---
title: "The Question Behind a 25 Billion Won Bill: Why AI Agent Costs Have Become Invisible"
excerpt: "From a 25 billion won bill sent to a user in Korea to allegations of overbilling at 60 companies, the past month of AI cost news points to a single blind spot. In the age of agents, where a single request can trigger hundreds of model calls, the bill no longer explains what you actually paid for. Here is how we think that observability gap should be closed."
seo_title: "AI Agent Cost Observability and FinOps: Lessons from a 25 Billion Won Billing Incident"
seo_description: "In July 2026, Anthropic's 25 billion won billing error, allegations that 60 companies were overcharged $1.7 million, retry storms, and shadow IT. We analyze the structural reasons why agent workloads make costs unobservable, and lay out ThakiCloud's strategy of self-hosting plus agent cost observability and governance to address it."
date: 2026-07-20
tags:
  - LLMOps
  - FinOps
  - AgentCost
  - CostObservability
  - ModelRouting
  - self-hosting
  - Paxis
  - AIInfrastructure
author_profile: true
toc: true
toc_label: Anatomy of an Invisible Bill
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/agent-cost-observability-billing-crisis/"
published: false
---

This piece is written for platform and infrastructure engineers rolling out Claude Code or AI agents across an organization, and for finance and procurement owners who have to explain next month's AI bill. The short version: the flood of AI cost news over the past month is not really a story about "AI being expensive." The real problem is that the bill doesn't explain what it's actually for. In an agent architecture, a single user request can fan out into dozens or hundreds of model calls, tool executions, and automatic retries on failure, and the final dollar amount alone gives you no way to tell which loop leaked the money. We think this observability gap is the real source of the pain the market is feeling right now.

## Overview

If you had to sum up the news from late June through July 2026 in one line, it would be this: using frontier models indiscriminately for every task is unsustainably expensive, and it's hard to even trace where that cost is coming from. The clearest illustration was dramatic. A user in Korea first saw a charge attempt of roughly 2.5 billion won, then one for roughly 25 billion won. No money actually left the user's account, since the charge exceeded the card's limit, but the fact that an abnormal figure was pushed all the way to the card authorization stage, not just displayed as a UI glitch, is what gives the incident its weight.

Around the same time, news broke at other levels of the stack. An AI cost auditing firm reviewed the bills of 60 companies and alleged significant overcharging, several large enterprises began splitting frontier-model usage across cheaper models depending on the task, and reports emerged that companies in the US and Europe were migrating to Chinese open-weight models to cut costs. Interestingly, model vendors themselves began responding in a way that essentially conceded the point, that running the top-tier model on everything, all the time, isn't sustainable. Stories from several different directions were converging on the same spot.

## What Happened Over the Past Month

The first issue to surface was the reliability of the billing system itself. According to ZDNet Korea, a charge to a Korean university student started at roughly $1.66 million and then jumped tenfold to roughly $16.62 million. Anthropic later explained that the auto-recharge amount had been set to an abnormally high figure by mistake, but the user maintained that he had never configured auto-recharge in the first place, so why that setting existed remains unexplained. The detail that the user sent more than fifteen emails to multiple departments and only received an automated reply four days later says more about the gap in the response system than about the technical error itself.

The second issue was the observability of agent costs. According to AI Times and The Information, cost-auditing startup Vaudit reviewed roughly $34 million in bills across 60 companies and claimed that about $1.7 million of it was overcharged. A large share of what it reviewed was Claude Code usage, and companies including Panasonic, HP, and Honda were named as clients. The patterns Vaudit pointed to included calls made on a cheap model but billed at a premium model's rate, charges for jobs that never actually completed, and repeated automatic retries after failures, what it called a retry storm. Two caveats are worth stating clearly here. First, Anthropic pushed back, saying it does not bill for incomplete requests or error responses and that it has seen no evidence of widespread overcharging. Second, Vaudit is a commercial auditing firm that takes a cut of any refunds it wins, so these figures are best read as one party's findings rather than an independent audit. In other words, this is currently a standoff between an auditor's allegations and a vendor's denial.

