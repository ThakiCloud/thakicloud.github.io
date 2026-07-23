---
title: "Routing 1,600 Skills Without Noise - Operating an AI Agent Skill Ecosystem"
excerpt: "Routing design principles learned from running 1,620 skills solo on Claude Code. Honestly sharing SRA (Skill Retrieval Augmentation) + BM25 gate design, description quality discipline, and real benchmark results."
seo_title: "AI Agent 1600 Skill Routing Design - Skill Retrieval Augmentation - Thaki Cloud"
seo_description: "More skills does not mean a better agent. We share the routing design and real benchmarks from eliminating noise in a 1,620-skill ecosystem using an SRA + BM25 two-stage gate on Claude Code."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: en
tags:
  - skill-routing
  - ai-agents
  - retrieval-augmentation
  - claude-code
  - bm25
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/skill-ecosystem-routing-sra/"
reading_time: true
categories:
  - dev
published: false
---

![Skill Ecosystem Routing SRA Hero Image]({{ '/assets/images/skill-ecosystem-routing-sra-hero.webp' | relative_url }})

## Overview: The Problem Created by Skill Proliferation

When you operate an AI agent system for a long time, skills naturally accumulate. First dozens, then hundreds, and one day you open the catalog to find 1,620 entries. That is the current state of ThakiCloud's Claude Code-based agent infrastructure. Approximately 1,620 local skills, 55 subagents, 36 always-on rules, 22 slash commands, and 12 hooks are running together.

The first intuition you encounter here is "the more skills, the stronger the agent." That is wrong. As skills multiply, the agent actually slows down, picks up the wrong skill, or starts answering raw without using any skill at all. The problem was not the number of skills -- it was routing.

This article documents the routing design principles learned from operating a skill ecosystem of over 1,600 skills solo. It covers how Skill Retrieval Augmentation (SRA, arXiv:2604.24594) was applied to a real operating environment, what the BM25 gate does, why description quality determines search accuracy, and honestly, what is still lacking.

## Why More Skills Slows You Down: The Noise Tax

Claude Code's context window is finite. Putting the entire skill list into context every turn reduces the tokens available for actual work. This is the "noise tax." Just listing the names and short descriptions of 1,620 skills amounts to tens of thousands of tokens. Injecting this every turn causes costs to explode and the model to get lost among irrelevant skill names.

The more serious problem is "forced matching." This is the phenomenon where the model picks up the wrong skill because its name partially overlaps with something in the skill list. For example, loading the `4phase-debugging` skill for a simple "fix this bug" request and running a complex workflow, or pulling out the `technical-writer` skill for a simple file edit. As skills multiply, this noise probability increases.

The SRA paper (arXiv:2604.24594) defines this problem as "distractor noise being the primary accuracy risk in environments with 1,000+ skills." The solution direction is clear: instead of showing the agent all skills, filter to only the small number of candidates genuinely relevant to the current request.

## SRA + BM25 Two-Stage Gate

