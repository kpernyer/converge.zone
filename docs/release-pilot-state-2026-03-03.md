# Release Pilot Current State (March 3, 2026)

## Scope

This snapshot covers the release-readiness pilot across:

- `converge-www` (web UX, auth, invite gate, SSE timeline)
- `converge-runtime` (pilot API + SSE + auth checks)
- `/Users/kpernyer/repo/cloud-agents` (deployment control-plane scripts and spec)

Issue tracking reference: `cz-e3u.11` is currently `IN_PROGRESS`.

## What is implemented

### 1. Pilot flow is implemented end-to-end in code

- Invite-only access and approval capture in web UI:
  - `converge-www/src/app/pages/ReleaseReadinessPilot.tsx`
  - `converge-www/src/app/pages/releaseReadinessPilotAccess.ts`
- Protected routes for pilot/apps/settings:
  - `converge-www/src/main.tsx`
- Runtime-backed pilot API and SSE:
  - `converge-runtime/src/pilot.rs`
  - merged into router:
    - `converge-runtime/src/http.rs`
    - `converge-runtime/src/lib.rs`
- Invite validation Cloud Function:
  - `converge-www/functions/src/index.ts`
- Web env/proxy wiring for `/api` and functions:
  - `converge-www/src/config/env.ts`
  - `converge-www/vite.config.ts`
  - `converge-www/.env.example`
- Firebase Hosting rewrite to runtime:
  - `converge-www/firebase.json`

### 2. Control-plane moved out of Terraform and into cloud-agents

- Runtime+web deployment contract:
  - `converge-runtime/docs/deployment/RELEASE_PILOT_HOSTING.md`
  - `converge-runtime/docs/deployment/CONTROL_PLANE_HANDOFF.md`
- Cloud-agents control-plane spec and scripts:
  - `/Users/kpernyer/repo/cloud-agents/docs/converge-release-pilot-control-plane.md`
  - `/Users/kpernyer/repo/cloud-agents/profiles/converge-release-pilot.env`
  - `/Users/kpernyer/repo/cloud-agents/scripts/converge-runtime-deploy.sh`
  - `/Users/kpernyer/repo/cloud-agents/scripts/converge-web-deploy.sh`
  - `/Users/kpernyer/repo/cloud-agents/scripts/converge-pilot-smoke.sh`

## Validation status

Validated locally on March 3, 2026:

- `converge-runtime`
  - `cargo check` -> pass
  - `cargo test pilot:: --lib` -> pass (3 tests)
- `converge-www`
  - `bun run typecheck` -> pass
  - `bun test src/app/pages/releaseReadinessPilotModel.test.ts` -> pass (12 tests)
- `cloud-agents`
  - `bash -n` passed for all new pilot scripts

Known valid invite codes:

- `release-readiness-pilot`
- `design-partner-v0`
- `converge-zone-rr-demo`

## What is not done yet

### 1. Production deployment has not been executed from this session

- Runtime deploy script has been created, but not run in production with real cloud credentials.
- Web+functions deploy script has been created, but not run in production in this session.
- Smoke script exists, but has not been run with a real `SMOKE_FIREBASE_ID_TOKEN`.

### 2. Tracking closure is pending

- `cz-e3u.11` remains open (`IN_PROGRESS`) until hosted HTTPS + operator health/log verification is confirmed.

## Immediate next commands

From `/Users/kpernyer/repo/cloud-agents`:

```bash
WORKLOAD_PROFILE=converge-release-pilot \
GCP_PROJECT=<gcp-project> \
FIREBASE_PROJECT=<firebase-project> \
CLOUD_RUN_IMAGE=gcr.io/<gcp-project>/converge-runtime:<tag> \
scripts/converge-runtime-deploy.sh

WORKLOAD_PROFILE=converge-release-pilot \
GCP_PROJECT=<gcp-project> \
FIREBASE_PROJECT=<firebase-project> \
scripts/converge-web-deploy.sh

WORKLOAD_PROFILE=converge-release-pilot \
GCP_PROJECT=<gcp-project> \
FIREBASE_PROJECT=<firebase-project> \
SMOKE_FIREBASE_ID_TOKEN=<firebase-id-token> \
scripts/converge-pilot-smoke.sh
```

Then:

1. Verify `/demo/release-readiness` works on the live URL.
2. Confirm logs and health checks in your control-plane.
3. Close `cz-e3u.11`.
