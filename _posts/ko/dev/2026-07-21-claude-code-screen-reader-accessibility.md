---
title: "Claude Code 스크린 리더 모드: 터미널 AI 코딩을 모두에게 여는 한 줄"
excerpt: "Claude Code가 시각 중심 터미널 UI를 순수 텍스트로 바꾸는 스크린 리더 모드를 추가했습니다. `claude --ax-screen-reader` 한 줄이 무엇을 바꾸는지, 어떤 원리로 동작하는지, 그리고 에이전트 인터페이스의 접근성이 왜 다키클라우드 같은 플랫폼에 중요한 문제인지 정리했습니다."
date: 2026-07-21
tags:
  - ClaudeCode
  - 접근성
  - 스크린리더
  - AI코딩
  - 개발생산성
  - Accessibility
  - Paxis
  - 포용적개발
author_profile: true
toc: true
toc_label: 접근성 모드 해부
published: true
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/claude-code-screen-reader-accessibility/"
---

![순수한 선형 텍스트 흐름으로 재구성된 터미널을 형상화한 추상 이미지]({{ '/assets/images/claude-code-screen-reader-accessibility-hero.webp' | relative_url }})

## 개요

터미널 기반 AI 코딩 도구는 대부분 화면을 아름답게 채우는 방향으로 진화해 왔습니다. 실시간으로 갱신되는 스피너, 색으로 구분된 diff, 박스로 감싼 권한 승인 프롬프트, 커서가 이리저리 움직이며 다시 그리는 진행 표시가 그렇습니다. 눈으로 화면을 보는 사용자에게는 이 시각적 밀도가 정보를 빠르게 전달하는 장점이 됩니다. 그러나 화면을 눈으로 읽지 않는 사용자, 즉 스크린 리더로 터미널을 읽는 시각장애 개발자에게는 정반대로 작동합니다. 끊임없이 다시 그려지는 화면은 스크린 리더가 "지금 무엇이 새로 나타났는지"를 판단하기 어렵게 만들고, 박스와 애니메이션은 순서 없는 소음으로 낭독됩니다.

Claude Code가 이 문제를 정면으로 다루는 스크린 리더 모드를 추가했습니다. `claude --ax-screen-reader` 한 줄이면 시각 중심 터미널 UI가 순수한 선형 텍스트로 바뀝니다. 화려한 렌더링 대신, 라벨이 붙은 줄을 순서대로 출력해서 VoiceOver, NVDA, JAWS 같은 스크린 리더가 위에서 아래로 자연스럽게 읽어 내려가게 합니다. 이 글은 이 모드가 정확히 무엇을 바꾸는지, 어떤 원리로 동작하는지, 그리고 에이전트 인터페이스의 접근성이 왜 지금 개발 생태계 전체가 함께 다뤄야 할 문제인지를 순서대로 살펴봅니다.

작은 플래그처럼 보이지만, 이 변화는 "터미널 AI 에이전트를 실제로 누가 쓸 수 있는가"라는 질문에 대한 답을 넓힙니다. 다키클라우드가 에이전트 네이티브 클라우드를 만들면서 계속 부딪히는 주제이기도 하므로, 단순 기능 소개를 넘어 인터페이스 설계 관점에서 함께 정리하겠습니다.

## 스크린 리더 모드란 무엇인가

일반적인 Claude Code 세션은 터미널을 하나의 캔버스처럼 다룹니다. 커서 위치를 옮기고, 이미 출력한 줄을 지우고 다시 그리며, 진행 상태를 실시간 애니메이션으로 보여 줍니다. 이 방식은 눈으로 화면을 훑는 사용자에게는 최적이지만, 스크린 리더에게는 최악의 입력입니다. 스크린 리더는 화면 버퍼가 바뀔 때마다 무엇을 읽어야 할지 결정해야 하는데, 화면이 매 프레임 다시 그려지면 같은 내용을 반복해서 읽거나, 정작 중요한 새 출력은 놓치기 쉽습니다.

