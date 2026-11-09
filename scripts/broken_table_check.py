#!/usr/bin/env python3
"""빌드된 _site 에서 표로 렌더되지 않은 마크다운 표를 찾는다.

kramdown 은 표 바로 다음 줄에 빈 줄 없이 문단(캡션 등)이 붙거나 열 수가 어긋나면
표 전체를 문단으로 렌더한다. 그러면 화면에 `| a | b | |—|—|` 같은 원문이 그대로 보인다.
<table> 밖 본문 텍스트에 구분행 패턴(|---| 또는 스마트 대시로 바뀐 |—|)이 있으면 실패다.
"""
import re, sys, pathlib

SEP = re.compile(r"\|\s*:?[-—–]{1,}:?\s*\|\s*:?[-—–]{1,}:?\s*\|")
STRIP = re.compile(r"<(pre|code|script|style|table)\b.*?</\1>", re.S | re.I)

def main(root: str) -> int:
    bad = []
    for f in pathlib.Path(root).rglob("index.html"):
        html = STRIP.sub("", f.read_text(errors="ignore"))
        text = re.sub(r"<[^>]+>", " ", html)
        if SEP.search(text):
            bad.append(str(f))
    for b in bad:
        print(f"❌ 깨진 표: {b}")
    print(f"broken_table_check: {len(bad)} page(s)")
    return 1 if bad else 0

if __name__ == "__main__":
    sys.exit(main(sys.argv[1] if len(sys.argv) > 1 else "_site"))
