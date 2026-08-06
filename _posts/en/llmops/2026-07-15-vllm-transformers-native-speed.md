---
title: "Implement Once, Serve at vLLM Native Speed: the Transformers Backend Ends the Double-Build"
excerpt: "Until now, every new model architecture had to be built twice: once in Transformers for training and research, and again in vLLM for production inference. vLLM v0.25.0's native-speed Transformers backend ends that duplication. It works by using torch.fx to statically analyze the model graph, finding known patterns like attention, normalization, and MLP, then rewiring them onto vLLM's optimized kernels. We reproduced the graph-analysis step the backend actually runs on a 4-layer decoder and measured which of its 178 nodes become fusion targets. Then we look at what this means for ThakiCloud's multi-tenant open-weight serving infrastructure."
tags:
  - vllm
  - transformers
  - inference
  - serving
  - torch-fx
  - llmops
  - self-hosting
  - open-weights
  - paxis
date: 2026-07-15
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/vllm-transformers-native-speed/"
categories:
  - llmops
published: false
---

## Overview

If you have ever self-hosted open-weight models, you know one familiar wall. A great model ships, but to actually serve it fast you have to wait until your serving engine supports that architecture. A new structure landing in the Transformers library is immediately usable for training and research, yet to reach full speed in a high-performance inference engine like vLLM, someone had to reimplement that architecture from scratch inside vLLM. You effectively built the same model twice.

This post is for engineering leaders who own inference cost and serving latency, for practitioners running open-weight models on-premises or in sovereign environments, and for data scientists who experiment with new architectures while worrying about deployment speed. In July 2026, Hugging Face's Clement Delangue shared a big turning point for open-source inference: starting with vLLM v0.25.0, Transformers models can run inside vLLM at **native speed**, often matching or beating hand-written implementations.

The core idea is this. Once a model author implements an architecture in Transformers, they can enjoy vLLM's optimized inference stack for free, with no separate porting work. We did not take this claim on faith. We reproduced the graph-analysis step the backend runs internally on a small decoder block and measured it. This post walks through the mechanism, our measurements, and what it means for infrastructure that serves many different models under one multi-tenant roof.

## What This Technology Is

With a single `--model-impl transformers` flag, vLLM loads the model definition straight from the Transformers library instead of a dedicated ported implementation, and serves it. On the surface this looks like a compatibility layer, but what makes the v0.25.0 backend special is that this compatibility no longer costs speed. The old compatibility path was closer to a "works but slow" fallback. Now inference-specific layer fusions are applied dynamically at runtime, so for compatible architectures the backend matches the speed of dedicated code.

