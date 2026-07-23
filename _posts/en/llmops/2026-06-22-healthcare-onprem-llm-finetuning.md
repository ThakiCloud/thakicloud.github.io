---
title: "Fine-Tuning LLMs On-Premises Without Exporting Patient Data - Healthcare and Biomedical AI Infrastructure"
excerpt: "A complete workflow for healthcare organizations to fine-tune and serve domain-specific LLMs on in-house GPU clusters without sending patient data to external clouds. Covers ThakiCloud AI Platform's six fine-tuning methods, DevSpace, and vLLM Scale-to-Zero deployment."
seo_title: "Healthcare LLM Fine-Tuning On-Premises - Build AI Without Exporting Hospital or Pharma Data - Thaki Cloud"
seo_description: "How to fine-tune and serve a healthcare LLM on-premises without exporting patient data. A complete guide to building domain-specific healthcare AI on-premises using six tuning methods (SFT, DPO, LoRA, and more) and vLLM Scale-to-Zero."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: en
tags:
  - healthcare
  - fine-tuning
  - on-premise
  - llm
  - data-privacy
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/healthcare-onprem-llm-finetuning/"
reading_time: true
categories:
  - llmops
published: false
---

![Fine-tuning healthcare LLMs on-premises without exporting patient data]({{ '/assets/images/healthcare-onprem-llm-finetuning-hero.webp' | relative_url }})

## Overview

LLM adoption in the healthcare and biomedical sector is accelerating rapidly. As use cases expand -- clinical note summarization, diagnostic assistance, pharmaceutical literature analysis, and prescription code automation -- hospitals, pharmaceutical companies, and research institutions are beginning to evaluate domain-specific model development.

Yet the biggest barrier to healthcare AI is not technology. It is data governance. Domestic medical law, personal information protection regulations, bioethics legislation, and National Intelligence Service (NIS) security requirements effectively prohibit or severely restrict the transmission of patient information to external servers. In this environment, the approach of "uploading data to a cloud API for fine-tuning" is neither legally nor practically viable.

This article uses hypothetical cases of a large general hospital and a pharmaceutical research institute to explain the full workflow for fine-tuning and serving a domain LLM inside an on-premises Kubernetes cluster without exporting data. The workflow is built on ThakiCloud AI Platform, and each stage describes which components are actually at work.

---

## Why Healthcare Data Cannot Go to the Cloud

### The Regulatory Environment

Domestic healthcare data is bound by multiple layers of regulation.

**Article 21 of the Medical Service Act** prohibits the external provision of medical records without patient consent. The **Personal Information Protection Act** imposes explicit consent requirements and security obligations for third-party transfers of sensitive information (diagnoses, prescription histories, genetic data, and so on). The **Act on Bioethics and Safety** treats the overseas transfer of human-derived materials and genetic information as a separately approved matter. Public healthcare institutions and defense-related research institutes must also pass NIS security suitability reviews, and they frequently operate in air-gapped environments where external API connectivity is entirely blocked.

### Practical Risks

Beyond regulation, there are operational risks. Cases have already been reported abroad where clinical notes were sent to external AI APIs without de-identification, resulting in privacy-violation lawsuits. Even the claim "de-identification makes it acceptable" is legally tenuous due to the possibility of re-identification through quasi-identifier linkage.

The conclusion is clear. Healthcare AI models must be trained and served where the data lives -- inside the on-premises cluster.

---

## On-Premises Fine-Tuning Workflow

