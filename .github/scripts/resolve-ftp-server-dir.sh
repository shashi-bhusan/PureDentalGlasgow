#!/usr/bin/env bash
# Used by deploy workflows. Writes normalized server-dir to GITHUB_OUTPUT (key: dir).
# Args: $1 = staging|production
set -euo pipefail

trim() {
  local s="${1:-}"
  s="${s//$'\r'/}"
  s="${s#"${s%%[![:space:]]*}"}"
  s="${s%"${s##*[![:space:]]}"}"
  printf '%s' "$s"
}

normalize_path() {
  local d
  d="$(trim "${1:-}")"
  [ -z "$d" ] && return 1
  # FTP account chrooted to staging document root → use current dir
  case "$d" in .|./) printf '%s' './'; return 0 ;; esac
  # Relative to FTP login root (Hostinger)
  while [[ "$d" == .//* ]] || [[ "$d" == . ]]; do d="${d#./}"; done
  d="${d#/}"
  [ -z "$d" ] && return 1
  case "$d" in */) ;; *) d="${d}/" ;; esac
  printf '%s' "$d"
}

target="${1:?staging or production}"

if [ "$target" = "staging" ]; then
  v_raw="${FTP_REMOTE_STAGING_VAR:-}"
  s_raw="${FTP_REMOTE_STAGING_SECRET:-}"
  default="public_html/staging/"
  var_name="FTP_REMOTE_STAGING"
else
  v_raw="${FTP_REMOTE_PRODUCTION_VAR:-}"
  s_raw="${FTP_REMOTE_PRODUCTION_SECRET:-}"
  default="public_html/"
  var_name="FTP_REMOTE_PRODUCTION"
fi

v="$(trim "$v_raw")"
s="$(trim "$s_raw")"

if [ -n "$v" ]; then
  echo "::notice::Using repository Variable ${var_name} (check this path in hPanel → Subdomains → Directory if deploy still wrong)."
  d="$(normalize_path "$v")" || { echo "::error::${var_name} Variable is blank after trim."; exit 1; }
  echo "dir=$d" >>"$GITHUB_OUTPUT"
  echo "source=variable" >>"$GITHUB_OUTPUT"
  echo "Effective server-dir: $d"
elif [ -n "$s" ]; then
  echo "::notice::Using repository Secret ${var_name} (path not printed; confirm value matches hPanel Subdomains → Directory, trailing /)."
  d="$(normalize_path "$s")" || { echo "::error::${var_name} Secret is blank after trim."; exit 1; }
  echo "dir=$d" >>"$GITHUB_OUTPUT"
  echo "source=secret" >>"$GITHUB_OUTPUT"
  echo "Effective server-dir length=${#d} chars."
else
  echo "::notice::${var_name} not set — using default ${default}"
  d="$default"
  echo "dir=$d" >>"$GITHUB_OUTPUT"
  echo "source=default" >>"$GITHUB_OUTPUT"
  echo "Effective server-dir: $d"
fi

# hPanel File Manager often shows paths starting with files/ — FTP may use a different tree for the same account.
case "$d" in *files/*)
  echo "::warning::Your FTP path contains 'files/'. That string often comes from **File Manager**, not from **FileZilla**. Open FileZilla with the **same** FTP user as GitHub, go to the folder that contains staging **index.html**, and set FTP_REMOTE_STAGING to **that** path (see docs/STAGING.md → Simple checklist)."
  ;;
esac
