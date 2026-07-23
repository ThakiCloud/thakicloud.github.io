---
title: "ByteDance Dolphin Document Image Parsing: Fox Dataset and Benchmark Complete Analysis"
excerpt: "A detailed analysis of ByteDance's Dolphin project Fox dataset and benchmark, including the Analyze-then-Parse paradigm from ACL 2025 and a large-scale dataset with 30M+ samples."
seo_title: "ByteDance Dolphin Fox Dataset Analysis - Document Image Parsing Benchmark Guide - Thaki Cloud"
seo_description: "Complete analysis of ByteDance Dolphin's Fox dataset and document image parsing benchmark. Covers the ACL 2025 paper, the Analyze-then-Parse paradigm, and the 30M-sample dataset structure."
date: 2025-08-08
last_modified_at: 2025-08-08
tags:
  - dolphin
  - bytedance
  - document-parsing
  - fox-dataset
  - acl-2025
  - multimodal
  - vision-language-model
  - ocr
  - document-understanding
  - benchmark
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/datasets/bytedance-dolphin-document-parsing-dataset-fox-benchmark-guide/"
reading_time: true
lang: en
published: true
categories:
  - datasets
  - research
---

⏱️ **Estimated reading time**: 18 min

![ByteDance Dolphin Analyze-then-Parse pipeline overview]({{ '/assets/images/bytedance-dolphin-document-parsing-dataset-fox-benchmark-guide-hero.png' | relative_url }})

## Introduction

Document image parsing is a core AI technology for extracting structured information from scanned documents, PDFs, or photographed pages. ByteDance's Dolphin project proposes an innovative approach in this space, and building on research published at [ACL 2025](https://arxiv.org/abs/2505.14059), the team has released the Fox dataset and benchmark.

This article provides a thorough analysis of Dolphin's core techniques together with the large-scale dataset the researchers constructed, with particular focus on the structure and practical use of the Fox-Page benchmark.

## Dolphin Project Overview

### 🎯 Core Idea: The Analyze-then-Parse Paradigm

