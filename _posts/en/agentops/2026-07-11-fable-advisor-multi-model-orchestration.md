---
title: "A Cross-Vendor Workflow Where Fable 5 Conducts and Grok 4.5 Implements: fable-advisor"
seo_title: "Conducting Grok 4.5 with Fable 5 - fable-advisor Plugin Analysis - Thaki Cloud"
seo_description: "fable-advisor is a cross-vendor multi-agent workflow where Claude Fable 5 handles specs and reviews while Grok 4.5 does the actual implementation typing. We break down the conductor-worker split and verify it from ThakiCloud Paxis's perspective."
excerpt: "We break down the conductor-worker split of the fable-advisor plugin, in which Claude Fable 5 conducts spec writing and diff review while Grok 4.5 handles the actual code typing, and verify it from ThakiCloud's perspective of treating multi-agent systems and model routing as first-class resources."
date: 2026-07-11
lang: en
tags:
  - claude-code
  - multi-agent
  - model-routing
  - fable
  - grok
  - agentops
  - paxis
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/fable-advisor-multi-model-orchestration/"
---

Anyone who has used a coding agent for a while eventually arrives at a natural question. Writing a precise spec and sharply reviewing a resulting diff is a different kind of work from actually typing out code line by line, so why should the same single model have to do both? The recently released and widely discussed `fable-advisor` plugin answers this question head on. It is a cross-vendor workflow in which **Claude Fable 5 does nothing but conduct, while Grok 4.5 handles all of the actual implementation**. This post breaks down that structure and examines what this design suggests from ThakiCloud's operational perspective, where multi-agent systems and model routing are treated as first-class resources.

## Overview

Until now, multi-agent coding workflows have largely stayed within a single vendor. In Claude Code, Opus conducts while Sonnet or Haiku runs as subagents. What makes `fable-advisor` interesting is that it structures this division of labor **across vendor boundaries**. Anthropic's Fable 5 handles the orchestration layer, while xAI's Grok 4.5 handles the implementation layer.

The core insight of this design is straightforward. Conducting and implementing demand different capabilities, and they have different cost structures. Spec writing and diff review are matters of judgment and reasoning, so they require a model suited to conducting, whereas bulk code typing is where throughput and cost efficiency matter most. `fable-advisor` places each of these two roles on models from different vendors, letting each layer use whichever model fits it best. The fact that it is free and open source, with routing logic that can be customized directly, also lowers the barrier to real-world adoption.

## What This Technology Is

`fable-advisor` is a plugin layered on top of Claude Code that enforces a three-way separation of roles.

First, the **conductor (Fable 5)** writes specs and reviews outcomes. It takes the user's request, breaks it down into an implementation spec, and reviews the resulting diff once implementation is done. The important point is that the conductor **never writes code directly**. It focuses entirely on judgment and contract definition.

Second, the **implementer (Grok 4.5)** handles all the actual typing. It receives the spec passed down by the conductor and writes code through the Grok CLI, powered by Grok 4.5. Looking at the repository's history, starting with v3 the existing Sonnet/Opus implementation agent was replaced by `grok-implementer`, making Grok 4.5 the default typing lane. In other words, this plugin was not cross-vendor from the start; it is the result of an evolution that moved the implementation lane toward a lower-cost, higher-throughput model.

Third, there is **parallel execution**. Independent specs are run simultaneously as parallel agents. When the conductor breaks work down into units that do not depend on each other, each unit proceeds concurrently as a separate implementation agent. This is not simple sequential delegation but closer to a division of labor shaped like a DAG (directed acyclic graph).

