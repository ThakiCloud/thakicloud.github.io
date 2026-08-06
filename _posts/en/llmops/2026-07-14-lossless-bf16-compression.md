---
title: "We Deleted 423GB from GLM-5.2 Without Quantization: Measuring the Waste in BF16 Exponents"
excerpt: "Someone claimed they shrank GLM-5.2 from 1403GB to 980GB. Not quantization, not pruning, but lossless compression that is bit-for-bit identical to the original. It was hard to believe, so we opened up 490 million weights of Qwen2.5-0.5B and measured the entropy of the BF16 exponent field ourselves. The 8 allocated bits were actually carrying only 2.64 bits of information, which means roughly 33.5 percent can be removed losslessly. This post walks through where that waste comes from, and why the savings show up not only on disk but in VRAM, using measured data."
tags:
  - lossless-compression
  - bf16
  - quantization
  - vram
  - llmops
  - self-hosting
  - vllm
  - paxis
date: 2026-07-14
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/lossless-bf16-compression/"
categories:
  - llmops
published: false
---

![Abstract illustration of densely packed glass cubes being losslessly compacted into a smaller cluster]({{ '/assets/images/lossless-bf16-compression-hero.png' | relative_url }})

## Overview

Any team that has served a large open-weight model locally knows the first wall is always size. A model like GLM-5.2, with more than 700 billion parameters, approaches 1.4 terabytes in raw BF16, and fitting it across several GPUs makes VRAM the direct cost. The answer to this problem has almost always been quantization: dropping 16 bits to 8, to 4, even to 2, trading a bit of quality along the way.

This post is written for engineering leaders who own inference cost, practitioners deploying models on premises, and data scientists in regulated environments who cannot lose a single bit of precision. Recently a researcher named brianbell-x published that they had deleted 423GB from GLM-5.2. 1403GB became 980GB, and the striking part was that the method was not quantization. It was not pruning or distillation either, but lossless compression that reconstructs the original bit for bit when decompressed. If something is lossless yet shrinks by 30 percent, it means the original format was wasting exactly that much.

Rather than take the claim on faith, we decided to verify it directly. We opened 490 million actual trained weights of Qwen2.5-0.5B and measured the entropy of the BF16 exponent field, confirming that the 8 allocated bits carry only 2.64 bits of real information. The theoretical lossless bound came out to 33.5 percent, which lined up almost exactly with the 30.17 percent the original author achieved with a real codec. This post covers that measurement and explains why the saving happens not only on disk but in VRAM.

## What the technique is

First we need to see how BF16 stores a single number. BF16 (brain floating point 16) divides 16 bits into three parts: 1 sign bit, 8 exponent bits, and 7 mantissa bits. The exponent gets a full 8 bits because BF16 is designed to keep the same wide dynamic range as FP32, so it can represent very large or very small values.

The problem is that the weights of a trained model barely use that wide range. In a well-trained neural network, most weights cluster around small values near zero. As a result the exponent field bunches around a handful of values, and out of the 256 possibilities that 8 bits can express, only a small fraction actually appear. That is where the waste lives: 8 bits are allocated, but the actual information carried is far less.

