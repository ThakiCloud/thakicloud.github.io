---
title: "Preparing for What Comes After NVFP4: A Complete Guide to Quantization Methods for vLLM Serving (Including Unsloth)"
excerpt: "Beyond Blackwell-only NVFP4, this guide covers every quantization method you can serve with vLLM today on Hopper and Ampere -- AWQ, GPTQ, FP8, W4A16, compressed-tensors, and Unsloth Dynamic 2.0 -- with real recipes and serving flags."
seo_title: "Complete vLLM Quantization Serving Guide: AWQ, GPTQ, FP8, W4A16, Unsloth - Thaki Cloud"
seo_description: "Compare LLM quantization methods for vLLM serving. Covers llm-compressor (compressed-tensors) W4A16, W8A8, FP8; AWQ+Marlin; GPTQModel; AutoRound; Unsloth Dynamic 2.0; and the merge-to-AWQ production path -- with real code."
date: 2026-06-20
last_modified_at: 2026-06-20
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/llmops/llm-quantization-vllm-serving-unsloth/
tags:
  - quantization
  - vllm
  - awq
  - gptq
  - fp8
  - llm-compressor
  - unsloth
  - compressed-tensors
  - moe
  - thakicloud
header:
  teaser: /assets/images/llm-quant-vllm-hero.webp
toc: true
toc_sticky: true
categories:
  - llmops
published: false
---

![Map of quantization formats served by vLLM]({{ '/assets/images/llm-quant-vllm-hero.webp' | relative_url }})

## Why Quantization Again

The bulk of serving cost comes from GPU memory and throughput. Compressing a model to 4 bits lets you load a larger model onto the same card and serve the same model to more concurrent users. The question is: which quantization format actually works well with vLLM in production?

