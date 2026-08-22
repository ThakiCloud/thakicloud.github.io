---
title: "The Agent Fixes Its Own Harness: What Self-Harness Reveals About the Real Bottleneck of Self-Improvement"
seo_title: "Self-Harness Paper Review: A 3-Stage Loop Where the Harness Improves Itself | ThakiCloud"
seo_description: "A walkthrough of Self-Harness (arXiv 2606.09498), which lifted MiniMax M2.5, Qwen3.5-35B-A3B, and GLM-5 on Terminal-Bench-2.0 from 40.5% up to 61.9% pass rate. Without human engineers, the agent fixes its own harness through weakness mining, harness proposal, and proposal validation. We examine, from a ThakiCloud viewpoint, why the evaluator is the real bottleneck of any self-improvement loop."
excerpt: "Without touching model weights, fixing only the harness raised Terminal-Bench pass rates by more than 60% in relative terms. But the ceiling of this loop is set by how demanding the evaluator becomes."
date: 2026-07-25
tags:
  - 에이전트
  - 자가개선
  - 하네스
  - 에이전트 하네스
  - Terminal-Bench
  - 평가자
  - LLM 에이전트
  - 에이전트 루프
  - 프로덕션 에이전트
  - MLOps
categories: [research]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/self-improving-agent-harness/"
published: false
---

If you run an agent harness in production, you are probably always wondering where the headroom for higher pass rates hides once you stop swapping in a bigger model. The conclusion of Self-Harness (arXiv 2606.09498) is this: that headroom lives not in the model but in the harness, and, remarkably, an agent can recover much of it by fixing its own harness with no human in the loop. How far this self-improvement loop climbs, however, depends not on the generator but on how demanding the evaluator becomes. This post lays out the mechanism and its limits.

## Why Read This

This post is written for engineers who operate an agent harness directly, and for platform owners who want to design a self-improvement loop. By harness we mean the entire scaffolding around the model: the system prompt, tool definitions, routing rules, and output-validation gates. The core conclusion is that the lever for raising agent performance is not only model replacement but harness improvement, and that an agent can repeat that improvement on its own. The ceiling, though, is set by the quality of the evaluator. Knowing this lets you defer the reflex decision of "performance is weak, so let us move to a bigger model" and instead fix the harness and the evaluator first.

## Overview

Over the past two years, the center of gravity in agent research has shifted from the model itself to the scaffolding around it. It has been confirmed again and again that with the same model, results change greatly depending on how you write the system prompt, which tools you provide, and how you feed failures back in. Yet improving this harness remained a human engineer's job: the tedious manual work of collecting and reading failure cases, revising prompts, and refining tools continued.

Self-Harness hands that manual work to the agent. Without bringing in a human engineer or a stronger external agent, it makes the agent fix its own harness. The question the paper poses is simple: how much does performance rise if you leave model weights untouched and repeatedly fix only the harness, and where does that improvement stop?

## What the Research Is

