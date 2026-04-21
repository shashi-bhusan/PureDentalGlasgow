#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
export MIRROR_ROOT="${ROOT}/site-mirror"
echo "Downloading public assets via HTTP (see scripts/mirror_site.py limits)..."
python3 "${ROOT}/scripts/mirror_site.py"
"${ROOT}/scripts/sync_mirror_to_public.sh"
echo "Done. Review changes in public/ then commit."
