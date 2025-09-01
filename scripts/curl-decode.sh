#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/curl-decode.sh [URL]
#
# Sends a POST with a sample JSON body to the /decode endpoint.
# Default URL: http://localhost:8000/decode

URL="${1:-http://localhost:8000/decode}"

JSON='{"message":"hello","count":42}'

echo "POST ${URL}"
echo "Body: ${JSON}"
echo

curl -sS -X POST \
  -H 'Content-Type: application/json' \
  --data "${JSON}" \
  -D - \
  "${URL}"

echo
