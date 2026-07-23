---
title: "Editing Video With a Coding Agent: A Look Inside the video-use Skill"
excerpt: "Shared by midudev and quickly making the rounds, browser-use's video-use is a free, open-source skill: drop raw footage into a folder, type one sentence, and a coding agent handles cutting, filler removal, subtitles, color grading, animation, and rendering. We break down its per-animation parallel sub-agent design and what it means through the lens of Paxis, ThakiCloud's Agent-Native Cloud, and its Skill Harness."
seo_title: "video-use: Editing Video With a Coding Agent - Thaki Cloud"
seo_description: "browser-use's open-source video-use skill automates cutting, filler removal, subtitles, color grading, animation, and rendering from just a folder of footage and one sentence. We analyze its parallel sub-agent design and HyperFrames/Remotion/Manim/PIL animation engines, then map it to the Skill Harness of ThakiCloud's Paxis."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - ai-coding
  - claude-code
  - agent-skills
  - video-editing
  - browser-use
  - agent-orchestration
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "film"
canonical_url: "https://thakicloud.com/tech-blog/en/technique/video-use-coding-agent-video-editor/"
categories:
  - tutorials
---

## Overview

Video editing has long been the domain of manual work, where a person cuts and joins clips on a timeline. Finishing a single video meant dedicated tools and a trained hand for cutting, removing filler speech, adding subtitles, color grading, and motion graphics. Then in June 2026, a one-line tweet from the Spanish developer-influencer midudev spread quickly among developers: "Claude Code can now edit video too. This skill is 100% free and open source."

The subject of the buzz is `video-use`, released by the browser-use team. The same team known for browser-use, which drives a browser with a coding agent, now offers a skill that hands video editing entirely to a coding agent. The usage is simple. You put your raw video files in a folder, write one sentence describing the video you want, and the agent does the rest.

ThakiCloud is productizing the structure where an agent picks and runs skills inside an isolated environment as an Agent-Native Cloud. So we read video-use not as a mere editing tool, but as a case study in how a coding agent decomposes and parallelizes non-development work. This article records what video-use actually does, what its internals look like, and what its design suggests from our platform's point of view.

## What This Technology Is

The core idea of video-use is to reduce video editing to a single natural-language command. The user never touches the timeline directly. Instead, they describe the desired result in a sentence, and the agent decomposes that sentence into several concrete editing actions.

According to its public description, video-use automatically handles the following.

- Cutting away unnecessary segments from the raw footage
- Automatically removing filler words such as "um" and "uh"
- Recognizing speech to generate subtitles and burn them into the video
- Applying color grading to unify the tone
- Layering animation overlays at points that need emphasis
- Rendering all of the above into a single final MP4

The interesting part is how animation is handled. When creating animation overlays, video-use is not tied to a single engine; it chooses among HyperFrames, Remotion, Manim, and PIL according to the nature of the task. More importantly, it spawns a separate sub-agent in parallel for each animation it creates. One agent per animation.

