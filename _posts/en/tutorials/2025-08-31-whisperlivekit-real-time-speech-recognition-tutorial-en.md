---
title: "WhisperLiveKit: Complete Guide to Real-Time Speech Recognition with Ultra-Low Latency"
excerpt: "Master WhisperLiveKit, the cutting-edge real-time speech transcription system powered by SOTA research. Learn to build production-ready voice applications with SimulStreaming, speaker diarization, and web UI integration."
seo_title: "WhisperLiveKit Real-Time Speech Recognition Tutorial - Complete Guide - Thaki Cloud"
seo_description: "Learn to implement WhisperLiveKit for real-time speech transcription with ultra-low latency. Complete tutorial covering installation, configuration, and advanced features like speaker diarization."
date: 2025-08-31
tags:
  - WhisperLiveKit
  - real-time-speech
  - speech-recognition
  - SimulStreaming
  - voice-activity-detection
  - speaker-diarization
  - WebSocket
  - FastAPI
  - Python
author_profile: true
toc: true
toc_label: "Table of Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/whisperlivekit-real-time-speech-recognition-tutorial/"
lang: en
permalink: /en/tutorials/whisperlivekit-real-time-speech-recognition-tutorial/
published: false
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

Real-time speech recognition has evolved dramatically with the emergence of streaming-optimized models and advanced research breakthroughs. **WhisperLiveKit** represents the state-of-the-art in real-time speech transcription, combining cutting-edge research from SimulStreaming (SOTA 2025), WhisperStreaming (SOTA 2023), and advanced speaker diarization systems.

Unlike traditional batch-processing approaches that struggle with real-time constraints, WhisperLiveKit leverages intelligent buffering, incremental processing, and voice activity detection to deliver ultra-low latency transcription directly to your browser.

This comprehensive guide will walk you through implementing WhisperLiveKit for production-ready real-time speech applications, from basic setup to advanced features like speaker identification and multi-user support.

## Why WhisperLiveKit Over Standard Whisper?

### The Real-Time Challenge

Standard Whisper models are designed for complete utterances, not real-time audio chunks. Processing small segments leads to:

- **Context Loss**: Missing conversational flow and sentence boundaries
- **Word Fragmentation**: Cutting off words mid-syllable
- **Poor Accuracy**: Degraded transcription quality on incomplete audio
- **High Latency**: Batch processing delays

### WhisperLiveKit's Innovation

WhisperLiveKit solves these challenges through:

```python
# Traditional Approach (Problematic)
def process_audio_chunk(chunk):
    return whisper.transcribe(chunk)  # Loses context, poor quality

# WhisperLiveKit Approach (Optimized)
def process_streaming_audio(stream):
    # Intelligent buffering with context preservation
    # Voice Activity Detection for efficiency
    # SimulStreaming for ultra-low latency
    # Incremental processing with LocalAgreement
    return optimized_transcription
```

## Core Technologies and Architecture

### State-of-the-Art Research Integration

**SimulStreaming (SOTA 2025)**:
- Ultra-low latency transcription with AlignAtt policy
- Frame-level attention guidance for optimal processing timing
- Advanced beam search optimization

**WhisperStreaming (SOTA 2023)**:
- LocalAgreement policy for consistent streaming output
- Intelligent buffer management and trimming strategies

**Advanced Speaker Diarization**:
- Streaming Sortformer (SOTA 2025) for real-time speaker identification
- Diart (SOTA 2021) integration for production environments

**Enterprise-Grade VAD**:
- Silero VAD (2024) for accurate voice activity detection
- Reduces computational overhead during silence periods

