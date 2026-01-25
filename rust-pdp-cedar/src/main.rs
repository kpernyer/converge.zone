use axum::{routing::{post, get}, Json, Router};
use serde::{Deserialize, Serialize};
use std::{fs, net::SocketAddr, sync::Arc};
use tracing_subscriber::FmtSubscriber;

use cedar_policy::{
    Authorizer, Context, Entities, EntityId, EntityTypeName, EvalResult, Policy, PolicySet,
    Request, Schema, Value,
};

use ed25519_dalek::{Signer, SigningKey, VerifyingKey, Signature};
use ciborium::{ser, de};
use base64::{engine::general_purpose, Engine as _};

// -------------------- Domain structs --------------------

#[derive(Debug, Deserialize)]
struct Profile {
    id: String,
    vf_min: i64, // valid_from in minutes (or epoch minutes, up to you)
    vt_min: i64, // valid_to in minutes
}

#[derive(Debug, Deserialize)]
struct PrincipalIn {
    id: String,
    profiles: Vec<Profile>,
}

#[derive(Debug, Deserialize)]
struct ResourceIn {
    id: String,
    area_id: String,
}

#[derive(Debug, Deserialize, Clone)]
struct PolicyFact {
    profile_id: String,
    area_id: String,
    schedule_id: String,
    modifiers: Vec<String>,
}

#[derive(Debug, Deserialize)]
struct ContextIn {
    now_min: i64,
    allowed_schedule_ids: Vec<String>,
    required_modifier: String,
    policies: Vec<PolicyFact>,
}

#[derive(Debug, Deserialize)]
struct DecideReq {
    principal: PrincipalIn,
    resource: ResourceIn,
    context: Option<ContextIn>, // optional when using capability token path
    observe: Option<bool>,      // if allowed, append event to Redis
    capability_b64: Option<String>, // optional compact capability token (CBOR bytes, base64)
}

#[derive(Debug, Serialize)]
struct DecideResp {
    allow: bool,
    reason: Option<String>,
    mode: String, // "policy" or "capability"
}

// For Redis last_open
#[derive(Debug, Serialize, Deserialize, Clone)]
struct LastOpen {
    door: String,
    time_hhmm: String, // "HH:MM"
    lat: f64,
    lon: f64,
}

// -------------------- Capability token --------------------

// Keep it small & explicit; encode as CBOR, transport as base64
#[derive(Debug, Serialize, Deserialize, Clone)]
struct Capability {
    sub: String,          // user id
    aud: String,          // lock/controller id
    res: String,          // resource area/door id
    act: String,          // "open"
    nbf_epoch: i64,       // not-before epoch (seconds)
    exp_epoch: i64,       // expires epoch (seconds)
    booking_id: Option<String>,
    modifiers: Vec<String>,
    jti: String,          // nonce/id for replay protection
    sig: Option<Vec<u8>>, // signature (ed25519) over the CBOR-encoded fields without sig
}

// Helper to CBOR-encode a Capability **without** the signature field
fn capability_sig_message(c: &Capability) -> Vec<u8> {
    // Create a clone with sig=None to sign canonical content
    let mut to_sign = c.clone();
    to_sign.sig = None;
    let mut buf = Vec::new();
    ser::into_writer(&to_sign, &mut buf).expect("CBOR serialize");
    buf
}

// -------------------- App State --------------------

#[derive(Clone)]
struct AppState {
    policies: PolicySet,
    schema: Schema,
    auth: Authorizer,
    redis_url: String,
    // signing/verification keys (demo: generate on start if not provided)
    signing_key: Arc<SigningKey>,
    verifying_key: Arc<VerifyingKey>,
}

#[tokio::main]
async fn main() -> anyhow::Result<()> {
    // Logging
    let subscriber = FmtSubscriber::new();
    tracing::subscriber::set_global_default(subscriber).ok();

    // Load Cedar policy
    let policy_text = fs::read_to_string("policies/policy.cedar")?;
    let ps = PolicySet::from_policies([Policy::from_str("P1", &policy_text)?])?;
    let schema = Schema::empty();
    let auth = Authorizer::new();

    // Keys (in production, load from secure storage)
    let signing_key = SigningKey::from_bytes(&rand::random::<[u8; 32]>());
    let verifying_key = signing_key.verifying_key();

    let state = AppState {
        policies: ps,
        schema,
        auth,
        redis_url: std::env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1/".into()),
        signing_key: Arc::new(signing_key),
        verifying_key: Arc::new(verifying_key),
    };

    // Routes
    let app = Router::new()
        .route("/decide", post(decide))
        .route("/issue-capability", post(issue_capability))
        .route("/pubkey", get(pubkey))
        .with_state(state);

    let addr: SocketAddr = "0.0.0.0:8080".parse()?;
    println!("pdp-cedar listening on http://{addr}");
    println!("POST /decide  | POST /issue-capability | GET /pubkey");
    let listener = tokio::net::TcpListener::bind(addr).await?;
    axum::serve(listener, app).await?;
    Ok(())
}

