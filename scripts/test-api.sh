#!/usr/bin/env bash
# Prueba manual de los endpoints CRUD con curl.
# Uso: ./scripts/test-api.sh [URL_BASE]   (por defecto http://localhost:8080)
set -euo pipefail

BASE="${1:-http://localhost:8080}/api/products"
line() { printf '\n==== %s ====\n' "$1"; }

line "GET todos"
curl -s -w '\nHTTP %{http_code}\n' "$BASE"

line "POST crear (201)"
RESP=$(curl -s -w '\n%{http_code}' -X POST "$BASE" \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"Audífonos Bluetooth","cantidad":40,"precio":799.90}')
BODY=$(echo "$RESP" | head -n -1); CODE=$(echo "$RESP" | tail -n 1)
echo "$BODY"; echo "HTTP $CODE"
ID=$(echo "$BODY" | sed -E 's/.*"id":([0-9]+).*/\1/')

line "GET por id ($ID)"
curl -s -w '\nHTTP %{http_code}\n' "$BASE/$ID"

line "PUT actualizar ($ID)"
curl -s -w '\nHTTP %{http_code}\n' -X PUT "$BASE/$ID" \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"Audífonos Bluetooth Pro","cantidad":35,"precio":999.00}'

line "POST inválido (400)"
curl -s -w '\nHTTP %{http_code}\n' -X POST "$BASE" \
  -H 'Content-Type: application/json' \
  -d '{"nombre":"","cantidad":-1,"precio":10}'

line "DELETE ($ID) (204)"
curl -s -o /dev/null -w 'HTTP %{http_code}\n' -X DELETE "$BASE/$ID"

line "GET eliminado (404)"
curl -s -w '\nHTTP %{http_code}\n' "$BASE/$ID"
