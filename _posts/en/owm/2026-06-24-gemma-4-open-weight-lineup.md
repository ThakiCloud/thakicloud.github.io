---
title: "The Complete Gemma 4 Lineup: Five Apache 2.0 Open-Weight Models and an On-Premises Serving Guide"
excerpt: "Released by Google DeepMind in April 2026, Gemma 4 is a multimodal open-weight family of five models spanning E2B to 31B. We break down the Apache 2.0 license, 256K context, the difference between the 26B MoE and 31B Dense, and how to pick each model from an on-premises serving perspective."
seo_title: "Gemma 4 Lineup Compared - E2B/E4B/12B/26B MoE/31B On-Prem Guide - Thaki Cloud"
seo_description: "Gemma 4 lineup (E2B, E4B, 12B Unified, 26B A4B MoE, 31B Dense): parameters, context, multimodality, benchmarks (MMLU-Pro 85.2%, GPQA 84.3%), vLLM/SGLang/Ollama serving, and the Apache 2.0 license."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - gemma-4
  - google-deepmind
  - open-weight
  - apache-2.0
  - mixture-of-experts
  - multimodal
  - edge-ai
  - vllm
  - sglang
  - on-premise
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/owm/gemma-4-open-weight-lineup/"
lang: en
reading_time: true
categories:
  - owm
---

⏱️ **Estimated reading time**: 10 min

![Gemma 4 lineup concept]({{ '/assets/images/gemma-4-open-weight-lineup-hero.webp' | relative_url }})

## Gemma 4 Overview

Released by Google DeepMind on April 2, 2026, Gemma 4 is the most intelligent open-weight model family Gemma has shipped to date. Google states that it was built on the same research and technology that underpins Gemini 3. In other words, think of it as the training recipe behind a closed flagship distilled down into an open-weight lineup.

From a ThakiCloud perspective, two changes stand out this generation. First, the license moved to **Apache 2.0**. Unlike earlier Gemma generations that carried a separate Gemma usage policy, Gemma 4 adopts a commercially permissive standard open-source license. Second, it ships not as a single size but as a five-model lineup that spans **everything from the edge (phones) to a single server GPU**. That means you can pick a deployment target by device tier within the same model family.

Rather than going deep on a single model, this post aims to **compare all five models at a glance and clarify which one to choose for which situation**.

## The Gemma 4 Lineup: All Five Models

Gemma 4 consists of the following five models. Organized by parameters, context, modality, and architecture per the model card:

| Model | Parameters | Context | Input Modalities | Architecture |
|---|---|---|---|---|
| **E2B** | 2.3B effective (5.1B with embeddings) | 128K | Text + Image + Audio | Dense |
| **E4B** | 4.5B effective (8B with embeddings) | 128K | Text + Image + Audio | Dense |
| **12B Unified** | 11.95B | 256K | Text + Image + Audio | Dense |
| **26B A4B** | 25.2B total / 3.8B active | 256K | Text + Image | MoE (8 of 128 experts active) |
| **31B Dense** | 30.7B | 256K | Text + Image | Dense |

All five output text. Audio input is supported only on the E2B, E4B, and 12B models; the 26B and 31B handle text and image.

The "E" in `E2B` and `E4B` stands for effective parameters. It is the size based on actual compute parameters excluding the embedding table, and effective values are the more realistic figure when gauging memory and compute budgets. Both models squarely target edge devices such as phones and laptops.

The heart of the lineup is the **division of labor between the two top models: the 26B A4B (MoE) and the 31B (Dense)**.

- **26B A4B** is a Mixture-of-Experts. It holds 25.2B total parameters but activates only about 3.8B per token. The full weights still have to sit in VRAM, but per-token compute (FLOPs) is based on the active parameters, which is **favorable for latency and throughput**. It suits serving where you need to push large volumes of requests quickly.
- **31B Dense** is a standard dense model where every parameter participates on every token. Oriented toward maximizing quality and fine-tuning suitability, Google positions the 31B as the quality ceiling of the lineup.

According to Google, the 31B ranked #3 among open models worldwide on the Arena AI text leaderboard and the 26B placed #6, and it described the lineup as "competing with models 20x its size." Such leaderboard rankings shift over time, so it is better to read them as a direction ("high intelligence density relative to its class") than as absolute figures.

