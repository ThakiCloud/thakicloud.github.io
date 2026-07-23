---
title: "Why an 8x Larger Model Is 5x Cheaper: The Real Structure of LLM Inference Costs"
excerpt: "We dissect, with a roofline model, the paradox that the 284B DeepSeek V4 Flash prices its output tokens 5x cheaper than the 35B Qwen3.6. From KV cache reads to MoE batching economics to 8xH100 serving-shape calculations, we walk through the real structure of inference cost in numbers."
seo_title: "LLM Inference Cost Structure Analysis: KV Cache and MoE Serving Economics - Thaki Cloud"
seo_description: "We analyze the real structure of LLM inference cost through the pricing paradox between DeepSeek V4 Flash and Qwen3.6, including KV cache reads, MoE batching economics, and 8xH100 roofline calculations."
date: 2026-07-05
tags:
  - LLM-Inference
  - KV-Cache
  - MoE
  - vLLM
  - Serving-Cost
  - DeepSeek
  - Qwen
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/llmops/llm-inference-economics-kv-cache-moe-roofline/
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/llm-inference-economics-kv-cache-moe-roofline/"
categories:
  - llmops
header:
  teaser: /assets/images/llm-inference-economics-kv-cache-moe-roofline-hero.webp
---

![LLM inference cost structure]({{ '/assets/images/llm-inference-economics-kv-cache-moe-roofline-hero.webp' | relative_url }})

## Overview: The Paradox of an 8x Larger Model Being 5x Cheaper

An interesting question has been making the rounds in the inference infrastructure community lately. DeepSeek V4 Flash, a 284B-total-parameter model, prices its output tokens roughly 5x cheaper than the 35B Qwen3.6-35B-A3B. Looking at the actual pricing, input tokens for both sit at a similar level around $0.14/M, but output tokens run $0.18-0.28/M for DeepSeek V4 Flash versus $1.00-1.49/M for Qwen3.6.

There is something even stranger. In terms of active parameters per token, Qwen3.6 uses 3B and DeepSeek V4 Flash uses 13B. By compute alone, Qwen is actually 4x lighter, yet market pricing runs in the opposite direction. The intuition that parameter count equals cost gets broken twice in a row here.

This article dissects that paradox at three levels: first, why the dominant term in decode cost is memory reads rather than compute; second, the structural tension between KV cache depth and flat-rate pricing; and third, what emerges when we directly calculate the optimal serving shape on 8xH100 with a roofline model. For an operator like ThakiCloud that serves models directly in customer environments, this structure translates directly into cost competitiveness, so we also lay out the practical implications.

## Confirming the Architecture Facts of Both Models

Let's start by pinning down the specs precisely.

DeepSeek V4 Flash is a 284B-total / 13B-active MoE model. The router selects the top-6 among 256 routed experts plus 1 shared expert. Attention is a hybrid stack combining CSA (Compressed Sparse Attention) and HCA (Heavily Compressed Attention), reading only the top-1,024 compressed KV entries per query pass. According to official materials, at a 1M context this brings inference FLOPs per token down to 27% and KV cache down to 10% compared with V3.2. The checkpoint is a mixed format, with MoE experts in FP4 and the rest in FP8.

Qwen3.6-35B-A3B is a 35B-total / 3B-active MoE model (256 experts, 8 routed + 1 shared). Attention is a hybrid of Gated DeltaNet linear attention layers and full attention layers (2 KV heads, head dim 256). Native context is 262K, extended to 1M via YaRN. At an FP8 checkpoint it comes to roughly 35GB, which fits on a single H100.

In short, both are state-of-the-art, efficiency-oriented designs. What makes this comparison more interesting is that Qwen is not expensive because it is some naive dense model.

## The Real Structure of Decode Cost: A Roofline Model

Token generation (decode) is bound by memory bandwidth, not compute. A first-order approximation of decode step time looks like this.

```text
T_step = (bytes of weight to read + Σ per-request KV read bytes) / memory bandwidth
throughput = batch_size / T_step
```

The two terms here have completely different characters.

Weight reads are shared across the batch. Reading the weights once per step is shared by every request in the batch. At a batch size of 512, the per-token weight cost drops to 1/512. This is why MoE's total parameter count becomes "nearly free at large batch sizes."

KV reads, by contrast, are per-request. Each request must read its own context's KV cache, and this cost does not get divided as the batch grows. It scales linearly as context gets deeper.

