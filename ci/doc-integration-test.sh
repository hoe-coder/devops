#!/usr/bin/env bash
set -euo pipefail

URL="http://localhost:8082"

# Warte bis Doku-Service 200 zurückgibt
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")
  if [ "$code" = "200" ]; then
    echo "Documentation service antwortet mit 200."
    exit 0
  fi
  echo "Warte... ($i/30) aktueller Code: $code"
  sleep 2
done

echo "Fehler: Documentation service gibt nicht 200 zurück (got $code)."
docker logs --tail 100 mydoc || true
exit 1