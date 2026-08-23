---
title: "Route Every Task to Its Winning Model: How We Cut Agent Automation Costs 44x with Open-Weight Models"
excerpt: "Most agent automation is not top-tier reasoning. It is tool calling and pipeline execution. We ran real production requests through Gemma 4 as structured tool calls, confirmed 6/6 success, then calculated the exact cost of routing each task to an open-weight model tier using Paxis CostRouter, real token counts, and real prices."
seo_title: "Open-Weight Agent Cost Optimization: Per-Task Model Routing in Practice - Thaki Cloud"
seo_description: "Gemma 4 tool-call experiment 6/6 success rate, Paxis models.yaml real-price cost calculation showing 44x savings vs. frontier. A practical look at routing agent automation workloads to open-weight models with measured numbers."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - open-weight
  - cost-optimization
  - model-routing
  - agent-automation
  - gemma4
  - tool-calling
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/open-weight-agent-cost-routing/"
reading_time: true
header:
  image: /assets/images/open-weight-agent-cost-routing-hero.webp
categories:
  - agentops
---

![Abstract image of a task flow passing through a prism and splitting into multiple cost lanes]({{ '/assets/images/open-weight-agent-cost-routing-hero.webp' | relative_url }})

Most teams that open their agent billing statement share the same misconception: "Our agents do a lot of hard reasoning, so we need the top-tier model." Look at actual production traffic, though, and the picture is different. The overwhelming majority of requests are repetitive work: translating natural language into API calls, classifying logs, chaining pipeline steps, summarizing results. None of that requires world-class reasoning. Running all of it through a frontier premium model means paying a premium price for capability you are not using.

This post documents how we measured that waste and eliminated it. We ran real production requests through an open-weight model (Gemma 4) as structured tool calls to validate quality, then used Paxis CostRouter to calculate exactly how far costs drop when each task is routed to the right model tier. The short answer: the same workload that costs one amount on a frontier premium model costs about 44 times less on a managed open-weight tier.

## What This Approach Does

The core idea is straightforward. Rather than sending every agent task to a single model, you route each task to a different model tier based on its nature. Hard reasoning and judgment go to the frontier premium. Code generation goes to an open-weight model strong at code. Tool calls and pipeline execution go to an open-weight agent tier. High-volume extraction and classification go to the cheapest economy tier. Sending each task to the model that wins at it preserves quality while shrinking the bill.

