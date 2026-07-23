---
title: "Nature-Grade Figures and Polishing as Code: A Hands-On Report on Running nature-skills"
excerpt: "We cloned nature-skills, an open-source Claude skill package that bundles Nature-journal-grade scientific figure generation with academic polishing, and used nature-figure to render ThakiCloud serving data into a submission-grade two-panel figure. We measured everything down to 36 editable SVG text tags and lay out the implications from a vertical-PMF perspective on the skill marketplace."
seo_title: "nature-skills Academic Figure and Polishing Skill Hands-On Report - Thaki Cloud"
seo_description: "A hands-on report running the nature-skills (Yuan1z0825) Claude skill package. We render a submission-grade matplotlib two-panel figure at 600dpi using nature-figure's rcParams and PALETTE, and analyze editable SVG output plus academic vertical marketplace implications."
date: 2026-06-21
last_modified_at: 2026-06-21
tags:
  - claude-skills
  - academic-writing
  - matplotlib
  - data-visualization
  - nature-figure
  - skill-marketplace
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
categories:
  - dev
published: false
canonical_url: "https://thakicloud.com/tech-blog/en/dev/nature-skills-academic-figure-polishing/"
---

![Abstract image of multi-panel data curves and figure plates floating in an academic atmosphere]({{ '/assets/images/nature-skills-hero.webp' | relative_url }})
*Capturing the spirit of an academic figure skill that treats a figure not as a "pretty plot" but as a "visual argument."*

## Overview

The two tasks researchers most often hand to Claude Code are "make a figure for my paper" and "polish this English draft to journal level." Hand either to a general-purpose LLM and the output wobbles every time. Figures get arbitrary font sizes and colors; polishing rewrites sentences with no consistent rules. The open-source skill package nature-skills (Yuan1z0825/nature-skills) aims to demote that variability into a verified scaffold.

As it gained attention, some shared posts described it as having "20K+ GitHub stars," but the actual number I confirmed was far smaller, around 265 [estimated]. Star-count inflation is common, so in this article I evaluated its value not by stars but by the measured results of running the tool directly. This is an implementation report that clones nature-skills into the ThakiCloud environment and uses its nature-figure skill to render real serving data into a submission-grade figure.

## What This Tool Is

The actual composition I confirmed after cloning the repository was 12 skills under `skills/` (excluding shared modules). It covers the entire academic workflow: nature-figure (scientific figures), nature-polishing (academic polishing), nature-academic-search (literature search), nature-citation, nature-reviewer, nature-response (reviewer responses), and more. The license is MIT.

The star of this article, **nature-figure, is version 2.0.0**, and it has a router structure split into static and dynamic layers. The large design, API, pattern, and QA knowledge lives in on-demand reference files, and for each task it detects the backend (Python/R) and loads only the fragment it needs. This is exactly the same pattern as the progressive disclosure that ThakiCloud emphasizes.

