---
title: "Coding with Kimi K3: Wiring a 2.8T Open Model into the OpenCode Terminal Agent"
seo_title: "Coding with Kimi K3 + OpenCode in the Terminal - Thaki Cloud"
seo_description: "How to connect Kimi K3, Moonshot AI's 2.8-trillion-parameter open MoE model, to OpenCode, an open-source terminal coding agent. We install OpenCode 1.18.3, walk the provider auth and model-selection flow first-hand, and read the implications for ThakiCloud's ai-platform (serving a 2.8T open model on-prem) and Paxis (an Agent-Native Cloud where the coding brain is swappable)."
excerpt: "Kimi K3, called Fable 5-class by many, can run inside an open-source terminal agent rather than a locked proprietary IDE. We installed OpenCode to verify the provider connection flow end to end."
date: 2026-07-18
tags:
  - kimi-k3
  - opencode
  - moonshot-ai
  - coding-agent
  - open-weight
  - terminal
  - developer-tools
  - paxis
  - ai-coding
categories:
  - tutorials
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/kimi-k3-opencode-coding/"
---

For the past few days, developer timelines have been full of "how to code with Kimi K3" threads.
The reactions split two ways. One is that the benchmarks are genuinely strong. The other is that
you can run this model from your own terminal, inside a coding agent you chose, rather than a single
company's closed tool. This post is about the second reaction. The reader we have in mind is a
developer who would rather swap models into an open-source tool than get locked into a vendor's GUI.
The short version: connect Moonshot AI's Kimi K3 as a provider to the open-source terminal agent
OpenCode, and you can code with a 2.8-trillion-parameter-class model without being tied to any one IDE.

## Overview

Moonshot AI released Kimi K3 on July 16, 2026. Per the company, it is a 2.8-trillion-parameter
Mixture-of-Experts model and among the largest open-weight models released to date. The interesting
part is not just the scores. This model is not confined to a proprietary chatbot; it connects as a
provider to an open-source coding agent that runs in the terminal. In other words, "which IDE you use"
and "which model you code with" can now be decoupled.

From ThakiCloud's vantage point, this pairing matters for two reasons. First, a coding agent that can
freely swap models instead of being vendor-locked lines up with the core premise of agent-platform
design. Second, a 2.8-trillion-parameter open-weight model has to be served on real GPUs by someone,
and that serving cost and on-prem requirement come straight back as infrastructure questions. Below we
install the tool first-hand to confirm the connection flow, then work through both perspectives.

## What Are These Tools

OpenCode is an open-source coding agent that runs in the terminal. It reads files in a codebase,
explains structure, edits code, reviews changes, and runs tasks through a connected LLM provider.
Because it is not bound to a single model and instead swaps providers, you can keep the same workflow
and change only the model underneath.

Kimi K3 is the model that goes in that provider slot. Per Moonshot AI's announcement, the key specs
are as follows. It is a 2.8-trillion-parameter MoE, with 16 of 896 experts activated per token.
Attention uses Kimi Delta Attention (KDA), a hybrid linear attention scheme. On top of that it adds
Attention Residuals (a replacement for residual connections), native vision understanding, and up to a
1-million-token context window. Full model weights are scheduled to release on July 27, 2026.

