#!/usr/bin/env python3
"""Fail the build if the language toggle cannot reach a post's translation.

The language toggle lives in the injected site chrome (thaki-chrome.js, from the
homepage repo). As deployed it rewrites ONLY the language segment of the path:

    /tech-blog/(en|ko|ar)/rest...  ->  /tech-blog/<target>/rest...

It does not read hreflang. So the rest of the path — category segment included —
must be identical across languages, or the toggle lands on a URL that does not
exist. That is exactly how every comic broke: ko lived at /ko/만화/<slug>/ and en
at /en/comics/<slug>/, so pressing EN produced /en/만화/<slug>/ and 404'd.

This gate re-derives the toggle's arithmetic from the built site and asserts that
wherever a translation EXISTS, the toggle actually reaches it. A post with no
translation is reported but not failed — the toggle has nowhere to go and no
change to this repo can invent one.

Usage: python3 scripts/check_language_toggle.py [_site]
"""
import os
import re
import sys
import urllib.parse

LANGS = ("ko", "en", "ar")
ALT = re.compile(
    r'<link rel="alternate" hreflang="([a-z-]+)" href="https?://[^/]+(/[^"]*)">'
)
LANG_SEG = re.compile(r"^(/tech-blog)?/(en|ko|ar)(?=/|$)")


def page_url(root: str, site: str) -> str:
    rel = os.path.relpath(root, site).replace(os.sep, "/")
    return "/" if rel == "." else "/" + rel + "/"


def exists(site: str, url: str) -> bool:
    p = urllib.parse.unquote(url).strip("/")
    return os.path.exists(os.path.join(site, p, "index.html"))


def main() -> int:
    site = sys.argv[1] if len(sys.argv) > 1 else "_site"
    if not os.path.isdir(site):
        print(f"FAIL: no such build directory: {site}")
        return 1

    broken, checked, untranslated = [], 0, 0
    for root, _dirs, files in os.walk(site):
        if "index.html" not in files:
            continue
        url = page_url(root, site)
        if not LANG_SEG.match(url):
            continue
        with open(os.path.join(root, "index.html"), encoding="utf-8", errors="ignore") as fh:
            html = fh.read()
        # hreflang hrefs are absolute and carry the /tech-blog baseurl; the built
        # page path does not. Strip it so both sides speak the same coordinates.
        alts = {
            lang: re.sub(r"^/tech-blog", "", href)
            for lang, href in ALT.findall(html)
            if lang in LANGS
        }
        own = {lang: u for lang, u in alts.items() if u == url}
        others = {lang: u for lang, u in alts.items() if u != url}
        if not others:
            if own:
                untranslated += 1
            continue
        for lang, real in others.items():
            checked += 1
            swapped = LANG_SEG.sub(lambda m: (m.group(1) or "") + "/" + lang, url)
            if swapped != real and not exists(site, swapped):
                broken.append((url, lang, swapped, real))

    for url, lang, swapped, real in broken:
        print(f"BROKEN {url}  --[{lang}]-->  {swapped}   (translation is at {real})")

    print(
        f"toggle pairs checked={checked} broken={len(broken)} "
        f"posts_without_translation={untranslated}"
    )
    if broken:
        print(
            "\nThe toggle swaps only the language segment, so the rest of the path "
            "must match across languages.\nUnify the category value in the posts' "
            "front matter rather than aliasing it in _data/category_aliases.yml — "
            "an alias fixes the sitemap but not the toggle."
        )
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
