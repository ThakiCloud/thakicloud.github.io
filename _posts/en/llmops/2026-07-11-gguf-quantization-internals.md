---
title: "There Was Almost No Q4 Inside Q4_K_M: Dissecting GGUF Quantization Internals"
excerpt: "There is a real gap between someone who downloads a GGUF file from Hugging Face and just clicks run, and someone who knows exactly which tensors are stored at how many bits inside that file. We actually downloaded a Q4_K_M file for Qwen2.5-0.5B and opened it tensor by tensor. Despite its name, only 6 percent of the file was true 4-bit Q4_K, and the effective bit width was not 4 but 6.16. This post walks through why that happens, using measured data on K-quantization's superblock structure and its 256-divisibility rule."
tags:
  - quantization
  - gguf
  - llama-cpp
  - llmops
  - self-hosting
  - vllm
  - paxis
date: 2026-07-11
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/gguf-quantization-internals/"
categories:
  - llmops
published: false
---

![Abstract illustration of quantized neural network weights being rearranged into blocks of different sizes]({{ '/assets/images/gguf-quantization-internals-hero.png' | relative_url }})

## Overview

If you have ever run an LLM locally, you have probably seen labels like `Q4_K_M`, `Q5_K_M`, or `Q8_0`. Most people stop at "Q4 means 4 bits, so it must be the smallest and fastest" and simply download the file and run it. But that label hides more than it reveals. Few people have actually opened a file labeled `Q4_K_M` and checked, tensor by tensor, whether it is really filled with 4-bit data.

This post is for engineering leaders, practitioners responsible for inference cost, and teams looking to serve models on-premises. We downloaded the GGUF file for Qwen2.5-0.5B-Instruct at several quantization levels, measured the actual file sizes, and fully dissected one `Q4_K_M` file tensor by tensor. The result was quite different from intuition. We explain why understanding this gap matters for serving cost and quality, and what it means for ThakiCloud's inference infrastructure.

To state the conclusion up front: in this model's `Q4_K_M` file, tensors that were genuinely 4-bit K-quantization (Q4_K) accounted for only 6.1 percent of total weight capacity, and the file's effective bit width was not 4 but **6.16 bits**. The label was, in effect, almost a lie.

## What Is This Technology

GGUF is a single-file model format used in the llama.cpp ecosystem. A single file bundles metadata (architecture, tokenizer, hyperparameters) together with the quantized weights of every tensor. The key point is that **each tensor can use a different quantization type**. So a file-level label like `Q4_K_M` only indicates the "dominant type," not that the entire file is that type.

llama.cpp's quantization types broadly fall into two families. One is the **legacy family** (Q4_0, Q5_0, Q8_0), which groups 32 weights into one block. The other is the **K-quantization family** (Q4_K, Q5_K, Q6_K), which groups 256 weights into one superblock. Because K-quantization further subdivides and stores scales and minimums within the superblock, it delivers better quality than legacy at the same bit width. The `K` in `Q4_K_M` refers to this K-quantization, and `M` denotes the "medium" preset that raises some sensitive tensors to higher precision (Q6_K).

Looking a bit closer at the superblock structure reveals why K-quantization is more efficient. For example, Q4_K packs 256 weights into 144 bytes. Of that, the pure 4-bit values take up 256 x 4 bits = 128 bytes, and the remaining 16 bytes are metadata that splits the superblock into 8 sub-blocks and re-quantizes each sub-block's scale and minimum to 6 bits. In other words, the values themselves are 4 bits, but by keeping the scales that reconstruct them finely grained, error is reduced. This contrasts with legacy Q4_0, which keeps only one scale per 32 weights. So the actual bit width of Q4_K is 144 x 8 / 256 = 4.5 bits, slightly more than pure 4 bits, but with much more stable quality.

