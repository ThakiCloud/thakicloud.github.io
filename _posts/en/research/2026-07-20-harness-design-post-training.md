---
title: "Harness Design and Post-Training Aren't Separable: Harness-Aware Post-Training and LLM Agent Performance"
excerpt: "Tool-using LLM agents run on top of a harness that wraps the model. A recent arXiv paper shows empirically that treating harness design and post-training as separate concerns breaks performance, especially when the tool environment shifts. We unpack this result through the lens of treating the harness as a first-class resource."
seo_title: "The Interplay of Harness Design and Post-Training in LLM Agents - Thaki Cloud"
seo_description: "A summary of The Interplay of Harness Design and Post-Training in LLM Agents (arXiv:2606.25447). We interpret the finding that harness informativeness lifts both zero-shot and post-trained performance, and that only harness-aware post-training generalizes robustly under tool environment shifts (OOD), through the lens of an agent-native cloud and inference/training infrastructure."
date: 2026-07-20
last_modified_at: 2026-07-20
canonical_url: "https://thakicloud.com/tech-blog/en/research/harness-design-post-training/"
lang: en
reading_time: true
tags:
  - agent-harness
  - harness-engineering
  - post-training
  - tool-use
  - llm-agents
  - ood-generalization
  - agent-native-cloud
  - rlvr
author_profile: true
toc: true
categories:
  - research
published: false
---

