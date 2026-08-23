---
title: "Qwen-Image-3.0 공개: '진짜(实)'를 내건 3세대 이미지 모델, 가중치는 아직입니다"
excerpt: "알리바바 Qwen 팀이 이미지 생성 3세대 모델 Qwen-Image-3.0을 발표했습니다. 4.5k 토큰 입력, 10px 초소형 텍스트, 12개 언어 렌더링을 앞세웠지만 지금 쓸 수 있는 경로는 Qwen Chat 호스팅뿐이고 가중치도 벤치마크도 공개되지 않았습니다. 확인된 사실과 아직 아닌 부분을 나눠 정리했습니다."
seo_title: "Qwen-Image-3.0 발표 분석: 확인된 능력과 미공개 가중치"
seo_description: "알리바바 Qwen-Image-3.0은 4.5k 토큰 입력, 10px 소형 텍스트, 12개 언어 렌더링을 앞세운 3세대 이미지 생성 모델입니다. Qwen Chat 호스팅 가용 여부, 미공개 가중치와 벤치마크를 구분하고, 이미지 생성이 '예쁜 그림'에서 '생산성 도구'로 넘어갈 때 온프렘 서빙과 문서 자동화에 주는 함의를 분석합니다."
date: 2026-07-21
last_modified_at: 2026-07-21
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "image"
tags:
  - qwen
  - image-generation
  - text-to-image
  - multimodal
  - alibaba
  - on-prem-serving
  - news
  - thakicloud
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ko/news/qwen-image-3-0-preview/"
---

화요일 아침 Qwen 팀 블로그에 이미지 생성 모델의 3세대 발표가 올라왔습니다. 이름은 Qwen-Image-3.0이고, 팀은 세대마다 붙여 온 키워드를 이번에도 하나로 압축했습니다. 1.0이 "정밀", 2.0이 "정밀, 다양성, 완결성, 미감, 진정성"이었다면 3.0의 핵심은 한 글자 "진짜(实, Real)"라는 것입니다.

다만 발표는 릴리즈가 아닙니다. 이 글은 데모의 화려함을 걷어내고, 이번 발표에서 실제로 확인된 것이 무엇이고 아직 손에 잡히지 않는 것이 무엇인지를 나눠 보려 합니다. 이미지 생성 모델을 고객 인프라 위에 올려 서빙하는 입장에서는, 데모 몇 장과 능력 소개 문구만으로 로드맵을 확정할 수 없기 때문입니다. 확인된 것과 아직 아닌 것을 구분하는 일 자체가 인프라 회사의 실무입니다.

## Qwen-Image-3.0, 무엇이 발표됐나

먼저 확인된 사실입니다. Qwen 팀은 2026년 7월 21일 Qwen-Image-3.0을 발표하면서, 이 모델의 지향을 세 가지 축으로 설명했습니다.

첫째는 "풍부한 내용(Rich Content)"입니다. 입력 지시문 길이를 4.5k 토큰까지 받아들여, 신문이나 스토리보드, 시험지처럼 정보 밀도가 높은 레이아웃을 한 번에 그려낸다는 것입니다. 발표에서 가장 인상적인 예시는 3×3 격자 이미지였습니다. 각 칸이 터널 안전 만화, 공간기하 강의, 물리 포물선 운동, 세포 DNA 구조 비교 같은 서로 다른 인포그래픽이고, 이 격자 전체를 3.7k 토큰짜리 단일 지시문으로 한 번에 생성했다고 합니다. 여러 이미지를 이어 붙인 것이 아니라 한 번의 생성이라는 점을 팀은 강조했습니다. 여기에 더해 VSCode 화면 안에 Qwen Chat이 있고 그 안에 위챗 화면이, 다시 그 안에 포스터가 들어가는 "화면 속 화면 속 화면"의 중첩 렌더링도 예시로 제시됐습니다.