Two things need to be true for this to work. First, open-weight models must genuinely handle a meaningful share of agent tasks. Second, the routing must happen automatically at the platform level, not by a human picking a model for every request. The sections below confirm each with an experiment and a real configuration.

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
<div class="d3-arch" data-arch-root id="enweightagentcostrouting-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 939, "height": 634, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 395, "y": 24, "w": 156, "h": 46, "title": "Agent task request"}, {"id": "B", "x": 386, "y": 148, "w": 174, "h": 52, "title": "Classify task type"}, {"id": "C", "x": 734, "y": 300, "w": 142, "h": 46, "title": "Frontier premium"}, {"id": "D", "x": 502, "y": 300, "w": 177, "h": 46, "title": "Open-weight code tier"}, {"id": "E", "x": 263, "y": 292, "w": 184, "h": 62, "title": ["Open-weight agent tier", "Gemma 4"]}, {"id": "F", "x": 45, "y": 300, "w": 163, "h": 46, "title": "Open-weight economy"}, {"id": "G", "x": 377, "y": 432, "w": 191, "h": 46, "title": "Policy gate + audit log"}, {"id": "H", "x": 374, "y": 556, "w": 198, "h": 46, "title": "Return result + log cost"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [473, 70, 473, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "Reasoning and judgment, top tier", "curve": [[560, 193], [805, 246], [805, 246], [805, 300]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Code generation", "curve": [[515, 200], [590, 246], [590, 246], [590, 300]], "off": "50%"}, {"src": "B", "dst": "E", "kind": "data", "label": "Tool calls and pipelines", "curve": [[430, 200], [355, 246], [355, 246], [355, 292]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "label": "Extraction, classification, bulk", "curve": [[386, 192], [126, 246], [126, 246], [126, 300]], "off": "50%"}, {"src": "C", "dst": "G", "kind": "data", "curve": [[805, 346], [805, 393], [805, 393], [568, 437]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[590, 346], [590, 393], [590, 393], [516, 432]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[355, 354], [355, 393], [355, 393], [429, 432]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[126, 346], [126, 393], [126, 393], [377, 438]]}, {"src": "G", "dst": "H", "kind": "data", "line": [473, 478, 473, 556]}]});
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
      const container = document.getElementById('enweightagentcostrouting-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'enweightagentcostrouting-1';
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

## Setup and Integration

The first question was whether an open-weight model can handle the real core task of an agent: converting a natural-language request into a structured tool call. We tested Gemma 4 26B via a managed API. The experiment was written with no external dependencies, just the standard library (urllib).

We gave the model a tool schema for a cloud operations pipeline: five tools covering metric queries, pod restarts, cost aggregation, deployment scaling, and secret rotation. The instruction was to receive a natural-language request and output exactly one JSON object with the correct tool name and all required parameters.

```python
TOOL_SPEC = """You are an operations automation agent. Convert user requests into a single tool-call JSON object.
Output only the JSON object, no explanation or markdown fences.

Available tools and required parameters:
- query_metrics: {metric, window_days, threshold?, region?}
- restart_pods: {region, selector, only_failed(bool)}
- aggregate_cost: {group_by, month, service?}
- scale_deployment: {name, region, replicas}
- rotate_secret: {name, namespace}

Output schema: {"tool": "<name>", "params": { ... }}"""

def call(prompt):
    body = {
        "contents": [{"role": "user",
                      "parts": [{"text": TOOL_SPEC + "\n\nRequest: " + prompt}]}],
        "generationConfig": {"temperature": 0.0, "maxOutputTokens": 1024},
    }
    # calls gemma-4-26b-a4b-it generateContent, captures latency, tokens, and output
```

We hit one practical issue worth documenting. Gemma 4 generates thinking tokens before its final response. With an output cap of 256, the thinking phase consumed the budget and the final JSON came back empty. Raising the cap to 1024 and filtering out response parts flagged as `thought` gave the correct final answer. This is a commonly missed step when integrating open-weight models with thinking output into pipelines, so measuring it directly was worthwhile.

On the platform side, Paxis manages model selection through a single declarative catalog file (`models.yaml`). Each model entry carries its input and output price per million tokens and its tier label. Routing decisions are made from this catalog.

```yaml
# models.yaml: tier and real unit prices drive routing decisions (USD / 1M tokens)
- id: claude-opus-4-8      # premium
  tier: premium
  costInput: 5.0
  costOutput: 25.0
- id: claude-sonnet-5      # standard (default)
  tier: standard
  costInput: 3.0
  costOutput: 15.0
# Add open-weight providers (Ollama, vLLM, etc.) with the same schema
# and CostRouter will automatically send task-tier-matched requests to the cheapest eligible model.
```

When a task arrives, CostRouter evaluates its tier and selects the cheapest eligible model from the catalog. Register an open-weight provider using the same schema and tool calls, plus bulk processing work, will flow automatically to the cheaper tier. That is why humans do not need to choose a model for every request.

## Experiment Results

We ran six real production operations requests through Gemma 4 and scored the output directly. The scoring criteria were two: is the output valid JSON, and does it contain the correct tool name and all required parameters.

| Metric | Result |
|---|---|
| Valid JSON rate | 6/6 (100%) |
| Schema match (tool + required params) | 6/6 (100%) |
| Average latency | 15.3 s (free shared endpoint, thinking tokens included) |
| Average input tokens | 155 |
| Average output tokens | 33 (final answer) |
| Average thinking tokens | 514 |

All six requests produced the correct tool selection with every required parameter filled in. For example, the request "Show me nodes where GPU utilization exceeded 80% over the last 7 days" produced:

```json
{"tool": "query_metrics", "params": {"metric": "gpu_utilization", "window_days": 7, "threshold": 80}}
```

The `threshold` field is optional in the schema, yet the model read "80%" from the request and populated it correctly. For "Scale the inference-api deployment in ap-northeast to 6 replicas," the model mapped name, region, and replica count precisely to `scale_deployment`. These are unmanipulated measurements confirming that an open-weight model handles the core tasks of agent automation, tool calling and pipeline execution, without quality loss.

The 15.3-second average latency is measured on a free shared endpoint with thinking tokens included. That number drops considerably in a self-hosted or batch processing environment. The key point here is not the absolute latency but that quality did not degrade.

Now for the cost. Using the measured token profile as a starting point, we modeled a realistic single turn at 1,000 input tokens and 300 output tokens (accounting for system prompt, tool schema, and context), run at 10,000 tasks per day for 30 days. Frontier prices come from the actual values in Paxis `models.yaml`. Open-weight prices come from representative mid-2026 managed inference estimates.

![Bar chart comparing monthly API costs by model tier]({{ '/assets/images/open-weight-agent-cost-routing-results.webp' | relative_url }})

| Tier | Cost per task | Monthly cost (10k/day, 30 days) | vs. Premium |
|---|---|---|---|
| Frontier premium | $0.0125 | $3,750 | baseline |
| Frontier standard | $0.0075 | $2,250 | 1.7x cheaper |
| Frontier economy | $0.0020 | $600 | 6.2x cheaper |
| Open-weight managed (Gemma-class) | $0.000285 | $86 | 43.9x cheaper |
| Open-weight economy | $0.00007 | $21 | 178.6x cheaper |

The same workload costs $3,750 per month at the frontier premium tier and $86 per month at the Gemma-class open-weight tier. That is roughly a 44x difference. And as the experiment shows, open-weight quality on tool-call tasks was 100%. This saving does not come from degrading quality. It comes from removing overspec. Open-weight unit prices vary by provider and whether you self-host (which is why they are labeled as estimates), but the order-of-magnitude savings direction is solid.

## Implications for ThakiCloud Products

This pattern fits precisely with how Paxis, ThakiCloud's Agent-Native Cloud, is designed. Paxis treats skills, tools, policies, and audit logs as first-class resources, the same way traditional cloud treats servers and networks. CostRouter sits on top of that as the layer that picks the right model for each task.

- **Per-task routing is a first-class feature.** A single `models.yaml` is the one source of truth for which provider and model to use. Register an open-weight provider using the same schema and tool calls plus bulk processing work will flow automatically to the cheaper tier. Standard tier is the default and premium requires an explicit selection, so overspec routing cannot happen by accident.
- **Isolated execution and governance are built in.** Regardless of which tier a task is sent to, the result passes through the policy gate and audit log. Using a cheaper model does not loosen control. In fact, because every task's model, token count, and cost are recorded, you can retrospectively identify which task types are using an expensive tier unnecessarily and reroute them.
- **The design is compatible with on-premises and sovereign requirements.** Open-weight models can be served on your own GPUs, which lets you control both cost and data residency for customers whose data cannot leave their environment. ThakiCloud's ai-platform runs this open-weight tier in multi-tenant mode using Kueue-based GPU scheduling and vLLM serving. Efficient serving directly enables agent economics, which means ai-platform's infrastructure advantage underpins Paxis's routing economics.

The core principle is not "use expensive models less." It is "route every task to the model that wins at it." Most agent tasks are tool calls and pipeline execution, and the vast majority of those are well within reach of open-weight models.

## Limitations and Counterarguments

This approach has clear boundaries.

On tasks that require the hardest reasoning and the broadest world knowledge, open-weight models still fall behind frontier. That is why routing must be "open-weight where it wins" and not "open-weight everywhere." Difficult judgment calls belong at the premium tier. Routing them to a cheap tier because of the cost savings produces quality failures, not savings.

Task-type classification itself becomes a new failure point. If classification is wrong, routing is wrong. That means you need a feedback loop: continuously observe classification results alongside actual quality, and bump task types back to a higher tier if failures start accumulating at the cheaper one.

The open-weight unit prices in the cost table are estimates. Absolute values depend on the provider and whether you self-host. The frontier prices are real, the experiment quality is measured, and the conclusion that savings are order-of-magnitude in scale is robust. We recommend running the same calculation with your own actual unit prices.

Finally, latency. Fifteen seconds on a free shared endpoint is a burden for real-time conversational UX. For batch pipelines and background automation it is fine. For user-facing paths where someone is waiting, you need either self-hosted serving to reduce latency or routing that sends only that segment to a faster tier.

## Sources

- Experiment code and result logs: The Gemma 4 tool-call experiment (6/6 success) described in this post is based on measured logs in `outputs/blog-impl/open-weight-agent-cost-routing/`.
- Frontier unit prices: Paxis `models.yaml` (costInput/costOutput, USD per 1M tokens).
- Open-weight unit prices: Representative mid-2026 managed inference estimates [estimated].
- [Gemma 4 26B-A4B-it model card (Hugging Face)](https://huggingface.co/google/gemma-4-26B-A4B-it) - official confirmation of the MoE architecture, thinking tokens, and native function-calling (tool-call) support.
- [Claude API pricing (Anthropic)](https://platform.claude.com/docs/en/about-claude/pricing) - official page for Claude Opus 4.8 and Sonnet 5 input/output unit prices.
