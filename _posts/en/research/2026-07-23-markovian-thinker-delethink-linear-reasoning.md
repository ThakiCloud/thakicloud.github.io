---
title: "Longer Thinking, Linear Cost: How the Markovian Thinker and Delethink Redesign Long Reasoning"
excerpt: "The real cost of long reasoning comes from the state growing without bound. Markovian Thinking breaks reasoning into fixed-size chunks and passes only a short state across each boundary, turning cost from quadratic into linear."
tags: [long-reasoning, chain-of-thought, markovian-thinking, delethink, reinforcement-learning, inference-cost-optimization, linear-scaling, kv-cache, test-time-scaling, inference-serving]
date: 2026-07-23
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/markovian-thinker-delethink-linear-reasoning/"
categories: [research]
author_profile: true
toc: true
---

If you have hit the point where making a reasoning model think ever longer becomes unaffordable, this post is for you. Here is the conclusion first. The real cost of a long chain of thought is that the state grows without bound while the model thinks, so cost scales with the square of the thinking length, and Markovian Thinking lowers that cost to linear by making the policy advance reasoning while conditioning only on a fixed-size state. In Delethink, the environment that instantiates this idea, a 1.5B model trained with 8K-token chunks thinks up to 24K tokens and matches or surpasses the same-budget baseline, and at a 96K thinking length the training cost drops from 27 H100-months to 7.

![Abstract rendering of long reasoning flowing along a linear track in fixed-size chunks](/assets/images/markovian-thinker-delethink-linear-reasoning-hero.png)
*An abstract rendering of Markovian Thinking: breaking long reasoning into fixed-size chunks and passing only a short state forward.*

## Why This Is Worth Reading

This post is written for the engineer who serves or trains long-reasoning models with reinforcement learning, and for the platform owner accountable for that inference cost. The decision you face is this: you want the model to think longer, but how do you absorb the compute and memory that jump quadratically with that length? Markovian Thinking (arXiv:2510.06557, McGill-NLP) answers by decoupling thinking length from context size. In short, if you break reasoning into fixed-size chunks and keep only a short textual state to carry across each chunk boundary, then no matter how long the thinking gets, cost grows only linearly and memory stays constant.

## Overview

Over the last few years, reasoning-model performance has climbed by lengthening the chain of thought. The premise is that thinking longer lets you solve harder problems. But this lengthening thinking carries a hidden price. In the standard RL thinking environment, the state is defined as the prompt plus every reasoning token generated so far. As the model keeps thinking, the state keeps swelling, and an attention-based policy has to re-read that growing state each time, so compute scales with the square of thinking length. Memory grows alongside it. Double the thinking, and cost quadruples.

Markovian Thinking revisits that premise itself. Instead of letting the state grow without bound, it makes the policy advance reasoning while conditioning only on a fixed-size state. It cuts the link that tied thinking length to context size, so that as thinking lengthens, compute stays linear and memory stays constant. Just as in a Markov process the next state depends only on the immediately preceding fixed state, the next piece of thinking depends only on the fixed state just handed over, not on all prior tokens.

## What the Technique Is

The concrete instantiation of Markovian Thinking is a reinforcement-learning environment called Delethink. Delethink structures reasoning into fixed-size chunks. Within each chunk the model thinks freely as usual. When it reaches a chunk boundary, the environment resets the context and reinitializes the prompt with a short carryover. The key is what the policy learns through RL. Near the end of each chunk, the policy learns to write for itself a textual state sufficient to continue reasoning seamlessly after the reset. The next chunk inherits only this short state, not the entire preceding chunk.

