---
title: "예시를 빼니 더 잘합니다: 최신 모델을 위한 컨텍스트 엔지니어링의 새 규칙"
seo_title: "Claude Code 시스템 프롬프트 80% 삭감이 알려주는 것 | 컨텍스트 엔지니어링 새 규칙 | ThakiCloud"
seo_description: "Anthropic이 최신 세대 모델을 위해 Claude Code 시스템 프롬프트를 80% 넘게 줄였습니다. 예시와 금지 규칙을 덜어낼수록 더 똑똑한 모델은 오히려 잘합니다. 왜 예시가 이제는 족쇄가 되는지, 시스템 프롬프트를 어떻게 다시 써야 하는지, ThakiCloud 스킬 하네스 관점에서 정리했습니다."
excerpt: "모델이 똑똑해질수록 예시와 금지 목록은 도움이 아니라 족쇄가 됩니다. Anthropic이 시스템 프롬프트를 80% 줄인 이유와, 새 모델이 나올 때마다 프롬프트를 다시 다듬어야 하는 이유를 정리합니다."
date: 2026-07-25
tags:
  - 컨텍스트 엔지니어링
  - 프롬프트 엔지니어링
  - 시스템 프롬프트
  - Claude Code
  - 에이전트 하네스
  - LLM
  - 프롬프트 설계
  - 베스트 프랙티스
  - 개발 생산성
  - AI 코딩
categories: [tutorials]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/tutorials/context-engineering-smaller-system-prompts/"
---

시스템 프롬프트를 직접 쓰고 관리하는 개발자라면, 프롬프트에 예시와 규칙을 더 넣을수록 결과가 좋아진다는 감각을 한 번쯤 가지셨을 겁니다. 그런데 Anthropic이 최근 공개한 방향은 그 감각을 정면으로 뒤집습니다. 결론부터 말씀드리면, 모델이 충분히 똑똑해지면 예시와 금지 규칙은 도움이 아니라 오히려 성능을 깎는 족쇄가 되고, 그래서 프롬프트를 늘리는 것이 아니라 덜어내는 것이 새로운 베스트 프랙티스입니다. Anthropic은 이 원칙을 자기 제품에 그대로 적용해 Claude Code의 시스템 프롬프트를 80% 넘게 줄였습니다. 이 글은 왜 그런 일이 벌어졌는지, 그리고 우리가 프롬프트를 어떻게 다시 써야 하는지 정리합니다.

## 왜 읽어야 하나

이 글은 시스템 프롬프트를 설계하고 유지하는 개발자, 그리고 에이전트 하네스를 운영하는 플랫폼 담당자를 대상으로 합니다. 핵심 결론은 이렇습니다. 최신 세대 모델을 상대할 때는 예시를 붙이고 "이것도 하지 말고 저것도 하지 마라" 목록을 늘리는 대신, 원하는 결과의 맥락만 간결하게 전달하고 나머지는 모델의 판단에 맡기는 편이 더 좋은 결과를 냅니다. 이 사실을 알면 새 모델이 나올 때마다 프롬프트를 물려받아 계속 덧대는 습관을 멈추고, 오히려 프롬프트를 잘라내는 작업을 정기 점검 항목으로 삼게 됩니다.

## 개요

지난 몇 년 동안 프롬프트 엔지니어링의 상식은 "구체적으로, 많이"였습니다. 원하는 출력의 예시를 두세 개 붙이고, 하지 말아야 할 것을 목록으로 나열하고, 형식을 못 박는 것이 안정적인 결과를 얻는 길이라고 여겨졌습니다. 실제로 이전 세대 모델에서는 이 방식이 잘 통했습니다. 모델이 스스로 채우지 못하는 빈틈을 사람이 예시와 규칙으로 메워 주는 셈이었기 때문입니다.

그런데 모델이 세대를 거듭하며 똑똑해지자 그 빈틈이 줄어들었습니다. Anthropic은 최신 세대 모델을 대상으로 Claude Code의 시스템 프롬프트를 80% 넘게 덜어냈고, 코딩 평가에서 측정 가능한 성능 저하가 없었다고 밝혔습니다. 예시와 규칙을 대거 걷어냈는데도 결과가 나빠지지 않았다는 것입니다. 오히려 어떤 경우에는 예시가 모델을 특정 틀에 가두어 더 나은 답을 막고 있었다는 진단이 뒤따랐습니다.