The [NVFP4 quantization](https://github.com/ThakiCloud/praxis) we covered earlier is the cutting-edge path for running W4A4 on Blackwell (B200) tensor cores. But NVFP4 tensor cores exist only on Blackwell. For older generations like H100 and A100, or for mixed clusters, you need different techniques. This post sets NVFP4 aside and catalogues the methods you can use right now with the hardware you have -- including Unsloth Dynamic 2.0 -- complete with real recipes.

## The vLLM Quantization Landscape

| Method | Bit-width | vLLM Load | GPU | Notes |
|---|---|---|---|---|
| AWQ + Marlin | W4A16 | `--quantization awq` (Marlin auto) | Turing+ | Production 4-bit standard |
| GPTQ / GPTQModel | W4A16, W3 | `--quantization gptq` | Volta+ | Broadest compatibility |
| compressed-tensors | W4A16 / W8A8 / FP8 | Auto-detected (no flag needed) | Turing+ ~ Blackwell | Official llm-compressor format |
| FP8 (E4M3) | W8A8 FP8 | `--quantization fp8` or auto | Ada (cc>=8.9), Hopper, Blackwell | Top choice for MoE |
| INT8 W8A8 | W8A8 INT8 | compressed-tensors auto | Turing+ | SmoothQuant family |
| AutoRound | W4A16, INT2-4 | compressed-tensors auto | CUDA, CPU, Intel | Excellent accuracy at very low bit-widths |
| bitsandbytes NF4 | W4A16 | `--quantization bitsandbytes` | Volta-Hopper | Memory-focused, low throughput |
| GGUF | Q4-Q8 | `repo:quant` (plugin) | Experimental | For llama.cpp ecosystem |

Two points stand out. First, vLLM's production 4-bit standard is W4A16 via AWQ or GPTQ running on the **Marlin kernel**. In JarvisLabs benchmarks on Qwen2.5-32B, Marlin-AWQ reached 741 tok/s versus 68 tok/s for the baseline AWQ kernel -- a dramatic difference ([source](https://jarvislabs.ai/blog/vllm-quantization-complete-guide-benchmarks)). Second, the **compressed-tensors** format -- developed jointly by neuralmagic (Red Hat) and the vLLM project -- stores quantization metadata in `quantization_config`, which vLLM reads and loads automatically without any extra flags.

## compressed-tensors and llm-compressor: The Recommended Path

Quantizing with `llm-compressor` produces output in compressed-tensors format, which vLLM detects automatically. W4A16, W8A8-INT8, and FP8 are all handled by a single tool ([llm-compressor](https://github.com/vllm-project/llm-compressor)).

```python
# W4A16 (AWQ-style) llm-compressor recipe
from llmcompressor.transformers import oneshot
from llmcompressor.modifiers.quantization import GPTQModifier

recipe = GPTQModifier(scheme="W4A16", targets="Linear", ignore=["lm_head"])
oneshot(
    model="Qwen/Qwen3-30B-A3B",
    dataset="open_platypus",   # calibration set
    recipe=recipe,
    output_dir="Qwen3-30B-A3B-W4A16",
    max_seq_length=2048, num_calibration_samples=512,
)
```

Serving requires almost no extra flags.

```bash
# compressed-tensors is auto-detected; --quantization can be omitted
vllm serve ./Qwen3-30B-A3B-W4A16 --served-model-name qwen3-w4a16
# Serving an AWQ checkpoint directly
vllm serve TheBloke/...-AWQ --quantization awq
```

FP8 can be created dynamically without calibration data, making it the lowest-friction option.

```python
from llmcompressor.modifiers.quantization import QuantizationModifier
recipe = QuantizationModifier(targets="Linear", scheme="FP8_DYNAMIC", ignore=["lm_head"])
```

## MoE Models (Qwen3-MoE): FP8 Block-Wise First

Our primary serving targets are Qwen3-MoE family models. MoE architectures are tricky to quantize. The short answer: on GPUs with cc>=8.9 (Ada, Hopper, Blackwell), **FP8 block-wise** is the top choice. It needs no calibration data and has official vLLM support. If memory is tighter, fall back to W4A16. Note that FP8 per-tensor has a reported dimension-mismatch bug on Qwen3-MoE, so block-wise is the safer route ([issue](https://github.com/vllm-project/llm-compressor/issues/2043)).

## Unsloth: Fine-Tuning and Dynamic 2.0 Quantization

Unsloth is useful in two ways: QLoRA fine-tuning and Dynamic 2.0 quantization.

**Dynamic 2.0 (UD)** does not apply a uniform bit-width across all layers. Instead, it evaluates per-layer sensitivity and assigns higher precision to critical layers while compressing less important ones further. The result is a model-specific quantization map. In benchmarks published by Unsloth, Gemma 3 27B with Dynamic Q4_K_XL scored 71.47% on MMLU 5-shot -- higher than the Google QAT baseline of 70.64% -- while the file size was only 15.64GB (Unsloth-reported, [blog](https://unsloth.ai/blog/dynamic-v2)). Unlike the original Dynamic release which worked mainly for MoE, version 2.0 extends to dense models as well.

`unsloth/...-bnb-4bit` checkpoints are pre-quantized to NF4 4-bit and serve mainly as starting points for QLoRA fine-tuning. After training, a single call to `save_pretrained_gguf()` produces a GGUF file for llama.cpp.

### The Realistic Path from Unsloth to vLLM Serving

Honesty matters here. Of the formats Unsloth produces, relatively few are immediately suitable for vLLM production serving. bitsandbytes NF4 can be loaded in vLLM but delivers low throughput (shape errors have been reported on some models). Dynamic UD-GGUF is a llama.cpp-only format not covered in vLLM's official documentation, and vLLM's GGUF support itself is explicitly marked "highly experimental" ([vLLM GGUF](https://docs.vllm.ai/en/latest/features/quantization/gguf/)).

The practical production path is therefore: **fine-tune with Unsloth, re-quantize for serving**.

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
<div class="d3-arch" data-arch-root id="zationvllmservingunsloth-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 472, "height": 570, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 166, "y": 24, "w": 156, "h": 62, "title": ["Unsloth QLoRA", "NF4 4-bit training"]}, {"id": "B", "x": 184, "y": 164, "w": 120, "h": 62, "title": ["LoRA merge", "merged_16bit"]}, {"id": "C1", "x": 284, "y": 304, "w": 156, "h": 78, "title": ["Local/small-scale:", "GGUF Q4_K_M", "Ollama·llama.cpp"]}, {"id": "C2", "x": 24, "y": 304, "w": 205, "h": 78, "title": ["Production vLLM:", "W4A16/FP8 re-quantization", "llm-compressor"]}, {"id": "D", "x": 49, "y": 460, "w": 156, "h": 78, "title": ["vllm serve", "compressed-tensors", "auto-detected"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [244, 86, 244, 164]}, {"src": "B", "dst": "C1", "kind": "data", "curve": [[296, 226], [362, 265], [362, 265], [362, 304]]}, {"src": "B", "dst": "C2", "kind": "data", "curve": [[192, 226], [127, 265], [127, 265], [127, 304]]}, {"src": "C2", "dst": "D", "kind": "data", "line": [127, 382, 127, 460]}]});
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
      const container = document.getElementById('zationvllmservingunsloth-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'zationvllmservingunsloth-1';
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

```python
# Unsloth: merge LoRA to 16-bit after QLoRA training
model.save_pretrained_merged("merged_model", tokenizer, save_method="merged_16bit")
# Then re-quantize with the llm-compressor W4A16/FP8 recipe above and serve with vLLM
```

For local or experimental serving, using Unsloth's Dynamic GGUF with Ollama or llama.cpp is perfectly reasonable -- the accuracy and convenience are both solid. For multi-user production serving, merging first and re-quantizing to W4A16 or FP8 gives you better throughput with vLLM.

## Cost and Observability

Quantization reduces cost but it is not free. Three things must be tracked together: memory savings (fitting a larger model or longer context on the same card), throughput (whether the Marlin kernel is active determines tokens per second), and accuracy (per-task regression must be measured). After deployment, monitor token throughput, TTFT, and per-card memory usage via vLLM metrics, and run your core evaluation sets before and after quantization to catch regression.

## ThakiCloud's Perspective: Why This Summary Was Needed

ThakiCloud's AI platform runs on Kubernetes, schedules GPU workloads with Kueue, and serves models with vLLM. Our agent platform Paxis calls a self-hosted vLLM backend (codename Metis) through an OpenAI-compatible API. Quantization choices directly affect our per-token serving cost.

The operational reality is a heterogeneous hardware fleet. NVFP4 is optimal on Blackwell (B200), but that path is closed on Hopper and Ampere nodes. So we route quantization by hardware tier: Blackwell gets NVFP4 or FP8 block-wise; Hopper gets FP8 and W4A16; Ampere gets AWQ/GPTQ W4A16. Unifying everything under compressed-tensors means vLLM auto-detects the format, so serving code barely changes across tiers. Domain fine-tuning is done cheaply with Unsloth, then merged and re-quantized to W4A16 or FP8 for production serving -- that is our standard path.

The advantage is clear. In on-premises and self-hosting environments, data never leaves the cluster, and we can extract the lowest possible serving cost for whatever GPU generation a customer happens to own. Quantization is not just compression -- it is the central lever for the cost efficiency we offer.

## Summary

- The vLLM production 4-bit standard is W4A16 (AWQ/GPTQ) running on the Marlin kernel.
- For a single unified toolchain, llm-compressor + compressed-tensors is the smoothest option (auto-detected).
- For MoE models, FP8 block-wise is the first choice; fall back to W4A16 if memory is constrained.
- Unsloth excels at fine-tuning and high-accuracy Dynamic quantization, but the realistic path to vLLM production serving is to merge first and re-quantize to W4A16 or FP8.

## Further Reading

- vLLM quantization docs: [docs.vllm.ai](https://docs.vllm.ai/en/latest/features/quantization/)
- llm-compressor: [github.com/vllm-project/llm-compressor](https://github.com/vllm-project/llm-compressor)
- Unsloth Dynamic 2.0: [unsloth.ai/blog/dynamic-v2](https://unsloth.ai/blog/dynamic-v2)
- ThakiCloud Paxis: [github.com/ThakiCloud/praxis](https://github.com/ThakiCloud/praxis)