ThakiCloud AI Platform is built on Kubernetes, and all training and inference is completed entirely within the on-premises cluster. Data does not leave the internal network. The pipeline below walks through each stage.

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
<div class="d3-arch" data-arch-root id="hcareonpremllmfinetuning-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 915, "height": 1480, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 362, "y": 24, "w": 184, "h": 78, "title": ["Source Data", "Clinical Notes / EMR /", "Prescription Codes"]}, {"id": "B", "x": 365, "y": 180, "w": 177, "h": 78, "title": ["De-identification", "Preprocessing", "Hospital-Internal ETL"]}, {"id": "C", "x": 348, "y": 336, "w": 212, "h": 94, "title": ["Dataset Upload", "ThakiCloud Dataset Manager", "HuggingFace Format /", "S3-Compatible Storage"]}, {"id": "D", "x": 342, "y": 508, "w": 223, "h": 52, "title": "Choose Fine-Tuning Method"}, {"id": "E1", "x": 699, "y": 638, "w": 184, "h": 62, "title": ["SFT", "Supervised Fine-Tuning"]}, {"id": "E2", "x": 481, "y": 638, "w": 163, "h": 62, "title": ["LoRA / QLoRA", "Lightweight Adapter"]}, {"id": "E3", "x": 263, "y": 638, "w": 163, "h": 62, "title": ["DPO", "Preference Learning"]}, {"id": "E4", "x": 24, "y": 638, "w": 184, "h": 62, "title": ["CPT", "Continued Pre-Training"]}, {"id": "F", "x": 372, "y": 778, "w": 163, "h": 94, "title": ["DevSpace", "Jupyter / VSCode", "Experimentation and", "Validation"]}, {"id": "G", "x": 369, "y": 950, "w": 170, "h": 62, "title": ["Kubeflow TrainJob", "Kueue GPU Scheduling"]}, {"id": "H", "x": 372, "y": 1090, "w": 163, "h": 62, "title": ["Trained Model", "On-Premises Storage"]}, {"id": "I", "x": 355, "y": 1230, "w": 198, "h": 62, "title": ["vLLM Serverless Endpoint", "KEDA Scale-to-Zero"]}, {"id": "J", "x": 362, "y": 1370, "w": 184, "h": 78, "title": ["Internal API Consumers", "EMR System / Clinical", "Decision Support"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [454, 102, 454, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [454, 258, 454, 336]}, {"src": "C", "dst": "D", "kind": "data", "line": [454, 430, 454, 508]}, {"src": "D", "dst": "E1", "kind": "data", "curve": [[565, 555], [791, 599], [791, 599], [791, 638]]}, {"src": "D", "dst": "E2", "kind": "data", "curve": [[497, 560], [563, 599], [563, 599], [563, 638]]}, {"src": "D", "dst": "E3", "kind": "data", "curve": [[410, 560], [345, 599], [345, 599], [345, 638]]}, {"src": "D", "dst": "E4", "kind": "data", "curve": [[342, 555], [116, 599], [116, 599], [116, 638]]}, {"src": "E1", "dst": "F", "kind": "data", "curve": [[791, 700], [791, 739], [791, 739], [535, 804]]}, {"src": "E2", "dst": "F", "kind": "data", "curve": [[563, 700], [563, 739], [563, 739], [513, 778]]}, {"src": "E3", "dst": "F", "kind": "data", "curve": [[345, 700], [345, 739], [345, 739], [394, 778]]}, {"src": "E4", "dst": "F", "kind": "data", "curve": [[116, 700], [116, 739], [116, 739], [372, 804]]}, {"src": "F", "dst": "G", "kind": "data", "line": [454, 872, 454, 950]}, {"src": "G", "dst": "H", "kind": "data", "line": [454, 1012, 454, 1090]}, {"src": "H", "dst": "I", "kind": "data", "line": [454, 1152, 454, 1230]}, {"src": "I", "dst": "J", "kind": "data", "line": [454, 1292, 454, 1370]}]});
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
      const container = document.getElementById('hcareonpremllmfinetuning-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'hcareonpremllmfinetuning-1';
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

*The diagram above represents a conceptual flow. Actual configuration parameters may vary by environment.*

### Stage 1: Dataset Preparation and Upload

Medical data cannot be used for fine-tuning in its raw form. The hospital-internal ETL pipeline must perform de-identification (removing names, national ID numbers, and hospital registration numbers), format conversion (converting FHIR JSON or free text into instruction-response pairs), and quality filtering (deduplication and removal of abnormal-length records).

The preprocessed data is then uploaded to on-premises storage through ThakiCloud's dataset manager. Because the platform supports HuggingFace dataset format and S3-compatible object storage, integration with existing data pipelines is straightforward. Volume and snapshot features allow dataset versioning, with rollback to previous versions when needed.

```python
# Conceptual example - placeholder, not the actual API specification
dataset_config = {
    "name": "clinical-notes-sft-v1",
    "format": "jsonl",
    "schema": {
        "instruction": "string",   # e.g., "Summarize the following clinical note."
        "input": "string",         # Clinical note body
        "output": "string"         # Specialist-authored summary
    },
    "storage": "s3://internal-bucket/datasets/clinical-notes/",
    "privacy_level": "restricted"  # Access restricted via RBAC
}
```

Keycloak-based RBAC controls dataset access permissions at the organization, project, and role level. Research teams can see only the datasets belonging to their own projects, and cross-organizational data mixing is blocked at the system level.

### Stage 2: Selecting a Fine-Tuning Method

ThakiCloud AI Platform supports six fine-tuning methods. The right choice depends on the characteristics of the healthcare domain.

**SFT (Supervised Fine-Tuning)**: The most intuitive approach. It is suited for situations where sufficient instruction-response pair data is available. Ideal for tasks with clear correct answers, such as clinical note summarization, prescription code classification, and lab result interpretation. Data quality matters greatly; a small set of high-quality, specialist-reviewed data typically outperforms a large volume of unreviewed data.

**LoRA / QLoRA (Low-Rank Adaptation)**: Enables efficient fine-tuning of large base models in GPU-memory-constrained environments. Because only adapter layers are trained, [estimate] only 1-5% of parameters relative to the total are updated. This is a realistic choice for small and mid-sized hospitals or research institutes with limited A100 GPUs that need to fine-tune models on the scale of Llama-3 70B or Qwen-2.5 72B.

**DPO (Direct Preference Optimization)**: Trains on preference data where a preferred response is chosen from two options. This is well suited to encoding healthcare domain requirements such as "the diagnostic assistance system should give safer, more conservative answers." It is primarily used as an alignment stage following SFT.

**CPT (Continued Pre-Training)**: Used to inject domain knowledge into the base model using large volumes of unstructured text such as medical papers, pharmacology textbooks, and clinical guidelines. The data volume is large and training time is long, but the model gains a deeper understanding of medical terminology and concepts.

**GKD (Generalized Knowledge Distillation)**: Transfers knowledge from a larger teacher model (one already validated internally) to a smaller student model. Useful when serving cost must be reduced while maintaining quality. Appropriate when the actual serving model must be small and fast but should retain as much of the teacher's expertise as possible.

**GRPO (Group Relative Policy Optimization)**: A reinforcement-learning-based approach that uses group-relative rewards. Used for complex medical diagnostic reasoning tasks or to reinforce specific safety guidelines.

### Stage 3: Experimentation and Validation in DevSpace

Before launching a full fine-tuning run, small-scale experiments are conducted in DevSpace. DevSpace is a Jupyter Notebook or VS Code environment running on a Kubernetes Pod that has direct access to in-cluster GPUs.

Researchers connect to the DevSpace environment via Pod SSH and test training scripts on a small subset of data. Completing hyperparameter tuning (learning rate, batch size, LoRA rank, and so on) and data format validation at this stage reduces wasted GPU time in subsequent full training jobs.

```bash
# Example DevSpace Pod connection (placeholder - actual commands depend on platform configuration)
# ssh <devspace-pod-name>.<namespace>.svc.cluster.local

# Small-scale LoRA experiment example
python train.py \
  --model_name_or_path /mnt/models/llama3-8b \
  --data_path /mnt/datasets/clinical-notes-sample \
  --method lora \
  --lora_r 16 \
  --lora_alpha 32 \
  --num_train_epochs 3 \
  --per_device_train_batch_size 4 \
  --output_dir /mnt/checkpoints/exp-001
```

### Stage 4: Full Training with Kubeflow TrainJob

Once experimental results are satisfactory, a full training run against the complete dataset is launched through a Kubeflow TrainJob. Kueue and the KAI scheduler share GPU resources with other hospital workloads while allocating the required GPUs to training jobs according to priority.

Multi-GPU distributed training (such as PyTorch DDP or DeepSpeed ZeRO) can also be declared declaratively in the Kubeflow TrainJob spec.

```yaml
# Conceptual TrainJob example - placeholder
apiVersion: kubeflow.org/v1
kind: PyTorchJob
metadata:
  name: clinical-notes-sft-run1
  namespace: hospital-ai
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      template:
        spec:
          containers:
          - name: trainer
            image: registry.internal/thakicloud/trainer:v1.2
            args:
            - "--method=sft"
            - "--data=/mnt/datasets/clinical-notes-v1"
            - "--model=/mnt/models/qwen2.5-7b"
            - "--output=/mnt/checkpoints/clinical-qwen-v1"
            resources:
              limits:
                nvidia.com/gpu: "4"
    Worker:
      replicas: 3
      # ...
```

DCGM GPU telemetry provides real-time monitoring of GPU utilization, memory usage, and temperature during training. Anomalies trigger alerts, and checkpoint-based safe restarts are available.

Trained models are stored in on-premises storage (including volume and snapshot management). Data never leaves the internal cluster from start to finish.

---

## Serving and Operations

### vLLM Serverless Endpoint

Trained domain models are served via a vLLM-based serverless inference endpoint. vLLM uses PagedAttention to manage GPU memory efficiently and achieves high throughput through continuous batching.

Integration with KEDA (Kubernetes Event-Driven Autoscaling) implements Scale-to-Zero functionality. When there are no requests, the inference server scales down to zero; it scales back up automatically when requests arrive. Because hospital LLM usage patterns tend to be concentrated during daytime hours, GPUs need not be left idle overnight.

```yaml
# Conceptual KEDA ScaledObject example - placeholder
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: clinical-llm-endpoint
  namespace: hospital-ai
spec:
  scaleTargetRef:
    name: clinical-llm-deployment
  minReplicaCount: 0      # Scale-to-Zero
  maxReplicaCount: 4
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus:9090
      metricName: vllm_requests_pending
      threshold: "5"      # Scale up when 5 or more requests are pending
```

### Inference Cost Structure

External LLM APIs (such as the GPT-4 API) charge per token. For high-volume tasks with long input contexts, such as clinical note summarization, monthly bills can grow rapidly. Transmitting clinical data through an API also introduces the regulatory risks described above.

An on-premises vLLM endpoint requires upfront GPU infrastructure investment, but there are no additional per-token costs thereafter. If a hospital can reuse GPU servers it already owns or HPC infrastructure procured for clinical research, marginal costs reduce to electricity and operational personnel expenses.

### RBAC and Multi-Tenant Isolation

Large healthcare organizations require different departments, research teams, and administrative units to access different data and models. ThakiCloud's Keycloak-based RBAC manages permissions at the organization, project, and role levels (Admin / Developer / Viewer). Group information is embedded in JWT tokens for real-time access validation.

The endocrinology team's fine-tuned diabetes diagnostic assistance model can be scoped to its project so that the cardiology team cannot access it. This limits not only internal data isolation but also the risk of model misuse (the wrong model in the wrong context).

### lm-eval Benchmarking

To quantify model quality before serving, the lm-eval benchmarking feature is used. Internally built healthcare domain evaluation datasets (QA sets reviewed by specialists) are registered, and the degree of improvement of the trained model over the base model is measured.

---

## ThakiCloud Application Insights

### Hypothetical Case: Clinical Note Summarization at a Tertiary General Hospital

Consider a hypothetical Hospital A. Hospital A faced the problem that writing discharge summaries for inpatient encounters consumed significant physician time. Introducing an external AI API was difficult to execute due to complex procedures including personal information processing entrustment agreements, security reviews, and information protection committee approvals.

If an on-premises approach were chosen, the process would proceed as follows.

1. De-identified historical discharge summary data (pairs of original clinical notes and specialist-authored summaries) is processed by an internal ETL pipeline.
2. The data is uploaded to the ThakiCloud dataset manager and access permissions are granted to the clinical informatics team's project.
3. Small-scale SFT experiments in DevSpace are used to explore an appropriate base model (such as Llama-3 8B or Qwen2.5 7B) and hyperparameters.
4. Full training is launched via a Kubeflow TrainJob, using distributed training across 8 in-hospital GPU nodes.
5. Once ROUGE and domain QA scores measured with lm-eval meet quality thresholds, the model is deployed as a vLLM endpoint.
6. The EMR system calls the internal API to receive summarization results and provide draft summaries to physicians.

Data never leaves Hospital A's data center.

### Hypothetical Case: Clinical Trial Literature Analysis at a Pharmaceutical Research Institute

A hypothetical Institute B sought to automate the extraction of safety signals from clinical trial protocol documents and adverse drug reaction reports. This data contained research subject information and unpublished clinical results, making external transfer impossible.

A two-stage approach is effective: use CPT (Continued Pre-Training) on hundreds of thousands of internally acquired medical literature records to strengthen the base model's domain knowledge, then use SFT to specialize it for the safety signal extraction task. With Scale-to-Zero configuration, GPUs are allocated only when the research team is using the system, and other computational workloads can utilize the GPUs overnight and on weekends.

---

## Limitations and Considerations

### Operational Capability Requirements

An on-premises LLM platform, unlike external SaaS, requires internal operational capabilities. MLOps engineers are needed to handle Kubernetes cluster management, GPU driver maintenance, model version management, and security patch application. For small hospitals or research institutes, internalizing these capabilities may be challenging.

### Data Quality Determines Performance

Fine-tuning results are absolutely dependent on data quality. Running SFT on clinical notes that have not been reviewed by specialists can result in training on errors. The physician time and annotation process costs required to secure high-quality labeled data must be planned for in advance.

### Verify Base Model Licenses

Even when applying LoRA or SFT, the license terms of the base model must be verified. Permissions for commercial use and clauses restricting use for medical purposes vary by model. Major open-source models such as Llama-3, Qwen, and Gemma each have different terms of use, so legal team review should precede any deployment.

### Managing Inference Latency

With Scale-to-Zero configuration, model loading time (cold start) occurs on the first request. Even a 7B-scale model can take tens of seconds to load onto a GPU. For latency-sensitive applications such as real-time clinical decision support, the minimum replica count should be kept at 1, or another pre-warming strategy should be applied.

### Model Validation and Regulatory Compliance

AI-based clinical decision support systems may be subject to the Ministry of Food and Drug Safety's medical device approval process. If a model is used in a way that renders "diagnoses," the Software as a Medical Device (SaMD) regulations must be reviewed. lm-eval benchmarking results and internal validation data serve as supporting evidence in this process. However, regulatory compliance goes beyond the scope of platform features and requires specialized regulatory consulting.

---

In healthcare and biomedical LLM adoption, the question of "how to leverage AI while protecting data" is a governance problem before it is a technology problem. An on-premises fine-tuning platform is one practical answer to that question. The approach of keeping data in-house without sacrificing model quality has now matured to an operationally viable level within a Kubernetes environment.

*The hypothetical cases in this document are written for illustrative purposes and do not refer to actual institutions. Review with legal and regulatory experts is recommended before building a healthcare AI system.*
