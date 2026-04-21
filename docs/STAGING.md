# Staging environment (`staging.puredentalglasgow.com`)

Use this host for **QA and client review** before deploying the same build from `main` to production (`www.puredentalglasgow.com`).

## What you need to do in Hostinger (once)

These steps are done in **hPanel** for the Pure Dental Glasgow account. Exact labels can vary slightly.

1. **Create a subdomain**
   - Open **Domains** → **Subdomains** (or **Websites** → **Subdomains**).
   - **Subdomain:** `staging`
   - **Domain:** `puredentalglasgow.com`
   - **Document root:** choose or create a dedicated folder, for example:
     - `public_html/staging`  
     or  
     - `staging.puredentalglasgow.com` (Hostinger sometimes suggests a folder matching the subdomain).
   - Save and wait until DNS shows **Active** (often a few minutes).

2. **Optional: HTTPS**
   - In **SSL**, enable **Let’s Encrypt** (or AutoSSL) for `staging.puredentalglasgow.com`.

3. **Block search engines on staging (recommended)**
   - After you upload the site, copy **`public/robots.staging.txt`** to **`robots.txt`** in the **staging** document root only (see file contents — it disallows all crawlers).
   - Do **not** deploy this `robots.txt` to production; production should keep a normal `robots.txt` / sitemap policy.

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

The **remote path** for staging is **not** the same as production `public_html` root. Set your FTP client or `lftp` script to the folder you chose in step 1 (e.g. `.../public_html/staging`). See `scripts/deploy-staging.example.sh`.

## Local testing

- Static preview: `./scripts/serve-local.sh` (`.php` may download — use PHP built-in server if needed; see main `README.md`).
- Staging on Hostinger runs **PHP** like production, so behaviour should match live more closely than local Python.