둘째는 "사실적 디테일(Authentic Details)"입니다. 10px 수준의 작은 글자도 읽을 수 있게 렌더링하고, 모공과 머리카락, 피부 질감을 사진에 가깝게 묘사한다는 것입니다. LaTeX 수식이 빽빽한 학술 논문 페이지, 실제 신문 지면, 편집 작업에서 손글씨 주석을 덧입히거나 훼손된 전통 회화를 복원하는 사례도 함께 소개됐습니다.

셋째는 "깊은 지식(Deep Knowledge)"입니다. 12개 언어를 네이티브로 렌더링하고, 100개가 넘는 화풍과 다양한 UI 인터페이스를 세계 지식에 기반해 그려낸다는 것입니다. 발표에는 일본어, 한국어, 스페인어를 정확히 렌더링한 예시와, 인터넷에 연결해 최신 정보를 반영한다는 설명이 함께 있었습니다. 특정 IP 인물을 찾아 생성하는 예시로 치바이스와 반 고흐가 라이브 방송에서 Qwen-Image-3.0을 소개하는 장면도 제시됐습니다.

접근 경로도 확인됩니다. 발표 글의 실행 버튼은 모두 Qwen Chat의 텍스트-투-이미지 기능으로 연결됩니다. 즉 지금 만져볼 수 있는 것은 알리바바 플랫폼에서 호스팅되는 서비스 형태이며, 이는 프리뷰 성격의 가용성입니다.

## 무엇이 아직 공개되지 않았나

여기서 조심스럽게 읽어야 할 대목이 시작됩니다. 이번 발표 글에는 이미지 생성 모델을 실제로 도입할 때 가장 먼저 확인해야 할 정보가 통째로 빠져 있습니다.

가중치가 없습니다. 발표는 능력을 보여주는 쇼케이스이고, Hugging Face나 ModelScope에 올라온 다운로드 가능한 체크포인트로 연결되지 않습니다. 세 번째 파티가 만든 커뮤니티 생성기 사이트조차 3.0에 대해서는 "접근 대기(access pending)" 상태로 표기하고 있습니다. 파라미터 수, 모델 아키텍처, 라이선스도 발표 글에 명시되지 않았습니다. 1.0이 20B 규모의 MMDiT였고 2.0이 파라미터를 7B로 줄였다는 사실이 각각 공개됐던 것과 비교하면, 3.0은 아직 구조를 가늠할 단서가 없습니다.

표준 벤치마크도 없습니다. 4.5k 토큰 입력이나 10px 텍스트 렌더링 같은 능력은 발표자가 고른 데모로 제시됐을 뿐, DPG나 GenEval처럼 재현 가능한 평가 표가 함께 나오지 않았습니다. 따라서 "이전 세대보다 낫다"거나 "생산성 도구로 쓸 수 있다"는 문구는, 검증된 수치가 아니라 발표자의 주장 [추정]으로 읽는 것이 안전합니다. 데모는 대체로 가장 잘 나온 결과를 고른 것이므로, 실패율이나 일관성은 별도로 확인해야 합니다.

정리하면 아래와 같습니다.

| 항목 | 상태 |
|---|---|
| 발표·3세대 모델 | 확인됨 |
| 4.5k 토큰 입력·복잡 레이아웃 | 확인됨(데모) |
| 10px 텍스트·12개 언어 렌더링 | 확인됨(데모) |
| Qwen Chat 사용 가용 | 확인됨(호스팅) |
| 오픈 가중치(HF/ModelScope) | 미공개 |
| 파라미터·아키텍처·라이선스 | 미공개 |
| 표준 벤치마크 | 미공개 |
| "생산성 도구" 수준 성능 | 미검증 주장 [추정] |

## 이미지 생성이 '예쁜 그림'에서 '생산성 도구'로

발표에서 반복되는 표현은 "보기 좋은(good-looking)"에서 "쓸모 있는(useful)"으로의 이동입니다. 이 프레임은 이번 세대가 겨냥하는 지점을 잘 요약합니다. 예술적인 한 장을 뽑는 것이 아니라, 신문 지면 PDF, 짧은 드라마 스토리보드, 복잡한 UI 목업처럼 그대로 업무에 투입할 수 있는 산출물을 겨냥한다는 것입니다.