Any engineer who has operated an agent directly, or wired up a workflow heavy on tool calls, has shared one experience: even with the same base model, the agent behaves noticeably differently depending on the scaffolding it sits on (the tool list, tool descriptions, hints attached to observations). This scaffolding has recently come to be called the harness. This post is based on the paper [The Interplay of Harness Design and Post-Training in LLM Agents](https://arxiv.org/abs/2606.25447) (arXiv:2606.25447), published in June 2026. We summarize why designing a good harness and training the model well are not separate concerns, and what this result means for a cloud that actually serves agents in production. To state the conclusion up front: the harness is not a component you swap out after training finishes. It is something you must design together with the model, starting at the training stage.

## Overview: Why the Harness Matters Now

Over the past few months, the claim that "the code around the model matters more than the model itself" has come up more and more often. For tool-using agents, final performance depends as much on how tools are exposed and described, and on what gets returned as the observation at every step, as it does on the model weights. The survey [From Question Answering to Task Completion](https://arxiv.org/abs/2606.20683), which covers similar ground, also treats harness design as an independent research axis within agent systems.

The problem is that, up to now, these two things (harness design and post-training) have been handled as if they belonged to different teams. Research teams refine the policy through reinforcement learning, while platform teams tune the tools and prompts. This paper's contribution is showing that this division of labor is wrong. Harness informativeness and post-training are entangled multiplicatively: optimizing only one side leaves most of the other side's gains on the table. For a platform like ThakiCloud that already treats the harness as a first-class resource, this finding translates directly into an operating principle.

## What a Harness Is, and Where Performance Diverges

The paper defines the harness as "the scaffolding that wraps the model." Concretely, it is the layer that decides which tools to expose, how to describe those tools, and what auxiliary information rides along with the observation at every step. One cycle of a tool-calling agent looks like this:

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
<div class="d3-arch" data-arch-root id="arnessdesignposttraining-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1086, "height": 876, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 303, "y": 24, "w": 751, "h": 156, "label": "Harness: Scaffolding That Wraps the Model", "lx": 315, "ly": 42}], "nodes": [{"id": "U", "x": 146, "y": 79, "w": 120, "h": 46, "title": "User Task"}, {"id": "H", "x": 146, "y": 258, "w": 120, "h": 46, "title": "H"}, {"id": "T", "x": 341, "y": 71, "w": 191, "h": 62, "title": ["Select the exposed tool", "set"]}, {"id": "D", "x": 587, "y": 71, "w": 177, "h": 62, "title": ["Tool descriptions and", "signatures"]}, {"id": "O", "x": 819, "y": 63, "w": 198, "h": 78, "title": ["Auxiliary info and hints", "attached to each step's", "observation"]}, {"id": "M", "x": 135, "y": 534, "w": 142, "h": 46, "title": "LLM Policy Model"}, {"id": "A", "x": 370, "y": 658, "w": 184, "h": 46, "title": "Tool Calls and Actions"}, {"id": "E", "x": 110, "y": 782, "w": 191, "h": 62, "title": ["Environment Observation", "Returned"]}, {"id": "R", "x": 194, "y": 658, "w": 121, "h": 46, "title": "Task Complete"}, {"id": "PT", "x": 28, "y": 396, "w": 212, "h": 46, "title": "Policy Post-Training Stage"}], "edges": [{"src": "U", "dst": "H", "kind": "data", "line": [206, 125, 206, 258]}, {"src": "H", "dst": "M", "kind": "data", "curve": [[230, 304], [278, 350], [278, 488], [230, 534]]}, {"src": "M", "dst": "A", "kind": "data", "curve": [[277, 574], [462, 619], [462, 619], [462, 658]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[462, 704], [462, 743], [462, 743], [301, 787]]}, {"src": "E", "dst": "M", "kind": "data", "curve": [[184, 782], [157, 743], [157, 619], [188, 580]]}, {"src": "M", "dst": "R", "kind": "data", "curve": [[224, 580], [255, 619], [255, 619], [255, 658]]}, {"src": "H", "dst": "PT", "kind": "event", "label": "Harness-aware post-training", "curve": [[182, 304], [134, 350], [134, 350], [134, 396]], "off": "50%"}, {"src": "PT", "dst": "M", "kind": "event", "label": "Policy trained together with harness", "curve": [[134, 442], [134, 488], [134, 488], [182, 534]], "off": "50%"}]});
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
      const container = document.getElementById('arnessdesignposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arnessdesignposttraining-1';
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

The key variable here is the harness's informativeness. A highly informative harness describes tools richly and attaches useful hints to observations, so the model can pick the right tool while relying less on its own prior knowledge. A low-informativeness harness, by contrast, throws out only the bare minimum signature and leaves the rest to the model's own reasoning. This gap is what splits the results once it meets training.

## The Assumption This Paper Overturns

Anyone who has worked with agents tends to carry an implicit assumption: a good harness can just be bolted on right before deployment. Train the model well on its own, then later polish the tool descriptions and performance goes up: that is the expectation. The paper directly refutes this assumption.

First, even in the zero-shot setting (prompting alone, with no further training), performance improves monotonically as harness informativeness increases, and this effect is more pronounced in higher-capacity models. In other words, the prior knowledge baked into an information-rich harness is itself performance.

Second, and more importantly, comes the finding about the interaction with post-training. Compare a model trained with the harness folded in from the start against a model that gets the same harness bolted on only after training finishes: the latter recovers only a small fraction of the gains the former enjoyed. In other words, harness-aware post-training is not an add-on that boosts performance on top; it is a precondition for obtaining robust performance. Swapping in the harness after training is a half-measure.

## The Real Difference Shows Up When the Tool Environment Changes

The most practically relevant result comes from the out-of-distribution (OOD) experiments. Here, OOD refers to a tool environment not seen during training: tools added or swapped, or API signatures that have changed. In real-world operation, this kind of change is a constant. Tools keep growing in number, versions keep bumping, and the set of tools exposed differs from tenant to tenant.

The paper compares two branches. An agent that underwent harness-aware post-training with a highly informative harness holds up robustly even when the tool environment changes significantly, and generalizes across task groups. An agent trained with a low-effort, poorly designed harness, on the other hand, sees its performance collapse as the tool environment shift grows stronger, and fails to transfer to the new environment. In other words, the prior knowledge embedded in the harness acts as an anchor for generalization. A policy trained together with a well-designed harness retains a sense of what to call and how, even when facing unfamiliar tools, while a policy trained with a thin harness loses that sense entirely.

This point stings particularly for cloud operators. The classic reason an agent that scores well on benchmarks collapses in production is precisely tool environment drift. And this paper says that vulnerability is, to a significant degree, already determined at the harness design stage.

## Implications for ThakiCloud's Products

This finding touches both of ThakiCloud's product axes, so viewing it through only one lens would miss half the picture.

The first is the **Paxis lens**. Paxis is the control plane for the Agent-Native Cloud running on top of ai-platform, and it treats Skills, Tools, Policies, and Audit Logs as first-class resources. Translated into this paper's language, Paxis's Skill Harness is exactly the harness described here. Selecting the exposed tool set from roughly 960 skills via BM25, curating each skill's description and signature, and returning isolated sandbox execution results as the observation: the entire process determines harness informativeness. The paper's conclusion backs the design principle behind Paxis. Rather than exposing skills indiscriminately, selecting them for the task at hand to build a high-informativeness harness, and evolving that harness alongside the training and evaluation loop, is what leads to robustness under unfamiliar tool environments. The structure of routing every action through policy gates and audit logs is an extension of the same underlying concern: keeping the harness as something to experiment on and version, not something fixed.

The second is the **ai-platform lens**. The conclusion that harness-aware post-training is a precondition raises the value of keeping training and serving attached within a single piece of infrastructure. ai-platform runs post-training workloads such as fine-tuning and RLVR together with vLLM inference serving, on top of K8s and Kueue-based GPU scheduling. To reflect the harness at training time, the training pipeline needs to be able to reference the exact same tool schema and observation format used in serving. If training and serving are split across different organizations and different stacks, the harness drifts out of alignment, and you get trapped in the half-measure gains the paper warns about ("swap the harness in after training"). A setup that exposes different tool sets per tenant in a multi-tenant environment, while still meeting on-premise and sovereignty requirements by keeping training and serving self-hosted within one boundary, is well positioned to preserve this harness-training alignment.

The two lenses complement each other. Paxis manages the harness as a first-class resource, controlling its informativeness and versioning, while ai-platform feeds that harness into the training loop, turning harness-aware post-training into reality.

## Limitations and Counterarguments

To avoid over-interpreting this paper's results, a few caveats deserve attention.

First, the claim that "higher harness informativeness is better" comes with a cost attached. The more hints packed into observations, the longer the context grows, and the richer the tool descriptions, the more prompt tokens and latency increase. From a serving standpoint, informativeness is not free, and it needs to be weighed against throughput trade-offs. It is probably safer to read the paper's notion of informativeness not as "more is always better" but as "does it carry prior knowledge useful for the task."

Also, harness-aware post-training demands an entry cost: reworking the training pipeline. For the many practical settings that simply use an already-trained open-weight model as-is, zero-shot improvement through harness refinement alone remains a realistic first move. The paper itself shows that informativeness lifts zero-shot performance, so for teams without the capacity to train, this is a reasonable starting point.

Finally, it is hard to claim with certainty that the tool environment shifts covered by the paper's OOD experiments represent the full range of change seen in actual production. There is a gap between tool swaps on a benchmark and an operating environment where dozens of tenants are each updating their own APIs. Even so, the directional conclusion (that agents whose harness is designed together with training hold up better against change) is likely to matter even more in a real cloud where tools are constantly changing.

To sum up, this paper argues that the harness should be treated as a structure designed together with the model from the very first training stage, not as finishing trim applied right before deployment. The direction of managing the harness as a first-class resource and keeping training and serving inside one piece of infrastructure points exactly toward that recommendation.

## Sources

- The Interplay of Harness Design and Post-Training in LLM Agents, arXiv:2606.25447: <https://arxiv.org/abs/2606.25447>
- From Question Answering to Task Completion: A Survey on Agent System and Harness Design, arXiv:2606.20683: <https://arxiv.org/abs/2606.20683>
</content>
