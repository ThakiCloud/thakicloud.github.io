---
title: "Inside Kimi Code CLI: How an Open Source Terminal Agent Swallows Editors via ACP"
excerpt: "We dig into the open source coding CLI that Moonshot AI released alongside Kimi K3, working strictly from the official docs and repository. From coder/explore/plan sub-agents to interactive MCP configuration and its real differentiator, native Agent Client Protocol support, we verify how much of the 'features Claude Code lacks' marketing line actually holds up."
seo_title: "Kimi Code CLI and ACP Fully Explained: The Real Differentiators of an Open Source Agent CLI"
seo_description: "We verify Moonshot AI's Kimi Code CLI sub-agents, MCP, and Agent Client Protocol against the official documentation. We read the real differences from Claude Code and the on-premise self-hosting angle through the Paxis and ai-platform lens."
date: 2026-07-20
last_modified_at: 2026-07-20
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
tags:
  - agentops
  - kimi
  - moonshot
  - coding-agent
  - mcp
  - agent-client-protocol
  - paxis
  - thakicloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/kimi-code-cli-acp-open-source-agent/"
published: false
---

Last week Moonshot AI released the open-weight model Kimi K3 and took the top spot on the coding leaderboards. But something that touches developer workflows even more directly slipped out quietly alongside it: **Kimi Code CLI**, an open source terminal coding agent that Moonshot released under the MIT license. LinkedIn timelines were full of posts framing it as "features Claude Code doesn't have." We didn't take that line at face value and instead checked the official repository and documentation ourselves. The short version: half of the pitch holds up, and half is overstated. The genuinely interesting part turned out to be something the marketing didn't emphasize at all.

This post covers what Kimi Code CLI is, what it actually delivers, and why it is worth watching from the perspective of a team running a Kubernetes based AI platform. We spend a good part of it on why Agent Client Protocol, an open standard, is a piece that could reshape the agent ecosystem.

## What Kimi Code CLI Is

