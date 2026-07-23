---
title: "Cutting Token Cost by 34-71% with Reversible Compression: A Headroom Field Report and ThakiCloud Context Hygiene"
excerpt: "The biggest hidden cost of an AI coding agent is context. We ran Headroom (headroom-ai) directly against three real JSON tool outputs from the ThakiCloud repo and measured the token reduction. We walk through how SmartCrusher's lossless, reversible compression cut tokens by up to 71.2%, from install command to measured numbers."
seo_title: "Headroom Reversible Context Compression Field Report - Thaki Cloud"
seo_description: "Measuring Headroom (headroom-ai) SmartCrusher reversible JSON compression on real repo data (34-71% token reduction), install and integration commands, and K8s LLM serving token-cost and context-hygiene analysis"
date: 2026-06-21
last_modified_at: 2026-06-21
tags: [headroom, context-compression, token-cost, llm-serving, rag, mcp]
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/headroom-reversible-context-compression/"
reading_time: true
categories:
  - dev
published: false
---

![Abstract image of data condensing]({{ '/assets/images/headroom-reversible-context-compression-hero.webp' | relative_url }})
*Context is not free. Condensing scattered tokens losslessly is what Headroom does.*

## Overview

Any team running AI coding agents daily knows where the biggest hidden cost comes from. It is context. Tool outputs, RAG results, logs, files, and conversation history pile up every turn, and those tokens become the bill. In multi-agent workflows this cost grows not linearly but multiplicatively, because every time one subagent drops a large search-result JSON into context, the cache-read tokens grow alongside it.

This post is not a simple tool introduction. ThakiCloud already runs Headroom in its production tool chain, and this time we pulled three real JSON tool outputs from our own repo and ran Headroom directly against them. We document the install command, the integration code, and the measured token reductions in a reproducible form. The short version: the more repetitive the JSON structure, the larger the savings, and on our data the token reduction reached up to 71.2%. Every number was measured in a real sandbox, with no estimates mixed in.

## What Is Headroom

Headroom (PyPI package `headroom-ai`, GitHub `chopratejas/headroom`) is a context-compression tool open-sourced by ex-Netflix engineer Tejas Chopra. Its stated goal is clear: compress tool outputs, logs, files, and RAG chunks before they reach the LLM, reducing tokens while keeping the answer identical.

Most existing context-reduction tools are irreversible. Once you cut, you cannot get the original back. Headroom's key differentiator is that it runs locally, covers multiple content types, and is reversible. The original can be restored within a configured TTL via breadcrumb hashes. This structurally prevents the classic failure of "we compressed and the agent lost the details." You can run on the compressed version by default and restore the original only when a specific section is needed.

There are three ways to attach it: as a library you call directly, as a proxy, or as an MCP server. It recognizes content type and compresses selectively, keeping only the outliers in JSON or only the failure lines in logs.

### Internals: SmartCrusher Is the Core

Headroom routes to a different compressor per content type. In this experiment the transforms that actually fired showed up in the router log as `router:protected:user_message` and `router:mixed:...`, meaning it protects the user message and compresses only the JSON payload of tool messages.

- **SmartCrusher**: a general-purpose JSON compressor that handles arrays of dicts, nested objects, and mixed types. For repetitive JSON tool output (search results, log rows, record lists) it folds redundant keys and infers schema to reduce deterministically. It accounted for most of the savings in our measurement.
- **Code compressor**: structure-aware source-code compression.
- **Image compression**: image payloads are also reduced.

