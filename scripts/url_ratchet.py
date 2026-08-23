#!/usr/bin/env python3
"""url_ratchet.py — a published URL is a promise. This gate enforces it.

WHY THIS EXISTS (2026-08-22 incident, and the 2026-08-12 one before it):
  A nightly publish pass ran with STALE policy code on a second machine and set
  `published: false` on 554 posts in one commit. Every one of those was a live URL
  shared on LinkedIn. They became soft-404s (CloudFront serves the corporate landing
  page with HTTP 200, so nothing alarmed). The same class of bug had already been
  fixed once on 2026-08-12 and came back, because the rule lived only in planner
  logic that any machine could run an old copy of.

  Prose rules and date constants (NO_ROLL_FROM) did not hold. This does: the ledger
  is data in the repo, and the check runs in CI where no local machine can be stale.
  Fail-closed — if a live URL would vanish, the deploy is blocked and the old site
  stays up.

CONTRACT
  _data/published_urls.json  ledger: every URL that has ever been deployed.
  _data/retired_urls.json    explicit removals: {"<url>": "<redirect target or ''>"}.
                             The ONLY sanctioned way to take a URL down.

USAGE
  python3 scripts/url_ratchet.py --check    # exit 1 if any ledger URL would disappear
  python3 scripts/url_ratchet.py --update   # append newly published URLs to the ledger
  python3 scripts/url_ratchet.py --seed     # first-time ledger creation from current state
"""
from __future__ import annotations

import json
import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POSTS = ROOT / "_posts"
DATA = ROOT / "_data"
LEDGER = DATA / "published_urls.json"
RETIRED = DATA / "retired_urls.json"
BASEURL = "/tech-blog"
LANGS = ("ko", "en")

FM = re.compile(r"^---\s*$")


def _front_matter(path: Path) -> dict:
    """Minimal front-matter reader: only the keys this gate needs."""
    out: dict = {}
    try:
        lines = path.read_text(encoding="utf-8", errors="replace").split("\n")
    except OSError:
        return out
    if not lines or not FM.match(lines[0]):
        return out
    body, in_cats = [], False
    for line in lines[1:]:
        if FM.match(line):
            break
        body.append(line)
    for line in body:
        if in_cats:
            m = re.match(r"\s+-\s+(\S.*?)\s*$", line)
            if m:
                out.setdefault("categories", []).append(m.group(1).strip("\"'"))
                continue
            in_cats = False
        m = re.match(r"(\w+)\s*:\s*(.*)$", line)
        if not m:
            continue
        key, val = m.group(1), m.group(2).strip()
        if key == "categories":
            if val:
                inline = val.strip("[]")
                out["categories"] = [c.strip().strip("\"'") for c in inline.split(",") if c.strip()]
            else:
                in_cats = True
            continue
        out[key] = val.strip("\"'")
    return out


def _falsey(val: str | None) -> bool:
    return str(val).strip().lower() in ("false", "no", "0")


def _truthy(val: str | None) -> bool:
    return str(val).strip().lower() in ("true", "yes", "1")


def url_for(path: Path, fm: dict) -> str:
    """Resolve the deployed URL exactly as Jekyll does for this site."""
    explicit = fm.get("permalink")
    if explicit:
        return BASEURL + "/" + explicit.strip("/") + "/"
    rel = path.relative_to(POSTS)
    lang = rel.parts[0]
    cats = fm.get("categories") or list(rel.parts[1:-1])
    slug = re.sub(r"^\d{4}-\d{2}-\d{2}-", "", path.stem)
    parts = [lang] + [str(c) for c in cats] + [slug]
    return BASEURL + "/" + "/".join(p.strip("/") for p in parts if p) + "/"


def published_urls() -> set[str]:
    """URLs Jekyll will actually build. Mirrors the build gate in jekyll.yml."""
    urls = set()
    for lang in LANGS:
        for path in sorted((POSTS / lang).rglob("*.md")):
            fm = _front_matter(path)
            if _falsey(fm.get("published", "true")):
                continue
            if _truthy(fm.get("draft")):
                continue
            urls.add(url_for(path, fm))
    return urls


def _load(path: Path, default):
    if not path.exists():
        return default
    return json.loads(path.read_text(encoding="utf-8"))


def _save(path: Path, obj) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(obj, ensure_ascii=False, indent=2, sort_keys=True) + "\n",
                    encoding="utf-8")


def main() -> int:
    mode = sys.argv[1] if len(sys.argv) > 1 else "--check"
    live = published_urls()
    ledger = set(_load(LEDGER, []))
    retired = _load(RETIRED, {})

    if mode == "--seed":
        _save(LEDGER, sorted(live))
        if not RETIRED.exists():
            _save(RETIRED, {})
        print(f"SEEDED ledger with {len(live)} URLs -> {LEDGER.relative_to(ROOT)}")
        return 0

    missing = sorted(u for u in ledger if u not in live and u not in retired)

    if mode == "--update":
        added = sorted(live - ledger)
        if missing:
            print(f"REFUSING to update: {len(missing)} live URLs would disappear. "
                  f"Run --check to see them.")
            return 1
        _save(LEDGER, sorted(ledger | live))
        print(f"ledger: +{len(added)} new URLs (total {len(ledger | live)})")
        return 0

    # --check
    print(f"url-ratchet: {len(live)} published, {len(ledger)} in ledger, "
          f"{len(retired)} explicitly retired")
    if not missing:
        print("OK: no previously published URL disappears.")
        return 0

    print(f"\n⛔ BLOCKED: {len(missing)} previously published URL(s) would 404.\n")
    for u in missing[:40]:
        print("   ", u)
    if len(missing) > 40:
        print(f"    ... and {len(missing) - 40} more")
    print("\nA published URL is a promise — it is linked from LinkedIn, search, and chats.")
    print("To take one down deliberately, add it to _data/retired_urls.json with a")
    print("redirect target (or \"\" for a hard removal). Never by flipping published:false.")
    return 1


if __name__ == "__main__":
    sys.exit(main())
