---
title: "A $400K Rack on a 24GB Graphics Card? We Reproduced ktransformers' '28x' Ourselves"
excerpt: "ktransformers claims you can run a giant MoE model on a single 24GB GPU by offloading experts to CPU. We tested the viral '28x' and '$400K to 24GB' claims by renting GPUs on RunPod twice, for about $5. The trick was real, but the number stood on three hidden assumptions."
date: 2026-07-19
tags:
  - ktransformers
  - MoE
  - LLM서빙
  - GPU
  - AMX
  - LLMOps
  - 벤치마크
  - 인프라
author_profile: true
toc: true
toc_label: "Anatomy of the 28x"
published: true
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/ktransformers-moe-offload-28x-validation/"
---

This post is for engineers weighing whether to self-host an MoE model, and for infrastructure leads who have to decide how far to trust the current wave of tweets claiming "run a giant model on a single GPU." The short version: the ktransformers trick is real and it works. But the viral phrases "28x" and "a $400K rack on a single 24GB card" each rest on a hidden assumption. Here is what those assumptions are, based on measurements from two separate GPU rentals on RunPod.

## What made it go viral

The idea behind ktransformers (kvcache-ai/ktransformers, Apache 2.0, 17k stars), released by Tsinghua's MADSYS lab, boils down to one sentence. In an MoE model, keep only the experts that are actually being called near the GPU, and park the experts that sit idle most of the time in CPU memory, pulling them in only when needed. With this layout, DeepSeek-V3 and R1 reportedly run on 24GB of VRAM with a 139K context, up to 28x faster than the standard setup.

The trick itself is almost embarrassingly simple. That is exactly what made it suspicious. The only way to know whether this was a genuine free lunch, or whether a hidden bill was waiting somewhere, was to pull the numbers ourselves.

## Experiment design: isolating the mechanism with a smaller model

DeepSeek-V3 is 671B, so it will not fit on a 24GB card. We used Qwen3-30B-A3B (30B total, 3.3B active) as a proxy model, a scaled-down member of the same family (MLA plus fine-grained MoE). The goal was not to reproduce the vendor's 671B numbers, but to isolate whether "offloading experts to CPU" actually pays off as a mechanism, and if it does, to break down where that payoff comes from.

We split the measurement into two stages. First, we tested the mechanism itself on an off-the-shelf AMD box. Second, we separately measured the Intel AMX kernel that ktransformers claims is the source of its performance.

## Stage 1: measuring the mechanism on a commodity 4090 plus AMD

We rented an RTX 4090 (24GB) paired with an AMD Ryzen 9 7950X and 188GB RAM on RunPod. This is where the first hidden assumption showed up immediately. ktransformers' CPU expert kernel is optimized for Intel AMX instructions, and this AMD CPU has no AMX. So instead of ktransformers' own kernel, we measured the mechanism cleanly using llama.cpp's `--n-cpu-moe` (experts on CPU, attention and KV cache on GPU), which implements exactly the same trick.

We quantized Qwen3-30B-A3B to Q4 and compared decode speed across three layouts.

| Layout | Decode speed |
|---|---|
| Entire model on GPU (full-GPU) | 261.5 tok/s |
| Experts on CPU, attention on GPU (mechanism) | 12.0 tok/s |
| Everything on CPU (CPU-only) | 7.4 tok/s |

Two things stand out here. The mechanism is 1.62x faster than pure CPU. Moving attention to the GPU genuinely pays off. But when the model fits entirely in VRAM (Q4 is 18GB, which fits in 24GB), full-GPU beats the mechanism by 22x. In other words, if the model fits on the GPU, offloading experts to CPU is a net loss. This trick only matters at the moment the model overflows VRAM. In that case, "it runs at all, even at 12 tok/s" is the value, not raw speed.

## Stage 2: the real multiplier from the Intel AMX kernel

To face the AMX kernel head on, the claimed source of the 28x, we needed a Sapphire Rapids-generation Xeon. After spinning up several H100 pods on RunPod and checking their CPUs, we landed a host with an Intel Xeon Platinum 8470 (AMX bf16/int8/tile support), 208 vCPUs, and 1TB RAM.

