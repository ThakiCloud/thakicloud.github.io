---
title: "Complete CCPM Tutorial: Transform PRDs to Production Code with Claude Code PM"
excerpt: "Master the revolutionary Claude Code Project Management system that turns PRDs into epics, epics into GitHub issues, and issues into production code with full traceability and parallel execution."
seo_title: "CCPM Tutorial: Claude Code Project Management Guide - Thaki Cloud"
seo_description: "Learn CCPM (Claude Code Project Management) - a battle-tested system for spec-driven development using GitHub Issues, Git worktrees, and parallel AI agents."
date: 2025-08-25
tags:
  - claude-code
  - project-management
  - ai-agents
  - github
  - workflow
  - spec-driven-development
author_profile: true
toc: true
toc_label: "Tutorial Contents"
lang: en
permalink: /en/tutorials/ccpm-claude-code-project-management-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/ccpm-claude-code-project-management-tutorial/"
published: false
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction: Beyond Vibe Coding

Every development team faces the same productivity killers:

- **Context evaporates** between sessions, forcing constant re-discovery
- **Parallel work creates conflicts** when multiple developers touch the same code
- **Requirements drift** as verbal decisions override written specs
- **Progress becomes invisible** until the very end

[Claude Code Project Management (CCPM)](https://github.com/automazeio/ccpm) solves all of these problems with a revolutionary approach that transforms how AI-assisted development works.

### What Makes CCPM Revolutionary?

Traditional Claude Code workflows operate in isolation – a single developer working with AI in their local environment. CCPM breaks this limitation by using **GitHub Issues as the database** and **Git worktrees for parallel execution**.

| Traditional Development | CCPM System |
|------------------------|-------------|
| Context lost between sessions | **Persistent context** across all work |
| Serial task execution | **Parallel agents** on independent tasks |
| "Vibe coding" from memory | **Spec-driven** with full traceability |
| Progress hidden in branches | **Transparent audit trail** in GitHub |
| Manual task coordination | **Intelligent prioritization** |

## System Architecture Overview

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
<div class="d3-arch" data-arch-root id="rojectmanagementtutorial-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1382, "height": 1126, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 547, "y": 722, "w": 596, "h": 124, "label": "Local Development", "lx": 559, "ly": 740}, {"x": 24, "y": 520, "w": 625, "h": 124, "label": "GitHub Integration", "lx": 36, "ly": 538}], "nodes": [{"id": "A", "x": 386, "y": 24, "w": 120, "h": 46, "title": "PRD Creation"}, {"id": "B", "x": 385, "y": 148, "w": 121, "h": 46, "title": "Epic Planning"}, {"id": "C", "x": 368, "y": 272, "w": 156, "h": 46, "title": "Task Decomposition"}, {"id": "D", "x": 368, "y": 396, "w": 156, "h": 46, "title": "GitHub Issues Sync"}, {"id": "E", "x": 858, "y": 559, "w": 198, "h": 46, "title": "Parallel Agent Execution"}, {"id": "F", "x": 1180, "y": 761, "w": 163, "h": 46, "title": "Worktree Management"}, {"id": "G", "x": 1191, "y": 924, "w": 142, "h": 46, "title": "Code Integration"}, {"id": "H", "x": 1173, "y": 1048, "w": 177, "h": 46, "title": "Production Deployment"}, {"id": "I", "x": 984, "y": 761, "w": 121, "h": 46, "title": "Context Files"}, {"id": "J", "x": 809, "y": 761, "w": 120, "h": 46, "title": "Task Files"}, {"id": "K", "x": 584, "y": 761, "w": 170, "h": 46, "title": "Agent Specialization"}, {"id": "L", "x": 477, "y": 559, "w": 135, "h": 46, "title": "Issues Database"}, {"id": "M", "x": 273, "y": 559, "w": 149, "h": 46, "title": "Progress Tracking"}, {"id": "N", "x": 62, "y": 559, "w": 156, "h": 46, "title": "Team Collaboration"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [446, 70, 446, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [446, 194, 446, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [446, 318, 446, 396]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[524, 428], [957, 481], [957, 520], [957, 559]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[1056, 602], [1262, 644], [1262, 722], [1262, 761]]}, {"src": "F", "dst": "G", "kind": "data", "line": [1262, 807, 1262, 924]}, {"src": "G", "dst": "H", "kind": "data", "line": [1262, 970, 1262, 1048]}, {"src": "E", "dst": "I", "kind": "data", "curve": [[989, 605], [1045, 644], [1045, 722], [1045, 761]]}, {"src": "E", "dst": "J", "kind": "data", "curve": [[924, 605], [869, 644], [869, 722], [869, 761]]}, {"src": "E", "dst": "K", "kind": "data", "curve": [[858, 603], [669, 644], [669, 722], [669, 761]]}, {"src": "D", "dst": "L", "kind": "data", "curve": [[482, 442], [544, 481], [544, 520], [544, 559]]}, {"src": "D", "dst": "M", "kind": "data", "curve": [[409, 442], [347, 481], [347, 520], [347, 559]]}, {"src": "D", "dst": "N", "kind": "data", "curve": [[368, 435], [140, 481], [140, 520], [140, 559]]}]});
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
      const container = document.getElementById('rojectmanagementtutorial-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rojectmanagementtutorial-1';
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

## Prerequisites and Setup

### System Requirements

- macOS (recommended) or Linux
- Git 2.30+
- Claude Code (Anthropic's coding assistant)
- GitHub CLI (`gh`)
- Node.js 18+ (for some automation scripts)

### macOS Quick Test Script

For macOS users, you can use our automated test script to validate your environment and try CCPM:

```bash
# Download and run the CCPM test script
curl -fsSL https://raw.githubusercontent.com/automazeio/ccpm/main/scripts/test-workflow.sh | bash

# Or if you have this repository locally:
./scripts/test-ccpm-workflow.sh
```

This script will:
- ✅ Check all system prerequisites
- ✅ Create a test project with CCPM installed
- ✅ Validate the installation
- ✅ Create sample PRD and Epic files
- ✅ Test GitHub CLI integration (if available)
- ✅ Provide next steps for Claude Code integration

### Quick Installation (2 Minutes)

**Step 1: Clone CCPM into Your Project**

```bash
# Navigate to your project directory
cd path/to/your/project/

# Clone CCPM system
git clone https://github.com/automazeio/ccpm.git .
```

> ⚠️ **IMPORTANT**: If you already have a `.claude` directory, clone to a temporary directory and merge the contents manually.

**Step 2: Initialize the PM System**

```bash
# In Claude Code, run:
/pm:init
```

This command will:
- Install GitHub CLI (if needed)
- Authenticate with GitHub
- Install `gh-sub-issue` extension for parent-child relationships
- Create required directories
- Update `.gitignore`

**Step 3: Configure Repository Settings**

Create or update your `CLAUDE.md`:

```bash
# In Claude Code:
/init include rules from .claude/CLAUDE.md

# If you already have CLAUDE.md:
/re-init
```

**Step 4: Prime the System**

```bash
# Initialize context system
/context:create
```

## Core Workflow: From Idea to Production

### Phase 1: PRD (Product Requirements Document) Creation

The foundation of CCPM is **spec-driven development**. Everything starts with a comprehensive PRD.

**Starting a New Feature:**

```bash
/pm:prd-new memory-system
```

This launches an **interactive brainstorming session** that creates a detailed PRD covering:

- **Problem Statement**: What exactly are we solving?
- **Success Metrics**: How do we measure success?
- **User Stories**: Who benefits and how?
- **Technical Constraints**: What are our limitations?
- **Edge Cases**: What could go wrong?
- **Integration Points**: How does this fit with existing systems?

**Example PRD Structure:**

```markdown
# Memory System PRD

## Problem Statement
Users lose context between Claude Code sessions, leading to repeated explanations and slower development cycles.

## Success Metrics
- 90% reduction in context re-establishment time
- 75% fewer repeated questions
- Persistent project understanding across sessions

## User Stories
- As a developer, I want Claude to remember our previous architectural decisions
- As a team lead, I want consistent context across team members
- As a product manager, I want feature requirements preserved between sessions

## Technical Architecture
- File-based memory storage in `.claude/memory/`
- Automatic context loading on session start
- Structured memory categories (decisions, patterns, constraints)

## Integration Points
- Existing `.claude/` directory structure
- GitHub Issues for progress tracking
- Git hooks for automatic memory updates
```

### Phase 2: Epic Planning and Task Decomposition

Once your PRD is complete, transform it into an actionable epic with detailed tasks.

**Parse PRD into Epic:**

```bash
/pm:prd-parse memory-system
```

This creates:
- **Epic overview** with clear objectives
- **Technical breakdown** of required components
- **Task list** with dependencies mapped
- **Effort estimates** for each component
- **Parallel execution plan** for maximum efficiency

**Example Epic Structure:**

```
Epic: Memory System Implementation

├── Task 1: Core Memory Infrastructure
│   ├── Create memory storage system
│   ├── Implement context loading
│   └── Add memory persistence hooks
│
├── Task 2: Memory Management Interface
│   ├── Design memory CRUD operations
│   ├── Build memory search functionality
│   └── Create memory visualization tools
│
└── Task 3: Integration and Testing
    ├── Integrate with existing workflows
    ├── Add comprehensive test suite
    └── Create documentation and examples
```

### Phase 3: GitHub Integration and Issue Creation

Transform your epic into a structured GitHub project with full traceability.

**One-Shot Epic to GitHub:**

```bash
/pm:epic-oneshot memory-system
```

This command:
1. **Creates parent epic issue** in GitHub
2. **Generates child task issues** with proper relationships
3. **Sets up labels and milestones** for organization
4. **Initializes progress tracking** with completion metrics
5. **Creates local task files** linked to GitHub issues

**Example GitHub Structure:**

```
Issue #1234 (Epic): Memory System Implementation
├── Issue #1235: Core Memory Infrastructure  
├── Issue #1236: Memory Management Interface
└── Issue #1237: Integration and Testing
```

Each issue contains:
- Detailed technical specifications
- Acceptance criteria
- Dependencies and prerequisites
- Estimated effort and complexity
- Links to related issues and documentation

### Phase 4: Parallel Agent Execution

Here's where CCPM truly shines – **multiple specialized agents working simultaneously**.

**Starting Work on Issues:**

```bash
# Start work on infrastructure task
/pm:issue-start 1235

# In parallel, start interface work
/pm:issue-start 1236

# And testing preparation
/pm:issue-start 1237
```

**What Happens Behind the Scenes:**

1. **Agent Specialization**: Each agent focuses on their specific domain
   - **Infrastructure Agent**: Database schemas, file systems, core logic
   - **Interface Agent**: APIs, user interfaces, integration points  
   - **Testing Agent**: Test suites, validation, documentation

2. **Worktree Management**: Each issue gets its own Git worktree
   ```
   ../epic-memory-system/
   ├── main/           # Primary development branch
   ├── issue-1235/     # Infrastructure work
   ├── issue-1236/     # Interface development  
   └── issue-1237/     # Testing and integration
   ```

3. **Context Isolation**: Agents maintain separate contexts
   ```
   .claude/context/
   ├── epic-memory-system/
   │   ├── infrastructure-context.md
   │   ├── interface-context.md
   │   └── testing-context.md
   ```

### Phase 5: Progress Management and Coordination

Monitor and coordinate work across all parallel streams.

**Check Overall Status:**

```bash
/pm:status
```

**Sample Status Output:**
```
Memory System Epic Progress: 67% Complete

✅ Issue #1235: Core Infrastructure (Complete)
   - Memory storage system ✅
   - Context loading ✅  
   - Persistence hooks ✅

🚧 Issue #1236: Management Interface (In Progress)
   - CRUD operations ✅
   - Search functionality 🚧
   - Visualization tools ⏳

⏳ Issue #1237: Integration & Testing (Pending)
   - Workflow integration ⏳
   - Test suite ⏳
   - Documentation ⏳
```

**Get Next Priority Task:**

```bash
/pm:next
```

This intelligently suggests the next most important task based on:
- **Dependencies**: What's blocking other work?
- **Effort estimates**: Quick wins vs. complex tasks
- **Team capacity**: What can be done in parallel?
- **Business priority**: What delivers value soonest?

## Advanced Features and Commands

### Workflow Management Commands

**Daily Standup Report:**
```bash
/pm:standup
```
Generates a comprehensive status report perfect for team standups.

**Find Blocked Tasks:**
```bash
/pm:blocked
```
Identifies tasks waiting on dependencies or external factors.

**Show Work in Progress:**
```bash
/pm:in-progress
```
Lists all currently active development streams.

### Synchronization Commands

**Full Bidirectional Sync:**
```bash
/pm:sync
```
Synchronizes all local changes with GitHub and pulls updates from team members.

**Import Existing Issues:**
```bash
/pm:import
```
Brings existing GitHub issues into the CCPM system for management.

### Maintenance Commands

**Validate System Integrity:**
```bash
/pm:validate
```
Checks for consistency between local files and GitHub state.

**Clean Completed Work:**
```bash
/pm:clean
```
Archives completed epics and tasks to keep the workspace organized.

**Search Across Content:**
```bash
/pm:search "authentication logic"
```
Finds relevant information across all PRDs, epics, and tasks.

## Real-World Example: Building a User Authentication System

Let's walk through a complete example from idea to production.

### Step 1: Create the PRD

```bash
/pm:prd-new user-authentication
```

**Generated PRD (abbreviated):**
```markdown
# User Authentication System PRD

## Problem Statement
Our application lacks secure user authentication, preventing personalized experiences and data protection.

## Success Metrics
- Support 10,000+ concurrent users
- <200ms authentication response time
- 99.9% uptime for auth services
- OAuth integration with Google, GitHub, Apple

## Technical Requirements
- JWT-based session management
- Password hashing with bcrypt
- Rate limiting for login attempts
- Multi-factor authentication support
- Session persistence across devices
```

### Step 2: Parse into Epic

```bash
/pm:prd-parse user-authentication
```

**Generated Epic Structure:**
```
Epic: User Authentication System

├── Database Schema & Models (2-3 days)
│   ├── User table design
│   ├── Session management tables  
│   └── OAuth provider tables
│
├── Authentication Service (3-4 days)  
│   ├── JWT token management
│   ├── Password hashing/validation
│   ├── OAuth provider integration
│   └── Session lifecycle management
│
├── API Endpoints (2-3 days)
│   ├── Login/logout endpoints
│   ├── Registration workflow
│   ├── Password reset functionality
│   └── Profile management APIs
│
├── Frontend Integration (2-3 days)
│   ├── Login/registration forms
│   ├── Authentication state management
│   ├── Protected route handling
│   └── OAuth login buttons
│
└── Security & Testing (2-3 days)
    ├── Security audit and penetration testing
    ├── Comprehensive test suite
    ├── Performance benchmarking
    └── Documentation and deployment guides
```

### Step 3: Create GitHub Issues

```bash
/pm:epic-oneshot user-authentication
```

**Created Issues:**
- Issue #1240 (Epic): User Authentication System
  - Issue #1241: Database Schema & Models
  - Issue #1242: Authentication Service  
  - Issue #1243: API Endpoints
  - Issue #1244: Frontend Integration
  - Issue #1245: Security & Testing

### Step 4: Parallel Execution

```bash
# Start database work
/pm:issue-start 1241

# Simultaneously start service layer
/pm:issue-start 1242  

# And prepare API structure
/pm:issue-start 1243
```

**Agent Coordination:**
- **Database Agent**: Creates schemas, migrations, and data models
- **Service Agent**: Implements JWT logic, OAuth flows, session management
- **API Agent**: Builds REST endpoints with proper validation and error handling

Each agent works in isolation but coordinates through:
- Shared interface definitions
- Common data structures
- Coordinated testing strategies

### Step 5: Integration and Deployment

```bash
# Check integration points
/pm:epic-show user-authentication

# Validate all components work together
/pm:validate

# Final status before deployment
/pm:status
```

**Final Integration:**
All worktrees merge back into main branch with:
- Complete authentication system
- Comprehensive test coverage
- Full documentation
- Deployment-ready configuration

## Best Practices and Pro Tips

### 1. PRD Quality is Everything

**Invest Time in Detailed PRDs:**
- Spend 20-30% of project time on PRD creation
- Include edge cases and error scenarios
- Define success metrics clearly
- Document integration requirements thoroughly

**PRD Anti-Patterns to Avoid:**
- Vague requirements ("make it fast")
- Missing error handling scenarios
- Undefined success metrics
- No consideration of existing system constraints

### 2. Task Decomposition Strategy

**Optimal Task Size:**
- 1-3 days of work per task
- Clear input/output definitions
- Minimal dependencies between tasks
- Testable completion criteria

**Parallel-Friendly Decomposition:**
```bash
# Good: Clear separation of concerns
- Task A: Database layer
- Task B: Business logic  
- Task C: API layer
- Task D: Frontend components

# Bad: Sequential dependencies
- Task 1: Start everything
- Task 2: Continue everything  
- Task 3: Finish everything
```

### 3. Context Management

**Keep Contexts Focused:**
- Each agent maintains domain-specific context
- Main thread stays strategic, not tactical
- Regular context cleanup prevents bloat
- Document key decisions in persistent memory

**Context Anti-Patterns:**
- Mixing implementation details in main thread
- Agents sharing overlapping contexts
- Never cleaning completed work contexts
- Losing architectural decisions between sessions

### 4. Team Collaboration

**GitHub Issue Hygiene:**
- Clear, actionable issue titles
- Detailed acceptance criteria
- Regular progress updates in comments
- Proper labeling and milestone assignment

**Human-AI Collaboration:**
- Humans can jump into any issue at any time
- AI progress is visible through GitHub comments
- Code reviews happen naturally through PRs
- No special tools needed for team coordination

## Performance Metrics and Results

Teams using CCPM report significant improvements:

### Development Velocity
- **5-8 parallel tasks** vs 1 previously
- **Up to 3x faster** feature delivery
- **89% less time** lost to context switching
- **75% reduction** in bug rates

### Code Quality
- **Complete traceability** from requirements to code
- **Comprehensive test coverage** through dedicated testing agents
- **Consistent architecture** through spec-driven development
- **Better documentation** as a natural byproduct

### Team Productivity
- **Seamless handoffs** between team members
- **Transparent progress** visible to all stakeholders
- **Reduced meetings** due to self-documenting progress
- **Improved estimation** accuracy through detailed task breakdown

## Troubleshooting Common Issues

### Setup Issues

**GitHub CLI Authentication:**
```bash
gh auth status
gh auth login
```

**Missing gh-sub-issue Extension:**
```bash
gh extension install HackerNews/gh-sub-issue
```

**Worktree Conflicts:**
```bash
# Clean up corrupted worktrees
git worktree prune
git worktree remove ../epic-name/issue-123/
```

### Sync Issues

**Local-GitHub Mismatch:**
```bash
/pm:validate
/pm:sync --force
```

**Context Corruption:**
```bash
/context:create --reset
```

### Performance Issues

**Too Many Parallel Agents:**
- Limit to 3-5 concurrent agents
- Focus on tasks with clear separation
- Use `/pm:next` for intelligent prioritization

**Context Size Management:**
```bash
/pm:clean --aggressive
/context:compact
```

## Advanced Configuration

### Custom Agent Specialization

Create specialized agents for your tech stack:

```markdown
# .claude/agents/backend-agent.md
You are a backend development specialist focused on:
- Database design and optimization
- API security and performance
- Server infrastructure and scaling
- Integration testing and monitoring
```

### Workflow Customization

Adapt CCPM to your team's needs:

```yaml
# .claude/config/workflow.yml
epic_size: medium  # small, medium, large
parallel_limit: 5
auto_sync: true
github_labels:
  - "epic:feature"
  - "task:implementation"
  - "priority:high"
```

## Future Roadmap and Extensions

### Planned Features
- **Multi-repository support** for microservices
- **Integration with CI/CD pipelines** for automated testing
- **Advanced analytics** on development velocity
- **Team performance dashboards** with metrics visualization

### Community Extensions
- **Slack/Discord integration** for team notifications
- **Jira synchronization** for enterprise environments  
- **Custom workflow templates** for different project types
- **AI-powered code review** integration

## Conclusion: Transforming How Teams Ship Software

CCPM represents a fundamental shift in how AI-assisted development works. By moving beyond isolated conversations to collaborative, traceable, parallel execution, teams can:

1. **Ship faster** through intelligent parallel execution
2. **Maintain quality** through spec-driven development
3. **Improve collaboration** with transparent progress tracking
4. **Reduce context loss** with persistent project memory
5. **Scale effectively** as teams and projects grow

The system is battle-tested by teams shipping production software and represents the future of human-AI collaboration in software development.

### Getting Started Today

1. **Clone CCPM** into your next project
2. **Start with a simple feature** to learn the workflow
3. **Expand to complex epics** as you build confidence
4. **Share with your team** and experience collaborative AI development

The transformation from vibe coding to spec-driven parallel development starts with a single command:

```bash
/pm:prd-new your-next-feature
```

### Resources and Community

- **GitHub Repository**: [https://github.com/automazeio/ccpm](https://github.com/automazeio/ccpm)
- **Documentation**: Comprehensive guides in the repository
- **Community**: Join discussions in GitHub Issues
- **Support**: Follow [@aroussi](https://x.com/aroussi) for updates and tips

---

*Ready to revolutionize your development workflow? Start your first CCPM project today and experience the future of AI-assisted software development.*
