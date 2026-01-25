# Architecture Overview

This repo demonstrates a **hands‑on** deployment for multi‑dimensional access decisions with an edge-friendly policy engine.

## Components

- **pdp (Rust + Cedar)** — Policy Decision Point with two paths:
  - **Policy mode** (Cedar): `POST /decide` with `context` → evaluates the declarative rule.
  - **Capability mode**: `POST /decide` with `capability_b64` → verifies Ed25519 signature and time window.
  - **Token issuer**: `POST /issue-capability` creates short‑lived CBOR tokens for bookings.
  - **Pubkey**: `GET /pubkey` returns the Ed25519 public key (base64).

- **redis** — Lightweight state:
  - `last:user:{userId}` hash → `{door, time, lat, lon}` (TTL 1h)
  - (extendable) Streams for recent events if you add velocity rules.

## Data Flow (local demo)

1. **Issue a capability** for a booking window: `POST /issue-capability` → base64(CBOR).
2. **Decide** at the PDP:
   - Capability mode: send `capability_b64` to `POST /decide` (fast path).
   - Policy mode: send `context` (mirrors your SQL join as pre‑joined facts).
3. On **allow + observe=true**, PDP writes `last_open` to Redis.

## Why this shape?

- Push **data** (short‑lived, signed capability) instead of pushing rules.
- Keep a **static**, human‑readable **policy** for general eligibility.
- Use Redis for **tiny contextual memory** (recent event), avoiding DB joins on the hot path.

## Run it

```bash
docker compose up --build -d
# test: policy mode
cd sample && ./curl.sh
# test: capability mode
./capability_flow.sh
```

The PDP listens on **http://localhost:8080**.

## API Summary

- `POST /decide`
  - **Policy mode** payload: `principal`, `resource`, `context`, `observe?`
  - **Capability mode** payload: `principal`, `resource`, `capability_b64`, `observe?`
  - Returns: `{ "allow": bool, "reason": string|null, "mode": "policy|capability" }`

- `POST /issue-capability`
  - Body: `{ sub, aud, res, act, nbf_epoch, exp_epoch, booking_id?, modifiers[], jti }`
  - Returns: `{ capability_b64, pubkey_b64 }`

- `GET /pubkey`
  - Returns: `{ pubkey_b64 }`

## Extending

- Add **Streams**: record every decision in `XADD ev:user:{id}` for burst/velocity rules.
- Add **BLE/NFC** codec**:** reuse the same CBOR capability for offline opens.
- Swap Cedar for **Rego→WASM** under `opa/` if you need hot‑swappable policies.
- Split audience: use **lock‑id** as `aud` and **door/area** as `res` to scope tokens tightly.

## Security Notes

- Ed25519 keys are generated on startup for demo. Load them from secure storage in production.
- Keep capabilities **short‑lived**; prefer revocation via key rotation and time windows.
- Ensure devices have a **trusted clock** (periodic time beacons or secure RTC).
