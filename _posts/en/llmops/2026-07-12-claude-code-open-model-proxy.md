---
title: "Connecting Claude Code to Self-Hosted Open Models: Inside the free-claude-code Proxy"
excerpt: "Coding agents like Claude Code and Codex are tied to the Anthropic API. free-claude-code sits an Anthropic-compatible proxy in between, letting teams keep the same agent UI while routing requests to self-hosted backends such as Ollama, llama.cpp, and vLLM. We examine the real repository, how it lets you pick from 24 backends in an Admin UI and route Opus, Sonnet, and Haiku traffic to different models, and what this means for ThakiCloud from an on-premise coding agent perspective."
tags:
  - llmops
  - claude-code
  - proxy
  - self-hosting
  - ollama
  - vllm
  - agent
  - paxis
date: 2026-07-12
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/claude-code-open-model-proxy/"
categories:
  - llmops
published: false
---

## Overview

Claude Code and Codex have become the most widely used coding agents inside terminals and IDEs over the past year. The problem is that both are tightly coupled to their respective cloud APIs, Anthropic and OpenAI. For teams that cannot let source code leave the building under internal policy, teams working in air-gapped networks, or teams already serving open-weight models on their own GPUs, that coupling becomes a hard wall.

This piece is for engineering leaders weighing the operating cost and data sovereignty of coding agents, and for practitioners looking to serve models on-premise. We examined `free-claude-code`, an open source proxy that has been getting attention in developer communities recently, directly from its repository. The project is known for a somewhat provocative pitch about "killing the subscription," but the technically interesting part is elsewhere. It preserves the user experience of a proven agent, Claude Code, while swapping out only the model behind it for your own infrastructure.

To put it plainly upfront: the core value of this proxy isn't "free," it's "isolation." Separating the agent UI from the model backend lets you move the same workflow onto an open model running on in-house GPUs. We look at why that separation matters from the standpoint of running on-premise AI infrastructure, and at the limitations that come with it.

## What This Tool Is

`free-claude-code` is a local proxy server built on FastAPI. It exposes an endpoint compatible with the Anthropic API, so the Claude Code CLI, Codex CLI, VS Code extensions, JetBrains ACP, and even some chatbots mistake it for a genuine Anthropic server and connect to it directly. From the agent's point of view nothing has changed; only the model actually handling the request gets swapped out behind the scenes.

The breadth of supported backends is what stands out about this project. According to the repository, it supports 24 providers across cloud and local, switchable from the Admin UI, spanning cloud APIs like NVIDIA NIM, OpenRouter, and DeepSeek alongside local runtimes like LM Studio, llama.cpp, and Ollama. In other words, you can point it at a commercial API or at an open model running on your own GPU.

The routing structure is more than a simple switch, too. Internally, Claude Code splits work across three model tiers depending on the situation: Opus, Sonnet, and Haiku. Heavy reasoning goes to Opus, everyday tasks go to Sonnet, and light exploration goes to Haiku. `free-claude-code` lets you map each of these three tiers, plus fallback traffic, to a different backend model. Streaming, tool use, and reasoning support are preserved within the range of what the target model supports. This tier-based routing lines up exactly with a principle already in use inside ThakiCloud: send exploration to a cheap model, implementation to a mid-tier model, and reserve the expensive model for architectural judgment calls.

