---
title: "DFlash Speculative Decoding: Up to 15x Faster vLLM Inference with Block Diffusion Drafting"
excerpt: "DFlash replaces the autoregressive token-by-token drafter used in EAGLE-3 with a block diffusion drafter that proposes a block of future tokens in a single forward pass. It drops into vLLM, SGLang, and TensorRT-LLM without application code changes. Based on published figures, it delivers 6x lossless speedup on a single stream and up to 15x throughput on Blackwell. We break down what this means for K8s-based multi-tenant model serving."
seo_title: "DFlash Speculative Decoding vLLM Integration Analysis - Block Diffusion Drafting - Thaki Cloud"
seo_description: "How DFlash block diffusion speculative decoding plugs into vLLM/SGLang/TensorRT-LLM to boost inference throughput beyond EAGLE-3, with analysis of published benchmarks (Qwen3-8B lossless 6.08x, Blackwell 15x) from a ThakiCloud K8s serving platform perspective."
date: 2026-06-24
last_modified_at: 2026-06-24
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/dflash-speculative-decoding-vllm/"
tags:
  - speculative-decoding
  - dflash
  - vllm
  - inference-optimization
  - block-diffusion
  - eagle
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "bolt"
toc_sticky: true
reading_time: true
categories:
  - llmops
published: false
---

![Abstract visual of parallel token blocks propagating forward in a single pass]({{ '/assets/images/dflash-speculative-decoding-vllm-hero.webp' | relative_url }})

An illustration of the DFlash concept: the drafting step shifts from sequential token generation to parallel block proposal.

## Overview

In large-scale language model serving, decoding throughput is what determines both infrastructure cost and the latency a user actually feels. As long as a model generates tokens one at a time in an autoregressive loop, there is a structural ceiling: no matter how fast the GPU is, the full model must be traversed once per token. Speculative decoding is the most practical known technique for bypassing this bottleneck, yet earlier drafters were also autoregressive, which kept acceleration ratios in the 2-3x range.

On June 23, 2026, the NVIDIA Technical Blog introduced DFlash, developed by researchers at UC San Diego. DFlash applies a block diffusion model to the drafting stage of speculative decoding, proposing future tokens as a block in one forward pass rather than one at a time. Based on published figures, it achieves up to 6x lossless single-stream speedup and up to 15x serving throughput on NVIDIA Blackwell at the same latency target.

The most operationally significant property is **drop-in integration**. DFlash is supported by vLLM, SGLang, and TensorRT-LLM. On vLLM, switching from EAGLE-3 to DFlash requires only a config change - no application code modifications. This post explains how DFlash works, what the published benchmarks say, and what it means for ThakiCloud's K8s-based multi-tenant AI/ML serving platform. All numbers cited here are official figures published by NVIDIA and UCSD. We have not reproduced these results on ThakiCloud hardware, and we address that honestly in a dedicated section.

## What the Technology Does

Speculative decoding has two stages. A small draft model proposes future tokens, and a large target model verifies them in parallel, accepting the longest valid prefix. When the draft is correct, a single verification pass through the target model confirms multiple tokens. The problem is that conventional drafters are autoregressive: drafting cost grows linearly with the number of speculative tokens, which caps the throughput gains.

