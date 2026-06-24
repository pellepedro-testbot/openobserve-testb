#!/usr/bin/env bash
# Build the SUT from source and wait until healthy. Tuned for Mealie.
# Mealie facts (verified 2026-06-13):
#   Port:       9000 (APP_PORT env default, EXPOSE 9000 in Dockerfile)
#   Health:     GET /api/app/about  (confirmed in docker/healthcheck.sh)
#   Dockerfile: docker/Dockerfile   (ENTRYPOINT /app/run.sh, target=production)
set -euo pipefail
cd "$(dirname "$0")"
echo "Building SUT from source + starting..."
docker compose -f docker-compose.yml up -d --build
echo "Waiting for health endpoint..."
for i in $(seq 1 60); do
  if curl -sf -m 3 http://localhost:9000/api/app/about >/dev/null; then echo "SUT healthy"; break; fi
  sleep 3
  [[ $i -eq 60 ]] && { echo "SUT failed to become healthy"; docker compose logs --tail 50; exit 1; }
done
echo "Setup complete"
