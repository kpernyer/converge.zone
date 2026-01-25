#!/usr/bin/env bash
set -euo pipefail

ISSUE=$(curl -sS -X POST http://localhost:8080/issue-capability   -H 'content-type: application/json'   -d '{
    "sub":"user:ch_42",
    "aud":"apoint:A-17",
    "res":"area:WestWing",
    "act":"open",
    "nbf_epoch": 1730365800,
    "exp_epoch": 1730367600,
    "booking_id":"B-2025-10-31-12",
    "modifiers":["standard"],
    "jti":"abc123"
  }')

CAP=$(echo "$ISSUE" | jq -r .capability_b64)

curl -sS -X POST http://localhost:8080/decide   -H 'content-type: application/json'   -d "{
    \"principal\": {\"id\": \"user:ch_42\", \"profiles\": []},
    \"resource\": {\"id\": \"apoint:A-17\", \"area_id\": \"area:WestWing\"},
    \"capability_b64\": \"${CAP}\",
    \"observe\": true
  }" | jq .
