#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
PORT="${PORT:-8765}"
cd "${ROOT}/public"
echo "Serving ${ROOT}/public at http://127.0.0.1:${PORT}/ (Ctrl+C to stop)"
exec python3 -m http.server "${PORT}" --bind 127.0.0.1
