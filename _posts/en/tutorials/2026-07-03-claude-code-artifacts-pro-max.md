---
title: "Claude Code Artifacts Come to Pro and Max: Your Session Becomes a Living Web Page"
excerpt: "Claude Code artifacts have expanded beyond Team and Enterprise to the Pro and Max plans. We break down the feature that turns a coding session into a live, shareable web page, and look at how ThakiCloud's Paxis and ai-platform can absorb the pattern."
tags:
  - claude-code
  - artifacts
  - agent-native
  - developer-experience
  - paxis
date: 2026-07-03
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/technique/claude-code-artifacts-pro-max/"
categories:
  - tutorials
---

![Abstract image of session outputs assembling into a single living page in layered depth]({{ '/assets/images/claude-code-artifacts-pro-max-hero.webp' | relative_url }})
*The progress of a coding session condenses into one shareable page that updates in real time.*

## Overview

When a coding agent finishes hours of work, showing the result to someone else is still surprisingly clumsy. You capture terminal logs and paste them, summarize the changes by hand, or build a separate dashboard. Explaining the work often takes more effort than the work itself.

In July 2026, Anthropic expanded the Artifacts feature in Claude Code to the Pro and Max plans. A capability that had been limited to Team and Enterprise is now open to individual developers. The idea is simple. When you ask for an artifact, Claude writes the code, publishes it live to claude.ai, and keeps updating that page in real time while the session runs. The page is private to your account and fully self-contained.

This post explains exactly what Claude Code artifacts are, why the Pro and Max expansion matters, and how the pattern can be absorbed from the perspective of ThakiCloud's agent platform Paxis and its AI infrastructure ai-platform.

## What Claude Code Artifacts Are

Artifacts originally rendered code or documents in a separate panel inside a claude.ai conversation. The artifacts that just arrived in Claude Code are a little different. Instead of the output of a single exchange, they turn the progress of an entire coding session into one living visual page.

Anthropic lists four example uses: PR walkthroughs, system explainer pages, dashboards, and release checklists. What they share is that each is a human-readable summary of what is happening right now. And while the session continues its work, that page updates itself.

