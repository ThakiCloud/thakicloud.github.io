---
title: "The Center of Gravity Has Shifted: Reading the Open Model Ecosystem Through the ATOM Report"
excerpt: "The ATOM Report measures open language models across both downloads and inference usage in one place, and shows with data that Chinese open models overtook the U.S. camp in the summer of 2025 and have widened the gap since. Qwen crossed roughly one billion cumulative downloads on Hugging Face, while DeepSeek leads the OpenRouter inference market. We read what this shift means from the perspective of ThakiCloud, which runs on-prem and sovereign infrastructure."
seo_title: "Reading the Open Model Ecosystem Through the ATOM Report - Thaki Cloud"
seo_description: "The ATOM Report (arXiv 2604.07190) measures both Hugging Face downloads and OpenRouter inference usage to map the open language model ecosystem. We summarize its key findings, Qwen's billion downloads, the mid-2025 Chinese overtake, DeepSeek's inference lead, and the rise of GPT-OSS, then draw implications for ThakiCloud's ai-platform, which serves open models in on-prem multi-tenant clusters."
date: 2026-07-06
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/research/atom-report-open-model-ecosystem/"
tags:
  - research
  - open-weight
  - qwen
  - deepseek
  - open-source-llm
  - inference
  - on-prem-llm
  - sovereign-ai
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "flask"
categories:
  - research
published: false
---

## Who Should Read This

This post is for engineers and technical leaders who have to decide which open model to run on their own infrastructure. It is aimed at people who want to move past impressions like "I hear Llama is good these days" and instead confirm with data what people actually download and what they actually run inference on. The ATOM Report is a rare piece of work that measures both of those axes in one place, and its conclusion is that the center of gravity of open models has visibly moved over the past year.

## Overview: Why a Map of the Open Model Landscape Now

When we talk about open language models, we usually look at benchmark tables. But a scoreboard tells us what performs well, not what actually gets used. It is common for a top-ranked model to be one that almost nobody deploys, and equally common for a model with unremarkable scores to be overwhelmingly adopted in the field. For anyone operating infrastructure, the latter is the real signal. What the community actually holds in its hands and puts into production determines which ecosystem we should bet on.

The ATOM Report (arXiv 2604.07190, published April 8, 2026) answers exactly this question head-on. Produced by Interconnects, the report covers roughly 1,500 mainline open models and cross-references Hugging Face downloads, derivative model counts, inference market share, and performance metrics to draw a snapshot of the entire open model ecosystem. Its value lies in being a top-down map of the ecosystem rather than one organization boasting about the success of its own model.

## What the ATOM Report Measured

The methodology begins by trying to avoid the trap of a single metric. Attempts to reduce the success of an open model to one number almost always distort. Look only at Hugging Face downloads and models with active fine-tuning communities get overrated; look only at inference API calls and models that landed well on commercial hosting get overrated. The ATOM Report separates these two and places them side by side. One is a download lens that shows what developers pull down and tinker with themselves; the other is an inference lens that shows where real production traffic flows.

