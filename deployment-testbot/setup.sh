#!/usr/bin/env bash
# Start the OpenObserve SUT and wait until healthy.
#
# Two modes (auto-detected):
#   CI (GITHUB_ACTIONS=true):  pull published openobserve/openobserve:v0.91.0 — avoids
#       the >16 GB RAM needed to build Rust+Vue from source on hosted runners.
#       Image is tagged locally as openobserve-testb:eval so docker-compose finds it.
#   Local:  build from source (requires ~32 GB RAM + Rust nightly toolchain).
#
# Port:    5080  |  Health: GET /healthz -> 200 {"status":"ok"}
set -euo pipefail
cd "$(dirname "$0")"

PUBLISHED_IMAGE="openobserve/openobserve:v0.91.0"
LOCAL_TAG="openobserve-testb:eval"

if [[ "${GITHUB_ACTIONS:-false}" == "true" ]]; then
  echo "CI mode: pulling ${PUBLISHED_IMAGE} (from-source build needs >16 GB RAM on hosted runners)..."
  docker pull "${PUBLISHED_IMAGE}"
  docker tag  "${PUBLISHED_IMAGE}" "${LOCAL_TAG}"
  docker compose -f docker-compose.yml up -d
else
  echo "Local mode: building OpenObserve from source (Rust release + Vue — slow)..."
  docker compose -f docker-compose.yml up -d --build
fi

echo "Waiting for health endpoint http://localhost:5080/healthz ..."
for i in $(seq 1 120); do
  if curl -sf -m 3 http://localhost:5080/healthz >/dev/null; then echo "SUT healthy"; break; fi
  sleep 3
  [[ $i -eq 120 ]] && { echo "SUT failed to become healthy"; docker compose logs --tail 80; exit 1; }
done
echo "Setup complete"

