---
title: "The Agent Teaches Itself With Skills It Wrote: How SEED Fixes the Sparse-Reward Problem"
excerpt: "The real bottleneck in agentic RL is that the reward arrives only once, at the very end of a trajectory. SEED turns that single sparse signal into dense per-token supervision by having the agent mine natural-language skills from its own trajectories and distill them back into itself."
tags: [agentic-rl, reinforcement-learning, on-policy-distillation, sparse-reward, self-evolving, llm-agents, post-training, sample-efficiency, hindsight-skills, credit-assignment]
date: 2026-07-23
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/seed-self-evolving-distillation-agentic-rl/"
categories: [research]
author_profile: true
toc: true
---

If you train LLM agents that act through multi-turn tool use and environment feedback with reinforcement learning, this post is for you. Here is the conclusion first. The most common reason agentic RL underperforms is not that the model is weak, but that the reward arrives only once at the end of a trajectory, and SEED converts that single sparse signal into dense per-token supervision by having the agent analyze its own trajectories, extract natural-language skills, and distill them back into itself. The method lifted both performance and sample efficiency across text-based and vision-based agentic tasks.

![Abstract rendering of an agent reflecting on its own trajectory and distilling knowledge back into itself](/assets/images/seed-self-evolving-distillation-agentic-rl-hero.png)
*An abstract rendering of SEED's self-evolving loop: mining skills from completed trajectories and feeding them back into the same policy.*

## Why This Is Worth Reading

This post is written for the engineer who post-trains agents with reinforcement learning and for the platform owner who designs the training infrastructure underneath. You face a single decision: how do you push additional supervision into an RL pipeline that currently rewards only the outcome? SEED (Self-Evolving On-Policy Distillation, arXiv:2607.14777) answers with a path that uses neither a separate strong teacher model nor a human-built reward model, but the policy itself as its own teacher. In short, the loop of analyzing a trajectory, extracting reusable skills, and using how much those skills shift the policy's action probabilities as the training signal manufactures supervision over intermediate decisions without any extra labels.

## Overview

The last few years of reasoning-model training have been led by outcome-based reinforcement learning, the RLVR family that uses verifiable rewards. You hand out a trajectory-level reward such as 1 for correct and 0 for wrong and push the policy upward. For single-response math or coding problems this works well. Agents are the problem. In a long trajectory that calls tools repeatedly, receives observations, and acts again, whether the final answer succeeded tells you almost nothing about whether each of the dozens of intermediate decisions in between was good or bad. A supervision gap opens up between the episode-level outcome and token-level learning. That gap is the fundamental bottleneck eating into the sample efficiency of agentic RL.

SEED proposes a way to close it. The core idea is that a completed trajectory already contains what there is to learn. A successful trajectory holds a reusable workflow; a failed one holds a trap to avoid. SEED makes this hindsight explicit as natural-language skills, then distills those skills back into the policy. And the analyst that extracts these skills is not an external model but the current policy itself. It is a self-evolving structure in which the policy both collects trajectories and mines skills from them.

## What SEED Is

In one sentence, SEED is a self-evolving framework that converts completed on-policy trajectories into training-time hindsight skills and distills their behavioral effect back into the policy model. Break it into three steps and the structure becomes clear.

First, the policy is fine-tuned to analyze completed trajectories and generate natural-language skills. These skills capture reusable workflows, decisive observations, or failure-avoidance rules. Rather than a human injecting rules through a prompt, the model extracts rules from its own experience and states them in language.

Second, during RL the current policy plays two roles at once. One is to interact with the environment and collect trajectories as usual; the other is to serve as the analyst that extracts hindsight skills from those trajectories. Because there is no separate teacher, no teacher-student distribution mismatch arises, and the skills stay aligned with the trajectory distribution the policy is actually walking right now.

Third, and this is SEED's core device, it re-scores the sampled actions under two contexts. One is an ordinary context without skills, the other is a context augmented with the extracted skills. How much the probability of a given action rises or falls when the skill is attached, that probability shift, becomes a dense per-token on-policy distillation signal. This signal is then optimized jointly with outcome-based RL. It nudges the policy toward the actions it would have chosen with higher probability had the skill been present, and crucially this auxiliary supervision stays aligned with the current trajectory distribution.

