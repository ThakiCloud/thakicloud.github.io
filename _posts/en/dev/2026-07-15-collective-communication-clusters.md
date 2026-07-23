---
title: "The Anatomy of GPU and TPU Clusters: How Collective Communication Determines the Speed of Distributed Training"
excerpt: "When training or serving a large model across many accelerators, the real bottleneck usually isn't computation, it's the data moving between accelerators. This post walks through what collective operations like all-reduce, all-gather, reduce-scatter, and all-to-all actually are, and how they run on two very different physical structures: GPU clusters (NVLink, NVSwitch, InfiniBand) and TPU clusters (the ICI 3D torus and optical circuit switches). From the bandwidth cost formula behind ring all-reduce to which collectives are triggered by data, tensor, pipeline, and expert parallelism, we cover this from the perspective ThakiCloud brings to running GPU infrastructure."
tags:
  - dev
  - distributed-training
  - gpu
  - tpu
  - nccl
  - nvlink
  - infiniband
  - kubernetes
  - self-hosting
  - paxis
date: 2026-07-15
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/collective-communication-clusters/"
categories:
  - dev
---

## Overview

It has been a while since large language models could fit on a single GPU. Models with tens of billions to trillions of parameters are split across tens or thousands of accelerators, and at every training step those accelerators have to reconcile each other's results. This "reconciling" process is collective communication, and in most modern distributed training workloads, the thing that actually eats up time isn't matrix multiplication, it's this communication.

This post is for infrastructure engineers training or serving models on GPU or TPU clusters, and for anyone responsible for serving cost and scalability. It takes Aleksa Gordic's widely read deep dive, "Inside TPU and GPU Clusters: The Anatomy of Collective Communication," as a starting point, and cross-checks the core concepts against standard references (NCCL, the TPU v4 paper, and so on) along the way.

Here's the headline summary up front. First, the performance of distributed training reduces down to a handful of collective operations. Second, the cost of the same operation changes completely depending on the physical topology it runs on (NVIDIA's switch-based fabric versus Google's torus structure). Third, which parallelism strategy you use determines which collectives get called, and how often. Understanding these three points explains why placing a handful of GPUs in a particular arrangement has such an outsized effect on performance.

## What Collective Communication Actually Is

A collective operation is a communication pattern that multiple processes (typically one per accelerator) participate in together. Where point-to-point (P2P) communication is one process sending to another single process, a collective has the whole group split and merge data according to a shared rule. A few of these show up over and over in distributed training:

- **All-reduce**: every participant's tensor is reduced element-wise (summed or averaged), and the result is sent back to everyone. This is the exact operation used to reconcile gradients in data-parallel training.
- **Reduce-scatter**: a sum is computed, but instead of one participant holding the whole result, it's split into chunks that get distributed across participants.
- **All-gather**: each participant's chunk is collected so that everyone ends up with the full set. This is the counterpart to reduce-scatter, and chaining the two together produces an all-reduce.
- **All-to-all**: every participant sends a different chunk of data to every other participant. This pattern is close to a transpose, and it's central to routing tokens to experts in mixture-of-experts (MoE) models.
- **Broadcast / Reduce**: one-directional operations where one participant sends the same data to everyone, or everyone's data is collected and reduced down to one participant.

