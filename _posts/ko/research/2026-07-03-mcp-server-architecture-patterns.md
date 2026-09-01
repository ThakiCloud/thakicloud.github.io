---
title: "MCP 서버 아키텍처 패턴: 도구가 많아질수록 LLM이 흔들리는 이유"
excerpt: "15개 프로덕션 MCP 서버를 분석한 최신 논문이 다섯 가지 아키텍처 패턴과 네 가지 안티패턴을 정리했습니다. 핵심은 도구가 일정 수를 넘으면 모델의 도구 선택 정확도가 무너진다는 실측 결과입니다."
seo_title: "MCP 서버 아키텍처 패턴 분석 도구 과부하 LLM - Thaki Cloud"
seo_description: "arXiv 2606.30317 논문 분석. MCP 서버의 다섯 가지 아키텍처 패턴과 도구 개수가 LLM 도구 선택 정확도에 미치는 영향, 그리고 Paxis Skill Harness의 BM25 선택 전략까지 정리합니다."
date: 2026-07-03
last_modified_at: 2026-07-03
tags:
  - MCP
  - Model-Context-Protocol
  - LLM-Agents
  - Architecture-Patterns
  - Tool-Selection
  - Agent-Native-Cloud
  - paxis
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/mcp-server-architecture-patterns/"
reading_time: true
header:
  image: /assets/images/mcp-server-architecture-patterns-hero.webp
  teaser: /assets/images/mcp-server-architecture-patterns-hero.webp
categories:
  - research
---

## 개요

Model Context Protocol(MCP)은 Anthropic이 2024년 11월에 공개한 표준 인터페이스입니다. 대규모 언어 모델을 외부 도구와 데이터 소스, 서비스에 연결하는 공통 규격이며, 공개 몇 달 만에 GitHub에는 커뮤니티가 만든 MCP 서버가 수백 개 등장했습니다. 그런데 정작 "이 서버들이 프로덕션에서 어떻게 구조화되고 있는가"를 소프트웨어 유지보수 관점에서 정리한 문헌은 없었습니다.

