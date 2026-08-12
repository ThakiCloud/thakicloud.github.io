---
title: "Building Interactive Web Experiences with Fable 5: 3D, Scroll Animation, and GLSL in a Single Prompt"
excerpt: "Anthropic's Claude Fable 5 is setting a new bar for frontend generation. We look at real public guides and open-source galleries showing scroll-driven 3D scenes, GLSL shaders, and screenshot-based redesigns pulled from a single prompt, and consider what this shift means from the perspective of ThakiCloud Paxis, which treats coding agents as first-class resources."
seo_title: "Claude Fable 5 Interactive Web Design - 3D Scroll Animation GLSL Workflow (2026) - Thaki Cloud"
seo_description: "An analysis of how Claude Fable 5 generates 3D interactive sites, scroll-driven animation, and GLSL shaders from a single prompt, grounded in a real public guide (Viktor Oddy) and an open-source gallery (claude-directory). Covers frontend generation workflows, screenshot-based redesign, and Three.js integration, and unpacks the implications for ThakiCloud's Paxis Agent-Native Cloud, which treats coding agents as first-class resources."
date: 2026-07-09
last_modified_at: 2026-07-09
lang: en
tags:
  - claude-fable-5
  - web-design
  - frontend
  - interactive-animation
  - threejs
  - ai-coding
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/fable5-interactive-web-design/"
reading_time: true
categories:
  - dev
---

## Who should read this

This piece is for frontend developers and design engineers who build real product surfaces with AI coding tools, and for platform engineers trying to wire coding agents into a team's workflow. The claim that "AI can spit out a convincing landing page mockup" is old news by now. What we want to dig into here goes one level deeper: how far can a model actually get with interactions that used to take days to hand-code, things like a 3D scene that reacts to scroll position or a shader-driven background, and how do you actually put that output into a production pipeline. If you're weighing whether to adopt this, our goal is to draw a clean line between what's genuinely possible today and where a human still has to be in the loop, without the hype.

![An abstract image of light and glass surfaces overlapping to create a sense of depth in a 3D interaction]({{ '/assets/images/fable5-interactive-web-design-hero.webp' | relative_url }})

## Overview

For a long time, the wall AI-generated frontends kept hitting was "static." Pages with tidy buttons and cards came out fine, but interactions that tangle state and time together, a 3D scene where the camera moves with scroll position, or a glass material that refracts as you move the mouse, tended to break the model. Code would compile, but nothing would happen on screen, or the frame rate would stutter badly.

By the middle of 2026, that wall had visibly come down. Anthropic's Claude Fable 5 sits at the center of it. Developer Viktor Oddy published a public guide titled "Claude Fable 5 Just Changed Web Design Forever!" recording, start to finish, the process of generating a 3D, interactive, animated website from a single prompt. Since then, the community has gone further and produced an open-source gallery collecting UI experiments built with Fable 5. This post follows that thread to work out what has actually changed, and what it means for a company like ThakiCloud that treats agents as infrastructure.

{% include video id="_JF_s-ZRTyY" provider="youtube" %}

The video above is Viktor Oddy's recorded walkthrough of building a 3D interactive web experience with Fable 5.

## What sets Fable 5 apart

Fable 5 is a Claude-family model from Anthropic that shows particular strength in frontend engineering and multi-step agentic work. That phrase, "multi-step," matters here. Building a single interactive web page is really a bundle of separate jobs: laying out the structure, defining 3D geometry, wiring scroll events to scene state, attaching shaders, organizing files, and tuning performance. Where earlier models would handle one or two of those steps and hand the rest back to a human, Fable 5 carries the chain forward on its own for much longer.

Concretely, a few capabilities show up again and again across public examples. First, it implements scroll-driven animation in code, wiring scroll progress to a scene's camera or element state, the kind of thing that's genuinely fiddly state management by hand. Second, it combines 3D libraries like Three.js with GLSL shaders to produce effects like refraction, noise, and particles. Third, it can take a screenshot as input and propose a redesign that improves an existing site's layout and interactions. Fourth, it organizes project file structure and assets on its own, carrying a single prompt through to a runnable result.

