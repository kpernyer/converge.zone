use axum::{
    Json, Router,
    http::StatusCode,
    response::{IntoResponse, Response},
    routing::{get, post},
};
use base64::{Engine as _, engine::general_purpose};
use cedar_policy::{
    Authorizer, Context, Entities, EntityId, EntityTypeName, Policy, PolicySet, Request, Value,
};
use ciborium::{de, ser};
use ed25519_dalek::{Signature, Signer, SigningKey, Verifier, VerifyingKey};
use serde::{Deserialize, Serialize};
use std::{fs, net::SocketAddr, sync::Arc};
use thiserror::Error;
use tracing::{info, warn};
use tracing_subscriber::FmtSubscriber;

#[derive(Debug, Error)]
enum AppError {
    #[error("policy file read failed: {0}")]
    PolicyRead(#[from] std::io::Error),
    #[error("policy parse failed: {0}")]
    Policy(String),
    #[error("request build failed: {0}")]
    Request(String),
    #[error("context build failed: {0}")]
    Context(String),
    #[error("redis error: {0}")]
    Redis(#[from] redis::RedisError),
    #[error("capability error: {0}")]
    Capability(String),
    #[error("server error: {0}")]
    Server(String),
}

impl AppError {
    fn status(&self) -> StatusCode {
        match self {
            AppError::Request(_) | AppError::Context(_) | AppError::Capability(_) => {
                StatusCode::BAD_REQUEST
            }
            AppError::Redis(_) => StatusCode::SERVICE_UNAVAILABLE,
            AppError::Policy(_) | AppError::PolicyRead(_) | AppError::Server(_) => {
                StatusCode::INTERNAL_SERVER_ERROR
            }
        }
    }
}

#[derive(Debug, Serialize)]
struct ErrorResponse {
    error: String,
}

impl IntoResponse for AppError {
    fn into_response(self) -> Response {
        let status = self.status();
        let body = Json(ErrorResponse {
            error: self.to_string(),
        });
        (status, body).into_response()
    }
}

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
    sub: String,    // user id
    aud: String,    // lock/controller id
    res: String,    // resource area/door id
    act: String,    // "open"
    nbf_epoch: i64, // not-before epoch (seconds)
    exp_epoch: i64, // expires epoch (seconds)
    booking_id: Option<String>,
    modifiers: Vec<String>,
    jti: String,          // nonce/id for replay protection
    sig: Option<Vec<u8>>, // signature (ed25519) over the CBOR-encoded fields without sig
}

// Helper to CBOR-encode a Capability **without** the signature field
fn capability_sig_message(c: &Capability) -> Result<Vec<u8>, String> {
    let mut to_sign = c.clone();
    to_sign.sig = None;
    let mut buf = Vec::new();
    ser::into_writer(&to_sign, &mut buf).map_err(|err| err.to_string())?;
    Ok(buf)
}

// -------------------- App State --------------------

#[derive(Clone)]
struct AppState {
    policies: PolicySet,
    auth: Authorizer,
    redis_url: String,
    // signing/verification keys (demo: generate on start if not provided)
    signing_key: Arc<SigningKey>,
    verifying_key: Arc<VerifyingKey>,
}

#[tokio::main]
async fn main() -> Result<(), AppError> {
    let subscriber = FmtSubscriber::new();
    if let Err(err) = tracing::subscriber::set_global_default(subscriber) {
        eprintln!("logging already initialized: {err}");
    }

    let policy_text = fs::read_to_string("policies/policy.cedar")?;
    let policy =
        Policy::from_str("P1", &policy_text).map_err(|err| AppError::Policy(err.to_string()))?;
    let ps = PolicySet::from_policies([policy]).map_err(|err| AppError::Policy(err.to_string()))?;
    let auth = Authorizer::new();

    let signing_key = SigningKey::from_bytes(&rand::random::<[u8; 32]>());
    let verifying_key = signing_key.verifying_key();

    let state = AppState {
        policies: ps,
        auth,
        redis_url: std::env::var("REDIS_URL").unwrap_or_else(|_| "redis://127.0.0.1/".into()),
        signing_key: Arc::new(signing_key),
        verifying_key: Arc::new(verifying_key),
    };

    let app = Router::new()
        .route("/decide", post(decide))
        .route("/issue-capability", post(issue_capability))
        .route("/pubkey", get(pubkey))
        .with_state(state);

    let addr: SocketAddr = "0.0.0.0:8080"
        .parse()
        .map_err(|err| AppError::Server(err.to_string()))?;
    info!(%addr, "converge-policy listening");
    let listener = tokio::net::TcpListener::bind(addr)
        .await
        .map_err(|err| AppError::Server(err.to_string()))?;
    axum::serve(listener, app)
        .await
        .map_err(|err| AppError::Server(err.to_string()))?;
    Ok(())
}

async fn redis_conn(url: &str) -> Result<redis::aio::Connection, AppError> {
    let client = redis::Client::open(url)?;
    client.get_async_connection().await.map_err(AppError::from)
}

// Fetch last_open from Redis into ContextIn-like usage
async fn fetch_last_open(redis_url: &str, user_id: &str) -> Result<Option<LastOpen>, AppError> {
    let mut con = redis_conn(redis_url).await?;
    let key = format!("last:user:{user_id}");
    let (door, time, lat, lon): (
        Option<String>,
        Option<String>,
        Option<String>,
        Option<String>,
    ) = redis::cmd("HMGET")
        .arg(&key)
        .arg(&["door", "time", "lat", "lon"])
        .query_async(&mut con)
        .await?;
    let time = time.unwrap_or_default();
    if time.is_empty() {
        return Ok(None);
    }
    Ok(Some(LastOpen {
        door: door.unwrap_or_default(),
        time_hhmm: time,
        lat: lat.and_then(|value| value.parse().ok()).unwrap_or(0.0),
        lon: lon.and_then(|value| value.parse().ok()).unwrap_or(0.0),
    }))
}

// Append event to Redis on successful open
async fn append_event(
    redis_url: &str,
    user_id: &str,
    resource_id: &str,
    time_hhmm: &str,
    lat: f64,
    lon: f64,
) -> Result<(), AppError> {
    let mut con = redis_conn(redis_url).await?;
    let last_key = format!("last:user:{user_id}");
    redis::pipe()
        .hset(&last_key, "door", resource_id)
        .hset(&last_key, "time", time_hhmm)
        .hset(&last_key, "lat", lat.to_string())
        .hset(&last_key, "lon", lon.to_string())
        .expire(&last_key, 3600)
        .query_async(&mut con)
        .await?;
    Ok(())
}

// -------------------- Endpoints --------------------

// Decide endpoint supports two modes:
// 1) Policy mode (context present): standard Cedar policy evaluation.
//    It also fetches Redis last_open (if you extend the Cedar policy to use it).
// 2) Capability mode (capability_b64 present): verify Ed25519 signature & time window locally.
async fn decide(
    axum::extract::State(state): axum::extract::State<AppState>,
    Json(input): Json<DecideReq>,
) -> Result<Json<DecideResp>, AppError> {
    if let Some(cap_b64) = input.capability_b64.as_ref() {
        let allow = match verify_capability(cap_b64, &state.verifying_key, &input) {
            Ok(allow) => allow,
            Err(reason) => {
                return Ok(Json(DecideResp {
                    allow: false,
                    reason: Some(reason),
                    mode: "capability".into(),
                }));
            }
        };
        if allow && input.observe.unwrap_or(false) {
            if let Err(err) = append_event(
                &state.redis_url,
                &input.principal.id,
                &input.resource.id,
                "00:00",
                0.0,
                0.0,
            )
            .await
            {
                warn!(error = %err, "failed to append capability event");
            }
        }
        return Ok(Json(DecideResp {
            allow,
            reason: None,
            mode: "capability".into(),
        }));
    }

    if let Err(err) = fetch_last_open(&state.redis_url, &input.principal.id).await {
        warn!(error = %err, "failed to fetch last_open");
    }

    let Some(ctx) = input.context else {
        return Ok(Json(DecideResp {
            allow: false,
            reason: Some("missing context or capability".into()),
            mode: "policy".into(),
        }));
    };

    let mut ents = Entities::empty();
    let p_eid =
        EntityId::from_type_name_and_id(&EntityTypeName::from("User::User"), &input.principal.id);
    let r_eid =
        EntityId::from_type_name_and_id(&EntityTypeName::from("Door::Door"), &input.resource.id);

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
    )
    .map_err(|err| AppError::Request(err.to_string()))?;

