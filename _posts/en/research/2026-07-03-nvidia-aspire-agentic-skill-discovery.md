---
title: "NVIDIA ASPIRE: Robots That Turn Failure Into Skills"
excerpt: "Robots throw away their trial and error every time they solve a task, then fumble from scratch on the next one. NVIDIA's ASPIRE is a continual-learning system where an LLM writes robot control code directly, observes failures during execution, repairs them, and distills the verified repair experience into a reusable skill library. Alongside the result that bimanual handover success rose from 20% to 92% with no extra training, we look at how ThakiCloud Paxis's self-evolving skill harness puts this loop into practice."
seo_title: "NVIDIA ASPIRE: Robot Skill Discovery and Continual Learning | Thaki Cloud"
seo_description: "A breakdown of NVIDIA GEAR's ASPIRE (arXiv 2607.00272): writing robot control code as policy, repairing failures and distilling them into skills, the 20%-to-92% handover result, and its application to the ThakiCloud Paxis skill harness."
date: 2026-07-03
last_modified_at: 2026-07-03
lang: en
categories:
  - research
tags:
  - agent-skills
  - robotics
  - continual-learning
  - code-as-policy
  - nvidia
  - llm-agents
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/en/research/nvidia-aspire-agentic-skill-discovery/"
published: false
---

![An abstract lattice of glowing nodes compounding into a dense, reusable structure]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-hero.webp' | relative_url }})

## Overview

Anyone who has run robots for a while sees a familiar waste. Even when a robot painstakingly succeeds at a task, most of the trial and error it went through is thrown away. On the next task it fumbles from scratch again. The fine-grained know-how earned through failure, such as how to recover when a gripper slips or the right approach angle for a particular object, is left nowhere in the system. A person reuses a knack once learned; a robot does not.

NVIDIA's GEAR team addressed exactly this with **ASPIRE** (Agentic /Skills Discovery for Robotics, arXiv 2607.00272), released on June 30, 2026. The idea is simple but powerful. Instead of injecting a fixed policy into the robot, a large language model (LLM) **writes the robot control code itself**, runs that code in the real execution environment, observes the failures, repairs it iteratively, and then distills the verified repair experience into **reusable Skills**. Experience is not discarded; it compounds.

This post lays out ASPIRE's architecture and measured results based on the verified paper and project page. It then argues that this is not a robotics-only story: the same pattern applies to software agents, and we close by connecting it to how ThakiCloud's Agent-Native Cloud, Paxis, treats skills as first-class resources.

## What ASPIRE Is

ASPIRE lays a continual-learning loop on top of the **code-as-policy** paradigm. Traditional robot learning often trains a neural policy on large volumes of demonstration data, then recollects data and retrains whenever a new situation appears. That carries two burdens: data collection is expensive, and knowledge learned once breaks easily in the face of new variations.