### System Architecture

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
<div class="d3-arch" data-arch-root id="echrecognitiontutorialen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 671, "height": 846, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 63, "y": 24, "w": 120, "h": 46, "title": "Audio Input"}, {"id": "B", "x": 24, "y": 148, "w": 198, "h": 46, "title": "Voice Activity Detection"}, {"id": "C", "x": 147, "y": 272, "w": 191, "h": 46, "title": "Audio Buffer Management"}, {"id": "D", "x": 272, "y": 396, "w": 177, "h": 46, "title": "SimulStreaming Engine"}, {"id": "E", "x": 279, "y": 520, "w": 163, "h": 46, "title": "Speaker Diarization"}, {"id": "F", "x": 393, "y": 644, "w": 142, "h": 46, "title": "WebSocket Server"}, {"id": "G", "x": 404, "y": 768, "w": 121, "h": 46, "title": "Web UI Client"}, {"id": "H", "x": 497, "y": 520, "w": 142, "h": 46, "title": "Multiple Clients"}, {"id": "I", "x": 393, "y": 272, "w": 170, "h": 46, "title": "Real-time Processing"}, {"id": "J", "x": 277, "y": 148, "w": 170, "h": 46, "title": "Context Preservation"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [123, 70, 123, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[123, 194], [123, 233], [123, 233], [198, 272]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[243, 318], [243, 357], [243, 357], [317, 396]]}, {"src": "D", "dst": "E", "kind": "data", "line": [360, 442, 360, 520]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[360, 566], [360, 605], [360, 605], [426, 644]]}, {"src": "F", "dst": "G", "kind": "data", "line": [464, 690, 464, 768]}, {"src": "H", "dst": "F", "kind": "data", "curve": [[568, 566], [568, 605], [568, 605], [502, 644]]}, {"src": "I", "dst": "D", "kind": "data", "curve": [[478, 318], [478, 357], [478, 357], [404, 396]]}, {"src": "J", "dst": "C", "kind": "data", "curve": [[362, 194], [362, 233], [362, 233], [287, 272]]}]});
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
      const container = document.getElementById('echrecognitiontutorialen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'echrecognitiontutorialen-1';
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

The architecture supports multiple concurrent users with intelligent resource management and voice activity detection to optimize performance.

## Installation and Setup

### Prerequisites

**System Requirements**:
- Python 3.8+
- FFmpeg (required for audio processing)
- 4GB+ RAM (8GB+ recommended for larger models)
- Optional: NVIDIA GPU for accelerated processing

### FFmpeg Installation

```bash
# macOS
brew install ffmpeg

# Ubuntu/Debian
sudo apt install ffmpeg

# Windows
# Download from https://ffmpeg.org/download.html and add to PATH
```

### WhisperLiveKit Installation

```bash
# Create isolated environment
python3 -m venv whisperlivekit-env
source whisperlivekit-env/bin/activate  # On Windows: whisperlivekit-env\Scripts\activate

# Install WhisperLiveKit
pip install whisperlivekit

# Verify installation
whisperlivekit-server --help
```

## Quick Start Guide

### Basic Server Launch

```bash
# Start with default settings (small model, auto language detection)
whisperlivekit-server --model base --language en

# Server starts on http://localhost:8000
# Web UI automatically available at the same address
```

### Testing the Installation

1. **Start the server**:
```bash
whisperlivekit-server --model tiny --language en --host localhost --port 8000
```

2. **Open your browser** and navigate to `http://localhost:8000`

3. **Grant microphone permissions** when prompted

4. **Start speaking** and watch real-time transcription appear

### Verification Script

```python
# test_whisperlivekit.py
import asyncio
import websockets
import json
import pyaudio
import wave

async def test_websocket_connection():
    """Test WebSocket connection to WhisperLiveKit server"""
    uri = "ws://localhost:8000/ws"
    
    try:
        async with websockets.connect(uri) as websocket:
            print("✅ WebSocket connection successful")
            
            # Send test message
            test_message = {
                "type": "audio_chunk",
                "data": "test_audio_data"
            }
            
            await websocket.send(json.dumps(test_message))
            response = await websocket.recv()
            print(f"📨 Server response: {response}")
            
    except Exception as e:
        print(f"❌ Connection failed: {e}")

# Run test
asyncio.run(test_websocket_connection())
```

## Advanced Configuration

### Model Selection and Performance

```bash
# Ultra-fast processing (lower accuracy)
whisperlivekit-server --model tiny --language en

# Balanced performance (recommended for most use cases)
whisperlivekit-server --model base --language en

# High accuracy (requires more resources)
whisperlivekit-server --model large-v3 --language en

# Multilingual support with auto-detection
whisperlivekit-server --model base --language auto
```

### Backend Selection

```bash
# SimulStreaming (SOTA 2025) - Ultra-low latency
whisperlivekit-server --backend simulstreaming --model base

# Faster-Whisper - Optimized performance
whisperlivekit-server --backend faster-whisper --model base

# WhisperStreaming - LocalAgreement policy
whisperlivekit-server --backend whisper_timestamped --model base
```

### SimulStreaming Advanced Configuration

```bash
# Fine-tune latency vs accuracy
whisperlivekit-server \
  --backend simulstreaming \
  --model base \
  --frame-threshold 25 \
  --beams 1 \
  --audio-max-len 30.0 \
  --never-fire
```

**Key Parameters**:
- `--frame-threshold`: Lower = faster, higher = more accurate (default: 25)
- `--beams`: Beam search beams (1 = greedy, >1 = beam search)
- `--audio-max-len`: Maximum audio buffer length in seconds
- `--never-fire`: Never truncate incomplete words

## Speaker Diarization Setup

### Basic Speaker Identification

```bash
# Enable speaker diarization with Sortformer (SOTA 2025)
whisperlivekit-server \
  --model base \
  --language en \
  --diarization \
  --diarization-backend sortformer
```

### Advanced Diarization with Diart

```bash
# Diart backend with custom models
whisperlivekit-server \
  --model base \
  --language en \
  --diarization \
  --diarization-backend diart \
  --segmentation-model pyannote/segmentation-3.0 \
  --embedding-model speechbrain/spkrec-ecapa-voxceleb
```

### Hugging Face Authentication for Pyannote

```bash
# Required for pyannote.audio models
pip install huggingface_hub
huggingface-cli login

# Accept user conditions for required models:
# 1. pyannote/segmentation
# 2. pyannote/segmentation-3.0  
# 3. pyannote/embedding
```

## Production Deployment

### Docker Deployment

**GPU-Accelerated Container**:
```dockerfile
# Dockerfile
FROM nvidia/cuda:11.8-runtime-ubuntu20.04

RUN apt-get update && apt-get install -y \
    python3 python3-pip ffmpeg \
    && rm -rf /var/lib/apt/lists/*

RUN pip install whisperlivekit

EXPOSE 8000

CMD ["whisperlivekit-server", "--model", "base", "--language", "en", "--host", "0.0.0.0"]
```

```bash
# Build and run
docker build -t whisperlivekit .
docker run --gpus all -p 8000:8000 whisperlivekit
```

**CPU-Only Container**:
```bash
# Use pre-built CPU image
docker run -p 8000:8000 whisperlivekit/cpu:latest
```

### Production Server Configuration

```bash
# Production-ready configuration
whisperlivekit-server \
  --model base \
  --language en \
  --host 0.0.0.0 \
  --port 8000 \
  --ssl-certfile /path/to/cert.pem \
  --ssl-keyfile /path/to/key.pem \
  --diarization \
  --preloaded_model_count 4 \
  --min-chunk-size 1.0 \
  --buffer_trimming sentence
```

### Load Balancing with Nginx

```nginx
# /etc/nginx/sites-available/whisperlivekit
upstream whisperlivekit_backend {
    server 127.0.0.1:8000;
    server 127.0.0.1:8001;
    server 127.0.0.1:8002;
    server 127.0.0.1:8003;
}

server {
    listen 80;
    server_name your-domain.com;

    location / {
        proxy_pass http://whisperlivekit_backend;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
    }
}
```

## Custom Web Integration

### Basic WebSocket Client

```javascript
// whisperlivekit-client.js
class WhisperLiveKitClient {
    constructor(serverUrl = 'ws://localhost:8000/ws') {
        this.serverUrl = serverUrl;
        this.websocket = null;
        this.mediaRecorder = null;
        this.audioContext = null;
    }

    async connect() {
        try {
            this.websocket = new WebSocket(this.serverUrl);
            
            this.websocket.onopen = () => {
                console.log('✅ Connected to WhisperLiveKit');
                this.startAudioCapture();
            };

            this.websocket.onmessage = (event) => {
                const data = JSON.parse(event.data);
                this.handleTranscription(data);
            };

            this.websocket.onerror = (error) => {
                console.error('❌ WebSocket error:', error);
            };

        } catch (error) {
            console.error('Connection failed:', error);
        }
    }

    async startAudioCapture() {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ 
                audio: {
                    sampleRate: 16000,
                    channelCount: 1,
                    echoCancellation: true,
                    noiseSuppression: true
                } 
            });

            this.audioContext = new AudioContext({ sampleRate: 16000 });
            const source = this.audioContext.createMediaStreamSource(stream);
            
            // Process audio in real-time
            this.processAudioStream(source);

        } catch (error) {
            console.error('Microphone access denied:', error);
        }
    }

    processAudioStream(source) {
        const processor = this.audioContext.createScriptProcessor(4096, 1, 1);
        
        processor.onaudioprocess = (event) => {
            const audioData = event.inputBuffer.getChannelData(0);
            
            // Convert to 16-bit PCM
            const pcmData = new Int16Array(audioData.length);
            for (let i = 0; i < audioData.length; i++) {
                pcmData[i] = Math.max(-32768, Math.min(32767, audioData[i] * 32768));
            }

            // Send to server
            if (this.websocket && this.websocket.readyState === WebSocket.OPEN) {
                this.websocket.send(pcmData.buffer);
            }
        };

        source.connect(processor);
        processor.connect(this.audioContext.destination);
    }

    handleTranscription(data) {
        if (data.type === 'transcription') {
            this.displayTranscription(data.text, data.speaker);
        }
    }

    displayTranscription(text, speaker = null) {
        const transcriptionDiv = document.getElementById('transcription');
        const timestamp = new Date().toLocaleTimeString();
        
        const entry = document.createElement('div');
        entry.className = 'transcription-entry';
        entry.innerHTML = `
            <span class="timestamp">${timestamp}</span>
            ${speaker ? `<span class="speaker">Speaker ${speaker}:</span>` : ''}
            <span class="text">${text}</span>
        `;
        
        transcriptionDiv.appendChild(entry);
        transcriptionDiv.scrollTop = transcriptionDiv.scrollHeight;
    }
}

// Usage
const client = new WhisperLiveKitClient();
client.connect();
```

### React Integration

```jsx
// WhisperLiveKitComponent.jsx
import React, { useState, useEffect, useRef } from 'react';

const WhisperLiveKitComponent = () => {
    const [transcriptions, setTranscriptions] = useState([]);
    const [isConnected, setIsConnected] = useState(false);
    const [isRecording, setIsRecording] = useState(false);
    const websocketRef = useRef(null);
    const mediaRecorderRef = useRef(null);

    useEffect(() => {
        connectToServer();
        return () => {
            if (websocketRef.current) {
                websocketRef.current.close();
            }
        };
    }, []);

    const connectToServer = () => {
        const ws = new WebSocket('ws://localhost:8000/ws');
        
        ws.onopen = () => {
            setIsConnected(true);
            console.log('Connected to WhisperLiveKit');
        };

        ws.onmessage = (event) => {
            const data = JSON.parse(event.data);
            if (data.type === 'transcription') {
                setTranscriptions(prev => [...prev, {
                    id: Date.now(),
                    text: data.text,
                    speaker: data.speaker,
                    timestamp: new Date().toLocaleTimeString()
                }]);
            }
        };

        ws.onclose = () => {
            setIsConnected(false);
            console.log('Disconnected from WhisperLiveKit');
        };

        websocketRef.current = ws;
    };

    const startRecording = async () => {
        try {
            const stream = await navigator.mediaDevices.getUserMedia({ 
                audio: {
                    sampleRate: 16000,
                    channelCount: 1,
                    echoCancellation: true,
                    noiseSuppression: true
                }
            });

            const mediaRecorder = new MediaRecorder(stream, {
                mimeType: 'audio/webm;codecs=opus'
            });

            mediaRecorder.ondataavailable = (event) => {
                if (event.data.size > 0 && websocketRef.current?.readyState === WebSocket.OPEN) {
                    websocketRef.current.send(event.data);
                }
            };

            mediaRecorder.start(100); // Send data every 100ms
            mediaRecorderRef.current = mediaRecorder;
            setIsRecording(true);

        } catch (error) {
            console.error('Failed to start recording:', error);
        }
    };

    const stopRecording = () => {
        if (mediaRecorderRef.current) {
            mediaRecorderRef.current.stop();
            mediaRecorderRef.current = null;
            setIsRecording(false);
        }
    };

    return (
        <div className="whisperlivekit-container">
            <div className="controls">
                <div className={`status ${isConnected ? 'connected' : 'disconnected'}`}>
                    {isConnected ? '🟢 Connected' : '🔴 Disconnected'}
                </div>
                
                <button 
                    onClick={isRecording ? stopRecording : startRecording}
                    disabled={!isConnected}
                    className={`record-button ${isRecording ? 'recording' : ''}`}
                >
                    {isRecording ? '⏹️ Stop Recording' : '🎤 Start Recording'}
                </button>
            </div>

            <div className="transcriptions">
                <h3>Real-time Transcription</h3>
                <div className="transcription-list">
                    {transcriptions.map(item => (
                        <div key={item.id} className="transcription-item">
                            <span className="timestamp">{item.timestamp}</span>
                            {item.speaker && <span className="speaker">Speaker {item.speaker}:</span>}
                            <span className="text">{item.text}</span>
                        </div>
                    ))}
                </div>
            </div>
        </div>
    );
};

export default WhisperLiveKitComponent;
```

## Performance Optimization

### Model Selection Strategy

```python
# performance_config.py
PERFORMANCE_CONFIGS = {
    'ultra_fast': {
        'model': 'tiny',
        'backend': 'simulstreaming',
        'frame_threshold': 15,
        'beams': 1,
        'min_chunk_size': 0.5
    },
    'balanced': {
        'model': 'base',
        'backend': 'simulstreaming', 
        'frame_threshold': 25,
        'beams': 1,
        'min_chunk_size': 1.0
    },
    'high_accuracy': {
        'model': 'large-v3',
        'backend': 'faster-whisper',
        'beams': 5,
        'min_chunk_size': 2.0
    }
}

def get_optimal_config(use_case):
    """Select optimal configuration based on use case"""
    if use_case == 'live_streaming':
        return PERFORMANCE_CONFIGS['ultra_fast']
    elif use_case == 'meeting_transcription':
        return PERFORMANCE_CONFIGS['balanced']
    elif use_case == 'legal_documentation':
        return PERFORMANCE_CONFIGS['high_accuracy']
```

### Resource Management

```bash
# Multi-instance deployment for high concurrency
# Instance 1: Ultra-fast processing
whisperlivekit-server --model tiny --port 8001 --preloaded_model_count 2

# Instance 2: Balanced processing  
whisperlivekit-server --model base --port 8002 --preloaded_model_count 2

# Instance 3: High-accuracy processing
whisperlivekit-server --model large-v3 --port 8003 --preloaded_model_count 1
```

## Troubleshooting Guide

### Common Issues and Solutions

**1. Server Won't Start**
```bash
# Check FFmpeg installation
ffmpeg -version

# Verify Python environment
python -c "import whisperlivekit; print('✅ Installation OK')"

# Check port availability
lsof -i :8000
```

**2. Poor Transcription Quality**
```bash
# Increase model size
whisperlivekit-server --model base  # Instead of tiny

# Adjust chunk size
whisperlivekit-server --min-chunk-size 2.0

# Enable confidence validation
whisperlivekit-server --confidence-validation
```

**3. High Latency Issues**
```bash
# Use SimulStreaming backend
whisperlivekit-server --backend simulstreaming --frame-threshold 15

# Reduce audio buffer
whisperlivekit-server --audio-max-len 15.0

# Enable VAD optimization
whisperlivekit-server --vac-chunk-size 0.5
```

**4. WebSocket Connection Issues**
```javascript
// Add connection retry logic
class RobustWhisperClient {
    constructor(serverUrl) {
        this.serverUrl = serverUrl;
        this.reconnectAttempts = 0;
        this.maxReconnectAttempts = 5;
    }

    connect() {
        this.websocket = new WebSocket(this.serverUrl);
        
        this.websocket.onclose = () => {
            if (this.reconnectAttempts < this.maxReconnectAttempts) {
                setTimeout(() => {
                    this.reconnectAttempts++;
                    this.connect();
                }, 1000 * this.reconnectAttempts);
            }
        };
    }
}
```

### Performance Monitoring

```python
# monitoring.py
import psutil
import time
import requests

def monitor_whisperlivekit_performance():
    """Monitor WhisperLiveKit server performance"""
    while True:
        try:
            # Check server health
            response = requests.get('http://localhost:8000/health', timeout=5)
            
            # Monitor system resources
            cpu_percent = psutil.cpu_percent(interval=1)
            memory_percent = psutil.virtual_memory().percent
            
            print(f"🖥️  CPU: {cpu_percent}% | 💾 Memory: {memory_percent}%")
            
            if cpu_percent > 80:
                print("⚠️  High CPU usage detected")
            
            if memory_percent > 80:
                print("⚠️  High memory usage detected")
                
        except Exception as e:
            print(f"❌ Health check failed: {e}")
        
        time.sleep(10)

if __name__ == "__main__":
    monitor_whisperlivekit_performance()
```

## Real-World Use Cases

### 1. Live Meeting Transcription

```python
# meeting_transcriber.py
import asyncio
import websockets
import json
from datetime import datetime

class MeetingTranscriber:
    def __init__(self):
        self.transcriptions = []
        self.meeting_id = datetime.now().strftime("%Y%m%d_%H%M%S")
    
    async def start_meeting_transcription(self):
        uri = "ws://localhost:8000/ws"
        
        async with websockets.connect(uri) as websocket:
            print(f"📝 Meeting transcription started: {self.meeting_id}")
            
            async for message in websocket:
                data = json.loads(message)
                
                if data['type'] == 'transcription':
                    entry = {
                        'timestamp': datetime.now().isoformat(),
                        'speaker': data.get('speaker', 'Unknown'),
                        'text': data['text']
                    }
                    
                    self.transcriptions.append(entry)
                    print(f"[{entry['timestamp']}] Speaker {entry['speaker']}: {entry['text']}")
    
    def export_meeting_notes(self):
        """Export meeting transcription to file"""
        filename = f"meeting_{self.meeting_id}.json"
        with open(filename, 'w') as f:
            json.dump(self.transcriptions, f, indent=2)
        print(f"📄 Meeting notes exported to {filename}")

# Usage
transcriber = MeetingTranscriber()
asyncio.run(transcriber.start_meeting_transcription())
```

### 2. Customer Service Call Analysis

```python
# call_analyzer.py
import re
from collections import Counter

class CallAnalyzer:
    def __init__(self):
        self.sentiment_keywords = {
            'positive': ['great', 'excellent', 'satisfied', 'happy', 'good'],
            'negative': ['terrible', 'awful', 'disappointed', 'angry', 'bad'],
            'neutral': ['okay', 'fine', 'average', 'normal']
        }
    
    def analyze_call_transcription(self, transcriptions):
        """Analyze customer service call for insights"""
        analysis = {
            'total_duration': len(transcriptions),
            'speaker_distribution': Counter(),
            'sentiment_analysis': {'positive': 0, 'negative': 0, 'neutral': 0},
            'key_topics': [],
            'action_items': []
        }
        
        for entry in transcriptions:
            speaker = entry['speaker']
            text = entry['text'].lower()
            
            # Speaker distribution
            analysis['speaker_distribution'][speaker] += 1
            
            # Sentiment analysis
            for sentiment, keywords in self.sentiment_keywords.items():
                if any(keyword in text for keyword in keywords):
                    analysis['sentiment_analysis'][sentiment] += 1
            
            # Extract action items
            if any(phrase in text for phrase in ['will follow up', 'will send', 'will call back']):
                analysis['action_items'].append(entry)
        
        return analysis
    
    def generate_call_summary(self, analysis):
        """Generate executive summary of the call"""
        summary = f"""
        📞 Call Analysis Summary
        ========================
        Total Interactions: {analysis['total_duration']}
        
        Speaker Distribution:
        {dict(analysis['speaker_distribution'])}
        
        Sentiment Analysis:
        - Positive: {analysis['sentiment_analysis']['positive']}
        - Negative: {analysis['sentiment_analysis']['negative']}  
        - Neutral: {analysis['sentiment_analysis']['neutral']}
        
        Action Items: {len(analysis['action_items'])}
        """
        
        return summary
```

### 3. Accessibility Integration

```javascript
// accessibility_integration.js
class AccessibilityTranscriber {
    constructor() {
        this.isHighContrast = false;
        this.fontSize = 'medium';
        this.speechRate = 1.0;
    }

    setupAccessibilityFeatures() {
        // High contrast mode
        this.addHighContrastToggle();
        
        // Font size controls
        this.addFontSizeControls();
        
        // Text-to-speech for transcriptions
        this.addTextToSpeech();
        
        // Keyboard navigation
        this.addKeyboardShortcuts();
    }

    addHighContrastToggle() {
        const toggle = document.createElement('button');
        toggle.textContent = '🎨 High Contrast';
        toggle.onclick = () => {
            this.isHighContrast = !this.isHighContrast;
            document.body.classList.toggle('high-contrast', this.isHighContrast);
        };
        document.getElementById('accessibility-controls').appendChild(toggle);
    }

    addTextToSpeech() {
        const speakButton = document.createElement('button');
        speakButton.textContent = '🔊 Read Aloud';
        speakButton.onclick = () => {
            const transcriptionText = document.getElementById('transcription').textContent;
            const utterance = new SpeechSynthesisUtterance(transcriptionText);
            utterance.rate = this.speechRate;
            speechSynthesis.speak(utterance);
        };
        document.getElementById('accessibility-controls').appendChild(speakButton);
    }

    addKeyboardShortcuts() {
        document.addEventListener('keydown', (event) => {
            // Ctrl+R: Start/Stop recording
            if (event.ctrlKey && event.key === 'r') {
                event.preventDefault();
                this.toggleRecording();
            }
            
            // Ctrl+S: Save transcription
            if (event.ctrlKey && event.key === 's') {
                event.preventDefault();
                this.saveTranscription();
            }
            
            // Ctrl+Plus: Increase font size
            if (event.ctrlKey && event.key === '=') {
                event.preventDefault();
                this.increaseFontSize();
            }
        });
    }
}
```

## Advanced Features and Customization

### Custom Language Models

```python
# custom_model_integration.py
from whisperlivekit import WhisperLiveKitServer

class CustomWhisperServer(WhisperLiveKitServer):
    def __init__(self, custom_model_path):
        super().__init__()
        self.custom_model_path = custom_model_path
    
    def load_custom_model(self):
        """Load domain-specific fine-tuned model"""
        # Implementation for custom model loading
        pass
    
    def apply_domain_specific_processing(self, transcription):
        """Apply domain-specific post-processing"""
        # Medical terminology correction
        medical_corrections = {
            'heart attack': 'myocardial infarction',
            'high blood pressure': 'hypertension'
        }
        
        for term, correction in medical_corrections.items():
            transcription = transcription.replace(term, correction)
        
        return transcription
```

### Integration with External Services

```python
# external_integrations.py
import requests
import json

class ExternalServiceIntegrator:
    def __init__(self):
        self.slack_webhook = "YOUR_SLACK_WEBHOOK_URL"
        self.teams_webhook = "YOUR_TEAMS_WEBHOOK_URL"
    
    async def send_to_slack(self, transcription_data):
        """Send transcription to Slack channel"""
        message = {
            "text": f"🎤 New Transcription",
            "attachments": [{
                "color": "good",
                "fields": [{
                    "title": "Speaker",
                    "value": transcription_data.get('speaker', 'Unknown'),
                    "short": True
                }, {
                    "title": "Text",
                    "value": transcription_data['text'],
                    "short": False
                }]
            }]
        }
        
        response = requests.post(self.slack_webhook, json=message)
        return response.status_code == 200
    
    async def save_to_database(self, transcription_data):
        """Save transcription to database"""
        # Database integration logic
        pass
    
    async def trigger_workflow(self, transcription_data):
        """Trigger automated workflow based on transcription content"""
        # Workflow automation logic
        pass
```

## Conclusion

WhisperLiveKit represents a significant advancement in real-time speech recognition technology, combining state-of-the-art research with practical production-ready features. Through this comprehensive guide, you've learned to:

### Key Achievements

1. **Master Real-Time Speech Processing**: Understand the fundamental differences between batch and streaming speech recognition
2. **Implement Production Systems**: Deploy scalable, multi-user speech transcription services
3. **Advanced Feature Integration**: Leverage speaker diarization, voice activity detection, and custom backends
4. **Performance Optimization**: Configure systems for optimal latency and accuracy trade-offs
5. **Real-World Applications**: Build meeting transcribers, accessibility tools, and customer service analyzers

### Technical Highlights

- **Ultra-Low Latency**: SimulStreaming backend with frame-level attention guidance
- **Enterprise-Grade Features**: Multi-user support, speaker identification, SSL/TLS security
- **Flexible Architecture**: WebSocket-based real-time communication with web UI integration
- **Production Ready**: Docker deployment, load balancing, monitoring, and error handling

### Next Steps

Consider exploring these advanced topics:

- **Custom Model Fine-Tuning**: Adapt models for domain-specific terminology
- **Multi-Modal Integration**: Combine with video processing for comprehensive meeting analysis
- **Edge Deployment**: Optimize for mobile and IoT devices
- **Advanced Analytics**: Implement sentiment analysis and conversation intelligence

WhisperLiveKit's combination of cutting-edge research and practical implementation makes it an ideal choice for building the next generation of voice-enabled applications. Whether you're developing accessibility tools, meeting transcription systems, or customer service analytics, WhisperLiveKit provides the foundation for reliable, scalable real-time speech recognition.

---

**Related Resources**:
- [WhisperLiveKit GitHub Repository](https://github.com/QuentinFuxa/WhisperLiveKit)
- [SimulStreaming Research Paper](https://arxiv.org/abs/2406.03049)
- [Pyannote.audio Documentation](https://github.com/pyannote/pyannote-audio)
- [FastAPI WebSocket Guide](https://fastapi.tiangolo.com/advanced/websockets/)
