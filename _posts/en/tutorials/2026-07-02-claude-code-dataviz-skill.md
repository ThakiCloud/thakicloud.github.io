---
title: "Claude Code's /dataviz Skill: Treating Charts as Design, Not Just Code"
excerpt: "The /dataviz skill added in Claude Code 2.1.198 loads chart and dashboard design guidance directly into context. We break down the form heuristic, color formula, and runnable palette validator, and look at how ThakiCloud's platform can put it to use."
tags:
  - claude-code
  - dataviz
  - data-visualization
  - dashboard
  - skill
date: 2026-07-02
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/claude-code-dataviz-skill/"
header:
  image: /assets/images/claude-code-dataviz-skill-hero.webp
categories:
  - tutorials
---

## Overview

Anyone can write code that draws a chart. Pulling a bar chart out of `matplotlib` or wiring a dashboard together with Recharts takes only a few lines. The problem is that most of what comes out of that process cannot actually be read. Axes that do not start at zero exaggerate differences, every series gets a different color so you have to check the legend three times, and switching to dark mode collapses the contrast until the labels disappear. The code runs, but the picture does not help anyone make a decision.

Claude Code 2.1.198 added a built-in skill, `/dataviz`, aimed squarely at this gap. The official changelog describes it in one short line as providing "chart and dashboard design guidance," but what it actually does is turn charts back from a coding problem into a design problem. Before a single line of code is written, it loads guidance into context on which form to choose, how to assign color, and how to protect accessibility. It is worth a close look because it inverts the "draw first, polish later" order that keeps repeating whenever we build a GPU usage dashboard or a model evaluation report at ThakiCloud.

## What the /dataviz Skill Is

`/dataviz` is a reference skill meant to be read right before you build any chart, graph, or dashboard, in any output medium. It does not care whether the target is an HTML or React artifact, inline SVG, library code in `matplotlib`, `plotly`, d3, or Recharts, a PNG you will render and upload, or a chart you are about to share in Slack. It is designed to be loaded before you write the first line of chart code, before you pick chart colors, and before you lay out a KPI tile, a meter, or a row of metrics.

The key point is that it is not tied to any specific design system. The skill ships a brand-neutral placeholder palette as its default and instructs you to swap those values for your own brand colors. In other words, it is closer to "use this method for picking colors" than "use this color." Because it teaches a method, the same discipline applies even when the palette differs from project to project.

The scope of the skill becomes clear once you look at what triggers it. Words like chart, graph, plot, data visualization, and dashboard trigger it, and so does every individual component of a visualization: categorical color, sequential and diverging palettes, stat tiles, sparklines, heatmaps, legends, axes, and tooltips. Whether you are drawing one full chart or placing a single KPI row, you pass through the same guidance either way.

## What This Skill Loads Into Context

