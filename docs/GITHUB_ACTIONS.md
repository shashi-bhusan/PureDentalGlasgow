# GitHub Actions → Hostinger (automatic — no zip upload after setup)

Workflows sync **`./public/`** to Hostinger over **FTPS** when you push, or when you run a workflow manually. **Default FTP paths are relative to Hostinger’s usual FTP chroot** (`public_html/staging/` for staging, `public_html/` for production). Override with Variables if your account starts in a different folder — see below.

## Important: **`ETIMEDOUT` on port 21 *and* 990**

If FileZilla from your **own computer** works but GitHub Actions logs show **`connect ETIMEDOUT … :21`** (or `:990`), Hostinger (or a network in between) is often **blocking inbound FTP from cloud / datacenter IP ranges** used by **GitHub-hosted runners**. This is **not** something we can fix in YAML alone.

**Practical options (pick one):**

1. **[Hostinger Git + webhook](HOSTINGER_GIT.md)** — Hostinger’s server **pulls** from GitHub (outbound to `github.com`). FTP is not used from GitHub → Hostinger, so this path usually works when FTP Actions fail.
2. **Self-hosted GitHub Actions runner** (a small PC or VPS that *can* FTP to Hostinger) — same workflow, different runner.
3. **Contact Hostinger support** — ask whether FTP from **GitHub Actions** IP ranges can be allowed, or for **SFTP/SSH deploy** details if your plan includes SSH.
4. **Manual deploy** — zip `public/` and upload in File Manager (reliable fallback).

### Repository **Variables** (optional paths — **not** Secrets)

Secrets only store **FTP_SERVER**, **FTP_USERNAME**, **FTP_PASSWORD**. Path overrides live under **Settings → Secrets and variables → Actions → Variables** (a separate tab from **Secrets**):

| Variable | When to set |
|----------|-------------|
| **`FTP_REMOTE_STAGING`** | Only if defaults fail: path (with trailing `/`) from **FileZilla remote pane** to the folder that contains **`index.html`** for staging. Hostinger often chroots you under `domains/puredentalglasgow.com/`, so the workflow default is **`public_html/staging/`**. If your FTP home is the **account root** (you see a `domains/` folder first), use **`domains/puredentalglasgow.com/public_html/staging/`**. |
| **`FTP_REMOTE_PRODUCTION`** | Same for live site; default **`public_html/`** when chrooted under the domain. |

After each **Deploy staging** run, a **verify** step fetches `https://staging.puredentalglasgow.com/` and **fails the workflow** if the new footer text is missing — so a green run means staging really shows the new footer.

If verify fails with **curl exit 28** (timeout), that is usually **GitHub runner → Hostinger HTTPS** (often **IPv6**); the workflow uses **IPv4 (`curl -4`)** and **retries**. If it still times out, open staging in your browser: if the footer is updated, the deploy worked and only the verify hop failed (re-run or ignore). If the footer is still old, fix **`FTP_REMOTE_STAGING`**.

## Workflows

| Workflow | When it runs |
|----------|----------------|
| **Deploy staging** | Every push to branch **`staging`** |
| **Deploy production** | Every push to branch **`main`** |
| **Deploy manual** | **Actions → Deploy manual → Run workflow** → choose staging or production (uses current branch snapshot) |

Files: `.github/workflows/deploy-staging.yml`, `deploy-production.yml`, `deploy-manual.yml`.

## One-time setup (only 3 secrets)

**GitHub repo → Settings → Secrets and variables → Actions → New repository secret**

| Secret | Where to find it |
|--------|-------------------|
| **`FTP_SERVER`** | hPanel → **FTP Accounts** — hostname only (e.g. `ftp.puredentalglasgow.com`, **no** `ftp://` prefix) |
| **`FTP_USERNAME`** | FTP username (often **not** your hPanel email) |
| **`FTP_PASSWORD`** | FTP password |

