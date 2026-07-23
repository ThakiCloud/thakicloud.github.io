#!/usr/bin/env python3
"""Rewrite root-absolute /assets/ body references to baseurl-aware relative_url.

Why: blog moved from thakicloud.github.io/ (root) to thakicloud.com/tech-blog/
(Jekyll baseurl=/tech-blog). Front-matter fields (image/teaser/header/audiobook)
already get baseurl via the theme's `relative_url`. But BODY references written as
`![alt](/assets/..)` or raw `<img src="/assets/..">` are site-absolute and resolve
to thakicloud.com/assets/.. (root) -> CloudFront 404 fallback -> main homepage HTML
served in the <img> slot -> broken image.

Fix: rewrite body refs to `{{ '/assets/..' | relative_url }}` so Jekyll prepends
baseurl. DRY (baseurl stays single-source in _config.yml), survives future baseurl
changes, and idempotent (already-converted `]({{ ..` won't re-match).

Scope guards (do NOT touch):
  - YAML front matter block (theme handles those fields)
  - fenced code blocks ``` / ~~~ and inline `code` (literal example paths)
  - already-baseurl'd `/tech-blog/assets/` and Liquid `{{ .. | relative_url }}`

Usage:
  python3 scripts/fix_asset_baseurl.py --dry-run   # report only
  python3 scripts/fix_asset_baseurl.py --apply     # write changes
"""
import argparse
import glob
import re
import sys

# Body patterns -> capture the /assets/... URL, rewrite URL only.
# 1) markdown image/link:  ](/assets/PATH)  or  ](/assets/PATH "title")
MD_RE = re.compile(r'\]\((/assets/[^)\s]+)')
# 2) raw html:  src="/assets/PATH"  src='/assets/PATH'
HTML_RE = re.compile(r'''(src|href)=(["'])(/assets/[^"']+)\2''')

INLINE_CODE_RE = re.compile(r'`[^`]*`')


def rewrite_line(line):
    """Rewrite a single body line, preserving inline-code spans verbatim."""
    # Protect inline `code` spans: replace with placeholders, restore after.
    spans = []

    def _stash(m):
        spans.append(m.group(0))
        return f'\x00{len(spans)-1}\x00'

    protected = INLINE_CODE_RE.sub(_stash, line)

    n = 0

    def _md(m):
        nonlocal n
        n += 1
        return f"]({{{{ '{m.group(1)}' | relative_url }}}}"

    def _html(m):
        nonlocal n
        n += 1
        attr, q, url = m.group(1), m.group(2), m.group(3)
        return f"{attr}={q}{{{{ '{url}' | relative_url }}}}{q}"

    protected = MD_RE.sub(_md, protected)
    protected = HTML_RE.sub(_html, protected)

    # restore inline code
    def _restore(m):
        return spans[int(m.group(1))]

    out = re.sub(r'\x00(\d+)\x00', _restore, protected)
    return out, n


def process(path, apply):
    try:
        src = open(path, encoding='utf-8').read()
    except Exception as e:
        print(f"SKIP {path}: {e}", file=sys.stderr)
        return 0
    lines = src.split('\n')
    out_lines = []
    in_fence = False
    fm_state = 0  # 0=before front matter, 1=inside, 2=after
    total = 0
    for i, ln in enumerate(lines):
        stripped = ln.lstrip()
        # front matter delimiters (only leading ---, first two)
        if fm_state < 2 and stripped == '---' and (i == 0 or fm_state == 1):
            fm_state = 1 if fm_state == 0 else 2
            out_lines.append(ln)
            continue
        if fm_state == 1:  # inside front matter -> leave untouched
            out_lines.append(ln)
            continue
        # fenced code block toggle
        if stripped.startswith('```') or stripped.startswith('~~~'):
            in_fence = not in_fence
            out_lines.append(ln)
            continue
        if in_fence:
            out_lines.append(ln)
            continue
        new, n = rewrite_line(ln)
        total += n
        out_lines.append(new)
    if total and apply:
        open(path, 'w', encoding='utf-8').write('\n'.join(out_lines))
    return total


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument('--apply', action='store_true')
    ap.add_argument('--dry-run', action='store_true')
    args = ap.parse_args()
    apply = args.apply and not args.dry_run
    files = sorted(set(
        glob.glob('_posts/**/*.md', recursive=True)
        + glob.glob('_posts/**/*.html', recursive=True)
        + glob.glob('_pages/**/*.md', recursive=True)
        + glob.glob('_pages/**/*.html', recursive=True)
    ))
    changed_files = 0
    total = 0
    for f in files:
        n = process(f, apply)
        if n:
            changed_files += 1
            total += n
    mode = 'APPLIED' if apply else 'DRY-RUN'
    print(f"[{mode}] files_changed={changed_files} refs_rewritten={total} scanned={len(files)}")


if __name__ == '__main__':
    main()
