---
title: "How vLLM Works, and How It's Used in Production"
excerpt: "When you put an LLM into real service, most of the cost is decided not by the model itself but by the inference engine. Here's how vLLM cuts GPU waste with PagedAttention and continuous batching, and how ThakiCloud runs it in production from a serving perspective."
date: 2026-07-18
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/dev/vllm-production-inference-engineering/
tags:
  - vLLM
  - 추론엔진
  - PagedAttention
  - 연속배칭
  - LLM서빙
  - LLMOps
  - 쿠버네티스
  - 온프레미스
author_profile: true
toc: true
toc_label: Anatomy of an Inference Engine
published: true
categories:
  - dev
  - llmops
---

## Overview

Any team that has taken a large language model into production eventually learns one thing. What determines a service's latency and cost is not which model you chose, but what you serve it with. On the same GPU, with the same model, throughput per second can differ by several times depending on the inference engine. And a several fold difference in throughput means a several fold difference in the number of GPUs needed to handle the same traffic, which directly changes the order of magnitude on your infrastructure bill.

This post covers vLLM, which has become the de facto standard for production LLM serving today. We will walk through what problem vLLM was built to solve, what its core techniques, PagedAttention and continuous batching, actually do, and what you need to watch for when running it reliably on Kubernetes. ThakiCloud operates this engine across both on premise and managed environments for our customers, so we will go beyond a conceptual explanation and write this from an operator's point of view.

## What Is vLLM

vLLM is an open source inference engine released by researchers at UC Berkeley in 2023. Its goal is simple and clear: make LLM inference faster and cheaper. Since its release it has spread quickly and is now the default choice underlying production inference at organizations including Meta, Mistral, Cohere, and IBM.

What vLLM targets is two kinds of waste hidden inside traditional inference. One is memory fragmentation, the other is GPU idle time. Neither is obvious on the surface, but together they leave a large portion of expensive GPUs sitting idle. vLLM's two core techniques, PagedAttention and continuous batching, each target one of these two forms of waste head on.