**No path secrets.** Defaults (FTP `server-dir`):

- **Staging:** `public_html/staging/`
- **Production:** `public_html/`

If uploads went to the wrong tree before (FTP green but site unchanged), you likely had **`domains/...` duplicated under a domain chroot** — the new defaults fix that for typical Hostinger FTP accounts.

Override with **Variables** `FTP_REMOTE_STAGING` / `FTP_REMOTE_PRODUCTION` if your panel shows a different layout.

## Optional: Repository **Variables** (no secrets — tune FTP mode)

Workflows default to **explicit FTPS on port 21** (`ftps` + `21`), because GitHub-hosted runners often **time out** connecting to **port 990** (implicit FTPS), even when FileZilla works from your PC.

If your Hostinger account **requires** implicit FTPS on 990, set **Variables** (Settings → Secrets and variables → Actions → **Variables**):

| Variable | Value |
|----------|--------|
| **`FTP_PORT`** | `990` |
| **`FTP_PROTOCOL`** | `ftps-legacy` |

If you must use **plain FTP** (insecure; only if Hostinger allows it): `FTP_PORT` = `21`, `FTP_PROTOCOL` = `ftp`.

Leave both variables **unset** to use defaults (**21** + **ftps**).

## Day-to-day (no manual file upload)

```bash
# From repo root — optional helper:
./scripts/deploy-via-git-push.sh staging "Footer update"

# Or manually:
git checkout staging && git push origin staging
```

Then open **Actions** and confirm **Deploy staging** succeeded. Staging URL: `https://staging.puredentalglasgow.com/`

Production (after merging to main):

```bash
./scripts/deploy-via-git-push.sh main "Release"
```

## If the job fails: **`ETIMEDOUT` (control socket) on 21 or 990**

See the section **“ETIMEDOUT on port 21 and 990”** at the top of this page — that is the usual explanation when **both** ports time out from Actions but **FileZilla works from home**.

## If the job fails: **`FTPError: 530 Login incorrect`**

This means **authentication failed** — not the deploy path. The workflow never gets past login.

1. **Use an FTP account from Hostinger, not your hPanel login unless they are the same**  
   hPanel → **Files → FTP Accounts** → open or **Create** an account. Copy the **username** exactly as shown (often `u123456789` or `user@domain` style).

2. **Match the hostname to that account**  
   In the same screen, use the **FTP hostname** Hostinger shows for **that** account (e.g. `ftp.puredentalglasgow.com` or a server-specific host). Put only the host in **`FTP_SERVER`** (no `https://`, no `ftp://`).

3. **Reset the FTP password** in hPanel, then update **`FTP_PASSWORD`** in GitHub Secrets (no leading/trailing spaces when you paste).

4. **Prove it locally**  
   In **FileZilla** (or another FTP client), connect with **the same three values** you put in secrets:  
   - If FileZilla fails → fix Hostinger / password first.  
   - If FileZilla works on **port 21** with “Use explicit FTP over TLS” but Actions use **990** → add repo **Variables** `FTP_PORT`=`21` and `FTP_PROTOCOL`=`ftps` (see table above).

5. **Re-run the workflow** after updating secrets (Actions → failed run → **Re-run all jobs**).

## If the job fails (other FTPS / TLS errors)

See [FTP-Deploy-Action README](https://github.com/SamKirkland/FTP-Deploy-Action). Try repo **Variables** `FTP_PORT` / `FTP_PROTOCOL` (see table above).

The **Node.js 20 deprecation** warning in the log is **not** the cause of `530`; you can ignore it for now.

## Other option: Hostinger Git + webhook

If you prefer Hostinger to `git pull` from GitHub, read **[HOSTINGER_GIT.md](HOSTINGER_GIT.md)** (mind the **`public/`** subfolder).

## Security

- Never commit FTP passwords.
- Revoke/regenerate passwords if leaked.
- Optionally add GitHub **Environments** + required reviewers for production.