The guidance `/dataviz` loads breaks down into four blocks: a form heuristic, a color formula, a runnable validator, and mark specs paired with interaction rules.

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
<div class="d3-arch" data-arch-root id="02claudecodedatavizskill-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 339, "height": 1026, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 28, "y": 24, "w": 191, "h": 62, "title": ["Visualization request", "(chart, dashboard, KPI)"]}, {"id": "B", "x": 28, "y": 164, "w": 191, "h": 62, "title": ["Form heuristic", "Data shape → chart form"]}, {"id": "C", "x": 24, "y": 304, "w": 198, "h": 78, "title": ["Color formula", "Categorical, sequential,", "diverging assignment"]}, {"id": "D", "x": 95, "y": 460, "w": 212, "h": 78, "title": ["Run palette validator", "Contrast and accessibility", "check"]}, {"id": "E", "x": 36, "y": 616, "w": 174, "h": 52, "title": "Validation passed?"}, {"id": "F", "x": 28, "y": 760, "w": 191, "h": 78, "title": ["Mark spec + interaction", "rules", "Axes, legend, tooltip"]}, {"id": "G", "x": 24, "y": 916, "w": 198, "h": 78, "title": ["Consistent visualization", "Same system, light and", "dark"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [123, 86, 123, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [123, 226, 123, 304]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[162, 382], [201, 421], [201, 421], [201, 460]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[201, 538], [201, 577], [201, 577], [154, 616]]}, {"src": "E", "dst": "C", "kind": "data", "label": "\"No\"", "curve": [[92, 616], [45, 577], [45, 421], [84, 382]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "\"Yes\"", "line": [123, 668, 123, 760], "lx": 123, "ly": 710}, {"src": "F", "dst": "G", "kind": "data", "line": [123, 838, 123, 916]}]});
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
      const container = document.getElementById('02claudecodedatavizskill-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '02claudecodedatavizskill-1';
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

The **form heuristic** is the rule set that decides the chart's form based on the data's shape. Whether the data is a time series, a distribution, a part-to-whole relationship, or geographic changes which mark is appropriate. Having this step is what lets you break the habit of reaching for a pie chart by default. Principles long established in the data visualization field, such as why a pie chart is a bad choice in most cases and why a bar chart's axis should start at zero, are codified here as working rules. It is essentially the norms laid out by people like Edward Tufte and Cole Nussbaumer Knaflic, translated into a skill's practical rule set.

The **color formula** treats color as part of the data rather than decoration. It assigns clearly distinguishable colors to categorical data, colors that step gradually in brightness to sequential data, and colors that diverge from a center point in both directions to diverging data. Instead of picking an arbitrary color per series, it matches color to the meaning structure of the data.

The **runnable palette validator** is the skill's real differentiator. It does not stop at guidance for picking colors, it checks in code whether the chosen palette actually reads. The validator checks color contrast and accessibility to determine whether text and marks are distinguishable enough in both light mode and dark mode. Because a deterministic check owns the pass/fail decision instead of a human eyeballing it, subjective judgments like "looks fine" are ruled out. The default palette is documented in `references/palette.md` with values that have already passed validation, and all you need to do is replace those values with your own brand colors.

The **mark spec and interaction rules** standardize the details of a chart. Decisions like how to draw the axes, where to place the legend, and what to put in the tooltip are fixed as rules instead of being remade every time. As a result, charts made by different people using different libraries end up reading as one system.

## How to Actually Use It

Using it is simple in itself. Load the skill before you start building a chart or dashboard, and the guidance from the four blocks above enters your context. From that point on, no matter which library you use, code is generated on top of the same discipline.

The point to watch is order. What the skill's description repeatedly emphasizes is to read it "before you write the first line of chart code." Fixing color after the code is already written is too late. Correcting a bar chart whose axis did not start at zero after the fact usually means reworking the scale and layout, and dark mode contrast problems often mean rebuilding the entire palette from scratch. Putting the design decision up front makes this rework disappear.

The fact that the same guidance applies to charts shared in Slack is especially useful in practice. An ad hoc chart pasted into a team channel usually suffers a double bind of being the most carelessly made and the most widely read. Once it passes through this skill, even that kind of chart follows the same rules as a formal dashboard.

## Implications for ThakiCloud's Products

The message `/dataviz` is sending overlaps exactly with the principle ThakiCloud already practices across two products: do not leave format and quality to the model's improvisation, make it fill in a validated skeleton instead.

Through the **ai-platform lens**, we are constantly visualizing metrics like GPU usage, Kueue queue state, model serving latency, and per-tenant cost on top of our K8s-based AI/ML infrastructure. These observability dashboards are screens where an operator needs to spot an anomaly within seconds, so visual hierarchy directly translates into response speed. A flow that picks a chart matching the nature of each metric with the form heuristic, distinguishes normal, warning, and failure states through the meaning of color with the color formula, and guarantees dark mode contrast through the validator lifts the reliability of an operations dashboard directly. The discipline of using color as a status signal rather than decoration reduces misjudgment during on-call response.

Through the **Paxis lens**, `/dataviz` itself is a miniature of the Agent-Native Cloud we are building. Paxis is the agent control plane running on top of ai-platform, treating skills as first-class resources and selecting from roughly 960 skills with BM25 to run them in an isolated sandbox. The way `/dataviz` packages "the ability to draw a chart" into a single skill and loads it into context when needed is the same structure as Paxis's Skill Harness, which bundles knowledge and discipline into reusable skill units. The runnable palette validator in particular is the data visualization version of a principle we have kept across several batch skills: numbers and verdicts are not asserted by the model, deterministic code owns them. The model proposes a color, and code checks whether that color actually reads. Without this separation, output produced by many different people and many different agents cannot converge into one system.

The two lenses complement each other. ai-platform pulls out the metrics, and Paxis safely runs the skill that renders those metrics into a consistent visual language. Low-cost infrastructure makes observability cheap, and the skill harness turns that observability into a picture that can actually be read.

## Limits and Counterarguments

`/dataviz` is not a silver bullet. What the skill loads is guidance, not autocompletion, so a human or an agent still has to write the chart. If you ignore the guidance and write the code first anyway, loading the skill was pointless. Order discipline is not something the tool can enforce on its own.

There is also a cost in context consumption. Loading the skill spends tokens. Loading the full guidance every time for a chart you only need to sketch quickly can be overkill. It earns its keep for dashboards and reports where quality is the whole point of the output, but there is no reason to force it onto a one-off scratch plot.

The fact that the default palette is brand-neutral is also a double-edged sword. Use it as is without swapping it out, and you get a bland, characterless chart that could belong to any company. Skip the one step of replacing the values in `references/palette.md` with your own brand, and you gain consistency but lose identity. The skill gives you a method, and the final decision of putting a brand on top is still ours to make.

## Sources

- [Claude Code CLI 2.1.198 changelog (ClaudeCodeLog, X)](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- Claude Code's built-in `dataviz` skill description and `references/palette.md`
