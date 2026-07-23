---
title: "Where Does a Real-Time Voice Agent Actually Bottleneck: A Latency Budget Calculator and GPU Serving Measurements"
seo_title: "Real-Time Voice Agent Latency Budget + Self-Hosted GPU Benchmark - Thaki Cloud"
seo_description: "We introduce voice-latency-budget, an open calculator that breaks down the delay from end-of-utterance to first response sound into stages to diagnose bottlenecks, and share measurements of our actual stack (Qwen3-ASR, VoxCPM2, Qwen3-TTS, Qwen3.5-9B) on a RunPod H200 to show where the real bottleneck in a self-hosted voice stack lies. We also publish a reproducible download-once network volume cost-optimization and teardown-guaranteed harness."
excerpt: "We built an open tool that diagnoses which stage of your voice agent is the bottleneck, without any vendor SDK, and measured our actual stack (Qwen3-ASR, VoxCPM2, Qwen3-TTS) on a RunPod H200. STT was fast; non-streaming TTS was the real bottleneck."
date: 2026-07-19
tags:
  - voice-agent
  - latency
  - vllm
  - qwen3-asr
  - voxcpm2
  - qwen3-tts
  - runpod
  - gpu-serving
  - ttft
  - llmops
  - real-time
categories:
  - llmops
author_profile: true
toc: true
toc_label: Contents
published: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/voice-agent-latency-budget-gpu-serving/"
---

Anyone who has built a real-time voice agent runs into the same wall. Once the delay between the user stopping speaking and the agent making its first sound grows even a little, the conversation starts to feel off. Yet the moment you ask "which stage of my stack is slow," the answer does not come easily. End-of-utterance detection, network round-trip, speech-to-text (STT), the LLM's first token, and text-to-speech (TTS) are chained together, and each vendor's SDK only shows you the numbers for its own segment. This post covers an open tool we built, voice-latency-budget, to diagnose that entire chain at a glance, along with the results of measuring its self-hosting scenario on actual GPUs. This post is written for infrastructure and AI engineers who want to serve a real-time voice agent themselves. The short version: in GPU self-hosting, the latency bottleneck was not the LLM, as one might commonly assume, but concurrency design and TTS choice.

## Why We Need a Latency Budget Framing

Research shows that when two people talk, the gap between one person finishing speaking and the other responding converges to a median of about 200 milliseconds regardless of language (Stivers et al., 2009, PNAS). For a real-time voice agent to feel "human," the time from end-of-utterance to the first response sound needs to be close to that range, and in practice, staying under sub-second, that is, under 800 ms, is a common target. This number roughly matches the targets vendors publish too. Deepgram cites under 300 ms, Vapi cites under 500 ms.

The question is how to split that total budget. If the network eats 40 ms round-trip, STT takes 300 ms, and the LLM's first token takes 500 ms, the budget is already blown. It is hard to judge by gut feeling which stage to cut for the biggest gain. So we built a calculator that shows the cumulative timeline, the bottleneck, and whether you land within a natural conversational range the moment you enter each stage's expected latency. It runs entirely client-side, with no server and no API key, and your inputs never leave the browser. We aimed for a public-good tool that does not promote any particular product.

The tool covers seven stages: end-of-utterance detection, network round-trip, STT, LLM first token, first sentence ready, TTS synthesis, and playback buffer. Each stage's slider hint carries a typical range pulled from public material from 2025 through 2026, and when a bottleneck exceeds that range, the tool surfaces a recommendation. You can start from a preset, overlay two configurations in comparison mode, and see a rough p95 under load as well.

