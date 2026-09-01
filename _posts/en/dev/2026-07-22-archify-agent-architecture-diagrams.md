---
title: "Drawing Architecture Diagrams With Words: We Ran Archify and Mapped the ThakiCloud Stack"
excerpt: "Archify is an agent skill that generates self-contained HTML architecture diagrams from plain-language descriptions, no Mermaid syntax required. We installed it and used it to diagram ThakiCloud's ai-platform structure, and found that the real value isn't the drawing itself but a renderer that forcibly validates layout. Here's why that design lines up with the skill-harness philosophy behind ThakiCloud's Paxis."
date: 2026-07-22
tags:
  - Archify
  - 아키텍처다이어그램
  - ClaudeCode
  - AI에이전트
  - 개발도구
  - 시각화
  - JSON-IR
  - paxis
author_profile: true
toc: true
toc_label: Archify in Practice
published: true
categories:
  - dev
  - agentops
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/archify-agent-architecture-diagrams/"
---

![An abstract image depicting many boxes and connecting lines converging into a single tidy grid structure]({{ '/assets/images/archify-agent-architecture-diagrams-hero.webp' | relative_url }})

## Why read this

This post is for **developers and platform engineers who draw architecture diagrams often but keep losing time to Mermaid syntax or drag-and-drop drawing tools**. It's meant to help anyone who needs a concrete basis for picking a tool.

Here's the conclusion up front. Archify's real value isn't the convenience of "draw a diagram by describing it in words." It's that **the renderer forcibly validates the layout an agent produces, so a broken diagram simply cannot be created.** When we actually ran it, our first attempt was rejected by the renderer, and that rejection is exactly what makes this tool worth using.

## Overview

Architecture diagrams are one of the outputs developers produce most often and dread most. Mermaid requires memorizing syntax. Drawing tools require dragging boxes and lines into place by hand. Even after you finish, dark mode often doesn't line up, or you have to re-export the file to drop it into a slide deck.

**Archify**, which recently gained traction in the Chinese developer community, targets exactly this pain point. Give Claude Code or Codex a plain sentence like "read these repositories and draw me a comparison of their architectures," and out comes a single self-contained HTML diagram that opens right in the browser. You can toggle between dark and light themes, and export to PNG or SVG.

So far, this reads like typical marketing copy. So instead of trusting the copy, we installed it, ran it ourselves, and used it to diagram ThakiCloud's own ai-platform structure. That process revealed why this tool is different from a simple "AI diagram generator." This post is both a record of that experiment and a look at how it connects to the design philosophy behind Paxis, ThakiCloud's agent platform.

## What this tool is

Archify is an open source agent skill released under the MIT license by `tt-a1i`. At the time of our experiment, the version was 2.11.0. It is a fork and rewrite of Cocoon AI's architecture-diagram-generator v1.0, and it credits Cocoon AI for the original visual language. It installs into several agent runtimes, including Claude, Codex CLI, and opencode.

Understanding its core structure explains why the tool is unusual. Archify doesn't draw a diagram directly. Instead, it describes the diagram as a **JSON-IR (intermediate representation)**, and a type-specific renderer turns that JSON into HTML. There are five renderers: architecture, workflow, sequence, dataflow, and lifecycle. In other words, "what to draw" lives in structured JSON, and "how to draw it" is owned by validated code.

The five renderers each handle a different kind of diagram. Architecture covers system components and boundaries. Workflow covers procedures like approval chains or CI/CD. Sequence covers request lifecycles or API call ordering. Dataflow covers data movement such as ETL pipelines and event streams. Lifecycle covers state transitions such as deployments or agent execution. Once you know what you're drawing, the matching renderer and schema kick in, and that schema enforces the shape of the input JSON.

This division of labor creates the decisive difference from Mermaid. Mermaid parses syntax and lays things out automatically (via dagre), but it will happily render a diagram where a line cuts through a box or labels overlap. Archify does the opposite: it makes you specify layout coordinates explicitly, and right before rendering it **forcibly checks layout rules**. If a rule is violated, it refuses to produce the diagram and raises an error instead.