The overall request flow looks like this.

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
<div class="d3-arch" data-arch-root id="claudecodeopenmodelproxy-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 720, "height": 648, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 368, "y": 24, "w": 205, "h": 78, "title": ["Coding agent", "Claude Code / Codex / IDE", "extension"]}, {"id": "B", "x": 378, "y": 180, "w": 184, "h": 94, "title": ["free-claude-code proxy", "FastAPI,", "Anthropic-compatible", "endpoint"]}, {"id": "C", "x": 504, "y": 352, "w": 184, "h": 94, "title": ["Admin UI", "127.0.0.1:8082/admin", "provider selection and", "validation"]}, {"id": "D", "x": 240, "y": 357, "w": 209, "h": 84, "title": ["Tier-based routing", "Opus / Sonnet / Haiku /", "fallback"]}, {"id": "E", "x": 495, "y": 538, "w": 191, "h": 78, "title": ["Cloud backends", "OpenRouter / DeepSeek /", "NIM"]}, {"id": "F", "x": 249, "y": 538, "w": 191, "h": 78, "title": ["Local runtimes", "Ollama / llama.cpp / LM", "Studio"]}, {"id": "G", "x": 24, "y": 546, "w": 170, "h": 62, "title": ["On-prem vLLM", "in-house GPU cluster"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [470, 102, 470, 180]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[539, 274], [596, 313], [596, 313], [596, 352]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[402, 274], [345, 313], [345, 313], [345, 357]]}, {"src": "D", "dst": "E", "kind": "data", "label": "Heavy reasoning", "curve": [[449, 439], [591, 492], [591, 492], [591, 538]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "Everyday tasks", "line": [345, 441, 345, 538], "lx": 345, "ly": 488}, {"src": "D", "dst": "G", "kind": "data", "label": "Self-hosted serving", "curve": [[240, 440], [109, 492], [109, 492], [109, 546]], "off": "50%"}]});
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
      const container = document.getElementById('claudecodeopenmodelproxy-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'claudecodeopenmodelproxy-1';
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

The difference from the existing approach is clear. Until now, running a coding agent on an open model meant either forking the agent itself or hand-building a different API shim for every model. This proxy collapses that translation layer into one place, leaving the agent untouched while only the model changes.

## Installation and Integration

The repository offers two installation paths. One is downloading and running the install script in a single command.

```bash
curl -fsSL "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh?raw=1" | sh
```

This script provisions `free-claude-code` itself along with `uv` and Python 3.14. If Claude Code and Codex aren't already installed, it installs them too, which means Node.js needs to already be in place since that step requires npm. Running the same command again acts as an update.

If you prefer a manual install, you can clone the repository directly and prepare the environment file instead.

```bash
git clone https://github.com/Alishahryar1/free-claude-code.git
cd free-claude-code
cp .env.example .env
pip install uv
```

Once the proxy is running, open the local-only Admin UI in a browser to pick providers and validate the connection.

```text
http://127.0.0.1:8082/admin
```

From this screen you enter each provider's key, check the connection status, and decide which model goes into the Opus, Sonnet, Haiku, and fallback slots. Once that's set, all you need is to point Claude Code's API base address at this proxy. From there you keep using the Claude Code commands you're used to, but the actual inference happens on the backend you specified.

## How It Actually Works, and What We Verified

For this analysis we checked the repository's public documentation and install script directly to verify the commands and structure above. We did not, however, measure actual inference latency or accuracy across all 24 backends. A meaningful serving benchmark needs to be run against an open model actually loaded on your own GPU, and the environment used to write this piece had no local GPU, so we could not carry out a full round-trip measurement across every backend. To avoid inventing numbers, we left unverified latency or throughput figures out of this piece.

What we can verify structurally is nonetheless clear. Because the proxy exposes an Anthropic-compatible endpoint, the agent has no need to know what the backend actually is. As long as that contract holds, switching the backend from Ollama to an in-house vLLM deployment is just reassigning one slot in the Admin UI. No agent reinstall, no workflow change required. This switching cost being close to zero is the real strength of this architecture.

We should also record the sober fact on quality. Coding quality when connected to an open model is not the same as with Anthropic's top-tier model. In particular, gaps against the leading commercial model can show up in long tool-call chains or complex refactoring. So it's more accurate to think of this proxy not as "a free tool that keeps the quality" but as "a tool that lets your team choose the tradeoff between quality and sovereignty for itself."

## Implications for ThakiCloud's Products

The question this tool raises lines up directly with problems ThakiCloud is already addressing through two products.

First, from the **Paxis** angle. Paxis is ThakiCloud's control plane for the Agent-Native Cloud, treating skills, tools, policy, and audit logs as first-class resources. The separation between agent UI and model backend that `free-claude-code` demonstrates is a small-scale version of the direction Paxis is heading. In Paxis, model routing for coding agents doesn't have to be picked by hand in a local Admin UI by each individual; it can be governed by an organization-wide policy gate. Which team's requests go to which backend, whether code from a sensitive repository is forced through an in-house model only, all of that gets recorded as policy and audit logs. If a proxy changes individual productivity, Paxis takes that same principle and lifts it to organizational governance. Add MCP connectors and isolated sandbox execution on top, and even external tool calls fall inside the scope of control.

Second, from the **ai-platform** angle. The fact that this proxy supports Ollama and llama.cpp as local runtimes means, in the end, that someone has to serve that open model reliably. Ollama on a personal laptop is fine for a demo, but it can't handle the load of an entire team running a coding agent all day. ThakiCloud's ai-platform schedules GPUs on K8s and Kueue and serves open models in a multi-tenant environment with vLLM. Route coding agent traffic through this serving layer, and you can run a team-scale on-premise coding agent without the ceiling of individual hardware. Low serving cost and the ability to handle air-gapped environments become the competitive edge here.

The two lenses complement each other. When ai-platform serves open models cheaply and reliably, Paxis governs the agent traffic on top of it with policy and audit. Low-cost serving is what makes the agent economical, and governance is what turns that economy into something an organization can trust.

## Limitations and Counterarguments

First, the terms of service issue needs to be said plainly. Using clients like Claude Code or Codex in a way that circumvents a paid subscription can run into conflict with each service's terms of use. The use case this piece considers meaningful is strictly the on-premise scenario of routing traffic to your own open models or a legitimately contracted API backend, not unauthorized bypass of a paid service. Any organization adopting this needs to check each client's terms of service first.

Second, the attack surface widens. A proxy, by definition, sits in a position to intercept all traffic between agent and model, meaning your source code and full prompts. An untrustworthy proxy configuration can become a code leak path. The benefit only holds if you run it inside your own infrastructure, in an auditable way. This is exactly why Paxis's policy gates and audit logs matter.

Third, there's a quality and maintenance burden. As noted above, coding quality on open models differs from the top commercial model, and supporting 24 backends also means being that much more exposed to upstream API changes. When Anthropic or any individual provider changes its API contract, the proxy has to keep up. Loading an organization's core workflow entirely onto maintenance at the level of a personal project is risky.

To sum up, `free-claude-code` is worth more when read as "an open source experiment separating a coding agent's model layer" than under the banner of "free Claude Code." When that separation meets on-premise serving, it opens a realistic path to running a team-scale coding agent while keeping data sovereignty intact. What ThakiCloud is building with ai-platform and Paxis is exactly the work of letting an organization walk that path safely.

## Sources

- free-claude-code repository: [github.com/Alishahryar1/free-claude-code](https://github.com/Alishahryar1/free-claude-code)
- Install script: [scripts/install.sh](https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh)
