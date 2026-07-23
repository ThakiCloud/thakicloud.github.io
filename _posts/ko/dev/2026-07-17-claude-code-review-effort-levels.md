---
title: "코드 리뷰에 노력 단계를 붙이다: Claude Code /code-review의 low부터 ultra까지"
excerpt: "Claude Code가 v2.1.101에서 /simplify를 /code-review로 바꾸면서 리뷰에 노력 단계를 붙였습니다. low와 medium은 확신 높은 소수의 지적만, high와 max는 넓은 커버리지와 불확실한 발견까지, ultra는 클라우드에서 여러 에이전트가 병렬로 검증하는 심층 리뷰입니다. 저희는 이 단계 설계가 왜 코드 리뷰의 비용과 품질을 나누는 올바른 방식인지, 그리고 이 발상이 Paxis의 스킬 하네스와 어떻게 맞물리는지 짚어봅니다."
tags:
  - claude-code
  - code-review
  - effort-levels
  - ultrareview
  - ai-coding
  - agent
  - developer-tools
  - cost-quality
  - paxis
  - dev
date: 2026-07-17
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/claude-code-review-effort-levels/"
categories:
  - dev
---

## 개요

코드 리뷰 도구를 고를 때 자주 놓치는 질문이 하나 있습니다. "이 변경에 얼마만큼의 리뷰가 필요한가"입니다. 오탈자 한 줄을 고친 커밋과 결제 로직을 갈아엎은 커밋에 같은 강도의 리뷰를 돌리는 것은 낭비이거나 부족이거나 둘 중 하나입니다. 대부분의 자동 리뷰 도구는 이 구분을 사용자에게 맡기지 않고 한 가지 강도로만 동작했습니다.

Claude Code는 v2.1.101에서 이 문제를 정면으로 다뤘습니다. 2026년 4월 11일 릴리스에서 기존 `/simplify` 명령을 `/code-review`로 바꾸고, 리뷰가 답을 내기 전에 얼마나 깊이 추론할지를 정하는 노력 단계(effort level) 플래그를 붙였습니다. low, medium, high, max, ultra의 다섯 단계이며, 단계마다 리뷰 자체가 다시 쓰입니다. 얕은 단계는 빠르고 확신이 높은 지적만 내놓고, 깊은 단계는 시간을 더 써서 엣지 케이스와 미묘한 회귀까지 훑습니다.

이 글은 AI 코딩 에이전트를 운용하는 ThakiCloud의 관점에서 이 설계를 읽습니다. 노력 단계가 왜 코드 리뷰의 비용과 품질을 나누는 올바른 축인지, 각 단계를 실무에서 언제 골라야 하는지, 그리고 이 발상이 저희가 운영하는 에이전트 플랫폼 Paxis의 스킬 하네스 및 검증 루프와 어떻게 겹치는지 순서대로 살펴봅니다. 아래에 인용한 소요 시간과 비용 수치는 모두 Anthropic이 공개한 문서와 릴리스 노트의 보고값이며, ThakiCloud가 직접 측정한 값이 아닙니다.

## 이 기능은 무엇인가

`/code-review`는 현재 작업 트리의 변경분을 읽고 문제를 찾아 보고하는 슬래시 명령입니다. 핵심 변화는 명령 뒤에 단계를 붙일 수 있다는 점입니다. `/code-review low`처럼 단계를 지정하면, 리뷰 엔진이 그 단계에 맞춰 탐색 범위와 추론 깊이를 조정합니다. 단계를 생략하면 기본값으로 동작합니다.

