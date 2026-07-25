---
title: "AWS Agent Squad: Complete Tutorial for Multi-Agent Orchestration Framework"
excerpt: "Comprehensive guide to AWS Labs' Agent Squad framework - from basic setup to advanced multi-agent orchestration with Python and TypeScript implementations"
seo_title: "AWS Agent Squad Tutorial: Multi-Agent Orchestration Framework Guide"
seo_description: "Learn AWS Agent Squad framework for multi-agent AI orchestration. Complete tutorial with Python/TypeScript examples, Bedrock integration, and real-world implementations."
date: 2025-09-07
tags:
  - aws
  - agent-squad
  - multi-agent
  - orchestration
  - bedrock
  - ai-agents
  - python
  - typescript
author_profile: true
toc: true
toc_label: "Tutorial Contents"
lang: en
permalink: /en/tutorials/aws-agent-squad-multi-agent-orchestration-framework-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/aws-agent-squad-multi-agent-orchestration-framework-tutorial/"
published: false
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction to Agent Squad

AWS Labs' **Agent Squad** (formerly Multi-Agent Orchestrator) is a flexible, lightweight open-source framework designed for orchestrating multiple AI agents to handle complex conversations. With over 6.6k GitHub stars and growing community support, it represents a significant advancement in multi-agent AI systems.

### What Makes Agent Squad Special?

Agent Squad addresses the growing need for intelligent conversation routing in AI applications. Instead of having a single AI agent handle all queries, it intelligently distributes conversations to specialized agents based on context and intent.

## Key Features and Capabilities

### 🧠 Intelligent Intent Classification
The framework dynamically routes queries to the most suitable agent based on:
- **Context analysis**: Understanding conversation flow and history
- **Content evaluation**: Analyzing query semantics and intent
- **Agent specialization**: Matching queries to agent expertise

### 🔤 Dual Language Support
Full implementation in both **Python** and **TypeScript**:
- Identical functionality across languages
- Language-specific optimizations
- Seamless integration with existing codebases

### 🌊 Flexible Response Handling
Support for both streaming and non-streaming responses:
- **Real-time streaming**: For interactive conversations
- **Batch processing**: For analytical tasks
- **Mixed mode support**: Different agents can use different response types

### 📚 Context Management
Sophisticated conversation context handling:
- **Cross-agent memory**: Maintain context when switching between agents
- **Session persistence**: Remember conversation history
- **Context inheritance**: Pass relevant information between agents

