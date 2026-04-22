# Vane Labs

One-page site for [vane-labs.com](https://vane-labs.com) — a small ad-tech practice.

## Stack

Plain static site, no build step. Everything is inlined into `index.html`:

- Markup, styles, and a tiny inline script
- Google Fonts (Rajdhani, Inter) loaded via CDN
- Logo embedded as a base64 PNG data URI inside the HTML

A standalone copy of the logo lives at `assets/logo.png` for reference.

## Deploy

Hosted on [Netlify](https://www.netlify.com), sourced from this GitHub repo. Every push to `main` triggers a rebuild.

Domain `vane-labs.com` is registered at [Porkbun](https://porkbun.com) with DNS pointing at Netlify.

## Local preview

Just open `index.html` in a browser. No server needed.
