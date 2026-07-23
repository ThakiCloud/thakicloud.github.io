---
title: "The Gains From Self-Evolving Harnesses May Be an Illusion: Separating Harness Updating From Harness Benefit"
seo_title: "Rethinking Self-Evolving Agent Harness Evaluation - Separating Updating From Benefit - Thaki Cloud"
seo_description: "The performance gains attributed to self-evolving agent harnesses mix two distinct abilities together. Separate the ability to update a harness from the ability to benefit from an updated harness, and updating turns out flat across model tiers while benefit peaks at mid-tier models. We unpack the findings of arXiv 2605.30621 and map what transfers to ThakiCloud Paxis's self-evolving skill loop, where skills are treated as first-class resources."
excerpt: "The gains attributed to self-evolving harnesses are a mix of 'the ability to produce good updates' and 'the ability to use those updates well,' tangled together within a single loop. Separate the two, and the question of where to spend your capability budget flips."
date: 2026-07-16
tags:
  - self-evolving-agents
  - agent-harness
  - evaluation
  - skill-library
  - llm-agents
  - agentops
  - paxis
  - benchmarking
categories:
  - agentops
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/self-evolving-harness-evaluation/"
---

Anyone who has run agents for a while has probably seen a graph like this: an agent revises its own prompts, skills, and memory over time, the benchmark score climbs, and the team concludes that "the self-evolving harness works." A recently published study argues that a large part of that graph may be an illusion. Until now, evaluation methods could not tell whether the rising score reflected a genuinely better harness or simply a model that was already good at following instructions. This piece is written for ML and platform engineers who run agents and evolve their skill libraries and harnesses in production. The bottom line up front: the reflex of saying "let's move up a model tier" whenever performance stalls turns out to be only half right, once you look at this study's data.

## Overview

The paper is titled "Harness Updating Is Not Harness Benefit." Read literally, updating a harness and benefiting from a harness are two different things. Most systems that work with self-evolving agents have measured these two as a single blob. An agent solves a task, extracts prompt or skill edits from the execution trace, runs the next task with the revised harness, and if the final score goes up, the system declares that "evolution worked."

The problem is that this verdict conflates two distinct abilities: the ability to produce a useful, durable update from execution evidence, and the ability to actually put that updated harness to work when solving a task. Both abilities live inside the same model, but they are fundamentally different in character. And because prior evaluations measured both **inside the same execution loop at once**, looking at the final score alone could not tell you where the improvement came from. The authors propose an experimental design that untangles this conflation, and the result runs directly against conventional wisdom in the field.

## What This Research Asks

First, some terminology. Here, a **harness** refers to the entire set of editable, external components that shape an agent's behavior without touching the model's parameters. Prompts, skills, memory, and tool definitions are all part of the harness. Self-evolution is the process by which an agent reviews its own execution outcomes and revises this harness on its own. The model stays fixed; only the surrounding knowledge and tooling change.

The study splits this evolution process into two abilities.

The first is **harness-updating**: the ability to look at evidence from a completed task and produce a useful, reusable, persistent update. Extracting a lesson from a failed case and writing it into a skill document, or noticing a recurring pattern and hardening it into a prompt rule, both fall under this category.

The second is **harness-benefit**: the ability, given an updated harness, to actually retrieve it and follow it to raise task performance. A good skill sitting unused in the library, or a skill that gets invoked but whose instructions are not followed through to the end, both produce zero benefit.

