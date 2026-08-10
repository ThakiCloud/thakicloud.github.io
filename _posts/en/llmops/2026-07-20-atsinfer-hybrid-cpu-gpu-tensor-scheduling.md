---
title: "A 122B Model on a 24GB Card? We Dissected ATSInfer, Which Slices llama.cpp at Tensor Granularity"
excerpt: "Instead of offloading whole layers or experts, ATSInfer places individual tensors across CPU and GPU. The paper reports running models far beyond VRAM on a single RTX 4090 while pushing decode up to 3.29x. We read arXiv:2607.10183 and unpacked how it works and what it means for serving."
date: 2026-07-20
tags:
  - ATSInfer
  - llama.cpp
  - CPU-offloading
  - GPU
  - LLM-serving
  - LLMOps
  - quantization
  - infrastructure
author_profile: true
toc: true
toc_label: Anatomy of Tensor-Level Scheduling
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/atsinfer-hybrid-cpu-gpu-tensor-scheduling/"
published: false
---

This post is for engineers weighing whether to self-serve a large model on a single consumer GPU, and for infra owners deciding how much to trust the "run 120B on 24GB" tweets going around. Up front: the core idea of ATSInfer (arXiv:2607.10183), released by researchers at Nanjing University, is simple and persuasive. Where prior offloading moved things in chunks at the granularity of a "layer" or an "expert," ATSInfer slices down to **individual tensors**. That said, the headline "up to 3.29x" rests on a few premises, and the code is not yet public. We did not reproduce an RTX 4090 running a 120B-class model here, so every number in this post is a **value reported by the paper**, stated as such.

## Overview

Anyone who has run a local LLM hits the same wall: if the model weights are larger than GPU memory, the overflow spills to CPU memory. llama.cpp's `-ngl` flag (how many layers to place on the GPU) does exactly this. The problem is that it cuts only at **layer granularity**. A single layer mixes tensors of very different character (attention weights, FFN weights, normalization params), yet they are handled all-or-nothing: either the whole thing goes to the GPU or it stays on the CPU.

Why this chunked placement loses is simple. The same 1GB in VRAM might make one tensor 10x faster and another only 2x faster. VRAM is a scarce resource, and chunked cuts prevent you from picking the tensors with the highest gain per GB. ATSInfer targets exactly this. It profiles each tensor's CPU and GPU performance and fills VRAM starting from the tensors with the **highest speed gain per GB**. If the recent ktransformers was an "expert-level" trick that pushes MoE experts to the CPU (see our [related post: reproducing the ktransformers 28x](/en/llmops/ktransformers-moe-offload-28x-validation/)), ATSInfer is the finer, "tensor-level" generalization. Notably, it applies to dense models, not just MoE.

## What is this technology

ATSInfer is a hybrid CPU-GPU inference system built as an extension to llama.cpp in roughly 15,000 lines of C++. As the name says, "Automated Tensor Scheduling" is the core, and three mechanisms interlock.

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
<div class="d3-arch" data-arch-root id="idcpugputensorscheduling-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 388, "height": 1058, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 114, "y": 24, "w": 149, "h": 78, "title": ["Model weights", "(RAM, exceed VRAM", "capacity)"]}, {"id": "B", "x": 86, "y": 180, "w": 205, "h": 62, "title": ["Per-tensor profiling", "measure speed gain per GB"]}, {"id": "C", "x": 84, "y": 320, "w": 209, "h": 84, "title": ["Static placement", "highest-gain tensors to", "VRAM first"]}, {"id": "D", "x": 214, "y": 496, "w": 142, "h": 46, "title": "Resident in VRAM"}, {"id": "E", "x": 24, "y": 496, "w": 135, "h": 46, "title": "Resident in RAM"}, {"id": "F", "x": 86, "y": 620, "w": 205, "h": 94, "title": ["Load-aware dynamic", "transfer", "promote/demote by runtime", "load"]}, {"id": "G", "x": 89, "y": 792, "w": 198, "h": 94, "title": ["Asynchronous CPU-GPU", "coordination", "overlap compute and PCIe", "transfer"]}, {"id": "H", "x": 117, "y": 964, "w": 142, "h": 62, "title": ["Token output", "prefill · decode"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [188, 102, 188, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [188, 242, 188, 320]}, {"src": "C", "dst": "D", "kind": "data", "label": "\"high-gain tensors\"", "curve": [[234, 404], [285, 450], [285, 450], [285, 496]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "\"low-gain tensors\"", "curve": [[142, 404], [92, 450], [92, 450], [92, 496]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "curve": [[285, 542], [285, 581], [285, 581], [241, 620]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[92, 542], [92, 581], [92, 581], [135, 620]]}, {"src": "F", "dst": "G", "kind": "data", "line": [188, 714, 188, 792]}, {"src": "G", "dst": "H", "kind": "data", "line": [188, 886, 188, 964]}]});
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
      const container = document.getElementById('idcpugputensorscheduling-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'idcpugputensorscheduling-1';
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

**First, static tensor placement.** Before loading the model, it benchmarks how much each tensor speeds up on the GPU, then places tensors on the GPU in order of "most speed returned per GB of VRAM used." This is close to a knapsack optimization and directly exploits the tensor-level heterogeneity that chunked placement ignored.

**Second, load-aware dynamic transfer.** Static placement alone is not enough. During real inference, load shifts moment to moment with batch size, context length, and concurrency. ATSInfer promotes a given tensor from RAM to GPU, or demotes it, based on the runtime situation. If static placement is the starting line, dynamic transfer is changing lanes while driving.

**Third, asynchronous CPU-GPU coordination.** It overlaps CPU compute, GPU compute, and the PCIe transfer that connects them. A naive implementation leaves the GPU idling while it waits on CPU work or data movement; this coordination layer fills that idle time. The paper reports this raises average GPU SM (streaming multiprocessor) utilization by about 70%.

## Results the paper reports

Again: the numbers below are **values reported by the paper**, not something we reproduced. ATSInfer's code is not yet public (even the tweet chatter said "researchers, please share the code with the llama.cpp team"), and a 120B-class model plus an RTX 4090 is hard to reproduce in the sandbox behind this post. So instead of reproduction, we focus on **structural analysis and implications**.

The paper's headline: versus existing hybrid systems (including llama.cpp's layer-level offloading), prefill (throughput to first token) improves by up to 1.94x, and decode (tokens generated per second) by up to 3.29x.

