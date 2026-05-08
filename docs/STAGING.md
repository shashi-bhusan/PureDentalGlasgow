# Staging environment (`staging.puredentalglasgow.com`)

Use this host for **QA and client review** before deploying the same build from `main` to production (`www.puredentalglasgow.com`).

## Confirmed in hPanel (this project)

| | |
|---|---|
| **URL** | `https://staging.puredentalglasgow.com` |
| **Document root (server)** | `/home/<your-account>/domains/puredentalglasgow.com/public_html/staging` |

In **File Manager** you often navigate from the account root as:

`domains/puredentalglasgow.com/public_html/staging`

Many **FTP** accounts are **chrooted** under `domains/puredentalglasgow.com/`, so after login you only need:

`public_html/staging`

That is the **default `server-dir`** in **GitHub Actions** for this repo (override with Variable **`FTP_REMOTE_STAGING`** if your FTP home is the full account root — see **[GITHUB_ACTIONS.md](GITHUB_ACTIONS.md)**).

Upload the **contents** of this repo’s **`public/`** folder into that **`staging`** directory (so `index.html` sits directly inside `staging`, not nested in another `public` folder).

## What you need to do in Hostinger (once)

These steps are done in **hPanel** for the Pure Dental Glasgow account. Exact labels can vary slightly.

1. **Subdomain** — Already created for this site:
   - **Subdomain:** `staging.puredentalglasgow.com`
   - **Directory:** `public_html/staging` (under the `puredentalglasgow.com` domain tree)
   - If DNS is not active yet, wait until it shows **Active** in the subdomain list.

2. **Optional: HTTPS**
   - In **SSL**, enable **Let’s Encrypt** (or AutoSSL) for `staging.puredentalglasgow.com`.

3. **Block search engines on staging (recommended)**
   - After you upload the site, copy **`public/robots.staging.txt`** to **`robots.txt`** in the **staging** document root only (see file contents — it disallows all crawlers).
   - Do **not** deploy this `robots.txt` to production; production should keep a normal `robots.txt` / sitemap policy.

## Automatic uploads (no zip)

Add **three** GitHub Secrets (`FTP_SERVER`, `FTP_USERNAME`, `FTP_PASSWORD`) — see **[GITHUB_ACTIONS.md](GITHUB_ACTIONS.md)** — then **`git push origin staging`** deploys `./public/` into this folder automatically.

## Git workflow (this repo)

| Item | Role |
|------|------|
| Git branch **`staging`** | Branch you commit to for pre-production work. |
| Host **`https://staging.puredentalglasgow.com`** | Where you upload **`public/`** for testing. |
| Git branch **`main`** | What you deploy to **production** after staging sign-off. |

Typical flow:

1. Commit and push changes on branch **`staging`**.
2. Build/upload **`public/`** to the **staging** document root on Hostinger (FTP or File Manager zip).
3. Test on **`https://staging.puredentalglasgow.com`**.
4. Merge **`staging` → `main`**, then deploy **`public/`** to **production** `public_html`.

## FTP / upload note

The **remote path** for staging is **not** the same as production `public_html` root. Point uploads at the folder that contains **`staging/index.html`** — from FileZilla’s remote pane after login, that is often **`public_html/staging/`** (chrooted FTP) or **`domains/puredentalglasgow.com/public_html/staging/`** (home-root FTP). See `scripts/deploy-staging.example.sh` — set `FTP_REMOTE_STAGING_DIR` to that path for `lftp`.

## Troubleshooting

### “You Are All Set to Go!” (Hostinger default page)

The subdomain is working, but **no site files are in the staging folder yet** (or only Hostinger defaults). Fix:

1. Open **hPanel → Files → File Manager**.
2. Go to **`domains/puredentalglasgow.com/public_html/staging`** (or the path shown under **Subdomains → Directory**).
3. **Delete** the default `default.php` / placeholder files there if you only want this project (optional).
4. **Upload** a **zip** of everything inside this repo’s **`public/`** folder, then **Extract** so **`index.html`** is directly inside **`staging/`** (same level as `css/`, `js/`, etc.).
5. Reload `https://staging.puredentalglasgow.com`.

Wrong layout (common mistake): uploading a single folder named `public` so the site lives at `/staging/public/index.html`. The home page must be `/staging/index.html`.

## Local testing

- Static preview: `./scripts/serve-local.sh` (`.php` may download — use PHP built-in server if needed; see main `README.md`).
- Staging on Hostinger runs **PHP** like production, so behaviour should match live more closely than local Python.