2026년 6월 29일 arXiv에 올라온 Carson Rodrigues 외 연구진의 논문 [MCP Server Architecture Patterns for LLM-Integrated Applications](https://arxiv.org/abs/2606.30317)가 그 공백을 메웁니다. 독립적으로 개발된 15개의 MCP 서버를 코퍼스로 삼아, 반복적으로 나타나는 다섯 가지 아키텍처 패턴과 네 가지 안티패턴을 카탈로그화했습니다. 여기에 인증, 버전 관리, 관측 가능성이라는 교차 관심사를 함께 다룹니다.

에이전트 인프라를 운영하는 입장에서 이 논문이 흥미로운 이유는 따로 있습니다. 논문은 "도구를 몇 개까지 붙일 수 있는가"를 실제로 측정했고, 그 답이 우리가 막연히 생각하던 것보다 훨씬 낮았기 때문입니다. ThakiCloud가 Agent-Native Cloud인 Paxis에서 960개가 넘는 스킬을 다루는 방식과 정면으로 맞닿는 주제라, 이 글에서 실측 결과와 우리 설계 선택을 함께 짚어보겠습니다.

![mcp-server-architecture-patterns 슬라이드 1]({{ '/assets/images/mcp-server-architecture-patterns-slide-01.webp' | relative_url }})

## 이 연구는 무엇인가

논문의 접근은 실증적입니다. 이론에서 출발해 "이래야 한다"를 제시하는 대신, 이미 돌아가고 있는 서버 15개를 뜯어보고 공통 구조를 귀납적으로 추출했습니다. 그 결과 도출된 다섯 패턴은 서버가 LLM에게 무엇을 노출하느냐, 그리고 상태를 어떻게 다루느냐에 따라 갈립니다.

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
<div class="d3-arch" data-arch-root id="rverarchitecturepatterns-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1091, "height": 628, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "LLM", "x": 503, "y": 24, "w": 120, "h": 46, "title": "LLM 에이전트"}, {"id": "Client", "x": 503, "y": 148, "w": 120, "h": 46, "title": "MCP 클라이언트"}, {"id": "Server", "x": 503, "y": 272, "w": 120, "h": 46, "title": "MCP 서버"}, {"id": "P1", "x": 917, "y": 396, "w": 142, "h": 62, "title": ["Resource Gateway", "데이터 소스 노출"]}, {"id": "P2", "x": 713, "y": 396, "w": 149, "h": 62, "title": ["Tool Orchestrator", "도구 실행 조율"]}, {"id": "P3", "x": 467, "y": 396, "w": 191, "h": 62, "title": ["Stateful Session Server", "세션 상태 유지"]}, {"id": "P4", "x": 270, "y": 396, "w": 142, "h": 62, "title": ["Proxy Aggregator", "다중 백엔드 통합"]}, {"id": "P5", "x": 24, "y": 396, "w": 191, "h": 62, "title": ["Domain-Specific Adapter", "도메인 특화 래핑"]}, {"id": "X", "x": 706, "y": 550, "w": 163, "h": 46, "title": "인증 · 버전 관리 · 관측 가능성"}], "edges": [{"src": "LLM", "dst": "Client", "kind": "data", "line": [563, 70, 563, 148]}, {"src": "Client", "dst": "Server", "kind": "data", "line": [563, 194, 563, 272]}, {"src": "Server", "dst": "P1", "kind": "data", "curve": [[623, 304], [988, 357], [988, 357], [988, 396]]}, {"src": "Server", "dst": "P2", "kind": "data", "curve": [[623, 312], [788, 357], [788, 357], [788, 396]]}, {"src": "Server", "dst": "P3", "kind": "data", "line": [563, 318, 563, 396]}, {"src": "Server", "dst": "P4", "kind": "data", "curve": [[503, 312], [341, 357], [341, 357], [341, 396]]}, {"src": "Server", "dst": "P5", "kind": "data", "curve": [[503, 303], [120, 357], [120, 357], [120, 396]]}, {"src": "P1", "dst": "X", "kind": "event", "label": "교차 관심사", "curve": [[988, 458], [988, 504], [988, 504], [854, 550]], "off": "50%"}, {"src": "P2", "dst": "X", "kind": "event", "label": "교차 관심사", "line": [788, 458, 788, 550], "lx": 788, "ly": 500}, {"src": "P3", "dst": "X", "kind": "event", "label": "교차 관심사", "curve": [[563, 458], [563, 504], [563, 504], [713, 550]], "off": "50%"}]});
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
      const container = document.getElementById('rverarchitecturepatterns-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rverarchitecturepatterns-1';
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

이 분류가 유용한 이유는 서버를 설계할 때 "내 서버는 어떤 종류인가"를 먼저 정하게 만들기 때문입니다. Resource Gateway를 만들면서 Tool Orchestrator의 복잡한 실행 로직을 욱여넣으면 두 패턴의 단점만 합쳐집니다. 패턴을 명시적으로 고르는 것 자체가 설계 규율입니다.

![mcp-server-architecture-patterns 슬라이드 2]({{ '/assets/images/mcp-server-architecture-patterns-slide-02.webp' | relative_url }})

## 다섯 가지 아키텍처 패턴

**Resource Gateway**는 데이터베이스나 파일 시스템, API 같은 데이터 소스를 읽기 중심으로 노출하는 서버입니다. 도구 자체는 단순하고, 관건은 어떤 리소스를 어떤 권한으로 열어주느냐입니다.

**Tool Orchestrator**는 여러 도구를 묶어 실행 흐름을 조율합니다. 단일 호출이 내부적으로 여러 단계를 거치는 경우가 많아, 실패 처리와 부분 롤백 설계가 핵심 난이도입니다.

**Stateful Session Server**는 대화나 작업 세션에 걸친 상태를 유지합니다. LLM 호출은 본질적으로 무상태에 가깝기 때문에, 상태를 서버가 대신 들고 있으면서 세션 수명과 정리 정책을 명확히 해야 합니다.

**Proxy Aggregator**는 여러 백엔드나 다른 MCP 서버를 하나의 표면으로 합쳐 노출합니다. 편리하지만, 뒤에 붙는 도구가 늘어나면 곧 도구 과부하 문제로 이어집니다. 뒤에서 다시 다루겠습니다.

**Domain-Specific Adapter**는 특정 도메인(금융, 의료, 사내 시스템 등)의 개념을 LLM이 다루기 좋은 형태로 래핑합니다. 도메인 용어와 제약을 도구 스키마에 녹여, 모델이 엉뚱한 조합을 시도하지 않게 유도합니다.

![mcp-server-architecture-patterns 슬라이드 3]({{ '/assets/images/mcp-server-architecture-patterns-slide-03.webp' | relative_url }})

## 도구 과부하: 도구가 많으면 왜 흔들리는가

이 논문에서 가장 실무적으로 중요한 부분은 도구 개수와 도구 선택 정확도의 관계를 측정한 대목입니다. 결과는 명확합니다. 컨텍스트에 붙는 도구가 일정 수를 넘으면, 모델이 올바른 도구를 고르는 정확도가 90% 아래로 떨어집니다.

구체적으로 논문은 Claude Haiku 4.5의 경우 도구 10~15개 구간에서, Sonnet 4의 경우 20~30개 구간에서 도구 선택 정확도가 90% 밑으로 내려간다고 보고합니다. 더 큰 모델일수록 감당하는 도구 수가 늘어나긴 하지만, "무한정 붙여도 된다"는 지점은 존재하지 않습니다. 도구가 많아지고 설명이 모호해질수록 모델은 헷갈립니다.

이 실측은 흔한 직관을 뒤집습니다. MCP를 처음 붙이는 팀은 "일단 가진 API를 전부 도구로 노출하자"고 시작하는 경우가 많습니다. Proxy Aggregator로 여러 백엔드를 합치면 도구 수는 금세 수십 개가 됩니다. 그 순간 정확도 곡선의 벼랑 아래로 떨어지는 셈입니다. 도구 개수는 무료가 아니라, 모델의 판단 예산을 갉아먹는 비용입니다.

![mcp-server-architecture-patterns 슬라이드 4]({{ '/assets/images/mcp-server-architecture-patterns-slide-04.webp' | relative_url }})

## 안티패턴과 교차 관심사

논문은 네 가지 안티패턴도 함께 정리합니다. 세부 명칭까지는 초록 단계에서 확인되지 않지만, 방향은 위 실측과 연결됩니다. 도구를 무분별하게 늘리는 것, 도구 설명을 모호하게 두어 모델이 의도를 추론하게 만드는 것, 상태 관리 없이 세션을 흘려보내는 것, 그리고 인증과 버전을 서버마다 제각각 처리하는 것이 전형적인 실패 모드입니다.

교차 관심사로는 인증, 버전 관리, 관측 가능성 세 가지를 강조합니다. 이 셋은 어떤 패턴을 고르든 공통으로 필요합니다. 특히 관측 가능성은 에이전트 시스템에서 종종 뒤로 밀리는데, 도구 호출이 실패했을 때 왜 실패했는지 추적할 수 없으면 디버깅이 사실상 불가능합니다.

## ThakiCloud 제품 적용 시사점

이 논문의 도구 과부하 결론은 ThakiCloud가 **Paxis**를 설계한 이유와 그대로 겹칩니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud 제어 평면으로, 스킬(Skills)과 도구(Tools), 정책(Policies), 감사 로그(Audit Logs)를 일급 리소스로 다룹니다. 여기서 핵심은 **Skill Harness**입니다.

Paxis는 960개가 넘는 스킬을 보유하고 있지만, 이 스킬을 전부 모델의 컨텍스트에 도구로 쏟아붓지 않습니다. 대신 사용자 요청마다 BM25 검색으로 관련 스킬 소수만 선택해 노출합니다. 논문의 실측에 대입하면, 이는 정확도 벼랑을 피하는 설계입니다. 모델은 언제나 자신이 감당 가능한 소수의 도구만 마주하고, 나머지 수백 개의 능력은 필요할 때만 검색으로 불려 나옵니다. "능력은 많이, 노출은 적게"가 도구 과부하 문제에 대한 우리의 답입니다.

Proxy Aggregator의 위험도 같은 렌즈로 관리합니다. Paxis의 MCP 커넥터는 여러 외부 서비스를 연결하지만, 연결된 도구를 무차별 노출하는 대신 정책 게이트로 걸러 실제 필요한 것만 격리 샌드박스 실행 경로에 올립니다. 모든 도구 호출은 감사 로그를 남겨 관측 가능성 요구를 충족합니다. 논문이 교차 관심사로 지목한 인증, 버전, 관측 가능성이 Paxis에서는 선택이 아니라 기본 배선입니다.

인프라 층위인 **ai-platform** 관점도 짚어둘 만합니다. MCP 서버가 늘어나면 각 서버는 결국 어딘가에서 프로세스로 떠야 합니다. ai-platform은 K8s와 Kueue 기반 GPU 스케줄링, 멀티테넌트 격리 위에서 이런 서버들을 온프렘과 소버린 환경까지 포함해 안정적으로 서빙합니다. Stateful Session Server처럼 상태를 들고 있는 서버일수록 배치와 수명 관리가 중요한데, 여기서 K8s의 운영 성숙도가 그대로 이점이 됩니다.

## 한계 및 반론

이 논문은 15개 서버라는 비교적 작은 코퍼스에 기반합니다. MCP 생태계가 워낙 빠르게 커지고 있어, 패턴 다섯 개가 앞으로도 대표성을 유지할지는 지켜봐야 합니다. 새로운 패턴이 등장하거나, 지금의 안티패턴이 도구 개선으로 완화될 여지도 있습니다.

도구 선택 정확도 실측 역시 모델과 프롬프트 설계에 따라 달라질 수 있는 값입니다. 잘 짜인 도구 설명과 명확한 네이밍은 같은 도구 수에서도 정확도를 끌어올립니다. 즉 "도구 N개까지 안전"이라는 절대선이 있는 것이 아니라, 도구 수는 여러 변수 중 하나입니다. 그럼에도 방향성은 분명합니다. 도구는 공짜가 아니며, 필요한 만큼만 노출하는 규율이 에이전트 신뢰성의 토대라는 점입니다.


## 출처

- Carson Rodrigues 외, [MCP Server Architecture Patterns for LLM-Integrated Applications](https://arxiv.org/abs/2606.30317), arXiv:2606.30317 (2026-06-29)
- [Model Context Protocol 공식 소개](https://modelcontextprotocol.io/)
