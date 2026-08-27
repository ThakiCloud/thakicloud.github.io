---
title: "Measuring the World With a Ruler That Has Sixteen Marks: Quantization Made Easy"
seo_title: "LLM Quantization Explained Simply - GGUF, MLX, NVFP4 and Unsloth Dynamic 3.0 | ThakiCloud"
seo_description: "One analogy that carries all the way through what quantization is, how GGUF, MLX, NVFP4 and MXFP4 actually differ, and which format belongs on which hardware. Includes the four-bit-storage-but-sixteen-bit-compute trap and our own measurements on B200 and H200."
excerpt: "Four bits means measuring a number with a ruler that has sixteen marks. But if your GPU cannot read four bits, it unpacks every weight back to sixteen bits before each multiply. That fork, not the format name, decides your speed."
date: 2026-08-27
tags:
  - quantization
  - GGUF
  - MLX
  - NVFP4
  - MXFP4
  - FP8
  - AWQ
  - GPTQ
  - Unsloth
  - inference-optimization
  - LLMOps
  - beginner
header:
  teaser: /assets/images/quantization-easy-guide-hero.webp
categories: [llmops]
author_profile: true
toc: true
toc_label: "Contents"
toc_sticky: true
reading_time: true
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/quantization-easy-guide/"
---

If you have ever gone to download a model and found a wall of labels like `Q4_K_M`, `UD-IQ2_M`, `NVFP4`, `MXFP4`, `AWQ` and `4bit-DWQ` with no idea which one to click, this article will hand you a way to read that list. Here is the conclusion first. **The real fork in quantization is not how many bits, but whether your hardware knows how to read those bits.** The same four-bit file runs 1.28x faster on one GPU and 0.81x slower on another. Those are our own measurements, and the numbers appear later in this piece.

![Conceptual illustration of quantization: rewriting billions of numbers with a ruler that has only sixteen marks]({{ '/assets/images/quantization-easy-guide-hero.webp' | relative_url }})
*Four bits is a ruler with sixteen marks. Why that still produces usable results is the first half of this article.*

## Making the Heavy Books Thinner

In our [earlier piece on speculative decoding](/tech-blog/en/llmops/speculative-decoding-easy-guide/) we compared a large language model to a library. To write a single character the teacher has to haul several hundred very heavy books out of the stacks and spread them across the desk, and the actual reading takes an instant. Nearly all the time goes into moving the books.

Speculative decoding attacked how **often** you pull the books out. Quantization attacks the other side. **It makes the books themselves thinner.**

Thinner buys three things. More books fit in the stacks, so a model that did not fit on one GPU now does, and the leftover room takes more concurrent users. Moving them takes less time, so if a book is half as thick the trip is roughly half as long and characters come out faster. The third one is conditional. **If you can read the book while it is still thin**, the reading gets faster too. That third one is the one that most often fails to happen, and half of this article is about it.

## A Ruler With Sixteen Marks

A model's weights are, in the end, a few billion numbers. How finely you measure each one before writing it down is what quantization decides.

Sixteen bits gives you roughly sixty-five thousand marks to choose from. Eight bits gives you 256. Four bits gives you **sixteen**. Here is the complete set of values the four-bit floating point format E2M1 can represent.

```
0, 0.5, 1, 1.5, 2, 3, 4, 6   (and the negative of each)
```

That is the whole ruler. Eight positive values and eight negative ones. The first time you see it, the idea that a language model runs on this is hard to accept. With only that ruler, it does not.

## So You Re-Fit the Ruler for Every Neighborhood

This is the heart of four-bit quantization, and it decodes half the labels on its own.

Suppose you have to measure people's height with a ruler that has sixteen marks. Covering adults and newborns with the same ruler means the marks sit so far apart that nothing gets measured properly. But measuring **a single third-grade classroom** changes the problem. Those children are between 130 and 145 centimeters, so dividing just that range into sixteen gives you roughly centimeter resolution.

