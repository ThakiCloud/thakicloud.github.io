---
title: "Token Usage Explodes, AI Spend Halves: Coinbase's Better-Defaults Strategy"
excerpt: "Coinbase CEO Brian Armstrong's recipe for controlling AI cost was not usage caps or spend alerts, but better defaults, routing, and caching. Backed by the finding that 91% of employees never hit their usage caps, the company swapped its LLM gateway defaults to open-weight models instead of adding friction. We analyze the strategy and what it implies through the lens of low-cost serving on ThakiCloud's ai-platform."
seo_title: "Coinbase's AI Cost Strategy: Routing, Caching, Defaults - Thaki Cloud"
seo_description: "Coinbase cut AI spend nearly in half even as token usage grew exponentially. The keys were model routing, aggressive caching, and open-weight defaults. We analyze the data that 91% of employees never hit caps and the LLM gateway strategy, then map it to multi-tenant low-cost serving on ThakiCloud's ai-platform."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - llmops
  - model-routing
  - inference-cost
  - open-weight-models
  - llm-gateway
  - cost-optimization
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "coins"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/coinbase-flat-ai-spend-routing-caching-defaults/"
categories:
  - llmops
---

## Overview

Any organization that uses AI seriously runs into the same dilemma at some point. The more employees use LLMs, the more productivity rises, but the token bill rises exponentially alongside it. The common response is to cap usage, send alerts when the cap is exceeded, and make expensive-model usage cumbersome. Yet this approach, rather than curbing cost, adds friction to employee productivity as a side effect.

In June 2026, Coinbase CEO Brian Armstrong shared his company's different solution. In his words, it is "how to keep AI spend flat while token usage grows exponentially," and the conclusion is clear: solve it with better defaults, routing, and caching, not with friction and spend alerts. Coinbase says it cut AI spend nearly in half while token usage exploded.

ThakiCloud runs ai-platform, which serves models across diverse customer environments, so how to control inference cost is not someone else's story. Coinbase's strategy is a single company's internal policy, but inside it are LLMOps principles that apply to anyone operating model-serving infrastructure. This article lays out that strategy as it is and analyzes what it implies from a serving-platform perspective.

## The Core: Defaults, Not Friction

The starting point of Coinbase's approach is data. While trying to tighten usage caps, they discovered that 91% of employees never hit their usage caps in the first place. In other words, the culprit driving cost up was not "a handful of heavy users maxing out their caps," but a structural problem: the default behavior of overall usage pointed at expensive models.

Out of this came the slogan "Better Defaults, not Usage Caps." Engineers can still freely choose whatever model they want. The change is to the default model they land on when they specify nothing, swapping it from an expensive frontier model to a cheaper open-weight model. Coinbase says it is experimenting with making open-weight models such as GLM 5.2 and Kimi 2.7 the defaults in its own LLM gateway.

