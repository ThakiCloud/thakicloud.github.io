#!/usr/bin/env python3
"""Internal links must carry the baseurl and must point at a post that exists.

WHY THIS EXISTS (2026-08-27)
  A post linked to `/ko/research/harness-continual-learning/`. The site is served under
  /tech-blog, and Jekyll does NOT inject the baseurl into a root-relative markdown link,
  so it resolved to thakicloud.com/ko/... — where CloudFront answers HTTP 200 with the
  corporate landing page. A reader gets the wrong page; every status-code check on earth
  says the link is fine. Same soft-404 blindness as [[published-url-is-a-promise]].

  The same sweep found the other half of the problem: three links pointed at slugs that
  have never existed in _posts at all. Those were invented, and no baseurl fix helps.

CHECKS
  1. `](/ko|/en|/ar/...)`  — root-relative internal link missing the /tech-blog baseurl
  2. `](/tech-blog/<lang>/<cat>/<slug>/)` whose slug has no file under _posts
  3. `https://thakicloud.com/<lang>/...` — absolute link missing the baseurl

  internal_link_check.py [--fix] [paths...]      exit 1 = broken links found
"""
from __future__ import annotations

import re
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
POSTS = ROOT / "_posts"
BASEURL = "/tech-blog"
LANGS = ("ko", "en", "ar")

REL = re.compile(r"\[([^\]]*)\]\(/(ko|en|ar)/([^)/]+)/([^)/]+)/\)")
ABS = re.compile(r"\[([^\]]*)\]\(https?://thakicloud\.com/(ko|en|ar)/([^)/]+)/([^)/]+)/\)")
INTERNAL = re.compile(r"\]\(/tech-blog/(ko|en|ar)/[^)/]+/([^)/]+)/\)")
DATE = re.compile(r"^\d{4}-\d{2}-\d{2}-")


def known_slugs() -> set[str]:
    out = set()
    for p in POSTS.rglob("*.md"):
        out.add(DATE.sub("", p.stem))
        out.add(re.sub(r"-(ko|en|ar)$", "", DATE.sub("", p.stem)))
    return out


def main() -> int:
    fix = "--fix" in sys.argv
    args = [a for a in sys.argv[1:] if not a.startswith("-")]
    files = [Path(a) for a in args] if args else sorted(POSTS.rglob("*.md"))
    slugs = known_slugs()
    problems: list[str] = []
    changed = 0

    for p in files:
        if not p.is_file():
            continue
        t = p.read_text(encoding="utf-8")
        orig = t
        for rx, kind in ((REL, "baseurl 누락(루트상대)"), (ABS, "baseurl 누락(절대)")):
            for m in list(rx.finditer(t)):
                label, lang, cat, slug = m.groups()
                if slug in slugs:
                    if fix:
                        t = t.replace(m.group(0),
                                      f"[{label}]({BASEURL}/{lang}/{cat}/{slug}/)")
                    problems.append(f"{p}: {kind} -> /{lang}/{cat}/{slug}/")
                else:
                    if fix:
                        t = t.replace(m.group(0), label)     # never link a soft-404
                    problems.append(f"{p}: 대상 없음 -> /{lang}/{cat}/{slug}/")
        for m in INTERNAL.finditer(t):
            if m.group(2) not in slugs:
                problems.append(f"{p}: 대상 없음 -> {m.group(0)[2:-1]}")
        if fix and t != orig:
            p.write_text(t, encoding="utf-8")
            changed += 1

    if problems:
        for x in problems:
            print(f"  {x}")
        print(f"internal-link: {len(problems)}건 문제"
              + (f" · {changed}개 파일 수정" if fix else ""))
        return 0 if fix else 1
    print(f"internal-link OK: {len(files)}개 파일, 깨진 내부링크 없음")
    return 0


if __name__ == "__main__":
    sys.exit(main())
