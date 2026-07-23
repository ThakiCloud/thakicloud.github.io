---
title: "Fitting a 27B Model on a Phone: Dissecting Bonsai 27B's 1-bit and Ternary Quantization"
excerpt: "Bonsai 27B, released by PrismML, is not a newly trained model but the result of compressing Qwen3.6-27B's weights to 1-bit and ternary while leaving the architecture untouched. The ternary build reportedly keeps 94.6% of FP16 quality at 5.9GB, and the 1-bit build keeps 89.5% at 3.9GB. We look at how this compression actually works, why memory rather than storage capacity is the real constraint, and what low-bit serving means for ThakiCloud's multi-tenant inference infrastructure."
tags:
  - quantization
  - bonsai-27b
  - ternary
  - 1-bit
  - llama-cpp
  - mlx
  - inference
  - serving
  - kv-cache
  - on-device
  - self-hosting
  - llmops
  - paxis
date: 2026-07-16
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/bonsai-27b-ternary-1bit-quantization/"
categories:
  - llmops
---

## Overview

Attempts to run large models on small devices mostly go one of two ways. One is to train a small model from scratch, and the other is to compress a large model's weights after the fact. The latter has always hit the same wall. Below 4-bit, short benchmarks look fine, but quality collapses on longer reasoning tasks like math or coding.

On July 14, 2026, PrismML released Bonsai 27B, which addresses this wall head-on. Bonsai 27B is not a newly trained model. It leaves Qwen3.6-27B as is and represents only the weights in low-bit form. The architecture is unchanged. Two variants were released under Apache 2.0, and the ternary build reportedly keeps 94.6% of the original quality at 5.9GB, while the 1-bit build keeps 89.5% at 3.9GB.

This post reads Bonsai 27B from ThakiCloud's perspective of serving low-bit models in a multi-tenant setting. We go in order through how the compression works, why memory rather than storage capacity is the real constraint, and what practical implications this trend carries for our inference infrastructure. Up front: all benchmark figures below are numbers PrismML has published, not values ThakiCloud has reproduced independently.

## What Bonsai 27B Is

Bonsai 27B is a low-bit representation of Qwen3.6-27B. Applied to a multimodal model composed of about 24.8B language weights, 0.46B in the vision tower, and 2.5B in embeddings and the LM head, it converts the entire set of matrix-heavy components to low-bit. This includes embeddings, attention projections, MLP projections, and the LM head, while only a tiny tail of parameters such as normalization and scale stay at high precision. The vision tower is kept separately at 4-bit HQQ and is only loaded when there is image input.

