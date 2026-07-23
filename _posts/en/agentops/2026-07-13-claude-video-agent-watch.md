---
title: "Claude Code Can Watch Videos: claude-video Feeds Frames and Transcripts Into the Agent via /watch"
excerpt: "Coding agents have long read only text. claude-video thinly wires yt-dlp, ffmpeg, and Whisper together to turn YouTube, Zoom, Loom, or local files into frame images and timestamped transcripts, then injects them into Claude's multimodal Read context. This post dissects the actual install and usage of this open-source skill (5,400+ GitHub stars) and its internals (captions-first, three-tier frame extraction, deduplication, transcription fallback), and reads what it means through ThakiCloud's Agent-Native Cloud Paxis skill harness and the ai-platform serving lens."
seo_title: "claude-video: The /watch Skill That Lets Claude Code See Videos - Thaki Cloud"
seo_description: "An analysis of claude-video (bradautomates): the /watch skill's captions-first yt-dlp path, three-tier ffmpeg frame extraction, 16x16 grayscale deduplication, and Whisper (Groq large-v3, OpenAI fallback) transcription injected via Claude multimodal Read, plus ThakiCloud Paxis and ai-platform implications."
date: 2026-07-13
last_modified_at: 2026-07-13
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/claude-video-agent-watch/"
tags:
  - agentops
  - claude-code
  - multimodal
  - agent-skills
  - video-understanding
  - ffmpeg
  - whisper
  - platform-engineering
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
categories:
  - agentops
---

## Overview

Coding agents have read only text until now. Source files, logs, docs, API responses, all of it was characters. Yet in practice, a large share of what matters lives inside videos. Product demo recordings, bug repro screens, meeting captures, lecture videos, competitor release clips. A human opens one and says "the screen breaks around 2:30," but to an agent that video was just an unopenable binary.

`claude-video` thinly tears down that wall. In one line it "gives Claude the ability to watch videos," and what it actually does is turn a video into frame images and a timestamped transcript, then push them into Claude's multimodal Read context. As of July 2026 it has passed 5,400 GitHub stars, and some counts put it as high as 7,000, making it one of the more talked-about projects of the moment.

The audience for this post is clear. Developers and platform engineers who use coding agents like Claude Code, Cursor, Copilot, and Gemini CLI in real work and wonder how to get video material into their pipeline. And anyone curious about what this technique means for agent platform design beyond mere convenience. The short answer: claude-video is a fine example of how "a thin harness plus a combination of proven tools" attaches a new sense (sight) to an agent, and it lines up exactly with the direction ThakiCloud pursues in Paxis.

![An abstract image depicting an agent gaining sight as video frames and audio waveforms flow into a single lens]({{ '/assets/images/claude-video-agent-watch-hero.png' | relative_url }})

## What This Tool Is

claude-video does not build a new model. It is a skill that thinly wires together three already-proven open-source tools. `yt-dlp` handles video download and caption retrieval, `ffmpeg` handles frame extraction and audio conversion, and `Whisper` handles speech transcription when captions are missing. Final assembly and judgment are done by Claude's multimodal Read tool. What is newly written is the pipeline joining these four pieces and the deduplication logic that intelligently thins out frames.

The core interface is a single `/watch` slash command. The user passes a video URL or a local path, attaches a question, and specifies a range if needed. The agent then "watches" the video and answers. The input sources are broad. Not just YouTube but Instagram, X, Vimeo, and generally any site yt-dlp supports, plus Zoom and Loom recordings and local mp4 files.