That is exactly the trick. Weights get grouped a few dozen at a time, and **each group stores its own scale**. Values inside a group are close to one another, so sixteen marks separate them well enough.

Two questions remain: how many values per group, and at what precision do you record the scale. **The difference between NVFP4 and MXFP4 is precisely those two answers.**

MXFP4 comes from the OCP microscaling standard. It groups **32 values** and records the scale as E8M0, which has an exponent and no mantissa, so it expresses **powers of two only**. Two, four and eight are available; 1.5 is not. NVIDIA's NVFP4 groups **16 values**, a finer cut, and records the scale as FP8 E4M3, so awkward multipliers like 1.5x and 2.5x are on the table. It then layers an FP32 scale across the whole tensor on top. Fit a ruler per neighborhood, then fit one more for the whole city.

The price is size. Attaching an eight-bit scale to every sixteen values adds half a bit per value, so NVFP4 is called four bits and costs an effective 4.5. No precision is free.

## Weights Are Easy, Today's Ingredients Are Hard

There is one more layer to peel. Two kinds of numbers get multiplied inside a model.

**Weights** are fixed once training ends. They are like a recipe the cook has memorized, so you can study them at leisure and pick an optimal ruler in advance. **Activations** are recomputed every time depending on what the user typed. They are the ingredients that arrived this morning, and you cannot inspect them ahead of time.

Occasionally something unusually large arrives among those ingredients. These are called outliers, and a channel can come in around twenty times larger than its neighbors. The damage is that the scale stretches to cover that one big value and **every ordinary value collapses into the same bucket**. One three-meter-tall person in the classroom and every child's height gets recorded as zero marks.

Hence the notation. `W4A16` means weights down to four bits with activations left at sixteen. `W8A8` puts both at eight, `W4A4` puts both at four. Each step is harder than the last.

Methods for handling outliers followed. SmoothQuant applies a mathematically equivalent transform that **pushes the difficulty out of the activations and into the weights**, which can absorb it because you get to look at them in advance. QuaRot and SpinQuant go further and apply an output-preserving rotation that **spreads the outliers evenly across many channels**, trading one three-meter person for several slightly tall ones. That rotation is what brought W4A4, four bits on both sides, into practical range.

## Measure Only What Matters, Finely

The other big idea is this. **Not every layer matters equally.**

Some layers can be crushed to four bits with almost no change in the output. Others start producing nonsense the moment you touch them. So the win goes to whoever keeps the important layers precise and cuts hard everywhere else. Most current methods are, in effect, competing over how to find out which layers those are.

llama.cpp's **importance matrix (imatrix)** is the most direct answer. It runs representative text through the model, measures how much each weight influences the output, and feeds that into the quantizer. Formats with `IQ` in the name were designed assuming this matrix exists, and quality visibly collapses if you build them without one.

**GPTQ** quantizes one weight and then **compensates for the resulting error by adjusting the remaining weights**, using second-order information to solve "we lost this much rounding that value, so shift the neighbor to make it up." **AWQ** looks at activation distributions instead, finds the top one percent of channels that fire large most often, and protects only those. It overfits its calibration set less, so it travels to other domains better. **HQQ** skips calibration data entirely and works from the weight distribution alone, quantizing a 70B model in five minutes.

**Unsloth Dynamic** pushes the idea to the file level. It assigns different bit widths per layer and recomputes that assignment per model. The `UD-` prefix on a filename is the marker. Dynamic 3.0, released in August 2026, says it widened its calibration sources to include agentic coding and multilingual conversation.

One warning in the Unsloth documentation deserves attention. **Do not use the one-bit files for agents or tool calling.** There is a cliff below two bits where accuracy falls away sharply, and that cliff shows up in call-a-tool-and-read-the-result work before it shows up in short question answering. If the smallest file looked appealing and your agent then started behaving strangely, this is usually why.