The two variants differ in character. Ternary Bonsai 27B represents weights with three values, `{-1, 0, +1}`, giving an effective 1.71 bit and an ideal size of 5.9GB. 1-bit Bonsai 27B uses only two values, `{-1, +1}`, giving an effective 1.125 bit at 3.9GB. Context is supported up to 262K tokens, and this stays practical because about 75% of Qwen3.6-27B's attention is linear.

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
<div class="d3-arch" data-arch-root id="bternary1bitquantization-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 366, "height": 1134, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 115, "y": 24, "w": 120, "h": 62, "title": ["Qwen3.6-27B", "FP16 54GB"]}, {"id": "B", "x": 80, "y": 164, "w": 191, "h": 62, "title": ["Group-wise split", "1 group per 128 weights"]}, {"id": "C", "x": 95, "y": 304, "w": 160, "h": 52, "title": "Low-bit codebook"}, {"id": "D", "x": 199, "y": 448, "w": 135, "h": 62, "title": ["-1, 0, +1", "about 1.585 bit"]}, {"id": "E", "x": 24, "y": 448, "w": 120, "h": 62, "title": ["-1, +1", "1.0 bit"]}, {"id": "F", "x": 76, "y": 588, "w": 198, "h": 62, "title": ["One FP16 scale per group", "+16/128 bit"]}, {"id": "G", "x": 83, "y": 728, "w": 184, "h": 62, "title": ["Ternary 1.71 bpw 5.9GB", "Binary 1.125 bpw 3.9GB"]}, {"id": "H", "x": 104, "y": 868, "w": 142, "h": 78, "title": ["Vision tower", "4-bit HQQ stored", "separately"]}, {"id": "I", "x": 83, "y": 1024, "w": 184, "h": 78, "title": ["llama.cpp / MLX", "on-device inference on", "laptops and phones"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [175, 86, 175, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [175, 226, 175, 304]}, {"src": "C", "dst": "D", "kind": "data", "label": "Ternary", "curve": [[208, 356], [267, 402], [267, 402], [267, 448]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "Binary", "curve": [[142, 356], [84, 402], [84, 402], [84, 448]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "curve": [[267, 510], [267, 549], [267, 549], [216, 588]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 510], [84, 549], [84, 549], [135, 588]]}, {"src": "F", "dst": "G", "kind": "data", "line": [175, 650, 175, 728]}, {"src": "G", "dst": "H", "kind": "data", "line": [175, 790, 175, 868]}, {"src": "H", "dst": "I", "kind": "data", "line": [175, 946, 175, 1024]}]});
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
      const container = document.getElementById('bternary1bitquantization-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'bternary1bitquantization-1';
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

## How the Compression Works

The core idea is simple. Each weight is stored as a single code, and every group of 128 weights shares one FP16 scale. The actual weight is reconstructed as the product of the group scale and the code, in the form `w_i = s_g · t_i`.

Tracing the bit accounting makes the storage cost clear. One ternary value carries `log2(3) ≈ 1.585` bits. Adding one FP16 scale per 128 values adds `16/128` bits, bringing the total to about 1.71 bits, roughly a 9.4x reduction versus FP16. Binary is 1 bit per value itself, and with the same scale overhead it comes to `1 + 16/128 = 1.125` bits, roughly a 14.2x reduction.

An interesting contrast appears here. The commonly named "4-bit" Qwen3.6-27B Q4_K_XL build actually averages 5.2 bits, and the "2-bit" IQ2_XXS actually averages 2.8 bits. The name and the real average bit count differ. Bonsai is also different from BitNet. BitNet trains from scratch at low bit to avoid collapse, but Bonsai compresses an already-trained model after the fact. PrismML claims it avoided collapse without retraining, but the details of this claim rely on the published technical documentation.

## Reported Benchmark Results

PrismML stated it evaluated 15 benchmarks in thinking mode on H100 using EvalScope and vLLM. The table below shows those reported figures. To emphasize again, these numbers are values the provider has published, not values ThakiCloud has reproduced, and independent reproduction requires separate verification.

| Build | Effective bpw | Size | Thinking Average | vs. FP16 |
|---|---|---|---|---|
| Qwen3.6-27B FP16 | 16.0 | 54GB | 85.07 | baseline |
| Q4_K_XL (4-bit) | 5.2 | 17.6GB | 84.99 | 99.9% |
| IQ2_XXS (2-bit) | 2.8 | 9.4GB | 72.73 | 85.5% |
| Ternary Bonsai 27B | 1.71 | 5.9GB | 80.49 | 94.6% |
| 1-bit Bonsai 27B | 1.125 | 3.9GB | 76.11 | 89.5% |

Breaking it down by category shows the compression does not create uniform loss. Math holds up relatively well, from 95.33 at FP16 to 93.40 for ternary and 91.66 for 1-bit. Agent tasks and tool calling, in contrast, drop sharply from 80.00 to 74.01 for ternary and 66.03 for 1-bit, and vision falls from 72.61 to as low as 59.57 for 1-bit. Instruction following also loses significantly, from 78.47 to 65.74 for 1-bit.

The contrast PrismML emphasizes is the selective collapse of existing sub-4-bit builds. IQ2_XXS keeps 88.93 on short-answer tasks like MMLU-Redux but collapses to 57.5 on AIME26 and 56.4 on LiveCodeBench. The point is that short benchmarks mask this collapse. This observation itself is a practical insight that anyone who has worked with low-bit quantization would recognize.

## Memory Is the Binding Constraint

Reading the Bonsai 27B release purely by its size numbers misses the point. The conditions for fitting a model on a phone are much stricter than storage capacity alone. iOS limits a single app to roughly half of physical memory, so a 12GB iPhone actually exposes only about 6GB. This is why the 3.9GB build matters.

The second budget is the KV cache. Because only 16 of 64 layers have a growing full-attention cache, it costs about 64KiB per token at FP16. Filling the full 262K window costs about 17.2GB, and using a 4-bit KV cache brings this down to about 4.3GB. No matter how much the model weights are reduced, a longer context will consume memory through the KV cache, so low-bit weights and a low-bit KV cache need to go together.

PrismML also says it measured the quality impact of cache compression. Against its own FP16-KV baseline, Ternary Bonsai showed an output forward-KL of 0.0011 nats on MATH-500, while Q4_K_XL showed 0.0146. At 100K tokens, using an FP16 cache, 1-bit peaks at about 11.6GB and ternary at about 14.7GB. In other words, even after shrinking the weights, long contexts require lowering cache precision as well for the model to actually fit on a device.

## Throughput and Speculative Decoding

Generation is bound by memory bandwidth. The fewer bytes read per step, the more tokens per second. Prefill, on the other hand, is compute-bound, so the compression effect is relatively smaller there. The throughput PrismML released shows exactly this property.

| Platform | Build | tg128 (generation) | pp512 (prefill) |
|---|---|---|---|
| M5 Max | Binary | 66.4 | 874 |
| M5 Pro | Ternary | 26.2 | 393 |
| iPhone 17 Pro Max | Binary | 11.0 | 111 |
| H100 (CUDA) | Binary | 104.8 | 2755 |

PrismML also shipped a DSpark drafter trained specifically for the Bonsai 27B target. On H100 with a draft depth of k=4, it reports an accepted length of tau=3.6 for the binary target, that is 143.8 tok/s, a 1.37x speedup. Verification is lossless, so the output distribution stays identical. However, on Apple silicon the drafter is disabled by default at batch size 1.

Execution itself is standard. You can run a llama.cpp server or generate directly with llama-cli, and an MLX path is also provided. Tool calling uses the OpenAI-style `tools` array as is, and the response comes back as `choices[0].message.tool_calls`. Thinking mode is enabled by default and can be toggled per request.

## What This Means for ThakiCloud

Low-bit serving touches both of ThakiCloud's products.

**ai-platform lens (infrastructure and serving).** ThakiCloud's ai-platform serves open-weight models across a variety of customer environments. What Bonsai shows is the possibility of putting 27B-class quality on a single 24GB GPU along with a 4-bit KV cache. This directly affects multi-tenant density. If more tenants can run on the same GPU, or the same SLA can be met with a smaller card, serving cost goes down. This matters especially for on-premises and sovereign deployments. Domestic public sector and regulated industries require self-hosting that keeps data from leaving the premises, but hardware budgets are limited. Lowering both model weights and the KV cache to low-bit together enables denser packing in a GPU pool scheduled with Kueue, which feeds directly into the cost efficiency and resource density we have emphasized. That said, low-bit is not always the answer. If a workload is agent- or tool-calling-centric, quality loss is significant as shown in the limitations section below, which calls for routing that varies precision by workload.

**Paxis lens (agents and edge).** Paxis is the Agent-Native Cloud control plane that runs on top of ai-platform, treating Skills, Tools, Policies, and Audit Logs as first-class resources. A model that runs on a phone at 3.9GB opens the door to on-device agents where privacy is sensitive. A setup where the prompt never leaves the device is useful for regulatory compliance and offline workflows. From Paxis's point of view, it is a natural fit to run such local models inside sandboxed, isolated execution while passing every action through policy gates and audit logs. Low-bit on-device inference creates the economics for edge agents, and Paxis is the layer that governs that execution.

The two lenses complement each other. Low-cost serving (ai-platform) creates the economics for agents (Paxis).

## Limitations and Counterpoints

The biggest caveat is the source of the benchmarks. All the figures above are PrismML's own evaluations, and there is no independent reproduction yet. The argument pointing out IQ2_XXS's selective collapse is persuasive, but the benchmarks that show Bonsai's advantage are also self-measured by the same provider. A fair judgment needs third-party reproduction.

The unevenness of the quality loss also matters in practice. The 1-bit build's agent and tool-calling score is only 66.03. Tool-calling accuracy at this level is risky for production agent pipelines. Vision at 59.57 and instruction following at 65.74 are similarly large drops, which means 1-bit is effectively limited to simple text reasoning and privacy-first on-device use. Paths that need quality should move up to ternary or higher precision.

Phone performance numbers also need careful reading. The iPhone tok/s figures are enough for short interactions but slow for long generations. Heat, battery, and sustained throughput are not visible in the benchmark table. The white paper reportedly measured 672 tokens per 1% of iPhone battery, but real-world latency and sustained performance are separate concerns.

Finally, the core claim of avoiding collapse without retraining relies on method details in the published documentation. The license is Apache 2.0, but the license inheritance relationship with the Qwen3.6 base needs verification before commercial deployment. In summary, Bonsai 27B is a genuine practical advance in low-bit quantization, but adoption decisions should be made together with workload-specific quality requirements and independent reproduction.

## ThakiCloud Independent Reproduction

In the limitations above we noted that no independent reproduction existed yet. We ran one. The intended reader is an infrastructure engineer weighing a self-hosted low-bit pipeline. The short version is that PrismML's released 1-bit model genuinely works, but the compression method itself cannot be reproduced, because it was never disclosed.

We first extracted and read all three whitepapers in full. What is public is the storage format, the inference kernels, and the benchmarks. The algorithm for assigning 1-bit weights without retraining while avoiding collapse appears nowhere. The 8B whitepaper explicitly calls it "proprietary Caltech intellectual property." The method is sealed.

We then loaded their released `Bonsai-1.7B-unpacked` (their 1-bit weights materialized back to FP16) with stock tooling. Every 128-weight group used exactly one scale, and perplexity on a fixed passage was 3.492, essentially identical to the same base Qwen3-1.7B at FP16 (3.507). The released model is real and near lossless.

By contrast, reproducing naively from the public format alone (textbook BWN binarization) collapses completely at the same 1.125 bits. A 4-bit control confirms the harness is sound.

| Variant | bpw | Perplexity | vs FP16 |
|---|---|---|---|
| Qwen3-1.7B FP16 | 16 | 3.507 | 1.00x |
| PrismML 1-bit (their method) | 1.125 | 3.492 | 0.995x, lossless |
| Naive binary (public format) | 1.125 | 2,109,839 | 601,600x, collapse |
| 4-bit control | 4.125 | 4.209 | 1.14x, intact |

A sealed method can still be predicted. Because we hold their actual 1-bit weights, we paired them with the base weights and reverse-engineered a fingerprint. Their signs agreed with the base only 71.6% of the time, meaning about 28% of signs were flipped, whereas naive binarization preserves every sign. Their group scales were also 2.26x larger than the naive mean. That is the fingerprint of error compensation that minimizes layer output error rather than per-weight error, the GPTQ family. Since sign agreement is far above the 50% of chance, the base is unmodified Qwen, consistent with their "no retraining" claim.

We implemented that prediction to test it. A hand-written error-compensated binary quantizer (GPTQ family) recovered about 10x of the naive collapse. The direction was right. Yet even after recovery a large gap to FP16 remained, and simply enlarging the scale by 2.26x made things worse, which tells us the larger scale only helps when coupled with sign optimization. Textbook error compensation is necessary but not sufficient. Reaching their lossless 1-bit needs salient-weight handling or residual schemes beyond it, and that is exactly the part they withheld.

One caveat: this perplexity is a coarse signal on a short passage, measured on small models. Full category retention (tool use, vision) would require building their custom kernels, serving the 27B, and running the whole benchmark suite, which we leave as separate work. Still, to "does 1-bit actually work" the answer is yes, and to "can public materials reproduce that quality" the answer is no. That gap is the value of the technology.

We also pushed the latest public methods as far as they go. In recent extreme low-bit research (QuIP, BiLLM, QuaRot, SpinQuant) the biggest lever is incoherence rotation: a random orthogonal rotation spreads outlier weights into a near-Gaussian distribution that binarizes cleanly, and when paired with error compensation it revives pure 1-bit dramatically. Rotation alone actually hurts and must be combined with GPTQ, which we confirmed. Measured on the exact base they used, Qwen3-1.7B, same harness:

| Method | eff bpw | Perplexity | vs FP16 | escape |
|---|---|---|---|---|
| FP16 | 16 | 2.027 | 1.00x | none |
| PrismML Bonsai (their method) | 1.125 | 1.971 | 0.97x | none |
| ours QuIP (rotation + error-comp) | 1.125 | 4.213 | 2.1x | none |
| ours QuIP + salient 3% | 1.571 | 2.24 | 1.1x | 3% |

The public stack (QuIP + salient) reaches 2.24, nearly matching their 1.971 in quality. But a decisive gap remains: they hit that quality at pure 1.125 bpw with no escape hatch, whereas we needed 1.57 bpw and 3% high-precision, and at the same pure-1-bit point we land at 4.21 versus their 1.97. Quality nearly converges, yet they hold a better efficiency Pareto point. One striking observation is that rotation helps far more as the model grows: the gain was small at 0.6B and large at 1.7B, which partly explains how they reach lossless at 27B. These numbers are a coarse short-passage signal, so firm claims need full benchmark evaluation. The full reproduction code is open-sourced.

One point to state plainly. This entire study runs under the post-training quantization constraint, to follow their "no retraining" claim on equal terms. If you are willing to train, near-lossless low-bit is already an established path. BitNet and BitNet b1.58 train binary and ternary weights from scratch and match FP16 quality at scale, and quantization-aware training and distillation reach the same end by other means. So the answer to "can a lossless 1-bit model exist" is an obvious yes if you train for it. The hard and valuable problem is reaching that quality after the fact, on an already-trained model, without retraining, which is exactly what PrismML did. Turned around, for an organization that controls its own training, native low-bit training in the BitNet style sidesteps this post-hoc gap entirely, trading GPU cost for quality.

## Sources

- [prism-ml/Bonsai-27B-gguf (Hugging Face)](https://huggingface.co/prism-ml/Bonsai-27B-gguf)
- [PrismML Releases Bonsai 27B (MarkTechPost)](https://www.marktechpost.com/2026/07/14/prismml-releases-bonsai-27b-1-bit-and-ternary-builds-of-qwen3-6-27b-that-run-on-laptops-and-phones/)
- [PrismML Bonsai 27B docs](https://docs.prismml.com/models/bonsai-27b)
