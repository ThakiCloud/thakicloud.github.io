---
title: "Opus급 성능을 3분의 1 가격에: Grok 4.5가 바꾸는 모델 경제학"
excerpt: "SpaceXAI가 공개한 Grok 4.5는 Opus 4.8과 GPT-5.5에 근접한 성능을 절반 이하 가격에 내놓았습니다. 벤치마크 몇 점 차이보다 태스크당 비용과 토큰 효율이 실무 선택을 좌우하는 국면이 왔습니다. 실제 공개 수치로 그 경제학을 뜯어보고, ThakiCloud의 모델 라우팅 전략에 어떤 의미인지 정리합니다."
tags:
  - model-economics
  - cost-optimization
  - model-routing
  - inference
  - llmops
date: 2026-07-09
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/grok-4-5-opus-class-cheap/"
categories:
  - llmops
---

지난 몇 분기 동안 프론티어 모델 경쟁은 벤치마크 점수 한두 점을 두고 벌어졌습니다. 그런데 2026년 7월 8일 SpaceXAI가 공개한 Grok 4.5는 질문 자체를 바꿔 놓았습니다. Opus 4.8이나 GPT-5.5와 성능이 근접한다면, 그다음에 남는 질문은 "누가 더 똑똑한가"가 아니라 "같은 일을 누가 더 싸게 끝내는가"입니다. 이 글은 인프라를 운영하며 모델 비용을 매달 결제하는 엔지니어링 리더와 AI 팀을 위한 것입니다. Grok 4.5의 공개 수치를 근거로 모델 경제학이 어떻게 이동하고 있는지, 그리고 그 흐름이 ThakiCloud 같은 멀티테넌트 추론 플랫폼에 무엇을 의미하는지 다룹니다.

## 개요: 벤치마크 경쟁에서 경제성 경쟁으로

Grok 4.5는 xAI 계열인 SpaceXAI가 만들었고, Grok Build와 Cursor, 그리고 xAI 콘솔에서 곧바로 쓸 수 있습니다. 일론 머스크는 이 모델을 "Opus급(Opus-class) 모델"이라고 표현했고, 실제로 일부 벤치마크에서 Opus 4.8과 GPT-5.5를 앞섰습니다. 하지만 이 릴리스에서 가장 눈에 띄는 대목은 성능이 아니라 가격표입니다. Grok 4.5는 입력 100만 토큰당 2달러, 출력 100만 토큰당 6달러입니다. 같은 급으로 비교되는 GPT-5.5와 GPT-5.6이 입력 5달러, 출력 30달러라는 점을 감안하면, 출력 기준으로 5분의 1 수준입니다.

이 가격 구조가 왜 중요한지는 실제 작업 단위로 내려가 보면 분명해집니다. 벤치마크 점수는 리더보드에서 의미가 있지만, 청구서를 결정하는 것은 태스크당 실제 소비 토큰과 단가입니다. 그리고 바로 이 지점에서 Grok 4.5는 격차를 크게 벌립니다.

## 이 모델은 무엇인가: 근접한 성능, 벌어진 비용

먼저 성능부터 정직하게 보겠습니다. Grok 4.5는 모든 벤치마크에서 우위에 있지 않습니다. 공개된 수치를 그대로 옮기면 다음과 같습니다.

- Terminal Bench 2.1에서 Grok 4.5는 83.3%로, GPT-5.5의 83.4%와 사실상 동률입니다.
- 코딩 에이전트 인덱스(Coding Agent Index)에서 76점을 기록해, Codex 환경의 GPT-5.5와 같은 수준입니다.
- DeepSWE 1.1에서는 53%로, GPT-5.5의 67%에 크게 뒤집니다.
- Artificial Analysis의 지능 지수(Intelligence Index)에서는 54점으로, GPT-5.5의 55점과 근소한 차이입니다.

정리하면 코딩과 터미널 에이전트 작업에서는 최상위권과 어깨를 나란히 하지만, 어려운 소프트웨어 엔지니어링 과제(DeepSWE)에서는 아직 격차가 있습니다. 즉 Grok 4.5는 "모든 것을 이기는 모델"이 아니라 "대부분의 실무 작업을 최상위권 근처에서 처리하는 모델"입니다.

여기서 경제성이 등장합니다. 아래는 실제 에이전트 작업 한 건을 기준으로 공개된 수치입니다.

- 태스크당 비용: Grok Build의 Grok 4.5는 2.49달러, Codex의 GPT-5.5는 5.07달러입니다.
- 태스크당 평균 소비 토큰: Grok 4.5는 190만 토큰, GPT-5.5는 620만 토큰입니다.

