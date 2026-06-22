#!/usr/bin/env python3
"""Revive selected news posts: published:true + convert raw <iframe>/<figure>
video embeds to the theme-native {% include video %} (youtube-nocookie, responsive).
Idempotent. Prose untouched. Run from repo root."""
import re, sys, pathlib

ROOT = pathlib.Path(__file__).resolve().parents[1]
SLUGS = [
    "2025-06-19-karpathy-software-era-ai-programming-paradigms",
    "2025-05-28-jensen-huang-ai-industrial-revolution-insights",
    "2025-06-17-hinton-ai-godfather-interview-key-insights",
    "2025-06-12-demis-hassabis-agi-radical-abundance-vision",
    "2025-06-15-kent-beck-tdd-ai-agents-coding-evolution",
    "2025-05-27-eric-schmidt-ted-ai-revolution-underhyped",
    "2025-06-12-cursor-ai-coding-revolution-future-insights",
    "2025-06-05-jeff-dean-bill-coughran-talk",
    "2025-08-20-po-shen-loh-ai-creative-supremacy-era-insights",
]
LANGS = ["ko", "en", "ar"]

FIGURE_RE = re.compile(r'<figure class="video-container">.*?</figure>', re.S)
IFRAME_RE = re.compile(r'<iframe\b.*?</iframe>', re.S)
FIGCAP_RE = re.compile(r'<figcaption>(.*?)</figcaption>', re.S)
ID_RE = re.compile(r'(?:youtube(?:-nocookie)?\.com/embed/|youtu\.be/|watch\?v=)([A-Za-z0-9_-]{6,})')


def extract_id(block):
    m = ID_RE.search(block)
    return m.group(1) if m else None


def caption_from(block):
    m = FIGCAP_RE.search(block)
    if not m:
        return None
    txt = re.sub(r'\s+', ' ', m.group(1)).strip()
    txt = re.sub(r'^[※*]\s*', '', txt).strip()
    return txt or None


def build_include(vid, caption):
    out = '{% include video id="' + vid + '" provider="youtube" %}'
    if caption:
        out += "\n\n*" + caption + "*"
    return out


def process(path):
    text = path.read_text(encoding="utf-8")
    orig = text
    notes = []

    # 1) revive
    new = re.sub(r'(?m)^published:\s*false\s*$', 'published: true', text)
    if new != text:
        notes.append("published->true")
        text = new

    # 2) figure block first, else bare iframe
    block = None
    m = FIGURE_RE.search(text)
    kind = None
    if m:
        block, kind = m.group(0), "figure"
    else:
        m = IFRAME_RE.search(text)
        if m:
            block, kind = m.group(0), "iframe"

    if block:
        vid = extract_id(block)
        if not vid:
            notes.append("WARN: no video id found, embed left as-is")
        else:
            cap = caption_from(block) if kind == "figure" else None
            text = text[:m.start()] + build_include(vid, cap) + text[m.end():]
            notes.append("embed->include id=%s%s" % (vid, " +caption" if cap else ""))
    else:
        notes.append("no embed block (skipped embed step)")

    if text != orig:
        path.write_text(text, encoding="utf-8")
        return "CHANGED", notes
    return "nochange", notes


def main():
    any_change = False
    for slug in SLUGS:
        for lang in LANGS:
            p = ROOT / "_posts" / lang / "news" / (slug + ".md")
            if not p.exists():
                print(f"  MISSING  {lang}/{slug}")
                continue
            status, notes = process(p)
            if status == "CHANGED":
                any_change = True
            print(f"  {status:8} {lang}/{slug} :: {', '.join(notes)}")
    print("done.", "changes written." if any_change else "no changes.")


if __name__ == "__main__":
    main()