{% raw %}
<!--
  animated-architecture-diagram — self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="260721qwenimage30preview-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent — swap for #1B4F72 etc. */
    position: relative;
    font-family: -apple-system, BlinkMacSystemFont, "Segoe UI", "Noto Sans KR", system-ui, sans-serif;
    color: var(--text-color);
  }
  @media (prefers-color-scheme: dark) {
    .d3-arch {
      --page-bg: #0f1115;
      --surface-bg: #171a21;
      --text-color: #e6e8eb;
      --muted-color: #9aa3af;
      --border-color: #2a2f3a;
      --primary-color: hsl(217 91% 62%);
    }
  }
  .d3-arch[data-theme="light"] { --page-bg:#fff; --surface-bg:#f7f8fa; --text-color:#1a1d21; --muted-color:#6b7280; --border-color:#d5d9e0; --primary-color:hsl(217 91% 55%); }
  .d3-arch[data-theme="dark"]  { --page-bg:#0f1115; --surface-bg:#171a21; --text-color:#e6e8eb; --muted-color:#9aa3af; --border-color:#2a2f3a; --primary-color:hsl(217 91% 62%); }

  .d3-arch .diagram-scroll { overflow-x: auto; }
  .d3-arch svg { display: block; width: 100%; max-width: 100%; height: auto; font-family: inherit; }

  /* Group boxes */
  .d3-arch .group rect { fill: none; stroke: var(--border-color); stroke-dasharray: 3 3; rx: 12px; }
  .d3-arch .group text { font-size: 10px; font-weight: 700; letter-spacing: 0.08em; text-transform: uppercase; fill: var(--muted-color); }

  /* Nodes */
  .d3-arch .node rect { fill: var(--surface-bg); stroke: var(--border-color); stroke-width: 1; transition: stroke 0.15s ease, opacity 0.15s ease; }
  .d3-arch .node .node-title { font-size: 12px; font-weight: 600; fill: var(--text-color); }
  .d3-arch .node .node-sub { font-size: 9.5px; fill: var(--muted-color); }
  .d3-arch .node { cursor: default; transition: opacity 0.15s ease; }

  /* Edges */
  .d3-arch .edge { transition: opacity 0.15s ease; }
  .d3-arch .edge path.main { fill: none; stroke-width: 1.5; }
  .d3-arch .edge.data path.main { stroke: var(--primary-color); }
  .d3-arch .edge.event path.main { stroke: var(--muted-color); stroke-dasharray: 5 4; }
  .d3-arch .edge text { font-size: 9.5px; fill: var(--muted-color); paint-order: stroke; stroke: var(--page-bg); stroke-width: 3px; stroke-linejoin: round; }

  /* Hover highlighting */
  .d3-arch.hovering .edge:not(.hl) { opacity: 0.12; }
  .d3-arch.hovering .node:not(.hl):not(.nb) { opacity: 0.25; }
  .d3-arch .node.hl rect { stroke: var(--primary-color); stroke-width: 1.5; }

  /* Flow animation */
  .d3-arch .flow-dot.data { fill: var(--primary-color); stroke: var(--page-bg); stroke-width: 1.5; }
  .d3-arch .flow-dot.event { fill: var(--page-bg); stroke: var(--muted-color); stroke-width: 1.5; }
  .d3-arch .node.anim-hl rect { stroke: var(--primary-color); stroke-width: 1.5; }
  .d3-arch .replay-btn { font: inherit; font-size: 11px; font-weight: 600; padding: 4px 10px; border: 1px solid var(--border-color); border-radius: 8px; background: var(--surface-bg); color: var(--text-color); cursor: pointer; transition: border-color 0.15s ease, opacity 0.15s ease; }
  .d3-arch .replay-btn:hover:not(:disabled) { border-color: var(--primary-color); }
  .d3-arch .replay-btn:disabled { opacity: 0.45; cursor: default; }
  .d3-arch .replay-btn:focus-visible { outline: 2px solid var(--primary-color); outline-offset: 1px; }

  /* Legend */
  .d3-arch .legend { display: flex; flex-direction: column; align-items: flex-start; gap: 6px; margin-top: 10px; }
  .d3-arch .legend-title { font-size: 12px; font-weight: 700; color: var(--text-color); }
  .d3-arch .legend .items { display: flex; flex-wrap: wrap; gap: 8px 18px; align-items: center; }
  .d3-arch .legend .item { display: inline-flex; align-items: center; gap: 7px; white-space: nowrap; font-size: 12px; color: var(--text-color); }
  .d3-arch .legend .swatch { width: 22px; height: 0; }
  .d3-arch .legend .swatch.data-line { border-top: 2.5px solid var(--primary-color); }
  .d3-arch .legend .swatch.event-line { border-top: 2.5px dashed var(--muted-color); }
  .d3-arch .legend .hint { font-size: 11px; font-style: italic; color: var(--muted-color); }
</style>
<script>
  (() => {
    const SPEC = ({"title": "", "ariaLabel": "", "width": 825, "height": 660, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 488, "y": 24, "w": 149, "h": 46, "title": "Qwen-Image 세대별 지향"}, {"id": "B", "x": 609, "y": 148, "w": 184, "h": 62, "title": ["1.0", "정밀 · 20B MMDiT · 오픈웨이트"]}, {"id": "C", "x": 363, "y": 148, "w": 191, "h": 62, "title": ["2.0", "정밀·다양성·완결성 · 7B · 오픈웨이트"]}, {"id": "D", "x": 103, "y": 148, "w": 205, "h": 62, "title": ["3.0", "'진짜' · 파라미터 미공개 · 가중치 미공개"]}, {"id": "E", "x": 439, "y": 288, "w": 149, "h": 62, "title": ["Rich Content", "4.5k 토큰 · 복잡 레이아웃"]}, {"id": "F", "x": 235, "y": 288, "w": 149, "h": 62, "title": ["Authentic Details", "10px 텍스트 · 사진급 질감"]}, {"id": "G", "x": 24, "y": 288, "w": 156, "h": 62, "title": ["Deep Knowledge", "12개 언어 · UI · 세계지식"]}, {"id": "H", "x": 216, "y": 428, "w": 184, "h": 62, "title": ["생산성 산출물", "신문 PDF · 스토리보드 · UI 목업"]}, {"id": "I", "x": 248, "y": 582, "w": 120, "h": 46, "title": "온프렘 서빙 검토 가능"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[614, 70], [701, 109], [701, 109], [701, 148]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[524, 70], [459, 109], [459, 109], [459, 148]]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[488, 60], [206, 109], [206, 109], [206, 148]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[308, 202], [514, 249], [514, 249], [514, 288]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[252, 210], [310, 249], [310, 249], [310, 288]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[160, 210], [102, 249], [102, 249], [102, 288]]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[514, 350], [514, 389], [514, 389], [399, 428]]}, {"src": "F", "dst": "H", "kind": "data", "line": [310, 350, 309, 428]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[102, 350], [102, 389], [102, 389], [217, 428]]}, {"src": "H", "dst": "I", "kind": "event", "label": "가중치 공개 시", "line": [308, 490, 308, 582], "lx": 308, "ly": 532}]});
    const ensureD3 = (cb) => {
      if (window.d3 && typeof window.d3.select === 'function') return cb();
      let s = document.getElementById('d3-cdn-script');
      if (!s) {
        s = document.createElement('script');
        s.id = 'd3-cdn-script';
        s.src = 'https://cdn.jsdelivr.net/npm/d3@7/dist/d3.min.js';
        document.head.appendChild(s);
      }
      const onReady = () => { if (window.d3 && typeof window.d3.select === 'function') cb(); };
      s.addEventListener('load', onReady, { once: true });
      if (window.d3) onReady();
    };

    const bootstrap = () => {
      const container = document.getElementById('260721qwenimage30preview-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '260721qwenimage30preview-1';
        const NODES = SPEC.nodes || [];
        const EDGES = SPEC.edges || [];
        const GROUPS = SPEC.groups || [];
        const HOP = SPEC.hop || 800;
        const legendCfg = SPEC.legend || {};
        const dataLabel = legendCfg.data || 'Data path';
        const eventLabel = legendCfg.event || 'Event side-channel';

        const byId = Object.fromEntries(NODES.map((n) => [n.id, n]));
        const cx = (n) => n.x + n.w / 2;
        const asTitle = (t) => Array.isArray(t) ? t : [t];

        // Canvas: explicit, else auto from node/group extents + padding
        let W = SPEC.width, H = SPEC.height;
        if (!W || !H) {
          const xs = [], ys = [];
          NODES.forEach((n) => { xs.push(n.x + n.w); ys.push(n.y + n.h); });
          GROUPS.forEach((g) => { xs.push(g.x + g.w); ys.push(g.y + g.h); });
          W = W || Math.max(760, Math.ceil(Math.max(...xs, 0) + 24));
          H = H || Math.ceil(Math.max(...ys, 0) + 20);
        }

        // Tooltip
        container.style.position = container.style.position || 'relative';
        const tip = document.createElement('div');
        Object.assign(tip.style, {
          position: 'absolute', top: '0px', left: '0px',
          transform: 'translate(-9999px, -9999px)', pointerEvents: 'none',
          padding: '8px 10px', borderRadius: '8px', fontSize: '12px', lineHeight: '1.4',
          border: '1px solid var(--border-color)', background: 'var(--surface-bg)',
          color: 'var(--text-color)', boxShadow: '0 4px 24px rgba(0,0,0,.18)',
          opacity: '0', transition: 'opacity .12s ease', maxWidth: '260px', zIndex: '3'
        });
        const tipInner = document.createElement('div');
        tip.appendChild(tipInner);

        const scroll = document.createElement('div');
        scroll.className = 'diagram-scroll';
        container.appendChild(scroll);

        const svg = d3.select(scroll).append('svg')
          .attr('viewBox', `0 0 ${W} ${H}`)
          .attr('preserveAspectRatio', 'xMidYMid meet')
          .attr('role', 'img')
          .attr('aria-label', SPEC.ariaLabel || SPEC.title || 'Architecture diagram');
        svg.style('max-width', W + 'px').style('min-width', Math.min(W, 760) + 'px').style('margin', '0 auto');

        const defs = svg.append('defs');
        const mkMarker = (id, color) => {
          defs.append('marker')
            .attr('id', id).attr('viewBox', '0 0 10 10')
            .attr('refX', 9).attr('refY', 5)
            .attr('markerWidth', 6.5).attr('markerHeight', 6.5)
            .attr('orient', 'auto-start-reverse')
            .append('path').attr('d', 'M 0 0 L 10 5 L 0 10 z').style('fill', color);
        };
        mkMarker(`${uid}-arrow-data`, 'var(--primary-color)');
        mkMarker(`${uid}-arrow-event`, 'var(--muted-color)');

        // Groups
        const groups = svg.append('g');
        GROUPS.forEach((gr) => {
          const g = groups.append('g').attr('class', 'group');
          g.append('rect').attr('x', gr.x).attr('y', gr.y).attr('width', gr.w).attr('height', gr.h).attr('rx', 12);
          if (gr.label) g.append('text').attr('x', gr.lx != null ? gr.lx : gr.x + 12).attr('y', gr.ly != null ? gr.ly : gr.y + 18).text(gr.label);
        });

        // Edges (under nodes)
        const edgeLayer = svg.append('g');
        const curvePath = (p) => `M ${p[0][0]} ${p[0][1]} C ${p[1][0]} ${p[1][1]}, ${p[2][0]} ${p[2][1]}, ${p[3][0]} ${p[3][1]}`;
        EDGES.forEach((e, i) => {
          const kind = e.kind === 'event' ? 'event' : 'data';
          const g = edgeLayer.append('g').attr('class', `edge ${kind}`).attr('data-src', e.src).attr('data-dst', e.dst);
          const marker = `url(#${uid}-arrow-${kind})`;
          if (e.line) {
            const [x1, y1, x2, y2] = e.line;
            e.pathEl = g.append('path').attr('class', 'main').attr('d', `M ${x1} ${y1} L ${x2} ${y2}`).attr('marker-end', marker).node();
            if (e.label) g.append('text').attr('x', e.lx != null ? e.lx : (x1 + x2) / 2).attr('y', e.ly != null ? e.ly : (y1 + y2) / 2 - 6).attr('text-anchor', e.anchor || 'middle').text(e.label);
          } else if (e.curve) {
            e.pathEl = g.append('path').attr('class', 'main').attr('d', curvePath(e.curve)).attr('marker-end', marker).node();
            if (e.label && e.off) {
              const p = e.curve;
              const lp = p[3][0] < p[0][0] ? [p[3], p[2], p[1], p[0]] : p;
              const lpId = `${uid}-lbl-${i}`;
              g.append('path').attr('id', lpId).attr('d', curvePath(lp)).attr('fill', 'none').attr('stroke', 'none');
              g.append('text').attr('dy', -5).append('textPath').attr('href', `#${lpId}`).attr('startOffset', e.off).attr('text-anchor', 'middle').text(e.label);
            } else if (e.label) {
              g.append('text').attr('x', e.lx).attr('y', e.ly).attr('text-anchor', e.anchor || 'start').text(e.label);
            }
          }
        });

        // Nodes (over edges)
        const nodeLayer = svg.append('g');
        NODES.forEach((n) => {
          const g = nodeLayer.append('g').attr('class', 'node').attr('data-id', n.id);
          g.append('rect').attr('x', n.x).attr('y', n.y).attr('width', n.w).attr('height', n.h).attr('rx', 9);
          const title = asTitle(n.title);
          const lines = title.length;
          const baseY = n.y + n.h / 2 - (lines - 1) * 7 - (n.sub ? 5 : -4);
          title.forEach((t, li) => {
            g.append('text').attr('class', 'node-title').attr('x', cx(n)).attr('y', baseY + li * 14).attr('text-anchor', 'middle').text(t);
          });
          if (n.sub) g.append('text').attr('class', 'node-sub').attr('x', cx(n)).attr('y', baseY + (lines - 1) * 14 + 15).attr('text-anchor', 'middle').text(n.sub);
        });

        // Hover highlighting
        const edgeSel = svg.selectAll('.edge');
        const nodeSel = svg.selectAll('.node');
        nodeSel
          .on('mouseenter', function () {
            const id = this.getAttribute('data-id');
            const n = byId[id];
            container.classList.add('hovering');
            const nb = new Set([id]);
            edgeSel.classed('hl', function () {
              const hit = this.getAttribute('data-src') === id || this.getAttribute('data-dst') === id;
              if (hit) { nb.add(this.getAttribute('data-src')); nb.add(this.getAttribute('data-dst')); }
              return hit;
            });
            nodeSel.classed('hl', function () { return this.getAttribute('data-id') === id; })
                   .classed('nb', function () { return nb.has(this.getAttribute('data-id')); });
            if (n && n.desc) { tipInner.innerHTML = `<strong>${asTitle(n.title).join('')}</strong><br>${n.desc}`; tip.style.opacity = '1'; }
          })
          .on('mousemove', function (event) {
            const [mx, my] = d3.pointer(event, container);
            const flip = mx > container.clientWidth - 280;
            tip.style.transform = `translate(${flip ? mx - 270 : mx + 14}px, ${my + 14}px)`;
          })
          .on('mouseleave', function () {
            container.classList.remove('hovering');
            edgeSel.classed('hl', false);
            nodeSel.classed('hl', false).classed('nb', false);
            tip.style.opacity = '0';
            tip.style.transform = 'translate(-9999px, -9999px)';
          });

        // Flow animation sequence: explicit SEQ, else auto forward-cascade of data edges
        const resolveEdge = (s) => {
          if (typeof s.e === 'number') return s.e;
          if (s.from && s.to) return EDGES.findIndex((e) => e.src === s.from && e.dst === s.to);
          return -1;
        };
        let SEQ = (SPEC.seq || []).map((s) => ({ e: resolveEdge(s), t0: s.t0 })).filter((s) => s.e >= 0);
        if (!SEQ.length) {
          let t = 0;
          EDGES.forEach((e, i) => { if ((e.kind || 'data') === 'data') { SEQ.push({ e: i, t0: t }); t += HOP; } });
        }
        const TOTAL = SPEC.total || (Math.max(0, ...SEQ.map((s) => s.t0)) + HOP + 800);

        let playing = false, replayBtn = null;
        const pulseNode = (id) => {
          const sel = nodeSel.filter(function () { return this.getAttribute('data-id') === id; });
          sel.classed('anim-hl', true);
          setTimeout(() => sel.classed('anim-hl', false), 550);
        };
        const play = () => {
          if (playing) return;
          playing = true;
          if (replayBtn) replayBtn.disabled = true;
          const layer = svg.append('g');
          const steps = SEQ.map((s) => {
            const edge = EDGES[s.e];
            return { ...s, edge, len: edge.pathEl.getTotalLength(), dot: null, arrived: false };
          });
          const start = performance.now();
          const frame = (now) => {
            const t = now - start;
            steps.forEach((s) => {
              if (t < s.t0) return;
              const f = Math.min(1, (t - s.t0) / HOP);
              if (f >= 1) { if (s.dot) { s.dot.remove(); s.dot = null; } if (!s.arrived) { s.arrived = true; pulseNode(s.edge.dst); } return; }
              if (!s.dot) s.dot = layer.append('circle').attr('class', `flow-dot ${s.edge.kind || 'data'}`).attr('r', (s.edge.kind === 'event') ? 4 : 5);
              const p = s.edge.pathEl.getPointAtLength(d3.easeCubicInOut(f) * s.len);
              s.dot.attr('cx', p.x).attr('cy', p.y);
            });
            if (t < TOTAL) requestAnimationFrame(frame);
            else { layer.remove(); playing = false; if (replayBtn) replayBtn.disabled = false; }
          };
          requestAnimationFrame(frame);
        };

        // Legend
        const legend = document.createElement('div');
        legend.className = 'legend';
        legend.innerHTML = `
          <div class="legend-title">${SPEC.legendTitle || 'Legend'}</div>
          <div class="items">
            <span class="item"><span class="swatch data-line"></span><span>${dataLabel}</span></span>
            <span class="item"><span class="swatch event-line"></span><span>${eventLabel}</span></span>
            <button class="replay-btn" type="button" aria-label="Replay the flow animation">&#9654; Replay</button>
            <span class="hint">${SPEC.hint || 'Hover a component to trace its connections.'}</span>
          </div>`;
        container.appendChild(legend);
        container.appendChild(tip);
        replayBtn = legend.querySelector('.replay-btn');
        replayBtn.addEventListener('click', play);

        const prefersReduced = window.matchMedia && window.matchMedia('(prefers-reduced-motion: reduce)').matches;
        if (!prefersReduced && window.IntersectionObserver) {
          const io = new IntersectionObserver((entries) => {
            entries.forEach((en) => { if (en.isIntersecting) { io.disconnect(); play(); } });
          }, { threshold: 0.5 });
          io.observe(container);
        }
      } catch (err) {
        const pre = document.createElement('pre');
        pre.style.color = '#c0392b';
        pre.style.fontSize = '12px';
        pre.textContent = 'Failed to render architecture diagram: ' + (err && err.message ? err.message : err);
        container.appendChild(pre);
      }
    };

    if (document.readyState === 'loading') document.addEventListener('DOMContentLoaded', () => ensureD3(bootstrap), { once: true });
    else ensureD3(bootstrap);
  })();
