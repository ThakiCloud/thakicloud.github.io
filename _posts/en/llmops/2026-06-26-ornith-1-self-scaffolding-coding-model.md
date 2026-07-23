---
title: "Ornith-1.0: An Open Coding Model That Writes Its Own RL Scaffolds"
excerpt: "Released by DeepReinforce on June 25, 2026, Ornith-1.0 is an open-source coding model family built on a self-scaffolding mechanism: during reinforcement learning, the model writes the training scaffold that guides its own solutions. We examine the four-size lineup (9B/31B dense and 35B/397B MoE), its MIT license, 262K context, and the reported SWE-Bench Verified score of 82.4 through the lens of ThakiCloud's K8s multi-tenant serving and in-house coding agent infrastructure."
seo_title: "Ornith-1.0 Self-Scaffolding RL Open Coding Model Analysis vLLM Serving - Thaki Cloud"
seo_description: "Analysis of DeepReinforce Ornith-1.0 (MIT, 9B/31B/35B/397B): self-scaffolding reinforcement learning mechanism, public benchmarks (SWE-Bench Verified 82.4, Terminal-Bench 2.1 77.5), and vLLM serving recipes evaluated from a ThakiCloud K8s multi-tenant coding agent operations perspective."
date: 2026-06-26
last_modified_at: 2026-06-26
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/ornith-1-self-scaffolding-coding-model/"
tags:
  - ornith
  - deepreinforce
  - reinforcement-learning
  - coding-agent
  - self-scaffolding
  - open-weights
  - vllm
  - moe
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "robot"
toc_sticky: true
reading_time: true
categories:
  - llmops
published: false
---

![Abstract image depicting a self-scaffolding structure building its own foundation layer by layer]({{ '/assets/images/ornith-1-self-scaffolding-coding-model-hero.webp' | relative_url }})
*An abstract representation of self-scaffolding reinforcement learning, where a model constructs its own training scaffold from the ground up.*

Competition among open-weight coding models has moved beyond "what benchmark score did you hit?" toward "what training method produced that score?" `Ornith-1.0`, released by DeepReinforce on June 25, 2026, is a model where the methodology itself is the headline. The reinforcement learning design lets the model **write the training scaffold that guides its own solutions** at the same time it generates those solutions.

The benchmark numbers in this post are not results we reproduced ourselves. Running a 397B model through coding benchmarks requires multi-GPU nodes and hours of inference, which we did not do for this intraday analysis. Every score cited here is **a figure stated in DeepReinforce's public materials**; values where sources differ are marked `[estimated]`. We have not fabricated any reproduction numbers.

## Overview

`Ornith-1.0` is not a single model but an open-source family specialized for coding. It spans four sizes: 9B dense, 31B dense, 35B Mixture-of-Experts (MoE), and the 397B MoE flagship. All four are MIT-licensed and immediately downloadable from the `deepreinforce-ai` namespace on Hugging Face. Quantized variants, including 9B and 35B GGUF and 35B and 397B FP8, are also available, signaling an intentional deployment spectrum from single-GPU edge to multi-node datacenter.

Two things stand out immediately from ThakiCloud's perspective: the license and self-hosting viability. MIT imposes no copyleft infection, no non-commercial clause, and no legal friction for commercial or non-commercial use. For organizations that want to run a coding agent on their own infrastructure without sending proprietary code to an external API, MIT is the cleanest possible "yes, you can."

The one-sentence summary: **Ornith-1.0 does not just learn solutions during the RL phase; it also learns the per-task training scaffold that produces those solutions.** Treating the scaffold as a learned variable rather than a fixed constant is the key divergence from other RL coding models.

The original announcement tweet described this as "the first open-source model from a US lab that codes at frontier level." We were unable to independently verify DeepReinforce's headquarters location from public sources, so this post focuses on the verifiable mechanism and public numbers rather than the geographic framing.

## What This Model Is

