---
title: "Back from GRPO to PPO: How GLM-5.2 Stabilized RL with IcePop"
seo_title: "GLM-5.2 PPO IcePop Reinforcement Learning Analysis - Thaki Cloud"
seo_description: "An analysis of why GLM-5.2 went back to PPO with a trained value model instead of GRPO, and how IcePop fixed the train-inference distribution mismatch. Covers the slime, Megatron, and SGLang infrastructure and implications for the ThakiCloud LLM training platform."
excerpt: "The dominant trend in RL post-training these days is the GRPO family, which drops the critic. GLM-5.2, however, went back to PPO with a revived value model and used IcePop to fix train-inference mismatch. This post covers the reasoning behind that choice and its implications for ThakiCloud's training infrastructure."
date: 2026-07-10
tags:
  - reinforcement-learning
  - ppo
  - grpo
  - icepop
  - glm
  - llm-training
  - rlhf
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/glm-5-2-ppo-icepop/"
lang: en
---

Any team that has actually run reinforcement learning (RL) post-training on large language models knows that the trend of the past year or two has leaned heavily in one direction. Since DeepSeek released GRPO, the practice of dropping the separate value model (critic) and estimating advantage purely from relative reward within a group has become close to standard. Without a critic to train, memory and compute costs drop and the implementation gets simpler. The claim that "critics are no longer necessary" has become something close to conventional wisdom.

Zhipu's GLM-5.2, however, runs directly against this trend. The model abandons the group-relative approach and goes back to PPO with a trained value model, while addressing RL's chronic instability problem, the train-inference distribution mismatch, with a technique called IcePop. What makes this interesting is that the choice is not a simple regression. It amounts to an empirical rebuttal of the recent conventional wisdom that "GRPO is universally superior."

![An abstract image depicting the reinforcement learning path returning from GRPO to PPO]({{ '/assets/images/glm-5-2-ppo-icepop-hero.png' | relative_url }})
*Depicting the directional shift in RL post-training: dropping the critic, then bringing it back.*

## Overview

GLM-5.2 is an open-weight model with a one-million-token context window that shows strong performance on long-horizon coding and agentic benchmarks. This post is not about the model's raw performance numbers, but about the RL post-training design decisions behind that performance. There are two key points. First, the model went back to PPO with a trained value model instead of the group-relative approach (GRPO). Second, it mitigated the resulting train-inference mismatch with IcePop, while removing the KL regularization term that was part of the original IcePop formulation, in order to speed up RL improvement.

This topic matters from ThakiCloud's perspective for a concrete reason. The LLM training pipeline we operate supports several post-training methods, including SFT, CPT, DPO, GRPO, and GKD. The choice of RL methodology is not merely a matter of algorithmic taste. It is an infrastructure decision that directly affects GPU budget, training stability, and reproducibility. GLM-5.2's case pushes us to ask not just "what should we use" but "why should we use it."

## The Wall GRPO Hit: The Cost of Dropping the Critic

Let's first look at why so many teams moved to GRPO. Traditional PPO uses an actor-critic structure. A policy (the actor) generates tokens, while a separate value model (the critic) estimates the expected reward of each state. This value estimate is used to compute advantage (typically via GAE), and the policy is updated with a clipped surrogate objective. The problem is the cost of training this critic. You need to run an additional model that is roughly the same size as the policy, and if the critic converges poorly, the entire training run can become unstable.

GRPO removes the critic entirely. It samples multiple responses for the same prompt, normalizes the reward within that group, and derives advantage purely from relative standing. With no critic, memory usage drops, and the instability that comes from training a value model disappears along with it. The approach is also mathematically clean, which helped it spread quickly.

But there is no free lunch. The group-relative approach loses signal when the variance within a group is small, that is, when the responses are all similarly good or similarly bad. It also struggles with fine-grained, token-level credit assignment over long sequences. A value model can estimate, state by state, "how much did this token contribute to the final reward." Group normalization alone cannot deliver that resolution. This limitation is most pronounced in problems with long trajectories and sparse rewards, such as long-horizon coding and agentic tasks. That is precisely the territory GLM-5.2 was targeting.

## GLM-5.2's Choice: PPO with a Revived Value Model

