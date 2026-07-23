---
title: "How to Systematically Learn LLM Internals: From Tokenization to Inference Optimization"
excerpt: "If you operate LLMs in production but can't explain why the KV cache eats memory or what GQA actually saves, your optimization work is running on intuition. amitshekhariitbhu/llm-internals is a learning repository that strings together tokenization, the attention formula, transformer blocks, KV cache, MoE, and GQA in a deliberate sequence. This post explains why each topic is a direct weapon for infrastructure engineers."
seo_title: "LLM Internals Learning Roadmap: Tokenization, Attention, KV Cache, MoE, GQA | Thaki Cloud"
seo_description: "An analysis of the llm-internals learning repository, covering tokenization (BPE), Query/Key/Value attention, transformer blocks, KV cache, MoE, and GQA from an infrastructure engineer's perspective, and connecting them to vLLM and Kueue serving optimization."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - llm-internals
  - transformer
  - kv-cache
  - mixture-of-experts
  - gqa
  - llm-inference
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "microchip"
published: true
canonical_url: "https://thakicloud.com/tech-blog/en/technique/llm-internals-learning-path/"
categories:
  - llmops
---

## Overview

If you operate LLM serving long enough, you eventually hit an odd spot. You've deployed vLLM, you monitor GPU utilization, you tune batch sizes, and yet you still can't put into words why a given request occupies this much KV cache, or exactly what GQA trims away to save memory bandwidth. You know how to operate the tools, but the principles underneath stay blurry. That gap forces optimization to run on intuition, and it leaves you unable to reason about root causes when something breaks.