The diagram below shows the loop.

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
<div class="d3-arch" data-arch-root id="ingdistillationagenticrl-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 645, "height": 974, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 243, "y": 24, "w": 128, "h": 46, "title": "Current policy"}, {"id": "B", "x": 357, "y": 162, "w": 149, "h": 62, "title": ["Collect completed", "trajectories"]}, {"id": "C", "x": 336, "y": 302, "w": 191, "h": 62, "title": ["Same policy switches to", "analyst"]}, {"id": "D", "x": 325, "y": 456, "w": 212, "h": 62, "title": ["Natural-language hindsight", "skills"]}, {"id": "E", "x": 351, "y": 596, "w": 160, "h": 52, "title": "Re-score actions"}, {"id": "F", "x": 471, "y": 740, "w": 142, "h": 46, "title": "Base probability"}, {"id": "G", "x": 225, "y": 740, "w": 191, "h": 46, "title": "Skill-aware probability"}, {"id": "H", "x": 229, "y": 864, "w": 184, "h": 78, "title": ["Probability shift =", "per-token distillation", "signal"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "interact with environment", "curve": [[348, 70], [431, 116], [431, 116], [431, 162]], "off": "50%"}, {"src": "B", "dst": "C", "kind": "data", "line": [431, 224, 431, 302]}, {"src": "C", "dst": "D", "kind": "data", "label": "reusable workflows<br/>decisive observations<br/>failure-avoidance rules", "line": [431, 364, 431, 456], "lx": 431, "ly": 406}, {"src": "D", "dst": "E", "kind": "data", "line": [431, 518, 431, 596]}, {"src": "E", "dst": "F", "kind": "data", "label": "context without skills", "curve": [[471, 648], [542, 694], [542, 694], [542, 740]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "context with skills", "curve": [[391, 648], [321, 694], [321, 694], [321, 740]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "curve": [[542, 786], [542, 825], [542, 825], [413, 871]]}, {"src": "G", "dst": "H", "kind": "data", "line": [321, 786, 321, 864]}, {"src": "H", "dst": "A", "kind": "data", "label": "jointly optimized with outcome RL", "curve": [[229, 865], [130, 622], [130, 333], [248, 70]], "off": "50%"}]});
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
      const container = document.getElementById('ingdistillationagenticrl-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ingdistillationagenticrl-1';
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

The contrast with prior approaches is clear. Distilling from a strong external teacher requires finding that teacher, and if the teacher and student distributions drift apart the signal is contaminated. Building a human reward model is label-expensive. SEED avoids both. The teacher is the policy itself, the labels are extracted automatically from trajectories, and the signal is aligned with the current policy at every step.

## What the Paper Reports

The paper reports extensive experiments on both text-based and vision-based agentic tasks. The direction of the results is consistent. SEED improved both performance and sample efficiency, and its generalization to scenarios not seen during training was robust. Compared with powerful baseline methods, it achieved the strongest average performance across three representative agentic benchmarks, which is the paper's central claim.

An honest note belongs here. This post is written on the basis of the paper's abstract and public summary, and we encourage you to check the per-benchmark numbers directly in the source. These are not values we measured through a separate reproduction, so rather than quote absolute figures we focused on conveying the structure and direction of the results. Even the direction alone carries a clear implication. Higher sample efficiency means reaching the same performance with fewer trajectories, which is to say fewer GPU-hours, and that maps directly onto saving the most expensive resource for anyone actually running agentic RL.

## What It Means for ThakiCloud

The idea SEED puts forward touches both products ThakiCloud operates.

The Paxis angle is especially direct. Paxis is ThakiCloud's Agent-Native Cloud, treating skills, tools, policies, and audit logs as first-class resources. Within it lives a self-evolving skill layer where agents mine skills from experience and improve on their own. What SEED demonstrated academically is exactly this idea, that a loop which makes completed trajectories explicit as natural-language skills and feeds them back into behavior genuinely improves the policy. If the Paxis skill harness selects from more than 960 skills via BM25, executes them in isolated sandboxes, and passes every action through policy gates and audit logs, SEED offers the training-time theoretical backing for how those skills are born from experience and refined. Skills expressed in natural language can be read and audited by humans, which fits well with the Paxis design philosophy that prizes policy gates and audit logs.

There is an ai-platform angle too. Actually running a method like SEED requires a post-training pipeline that jointly optimizes outcome-based RL and a distillation signal, and that consumes substantial GPU resources. ThakiCloud's ai-platform operates post-training such as SFT, DPO, and GRPO on top of Kueue-based GPU scheduling and multi-tenant serving. The sample-efficiency improvement SEED emphasizes translates straight into cost on this infrastructure. Reaching the same agent quality with fewer trajectories means absorbing more training jobs on a shared GPU pool, or training more deeply on the same budget.

## Limits and Counterarguments

SEED's self-evolving structure is powerful, but the fact that the policy doubles as the analyst is a double-edged sword. In the early stage when the policy is still weak, the quality of the skills it extracts is necessarily low too, and a distillation signal built from low-quality skills risks pushing learning in the wrong direction. The price of not using a strong external teacher is that securing signal quality during the early bootstrap phase becomes the practical crux.

Extracting skills and re-scoring actions under two contexts also adds computation over pure outcome-based RL. The trade-off between the gain of fewer trajectories from better sample efficiency and the cost of adding analysis and re-scoring per trajectory will depend on the task and scale. Finally, the results this post rests on are for the three benchmarks the paper selected, and whether the gain transfers intact to other domains, especially real production agents with very different tool ecosystems, needs separate verification.

## Wrapping Up

Diagnosing the bottleneck of agentic reinforcement learning as a supervision gap rather than a lack of model capability points to a direction: before scaling the model, make the signal denser. SEED shows a path to that denser signal that does not buy it from outside but mines it, in the form of natural-language skills, from trajectories the agent has already produced and feeds back into itself. If you operate an agentic RL pipeline, the one thing to take away today is clear. If you are rewarding only the outcome, do not throw the trajectory away; check first whether there is room to extract hindsight skills and recycle them as per-token supervision. That may be the cheaper lever to try before a bigger model or a stronger teacher.

Source: [SEED: Self-Evolving On-Policy Distillation for Agentic Reinforcement Learning (arXiv:2607.14777)](https://arxiv.org/abs/2607.14777)
