---
title: "Working Without Rate Limits on Fable 5: Model Routing and Token Budget Strategy"
excerpt: "We unpack the Claude Fable 5 workflow tips shared by T3 creator Theo: effort levels, Codex orchestration, model priority in CLAUDE.md, and offloading token-hungry work. We line them up next to the model routing discipline ThakiCloud already uses across Paxis and ai-platform."
tags:
  - claude-code
  - model-routing
  - cost-optimization
  - agent-native
  - paxis
date: 2026-07-04
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/fable-model-routing-rate-limits/"
categories:
  - dev
---

![Abstract image of multiple sized processing streams converging into one conductor node then branching out again]({{ '/assets/images/fable-model-routing-rate-limits-hero.webp' | relative_url }})
*A visualization of routing, where heavy and light work flow to different models.*

## Overview

Grabbing one powerful coding model and throwing every task at it is comfortable. The problem is that the comfort comes back as a token budget and rate limit bill. If you use the most expensive model even for the simplest tasks, your quota is empty by the time you actually need hard reasoning.

In early July 2026, T3 stack creator Theo (@theo) shared how he runs Claude Fable 5 all day without hitting rate limits. The point is simple. Instead of piling everything onto one model, split the model and effort by the nature of the work. In this post we walk through his four strategies with real quotes, and set them alongside the model routing discipline ThakiCloud already applies in operating Paxis and ai-platform.

Why this matters is clear. In an era where agents run autonomously for a long time, how you design the token flow across an entire session, rather than the quality of a single model call, decides real productivity and cost.

## The Problem: Rate Limits Are About Allocation, Not Quality

Users who hit rate limits often do so not because the model is weak but because their allocation is clumsy. If you run the top tier model at top effort even for low difficulty work like reading a single file, a simple grep, or summarizing a log, tokens burn not linearly but exponentially. Thinking tokens in particular pile up invisibly.

The key insight is this. The best model is a finite resource, and deciding where to spend it is exactly what routing means. Theo's four tips are all the same principle practiced from different angles.

## Theo's Four Strategies

### 1. Default to High Effort, Reserve xhigh and max

Theo says he uses Fable only on "high" effort for now. In his own words, xhigh is "token hungry," and max and extra are "a furnace with worse outputs than lower options."

The lesson here is that raising effort does not monotonically raise quality. As thinking tokens grow, the output can become scattered or take excessive detours. For most practical work, high is the balance point between quality and cost. Reserve xhigh and max for stages that genuinely need deep reasoning.

### 2. Orchestrate Codex as a Sub-Executor

The second strategy is to layer models. Theo taught Claude Code to call Codex (GPT-5.5) as a sub-executor for implementation work. By his observation, GPT-5.5 is highly steerable, so Fable can learn how to steer it.

In other words, Fable acts as a conductor handling judgment and branching, while repetitive, high-volume implementation is delegated to a cheaper executor. This way the expensive conductor model spends its tokens on judgment, and the implementation volume comes out of a different budget.

### 3. Declare Model Priority in CLAUDE.md

The third is to harden this routing into a contract rather than improvisation. Theo wrote a large section in his CLAUDE.md on which model to prioritize for which work, and how to allocate when orchestrating subagents and workflows.

This point matters especially. If you bake the routing rules into a document, you do not have to decide again each session, and the whole team shares the same allocation discipline. Turning a repeated prompt into a rule is a basic tenet of prompt hygiene.

### 4. Offload Token-Heavy Work and Retrieve Only Results

Finally, Theo runs token-heavy tasks (computer use, full codebase analysis, and the like) with other models, then has only the result reported back to Fable.

This ties directly to main context hygiene. If you dump a large exploration output straight into the conductor model's context, the cost of re-reading that large context on every subsequent turn grows linearly. If a sub-executor handles the heavy reading and passes up only a summary, the conductor model's context stays clean.

