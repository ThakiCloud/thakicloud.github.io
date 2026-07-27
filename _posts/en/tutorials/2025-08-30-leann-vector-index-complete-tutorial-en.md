---
title: "LEANN: Complete Tutorial for the Revolutionary Vector Index with 97% Storage Savings"
excerpt: "Master LEANN, the groundbreaking vector index system that delivers 97% storage savings while maintaining fast, accurate search. Complete guide from installation to advanced usage"
seo_title: "LEANN Vector Index Tutorial - 97% Storage Savings RAG System"
seo_description: "Learn LEANN, the revolutionary vector index system offering 97% storage savings. Complete tutorial covering installation, usage, and advanced features for efficient RAG applications"
date: 2025-08-30
tags:
  - LEANN
  - vector-index
  - RAG
  - storage-optimization
  - machine-learning
  - AI
  - vector-database
  - embedding
author_profile: true
toc: true
toc_label: "LEANN Tutorial"
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/leann-vector-index-complete-tutorial-en/"
lang: en
permalink: /en/tutorials/leann-vector-index-complete-tutorial/
published: false
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 12 minutes

> **TL;DR** LEANN is a revolutionary vector index system that achieves **97% storage savings** compared to traditional vector databases while maintaining fast and accurate search capabilities. This comprehensive tutorial covers everything from basic installation to advanced usage, enabling you to build efficient RAG applications with minimal storage requirements.

---

## What is LEANN?

LEANN (Low-Storage Vector Index) is a groundbreaking vector index system developed by Berkeley Sky Computing Lab that fundamentally reimagines how vector databases work. Instead of storing every single embedding (which is expensive), LEANN stores a pruned graph structure and recomputes embeddings only when needed.

### The Storage Revolution

Traditional vector databases like FAISS store all embeddings in memory, leading to massive storage requirements:

| Dataset | Traditional DB | LEANN | Savings |
|---------|---------------|-------|---------|
| DPR (2.1M docs) | 3.8 GB | 324 MB | **91%** |
| Wikipedia (60M docs) | 201 GB | 6 GB | **97%** |
| Chat (400K docs) | 1.8 GB | 64 MB | **97%** |
| Email (780K docs) | 2.4 GB | 79 MB | **97%** |

### Key Innovation: Graph-Based Selective Recomputation

LEANN's magic lies in its core techniques:

