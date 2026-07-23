---
title: "Encode Domain Knowledge as Infrastructure: Redefining Automation in the Agent Era"
seo_title: "Domain Knowledge as Infrastructure - Automation in the Agent Era - Thaki Cloud"
seo_description: "Boris Cherny argues that automation, an engineer's highest leverage activity, matters even more in the agent era. Encoding domain knowledge beyond lint rules and e2e tests, into CLAUDE.md, skills, review rules, and memory, lets both agents and non engineers contribute from day one. We put ThakiCloud's own numbers, 52 rules, thousands of skills, 41 unattended automations, against this principle."
excerpt: "If an agent can't work productively in a codebase, that is not a failure of the model. It is a failure of automation. Moving domain knowledge into infrastructure is a natural extension of what engineers have always done."
date: 2026-07-16
tags:
  - agent-native-development
  - domain-knowledge
  - claude-md
  - agent-harness
  - developer-experience
  - agentops
  - paxis
  - automation
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/domain-knowledge-as-infrastructure/"
lang: en
---

## Overview

Boris Cherny, who built Claude Code at Anthropic, recently shared an idea worth sitting with. His starting point is simple. The best engineers have always spent a large share of their time automating their own work: better editor macros, lint rules that catch recurring mistakes, e2e suites that remove the need to smoke test by hand. This kind of automation was the highest leverage activity available because it multiplied output.

His observation goes one step further. In the agent era, this same automation matters even more than it used to. This post unpacks that claim in three parts, then closes with an honest audit of how much of it ThakiCloud actually practices, measured against our own repository. This is not self congratulation. It is a check on whether the infrastructure we built genuinely carries domain knowledge, or merely looks like it does.

## Why automation's standing has changed

The arrival of agents raised the value of automation for three reasons.

First, infrastructure and developer experience automation increases speed, and if you are running several agents at once, each of those agents also gets faster. More automation means more output per unit of time, except now the entity producing that output is not one person but several agents. The multiplier itself has changed scale.

Second, moving work into code raises efficiency. An agent can fix the same problem by hand every time it appears, but that burns tokens and still misses edge cases. Instead, once an agent writes a lint rule, a CI step, or a routine a single time, that entire class of problem is automated forever. This is the real meaning behind what people call a "loop." It is not about solving one instance of a problem, it is about automating the whole category of problem. None of this is a new idea. Engineers have worked this way for a long time.

Third, and most importantly, automation makes it easier for other people to contribute to a codebase. A scene that shows up more and more often is an engineer contributing on their very first day, carried by an agent's ability to navigate the codebase for them. Non engineers contribute just as effectively as engineers do. What used to block both groups was never a lack of automation. It was domain knowledge sitting only inside people's heads, the tacit knowledge you had to learn during onboarding.

## What it means to encode domain knowledge as infrastructure

Here is the core shift agents brought about. The domain knowledge that can be encoded into infrastructure is no longer limited to what lint rules, types, and tests can express.

In the past, only rules like "this function must never return nil" could be hard coded. Knowledge like "our team always checks this permission before calling this API," "this migration is only safe inside a deploy window," or "this screen must follow this architecture pattern" lived in a document somewhere, or only in a senior engineer's head.

Now nearly all of that knowledge can be captured in code comments, skills, CLAUDE.md rules, and memory. If I open a PR against an iOS codebase I don't know and a reviewer rejects it for using the wrong framework, or a designer built a feature that gets rejected because it doesn't follow the architecture pattern, these are not human mistakes. They are automation failures. If that knowledge had been embedded in the infrastructure, the agent would never have gotten it wrong in the first place.

