---
title: "vLLM v0.25.0: Model Runner V2 Becomes the Default and PagedAttention Is Gone"
excerpt: "vLLM v0.25.0 landed with 558 commits from 232 contributors. Two changes define this release: Model Runner V2 is now the default execution path for every dense model, and the legacy PagedAttention implementation that first made vLLM famous has been removed from the codebase. Alongside that, the release adds efficient video sampling (EVS), dynamic speculative decoding, and Mamba hybrid prefix caching. Here is what changed and what to prepare for from the perspective of a team running serving infrastructure."
tags:
  - dev
  - vllm
  - inference
  - serving
  - cuda
  - self-hosting
  - kubernetes
  - paxis
date: 2026-07-12
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/vllm-v0-25-0-model-runner-v2/"
categories:
  - dev
published: false
---

## Overview

vLLM is the de facto standard inference engine for serving open-weight LLMs in production. Thanks to its high throughput and broad hardware support, most teams that host their own models on their own GPUs run them through vLLM. A new release of an engine like this is never just a version bump. It changes how the entire serving stack is operated.

This post is written for engineers who run inference infrastructure directly or own serving costs. vLLM v0.25.0, released in 2026, contains 558 commits from 232 contributors, 64 of them new. The scale matches the intent: the new execution architecture the project has been building toward over several prior releases was promoted to the default in this one, and the old paths were cleaned up along the way.

The headline is two changes. First, **Model Runner V2 (MRv2) is now the default execution path for every dense model**. Second, the **legacy PagedAttention implementation that made vLLM famous has been removed**. This post covers what those two changes mean for anyone operating a serving fleet, and what the accompanying video and speculative-decoding features are good for.

## What This Release Changes

The biggest structural change is the promotion of MRv2. MRv2 was built up over previous releases while the team hardened quantized model support, and as of v0.25.0 it becomes the standard execution path for dense models. Most models now run on this new core without needing any special flags. The vLLM team describes MRv2 as a more modular, faster core, and this release locks it in as the default path.

The natural consequence of that shift is the removal of the legacy PagedAttention implementation. Now that the V1 and MRv2 backends are the standard path, there was no longer a reason to keep the old attention implementation around. PagedAttention, the technique that manages the KV cache page by page to cut memory waste, was something of a signature feature from vLLM's early days, but the idea itself has already been absorbed into the new backends. What was removed here is old code, not the concept.