So once the batch is large enough and context is long enough, the dominant cost term shifts from weight to KV reads. Yet API pricing is flat per token regardless of context depth: a request with 32K of history and one with 500K of history pay the same output price. From a serving operator's perspective, a model that can keep KV reads bounded regardless of depth is the one that generates margin under a flat-rate regime.

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
<div class="d3-arch" data-arch-root id="nomicskvcachemoeroofline-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 618, "height": 806, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 291, "y": 24, "w": 142, "h": 46, "title": "Decode step cost"}, {"id": "B", "x": 423, "y": 148, "w": 120, "h": 46, "title": "Weight read"}, {"id": "C", "x": 180, "y": 148, "w": 121, "h": 46, "title": "KV cache read"}, {"id": "B1", "x": 381, "y": 272, "w": 205, "h": 62, "title": ["Shared across whole batch", "Split 1/512 at batch 512"]}, {"id": "C1", "x": 156, "y": 272, "w": 170, "h": 62, "title": ["Occurs per request", "Not divided by batch"]}, {"id": "D", "x": 171, "y": 412, "w": 139, "h": 52, "title": "Context depth"}, {"id": "E", "x": 270, "y": 556, "w": 184, "h": 78, "title": ["Grows in proportion to", "depth", "O(L) read"]}, {"id": "F", "x": 24, "y": 556, "w": 191, "h": 78, "title": ["Fixed top-1,024 entries", "Constant regardless of", "depth"]}, {"id": "G", "x": 295, "y": 712, "w": 135, "h": 62, "title": ["Cost explodes", "at long context"]}, {"id": "H", "x": 24, "y": 712, "w": 191, "h": 62, "title": ["Margin secured", "under flat-rate pricing"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[407, 70], [483, 109], [483, 109], [483, 148]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[317, 70], [241, 109], [241, 109], [241, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [483, 194, 483, 272]}, {"src": "C", "dst": "C1", "kind": "data", "line": [241, 194, 241, 272]}, {"src": "C1", "dst": "D", "kind": "data", "line": [241, 334, 241, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "\"Standard attention\"", "curve": [[285, 464], [362, 510], [362, 510], [362, 556]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "\"Sparse attention CSA/HCA\"", "curve": [[197, 464], [120, 510], [120, 510], [120, 556]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "line": [362, 634, 362, 712]}, {"src": "F", "dst": "H", "kind": "data", "line": [120, 634, 120, 712]}]});
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
      const container = document.getElementById('nomicskvcachemoeroofline-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nomicskvcachemoeroofline-1';
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

## 8xH100 Serving Shape: A Numeric Comparison

Let's now actually put both models on 8xH100 (SXM5, 80GB HBM3 per card, 3.35TB/s per card, 640GB total, 26.8TB/s aggregate). We set the hourly cost at roughly $20 on an on-demand basis.

The modeling assumptions are as follows. Qwen3.6 has roughly 35GB of FP8 weights; assuming 10 of its 40 hybrid layers are full attention layers, per-token KV is about 10KB [Est.] (2 KV heads x 256 dim x 2 for K/V x 10 layers x 1 byte). DeepSeek V4 Flash has an effective weight of roughly 150GB [Est.] with FP4 experts plus FP8 dense; stored KV, based on the official claim of 10% versus V3.2, comes to about 3.5KB per token [Est.], while decode-time reads are a constant roughly 4MB per request per step via the top-1,024 entries.

### The Serving Shape Differs From the Start

Qwen3.6's optimal shape is 8 independent replicas (DP8). Since the model fits on a single card, there is no inter-GPU communication at all, leaving roughly 38GB of KV budget per card. This is the typical serving shape for a design oriented toward local hosting.

DeepSeek V4 Flash requires all 8 cards to be grouped as a single TP/EP unit. In exchange for the all-to-all communication this introduces, roughly 490GB of KV budget is shared across the whole batch.

### Throughput Calculations by Context Depth

Here are the roofline calculation results (actual achieved throughput is typically 50-60% of these figures, and EP communication and prefill are not included).

At 8K context, the Qwen cluster runs about 76k tok/s and DeepSeek V4 Flash about 90k tok/s, roughly comparable. Once communication overhead is factored in, Qwen is effectively ahead. This means at short context, the smaller model is hardware-cheaper or on par.

At 32K the gap starts to open up. Qwen's per-request KV read grows to 320MB, dropping it to about 31k tok/s, while DeepSeek V4 Flash holds at about 90k tok/s since its KV read is still constant. That's roughly a 3x difference.

At 256K, Qwen's per-request KV reaches 2.56GB, and the storage ceiling caps per-card batch size at 14, dropping it to about 5.3k tok/s. DeepSeek V4 Flash runs about 45k tok/s, an 8.5x difference.

At 1M, Qwen must read 10GB per request at every step, dropping it to about 1.2k tok/s with a ceiling of 24 concurrent sessions. DeepSeek V4 Flash runs about 11k tok/s with 64 concurrent sessions, a gap approaching 10x.

Converted to dollars, at 32K it's Qwen $0.18/M versus DeepSeek V4 Flash $0.06/M; at 1M it's Qwen $4.6/M versus DeepSeek V4 Flash $0.5/M. Across the tens-to-hundreds-of-K range that is the average depth for agentic workloads, the cost gap widens to 3-10x, which lands in exactly the same order of magnitude as the observed API price difference (roughly 5x).

![Throughput and cost comparison by context depth]({{ '/assets/images/llm-inference-economics-kv-cache-moe-roofline-results.webp' | relative_url }})

One thing worth stating honestly: there is up to a 40x discrepancy across public sources on DeepSeek V4 Flash's stored KV per token (the vLLM recipes' claim of "10% versus V3.2" conflicts with the KV table in some deployment guides). The calculation above adopts the former, which is closer to a primary source, and we want to stress that the conclusion rests on the direction of scaling, the structure by which the gap widens with depth, rather than on the absolute values.

