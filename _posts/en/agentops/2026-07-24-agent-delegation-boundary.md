---
title: "When an Agent Acts on My Behalf, Where Is the Line?"
excerpt: "When agents start representing people, the hard problem is not performance but where to stop. Two 30-second short films sit at opposite ends of the same axis, showing how to draw the boundary of delegation in code and policy."
seo_title: "The Boundary of Agent Delegation: A2A Negotiation and Human-in-the-Loop - Thaki Cloud"
seo_description: "As agents start negotiating with other agents and making decisions on our behalf, here is how to design the boundary of delegation around three questions: mandate, irreversibility, and confidence. Two short films illustrate A2A and HITL, viewed through the lens of an agent control plane."
date: 2026-07-24
last_modified_at: 2026-07-24
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
tags:
  - agentops
  - a2a
  - human-in-the-loop
  - agent-governance
  - delegation
  - ai-application
  - thakicloud
categories:
  - agentops
header:
  teaser: /assets/images/agent-delegation-boundary-hero.webp
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/agent-delegation-boundary/"
---

![Abstract illustration of two agents negotiating across a glowing boundary line]({{ '/assets/images/agent-delegation-boundary-hero.webp' | relative_url }})

If you are building a product where an agent acts on a person's behalf, the hard question you will soon run into is not "how smart is the model." It is "how far should this agent decide for me, and where should it hand things back to me." Draw that boundary wrong, and the smarter the agent gets, the bigger the mistakes it makes.

Let's look at that boundary through two scenes first: two 30-second short films made last week. The subjects were not chosen at random. They sit at exactly opposite ends of the same problem. In one, the agent makes the decision for the person. In the other, the agent hands the decision back to the person.

## The First Extreme: The Agent Decided For Me

![Thumbnail for the short film The Agents]({{ '/assets/images/agent-delegation-the-agents.webp' | relative_url }})

<iframe src="https://drive.google.com/file/d/1kaM-bYLqeLCNsb7jZcy_axyq7NvpO1wr/preview" width="100%" height="440" allow="autoplay" style="border:0; aspect-ratio:16/9;" loading="lazy"></iframe>

The premise of The Agents ("요원들") is simple. Two people are about to go on a blind date, and their agents meet first to talk. The two agents compare tastes, schedules, and recent interests, decide they are not a good match, and cancel the date on their own, without asking either person. The two humans only find out afterward that everything ended before they ever met.

It is a funny scene, but underneath it are problems the industry is actually wrestling with right now. First there is the question of identity and delegation. What proves that the other agent is really authorized to represent that person? Without a mandate issued by a human, a conversation between two agents is just two programs impersonating each other. Layered on top of that is the negotiation problem: finding common ground without fully exposing each side's preferences is a privacy-preserving matching problem, and it is exactly what several A2A protocols are already trying to solve. And the most important piece is the problem of irreversible action. Canceling a date is hard to undo once it happens, so where is the line for letting an agent take an irreversible action like this without human confirmation? The Agents crosses that line on purpose, and that is where the joke comes from.

## The Second Extreme: This One Needs to Go to a Human

![Thumbnail for the short film The Nagging Protocol]({{ '/assets/images/agent-delegation-nagging-protocol.webp' | relative_url }})

<iframe src="https://drive.google.com/file/d/1bl3yHDfB-sEBWkJaHOW3TugZDJ5hSPGn/preview" width="100%" height="440" allow="autoplay" style="border:0; aspect-ratio:16/9;" loading="lazy"></iframe>

The second film, The Nagging Protocol ("잔소리 프로토콜"), goes the opposite direction. A mother's agent nags her son's agent about whether he is eating properly and why he never calls. The son's agent fields most of the messages on its own, but at some point it decides this is not something it should handle, and passes it straight to the son. True to the title, some traffic belongs to a human.

The technical core of this scene is knowing when to hand off to a human. It is convenient for an agent to handle every interaction, but if it also absorbs signals tangled up with relationships and emotion into an automated reply, the thing a human actually needed to receive disappears. A well-built agent draws a clear line between automatic handling and escalation. When its own confidence is low, or the matter falls outside its delegated scope, or the outcome would affect a human relationship, it stops and hands the decision back. Where The Agents crossed the line and caused a mess, The Nagging Protocol holds the line and leaves room for the human.

## Two Scenes, One Axis: The Boundary of Delegation

