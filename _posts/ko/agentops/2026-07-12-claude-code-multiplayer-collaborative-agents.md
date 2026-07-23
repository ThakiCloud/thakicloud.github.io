---
title: "코딩 에이전트가 서로 대화하기 시작할 때: 멀티플레이어 Claude Code와 협업 에이전트의 설계"
seo_title: "멀티플레이어 Claude Code - 협업 코딩 에이전트 설계 분석 - Thaki Cloud"
seo_description: "여러 사람과 여러 Claude가 같은 터미널에서 서로 대화하는 멀티플레이어 Claude Code를 계기로, 협업 코딩 에이전트의 설계 과제를 분해하고 멀티에이전트를 일급 리소스로 다루는 ThakiCloud Paxis 관점에서 검증합니다."
excerpt: "한 사람이 한 에이전트를 쓰던 구조에서, 여러 사람과 여러 에이전트가 같은 작업 공간에서 서로 대화하는 구조로 넘어가고 있습니다. 멀티플레이어 Claude Code를 계기로 협업 에이전트의 동시성·충돌·신뢰 경계 문제를 짚고 ThakiCloud 운영 관점에서 검증합니다."
date: 2026-07-12
tags:
  - claude-code
  - multi-agent
  - collaboration
  - agentops
  - paxis
  - orchestration
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/claude-code-multiplayer-collaborative-agents/"
---

![고립된 에이전트에서 연결된 협업 에이전트 네트워크로 향하는 개념도]({{ '/assets/images/claude-code-multiplayer-collaborative-agents-hero.webp' | relative_url }})

코딩 에이전트를 팀에서 쓰다 보면 이상한 벽에 부딪힙니다. 에이전트는 나 혼자만의 것입니다. 옆자리 동료가 같은 저장소를 만지고 있어도, 각자의 Claude는 서로의 존재를 모릅니다. 사람은 슬랙과 화면 공유로 협업하는데, 정작 우리를 대신해 코드를 만지는 에이전트들은 각자의 섬에 갇혀 있습니다. 최근 공개되어 화제가 된 **멀티플레이어 Claude Code**는 바로 이 벽을 겨냥합니다. 같은 터미널을 여러 사람이 함께 쓰고, 각자의 Claude를 서로 연결해 에이전트끼리 대화하게 만드는 실험입니다. 이 글은 이 시도를 계기로 협업 코딩 에이전트가 풀어야 할 설계 과제를 분해하고, 멀티에이전트와 정책을 일급 리소스로 다루는 ThakiCloud의 운영 관점에서 이 방향이 무엇을 시사하는지 검증합니다.

## 개요

지금까지 코딩 에이전트의 기본 단위는 **1인 1에이전트**였습니다. Claude Code는 내 터미널에 살면서 내 코드베이스를 이해하고 내 명령을 받습니다. 이 구조는 개인 생산성에는 훌륭하지만, 소프트웨어가 애초에 팀 작업이라는 사실과는 어긋납니다. 개발자 도라 로하니(Dorsa Rohani)가 공개한 멀티플레이어 Claude Code는 이 전제를 뒤집습니다. 발표에 따르면 이 도구는 두 가지를 가능하게 합니다. 첫째, 여러 사람이 **같은 터미널 세션**을 공유하며 함께 작업합니다. 둘째, 각자의 Claude를 **서로 연결해 에이전트끼리 대화**하도록 만듭니다.

주목할 점은 이것이 단발성 장난감이 아니라 더 큰 흐름의 한 조각이라는 것입니다. 비슷한 시기에 여러 사람이 여러 코딩 에이전트를 하나의 작업 공간에 모으는 프로젝트들이 잇따라 등장했습니다. 팀 우선 멀티에이전트 오케스트레이션을 표방한 `oh-my-claudecode`, Codex와 Claude를 비롯한 여러 에이전트를 한 워크스페이스에서 섞어 쓰는 `claude_codex_bridge`, 여러 에이전트 세션을 집계하는 협업 워크스페이스 `codeg` 같은 도구들이 그 예입니다. 방향은 하나로 수렴합니다. **에이전트를 고립된 단말이 아니라 서로 통신하는 참여자로 다루는 것**입니다.

