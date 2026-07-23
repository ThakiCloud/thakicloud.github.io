---
title: "Paxis: Run a Full Team of AI Employees Without Writing Code"
excerpt: "Just as traditional clouds treat servers as first-class resources, Paxis treats agent skills, tools, policies, and audit logs as first-class resources. 849 skills loaded automatically, a CostRouter that picks the right model per task, and capabilities that sharpen with use. We share a working PoC with real code."
seo_title: "Paxis Agent-Native Cloud: Governance, CostRouter, and Evolving Skills - Thaki Cloud"
seo_description: "ThakiCloud Paxis is an Agent-Native Cloud for running autonomous AI agents safely. It features L0-L3 autonomy governance, multi-LLM CostRouter cost optimization, a Git-based HKE knowledge engine, and an 849-skill harness. Explained with real code."
lang: en
canonical_url: https://thakicloud.com/tech-blog/en/agentops/praxis-agent-native-cloud/
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - agent-native-cloud
  - praxis
  - agentops
  - llm-cost-optimization
  - governance
  - rag
  - knowledge-engine
  - multi-agent
  - skill-harness
  - thakicloud
header:
  teaser: /assets/images/praxis-architecture-hero.webp
toc: true
toc_sticky: true
categories:
  - agentops
published: false
---

![Paxis layered architecture: Cloud infrastructure at the base, Paxis Core above it, and the 849-skill / 14-domain agent capability layer on top]({{ '/assets/images/praxis-architecture-hero.webp' | relative_url }})

## The Next Question in Cloud: How Do You Operate Agents?

Over the past decade, cloud generations have been defined by what they manage. First came servers and infrastructure. Then data and pipelines. The question surfacing in production right now is different. The moment you start running multiple AI agents, you lose visibility into who did what, costs escape prediction, security and audit requirements go unmet, and every team rebuilds the same thing independently.

Paxis targets that gap. Traditional cloud treated compute, databases, and networking as first-class resources. Paxis treats AI agent capabilities (Skills), tools (Tools), policies (Policies), and audit logs (Audit) as first-class resources. Customers hire, manage, and audit "a full team of AI employees" without writing code. We call this category Agent-Native Cloud.

![Traditional cloud manages Compute, DB, and Network as first-class resources; Paxis manages Skills, Tools, Policies, and Audit Logs]({{ '/assets/images/praxis-cloud-analogy.webp' | relative_url }})

This post is not a marketing tagline -- it walks through a working PoC with real code. Every number below was verified against an actual server (`localhost:8080`).

## Core Modules: Three Things to Remember

The Paxis backend is written in Go. The architecture reads cleanly as three layers: infrastructure at the bottom, the core above it, and the capability layer on top.

- Agent Runtime (Native Loop): The single execution entry point where the ReAct loop, tool execution, cost tracking, and autonomy gates converge.
- Skill Harness: Automatically loads skills at boot and selects relevant ones using TF-IDF.
- Hybrid Knowledge Engine (HKE): A Git-based knowledge layer that ingests and queries per-team wikis.
- LLM Gateway: Abstracts multiple model providers and serves as the single source of truth for cost routing.
- Security and Policy: Autonomy matrix (L0-L3), prompt security, and full action auditing.
- Memory: Session memory, pgvector semantic search, and provenance tracking.

Sandbox execution and multi-agent orchestration sit underneath all of this. If you need to remember only three things: runtime, harness, knowledge engine.

## Adding Capability = One File

The cost of adding a new capability in Paxis is zero code deployments. Drop a single `skills/<domain>/<name>/SKILL.md` file and the server scans the directory automatically, picking it up immediately.

```markdown
---
name: competitor-digest
description: >-
  Collects and summarizes competitor news. Use when tracking competitor activity or news digests.
allowed-tools: [web_search, web_fetch]
---
# Competitor Digest
## Instructions
Gather the latest articles from the specified sources and distill the key points into bullets.
```

Save the file and it appears in `GET /api/v1/skills` with no server restart. In the PoC, 849 skills loaded automatically at boot, along with 14 default domain agents. This "thick skills, thin harness" principle means capabilities accumulate as files while the harness stays lean.

Creating a recurring task in natural language follows the same pattern.

```bash
curl -X POST http://localhost:8080/api/v1/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"team_id":"dev-team","agent_id":"research-bot",
       "schedule":{"type":"cron","expr":"0 9 * * *"},
       "skill":"competitor-digest","params":{"topN":10}}'
```

Type "summarize the top 10 competitor news items every morning at 9" in chat, and the LLM translates it into this cron, skill, and parameter set and registers it. Zero lines of code.

## CostRouter: The Code Picks the Model Per Task