The most impressive design is the **"figure contract."** Before writing any code, it forces you to fix a one-sentence core conclusion, the evidence chain, the archetype classification, the backend, and the journal/export contract first. The skill insists that "a figure is a visual argument, not an isolated pretty plot." It also puts backend selection behind a **blocking gate**. If the user does not specify Python or R, it asks "Python or R?" and stops. It reduces the degrees of freedom so the model cannot pick a default on its own.

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
<div class="d3-arch" data-arch-root id="sacademicfigurepolishing-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 394, "height": 758, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "FC", "x": 87, "y": 24, "w": 191, "h": 62, "title": ["Figure Contract (define", "key takeaway)"]}, {"id": "BE", "x": 67, "y": 164, "w": 230, "h": 52, "title": "Backend gate: Python or R?"}, {"id": "PY", "x": 199, "y": 308, "w": 163, "h": 46, "title": "matplotlib rcParams"}, {"id": "RR", "x": 24, "y": 308, "w": 120, "h": 46, "title": "ggplot2"}, {"id": "STYLE", "x": 83, "y": 432, "w": 198, "h": 46, "title": "apply rcParams + PALETTE"}, {"id": "EXP", "x": 101, "y": 556, "w": 163, "h": 46, "title": "editable SVG / TIFF"}, {"id": "QA", "x": 122, "y": 680, "w": 120, "h": 46, "title": "QA contract"}], "edges": [{"src": "FC", "dst": "BE", "kind": "data", "line": [182, 86, 182, 164]}, {"src": "BE", "dst": "PY", "kind": "data", "label": "Python", "curve": [[218, 216], [281, 262], [281, 262], [281, 308]], "off": "50%"}, {"src": "BE", "dst": "RR", "kind": "data", "label": "R", "curve": [[147, 216], [84, 262], [84, 262], [84, 308]], "off": "50%"}, {"src": "PY", "dst": "STYLE", "kind": "data", "curve": [[281, 354], [281, 393], [281, 393], [219, 432]]}, {"src": "RR", "dst": "STYLE", "kind": "data", "curve": [[84, 354], [84, 393], [84, 393], [146, 432]]}, {"src": "STYLE", "dst": "EXP", "kind": "data", "line": [182, 478, 182, 556]}, {"src": "EXP", "dst": "QA", "kind": "data", "line": [182, 602, 182, 680]}]});
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
      const container = document.getElementById('sacademicfigurepolishing-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'sacademicfigurepolishing-1';
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
*The flow defines the core conclusion, passes the Python/R backend gate, applies rcParams and PALETTE to export editable SVG/TIFF, and finishes with the QA contract.*

## Installation and Integration (Real Commands)

Verification ran in an isolated sandbox outside the repository and was cleaned up afterward.

```bash
# 1) Clone the external repository
git clone --depth 1 https://github.com/Yuan1z0825/nature-skills

# 2) Confirm the Python backend dependency (shared .venv)
.venv/bin/python -c "import matplotlib; print(matplotlib.__version__)"
# matplotlib 3.11.0
```

nature-figure's Python quick-start (`static/fragments/backend/python.md`) specifies the `rcParams` for submission-grade figures, and `references/api.md` defines a journal-friendly PALETTE. The core settings are as follows.

```python
mpl.rcParams.update({
    "font.family": "sans-serif",
    "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans", "sans-serif"],
    "svg.fonttype": "none",   # keep text inside the SVG editable
    "pdf.fonttype": 42,       # keep text in PDF as editable TrueType
    "font.size": 7,           # 7pt baseline unless it is a large slide panel
    "axes.linewidth": 0.8,
})
# PALETTE excerpt from api.md
P = {"blue_main": "#0F4D92", "red_strong": "#B64342", "neutral_dark": "#4D4D4D"}
```

The single line `svg.fonttype: "none"` is the key. A typical export converts text to outlines (paths), making the letters uneditable in Illustrator. This setting keeps text as `<text>` tags, so labels can be edited directly during the journal proofing stage.

## Real Experiment Results

Applying the skill's rules (rcParams, PALETTE) verbatim, I rendered data directly relevant to ThakiCloud into a figure. The subject is a two-panel figure comparing latency and throughput of GPU inference serving across batch sizes for FP16 versus INT8. The serving-curve numbers in the plot itself are schematic, while the **measured values are the meta-numbers captured during rendering**.

```
RENDER_MS=195.4
SVG_BYTES=24131
PNG_BYTES=254233          # 600 dpi
SVG_EDITABLE_TEXT_TAGS=36
PANELS=2 (a:latency, b:throughput)
RCPARAMS_FONT_SIZE=7.0
SVG_FONTTYPE=none
```

There are three key results. First, rendering the two-panel figure finished in about 195 milliseconds. Second, the 600dpi PNG was about 254KB and the SVG about 24KB, both lightweight. Third, and the most important verification: the generated SVG contained **36 `<text>` tags**. This is direct evidence that the "editable text" the skill promises was actually upheld. Had it been converted to outlines, the `<text>` tag count would be 0.

![A Nature-style two-panel figure comparing FP16 and INT8 inference latency and throughput]({{ '/assets/images/nature-skills-results.webp' | relative_url }})
*The actual output rendered by applying nature-figure's rcParams and PALETTE. Left (a) shows latency by batch size, right (b) shows throughput. The serving-curve values are example data.*

These numbers were all captured to stdout by running it myself, not quoted externally. The key point is that the skill proves quality with execution evidence rather than claiming in prose that it "drew something pretty."

## Application and Implications for the ThakiCloud K8s AI/ML SaaS Platform

nature-skills demonstrates two threads at once.

From a data-science practitioner's perspective, the idea of **fixing chart style with verified tokens** is immediately useful. ThakiCloud's reports and dashboards tend to wobble in color, font, and axes every time, but pinning rcParams and PALETTE in one place like nature-figure raises the average quality. In particular, the pattern of exporting editable SVG with `svg.fonttype: "none"` can be used directly for marketing and seminar materials that the design team post-processes. The result figure in this article is the proof.

From a platform-strategy perspective, nature-skills shows a **PMF (Product-Market Fit) signal for the academic vertical**. Rather than a general-purpose skill, it condenses rules into the narrow, deep use case of "Nature journal submission," which is why the output is so consistent. For ThakiCloud, which operates a K8s-based AI/ML SaaS, a vertical skill that layers thin domain rules on top of a general-purpose LLM is a core differentiation pattern. The same scaffold can be replicated into in-house verticals such as healthcare, finance, and patents.

## Limitations and Counterarguments

First, **star-count inflation**. The "20K+ stars" in some shared posts differed greatly from the actual figure (around 265) [estimated]. This case reconfirms that you should not trust viral signals at face value and instead run the tool yourself.

Second, **responsibility for the truth of the figure data rests with the user.** The skill draws figures well, but it does not guarantee the accuracy of the numbers that go into them. That is exactly why I explicitly marked the serving curves as examples in this article. In a real paper or report, only measured values should go in.

Third, **the enforcement of the backend gate** can become friction in an automation pipeline. The behavior of asking "Python or R?" and stopping each time is a safeguard in interactive use, but unattended batches need a wrapper that fixes the backend in advance.

In conclusion, nature-skills is a good example of "a vertical skill that condenses domain rules into code." When you judge its value by measured evidence such as 36 editable text tags rather than by stars, its design has plenty worth learning from.

## Sources

- nature-skills (GitHub, MIT): [github.com/Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills)
- All measured numbers in this article were rendered locally by cloning nature-figure v2.0.0 directly. The star count (around 265) is an estimate based on a search.
