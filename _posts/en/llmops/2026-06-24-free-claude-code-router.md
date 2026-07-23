---
title: "Connecting Claude Code to Self-Hosted Models with free-claude-code: A Real-World Test of a 17-Provider Routing Proxy"
excerpt: "free-claude-code (36.7k stars) intercepts Claude Code traffic through an Anthropic-compatible FastAPI proxy and routes it to 17 providers. This report documents direct routing to a local Ollama backend with latency measurements, and honestly records the deployment risk introduced by a hard Python 3.14 requirement."
seo_title: "free-claude-code Self-Hosted Routing - Claude Code Multi-Provider Proxy - Thaki Cloud"
seo_description: "A hands-on record of routing Claude Code to self-hosted models such as Ollama and vLLM using free-claude-code. Covers the Anthropic-compatible FastAPI proxy architecture, local Ollama latency measurements, and the deployment risk from a hard Python 3.14 requirement, analyzed from the perspective of ThakiCloud's Kubernetes environment."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - free-claude-code
  - Claude Code
  - LLM Gateway
  - Model Routing
  - Ollama
  - vLLM
  - Self-Hosting
  - FastAPI
  - LLM Ops
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/free-claude-code-router/"
categories:
  - llmops
published: false
---

## Overview

Claude Code is a powerful coding agent. However, because every request goes directly to the Anthropic API, it creates a constraint for organizations that need to control costs or keep data within their own boundaries. The recently trending `free-claude-code` project addresses this exact point. It is a proxy layer that intercepts Claude Code traffic and routes it to 17 different providers. It is an MIT-licensed project with 36.7k GitHub stars, 5.7k forks, and 712 commits.

The project's marketing tagline is "Claude Code forever free." The approach routes traffic to free or low-cost tier providers, and this framing is frankly overstated in some respects and sits in a gray area from a Terms of Service perspective. This article therefore focuses not on the "free" angle, but on what this tool means for organizations like ThakiCloud that **serve their own models on Kubernetes and want to connect Claude Code to their own infrastructure**. The key points are that code and prompts never leave the tenancy boundary, per-token cloud billing disappears, and no client-side modifications are needed because the endpoint is Anthropic-compatible.

> Note: A previous article, "Routing Claude Code to In-House Models - claude-code-router," focused on **cost arbitrage** between cloud models (glm, MiniMax, Kimi). This article is about a different tool (`free-claude-code`), covering the connection to **self-hosted backends (Ollama, vLLM)** — not cloud models — and the deployment risks that surfaced in the process.

## What This Tool Does

`free-claude-code` is a local proxy server that receives requests sent by Claude Code (and Codex). Its core feature is that it **exactly mimics an Anthropic-compatible endpoint**. From the client's perspective, it is indistinguishable from the real Anthropic API, so the backend can be swapped without changing a single line of Claude Code.

The server is written in FastAPI and exposes the following endpoints:

- `/v1/messages` - Anthropic Messages API compatible (the primary path for Claude Code)
- `/v1/models` - Model listing
- `/v1/responses` - OpenAI Responses API compatible (for Codex; internally converted to Messages)

When a request arrives, a **model router** decides which provider to send it to, and a **normalizer** transforms thinking blocks, tool_calls, and error responses into the shape each client expects. Because response formats differ across providers, this normalization layer is where the real complexity lies.