The overall flow looks like this.

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
<div class="d3-arch" data-arch-root id="gentarchitecturediagrams-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 516, "height": 934, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 158, "y": 24, "w": 198, "h": 78, "title": ["Natural language request", "(read this repo and draw", "the architecture)"]}, {"id": "B", "x": 176, "y": 180, "w": 163, "h": 62, "title": ["Agent", "Claude Code / Codex"]}, {"id": "C", "x": 151, "y": 320, "w": 212, "h": 78, "title": ["Write JSON-IR", "components · connections ·", "boundaries"]}, {"id": "D", "x": 279, "y": 476, "w": 205, "h": 94, "title": ["Type renderer", "architecture / workflow /", "sequence / dataflow /", "lifecycle"]}, {"id": "E", "x": 160, "y": 648, "w": 195, "h": 84, "title": ["Layout validation", "edge-node crossings ·", "label overlap"]}, {"id": "F", "x": 151, "y": 824, "w": 212, "h": 78, "title": ["Self-contained HTML", "dark/light theme · PNG/SVG", "export"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [257, 102, 257, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [257, 242, 257, 320]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[319, 398], [382, 437], [382, 437], [382, 476]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[382, 570], [382, 609], [382, 609], [322, 648]]}, {"src": "E", "dst": "C", "kind": "event", "label": "validation failed + fix suggestion", "curve": [[193, 648], [133, 609], [133, 437], [195, 398]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "pass", "line": [257, 732, 257, 824], "lx": 257, "ly": 774}]});
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
      const container = document.getElementById('gentarchitecturediagrams-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'gentarchitecturediagrams-1';
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

## Installation and integration

Installation is a single npx command. The global install looks like this.

```bash
# Install globally, then pick an agent
npx skills add tt-a1i/archify -g

# Try it once without a permanent install
npx skills use tt-a1i/archify@archify --agent codex
```

You can also clone the repository directly and verify it with the CLI to pull out examples. Here are the exact commands we ran and their output. Our test environment was Node.js v24.1.0. Archify requires Node 18 or higher, and it has essentially no runtime dependencies (the only dev dependency is ajv, used for schema validation).

```bash
git clone --depth 1 https://github.com/tt-a1i/archify.git
cd archify/archify

# Check install status
node bin/archify.mjs doctor
```

Here is the actual output of the `doctor` command. All five renderers and the schema validators checked out fine.

```text
Archify doctor

[ok] Node.js v24.1.0 (requires >=18)
[ok] Core template
[ok] Standalone schema validators
[ok] architecture renderer, schema, and example
[ok] workflow renderer, schema, and example
[ok] sequence renderer, schema, and example
[ok] dataflow renderer, schema, and example
[ok] lifecycle renderer, schema, and example

Archify is ready.
```

Pulling one of the built-in examples produces a single self-contained HTML file, 508KB, that opens directly in a browser with no external server needed.

```bash
node bin/archify.mjs demo ./out
# Demo ready: ./out/archify-demo.html   (about 508KB, single HTML)
```

## What we found when we actually ran it

Reading the docs alone makes it seem like that's the whole story. So instead of using someone else's example, we wrote out **ThakiCloud's actual ai-platform structure** as a JSON-IR by hand and rendered it. We included nine components: GPU scheduling with Kueue, model serving with vLLM, multi-tenant auth with Keycloak, state and events through PostgreSQL and NATS, and GitOps deployment via ArgoCD.

The JSON-IR wasn't hard for a human to read or write. A component is an object with a type, a label, a position, and a size. A connection carries a source, a destination, and a label. For example, we described the gateway and the GPU-serving piece like this.

```json
{
  "components": [
    { "id": "gateway", "type": "backend", "label": "API Gateway",
      "sublabel": "Go Fiber :8080", "pos": [280, 300], "size": [140, 60] },
    { "id": "vllm", "type": "backend", "label": "vLLM Server",
      "sublabel": "OpenAI API", "pos": [540, 300], "size": [140, 60] }
  ],
  "connections": [
    { "id": "gw-to-vllm", "from": "gateway", "to": "vllm", "label": "route inference" },
    { "id": "vllm-gpu", "from": "vllm", "to": "gpupool", "label": "CUDA", "variant": "emphasis" }
  ]
}
```

Our first render attempt **failed.** And this failure is the most important part of this post. Instead of drawing anything, the renderer pointed out three concrete problems.

```text
Error: Architecture layout validation failed:
- [clean-flow/edge-through-node] connection "kueue-gpu" (kueue -> gpupool)
  crosses component "vllm" (unrelated to this relationship)
- [clean-flow/edge-through-node] connection "kueue-gpu" (kueue -> gpupool)
  crosses component "argocd" (unrelated to this relationship)
- Label "publish" overlaps component "gateway"
  Suggested fix: labelDy +24 (below); or labelAt [350, 374]
```

In other words, the connection from Kueue to the GPU pool cut through the unrelated vLLM and ArgoCD boxes, and the "publish" label overlapped the gateway box. What stands out is that the renderer didn't just flag the problems, it **also suggested how to fix them**, down to the exact coordinates for how far to move the label.

We followed the suggestion, added a routing waypoint (`via`) to the connection, adjusted the label position, and re-rendered. This time it passed. Here are the actual measurements.

| Item | Measurement |
| --- | --- |
| Render time | About 0.073 seconds |
| Output file | 519,709 bytes (about 508KB) single HTML |
| Inline SVG | 1 (the whole diagram is a single SVG) |
| Theme support | 27 uses of `data-theme` · 7 uses of `prefers-color-scheme` |
| External references | 1 (JetBrains Mono web font, falls back to system font) |

To sum up, the render itself takes 73 milliseconds, effectively instant. The output is a self-contained HTML file with no dependency on an image server or CDN, and its only external reference is a single web font for code, so it still opens correctly offline, falling back to the system font. The dark and light themes aren't cosmetic labels either. They're implemented with real CSS variables and `prefers-color-scheme`.

The lesson here is clear. Archify's validator isn't a device for producing "a pretty picture." It's **a gate that blocks a bad diagram, one with tangled lines or overlapping labels, before it ever ships.** A visual defect that a human drawing by hand would have simply missed, the code caught every single time, using the same standard.

## Implications for ThakiCloud's products

This tool's design lines up precisely with a principle ThakiCloud holds to across two products.

**Through the Paxis lens (agents and skills).** Paxis is ThakiCloud's Agent-Native Cloud, and it treats skills as first-class resources. It selects from more than 960 skills using BM25, runs them in an isolated sandbox, and routes every action through policy gates and audit logs. Archify is exactly the shape of tool that a skill harness like this is built to select and run. More importantly, look at its internal design. Archify has **the model produce content (the JSON-IR), while code owns the format and the validation.** This matches a principle ThakiCloud repeats across its batch-output work: separate the freeform generation step from the deterministic validation step. Instead of asking the model to "draw something nice," you have it produce a structured representation, and code enforces whether that representation follows the rules. Our first render getting rejected was exactly this principle in action.

**Through the ai-platform lens (infrastructure and documentation).** Self-contained HTML is especially useful in on-premise and sovereign environments. For a customer who can't upload internal architecture to an external diagramming SaaS, rendering locally and getting a single portable file back is directly usable as a deliverable. And because the JSON-IR is plain text, it's version-controlled in Git and diffable. Just as ArgoCD manages manifests, you can manage architecture diagrams as code too, tracking and reviewing every change. Instead of redrawing onboarding docs or customer-facing deployment diagrams by hand every time, you just edit the JSON when the structure changes and re-render.

The two lenses reinforce each other. A validated skill (Paxis) produces a reproducible artifact (ai-platform documentation), and that artifact in turn becomes a portable asset for on-premise customers.

## Limitations and counterpoints

Archify is, of course, not a silver bullet. It has a few clear weaknesses.

First, **you have to specify layout coordinates.** Unlike Mermaid's automatic layout, you have to give the position and size of every component as coordinates, and that layout has to pass validation. As our own first attempt showed, this step is not entirely free. In practice, though, an agent fills in these coordinates for you and fixes them itself when it gets a validation error, so the burden on a human is reduced.

Second, **the output isn't lightweight.** A single diagram is roughly 508KB of HTML, because it packs fonts and scripts into a self-contained file. That's heavier than a plain SVG or a Mermaid block. If you're dropping several diagrams onto one blog page, that weight can add up.

Third, **it isn't distributed as a library.** The `package.json` is marked `private: true`, meaning you consume it as a repository skill or CLI rather than pulling it in as an npm package. Wiring it into a pipeline as a library takes some extra thought.

Fourth, **it's a static snapshot.** It isn't a live dashboard that updates with real-time data, but a picture of a structure at a specific point in time. If you just want to sketch something quickly, the strictness of the validation rules can feel like friction. That said, this strictness is also the whole reason the tool exists.

## Wrap-up

Having installed Archify ourselves and used it to draw the ThakiCloud stack, here's our conclusion. The core of this tool isn't the convenience of "drawing by describing it in words." It's the discipline of **having a renderer validate every layout an agent produces against the same standard, every time, so a bad diagram never ships.** As we said up front, our first render getting rejected was exactly the moment that earned this tool our trust.

So the next step is clear. If you draw architecture diagrams often, and you want those diagrams to live in your docs or repository like code, Archify is worth running once. If instead you're after a quick sketch or want to stack several diagrams on one page, Mermaid is still the lighter option. The deciding question is whether you want this diagram managed as a reproducible, validated asset. If the answer is yes, then Archify, and the Paxis skill harness that builds the same principle into a product, is the answer.

> Sources
> - Archify repository: [github.com/tt-a1i/archify](https://github.com/tt-a1i/archify) (MIT, v2.11.0)
> - Original tweet: [@alin_zone via @hjguyhan](https://x.com/hjguyhan/status/2079683904030777353)
> - Experiment log: the commands, output, and measurements in this post were captured from a local run on 2026-07-22 (Node v24.1.0).
