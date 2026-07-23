---
title: "The Agent That Writes Code and the Agent That Audits It Arrived on the Same Day"
excerpt: "On July 22, two open weight releases stood facing each other like mirror images. One generates code, the other finds vulnerabilities in it. Yet neither answers one question: on whose infrastructure, and with what authority, does that code actually run."
seo_title: "Generation Meets Audit: The Runtime Accountability Gap Open Weight Coding Agents Leave Behind"
seo_description: "Poolside's Laguna S 2.1 and Cisco's Antares launched on the same day. As code generation and code auditing both move to self hosted open weights, we examine the empty execution layer that still needs an owner."
date: 2026-07-22
last_modified_at: 2026-07-22
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "robot"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/generate-audit-runtime-accountability-gap/"
---

The symmetry is too precise to be coincidence. On July 22, 2026, two open weight models with opposite personalities arrived on the same day. One writes code. The other finds vulnerabilities in code. Poolside released Laguna S 2.1, a model built for self hosted coding agents, and Cisco introduced Antares, a small open weight model specialized in detecting code vulnerabilities. It is as if a sword and a shield were hung side by side in the same display case.

Read separately, these two releases are unremarkable news items each in their own right. Read together, the story changes. It means that both the side that builds software and the side that audits it are moving to agents at the same time. And the moment you put both models on your own infrastructure, a question remains that no one else will answer for you. On whose resources, under what authority, and leaving what record do these agents actually run.

## The Same Day, From Opposite Ends

Poolside's Laguna S 2.1 reads like a Western answer card. The announcement is aimed squarely at the trend where Chinese open weight models such as DeepSeek and Qwen had been pulling ahead in the coding agent space. Foreign outlets described it as the most credible Western open weight option released over the past year for self hosted agentic coding. What stands out is not the performance but the size. With a low activation architecture of only 8 billion active parameters, it reportedly matched competing models several times its size on benchmarks, and the real message is that it cuts both inference cost and the burden of running on premises. The fact that it can run on a single piece of DGX Spark class hardware means a dedicated coding agent can now fit onto even a small GPU partition.

Cisco's Antares makes the same case from the opposite side. A small on device language model, it argues, can beat huge general purpose models in security work on both cost and accuracy. Cisco claims Antares outperforms more than a dozen large open and closed models on benchmarks while running far more cheaply. What matters most here is where it executes. Because it runs locally, source code never has to leave the building. For financial institutions and public agencies under strict rules against exporting source code, that single fact can decide whether the tool gets adopted at all.

The two models point in opposite directions yet share the same design philosophy. Build small, release the weights openly, and run it on your own infrastructure rather than someone else's cloud. Even the deployment strategy matches. Releasing the core model as open weight while keeping the best performing version locked inside your own product has become the common grammar shared by security startups and large vendors alike these days. Generation and auditing are being rewritten side by side under the same rule of self hosting.

## Where Open Weights Rewrite the Rules of Auditing

In the past, scanning code for vulnerabilities usually meant calling a frontier model. That created two problems. Cost made continuous scanning hard to sustain, and the source code being scanned had to flow out to an external API. That is precisely why many Korean security teams gave up on continuous scanning under budget constraints. Antares addresses both bottlenecks at once. Running locally eliminates the export problem, and the small model size lowers the cost. This is also the context behind Cisco explicitly naming universities, the public sector, and under resourced small and mid sized security teams as target users.

The same logic applies directly to the generation side as well. The fact that Laguna S 2.1 pairs a permissive license with open weights widens the room for building self hosted coding assistants in finance and public sector environments that must satisfy network segregation rules or National Intelligence Service requirements. It is one more option for cutting reliance on closed APIs. Naturally, this freedom comes with homework attached. Because the domestic distribution and support ecosystem and its handling of Korean language code comments have not yet been verified, real world adoption will first need to clear benchmark reproduction and Korean environment fit testing.

Cisco, however, drew its own boundary. The model does not replace dependency analysis, secrets scanning, or dynamic testing, and it is meant to sit at the initial filtering stage. That is an honest limitation. And this limitation leads straight into today's real subject. Both the generation model and the audit model each handle only a slice of their own role, and stitching those two slices into one accountable flow is a separate problem entirely.

## The Gap Neither Generation Nor Audit Fills

Another story from the same day shows that gap precisely. Imweb, a Korean e-commerce platform, said it had deployed AI across development and operations broadly enough to shrink four years of work into three months. It even maintains the conservative practice of cross checking with OpenAI, Anthropic, and Google models simultaneously. But one sentence stands out. It performs automatic rollback immediately after detecting an infrastructure anomaly, without human approval. From a productivity standpoint that is something to boast about, but from a governance standpoint it is an alarm bell. An agent that can revert production without approval is, by the same token, an agent that can do other things without approval too.