The "AI cost explosion" problem is almost always the same cause: using an expensive model for everything. Paxis splits a task into three phases -- Planner, Executor, Synthesizer -- and automatically assigns the right model to each.

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
<div class="d3-arch" data-arch-root id="20praxisagentnativecloud-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 465, "height": 640, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q", "x": 123, "y": 24, "w": 120, "h": 46, "title": "Task Request"}, {"id": "P", "x": 123, "y": 148, "w": 120, "h": 46, "title": "Planner"}, {"id": "E", "x": 214, "y": 286, "w": 120, "h": 46, "title": "Executor"}, {"id": "S", "x": 309, "y": 424, "w": 120, "h": 46, "title": "Synthesizer"}, {"id": "H", "x": 24, "y": 286, "w": 135, "h": 46, "title": "Haiku · economy"}, {"id": "SO", "x": 105, "y": 424, "w": 149, "h": 46, "title": "Sonnet · standard"}, {"id": "O", "x": 305, "y": 562, "w": 128, "h": 46, "title": "Opus · premium"}], "edges": [{"src": "Q", "dst": "P", "kind": "data", "line": [183, 70, 183, 148]}, {"src": "P", "dst": "E", "kind": "data", "curve": [[213, 194], [274, 240], [274, 240], [274, 286]]}, {"src": "E", "dst": "S", "kind": "data", "curve": [[306, 332], [369, 378], [369, 378], [369, 424]]}, {"src": "P", "dst": "H", "kind": "event", "label": "most tasks", "curve": [[152, 194], [92, 240], [92, 240], [92, 286]], "off": "50%"}, {"src": "E", "dst": "SO", "kind": "event", "label": "standard", "curve": [[242, 332], [179, 378], [179, 378], [179, 424]], "off": "50%"}, {"src": "S", "dst": "O", "kind": "event", "label": "critical phases only", "line": [369, 470, 369, 562], "lx": 369, "ly": 512}]});
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
      const container = document.getElementById('20praxisagentnativecloud-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20praxisagentnativecloud-1';
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

The model tiers are managed from a single source, `models.yaml`. The price spread per million output tokens is significant.

| Tier | Model | Output $/1M | Use |
|---|---|---|---|
| economy | Haiku 4.5 | $4 | Most tasks |
| standard | Sonnet 4.6 | $15 | Balanced workloads |
| strong | GPT-4o / Kimi | Mid | Augmentation |
| premium | Opus 4.8 | $25 | Critical phases only (opt-in) |

The key insight is that most tasks are well-served by the cheapest model, Haiku, and Opus is reserved only for genuinely critical phases. Per-execution budget caps are enforced, making costs predictable and visible through Command Center in daily and weekly views. And as the system sees more usage, the routing learns which tasks can be handled by cheaper models, so the cost per execution on repeated work trends downward.

## What Makes HKE Different from Traditional RAG

Traditional RAG is essentially a one-shot retrieval bolted on at query time. Paxis's Hybrid Knowledge Engine (HKE) treats knowledge as an asset that accumulates.

| Traditional RAG | Paxis HKE |
|---|---|
| Stateless single-shot retrieval | Git-based persistent wiki (knowledge accumulates) |
| No domain boundaries | Per-agent domain scoping and isolation |
| No source trust tracking | Provenance records (who, when, which source) |
| Uncapped cost | tool-budget truncates large results or defers fetch |

Documents or code pushed in are refined and grow into a knowledge graph. Answers cite their sources. Each team's wiki is isolated so one team's knowledge is never visible to another. Underneath sits a four-layer memory stack -- session memory, pgvector semantic search, team wikis, and provenance -- so context accumulates as conversations repeat.

## Governed Agents: Control as a Moat

There is no shortage of flashy agent demos, but weak governance keeps agents out of the enterprise. Paxis treats control as the default.

- Autonomy matrix L0-L3: Execution gates before a task runs, based on task risk and permission level.
- Prompt security and personally identifiable information removal.
- Full action audit chain: every action recorded -- who, when, what.
- Multi-tenant team isolation.

Beyond that, the system is designed so that capabilities sharpen through use. A curator loop runs Propose, Distill, and Patch in sequence, and a capability trust ladder promotes skills from `system` to `learned` to `promoted` based on usage. This self-improvement loop is partially working and partially under active development -- it is an honest PoC. Without exaggeration, the direction and skeleton are already in the code.

## Three Demo Scenarios Your Sales Team Can Use Today

Paxis's strength is that the team using it internally is the same team showing it to customers.

1. A delegate that works while you sleep: Toggle Proactive ON once and the next morning's briefing lands in Slack automatically.
2. Assign work by speaking: One natural-language sentence registers as a cron and a skill.
3. Documents become team knowledge: Drag in a proposal PDF and the entire team can ask questions in chat, with source citations included.

All of this is managed from a single screen, Command Center, covering schedule, cost, collaboration, and audit.

## ThakiCloud's Perspective: Why This Direction

ThakiCloud's AI platform runs a multi-tenant environment on Kubernetes, scheduling GPUs with Kueue and serving models with vLLM. Paxis is the control plane on top of that for operating agents safely.

Three things make this combination meaningful. First, governance -- L0-L3 autonomy, full action auditing, and team isolation -- is built in, which means public-sector, financial, and enterprise environments that require security, auditing, and data separation get it out of the box. Second, the design assumes on-premises and self-hosted deployments, so organizations that cannot send data outside their perimeter can still run it. Third, CostRouter's per-task model selection with budget caps makes it possible to operate while keeping GPU and API costs under control. The cost advantage at the serving layer translates directly into a product moat.

Paxis is at the PoC stage today. The core -- conversation, skills, scheduler, Command Center, cost routing, and HKE -- is working. Some advanced features are on the roadmap. "Demo-ready today, pilot one workflow first" is our honest message.

## Further Reading

- Source: [github.com/ThakiCloud/praxis](https://github.com/ThakiCloud/praxis)
- Executive demo deck (33 slides with presenter notes): [Google Slides](https://docs.google.com/presentation/d/11E5ixfWgV6uY-akebEZ--Kwp1JmRQJG1OpPaChbJLmc/edit)

We are looking for colleagues to build with and pilot customers to work alongside. We intend to define the Agent-Native Cloud category first.
