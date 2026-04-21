#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SRC="${ROOT}/site-mirror/www.puredentalglasgow.com"
DST="${ROOT}/public"
if [[ ! -d "${SRC}" ]]; then
  echo "Missing mirror: ${SRC}. Run: python3 scripts/mirror_site.py" >&2
  exit 1
fi
mkdir -p "${DST}"
rsync -a --delete "${SRC}/" "${DST}/"
echo "Synced mirror -> ${DST}"