    ents.add(
        r_eid.clone(),
        None,
        Some(Value::record([(
            "area_id".into(),
            Value::from(input.resource.area_id),
        )])),
        None,
    )
    .map_err(|err| AppError::Request(err.to_string()))?;

    let policies_val = Value::set(
        ctx.policies
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
                ctx.allowed_schedule_ids
                    .into_iter()
                    .map(Value::from)
                    .collect(),
            ),
        ),
        (
            "required_modifier".into(),
            Value::from(ctx.required_modifier),
        ),
        ("policies".into(), policies_val),
    ]);

    let context =
        Context::from_json_value(ctx_val).map_err(|err| AppError::Context(err.to_string()))?;

    let action = "Action::\"open\""
        .parse()
        .map_err(|err| AppError::Request(err.to_string()))?;
    let rq = Request::new(p_eid, action, r_eid, Some(context), None)
        .map_err(|err| AppError::Request(err.to_string()))?;

    let eval_res = state.auth.is_authorized(&rq, &state.policies, &ents);
    let allow = matches!(eval_res.decision, cedar_policy::Decision::Allow);
    let reason = eval_res.diagnostics.reason.map(|r| format!("{:?}", r));

    if allow && input.observe.unwrap_or(false) {
        if let Err(err) = append_event(
            &state.redis_url,
            &input.principal.id,
            &input.resource.id,
            "00:00",
            0.0,
            0.0,
        )
        .await
        {
            warn!(error = %err, "failed to append policy event");
        }
    }

    Ok(Json(DecideResp {
        allow,
        reason,
        mode: "policy".into(),
    }))
}

