---
title: "친구가 먼저 쓰고 선생님이 채점합니다: 투기 디코딩 쉽게 읽기"
seo_title: "투기 디코딩(speculative decoding) 쉬운 설명 - 원리부터 EAGLE, DFlash까지 | ThakiCloud"
seo_description: "LLM이 왜 느린지, 투기 디코딩이 어떻게 답을 바꾸지 않으면서 2배에서 6배까지 빨라지는지를 비유 하나로 끝까지 설명합니다. 채점 규칙, 미리 쓰는 개수의 손익분기, EAGLE과 DFlash 같은 최신 방식, 그리고 배치가 커지면 효과가 줄어드는 이유까지 다룹니다."
excerpt: "큰 모델은 글자 하나를 쓸 때마다 무거운 책을 전부 펼칩니다. 옆에 눈치 빠른 친구를 앉히면 그 책을 훨씬 덜 펼치게 됩니다. 답은 그대로인데 속도만 빨라지는 이유를 처음부터 짚습니다."
date: 2026-08-24
tags:
  - 투기 디코딩
  - speculative-decoding
  - 추론 최적화
  - EAGLE
  - DFlash
  - vLLM
  - 드래프트 모델
  - LLMOps
  - 입문
categories: [llmops]
author_profile: true
toc: true
toc_label: "목차"
toc_sticky: true
reading_time: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/speculative-decoding-easy-guide/"
---

챗봇이 글자를 한 자씩 또박또박 뱉는 걸 보면서 왜 저렇게 느린지 궁금하셨다면, 이 글 하나로 답과 해결책을 같이 가져가실 수 있습니다. 요즘 추론 엔진들이 쓰는 **투기 디코딩(speculative decoding)** 은 답을 한 글자도 바꾸지 않으면서 속도만 2배에서 6배까지 올리는 기술인데, 원리 자체는 초등학생도 이해할 수 있을 만큼 단순합니다. 눈치 빠른 친구에게 먼저 써 보게 하고 선생님은 채점만 합니다.

![LLM 추론 가속의 설계학, 추측 해독 표지 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-01.webp)
*이 글에 실린 슬라이드는 원문을 소스로 NotebookLM이 자동 생성한 것입니다. 글을 따라 읽으면서 그림으로 한 번 더 확인하시라고 중간중간 넣었습니다.*


## 글자 하나 쓰는 데 도서관을 한 번 다녀옵니다

큰 언어 모델이 문장을 만드는 방식은 생각보다 답답합니다. 한 글자를 정하면 그 글자를 다시 입력에 붙여서 처음부터 계산하고 그렇게 나온 다음 글자를 또 붙입니다. 백 글자짜리 답변이면 이 과정을 백 번 반복합니다.

여기까지는 많이 알려진 이야기인데, 진짜 문제는 그다음입니다. 한 번의 계산에서 시간을 잡아먹는 건 계산 자체가 아닙니다. 모델의 무게(가중치)를 메모리에서 계산 장치로 끌어오는 일이 훨씬 오래 걸립니다.

도서관에 비유해 보겠습니다. 선생님이 글자 하나를 쓰려면 서고에서 아주 무거운 책 수백 권을 꺼내 책상에 전부 펼쳐야 합니다. 그런데 정작 책을 읽는 시간은 눈 깜짝할 사이죠. 시간의 대부분은 책을 꺼내고 펼치는 데 들어갑니다. 그러고는 글자 하나를 쓰고 책을 도로 집어넣습니다. 다음 글자를 쓰려면 또 처음부터 꺼내야 합니다.

바보 같아 보이지만 달리 방법이 없죠. 다음 글자가 뭔지 알아야 그다음 글자를 계산할 수 있으니까요. 이 답답함을 전문 용어로는 메모리 대역폭 병목이라고 부릅니다. GPU의 계산 능력은 남아도는데 데이터를 나르는 통로가 좁아서 놀고 있는 상태입니다.

![자기회귀 생성이 메모리 대역폭에 막혀 연산 능력이 유휴 상태가 되는 구조 도식](/assets/images/speculative-decoding-easy-guide-slide-02.webp)
*계산 능력은 남는데 통로가 막혀 있죠. 투기 디코딩은 바로 이 남는 능력을 씁니다.*


## 눈치 빠른 친구를 옆에 앉힙니다

여기서 한 가지를 눈치채면 길이 열립니다. **모든 글자가 똑같이 어렵지는 않습니다.**