이 흐름이 왜 중요한지는 명확합니다. 실제 개발 조직에서 가치 있는 일의 상당 부분은 조율에서 나옵니다. 누가 어느 파일을 만지는지, 이 변경이 저 모듈을 깨뜨리지 않는지, 리뷰어가 무엇을 걱정하는지 같은 것들입니다. 에이전트가 이 조율에 참여하지 못하면, 우리는 결국 에이전트가 각자 만든 결과물을 사람이 손으로 다시 봉합해야 합니다. 협업 에이전트는 그 봉합 비용을 줄이려는 시도입니다.

## 멀티플레이어 코딩 에이전트란 무엇인가

멀티플레이어라는 단어는 게임에서 왔지만, 여기서는 두 개의 서로 다른 축을 동시에 가리킵니다. 하나는 **사람 대 사람** 축입니다. 여러 개발자가 같은 세션을 공유하며 하나의 에이전트에 함께 지시를 내리는 형태입니다. 다른 하나는 **에이전트 대 에이전트** 축입니다. 각자의 에이전트가 서로 메시지를 주고받으며 작업을 나누는 형태입니다. 멀티플레이어 Claude Code가 흥미로운 이유는 이 두 축을 함께 다룬다는 데 있습니다.

아래 도표는 기존의 고립된 구조와 협업 구조의 차이를 보여줍니다.

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
<div class="d3-arch" data-arch-root id="layercollaborativeagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1001, "height": 805, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 370, "h": 432, "label": "기존: 1인 1에이전트 (고립)", "lx": 36, "ly": 42}, {"x": 589, "y": 24, "w": 380, "h": 749, "label": "협업: 공유 세션 + 연결된 에이전트", "lx": 601, "ly": 42}], "nodes": [{"id": "직접1", "x": 62, "y": 63, "w": 120, "h": 46, "title": "개발자 A"}, {"id": "클로드1", "x": 62, "y": 201, "w": 120, "h": 62, "title": ["Claude A", "(A의 컨텍스트만)"]}, {"id": "직접2", "x": 237, "y": 209, "w": 120, "h": 46, "title": "개발자 B"}, {"id": "클로드2", "x": 149, "y": 355, "w": 120, "h": 62, "title": ["Claude B", "(B의 컨텍스트만)"]}, {"id": "사람A", "x": 627, "y": 63, "w": 120, "h": 46, "title": "개발자 A"}, {"id": "세션", "x": 714, "y": 209, "w": 120, "h": 46, "title": "공유 터미널 세션"}, {"id": "사람B", "x": 812, "y": 63, "w": 120, "h": 46, "title": "개발자 B"}, {"id": "에이전트A", "x": 763, "y": 363, "w": 120, "h": 46, "title": "Claude A"}, {"id": "에이전트B", "x": 812, "y": 548, "w": 120, "h": 46, "title": "Claude B"}, {"id": "공유상태", "x": 762, "y": 672, "w": 121, "h": 62, "title": ["공유 작업 상태", "(저장소 · 진행 상황)"]}, {"id": "기존", "x": 432, "y": 63, "w": 120, "h": 46, "title": "기존"}, {"id": "협업", "x": 432, "y": 209, "w": 120, "h": 46, "title": "협업"}], "edges": [{"src": "직접1", "dst": "클로드1", "kind": "data", "line": [122, 109, 122, 201]}, {"src": "직접2", "dst": "클로드2", "kind": "data", "curve": [[297, 255], [297, 309], [297, 309], [244, 355]]}, {"src": "클로드1", "dst": "클로드2", "kind": "event", "label": "단절", "curve": [[122, 263], [122, 309], [122, 309], [174, 355]], "off": "50%"}, {"src": "사람A", "dst": "세션", "kind": "data", "curve": [[687, 109], [687, 155], [687, 155], [748, 209]]}, {"src": "사람B", "dst": "세션", "kind": "data", "curve": [[872, 109], [872, 155], [872, 155], [803, 209]]}, {"src": "세션", "dst": "에이전트A", "kind": "data", "curve": [[789, 255], [823, 309], [823, 309], [823, 363]]}, {"src": "세션", "dst": "에이전트B", "kind": "data", "curve": [[736, 255], [648, 386], [648, 502], [812, 552]]}, {"src": "에이전트A", "dst": "에이전트B", "kind": "data", "label": "에이전트 간 메시지", "curve": [[839, 409], [872, 456], [872, 502], [872, 548]], "off": "50%"}, {"src": "에이전트A", "dst": "공유상태", "kind": "data", "curve": [[785, 409], [707, 502], [707, 633], [771, 672]]}, {"src": "에이전트B", "dst": "공유상태", "kind": "data", "curve": [[872, 594], [872, 633], [872, 633], [844, 672]]}, {"src": "기존", "dst": "협업", "kind": "data", "label": "패러다임 전환", "line": [492, 109, 492, 209], "lx": 492, "ly": 151}]});
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
      const container = document.getElementById('layercollaborativeagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'layercollaborativeagents-1';
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

기존 구조에서 두 개발자의 에이전트는 같은 저장소를 만지더라도 서로를 인식하지 못합니다. 각자 자기 컨텍스트 안에서만 판단하므로, A의 Claude가 리팩터한 인터페이스를 B의 Claude가 모른 채 예전 시그니처로 호출하는 일이 벌어집니다. 협업 구조에서는 세션과 상태가 공유되고, 에이전트끼리 메시지를 주고받기 때문에 이 어긋남을 실시간에 가깝게 줄일 여지가 생깁니다.

다만 발표된 정보만으로는 이 연결이 어느 수준까지 구현되었는지 단정하기 어렵습니다. 공유 터미널이 화면 스트리밍 수준인지, 아니면 에이전트가 실제로 서로의 계획과 편집 의도를 구조화된 형태로 교환하는지에 따라 실용성은 크게 갈립니다. 이 글은 공개된 개념을 근거로 설계 과제를 짚는 데 초점을 맞추며, 검증되지 않은 내부 동작은 단정하지 않습니다.

## 왜 지금 이 방향인가

협업 에이전트가 지금 등장하는 데에는 이유가 있습니다. 모델이 강해지면서 에이전트 한 대가 처리하는 작업의 크기가 커졌고, 그 결과 **여러 에이전트가 동시에 큰 변경을 만드는 상황**이 실제로 잦아졌기 때문입니다. 한 사람이 서브에이전트를 병렬로 띄워 파일을 나눠 고치는 패턴은 이미 흔합니다. 여기서 한 걸음만 더 나가면 서로 다른 사람의 에이전트가 같은 코드베이스에서 겹치는 순간이 옵니다. 조율이 없으면 이 순간은 곧 충돌이 됩니다.

또 하나의 배경은 도구 생태계의 파편화입니다. 팀마다 Claude Code를 쓰는 사람, Codex를 쓰는 사람, Cursor를 쓰는 사람이 섞여 있습니다. 앞서 언급한 여러 벤더의 에이전트를 한 워크스페이스로 묶는 프로젝트들이 등장한 것은, 이 파편화를 조율 계층으로 흡수하려는 시도입니다. 즉 협업 에이전트는 단순히 사람을 더 붙이는 기능이 아니라, **이질적인 에이전트들이 공존하는 현실을 다루는 인프라 문제**로 커지고 있습니다.

## 협업 에이전트가 풀어야 할 설계 과제

멋진 개념 뒤에는 만만치 않은 엔지니어링이 있습니다. 협업 에이전트를 실무에 올리려면 최소 네 가지를 풀어야 합니다.

첫째, **동시성과 충돌**입니다. 두 에이전트가 같은 파일의 같은 영역을 동시에 편집하면 어떻게 되는지 정해야 합니다. 사람의 협업에서는 git 브랜치와 병합이 이 문제를 흡수했지만, 실시간 공유 세션에서는 그보다 짧은 주기의 조정이 필요합니다. 잠금을 걸 것인지, 낙관적 편집 후 병합할 것인지, 아니면 애초에 작업 영역을 겹치지 않게 분배할 것인지가 설계의 갈림길입니다.

둘째, **컨텍스트 공유의 범위**입니다. 에이전트끼리 대화하게 하려면 무엇을 공유할지 정해야 합니다. 전체 대화 이력을 통째로 넘기면 토큰 비용이 폭증하고 컨텍스트가 오염됩니다. 반대로 너무 적게 공유하면 협업의 의미가 사라집니다. 결국 필요한 것은 **요약되고 구조화된 상태 교환**입니다. "나는 이 파일의 이 함수를 이렇게 바꿀 계획이다"라는 의도를, 원문이 아니라 압축된 형태로 주고받아야 합니다.

셋째, **신뢰 경계**입니다. 내 에이전트가 남의 에이전트가 제안한 변경을 얼마나 신뢰해야 하는지의 문제입니다. 사람이 리뷰 없이 병합하지 않듯, 에이전트도 다른 에이전트의 산출물을 무검증으로 받아들여서는 안 됩니다. 멀티에이전트 시스템의 오래된 교훈은 명확합니다. **검증 단계 없이 여러 에이전트의 결과를 합치면 환각이 누적됩니다.** 협업 에이전트일수록 각 참여자의 산출물을 적대적으로 검증하는 게이트가 더 필요합니다.

넷째, **감사와 책임 추적**입니다. 여러 사람과 여러 에이전트가 같은 코드를 만졌을 때, 어떤 변경이 누구의(혹은 어느 에이전트의) 판단에서 나왔는지 추적할 수 없다면 사고가 났을 때 원인을 되짚을 수 없습니다. 협업이 늘어날수록 감사 로그는 선택이 아니라 필수가 됩니다.

## ThakiCloud 제품 적용 시사점

이 설계 과제들은 ThakiCloud가 **Paxis**에서 이미 정면으로 다루고 있는 문제들과 정확히 겹칩니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, Skills·Tools·Policies·Audit Logs를 일급 리소스로 취급합니다. 멀티플레이어 코딩 에이전트가 던지는 질문에 Paxis의 구조는 다음과 같이 대응합니다.

에이전트 간 협업의 골격은 Paxis의 **DAG 멀티에이전트** 오케스트레이션입니다. 여러 에이전트를 무작정 같은 공간에 풀어놓는 대신, 작업을 방향성 비순환 그래프로 분해해 각 노드가 담당 영역을 갖게 하면, 앞서 말한 동시성 충돌의 상당 부분을 구조적으로 회피할 수 있습니다. 겹치는 편집을 사후에 병합하는 대신, 애초에 겹치지 않도록 작업을 배분하는 방식입니다.

신뢰 경계 문제에는 Paxis의 **정책 게이트와 감사 로그**가 답합니다. 한 에이전트의 산출물이 다른 에이전트나 실제 시스템으로 흘러가기 전에 정책 게이트를 통과해야 하고, 모든 행동이 감사 로그에 남습니다. 이는 "여러 에이전트의 결과를 검증 없이 합치지 않는다"는 원칙을 인프라 차원에서 강제하는 셈입니다. 협업이 늘어날수록 이 게이트의 가치는 커집니다.

컨텍스트 공유의 비용 문제는 Paxis의 **Skill Harness**와 지식 엔진이 완화합니다. 960개가 넘는 스킬을 BM25로 선택해 격리 샌드박스에서 실행하는 구조는, 에이전트가 매번 전체 컨텍스트를 짊어지는 대신 그때그때 필요한 능력만 불러오도록 설계돼 있습니다. 협업 에이전트가 상태를 통째로 교환하는 대신 요약된 형태로 주고받아야 한다는 요구와 같은 방향입니다.

그 아래에서 실행 자원을 받쳐주는 것은 **ai-platform**입니다. 여러 사람과 여러 에이전트가 동시에 격리된 샌드박스에서 코드를 실행하려면 멀티테넌트 격리와 탄력적인 컴퓨트가 필요합니다. K8s와 Kueue 기반 GPU 스케줄링, 멀티테넌트 격리는 협업 에이전트가 실제로 돌아갈 토대를 제공합니다. 온프레미스와 소버린 환경에서도 이 협업 구조를 안전하게 세울 수 있다는 점은, 데이터 유출을 우려하는 조직에 특히 의미가 있습니다.

정리하면, 멀티플레이어 Claude Code가 개인 도구 층에서 실험하는 협업 개념을, Paxis는 제어 평면 층에서 정책과 감사와 오케스트레이션으로 구조화합니다. 두 층은 경쟁이 아니라 보완입니다. 협업 에이전트가 재미있는 데모에서 신뢰할 수 있는 운영으로 넘어가려면, 결국 정책 게이트와 감사 로그와 자원 격리를 갖춘 제어 평면이 필요하기 때문입니다.

## 한계 및 반론

협업 에이전트를 낙관만 할 수는 없습니다. 가장 큰 반론은 **조율 비용이 협업 이득을 잡아먹을 수 있다**는 것입니다. 사람 사이의 회의가 그렇듯, 에이전트끼리 주고받는 메시지가 늘어나면 그 자체가 지연과 토큰 비용이 됩니다. 두 에이전트가 서로의 계획을 계속 확인하느라 정작 코드를 못 만드는 상황은 충분히 가능합니다. 협업이 항상 병렬 단독 작업보다 빠른 것은 아닙니다.

둘째, **실패 모드의 결합**입니다. 에이전트가 서로 연결되면 한 에이전트의 잘못된 판단이 다른 에이전트로 전파됩니다. 고립된 구조에서는 한 사람의 실수가 그 사람 안에 머물지만, 연결된 구조에서는 오류가 사슬을 타고 번집니다. 검증 게이트가 없다면 협업은 오히려 사고를 증폭시킵니다.

셋째, 지금 공개된 멀티플레이어 도구가 실제로 어느 수준의 상태 교환을 구현했는지는 아직 검증되지 않았습니다. 공유 터미널이 화면 공유에 가까운 것인지, 진짜 구조화된 에이전트 간 프로토콜인지에 따라 실용성은 크게 달라집니다. 개념의 방향성은 분명하지만, 프로덕션에 올리기 전에는 신뢰 경계와 감사 추적을 반드시 확인해야 합니다. 흥미로운 데모와 신뢰할 수 있는 인프라 사이에는 여전히 상당한 거리가 있습니다.

그럼에도 방향 자체는 되돌리기 어렵다고 봅니다. 소프트웨어가 팀 작업인 한, 그 팀을 대신하는 에이전트들도 결국 서로 대화해야 합니다. 관건은 협업을 켜느냐 마느냐가 아니라, 그 협업을 **정책과 검증과 감사가 받쳐주는 구조 위에 세우느냐**입니다.

## 출처

- Dorsa Rohani, "We made Claude Code multiplayer!" (X, 2026-07-08): [https://x.com/dorsa_rohani/status/2074963064231952832](https://x.com/dorsa_rohani/status/2074963064231952832)
- Claude Code (Anthropic 공식 저장소): [https://github.com/anthropics/claude-code](https://github.com/anthropics/claude-code)
- oh-my-claudecode (팀 우선 멀티에이전트 오케스트레이션): [https://github.com/yeachan-heo/oh-my-claudecode](https://github.com/yeachan-heo/oh-my-claudecode)
- claude_codex_bridge (다중 에이전트 CLI 워크스페이스): [https://github.com/SeemSeam/claude_codex_bridge](https://github.com/SeemSeam/claude_codex_bridge)
