---
title: "iTool: Reinforced Fine-Tuning with Dynamic Deficiency Calibration for Advanced Tool Use"
excerpt: "An in-depth analysis of iTool, an innovative reinforced fine-tuning methodology that addresses the diminishing training effectiveness of synthetic tool-use data"
seo_title: "iTool Reinforced Fine-Tuning Research: Improving LLM Tool Use Capability - Thaki Cloud"
seo_description: "Analysis of the iTool research paper jointly developed by Harbin Institute of Technology and Huawei. Achieves 13% improvement in LLM tool use performance through MCTS-based path search and preference optimization"
date: 2025-08-21
last_modified_at: 2025-08-21
tags:
  - iTool
  - reinforcement-learning
  - fine-tuning
  - tool-use
  - LLM
  - MCTS
  - preference-optimization
  - harbin-institute-of-technology
  - huawei
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/itool-reinforced-fine-tuning-tool-use-research/"
lang: en
reading_time: true
published: false
categories:
  - research
---

⏱️ **Estimated reading time**: 12 min

## Introduction

The ability of large language models (LLMs) to use external tools has emerged as a critical capability for building practical AI systems. By calling APIs, querying databases, and interacting with external services, models can overcome their inherent knowledge cutoff and solve real-world tasks that pure text generation cannot address.

The dominant approach to teaching tool use has been supervised fine-tuning (SFT) on synthetically generated datasets. Research teams collect or construct examples of correct tool-calling behavior, then train models to imitate those examples. While this approach has shown early promise, it runs into a fundamental ceiling: as the training data grows larger, the marginal improvement in model capability diminishes. The model learns to reproduce surface patterns in the synthetic data rather than developing a robust, generalizable understanding of when and how to invoke tools correctly.

This is the problem that the iTool research addresses. Developed jointly by the Harbin Institute of Technology SCIR Lab, Huawei Technologies, and Huawei Noah's Ark Lab, iTool proposes a reinforced fine-tuning framework that goes beyond imitation learning. The paper is available on arXiv as arXiv:2501.09766.

## Existing Problems

### Diminishing Training Effectiveness

Standard SFT on synthetic tool-use data faces a saturation effect. As the dataset size increases from tens of thousands to hundreds of thousands of samples, the performance gains on held-out benchmarks become progressively smaller. The model is essentially memorizing the training distribution rather than learning to reason about tool use.

This phenomenon becomes especially pronounced in complex, multi-step scenarios. When a task requires chaining multiple tool calls, handling ambiguous parameters, or recovering from intermediate errors, SFT-trained models frequently fail. They can produce plausible-looking but incorrect tool calls because they have learned to pattern-match rather than to reason about the underlying task structure.

### The Fragment Deficiency Concept

A central insight of the iTool paper is the concept of Fragment Deficiency. In standard SFT, the model is trained to reproduce complete, correct tool-calling sequences. However, a model that makes a partially correct call, one that gets the function name right but specifies the wrong parameter values, receives no credit and no targeted feedback. The gradient signal treats the entire response as incorrect, even though the model demonstrated partial competence.

Fragment Deficiency refers to this gap: the model has localized weaknesses in specific components of tool-calling behavior (parameter value generation, type inference, semantic grounding), but the training signal is too coarse to address them individually. Over many training iterations, these localized deficiencies persist and limit the model's overall capability ceiling.

### Complex Scenario Limitations

Beyond the Fragment Deficiency problem, SFT-trained models struggle with scenarios that require composing multiple tool calls in a coherent sequence. Real-world tool use often involves conditional logic: call tool A, observe the result, then decide whether to call tool B or tool C. Static imitation learning cannot equip models for this kind of dynamic reasoning.

## iTool Methodology

iTool addresses these problems through three interlocking components: an easy-to-hard warmup SFT stage, an MCTS-based path search mechanism, and an iterative reinforced fine-tuning loop with preference optimization.

### Easy-to-Hard Warmup SFT

Before entering the reinforced fine-tuning loop, the model undergoes a warmup phase using conventional SFT. Crucially, this warmup is structured as an easy-to-hard curriculum. The training data is sorted by task complexity, and the model is exposed first to simpler single-tool scenarios before progressing to complex multi-tool chains.

