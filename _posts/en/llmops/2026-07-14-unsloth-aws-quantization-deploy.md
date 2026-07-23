---
title: "Where Do You Put a Quantized Model? Four AWS and Unsloth Deployment Patterns"
excerpt: "Plenty of teams know how to shrink a model to 4-bit with Unsloth. But the moment they have to decide whether to put that file on EC2, wrap it in a SageMaker endpoint, or launch it as an EKS pod, most get stuck. The AWS guide co-authored with Unsloth gives a clear map for this. The key idea: the model file format decides the runtime, and the runtime decides the AWS service. This post covers where GGUF goes, where merged safetensors goes, and how this thinking maps onto ThakiCloud's serving infrastructure."
tags:
  - unsloth
  - quantization
  - aws
  - sagemaker
  - vllm
  - llmops
  - self-hosting
  - paxis
date: 2026-07-14
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/unsloth-aws-quantization-deploy/"
categories:
  - llmops
---

![Abstract illustration of a large model distilled into compact layers flowing into cloud serving infrastructure]({{ '/assets/images/unsloth-aws-quantization-deploy-hero.png' | relative_url }})

## Overview

There are already plenty of posts on how to quantize a model. GPTQ, AWQ, GGUF, Unsloth Dynamic; a recipe to shrink a 16-bit model to 4-bit is a few searches away. Yet the point where teams actually stall is what comes next. Where exactly do you put that 4-bit file, and how? Do you launch it directly on an EC2 instance, wrap it in a SageMaker endpoint, or drop it into a pod on the EKS cluster you already run? There is no single answer, but there is a map that branches on the format of the model file.

This post is written for platform engineers deploying open-weight models on their own infrastructure and for practitioners designing inference cost. AWS recently published a guide with Unsloth, "Deploying quantized models on Amazon SageMaker AI with Unsloth," that organizes this deployment decision into four patterns. We dissect the core logic of that guide, explain why the model file format decides the runtime and the runtime in turn decides the AWS service, and connect this way of thinking to how infrastructure like ThakiCloud, which does multi-tenant serving on Kubernetes, is designed.

One thing to state up front: the command examples here are paths verified in the AWS official guide and Unsloth docs, and we have not invented any benchmark numbers. Our verification environment is Apple Silicon, so we could not actually run and reproduce the CUDA-dependent Unsloth quantization and vLLM serving locally. This post is therefore not an experiment report but a structural analysis of a verified guide.

## Why quantization matters again at deployment

Quantization is usually discussed only as a matter of training or inference speed. But the AWS guide points out that at the deployment stage, quantization changes three things at once. First, the instance decision. As a large model becomes practical to run on a smaller GPU or even a CPU, the required instance tier itself drops. Second, the startup and storage profile. Smaller model files move and store faster, which helps cold starts and scale-out. Third, deployment flexibility. You can pick a smaller model for cost-sensitive inference and a higher-precision export for quality-sensitive inference.

Unsloth's strength is that it ties fine-tuning, running, exporting, and deploying into a single workflow. In particular, Unsloth Dynamic v2.0 quantization lets you run and fine-tune quantized LLMs while preserving accuracy as much as possible, and quantization-aware training (QAT), built in collaboration with PyTorch, is reported to recover much of the accuracy lost to naive 4-bit quantization. In other words, you can choose precisely where on the quality-versus-size trade-off to sit before deployment.

## Format decides the runtime, runtime decides AWS

The core insight of the guide is: do not start the deployment decision from "which service should I use." Instead, start from "which file format should I export to," and the rest follows naturally. There are two branches.

One is GGUF. GGUF is a single-file format that bundles weights, tokenizer, and metadata together, and lightweight runtimes such as llama.cpp, Ollama, and Unsloth use it. On AWS this branch maps to Amazon EC2 or a SageMaker AI custom container. It is the path for when you want to validate lightly and keep direct control.

