---
title: "158 Skills and 24 Agents in One Plugin: How a Deterministic Skeleton Tames Agent Explosion"
excerpt: "The open-source marketing plugin Digital Marketing Pro bundles 158 skills and 24 specialist agents without collapsing. The trick is a deterministic skeleton: a fixed 12-part flow. We dissect the design and show how ThakiCloud's Paxis productizes the same principle."
date: 2026-07-21
tags:
  - AgentOps
  - Skills
  - MultiAgent
  - ClaudeCode
  - Plugins
  - Determinism
  - Paxis
  - AIAgents
author_profile: true
toc: true
toc_label: Plugin dissection
published: true
categories:
  - dev
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/en/dev/agent-plugin-158-skills-deterministic-flow/"
---

![Abstract visualization of many skill modules converging into one ordered vertical pipeline]({{ '/assets/images/agent-plugin-158-skills-deterministic-flow-hero.png' | relative_url }})

## Overview

Anyone who has built a serious agent system runs into the same paradox. Adding more skills and agents feels like it should make the system smarter, but often it does the opposite. Once you pass a few dozen skills, the agent starts getting confused about which skill to use when, and once there are several agents, they handle the same task differently or the order and format of outputs drift every run. Capability goes up while consistency of results goes down.

The open-source marketing plugin **Digital Marketing Pro** is an interesting case that tackles this paradox head on. It bundles 158 skills and 24 specialist agents (the repo docs list 25; the original tweet said 24) and still keeps the consistency of producing the same files in the same order every time. The trick is not a smarter model but a strategy flow fixed into 12 parts, a deterministic skeleton. This article dissects not the marketing tool itself but the agent engineering design inside it. What structure survives even when skills explode in number, and how that principle connects to the agent platform ThakiCloud is building.

Why this case matters to developers is clear. It shows, in concrete open-source code, why the naive hope of "just make lots of skills" so often fails in practice, and what stops that failure.

## What the Plugin Is

Digital Marketing Pro is an open-source marketing plugin released under the MIT license. Its surface purpose is to help agencies and in-house marketing teams produce marketing documents consistently across many brands. According to the repo description, it targets agencies handling between 50 and 200 client brands, running every brand through the same 12-part flow to produce the same files in the same order.

By the numbers, the plugin is fairly large. It has 158 skills, 24 specialist agents, and a 12-part strategy flow expanded into 61 detailed steps. On top of that sit EU AI Act Article 50 readiness, AEO/GEO (answer engine optimization) features for six platforms including Google AI Mode, and Cowork support that persists state at the team level.

Worth noting is the install target. The plugin is not tied to Claude Code alone; it installs across multiple agent runtimes including Cowork, Codex, Cursor, Copilot CLI, and Antigravity. In other words, a single bundle of skills and agents is designed to work across many harnesses. This is an important enough design decision to treat separately below.

In short, beneath the appearance of a "marketing tool," this plugin holds one answer to how you organize and consistently execute a large bundle of skills and agents.

## A Deterministic Skeleton Tames the Skill Explosion

The core insight of this plugin is that it does not let the 158 skills and 24 agents collaborate freely. Instead it forces every task through a strategy flow fixed into 12 parts. Each part produces a defined output in a defined order, and there are explicit dependency rules between parts. A later part runs only when the earlier result exists, and the names and order of the result files stay identical even as the brand changes.

Why this matters becomes clear if you imagine the opposite. If 24 agents freely picked the skill that "looked best" and ran in free order, the composition and format of outputs would differ per brand. One brand might get competitor analysis first; another might skip that step entirely. If an agency manages 200 clients, this variance quickly becomes unauditable chaos. The 12-part flow deliberately reduces that freedom to raise average quality and consistency.

