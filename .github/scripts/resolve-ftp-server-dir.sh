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
  # hPanel "Directory" is often an absolute path: /home/USER/domains/domain.tld/public_html/...
  # FTP for that same account usually starts at /home/USER/, so strip home/USER/.
  if [[ "$d" =~ ^home/[A-Za-z0-9._-]+/(.+)$ ]]; then
    d="${BASH_REMATCH[1]}"
    echo "::notice::Converted hPanel-style /home/… path to FTP path relative to account root (starts with ${d%%/*}/)." >&2
  fi
  [ -z "$d" ] && return 1
  case "$d" in */) ;; *) d="${d}/" ;; esac
  # Hostinger hPanel File Manager URLs (srv*.hstgr.io) include a virtual "files/" segment; FTPS login cwd usually does not.
  case "$d" in
    files/public_html/*)
      echo "::notice::Removed File-Manager-only prefix \"files/\" from server-dir for FTP." >&2
      d="${d#files/}"
      ;;
  esac
  [ -z "$d" ] && return 1
  # File Manager path is often files/public_html/domains/... but FTP from /home/USER usually starts with domains/ (not public_html/domains/).
  case "$d" in
    public_html/domains/*)
      echo "::notice::Removed leading public_html/ before domains/ (Hostinger FTP account root layout)." >&2
      d="${d#public_html/}"
      ;;
  esac
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
