#!/usr/bin/env bash
# Commit (if needed) and push so GitHub Actions deploys public/ to Hostinger — no zip upload.
# Prereq: GitHub repo secrets FTP_SERVER, FTP_USERNAME, FTP_PASSWORD (see docs/GITHUB_ACTIONS.md)
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT"
BRANCH="${1:?Usage: $0 <staging|main> [commit message]}"
MSG="${2:-Update site}"

if [[ "$BRANCH" != "staging" && "$BRANCH" != "main" ]]; then
  echo "Branch must be staging or main" >&2
  exit 1
fi

git checkout "$BRANCH"

if ! git diff --quiet || ! git diff --cached --quiet; then
  git add -A
  git commit -m "$MSG"
fi

git push -u origin "$BRANCH"
echo ""
echo "Deploy: open https://github.com/shashi-bhusan/PureDentalGlasgow/actions"
echo "  → wait for 'Deploy ${BRANCH}' (or 'Deploy manual') to finish."
echo "Staging URL: https://staging.puredentalglasgow.com/"
echo "Production:  https://www.puredentalglasgow.com/"
