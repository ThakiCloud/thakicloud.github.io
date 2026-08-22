---
title: "Scoring Agents That Turn Design Rules Into Verification Scripts by Execution: The Rule2DRC Benchmark"
seo_title: "Rule2DRC: Execution-Based Benchmark for Semiconductor DRC LLM Agents | ThakiCloud"
seo_description: "Rule2DRC scores LLM agents that translate natural-language design rules into executable DRC scripts by running them in KLayout, not by code similarity. It spans 1,000 rules and 13,921 layouts and measures functional correctness without giving the agent the answer layouts. Seoul National University and Samsung AI Center even shipped an on-prem GUI app."
excerpt: "What matters is not plausible-looking code but code that actually passes. We look at Rule2DRC as a concrete case of domain-specific agents replacing expert manual EDA verification inside a regulated, secure environment."
date: 2026-07-23
tags:
  - DRC
  - Design Verification
  - EDA
  - Semiconductor
  - LLM Agent
  - Execution-Based Scoring
  - Benchmark
  - Domain-Specific Agent
  - On-Premises
  - KLayout
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/rule2drc-drc-llm-agent-benchmark/"
published: false
---

If you are an engineer who wants to automate the verification of the thousands of design rules a chip must satisfy before mass production, this post is for you. Here is the conclusion first. Rule2DRC (arXiv:2605.15669, from Prof. Hyun Oh Song's group at Seoul National University and Samsung AI Center, ICML 2026) is a large-scale benchmark that scores LLM agents translating natural-language design rules into executable DRC verification scripts by whether the scripts actually run and pass in a verification engine, not by how closely the code resembles a reference. On top of that, the team built a layout-native agent GUI app that can be deployed inside Samsung's secure intranet. It is worth watching as a signal that domain-specific agents are entering industrial settings where regulation and security are strict.

![An abstract image depicting natural-language design rules flowing into executable verification code](/assets/images/rule2drc-drc-llm-agent-benchmark-hero.webp)
*A visualization of layout grid patterns flowing into structured verification logic.*

## Why Read This

This post is for engineers deploying domain-specific LLM agents into regulated, secure environments, and for platform owners looking to automate specialized work such as EDA and semiconductor verification with agents. The question you face is this: when you hand verification work that used to require an expert to an agent, how can you trust that it truly does the job correctly? Rule2DRC's answer is clear. You run the scripts the agent produces in an actual verification engine and score them by functional correctness. Plausible-looking code and code that actually works are different things, and the industry needs the latter.

## Overview

Before a semiconductor chip goes into mass production, it must be verified against thousands of geometry-based design rules. This verification is called DRC, or Design Rule Check. The catch is that the rules themselves are written as natural-language documents. A sentence like "the minimum spacing between metal wires must be at least X" has to be turned into a script in a dedicated verification language such as KLayout or SVRF before an engine can actually inspect the layout.

That translation is far from trivial. Every time a process node changes or a foundry changes, experts have hand-translated thousands of rules into scripts. Because the work is repetitive yet requires deep expertise, attempts to automate it with LLM agents followed naturally. The idea is to build an agent that reads a rule document, generates a verification script, and even debugs it when it is wrong.

The real bottleneck turned out to be evaluating the agent properly, more than building it. Prior benchmarks carried two limitations. One was that the evaluation sets were small. The other was that they scored generated scripts by similarity to reference code rather than by actually running them. On top of that, prior methods that did use execution feedback often required the answer test layouts as the agent's input in order to score. In practice, no such answer layouts are handed to you.

## What the Benchmark Is

Rule2DRC takes these two limitations head-on. It is a large-scale benchmark made of 1,000 rule-to-script tasks and 13,921 chip layouts for scoring those scripts. The scoring method is the crux. It runs the AI-generated scripts in the KLayout verification engine and measures functional correctness by how well they inspect the layouts. It does not look at whether the code resembles a reference.

What stands out is that the answer layouts are not given to the agent as input. The scoring side holds a vast pool of evaluation layouts, but the agent has to write scripts from the rule document alone. This reproduces the real situation exactly. It parts ways here with earlier approaches that showed the agent the answer key beforehand and then scored it.

The diagram below shows the Rule2DRC evaluation flow.

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
<div class="d3-arch" data-arch-root id="2drcdrcllmagentbenchmark-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 465, "height": 896, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 28, "y": 24, "w": 191, "h": 78, "title": ["Natural-language design", "rule", "(process rule document)"]}, {"id": "B", "x": 42, "y": 180, "w": 163, "h": 78, "title": ["LLM agent", "script generation &", "debugging"]}, {"id": "C", "x": 35, "y": 336, "w": 177, "h": 62, "title": ["DRC script candidates", "(multiple)"]}, {"id": "D", "x": 24, "y": 476, "w": 198, "h": 78, "title": ["SplitTester", "discriminative test-case", "generation"]}, {"id": "E", "x": 118, "y": 646, "w": 184, "h": 78, "title": ["KLayout execution", "functional-correctness", "scoring"]}, {"id": "F", "x": 107, "y": 802, "w": 205, "h": 62, "title": ["Best-of-N selection", "choose the optimal script"]}, {"id": "G", "x": 277, "y": 484, "w": 156, "h": 62, "title": ["Evaluation layouts", "13,921"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [123, 102, 123, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [123, 258, 123, 336]}, {"src": "C", "dst": "D", "kind": "data", "line": [123, 398, 123, 476]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[163, 554], [210, 600], [210, 600], [210, 646]]}, {"src": "E", "dst": "F", "kind": "data", "line": [210, 724, 210, 802]}, {"src": "G", "dst": "E", "kind": "event", "label": "scoring only", "curve": [[355, 546], [355, 600], [355, 600], [276, 646]], "off": "50%"}, {"src": "E", "dst": "D", "kind": "event", "label": "execution feedback", "curve": [[152, 646], [84, 600], [84, 600], [105, 554]], "off": "50%"}]});
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
      const container = document.getElementById('2drcdrcllmagentbenchmark-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '2drcdrcllmagentbenchmark-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

This is where the second contribution, SplitTester, comes in. When the agent produces several candidate scripts, choosing the best one is harder than it sounds, because the candidates often behave similarly and are indistinguishable on the surface. SplitTester is a tester agent that uses execution feedback to generate discriminative test cases on its own. It creates tests that make previously indistinguishable candidates produce different results, so it becomes clear which candidate is actually correct. Separating candidates this way noticeably improves Best-of-N selection, the task of picking one script out of many.

In the paper's quantitative results, the gap between frontier models and open-source models was pronounced, and attaching SplitTester improved candidate-selection performance. For exact per-model pass rates, we recommend checking the paper's tables directly. The benchmark was accepted at ICML 2026, and it was reported to have received an Outstanding Research Award and a Best Poster Award at Samsung AI Center's NPRC workshop.

## Why Execution-Based Scoring Matters

The shift from code-similarity scoring to execution-based scoring is the real center of gravity of this work. Similarity scoring measures "how much does it resemble the answer," while execution scoring measures "does it actually pass." The two questions are entirely different. Code that looks identical to the answer can fail when run, and code that looks completely different can work perfectly. As long as the essence of verification lies in "does it actually catch the rule violations," scoring should be done by execution too.

This direction is not a story confined to semiconductor verification. The evaluation paradigm across coding agents as a whole is heading to the same place. It is the trend of scoring by deterministically checkable outcomes: code that passes tests, code whose endpoints return the expected responses, code that leaves the correct rows in a database. Rather than trusting the model's self-report that "I think it worked," you let the execution result render the verdict.

And what makes this work especially meaningful is that it did not stop there. Integrated with an in-house LLM in Samsung's secure environment, a GUI app that handles layouts and verification code on a single screen was built. It went beyond a benchmark and a paper into a tool that can be deployed in the field. Here you can read the signal that domain-specific agents are genuinely entering industries where regulation and security are strict.

## Implications for ThakiCloud Products

The picture Rule2DRC paints overlaps precisely with where ThakiCloud aims with its two products. Because the topic is operating domain-specific agents in a security-isolated environment, the Paxis lens is central and the ai-platform lens supports it.

From the agent perspective, Paxis takes this demand directly. Paxis is ThakiCloud's Agent-Native Cloud control plane running on top of the ai-platform, treating Skills, Tools, Policies, and Audit Logs as first-class resources. The Samsung case of a layout-native GUI app plus an in-house LLM integration is exactly Paxis's Agent Builder and on-premises deployment model. In particular, Rule2DRC's execution-based scoring shares the same philosophy as Paxis's verification design. When Paxis evaluates a skill, it already leans toward scoring by deterministic execution results, that is, assertions, DB rows, and endpoint outputs, rather than by resemblance to a reference. The way SplitTester separates candidates with execution feedback to lift Best-of-N is worth borrowing as the logic by which the Evaluator in Paxis's multi-agent orchestrator discriminates candidate outputs by their execution results.

From the infrastructure perspective, the ai-platform holds up this picture. Serving an in-house LLM as the backend of a verification agent requires an inference stack that runs stably on-premises. The ai-platform provides vLLM serving and scale-to-zero on top of K8s and Kueue-based GPU scheduling, and operates models in multi-tenant isolated environments. A token-metered cloud API cannot meet air-gapped requirements like Samsung's intranet. On-prem inference that competes on low serving cost is what makes the economics of such domain agents work. Low-cost serving opens the possibility of running agents continuously, and on top of that Paxis's policy gates and audit logs take responsibility for regulatory compliance.

In short, this case is evidence that industry needs not general-purpose chatbots but domain-specific agents running in security-isolated environments. Paxis's Sandbox Runtime, autonomy levels, Policy Engine, and on-premises audit logs point exactly at this demand.

## Limitations and Counterarguments

To avoid overrating this work, let me note the other side. First, Rule2DRC's core contribution is the benchmark and the scoring methodology, not a claim that verification automation is now complete. Even frontier models did not translate every rule into a script perfectly, and the existence of a gap also means we are not yet at the stage of replacing human experts.

Second, execution-based scoring is only possible when the verification engine and evaluation layouts are in place. Rule2DRC prepared 13,921 layouts, but building an execution-ready evaluation set of the same scale for a new process or a different domain is itself a large cost. That execution scoring is more correct than similarity scoring, and that you can cheaply set up that execution environment everywhere, are two separate things.

Third, that an on-prem GUI app appeared and how much it actually reduced experts' manual work in practice are different questions. There is still distance between a paper-stage demonstration and field-operation reliability, and what bridges that distance is not a benchmark but long-accumulated operational data.

## Wrapping Up

If we compress the message of Rule2DRC into one sentence, it is this: domain-specific agents should be scored by code that actually passes, not by plausible-looking code, and only when you can score them that way can you deploy them in regulated, secure settings. A single thread runs from a benchmark that evaluates the specialized work of turning natural-language rules into execution scripts by execution results even without answer layouts, to SplitTester that discriminates candidates on top of it, to an on-prem GUI app.

If you are designing a domain-specific agent, the next action is clear. First set up a gate that scores outputs by execution results rather than by similarity, and when there are multiple candidates, attach discriminative tests that separate them. ThakiCloud already folds these two into practice through Paxis's Evaluator and the ai-platform's on-prem serving. If you want to automate verification, let execution render the verdict.

## Sources

- Paper: [Rule2DRC (arXiv:2605.15669)](https://arxiv.org/abs/2605.15669)
- SNU Engineering News: [SNU Engineering News](https://eng.snu.ac.kr/en/communication/promotion/news?md=v&bbsidx=8189&sc=y)
