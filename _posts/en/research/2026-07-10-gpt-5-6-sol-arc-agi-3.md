---
title: "Orientation Before Execution: How GPT-5.6 Sol Broke ARC-AGI-3 for the First Time"
seo_title: "GPT-5.6 Sol ARC-AGI-3 7.8% Breakthrough Analysis - Thaki Cloud"
seo_description: "GPT-5.6 Sol set the first SOTA on ARC-AGI-3 at 7.78% and became the first model to clear a game. We break down why orientation-centered reasoning, not better execution, matters for agent infrastructure and serving economics from ThakiCloud's perspective."
excerpt: "ARC-AGI-3 measures whether an agent can figure out a situation and adapt on its own inside an interactive game with no instructions. GPT-5.6 Sol became the first model to break this benchmark, reaching 7.78%. The driving force was not better execution but orientation, the ability to find its bearings in an unfamiliar environment first."
date: 2026-07-10
tags:
  - arc-agi
  - reasoning
  - agents
  - gpt-5-6
  - benchmark
  - agentic-ai
  - orientation
categories:
  - research
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/gpt-5-6-sol-arc-agi-3/"
---

Teams that have actually run agents in production do not get excited over a single benchmark score. We have seen too many cases of a model that clears 90% on static problem sets still losing its footing in front of an unfamiliar tool, a UI it has never seen, or an environment with no instructions. So when ARC Prize announced that it had verified GPT-5.6 Sol's ARC-AGI-3 results, what caught our attention was not the number itself but how that number came about.

Here is the core fact. GPT-5.6 Sol scored 7.78% on the ARC-AGI-3 semi-private set, setting a new SOTA, and became the first verified frontier model to actually finish an ARC-AGI-3 game from start to end. What stands out is ARC Prize's explanation for why. Sol did not succeed because it executed each action more precisely. It succeeded because it was better at orientation, the ability to figure out its own direction in a situation it had never seen before.

![Abstract image depicting an agent orienting itself inside an unfamiliar grid world and converging on a single path]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-hero.png' | relative_url }})
*It depicts the moment of orientation, where scattered chaos in an unfamiliar, instructionless environment converges into a single direction.*

## Overview

This post is not about where GPT-5.6 Sol ranks overall among models. It is about why this model made meaningful progress specifically on ARC-AGI-3 rather than on some other benchmark, and what that progress means for those of us who build and serve agents in practice.

The ARC-AGI series splits into two distinct kinds of problems. ARC-AGI-1 and ARC-AGI-2 are static grid puzzles that measure passive fluid intelligence, the ability to infer a rule and produce the correct output grid. ARC-AGI-3 is an entirely different kind of problem. In an interactive, turn-based game environment with no instructions given, the agent has to act on its own to discover the rules and reach the goal. In other words, the axis has shifted from getting the right answer to adapting to an unfamiliar world.

This distinction matters from ThakiCloud's point of view. Most of the agent workloads we deal with fall closer to the second category. How quickly an agent can grasp a situation and move safely in front of an MCP connector it has just connected to, an internal API it has never seen, or a data source whose schema just changed. That is what actually determines whether a production agent succeeds or fails. ARC-AGI-3 measures exactly that capability under lab conditions.

## What ARC-AGI-3 Is and Why It Is So Hard

ARC-AGI-3 was designed to "resist the kind of progress that saturated the previous generation." ARC-AGI-1 is now effectively saturated. Sol and Terra are nearly tied at around 96.5%, and even the low-cost model Luna reaches 88%. Static reasoning is close to a solved problem for frontier models at this point.

Moving up to ARC-AGI-2, the gap widens. Sol scores 92% (about $1.44 per task), Terra scores 83.9% ($1.09), and Luna scores 59.5% ($0.67). Even at this level, we are still in the territory of how well a model solves a problem it has been given.

