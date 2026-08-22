---
title: "The Era of AI Completing 32-Step Intrusions Start to Finish: GPT-5.6 Sol and Cybersecurity"
excerpt: "OpenAI announced that GPT-5.6 Sol set a new record on a cyber range. As frontier models begin autonomously executing real attack chains, the decisive factor shifts from model capability to where and under what controls that model runs."
seo_title: "GPT-5.6 Sol Cybersecurity: Analyzing The Last Ones 32-Step Attack and the Defense Stack"
seo_description: "OpenAI's GPT-5.6 Sol scored 73.5% on ExploitBench2, emerging as the strongest cybersecurity model to date. We analyze AISI's 32-step cyber range The Last Ones, the layered safety stack, and why on-premises sovereign AI and agentic policy gates are now central to defense."
date: 2026-07-19
last_modified_at: 2026-07-19
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - cybersecurity
  - frontier-model
  - agentops
  - paxis
  - sovereign-ai
  - thakicloud
categories:
  - news
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/news/gpt-5-6-sol-cybersecurity/"
published: false
---

A single sentence lingered on my timeline this morning. OpenAI, introducing its new flagship model GPT-5.6 Sol, stated that it had set a new high score on "The Last Ones," a cyber range used for security evaluation. What matters here isn't the score itself but the implication of that sentence. It signals that AI is moving beyond helping humans find vulnerabilities and toward completing multi-step attack scenarios entirely on its own, without a human in the loop.

The reason this news can't be a non-issue for an infrastructure company like ThakiCloud is clear. As frontier models' attack capabilities rise, the center of gravity for defense shifts from "which model is smarter" to "where that model runs, under whose control, and what audit trail it leaves behind." Models will only keep getting stronger regardless. If that's the case, the decisive battleground becomes the isolation of the execution environment, policy gates, and post-hoc traceability. Today's post first lays out what GPT-5.6 Sol has actually demonstrated, sticking strictly to confirmed facts, and then turns to why this capability actually increases demand for on-premises sovereign AI and an agentic control plane.

## What GPT-5.6 Sol Is, and Why Cybersecurity Is the Focus

GPT-5.6 is a model family OpenAI released on July 9, 2026. It comes in three tiers by capability: Luna, Terra, and Sol, with Sol as the most powerful flagship. OpenAI stated that it serves Sol on Cerebras infrastructure at up to 750 tokens per second, emphasizing that the leap applies not just to capability but to serving speed as well.

The most prominent axis of this announcement is cybersecurity. OpenAI describes Sol as its most capable cybersecurity model to date, explaining that it has shifted the performance-and-efficiency frontier for long-horizon security work, including vulnerability research and exploitation. The core claim is "go further with fewer tokens." A reduction in the reasoning tokens consumed to reach the same outcome also means the same budget can now automate more attack attempts. In the regime where capability gains translate directly into cost reductions, the barrier to entry drops for both defenders and attackers.

One thing deserves an honest caveat. The original tweet is OpenAI's own announcement, and the independent evaluation of the "The Last Ones" range discussed below, run by the UK AI Safety Institute (AISI), covered only up through GPT-5.5 as of publication. So Sol's "new record" claim is a figure OpenAI itself presented, and until third-party reproduction results are fully public, it's safer to read it as the claim of the party making the announcement. This piece takes care to distinguish verifiable numbers from the party asserting them.

## "The Last Ones": What a 32-Step Cyber Range Measures

"The Last Ones" is a simulated enterprise network intrusion scenario operated by AISI. It consists of 32 steps in total, and a skilled human expert is estimated to need roughly 20 hours to complete it start to finish. It isn't a simple problem set; it's structured so that passing requires stringing together the many capabilities a real breach demands into a single continuous chain. The agent has to autonomously seize systems, reverse-engineer protocols and cryptographic authentication, and manipulate controllers, all while judging its own next move at each step.

Very few models have completed this range from start to finish so far. Claude Mythos preview was the first to succeed, completing it three times out of ten attempts (3/10), and GPT-5.5 was the second to make it all the way through, at two out of ten (2/10). The success rate looks low relative to the number of attempts, but the fact that a 20-hour multi-stage attack was completed even once without human intervention is itself a signal that a threshold has been crossed. Related research (arXiv 2603.11214) reports that this capability scales log-linearly with inference-time compute, with no plateau observed yet. The finding that performance can rise by as much as 59% when the token budget is scaled from 10 million to 100 million carries an uncomfortable implication: the more money and time you're willing to burn, the higher the probability of completing an attack keeps climbing.