The idea of lossless compression is simple. Entropy-code the low-information exponent field into a short representation, and leave the near-incompressible 8 bits of sign and mantissa alone. The original author's implementation combines sign and exponent into a 4-bit code that points into a lookup table of the 15 most common exponent combinations. Rare values not in the table are stored separately in full form. The process is summarized below.

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
<div class="d3-arch" data-arch-root id="4losslessbf16compression-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 268, "height": 1102, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 212, "h": 78, "title": ["Trained BF16 weight", "16 bit = sign 1 + exponent", "8 + mantissa 7"]}, {"id": "B", "x": 31, "y": 180, "w": 198, "h": 78, "title": ["Analyze exponent field", "only a few of 256 values", "appear"]}, {"id": "C", "x": 28, "y": 336, "w": 205, "h": 78, "title": ["Measure exponent entropy", "8 bit allocation -> ~2.64", "bit"]}, {"id": "D", "x": 24, "y": 492, "w": 212, "h": 94, "title": ["Replace sign+exponent with", "a 4-bit code", "15 most common combos ->", "lookup table"]}, {"id": "E", "x": 35, "y": 664, "w": 191, "h": 78, "title": ["Keep the 7-bit mantissa", "intact", "bit-for-bit lossless"]}, {"id": "F", "x": 35, "y": 820, "w": 191, "h": 94, "title": ["Store rare exponents in", "full form", "keep fixed-width", "addressing"]}, {"id": "G", "x": 24, "y": 992, "w": 212, "h": 78, "title": ["Compressed weight", "~10.6 bit per weight (~33%", "saved)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [130, 102, 130, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [130, 258, 130, 336]}, {"src": "C", "dst": "D", "kind": "data", "line": [130, 414, 130, 492]}, {"src": "D", "dst": "E", "kind": "data", "line": [130, 586, 130, 664]}, {"src": "E", "dst": "F", "kind": "data", "line": [130, 742, 130, 820]}, {"src": "F", "dst": "G", "kind": "data", "line": [130, 914, 130, 992]}]});
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
      const container = document.getElementById('4losslessbf16compression-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '4losslessbf16compression-1';
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

This approach is fundamentally different from quantization. Quantization truncates the mantissa or rounds values, actually discarding precision. Lossless compression discards nothing. It simply rewrites the same information in a shorter code, so decompression restores the original weights without a single bit of error. Recent work like DFloat11 and ZipNN belongs to the same family. ZipNN reported that the BF16 exponent field of trained LLM weights holds only about 2.6 bits of Shannon entropy within its 8-bit allocation. What we wanted to know was whether that number reproduces on a real model.

## Measuring exponent entropy ourselves

To verify, we opened one real trained BF16 model in an isolated workspace. The target was Qwen2.5-0.5B, a real deployed model with 490 million weights. We parsed the binary layout of the safetensors file directly, read each BF16 tensor as 16-bit integers, extracted the 8 bits of the exponent, and computed the value distribution and Shannon entropy. We used no framework estimate, only the numbers from the actual tensor bytes.

The core measurement code, the part that views a BF16 value as a 16-bit integer and slices out the exponent field, is below.

```python
import numpy as np

def bf16_exponent_bytes(raw: np.ndarray) -> np.ndarray:
    # raw = BF16 values viewed as uint16. Exponent = bits 14..7 (8 bits)
    return ((raw >> 7) & 0xFF).astype(np.uint8)

# Parse the safetensors header, read BF16 tensors as uint16, and compute the
# Shannon entropy from the frequency of exponent values.
```

The result was more dramatic than expected. Here is what a sweep across 290 BF16 tensors totaling 494 million weights showed.

| Item | Measured |
|---|---|
| BF16 tensors | 290 |
| Total weights | 494,032,768 |
| Distinct exponent values that appear | 38 out of 256 |
| Exponent field Shannon entropy | **2.6386 bits** (of 8 allocated) |
| Share of top 3 most common exponents | about 72 percent of all weights |
| Bits per weight after compression | 16 bit -> 10.64 bit |
| Theoretical lossless saving | **33.5 percent** |

The exponent field can express 256 values, but only 38 actually appeared, and the top 3 of those covered 72 percent of all weights. The Shannon entropy was 2.6386 bits, matching ZipNN's reported ~2.6 bits almost exactly. In other words, the 8-bit exponent field was carrying only 2.64 bits of information, and the remaining 5.36 bits were pure waste.

Removing that waste losslessly drops bits per weight from 16 to 10.64, keeping the 8 bits of sign and mantissa intact while compressing the exponent to its entropy bound. As a saving, that is 33.5 percent.

![Chart of the Qwen2.5-0.5B measurement showing the BF16 exponent field uses only 2.64 bits in practice, and losslessly compressing it shrinks GLM-5.2 from 1403GB to about 980GB]({{ '/assets/images/lossless-bf16-compression-results.png' | relative_url }})

Projecting this 33.5 percent onto GLM-5.2 (753B) scale, 1403GB becomes about 933GB. The value the original author achieved with a real codec was 980GB, a 30.17 percent saving. The roughly 3 percentage point gap between our theoretical bound (33.5 percent) and the actual implementation (30.17 percent) is no accident. Real entropy coders do not fully reach the Shannon bound, rare exponent values must be stored in full form, and codes must be fixed-width to allow random access on the GPU, all of which add slight overhead. That theory and implementation landed this close is strong evidence that the original claim is true and the approach is sound.

## Why VRAM shrinks too, on the GPU

Here is the most easily misunderstood point. Most compression only shrinks on disk and returns to full size the moment the model is loaded onto the GPU, because it has to be decompressed to compute. Yet this lossless compression's 30 percent is a VRAM number, not a disk number. That is what makes this technique different from ordinary file compression.

The trick is in the fixed-width codes. Because every weight's compressed code is the same width, you can compute exactly where weight N lives without decompressing. No separate unpacking pass and no second copy in the original format are needed. The GPU kernel reads the compressed bytes directly and looks each code up in a tiny table held in registers while performing the multiply. The full 16-bit form never exists in VRAM. That is why the 30 percent shows up in actual memory footprint, not just on disk.

The practical implication is large. Serving a 1403GB model requires at least 18 of the 80GB H100 cards. With lossless compression bringing it to 980GB, that drops to around 13. You save five GPUs without losing a single bit of quality. If quantization was a trade of quality for memory, this technique is closer to a free lunch. Of course it is not entirely free, and we cover the cost below.

## Implications for ThakiCloud products

This technique is especially attractive from the perspective of ThakiCloud's ai-platform. The ai-platform is infrastructure that serves models to diverse customer environments on top of Kubernetes and Kueue-based GPU scheduling. Many domestic customers require on-premises and sovereign cloud, and in those environments every single GPU is capital expenditure and procurement lead time. Lossless compression reduces the required GPU count without sacrificing any precision, making it an easier card to pitch than quantization to quality-sensitive regulated customers. In finance or healthcare, where reproducibility of model output becomes subject to audit, bit-for-bit identity can itself be a requirement.

The effect is largest in multi-tenant setups serving large models with vLLM or SGLang. Reclaiming 30 percent of VRAM lets you fit a larger context window on the same hardware, run more concurrent requests, or load a bigger model on one node. The accumulation of exactly this kind of resource efficiency is where ai-platform competes on low serving cost. Lossless compression is an axis orthogonal to quantization, paged attention, and tensor parallelism, so it adds directly on top of existing optimizations.

Low-cost serving in turn feeds agent economics. Paxis, ThakiCloud's Agent-Native Cloud control plane, runs hundreds of skills in isolated sandboxes and passes every action through policy gates and audit logs, and these agent workloads call large open-weight models repeatedly. The lower the serving unit cost, the more aggressively agents can run, so ai-platform's resource efficiency underpins Paxis's operating economics.

## Limitations and counterarguments

This technique is not a cure-all. First, the premise that exponent entropy is low only holds for well-trained models. Weights must cluster near zero for the exponent to bunch, so undertrained models, models with wide distributions, or models already heavily quantized will see a smaller saving. Our measurement also comes from a single model, so the actual numbers will vary with architecture and training method.

Second, decoding compressed codes in real time requires the GPU kernel to handle lookup and multiply together. If that kernel is not well optimized, you can end up saving memory but increasing latency. It may even run faster in workloads bottlenecked on memory bandwidth, but this depends heavily on hardware and kernel implementation, so you must benchmark on the target GPU before deploying.

Third, being lossless, this approach cannot reach the savings of aggressive compression like 4-bit quantization. A 30 percent saving is excellent, but it serves a different purpose than quantization, which gives up a little quality to shrink by 4x. The two are complementary rather than competing, and a realistic answer combines them: lossless compression where precision is absolutely critical, quantization where there is quality headroom.

Finally, this result is based on one researcher's public experiment and our small-scale reproduction. Applying it in production requires independently verifying bit identity of compression and reconstruction, kernel performance, and actual VRAM saving on the target model and serving stack.

## Sources

- brianbell-x, "Lossless Model Compression Experiment": [https://brianbell-x.github.io/weight-compression/](https://brianbell-x.github.io/weight-compression/)
- Measured model: Qwen/Qwen2.5-0.5B (Hugging Face)
- Related work: ZipNN, DFloat11 (BF16 exponent entropy coding family)
