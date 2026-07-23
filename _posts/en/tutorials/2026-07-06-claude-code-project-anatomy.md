---
title: "Setting Up a Claude Code Project the Right Way: Dissecting the .claude/ Folder"
excerpt: "Most developers skip the setup and jump straight into prompting. That's a mistake. We dissect the structure of the .claude/ folder, from CLAUDE.md to rules, commands, skills, agents, and hooks, by measuring an actual production project running 1,671 skills. We also connect this pattern to how ThakiCloud productized it as the Agent-Native Cloud 'Paxis.'"
tags:
  - claude-code
  - developer-experience
  - agent-native
  - paxis
  - agentops
date: 2026-07-06
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/claude-code-project-anatomy/"
categories:
  - tutorials
---

![An abstract image of layered configuration levels converging into a single, well-ordered agent execution]({{ '/assets/images/claude-code-project-anatomy-hero.webp' | relative_url }})
*Scattered instructions, rules, and tools become predictable agent behavior once they're organized into a folder structure.*

## Overview

The most common mistake when starting work with Claude Code is skipping the setup and jumping straight into prompting. It works fine a few times, but as the project grows, you end up repeating the same instructions over and over, and the model starts every session from a blank slate. The quality of your results starts depending on the day's luck rather than your prompting skill.

The fix for this isn't swapping in a better model, it's turning **the project itself into a contract structure**. In Claude Code, that contract lives in the `.claude/` folder at the project root. A recent thread by Akshay Pachaar on X, "Anatomy of the .claude/ folder," widely shared and well organized, laid out this structure clearly. This post follows that same skeleton, but adds **numbers measured directly from an actual production Claude Code project running 1,671 skills** to show what scale each layer operates at in the real world. We also connect this to how ThakiCloud productized the pattern as Paxis, its Agent-Native Cloud.

## What Is the .claude/ Folder

