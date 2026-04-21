# Pure Dental Glasgow

Website project for [Pure Dental Care](https://www.puredentalglasgow.com/).

## Branches

| Branch | Use |
|--------|-----|
| `main` | Production — deploy from here to Hostinger **live** site (`www`). |
| `staging` | Pre-production — commit here first; deploy **`public/`** to the **staging subdomain** for testing, then merge to `main`. |

### Staging URL (testing)

Use Hostinger to create **`staging.puredentalglasgow.com`** pointing at a separate folder (not the live `public_html` root). Upload the same **`public/`** build there for QA. Full steps: **[docs/STAGING.md](docs/STAGING.md)**.

After the subdomain exists, test at **`https://staging.puredentalglasgow.com`**. Use **`public/robots.staging.txt`** as **`robots.txt`** on staging only so Google does not index the copy.

## Project layout

| Path | Purpose |
|------|---------|
| **`public/`** | **Deployable web root** — edit this folder for content and assets. Upload **its contents** to Hostinger **`public_html`** (or sync via FTP; see below). |
| `site-mirror/` | Scratch output from the HTTP mirror script (gitignored). |
| `scripts/mirror_site.py` | Crawls the live site and downloads linked HTML/CSS/JS/images into `site-mirror/`. |
| `scripts/refresh-from-production.sh` | Re-downloads from production, then copies into `public/`. |
| `scripts/sync_mirror_to_public.sh` | Copies `site-mirror/...` → `public/` only. |
| `scripts/serve-local.sh` | Serves `public/` at `http://127.0.0.1:8765/`. |
| `scripts/deploy-hostinger.example.sh` | Example FTP upload to **production** `public_html` with `lftp`. |
| `scripts/deploy-staging.example.sh` | Example FTP upload to **staging** document root (see `docs/STAGING.md`). |
| `docs/STAGING.md` | Create **`staging.puredentalglasgow.com`** in Hostinger and deploy workflow. |
| `public/robots.staging.txt` | Template for **`robots.txt` on staging only** (blocks crawlers). |

Read **`public/SOURCE.txt`** for important limits (PHP source, `.htaccess`).

## Automatic deploy (GitHub Actions → Hostinger)

After you add **FTP secrets** once, **`git push`** can upload **`public/`** for you:

- Push to **`staging`** → deploy to **staging** folder on Hostinger.
- Push to **`main`** → deploy to **production** `public_html`.

Setup and troubleshooting: **[docs/GITHUB_ACTIONS.md](docs/GITHUB_ACTIONS.md)**.

You can still deploy manually (zip / File Manager) anytime; Actions are optional.

## Workflow: change → test → deploy

1. Work on **`staging`** (or a feature branch off `staging`).
2. Edit files under **`public/`**.
3. Preview locally:

   ```bash
   ./scripts/serve-local.sh
   ```

   Open `http://127.0.0.1:8765/`.

4. Commit and push **`staging`** (triggers **Deploy staging** if secrets are set). Test **`https://staging.puredentalglasgow.com`** (see `docs/STAGING.md`).
5. Merge **`staging` → `main`**, push **`main`** (triggers **Deploy production** if secrets are set). Or upload **`public/`** manually to Hostinger.

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
