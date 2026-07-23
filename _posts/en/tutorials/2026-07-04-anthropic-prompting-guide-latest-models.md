---
title: "Reading Anthropic's Prompting Guide: Model-Specific Strategy for Fable 5, Sonnet 5, and Opus 4.8"
excerpt: "We work through Anthropic's official guide to prompting best practices for the latest models. Model differences, the core techniques (clarity, examples, XML, chain of thought, roles, chaining, extended thinking), and migration. We connect it to how ThakiCloud hardens prompts into contracts inside the Paxis skill harness."
tags:
  - prompt-engineering
  - claude
  - developer-experience
  - agent-native
  - paxis
date: 2026-07-04
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/anthropic-prompting-guide-latest-models/"
categories:
  - tutorials
---

![Abstract image of structured instructions layering and converging into one ordered output]({{ '/assets/images/anthropic-prompting-guide-latest-models-hero.webp' | relative_url }})
*A visualization of how clear instructions and structure converge into predictable output.*

## Overview

Writing prompts well is still eight tenths of using a model well. As models grow stronger they follow loose instructions to a degree, but pulling out stable form and quality still needs a clear contract.

Anthropic maintains an official document of prompting best practices for its latest models. This guide covers current models including Claude Fable 5, Claude Sonnet 5, and Claude Opus 4.8, and it separates where each model behaves differently, which techniques apply commonly to all models, and what to fix when moving over from an earlier generation. In this post we lay out its structure and core techniques, and connect it to how ThakiCloud treats prompts as contracts rather than improvisation inside its agent platform Paxis.

## What This Guide Is

Anthropic's prompting document is organized in three large parts.

The first is model-specific guidance. It points out where Fable 5, Sonnet 5, and Opus 4.8 respond differently, so you know the same prompt may need adjustment depending on the model. The second is techniques that apply commonly to all current models. It covers a wide range from general principles to output formatting, tool use, thinking, and agentic system design. The third is migration considerations, guiding how to revise prompts carried over from an earlier generation.

