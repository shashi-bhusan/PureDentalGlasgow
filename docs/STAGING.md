# Staging environment (`staging.puredentalglasgow.com`)

Use this host for **QA and client review** before deploying the same build from `main` to production (`www.puredentalglasgow.com`).

## Simple checklist (read this first if GitHub shows “OLD footer”)

The workflow is doing what we told it: it uploads your repo’s **`public/`** folder to **one remote folder**. If that folder is **not** the same place Hostinger uses for **`https://staging.puredentalglasgow.com/`**, the deploy step can still be green but the **site stays old**. That is a **path mismatch**, not a random “CI bug”.

Do these in order:

1. **Use the same FTP login as GitHub**  
   In GitHub you have secrets **`FTP_SERVER`**, **`FTP_USERNAME`**, **`FTP_PASSWORD`**. In **FileZilla**, connect with **exactly those** (not a different FTP user, not “main account” if the secret is a sub-account).

2. **Get the path from FileZilla, not from File Manager**  
   After login, open folders on the **right (remote)** side until you see the **`index.html`** that really belongs to staging (you can edit a test file and refresh the site to confirm).  
   Look at the **path / breadcrumb** FileZilla shows for that folder.  
   **Important:** hPanel **File Manager** sometimes shows **`files/public_html/...`**. FTP often **does not** use the same string. If you copied **`files/public_html/staging/`** from the browser/File Manager, try **`public_html/staging/`** instead (no `files/` prefix), **or** whatever FileZilla actually shows after step 1.  
   If the browser address looks like **`https://srvXXXX-files.hstgr.io/…/files/public_html/staging/`**, that host is **only for the file manager in the browser** — your GitHub FTP secrets still use your normal **FTP hostname** from hPanel; **`FTP_REMOTE_STAGING`** should **not** contain `hstgr.io` or the long random segment, only the folder path relative to FTP (usually **`public_html/staging/`**).

3. **Put that path in GitHub (one place only)**  
   - Go to **GitHub → your repo → Settings → Secrets and variables → Actions**.  
   - Open the **Variables** tab. If **`FTP_REMOTE_STAGING`** exists **at all**, it **overrides** the Secret — even an old value. **Delete** the Variable unless you intentionally use Variables instead of Secrets.  
   - Open the **Secrets** tab. Set **`FTP_REMOTE_STAGING`** to the path from step 2 **or** paste hPanel’s full line (e.g. `/home/u123…/domains/puredentalglasgow.com/public_html/staging`) — the deploy script converts **`/home/USER/`** to the correct **FTP-relative** path (`domains/…/public_html/staging/`).  
   - If you set it by hand, many accounts need **`domains/puredentalglasgow.com/public_html/staging/`** (not only `public_html/staging/`). Use **forward slashes** and a trailing **`/`**.

4. **Push `staging` again** (or **Actions → Deploy staging → Run workflow**).  
   When **`verify-staging-footer`** is green, the live page really contains **“Healing Waters”**.

5. **Still failing?** Open the latest **Deploy staging** run → job **`verify-staging-footer`**. If it says **`STAGING_DEPLOY_CHECK.txt` missing**, FTP is **not** writing the folder that serves **`https://staging.puredentalglasgow.com/`** (wrong `FTP_REMOTE_STAGING` for this FTP user). Then open **`ftp-deploy`** → **Diagnostic — FTPS list remote root** and set the path from that listing to your staging folder (e.g. list shows `domains` → `domains/puredentalglasgow.com/public_html/staging/`; only `public_html` at root → `public_html/staging/`).

6. **Still wrong?** In **hPanel → Websites → Domains → Subdomains**, click **`staging.puredentalglasgow.com`** and read **Directory** (e.g. `public_html/staging` or `public_html/staging.puredentalglasgow.com`). That folder **must** be the same as in FileZilla for the user from step 1.

Optional **Hostinger fix** (very reliable): create an **FTP account** whose **home directory** is set to the **staging document root** in hPanel. Then in FileZilla you land **inside** staging already; set GitHub **`FTP_REMOTE_STAGING`** to **`.`** (the workflow turns that into **`./`** for the FTP action).

## Confirmed in hPanel (this project)

| | |
|---|---|
| **URL** | `https://staging.puredentalglasgow.com` |
| **Document root (server)** | `/home/<your-account>/domains/puredentalglasgow.com/public_html/staging` |

In **File Manager** you often navigate from the account root as:

`domains/puredentalglasgow.com/public_html/staging`

Many **FTP** accounts are **chrooted** under `domains/puredentalglasgow.com/`, so after login you only need:

`public_html/staging`

That is the **default `server-dir`** in **GitHub Actions** for this repo (override with repo **Variable** or **Secret** **`FTP_REMOTE_STAGING`** if your FTP home is the full account root — see **[GITHUB_ACTIONS.md](GITHUB_ACTIONS.md)**).

Upload the **contents** of this repo’s **`public/`** folder into that **`staging`** directory (so `index.html` sits directly inside `staging`, not nested in another `public` folder).

## What you need to do in Hostinger (once)

These steps are done in **hPanel** for the Pure Dental Glasgow account. Exact labels can vary slightly.

1. **Subdomain** — Already created for this site:
   - **Subdomain:** `staging.puredentalglasgow.com`
   - **Directory:** whatever **hPanel → Subdomains** shows for this subdomain (often `public_html/staging`, sometimes `public_html/staging.puredentalglasgow.com` or another custom path). **GitHub `FTP_REMOTE_STAGING` must match that folder** (relative to your FTP login root — see **[GITHUB_ACTIONS.md](GITHUB_ACTIONS.md)**).
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
