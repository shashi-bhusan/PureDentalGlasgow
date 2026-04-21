#!/usr/bin/env python3
"""
Best-effort public HTTP mirror of the dental site (static assets + rendered HTML).
Server-side PHP source is NOT available over HTTP — use Hostinger FTP/File Manager for .php files.
"""
from __future__ import annotations

import os
import re
import sys
import time
import urllib.error
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from queue import Queue
from typing import Iterable

BASE_NETLOCS = {"www.puredentalglasgow.com", "puredentalglasgow.com"}
BASE_SCHEME = "https"
DEFAULT_ROOT = os.path.join(os.path.dirname(__file__), "..", "site-mirror")
USER_AGENT = "PureDentalGlasgow-local-mirror/1.0 (+local dev)"
REQUEST_DELAY_SEC = 0.35
MAX_ATTEMPTS = 5000

# Extra seeds (fix known bad casing in public HTML, e.g. appointment.php vs Appointment.php)
EXTRA_SEEDS = (
    "https://www.puredentalglasgow.com/Appointment.php",
    "https://www.puredentalglasgow.com/sitemap.xml",
)

CSS_URL_RE = re.compile(
    r"""url\s*\(\s*['"]?([^'")]+)['"]?\s*\)""",
    re.IGNORECASE,
)
CSS_IMPORT_RE = re.compile(
    r"""@import\s+(?:url\s*\(\s*)?['"]?([^'");]+)['"]?\s*\)?""",
    re.IGNORECASE,
)


def _norm_url(url: str) -> str | None:
    try:
        p = urllib.parse.urlsplit(url)
    except ValueError:
        return None
    if p.scheme not in ("http", "https"):
        return None
    host = (p.hostname or "").lower()
    if host not in BASE_NETLOCS:
        return None
    # Drop fragment; keep query (pages differ by query)
    path = p.path or "/"
    if not path.startswith("/"):
        path = "/" + path
    return urllib.parse.urlunsplit((BASE_SCHEME, "www.puredentalglasgow.com", path, p.query, ""))


class _LinkParser(HTMLParser):
    def __init__(self) -> None:
        super().__init__()
        self.links: list[str] = []

    def handle_starttag(self, tag: str, attrs: list[tuple[str, str | None]]) -> None:
        a = dict(attrs)
        for key in ("href", "src", "data-src", "data-href"):
            v = a.get(key)
            if v and not v.startswith(("#", "mailto:", "tel:", "javascript:")):
                self.links.append(v)


def _extract_css_refs(css: str, base: str) -> Iterable[str]:
    out: list[str] = []
    for rx in (CSS_URL_RE, CSS_IMPORT_RE):
        for m in rx.finditer(css):
            raw = m.group(1).strip()
            if raw.startswith(("data:", "#", "http://fonts", "https://fonts")):
                continue
            joined = urllib.parse.urljoin(base, raw)
            nu = _norm_url(joined)
            if nu:
                out.append(nu)
    return out


def _extract_links(html: str, base: str) -> Iterable[str]:
    parser = _LinkParser()
    try:
        parser.feed(html)
    except Exception:
        return []
    out: list[str] = []
    for raw in parser.links:
        joined = urllib.parse.urljoin(base, raw)
        nu = _norm_url(joined)
        if nu:
            out.append(nu)
    return out


def _local_path(root: str, url: str) -> str:
    p = urllib.parse.urlsplit(url)
    path = p.path or "/"
    if path.endswith("/"):
        path = path + "index.html"
    # query string → suffix to avoid collisions
    if p.query:
        safe = re.sub(r"[^a-zA-Z0-9._-]+", "_", p.query)
        if safe:
            base, ext = os.path.splitext(path)
            if not ext:
                ext = ".html"
            path = f"{base}__q_{safe}{ext}"
    full = os.path.join(root, "www.puredentalglasgow.com", path.lstrip("/"))
    d = os.path.dirname(full)
    os.makedirs(d, exist_ok=True)
    return full


def _fetch(url: str) -> tuple[bytes, str | None, str]:
    req = urllib.request.Request(
        url,
        headers={"User-Agent": USER_AGENT, "Accept": "*/*"},
        method="GET",
    )
    with urllib.request.urlopen(req, timeout=60) as resp:
        data = resp.read()
        ctype = resp.headers.get("Content-Type")
        final = resp.geturl()
        return data, ctype, final


