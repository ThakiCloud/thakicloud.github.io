---
title: "Running Gemma 4 26B 16x Parallel on a Single DGX Spark: NVFP4 Quantization and an Honest Cost-Efficiency Review"
excerpt: "NVIDIA's Gemma-4-26B-A4B-NVFP4 running 16 parallel streams on a single DGX Spark (128 GB unified memory) delivers roughly 18 tokens/s per stream and about 300 tokens/s combined. This post covers how NVFP4 compresses a 25.2B MoE to 14 GB, the trade-off between single-stream latency and concurrency, and an honest assessment of whether the DGX Spark is actually cost-effective compared to other Blackwell GPUs."
seo_title: "Gemma-4-26B-A4B-NVFP4 DGX Spark 16x Parallel Inference - Honest Cost Efficiency Review - Thaki Cloud"
seo_description: "Serving Gemma-4-26B-A4B-NVFP4 (25.2B MoE / 3.8B active) on a DGX Spark 128 GB with 16x parallelism: 18 tok/s per stream, 300 tok/s combined. NVFP4 4-bit quantization, memory-bandwidth bottleneck, RTX 5090/RTX PRO 6000/B200 cost comparisons, and ThakiCloud on-premises serving perspective."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - gemma-4
  - nvfp4
  - dgx-spark
  - blackwell
  - mixture-of-experts
  - quantization
  - vllm
  - on-premise
  - inference
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/owm/gemma-4-26b-nvfp4-dgx-spark/"
lang: en
reading_time: true
categories:
  - owm
---

⏱️ **Estimated reading time**: 12 min

![Gemma 4 26B NVFP4 parallel inference concept diagram]({{ '/assets/images/gemma-4-26b-nvfp4-dgx-spark-hero.webp' | relative_url }})

## Overview

A demo showing a small desktop box running 16 concurrent sessions of a large MoE model has been making waves. The demo uses `Gemma-4-26B-A4B-NVFP4` published by NVIDIA, running 16 parallel streams on a single DGX Spark (128 GB unified memory), reaching approximately 18 tokens/s per stream and about 300 tokens/s combined. The person who shared the demo noted that the concurrency was too high to display legibly on screen, so the demo was presented programmatically, that up to 32x parallelism is possible, and that flashinfer had not even been applied yet.

Two points are worth highlighting. First, this is not a lightweight E2B/E4B model that fits on a laptop. It is a full-scale Gemma MoE with 25.2 billion total parameters. Second, the reason this is possible is the combination of three factors: NVFP4 4-bit quantization, the small active-parameter footprint of MoE, and the large unified memory of the DGX Spark.

ThakiCloud operates a platform that serves LLMs in a multi-tenant configuration on Kubernetes. For us, "how many concurrent requests can a small on-premises box handle?" is not just an interesting demo; it is a question that feeds directly into the cost model. This post reviews the model facts, separates single-stream performance from concurrent throughput, honestly assesses whether the DGX Spark is cost-effective relative to other Blackwell GPUs, and considers how far this model fits into our skill ecosystem.

## What the Demo Actually Showed

