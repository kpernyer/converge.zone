#!/usr/bin/env bash
set -euo pipefail
JSON=$(cat "$(dirname "$0")/input.json")
curl -sS -X POST http://localhost:8080/decide   -H 'content-type: application/json'   -d "$JSON" | jq .
