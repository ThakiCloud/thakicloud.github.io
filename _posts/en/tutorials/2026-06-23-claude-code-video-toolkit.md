---
title: "Making Videos from Claude Code: I Ran claude-code-video-toolkit Myself"
excerpt: "An open-source toolkit that renders 1080p video from inside Claude Code with a couple of slash commands. I cloned examples/hello-world and rendered it with zero API keys, and a 750-frame, 25-second 1080p clip came out in about 18 seconds. Here is the structure, the measured results, and how ThakiCloud's Kubernetes AI/ML SaaS platform views GPU video workloads."
seo_title: "Hands-on with claude-code-video-toolkit and a Platform View - Thaki Cloud"
seo_description: "A hands-on run of digitalsamba/claude-code-video-toolkit with zero API keys (npm install 3.5s, cold render 18.4s, 1920x1080 25s 2.15MB) plus structural analysis. Remotion, open-source AI model stack, and ThakiCloud Kubernetes GPU workload perspective."
date: 2026-06-23
last_modified_at: 2026-06-23
tags:
  - ai-coding
  - claude-code
  - remotion
  - video-generation
  - gpu
  - platform-engineering
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/technique/claude-code-video-toolkit/"
categories:
  - tutorials
---

![Abstract representation of an automated video production pipeline]({{ '/assets/images/claude-code-video-toolkit-hero.webp' | relative_url }})
*An automated video pipeline, rendered as light particles assembling into ordered frames.*

## Overview

Video production has long required dedicated editors and a human touch. Recently, though, a pattern has taken hold where, just as coding agents write code, video is described in code and rendered. `digitalsamba/claude-code-video-toolkit` puts that pattern on top of Claude Code. As of its release it shows roughly 1.6k GitHub stars, 268 forks, and 182 commits, under the MIT license.

The core idea is simple. You describe a video project with Remotion, a React-based framework; you delegate the generation of assets such as voice, images, music, and b-roll to open-source AI models; and you tie the whole process together with Claude Code's slash commands and skills. The user creates a project from a template with a single `/video`, configures cloud GPU, storage, and voice with `/setup`, and then moves on to rendering.

ThakiCloud runs a Kubernetes-based AI/ML SaaS platform and deals with GPU workloads every day. Video rendering and generative asset synthesis are textbook GPU-bound jobs, and in a multi-tenant environment how you allocate resources is the cost. So this toolkit is worth reading not just as a content tool but as one example of the workload type our platform handles. In this post I first show what happened when I actually cloned and ran the toolkit, then discuss what it means from a platform point of view.

## What this tool is

claude-code-video-toolkit turns Claude Code into a video production workstation. It helps to think of it in three layers.

The first is the slash-command layer. `/setup` interactively walks you through first-time configuration such as cloud GPU, file transfer, and voice. `/video` creates and opens projects, and `/scene-review` helps with scene-by-scene review in Remotion Studio. Beyond these, there are commands for each stage of production: `/brand`, `/template`, `/generate-voiceover`, `/voice-clone`, `/redub`, `/record-demo`, `/publish`, and more. `/publish` uploads a finished video to YouTube and auto-fills metadata from `project.json`.

The second is the skill layer. These bundle domain knowledge so Claude Code can handle it deeply: remotion (React-based video framework), elevenlabs (audio), ffmpeg (media processing), playwright-recording (browser demo recording), frontend-design (visual design), qwen-edit (image editing), ideogram4 (image generation with strong in-image text), acestep (music), ltx2 (text/image-driven video clips), moviepy (Python video composition), and runpod (cloud GPU), for eleven skills in total.