The other is merged safetensors. Merging and exporting 16-bit, 8-bit, FP8, or 4-bit weights with Unsloth lets you run on high-throughput engines like vLLM and SGLang, which maps to SageMaker AI Large Model Inference (LMI) containers, EKS, or ECS. It is the path for production serving where throughput and scale matter. The branch is summarized below.

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
<div class="d3-arch" data-arch-root id="othawsquantizationdeploy-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 493, "height": 1010, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 144, "y": 24, "w": 212, "h": 62, "title": ["Fine-tune or download with", "Unsloth"]}, {"id": "B", "x": 149, "y": 164, "w": 202, "h": 52, "title": "Choose serving runtime"}, {"id": "C", "x": 284, "y": 308, "w": 177, "h": 78, "title": ["Export GGUF", "weights + tokenizer +", "metadata"]}, {"id": "D", "x": 24, "y": 316, "w": 205, "h": 62, "title": ["Export merged safetensors", "16 / 8 / FP8 / 4-bit"]}, {"id": "E", "x": 288, "y": 464, "w": 170, "h": 62, "title": ["llama.cpp · Ollama ·", "Unsloth"]}, {"id": "F", "x": 66, "y": 472, "w": 121, "h": 46, "title": "vLLM · SGLang"}, {"id": "G", "x": 291, "y": 604, "w": 163, "h": 78, "title": ["Amazon EC2", "or SageMaker custom", "container"]}, {"id": "H", "x": 31, "y": 612, "w": 191, "h": 62, "title": ["SageMaker LMI container", "or EKS · ECS"]}, {"id": "I", "x": 154, "y": 760, "w": 191, "h": 62, "title": ["Validate the runtime on", "EC2"]}, {"id": "J", "x": 161, "y": 900, "w": 177, "h": 78, "title": ["Promote the same", "file+runtime combo", "to managed deployment"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [250, 86, 250, 164]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"lightweight single file\"", "curve": [[294, 216], [373, 262], [373, 262], [373, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "\"high-throughput engine\"", "curve": [[205, 216], [127, 262], [127, 262], [127, 316]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [373, 386, 373, 464]}, {"src": "D", "dst": "F", "kind": "data", "line": [127, 378, 127, 472]}, {"src": "E", "dst": "G", "kind": "data", "line": [373, 526, 373, 604]}, {"src": "F", "dst": "H", "kind": "data", "line": [127, 518, 127, 612]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[373, 682], [373, 721], [373, 721], [304, 760]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[127, 674], [127, 721], [127, 721], [195, 760]]}, {"src": "I", "dst": "J", "kind": "data", "line": [250, 822, 250, 900]}]});
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
      const container = document.getElementById('othawsquantizationdeploy-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'othawsquantizationdeploy-1';
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

## Setup and integration

The workflow the guide lays out has four steps. Fine-tune or download a model in Unsloth, export it in the format that matches your target runtime, validate the runtime on EC2 or locally, then promote the same file and runtime combination straight into a managed deployment. The phrase "same file and runtime combination" matters here, because if the format or engine differs between validation and production, unexpected behavior creeps in.

Exporting from Unsloth branches by target runtime. The GGUF path looks like this.

```python
# Export GGUF (llama.cpp / Ollama / EC2 path)
model.save_pretrained_gguf(
    "qwen-merged-gguf",
    tokenizer,
    quantization_method="q4_k_m",
)
```

The merged safetensors path targets vLLM or SGLang.

```python
# Export merged safetensors (vLLM / SGLang / SageMaker LMI path)
model.save_pretrained_merged(
    "qwen-merged-16bit",
    tokenizer,
    save_method="merged_16bit",  # or merged_4bit, etc.
)
```

The exported merged model can be validated for serving directly with vLLM.

```bash
# Validate serving on EC2 or locally
vllm serve ./qwen-merged-16bit --port 8000
```

For container-based deployment, AWS Deep Learning Containers (DLCs) provide optimized Docker environments across EC2, EKS, and ECS. The vLLM DLC in particular is tuned for high-performance inference and natively supports tensor parallelism and pipeline parallelism across multiple GPUs and nodes. That is, a configuration validated on a single EC2 instance flows smoothly into an EKS pod using the same runtime for horizontal scaling.

## Implications for ThakiCloud products

This deployment map overlaps directly with the design philosophy of ThakiCloud's ai-platform. The ai-platform serves models on top of Kubernetes and Kueue-based GPU scheduling, and the principle the AWS guide states, that format decides runtime and runtime decides infrastructure, is not tied to any specific cloud. The split of GGUF for lightweight validation and edge deployment versus merged safetensors for vLLM-based high-throughput serving applies identically whether it is AWS EKS or on-premises Kubernetes. If anything, for ThakiCloud, which has many customers requiring on-premises and sovereign cloud, standardizing the deployment path by file format and runtime rather than binding to a specific managed service is more advantageous for portability.

In practice, the ai-platform can combine the tensor parallelism and pipeline parallelism the vLLM DLC provides with Kueue queuing to run multi-tenant. It can pick a different-precision export per customer, assigning 4-bit merged models to cost-sensitive workloads and FP8 or 16-bit to quality-sensitive ones. If you use Unsloth's QAT to recover accuracy even at 4-bit, the point at which you win both low serving cost and quality widens. This fine-grained matching of format and runtime is exactly the background to ai-platform competing on low serving unit cost.

This low-cost serving in turn feeds agent economics. Paxis, ThakiCloud's Agent-Native Cloud control plane, runs skills in isolated sandboxes and calls large open-weight models repeatedly, so if you quantize a fine-tuned domain model with Unsloth and put it on the ai-platform, Paxis agents can consume it cheaply. Format-based deployment standardization is itself the structure that lowers the unit cost of agent workloads.

## Limitations and counterarguments

As a deployment map this guide is clear, but there are caveats. First, actual quality and throughput vary greatly with the combination of quantization method and runtime. How much accuracy a 4-bit merged model retains on vLLM, or whether tensor parallelism actually gives linear scaling on a specific model, must be measured directly on the target model and hardware; the guide's generalities alone cannot tell you.

Second, the convenience of managed services comes at the cost of expense and lock-in. SageMaker LMI containers reduce operational burden, but in environments with strong on-premises requirements, running the same runtime yourself on EKS or your own Kubernetes may be better for control and cost. The AWS guide being a good map is separate from the judgment of porting that map to your own infrastructure, which is each team's own call.

Third, as noted above, this post is a structural analysis without local reproduction. Before actual adoption you must export the target model with Unsloth, serve it on vLLM, and confirm per-format latency, throughput, and accuracy with your own benchmarks.

## Sources

- AWS Machine Learning Blog, "Deploying quantized models on Amazon SageMaker AI with Unsloth": [https://aws.amazon.com/blogs/machine-learning/deploying-quantized-models-on-amazon-sagemaker-ai-with-unsloth/](https://aws.amazon.com/blogs/machine-learning/deploying-quantized-models-on-amazon-sagemaker-ai-with-unsloth/)
- Unsloth Documentation: [https://unsloth.ai/docs](https://unsloth.ai/docs)
- AWS, "Deploy LLMs on Amazon EKS using vLLM Deep Learning Containers"