Here is the shift in execution paths laid out visually:

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
<div class="d3-arch" data-arch-root id="12vllmv0250modelrunnerv2-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 943, "height": 558, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 497, "y": 24, "w": 149, "h": 46, "title": "Inference request"}, {"id": "B", "x": 463, "y": 148, "w": 216, "h": 52, "title": "Execution path selection"}, {"id": "C", "x": 590, "y": 300, "w": 212, "h": 62, "title": ["Legacy PagedAttention path", "removed in this release"]}, {"id": "D", "x": 358, "y": 292, "w": 177, "h": 78, "title": ["Model Runner V2", "standard path for all", "dense models"]}, {"id": "E", "x": 720, "y": 464, "w": 191, "h": 46, "title": "Quantized model support"}, {"id": "F", "x": 453, "y": 448, "w": 212, "h": 78, "title": ["Dynamic speculative", "decoding", "full CUDA graph compatible"]}, {"id": "G", "x": 270, "y": 456, "w": 128, "h": 62, "title": ["Mamba hybrid", "prefix caching"]}, {"id": "H", "x": 24, "y": 456, "w": 191, "h": 62, "title": ["Multimodal prefix", "bidirectional attention"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [571, 70, 571, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "Before v0.24", "curve": [[616, 200], [696, 246], [696, 246], [696, 300]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "v0.25.0 default", "curve": [[526, 200], [447, 246], [447, 246], [447, 292]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "curve": [[535, 350], [816, 409], [816, 409], [816, 464]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[503, 370], [559, 409], [559, 409], [559, 448]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[390, 370], [334, 409], [334, 409], [334, 456]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[358, 352], [120, 409], [120, 409], [120, 456]]}]});
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
      const container = document.getElementById('12vllmv0250modelrunnerv2-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '12vllmv0250modelrunnerv2-1';
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

## Key Changes in Detail

The features layered on top of MRv2 in this release mostly target multimodal and long-context workloads.

First, **Efficient Video Sampling (EVS)**. Vision-language models that handle video see their token counts explode as frame counts grow, which quickly wrecks memory and latency. EVS prunes tokens from spatiotemporal regions that are nearly static while preserving the positional identity of the tokens that remain. Because the number of retained tokens grows sublinearly with clip length, models can handle much longer temporal context without blowing past memory and latency budgets.

Second, **dynamic speculative decoding is now compatible with full CUDA graphs**. Speculative decoding uses a small draft model to propose several tokens ahead of time, which the main model then verifies, boosting throughput. Working alongside CUDA graph capture means you can now get the kernel-overhead savings of graph capture and the throughput gains of speculative decoding at the same time.

Third, there is an important tradeoff to know about. **Turning on EVS pruning automatically disables the video CUDA graph.** Because EVS makes the token count depend on the input data, it conflicts with CUDA graph capture, which assumes a fixed shape. In other words, choosing the token savings of long-video pruning means giving up CUDA graph optimization on that path. Which side makes sense depends on the workload, and teams need to make that call themselves.

The release also ships realtime embeddings, prefix caching for Mamba hybrid models, and bidirectional attention support for multimodal prefixes. As hybrid architectures built on Mamba become more common, prefix caching support for them is a concrete win that lowers the cost of repeated requests.

## Installation and Verification

vLLM v0.25.0 installs the standard way.

```bash
uv pip install vllm==0.25.0
```

The basic command for serving a model after installation hasn't changed.

```bash
vllm serve <model-id>
```

Since MRv2 is now the default path, you generally don't need to set any separate runner flags to serve dense models.

To be upfront about it, the environment we wrote this post in has no GPU, so we couldn't measure actual throughput or latency ourselves. That's why this post doesn't include any performance numbers we haven't measured firsthand. Every fact cited here comes from the official release notes: the commit and contributor counts, MRv2's promotion to default, the removal of legacy PagedAttention, and the characteristics of EVS and dynamic speculative decoding are all based on published release information. For real benchmarks, we recommend measuring on your own GPU cluster with your target models and traffic patterns.

## Implications for ThakiCloud's Products

This release lands directly on how ThakiCloud runs **ai-platform**. ai-platform schedules GPUs with K8s and Kueue and serves models to a range of customer environments through vLLM. Since vLLM is the core engine of our serving stack, a change in its execution architecture is also a change in how we operate.

MRv2 becoming the default means we can now concentrate our validation and optimization effort on a single standard execution path. When multiple paths coexist, bug reproduction and performance tuning fork along each one, but once a standard path is set, operational complexity drops. For a platform serving dozens of models concurrently in a multi-tenant environment, that simplification translates directly into stability.

The combination of dynamic speculative decoding with CUDA graphs, along with Mamba hybrid prefix caching, both push serving costs down. Lower serving costs are a direct competitive edge for customers who need on-premises or sovereign AI. The economics of the agents and applications running on top only work if the underlying infrastructure can serve cheaply. In that sense, ai-platform's low-cost serving is the foundation that supports the economics of higher-level agent layers like Paxis.

## Limitations and Counterpoints

The first thing to flag is that this release includes a breaking change. Because the legacy PagedAttention path was removed, any custom configuration or third-party integration that depended on it may break under v0.25.0. When bumping versions in production serving, you should actually spin up your target models in staging and check for regressions before rolling out. Deploying a new release straight to production just because it's new is risky.

Second, as with the EVS and CUDA graph tradeoff noted above, new features don't always come out as a pure win. Teams need to decide which optimizations to turn on or off based on their own workload characteristics, and that call is hard to make without real measurement. The expectation that "turning on every new feature makes things faster" often doesn't hold up in practice.

Third, the sheer size of the release is itself a risk. A release that bundles in 558 commits at once leaves more room for unexpected interactions. There may be issues that only show up with specific model architectures or hardware combinations, so it's worth not skipping validation on the exact model and GPU combination you actually serve.

In short, vLLM v0.25.0 is a release that locks in the results of long preparation as the default. Unifying around MRv2 and cleaning up legacy paths makes the serving stack simpler and faster over the long run, which is a direct benefit for ThakiCloud's ai-platform, which runs vLLM as its core engine. But capturing that benefit safely still requires the basics: validating breaking changes and measuring per-workload before you flip the switch.

## Sources

- vLLM v0.25.0 release: [github.com/vllm-project/vllm/releases/tag/v0.25.0](https://github.com/vllm-project/vllm/releases/tag/v0.25.0)
- Model Runner V2 introduction: [vllm.ai/blog/2026-03-24-mrv2](https://vllm.ai/blog/2026-03-24-mrv2)
- Efficient Video Sampling (EVS) paper: [arxiv.org/pdf/2510.14624](https://arxiv.org/pdf/2510.14624)