## What the Benchmarks Reveal About the Capability Leap

This capability leap also shows up in individual benchmarks. According to OpenAI, GPT-5.6 scored 73.5% on ExploitBench2, an exploitation-capability evaluation, sharply outpacing GPT-5.5's 47.9% at a comparable output token budget. That's a jump of more than 25 percentage points in a single generation. Still, there's nuance here too. OpenAI's own testing suggests that GPT-5.6 is more skilled at finding and fixing vulnerabilities than at reliably carrying out an actual attack from start to finish. In other words, it's fair to read this as the balance of capability still tilting toward defense for now.

This distinction matters for policy. The same model becomes a tool for mass vulnerability discovery and patching in a defender's hands, and an intrusion automation engine in an attacker's hands. Aardvark, an agentic security researcher that OpenAI separately unveiled, targets exactly this defensive use case. Aardvark was introduced as an autonomous agent that helps developers and security teams automatically find and fix vulnerabilities, and OpenAI made explicit that this capability should reach defenders first, above all else.

## Defense Over Offense: OpenAI's Layered Safety Stack

It's in this same context that OpenAI didn't open Sol to everyone from day one, instead releasing it in a limited way to a select set of trusted partners. Access is initially restricted to a curated group of customers, a decision OpenAI says came out of close coordination with the US government on a cybersecurity framework. It's a signal that the more a capability is judged to have crossed a critical threshold, the more conservatively deployment gets throttled.

