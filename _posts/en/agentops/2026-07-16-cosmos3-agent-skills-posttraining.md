---
title: "Agents Take the Wheel on GPU Training: Dissecting NVIDIA Cosmos 3 Agent Skills"
seo_title: "NVIDIA Cosmos 3 Agent Skills Post-Training Analysis - Thaki Cloud"
seo_description: "With TAO agent skills published by NVIDIA, a coding agent automatically drives LoRA fine-tuning and AutoML sweeps for the Cosmos 3 vision model. We dissect a workflow where two prompts raised validation accuracy from 54.41% to 93.35%, and lay out what ThakiCloud Paxis, which treats skills as first-class resources, and ai-platform, which schedules GPU training, can each take from it."
excerpt: "Give a coding agent two natural-language prompts, and post-training a vision foundation model finishes in a single day. We dissect NVIDIA's agent skill and look at what transfers to our own platform, where skills are already treated as first-class resources."
date: 2026-07-16
tags:
  - agent-skills
  - post-training
  - lora
  - automl
  - cosmos-3
  - tao
  - nvidia
  - gpu
  - mlops
  - vision-language
categories:
  - agentops
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/cosmos3-agent-skills-posttraining/"
---

Last week, our design-system UI generation experiment led us to the conclusion that you need to
build the gate before the model. NVIDIA's newly published Cosmos 3 post-training case study is the
other half of that story. Here, instead of a human hand-building the gate, encapsulated knowledge
called an **agent skill** is handed to a coding agent, and that agent drives fine-tuning,
evaluation, and hyperparameter search on its own. The intended audience is ML and platform
engineers who want to post-train foundation models on their own infrastructure. To cut to the
conclusion: the real protagonist of this case study is neither the model nor the GPUs, but the
**harness that hardens workflow knowledge into a skill and lets an agent run it repeatedly**.

![Abstract illustration of a central orchestration node conducting a fleet of GPU servers]({{ '/assets/images/cosmos3-agent-skills-posttraining-hero.png' | relative_url }})
*Agent skills conduct the repetitive labor of GPU training, evaluation, and tuning. The human only supplies the goal through a prompt.*

## What Cosmos 3 and Agent Skills Are

Cosmos 3 is a foundation model NVIDIA built to handle the physical world. It uses a
Mixture-of-Transformers architecture that unifies text, images, video, ambient sound, and motion
tracking, combining an autoregressive reasoning tower responsible for logic and planning with a
diffusion transformer that predicts future states. NVIDIA states that this model ranks first on
multiple benchmarks including VANTAGE-Bench, PAI-Bench, Physics-IQ, RoboLab, and RoboArena. It
comes in two sizes, the 64B Cosmos 3 Super and the 16B Cosmos 3 Nano, and this case study uses
Nano.

The key here is not the model but the **TAO agent skill** attached alongside it. A TAO agent skill
is a bundle of knowledge that automates the post-training workflow for vision models. It
encapsulates task-specific knowledge such as framework details, launcher behavior, config
structure, data loading conventions, and evaluation workflows, so that a coding agent like Codex
or Claude can orchestrate a training pipeline on its own with minimal human intervention. In other
words, a skill is not a single-line prompt but a reusable unit that packages an executable
procedure together with failure recovery.

## Post-Training That Finishes with Two Prompts

What makes this case study striking is that the only human input was two natural-language
prompts.

The first prompt instructs LoRA post-training. It asks the agent to train
`nvidia/Cosmos3-Nano` with LoRA on Toyota's Woven Traffic Safety dataset, but to run a baseline
evaluation first for comparison.

```
Perform LoRA post-training of the Cosmos 3 model on the Woven Traffic
Safety dataset. Training data: /home/.../WTS_dataset/wts_data_train
Validation data: /home/.../WTS_dataset/wts_data_val
Base model on Hugging Face: nvidia/Cosmos3-Nano
Also perform a baseline evaluation first, to compare with the post-trained model.
```

With this single prompt, the agent handled several tasks in sequence. It found and patched a
missing FPS parameter in the data pipeline on its own, cached the model using a Hugging Face
token, measured a pre-training zero-shot baseline of 54.41%, and then ran LoRA training. What
stands out here is the instruction to "run a baseline evaluation first." Instead of trusting a
self-reported result after training, the agent pinned down a pre-training number as a measured
baseline and actually measured the improvement. This is exactly the same principle we learned from
our experiment last week.

The second prompt is an AutoML sweep. It leaves the search strategy and which hyperparameters to
tune up to TAO, and asks the agent to optimize validation accuracy and summarize the best models.

