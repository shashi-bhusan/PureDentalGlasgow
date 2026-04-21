#!/usr/bin/env bash
# Copy to deploy-hostinger.sh (gitignored) and fill in credentials, or use Hostinger File Manager:
#   Zip the contents of public/ and upload/extract into public_html.
#
# Optional: lftp mirror (install lftp). Uses env vars — do not commit real values.
#
#   export FTP_HOST=ftp.example.com
#   export FTP_USER=your_user
#   export FTP_PASS=your_pass
#   export FTP_REMOTE_DIR=/domains/example.com/public_html
#
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
: "${FTP_HOST:?}" "${FTP_USER:?}" "${FTP_PASS:?}"
REMOTE="${FTP_REMOTE_DIR:-/public_html}"
lftp -u "${FTP_USER},${FTP_PASS}" "${FTP_HOST}" -e "set ssl:verify-certificate no; mirror -R --delete --verbose ${ROOT}/public ${REMOTE}; bye"