`.claude/` is a set of conventions that tells Claude Code "this is how we work on this project." The key idea isn't one giant prompt, it's several layers with different roles, each with its own loading time and cost.

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
<div class="d3-arch" data-arch-root id="claudecodeprojectanatomy-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 778, "height": 703, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 325, "w": 177, "h": 46, "title": ".claude/ project root"}, {"id": "B", "x": 307, "y": 609, "w": 121, "h": 62, "title": ["CLAUDE.md", "project brain"]}, {"id": "C", "x": 300, "y": 492, "w": 135, "h": 62, "title": ["rules/", "always-on rules"]}, {"id": "D", "x": 283, "y": 375, "w": 170, "h": 62, "title": ["commands/", "repeatable workflows"]}, {"id": "E", "x": 286, "y": 258, "w": 163, "h": 62, "title": ["skills/", "on-demand expertise"]}, {"id": "F", "x": 290, "y": 141, "w": 156, "h": 62, "title": ["agents/", "isolated subagents"]}, {"id": "G", "x": 279, "y": 24, "w": 177, "h": 62, "title": ["settings.json", "permissions and hooks"]}, {"id": "B1", "x": 538, "y": 617, "w": 205, "h": 46, "title": "auto-loaded every session"}, {"id": "C1", "x": 548, "y": 500, "w": 184, "h": 46, "title": "auto-loaded every turn"}, {"id": "E1", "x": 534, "y": 258, "w": 212, "h": 62, "title": ["loaded only when a request", "triggers it"]}, {"id": "F1", "x": 548, "y": 141, "w": 184, "h": 62, "title": ["summoned via the Agent", "tool"]}, {"id": "G1", "x": 541, "y": 24, "w": 198, "h": 62, "title": ["PreToolUse, PostToolUse,", "Stop, etc."]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[123, 371], [240, 640], [240, 640], [307, 640]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[129, 371], [240, 523], [240, 523], [300, 523]]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[163, 371], [240, 406], [240, 406], [283, 406]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[163, 325], [240, 289], [240, 289], [286, 289]]}, {"src": "A", "dst": "F", "kind": "data", "curve": [[129, 325], [240, 172], [240, 172], [290, 172]]}, {"src": "A", "dst": "G", "kind": "data", "curve": [[123, 325], [240, 55], [240, 55], [279, 55]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [428, 640, 538, 640]}, {"src": "C", "dst": "C1", "kind": "data", "line": [435, 523, 548, 523]}, {"src": "E", "dst": "E1", "kind": "data", "line": [449, 289, 534, 289]}, {"src": "F", "dst": "F1", "kind": "data", "line": [446, 172, 548, 172]}, {"src": "G", "dst": "G1", "kind": "data", "line": [456, 55, 541, 55]}]});
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
      const container = document.getElementById('claudecodeprojectanatomy-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'claudecodeprojectanatomy-1';
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

Breaking down each layer's role:

**CLAUDE.md** is the project's brain. It loads automatically every session and answers only four things: architecture overview, tech stack, conventions, and workflow rules. Cramming "occasionally needed" knowledge in here wastes context on every single session, so keeping CLAUDE.md thin is the guiding principle.

**rules/** are always-on rules applied on every turn. This is where you put invariant rules that apply to all work, like coding style, security policy, git workflow, and quality gates. When CLAUDE.md gets bloated, this is where you split it out to.

**commands/** bundle repeatable workflows into slash commands. A single command like `/review` or `/ship` invokes a predefined multi-step procedure.

**skills/** are on-demand expertise loaded only when a request triggers them. This is where you put domain pipelines and analysis recipes that aren't always needed. Only a skill's name and description sit in the index until a relevant request comes in, at which point the full body loads.

**agents/** are definitions of independent specialists with their own roles, tools, and models. They're summoned via the Agent tool, and routed by task: exploration to a cheap model, implementation to a balanced model, architectural judgment to a strong model.

**settings.json** locks down permissions and hooks. Hooks inject deterministic code before or after tool calls (`PreToolUse`/`PostToolUse`) or at session end (`Stop`), so that code, not the model, owns formatting and validation.

On top of this, there are two copies of the `.claude/` folder. One lives in the repository, committed and shared by the whole team. The other is a global folder at `~/.claude/`, which holds personal preferences and cross-project automatic memory.

## Installation and Configuration

The fastest way to start is to initialize from the project root.

```bash
# From the project root
claude
# Inside the session, generate a draft of the project brain
/init
```

`/init` scans the repository and drafts a `CLAUDE.md` for you. After that, you refine it manually. You can also hand-build the folder skeleton like this:

```bash
mkdir -p .claude/rules .claude/commands .claude/skills .claude/agents .claude/hooks
```

Here's an example of wiring a hook into `settings.json`, a PostToolUse hook that auto-formats after an edit.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "python3 .claude/hooks/format-on-save.py",
        "description": "Auto-format edited files"
      }
    ]
  }
}
```

The minimal form of a single skill is a `SKILL.md` frontmatter. Since `description` becomes the search trigger, include both English and Korean keywords, and write out "when NOT to use this" so it doesn't get confused with a neighboring skill.

```yaml
---
name: my-pipeline
description: >-
  Does X in one sentence. Use when <english + Korean trigger phrases>.
  Do NOT use for <anti-pattern> (use other-skill).
---
```

There's one core discipline underlying all of this. **Capability belongs in skills, not in the harness.** Keep CLAUDE.md and rules thin, and put domain knowledge, judgment, templates, and failure cases thickly into skills. The goal is for the same skill to work across Claude Code and other harnesses alike.

## Real Measurements: Dissecting a Production Claude Code Project

The very repository this post is written in is a heavily configured Claude Code project. We measured how each layer is actually used at scale by counting the files directly. The numbers below are all measured values.

| Layer | Measured count | Load timing | Role |
|---|---|---|---|
| CLAUDE.md | 94 lines | Every session | Project brain (kept thin) |
| rules/ | 49 files | Every turn | Always-on rules |
| commands/ | 22 files | On invocation | Repeatable workflows |
| skills/ | 1,671 files | On trigger | On-demand expertise |
| agents/ | 60 files | On summon | Isolated subagents |
| hooks/ | 12 files | Around tool calls | Deterministic gates |

The design principle this reveals is clear. CLAUDE.md is extremely thin at 94 lines. Since it's a file loaded every session, it pays "rent," so it only holds the bare minimum. Skills, on the other hand, are overwhelmingly numerous at 1,671. Because skills only load when triggered, this scale doesn't impose a per-turn cost even though it's enormous.

The measured hook events were five kinds: `PreToolUse`, `PostToolUse`, `Stop`, `SessionStart`, and `UserPromptSubmit`, and `settings.json` was organized around three axes: `permissions`, `hooks`, and `env`. In other words, the things that are always on (rules, hooks) are kept to a small set, while the things called only when needed (skills, agents) are allowed to grow large.

But once you have 1,671 skills, a new problem emerges. Neither a human nor the model can scan the entire list to pick "which skill should I use right now." This is exactly where the next section picks up.

## Implications for ThakiCloud's Product

The moment skill count reaches into the thousands, managing files in the `.claude/` folder stops being a personal organization problem and becomes a **runtime routing problem**. ThakiCloud productized this pattern as **Paxis**, its Agent-Native Cloud.

Paxis is an agent control plane that runs on top of ThakiCloud's AI infrastructure (ai-platform), treating Skills, Tools, Policies, and Audit Logs as first-class resources. The part that connects directly to the anatomy of the `.claude/` folder is the **Skill Harness**. As we saw above, no matter how many skills you build, loading all of them every turn blows up the context. Paxis selects only the relevant skills from a massive skill pool using BM25 search when a request comes in, loads only those, and runs them in an isolated sandbox. This is exactly why routing still holds up even when the skill count, as measured in this post, comfortably exceeds 1,000.

On top of that, it elevates what hooks do (deterministic gating) into policy gates and audit logs. Just as a PreToolUse hook in `.claude/settings.json` blocks a dangerous command, Paxis routes every agent action through policy gates and audit logs, leaving a record of who ran what, and when. It's the personal-project hook pattern made trustworthy in a multi-tenant environment.

The agents/ layer extends into Paxis's DAG-based multi-agent orchestration. The local pattern of separating individual subagents by role and model scales up into a structure that binds multiple agents into a dependency graph, runs them in parallel, and closes the loop with a verification stage.

There's also a meaning at the infrastructure level (through the ai-platform lens). All this skill and agent execution ultimately consumes GPU and inference cost. ThakiCloud's ai-platform underpins this execution at low cost through K8s/Kueue-based GPU scheduling and vLLM serving, and it lets the same harness run as self-hosted for customer environments with on-premises or sovereignty requirements. Low-cost serving is what makes agent economics work, and Paxis's skill harness runs on top of that foundation.

## Limitations and Counterarguments

This approach isn't always the right answer. First, forcing a heavy `.claude/` structure onto small scripts or one-off tasks is overkill. Before adding a single rule, you should ask "does this really need to apply on every turn," and if not, push it down into a skill. The setup itself shouldn't become the goal.

Second, scaling skills into the thousands turns search noise into a new bottleneck. The more similarly named skills you have, the lower routing accuracy gets, and the greater the risk of loading the wrong skill. This problem doesn't get solved by bumping the model tier, it only improves through the tedious work of refining each skill description's triggers and boundaries.

Third, the committed `.claude/` folder should hold only team-shared configuration. Personal paths, tokens, and debugging shortcuts belong in `~/.claude/` or `CLAUDE.local.md`. If you don't respect this boundary, personal information ends up exposed in the repository.

To sum up, setting up the `.claude/` folder isn't about "making the model better," it's about "making the model's behavior predictable." When a project is small, a single CLAUDE.md is enough, and as it grows, you split it into rules, skills, agents, and hooks. And the moment skills scale into the thousands, it stops being folder organization and becomes a routing infrastructure problem. Paxis is exactly where ThakiCloud tackles that point as a product.

## Sources

- [Akshay Pachaar, "How to setup your Claude code project?" (X)](https://x.com/akshay_pachaar/status/2035706568142893229)
- [Builder.io, "Setting Up a New Claude Code Project: The Complete Guide"](https://www.builder.io/blog/setting-up-claude-code-project)
- [Claude Code Docs: Quickstart](https://code.claude.com/docs/en/quickstart)