스크린 리더 모드는 이 렌더링 모델 자체를 바꿉니다. 화면을 다시 그리는 대신, 새로 생긴 정보를 라벨이 붙은 한 줄로 순서대로 덧붙여 출력합니다. 예를 들어 어떤 도구가 실행될 때 "권한 요청", "도구 실행 중", "결과" 같은 명시적 라벨이 텍스트로 붙어 나옵니다. 스크린 리더는 이 선형 텍스트를 그냥 위에서 아래로 읽으면 되므로, 전체 대화를 처음부터 끝까지 따라가고, 도구 권한을 승인하고, 출력을 검토하는 모든 작업을 소리만으로 완결할 수 있습니다.

아래는 두 렌더링 경로가 어떻게 갈라지는지를 단순화한 흐름입니다.

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
<div class="d3-arch" data-arch-root id="creenreaderaccessibility-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 526, "height": 682, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 185, "y": 24, "w": 149, "h": 46, "title": "Claude Code 세션 시작"}, {"id": "B", "x": 190, "y": 148, "w": 138, "h": 68, "title": ["스크린 리더 모드", "활성화 여부"]}, {"id": "C", "x": 374, "y": 308, "w": 120, "h": 62, "title": ["화면 캔버스 갱신", "커서 이동·재렌더"]}, {"id": "D", "x": 112, "y": 308, "w": 120, "h": 62, "title": ["선형 텍스트 출력", "라벨 붙은 줄 추가"]}, {"id": "E", "x": 374, "y": 448, "w": 120, "h": 62, "title": ["시각 사용자에게", "고밀도 정보 전달"]}, {"id": "F", "x": 199, "y": 448, "w": 120, "h": 62, "title": ["스크린 리더가", "위에서 아래로 낭독"]}, {"id": "G", "x": 199, "y": 588, "w": 120, "h": 62, "title": ["대화·권한승인·출력검토", "소리만으로 완결"]}, {"id": "H", "x": 24, "y": 448, "w": 120, "h": 62, "title": ["주의 필요 시", "터미널 벨 신호"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [259, 70, 259, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "일반 모드", "curve": [[328, 214], [434, 262], [434, 262], [434, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "--ax-screen-reader", "curve": [[222, 216], [172, 262], [172, 262], [172, 308]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [434, 370, 434, 448]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[210, 370], [259, 409], [259, 409], [259, 448]]}, {"src": "F", "dst": "G", "kind": "data", "line": [259, 510, 259, 588]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[133, 370], [84, 409], [84, 409], [84, 448]]}]});
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
      const container = document.getElementById('creenreaderaccessibility-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'creenreaderaccessibility-1';
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

핵심은 "정보를 덜 준다"가 아니라 "같은 정보를 순서가 있는 텍스트로 준다"는 점입니다. 시각적 화려함을 걷어 내는 대신, 스크린 리더가 신뢰할 수 있는 단조롭고 예측 가능한 출력 스트림을 제공하는 것입니다.

## 켜는 법과 동작 방식

스크린 리더 모드를 켜는 방법은 두 가지입니다. 한 세션만 켜려면 실행할 때 플래그를 붙입니다.

```bash
claude --ax-screen-reader
```

이 플래그는 실제로 설치된 Claude Code에 존재합니다. 도움말에서 확인하면 다음과 같이 노출됩니다.

```bash
$ claude --help | grep ax-screen
  --ax-screen-reader                    Render screen-reader friendly output
```

셸에서 시작하는 모든 세션에 기본으로 적용하려면 환경 변수를 설정합니다.

```bash
export CLAUDE_AX_SCREEN_READER=1
```

이렇게 하면 그 셸에서 여는 Claude Code 세션은 별도 플래그 없이도 스크린 리더 친화 출력을 사용합니다. 공식 문서에 따르면 이 모드는 Claude Code v2.1.181 이상에서 동작하며, 그 이전 버전은 `--ax-screen-reader` 플래그를 오류로 거부합니다.

동작상의 세부 배려도 있습니다. 스크린 리더 모드에서는 Claude Code가 사용자의 주의가 필요할 때 터미널 벨을 울립니다. 특히 5초 이상 걸린 도구 실행이 끝났을 때 벨이 울리는데, 이는 긴 작업이 끝난 시점을 화면을 보지 않고도 알 수 있게 하는 신호입니다. 스크린 리더 사용자는 명령을 실행해 놓고 결과가 언제 도착했는지 화면으로 확인할 수 없으므로, 이 소리 신호가 상호작용의 리듬을 만들어 줍니다.

화면 확대기(screen magnifier)를 쓰는 저시력 사용자를 위한 별도 설정도 있습니다.

```bash
export CLAUDE_CODE_ACCESSIBILITY=1
```

이 값을 설정하면 Claude Code가 네이티브 터미널 커서를 계속 보이게 유지합니다. macOS 확대(Zoom) 같은 화면 확대기는 커서 위치를 따라 화면을 확대하는데, 도구가 커서를 숨기면 확대기가 초점을 잃습니다. 이 설정은 커서를 노출시켜 확대기가 사용자의 현재 위치를 정확히 추적하도록 돕습니다.

정리하면 접근성 지원은 세 갈래입니다. 스크린 리더를 위한 선형 텍스트 출력, 주의 환기를 위한 터미널 벨, 화면 확대기를 위한 커서 유지입니다. 각각 다른 보조 기술을 겨냥하며, 환경 변수로 독립적으로 켤 수 있습니다.

## 왜 지금 중요한가

이 기능이 의미 있는 첫 번째 이유는, 터미널 AI 에이전트가 개발자의 핵심 작업 도구로 빠르게 자리 잡고 있기 때문입니다. 코드를 읽고, 고치고, 명령을 실행하고, 결과를 검토하는 일상이 점점 이런 도구 안에서 일어납니다. 이 흐름에서 접근성이 빠지면, 시각장애나 저시력 개발자는 동료들이 쓰는 생산성 도구를 그대로 쓸 수 없게 됩니다. 도구의 능력이 아무리 뛰어나도, 그 능력에 접근하는 문이 좁으면 일부 개발자에게는 존재하지 않는 것과 같습니다.

두 번째 이유는 이 기능이 커뮤니티의 요청에서 출발했다는 점입니다. NVDA와 JAWS 같은 스크린 리더 지원을 요청하는 이슈가 공개 저장소에 올라왔고, 그 요구가 실제 릴리스로 이어졌습니다. 접근성 기능은 흔히 "나중에" 붙이는 항목으로 밀리기 쉬운데, 사용자 요청을 받아 우선순위를 올린 사례는 좋은 참고가 됩니다. 접근성은 소수의 특수 요구가 아니라, 도구를 쓸 수 있는 사람의 범위를 결정하는 설계 축입니다.

세 번째는 이 접근이 "선형 텍스트가 곧 견고한 인터페이스"라는 오래된 진리를 다시 확인시켜 준다는 점입니다. 순서가 명확하고, 라벨이 붙어 있고, 예측 가능한 텍스트 스트림은 스크린 리더에게만 좋은 것이 아닙니다. 로그로 남기기 좋고, 파이프로 넘기기 좋고, 자동화로 파싱하기 좋습니다. 접근성을 위해 만든 출력 모드가 결과적으로 스크립팅과 감사(audit)에도 유리한 형태라는 점은 우연이 아닙니다.

## ThakiCloud 제품 적용 시사점

다키클라우드는 **Paxis**라는 에이전트 네이티브 클라우드를 운용합니다. Paxis는 Skills와 Tools, Policies, Audit Logs를 일급 리소스로 다루며, 스킬 하네스가 다수의 스킬 중 적합한 것을 골라 격리된 샌드박스에서 실행하고, 모든 행동을 정책 게이트와 감사 로그로 통과시키는 제어 평면입니다. 에이전트가 사람과 상호작용하는 표면이 넓어질수록, 그 표면이 "누구에게나 접근 가능한가"라는 질문은 부가 기능이 아니라 설계의 기본 축이 됩니다.

Claude Code 스크린 리더 모드가 주는 교훈은 명확합니다. 에이전트 인터페이스의 접근성은 화면을 아름답게 만드는 것과 별개로, 같은 정보를 선형이고 라벨이 붙은 텍스트로 제공할 수 있느냐에 달려 있다는 것입니다. Paxis처럼 감사 로그와 정책 게이트를 일급으로 다루는 플랫폼은 이 점에서 구조적으로 유리합니다. 모든 에이전트 행동이 이미 라벨이 붙은 이벤트로 기록되므로, 그 이벤트 스트림을 사람이 읽는 선형 출력으로 재구성하는 일은 전혀 다른 렌더링 파이프라인을 새로 만드는 것이 아니라, 이미 가진 구조화된 로그를 표면으로 노출하는 문제에 가깝습니다.

또한 이 사례는 접근성 출력과 자동화 출력이 같은 뿌리에서 나온다는 점을 보여 줍니다. 스크린 리더가 읽기 좋은 텍스트는 로그 수집기가 파싱하기도 좋고, 감사 추적으로 남기기도 좋습니다. 다키클라우드가 에이전트 플랫폼에서 관측성과 감사를 중시하는 만큼, 접근 가능한 선형 인터페이스를 함께 설계하는 것은 두 목표를 동시에 만족시키는 방향입니다. 화려한 UI와 접근 가능한 텍스트를 대립 항으로 보지 않고, 구조화된 이벤트 스트림이라는 공통 기반 위에서 두 표현을 모두 렌더링하는 접근이 바람직합니다.

## 한계 및 반론

이 기능을 과대평가하지 않는 것도 중요합니다. 스크린 리더 모드는 접근성의 출발선이지 도착점이 아닙니다. 선형 텍스트로 출력한다고 해서 모든 상호작용이 자동으로 편해지는 것은 아니며, 긴 코드 블록이나 복잡한 diff를 소리만으로 이해하는 것은 여전히 인지 부담이 큰 작업입니다. 화면 없이 대규모 리팩터링의 전체 맥락을 파악하는 일은 이 모드가 있어도 쉽지 않습니다.

터미널 벨에 의존하는 주의 신호 역시 환경에 따라 편차가 있습니다. 어떤 터미널 에뮬레이터는 벨을 시각적 플래시로 바꾸거나 아예 무음으로 처리하도록 설정되어 있어서, 벨 신호가 의도대로 전달되지 않을 수 있습니다. 사용자가 자신의 터미널 설정을 함께 조정해야 최적 경험이 나옵니다.

마지막으로, 접근성 모드가 존재한다는 사실과 그것이 실무에서 충분히 검증되었다는 사실은 다릅니다. 실제 시각장애 개발자들이 다양한 스크린 리더와 워크플로에서 장기간 사용하며 피드백을 쌓아야 거친 부분이 드러나고 다듬어집니다. 이 모드가 v2.1.181에서 처음 동작한다는 점을 감안하면, 아직 초기 단계이며 앞으로의 개선 여지가 큽니다. 그럼에도 이런 기능이 기본 배포에 포함되었다는 사실 자체가, 접근성을 나중이 아니라 지금 다루겠다는 방향을 보여 주는 신호로서 의미가 있습니다.

## 출처

- Claude Code 접근성 공식 문서: [code.claude.com/docs/en/accessibility](https://code.claude.com/docs/en/accessibility)
- 기능 요청 이슈(NVDA/JAWS): [anthropics/claude-code #11002](https://github.com/anthropics/claude-code/issues/11002)
- 원 소스: [@ClaudeDevs 트윗](https://x.com/hjguyhan/status/2079435394727416168)