### Model Selection Flow

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
<div class="d3-arch" data-arch-root id="24gemma4openweightlineup-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 614, "height": 540, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 321, "y": 24, "w": 184, "h": 46, "title": "Choose a Gemma 4 model"}, {"id": "B", "x": 326, "y": 148, "w": 174, "h": 52, "title": "Deployment target?"}, {"id": "C", "x": 419, "y": 292, "w": 163, "h": 62, "title": ["E2B / E4B", "128K, audio support"]}, {"id": "D", "x": 226, "y": 297, "w": 138, "h": 52, "title": "Priority?"}, {"id": "E", "x": 425, "y": 446, "w": 120, "h": 62, "title": ["26B A4B MoE", "active 3.8B"]}, {"id": "F", "x": 250, "y": 454, "w": 120, "h": 46, "title": "31B Dense"}, {"id": "G", "x": 32, "y": 446, "w": 163, "h": 62, "title": ["12B Unified", "256K, audio support"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [413, 70, 413, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "Phone/edge device", "curve": [[444, 200], [500, 246], [500, 246], [500, 292]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Single-GPU on-prem", "curve": [[370, 200], [295, 246], [295, 246], [295, 297]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "Throughput/latency", "curve": [[359, 349], [485, 400], [485, 400], [485, 446]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "Top quality/fine-tuning", "line": [300, 349, 310, 454], "lx": 310, "ly": 396}, {"src": "D", "dst": "G", "kind": "data", "label": "Multimodal + audio + balance", "curve": [[234, 349], [114, 400], [114, 400], [114, 446]], "off": "50%"}]});
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
      const container = document.getElementById('24gemma4openweightlineup-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '24gemma4openweightlineup-1';
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

## Architecture: Hybrid Attention and Multimodality

All five Gemma 4 models share a **hybrid attention** mechanism. It interleaves local sliding-window attention with full global attention. Short ranges are handled cheaply by the sliding window, while global attention is periodically inserted to capture full-context dependencies, with the goal of curbing memory and compute cost on long contexts. This design is the backdrop to the upper models (12B/26B/31B) handling a 256K context.

Multimodality is the default this generation. All five take text and image as input, and the edge/mid tiers (E2B/E4B/12B) also handle audio input. Features aimed at agentic workflows are built in too. Function calling, structured JSON output, and native system instructions are officially supported, and the lineup emphasizes improvements in multi-step planning and logical reasoning over the previous generation. The training data cutoff is January 2025.

Language support is broad: 35+ languages out of the box and 140+ languages at the pretraining level. Actual quality in Korean operation requires direct evaluation, but the multilingual coverage itself is wide.

## Benchmarks

The representative benchmarks Google published for the 31B instruction-tuned model are below, per the model card.

| Benchmark | 31B (IT) | Area Measured |
|---|---|---|
| MMLU-Pro | 85.2% | General knowledge & reasoning |
| GPQA Diamond | 84.3% | Graduate-level science reasoning |
| LiveCodeBench v6 | 80.0% | Code generation |
| MATH-Vision | 85.6% | Vision-grounded math |
| Codeforces (ELO) | 2150 | Competitive programming |

At the 31B single-node scale, GPQA Diamond at 84.3% and MMLU-Pro at 85.2% are top-tier among comparable open-weight models. That said, the benchmarks are for the instruction-tuned variant, and real domain-task performance must be validated separately. In particular, Korean reasoning and coding tasks are not directly reflected in public benchmarks, so measuring them with an internal eval set is recommended.

## Serving and Deployment

Gemma 4 secured broad serving-ecosystem support from launch. The official paths are:

- **Inference servers**: vLLM, SGLang, llama.cpp, Ollama, LM Studio, NVIDIA NIM
- **Frameworks**: Hugging Face Transformers / TRL / Transformers.js / Candle, Keras, MaxText, NeMo
- **Edge/on-device**: LiteRT-LM, Cactus
- **Fine-tuning/quantization**: Unsloth, Tunix
- **Deployment infra**: Docker, Baseten, Google Cloud (Vertex AI)

Weights can be downloaded from the [google/gemma-4 collection on Hugging Face](https://huggingface.co/collections/google/gemma-4), Kaggle, and Ollama.

### On-Prem GPU Requirements (Estimated)

A rough on-prem deployment guide based on each model's BF16 weight memory. These are weight estimates excluding KV cache and runtime overhead, so leave headroom for your context length and concurrent request count in an actual deployment.

| Model | BF16 weights (est.) | Realistic on-prem starting point |
|---|---|---|
| E2B / E4B | ~5–16GB [est.] | Consumer GPU, laptop, phone (LiteRT) |
| 12B Unified | ~24GB [est.] | Single 24GB GPU (RTX 4090/L4 class), headroom when quantized |
| 26B A4B (MoE) | ~50GB [est.] | A single H100/A100 80GB |
| 31B Dense | ~62GB [est.] | A single H100/A100 80GB |

The practical strength of the lineup is that both top models (26B, 31B) fit on **a single 80GB GPU** in BF16. That means you can run frontier-grade inference on a single server without multi-node tensor parallelism, which sharply lowers the bar to on-prem adoption. With a smaller GPU budget, step down to the 12B or to a quantized path (GGUF Q4/Q8). Thanks to its MoE nature computing only the active 3.8B, the 26B has a throughput edge per token over the 31B Dense at the same VRAM.

## Implications for the ThakiCloud K8s AI/ML SaaS Platform

The Gemma 4 lineup meshes well with ThakiCloud's multi-tenant serving strategy. It matters on three fronts.

**Apache 2.0 unlocks the adoption barrier.** A frontier-grade open-weight family released under standard Apache 2.0 is highly significant for enterprise and on-prem adoption. You can embed it in commercial services without the burden of reviewing a separate usage policy and freely distribute fine-tuned artifacts. It is a model family you can propose directly to environments with strict license compliance, such as domestic public-sector and finance, and to on-prem customers who require self-hosting.

**The lineup itself aligns with multi-tenant GPU routing.** ThakiCloud manages GPU quotas with Kueue and serves models with vLLM. Gemma 4's five-model lineup is a structure that lets you route model tiers within one family to match tenant needs (latency-sensitive, quality-first, edge inference). Route light chat/summarization to the 12B, throughput-critical batches to the 26B MoE, and high-difficulty reasoning/coding to the 31B, and you can optimize the GPU budget by task tier while keeping the same tokenizer and prompt format.

**Single-80GB-GPU serving simplifies the cost model.** That the 26B and 31B fit on a single H100/A100 simplifies Kueue GPU job cost estimation. The communication overhead and scheduling complexity of multi-node tensor parallelism disappear, so you can price cleanly with a per-tenant dedicated-single-GPU model. The 26B MoE's active-3.8B trait means it can take more concurrent requests on the same GPU, which is also favorable on a per-request unit-cost basis.

In short, Gemma 4 is a fit as a reference model family when ThakiCloud proposes a "single-GPU on-prem + multi-tenant model routing" operating pattern to customers.

## Limitations and Counterpoints

For balance, a few caveats deserve mention.

- **The gap between benchmarks and real use.** The published figures center on the instruction-tuned, English-language benchmarks. Korean domain tasks, especially RAG and agent tool-call accuracy, must be re-measured with your own eval set.
- **The operational difficulty of MoE serving.** The 26B A4B has low per-token compute but must keep the full weights resident in VRAM, and expert routing affects batch efficiency and memory patterns. The simplistic reading "it's small because active is 3.8B" is risky.
- **Asymmetric audio support.** Audio input exists only on E2B/E4B/12B. If you want top quality (26B/31B) and audio at the same time, a trade-off arises within the lineup.
- **January 2025 training cutoff.** Tasks needing the latest information must be supplemented with RAG and tool integration.

Even so, the Apache 2.0 license, the feasibility of single-GPU serving, and a lineup that bridges the edge to the server are reason enough to put Gemma 4 at the top of the evaluation list for any organization considering on-prem and self-hosting.

## References

- [Gemma 4 official announcement blog (Google)](https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/)
- [Gemma 4 model card (Google AI for Developers)](https://ai.google.dev/gemma/docs/core/model_card_4)
- [Gemma 4 model overview docs](https://ai.google.dev/gemma/docs/core)
- [google/gemma-4 collection on Hugging Face](https://huggingface.co/collections/google/gemma-4)
- [Google DeepMind Gemma GitHub library](https://github.com/google-deepmind/gemma)
- [Gemma 4 availability on Google Cloud](https://cloud.google.com/blog/products/ai-machine-learning/gemma-4-available-on-google-cloud)
