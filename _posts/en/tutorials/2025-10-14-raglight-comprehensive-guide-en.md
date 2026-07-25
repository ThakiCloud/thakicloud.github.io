---
title: "RAGLight Complete Guide: From Basic RAG to Agentic Workflows"
excerpt: "Master RAGLight framework with hands-on examples covering RAG, Agentic RAG, RAT pipelines, and MCP integration for building powerful retrieval-augmented generation systems."
seo_title: "RAGLight Tutorial: Complete RAG Framework Guide - Thaki Cloud"
seo_description: "Learn RAGLight framework with practical examples. Build RAG, Agentic RAG, and RAT pipelines on macOS using Ollama, OpenAI, or Mistral for context-aware AI applications."
date: 2025-10-14
tags:
  - raglight
  - rag
  - agentic-rag
  - ollama
  - python
  - llm
  - vector-database
  - mcp
  - huggingface
author_profile: true
toc: true
toc_label: "Contents"
lang: en
permalink: /en/tutorials/raglight-comprehensive-guide/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/raglight-comprehensive-guide-en/"
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

**RAGLight** is a lightweight, modular Python framework designed to simplify the implementation of **Retrieval-Augmented Generation (RAG)**. By combining document retrieval with large language models (LLMs), RAGLight enables you to build context-aware AI systems that can answer questions based on your own documents and knowledge bases.

In this comprehensive tutorial, you'll learn how to:

- Set up RAGLight with various LLM providers (Ollama, OpenAI, Mistral)
- Build basic RAG pipelines for document-based question answering
- Implement Agentic RAG for multi-step reasoning tasks
- Use RAT (Retrieval-Augmented Thinking) for enhanced reasoning
- Integrate external tools using MCP (Model Context Protocol)

### What Makes RAGLight Special?

RAGLight stands out for its:

- **Modular Architecture**: Easily swap LLMs, embeddings, and vector stores
- **Multiple Provider Support**: Ollama, OpenAI, Mistral, LMStudio, vLLM, Google AI
- **Advanced Pipelines**: Basic RAG, Agentic RAG, and RAT with reasoning layers
- **MCP Integration**: Connect external tools and data sources seamlessly
- **Flexible Configuration**: Customize every aspect of your RAG pipeline

## Prerequisites

Before starting this tutorial, ensure you have:

### 1. Python Environment

```bash
# Check Python version (3.8 or higher required)
python3 --version

# Create a virtual environment (recommended)
python3 -m venv raglight-env
source raglight-env/bin/activate  # On macOS/Linux
# raglight-env\Scripts\activate  # On Windows
```

### 2. Ollama Installation (for local LLM)

```bash
# macOS
brew install ollama

# Or download from https://ollama.ai/download

# Start Ollama service
ollama serve

# Pull a model (in a new terminal)
ollama pull llama3.2:3b
```

**Alternative**: Use OpenAI or Mistral API if you prefer cloud-based LLMs.

### 3. Install RAGLight

```bash
pip install raglight
```

## Installation and Setup

### Environment Configuration

Create a `.env` file to store your API keys (if using cloud providers):

```bash
# .env file
OPENAI_API_KEY=your_openai_key_here
MISTRAL_API_KEY=your_mistral_key_here
```

### Project Structure

Set up your project directory:

```bash
mkdir raglight-tutorial
cd raglight-tutorial
mkdir data
mkdir knowledge_base
```

### Sample Data Creation

Create some sample documents for testing:

```bash
# data/document1.txt
cat > data/document1.txt << 'EOF'
RAGLight is a modular Python framework for Retrieval-Augmented Generation.
It supports multiple LLM providers including Ollama, OpenAI, and Mistral.
Key features include flexible vector store integration with ChromaDB and FAISS.
EOF

# data/document2.txt
cat > data/document2.txt << 'EOF'
Agentic RAG extends traditional RAG by incorporating autonomous agents.
These agents can perform multi-step reasoning and dynamic information retrieval.
Use cases include complex question answering and research assistants.
EOF

# data/document3.txt
cat > data/document3.txt << 'EOF'
Retrieval-Augmented Thinking (RAT) adds a specialized reasoning layer.
It uses reasoning LLMs to enhance response quality and analytical depth.
RAT is ideal for tasks requiring deep thinking and multi-hop reasoning.
EOF
```