</script>
{% endraw %}

이 방향이 인프라 회사에 주는 함의는 두 갈래입니다. 하나는 서빙입니다. 이미지 생성 모델이 문서와 인포그래픽, UI 목업을 안정적으로 뽑는 도구가 되면, 이런 모델을 고객 경계 안에서 돌려야 하는 수요가 생깁니다. 디자인 자산이나 내부 문서를 외부 API로 보낼 수 없는 고객이 대표적입니다. 다른 하나는 활용입니다. 고밀도 텍스트와 UI를 정확히 렌더링하는 능력은 사람이 손으로 만들던 인포그래픽과 목업 제작을 자동화할 여지를 엽니다.

다만 그 선택지가 실제로 유효해지는 시점은 모델이 발표될 때가 아니라, 가중치가 다운로드 가능해지고 우리가 그것을 우리 하드웨어에서 재현했을 때입니다. 그리고 지금 3.0은 그 앞 단계에 있습니다.

## ThakiCloud 관점: 이미지 모델을 온프렘에서 서빙한다는 것

가정을 해보겠습니다. Qwen-Image-3.0이 앞선 세대들처럼 오픈 가중치로 공개된다면, 확산 계열 이미지 생성 모델을 고객 온프렘 환경에서 서빙하는 과제가 현실이 됩니다. 이때 병목은 모델의 표현력이 아니라 GPU 메모리, 배치 처리 효율, 그리고 지연과 처리량을 맞추는 서빙 구성입니다. 파라미터 수와 아키텍처가 공개되지 않은 지금은 이 비용을 정확히 계산할 수 없고, 그래서 우리는 발표만으로 서빙 로드맵을 확정하지 않습니다.