## 왜 예시가 족쇄가 되는가

Anthropic 쪽 설명의 핵심은 간단합니다. 모델이 똑똑해질수록 더 적은 지시, 더 적은 제약, 더 적은 예시를 필요로 한다는 것입니다. 예시를 붙이면 모델은 그 예시를 "이런 모양을 원하는구나"로 해석하고 그 모양에 자기를 맞춥니다. 문제는 최신 모델이 그 예시보다 더 창의적일 때 생깁니다. 예시가 오히려 모델의 더 나은 답을 끌어내리는 천장이 되는 것입니다.

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
<div class="d3-arch" data-arch-root id="ringsmallersystemprompts-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 531, "height": 584, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 104, "y": 24, "w": 135, "h": 78, "title": ["구세대 접근", "예시 3개 + 금지 목록 +", "형식 못박기"]}, {"id": "B", "x": 103, "y": 185, "w": 138, "h": 68, "title": ["최신 세대 모델에", "적용하면?"]}, {"id": "C", "x": 199, "y": 350, "w": 120, "h": 62, "title": ["모델이 예시 틀에 갇힘", "더 나은 답이 막힘"]}, {"id": "D", "x": 24, "y": 350, "w": 120, "h": 62, "title": ["부정 규칙이", "결과 품질을 깎음"]}, {"id": "E", "x": 378, "y": 180, "w": 121, "h": 78, "title": ["신세대 접근", "원하는 맥락만 간결히 +", "판단은 모델에 위임"]}, {"id": "F", "x": 379, "y": 350, "w": 120, "h": 62, "title": ["모델이 맥락에 맞춰", "스스로 최적 출력 생성"]}, {"id": "G", "x": 199, "y": 490, "w": 120, "h": 62, "title": ["프롬프트를 덜어낸다", "새 모델마다 재점검"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [172, 102, 172, 185]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"예시가 창의성 제한\"", "curve": [[207, 253], [259, 304], [259, 304], [259, 350]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "\"금지 목록이 품질 저하\"", "curve": [[137, 253], [84, 304], [84, 304], [84, 350]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [439, 258, 439, 350]}, {"src": "C", "dst": "G", "kind": "data", "line": [259, 412, 259, 490]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[84, 412], [84, 451], [84, 451], [199, 497]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[439, 412], [439, 451], [439, 451], [319, 498]]}]});
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
      const container = document.getElementById('ringsmallersystemprompts-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ringsmallersystemprompts-1';
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

금지 규칙도 비슷한 함정을 갖습니다. "이것 하지 마라, 저것 하지 마라"를 길게 나열하면 최신 모델에서는 결과 품질이 오히려 떨어질 수 있습니다. Anthropic은 이제 딱딱한 금지 규칙으로 모델을 막기보다, 맥락을 통해 원하는 방향으로 이끄는 방식을 택한다고 밝혔습니다. 규칙으로 벽을 세우는 대신, 무엇을 원하는지의 맥락을 주고 모델이 그 안에서 판단하게 하는 것입니다.

그래서 새 모델이 나오면 프롬프트를 늘릴 것이 아니라 오히려 잘라내라는 조언이 따라옵니다. 이전 모델을 위해 쌓아 둔 예시와 규칙 중 상당수는 새 모델에게는 불필요한 짐이거나, 심하면 성능을 깎는 족쇄일 수 있기 때문입니다.

## 그렇다고 모든 규칙을 버리라는 뜻은 아닙니다

여기서 중요한 균형을 짚고 넘어가야 합니다. 이 조언은 가장 강력한 최신 세대 모델을 상대할 때의 이야기입니다. 더 저렴한 모델 등급이나, 매 호출마다 출력 형식이 정확히 같아야 하는 배치 작업에서는 이야기가 다릅니다. 형식이 흔들리면 안 되는 스케줄 산출물, 예를 들어 매일 같은 모양으로 나와야 하는 리포트나 JSON 계약에서는 여전히 결정론적 골격이 필요합니다.

ThakiCloud 내부에서도 이 두 축을 분리해서 다룹니다. 콘텐츠의 창의성이 산출물인 작업에서는 강한 모델에게 맥락만 주고 자유도를 넓히지만, 숫자와 열거값과 렌더링 형식은 모델이 아니라 결정론적 코드가 소유하도록 강제합니다. 다시 말해, 예시를 걷어내라는 조언과 형식을 코드로 고정하라는 규율은 서로 충돌하지 않습니다. 전자는 판단과 창작의 영역이고, 후자는 형식과 집계의 영역입니다. 두 영역을 구분하지 않고 하나의 프롬프트에 뭉뚱그리면, 강한 모델에게는 예시가 족쇄가 되고 약한 모델에게는 형식이 흔들리는 최악의 조합이 나옵니다.

## ThakiCloud 제품 적용 시사점

이 논의는 저희 Paxis 관점에서 곧바로 실무로 이어집니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, Skills와 Tools, Policies를 일급 리소스로 다루는 제어 평면입니다. 960개가 넘는 스킬을 BM25로 선택해 격리된 샌드박스에서 실행합니다. 여기서 각 스킬의 명세와 시스템 프롬프트가 바로 이 글이 말하는 컨텍스트 엔지니어링의 대상입니다.

이 글의 교훈을 Paxis 스킬 하네스에 옮기면 두 가지 실천이 나옵니다. 첫째, 강한 모델을 상대하는 스킬에서는 예시와 금지 목록을 최소화하고, 원하는 결과의 맥락과 경계만 간결하게 남깁니다. 얇은 하네스에 두꺼운 지식을 쌓되, 그 지식이 예시 나열이 아니라 실패에서 뽑아낸 판단 기준이 되도록 하는 것입니다. 둘째, 새 모델을 도입할 때 스킬 명세를 자동으로 물려받아 계속 덧대지 않고, 오히려 불필요해진 예시와 규칙을 덜어내는 점검을 함께 돌립니다. Anthropic이 새 모델마다 프롬프트를 트리밍하라고 조언한 것과 같은 맥락입니다.

인프라 관점의 ai-platform 렌즈에서도 이득이 있습니다. 시스템 프롬프트가 짧아지면 매 호출의 입력 토큰이 줄고, 이는 K8s 기반 멀티테넌트 서빙 환경에서 그대로 비용 절감으로 이어집니다. 프롬프트를 덜어내는 일은 품질과 비용을 동시에 개선하는 드문 작업입니다.

## 한계 및 반론

이 조언을 무비판적으로 받아들이면 위험합니다. 첫째, "예시를 빼라"는 강력한 최신 모델에 한정된 이야기이며, 능력이 낮은 모델이나 형식이 엄격해야 하는 작업에는 그대로 적용되지 않습니다. 둘째, 예시를 걷어낸 뒤 실제로 성능이 유지되는지는 반드시 평가로 확인해야 합니다. Anthropic이 코딩 평가에서 저하가 없었다고 밝힌 것도 측정을 거친 결과이지 직관만으로 내린 결정이 아닙니다. 프롬프트를 줄이면서 평가를 생략하면, 눈에 안 보이는 품질 저하를 놓칠 수 있습니다. 셋째, 이 방향은 특정 모델 계열의 특성에 기댄 조언이므로, 다른 벤더의 모델이나 오픈웨이트 모델에서도 같은 폭으로 통한다고 단정할 수 없습니다.

## 정리

컨텍스트 엔지니어링의 새 규칙을 한 문장으로 줄이면 이렇습니다. 최신 모델을 상대할 때는 프롬프트를 늘려 채우려 하지 말고, 덜어내서 모델의 판단에 맡기십시오. 예시와 금지 목록은 이전 세대에서는 안전장치였지만, 지금 세대에서는 더 나은 답을 막는 천장이 될 수 있습니다. 다만 이 조언은 강한 모델과 창작의 영역에 한정되며, 형식이 흔들리면 안 되는 작업에서는 여전히 결정론적 골격이 필요합니다. 다음에 새 모델을 도입하실 때, 프롬프트에 무엇을 더 넣을지 고민하기 전에 무엇을 뺄 수 있는지부터 점검해 보시길 권합니다. 그리고 뺀 뒤에는 반드시 평가로 확인하십시오. 그것이 이 변화를 안전하게 자기 것으로 만드는 방법입니다.

## 출처

- The new rules of context engineering for Claude 5 generation models, Anthropic (<https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models>)
- A Fireside Chat with Cat and Thariq from the Claude Code team, Simon Willison (<https://simonwillison.net/2026/Jul/21/cat-and-thariq/>)
