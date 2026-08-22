---
title: "NVIDIA Qwen3.6-35B-A3B-NVFP4: Running 35B at 3B Speed with FP4 Quantization"
excerpt: "NVIDIA released an NVFP4 (4-bit) quantized version of Alibaba's Qwen3.6-35B-A3B. Cutting weights from 16-bit to 4-bit reduces disk and GPU memory by about 3.06x, while accuracy loss against BF16 stays within 0.1-0.8 points on the model card's published numbers. We break down how the MoE structure (35B total, 3B active) combines with NVFP4 quantization, the vLLM deployment commands, and what it means for ThakiCloud's on-premises serving."
seo_title: "NVIDIA Qwen3.6-35B-A3B-NVFP4 FP4 Quantization vLLM Deployment Analysis - Thaki Cloud"
seo_description: "Analysis of NVIDIA Qwen3.6-35B-A3B-NVFP4 (NVFP4 4-bit quantization): ~3.06x memory savings, accuracy retention vs BF16, vLLM deployment commands, and Blackwell/Hopper hardware requirements from a ThakiCloud K8s multi-tenant serving perspective."
date: 2026-06-25
last_modified_at: 2026-06-25
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/nvidia-qwen36-nvfp4/"
tags:
  - nvfp4
  - quantization
  - vllm
  - qwen3
  - moe
  - inference-optimization
  - model-optimizer
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "microchip"
toc_sticky: true
reading_time: true
categories:
  - llmops
published: false
---

For any team trying to serve large models on their own infrastructure, the biggest wall is GPU memory. Fitting a bigger model on the same GPU, or the same model on a cheaper GPU, translates directly into serving cost. `nvidia/Qwen3.6-35B-A3B-NVFP4`, which NVIDIA published on Hugging Face on May 28, 2026, is an attempt to lower that wall with 4-bit quantization. The accuracy and memory figures in this article are official measurements from NVIDIA's model card; ThakiCloud separately quantized the same base model to NVFP4 on RunPod GPUs and reports that reproduction in the "Real Experimental Results" section below.

## Overview

`nvidia/Qwen3.6-35B-A3B-NVFP4` is Alibaba's `Qwen/Qwen3.6-35B-A3B` quantized with NVIDIA Model Optimizer (ModelOpt). The base model is a Mixture-of-Experts (MoE) architecture with 35B total parameters and only 3B activated, a context length up to 262K, and an Apache-2.0 license that permits both commercial and non-commercial use. NVIDIA explicitly notes on the model card that this is not an NVIDIA-built base model but a quantized version of a third-party model.

The core value reduces to two words. **MoE handles speed, NVFP4 handles memory.** Thanks to the MoE structure, generating a single token engages only the 3B of active experts rather than all 35B, so a 35B model runs with a compute load close to a 3B dense model. Add NVFP4 quantization on top, dropping weights from 16-bit to 4-bit, and disk and GPU memory requirements fall by about 3.06x per the model card. The combination runs "35B-level intelligence at 3B speed, with far less memory."

ThakiCloud operates a K8s-based multi-tenant AI/ML SaaS platform and serves models across diverse customer environments. Being able to take a pre-quantized checkpoint and load it straight into vLLM means lowering serving cost without rerunning a quantization pipeline each time. In fact, ThakiCloud already runs an in-house pipeline that quantizes the same Qwen3-MoE family to NVFP4, and we share that experience later in this article.

## What Is This Technology

NVFP4 is a 4-bit floating-point format defined by NVIDIA. It does not simply crush every value down to 4 bits; it applies quantization specifically to the **weights and activations** of the linear operators inside MoE transformer blocks. To quote the model card directly: "This model was obtained by quantizing the weights of Qwen3.6-35B-A3B to NVFP4 data type. Only the weights and activations of the linear operators within transformer blocks in MoE are quantized. This optimization reduces the number of bits per parameter from 16 to 4, reducing the disk size and GPU memory requirements by approximately 3.06x."