ThakiCloud의 ai-platform은 이런 모델을 고객 환경에 올리기 위한 토대를 제공합니다. K8s와 Kueue 기반 GPU 스케줄링, 멀티테넌트 격리는 모델이 실제로 공개됐을 때 신속하게 검증에 착수할 수 있게 해줍니다. 이미지 생성 워크로드는 언어 모델과 부하 특성이 다르므로, 배치 크기와 GPU 배분을 이 특성에 맞춰 조정하는 일이 서빙 비용을 좌우합니다. 낮은 서빙 비용과 온프렘 주권이라는 강점은, 오픈 모델이 실제로 손에 들어왔을 때 비로소 값을 합니다.

활용 각도도 있습니다. 문서와 인포그래픽, UI 목업을 정확히 렌더링하는 능력은 에이전트가 다룰 수 있는 하나의 도구가 됩니다. ThakiCloud의 Agent-Native Cloud인 Paxis 관점에서 보면, 이런 생성 능력은 스킬로 감싸 정책 게이트와 감사 로그를 통과시키는 격리 실행의 대상이 됩니다. 다만 이 각도 역시 모델이 실제로 손에 들어온 다음의 이야기입니다.

## 한계 및 반론

이 글은 Qwen-Image-3.0을 깎아내리려는 것이 아닙니다. 4.5k 토큰짜리 복잡한 레이아웃을 한 번에 렌더링하고 10px 텍스트를 읽을 수 있게 그린다는 방향은, 실현된다면 이미지 생성의 실용성을 한 단계 끌어올립니다. Qwen Chat에서 이미 만져볼 수 있다는 점도 무의미하지 않습니다.

