---
title: "Hermes Bible: Hermes Agent 문서와 실전 워크플로를 한 번에 검색합니다"
excerpt: "Nous Research의 Hermes Agent 공식 문서 169페이지와 커뮤니티가 만든 실전 워크플로 28개를 한곳에 색인해 ⌘K 한 번으로 검색하는 비공식 커뮤니티 사이트입니다. 무엇을 담고 있고, 공식 문서와 어떻게 다른지, 그리고 1000개가 넘는 스킬과 룰을 운용하는 ThakiCloud 입장에서 이 패턴이 왜 의미 있는지 정리합니다."
seo_title: "Hermes Bible과 에이전트 문서 검색 패턴 분석 - Thaki Cloud"
seo_description: "Hermes Bible(hermesbible.com)은 Hermes Agent 공식 문서 169페이지와 커뮤니티 워크플로 28개를 색인한 비공식 검색 사이트입니다. 구성과 공식 문서와의 차이, 그리고 ThakiCloud 쿠버네티스 AI/ML 플랫폼의 스킬·룰 검색 관점에서 시사점을 분석합니다."
date: 2026-06-23
last_modified_at: 2026-06-23
tags:
  - ai-coding
  - hermes-agent
  - documentation
  - agent-workflows
  - knowledge-base
  - platform-engineering
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/hermes-bible-agent-docs/"
categories:
  - agentops
audiobook: /assets/audio/posts/hermes-bible-agent-docs/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![색인된 지식 라이브러리를 추상적으로 표현한 이미지]({{ '/assets/images/hermes-bible-agent-docs-hero.webp' | relative_url }})
*수많은 문서 노드가 하나의 밝은 검색 지점으로 수렴하는 모습으로 표현한 색인 검색.*

## 개요

에이전트 프레임워크가 강력해질수록 역설적으로 문서가 발목을 잡습니다. 기능이 빠르게 늘면서 문서 페이지 수가 수백 단위로 불어나고, 정작 필요한 한 줄을 찾는 일이 점점 어려워지기 때문입니다. Nous Research가 2026년 2월 공개한 Hermes Agent도 마찬가지입니다. 공식 문서는 잘 정리되어 있지만 분량이 방대하고, 거기에 더해 커뮤니티가 공유하는 실전 노하우는 X(트위터)와 여기저기에 흩어져 있습니다.

`Hermes Bible`(hermesbible.com)은 이 문제를 정면으로 겨냥한 비공식 커뮤니티 사이트입니다. Hermes Agent 공식 문서의 모든 페이지와, 커뮤니티가 만든 실전 워크플로를 한곳에 색인해 두고, 단축키 한 번으로 전문 검색을 제공합니다. 사이트 스스로 "비공식, 커뮤니티 제작, Nous Research와 무관"임을 명확히 밝히고 있습니다.

ThakiCloud는 쿠버네티스 기반 AI/ML SaaS 플랫폼을 운영하면서 내부적으로 1000개가 넘는 스킬과 다수의 운영 룰을 다룹니다. 그래서 "방대한 에이전트 지식을 어떻게 검색 가능하게 만드느냐"는 주제는 우리에게도 매일의 과제입니다. 이 글에서는 Hermes Bible이 무엇을 어떻게 담았는지 살펴보고, 공식 문서와의 차이, 그리고 우리 플랫폼 관점의 시사점을 함께 정리합니다.

![hermes-bible-agent-docs 슬라이드 1](/assets/images/hermes-bible-agent-docs-slide-01.png)

## 이 사이트는 무엇인가

Hermes Bible의 핵심 기능은 색인과 검색입니다. 사이트는 Hermes Agent 문서 169페이지를 10개 섹션으로 나눠 담고 있습니다. Getting Started(설치·퀵스타트·학습 경로 등 6페이지), Core Features(기능 개요·툴·스킬 시스템·큐레이터 등 45페이지), Messaging Platforms(메시징 게이트웨이·텔레그램·디스코드·슬랙 등 30페이지), Secrets(2페이지), Skills, Using Hermes(CLI·TUI·설정·모델 구성 등 15페이지) 등으로 구성됩니다.