One key insight here is that all-reduce is not an atomic operation. All-reduce decomposes into a **reduce-scatter followed by an all-gather**. This decomposition is the root of the cost formula we'll get to later.

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
<div class="d3-arch" data-arch-root id="ivecommunicationclusters-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 669, "height": 586, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 228, "y": 24, "w": 191, "h": 62, "title": ["Each accelerator: local", "gradient/tensor"]}, {"id": "B", "x": 453, "y": 172, "w": 177, "h": 62, "title": ["Reduce-scatter", "Sum split into chunks"]}, {"id": "C", "x": 464, "y": 320, "w": 156, "h": 78, "title": ["All-gather", "Chunks restored to", "everyone"]}, {"id": "D", "x": 446, "y": 476, "w": 191, "h": 78, "title": ["All-reduce complete", "Everyone holds the same", "sum"]}, {"id": "E", "x": 249, "y": 172, "w": 149, "h": 62, "title": ["All-to-all", "MoE token routing"]}, {"id": "F", "x": 24, "y": 164, "w": 170, "h": 78, "title": ["Broadcast/Reduce", "One-directional", "distribute/aggregate"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[419, 86], [542, 125], [542, 125], [542, 172]]}, {"src": "B", "dst": "C", "kind": "data", "line": [542, 234, 542, 320]}, {"src": "C", "dst": "D", "kind": "data", "line": [542, 398, 542, 476]}, {"src": "A", "dst": "E", "kind": "data", "line": [324, 86, 324, 172]}, {"src": "A", "dst": "F", "kind": "data", "curve": [[229, 86], [109, 125], [109, 125], [109, 164]]}]});
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
      const container = document.getElementById('ivecommunicationclusters-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ivecommunicationclusters-1';
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

## The Physical Structure of GPU Clusters

It's easiest to think of an NVIDIA-based cluster as two layers: within a node (scale-up) and between nodes (scale-out).

Within a node, **NVLink** and **NVSwitch** tie the GPUs together tightly. The eight or so GPUs inside a single server are wired through NVSwitch into something close to a full mesh, communicating at uniformly high bandwidth from any GPU to any other. This is exactly why work with extremely frequent communication, like tensor parallelism, gets confined inside this domain.

Between nodes, a leaf-spine (fat-tree) network built on **InfiniBand** or **RoCE** (RDMA over Converged Ethernet) is used. This scale-out fabric connects GPUs across racks and servers. A design that shows up often here is the rail-optimized topology: the same-numbered NIC on each node is attached to the same switch (a "rail"), so that inter-node all-reduce traffic passes through fewer hops at the spine layer.

That flexibility comes at a cost. The thousands of switches a scale-out fabric requires can consume roughly 5 to 10 percent of a cluster's total power [the estimated range varies by configuration], and they demand significant capital expenditure. In other words, instead of relying on any GPU being able to talk cleanly to any other GPU by default, NVIDIA's approach buys that uniformity by paying for switches that actively process packets.

## TPU Clusters Take a Different Path

Google's TPUs go a completely different route. Rather than an active switching fabric, TPU chips connect directly to their neighbors over a dedicated high-speed link called **ICI (Inter-Chip Interconnect)**. In the latest generation, each chip extends ICI links in six directions, plus and minus X, Y, and Z, forming a **3D torus** lattice (earlier generations used a 2D torus to build pods of 256 chips). Because chips only connect directly to their neighbors, most of the switching layer disappears.

That raises an obvious question: how do you connect chips that are far apart, or scale beyond a single pod? This is where the **optical circuit switch (OCS)** comes in. According to the TPU v4 paper, an OCS reconfigures optical fibers using MEMS mirrors rather than actively interpreting the optical signal, it just reflects it. That lets it reconfigurably connect up to 4096 chips while consuming far less power than an InfiniBand switch, since power is only needed to hold the mirror positions in place. It also allows one axis of the torus to be optically wrapped around, or lets the topology be rewired in software to route around a failed node.

Put simply, GPU clusters invest in active switches to buy uniform access, while TPU clusters lean on a neighbor-direct torus plus optical reconfiguration to save on power and cost. Neither approach is unconditionally superior. A torus is optimal for neighbor-to-neighbor traffic but adds hops for arbitrary long-distance communication, while a switch fabric is uniform but expensive and power-hungry.

## How Collectives Map to Parallelism Strategies

Which collective gets called, and how often, ultimately comes down to which parallelism strategy is in use.

- **Data parallelism (DP)**: each replica processes a different batch, then gradients are reconciled with **all-reduce**. Communication volume scales with model size and happens once per step.
- **Fully sharded data parallelism (FSDP/ZeRO)**: parameters are sharded and held in pieces, gathered with **all-gather** right before the forward pass, and split back apart with **reduce-scatter** after the backward pass. It saves memory at the cost of more frequent communication.
- **Tensor parallelism (TP)**: a single layer's computation is split across multiple GPUs, and the results are merged at each layer boundary with **all-reduce** or all-gather/reduce-scatter. Communication is extremely frequent, which is why confining it inside the NVLink domain mentioned earlier is practically mandatory.
- **Pipeline parallelism (PP)**: the model is sliced by layer and distributed across different GPUs, and activations are handed off between stages mostly via **P2P** transfers. Point-to-point communication dominates rather than collectives.
- **Expert parallelism (EP/MoE)**: tokens have to be routed to the accelerator holding the relevant expert, so **all-to-all** is central. As the number of participants grows, the number of communication pairs in an all-to-all grows quadratically, making it especially sensitive to topology.

In practice, these strategies are layered on top of each other. For example, a typical layout places TP inside a node's NVLink, DP's all-reduce over the inter-node InfiniBand, and PP spanning across both. Get the placement wrong, and frequent tensor-parallel communication leaks onto the slower inter-node links, slowing down the entire training run.

## The Rule That Governs Performance: Rings and Trees

There are several algorithms for actually implementing a collective, but from a bandwidth perspective, the best known is **ring all-reduce**. Participants are connected in a single ring, and at each step each one passes its chunk to its next neighbor, carrying out reduce-scatter and all-gather each over N-1 steps.

The total amount of data carried on each link works out to a well-known formula. For an all-reduce of a tensor of size S across N participants, the traffic per link is approximately:

```
2 x (N - 1) / N x S
```

That's because (N-1)/N x S flows during reduce-scatter, and another (N-1)/N x S flows during all-gather. The key property here is that as N grows, (N-1)/N converges toward 1, so traffic per link flattens out to roughly 2S. This is why ring all-reduce is called bandwidth-optimal, and it's why libraries like NCCL and Gloo have relied on it for a long time.

The problem is latency. A ring has to traverse N-1 sequential steps, so the fixed per-step latency (alpha) accumulates in proportion to the number of participants. When a lot of nodes are doing an all-reduce on a small tensor, bandwidth is left on the table while latency becomes the bottleneck. That's why real libraries automatically choose between ring and tree (or hierarchical) algorithms depending on tensor size and node count. Tree algorithms bring latency down closer to log(N) at the cost of some bandwidth efficiency, which is why NCCL selects different algorithms depending on message size.

The practical implication of this rule is clear. As you change batch size, model size, and node count, the dominant bottleneck shifts back and forth between bandwidth and latency. That's exactly why you can't assume "doubling the number of nodes doubles the speed" without benchmarking it.

## Implications for ThakiCloud's Products

This topic touches the heart of infrastructure, which makes it especially practical from the perspective of ThakiCloud's **ai-platform** (our Kubernetes-based AI/ML SaaS infrastructure).

First, **topology-aware scheduling**. ai-platform schedules GPU workloads with Kueue, and the placement principle of keeping tensor-parallel jobs inside the same NVLink domain (the same node) while routing a data-parallel job's all-reduce over rail-optimized inter-node links lines up exactly with the communication characteristics of the collectives covered here. You need to know which collective flows over which link before job placement can translate into performance.

Second, **tensor parallelism in serving**. When a large model is served across multiple GPUs with tensor parallelism using an engine like vLLM, an all-reduce fires at every layer. Placing pods so that this communication stays inside NVLink makes it much easier to hit latency targets, and crossing a node boundary noticeably raises per-token latency. In a multi-tenant environment, this kind of placement discipline translates directly into serving cost and SLA outcomes.

Third, **the economics of on-premises and sovereign cloud**. The fact that GPU switches account for a meaningful share of power draw means that when designing a cluster for an on-premises or domestic sovereign environment, networking isn't a minor add-on, it's a core variable in total cost of ownership (TCO). The self-hosting and cost efficiency ThakiCloud aims for only holds up on top of these network design decisions.

There's also a connection to **Paxis**, our agent orchestration product. When distributed training or large-scale inference jobs are coordinated as a DAG and executed in isolation, understanding the communication profile of the collectives each stage calls makes it possible to design more precise resource reservations and policy gates. That said, the center of gravity in this post is the infrastructure layer, so the ai-platform lens is the primary one here.

## Limitations and Counterarguments

This perspective has its counterarguments too. First, frameworks abstract collectives away quite a lot. With the higher-level APIs in PyTorch or JAX, most placement decisions happen automatically inside the library and scheduler, and application developers don't need to know these details. So if you ask, "does every team need to know torus and ring formulas," the honest answer is closer to no.

But the moment performance becomes a problem, this abstraction breaks down. When training runs slower than expected or serving latency spikes, finding the root cause eventually requires looking at which collective is flowing over which link. The abstraction is convenient on the happy path, but it turns into a leaky abstraction the moment you're diagnosing a bottleneck.

The rules laid out in this post also keep changing across hardware generations. NVLink and InfiniBand bandwidth, the number of TPU ICI links, and OCS scale all vary from generation to generation, so any concrete numbers should always be re-verified against the official documentation for that specific generation. The formulas and structures here provide a mental framework, but production decisions need to be closed out with real benchmarks. Finally, there's the practical gap where software fails to keep pace with hardware. Even a theoretically optimal topology is wasted if the kernels and communication libraries can't fully exploit it.

## Sources

- Aleksa Gordic, "Inside TPU and GPU Clusters: The Anatomy of Collective Communication": https://www.aleksagordic.com/blog/collective-operations
- NVIDIA NCCL documentation and the communication cost model for ring all-reduce (reduce-scatter + all-gather, bandwidth optimality)
- Google's TPU v4 paper, "TPU v4: An Optically Reconfigurable Supercomputer for Machine Learning with Hardware Support for Embeddings" (ICI 3D torus, OCS): https://arxiv.org/abs/2304.01433
