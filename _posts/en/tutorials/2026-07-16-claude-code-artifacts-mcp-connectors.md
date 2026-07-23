---
title: "Claude Code Artifacts Now Call MCP Connectors: Building Live, Self-Refreshing Dashboards"
seo_title: "Build Live Dashboards with Claude Code Artifacts + MCP Connectors - Thaki Cloud"
seo_description: "Claude Code artifacts can now call MCP connectors directly to fetch data and perform actions. Here's how to build a live dashboard or app that re-queries connectors every time it opens, how approval gates and access scope work, and what ThakiCloud Paxis makes of treating MCP connectors as first-class resources."
excerpt: "Artifacts used to end as static markdown. Now they're living apps that call connectors. Here's how to build a dashboard that pulls fresh data every time you open it."
date: 2026-07-16
tags:
  - claude-code
  - mcp
  - artifacts
  - connectors
  - dashboard
  - developer-tools
  - paxis
  - ai-coding
categories:
  - tutorials
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/claude-code-artifacts-mcp-connectors/"
---

Until now, Claude Code artifacts were a way to capture the work from a session and freeze it into a single shareable web page. A pull request description with an annotated diff, an incident summary, a checklist: all static outputs that preserved the state of the moment they were created. This update pushes artifacts a step further. Artifacts can now **call MCP connectors directly** to fetch data and even perform actions. In other words, instead of a page fossilized at creation time, you get a **living app that re-queries connectors every time it opens and shows the current state**. This piece is for developers who are tired of hand-coding the same internal dashboards and ops tools over and over. The short version: you can now replace a good chunk of those dashboards with a single artifact, no frontend deployment required.

## Overview

The core shift is that artifacts moved from "read-only output" to "executable client." Where an old artifact rendered a snapshot of data, a live artifact sends queries to the actual source through a connector. The use cases this unlocks are obvious: CRM pipeline views, project trackers, morning briefings, weekly metrics boards, anything where the **underlying data keeps changing**. Because it pulls fresh data on every open, nobody has to hit refresh, and no separate backend has to push data in on a cron.

MCP is the plumbing behind this picture. MCP is an open protocol that lets Claude talk to tools outside the chat window, and connectors are the one-click integrations that Anthropic and its partners have built on top of it. When an artifact calls a connector, it means the artifact can now directly read and write data in the external systems attached to that MCP server.

## What Claude Code Artifacts and MCP Connectors Are

Let's start with artifacts. An artifact turns the work from a Claude Code session into a living, shareable visual page. A pull request description with an annotated diff, a dashboard assembled from session data, a timeline that fills in as an investigation progresses: all of these can be artifacts. A live artifact goes one step further and refreshes itself. Every time it opens, it re-queries the connectors it's wired to and shows the current state.

Connectors are the integration layer built on top of MCP servers. Library connectors attach with a single click and an OAuth login from the Connectors section under Customize. Notion, Gmail, Slack, HubSpot, Linear, Canva, Atlassian, and Microsoft 365 all live there. The connector directory lists 375+ integrations spanning files, email, project management, analytics, design, sales, and developer tools.