The third is the template and brand layer. `templates/` includes sprint-review, sprint-review-v2, product-demo, and concept-explainer-short for 9:16 vertical shorts. `brands/` defines brand profiles holding colors, fonts, and voice settings, which are applied automatically when you create a project with `/video`. The diagram below shows how these three layers connect into a single pipeline.

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
<div class="d3-arch" data-arch-root id="23claudecodevideotoolkit-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 946, "height": 910, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 310, "y": 24, "w": 135, "h": 46, "title": "Prompt / Script"}, {"id": "B", "x": 313, "y": 148, "w": 128, "h": 46, "title": "/video command"}, {"id": "C", "x": 282, "y": 272, "w": 191, "h": 62, "title": ["Brand profile", "brand.json · voice.json"]}, {"id": "D", "x": 292, "y": 412, "w": 170, "h": 62, "title": ["Remotion composition", "React video"]}, {"id": "E", "x": 489, "y": 560, "w": 128, "h": 46, "title": "AI skill layer"}, {"id": "E1", "x": 793, "y": 692, "w": 121, "h": 62, "title": ["Qwen3-TTS", "voice · clone"]}, {"id": "E2", "x": 568, "y": 692, "w": 170, "h": 62, "title": ["FLUX.2 · Ideogram4", "images · title cards"]}, {"id": "E3", "x": 393, "y": 692, "w": 120, "h": 62, "title": ["ACE-Step", "music"]}, {"id": "E4", "x": 218, "y": 692, "w": 120, "h": 62, "title": ["LTX-2", "b-roll"]}, {"id": "F", "x": 28, "y": 552, "w": 149, "h": 62, "title": ["remotion render", "h264 · 1080p · 6x"]}, {"id": "G", "x": 42, "y": 700, "w": 121, "h": 46, "title": "out/video.mp4"}, {"id": "H", "x": 24, "y": 832, "w": 156, "h": 46, "title": "/publish → YouTube"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [377, 70, 377, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [377, 194, 377, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [377, 334, 377, 412]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[455, 474], [553, 513], [553, 513], [553, 560]]}, {"src": "E", "dst": "E1", "kind": "data", "curve": [[617, 598], [853, 653], [853, 653], [853, 692]]}, {"src": "E", "dst": "E2", "kind": "data", "curve": [[585, 606], [653, 653], [653, 653], [653, 692]]}, {"src": "E", "dst": "E3", "kind": "data", "curve": [[520, 606], [453, 653], [453, 653], [453, 692]]}, {"src": "E", "dst": "E4", "kind": "data", "curve": [[489, 599], [278, 653], [278, 653], [278, 692]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[292, 465], [102, 513], [102, 513], [102, 552]]}, {"src": "F", "dst": "G", "kind": "data", "line": [102, 614, 102, 700]}, {"src": "G", "dst": "H", "kind": "data", "line": [102, 746, 102, 832]}]});
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
      const container = document.getElementById('23claudecodevideotoolkit-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '23claudecodevideotoolkit-1';
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

The cost structure stands out in particular. The toolkit is designed so that generative assets such as voice (Qwen3-TTS), images (FLUX.2), and music (ACE-Step) depend on open-source models rather than commercial APIs. You deploy the models to your own cloud GPU account and run them at cost. For storage it points to Cloudflare R2's free tier (10GB, zero egress), and for compute to Modal's Starter plan with $30/month of free credit. This self-hosting-first choice maps precisely to the platform perspective discussed later.

## Installation and integration

The documented quick start is as follows: clone the repository, optionally install Python dependencies, and open Claude Code.

```shell
git clone https://github.com/digitalsamba/claude-code-video-toolkit.git
cd claude-code-video-toolkit
python3 -m pip install -r tools/requirements.txt   # Optional: AI voiceover, image gen, music, moviepy examples
claude                                              # Open Claude Code inside the toolkit
```

Then, inside Claude Code, you configure cloud GPU, storage, and voice interactively for about five minutes with `/setup`, and create your first project with `/video`. The requirements are Node.js 18+ and Claude Code; Python 3.9+ is recommended for AI tools. FFmpeg is optional.

What matters here is that there is a separate path to verify rendering immediately, with no setup. `examples/hello-world` is a minimal example that needs no API keys at all. I followed this path exactly and ran it for real.

```shell
cd examples/hello-world
npm install
npm run render
```

Looking at `hello-world`'s `package.json`, the render script is `npx remotion render src/index.ts SprintReview out/video.mp4`, and the dependencies are the Remotion 4.0.425 line and React 18. In other words, it bakes a React composition straight into video without any external model calls.

## Real experiment results

I ran the verification inside an isolated git worktree, and every number is taken directly from the run log. The environment was Apple Silicon (arm64), Node.js 24.1.0, and npm 11.3.0.

First, dependency installation. `npm install` added 230 packages and took about 3.5 seconds. The audit did report 10 vulnerabilities (7 moderate, 3 high), which I revisit in the limitations section.

In the render step, Remotion downloads Chrome Headless Shell once on the first run. In this run it downloaded about 90.2MB, a one-time cost. Bundling and composition followed. The composition was `SprintReview`, the codec h264, concurrency 6x, and it rendered all 750 frames. The log left the note "Cached bundle. Subsequent renders will be faster," making clear that subsequent runs are faster thanks to the bundle cache.

From a cold state, the wall-clock time for `npm run render`, including the download, bundling, rendering, and encoding, was 18.4 seconds. The final output was an h264 video at 1920x1080 resolution, 30fps, 25.0 seconds long, and 2.15MB (2,152,829 bytes), including an AAC audio track. Not a single API key was used.

![Per-stage measured times for the hello-world render pipeline]({{ '/assets/images/claude-code-video-toolkit-results.webp' | relative_url }})
*Per-stage wall-clock time of the hello-world 1080p render pipeline, measured with zero API keys.*

In short, with no separate setup, a single 1080p video was in hand within about 30 seconds of cloning. That was even faster than the example's "renders in 2 minutes" description, but since this can vary with hardware and network conditions, you should not take the number as absolute. What matters is that the barrier to entry is that low.

## Applying it to the ThakiCloud Kubernetes AI/ML SaaS platform

This toolkit is interesting because it structurally resembles the workloads our platform handles. Video rendering and generative asset synthesis are both GPU-bound batch jobs, with a pattern of using resources in short, intense bursts before returning to idle. ThakiCloud queues and prioritizes GPU jobs with Kueue on top of Kubernetes and serves models with vLLM and others. The Modal/Daytona-style serverless persistence the toolkit recommends, where the environment hibernates when idle and wakes on request, solves the same resource-efficiency problem we pursue with Kueue, just at a different layer.

The points worth highlighting are cost and self-hosting. The toolkit is designed to run open-weight models such as Qwen3-TTS, FLUX.2, and ACE-Step on your own GPU at cost rather than via commercial APIs. This aligns exactly with ThakiCloud's direction of treating on-premises and self-hosting as strengths. When a customer wants to operate generative workloads multi-tenant in a high-security environment without sending data or models outside, our platform can naturally accommodate this kind of video and media pipeline as well.

The internal use angle is clear too. The sprint-review and product-demo templates are artifacts engineering organizations produce repeatedly. If you wrap this video generation as Kubernetes jobs and put them on a Kueue queue, you can move heavy rendering from developers' laptops to a shared GPU pool processed by priority. The fact that the toolkit itself is tied to Claude Code is a constraint, but peeling off just the Remotion render stage and containerizing it makes it straightforward to place on our batch infrastructure.

## Limitations and counterpoints

There are clear weaknesses alongside the strengths. First, dependency security. Even the minimal example's `npm install` reported 10 vulnerabilities (including 3 high). To put it into production you need dependency auditing and pinning first, and it is safer to enforce this as a gate in your automation pipeline.

Second, the scope of the word "free." What works immediately without API keys is template-based rendering. To use generative assets such as voice, images, music, and b-roll, you ultimately have to deploy models to your own cloud GPU, and from that point on compute cost and operational burden appear. "Free" means running it yourself at cost, not that there is no cost.

Third, tool coupling. This workflow is strongly coupled to Claude Code. As convenient as the slash-command and skill abstractions are, there is an aspect of dependence on a specific agent environment. Fortunately the core rendering is handled by Remotion, an independent framework, so if needed you can separate that part and move it to a different orchestration.

Fourth, Remotion describes video in React. This can be a barrier for designers and non-developers, and handling complex motion graphics in code can take more effort than a dedicated editor. In the end this toolkit fits best with teams already comfortable handling video in code.

To sum up, claude-code-video-toolkit is a good starting point for code-friendly video automation. The experience of producing a 1080p video within 30 seconds with no API keys is a clear strength, and its open-source-model, self-hosting philosophy aligns well with our platform's direction. That said, you need to weigh the real cost of the generative asset stage, dependency security, and tool coupling together for a balanced judgment.

## Sources

- GitHub: [digitalsamba/claude-code-video-toolkit](https://github.com/digitalsamba/claude-code-video-toolkit)
- Remotion: [remotion.dev](https://www.remotion.dev/)
- Test environment: Apple Silicon (arm64), Node.js 24.1.0, npm 11.3.0 / all numbers extracted directly from run logs.
