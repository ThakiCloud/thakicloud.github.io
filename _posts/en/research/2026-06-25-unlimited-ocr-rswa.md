---
title: "Reading a Whole Book in One Pass: The Constant KV Cache Behind Baidu's Unlimited OCR"
excerpt: "Baidu's Unlimited OCR replaces decoder attention with Reference Sliding Window Attention to keep the KV cache constant. We unpack how it parses dozens of pages in a single forward pass and what it means for ThakiCloud's multi-tenant inference."
seo_title: "Unlimited OCR R-SWA Constant KV Cache Long-Document Parsing - Thaki Cloud"
seo_description: "Analysis of Baidu Unlimited OCR (arXiv 2606.23050) and its Reference Sliding Window Attention. Constant KV cache processes 32K context in one pass, 93.23% on OmniDocBench v1.5. ThakiCloud Kubernetes multi-tenant document inference perspective."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - unlimited-ocr
  - document-parsing
  - sliding-window-attention
  - kv-cache
  - long-context
  - on-premise
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "file-text"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/unlimited-ocr-rswa/"
reading_time: true
categories:
  - research
published: false
---

## Overview

Turning documents into a machine-readable structure has become central again in the era of RAG and agents. A single contract can run dozens of pages, and financial reports or papers carry tables, equations, and multi-column layouts that flow across page boundaries. These long documents need to be parsed in the correct reading order, all at once, before an LLM can use them well.

The problem is cost. When a vision-language model parses a document, the decoder generates output tokens one at a time autoregressively, and a standard transformer's full attention makes the KV cache grow linearly with sequence length. As pages pile up, memory swells, and a ceiling appears on how long a document you can process in one go. That is why most existing tools split documents page by page, process them separately, and stitch the results back together, breaking the continuity of tables and paragraphs that cross page boundaries.

Baidu's **Unlimited OCR** (arXiv 2606.23050) removes this ceiling differently. It replaces every attention layer in the decoder with Reference Sliding Window Attention (R-SWA), keeping the KV cache size constant throughout decoding. As a result, it can transcribe dozens of pages of a document in a single forward pass within a 32K context. The paper's phrase, "one-shot long-horizon parsing," is no exaggeration.

At ThakiCloud, we run multi-tenant inference and document-processing workloads directly on a Kubernetes-based AI/ML SaaS platform. In an environment where a large share of inference cost comes from KV cache memory, "constant memory regardless of length" is not academic curiosity but a topic that touches serving economics directly. This post explains what R-SWA is, why the KV cache stays constant, and where it fits from our platform's perspective.

## What Is Unlimited OCR

