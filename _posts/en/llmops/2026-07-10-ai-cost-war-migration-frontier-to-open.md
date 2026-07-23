---
title: "From the Intelligence War to the Value War: Enterprises Leaving Frontier APIs and the Economics of Migration"
excerpt: "Microsoft has started routing bulk AI requests from Excel and Outlook to its own models, Chinese open models now handle nearly half of some US enterprise AI usage, and over a trillion dollars in market capitalization evaporated in a single stretch of days. The assumption that enterprises will pay premium frontier prices forever is breaking down. This post reads the signals, lays out a migration playbook for moving bulk workloads to open models, and explains how ThakiCloud's ai-platform and Paxis fit together as the control plane that executes it."
tags:
  - cost-optimization
  - model-routing
  - open-weights
  - self-hosting
  - vllm
  - paxis
date: 2026-07-10
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/ai-cost-war-migration-frontier-to-open/"
categories:
  - llmops
---

![Abstract illustration depicting a migration flow from frontier APIs to open models]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-hero.png' | relative_url }})

Over the past few weeks, the conversation in the AI industry has shifted from "who is smarter" to "who is cheaper." The most telling scene came from Microsoft. The very company that put OpenAI on the trajectory it now rides has started routing the tens of thousands of weekly AI requests inside Excel and Outlook to its own models instead of OpenAI's and Anthropic's. Microsoft's AI chief Mustafa Suleyman did not hide the reasoning. "Anthropic is extremely expensive. Our goal is to reduce that cost and eventually eliminate it," he said.

This post is written for engineering leaders, AI teams, and the decision makers who own inference cost for their own services. It explains why the cost war unfolding right now is not transient noise but a structural shift, lays out a migration playbook for moving frontier API spend to open models and self-hosting, and finally explains where ThakiCloud sits as the control plane that actually runs that migration.

## What has changed

A single company's decision does not make a trend. But several signals pointing the same direction have stacked up within a few weeks.

First, Microsoft's detour was precise. The hardest, rarest tasks still go to frontier models, while only the tedious, high-volume work, things like email replies, thread summaries, and simple spreadsheet formulas, is being reclaimed for its own models. This matters because that tedious bulk work is exactly where the money actually flows ({% raw %}[SiliconANGLE report](https://siliconangle.com/2026/07/07/microsoft-reportedly-ditching-openais-anthropics-ai-models-favor-cut-costs/){% endraw %}).

