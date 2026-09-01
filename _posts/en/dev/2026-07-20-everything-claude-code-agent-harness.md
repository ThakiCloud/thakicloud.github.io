---
title: "everything-claude-code: Dissecting an AI Coding Harness Battle-Tested Over Six Months"
excerpt: "AI coding tools forget your rules every new session. An Anthropic hackathon winner solved this by open-sourcing the config they refined over six months on a real TypeScript microservice. We dissect everything-claude-code's thin-harness, fat-skills design and show how ThakiCloud's Paxis productizes the same principle."
date: 2026-07-20
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/everything-claude-code-agent-harness/"
tags:
  - ClaudeCode
  - 에이전트하네스
  - Skills
  - Rules
  - AI코딩
  - AgentOps
  - paxis
  - 개발생산성
author_profile: true
toc: true
toc_label: Anatomy of the Harness
published: true
categories:
  - dev
  - agentops
---

![A thin harness core connected to many skill modules]({{ '/assets/images/everything-claude-code-agent-harness-hero.webp' | relative_url }})

## Overview

Any developer who uses an AI coding tool seriously for a few days hits the same wall. Yesterday you clearly told it "this project commits like this, do not touch that folder, run tests with this command," yet today, when you open a new session, the tool remembers none of it. You paste the same rules again, and you revert the same convention-breaking code again. The smarter the model gets, the more frustrating this gap becomes: the capability is there, but there is no skeleton to make that capability apply your rules consistently.

`everything-claude-code` is an open-source configuration collection that tackles exactly this skeleton. An Anthropic hackathon winner open-sourced the entire production-grade config they refined for over six months while running a real TypeScript microservice project, and the repository quickly gathered stars after release (around 9,700 per the source tweet, [estimated]). This post walks through what the repository contains, the design principles it stands on, and how those principles connect to the agent platform ThakiCloud is building. ThakiCloud has adopted this repository's rule set as an actual internal standard, so this is a hands-on take rather than a mere introduction.

## What everything-claude-code Is

`everything-claude-code` (ECC for short) describes itself as "the agent harness performance optimization system." It bundles six kinds of configuration assets: subagents that handle delegated tasks (agents), on-demand bundles of specialized knowledge (skills), hooks that automatically intervene before and after tool execution (hooks), slash commands wrapping repeated work (commands), always-on rules (rules), and MCP server configs that connect external tools (MCPs).

Crucially, this is not some hobby project's config. The author won the Anthropic x Forum Ventures hackathon in September 2025 by building a product using only Claude Code, then honed this config for over ten months while shipping real products every day. The quality metrics the repository states are concrete: 1,282 tests, 98% coverage, and 102 static-analysis rules. The very fact that a configuration collection carries this level of discipline is evidence that the author separates "rules to hand the AI" from "code that verifies those rules are kept."

Another trait is harness neutrality. ECC is designed to work not only in Claude Code but also in other coding agents like Codex, Opencode, and Cursor. The idea of reusing the same rules and skills across multiple tools is a natural consequence of the design philosophy discussed below.

## Architecture: Thin Harness, Fat Skills

ECC's heart is a single principle: **build capability into skills, not into the harness.** The harness itself, meaning the execution skeleton of the model loop, file access, permissions, and security, is kept minimal, while domain knowledge, judgment criteria, templates, and failure cases are stacked thickly into skills and rules. That is what lets the same skill work across many harnesses, whether Claude Code or Cursor.

This philosophy leads directly to two practical distinctions. First, the role separation between Rules and Skills. Rules are broad, always-applied standards and checklists, such as "test coverage of 80% or higher" or "no hardcoded secrets." They load every turn. Skills, by contrast, are execution knowledge needed deeply for a specific task, loaded only when a request calls for them. Rules define *what* to do; skills tell you *how*.

Second, rules themselves are stacked in layers. The `common/` directory holds language-agnostic universal principles (coding style, git workflow, testing, security, and so on), and above it, language-specific directories such as `typescript/`, `python/`, `golang/`, and `web/` extend or override the universal rules. Precedence works like CSS specificity or `.gitignore` rules: the more specific rule beats the more general one. For example, the universal rules recommend immutability as a default principle, but Go's language-specific rules state that struct mutation via pointer receivers is idiomatic, overriding just that point.

