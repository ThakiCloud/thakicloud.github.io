---
title: "Have It Write the Goal First on Hard Tasks: Codex Goal-Delegation Prompting"
excerpt: "A developer shared a tip: when handing Codex a genuinely hard /goal, first ask it to write the goal so that another thread can achieve it. It sounds like wordplay, but underneath is a real agent-operations pattern: make the model author a verifiable goal spec first, then delegate that spec to a fresh thread. We look at how Codex goals actually work and read the technique through ThakiCloud's Goal Mode, pge-loop, and Paxis."
seo_title: "Codex Goal-Delegation Prompting: Writing a Verifiable Goal First - Thaki Cloud"
seo_description: "We analyze Codex's /goal feature and the meta-prompting technique of writing a goal for another thread. The three parts of a goal (measurable outcome, verification surface, constraints), ThakiCloud's real Goal Mode and pge-loop, and a Paxis Agent-Native Cloud perspective."
date: 2026-07-15
last_modified_at: 2026-07-15
lang: en
tags:
  - ai-coding
  - agentic
  - codex
  - goal-mode
  - agentops
  - verification
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/codex-goal-delegation/"
categories:
  - agentops
---

## Overview

A short tip has been circulating among developers who lean on coding agents. When you hand Codex a truly hard `/goal`, do not tell it to start working right away. First ask it to "write the goal so that another thread can achieve it." Read once, it sounds like a play on words. What difference does it make to ask the model to write the goal instead of achieving it?

Yet this tip lands squarely on something anyone who has run agents for a while knows in their bones. Hard tasks usually fail not because the model is weak, but because the goal was never written in a form a machine can judge. People think a sentence like "clean up this refactor" is a goal, but to an agent it leaves everything blank: when to stop, what counts as success, where the boundary is. So this post takes the "have it write the goal" technique apart piece by piece, and shows how ThakiCloud, which runs a Kubernetes-based AI/ML platform and an agent platform, already enforces the same principle in code.

## What Codex goals are

First, look closely at the raw ingredient. Codex's `/goal` attaches a persistent objective to a thread. According to OpenAI's published cookbook "Using Goals in Codex," a goal should be described in three parts: a measurable outcome, a verification surface that lets you confirm progress, and constraints. Once those three are present, the goal becomes a durable target attached to the thread.

The mechanics matter. At the end of each turn, Codex inspects the evidence so far and judges for itself whether the objective is satisfied. If not, and the goal is still active and within budget, it continues from the latest state. In short, instead of a single response, it repeats observing and judging until the goal, a termination condition, is met. The appeal is that a long-running task can turn into a set-it-and-forget-it workflow.

