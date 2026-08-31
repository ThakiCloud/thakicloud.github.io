---
title: "What Is Agent-Native Cloud: Skills and Policies as First-Class Resources"
excerpt: "Why VM-centric cloud is ill-suited for autonomous AI agent operations, and the design principles of agent-native infrastructure that treats Skills, Tools, Policies, and Audit Logs as first-class resources."
seo_title: "Agent-Native Cloud Design Principles - Thaki Cloud"
seo_description: "A paradigm shift in cloud infrastructure for autonomous AI agent operations. Introducing agent-native architecture and ThakiCloud Paxis, where Skills, Tools, Policies, and Audit Logs -- not VMs -- are first-class resources."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: en
tags:
  - agent-native
  - cloud-infrastructure
  - praxis
  - ai-agents
  - platform
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/agent-native-cloud-praxis/"
reading_time: true
permalink: /en/dev/agent-native-cloud-praxis/
categories:
  - dev
  - product
---

![Agent-Native Cloud Paxis Overview]({{ '/assets/images/agent-native-cloud-praxis-hero.webp' | relative_url }})

## Overview

Cloud computing has, until now, focused on a single question: "How do we abstract the environment in which applications run?" The progression from physical servers to virtual machines (VMs), from VMs to containers, and from containers to serverless has been a process of ever-finer refinement of that answer.

Yet we now face a different kind of question: "How do we abstract the environment in which AI agents -- agents that reason and act autonomously -- run?" This question demands something that existing cloud abstraction frameworks were never designed to provide.

This article examines that gap and explores the principles of infrastructure abstraction required for the agent era. This is a story about a paradigm, not a product pitch.

## The Evolution of Cloud Abstraction

The history of cloud infrastructure is a history of building up abstraction layers.

**Generation 1: Physical server rental.** The colocation datacenter model, where operators rented rack space. Operators were responsible for everything from OS installation to network configuration. The cost of change was very high, and responding flexibly to shifts in demand was difficult.

**Generation 2: Virtual machines (VMs).** The model exemplified by AWS EC2 and GCP Compute Engine. Physical servers were partitioned into logical units, and operators could provision compute resources -- CPU, memory, storage -- through an API. Abstraction dramatically improved infrastructure elasticity.

**Generation 3: Containers and orchestration.** The world defined by Docker and Kubernetes. Packaging the execution environment itself as an image and deploying workloads via declarative specifications became the norm. Concepts like immutable infrastructure, GitOps, and service meshes flourished in this generation.

**Generation 4 (current transition): Serverless and functions.** The model represented by AWS Lambda and Google Cloud Functions. Operators no longer need to manage servers at all. They pay only for execution costs, in function-sized units that respond to events.

All of these generations share one thing in common: the managed entity has always been the **execution environment**. Whether VMs, containers, or functions, cloud has focused on providing "a space in which something runs."

Autonomous AI agents break out of this frame.

## The Four Hard Problems of Agent Operations

Teams that have deployed autonomous AI agents in production environments consistently encounter a shared set of challenges.

### Hard Problem 1: Model Selection and Cost Control

An agent does not complete its work with a single LLM call. To solve complex goals, it goes through multiple stages: Planning, Execution, and Synthesis.

The problem is that each stage demands different model capabilities. Planning requires broad context and complex reasoning; a simple retrieval step does not. Yet with existing approaches, it is difficult to control this granularly. Developers must either specify a model for each stage manually, or process everything with a single powerful (and expensive) model.

The former increases code complexity; the latter leads to cost explosion. [estimate] It is not uncommon for model costs to account for more than 60% of total infrastructure costs in large-scale agent operations organizations.

### Hard Problem 2: Skill Management and Proliferation

Let us call the set of tools and capabilities an agent uses "skills" for convenience. As the agent ecosystem grows, skills proliferate rapidly. Multiple skills with similar functionality emerge, some of which go unmaintained. It becomes difficult to determine which skill is best suited to which situation.

Just as AMI image sprawl occurs when VM images are not managed systematically, skill sprawl occurs in agent ecosystems. Yet existing cloud infrastructure provides no abstraction to address this.

### Hard Problem 3: Balancing Governance and Autonomy

Autonomous AI agents confront a fundamental question: "How much should they judge and act on their own?" Too much restriction eliminates the agent's value; too little causes unexpected behavior.

Controlling this at the operations layer requires a policy engine. It must declaratively define and enforce which tools are permitted, which data can be accessed, and which actions require human approval.

Traditional cloud IAM and security groups handle "who can call which API." But agent governance must address the context-dependent question: "Can this agent make this judgment in this situation?" This demands a qualitatively different abstraction.

