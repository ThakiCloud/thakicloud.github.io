---
title: "Effort Levels for Code Review: Claude Code /code-review from low to ultra"
excerpt: "In v2.1.101 Claude Code renamed /simplify to /code-review and attached effort levels to the review. low and medium return a few high-confidence findings, high and max add broader coverage with uncertain findings, and ultra runs a deep review where multiple agents verify each finding in the cloud. We look at why this staging is the right way to split cost and quality in code review, and how the idea maps onto the Paxis skill harness."
tags:
  - claude-code
  - code-review
  - effort-levels
  - ultrareview
  - ai-coding
  - agent
  - developer-tools
  - cost-quality
  - paxis
  - dev
date: 2026-07-17
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/claude-code-review-effort-levels/"
categories:
  - dev
---

## Overview

There is a question people skip when choosing a code review tool: how much review does this change actually need? Running the same review intensity on a one-line typo fix and on a rewrite of payment logic is either wasteful or insufficient. Most automated review tools do not leave that choice to the user and operate at a single fixed intensity.

Claude Code addressed this directly in v2.1.101. The April 11, 2026 release renamed the existing `/simplify` command to `/code-review` and attached an effort level flag that governs how deeply the model reasons before answering. There are five levels, low, medium, high, max, and ultra, and the review itself is rewritten at each one. Shallow levels return fast, high-confidence findings; deep levels spend more time and sweep through edge cases and subtle regressions.

This post reads that design from the perspective of ThakiCloud, which operates AI coding agents. We look at why effort level is the right axis for splitting cost and quality in code review, when to pick each level in practice, and how the idea overlaps with the skill harness and verification loop of Paxis, our agent platform. The durations and costs cited below are all reported values from Anthropic's public documentation and release notes, not figures measured by ThakiCloud.

## What the feature is

`/code-review` is a slash command that reads the diff in your current working tree, finds problems, and reports them. The key change is that you can append a level to the command. Specifying a level like `/code-review low` makes the review engine adjust its exploration scope and reasoning depth to match. Omitting the level runs the default.