Drawn as a single flow, the four strategies look like this.

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
<div class="d3-arch" data-arch-root id="lemodelroutingratelimits-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 686, "height": 932, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 278, "y": 24, "w": 120, "h": 46, "title": "Task arrives"}, {"id": "B", "x": 251, "y": 148, "w": 174, "h": 52, "title": "Classify task type"}, {"id": "C", "x": 246, "y": 430, "w": 184, "h": 62, "title": ["Fable 5 conductor high", "effort"]}, {"id": "D", "x": 263, "y": 292, "w": 149, "h": 46, "title": "Low-cost executor"}, {"id": "E", "x": 24, "y": 292, "w": 184, "h": 46, "title": "Codex GPT-5.5 executor"}, {"id": "F", "x": 237, "y": 570, "w": 202, "h": 52, "title": "Deep reasoning needed?"}, {"id": "G", "x": 351, "y": 714, "w": 177, "h": 62, "title": ["Escalate to xhigh max", "sparingly"]}, {"id": "H", "x": 176, "y": 722, "w": 120, "h": 46, "title": "Keep high"}, {"id": "I", "x": 260, "y": 854, "w": 156, "h": 46, "title": "Synthesize results"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [338, 70, 338, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "Judgment branching orchestration", "curve": [[415, 200], [552, 246], [552, 384], [424, 430]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Search grep file reading", "line": [338, 200, 338, 292], "lx": 338, "ly": 242}, {"src": "B", "dst": "E", "kind": "data", "label": "Bulk implementation", "curve": [[258, 200], [116, 246], [116, 246], [116, 292]], "off": "50%"}, {"src": "D", "dst": "C", "kind": "data", "label": "Return summary only", "line": [338, 338, 338, 430], "lx": 338, "ly": 380}, {"src": "E", "dst": "C", "kind": "data", "label": "Return artifact", "curve": [[116, 338], [116, 384], [116, 384], [248, 430]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "line": [338, 492, 338, 570]}, {"src": "F", "dst": "G", "kind": "data", "label": "Yes", "curve": [[374, 622], [439, 668], [439, 668], [439, 714]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "label": "No", "curve": [[301, 622], [236, 668], [236, 668], [236, 722]], "off": "50%"}, {"src": "G", "dst": "I", "kind": "data", "curve": [[439, 776], [439, 815], [439, 815], [375, 854]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[236, 768], [236, 815], [236, 815], [300, 854]]}]});
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
      const container = document.getElementById('lemodelroutingratelimits-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lemodelroutingratelimits-1';
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

## Implications for ThakiCloud Products

Theo's tips read as a welcome confirmation because ThakiCloud's agent platform Paxis already stands on the same principle. Paxis is an Agent-Native Cloud control plane that runs on top of ai-platform, treating skills, tools, policies, and audit logs as first-class resources. Within it, model routing is not decoration but the backbone of the cost structure.

Our subagent routing discipline aims at exactly the same target as Theo's fourth strategy. Exploration and file reading go to the cheapest tier, implementation and review to the middle tier, and only architecture and complex multi-step reasoning to the top tier. Subagents do not push raw large outputs upward but return only a summary and file paths. This rule of keeping the conductor model's context clean is the same practice Theo described as "report only the results."

The second strategy of separating conductor and executor also touches the design of Paxis. The Paxis skill harness selects from more than 960 skills with BM25 and runs them in isolated sandboxes, where the orchestration layer handles only light judgment and heavy execution is isolated to separate workers. Using the expensive judgment model only for routing and synthesis, and placing the actual heavy lifting on cheaper workers, is the same picture as Theo putting Fable as conductor and Codex as executor.

The third strategy, hardening routing into documents and policy, is implemented in Paxis as policy gates and audit logs. When you fix which work should flow to which resource as an explicit rule rather than improvised judgment, the allocation discipline does not waver even as an autonomous agent runs for a long time.

At the infrastructure layer, the ai-platform lens works alongside. When serving models on K8s and Kueue based GPUs, flowing low difficulty requests to small models at low batch priority saves GPU time, and that saving flows back into agent economics. Lower serving cost creates the headroom to afford more aggressive routing. In short, low-cost serving (ai-platform) underpins the economics of agent orchestration (Paxis).

## Limitations and Counterarguments

This approach has weaknesses too. First, as routing grows complex, management cost appears. Weaving several models together means each has a different context window, price, and availability, making debugging harder. If the conductor misreads the executor's output, round trips increase and end up spending more tokens.

Second, "high is always best" is Theo's personal observation and varies by task type. For genuinely hard architecture judgments or subtle bug hunts, higher effort earns its cost. The rule is only a default, and the eye to judge exceptions is still required.

Third, orchestration that mixes models from different vendors widens the data flow and security boundary. When you hand codebase analysis to an external executor, you must control exactly what enters that model's context. This is precisely why Paxis passes every action through policy gates and audit logs.

In conclusion, rate limits are not a problem to push through with a more expensive plan but one to solve with allocation. Start cheap, use the expensive model only for heavy judgment, and harden that rule into documents and policy. This is the direction all four of Theo's tips point to, and the discipline ThakiCloud practices every day on Paxis.

## Sources

- Theo (@theo), "I've been getting a TON done with Fable today and I'm not hitting rate limits": [x.com/theo/status/2072481845363822914](https://x.com/theo/status/2072481845363822914)
- "T3 Stack creator Theo shares Fable AI workflow", digg.com: [digg.com/tech/wmowks0x](https://digg.com/tech/wmowks0x)
- "Fable Is Back. Here's How to Actually Code With It", Wavect: [wavect.io/blog/coding-with-claude-fable-5](https://wavect.io/blog/coding-with-claude-fable-5/)
