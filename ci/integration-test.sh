#!/usr/bin/env bash
set -euo pipefail

URL="http://localhost:8080/api/hello"
EXPECTED="Hello from DevOps App!"

# Warte bis Service 200 zurückgibt
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")
  if [ "$code" = "200" ]; then
    echo "Service antwortet mit 200."
    break
  fi
  echo "Warte... ($i/30) aktueller Code: $code"
  sleep 2
done

if [ "$code" != "200" ]; then
  echo "Fehler: Service gibt nicht 200 zurück (got $code)."
  docker logs --tail 100 devops-app-team9 || true
  exit 1
fi

# Inhalt checken
actual=$(curl -s "$URL")
if [ "$actual" = "$EXPECTED" ]; then
  echo "Integrationstest bestanden: Inhalt stimmt."
  exit 0
else
  echo "Integrationstest fehlgeschlagen!"
  echo "Expected: $EXPECTED"
  echo "Actual:   $actual"
  docker logs --tail 100 devops-app-team9 || true
  exit 2
fi