`Ornith-1.0` is built by applying post-training on top of pretrained base models. DeepReinforce stated it used Gemma 4 and Qwen 3.5 series as bases. This means the model was not pretrained from scratch; instead, the team applied **their own RL post-training** to strong open bases to sharpen coding capability. That structure mirrors the broader open ecosystem trend of "base as shared asset, differentiation through post-training," similar to how NVIDIA redistributes third-party models after quantization.

The model itself is a reasoning model. By default it opens assistant responses with a `<think> ... </think>` block, working through its reasoning before producing a final answer. The published serving recipe activates a reasoning parser that routes this thinking process to a separate `reasoning_content` field, alongside a tool-call parser that exposes the model's tool invocation blocks as OpenAI-style `tool_calls`. The design intent is clear: plug it straight into an existing agent loop. The maximum context length is 262,144 tokens, sized for long-horizon coding tasks that push a large repository into a single context window.

DeepReinforce is not new to RL work. Their 2025 `CUDA-L1` project used reinforcement learning to auto-optimize CUDA kernels, reporting a mean 3.12x speedup and peak gains orders of magnitude higher on multiple GPU tasks. The consistent research thread of "use reinforcement learning to make code or kernels improve themselves" runs directly into this coding model.

## The Core: Reinforcement Learning That Writes Its Own Scaffold

Most agentic RL training fixes the scaffold (prompt structure, tool-use conventions, task decomposition template) by hand and then trains the policy within it. A good scaffold raises scores; a bad one caps performance no matter how strong the policy becomes. The problem is that a different scaffold works best for each task type. Ornith-1.0 promotes the scaffold from a **fixed constant to a learned variable**.