MLX on the Mac sits on the same trend. `mlx_lm.dwq` takes the original model as a teacher and **distills only the parameters that do not get quantized, meaning the scales and biases.** Rather than fitting the ruler by a fixed rule, it learns the marks, which cuts the loss at the same four bits. `mlx_lm.dynamic_quant` measures per-layer sensitivity and allocates bits automatically.

## Do Not Trust the Label

This is where practitioners trip. Seeing `Q4_K_M` you naturally read "ah, four bits." **It is not.**

We once [opened a Qwen2.5-0.5B Q4_K_M file and counted it tensor by tensor](/tech-blog/en/llmops/gguf-quantization-internals/). The genuinely four-bit Q4_K tensors accounted for **6.1 percent** of the file, and the effective bit width of the whole file was not 4 but **6.16**. The rest was eight-bit and six-bit tensors plus normalization parameters left at full 32. The label is closer to a recipe name than a bit count.

The same effect is visible in the repository that prompted this article. Unsloth's [GGUF build of Qwen3.8-Flash-Next](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF) offers seven UD variants, and the smallest one-bit file is 72.5GB while the largest four-bit file is 111GB. **The bit counts differ fourfold and the sizes differ by 1.5x.** The one-bit label does not mean every weight was crushed to one bit. It means "the most aggressive mix."

So when picking a file, do not infer size from the number in the label. **Read the file size that is printed.** Whether that number fits your RAM is the question you actually need answered.

## The Fork That Matters Most: Storage or Compute

Now the most important part. Miss this and the rest of the knowledge spins in place.

Storing weights in four bits does not mean the arithmetic happens in four bits. In most cases the GPU **unpacks those four bits back to sixteen** immediately before the multiply. That unpacking is itself computation, so it is not free.

Back to the library. You vacuum-sealed the books flat and shelved them. Hauling got easier. But to read one at the desk you have to unseal it back to full thickness every time. **Carrying time went down and unsealing time appeared.**

For that to be a net win, a condition has to hold. When hauling is the bottleneck, meaning few concurrent users and idle compute, you come out ahead. When users pile in and the GPU is already saturated with arithmetic, the unsealing lands on top of that saturated arithmetic and you lose.

