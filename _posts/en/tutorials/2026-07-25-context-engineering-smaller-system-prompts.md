---
title: "It Does Better With the Examples Removed: The New Rules of Context Engineering for the Latest Models"
seo_title: "What Cutting the Claude Code System Prompt by 80% Teaches Us | New Rules of Context Engineering | ThakiCloud"
seo_description: "Anthropic cut the Claude Code system prompt by more than 80% for the latest generation of models. The smarter the model, the better it does when you strip out examples and prohibition lists. We explain why examples now become a shackle, how to rewrite a system prompt, and what it means for the ThakiCloud skill harness."
excerpt: "The smarter a model gets, the more examples and do-not lists become a shackle rather than help. We look at why Anthropic cut its system prompt by 80% and why you should re-trim your prompt every time a new model ships."
date: 2026-07-25
tags:
  - 컨텍스트 엔지니어링
  - 프롬프트 엔지니어링
  - 시스템 프롬프트
  - Claude Code
  - 에이전트 하네스
  - LLM
  - 프롬프트 설계
  - 베스트 프랙티스
  - 개발 생산성
  - AI 코딩
categories: [tutorials]
author_profile: true
toc: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/context-engineering-smaller-system-prompts/"
---

If you write and maintain system prompts yourself, you have probably felt at some point that results get better as you pack in more examples and rules. Yet the direction Anthropic recently shared flips that intuition head-on. The conclusion first: once a model is smart enough, examples and prohibition rules become not a help but a shackle that actually shaves off performance, and so the new best practice is to remove from the prompt rather than add to it. Anthropic applied this very principle to its own product and cut the Claude Code system prompt by more than 80%. This post lays out why that happened and how we should rewrite our prompts.

## Why Read This

This post is written for developers who design and maintain system prompts, and for platform owners who operate an agent harness. The core conclusion is this: when dealing with the latest generation of models, you get better results by conveying only the concise context of the outcome you want and leaving the rest to the model's judgment, rather than by attaching examples and lengthening lists of "do not do this, do not do that." Knowing this lets you break the habit of inheriting a prompt with each new model and endlessly bolting on more, and instead make trimming the prompt a regular checklist item.

## Overview

For the past few years, the common wisdom of prompt engineering was "be specific, be plentiful." Attaching two or three examples of the desired output, listing what not to do, and nailing down the format were seen as the path to stable results. And for the previous generation of models, this approach worked well, because a human was filling in with examples and rules the gaps the model could not fill on its own.

But as models grew smarter across generations, those gaps shrank. Anthropic trimmed the Claude Code system prompt by more than 80% for the latest generation of models and reported no measurable drop in coding evaluations. Even after stripping out a large body of examples and rules, results did not get worse. In some cases the diagnosis was that examples had been caging the model into a particular mold and blocking a better answer.

## Why Examples Become a Shackle

