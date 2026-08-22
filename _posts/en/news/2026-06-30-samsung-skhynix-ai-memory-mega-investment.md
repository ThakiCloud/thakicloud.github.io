---
title: "Samsung & SK’s 4,755 Trillion KRW 10-Year Domestic Investment: Honam Memory Fabs to 15GW AI Data Centers"
excerpt: "On June 29, 2026, Samsung Electronics and SK hynix announced a combined 4,755 trillion KRW domestic investment over the next 10 years. Centered on four memory fabs in the southwestern region (800 trillion KRW) and SK's 15GW AI data center plan (1,000 trillion KRW), this post breaks down the announcement, examines the HBM supercycle and policy environment, and explores what rapidly expanding domestic AI infrastructure means for ThakiCloud's Kubernetes- and Kueue-based serving platform."
seo_title: "Samsung & SK 4,755 Trillion KRW Investment Announcement: Honam Fabs & AI Data Centers - Thaki Cloud"
seo_description: "Samsung 2,655 trillion + SK 2,100 trillion = 4,755 trillion KRW domestic investment announced. Covers the 800 trillion KRW southwestern memory fabs, SK's 1,000 trillion KRW 15GW AI data centers, the HBM supercycle, the Semiconductor Special Act, and ThakiCloud's K8s/Kueue serving perspective."
date: 2026-06-30
last_modified_at: 2026-06-30
disable_mathjax: true
tags:
  - samsung
  - sk-hynix
  - hbm
  - ai-memory
  - semiconductor
  - data-center
  - sovereign-ai
  - kubernetes
  - kueue
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "microchip"
canonical_url: "https://thakicloud.com/tech-blog/en/news/samsung-skhynix-ai-memory-mega-investment/"
categories:
  - news
published: false
---

On June 29, 2026, a landmark figure emerged at the Cheongwadae State Guest House. Samsung Electronics and SK hynix announced plans to invest a combined 4,755 trillion KRW domestically over the next 10 years. The declaration was made in person by Samsung Chairman Lee Jae-yong and SK Group Chairman Chey Tae-won at the "Republic of Korea Great Leap, Three National Mega-Projects Public Briefing" presided over by President Lee Jae-myung.

This post calmly unpacks what was announced that day: what will be built, where, and at what scale; the industrial trends and policies behind the numbers; and what it all means for operators of AI infrastructure.

![Bar chart comparing Samsung and SK's 10-year domestic investment plan against the government's annual budget]({{ '/assets/images/samsung-skhynix-ai-memory-mega-investment-results-en.webp' | relative_url }})

## What Was Announced

The announcement was not a standalone corporate IR event. It was a declaration of a national mega-project, which President Lee framed as a "Korean-style AI industrial revolution." Two groups are investing: Samsung Group pledged 2,655 trillion KRW and SK Group pledged 2,100 trillion KRW in domestic investment over 10 years, for a combined total of 4,755 trillion KRW, roughly 6.5 times the government's annual budget of approximately 728 trillion KRW.

Chairman Lee Jae-yong named Gwangju as a candidate site for the new semiconductor complex, stating: "We are considering Gwangju as a candidate site where incentive support is expected." Chairman Chey Tae-won emphasized his intention to transform Korea "from a country that consumes AI into a country that exports it." SK hynix CEO Kwak Noh-jung specifically requested the application of the Semiconductor Special Act to the Yongin cluster and improvements to regional living conditions.

One important context: 4,755 trillion KRW represents a cumulative planned figure spread over more than 10 years, not a near-term commitment. The two companies' current combined annual capital expenditure runs at roughly 70 trillion KRW (Samsung DS approximately 41 trillion, SK hynix approximately 29 trillion). Announcement scale and annual execution pace should be read separately.

> USD conversion note: The announced figure is denominated in Korean won, which is the reference to use. At an exchange rate of 1,380 KRW per USD, 4,755 trillion KRW is roughly 3.4 trillion USD.

## Investment Structure: 800 Trillion KRW Southwestern Fabs and 15GW Data Centers

