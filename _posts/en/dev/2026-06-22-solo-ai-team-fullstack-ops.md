---
title: "How a Solo AI Engineer Operates a Stack of 1,620 Skills"
excerpt: "1,620 skills, 55 sub-agents, nightly self-evolution, and cost guardrails. Exposing the full operational system that lets a solo AI team maintain a massive automation stack."
seo_title: "Solo AI Engineer Automation Stack: 1,620 Skills, 55 Agents - Thaki Cloud"
seo_description: "How a solo AI engineer operates 1,620 skills, 55 sub-agents, nightly self-evolution loops, and haiku/sonnet/opus cost routing to manage a large AI automation stack. Original experience behind ThakiCloud Paxis."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: en
tags:
  - solo-engineer
  - ai-automation
  - agent-ops
  - productivity
  - claude-code
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/solo-ai-team-fullstack-ops/"
reading_time: true
categories:
  - dev
published: false
---

![Solo AI Engineer Full-Stack Operations Overview]({{ '/assets/images/solo-ai-team-fullstack-ops-hero.webp' | relative_url }})

## Overview: How Can One Person Handle This Scale?

I get asked this question a lot. Roughly 1,620 skills, 55 sub-agents, 36 always-on rules, 22 slash commands, 12 hooks. At night, unmanned launchd jobs run their own evolution loops. Two machines -- home PC and office PC -- stay in sync through a single main branch. A single engineer runs all of this alone.

The numbers look impossible at a glance. But these numbers are not things to manage. Most of them, the system uses on its own. While the engineer writes code, the skill router picks the right skill; while they sleep, the evolution loop refines the skills; and cost guardrails keep the budget in check.

The secret is not managing scale -- it is **designing scale to manage itself**. Skills evolve skills, agents route agents, and retro loops optimize model selection. The human's job is only to set direction, notice anomalous signals, and make key judgment calls.

This post is the first time the full operational system is laid out in one place. It explains how skill routing, nightly evolution, and cost control interlock as a single operating system -- and how this experience became the source material for the ThakiCloud Paxis product.

---

## Stack Overview: The Automation Architecture in 4 Layers

