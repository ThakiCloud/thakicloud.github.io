---
title: "Qwen3.6-27B in NVFP4: The Economics of Single-GPU Blackwell Serving"
excerpt: "NVIDIA re-quantized Qwen3.6-27B to NVFP4 so it serves on a single Blackwell GPU with vLLM out of the box. We break down how the mixed precision (MLP in NVFP4, attention and KV cache in FP8) fits a 27B model in about 22GB, and what that means for the multi-tenant GPU serving economics of ThakiCloud ai-platform."
seo_title: "Qwen3.6-27B-NVFP4 on vLLM: Single-GPU Blackwell Serving Analysis | Thaki Cloud"
seo_description: "How NVIDIA ModelOpt's Qwen3.6-27B-NVFP4 re-quantization (MLP in NVFP4 W4A16, attention and KV cache in FP8) serves on vLLM, and what single-GPU Blackwell serving implies for GPU cost efficiency on ThakiCloud ai-platform."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - vllm
  - nvfp4
  - quantization
  - blackwell
  - model-serving
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "microchip"
published: true
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/qwen3-6-27b-nvfp4-vllm-blackwell/"
categories:
  - llmops
---

## Overview

If you can serve a 27B-class model on a single GPU with near-lossless accuracy, the economics of on-premises inference change. The nvidia/Qwen3.6-27B-NVFP4 checkpoint re-quantizes Qwen3.6-27B into the NVFP4 data type so it runs on a recent vLLM with no extra configuration. That is the backdrop to the vLLM project announcing this checkpoint is inference-ready on Blackwell GPUs.

The point is not simply "reduced to 4-bit" but **what was reduced and what was kept**. This post dissects the mixed-precision design of the NVFP4 re-quantization, lays out how to actually serve it with vLLM, and then works through what this means for the multi-tenant GPU serving cost structure of ThakiCloud ai-platform. Where measurement is required, we mark it honestly.

## What This Is

NVFP4 is a 4-bit floating-point format that drops bits-per-parameter from 16 to 4, cutting disk and GPU memory requirements by roughly 2.5x. But the actual design of nvidia/Qwen3.6-27B-NVFP4 does not flatten everything to 4-bit. NVIDIA ModelOpt's re-quantization **lowers only the MLP linear layers to NVFP4 (W4A16), while keeping the attention linear layers and the KV cache in FP8.** As a result, about 22GB of weights fit on a single Blackwell GPU. NVIDIA reports this configuration is near-lossless in accuracy versus the FP8 baseline.