def _file_path_to_base_url(root: str, file_path: str) -> str | None:
    site_root = os.path.join(root, "www.puredentalglasgow.com")
    try:
        rel = os.path.relpath(file_path, site_root)
    except ValueError:
        return None
    if rel.startswith(".."):
        return None
    rel_url = rel.replace(os.sep, "/")
    return f"{BASE_SCHEME}://www.puredentalglasgow.com/{rel_url}"


def _harvest_local_assets(root: str) -> list[str]:
    """Find url(...) references inside mirrored CSS on disk."""
    site_root = os.path.join(root, "www.puredentalglasgow.com")
    if not os.path.isdir(site_root):
        return []
    found: list[str] = []
    for dirpath, _, files in os.walk(site_root):
        for fn in files:
            if not fn.endswith(".css"):
                continue
            fp = os.path.join(dirpath, fn)
            try:
                text = open(fp, encoding="utf-8", errors="replace").read()
            except OSError:
                continue
            base = _file_path_to_base_url(root, fp)
            if not base:
                continue
            found.extend(_extract_css_refs(text, base))
    return found


def main() -> int:
    root = os.path.abspath(os.environ.get("MIRROR_ROOT", DEFAULT_ROOT))
    os.makedirs(root, exist_ok=True)
    seen: set[str] = set()
    q: Queue[str] = Queue()
    for s in (f"{BASE_SCHEME}://www.puredentalglasgow.com/", *EXTRA_SEEDS):
        nu = _norm_url(s)
        if nu:
            if nu not in seen:
                seen.add(nu)
                q.put(nu)

    # Seed from sitemap if present
    sm = f"{BASE_SCHEME}://www.puredentalglasgow.com/sitemap.xml"
    try:
        xml, _, _ = _fetch(sm)
        for m in re.finditer(rb"<loc>\s*([^<]+)\s*</loc>", xml, re.I):
            loc = m.group(1).decode("utf-8", errors="replace").strip()
            nu = _norm_url(loc)
            if nu and nu not in seen:
                seen.add(nu)
                q.put(nu)
    except Exception as e:
        print(f"sitemap: skip ({e})", file=sys.stderr)

    saved = 0
    errors = 0
    attempts = 0

    while True:
        while not q.empty() and attempts < MAX_ATTEMPTS:
            url = q.get()
            attempts += 1
            path = _local_path(root, url)
            if os.path.isfile(path):
                continue
            try:
                time.sleep(REQUEST_DELAY_SEC)
                data, ctype, final = _fetch(url)
            except urllib.error.HTTPError as e:
                print(f"ERR {e.code} {url}", file=sys.stderr)
                errors += 1
                continue
            except Exception as e:
                print(f"ERR {url} :: {e}", file=sys.stderr)
                errors += 1
                continue

            with open(path, "wb") as f:
                f.write(data)
            saved += 1
            print(f"OK {saved} {url} -> {path}")

            base_for_links = final or url
            if ctype and "html" in ctype.lower():
                try:
                    text = data.decode("utf-8", errors="replace")
                except Exception:
                    text = ""
                if text:
                    for link in _extract_links(text, base_for_links):
                        if link not in seen:
                            seen.add(link)
                            q.put(link)
            if ctype and "css" in ctype.lower():
                try:
                    ctext = data.decode("utf-8", errors="replace")
                except Exception:
                    ctext = ""
                if ctext:
                    for link in _extract_css_refs(ctext, base_for_links):
                        if link not in seen:
                            seen.add(link)
                            q.put(link)

        added = False
        for link in _harvest_local_assets(root):
            if link not in seen:
                seen.add(link)
                q.put(link)
                added = True
        if not added or attempts >= MAX_ATTEMPTS:
            break

    print(f"Done. saved={saved} attempts={attempts} errors={errors} root={root}")
    if errors:
        print(
            "Some URLs returned errors (often 404 for legacy links). "
            "PHP source is only available via Hostinger files/FTP.",
            file=sys.stderr,
        )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
