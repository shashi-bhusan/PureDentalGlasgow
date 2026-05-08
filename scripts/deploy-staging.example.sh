#!/usr/bin/env bash
# Example: upload public/ to Hostinger STAGING document root (not production public_html).
# Copy to deploy-staging.sh locally, fill FTP_*, run from repo root. Do not commit secrets.
#
# Staging document root (hPanel → Subdomains → Directory). Use the path FileZilla shows
# after login (trailing slash optional for lftp mirror target):
#   public_html/staging          — typical when FTP is chrooted under the domain
#   domains/.../public_html/staging — if FTP home is the account root
# Full server path on disk: /home/<account>/domains/puredentalglasgow.com/public_html/staging
#
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
: "${FTP_HOST:?}" "${FTP_USER:?}" "${FTP_PASS:?}"
REMOTE="${FTP_REMOTE_STAGING_DIR:?}"
lftp -u "${FTP_USER},${FTP_PASS}" "${FTP_HOST}" -e "set ssl:verify-certificate no; mirror -R --delete --verbose ${ROOT}/public ${REMOTE}; bye"