The flow that connects the two tools looks like this.

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
<div class="d3-arch" data-arch-root id="0718kimik3opencodecoding-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 362, "height": 870, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 57, "y": 24, "w": 163, "h": 62, "title": ["Developer terminal", "OpenCode TUI or run"]}, {"id": "B", "x": 133, "y": 164, "w": 163, "h": 62, "title": ["Provider layer", "opencode auth login"]}, {"id": "C", "x": 100, "y": 304, "w": 230, "h": 68, "title": ["Model selection", "/models or opencode models"]}, {"id": "D", "x": 130, "y": 464, "w": 170, "h": 62, "title": ["Moonshot AI provider", "Kimi K3"]}, {"id": "E", "x": 116, "y": 604, "w": 198, "h": 78, "title": ["Kimi Delta Attention", "2.8T MoE · 896 experts ·", "16 active per token"]}, {"id": "F", "x": 33, "y": 760, "w": 212, "h": 78, "title": ["Read · edit · review · run", "code", "up to 1M context"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[172, 86], [215, 125], [215, 125], [215, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [215, 226, 215, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [215, 372, 215, 464]}, {"src": "D", "dst": "E", "kind": "data", "line": [215, 526, 215, 604]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[215, 682], [215, 721], [215, 721], [177, 760]]}, {"src": "F", "dst": "A", "kind": "event", "label": "session loop", "curve": [[101, 760], [62, 565], [62, 265], [105, 86]], "off": "50%"}]});
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
      const container = document.getElementById('0718kimik3opencodecoding-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0718kimik3opencodecoding-1';
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

The difference from the usual approach is clear. A vendor's GUI agent ships the model and the tool as
one bundle. An open-source agent like OpenCode fixes the tool and swaps only the provider. A
self-hosted model yesterday, Kimi K3 today, a different model tomorrow, all through the same command
interface.

## Installation and Integration

We verified the install and connection flow first-hand in an isolated sandbox. The commands and
versions below are actual values captured during reproduction.

First install OpenCode. A global npm install worked immediately.

```bash
npm install -g opencode-ai
opencode --version
# 1.18.3
```

We checked the command surface the installed CLI exposes. From launching the TUI to headless
execution, provider management, model listing, and MCP server management, it covers what a coding
agent needs.

```bash
opencode --help
# opencode [project]        start opencode tui              [default]
# opencode run [message..]  run opencode with a message
# opencode providers        manage AI providers and credentials   [aliases: auth]
# opencode models [provider]  list all available models
# opencode mcp              manage MCP (Model Context Protocol) servers
# opencode agent            manage agents
# opencode serve            starts a headless opencode server
```

Provider authentication is handled by the `opencode auth` subcommands.

```bash
opencode auth --help
# opencode auth list    list providers and credentials   [aliases: ls]
# opencode auth login   log in to a provider
# opencode auth logout  log out from a configured provider
```

The order for wiring in Kimi K3 is as follows, per Moonshot AI's official OpenCode guide.

1. Create an API key on the Kimi Open Platform and keep it private.
2. Run `opencode auth login`, select **Moonshot AI** as the provider, and enter your API key.
3. Inside OpenCode, use `/models` (or `opencode models moonshotai` in the shell) to select **Kimi K3**.
4. Verify the connection with a low-risk task.

```bash
opencode run "Explain this project's folder structure and recommend the first three files I should read."
```

One fact worth pinning down: right after install, the default model catalog did not include the
Moonshot provider. During reproduction, filtering `opencode models` for Moonshot/Kimi returned nothing,
which means the provider has to be added explicitly via `auth login` before it shows up in the catalog.
So step 2 above is not optional; it is required.

## Actual Results

We separate values we captured directly from the model's published figures. The tool install and
connection flow are measured first-hand; the benchmark scores are reported figures from Moonshot and a
third party (Artificial Analysis).

Directly measured results:

- OpenCode install succeeded, version 1.18.3 (npm `opencode-ai`, exit code 0).
- Confirmed the CLI provides provider auth (`auth`), model listing (`models`), headless run (`run`),
  MCP management (`mcp`), and agent management (`agent`).
- Right after install, the default catalog did not include the Moonshot provider, so it must be added
  explicitly via `auth login`.

We did not run live Kimi K3 inference. Calling Kimi K3 requires a paid API key with balance (vouchers
from new-user verification cannot be used for K3), and this reproduction environment did not have such a
key. So we draw the line at "install and connection flow measured, actual code-generation quality cited
from public figures." We do not invent numbers we did not observe.

The model's published benchmarks are below. These scores are reported figures per Artificial Analysis,
and because weights are not yet fully public, they have not been verified by independent reproduction.

| Benchmark | Kimi K3 | Rank | Top / comparison models |
|---|---|---|---|
| GDPval-AA v2 | 1,687 | 3rd | Fable 5 Max 1,815 · GPT-5.6 Sol Max 1,747.8 · (Opus 4.8 1,600) |
| AA-Briefcase | 1,527 | 2nd | Fable 5 Max 1,587 · GPT-5.6 Sol Max 1,495 |

Read at face value, Kimi K3 sits in the band just below the top frontier models. Placing 2nd on
AA-Briefcase, which is meant to measure long-horizon knowledge work, is a signal that it can hold up on
multi-step agent tasks like coding. That said, these are reported figures, and the actual feel in a real
coding workflow is best verified against your own codebase.

## Implications for ThakiCloud

This pairing touches both of ThakiCloud's product lenses. One is the agent-platform lens, the other is
the infrastructure serving lens.

**Paxis lens (agents, tools, swappable models).** Paxis is ThakiCloud's Agent-Native Cloud control
plane that treats Skills, Tools, Policies, and Audit Logs as first-class resources. The "fix the tool,
swap the provider" structure that OpenCode demonstrates overlaps exactly with the Paxis design
philosophy. In Paxis, a coding agent selects from 960-plus skills via BM25, runs them in isolated
sandboxes, and passes every action through policy gates and audit logs. Attach an open-weight model like
Kimi K3 as the provider, and you can swap the agent's brain by cost and performance while keeping
execution isolation and auditing intact. The fact that OpenCode has built-in MCP server management
(`opencode mcp`) also connects naturally to how Paxis treats MCP connectors as first-class resources.

**ai-platform lens (serving a 2.8T model).** Open-weight means someone has to serve this model on real
GPUs. A 2.8-trillion-parameter MoE only activates 16 experts per token, so active parameters are far
smaller than the total, but the structure still requires holding all 896 experts in memory, so the bar
for on-prem serving is not low. This is where ThakiCloud's ai-platform answers the question. When
K8s- and Kueue-based GPU scheduling, vLLM/SGLang serving, and quantization for memory savings come
together, large open models like this can run economically in a multi-tenant environment. Once the
weights ship on July 27, the cost curve of self-hosting versus API calls can be compared for real. Lower
serving cost translates into agent economics, which in turn lowers the per-run cost of agents running on
Paxis. Both lenses point in the same direction.

## Limits and Counterarguments

A few sober counterpoints are worth stating.

First, benchmark scores and actual coding feel are different. A 2nd place on AA-Briefcase does not
guarantee "best on my codebase." A top-ranked model can be weaker on a specific language, framework, or
in-house convention, so adoption should be verified against your real work.

Second, this post's measurements go up to install and connection flow. Live Kimi K3 inference was not
run because of the paid API key constraint. Actual generation quality, latency, and token cost remain
things you have to re-measure with your own key.

Third, "open weight" does not mean "free" or "easy to operate." Even with weights public, serving a
2.8T MoE stably requires substantial GPU resources and operational skill. The break-even between
self-hosting and API calls depends on usage and latency requirements.

Fourth, the Kimi K3 API needs balance, and new-user vouchers cannot be used for K3. Do not expect
unlimited free use of a top-tier model. Even so, the structural freedom to choose tool and model
independently is a stronger long-term position than being locked to a single vendor.

## Sources

- [MarkTechPost, "Moonshot AI Releases Kimi K3: A 2.8 Trillion Parameter Open MoE Model With Kimi Delta Attention and 1M Context" (2026-07-16)](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
- [Fortune, "Moonshot's Kimi K3 pushes Chinese AI into Fable-level territory" (2026-07-16)](https://fortune.com/2026/07/16/moonshots-kimi-k3-pushes-chinese-ai-into-fable-level-territory/)
- [Artificial Analysis, "Kimi K3" model page (source for the GDPval-AA v2 and AA-Briefcase benchmark figures in this post)](https://artificialanalysis.ai/models/kimi-k3)
- [Kimi API Platform, "Use Kimi Models in OpenCode"](https://platform.kimi.ai/docs/guide/open-code)
- [OpenCode (sst/opencode), v1.18.3 release](https://github.com/sst/opencode)
- [Simon Willison, "Kimi K3, and what we can still learn from the pelican benchmark" (2026-07-16)](https://simonwillison.net/2026/Jul/16/kimi-k3/)
- VentureBeat, "China's Moonshot AI releases Kimi K3, the largest open-source model ever" (article exists; URL response not confirmed this session)
- OpenCode 1.18.3 (`npm install -g opencode-ai`): commands and version are directly captured reproduction values