This design is fundamentally different from the common approach of "generate a video with one giant prompt." It splits the large task of video editing into independent sub-tasks such as cuts, subtitles, color grading, and animation; runs the non-dependent ones in parallel; and finally assembles them into a single timeline. The full flow looks like this.

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
<div class="d3-arch" data-arch-root id="secodingagentvideoeditor-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1363, "height": 770, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 722, "y": 24, "w": 212, "h": 62, "title": ["Raw Footage Folder", "+ One-sentence Instruction"]}, {"id": "B", "x": 767, "y": 164, "w": 121, "h": 62, "title": ["Agent: Intent", "Decomposition"]}, {"id": "C", "x": 1182, "y": 428, "w": 149, "h": 62, "title": ["Cut Editing", "Segment Selection"]}, {"id": "D", "x": 964, "y": 428, "w": 163, "h": 62, "title": ["Filler Word Removal", "Audio Analysis"]}, {"id": "E", "x": 746, "y": 428, "w": 163, "h": 62, "title": ["Subtitle Generation", "Speech Recognition"]}, {"id": "F", "x": 549, "y": 428, "w": 142, "h": 62, "title": ["Color Grading", "Tone Unification"]}, {"id": "G", "x": 181, "y": 304, "w": 156, "h": 46, "title": "Animation Overlays"}, {"id": "G1", "x": 374, "y": 428, "w": 120, "h": 62, "title": ["Sub-agent 1", "HyperFrames"]}, {"id": "G2", "x": 199, "y": 428, "w": 120, "h": 62, "title": ["Sub-agent 2", "Remotion"]}, {"id": "G3", "x": 24, "y": 428, "w": 120, "h": 62, "title": ["Sub-agent 3", "Manim / PIL"]}, {"id": "H", "x": 546, "y": 568, "w": 149, "h": 46, "title": "Timeline Assembly"}, {"id": "I", "x": 539, "y": 692, "w": 163, "h": 46, "title": "Final MP4 Rendering"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [828, 86, 828, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[888, 205], [1257, 265], [1257, 389], [1257, 428]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[888, 214], [1046, 265], [1046, 389], [1046, 428]]}, {"src": "B", "dst": "E", "kind": "data", "line": [828, 226, 828, 428]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[767, 215], [620, 265], [620, 389], [620, 428]]}, {"src": "B", "dst": "G", "kind": "data", "curve": [[767, 202], [259, 265], [259, 265], [259, 304]]}, {"src": "G", "dst": "G1", "kind": "data", "curve": [[324, 350], [434, 389], [434, 389], [434, 428]]}, {"src": "G", "dst": "G2", "kind": "data", "line": [259, 350, 259, 428]}, {"src": "G", "dst": "G3", "kind": "data", "curve": [[194, 350], [84, 389], [84, 389], [84, 428]]}, {"src": "C", "dst": "H", "kind": "data", "curve": [[1257, 490], [1257, 529], [1257, 529], [695, 584]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[1046, 490], [1046, 529], [1046, 529], [695, 580]]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[828, 490], [828, 529], [828, 529], [695, 569]]}, {"src": "F", "dst": "H", "kind": "data", "line": [620, 490, 620, 568]}, {"src": "G1", "dst": "H", "kind": "data", "curve": [[434, 490], [434, 529], [434, 529], [551, 568]]}, {"src": "G2", "dst": "H", "kind": "data", "curve": [[259, 490], [259, 529], [259, 529], [546, 578]]}, {"src": "G3", "dst": "H", "kind": "data", "curve": [[84, 490], [84, 529], [84, 529], [546, 582]]}, {"src": "H", "dst": "I", "kind": "data", "line": [620, 614, 620, 692]}]});
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
      const container = document.getElementById('secodingagentvideoeditor-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'secodingagentvideoeditor-1';
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

*How video-use decomposes editing into cuts, subtitles, color grading, and animation, spawns a sub-agent per animation in parallel, then merges them into a single timeline. (Diagram labels in Korean, shared across languages.)*

As the diagram shows, the animation block is not a single node but fans out into multiple sub-agents. Each sub-agent is responsible only for its assigned animation and does not see the others' intermediate results. With this separation, whether there are three animations or five, they can proceed simultaneously, and total wall-clock time converges to the duration of the single longest animation.

## Installation and Integration

video-use ships as a skill that runs on top of a coding agent. You can get it from the browser-use team's public repository (`browser-use/video-use`), and true to its one-line description, "Edit videos with coding agents," a coding agent is the host. The typical flow is to fetch the repository, place the skill where the agent can recognize it, drop raw footage into a working folder, and instruct the agent in one sentence.

The animation engines each have a different character. Remotion is a framework for programming video with React, strong at component-based motion graphics; Manim is a Python library specialized in equation and shape animation; PIL handles lightweight image compositing; and HyperFrames is used for frame-by-frame sequence generation. Because video-use does not fix on one engine but picks the right one per task, the environment needs the runtimes these engines require (Node, Python, ffmpeg, and so on).

> An honest note on the scope of reproduction: the environment in which this article was written is an isolated one with restricted external network and dependency installation, so we were unable to run the full pipeline with raw video assets and heavy rendering dependencies (Remotion, Manim, ffmpeg) to measure rendering time or quality numbers directly. The analysis here is therefore based on the published skill description and architecture, and we do not include any benchmark numbers we did not measure.

## What the Behavior Actually Means

Although we did not run the full render ourselves, the published behavior spec alone makes clear what this skill aims for. The biggest shift is that the unit of editing becomes intent rather than clips.

In a traditional editing tool, the user thinks in terms of actions: "cut from 3 seconds to 7 seconds, add a fade there, attach a subtitle." In video-use, the user thinks in terms of results: "take this presentation video, clean it up, and make a one-minute clip with subtitles and emphasis animations." The conversion between the two, that is, unpacking the intent into dozens of actions, is what the agent takes on.

The second shift is parallelization. Video editing looks inherently serial, but in reality it contains many independent sub-tasks. Subtitle generation is unrelated to color grading, and the second scene's animation is unrelated to the first's. The fact that video-use spawns a sub-agent per animation is a design that actively exploits this independence to reduce wall-clock time. It is exactly the same idea ThakiCloud always emphasizes in multi-agent orchestration: run non-dependent tasks in parallel.

## Implications for ThakiCloud's Products

video-use addresses the non-development domain of video, but its design principles touch the core of **Paxis**, which ThakiCloud is productizing as an Agent-Native Cloud. Paxis is an agent control plane running on top of ai-platform, treating Skills, Tools, Policies, and Audit Logs as first-class resources. Mapping the video-use structure onto Paxis's layers reveals three things.

First, the **Skill Harness perspective**. video-use is itself a single skill, and internally it selects among several sub-tools (HyperFrames, Remotion, Manim, PIL) as the situation demands. Paxis's Skill Harness selects from more than 960 skills via BM25 and loads only the relevant ones into context; the way video-use picks an engine per animation task is a small instance of the same "load only what you need" principle. It also aligns with our experience that filling a verified skeleton with free design raises average quality.

Second, the **sandboxed isolated execution perspective**. Video rendering pulls in heavy dependencies such as ffmpeg, Node, and Python, and done carelessly, it can pollute the host environment. Paxis processes every skill execution in an isolated sandbox to protect the main working tree. The more a skill calls multiple external runtimes, as video-use does, the more this isolation becomes a necessity rather than an option. When parallel sub-agents each run a different engine, you need a boundary that keeps their temporary files and processes from colliding for things to run reliably.

Third, the **DAG multi-agent orchestration perspective**. The video-use flow is in effect a directed acyclic graph (DAG). The cut, subtitle, color-grading, and animation nodes fan out in parallel and then converge again at the timeline-assembly node. Paxis expresses this fan-out and fan-in as first-class, and passes each node's execution through policy gates and audit logs. Because who called which tool and when is all recorded, you can trace how the result was produced.

In short, video-use is one demo of a coding agent decomposing and parallelizing non-development work, and Paxis is the control plane that operates such patterns safely and traceably. Whether it is video editing or a data pipeline, the skeleton is the same: encapsulate the work as a skill, run it in parallel inside an isolated sandbox, and leave every action in an audit log.

## Limitations and Counterarguments

This approach is not a cure-all. First, because the agent's judgment enters at the stage of decomposing intent into actions, the output may diverge from what the user pictured. "Clean it up" means different things to different people, and the segment the agent cut may in fact have been the key one. In the end, rather than finishing in one sentence, you will likely exchange several rounds of revision instructions.

Second, cost and time. Spawning a sub-agent per animation reduces wall-clock time through parallelization, but at the cost of using more compute for as many agents and rendering processes as run at once. For polishing a single short clip, it may be an over-engineered design. Running a job through agent orchestration when a traditional editor would finish it in five minutes is not always a win.

Third, the absence of determinism. Even with the same source and the same instruction, there is no guarantee the same result comes out every time. Reproducibility matters in professional video production, and agent-based editing still needs validation here. This is also why ThakiCloud emphasizes the principle that in batch outputs, "format and aggregation are owned by deterministic code while the model generates only content." Even if you leave creative editing to the model, a hybrid where deterministic parts such as subtitle timing and output specs are guaranteed by code is the realistic compromise.

Even so, the direction video-use demonstrates is clear. The pattern of encapsulating complex tasks in non-development domains as skills, decomposing independent sub-tasks into parallel agents, and using natural-language intent as the entry point will spread to more areas. What ThakiCloud is building with Paxis is precisely the foundation for operating that pattern safely.

## Sources

- [browser-use/video-use (GitHub)](https://github.com/browser-use/video-use): "Edit videos with coding agents"
- [@midudev tweet](https://x.com/midudev): video-use skill introduction (2026-06-27)
- [video-use: Edit Videos with Claude Code (AIBit)](https://aibit.im/en/article/video-use-edit-videos-with-claude-code)