The flow from work to publication looks like this.

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
<div class="d3-arch" data-arch-root id="laudecodeartifactspromax-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 632, "height": 930, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 106, "y": 24, "w": 177, "h": 62, "title": ["Developer requests an", "artifact"]}, {"id": "B", "x": 102, "y": 164, "w": 184, "h": 62, "title": ["Claude Code writes the", "code"]}, {"id": "C", "x": 92, "y": 304, "w": 205, "h": 46, "title": "Publish live to claude.ai"}, {"id": "D", "x": 97, "y": 428, "w": 195, "h": 52, "title": "Session keeps running"}, {"id": "E", "x": 24, "y": 580, "w": 205, "h": 46, "title": "Page updates in real time"}, {"id": "F", "x": 284, "y": 572, "w": 163, "h": 62, "title": ["Self-contained page", "finalized"]}, {"id": "G", "x": 267, "y": 712, "w": 198, "h": 46, "title": "Share the published link"}, {"id": "H", "x": 128, "y": 836, "w": 212, "h": 62, "title": ["Recipient views without an", "account"]}, {"id": "I", "x": 395, "y": 836, "w": 205, "h": 62, "title": ["Account holder remixes an", "editable copy"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [194, 86, 194, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [194, 226, 194, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [194, 350, 194, 428]}, {"src": "D", "dst": "E", "kind": "data", "label": "work state changes", "curve": [[194, 480], [194, 526], [194, 526], [147, 580]], "off": "50%"}, {"src": "E", "dst": "D", "kind": "data", "curve": [[115, 580], [88, 526], [88, 526], [156, 480]]}, {"src": "D", "dst": "F", "kind": "data", "label": "complete", "curve": [[256, 480], [366, 526], [366, 526], [366, 572]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [366, 634, 366, 712]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[317, 758], [234, 797], [234, 797], [234, 836]]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[414, 758], [497, 797], [497, 797], [497, 836]]}]});
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
      const container = document.getElementById('laudecodeartifactspromax-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodeartifactspromax-1';
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

Two design decisions stand out here. First, the page is self-contained. Without an external build pipeline or hosting setup, everything it needs lives in the single published page. Second, the default is private. The page belongs to your account, and nobody else can see it until you press publish and share the link.

## Why the Pro and Max Expansion Matters

The feature itself had been available on Team and Enterprise for a few months. The key change now is that the plan boundary has moved down.

To be precise: regular artifacts created in a claude.ai conversation could already be published on every plan, including Free, Pro, and Max. The artifacts that turn a Claude Code session into a live page, on the other hand, were Team and Enterprise only. That boundary has now extended to Pro and Max. Without an organization seat, an individual developer can turn their own session into a shareable page.

Why this matters becomes clear when you look at how individual developers actually work. When an open-source contributor finishes a long refactor, they need a way to convey the context of the change to a reviewer. The same holds for a solo developer running a side project who wants to track their own progress or demo it to a peer. Until now, these users could not touch the feature unless they were tied to an organization plan. The Pro and Max expansion closes that gap.

One more note: over the same period, Anthropic also temporarily raised the weekly Claude Code usage limits for Pro, Max, and Team. Access and headroom opened together, which gives individual developers real room to try the feature.

## How It Works in Practice

Using it feels conversational. During a session, when you say "turn this work into an artifact," Claude Code generates a page capturing the current progress and publishes it to claude.ai. Open the returned link and you see a visual page summarizing the work so far, and as the session keeps running, the page updates without a refresh.

Sharing happens through the publish button at the bottom of the artifact panel. Whoever receives the link can view the page without a Claude account. Someone who does have an account can use remix to make their own editable copy. In other words, a single artifact is both a read-only shared object and a starting point that someone else can pick up and develop.

The privacy model is also clear. A page created in Claude Code is private to your account by default. It is exposed externally only the moment you publish and hand over a link, and until then only you can see it. For developers handling sensitive internal work, this default matters, because there is no path to accidental exposure.

The most practical combination in this flow is the PR walkthrough. After finishing a long change, requesting an artifact yields a page covering what changed and why, which files are affected, and how it was verified. The reviewer can grasp the context from this page before reading the diff. Incident response pages and release checklists work the same way, letting the agent maintain a human-readable summary on its own.

## What It Means for ThakiCloud

The real implication of this feature goes beyond the convenience of a single tool. The pattern itself, "keep an agent's work output as a human-readable, shareable artifact, and keep it live," is a core challenge for any agent platform.

**The Paxis lens (agent output as a first-class resource).** ThakiCloud's Paxis is an Agent-Native Cloud control plane that runs on top of ai-platform and treats Skills, Tools, Policies, and Audit Logs as first-class resources. What Claude Code artifacts demonstrate is a way to expose an agent's intermediate and final output as a separate observation channel. When a DAG of multiple agents in Paxis performs a long task, condensing each node's progress into a human-readable live page lets an operator grasp the flow without scrolling logs. Combine that with Paxis's policy gates and audit logs, and the artifact becomes a controlled output that is traceable down to "who made and shared what, and when." In the same spirit as Anthropic's default-private artifacts, Paxis can layer policy-based access control onto output sharing and scale it to the organization level.

**The ai-platform lens (internal operations pages).** On the infrastructure side, self-contained pages fit internal dashboards and incident pages well. ThakiCloud's ai-platform runs K8s, Kueue GPU scheduling, and multi-tenant vLLM serving, and the batch and serving workloads that run on it need a channel to convey state to people. If you let an agent maintain a release checklist or a deployment progress page on its own, you gain operational visibility in on-prem and sovereign environments without adding a separate observability stack. Because self-containment reduces the dependence on external hosting, it is a light burden even in customer environments with strong air-gap requirements.

The two lenses complement each other. If ai-platform runs agent workloads at low cost and Paxis treats their output as shareable artifacts under policy and audit, you can reproduce the experience of "an agent works and its result immediately becomes something a human can read" on your own platform.

## Limitations and Counterpoints

There are clear points where expectations should be tempered.

First, the feature is tied to publishing on claude.ai. Because the page is hosted on Anthropic infrastructure, it is hard to use as-is in a fully air-gapped environment or where data exfiltration is prohibited. Customers with strong sovereignty requirements need a self-hosted alternative, and that is precisely the gap an on-prem-oriented platform like ThakiCloud can fill.

Second, self-contained pages are excellent for simple summaries and dashboards, but they are limited for complex interactions or large-scale data integration. A published artifact is essentially a lightweight frontend and does not replace heavy backend logic.

Third, real-time updates hold only while the session is alive. Once the session ends, the page freezes as a snapshot from that moment. If you need a continuously updating operations dashboard, you still need a separate pipeline.

In short, the Pro and Max expansion of Claude Code artifacts significantly lowers the barrier for individual developers to turn agent work into shareable output. The constraints of hosting and persistence remain, and that is exactly where an agent platform with policy, audit, and on-prem capabilities offers complementary value. Absorb the convenience of the tool, and fill the areas that require control and sovereignty with your own platform. That is the realistic approach.

## Sources

- [ClaudeDevs (@ClaudeDevs) announcement post](https://x.com/ClaudeDevs/status/2072770790114914317)
- [Publish and share artifacts (Claude Help Center)](https://support.claude.com/en/articles/9547008-publish-and-share-artifacts)
- [What are artifacts and how do I use them? (Claude Help Center)](https://support.claude.com/en/articles/9487310-what-are-artifacts-and-how-do-i-use-them)