ASPIRE represents the policy not as neural-network weights but as **executable code**. When the LLM receives a task and writes a control program, that program runs in simulation or on a real robot. If execution fails, ASPIRE records the execution trajectory, analyzes the cause of failure, fixes the program, and tries again. Once this loop reaches success, the verified repair knowledge is stored in the skill library. The next task starts not empty-handed but by referencing that library.

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
<div class="d3-arch" data-arch-root id="ireagenticskilldiscovery-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 749, "height": 790, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 249, "y": 24, "w": 142, "h": 46, "title": "Task instruction"}, {"id": "B", "x": 224, "y": 148, "w": 191, "h": 62, "title": ["LLM writes control code", "code-as-policy"]}, {"id": "C", "x": 351, "y": 288, "w": 163, "h": 62, "title": ["Real execution", "simulation or robot"]}, {"id": "D", "x": 430, "y": 428, "w": 138, "h": 52, "title": "Success?"}, {"id": "E", "x": 526, "y": 572, "w": 191, "h": 62, "title": ["Log trajectory, analyze", "failure cause"]}, {"id": "F", "x": 354, "y": 712, "w": 156, "h": 46, "title": "Repair the program"}, {"id": "G", "x": 280, "y": 572, "w": 191, "h": 62, "title": ["Distill verified repair", "experience"]}, {"id": "H", "x": 105, "y": 712, "w": 184, "h": 46, "title": "Reusable skill library"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [320, 70, 320, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[369, 210], [432, 249], [432, 249], [432, 288]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[461, 350], [499, 389], [499, 389], [499, 428]]}, {"src": "D", "dst": "E", "kind": "data", "label": "Fail", "curve": [[543, 480], [622, 526], [622, 526], [622, 572]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "curve": [[622, 634], [622, 673], [622, 673], [502, 712]]}, {"src": "F", "dst": "C", "kind": "data", "curve": [[362, 712], [243, 603], [243, 454], [351, 349]]}, {"src": "D", "dst": "G", "kind": "data", "label": "Success", "curve": [[454, 480], [376, 526], [376, 526], [376, 572]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "curve": [[376, 634], [376, 673], [376, 673], [263, 712]]}, {"src": "H", "dst": "B", "kind": "event", "label": "next task references", "curve": [[156, 712], [88, 526], [88, 319], [224, 208]], "off": "50%"}]});
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
      const container = document.getElementById('ireagenticskilldiscovery-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ireagenticskilldiscovery-1';
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

The key is that last arrow. As the skill library feeds back into writing the next task, the system writes better code faster over time. The paper describes how this accumulated knowledge **transfers** across tasks in the form of grasp-recovery heuristics, navigation strategies, prompting recipes, and procedural fixes. It is not about solving one particular task well; the capacity to solve tasks itself accumulates.

## Distilling Failure Into Skills

What sets ASPIRE apart from other robot learning is how it treats failure. In most pipelines, failure is something to discard, or at best a negative signal that trims a reward. ASPIRE treats failure as **learning material**. A failed execution's trajectory contains the information of "what went wrong and why," and the LLM reads it to reason about where and how to fix the code.

If that repair ended as a one-off improvisation, its value would be limited. ASPIRE's contribution is **distilling the verified repair into a generalizable skill**. For example, if a slip while picking up a particular object is fixed into a success, the recovery procedure is abstracted into a form that is not tied to that object alone but can be reapplied to similar grasping situations. Because a skill is a code fragment expressed as text, a person can read and audit it, and it can be managed and versioned as a library. This is a major advantage over black-box neural policies.

Thanks to this structure, ASPIRE lifts performance **with no additional training data**. Instead of collecting new demonstrations to retrain the model, simply repeating the execute-fail-repair-distill loop raises the success rate. In robotics, where data collection is the bottleneck, this is a practically important property.

## Real Experimental Results

The numbers reported in the paper and project page show this loop is more than a concept. The most striking result is Robosuite's bimanual object handover task. Starting from a baseline success rate of **20%**, it climbed to **92%** through iterative debugging alone, a figure reached with zero additional demonstration data, using only the execute-repair loop.

The advantage holds as task types broaden. The paper reports that ASPIRE outperforms prior methods by up to **77%** on LIBERO-Pro (a manipulation task under perturbation), by **72%** on Robosuite bimanual handover, and by up to **32%** on BEHAVIOR-1K (a long-horizon household task). In particular, in the long-horizon generalization experiments, the success rate rose steadily as the skill library grew. The fact that library growth and performance rise together supports this system's central claim that experience genuinely compounds.

The research team spans NVIDIA's GEAR lab together with researchers from the University of Michigan (UMich), the University of Illinois (UIUC), UC Berkeley, and Carnegie Mellon (CMU). NVIDIA stated that ASPIRE's skill library would be open-sourced at release, with details on the project page (research.nvidia.com/labs/gear/aspire). That said, the specific license of the code repository was not confirmed as clearly stated at release time, so it is safer to check the actual repository's license terms directly before adopting it.

## Implications for ThakiCloud Products

ASPIRE targets a robot arm, but the message its architecture sends carries straight over to software agents. Take the sentence "an agent writes code, learns from failure, and distills verified experience into reusable skills stacked in a library," swap "robot" for "cloud agent," and you get exactly the structure ThakiCloud's Agent-Native Cloud, **Paxis**, is built toward.

Paxis treats Skills, Tools, Policies, and Audit Logs as first-class resources. ASPIRE's skill library corresponds in Paxis to a skill harness of some 960 skills selected via BM25, and ASPIRE's code-as-policy execution corresponds to Paxis's isolated sandbox execution. Just as ASPIRE records and analyzes failure trajectories, Paxis passes every agent action through a policy gate and audit log so that what failed and why can be traced retroactively. And the self-improvement that ASPIRE's distillation loop aims for is realized in Paxis as self-evolving skills: the lessons drawn from execution feed back into new skills or skill revisions, so the next run does not start empty-handed.

From an infrastructure standpoint, ThakiCloud's **ai-platform** provides the foundation for this loop. An ASPIRE-style repeated execute-repair loop has to run simulation and inference in bulk, which presupposes elastic scheduling of GPU resources. ai-platform is designed to absorb such repetitive workloads cost-effectively on top of Kueue-based GPU scheduling and multi-tenant isolation. Low-cost serving makes the agent's execute-repair repetition economical, and the skills accumulated that way in turn raise the agent's autonomy, a virtuous cycle. For customers who require on-premises and sovereign environments, being able to run this entire loop inside their own infrastructure is especially meaningful.

## Limitations and Counterarguments

Impressive as ASPIRE's results are, a few reservations are in order. First, the reported numbers come mostly from simulation benchmarks (Robosuite, LIBERO-Pro, BEHAVIOR-1K). Iterative debugging in simulation is cheap and safe, but on real hardware every attempt carries time, wear, and safety risk. Whether the economics of the execute-fail-repair loop hold on physical robots needs separate validation.

Second, code-as-policy is strong on tasks where the LLM can write valid control code, but for precise continuous control or actions needing high-frequency feedback, there remains a region hard to express as code. ASPIRE appears to delegate such low-level control to existing skills or primitives, and the quality of those primitives may cap overall performance.

Third, as the skill library grows, the burden of retrieval and selection increases. The result that library growth tracks with performance gains is encouraging, but whether picking a wrong skill or a stale skill triggering wrong answers becomes a problem at larger scale bears continued watching. This is a challenge Paxis's skill harness has already faced, and BM25 selection, the policy gate, and audit logs are precisely the mechanisms for managing that risk.

Even so, the direction ASPIRE points to, not discarding failure but compounding it as verified skills, is likely to become a standard on both the robotics and software-agent sides. The real contribution of this work is the shift in perspective: growing capability through accumulated skills rather than through data.

## Sources

- ASPIRE: Agentic /Skills Discovery for Robotics, arXiv 2607.00272: <https://arxiv.org/abs/2607.00272>
- Project page (NVIDIA GEAR): <https://research.nvidia.com/labs/gear/aspire/>
- Paper page (Hugging Face): <https://huggingface.co/papers/2607.00272>
