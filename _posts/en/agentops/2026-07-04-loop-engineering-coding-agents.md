---
title: "Stop Writing Prompts, Start Writing Loops: Loop Engineering for Coding Agents"
excerpt: "One developer put it this way: \"I don't type prompts into Claude Code anymore. I run a loop that feeds prompts to Fable, and my job is just writing that loop.\" Strip away the hyperbole and the sentence points to a real shift: the unit of work is moving from the prompt to the loop. We look at loop engineering, the practice of repeating observe-judge-act cycles and using the compiler and test suite as the reward signal, through ThakiCloud's own pge-loop and Goal Mode in production."
seo_title: "Loop Engineering: Treating Coding Agents as Loops, Not Prompts - Thaki Cloud"
seo_description: "An analysis of the shift from prompts to loops in how coding agents are operated: the Act-Observe-Learn-Repeat structure, using deterministic gates as reward signals, ThakiCloud's real implementations in pge-loop and Goal Mode, and what this means for the Paxis Agent-Native Cloud."
date: 2026-07-04
last_modified_at: 2026-07-04
tags:
  - ai-coding
  - agentic
  - loop-engineering
  - claude-fable-5
  - agentops
  - verification
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/loop-engineering-coding-agents/"
categories:
  - agentops
---

## Overview

A single sentence recently made the rounds among developers: "I don't type prompts into Claude Code anymore. I run a loop that feeds prompts to Fable, and my job is just writing that loop." It's a provocative line, but once you strip away the marketing gloss, there's a genuinely useful observation buried in it: the unit of work is shifting from a single prompt to a whole loop.

This shift has little to do with models getting smarter. Even the strongest model, faced with a one-shot request, can't push a complex task all the way through in a single pass. But wire that same model into a repeating structure, one where it calls tools, takes the results back as input, and decides its next move, and the picture changes. ThakiCloud runs a Kubernetes-based AI/ML SaaS platform, and we run exactly this kind of loop in our own internal development. So for us, "writing a loop" isn't a trend to comment on; it's a daily engineering concern. This post lays out what that loop actually consists of, and what makes it trustworthy.

![Conceptual illustration of loop engineering for coding agents]({{ '/assets/images/loop-engineering-coding-agents-hero.webp' | relative_url }})

## From Prompts to Loops: What Actually Changes

In the prompt-writing mindset, a person tries to extract the most accurate possible result from a single instruction. Good prompts still matter, but the limits of this approach are clear. When the result is wrong, a human has to read it, figure out what went off track, and refine the prompt again. The human ends up being both the grader and the next instructor, every single iteration.

The loop-writing mindset hands that grading and re-instructing over to the structure itself. Instead of crafting individual prompts, a human defines the goal, what to observe, and when to stop. The model acts within that frame, an external tool judges the result, and that judgment becomes the model's next input. The human's role shifts from watching every turn to designing the loop's boundaries and its exit conditions.

This difference looks small but compounds into something significant. In the prompt-based approach, the human is the bottleneck, because nothing moves forward until a person has read the whole result. In the loop-based approach, the bottleneck isn't the human anymore, it's the quality of the exit condition. When the exit condition is well defined, the loop keeps converging even while the human is away. When it's weak, no model, however capable, can escape spinning in circles. So the real core of loop engineering isn't a knack for polished prompt wording, it's the design skill of making "what counts as success" something a machine can judge on its own.

## Anatomy of a Loop: Observe, Judge, Act, Repeat