To elaborate on why normalization is difficult: Claude Code assumes Anthropic's own response structure. For instance, reasoning steps arrive as `thinking` blocks and tool calls as `tool_use` content blocks. DeepSeek, however, exports reasoning as a separate field, and OpenAI-compatible providers return tool calls as a `tool_calls` array. Even though they all mean "a tool was called," the wire format differs in each case. The normalizer must absorb these differences and ensure Claude Code receives identically shaped responses regardless of which backend is used. The Codex path (`/v1/responses`) goes one step further, converting OpenAI Responses requests internally to Anthropic Messages before sharing the same router, normalizer, and provider adapters. This means protocol conversion happens in both directions — the key distinction between a simple reverse proxy and a routing proxy.

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
<div class="d3-arch" data-arch-root id="0624freeclaudecoderouter-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 486, "height": 920, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "CC", "x": 281, "y": 24, "w": 120, "h": 62, "title": ["Claude Code", "(client)"]}, {"id": "CX", "x": 60, "y": 24, "w": 120, "h": 62, "title": ["Codex", "(client)"]}, {"id": "FP", "x": 166, "y": 320, "w": 128, "h": 62, "title": ["FastAPI Proxy", "(local server)"]}, {"id": "EP1", "x": 256, "y": 172, "w": 170, "h": 62, "title": ["/v1/messages", "Anthropic-compatible"]}, {"id": "EP2", "x": 38, "y": 164, "w": 163, "h": 78, "title": ["/v1/responses", "OpenAI-compatible →", "converted"]}, {"id": "MR", "x": 133, "y": 460, "w": 195, "h": 84, "title": ["Model Router", "MODEL_OPUS / SONNET /", "HAIKU"]}, {"id": "NZ", "x": 138, "y": 622, "w": 184, "h": 78, "title": ["Normalizer", "(thinking · tool_use ·", "error transform)"]}, {"id": "CLOUD", "x": 249, "y": 778, "w": 205, "h": 110, "title": ["Cloud Providers", "NVIDIA NIM · OpenRouter ·", "Gemini", "DeepSeek · Mistral · Groq", "+ 8 more"]}, {"id": "SELF", "x": 24, "y": 794, "w": 170, "h": 78, "title": ["Self-hosted Backends", "Ollama · LM Studio", "llama.cpp / vLLM"]}], "edges": [{"src": "CC", "dst": "EP1", "kind": "data", "line": [341, 86, 341, 172]}, {"src": "CX", "dst": "EP2", "kind": "data", "line": [120, 86, 120, 164]}, {"src": "EP1", "dst": "FP", "kind": "data", "curve": [[341, 234], [341, 281], [341, 281], [279, 320]]}, {"src": "EP2", "dst": "FP", "kind": "data", "curve": [[120, 242], [120, 281], [120, 281], [181, 320]]}, {"src": "FP", "dst": "MR", "kind": "data", "line": [230, 382, 230, 460]}, {"src": "MR", "dst": "NZ", "kind": "data", "line": [230, 544, 230, 622]}, {"src": "NZ", "dst": "CLOUD", "kind": "data", "curve": [[291, 700], [352, 739], [352, 739], [352, 778]]}, {"src": "NZ", "dst": "SELF", "kind": "data", "curve": [[170, 700], [109, 739], [109, 739], [109, 794]]}]});
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
      const container = document.getElementById('0624freeclaudecoderouter-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0624freeclaudecoderouter-1';
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
*The FastAPI proxy intercepts Claude Code and Codex requests and routes them by model tier to 17 providers. Click the diagram to enlarge.*

The supported providers number 17. On the cloud side: NVIDIA NIM, OpenRouter, Google AI Studio (Gemini), DeepSeek, Mistral La Plateforme, Mistral Codestral, OpenCode Zen, OpenCode Go, Wafer, Kimi, Cerebras, Groq, Fireworks, and Z.ai. On the **self-hosted side: LM Studio, llama.cpp, and Ollama**. The last three are the meaningful ones from ThakiCloud's perspective. Since Ollama and llama.cpp expose OpenAI-compatible endpoints, a vLLM server deployed the same way on Kubernetes can be attached identically.

Tier-based routing is controlled via environment variables. `MODEL_OPUS`, `MODEL_SONNET`, and `MODEL_HAIKU` each specify which model to route to for the three Claude tiers; if unspecified, the fallback `MODEL` is used. This enables differentiated placement — for example, routing lightweight Haiku traffic to a small local model and heavier Opus traffic to a larger one.

## Installation and Integration

The official installation path is a shell one-liner:

```bash
# macOS / Linux
curl -fsSL "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh?raw=1" | sh

# Windows PowerShell
irm "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.ps1?raw=1" | iex
```

Rather than the shell one-liner, I verified the package by installing it directly in an isolated sandbox, in order not to contaminate ThakiCloud's shared virtual environment per our Python runtime rules.

```bash
# Isolated worktree + ephemeral venv (shared .venv is 3.12.8 and would conflict)
uv venv --python 3.14 .expenv
VIRTUAL_ENV=.expenv uv pip install "git+https://github.com/Alishahryar1/free-claude-code.git"
```

The package itself installs cleanly. Dependencies such as fastapi, uvicorn, httpx, pydantic, openai, and loguru resolve successfully, and console scripts like `fcc-server`, `fcc-init`, and `fcc-claude` are created. After starting the server, Claude Code is directed to the proxy as follows:

```bash
fcc-server            # Start the FastAPI proxy (default http://127.0.0.1:8082)
# Self-hosted backend example (Ollama):
#   MODEL_HAIKU=ollama/llama3.2:3b
#   MODEL_SONNET=ollama/qwen2.5:7b
# Specify the base URL to point Claude Code at the proxy, then use as normal
```

The admin UI is at `http://127.0.0.1:8082/admin` and is only accessible from loopback. Provider keys, model routing, and messaging and voice settings are managed here.

## Actual Experiment Results

During validation I encountered **a point where reproduction was blocked**, and I record it as-is. Not fabricating numbers is a principle of this report.

### Boot Blocker: Hard Python 3.14 Requirement

`free-claude-code` v2.3.14 has hardcoded `requires-python = ">=3.14.0"`. Python 3.14 is the latest version, only officially released in October 2025. The problem was that the only available 3.14 in the test environment was an alpha build (3.14.0a7). Running `fcc-server` on this alpha fails with the following error:

```text
ImportError: cannot import name 'get_annotate_from_class_namespace'
from 'annotationlib'
```

This is a conflict where the pinned pydantic expects the `annotationlib` API of the final 3.14, but that symbol is not yet present in the early alpha. I then attempted to force-run it under the next lower stable version (3.13), but installation itself is rejected because of the hard requirement in the package metadata:

```text
free-claude-code==2.3.14 cannot be used ... your requirements are unsatisfiable.
```

The conclusion is clear: **in environments without a stable Python 3.14, this proxy will not boot.** Reproduction attempt failed: the package hard-requires freshly released Python 3.14, but the only available 3.14 is an alpha that conflicts with the pinned pydantic. This is less a defect in the tool than a problem of **aggressive version pinning** that is at odds with the reality that production images typically remain on 3.11–3.12.

### Direct Measurement of the Self-Hosted Routing Path

Although the proxy itself was blocked at boot, the **mechanism** this tool uses to call the `ollama` provider is the OpenAI-compatible endpoint. I therefore measured this path by calling local Ollama directly. These are the backend's own routing performance numbers without the proxy overhead that fcc would add. The results of mapping Claude's three tiers to local models are as follows (Apple Silicon, identical prompt, 64-token cap):

![Self-hosted routing measurement results]({{ '/assets/images/free-claude-code-router-results.webp' | relative_url }})
*Figure 2. Latency and throughput when routing Claude tiers to local Ollama models. qwen3:8b placed on the opus path is a thinking model that outputs extended reasoning tokens, significantly increasing the time.*

| Routing | Model | Latency | Completion Tokens | Throughput |
|---|---|---|---|---|
| haiku | llama3.2:3b | 0.49s | 33 | 67.3 tok/s |
| sonnet | qwen2.5:7b | 0.56s | 20 | 35.7 tok/s |
| opus | qwen3:8b | 8.12s | 281 | 34.6 tok/s |

The small model (llama3.2:3b) finishes responding in under 0.5 seconds — fast enough for Haiku replacement traffic. qwen2.5:7b at 0.56 seconds is also practical. The qwen3:8b placed on the opus path, however, took 8.12 seconds, because the thinking model first emits 281 reasoning tokens. The throughput itself (34.6 tok/s) is normal, but this measurement confirms that **placing a reasoning model in a heavy tier causes a token explosion and significantly increases perceived latency**. A practical lesson: when designing tier mappings, the reasoning-token behavior of the model must also be considered.

## Application and Implications for ThakiCloud's K8s AI/ML SaaS Platform

The real value of this tool lies not in "free" but in the **connection pattern**. Once an Anthropic-compatible proxy is inserted as a layer, commercial agents like Claude Code can be attached directly to our infrastructure.

ThakiCloud schedules GPUs with Kueue and serves models with vLLM on Kubernetes. Since vLLM provides an OpenAI-compatible endpoint (`/v1/chat/completions`), it can be connected to `free-claude-code`'s self-hosted provider path in the same way as Ollama or llama.cpp. The connection method is common across self-hosted providers: specify the base URL as the cluster's vLLM service endpoint and add the provider prefix to the model identifier. Just as Ollama uses `ollama/llama3.2:3b`, an in-house model served on vLLM is added to the routing targets with the same prefix convention. This enables the following:

- **Data sovereignty**: Code and prompts never leave the tenancy boundary. This is essential in regulated environments such as on-premises deployment and NIS (National Intelligence Service) compliance requirements.
- **Cost structure shift**: Per-token metered billing is replaced by fixed GPU costs. The higher the usage, the faster self-serving reaches its break-even point.
- **Tiered differentiated placement**: Lightweight Haiku traffic can be routed to small models, and heavier workloads to larger ones, optimizing GPU occupancy. The measurements above provide baseline numbers for this differentiated placement.

That said, rather than adopting this tool as-is, it is more rational to **borrow only the validated routing pattern**. In a multi-tenant environment, the proxy must have per-tenant authentication, isolation, and observability, but `free-claude-code`'s admin UI assumes a single loopback user and is insufficient as-is. The idea behind the Anthropic-compatible normalization layer is worth borrowing, but authentication, quotas, and logging must be re-implemented to match our gateway standards.

## Limitations and Counterarguments

First, there is the **Terms of Service gray area**. The "Claude Code for free" framing relies on routing through free-tier providers, which may conflict with each service's terms. In enterprise environments, legitimate and sustainable use is strictly **routing to owned backends (self-served models)**. This is why this article emphasizes only the self-hosting path.

Second, there is **aggressive version pinning**. As seen above, the hard Python 3.14 requirement immediately prevents booting in environments without a stable runtime. Considering the cost and risk of upgrading production container images to 3.14, inserting this tool directly into a deployment pipeline at this point carries too much friction.

Third, **quality equivalence is not guaranteed**. Replacing Claude's Opus or Sonnet with different models does not preserve coding quality. Routing is a trade-off that gains cost savings and data sovereignty at the expense of response quality; which traffic to send where must be determined by measurement, depending on task difficulty.

Fourth, the measurements in this report are **direct backend call numbers without going through the proxy**. The normalization and routing overhead of fcc is not included. Once a stable Python 3.14 environment is secured, I plan to re-measure the round-trip latency through the proxy and supplement these results.

In summary, `free-claude-code` is risky if consumed as a "free hack," but read as an **open-source reference for Anthropic-compatible routing patterns**, it is a solid starting point for the design of connecting commercial agents to self-hosted inference infrastructure.

## Sources

- GitHub: [Alishahryar1/free-claude-code](https://github.com/Alishahryar1/free-claude-code) (MIT, 36.7k stars, v2.3.14)
- Measurement data: Direct calls to local Ollama OpenAI-compatible endpoint (llama3.2:3b, qwen2.5:7b, qwen3:8b, Apple Silicon)
- Related article: ThakiCloud Tech Blog "Routing Claude Code to In-House Models - claude-code-router"