DFlash replaces the autoregressive drafter with a lightweight block diffusion drafter. A block diffusion model denoises a masked block of tokens all at once, combining parallel generation with an autoregressive block structure. DFlash applies this idea only to the drafting stage; verification is still handled by the trusted autoregressive target model. That separation is what preserves output quality. Standalone diffusion LLMs often trail autoregressive models in accuracy and require multiple denoising steps, but in DFlash the draft only needs to be good enough to pass verification - the final output distribution is guaranteed by the target model's parallel check. The method is therefore lossless.

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
<div class="d3-arch" data-arch-root id="hspeculativedecodingvllm-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 959, "height": 568, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 903, "h": 121, "label": "EAGLE-3 (Autoregressive Drafting)", "lx": 36, "ly": 42}, {"x": 24, "y": 399, "w": 453, "h": 137, "label": "DFlash (Block Diffusion Drafting)", "lx": 36, "ly": 417}], "nodes": [{"id": "E1", "x": 63, "y": 62, "w": 120, "h": 46, "title": "Token t1"}, {"id": "E2", "x": 290, "y": 62, "w": 120, "h": 46, "title": "Token t2"}, {"id": "E3", "x": 563, "y": 62, "w": 120, "h": 46, "title": "Token t3"}, {"id": "E4", "x": 768, "y": 62, "w": 120, "h": 46, "title": "Token t4"}, {"id": "D0", "x": 63, "y": 445, "w": 120, "h": 46, "title": "Masked block"}, {"id": "D1", "x": 265, "y": 437, "w": 170, "h": 62, "title": ["t1 · t2 · t3 · t4 (1", "forward pass)"]}, {"id": "V1", "x": 261, "y": 183, "w": 177, "h": 62, "title": ["Target model parallel", "verification"]}, {"id": "EAGLE", "x": 63, "y": 191, "w": 120, "h": 46, "title": "EAGLE"}, {"id": "V2", "x": 261, "y": 300, "w": 177, "h": 62, "title": ["Target model parallel", "verification"]}, {"id": "DFLASH", "x": 63, "y": 308, "w": 120, "h": 46, "title": "DFLASH"}, {"id": "OUT", "x": 555, "y": 249, "w": 135, "h": 46, "title": "Lossless output"}], "edges": [{"src": "E1", "dst": "E2", "kind": "data", "line": [183, 85, 290, 85]}, {"src": "E2", "dst": "E3", "kind": "data", "line": [410, 85, 563, 85]}, {"src": "E3", "dst": "E4", "kind": "data", "line": [683, 85, 768, 85]}, {"src": "D0", "dst": "D1", "kind": "data", "line": [183, 468, 265, 468]}, {"src": "EAGLE", "dst": "V1", "kind": "data", "line": [183, 214, 261, 214]}, {"src": "DFLASH", "dst": "V2", "kind": "data", "line": [183, 331, 261, 331]}, {"src": "V1", "dst": "OUT", "kind": "data", "curve": [[438, 214], [477, 214], [516, 214], [581, 249]]}, {"src": "V2", "dst": "OUT", "kind": "data", "curve": [[438, 331], [477, 331], [516, 331], [581, 295]]}]});
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
      const container = document.getElementById('hspeculativedecodingvllm-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'hspeculativedecodingvllm-1';
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

The second advantage is drafting cost structure. An autoregressive drafter's cost scales with the number of speculative tokens, while a diffusion drafter generates all tokens in one parallel pass, so drafting latency stays nearly flat as the block size grows. This allows DFlash to use a deeper, more expressive draft model without increasing latency. In practice, DFlash uses a small 5-layer drafter (8 layers for Qwen3-Coder). That contrasts with earlier diffusion-drafter research (DiffuSpec, SpecDiff-2), which used large 7B-parameter drafters and capped speedup at 3-4x.

DFlash combines three techniques. First, **block diffusion drafting** predicts multiple future tokens in parallel. Second, **target hidden-state conditioning** transfers context features from the target model to the drafter via KV injection. Third, verification-friendly training improves the acceptance rate of draft blocks. Together these create the balance of small drafter, parallel block proposal, and lossless verification.

## Installation and Integration

DFlash ships checkpoints and framework support together, so adoption requires very little new code. Public checkpoints are available in the `z-lab/dflash` collection on Hugging Face; 20 checkpoints were available at announcement time. On vLLM, you swap the EAGLE-3 speculative config for the DFlash config with no application refactoring. Below is the vLLM example from the official documentation.

```bash
vllm serve Qwen/Qwen3.5-27B \
  --speculative-config '{"method": "dflash", "model": "z-lab/Qwen3.5-27B-DFlash", "num_speculative_tokens": 15}' \
  --attention-backend flash_attn \
  --max-num-batched-tokens 32768
```

Setting `method` to `dflash` in `--speculative-config` and passing the draft checkpoint path is all that changes. Because the flag structure mirrors the existing EAGLE-3 serving setup, you are effectively hot-swapping the speculative decoding method in a running vLLM deployment. SGLang and TensorRT-LLM work the same way, accepting DFlash draft checkpoints through the same speculative decoding API.

The Transformers backend supports Qwen3 and LLaMA-3.1 model families and provides a `spec_generate` interface that pairs the draft and target models.

```python
from transformers import AutoModel, AutoModelForCausalLM, AutoTokenizer

draft = AutoModel.from_pretrained(
    "z-lab/Qwen3-8B-DFlash-b16", trust_remote_code=True,
    dtype="auto", device_map="cuda:0").eval()
target = AutoModelForCausalLM.from_pretrained(
    "Qwen/Qwen3-8B", dtype="auto", device_map="cuda:0").eval()
tokenizer = AutoTokenizer.from_pretrained("Qwen/Qwen3-8B")

messages = [{"role": "user", "content": "How many positive divisors does 196 have?"}]
input_ids = tokenizer.apply_chat_template(
    messages, return_tensors="pt", add_generation_prompt=True,
    enable_thinking=False).to(draft.device)

output = draft.spec_generate(
    input_ids=input_ids, max_new_tokens=2048, temperature=0.0, target=target)
```

All code blocks above are cited from official examples published by the NVIDIA Technical Blog and MarkTechPost; they are not output captured from ThakiCloud infrastructure. DFlash throughput numbers were measured on NVIDIA Blackwell (DGX B300, 8 GPUs) with TensorRT-LLM. Our environment does not have those accelerators or checkpoints available, so we have not reproduced the results under identical conditions. All figures below therefore come from clearly attributed public sources; no self-measured numbers are included.

## Benchmark Results (Published Figures)

DFlash's speedup numbers fall into two categories, measured differently, and should be read accordingly.

**Lossless single-stream speedup.** The UCSD paper reports an average of 4.86x and a peak of 6.08x on MATH-500 for Qwen3-8B greedy decoding on the Transformers backend. Under the same conditions, EAGLE-3 achieves an average of 1.76x at tree size 16 and 2.02x at tree size 60. Task-level figures are shown in the chart below.

![Bar chart comparing DFlash vs EAGLE-3 lossless speedup on Qwen3-8B across tasks]({{ '/assets/images/dflash-speculative-decoding-vllm-results.webp' | relative_url }})

The chart visualizes official numbers from the UCSD DFlash paper and does not represent direct ThakiCloud measurements. GSM8K 5.15x, MATH-500 6.08x, AIME25 5.62x, HumanEval 5.14x, and LiveCodeBench 5.51x show particularly large gains on math and code reasoning tasks. MT-Bench, which allows more varied responses, is comparatively lower at 2.75x. This is consistent with the general principle that speculative decoding gains more as output becomes more predictable (higher acceptance rate).

**Throughput at a fixed latency target.** The 15x figure NVIDIA reports refers to serving gpt-oss-120b on a DGX B300 (8 Blackwell GPUs) with TensorRT-LLM, achieving over 15x the throughput of autoregressive decoding at the 500-600 tokens/second per user operating point. At the same point, DFlash is approximately 1.5x faster than EAGLE-3. In a separate NVIDIA Speed-Bench (latency speedup at the same concurrency), gpt-oss-120b shows DFlash at 2.3x vs. EAGLE-3 at 1.7x, and Llama 3.1 8B Instruct shows DFlash at 2.8x vs. EAGLE-3 at 2.2x. Across tasks the reported range extends to Gemma 4 31B at up to 5.8x (vLLM) and Qwen3 8B at 5.1x (SGLang).

In summary, "6x" is lossless single-request speedup; "15x" is serving throughput when many users are held to the same latency target. The two numbers answer different questions. To estimate what to expect in your own deployment, fix your concurrency and latency target first, then look at the figure for that operating point.

## Implications for the ThakiCloud K8s AI/ML Platform

ThakiCloud runs a stack where Kueue schedules GPUs on Kubernetes and vLLM serves models across multiple tenants. DFlash is particularly well-suited to this setup for three reasons.

First, **it is a drop-in replacement with low operational risk**. If you are already running speculative decoding with EAGLE-3, you can switch `method` and the draft checkpoint to DFlash and validate it as a canary deployment. Because it is a lossless technique - the API contract and output distribution are unchanged - tenants see the same response content; only throughput and latency improve. An optimization that does not break output consistency is rare and valuable in multi-tenant SaaS.

Second, **GPU efficiency directly translates to unit economics**. Handling more concurrent requests at the same latency target with the same GPU means lower serving cost per tenant. This matters most in environments where adding capacity is constrained, such as on-premises deployments or domestic-region GPU allocations. It aligns precisely with ThakiCloud's emphasis on on-premises deployment, cost efficiency, and self-hosting. That said, the 15x figure is a ceiling measured on Blackwell with TensorRT-LLM; expectations should be adjusted for the GPU generation and serving backend actually in use.

Third, **the gains are largest on math and code workloads**. Internal coding agents, data analysis pipelines, and tool-heavy agent workloads produce structured outputs, so acceptance rates tend to be higher. Tenants running these workloads are likely to see above-average gains from DFlash. Given ThakiCloud's focus on multi-tenant agent platforms, it makes sense to prioritize DFlash serving profiles for tenants with code and reasoning workloads.

A natural longer-term roadmap: expose speculative decoding method as a per-tenant serving profile in the vLLM Helm chart, and run a background cost measurement loop to track whether token-per-dollar actually improves after DFlash is applied. The principle of measuring rather than assuming applies to inference optimization as much as anywhere else.

## Limitations and Caveats

DFlash is not a universal solution. The headline numbers are tied to specific hardware and backends. The 15x result requires Blackwell with TensorRT-LLM; older GPU generations and other serving stacks will see smaller gains. The 6x lossless figure is single-stream greedy decoding; high-temperature sampling and conversational workloads with more varied outputs will lower acceptance rates and reduce the benefit (MT-Bench at 2.75x illustrates this).

Second, speculative decoding adds memory overhead. The draft model and its KV cache occupy GPU memory, which can create trade-offs with concurrency limits in memory-constrained multi-tenant environments. The small drafter reduces this burden but does not eliminate it.

Third, the responsibility for operational validation rests with the operator. The published figures are clearly sourced, but there is no guarantee they reproduce identically under your model, traffic, and concurrency. As noted, ThakiCloud has not reproduced these results in our environment, so we cannot verify them independently. Canary deployment with direct measurement of token cost and p50/p99 latency is required before committing to production. Finally, because block diffusion drafters are a relatively new approach, not all model architectures have checkpoints available. Check that a draft checkpoint exists for your target model before proceeding.

## Sources

- [Boost Inference Performance up to 15x on NVIDIA Blackwell Using DFlash Speculative Decoding (NVIDIA Technical Blog, 2026-06-23)](https://developer.nvidia.com/blog/boost-inference-performance-up-to-15x-on-nvidia-blackwell-using-dflash-speculative-decoding)
- [DFlash Speculative Decoding Drafts Whole Token Blocks in Parallel (MarkTechPost, 2026-06-24)](https://www.marktechpost.com/2026/06/24/dflash-speculative-decoding-drafts-whole-token-blocks-in-parallel-for-up-to-15x-higher-throughput-on-nvidia-blackwell/)
- [DFlash public checkpoint collection (Hugging Face, z-lab/dflash)](https://huggingface.co/collections/z-lab/dflash)
- [vLLM Speculative Decoding documentation](https://docs.vllm.ai/en/latest/features/speculative_decoding/)
