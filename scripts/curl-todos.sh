#!/usr/bin/env bash
set -euo pipefail

# Usage:
#   bash scripts/curl-todos.sh [URL]
# Default URL: http://localhost:8000/todos

URL="${1:-http://localhost:8000/todos}"

echo "GET ${URL}"
echo
curl -sS -D - "${URL}"
echo