There is one decisive constraint here. **K-quantization can only be used when a tensor's number of columns (`ne[0]` in ggml terms) is divisible by 256.** This is because the superblock operates in units of 256. If this condition is not met, llama.cpp silently falls back to the legacy family (mostly Q5_0). This one rule explains the entire result of today's experiment.

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
<div class="d3-arch" data-arch-root id="gufquantizationinternals-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 677, "height": 854, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 265, "y": 24, "w": 156, "h": 46, "title": "GGUF file (Q4_K_M)"}, {"id": "B", "x": 240, "y": 148, "w": 205, "h": 62, "title": ["Determine type per tensor", "llama_tensor_get_type()"]}, {"id": "C", "x": 362, "y": 288, "w": 195, "h": 68, "title": ["Is column count ne[0]", "divisible by 256?"]}, {"id": "D", "x": 489, "y": 448, "w": 156, "h": 78, "title": ["Use K-quantization", "Q4_K / Q6_K (256", "superblock)"]}, {"id": "E", "x": 271, "y": 456, "w": 163, "h": 62, "title": ["Fall back to legacy", "Q5_0 (32 block)"]}, {"id": "F", "x": 38, "y": 291, "w": 163, "h": 62, "title": ["Raise precision for", "sensitive tensors"]}, {"id": "G", "x": 24, "y": 448, "w": 191, "h": 78, "title": ["output.weight -> Q8_0", "attn_v.weight -> Q8_0", "ffn_down.weight -> Q6_K"]}, {"id": "H", "x": 257, "y": 604, "w": 191, "h": 62, "title": ["Aggregate effective bit", "width"]}, {"id": "I", "x": 250, "y": 744, "w": 205, "h": 78, "title": ["File-wide effective bpw =", "6.16", "(label 'Q4' = 4.0)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [343, 70, 343, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[395, 210], [460, 249], [460, 249], [460, 288]]}, {"src": "C", "dst": "D", "kind": "data", "label": "\"Yes\"", "curve": [[505, 356], [567, 402], [567, 402], [567, 448]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "\"No\"", "curve": [[414, 356], [353, 402], [353, 402], [353, 456]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "curve": [[244, 210], [120, 249], [120, 249], [120, 291]]}, {"src": "F", "dst": "G", "kind": "data", "line": [120, 353, 120, 448]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[567, 526], [567, 565], [567, 565], [447, 604]]}, {"src": "E", "dst": "H", "kind": "data", "line": [353, 518, 353, 604]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[120, 526], [120, 565], [120, 565], [257, 606]]}, {"src": "H", "dst": "I", "kind": "data", "line": [353, 666, 353, 744]}]});
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
      const container = document.getElementById('gufquantizationinternals-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'gufquantizationinternals-1';
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

## Setup and Integration

The experiment can be reproduced without any extra dependencies. The Hugging Face API returns actual byte counts for file size, and you can read tensor types directly with the `gguf` reader.

```bash
# 1) Install the reader and downloader
pip install gguf huggingface_hub

# 2) Download just one Q4_K_M file (under 500MB since it's a 0.5B model)
hf download Qwen/Qwen2.5-0.5B-Instruct-GGUF \
  qwen2.5-0.5b-instruct-q4_k_m.gguf --local-dir ./gguf
```

Here is the code for opening the downloaded file's tensor types. The GGUF header embeds each tensor's name, dimensions, and ggml type integer directly, so aggregating just these values tells you exactly what the file is actually filled with.

```python
from collections import Counter
from gguf import GGUFReader

r = GGUFReader("gguf/qwen2.5-0.5b-instruct-q4_k_m.gguf")
hist = Counter()
for t in r.tensors:
    hist[t.tensor_type.name] += 1
    # Check the actual type of a few representative tensors
    if t.name in ("token_embd.weight", "output.weight",
                  "blk.0.attn_v.weight", "blk.0.ffn_down.weight",
                  "blk.0.attn_q.weight"):
        print(f"{t.name:26s} {t.shape} -> {t.tensor_type.name}")
print(dict(hist))
```

Bytes per block come straight from ggml's definitions. For example, Q4_K stores 256 weights in 144 bytes, so 4.5 bits per weight; Q6_K stores 256 in 210 bytes, so 6.5625 bits per weight; legacy Q5_0 stores 32 in 22 bytes, so 5.5 bits per weight. Summing (element count / block size) x bytes per block for every tensor gives you the exact effective bit width of the file.

## Actual Experiment Results

First, file sizes. Here are the measured values for the same model downloaded at 7 quantization levels, compared against the fp16 original (1266MB).

| Quantization | File Size | vs. fp16 |
|---|---|---|
| Q2_K | 415.2 MB | 32.8% |
| Q3_K_M | 432.0 MB | 34.1% |
| Q4_0 | 428.7 MB | 33.9% |
| **Q4_K_M** | **491.4 MB** | **38.8%** |
| Q5_K_M | 522.2 MB | 41.2% |
| Q6_K | 650.4 MB | 51.4% |
| Q8_0 | 675.7 MB | 53.4% |

Something odd already jumps out here. The difference between Q2_K (415MB) and Q4_0 (429MB) is just 14MB. We cut the bits in half, yet the file barely shrank. And `Q4_K_M` (491MB) is actually larger than pure 4-bit `Q4_0` (429MB). Looking at the names alone, this makes no sense.

The real reason becomes clear once you open the `Q4_K_M` file tensor by tensor. Here is the type distribution across its 291 tensors.

| Actual Type | Tensor Count | Nominal bpw | Share of Weight Capacity |
|---|---|---|---|
| Q5_0 | 133 | 5.5 | 54.9% |
| Q8_0 | 13 | 8.5 | 30.1% |
| Q6_K | 12 | 6.5625 | 8.8% |
| Q4_K | 12 | 4.5 | 6.1% |
| F32 (norm/bias) | 121 | 32.0 | 0.1% |

![Chart showing file sizes across quantization levels for Qwen2.5-0.5B, and the actual tensor type composition inside Q4_K_M. Q4_K_M's effective bit width is 6.16, far from the label's 4.0]({{ '/assets/images/gguf-quantization-internals-results.png' | relative_url }})

Despite the `Q4_K_M` label, genuine 4-bit K-quantization (Q4_K) accounted for only **6.1 percent** of total weight capacity. Instead, the 5.5-bit legacy type Q5_0 took up more than half (54.9 percent), and the 8.5-bit Q8_0 consumed 30 percent. Calculating the file's overall effective bit width gives **6.16 bits**, more than 1.5 times the 4 bits the label implies.

Checking representative tensors one by one makes the pattern clear. Here are the measured types:

- `token_embd.weight` (896 x 151936) -> **Q5_0**
- `output.weight` (896 x 151936) -> **Q8_0**
- `blk.0.ffn_down.weight` (4864 x 896) -> **Q6_K**
- `blk.0.attn_v.weight` (896 x 128) -> **Q8_0**
- `blk.0.attn_q.weight` (896 x 896) -> **Q5_0**

Do you see the pattern? Tensors carrying K-quantization (Q4_K, Q6_K) appeared only where the column count `ne[0]` was 4864, as with `ffn_down`. 4864 is divisible by 256 (19 x 256). Most other tensors, however, have `ne[0]` of 896, and 896 is not divisible by 256 (3.5 x 256). So these tensors could not use K-quantization at all and all fell back to legacy Q5_0. Layer this together with precision boosts (Q5_0, Q8_0) on quality-sensitive tensors like embeddings, output, and attention value, and you get a file labeled `Q4_K_M` whose actual substance is chunks of 5.5 to 8.5 bits.

Here is exactly where the effective bit width of 6.16 comes from. This file contains a total of 630 million weights subject to quantization, stored in roughly 485MB of bytes. 485,452,288 bytes x 8 / 630,167,424 weights = 6.16 bits per weight. Add about 6MB of file metadata and alignment padding, and it matches the actual file size of 491MB exactly. The fact that the calculation matches the file size is also evidence that the tensor type readout was accurate.

This also explains the two odd points in the file size table. Q2_K (415MB) is only barely smaller than Q4_0 (429MB) because, in this small model, the embedding and output tensors take up a large share of total weights, and they stay at high precision regardless of the quantization level. No matter how much you lower the bits, a fixed cost sits at the floor and does not shrink. And `Q4_K_M` is larger than pure 4-bit `Q4_0` because the `M` preset paid for pulling sensitive tensors up to Q6_K and Q8_0 in file size. The label's number is lower, but the effective bit width is actually higher.

To summarize, this experiment demonstrated three facts through measurement. First, a file-level label only indicates the dominant type and does not guarantee the effective bit width. Second, in small models whose hidden size is not a multiple of 256, K-quantization is largely disabled, widening the gap between label and substance. Third, in small models the embedding and output tensors take up a large share of total capacity, so keeping them at high precision significantly dilutes the savings that "4-bit quantization" is supposed to deliver.

## Implications for ThakiCloud Products

This experiment only dissected one small model, but its lesson carries straight through to production serving infrastructure. ThakiCloud's ai-platform serves models to diverse customer environments on top of Kubernetes and Kueue-based GPU scheduling. In that context, "which quantization to choose" is not a matter of taste, it is a decision that determines GPU memory allocation, batch size, and ultimately cost per token.

Trusting the label as-is throws off capacity planning. If you assume `Q4_K_M` means "4 bits, so a quarter of the original" and allocate GPU memory accordingly, you will find, as in the experiment above, that it actually takes up around 40 percent of the original, and batch slots run out faster than expected. This matters especially in multi-tenant serving, where many small models must be packed tightly onto a single node. There, the difference between measuring the effective bit width and simply trusting the label directly translates into how many models a node can hold. This is exactly why we verify GGUF files tensor by tensor when building serving images. For customers who require self-hosted, on-premises, or sovereign deployment in particular, this habit of measuring rather than assuming becomes a genuine cost advantage.

Making this verification itself a repeatable task is where Paxis comes in. Paxis is ThakiCloud's Agent-Native Cloud control plane running on top of ai-platform, treating skills, tools, policies, and audit logs as first-class resources. If today's experiment, downloading a GGUF file, aggregating tensor types, and flagging a warning when effective bit width exceeds a threshold, is registered as a single skill, it runs in an isolated sandbox and every result passes through policy gates and audit logs. Instead of having someone manually open a file every time a new model lands in the registry, a validated skeleton runs automatically. This is how the economics that low-cost serving (ai-platform) creates and the orchestration (Paxis) that makes that serving safely repeatable fit together.

## Limitations and Counterarguments

A few things should be made explicit.

First, these results are close to an extreme case specific to Qwen2.5-0.5B, whose hidden size is 896. In larger models whose hidden size is a multiple of 256 (for example, 4096 or 8192), K-quantization applies normally, and `Q4_K_M`'s effective bit width lands much closer to the label, around 4.8 bits.

In other words, the correct lesson is not "the label is always a lie," but that "the gap between label and substance varies greatly with model architecture, and is larger for smaller models."

Second, a larger file size is not necessarily a bad thing. Keeping embedding and output tensors at high precision is a deliberate choice to prevent quality collapse in small models. In other words, this `Q4_K_M` is not a "badly made" file, but a reasonable result of automatically raising precision to protect quality in a small model. The cost simply does not show up in the label.

Third, this post only measured file structure and capacity, not actual inference quality (perplexity, benchmark scores). The relationship between bit width and quality requires a separate experiment, which we leave as the topic of a future post. What we can say here is only an operational principle: do not plan capacity and memory around the label, measure it.

The difference between just clicking run on a local model and knowing what is actually inside the file comes down to exactly this habit of measurement. Five minutes spent checking the numbers behind the label can change the accuracy of your entire serving cost plan.

## Sources

- Qwen2.5-0.5B-Instruct-GGUF model repository: [huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF)
- llama.cpp quantization documentation: [github.com/ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md)
- File sizes, tensor type distributions, and effective bit widths were measured directly from actual files downloaded from the repository above.