The key point here is that the quality of the goal decides everything. If the verification surface is blurry, Codex cannot tell when to stop; without constraints, it wanders past its scope and touches unrelated files; without a measurable outcome, it fixes one file and declares itself done. Writing a good goal is therefore its own skill, and when that skill is lacking, hard tasks fall apart.

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
<div class="d3-arch" data-arch-root id="60715codexgoaldelegation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 788, "height": 834, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 329, "y": 24, "w": 128, "h": 46, "title": "Hard task idea"}, {"id": "B", "x": 289, "y": 148, "w": 209, "h": 68, "title": ["Is the goal in a", "machine-checkable form?"]}, {"id": "C", "x": 635, "y": 308, "w": 121, "h": 62, "title": ["Spinning loop", "or early exit"]}, {"id": "D", "x": 424, "y": 316, "w": 156, "h": 46, "title": "Measurable outcome"}, {"id": "E", "x": 199, "y": 316, "w": 170, "h": 46, "title": "Verification surface"}, {"id": "F", "x": 24, "y": 316, "w": 120, "h": 46, "title": "Constraints"}, {"id": "G", "x": 206, "y": 448, "w": 156, "h": 62, "title": ["Persistent goal", "attached to thread"]}, {"id": "H", "x": 189, "y": 602, "w": 191, "h": 62, "title": ["Self-judges on evidence", "at each turn's end"]}, {"id": "I", "x": 217, "y": 756, "w": 135, "h": 46, "title": "Converged, done"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [393, 70, 393, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "No", "curve": [[498, 210], [696, 262], [696, 262], [696, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Yes", "curve": [[439, 216], [502, 262], [502, 262], [502, 316]], "off": "50%"}, {"src": "B", "dst": "E", "kind": "data", "label": "Yes", "curve": [[347, 216], [284, 262], [284, 262], [284, 316]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "label": "Yes", "curve": [[289, 209], [84, 262], [84, 262], [84, 316]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[502, 362], [502, 409], [502, 409], [362, 454]]}, {"src": "E", "dst": "G", "kind": "data", "line": [284, 362, 284, 448]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[84, 362], [84, 409], [84, 409], [206, 452]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[301, 510], [326, 556], [326, 556], [301, 602]]}, {"src": "H", "dst": "G", "kind": "data", "label": "Unmet, within budget", "curve": [[267, 602], [242, 556], [242, 556], [267, 510]], "off": "50%"}, {"src": "H", "dst": "I", "kind": "data", "label": "Met", "line": [284, 664, 284, 756], "lx": 284, "ly": 706}]});
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
      const container = document.getElementById('60715codexgoaldelegation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '60715codexgoaldelegation-1';
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

## The technique: "write a goal for another thread"

Now back to the tip. Facing a hard task, a person rarely writes a good goal on the first try. Filling in what the measurable outcome is, what will verify progress, and which constraints to set is itself a non-trivial design task. What this tip proposes is to delegate that design to the model first.

Concretely, it flows like this. The first thread is told to "write a goal that lets another thread autonomously achieve this hard task." The model does not do the work here. Instead it understands the task and produces a goal spec that states what success is, how to verify it, and where the boundary lies. The person reviews and sharpens that spec, then feeds it as the goal into a new thread to run the actual execution. The execution thread starts with a well-defined termination condition, so it is far less prone to the spinning loops or early exits described above.

This technique works for two reasons. First, it separates writing the goal from achieving the goal. The two are different in character. Writing a goal is about understanding the problem broadly and fixing success criteria in language; achieving a goal is about drilling narrowly toward those criteria. When one thread tries to do both, it lurches into implementation while still deciding the verification criteria, and ends up grading itself against criteria it never even set. Separated, each thread focuses on one thing.

Second, it creates a review point for the person. The goal spec the model produces is an artifact a person can read and edit before execution. If the verification surface is weak, you can reinforce it at this stage; if the scope is broad, you can add constraints. Discovering a mistake after execution starts is expensive; catching it at the goal-spec stage is cheap. In other words, this is not a prompt trick but a structural device that inserts one layer of cheap review.

Of course it is no cure-all. One developer newsletter framed this approach as turning "a four-hour task into a set-it-and-forget-it workflow," but that is an impression of a case that fit well, not a guarantee. Even if you succeed at making the model write a good goal, whether the execution thread actually converges toward it is a separate matter. So the technique only pays off when it is paired with the verification gates discussed below.

## Implications for ThakiCloud's products

There is a reason this technique does not feel foreign: ThakiCloud already enforces the same principle, not as a prompt request but as a code discipline. Since the subject is agent operations, we center the perspective of our agent platform Paxis here, while also connecting it to the ai-platform infrastructure beneath it.

Paxis is ThakiCloud's Agent-Native Cloud, a control plane that treats skills, tools, policies, and audit logs as first-class resources. Inside it is an executor called Goal Mode. When we create a goal in Goal Mode, we have written the rules so that `check_cmd`, `success_criteria`, and a budget cannot be left blank. Those three map almost one-to-one to the three parts of a Codex goal: `success_criteria` is the measurable outcome, `check_cmd` is the verification surface that judges progress, and the budget is the constraint. If a goal is created as an empty shell, it is designed to fail the gate on the first iteration, so the code guarantees a state where "if you do not write the goal well, it will not even start."

The delegation structure of "write a goal for another thread" also lives inside us. When a complex request arrives, the main agent decomposes it into subtasks and delegates each to a separate subagent. The one who decomposes and the one who executes are separated, which is exactly the same idea as this article's split between the goal-writing thread and the goal-executing thread. Decomposition needs judgment, so a higher-tier model handles it; execution is narrow work, so it is sent down to a cheaper model. The principle of cheap workers, expensive gates comes from here.

Above all, we never merge fanned-out results without verification. However well you write and delegate a goal, whether the result is correct must be judged by a separate verification stage, not the executor. Code artifacts are judged by actually running tests and reading the exit code; content or judgment artifacts are filtered by a majority vote of several verifiers with different perspectives. A sentence where the model reports "this looks done" cannot be the termination condition of a loop. This discipline shows how we harden Codex goal's "judge yourself on the evidence at each turn's end" into a trustworthy form.

There is a connection through the infrastructure lens too. A loop that slices goals finely and runs them with verification steadily consumes compute. The ai-platform is the layer that provides Kubernetes and Kueue-based GPU scheduling, vLLM serving, and multi-tenant isolation, building a floor where these agent loops can run cheaply and reliably. Low-cost serving creates agent economics, and on top of it Paxis's goal delegation and verification loops become practically viable. The two lenses complement each other.

## Limitations and counterarguments

To avoid overrating this technique, let us take the other side.

First, the goal-writing step itself can fail. If the model produces a plausible but unverifiable goal, the execution thread still starts without knowing what counts as success. There are many cases where a person writing a short, solid goal directly is better. So the goal spec the model writes must have a human review point, and handing it straight to execution without review throws away the very cheap review point you gained.

Second, the overhead is not justified for every task. Writing the goal for it and splitting threads on a single-file fix or a quick question is overkill. This technique only pays off on hard tasks where the termination condition is blurry, the run is long, and autonomous execution is genuinely valuable. Our internal rules likewise draw a line: use loop tools only for iterative implementation or convergent work, and do not force them onto one-off edits.

Third, the longer autonomous execution runs, the more people tend to trust the result and stop reviewing. The comfort of having delegated the goal well is itself the danger. If the verifier filters out nothing, that is not a signal that everything passed but more likely a signal that the verifier is broken. So core outputs must be sampled and checked by a person periodically, and verifiers should be designed to aim at refutation, not confirmation.

In sum, "on hard tasks, write the goal first" is not a prompting knack but structural advice to separate writing the goal from executing it and to insert a review point in between. If Codex's goal feature put this into the hands of individual developers, ThakiCloud enforces the same principle at team scale through Paxis's Goal Mode and verification loops. That writing a good goal is what it means to run an agent well does not change, whatever the tool.

## Sources

- OpenAI Cookbook, ["Using Goals in Codex"](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
- Original tweet: nickbaumann_, tip post on delegating Codex goals (X/Twitter fetch restrictions prevent automated verification, source not machine-verified)
