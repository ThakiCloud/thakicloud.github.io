---
title: "Testing iOS Apps in a Browser from a Headless Cloud Mac: serve-sim"
seo_title: "Headless Development with the serve-sim Web iOS Simulator - Thaki Cloud"
seo_description: "serve-sim, built by Expo core developer Evan Bacon, streams an iOS Simulator screen to a browser and lets agents control it over a CLI. We cover the workflow where AI coding agents build and directly test iOS apps in a GUI-less cloud Mac, and what it implies for ThakiCloud's Paxis agent platform and headless development infrastructure."
excerpt: "Put a Mac Mini in the cloud and you lose the GUI, which means you lose the iOS Simulator too. serve-sim streams the simulator's framebuffer to a browser and opens a WebSocket control channel on top of it, letting AI coding agents build and actually operate an iOS app in a headless environment."
date: 2026-07-11
tags:
  - ios-simulator
  - agent-skills
  - developer-tools
  - headless
  - claude-code
  - expo
categories:
  - dev
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/serve-sim-ios-simulator-web/"
published: false
---

Ask an AI coding agent to build an iOS app and you run into one fundamental wall. The agent can write code and even build it, but it cannot actually see what happens on screen. The problem gets worse once you move your development environment to a Mac Mini in the cloud, because on a headless server with no GUI the Xcode Simulator window never even appears.