Multiple layers of defense have also been added on the technical side. According to the announcement, Sol and Terra now carry activation classifiers focused on sensitive domains that monitor the model during generation and intervene mid-stream to stop it the moment it starts producing a dangerous response. On top of that sits a model-level restriction that blocks prohibited cyber assistance at the source, real-time output monitoring via a misuse classifier, and account-level behavioral analysis that catches malicious patterns. Output isn't delivered directly; it passes through review by a secondary reasoning system before it ever reaches the user. Below is a diagram summarizing this layered defense flow.

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
<div class="d3-arch" data-arch-root id="719gpt56solcybersecurity-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 500, "height": 1036, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 181, "y": 24, "w": 120, "h": 46, "title": "User request"}, {"id": "B", "x": 145, "y": 148, "w": 191, "h": 78, "title": ["Model-level restriction", "Block prohibited cyber", "assistance"]}, {"id": "C", "x": 135, "y": 304, "w": 212, "h": 78, "title": ["Activation classifier", "Monitor during generation,", "intervene mid-stream"]}, {"id": "D", "x": 166, "y": 460, "w": 149, "h": 78, "title": ["Real-time output", "monitoring", "Misuse classifier"]}, {"id": "E", "x": 135, "y": 616, "w": 212, "h": 78, "title": ["Secondary reasoning system", "review", "Pause before delivery"]}, {"id": "F", "x": 138, "y": 772, "w": 205, "h": 78, "title": ["Account-level behavioral", "analysis", "Detect malicious patterns"]}, {"id": "G", "x": 263, "y": 950, "w": 205, "h": 46, "title": "Deliver response or block"}, {"id": "H", "x": 24, "y": 942, "w": 184, "h": 62, "title": ["Review, block, account", "action"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [241, 70, 241, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [241, 226, 241, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [241, 382, 241, 460]}, {"src": "D", "dst": "E", "kind": "data", "line": [241, 538, 241, 616]}, {"src": "E", "dst": "F", "kind": "data", "line": [241, 694, 241, 772]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[298, 850], [366, 896], [366, 896], [366, 950]]}, {"src": "F", "dst": "H", "kind": "event", "label": "Anomalous pattern", "curve": [[184, 850], [116, 896], [116, 896], [116, 942]], "off": "50%"}]});
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
      const container = document.getElementById('719gpt56solcybersecurity-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '719gpt56solcybersecurity-1';
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

What stands out is that this structure isn't a single filter. The inside of the model (activation classifier), the output boundary (misuse classifier), and the account layer (behavioral analysis) all watch from different vantage points, layered on top of one another. It's defense in depth, designed so that if one layer misses something, the next layer catches it. And this exact idea transplants directly onto infrastructure providers.

## Implications for ThakiCloud's Products

The news that frontier models' attack capability keeps rising, paradoxically, makes the case for on-premises and sovereign AI. As autonomous attacks become a reality, enterprises and public institutions want to keep "who called this model, what did they ask it to do, and what output did it return" under their own control. ThakiCloud's **ai-platform** meets this need directly. On top of K8s- and Kueue-based GPU scheduling, it keeps models within the customer's own cluster, serves them with multi-tenant isolation, and supports on-premises and sovereign deployment so that data never crosses an external boundary. The more sensitive the security workload, the greater the value of self-hosting, keeping model weights and inference traffic locked inside your own infrastructure. Lower serving costs are also a practical precondition that lets defenders run bulk, repetitive work like vulnerability scanning within an affordable budget.

At the agentic layer, **Paxis**'s design turns out to look strikingly similar to the layered safety stack described above. Paxis is the Agent-Native Cloud control plane that runs on top of ai-platform, treating Skills, Tools, Policies, and Audit Logs as first-class resources. Skills that an agent executes run in an isolated sandbox that doesn't contaminate the host environment, every action passes through a policy gate before it's carried out, and the entire process is recorded in an audit log. Just as OpenAI layered monitoring across the inside of the model, its output boundary, and the account level, Paxis separates skill selection (BM25 harness), execution (sandbox isolation), control (policy gates), and traceability (audit logs) into distinct layers. This structure prevents an autonomous agent from applying the wrong tool to the wrong target, and even if an incident does occur, it lets you trace back exactly what went wrong and where.

The two lenses complement each other. If ai-platform is the physical control that keeps the model inside your own boundary, Paxis is the logical control that binds the agent using that model to policy and logs. In an era where AI can autonomously execute a 32-step intrusion, the fundamentals of defense are no longer about picking the strongest model, but about running whatever model you use inside a controlled environment and keeping a record of its actions. That's why on-premises deployment and an agentic control plane matter more now than ever.

## Limitations and Counterarguments

In the interest of balance, let's look at the other side too. First, Sol's cybersecurity edge rests substantially on OpenAI's own announcements, and because access is restricted, independent reproduction and verification remain insufficient. Benchmark numbers are shaped by the measurement conditions of whoever is presenting them, so until third-party evaluations accumulate, it's safer to treat them only as directional signals.

Second, the observation that capability currently tilts toward defense is not grounds for reassurance. If log-linear scaling continues without a plateau, today's defense-favoring balance could flip at any time simply from an increase in compute. The statement "it's currently more skilled at defense than offense" is a snapshot of the present state, not a permanent safety guarantee.

Third, on-premises deployment, isolation, and policy gates aren't free. Operating your own infrastructure demands upfront investment, specialized personnel, and an ongoing patching burden. For smaller organizations, the convenience of managed cloud may still be the rational choice. The point isn't that on-premises is always the right answer, but that as workload sensitivity rises, the point at which the value of control and auditability outweighs the cost of convenience arrives sooner.

Finally, policy gates and audit logs are themselves imperfect. A defense stack becomes a target for bypass attempts, and jailbreak research against Sol is already underway. The meaning of defense in depth isn't a promise of never being breached, it's making sure that even if one layer is breached, the next layer catches it and the incident can be traced afterward. That modest goal is, in fact, the realistic defense design for this era.

## Sources

- [Original tweet (RT @OpenAI)](https://x.com/hjguyhan/status/2078708617822564773)
- [GPT-5.6: Frontier intelligence that scales with your ambition | OpenAI](https://openai.com/index/gpt-5-6/)
- [Previewing GPT-5.6 Sol: a next-generation model | OpenAI](https://openai.com/index/previewing-gpt-5-6-sol/)
- [GPT-5.6 Preview System Card | OpenAI Deployment Safety Hub](https://deploymentsafety.openai.com/gpt-5-6-preview)
- [Introducing Aardvark: OpenAI's agentic security researcher](https://openai.com/index/introducing-aardvark/)
- [Our evaluation of OpenAI's GPT-5.5 cyber capabilities | AISI](https://www.aisi.gov.uk/blog/our-evaluation-of-openais-gpt-5-5-cyber-capabilities)
- [OpenAI Previews GPT-5.6 Sol With Restricted Access and Stronger Cyber Safeguards | The Hacker News](https://thehackernews.com/2026/06/openai-limits-gpt-56-rollout-as-sol.html)
- [Measuring AI Agents' Progress on Multi-Step Cyber Attack Scenarios | arXiv 2603.11214](https://arxiv.org/html/2603.11214v2)
