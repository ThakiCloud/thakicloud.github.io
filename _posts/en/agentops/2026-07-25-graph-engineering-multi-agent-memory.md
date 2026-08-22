---
title: "How to Make Agent Memory Persistent: The Five Steps of Graph Engineering"
excerpt: "Agent memory dies with the context window. Treating a knowledge graph as shared memory keeps it alive. We break down the five steps shared by the community, Extract, Resolve, Assemble, Query, and Repeat, and look at how they fit into multi-agent systems."
seo_title: "Graph Engineering: Designing Persistent Memory for Multi-Agent Systems - Thaki Cloud"
seo_description: "An engineering breakdown of graph engineering's five steps (Extract, Resolve, Assemble, Query, Repeat) for solving the problem of agent memory disappearing with the context window, using a shared knowledge graph. Covers Haiku/Sonnet model routing, provenance, and application to ThakiCloud Paxis."
date: 2026-07-25
last_modified_at: 2026-07-25
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "diagram-project"
tags:
  - agentops
  - knowledge-graph
  - multi-agent
  - agent-memory
  - graph-engineering
  - rag
  - ai-application
  - thakicloud
categories:
  - agentops
header:
  teaser: /assets/images/graph-engineering-multi-agent-memory-hero.webp
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/graph-engineering-multi-agent-memory/"
published: false
---

![Abstract illustration of language fragments condensing into a permanent network of nodes and edges]({{ '/assets/images/graph-engineering-multi-agent-memory-hero.webp' | relative_url }})

## Why This Matters

If you build multi-agent systems or long-running agent products, this piece might make you set aside the question of whether you need a bigger model. The core conclusion up front: agent memory dies with the context window, and only a knowledge graph used as shared memory keeps it alive. A recently shared write-up laid out graph engineering for multi-agent systems. Its backbone is five steps, Extract, Resolve, Assemble, Query, and Repeat. This post breaks down why that backbone matters now and how to wire it into a real system.

## Overview

Anyone who has run agents for a while hits the same wall. What a worker learned yesterday, today's worker does not know. As a conversation grows longer, earlier turns fall out of the context window, and the moment they do, the agent forgets what it knew a second ago. Memory evaporates on a per session basis.

The usual fix is vector RAG: embed documents and pull back similar chunks. That solves "find something similar," but it stays fuzzy on "who did what, and what does it connect to." If the same person shows up under different names across documents, vectors will not merge them into one. Reasoning two or three hops across relationships is not reliable with embedding similarity alone either.

Graph engineering answers this differently. Instead of storing information as a blob, it records the relationships between entities as an explicit graph. Agent memory then becomes a queryable structure rather than a pile of sentences.

## What This Technique Is

The core idea is simple. Pull out what the agent has read and observed as subject predicate object (S-P-O) triples, accumulate them in a knowledge graph, and query a slice of that graph whenever needed. Nodes are entities, edges are typed relationships, and every triple carries provenance pointing back to where it came from.

If the context window is "what's visible right now," the knowledge graph is "what has been confirmed so far." The former disappears when the session ends, the latter stays. That separation is more or less the whole idea behind graph engineering.

