#!/usr/bin/env bash
set -euo pipefail

URL="http://localhost:8080/"          # <-- falls du ein konkretes endpoint hast, z.B. /api/hello, ändere das hier
EXPECTED_FILE="ci/expected_root.txt"   # optional: wenn vorhanden, wird Inhalt verglichen

# Warte, bis Service antwortet (max ~60s)
code="000"
for i in {1..30}; do
  code=$(curl -s -o /dev/null -w "%{http_code}" "$URL" || echo "000")
  if [ "$code" = "200" ]; then
    echo "Service antwortet (HTTP 200)."
    break
  fi
  echo "Warte auf Service... ($i/30) (aktueller HTTP-Code: $code)"
  sleep 2
done

if [ "$code" != "200" ]; then
  echo "Fehler: Service antwortet nicht mit 200 (got $code)."
  echo "Letzte Container-Logs (200 Zeilen):"
  docker logs --tail 200 devops-app-team9 || true
  exit 2
fi

# Falls eine erwartete Datei vorhanden ist, vergleiche Inhalte
if [ -f "$EXPECTED_FILE" ]; then
  actual="$(curl -sS "$URL")"
  expected="$(cat "$EXPECTED_FILE")"
  if [ "$actual" = "$expected" ]; then
    echo "Integrationstest bestanden: Inhalt stimmt überein."
    exit 0
  else
    echo "Integrationstest fehlgeschlagen: Inhalt stimmt NICHT überein."
    echo "---- expected ----"
    echo "$expected"
    echo "---- actual ----"
    echo "$actual"
    docker logs --tail 200 devops-app-team9 || true
    exit 3
  fi
else
  echo "Keine erwartete Datei ($EXPECTED_FILE) vorhanden. Status-Check reichte (200)."
  exit 0
fi