The key point is that these two lenses show different pictures. On download metrics, model families with large derivative ecosystems lead; on inference metrics, usage is spread more evenly across organizations. Only by overlaying the two photographs taken from different angles does the ecosystem become three-dimensional. That methodological stance is something the report repeatedly emphasizes.

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
<div class="d3-arch" data-arch-root id="reportopenmodelecosystem-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 472, "height": 726, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 135, "y": 24, "w": 184, "h": 62, "title": ["Open model ecosystem", "~1,500 mainline models"]}, {"id": "B", "x": 249, "y": 164, "w": 191, "h": 78, "title": ["Download lens", "Hugging Face cumulative", "downloads + derivatives"]}, {"id": "C", "x": 24, "y": 164, "w": 170, "h": 78, "title": ["Inference lens", "OpenRouter inference", "market share"]}, {"id": "D", "x": 263, "y": 320, "w": 163, "h": 62, "title": ["What developers", "hold in their hands"]}, {"id": "E", "x": 38, "y": 320, "w": 142, "h": 62, "title": ["Where production", "traffic flows"]}, {"id": "F", "x": 149, "y": 460, "w": 156, "h": 62, "title": ["Cross-analysis", "= 3D ecosystem map"]}, {"id": "G", "x": 145, "y": 600, "w": 163, "h": 94, "title": ["Core conclusion", "Chinese open models", "moved the center of", "gravity"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[279, 86], [345, 125], [345, 125], [345, 164]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[175, 86], [109, 125], [109, 125], [109, 164]]}, {"src": "B", "dst": "D", "kind": "data", "line": [345, 242, 345, 320]}, {"src": "C", "dst": "E", "kind": "data", "line": [109, 242, 109, 320]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[345, 382], [345, 421], [345, 421], [279, 460]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[109, 382], [109, 421], [109, 421], [175, 460]]}, {"src": "F", "dst": "G", "kind": "data", "line": [227, 522, 227, 600]}]});
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
      const container = document.getElementById('reportopenmodelecosystem-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'reportopenmodelecosystem-1';
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

## Key Finding: Chinese Open Models Reshaped the Landscape

The report's heaviest finding is a reversal in the regional balance. Chinese open models overtook the U.S. camp in the summer of 2025 and have since widened the gap rather than closing it. This is not a single flashy release pulling ahead briefly; it is a structural shift observed on both the download and inference axes together.

On the download axis, the name that symbolizes this shift is Qwen. Alibaba's Qwen family is the single most-used open model family, reaching roughly one billion cumulative downloads as of March 2026. Its derivative count exceeds 100,000. Other families such as Llama, DeepSeek, and Kimi follow, but the gap to Qwen is substantial. A single family carrying a derivative ecosystem of that scale means the layer of developers who fine-tune and redistribute on top of it is that much thicker. Ecosystems run on this kind of momentum. Heavy use accumulates tooling and recipes, and abundant tooling drives more use.

The inference axis looks a little different. On OpenRouter measurements, usage is split more across organizations rather than concentrated in one family, and within that split DeepSeek leads. Qwen is ahead on downloads while DeepSeek carries a strong presence in actual traffic, and this asymmetry is exactly why the two lenses deserve to be read separately. The models people download to experiment with are not necessarily the models they actually put into service and pay to run.

The report does not cover only the models at the center of attention. It also traces the rise of GPT-OSS, OpenAI's open-weight family; the growing influence of mid-tier Chinese organizations such as Moonshot, Z.ai, and MiniMax; and signs of the U.S. camp making renewed progress on open models. The observation that the landscape is made by this thick middle layer rather than by a few names at the top quietly warns why a strategy that leans on a single star model is risky.

## Downloads and Inference, Two Different Lenses

This point deserves a closer look, because for someone designing infrastructure the difference between these two lenses is not a matter of statistics but a practical decision.

Download metrics are useful for reading the vitality and future direction of an ecosystem. If a family's derivatives are exploding in number, that means quantized builds, serving optimizations, fine-tuning scripts, and adapters for that family are pouring out alongside. The tooling and community support we can lean on when we adopt that family grow accordingly. Inference metrics, by contrast, are useful for reading the economics of the present moment. Where real traffic flows is social proof that a model's price-performance works in the field, and a signal that hosting infrastructure is likely already tuned for it.

Which lens to trust when the two diverge depends on the goal. If you are choosing a base model to carry an in-house fine-tuning pipeline for a long time, the thickness of the download and derivative ecosystem matters more. If you are choosing a serving target that is cost-effective right now, the actual share in the inference market is the more accurate compass. That is precisely why the ATOM Report keeps the two axes separate all the way through.

## Implications for ThakiCloud

This shift in the landscape overlaps exactly with the problem ThakiCloud's ai-platform targets. The ai-platform schedules GPU resources with Kueue on top of Kubernetes and serves a variety of open models in a multi-tenant environment using vLLM. A widening open model ecosystem with a shifting center of gravity means the list of models our customers want to serve keeps changing.

First, the value of a serving abstraction that is not locked into any one model family grows. If today's asymmetry, with Qwen leading downloads and DeepSeek leading inference, can shift again in six months, infrastructure must be able to deploy and scale whatever family rises in the same way. This variability is exactly why ai-platform treats models as first-class resources and standardizes the serving pipeline.

Second, the rise of open weights strengthens the economic case for on-prem and sovereign deployment. As open models that approach the top tier become runnable on your own cluster without depending on commercial APIs, public sector, financial, and defense customers who cannot send data outside gain a real option. ThakiCloud targets the point where low serving cost and data sovereignty are satisfied at the same time in such environments. The wider the open model landscape grows, the more persuasive this position becomes.

Third, the ATOM Report's very methodology of reading downloads and inference separately offers an operational lesson. When a customer requests a model because "this one is trending," we should be able to distinguish whether that is download buzz or real inference economics. An infrastructure provider has a responsibility to recommend serving targets based on actual usage data rather than fashion.

## Limits and Counterpoints

There are caveats to keep in mind while reading this report. Both downloads and inference usage are proxy metrics. Downloads can be inflated by automated pipelines or mirroring, and crawlers and redistribution distort the numbers. OpenRouter inference share reflects only the traffic that passes through that router, so the vast usage that large operators run directly on their own infrastructure is outside the measurement range from the start. Blind spots remain even after overlaying the two lenses.

Equating the reversal of the regional balance directly with a reversal of capability is also hasty. Adoption is the result of price, license, accessibility, and ecosystem momentum together, not performance alone. Chinese open models being widely used owes as much to aggressive openness strategies and low barriers to entry as to strong performance. "Widely used" is a different proposition from "best," and what the report measured is the former.

Finally, this snapshot ages quickly. In a field that lurches on the scale of months, the April 2026 map may already differ a little from today's terrain. Even so, the report's worth lies not in individual rankings but in the methodology of reading downloads and inference separately and in the broad current that the center of gravity has moved. That current is likely to hold for a while, and those of us preparing infrastructure need only keep our serving stack open in that direction.

## Sources

- ATOM Report: Measuring the Open Language Model Ecosystem, arXiv:2604.07190 (2026-04-08). <https://arxiv.org/abs/2604.07190>
- Interconnects, "What I've been building: ATOM Report". <https://www.interconnects.ai/p/what-ive-been-building-atom-report>