## Architecture Overview

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
<div class="d3-arch" data-arch-root id="ationframeworktutorialen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 716, "height": 1100, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 302, "y": 24, "w": 120, "h": 46, "title": "User Query"}, {"id": "B", "x": 263, "y": 148, "w": 198, "h": 46, "title": "Agent Squad Orchestrator"}, {"id": "C", "x": 287, "y": 272, "w": 149, "h": 46, "title": "Intent Classifier"}, {"id": "D", "x": 289, "y": 396, "w": 146, "h": 52, "title": "Route Decision"}, {"id": "E", "x": 564, "y": 526, "w": 120, "h": 46, "title": "Tech Agent"}, {"id": "F", "x": 389, "y": 526, "w": 120, "h": 46, "title": "Health Agent"}, {"id": "G", "x": 214, "y": 526, "w": 120, "h": 46, "title": "Travel Agent"}, {"id": "H", "x": 32, "y": 526, "w": 120, "h": 46, "title": "Custom Agent"}, {"id": "I", "x": 564, "y": 650, "w": 120, "h": 46, "title": "Bedrock LLM"}, {"id": "J", "x": 389, "y": 650, "w": 120, "h": 46, "title": "OpenAI GPT"}, {"id": "K", "x": 214, "y": 650, "w": 120, "h": 46, "title": "Lex Bot"}, {"id": "L", "x": 24, "y": 650, "w": 135, "h": 46, "title": "Lambda Function"}, {"id": "M", "x": 291, "y": 774, "w": 142, "h": 46, "title": "Response Handler"}, {"id": "N", "x": 294, "y": 898, "w": 135, "h": 46, "title": "Context Manager"}, {"id": "O", "x": 298, "y": 1022, "w": 128, "h": 46, "title": "Final Response"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [362, 70, 362, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [362, 194, 362, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [362, 318, 362, 396]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[435, 440], [624, 487], [624, 487], [624, 526]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[397, 448], [449, 487], [449, 487], [449, 526]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[327, 448], [274, 487], [274, 487], [274, 526]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[289, 440], [92, 487], [92, 487], [92, 526]]}, {"src": "E", "dst": "I", "kind": "data", "line": [624, 572, 624, 650]}, {"src": "F", "dst": "J", "kind": "data", "line": [449, 572, 449, 650]}, {"src": "G", "dst": "K", "kind": "data", "line": [274, 572, 274, 650]}, {"src": "H", "dst": "L", "kind": "data", "line": [92, 572, 92, 650]}, {"src": "I", "dst": "M", "kind": "data", "curve": [[624, 696], [624, 735], [624, 735], [433, 780]]}, {"src": "J", "dst": "M", "kind": "data", "curve": [[449, 696], [449, 735], [449, 735], [394, 774]]}, {"src": "K", "dst": "M", "kind": "data", "curve": [[274, 696], [274, 735], [274, 735], [329, 774]]}, {"src": "L", "dst": "M", "kind": "data", "curve": [[92, 696], [92, 735], [92, 735], [291, 781]]}, {"src": "M", "dst": "N", "kind": "data", "line": [362, 820, 362, 898]}, {"src": "N", "dst": "O", "kind": "data", "line": [362, 944, 362, 1022]}]});
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
      const container = document.getElementById('ationframeworktutorialen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ationframeworktutorialen-1';
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

The architecture consists of:
1. **Orchestrator**: Central routing and management
2. **Classifiers**: Intent detection and agent selection
3. **Agents**: Specialized AI components
4. **Context Manager**: Memory and state management
5. **Response Handler**: Output processing and formatting

## Installation and Setup

### Python Installation

Agent Squad offers modular installation options based on your integration needs:

```bash
# Basic AWS integration (most common)
pip install "agent-squad[aws]"

# OpenAI integration
pip install "agent-squad[openai]"

# Anthropic integration
pip install "agent-squad[anthropic]"

# Full installation with all integrations
pip install "agent-squad[all]"
```

### Environment Setup

Create a virtual environment for isolation:

```bash
# Create virtual environment
python -m venv agent-squad-env
source agent-squad-env/bin/activate  # On Windows: agent-squad-env\Scripts\activate

# Install with AWS support
pip install "agent-squad[aws]"
```

### TypeScript/Node.js Installation

```bash
# Initialize new project
npm init -y

# Install Agent Squad
npm install @awslabs/agent-squad

# Install AWS SDK (if using AWS integrations)
npm install @aws-sdk/client-bedrock-runtime
```

## Basic Implementation Tutorial

### Python Implementation

Let's create a basic multi-agent system with specialized agents:

```python
import sys
import asyncio
from agent_squad.orchestrator import AgentSquad
from agent_squad.agents import BedrockLLMAgent, BedrockLLMAgentOptions, AgentStreamResponse

class AgentSquadTutorial:
    def __init__(self):
        # Initialize the orchestrator
        self.orchestrator = AgentSquad()
        
        # Configure agents
        self._setup_agents()
    
    def _setup_agents(self):
        """Configure specialized agents for different domains"""
        
        # Technology specialist agent
        tech_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="Technology Expert",
            streaming=True,
            description="""Expert in software development, cloud computing, AI/ML, 
                         cybersecurity, blockchain, and emerging technologies. 
                         Provides technical guidance, architecture advice, and 
                         cost analysis for technology solutions.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # Health and wellness agent
        health_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="Health & Wellness Expert",
            streaming=True,
            description="""Specializes in health, wellness, nutrition, fitness, 
                         mental health, and medical information. Provides 
                         evidence-based health guidance and wellness tips.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # Business and finance agent
        business_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="Business & Finance Expert",
            streaming=True,
            description="""Expert in business strategy, financial planning, 
                         market analysis, entrepreneurship, and business 
                         operations. Provides strategic business insights.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # Add agents to orchestrator
        self.orchestrator.add_agent(tech_agent)
        self.orchestrator.add_agent(health_agent)
        self.orchestrator.add_agent(business_agent)
    
    async def process_query(self, user_input, user_id="user123", session_id="session456"):
        """Process a user query through the agent squad"""
        
        try:
            # Route the request to appropriate agent
            response = await self.orchestrator.route_request(
                user_input=user_input,
                user_id=user_id,
                session_id=session_id,
                additional_params={},
                streaming=True
            )
            
            # Handle the response
            await self._handle_response(response)
            
        except Exception as e:
            print(f"Error processing query: {e}")
    
    async def _handle_response(self, response):
        """Handle both streaming and non-streaming responses"""
        
        if response.streaming:
            print("\n🤖 **STREAMING RESPONSE**\n")
            
            # Display metadata
            self._print_metadata(response.metadata)
            
            print("\n📝 **Response:**")
            
            # Stream the content
            async for chunk in response.output:
                if isinstance(chunk, AgentStreamResponse):
                    print(chunk.text, end='', flush=True)
                else:
                    print(f"Unexpected chunk type: {type(chunk)}", file=sys.stderr)
            
            print("\n")  # New line after streaming
            
        else:
            # Handle non-streaming response
            print("\n🤖 **RESPONSE**\n")
            self._print_metadata(response.metadata)
            print(f"\n📝 **Response:** {response.output.content}")
    
    def _print_metadata(self, metadata):
        """Print response metadata in a formatted way"""
        print(f"🎯 **Agent:** {metadata.agent_name} (ID: {metadata.agent_id})")
        print(f"👤 **User:** {metadata.user_id}")
        print(f"🔗 **Session:** {metadata.session_id}")
        print(f"❓ **Query:** {metadata.user_input}")
        if metadata.additional_params:
            print(f"⚙️ **Parameters:** {metadata.additional_params}")

# Example usage and testing
async def main():
    """Main function to demonstrate Agent Squad capabilities"""
    
    # Initialize the tutorial system
    agent_system = AgentSquadTutorial()
    
    # Test queries for different domains
    test_queries = [
        "What are the best practices for implementing microservices architecture?",
        "How can I improve my cardiovascular health through diet and exercise?",
        "What should I consider when creating a business plan for a tech startup?",
        "Explain the differences between Docker containers and virtual machines",
        "What are some effective stress management techniques for busy professionals?"
    ]
    
    print("🚀 **Agent Squad Tutorial Demo**\n")
    print("=" * 50)
    
    for i, query in enumerate(test_queries, 1):
        print(f"\n**Test Query {i}:**")
        print("-" * 30)
        await agent_system.process_query(query)
        print("=" * 50)

if __name__ == "__main__":
    asyncio.run(main())
```

### TypeScript Implementation

Here's the equivalent TypeScript implementation:

```typescript
import { AgentSquad } from '@awslabs/agent-squad';
import { BedrockLLMAgent, BedrockLLMAgentOptions } from '@awslabs/agent-squad';

class AgentSquadTutorial {
    private orchestrator: AgentSquad;
    
    constructor() {
        this.orchestrator = new AgentSquad();
        this.setupAgents();
    }
    
    private setupAgents(): void {
        // Technology expert agent
        const techAgent = new BedrockLLMAgent({
            name: 'Technology Expert',
            streaming: true,
            description: `Expert in software development, cloud computing, AI/ML, 
                         cybersecurity, blockchain, and emerging technologies.`,
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
        } as BedrockLLMAgentOptions);
        
        // Health and wellness agent
        const healthAgent = new BedrockLLMAgent({
            name: 'Health & Wellness Expert',
            streaming: true,
            description: `Specializes in health, wellness, nutrition, fitness, 
                         mental health, and medical information.`,
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
        } as BedrockLLMAgentOptions);
        
        // Add agents to orchestrator
        this.orchestrator.addAgent(techAgent);
        this.orchestrator.addAgent(healthAgent);
    }
    
    async processQuery(
        userInput: string, 
        userId: string = 'user123', 
        sessionId: string = 'session456'
    ): Promise<void> {
        try {
            const response = await this.orchestrator.routeRequest(
                userInput,
                userId,
                sessionId,
                {},
                true
            );
            
            await this.handleResponse(response);
            
        } catch (error) {
            console.error('Error processing query:', error);
        }
    }
    
    private async handleResponse(response: any): Promise<void> {
        if (response.streaming) {
            console.log('\n🤖 **STREAMING RESPONSE**\n');
            
            // Display metadata
            this.printMetadata(response.metadata);
            
            console.log('\n📝 **Response:**');
            
            // Handle streaming response
            for await (const chunk of response.output) {
                if (chunk.text) {
                    process.stdout.write(chunk.text);
                }
            }
            
            console.log('\n');
            
        } else {
            console.log('\n🤖 **RESPONSE**\n');
            this.printMetadata(response.metadata);
            console.log(`\n📝 **Response:** ${response.output.content}`);
        }
    }
    
    private printMetadata(metadata: any): void {
        console.log(`🎯 **Agent:** ${metadata.agentName} (ID: ${metadata.agentId})`);
        console.log(`👤 **User:** ${metadata.userId}`);
        console.log(`🔗 **Session:** ${metadata.sessionId}`);
        console.log(`❓ **Query:** ${metadata.userInput}`);
    }
}

// Example usage
async function main() {
    const agentSystem = new AgentSquadTutorial();
    
    const testQueries = [
        "What are the latest trends in cloud computing?",
        "How can I maintain good mental health while working remotely?"
    ];
    
    console.log('🚀 **Agent Squad Tutorial Demo (TypeScript)**\n');
    
    for (const query of testQueries) {
        await agentSystem.processQuery(query);
        console.log('='.repeat(50));
    }
}

main().catch(console.error);
```

## Advanced Configuration

### Custom Agent Creation

You can create custom agents by extending the base agent class:

```python
from agent_squad.agents import Agent, AgentOptions
from typing import Optional, Dict, Any

class CustomDatabaseAgent(Agent):
    def __init__(self, options: AgentOptions):
        super().__init__(options)
        # Initialize database connections, tools, etc.
        
    async def process_request(
        self, 
        input_text: str, 
        user_id: str, 
        session_id: str, 
        chat_history: list,
        additional_params: Optional[Dict[str, Any]] = None
    ):
        # Custom processing logic
        # Query databases, perform calculations, etc.
        
        # Return structured response
        return {
            "content": "Database query results...",
            "metadata": {
                "query_time": "0.5s",
                "records_found": 42
            }
        }
```

### Advanced Orchestrator Configuration

```python
from agent_squad.orchestrator import AgentSquad
from agent_squad.classifiers import BedrockClassifier, BedrockClassifierOptions

# Create orchestrator with custom classifier
classifier = BedrockClassifier(BedrockClassifierOptions(
    model_id="anthropic.claude-3-haiku-20240307-v1:0",
    inference_config={
        "maxTokens": 1000,
        "temperature": 0.1
    }
))

orchestrator = AgentSquad(
    classifier=classifier,
    logger=custom_logger,
    config={
        "LOG_AGENT_CHAT": True,
        "LOG_CLASSIFIER_CHAT": True,
        "LOG_CLASSIFIER_RAW_OUTPUT": True,
        "LOG_CLASSIFIER_OUTPUT": True,
        "LOG_EXECUTION_TIMES": True,
        "MAX_RETRIES": 3,
        "USE_DEFAULT_AGENT_IF_NONE_IDENTIFIED": True,
        "MAX_TOKENS": 1000,
        "TEMPERATURE": 0.1
    }
)
```

## Real-World Use Cases and Examples

### Customer Service Automation

```python
async def setup_customer_service_agents():
    """Setup specialized customer service agents"""
    
    orchestrator = AgentSquad()
    
    # Technical support agent
    tech_support = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="Technical Support",
        description="Handles technical issues, troubleshooting, and product support",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    # Billing and account agent
    billing_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="Billing Support",
        description="Handles billing inquiries, account management, and payment issues",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    # General information agent
    info_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="Information Agent",
        description="Provides general company information, policies, and basic inquiries",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    orchestrator.add_agent(tech_support)
    orchestrator.add_agent(billing_agent)
    orchestrator.add_agent(info_agent)
    
    return orchestrator
```

### Educational Platform

```python
async def setup_educational_agents():
    """Setup agents for different academic subjects"""
    
    orchestrator = AgentSquad()
    
    subjects = [
        ("Mathematics", "Expert in mathematics, calculus, statistics, and problem-solving"),
        ("Science", "Specializes in physics, chemistry, biology, and scientific concepts"),
        ("Literature", "Expert in literature analysis, writing, and language arts"),
        ("History", "Specializes in world history, historical analysis, and social studies")
    ]
    
    for name, description in subjects:
        agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name=f"{name} Tutor",
            description=description,
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
            streaming=True
        ))
        orchestrator.add_agent(agent)
    
    return orchestrator
```

## Performance Optimization

### Connection Pooling and Caching

```python
from agent_squad.orchestrator import AgentSquad
import asyncio
from functools import lru_cache

class OptimizedAgentSquad:
    def __init__(self):
        self.orchestrator = AgentSquad()
        self._connection_pool = self._setup_connection_pool()
        self._setup_caching()
    
    def _setup_connection_pool(self):
        """Setup connection pooling for better performance"""
        # Configure connection pools for different services
        return {
            'bedrock': self._create_bedrock_pool(),
            'openai': self._create_openai_pool(),
        }
    
    @lru_cache(maxsize=1000)
    def _cached_classification(self, query_hash: str):
        """Cache classification results for similar queries"""
        # Implementation for caching classification results
        pass
    
    async def batch_process_queries(self, queries: list):
        """Process multiple queries concurrently"""
        tasks = [
            self.orchestrator.route_request(query, f"user_{i}", f"session_{i}")
            for i, query in enumerate(queries)
        ]
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results
```

### Monitoring and Logging

```python
import logging
import time
from functools import wraps

class AgentSquadMonitor:
    def __init__(self, orchestrator):
        self.orchestrator = orchestrator
        self.logger = logging.getLogger('agent_squad_monitor')
        self._setup_monitoring()
    
    def _setup_monitoring(self):
        """Setup comprehensive monitoring"""
        self.metrics = {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'average_response_time': 0,
            'agent_usage': {}
        }
    
    def monitor_request(self, func):
        """Decorator to monitor request performance"""
        @wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()
            self.metrics['total_requests'] += 1
            
            try:
                result = await func(*args, **kwargs)
                self.metrics['successful_requests'] += 1
                
                # Track agent usage
                agent_name = result.metadata.agent_name
                self.metrics['agent_usage'][agent_name] = \
                    self.metrics['agent_usage'].get(agent_name, 0) + 1
                
                return result
                
            except Exception as e:
                self.metrics['failed_requests'] += 1
                self.logger.error(f"Request failed: {e}")
                raise
                
            finally:
                # Update average response time
                response_time = time.time() - start_time
                self._update_average_response_time(response_time)
        
        return wrapper
    
    def _update_average_response_time(self, response_time):
        """Update running average of response times"""
        current_avg = self.metrics['average_response_time']
        total_requests = self.metrics['total_requests']
        
        self.metrics['average_response_time'] = \
            (current_avg * (total_requests - 1) + response_time) / total_requests
    
    def get_performance_report(self):
        """Generate performance report"""
        return {
            'summary': self.metrics,
            'success_rate': self.metrics['successful_requests'] / self.metrics['total_requests'] * 100,
            'most_used_agent': max(self.metrics['agent_usage'], 
                                 key=self.metrics['agent_usage'].get) if self.metrics['agent_usage'] else None
        }
```

## Deployment Strategies

### AWS Lambda Deployment

```python
import json
import asyncio
from agent_squad.orchestrator import AgentSquad
from agent_squad.agents import BedrockLLMAgent, BedrockLLMAgentOptions

# Global orchestrator instance for Lambda container reuse
orchestrator = None

def lambda_handler(event, context):
    """AWS Lambda handler for Agent Squad"""
    
    global orchestrator
    
    # Initialize orchestrator on cold start
    if orchestrator is None:
        orchestrator = setup_orchestrator()
    
    # Extract request data
    body = json.loads(event['body'])
    user_input = body['message']
    user_id = body.get('user_id', 'anonymous')
    session_id = body.get('session_id', 'default')
    
    # Process request
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    try:
        response = loop.run_until_complete(
            orchestrator.route_request(user_input, user_id, session_id)
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'response': response.output.content,
                'agent': response.metadata.agent_name,
                'success': True
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'success': False
            })
        }
    
    finally:
        loop.close()

def setup_orchestrator():
    """Setup orchestrator with production configuration"""
    squad = AgentSquad()
    
    # Add production agents
    tech_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="Production Tech Agent",
        description="Production-ready technical support agent",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    squad.add_agent(tech_agent)
    return squad
```

### Docker Deployment

```dockerfile
# Dockerfile for Agent Squad application
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements and install Python dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application code
COPY . .

# Expose port
EXPOSE 8000

# Set environment variables
ENV PYTHONPATH=/app
ENV AWS_DEFAULT_REGION=us-east-1

# Run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Best Practices and Tips

### 1. Agent Design Principles

- **Single Responsibility**: Each agent should have a clearly defined domain
- **Clear Descriptions**: Write detailed agent descriptions for better routing
- **Performance Optimization**: Use appropriate model sizes for different tasks
- **Error Handling**: Implement robust error handling and fallback mechanisms

### 2. Context Management

```python
# Effective context management
async def manage_conversation_context(orchestrator, user_id, session_id):
    """Best practices for context management"""
    
    # Store important context information
    context = {
        'user_preferences': get_user_preferences(user_id),
        'conversation_history': get_conversation_history(session_id),
        'current_task': 'information_gathering'
    }
    
    # Pass context through additional_params
    response = await orchestrator.route_request(
        user_input="Continue our previous discussion",
        user_id=user_id,
        session_id=session_id,
        additional_params=context
    )
    
    return response
```

### 3. Security Considerations

```python
# Input validation and sanitization
def validate_input(user_input: str) -> bool:
    """Validate user input for security"""
    
    # Check for malicious content
    forbidden_patterns = [
        r'<script.*?</script>',
        r'javascript:',
        r'on\w+\s*='
    ]
    
    import re
    for pattern in forbidden_patterns:
        if re.search(pattern, user_input, re.IGNORECASE):
            return False
    
    # Check input length
    if len(user_input) > 10000:
        return False
    
    return True

# Rate limiting implementation
from collections import defaultdict
import time

class RateLimiter:
    def __init__(self, max_requests=100, time_window=3600):
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests = defaultdict(list)
    
    def is_allowed(self, user_id: str) -> bool:
        now = time.time()
        user_requests = self.requests[user_id]
        
        # Remove old requests
        self.requests[user_id] = [
            req_time for req_time in user_requests 
            if now - req_time < self.time_window
        ]
        
        # Check if under limit
        if len(self.requests[user_id]) < self.max_requests:
            self.requests[user_id].append(now)
            return True
        
        return False
```

## Troubleshooting Guide

### Common Issues and Solutions

1. **Agent Selection Problems**
   ```python
   # Debug agent selection
   orchestrator.config['LOG_CLASSIFIER_OUTPUT'] = True
   orchestrator.config['LOG_CLASSIFIER_RAW_OUTPUT'] = True
   ```

2. **Memory Issues with Large Contexts**
   ```python
   # Implement context truncation
   def truncate_context(context, max_length=8000):
       if len(context) > max_length:
           return context[-max_length:]
       return context
   ```

3. **Performance Bottlenecks**
   ```python
   # Implement async processing
   import asyncio
   
   async def process_multiple_requests(requests):
       tasks = [process_single_request(req) for req in requests]
       return await asyncio.gather(*tasks)
   ```

## Testing Your Implementation

Create a comprehensive test suite:

```python
import pytest
import asyncio
from agent_squad.orchestrator import AgentSquad

class TestAgentSquad:
    @pytest.fixture
    async def orchestrator(self):
        """Setup test orchestrator"""
        squad = AgentSquad()
        # Add test agents
        return squad
    
    @pytest.mark.asyncio
    async def test_tech_query_routing(self, orchestrator):
        """Test that tech queries route to tech agent"""
        response = await orchestrator.route_request(
            "How do I deploy a Docker container?",
            "test_user",
            "test_session"
        )
        
        assert "tech" in response.metadata.agent_name.lower()
    
    @pytest.mark.asyncio
    async def test_streaming_response(self, orchestrator):
        """Test streaming functionality"""
        response = await orchestrator.route_request(
            "Explain machine learning",
            "test_user",
            "test_session",
            streaming=True
        )
        
        assert response.streaming is True
        
        # Collect streamed content
        content = ""
        async for chunk in response.output:
            content += chunk.text
        
        assert len(content) > 0
```

## Conclusion

Agent Squad represents a powerful evolution in multi-agent AI systems, offering:

- **Intelligent routing** for better user experiences
- **Flexible architecture** supporting various AI providers
- **Production-ready features** for enterprise deployments
- **Strong community support** and active development

The framework's dual-language support (Python/TypeScript) and modular design make it an excellent choice for both prototyping and production deployments. Whether you're building customer service systems, educational platforms, or complex conversational AI applications, Agent Squad provides the foundation for sophisticated multi-agent orchestration.

### Next Steps

1. **Experiment** with the basic implementation
2. **Customize agents** for your specific use case
3. **Implement monitoring** and performance optimization
4. **Deploy** to your preferred cloud platform
5. **Contribute** to the open-source community

For more advanced features and enterprise support, explore the [official documentation](https://awslabs.github.io/agent-squad/) and join the growing community of Agent Squad developers.

---

*This tutorial provides a comprehensive foundation for working with AWS Agent Squad. As the framework continues to evolve, stay updated with the latest features and best practices through the official repository and documentation.*
