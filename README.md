# Pure Dental Glasgow

Website project for [Pure Dental Care](https://www.puredentalglasgow.com/).

## Branches

| Branch | Use |
|--------|-----|
| `main` | Production — matches what is deployed live (e.g. Hostinger). |
| `staging` | Testing — integrate and verify changes here before merging to `main`. |

## Repository contents

- `scripts/mirror_site.py` — optional HTTP mirror of the public site for local preview (output goes to `site-mirror/`, which is not committed).
- The live PHP application and full `public_html` backup should be added from Hostinger (FTP / File Manager) when you are ready to version that code.

## Git remotes

```bash
git remote -v
# origin  https://github.com/shashi-bhusan/PureDentalGlasgow.git
```

## Push from your machine

Automated environments may not have GitHub credentials. After committing locally:

```bash
git push -u origin main
git push -u origin staging
```

Use a [Personal Access Token](https://github.com/settings/tokens) for HTTPS, or configure SSH (`git@github.com:shashi-bhusan/PureDentalGlasgow.git`).

## Local preview of HTTP mirror

```bash
cd site-mirror/www.puredentalglasgow.com
python3 -m http.server 8765 --bind 127.0.0.1
```

Open `http://127.0.0.1:8765/`.
