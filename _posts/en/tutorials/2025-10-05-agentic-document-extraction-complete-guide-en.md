---
title: "Complete Guide to LandingAI Agentic Document Extraction: AI-Powered PDF and Image Processing"
excerpt: "Master LandingAI's Agentic Document Extraction library for intelligent document processing. Extract structured data from complex PDFs, images, and documents with AI-powered parsing capabilities."
seo_title: "LandingAI Agentic Document Extraction Tutorial - AI PDF Processing Guide"
seo_description: "Learn how to use LandingAI's Agentic Document Extraction library for AI-powered document processing. Complete tutorial with code examples, batch processing, and visualization features."
date: 2025-10-05
tags:
  - LandingAI
  - Document-Extraction
  - AI
  - PDF-Processing
  - Python
  - Machine-Learning
  - OCR
  - Document-AI
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/agentic-document-extraction-complete-guide/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/agentic-document-extraction-complete-guide-en/"
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

In today's data-driven world, extracting structured information from complex documents like PDFs, images, and charts is a critical challenge for businesses and developers. Traditional OCR solutions often struggle with visually complex layouts, tables, and mixed content types. This is where **LandingAI's Agentic Document Extraction** library comes to the rescue.

The Agentic Document Extraction API is a powerful Python library that leverages advanced AI to pull structured data from visually complex documents and returns hierarchical JSON with exact element locations. Whether you're dealing with financial reports, research papers, or multi-page technical documentation, this library provides enterprise-grade document processing capabilities.

## What is Agentic Document Extraction?

LandingAI's Agentic Document Extraction is an AI-powered document processing library that excels at:

- **Complex Layout Understanding**: Handles tables, pictures, charts, and mixed content layouts
- **Long Document Support**: Processes 100+ page PDFs in a single call
- **Structured Output**: Returns hierarchical JSON with exact element locations
- **Visual Grounding**: Provides bounding box information for extracted content
- **Batch Processing**: Handles multiple documents simultaneously with parallel processing

