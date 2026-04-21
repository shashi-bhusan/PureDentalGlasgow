# Pure Dental Glasgow

Website project for [Pure Dental Care](https://www.puredentalglasgow.com/).

## Branches

| Branch | Use |
|--------|-----|
| `main` | Production — deploy from here to Hostinger after release. |
| `staging` | Integration and testing — merge to `main` when ready to go live. |

## Project layout

| Path | Purpose |
|------|---------|
| **`public/`** | **Deployable web root** — edit this folder for content and assets. Upload **its contents** to Hostinger **`public_html`** (or sync via FTP; see below). |
| `site-mirror/` | Scratch output from the HTTP mirror script (gitignored). |
| `scripts/mirror_site.py` | Crawls the live site and downloads linked HTML/CSS/JS/images into `site-mirror/`. |
| `scripts/refresh-from-production.sh` | Re-downloads from production, then copies into `public/`. |
| `scripts/sync_mirror_to_public.sh` | Copies `site-mirror/...` → `public/` only. |
| `scripts/serve-local.sh` | Serves `public/` at `http://127.0.0.1:8765/`. |
| `scripts/deploy-hostinger.example.sh` | Example FTP upload with `lftp` (copy to a **local** `deploy-hostinger.sh`, gitignored). |

Read **`public/SOURCE.txt`** for important limits (PHP source, `.htaccess`).

## Workflow: change → test → deploy

1. Work on **`staging`** (or a feature branch off `staging`).
2. Edit files under **`public/`**.
3. Preview locally:

   ```bash
   ./scripts/serve-local.sh
   ```

   Open `http://127.0.0.1:8765/`.

4. Commit and push `staging`, open a PR to `main` if you use reviews.
5. Merge to **`main`**, then deploy **`public/`** to Hostinger (zip upload or FTP).

## Refresh `public/` from the live site

When you want to pull the latest **public HTTP** snapshot from production into `public/`:

```bash
./scripts/refresh-from-production.sh
```

Review diffs, then commit. This does **not** replace a full Hostinger file export (see `public/SOURCE.txt`).

## Full Hostinger backup (recommended once)

For **real PHP sources**, **`.htaccess`**, and server-only files, download **`public_html`** from Hostinger (File Manager → Compress → Download, or FTP). Merge those files into `public/` (or replace mirrored `.php` snapshots with real scripts) so Git matches production.

## Git remote

```bash
git remote -v
# origin  https://github.com/shashi-bhusan/PureDentalGlasgow.git
```

## Push branches

```bash
git push -u origin main
git push -u origin staging
```

Use SSH or HTTPS with a [Personal Access Token](https://github.com/settings/tokens); do not commit tokens.

## Environment template

Copy `.env.example` to `.env` for local FTP tooling (`.env` is gitignored).