The power of this idea is that it does not fight human behavior patterns. Most users simply take the default. Change the default and, without forcing anything, the behavior of the majority shifts naturally. It is the opposite of lowering caps and adding alerts, which creates friction between users and the system. The full flow looks like this.

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
<div class="d3-arch" data-arch-root id="ndroutingcachingdefaults-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 771, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 279, "y": 24, "w": 156, "h": 62, "title": ["Engineer request", "no model specified"]}, {"id": "B", "x": 297, "y": 164, "w": 120, "h": 46, "title": "LLM Gateway"}, {"id": "C", "x": 168, "y": 288, "w": 146, "h": 52, "title": "Default policy"}, {"id": "D", "x": 24, "y": 432, "w": 198, "h": 62, "title": ["Expensive frontier model", "high token cost"]}, {"id": "E", "x": 277, "y": 432, "w": 163, "h": 62, "title": ["Open-weight default", "GLM 5.2 / Kimi 2.7"]}, {"id": "F", "x": 279, "y": 586, "w": 191, "h": 46, "title": "Task difficulty routing"}, {"id": "G", "x": 218, "y": 732, "w": 120, "h": 46, "title": "Cheap model"}, {"id": "H", "x": 393, "y": 724, "w": 156, "h": 62, "title": ["Frontier model", "explicit selection"]}, {"id": "I", "x": 596, "y": 440, "w": 120, "h": 46, "title": "Cache lookup"}, {"id": "J", "x": 604, "y": 724, "w": 135, "h": 62, "title": ["Cached response", "0 tokens"]}, {"id": "K", "x": 404, "y": 864, "w": 135, "h": 46, "title": "Spend flattened"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [357, 86, 357, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[314, 210], [241, 249], [241, 249], [241, 288]]}, {"src": "C", "dst": "D", "kind": "data", "label": "Before", "curve": [[198, 340], [123, 386], [123, 386], [123, 432]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "After change", "curve": [[283, 340], [358, 386], [358, 386], [358, 432]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [358, 494, 369, 586]}, {"src": "F", "dst": "G", "kind": "data", "label": "Simple repetitive", "curve": [[343, 632], [278, 678], [278, 678], [278, 732]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "label": "High complexity", "curve": [[407, 632], [471, 678], [471, 678], [471, 724]], "off": "50%"}, {"src": "B", "dst": "I", "kind": "data", "curve": [[417, 199], [656, 249], [656, 386], [656, 440]]}, {"src": "I", "dst": "J", "kind": "data", "label": "Hit", "curve": [[660, 486], [672, 540], [672, 678], [672, 724]], "off": "50%"}, {"src": "I", "dst": "F", "kind": "data", "label": "Miss", "curve": [[626, 486], [555, 540], [555, 540], [435, 586]], "off": "50%"}, {"src": "G", "dst": "K", "kind": "data", "curve": [[278, 778], [278, 825], [278, 825], [404, 865]]}, {"src": "H", "dst": "K", "kind": "data", "line": [471, 786, 471, 864]}, {"src": "J", "dst": "K", "kind": "data", "curve": [[672, 786], [672, 825], [672, 825], [539, 866]]}]});
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
      const container = document.getElementById('ndroutingcachingdefaults-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ndroutingcachingdefaults-1';
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

*How a request with no model specified passes through the gateway's default policy, cache lookup, and difficulty-based routing to flatten spend at low cost. (Diagram labels in Korean, shared across languages.)*

## Three Techniques

The cost control Armstrong laid out comes down to three axes. None is a new invention, but the key is combining all three in one place, the gateway.

First, **smarter model routing**. Rather than processing every task with the same model, each task is sent to the cheapest model capable of completing it. Simple, repetitive tasks like summarization or classification are fine with a small model, and only tasks that need complex reasoning are escalated to a frontier model. The key insight is that the highest-performance model is not always necessary. There is no reason to use an expensive model on routine tasks where frontier performance makes no difference to the result.

Second, **aggressive caching**. Redundant outputs are eliminated for repeated queries. When the same question comes in multiple times, a cached response is returned instead of calling the model every time. A cache hit uses no tokens at all, so the more repetitive the workload, the larger the savings. In environments where similar questions recur, such as code assistants or internal document queries, caching is a simple but powerful lever.

Third, **a shift to cheaper open-weight models**. For routine work where frontier performance adds no value, the work moves to open-weight models. Combined with the earlier defaults strategy, the default destination of routing itself is set to open weight. Armstrong went further, predicting that within 18 months 80% of AI workloads will move to models that are 99% cheaper, and that what defines the ceiling of AI growth will be energy and compute infrastructure, not model quality.

The three techniques reinforce one another. Routing distributes tasks to the appropriate model, caching strips out repeated calls, and open-weight defaults move the center of gravity of that distribution toward low cost. This combination is the secret behind making exploding usage and flat spend hold true at the same time.

## Implications for ThakiCloud's Products

Coinbase's strategy is the story of a single company with its own internal LLM gateway, but its principles overlap precisely with the value proposition of the multi-tenant model serving offered by ThakiCloud's **ai-platform**. ai-platform serves models with vLLM and the like on top of Kubernetes and Kueue-based GPU scheduling, and what Coinbase did at a single gateway, we can provide more deeply at the serving-platform level.

First, **routing as a platform feature**. Coinbase distributed tasks to models at the gateway. Because ThakiCloud's ai-platform serves many models simultaneously in a multi-tenant environment, it can set routing policies at the infrastructure level per tenant: "small model for simple tasks, big model only for hard ones." Because we host the models directly, the freedom of routing decisions and the transparency of cost are greater than when relying on external APIs.

Second, **the economics of open-weight serving**. The core reason Coinbase set open-weight models like GLM 5.2 and Kimi 2.7 as defaults is low cost. ai-platform specializes in serving exactly these open-weight models directly in on-premises or sovereign environments. Through consumer-GPU quantized serving, high-throughput vLLM-based inference, and multi-tenant resource isolation, lowering the per-token serving cost is our competitive edge. Free from the token pricing of external frontier APIs, the more efficiently you run open-weight models on your own infrastructure, the closer you actually get to the "99% cheaper" territory Coinbase described.

Third, **the insight that energy and compute are the ceiling**. Armstrong saw that what defines the ceiling of AI growth is energy and compute infrastructure, not model quality. This points at the same place as ThakiCloud's direction of scheduling GPU resources efficiently with Kueue and emphasizing on-premises cost efficiency. In an era where inference cost determines workloads, the serving infrastructure itself, which runs the same model cheaper and more, becomes the differentiator.

On the policy and audit side, ThakiCloud's Agent-Native Cloud **Paxis** is also relevant. Coinbase's "default policy" is in essence a policy gate applied to every request passing through the gateway. Because Paxis passes every agent action through policy gates and audit logs, it can leave a traceable record of which model was used by default for which task and where the cost arose. Cost control ultimately starts from visibility, and visibility holds when every call is recorded.

## Limitations and Counterarguments

This strategy has clear limitations too. First, the accuracy problem of routing. If the judgment that "this task is fine with a small model" is wrong, quality drops, and that loss can exceed the token savings. When a task that looks simple in fact demands subtle reasoning, the price of routing it to a cheap model comes back as a wrong result. A routing policy is not something you write once and finish; it needs continuous evaluation and correction.

Second, the scope of caching. Caching is powerful for repeated queries, but in creative or personalized work where a different context and different input come in each time, hit rates are low. Not every workload benefits equally from caching, so savings depend heavily on the nature of the workload.

Third, the quality gap of open-weight models. The forecast that "within 18 months, 80% will move to models 99% cheaper" is aggressive. It is true that open-weight models are catching up fast, but a gap with frontier models still exists in areas where high-difficulty reasoning, long context, or stability matter. Set the default to open weight, but draw the boundary of when to escalate to frontier wrong, and user experience suffers. This forecast is safer read as a direction than as a certainty.

Even so, the core lesson of the Coinbase case is robust. Cost control should be solved by changing defaults and infrastructure, not by adding friction for users. And the more you own that infrastructure, that is, the more you serve models yourself, the wider your span of control. The low-cost multi-tenant serving that ThakiCloud's ai-platform pursues is precisely that foundation of control.

## Sources

- [Brian Armstrong tweet](https://x.com/brian_armstrong/status/2070670644577280109): "How to keep AI spend flat while token usage grows exponentially" (2026-06-27)
- [Coinbase Says AI Costs Are Staying Flat As Token Usage Explodes (CryptoAdventure)](https://cryptoadventure.com/coinbase-says-ai-costs-are-staying-flat-as-token-usage-explodes/)
- [Coinbase CEO Halved AI Costs (Yahoo Finance)](https://finance.yahoo.com/markets/crypto/articles/coinbase-ceo-halved-ai-costs-130000536.html)