여기서 중요한 것은 단계가 단순히 "출력을 길게 하느냐 짧게 하느냐"가 아니라는 점입니다. 문서에 따르면 low와 medium은 소수의 확신 높은 발견만 반환하고, high와 max는 확실한 발견에 더해 불확실한 발견까지 함께 내놓습니다. 즉 얕은 단계는 정밀도(precision)를 우선하고, 깊은 단계는 재현율(recall)을 우선하도록 리뷰의 성격 자체가 바뀝니다. 이 구분은 리뷰를 받는 쪽의 심리와도 맞습니다. 작은 패치에서는 오탐이 섞인 긴 목록보다 확실한 몇 개가 낫고, 병합 직전에는 놓치는 것이 없는 편이 낫습니다.

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
<div class="d3-arch" data-arch-root id="decoderevieweffortlevels-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 526, "height": 790, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 199, "y": 24, "w": 120, "h": 62, "title": ["코드 변경분", "작업 트리 diff"]}, {"id": "B", "x": 190, "y": 164, "w": 138, "h": 52, "title": "노력 단계 선택"}, {"id": "C", "x": 374, "y": 308, "w": 120, "h": 62, "title": ["정밀도 우선", "확신 높은 소수 지적"]}, {"id": "D", "x": 199, "y": 308, "w": 120, "h": 62, "title": ["재현율 우선", "불확실 발견까지 포함"]}, {"id": "E", "x": 24, "y": 308, "w": 120, "h": 62, "title": ["클라우드 샌드박스", "병렬 에이전트 리뷰"]}, {"id": "F", "x": 374, "y": 448, "w": 120, "h": 62, "title": ["초 단위 응답", "작은 패치·설정 변경"]}, {"id": "G", "x": 199, "y": 448, "w": 120, "h": 62, "title": ["분 단위 탐색", "병합 직전·복잡한 상태"]}, {"id": "H", "x": 24, "y": 448, "w": 120, "h": 62, "title": ["각 발견 독립 검증", "5~10분·유료 티어"]}, {"id": "I", "x": 185, "y": 588, "w": 149, "h": 46, "title": "--comment: PR 인라인"}, {"id": "J", "x": 188, "y": 712, "w": 142, "h": 46, "title": "--fix: 작업 트리에 적용"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [259, 86, 259, 164]}, {"src": "B", "dst": "C", "kind": "data", "label": "low / medium", "curve": [[322, 216], [434, 262], [434, 262], [434, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "high / max", "line": [259, 216, 259, 308], "lx": 259, "ly": 258}, {"src": "B", "dst": "E", "kind": "data", "label": "ultra", "curve": [[196, 216], [84, 262], [84, 262], [84, 308]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "line": [434, 370, 434, 448]}, {"src": "D", "dst": "G", "kind": "data", "line": [259, 370, 259, 448]}, {"src": "E", "dst": "H", "kind": "data", "line": [84, 370, 84, 448]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[434, 510], [434, 549], [434, 549], [324, 588]]}, {"src": "G", "dst": "I", "kind": "data", "line": [259, 510, 259, 588]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[84, 510], [84, 549], [84, 549], [194, 588]]}, {"src": "I", "dst": "J", "kind": "data", "line": [259, 634, 259, 712]}]});
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
      const container = document.getElementById('decoderevieweffortlevels-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'decoderevieweffortlevels-1';
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

## 다섯 단계를 언제 쓰는가

단계 선택은 변경의 위험도와 남은 시간을 저울질하는 일입니다. 문서가 제시한 성격을 실무 감각으로 옮기면 다음과 같이 정리됩니다.

low와 medium은 빠른 정신 점검용입니다. 설정 파일을 바꾸거나 작은 패치를 올리기 전, 명백한 정합성 버그만 걸러내고 싶을 때 씁니다. 응답이 초 단위로 돌아오므로 커밋 직전에 습관처럼 돌려도 흐름을 끊지 않습니다.

high와 max는 병합 직전이나 복잡한 상태를 다루는 코드 경로에서 씁니다. 기능 브랜치를 main에 합치기 전, 혹은 동시성이나 트랜잭션처럼 미묘한 회귀가 숨기 쉬운 곳을 손봤을 때가 여기 해당합니다. 이 단계는 시간을 더 들여 가정을 검증하고 엣지 케이스를 뒤지므로, 확실한 지적 사이에 "이건 아닐 수도 있지만 확인해 보라"는 발견이 섞여 나옵니다. 이 불확실성을 노이즈로 볼지 안전망으로 볼지는 상황에 달렸습니다. 병합 직전이라면 안전망 쪽이 맞습니다.

ultra는 성격이 다른 도구입니다. 뒤에서 따로 다룹니다.

이 사다리를 한 문장으로 요약하면, 리뷰 강도를 변경의 위험도에 맞추라는 것입니다. 이는 저희가 스케줄 스킬을 운영할 때 지키는 원칙과 정확히 같습니다. 싸게 시작하고, 실패가 쌓이면 그 작업만 비싼 티어로 올립니다. 모든 리뷰를 최고 강도로 돌리는 것은 비용 낭비이고, 모든 리뷰를 최저 강도로 돌리는 것은 사고의 씨앗입니다.

## --comment와 --fix: 리뷰를 워크플로에 넣기

노력 단계와 별개로 두 플래그가 리뷰를 실제 작업 흐름에 끼워 넣습니다. `--comment`는 발견을 PR의 인라인 코멘트로 게시하고, `--fix`는 발견을 작업 트리에 직접 적용합니다.

```bash
# 병합 직전 넓은 커버리지로 리뷰하고 PR에 코멘트 + 로컬 적용
/code-review high --comment --fix

# 클라우드 심층 리뷰 후 결과를 작업 트리에 적용
/code-review ultra --fix
```

문서가 제시한 1인 개발 워크플로는 이렇습니다. `--comment --fix`를 함께 걸어 발견을 PR에 남기고 로컬에도 적용한 뒤, diff를 눈으로 확인하고 푸시합니다. 리뷰어를 기다리지 않고 첫 번째 패스를 자동으로 통과시키는 방식입니다. 다만 `--fix`가 코드를 건드린다는 점에서, 적용된 diff를 사람이 반드시 검토해야 합니다. 자동 적용은 검토의 대체가 아니라 검토를 위한 준비입니다.

## ultrareview: 클라우드 멀티에이전트 리뷰

ultra 단계는 로컬에서 도는 나머지 넷과 다릅니다. `/code-review ultra`를 실행하면 Claude Code가 저장소 상태를 묶어 원격 샌드박스로 업로드하고, 그곳에서 특화된 리뷰어 에이전트들이 코드를 병렬로 분석합니다. 각 에이전트는 서로 다른 종류의 문제에 집중하며, 발견은 개별적으로 독립 검증을 거칩니다. 문서에 따르면 실행에 5분에서 10분이 걸리고, Pro와 Max 구독자에게 3회의 무료 실행 이후에는 실행당 5달러에서 20달러의 비용이 붙습니다.

여기서 두 가지 설계 결정이 눈에 띕니다. 첫째, 리뷰를 단일 에이전트가 아니라 여러 특화 에이전트의 팬아웃으로 처리한다는 점입니다. 하나의 리뷰어가 모든 유형의 결함을 동등하게 잘 찾기는 어렵기 때문에, 문제 유형별로 시각을 나누는 편이 커버리지를 넓힙니다. 둘째, 각 발견을 독립적으로 검증한다는 점입니다. 팬아웃은 그 자체로 환각을 누적할 위험이 있으므로, 합치기 전에 검증 단계로 닫아야 합니다. ultra는 이 두 원칙을 제품 기능으로 구현한 사례입니다.

## ThakiCloud 제품 적용 시사점

이 기능의 설계 원칙은 저희가 에이전트 플랫폼을 운영하며 지켜온 것과 놀랍도록 겹칩니다. 두 제품의 렌즈로 나눠 봅니다.

**Paxis 렌즈.** Paxis는 ThakiCloud의 Agent-Native Cloud로, 스킬(Skills), 도구(Tools), 정책(Policies), 감사 로그(Audit Logs)를 일급 리소스로 다룹니다. `/code-review`가 던지는 질문은 Paxis의 스킬 하네스가 매일 푸는 질문과 같습니다. 어떤 작업에 어떤 강도의 에이전트를 붙일 것인가입니다. Paxis는 960개가 넘는 스킬을 BM25로 선택해 격리 샌드박스에서 실행하는데, 여기서도 노력 단계와 같은 발상이 작동합니다. 탐색과 조회 같은 가벼운 작업은 값싼 티어에, 아키텍처 판단과 검증 같은 무거운 작업은 비싼 티어에 배정합니다. ultra의 멀티에이전트 병렬 리뷰와 발견별 독립 검증은 Paxis가 팬아웃 결과를 검증 스테이지로 닫는 방식과 같은 구조입니다. 검증 없는 팬아웃은 환각을 누적하고, 검증 게이트가 이를 막습니다. 코드 리뷰가 하나의 에이전트 스킬로 격리 실행되고 그 결과가 정책 게이트와 감사 로그를 통과한다면, 그것이 바로 Paxis가 지향하는 운영 모델입니다.

**ai-platform 렌즈.** ultra가 리뷰를 클라우드 샌드박스로 오프로드하고 실행당 비용을 매긴다는 사실은, 에이전트 워크로드가 결국 GPU와 격리 실행 인프라 위에서 돈다는 것을 다시 확인시켜 줍니다. ThakiCloud의 ai-platform은 K8s와 Kueue 기반 GPU 스케줄링, 멀티테넌트 격리, 온프레미스 서빙을 제공합니다. 리뷰어 에이전트 함대를 병렬로 띄우는 워크로드는 정확히 이런 인프라가 필요한 종류의 작업입니다. 특히 소스 코드를 외부 클라우드에 업로드하기 꺼리는 조직이라면, 같은 멀티에이전트 리뷰 패턴을 자체 인프라 안에서 돌리는 선택지가 중요해집니다. 저비용 서빙과 격리 실행이 갖춰져야 에이전트 경제성이 성립한다는 점에서, 두 렌즈는 서로를 보완합니다.

## 한계 및 반론

노력 단계는 만능이 아닙니다. 몇 가지 반론을 정직하게 적습니다.

첫째, 단계 선택 자체가 사용자의 판단에 의존합니다. 위험도를 잘못 읽으면 중요한 변경을 low로 흘려보내거나 사소한 변경에 ultra를 낭비합니다. 도구가 축을 제공했을 뿐, 올바른 축 위의 위치를 정하는 것은 여전히 사람의 몫입니다.

둘째, high와 max가 내놓는 불확실한 발견은 양날의 검입니다. 안전망이 되기도 하지만, 오탐이 많으면 리뷰 피로를 부르고 결국 목록을 무시하게 만듭니다. 검증되지 않은 지적을 얼마나 신뢰할지는 팀의 규율에 달렸습니다.

셋째, ultra는 저장소를 원격 샌드박스로 업로드합니다. 소스 코드가 민감한 조직에는 이 자체가 도입 장벽입니다. 또한 실행당 5달러에서 20달러의 비용은 자주 돌리기에는 부담이며, 무료 3회 이후의 경제성을 팀이 스스로 계산해야 합니다.

넷째, 자동 `--fix`는 검토를 대체하지 않습니다. 적용된 diff를 확인하지 않고 푸시하면, 편해 보이는 자동화가 오히려 조용한 버그를 밀어 넣을 수 있습니다. 자동화는 사고를 대체하는 것이 아니라 보조하는 도구입니다.

그럼에도 노력 단계라는 발상은 옳은 방향입니다. 리뷰의 강도를 변경의 위험도에 맞추는 것은, 저희가 에이전트를 운영하며 배운 비용과 품질의 균형과 정확히 같은 원칙이기 때문입니다.

## 출처

- [Code Review - Claude Code Docs](https://code.claude.com/docs/en/code-review)
- [Claude Code Review: How to Use /code-review and Ultrareview - Fastio](https://fast.io/resources/claude-code-review-guide/)
- [Claude Code Effort Levels Explained - MindStudio](https://www.mindstudio.ai/blog/claude-code-effort-levels-explained)
