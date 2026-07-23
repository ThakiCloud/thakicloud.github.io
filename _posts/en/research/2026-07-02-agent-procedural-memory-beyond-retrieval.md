---
title: "Agent Procedural Memory: Beyond Prompt Retrieval"
excerpt: "Stuffing skills into an agent's prompt eats context and breaks easily. Recent research is moving procedural memory from prompt templates toward architectures that separate build, retrieval, and update, and further toward parametric neural policies. We map this shift around Memp and the AFTER benchmark, then look at how ThakiCloud Paxis's skill harness puts it into practice."
seo_title: "Agent Procedural Memory: Skill Storage Beyond Prompt Retrieval | Thaki Cloud"
seo_description: "A survey of LLM agent procedural memory research centered on Memp (arXiv 2508.06433) and the AFTER benchmark (arXiv 2606.23127), covering the build-retrieval-update architecture, the shift toward parametric memory, and its application in ThakiCloud Paxis's skill harness."
date: 2026-07-02
last_modified_at: 2026-07-02
lang: en
tags:
  - agent-memory
  - procedural-memory
  - llm-agents
  - skills
  - agent-skills
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "brain"
canonical_url: "https://thakicloud.com/tech-blog/en/research/agent-procedural-memory-beyond-retrieval/"
categories:
  - research
published: false
---

## Overview

Anyone who has run LLM agents for a while hits the same wall. The agent reasons from scratch every time, fumbling its way back through a procedure it already solved last week. A common fix is to cram frequently used skills straight into the prompt. But this approach is fragile for two reasons. First, as skills accumulate they eat up the context window, leaving less room for the actual task. Second, prompt templates break easily the moment the situation shifts even slightly.

Recent research on agent memory reframes this problem through the lens of **procedural memory**. Just as human procedural memory holds skilled actions that execute without conscious thought, like riding a bike, an agent's procedural memory compresses the execution steps of recurring tasks into a reusable form. The core shift is moving procedural knowledge **beyond prompt retrieval**, into a separate storage, retrieval, and update architecture, and ultimately into a neural policy embedded in the model's own parameters.

This post maps that shift through peer-reviewed papers. Since ThakiCloud's Agent-Native Cloud, Paxis, treats skills as first-class resources in exactly the way this research line points toward, we close by drawing that connection.

## What Is Procedural Memory

From a cognitive-science standpoint, memory is commonly split into three kinds: semantic memory for facts, episodic memory for events, and procedural memory for methods. In the agent literature, procedural memory covers the "how": it abstracts complex action sequences into reusable patterns, so the agent doesn't have to plan from the ground up every single time.