The backbone of Self-Harness is a loop of three interlocking stages: Weakness Mining, Harness Proposal, and Proposal Validation.

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
<div class="d3-arch" data-arch-root id="elfimprovingagentharness-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 460, "height": 600, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 212, "h": 78, "title": ["Weakness Mining", "Extract the harness defect", "points from failed runs"]}, {"id": "B", "x": 216, "y": 180, "w": 212, "h": 78, "title": ["Harness Proposal", "Generate concrete edits to", "prompts, tools, and rules"]}, {"id": "C", "x": 123, "y": 336, "w": 205, "h": 78, "title": ["Proposal Validation", "Evaluate whether the edit", "actually raises pass rate"]}, {"id": "D", "x": 60, "y": 506, "w": 191, "h": 62, "title": ["Improved harness", "Model weights unchanged"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[226, 102], [322, 141], [322, 141], [322, 180]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[322, 258], [322, 297], [322, 297], [274, 336]]}, {"src": "C", "dst": "D", "kind": "data", "label": "\"Pass: merge into harness\"", "curve": [[226, 414], [226, 460], [226, 460], [184, 506]], "off": "50%"}, {"src": "C", "dst": "A", "kind": "event", "label": "\"Fail: discard\"", "curve": [[178, 336], [130, 297], [130, 141], [130, 102]], "off": "50%"}, {"src": "D", "dst": "A", "kind": "data", "curve": [[104, 506], [26, 375], [26, 219], [78, 102]]}]});
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
      const container = document.getElementById('elfimprovingagentharness-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'elfimprovingagentharness-1';
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

The first stage, Weakness Mining, digs through failed runs to find which part of the harness caused the problem. The point is not simply "it was wrong" but pinpointing which file or which procedure led the agent astray. The second stage, Harness Proposal, targets that weakness and produces concrete edits for how to change the system prompt, tool definitions, and routing rules. The third stage, Proposal Validation, checks whether that edit actually raises the pass rate. Only edits that pass here are merged into the harness; those that do not are discarded.

The crucial point in this structure is that model weights are never trained. The only thing that improves is the scaffolding outside the model. That leaves room for teams with no budget to retrain weights, and for teams that use closed models through an API only, to apply this method directly.

## Actual Experimental Results

The paper ran Self-Harness on a benchmark called Terminal-Bench-2.0 with three base models. The results are summarized below.

| Base model | Pass rate before | Pass rate after | Relative gain |
|---|---|---|---|
| MiniMax M2.5 | 40.5% | 61.9% | about +53% |
| Qwen3.5-35B-A3B | 23.8% | 38.1% | about +60% |
| GLM-5 | 42.9% | 57.1% | about +33% |

All three models showed clear gains in pass rate on held-out problems (problems not used for improvement), even though the weights were never touched. For Qwen3.5-35B-A3B the relative gain reached about 60%. It is also notable that in absolute terms the weakest starting model improved by the largest margin, which invites the reading that the flimsier the harness, the more room it has to fix itself.

One caveat here: these numbers are values we confirmed from the paper's abstract and introduction, not figures we reproduced ourselves. Terminal-Bench-2.0 measures the ability to carry out real tasks in a terminal environment, so whether the same harness-improvement technique transfers with the same margin to other domains (say, document generation or data analysis) must be verified separately.

## The Real Bottleneck of a Self-Improvement Loop: The Evaluator

The passage most worth dwelling on in this paper is not the performance numbers but where those numbers stop. The third stage, Proposal Validation, is the evaluator of this loop. And a self-improvement loop tends to stall the moment the evaluator stops getting harder. If the bar for passing a proposal is loose, the agent keeps admitting changes that do not actually make it better, and the loop merely spins in place.

This overlaps exactly with a discipline we have stressed repeatedly as an internal rule: before merging fanned-out results, you must close them with a verification stage; that verification must be adversarial and take a different view from the generator; and when quality is poor, the most common cause is not "the model is weak" but "there is no verification stage, or it is weak." Self-Harness backs this principle with benchmark numbers. In other words, if you want to raise the ceiling of self-improvement, make the evaluator more demanding before you make the generator bigger.

## Implications for ThakiCloud Products

This paper is especially direct from our Paxis viewpoint. Paxis is ThakiCloud's Agent-Native Cloud, a control plane that treats Skills, Tools, Policies, and Audit Logs as first-class resources. It selects from more than 960 skills via BM25, runs them in isolated sandboxes, and passes every action through policy gates and audit logs. The harness that Self-Harness talks about, that set of prompts, tools, and routing rules, is exactly the Paxis skill harness.

The three-stage loop of Self-Harness maps naturally onto the self-evolving skill layer of Paxis. Weakness mining, which pulls weaknesses from failed-run records, is handled by our skill retrospection and mining routines; harness proposal corresponds to the evolution stage that revises skills and rules; and proposal validation corresponds to deterministic gates and adversarial voting. The paper's conclusion that "the evaluator is the bottleneck" touches directly on our discipline of owning gates in code, separating the verification stage from the generator, and treating an evaluator that never rejects anything as broken.

From an infrastructure angle, the ai-platform lens works alongside this. Improving performance by fixing only the harness means improving by changing only the inference-time scaffolding, without expensive retraining. In a K8s-based multi-tenant serving environment, this opens a path to iteratively improve per-customer harnesses without paying GPU retraining costs. Low-cost serving creates agent economics, and on top of it harness self-improvement lifts quality.

## Limitations and Counterarguments

Self-Harness has clear limits too. First, the ceiling of this method is ultimately tied to the quality of the evaluator. If the validation stage cannot properly separate real performance, the loop stalls or, worse, overfits to benchmark-specific patterns. Second, these are numbers from one specific benchmark, Terminal-Bench-2.0, so whether the same margin of improvement reproduces under a different task distribution is unconfirmed. Third, there is a risk that as the harness grows and gets more complex on its own, it grows in directions that are hard to control. Left to fix itself indefinitely without human review, the harness may reach a state where no one can explain why it behaves as it does.

So when putting this technique into a real system, it is more realistic to add safeguards, having humans periodically review samples and continually strengthen the evaluator itself, rather than letting self-improvement run fully autonomous. The principle that automation is a tool to assist thinking, not to replace it, applies here as well.

## Wrap-Up

Boiled down to one sentence, the practical lesson of Self-Harness is this: when agent performance hits a wall, the first place to touch is not a bigger model but the harness and the evaluator that scores it. The result of raising pass rates by more than 60% in relative terms without touching model weights shows that a substantial amount of unrecovered performance still sits inside the scaffolding. But the ceiling of that recovery is set by the evaluator. If you run a self-improvement loop, we suggest that in your next sprint you make the evaluator more demanding before the generator. That is the surest lever this paper proved with numbers.

## Sources

- Self-Harness: Harnesses That Improve Themselves, arXiv 2606.09498 (<https://arxiv.org/abs/2606.09498>)
