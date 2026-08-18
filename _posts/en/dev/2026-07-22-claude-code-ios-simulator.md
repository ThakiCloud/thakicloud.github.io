---
title: "Claude Code + iOS Simulator: A Closed Coding Loop Where You Build, Run, and Watch"
excerpt: "Claude Code desktop has shipped a public beta feature that opens the iOS simulator in a panel right next to the conversation. Here is what changes when Claude can build, run, and watch its own app respond, how to turn it on, and why it matters from an agent-native cloud perspective."
date: 2026-07-22
tags:
  - ClaudeCode
  - iOS
  - Simulator
  - AICoding
  - AgentLoop
  - DevProductivity
  - Paxis
author_profile: true
toc: true
toc_label: Anatomy of the iOS Simulator Loop
published: true
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/claude-code-ios-simulator/"
lang: en
---

![An abstract image depicting a closed loop where a running screen and code are joined into a single ring of light]({{ '/assets/images/claude-code-ios-simulator-hero.webp' | relative_url }})

## Why this is worth reading

If you build iOS apps with Claude Code on macOS, this post boils down to one point. The "closed loop" where a coding agent runs the app it just wrote and watches the screen while fixing it now runs inside the desktop app itself, with no separate tooling required. Below, we walk through what you actually need to learn and why this shift is not just a convenience feature but a matter of how an agent converges on code quality on its own.

## Overview

An AI coding agent becomes genuinely useful the moment it stops just spitting out code and starts checking, on its own, whether that code actually works and fixing it when it doesn't. For backend code, you can run tests and get an objective pass or fail signal. Mobile app UI is a different story. Whether an onboarding screen renders as intended, or whether tapping a button actually moves you to the next screen, has always been something you could only confirm by looking at it. Until now, that confirmation fell to a human. The agent would write the code and then sit idle until a person launched the simulator, tapped around, and reported back.

On July 21, 2026, the Claude Code desktop app shipped a public beta feature aimed squarely at closing that gap. When you build and run an iOS app, Apple's iOS Simulator opens in a panel right next to the conversation, and Claude watches the running app screen, interacts with the interface directly, and keeps iterating on the code until it behaves as intended. The back-and-forth where a human had to launch the simulator, check the result, and translate it back into words has folded into a single loop.

As ThakiCloud builds an agent-native cloud, we keep running into the same question: how does an agent observe the results of its own actions and decide what to do next? This feature is one very concrete answer to that question, so it is worth examining not just as a product announcement but through the lens of loop design.

## What the iOS Simulator integration actually is

The core idea is simple. Open an iOS project in Claude Code desktop and ask it to build and run the app, and the simulator appears in a panel beside the conversation, with Claude treating that screen as something to observe. Each session opens its own independent simulator, so running multiple tasks at once does not mix up screens between them. And this panel only works in local sessions, since the simulator itself is software that only runs on macOS.

What makes this interesting is not that it bolts on one more rendering surface, but that it opens up an additional "observation channel" for the agent. Until now, most of the signals a coding agent could check were text: compiler errors, test results, logs. What the app actually looks like and how it responds, by contrast, could only reach the agent once a human looked at it and put it into words. The simulator integration turns that visual outcome into a signal the agent can check for itself.