async fn redis_conn(url: &str) -> redis::aio::Connection {
    let client = redis::Client::open(url).expect("redis client");
    client.get_async_connection().await.expect("redis conn")
}

// Fetch last_open from Redis into ContextIn-like usage
async fn fetch_last_open(redis_url: &str, user_id: &str) -> Option<LastOpen> {
    let mut con = redis_conn(redis_url).await;
    let key = format!("last:user:{user_id}");
    let (door, time, lat, lon): (String, String, String, String) = match redis::cmd("HMGET")
        .arg(&key)
        .arg(&["door", "time", "lat", "lon"])
        .query_async(&mut con)
        .await
    {
        Ok(v) => v,
        Err(_) => return None,
    };
    if time.is_empty() {
        return None;
    }
    Some(LastOpen {
        door,
        time_hhmm: time,
        lat: lat.parse().unwrap_or(0.0),
        lon: lon.parse().unwrap_or(0.0),
    })
}

// Append event to Redis on successful open
async fn append_event(redis_url: &str, user_id: &str, resource_id: &str, time_hhmm: &str, lat: f64, lon: f64) {
    let mut con = redis_conn(redis_url).await;
    let last_key = format!("last:user:{user_id}");
    let _: () = redis::pipe()
        .hset(&last_key, "door", resource_id)
        .hset(&last_key, "time", time_hhmm)
        .hset(&last_key, "lat", lat.to_string())
        .hset(&last_key, "lon", lon.to_string())
        .expire(&last_key, 3600)
        .query_async(&mut con)
        .await
        .unwrap_or(());
}

// -------------------- Endpoints --------------------

// Decide endpoint supports two modes:
// 1) Policy mode (context present): standard Cedar policy evaluation.
//    It also fetches Redis last_open (if you extend the Cedar policy to use it).
// 2) Capability mode (capability_b64 present): verify Ed25519 signature & time window locally.
async fn decide(
    axum::extract::State(state): axum::extract::State<AppState>,
    Json(input): Json<DecideReq>,
) -> Json<DecideResp> {
    if let Some(cap_b64) = input.capability_b64.as_ref() {
        // -------- Capability path (fast) --------
        let allow = verify_capability(cap_b64, &state.verifying_key, &input).unwrap_or(false);
        if allow && input.observe.unwrap_or(false) {
            // in cap mode, we don't necessarily have lat/lon; append minimal event
            append_event(&state.redis_url, &input.principal.id, &input.resource.id, "00:00", 0.0, 0.0).await;
        }
        return Json(DecideResp { allow, reason: None, mode: "capability".into() });
    }

    // -------- Policy path (Cedar) --------
    // (Optional) you can enrich context with last_open from Redis, if policy uses it
    let _last = fetch_last_open(&state.redis_url, &input.principal.id).await;

    let Some(ctx) = input.context else {
        return Json(DecideResp { allow: false, reason: Some("missing context or capability".into()), mode: "policy".into() });
    };

    // Build Entities (principal, resource) with attributes
    let mut ents = Entities::empty();
    let p_eid = EntityId::from_type_name_and_id(
        &EntityTypeName::from("User::User"),
        &input.principal.id,
    );
    let r_eid = EntityId::from_type_name_and_id(
        &EntityTypeName::from("Door::Door"),
        &input.resource.id,
    );

    // principal attributes
    let profiles_val = Value::set(
        input
            .principal
            .profiles
            .into_iter()
            .map(|p| {
                Value::record([
                    ("id".into(), Value::from(p.id)),
                    ("vf_min".into(), Value::from(p.vf_min)),
                    ("vt_min".into(), Value::from(p.vt_min)),
                ])
            })
            .collect(),
    );

    ents.add(
        p_eid.clone(),
        None,
        Some(Value::record([("profiles".into(), profiles_val)])),
        None,
    ).ok();

    // resource attributes
    ents.add(
        r_eid.clone(),
        None,
        Some(Value::record([(
            "area_id".into(),
            Value::from(input.resource.area_id),
        )])),
        None,
    ).ok();

    // Context value (now_min, allowed_schedule_ids, required_modifier, policies[])
    let policies_val = Value::set(
        ctx
            .policies
            .into_iter()
            .map(|pol| {
                Value::record([
                    ("profile_id".into(), Value::from(pol.profile_id)),
                    ("area_id".into(), Value::from(pol.area_id)),
                    ("schedule_id".into(), Value::from(pol.schedule_id)),
                    (
                        "modifiers".into(),
                        Value::set(pol.modifiers.into_iter().map(Value::from).collect()),
                    ),
                ])
            })
            .collect(),
    );

    let ctx_val = Value::record([
        ("now_min".into(), Value::from(ctx.now_min)),
        (
            "allowed_schedule_ids".into(),
            Value::set(
                ctx.allowed_schedule_ids.into_iter().map(Value::from).collect(),
            ),
        ),
        (
            "required_modifier".into(),
            Value::from(ctx.required_modifier),
        ),
        ("policies".into(), policies_val),
    ]);

    let context = Context::from_json_value(ctx_val).unwrap_or_default();

    // Build request (principal, action, resource)
    let rq = Request::new(
        p_eid,
        "Action::\"open\"".parse().unwrap(),
        r_eid,
        Some(context),
        None,
    );

    // Authorize
    let eval_res = state.auth.is_authorized(&rq, &state.policies, &ents);

    let allow = matches!(eval_res.decision, cedar_policy::Decision::Allow);
    let reason = eval_res
        .diagnostics
        .reason
        .map(|r| format!("{:?}", r));

    if allow && input.observe.unwrap_or(false) {
        append_event(&state.redis_url, &input.principal.id, &input.resource.id, "00:00", 0.0, 0.0).await;
    }

    Json(DecideResp { allow, reason, mode: "policy".into() })
}