**Real four-bit compute is different.** If the GPU contains circuitry that multiplies four-bit numbers while they are still compressed, no unpacking is needed. Hauling drops and arithmetic speeds up. That circuitry is the tensor core, and **which generation ships tensor cores for which precision is the central table of this article.**

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="827quantizationeasyguide-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 683, "height": 666, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 254, "y": 24, "w": 198, "h": 46, "title": "Weights stored in 4 bits"}, {"id": "B", "x": 252, "y": 148, "w": 202, "h": 68, "title": ["Does this GPU have FP4", "tensor cores"]}, {"id": "C", "x": 377, "y": 308, "w": 198, "h": 62, "title": ["Unpack to 16 bits before", "the multiply"]}, {"id": "D", "x": 38, "y": 308, "w": 170, "h": 62, "title": ["Multiply while still", "compressed"]}, {"id": "E", "x": 516, "y": 456, "w": 135, "h": 46, "title": "Memory is saved"}, {"id": "F", "x": 277, "y": 456, "w": 184, "h": 46, "title": "Unpacking work appears"}, {"id": "G", "x": 270, "y": 588, "w": 198, "h": 46, "title": "Slower than FP8 at 0.81x"}, {"id": "H", "x": 24, "y": 448, "w": 198, "h": 62, "title": ["Memory saved and compute", "faster"]}, {"id": "I", "x": 59, "y": 588, "w": 128, "h": 46, "title": "1.28x over FP8"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [353, 70, 353, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "No H200 Ada", "curve": [[406, 216], [476, 262], [476, 262], [476, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Yes B200 RTX50", "curve": [[255, 216], [123, 262], [123, 262], [123, 308]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "curve": [[524, 370], [584, 409], [584, 409], [584, 456]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[429, 370], [369, 409], [369, 409], [369, 456]]}, {"src": "F", "dst": "G", "kind": "data", "line": [369, 502, 369, 588]}, {"src": "D", "dst": "H", "kind": "data", "line": [123, 370, 123, 448]}, {"src": "H", "dst": "I", "kind": "data", "line": [123, 510, 123, 588]}]});
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
      const container = document.getElementById('827quantizationeasyguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '827quantizationeasyguide-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

*The same four-bit file takes one of these two paths, and that decides the speed. The left path saves memory and loses time.*

Telling the two apart is worth knowing. Look at which kernel your serving engine actually called. If it lands on a general matrix-multiply kernel like `aten.mm.default`, it is unpacking to compute. If an FP4-specific kernel name appears, it is multiplying compressed. We hold a rule that **no FP4 speed number gets quoted without kernel-path evidence from the same run**, because we fell into this trap repeatedly.

One more place to watch. Quantizing in PyTorch with NVIDIA's Model Optimizer produces a **simulation**. NVIDIA's own documentation states this directly: it only simulates the low-precision computation. It is for checking accuracy, and the actual speed and memory gains arrive only after export to TensorRT-LLM or vLLM. If you measured in PyTorch and wondered why four bits did not get faster, this is why.

## So Which GPU Reads Which Ruler

Here is the table people find most confusing. Whether a precision can be **stored** and whether it can be **multiplied** are different questions, and this one is about multiplying.

| Hardware | FP8 tensor cores | FP4 tensor cores |
|---|---|---|
| RTX 4090, L40S (Ada) | yes | no |
| H100, H200 (Hopper) | yes | **no** |
| B200, GB200 (Blackwell datacenter) | yes | yes |
| RTX 50 series (Blackwell consumer) | yes | yes |
| AMD MI300X (CDNA3) | yes | no |
| AMD MI355X (CDNA4) | yes | yes (MXFP4) |
| Apple M1 through M4 | no | no |
| CPU | no | no |

The cell most often misread is **H100 and H200**. A large share of the GPU servers running today are that generation, and because they are excellent modern hardware it is easy to assume FP4 comes along for the ride. It does not. FP4 tensor cores start at Blackwell.

So what happens when you put a four-bit model on an H200? Memory savings are real. But every multiply unpacks first, so you pay the unsealing cost described above. **It ends up slower than FP8.**

## Three Things That Surprised Us When We Measured

That last paragraph is not inference, it is measurement. We put Qwen3-Coder-30B-A3B on the same engine (vLLM 0.27.1) and changed only the GPU. The figures are medians across the concurrency 32 to 128 band.

**The first surprise was that four bits lost.** On H200, weight-only W4A16 came in at 0.81x to 0.84x of FP8. We built and served a four-bit file and it ran slower than eight-bit.

**The second was stranger.** Moving the same W4A16 to newer hardware, a B200, should help. **It gets worse.** The ratio falls from 0.76x to 0.67x. Thinking it through, this is inevitable. The faster the low-precision tensor cores get, the further behind a path that ignores them and unpacks instead falls. **Using four bits wrongly costs more on newer silicon, not less.**

On the same B200, running NVFP4 properly gives 1.22x to 1.28x over FP8. Same four-bit family, and W4A16 sits at 0.67x while NVFP4 sits at 1.28x. **Nearly a factor of two decided by the kernel path, not the format name.**

**The third surprise was on quality.** MXFP4 scored higher than NVFP4 on HumanEval (0.9268 versus 0.9024). But it ran at 0.66x to 0.74x of NVFP4's speed. Both reached a native FP4 kernel on the B200, just not the same one: NVFP4 gets TensorRT-LLM's fused MoE kernel and MXFP4 gets a CUTLASS path. **Kernel maturity decided it, not the numeric format**, which means this particular gap could invert later.

| On B200, versus FP8 (concurrency 32/64/128) | Throughput ratio | HumanEval |
|---|---|---|
| NVFP4 | 1.28 / 1.26 / 1.22 | 0.9024 |
| MXFP4 | 0.84 / 0.89 / 0.90 | 0.9268 |
| W4A16 (weight-only four bits) | 0.76 / 0.71 / 0.67 | 0.9268 |

**And the real prize turned out to be power, not throughput.** In a separate experiment we put bf16 and NVFP4 head to head at saturation. Throughput was effectively tied (23,415 versus 23,771 tok/s, a 1.5 percent gap) while power split at 500W versus 867W. Per token of energy that is **1.71x**. For anyone renting GPUs, that number enters the cost model more directly than a throughput multiple does.

One honest addition. **The largest throughput lever we found in the same period was not quantization.** Fixing two serving settings moved single-stream throughput by 18.77x. `torch.compile` was off and the concurrent-request limit was pinned at a default of 32. While format debates argue over 1.2x and 1.3x, one setting moved eighteen. **Check your baseline configuration before you touch quantization.**

## On a MacBook

The Mac is a different story entirely. GPU memory and system memory are the same pool, so a 128GB Mac can hold a 128GB model outright. A GPU server at the same price cannot come close, which is why Macs are strong for local experimentation.

The ceiling is bandwidth instead. Every character generated requires reading all the weights again, so **how many gigabytes per second you can read very nearly sets how many characters per second you get.** The M4 Pro does 273GB/s, the M4 Max does 410GB/s or 546GB/s depending on configuration, and the M3 Ultra does 819GB/s. Dropping to four bits means reading less, which is why quantization almost always wins on a Mac.

Formats split two ways. **GGUF** is the file format of the llama.cpp ecosystem, and Ollama and LM Studio both consume it. It runs on CPU and on Windows and Linux, so portability is unmatched. **MLX** is Apple's own framework, Mac-only in exchange for being tuned to the Mac. Measured comparisons report MLX ahead by 1.4x to 1.6x on dense models during generation and up to 3x on MoE models. Prompt ingestion is a different matter, where llama.cpp can lead, so if your pattern is many short fresh conversations the gap narrows.

One thing changed in 2026. **From the M5, each GPU core carries a dedicated matrix unit called a Neural Accelerator.** Apple's own measurements put time to first token at 3.33x to 4.06x versus the M4. Calibrate the expectation carefully though. **Generation speed itself improved only 1.19x to 1.27x**, and Apple's document explains why: generation is bound by memory bandwidth rather than compute, and the M5's bandwidth rose from the M4's 120GB/s to 153GB/s, which is 28 percent. The gain matches the bandwidth gain almost exactly.

One clarification is worth making. Apple does **not** state that this unit accelerates block-scaled FP4 in hardware. It published measurements from running an MXFP4 model. Saying "Macs have FP4 tensor cores now" goes further than the evidence.

The practical recommendation is simple. For Mac-only use, **MLX at four bits** is the balance point. To squeeze more quality, build the four-bit with `mlx_lm.dwq`; with RAM to spare, go to six or eight bits. If you share files with other operating systems or need CPU execution, use GGUF. For sizing, four-bit puts a 7B around 4 to 5GB, a 30B around 20GB, and a 70B around 40 to 48GB.

## On a Server

Serving many concurrent users adds one more criterion: **small batch or large batch.**

At small batch the GPU has compute to spare and only memory is straining, so moving fewer weight bytes is itself the win. Weight-only four-bit like AWQ or GPTQ works well here. As batch grows the GPU fills with arithmetic, the unpacking cost starts to hurt, and the right answer becomes a format that **lowers both weights and activations**. On Hopper that is FP8; on Blackwell it goes to NVFP4. NVIDIA's own selection guide recommends W4A16 below batch 4 and W8A8 at 16 and above.

Tooling has settled reasonably. In the vLLM world, quantize with `llm-compressor`, export to the `compressed-tensors` format, and vLLM reads it directly. AWQ, GPTQ, bitsandbytes, AMD Quark and torchao are all supported too.

```bash
# Build an FP8 W8A8 checkpoint with llm-compressor (conceptual)
pip install llmcompressor
# apply QuantizationModifier(scheme="FP8_DYNAMIC") in the recipe, then run oneshot

# Serve with vLLM
vllm serve <path-to-quantized-model> \
  --max-num-seqs 256 \
  --max-model-len 32768
```

`--max-num-seqs` is spelled out deliberately. Half of that 18.77x incident was this value. Pinned at its default, no amount of incoming concurrency opens the ceiling.

After starting up, check the **kernel name** in the logs. If a four-bit model is loaded and a general matrix-multiply kernel is being called, you are saving memory and losing speed. Benchmarking in that state and concluding "four bits is not worth it" gets you the wrong answer.

## Does Quality Actually Drop

Honestly: **our benchmarks cannot see a difference, and that is not a reason to relax.**

In the hardware comparison above, all five arms landed within four HumanEval problems of one another. The benchmark's resolution is 0.61 percentage points per problem, and rerunning an identical configuration moves it about that much anyway. On Qwen3-30B-A3B our NVFP4 scored MMLU 0.7743 against bf16's 0.7779, statistically indistinguishable.

The problem is that these benchmarks are **short exchanges**. A 2025 EMNLP study evaluated five quantization methods across several models and reported that eight-bit loses around 0.8 percent, effectively nothing, while **four-bit lost up to 59 percent on long-context tasks, with the loss growing as context lengthened.** A separate study of reasoning found a difficulty-proportional pattern: at W4A4, GSM8K lost nothing while AIME dropped 4.17 percent. Easy problems survive the crushing; hard ones start failing first.

Multilingual remains contested. One study finds automatic metrics look mild while human evaluation registers a much larger drop; another finds English-calibrated K-quants do not disproportionately harm other languages. That is unsettled, so we will not write it as settled.

Our position follows. **Failing to find a loss is not the same as there being none.** That is why the top priority for our next quarter of quantization work is not measuring a new format but **standing up one control arm.** If you cannot trust the ruler, everything measured with it wobbles. On your side, if you are going to run four bits, measure it yourself **on your own workload, specifically on long context and hard reasoning.**

## The Order to Decide In

Compressed into a decision sequence, it is four steps.

**First, settle where it runs.** Mac means MLX or GGUF, anything involving CPU means GGUF, an NVIDIA server means checking that GPU's generation. This alone eliminates half the candidate formats.

**Second, pick a format with a native path on that hardware.** Blackwell means NVFP4; Hopper and Ada mean FP8. If the batch is small and memory is tight, weight-only four-bit like AWQ or GPTQ enters the picture. **Choosing four bits on Hopper means buying memory, not speed**, and you should make that choice knowingly.

**Third, confirm size from the file size.** We saw above that `Q4` does not mean four bits.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="827quantizationeasyguide-2"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 747, "height": 638, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "S", "x": 398, "y": 24, "w": 149, "h": 46, "title": "Where will it run"}, {"id": "M", "x": 595, "y": 148, "w": 120, "h": 46, "title": "Mac"}, {"id": "P", "x": 405, "y": 148, "w": 135, "h": 46, "title": "CPU is involved"}, {"id": "N", "x": 224, "y": 148, "w": 121, "h": 46, "title": "NVIDIA server"}, {"id": "M1", "x": 595, "y": 275, "w": 120, "h": 46, "title": "MLX 4-bit"}, {"id": "P1", "x": 413, "y": 275, "w": 120, "h": 46, "title": "GGUF"}, {"id": "N1", "x": 212, "y": 272, "w": 146, "h": 52, "title": "GPU generation"}, {"id": "B1", "x": 317, "y": 419, "w": 120, "h": 46, "title": "NVFP4"}, {"id": "H1", "x": 124, "y": 416, "w": 138, "h": 52, "title": "Batch size"}, {"id": "H2", "x": 199, "y": 560, "w": 205, "h": 46, "title": "AWQ or GPTQ buying memory"}, {"id": "H3", "x": 24, "y": 560, "w": 120, "h": 46, "title": "FP8"}], "edges": [{"src": "S", "dst": "M", "kind": "data", "curve": [[540, 70], [655, 109], [655, 109], [655, 148]]}, {"src": "S", "dst": "P", "kind": "data", "line": [473, 70, 473, 148]}, {"src": "S", "dst": "N", "kind": "data", "curve": [[403, 70], [285, 109], [285, 109], [285, 148]]}, {"src": "M", "dst": "M1", "kind": "data", "line": [655, 194, 655, 275]}, {"src": "P", "dst": "P1", "kind": "data", "line": [473, 194, 473, 275]}, {"src": "N", "dst": "N1", "kind": "data", "line": [285, 194, 285, 272]}, {"src": "N1", "dst": "B1", "kind": "data", "label": "Blackwell", "curve": [[318, 324], [377, 370], [377, 370], [377, 419]], "off": "50%"}, {"src": "N1", "dst": "H1", "kind": "data", "label": "Hopper Ada", "curve": [[252, 324], [193, 370], [193, 370], [193, 416]], "off": "50%"}, {"src": "H1", "dst": "H2", "kind": "data", "label": "Small", "curve": [[232, 468], [302, 514], [302, 514], [302, 560]], "off": "50%"}, {"src": "H1", "dst": "H3", "kind": "data", "label": "Large", "curve": [[153, 468], [84, 514], [84, 514], [84, 560]], "off": "50%"}]});
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
      const container = document.getElementById('827quantizationeasyguide-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '827quantizationeasyguide-2';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

*Walk down this instead of memorizing format names. There are only three forks.*

**Fourth, verify the kernel path and the quality before concluding anything.** Read the kernel name from the logs, and measure with the longest context and hardest task in your actual workload.

## Wrapping Up

Quantization in one sentence: **rewrite the numbers with a coarser ruler, then re-fit the ruler per neighborhood so the coarseness does not show.** That much is a decade-old idea, and today's competition is over which neighborhood gets how fine a ruler. imatrix, GPTQ, AWQ, Unsloth Dynamic and MLX DWQ are all different answers to that one question.

In practice, though, what decides the outcome is not those answers but **the fit with your hardware**. The same four bits become 1.28x on a B200 and 0.81x on an H200. Memorizing format names pays less than carrying two questions: does my GPU have tensor cores for this precision, and is the engine actually calling that kernel.

The trend is worth noting. Early on every vendor shipped its own format; now things are converging on the OCP microscaling spec. AMD's newest accelerator carries the same MXFP4 natively, and OpenAI shipped gpt-oss with MXFP4 weights outright. Apple has begun adding matrix units as well. In a few years "does this format work on this chip" should hurt less than it does today. Until then, and especially on the Hopper-generation hardware widely deployed right now, checking this table before you choose is worth several multiples.

A large part of what our inference product **Metis** does is making sure tenants never have to make this call themselves. Which format goes on which GPU generation, and which serving settings send the kernel down the right path, is repetitive work once it has been decided properly a single time. And the property described above, that four bits fails first on hard reasoning, matters especially for **Paxis**. An agent calls a tool, reads the result and judges again within a single request, and that judgment is exactly the kind of difficulty benchmarks are poor at catching. Lowering bits to save cost and having an agent quietly get worse is the hardest failure to notice.

Every measurement of ours cited here came from in-house B200 and H200 machines on the same engine, recorded with its conditions in our ledger. For the deeper per-format story, see [The Same Four Bits Land on Opposite Sides of FP8](/tech-blog/en/llmops/nvfp4-vs-fp8-two-four-bits/) and [There Was Almost No Q4 Inside Q4_K_M](/tech-blog/en/llmops/gguf-quantization-internals/).