The trouble is that in most agents today, this procedural knowledge exists in one of three forms: hand-crafted by a person, embedded in a brittle prompt template, or implicitly entangled in the model's parameters where it is expensive to update. What this research targets is lifting that knowledge into a **learnable, updatable, first-class object**.

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
<div class="d3-arch" data-arch-root id="ralmemorybeyondretrieval-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 382, "height": 932, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 66, "y": 24, "w": 128, "h": 62, "title": ["Past execution", "trajectories"]}, {"id": "B", "x": 45, "y": 164, "w": 170, "h": 62, "title": ["Procedure extraction", "Build"]}, {"id": "C", "x": 128, "y": 304, "w": 138, "h": 52, "title": "Storage form"}, {"id": "D", "x": 222, "y": 434, "w": 128, "h": 62, "title": ["Non-parametric", "text scripts"]}, {"id": "E", "x": 46, "y": 434, "w": 121, "h": 62, "title": ["Parametric", "neural policy"]}, {"id": "F", "x": 101, "y": 574, "w": 191, "h": 62, "title": ["Retrieval and selection", "Retrieval"]}, {"id": "G", "x": 133, "y": 714, "w": 128, "h": 46, "title": "Task execution"}, {"id": "H", "x": 24, "y": 838, "w": 212, "h": 62, "title": ["Feedback-driven update", "add, revise, delete Update"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [130, 86, 130, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[159, 226], [197, 265], [197, 265], [197, 304]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[232, 356], [286, 395], [286, 395], [286, 434]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[161, 356], [107, 395], [107, 395], [107, 434]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[286, 496], [286, 535], [286, 535], [236, 574]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[107, 496], [107, 535], [107, 535], [157, 574]]}, {"src": "F", "dst": "G", "kind": "data", "line": [197, 636, 197, 714]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[197, 760], [197, 799], [197, 799], [159, 838]]}, {"src": "H", "dst": "B", "kind": "data", "curve": [[69, 838], [-9, 675], [-9, 395], [69, 226]]}]});
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
      const container = document.getElementById('ralmemorybeyondretrieval-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ralmemorybeyondretrieval-1';
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

## Beyond Prompt Retrieval: Separating Build, Retrieval, and Update

The paper that takes this shift on directly is **Memp: Exploring Agent Procedural Memory** (arXiv 2508.06433). Memp treats procedural memory as a first-class optimization target and distills past trajectories into two layers: fine-grained, step-by-step instructions, and higher-level, script-like procedures. It then splits the memory loop into three distinct phases: **build, retrieval, and update**. In the update phase, entries are added, revised, or deleted based on execution feedback.

This separation matters because it is fundamentally different from stuffing skills into a prompt. In the prompt-based approach, storage and retrieval are collapsed into one, and the very concept of "update" barely exists. Once you separate the three phases, when and how a procedure enters or leaves the pool, and what gets fixed after a failure, become explicit design decisions. According to the literature, the broader direction of this shift is summarized as a move **from explicit non-parametric templates toward implicit parametric neural policies** (the Foundation Agents memory survey, arXiv 2602.06052). In other words, the field is moving past storing and retrieving procedures as text, toward folding experience directly into the model's own policy.

## Why This Matters Now: The Evaluation Problem

Whether procedural memory actually produces usable skills is still not well understood. The paper aimed at this gap is **Managing Procedural Memory in LLM Agents** (arXiv 2606.23127). It proposes a benchmark called **AFTER**: 382 realistic enterprise tasks spanning 6 job roles, paired with 22 procedural skills, built to measure how well a skill transfers across tasks, roles, and model backbones.

The question this benchmark raises is the crux of the matter. Does a procedure learned in one context hold up in another? Does a skill still work once the underlying model changes? The moment you introduce procedural memory, you need a way to measure whether a given skill is actually reusable. Even with a solid build-retrieve-update architecture in place, a skill that fails to transfer ends up no better than an expensive prompt template.

## Implications for ThakiCloud's Products

This line of research already has a concrete production shape in ThakiCloud's **Paxis**. Paxis is an Agent-Native Cloud that treats **skills, tools, policies, and audit logs as first-class resources**. Its skill harness is, in effect, procedural memory running in production.

- **A practical counterpart to build, retrieval, and update**: Paxis's skill harness selects (retrieves) from more than 960 skills via BM25, executes them in isolated sandboxes, and improves (updates) them through a self-evolution loop. The three-phase separation that Memp proposed shows up here as an operating system.
- **An architecture that moves past prompt retrieval**: Instead of stuffing skills into every prompt, Paxis selectively pulls in verified skills, which preserves the context budget while keeping the procedure consistent. This lines up exactly with the "beyond prompt retrieval" direction covered in this post.
- **Evaluation and audit**: Paxis manages the "transferability" that the AFTER benchmark emphasizes through policy gates and audit logs. Because which skill was selected, when, and what it did is all tracked, there is a data-backed basis for telling reusable procedures apart from ones that are not.

From an infrastructure standpoint, ai-platform underpins this skill execution. Because agents run skills on top of Kueue GPU scheduling and multi-tenant serving, the execution cost of procedural memory feeds directly into serving efficiency. Low-cost serving (ai-platform) is what makes agent economics (Paxis) sustainable.

## Limitations and Counterarguments

Moving procedural memory toward a parametric neural policy comes with a clear cost. A text script can be read and edited by a human, but a procedure folded into parameters is hard to audit and hard to update. It is difficult to inspect what has actually been stored, and just as difficult to pick out and delete a bad procedure. In regulated or sovereign environments where explainability matters, that opacity becomes a risk in its own right.

Non-parametric retrieval is not a silver bullet either. Retrieval can still surface the wrong procedure, and selection quality can degrade as the storage pool grows. As benchmarks like AFTER show, skill transferability is still at an early stage of validation, and there is no guarantee that a procedure that works in one domain will work in another. Procedural memory is a promising direction for keeping agents from starting over from a blank slate every time, but it will only become a trustworthy production asset once storage form, retrieval quality, update safety, and evaluation methodology mature together.

## Sources

- [Memp: Exploring Agent Procedural Memory (arXiv 2508.06433)](https://arxiv.org/abs/2508.06433)
- [Managing Procedural Memory in LLM Agents: Control, Adaptation, and Evaluation (arXiv 2606.23127)](https://arxiv.org/abs/2606.23127)
- [Rethinking Memory Mechanisms of Foundation Agents in the Second Half: A Survey (arXiv 2602.06052)](https://arxiv.org/abs/2602.06052)