// Issue a booking capability token for a given window, sign with Ed25519
#[derive(Debug, Deserialize)]
struct IssueReq {
    sub: String,
    aud: String,
    res: String,
    act: String,        // "open"
    nbf_epoch: i64,     // seconds
    exp_epoch: i64,     // seconds
    booking_id: Option<String>,
    modifiers: Vec<String>,
    jti: String,
}

#[derive(Debug, Serialize)]
struct IssueResp {
    capability_b64: String,
    pubkey_b64: String,
}

async fn issue_capability(
    axum::extract::State(state): axum::extract::State<AppState>,
    Json(req): Json<IssueReq>,
) -> Json<IssueResp> {
    let mut cap = Capability {
        sub: req.sub,
        aud: req.aud,
        res: req.res,
        act: req.act,
        nbf_epoch: req.nbf_epoch,
        exp_epoch: req.exp_epoch,
        booking_id: req.booking_id,
        modifiers: req.modifiers,
        jti: req.jti,
        sig: None,
    };
    let msg = capability_sig_message(&cap);
    let sig: Signature = state.signing_key.sign(&msg);
    cap.sig = Some(sig.to_bytes().to_vec());

    // CBOR encode full capability (including sig) then base64
    let mut buf = Vec::new();
    ser::into_writer(&cap, &mut buf).expect("cbor encode");
    let b64 = general_purpose::STANDARD_NO_PAD.encode(&buf);
    let pub_b64 = general_purpose::STANDARD_NO_PAD.encode(state.verifying_key.to_bytes());

    Json(IssueResp { capability_b64: b64, pubkey_b64: pub_b64 })
}

#[derive(Debug, Serialize)]
struct PubKeyResp { pubkey_b64: String }

async fn pubkey(
    axum::extract::State(state): axum::extract::State<AppState>,
) -> Json<PubKeyResp> {
    let pub_b64 = general_purpose::STANDARD_NO_PAD.encode(state.verifying_key.to_bytes());
    Json(PubKeyResp { pubkey_b64: pub_b64 })
}

// Verify a capability and basic constraints
fn verify_capability(b64: &str, vkey: &VerifyingKey, req: &DecideReq) -> Option<bool> {
    let raw = general_purpose::STANDARD_NO_PAD.decode(b64).ok()?;
    let cap: Capability = de::from_reader(raw.as_slice()).ok()?;

    // Check signature
    let msg = capability_sig_message(&cap);
    let sig_bytes = cap.sig.clone()?;
    let sig = Signature::from_slice(&sig_bytes).ok()?;
    if vkey.verify_strict(&msg, &sig).is_err() {
        return Some(false);
    }

    // Time window & audience/resource checks (basic; extend as needed)
    let now_epoch = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH).ok()?.as_secs() as i64;
    if now_epoch < cap.nbf_epoch || now_epoch > cap.exp_epoch {
        return Some(false);
    }
    if cap.aud != req.resource.id {
        // If your audience is the lock id rather than resource.id, adjust comparison here.
        return Some(false);
    }
    if cap.res != req.resource.area_id && cap.res != req.resource.id {
        // allow either area match or exact resource match
        return Some(false);
    }
    if cap.act != "open" {
        return Some(false);
    }
    // Check required modifier if policy path would have enforced it
    if let Some(ctx) = req.context.as_ref() {
        if !cap.modifiers.iter().any(|m| m == &ctx.required_modifier) {
            return Some(false);
        }
    }
    Some(true)
}