The overall flow looks like this in diagram form.

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
<div class="d3-arch" data-arch-root id="rmultimodelorchestration-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 738, "height": 534, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 311, "y": 24, "w": 120, "h": 46, "title": "User request"}, {"id": "F", "x": 265, "y": 148, "w": 212, "h": 62, "title": ["Fable 5 conductor", "spec writing & diff review"]}, {"id": "S1", "x": 111, "y": 310, "w": 120, "h": 46, "title": "Spec A"}, {"id": "S2", "x": 557, "y": 310, "w": 120, "h": 46, "title": "Spec B"}, {"id": "G1", "x": 24, "y": 456, "w": 184, "h": 46, "title": "Grok 4.5 implementer A"}, {"id": "G2", "x": 470, "y": 456, "w": 184, "h": 46, "title": "Grok 4.5 implementer B"}, {"id": "R", "x": 286, "y": 302, "w": 170, "h": 62, "title": ["Integration & review", "result"]}], "edges": [{"src": "U", "dst": "F", "kind": "data", "line": [371, 70, 371, 148]}, {"src": "F", "dst": "S1", "kind": "data", "label": "split into independent specs", "curve": [[291, 210], [171, 256], [171, 256], [171, 310]], "off": "50%"}, {"src": "F", "dst": "S2", "kind": "data", "label": "split into independent specs", "curve": [[470, 210], [617, 256], [617, 256], [617, 310]], "off": "50%"}, {"src": "S1", "dst": "G1", "kind": "event", "label": "Grok CLI", "curve": [[171, 356], [171, 410], [171, 410], [134, 456]], "off": "50%"}, {"src": "S2", "dst": "G2", "kind": "event", "label": "Grok CLI", "curve": [[617, 356], [617, 410], [617, 410], [580, 456]], "off": "50%"}, {"src": "G1", "dst": "F", "kind": "data", "label": "diff", "curve": [[98, 456], [61, 410], [61, 256], [265, 205]], "off": "50%"}, {"src": "G2", "dst": "F", "kind": "data", "label": "diff", "curve": [[543, 456], [506, 410], [506, 256], [426, 210]], "off": "50%"}, {"src": "F", "dst": "R", "kind": "data", "line": [371, 210, 371, 302]}]});
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
      const container = document.getElementById('rmultimodelorchestration-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rmultimodelorchestration-1';
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

## Installation and Integration

Installing the plugin takes one line. You add the repository to Claude Code's plugin marketplace.

```bash
claude plugin marketplace add DannyMac180/fable-advisor
```

The Grok CLI, which handles the implementation lane, requires separate authentication. Logging in with `grok login` sets up OAuth authentication based on a SuperGrok or X Premium+ subscription, and according to the repository description, this path lets you run the implementation agent **without per-token API charges**, purely through your subscription. This is the crux of the cost structure. The conductor makes only a small number of judgment-heavy calls, while the bulk of code typing happens within the subscription plan, minimizing exposure to usage-based billing.

From an integration standpoint, it is worth noting that the routing logic is open. You can adjust directly which task goes to which model and under what conditions work gets parallelized, so a team can reconfigure the lanes to fit its budget and quality requirements.

## How This Design Actually Performs

`fable-advisor` is not a tool that touts benchmark numbers but a workflow pattern, so instead of reproducible performance figures, this section covers the structural effects the design produces. Since the repository does not present quantitative metrics, this post also avoids inventing numbers and sticks to structural benefits.

The biggest effect is the **separation of cost and quality**. When orchestration that requires judgment goes to the conductor and implementation that requires throughput goes to a low-cost implementer, the overall workflow's unit cost drops while judgment quality is preserved. The arrangement "call the conductor sparingly and cheaply, call the implementer often but not expensively" falls into place naturally.

The second effect is **cross-verification**. The fact that the implementer and the reviewer are models from different vendors produces an interesting side effect. When the same model reviews its own code, it tends to overlook the same mistakes it made in the first place, but when a model from a different lineage reviews the diff, there is more room for it to catch the other's blind spots. The conductor-worker split becomes more than a simple division of labor; it functions as a kind of mutual verification mechanism.

The third effect is **reduced latency through parallelization**. When independent specs are implemented at the same time, total working time converges not to the sequential sum but to the length of the single longest chain. The better the conductor breaks work down, the larger this benefit becomes.

## Generalizing the Conductor-Worker Pattern

If we look at `fable-advisor` not as an individual plugin but as a design pattern, a broader context comes into view. The essence of this pattern is "the main session only conducts, and heavy work gets delegated." Crossing vendors is just one variant of this pattern; it also holds within a single vendor. For example, a setup where Claude Code uses Fable 5 as the conductor, routes exploration to Haiku, implementation to Sonnet, and complex reasoning to an Opus subagent is already widely used. What `fable-advisor` did was extend the target models of this delegation beyond the vendor boundary.

Seen from this angle, the selection criteria for the conductor model become clear. Since the conductor is responsible for judgment, branching, and aggregation, accuracy and reasoning quality matter, but call frequency is relatively low. The implementer, by contrast, cares about throughput and unit cost. Good orchestration, then, is not "put the most expensive model in the conductor seat and route everything through it," but rather "place at each layer the model whose characteristics that layer actually requires." The v3 evolution that moved `fable-advisor`'s implementation lane to a low-cost subscription model is exactly the result of following this principle.

One thing worth watching is that this pattern only works if the boundaries of delegation are clear. If the conductor hands off an ambiguous spec, the implementer fills in the gaps by guessing, and the resulting review burden actually grows. The gains of delegation are realized only when the spec is sufficiently concrete. This is no different from division of labor in human organizations. The clearer the specification, the better delegation works.

## Implications for ThakiCloud's Products

This design overlaps strikingly with how ThakiCloud operates its own agents.

It is most directly relevant from a **Paxis perspective**. Paxis is ThakiCloud's Agent-Native Cloud control plane, and it treats DAG-shaped multi-agent execution as a core capability. The "spec writing to distributed implementation to cross review" structure that `fable-advisor` demonstrates shares the same skeleton as Paxis's skill harness, which breaks work into subtasks, runs them in parallel inside isolated sandboxes, and closes the loop with a verification stage. In particular, the principle that the conductor focuses on judgment and contract definition rather than writing code directly matches exactly with our own design philosophy of drawing capability from surrounding contract structures rather than model tier. The flow where the conductor reviews results produced by a different model also lines up with our own operating principle of closing multi-agent fan-out with a verification stage, so that hallucinations do not accumulate unchecked.

It also holds up from an **ai-platform perspective**, particularly around cost structure. ThakiCloud's ai-platform schedules GPU workloads on K8s and Kueue, serving the inference and training workloads of its customers. The idea behind `fable-advisor` of delegating the implementation lane to a low-cost model to bring down overall workflow unit cost is a pattern that GPU cloud customers can apply directly when designing their own workloads. When the small number of judgment steps that need heavy inference and the larger number of execution steps that need throughput are placed on resource tiers matched to each, the same result can be obtained at lower cost. Since low-cost serving is what makes agent economics work in the first place, ai-platform's cost efficiency and Paxis's agent orchestration complement each other.

## Limitations and Counterarguments

This design comes with clear trade-offs. The first is **operational complexity**. Weaving two vendors' models into a single workflow means managing two authentication systems, two pricing plans, and two points of failure. If one vendor's CLI changes or its authentication expires, the entire workflow can stop. This is a trade against the simplicity of a single-vendor workflow, and whether the benefit justifies the complexity may differ from team to team.

The second is **the risk of delegating quality**. Delegating implementation to a low-cost model means that if the conductor's spec and review are not tight enough, low-quality implementation can pass through unchecked. The quality of this workflow ultimately depends on how strict the conductor's review gate is. If the review is a formality, the cross-verification benefit of cross-vendor division of labor disappears, and what remains is a low-quality pipeline that merely saved on cost.

The third is **the constraint of subscription-based authentication**. The fact that the Grok CLI runs on subscription-based OAuth is a cost advantage for individuals or small teams, but for large-scale automation or unattended pipelines, subscription limits and authentication renewal can become bottlenecks. The advantage of having no usage-based billing is, flipped around, also a statement that scaling stops the moment usage exceeds the plan's limit.

Even so, the message `fable-advisor` sends is clear. The future of coding agents lies not in one all-purpose model but in orchestration that combines the model best suited to each layer. This points to exactly the same direction as ThakiCloud's approach of treating multi-agent systems and model routing as first-class resources.

## Sources

- [fable-advisor (GitHub)](https://github.com/DannyMac180/fable-advisor)
- [Grok CLI (x.ai/cli)](https://x.ai/cli)