The diagram below shows the difference in data flow between a static artifact and a live artifact.

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
<div class="d3-arch" data-arch-root id="deartifactsmcpconnectors-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 472, "height": 1058, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 147, "y": 24, "w": 191, "h": 46, "title": "User opens the artifact"}, {"id": "Q", "x": 145, "y": 148, "w": 195, "h": 52, "title": "Is it a live artifact"}, {"id": "S", "x": 277, "y": 292, "w": 163, "h": 62, "title": ["Render the snapshot", "from creation time"]}, {"id": "M", "x": 31, "y": 300, "w": 191, "h": 46, "title": "Re-query MCP connectors"}, {"id": "C1", "x": 24, "y": 432, "w": 205, "h": 62, "title": ["Connected sources:", "Notion/Slack/HubSpot etc."]}, {"id": "R", "x": 24, "y": 572, "w": 205, "h": 46, "title": "Render with current state"}, {"id": "W", "x": 33, "y": 696, "w": 188, "h": 68, "title": ["Is it a write/delete", "action"]}, {"id": "A", "x": 104, "y": 856, "w": 177, "h": 46, "title": "Ask user for approval"}, {"id": "D", "x": 31, "y": 980, "w": 191, "h": 46, "title": "Screen refresh complete"}], "edges": [{"src": "U", "dst": "Q", "kind": "data", "line": [243, 70, 243, 148]}, {"src": "Q", "dst": "S", "kind": "data", "label": "No", "curve": [[284, 200], [359, 246], [359, 246], [359, 292]], "off": "50%"}, {"src": "Q", "dst": "M", "kind": "data", "label": "Yes", "curve": [[201, 200], [127, 246], [127, 246], [127, 300]], "off": "50%"}, {"src": "M", "dst": "C1", "kind": "data", "line": [127, 346, 127, 432]}, {"src": "C1", "dst": "R", "kind": "data", "line": [127, 494, 127, 572]}, {"src": "R", "dst": "W", "kind": "data", "line": [127, 618, 127, 696]}, {"src": "W", "dst": "A", "kind": "data", "label": "Yes", "curve": [[155, 764], [193, 810], [193, 810], [193, 856]], "off": "50%"}, {"src": "W", "dst": "D", "kind": "data", "label": "No", "curve": [[98, 764], [60, 810], [60, 941], [102, 980]], "off": "50%"}, {"src": "A", "dst": "D", "kind": "data", "curve": [[193, 902], [193, 941], [193, 941], [151, 980]]}]});
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
      const container = document.getElementById('deartifactsmcpconnectors-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'deartifactsmcpconnectors-1';
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

## How It Works

The mechanics come down to three rules.

First, **it re-queries every time it opens.** A live artifact lives in its own tab in the Cowork sidebar, and every time it opens it re-queries its connectors and draws the current state. You can wire it to a single connector or stitch several together into one screen. That's where a unified dashboard pulling from multiple sources comes from.

Second, **writes and deletes go through an approval gate.** When a connector doesn't just read data but actually performs an action that changes data at the connected source, Claude is required to ask the user for approval first. It's a safeguard against automation quietly touching the source of truth. When you're configuring a tool, the first thing to check is whether approval is required for the Write and Delete tool categories.

Third, **access scope is tied to the individual.** In Team or Enterprise organizations, only owners can add a connector to the organization, but the actual connection and activation happen per user. So Claude only accesses the tools and data that user already has permission for. A notable Team and Enterprise feature: when a shared artifact is used by a teammate, no extra cost hits the person who created it.

From an enterprise administration angle, there's also a flow for provisioning connectors at the organization level. Once an admin registers a connector through an identity provider like Okta, users get connector access automatically on first login with no extra setup. Authentication is configured centrally at the organization level, and this access is shared across Claude chat, Claude Code, and Cowork.

## A Practical Setup Example

Attaching an MCP server in Claude Code takes one command and one config file. Here's the actual command for adding a local MCP server.

```bash
# Register an MCP server with Claude Code
claude mcp add my-metrics --command "python3" --args "servers/metrics_mcp.py"

# Check registered servers
claude mcp list
```

MCP servers attached to a project can be declared in `.mcp.json` at the repository root and shared with the team. The structure looks like this.

```json
{
  "mcpServers": {
    "my-metrics": {
      "command": "python3",
      "args": ["servers/metrics_mcp.py"],
      "env": { "METRICS_DB_URL": "postgres://..." }
    }
  }
}
```

For remote connectors, you use a remote MCP endpoint and an OAuth flow. Library connectors are even simpler: go to the Connectors section under Customize in the UI, click the plus button, and search for the app you want to connect. Inside the artifact, that attached connector gets called like a function to fetch data, and the result gets rendered as a dashboard component. What we need to write isn't a frontend deployment pipeline, it's a natural language instruction for which connectors to query in what order and what to draw with the result.

## Implications for ThakiCloud's Product Line

This feature is the consumer-facing version of a problem we've been working on for a long time at Paxis. Paxis is ThakiCloud's Agent-Native Cloud, and it treats skills, tools, and policies as first-class resources. One of the core pieces of that tool layer is the plumbing that **manages MCP connectors with automatic OAuth reconnection**. Anthropic's move to let artifacts call connectors points at exactly the same spot our own design already aims at: agents that talk to external systems need connectors promoted to first-class resources.

What catches our attention in particular is the **approval gate and access scope**. The way live artifacts require approval for write and delete actions and tie access to individual permissions comes from the same underlying concern as Paxis's discipline of routing every agent action through a policy gate and audit log. As connectors get more powerful, the control plane that logs what a connector touched and when, and defers risky actions behind human approval, has to get stronger right along with them. The moment an artifact becomes a live app, a single dashboard turns into an execution path toward production data.

On the infrastructure side, ai-platform is the layer that serves the MCP servers a live artifact queries, reliably, on top of K8s. Once a team exposes the data it checks often, an internal metrics MCP, a deployment status MCP, a cost MCP, as MCP servers, developers can assemble their own ops dashboards with live artifacts without writing a single line of frontend code. A low-cost, reliably served MCP backend is what makes the agent economics work, which is why ai-platform's serving layer and Paxis's connector layer move as one.

## Limitations and Counterarguments

A few things need to be clear before adoption.

First, a large part of this feature is tied to Team and Enterprise plans, and to the Cowork environment. Live artifacts and organization-managed connectors don't carry over to individual plans as-is, so the value calculation should assume org-level adoption as the baseline.

Second, the fact that a live artifact re-queries connectors every time it opens means every view generates a request against an external system. If several people are frequently opening a dashboard with heavy queries, you need to watch rate limits and cost on the source system too. There are still screens where a static snapshot is the better choice.

Third, approval gates are powerful but not a cure-all. A query that looks read-only can still pull sensitive data onto a shareable surface like an artifact. An organizational policy on what's allowed to be exposed in a shared artifact needs to come before the approval gate, not after it. The more convenient this feature gets, the more worth asking what control that convenience is bypassing. That's the safe way to use it.

## Sources

- Claude Code now supports artifacts, Anthropic: [claude.com/blog/artifacts-in-claude-code](https://claude.com/blog/artifacts-in-claude-code)
- Connect Claude Code to tools via MCP, Claude Code Docs: [code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp)
- Get started with custom connectors using remote MCP, Claude Help Center: [support.claude.com/en/articles/11175166](https://support.claude.com/en/articles/11175166)
- Anthropic Claude Code Artifacts update, VentureBeat: [venturebeat.com/data/anthropics-claude-code-artifacts-update-brings-live-shared-dashboards-and-interactive-workspaces-to-enterprises](https://venturebeat.com/data/anthropics-claude-code-artifacts-update-brings-live-shared-dashboards-and-interactive-workspaces-to-enterprises)