The seven stages form a chain, and the sum of these delays has to fit inside the target budget for the conversation to feel natural. In the flow below, the stage that actually ate up the most budget was non-streaming TTS.

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
<div class="d3-arch" data-arch-root id="tlatencybudgetgpuserving-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 212, "height": 1098, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 31, "y": 24, "w": 142, "h": 62, "title": ["End of utterance", "detection"]}, {"id": "B", "x": 42, "y": 164, "w": 120, "h": 62, "title": ["Network", "round-trip"]}, {"id": "C", "x": 31, "y": 304, "w": 142, "h": 62, "title": ["STT", "Qwen3-ASR ~133ms"]}, {"id": "D", "x": 42, "y": 444, "w": 120, "h": 62, "title": ["LLM", "first token"]}, {"id": "E", "x": 38, "y": 584, "w": 128, "h": 62, "title": ["First sentence", "ready"]}, {"id": "F", "x": 38, "y": 724, "w": 128, "h": 62, "title": ["TTS synthesis", "the bottleneck"]}, {"id": "G", "x": 42, "y": 864, "w": 120, "h": 62, "title": ["Playback", "buffer"]}, {"id": "H", "x": 24, "y": 1004, "w": 156, "h": 62, "title": ["First audio out", "target under 800ms"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [102, 86, 102, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [102, 226, 102, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [102, 366, 102, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [102, 506, 102, 584]}, {"src": "E", "dst": "F", "kind": "data", "line": [102, 646, 102, 724]}, {"src": "F", "dst": "G", "kind": "data", "line": [102, 786, 102, 864]}, {"src": "G", "dst": "H", "kind": "data", "line": [102, 926, 102, 1004]}]});
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
      const container = document.getElementById('tlatencybudgetgpuserving-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'tlatencybudgetgpuserving-1';
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

## How the Numbers Change Once You Self-Host

You can get a rough sense of a managed streaming API's latency range from documentation. But "what number do we actually get when we put the engine we really use on a GPU" is something you cannot know without measuring it directly. So we took the exact stack we had been running locally on a MacBook for development and put it on a RunPod H200 (141GB) to measure it. The engines were Qwen3-ASR-1.7B for STT, VoxCPM2 and Qwen3-TTS-1.7B for TTS, and the latest Qwen3.5-9B for the LLM.

First, a note on how we kept costs down. If you re-download tens of gigabytes of models and CUDA wheels on every GPU pod, the expensive GPU sits idle waiting for the download and you get charged for it. So we downloaded the virtual environment and weights onto a single network volume exactly once (67 gigabytes), then had the GPU pod mount that volume and benchmark without re-downloading. We guaranteed that the pod and volume would be fully deleted afterward using a finally block plus a name-based safety net for teardown. Total cost including debugging was about 17 dollars, and no resources leaked.

## Measurement Results: The Bottleneck Was Neither the LLM Nor STT, But TTS

Here are the numbers we measured on the H200, on a single-request basis.

| Engine | Model | Latency (single) | Real-Time Factor (RTF) |
|---|---|---|---|
| STT | Qwen3-ASR-1.7B | 133 ms / 10s audio | 0.013 |
| TTS | VoxCPM2 (non-streaming) | 673 ms / sentence | 0.149 |
| TTS | Qwen3-TTS-1.7B (non-streaming) | 6778 ms / sentence | 1.205 |

STT was not a stage worth worrying about. Qwen3-ASR transcribes 10 seconds of audio in 133 ms. A real-time factor of 0.013 is effectively instant. The real story was in TTS. On the same H200, VoxCPM2 synthesized the same Korean sentence in 0.67 seconds, while Qwen3-TTS took 6.8 seconds. On the same card, VoxCPM2 is nearly ten times faster. And it matters that both engines are non-streaming. Because the entire sentence has to be synthesized before the first sound comes out, even VoxCPM2's 0.67 seconds is not "100 ms streaming TTFA" but "first sound after 0.67 seconds." VoxCPM2 did drop from multi-second on local MPS down to 0.67 seconds on GPU, but that does not mean it became streaming. To build a real-time turn, you need to switch to a streaming TTS or synthesize in short sentence chunks. Making this exact point visible as a number was the reason we built this tool in the first place.

## An Honest Gap: The LLM Got Stuck on This Host

We were unable to obtain vLLM serving numbers for Qwen3.5-9B this time. The cause was not performance but an infrastructure version mismatch. As of July 2026, the latest vLLM pulls in a torch built for CUDA 13, and the driver on the H200 host we were assigned was CUDA 12.8, so the engine refused to start, saying the driver was too old. Downgrading torch to a 12.8-compatible build then broke vLLM's compiled kernels, and routing through transformers instead threw errors in the multimodal generation path. Each engine wants a different torch, and fixing one breaks the other, a classic dependency conflict. Getting clean vLLM numbers would require a host with a CUDA 13 driver. We entered an estimate into the calculator's LLM slider and marked it explicitly as an estimate. Hitting an outdated driver while trying to serve the latest model on the latest stack is also a realistic pitfall of self-hosting, so we are writing it down plainly rather than hiding it.

## How to Set This Up for Serving

Translating the measurements into a recipe looks like this. STT is fine as-is with Qwen3-ASR. For TTS, choose VoxCPM2, the one that is ten times faster of the two engines, but bring the first sound forward with streaming or sentence chunking. Qwen3-TTS's non-streaming 6.8 seconds cannot be used as-is for a real-time turn. Serve the LLM with vLLM on a host with a CUDA 13 driver. Put all three engines on the same node to eliminate network hops, and use sentence-level streaming that kicks off TTS the instant the first sentence is ready. Our local MacBook stack is for development, not a serving system, and the calculator's local preset is explicitly labeled "not suitable for real-time."

We published this whole process so it can be reproduced. The calculator opens directly in a browser, and the benchmark harness bundles volume creation, download, GPU benchmarking, and full teardown into a single script. We have also archived the raw measurement JSON and a serving guide in the repository. We hope this gives a starting point for anyone who wants to talk about self-hosted voice stack latency with numbers instead of gut feeling.

- Calculator: [voice-latency-budget](https://sylvanus4.github.io/voice-latency-budget/)
- Repository, benchmark harness, and serving guide: [github.com/sylvanus4/voice-latency-budget](https://github.com/sylvanus4/voice-latency-budget)