다만 균형을 위해 짚자면, 발표는 릴리즈가 아니고 데모는 벤치마크가 아니며 호스팅 가용성은 오픈 가중치가 아닙니다. 이 세 가지 구분이 흐려질 때 기술 판단이 마케팅에 끌려갑니다. 특정 실존 인물을 찾아 생성하는 기능이나 실제 UI를 그대로 시뮬레이션하는 능력은, 저작권과 초상, 브랜드 사칭 측면에서 별도의 검토가 필요한 대목이기도 합니다. 반대로 "완전 공개까지 관심을 끄자"는 태도도 지나칩니다. 올바른 자세는 그 사이에 있습니다. 흐름은 주시하되 로드맵은 검증된 사실 위에만 세우는 것. 발표와 공개가 빠르게 이어지는 지금, 이 구분을 지키는 규율이 인프라 회사의 신뢰를 만듭니다.

## 출처

- [Qwen-Image-3.0: Rich Content, Authentic Details, Deep Knowledge - Qwen Team Blog](https://qwen.ai/blog?id=qwen-image-3.0)
- [Qwen Image 3 Generator (third-party, access pending 표기)](https://qwenimage3.com/)
- [Qwen-Image GitHub (이전 세대 오픈웨이트 참고)](https://github.com/QwenLM/Qwen-Image)