There is a reason for this mixed-precision choice. The MLP layers hold an overwhelming share of the parameters, so their memory savings are large and they tolerate 4-bit relatively well. Attention and the KV cache, by contrast, are sensitive to quality over long contexts, so they stay in FP8 to preserve accuracy. The principle: "cut the heaviest part most aggressively, and keep the most sensitive part conservatively."

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
<div class="d3-arch" data-arch-root id="n3627bnvfp4vllmblackwell-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 626, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 192, "y": 24, "w": 205, "h": 62, "title": ["Qwen3.6-27B original FP16", "weights"]}, {"id": "B", "x": 227, "y": 164, "w": 135, "h": 62, "title": ["NVIDIA ModelOpt", "re-quantization"]}, {"id": "C", "x": 445, "y": 304, "w": 149, "h": 62, "title": ["MLP linear layers", "NVFP4 W4A16"]}, {"id": "D", "x": 199, "y": 304, "w": 191, "h": 62, "title": ["Attention linear layers", "kept in FP8"]}, {"id": "E", "x": 24, "y": 304, "w": 120, "h": 62, "title": ["KV cache", "kept in FP8"]}, {"id": "F", "x": 217, "y": 444, "w": 156, "h": 46, "title": "About 22GB weights"}, {"id": "G", "x": 220, "y": 568, "w": 149, "h": 62, "title": ["Loads on a single", "Blackwell GPU"]}, {"id": "H", "x": 206, "y": 708, "w": 177, "h": 62, "title": ["vLLM auto-detects", "quantization modelopt"]}, {"id": "I", "x": 217, "y": 848, "w": 156, "h": 62, "title": ["OpenAI-compatible", "inference endpoint"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [295, 86, 295, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[362, 216], [520, 265], [520, 265], [520, 304]]}, {"src": "B", "dst": "D", "kind": "data", "line": [295, 226, 295, 304]}, {"src": "B", "dst": "E", "kind": "data", "curve": [[227, 217], [84, 265], [84, 265], [84, 304]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[520, 366], [520, 405], [520, 405], [373, 446]]}, {"src": "D", "dst": "F", "kind": "data", "line": [295, 366, 295, 444]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 366], [84, 405], [84, 405], [217, 444]]}, {"src": "F", "dst": "G", "kind": "data", "line": [295, 490, 295, 568]}, {"src": "G", "dst": "H", "kind": "data", "line": [295, 630, 295, 708]}, {"src": "H", "dst": "I", "kind": "data", "line": [295, 770, 295, 848]}]});
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
      const container = document.getElementById('n3627bnvfp4vllmblackwell-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'n3627bnvfp4vllmblackwell-1';
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

Compared to a uniform 4-bit quantization (for example, W4 across all layers), this approach captures most of the memory savings while defending quality by keeping sensitive layers in FP8. Setting the savings-vs-accuracy trade-off per layer is the key differentiator of NVFP4 re-quantization.

## Installation and Serving

vLLM auto-detects the ModelOpt quantization from the checkpoint, so you do not strictly need to pass a quantization flag. You do need a recent vLLM with NVFP4/W4A16 support, and NVIDIA recommends nightly or a source build that includes ModelOpt support. Bring up the nightly image with Docker and serve as follows.

```bash
# Recent vLLM with NVFP4/ModelOpt support (nightly image)
docker run --gpus all -p 8000:8000 \
  vllm/vllm-openai:nightly \
  vllm serve nvidia/Qwen3.6-27B-NVFP4 \
    --port 8000 \
    --quantization modelopt \
    --max-model-len 262144 \
    --reasoning-parser qwen3
```

`--max-model-len 262144` uses the long context of the Qwen3.6 family as-is, and `--reasoning-parser qwen3` handles reasoning-token parsing. The endpoint is OpenAI-compatible, so existing clients attach without change.

## Experiment Results

To be candid: this checkpoint assumes a Blackwell-class GPU, and the environment where this post was written has no such hardware, so we **could not reproduce it locally.** The numbers below are therefore not our measurements but figures reported by public sources, cited as-is with attribution.

- NVIDIA reports the NVFP4 re-quantized configuration is **near-lossless** in accuracy versus the FP8 baseline (per the model card).
- The weight size is about **22GB**, fitting on a single Blackwell GPU (per the model card).
- One third-party benchmark (loFT LLC) reports **around 190 tok/s of generation throughput** with an NVFP4+MTP configuration on dual RTX PRO 6000 Blackwell Max-Q. This is an [estimate]-grade external measurement, not our environment's value.

What we could verify are the facts of the serving path. That vLLM auto-detects ModelOpt quantization, that the configuration is mixed-precision (MLP in NVFP4, attention and KV in FP8), and that ~22GB of weights fit on a single Blackwell are all confirmed in the public model card and the vLLM recipe. Actual throughput and latency remain something to measure once the hardware is in hand.

## Implications for ThakiCloud Products

What makes this checkpoint interesting is less the benchmark numbers themselves and more the **shift in serving economics**. ThakiCloud ai-platform serves models across diverse customer environments on K8s and Kueue, and the GPU is always the most expensive resource. If a 27B-class model can fit on a single GPU, near-losslessly at that, you lower per-tenant GPU occupancy and can host more models, or more tenants, on the same hardware.

From a multi-tenant view, this saving compounds. When a model drops from 2 GPUs to 1, the cluster's concurrent serving slots nearly double. Under Kueue-based GPU allocation, that translates directly into shorter wait queues and easier fair sharing across tenants. It matters especially for customers with strong on-premises and sovereign requirements, because the sheer number of GPUs to procure falls, lowering the barrier of upfront investment and operating cost.

The mixed-precision design also aligns with our operating philosophy. Rather than lowering precision indiscriminately, the approach of keeping the quality-sensitive parts and aggressively cutting only the heavy parts fits the goal of "cost efficiency and quality at once." It is why, when adopting a new quantized checkpoint on ai-platform, we review not just the benchmark score but which layers were treated at which precision. NVFP4 re-quantization is a good reference case for that review, and once we secure measured throughput we plan a follow-up post on its cost-quality profile in our serving stack.

## Limitations and Counterpoints

First, the hardware dependency is stark. NVFP4's benefit is maximized on Blackwell-generation GPUs, and earlier generations should not expect the same efficiency. The appeal of single-GPU serving holds only on the premise that Blackwell was secured. In an environment where GPU procurement itself is the bottleneck, "a single GPU is enough" does not immediately convert into cost savings.

Second, near-lossless is a story about benchmark averages. In specific domains, long contexts, or precision-sensitive tasks like numerics and code, a subtle quality drop versus the FP8 baseline may surface. An NVFP4 adoption decision should be confirmed by evaluation on the actual workload you will serve, not by the model card's summary figures.

Third, the throughput number in this post is not our measurement. Third-party benchmarks depend heavily on hardware configuration (dual RTX PRO 6000, whether MTP is used) and on batch and context length, so our cluster's actual value is undetermined until we measure it directly. This post's conclusion reaches only "NVFP4 single-GPU serving has the potential to shift serving economics"; "how many tok/s in our environment" is a matter to state after separate verification.

## Sources

- nvidia/Qwen3.6-27B-NVFP4 model card, Hugging Face (<https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4>)
- Qwen/Qwen3.6-27B, vLLM Recipes (<https://recipes.vllm.ai/Qwen/Qwen3.6-27B>)
- Measuring Qwen3.6-27B NVFP4+MTP on vLLM, loFT LLC (<https://loftllc.dev/en/docs/tech/llm-research/qwen3-6-27b-nvfp4-mtp-vllm-benchmark/>)