This gives us a test to apply. Every rule, every sentence in a skill, has to pass the question: would the agent get this wrong without it? A sentence that fails that test is pure loss, paid for every session in context cost. A skill is not free. It is a tax.

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
<div class="d3-arch" data-arch-root id="nowledgeasinfrastructure-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 575, "height": 786, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 162, "y": 24, "w": 191, "h": 110, "title": ["Knowledge in people's", "heads", "tacit knowledge", "(passed on only through", "onboarding)"]}, {"id": "B", "x": 296, "y": 226, "w": 170, "h": 62, "title": ["Infrastructure", "lint · types · tests"]}, {"id": "C", "x": 179, "y": 676, "w": 177, "h": 78, "title": ["Infrastructure 2.0", "CLAUDE.md · skills", "review rules · memory"]}, {"id": "D", "x": 282, "y": 366, "w": 198, "h": 62, "title": ["Agents don't get it", "wrong in the first place"]}, {"id": "E", "x": 352, "y": 506, "w": 191, "h": 78, "title": ["Engineers and non", "engineers", "contribute from day one"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "encode", "curve": [[324, 134], [381, 180], [381, 180], [381, 226]], "off": "50%"}, {"src": "A", "dst": "C", "kind": "data", "label": "newly possible path<br/>in the agent era", "curve": [[190, 134], [134, 327], [134, 545], [206, 676]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "line": [381, 288, 381, 366]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[267, 676], [267, 630], [267, 467], [330, 428]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[410, 428], [447, 467], [447, 467], [447, 506]]}, {"src": "E", "dst": "C", "kind": "data", "label": "extract lessons from failures", "curve": [[447, 584], [447, 630], [447, 630], [350, 676]], "off": "50%"}]});
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
      const container = document.getElementById('nowledgeasinfrastructure-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nowledgeasinfrastructure-1';
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

The last arrow in this diagram is the important one. When an agent gets something wrong, the goal is not to patch it once and move on, but to re encode "why it went wrong" as a rule or a skill. That way the same class of failure disappears for good. Without this feedback loop, the system cannot keep improving on its own over time.

## What ThakiCloud actually does

That covers the argument. Now we turn the same question on ourselves. Does ThakiCloud's agent infrastructure really carry domain knowledge, or does it just look like it does. We measured the repository directly.

Our backend monorepo carries 52 always loaded standing rules (`.claude/rules/`), 3,536 lines in total. These rules are not generic coding style guidance. Most of them are lessons pulled out of specific incidents. The "macro data source" rule, for example, exists because a specific library once returned an exchange rate that was 25 won too high and a day stale, which caused a morning briefing to report the wrong number. Since then, code enforces that exchange rates come only from a designated authoritative source. A large share of our 52 rules open with a header like "incident on such and such date," and 18 of them carry a dedicated gotchas section. That is evidence that the loop from failure to documentation to enforced rule is actually running, not just described.

The skills that load on demand, including external plugins, number over 1,800. They package recurring workflows, report generation, code review, paper writing, deployment pipelines, into reusable form. A skill is not the same thing as a plain prompt. It is version controlled, it bundles scripts, templates, and known failure cases together, and it gets reused end to end from input through error recovery. The principle is to build capability into fat skills rather than a thin harness.

We have 63 role specific subagents, 13 auto triggered hooks, and 41 unattended automations (launchd) that run at fixed times with no human involved. Morning briefings, news digests, blog evolution, and self improving skills all fall into this bucket. The pipeline behind this very post is one of them. The workflow that produced the sentence you are reading right now enforces, in code, the process of drafting, stripping AI tells, unifying tone, and translating into three languages before publishing. The format is not improvised by the model. It is owned by deterministic code.

CLAUDE.md is not confined to a single top level repository. Counting submodules and sub packages, it exists in more than 20 locations. The frontend monorepo, the multi cluster mesh, and the AI assistant product each declare their own rules through their own CLAUDE.md. An agent working on the backend reads the backend's CLAUDE.md on demand, and an agent working on the frontend reads the frontend's. Knowledge is not piled into one place, it is placed where it is needed, following a pattern of progressive disclosure.

Taken together, the four encoding channels Boris Cherny names (code comments, skills, CLAUDE.md rules, memory) are all alive in our system. In particular, the loop that "feeds failures back as rules" is not decoration. It is genuinely fed by real incidents, and that is the strongest evidence we have that we are practicing this principle rather than just imitating it.

## What's still missing, and the counter case

In fairness, we should also look at the other side. This approach is not an unqualified good.

First, the infrastructure itself is a cost. 3,500 lines of always loaded rules consume tokens every single session. As rules accumulate, context bloats and the code that actually matters gets crowded out. That's why we delete any rule that fails the "would the agent get this wrong without it" test, and demote knowledge that isn't always needed from a standing rule down to an on demand skill. Encoding is not something to keep growing without limit, it is something that needs continuous dieting.

Second, encoded knowledge goes stale. A rule born from an incident six months ago can rest on an assumption that no longer holds. One of our own rules, in fact, was an absolute ban on "averaging down," rooted in an old story about trading a small speculative stock. It no longer fit our current portfolio context, so it was deleted and replaced with a different principle. Infrastructure needs weeding just as much as it needs planting.

Third, 1,800 skills are, by themselves, a source of noise. The more candidates there are, the higher the risk of loading the wrong one. Loading a skill just because its name partially overlaps degrades accuracy. That's why we narrow candidates through retrieval based routing and an explicit rule against forced matching. The sheer volume of encoding is never the same thing as quality, and that's a tradeoff we have to keep watching.

None of these limits undercut the principle itself. If anything, they show that practicing the principle properly means treating encoding and pruning as equally important work.

## Closing

Boris Cherny's conclusion is understated. Every team should write the CLAUDE.md, review rules, skills, and documentation that let an agent work productively in a codebase without any extra context. It sounds like an odd thing to ask for, but it is also a natural extension of what engineers have always done: automate, and turn domain knowledge into infrastructure.

As models get smarter and harnesses mature, this work gets easier. In the meantime, what every team needs to do is clear. Move the domain knowledge scattered across people's heads and documents into infrastructure that an agent can read and follow. Do that, and Claude writes better code, code review catches problems automatically, and the next person who works in this codebase can contribute more easily. ThakiCloud is building its platform, and the automation that runs it, on top of this principle.

## Source

- Boris Cherny, "Automation and the infrastructure of domain knowledge," X (formerly Twitter), [original post](https://x.com/bcherny/status/2077460395279692197)
