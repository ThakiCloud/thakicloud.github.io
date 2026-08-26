#!/usr/bin/env python3
"""No stray foreign scripts in what we actually ship.

WHY (2026-08-27)
  Two separate leaks reached readers, and neither was visible in a post:

  1. Arabic. `ar` was retired 2026-07-27 and the 558 ar posts were excluded from the
     build — but the brand metadata still carried `ثاكي كلاود` and a full Arabic sentence,
     so EVERY page shipped 122 Arabic characters in its keywords meta and every shared
     link previewed with Arabic in the description.
  2. Cyrillic. A ko tutorial read "보상이 откуда 나오느냐는" — the drafting model
     code-switched mid-sentence and no gate looked.

  Checking the source tree is not enough: the Arabic came from _config.yml and _includes,
  not from _posts. This checks the BUILT SITE, which is the only thing readers see.

INTENT vs LEAK
  Some foreign script is the content. The "thank you in 7 languages" comic prints
  СПАСИБО and شكرا on purpose, and a blanket sweep would gut it. Those pages are listed
  in ALLOW, by slug, so the exception is explicit and reviewable rather than a threshold.

  script_purity_check.py [_site]        exit 1 = a leak shipped
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPTS = {
    "Arabic": re.compile(r"[؀-ۿݐ-ݿ]"),
    "Cyrillic": re.compile(r"[Ѐ-ӿ]"),
    "Kana": re.compile(r"[぀-ゟ゠-ヿ]"),
}
# Pages whose foreign script IS the content. Slug substrings, deliberately narrow.
ALLOW = ("thank-you-in-7-languages",)
# Chrome that ships on every page and legitimately names other languages.
ALLOW_SNIPPET = re.compile(r"hreflang|lang=\"ar\"|/ar/")


def offenders(html: str) -> dict[str, int]:
    out = {}
    for name, rx in SCRIPTS.items():
        hits = [m for m in rx.finditer(html)
                if not ALLOW_SNIPPET.search(html[max(0, m.start() - 120):m.start() + 40])]
        if hits:
            out[name] = len(hits)
    return out


def main() -> int:
    site = Path(sys.argv[1]) if len(sys.argv) > 1 else ROOT / "_site"
    if not site.is_dir():
        print(f"script-purity: {site} 없음 — 건너뜀")
        return 0
    bad: list[str] = []
    checked = 0
    for f in site.rglob("*.html"):
        rel = str(f.relative_to(site))
        if any(a in rel for a in ALLOW):
            continue
        checked += 1
        found = offenders(f.read_text(encoding="utf-8", errors="replace"))
        if found:
            bad.append(f"{rel}: " + ", ".join(f"{k} {v}자" for k, v in found.items()))
    if bad:
        for b in bad[:25]:
            print(f"  {b}")
        if len(bad) > 25:
            print(f"  … 외 {len(bad) - 25}건")
        print(f"script-purity FAIL: {len(bad)}/{checked} 페이지에 이질 문자")
        return 1
    print(f"script-purity OK: {checked} 페이지, 이질 문자 없음")
    return 0


if __name__ == "__main__":
    sys.exit(main())