Kimi Code CLI is an agentic coding tool that runs in the terminal, in the same family as Claude Code, Gemini CLI, and Codex CLI. The official repository is [MoonshotAI/kimi-code](https://github.com/MoonshotAI/kimi-code), and it evolved from the earlier project [MoonshotAI/kimi-cli](https://github.com/MoonshotAI/kimi-cli), carrying existing sessions and configuration forward. Both repositories are official Moonshot projects, so be careful not to confuse them with similarly named third-party projects.

Here is the first correction worth making. The tool's official name is not "the CLI for Kimi K3" but **Kimi Code CLI**. It is not tied to a single model. By default it pairs with Moonshot's coding-specialized model, Kimi K2.7 Code, but configuration lets you switch to K3 or other models as well. K3 is one of several models the CLI can attach to, not a model the CLI was purpose-built for. K3 itself is a 2.8 trillion parameter open MoE model that Moonshot released on July 16, 2026, built around Kimi Delta Attention and up to a 1 million token context window. This launch was covered jointly by CNBC, Bloomberg, and Forbes, among other major outlets.

Establishing the full picture first makes the details land much better later. The core idea is that Kimi Code CLI plays a dual role: on one side it is an MCP client connecting to tools and data, and on the other side it is an ACP server connecting to editors.

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
<div class="d3-arch" data-arch-root id="odecliacpopensourceagent-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1443, "height": 940, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 589, "h": 124, "label": "Developer Editor (ACP Client)", "lx": 36, "ly": 42}, {"x": 581, "y": 380, "w": 443, "h": 342, "label": "Kimi Code CLI (Agent Core)", "lx": 593, "ly": 398}, {"x": 808, "y": 24, "w": 603, "h": 124, "label": "MCP Servers (Tools · Data)", "lx": 820, "ly": 42}], "nodes": [{"id": "ZED", "x": 62, "y": 63, "w": 120, "h": 46, "title": "Zed"}, {"id": "JB", "x": 237, "y": 63, "w": 142, "h": 46, "title": "JetBrains family"}, {"id": "VSC", "x": 434, "y": 63, "w": 142, "h": 46, "title": "VS Code / Neovim"}, {"id": "ACP", "x": 622, "y": 226, "w": 177, "h": 62, "title": ["Agent Client Protocol", "JSON-RPC over stdio"]}, {"id": "MAIN", "x": 619, "y": 419, "w": 184, "h": 78, "title": ["Main Agent", "Maintains conversation", "history"]}, {"id": "SUB", "x": 802, "y": 589, "w": 184, "h": 94, "title": ["Sub-agents", "coder · explore · plan", "Each with an isolated", "context"]}, {"id": "MODEL", "x": 650, "y": 814, "w": 170, "h": 94, "title": ["Model Layer", "Kimi K2.7 Code / K3", "or OpenAI-compatible", "endpoint"]}, {"id": "T1", "x": 846, "y": 63, "w": 120, "h": 46, "title": "Context7"}, {"id": "T2", "x": 1021, "y": 63, "w": 135, "h": 46, "title": "Chrome DevTools"}, {"id": "T3", "x": 1211, "y": 63, "w": 163, "h": 46, "title": "Internal connectors"}, {"id": "EDITOR", "x": 651, "y": 63, "w": 120, "h": 46, "title": "EDITOR"}, {"id": "MCP", "x": 424, "y": 613, "w": 120, "h": 46, "title": "MCP"}], "edges": [{"src": "EDITOR", "dst": "ACP", "kind": "data", "line": [711, 109, 711, 226]}, {"src": "ACP", "dst": "MAIN", "kind": "data", "label": "kimi acp", "line": [711, 288, 711, 419], "lx": 711, "ly": 330}, {"src": "MAIN", "dst": "SUB", "kind": "data", "curve": [[795, 497], [894, 543], [894, 543], [894, 589]]}, {"src": "MAIN", "dst": "MODEL", "kind": "data", "label": "inference request", "curve": [[711, 497], [711, 636], [711, 768], [723, 814]], "off": "50%"}, {"src": "SUB", "dst": "MODEL", "kind": "data", "label": "inference request", "curve": [[894, 683], [894, 722], [894, 768], [816, 814]], "off": "50%"}, {"src": "MAIN", "dst": "MCP", "kind": "data", "label": "tool call", "curve": [[681, 497], [646, 543], [646, 543], [524, 613]], "off": "50%"}]});
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
      const container = document.getElementById('odecliacpopensourceagent-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'odecliacpopensourceagent-1';
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

## Sub-agents: Splitting Context to Keep the Main Thread Clean

Kimi Code CLI ships with three built-in sub-agents. **coder** is the general engineering agent that reads and writes files and runs commands to make actual changes. **explore** is read-only and dedicated to surveying the codebase. **plan** produces implementation plans and architectural designs without running any shell commands. This split is spelled out in the official [Agents and Sub-Agents](https://moonshotai.github.io/kimi-code/en/customization/agents.html) documentation.

What matters here is not the naming but the context isolation. Each sub-agent gets a fully independent context window and sees only the task description the main agent explicitly hands it. The main agent's conversation history is never exposed to a sub-agent, and the intermediate reasoning and tool call logs a sub-agent produces never leak back into the main history. A sub-agent returns only its final conclusion. That is why the main context stays thin instead of bloating with logs over a long session. Background and parallel execution are also supported, so multiple exploration tasks can run at once and their results flow back automatically once complete.

This pattern is not unfamiliar to us. The internal orchestration harness behind this blog also delegates exploration to low-cost sub-agents and pulls back only summaries to protect the main context. The principle that context hygiene is both a cost and a quality lever holds regardless of which tool implements it.

## MCP: A Configuration Experience Without Hand-Editing JSON

Model Context Protocol integration is managed through two paths. The first is the CLI subcommand set: `kimi mcp add`, `kimi mcp list`, `kimi mcp remove`, and `kimi mcp authorize` manage servers. For example, you can attach a documentation search server over HTTP transport, or a browser automation server over stdio transport.

```bash
# HTTP transport (with optional OAuth)
kimi mcp add --transport http context7 https://mcp.context7.com/mcp

# stdio transport connecting to a local process
kimi mcp add --transport stdio chrome-devtools -- npx chrome-devtools-mcp@latest
```

The second path is the interactive slash command `/mcp-config` inside the TUI, which lets you add, edit, and authenticate servers without touching a JSON config file directly. `/mcp` shows the currently connected servers and the list of loaded tools. The claim that "you don't need to edit JSON directly," which the LinkedIn post emphasized, is accurate. That said, this convenience by itself is not something Claude Code lacks either; we return to that point later in this post. See the [MCP configuration](https://moonshotai.github.io/kimi-cli/en/customization/mcp.html) docs for details.

## Agent Client Protocol: The Most Important Piece of This Tool

This is the most interesting part of this article. Agent Client Protocol, abbreviated ACP, is an open standard built by the Zed editor team. It is Apache licensed and runs JSON-RPC 2.0 over stdio, with the editor spawning the agent as a child process and communicating through standard input and output. The transport mechanism itself is identical to the Language Server Protocol.

An analogy helps a great deal here. Before LSP existed, every editor needed a separate integration for every language. LSP turned that M-times-N problem into M-plus-N: an editor only needs to implement the standard once, and it benefits from every language server anyone builds. ACP does exactly the same thing for agents. Once an editor implements ACP, any agent built by anyone plugs into it through a standard interface. This concept is explained in [Zed's introduction to ACP](https://zed.dev/acp) and in [Marc Nuri's write-up](https://blog.marcnuri.com/agent-client-protocol-acp-introduction).

It is easy to confuse ACP with MCP, but the direction is reversed. MCP flows from the agent toward tools and data, with the agent acting as the MCP client. ACP flows from the editor toward the agent, with the agent acting as the ACP server and the editor acting as the ACP client. The same agent can play the MCP client role on one side and the ACP server role on the other at the same time, which is exactly why the diagram above draws that dual role.

Kimi Code CLI supports this protocol natively through the `kimi acp` subcommand, with no separate installation required. Zed connects natively, JetBrains connects through a plugin, and based on Zed's ACP registry, several other editor integrations are already listed. Developers can drive a Kimi session without ever leaving the editor they already use.

## Image and Video Input: What Actually Works

The LinkedIn post claimed you can "feed a screen capture directly as input." This needs a correction. The feature Moonshot actually markets front and center is not a static screenshot but **screen recording video input**. The repository description says that dropping a screen recording or demo clip into the chat lets the agent directly see and understand behavior that's hard to describe in words. Pasting images into the CLI input is also supported, and the default model, Kimi K2.7 Code, is natively multimodal with a 400 million parameter vision encoder called MoonViT, so it accepts text, images, and video all together. That said, when you attach a custom model, that model's modalities must explicitly declare image support for this to work correctly. To summarize, image input does work, but the feature actually marketed as the real differentiator is video input, and the word "screenshot" is somewhat inaccurate here.

## Installation Is Really Three Steps

The installation flow is as simple as advertised. The commands below follow the [official getting started guide](https://moonshotai.github.io/kimi-cli/en/guides/getting-started.html). Our internal sandbox does not have access to the relevant distribution domain, so we did not run these ourselves and are not logging execution output. We are not fabricating any benchmark numbers here; we are only citing verified commands.

```bash
# 1) Run the install script (also installs uv)
curl -LsSf https://code.kimi.com/install.sh | bash

# 2) Run it from your project directory
kimi

# 3) Set up authentication
/login
```

macOS also supports `brew install kimi-code`, and Windows has a PowerShell script. Building from source requires Node 24.15 or later and pnpm. The license is MIT, which puts few restrictions on reading the code, forking it, or deploying it internally.

## Model and Provider Openness

Context length tops out at 256,000 tokens for the K2.6 line, and Moonshot's marketing claims up to 1 million tokens for K3. More important is provider openness. In `~/.kimi-code/config.toml` you can register multiple providers, including OpenAI-compatible endpoints, an Anthropic API key, and Google GenAI or Vertex AI. That means the CLI is not locked into a single model. It also automatically handles the `reasoning_content` field from third-party reasoning models. See [Providers and models](https://moonshotai.github.io/kimi-cli/en/configuration/providers.html) for the details.

## Is This a Feature Claude Code Lacks? An Honest Comparison

The most widely circulated pitch was "this gives you features Claude Code doesn't have." After verifying it, that framing turns out to be mostly overstated.

Sub-agents and context isolation are already offered by Claude Code through its own sub-agent feature, in the same way. MCP is also mature in Claude Code, which already supports stdio, SSE, and HTTP transports. Image pasting exists in Claude Code as well. None of these three are actual differentiators.

The real differences sit in two places. First, how ACP support is delivered. Kimi Code CLI bakes ACP into the CLI itself as a first-class feature through the `kimi acp` subcommand. Claude Code, by contrast, connects through a separate adapter package built by Zed, currently in beta. From a user's perspective, the former just works once you turn it on, while the latter requires bolting on an additional bridge. Second, model openness. Kimi is open across its open-weight K series with the ability to switch providers, while Claude Code is limited to Anthropic's own models. A third difference follows from this: self-hosting potential. Kimi combines an open source CLI with open-weight models, making on-premise serving possible, whereas Claude Code has an open CLI but a model that is API-only. The relevant evidence is in [Zed's post on the Claude Code ACP beta](https://zed.dev/blog/claude-code-via-acp).

## Implications for ThakiCloud's Products

This topic touches both the agent tooling axis and the open model and on-premise infrastructure axis, so we apply two lenses together.

Through the Paxis lens, Kimi Code CLI's structure overlaps quite a bit with our product's design direction. Paxis is ThakiCloud's Agent-Native Cloud control plane, treating skills, tools, policies, and audit logs as first-class resources. The way Kimi's coder, explore, and plan sub-agents run in parallel with isolated contexts shares the same underlying philosophy as the way Paxis's skill harness selects among more than 960 skills with BM25 and runs them in isolated sandboxes. ACP in particular, as a vendor-neutral standard, is a direct opportunity for Paxis. Any agent we deploy, including ones running our own fine-tuned models, could plug into a customer's development editor such as Zed or JetBrains through a standard interface simply by implementing ACP. The combination of MCP for connecting to data and ACP for connecting to editors is exactly the kind of integrated picture we are aiming for.

Through the ai-platform lens, openness translates directly into deployment freedom. Running an open-weight K-series model on top of our cluster's Kueue GPU scheduling and vLLM serving, and routing the CLI to an internal endpoint, would let us build an internal coding agent without depending on an external API or exporting data outside our environment. That aligns well with on-premise security requirements in domains like finance or the public sector where code cannot leave the organization, including requirements tied to Korea's National Intelligence Service. As capability becomes commoditized and cheaper, what enterprises actually end up paying for is a controlled execution environment, a point we have made in earlier posts as well. Kimi Code CLI matters precisely because it opens up that execution layer as open source.

## Caveats and Counterarguments

A few things deserve a colder look. First, some third-party deep dives reference internal engine names or layer structures that don't appear in the official documentation, which suggests they may be the product of reverse engineering. It is safer to treat the official docs as the source of truth before citing those as fact. Second, there are community reports that the ACP path produces better response quality than other connection methods, but this is anecdotal rather than benchmarked, and we don't treat it as verified data. Third, even with open weights, actually serving a 2.8 trillion parameter class model on-premise requires substantial GPU resources. Openness does not automatically mean easy self-hosting, and the API route remains the practical choice for small teams. Fourth, the maturity and stability of the tooling ecosystem may still favor Claude Code or Codex CLI. Being open source does not by itself mean production ready.

## Conclusion

Even so, the direction toward agents and editors loosely coupled through open standards is a clear trend. A world where developers aren't locked into a single vendor's CLI, and can swap out the model and the editor independently, is a better world for developers. Kimi Code CLI is one of the pieces bringing that world closer.

## Sources

- [MoonshotAI/kimi-code (official repository)](https://github.com/MoonshotAI/kimi-code)
- [MoonshotAI/kimi-cli (previous repository)](https://github.com/MoonshotAI/kimi-cli)
- [Kimi Code CLI getting started guide](https://moonshotai.github.io/kimi-cli/en/guides/getting-started.html)
- [Agents and Sub-Agents documentation](https://moonshotai.github.io/kimi-code/en/customization/agents.html)
- [MCP configuration documentation](https://moonshotai.github.io/kimi-cli/en/customization/mcp.html)
- [Zed - Agent Client Protocol](https://zed.dev/acp)
- [ACP: The LSP for AI Coding Agents](https://blog.marcnuri.com/agent-client-protocol-acp-introduction)
- [Zed - Claude Code via ACP (beta)](https://zed.dev/blog/claude-code-via-acp)
- [MarkTechPost - Kimi K3 launch](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