## Three Things the Calculation Reveals

First, Qwen's bottleneck is not KV storage but KV reads. Thanks to Gated DeltaNet, storage (roughly 10KB per token) is already excellent. The problem is that the O(L) reads of the full attention layers repeat at every decode step. DeepSeek V4 Flash keeps storage small and also locks reads down to a constant.

Second, the batch absorbs the weight reads of MoE's 284B. At a large batch, per-step weight reads are fixed at roughly 150GB, which comes to 0.3GB per token when split across 512 tokens. Qwen's DP8, by contrast, has each card read its own 35GB independently, aggregating to 280GB per step across the cluster. The 8x difference in total parameters reverses in effective reads.

Third, even though Qwen is hardware-cheaper at short context, its market price is 5x higher. That is quantitative evidence that the price sheet does not reflect physical cost. DeepSeek runs its 1st-party API at massive traffic volume and passes the cost savings from infrastructure optimizations, dedicated kernels (deep_gemm_mega_moe, FP4 indexer cache), prefill/decode disaggregation, MTP, and a 98% cache-hit discount, straight into pricing. Qwen3.6-35B, whose design is itself oriented toward local/single-GPU use, has its API serving mostly handled by third parties running a general-purpose vLLM stack; when traffic density is low, GPU idle time has to get folded into the price, pushing quotes up. Market price is a function of demand density and optimization level, not of physical cost.

## Implications for ThakiCloud's Product

This analysis connects directly to the decisions ThakiCloud's ai-platform faces every day. When serving models on customer GPUs in on-prem and sovereign cloud environments, what determines per-token cost on the same hardware is not model size but serving shape. As the calculations above show, effective throughput can differ by several multiples on the same 8xH100 depending on the choice between DP8 and a TP/EP group, the KV cache dtype, and the max-model-len setting. ai-platform makes it standard process to configure vLLM serving parameters, on top of K8s- and Kueue-based GPU scheduling, to match the workload profile (average context depth, concurrent session count), and this article's roofline model is the starting point for that sizing.

There is also an agent-workload angle. In Paxis (ThakiCloud's Agent-Native Cloud), agents generate long histories and repeated tool calls, which is exactly the kind of traffic that pushes KV depth deep. The practical conclusion of this analysis is that the combination of a model that stays strong at deep context and a prefix-cache infrastructure is what governs agent economics. Low serving cost (ai-platform) is what produces agent unit economics (Paxis).

## Limitations and Counterarguments

Let's state the limitations of this analysis explicitly. First, roofline is an upper-bound model. Actual throughput typically comes in at 50-60% of these figures due to kernel efficiency, EP all-to-all communication, and interference between prefill and decode, while speculative techniques such as MTP push throughput back up in the other direction. Second, DeepSeek V4 Flash's KV figures conflict across public sources, so we have kept the [Est.] label. Third, the number of full attention layers in Qwen3.6 is an estimate based on the public config, and the absolute values shift if the hybrid ratio differs. Fourth, quality is a separate axis: DeepSeek V4 Flash trails V4 Pro on complex multi-step reasoning, so choosing a model on cost alone would be the wrong conclusion. This cost analysis only answers the question of which serving shape is economical at a given, fixed level of required quality.

## References

- [vLLM Recipes: DeepSeek-V4-Flash](https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4-Flash)
- [vLLM Recipes: Qwen3.6-35B-A3B](https://recipes.vllm.ai/Qwen/Qwen3.6-35B-A3B)
- [DeepSeek API Docs: Models & Pricing](https://api-docs.deepseek.com/quick_start/pricing)
- [OpenRouter: DeepSeek V4 Flash](https://openrouter.ai/deepseek/deepseek-v4-flash)
- [OpenRouter: Qwen3.6 35B A3B](https://openrouter.ai/qwen/qwen3.6-35b-a3b)
- [Qwen Official Blog: Qwen3.6-35B-A3B](https://qwen.ai/blog?id=qwen3.6-35b-a3b)
- [Spheron: Deploy DeepSeek V4-Flash on GPU Cloud](https://www.spheron.network/blog/deploy-deepseek-v4-flash-gpu-cloud/)