Unlimited OCR is not a from-scratch model but one that pushes DeepSeek-OCR one step further. It keeps DeepSeek-OCR's strong **DeepEncoder** as its encoder and swaps only the decoder's attention for R-SWA.

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
<div class="d3-arch" data-arch-root id="20260625unlimitedocrrswa-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 479, "height": 948, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 56, "y": 24, "w": 128, "h": 62, "title": ["Input Document", "(PDF, Image)"]}, {"id": "B", "x": 42, "y": 164, "w": 156, "h": 62, "title": ["SAM-ViT", "Feature Extraction"]}, {"id": "C", "x": 31, "y": 304, "w": 177, "h": 62, "title": ["CLIP-ViT", "16× Token Compression"]}, {"id": "D", "x": 24, "y": 444, "w": 191, "h": 62, "title": ["Visual Reference Tokens", "(256 per page)"]}, {"id": "E", "x": 163, "y": 584, "w": 153, "h": 52, "title": "R-SWA Attention"}, {"id": "F", "x": 270, "y": 444, "w": 177, "h": 62, "title": ["Sliding Window", "Recent Generated Text"]}, {"id": "G", "x": 32, "y": 714, "w": 198, "h": 62, "title": ["MoE Decoder", "3B params / ~500M active"]}, {"id": "H", "x": 272, "y": 854, "w": 170, "h": 62, "title": ["Constant KV Cache", "(length-independent)"]}, {"id": "I", "x": 26, "y": 854, "w": 191, "h": 62, "title": ["Output Text", "(Markdown / Structured)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [120, 86, 120, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [120, 226, 120, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [120, 366, 120, 444]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[120, 506], [120, 545], [120, 545], [191, 584]]}, {"src": "F", "dst": "E", "kind": "data", "curve": [[359, 506], [359, 545], [359, 545], [287, 584]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[196, 636], [131, 675], [131, 675], [131, 714]]}, {"src": "G", "dst": "H", "kind": "data", "line": [183, 776, 309, 854]}, {"src": "G", "dst": "I", "kind": "data", "line": [127, 776, 121, 854]}, {"src": "H", "dst": "E", "kind": "event", "label": "maintained", "curve": [[361, 854], [367, 815], [367, 675], [290, 636]], "off": "50%"}]});
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
      const container = document.getElementById('20260625unlimitedocrrswa-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260625unlimitedocrrswa-1';
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

*The DeepEncoder compresses each page to 256 visual tokens; the R-SWA decoder transcribes long documents in one shot with a constant KV cache. Click the diagram to enlarge.*
*A high-compression encoder shrinks a page into a handful of visual tokens, and the R-SWA decoder generates long output with a constant KV cache.*

**Encoder (DeepEncoder)**: SAM-ViT and CLIP-ViT are cascaded in series, applying 16x token compression. A single 1024x1024 PDF page compresses to just 256 visual tokens. Because the token count is already cut sharply on the input side, the amount of visual information the decoder must reference is small. This high-compression design works together with the constant KV cache discussed below to enable long-document processing.

**Decoder (an LLM with R-SWA)**: The decoder is a 3B-scale Mixture-of-Experts (MoE) model with roughly 500M activated parameters. Since only a subset of experts activate per token rather than the full 3B, compute per token is light relative to the parameter count. On top of this, replacing all attention layers with R-SWA is the model's core differentiator.

The full model is about three billion parameters, released with BF16 weights under the commercially permissive MIT license. Weights are available on Hugging Face at `baidu/Unlimited-OCR` and on ModelScope, published alongside the code on GitHub. At release it reportedly runs on a single mid-range NVIDIA GPU.

This model is from the same Baidu lineage as PaddleOCR-VL, which we covered earlier, but the approach differs. PaddleOCR-VL splits layout analysis and element recognition into two stages to secure stability with small models, whereas Unlimited OCR keeps a single end-to-end model but changes the attention mechanism to chase one-shot long-document processing. It is interesting to compare two design philosophies solving the same problem.

## The Core Mechanism: Reference Sliding Window Attention

To understand R-SWA, look first at the weaknesses of two existing approaches.

**Full attention** lets every output token see every preceding token. It is accurate, but the KV cache grows in proportion to sequence length. As pages increase, memory grows linearly and hits a ceiling.

**Plain sliding window attention (SWA)** sees only the most recent W tokens. The KV cache is fixed to the window size so memory becomes constant, but information pushed out of the window is forgotten. This works for general text generation, but for OCR, where you must "look at the source and transcribe it faithfully," it is fatal. Once the window moves past, you lose the evidence of which page you were transcribing.

R-SWA splits the difference. Its key idea comes from how humans transcribe a long document. A person writes while looking at both the last few sentences they wrote (short-term working memory) and the original document spread out in front of them (the reference). The "Reference" in R-SWA is exactly this original reference. It keeps the high-compression visual tokens produced by the encoder as an always-accessible anchor while applying a sliding window over the generated text tokens.

In other words, attention looks at two groups. One is the fixed-size visual reference tokens (encoder output), and the other is a sliding window over the recently generated text. Both groups are bounded in length, so however long the output grows, the total KV cache stays constant. It is an attention that mimics working memory in the literal sense: it never forgets the source, yet keeps memory steady.

The paper stresses that R-SWA is not an OCR-only trick but a general-purpose parsing attention. The same structure applies to tasks that read a long input and produce a long output, such as speech recognition (ASR) or translation. The pattern of fixing the input as an anchor reference and applying a sliding window to the output may generalize across sequence-to-sequence problems.

## Benchmark Results

Performance is reported on OmniDocBench, a document-parsing benchmark that comprehensively evaluates body text, tables, equations, and reading order.

- **OmniDocBench v1.5 overall score 93.23%**: a 6.22 percentage-point gain over the DeepSeek-OCR baseline.
- **OmniDocBench v1.6 overall score 93.92%**: reported as end-to-end SOTA.

What stands out is achieving accuracy gains and memory efficiency at the same time. Usually narrowing the window to save memory creates an accuracy trade-off, but R-SWA reaches a constant KV cache without accuracy loss by keeping the visual reference as a fixed anchor. Being able to stream a continuous document at once, without slicing pages and processing them separately, makes a big practical difference, because it preserves the continuity of tables, footnotes, and multi-column body text that break at page boundaries.

That said, all the figures above are values reported by the paper and the model card, not numbers we reproduced ourselves. Unlimited OCR is a 3B MoE model, so meaningful verification requires a GPU and a model download, and this post focuses on the design analysis. We plan to cover hands-on reproduction in a separate experiment.

## Applying It to ThakiCloud's K8s AI/ML SaaS Platform

From our platform's perspective, the reason this model is interesting is clear: the trickiest resource in multi-tenant inference serving is precisely KV cache memory.

**Serving economics**: In serving engines like vLLM, the number of concurrent requests, that is the batch size, depends on how much of GPU memory the KV cache occupies. A full-attention model lets a single long-document request eat a large KV cache, lowering concurrent throughput. A constant-KV-cache model, by contrast, has predictable per-request memory regardless of document length. Whether it is a one-page invoice or a 200-page contract, it is processed with the same memory footprint, so you can plan batch size stably without being shaken by the workload's length distribution. In a multi-tenant environment, per-tenant resource isolation and capacity planning become far simpler.

**On-premise and cost efficiency**: Open weights under the MIT license and operation on a single mid-range GPU are decisive for customers who cannot send data outside. In domains where the documents themselves are sensitive, such as finance, public sector, and healthcare, uploading a contract to a cloud OCR API can itself be a compliance violation. If the constant-memory design lets you stand up a long-document pipeline on-premise with a single reasonable GPU, it sits naturally on top of our stack, where we schedule GPUs with Kueue and serve with vLLM.

**Application roadmap**: On our platform, document-intelligence workloads enter as RAG indexing preprocessing and as document tools for agents. Constant-KV-cache OCR can serve as the first gate in both paths, parsing a long document accurately and in full before it is chunked. Especially for Korean public documents and financial documents with many cross-page tables and multi-column layouts, the ability to process continuously without page splitting directly improves downstream RAG quality. A realistic operating strategy is to deploy PaddleOCR-VL's split-stage stability and Unlimited OCR's one-shot long-document processing selectively, according to workload characteristics.

## Limitations and Counterarguments

An elegant design does not mean it fits every situation.

**Inherent limits of the sliding window**: Even though R-SWA keeps the visual reference as an anchor, the generated-text side is still a sliding window. Very long-range dependencies between output tokens, such as consistently expanding an abbreviation defined on page 1 across page 180, may not be guaranteed to the same degree as full attention even with the visual reference reinforcing them. This is a point to confirm through hands-on reproduction.

**Operational burden of MoE**: A 3B MoE is light in compute per token, but the full set of experts must sit in memory, so actual memory occupancy exceeds the active parameters (500M). MoE also has the property that throughput wobbles when expert routing across tokens in a batch becomes unbalanced, so performance depends on the serving engine's MoE maturity.

**The gap between benchmark and real use**: A high OmniDocBench score does not guarantee the same level on the demanding inputs of real operations, such as non-Latin scripts like Korean and Arabic, handwriting, low-quality scans, or public documents overlaid with stamps. Document OCR is an area where the gap between benchmark and field is especially large, and a separate evaluation on your own document distribution is essential before adoption.

**The need for verification**: Every figure in this post is a value reported by the paper and the model card. Whether the constant KV cache delivers the throughput gain it promises in real serving, and whether it fills 32K without accuracy loss, can only be confirmed by benchmarking it ourselves.

Even so, the idea of "fixing the reference and applying a sliding window to generation" is a clean move for handling the memory ceiling of long sequence-to-sequence tasks. If the claim that it generalizes beyond OCR to ASR and translation holds, it is well worth watching from the standpoint of operating a multi-tenant inference platform.

## Sources

- [Unlimited OCR Works: Welcome the Era of One-shot Long-horizon Parsing (arXiv 2606.23050)](https://arxiv.org/abs/2606.23050)
- [Hugging Face paper page](https://huggingface.co/papers/2606.23050)
- [baidu/Unlimited-OCR (Hugging Face model and weights)](https://huggingface.co/baidu/Unlimited-OCR)
- [baidu/Unlimited-OCR (GitHub code)](https://github.com/baidu/Unlimited-OCR)