Practically, consider this scenario: when an agent with access to a customer database attempts a large-scale query at an unusual hour, should it be allowed simply because it has API permission? Contextual authorization was an area that traditional IAM models placed deliberately out of scope.

### Hard Problem 4: Continuous Learning and Skill Evolution

Agents are not static software. As they operate, data accumulates about which strategies are effective and which skills frequently fail. A feedback loop is needed to improve agents and skills based on this data.

Just as container images are updated through deployment pipelines, an agent's capabilities must be updated systematically. Yet existing cloud infrastructure does not treat this "evolution of capability" as a first-class citizen.

This challenge is particularly pronounced in enterprise environments. In an agent system used by hundreds of team members, understanding which skill has degraded since last month, and in which scenarios new skills are needed, requires enormous operational overhead. Without automation, agent systems tend to degrade gradually in quality after initial deployment.

## Skills, Tools, Policies, and Audit Logs as First-Class Resources

All four of these hard problems point to the same root cause: the things that existing cloud treats as first-class resources -- VMs, containers, functions, storage, networks -- are not the things that matter most for agent operations.

An agent-native cloud must treat the following four as first-class resources.

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
<div class="d3-arch" data-arch-root id="22agentnativecloudpraxis-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 739, "height": 643, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 494, "y": 50, "w": 213, "h": 544, "label": "Traditional Cloud First-Class Resources", "lx": 506, "ly": 68}, {"x": 24, "y": 24, "w": 283, "h": 587, "label": "Agent-Native First-Class Resources", "lx": 36, "ly": 42}], "nodes": [{"id": "VM", "x": 533, "y": 144, "w": 135, "h": 46, "title": "VM / Containers"}, {"id": "DB", "x": 540, "y": 277, "w": 120, "h": 46, "title": "Databases"}, {"id": "NET", "x": 540, "y": 378, "w": 120, "h": 46, "title": "Networks"}, {"id": "STORAGE", "x": 540, "y": 511, "w": 120, "h": 46, "title": "Storage"}, {"id": "SKILL", "x": 67, "y": 195, "w": 198, "h": 78, "title": ["Skills", "Capability unit,", "versioned, self-evolving"]}, {"id": "TOOLS", "x": 63, "y": 362, "w": 205, "h": 78, "title": ["Tools", "Tool registry, permission", "bindings"]}, {"id": "POLICY", "x": 70, "y": 62, "w": 191, "h": 78, "title": ["Policies", "Autonomy-risk matrix,", "declarative enforcement"]}, {"id": "AUDIT", "x": 77, "y": 495, "w": 177, "h": 78, "title": ["Audit Logs", "Hash chain, immutable", "history"]}], "edges": [{"src": "SKILL", "dst": "VM", "kind": "data", "label": "Runtime execution", "curve": [[265, 234], [307, 234], [494, 234], [563, 190]], "off": "50%"}, {"src": "TOOLS", "dst": "NET", "kind": "data", "label": "API calls", "line": [268, 401, 540, 401], "lx": 400, "ly": 397}, {"src": "POLICY", "dst": "VM", "kind": "data", "label": "Enforcement layer", "curve": [[261, 101], [307, 101], [494, 101], [563, 144]], "off": "50%"}, {"src": "AUDIT", "dst": "STORAGE", "kind": "data", "label": "Persistence", "line": [254, 534, 540, 534], "lx": 400, "ly": 530}]});
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
      const container = document.getElementById('22agentnativecloudpraxis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22agentnativecloudpraxis-1';
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

**Skills are the unit of capability.** They must be more than simple prompt bundles -- they must be manageable objects with versions, evaluation metrics, and the ability to be compared and merged. Decisions about which skills to retain and which to deprecate must be made based on metrics such as usage frequency, success rate, and cost efficiency.

**Tools are a tool registry.** They represent the list of external interfaces an agent can invoke, with access permissions bound to each tool. It must be possible to centrally manage which agent can invoke which tool.

**Policies are the language of governance.** Policies are expressed as a matrix crossing an agent's level of autonomy against the scope of acceptable risk. Declarative policies must be enforced at runtime, and workflows must be automatically triggered when human approval is required.

**Audit Logs are the foundation of trust.** The history of judgments made and actions taken by an agent must be recorded in a tamper-proof manner. This is, before being a matter of regulatory compliance, a design principle that makes agent systems trustworthy.

Treating these four resources as first-class citizens means more than simply being able to store and retrieve them. It means full lifecycle management: provisioning them like compute resources, versioning, controlling access through policies, tracking costs, and rolling back on failure. Just as Kubernetes handles containers through "Deployment" and "ReplicaSet" abstractions, an agent-native platform must handle skills through "SkillRelease" and "SkillPolicy" abstractions.

## ThakiCloud's Implementation: Paxis and AI Platform Integration

ThakiCloud is developing **Paxis** as the platform that concretizes these design principles. Under the concept of "AWS for Agents," the goal is to treat Skills, Tools, Policies, and Audit Logs as first-class resources -- in the same way that traditional cloud treats VMs, DBs, and Networks.

**The LLM and skill router** automatically selects the right model for each stage of agent execution (Planning, Execution, Synthesis). It supports more than 10 providers including Claude, GPT, Gemini, Kimi, Ollama, and ThakiCloud's own model Metis, and reduces unnecessary high-cost model calls through cost-aware routing. Skill selection is a two-stage process: it first narrows down the domain candidate set, then selects the optimal skill based on 7 criteria including suitability, cost, and reliability.

**The Curator self-evolving daemon** continuously manages the skill ecosystem. It detects and merges similar skills, automatically patches skills with degraded performance, and discovers new skills based on operational data. Through memory distillation, insights from repeated execution are accumulated into a knowledge base.

**The security and governance layer** provides a policy matrix crossing 4 levels of autonomy with 7 levels of risk. Prompt protection for 11 input types and 2 output types is applied, along with masking for 16 categories of personal information. Sandbox execution environments based on Docker and Kata containers isolate agents, and hash-chain audit logs covering more than 20 event types are retained for 90 days.

**The multi-channel inbound layer** enables interaction with agents through a Web React SPA, Slack (supporting 48 commands), and a CLI. A dynamic scheduler that defines custom tasks in natural language is also included. Instructions like "collect and summarize competitor news every morning" are registered directly by the agent as its own schedule.

**The Hybrid Knowledge Engine (HKE)** combines team-specific wiki-based RAG with a knowledge graph. Each agent references a knowledge base specialized to its domain, continuously enriching it through execution experience.

Paxis operates in conjunction with the **AI Platform (ai-suite)**. It is a three-layer architecture where the AI Platform handles central LLM policy and cost control, Paxis provides the agent runtime, and Metis handles the inference layer. The way each layer has clear responsibilities and combines is similar to the separation of control plane and data plane in traditional cloud.

The stack is built with Go 1.26 (backend) and React 19 (frontend), using PostgreSQL, Redis, and MinIO as the storage layer in production environments.

## Limitations and Outlook

The concept of agent-native cloud itself is not yet mature. Several fundamental difficulties deserve honest examination.

**The problem of measuring skill quality.** The reliability of container images can be assessed through relatively established methods such as vulnerability scanning and signature verification. In contrast, the quality of a skill depends deeply on the execution context. "Is this skill appropriate for this situation?" is difficult to fully evaluate in advance through automated means. Current evaluation metrics (success rate, cost efficiency) are proxy metrics only -- they do not measure true effectiveness.

**The illusion of policy completeness.** Declarative policies are enforced for stated situations, but the variety of situations an agent encounters exceeds the imagination of policy designers. Care is needed to ensure that policies do not create the false impression that "governance has been solved." Policies are a safety net, not a guarantee.

**The complexity of multi-agent coordination.** Handling a single agent and handling a system in which multiple agents collaborate are qualitatively different problems. Trust models between agents, conflict resolution mechanisms, and accountability attribution are areas that have not yet been sufficiently resolved at the infrastructure layer.

**The absence of industry standards.** For VMs, image standards like OVF/OCI and compatible API patterns between cloud providers exist. Standards for describing agent skills and policies are still being formed. There are movements trying to standardize tool interfaces, like MCP (Model Context Protocol), but broader ecosystem consensus will take time.

The direction, nonetheless, is clear. As agents establish themselves as part of software systems, the level of abstraction in the infrastructure that operates them must rise as well. Just as we moved from an era of directly managing physical servers to an era of calling VM APIs, an era is approaching where "an agent's capabilities and scope of action are defined via API, and the platform enforces them."

Paxis's journey, with a skill marketplace [estimate] on the roadmap for Q4 2026 and SOC2 certification and air-gap deployment [estimate] for Q2 2027 and beyond, is part of that flow. As the platform matures, developers will be able to focus on designing agent capabilities, while the infrastructure handles execution safety and cost optimization.

Agent-native cloud is not yet a complete concept. But what problems in the next generation of software operations need to be solved at the infrastructure layer is, at this moment, taking shape as design principles.