The structure ThakiCloud adopted combines the SRA paper's three-stage protocol with a BM25-based automatic gate.

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
<div class="d3-arch" data-arch-root id="skillecosystemroutingsra-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 873, "height": 1018, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 279, "y": 24, "w": 170, "h": 46, "title": "User request arrives"}, {"id": "B", "x": 267, "y": 148, "w": 195, "h": 84, "title": ["Pre-filter", "Greeting/Command/Same", "turn?"]}, {"id": "C", "x": 390, "y": 332, "w": 184, "h": 46, "title": "Zero-token passthrough"}, {"id": "D", "x": 158, "y": 324, "w": 177, "h": 62, "title": ["BM25 automatic search", "retrieve.py"]}, {"id": "E", "x": 152, "y": 464, "w": 188, "h": 68, "title": ["Any candidates", "above SCORE_MIN 6.0?"]}, {"id": "F", "x": 272, "y": 624, "w": 184, "h": 62, "title": ["No candidates = Native", "execution"]}, {"id": "G", "x": 40, "y": 624, "w": 177, "h": 62, "title": ["TOP_K 5 candidates", "injected into context"]}, {"id": "H", "x": 24, "y": 764, "w": 209, "h": 68, "title": ["Model Triage", "Native vs Skill-worthy?"]}, {"id": "I", "x": 40, "y": 924, "w": 177, "h": 62, "title": ["Execute directly with", "built-in tools"]}, {"id": "J", "x": 646, "y": 151, "w": 177, "h": 78, "title": ["Incorporation", "Select optimal single", "skill"]}, {"id": "worthy", "x": 675, "y": 24, "w": 120, "h": 46, "title": "worthy"}, {"id": "K", "x": 629, "y": 324, "w": 212, "h": 62, "title": ["Load and execute via Skill", "tool"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [364, 70, 364, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "SKIP", "curve": [[420, 232], [482, 278], [482, 278], [482, 332]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "PROCEED", "curve": [[308, 232], [246, 278], [246, 278], [246, 324]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "line": [246, 386, 246, 464]}, {"src": "E", "dst": "F", "kind": "data", "label": "None", "curve": [[296, 532], [364, 578], [364, 578], [364, 624]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "Found", "curve": [[196, 532], [129, 578], [129, 578], [129, 624]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "line": [129, 686, 129, 764]}, {"src": "H", "dst": "I", "kind": "data", "label": "Native", "line": [129, 832, 129, 924], "lx": 129, "ly": 874}, {"src": "worthy", "dst": "J", "kind": "data", "line": [735, 70, 735, 151]}, {"src": "J", "dst": "K", "kind": "data", "line": [735, 229, 735, 324]}]});
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
      const container = document.getElementById('skillecosystemroutingsra-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'skillecosystemroutingsra-1';
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

### Stage 1: Retrieval - BM25 Automatic Search

The `skill-router-gate.py` hook is wired to the `UserPromptSubmit` event. The moment a user submits a prompt, this hook runs first.

The first step of the hook is the pre-filter. Greetings ("Hello"), simple confirmations ("Got it"), and pure commands (direct file path edits) pass through immediately without BM25 search. If an explicit skill trigger keyword is already present (`/review`, `/debug`, etc.), it is force-routed to that skill.

The second step is BM25 search. `retrieve.py` indexes SKILL.md frontmatter, agent definitions, and the skill catalog with BM25, then calculates relevance against the current query. Leveraging IDF weighting and a Korean-English cross-language synonym dictionary (25+ vocabulary pairs), it narrows down 1,200+ skills in real time. Only candidates scoring SCORE_MIN (6.0) or above -- up to TOP_K (5) -- are filtered and injected into context. If the request is identical to the previous turn, re-injection is skipped. All routing results are logged to `state/skill-router.jsonl`.

### Stage 2: Triage - Native vs Skill-worthy

The model looks at the injected candidate list and judges the nature of the current task.

- Native tasks: file editing, git commands, simple Q&A, single-line code changes, grep. Tasks where built-in tools are sufficient. Executed directly without loading a skill.
- Skill-worthy tasks: structured writing, multi-domain code review, pipeline orchestration, domain-specific analysis, document generation. Tasks that benefit from a skill with a checklist or workflow.

When the judgment is ambiguous, Native is the default. The criterion is whether structured workflow overhead is worth incurring.

### Stage 3: Incorporation - Selecting the Single Optimal Skill

Once classified as skill-worthy, one candidate from the BM25 list is selected, the reason is stated in a single sentence, and it is loaded via the Skill tool. If two or more candidates are neck and neck, the user is asked. If there are no candidates, it falls back to Native. Forced matching is not done.

A separate agent pool is also managed. The 55 subagents are searched in an index separate from the general skill pool, so user-facing skills and orchestration agents route without confusion.

## Description Quality Discipline

BM25 accuracy ultimately depends on the description quality of each skill. BM25 reads text. If descriptions are vague, similar skills receive similar scores for the same query and wrong candidates surface.

The description format ThakiCloud enforces has three components.

```yaml
description: >-
  [What the skill does - one sentence, third person].
  Use when [English + Korean trigger keywords].
  Do NOT use for [cases that are not this skill] (use [adjacent skill name]).
```

The first sentence is the capability. It defines "what it does" with a single verb. The second sentence is the utterance trigger. It must include both English and Korean. Korean requests match Korean triggers; English requests match English triggers. Having only one side misses half the queries. The third sentence is the boundary. It specifies "patterns that should not come to this skill" and "the adjacent skill to use instead." This is the core of disambiguation.

Descriptions must be within 1,024 characters. This is the upper limit accounting for BM25 indexing efficiency and context injection cost.

An additional discipline introduced on 2026-06-22 is Skill IR (Intent-Trigger schema). Before creating a complex new skill, six fields are filled in first: intent (what single problem it solves), triggers (English + Korean utterance keywords), inputs (what it receives), outputs (what it produces), boundaries (what it does not do + adjacent skills), and references (dependent scripts/rules). Fixing this IR first filters out trigger conflicts and duplicate skills at the description-writing stage. It is not applied to simple skills.

There is one lesson extracted from failure. "If the skill name sounds plausible, surely it will be found even if the description is rough" is a misconception. BM25 reads the full description, not the name. Even if the name is great, if there are no triggers in the description, it will not appear in search results.

## Measurement: What Improved

The benchmark methodology is stated upfront. The figures below are results from a gold-set benchmark of 63 cases. They are not values measured every turn in the actual operating environment. They measure the potential accuracy of the engine; operating accuracy may differ.

Before/after router repair comparison (sra-bench, 63 cases):

| Metric | Before repair | After repair |
|--------|--------------|-------------|
| Recall@5 | 44.0% | 73.3% |
| Gated (gate pass rate) | - | 53.3% |
| Top-1 accuracy | - | 31.1% |
| Hallucination (wrong skill loaded) | 10.0% | 0.0% |

Before repair, Recall@5 of 44% means the relevant skill was in the top-5 candidates less than half the time. In this state, even if the model selected perfectly, the correct answer was absent half the time. After repair it rose to 73.3%, and hallucination (loading a nonexistent or completely unrelated skill) dropped to 0%.

The three main causes of improvement were: first, skills lacking Korean triggers in their descriptions were updated in bulk. Second, cases where adjacent skill descriptions overlapped and caused score collisions were separated with Do-NOT-use clauses. Third, the BM25 SCORE_MIN threshold was tuned so that low-scoring noise candidates do not enter context.

Top-1 accuracy of 31.1% is still low. The gap between 73% (correct answer in top 5) and 31.1% represents "the model's ability to select the optimal one from candidates." This is an area that can continue to improve through description refinement, but the current ceiling is [estimate] around 50%.

A separate experiment was also conducted on composite requests (e.g., "research this, fact-check it, make a docx, and post it to Slack"). For 12 cases, the step_coverage of the single-query retrieve (SINGLE) strategy was 32.8%. Bundling multiple steps into a single query causes the skills for later steps to be missed. This problem is not fully resolved yet; composite requests are partially addressed by having the agent decompose into sub-tasks and retrieve each separately.

## Productization into Paxis

This routing structure is generalized on the same principles in ThakiCloud's SaaS product Paxis. Paxis's skill router has a two-stage structure. Stage 1 narrows domain candidates from a large skill pool. Stage 2 evaluates seven factors (intent match, trigger coverage, boundary violation, input sufficiency, output fit, reference dependencies, context cost) to select the optimal skill.

The key difference is diversification of scale. In Claude Code local operation, a single agent sees 1,600 skills, but in Paxis the skill pool is separated per tenant and the router readjusts to each tenant's context. The BM25 + gate + description discipline validated in solo operation applies directly to the multi-tenant product.

The part that changes most significantly during productization is responsibility for description writing. In local operation, the operator writes descriptions directly and validates with benchmarks. In Paxis, a gate is needed to automatically check description quality when customers register skills. Without this gate, skills registered by customers conflict and routing accuracy degrades. This gate is currently under development.

## Limitations and Lessons

An honest summary.

**BM25's limitations**: BM25 is lexical-match-based search. "Review my code" and "give me PR feedback" are semantically equivalent but lexically different. A synonym dictionary partially compensates, but there are limits. A hybrid approach combining semantic search (embedding-based) with BM25 is theoretically more accurate. However, embedding computation cost and index management complexity have prevented adoption so far.

**Gold-set bench vs. operating reality**: The figures cited in the measurement section are results for 63 pre-prepared cases. In actual use, unexpected phrasing, composite requests, and domain boundary cases are mixed in. Benchmark figures may differ from operating experience.

**Skill maintenance cost**: Updating 1,620 skills individually is not feasible. When descriptions become outdated, triggers misalign and accuracy drops. Currently some skills are updated through a nightly automation loop, but there is no systematic method to guarantee freshness across all skills.

**Composite request decomposition**: As mentioned earlier, composite requests spanning multiple steps are currently weak in routing. Having the agent decompose sub-tasks and retrieve each stage yields step_coverage of 42.5% under oracle conditions, higher than single retrieve (32.8%), but this ceiling is also low. Composite request routing is an area requiring further research alongside description quality improvement.

**"More skills is not better"**: This sentence is the core of this article. Skills are a tax. They raise context cost, maintenance cost, and routing noise. Before adding a skill, you must first ask "would the agent be wrong without this skill?" If the answer is "no," the skill should not be created.

1,620 is a large number. But the skills that are actively used daily are far fewer. The rest are latent assets that can only be retrieved when needed -- if routing works. Without routing, they become noise.

SRA + BM25 gate + description quality discipline is the infrastructure that makes those latent assets actually usable. It is not perfect and continues to improve, but the direction is right.
