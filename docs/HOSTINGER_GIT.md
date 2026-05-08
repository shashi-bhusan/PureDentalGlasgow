# Alternative: deploy with Hostinger Git (hPanel)

Hostinger can **pull your GitHub repo** into a folder when you push, so you never upload zips by hand. This is separate from **GitHub Actions + FTP** (the method wired in `.github/workflows/`).

## Limitation for *this* repo

Your site files live under **`public/`**, not at the repository root. Many Git panels deploy the **repository root** only. If Hostinger deploys the repo root into `public_html/staging`, visitors would need to open `/public/index.html`, which is wrong.

**Works without restructuring if** hPanel Git lets you set a **source subdirectory** (sometimes called *build path* / *folder to deploy*) to **`public`** — check your Git screen. If that option does **not** exist, prefer **GitHub Actions** (it uploads only `./public/` contents to the correct folder).

## If you use Hostinger Git anyway

1. hPanel → **Websites** → your site → **Git** (Advanced).
2. Repository URL: `https://github.com/shashi-bhusan/PureDentalGlasgow.git`
3. Branch: **`staging`** for the staging subdomain folder, **`main`** for production (or two separate Git entries if Hostinger allows).
4. **Install / target path:** for staging, set to the document root for `staging.puredentalglasgow.com` (e.g. `public_html/staging`).
5. Enable **Auto deployment** → copy the **Webhook URL** → GitHub repo **Settings → Webhooks** → add URL, **Push events** only.

Then each **git push** to the chosen branch triggers a pull on Hostinger.

## Recommendation

- **Fastest to get right with current layout:** [GITHUB_ACTIONS.md](GITHUB_ACTIONS.md) — three secrets, push `staging` / `main`.
- **Native Git:** ideal only if you confirm Hostinger deploys the **`public`** subfolder into the correct web root.

Official reference: [How to deploy a Git repository in Hostinger](https://support.hostinger.com/en/articles/1583302-how-to-deploy-a-git-repository).
