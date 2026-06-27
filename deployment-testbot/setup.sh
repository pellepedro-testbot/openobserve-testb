#!/usr/bin/env bash
# Build the OpenObserve SUT from source (Rust release + embedded Vue UI) so the eval
# exercises the PR's development code — NOT a pre-built release image. Runs on the
# self-hosted runner (sufficient memory); the from-source build OOMs a 15 GiB GitHub runner.
set -euo pipefail
cd "$(dirname "$0")"
echo "Building OpenObserve SUT from source (dev code)..."
docker compose -f docker-compose.yml up -d --build
echo "Waiting for health endpoint http://localhost:5080/healthz ..."
for i in $(seq 1 200); do
  if curl -sf -m 3 http://localhost:5080/healthz >/dev/null; then echo "SUT healthy"; break; fi
  sleep 3
  [[ $i -eq 200 ]] && { echo "SUT failed to become healthy"; docker compose logs --tail 80; exit 1; }
done
echo "Setup complete"