The problem is ARC-AGI-3. When this benchmark launched in March 2026, even the best model at the time could barely clear 0.37%. That is because in an interactive game, the agent has to work out on its own, with no prior information at all, what action triggers what effect, what the goal is, and what failure even means. This is easy for a human, but for a model it is completely unknown territory, outside its training distribution.

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
<div class="d3-arch" data-arch-root id="20260710gpt56solarcagi3-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 753, "height": 694, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 302, "y": 24, "w": 128, "h": 46, "title": "ARC-AGI Series"}, {"id": "B", "x": 534, "y": 156, "w": 163, "h": 62, "title": ["ARC-AGI-1", "Static Grid Puzzles"]}, {"id": "C", "x": 270, "y": 156, "w": 191, "h": 62, "title": ["ARC-AGI-2", "Harder Static Reasoning"]}, {"id": "D", "x": 31, "y": 148, "w": 184, "h": 78, "title": ["ARC-AGI-3", "Interactive Turn-Based", "Games"]}, {"id": "B1", "x": 509, "y": 304, "w": 212, "h": 62, "title": ["Passive Fluid Intelligence", "Sol 96.5% Saturated"]}, {"id": "C1", "x": 277, "y": 304, "w": 177, "h": 62, "title": ["Deeper Rule Inference", "Sol 92% / $1.44"]}, {"id": "D1", "x": 24, "y": 304, "w": 198, "h": 62, "title": ["No Instructions", "Discover Rules by Acting"]}, {"id": "E", "x": 31, "y": 444, "w": 184, "h": 78, "title": ["Orientation Required", "Adapting to Unfamiliar", "Environments"]}, {"id": "F", "x": 38, "y": 600, "w": 170, "h": 62, "title": ["Best at Launch 0.37%", "Effectively Unsolved"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[430, 63], [615, 109], [615, 109], [615, 156]]}, {"src": "A", "dst": "C", "kind": "data", "line": [366, 70, 366, 156]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[302, 63], [123, 109], [123, 109], [123, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [615, 218, 615, 304]}, {"src": "C", "dst": "C1", "kind": "data", "line": [366, 218, 366, 304]}, {"src": "D", "dst": "D1", "kind": "data", "line": [123, 226, 123, 304]}, {"src": "D1", "dst": "E", "kind": "data", "line": [123, 366, 123, 444]}, {"src": "E", "dst": "F", "kind": "data", "line": [123, 522, 123, 600]}]});
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
      const container = document.getElementById('20260710gpt56solarcagi3-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260710gpt56solarcagi3-1';
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

Looking at this structure, it becomes clear that ARC-AGI-3 measures a fundamentally different axis from other benchmarks. If the first two generations were about raising the resolution of intelligence, the third generation demands the adaptability of intelligence. And adaptability is not built from execution accuracy alone.

## GPT-5.6 Sol's Results: The Numbers

At its max reasoning effort setting, GPT-5.6 Sol averaged 13.33% on the ARC-AGI-3 public set and 7.78% on the semi-private set. The 7.8% figure quoted in headlines is this semi-private number. Given that the previous SOTA was Claude Opus 4.8's 1.5%, this is more than a fivefold jump.

The more symbolic event is that Sol became the first verified frontier model to actually clear one of the ARC-AGI-3 public games, ft09. Sol's success rate on this game was 87%. No model had ever fully finished a single game since the benchmark went live, so this is not just a new high score. It is the first case of crossing a qualitative threshold.

That said, we need to be honest about the cost. Running the full ARC-AGI-3 evaluation at max reasoning effort costs close to $20,000 in total. This capability is still one that only barely opens up at the most expensive setting. The 7.78% figure is a signal of a breakthrough, not a declaration that the problem is solved. Placed next to the 92% on ARC-AGI-2, it shows that interactive adaptation is still a generation behind static reasoning.

## The Breakthrough Came From Orientation, Not Execution

The most important part is ARC Prize's interpretation. The reason Sol performed well on ARC-AGI-3, in their reading, was not that it executed each action more precisely, but that it first oriented itself correctly in an unfamiliar environment.

Orientation and execution are different capabilities. Execution is performing an action accurately once you know what needs to be done in a given situation. Orientation is figuring out the structure of a situation through observation and trial when it is not even clear what needs to be done. Most benchmarks measure execution, because the problem and the goal are given clearly. ARC-AGI-3 hides even the goal and measures orientation instead.

This distinction connects directly to how we design agents in practice. In production, the moment an agent fails is usually the orientation stage, not the execution stage. It rarely falls apart because it called the wrong function. It falls apart because it judged wrong, from the start, which function to call and why in this situation. Sol's result suggests that orientation is an axis that can scale on its own, and that a benchmark measuring it may correlate more closely with real agent quality.

## Implications for ThakiCloud's Products

This topic touches both of ThakiCloud's products.

**The Paxis lens (agent orientation).** Paxis is ThakiCloud's Agent-Native Cloud, where Skills, Tools, Policies, and Audit Logs are treated as first-class resources. Here, orientation is not an abstract concept but a design problem. Every time an agent connects to a new MCP connector for the first time or selects among roughly 960 skills through BM25, it is solving, once again, the problem of finding its bearings in an unfamiliar space of capabilities. The lesson from ARC-AGI-3 is that this orientation step should not be left to the model alone. The harness needs to help. Paxis structuring the action space through skill descriptions, policy gates, and audit logs works as an orientation aid, letting the agent find its direction inside a verified skeleton instead of wandering through an unknown environment. Without relying on expensive max reasoning like Sol, a harness that reduces the orientation burden can make stable adaptation possible even with cheaper models.

**The ai-platform lens (inference economics).** At the same time, that $20,000 evaluation cost is also an infrastructure problem. Orientation-heavy reasoning generally requires long thought trajectories and a lot of trial and error, which translates directly into token consumption. ThakiCloud's ai-platform focuses on running these expensive inference workloads cost-efficiently in a multi-tenant environment through K8s, Kueue GPU scheduling, and vLLM serving. To put an agent that adapts to unfamiliar environments into production, you need a serving layer that can push the cost of max reasoning effort down to an affordable level. This confirms once again that cheap serving is what makes agent economics work.

In short, an adaptive agent becomes something you can actually operate, rather than an expensive frontier demo, only when Paxis distributes the orientation burden into the harness and ai-platform pushes down the inference cost.

## Limitations and Counterarguments

To avoid overreading this result, here are a few counterarguments worth keeping in view.

First, 7.78% is still a very low absolute number. A human would clear most ARC-AGI-3 games without much trouble, while the best model barely finished a single one. Calling this a breakthrough is fair, but it is far from calling it solved. How robustly this orientation capability generalizes has not been proven yet.

Second, the cost problem offsets a good part of the capability claim. A capability that only opens up at max reasoning effort is a separate question from whether it can actually be deployed. Whether the same orientation ability reproduces at a tenth of the cost is what actual value hinges on, and the current data does not tell us.

Third, this is a result verified on a single benchmark. Fable 5 has not yet been benchmarked on ARC-AGI-3, and whether this orientation ability transfers to real agent tasks outside the ARC-AGI-3 game set still needs separate verification. There is not yet enough evidence to rule out the possibility that the model has simply overfit to the benchmark.

Even so, the direction is clear. In an era where execution accuracy is saturating, the next bottleneck is orientation, and the approach of measuring it and assisting it with a harness will become the next competitive edge for practical agents. Sol's 7.78% is the first coordinate of that turning point.

## Sources

- [GPT-5.6 Sol ARC-AGI Results (ARC Prize)](https://arcprize.org/results/openai-gpt-5-6-sol)
- [ARC Prize Announcement (X/Twitter)](https://x.com/arcprize/status/2075270869992264003)
- [ARC Prize Leaderboard](https://arcprize.org/leaderboard)
- [GPT 5.6 Sol Tops ARC-AGI-3 With 7.8% (OfficeChai)](https://officechai.com/ai/gpt-5-6-sol-tops-arc-agi-3-with-7-8-becomes-first-model-to-make-meaningful-progress-on-benchmark/)