Summarizing the claims from the original demo ([Google Gemma team tweet](https://x.com/googlegemma/status/2069452783523401804)):

- Hardware: **1x DGX Spark, 128 GB unified memory (GB10 Grace-Blackwell)**
- Model: [`nvidia/Gemma-4-26B-A4B-NVFP4`](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- Concurrency: **16x parallel**, approximately **18 tokens/s per stream**, **approximately 300 tokens/s combined**
- Headroom: **up to 32x** parallelism is possible, capped at 16x for screen readability
- Optimization headroom: **flashinfer not yet applied**, so further speedup is likely once support arrives

One potential misreading to address upfront: "18 tokens/s per stream" is the per-stream figure when 16 streams run simultaneously. A single stream alone is faster. The trade-off between concurrency and single-stream latency is covered below with measured numbers.

## Gemma-4-26B-A4B-NVFP4: Model Facts

The model NVIDIA published is Google DeepMind's `gemma-4-26B-A4B-it` quantized to NVFP4 using the NVIDIA Model Optimizer. Key specs from the model card:

| Field | Value |
|---|---|
| Base model | google/gemma-4-26B-A4B-it |
| Architecture | Mixture-of-Experts (Transformer) |
| Total parameters | 25.2B |
| Active parameters | 3.8B (per token) |
| Expert configuration | 8 active + 1 shared out of 128 experts |
| Layers | 30 |
| Context | 256K tokens |
| Sliding window | 1024 tokens |
| Input modalities | Text + image |
| Quantization | NVFP4 (Model Optimizer v0.43.0) |
| Target hardware | NVIDIA Blackwell |
| License | Apache 2.0 |

### What NVFP4 Is and Why It Requires Blackwell

NVFP4 is a 4-bit floating-point format accelerated in hardware on NVIDIA's Blackwell generation. Unlike INT4 quantization, which simply truncates weights to 4-bit integers, NVFP4 uses microscaling with FP8 scale factors at small block granularity. This allows memory savings comparable to INT4 while keeping accuracy loss small.

The memory impact is most direct. Storing 25.2B parameters in BF16 requires roughly 50 GB; NVFP4 compresses the weights to approximately **14 to 16 GB**. On the DGX Spark's 128 GB unified memory, with weights at 16 GB, more than 100 GB remains available for the KV cache. That headroom is what enables 16 to 32x concurrency and long 256K-token contexts.

The hardware acceleration for NVFP4 is Blackwell-exclusive. On older generations like Hopper (H100) or Ada (RTX 4090), there are no NVFP4 tensor core paths, so the format's benefits cannot be realized. In practice, this model is built to run on Blackwell.

### Benchmark: How Much Does NVFP4 Quantization Cost?

The model card presents NVFP4 and baseline (unquantized) scores side by side:

| Benchmark | NVFP4 | Baseline | Domain |
|---|---|---|---|
| AIME 2025 | 90.00% | 88.95% | Math competition |
| MMLU Pro | 84.80% | 85.00% | General knowledge and reasoning |
| IFBench | 78.1% | 77.77% | Instruction following |
| GPQA Diamond | 79.90% | 80.30% | Graduate-level science reasoning |

All four benchmarks are within 1 percentage point of baseline. AIME and IFBench are slightly higher for the quantized version, which is most safely interpreted as measurement variance. The key takeaway is that "4-bit compression preserves quality in practice," which is exactly the advantage NVFP4 claims over INT4. That said, none of the public benchmarks cover Korean-language tasks, so separate internal evaluation is recommended for Korean-domain use cases.

## Real Performance: Single Stream vs. Concurrency

The "18 tokens/s per stream" from the demo can seem slow in isolation. The numbers need to be read with single-stream and concurrent modes separated. Synthesizing community reports measuring this model on the DGX Spark:

- **Single stream, no MTP**: approximately 32 tokens/s (with 64k context setting)
- **Single stream + MTP (Multi-Token Prediction)**: approximately **55 to 61 tokens/s** (32k context setting, best on short-to-medium responses and structured JSON)
- **16x concurrency**: approximately 18 tokens/s per stream, **approximately 300 tokens/s combined**
- **Long-context prefill**: approximately 11.9 s for 25k-token input, approximately 28.6 s for 50k-token input (64k context setting)

Two observations stand out.

First, **MoE decoding is memory-bandwidth-bound**. With only 3.8B active parameters per token, compute (FLOPs) is light, but every token requires fetching the active expert weights from memory. The DGX Spark's LPDDR5X unified memory has lower bandwidth than datacenter HBM, which is why single-stream speed is "modest for a Blackwell." Even with FP4 compute capacity to spare, bandwidth is the ceiling.

Second, the DGX Spark's real strength is not single-stream latency but **aggregate concurrent throughput**. Getting approximately 300 tokens/s across 16 streams means multiple requests share bandwidth efficiently. The large unified memory that allows a generous KV cache pool makes this possible. In other words, the machine is better suited to "serving many agents or users concurrently at adequate speed" than "delivering the fastest single response."

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
<div class="d3-arch" data-arch-root id="24gemma426bnvfp4dgxspark-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 729, "height": 697, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 227, "h": 254, "label": "DGX Spark · 128 GB Unified Memory", "lx": 36, "ly": 42}], "nodes": [{"id": "W", "x": 77, "y": 62, "w": 121, "h": 62, "title": ["NVFP4 Weights", "~16 GB"]}, {"id": "KV", "x": 63, "y": 179, "w": 149, "h": 62, "title": ["KV Cache Pool", "~100 GB+ headroom"]}, {"id": "R1", "x": 78, "y": 316, "w": 120, "h": 46, "title": "Request 1"}, {"id": "Spark", "x": 329, "y": 467, "w": 120, "h": 46, "title": "Spark"}, {"id": "R2", "x": 78, "y": 417, "w": 120, "h": 46, "title": "Request 2"}, {"id": "R3", "x": 78, "y": 518, "w": 120, "h": 46, "title": "..."}, {"id": "R16", "x": 78, "y": 619, "w": 120, "h": 46, "title": "Request 16"}, {"id": "O", "x": 527, "y": 459, "w": 170, "h": 62, "title": ["~18 tok/s per stream", "~300 tok/s combined"]}], "edges": [{"src": "R1", "dst": "Spark", "kind": "data", "curve": [[198, 339], [251, 339], [290, 339], [374, 467]]}, {"src": "R2", "dst": "Spark", "kind": "data", "curve": [[198, 440], [251, 440], [290, 440], [344, 467]]}, {"src": "R3", "dst": "Spark", "kind": "data", "curve": [[198, 541], [251, 541], [290, 541], [344, 513]]}, {"src": "R16", "dst": "Spark", "kind": "data", "curve": [[198, 642], [251, 642], [290, 642], [374, 513]]}, {"src": "Spark", "dst": "O", "kind": "data", "line": [449, 490, 527, 490]}]});
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
      const container = document.getElementById('24gemma426bnvfp4dgxspark-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '24gemma426bnvfp4dgxspark-1';
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

## Honest Review 1: Is the DGX Spark Actually Cost-Effective?

The short answer is: **exceptional value per unit of memory, average value per unit of token latency**. Different Blackwell chips have different characteristics.

| Chip | Price (USD) | Memory | Bandwidth | NVFP4 MoE status (2026-06) | Character |
|---|---|---|---|---|---|
| **DGX Spark** (GB10, SM121) | ~$4,699 | 128 GB unified LPDDR5X | 273 GB/s | ✅ Working (vLLM Marlin backend) | Large memory, high concurrency, low bandwidth |
| **RTX 5090** (SM120) | ~$2,000 [estimate] | 32 GB GDDR7 | 1,792 GB/s | ⚠️ Currently broken (flashinfer #2577) | Best $/token potential, small VRAM |
| **RTX PRO 6000** Blackwell (SM120) | ~$8,500 | 96 GB GDDR7 | 1,792 GB/s | ⚠️ Same SM120 issue | Large VRAM, overkill for this model |
| **B200** (SM100, datacenter) | ~$3 to $10/hr cloud [estimate] | 192 GB HBM3e | 8,000 GB/s | ✅ Fully supported (TRT-LLM/flashinfer) | Maximum performance, order-of-magnitude cost difference |

The most important column in this table is not price but **NVFP4 MoE status**, because that is where theory and reality diverge.

- **On paper, the RTX 5090 wins on $/token.** Its bandwidth is 6.6x that of the DGX Spark (1,792 vs. 273 GB/s), and since MoE decoding is bandwidth-bound, theoretical throughput ceilings follow almost directly. Reading 16 GB of weights at 273 GB/s gives a theoretical ceiling of roughly 170 tokens/s; at 1,792 GB/s, roughly 1,100 tokens/s. The RTX 5090 costs about half as much, so in simple arithmetic it is 5 to 6x more efficient.
- **In reality, NVFP4 MoE kernels are currently broken on consumer and professional Blackwell (SM120).** The flashinfer NVFP4 GEMM issue on SM120 ([#2577](https://github.com/flashinfer-ai/flashinfer/issues/2577)) remains open, making it effectively impossible to run this 4-bit MoE correctly on the RTX 5090 or RTX PRO 6000. The on-paper leader is, for now, "can't run it."
- **That leaves the DGX Spark (SM121) as the only consumer-class box where NVFP4 MoE actually works today.** Bandwidth is lower, so throughput is conservative, but "the 4-bit MoE box that runs today" is the actual reason this demo came from a DGX Spark.
- **Datacenter Blackwell (B200, SM100)** ships with full TRT-LLM and flashinfer NVFP4 support, but the per-unit cost is an order of magnitude different. 24/7 self-hosted serving favors owned hardware; burst or multi-tenant workloads may favor cloud B200.

In summary, the DGX Spark is not a machine for buying frontier-level per-token speed. It is a machine for **buying large memory and high concurrency, in a form that works today, at a relatively accessible price for development, prototyping, and small-scale concurrent serving.** Once SM120 kernels are fixed, the RTX 5090's theoretical cost advantage becomes real. Until then, the DGX Spark's position is clear. The 16x parallel demo is impressive precisely because it builds on that strength.

## Honest Review 2: What Workloads Does This Fit?

Once the cost-efficiency profile is established, appropriate workloads follow naturally.

**Good fit**

- Multiple concurrent agents: 16 to 32 workers each running at moderate speed simultaneously. Aggregate throughput is the strength.
- Structured output workloads: the model card confirms function calling and JSON structured output support, and MTP is fastest on short-to-medium responses and control JSON. Well-suited to classification, tagging, and extraction tasks.
- Long-context processing: 256K context and a large KV headroom leave room for long-document summarization and RAG context injection.
- On-premises prototyping: experimenting with large MoE serving on a desk without datacenter GPUs.

**Poor fit**

- Single-user ultra-low-latency chat: per-stream speed is slower than GDDR7 cards. Not appropriate if "fastest single response" is the goal.
- Hardest single-shot reasoning: tasks requiring quality headroom should use a 31B dense model, something larger, or a closed-source flagship. At 26B this is a throughput-tier model.

## Serving Guide

The recommended path per the model card is vLLM. Current constraints to be aware of:

- **vLLM TP=1 only**: the current build supports tensor parallelism of 1 only (assumes a single GPU or single box).
- **Gemma 4-specific parsers required**: the flags `--tool-call-parser gemma4` and `--reasoning-parser gemma4` must be specified for function calling and reasoning output to parse correctly.
- **flashinfer not yet applied**: the demo author stated flashinfer was not used. There is headroom for additional acceleration once attention kernel optimization is added.

For production use, Linux OS and Blackwell hardware with NVFP4 tensor cores are prerequisites. Running this build on older-generation GPUs will not deliver the 4-bit acceleration benefits.

## Implications for the ThakiCloud K8s AI/ML SaaS Platform

ThakiCloud operates a multi-tenant platform that manages GPU quotas with Kueue and serves models with vLLM. This demo has three implications for our operational model.

**A self-hosting candidate for worker-tier models.** Our agent orchestration follows the cost discipline of "workers cheap, gates expensive." Worker tasks such as exploration, classification, summarization, and structured extraction do not need top-tier models. NVFP4 26B, with roughly 300 tokens/s combined throughput and function calling plus JSON output, is a strong candidate for running many workers concurrently on-premises. Keeping only high-risk steps such as verification, synthesis, and architectural judgment on upper-tier models creates structural cost reduction.

**Large unified memory simplifies multi-tenant KV budgeting.** With weights at 16 GB on a 128 GB unified memory, the KV cache headroom exceeds 100 GB. KV cache is the first resource to run out in high-concurrency multi-tenant environments. This headroom allows generous per-tenant concurrency limits.

**A reference configuration for on-premises and compliance proposals.** Apache 2.0 license plus single-box serving is a configuration that can be proposed directly to public-sector and financial clients who require self-hosting. The ability to run a large MoE on a small box without datacenter GPUs is a practical deployment path for environments with constraints such as National Intelligence Service requirements or data-residency restrictions.

## Honest Review 3: Where Does This Model Fit in Our Skill Ecosystem?

Most of ThakiCloud's skill and agent ecosystem uses upper-tier models such as Opus or Sonnet as the primary. Where does NVFP4 26B slot in? Honestly:

- **Drop-in replacement (worker tier)**: file reading and grep summarization, classification and enum normalization (format-determinism workers), first-draft generation, news and document extraction. Read-only and structured tasks currently handled by haiku/sonnet sub-agents can largely be moved to on-premises 26B.
- **Conditional (with verification reinforcement)**: agent tool-call workers. Function calling and JSON output are supported, so this model can serve as a terminal worker in tool-call loops. However, fan-out results must be closed with adversarial verification by an upper-tier model to prevent hallucination accumulation.
- **Not recommended (gate tier)**: multi-step architectural reasoning, synthesis and verification judgments, high-risk content generation. Stages requiring quality headroom stay with Opus.

The key is matching model tier to task tier. Viewing NVFP4 26B as an "Opus replacement" leads to disappointment. Viewing it as "an on-premises self-hosting candidate for the haiku/sonnet worker tier" opens a path to restructuring costs. This aligns exactly with our routing discipline: exploration cheap, gates expensive.

## Limitations and Counter-Arguments

For balance:

- **Single-stream speed is conservative.** Memory-bandwidth limitations make it slower than GDDR7 cards. Latency-sensitive workloads require a different hardware choice.
- **Demo figures are configuration-dependent.** The 18 tokens/s and 300 tokens/s figures apply to 16x concurrency with specific settings. Results vary with prompt length, output length, and MTP usage. Your own workload requires re-measurement.
- **vLLM TP=1 and no flashinfer are current-snapshot constraints.** These numbers will change as optimizations are added; treat this as a point-in-time reading.
- **MoE serving has operational complexity.** Even though active parameters are 3.8B, all weights must reside in memory, and expert routing affects batch efficiency. "It's small" is an oversimplification.
- **Korean-language real-world validation is needed.** Public benchmarks are English-centric. Korean RAG and tool-call accuracy require internal evaluation.

Even with these caveats, the combination of Apache 2.0, single-box large-MoE serving, and high concurrency backed by large memory is a genuinely attractive option for organizations considering on-premises or self-hosted deployment. Approached with the mindset of "buying cheap memory and concurrency" rather than "buying frontier speed," DGX Spark plus NVFP4 26B has a clear and legitimate use case.

## Reference Links

- [Gemma-4-26B-A4B-NVFP4 model card (Hugging Face)](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- [Original demo tweet (Google Gemma)](https://x.com/googlegemma/status/2069452783523401804)
- [Full Gemma 4 lineup overview (ThakiCloud blog)](https://thakicloud.com/tech-blog/owm/gemma-4-open-weight-lineup/)
- [NVIDIA TensorRT Model Optimizer](https://github.com/NVIDIA/TensorRT-Model-Optimizer)
- [Introducing NVFP4 (NVIDIA Developer)](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [flashinfer NVFP4 GEMM SM120 issue #2577](https://github.com/flashinfer-ai/flashinfer/issues/2577)
- [DGX Spark Gemma 4 26B NVFP4 benchmark (ai-muninn)](https://ai-muninn.com/en/blog/dgx-spark-gemma4-26b-nvfp4-52-toks)