[serve-sim](https://github.com/EvanBacon/serve-sim), built by Evan Bacon of the Expo core team, aims straight at that wall. It became widely known after indie developer levelsio showed it off, saying it let him "watch, in a browser, in real time, an iOS app that Claude Code built on a cloud Mac Mini." Its slogan is simple: "npx serve for Apple Simulators."

## Overview

What makes serve-sim interesting is that it is not just a screen-mirroring tool. It opens two things at once: a video stream that sends the simulator screen to a browser, and a control channel that lets a browser or an agent operate the simulator. In other words, it makes both "watching" and "operating" possible remotely.

That combination matters because it completes the development loop for AI coding agents. An agent can fix code, build it, run it, look at the resulting screen, tap a button to move to the next step, and cycle through all of that without a human in the loop. This lines up exactly with what ThakiCloud's Agent-Native Cloud, Paxis, is aiming for: agents doing real work inside isolated environments. That makes it worth a closer look at how one open-source tool implements that workflow.

![An abstract image of a smartphone screen on a headless cloud server dissolving into particles of light that flow through the network into a browser window]({{ '/assets/images/serve-sim-ios-simulator-web-hero.webp' | relative_url }})
*A visualization of a headless server's simulator screen becoming a stream that flows into a remote browser.*

## What serve-sim Is

The way serve-sim works is simpler and more clever than it sounds. There is no separate Xcode plugin to install, and no instrumentation code to embed in the app. Instead it spins up a small Swift helper process that captures the framebuffer of an already-booted iOS Simulator through Apple's own `simctl io` interface.

The captured screen is exposed in two ways. First, it sends the video to the browser as an MJPEG stream at up to 60 FPS. Second, it opens a WebSocket control channel alongside it, so input from the browser side, taps and gestures, can be sent back to the simulator. On top of that sits a React-based preview UI, so a person can operate the app in the browser as if it were a real device.

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
<div class="d3-arch" data-arch-root id="1servesimiossimulatorweb-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 308, "height": 938, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 170, "h": 46, "title": "Booted iOS Simulator"}, {"id": "B", "x": 24, "y": 148, "w": 170, "h": 46, "title": "Swift helper process"}, {"id": "C", "x": 24, "y": 272, "w": 170, "h": 62, "title": ["Captures framebuffer", "via simctl io"]}, {"id": "D", "x": 99, "y": 412, "w": 156, "h": 62, "title": ["MJPEG video stream", "up to 60 FPS"]}, {"id": "E", "x": 42, "y": 690, "w": 205, "h": 46, "title": "WebSocket control channel"}, {"id": "F", "x": 78, "y": 552, "w": 198, "h": 46, "title": "Browser React preview UI"}, {"id": "G", "x": 56, "y": 828, "w": 177, "h": 78, "title": ["Agent CLI", "tap, gesture, rotate,", "camera"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [109, 70, 109, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [109, 194, 109, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[139, 334], [177, 373], [177, 373], [177, 412]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[79, 334], [41, 443], [41, 575], [110, 690]]}, {"src": "D", "dst": "F", "kind": "data", "line": [177, 474, 177, 552]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[145, 690], [145, 644], [145, 644], [166, 598]]}, {"src": "E", "dst": "G", "kind": "data", "line": [145, 736, 145, 828]}, {"src": "F", "dst": "E", "kind": "event", "label": "human operates", "curve": [[188, 598], [210, 644], [210, 644], [166, 690]], "off": "50%"}, {"src": "G", "dst": "E", "kind": "event", "label": "agent operates", "curve": [[115, 828], [80, 782], [80, 782], [123, 736]], "off": "50%"}]});
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
      const container = document.getElementById('1servesimiossimulatorweb-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '1servesimiossimulatorweb-1';
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

The key point is that it targets "any booted simulator." Since it requires no modification to the app, it can be attached to an existing project as-is. It can also forward simulator logs to the browser, so browser-use style MCP tools can read those logs to judge state. There is even a convenience feature where dragging a video or image into the browser window adds it as a file on the simulator device.

## Installation and Use

The barrier to entry for serve-sim is low. On a Mac with Node.js, one line is enough.

```bash
npx serve-sim
```

Once running, you can view the preview at `http://localhost:3200` locally. It supports three modes: using it locally, connecting from another device on the same LAN, or hosting it on a remote Mac and reaching it from anywhere through a tunnel. levelsio's case is the third mode: running it on a headless Mac Mini in the cloud and viewing it through a remote browser.

Agent integration is provided as a separate Agent Skill. This skill, packaged at `skills/serve-sim` in the repository, teaches any host that implements the open Agent Skills standard, including Claude Code, Cursor, Codex CLI, and Gemini CLI, how to operate the simulator through the CLI. That includes taps, gestures, hardware buttons, screen rotation, injecting camera input, and handing the stream off to the host's own preview window.

## A Note on Reproduction

This post was written in a headless batch session with no GUI, where running Node.js is blocked by policy, so we were not able to run `npx serve-sim` directly ourselves and capture the screen. The commands and behavior described in this post are therefore based on facts confirmed in the repository README and the official announcement material, and we have not fabricated any benchmark numbers. Please verify the actual simulator streaming screen and latency yourself, on a macOS machine with a booted Xcode Simulator, using the commands above.

## Implications for ThakiCloud Products

On the surface, serve-sim is a tool for iOS developers, but underneath it sits a much bigger trend: agent-native development.

**Paxis lens (agent-native development).** ThakiCloud's Paxis is an Agent-Native Cloud control plane that runs skills in isolated sandboxes and passes every action through policy gates and audit logs. The open Agent Skills standard that serve-sim adopts is the same kind of contract model that Paxis's skill harness handles. The idea that a single skill can give "tap, rotate, and read the screen of a simulator" capability to multiple agent hosts points in exactly the same direction as Paxis's structure of selecting from 960-plus skills via BM25 and running them in isolation. In particular, workloads where an agent operates a real UI, like serve-sim's control channel, need those operations to pass through policy gates and be recorded in audit logs before they can safely go into production. If serve-sim provides the "capability," Paxis provides the layer that "safely governs" that capability.

**ai-platform lens (headless execution infrastructure).** What really makes serve-sim compelling is that it runs on a headless, remote Mac. The idea of building and streaming from a GUI-less server shares its philosophy with how ThakiCloud's ai-platform schedules and runs workloads on Kubernetes without a GUI. A pipeline that attaches macOS runners on demand for iOS builds, lets an agent automatically build and test on top of them, and streams only the results back to a human, could extend beyond CI into "agent-driven QA." It is a structure where low-cost headless execution infrastructure (ai-platform) underpins the economics of agent automation (Paxis).

## Limits and Counterarguments

A few things deserve a sober look.

First, serve-sim targets the simulator. Because it is a simulator and not a physical device, issues that only surface on real hardware, camera, sensors, performance characteristics, still go uncaught. The old limitation that passing on the simulator does not guarantee passing on a real device remains unchanged.

Second, MJPEG streaming is simple and compatible but not very efficient at compression. Continuously streaming a 60 FPS, high-quality feed over a remote tunnel can turn bandwidth and latency into a bottleneck. For gesture testing where responsiveness matters, network round-trip delay translates directly into input lag.

Third, an agent being able to "see and operate" the screen is a separate matter from that judgment being correct. It remains entirely possible for an agent to misread the stream and tap the wrong button, and this is exactly why policy gates and human review are needed. The more capability a tool opens up, the more important the layer that governs that capability becomes.

Even so, serve-sim's direction is clear. It has built a real bridge needed to move from "the agent only writes code" to "the agent builds, runs, and verifies by directly operating the screen." If you are a team trying to develop mobile apps with agents from a headless cloud, you can open that world right now with a single line: `npx serve-sim`.

## Sources

- Evan Bacon. "serve-sim: The `npx serve` of Apple Simulators." GitHub. <https://github.com/EvanBacon/serve-sim>
- @levelsio, tweet introducing serve-sim. <https://x.com/levelsio/status/2075328941317886210>
