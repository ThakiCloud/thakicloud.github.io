---
title: "More Skills, Worse Agents: Skill Shadowing and the Selection Bottleneck"
excerpt: "Recent work shows agent performance can drop as skill libraries grow. arXiv 2605.24050 decomposes the decline into skill shadowing and context overhead, and finds the real bottleneck is wrong skill selection, not context size. We look at how ThakiCloud Paxis's skill harness blocks this in practice with BM25 retrieval and an abstain gate, with real bench numbers."
seo_title: "Skill Shadowing: Why Bigger Skill Libraries Make Agents Worse | Thaki Cloud"
seo_description: "Built on arXiv 2605.24050 'More Skills, Worse Agents?', this post separates skill shadowing from context overhead and shows how ThakiCloud Paxis's skill harness stops the selection bottleneck with BM25 retrieval and an abstain gate, backed by real bench numbers."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - agent-skills
  - skill-retrieval
  - llm-agents
  - skill-shadowing
  - paxis
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "layer-group"
canonical_url: "https://thakicloud.com/tech-blog/en/research/agent-skill-shadowing-library-selection/"
categories:
  - research
published: false
---

## Overview

Handing an agent more skills feels like it should make it more capable, but recent research reports the opposite. As a skill library grows, an agent's success rate on the same tasks can actually fall. arXiv 2605.24050, "More Skills, Worse Agents? Skill Shadowing Degrades Performance When Expanding Skill Libraries," confronts this paradox head-on and reports that task pass rate drops by up to 21% when scaling from a small set of helpful skills to a 202-skill library.

This is an operational reality, not an academic curiosity. ThakiCloud's Agent-Native Cloud, Paxis, already manages over 960 skills and must decide, on every request, which of them to load. Adding skills is easy; picking the right one from a swollen library gets steadily harder. This post uses skill shadowing as a lens to name that bottleneck, then shows how the Paxis skill harness blocks it in practice with retrieval and an abstain gate, backed by real measurements.

## What Is Skill Shadowing

A skill library lets an LLM agent load task-specific instructions on demand. The goal is to let a non-expert user solve domain tasks in natural language without knowing which skills exist or how they work internally. The trouble begins as the library grows.

The core contribution of arXiv 2605.24050 is to decompose the performance drop into two effects. The first is **skill shadowing**: as the library grows, similarly described skills collide and the agent picks the wrong skill more often. The second is **context overhead**: skill descriptions fill the context and degrade execution quality even when the selection was correct.