```
Run an AutoML sweep to improve the LoRA result. Let TAO choose suitable
search strategies and tune the important training hyperparameters. Optimize
validation accuracy and summarize the best models.
```

Looking at the overall flow as a diagram, the human appears only at both ends, while the skill
fills in the repetitive work in between.

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
<div class="d3-arch" data-arch-root id="3agentskillsposttraining-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 718, "height": 1086, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 246, "y": 24, "w": 205, "h": 78, "title": ["Natural-language prompt", "(LoRA training + baseline", "eval)"]}, {"id": "B", "x": 277, "y": 180, "w": 142, "h": 62, "title": ["Coding agent", "(Codex / Claude)"]}, {"id": "C", "x": 253, "y": 320, "w": 191, "h": 110, "title": ["TAO agent skill", "encapsulates framework,", "launcher, config,", "data loading, and", "evaluation knowledge"]}, {"id": "D", "x": 488, "y": 508, "w": 198, "h": 78, "title": ["Automatic error patching", "(fixing missing FPS", "parameter)"]}, {"id": "E", "x": 263, "y": 508, "w": 170, "h": 78, "title": ["Model caching", "(Cosmos3-Nano via HF", "token)"]}, {"id": "F", "x": 45, "y": 516, "w": 163, "h": 62, "title": ["Baseline evaluation", "(zero-shot 54.41%)"]}, {"id": "G", "x": 28, "y": 664, "w": 198, "h": 62, "title": ["LoRA post-training", "(8x A100, ~30 min/epoch)"]}, {"id": "H", "x": 24, "y": 804, "w": 205, "h": 78, "title": ["AutoML sweep", "(43 parallel trials, 19.5", "hours)"]}, {"id": "I", "x": 28, "y": 960, "w": 198, "h": 94, "title": ["Serving the best adapter", "Cosmos 3 Reasoner NIM", "(OpenAI-compatible", "endpoint)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [348, 102, 348, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [348, 242, 348, 320]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[444, 413], [587, 469], [587, 469], [587, 508]]}, {"src": "C", "dst": "E", "kind": "data", "line": [348, 430, 348, 508]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[253, 416], [127, 469], [127, 469], [127, 516]]}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 578, 127, 664]}, {"src": "G", "dst": "H", "kind": "data", "line": [127, 726, 127, 804]}, {"src": "H", "dst": "I", "kind": "data", "line": [127, 882, 127, 960]}]});
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
      const container = document.getElementById('3agentskillsposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '3agentskillsposttraining-1';
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

Environment setup is three tokens and one install script line. Set `HUGGINGFACE_TOKEN`,
`NGC_API_KEY`, and `AUTOML_LLM_API_KEY` in the terminal, then install the agent skill with the
script below.

```bash
export HUGGINGFACE_TOKEN="your_hf_token"
export NGC_API_KEY="your_ngc_key"
export AUTOML_LLM_API_KEY="your_llm_key"

curl -fsSL https://raw.githubusercontent.com/NVIDIA-TAO/tao-skills-bank/main/scripts/install-codex-agents.sh | bash
```

The training data is Toyota's Woven Traffic Safety dataset, a video question-answering task with
over 8,000 training and validation samples. It consists of four-choice questions about road
structure, road type, and traffic safety situations.

## The Numbers Two Prompts Produced

Performance improved clearly. All the figures below are values NVIDIA published, not results we
reproduced.

![Bar chart of WTS video QA validation accuracy across the Cosmos 3 Nano baseline, LoRA, and AutoML stages]({{ '/assets/images/cosmos3-agent-skills-posttraining-results.png' | relative_url }})
*Two prompts raised validation accuracy from 54.41% to 93.35%. NVIDIA published figures.*

The zero-shot baseline was 54.41%, and the single-prompt LoRA run raised it by 32.73 points to
87.14%. On top of that, the AutoML sweep tuned hyperparameters with Bayesian optimization and
pushed it to 93.35%, a gain of 38.94 points over the baseline. The key point is that these numbers
came without a human touching a single hyperparameter by hand; the agent chose the search strategy
and ran the repeated training itself.

To be honest about it, we also need to look at the cost numbers. LoRA training took about 30
minutes per epoch on 8x A100 80GB GPUs, and the AutoML sweep ran 43 trials in parallel across
multiple A100 nodes, taking 19.5 hours. A full-parameter SFT run used as a comparison took 3h34m
on H100, and NVIDIA states that LoRA cut GPU time to roughly one-seventh of that full SFT run.
Once training finishes, Cosmos 3 Reasoner NIM serves the LoRA adapter through an
OpenAI-compatible endpoint, a structure that deploys directly as a prebuilt microservice without
requiring manual setup of vLLM dependencies or CUDA configuration.

## Did We Run This Ourselves

To be honest, we did not reproduce this workflow in our own environment. The Cosmos 3 family of
weights sits behind a gated Hugging Face repository, it requires 8 A100 GPUs plus NGC and AutoML
LLM keys, and the parallel sweep used in the case study assumes multiple GPU nodes. We did not
secure this combination of resources for this post. So every number above is a quote of a value
NVIDIA published, and we do not present it as something we measured ourselves. We hold to the
principle of never fabricating a benchmark without reproducing it. What we can do instead is
dissect the structure of this case study and precisely contrast it with what is already running
on our own platform, noting what matches and what differs.

## Implications for ThakiCloud Products

This case study is a rare topic where the perspectives of both our products interlock.

**From the Paxis lens, this is external validation of our thesis that skills should be treated as
first-class resources.** Paxis is ThakiCloud's Agent-Native Cloud control plane, and it treats
Skills, Tools, Policies, and Audit Logs as first-class resources. The Skill Harness selects from
over 960 skills using BM25, runs them in an isolated sandbox, and routes every action through
policy gates and audit logs. What NVIDIA's TAO agent skill proves is that when a skill
encapsulates framework details all the way down to failure recovery, a coding agent can reliably
repeat a complex workflow. This is exactly the direction we have been defining skills in: not as
prompts, but as units of execution. The difference is just as clear, though. TAO skills are
tightly bound to the NVIDIA stack, so they are hard to use as-is outside the TAO launcher, Cosmos
models, NGC, and NIM. The Paxis skill harness is designed to avoid dependency on any specific
vendor or model, and that is exactly the core of the value we aim to deliver in on-premises and
sovereign environments.

**From the ai-platform lens, this is exactly the GPU training and serving we schedule every
day.** Throwing 43 AutoML trials in parallel across multiple nodes directly overlaps with how
Kueue manages the GPU queue on our platform. NIM serving a LoRA adapter through an
OpenAI-compatible endpoint solves the same problem our vLLM serving path solves. And the fact
that LoRA cuts GPU time substantially compared to full SFT supports our thesis that low-cost
serving and low-cost training are ultimately what make agent economics work. When a customer
wants to post-train a foundation model on their own data, we offer a path where they slice GPUs
with Kueue and serve adapters with vLLM on their own cluster, rather than going through a gated
external cloud.

Put the two lenses together and the picture is complete. ai-platform underpins low-cost training
and serving, and on top of that Paxis drives the agent with skills, policies, and audit. NVIDIA's
case study, using someone else's benchmark, shows that this combination actually leads to real
performance gains.

## Limits and Counterarguments

To avoid overstating this case study, four things need to be kept in view together. First, "in
one day" is a wall-clock measure, not a GPU-time measure. A 19.5-hour sweep across 8 A100 GPUs
and multiple nodes is by no means cheap, and one-seventh is a relative figure against full SFT,
not a claim of absolute cheapness. Second, 93.35% is a number from a narrow task: four-choice
traffic-safety video QA. It should not be inflated into a claim that general physical reasoning
ability improved by that much. Third, automation hides vendor lock-in. The reason the agent could
patch errors "on its own" is that the skill bank already knew that exact framework's error
patterns in advance. That smoothness disappears once you step outside the stack. Fourth,
"minimal intervention" is not zero intervention. A human still has to enter API keys, specify
dataset paths, and install a skill bank suited to that task in the first place before the flow
can begin. What the agent removed is repetitive labor, not judgment itself.

Even so, the direction is clear. Hardening workflow knowledge into a skill, having an agent
execute that skill repeatedly, and confirming improvement through a measured gate rather than a
self-report is not one vendor's strategy but a common design pattern of the agent era. That
structure is exactly what we are building with Paxis and ai-platform.

## Sources

- NVIDIA Developer Blog, "Post-Train NVIDIA Cosmos 3 in One Day Using Agent Skills" (<https://developer.nvidia.com/blog/post-train-nvidia-cosmos-3-in-one-day-using-agent-skills/>)
- GitHub: NVIDIA/cosmos, NVIDIA-TAO/tao-skill-bank
- Hugging Face: nvidia/Cosmos3-Nano, nvidia/Cosmos3-Super
- Dataset: Woven Traffic Safety (WTS), Toyota