According to DeepReinforce's description, each RL step proceeds in two stages. First, the model proposes a **refined scaffold conditioned on the given task**. Second, it **generates a solution rollout conditioned on that scaffold**. The reward propagates back through both stages: "what scaffold did you build?" and "what did you solve on top of it?" are scored together and improved together. The scaffold co-evolves with the policy.

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
<div class="d3-arch" data-arch-root id="lfscaffoldingcodingmodel-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 490, "height": 612, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 148, "w": 434, "h": 294, "label": "RL step (2 stages)", "lx": 36, "ly": 166}], "nodes": [{"id": "T", "x": 181, "y": 24, "w": 120, "h": 46, "title": "Task"}, {"id": "S1", "x": 139, "y": 187, "w": 205, "h": 62, "title": ["Stage 1: Propose scaffold", "(conditioned on task)"]}, {"id": "S2", "x": 216, "y": 341, "w": 205, "h": 62, "title": ["Stage 2: Solution rollout", "(conditioned on scaffold)"]}, {"id": "R", "x": 195, "y": 534, "w": 120, "h": 46, "title": "Reward"}], "edges": [{"src": "T", "dst": "S1", "kind": "data", "line": [241, 70, 241, 187]}, {"src": "S1", "dst": "S2", "kind": "data", "curve": [[296, 249], [378, 295], [378, 295], [343, 341]]}, {"src": "S2", "dst": "R", "kind": "data", "curve": [[345, 403], [378, 442], [378, 488], [296, 534]]}, {"src": "R", "dst": "S1", "kind": "event", "label": "propagate to scaffold", "curve": [[207, 534], [111, 442], [111, 295], [189, 249]], "off": "50%"}, {"src": "R", "dst": "S2", "kind": "event", "label": "propagate to policy", "curve": [[255, 534], [255, 488], [255, 442], [290, 403]], "off": "50%"}, {"src": "S1", "dst": "S2", "kind": "event", "label": "Co-evolve", "curve": [[241, 249], [241, 295], [241, 295], [287, 341]], "off": "50%"}]});
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
      const container = document.getElementById('lfscaffoldingcodingmodel-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lfscaffoldingcodingmodel-1';
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

This structure matters for two reasons. First, the bottleneck of humans hand-tuning scaffolds disappears. When the task distribution shifts, the model re-builds its scaffold on its own. Second, because the scaffold is exposed directly to the reward signal, the common failure mode of "the policy is fine but the scaffold is bad so the score never climbs" becomes correctable inside the training loop. This is in the same family as the [Loop Engineering pattern](https://thakicloud.com/tech-blog/en/llmops/) that uses external tools (compilers, tests) as reward signals, but goes one step further by adding **the scaffold itself** to the set of things receiving that reward.

## Public Benchmarks

The flagship numbers DeepReinforce published are as follows. All are from their own evaluation; none were reproduced in our environment.

| Benchmark | Ornith-1.0-397B | Comparison |
|---|---|---|
| SWE-Bench Verified | 82.4 | Claude Opus 4.8 87.6 (the only model in the comparison that exceeds it) |
| Terminal-Bench 2.1 | 77.5 | Reported as SOTA among open-source at this scale |
| SWE-Bench Pro | 62.2 `[estimated]` | Sources differ |

DeepReinforce claims top-tier performance among open-source models of comparable size on Terminal-Bench 2.1, SWE-Bench, NL2Repo, and OpenClaw. Notably, the 35B MoE is reported to outperform some larger models, which reads as MoE sparsity combined with self-scaffolding post-training raising efficiency relative to active parameter count. That said, SWE-Bench variants (Verified, Pro, original) differ substantially in scoring, and comparing numbers without confirming which variant was used is risky. That is why the SWE-Bench Pro figure is marked `[estimated]`.

More meaningful than the scores for anyone running these in production is that **the source of the scores is a publicly described mechanism**. Closed-model scores cannot be reproduced, but MIT-released weights and a published training description leave the door open for external verification.

## Installation and Serving

Ornith-1.0 is packaged to run on standard inference stacks without modification. Starting with the smallest model before validating is the right discipline for self-hosting. The 9B is designed for a single GPU and is a reasonable starting point for pipeline integration testing.

```bash
# Download weights from Hugging Face (e.g., 9B)
huggingface-cli download deepreinforce-ai/Ornith-1.0-9B \
  --local-dir ./ornith-1.0-9b
```

Because this is both a reasoning model and a tool-calling model, serving it requires both the reasoning parser and the tool-call parser to be active so that the thinking process and tool invocations arrive as structured fields rather than raw text. A representative vLLM startup looks like this; confirm the exact parser names from each model card's serving recipe.

```bash
# vLLM serving (representative form -- confirm parser names from model card)
vllm serve deepreinforce-ai/Ornith-1.0-9B \
  --max-model-len 262144 \
  --enable-auto-tool-choice \
  --tool-call-parser <see model card> \
  --reasoning-parser <see model card>
```

For the 397B MoE flagship, memory is the first wall. That is why the FP8 variant (`Ornith-1.0-397B-FP8`) ships alongside. It cuts weight memory roughly in half compared to BF16, reducing the node count and tensor parallel degree needed. The 35B MoE sits at the point where MoE's advantage of "small active parameters, large knowledge capacity" is most balanced; it is a realistic candidate for single-node multi-GPU deployment.

```bash
# 397B: FP8 variant + tensor parallelism to lower the memory wall (skeleton example)
vllm serve deepreinforce-ai/Ornith-1.0-397B-FP8 \
  --tensor-parallel-size 8 \
  --max-model-len 262144 \
  --enable-auto-tool-choice
```

## What This Means for ThakiCloud's Products

Ornith-1.0's self-scaffolding is structurally isomorphic with Paxis's self-evolving skills. Paxis is ThakiCloud's Agent-Native Cloud proof of concept, running as the agent control plane on top of the ai-platform Kubernetes infrastructure. Its core components include a Skill Harness that selects from 960-plus skills using BM25 retrieval, sandboxed isolated execution, a DAG multi-agent engine, NL Cron, MCP connectors, and self-evolving skills. Just as Ornith-1.0 proposes its own training scaffold at each RL step and exposes that scaffold to the reward signal alongside the solution, Paxis's self-evolving skill loop lets agents generate and improve their own work structure, including skill composition, execution flow, and tool-use conventions. "Elevating the scaffold to a learned variable" and "elevating the skill to an evolving artifact" are two expressions of the same design philosophy.

Paxis's self-management capability, where agents autonomously schedule their own work, track tasks, and manage sessions through DAG multi-agent coordination and NL Cron, is directly isomorphic with self-scaffolding: in both cases an autonomous agent creates and maintains the structure of its own work rather than operating inside a fixed frame handed down by a human. Paxis is built in Go 1.26 and React 19 and is LLM-agnostic, generalizing this pattern as a platform-level capability rather than tying it to any particular model. Ornith-1.0's mechanism provides a concrete precedent that can directly inform the design and improvement of Paxis's self-evolving skill harness loop.

The training and serving infrastructure for self-scaffolding models like Ornith-1.0 sits on ai-platform. ThakiCloud's ai-platform schedules GPU workloads via Kueue on Kubernetes and serves multi-tenant inference via vLLM. The Ornith-1.0 family's range from 9B to 397B MoE maps cleanly onto Kueue's layered GPU allocation: 9B for lightweight auxiliary tasks, 35B MoE as the primary serving workhorse, and 397B for dedicated high-difficulty task pools, with Kueue coordinating allocation by per-tenant priority. The MIT license and OpenAI-compatible `tool_calls` output mean any size in the family can be integrated into an existing vLLM serving pipeline by replacing the base model, which is particularly valuable for regulated environments where model sovereignty over internal code is a hard requirement.

## Limitations and Counterarguments

The biggest limitation is **asymmetric verification**. The weights and training description are public, but the benchmark numbers are self-reported and were not reproduced in our environment. SWE-Bench variants differ substantially in score, and the same model can produce different results depending on harness configuration, temperature, and retry settings. Jumping from the reported numbers to "this has caught up to frontier" is premature. Any actual adoption decision requires internal evaluation against a sample of our own codebase.

The second concern is **operational cost**. The 397B MoE scores look attractive, but self-hosting at that scale means GPU memory and node count are a real constraint. The FP8 variant helps, but "open" does not mean "free" -- it means we bear the infrastructure cost ourselves. The comparison between closed API token pricing and self-hosting node pricing only resolves in our favor at specific workload patterns, and that requires working through the numbers.

The third is **generalization of self-scaffolding**. The design is elegant, but there is no externally verified guarantee that scaffold quality holds up on unfamiliar tasks outside the training distribution. It is also plausible that the scaffold overfit to the reward signal and learned to build structures that perform well specifically on these benchmark formats. This question can only be settled when independent parties reproduce results with the public weights.

In summary, Ornith-1.0 is a model worth watching for its **method** more than its scores. The MIT open-weight release makes it a realistic candidate for self-hosted coding agents, and the self-scaffolding mechanism has ideas worth borrowing for agent training pipeline design regardless of whether you adopt the model itself. That said, all benchmark claims should be held as "announced figures" until validated through your own evaluation.

## Sources

- DeepReinforce, "Ornith-1.0: Self-Scaffolding LLMs for Agentic Coding" (2026-06): <https://deep-reinforce.com/ornith_1_0.html>
- Hugging Face model cards: <https://huggingface.co/deepreinforce-ai/Ornith-1.0-397B>, <https://huggingface.co/deepreinforce-ai/Ornith-1.0-9B>
- GitHub: <https://github.com/deepreinforce-ai/Ornith-1>
- MarkTechPost, "DeepReinforce Releases Ornith-1.0" (2026-06-25): <https://www.marktechpost.com/2026/06/25/deepreinforce-releases-ornith-1-0-an-open-source-coding-model-family-that-learns-its-own-rl-scaffolds/>
- Tech Times (2026-06-26): <https://www.techtimes.com/articles/319122/20260626/open-source-coding-model-ornith-10-writes-its-own-training-scaffold-reinforcement-learning.htm>
- DeepReinforce, CUDA-L1 (prior research): <https://deepreinforce-ai.github.io/cudal1_blog/>