The key is to recognize that MoE and quantization operate on different axes. The diagram below shows both.

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
<div class="d3-arch" data-arch-root id="0260625nvidiaqwen36nvfp4-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 519, "height": 984, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 214, "y": 24, "w": 273, "h": 294, "label": "Quantization axis (memory)", "lx": 226, "ly": 42}, {"x": 24, "y": 410, "w": 211, "h": 542, "label": "Serving axis (speed)", "lx": 36, "ly": 428}], "nodes": [{"id": "A", "x": 283, "y": 63, "w": 135, "h": 62, "title": ["Qwen3.6-35B-A3B", "BF16 weights"]}, {"id": "B", "x": 252, "y": 217, "w": 198, "h": 62, "title": ["NVFP4 checkpoint", "16→4 bit, ~3.06x savings"]}, {"id": "C", "x": 64, "y": 457, "w": 120, "h": 46, "title": "Input token"}, {"id": "D", "x": 74, "y": 589, "w": 120, "h": 46, "title": "Router"}, {"id": "E", "x": 70, "y": 727, "w": 128, "h": 62, "title": ["Active experts", "(3B compute)"]}, {"id": "F", "x": 74, "y": 867, "w": 120, "h": 46, "title": "Output token"}, {"id": "G", "x": 273, "y": 449, "w": 156, "h": 62, "title": ["Blackwell / Hopper", "Tensor Core"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "\"ModelOpt PTQ<br/>NVFP4 calibration\"", "line": [351, 125, 351, 217], "lx": 351, "ly": 167}, {"src": "C", "dst": "D", "kind": "data", "line": [124, 503, 130, 589]}, {"src": "D", "dst": "E", "kind": "data", "label": "\"3B of 35B selected\"", "line": [134, 635, 134, 727], "lx": 134, "ly": 677}, {"src": "E", "dst": "F", "kind": "data", "line": [134, 789, 134, 867]}, {"src": "B", "dst": "G", "kind": "data", "label": "\"vLLM --quantization modelopt\"", "line": [351, 279, 351, 449], "lx": 351, "ly": 360}, {"src": "G", "dst": "D", "kind": "data", "curve": [[273, 511], [174, 550], [174, 550], [149, 589]]}]});
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
      const container = document.getElementById('0260625nvidiaqwen36nvfp4-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0260625nvidiaqwen36nvfp4-1';
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

On the quantization axis, BF16 weights are converted into an NVFP4 checkpoint via ModelOpt's post-training quantization (PTQ). On the serving axis, for each input token the router selects only a subset of the 35B experts and performs roughly 3B of compute. The two axes meet at the Tensor Core operation on top of vLLM, and that is exactly where NVFP4's hardware dependency surfaces. NVFP4 operations are accelerated only on NVIDIA Hopper and Blackwell microarchitectures. The model card lists NVIDIA GB300 as the test hardware.

The trick to minimizing accuracy loss is quantizing "selectively, not everything." Sensitive paths including attention are left untouched, and the effort concentrates on the MoE linear weights that consume the most memory, so memory savings stay large while quality degradation stays small.

## Installation and Integration

The basic vLLM serving command NVIDIA provides on the model card is below. You launch the `vllm/vllm-openai:nightly` docker image and run it.

```sh
vllm serve nvidia/Qwen3.6-35B-A3B-NVFP4 \
  --port 8000 \
  --quantization modelopt \
  --max-model-len 262144 \
  --reasoning-parser qwen3
```

The `--quantization modelopt` flag is what makes the runtime recognize the NVFP4 checkpoint. If GPU memory is tight, reducing `--max-model-len` first and then raising it gradually is the safe approach, because keeping the full 262K context requires considerable KV cache memory.

For memory-constrained environments such as the NVIDIA DGX Spark, the model card provides a separate recommended command.

```sh
vllm serve nvidia/Qwen3.6-35B-A3B-NVFP4 \
  --host 0.0.0.0 \
  --port 8000 \
  --tensor-parallel-size 1 \
  --trust-remote-code \
  --kv-cache-dtype fp8 \
  --attention-backend flashinfer \
  --moe-backend marlin \
  --gpu-memory-utilization 0.4 \
  --max-model-len 262144 \
  --max-num-seqs 4 \
  --max-num-batched-tokens 8192 \
  --enable-chunked-prefill \
  --async-scheduling \
  --enable-prefix-caching \
  --speculative-config '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}' \
  --load-format fastsafetensors \
  --reasoning-parser qwen3 \
  --tool-call-parser qwen3_xml \
  --enable-auto-tool-choice
```

This command packs in several operationally useful options. `--kv-cache-dtype fp8` shrinks even the KV cache to 8-bit, `--gpu-memory-utilization 0.4` keeps memory footprint low, and `--speculative-config` enables MTP (Multi-Token Prediction) based speculative decoding. `--tool-call-parser qwen3_xml` and `--enable-auto-tool-choice` make tool calling immediately usable in agent and RAG scenarios. NVIDIA's stated use case is precisely "developers looking to take off-the-shelf, pre-quantized models for deployment in AI agent systems, chatbots, and RAG systems," and this option set directly reflects that purpose.

## Real Experimental Results

### ThakiCloud reproduction: running the NVFP4 quantization pass on RunPod H100

Rather than just restating the model-card figures, ThakiCloud quantized the same base model `Qwen/Qwen3.6-35B-A3B` to NVFP4 directly, on **two NVIDIA H100 NVL GPUs (Hopper, 191GB combined)** on RunPod, using NVIDIA Model Optimizer. Because the calibration math runs in BF16, the quantization pass itself reproduces on Hopper as well. The measured facts:

| Item | Measured value |
|---|---|
| Quantization tool | `nvidia-modelopt[hf]` 0.44.0 (current latest) |
| Base model load | 34.66B parameters, auto-sharded across 2×H100 via device_map |
| Calibration config | `NVFP4_DEFAULT_CFG`, smoke 8 samples |
| New-architecture auto-registration | `Qwen3_5MoeExperts` → `_QuantFusedExperts` (fused MoE), `Qwen3_5MoeAttention` → `_QuantAttention` (KV cache) |
| Quantizers inserted | **21,743** |
| PTQ wall-clock | **148s** |

The key point is that **modelopt 0.44 automatically recognized a brand-new architecture released in late May 2026 (Qwen3.6, internal name `qwen3_5_moe`, Gated DeltaNet family) and completed the quantization pass cleanly**. The fused MoE expert blocks and attention KV cache were auto-registered as quantization targets, and 21,743 quantizers were inserted.

One thing in fairness, though: the quantization pass succeeded, but the step that writes the packed 4-bit checkpoint to disk, `export_hf_checkpoint`, currently hit a **compatibility gap between modelopt 0.44 and transformers 5.x** (`transformers>=5.0 support is experimental`). `qwen3_5_moe` requires transformers 5.x, and in that combination the unified HF export does not work yet, so it fell back to BF16. This is the kind of toolchain lag commonly seen for an architecture less than a month old. We therefore cite NVIDIA's published checkpoint for the packed-checkpoint size (~3.06× reduction, ~18.7B) and the accuracy figures.

The accuracy table below is **NVIDIA's official evaluation published on the model card**. NVIDIA compared the NVFP4 quantized version against the base model `Qwen3.6-35B-A3B` (BF16) on text reasoning and coding benchmarks.

| Benchmark | BF16 (baseline) | NVFP4 | Δ |
|---|---|---|---|
| MMLU Pro | 85.6 | 85.0 | -0.6 |
| GPQA Diamond | 84.9 | 84.8 | -0.1 |
| τ²-Bench Telecom | 95.5 | 94.7 | -0.8 |
| SciCode | 40.8 | 40.6 | -0.2 |
| AIME 2025 | 89.2 | 88.8 | -0.4 |
| AA-LCR | 62.0 | 62.0 | 0.0 |
| IFBench | 62.3 | 62.8 | +0.5 |
| MMMU PRO | 74.1 | 74.5 | +0.4 |

![Bar chart comparing NVFP4 accuracy against BF16]({{ '/assets/images/nvidia-qwen36-nvfp4-results.webp' | relative_url }})

A visualization of the model card's published numbers (axis labels in Korean). Even after 4-bit quantization, most accuracy differences stay below one point.

The key to reading the table is the magnitude of the loss. The largest drop across the 8 benchmarks is -0.8 on τ²-Bench Telecom; GPQA Diamond is -0.1, and AA-LCR is a tie. IFBench and MMMU PRO actually have NVFP4 slightly ahead of BF16. The tiny distribution shift from quantization happened to help on a few tasks, but this should not be generalized into "quantization improves performance." Overall, the message of the table is that cutting 16-bit down to a quarter at 4-bit preserved reasoning, math, coding, and agentic tool-use capability almost entirely. The evaluation conditions were SciCode at temperature=0.6, top_p=0.95, max 131072 tokens, and the rest at temperature=1.0, top_p=0.95, max 131072 tokens.

On the memory side, the model card states roughly 3.06x savings. Per the Hugging Face repository, the packed parameter scale of the NVFP4 checkpoint is reported at about 18.7B, a substantially reduced form of the 35B model versus the original BF16. The exact file size must be checked directly in the repository sidebar, and the model card warns not to confuse the sidebar's file statistics with the base model's architecture parameters.

## Application and Implications for the ThakiCloud K8s AI/ML SaaS Platform

From ThakiCloud's platform perspective, the appeal of this model is clear. In a multi-tenant environment, the GPU is the most expensive shared resource, and the more tenant models we can load onto the same GPU simultaneously, the lower the per-inference cost. NVFP4 reducing memory by about 3.06x means, in simplified terms, room to fit a larger model or more concurrent sessions in the same GPU memory. Layer in the MoE characteristic of running a 35B MoE at roughly 3B compute, and the on-premises value proposition of "high-quality models at low serving cost" becomes much more concrete.

ThakiCloud already reflects this in operations. We maintain an in-house pipeline that quantizes `Qwen/Qwen3-30B-A3B`, of the same Qwen3-MoE family, to NVFP4 (W4A4, group_size=16) on RunPod B200 (Blackwell SM100). In a validation run on May 1, 2026, it **produced a 17.1GB checkpoint with 137 seconds of PTQ compute.** Total wall-clock was about 25 minutes, and cost was around $3.48 on B200 on-demand. And while preparing this article we applied the same pipeline to the new `Qwen3.6-35B-A3B`, reproducing the NVFP4 quantization pass on two RunPod H100 NVL GPUs (modelopt 0.44, 21,743 quantizers inserted, the new fused-MoE auto-registered, 148s). Two things follow from this experience. First, NVFP4 quantization itself is a one-time job that finishes in a short time at low cost. Second, when a pre-quantized checkpoint is published as NVIDIA did here, you can skip even that one-time job and go straight to serving. In other words, NVIDIA's public checkpoint is a superset input to our pipeline.

On the K8s operations side, it aligns as follows. GPU workloads are queued and scheduled with Kueue, serving is brought up as vLLM pods with the `--quantization modelopt` flag recognizing the NVFP4 checkpoint, and multi-tenant isolation is handled with namespaces and GPU partitioning, adjusting per-tenant allocation by the memory saved. One hardware premise comes attached, though. NVFP4 acceleration works only on Blackwell and Hopper, so existing A100-based node pools cannot enjoy this model's 4-bit benefit as-is. This is an operational decision tied directly to node-pool composition, which we flag as a limitation in the next section.

## Limitations and Counterarguments

First, **the hardware dependency is strong.** NVFP4 Tensor Cores exist only on Blackwell and Hopper. On prior-generation GPUs like the A100 or V100, NVFP4 is not accelerated, so you cannot expect the same memory savings and must take a different path such as INT8 or FP8. If an on-premises customer's existing GPU assets are prior-generation, reaping this model's benefit incurs the added cost of node replacement.

Second, **memory savings and throughput gains are different matters.** The model card states roughly 3.06x disk and memory savings, but it does not directly present throughput figures such as tokens/sec or latency. While 4-bit weights generally help decoding by easing memory-bandwidth pressure, actual throughput depends on batch size, context length, and KV cache settings. Asserting "it's N times faster" without ThakiCloud's own serving benchmark would be inaccurate. Native FP4 acceleration runs only on Blackwell, and at the time of this reproduction we could not secure B200 stock on RunPod, so we validated the quantization pass on Hopper (two H100 NVL GPUs) and left native FP4 serving throughput as a separate benchmark task once Blackwell is available.

Third, **quantization inherits the base model's limitations as-is.** As the model card states directly, the base model was trained on data crawled from the internet that contains toxic language and societal biases, and it may generate inaccurate answers, omit key information, or produce irrelevant text. Quantization only optimizes memory and speed; it does not solve these safety and accuracy issues. Multi-tenant serving still requires separate output filtering and monitoring.

Fourth, **accuracy loss does not converge to zero.** Although most benchmarks show loss under one point, scenarios where agentic tool use and policy adherence are central, like τ²-Bench Telecom's -0.8, show a relatively larger loss. In domains like finance and healthcare where small accuracy differences translate directly into cost, you need a policy that weighs the economics of 4-bit savings against accuracy loss per tenant and chooses among BF16, FP8, and NVFP4.

In sum, `nvidia/Qwen3.6-35B-A3B-NVFP4` is a highly practical option for teams with Blackwell/Hopper-based infrastructure to "cut memory to a quarter with almost no loss." That benefit holds only on top of the hardware premise and domain-specific accuracy validation, and ThakiCloud plans to confirm throughput and per-tenant suitability with its own serving benchmark before reflecting it in node-pool policy.

## Sources

- Model card: [nvidia/Qwen3.6-35B-A3B-NVFP4 · Hugging Face](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4)
- Base model: [Qwen/Qwen3.6-35B-A3B · Hugging Face](https://huggingface.co/Qwen/Qwen3.6-35B-A3B)
- Quantization tool: [NVIDIA Model Optimizer (GitHub)](https://github.com/NVIDIA/Model-Optimizer)
- Inference engine: [vLLM (GitHub)](https://github.com/vllm-project/vllm)