A signal from the public sector points to the same conclusion from the opposite direction. In rolling out its generative AI service, the Korea Deposit Insurance Corporation set building a data catalog and an AI risk management framework as prerequisite tasks ahead of model selection. An institution handling the public's assets choosing to build a control framework before choosing a model reveals plainly that the real gatekeeper for AI adoption in regulated industries is not performance but explainability and audit trails. On one side autonomy is racing ahead, and on the other control is settling in first. Right at the point where these two demands meet, a standardized layer is currently missing.

The generation model makes code, and the audit model finds its flaws. But recording what level of autonomy an agent moves with, under whose policy's permission it executes, and what it touched and when, falls under neither model's mandate. This is not a problem of the model. It is a problem of the execution layer.

## Hardware Sovereignty Alone Doesn't Close It

It might seem like this gap could be closed simply through the scale of infrastructure, but today's news says otherwise. On the very same day, three business leaders, Lee Jae-yong, Chey Tae-won, and Lee Hae-jin, met Jensen Huang in Silicon Valley to restart an Nvidia centered AI supply chain alliance, a major move that could reshape the landscape of domestic sovereign AI infrastructure. Samsung SDS launched NPUaaS built on FuriosaAI's domestically made NPU, bringing a homegrown alternative to what had been a GPU only inference infrastructure into commercial deployment for the first time. For the public and financial sectors, this means one more sovereign option for reducing dependence on foreign GPUs, and it also raises the possibility that domestic NPUs could later appear as a requirement in government cloud procurement bids.

Sovereignty at the level of chips, data centers, and supply chains is filling in this quickly. But hardware sovereignty only answers half the question. A self hosted coding agent running on a domestic NPU does not automatically define what that agent is authorized to do or what it must leave behind as a record. Blocking data export and controlling execution are problems at different layers. The more sovereign infrastructure gets completed, the more clearly it exposes the absence of a software layer that defines the autonomy and auditing of the agents running on top of it.

## The Answer Lives in the Execution Layer

