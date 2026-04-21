# GitHub Actions → Hostinger (automatic deploy)

Pushing **`staging`** or **`main`** can upload **`public/`** to Hostinger over **FTPS** so you do not need to zip/upload by hand each time.

## Workflows

| Workflow | When it runs | Target (secret) |
|----------|----------------|-----------------|
| **Deploy staging** | Push to `staging`, or **Actions → Deploy staging → Run workflow** | `FTP_REMOTE_STAGING` |
| **Deploy production** | Push to `main`, or manual run | `FTP_REMOTE_PRODUCTION` |

Files: `.github/workflows/deploy-staging.yml`, `.github/workflows/deploy-production.yml`.

## One-time setup: GitHub Secrets

In the repo: **Settings → Secrets and variables → Actions → New repository secret**.

| Secret | Example / notes |
|--------|------------------|
| **`FTP_SERVER`** | From hPanel **Files → FTP Accounts** (e.g. `ftp.puredentalglasgow.com` or the hostname shown there). |
| **`FTP_USERNAME`** | FTP user (often **not** the same as hPanel login). |
| **`FTP_PASSWORD`** | That FTP account’s password. |
| **`FTP_REMOTE_STAGING`** | Remote folder **relative to FTP home**, with trailing slash. For this project: `domains/puredentalglasgow.com/public_html/staging/` |
| **`FTP_REMOTE_PRODUCTION`** | Production web root, trailing slash: `domains/puredentalglasgow.com/public_html/` |

**Finding `server-dir`:** connect with **FileZilla** (or Hostinger’s online FTP). The path you see to `staging` after login is what should go in the secret (Hostinger usually starts at `/home/...` in full paths, but FTP often drops you in the home folder where paths begin with `domains/`).

## If the job fails (FTPS / login)

1. Confirm the same host, user, and password work in **FileZilla**.
2. In FileZilla, note whether the host uses **explicit FTPS on port 21** or **implicit on 990**.
3. If you use **port 990** and implicit FTPS, edit the workflow YAML: set `port: 990` and `protocol: ftps-legacy` (see [FTP-Deploy-Action README](https://github.com/SamKirkland/FTP-Deploy-Action)).
4. **530 Login incorrect:** wrong FTP user/password or wrong server hostname (use the value from **FTP Accounts**, not generic hPanel login).

## Day-to-day commands

```bash
# Staging: commit + push → Action deploys public/ to staging subdomain
git checkout staging
git add public/ && git commit -m "Update copy" && git push origin staging

# Production: merge to main + push → Action deploys to live public_html
git checkout main && git merge staging
git push origin main
```

## Security

- Never commit FTP passwords or put them in workflow YAML.
- Revoke/regenerate the FTP password if it was ever exposed.
- Optional: restrict **Deploy production** to **GitHub Environments** with required reviewers (Settings → Environments → `production`).