![Max speedup ATSInfer reports in the paper]({{ '/assets/images/atsinfer-hybrid-cpu-gpu-tensor-scheduling-results.png' | relative_url }})

The setup is an RTX 4090 (24GB) and RTX 3060 system with 64GB RAM, and the validated models are:

- Llama 3.1-70B (INT4)
- Qwen3-Next-80B-A3B (INT4)
- Qwen3.5-122B-A10B (INT4)
- GPT-OSS-120B (MXFP4)

So the central claim is running a 122B-parameter model (an MoE with far fewer active parameters) on a single 24GB card. Read two things separately here. First, "3.29x" is a **maximum** under specific conditions, not an average across every model and batch. Second, the gain fundamentally comes not from "fitting what didn't fit into the GPU" but from "making the unavoidable CPU-GPU traffic smarter." The physics that PCIe bandwidth is the bottleneck stays the same, so ATSInfer's contribution is using that bandwidth without waste and reducing GPU idle time.

## Implications for ThakiCloud products

ThakiCloud's **ai-platform** is an AI/ML infrastructure that serves models across diverse customer environments on Kubernetes and Kueue. Tensor-level scheduling like ATSInfer aligns with a trend we watch closely.

First, **the economics of on-premises and sovereign environments.** In settings where data cannot leave the premises, such as domestic public-sector and financial customers, models must run on owned GPUs. If a few consumer GPUs can carry a mid-to-large model instead of a rack of eight H100s, initial CAPEX drops dramatically. What ATSInfer's experiments show is that the premise "if VRAM is short you must simply buy more GPUs" can be substantially relaxed through tensor placement optimization. The cost, of course, is reduced throughput, so it is unsuitable for latency-critical workloads. Judging that trade-off per workload is the job of our serving layer.

Second, **coupling with multi-tenant scheduling.** ATSInfer's "load-aware dynamic transfer" is tensor movement within a single node, but the idea holds at cluster scale too. When Kueue queues and allocates GPU resources, a policy that decides which request to handle at which precision and offloading profile based on load is an area we already think about. Just as tensor-level profiling squeezes resource gains within a node, the cluster scheduler does the same across nodes.

Third, **redefining the cost-quality curve.** In our [ktransformers reproduction post](/en/llmops/ktransformers-moe-offload-28x-validation/) we showed by direct measurement that headline figures like "28x" rest on hidden premises. ATSInfer's "3.29x" deserves the same lens. Not a marketing number, but the value that emerges on our customers' actual models, actual batches, and actual SLAs, is what we verify. Competitiveness at low serving cost ultimately comes from accumulating exactly this kind of verification.

## Limits and counterarguments

The biggest limit is **the code being unreleased.** Whether the paper's numbers reproduce, and whether they hold on other hardware and models, can only be checked once code appears. A 15,000-line C++ extension is also a nontrivial maintenance and upstream-merge task. A fork that never merges falls behind upstream changes over time and loses value.

Second, **the condition-dependence of the gains.** The effect of tensor-level placement depends heavily on CPU performance, RAM bandwidth, and PCIe generation. The paper's experiments assume 64GB RAM; if RAM is short, there is no room to keep tensors on the CPU at all. On PCIe 3.0 systems, transfer likely becomes the bottleneck and shrinks the gain substantially ([estimate], the paper does not spell out a generation-by-generation comparison).

Third, **the inherent ceiling on decode optimization.** Decode is a memory-bound task. However well you schedule, weights outside VRAM must be accessed somehow every token, so it is inevitably slower than pure VRAM residency. What ATSInfer does is "minimize how much slower," not "eliminate the slowdown." Building the opposing case: for production serving that truly needs low latency and high throughput, using a GPU that holds the whole model in VRAM is still the right call. ATSInfer shines in the development, evaluation, and small-batch regime where you cannot afford that GPU, or do not need it.

Even so, the direction has clear value. Squeezing resource utilization through software rather than adding hardware fits a platform like ours particularly well, one that treats on-prem, cost-efficiency, and self-hosting as its weapons. Once the code is public, we plan to fold it into our serving benchmarks and measure the real numbers ourselves.

## Sources

- ATSInfer paper: [arXiv:2607.10183, Automated Tensor Scheduling for Hybrid CPU-GPU LLM Inference on Consumer Devices](https://arxiv.org/abs/2607.10183)
- Related post: [A $400K rack on 24GB? We reproduced the ktransformers 28x](/en/llmops/ktransformers-moe-offload-28x-validation/)