Simplified, the overall flow becomes a repeating loop like the one below.

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
<div class="d3-arch" data-arch-root id="22claudecodeiossimulator-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 632, "height": 1198, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 165, "y": 24, "w": 184, "h": 62, "title": ["Open the iOS project", "in Claude Code desktop"]}, {"id": "B", "x": 168, "y": 164, "w": 177, "h": 46, "title": "Request build and run"}, {"id": "C", "x": 24, "y": 288, "w": 177, "h": 46, "title": "Claude runs the build"}, {"id": "D", "x": 33, "y": 412, "w": 160, "h": 52, "title": "Build succeeded?"}, {"id": "E", "x": 101, "y": 564, "w": 149, "h": 46, "title": "Observe error log"}, {"id": "F", "x": 305, "y": 556, "w": 163, "h": 62, "title": ["App launches in", "the simulator panel"]}, {"id": "G", "x": 305, "y": 696, "w": 163, "h": 62, "title": ["Claude observes the", "running screen"]}, {"id": "H", "x": 309, "y": 836, "w": 156, "h": 62, "title": ["Interact with and", "test the interface"]}, {"id": "I", "x": 293, "y": 976, "w": 188, "h": 52, "title": "Behaves as intended?"}, {"id": "J", "x": 480, "y": 1120, "w": 120, "h": 46, "title": "Modify code"}, {"id": "K", "x": 305, "y": 1120, "w": 120, "h": 46, "title": "Loop ends"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [257, 86, 257, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[203, 210], [113, 249], [113, 249], [113, 288]]}, {"src": "C", "dst": "D", "kind": "data", "line": [113, 334, 113, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "Failed", "curve": [[113, 464], [113, 510], [113, 510], [157, 564]], "off": "50%"}, {"src": "E", "dst": "B", "kind": "data", "curve": [[200, 564], [257, 438], [257, 311], [257, 210]]}, {"src": "D", "dst": "F", "kind": "data", "label": "Succeeded", "curve": [[193, 459], [387, 510], [387, 510], [387, 556]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [387, 618, 387, 696]}, {"src": "G", "dst": "H", "kind": "data", "line": [387, 758, 387, 836]}, {"src": "H", "dst": "I", "kind": "data", "line": [387, 898, 387, 976]}, {"src": "I", "dst": "J", "kind": "data", "label": "No", "line": [418, 1028, 518, 1120], "lx": 474, "ly": 1070}, {"src": "J", "dst": "B", "kind": "data", "curve": [[544, 1120], [553, 797], [553, 438], [345, 206]]}, {"src": "I", "dst": "K", "kind": "data", "label": "Yes", "curve": [[379, 1028], [365, 1074], [365, 1074], [365, 1120]], "off": "50%"}]});
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
      const container = document.getElementById('22claudecodeiossimulator-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22claudecodeiossimulator-1';
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

As the diagram shows, human involvement is limited to the initial request and the final check; the build, run, observe, and modify steps in the middle all happen inside the agent. It is exactly the same structure as a backend test runner closing the loop by returning an objective pass or fail signal, except this time the simulator plays that role in the visual UI domain.

## How to turn it on and use it

This feature doesn't require any elaborate setup. What it does require is a clear set of prerequisites. First, you need macOS, since the iOS Simulator doesn't run outside the Apple ecosystem, so this panel is unavailable on Windows or Linux. You also need Xcode installed with the iOS platform, since the underlying machinery that actually performs the build and launches the simulator is Xcode's build tools and simulator. On the plan side, this feature is available to users on the Pro, Max, and Team plans.

Using it is entirely conversational. Open your iOS project in Claude Code desktop, set the app's project folder as the project, and start a session. Any project that builds an app for the iOS simulator will work. From there, just ask Claude to run or test the app. Tell it in natural language, something like "build the app, run it in the simulator, and check the onboarding flow," and Claude will run the build, launch the app in the simulator panel, and go through its checks while observing the screen.

In short, there is essentially no new command or config file to memorize. What changes is the scope of what you can ask an agent to do. Where you used to say "fix this screen to look like this" and then had to launch it yourself to check, you can now fold that check into the instruction itself. Since this is still a public beta, the details will keep getting refined, but the direction of the interaction model is already clear.

## What a closed loop gives a coding agent

The real significance of this feature lies less in convenience and more in the completeness of the loop. For an agent to be useful, it needs a way to verify its own output, and if that verification depends on a human's eyes and hands every single time, the agent remains only half-automated. iOS UI work has long been a textbook case of this half-finished state. The agent writes the code, but whether the result is correct on screen has always needed a human to look.

Once the simulator sits next to the conversation and the agent can watch the running screen, observation, judgment, and correction all chain together inside one loop. If the build fails, it reads the error and fixes it; once the app launches, it looks at the screen, spots where things diverge from intent, and fixes it again. The key point is that this cycle runs without a human round trip. Granted, this observation works by capturing and checking the screen, so it can't perfectly replace the subtle feel a human gets from actually touching and interacting with the interface. Even so, simply removing the disconnect of "I fixed the code but have no idea how the screen changed, so I'm waiting for the next instruction" changes the texture of the work.

This structure also connects to loop engineering principles ThakiCloud has been formalizing internally. Reliable feedback is a deterministic signal that objectively reports pass or fail, and an agent's self-report ("looks like it worked") can never serve as the loop's exit condition. The simulator is a device that extends that deterministic signal into the visual domain. Build success or failure was already a clear signal; now that another observation channel, the running screen, has been added, the loop for UI work closes that much more tightly.

## Implications for ThakiCloud's products

Since this is fundamentally about agents, it's natural to view it through the Paxis lens. Paxis is ThakiCloud's agent-native cloud, treating skills, tools, policies, and audit logs as first-class resources, running skills in isolated sandboxes, and routing every action through policy gates and audit logs. The "build, run, observe, fix" closed loop that Claude Code's simulator integration demonstrates belongs to exactly the same family as the execution model Paxis is aiming for: an agent runs something in an isolated environment, observes the result to decide its next action, and the entire process stays within controlled boundaries.

From a Paxis perspective, this case carries two implications. First, opening a channel for an agent to observe execution results is what determines the depth of automation. Just as a loop for UI work that text signals alone couldn't close was closed by adding a single visual observation channel, quality in Paxis likewise hinges on each skill having a signal to verify its own output. Second, that execution happens in an environment isolated per session. Just as Claude Code opens an independent simulator for each session, Paxis's sandboxed isolated execution is a design built on the same principle: guaranteeing that multiple agent tasks running in parallel never contaminate one another.

One more point worth adding from an infrastructure angle: for a closed loop like this to be practical, the execution environment needs to spin up and tear down cheaply and fast. ThakiCloud's ai-platform's ability to efficiently schedule isolated execution environments on Kubernetes underpins the economics of running agent loops at scale. Without low-cost isolated execution, an agent loop that repeats observation and correction cannot run without racking up unsustainable cost.

## Limitations and counterarguments

To avoid overstating this feature, its boundaries deserve equal attention. For one, the platform is locked to macOS. That's an unavoidable constraint given that the iOS Simulator doesn't run outside Apple's ecosystem, but it also means this loop is only open to Mac users. Xcode is a hard prerequisite, the feature is limited to Pro, Max, and Team plans, and the panel only works in local sessions. It's still too early to expect the same experience in remote sessions or shared team environments.

The feature itself is also a public beta. What was published alongside the announcement is how it works and how to use it, not a benchmark of how fast or accurately this loop actually converges in practice. So it's not yet possible to state numerically how much better things get. And because the agent's screen observation works by capturing and checking the running screen, it cannot substitute for the subtle response of a gesture or the felt sense of performance that a human experiences on an actual device with their own fingertips. Complex animations, accessibility behavior, and issues that only surface on real hardware still need human verification.

One last counterargument worth raising: this kind of convenience carries the risk of turning into unreviewed trust. The more smoothly a loop runs, the easier it becomes for a human to accept the result at face value. An agent saying "I checked it" doesn't mean that judgment is itself verification. Simulator observation is a useful signal, not final approval, and especially for subtle aspects of user experience, a human still needs to tap through it and judge for themselves.

## Wrap-up

Claude Code's iOS Simulator integration looks small, but its direction is clear. The closed loop where a coding agent runs what it just built, observes it, and fixes it has now extended into UI, a domain that had long depended on humans. For developers building iOS apps with Claude Code on macOS, this is a change worth trying right now, and because it widens the scope of what you can ask an agent to do, it invites you to rethink how you work in the first place.

Zooming out, this case reconfirms that what makes an agent useful isn't model size alone but a harness question: how well does it close the loop of observing results and deciding the next action? That's precisely the problem ThakiCloud is solving with Paxis and ai-platform. Today's one-line takeaway is this: the next time you hand UI work to an agent, don't stop at asking it to fix the code. Tell it to "run it and check it too." Letting the agent close the loop instead of a human is the most practical change this feature brings.

## Sources

- [Claude Code official docs: Test iOS apps in the simulator](https://code.claude.com/docs/en/desktop-ios-simulator)
- [ClaudeDevs announcement (X)](https://x.com/ClaudeDevs/status/2079674432038248611)
- [9to5Mac: Claude Code brings live iOS app testing into its Mac app](https://9to5mac.com/2026/07/21/claude-code-brings-live-ios-app-testing-into-its-mac-app/)
- [MacRumors: Claude Code Can Now Build and Test iOS Apps in Apple's Simulator](https://www.macrumors.com/2026/07/21/claude-code-ios-simulator/)