The diagram below is the data flow we observed. Tool output passes through the router into SmartCrusher, and while the compressed context goes to the LLM call, the original is stored separately for reversible restoration when needed.

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
<div class="d3-arch" data-arch-root id="rsiblecontextcompression-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 762, "height": 804, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 186, "y": 24, "w": 120, "h": 46, "title": "Tool Output"}, {"id": "B", "x": 363, "y": 148, "w": 163, "h": 46, "title": "Content-Type Router"}, {"id": "C", "x": 354, "y": 272, "w": 181, "h": 52, "title": "Content Type Branch"}, {"id": "D", "x": 563, "y": 416, "w": 156, "h": 78, "title": ["SmartCrusher", "Deterministic JSON", "Compression"]}, {"id": "E", "x": 373, "y": 432, "w": 135, "h": 46, "title": "Code Compressor"}, {"id": "F", "x": 176, "y": 432, "w": 142, "h": 46, "title": "Image Compressor"}, {"id": "G", "x": 362, "y": 580, "w": 156, "h": 46, "title": "Compressed Context"}, {"id": "H", "x": 186, "y": 726, "w": 120, "h": 46, "title": "LLM Call"}, {"id": "I", "x": 24, "y": 572, "w": 142, "h": 62, "title": ["Original Store", "Reversible Store"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[306, 66], [445, 109], [445, 109], [445, 148]]}, {"src": "B", "dst": "C", "kind": "data", "line": [445, 194, 445, 272]}, {"src": "C", "dst": "D", "kind": "data", "label": "JSON arrays / nested objects", "curve": [[516, 324], [641, 370], [641, 370], [641, 416]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "Source code", "line": [443, 324, 440, 432], "lx": 440, "ly": 366}, {"src": "C", "dst": "F", "kind": "data", "label": "Images", "curve": [[373, 324], [247, 370], [247, 370], [247, 432]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[641, 494], [641, 533], [641, 533], [506, 580]]}, {"src": "E", "dst": "G", "kind": "data", "line": [440, 478, 440, 580]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[247, 478], [247, 533], [247, 533], [377, 580]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[440, 626], [440, 680], [440, 680], [306, 728]]}, {"src": "A", "dst": "I", "kind": "event", "label": "breadcrumb hash + TTL", "curve": [[190, 70], [95, 233], [95, 455], [95, 572]], "off": "50%"}, {"src": "I", "dst": "H", "kind": "event", "label": "reversible restore", "curve": [[95, 634], [95, 680], [95, 680], [196, 726]], "off": "50%"}]});
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
      const container = document.getElementById('rsiblecontextcompression-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rsiblecontextcompression-1';
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
*Headroom data flow: tool output is routed through a content-type router, compressed by SmartCrusher, and delivered to the LLM — while the original is held in a reversible store with TTL. Click the diagram to enlarge.*

## Install and Integration

Our Python runtime is unified into a single interpreter (3.12.8) `.venv`. Installation is one line.

```bash
VIRTUAL_ENV="$PWD/.venv" uv pip install "headroom-ai[code,relevance]"
```

The `[code,relevance]` extra enables code structure-aware compression and relevance-based filtering. Semantic compression of plain text needs an additional model (about 261MB), but the highest-impact JSON path works with this base install alone.

Integration is simplest by passing a message list directly. The core of the wrapper we actually use (`scripts/headroom_compress.py`) is below. Put the tool output as the `content` of a `tool`-role message and call `compress`.

```python
from headroom import compress

messages = [
    {"role": "user", "content": "Summarize this tool output"},
    {"role": "assistant", "content": None,
     "tool_calls": [{"id": "c1", "type": "function",
                     "function": {"name": "tool", "arguments": "{}"}}]},
    {"role": "tool", "tool_call_id": "c1", "content": raw_json_string},
]

result = compress(messages, model="claude-sonnet-4-5-20250929")
compressed = result.messages[-1]["content"]
print(result.tokens_before, "->", result.tokens_after, result.transforms_applied)
```

The object `compress` returns carries `tokens_before`, `tokens_after`, and `transforms_applied`, so code can verify after the fact what the compression actually did. The point is that these are values the library measured, not numbers the model self-reports. On top of that we cross-checked once more with a separate tokenizer (tiktoken).

## Real Experiment Results

The experiment ran in an isolated git worktree sandbox. The structure never touches the main working tree and keeps only results in an evidence directory. The test data is three of our repo's real artifacts with clearly repetitive JSON structure.

1. **skill_index.json**: a BM25 index for skill search. Records with identical schema repeat at scale.
2. **seedance-prompts/raw-prompts.json**: a catalog of 605 prompts. Natural-language text is the dominant share.
3. **twitter timeline archive**: 1,385 timeline records. An array of objects with identical key structure.

Token counts were measured with the `cl100k_base` tokenizer. We recorded both bytes and tokens because compression should be judged not by raw byte savings but by how much it helps in the actual billing unit, the token. The results are below.

| Test data | Original tokens | Compressed tokens | Token reduction | Byte reduction | Time |
|---|---|---|---|---|---|
| skill_index (BM25 index) | 1,618,287 | 465,445 | **71.2%** | 64.9% | 2.08s |
| twitter-timeline (record array) | 399,926 | 192,465 | **51.9%** | 57.0% | 0.24s |
| seedance-prompts (prompt catalog) | 1,085,592 | 713,210 | **34.3%** | 38.5% | 0.57s |

![Measured compression chart]({{ '/assets/images/headroom-reversible-context-compression-results.webp' | relative_url }})
*Measured reduction rates for three JSON tool outputs from the ThakiCloud repo. Bytes and tokens are shown together.*

How to read the numbers matters. **The more repetitive the structure, the larger the savings.** skill_index is an index of densely repeating identical-schema records, so SmartCrusher's key folding maximizes and cut tokens by a full 71.2%. The twitter timeline, also a uniform object array, was reduced by more than half. By contrast seedance-prompts, where natural-language prompt text makes up most of each record, had little room to trim via structural compression and landed at 34.3%. This difference directly demonstrates the design intent that "JSON is where it works best."

The timing is also worth noting. It processed a 1.6-million-token index in two seconds, and the rest in under a second. That is fast enough to inline right before tool output enters context with almost no perceptible latency. Because the compression is deterministic, the same input always yields the same output, which is also cache-friendly.

One honest caveat. The numbers above are single-run measurements over three datasets. On other kinds of JSON, especially data with mostly unique values and few repeated keys, the reduction may be lower. Still, within our measured range, a span of 34-71% token reduction is a clearly meaningful result, at least for repetitive-structure tool output.

## Application to the ThakiCloud K8s AI/ML SaaS Platform

The point where we adopted Headroom is exactly what the experiment above shows: **repetitive-structure, large JSON tool output.** Our context-hygiene rule (`ecc-token-strategy`) spells this out: repetitive-structure JSON array tool output is compressed deterministically with SmartCrusher before entering context, plain text is not a target but JSON is, and the priority is subagent summarization first, then headroom compression.

The reason this matters so much in K8s multi-agent orchestration is the structure of the cost. In a workflow where many subagents run, context hygiene means three things at once. First, token cost control. Second, cache hit-rate management; deterministic compression guarantees identical output for identical input, so it does not break the prompt cache. Third, latency management; the smaller the context, the faster the model responds.

Our LLM serving schedules GPU workloads with Kueue on top of K8s, and many inference requests flow concurrently. In this environment, a bloated context costs more than one request; it eats overall throughput. Headroom lets us insert this layer with almost no code change. We compress a search-result or log array in one line right before it enters context, and restore reversibly only when a specific section is needed.

It is practical from a data-scientist's perspective too. In a RAG pipeline where retrieved chunks come loaded with repetitive metadata (identical keys like source URL, timestamp, score), that metadata is precisely the area SmartCrusher trims best. Because it preserves the body and reduces only the structural overhead, you secure context budget without sacrificing retrieval accuracy.

## Limitations and Counterarguments

We do not recommend this tool uncritically. Here are the honest limitations and counterarguments.

**First, local execution is a precondition.** Headroom needs to run a local process, so it cannot be used in fully sandboxed, isolated execution environments. There are deployment shapes this constraint does not fit.

**Second, the effect on plain text is limited.** As the seedance-prompts result shows, data with a high share of natural-language text has little room to trim via structural compression. Reducing plain text semantically requires an additional model, and that path gives up some determinism and speed.

**Third, it may be overkill for single-provider teams.** If one model provider's native compaction is enough and you do not need cross-agent memory, the operational burden of adding a separate compression layer may outweigh the gain.

**Fourth, the strongest counterargument is "couldn't you just summarize with a subagent?"** In fact our own rule prioritizes subagent summarization over headroom compression. Summarization is irreversible but reduces far more and compresses by meaning. So where does Headroom fit? The answer is "when summarizing would lose details that might be needed later." Reversibility fills exactly this gap. You run on the compressed version normally, and the moment you need the original of a specific record, you restore it precisely within the TTL. Summarization and compression are not competitors but complements.

In short, Headroom implements the principle that "context is not free" with the concrete design of reversible compression. Within our measured range it cut tokens by 34-71% on repetitive-structure JSON, and thanks to determinism and reversibility it neither broke the cache nor lost the details. If you are an engineer interested in how ThakiCloud treats context hygiene as a cost and reliability problem, we are the place that runs this layer in production.

---

Sources: Headroom (headroom-ai), PyPI https://pypi.org/project/headroom-ai/ · GitHub https://github.com/chopratejas/headroom (author Tejas Chopra). The figures in this post are measured directly on ThakiCloud repo data.