The full flow looks like this.

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
<div class="d3-arch" data-arch-root id="713claudevideoagentwatch-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 753, "height": 912, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 279, "y": 24, "w": 198, "h": 78, "title": ["Agent: /watch URL·path +", "question", "optional --start / --end"]}, {"id": "B", "x": 414, "y": 180, "w": 184, "h": 62, "title": ["yt-dlp: check captions", "first"]}, {"id": "C", "x": 430, "y": 333, "w": 153, "h": 52, "title": "Captions exist?"}, {"id": "D", "x": 537, "y": 514, "w": 184, "h": 62, "title": ["Use free captions as", "timestamped transcript"]}, {"id": "E", "x": 284, "y": 490, "w": 198, "h": 110, "title": ["Extract mono 16kHz audio", "then", "Whisper transcription", "Groq large-v3 first ·", "OpenAI fallback"]}, {"id": "F", "x": 31, "y": 320, "w": 191, "h": 78, "title": ["ffmpeg frame extraction", "efficient · balanced ·", "token-burner"]}, {"id": "G", "x": 24, "y": 506, "w": 205, "h": 78, "title": ["Deduplication", "16x16 grayscale · vs last", "kept frame"]}, {"id": "H", "x": 277, "y": 678, "w": 212, "h": 62, "title": ["Align by timestamp: frames", "+ transcript"]}, {"id": "I", "x": 288, "y": 818, "w": 191, "h": 62, "title": ["Inject into Claude", "multimodal Read context"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[442, 102], [506, 141], [506, 141], [506, 180]]}, {"src": "B", "dst": "C", "kind": "data", "line": [506, 242, 506, 333]}, {"src": "C", "dst": "D", "kind": "data", "label": "Yes", "curve": [[544, 385], [629, 444], [629, 444], [629, 514]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "No", "curve": [[468, 385], [383, 444], [383, 444], [383, 490]], "off": "50%"}, {"src": "A", "dst": "F", "kind": "data", "curve": [[279, 94], [127, 141], [127, 281], [127, 320]]}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 398, 127, 506]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[629, 576], [629, 639], [629, 639], [489, 679]]}, {"src": "E", "dst": "H", "kind": "data", "line": [383, 600, 383, 678]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[127, 584], [127, 639], [127, 639], [277, 680]]}, {"src": "H", "dst": "I", "kind": "data", "line": [383, 740, 383, 818]}]});
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
      const container = document.getElementById('713claudevideoagentwatch-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '713claudevideoagentwatch-1';
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

The difference from prior approaches is clear. Until now, "an AI summarizes a YouTube video" mostly meant reading only the title, description, and caption text and guessing. claude-video does not guess from the title. It sees the actual frames as images and reads the captions or transcript alongside, combining sight and hearing. Questions like what is on screen, or when exactly the UI breaks, cannot be answered from text captions alone; you have to see the frames.

## Installation and Usage

Installation goes two ways. Claude Code users attach it through the plugin marketplace.

```bash
# Claude Code: register the marketplace, then install the watch skill
/plugin marketplace add bradautomates/claude-video
/plugin install watch@claude-video
```

On the 50-odd agent hosts including Cursor, Copilot, and Gemini CLI, install it globally under the Agent Skills spec.

```bash
# Agent Skills spec (common across ~50 hosts)
npx skills add bradautomates/claude-video -g
```

No extra configuration is needed to start. If `yt-dlp` and `ffmpeg` are absent, they auto-install via brew on first run on macOS, and on Linux and Windows the exact install commands are printed. A Whisper API key is not always required; it is only needed when a video has no captions at all. Many public videos ship with captions and are handled on the free path.

Usage is a single command line.

```bash
# Ask a question about a local file
/watch tutorial.mp4 "What language is used in this tutorial?"

# Focus on a specific segment of a YouTube video
/watch https://youtu.be/VIDEO "What happens around 2:30?" --start 2:00 --end 3:00
```

`--start` and `--end` matter. Tearing an entire long video into frames blows up context and cost. Narrowing the range downloads only that portion and extracts frames from it, saving tokens. In practice the standard move is to narrow the scope, such as "only the 12-minute demo segment out of a 45-minute meeting recording."

## Internals: Captions First, Frame Extraction, Deduplication, Transcription

The reason claude-video is interesting is that practical judgment is baked into how the pieces are joined. Let us walk through the documented design step by step. The figures and parameters below are the design values published by the project, not benchmarks I measured in this environment.

First, transcription is captions-first. yt-dlp checks for existing captions first, and if present it uses them directly as a timestamped transcript without downloading the video body. It is immediate and free. Only when captions are absent does it extract mono 16kHz audio and hand it to Whisper. Here, for speed and cost, it prefers Groq's whisper-large-v3 and falls back to OpenAI whisper-1 if that is unavailable.

Second, frame extraction offers three detail levels. `efficient` decodes keyframes only and finishes almost instantly. `balanced` prefers scene-change frames but supplements with duration-aware uniform sampling when they under-produce. `token-burner` runs scene detection without a cap to pull maximum fidelity, burning tokens accordingly. You choose "skim fast, or look carefully" by purpose.

Third, deduplication is the small highlight of this project. Each extracted frame is scaled to a 16x16 grayscale thumbnail, and the mean absolute difference is computed not against the immediately preceding frame but against the **last kept frame**. If that value is at or below a threshold of 2.0, the frame is dropped. The reason for comparing against the last kept frame rather than the previous one is the key. Comparing frame to frame keeps passing very slow fade-in/out as "barely changed," but comparing against the last kept frame catches the moment when cumulative change crosses the threshold. It is a genuinely useful design for things like lecture videos where slides advance slowly.

Fourth, final assembly. Frame images and the transcript are aligned by timestamp, so frames enter Claude's context as images and the transcript as time-stamped text. Claude reads "at this moment the screen shows this, and this was said then" together and answers.

## What I Verified: Documented Behavior and a Reproduction Note

Let me be honest. The authoring environment for this post has external video downloads blocked, so I could not run a live benchmark that installs claude-video and actually tears a real YouTube video into frames. Therefore I invent no latency or accuracy figures. Instead I lay out the project's published design and behavior faithfully and leave reproducible verification points.

What is consistently confirmed across the docs and multiple user reports is the following. Public videos with captions are transcribed for free without downloading. Frame detail has three levels, efficient/balanced/token-burner, each differing in speed and fidelity. Deduplication uses 16x16 grayscale comparison with a threshold of 2.0. The transcription fallback path is Groq whisper-large-v3 then OpenAI whisper-1. The fork `mathiaschu/watch` offers a variant that swaps the transcription step for local `mlx-whisper`, running fully on-device with no API key.

To verify directly, I recommend this. Cut a short public video that has captions to a sub-one-minute segment with `--start`/`--end`, throw it at `/watch`, and run it at efficient and token-burner detail respectively, comparing frame counts and response tokens. This comparison most intuitively shows the effect of "range narrowing plus detail selection" on cost. Rather than citing numbers without measurement, measuring these two axes in your own environment is more accurate.

## Implications for ThakiCloud Products

claude-video naturally meshes with the two axes ThakiCloud is pushing.

First, the **Paxis lens**. Paxis is ThakiCloud's Agent-Native Cloud control plane, treating Skills, Tools, Policies, and Audit Logs as first-class resources. What claude-video demonstrates is exactly the "thin harness, thick skill" structure Paxis aims for. Without training a new model, it wires proven tools (yt-dlp, ffmpeg, Whisper) through a skill harness to attach a new sense to the agent. The Paxis Skill Harness selects from over 960 skills via BM25 and runs them in an isolated sandbox, and a multimodal skill like claude-video is a candidate to sit right on that harness. In particular, since video download and ffmpeg execution deal with arbitrary URLs and binaries, Paxis's sandboxed execution and policy gate plus audit logs pay off directly. When it is recorded in the audit log which video was processed, up to which range, at which detail, cost and data access can be controlled at once.

Next, the **ai-platform lens**. claude-video's transcription path fundamentally depends on external APIs (Groq, OpenAI). For customers with on-premises or sovereign requirements, that part is a risk as-is. Here ThakiCloud's ai-platform provides the answer. If you serve Whisper-class STT in-house on K8s with GPU scheduled by Kueue, you can finish video transcription inside a closed network without sending it out. It is the same direction the fork took by choosing mlx-whisper for local transcription, implemented at organizational scale. A pipeline that batch-transcribes large volumes of caption-less meeting recordings on an in-house GPU cluster, with agents consuming the results, is a textbook use case for the ai-platform, whose strengths are multi-tenant serving and cost efficiency.

The two lenses complement each other. When ai-platform backs low-cost, closed-network transcription and frame processing, Paxis orchestrates multimodal skills on top with policy and audit. The structure of "cheap infrastructure makes an agent's new sense economical" holds here as well.

## Limitations and Counterpoints

A few things must be stated plainly.

First, token cost. The moment frames enter the context as images, tokens pile up fast. Running a long video whole in token-burner mode can incur substantial cost per question. The discipline of narrowing with `--start`/`--end` and starting at efficient detail is essential. Used carelessly for the sake of convenience, the bill responds first.

Second, deduplication is not a panacea. 16x16 grayscale with a threshold of 2.0 fits videos with discrete change like slides and demos well, but on handheld footage with constant camera shake or screens where subtle text changes matter, it may miss or over-retain. The threshold is a candidate for tuning by video character.

Third, source trust and legal issues. Downloading videos from arbitrary sites with yt-dlp can conflict with the target service's terms and copyright. When putting it into an organizational pipeline, you must nail down by policy which sources are allowed, and this is precisely why a policy gate like Paxis is needed.

Fourth, external API dependence. If the transcription of caption-less videos goes out to Groq or OpenAI, data leaves the premises. For sensitive internal meeting recordings, that is exposure as-is unless you switch the path to the in-house Whisper serving mentioned above.

Even so, the big picture holds. claude-video broke the premise that "coding agents only read text" in a thin, practical way. The approach of extending a sense through a combination of proven tools rather than a new model is a pattern worth continually referencing from the standpoint of designing agent platforms.

## Sources

- [bradautomates/claude-video (GitHub)](https://github.com/bradautomates/claude-video)
- [claude-video/README.md (GitHub)](https://github.com/bradautomates/claude-video/blob/main/README.md)
- [mathiaschu/watch, mlx-whisper local transcription fork (GitHub)](https://github.com/mathiaschu/watch)
- [claude-video: Let Claude Watch Videos with /watch (knightli.com)](https://knightli.com/en/2026/07/08/claude-video-watch-video-transcript-frames-skill/)
- [Claude Video: The Open-Source Tool That Lets AI Coding Agents Watch and Analyze Any Video (CoddyKit)](https://www.coddykit.com/pages/blog-detail?id=512902&slug=claude-video-the-open-source-tool-that-lets-ai-coding-agents-watch-and-analyze-a)