This curriculum design serves two purposes. First, it establishes a competent baseline that is strong enough to benefit from subsequent reinforced fine-tuning. Second, it ensures that the model has a solid foundation in tool-calling syntax and semantics before it is asked to explore harder scenarios through MCTS.

### MCTS-Based Path Search

The core of iTool's approach is using Monte Carlo Tree Search (MCTS) to generate diverse tool-calling trajectories for complex tasks. Given a complex prompt, the model uses MCTS to explore multiple possible response paths. Each node in the search tree corresponds to a partial tool-calling sequence, and the tree is expanded by sampling possible next steps from the model's current distribution.

Each terminal node (a complete tool-calling sequence) is assigned a Q-value based on a reward function that evaluates the correctness of the tool call. This reward function is multi-dimensional, capturing function name accuracy, parameter count correctness, parameter name accuracy, and parameter value and type correctness. Semantic similarity is also factored in to handle cases where the model produces semantically equivalent but syntactically different responses.

The MCTS search produces a collection of diverse trajectories for each complex prompt, ranging from high-quality correct calls to various types of errors. This diversity is precisely what makes the subsequent preference optimization effective.

### Iterative Reinforced Fine-Tuning

From the MCTS-generated trajectories, iTool constructs preference pairs: a chosen response (higher Q-value trajectory) and a rejected response (lower Q-value trajectory). These pairs are used to train the model with preference optimization methods, specifically DPO (Direct Preference Optimization) and SimPO (Simple Preference Optimization).

This process is iterative. After each round of preference optimization, the updated model is used to generate new MCTS trajectories on the complex data subset that has not yet been mastered. The loop continues until convergence, at which point the model has been systematically calibrated on its specific deficiency areas rather than trained uniformly on the entire dataset.

This iterative calibration is the mechanism that addresses Fragment Deficiency. Because the MCTS trajectories explicitly surface the partial errors that the model makes (wrong parameter values, wrong types, missing parameters), the preference pairs provide fine-grained gradient signal that targets those specific weaknesses. The model receives credit for what it gets right and corrective signal for what it gets wrong at the component level.

## Experiment Design

### ToolACE Dataset

The experiments use the ToolACE dataset, which contains up to 100,000 synthetic tool-use samples covering a wide range of API categories. The dataset includes examples that span simple single-function calls through complex multi-step tool chains.

Two representative dataset examples illustrate the range of difficulty:

**Get Trending Result**: A simpler task asking the model to retrieve trending content from a specified platform. The correct call requires specifying the function name and a small number of parameters with clear semantics.

**Complex Analysis Task**: A harder task requiring the model to combine multiple tool calls, handle intermediate results, and apply conditional logic based on observed outputs. These tasks exercise the model's ability to reason about tool composition and error recovery.

### BFCL Benchmark

The primary evaluation benchmark is the Berkeley Function Calling Leaderboard (BFCL), which provides a standardized suite of tool-use tasks across multiple difficulty levels and API categories. BFCL is widely used in the research community for evaluating LLM tool-calling capability.

### Evaluation Criteria

The evaluation framework uses five dimensions to assess tool-calling quality:

1. **Function name accuracy**: Whether the model selects the correct function to call.
2. **Parameter count**: Whether the number of parameters in the call matches the expected count.
3. **Parameter names**: Whether the parameter keys are correctly named.
4. **Parameter values and types**: Whether the parameter values are correct and of the expected type.
5. **Semantic similarity**: A softer measure that evaluates whether the model's response is semantically equivalent to the reference answer even if syntactically different.

### Quality Grades

Based on these five dimensions, responses are classified into four quality grades:

- **Excellent**: All five dimensions are correct.
- **Acceptable**: Minor discrepancies in one or two dimensions that do not affect the functional outcome.
- **Fair**: Errors in parameter values or types that would cause the tool call to fail or produce incorrect results.
- **Poor**: Fundamental errors in function name or parameter structure that render the call unusable.

## Experimental Results

### Overall Performance Improvement