The whole picture, generation, audit, and the gap between them, looks like this.

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
<div class="d3-arch" data-arch-root id="runtimeaccountabilitygap-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 587, "height": 788, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 352, "w": 531, "h": 404, "label": "ThakiCloud Paxis · Execution Layer", "lx": 36, "ly": 370}], "nodes": [{"id": "G1", "x": 302, "y": 32, "w": 184, "h": 62, "title": ["Agent that writes code", "Laguna S 2.1"]}, {"id": "A1", "x": 105, "y": 24, "w": 142, "h": 78, "title": ["Agent that finds", "vulnerabilities", "Antares"]}, {"id": "GAP", "x": 183, "y": 180, "w": 205, "h": 94, "title": ["The unanswered question", "on whose resources", "with what authority", "logging what, does it run"]}, {"id": "P1", "x": 183, "y": 391, "w": 205, "h": 62, "title": ["Policy gate", "L0-L3 autonomy governance"]}, {"id": "P2", "x": 306, "y": 539, "w": 212, "h": 46, "title": "Isolated sandbox execution"}, {"id": "P3", "x": 352, "y": 671, "w": 120, "h": 46, "title": "Audit logs"}, {"id": "P4", "x": 67, "y": 531, "w": 184, "h": 62, "title": ["CostRouter · Sovereign", "Kubernetes"]}], "edges": [{"src": "G1", "dst": "GAP", "kind": "data", "curve": [[394, 94], [394, 141], [394, 141], [345, 180]]}, {"src": "A1", "dst": "GAP", "kind": "data", "curve": [[176, 102], [176, 141], [176, 141], [226, 180]]}, {"src": "GAP", "dst": "P1", "kind": "data", "line": [285, 274, 285, 391]}, {"src": "P1", "dst": "P2", "kind": "data", "curve": [[341, 453], [412, 492], [412, 492], [412, 539]]}, {"src": "P2", "dst": "P3", "kind": "data", "line": [412, 585, 412, 671]}, {"src": "P1", "dst": "P4", "kind": "data", "curve": [[229, 453], [159, 492], [159, 492], [159, 531]]}]});
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
      const container = document.getElementById('runtimeaccountabilitygap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'runtimeaccountabilitygap-1';
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

ThakiCloud's Paxis is built to handle exactly this missing layer. Paxis is a cloud for agents, a full fledged product that treats Skills, Tools, Policies, and Audit Logs as first class resources. Whether you attach a coding agent like Laguna S 2.1 to the backend or put an audit model like Antares in front of a scan, the agent still has to pass through a policy gate, run inside an isolated sandbox, and leave every action in an audit log. If the unapproved automatic rollback in the Imweb case read as unsettling, Paxis's autonomy governance spanning L0 through L3 is the counterweight to that unease. You can declare, as policy rather than as code, the boundary where some tasks are left fully autonomous and others require mandatory human approval.

The sovereignty requirement meets Paxis at the same layer. Just as Antares only makes sense if it runs locally without exporting source code, Paxis operates on sovereign, on premises Kubernetes and includes a CostRouter that picks the right model for each task. Narrowing down suspect files with a low cost local model and calling in a larger model only when needed is precisely Cisco's own recommendation, to position Antares as an early filter, implemented at the infrastructure level. Adding new models and tools through MCP connectors and a skills marketplace does not change the rules of execution and record keeping. The data governance and risk management framework that the Korea Deposit Insurance Corporation wanted to build ahead of choosing a model is likewise absorbed into the policy and audit layer the platform provides by default, rather than being rebuilt from scratch for every individual project.

A fair objection could be raised here. Isn't this just piling on yet another layer of control, tying back up the speed and autonomy that open weights had hard won, under the name of policy and audit? If Imweb finished four years of work in three months precisely because it rolled back instantly without human approval, then that very speed could be the source of its competitive edge. That is a valid point. But the purpose of autonomy governance is not to eliminate autonomy, it is to draw an explicit boundary around how far that autonomy extends. Declaring in advance which tasks may roll back without approval and which tasks must go through a human actually lets teams delegate more boldly within the safe zone. When the boundary is blurry, a team suspects every piece of automation, but when the boundary is fixed as policy, the team runs freely inside it. Control and speed are not opposites, they grow together once the boundary is clear. The Korea Deposit Insurance Corporation building its control framework before its model was likewise not a choice to slow adoption down, but a choice to make adoption sustainable.

The two releases from July 22 announce that agents have begun to acquire the ability to write code and the ability to watch over it at the same time. That is welcome progress. But as capability grows, the gap in accountability grows right along with it. The more common agents that build code and agents that audit code become, the scarcer what actually becomes is the place where those agents run safely and leave a complete record. Once you have both the sword and the shield, one question remains. Whose rules do the two of them ultimately fight under. Choosing a model keeps getting easier, but taking responsibility for what that model produces remains just as hard. What the sword and shield hanging side by side today tell us is that the next stage for competition will not be bigger models, but the execution layer where those models live and move safely.

## References

This article synthesizes the following news coverage:

- Global Economy, [엔비디아, 차세대 AI플랫폼 '베라루빈' 본격 공급 통해 "선두 수성"](https://www.getnews.co.kr/news/articleView.html?idxno=875704)
- Money Today, [LGU+·LS일렉트릭, AI 데이터센터 800V DC 공동 개발 나선다](https://www.mt.co.kr/tech/2026/07/22/2026072207035073681)
- Global Economic, [HPE, 슈퍼컴퓨팅 개발환경 통합…소버린 AI 인프라 간소화](https://www.g-enews.com/view.php?ud=202607212059199803112616b072_1)
- Newsworks, [[#클라우드 월드] 삼성SDS-퓨리오사AI 'NPUaaS' 출시·LG CNS 'AI 캠퍼스'...](https://www.newsworks.co.kr/news/articleView.html?idxno=847787)
- ZDNet Korea, ["SKT, AI팩토리에 가장 적극적인 통신사...풀스택AI·전국망 경쟁력"](https://zdnet.co.kr/view/?no=20260721191819)
- Yakup News, [BMS‧엔비디아, 생명공학 최강 AI 팩토리 구축](https://www.yakup.com/news/index.html?mode=view&cat=16&nid=330043)
- Global Economic, [미국 데이터센터 전력 수요 급증… 호남 반도체 허브, 전력망·용수가 ...](https://www.g-enews.com/view.php?ud=202607220659395424fbbec65dfb_1)
- Digital Today, [풀사이드, 코딩 에이전트용 오픈웨이트 모델 '라구나 S 2.1' 공개](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685807)
- Etoday, [키미 쇼크에 ‘AI 2강’ 험로…'특화 AI' 키우고, 경량화 모델로 차별화...](https://www.etoday.co.kr/news/view/2605803)
- Digital Today, [포티투마루, 예금보험공사 데이터 관리체계 고도화·생성형 AI 서비스 구...](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685817)
- News2Day, [밖에선 AI 인재 찾고 안에선 업무 혁신…NHN의 AX '승부수'](https://www.news2day.co.kr/article/20260721500191)
- Byline Network, [“4년 걸린 일을 3개월에”…아임웹이 안팎으로 AI 쓰는 법](https://byline.network/?p=9004111222612588)
- IT Chosun, [내년 지원 불투명한데…정부 '모두의 AI' 출시 서두르나](https://it.chosun.com/news/articleView.html?idxno=2023092166202)
- EBN, [이재용·최태원·이해진, 美서 젠슨 황 만난다…AI 공급망 동맹 재가동](https://www.ebn.co.kr/news/articleView.html?idxno=1717215)
- Digital Today, [시스코, 코드 취약점 탐지 특화 오픈웨이트 소형 모델 '안타레스' 공개](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685800)
- News Journalism, [AI가 바꾼 보안 공식…에스원 '현장 데이터'로 승부](https://www.ngetnews.com/news/articleView.html?idxno=551683)
