#!/usr/bin/env bash
# Build the OpenObserve SUT from source and wait until healthy.
# OpenObserve facts (verified 2026-06-23):
#   Port:       5080 (ZO_HTTP_PORT default; serves API + embedded web UI)
#   Health:     GET /healthz -> 200 {"status":"ok"} (no auth)
#   Dockerfile: deploy/build/Dockerfile (web build + cargo --release; SLOW)
set -euo pipefail
cd "$(dirname "$0")"
echo "Building OpenObserve SUT from source (Rust release + Vue build — this is slow)..."
docker compose -f docker-compose.yml up -d --build
echo "Waiting for health endpoint http://localhost:5080/healthz ..."
for i in $(seq 1 120); do
  if curl -sf -m 3 http://localhost:5080/healthz >/dev/null; then echo "SUT healthy"; break; fi
  sleep 3
  [[ $i -eq 120 ]] && { echo "SUT failed to become healthy"; docker compose logs --tail 80; exit 1; }
done
echo "Setup complete"