A coding loop that actually converges tends to repeat the same four steps. The model proposes a change (Act). That change is applied to the codebase, and an external tool is run to get a result (Observe). The output is parsed into context about what failed and why (Learn). That context is fed back into the model for its next proposal (Repeat). This cycle continues until an exit gate passes or the budget runs out.

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
<div class="d3-arch" data-arch-root id="pengineeringcodingagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 579, "height": 884, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 183, "y": 24, "w": 191, "h": 62, "title": ["Model proposes a change", "Act"]}, {"id": "B", "x": 137, "y": 164, "w": 149, "h": 46, "title": "Apply to codebase"}, {"id": "C", "x": 116, "y": 288, "w": 191, "h": 78, "title": ["Run external tool", "tests, compiler, linter", "Observe"]}, {"id": "D", "x": 120, "y": 444, "w": 184, "h": 94, "title": ["Parse output", "error messages, lines,", "failure reasons", "Learn"]}, {"id": "E", "x": 33, "y": 630, "w": 138, "h": 68, "title": ["Exit gate", "passed?"]}, {"id": "F", "x": 335, "y": 790, "w": 212, "h": 62, "title": ["Feed context back to model", "Repeat"]}, {"id": "G", "x": 24, "y": 790, "w": 120, "h": 62, "title": ["Loop ends", "Converged"]}, {"id": "H", "x": 226, "y": 641, "w": 191, "h": 46, "title": "Halt, hand off to human"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[249, 86], [212, 125], [212, 125], [212, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [212, 210, 212, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [212, 366, 212, 444]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[156, 538], [102, 584], [102, 584], [102, 630]]}, {"src": "E", "dst": "F", "kind": "data", "label": "No", "line": [171, 698, 370, 790], "lx": 265, "ly": 740}, {"src": "F", "dst": "A", "kind": "data", "curve": [[447, 790], [455, 584], [455, 249], [356, 86]]}, {"src": "E", "dst": "G", "kind": "data", "label": "Yes", "line": [94, 698, 84, 790], "lx": 84, "ly": 740}, {"src": "D", "dst": "H", "kind": "event", "label": "Budget exhausted", "curve": [[267, 538], [322, 584], [322, 584], [322, 641]], "off": "50%"}]});
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
      const container = document.getElementById('pengineeringcodingagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'pengineeringcodingagents-1';
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

The third step, Learn, is especially important here. If you summarize or compress the tool's output before feeding it to the model, the loop tends not to converge well. The compiler's exact error message, the specific file and line that failed, the precise nature of a type mismatch, all of that needs to go into the next prompt's context untouched, so the model can reconstruct "why it failed" without relying on memory across sessions. To a human, that raw output looks like verbose logging. To the loop, that verbosity is the signal that drives convergence.

## Deterministic Gates Are the Reward Signal

The place loop engineering most often goes wrong is the exit condition. If you ask the model whether the task is done and let its answer decide when to stop, the model will end the loop early with self-reports like "this looks complete." That's not verification. A trustworthy loop hands the exit decision to a deterministic tool instead of the model: do the tests pass, does the compiler build without errors, is the type checker quiet. This pass/fail signal plays the same role that a reward signal plays in reinforcement learning. There's no need to train a separate reward model; the test runner and compiler you already have can judge "is this code correct" on their own.

ThakiCloud has built this principle directly into our internal loops. The clearest example is pge-loop: it applies a model-proposed diff on the Go backend, runs `make test-short`, and feeds the entire stderr output back into the context for the next proposal. The exit condition isn't the model's own judgment, it's the test's exit code. Goal Mode works the same way: it pursues a goal autonomously until an achievement condition is met, but every step's progress is checked against a fixed verification command, and a budget (iteration count, cost, deadline) sets a hard ceiling. It doesn't spin forever, it either converges or exhausts its budget. Without these two safeguards, a deterministic exit gate and a budget ceiling, a loop becomes a tool you can't trust.

When fan-out is involved, one more rule applies. When you spin up multiple sub-agents in parallel and gather their results, you always close the loop with a verification stage before merging anything. For code output, that means a test gate. For judgment or research output, it means dispatching several skeptical verifiers with different perspectives and filtering by vote. Merge parallel results without verification, and you accumulate output that looks plausible but is wrong. When quality isn't landing, the first thing to suspect usually isn't the model's tier, it's a missing verification stage.

## Implications for ThakiCloud's Products

Loop engineering connects directly to Paxis. Paxis is the Agent-Native Cloud control plane running on top of ai-platform, and it treats Skills, Tools, Policies, and Audit Logs as first-class resources. For a loop that a person designs to become a platform-level resource rather than staying confined to a personal dev environment, the pieces that make up that loop need to be exposed in a manageable form. Paxis selects from roughly 960 skills using BM25, runs them in isolated sandboxes, and passes every action through policy gates and audit logs. In other words, once a person designs "what to observe and when to stop," Paxis supplies the underlying infrastructure that isolates, records, and controls that loop's execution.

From this angle, the deterministic gate maps naturally onto Paxis's policy gate, tool execution maps onto sandboxed isolated execution, and the loop's observation log maps onto the audit log. A loop that verifies itself follows the same principle Paxis emphasizes: fan-out closed by verification.

On the infrastructure side, the ai-platform lens fills out the rest of the picture. Running more loops means more repeated inference calls and test executions. ai-platform absorbs that repeated load cost-effectively through Kubernetes and Kueue-based GPU scheduling, vLLM serving, and multi-tenant isolation. Low serving cost is what makes running loops frequently economically viable, and that economics is what turns an agent into something you can operate continuously rather than occasionally. Low-cost serving (ai-platform) is what creates agent economics (Paxis), and that connection holds here. For customers with on-premises and sovereignty requirements, being able to run this entire loop inside their own infrastructure carries particular weight.

## Limits and Counterarguments

Presenting loop engineering as a cure-all wouldn't be honest. First, for tasks where you can't construct an exit gate, a loop is actually dangerous. Without a command that can automatically judge pass or fail, the loop has no idea where convergence is and just burns through budget. In that case, a single-shot approach is better, and it's better to admit that plainly.

Second, the deeper a loop runs, the more people tend to trust the result and stop reviewing it. The attitude of "the loop will catch it anyway" is the most quietly dangerous failure mode there is. Automation is a tool that supports thinking, not a replacement for it, and the core outputs still need periodic sampling review by a human. If a verifier never catches anything, that doesn't mean everything passed, it more likely means the verifier itself is broken.

Third, cost. A loop, by definition, consumes multiple rounds of inference calls. Without a ceiling, budget disappears fast, and if you keep a strong model attached at all times, cost doesn't scale linearly, it multiplies. In practice, you need routing that uses a cheap model for exploration and repeated execution, and reserves the expensive model only for verification stages where accuracy is critical. The principle of "cheap workers, expensive gates only" applies here just as much as anywhere else.

To sum up: "I don't write prompts, I write loops" is a provocative sentence, but there's substance inside it. That substance doesn't come from a flashier model, it comes from the unglamorous work of designing a system where a machine can judge what counts as success. That's the same lesson ThakiCloud has learned from pge-loop and Goal Mode: a good loop comes from a good exit condition.

## Sources

- Miles Deutscher, post on X (formerly Twitter), commentary on coding agent loops
- ThakiCloud's internal loop-engineering practice: pge-loop, Goal Mode (verification gate + budget ceiling)
- [ReAct: the foundational paper on reasoning-and-acting agent loops (arXiv:2210.03629)](https://arxiv.org/abs/2210.03629)
- [Anthropic, Building Effective Agents: tool use, evaluator-optimizer loop, orchestrator-workers](https://www.anthropic.com/research/building-effective-agents)