The overall structure looks like this.

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
<div class="d3-arch" data-arch-root id="ngclaudecodeagentharness-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1097, "height": 958, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 356, "y": 24, "w": 149, "h": 46, "title": "Developer request"}, {"id": "B", "x": 331, "y": 148, "w": 198, "h": 78, "title": ["Thin harness", "model loop, permissions,", "security"]}, {"id": "C", "x": 754, "y": 317, "w": 167, "h": 52, "title": "Loaded every turn"}, {"id": "D", "x": 874, "y": 460, "w": 170, "h": 78, "title": ["Rules", "always-on standards,", "checklists"]}, {"id": "E", "x": 649, "y": 616, "w": 135, "h": 46, "title": "Request trigger"}, {"id": "F", "x": 635, "y": 740, "w": 163, "h": 62, "title": ["Skills", "on-demand expertise"]}, {"id": "G", "x": 867, "y": 616, "w": 184, "h": 46, "title": "common universal rules"}, {"id": "H", "x": 853, "y": 740, "w": 212, "h": 62, "title": ["language rules", "specific overrides general"]}, {"id": "I", "x": 403, "y": 740, "w": 177, "h": 62, "title": ["Agents", "delegated specialists"]}, {"id": "J", "x": 284, "y": 304, "w": 170, "h": 78, "title": ["Hooks", "auto-verify pre/post", "execution"]}, {"id": "K", "x": 24, "y": 312, "w": 205, "h": 62, "title": ["MCP servers", "external tool connections"]}, {"id": "L", "x": 642, "y": 880, "w": 149, "h": 46, "title": "Consistent output"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [430, 70, 430, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[529, 206], [838, 265], [838, 265], [838, 317]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[878, 369], [959, 421], [959, 421], [959, 460]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[797, 369], [717, 421], [717, 577], [717, 616]]}, {"src": "E", "dst": "F", "kind": "data", "line": [717, 662, 717, 740]}, {"src": "D", "dst": "G", "kind": "data", "line": [959, 538, 959, 616]}, {"src": "G", "dst": "H", "kind": "data", "line": [959, 662, 959, 740]}, {"src": "B", "dst": "I", "kind": "data", "curve": [[461, 226], [492, 421], [492, 639], [492, 740]]}, {"src": "B", "dst": "J", "kind": "data", "curve": [[400, 226], [369, 265], [369, 265], [369, 304]]}, {"src": "B", "dst": "K", "kind": "data", "curve": [[331, 212], [127, 265], [127, 265], [127, 312]]}, {"src": "F", "dst": "L", "kind": "data", "line": [717, 802, 717, 880]}, {"src": "H", "dst": "L", "kind": "data", "curve": [[959, 802], [959, 841], [959, 841], [791, 884]]}, {"src": "I", "dst": "L", "kind": "data", "curve": [[492, 802], [492, 841], [492, 841], [642, 882]]}]});
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
      const container = document.getElementById('ngclaudecodeagentharness-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ngclaudecodeagentharness-1';
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

You can start to see how this structure solves the earlier "forgets rules every time" problem. Rules load automatically every session, so developers do not have to re-paste conventions. Skills load only when needed, so they do not waste the context window. Hooks verify at the code level whether a tool broke a rule. In other words, deterministic checks enforce quality rather than relying on the model's self-report.

## How You Actually Adopt It

There are two adoption paths. The easiest is to install it through the Claude Code plugin marketplace. The more direct path is to clone the repository and copy only the assets you need into your own Claude config directory. To avoid breaking the layered structure, copy at the directory level.

```bash
# Create the ECC rule namespace once.
mkdir -p ~/.claude/rules/ecc

# Copy the universal rules (required for all projects).
cp -r rules/common ~/.claude/rules/ecc/

# Copy language-specific rules matching your project stack.
cp -r rules/typescript ~/.claude/rules/ecc/
cp -r rules/golang ~/.claude/rules/ecc/
cp -r rules/web ~/.claude/rules/ecc/
```

Here the repository explicitly warns about a common mistake. Do not flatten-copy with a wildcard like `rules/common/*`. The universal and language-specific directories contain files with the same names (`coding-style.md`, `testing.md`, and so on), so flattening makes the language file overwrite the universal file and breaks the relative reference (`../common/`). To keep the hierarchy, you must copy entire directories.

MCP server configs need separate handling. Pull only the server configs you need from `mcp-configs`, but the key point is **not to enable them all at once**. The repository warns strongly here, because too many attached tools can shrink a 200k context window down to an effective 70k. Each enabled MCP server pays a schema cost every turn, so you need the hygiene of enabling only the servers you actually use.

Hooks are the core of the automation the repository emphasizes. For instance, connect a hook that runs a formatter after editing files, a hook that checks file size before commit, and a hook that verifies the production build at session end to your project's existing tool entrypoints. Hooks that run one-off remote packages are discouraged; using repo-owned local dependencies is the recommended way.

## Implications for ThakiCloud's Products

The design principles ECC raises overlap strikingly with what ThakiCloud builds. Let me split this into two lenses.

**Paxis lens (agent platform).** ThakiCloud's Paxis is an Agent-Native Cloud control plane running atop ai-platform, treating Skills, Tools, Policies, and Audit Logs as first-class resources. ECC's "thin harness, fat skills" philosophy is precisely the model Paxis productizes. Paxis's Skill Harness selects from more than 960 skills via BM25, executes them in isolated sandboxes, and passes every action through policy gates and audit logs. In other words, the layers of rules, skills, and hooks that ECC manages by hand in an individual developer's `~/.claude` directory, Paxis lifts to a multi-tenant cloud level of automatic selection, isolated execution, policy enforcement, and audit. Paxis can be seen as the operational, platform-scale form of the principles ECC validated in a personal workflow. ECC's insight that "rules load every turn and pay rent" carries straight into Paxis's design of loading skills on demand only and filtering noise via BM25.

**ai-platform lens (infrastructure).** The idea of layered rules applies just as well to infrastructure standardization. Just as ECC separates universal rules from language-specific rules, ThakiCloud's ai-platform separates organization-wide defaults from per-cluster and per-tenant overrides. Defining infrastructure standards like K8s, Kueue GPU scheduling, and vLLM serving once and applying them consistently across many customer environments, while overriding environment-specific quirks at lower layers, is the same shape as ECC's rule-precedence model. The stronger a customer's on-premises and sovereign requirements, the more the discipline of "enforce a standard defined once, yet override it safely per environment" translates into operational reliability.

In short, ECC is the essence of harness hygiene hand-crafted by an individual, and ThakiCloud builds products where the platform keeps that hygiene automatically. Low-cost serving (ai-platform) creates the economics of agents, and on top of it, skill execution with policy and audit (Paxis) creates trust.

## Limits and Counterpoints

For balance, let me note the other side. First, ECC is a config that strongly reflects one person's taste and workflow. It is the result of refining a particular TypeScript microservice for six months, so copying it wholesale onto a different stack or a different team culture can create friction instead. That is why the repository repeatedly warns not to copy-paste as-is but to adjust to your project's needs.

Second, the thicker the config, the higher the maintenance cost. Rules loading every turn means consuming tokens every turn. As you add rules and skills, you must continually ask "does this really need to be in every session?" or the context budget quietly leaks away. ECC itself addresses this with the discipline that "every line must pay rent," but keeping the discipline is ultimately a human's job.

Third, harness neutrality is an ideal, not a guarantee. The promise that the same skill works identically in Claude Code and Cursor holds only when each harness's tool surface and permission model are actually compatible. If hook execution or file-access rules differ per harness, a neutrally written skill can quietly diverge on a particular harness.

Even so, ECC's value is clear. Quality problems in AI coding tools usually arise not because the model is weak but because there is no rule-and-verification skeleton wrapping the model. ECC published that skeleton in a battle-tested form, and ThakiCloud is on the path to lifting the same principles to platform scale. For any team looking to hand code to AI, this repository's message, "inspect the harness before you swap the model," is worth keeping in mind.

## Sources

- [everything-claude-code (affaan-m/everything-claude-code), GitHub](https://github.com/affaan-m/everything-claude-code)
- Author profile related to [zenith.chat](https://zenith.chat/), the Anthropic x Forum Ventures hackathon winner
- Original tweet: @Ryrenz (RT @hjguyhan), 2026-07-20
