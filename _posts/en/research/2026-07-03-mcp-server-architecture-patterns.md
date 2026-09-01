---
title: "MCP Server Architecture Patterns: Why More Tools Make LLMs Wobble"
excerpt: "A new paper analyzing 15 production MCP servers catalogs five architecture patterns and four anti-patterns. The key finding: past a certain tool count, a model's tool-selection accuracy collapses."
seo_title: "MCP Server Architecture Patterns Tool Overload LLM - Thaki Cloud"
seo_description: "Analysis of arXiv 2606.30317. The five MCP server architecture patterns, how tool count affects LLM tool-selection accuracy, and Paxis Skill Harness BM25 selection."
date: 2026-07-03
last_modified_at: 2026-07-03
tags:
  - MCP
  - Model-Context-Protocol
  - LLM-Agents
  - Architecture-Patterns
  - Tool-Selection
  - Agent-Native-Cloud
  - paxis
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/research/mcp-server-architecture-patterns/"
reading_time: true
header:
  image: /assets/images/mcp-server-architecture-patterns-hero.webp
  teaser: /assets/images/mcp-server-architecture-patterns-hero.webp
categories:
  - research
---

## Overview

The Model Context Protocol (MCP) is a standard interface Anthropic released in November 2024. It provides a common way to connect large language models to external tools, data sources, and services. Within months, hundreds of community-built MCP servers appeared on GitHub. Yet no software-maintenance literature had described how those servers were actually being structured in production.