검색은 ⌘K로 호출하며, 모든 페이지의 제목과 섹션, 헤딩을 가로지르는 전문 퍼지 검색입니다. 사이트 설명에 따르면 로딩이나 대기 없이 입력하는 즉시 결과가 나타납니다. 방대한 문서에서 키워드 하나로 정확한 위치를 초 단위로 찾는 경험을 목표로 한 셈입니다. 아래 그림은 이 사이트가 공식 문서와 커뮤니티 워크플로를 어떻게 하나의 검색 표면으로 통합하는지를 보여줍니다.

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
<div class="d3-arch" data-arch-root id="0623hermesbibleagentdocs-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 841, "height": 352, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 200, "w": 191, "h": 62, "title": ["Hermes Agent 공식 문서", "169 pages · 10 sections"]}, {"id": "C", "x": 293, "y": 141, "w": 120, "h": 62, "title": ["Hermes Bible", "전문 색인 (비공식)"]}, {"id": "B", "x": 45, "y": 83, "w": 149, "h": 62, "title": ["커뮤니티 Flows", "28 real workflows"]}, {"id": "D", "x": 491, "y": 258, "w": 120, "h": 62, "title": ["⌘K 퍼지 전문검색", "제목·섹션·헤딩"]}, {"id": "E", "x": 689, "y": 258, "w": 120, "h": 62, "title": ["타이핑 즉시 결과", "로딩 없음"]}, {"id": "F", "x": 491, "y": 141, "w": 120, "h": 62, "title": ["/docs 브라우즈", "10개 섹션"]}, {"id": "G", "x": 491, "y": 24, "w": 120, "h": 62, "title": ["/flows", "아키텍처·토큰 경제"]}], "edges": [{"src": "A", "dst": "C", "kind": "data", "curve": [[215, 231], [254, 231], [254, 231], [301, 203]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[194, 114], [254, 114], [254, 114], [301, 141]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[379, 203], [452, 289], [452, 289], [491, 289]]}, {"src": "D", "dst": "E", "kind": "data", "line": [611, 289, 689, 289]}, {"src": "C", "dst": "F", "kind": "data", "line": [413, 172, 491, 172]}, {"src": "C", "dst": "G", "kind": "data", "curve": [[379, 141], [452, 55], [452, 55], [491, 55]]}]});
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
      const container = document.getElementById('0623hermesbibleagentdocs-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0623hermesbibleagentdocs-1';
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

차별점은 Flows 라이브러리입니다. 공식 문서를 넘어, 커뮤니티가 실제로 구축한 멀티 에이전트 자동화 워크플로 28개를 모아 둡니다. 각 워크플로는 전체 아키텍처와 토큰 경제, 오케스트레이션 패턴까지 포함해, 검색하고 연구하고 적용할 수 있게 정리되어 있습니다. 예를 들어 한 글은 "아무도 이야기하지 않지만 매일 여는" Hermes 대시보드(localhost:9119)를 24시간 에이전트를 건강하게 유지하는 운영 표면으로 소개하며 Sessions, MCP, Skills, Cron, Analytics, Logs, System을 다룹니다. 또 다른 글 "Hermes Agent 사용의 15단계"는 첫 원샷 프롬프트부터 여러 프로파일로 비즈니스를 자동화하는 단계까지를 토큰 경제와 함께 정리하고, Hermes Agent v0.17.0 기준으로 검증했다고 밝힙니다.

참고로 Hermes Agent 자체는 Nous Research가 MIT 라이선스로 공개한 프로젝트로, 발표 시점 기준 GitHub 스타 약 20만 개, 포크 3.5만 개, 커밋 1.2만여 개를 기록하고 있습니다. 에이전트가 경험에서 스킬을 만들고, 사용 중에 스킬을 스스로 개선하며, 세션을 가로질러 사용자를 모델링하는 "닫힌 학습 루프"를 내세웁니다. Hermes Bible은 이 빠르게 진화하는 프로젝트의 지식을 따라잡기 위한 커뮤니티의 대응으로 볼 수 있습니다.

![hermes-bible-agent-docs 슬라이드 2](/assets/images/hermes-bible-agent-docs-slide-02.png)

## ThakiCloud 플랫폼 관점의 시사점

Hermes Bible을 단순한 검색 사이트가 아니라 하나의 패턴으로 보면 우리에게 직접적인 교훈이 됩니다. ThakiCloud는 내부적으로 1000개가 넘는 스킬과 운영 룰을 운용하는데, 이는 Hermes Agent 문서가 직면한 것과 똑같은 "방대한 지식의 검색 가능성" 문제입니다. 실제로 우리 플랫폼에는 이미 BM25 기반 스킬 검색 게이트가 매 작업 턴에 후보를 띄우는 장치가 들어가 있습니다. Hermes Bible의 ⌘K 즉시 전문 검색은 바로 이 방향, 즉 "지식이 많아질수록 검색이 곧 생산성"이라는 명제를 사용자 경험 측면에서 잘 보여줍니다.

특히 흥미로운 부분은 Flows 개념입니다. 공식 문서가 기능을 설명한다면, Flows는 그 기능을 엮어 만든 실전 레시피를 아키텍처와 토큰 경제까지 곁들여 공유합니다. 이는 ThakiCloud가 스킬과 룰을 "실패 사례와 gotchas, 검증된 골격까지 함께 패키징한 능력 상품"으로 다루는 철학과 정확히 같은 발상입니다. 단일 프롬프트가 아니라 입력에서 처리, 출력, 에러 복구까지 묶인 재사용 가능한 워크플로로 지식을 축적할 때, 검색과 공유의 가치가 비로소 복리로 쌓입니다.

운영 관점에서도 닿는 지점이 있습니다. Hermes 대시보드가 Sessions, Cron, Skills, Analytics, Logs를 한 화면에 모아 24시간 에이전트를 관리하듯, 우리 역시 무인 루프와 스케줄 작업을 중앙 레지스트리로 가시화하는 방향으로 운영을 설계합니다. 빠르게 진화하는 에이전트 시스템에서 "지금 무엇이 돌고 있고 무엇을 읽고 쓰는지"를 한눈에 보는 일은 안정적 운용의 전제입니다.

![hermes-bible-agent-docs 슬라이드 3](/assets/images/hermes-bible-agent-docs-slide-03.png)

## 한계 및 반론

가장 분명한 한계는 비공식이라는 점입니다. Hermes Bible은 Nous Research와 무관한 커뮤니티 프로젝트이므로, 색인된 내용이 항상 최신 공식 문서와 일치한다는 보장이 없습니다. Hermes Agent는 커밋이 1만 건을 넘는 빠르게 움직이는 프로젝트입니다. 비공식 색인은 본질적으로 시차를 가질 수밖에 없고, 특히 보안에 민감한 설정이나 시크릿 관리 같은 영역에서는 반드시 공식 문서를 최종 기준으로 삼아야 합니다.

둘째, 공식 문서가 이미 기계 친화적 진입점을 제공한다는 사실도 고려해야 합니다. Hermes Agent 공식 문서는 모든 페이지를 짧은 설명과 함께 색인한 `/llms.txt`(약 17KB)와 전체를 하나로 합친 `/llms-full.txt`(약 1.8MB)를 제공합니다. LLM이 문서를 통째로 읽어 들이는 용도라면 이 공식 경로가 더 권위 있고 안정적입니다. 즉 Hermes Bible의 강점은 어디까지나 사람이 빠르게 검색하고 커뮤니티 워크플로를 둘러보는 경험에 있습니다.

셋째, 외부 의존이라는 일반적 위험이 있습니다. 회사 블로그나 운영 문서가 제3자 사이트를 핵심 동선으로 끌어들이면, 그 사이트가 사라지거나 방향을 바꿀 때 링크가 깨질 수 있습니다. Hermes Bible은 발견과 학습의 보조 도구로 활용하되, 우리 내부 운영의 단일 진실 소스로 삼는 것은 적절하지 않습니다.

종합하면, Hermes Bible은 빠르게 진화하는 에이전트 프레임워크의 지식을 사람이 따라잡도록 돕는 잘 만들어진 커뮤니티 자산입니다. 다만 비공식이라는 본질적 시차와 외부 의존을 인지하고, 공식 문서를 기준점으로 두는 균형이 필요합니다. 무엇보다 이 사이트가 보여주는 "방대한 에이전트 지식을 검색 가능하게, 그리고 실전 워크플로로 공유 가능하게 만든다"는 패턴 자체가, 우리처럼 대규모 스킬과 룰을 운용하는 플랫폼에 가장 값진 시사점입니다.


![hermes-bible-agent-docs 슬라이드 4](/assets/images/hermes-bible-agent-docs-slide-04.png)

## 출처

- Hermes Bible: [hermesbible.com](https://www.hermesbible.com/)
- Hermes Agent (Nous Research): [github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
- 공식 문서: [hermes-agent.nousresearch.com/docs](https://hermes-agent.nousresearch.com/docs/)