The paper's conclusion cuts against intuition. The primary culprit is not the bloated context but **the wrong skill selection itself**. In other words, the bottleneck is not "the model has to read too much text" but "the model cannot pick the right skill among lookalike descriptions." That diagnosis changes the response. Compressing context is not enough; you need a retrieval step that narrows candidates and selects precisely in the first place.

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
<div class="d3-arch" data-arch-root id="hadowinglibraryselection-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 651, "height": 1130, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 299, "y": 24, "w": 120, "h": 46, "title": "User request"}, {"id": "B", "x": 272, "y": 148, "w": 174, "h": 52, "title": "Skill library size"}, {"id": "C", "x": 428, "y": 602, "w": 191, "h": 62, "title": ["Relevant skill selected", "correctly"]}, {"id": "D", "x": 124, "y": 292, "w": 212, "h": 62, "title": ["Similar skill descriptions", "collide"]}, {"id": "E", "x": 270, "y": 446, "w": 142, "h": 78, "title": ["Skill shadowing", "more wrong-skill", "selections"]}, {"id": "F", "x": 24, "y": 446, "w": 191, "h": 78, "title": ["Context overhead", "execution degrades even", "when correct"]}, {"id": "G", "x": 124, "y": 602, "w": 212, "h": 62, "title": ["Task pass rate falls up to", "21 percent"]}, {"id": "H", "x": 284, "y": 756, "w": 149, "h": 62, "title": ["Retrieval narrows", "candidates first"]}, {"id": "I", "x": 274, "y": 896, "w": 170, "h": 62, "title": ["Abstain gate rejects", "low-score skills"]}, {"id": "J", "x": 277, "y": 1036, "w": 163, "h": 62, "title": ["Execute in isolated", "sandbox"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [359, 70, 359, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "A few useful skills", "curve": [[418, 200], [524, 323], [524, 485], [524, 602]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Scaled to hundreds", "curve": [[312, 200], [230, 246], [230, 246], [230, 292]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "curve": [[275, 354], [341, 400], [341, 400], [341, 446]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[186, 354], [120, 400], [120, 400], [120, 446]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[341, 524], [341, 563], [341, 563], [279, 602]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[120, 524], [120, 563], [120, 563], [181, 602]]}, {"src": "C", "dst": "H", "kind": "data", "curve": [[524, 664], [524, 710], [524, 710], [425, 756]]}, {"src": "G", "dst": "H", "kind": "event", "label": "diagnosis", "curve": [[230, 664], [230, 710], [230, 710], [307, 756]], "off": "50%"}, {"src": "H", "dst": "I", "kind": "data", "line": [359, 818, 359, 896]}, {"src": "I", "dst": "J", "kind": "data", "line": [359, 958, 359, 1036]}]});
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
      const container = document.getElementById('hadowinglibraryselection-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'hadowinglibraryselection-1';
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

This flow overlaps precisely with a problem we already faced. Stuffing the full skill list into the prompt breaks the moment the count passes a few hundred. Instead of endlessly growing the library, you must switch to retrieving only the top candidates per request.

## Why This Matters Now

The scale problem is not confined to one paper. The SkillRet benchmark (arXiv 2605.05726), released around the same time, assembles 17,810 public agent skills into a large-scale retrieval benchmark organized under a two-level taxonomy of 6 major and 18 sub-categories. Skills are now accumulating at the scale of tens of thousands, and retrieving the right one from that pool has become a research problem in its own right.

In short, a gap is opening between the pace at which communities add skills and the ability to select them accurately. The shadowing work shows quantitatively that this gap turns into real performance loss, while benchmarks like SkillRet supply a common yardstick to measure it. Both point to a single practical prescription: **treat retrieval and selection as first-class problems, separate from growing the library.**

## Implications for ThakiCloud Products

This research direction maps exactly onto a design the Paxis skill harness already implements. Paxis is ThakiCloud's Agent-Native Cloud and treats skills as first-class resources. Rather than pushing the entire skill list on every request, it narrows candidates to the top matches with BM25 lexical retrieval and loads only those. That is the first line of defense against skill shadowing. When the candidate set shrinks from hundreds to a few, the room for lookalike descriptions to collide shrinks with it.

The second line of defense is the **abstain gate**. When the top retrieval score falls below a threshold, no skill is forced; the request falls through to native handling. If the essence of skill shadowing is "picking a plausible wrong skill when unsure," the abstain gate is the mechanism that deterministically blocks that unsure match in code. Rather than trusting the model to judge "this is ambiguous," a score threshold owns the decision.

Our skill-retrieval harness's actual measurements show the design works. On our internal SRA bench (63 cases), Recall@5 was 82.2%, the gated accuracy with the abstain gate applied was 66.7%, Top-1 was 40.0%, and hallucination (inventing a nonexistent skill to match) was 0%. The 0% hallucination in particular is a direct effect of the abstain gate: no matter how large the library grows, it neither fabricates a missing skill nor forces a below-threshold match.

On top of this sit Paxis's isolated sandbox execution, policy gates, and audit logs. Even if a wrong skill is occasionally selected, its execution happens in an isolated environment and every action is recorded in the audit log. Even when skill shadowing does not vanish entirely, its blast radius is contained at the execution boundary. The bottleneck the research diagnoses (selection failure) and its downstream risk (wrong execution) are blocked in three layers: retrieval, gate, and isolation.

## Limitations and Counterpoints

Both the research and our design have clear limits. First, the 21% drop in arXiv 2605.24050 is a value under a specific setup (a 202-skill library) and varies greatly with the quality and overlap of skill descriptions and the task domain. Describe skills well and keep them from overlapping, and the drop shrinks at the same scale. The precise lesson is not "do not add skills" but "manage description quality and retrieval together."

Second, BM25 lexical retrieval is not a panacea. For queries in pure Korean terminology that lack English expansion vocabulary, it can fail to surface the right skill, and our bench's Top-1 of 40.0% leaves plenty of room to improve. Reinforcements like embedding ensembles are on the table, but whether they justify giving up the determinism and low cost of a single signal is a separate call. Before making retrieval heavier, improving the skill descriptions themselves usually yields the larger gain.

Third, the abstain gate reduces to a threshold-tuning problem. Too high, and it excludes useful skills, hurting coverage; too low, and it fails to block shadowing. The 0% hallucination result is a product of a conservatively set threshold, and it comes at the cost of missing some legitimate matches. Ultimately, running a skill library is not a question of "how much to grow it" but of "how to balance retrieval, gate, and description quality," and the shadowing work is a quantitative warning that this balance starts to wobble at a smaller scale than you would expect.

## Sources

- More Skills, Worse Agents? Skill Shadowing Degrades Performance When Expanding Skill Libraries, arXiv 2605.24050 (<https://arxiv.org/abs/2605.24050>)
- SkillRet: A Large-Scale Benchmark for Skill Retrieval in LLM Agents, arXiv 2605.05726 (<https://arxiv.org/abs/2605.05726>)