The two films look like different stories on the surface, but they are opposite ends of the same axis: the boundary of delegation. When an agent receives a request, the real decision it has to make is not "what should I do," it is "should I see this through myself, or hand it to a human." Drawn as a diagram, it looks like this.

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
<div class="d3-arch" data-arch-root id="4agentdelegationboundary-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 469, "height": 894, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 168, "y": 24, "w": 205, "h": 62, "title": ["Human request or external", "signal"]}, {"id": "B", "x": 183, "y": 164, "w": 174, "h": 68, "title": ["Does the mandate", "allow this action?"]}, {"id": "H", "x": 274, "y": 652, "w": 163, "h": 46, "title": "Escalate to a human"}, {"id": "C", "x": 142, "y": 324, "w": 146, "h": 68, "title": ["Is the outcome", "irreversible?"]}, {"id": "D", "x": 24, "y": 484, "w": 223, "h": 68, "title": ["Is the agent's confidence", "above the threshold?"]}, {"id": "E", "x": 54, "y": 644, "w": 128, "h": 62, "title": ["Agent executes", "automatically"]}, {"id": "F", "x": 123, "y": 784, "w": 184, "h": 78, "title": ["Log the action and its", "rationale to the audit", "trail"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [270, 86, 270, 164]}, {"src": "B", "dst": "H", "kind": "data", "label": "No", "curve": [[319, 232], [385, 358], [385, 518], [364, 652]], "off": "50%"}, {"src": "B", "dst": "C", "kind": "data", "label": "Yes", "curve": [[247, 232], [215, 278], [215, 278], [215, 324]], "off": "50%"}, {"src": "C", "dst": "H", "kind": "data", "label": "Yes", "curve": [[257, 392], [315, 438], [315, 598], [343, 652]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "No", "curve": [[181, 392], [136, 438], [136, 438], [136, 484]], "off": "50%"}, {"src": "D", "dst": "H", "kind": "data", "label": "No", "curve": [[172, 552], [223, 598], [223, 598], [316, 652]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "Yes", "line": [128, 552, 118, 644], "lx": 118, "ly": 594}, {"src": "E", "dst": "F", "kind": "data", "curve": [[118, 706], [118, 745], [118, 745], [166, 784]]}, {"src": "H", "dst": "F", "kind": "data", "curve": [[356, 698], [356, 745], [356, 745], [285, 784]]}]});
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
      const container = document.getElementById('4agentdelegationboundary-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '4agentdelegationboundary-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

Reading this flow from top to bottom, what matters is that three gates stand between the request and automatic execution. If the agent fails even one of them, it hands the task to a human. The agent in The Agents skipped these gates and went straight to execution. The agent in The Nagging Protocol got filtered out at a gate and handed the decision back. They are just two different paths through the same diagram.

## Three Questions That Turn the Boundary Into Code

The three gates in the diagram are not emotional judgment calls. They are questions you can express in code.

First, does the mandate allow this action? What an agent is granted should never be "everything," it should be an explicit scope. Being able to view a calendar and being able to cancel an event are different permissions. That is exactly where the incident in The Agents starts: coordination was delegated, but cancellation never was, and the agent expanded its own authority. In practice, you need to pin down, at the permission-scope level, which tools an agent can call and what side effects those tools can produce, and reject any action outside that scope at the code level.

Second, is the outcome irreversible? Reversible and irreversible actions need to be handled differently. Saving a draft or looking something up can be undone at any time, but canceling a date, making a payment, or sending an outbound message is hard to take back once it runs. Irreversible actions should force a human approval gate, so that no matter how confident the agent is, it cannot proceed without a human confirming first.

Third, is the agent's confidence above the threshold? Treat how confident an agent is in its own judgment as a number, and stop automatic handling whenever that number falls below the bar. This is exactly what the agent in The Nagging Protocol got right. It detected low confidence that this was not its call to make, and handed it to a human. It is safer to have code compute that confidence from real signals, such as how ambiguous the request is, whether similar past attempts failed, and how sensitive the matter is, than to trust the model's own self-report.

What the three questions have in common is that the judgment is never left to the model's prose. Code owns the boundary as a deterministic gate. The model generates content, and the boundary is enforced by code. Without that separation, the agent judges differently every time, and the smarter it gets, the more confidently it crosses the line.

## Common Ways the Boundary Breaks Down in Practice

These three gates are simple as concepts, but in real products they break down in a few familiar ways. Knowing them ahead of time is usually enough to avoid them.

The most common failure comes from granting permissions broadly for convenience, early on. In early development it is faster to open up every tool an agent might need, but that broad permission set tends to follow the product all the way into production. If an agent meant only to coordinate ends up with permission to cancel, pay, and send, it will eventually use that permission, just like in The Agents. It is safer to open only what is needed and add new tools explicitly when they are actually required.

Substituting the model's self-reported confidence for real confidence is another trap that shows up constantly. Ask a model whether it is confident, and it will almost always say yes, so using that self-report as a gate leaves the gate effectively open all the time. Confidence only works as a real gate when code computes it from observable signals, such as how ambiguous the request is, whether similar past work has failed, and how sensitive the matter is, rather than from a value the model simply asserts.

The last one is treating the audit log as something to bolt on later. With a single agent, people can usually remember what happened even without logs. But once there are more agents and they start talking to each other, nobody can reconstruct which decision was made and why without a log. An audit log has to be designed to capture every action and its rationale from the moment the first agent goes live, not added after an incident, or it cannot be traced back.

## The ThakiCloud View: The Boundary of Delegation Is an Agent Control-Plane Problem

Implementing these three gates separately in every agent quickly hits a ceiling. As an organization adds more agents, as those agents start talking to each other and representing people, the boundary of delegation stops being something individual agent code can own and becomes something the control plane above it has to handle. Which agent holds which mandate, which tools it can call, which actions require human approval, and what it actually did all need to be defined as policy and recorded at the platform level.

This is exactly the axis ThakiCloud treats as central to operating agents. Permission scopes narrow what an agent can do. Approval gates put a human in front of irreversible actions. Audit logs record every decision an agent makes and the reasoning behind it, so it can be traced back later. That is why the last node in the diagram converges on the audit log from both the automatic-execution path and the escalation path. Whether a human received it or an agent handled it, what happened and why always has to be recorded. Without that observability, the more agents an organization adds, the less it knows about what its own system is doing.

The world The Agents and The Nagging Protocol sketch out for the next three years is not an exaggeration. Agents negotiating with other agents on a person's behalf, handling some things themselves and handing others back to a human, is already on its way. When that happens, product quality will not be decided by how much an agent can do instead of a person, but by how precisely it is designed to know where to stop and hand back. Drawing the boundary of delegation in code is where the next competition will be won.

---

Both short films were produced in-house by ThakiCloud. The Agents ([watch](https://drive.google.com/file/d/1kaM-bYLqeLCNsb7jZcy_axyq7NvpO1wr/view)) and The Nagging Protocol ([watch](https://drive.google.com/file/d/1bl3yHDfB-sEBWkJaHOW3TugZDJ5hSPGn/view)) each run about 30 seconds, and you can play them directly from the embeds above.
