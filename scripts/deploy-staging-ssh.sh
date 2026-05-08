#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"

SSH_USER="u972471760"
SSH_HOST="puredentalglasgow.com"
SSH_PORT="65002"
SSH_KEY="$HOME/.ssh/hostinger_staging_deploy"
REMOTE_PATH="/home/u972471760/domains/puredentalglasgow.com/public_html/staging/"

if [ ! -f "$SSH_KEY" ]; then
  echo "ERROR: SSH key not found at $SSH_KEY"
  echo "Run: ssh-keygen -t ed25519 -f $SSH_KEY -N ''"
  exit 1
fi

echo "Deploying ${ROOT}/public/ → ${SSH_USER}@${SSH_HOST}:${REMOTE_PATH}"
echo "Using SSH on port ${SSH_PORT}..."

rsync -avz --delete \
  -e "ssh -i ${SSH_KEY} -o IdentitiesOnly=yes -o StrictHostKeyChecking=accept-new -p ${SSH_PORT}" \
  "${ROOT}/public/" \
  "${SSH_USER}@${SSH_HOST}:${REMOTE_PATH}"

echo ""
echo "Done! Check: https://staging.puredentalglasgow.com/"
