---
title: "vLLM vs Ollama - Local LLM Inference: When to Choose Which"
excerpt: "The conventional wisdom that Ollama is easy and vLLM is fast gets re-examined with 2026 RTX 4090 public benchmarks. At a single user the gap is around 13%, but at 50 concurrent users vLLM delivers roughly 6x the throughput. This post breaks down the scaling curves that PagedAttention and continuous batching produce, along with implications for ThakiCloud Kubernetes-based serving."
seo_title: "vLLM vs Ollama Local LLM Inference Benchmark Comparison (2026) - Thaki Cloud"
seo_description: "Comparing vLLM and Ollama on throughput, latency, and VRAM usage with RTX 4090 public benchmarks. PagedAttention, continuous batching, concurrency scaling curves, and Kubernetes multi-tenant serving considerations."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - vllm
  - ollama
  - llm-serving
  - kubernetes
  - inference
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/dev/vllm-vs-ollama-local-inference/"
reading_time: true
categories:
  - dev
---

Search for how to run an LLM locally and two names come up almost every time: Ollama and vLLM. Strong claims like "don't use Ollama if you care about performance, use vLLM instead" appear frequently. Are they right? The short answer is: half right. A laptop used by one person sending one request at a time is a completely different problem from a server handling dozens of concurrent users. This post uses RTX 4090 benchmark numbers published in 2026 to examine where the two tools diverge, and what that divergence means for ThakiCloud's Kubernetes-based serving stack.

## Overview

Both Ollama and vLLM are inference engines for running LLMs locally or on private infrastructure, but their design goals differ. Ollama is built for a single person to pull a model quickly and run it with minimal friction. Installation is simple, model management is built in, and the lightweight Go server starts fast. vLLM is a production serving engine designed from the ground up to saturate a single GPU with multiple concurrent requests, maximizing throughput. Its core weapons are PagedAttention and continuous batching.

Why does this distinction matter again now? Both tools underwent significant architectural changes after 2024. Ollama refined its llama.cpp kernel optimizations and quantization inference paths to lift single-stream performance; vLLM simplified its installation experience while continuing to improve PagedAttention and speculative decoding. Benchmarks from a year ago no longer reflect the current reality, which is why a fresh look with up-to-date numbers is warranted.

ThakiCloud processes inference requests from multiple customers on a shared GPU pool in a multi-tenant environment. In that context, "is it fast for one person" is almost irrelevant; what matters is "does it hold up when many users hit it simultaneously." That is the lens through which we examine the two engines' scaling curves.

## What Each Tool Is

The decisive difference between the two engines lies in how they manage the KV cache. During generation, a transformer accumulates keys and values from previous tokens in a cache. That KV cache is the largest consumer of GPU memory. Ollama and llama.cpp pre-allocate a contiguous memory block per request. The implementation is straightforward, but as concurrent requests grow, fragmentation builds up and the ability to handle parallel work hits a ceiling quickly.

vLLM's PagedAttention treats the KV cache like virtual memory pages in an operating system. Allocating in small, non-contiguous blocks on demand means far more concurrent sequences can fit in the same VRAM. Continuous batching compounds this: when a new request arrives it gets inserted into the active batch immediately rather than waiting for earlier requests to finish. These two mechanisms together explain why vLLM traces a different curve under concurrency.

