---
title: "Inside slime, the Open-Source RL Framework That Built GLM-5.2"
excerpt: "slime, the asynchronous reinforcement-learning infrastructure behind the post-training of Z.ai's 1M-context open-weight model GLM-5.2, has been fully open-sourced. We break down its three-component design that bridges Megatron training and SGLang rollout through a Data Buffer, its colocated/disaggregated execution modes, and its multi-turn agent-RL design from the perspective of ThakiCloud's K8s and Kueue GPU serving stack."
seo_title: "GLM-5.2 RL Framework slime Analysis: Megatron SGLang Post-Training - Thaki Cloud"
seo_description: "An analysis of THUDM slime (an SGLang-native RL post-training framework): its Training/Rollout/Data Buffer three-component design, colocated vs disaggregated modes, multi-turn agent-RL features, and GLM-5.x validation, examined from ThakiCloud's K8s-based multi-tenant GPU operations perspective."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - slime
  - glm-5.2
  - reinforcement-learning
  - post-training
  - sglang
  - megatron
  - agent-rl
  - open-source
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/glm52-slime-rl-framework/"
reading_time: true
categories:
  - llmops
---

![An abstract image depicting a generation cluster and a training cluster exchanging data asynchronously through a central buffer]({{ '/assets/images/glm52-slime-rl-framework-hero.webp' | relative_url }})
*An image evoking slime's asynchronous RL design, which decouples rollout from training to raise throughput.*

## Overview

GLM-5.2, released by Z.ai (formerly Zhipu AI) in June 2026, is an open-weight model with a 1M-token context and an MIT license. It drew attention for competing with closed commercial models on coding and long-horizon agentic tasks. But this release ships with something nearly as significant as the model weights themselves: **slime**, the reinforcement-learning infrastructure that powered the model's post-training, was open-sourced alongside it.

Most frontier models release their pretrained weights but keep private the RL pipeline that turns those weights into a genuinely useful agent. The infrastructure that connects reward design, rollout generation, and the training loop is precisely the kind of proprietary know-how that determines model quality. slime opens this entire territory. Z.ai states that not only GLM-5.2 but also GLM-5.1, GLM-5, GLM-4.7, GLM-4.6, and GLM-4.5 went through post-training on the same framework. A single framework passing through multiple SOTA-class releases means this is production-validated infrastructure, not lab code.

ThakiCloud runs a K8s-based multi-tenant AI/ML SaaS platform, serving models and running agents across diverse customer environments. So for us, "which model is good" matters as much as "what infrastructure built and operates it." As a public reference for the latter, slime is well worth examining. In this post we lay out slime's structure and design philosophy, and consider what it implies for our platform's Kueue GPU scheduling and SGLang/vLLM serving stack.

## What Is slime

slime is an **LLM post-training framework for RL scaling** built by THUDM (the Tsinghua / Z.ai lineage). The core idea is simple. Megatron-LM is good at training and SGLang is good at high-throughput inference (rollout), so let us bind the two into a single data flow. RL post-training endlessly repeats a loop of "the model generates an answer (rollout), the answer is scored, and that reward updates the model," so how smoothly you connect the generation engine and the training engine determines overall throughput.