## Basic RAG Pipeline

### Understanding the RAG Architecture

The basic RAG pipeline consists of three main components:

1. **Document Ingestion**: Your documents are split into chunks and converted to embeddings
2. **Vector Storage**: Embeddings are stored in a vector database (ChromaDB, FAISS, etc.)
3. **Retrieval & Generation**: When queried, relevant documents are retrieved and passed to the LLM

**Figure 1. RAGLight pipeline architecture (Basic RAG, Agentic RAG, RAT).**

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
<div class="d3-arch" data-arch-root id="ightcomprehensiveguideen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 741, "height": 1036, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "D", "x": 199, "y": 24, "w": 120, "h": 46, "title": "Documents"}, {"id": "C", "x": 191, "y": 148, "w": 135, "h": 46, "title": "Chunk and Embed"}, {"id": "VS", "x": 160, "y": 272, "w": 198, "h": 62, "title": ["Vector Store: ChromaDB /", "FAISS / Qdrant"]}, {"id": "Q", "x": 413, "y": 280, "w": 120, "h": 46, "title": "User Query"}, {"id": "MODE", "x": 296, "y": 426, "w": 139, "h": 52, "title": "Pipeline Mode"}, {"id": "B1", "x": 581, "y": 702, "w": 128, "h": 46, "title": "Retrieve top-k"}, {"id": "B2", "x": 585, "y": 834, "w": 120, "h": 46, "title": "LLM Generate"}, {"id": "A1", "x": 270, "y": 694, "w": 191, "h": 62, "title": ["Agent Loop: reason then", "retrieve"]}, {"id": "A2", "x": 306, "y": 834, "w": 120, "h": 46, "title": "LLM Generate"}, {"id": "T1", "x": 60, "y": 570, "w": 120, "h": 46, "title": "Retrieve"}, {"id": "T2", "x": 24, "y": 694, "w": 191, "h": 62, "title": ["Reasoning LLM: thinking", "steps"]}, {"id": "T3", "x": 56, "y": 834, "w": 128, "h": 46, "title": "Generation LLM"}, {"id": "ANS", "x": 306, "y": 958, "w": 120, "h": 46, "title": "Answer"}], "edges": [{"src": "D", "dst": "C", "kind": "data", "line": [259, 70, 259, 148]}, {"src": "C", "dst": "VS", "kind": "data", "line": [259, 194, 259, 272]}, {"src": "Q", "dst": "MODE", "kind": "data", "curve": [[473, 326], [473, 380], [473, 380], [404, 426]]}, {"src": "VS", "dst": "MODE", "kind": "event", "label": "retrieve", "curve": [[259, 334], [259, 380], [259, 380], [327, 426]], "off": "50%"}, {"src": "MODE", "dst": "B1", "kind": "data", "label": "Basic RAG", "curve": [[435, 470], [645, 524], [645, 655], [645, 702]], "off": "50%"}, {"src": "B1", "dst": "B2", "kind": "data", "line": [645, 748, 645, 834]}, {"src": "MODE", "dst": "A1", "kind": "data", "label": "Agentic RAG", "line": [366, 478, 366, 694], "lx": 366, "ly": 589}, {"src": "A1", "dst": "A1", "kind": "data", "label": "iterate", "curve": [[461, 703], [511, 694], [511, 756], [461, 747]], "off": "50%"}, {"src": "A1", "dst": "A2", "kind": "data", "line": [366, 756, 366, 834]}, {"src": "MODE", "dst": "T1", "kind": "data", "label": "RAT", "curve": [[296, 472], [120, 524], [120, 524], [120, 570]], "off": "50%"}, {"src": "T1", "dst": "T2", "kind": "data", "line": [120, 616, 120, 694]}, {"src": "T2", "dst": "T3", "kind": "data", "line": [120, 756, 120, 834]}, {"src": "B2", "dst": "ANS", "kind": "data", "curve": [[645, 880], [645, 919], [645, 919], [426, 968]]}, {"src": "A2", "dst": "ANS", "kind": "data", "line": [366, 880, 366, 958]}, {"src": "T3", "dst": "ANS", "kind": "data", "curve": [[120, 880], [120, 919], [120, 919], [306, 966]]}]});
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
      const container = document.getElementById('ightcomprehensiveguideen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ightcomprehensiveguideen-1';
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

### Implementation

Here's a complete example of a basic RAG pipeline:

```python
#!/usr/bin/env python3
"""Basic RAG Pipeline with RAGLight"""

from raglight.rag.simple_rag_api import RAGPipeline
from raglight.config.rag_config import RAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

# Load environment variables
load_dotenv()

# Setup logging
Settings.setup_logging()

# Vector Store Configuration
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./chroma_db",
    collection_name="my_knowledge_base"
)

# RAG Configuration
config = RAGConfig(
    llm="llama3.2:3b",  # Ollama model
    k=5,  # Number of documents to retrieve
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    knowledge_base=[FolderSource(path="./data")]
)

# Initialize and build pipeline
print("Initializing RAG pipeline...")
pipeline = RAGPipeline(config, vector_store_config)

print("Building knowledge base...")
pipeline.build()

# Query the pipeline
query = "What are the key features of RAGLight?"
print(f"\nQuery: {query}")

response = pipeline.generate(query)
print(f"\nResponse:\n{response}")
```

### Key Configuration Options

**Vector Store Options:**
- `database`: CHROMA, FAISS, or QDRANT
- `provider`: HUGGINGFACE, OLLAMA, or OPENAI for embeddings
- `persist_directory`: Where to store the vector database

**RAG Options:**
- `llm`: Model name (e.g., "llama3.2:3b", "gpt-4", "mistral-large-2411")
- `k`: Number of relevant documents to retrieve
- `provider`: OLLAMA, OPENAI, MISTRAL, LMSTUDIO, GOOGLE

### Using Different LLM Providers

**OpenAI:**
```python
config = RAGConfig(
    llm="gpt-4",
    k=5,
    provider=Settings.OPENAI,
    api_key=Settings.OPENAI_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

**Mistral:**
```python
config = RAGConfig(
    llm="mistral-large-2411",
    k=5,
    provider=Settings.MISTRAL,
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

## Agentic RAG Pipeline

### What is Agentic RAG?

Agentic RAG extends traditional RAG by incorporating an autonomous agent that can:

- Perform multi-step reasoning
- Decide when to retrieve additional information
- Iterate through multiple retrieval-generation cycles
- Handle complex questions requiring multiple data sources

### Implementation

```python
"""Agentic RAG Pipeline with RAGLight"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

load_dotenv()
Settings.setup_logging()

# Vector Store Configuration
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./agentic_chroma_db",
    collection_name="agentic_knowledge_base"
)

# Agentic RAG Configuration
config = AgenticRAGConfig(
    provider=Settings.MISTRAL,
    model="mistral-large-2411",
    k=10,
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,  # Maximum reasoning steps
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)

# Initialize and build
print("Initializing Agentic RAG pipeline...")
agentic_rag = AgenticRAGPipeline(config, vector_store_config)

print("Building knowledge base...")
agentic_rag.build()

# Complex query requiring multiple steps
query = """
Compare the capabilities of basic RAG and Agentic RAG.
What are the specific use cases where Agentic RAG would be more beneficial?
"""

print(f"\nQuery: {query}")
response = agentic_rag.generate(query)
print(f"\nResponse:\n{response}")
```

### Key Features of Agentic RAG

**max_steps**: Controls how many reasoning iterations the agent can perform
```python
# Simple query: fewer steps needed
config = AgenticRAGConfig(max_steps=2, ...)

# Complex analysis: more steps allowed
config = AgenticRAGConfig(max_steps=10, ...)
```

**Custom Agent Prompt**: Tailor the agent's behavior
```python
custom_agent_prompt = """
You are a research assistant. When answering questions:
1. Break down complex queries into sub-questions
2. Retrieve relevant information for each sub-question
3. Synthesize findings into a comprehensive answer
4. Cite sources when possible
"""

config = AgenticRAGConfig(
    system_prompt=custom_agent_prompt,
    ...
)
```

## RAT (Retrieval-Augmented Thinking)

### Understanding RAT

RAT adds a specialized reasoning layer to the RAG pipeline:

1. **Retrieval**: Fetch relevant documents
2. **Reasoning**: Use a reasoning LLM to analyze retrieved content
3. **Thinking**: Generate intermediate reasoning steps
4. **Generation**: Produce final answer with enhanced context

### Implementation

```python
"""RAT Pipeline with RAGLight"""

from raglight.rat.simple_rat_api import RATPipeline
from raglight.config.rat_config import RATConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource

Settings.setup_logging()

# Vector Store Configuration
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./rat_chroma_db",
    collection_name="rat_knowledge_base"
)

# RAT Configuration
config = RATConfig(
    cross_encoder_model=Settings.DEFAULT_CROSS_ENCODER_MODEL,
    llm="llama3.2:3b",
    k=Settings.DEFAULT_K,
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    reasoning_llm=Settings.DEFAULT_REASONING_LLM,
    reflection=3,  # Number of reasoning iterations
    knowledge_base=[FolderSource(path="./data")]
)

# Initialize and build
print("Initializing RAT pipeline...")
pipeline = RATPipeline(config, vector_store_config)

print("Building knowledge base...")
pipeline.build()

# Query requiring deep reasoning
query = """
Analyze the architectural differences between RAG, Agentic RAG, and RAT.
What are the trade-offs in terms of complexity, performance, and output quality?
"""

print(f"\nQuery: {query}")
response = pipeline.generate(query)
print(f"\nResponse:\n{response}")
```

### RAT Configuration Options

**reflection**: Number of reasoning iterations
```python
# Quick reasoning
config = RATConfig(reflection=1, ...)

# Deep analytical thinking
config = RATConfig(reflection=5, ...)
```

**cross_encoder_model**: Reranking model for better retrieval
```python
config = RATConfig(
    cross_encoder_model="cross-encoder/ms-marco-MiniLM-L-12-v2",
    ...
)
```

## MCP Integration

### What is MCP?

Model Context Protocol (MCP) allows your RAG pipeline to interact with external tools and services. This enables:

- Web search integration
- Database queries
- API calls to external services
- Code execution environments
- Custom tool integration

### MCP Server Setup

First, configure your MCP server (example using MCPClient):

```python
"""MCP Server Configuration"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.settings import Settings

# Configure MCP server URL
config = AgenticRAGConfig(
    provider=Settings.OPENAI,
    model="gpt-4o",
    k=10,
    mcp_config=[
        {% raw %}{"url": "http://127.0.0.1:8001/sse"}{% endraw %}  # Your MCP server URL
    ],
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,
    api_key=Settings.OPENAI_API_KEY
)

# Initialize with MCP
pipeline = AgenticRAGPipeline(config, vector_store_config)
pipeline.build()

# The agent can now use external tools
query = "Search the web for recent updates on RAG frameworks and summarize findings"
response = pipeline.generate(query)
```

### MCP Use Cases

**Web Search Integration:**
```python
# Agent can search and incorporate web results
query = "What are the latest developments in RAG technology in 2024?"
```

**Database Queries:**
```python
# Agent can query databases for real-time data
query = "Retrieve user statistics from our database and analyze trends"
```

**API Integration:**
```python
# Agent can call external APIs
query = "Check weather API and recommend activities based on forecast"
```

## Performance Comparison

### Pipeline Characteristics

| Pipeline Type | Complexity | Response Time | Use Case |
|--------------|------------|---------------|----------|
| **Basic RAG** | Low | Fast (< 5s) | Simple Q&A, document lookup |
| **Agentic RAG** | Medium | Moderate (5-15s) | Multi-step reasoning, research |
| **RAT** | High | Slower (15-30s) | Deep analysis, complex reasoning |
| **RAG + MCP** | Variable | Depends on tools | External tool integration |

### Choosing the Right Pipeline

**Use Basic RAG when:**
- You need fast responses
- Questions are straightforward
- Single document lookup is sufficient

**Use Agentic RAG when:**
- Questions require multiple steps
- You need dynamic retrieval
- Task involves research or exploration

**Use RAT when:**
- Deep analytical thinking is required
- Quality is more important than speed
- Complex multi-hop reasoning is needed

**Use MCP Integration when:**
- You need real-time external data
- Task requires tool usage
- Dynamic information is essential

## Best Practices

### 1. Document Preparation

**Chunk Size Optimization:**
```python
# For technical documents
chunk_size = 512

# For narrative content
chunk_size = 1024
```

**Folder Organization:**
```
knowledge_base/
├── technical_docs/
├── user_manuals/
├── api_reference/
└── faq/
```

### 2. Vector Store Management

**Persistence:**
```python
# Always use persistent storage in production
vector_store_config = VectorStoreConfig(
    persist_directory="./prod_vectordb",
    collection_name="production_kb"
)
```

**Collection Organization:**
```python
# Separate collections for different domains
collections = {
    "technical": "tech_docs_collection",
    "business": "business_docs_collection",
    "general": "general_knowledge_collection"
}
```

### 3. LLM Selection

**Development:**
```python
# Use local models for development
config = RAGConfig(
    llm="llama3.2:3b",
    provider=Settings.OLLAMA
)
```

**Production:**
```python
# Use more powerful models for production
config = RAGConfig(
    llm="gpt-4",
    provider=Settings.OPENAI
)
```

### 4. Error Handling

```python
"""Robust RAG Pipeline with Error Handling"""

try:
    pipeline = RAGPipeline(config, vector_store_config)
    pipeline.build()
    response = pipeline.generate(query)
except Exception as e:
    print(f"Pipeline error: {e}")
    # Fallback to basic LLM without RAG
    response = fallback_generate(query)
```

### 5. Ignore Folders Configuration

When indexing code repositories, exclude unnecessary directories:

```python
# Custom ignore folders
custom_ignore_folders = [
    ".venv",
    "venv",
    "node_modules",
    "__pycache__",
    ".git",
    "build",
    "dist",
    "my_custom_folder_to_ignore"
]

config = AgenticRAGConfig(
    ignore_folders=custom_ignore_folders,
    ...
)
```

### 6. Monitoring and Logging

```python
"""Enable detailed logging"""

import logging

# Configure logging level
logging.basicConfig(level=logging.INFO)

# Or use RAGLight's setup
Settings.setup_logging()

# Monitor performance
import time

start_time = time.time()
response = pipeline.generate(query)
elapsed_time = time.time() - start_time

print(f"Query processed in {elapsed_time:.2f}s")
```

## Advanced Customization

### Custom Pipeline Builder

```python
"""Custom RAG Pipeline with Builder Pattern"""

from raglight.rag.builder import Builder
from raglight.config.settings import Settings

# Build custom pipeline
rag = Builder() \
    .with_embeddings(
        Settings.HUGGINGFACE,
        model_name=Settings.DEFAULT_EMBEDDINGS_MODEL
    ) \
    .with_vector_store(
        Settings.CHROMA,
        persist_directory="./custom_db",
        collection_name="custom_collection"
    ) \
    .with_llm(
        Settings.OLLAMA,
        model_name="llama3.2:3b",
        system_prompt_file="./custom_prompt.txt",
        provider=Settings.OLLAMA
    ) \
    .build_rag(k=5)

# Ingest documents
rag.vector_store.ingest(data_path='./data')

# Query
response = rag.generate("Your question here")
```

### Code Repository Indexing

```python
"""Index code repositories"""

# Index code with signature extraction
rag.vector_store.ingest(repos_path=['./repo1', './repo2'])

# Search code
code_results = rag.vector_store.similarity_search("authentication logic")

# Search class signatures
class_results = rag.vector_store.similarity_search_class("User class definition")
```

### GitHub Repository Integration

```python
"""Index GitHub repositories directly"""

from raglight.models.data_source_model import GitHubSource

knowledge_base = [
    GitHubSource(url="https://github.com/Bessouat40/RAGLight"),
    GitHubSource(url="https://github.com/your-org/your-repo")
]

config = RAGConfig(
    knowledge_base=knowledge_base,
    ...
)
```

## Docker Deployment

### Dockerfile Example

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# Install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Add host mapping for Ollama/LMStudio
# Run with: docker run --add-host=host.docker.internal:host-gateway your-image

CMD ["python", "app.py"]
```

### Build and Run

```bash
# Build image
docker build -t raglight-app .

# Run with host network access (for Ollama)
docker run --add-host=host.docker.internal:host-gateway raglight-app
```

## Troubleshooting

### Common Issues

**1. Ollama Connection Error:**
```python
# Check Ollama is running
# macOS/Linux:
ollama serve

# Update API base if needed
vector_store_config = VectorStoreConfig(
    api_base="http://localhost:11434",  # Default Ollama URL
    ...
)
```

**2. Memory Issues:**
```python
# Reduce chunk size and k value
config = RAGConfig(
    k=3,  # Retrieve fewer documents
    ...
)
```

**3. Slow Performance:**
```python
# Use smaller embedding models
vector_store_config = VectorStoreConfig(
    embedding_model="all-MiniLM-L6-v2",  # Smaller, faster model
    ...
)
```

**4. Vector Store Errors:**
```bash
# Clear and rebuild
rm -rf ./chroma_db
python rebuild_kb.py
```

## Conclusion

RAGLight provides a powerful, flexible framework for building retrieval-augmented generation systems. Whether you need simple document Q&A or complex agentic workflows with external tool integration, RAGLight's modular architecture makes it easy to build and scale.

### Key Takeaways

- **Start Simple**: Begin with Basic RAG and upgrade to Agentic RAG or RAT as needed
- **Choose Wisely**: Select the right pipeline based on your use case and performance requirements
- **Customize Extensively**: RAGLight's modular design allows complete customization
- **Scale Gradually**: Start locally with Ollama, then move to cloud providers for production

### Next Steps

1. **Experiment**: Try different LLM providers and vector stores
2. **Optimize**: Tune k values, chunk sizes, and model selection
3. **Integrate**: Add MCP servers for external tool access
4. **Deploy**: Containerize with Docker for production deployment

### Resources

- **RAGLight GitHub**: [https://github.com/Bessouat40/RAGLight](https://github.com/Bessouat40/RAGLight)
- **PyPI Package**: [https://pypi.org/project/raglight/](https://pypi.org/project/raglight/)
- **Ollama**: [https://ollama.ai](https://ollama.ai)
- **ChromaDB**: [https://www.trychroma.com](https://www.trychroma.com)
- **MCP Protocol**: Search "Model Context Protocol" for documentation

Happy building with RAGLight! 🚀