The diagram below illustrates the difference in how each engine handles concurrent requests.

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
<div class="d3-arch" data-arch-root id="lmvsollamalocalinference-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1125, "height": 584, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 504, "h": 528, "label": "Ollama / llama.cpp - FIFO Queue", "lx": 36, "ly": 42}, {"x": 548, "y": 24, "w": 545, "h": 528, "label": "vLLM - Continuous Batching + PagedAttention", "lx": 560, "ly": 42}], "nodes": [{"id": "Q1", "x": 85, "y": 187, "w": 120, "h": 46, "title": "Request 1"}, {"id": "EXEC1", "x": 129, "y": 319, "w": 170, "h": 46, "title": "Sequential Execution"}, {"id": "Q2", "x": 172, "y": 63, "w": 120, "h": 46, "title": "Request 2"}, {"id": "WAIT", "x": 260, "y": 187, "w": 120, "h": 46, "title": "Queue Wait"}, {"id": "Q3", "x": 347, "y": 63, "w": 120, "h": 46, "title": "Request N"}, {"id": "KVC", "x": 108, "y": 451, "w": 212, "h": 62, "title": ["Contiguous KV Cache (fixed", "block per request)"]}, {"id": "R1", "x": 585, "y": 63, "w": 120, "h": 46, "title": "Request 1"}, {"id": "BATCH", "x": 760, "y": 187, "w": 121, "h": 46, "title": "Unified Batch"}, {"id": "R2", "x": 760, "y": 63, "w": 120, "h": 46, "title": "Request 2"}, {"id": "R3", "x": 935, "y": 63, "w": 120, "h": 46, "title": "Request N"}, {"id": "PAGED", "x": 725, "y": 311, "w": 191, "h": 62, "title": ["PagedAttention KV Pages", "(dynamic allocation)"]}, {"id": "GPU", "x": 728, "y": 451, "w": 184, "h": 62, "title": ["Merged into Single GPU", "Compute"]}], "edges": [{"src": "Q1", "dst": "EXEC1", "kind": "data", "curve": [[145, 233], [145, 272], [145, 272], [191, 319]]}, {"src": "Q2", "dst": "WAIT", "kind": "data", "curve": [[232, 109], [232, 148], [232, 148], [287, 187]]}, {"src": "Q3", "dst": "WAIT", "kind": "data", "curve": [[407, 109], [407, 148], [407, 148], [352, 187]]}, {"src": "WAIT", "dst": "EXEC1", "kind": "data", "curve": [[320, 233], [320, 272], [320, 272], [249, 319]]}, {"src": "EXEC1", "dst": "KVC", "kind": "data", "line": [214, 365, 214, 451]}, {"src": "R1", "dst": "BATCH", "kind": "data", "curve": [[645, 109], [645, 148], [645, 148], [760, 189]]}, {"src": "R2", "dst": "BATCH", "kind": "data", "line": [820, 109, 820, 187]}, {"src": "R3", "dst": "BATCH", "kind": "data", "curve": [[995, 109], [995, 148], [995, 148], [881, 189]]}, {"src": "BATCH", "dst": "PAGED", "kind": "data", "line": [820, 233, 820, 311]}, {"src": "PAGED", "dst": "GPU", "kind": "data", "line": [820, 373, 820, 451]}]});
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
      const container = document.getElementById('lmvsollamalocalinference-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lmvsollamalocalinference-1';
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

In short, Ollama is optimized for cleanly handling one request at a time; vLLM is optimized for bundling many requests into a single GPU operation. That design difference shows up directly in the benchmark numbers.

## Installation and Integration

Launching both tools via Docker is the cleanest approach for reproducibility. Ollama starts like this:

```bash
docker run -d --gpus=all -v ollama:/root/.ollama \
  -p 11434:11434 --name ollama ollama/ollama
docker exec -it ollama ollama run llama3.1:8b
```

vLLM can be launched directly from its OpenAI-compatible server image:

```bash
docker run --gpus all -p 8000:8000 \
  --ipc=host vllm/vllm-openai:latest \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --dtype auto
```

Both servers expose an OpenAI-compatible API, so client code can remain identical across both:

```bash
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"meta-llama/Llama-3.1-8B-Instruct","prompt":"Hello","max_tokens":64}'
```

For reproducibility, pin image digests. Public benchmarks recommend recording the RepoDigest via `docker inspect ollama/ollama:<tag>` and `docker inspect vllm/vllm-openai:<tag>`, and capturing `ollama --version` and `pip show vllm` output alongside results. Even a single version increment can shift the numbers.

One disclosure: this post was authored on Apple Silicon (macOS, MPS), so CUDA-based vLLM benchmarks could not be reproduced directly. The numbers below are cited from a public benchmark run on the same hardware (SitePoint, March 2026, RTX 4090). The source is listed at the end of this post. Numbers that come from someone else's measurement are kept distinct from any claim that they are our own.

## Benchmark Results (Public Benchmark Citation)

The cited benchmark environment: GPU - NVIDIA RTX 4090 (24GB), CPU - AMD Ryzen 9 7950X, 64GB DDR5 RAM, Ubuntu 24.04, CUDA 12.6, Python 3.12. Models compared were Llama 3.1 8B and DeepSeek-R1-Distill-Llama-8B under identical prompts.

First, single-user sequential throughput. Contrary to common wisdom, vLLM does not dominate. For Llama 3.1 8B, Ollama (Q4_K_M) produced roughly 62 tok/s, vLLM (FP16) roughly 71 tok/s, and vLLM AWQ roughly 68 tok/s. The roughly 13% gap comes more from quantization differences than from architectural advantages. With a single user, Ollama's low server overhead and quantization kernel optimizations offset vLLM's structural strengths.

The picture changes entirely under concurrency. The table below shows aggregate token throughput (tok/s) by concurrent user count.

| Configuration | Ollama | vLLM FP16 | vLLM AWQ |
|---|---|---|---|
| Llama 3.1 8B, 1 user | 62 | 71 | 68 |
| Llama 3.1 8B, 10 users | 148 | 485 | 452 |
| Llama 3.1 8B, 50 users | 155 | 920 | 875 |
| DeepSeek-R1 8B, 1 user | 58 | 67 | 63 |
| DeepSeek-R1 8B, 10 users | 135 | 445 | 418 |
| DeepSeek-R1 8B, 50 users | 142 | 840 | 795 |

At 10 concurrent users vLLM is already roughly 3.3x ahead; at 50 users it is roughly 6x. Ollama processes through a FIFO queue - effectively sequential - so aggregate throughput barely grows as concurrency increases. vLLM absorbs concurrent requests through continuous batching and scales close to linearly.

![Aggregate token throughput comparison chart by concurrent user count - Ollama vs vLLM]({{ '/assets/images/vllm-vs-ollama-local-inference-results.webp' | relative_url }})

Latency tells the same story from a different angle. At one user, time to first response (TTFR) is roughly 45ms for Ollama and roughly 82ms for vLLM - Ollama is faster. At 50 concurrent users the positions reverse. Ollama's TTFR climbs to roughly 3,200ms as requests stack in the queue, while vLLM holds around 145ms thanks to continuous batching. The tool that is faster in isolation becomes the slowest under load.

Resource usage makes the trade-off explicit. At idle with Llama 3.1 8B, Ollama uses roughly 5.2GB VRAM; vLLM FP16 uses roughly 16.1GB. At 50 concurrent users Ollama stays near 5.4GB while vLLM FP16 grows to roughly 21.8GB as it dynamically allocates pages for active sequence KV caches. The AWQ variant is more conservative at roughly 12.4GB under the same load. System RAM and CPU usage are also lower for Ollama (roughly 1.8GB vs 4.6GB idle RAM). vLLM's higher throughput is not free - it is paid for with more VRAM and more RAM.

## Developer Experience and Ecosystem

Beyond performance, developer experience shapes operational cost. Ollama installs in one command, and `ollama run` brings up a model with built-in download and quantization variant management. The low barrier to entry once made it feel like a hobbyist tool, but today it appears broadly in CI pipelines for code review prompts, edge deployments on devices like Jetson Orin, and internal developer toolchains.

vLLM previously required familiarity with Python ML tooling, but the installation experience has simplified significantly in recent versions. Pulling and running the OpenAI-compatible server image lets existing OpenAI client code attach with minimal changes. Rich production features - tensor parallelism, speculative decoding, hot-swappable LoRA adapters - are strong ecosystem advantages. Because both tools share the OpenAI-compatible API surface, transitioning from Ollama in development to vLLM in production is relatively smooth.

## ThakiCloud K8s AI/ML SaaS Platform - Application and Implications

This comparison explains precisely why ThakiCloud standardizes on vLLM-family engines for multi-tenant serving. Our platform is not a single user monopolizing a single model. Multiple customers' requests flow concurrently across a shared GPU pool. In that setting, what matters is not single-stream speed but the concurrency scaling curve and latency stability under load. At 50 concurrent users, 6x throughput and 20x lower latency translate directly into the number of tenants a single GPU can serve - that is unit cost.

Operationally, we deploy vLLM serving pods on Kubernetes and queue GPU workloads with Kueue. A serving workload looks roughly like this:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-llama31-8b
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model=meta-llama/Llama-3.1-8B-Instruct"
            - "--max-num-seqs=64"
            - "--gpu-memory-utilization=0.90"
          resources:
            limits:
              nvidia.com/gpu: "1"
          ports:
            - containerPort: 8000
```

`--max-num-seqs` and `--gpu-memory-utilization` are the key tuning handles. PagedAttention's dynamic VRAM growth is a variable that must be factored into pod memory limits and GPU partition policy. As the numbers above show, VRAM moves from 16GB to 22GB as concurrency rises, so static allocation lands you in either OOM or chronic under-utilization. We therefore measure the maximum concurrent sequences and KV cache ceiling per model and size pod resources accordingly. Kueue holds jobs in queue until GPU capacity is available and dispatches when it clears, preventing GPU over-subscription even when many tenants arrive at once.

None of this makes Ollama irrelevant. For local prototyping by internal engineers, single-user demo environments, and lightweight code review prompts in CI pipelines, Ollama's fast startup and low resource floor are genuine advantages. For ThakiCloud the boundary is clear: customer-facing production multi-tenant inference uses vLLM; individual developer workflows and edge demos use Ollama. For on-premises self-hosting customers where data cannot leave the premises (national security requirements and similar), the fact that both engines can run on their own GPU hardware is itself a core part of the value proposition.

## Limitations and Caveats

A few things to keep in mind. First, the cited benchmarks are for a single RTX 4090. Multi-GPU setups, models above 70B, and tensor-parallel configurations may produce different curves. In those scenarios vLLM is effectively the only practical option, but specific numbers need to be measured on the relevant hardware.

Second, Ollama's concurrency weakness reflects the version tested. Ollama is actively improving batching, and future versions may narrow the gap. Treating "Ollama is weak at concurrency" as a permanent fact is incorrect. Tools change fast.

Third, vLLM's high throughput has a real cost: more VRAM, more RAM, more operational complexity, and Python runtime overhead. Deploying vLLM for workloads with almost no concurrent requests is over-engineering. Tool selection should start not from "which one is faster" but from "where does my concurrency profile sit."

Finally, the core numbers in this post are cited from a public benchmark, not measured by us. Reproduction measurements in our actual GPU environment are planned for a separate follow-up post. Please read with the understanding that cited numbers from someone else's setup should not be generalized as our own conclusions.

## Sources

- SitePoint, "Ollama vs vLLM: Performance Benchmark 2026" (2026-03-05): [https://www.sitepoint.com/ollama-vs-vllm-performance-benchmark-2026/](https://www.sitepoint.com/ollama-vs-vllm-performance-benchmark-2026/)
- vLLM Official Documentation: [https://docs.vllm.ai](https://docs.vllm.ai)
- Ollama: [https://ollama.com](https://ollama.com)