What these capabilities have in common isn't "generating static markup" but "generating code where state and time are entangled." That has been the weak link in AI frontend generation for a while, and it's the part Fable 5 has visibly pushed forward.

## How interactive web design actually gets built

Working backward from published guides and gallery results, the real workflow tends to follow the pattern below. Rather than expecting a perfect result in one shot, it hands the model big chunks of the work it's good at, and lets a human review and narrow things down from there.

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
<div class="d3-arch" data-arch-root id="ble5interactivewebdesign-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 432, "height": 912, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 102, "y": 24, "w": 198, "h": 78, "title": ["Intent prompt", "(mood, references, stack", "specified)"]}, {"id": "B", "x": 95, "y": 180, "w": 212, "h": 62, "title": ["Draft generation", "layout + 3D scene skeleton"]}, {"id": "C", "x": 102, "y": 320, "w": 198, "h": 78, "title": ["Wiring interaction", "scroll progress -> scene", "state"]}, {"id": "D", "x": 209, "y": 476, "w": 191, "h": 78, "title": ["Visual effects", "GLSL shaders . Three.js", "materials"]}, {"id": "E", "x": 112, "y": 632, "w": 177, "h": 78, "title": ["Human review", "performance .", "accessibility . brand"]}, {"id": "F", "x": 123, "y": 802, "w": 156, "h": 78, "title": ["Build . deploy", "React . Tailwind .", "Three.js"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [201, 102, 201, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [201, 242, 201, 320]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[253, 398], [304, 437], [304, 437], [304, 476]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[304, 554], [304, 593], [304, 593], [253, 632]]}, {"src": "E", "dst": "C", "kind": "data", "label": "\"Revision instructions\"", "curve": [[149, 632], [98, 593], [98, 437], [149, 398]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "\"Approved\"", "line": [201, 710, 201, 802], "lx": 201, "ly": 752}]});
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
      const container = document.getElementById('ble5interactivewebdesign-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ble5interactivewebdesign-1';
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

The key is packing enough specificity about "what you want" into the first prompt. Naming the mood you're after, reference sites, and the stack you want to use (React, Tailwind, Three.js, for example) changes draft quality substantially. Including a screenshot raises redesign accuracy. Once a draft exists, interaction-level revision instructions, something like "slow the camera down near the bottom of the scroll," work well. In other words, this isn't a one-shot prompt that finishes the job. The model takes on the big skeleton, and a human tunes the texture of the interaction.

There's also a clear caution here. Flashy shaders and 3D come at a cost to mobile performance and accessibility. Even when a model's output looks great on desktop, handling low-end devices and screen reader users is still squarely a human job. Skip building that review step explicitly into the workflow, and you end up accumulating output that's pretty but unusable in production.

## Real examples and the open-source gallery

The evidence that this isn't one person's bragging sits in public material. Viktor Oddy's guide, mentioned above, recorded the entire process, and the community has published an open-source gallery, `pulkitxm/claude-directory`, collecting UI experiments built with Fable 5. The repository gathers examples of landing pages, hero sections, GLSL shaders, design systems, animation, and 3D built on React, Tailwind, and Three.js, and lets you open each result directly, code included. Being able to run individual experiments in a browser matters, because it means you can verify "does this actually work" by execution, not by looking at a screenshot.

Another example on record combines Fable 5 with Higgsfield MCP to build a cinematic scroll website. What's worth noting here is that the model isn't doing everything alone. It connects to an external tool (visual asset generation, in this case) through an MCP connector, and the two are merged into one result. That's a signal that interactive web generation is evolving from a single model's trick into the product of a pipeline where a model and tools mesh together.

Putting it together, here's what can be confirmed at this point. First, a single prompt produces a runnable draft of a 3D interactive web experience. Second, that result is verifiable, code included, in public repositories. Third, tool connections like MCP integrate asset generation into the pipeline as well. That said, none of these examples come with standardized, published quantitative performance benchmarks (frame rate, bundle size, accessibility score), so quality judgment still comes down to each team's own review criteria. That's worth treating as a plain fact rather than an "[estimated]" caveat.

## Implications for ThakiCloud's product

This trend lines up closely with the direction ThakiCloud is taking Paxis. Paxis is the Agent-Native Cloud control plane running on top of ai-platform, and it treats Skills, Tools, Policies, and Audit Logs as first-class resources. What Fable 5 demonstrates is that a coding agent has become a generation subject that carries multiple steps forward on its own, not just a single-shot responder. To put an agent like that into a product workflow, "where it runs, under what permissions, and what gets logged" starts to matter just as much as "what it generates."

Looked at from Paxis's angle, each stage of the workflow above reduces to a control-plane resource. A repeatable task like interactive web generation gets registered as a single skill, selected by BM25 out of a pool of roughly 960 skills, and the actual code generation and build run in an isolated sandbox. When an external tool is needed, as in the Higgsfield MCP example, the MCP connector handles even OAuth reconnection automatically. Before a generated artifact reaches production, policy gates enforce review rules, and every action lands in the audit log. In short, what a control plane does is take the individual trick of "AI is good at building screens" and promote it into a repeatable pipeline a team can trust and audit.

There's an infrastructure-level implication too. Frontends with 3D and shaders demand heavy rendering and repeated builds during generation. ThakiCloud's ai-platform, built on K8s and Kueue, schedules this kind of bursty work inside isolated tenants and manages cost by attaching and releasing resources only when needed. Being able to run this pipeline self-hosted on premises or in a sovereign environment matters in particular for customers who can't send code and design assets outside their own walls. Agent economics (Paxis) only work on top of a low-cost, stable generation and build infrastructure (ai-platform).

## Limits and counterarguments

Sticking to optimism would throw off the balance. A few counterpoints worth stating plainly.

First, the maintainability of generated interaction code is still an open question. A 3D scene produced from a single prompt is impressive, but whether someone else can understand and modify that state management logic months later is a different problem. Flashiness and maintainability are frequently at odds.

Second, performance and accessibility don't come along for free. As noted above, mobile frame rate, bundle size, and screen reader support aren't areas the model handles by default, and if you don't make them an explicit review gate, they end up as technical debt.

Third, there's a question of originality. If similar prompts produce similar 3D hero sections, you can end up with every site converging on the same mood, a kind of homogenization of "AI aesthetics." The more powerful the tool gets, the more human judgment about what to actually build matters.

Fourth, the absence of standardized quantitative metrics in public examples calls for some caution. There's no shortage of impressive testimonials about how different this feels, but reproducible, verified benchmarks are still thin. Before adopting this in production, it's worth reproducing the results yourself against your own stack and standards.

In conclusion, Fable 5 has genuinely lowered the barrier to generating interactive web experiences. But turning that output into a product you can trust remains a matter of review, policy, and infrastructure. And how a team closes that last stretch with a system is what separates teams that use the tool from teams that build the product.

## Sources

- Viktor Oddy, "Claude Fable 5 Just Changed Web Design Forever!" (guide video and article), <https://www.youtube.com/watch?v=_JF_s-ZRTyY>
- pulkitxm/claude-directory, an open-source gallery of UI experiments built with Fable 5 (React, Tailwind, Three.js, GLSL), <https://github.com/pulkitxm/claude-directory>
- "I Built a Cinematic Scroll Website Using Claude Fable 5 and Higgsfield MCP", Medium, <https://medium.com/@info.booststash/i-built-a-cinematic-scroll-website-using-claude-fable-5-and-higgsfield-mcp-72fbcebb8ad1>