[Dolphin](https://github.com/bytedance/Dolphin) adopts an "Analyze-then-Parse" approach that sets it apart from conventional document parsing methods.

#### Limitations of Existing Methods

```python
# Conventional approach: specialized model pipeline
traditional_pipeline = {
    "layout_detection": "YOLO/Faster R-CNN",
    "ocr_engine": "Tesseract/PaddleOCR", 
    "table_extraction": "TableNet/CascadeTabNet",
    "formula_recognition": "Im2Latex/InftyReader"
}
# Problems: integration overhead, lack of consistency, high complexity
```

```python
# Conventional approach: autoregressive generation
autoregressive_approach = {
    "input": "document_image",
    "output": "sequential_text_generation",
    "problem": "layout_structure_degradation"
}
# Problems: loss of layout structure, reduced efficiency
```

#### Dolphin's Innovative Approach

```python
# Dolphin: two-stage Analyze-then-Parse paradigm
dolphin_paradigm = {
    "stage_1": {
        "task": "layout_analysis",
        "output": "element_sequence_in_reading_order",
        "elements": ["text", "table", "figure", "formula"]
    },
    "stage_2": {
        "task": "parallel_element_parsing", 
        "method": "heterogeneous_anchor_prompting",
        "efficiency": "parallel_processing"
    }
}
```

### 🏗️ Model Architecture

Dolphin is built on a Vision-Encoder-Decoder structure:

The diagram below shows how a document image is transformed into structured output through the two-stage Analyze-then-Parse flow:

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
<div class="d3-arch" data-arch-root id="datasetfoxbenchmarkguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 701, "height": 1050, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IMG", "x": 283, "y": 24, "w": 128, "h": 46, "title": "Document image"}, {"id": "ENC", "x": 265, "y": 148, "w": 163, "h": 62, "title": ["Vision Encoder Swin", "Transformer"]}, {"id": "S1", "x": 251, "y": 288, "w": 191, "h": 46, "title": "Stage 1 Layout Analysis"}, {"id": "SEQ", "x": 265, "y": 412, "w": 163, "h": 62, "title": ["Element sequence in", "reading order"]}, {"id": "S2", "x": 248, "y": 552, "w": 198, "h": 62, "title": ["Stage 2 Parallel Element", "Parsing"]}, {"id": "T", "x": 549, "y": 692, "w": 120, "h": 46, "title": "Text blocks"}, {"id": "TB", "x": 374, "y": 692, "w": 120, "h": 46, "title": "Tables"}, {"id": "FM", "x": 199, "y": 692, "w": 120, "h": 46, "title": "Formulas"}, {"id": "FG", "x": 24, "y": 692, "w": 120, "h": 46, "title": "Figures"}, {"id": "DEC", "x": 251, "y": 816, "w": 191, "h": 62, "title": ["Text Decoder MBart with", "anchor prompts"]}, {"id": "OUT", "x": 265, "y": 956, "w": 163, "h": 62, "title": ["Structured JSON and", "Markdown"]}], "edges": [{"src": "IMG", "dst": "ENC", "kind": "data", "line": [347, 70, 347, 148]}, {"src": "ENC", "dst": "S1", "kind": "data", "line": [347, 210, 347, 288]}, {"src": "S1", "dst": "SEQ", "kind": "data", "line": [347, 334, 347, 412]}, {"src": "SEQ", "dst": "S2", "kind": "data", "line": [347, 474, 347, 552]}, {"src": "S2", "dst": "T", "kind": "data", "curve": [[446, 609], [609, 653], [609, 653], [609, 692]]}, {"src": "S2", "dst": "TB", "kind": "data", "curve": [[385, 614], [434, 653], [434, 653], [434, 692]]}, {"src": "S2", "dst": "FM", "kind": "data", "curve": [[308, 614], [259, 653], [259, 653], [259, 692]]}, {"src": "S2", "dst": "FG", "kind": "data", "curve": [[248, 609], [84, 653], [84, 653], [84, 692]]}, {"src": "T", "dst": "DEC", "kind": "data", "curve": [[609, 738], [609, 777], [609, 777], [442, 822]]}, {"src": "TB", "dst": "DEC", "kind": "data", "curve": [[434, 738], [434, 777], [434, 777], [385, 816]]}, {"src": "FM", "dst": "DEC", "kind": "data", "curve": [[259, 738], [259, 777], [259, 777], [308, 816]]}, {"src": "FG", "dst": "DEC", "kind": "data", "curve": [[84, 738], [84, 777], [84, 777], [251, 822]]}, {"src": "DEC", "dst": "OUT", "kind": "data", "line": [347, 878, 347, 956]}]});
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
      const container = document.getElementById('datasetfoxbenchmarkguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'datasetfoxbenchmarkguide-1';
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

#### Vision Encoder
- **Backbone**: Swin Transformer
- **Function**: Extracting visual features from document images
- **Resolution**: Multi-scale processing supported

#### Text Decoder
- **Base**: MBart architecture
- **Languages**: Chinese and English supported simultaneously
- **Vocabulary size**: 32K tokens

#### Prompt-based Interface
```python
# Heterogeneous anchor prompting example
prompts = {
    "layout_analysis": "Analyze the layout and generate element sequence:",
    "table_parsing": "Parse the table content in the red box:",
    "formula_recognition": "Recognize the mathematical formula in the blue box:",
    "text_extraction": "Extract text content from the green box:"
}
```

## Fox Dataset: Detailed Analysis

### 📊 Dataset Composition

The ByteDance research team built a large-scale multi-granularity dataset for training Dolphin.

#### Overall Dataset Scale
```yaml
dataset_statistics:
  total_samples: 30_000_000+
  granularity_levels:
    - page_level: "full-page parsing"
    - element_level: "individual element parsing"
  
  task_distribution:
    layout_analysis: 8_500_000
    table_extraction: 7_200_000  
    formula_recognition: 5_800_000
    text_recognition: 8_500_000
```

#### Fox-Page Benchmark Characteristics

Fox-Page is a high-quality subset manually refined from the original Fox dataset.

```yaml
fox_page_benchmark:
  release_date: "2025-07-10"
  quality: "manually_refined"
  purpose: "evaluation_benchmark"
  
  download_links:
    baidu_yun: "https://pan.baidu.com/..."
    google_drive: "https://drive.google.com/..."
  
  characteristics:
    diversity: "diverse document types"
    complexity: "complex layout structures"
    quality: "expert-verified"
```

### 🔍 Data Category Analysis

#### 1. Academic Papers
```python
academic_papers = {
    "sources": ["arXiv", "ACL", "NeurIPS", "ICLR"],
    "elements": {
        "multi_column_text": "two- and three-column text",
        "complex_tables": "statistical tables, results comparison tables",
        "mathematical_formulas": "inline and display formulas",
        "figures_with_captions": "graphs, diagrams"
    },
    "challenges": [
        "dense_layout",
        "interleaved_elements", 
        "scientific_notation"
    ]
}
```

#### 2. Business Documents
```python
business_documents = {
    "types": ["invoices", "reports", "presentations"],
    "layouts": {
        "structured_forms": "form-based documents",
        "mixed_content": "text and chart combinations",
        "branded_headers": "logos and header information"
    },
    "extraction_targets": [
        "key_value_pairs",
        "financial_data",
        "contact_information"
    ]
}
```

#### 3. Educational Materials
```python
educational_materials = {
    "categories": ["textbooks", "worksheets", "exams"],
    "special_elements": {
        "question_answer_pairs": "Q&A format",
        "step_by_step_solutions": "step-by-step solutions",
        "mixed_languages": "mixed multilingual content"
    },
    "complexity_factors": [
        "handwritten_annotations",
        "geometric_diagrams",
        "chemical_formulas"
    ]
}
```

### 📈 Benchmark Performance Metrics

#### Page-level Evaluation Metrics
```python
page_level_metrics = {
    "structure_accuracy": {
        "description": "layout structure accuracy",
        "calculation": "correct_elements / total_elements",
        "weight": 0.3
    },
    "content_fidelity": {
        "description": "content fidelity", 
        "measures": ["BLEU", "ROUGE", "Edit Distance"],
        "weight": 0.4
    },
    "reading_order": {
        "description": "reading order accuracy",
        "metric": "sequence_alignment_score", 
        "weight": 0.3
    }
}
```

#### Element-level Evaluation Metrics
```python
element_level_metrics = {
    "table_extraction": {
        "cell_accuracy": "per-cell accuracy",
        "structure_score": "table structure score", 
        "format_preservation": "degree of format preservation"
    },
    "formula_recognition": {
        "latex_accuracy": "LaTeX syntax accuracy",
        "semantic_correctness": "semantic correctness",
        "rendering_quality": "rendering quality"
    },
    "text_extraction": {
        "character_accuracy": "character-level accuracy",
        "word_accuracy": "word-level accuracy", 
        "layout_preservation": "layout preservation"
    }
}
```

## Practical Usage Guide

### 🚀 Using the Dolphin Model

#### Installation and Setup

```bash
# Clone the repository
git clone https://github.com/bytedance/Dolphin.git
cd Dolphin

# Install dependencies
pip install -r requirements.txt

# Download the model (HuggingFace approach)
git lfs install
git clone https://huggingface.co/ByteDance/Dolphin ./hf_model
```

#### Page-level Parsing Example

```python
# Usage example for demo_page_hf.py
import argparse
from pathlib import Path

# Process a single document image
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs/academic_paper.jpeg \
    --save_dir ./results

# Process a PDF document
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs/business_report.pdf \
    --save_dir ./results

# Batch processing (entire directory)
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs \
    --save_dir ./results \
    --max_batch_size 16
```

#### Element-level Parsing Example

```python
# Table extraction
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/complex_table.jpeg \
    --element_type table

# Formula recognition
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/math_formula.jpeg \
    --element_type formula

# Text paragraph extraction
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/text_paragraph.jpg \
    --element_type text
```

### 📊 Performance Optimization Tips

#### TensorRT-LLM Acceleration (added 2025.06.30)

```bash
# Install TensorRT-LLM
pip install tensorrt-llm

# Convert the model
python convert_to_tensorrt.py \
    --model_path ./hf_model \
    --output_dir ./tensorrt_model \
    --precision fp16

# Run accelerated inference
python demo_page_tensorrt.py \
    --model_path ./tensorrt_model \
    --input_path ./test_images
```

#### vLLM Acceleration (added 2025.06.27)

```bash
# Install vLLM
pip install vllm

# Start the vLLM server
python -m vllm.entrypoints.openai.api_server \
    --model ./hf_model \
    --tensor-parallel-size 2 \
    --dtype half

# Call from a client
curl -X POST "http://localhost:8000/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "ByteDance/Dolphin",
        "messages": [{"role": "user", "content": "Parse this document"}]
    }'
```

### 🔧 Building a Custom Dataset

#### Data Preparation Guidelines

```python
# Custom dataset structure
custom_dataset = {
    "images": {
        "format": ["JPEG", "PNG", "PDF"],
        "resolution": "minimum 300 DPI recommended",
        "quality": "high-resolution, sharp images"
    },
    "annotations": {
        "layout": {
            "bounding_boxes": "bounding box for each element",
            "element_types": ["text", "table", "figure", "formula"],
            "reading_order": "natural reading order"
        },
        "content": {
            "ground_truth": "accurate text content", 
            "markup": "structured markup (HTML/Markdown)",
            "latex": "LaTeX representation of formulas"
        }
    }
}
```

#### Annotation Guidelines

```yaml
annotation_guidelines:
  layout_analysis:
    text_blocks:
      - "Distinguish paragraphs, headings, and captions"
      - "Assign sequence numbers that reflect reading order"
    
    tables:
      - "Distinguish header rows from data rows"
      - "Include information on merged cells"
      - "Link table captions to tables"
    
    figures:
      - "Images, charts, and diagrams"
      - "Relationship between figure and its caption"
      - "Reference number information"
    
    formulas:
      - "Distinguish inline from display formulas"
      - "Accurate LaTeX representation"
      - "Consistent use of variables and symbols"

  quality_control:
    consistency_checks:
      - "Style consistency within the same document"
      - "Unified terminology and notation"
    
    accuracy_validation:
      - "Compare OCR output with source"
      - "Verify formula rendering"
      - "Confirm table structure accuracy"
```

## Comparison with Other Datasets

### 📋 Comparison of Major Document Understanding Benchmarks

| Dataset | Scale | Characteristics | Limitations |
|---------|-------|-----------------|-------------|
| **Fox-Page** | Refined, high quality | Multilingual, complex layouts | Relatively smaller size |
| DocVQA | 50K+ | VQA format | Limited to question-answer pairs |
| ChartQA | 20K+ | Chart-focused | Lacks non-chart elements |
| PubLayNet | 360K+ | Layout-centric | Limited content extraction |
| TableBank | 417K+ | Table-focused | Tables only |

### 🎯 What Sets the Dolphin Fox Dataset Apart

#### 1. Multi-Granularity Support
```python
multi_granularity = {
    "page_level": {
        "task": "understanding full document structure",
        "output": "JSON + Markdown",
        "applications": ["document digitization", "automatic summarization"]
    },
    "element_level": {
        "task": "precise extraction of individual elements", 
        "output": "structured data",
        "applications": ["data mining", "information retrieval"]
    }
}
```

#### 2. Grounded in Real-World Scenarios
```python
real_world_scenarios = {
    "academic_research": {
        "documents": "arXiv papers, conference proceedings",
        "challenges": "complex formulas, multi-column layouts"
    },
    "business_intelligence": {
        "documents": "financial statements, business reports",
        "challenges": "table structures, chart interpretation"
    },
    "education_technology": {
        "documents": "textbooks, exam questions",
        "challenges": "multilingual content, handwriting"
    }
}
```

#### 3. Comprehensive Evaluation Metrics
```python
comprehensive_evaluation = {
    "structure_preservation": "preservation of layout structure",
    "content_accuracy": "content accuracy",
    "efficiency_metrics": "processing speed and memory usage",
    "robustness_testing": "stability across diverse conditions"
}
```

## Research and Development Use Cases

### 🔬 Academic Research Applications

#### 1. Document Understanding Model Development
```python
research_applications = {
    "baseline_comparison": {
        "purpose": "benchmarking new model performance",
        "metrics": "Fox-Page benchmark scores",
        "advantage": "standardized evaluation environment"
    },
    "ablation_studies": {
        "components": ["vision_encoder", "text_decoder", "prompting"],
        "methodology": "per-component contribution analysis"
    },
    "cross_lingual_analysis": {
        "languages": ["Chinese", "English", "Mixed"],
        "research_questions": "analysis of performance differences by language"
    }
}
```

#### 2. Validating New Techniques
```python
technique_validation = {
    "anchor_prompting": {
        "hypothesis": "heterogeneous anchors improve performance",
        "experiment": "comparison experiments with and without prompts"
    },
    "parallel_processing": {
        "hypothesis": "parallel processing improves efficiency",
        "measurement": "processing time and memory usage"
    }
}
```

### 🏭 Industrial Applications

#### 1. Digital Transformation Projects
```python
digital_transformation = {
    "document_digitization": {
        "scope": "digitizing large-scale document archives",
        "pipeline": [
            "scan / photograph",
            "Dolphin parsing",
            "structured data storage",
            "search indexing"
        ]
    },
    "automated_processing": {
        "workflows": [
            "automated invoice processing",
            "contract information extraction", 
            "automated report summarization"
        ]
    }
}
```

#### 2. Knowledge Management Systems
```python
knowledge_management = {
    "academic_libraries": {
        "task": "automatic extraction of paper metadata",
        "benefits": "improved classification and search accuracy"
    },
    "corporate_archives": {
        "task": "building corporate document knowledge bases",
        "benefits": "providing information to support decision-making"
    }
}
```

## Advanced Usage and Extension

### 🛠️ Model Fine-tuning Guide

#### 1. Domain-specific Fine-tuning
```python
# Medical document fine-tuning example
medical_domain_config = {
    "data_preparation": {
        "medical_reports": "diagnostic reports, prescriptions",
        "terminology": "adding medical terminology dictionaries",
        "privacy": "masking personally identifiable information"
    },
    "training_config": {
        "learning_rate": 1e-5,
        "batch_size": 8,
        "epochs": 10,
        "special_tokens": ["<MEDICAL>", "<PRESCRIPTION>", "<DIAGNOSIS>"]
    }
}
```

#### 2. Multilingual Extension
```python
# Korean language extension example
korean_extension = {
    "tokenizer_expansion": {
        "korean_vocab": "adding Korean vocabulary",
        "hanja_support": "supporting Chinese character notation",
        "mixed_script": "processing Korean-English mixed documents"
    },
    "dataset_creation": {
        "korean_documents": [
            "official documents", "academic papers", "news articles", "textbooks"
        ],
        "annotation_guidelines": "reflecting Korean language characteristics"
    }
}
```

### 📊 Performance Monitoring and Optimization

#### 1. Real-time Performance Tracking
```python
# Performance monitoring script
import time
import psutil
import torch

class PerformanceMonitor:
    def __init__(self):
        self.start_time = None
        self.memory_usage = []
        
    def start_monitoring(self):
        self.start_time = time.time()
        self.memory_usage = []
        
    def log_metrics(self, step, accuracy):
        current_memory = psutil.virtual_memory().used / 1024**3  # GB
        elapsed_time = time.time() - self.start_time
        
        metrics = {
            "step": step,
            "accuracy": accuracy,
            "memory_gb": current_memory,
            "elapsed_time": elapsed_time,
            "gpu_memory": torch.cuda.memory_allocated() / 1024**3 if torch.cuda.is_available() else 0
        }
        
        return metrics
```

#### 2. Deployment Optimization
```python
# Production deployment configuration
production_config = {
    "model_optimization": {
        "quantization": "INT8 quantization",
        "pruning": "weight pruning", 
        "distillation": "knowledge distillation"
    },
    "inference_optimization": {
        "batching": "dynamic batching",
        "caching": "result caching",
        "parallel_workers": 4
    },
    "monitoring": {
        "latency_tracking": "response time tracking",
        "error_logging": "error logging",
        "usage_analytics": "usage pattern analysis"
    }
}
```

## Conclusion and Future Outlook

### 🎯 Significance of Dolphin and the Fox Dataset

The Dolphin project and the Fox dataset mark an important milestone in document image parsing:

#### 1. Technical Innovation
- **Analyze-then-Parse paradigm**: An intuitive approach that mirrors how humans read documents
- **Heterogeneous anchor prompting**: Effective handling of diverse document elements
- **Parallel processing mechanism**: High efficiency and scalability

#### 2. Dataset Value
- **Large-scale multi-granularity**: Over 30 million diverse samples
- **Real-world scenario coverage**: Academic, business, and educational domains included
- **Standardized evaluation environment**: A fair comparison baseline for the research community

### 🚀 Future Research Directions

#### 1. Technical Development Directions
```python
future_directions = {
    "multimodal_fusion": {
        "vision_language": "more refined vision-language fusion",
        "3d_documents": "understanding three-dimensional document structure"
    },
    "interactive_parsing": {
        "user_feedback": "improvement based on user feedback",
        "adaptive_learning": "adaptive learning mechanisms"
    },
    "efficiency_improvements": {
        "edge_deployment": "deployment on edge devices",
        "real_time_processing": "real-time processing optimization"
    }
}
```

#### 2. Application Domain Expansion
```python
application_expansion = {
    "specialized_domains": [
        "legal_documents",
        "medical_records",
        "financial_reports",
        "historical_archives"
    ],
    "emerging_technologies": [
        "ar_vr_integration",
        "voice_interaction",
        "blockchain_verification"
    ]
}
```

### 💡 Recommendations for Practical Adoption

#### 1. Adoption Strategy
1. **Pilot project**: Start small and expand gradually
2. **Domain specialization**: Customize for specific document types
3. **Performance benchmarking**: Establish a baseline using the Fox dataset
4. **Continuous improvement**: Update the model based on user feedback

#### 2. Quality Assurance
```python
quality_assurance = {
    "validation_pipeline": {
        "automated_testing": "automated accuracy testing",
        "human_review": "expert review process",
        "error_analysis": "error pattern analysis and improvement"
    },
    "continuous_monitoring": {
        "performance_tracking": "real-time performance monitoring",
        "drift_detection": "detecting model performance degradation",
        "retraining_triggers": "automatic determination of retraining timing"
    }
}
```

ByteDance Dolphin and the Fox dataset set a new benchmark for document understanding AI, enabling practical solutions across industries and research domains. Continued technical advancement and community contributions are expected to yield more refined and capable document parsing systems.

---

**Further Reading:**
- [Dolphin GitHub Repository](https://github.com/bytedance/Dolphin)
- [ACL 2025 Paper (arXiv)](https://arxiv.org/abs/2505.14059)
- [Dolphin Hugging Face Model](https://huggingface.co/ByteDance/Dolphin)
- [Fox-Page Benchmark Download](https://github.com/bytedance/Dolphin#fox-page-benchmark)