Across the full BFCL benchmark, iTool achieves a 13.11% overall improvement compared to baseline SFT models. This is a substantial gain, particularly given the already competitive baselines that use high-quality synthetic training data.

The improvement is consistent across different difficulty levels in the benchmark, but it is most pronounced on the complex multi-step scenarios that previous SFT approaches struggled with.

### Complex Scenario Gains

On the complex task subset specifically, iTool achieves an additional 6.5% improvement over the overall average gain. This confirms that the MCTS-based exploration and iterative deficiency calibration are most effective precisely in the scenarios where standard SFT falls shortest.

The gap between simple and complex task performance narrows significantly with iTool compared to SFT baselines, indicating that the model has developed more robust compositional reasoning about tool use.

### 8B Model Competing with Larger Models

One of the most significant findings is that an 8B parameter model trained with iTool can match or exceed the performance of substantially larger models trained with conventional SFT. This result suggests that the quality of the training signal, not the quantity of parameters, is the primary constraint on tool-use capability.

This has practical implications: organizations that cannot afford to deploy large models can achieve comparable tool-use performance by investing in better training methodology rather than larger model capacity.

### SimPO Combination Performance

Among the preference optimization methods evaluated, SimPO in combination with iTool's MCTS-based trajectory generation produces the best results. SimPO's simplicity and stability during training make it a good match for the iterative reinforced fine-tuning loop, where the preference data distribution shifts with each round of model updates.

### Ablation Study

The ablation study confirms the contribution of each component:

- Removing the easy-to-hard warmup SFT and starting directly with MCTS-based reinforced fine-tuning degrades performance, showing that a strong baseline is necessary for effective exploration.
- Removing MCTS and using only random sampling for trajectory generation reduces the diversity and quality of preference pairs, leading to smaller performance gains.
- Using a single round of preference optimization rather than iterating to convergence also reduces performance, confirming the value of the iterative calibration loop.

## Learning Process Flow