Drawn as a picture, this three-way structure looks like this.

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
<div class="d3-arch" data-arch-root id="omptingguidelatestmodels-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 750, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 444, "w": 135, "h": 46, "title": "Prompting guide"}, {"id": "B", "x": 237, "y": 856, "w": 191, "h": 46, "title": "Model-specific guidance"}, {"id": "C", "x": 258, "y": 444, "w": 149, "h": 46, "title": "Common techniques"}, {"id": "D", "x": 273, "y": 32, "w": 120, "h": 46, "title": "Migration"}, {"id": "B1", "x": 510, "y": 848, "w": 205, "h": 62, "title": ["Fable 5 Sonnet 5 Opus 4.8", "behavior differences"]}, {"id": "C1", "x": 534, "y": 747, "w": 156, "h": 46, "title": "Clear instructions"}, {"id": "C2", "x": 534, "y": 646, "w": 156, "h": 46, "title": "Multishot examples"}, {"id": "C3", "x": 527, "y": 545, "w": 170, "h": 46, "title": "Chain of thought CoT"}, {"id": "C4", "x": 531, "y": 444, "w": 163, "h": 46, "title": "XML tag structuring"}, {"id": "C5", "x": 548, "y": 343, "w": 128, "h": 46, "title": "Role prompting"}, {"id": "C6", "x": 545, "y": 242, "w": 135, "h": 46, "title": "Prompt chaining"}, {"id": "C7", "x": 506, "y": 141, "w": 212, "h": 46, "title": "Extended thinking tool use"}, {"id": "D1", "x": 506, "y": 24, "w": 212, "h": 62, "title": ["Migrating", "earlier-generation prompts"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[97, 490], [198, 879], [198, 879], [237, 879]]}, {"src": "A", "dst": "C", "kind": "data", "line": [159, 467, 258, 467]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[97, 444], [198, 55], [198, 55], [273, 55]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [428, 879, 510, 879]}, {"src": "C", "dst": "C1", "kind": "data", "curve": [[343, 490], [467, 770], [467, 770], [534, 770]]}, {"src": "C", "dst": "C2", "kind": "data", "curve": [[348, 490], [467, 669], [467, 669], [534, 669]]}, {"src": "C", "dst": "C3", "kind": "data", "curve": [[363, 490], [467, 568], [467, 568], [527, 568]]}, {"src": "C", "dst": "C4", "kind": "data", "line": [407, 467, 531, 467]}, {"src": "C", "dst": "C5", "kind": "data", "curve": [[363, 444], [467, 366], [467, 366], [548, 366]]}, {"src": "C", "dst": "C6", "kind": "data", "curve": [[348, 444], [467, 265], [467, 265], [545, 265]]}, {"src": "C", "dst": "C7", "kind": "data", "curve": [[343, 444], [467, 164], [467, 164], [506, 164]]}, {"src": "D", "dst": "D1", "kind": "data", "line": [393, 55, 506, 55]}]});
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
      const container = document.getElementById('omptingguidelatestmodels-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'omptingguidelatestmodels-1';
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

Separate from the document, Anthropic also publishes an interactive prompt engineering tutorial in nine chapters, so you can learn by running the examples and exercises directly.

## The Core Techniques

The techniques the guide stresses are not flashy tricks but repeated fundamentals. Ordered by practical impact:

Clear instructions come first. Write specifically what to do, in what form to produce it, and what to use as the evaluation criteria. Instead of a vague request like "help me," specify one result per action. Specifying the form of the output alone raises quality the most.

Multishot examples come second. Show the tone and format you want in two or three examples and the model follows that rhythm. When the output format is tricky in particular, attaching one example is far more accurate than describing it in words.

Chain of thought comes third. Requesting step-by-step reasoning before the answer raises accuracy on complex reasoning. That said, thinking costs tokens, so use it only for work that genuinely needs reasoning.

Structuring with XML tags comes fourth. Separating instructions, context, examples, and input data with tags keeps the model from confusing the role of each part. The effect is especially large when handling long context.

Role prompting comes fifth. Giving the model a specific perspective or expert role produces vocabulary and judgment that fit that context. It is useful for review, audit, and specific domain analysis.

Prompt chaining comes sixth. Splitting one large request into several stages and passing each stage's output to the next stabilizes the quality of each stage more than demanding everything at once.

Finally there are extended thinking, tool use, and agentic system design. Extended thinking is a feature that allocates budget to internal reasoning, and tool use and agent design cover the loop where the model calls external tools and takes the result back to decide the next action. This is the area that has grown in weight in the latest guide.

## Implications for ThakiCloud Products

This guide is practical for us because ThakiCloud's agent platform Paxis treats prompts in exactly this way. Paxis is an Agent-Native Cloud control plane that runs on top of ai-platform, managing skills, tools, policies, and audit logs as first-class resources. Within it, a prompt is not an improvised thing composed anew each time but a contract packaged into a skill and version controlled.

The guide's first technique, clear instructions, overlaps directly with the design principle of the Paxis skill harness. Capabilities accumulate not in a thin harness but in thick skills, and each skill explicitly defines input, processing, output, and even failure recovery. If you make code own the form and evaluation criteria of the output, the model concentrates only on generating content and the format does not waver.

XML structuring and prompt chaining touch DAG multi-agent orchestration. Paxis selects from more than 960 skills with BM25 and runs them in isolated sandboxes, and chaining, which splits a large task into stages and passes each stage's output onward, is the basic grammar of this orchestration. Making each stage an independent skill lets you re-run only the failed stage, raising recovery precision.

Role prompting and tool use combine with policy gates and audit logs. The loop where a subagent given a specific role calls tools and takes results to decide the next action becomes safely autonomous only when every action passes through policy gates and audit logs. What the guide calls agentic system design translates for us into the problem of auditable autonomous execution.

In short, the principles of good prompting and the design principles of a solid agent platform point to essentially the same place. Reduce degrees of freedom and fill a verified skeleton with content to raise average quality. This guide practices that principle at the prompt level, and Paxis at the platform level.

## Limitations and Counterarguments

This guide has caveats too. First, model-specific guidance ages over time. When a model is released or updated, a prompt that worked yesterday may respond differently today, so read the guide as a snapshot of the current moment, not dogma.

Second, knowing many techniques does not make a good prompt. Stacking XML tags, chain of thought, and role prompting all at once can instead make instructions heavy and only grow tokens. For each technique, knowing when not to use it is as important as knowing when to use it.

Third, extended thinking is not free. Thinking tokens are a cost, and turning on maximum thinking for every task is a waste. As with the model routing perspective covered earlier, the thinking budget must also be allocated to the difficulty of the task.

In conclusion, the value of this guide is not in teaching new magic. It is in sharpening the judgment of when and how to combine fundamentals. And hardening that judgment into skills and policy so you do not redo it every time is the platform's job.

## Sources

- "Prompting best practices", Claude Platform Docs: [platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- "Prompt engineering overview", Anthropic Docs: [docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- "Anthropic's Interactive Prompt Engineering Tutorial", GitHub: [github.com/anthropics/prompt-eng-interactive-tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial)
