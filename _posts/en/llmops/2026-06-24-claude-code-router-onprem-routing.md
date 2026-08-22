---
title: "Routing Claude Code to Your Own Models - Cost-Efficient Coding Infra with claude-code-router"
excerpt: "Routing Claude Code traffic across glm-5.2, MiniMax-M2.7, and Kimi K2 with claude-code-router. A hands-on record of verifying all three models live, fixing MiniMax thinking leakage, and building a loop that continuously checks every routed model is cheaper than Sonnet."
seo_title: "claude-code-router Cost Routing - Multi-Model Claude Code Setup - Thaki Cloud"
seo_description: "Practical guide to routing Claude Code across glm-5.2/MiniMax-M2.7/Kimi K2 with claude-code-router. Per-task model split, MiniMax thinking-leak fix, and a continuous cost-vs-Sonnet measurement loop, all verified in the ThakiCloud environment."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - claude-code
  - model-routing
  - cost-optimization
  - ollama
  - minimax
  - on-premise
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/claude-code-router-onprem-routing/"
reading_time: true
categories:
  - llmops
published: false
---

![Concept diagram]({{ '/assets/images/claude-code-router-onprem-routing-hero.webp' | relative_url }})

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
<div class="d3-arch" data-arch-root id="ecoderouteronpremrouting-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1008, "height": 437, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "CC", "x": 53, "y": 242, "w": 120, "h": 46, "title": "Claude Code"}, {"id": "CCR", "x": 381, "y": 192, "w": 198, "h": 46, "title": "claude-code-router proxy"}, {"id": "GLM", "x": 789, "y": 359, "w": 184, "h": 46, "title": "Ollama Cloud · glm-5.2"}, {"id": "MM", "x": 785, "y": 242, "w": 191, "h": 62, "title": ["MiniMax-M2.7 (Anthropic", "endpoint)"]}, {"id": "KIMI", "x": 817, "y": 125, "w": 128, "h": 62, "title": ["Ollama Cloud ·", "kimi-k2.7-code"]}, {"id": "VLLM", "x": 785, "y": 24, "w": 191, "h": 46, "title": "internal vLLM (GLM-air)"}, {"id": "AUDIT", "x": 24, "y": 141, "w": 177, "h": 46, "title": "daily cost-audit loop"}], "edges": [{"src": "CC", "dst": "CCR", "kind": "data", "curve": [[173, 265], [291, 265], [291, 265], [394, 238]]}, {"src": "CCR", "dst": "GLM", "kind": "data", "label": "default / background", "curve": [[508, 238], [682, 382], [682, 382], [789, 382]], "off": "50%"}, {"src": "CCR", "dst": "MM", "kind": "data", "label": "think / longContext", "curve": [[560, 238], [682, 273], [682, 273], [785, 273]], "off": "50%"}, {"src": "CCR", "dst": "KIMI", "kind": "event", "label": "coding subagent tag", "curve": [[560, 192], [682, 156], [682, 156], [817, 156]], "off": "50%"}, {"src": "CCR", "dst": "VLLM", "kind": "event", "label": "onprem option", "curve": [[508, 192], [682, 47], [682, 47], [785, 47]], "off": "50%"}, {"src": "AUDIT", "dst": "CCR", "kind": "data", "label": "checks vs Sonnet", "curve": [[201, 164], [291, 164], [291, 164], [394, 192]], "off": "50%"}]});
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
      const container = document.getElementById('ecoderouteronpremrouting-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ecoderouteronpremrouting-1';
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

## Overview

Claude Code is a terminal-based agentic coding tool. By default it sends requests to the Anthropic API, but not every request carries the same weight. Background summaries, short completions, long-context analysis, and deep refactoring reasoning all demand different model tiers. Push everything to the most expensive model and cost piles up; push everything to the cheapest and quality collapses.

`claude-code-router` (CCR) solves this with a routing layer. It sits as a proxy between Claude Code and the model backends and forks traffic by request type. This post is not just a concept tour. It is a record of calling three external models to verify behavior, fixing the problems found along the way (a dead API key, thinking-tag leakage), and finally attaching a loop that continuously measures whether the routing is actually cheaper than Anthropic Sonnet.

The governing principle, stated up front: **every model routed through CCR is only worthwhile if it is more cost-efficient than Claude Sonnet.** Otherwise you lower quality while the money still flows. So we don't assert. We measure.

---


![Concept diagram]({{ '/assets/images/claude-code-router-onprem-routing-diagram.svg' | relative_url }})

*Concept diagram*

## What claude-code-router is

CCR is a proxy that receives Anthropic-format requests, converts them to OpenAI-compatible (or other) formats, and forwards them to the configured provider. It does not modify the Claude Code client. Launch a session with `ccr code` and that session's traffic routes through the `localhost:3456` proxy.

Key features:

- **Per-request-type routing**: `default`, `background`, `think`, `longContext`, `webSearch`, each mapped to a different model.
- **Multi-provider**: any OpenAI-compatible endpoint can be registered. Here we use Ollama Cloud and MiniMax.
- **Transformers**: a converter absorbs each provider's API quirks. The `Anthropic` passthrough transformer for native Anthropic endpoints is the key tool in this post.
- **Dynamic switching**: change models mid-session with `/model provider,model`.

The verified CCR version is `1.0.62`. The config lives at `~/.claude-code-router/config.json`, centered on a `Providers` array and a `Router` object.

---

## What gets routed - fixed to three models

The model pool is exactly three. Adding more models complicates the routing table and inflates verification cost, so we deliberately narrowed it.

| Role | Model | Provider | Note |
|------|-------|----------|------|
| Primary (default/background) | `glm-5.2` | Ollama Cloud | everyday coding, strong and cheap |
| Reasoning (think/longContext) | `MiniMax-M2.7` | MiniMax | thinking separated, very low per-token cost |
| Coding subagent | `kimi-k2.7-code` | Ollama Cloud | hard coding turns only |

`glm-5.2` is the workhorse; only deep reasoning and long context go to MiniMax, and a tough coding turn goes to Kimi.

---

## Verification - we called, we didn't assume

Before writing any config, we called all three models directly. To avoid inventing numbers we inspected real responses, and three facts surfaced.

**First, one Ollama Cloud key covers both GLM and Kimi.** Both `glm-5.2` and `kimi-k2.7-code` returned HTTP 200 from `https://ollama.com/v1`. Ollama Cloud bundles the GLM, Kimi, DeepSeek, and Qwen families behind a single key.

**Second, the standalone Kimi key was dead.** The standalone Moonshot key in `.env` returned 401 (Invalid Authentication) against moonshot.ai, moonshot.cn, and the Anthropic-compatible endpoint alike. Fortunately Kimi K2 is reachable as Ollama Cloud's `kimi-k2.7-code`, so the dead key was not a dead end.

**Third, MiniMax's endpoint choice decides quality.** Called through the OpenAI-compatible endpoint (`/v1/chat/completions`), the model inlines its reasoning as `<think>...</think>` tags in the body, and CCR's conversion layer fails to strip them, so they leak to the user (musistudio/claude-code-router#964). Called through the native Anthropic endpoint (`/anthropic/v1/messages`), the same model returns clean `thinking` and `text` blocks.

That last item was a bug to fix, not a reason to drop MiniMax. The fix is in the config below.

---

## Configuration - secrets out of the repo, config as code

Keys are not hardcoded into the config file. A generator script reads the repo's `.env` and writes `~/.claude-code-router/config.json`. No keys remain in the repo, and rotating a key just means re-running the script.

The core generated config:

```json
{
  "LOG": true,
  "HOST": "127.0.0.1",
  "PORT": 3456,
  "API_TIMEOUT_MS": 1800000,
  "Providers": [
    {
      "name": "ollama",
      "api_base_url": "https://ollama.com/v1/chat/completions",
      "api_key": "<OLLAMA_GLM_API_KEY>",
      "models": ["glm-5.2", "kimi-k2.7-code"],
      "transformer": { "use": [["maxtoken", { "max_tokens": 16000 }]] }
    },
    {
      "name": "minimax",
      "api_base_url": "https://api.minimax.io/anthropic/v1/messages",
      "api_key": "<MINIMAX_API_KEY>",
      "models": ["MiniMax-M2.7"],
      "transformer": { "use": ["Anthropic"] }
    }
  ],
  "Router": {
    "default": "ollama,glm-5.2",
    "background": "ollama,glm-5.2",
    "think": "minimax,MiniMax-M2.7",
    "longContext": "minimax,MiniMax-M2.7",
    "longContextThreshold": 60000,
    "webSearch": "ollama,glm-5.2"
  }
}
```

The two lines in the MiniMax provider are what fix the thinking leak. Point `api_base_url` at the native Anthropic path and use the `Anthropic` passthrough transformer, and MiniMax responds in Anthropic message format (`thinking` + `text` blocks) from the start. Re-checked through the proxy, the response blocks were `["thinking", "text"]` with zero `<think>` leakage.

Reasoning models are slow to emit, so the timeout is generous (`1800000ms`), and `maxtoken` reserves output headroom so models like GLM and Kimi, which emit reasoning first, don't burn the budget before the answer.

Subagents are routed not by config but by a prompt-leading tag. To delegate a hard coding task, prepend `<CCR-SUBAGENT-MODEL>ollama,kimi-k2.7-code</CCR-SUBAGENT-MODEL>` to the prompt.

---

## Where and how to connect

There is a single connection point. Start a session with `ccr code` in your working repo, and that session's main and subagent traffic all route through the proxy per the table above. Native `claude` still connects directly to Anthropic, so it is unaffected.

```bash
# generate config, then start the router
python3 scripts/ccr/gen_ccr_config.py && ccr restart

# start the cost-routed session (this is the connection point)
ccr code

# switch models per task inside the session
/model ollama,kimi-k2.7-code     # hard coding turn
/model minimax,MiniMax-M2.7      # deep reasoning turn
/model ollama,glm-5.2            # everyday coding
```

For cost efficiency, the recommended pattern is hybrid. Run bulk, repetitive, AFK-style work (test generation, mass refactors, log analysis, translation, code exploration) under `ccr code` to cut cost, and keep judgment-heavy work (architecture decisions, subtle debugging) on the native `claude` subscription session. Moving everything to the routed session makes GLM your main loop, which can drop quality on hard tasks.

---

## Cost efficiency - measured against Sonnet, continuously

The reason this setup exists is cost. So instead of claiming "it's cheaper," we measure.

Rates verified on 2026-06-24 (USD per 1M tokens):

| Model | Input | Output | Billing | vs Sonnet |
|-------|-------|--------|---------|-----------|
| Claude Sonnet 4.6 (baseline) | $3.00 | $15.00 | per-token | 1.0x |
| MiniMax-M2.7 | $0.24 | $0.96 | per-token | ~0.07x |
| glm-5.2 / kimi-k2.7-code | - | - | subscription $20/mo (Pro) | usage-dependent |

MiniMax-M2.7 is about 7-8% of Sonnet's per-token rate, so it is always dramatically cheaper. Ollama Cloud, by contrast, is a flat monthly subscription rather than per-token. Its effective rate is `monthly fee / monthly tokens used`, and at low volume the $20 flat fee is actually a loss. Using a blended $9/M, you must push **roughly 2.2M tokens per month** before it beats Sonnet.

That break-even is a measurement target, not a guess. CCR logs record the routed model and input/output tokens per request. A measurement script aggregates these, computing the ratio of actual cost to Sonnet-equivalent cost for per-token models, and projected-monthly Sonnet cost versus the subscription fee for subscription models. Results accumulate in a history file to track the trend, where improvement means the ratio falling over time.

The loop runs once a day via launchd. Claude is not in the loop; only a plain script runs on cron, so the measurement itself costs nothing. If a per-token model is ever found to be more expensive than Sonnet, a Slack alert fires. A subscription model below break-even (under-utilized) is reported but not alerted, to avoid noise during ramp-up.

The action rules are tied to the measurement. If a per-token model's ratio is 1.0 or higher (more expensive than Sonnet), it comes off the routing immediately. If a subscription model stays under-utilized for months, downgrade the plan or move that route to a cheap per-token model. When prices change, updating the pricing-table file is enough to reflect it in the next run.

---

## ThakiCloud platform perspective

This routing model fits naturally with the infrastructure ThakiCloud already runs.

**Code security.** In environments where source code cannot leave the building (finance, public sector, healthcare), you only need to switch `default` in the config above to an internal vLLM endpoint. You keep Claude Code's usability while prompts and code never leave. The external-model setup here is for cost verification; drop in-house GPU serving into the same skeleton and you have the on-premise version.

**Cost control.** Per-task routing is per-cost routing. Send high-frequency, low-difficulty requests to cheap models and reserve top-tier models for hard reasoning, and you narrow expensive usage to where it's truly needed, with the measurement loop proving the effect in numbers.

**Policy as code.** Providers, routing rules, the pricing table, and the measurement criteria are all managed as text files committed to the repo. Only keys live in `.env` and the config is reproduced by a generator, so the same setup restores on any machine.

---

## Limits and counterarguments

A router does not solve everything. Several points deserve a cold look.

- **Quality gap**: routing value depends on backend model quality. Open models do not always match top closed models on complex multi-step refactors or subtle debugging. Hence the hybrid recommendation.
- **Tool-call reliability**: Claude Code leans heavily on tool calls. The OpenAI-compatible conversion layer can wobble tool-call formats, so it is safe for exploration/summary subagents but warrants gradual rollout for edit/implementation subagents.
- **Subscription trap**: Ollama Cloud is flat-rate, so low usage is a loss. Below break-even, Sonnet is simply cheaper. The measurement loop watches exactly this point.
- **Proxy is a single point of failure**: main traffic also passes through CCR, so if the proxy dies the session stalls. The fallback is native `claude`.
- **The "free" framing trap**: some forks tout removing telemetry or safety guards as "free." That is a direction a company cannot endorse. The value we take is not free but control - we decide which request goes to which model, and we measure the cost.

CCR is not a cost-cutting magic trick but a routing control device. Combined with a verified model pool, fixes for real bugs like thinking leakage, and continuous measurement against Sonnet, it becomes a meaningful gain on both security and cost.

---

## Sources

- claude-code-router (musistudio): [https://github.com/musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)
- MiniMax thinking-leak issue: [claude-code-router#964](https://github.com/musistudio/claude-code-router/issues/964)
- MiniMax M2.7 pricing: [openrouter.ai/minimax/minimax-m2.7](https://openrouter.ai/minimax/minimax-m2.7)
- Ollama Cloud pricing: [ollama.com/pricing](https://ollama.com/pricing)
- Claude API pricing: [platform.claude.com/docs pricing](https://platform.claude.com/docs/en/about-claude/pricing)
