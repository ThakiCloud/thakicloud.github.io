---
title: "How Smart RL Can Make a Model Is Already Decided by Pretraining: Chess Reveals the Scaling Law of Reasoning"
seo_title: "Pretraining Loss Predicts RL Reasoning Performance | Chess Scaling Law Study | ThakiCloud"
seo_description: "Researchers from NYU, Modal, and UCLA used chess as a controlled testbed to uncover a joint scaling law that spans the entire pipeline from pretraining to RL post-training. Post-RL performance is well predicted by pretraining loss, and the slope of the RL reward curve improves almost linearly with pretraining token count. Here is a summary of findings you can use directly when deciding how to split a GPU budget between pretraining and RL."
excerpt: "RL looks like what makes a model smart, but its ceiling is already set by pretraining. We look at a joint scaling law, discovered on the controlled testbed of chess, in which pretraining loss predicts post-RL reasoning performance."
date: 2026-07-24
tags:
  - 강화학습
  - 사전학습
  - 후처리
  - 스케일링 법칙
  - 추론
  - LLM 학습
  - 컴퓨트 배분
  - GRPO
  - 체스
  - 검증 가능 보상
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/reasoning-pretraining-to-post-training/"
---

If you are an engineer trying to improve a reasoning model with RL post-training and wondering how to split a GPU budget between pretraining and RL, this paper offers a clear answer. The headline finding is this: the ceiling on the reasoning performance RL can reach is already set by pretraining, and the relationship is regular enough to be predicted from a single number, the pretraining loss. Researchers from NYU, Modal Labs, and UCLA used chess as a controlled testbed and uncovered a joint scaling law that spans the whole pipeline, from pretraining through RL post-training.

![An abstract image of a scaling curve rising from a foundation of pretraining](/assets/images/reasoning-pretraining-to-post-training-hero.png)
*Pretraining forms the foundation that sets the ceiling for later RL performance.*

## Why This Matters

This section is written for engineers who run LLM training pipelines directly, and for platform teams who have to split a limited GPU budget across pretraining, SFT, and RL. The core takeaway is this: RL is not magic that makes a model smart out of nothing. It is a stage that pushes performance up within a ceiling already drawn by pretraining, and that ceiling can be estimated in advance from the pretraining loss. Knowing this lets you avoid wasted effort like "let's just run RL on a small model for a long time and see," and instead decide where to spend compute with actual evidence.

## Overview

Over the past two years, RL post-training has become a central tool for improving LLMs on complex reasoning tasks, refining models with verifiable rewards through methods such as GRPO and DPO. Most research, however, has treated RL as separate from the pretraining that precedes it, optimizing each stage in isolation.

This paper ties the two together into a single pipeline and asks two fundamental questions. First, how do pretraining choices, model size and data volume, govern the returns on RL compute? Second, what does RL actually do to the model? Answering these questions requires repeating the full pipeline, from pretraining to RL, under controlled conditions, which is far too costly with real large language models. That is why the team turned to chess.

## What the Study Did