- **Graph-based selective recomputation**: Only compute embeddings for nodes in the search path
- **High-degree preserving pruning**: Keep important "hub" nodes while removing redundant connections
- **Dynamic batching**: Efficiently batch embedding computations for GPU utilization
- **Two-level search**: Smart graph traversal that prioritizes promising nodes

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
<div class="d3-arch" data-arch-root id="rindexcompletetutorialen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1026, "height": 1048, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 204, "y": 24, "w": 385, "h": 124, "label": "Storage Layer", "lx": 216, "ly": 42}, {"x": 609, "y": 24, "w": 385, "h": 124, "label": "Search Engine", "lx": 621, "ly": 42}], "nodes": [{"id": "A", "x": 38, "y": 63, "w": 128, "h": 46, "title": "Document Input"}, {"id": "B", "x": 42, "y": 226, "w": 121, "h": 46, "title": "Text Chunking"}, {"id": "C", "x": 24, "y": 350, "w": 156, "h": 46, "title": "Graph Construction"}, {"id": "D", "x": 28, "y": 474, "w": 149, "h": 46, "title": "Pruning Algorithm"}, {"id": "E", "x": 35, "y": 598, "w": 135, "h": 46, "title": "Compact Storage"}, {"id": "F", "x": 232, "y": 474, "w": 120, "h": 46, "title": "Search Query"}, {"id": "G", "x": 225, "y": 598, "w": 135, "h": 46, "title": "Query Embedding"}, {"id": "H", "x": 130, "y": 722, "w": 135, "h": 46, "title": "Graph Traversal"}, {"id": "I", "x": 102, "y": 846, "w": 191, "h": 46, "title": "Selective Recomputation"}, {"id": "J", "x": 130, "y": 970, "w": 135, "h": 46, "title": "Results Ranking"}, {"id": "K", "x": 241, "y": 63, "w": 120, "h": 46, "title": "Metadata"}, {"id": "L", "x": 416, "y": 63, "w": 135, "h": 46, "title": "Graph Structure"}, {"id": "M", "x": 646, "y": 63, "w": 120, "h": 46, "title": "HNSW Backend"}, {"id": "N", "x": 821, "y": 63, "w": 135, "h": 46, "title": "DiskANN Backend"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [102, 109, 102, 226]}, {"src": "B", "dst": "C", "kind": "data", "line": [102, 272, 102, 350]}, {"src": "C", "dst": "D", "kind": "data", "line": [102, 396, 102, 474]}, {"src": "D", "dst": "E", "kind": "data", "line": [102, 520, 102, 598]}, {"src": "F", "dst": "G", "kind": "data", "line": [292, 520, 292, 598]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[292, 644], [292, 683], [292, 683], [232, 722]]}, {"src": "H", "dst": "I", "kind": "data", "line": [197, 768, 197, 846]}, {"src": "I", "dst": "J", "kind": "data", "line": [197, 892, 197, 970]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[102, 644], [102, 683], [102, 683], [162, 722]]}]});
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
      const container = document.getElementById('rindexcompletetutorialen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rindexcompletetutorialen-1';
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

## Installation Guide

### Prerequisites

- **Python**: 3.9 or higher
- **Operating System**: macOS, Linux (Windows support coming soon)
- **Memory**: Minimum 4GB RAM (8GB+ recommended)
- **Storage**: Varies by dataset size (significantly less than traditional vector DBs)

### Quick Start Installation

```bash
# Create a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install uv for faster package management
pip install uv

# Clone LEANN repository
git clone https://github.com/yichuan-w/LEANN.git
cd LEANN

# Initialize submodules (required for compilation)
git submodule update --init --recursive

# Install LEANN
uv pip install -e .

# Verify installation
leann --help
```

### Global Installation (Recommended)

For system-wide access and Claude Code integration:

```bash
# Install globally using uv tool
uv tool install leann-core --with leann

# Verify global installation
leann --help
```

## Basic Usage Tutorial

### 1. Building Your First Index

Let's start with a simple example using markdown documents:

```bash
# Create test documents
mkdir test-docs
cat > test-docs/ai-overview.md << 'EOF'
# Artificial Intelligence Overview

AI is transforming how we work and live. Key areas include:

## Machine Learning
- Supervised learning
- Unsupervised learning  
- Reinforcement learning

## Deep Learning
- Neural networks
- Convolutional networks
- Transformer architectures

## Applications
- Natural language processing
- Computer vision
- Robotics and automation
EOF

# Build index
leann build ai-knowledge --docs ./test-docs
```

**Expected Output:**
```
📂 Indexing 1 path:
  📁 Directories (1):
    1. /path/to/test-docs
Loading documents from 1 directory...
🔄 Processing 1 directory...
Loaded 1 documents, 3 chunks
Building index 'ai-knowledge' with hnsw backend...
Index built at .leann/indexes/ai-knowledge/documents.leann
```

### 2. Searching Your Index

```bash
# Basic search
leann search ai-knowledge "What is machine learning?"

# Search with more results
leann search ai-knowledge "neural networks" --top-k 10

# Advanced search with complexity tuning
leann search ai-knowledge "AI applications" --complexity 128
```

### 3. Interactive Q&A

```bash
# Start interactive chat (requires Ollama)
leann ask ai-knowledge --interactive

# Use specific LLM provider
leann ask ai-knowledge --llm openai --model gpt-4

# Single question mode
leann ask ai-knowledge "Explain deep learning concepts"
```

### 4. Index Management

```bash
# List all indexes
leann list

# Remove an index
leann remove ai-knowledge

# Force removal without confirmation
leann remove ai-knowledge --force
```

## Advanced Features

### Multi-Source Indexing

LEANN excels at indexing diverse content types:

```bash
# Index multiple directories and files
leann build comprehensive-docs \
  --docs ./documentation ./source-code ./config-files

# Index specific file types only
leann build presentations \
  --docs ./content \
  --file-types .pptx,.pdf,.docx

# Mixed content indexing
leann build mixed-content \
  --docs ./readme.md ./src/ ./config.json ./docs/
```

### Backend Selection

LEANN offers two powerful backends:

#### HNSW Backend (Default)
- **Best for**: Most use cases, maximum storage savings
- **Features**: Full recomputation, optimal for memory-constrained environments

```bash
leann build my-index --docs ./data --backend hnsw
```

#### DiskANN Backend
- **Best for**: Large-scale datasets requiring maximum search speed
- **Features**: PQ-based graph traversal with real-time reranking

```bash
leann build my-index --docs ./data --backend diskann
```

### Performance Tuning

#### Build Parameters

```bash
# High-quality index (slower build, better search)
leann build high-quality \
  --docs ./data \
  --graph-degree 64 \
  --complexity 128

# Fast build (quicker indexing, good for development)
leann build fast-build \
  --docs ./data \
  --graph-degree 16 \
  --complexity 32

# Compact storage (maximum space savings)
leann build compact \
  --docs ./data \
  --compact
```

#### Search Optimization

```bash
# High-precision search
leann search my-index "query" \
  --complexity 128 \
  --top-k 20

# Fast search (lower precision)
leann search my-index "query" \
  --complexity 32 \
  --top-k 5

# Pruning strategies
leann search my-index "query" \
  --pruning-strategy proportional
```

### Metadata Filtering

LEANN supports sophisticated metadata filtering:

```python
# Python API example
from leann import IndexBuilder, IndexSearcher

# Build with metadata
builder = IndexBuilder("filtered-index")
builder.add_text(
    "Python is a programming language",
    metadata={"language": "python", "difficulty": "beginner"}
)
builder.add_text(
    "Advanced machine learning concepts",
    metadata={"topic": "ml", "difficulty": "advanced"}
)
builder.build()

# Search with filters
searcher = IndexSearcher("filtered-index")
results = searcher.search(
    "programming concepts",
    metadata_filters={
        "difficulty": {"==": "beginner"},
        "language": {"in": ["python", "javascript"]}
    }
)
```

**Supported filter operators:**
- `==`, `!=`: Equality/inequality
- `<`, `<=`, `>`, `>=`: Numerical comparisons
- `in`, `not_in`: List membership
- `contains`, `starts_with`, `ends_with`: String operations
- `is_true`, `is_false`: Boolean values

## Code-Aware Indexing

LEANN provides intelligent code processing with AST-aware chunking:

```bash
# Index source code with intelligent chunking
leann build codebase \
  --docs ./src ./tests ./config \
  --file-types .py,.js,.ts,.java,.cs

# The system automatically:
# - Parses AST structure
# - Preserves function/class boundaries
# - Maintains code context
# - Indexes comments and docstrings
```

**Supported languages:**
- Python
- JavaScript/TypeScript
- Java
- C#
- More languages coming soon

## Integration Examples

### Claude Code Integration

LEANN integrates seamlessly with Claude Code via MCP (Model Context Protocol):

1. **Install globally** (required):
```bash
uv tool install leann-core --with leann
```

2. **Configure Claude Code** by adding to your MCP settings:
```json
{
  "mcpServers": {
    "leann": {
      "command": "leann_mcp"
    }
  }
}
```

3. **Use in Claude Code**:
```
@leann search my-codebase "authentication logic"
@leann ask my-docs "How to implement OAuth?"
```

### Python API Usage

```python
from leann import IndexBuilder, IndexSearcher

# Build index programmatically
builder = IndexBuilder("my-index")
builder.add_directory("./documents")
builder.add_file("./important-doc.pdf")
builder.build(backend="hnsw", graph_degree=32)

# Search programmatically
searcher = IndexSearcher("my-index")
results = searcher.search("machine learning", top_k=10)

for result in results:
    print(f"Score: {result.score}")
    print(f"Content: {result.content[:200]}...")
    print(f"Metadata: {result.metadata}")
    print("---")
```

### LangChain Integration

```python
from leann.integrations.langchain import LeannVectorStore
from langchain.chains import RetrievalQA
from langchain.llms import Ollama

# Create LEANN vector store
vector_store = LeannVectorStore("my-index")

# Create retrieval chain
llm = Ollama(model="llama2")
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 5})
)

# Ask questions
response = qa_chain.run("What are the key features of this system?")
print(response)
```

## Performance Benchmarks

### Storage Comparison

Real-world storage savings across different datasets:

```bash
# Run benchmarks (requires dev dependencies)
uv pip install -e ".[dev]"
python benchmarks/run_evaluation.py

# Custom benchmark with your data
python benchmarks/run_evaluation.py /path/to/your/data --num-queries 1000
```

### Speed vs. Accuracy Trade-offs

| Configuration | Build Time | Search Speed | Accuracy | Storage |
|---------------|------------|--------------|----------|---------|
| Fast | 1x | 5ms | 85% | 95% savings |
| Balanced | 2x | 8ms | 92% | 96% savings |
| High-Quality | 4x | 12ms | 97% | 97% savings |

## Troubleshooting

### Common Issues

#### 1. Submodule Initialization Error
```bash
# Error: CMakeLists.txt not found
git submodule update --init --recursive
```

#### 2. Memory Issues During Build
```bash
# Use compact storage for large datasets
leann build large-index --docs ./big-data --compact

# Or process in smaller batches
leann build batch1 --docs ./data/part1
leann build batch2 --docs ./data/part2
```

#### 3. Search Returns No Results
```bash
# Check index status
leann list

# Verify index integrity
leann search my-index "test query" --top-k 1

# Rebuild if corrupted
leann remove my-index --force
leann build my-index --docs ./data
```

#### 4. Slow Search Performance
```bash
# Reduce complexity for faster search
leann search my-index "query" --complexity 32

# Use appropriate backend
leann build my-index --docs ./data --backend diskann
```

### Performance Optimization Tips

1. **Choose the right backend**:
   - HNSW: Maximum storage savings, good for most use cases
   - DiskANN: Better search performance for large datasets

2. **Tune build parameters**:
   - Higher `graph-degree`: Better connectivity, larger index
   - Higher `complexity`: Better quality, slower build

3. **Optimize search parameters**:
   - Lower `complexity`: Faster search, lower precision
   - Appropriate `top-k`: Balance between speed and completeness

4. **Use metadata filtering**:
   - Pre-filter documents to reduce search space
   - Combine with semantic search for best results

## Best Practices

### 1. Document Preparation

```bash
# Good: Organize documents logically
project/
├── docs/           # Documentation
├── code/          # Source code
├── configs/       # Configuration files
└── examples/      # Example files

# Index with appropriate chunking
leann build project-knowledge --docs ./project
```

### 2. Index Naming Strategy

```bash
# Use descriptive names
leann build customer-support-kb --docs ./support-docs
leann build api-documentation --docs ./api-docs
leann build codebase-v2-1 --docs ./src

# Avoid generic names
leann build docs --docs ./documents  # Too generic
leann build index1 --docs ./data     # Not descriptive
```

### 3. Regular Maintenance

```bash
# List and clean up old indexes
leann list
leann remove outdated-index

# Rebuild indexes when source documents change significantly
leann remove old-version --force
leann build new-version --docs ./updated-docs
```

### 4. Production Deployment

```bash
# Use consistent build parameters for production
leann build production-index \
  --docs ./production-docs \
  --backend diskann \
  --graph-degree 64 \
  --complexity 128 \
  --compact

# Test search performance
time leann search production-index "test query"
```

## Advanced Use Cases

### 1. Multi-Language Documentation

```bash
# Index documentation in multiple languages
leann build multilang-docs \
  --docs ./docs/en ./docs/ko ./docs/ja

# Search works across all languages
leann search multilang-docs "installation guide"
```

### 2. Version-Controlled Knowledge Base

```bash
# Create versioned indexes
leann build kb-v1.0 --docs ./docs/v1.0
leann build kb-v1.1 --docs ./docs/v1.1
leann build kb-latest --docs ./docs/latest

# Compare search results across versions
leann search kb-v1.0 "feature X"
leann search kb-latest "feature X"
```

### 3. Hybrid Search Systems

```python
# Combine LEANN with traditional search
from leann import IndexSearcher
import elasticsearch

def hybrid_search(query, top_k=10):
    # Semantic search with LEANN
    leann_searcher = IndexSearcher("my-index")
    semantic_results = leann_searcher.search(query, top_k=top_k//2)
    
    # Keyword search with Elasticsearch
    es_results = elasticsearch_search(query, size=top_k//2)
    
    # Combine and rerank results
    return combine_results(semantic_results, es_results)
```

## Future Roadmap

LEANN is actively developed with exciting features coming:

- **Windows Support**: Native Windows compatibility
- **Distributed Indexing**: Scale across multiple machines
- **Real-time Updates**: Incremental index updates
- **More Backends**: Additional optimization strategies
- **Cloud Integration**: Native cloud storage support
- **Advanced Filtering**: More sophisticated metadata queries

## Conclusion

LEANN represents a paradigm shift in vector indexing, offering unprecedented storage efficiency without sacrificing search quality. Its innovative graph-based approach makes it ideal for:

- **Resource-constrained environments** where storage is premium
- **Large-scale RAG applications** requiring efficient retrieval
- **Edge computing scenarios** with limited memory
- **Cost-sensitive deployments** where storage costs matter

By following this tutorial, you now have the knowledge to leverage LEANN's revolutionary capabilities in your own projects. The 97% storage savings, combined with fast and accurate search, makes LEANN an essential tool for modern AI applications.

### Next Steps

1. **Experiment** with your own datasets
2. **Integrate** LEANN into existing RAG pipelines  
3. **Contribute** to the open-source project
4. **Share** your experiences with the community

---

**🔗 Useful Links:**
- [LEANN GitHub Repository](https://github.com/yichuan-w/LEANN)
- [Research Paper](https://arxiv.org/abs/2506.08276)
- [Berkeley Sky Computing Lab](https://sky.cs.berkeley.edu/)
- [Community Discussions](https://github.com/yichuan-w/LEANN/discussions)

**⭐ Star the project** if you find LEANN useful for your work!
