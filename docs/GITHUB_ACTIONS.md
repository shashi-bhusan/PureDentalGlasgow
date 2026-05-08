# GitHub Actions → Hostinger (automatic — no zip upload after setup)

Workflows sync **`./public/`** to Hostinger over **FTPS** when you push, or when you run a workflow manually. **Remote folders are fixed in YAML** (`domains/puredentalglasgow.com/…`) — you only configure FTP login secrets.

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

**No path secrets.** Staging uploads to:

`domains/puredentalglasgow.com/public_html/staging/`

Production uploads to:

`domains/puredentalglasgow.com/public_html/`

If your FTP user’s home differs, edit **`server-dir`** in the workflow YAML.

## Optional: Repository **Variables** (no secrets — tune FTP mode)

Workflows default to **implicit FTPS** (`protocol: ftps-legacy`, **port 990**), which matches many Hostinger accounts. If deploy still fails, add **Variables** (same Settings page → **Variables** tab):

| Variable | Example when 990 fails | Example when only plain FTP works |
|----------|------------------------|-------------------------------------|
| **`FTP_PORT`** | `21` | `21` |
| **`FTP_PROTOCOL`** | `ftps` (explicit FTPS on 21) | `ftp` |

Leave both variables **unset** to keep defaults (`990` + `ftps-legacy`).

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

## If the job fails (FTPS / login)

See previous steps in this file plus [FTP-Deploy-Action README](https://github.com/SamKirkland/FTP-Deploy-Action). Common fixes:

1. Confirm **FileZilla** works with the same host, user, password.
2. Try **`port: 990`** + **`protocol: ftps-legacy`** in the workflow YAML if implicit FTPS is required.

## Other option: Hostinger Git + webhook

If you prefer Hostinger to `git pull` from GitHub, read **[HOSTINGER_GIT.md](HOSTINGER_GIT.md)** (mind the **`public/`** subfolder).

## Security

- Never commit FTP passwords.
- Revoke/regenerate passwords if leaked.
- Optionally add GitHub **Environments** + required reviewers for production.