Chess is a good testbed for studying reasoning. The rules are clear, the quality of a move can be verified by an engine, and difficulty can be tuned puzzle by puzzle. The team mapped a standard LLM training pipeline directly onto chess.

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
<div class="d3-arch" data-arch-root id="retrainingtoposttraining-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 386, "height": 584, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Pre", "x": 101, "y": 24, "w": 149, "h": 78, "title": ["Pretraining", "human chess games", "5M-1B parameters"]}, {"id": "SFT", "x": 142, "y": 180, "w": 212, "h": 62, "title": ["Supervised fine-tuning", "synthetic reasoning traces"]}, {"id": "RL", "x": 145, "y": 334, "w": 205, "h": 78, "title": ["Reinforcement learning", "chess puzzles, verifiable", "reward"]}, {"id": "Eval", "x": 108, "y": 490, "w": 135, "h": 62, "title": ["Evaluation", "puzzle accuracy"]}], "edges": [{"src": "Pre", "dst": "SFT", "kind": "data", "curve": [[212, 102], [248, 141], [248, 141], [248, 180]]}, {"src": "SFT", "dst": "RL", "kind": "data", "line": [248, 242, 248, 334]}, {"src": "RL", "dst": "Eval", "kind": "data", "curve": [[248, 412], [248, 451], [248, 451], [208, 490]]}, {"src": "Pre", "dst": "Eval", "kind": "event", "label": "pretraining loss predicts", "curve": [[140, 102], [104, 211], [104, 373], [144, 490]], "off": "50%"}]});
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
      const container = document.getElementById('retrainingtoposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'retrainingtoposttraining-1';
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

They first pretrained language models ranging from 5 million to 1 billion parameters on human chess games. Next came supervised fine-tuning on synthetic reasoning traces, data meant to mimic the thought process a person goes through when choosing a move. Finally, they ran RL on chess puzzles, where correctness is verifiable and rewards can be assigned unambiguously.

The advantage of this setup is that the team could freely vary parameter count and pretraining data volume and repeat the entire pipeline. In effect, they ran, on the scaled-down world of chess, a controlled experiment of a scope that would be unthinkable with actual LLMs.

## Key Findings

The results split into two main strands.

First, a joint scaling law. At a given level of RL compute, post-RL performance is well predicted by pretraining loss. In other words, how well pretraining went, before any RL touches the model, tells you fairly precisely how far RL will eventually take it. Furthermore, the slope of the RL reward curve improves almost linearly as pretraining token count increases. A model that has been pretrained more thoroughly improves faster per unit of RL compute.

The practical implication is compute allocation. Running RL longer does not make performance climb without bound. If pretraining is weak, the RL curve itself has a shallow slope, so pouring in the same RL compute yields less improvement. The paper quantifies this relationship and gives a basis for deciding how to split a fixed total budget between pretraining and RL.

Second, what RL actually does to the policy. It turns out RL is not simply sharpening the SFT policy. On easy puzzles, RL amplifies correct moves the SFT policy already favored, making what it was already good at more reliable. On hard puzzles, however, RL surfaces correct moves the SFT policy did not favor, uncovering moves it did not previously tend to play. This observation, that RL behaves qualitatively differently depending on difficulty, challenges the common view of RL as merely a process that sharpens a probability distribution.

## Implications for ThakiCloud Products

This research speaks directly to the problems ThakiCloud's ai-platform deals with day to day. ai-platform runs a training pipeline on top of K8s and Kueue GPU scheduling that supports multiple training methods, including SFT, CPT, DPO, GRPO, and GKD. When a customer wants to refine a reasoning model with their own GPU budget, the first question they run into is exactly this one: where should the compute go?

The joint scaling law in this paper gives that question a principle. Increasing the RL budget while pretraining or continued pretraining (CPT) remains weak means forcing your way up a curve with a shallow slope. Conversely, lowering the pretraining loss first means the same GPU hours spent in the following RL stage buy a larger improvement. From a platform standpoint, this means we can advise data-driven stage-by-stage budget allocation when scheduling training jobs, using pretraining loss as an observable to estimate the expected return of an RL job in advance, and adjusting Kueue queue priorities accordingly.

The finding that RL behaves differently depending on difficulty is also practically useful. Running RL on data weighted toward easy tasks may only amplify existing strengths without surfacing new capabilities. Mixing in enough hard tasks is what leads the model to discover correct behaviors it did not previously favor. For our customers running GRPO with verifiable rewards, this is a practical lesson: puzzle difficulty distribution should be designed deliberately, not left to chance.

Chess is, of course, a scaled-down world, and it differs from natural-language reasoning in many ways. Even so, the shape of the scaling law found in this controlled experiment is useful as a compass for setting the direction of compute allocation in real pipelines.

## Limitations and Counterarguments

Before accepting this paper's conclusions at face value, a few points are worth flagging.

First, chess is a closed domain with near-perfect verification. An engine judges the quality of a move exactly, so the reward signal is clean. In real natural-language reasoning, however, the reward itself can be noisy and biased. Whether the clean scaling law that holds in chess retains the same shape under messy real-world rewards is a separate question.

Second, model scale here ranges from 5 million to 1 billion parameters, small compared to frontier models. Scaling laws are risky to extrapolate. There is no guarantee that the linear relationship observed at this scale continues to hold at the scale of tens of billions of parameters. The paper itself presents this as a finding from a controlled testbed, not as a claim confirmed at frontier scale.

Third, predicting post-RL performance from the single metric of pretraining loss is powerful, but it may fail to distinguish what actually drove the loss down. When data quality and data quantity produce the same loss through different means, whether the subsequent RL behavior is truly identical needs further verification.

## Summary

This paper overturns the practice of treating RL post-training as separate from pretraining, tying the two together into a single joint scaling law. Post-RL reasoning performance is predicted by pretraining loss, and the slope of the RL curve improves almost linearly with pretraining token count. This result backs up the claim laid out at the start: the ceiling on the performance RL can reach is already set by pretraining.

The practical takeaway is clear. Before increasing the RL budget to refine a reasoning model, check first whether pretraining or continued pretraining has gone far enough. Pretraining loss is an observable that lets you estimate the expected return on RL ahead of time. And make sure the RL data mixes in enough hard tasks so the model discovers correct behaviors it did not originally favor. ThakiCloud's ai-platform builds this principle into training job scheduling, helping customers allocate their GPU budget wisely at each stage.

## Sources

- [Understanding Reasoning from Pretraining to Post-Training (arXiv:2607.16097)](https://arxiv.org/abs/2607.16097)
- [Full paper HTML (arXiv)](https://arxiv.org/html/2607.16097)
- [Author Pavel Izmailov's introduction thread (X)](https://x.com/Pavel_Izmailov/status/2079268684317508020)
</content>