slime decomposes this loop into three components.

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
<div class="d3-arch" data-arch-root id="627glm52slimerlframework-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 444, "height": 988, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 386, "h": 436, "label": "Rollout (SGLang + Router)", "lx": 36, "ly": 42}, {"x": 160, "y": 552, "w": 252, "h": 172, "label": "Data Buffer (bridge)", "lx": 172, "ly": 570}, {"x": 28, "y": 816, "w": 333, "h": 140, "label": "Training (Megatron-LM)", "lx": 40, "ly": 834}], "nodes": [{"id": "SGL", "x": 104, "y": 219, "w": 191, "h": 62, "title": ["SGLang inference engine", "response generation"]}, {"id": "RT", "x": 100, "y": 63, "w": 198, "h": 78, "title": ["sgl-router", "single OpenAI-compatible", "endpoint"]}, {"id": "RW", "x": 211, "y": 359, "w": 149, "h": 62, "title": ["reward / verifier", "score computation"]}, {"id": "DB", "x": 197, "y": 591, "w": 177, "h": 94, "title": ["prompt initialization", "custom data", "rollout generation", "strategy management"]}, {"id": "MG", "x": 107, "y": 855, "w": 184, "h": 62, "title": ["Megatron training loop", "weight update"]}], "edges": [{"src": "RT", "dst": "SGL", "kind": "data", "line": [199, 141, 199, 219]}, {"src": "SGL", "dst": "RW", "kind": "data", "curve": [[237, 281], [286, 320], [286, 320], [286, 359]]}, {"src": "RW", "dst": "DB", "kind": "data", "label": "\"generated data + reward record\"", "line": [286, 421, 286, 591], "lx": 286, "ly": 502}, {"src": "DB", "dst": "MG", "kind": "data", "label": "\"training batch supply\"", "curve": [[286, 685], [286, 724], [286, 816], [237, 855]], "off": "50%"}, {"src": "MG", "dst": "SGL", "kind": "event", "label": "\"parameter sync\"", "curve": [[161, 855], [112, 724], [112, 460], [161, 281]], "off": "50%"}]});
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
      const container = document.getElementById('627glm52slimerlframework-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '627glm52slimerlframework-1';
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

- **Training (Megatron-LM)**: Handles the main training process. It reads data from the Data Buffer to update the model, and synchronizes parameters with the rollout module once training completes.
- **Rollout (SGLang + Router)**: Generates new data, including rewards and verifier outputs, and writes it to the Data Buffer. Here the sgl-router provides an OpenAI-compatible API so complex agent environments can interact with the model through a single HTTP endpoint.
- **Data Buffer**: The bridge between the two worlds. It manages prompt initialization, custom data, and rollout generation strategy.

Resource management is handled by Ray. As a result, whether training and rollout sit on the same GPUs or are split across separate GPUs can be toggled with a single flag.

## Two Execution Modes: Colocated and Disaggregated

slime's most practical design decision is that the same code supports two deployment modes.

**Colocated / synchronous mode** places training and rollout on the same GPU pool. It is enabled with a single `--colocate` flag. It is good for squeezing the most out of constrained GPU environments, with generation and training time-sharing the same resources.

**Disaggregated / asynchronous mode** separates training GPUs from rollout GPUs. Generation can keep running without waiting on training, which raises throughput. The "asynchronous agent RL" that GLM-5.2 emphasized runs on top of exactly this mode. Decoupling generation from training sharply reduces GPU idle time on workloads where each episode is long and irregular, such as multi-turn, multi-tool interactions.

This choice matters to operators. With the same framework you can run small experiments cheaply in colocated mode and push throughput in disaggregated mode for large-scale production training, enabling gradual scale-up.

## Design for Agent RL

There is a reason slime was used to train agentic models like GLM-5.x: it includes features aimed squarely at multi-turn agent workloads.

- **PD Disaggregation**: Separates prefill and decode for multi-turn and agentic workloads where the two stages have different resource needs.
- **Router session affinity**: Provides routing policy so a multi-turn agent keeps the same session, letting the multiple turns of one agent continue in a consistent state.
- **Delta Weight Sync**: In a training/inference-disaggregated setup, only the weight delta is synchronized, cutting communication cost.
- **A single OpenAI-compatible endpoint**: Thanks to the sgl-router, complex agent environments interact with the model through plain HTTP requests. There is no need to cram environment code inside the RL framework.

The last item is especially practical. If you abstract the environment of long-horizon tasks such as code editing, tool use, and multi-step problem solving into OpenAI API calls, you can connect existing agent environments to the RL training loop almost as-is. Z.ai adds an "anti-hacking" mechanism on top to suppress reward hacking, where the model exploits the reward through shortcuts on long-horizon tasks.

## Installation and Usage Overview

slime is available on GitHub ([THUDM/slime](https://github.com/THUDM/slime)), and being SGLang-native it assumes the SGLang inference stack and the Megatron-LM training stack. Day-0 support for AMD Instinct GPUs has also been published via the ROCm blog, validating operation on accelerators beyond NVIDIA.

To be honest, though, meaningfully reproducing slime's actual RL post-training loop requires a multi-GPU cluster (typically eight or more datacenter-class accelerators) and an environment with Megatron, SGLang, and Ray configured together. This post did not run a full RL training on a single-node sandbox to capture numbers. We therefore present no benchmark figures such as training throughput or convergence speed, and the production validation cases below are based on published primary sources. Not inventing arbitrary performance numbers is a principle of this blog.

Structurally, the surfaces an operator touches are clear. You set the deployment style with a mode flag such as `--colocate`, plug your own domain rollout strategy into the Data Buffer's custom data generation interface, and attach agent environments to the sgl-router endpoint. This is why the framework emphasizes versatility: because the rollout interface is fully customizable, everything from general RL algorithms to domain-specific agent training can be configured on the same skeleton.

## GLM-5.x Validation

slime is counted among the most battle-tested open RL post-training frameworks. Multiple SOTA-class releases (GLM-5.2, GLM-5.1, GLM-5, GLM-4.7, GLM-4.6, GLM-4.5) have passed through its complete training loop. GLM-5.2 stated it was post-trained with a novel async agent-RL algorithm that learns from long-horizon, multi-tool interactions on top of infrastructure that decouples generation from training. It has been reported that GLM-5.2's full post-training finished in about two days, but we leave this duration figure as [estimated] since we could not cross-verify it against primary official documentation.

The point is not the number but reproducibility. With both the model weights (MIT) and the training framework open, an organization with enough compute can retrace GLM-5.2's post-training recipe on its own domain data. This is leverage unique to an open ecosystem, impossible with closed models.

## What This Means for ThakiCloud's Products

slime's asynchronous RL design touches two distinct product layers at ThakiCloud.

From the ai-platform lens, RL training demands two concurrent workloads of fundamentally different character: rollout (inference load) and train (backpropagation load). The way slime switches between colocated and disaggregated via Ray maps cleanly onto Kueue's GPU queue model. In disaggregated mode, splitting rollout and train into separate jobs lets Kueue schedule each through its own queue, raising GPU utilization across a multi-tenant cluster and keeping compute costs down. Our serving stack already uses vLLM, so the knowledge built around continuous batching and KV-cache management transfers directly to the rollout side of an RL pipeline. The practical result is an on-premises RL pipeline that can run without exporting data off-cluster, which turns self-hosted post-training from a vague goal into a concrete product offering.

From the Paxis lens, the connection is even more direct. Paxis is ThakiCloud's agent control plane, running on top of ai-platform. Its core includes a Skill Harness that selects from 960-plus skills via BM25, a self-evolving skill loop, sandboxed execution, and an HKE knowledge engine. A framework like slime becomes the learning backend for that self-evolving loop. By generating rollouts from customer-domain data, scoring them with a reward signal, and updating skills through reinforcement learning, Paxis's domain agents improve continuously with use. The sgl-router's OpenAI-compatible endpoint acts as the glue that attaches Paxis's MCP connectors and existing tool environments to the RL loop with minimal friction. The two products interlock: ai-platform supplies the GPU queues and on-premises RL pipeline, and Paxis consumes that pipeline as the engine for skill evolution.

This is closer to a roadmap than a shipped feature. Even so, the structural alignment between the ai-platform stack (K8s, Kueue, vLLM) and Paxis's self-evolving skill architecture on one side, and what slime actually assumes on the other, shows this is not a forced fit.

## Limitations and Counterarguments

slime is not a silver bullet. Let us state a few realistic constraints clearly.

The biggest barrier to entry is **compute and operational complexity**. Standing up Megatron + SGLang + Ray simultaneously and orchestrating training/rollout across multiple GPUs is by no means lightweight. This is not a tool a single GPU or a small team can casually run, and RL post-training itself demands an infrastructure investment comparable to pretraining. There is a considerable gap between "the framework is open" and "we can run RL post-training."

Second, **the difficulty of RL post-training**. Reward design, reward-hacking prevention, and training stability are intrinsic hardships the framework does not solve for you. slime provides infrastructure only; a good reward function and a stable training recipe remain the user's responsibility. That Z.ai separately emphasized anti-hacking is itself evidence of how tricky this area is.

Third, **the limits of our verification scope**. This post analyzed the structure based on slime's public documentation and reporting; we did not directly reproduce the full RL training loop to measure throughput. Therefore claims like "GLM-5.2-class training in a few days" are not facts we independently confirmed. Anyone considering adoption must first pilot with a small model and small task in colocated mode to measure the actual cost in their own environment.

Even so, an event where the model weights and the training framework open together is rare transparency in the open-LLM ecosystem. For a platform like ThakiCloud that operates infrastructure directly, the set of options that grant control all the way down to the post-training stage, beyond merely using someone else's model, has grown.

## Sources

- [THUDM/slime - GitHub](https://github.com/THUDM/slime)
- [slime: An SGLang-Native Post-Training Framework for RL Scaling - LMSYS Org](https://www.lmsys.org/blog/2025-07-09-slime/)
- [GLM-5.2: Built for Long-Horizon Tasks - Hugging Face Blog](https://huggingface.co/blog/zai-org/glm-52-blog)
- [Day-0 Support for the SGLang-Native RL Framework slime on AMD Instinct GPUs - ROCm Blogs](https://rocm.blogs.amd.com/artificial-intelligence/slime/README.html)