The third was how the market responded. The Information reported that companies had started splitting workloads by task, routing simple classification, summarization, and transformation jobs to cheaper models, complex coding and agentic work to frontier models, and repetitive high-volume jobs to open-weight or self-hosted models. The Financial Times reported that DoorDash, Siemens, and Airbnb had adopted DeepSeek or Moonshot-family models to cut costs. Business Insider reported that even Anthropic's own platform executives acknowledged that shadow IT, business units adopting AI tools on their own without coordination, had driven runaway AI spending at some companies, though their prescribed fix was task-level model selection and centralized cost governance rather than usage bans or blanket budget caps. Pricing policy itself kept shifting too. Whether the latest high-performance models were included in subscriptions, and when usage-based billing would kick in, was adjusted repeatedly, and promotional deadlines kept getting extended. One example: the free tier for Claude Fable 5 was reportedly extended through July 19. For procurement teams, the bigger headache wasn't performance, it was not being able to predict next month's bill.

## Why Agent Costs Go Unobserved

There's a single thread running through all three strands of news. In agent workloads, the distance between what the user sees and what the bill records has grown too large. A traditional API call was one request, one response, one line of cost. A coding agent or agent SDK, by contrast, expands a single instruction into planning, tool calls, file edits, verification, and automatic retries on failure. That expansion happens somewhere the user never sees, and the bill records only the sum of it, in one line.

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
<div class="d3-arch" data-arch-root id="servabilitybillingcrisis-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 564, "height": 914, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 183, "y": 24, "w": 128, "h": 46, "title": "1 user request"}, {"id": "P", "x": 351, "y": 148, "w": 128, "h": 46, "title": "Agent planning"}, {"id": "L", "x": 351, "y": 272, "w": 128, "h": 46, "title": "Execution loop"}, {"id": "T", "x": 313, "y": 396, "w": 205, "h": 62, "title": ["Tool calls · model calls", "tens to hundreds of times"]}, {"id": "R", "x": 346, "y": 536, "w": 138, "h": 52, "title": "Success?"}, {"id": "RS", "x": 348, "y": 688, "w": 135, "h": 62, "title": ["Automatic retry", "(retry storm)"]}, {"id": "ACC", "x": 116, "y": 680, "w": 177, "h": 78, "title": ["Tokens · cache · tool", "calls", "aggregated"]}, {"id": "INV", "x": 39, "y": 836, "w": 205, "h": 46, "title": "Bill: one final line item"}], "edges": [{"src": "U", "dst": "P", "kind": "data", "curve": [[309, 70], [415, 109], [415, 109], [415, 148]]}, {"src": "P", "dst": "L", "kind": "data", "line": [415, 194, 415, 272]}, {"src": "L", "dst": "T", "kind": "data", "line": [415, 318, 415, 396]}, {"src": "T", "dst": "R", "kind": "data", "line": [415, 458, 415, 536]}, {"src": "R", "dst": "RS", "kind": "data", "label": "\"Failure\"", "curve": [[447, 588], [503, 634], [503, 634], [447, 688]], "off": "50%"}, {"src": "RS", "dst": "T", "kind": "data", "curve": [[348, 694], [186, 634], [186, 497], [314, 458]]}, {"src": "R", "dst": "ACC", "kind": "data", "label": "\"Success\"", "curve": [[371, 588], [292, 634], [292, 634], [245, 680]], "off": "50%"}, {"src": "ACC", "dst": "INV", "kind": "data", "curve": [[204, 758], [204, 797], [204, 797], [165, 836]]}, {"src": "INV", "dst": "U", "kind": "event", "label": "observability gap", "curve": [[118, 836], [78, 562], [78, 295], [184, 70]], "off": "50%"}]});
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
      const container = document.getElementById('servabilitybillingcrisis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'servabilitybillingcrisis-1';
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

In this structure, most of the points where cost leaks out sit outside the user's field of view. A retry loop quietly runs and inflates the call count, an intermediary cloud provider sits between the actual model usage and the final billing record and creates drift between the two, and one misconfigured setting, like auto-recharge, can push an abnormal amount all the way to the card authorization stage. The three stories may look unrelated, but they're all different faces of the same observability gap. That's why setting a monthly cap per user isn't enough on its own. What's actually needed is an instrumentation layer that captures per-model cost, per-session tokens, cache tokens, tool call counts, failure and retry costs, and day-over-day anomaly rates centrally, at the moment each call happens. Without observability there's no control, and without control the bill will always be the document that surprises you after the fact.

## Implications for ThakiCloud's Products

This is a problem that two of ThakiCloud's products each target from a different angle. Because the infrastructure lens and the agent lens complement each other here, we apply both to this topic.

**The ai-platform lens: owning repetitive workloads is the answer.** The market has arrived at a clear conclusion. Running even trivial tasks on frontier models is unsustainably expensive, and self-hosting an open-weight model is the economical choice for repetitive, high-volume work. ThakiCloud's ai-platform is Kubernetes-based AI/ML infrastructure built for exactly that gap. It queues GPUs with Kueue to push utilization higher, serves open-weight models through vLLM, and separates usage and billing by department through multi-tenant isolation. Where usage-based API pricing produces unpredictable bills, self-hosting builds a structure on top of a fixed GPU cost where the unit price doesn't spike even as usage grows. Unlike external usage-based pricing that keeps shifting, on-premises and sovereign deployments turn cost predictability itself into an asset. And the fact that data never leaves the organization is an additional value for organizations facing heavy domestic regulatory and security requirements.

**The Paxis lens: making every agent action auditable.** The core of the observability gap was the agent loop, and that is precisely the territory Paxis addresses. Paxis is ThakiCloud's Agent-Native Cloud control plane, running on top of ai-platform, that treats Skills, Tools, Policies, and Audit Logs as first-class resources. Which skill an agent invoked, through which tool, how many times, and in which sandbox it ran, all of it is captured in an audit log. In this structure, a retry storm can't quietly inflate a bill: the retry loop shows up directly in the audit trail, and policy gates block calls that cross a threshold. A design that selects from more than 960 skills using BM25, runs them in isolated sandboxes, and routes every action through policy and audit is a structural answer to exactly the problem of not being able to tell, from the bill alone, which loop generated the cost. Low-cost serving through ai-platform makes agents economical, and action-level observability through Paxis makes that economics predictable. That's how the two lenses fit together.

## Limitations and Counterarguments

In the interest of balance, let's state the counterargument clearly. First, frontier models aren't automatically wasteful. According to the Wall Street Journal, companies like Shopify believe that for complex coding and multi-step agent work, a frontier model's higher price can be justified if it saves enough engineering time. Spotify and Twilio, by contrast, are weighing more carefully whether a marginal performance gain justifies the added cost. The takeaway isn't "abandon frontier models," it's "split the workload by task difficulty." Self-hosting isn't a universal answer either. Pushing tasks that require the highest level of reasoning down to open-weight models degrades quality, and it introduces a new operational burden of GPU operations, model updates, and security patching.

Second, the overbilling figures cited in this piece are not settled facts. Vaudit's claims come from a commercial auditing firm, and Anthropic has denied them, so the accurate reading right now is that the two sides' positions are in direct conflict. In the 25-billion-won billing incident too, no money actually changed hands, and no technical explanation for why the auto-recharge setting existed has been made public. The conclusion we draw from this news isn't aimed at any particular vendor. It's a principle: in the agent era, whichever vendor you use, cost observability and governance need to be secured on the user's side. Choosing a good model and governing that model are two separate problems, and the news of the past month simply exposed the fact that the latter has been an empty seat all along.

## Sources

- [ZDNet Korea, "Korean User Hit With 25 Billion Won Payment Request, Anthropic Billing Error Controversy" (2026-07-09)](https://zdnet.co.kr/view/?no=20260709165452)
- [ZDNet Korea, "Anthropic's 25 Billion Won Charge Turns Out to Be an Auto-Recharge Configuration Error" (2026-07-16)](https://zdnet.co.kr/view/?no=20260716093004)
- [AI Times, "Anthropic Faces 'AI Overbilling' Controversy, Charged for Failed Jobs Too" (2026-06)](https://www.aitimes.com/news/articleView.html?idxno=212155)
- [The Information, report on enterprises adopting AI cost controls and model diversification (2026-06-23)](https://www.theinformation.com/titv/fedld)
- [Financial Times, "Companies turn to Chinese AI models to cut costs" (2026-07)](https://www.ft.com/content/9c8ff45b-7c20-4c2e-93c9-c52339ffdcee)
- [Business Insider, "Anthropic Official Warns Against 'Wrong' AI Cost Response" (2026-07-15)](https://www.businessinsider.com/anthropic-ai-costs-responses-routers-2026-7)
- [The Wall Street Journal, "Meet the Companies Shelling Out for Top AI Models" (2026-07)](https://www.wsj.com/cio-journal/meet-the-companies-shelling-out-for-top-ai-models-e1fe3375)