The GLM-5.2 team brought the trained value model back. In other words, they restored the critic that GRPO had discarded, in order to regain token-level advantage estimation resolution. Contrary to the prevailing sentiment that "the PPO hype is overblown," they bet instead that a well-trained value model gives a more stable signal over long trajectories.

The problem is that the moment you revive the critic, the training instability mentioned earlier comes back with it. And on top of that, a newer headache specific to modern RL stacks compounds the issue: train-inference distribution mismatch.

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
<div class="d3-arch" data-arch-root id="20260710glm52ppoicepop-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 575, "height": 978, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 181, "y": 24, "w": 120, "h": 46, "title": "Prompt batch"}, {"id": "B", "x": 220, "y": 148, "w": 191, "h": 62, "title": ["Inference engine SGLang", "generates rollouts"]}, {"id": "C", "x": 213, "y": 288, "w": 205, "h": 46, "title": "Generated tokens + reward"}, {"id": "D", "x": 216, "y": 412, "w": 198, "h": 62, "title": ["Training engine Megatron", "recomputes forward pass"]}, {"id": "E", "x": 204, "y": 552, "w": 223, "h": 100, "title": ["Inference probability", "differs", "from training probability", "distribution mismatch"]}, {"id": "F", "x": 338, "y": 752, "w": 205, "h": 62, "title": ["Importance ratio explodes", "training collapses"]}, {"id": "G", "x": 99, "y": 744, "w": 184, "h": 78, "title": ["Suppress high-mismatch", "tokens", "stable policy update"]}, {"id": "H", "x": 24, "y": 900, "w": 184, "h": 46, "title": "Value model PPO update"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[268, 70], [315, 109], [315, 109], [315, 148]]}, {"src": "B", "dst": "C", "kind": "data", "line": [315, 210, 315, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [315, 334, 315, 412]}, {"src": "D", "dst": "E", "kind": "data", "line": [315, 474, 315, 552]}, {"src": "E", "dst": "F", "kind": "data", "label": "\"No correction\"", "curve": [[380, 652], [440, 698], [440, 698], [440, 752]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "\"IcePop masking\"", "curve": [[250, 652], [191, 698], [191, 698], [191, 744]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "curve": [[191, 822], [191, 861], [191, 861], [144, 900]]}, {"src": "H", "dst": "A", "kind": "data", "curve": [[92, 900], [51, 602], [51, 311], [181, 67]]}]});
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
      const container = document.getElementById('20260710glm52ppoicepop-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260710glm52ppoicepop-1';
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

## IcePop: Fixing the Train-Inference Mismatch

Modern RL post-training moves back and forth between two different engines. Rollouts, that is response generation, are handled by a high-throughput inference engine such as SGLang, while the forward computation for the actual policy update is handled by a training engine such as Megatron. The problem is that even when these two engines use the same model weights, differences in kernel implementation, numerical precision, and computation order cause them to produce subtly different probabilities for the same token.

RL typically corrects for this gap using importance sampling, which multiplies by the ratio between the inference-time policy probability and the training-time policy probability. But for tokens where the two distributions diverge, this ratio can explode or collapse. When a handful of tokens with runaway ratios come to dominate the gradient, the entire training run becomes unstable, and in severe cases it collapses. The longer the trajectory, that is, the more tokens involved, the higher the probability that these spikes accumulate. For GLM-5.2, which targets long-horizon tasks, this was an especially critical problem.

IcePop tackles this mismatch head on. It identifies tokens where the inference distribution and the training distribution diverge significantly, and suppresses or masks that token's contribution, so the gradient is not dragged around by a small number of unstable tokens. The result is that only the signal from stable tokens is retained and used in the policy update. This lets the training keep the benefits of PPO with a revived value model while avoiding the collapse caused by train-inference mismatch.

Where GLM-5.2 diverges from the original IcePop is that it removes the KL regularization term. Many RL recipes apply a KL penalty to keep the policy from drifting too far from the reference policy. This term improves stability, but it also caps how much the policy is allowed to improve. The GLM-5.2 team judged that IcePop's distribution-mismatch masking already handled most of the instability, so they dropped the KL term and allowed the policy to improve more aggressively. In effect, they removed one stability mechanism and handed that role over to IcePop's token selection.

## Infrastructure: slime, Megatron, SGLang

For this algorithm to work in practice rather than remain an idea on paper, it needs infrastructure that can withstand RL at scale. GLM-5.2's post-training was carried out on top of an RL scaling framework called slime, using Megatron-LM for distributed training and SGLang for high-throughput rollout generation. The train-inference mismatch described above arises directly from this configuration. Because Megatron (training) and SGLang (inference) each use their own optimized kernels, probabilities diverge between the two, and IcePop is designed precisely to target this structural gap.

In other words, IcePop is less a pure algorithmic improvement and more a joint system-and-algorithm design response to a system-level problem that inevitably arises in modern RL stacks that separate the training engine from the inference engine. The lesson for practitioners is clear. When choosing an RL methodology, you cannot look at the algorithm alone. You have to consider the combination of training and inference engines that algorithm runs on.

## Implications for ThakiCloud's Product

ThakiCloud's ai-platform is a K8s-based AI/ML infrastructure that operates a training pipeline supporting GPU scheduling through Kueue and multiple post-training methods (SFT, CPT, DPO, GRPO, GKD). GLM-5.2's case has direct implications for how this pipeline should be designed.

First, RL methodology is not something to fix in place. It is a choice to be made based on the problem at hand. For short-trajectory preference alignment, critic-free GRPO remains economical, but for problems where token-level credit assignment matters, such as long coding or agentic trajectories, PPO with a value model can provide a more stable signal. In a platform like ours that supports multiple methods, exposing this choice so users can switch based on the characteristics of their problem creates real, practical value.

Second, train-inference mismatch is not someone else's problem for us either. If you run a decoupled RL setup, drawing rollouts from an inference engine (the vLLM/SGLang family) while running the update on a training engine, in a multitenant environment, the same kind of probability mismatch can occur. Preparing a token-selection correction like IcePop as an option in the training runtime can significantly improve training stability for customers who want to fine-tune their own models with RL in an on-premises or sovereign environment. Low serving cost combined with a stable training pipeline is a decisive advantage for teams considering self-hosting.

From an agent perspective, this connects to Paxis as well. Paxis is the Agent-Native Cloud that runs on top of ai-platform, treating skills, tools, and policies as first-class resources. GLM-5.2's emphasis on long-horizon agent trajectory training is, at its core, about strengthening an agent's ability to complete tasks by calling tools across multiple steps. The lesson from this case, that a well-trained value model provides finer-grained signal over long trajectories, is worth keeping in mind when thinking through training strategies to improve the quality of the multi-step agent workflows Paxis handles.

## Limitations and Counterarguments

This case should be generalized with caution. First, it should not be read as a simple conclusion that "PPO is better than GRPO." GLM-5.2's choice is a judgment made within a specific problem setting characterized by long horizons and sparse rewards. For problems with short, dense reward signals, the cost of maintaining a critic can outweigh the benefit, in which case GRPO remains a reasonable choice. The practical constraint that reviving the value model increases the GPU memory budget again also still applies.

Removing IcePop's KL term is not a universal solution either. KL regularization is a safeguard against the policy running away from the reference policy. Removing it and relying entirely on distribution-mismatch masking for stability only holds up under the assumption that the masking works well. That assumption could break down under a different data distribution or a different combination of inference engines, so rather than porting this decision over directly, teams need a process to verify stability in their own environment.

Finally, the technical explanation in this post is a synthesis of publicly available analyses and papers (arXiv's "GLM-5: from Vibe Coding to Agentic Engineering") as well as secondary commentary. Specific hyperparameters and exact benchmark numbers should be confirmed directly against the original source, and implementation details not covered here may prove decisive for actual reproduction. RL post-training is a particularly difficult area to reproduce, so it is safer to treat this as "a direction worth considering" rather than "a recipe that just works."

## Sources

- [arXiv, "GLM-5: from Vibe Coding to Agentic Engineering" (arXiv:2602.15763)](https://arxiv.org/abs/2602.15763)
- ["Why is GLM-5.2 So Good: The GRPO to PPO Switch", Medium (Coding Nexus)](https://medium.com/coding-nexus/why-is-glm-5-2-so-gooood-the-grpo-to-ppo-switch-5b3b7d613ace)
- ["Zhipu's GLM-5.2: A Usability Breakthrough for Chinese Open-Source Models?", Weijin Research](https://weijinresearch.substack.com/p/zhipus-glm-52-a-usability-breakthrough)
