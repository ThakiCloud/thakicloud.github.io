---
title: "Qwen3.8, 2.4조 파라미터 오픈웨이트 예고: 무엇이 확인됐고 무엇이 아직인가"
excerpt: "알리바바가 2.4조 파라미터 규모의 Qwen3.8을 곧 오픈웨이트로 공개하겠다고 예고했습니다. 프리뷰는 이미 테스트할 수 있지만 가중치도 벤치마크도 아직 공개되지 않았습니다. 발표에서 확인된 사실과 아직 주장에 머무는 부분을 구분해 정리했습니다."
seo_title: "Qwen3.8 2.4T 오픈웨이트 예고 분석: 확인된 사실과 미검증 주장"
seo_description: "알리바바 Qwen3.8은 2.4조 파라미터 멀티모달 모델로 오픈웨이트 공개를 예고했습니다. 프리뷰 가용 여부, 미공개 벤치마크, active 파라미터 미공개 문제를 짚고, Kimi K3와 이어지는 초대형 오픈 모델 경쟁이 온프렘 서빙과 주권 AI 수요에 주는 함의를 분석합니다."
date: 2026-07-20
last_modified_at: 2026-07-20
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
tags:
  - qwen
  - open-weight
  - frontier-model
  - alibaba
  - sovereign-ai
  - news
  - thakicloud
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ko/news/qwen3-8-2-4t-open-weight-preview/"
---

일요일 저녁 타임라인에 알리바바 Qwen 팀의 짧은 예고가 올라왔습니다. Qwen3.8을 곧 출시하며 오픈웨이트로 공개하겠다는 내용이었고, 파라미터 규모로 2.4조라는 숫자가 함께 붙었습니다. 며칠 전 Moonshot이 2.8조 파라미터의 Kimi K3를 실제로 공개한 직후라, 이번 예고는 "초대형 오픈 모델 경쟁이 주 단위로 벌어지고 있다"는 인상을 더 강하게 남겼습니다.

다만 예고는 릴리즈가 아닙니다. 이 글은 흥분을 걷어내고, 이번 발표에서 실제로 확인된 사실이 무엇이고 아직 주장에 머무는 부분이 무엇인지를 나눠 보려 합니다. ThakiCloud처럼 고객 인프라 위에서 모델을 서빙하는 입장에서는, 벤치마크 한 줄과 파라미터 숫자 하나에 로드맵을 걸 수 없기 때문입니다. 확인된 것과 아직 아닌 것을 구분하는 일 자체가 인프라 회사의 실무입니다.

## Qwen3.8, 무엇이 발표됐나

먼저 확인된 사실입니다. 알리바바 Qwen 팀은 2026년 7월 19일 Qwen3.8을 예고하면서 오픈웨이트 공개 방침을 밝혔습니다. 헤드라인 숫자는 2.4조 파라미터이고, 멀티모달 모델로 소개됐습니다. 여기까지가 발표 주체가 명시적으로 내놓은 부분입니다.

접근 경로도 확인됩니다. Qwen3.8-Max-Preview는 알리바바의 Token Plan과 Qoder, QoderWork를 통해 이미 테스트할 수 있는 상태로 공개됐습니다. 즉 지금 당장 만져볼 수 있는 것은 프리뷰 변형이며, 이는 알리바바 플랫폼에서 호스팅되는 서비스 형태입니다. 완전한 Qwen3.8은 이후 오픈웨이트로 공개될 예정이라고 회사는 밝혔지만, 구체적인 날짜는 약속하지 않았습니다.

여기서 두 가지를 분명히 구분해야 합니다. 첫째, 지금 쓸 수 있는 것은 "프리뷰"이지 "오픈웨이트"가 아닙니다. 둘째, "곧 공개"라는 표현은 시점을 담고 있지 않습니다. 이 두 가지가 흐릿하게 섞이면, 아직 다운로드할 수 없는 모델을 마치 손에 넣은 것처럼 착각하기 쉽습니다.

## 성능 주장은 어디까지 믿을 수 있나