Here is the overall structure laid out first.

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
<div class="d3-arch" data-arch-root id="tioninferenceengineering-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 523, "height": 966, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 179, "y": 24, "w": 156, "h": 46, "title": "Many user requests"}, {"id": "B", "x": 197, "y": 148, "w": 120, "h": 46, "title": "Scheduler"}, {"id": "C", "x": 166, "y": 272, "w": 181, "h": 68, "title": ["Continuous batching", "rebuilt every step"]}, {"id": "D", "x": 226, "y": 418, "w": 198, "h": 62, "title": ["PagedAttention", "KV cache page management"]}, {"id": "E", "x": 370, "y": 580, "w": 121, "h": 62, "title": ["GPU execution", "forward pass"]}, {"id": "F", "x": 170, "y": 728, "w": 174, "h": 68, "title": ["Completed requests", "return immediately"]}, {"id": "G", "x": 179, "y": 888, "w": 156, "h": 46, "title": "Response streaming"}, {"id": "H", "x": 124, "y": 572, "w": 191, "h": 78, "title": ["Non-contiguous physical", "blocks", "GPU memory"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [257, 70, 257, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [257, 194, 257, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[289, 340], [325, 379], [325, 379], [325, 418]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[368, 480], [431, 526], [431, 526], [431, 580]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[431, 642], [431, 689], [431, 689], [338, 728]]}, {"src": "F", "dst": "C", "kind": "data", "label": "Incomplete sequence", "curve": [[177, 728], [85, 611], [85, 449], [177, 340]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "label": "Complete", "line": [257, 796, 257, 888], "lx": 257, "ly": 838}, {"src": "D", "dst": "H", "kind": "event", "label": "Block table", "curve": [[283, 480], [220, 526], [220, 526], [220, 572]], "off": "50%"}]});
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
      const container = document.getElementById('tioninferenceengineering-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'tioninferenceengineering-1';
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

## PagedAttention: Eliminating Memory Waste

As an LLM generates tokens one at a time, it stores the keys and values it has already computed. This is called the KV cache, and the longer the sequence, the more GPU memory it consumes. The problem is that the traditional approach reserves memory up front for each request, sized for the expected maximum length, and does so as one large contiguous block. If the actual response ends up shorter, much of that reserved memory simply goes to waste. When many requests arrive at once, this waste accumulates, to the point where a GPU with free memory available still cannot accept a new request.

PagedAttention borrows its idea directly from how operating systems manage RAM, namely virtual memory and paging. Instead of reserving the KV cache as one large block, it splits it into small, reusable pages. Each sequence's logical blocks are mapped, through a block table, to non-contiguous physical blocks inside GPU memory. This means only as many pages as actually needed get allocated, which sharply cuts memory waste. According to vLLM's own materials, this approach can reduce memory waste by up to 90 percent.

There is a significant side benefit too. In complex decoding scenarios that branch out from a single prompt, such as parallel sampling or beam search, vLLM does not need to duplicate the prompt's KV cache. Multiple logical blocks can point to the same physical block, and a copy is only made when one of them needs to modify that block, a copy-on-write scheme. This lets requests that share the same prefix context coexist while saving memory.

## Continuous Batching: Keeping the GPU Busy

The second kind of waste is wasted time. Traditional static batching groups requests into a batch and processes them together, and will not start the next batch until every request in the current one is done. The problem is that requests generate wildly different numbers of tokens. A request producing a short answer finishes early, but still has to wait until the longest request in the batch is done. In the meantime, the GPU slot that the finished request used to occupy sits idle.

Continuous batching removes this wait. The scheduler makes decisions at the granularity of an iteration rather than a batch, that is, at every forward pass. As soon as a request finishes in a given step, its slot is immediately filled with a new request from the queue. Because in-flight requests and new requests are dynamically mixed at every step, the GPU is almost never idle. This approach is reported to raise throughput on the same hardware by 3x to 10x.

Applying PagedAttention and continuous batching together is commonly observed to improve throughput by roughly 2x to 4x over a naively implemented serving stack. The two techniques complement each other. For continuous batching to slot in a new request at every step, it needs memory it can attach and detach just as flexibly, and that flexibility is exactly what PagedAttention provides.

> The figures above come from the vLLM project and various benchmark reports, and actual gains vary depending on model size, sequence length distribution, and hardware. You should measure the exact numbers for your own environment against your own workload.

## How It's Used in Production

Once you understand the concepts, actually running it in production is surprisingly mundane. vLLM ships with an OpenAI-compatible server by default, so code that used to call an external API often works unchanged once you just swap the endpoint address.

The simplest way to start the server looks like this.

```bash
# Install vLLM (CUDA environment)
pip install vllm

# Start the OpenAI-compatible server
vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --tensor-parallel-size 1 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.90
```

Calls to it use the existing OpenAI client as-is.

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8000/v1", api_key="EMPTY")
resp = client.chat.completions.create(
    model="meta-llama/Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "Explain vLLM in one sentence"}],
)
print(resp.choices[0].message.content)
```

The part that actually requires attention in production is not the server startup command itself, but the operational parameters around it. In particular, you need to pay attention to the following.

- `--gpu-memory-utilization`: the fraction of GPU memory to use for the KV cache. Set it too high and you risk sudden out-of-memory errors. Set it too low and you reduce how many requests you can serve concurrently.
- `--tensor-parallel-size`: the tensor parallel size used to split the model across multiple GPUs. This is required when serving a large model that does not fit on a single GPU.
- `--max-model-len`: the maximum context length. The longer you set it, the larger the KV cache per request grows, which trades off against concurrent throughput.

Running on Kubernetes adds scheduling and resource management on top of this. GPUs are expensive and finite, so as soon as multiple teams and multiple models share a cluster, resource contention shows up immediately. This is where queue-based batch scheduling comes in. ThakiCloud places Kueue at this layer to manage, as policy, which workload gets to occupy how much GPU and when.

## Implications for ThakiCloud's Products

ThakiCloud's ai-platform is a Kubernetes-based AI/ML SaaS infrastructure, and serving models across our customers' diverse environments is a core capability. vLLM is the default engine at this serving layer. The throughput gains that PagedAttention and continuous batching create translate directly into lower serving costs, and that is what lets us offer our customers competitively low serving costs.

The value of this combination is especially large in on-premise and sovereign environments. Customers who cannot send data outside their own infrastructure have to run models within their own GPU infrastructure, and in that setting, squeezing the maximum possible throughput out of each GPU is what determines whether adoption is even feasible in the first place. If an inference engine uses a GPU twice as efficiently, it means you can run the same service on half the hardware.

From an operational standpoint, the value ThakiCloud adds is not the engine itself but the scaffolding around it: GPU queue management through Kueue, multi-tenant isolation, autoscaling and observability, and a policy layer that lets multiple models safely coexist on a single cluster. If vLLM is responsible for the efficiency of a single server, the platform is responsible for making dozens of those servers something an entire organization can share reliably.

## Limitations and Counterarguments

vLLM is not a silver bullet. It comes with a few honest limitations.

First, vLLM's strength shows when throughput matters, that is, when it is handling many concurrent requests. Conversely, in a low-load situation where requests come in one at a time, sparsely, the benefit of continuous batching is not as large, and a different approach specialized for latency optimization may work better. You need to first understand whether your own traffic pattern looks like high-volume concurrent requests or sparse, one-off requests.

Second, the numbers PagedAttention and continuous batching deliver depend heavily on the workload. For very long or very short sequence lengths, or on certain hardware, the reported gains may not reproduce as-is. Adoption decisions must be based on actual load testing that represents your own workload, and you should not assume that a multiplier someone else reported will automatically be yours.

Third, as the engine gets more efficient, the bottleneck actually shifts upward, toward scheduling and multi-tenant operations. No matter how much you optimize a single server, the problem of multiple teams competing for GPUs has to be solved at the platform layer, not the engine layer. vLLM is an excellent starting point, but it is not the finish line, and production's real hard problems start right after it.

## Sources

- [vLLM Explained: PagedAttention and Continuous Batching (RunPod)](https://www.runpod.io/articles/guides/vllm-pagedattention-continuous-batching)
- [LLM Serving Optimization: Continuous Batching, PagedAttention, and Chunked Prefill (Spheron)](https://www.spheron.network/blog/llm-serving-optimization-continuous-batching-paged-attention/)
- [vLLM Production Deployment (Introl)](https://introl.com/blog/vllm-production-deployment-inference-serving-architecture-guide)
- [vLLM: Deploying LLMs at Scale (LearnOpenCV)](https://learnopencv.com/vllm-deploy-llms-at-scale-paged-attention/)
