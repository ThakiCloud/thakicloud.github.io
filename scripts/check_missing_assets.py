#!/usr/bin/env python3
"""Gate: detect (and optionally strip) post image references whose asset files
do not exist. Prevents shipping broken <img> when the auto-generation pipeline
failed to produce a hero/figure but still emitted the markdown reference.

--check  : list every referenced-but-missing image (exit 1 if any). CI/pre-deploy.
--strip  : remove the dangling references so no broken image renders:
             * body markdown image line  ![alt](.../x.png)   -> line deleted
             * front-matter  image:/teaser:/overlay_image:/header image lines -> deleted
           Code-block example paths and external URLs are never touched.
           Prints exactly what was stripped (never silent).

Scope: _posts, _pages. Run from repo root.
"""
import argparse
import glob
import os
import re
import sys

# a referenced local asset: markdown ](...) , relative_url liquid, or html src/href
REF_RE = re.compile(r"/assets/[^\s'\")}|]+\.(?:png|webp|jpg|jpeg|svg|gif)", re.I)
# front-matter line whose value is (only) an asset path
FM_LINE_RE = re.compile(r"^\s*(image|teaser|overlay_image|header_image|thumbnail|og_image)\s*:\s*\S*?/assets/\S+\s*$", re.I)


def missing_in_line(line, in_fence):
    """Return list of missing asset relpaths referenced on this line (skip code)."""
    if in_fence:
        return []
    out = []
    for m in REF_RE.findall(line):
        rel = m.lstrip("/")
        if not os.path.exists(rel):
            out.append(rel)
    return out


def scan(files):
    findings = []  # (file, lineno, kind, asset, raw)
    for f in files:
        try:
            lines = open(f, encoding="utf-8").read().split("\n")
        except Exception:
            continue
        in_fence = False
        fm = 0
        for i, ln in enumerate(lines):
            s = ln.lstrip()
            if fm < 2 and s == "---" and (i == 0 or fm == 1):
                fm = 1 if fm == 0 else 2
                continue
            if fm == 1:
                for rel in [m.lstrip("/") for m in REF_RE.findall(ln)]:
                    if not os.path.exists(rel):
                        kind = "frontmatter" if FM_LINE_RE.match(ln) else "frontmatter-inline"
                        findings.append((f, i, kind, rel, ln))
                continue
            if s.startswith("```") or s.startswith("~~~"):
                in_fence = not in_fence
                continue
            for rel in missing_in_line(ln, in_fence):
                kind = "body-image" if "](" in ln or "<img" in ln or "src=" in ln else "body-other"
                findings.append((f, i, kind, rel, ln))
    return findings


def strip(files, findings):
    by_file = {}
    for f, i, kind, rel, raw in findings:
        by_file.setdefault(f, set()).add(i)
    stripped = 0
    for f, drop in by_file.items():
        lines = open(f, encoding="utf-8").read().split("\n")
        kept = [ln for j, ln in enumerate(lines) if j not in drop]
        open(f, "w", encoding="utf-8").write("\n".join(kept))
        stripped += len(drop)
    return stripped


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--strip", action="store_true")
    args = ap.parse_args()
    files = sorted(
        glob.glob("_posts/**/*.md", recursive=True)
        + glob.glob("_posts/**/*.html", recursive=True)
        + glob.glob("_pages/**/*.md", recursive=True)
    )
    findings = scan(files)
    if not findings:
        print("[check-missing-assets] OK — no referenced-but-missing images.")
        return 0
    print(f"[check-missing-assets] {len(findings)} dangling image reference(s):")
    for f, i, kind, rel, raw in findings:
        print(f"  {kind:18} {rel}")
        print(f"      {os.path.basename(f)}:{i+1}")
    if args.strip:
        n = strip(files, findings)
        print(f"[check-missing-assets] STRIPPED {n} line(s) referencing missing images.")
        return 0
    # --check (default): fail so CI surfaces it
    return 1


if __name__ == "__main__":
    sys.exit(main())