A learning resource that takes this problem head-on is [amitshekhariitbhu/llm-internals](https://github.com/amitshekhariitbhu/llm-internals). It's a step-by-step repository that strings together blog posts and videos in a deliberate order, starting from tokenization and moving through attention, transformer architecture, KV cache, and inference optimization. The original author is Amit Shekhar, and the topics are arranged to build a single coherent mental model rather than leaving readers with a pile of disconnected one-off tutorials.

ThakiCloud operates ai-platform, which serves models across diverse customer environments on Kubernetes. Most of what determines serving cost and latency traces back to the internals this repository covers. So this post isn't just a resource pointer: it walks through why each topic becomes a direct, usable weapon for an infrastructure engineer.

## What This Resource Actually Is

llm-internals isn't a framework you run code with, it's a **learning path**. It follows the pipeline an LLM goes through from receiving input to producing the next token, presenting the concepts needed at each stage alongside external references, in order. The core value lies in the curriculum design itself: deciding what needs to be understood, and in what sequence, for the full picture to click into place.

The main topics the repository covers follow this flow:

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
<div class="d3-arch" data-arch-root id="llminternalslearningpath-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 599, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 227, "y": 24, "w": 120, "h": 46, "title": "Input text"}, {"id": "B", "x": 195, "y": 148, "w": 184, "h": 62, "title": ["Tokenization", "BPE Byte Pair Encoding"]}, {"id": "C", "x": 212, "y": 288, "w": 149, "h": 62, "title": ["Embedding", "Tokens to vectors"]}, {"id": "D", "x": 219, "y": 428, "w": 135, "h": 62, "title": ["Attention", "Query Key Value"]}, {"id": "E", "x": 281, "y": 568, "w": 198, "h": 62, "title": ["Transformer block", "Attention + FFN repeated"]}, {"id": "F", "x": 397, "y": 708, "w": 170, "h": 62, "title": ["KV Cache", "Speeds up generation"]}, {"id": "G", "x": 214, "y": 708, "w": 128, "h": 62, "title": ["MoE", "Expert routing"]}, {"id": "H", "x": 24, "y": 708, "w": 135, "h": 62, "title": ["GQA", "KV head sharing"]}, {"id": "I", "x": 186, "y": 848, "w": 184, "h": 62, "title": ["Inference optimization", "Serving efficiency"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [287, 70, 287, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [287, 210, 287, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [287, 350, 287, 428]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[328, 490], [380, 529], [380, 529], [380, 568]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[425, 630], [482, 669], [482, 669], [482, 708]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[335, 630], [278, 669], [278, 669], [278, 708]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[219, 483], [92, 529], [92, 669], [92, 708]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[482, 770], [482, 809], [482, 809], [368, 848]]}, {"src": "G", "dst": "I", "kind": "data", "line": [278, 770, 278, 848]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[92, 770], [92, 809], [92, 809], [195, 848]]}]});
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
      const container = document.getElementById('llminternalslearningpath-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'llminternalslearningpath-1';
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

This order matters because later topics don't make sense without the earlier ones. The KV cache only means something once you know what the Key and Value in attention actually are, and GQA only shows "what's being shared" once you understand the head structure of multi-head attention. The repository's value isn't the depth of any single article, it's the sequencing that never breaks this dependency chain.

## A Closer Look at the Core Topics

### Tokenization: Where Everything Starts

LLMs don't work directly with letters or words, they process tokens. Most modern models use some variant of BPE (Byte Pair Encoding), which builds a vocabulary by repeatedly merging byte pairs that frequently appear together. Tokenization looks trivial, but from a serving standpoint it's a direct cost driver. The same sentence can produce very different token counts depending on the language and the tokenizer, and token count directly maps to KV cache occupancy and compute. The fact that non-English text (Korean, Arabic, and similar languages) tends to consume more tokens than English is something you have to account for when estimating serving costs.

### Attention: Query, Key, Value

The heart of the transformer is self-attention. Each token gets projected into three vectors. Query represents "what am I looking for," Key represents "what do I offer," and Value represents "what I actually deliver." The attention score is computed as the dot product of Query and Key, then passed through scaling and softmax to produce a weighted sum over Value.

```
Attention(Q, K, V) = softmax( (Q · Kᵀ) / √d_k ) · V
```

The formula itself is simple, but the fact that attention computation grows as O(n²) with sequence length n is what gives rise to nearly every optimization technique that follows. This is the origin point for why long context is expensive, and why serving infrastructure is so sensitive to context length.

### Transformer Blocks and the KV Cache

A transformer stacks multiple layers of blocks, each combining attention with a feed-forward network (FFN). In autoregressive generation, tokens are produced one at a time, and recomputing the Key and Value of every prior token at each step would be wasteful. The **KV cache** solves this by storing already-computed Keys and Values and reusing them, which speeds up generation.

The catch is that this cache consumes memory. Cache size scales roughly with `2 × number of layers × number of KV heads × head dimension × sequence length × batch size`. Long contexts and many concurrent requests can blow this number up fast. This structural pressure is exactly why vLLM's PagedAttention manages the KV cache in pages: to reduce fragmentation.

### MoE and GQA: Structural Changes for Efficiency

**Mixture of Experts (MoE)** splits the FFN into multiple experts, and a router activates only a subset of experts per token. Total parameter count is large, but the actual compute per token stays small. In exchange, serving has to deal with new challenges: expert parallelism, routing imbalance, and memory placement.

**Grouped-Query Attention (GQA)** is a middle ground between multi-head attention (MHA) and multi-query attention (MQA). In MHA, every head has its own Key/Value; in MQA, all heads share a single Key/Value. GQA groups heads into a handful of clusters and shares KV within each group. The result is a **reduction in KV cache size and memory bandwidth** with minimal quality loss. Understanding GQA clarifies why recent open-weight models adopt this structure, and why it shifts your memory budget at serving time.

## Why This Knowledge Matters for Infrastructure Engineers

None of the topics above are academic curiosities, they are direct causes of serving cost. Understanding the KV cache size formula lets you predict how concurrent request count and context length collide with GPU memory. Understanding GQA lets you explain why one model handles more requests than another on the same GPU. Understanding MoE prepares you for why expert-parallel placement complicates scheduling.

Without this knowledge, the usual response to an incident is to see "out of memory" and repeatedly reach for the expensive fix: cut the batch size blindly, or throw more GPUs at it. An engineer who understands the internals has finer levers available: KV cache paging, context length caps, quantization, and choosing a GQA-based model.

## Implications for ThakiCloud's Products

ThakiCloud's **ai-platform** delivers multi-tenant, vLLM-based inference on top of Kubernetes and Kueue GPU scheduling. The internals covered in this post translate directly into operational levers.

- **KV cache**: Using PagedAttention and the KV cache size formula as a basis, we set per-tenant context length caps and concurrency budgets. Predicting cache occupancy lets us push throughput up without over-committing GPU memory.
- **GQA and quantization**: To fit more requests on the same hardware, we prioritize open-weight models that adopt GQA, combining it with quantization to target low serving costs in on-premise and sovereign environments.
- **MoE serving**: MoE models that require expert parallelism get separate treatment in Kueue queue design and node placement, planned for in advance.

From an agent perspective, ThakiCloud's Agent-Native Cloud, **Paxis**, is well suited to accumulating this kind of internal knowledge as a team asset. Because Paxis treats skills as first-class resources, a recurring judgment call like "compute the KV cache budget" can be hardened into a verified skill, reused inside an isolated sandbox, and tracked through audit logs. It becomes a channel for turning serving know-how, which otherwise tends to live only in individual engineers' heads, into procedural knowledge the whole organization owns.

## Limitations and Counterarguments

The biggest weakness of this resource is the fate of any curated repository. Because it's built by stitching together external blog posts and videos, links can go stale or disappear, and the notation and depth vary from source to source. There's also no guarantee that the latest architectural shifts (new attention variants, for instance) get folded in right away.

There's also still a gap between conceptual understanding and real-world operation. Memorizing the KV cache formula doesn't hand you the actual throughput number on a specific GPU. Real benchmarking, profiling, and workload-specific tuning all require separate hands-on experience. This learning path is genuinely valuable as a starting point for building an accurate mental model, but it isn't, by itself, the endpoint of serving optimization. Understanding the principles has to be followed by validation against real traffic.

## Sources

- [amitshekhariitbhu/llm-internals (GitHub)](https://github.com/amitshekhariitbhu/llm-internals)
- Original recommending tweet: Dan Kornas, "Stop learning LLM internals from random one-off tutorials"
