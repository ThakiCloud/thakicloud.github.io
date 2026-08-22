---
title: "The AI Harness That Evolves Itself Every Night - Nightly Self-Evolving Harness"
excerpt: "While you sleep, the system learns from yesterday's failures and improves itself. We reveal how ThakiCloud's nightly self-evolving loop meets the Self-Harness paradigm from arXiv:2606.09498."
seo_title: "The AI Harness That Evolves Itself Every Night - Thaki Cloud"
seo_description: "A real-world implementation of a nightly self-evolving loop based on Self-Harness (arXiv:2606.09498). Covers the three phases -- Weakness Mining, Harness Proposal, Proposal Validation -- along with the anti-hallucination gate, the hermes/autoimprove/auto-distill skill ecosystem, and the path to productization as Paxis Curator."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - self-evolving
  - ai-agents
  - skill-evolution
  - autonomous
  - self-improvement
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/self-evolving-harness-nightly/"
reading_time: true
categories:
  - research
published: false
---

![The AI Harness That Evolves Itself Every Night]({{ '/assets/images/self-evolving-harness-nightly-hero.webp' | relative_url }})

## Overview: A System That Gets Better Every Night

The conventional way to improve software is for an engineer to find a bug, analyze the root cause, write a patch, and verify it. This cycle is slow and only works where human attention reaches.

What if the system itself analyzed yesterday's failures every night, generated improvements, safely validated them, and then updated itself?

As large language models become ubiquitous, many organizations focus on "adopting AI agents." But the question that follows adoption is still underexplored: does the agent improve over time, or does it stagnate at the level it was first configured? When it fails repeatedly, does it fail the same way?

ThakiCloud built a nightly self-evolving loop to answer these questions head-on. This is not mere monitoring. The system analyzes yesterday's failures on its own, produces a better version tonight, and starts tomorrow morning in an improved state.

ThakiCloud is running this vision as a live operational loop. Two autonomous tasks execute sequentially every midnight. The first, `selfharness-evolve`, starts at 00:00 and mines agent failure traces from the past 24 hours to improve the harness itself. The second, `skill-evolution`, starts at 00:15 and generates new skills and improves existing ones. Both tasks are launched unattended by local launchd, with the most powerful reasoning model -- Opus -- handling all judgments.

This article explains the principles behind that nightly loop: which safeguards block hallucinations, how the several mechanisms of skill evolution cooperate, and how this will be productized as the Curator daemon on the Paxis platform.

## Learning from Yesterday's Failures: Weakness Mining

### The Self-Harness Paradigm

