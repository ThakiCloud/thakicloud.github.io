---
title: "Claude Code /cd: How to Move Between Directories Without Restarting Your Session and Keep the Prompt Cache Intact"
excerpt: "In a monorepo, switching between a library directory and the service that consumes it used to mean restarting your session, and with it, both your conversation context and your prompt cache. The /cd command in Claude Code v2.1.169 moves a running session to a new directory while keeping the cache alive. Using the documented rate difference between cache reads (0.1x) and cache writes (1.25x), this post explains why that one line changes coding agent operating costs, and connects it to ThakiCloud's Paxis coding agent and ai-platform serving cost picture."
seo_title: "Claude Code /cd: Change Directories Without Losing Your Prompt Cache (2026) - Thaki Cloud"
seo_description: "The /cd command in Claude Code v2.1.169 lets you switch working directories without restarting your session, preserving the prompt cache along the way. This post calculates the cost model from the documented 0.1x cache-read and 1.25x cache-write rates, explains why reloading CLAUDE.md doesn't rewrite the system prompt, and connects the mechanism to ThakiCloud's Paxis coding agent and ai-platform multi-tenant serving costs."
date: 2026-07-07
lang: en
last_modified_at: 2026-07-07
tags:
  - claude-code
  - prompt-caching
  - ai-agent
  - developer-tools
  - cost-optimization
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/claude-code-cd-prompt-cache/"
reading_time: true
categories:
  - dev
---

Anyone who works with a coding agent long enough eventually has to switch directories. The classic case is a monorepo: you fix something in a core module inside a shared library, then move to the service that consumes it to verify the integration. Until now, that meant closing the session and reopening it in the new directory, or clearing the context with `/clear`. Either way, all the conversation context you had built up disappeared, and a less visible cost kicked in as well: the prompt cache was invalidated entirely, so the next request got billed at the cache-write rate all over again. The `/cd` command, quietly added in Claude Code v2.1.169, prevents both of these losses at once. This post looks at why that one line is not just a convenience feature but a real question of coding agent operating cost, using the rates Anthropic has published.

![Abstract concept of a continuous data stream forking into two paths, one expensively rebuilding blocks and the other letting the lattice flow onward intact]({{ '/assets/images/claude-code-cd-prompt-cache-hero.png' | relative_url }})

## Overview

`/cd <path>` moves a running Claude Code session to a different working directory. Because the session is not restarted, the conversation history, the selected model, and the permission settings all carry over to the new directory intact. So far this sounds like an ordinary convenience feature. The real point is what happens next: `/cd` does not break the prompt cache. The first message you send right after switching directories gets billed at the cache-read price, not the cache-write price.

This distinction matters because of how steep the cache rates actually are. In Anthropic's published prompt caching rates, a cache read costs roughly 10 percent of the standard input price, or 0.1x. Writing fresh content into the cache, on the other hand, carries a 1.25x premium over the base input rate. When you restart a session, the system prompt, the tool definitions, and the project's `CLAUDE.md` all have to be written into a fresh cache. On a large project, that prefix can run to tens of thousands of tokens. `/cd` avoids rewriting that prefix; it simply reads and reuses it.

ThakiCloud runs multiple customers' agents and batch jobs on shared infrastructure in a multi-tenant environment. In that kind of setting, token economics is service cost. If a coding agent re-caches its prefix every time it switches directories, that cost accumulates in proportion to session count and switch frequency. A single behavior that preserves the cache, like `/cd`, adds up to a real saving at scale. That is why this feature is better understood as a matter of cost hygiene than as a handy shortcut.

## What Is This Technology

To see the value of `/cd`, it helps to first understand how the prompt cache works. Claude Code automatically caches the system prompt, tool definitions, and `CLAUDE.md` on every turn, with no configuration required. This cached prefix sits at the front of the conversation, and each new message is appended after it. As long as the cache is alive, that prefix is billed only at the read rate. Once the cache breaks, the entire prefix has to be written again.

Restarting a session or clearing context with `/clear` invalidates the cache. But switching directories has a hidden trap: the new directory has its own `CLAUDE.md`. Intuitively, you'd expect the cache to break the moment the `CLAUDE.md` that feeds into the system prompt changes. This is exactly where `/cd` is clever. Instead of rewriting the destination directory's `CLAUDE.md` into the system prompt, it appends it as the next message in the conversation. Because the system prompt is never rewritten, the cached prefix stays intact, and the new `CLAUDE.md` is simply handled as one more user message tacked on at the end. That is how it applies the new directory's rules while still protecting the cache.