Below is the cycle the five steps form.

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
<div class="d3-arch" data-arch-root id="ineeringmultiagentmemory-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 395, "height": 1036, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Doc", "x": 116, "y": 24, "w": 170, "h": 62, "title": ["New document / agent", "observation"]}, {"id": "Extract", "x": 102, "y": 164, "w": 198, "h": 78, "title": ["1. Extract", "Haiku pulls entities and", "S-P-O triples"]}, {"id": "Resolve", "x": 175, "y": 320, "w": 184, "h": 78, "title": ["2. Resolve", "Sonnet merges matching", "entities"]}, {"id": "Assemble", "x": 172, "y": 490, "w": 191, "h": 78, "title": ["3. Assemble", "Canonical nodes + typed", "edges + provenance"]}, {"id": "Graph", "x": 133, "y": 646, "w": 135, "h": 62, "title": ["Knowledge graph", "shared memory"]}, {"id": "Query", "x": 98, "y": 786, "w": 205, "h": 78, "title": ["4. Query", "Sonnet reasons over a cut", "subgraph"]}, {"id": "Answer", "x": 109, "y": 942, "w": 184, "h": 62, "title": ["Answer citing specific", "edges"]}], "edges": [{"src": "Doc", "dst": "Extract", "kind": "data", "line": [201, 86, 201, 164]}, {"src": "Extract", "dst": "Resolve", "kind": "data", "curve": [[234, 242], [267, 281], [267, 281], [267, 320]]}, {"src": "Resolve", "dst": "Assemble", "kind": "data", "line": [267, 398, 267, 490]}, {"src": "Assemble", "dst": "Graph", "kind": "data", "curve": [[267, 568], [267, 607], [267, 607], [230, 646]]}, {"src": "Graph", "dst": "Query", "kind": "data", "line": [201, 708, 201, 786]}, {"src": "Query", "dst": "Answer", "kind": "data", "line": [201, 864, 201, 942]}, {"src": "Graph", "dst": "Extract", "kind": "event", "label": "5. Repeat: keep updating with new information", "curve": [[171, 646], [134, 529], [134, 359], [167, 242]], "off": "50%"}]});
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
      const container = document.getElementById('ineeringmultiagentmemory-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ineeringmultiagentmemory-1';
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

## The Five Steps in Detail

**1. Extract.** When a document comes in, a cheap model (Haiku) pulls out entities and S-P-O triples. One call per document is enough. What's interesting here is that no separate training data is needed. A single Pydantic schema defines what gets extracted and in what shape. The schema itself is the only training signal. Because code owns the output format and the model only fills in content, the results stay consistent.

**2. Resolve.** Entities that point to the same real world thing get merged into one. A slightly smarter model (Sonnet) handles this step. "Edwin Aldrin" and "Buzz Aldrin," for instance, share no overlapping characters yet refer to the same person. String matching would never catch it. The model judges "these two are the same" using the description attached to each entity as context. The quality of entity resolution determines how trustworthy the whole graph is.

**3. Assemble.** Merged entities become canonical nodes, connected by typed edges, with provenance stamped into every triple, assembled into one connected graph. Carrying provenance matters: being able to trace which document a fact came from later on is what lets you track down and remove wrong information.

**4. Query.** When a question comes in, the relevant subgraph is serialized and handed to a model (Sonnet), which reasons over the triples. Every answer cites a specific edge. Because the reasoning behind an answer is traceable to a specific relationship in the graph, the answer becomes verifiable.

**5. Repeat.** When a new document or new observation arrives, the cycle returns to step one. The graph is not a one time artifact, it is a living memory that keeps updating.

Worth noting: model routing differs by step. Bulk extraction goes to cheap Haiku, while the judgment calls in entity resolution and query reasoning go to Sonnet. The expensive model is not smeared across every step, only used where judgment is actually required. That is exactly the principle we follow in our own internal batch jobs: keep workers cheap, spend only on the gate.

## How It Fits Into Multi-Agent Systems

The real value of a knowledge graph shows up when multiple agents share the same memory. Worker agents write what they learn into the graph. An evaluator agent checks a worker's claims against the graph. And an overnight loop picks up yesterday's progress today, through that same graph.

This lines up with something we've learned from running several automation loops ourselves. Results from fanned out subagents have to close through a verification stage, but without a shared fact store to anchor that verification, each agent starts from scratch. The graph serves as that anchor. Workers write to it, evaluators check against it, and the next loop inherits it, naturally.

## Implications for ThakiCloud Products

This technique fits particularly well with our **Paxis** platform. Paxis is an Agent-Native Cloud control plane running on top of ai-platform, treating Skills, Tools, Policies, and Audit Logs as first class resources. The five steps of graph engineering map directly onto several of its axes.

Start with the knowledge axis. Paxis's wiki knowledge engine already treats documents and entities as connected knowledge; layering S-P-O triples and entity resolution on top turns it into shared memory agents can query. Next, the orchestration axis. When a DAG multi-agent system fans out, having each worker write to the graph and the evaluator check against it closes the verification loop with data, not just prose. Finally, the audit axis. Stamping provenance into every triple runs in exactly the same direction as Paxis's policy gates and audit log philosophy. Being able to trace which evidence an answer came from is a competitive advantage in itself in environments with heavy regulatory or on premise requirements.

From an infrastructure angle, our **ai-platform** lens applies too. Extraction calls a cheap model at scale, while querying selectively calls a larger one, a structure well suited to splitting serving by model tier and running it on K8s. Scheduling batch extraction jobs with Kueue and serving small models cheaply with vLLM keeps the cost of continuously updating the graph under control. Cheap serving, through ai-platform, lowers the cost of keeping the graph alive, and that in turn is what makes the economics of agents, through Paxis, work.

## Limitations and Counterarguments

Graph engineering is not a cure all. The most painful failure mode is a wrong entity resolution. Merge two distinct entities into one by mistake, and that error spreads across the entire graph, contaminating every query that follows. Split the same entity apart instead, and memory fragments. As long as model judgment sits in this step, full automation is difficult, and periodic auditing is needed.

Hallucination at the extraction step is also a problem. If the model invents a triple that is not in the document, provenance being attached does not by itself confirm the relationship actually exists in that source. The schema enforces format, not the truth of the content.

At scale, the graph grows heavy and query latency rises. Cutting out the relevant subgraph becomes a search problem in its own right, and if the cut piece is too large, you are back at the context window limit. And if the task never needed relational reasoning to begin with, plain vector RAG is cheaper and faster than a heavy graph. The order of operations matters: first decide whether the problem is "find something similar" or "follow a relationship," before reaching for a graph.

## Summary

Giving an agent persistent memory is not solved by buying a bigger model. You have to change the structure where memory dies with the context window, and treating a knowledge graph as shared memory is the most practical answer available so far. Extract to pull facts out, Resolve to merge them, Assemble to build the graph, Query to answer with grounded evidence, and Repeat to keep it updated, those five steps are the method.

You do not need to start big. Define a small Pydantic schema around the handful of entities and relationships that matter most in your domain, and run extraction on a single document with a cheap model. The graph grows from there. The next time an agent says "I knew that yesterday but forgot it," remember that the answer is not a bigger model. It's a better memory structure.

## Sources

- [Codez (@0xCodez), "Graph Engineering for multi-agentic systems" (X)](https://x.com/0xCodez/status/2080250266851463209)
- [Anthropic Engineering, "How we built our multi-agent research system"](https://www.anthropic.com/engineering/multi-agent-research-system)

A note on sourcing. What we verified directly is the X post linked above; we could not confirm the author or length of the document behind it. Another write-up on the same material credits a different author, so we do not assert an unverified attribution in the body.