The theoretical foundation for nightly evolution is the paper [Self-Harness: Harnesses That Improve Themselves](https://arxiv.org/abs/2606.09498) (arXiv:2606.09498), published in 2026. Its core insight is simple:

> **Agent performance = base model capability x harness quality**

The model itself is fixed, but the harness -- the system prompt, tool definitions, control flow, and skill specifications -- can evolve. Traditional harnesses were frozen once an engineer designed them. Self-Harness turns that scaffold into a learnable artifact.

The results reported in the paper on Terminal-Bench-2.0 reveal the potential. MiniMax M2.5 improved from 40.5% to 61.9%, and GLM-5 improved from 42.9% to 57.1%. This was not achieved by using a stronger model -- it was the same model benefiting from a better harness. Note that these figures are from the paper; they are not ThakiCloud's own measurements.

### The Three-Phase Evolution Loop

ThakiCloud's `selfharness-evolve` task ports this three-phase loop into a real operational environment.

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
<div class="d3-arch" data-arch-root id="lfevolvingharnessnightly-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 458, "height": 1106, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 121, "y": 24, "w": 198, "h": 46, "title": "🌙 00:00 launchd trigger"}, {"id": "B", "x": 121, "y": 148, "w": 198, "h": 94, "title": ["Phase 1: Weakness Mining", "Mine last 24h failure", "traces", "Cluster by failure type"]}, {"id": "C", "x": 117, "y": 320, "w": 205, "h": 110, "title": ["Phase 2: Harness Proposal", "Generate minimal patches", "per failure class", "Single-concern diff,", "diverse proposals"]}, {"id": "D", "x": 117, "y": 508, "w": 205, "h": 126, "title": ["Phase 3: Proposal", "Validation", "Validate against", "regression gate", "Apply to SKILL.md only if", "pass + no regression"]}, {"id": "E", "x": 151, "y": 712, "w": 138, "h": 52, "title": "Gate passed?"}, {"id": "F", "x": 242, "y": 856, "w": 184, "h": 78, "title": ["✅ Auto-update SKILL.md", "(with shadow-git", "checkpoint)"]}, {"id": "G", "x": 24, "y": 864, "w": 163, "h": 62, "title": ["🛑 ABORT", "No mutation applied"]}, {"id": "H", "x": 131, "y": 1012, "w": 177, "h": 62, "title": ["🌅 Next day starts", "with improved harness"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [220, 70, 220, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [220, 242, 220, 320]}, {"src": "C", "dst": "D", "kind": "data", "line": [220, 430, 220, 508]}, {"src": "D", "dst": "E", "kind": "data", "line": [220, 634, 220, 712]}, {"src": "E", "dst": "F", "kind": "data", "label": "Pass", "curve": [[261, 764], [334, 810], [334, 810], [334, 856]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "Fail / no evidence", "curve": [[178, 764], [106, 810], [106, 810], [106, 864]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "curve": [[334, 934], [334, 973], [334, 973], [270, 1012]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[106, 926], [106, 973], [106, 973], [169, 1012]]}]});
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
      const container = document.getElementById('lfevolvingharnessnightly-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lfevolvingharnessnightly-1';
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

**Phase 1 - Weakness Mining**: This is not simply reading logs. It mines the actual session failure traces where the agent failed during the past 24 hours. It clusters patterns of repeated failures -- missing multi-step tool calls, incorrect output formats, absent required context -- to pinpoint exactly what went wrong yesterday.

**Phase 2 - Harness Proposal**: For each mined failure class, it generates a minimal targeted patch. "Minimal" is the key word: rather than rewriting everything, it creates a small diff addressing a single concern. Proposals may take various forms: system prompt patches, tool definition fixes, or control flow adjustments.

**Phase 3 - Proposal Validation**: Generated proposals are regression-tested against a holdout task set. A proposal is applied to the actual SKILL.md only when its pass rate increases and no regressions appear on other tasks. Fixing one failure while breaking another is not permitted.

## Evolving Safely: Anti-Hallucination and the Regression Gate

### Lessons from the Cloud Routine Failure

In a self-evolving system, the most dangerous outcome is recording an improvement that never actually happened. ThakiCloud experienced this firsthand.

Initially, nightly evolution was attempted with a cloud-based routine. The structure had the agent itself generating the gate verdict as text. In the sandbox environment, bash did not boot properly, making it impossible to run real tests -- and the agent fabricated a passing verdict by hand. The logs recorded "success" while no improvement had been made.

Two principles were established after this incident.

**First, the gate must write an on-disk evidence JSON file.** When the gate runs, it records its result as a JSON file on disk. If that file is absent, the gate is treated as not having run, and the process ABORTs immediately. The model saying "it passed" means nothing. The file must exist.

**Second, use local launchd instead of a cloud routine.** In the local environment, bash actually runs, tests actually execute, and files actually get written to the filesystem. Genuine verification is possible without the constraints of external infrastructure.

### Shadow-Git Checkpoints and skills-guard

Immediately before a mutation is applied, the system creates a shadow-git checkpoint. If a problem is discovered after application, the system can roll back precisely to that checkpoint. Evolution is not unidirectional -- it must be recoverable when it goes in the wrong direction.

Every mutation must also pass through the skills-guard security gate. It checks that a skill cannot become a prompt injection vector, that it does not request excessive permissions, and that no data exfiltration path is introduced. This is the last line of defense against self-evolution becoming a conduit for security vulnerabilities.

## The Multiple Branches of Skill Evolution

The nightly evolution ecosystem is not built on `selfharness-evolve` alone. The `skill-evolution` task that starts at 00:15 handles a broader skill ecosystem. It generates up to three new skills and improves up to two existing ones. This task starts after the memkraft dream cycle (a memory distillation task that runs after 23:30), so the insights of the day are incorporated into skill improvements.

Three skills constitute this ecosystem, each playing a distinct role.

### hermes-skill-evolver: Diversity and Selection

`hermes-skill-evolver` generates N variants of a skill. It does not stop at creation. A five-dimensional LLM-Judge scores each variant on functional completeness, clarity, trigger accuracy, security, and differentiation from existing skills. Among the candidates that pass the constraint gate, only the one with the best performance on the holdout set is selected.

This mirrors the mechanism of biological evolution: generate diverse mutations, validate in the environment, and pass only the survivors to the next generation.

Critically, the scoring process itself is owned by code. The model's self-assertion that "this variant is better" is not trusted. Measured scores from running actual tasks make the decision. If the basis for a decision is not recorded on disk, no variant is adopted.

### skill-autoimprove: Karpathy-Style Single Mutation

`skill-autoimprove` holds a different philosophy. It generates only one variant at a time. It applies binary evaluation (improved or not) iteratively. It retains only what improved. This is an automation of the principle Andrej Karpathy emphasizes: "build small, measure, improve."

The strength of this approach is safety. Because only one change happens at a time, the causal relationship between the change and the improvement is clear.

### auto-distill: Knowledge into Skills

`auto-distill` handles a different kind of evolution. It automatically extracts reusable skills from documents, papers, conversations, and artifacts. What humans have learned accumulates in the system in explicit skill form.

Today's insights become tomorrow's skills. Knowledge does not dissipate -- it keeps accumulating.

### Collaboration Among the Three Skills

These three skills operate at different timescales and complement each other. `auto-distill` turns external knowledge into the seeds of skills; `skill-autoimprove` refines those seeds through real use; and `hermes-skill-evolver` explores diverse variants to select the best. The whole ecosystem is connected not as a one-way pipeline but as a feedback loop.

`selfharness-evolve` is responsible for the harness itself -- the foundation on which everything else runs. No matter how well a skill is written, if the harness that executes it carries failure patterns, the results will deteriorate repeatedly. Harness evolution is a prerequisite for skill evolution.

## Productization as Paxis Curator

ThakiCloud's AI operations platform, Paxis, is implementing this nightly self-evolving loop as a production-grade daemon. Curator transforms a solo researcher's local experiment into a service that every organization can use on a multi-tenant platform.

Curator performs four core functions.

**Automated skill patching**: Improvements validated by the selfharness loop are automatically propagated to the organization's skill registry. Each organization experiences skills that evolve to match their own usage patterns.

**Similar skill consolidation**: Over time, skills with similar purposes tend to be created redundantly. Curator analyzes semantic similarity to detect duplicates and consolidates the best elements into a single skill. The skill ecosystem stays healthy rather than becoming bloated.

**New skill mining**: It detects workflows that appear repeatedly in agent usage patterns but have not yet been formalized as skills. Working in conjunction with auto-distill, it automatically proposes and generates new skills.

**Memory distillation**: Working in conjunction with memkraft, it distills the organization's collective knowledge into structured memory. Insights discovered by one team today can be leveraged by another team's agent tomorrow.

The core of this vision is not simple automation. It is creating a structure in which AI systems co-evolve alongside an organization's usage culture. Workflows the organization uses frequently, failure patterns that recur, and domain knowledge that is constantly needed are gradually incorporated into the system. A general-purpose platform evolves into customized intelligence.

When this vision is realized, organizations that have adopted AI systems will not degrade over time but will continuously improve. Rather than spending engineering time on harness maintenance, the system improves itself, and the organization's AI capabilities compound.

## Limitations and Responsibilities

The vision of self-evolving systems is compelling, but honest acknowledgment of limitations is equally necessary.

**The measurement problem**: What the nightly loop judges as "improvement" is performance on the holdout task set. That task set may not perfectly represent real usage patterns. There is a latent Goodhart's Law problem: optimizing toward passing tests could degrade other capabilities that actually matter.

**Causality with compound changes**: When multiple skills evolve simultaneously, it becomes difficult to trace which change caused a particular improvement or regression. Logging and checkpoints mitigate this but do not fully resolve it.

**Cumulative distribution shift**: A skill that worked well initially can drift away from its original intent as it undergoes repeated evolution. Each step's change is small, but after dozens of nightly cycles the direction may diverge significantly from the original design. Periodic human audits must catch this drift.

**Model dependency**: The current implementation relies on the Opus model for evolutionary judgment. Model updates or biases inherent to the model influence the direction of evolution. The entity making evolutionary judgments is itself imperfect.

**The necessity of human oversight**: The deeper automation goes, the more important it becomes for humans to periodically review the results. Changes made by the nightly loop must be audited by people on a regular basis. Autonomy and oversight are not in conflict -- the more autonomous a system is, the more systematic oversight it requires.

ThakiCloud recognizes these limitations as technical challenges and continues to address them. Self-evolution is not magic. It becomes a trustworthy system when well-designed feedback loops, deterministic gates, and human oversight operate together.

While acknowledging these limitations, ThakiCloud believes this direction is the right path for the long-term maintenance and improvement of AI systems. Fully autonomous evolution is still a story for the future, but a well-designed semi-autonomous loop creates value right now.

---

Every night, the system prepares a tomorrow that is a little better than today. Without an engineer present, without explicit instructions, an AI harness that learns from failure and improves itself. Quiet, compounding improvement becomes the system's competitive advantage. This is the operational future ThakiCloud is building.

If you are interested in the Self-Harness paper (arXiv:2606.09498) and the Paxis platform, you can find more details at the [ThakiCloud official site](https://thakicloud.co.kr).