The kt_kernel package bundles kernels for every backend, so within the same process we could run the AMX kernel and the AVX2 kernel side by side on identical BF16 weights. We measured MoE forward passes at DeepSeek-V3 scale (256 experts, hidden dim 7168) on both kernels.

| Kernel (identical BF16, decode) | Speed |
|---|---|
| AMX (AMXBF16_MOE) | 145.5 tok/s |
| AVX2 (AVX2BF16_MOE) | 105.5 tok/s |

The AMX kernel was 1.38x faster than AVX2. A clear win, but nowhere near 28x. Using INT8-only tile operations could widen that gap further (we limited this round to a same-precision BF16 comparison due to cost), but a single kernel alone does not produce a 28x speedup.

## Decomposing the "28x"

Putting the two experiments together shows how the vendor's 28x is actually composed. That number is not kernel magic, it is a comparison of the whole system against llama.cpp's pure-CPU execution. Broken down, it looks like this.

Moving attention and the KV cache to the GPU is by far the biggest lever. On the commodity AMD box, this layout alone produced a 1.62x gain over pure CPU, and once the model fits on the GPU, that gap widens to 35x. On top of that, the AMX expert kernel adds roughly another 1.4x over AVX2. INT8/INT4 quantization and pipeline optimizations stack on top of that. Each individual factor is a modest multiplier, but under specific conditions these multiply together into a double-digit speedup. Those conditions are: the model overflows VRAM, the CPU supports AMX, and the comparison baseline is pure-CPU llama.cpp.

## The truth behind "$400K to 24GB"

This phrase does not eliminate memory, it relocates it. Our pods each had 188GB and 1TB of system RAM respectively. Running DeepSeek-V3 at Q4 requires roughly 380GB of DRAM on the CPU side. The expert weights do not disappear, they simply move from VRAM to system RAM. So the accurate description is "one 24GB GPU plus a large-RAM server." An expensive GPU has been traded for cheap RAM, not a reduction in total memory demand. That is a different picture from a single consumer 24GB card replacing an entire data center rack.

## So how many tok/s, really, and at what cost

The experiments above decomposed the mechanism, but they left out the two numbers practitioners actually care about: how fast does a genuinely large model run, and how much money does this actually save. So we re-measured in the exact configuration where ktransformers actually makes sense: a many-core server CPU (Intel Xeon Platinum 8570, AMX support, 224 cores), 2TB of system RAM, local NVMe, and a single GPU. The model is Qwen3-235B-A22B (Q4, roughly 130GB), which fits neither on a 24GB card nor on a single 80GB card. This is the case where offloading is not optional, it is required.

First, the hardware claim checks out. Offloading all experts to CPU brings GPU memory usage down to just 11GB. A 235B-class model uses only 11GB of GPU memory. That fits not just on 24GB, but on a 12GB card. The picture of "run a 671B-class model on a big server with a single 4090" genuinely holds.

The problem is speed. Loading the same model entirely onto 2xA100 80GB gives 51.5 tok/s of decoding, comfortably enough for real-time conversation. But the offloaded state, with experts on CPU, is a completely different world. We measured this two independent ways, and both landed in single digits. Running llama.cpp end to end gives 1.2 tok/s. Measuring only the expert computation with ktransformers' actual AMX kernel (kt_kernel) gives 3.8 tok/s at BF16. Even putting some experts on the 24GB GPU only nudges this from 1.2 up to 1.5.

Why can't switching kernels break out of single digits. Because the fundamental bottleneck is computing 22B of active parameters on the CPU for every single token. The AMX kernel really is about 1.3x faster than AVX2, but that multiplier cannot clear the wall. The 8 to 15 tok/s ktransformers has publicly reported (for the larger DeepSeek-V3) stacks INT4 quantization, GPU expert placement, and pipelining all together, and even that figure is a batch-throughput number, not interactive serving speed.

This number flips the conclusion. Using RunPod's actual rental prices, the cost per million tokens works out as follows.

| Configuration | Hardware | Per hour | Decode | Per million tokens |
|---|---|---|---|---|
| Full-GPU | 2xA100 80GB | about $3 | 51.5 tok/s | about $16 |
| Offload | AMX server + 1 GPU | about $3 | about 2 to 4 tok/s | about $80 to $280 |

