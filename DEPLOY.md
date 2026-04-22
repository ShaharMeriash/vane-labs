# Deploying Vane Labs

Target stack: **GitHub → Netlify → Porkbun DNS**.

Repo: https://github.com/ShaharMeriash/vane-labs
Domain: vane-labs.com (registered at Porkbun)

---

## Step 1 — Push this folder to GitHub

Open a terminal (PowerShell, Windows Terminal, or Git Bash) and `cd` into this folder. Run:

```powershell
git init
git branch -M main
git remote add origin https://github.com/ShaharMeriash/vane-labs.git
git add .
git commit -m "Initial site: one-pager"
git push -u origin main
```

If the GitHub repo already has commits (a README, LICENSE, etc.) and you want to preserve them, instead do:

```powershell
git init
git remote add origin https://github.com/ShaharMeriash/vane-labs.git
git fetch origin
git checkout -b main origin/main        # pulls whatever is on main
git add .
git commit -m "Add site files"
git push origin main
```

If the repo is empty on GitHub, the first block is the right one.

You'll be prompted for GitHub auth on push. Easiest option: use a **Personal Access Token** (GitHub → Settings → Developer settings → Personal access tokens → Generate). Paste the token as your password at the prompt.

## Step 2 — Connect the repo to Netlify

1. Go to [app.netlify.com](https://app.netlify.com) and sign in (sign up with GitHub if new).
2. Click **Add new site → Import an existing project → GitHub**.
3. Authorize Netlify to access your GitHub account, then pick **ShaharMeriash/vane-labs**.
4. When asked for build settings:
   - **Branch:** `main`
   - **Build command:** *(leave empty)*
   - **Publish directory:** `.` (just a dot, meaning repo root)
5. Click **Deploy**. First build takes ~15 seconds. You'll get a preview URL like `https://radiant-kelpie-abc123.netlify.app`.

The `netlify.toml` in the repo already sets the publish dir and security headers, so those are fine on autopilot.

## Step 3 — Add vane-labs.com as a custom domain in Netlify

1. In your Netlify site dashboard, click **Domain settings → Add a domain**.
2. Enter `vane-labs.com` (the apex). Netlify will confirm you own it (automatic if DNS is already pointing there; otherwise it'll show you the next step).
3. Netlify will also suggest adding `www.vane-labs.com` as a domain alias. Accept — we want both to resolve, with www redirecting to apex.
4. Under **HTTPS**, click **Verify DNS configuration**, then **Provision certificate** (Let's Encrypt, free). Once DNS is set in step 4 below, this will succeed.

Netlify's default setup will have you choose between:
- **Option A** — using Netlify DNS (move nameservers to Netlify). Simplest, but replaces Porkbun DNS.
- **Option B** — keeping Porkbun DNS (what you want). Netlify shows you the exact records to add at Porkbun.

Pick **Option B** to stay with Porkbun.

## Step 4 — DNS records at Porkbun

Go to [porkbun.com](https://porkbun.com) → **Domain management** → **vane-labs.com** → **DNS Records**.

Delete any existing A / CNAME records on `@` and `www` (Porkbun's default parking records), then add:

| Type  | Host  | Answer                             | TTL  |
|-------|-------|------------------------------------|------|
| ALIAS | `@`   | `apex-loadbalancer.netlify.com`    | 600  |
| CNAME | `www` | `<your-site>.netlify.app`          | 600  |

Replace `<your-site>.netlify.app` with the subdomain Netlify assigned in step 2 (visible on your Netlify site dashboard).

Porkbun supports **ALIAS** records natively — use ALIAS for the apex, not A. It gives you the same effect as a CNAME at the apex, which is what Netlify recommends for automatic failover.

If for any reason you can't use ALIAS, fall back to an A record pointing to Netlify's load balancer IP — but Netlify's exact IPs can change, so grab the current one from the Netlify dashboard's "DNS configuration" screen instead of hardcoding.

DNS propagation is usually a few minutes on Porkbun.

## Step 5 — Verify

Once DNS propagates:

- https://vane-labs.com loads the site
- https://www.vane-labs.com redirects to https://vane-labs.com (Netlify handles this automatically when apex is set as primary)
- Netlify provisions the SSL certificate within ~1 minute

Test redirect and cert with:

```powershell
curl -I https://www.vane-labs.com
curl -I https://vane-labs.com
```

You should see `HTTP/2 301` for www and `HTTP/2 200` for apex.

---

## Making future changes

Edit files, then:

```powershell
git add .
git commit -m "description of change"
git push
```

Netlify auto-rebuilds on every push to `main`. Deploy takes ~15 seconds.
