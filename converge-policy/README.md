# Converge Policy Provider (Cedar-first, OPA optional)

Converge Policy is a **deterministic Policy Decision Point (PDP)** that fits the
Converge gate model: it evaluates **policy/authority gates** with explicit,
auditable inputs. It is Cedar-first, with an optional OPA adapter.

- ✅ **Cedar** PDP for policy evaluation (Rust-native)
- ✅ **Axum** HTTP endpoints for `decide`, `issue-capability`, `pubkey`
- ✅ **Capability tokens** for fast-path, short-lived commitments
- ✅ **No DB joins** on the hot path — pass pre-joined facts
- ➕ Optional **Rego/OPA** example under `opa/` (WASM-compatible)

## Quick start

```bash
# 1) Install Rust toolchain
# 2) Build & run
cd rust-pdp-cedar
cargo run

# In another terminal, test:
bash ../sample/curl.sh
```

The service expects JSON like `sample/input.json` and returns `{ "allow": true/false }`.

## Structure

```
converge-policy/
├─ rust-pdp-cedar/
│  ├─ Cargo.toml
│  ├─ src/main.rs
│  └─ policies/policy.cedar
├─ opa/
│  └─ policy.rego
├─ sample/
│  ├─ input.json
│  └─ curl.sh
└─ README.md
```

## Why Cedar first?

- Clear, concise rules for ABAC/ReBAC
- Tiny Rust dependency, no separate daemon
- Great fit for edge gateways / small devices

## Next steps

- Add schedule range helpers (precompute to numeric minutes)
- Add proof-carrying capability envelopes for commitments
- Add Redis/flash KV cache for `last_open` if you need velocity checks
```

Open this folder in your IDE and iterate. PRs welcome (😉).


## Redis-backed `last_open` and Capability Tokens

- Set `REDIS_URL` env var (defaults to `redis://127.0.0.1/`)
- **Endpoints**:
  - `POST /issue-capability` → returns a signed base64(CBOR) token
  - `GET  /pubkey` → base64 public key for verification
  - `POST /decide` → two modes:
    - **Capability mode**: include `capability_b64` (fast path)
    - **Policy mode**: include `context` (as before). `observe=true` appends a `last_open` event to Redis.

### Examples

Issue a capability for a booking (11:50–13:20 UTC):

```bash
curl -sS -X POST http://localhost:8080/issue-capability   -H 'content-type: application/json'   -d '{
    "sub":"user:ch_42",
    "aud":"apoint:A-17",
    "res":"area:WestWing",
    "act":"open",
    "nbf_epoch": 1730365800,
    "exp_epoch": 1730367600,
    "booking_id":"B-2025-10-31-12",
    "modifiers":["standard"],
    "jti":"abc123"
  }' | jq .
```

Use the capability to open:

```bash
CAP=$(curl -s http://localhost:8080/issue-capability -H 'content-type: application/json' -d '{
  "sub":"user:ch_42",
  "aud":"apoint:A-17",
  "res":"area:WestWing",
  "act":"open",
  "nbf_epoch": 1730365800,
  "exp_epoch": 1730367600,
  "booking_id":"B-2025-10-31-12",
  "modifiers":["standard"],
  "jti":"abc123"
}' | jq -r .capability_b64)

curl -sS -X POST http://localhost:8080/decide   -H 'content-type: application/json'   -d "{
    "principal": {"id": "user:ch_42", "profiles": []},
    "resource": {"id": "apoint:A-17", "area_id":"area:WestWing"},
    "capability_b64": "${CAP}",
    "observe": true
  }" | jq .
```

The successful decision writes `last_open` to Redis under `last:user:user:ch_42`.


## Run with Docker Compose

```bash
docker compose up --build -d
# Wait a few seconds for pdp to start
cd sample
./curl.sh            # policy mode example
./capability_flow.sh # capability mode example
```