Within the 4,755 trillion KRW total, the most binding commitment is the southwestern (Honam) memory fab plan. Samsung and SK will each contribute 400 trillion KRW, 800 trillion KRW in total, to build four new memory fabs (two per company). Samsung is considering Gwangju as its site. The remaining components break down as follows.

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
<div class="d3-arch" data-arch-root id="ixaimemorymegainvestment-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 750, "height": 767, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 341, "w": 170, "h": 78, "title": ["Samsung & SK 10-Year", "Domestic Investment", "4,755 Trillion KRW"]}, {"id": "B", "x": 272, "y": 157, "w": 163, "h": 62, "title": ["Samsung Electronics", "2,655 Trillion"]}, {"id": "C", "x": 290, "y": 482, "w": 128, "h": 62, "title": ["SK Group", "2,100 Trillion"]}, {"id": "B1", "x": 524, "y": 24, "w": 184, "h": 78, "title": ["Pyeongtaek & Yongin", "Semiconductors", "approx. 2,030 Trillion"]}, {"id": "B2", "x": 513, "y": 157, "w": 205, "h": 62, "title": ["Chungcheong HBM Packaging", "140 Trillion"]}, {"id": "C1", "x": 527, "y": 423, "w": 177, "h": 62, "title": ["AI Data Centers", "1,000 Trillion · 15GW"]}, {"id": "C2", "x": 527, "y": 540, "w": 177, "h": 62, "title": ["Yongin Semiconductors", "600 Trillion"]}, {"id": "C3", "x": 524, "y": 657, "w": 184, "h": 78, "title": ["Cheongju NAND Capacity", "Expansion", "100 Trillion"]}, {"id": "D", "x": 517, "y": 274, "w": 198, "h": 94, "title": ["Southwestern Memory Fabs", "(4 fabs)", "800 Trillion · Joint", "Samsung & SK"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[134, 341], [233, 188], [233, 188], [272, 188]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[145, 419], [233, 513], [233, 513], [290, 513]]}, {"src": "B", "dst": "B1", "kind": "data", "curve": [[383, 157], [474, 63], [474, 63], [524, 63]]}, {"src": "B", "dst": "B2", "kind": "data", "line": [435, 188, 513, 188]}, {"src": "C", "dst": "C1", "kind": "data", "curve": [[417, 482], [474, 454], [474, 454], [527, 454]]}, {"src": "C", "dst": "C2", "kind": "data", "curve": [[417, 544], [474, 571], [474, 571], [527, 571]]}, {"src": "C", "dst": "C3", "kind": "data", "curve": [[374, 544], [474, 696], [474, 696], [524, 696]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[402, 219], [474, 265], [474, 265], [517, 281]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[381, 482], [474, 378], [474, 378], [517, 361]]}]});
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
      const container = document.getElementById('ixaimemorymegainvestment-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ixaimemorymegainvestment-1';
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

The most notable item on the SK side is the AI data center plan. Led by SKT, the group intends to spend 1,000 trillion KRW by 2035 to build 15GW of AI data centers nationwide. Given that typical capex for a 1GW data center runs roughly $1 to $3 billion, a 1,000 trillion KRW figure for 15GW is broadly consistent. In addition, SK hynix will separately invest 100 trillion KRW in expanding NAND flash capacity at its Cheongju facility. Samsung has allocated approximately 2,030 trillion KRW to Pyeongtaek and Yongin semiconductor operations and 140 trillion KRW to HBM packaging in the Chungcheong region.

## Why Now, Why This Scale: The HBM Supercycle

The driving force behind these enormous numbers converges on a single technology: HBM, or High Bandwidth Memory. HBM is a high-value memory stacked directly onto AI accelerators, commanding a unit price five to seven times that of conventional DRAM. The global HBM market is forecast to grow from approximately $35 billion in 2025 to $54.6 to $58 billion in 2026, a jump of more than 58%.

The root of that demand lies in hyperscaler spending. Amazon, Microsoft, Google, Meta, and Oracle together exceeded $600 billion in AI infrastructure capex in 2026, with memory's share of that spending rising to approximately 30%, roughly four times the 8% share seen in 2023 to 2024. Backlog from NVIDIA Blackwell and Rubin demand alone has reached hundreds of billions of dollars, and the 2026 production output of the three HBM suppliers, SK hynix, Micron, and Samsung, is effectively sold out.

The critical insight is that the bottleneck is capacity, not capital. The constraint is not a lack of money to build; it is a lack of fabs to build in. That is why both companies are moving toward large-scale expansion simultaneously. SK hynix posted an operating margin of 47% in Q3 2025, and that profitability is now being recycled into Yongin and Cheongju facilities, creating a virtuous cycle.

## Policy Backing: The Semiconductor Special Act

Korea has historically supported its semiconductor industry through tax credits rather than direct cash subsidies as seen in the United States or Europe. The K-Chips Act passed in February 2025 raised the facility investment tax credit rate for large corporations from 15% to 20% and extended R&D credits through 2031. The combined tax benefit for the two companies is estimated at approximately 6 trillion KRW.

Layered on top is the Semiconductor Special Act, passed in January 2026. This legislation creates a legal basis for the state and local governments to directly support the construction of critical industrial infrastructure including power, water, and roads. Implementation is scheduled for Q3 2026. For the 800 trillion KRW Honam fabs to actually come online, the timely delivery of power and water infrastructure under this Special Act will be the decisive variable. CEO Kwak Noh-jung's direct request at the announcement for the Special Act to be applied to the Yongin cluster reflects exactly this concern.

## Global Competition: Three HBM Suppliers Expanding Simultaneously

| Company | Position | Recent Investment | HBM Status |
|---|---|---|---|
| SK hynix | Memory No. 1 | Yongin 600 trillion KRW, etc. | HBM share approx. 57%, HBM4 priority supply |
| Samsung Electronics | Memory challenger | Pyeongtaek & Yongin approx. 2,030 trillion KRW | HBM share approx. 35%, 50% capacity expansion in 2026 |
| Micron | Memory No. 3 | FY26 approx. $20 billion | 2026 HBM fully booked, HBM4 mass production in Q2 |
| TSMC | Foundry | Arizona $165 billion | CoWoS packaging sold out through 2026 |

All three HBM suppliers have their 2026 output sold out. The real question is 2027 to 2028. If sufficient Korean fab capacity is not online by then, the incremental demand for HBM4 and HBM5 could shift to Micron. On the foundry side, TSMC is committing $165 billion to Arizona alone, filling its CoWoS packaging capacity through 2026, while Intel has effectively withdrawn from HBM competition through its foundry restructuring.

## Power as the Real Bottleneck: Data Center Location Competition

Since Q1 2026, the primary bottleneck for AI infrastructure has shifted from chips to power. In the United States, approximately 7GW of data center projects have been delayed or cancelled due to power constraints. Paradoxically, this makes Korea's southwestern region and parts of the Middle East, where power and land remain available, increasingly attractive.

SK's plan to build 15GW of AI data centers nationwide for 1,000 trillion KRW by 2035 is not simply a real estate bet. When a memory manufacturer directly builds the data centers that will consume its HBM output, it can create its own demand and recover bargaining power in a supply chain where NVIDIA and hyperscalers currently set the terms. Samsung is moving in the same direction of vertical integration, with AI data center projects in Haenam and an AI server substrate factory in Sejong.

## Market Reaction

Immediately following the announcement, Samsung Electronics shares closed at 323,000 KRW after volatile trading, and on June 30 SK hynix reclaimed the top position in KOSPI market capitalization from Samsung Electronics. Some analysts drew parallels to the Cisco-Microsoft reversal during the 2000 dot-com bubble and raised concerns about a market peak. However, the majority of analysts withheld judgment on simple overheating, noting that "actual earnings and the macro environment need more observation." There is also a view that the valuation reversal is excessive, given that Samsung's 2026 operating profit estimate (361 trillion KRW) remains higher than SK hynix's (262 trillion KRW).

## ThakiCloud Perspective: The More Hardware Scales, the More the Software Layer Matters

The essence of this announcement is that Korea is vertically integrating AI infrastructure at the national level, and that connects directly to ThakiCloud's ai-platform business.

As domestic AI data centers expand to 15GW, the demand for multi-tenant infrastructure to train and serve models on top of that hardware grows with it. ThakiCloud targets exactly this layer with Kubernetes and Kueue-based GPU scheduling and vLLM serving. When fabs and data centers supply the hardware, a control plane is needed to safely isolate and run multiple customers' workloads on top of it.

The nature of the demand also works in our favor. National critical industries and public sector entities frequently need to operate models inside their own data centers rather than relying on external clouds, especially in security-sensitive environments. ThakiCloud's self-hosting, multi-tenant isolation, and cost-efficient serving align precisely with this sovereign AI demand.

And the most important shift is this: as HBM and high-performance GPUs proliferate, the axis of competition moves from "how much did you buy" to "how efficiently can you run it." GPU lifecycle management and queuing that prevents expensive accelerators from sitting idle ultimately determines cost. The software layer that runs the hardware created by 4,755 trillion KRW efficiently, that is exactly where ThakiCloud's value lies.

## Caveats and Counterarguments: Too Early for Pure Optimism

Reading this announcement as unambiguously positive would be a mistake. The counterarguments deserve an honest look.

First, 4,755 trillion KRW is a 10-year cumulative "plan," not an annualized figure with verified execution. The government event context may introduce upward bias, and the Yongin 622 trillion KRW cluster announced in 2024 has already experienced schedule delays. There is always a gap between announcement and execution.

Second, if the HBM supercycle reverses, today's expansion becomes tomorrow's oversupply. Memory is historically a sharply cyclical industry. If AI capex proves to be overinvestment as some analysts contend, the fabs coming online in 2027 to 2028 could coincide with a period of softening demand.

Third, if power and water infrastructure is not delivered on schedule, even an 800 trillion KRW fab investment will be delayed. Power is the leading cause of global data center delays, making this a concrete rather than abstract risk.

Finally, the valuation reversal has prompted warnings that market prices are running ahead of fundamentals. Announcement scale does not guarantee earnings.

## Summary

The framework of the June 29, 2026 announcement is clear. Samsung and SK will invest 4,755 trillion KRW domestically over 10 years, anchored by 800 trillion KRW in southwestern memory fabs and SK's 15GW AI data centers. The HBM supercycle is the engine driving all of it, and success will depend on the speed of power and water infrastructure delivery.

As Korea builds AI hardware at national scale, the value of the software layer that runs that hardware efficiently grows alongside it. ThakiCloud is positioning itself at exactly that intersection, with K8s- and Kueue-based serving and sovereign infrastructure.

## Sources

- Financial News, Southwestern Fabs Samsung & SK 4,755 Trillion (2026-06-29): [https://www.fnnews.com/news/202606291837098645](https://www.fnnews.com/news/202606291837098645)
- Newsis, Samsung & SK 800 Trillion Honam Semiconductor Hub (2026-06-29): [https://www.newsis.com/view/NISX20260629_0003687807](https://www.newsis.com/view/NISX20260629_0003687807)
- Aju News, SKT 15GW AI Data Centers (2026-06-29): [https://www.ajunews.com/view/20260629171803513](https://www.ajunews.com/view/20260629171803513)
- Hankyung, Yongin 600 Trillion & Cheongju 100 Trillion (2026-06-29): [https://www.hankyung.com/article/2026062943107](https://www.hankyung.com/article/2026062943107)
- CNBC, South Korea Samsung SK Hynix mega-projects (2026-06-29): [https://www.cnbc.com/2026/06/29/samsung-sk-hynix-reported-1point3-reported-trillion-spending-plans.html](https://www.cnbc.com/2026/06/29/samsung-sk-hynix-reported-1point3-reported-trillion-spending-plans.html)
- SK hynix, 2026 Market Outlook (HBM Supercycle): [https://news.skhynix.com/2026-market-outlook-focus-on-the-hbm-led-memory-supercycle/](https://news.skhynix.com/2026-market-outlook-focus-on-the-hbm-led-memory-supercycle/)
- TrendForce, Micron CapEx $20B & 2026 HBM booked (2025-12-18): [https://www.trendforce.com/news/2025/12/18/news-micron-hikes-capex-to-20b-with-2026-hbm-supply-fully-booked-hbm4-ramps-2q26/](https://www.trendforce.com/news/2025/12/18/news-micron-hikes-capex-to-20b-with-2026-hbm-supply-fully-booked-hbm4-ramps-2q26/)
- Policy Briefing, Semiconductor Special Act Passed by National Assembly (2026-01-30): [https://www.korea.kr/briefing/pressReleaseView.do?newsId=156742072](https://www.korea.kr/briefing/pressReleaseView.do?newsId=156742072)