What matters is that the level is not simply "make the output longer or shorter." According to the documentation, low and medium return a small set of high-confidence findings, while high and max return uncertain findings alongside the confident ones. In other words, shallow levels prioritize precision and deep levels prioritize recall; the character of the review itself changes. This also matches the psychology of the person receiving the review. On a small patch, a handful of certain findings beats a long list padded with false positives; just before a merge, missing nothing is better.

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
<div class="d3-arch" data-arch-root id="decoderevieweffortlevels-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 753, "height": 838, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 281, "y": 24, "w": 149, "h": 62, "title": ["Code change", "working tree diff"]}, {"id": "B", "x": 265, "y": 164, "w": 181, "h": 52, "title": "Select effort level"}, {"id": "C", "x": 534, "y": 308, "w": 163, "h": 78, "title": ["Precision first", "few high-confidence", "findings"]}, {"id": "D", "x": 277, "y": 308, "w": 156, "h": 78, "title": ["Recall first", "includes uncertain", "findings"]}, {"id": "E", "x": 24, "y": 316, "w": 177, "h": 62, "title": ["Cloud sandbox", "parallel agent review"]}, {"id": "F", "x": 509, "y": 472, "w": 212, "h": 62, "title": ["Second-scale response", "small patch, config change"]}, {"id": "G", "x": 256, "y": 472, "w": 198, "h": 62, "title": ["Minute-scale exploration", "pre-merge, complex state"]}, {"id": "H", "x": 24, "y": 464, "w": 177, "h": 78, "title": ["Each finding verified", "independently", "5-10 min, paid tier"]}, {"id": "I", "x": 270, "y": 620, "w": 170, "h": 46, "title": "--comment: PR inline"}, {"id": "J", "x": 260, "y": 744, "w": 191, "h": 62, "title": ["--fix: apply to working", "tree"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [355, 86, 355, 164]}, {"src": "B", "dst": "C", "kind": "data", "label": "low / medium", "curve": [[446, 215], [615, 262], [615, 262], [615, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "high / max", "line": [355, 216, 355, 308], "lx": 355, "ly": 258}, {"src": "B", "dst": "E", "kind": "data", "label": "ultra", "curve": [[267, 216], [113, 262], [113, 262], [113, 316]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "line": [615, 386, 615, 472]}, {"src": "D", "dst": "G", "kind": "data", "line": [355, 386, 355, 472]}, {"src": "E", "dst": "H", "kind": "data", "line": [113, 378, 113, 464]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[615, 534], [615, 581], [615, 581], [440, 623]]}, {"src": "G", "dst": "I", "kind": "data", "line": [355, 534, 355, 620]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[113, 542], [113, 581], [113, 581], [270, 621]]}, {"src": "I", "dst": "J", "kind": "data", "line": [355, 666, 355, 744]}]});
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
      const container = document.getElementById('decoderevieweffortlevels-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'decoderevieweffortlevels-1';
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

## When to use each of the five levels

Choosing a level is a matter of weighing the risk of the change against the time you have left. Translating the character the documentation describes into practical intuition:

low and medium are for a quick sanity check. Use them before pushing a config edit or a small patch when you only want to filter out obvious correctness bugs. Responses come back in seconds, so you can run them habitually right before a commit without breaking your flow.

high and max are for code paths just before a merge or that carry complex state. Merging a feature branch into main, or touching areas like concurrency and transactions where subtle regressions hide, falls here. These levels spend more time verifying assumptions and digging through edge cases, so findings labeled "this may not be an issue but check it" appear alongside the certain ones. Whether you treat that uncertainty as noise or as a safety net depends on the situation. Just before a merge, the safety net is the right read.

ultra is a different kind of tool. We cover it separately below.

If you compress this ladder into one sentence, it says: match review intensity to the risk of the change. This is exactly the principle we follow when operating scheduled skills. Start cheap, and escalate only the failing task to an expensive tier. Running every review at maximum intensity wastes cost, and running every review at minimum intensity plants the seed of an incident.

## --comment and --fix: putting review into the workflow

Separate from effort levels, two flags wire the review into an actual workflow. `--comment` posts findings as inline comments on the PR, and `--fix` applies findings directly to the working tree.

```bash
# Broad pre-merge review with PR comments plus local application
/code-review high --comment --fix

# Deep cloud review, then apply results to the working tree
/code-review ultra --fix
```

The solo-developer workflow the documentation offers goes like this. Combine `--comment --fix` to leave findings on the PR and apply them locally, then eyeball the diff and push. It is a way to pass the first review pass automatically without waiting on a reviewer. That said, because `--fix` touches the code, a human must review the applied diff. Automatic application is not a replacement for review; it is preparation for it.

## ultrareview: cloud multi-agent review

The ultra level is unlike the other four that run locally. Running `/code-review ultra` bundles your repository state, uploads it to a remote sandbox, and lets specialized reviewer agents analyze the code in parallel there. Each agent focuses on a different class of issue, and findings are independently verified one by one. According to the documentation, a run takes five to ten minutes, and after three free runs for Pro and Max subscribers, each run costs five to twenty dollars.

Two design decisions stand out here. First, the review is handled as a fan-out of several specialized agents rather than a single agent. Since one reviewer struggles to catch every class of defect equally well, splitting perspectives by issue type widens coverage. Second, each finding is verified independently. A fan-out on its own risks accumulating hallucinations, so it must be closed with a verification stage before merging. ultra implements both principles as a product feature.

## What this means for ThakiCloud products

The design principles of this feature overlap strikingly with what we have practiced operating an agent platform. We split it across our two products.

**Paxis lens.** Paxis is ThakiCloud's Agent-Native Cloud, treating Skills, Tools, Policies, and Audit Logs as first-class resources. The question `/code-review` poses is the same one the Paxis skill harness solves every day: which intensity of agent do you attach to which task? Paxis selects from over 960 skills via BM25 and runs them in isolated sandboxes, and the same idea as effort levels operates here. Light work like exploration and lookup goes to a cheap tier; heavy work like architectural judgment and verification goes to an expensive tier. ultra's multi-agent parallel review and per-finding independent verification share the same structure as the way Paxis closes fan-out results with a verification stage. A fan-out without verification accumulates hallucinations, and a verification gate stops it. If code review runs as one isolated agent skill whose results pass through policy gates and audit logs, that is exactly the operating model Paxis aims for.

**ai-platform lens.** The fact that ultra offloads the review to a cloud sandbox and charges per run reconfirms that agent workloads ultimately run on GPU and isolated-execution infrastructure. ThakiCloud's ai-platform provides K8s and Kueue based GPU scheduling, multi-tenant isolation, and on-premises serving. A workload that spins up a fleet of reviewer agents in parallel is exactly the kind of work such infrastructure targets. For organizations reluctant to upload source code to an external cloud in particular, the option to run the same multi-agent review pattern inside their own infrastructure becomes important. Because agent economics only hold when low-cost serving and isolated execution are in place, the two lenses complement each other.

## Limitations and counterarguments

Effort levels are not a cure-all. A few honest counterarguments.

First, the level choice itself depends on the user's judgment. Misreading the risk sends an important change through as low, or wastes ultra on a trivial one. The tool provides the axis; positioning yourself correctly on it is still up to the human.

Second, the uncertain findings that high and max produce are a double-edged sword. They can act as a safety net, but if false positives pile up they cause review fatigue and you end up ignoring the list. How much to trust an unverified finding depends on the team's discipline.

Third, ultra uploads the repository to a remote sandbox. For organizations with sensitive source, that alone is an adoption barrier. And the five-to-twenty-dollar cost per run is heavy to run often, so the team has to compute its own economics past the three free runs.

Fourth, automatic `--fix` does not replace review. Pushing without checking the applied diff lets convenient-looking automation slip in silent bugs instead. Automation is a tool that assists thinking, not one that replaces it.

Even so, the idea of effort levels points in the right direction. Matching review intensity to the risk of the change is exactly the cost-quality balance we learned operating agents.

## Sources

- [Code Review - Claude Code Docs](https://code.claude.com/docs/en/code-review)
- [Claude Code Review: How to Use /code-review and Ultrareview - Fastio](https://fast.io/resources/claude-code-review-guide/)
- [Claude Code Effort Levels Explained - MindStudio](https://www.mindstudio.ai/blog/claude-code-effort-levels-explained)