The diagram below shows the flow.

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
<div class="d3-arch" data-arch-root id="delethinklinearreasoning-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 568, "height": 868, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 212, "h": 62, "title": ["Chunk start: initialize", "with short carryover state"]}, {"id": "B", "x": 106, "y": 164, "w": 191, "h": 62, "title": ["Think freely within the", "chunk as usual"]}, {"id": "C", "x": 97, "y": 318, "w": 209, "h": 52, "title": "Chunk boundary reached?"}, {"id": "D", "x": 102, "y": 462, "w": 198, "h": 62, "title": ["Write a textual state at", "the chunk's end"]}, {"id": "E", "x": 109, "y": 602, "w": 184, "h": 62, "title": ["Environment resets the", "context"]}, {"id": "F", "x": 24, "y": 742, "w": 212, "h": 94, "title": ["Next chunk: carry only the", "short state", "instead of the full", "history"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[161, 86], [201, 125], [201, 125], [201, 164]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[206, 226], [214, 272], [214, 272], [206, 318]]}, {"src": "C", "dst": "B", "kind": "data", "label": "no", "curve": [[180, 318], [143, 272], [143, 272], [178, 226]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "yes", "line": [201, 370, 201, 462], "lx": 201, "ly": 412}, {"src": "D", "dst": "E", "kind": "data", "line": [201, 524, 201, 602]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[201, 664], [201, 703], [201, 703], [169, 742]]}, {"src": "F", "dst": "A", "kind": "data", "curve": [[91, 742], [59, 563], [59, 272], [99, 86]]}, {"src": "D", "dst": "D", "kind": "event", "label": "RL rewards writing a good state", "curve": [[300, 477], [414, 462], [414, 524], [300, 509]], "off": "50%"}]});
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
      const container = document.getElementById('delethinklinearreasoning-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'delethinklinearreasoning-1';
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

The difference from the standard long chain-of-thought approach (LongCoT) is exactly here. LongCoT keeps piling every generated token into the context, so the state grows without bound. Delethink empties the context at each chunk and passes only a short state, so the state size stays fixed. You lengthen the thinking by stitching more chunks together, but the amount loaded into the context at any one time is capped at a single chunk.

## What the Paper Reports

The numbers the paper reports show that the idea actually works. An R1-Distill 1.5B model trained in Delethink with 8K-token chunks thinks up to 24K tokens and matches or surpasses a LongCoT-RL model trained with a 24K budget. It managed reasoning three times longer than the 8K window it ever sees at once.

The cost difference widens with scale. The paper reports that at an average thinking length of 96K, LongCoT-RL costs 27 H100-months of training versus 7 for Delethink. That is the gap linear-versus-quadratic makes.

| Item | LongCoT-RL | Delethink (Markovian Thinking) |
|---|---|---|
| State size | grows without bound with thinking length | fixed at chunk size |
| Compute scaling | quadratic in thinking length | linear in thinking length |
| Training cost at 96K thinking | 27 H100-months | 7 H100-months |
| Test-time scaling | tends to plateau | keeps improving |

Test-time scaling shows a difference too. When you push thinking longer at inference, Delethink keeps improving where LongCoT plateaus. Another intriguing observation comes from analysis at RL initialization: off-the-shelf reasoning models from 1.5B to 120B often sample Markovian traces zero-shot across diverse benchmarks. These naturally occurring positive samples are what make RL effective at scale.

An honest note here as well. All the figures above are values the paper reports, not something we reproduced and measured ourselves. We encourage you to check the specific experimental conditions directly in the source and the public code repository.

## What It Means for ThakiCloud

The practical implication of Markovian Thinking reaches both of ThakiCloud's products.

The ai-platform angle is especially direct. What actually drives up the cost of serving long reasoning is the KV cache and attention compute that grow as thinking lengthens. If the context grows without bound, the number of concurrent requests you can fit on a single H200 drops, and GPU memory pressure worsens in a multi-tenant setting. Capping the amount loaded into the context at chunk size, as in Markovian Thinking, keeps the KV cache footprint constant regardless of thinking length. That means absorbing more concurrent inference on the same hardware under Kueue-based GPU scheduling, even for workloads that demand longer thinking. The tighter the GPU budget, as in on-premises and sovereign deployments, the larger the payoff of linear cost.

There is a Paxis angle too. Paxis is ThakiCloud's Agent-Native Cloud, running workflows in isolated sandboxes where agents reason at length across many steps and call tools. As an agent's reasoning lengthens, the context swells and cost and latency rise together; the fixed-state carryover of Markovian Thinking offers a way to keep long agent loops at constant memory. When the skill harness chains several skills together for a long task, a design in which each step inherits only a compressed state rather than the full history improves agent economics directly.

## Limits and Counterarguments

The biggest question is information loss. Resetting the context at a chunk boundary and passing only a short state means that any detail of the preceding chunk not captured in that short state is gone for good. The policy must genuinely learn to compress what matters into the state, and getting the state size and chunk size wrong can hurt performance on problems that demand long-range dependencies. Not every kind of reasoning chunks cleanly into a Markovian form.

The approach also only works once RL has trained the state-writing habit. Apply it as-is to a model that has not yet learned to write states and the chunks break apart. That said, the paper's observation that off-the-shelf models already sample Markovian traces to some degree eases this bootstrap burden. Finally, the reported gains are for the paper's experimental setup and benchmarks, and whether they transfer intact to real production inference in very different domains needs separate verification.

## Wrapping Up

Before trying to solve the cost of long reasoning by scaling the model, Markovian Thinking says to change the definition of the problem itself: do not let the state grow without bound, fix it. If you serve or train long reasoning, the one thing to take away today is clear. Lengthening the thinking and growing the context without bound are not the same thing, and separating the two opens room to get the same performance for far less cost. Letting the policy learn for itself what to keep and what to discard at a chunk boundary is a cheap lever worth examining first, in a serving reality where inference cost is business cost.

Source: [The Markovian Thinker: Architecture-Agnostic Linear Scaling of Reasoning (arXiv:2510.06557)](https://arxiv.org/abs/2510.06557) · [Code repository (McGill-NLP/the-markovian-thinker)](https://github.com/McGill-NLP/the-markovian-thinker)