가장 조심스럽게 읽어야 할 대목은 성능입니다. 알리바바는 Qwen3.8이 선도적인 프런티어 모델에 견줄 만하며 Anthropic의 Fable 5 다음가는 수준이라고 주장했습니다. X에서는 여기서 한발 더 나아가 "GPT-5.6보다 앞선다"는 반응까지 돌았습니다. 그러나 이 주장들은 현재 공개된 벤치마크로 뒷받침되지 않습니다. 발표와 함께 제시된 표준 평가 결과가 없기 때문입니다. 따라서 성능 관련 문구는 전부 발표자와 커뮤니티의 주장 [추정]으로 읽는 것이 안전합니다.

구조적으로도 미공개가 많습니다. 알리바바는 active 파라미터 수나 Mixture-of-Experts 구성을 밝히지 않았습니다. 이는 실무적으로 중요한 누락입니다. 2.4조이라는 숫자는 전체 크기일 뿐 매 토큰마다 실제로 도는 연산량을 말해주지 않습니다. 며칠 앞서 공개된 Kimi K3가 2.8조 전체 가운데 896개 전문가 중 16개만 활성화한다는 사실을 명시했던 것과 비교하면, Qwen3.8의 2.4조은 아직 서빙 비용을 가늠할 수 없는 헤드라인 숫자에 가깝습니다.

정리하면 아래와 같습니다.

| 항목 | 상태 |
|---|---|
| 발표·오픈웨이트 방침 | 확인됨 |
| 2.4조 파라미터(전체) | 확인됨(헤드라인) |
| 멀티모달 | 확인됨 |
| Max-Preview 테스트 가용 | 확인됨(호스팅) |
| 완전 가중치 공개 시점 | 미정 |
| 표준 벤치마크 | 미공개 |
| active 파라미터·MoE 구성 | 미공개 |
| "Fable 5 다음" 성능 | 미검증 주장 [추정] |

## 왜 지금 초대형 오픈 모델이 잇달아 나오나

