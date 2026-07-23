---
title: "Stop Typing Prompts, Start Designing Loops: Reading Claude Code's Official Loop Engineering Guide"
excerpt: "On July 7, 2026, Anthropic published its first official loop engineering document, 'Getting started with loops.' It marks the shift from a human prompting every step to designing a system that prompts the agent for you. This post covers manual loops, /loop interval loops, /schedule routines, and /goal completion conditions, then connects the patterns to how ThakiCloud has wired them into real unattended pipelines and to the Paxis agent control plane."
seo_title: "Claude Code Loop Engineering - Reading the /goal /loop /schedule Guide (2026) - Thaki Cloud"
seo_description: "An introduction to Anthropic's official 'Getting started with loops' (2026-07-07). We cover manual loops, /loop interval loops, /schedule routines, /goal completion conditions and turn caps, designing verifiable success criteria, and skill-based verification, plus how ThakiCloud wired these patterns into real unattended pipelines with pge-loop, Goal Mode, and launchd cron, and the Paxis Agent-Native Cloud implications."
date: 2026-07-08
last_modified_at: 2026-07-08
tags:
  - claude-code
  - loop-engineering
  - ai-agent
  - agentic-automation
  - developer-tools
  - orchestration
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/claude-code-loop-engineering/"
reading_time: true
categories:
  - dev
---

## Who Should Read This

This post is for developers and platform engineers who want to run a coding agent not as a one-shot tool but as a long-running automation system. It addresses practical questions like "what do I have to define so the agent repeats on its own instead of me typing every prompt?" and "how do I prevent infinite loops and runaway cost?" We read Anthropic's official loops document and overlay it with our own operational experience wiring these patterns into real unattended pipelines.

![A ring of interlocking segments forming an endless feedback loop with glowing arrows and a verification gate at its center]({{ '/assets/images/claude-code-loop-engineering-hero.png' | relative_url }})

## Overview

Until now, using a coding agent has been a conversation. A person types a prompt, the agent responds once, and it stops. It waits for the next instruction. That works beautifully for short tasks, but it does not fit the flow of repetitive, well-bounded work like reflecting PR reviews, fixing CI, triaging issues, or upgrading dependencies, because a human has to stay attached, prompting every turn.

On July 7, 2026, Anthropic published an official document, "Getting started with loops," and named this shift: loop engineering. The document's core sentence is this: stop typing every prompt directly, and start designing the system that prompts the agent for you. This post reads the kinds of loops and stop conditions that document lays out, and follows through to how we actually wired these patterns into real unattended pipelines.

## What Loop Engineering Is

Loop engineering is the next step after prompt engineering. If prompt engineering is about refining "an instruction that gets one good response," loop engineering is about designing the repeating structure itself: observe, judge, act, observe again. What determines the quality of a good loop is not only the model's capability but the quality of the feedback the loop receives on each pass.

The most reliable feedback comes from deterministic verification that returns pass or fail objectively, like tests, type checkers, and linters. The model's self-report of "this looks done" cannot be the termination condition of a loop. When a loop should stop is decided by a tool's verdict, not the model's assertion.

## The Three Loop Types and /goal