**Figure 1. Agentic Document Extraction processing pipeline.**

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
<div class="d3-arch" data-arch-root id="xtractioncompleteguideen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 531, "height": 770, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IN", "x": 152, "y": 24, "w": 205, "h": 62, "title": ["Input: PDF / Image / URL,", "any length"]}, {"id": "SPLIT", "x": 166, "y": 164, "w": 177, "h": 46, "title": "Auto-split 100+ pages"}, {"id": "BATCH", "x": 152, "y": 288, "w": 205, "h": 46, "title": "Parallel Batch Processing"}, {"id": "PARSE", "x": 163, "y": 412, "w": 184, "h": 62, "title": ["Layout Parser: tables,", "figures, charts"]}, {"id": "JSON", "x": 173, "y": 552, "w": 163, "h": 62, "title": ["Hierarchical JSON +", "Bounding Boxes"]}, {"id": "MD", "x": 291, "y": 692, "w": 177, "h": 46, "title": "Render-ready Markdown"}, {"id": "VIS", "x": 24, "y": 692, "w": 212, "h": 46, "title": "Visual Grounding and Debug"}], "edges": [{"src": "IN", "dst": "SPLIT", "kind": "data", "line": [255, 86, 255, 164]}, {"src": "SPLIT", "dst": "BATCH", "kind": "data", "line": [255, 210, 255, 288]}, {"src": "BATCH", "dst": "PARSE", "kind": "data", "line": [255, 334, 255, 412]}, {"src": "PARSE", "dst": "JSON", "kind": "data", "line": [255, 474, 255, 552]}, {"src": "JSON", "dst": "MD", "kind": "data", "curve": [[310, 614], [380, 653], [380, 653], [380, 692]]}, {"src": "JSON", "dst": "VIS", "kind": "data", "curve": [[200, 614], [130, 653], [130, 653], [130, 692]]}, {"src": "PARSE", "dst": "PARSE", "kind": "event", "label": "retry with backoff", "curve": [[347, 425], [426, 412], [426, 474], [347, 461]], "off": "50%"}]});
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
      const container = document.getElementById('xtractioncompleteguideen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'xtractioncompleteguideen-1';
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

### Key Features

- 📦 **Simple Installation**: One-line pip install with no additional dependencies
- 🗂️ **Universal File Support**: PDFs of any length, images, and URLs
- 📚 **Enterprise Scale**: Auto-split and parallel processing for 1000+ page documents
- 🧩 **Structured Output**: Hierarchical JSON plus ready-to-render Markdown
- 👁️ **Visual Debugging**: Bounding box snippets and full-page visualizations
- 🏃 **Parallel Processing**: Configurable batch processing with thread management
- 🔄 **Resilient**: Automatic retry with exponential backoff for API errors
- ⚙️ **Flexible Configuration**: Environment-based settings for production deployment

## Prerequisites and Setup

### System Requirements

- Python 3.9, 3.10, 3.11, or 3.12
- LandingAI API key (obtain from [LandingAI](https://landing.ai/))
- Internet connection for API calls

### Installation

The installation process is straightforward with pip:

```bash
# Install the agentic-doc library
pip install agentic-doc

# Verify installation
python -c "import agentic_doc; print('Installation successful!')"
```

### API Key Configuration

After obtaining your LandingAI API key, configure it as an environment variable:

```bash
# Set API key as environment variable
export VISION_AGENT_API_KEY=your-api-key-here

# Or create a .env file in your project directory
echo "VISION_AGENT_API_KEY=your-api-key-here" > .env
```

For production environments, consider using secure secret management systems rather than plain text environment variables.

## Basic Usage Examples

### Simple Document Parsing

Let's start with the most basic usage - parsing a single document:

```python
from agentic_doc.parse import parse

# Parse a local PDF file
results = parse("path/to/your/document.pdf")

# Parse from URL
results = parse("https://example.com/document.pdf")

# Parse an image
results = parse("path/to/your/image.jpg")

# Access the parsed content
parsed_doc = results[0]
print(f"Document title: {parsed_doc.title}")
print(f"Number of chunks: {len(parsed_doc.chunks)}")
print(f"Markdown content: {parsed_doc.markdown}")
```

### Understanding the Result Structure

The library returns a structured result with the following key components:

```python
from agentic_doc.parse import parse

results = parse("document.pdf")
parsed_doc = results[0]

# Document metadata
print(f"Title: {parsed_doc.title}")
print(f"Page count: {parsed_doc.page_count}")
print(f"Processing time: {parsed_doc.processing_time}")

# Iterate through content chunks
for i, chunk in enumerate(parsed_doc.chunks):
    print(f"Chunk {i}:")
    print(f"  Type: {chunk.chunk_type}")
    print(f"  Content: {chunk.content[:100]}...")  # First 100 chars
    print(f"  Page: {chunk.page}")
    print(f"  Bounding box: {chunk.grounding[0].bbox if chunk.grounding else 'N/A'}")
    print("---")

# Get the full markdown representation
markdown_content = parsed_doc.markdown
print("Full document as Markdown:")
print(markdown_content)
```

## Advanced Features

### Processing Large PDF Files

One of the library's standout features is its ability to handle large documents automatically:

```python
from agentic_doc.parse import parse

# The library automatically handles large PDFs
# by splitting them into manageable chunks and processing in parallel
results = parse("very-large-document.pdf")

parsed_doc = results[0]
print(f"Successfully processed {parsed_doc.page_count} pages")

# Check for any processing errors
if parsed_doc.errors:
    print("Processing errors encountered:")
    for error in parsed_doc.errors:
        print(f"  Page {error.page}: {error.message}")
```

### Batch Processing Multiple Documents

Process multiple documents simultaneously with configurable parallelism:

```python
from agentic_doc.parse import parse

# Process multiple documents in batch
document_paths = [
    "document1.pdf",
    "document2.pdf", 
    "https://example.com/document3.pdf",
    "image.jpg"
]

# Batch processing with default settings
results = parse(document_paths)

# Process results
for i, parsed_doc in enumerate(results):
    print(f"Document {i+1}: {parsed_doc.title}")
    print(f"  Pages: {parsed_doc.page_count}")
    print(f"  Chunks: {len(parsed_doc.chunks)}")
    
    # Check for errors
    if parsed_doc.errors:
        print(f"  Errors: {len(parsed_doc.errors)}")
```

### Visual Grounding and Debugging

Extract and save visual regions where content was found:

```python
from agentic_doc.parse import parse

# Parse document and save grounding images
results = parse(
    "document.pdf",
    grounding_save_dir="./grounding_images"
)

parsed_doc = results[0]

# Print paths to saved grounding images
for chunk in parsed_doc.chunks:
    for grounding in chunk.grounding:
        if grounding.image_path:
            print(f"Grounding saved to: {grounding.image_path}")
```

### Document Visualization

Create annotated visualizations showing extraction results:

```python
from agentic_doc.parse import parse
from agentic_doc.utils import viz_parsed_document
from agentic_doc.config import VisualizationConfig
from agentic_doc.schema import ChunkType

# Parse document
results = parse("document.pdf")
parsed_doc = results[0]

# Create visualizations with default settings
images = viz_parsed_document(
    "document.pdf",
    parsed_doc,
    output_dir="./visualizations"
)

# Customize visualization appearance
viz_config = VisualizationConfig(
    thickness=3,  # Thicker bounding boxes
    text_bg_opacity=0.9,  # More opaque text background
    font_scale=0.8,  # Larger text
    color_map={
        ChunkType.TITLE: (255, 0, 0),    # Red for titles
        ChunkType.TEXT: (0, 255, 0),     # Green for text
        ChunkType.TABLE: (0, 0, 255),    # Blue for tables
    }
)

# Create custom visualizations
custom_images = viz_parsed_document(
    "document.pdf",
    parsed_doc,
    output_dir="./custom_visualizations",
    viz_config=viz_config
)

print(f"Created {len(custom_images)} visualization images")
```

## Configuration and Optimization

### Environment Configuration

Create a `.env` file to customize library behavior:

```bash
# .env file configuration
VISION_AGENT_API_KEY=your-api-key-here

# Parallelism settings
BATCH_SIZE=4          # Number of files to process in parallel
MAX_WORKERS=5         # Threads per file for large document processing

# Retry configuration
MAX_RETRIES=100       # Maximum retry attempts
MAX_RETRY_WAIT_TIME=60  # Maximum wait time per retry (seconds)

# Logging configuration
RETRY_LOGGING_STYLE=log_msg  # Options: log_msg, inline_block, none
```

### Performance Optimization

```python
import os
from agentic_doc.parse import parse

# Configure performance settings programmatically
os.environ['BATCH_SIZE'] = '6'
os.environ['MAX_WORKERS'] = '8'
os.environ['MAX_RETRIES'] = '50'

# Process documents with optimized settings
results = parse(["doc1.pdf", "doc2.pdf", "doc3.pdf"])
```

### Advanced Parsing Options

```python
from agentic_doc.parse import parse

# Advanced parsing with custom options
results = parse(
    "document.pdf",
    include_marginalia=False,        # Exclude headers/footers
    include_metadata_in_markdown=False,  # Clean markdown output
    grounding_save_dir="./groundings"    # Save visual groundings
)

parsed_doc = results[0]
print(f"Clean content extracted: {len(parsed_doc.chunks)} chunks")
```

## Error Handling and Troubleshooting

### Robust Error Handling

```python
from agentic_doc.parse import parse
import logging

# Enable detailed logging
logging.basicConfig(level=logging.INFO)

try:
    results = parse("problematic-document.pdf")
    parsed_doc = results[0]
    
    # Check for parsing errors
    if parsed_doc.errors:
        print("Document processed with errors:")
        for error in parsed_doc.errors:
            print(f"  Page {error.page}: {error.error_code} - {error.message}")
    else:
        print("Document processed successfully!")
        
except Exception as e:
    print(f"Failed to process document: {e}")
    # Handle API key issues, network problems, etc.
```

### Common Issues and Solutions

```python
# Handle rate limiting gracefully
import os
from agentic_doc.parse import parse

# Reduce parallelism for rate-limited accounts
os.environ['BATCH_SIZE'] = '1'
os.environ['MAX_WORKERS'] = '2'
os.environ['RETRY_LOGGING_STYLE'] = 'inline_block'

try:
    results = parse("large-document.pdf")
    print("Processing completed successfully")
except Exception as e:
    if "rate limit" in str(e).lower():
        print("Rate limit exceeded. Consider reducing BATCH_SIZE and MAX_WORKERS")
    elif "api key" in str(e).lower():
        print("API key issue. Check VISION_AGENT_API_KEY environment variable")
    else:
        print(f"Unexpected error: {e}")
```

## Real-World Use Cases

### Financial Document Processing

```python
from agentic_doc.parse import parse
import json

def process_financial_reports(report_paths):
    """Process financial reports and extract key information."""
    results = parse(report_paths)
    
    financial_data = []
    for i, parsed_doc in enumerate(results):
        doc_data = {
            'filename': report_paths[i],
            'title': parsed_doc.title,
            'page_count': parsed_doc.page_count,
            'tables': [],
            'key_figures': []
        }
        
        # Extract tables and numerical data
        for chunk in parsed_doc.chunks:
            if chunk.chunk_type.name == 'TABLE':
                doc_data['tables'].append(chunk.content)
            elif any(keyword in chunk.content.lower() 
                    for keyword in ['revenue', 'profit', 'loss', '$', '%']):
                doc_data['key_figures'].append(chunk.content)
        
        financial_data.append(doc_data)
    
    return financial_data

# Process quarterly reports
reports = ['q1_report.pdf', 'q2_report.pdf', 'q3_report.pdf']
financial_analysis = process_financial_reports(reports)

# Save structured data
with open('financial_analysis.json', 'w') as f:
    json.dump(financial_analysis, f, indent=2)
```

### Research Paper Analysis

```python
from agentic_doc.parse import parse
import re

def analyze_research_papers(paper_urls):
    """Analyze research papers and extract abstracts, conclusions."""
    results = parse(paper_urls)
    
    analysis = []
    for i, parsed_doc in enumerate(results):
        paper_analysis = {
            'url': paper_urls[i],
            'title': parsed_doc.title,
            'abstract': None,
            'conclusion': None,
            'references_count': 0,
            'figures_count': 0
        }
        
        for chunk in parsed_doc.chunks:
            content_lower = chunk.content.lower()
            
            # Extract abstract
            if 'abstract' in content_lower and not paper_analysis['abstract']:
                paper_analysis['abstract'] = chunk.content
            
            # Extract conclusion
            if any(word in content_lower for word in ['conclusion', 'summary', 'findings']):
                paper_analysis['conclusion'] = chunk.content
            
            # Count references and figures
            if 'reference' in content_lower or 'bibliography' in content_lower:
                paper_analysis['references_count'] += len(re.findall(r'\[\d+\]', chunk.content))
            
            if chunk.chunk_type.name in ['FIGURE', 'IMAGE']:
                paper_analysis['figures_count'] += 1
        
        analysis.append(paper_analysis)
    
    return analysis

# Analyze research papers
paper_urls = [
    'https://arxiv.org/pdf/2301.00001.pdf',
    'https://arxiv.org/pdf/2301.00002.pdf'
]

research_analysis = analyze_research_papers(paper_urls)
for paper in research_analysis:
    print(f"Title: {paper['title']}")
    print(f"Figures: {paper['figures_count']}")
    print(f"References: {paper['references_count']}")
    print("---")
```

## Best Practices and Tips

### Performance Optimization

1. **Batch Processing**: Process multiple documents together for better throughput
2. **Parallel Configuration**: Adjust `BATCH_SIZE` and `MAX_WORKERS` based on your API limits
3. **Error Handling**: Always check for processing errors in results
4. **Resource Management**: Use grounding images only when needed for debugging

### Production Deployment

```python
import os
from agentic_doc.parse import parse
import logging

# Production configuration
def setup_production_config():
    """Configure library for production use."""
    os.environ['BATCH_SIZE'] = '2'  # Conservative for stability
    os.environ['MAX_WORKERS'] = '3'
    os.environ['MAX_RETRIES'] = '10'
    os.environ['RETRY_LOGGING_STYLE'] = 'none'  # Reduce log noise
    
    # Setup logging
    logging.basicConfig(
        level=logging.WARNING,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

def process_documents_safely(document_paths):
    """Safely process documents with comprehensive error handling."""
    setup_production_config()
    
    successful_results = []
    failed_documents = []
    
    try:
        results = parse(document_paths)
        
        for i, result in enumerate(results):
            if result.errors:
                failed_documents.append({
                    'path': document_paths[i],
                    'errors': result.errors
                })
            else:
                successful_results.append(result)
                
    except Exception as e:
        logging.error(f"Batch processing failed: {e}")
        return None, document_paths
    
    return successful_results, failed_documents

# Use in production
documents = ['doc1.pdf', 'doc2.pdf', 'doc3.pdf']
success, failures = process_documents_safely(documents)

if success:
    print(f"Successfully processed {len(success)} documents")
if failures:
    print(f"Failed to process {len(failures)} documents")
```

## Conclusion

LandingAI's Agentic Document Extraction library represents a significant advancement in AI-powered document processing. Its ability to handle complex layouts, process large documents, and provide structured output with visual grounding makes it an invaluable tool for modern data extraction workflows.

### Key Takeaways

- **Enterprise-Ready**: Handles documents of any size with automatic scaling
- **AI-Powered**: Advanced understanding of complex document layouts
- **Developer-Friendly**: Simple API with powerful configuration options
- **Production-Ready**: Built-in retry mechanisms and error handling
- **Flexible Output**: Structured JSON and Markdown formats

### Next Steps

1. **Experiment**: Try the library with your own documents
2. **Optimize**: Fine-tune configuration for your specific use case
3. **Integrate**: Build the library into your existing workflows
4. **Scale**: Leverage batch processing for production workloads

The future of document processing is here, and with LandingAI's Agentic Document Extraction, you're equipped to handle even the most complex document processing challenges with confidence.

---

**Resources:**
- [LandingAI Agentic Document Extraction GitHub](https://github.com/landing-ai/agentic-doc)
- [Official Documentation](https://landing.ai/agentic-document-extraction)
- [API Documentation](https://landing.ai/docs)
- [Get API Key](https://landing.ai/)

*Happy document processing! 🚀*
