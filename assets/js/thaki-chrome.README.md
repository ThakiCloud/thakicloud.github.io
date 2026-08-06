# thaki-chrome.js — shared site navbar (generated)

`thaki-chrome.js` is the **real thakicloud.com website navbar**, built from the
homepage source and dropped in here so the blog's standalone `/tech-blog/*` pages
render a **pixel-identical** header (see `_layouts/default.html`).

- It mounts the homepage `Navbar` into `#thaki-nav` inside a Shadow DOM (style
  isolation), with links pointing to `https://thakicloud.com/...`.
- Loaded only when the blog is opened directly (skipped inside the homepage
  iframe shell — see the guard in `_layouts/default.html`).

## This file is generated — do not hand-edit

Regenerate it from the homepage repo when the navbar changes:

```bash
# in the thaki-homepage repo
npm run build:embed          # -> dist-embed/thaki-chrome.js
cp dist-embed/thaki-chrome.js <this-repo>/assets/js/thaki-chrome.js
```

Source: `thaki-homepage` → `src/embed/chrome.tsx` (+ `router-shim.tsx`,
`vite.embed.config.ts`). The navbar rarely changes, so this snapshot approach
keeps the blog self-contained (no runtime dependency on a homepage deploy).