The key insight is that these two abilities must be **measured separately**. If you pair the model that produced the update with a different model that uses the update, you can tell whether an improvement came from the quality of the update or the quality of how it was used. The diagram below shows the structure of the conflation and where the separation happens.

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
<div class="d3-arch" data-arch-root id="volvingharnessevaluation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 621, "height": 1060, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 170, "y": 24, "w": 128, "h": 46, "title": "Task Execution"}, {"id": "B", "x": 128, "y": 148, "w": 212, "h": 46, "title": "Collect Execution Evidence"}, {"id": "C", "x": 136, "y": 272, "w": 195, "h": 100, "title": ["Harness-Updating", "Capability", "Generate persistent", "updates from evidence"]}, {"id": "D", "x": 256, "y": 464, "w": 198, "h": 78, "title": ["Updated Harness", "Prompts, Skills, Memory,", "Tools"]}, {"id": "E", "x": 240, "y": 620, "w": 230, "h": 84, "title": ["Harness-Benefit Capability", "Invoke and faithfully", "follow updates"]}, {"id": "F", "x": 381, "y": 812, "w": 198, "h": 46, "title": "Task-Solving Performance"}, {"id": "G", "x": 374, "y": 966, "w": 212, "h": 62, "title": ["Measured Gain", "Two capabilities entangled"]}, {"id": "H", "x": 24, "y": 464, "w": 177, "h": 78, "title": ["Flat", "Similar regardless of", "model tier"]}, {"id": "I", "x": 135, "y": 796, "w": 191, "h": 78, "title": ["Non-monotonic", "Mid-tier models benefit", "most"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [234, 70, 234, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [234, 194, 234, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[297, 372], [355, 418], [355, 418], [355, 464]]}, {"src": "D", "dst": "E", "kind": "data", "line": [355, 542, 355, 620]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[415, 704], [480, 750], [480, 750], [480, 812]]}, {"src": "F", "dst": "G", "kind": "event", "label": "Measured together in the same loop", "line": [480, 858, 480, 966], "lx": 480, "ly": 916}, {"src": "C", "dst": "H", "kind": "event", "label": "Separated measurement", "curve": [[171, 372], [113, 418], [113, 418], [113, 464]], "off": "50%"}, {"src": "E", "dst": "I", "kind": "event", "label": "Separated measurement", "curve": [[295, 704], [230, 750], [230, 750], [230, 796]], "off": "50%"}]});
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
      const container = document.getElementById('volvingharnessevaluation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'volvingharnessevaluation-1';
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

## What Separating the Two Abilities Reveals

The result of the separated experiment comes down to two sentences. Both run against practical intuition.

First, **harness-updating capability is flat across model tiers.** Harness updates produced by models of very different capability tiers delivered surprisingly similar gains. In the authors' own words, updates produced by a small 9B-scale model matched the gains delivered by updates from a top-tier frontier model. In other words, "who wrote the skill" barely moved the quality of the update. Extracting a rule and hardening it into documentation turns out to be a cheaper cognitive task than expected.

Second, **harness-benefit capability is non-monotonic across tiers.** Given the same updated harness, weak-tier models saw almost no gain, mid-tier models gained the most, and top-tier models gained less than the mid-tier models did. Rather than a curve that keeps climbing as you move up, it is a curve that bulges in the middle.

Overlay these two results and the picture flips. Assigning an expensive frontier model to the **evolver** role, the one that produces updates, in a self-evolving system is close to wasted budget, since update quality is flat regardless. Assigning an expensive model to the **agent that actually solves tasks** is not necessarily optimal either, since benefit is non-monotonic. A strong model already has its own habits set, and tends to follow an external harness's instructions less closely.

## Why Weaker Models Don't Benefit

The most practically useful part of the paper analyzes why weak-tier models fail to benefit. The authors point to two failure modes.

The first is **activation failure**. Even when a skill in the library is a perfect match, the model fails to retrieve it. The judgment required to connect a relevant harness artifact to the current situation simply does not fire. The skill exists, but gets dropped at the retrieval and selection stage, so no amount of accumulated updates helps.

The second is **unfaithful execution**. The model successfully retrieves the skill, but fails to follow its multi-step instructions through to the end. When the ability to hold a long chain of instructions is weak, a good harness gets derailed into a partial, drifted execution partway through.

This diagnosis points to a clear prescription. To raise self-evolution performance, don't raise the evolver's intelligence, target **harness invocation (activation) and faithful execution of long instructions**. Your capability budget buys more when spent on the side that uses updates, specifically on these two bottlenecks, rather than on the side that produces them.

## Implications for ThakiCloud Products

This study's conclusion lines up closely with the discipline we've built running Paxis. Paxis is ThakiCloud's Agent-Native Cloud, and it treats skills, tools, and policies as first-class resources. We select from more than 960 skills using BM25 and execute them in isolated sandboxes, and our self-evolving skill loop extracts lessons from failures and revises skill documentation. In other words, we already run a "harness-updating" loop every day.

The first lesson this study offers is: **don't attach an expensive model to the evolver.** A nightly evolution loop that improves skills and logs retrospectives can run on a low-cost tier under the premise that update quality is flat. In fact, our skill model policy already starts evolution and orchestration stages on sonnet by default, pinning a higher-tier model only for the small set of skills where content quality is itself the deliverable. This study gives that choice an evidentiary basis: it was **optimization with no quality loss**, not just cost savings.

The second lesson is the diagnosis that the bottleneck is "activation and execution." In our environment, this is precisely the problem of **skill routing and gate compliance**. No matter how many skills exist, if the right one is not retrieved at request time, that is activation failure, and if a skill is invoked but its deterministic gates are not honored, that is unfaithful execution. Paxis's decision to strengthen skill retrieval with a BM25 router, and to have format and validation owned by code gates rather than the model's own prose judgment, targets exactly these two bottlenecks. Performance is decided less by piling on more good skills and more by the plumbing that retrieves the right skill precisely and enforces its instructions to the end.

There is an infrastructure implication too. ai-platform serves multiple model tiers on top of K8s and Kueue. This study suggests that when deploying a self-evolving pipeline, it is reasonable to place **different model tiers in different roles** for the evolver and the task solver. A mixed deployment, a cheap model as evolver and a mid-tier model as the task solver, is a design that can save substantial cost in multi-tenant GPU scheduling while holding quality steady.

## Limitations and Counterarguments

Before carrying this study straight into practice, a few caveats are worth naming.

First, the conclusions of "flat" and "non-monotonic" are tied to the task distribution and harness types the experiments covered. Rule-extraction work like revising skill documentation may show flat updating capability, but updates that involve implementing complex tools or generating long orchestration code may well reopen the gap between model tiers. Whether our own updates lean toward the former or the latter is something each team has to measure for itself.

Second, the finding that top-tier models benefit less from an external harness can also be read as a ceiling effect: a strong model is already good, so there is less room left to improve. This does not mean the harness is useless. Absolute performance can still be higher for a strong model; the harness is simply a marginal gain layered on top.

Third, for an organization like ours that already practices "evolve cheap, gate expensive," this study reads less like a new direction and more like quantitative backing for an existing discipline. For a team that has been reflexively raising the evolver model's tier whenever self-evolution performance stalls, on the other hand, this data is a clear signal to reallocate budget.

## Conclusion

In the end, this study leaves us with one practical rule. Don't look at a self-evolving harness's performance as a single score. **Decompose it into two axes, updating and benefit, and measure each separately.** Only once you separate them does it become clear where your capability budget should actually go.

## Sources

- Harness Updating Is Not Harness Benefit: Disentangling Evolution Capabilities in Self-Evolving LLM Agents, arXiv 2605.30621: [arxiv.org/abs/2605.30621](https://arxiv.org/abs/2605.30621)
- Hugging Face Papers page: [huggingface.co/papers/2605.30621](https://huggingface.co/papers/2605.30621)
- Related background: Agentic Harness Engineering, arXiv 2604.25850: [arxiv.org/html/2604.25850v3](https://arxiv.org/html/2604.25850v3)