Look a little closer and the mechanism splits into two stages. First the backend uses `torch.fx` to statically analyze the model's compute graph, searching for optimizable patterns like attention-score computation, RMSNorm, SwiGLU MLPs, and Mixture-of-Experts. Then it manipulates the abstract syntax tree to rewrite that source in place and maps the discovered operations onto vLLM's optimized kernels. For an MoE model that means the Expert Parallelization kernels; for attention, the paged-attention family. In the end, vLLM optimizes throughput and latency on top of the architecture that Transformers expressed.

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
<div class="d3-arch" data-arch-root id="mtransformersnativespeed-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 458, "height": 1134, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 138, "y": 24, "w": 184, "h": 46, "title": "New model architecture"}, {"id": "B", "x": 128, "y": 148, "w": 205, "h": 78, "title": ["Implemented once in", "Transformers", "for training and research"]}, {"id": "C", "x": 136, "y": 304, "w": 188, "h": 52, "title": "How to serve in vLLM"}, {"id": "D", "x": 263, "y": 884, "w": 163, "h": 78, "title": ["Reimplement in vLLM", "hand-port dedicated", "kernels"]}, {"id": "E", "x": 28, "y": 448, "w": 177, "h": 62, "title": ["torch.fx static graph", "analysis"]}, {"id": "F", "x": 28, "y": 588, "w": 177, "h": 78, "title": ["Detect known patterns", "attention, RMSNorm,", "SwiGLU, MoE"]}, {"id": "G", "x": 24, "y": 744, "w": 184, "h": 62, "title": ["Rewrite source via ast", "runtime layer fusion"]}, {"id": "H", "x": 24, "y": 884, "w": 184, "h": 78, "title": ["Map to vLLM optimized", "kernels", "EP and paged attention"]}, {"id": "I", "x": 128, "y": 1040, "w": 205, "h": 62, "title": ["Native-speed inference", "4B to 235B, match or beat"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [230, 70, 230, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [230, 226, 230, 304]}, {"src": "C", "dst": "D", "kind": "data", "label": "Before", "curve": [[272, 356], [345, 549], [345, 775], [345, 884]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "Now: model-impl transformers", "curve": [[189, 356], [116, 402], [116, 402], [116, 448]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [116, 510, 116, 588]}, {"src": "F", "dst": "G", "kind": "data", "line": [116, 666, 116, 744]}, {"src": "G", "dst": "H", "kind": "data", "line": [116, 806, 116, 884]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[116, 962], [116, 1001], [116, 1001], [180, 1040]]}, {"src": "D", "dst": "I", "kind": "data", "curve": [[345, 962], [345, 1001], [345, 1001], [281, 1040]]}]});
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
      const container = document.getElementById('mtransformersnativespeed-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'mtransformersnativespeed-1';
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

The practical meaning of this shift is that the lag between the serving engine and the model ecosystem disappears. Previously every new architecture required two codebases, a training implementation and an inference implementation, and the gap between them was exactly the "great model is out but we cannot serve it fast yet" window. Now that window narrows. Whether you are a research team experimenting with a custom architecture or an operations team trying to put a freshly released model into production, one Transformers implementation gives you vLLM speed.

## Installation and Integration

This backend is not a separate package; it ships inside vLLM itself. Install vLLM v0.25.0 or later and add `--model-impl transformers` to your serving command. The real examples Hugging Face published are as follows.

```bash
# Single GPU, dense model
vllm serve Qwen/Qwen3-4B --model-impl transformers

# Tensor parallel across 2 GPUs, large dense model
vllm serve Qwen/Qwen3-32B \
  --model-impl transformers \
  --tensor-parallel-size 2

# Data parallel plus expert parallel, MoE model
vllm serve Qwen/Qwen3-235B-A22B-FP8 \
  --model-impl transformers \
  --data-parallel-size 8 \
  --enable-expert-parallel
```

The same works from the Python API for offline inference.

```python
from vllm import LLM, SamplingParams

llm = LLM(
    model="Qwen/Qwen3-4B",
    model_impl="transformers",   # use the Transformers definition, not a dedicated port
)
out = llm.generate(
    ["How does ThakiCloud serve open-weight models?"],
    SamplingParams(max_tokens=256, temperature=0.7),
)
print(out[0].outputs[0].text)
```

What stands out across the three examples is that distributed serving options like tensor parallel, data parallel, and expert parallel all still work under the Transformers backend. In other words, you do not give up scale-out in exchange for compatibility. From a dense 4B model to a 235B MoE, one flag covers it.

## Real Experiment Results

This environment is macOS (Apple Silicon), so it cannot run vLLM's CUDA kernels, and we could not reproduce the vLLM throughput benchmark itself. Instead we reproduced the **single most important step the backend performs internally: using torch.fx to statically analyze the model graph and find fusion-target patterns**. We built a 4-layer Llama-style decoder in pure PyTorch with the same structure real serving models use (grouped-query attention and a SwiGLU MLP), traced its graph with `torch.fx.symbolic_trace`, and classified the nodes.

The measurements were as follows. Tracing this small decoder of 2.902M parameters produced a torch.fx graph with a total of **178 nodes**. By op type there were 80 function calls, 60 method calls, 28 module calls, and 8 attribute lookups. Among these, the function-level patterns the backend can immediately swap for fusion kernels were 16 RMSNorm reductions, 8 attention-related matmuls, 4 softmaxes, and 4 SwiGLU activations, for 32 in total, plus 28 module calls carrying the QKV/output/MLP projections and normalizations. Forward latency at sequence length 64 averaged 1.4ms, measured on torch 2.13.0.

![Bar chart showing the distribution of fusion-target nodes in the torch.fx graph]({{ '/assets/images/vllm-transformers-native-speed-results.png' | relative_url }})

What these numbers show is clear. Even in a single small block of 178 nodes, well-formed patterns of attention, normalization, and MLP activation recur, and these are exactly the points the backend targets to replace with vLLM kernels. In a real model with dozens of layers this pattern multiplies by the layer count, so a single graph analysis lets the backend fuse the bottleneck operations across the whole model at once. According to Hugging Face, this approach let the Transformers backend match or beat native vLLM throughput from 4B to 235B, including tensor-parallel and MoE setups. Our experiment did not reproduce those throughput figures; it confirmed by measurement the **skeleton of the mechanism** that produces them.

## Implications for ThakiCloud

ThakiCloud's **ai-platform** is multi-tenant AI/ML infrastructure that serves models to diverse customer environments on top of K8s and Kueue-based GPU scheduling. This backend is a direct benefit for a serving operator like us. First, **model onboarding lead time shrinks.** When a new open-weight model ships, until now we had to wait for vLLM to officially support that architecture or accept a self-port. If a Transformers implementation exists, `--model-impl transformers` lets us bring up an optimized-speed serving pod right away. That directly affects the competitive question of how fast a new model reaches production.

Second, **the serving path for custom architectures gets simpler.** When we serve a model fine-tuned or structurally modified for a specific customer on-premises, being able to deploy from the Transformers definition alone, with no dedicated vLLM port, greatly reduces maintenance burden. In sovereign-cloud or regulated environments that require self-hosting, we save the time spent reconciling engine and model versions. Since tensor, data, and expert parallel all still work, we can adopt this path without changing the multi-GPU serving topologies we already run.

From an agent perspective, the **Paxis** lens applies too. Paxis is the Agent-Native Cloud control plane that runs on top of ai-platform, swapping different models like tools as it executes agents. If the serving layer can bring up new open-weight models faster and cheaper, the pool of models the agents on top can choose from widens and the cost of switching drops. Because low-cost, low-latency serving is ultimately what makes agent workloads economical, ai-platform's serving efficiency and Paxis's agent flexibility point in the same direction.

## Limitations and Counterarguments

This backend is not a cure-all, and a few clear limits deserve mention to be fair. First, the performance advantage is limited to "compatible architectures." The model must be statically traceable by torch.fx, and it must match patterns the backend already knows for fusion to apply. A structure with heavy dynamic control flow or novel operations the backend has not seen will fall back to unfused paths for some parts, and the speed advantage shrinks accordingly. Not every Transformers model automatically reaches native speed.

Second, this feature reached maturity in v0.25.0 but is still evolving. For certain quantization combinations, certain attention variants, or rare MoE routing schemes, a dedicated ported implementation may still be more stable or faster. Before going to production it is safer to benchmark actual throughput and accuracy yourself on your target model and target hardware. That is exactly why we did not cite vLLM throughput numbers directly and instead attributed them to the official announcement; the figures vary by environment, so a measurement on the ThakiCloud GPU cluster is planned separately.

Third, a counterargument is possible. When the serving engine and the model library become tightly coupled, changes in Transformers can affect serving stability. In the era of two separate codebases you could pin the inference stack independently, but sharing a backend forces you to rethink version management. Even so, weighed against the cost of implementing every new model twice, we judge that in most serving scenarios the onboarding-speed gain from this coupling is larger.

## Sources

- [Native-speed vLLM transformers modeling backend (Hugging Face Blog)](https://huggingface.co/blog/native-speed-vllm-transformers-backend)
- [vLLM v0.25.0: transformers backend now matches native vLLM speed (daily.dev)](https://daily.dev/posts/vllm-v0-25-0-transformers-backend-now-matches-native-vllm-speed-z8kvnsk7c)
- [Transformers modeling backend integration in vLLM (vLLM Blog)](https://blog.vllm.ai/2025/04/11/transformers-backend.html)
- [Clement Delangue (@ClementDelangue) on X](https://x.com/ClementDelangue/status/2076763231788339669)
- Experiment code and logs: `outputs/blog-impl/vllm-transformers-native-speed/` (torch.fx graph-analysis reproduction, torch 2.13.0, CPU)