The official document divides loops into three types. Which one to use splits on "is a human watching in real time?", "is there a defined endpoint?", and "does it repeat on a fixed schedule?"

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
<div class="d3-arch" data-arch-root id="laudecodeloopengineering-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 728, "height": 650, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q1", "x": 381, "y": 24, "w": 181, "h": 68, "title": ["Is a human watching", "in real time?"]}, {"id": "M", "x": 484, "y": 184, "w": 212, "h": 78, "title": ["Manual loop", "started by a prompt", "stops when judged complete"]}, {"id": "Q2", "x": 276, "y": 189, "w": 153, "h": 68, "title": ["Until a defined", "goal is met?"]}, {"id": "G", "x": 385, "y": 354, "w": 184, "h": 94, "title": ["/goal", "completion condition +", "budget cap", "ends when criteria met"]}, {"id": "Q3", "x": 128, "y": 367, "w": 202, "h": 68, "title": ["Repeats on an interval", "or schedule?"]}, {"id": "L", "x": 256, "y": 540, "w": 177, "h": 78, "title": ["/loop interval loop", "re-runs a prompt on a", "period"]}, {"id": "S", "x": 24, "y": 540, "w": 177, "h": 78, "title": ["/schedule routine", "runs without a human", "until you turn it off"]}], "edges": [{"src": "Q1", "dst": "M", "kind": "data", "label": "Yes, short one-off", "curve": [[522, 92], [590, 138], [590, 138], [590, 184]], "off": "50%"}, {"src": "Q1", "dst": "Q2", "kind": "data", "label": "No", "curve": [[421, 92], [353, 138], [353, 138], [353, 189]], "off": "50%"}, {"src": "Q2", "dst": "G", "kind": "data", "label": "Yes", "curve": [[402, 257], [477, 308], [477, 308], [477, 354]], "off": "50%"}, {"src": "Q2", "dst": "Q3", "kind": "data", "label": "No", "curve": [[303, 257], [229, 308], [229, 308], [229, 367]], "off": "50%"}, {"src": "Q3", "dst": "L", "kind": "data", "label": "Interval", "curve": [[271, 435], [345, 494], [345, 494], [345, 540]], "off": "50%"}, {"src": "Q3", "dst": "S", "kind": "data", "label": "Event · schedule", "curve": [[186, 435], [113, 494], [113, 494], [113, 540]], "off": "50%"}]});
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
      const container = document.getElementById('laudecodeloopengineering-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodeloopengineering-1';
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

First is the manual loop. It starts with a user prompt and stops when Claude judges the task complete or judges that it needs more context. It fits relatively short tasks that are not part of a regular process or schedule.

Second is the `/loop` interval loop. It re-runs a single prompt on a fixed interval. The document's example is: `/loop 5m check my PR, address review comments, and fix failing CI`, checking the PR every five minutes, reflecting review comments, and fixing failed CI.

Third is the `/schedule` routine. It is triggered by an event or a schedule, with no human watching in real time. Each task ends when its goal is met, but the routine itself keeps running until you turn it off. It fits well-defined streams of repeated work like bug reports, issue triage, migrations, and dependency upgrades.

Running through all three is `/goal`. `/goal` sets a completion condition and keeps Claude working toward it without a human prompting each step. It is a structure that holds a directional goal and converges via tool feedback.

## How to Design Good Success Criteria

A loop's success hinges on how well the success criteria are defined. The official document emphasizes three properties of a good success criterion.

First is verifiability. Claude must be able to confirm completion programmatically or through explicit observation. "All unit tests pass" is verifiable. By contrast, "improve the code" is not.

Second is a scope boundary. You must state what is in bounds and what is out. "Refactor the payment service without touching the database layer" is a scoped, safe goal.

Third is a success metric. Numbers help. "Reduce the API response time of the `/search` endpoint below 200ms" gives a concrete target. Deterministically judged criteria like tests passing, a Lighthouse score, or an empty queue work best.

And there is one more safety valve: the turn cap. Without a bound like "stop after five tries," a vague goal can burn a long time and many tokens as the agent decides whether it is "close enough." Including a turn cap in the completion condition is the simplest defense.

## Verification Gates and Skills

The principle the document returns to is that the quality of feedback determines the quality of the loop. This is where skills enter. A skill packages the verification procedure the loop runs on each pass into a reusable form, giving the agent a way to verify its own output. If a loop filters out nothing and only ever passes, that is a sign the verifier is broken.

This is where it matters most in practice. A fan-out loop that spreads many subtasks in parallel accumulates hallucinations if it merges results without a verification stage. For code work, the exit code of a test; for research or content work, an adversarial refutation vote must audit the results before moving to the next step. The common misreading when quality falls short is to bump the model to a more expensive tier, but the more common cause is the absence of a verification stage.

## Implications for ThakiCloud

This document is special to us because we already operate the patterns it describes in real unattended pipelines.

Three layers of loops run in our repository. First, pge-loop, which uses the compiler and the test runner as reward signals to repeat code transformations until tests pass. This implements the document's "verifiable completion condition" from `/goal` as the exit code of `make test-short`. Second, Goal Mode, which autonomously pursues a goal to a done state. With a state file, a budget cap, and a `check_cmd` gate, it follows the document's turn-cap and success-metric principles directly. Third, launchd cron runners that repeat at fixed times with no human, corresponding to the document's `/schedule` routines. Work that needs no human judgment each tick, like monitoring and content generation, runs on cron rather than keeping Claude resident, holding cost at zero.

This operating discipline is exactly the Paxis design philosophy. Paxis is ThakiCloud's Agent-Native Cloud control plane, treating skills, tools, policies, and audit logs as first-class resources. From a loop-engineering standpoint, Paxis provides four things: declaring schedule routines with natural-language Cron, assembling fan-out and verification stages with DAG multi-agents, selecting from over 960 skills via BM25 to run in an isolated sandbox, and passing every loop action through a policy gate and audit log. The document's principle that "fan-out without verification is dangerous" becomes an infrastructure feature in Paxis: the policy gate.

Beneath it, the ai-platform lens also operates. A long-running loop is ultimately an inference-cost problem. Holding a low serving cost on top of Kubernetes and Kueue-based GPU scheduling is the economic foundation that makes schedule routines sustainable. Low-cost serving creates the economics of agent loops, and on top of it Paxis owns the safety and assembly of the loops.

## Limitations and Counterarguments

Taking loop engineering as a cure-all is itself dangerous. The first limitation is unverifiable work. Loop a task whose success cannot be judged deterministically, and the agent burns budget with no termination condition. If you cannot define the gate first, a one-shot run, not a loop, is the right call.

The second limitation is cost. A long-session loop that re-reads a huge context on each tick sees cache-read cost grow linearly. Accumulating 24-hour monitoring into one session is especially expensive. The rule is to call the agent only when a human or event is present and to push simple polling to cron.

The third limitation is cognitive surrender. The deeper a loop goes, the more one tends to trust the results and stop reviewing. Automation is a tool that assists thinking, not one that replaces it. Core outputs must be sampled and reviewed by a human periodically, and if the verifier filters out nothing, that must be read as a failure signal.

These three limitations all reduce to one principle: define the exit gate before you start the loop. With a gate, a loop compounds quality; without one, a loop compounds hallucination.

## Sources

- Anthropic, "Getting started with loops" (2026-07-07): [claude.com/blog/getting-started-with-loops](https://claude.com/blog/getting-started-with-loops)
- Claude Code Docs, "Keep Claude working toward a goal": [code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal)