"동해물과 백두산이 마르고" 다음에 뭐가 올까요? "닳도록"입니다. 이건 고민할 필요가 없습니다. 괄호를 열었으면 언젠가 닫아야 하고 "그래서 저는"까지 썼으면 다음은 대체로 뻔합니다. 반면 사람 이름이나 낯선 전문 용어, 문장의 방향을 바꾸는 접속사 같은 건 정말로 잘 생각해서 골라야 합니다.

쉬운 글자까지 선생님이 무거운 책을 다 펼쳐 가며 쓸 이유는 없습니다. 그래서 옆자리에 **작고 빠른 모델**을 앉힙니다. 이 친구를 드래프트 모델이라고 부릅니다. 크기가 작으니 책도 얇습니다. 그래서 훨씬 빨리 씁니다. 대신 가끔 틀립니다.

이 친구가 먼저 다섯 글자쯤을 쭉 써 놓습니다. 그러면 선생님은 그 다섯 글자를 채점합니다. 맞으면 통과시키고 틀린 지점부터는 지우고 자기가 씁니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="ulativedecodingeasyguide-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 433, "height": 770, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "P", "x": 134, "y": 24, "w": 120, "h": 46, "title": "지금까지 쓴 문장"}, {"id": "D", "x": 134, "y": 148, "w": 120, "h": 62, "title": ["작고 빠른 친구", "글자 5개 초안"]}, {"id": "V", "x": 194, "y": 288, "w": 120, "h": 62, "title": ["크고 정확한 선생님", "5개를 한 번에 채점"]}, {"id": "A", "x": 281, "y": 560, "w": 120, "h": 46, "title": "맞은 데까지 통과"}, {"id": "X", "x": 106, "y": 428, "w": 120, "h": 46, "title": "틀린 자리부터 버림"}, {"id": "O", "x": 106, "y": 692, "w": 120, "h": 46, "title": "문장에 이어 붙임"}, {"id": "S", "x": 106, "y": 552, "w": 120, "h": 62, "title": ["그 한 자리는", "선생님이 직접"]}], "edges": [{"src": "P", "dst": "D", "kind": "data", "line": [194, 70, 194, 148]}, {"src": "D", "dst": "V", "kind": "data", "curve": [[220, 210], [254, 249], [254, 249], [254, 288]]}, {"src": "V", "dst": "A", "kind": "data", "curve": [[293, 350], [341, 389], [341, 513], [341, 560]]}, {"src": "V", "dst": "X", "kind": "data", "curve": [[215, 350], [166, 389], [166, 389], [166, 428]]}, {"src": "A", "dst": "O", "kind": "data", "curve": [[341, 606], [341, 653], [341, 653], [226, 694]]}, {"src": "X", "dst": "S", "kind": "data", "line": [166, 474, 166, 552]}, {"src": "S", "dst": "O", "kind": "data", "line": [166, 614, 166, 692]}, {"src": "O", "dst": "D", "kind": "event", "label": "\"다음 회차\"", "curve": [[122, 692], [46, 513], [46, 319], [134, 207]], "off": "50%"}]});
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
      const container = document.getElementById('ulativedecodingeasyguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ulativedecodingeasyguide-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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


![초안 작성, 병렬 검증, 거부 샘플링 3단계를 나눠 그린 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-03.webp)
*가벼운 초안, 한 번의 병렬 검증, 답을 지켜 주는 거부 샘플링. 이 세 가지가 전부죠.*

## 다섯 글자를 채점하는 값이 한 글자와 거의 같습니다

이 방법이 왜 이득인지가 이 글에서 제일 중요한 대목입니다. 채점도 결국 선생님이 하는데 뭐가 빨라지느냐, 자연스럽게 나오는 질문이죠.

답은 이렇습니다. **책을 한 번 펼친 김에 다섯 글자를 같이 확인하는 건 거의 공짜입니다.**

선생님이 한 글자를 쓸 때도 무거운 책을 전부 펼쳐야 하고 다섯 글자를 채점할 때도 똑같이 한 번만 펼치면 됩니다. 시간을 잡아먹던 건 책을 꺼내는 일이었으니까요. 책상에 펼쳐 놓은 상태에서 다섯 자리를 눈으로 훑는 건 원래 남아돌던 능력으로 처리됩니다. 앞에서 GPU의 계산 능력이 놀고 있다고 했는데, 투기 디코딩은 정확히 그 노는 능력을 쓰는 기술입니다.

그래서 이렇게 정리됩니다. 예전에는 다섯 글자를 얻으려면 무거운 책을 다섯 번 펼쳐야 했습니다. 이제는 얇은 책 다섯 번 더하기 무거운 책 한 번입니다. 얇은 책 다섯 번은 무거운 책 한 번보다 훨씬 쌉니다.

## 답이 바뀌지 않는다는 보장

여기서 걱정이 생깁니다. 친구가 쓴 글자를 그대로 쓰면 답이 나빠지는 것 아닐까요.

안 나빠집니다. 그리고 이게 이 기술의 진짜 매력입니다. 채점 규칙을 잘 만들어 두면 최종 결과물이 **선생님이 혼자 처음부터 끝까지 쓴 것과 통계적으로 완전히 똑같아집니다.**

규칙은 이렇습니다. 어떤 글자에 대해 친구가 매긴 확신을 q, 선생님이 매긴 확신을 p라고 합시다. 채점은 두 숫자를 비교합니다.

선생님이 그 글자를 쓸 마음이 친구보다 크거나 같으면(p가 q 이상이면) 무조건 통과입니다. 친구가 겸손했던 셈이니 문제가 없습니다. 반대로 친구가 너무 자신만만했다면(q가 p보다 크면), 그 차이만큼만 확률적으로 지웁니다. 정확히는 p를 q로 나눈 값의 확률로 통과시킵니다. 친구는 0.9의 확신으로 썼는데 선생님은 0.45밖에 확신이 없었다면 절반의 확률로만 통과하는 셈이죠.

그리고 지웠을 때가 중요합니다. 그냥 선생님이 평소대로 다시 뽑으면 안 됩니다. 이미 한 번 걸러진 상태라 확률이 기울어져 있기 때문입니다. 그래서 선생님의 확신에서 친구의 확신을 뺀 **남은 몫**에서 다시 뽑습니다. 음수가 되는 부분은 0으로 자릅니다. 그리고 전체를 다시 1이 되게 맞춘 뒤 뽑습니다.

이 두 가지를 지키면 수학적으로 원본과 같은 분포가 나옵니다. 품질을 속도와 맞바꾼 게 아니라, 그냥 공짜로 빨라진 겁니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="ulativedecodingeasyguide-2"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 734, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "S", "x": 97, "y": 24, "w": 149, "h": 62, "title": ["친구가 쓴 글자", "친구 확신 q, 선생님 확신 p"]}, {"id": "C", "x": 103, "y": 164, "w": 138, "h": 84, "title": ["선생님이 더", "쓰고 싶어했나?", "(p ≥ q)"]}, {"id": "OK", "x": 199, "y": 500, "w": 120, "h": 62, "title": ["통과", "그대로 사용"]}, {"id": "R", "x": 38, "y": 340, "w": 138, "h": 68, "title": ["p를 q로 나눈", "확률로 동전 던지기"]}, {"id": "X", "x": 24, "y": 500, "w": 120, "h": 62, "title": ["지우고 남은 몫에서", "선생님이 다시 뽑기"]}, {"id": "N", "x": 199, "y": 648, "w": 120, "h": 46, "title": "다음 글자 채점"}, {"id": "E", "x": 24, "y": 640, "w": 120, "h": 62, "title": ["이번 회차 종료", "여기서부터 다시 초안"]}], "edges": [{"src": "S", "dst": "C", "kind": "data", "line": [172, 86, 172, 164]}, {"src": "C", "dst": "OK", "kind": "data", "label": "\"예\"", "curve": [[221, 248], [275, 294], [275, 454], [266, 500]], "off": "50%"}, {"src": "C", "dst": "R", "kind": "data", "label": "\"아니오\"", "curve": [[141, 248], [107, 294], [107, 294], [107, 340]], "off": "50%"}, {"src": "R", "dst": "OK", "kind": "data", "label": "\"앞면\"", "line": [144, 408, 233, 500], "lx": 194, "ly": 450}, {"src": "R", "dst": "X", "kind": "data", "label": "\"뒷면\"", "curve": [[97, 408], [84, 454], [84, 454], [84, 500]], "off": "50%"}, {"src": "OK", "dst": "N", "kind": "data", "line": [259, 562, 259, 648]}, {"src": "X", "dst": "E", "kind": "data", "line": [84, 562, 84, 640]}]});
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
      const container = document.getElementById('ulativedecodingeasyguide-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ulativedecodingeasyguide-2';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

## 몇 글자를 미리 쓰게 할까요

친구에게 미리 쓰게 할 개수를 늘리면 무조건 좋을까요. 그렇지가 않습니다.

친구가 한 글자를 맞힐 확률을 70%라고 해 봅시다. 첫 글자가 통과할 확률은 70%입니다. 둘째 글자까지 살아남으려면 첫째도 맞고 둘째도 맞아야 하니 49%입니다. 셋째는 34%, 넷째는 24%로 뚝뚝 떨어집니다. 앞 글자가 지워지는 순간 뒷글자는 문맥이 달라져서 전부 버려지기 때문입니다.

그래서 열 글자를 미리 쓰게 해도 평균적으로 살아남는 건 서너 개뿐입니다. 나머지는 친구의 헛수고인데 그 헛수고에도 시간은 듭니다. 한 회차에 평균 몇 글자가 통과하는지를 나타내는 값을 τ(타우)라고 부르는데, 미리 쓰는 개수를 아무리 늘려도 τ는 어느 지점부터 거의 늘지 않습니다.

![드래프트 적중률에 따른 평균 통과 길이 곡선. 적중률이 낮으면 미리 쓰는 개수를 늘려도 곡선이 겹칩니다.](/assets/images/speculative-decoding-easy-guide-tau.webp)
*적중률이 40% 근처면 3개를 미리 쓰든 7개를 미리 쓰든 결과가 거의 같습니다. 개수를 늘려서 이득을 보려면 친구가 먼저 똑똑해져야 합니다.*

![지연 시간 공식 L = (T_draft + T_verify) / tau 를 시소로 표현한 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-04.webp)
*한 글자당 걸리는 시간은 초안 시간과 채점 시간을 합쳐 평균 통과 길이로 나눈 값. 결국 분모를 키우는 싸움입니다.*


이 그림이 지난 몇 년간의 연구 방향을 그대로 설명합니다. 미리 쓰는 개수를 늘리는 건 금방 한계에 부딪히니까, 사람들은 **친구를 더 잘 맞히게 만드는 쪽**으로 갔습니다.

## 친구를 만드는 방법이 계속 좋아졌습니다

처음에는 단순했습니다. 같은 계열의 작은 모델을 하나 더 데려와 앉히는 방식입니다. 추가 학습이 필요 없어서 편하고 2배에서 3배 정도 빨라지지만, 모델을 두 개 띄워야 하니 GPU 메모리를 그만큼 더 씁니다.

![독립 초안 모델 구조와 2배에서 3배 가속을 보여주는 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-05.webp)
*작은 모델을 하나 더 띄우는 가장 단순한 형태. 편한 대신 메모리를 두 배로 씁니다.*


그다음에 나온 **Medusa**는 친구를 따로 두는 대신 선생님 머리에 손을 여러 개 달았습니다. 각 손이 두 번째, 세 번째, 네 번째 글자를 동시에 예측합니다. 2.2배에서 3.6배가 나왔는데 약점이 있었습니다. 손끼리 서로 상의를 하지 않아서 뒤쪽 손일수록 엉뚱한 글자를 내놓습니다.

![Medusa와 MTP의 다중 헤드 예측 구조 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-06.webp)
*본체에 손을 여러 개 답니다. 손끼리 상의를 안 하는 게 한계죠.*


**MTP(다중 토큰 예측)** 는 그 손들을 완성된 모델에 나중에 붙이지 말고 처음 배울 때부터 같이 키우자는 접근입니다. 덤으로 본체 모델의 실력까지 좋아지는 효과가 있어서, 추론이 3배 빨라지는 건 오히려 부산물에 가깝습니다.

지금 가장 널리 쓰이는 건 **EAGLE** 계열입니다. 발상의 전환이 하나 있었습니다. 친구에게 "다음 글자가 뭘까"를 묻는 대신, "선생님 머릿속이 다음에 어떤 상태가 될까"를 묻습니다. 글자보다 머릿속 상태를 물려받는 편이 훨씬 잘 맞았습니다. 여기서 2.7배에서 3.5배가 나왔습니다. 뒤이어 나온 EAGLE-2는 친구가 자신 없어 할 때 여러 갈래를 동시에 준비해 두는 방식으로 3.05배에서 4.26배까지 올렸습니다. EAGLE-3는 다시 글자 예측으로 돌아오되 학습할 때부터 실전과 똑같은 조건으로 연습시켜서 최대 6.5배를 보고했습니다.

![EAGLE 계열이 숨겨진 상태를 기반으로 초안을 만드는 구조 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-07.webp)
*글자가 아니라 선생님 머릿속 상태를 물려받는 방식. 지금 가장 널리 쓰입니다.*


가장 최근에 나온 **DFlash**는 아예 다르게 접근합니다. 글자를 하나씩 순서대로 쓰는 대신 한 덩어리를 통째로 한 번에 만들어 냅니다. 확산 모델이 이미지를 흐릿한 상태에서 점점 또렷하게 만드는 것과 비슷한 방식을 글자 블록에 씁니다. 평균 4배에서 6배가 나옵니다. 친구를 더 크게 키울수록 잘 붙습니다.

![DFlash의 블록 병렬 확산 드래프팅을 표현한 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-08.webp)
*한 글자씩 계단을 오르는 대신 블록을 통째로 내려놓는 쪽으로.*


여기에 **DSpark**를 하나 더 얹으면 최근 흐름이 보입니다. 이 방식은 초안을 더 잘 만드는 데 매달리지 않습니다. 대신 지금 서버에 요청이 얼마나 몰려 있는지와 친구가 얼마나 자신 있어 하는지를 같이 보고 채점을 언제 할지 조절합니다. 한 사람이 체감하는 속도를 60%에서 85%까지 올렸는데, 대신 챙길 게 늘어서 구현이 복잡해집니다.

![DSpark의 신뢰도 기반 검증 스케줄링을 표현한 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-09.webp)
*초안을 더 잘 만드는 대신 채점 일정을 짭니다. 최근 연구가 옮겨 간 방향이죠.*

| 방식 | 초안을 만드는 법 | 한 회차 평균 통과 | 속도 |
|---|---|---|---|
| 별도 작은 모델 | 한 글자씩 순서대로 | 약 3.6 | 2배에서 3배 |
| Medusa | 여러 손이 동시에 | 3.0에서 3.5 | 2.2배에서 3.6배 |
| EAGLE-3 | 한 글자씩 순서대로 | 5에서 7.5 | 최대 6.5배 |
| DFlash | 블록을 통째로 | 4에서 8 | 6배 이상 |
| DSpark | 반자기회귀 + 채점 일정 조절 | 3.1에서 6.2 | 사용자 체감 1.6배에서 1.85배 |

## 손님이 많아지면 효과가 줄어듭니다

여기서 많이들 걸려 넘어지는 지점이 있습니다. 논문에 적힌 6배를 기대하고 켰는데 실제 서비스에서는 별로 빨라지지 않는 경우입니다. 대개 이유는 하나입니다.

도서관에 나 혼자 있을 때는 책을 꺼내는 시간이 정말 아깝습니다. 그런데 손님이 백 명 줄을 서 있으면 이야기가 달라집니다. 책을 한 번 꺼내서 백 명 몫을 한꺼번에 처리하니까, 책 꺼내는 비용은 이미 백 명이 나눠 부담하고 있습니다. 아까울 게 없어진 겁니다.

![배치 크기가 커지면 가속 효과가 떨어지는 곡선 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-11.webp)
*동시 요청이 늘수록 곡선이 내려앉습니다. 오른쪽 빗금 구간이라면 켜도 얻는 게 거의 없죠.*


투기 디코딩은 **동시 사용자가 적을 때** 가장 크게 이깁니다. 사용자가 많아져서 GPU 계산 능력이 이미 꽉 찬 상태라면, 남는 능력을 쓰겠다는 이 기술의 전제 자체가 사라집니다. 심하면 초안 만드는 비용만 더해져서 손해가 나기도 합니다.

그래서 판단 기준은 이렇게 잡으면 됩니다. 한 사람의 응답이 얼마나 빨리 오는지가 중요한 서비스라면 켤 만합니다. 대화형 챗봇, 코딩 도우미, 여러 단계를 거치며 스스로 판단하는 에이전트가 여기 해당합니다. 반대로 밤새 대량으로 문서를 처리하는 배치 작업이라면 굳이 켜지 않아도 됩니다.

## 직접 켜 보기

요즘 주요 추론 엔진은 전부 지원합니다. vLLM, SGLang, llama.cpp, MLX 모두 설정 한두 줄이면 됩니다. SGLang에서 DFlash 방식으로 띄우는 예시입니다.

```bash
python -m sglang.launch_server \
  --model-path <본체 모델 경로> \
  --speculative-algorithm DFLASH \
  --speculative-draft-model-path <드래프트 모델 경로> \
  --speculative-num-draft-tokens 5
```

켠 다음에는 로그에서 두 숫자를 확인하시면 됩니다. 하나는 적중률(acceptance rate)이고 다른 하나는 회차당 평균 통과 길이입니다. 통과 길이가 2를 못 넘고 있다면 친구와 선생님의 궁합이 안 맞는 상태라, 미리 쓰는 개수를 늘리기보다 드래프트 모델을 바꾸는 쪽이 맞습니다.

## 켜기 전에 확인할 순서

저희가 GPU 서빙을 운영하면서 비싸게 배운 게 하나 있습니다. **투기 디코딩은 마지막에 켜는 것이지 처음에 켜는 게 아닙니다.**

2026년 8월에 저희 B200 장비에서 서빙 설정만 바꿔 가며 처리량을 측정한 적이 있습니다. 같은 모델, 같은 GPU, 같은 엔진인데 설정 두 개 때문에 단일 스트림 처리량이 18.8배 차이가 났습니다. 컴파일이 꺼져 있었고, 동시에 처리할 수 있는 요청 수가 기본값 32에 묶여 있었습니다. 초당 7.4 토큰이던 게 138.8 토큰이 됐습니다.

이 상태에서 투기 디코딩을 켜면 어떻게 될까요. 6배 빨라진다는 기술로 18.8배 손해를 메우려고 애쓰는 셈입니다. 순서가 뒤바뀐 겁니다. 기본 설정을 먼저 바로잡고, 그 위에서 투기 디코딩을 얹어야 이 기술이 원래 낼 수 있는 몫을 냅니다.

저희 추론 제품인 **Metis**는 이런 서빙 설정을 테넌트가 일일이 만지지 않아도 되게 다루는 게 일입니다. 그리고 이 기술이 특히 잘 맞는 곳이 **Paxis** 쪽입니다. 에이전트는 한 번의 요청을 처리하면서 도구를 부르고 결과를 읽고 다시 판단하기를 여러 번 반복하는데, 이때 동시 사용자 수는 대체로 적고 한 스텝의 지연이 그대로 체감 속도가 됩니다. 앞에서 말한 "손님이 적을 때 가장 크게 이긴다"는 조건에 정확히 들어맞습니다.

투기 디코딩을 이미 한 번 시험해 보고 접으셨다면, 저희가 같은 경험을 하고 다시 열어 본 기록도 함께 보시면 도움이 되실 겁니다. [투기 디코딩이 느려진 게 아니라 lookup이 안 맞았던 겁니다](/tech-blog/ko/llmops/speculative-decoding-lookup-vs-drafter/)에서 방식 선택 하나로 11.9배가 갈린 과정을 정리해 두었습니다. [DFlash 블록 확산 드래프팅](/tech-blog/ko/llmops/dflash-speculative-decoding-vllm/)과 [vLLM에서 EAGLE 운영하기](/tech-blog/ko/llmops/vllm-eagle-speculative-decoding-production/)도 실제 설정 값을 담고 있습니다.

## 정리

투기 디코딩을 한 문장으로 줄이면 이렇습니다. 빠른 친구가 먼저 써 보고, 느리지만 정확한 선생님이 한꺼번에 채점합니다. 채점 규칙을 제대로 만들어 두면 답은 한 글자도 달라지지 않습니다.

![방식별 초안 패턴, 평균 통과 길이, 보고된 가속 배수를 정리한 비교표 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-10.webp)
*지금까지 나온 방식을 한 장으로 모으면 이렇습니다. 숫자는 각 연구가 보고한 값입니다.*


기술의 흐름도 짚어 볼 만합니다. 처음에는 "친구를 어떻게 똑똑하게 만들까"가 전부였습니다. 별도 모델에서 시작해 선생님 머리에 손을 달았고, 글자 대신 머릿속 상태를 물려주는 데까지 왔습니다. 그런데 최근 연구들을 보면 질문이 바뀌고 있습니다. 여러 사용자가 몰릴 때 **채점을 언제 어떻게 몰아서 할 것인가**, 그러니까 초안 만들기보다 검증 일정 짜기가 더 어려운 문제로 올라오고 있습니다. 이 부분이 다음 몇 년의 싸움터가 될 것 같습니다.


![원문 출처와 시각 콘셉트를 밝힌 마무리 슬라이드](/assets/images/speculative-decoding-easy-guide-slide-12.webp)
*슬라이드의 출처와 시각 콘셉트.*

이 글의 원본 설명은 Leonie Monigatti의 [Speculative Decoding](https://leoniemonigatti.com/blog/speculative-decoding.html)입니다. 수식과 논문 링크가 필요하시면 원문을 함께 보시길 권합니다.