이번 예고는 단독 사건이 아니라 흐름의 한 장면입니다. 한 매체는 Qwen3.8을 두고 알리바바가 Kimi K3를 쫓는 구도라고 표현했는데, 이 프레임이 상황을 잘 요약합니다. 며칠 사이에 2.8조과 2.4조이라는 초대형 오픈(혹은 오픈 예정) 모델이 연달아 등장하면서, 프런티어급 능력이 폐쇄형 API의 전유물이 아니게 되는 방향으로 무게추가 옮겨가고 있습니다.

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
<div class="d3-arch" data-arch-root id="en3824topenweightpreview-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 423, "height": 660, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 126, "y": 24, "w": 149, "h": 62, "title": ["초대형 오픈웨이트 프론티어 경쟁", "2026년 7월"]}, {"id": "B", "x": 221, "y": 164, "w": 170, "h": 62, "title": ["Kimi K3", "2.8조 · 실제 공개 · 벤치 공개"]}, {"id": "C", "x": 24, "y": 164, "w": 142, "h": 62, "title": ["Qwen3.8", "2.4조 · 예고 · 프리뷰만"]}, {"id": "D", "x": 246, "y": 304, "w": 120, "h": 62, "title": ["가중치 다운로드 가능", "7월 27일 예정"]}, {"id": "E", "x": 35, "y": 304, "w": 120, "h": 62, "title": ["가중치 미공개", "시점 미정"]}, {"id": "F", "x": 141, "y": 458, "w": 120, "h": 46, "title": "온프렘 서빙 검토 가능"}, {"id": "G", "x": 119, "y": 582, "w": 163, "h": 46, "title": "주권 AI · 빌드 대 바이 재계산"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[247, 86], [306, 125], [306, 125], [306, 164]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[154, 86], [95, 125], [95, 125], [95, 164]]}, {"src": "B", "dst": "D", "kind": "data", "line": [306, 226, 306, 304]}, {"src": "C", "dst": "E", "kind": "data", "line": [95, 226, 95, 304]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[306, 366], [306, 412], [306, 412], [236, 458]]}, {"src": "E", "dst": "F", "kind": "event", "label": "검증 유보", "curve": [[95, 366], [95, 412], [95, 412], [165, 458]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [201, 504, 201, 582]}]});
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
      const container = document.getElementById('en3824topenweightpreview-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'en3824topenweightpreview-1';
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

이 흐름이 인프라 회사에 주는 함의는 분명합니다. 외부 API를 쓸 수 없는 고객, 즉 데이터 주권이나 규제 때문에 모델을 자기 경계 안에서 돌려야 하는 고객에게 초대형 오픈 모델은 새로운 선택지를 엽니다. 다만 그 선택지가 실제로 유효해지는 시점은 모델이 예고될 때가 아니라 가중치가 다운로드 가능해지고, 우리가 그것을 우리 하드웨어에서 재현했을 때입니다.

## ThakiCloud 관점: 2.4조 모델을 온프렘에서 서빙한다는 것

가정을 해보겠습니다. Qwen3.8이 예고대로 오픈웨이트로 공개된다면, 2.4조 파라미터 멀티모달 모델을 고객 온프렘 환경에서 서빙하는 과제가 현실이 됩니다. 이때 병목은 모델의 똑똑함이 아니라 GPU 메모리, 인터커넥트, 그리고 전문가 오프로드와 양자화 전략입니다. active 파라미터와 MoE 구성이 공개되지 않은 지금은 이 비용을 정확히 계산할 수 없고, 그래서 우리는 발표만으로 서빙 로드맵을 확정하지 않습니다.

ThakiCloud의 ai-platform은 이런 초대형 오픈 모델을 고객 환경에 올리기 위한 토대를 제공합니다. K8s와 Kueue 기반 GPU 스케줄링, vLLM 계열 서빙, 멀티테넌트 격리는 모델이 실제로 공개됐을 때 신속하게 검증에 착수할 수 있게 해줍니다. 핵심은 준비된 파이프라인 위에서 "예고"를 "검증"으로 빠르게 전환하는 능력이지, 예고 단계에서 미리 흥분하는 것이 아닙니다. 낮은 서빙 비용과 온프렘 주권이라는 강점은, 오픈 모델이 실제로 손에 들어왔을 때 비로소 값을 합니다.

## 한계 및 반론

이 글은 Qwen3.8을 깎아내리려는 것이 아닙니다. 2.4조 파라미터 멀티모달 모델을 오픈웨이트로 공개하겠다는 방침 자체가 생태계에 긍정적인 신호이고, 실현된다면 큰 사건입니다. 프리뷰가 이미 테스트 가능하다는 점도 무의미하지 않습니다.

다만 균형을 위해 짚자면, 발표는 릴리즈가 아니고 프리뷰는 오픈웨이트가 아니며 자체 주장은 벤치마크가 아닙니다. 이 세 가지 구분이 흐려질 때 기술 판단이 마케팅에 끌려갑니다. 반대로 "완전 공개까지 관심을 끄자"는 태도도 지나칩니다. 올바른 자세는 그 사이에 있습니다. 흐름은 주시하되 로드맵은 검증된 사실 위에만 세우는 것. 초대형 오픈 모델이 몇 주 간격으로 예고되고 공개되는 지금, 이 구분을 지키는 규율이 인프라 회사의 신뢰를 만듭니다.

## 출처

- [Alibaba Launches Qwen 3.8 With 2.4 Trillion Parameters, Claims Near-Frontier Performance - MLQ News](https://mlq.ai/news/alibaba-launches-qwen-38-with-24-trillion-parameters-claims-near-frontier-performance/)
- [Alibaba Announces 2.4 Trillion-Parameter Open-Weight Qwen 3.8 - OfficeChai](https://officechai.com/ai/alibaba-qwen-3-8/)
- [Qwen3.8 Preview: 2.4T Params, Open Weights, Release - BuildFastWithAI](https://www.buildfastwithai.com/blogs/qwen3-8-preview-2-4t-params-open-weights-release)
- [Qwen3.8 Teases a 2.4 Trillion Parameter Open Model as Alibaba Chases Kimi K3 - Startup Fortune](https://startupfortune.com/qwen38-teases-a-24-trillion-parameter-open-model-as-alibaba-chases-kimi-k3/)
- [Qwen on X (announcement)](https://x.com/Alibaba_Qwen/status/2078759124914098291)