// Issue a booking capability token for a given window, sign with Ed25519
#[derive(Debug, Deserialize)]
struct IssueReq {
    sub: String,
    aud: String,
    res: String,
    act: String, // "open"
    nbf_epoch: i64,
    exp_epoch: i64,
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
) -> Result<Json<IssueResp>, AppError> {
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
    let msg = capability_sig_message(&cap).map_err(|err| AppError::Capability(err.to_string()))?;
    let sig: Signature = state.signing_key.sign(&msg);
    cap.sig = Some(sig.to_bytes().to_vec());

    let mut buf = Vec::new();
    ser::into_writer(&cap, &mut buf).map_err(|err| AppError::Capability(err.to_string()))?;
    let b64 = general_purpose::STANDARD_NO_PAD.encode(&buf);
    let pub_b64 = general_purpose::STANDARD_NO_PAD.encode(state.verifying_key.to_bytes());

    Ok(Json(IssueResp {
        capability_b64: b64,
        pubkey_b64: pub_b64,
    }))
}

#[derive(Debug, Serialize)]
struct PubKeyResp {
    pubkey_b64: String,
}

async fn pubkey(
    axum::extract::State(state): axum::extract::State<AppState>,
) -> Result<Json<PubKeyResp>, AppError> {
    let pub_b64 = general_purpose::STANDARD_NO_PAD.encode(state.verifying_key.to_bytes());
    Ok(Json(PubKeyResp {
        pubkey_b64: pub_b64,
    }))
}

// Verify a capability and basic constraints
fn verify_capability(b64: &str, vkey: &VerifyingKey, req: &DecideReq) -> Result<bool, String> {
    let raw = general_purpose::STANDARD_NO_PAD
        .decode(b64)
        .map_err(|err| format!("capability decode failed: {err}"))?;
    let cap: Capability =
        de::from_reader(raw.as_slice()).map_err(|err| format!("capability parse failed: {err}"))?;

    let msg = capability_sig_message(&cap)?;
    let sig_bytes = cap
        .sig
        .clone()
        .ok_or_else(|| "capability signature missing".to_string())?;
    let sig = Signature::from_slice(&sig_bytes)
        .map_err(|_| "capability signature invalid".to_string())?;
    if vkey.verify_strict(&msg, &sig).is_err() {
        return Ok(false);
    }

    let now_epoch = std::time::SystemTime::now()
        .duration_since(std::time::UNIX_EPOCH)
        .map_err(|err| format!("time source invalid: {err}"))?
        .as_secs() as i64;
    if now_epoch < cap.nbf_epoch || now_epoch > cap.exp_epoch {
        return Ok(false);
    }
    if cap.aud != req.resource.id {
        return Ok(false);
    }
    if cap.res != req.resource.area_id && cap.res != req.resource.id {
        return Ok(false);
    }
    if cap.act != "open" {
        return Ok(false);
    }
    if let Some(ctx) = req.context.as_ref() {
        if !cap.modifiers.iter().any(|m| m == &ctx.required_modifier) {
            return Ok(false);
        }
    }
    Ok(true)
}
