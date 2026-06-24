#!/usr/bin/env bash
# Print a bearer token for the SUT. Tuned for Mealie default admin.
# Default credentials come from mealie/core/settings/settings.py:
#   _DEFAULT_EMAIL    = "changeme@example.com"
#   _DEFAULT_PASSWORD = "MyPassword"
# Auth endpoint: POST /api/auth/token  (application/x-www-form-urlencoded)
set -euo pipefail
USER="${MEALIE_ADMIN_EMAIL:-changeme@example.com}"
PASS="${MEALIE_ADMIN_PASSWORD:-MyPassword}"
curl -sf -m 10 -X POST http://localhost:9000/api/auth/token \
  -H 'Content-Type: application/x-www-form-urlencoded' \
  --data-urlencode "username=$USER" --data-urlencode "password=$PASS" \
  | python3 -c "import json,sys; print(json.load(sys.stdin)['access_token'])"