성능이 몇 퍼센트 차이라면, 비용은 두 배 이상, 토큰 소비는 세 배 이상 차이가 납니다. 벤치마크 표에서는 한 줄 차이지만, 하루에 수천 건을 처리하는 운영 환경에서는 이 차이가 매달 청구서의 자릿수를 바꿉니다.

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
<div class="d3-arch" data-arch-root id="0709grok45opusclasscheap-1"></div>
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
  .d3-arch svg { display: block; width: 100%; min-width: 760px; height: auto; font-family: inherit; }

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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 666, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "T", "x": 112, "y": 24, "w": 120, "h": 46, "title": "에이전트 작업 1건"}, {"id": "R", "x": 103, "y": 148, "w": 138, "h": 52, "title": "모델 선택"}, {"id": "G", "x": 199, "y": 292, "w": 120, "h": 62, "title": ["토큰 190만", "비용 2.49달러"]}, {"id": "P", "x": 24, "y": 292, "w": 120, "h": 62, "title": ["토큰 620만", "비용 5.07달러"]}, {"id": "S", "x": 112, "y": 432, "w": 120, "h": 62, "title": ["성능 근접", "일부 벤치 우위"]}, {"id": "D", "x": 112, "y": 572, "w": 120, "h": 62, "title": ["실무 판단:", "같은 결과, 절반 비용"]}], "edges": [{"src": "T", "dst": "R", "kind": "data", "line": [172, 70, 172, 148]}, {"src": "R", "dst": "G", "kind": "data", "label": "\"Grok 4.5\"", "curve": [[203, 200], [259, 246], [259, 246], [259, 292]], "off": "50%"}, {"src": "R", "dst": "P", "kind": "data", "label": "\"GPT-5.5\"", "curve": [[140, 200], [84, 246], [84, 246], [84, 292]], "off": "50%"}, {"src": "G", "dst": "S", "kind": "data", "curve": [[259, 354], [259, 393], [259, 393], [210, 432]]}, {"src": "P", "dst": "S", "kind": "data", "curve": [[84, 354], [84, 393], [84, 393], [133, 432]]}, {"src": "S", "dst": "D", "kind": "data", "line": [172, 494, 172, 572]}]});
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
      const container = document.getElementById('0709grok45opusclasscheap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0709grok45opusclasscheap-1';
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

## 왜 지금 이 흐름이 중요한가

이 릴리스가 던지는 신호는 단순합니다. 프론티어 성능이 상향 평준화되면서, 모델을 고르는 기준이 "최고 지능"에서 "충분한 지능 × 낮은 단가"로 이동하고 있다는 것입니다. The Decoder가 지적한 것처럼, 벤치마크 격차가 이렇게 좁혀진 상황에서는 그 격차 자체가 실무 선택에서 별로 중요하지 않을 수 있습니다.

이 관점은 저희가 이전 글에서 다룬 원칙과 정확히 맞닿아 있습니다. 대부분의 에이전트 업무는 창의적 난제가 아니라 분류, 요약, 라우팅, 렌더링 같은 정형화된 작업입니다. 이런 작업의 품질은 모델 지능보다 코드 가드레일이 좌우합니다. 그렇다면 정형화된 작업은 값싼 모델로 내리고, 진짜 어려운 추론에만 최상위 모델을 남기는 라우팅이 합리적입니다. Grok 4.5는 이 라우팅에서 "충분히 똑똑한 싼 티어"의 선택지를 하나 더 넓혀 줍니다.

동시에 주의할 점도 분명합니다. 태스크당 토큰 소비가 세 배 적다는 것은 단가만의 문제가 아니라 모델이 같은 작업을 더 적은 왕복으로 끝낸다는 뜻일 수 있습니다. 이는 지연 시간과 처리량에도 유리하게 작용합니다. 다만 이 수치는 특정 벤치 환경(Grok Build 대 Codex)에서 나온 값이므로, 실제 워크로드에서는 자체 측정으로 확인해야 합니다.

## ThakiCloud 제품 적용 시사점

ThakiCloud의 ai-platform은 K8s와 Kueue 기반 GPU 스케줄링 위에서 다양한 고객 환경에 모델을 서빙하는 멀티테넌트 추론 플랫폼입니다. Grok 4.5 같은 릴리스는 저희에게 두 가지 층위에서 의미가 있습니다.

첫째는 모델 라우팅 경제학입니다. 저희는 이미 작업 성격에 따라 모델 티어를 나눕니다. 탐색과 분류는 값싼 티어, 구현과 리뷰는 중간 티어, 아키텍처와 복잡한 추론은 최상위 티어로 라우팅합니다. 프론티어 근처 성능을 절반 이하 가격에 제공하는 모델이 등장하면, "충분히 똑똑한 싼 티어"의 커버리지가 넓어지고, 최상위 모델을 호출해야 하는 구간이 줄어듭니다. 그 결과 같은 품질을 더 낮은 총비용으로 유지할 수 있습니다. 핵심은 이 판단을 사람의 직관이 아니라 코드가 측정한 실제 산출물 품질로 내려야 한다는 것입니다.

둘째는 온프레미스와 소버린 환경의 비용 논리입니다. 국내 공공과 금융, 국정원 요구 대응처럼 데이터를 외부로 내보낼 수 없는 고객에게는 self-hosting이 전제 조건입니다. 이런 환경에서 GPU 자원은 유한하므로, 태스크당 토큰 소비가 적은 모델은 같은 하드웨어로 더 많은 동시 요청을 처리하게 해 줍니다. 즉 토큰 효율은 API 청구서만의 문제가 아니라 온프렘 클러스터의 실질 처리량 문제이기도 합니다. ai-platform이 경쟁력을 갖는 지점이 바로 낮은 서빙 비용이며, 토큰 효율이 좋은 모델은 이 강점을 곧바로 증폭시킵니다.

셋째로, 에이전트 관점에서는 Paxis와 연결됩니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬을 격리 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. 에이전트 경제성은 결국 "한 작업을 끝내는 데 드는 모델 비용"으로 수렴하는데, 저비용 고효율 모델의 등장은 에이전트 워크플로 한 건의 손익 구조를 개선합니다. 싼 서빙이 에이전트 경제성을 만든다는 명제가 여기서 다시 확인됩니다.

## 한계 및 반론

낙관만 하기 전에 반대편도 봐야 합니다. 먼저 이 수치들은 대부분 공급자와 초기 분석 기관이 제시한 값입니다. Terminal Bench나 Coding Agent Index 같은 지표는 실제 프로덕션 워크로드와 상관관계가 완벽하지 않습니다. DeepSWE 1.1에서 53% 대 67%라는 격차가 보여주듯, 어려운 과제에서는 여전히 최상위 모델이 우위입니다. 비용이 싸다는 이유로 어려운 추론까지 싼 모델에 몰아넣으면, 재시도와 실패 복구 비용이 오히려 늘어 총비용이 역전될 수 있습니다.

둘째, 태스크당 토큰 190만이라는 효율 수치는 특정 하니스(Grok Build)에서 측정된 것입니다. 다른 에이전트 프레임워크나 다른 프롬프트 구조에서는 재현되지 않을 수 있습니다. 벤더 발표 수치를 그대로 자기 청구서에 대입하는 것은 위험하며, 반드시 자체 골든셋으로 A/B 측정을 해야 합니다.

셋째, Grok 4.5는 오픈웨이트 모델이 아니라 API로 제공되는 폐쇄형 모델입니다. 따라서 데이터 주권이 핵심인 온프렘 환경에는 직접 배포할 수 없습니다. 소버린 고객에게는 여전히 self-hosting 가능한 오픈웨이트 모델이 필요하며, Grok 4.5의 경제성은 클라우드 API 워크로드에 한정된 이야기입니다.

결론적으로 Grok 4.5는 "프론티어 성능이 상향 평준화되면 다음 전장은 경제성"이라는 흐름을 상징적으로 보여주는 릴리스입니다. 벤치마크 몇 점을 좇기보다, 자기 워크로드에서 태스크당 비용과 토큰 효율을 실제로 측정하고, 그 결과로 모델을 라우팅하는 팀이 이 국면에서 이깁니다. 그리고 그 측정과 라우팅을 자동화하는 것이 바로 저희가 매일 밤 하는 일입니다.

## 출처

- [Introducing Grok 4.5 · Cursor](https://cursor.com/blog/grok-4-5)
- [SpaceXAI releases Grok 4.5, which Elon describes as an 'Opus-class model' · TechCrunch](https://techcrunch.com/2026/07/08/spacexai-releases-grok-4-5-which-elon-describes-as-an-opus-class-model/)
- [Grok 4.5 is so cheap compared to Fable 5 and GPT 5.5 that benchmark gaps may not matter much · The Decoder](https://the-decoder.com/grok-4-5-is-so-cheap-compared-to-fable-5-and-gpt-5-5-that-benchmark-gaps-may-not-matter-much/)
- [Grok 4.5 (high): Intelligence, Performance & Price Analysis · Artificial Analysis](https://artificialanalysis.ai/models/grok-4-5)