The heart of Anthropic's explanation is simple. The smarter a model gets, the fewer instructions, fewer constraints, and fewer examples it needs. When you attach an example, the model reads it as "so this is the shape you want" and fits itself to that shape. The problem arises when the latest model is more creative than that example. The example becomes a ceiling that pulls down the model's better answer.

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
<div class="d3-arch" data-arch-root id="ringsmallersystemprompts-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 794, "height": 648, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 161, "y": 24, "w": 198, "h": 94, "title": ["Old-generation approach", "3 examples + prohibition", "list +", "rigid format"]}, {"id": "B", "x": 152, "y": 209, "w": 216, "h": 68, "title": ["Applied to the", "latest-generation model?"]}, {"id": "C", "x": 284, "y": 382, "w": 212, "h": 78, "title": ["Model caged in the example", "mold", "a better answer is blocked"]}, {"id": "D", "x": 31, "y": 390, "w": 198, "h": 62, "title": ["Negative rules", "shave off result quality"]}, {"id": "E", "x": 550, "y": 196, "w": 212, "h": 94, "title": ["New-generation approach", "only the desired context", "concisely +", "judgment left to the model"]}, {"id": "F", "x": 553, "y": 382, "w": 205, "h": 78, "title": ["Model generates its own", "optimal", "output to fit the context"]}, {"id": "G", "x": 298, "y": 538, "w": 184, "h": 78, "title": ["Trim the prompt", "re-check with each new", "model"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [260, 118, 260, 209]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"Examples limit creativity\"", "curve": [[307, 277], [390, 336], [390, 336], [390, 382]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "\"Prohibition lists lower quality\"", "curve": [[212, 277], [130, 336], [130, 336], [130, 390]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [656, 290, 656, 382]}, {"src": "C", "dst": "G", "kind": "data", "line": [390, 460, 390, 538]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[130, 452], [130, 499], [130, 499], [298, 549]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[656, 460], [656, 499], [656, 499], [482, 550]]}]});
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
      const container = document.getElementById('ringsmallersystemprompts-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ringsmallersystemprompts-1';
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

Prohibition rules carry a similar trap. Listing "do not do this, do not do that" at length can actually lower result quality on the latest models. Anthropic now says it steers models in the desired direction through context rather than blocking them with rigid prohibition rules. Instead of building walls with rules, it gives the context of what it wants and lets the model judge within that.

So when a new model arrives, the advice is to trim the prompt rather than lengthen it. Much of the examples and rules accumulated for the previous model are, for the new model, an unnecessary burden or, worse, a performance-shaving shackle.

## That Does Not Mean Throwing Out Every Rule

Here an important balance must be noted. This advice is about dealing with the strongest, latest generation of models. For cheaper model tiers, or for batch work where the output format must be exactly the same on every call, the story is different. In scheduled outputs that must not waver in shape, such as a report that has to come out in the same form every day, or a JSON contract, a deterministic skeleton is still required.

Inside ThakiCloud we handle these two axes separately. For work where creativity of content is the deliverable, we give the strong model only context and widen its degrees of freedom; but numbers, enumerated values, and rendering format are owned by deterministic code, not the model. In other words, the advice to remove examples and the discipline to fix format in code do not conflict. The former is the domain of judgment and creation; the latter is the domain of format and aggregation. Lump the two into a single prompt without distinction, and you get the worst combination: examples that shackle the strong model and a format that wavers for the weak one.

## Implications for ThakiCloud Products

This discussion leads straight into practice from our Paxis viewpoint. Paxis is ThakiCloud's Agent-Native Cloud, a control plane that treats Skills, Tools, and Policies as first-class resources. It selects from more than 960 skills via BM25 and runs them in isolated sandboxes. Here, each skill's specification and system prompt are precisely the subject of the context engineering this post describes.

Carrying this post's lesson into the Paxis skill harness yields two practices. First, in skills that deal with strong models, minimize examples and prohibition lists and leave only the concise context and boundaries of the desired outcome. Keep the harness thin and the knowledge thick, but make that knowledge a set of judgment criteria distilled from failures, not a parade of examples. Second, when introducing a new model, do not automatically inherit skill specs and keep bolting on; instead, run a check that trims the examples and rules that have become unnecessary. This is the same idea as Anthropic's advice to trim the prompt with each new model.

There is a gain from the infrastructure ai-platform lens too. A shorter system prompt means fewer input tokens per call, which translates directly into cost savings in a K8s-based multi-tenant serving environment. Trimming a prompt is a rare piece of work that improves quality and cost at the same time.

## Limitations and Counterarguments

Accepting this advice uncritically is dangerous. First, "remove the examples" is limited to strong, latest models and does not transfer as-is to lower-capability models or to work with strict format requirements. Second, whether performance actually holds after stripping examples must be confirmed by evaluation. Anthropic's report of no drop in coding evaluations was itself a measured result, not a decision made on intuition alone. Skip evaluation while shrinking the prompt, and you may miss an invisible quality drop. Third, this direction leans on the characteristics of a specific model family, so we cannot conclude that the same margin holds for other vendors' models or for open-weight models.

## Wrap-Up

Boiled down to one sentence, the new rule of context engineering is this: when dealing with the latest models, do not try to fill the prompt by lengthening it; trim it and leave it to the model's judgment. Examples and prohibition lists were a safety net for the previous generation, but for this generation they can be a ceiling that blocks a better answer. That said, this advice is limited to strong models and the domain of creation; for work where format must not waver, a deterministic skeleton is still required. The next time you introduce a new model, before worrying about what more to add to the prompt, check first what you can remove. And after removing, always confirm with evaluation. That is how you make this shift your own, safely.

## Sources

- The new rules of context engineering for Claude 5 generation models, Anthropic (<https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models>)
- A Fireside Chat with Cat and Thariq from the Claude Code team, Simon Willison (<https://simonwillison.net/2026/Jul/21/cat-and-thariq/>)