On a rental basis, offloading costs 5x to 17x more per token. It is not, in any sense, a tool for cutting cloud operating costs. And on top of that, a large AMX server itself is not cheap. RunPod does not even offer a "cheap 4090 plus large AMX server" combination, so AMX only comes bundled with data-center GPUs.

So the one place where the economics do work out is on premises, on a server you already own. If you already have a large Xeon server running, dropping a $1,600 4090 into that sunk cost to run a 671B-class model in batch is overwhelmingly cheaper than buying two new A100s worth $30,000. It is not a tool for cutting operating cost, it is a tool that, on hardware you already have, shifts the boundary between "this runs" and "this does not run." And its use case is not real-time serving, it is batch, offline, and latency-tolerant work like agents.

## So should you adopt it

Start by checking whether all three of these hold. Do you already own (or can you cheaply acquire) a large AMX server with a large amount of RAM. Is the model you want to run a large MoE (V3, R1-class) that genuinely overflows GPU VRAM. And is the workload latency-tolerant, batch or offline or agent-style, rather than real-time response. If all three are true, ktransformers becomes the only realistic path to running that model without buying an expensive multi-GPU setup. If even one is off, the answer changes. If you need real-time conversation, offloading's single-digit tok/s is not enough, and if the model fits on a GPU, just loading the whole thing onto the GPU is, without question, tens of times faster.

Here is that decision laid out as a single flow.

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
<div class="d3-arch" data-arch-root id="smoeoffload28xvalidation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 697, "height": 580, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 391, "y": 24, "w": 163, "h": 62, "title": ["Large MoE model", "overflows GPU VRAM?"]}, {"id": "B", "x": 495, "y": 178, "w": 170, "h": 62, "title": ["Load fully on GPU", "tens of times faster"]}, {"id": "C", "x": 291, "y": 178, "w": 149, "h": 62, "title": ["Own an AMX server", "with large RAM?"]}, {"id": "D", "x": 391, "y": 332, "w": 212, "h": 62, "title": ["Rent economics lose", "5 to 17x pricier per token"]}, {"id": "E", "x": 131, "y": 332, "w": 205, "h": 62, "title": ["Workload batch or offline", "latency tolerant?"]}, {"id": "F", "x": 270, "y": 486, "w": 156, "h": 62, "title": ["Single-digit tok/s", "too slow for chat"]}, {"id": "G", "x": 24, "y": 486, "w": 191, "h": 62, "title": ["ktransformers fits", "the only realistic path"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "No", "curve": [[516, 86], [580, 132], [580, 132], [580, 178]], "off": "50%"}, {"src": "A", "dst": "C", "kind": "data", "label": "Yes", "curve": [[430, 86], [366, 132], [366, 132], [366, 178]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "No", "curve": [[419, 240], [497, 286], [497, 286], [497, 332]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "Yes", "curve": [[312, 240], [234, 286], [234, 286], [234, 332]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "No, real-time", "curve": [[280, 394], [348, 440], [348, 440], [348, 486]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "Yes", "curve": [[188, 394], [120, 440], [120, 440], [120, 486]], "off": "50%"}]});
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
      const container = document.getElementById('smoeoffload28xvalidation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'smoeoffload28xvalidation-1';
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

In our view, the real value of ktransformers is neither "28x" nor "cheap serving." It is a single matter of accessibility: a team that cannot buy or rent multiple GPUs can now run a 671B-class MoE model at all, using a large server it already has plus a single GPU. It should be read not as a speed champion or a cost-cutter, but as a batch tool that lowers the barrier to entry.

## Reproduction details

All three experiments were run on RunPod, and total GPU cost came to about $15. The bench harness (llama.cpp `--n-cpu-moe`, the kt_kernel AMX/AVX2 kernel comparison, and the 235B end-to-end measurement) and the raw result JSON are all public. If you want to reproduce this yourself or verify the numbers, see [github.com/sylvanus4/ktransformers-moe-offload-bench](https://github.com/sylvanus4/ktransformers-moe-offload-bench) (Apache-2.0). The remaining candidate for verification is standing up ktransformers' full serving stack with INT4 quantization, GPU expert placement, and pipelining all turned on, to measure exactly how high batch throughput can actually climb.