The paper [MCP Server Architecture Patterns for LLM-Integrated Applications](https://arxiv.org/abs/2606.30317) by Carson Rodrigues et al., posted to arXiv on June 29, 2026, fills that gap. Using a corpus of 15 independently developed MCP servers, it catalogs five recurring architecture patterns and four anti-patterns, along with cross-cutting concerns around authentication, versioning, and observability.

For anyone running agent infrastructure, one part stands out. The paper actually measured how many tools you can attach, and the answer is much lower than most teams assume. Because this maps directly onto how ThakiCloud handles more than 960 skills in Paxis, our Agent-Native Cloud, this post walks through the measured results alongside our own design choices.

## What the Study Is

The approach is empirical. Instead of prescribing what servers should look like, the authors dissected 15 running servers and inductively extracted their shared structure. The five resulting patterns split along two axes: what the server exposes to the LLM, and how it handles state.

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
<div class="d3-arch" data-arch-root id="rverarchitecturepatterns-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1217, "height": 644, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "LLM", "x": 538, "y": 24, "w": 120, "h": 46, "title": "LLM agent"}, {"id": "Client", "x": 538, "y": 148, "w": 120, "h": 46, "title": "MCP client"}, {"id": "Server", "x": 538, "y": 272, "w": 120, "h": 46, "title": "MCP server"}, {"id": "P1", "x": 1015, "y": 396, "w": 170, "h": 62, "title": ["Resource Gateway", "exposes data sources"]}, {"id": "P2", "x": 748, "y": 396, "w": 212, "h": 62, "title": ["Tool Orchestrator", "coordinates tool execution"]}, {"id": "P3", "x": 502, "y": 396, "w": 191, "h": 62, "title": ["Stateful Session Server", "holds session state"]}, {"id": "P4", "x": 270, "y": 396, "w": 177, "h": 62, "title": ["Proxy Aggregator", "unifies many backends"]}, {"id": "P5", "x": 24, "y": 396, "w": 191, "h": 62, "title": ["Domain-Specific Adapter", "domain-aware wrapping"]}, {"id": "X", "x": 773, "y": 550, "w": 163, "h": 62, "title": ["auth · versioning ·", "observability"]}], "edges": [{"src": "LLM", "dst": "Client", "kind": "data", "line": [598, 70, 598, 148]}, {"src": "Client", "dst": "Server", "kind": "data", "line": [598, 194, 598, 272]}, {"src": "Server", "dst": "P1", "kind": "data", "curve": [[658, 302], [1100, 357], [1100, 357], [1100, 396]]}, {"src": "Server", "dst": "P2", "kind": "data", "curve": [[658, 310], [854, 357], [854, 357], [854, 396]]}, {"src": "Server", "dst": "P3", "kind": "data", "line": [598, 318, 598, 396]}, {"src": "Server", "dst": "P4", "kind": "data", "curve": [[538, 311], [359, 357], [359, 357], [359, 396]]}, {"src": "Server", "dst": "P5", "kind": "data", "curve": [[538, 303], [120, 357], [120, 357], [120, 396]]}, {"src": "P1", "dst": "X", "kind": "event", "label": "cross-cutting", "curve": [[1100, 458], [1100, 504], [1100, 504], [936, 555]], "off": "50%"}, {"src": "P2", "dst": "X", "kind": "event", "label": "cross-cutting", "line": [854, 458, 854, 550], "lx": 854, "ly": 500}, {"src": "P3", "dst": "X", "kind": "event", "label": "cross-cutting", "curve": [[598, 458], [598, 504], [598, 504], [773, 557]], "off": "50%"}]});
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
      const container = document.getElementById('rverarchitecturepatterns-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rverarchitecturepatterns-1';
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

The value of this taxonomy is that it forces you to decide "what kind of server is this" before you build. Cram a Tool Orchestrator's complex execution logic into a Resource Gateway and you combine the downsides of both. Choosing a pattern explicitly is itself a design discipline.

## The Five Architecture Patterns

**Resource Gateway** exposes data sources such as databases, file systems, or APIs in a read-centric way. The tools themselves are simple; the real question is which resources you open, and under what permissions.

**Tool Orchestrator** bundles several tools and coordinates an execution flow. A single call often runs multiple internal steps, so failure handling and partial rollback are the core difficulty.

**Stateful Session Server** maintains state across a conversation or work session. LLM calls are essentially stateless, so the server holds the state on the model's behalf and must define session lifetime and cleanup clearly.

**Proxy Aggregator** merges several backends or other MCP servers behind a single surface. Convenient, but as the tools behind it multiply, it soon leads to the tool-overload problem discussed below.

**Domain-Specific Adapter** wraps concepts of a specific domain (finance, healthcare, internal systems) into a shape the LLM handles well. It bakes domain terms and constraints into the tool schema so the model does not attempt nonsensical combinations.

## Tool Overload: Why More Tools Make Models Wobble

The most operationally important part of the paper measures the relationship between tool count and tool-selection accuracy. The result is clear: once the number of tools in context passes a threshold, the model's accuracy at picking the right tool drops below 90%.

Specifically, the paper reports that for Claude Haiku 4.5 accuracy falls below 90% somewhere between 10 and 15 tools, and for Sonnet 4 between 20 and 30 tools. Larger models tolerate more tools, but there is no point at which "attach as many as you like" holds. As tools multiply and descriptions grow vague, the model gets confused.

This measurement overturns a common instinct. Teams adding MCP for the first time often start by "exposing every API we have as a tool." Merge several backends with a Proxy Aggregator and the tool count reaches dozens fast, dropping you off the accuracy cliff. Tool count is not free; it spends the model's judgment budget.

## Anti-Patterns and Cross-Cutting Concerns

The paper also catalogs four anti-patterns. The exact names are not confirmed at the abstract level, but the direction connects to the measurement above. Growing tools indiscriminately, leaving tool descriptions vague so the model has to infer intent, letting sessions drift without state management, and handling authentication and versioning inconsistently per server are the typical failure modes.

For cross-cutting concerns, it emphasizes authentication, versioning, and observability. All three are needed regardless of which pattern you choose. Observability in particular often gets pushed to the back in agent systems, yet when a tool call fails and you cannot trace why, debugging becomes practically impossible.

## Implications for ThakiCloud Products

The paper's tool-overload conclusion overlaps precisely with why ThakiCloud built **Paxis**. Paxis is an Agent-Native Cloud control plane running on top of ai-platform, treating Skills, Tools, Policies, and Audit Logs as first-class resources. The key piece is the **Skill Harness**.

Paxis holds more than 960 skills, but it never dumps all of them into the model's context as tools. Instead, for each user request it selects only a small set of relevant skills via BM25 search and exposes those. Mapped onto the paper's measurement, this is a design that sidesteps the accuracy cliff. The model always faces a manageable handful of tools, while the remaining hundreds of capabilities are pulled in on demand. "Many capabilities, few exposed" is our answer to the tool-overload problem.

We manage the Proxy Aggregator risk through the same lens. Paxis MCP connectors link many external services, but rather than exposing every connected tool, a policy gate filters them so only what is actually needed reaches the isolated sandbox execution path. Every tool call leaves an audit log, satisfying the observability requirement. The authentication, versioning, and observability the paper flags as cross-cutting concerns are wired in by default in Paxis, not optional.

The infrastructure layer, **ai-platform**, is worth noting too. As MCP servers multiply, each one eventually runs as a process somewhere. ai-platform serves these servers reliably on K8s and Kueue-based GPU scheduling with multi-tenant isolation, extending to on-prem and sovereign environments. For state-holding servers like a Stateful Session Server, placement and lifecycle management matter, and K8s operational maturity becomes a direct advantage.

## Limitations and Counterpoints

The paper rests on a relatively small corpus of 15 servers. The MCP ecosystem is growing so fast that whether these five patterns remain representative is something to watch. New patterns may emerge, or today's anti-patterns may be eased by better tooling.

The tool-selection accuracy measurement also depends on model and prompt design. Well-written tool descriptions and clear naming raise accuracy at the same tool count. In other words, there is no absolute line of "N tools is safe"; tool count is one variable among several. Even so, the direction is unambiguous. Tools are not free, and the discipline of exposing only what is needed is the foundation of agent reliability.

## Sources

- Carson Rodrigues et al., [MCP Server Architecture Patterns for LLM-Integrated Applications](https://arxiv.org/abs/2606.30317), arXiv:2606.30317 (2026-06-29)
- [Model Context Protocol official introduction](https://modelcontextprotocol.io/)
