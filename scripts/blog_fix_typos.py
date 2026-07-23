#!/usr/bin/env python3
"""Deterministic KO typo/brand guardrail for ThakiCloud blog posts.

Primary need (2026-07-23): the official Korean brand name is **다키클라우드**, but
many posts wrote **타키클라우드** / **타키 클라우드**. This corrects the brand name and
a small, curated set of safe, unambiguous typos — as a publish-time guardrail so no
post ships with the wrong brand name.

Design (mirrors fix_asset_baseurl.py / blog_fix_canonical.py — format is code-owned):
  - TYPO_MAP is the single source of truth and the extension point. Add pairs here.
  - Korean-only replacements: English "Thaki"/"ThakiCloud" (the correct English name)
    is never touched — we only rewrite Hangul (타키...).
  - Safety guards (do NOT rewrite inside):
      * fenced code blocks ``` / ~~~  and inline `code`  (literal examples / commands)
      * URLs / bare http(s) links                          (identifiers, not prose)
    Brand name in prose/titles/front-matter IS corrected (that is user-facing text).
  - Idempotent: correct text stays correct.

Usage:
  python3 scripts/blog_fix_typos.py --check     # report only; exit 1 if any typo found (GATE)
  python3 scripts/blog_fix_typos.py --apply     # rewrite in place; exit 0
"""
import argparse
import glob
import re
import sys

# ── Typo dictionary (EXTEND HERE) ─────────────────────────────────────────────
# Order matters: longer/spaced variants before the collapsed form so a spaced
# misspelling doesn't get half-corrected. All keys/values are Hangul only.
TYPO_MAP = [
    # Brand name — official Korean form is 다키클라우드 (no space).
    ("타키 클라우드", "다키클라우드"),   # wrong initial + space
    ("타키클라우드", "다키클라우드"),     # wrong initial
    ("다키 클라우드", "다키클라우드"),   # correct name but spaced → normalize
    # ── Add more unambiguous KO corrections below (typo → correct) ──
    ("쿠버네틱스", "쿠버네티스"),         # common k8s misspelling
    ("어플리케이션", "애플리케이션"),     # 외래어 표기법 (standard form)
    ("컨네이너", "컨테이너"),             # dropped syllable
]

# ── Safety: spans that must be preserved verbatim ─────────────────────────────
INLINE_CODE_RE = re.compile(r"`[^`]*`")
URL_RE = re.compile(r"https?://[^\s)\"'<>]+")
FENCE_RE = re.compile(r"^\s*(```|~~~)")


def _protect(line):
    """Replace inline-code and URL spans with placeholders; return (line, restores)."""
    restores = []

    def stash(m):
        restores.append(m.group(0))
        return f"\x00{len(restores) - 1}\x00"

    line = INLINE_CODE_RE.sub(stash, line)
    line = URL_RE.sub(stash, line)
    return line, restores


def _restore(line, restores):
    for i, orig in enumerate(restores):
        line = line.replace(f"\x00{i}\x00", orig)
    return line


def fix_text(text):
    """Return (new_text, n_replacements). Skips fenced code blocks; protects inline code/URLs."""
    out, n = [], 0
    in_fence = False
    for line in text.split("\n"):
        if FENCE_RE.match(line):
            in_fence = not in_fence
            out.append(line)
            continue
        if in_fence:
            out.append(line)
            continue
        protected, restores = _protect(line)
        for bad, good in TYPO_MAP:
            if bad == good:
                continue
            c = protected.count(bad)
            if c:
                protected = protected.replace(bad, good)
                n += c
        out.append(_restore(protected, restores))
    return "\n".join(out), n


def main():
    ap = argparse.ArgumentParser(description="KO brand/typo guardrail for blog posts")
    ap.add_argument("--apply", action="store_true", help="rewrite files in place")
    ap.add_argument("--check", action="store_true", help="report only; exit 1 if typos found")
    ap.add_argument("--paths", nargs="*", help="explicit files (default: _posts + _pages)")
    args = ap.parse_args()

    files = args.paths or (
        glob.glob("_posts/**/*.md", recursive=True)
        + glob.glob("_posts/**/*.html", recursive=True)
        + glob.glob("_pages/**/*.md", recursive=True)
        + glob.glob("_pages/**/*.html", recursive=True)
    )

    total, changed_files, offenders = 0, 0, []
    for path in files:
        try:
            with open(path, encoding="utf-8") as f:
                s = f.read()
        except (OSError, UnicodeDecodeError) as e:
            print(f"SKIP {path}: {e}", file=sys.stderr)
            continue
        new, n = fix_text(s)
        if n:
            total += n
            changed_files += 1
            offenders.append((path, n))
            if args.apply and new != s:
                with open(path, "w", encoding="utf-8") as f:
                    f.write(new)

    mode = "apply" if args.apply else "check"
    print(f"[{mode}] files_with_typos={changed_files} replacements={total} scanned={len(files)}")
    for p, n in offenders[:50]:
        print(f"  {n:>3}  {p}")

    # --check is a GATE: nonzero exit when uncorrected typos remain.
    if args.check and total:
        print("GATE FAIL: brand/typo issues found. Run with --apply to fix.", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