The full stack is divided into four layers.

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
<div class="d3-arch" data-arch-root id="22soloaiteamfullstackops-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 654, "height": 1144, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 38, "y": 24, "w": 512, "h": 156, "label": "Layer 1: Interface", "lx": 50, "ly": 42}, {"x": 78, "y": 258, "w": 416, "h": 296, "label": "Layer 2: Routing", "lx": 90, "ly": 276}, {"x": 87, "y": 632, "w": 461, "h": 140, "label": "Layer 3: Execution", "lx": 99, "ly": 650}, {"x": 24, "y": 864, "w": 598, "h": 248, "label": "Layer 4: Nightly Self-Evolution", "lx": 36, "ly": 882}], "nodes": [{"id": "CMD", "x": 76, "y": 63, "w": 177, "h": 78, "title": ["22 Slash Commands", "/morning /eod /review", "/ship /debug"]}, {"id": "HOOK", "x": 308, "y": 63, "w": 205, "h": 78, "title": ["12 Hooks", "UserPromptSubmit · Stop ·", "PreToolUse"]}, {"id": "GATE", "x": 192, "y": 297, "w": 191, "h": 62, "title": ["Skill Router Gate", "SRA + BM25 Auto-mapping"]}, {"id": "RULES", "x": 199, "y": 437, "w": 177, "h": 78, "title": ["36 Always-on Rules", "Cost · Format · Model", "Routing · Security"]}, {"id": "SKILLS", "x": 350, "y": 671, "w": 135, "h": 62, "title": ["~1,620 Skills", ".claude/skills/"]}, {"id": "AGENTS", "x": 125, "y": 671, "w": 135, "h": 62, "title": ["55 Sub-agents", ".claude/agents/"]}, {"id": "M", "x": 62, "y": 1027, "w": 212, "h": 46, "title": "23:30 memkraft dream cycle"}, {"id": "S", "x": 386, "y": 903, "w": 198, "h": 46, "title": "00:00 selfharness-evolve"}, {"id": "E", "x": 329, "y": 1027, "w": 177, "h": 46, "title": "00:15 skill-evolution"}], "edges": [{"src": "CMD", "dst": "GATE", "kind": "data", "curve": [[164, 141], [164, 180], [164, 258], [233, 297]]}, {"src": "HOOK", "dst": "GATE", "kind": "data", "curve": [[410, 141], [410, 180], [410, 258], [341, 297]]}, {"src": "GATE", "dst": "RULES", "kind": "data", "line": [287, 359, 287, 437]}, {"src": "RULES", "dst": "SKILLS", "kind": "data", "curve": [[352, 515], [417, 554], [417, 632], [417, 671]]}, {"src": "RULES", "dst": "AGENTS", "kind": "data", "curve": [[240, 515], [192, 554], [192, 632], [192, 671]]}, {"src": "SKILLS", "dst": "S", "kind": "event", "label": "nightly evolution", "curve": [[447, 733], [485, 772], [485, 864], [485, 903]], "off": "50%"}, {"src": "S", "dst": "E", "kind": "data", "curve": [[485, 949], [485, 988], [485, 988], [442, 1027]]}, {"src": "E", "dst": "SKILLS", "kind": "data", "curve": [[370, 1027], [290, 926], [290, 818], [361, 733]]}]});
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
      const container = document.getElementById('22soloaiteamfullstackops-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22soloaiteamfullstackops-1';
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

**Layer 1 (Interface)** is where humans directly interact. Slash commands like `/morning`, `/eod`, `/review`, `/ship`, and `/debug` create the rhythm of the day. Hooks operate quietly in between. The `UserPromptSubmit` hook runs before every prompt; the `Stop` hook checks flag files when a task ends.

**Layer 2 (Routing)** is the brain of this stack. Out of 1,620 skills, it must find the right one for the current request. The skill router gate automates that task. The underlying principles are covered in detail in [Skill Routing SRA](/en/dev/skill-ecosystem-routing-sra/).

**Layer 3 (Execution)** is where actual work happens. Skills encapsulate repeatable workflows; sub-agents handle parallel execution and role separation. The 55 sub-agents are organized into 8 hub-and-spoke teams: Research, Content, Strategic Intel, Incident, Code Ship, Knowledge, Meeting, and Sales. Each team has an orchestrator with specialized sub-agents underneath.

**Layer 4 (Nightly Self-Evolution)** is the system's key differentiator. While the engineer sleeps, the stack improves itself.

---

## Routing at Every Moment: What the Skill Gate Does

All 1,620 skills exist under `.claude/skills/`, but not all are loaded every turn. Doing so would burn the entire budget on context cost alone. Assuming a skill description averages 300-500 tokens [estimate], loading all of them would consume hundreds of thousands of tokens per turn. Instead, `skill-router-gate.py` -- wired to the `UserPromptSubmit` hook -- narrows candidates via BM25 search and injects them into context.

The gate serves three roles.

First, **pre-filtering**. Turns that need no skill -- greetings, confirmations, pure commands -- pass through instantly with zero token cost. Running BM25 on every request would itself become an expense.

Second, **candidate injection**. When a turn is judged as task-oriented, a `🧭 Skill Router Candidates` block is added to context. The model sees this hint and selects the appropriate skill. Candidates are capped at 5, and if 2 or more tie, the user is asked to confirm.

Third, **preventing forced matching**. A skill is not selected just because its name partially overlaps. If the top score falls below a threshold, execution falls through to native. In an environment with 1,620 skills, the most common failure mode is an unrelated skill intruding like noise. The detailed design principles of this router are covered in [Skill Routing SRA](/en/dev/skill-ecosystem-routing-sra/).

The 36 always-on rules apply to all tasks independently of this routing. Cost control, Slack format determinism, the model routing table, output token discipline -- these are not "requested" of the model but enforced by code.

For example, the `quality_gate` field in a batch content skill once came back three different ways: `"passed"`, `True`, `{...}`. Give a model freedom and Sonnet will output differently on every call. Now code directly measures with `len()` and checks thresholds. The model's self-reported numbers are not trusted.

The 22 slash commands are a kind of macro running on top of this routing. `/morning` runs SOD git sync, Google Workspace briefing, and the stock pipeline in order. `/eod` bundles Cursor sync, release ship, and Slack summary. The human never has to remember the sequence.

---

## Every Night's Evolution: The Nightly launchd Loop

This is the part that surprises people most. While the engineer sleeps, three launchd jobs run in sequence.

**23:30 memkraft dream cycle.** Extracts insights, lessons, and patterns from the day's conversations and reflects them into the memory structure. Without the engineer manually recording anything, the system converts today's experience into tomorrow's context.

**00:00 selfharness-evolve.** Analyzes performance metrics for current skills and evaluates description quality, trigger conflicts, and usage frequency. Identifies skills needing improvement and generates improvement proposals. This job always runs on local launchd, never a cloud routine. In cloud sandboxes, bash cannot boot properly and gates can be fabricated.

**00:15 skill-evolution.** Applies what selfharness proposed. Refines skill descriptions, generates new skills when new patterns are found, and cleans up content that is no longer valid.

The detailed principles of the self-evolution loop are covered separately in [Self-Evolving Harness Nightly](/en/research/self-evolving-harness-nightly/).

There is an important design principle here. These nightly jobs are creative about skill content, but code owns the format. The model does not hand-write JSON or self-report quality judgments. Code measures with `len()`, validates with regex, and re-dispatches anything below threshold. The only way to keep a Sonnet-tier model producing consistent format across repeated batch tasks is to remove freedom.

---

## Preventing Cost Leaks: 4-Layer Guardrails

There was a day when daily AI costs reached $705. A single monitor session (9.4 hours, 1,145 turns) accounted for 54% of the total. The 4-layer guardrails in use today came out of that incident. The detailed figures are published in [LLM Cost Routing Guardrails](/en/llmops/llm-cost-routing-guardrails/).

**Layer 1: Model routing table.** Exploration, file reading, grep use haiku (~1x). Coding, review, test writing use sonnet (~4x). Architecture and complex multi-step reasoning use opus (~19x). The `model` parameter must always be specified when calling the Agent tool. Omitting it runs on the session default model (maximum cost). haiku sub-agents never spawn additional sub-agents. If a task cannot be resolved by haiku, the task was mis-classified.

**Layer 2: 2K token rule.** Any tool call expected to return more than 2K tokens is delegated to a sub-agent. The sub-agent reads, processes, and returns only a summary. The main context retains only the summary and a file path. Large JSON arrays are compressed 50%+ with headroom SmartCrusher before being fed in. MCP tool responses are the largest hidden source of context cost. Playwright page reads, GitHub API responses, and Notion thread reads can each dump thousands of tokens at once. Anything over 200 lines gets saved to `/tmp/ctx-{task-id}.json`, and only the schema and a sample reach the main context.

**Layer 3: No polling.** Running 24-hour monitoring as a Claude hot loop is prohibited. Polling tasks like price snapshots, state comparisons, and health checks run as launchd cron jobs and send a Slack alert only when anomalies are detected. This achieves the same effect at $0 Claude cost. The principle was established after a 9.4-hour monitor session consumed $381.

**Layer 4: Retro escalation.** Scheduled skills start on sonnet by default. `skill_model_policy.json` tracks the model and failure streak for each skill. If a skill fails consecutively `max_fail_streak` times, that skill alone is automatically promoted to opus and a notification is sent to Slack `#h-report`. A clean run resets the streak. Rather than promoting everything to opus, only skills that actually have a quality problem receive a targeted upgrade.

With all four layers interlocking, a typical day now stays sonnet-dominant. The same output volume is produced at significantly lower cost. The full figures for the cost control design are published in [LLM Cost Routing Guardrails](/en/llmops/llm-cost-routing-guardrails/).

Context hygiene also matters. Reading the same file repeatedly within a session accumulates `cache_read` tokens. Adding an unnecessary `cd` prefix to absolute-path commands does the same. `git` commands operate directly on the current working tree, so `cd` is never needed. Small habits like these stack up to meaningfully lower session cost [estimate].

---

## This Is the Product: Paxis and the AI Platform

This solo operational approach is exactly what ThakiCloud is productizing as Paxis. The goal is to make the autonomous agent runtime, skill ecosystem, self-evolution, governance, and cost control available to any engineer.

The operational system described so far proves two things.

The first is **that this operational approach actually works**. Not a concept or a paper -- a system used daily by a real solo engineer. The nightly evolution loop runs, cost guardrails control spending, and slash commands create the rhythm of the day.

The second is **that this approach is scalable**. A solo engineer managing 1,620 skills does not happen by manually touching each one. The system evolves itself, the router finds the right skill, and guardrails protect the budget. This structure works identically when scaled to a team.

Paxis is the work of turning this experience into a platform. Operators define skills, configure agents, and set cost policy -- then the runtime handles the rest. The AI Platform adds K8s-based workload orchestration (Kueue, ArgoCD) on top of that.

---

## Limitations and Lessons

To speak honestly.

**1,620 skills are also debt.** Well-crafted skills are assets, but neglected skills are ghosts consuming context tokens. When skill descriptions are too similar, the router gets confused. The nightly evolution loop cleans up this debt, but fundamentally, skills must have a clearly defined intent and boundary at creation time.

**Nightly self-evolution is slow.** It takes weeks for meaningful change to accumulate over a single night. Radical direction shifts require direct human intervention. Self-evolution improves incrementally in the current direction -- it does not change the direction.

**Cost guardrails are not perfect either.** If an MCP tool dumps thousands of tokens in a single response, context gets polluted immediately without a sandbox rule. Guardrails thicken not at the moment of design, but by extracting lessons after a problem occurs and embedding them.

**Multi-machine sync requires discipline.** If the home PC and office PC diverge on a feature branch, yesterday's home updates do not appear in today's office session. In practice, a session ran on a feature branch 25 commits behind origin/main, and a strategy directive applied the day before had not propagated -- leading to incorrect judgments. All work happens on main, and every completed task must be pushed. Simple, but ignoring it creates situations where decisions are made on stale code. Running `git log --oneline HEAD..origin/main` before starting a session has become habit.

**The opportunity cost of skills is easy to underestimate.** Creating a skill immediately feels like adding an asset. But the moment a skill enters the index, it pays context cost on every session. Two similar skills confuse the router. Before creating a skill, the first question should be: "Would an agent actually get this wrong without it?" If the answer is no, a single rule line is sufficient.

---

The operational system described in this post was not built in a day. It is the accumulation of encountering a problem, extracting a lesson, and embedding it in a rule or skill. Lessons recorded in the format `2026-XX-XX incident:` are scattered across all 36 rule files. Reading each rule's header immediately reveals which failure it came from.

If you want to run a solo AI team, the first investment should be skill quality and cost guardrails. Not flashy features -- the real leverage is routing that works quietly and an evolution loop that improves itself at night. I hope this post is useful as a reference for anyone thinking through automation at a similar scale.

In the next post, I plan to cover the design principles of the Paxis skill ecosystem -- particularly why the distinction between a thin harness and a fat skill matters.