The following diagram illustrates the complete iTool training pipeline:

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
<div class="d3-arch" data-arch-root id="inetuningtooluseresearch-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1362, "height": 1683, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 316, "y": 24, "w": 265, "h": 707, "label": "MCTS Detail Process", "lx": 328, "ly": 42}, {"x": 600, "y": 24, "w": 730, "h": 140, "label": "Preference Optimization Process", "lx": 612, "ly": 42}], "nodes": [{"id": "A", "x": 59, "y": 71, "w": 121, "h": 46, "title": "Initial Model"}, {"id": "B", "x": 24, "y": 242, "w": 191, "h": 46, "title": "Easy-to-Hard Warmup SFT"}, {"id": "C", "x": 56, "y": 366, "w": 128, "h": 62, "title": ["Complex Data", "Identification"]}, {"id": "D", "x": 92, "y": 506, "w": 184, "h": 46, "title": "MCTS-Based Path Search"}, {"id": "E", "x": 96, "y": 630, "w": 177, "h": 62, "title": ["Diverse Response Path", "Generation"]}, {"id": "F", "x": 106, "y": 809, "w": 156, "h": 46, "title": "Q-Value Evaluation"}, {"id": "G", "x": 117, "y": 933, "w": 135, "h": 62, "title": ["Preference Pair", "Construction"]}, {"id": "H", "x": 106, "y": 1073, "w": 156, "h": 62, "title": ["Chosen Response vs", "Rejected Response"]}, {"id": "I", "x": 92, "y": 1213, "w": 184, "h": 46, "title": "DPO/SimPO Optimization"}, {"id": "J", "x": 124, "y": 1337, "w": 120, "h": 46, "title": "Model Update"}, {"id": "K", "x": 36, "y": 1461, "w": 167, "h": 52, "title": "Check Convergence"}, {"id": "L", "x": 45, "y": 1605, "w": 149, "h": 46, "title": "Final iTool Model"}, {"id": "D1", "x": 369, "y": 71, "w": 120, "h": 46, "title": "Root Node"}, {"id": "D2", "x": 358, "y": 242, "w": 142, "h": 46, "title": "Action Selection"}, {"id": "D3", "x": 417, "y": 374, "w": 120, "h": 46, "title": "Expansion"}, {"id": "D4", "x": 417, "y": 506, "w": 120, "h": 46, "title": "Simulation"}, {"id": "D5", "x": 361, "y": 638, "w": 135, "h": 46, "title": "Backpropagation"}, {"id": "I1", "x": 638, "y": 63, "w": 191, "h": 62, "title": ["Increase Preference for", "Correct Responses"]}, {"id": "I2", "x": 884, "y": 63, "w": 191, "h": 62, "title": ["Decrease Preference for", "Erroneous Responses"]}, {"id": "I3", "x": 1130, "y": 63, "w": 163, "h": 62, "title": ["Fragment Deficiency", "Correction"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [120, 117, 120, 242]}, {"src": "B", "dst": "C", "kind": "data", "line": [120, 288, 120, 366]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[148, 428], [184, 467], [184, 467], [184, 506]]}, {"src": "D", "dst": "E", "kind": "data", "line": [184, 552, 184, 630]}, {"src": "E", "dst": "F", "kind": "data", "line": [184, 692, 184, 809]}, {"src": "F", "dst": "G", "kind": "data", "line": [184, 855, 184, 933]}, {"src": "G", "dst": "H", "kind": "data", "line": [184, 995, 184, 1073]}, {"src": "H", "dst": "I", "kind": "data", "line": [184, 1135, 184, 1213]}, {"src": "I", "dst": "J", "kind": "data", "line": [184, 1259, 184, 1337]}, {"src": "J", "dst": "K", "kind": "data", "curve": [[184, 1383], [184, 1422], [184, 1422], [145, 1461]]}, {"src": "K", "dst": "C", "kind": "data", "label": "No", "curve": [[94, 1461], [55, 1104], [55, 731], [91, 428]], "off": "50%"}, {"src": "K", "dst": "L", "kind": "data", "label": "Yes", "line": [120, 1513, 120, 1605], "lx": 120, "ly": 1555}, {"src": "D1", "dst": "D2", "kind": "data", "line": [429, 117, 429, 242]}, {"src": "D2", "dst": "D3", "kind": "data", "curve": [[447, 288], [477, 327], [477, 327], [477, 374]]}, {"src": "D3", "dst": "D4", "kind": "data", "line": [477, 420, 477, 506]}, {"src": "D4", "dst": "D5", "kind": "data", "curve": [[477, 552], [477, 591], [477, 591], [445, 638]]}, {"src": "D5", "dst": "D2", "kind": "data", "curve": [[412, 638], [380, 529], [380, 397], [410, 288]]}]});
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
      const container = document.getElementById('inetuningtooluseresearch-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'inetuningtooluseresearch-1';
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

The pipeline begins with the initial model entering the easy-to-hard warmup SFT phase. After this warmup, the system identifies complex data points and applies MCTS-based path search to generate diverse response trajectories. These trajectories are evaluated using Q-values, and preference pairs are constructed from chosen and rejected responses. DPO or SimPO optimization then updates the model, and the process iterates until convergence.

The MCTS subprocess (lower left) shows the standard four operations: action selection, expansion, simulation, and backpropagation. The preference optimization subprocess (lower right) shows the three calibration targets: increasing preference for correct responses, decreasing preference for erroneous responses, and correcting localized fragment deficiencies.

## Technical Innovations

### Fragment Deficiency Concept

The introduction of the Fragment Deficiency concept is a meaningful conceptual contribution. Prior work on LLM tool use did not have precise vocabulary for describing the localized, component-level errors that limit model performance. By naming and formalizing this phenomenon, the iTool paper provides a clearer framework for diagnosing why SFT plateaus and what kind of training signal is needed to move past that plateau.

### MCTS + Reinforcement Learning Combination

Applying MCTS to generate training data for preference optimization is a technique borrowed from the game-playing and planning literature but adapted here for the tool-use domain. The key adaptation is the design of the reward function: rather than a binary win/loss signal, iTool uses a multi-dimensional quality score that maps directly onto the Fragment Deficiency taxonomy.

This reward function design is what makes the MCTS trajectories useful for targeted calibration. A binary reward would produce preference pairs that tell the model "this response is better than that one" without specifying why. The multi-dimensional reward creates preference pairs that encode which specific components of the tool call were correct or incorrect, enabling more precise gradient updates.

### Systematic Iterative Improvement

The iterative structure of the training loop, where each round focuses on the data that the current model still fails to handle, is a form of curriculum adaptation. As the model improves, the effective training distribution shifts toward harder cases. This avoids the problem of wasting training compute on examples the model has already mastered, and it ensures that the model is always working at the edge of its current capability.

## Limitations

### High MCTS Computation Cost

MCTS is computationally expensive. Each invocation requires running many forward passes through the model to expand the search tree and evaluate trajectories. At the scale required for training on 100,000 samples, the total compute cost is substantially higher than standard SFT. The paper acknowledges this but does not propose a concrete solution, positioning it as future work.

For practitioners, this means that iTool as described is most suitable for offline training pipelines where compute budget is not the primary constraint. Online or continual learning settings would require more efficient tree search approximations.

### Evaluation Focused on Function Call Accuracy

The BFCL benchmark evaluates tool use primarily at the level of function call correctness: does the model produce the right function name with the right parameters? This is a well-defined and measurable criterion, but it does not capture everything that matters in practical tool-use scenarios.

In real deployments, tool use involves latency, error handling, partial success recovery, and multi-turn interaction. A model that produces syntactically correct tool calls may still fail in practice if it cannot handle unexpected API responses or if it cannot reason about when to retry a failed call. The iTool evaluation framework does not address these practical dimensions.

### Practical Aspects Lacking

Related to the evaluation point, the paper focuses on the offline training methodology and benchmark evaluation rather than practical deployment considerations. Questions about how iTool performs in production environments, how it handles distribution shift between training APIs and deployment APIs, and how it integrates with real-world tool execution frameworks are left open.

## Future Directions

Several directions for future work follow naturally from the iTool methodology and its current limitations:

**Computation efficiency**: The most immediate need is making the MCTS-based trajectory generation more computationally tractable. Techniques such as beam search approximations, draft-model acceleration, or learned value functions that reduce the number of simulation rollouts could significantly lower the training cost.

**Diverse domain expansion**: The ToolACE dataset covers a representative but not exhaustive range of API types. Extending the iTool framework to additional domains, including domain-specific scientific APIs, data processing pipelines, and code execution environments, would test the generality of the approach and potentially reveal domain-specific calibration challenges.

**Safety and reliability mechanisms**: As LLMs are deployed with real tool access, the consequences of incorrect tool calls become more serious. Future work could integrate safety constraints into the reward function, penalizing tool calls that could have harmful side effects even if they are otherwise technically correct. Reliability mechanisms, such as confidence estimation for generated tool calls and principled abstention when confidence is low, are also important for practical deployment.

## Conclusion

iTool presents a principled solution to the diminishing returns problem that affects SFT-based approaches to LLM tool use. By introducing the Fragment Deficiency concept, applying MCTS to generate diverse and informative training trajectories, and using preference optimization in an iterative calibration loop, the framework achieves a 13.11% overall improvement and a 6.5% additional gain on complex scenarios.

The finding that an 8B parameter model trained with iTool can match larger SFT-trained models is particularly noteworthy. It suggests that the field's current emphasis on scaling model size may be partly misplaced: for tool-use capability specifically, the quality and structure of the training signal matters at least as much as the number of parameters.

The main practical limitation is the computational cost of MCTS, which restricts iTool to offline training pipelines for now. Addressing this cost is the most important near-term research priority if the methodology is to see broad practical adoption.

For teams building LLM systems that rely on external tool use, the iTool framework offers a clear and well-validated path for improving model capability beyond what standard SFT can achieve. The methodology is model-agnostic and dataset-agnostic, making it applicable across a wide range of deployment contexts.

## References

- iTool paper: arXiv:2501.09766
- Harbin Institute of Technology SCIR Lab, Huawei Technologies, Huawei Noah's Ark Lab
- BFCL benchmark: Berkeley Function Calling Leaderboard
- ToolACE dataset: up to 100,000 synthetic tool-use samples
- DPO: Direct Preference Optimization
- SimPO: Simple Preference Optimization
- MCTS: Monte Carlo Tree Search