The flow below is a simplified view of how this deterministic skeleton constrains the freedom of skills and agents.

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
<div class="d3-arch" data-arch-root id="8skillsdeterministicflow-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 261, "height": 1158, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 67, "y": 24, "w": 120, "h": 62, "title": ["Task request", "Brand X"]}, {"id": "B", "x": 67, "y": 164, "w": 120, "h": 62, "title": ["Enter fixed", "12-part flow"]}, {"id": "C", "x": 24, "y": 304, "w": 205, "h": 62, "title": ["Each part: defined output", "defined order"]}, {"id": "D", "x": 47, "y": 444, "w": 160, "h": 84, "title": ["Select the", "part-appropriate", "skill from 158"]}, {"id": "E", "x": 54, "y": 606, "w": 146, "h": 68, "title": ["Assign a role", "from 24 agents"]}, {"id": "F", "x": 38, "y": 752, "w": 177, "h": 78, "title": ["Apply explicit", "inter-part dependency", "rules"]}, {"id": "G", "x": 35, "y": 908, "w": 184, "h": 78, "title": ["Same files, same order", "brand-independent", "consistency"]}, {"id": "H", "x": 49, "y": 1064, "w": 156, "h": 62, "title": ["Auditable", "document portfolio"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [127, 86, 127, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [127, 226, 127, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [127, 366, 127, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [127, 528, 127, 606]}, {"src": "E", "dst": "F", "kind": "data", "line": [127, 674, 127, 752]}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 830, 127, 908]}, {"src": "G", "dst": "H", "kind": "data", "line": [127, 986, 127, 1064]}]});
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
      const container = document.getElementById('8skillsdeterministicflow-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '8skillsdeterministicflow-1';
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

The lesson here has nothing to do with marketing. The way to protect quality as skills and agents grow is not to make the model smarter but to demote free design into filling in a validated skeleton. A deterministic structure owns the format, order, and dependencies, while the model fills only the content inside that skeleton. Whether there are 158 skills or 500, as long as the skeleton holds the degrees of freedom in check, the result stays predictable.

## What It Means to Install Across Six Runtimes

Another design worth watching is that this plugin installs across multiple agent runtimes. Claude Code, Cursor, Codex, and Copilot CLI are each a different harness. Their system prompts differ, their tool definition styles differ, and their permission models differ. That the same skill and agent bundle is designed to run on top of all of them means the capability was accumulated in the skills, not in the harness.

This distinction matters in practice. If the knowledge of a marketing workflow were baked into a specific tool's config files or system prompt, switching tools would mean rebuilding everything. Conversely, when the knowledge lives in a portable bundle of skills, the harness stays thin and the skills are reused across tools. Digital Marketing Pro's cross-runtime install is a case of practicing this "thin harness, fat skills" principle at a commercial scale.

Of course supporting many runtimes at once has a cost. Because each runtime loads and calls skills slightly differently, designing to the common denominator can leave a specific runtime's unique features underused. Even so, prioritizing portability is a reasonable direction that frees skill assets from tool lock-in and lets them survive longer.

## Implications for ThakiCloud Products

What makes this case interesting is that it deals with a problem strikingly similar to what ThakiCloud is building with **Paxis**. Paxis is ThakiCloud's agent-native cloud, treating Skills, Tools, Policies, and Audit Logs as first-class resources. A skill harness selects the right skill among more than 960 skills via BM25, runs it in an isolated sandbox, and passes every action through policy gates and audit logs.

The exact problem Digital Marketing Pro solved by taming 158 skills with a 12-part flow, Paxis solves at larger scale. Once skills pass 960, "which skill to use when" reaches a scale a human cannot specify by hand, so BM25-based skill selection replaces that skeleton. Instead of freely calling any skill, only the skills most relevant to the request are surfaced as candidates, reducing the degrees of freedom. This is the same principle by which the 12-part flow blocked free order, except that instead of a fixed flow it controls freedom through retrieval-based selection.

Also, the plugin's emphasis on EU AI Act Article 50 readiness and auditable document output aligns with Paxis treating audit logs and policy gates as first-class. In customer environments where regulation and auditing matter, you must be able to trace "what was produced, in what order, on what basis." A deterministic flow and audit logs are the two axes that create this traceability, and Paxis provides them at the platform level. No matter how many skills you stack, because policy gates and audit logs record every action, a large skill asset can be operated safely even in regulated environments.

Finally, cross-runtime portability matches the direction ThakiCloud aims for. A design that reuses a skill asset across harnesses rather than binding it to a specific tool is the same reason Paxis treats skills as first-class resources. When capability is accumulated in the skills rather than the harness, the assets you have built remain even as the tool changes.

## Limitations and Counterpoints

It is important not to over-read this case. The fixed 12-part flow sacrifices flexibility in exchange for consistency. An exceptional need that departs from the standard flow, such as an unstructured task required only for a specific brand, may be handled awkwardly within this skeleton or not at all. A deterministic skeleton is powerful for repeatable bulk work but becomes a shackle for work with many creative exceptions.

The number 158 skills itself deserves careful reading. Having many skills means having many maintenance targets, and whether each skill is actually validated and kept current is a separate matter. A number does not guarantee quality. How many core skills the 12-part flow actually calls, and how often the rest are used, is hard to confirm from the repo docs alone [estimate].

Also, this article analyzes the plugin's design principles, not the actual quality of its marketing output. That a deterministic flow produces consistent documents is a different matter from whether those documents lead to real marketing results. What we take from this case is not the marketing outcome but the engineering pattern of taming a large bundle of skills and agents with a deterministic skeleton.

## Sources

- Repository: [github.com/indranilbanerjee/digital-marketing-pro](https://github.com/indranilbanerjee/digital-marketing-pro)
- Original source: [@tom_doerr tweet](https://x.com/hjguyhan/status/2079315207579660557)