The diagram below shows how the two paths handle the cache differently when you switch directories.

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
<div class="d3-arch" data-arch-root id="7claudecodecdpromptcache-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 521, "height": 746, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 168, "y": 24, "w": 177, "h": 78, "title": ["Session running", "in directory A", "(prefix cache active)"]}, {"id": "B", "x": 184, "y": 180, "w": 146, "h": 68, "title": ["Need to move", "to directory B"]}, {"id": "C", "x": 298, "y": 340, "w": 177, "h": 78, "title": ["System prompt, tools,", "and CLAUDE.md cache", "invalidated"]}, {"id": "D", "x": 295, "y": 496, "w": 184, "h": 78, "title": ["Entire prefix", "written to cache again", "(1.25x rate)"]}, {"id": "E", "x": 284, "y": 660, "w": 205, "h": 46, "title": "Conversation context lost"}, {"id": "F", "x": 31, "y": 340, "w": 191, "h": 78, "title": ["System prompt preserved", "new CLAUDE.md", "appended as a message"]}, {"id": "G", "x": 52, "y": 504, "w": 149, "h": 62, "title": ["Prefix cache read", "(0.1x rate)"]}, {"id": "H", "x": 24, "y": 652, "w": 205, "h": 62, "title": ["Conversation, model,", "and permissions preserved"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [257, 102, 257, 180]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"Restart or /clear\"", "curve": [[312, 248], [387, 294], [387, 294], [387, 340]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "line": [387, 418, 387, 496]}, {"src": "D", "dst": "E", "kind": "data", "line": [387, 574, 387, 660]}, {"src": "B", "dst": "F", "kind": "data", "label": "\"/cd path\"", "curve": [[201, 248], [127, 294], [127, 294], [127, 340]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 418, 127, 504]}, {"src": "G", "dst": "H", "kind": "data", "line": [127, 566, 127, 652]}]});
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
      const container = document.getElementById('7claudecodecdpromptcache-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '7claudecodecdpromptcache-1';
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

The key point in this diagram is that the right-hand path never touches the system prompt. The left-hand path rewrites the prefix and throws away all the conversation you had accumulated along with it. Both paths arrive at the same destination, but the cost you pay to get there is completely different.

The reason appending works is that prompt caching operates at the level of the prefix. The cache reuses however much of the front of the conversation, the prefix, is identical to before. If even a single character in that prefix changes, everything from that point onward has to be recomputed. That's why putting content that changes frequently near the front hurts the cache hit rate, while putting stable content at the front and letting variable content trail behind it keeps the hit rate high. `/cd` appending the new `CLAUDE.md` as a message at the end of the conversation, rather than folding it into the system prompt, is a design that respects exactly this principle. It leaves the cached prefix untouched and absorbs all the change outside the cache boundary.

## Installation and Integration

`/cd` requires no separate installation. It works out of the box on Claude Code v2.1.169 or later. The command shipped on June 8, 2026. Usage is straightforward.

```bash
# Move to another directory within the session
/cd ../consuming-service

# Absolute paths work too
/cd /Users/me/repo/apps/web

# Home-relative paths
/cd ~/repo/packages/core
```

Once you run the command, Claude Code updates the working directory, reads the `CLAUDE.md` at the new location and appends it to the conversation, then continues the work it was doing. Because the conversation history and every decision made so far are preserved, a follow-up request like "verify that the interface I just changed in the core module works from this service" flows naturally.

Here's a concrete example. ThakiCloud's platform workspace bundles seven product repositories, the Go backend, the frontend, GitOps deployment, the multi-cluster mesh, and more, as git submodules. Changing a backend API's response schema and then checking that the frontend consuming that schema still renders correctly is a routine task in this structure. In the old workflow, you had to close the backend session and open a fresh one in the frontend directory, and then re-explain to that new session exactly what you had just changed and why. With `/cd`, the flow never breaks.

```bash
# Working on a schema change in the backend submodule
# ...

# Move to the frontend that consumes that schema (context and cache preserved)
/cd ../ai-suite/apps/web

# Immediately ask: does this screen reference the field name I just renamed?
```

Right after the move, the frontend directory's `CLAUDE.md` gets appended to the conversation, so that repository's rules (things like FSD boundaries or TDS token usage) apply immediately. At the same time, the context built up in the backend, namely which field was changed and why, is still there, so you can go straight into verification.

To understand the cache economics, you need to look at the rate table. Below is a summary of Anthropic's published prompt caching rates.

| Item | Rate vs. Standard Input | Description |
|---|---|---|
| Cache read | 0.1x | Reuse of a cached prefix, a 90 percent discount |
| Cache write (5-minute TTL) | 1.25x | Writing a new prefix into the cache, recovered on the first read |
| Cache write (1-hour TTL) | 2.0x | Applies when `ENABLE_PROMPT_CACHING_1H=1` is set |
| Uncached input | 1.0x | Base rate |

One piece of context worth flagging: Anthropic quietly cut the default cache TTL from 60 minutes to 5 minutes in March 2026. If your next request doesn't arrive within 5 minutes, the cache expires and you pay the write cost again. If you're working with long gaps between requests, you might consider enabling the 1-hour option, but the write premium jumps to 2.0x, so it's a real trade-off to weigh. `/cd` is what keeps the cache alive while you continue a session within that TTL window, which makes it more important than ever in this shorter-TTL era.

## Real Experiment Results

To be honest, `/cd` is an interactive slash command, so it wasn't possible to spin up an actual session and run an interactive benchmark in the headless environment used to write this post. Rather than fabricate measurements, this section presents a cost model built purely from the published rates. The figures below are not measurements; they are calculations based on documented rates, and that distinction is stated explicitly.

Let's compare how the two paths bill the cached prefix on the first request right after switching directories. On the restart or `/clear` path, the prefix is rewritten to the cache at the write rate (1.25x). On the `/cd` path, the same prefix is reused at the read rate (0.1x). Assuming the prefix size is identical in both cases, the ratio of what you pay for the prefix right after the switch is 1.25 divided by 0.1, or 12.5x. In other words, the restart path costs roughly 12.5 times more than the `/cd` path for re-billing the prefix.

![Comparison of cached-prefix cost when switching directories: the restart/re-cache path pays the 1.25x write rate, while the /cd path pays the 0.1x read rate, a roughly 12.5x difference by the documented rates]({{ '/assets/images/claude-code-cd-prompt-cache-results.png' | relative_url }})

This ratio holds regardless of the prefix's absolute token count. The absolute savings, however, grow larger as the prefix grows. In large projects it's common [estimated] for the combined prefix of system prompt, tool definitions, and a hefty `CLAUDE.md` to reach tens of thousands of tokens, and in sessions like that, moving between directories several times a day makes the re-caching cost add up fast. `/cd` compresses that 12.5x premium per switch down to the read rate.

One more thing worth noting: what `/cd` preserves isn't only cost. The conversation context lost on the restart path is a cost that's hard to translate into tokens. Having to re-explain the intent behind code you just changed, hypotheses you'd already formed, or approaches you'd already ruled out, costs both human time and additional tokens. `/cd` removes that re-explanation cost as well.

## Implications for ThakiCloud Products

This feature is meaningful from the perspective of both ThakiCloud products.

From the Paxis angle, `/cd` addresses session hygiene for coding agents directly. Paxis is ThakiCloud's Agent-Native Cloud, treating skills, tools, policies, and audit logs as first-class resources and running agents in isolated sandboxes. A coding agent moving across multiple repositories and submodules is a common scenario on Paxis. If every switch restarted the session and re-cached the prefix, a large skill harness and its policy context would get re-billed every time. The approach `/cd` takes, preserving the prefix and appending only the directory-specific rules as a message, aligns well with Paxis's orchestration model, which keeps skill selection and policy gates intact while only the working path changes. The idea of appending context after the fact rather than rewriting the system prompt is the same principle behind managing an always-loaded rule layer with cache stability in mind.

From the ai-platform angle, cache economics is directly multi-tenant serving cost. ThakiCloud's ai-platform serves multiple customers' inference workloads on K8s and Kueue-based GPU scheduling. Prompt caching is the key lever for reducing input costs by reusing repeated prefixes, and the principle `/cd` demonstrates, appending context after the cached boundary instead of in front of it so the cache never breaks, applies equally to our own serving stack. Designing the prompt structure to minimize cache invalidation points is a direct path to a competitive cost position on serving. The two lenses reinforce each other: lower serving cost (ai-platform) makes agent economics work (Paxis), and cache-preserving agent behavior (Paxis) in turn reduces infrastructure load.

## Limitations and Counterarguments

`/cd` isn't a silver bullet. First, cache preservation only matters within the 5-minute TTL. If you step away for a long time after switching directories, the cache expires regardless of whether you used `/cd`, and the next request pays the write cost either way. Given the short TTL, `/cd`'s savings are largest in a continuous work session and shrink for intermittent work.

Second, appending `CLAUDE.md` as a message instead of folding it into the system prompt has a subtle catch. If you edit the original project's `CLAUDE.md` mid-session, that change doesn't break the cache, but it also doesn't take effect until you `/clear`, `/compact`, or restart. In other words, you can end up in a situation where you've changed the rules but the session hasn't picked them up, so you need to deliberately refresh the session after any rule change.

Third, the 12.5x savings ratio is strictly a documented-rate calculation for re-billing the prefix right after a switch. How much you actually feel that savings in the total session cost depends on the prefix's share of overall cost, conversation length, and how often you switch. Don't stretch this post's ratio into "your session costs 12.5x less." The precise claim is narrower: you don't have to re-cache the prefix at the moment you switch.

Even so, the conclusion is clear. If your work involves frequently moving between directories in a monorepo or across multiple repositories, `/cd` is the cheapest way to protect both your conversation context and your prompt cache at the same time. For any team that operates coding agents with cost in mind, this one line is worth turning into a habit.

## Sources

- [Manage sessions - Claude Code Docs](https://code.claude.com/docs/en/sessions)
- [How Claude Code uses prompt caching - Claude Code Docs](https://code.claude.com/docs/en/prompt-caching)
- [Claude Code /cd: Switch Projects Without Losing Cache](https://claudcod.com/blog/claude-code-cd-command/)
- [Original tweet (retweeted by @delba_oliveira)](https://x.com/hjguyhan/status/2074414356058763747)
