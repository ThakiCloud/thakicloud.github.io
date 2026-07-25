---
title: "AI-Researcher: Analysis of a Fully Autonomous Scientific Research System"
excerpt: "The AI-Researcher project from HKUDS implements a fully autonomous scientific research pipeline, from literature review to paper submission. This analysis covers system architecture, core innovations, and applicability in research environments."
seo_title: "AI-Researcher Autonomous Scientific Research System Analysis - Thaki Cloud"
seo_description: "A deep look at the AI-Researcher project architecture, key capabilities, and what fully autonomous scientific research could mean for the research community."
date: 2025-08-21
last_modified_at: 2025-08-21
tags:
  - AI-Researcher
  - 자율-연구-시스템
  - 과학-혁신
  - LLM
  - 연구-자동화
  - 에이전트-시스템
  - arXiv
  - 홍콩대학교
  - HKUDS
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/ai-researcher-autonomous-scientific-innovation-analysis/"
reading_time: true
lang: en
published: false
categories:
  - research
---

⏱️ **Estimated reading time**: 12 min

## Introduction

The paradigm of scientific research is undergoing a fundamental shift. **AI-Researcher**, developed by the Hong Kong University Data Science (HKUDS) research team, goes beyond a simple research tool to realize a **fully autonomous scientific research system**. Published as [arXiv:2505.18705](https://arxiv.org/abs/2505.18705), this system allows AI to independently carry out the entire process from literature review to paper publication.

This analysis provides a comprehensive look at the technical architecture, core innovations, and applicability of AI-Researcher across diverse research environments.

## AI-Researcher Project Overview

### 📄 Paper and Core Value

**"AI-Researcher: Autonomous Scientific Innovation"** combines the reasoning capabilities of large language models (LLMs) with a complex task-automation agent framework to accelerate scientific discovery.

**🔬 Core Innovation Points:**

1. **Full autonomy**: AI independently handles the entire process, from research idea generation to paper publication.
2. **Overcoming human cognitive limits**: Systematic exploration of solution spaces that are difficult for human researchers to navigate.
3. **Multi-agent collaboration**: Specialized AI agents work together to handle complex research tasks.
4. **Objective evaluation system**: Expert-level quality assessment across four major domains.

### 🏗️ GitHub Repository Status

The [GitHub repository](https://github.com/HKUDS/AI-Researcher) has earned **over 2,000 stars** and established itself as an active open-source project:

- **Multi-LLM support**: Integration with Claude, OpenAI, DeepSeek, and other language models.
- **Minimal domain expertise required**: Effective research can be conducted even without deep domain knowledge.
- **Ready to use**: Designed for immediate use without complex configuration.
- **Fully open-source**: Everything from benchmark construction methodology to the full system is publicly available.

## System Architecture Analysis

### 🎨 Overall System Structure

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
<div class="d3-arch" data-arch-root id="ntificinnovationanalysis-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 998, "height": 1554, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 684, "w": 142, "h": 62, "title": ["🚀 AI-Researcher", "Main System"]}, {"id": "B", "x": 244, "y": 1226, "w": 170, "h": 62, "title": ["📚 Research Agent", "(Research Execution)"]}, {"id": "C", "x": 262, "y": 684, "w": 135, "h": 62, "title": ["✍️ Paper Agent", "(Paper Writing)"]}, {"id": "D", "x": 248, "y": 204, "w": 163, "h": 62, "title": ["📊 Benchmark Suite", "(Evaluation System)"]}, {"id": "E", "x": 503, "y": 1460, "w": 170, "h": 62, "title": ["📖 Literature Review", "(Literature Survey)"]}, {"id": "F", "x": 492, "y": 1343, "w": 191, "h": 62, "title": ["🔍 Gap Analysis", "(Research Gap Analysis)"]}, {"id": "G", "x": 510, "y": 1226, "w": 156, "h": 62, "title": ["💡 Idea Generation", "(Idea Generation)"]}, {"id": "H", "x": 503, "y": 1109, "w": 170, "h": 62, "title": ["🧪 Experiment Design", "(Experiment Design)"]}, {"id": "I", "x": 513, "y": 976, "w": 149, "h": 78, "title": ["⚡ Implementation", "(Implementation &", "Validation)"]}, {"id": "J", "x": 496, "y": 859, "w": 184, "h": 62, "title": ["📝 Abstract Generation", "(Abstract Generation)"]}, {"id": "K", "x": 510, "y": 742, "w": 156, "h": 62, "title": ["📄 Content Writing", "(Body Writing)"]}, {"id": "L", "x": 510, "y": 625, "w": 156, "h": 62, "title": ["📈 Result Analysis", "(Result Analysis)"]}, {"id": "M", "x": 496, "y": 508, "w": 184, "h": 62, "title": ["🔗 Citation Management", "(Reference Management)"]}, {"id": "N", "x": 513, "y": 391, "w": 149, "h": 62, "title": ["🎯 CV Domain", "(Computer Vision)"]}, {"id": "O", "x": 513, "y": 258, "w": 149, "h": 78, "title": ["🔤 NLP Domain", "(Natural Language", "Processing)"]}, {"id": "P", "x": 527, "y": 141, "w": 121, "h": 62, "title": ["📊 DM Domain", "(Data Mining)"]}, {"id": "Q", "x": 492, "y": 24, "w": 191, "h": 62, "title": ["🔍 IR Domain", "(Information Retrieval)"]}, {"id": "R", "x": 761, "y": 1226, "w": 205, "h": 62, "title": ["🧠 Global State", "(Global State Management)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[101, 746], [205, 1257], [205, 1257], [244, 1257]]}, {"src": "A", "dst": "C", "kind": "data", "line": [166, 715, 262, 715]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[102, 684], [205, 235], [205, 235], [248, 235]]}, {"src": "B", "dst": "E", "kind": "data", "curve": [[345, 1288], [453, 1491], [453, 1491], [503, 1491]]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[362, 1288], [453, 1374], [453, 1374], [492, 1374]]}, {"src": "B", "dst": "G", "kind": "data", "line": [414, 1257, 510, 1257]}, {"src": "B", "dst": "H", "kind": "data", "curve": [[362, 1226], [453, 1140], [453, 1140], [503, 1140]]}, {"src": "B", "dst": "I", "kind": "data", "curve": [[345, 1226], [453, 1015], [453, 1015], [513, 1015]]}, {"src": "C", "dst": "J", "kind": "data", "curve": [[351, 746], [453, 890], [453, 890], [496, 890]]}, {"src": "C", "dst": "K", "kind": "data", "curve": [[395, 746], [453, 773], [453, 773], [510, 773]]}, {"src": "C", "dst": "L", "kind": "data", "curve": [[395, 684], [453, 656], [453, 656], [510, 656]]}, {"src": "C", "dst": "M", "kind": "data", "curve": [[351, 684], [453, 539], [453, 539], [496, 539]]}, {"src": "D", "dst": "N", "kind": "data", "curve": [[350, 266], [453, 422], [453, 422], [513, 422]]}, {"src": "D", "dst": "O", "kind": "data", "curve": [[391, 266], [453, 297], [453, 297], [513, 297]]}, {"src": "D", "dst": "P", "kind": "data", "curve": [[391, 204], [453, 172], [453, 172], [527, 172]]}, {"src": "D", "dst": "Q", "kind": "data", "curve": [[350, 204], [453, 55], [453, 55], [492, 55]]}, {"src": "E", "dst": "R", "kind": "data", "curve": [[673, 1491], [722, 1491], [722, 1491], [845, 1288]]}, {"src": "F", "dst": "R", "kind": "data", "curve": [[683, 1374], [722, 1374], [722, 1374], [826, 1288]]}, {"src": "G", "dst": "R", "kind": "data", "line": [666, 1257, 761, 1257]}, {"src": "H", "dst": "R", "kind": "data", "curve": [[673, 1140], [722, 1140], [722, 1140], [826, 1226]]}, {"src": "I", "dst": "R", "kind": "data", "curve": [[662, 1015], [722, 1015], [722, 1015], [845, 1226]]}]});
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
      const container = document.getElementById('ntificinnovationanalysis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ntificinnovationanalysis-1';
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

AI-Researcher consists of three core components:

1. **Research Agent**: Handles every stage of the research process.
2. **Paper Agent**: Converts research findings into academic papers.
3. **Benchmark Suite**: A multidimensional quality evaluation system.

### 🔄 Detailed Execution Flow

```mermaid
flowchart TD
    START["🎬 Start: Research Topic Input"] --> LEVEL{"Select Research Level"}
    
    LEVEL -->|Level 1<br/>Using Existing Ideas| L1_SURVEY["📚 Literature Review<br/>Starting from Existing Ideas"]
    LEVEL -->|Level 2<br/>Generating New Ideas| L2_PAPERS["📄 Idea Generation<br/>from Reference Papers Only"]
    
    L1_SURVEY --> EXPERIMENT["🧪 Experiment Design & Implementation"]
    L2_PAPERS --> IDEA_GEN["💡 New Research<br/>Idea Generation"]
    IDEA_GEN --> EXPERIMENT
    
    EXPERIMENT --> CODE_IMPL["⚙️ Algorithm<br/>Code Implementation"]
    CODE_IMPL --> VALIDATION["✅ Result Validation<br/>& Analysis"]
    VALIDATION --> REFINEMENT["🔧 Code Optimization<br/>& Improvement"]
    
    REFINEMENT --> PAPER_GEN["📝 Paper Generation Start"]
    PAPER_GEN --> HIERARCHICAL["🏗️ Hierarchical Writing<br/>Approach Applied"]
    
    HIERARCHICAL --> SECTIONS["📋 Paper Section Writing"]
    SECTIONS --> INTRO["🎯 Introduction & Motivation"]
    SECTIONS --> METHODS["🔬 Methodology"]
    SECTIONS --> RESULTS["📊 Experimental Results"]
    SECTIONS --> CONCLUSION["🎉 Conclusion"]
    
    INTRO --> INTEGRATE["🔗 Section Integration"]
    METHODS --> INTEGRATE
    RESULTS --> INTEGRATE
    CONCLUSION --> INTEGRATE
    
    INTEGRATE --> REVIEW["👀 Automated Review<br/>& Quality Check"]
    REVIEW --> POLISH["✨ Final Revision<br/>& Completion"]
    
    POLISH --> FINAL["🎊 Completed Paper<br/>Output"]
    
    subgraph DOCKER["🐳 Docker Environment"]
        CODE_IMPL
        VALIDATION
        REFINEMENT
    end
    
    subgraph BENCHMARK["📏 Benchmark Evaluation"]
        NOVELTY["🌟 Novelty"]
        EXPERIMENTAL["🔬 Experimental Completeness"]
        THEORETICAL["📖 Theoretical Foundation"]
        ANALYSIS["📈 Result Analysis"]
        WRITING["✍️ Writing Quality"]
    end
    
    FINAL --> BENCHMARK
    
    style START fill:#e3f2fd
    style DOCKER fill:#f1f8e9
    style BENCHMARK fill:#fff3e0
    style FINAL fill:#e8f5e8
```

The system supports two research levels:

- **Level 1**: In-depth research and experimentation building on existing research ideas.
- **Level 2**: Full cycle from new idea generation to experimentation, using reference papers only.

## Technology Stack and Tool Ecosystem

### 🛠️ Integrated Technology Architecture

```mermaid
graph LR
    subgraph AI_MODELS["🤖 AI Model Layer"]
        CLAUDE["🎭 Claude 3.5<br/>Sonnet/Haiku"]
        OPENAI["🧠 OpenAI<br/>GPT Models"]
        DEEPSEEK["🔍 DeepSeek<br/>Models"]
        OTHERS["⚡ Other LLM<br/>Providers"]
    end
    
    subgraph CORE_SYSTEM["🎯 Core System"]
        MAIN["🚀 main_ai_researcher.py<br/>(Main Orchestrator)"]
        GLOBAL["🌐 global_state.py<br/>(Global State Management)"]
        WEB["🌍 web_ai_researcher.py<br/>(Web Interface)"]
    end
    
    subgraph AGENTS["🤝 Agent System"]
        RA["📚 Research Agent<br/>(Research Execution)"]
        PA["✍️ Paper Agent<br/>(Paper Writing)"]
        EA["📊 Evaluator Agent<br/>(Evaluation)"]
    end
    
    subgraph EXECUTION["⚙️ Execution Environment"]
        DOCKER["🐳 Docker<br/>Container"]
        SCRIPTS["📜 Shell Scripts<br/>(run_infer_*.sh)"]
        PYTHON["🐍 Python<br/>Environment"]
        GPU["💾 GPU Support<br/>(CUDA)"]
    end
    
    subgraph BENCHMARK["📏 Benchmark System"]
        EVAL_DATA["📊 Evaluation<br/>Datasets"]
        METRICS["📈 Performance<br/>Metrics"]
        DOMAINS["🎯 Multi-Domain<br/>Testing"]
        GROUND_TRUTH["✅ Expert<br/>Ground Truth"]
    end
    
    subgraph OUTPUT["📤 Outputs"]
        PAPERS["📄 Academic<br/>Papers"]
        CODE["💻 Research<br/>Code"]
        RESULTS["📊 Experimental<br/>Results"]
        REPORTS["📝 Analysis<br/>Reports"]
    end
    
    AI_MODELS --> CORE_SYSTEM
    CORE_SYSTEM --> AGENTS
    AGENTS --> EXECUTION
    EXECUTION --> BENCHMARK
    BENCHMARK --> OUTPUT
    
    RA --> |"Literature Review<br/>Experiment Design"| EXECUTION
    PA --> |"Paper Writing<br/>Structuring"| EXECUTION
    EA --> |"Quality Evaluation<br/>Validation"| BENCHMARK
    
    style AI_MODELS fill:#e3f2fd
    style CORE_SYSTEM fill:#f3e5f5
    style AGENTS fill:#e8f5e8
    style EXECUTION fill:#fff3e0
    style BENCHMARK fill:#ffebee
    style OUTPUT fill:#f1f8e9
```

## Core Innovations

### 1. 🎯 Fully Automated Research Pipeline

**Overcoming the limits of traditional research processes:**

- **Removing human cognitive bias**: AI determines research direction based on objective data.
- **24/7 research execution**: Continuous research without time constraints.
- **Large-scale literature processing**: Simultaneous analysis of vast bodies of literature that would be impractical for a human researcher.

### 2. 🤝 Intelligent Agent Collaboration

**Role division among specialized agents:**

- **Research Agent**: Handles literature review, gap analysis, and hypothesis validation.
- **Paper Agent**: Produces publication-quality papers using a hierarchical writing approach.
- **Evaluator Agent**: Performs multidimensional quality assessment (novelty, experimental completeness, theoretical grounding, and more).

### 3. 🌍 Versatility and Accessibility

**Democratizing research:**

- **Minimal expertise required**: High-quality research is achievable without deep domain specialization.
- **Multi-LLM support**: Different AI models can be selected to suit the task at hand.
- **Docker-based execution**: Consistent runtime environment ensures reproducible research.

### 4. 📊 Objective Evaluation System

**Standardized quality assessment framework:**

- **4 major domains**: Computer Vision, NLP, Data Mining, Information Retrieval.
- **Expert-level standards**: Evaluation benchmarked against papers written by human experts.
- **Multidimensional metrics**: Novelty, experimental design, theoretical background, result analysis, and writing quality.

## Benchmark and Evaluation Framework

### 📏 Comprehensive Evaluation Framework

AI-Researcher has built the following broad evaluation structure:

**Evaluation Dimensions:**

1. **🌟 Novelty**: Originality and innovation of research ideas.
2. **🔬 Experimental Comprehensiveness**: Rigor of experimental design and execution.
3. **📖 Theoretical Foundation**: Soundness of theoretical grounding.
4. **📈 Result Analysis**: Depth and accuracy of result interpretation.
5. **✍️ Writing Quality**: Clarity and structure of the paper.

**Domain Coverage:**

- **Computer Vision (CV)**: Image recognition, object detection, segmentation.
- **Natural Language Processing (NLP)**: Language models, text classification, machine translation.
- **Data Mining (DM)**: Pattern discovery, clustering, recommendation systems.
- **Information Retrieval (IR)**: Search algorithms, ranking, query optimization.

## Applicability in Research Environments

### 🔬 How Research Institutions Can Apply This

**1. Academic Research Labs**

- **Accelerating graduate research**: Automating literature review reduces time spent on foundational tasks.
- **Cross-disciplinary research**: Bridges gaps when domain expertise is limited.
- **Standardizing research quality**: Objective evaluation criteria help maintain consistent quality.

**2. Corporate R&D**

- **Technology scouting**: Analyzing large volumes of patents and papers to track technology trends.
- **Faster product development**: Automating algorithm prototyping.
- **Reducing R&D costs**: Minimizing manual effort in early-stage research.

**3. Policy and Public Research Support**

- **National R&D efficiency**: Supporting evaluation and direction-setting for research programs.
- **Researcher development**: A tool for building research skills among early-career scientists.
- **Global competitiveness**: Real-time analysis of global research trends to inform strategy.

### 🚀 Considerations for Adoption

**Technical requirements:**

- **Computing resources**: GPU clusters or cloud environments are needed.
- **Data infrastructure**: Large-scale paper databases must be available.
- **Security framework**: Research data protection and intellectual property management.

**Organizational changes:**

- **Research culture shift**: Building awareness of AI-collaborative research methods.
- **Training programs**: Educating researchers on how to use AI-Researcher effectively.
- **Revised evaluation criteria**: Establishing new standards for AI-assisted research.

## Future Outlook and Development Directions

### 🔮 Technical Evolution

**1. Multimodal Research Expansion**

- **Image-text integration**: Combined analysis of visual data and text.
- **Speech and language linkage**: Expanding research into speech-based data.
- **Sensor data utilization**: Analyzing diverse data collected from IoT environments.

**2. Real-Time Research Adaptation**

- **Dynamic literature updates**: Real-time adjustment of research direction as new papers are published.
- **Trend prediction**: Forecasting future research topics through trend analysis.
- **Collaborative networks**: Real-time collaboration platforms for researchers worldwide.

### 🌏 Societal Impact

**1. Improved Research Accessibility**

- **Bridging regional gaps**: Strengthening research capacity in areas with limited infrastructure.
- **Removing language barriers**: Expanding global research participation through multilingual support.
- **Reducing cost barriers**: Open-source foundations dramatically lower research costs.

**2. Acceleration of Scientific Progress**

- **Democratizing discovery**: Creating conditions where anyone can contribute to scientific findings.
- **Cross-disciplinary synthesis**: Automatically connecting and integrating knowledge across different fields.
- **Improved reproducibility**: Standardized experimental environments ensure research reproducibility.

## Conclusion

AI-Researcher is more than a research tool. It represents a system that **changes the paradigm of scientific research itself**. Through fully autonomous research execution, intelligent agent collaboration, and an objective evaluation framework, it raises both the efficiency and quality of research simultaneously.

Across research environments more broadly, the following positive changes are worth noting:

1. **Research productivity**: Automation of the full pipeline, from literature review to paper writing.
2. **Quality standardization**: Consistent quality through objective evaluation criteria.
3. **Improved accessibility**: Removing domain expertise barriers so more researchers can participate.
4. **Faster response to global trends**: Quicker adaptation to developments in the global research landscape.

The future that AI-Researcher points toward is a new era where humans and AI collaborate to achieve **more creative and original scientific discoveries**. Adoption and further development of this technology could bring meaningful change to research communities around the world.

## References

- [AI-Researcher GitHub Repository](https://github.com/HKUDS/AI-Researcher)
- [Paper: "AI-Researcher: Autonomous Scientific Innovation"](https://arxiv.org/abs/2505.18705)
- [Project Official Website](https://hkuds.github.io/AI-Researcher/)
- [Community Slack Channel](https://join.slack.com/t/ai-researcher/shared_invite/)
- [Discord Server](https://discord.gg/ai-researcher)
