#!/usr/bin/env python3
"""A page must not ship more than readers will wait for.

WHY (2026-08-31)
  A fat page is invisible in review: the markdown looks the same, the build is green,
  and only a reader on a phone pays. This gate makes it visible at build time.

WHAT IT MEASURES — and why not raw bytes
  The obvious gate is "raw HTML > 500KB fails". Measured on this site, that gate would
  fail EVERY page for a non-problem: pages are ~5.3MB raw but 96% of those bytes are
  whitespace emitted by a commented-out Liquid nav loop, and CloudFront serves gzip.
  The same 5,338KB page is 63KB on the wire.

  So the blocking threshold is TRANSFER size (gzip), which is what a reader downloads.
  Raw bloat is reported as a warning, never a failure — it costs nothing over the wire
  but it is a real smell worth naming.

  page_weight_check.py [_site]      exit 1 = a page exceeds the transfer budget
"""
from __future__ import annotations
import gzip, sys
from pathlib import Path

MAX_GZIP = 500 * 1024        # blocking: what the reader actually downloads
WARN_RAW = 2 * 1024 * 1024   # advisory: uncompressed bloat
WARN_WS = 0.50               # advisory: whitespace share of raw bytes


def main(root: str = "_site") -> int:
    base = Path(root)
    if not base.is_dir():
        print(f"page-weight: {base} 없음 — 빌드 후 실행해야 한다", file=sys.stderr)
        return 1
    pages = sorted(base.rglob("*.html"))
    if not pages:
        print(f"page-weight: {base} 에 html 0개 — 빌드가 비었다", file=sys.stderr)
        return 1

    over, bloat = [], []
    for p in pages:
        data = p.read_bytes()
        gz = len(gzip.compress(data, 9))
        if gz > MAX_GZIP:
            over.append((gz, len(data), p))
        elif len(data) > WARN_RAW:
            ws = sum(data.count(c) for c in b" \t\n\r") / max(len(data), 1)
            if ws > WARN_WS:
                bloat.append((len(data), ws, p))

    if bloat:
        bloat.sort(reverse=True)
        print(f"⚠️  압축 전 비대 {len(bloat)}쪽 (전송량엔 영향 없음, 상위 5):")
        for raw, ws, p in bloat[:5]:
            print(f"    {raw/1024:7.0f}KB raw · 공백 {ws*100:.0f}%  {p.relative_to(base)}")

    if over:
        over.sort(reverse=True)
        print(f"⛔ 전송 용량 초과 {len(over)}쪽 (gzip > {MAX_GZIP//1024}KB):", file=sys.stderr)
        for gz, raw, p in over:
            print(f"    {gz/1024:6.0f}KB gzip ({raw/1024:.0f}KB raw)  {p.relative_to(base)}", file=sys.stderr)
        return 1

    worst = max((len(gzip.compress(p.read_bytes(), 9)) for p in pages), default=0)
    print(f"✅ page-weight: {len(pages)}쪽 전부 통과 — 최대 전송 {worst/1024:.0f}KB / 상한 {MAX_GZIP//1024}KB")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "_site"))