Second, US companies are moving toward Chinese open models to escape pricing. According to CNBC, Chinese models handled more than 30 percent of US enterprise AI usage on one major routing platform, peaking at 46 percent, a sharp jump from an average of 11 percent a year earlier. Costs are 60 to 90 percent lower, and on some agentic benchmarks the gap to the top US models has narrowed to within a single point ({% raw %}[CNBC report](https://www.cnbc.com/2026/07/07/chinese-ai-models-costs-us-openai-anthropic.html){% endraw %}).

Third, a signal of oversupply has surfaced. Meta announced it is preparing a cloud business to sell "surplus" AI compute, effectively turning the admission that it built too much into a business model ({% raw %}[CNBC report](https://www.cnbc.com/2026/07/01/meta-stock-cloud-ai-compute.html){% endraw %}).

Fourth, the market reacted. In late June, more than a trillion dollars in market capitalization vanished from semiconductor and AI-related stocks within days, and Wall Street began asking whether this enormous spending could actually be recouped (roughly $1.3 trillion by Reuters' tally, unverified, for reference only).

What these signals share is not that frontier models got worse. If anything, their performance keeps improving. The problem is that even the biggest customers no longer accept the premise of using the best model for every task and paying the top price for it.

Pricing itself is also falling fast. OpenAI's recently released GPT-5.6 Sol prices at roughly $5 per million input tokens and $30 per million output tokens, a sharp drop in per-token cost from the previous generation ({% raw %}[CNBC report](https://www.cnbc.com/2026/07/08/openai-expanding-gpt-5point6-ai-model-release-ending-government-limits.html){% endraw %}). That means the frontier labs are now in a price war with each other too. The front line has shifted from an intelligence war to a value war.

## Why now

The cost war is breaking out now because of how workloads are distributed.

Break down what agents handle in a given day and the character splits clearly. On one side sits genuinely hard reasoning: ambiguous design decisions, subtle debugging, breaking down a problem nobody has seen before. On the other side sits standardized, high-volume work: classification, routing, summarization, spec checking, replies in a fixed format. By count, the latter overwhelmingly dominates.

The financial assumption of the frontier labs was simple: that enterprises worldwide would process billions of these small requests forever on expensive models. That endless river of tokens was the basis propping up the frontier companies' lofty valuations.

But the quality of standardized work is governed more by guardrails than by model intelligence. Output formats drift not because the model lacks capability, but because the format was requested in prose instead of being enforced. When length caps, allowed value sets, rendering specs, and pass criteria are enforced by code, that work comes out reliably even from far cheaper open models. The moment "good enough" becomes achievable for a fraction of the price, reclaiming that river of bulk work becomes the rational move. That is exactly the call Microsoft made.

## From frontier to open: the migration playbook

So how do you actually move this river. Switching models on impulse is risky. A reliable migration goes through five steps.

First, classify the workload. Split each request along two axes: difficulty and sensitivity. Keep hard or sensitive tasks on frontier, and mark only the standardized, high-volume work as a migration target.

Second, evaluate substitution candidates. For each task marked for migration, score open-model candidates against real data. The key here is a pass rate computed by code, not a human impression. Run actual outputs through the spec checks, and drop any candidate that falls short of the threshold.

Third, configure routing. Define, in one place, the rules for which model handles which task type. That single source of truth is what makes it easy to swap or roll back models later.

Fourth, self-host the open model. Deploy the selected open model on your own infrastructure using a serving engine like vLLM. This is the step where on-premises deployment, data sovereignty, and unit-cost advantages are actually realized.

Finally, verify and roll back. After migration, keep measuring quality, and if the pass rate slips, move that specific task back to frontier. A migration without a rollback path is not a migration, it is a gamble.

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
<div class="d3-arch" data-arch-root id="rmigrationfrontiertoopen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 613, "height": 820, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 183, "y": 24, "w": 149, "h": 46, "title": "Incoming workload"}, {"id": "B", "x": 149, "y": 148, "w": 216, "h": 68, "title": ["Classification gate", "difficulty · sensitivity"]}, {"id": "C", "x": 411, "y": 462, "w": 170, "h": 62, "title": ["Frontier API", "Claude · GPT-5.6 Sol"]}, {"id": "D", "x": 151, "y": 308, "w": 212, "h": 62, "title": ["Open model candidates", "selected by eval pass rate"]}, {"id": "E", "x": 158, "y": 462, "w": 198, "h": 62, "title": ["Self-hosted serving", "vLLM · Metis · Kueue GPU"]}, {"id": "F", "x": 162, "y": 602, "w": 191, "h": 62, "title": ["Policy gate + audit log", "Paxis control plane"]}, {"id": "G", "x": 197, "y": 742, "w": 120, "h": 46, "title": "Result"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [257, 70, 257, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "Hard or sensitive", "curve": [[359, 216], [496, 262], [496, 416], [496, 462]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Standardized bulk work", "line": [257, 216, 257, 308], "lx": 257, "ly": 258}, {"src": "D", "dst": "E", "kind": "data", "line": [257, 370, 257, 462]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[496, 524], [496, 563], [496, 563], [353, 605]]}, {"src": "E", "dst": "F", "kind": "data", "line": [257, 524, 257, 602]}, {"src": "F", "dst": "G", "kind": "data", "line": [257, 664, 257, 742]}, {"src": "F", "dst": "B", "kind": "event", "label": "Quality degradation detected", "curve": [[194, 602], [114, 493], [114, 339], [196, 216]], "off": "50%"}]});
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
      const container = document.getElementById('rmigrationfrontiertoopen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rmigrationfrontiertoopen-1';
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

On X, one developer shared that this approach took their monthly API spend from $60,000 down to $12,000 on open models, roughly an 80 percent cut. The original post was access-restricted and could not be independently verified, so the figure should be treated as unverified, for reference only. That said, the scale of the savings is consistent with the verified data: the 60 to 90 percent lower per-token cost of Chinese open models, and the price cuts happening between the frontier labs themselves, point in the same direction.

## Implications for ThakiCloud's products

The playbook is conceptually clear, but running it in practice requires two things: infrastructure to serve open models cheaply, and a control plane to choose the model per task while guaranteeing safety through policy and audit. ThakiCloud provides both pillars together through two products.

### ai-platform: low-cost serving infrastructure

ai-platform is Kubernetes-based AI/ML serving infrastructure. It schedules GPUs with Kueue, serves open models with vLLM, and supports multi-tenant isolation and on-premises deployment. Step four of the migration playbook, deploying a selected open model on your own infrastructure to bring down unit cost, happens at this layer. For customers who cannot send data outside their own boundary, such as government agencies or regulated industries, sovereign deployment is decisive, a requirement that frontier APIs cannot satisfy to begin with.

### Paxis: the Agent-Native Cloud that executes the migration

Paxis is the agent-native control plane running on top of ai-platform. Just as a conventional cloud treats virtual machines and databases as first-class resources, Paxis treats skills, tools, policies, and audit logs as first-class resources. From the migration playbook's perspective, the most important part is model routing. Paxis uses `models.yaml` as a single source of truth to cross-route Claude, OpenAI, Ollama, Kimi, MiniMax, and ai-platform's own vLLM serving (Metis) from one place. This maps directly onto steps three and five of the playbook described above: assigning a model per task type, and rolling a task back to frontier the moment quality slips is a judgment call made at this layer.

Beyond that, Paxis provides a skill harness that selects among more than 960 skills using BM25, isolated sandbox execution, a wiki-based knowledge engine, DAG multi-agent orchestration, and MCP connectors with automatic OAuth reconnection. Every agent action passes through a policy gate and an audit log. In other words, you can switch to cheaper models while still tracking exactly what was processed by which model.

The relationship between the two products can be summarized in one sentence. Low-cost serving (ai-platform) is what makes an agent's economics (Paxis) work. Without infrastructure that can run open models cheaply, routing rules remain a plan on paper; without routing and policy, cheap serving becomes an uncontrollable risk. Turning migration into a real business requires both pillars at once. Note that Paxis is still at the proof-of-concept stage, and its interfaces and schemas may change quickly.

## Limitations and counterarguments

Ending this story on pure optimism would not be honest. The counterarguments are clear.

First, quality gaps still exist. Where open models have closed the distance is standardized tasks and some agentic benchmarks. On breaking down never-seen problems or subtle reasoning over long context, frontier still leads. Trying to move everything to open models means paying back, in failure costs on hard tasks, everything you saved on bulk work. The core of migration is not wholesale replacement but precise classification.

Second, self-hosting is not free. API calls hand the operational burden to the lab, while self-hosting means taking on GPU procurement, serving optimization, and incident response yourself. Once you factor in upfront capital expenditure and operations headcount, API calls can actually be cheaper at small traffic volumes. The break-even point depends on traffic scale and utilization.

Third, widely circulated benchmark numbers should not be taken at face value. While preparing this post, certain benchmark tables and figures could not be traced to a verifiable original source and were left out of the body. Model comparisons should be judged only by results measured directly against your own workload. Someone else's benchmark is a starting point, nothing more.

Fourth, routing itself adds complexity. A system that moves between multiple models is harder to debug and observe than a single-model system. That is exactly why policy gates and audit logs are not optional, they are required.

Even so, the direction is clear. Now that even Microsoft refuses to pay frontier prices for every task, the real question is who will keep paying that price. The ability to precisely migrate bulk workloads to open models, and to control that migration safely, will be a core competency of AI operations for years to come. ThakiCloud is positioned to provide that migration on both fronts, infrastructure and control plane, together.

## Sources

- {% raw %}[Microsoft reportedly ditching OpenAI's, Anthropic's AI models to cut costs (SiliconANGLE)](https://siliconangle.com/2026/07/07/microsoft-reportedly-ditching-openais-anthropics-ai-models-favor-cut-costs/){% endraw %}
- {% raw %}[Chinese AI models gain ground with US companies on cost (CNBC)](https://www.cnbc.com/2026/07/07/chinese-ai-models-costs-us-openai-anthropic.html){% endraw %}
- {% raw %}[Meta plans cloud business to sell AI compute (CNBC)](https://www.cnbc.com/2026/07/01/meta-stock-cloud-ai-compute.html){% endraw %}
- {% raw %}[OpenAI expands GPT-5.6 Sol access and pricing (CNBC)](https://www.cnbc.com/2026/07/08/openai-expanding-gpt-5point6-ai-model-release-ending-government-limits.html){% endraw %}
