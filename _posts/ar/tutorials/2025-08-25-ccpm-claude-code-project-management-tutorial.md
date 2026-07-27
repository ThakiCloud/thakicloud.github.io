---
title: "دليل CCPM الشامل: تحويل PRDs إلى كود الإنتاج مع Claude Code PM"
excerpt: "إتقان نظام إدارة مشاريع Claude Code الثوري الذي يحول PRDs إلى epics، وepics إلى GitHub issues، وissues إلى كود إنتاج مع تتبع كامل وتنفيذ متوازي."
seo_title: "دليل CCPM: إدارة مشاريع Claude Code الكاملة - Thaki Cloud"
seo_description: "تعلم CCMP (Claude Code Project Management) - نظام مختبر للتطوير المُوجّه بالمواصفات باستخدام GitHub Issues، Git worktrees، ووكلاء AI متوازيين."
date: 2025-08-25
tags:
  - claude-code
  - إدارة-المشاريع
  - ai-agents
  - github
  - سير-العمل
  - التطوير-بالمواصفات
author_profile: true
toc: true
toc_label: "محتويات الدليل"
lang: ar
permalink: /ar/tutorials/ccpm-claude-code-project-management-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/ccpm-claude-code-project-management-tutorial/"
published: false
categories:
  - tutorials
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة: تجاوز البرمجة بالحدس

كل فريق تطوير يواجه نفس قتلة الإنتاجية:

- **اختفاء السياق** بين الجلسات، مما يضطر إلى إعادة الاكتشاف المستمر
- **العمل المتوازي يخلق تضارباً** عندما يعمل مطورون متعددون على نفس الكود
- **انحراف المتطلبات** عندما تتجاوز القرارات الشفهية المواصفات المكتوبة
- **التقدم يصبح غير مرئي** حتى النهاية

[Claude Code Project Management (CCPM)](https://github.com/automazeio/ccpm) يحل كل هذه المشاكل بنهج ثوري يغير طريقة عمل التطوير بمساعدة الذكاء الاصطناعي.

### ما الذي يجعل CCPM ثورياً؟

تدفقات العمل التقليدية لـ Claude Code تعمل في عزلة - مطور واحد يعمل مع AI في بيئته المحلية. CCPM يكسر هذا القيد باستخدام **GitHub Issues كقاعدة بيانات** و**Git worktrees للتنفيذ المتوازي**.

| التطوير التقليدي | نظام CCPM |
|-----------------|-----------|
| فقدان السياق بين الجلسات | **سياق مستمر** عبر كل العمل |
| تنفيذ تسلسلي للمهام | **وكلاء متوازيون** على مهام مستقلة |
| "برمجة بالحدس" من الذاكرة | **موجّه بالمواصفات** مع تتبع كامل |
| تقدم مخفي في الفروع | **مسار تدقيق شفاف** في GitHub |
| تنسيق يدوي للمهام | **تحديد أولويات ذكي** |

## نظرة عامة على هيكل النظام

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
<div class="d3-arch" data-arch-root id="rojectmanagementtutorial-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1277, "height": 1126, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 535, "y": 722, "w": 545, "h": 124, "label": "التطوير المحلي", "lx": 547, "ly": 740}, {"x": 24, "y": 520, "w": 588, "h": 124, "label": "تكامل GitHub", "lx": 36, "ly": 538}], "nodes": [{"id": "A", "x": 335, "y": 24, "w": 120, "h": 46, "title": "إنشاء PRD"}, {"id": "B", "x": 335, "y": 148, "w": 120, "h": 46, "title": "تخطيط Epic"}, {"id": "C", "x": 335, "y": 272, "w": 120, "h": 46, "title": "تفكيك المهام"}, {"id": "D", "x": 310, "y": 396, "w": 170, "h": 46, "title": "مزامنة GitHub Issues"}, {"id": "E", "x": 803, "y": 559, "w": 184, "h": 46, "title": "تنفيذ الوكلاء المتوازي"}, {"id": "F", "x": 1117, "y": 761, "w": 128, "h": 46, "title": "إدارة Worktree"}, {"id": "G", "x": 1121, "y": 924, "w": 120, "h": 46, "title": "دمج الكود"}, {"id": "H", "x": 1121, "y": 1048, "w": 120, "h": 46, "title": "نشر الإنتاج"}, {"id": "I", "x": 922, "y": 761, "w": 120, "h": 46, "title": "ملفات السياق"}, {"id": "J", "x": 747, "y": 761, "w": 120, "h": 46, "title": "ملفات المهام"}, {"id": "K", "x": 572, "y": 761, "w": 120, "h": 46, "title": "تخصص الوكلاء"}, {"id": "L", "x": 412, "y": 559, "w": 163, "h": 46, "title": "قاعدة بيانات Issues"}, {"id": "M", "x": 237, "y": 559, "w": 120, "h": 46, "title": "تتبع التقدم"}, {"id": "N", "x": 62, "y": 559, "w": 120, "h": 46, "title": "تعاون الفريق"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [395, 70, 395, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [395, 194, 395, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [395, 318, 395, 396]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[480, 430], [895, 481], [895, 520], [895, 559]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[987, 602], [1181, 644], [1181, 722], [1181, 761]]}, {"src": "F", "dst": "G", "kind": "data", "line": [1181, 807, 1181, 924]}, {"src": "G", "dst": "H", "kind": "data", "line": [1181, 970, 1181, 1048]}, {"src": "E", "dst": "I", "kind": "data", "curve": [[927, 605], [982, 644], [982, 722], [982, 761]]}, {"src": "E", "dst": "J", "kind": "data", "curve": [[862, 605], [807, 644], [807, 722], [807, 761]]}, {"src": "E", "dst": "K", "kind": "data", "curve": [[803, 604], [632, 644], [632, 722], [632, 761]]}, {"src": "D", "dst": "L", "kind": "data", "curve": [[431, 442], [493, 481], [493, 520], [493, 559]]}, {"src": "D", "dst": "M", "kind": "data", "curve": [[358, 442], [297, 481], [297, 520], [297, 559]]}, {"src": "D", "dst": "N", "kind": "data", "curve": [[310, 438], [122, 481], [122, 520], [122, 559]]}]});
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
      const container = document.getElementById('rojectmanagementtutorial-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rojectmanagementtutorial-1';
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

## المتطلبات المسبقة والإعداد

### متطلبات النظام

- macOS (مُوصى) أو Linux
- Git 2.30+
- Claude Code (مساعد الترميز من Anthropic)
- GitHub CLI (`gh`)
- Node.js 18+ (لبعض نصوص الأتمتة)

### نص اختبار سريع لـ macOS

لمستخدمي macOS، يمكنك استخدام نص الاختبار التلقائي الخاص بنا للتحقق من بيئتك وتجربة CCPM:

```bash
# تحميل وتشغيل نص اختبار CCPM
curl -fsSL https://raw.githubusercontent.com/automazeio/ccpm/main/scripts/test-workflow.sh | bash

# أو إذا كان لديك هذا المستودع محلياً:
./scripts/test-ccpm-workflow.sh
```

سيقوم هذا النص بـ:
- ✅ فحص كل المتطلبات المسبقة للنظام
- ✅ إنشاء مشروع اختبار مع CCPM مُثبت
- ✅ التحقق من التثبيت
- ✅ إنشاء ملفات PRD وEpic نموذجية
- ✅ اختبار تكامل GitHub CLI (إن أمكن)
- ✅ توفير الخطوات التالية لتكامل Claude Code

### التثبيت السريع (دقيقتان)

**الخطوة 1: استنساخ CCPM في مشروعك**

```bash
# الانتقال إلى دليل مشروعك
cd path/to/your/project/

# استنساخ نظام CCPM
git clone https://github.com/automazeio/ccpm.git .
```

> ⚠️ **مهم**: إذا كان لديك بالفعل دليل `.claude`، استنسخ إلى دليل مؤقت ودمج المحتويات يدوياً.

**الخطوة 2: تهيئة نظام PM**

```bash
# في Claude Code، شغّل:
/pm:init
```

هذا الأمر سيقوم بـ:
- تثبيت GitHub CLI (عند الحاجة)
- المصادقة مع GitHub
- تثبيت امتداد `gh-sub-issue` لعلاقات الوالد-الطفل
- إنشاء الأدلة المطلوبة
- تحديث `.gitignore`

**الخطوة 3: تكوين إعدادات المستودع**

إنشاء أو تحديث `CLAUDE.md`:

```bash
# في Claude Code:
/init include rules from .claude/CLAUDE.md

# إذا كان لديك CLAUDE.md بالفعل:
/re-init
```

**الخطوة 4: تحضير النظام**

```bash
# تهيئة نظام السياق
/context:create
```

## سير العمل الأساسي: من الفكرة إلى الإنتاج

### المرحلة 1: إنشاء PRD (وثيقة متطلبات المنتج)

أساس CCPM هو **التطوير المُوجّه بالمواصفات**. كل شيء يبدأ بـ PRD شامل.

**بدء ميزة جديدة:**

```bash
/pm:prd-new memory-system
```

هذا يطلق **جلسة عصف ذهني تفاعلية** تنشئ PRD مفصل يغطي:

- **تعريف المشكلة**: ما الذي نحله بالضبط؟
- **مؤشرات النجاح**: كيف نقيس النجاح؟
- **قصص المستخدم**: من يستفيد وكيف؟
- **القيود التقنية**: ما هي حدودنا؟
- **الحالات الحدية**: ما الذي قد يخطئ؟
- **نقاط التكامل**: كيف يتناسب هذا مع الأنظمة الموجودة؟

**مثال على هيكل PRD:**

```markdown
# PRD نظام الذاكرة

## تعريف المشكلة
المستخدمون يفقدون السياق بين جلسات Claude Code، مما يؤدي إلى تفسيرات متكررة ودورات تطوير أبطأ.

## مؤشرات النجاح
- تقليل وقت إعادة إنشاء السياق بنسبة 90%
- تقليل الأسئلة المتكررة بنسبة 75%
- فهم مستمر للمشروع عبر الجلسات

## قصص المستخدم
- كمطور، أريد Claude أن يتذكر قراراتنا المعمارية السابقة
- كقائد فريق، أريد سياقاً ثابتاً عبر أعضاء الفريق
- كمدير منتج، أريد متطلبات الميزة محفوظة بين الجلسات

## الهيكل التقني
- تخزين ذاكرة قائم على الملفات في `.claude/memory/`
- تحميل سياق تلقائي عند بدء الجلسة
- فئات ذاكرة منظمة (قرارات، أنماط، قيود)

## نقاط التكامل
- هيكل دليل `.claude/` الموجود
- GitHub Issues لتتبع التقدم
- Git hooks لتحديث الذاكرة التلقائي
```

### المرحلة 2: تخطيط Epic وتفكيك المهام

بمجرد اكتمال PRD الخاص بك، حوله إلى epic قابل للتنفيذ مع مهام مفصلة.

**تحليل PRD إلى Epic:**

```bash
/pm:prd-parse memory-system
```

هذا ينشئ:
- **نظرة عامة على Epic** بأهداف واضحة
- **تفكيك تقني** للمكونات المطلوبة
- **قائمة مهام** مع تحديد التبعيات
- **تقديرات الجهد** لكل مكون
- **خطة تنفيذ متوازي** لأقصى كفاءة

**مثال على هيكل Epic:**

```
Epic: تنفيذ نظام الذاكرة

├── المهمة 1: بنية الذاكرة الأساسية
│   ├── إنشاء نظام تخزين الذاكرة
│   ├── تنفيذ تحميل السياق
│   └── إضافة خطافات ثبات الذاكرة
│
├── المهمة 2: واجهة إدارة الذاكرة
│   ├── تصميم عمليات CRUD للذاكرة
│   ├── بناء وظيفة البحث في الذاكرة
│   └── إنشاء أدوات تصور الذاكرة
│
└── المهمة 3: التكامل والاختبار
    ├── التكامل مع تدفقات العمل الموجودة
    ├── إضافة مجموعة اختبار شاملة
    └── إنشاء التوثيق والأمثلة
```

### المرحلة 3: تكامل GitHub وإنشاء Issue

حوّل epic الخاص بك إلى مشروع GitHub منظم مع تتبع كامل.

**Epic واحد إلى GitHub:**

```bash
/pm:epic-oneshot memory-system
```

هذا الأمر:
1. **ينشئ issue epic والد** في GitHub
2. **يولد issues مهام فرعية** مع علاقات صحيحة
3. **يضع تسميات ومعالم** للتنظيم
4. **يهيئ تتبع التقدم** مع مؤشرات الإكمال
5. **ينشئ ملفات مهام محلية** مربوطة بـ GitHub issues

**مثال على هيكل GitHub:**

```
Issue #1234 (Epic): تنفيذ نظام الذاكرة
├── Issue #1235: بنية الذاكرة الأساسية  
├── Issue #1236: واجهة إدارة الذاكرة
└── Issue #1237: التكامل والاختبار
```

كل issue يحتوي على:
- مواصفات تقنية مفصلة
- معايير القبول
- التبعيات والشروط المسبقة
- تقدير الجهد والتعقيد
- روابط للـ issues والتوثيق ذات الصلة

### المرحلة 4: تنفيذ الوكلاء المتوازي

هنا حيث CCMP يتألق حقاً - **وكلاء متخصصون متعددون يعملون بشكل متزامن**.

**بدء العمل على Issues:**

```bash
# بدء عمل البنية
/pm:issue-start 1235

# بالتوازي، بدء عمل الواجهة
/pm:issue-start 1236

# والتحضير للاختبار
/pm:issue-start 1237
```

**ما يحدث خلف الكواليس:**

1. **تخصص الوكيل**: كل وكيل يركز على مجاله المحدد
   - **وكيل البنية**: مخططات قواعد البيانات، أنظمة الملفات، المنطق الأساسي
   - **وكيل الواجهة**: APIs، واجهات المستخدم، نقاط التكامل  
   - **وكيل الاختبار**: مجموعات الاختبار، التحقق، التوثيق

2. **إدارة Worktree**: كل issue يحصل على Git worktree منفصل
   ```
   ../epic-memory-system/
   ├── main/           # فرع التطوير الرئيسي
   ├── issue-1235/     # عمل البنية
   ├── issue-1236/     # تطوير الواجهة  
   └── issue-1237/     # الاختبار والتكامل
   ```

3. **عزل السياق**: الوكلاء يحافظون على سياقات منفصلة
   ```
   .claude/context/
   ├── epic-memory-system/
   │   ├── infrastructure-context.md
   │   ├── interface-context.md
   │   └── testing-context.md
   ```

### المرحلة 5: إدارة التقدم والتنسيق

راقب ونسق العمل عبر كل التدفقات المتوازية.

**فحص الحالة العامة:**

```bash
/pm:status
```

**مثال على مخرجات الحالة:**
```
تقدم Memory System Epic: 67% مكتمل

✅ Issue #1235: البنية الأساسية (مكتمل)
   - نظام تخزين الذاكرة ✅
   - تحميل السياق ✅  
   - خطافات الثبات ✅

🚧 Issue #1236: واجهة الإدارة (قيد التقدم)
   - عمليات CRUD ✅
   - وظيفة البحث 🚧
   - أدوات التصور ⏳

⏳ Issue #1237: التكامل والاختبار (في الانتظار)
   - تكامل تدفق العمل ⏳
   - مجموعة الاختبار ⏳
   - التوثيق ⏳
```

**الحصول على المهمة التالية بالأولوية:**

```bash
/pm:next
```

هذا يقترح بذكاء أهم مهمة تالية بناءً على:
- **التبعيات**: ما الذي يحجب العمل الآخر؟
- **تقديرات الجهد**: انتصارات سريعة مقابل مهام معقدة
- **سعة الفريق**: ما يمكن القيام به بالتوازي؟
- **أولوية العمل**: ما يحقق قيمة أسرع؟

## الميزات المتقدمة والأوامر

### أوامر إدارة تدفق العمل

**تقرير الاجتماع اليومي:**
```bash
/pm:standup
```
ينتج تقرير حالة شامل مثالي لاجتماعات الفريق اليومية.

**العثور على المهام المحجوبة:**
```bash
/pm:blocked
```
يحدد المهام التي تنتظر التبعيات أو العوامل الخارجية.

**عرض العمل قيد التقدم:**
```bash
/pm:in-progress
```
يسرد كل تدفقات التطوير النشطة حالياً.

### أوامر المزامنة

**مزامنة ثنائية الاتجاه كاملة:**
```bash
/pm:sync
```
يزامن كل التغييرات المحلية مع GitHub ويسحب تحديثات أعضاء الفريق.

**استيراد Issues موجودة:**
```bash
/pm:import
```
يجلب GitHub issues الموجودة إلى نظام CCMP للإدارة.

### أوامر الصيانة

**التحقق من سلامة النظام:**
```bash
/pm:validate
```
يفحص التسق بين الملفات المحلية وحالة GitHub.

**تنظيف العمل المكتمل:**
```bash
/pm:clean
```
يؤرشف epics والمهام المكتملة للحفاظ على منطقة العمل منظمة.

**البحث عبر المحتوى:**
```bash
/pm:search "منطق المصادقة"
```
يجد المعلومات ذات الصلة عبر كل PRDs وepics والمهام.

## مثال من العالم الحقيقي: بناء نظام مصادقة المستخدم

لنمر عبر مثال كامل من الفكرة إلى الإنتاج.

### الخطوة 1: إنشاء PRD

```bash
/pm:prd-new user-authentication
```

**PRD المُولَّد (مختصر):**
```markdown
# PRD نظام مصادقة المستخدم

## تعريف المشكلة
تطبيقنا يفتقر إلى مصادقة مستخدم آمنة، مما يمنع التجارب الشخصية وحماية البيانات.

## مؤشرات النجاح
- دعم 10,000+ مستخدم متزامن
- وقت استجابة مصادقة <200ms
- وقت تشغيل 99.9% لخدمات المصادقة
- تكامل OAuth مع Google، GitHub، Apple

## المتطلبات التقنية
- إدارة جلسة قائمة على JWT
- تشفير كلمة المرور باستخدام bcrypt
- تحديد معدل محاولات تسجيل الدخول
- دعم المصادقة متعددة العوامل
- ثبات الجلسة عبر الأجهزة
```

### الخطوة 2: التحليل إلى Epic

```bash
/pm:prd-parse user-authentication
```

**هيكل Epic المُولَّد:**
```
Epic: نظام مصادقة المستخدم

├── مخطط قاعدة البيانات والنماذج (2-3 أيام)
│   ├── تصميم جدول المستخدم
│   ├── جداول إدارة الجلسة  
│   └── جداول مزود OAuth
│
├── خدمة المصادقة (3-4 أيام)  
│   ├── إدارة رمز JWT
│   ├── تشفير/التحقق من كلمة المرور
│   ├── تكامل مزود OAuth
│   └── إدارة دورة حياة الجلسة
│
├── نقاط النهاية API (2-3 أيام)
│   ├── نقاط نهاية تسجيل الدخول/الخروج
│   ├── تدفق التسجيل
│   ├── وظيفة إعادة تعيين كلمة المرور
│   └── APIs إدارة الملف الشخصي
│
├── تكامل الواجهة الأمامية (2-3 أيام)
│   ├── نماذج تسجيل الدخول/التسجيل
│   ├── إدارة حالة المصادقة
│   ├── معالجة المسار المحمي
│   └── أزرار تسجيل دخول OAuth
│
└── الأمان والاختبار (2-3 أيام)
    ├── تدقيق أمني واختبار اختراق
    ├── مجموعة اختبار شاملة
    ├── قياس الأداء
    └── التوثيق وأدلة النشر
```

### الخطوة 3: إنشاء GitHub Issues

```bash
/pm:epic-oneshot user-authentication
```

**Issues المُنشَأة:**
- Issue #1240 (Epic): نظام مصادقة المستخدم
  - Issue #1241: مخطط قاعدة البيانات والنماذج
  - Issue #1242: خدمة المصادقة  
  - Issue #1243: نقاط النهاية API
  - Issue #1244: تكامل الواجهة الأمامية
  - Issue #1245: الأمان والاختبار

### الخطوة 4: التنفيذ المتوازي

```bash
# بدء عمل قاعدة البيانات
/pm:issue-start 1241

# بالتزامن بدء طبقة الخدمة
/pm:issue-start 1242  

# وتحضير هيكل API
/pm:issue-start 1243
```

**تنسيق الوكيل:**
- **وكيل قاعدة البيانات**: ينشئ مخططات، ترحيلات، ونماذج بيانات
- **وكيل الخدمة**: ينفذ منطق JWT، تدفقات OAuth، إدارة الجلسة
- **وكيل API**: يبني نقاط نهاية REST مع التحقق المناسب ومعالجة الأخطاء

كل وكيل يعمل في عزلة لكن ينسق من خلال:
- تعريفات واجهة مشتركة
- هياكل بيانات مشتركة
- استراتيجيات اختبار منسقة

### الخطوة 5: التكامل والنشر

```bash
# فحص نقاط التكامل
/pm:epic-show user-authentication

# التحقق من أن كل المكونات تعمل معاً
/pm:validate

# الحالة الأخيرة قبل النشر
/pm:status
```

**التكامل النهائي:**
كل worktrees تدمج مرة أخرى في الفرع الرئيسي مع:
- نظام مصادقة كامل
- تغطية اختبار شاملة
- توثيق كامل
- تكوين جاهز للنشر

## أفضل الممارسات ونصائح المحترفين

### 1. جودة PRD هي كل شيء

**استثمر الوقت في PRDs مفصلة:**
- اقضي 20-30% من وقت المشروع في إنشاء PRD
- تضمين الحالات الحدية وسيناريوهات الأخطاء
- تعريف مؤشرات النجاح بوضوح
- توثيق متطلبات التكامل بدقة

**أنماط PRD المضادة لتجنبها:**
- متطلبات غامضة ("اجعله سريعاً")
- سيناريوهات معالجة أخطاء مفقودة
- مؤشرات نجاح غير معرفة
- عدم اعتبار قيود النظام الموجود

### 2. استراتيجية تفكيك المهام

**حجم المهمة الأمثل:**
- 1-3 أيام عمل لكل مهمة
- تعريفات مدخل/مخرج واضحة
- تبعيات دنيا بين المهام
- معايير إكمال قابلة للاختبار

**تفكيك ودود للتوازي:**
```bash
# جيد: فصل واضح للاهتمامات
- المهمة A: طبقة قاعدة البيانات
- المهمة B: منطق العمل  
- المهمة C: طبقة API
- المهمة D: مكونات الواجهة الأمامية

# سيء: تبعيات تسلسلية
- المهمة 1: ابدأ كل شيء
- المهمة 2: تابع كل شيء  
- المهمة 3: أنه كل شيء
```

### 3. إدارة السياق

**احتفظ بالسياقات مركزة:**
- كل وكيل يحافظ على سياق خاص بالمجال
- الخيط الرئيسي يبقى استراتيجياً، وليس تكتيكياً
- تنظيف السياق المنتظم يمنع التضخم
- توثيق القرارات الرئيسية في الذاكرة المستمرة

**أنماط السياق المضادة:**
- خلط تفاصيل التنفيذ في الخيط الرئيسي
- الوكلاء يتشاركون سياقات متداخلة
- عدم تنظيف سياقات العمل المكتمل أبداً
- فقدان القرارات المعمارية بين الجلسات

### 4. تعاون الفريق

**نظافة GitHub Issue:**
- عناوين issue واضحة وقابلة للتنفيذ
- معايير قبول مفصلة
- تحديثات تقدم منتظمة في التعليقات
- تسمية وتعيين معالم مناسبة

**تعاون إنسان-AI:**
- الإنسان يمكن أن يقفز إلى أي issue في أي وقت
- تقدم AI مرئي من خلال تعليقات GitHub
- مراجعات الكود تحدث طبيعياً من خلال PRs
- لا حاجة لأدوات خاصة لتنسيق الفريق

## مؤشرات الأداء والنتائج

الفرق التي تستخدم CCMP تبلغ عن تحسينات كبيرة:

### سرعة التطوير
- **5-8 مهام متوازية** مقابل 1 سابقاً
- **أسرع حتى 3 مرات** في تسليم الميزات
- **تقليل 89%** في الوقت المفقود للتبديل بين السياقات
- **تقليل 75%** في معدلات الأخطاء

### جودة الكود
- **تتبع كامل** من المتطلبات إلى الكود
- **تغطية اختبار شاملة** من خلال وكلاء اختبار مخصصة
- **معمارية ثابتة** من خلال التطوير الموجه بالمواصفات
- **توثيق أفضل** كنتيجة طبيعية

### إنتاجية الفريق
- **انتقالات سلسة** بين أعضاء الفريق
- **تقدم شفاف** مرئي لكل أصحاب المصلحة
- **اجتماعات أقل** بسبب التقدم ذاتي التوثيق
- **دقة تقدير محسنة** من خلال تفكيك المهام المفصل

## حل المشاكل الشائعة

### مشاكل الإعداد

**مصادقة GitHub CLI:**
```bash
gh auth status
gh auth login
```

**امتداد gh-sub-issue مفقود:**
```bash
gh extension install HackerNews/gh-sub-issue
```

**تضارب Worktree:**
```bash
# تنظيف worktrees تالفة
git worktree prune
git worktree remove ../epic-name/issue-123/
```

### مشاكل المزامنة

**عدم تطابق محلي-GitHub:**
```bash
/pm:validate
/pm:sync --force
```

**تلف السياق:**
```bash
/context:create --reset
```

### مشاكل الأداء

**وكلاء متوازيون كثيرون جداً:**
- احصر على 3-5 وكلاء متزامنين
- ركز على المهام بفصل واضح
- استخدم `/pm:next` لتحديد الأولويات الذكي

**إدارة حجم السياق:**
```bash
/pm:clean --aggressive
/context:compact
```

## التكوين المتقدم

### تخصص الوكيل المخصص

إنشاء وكلاء متخصصين لمجموعة التقنيات الخاصة بك:

```markdown
# .claude/agents/backend-agent.md
أنت متخصص تطوير backend يركز على:
- تصميم وتحسين قاعدة البيانات
- أمان وأداء API
- بنية الخادم والتوسع
- اختبار التكامل والمراقبة
```

### تخصيص تدفق العمل

تكييف CCMP لاحتياجات فريقك:

```yaml
# .claude/config/workflow.yml
epic_size: medium  # small, medium, large
parallel_limit: 5
auto_sync: true
github_labels:
  - "epic:feature"
  - "task:implementation"
  - "priority:high"
```

## خارطة الطريق المستقبلية والتوسعات

### الميزات المخططة
- **دعم متعدد المستودعات** للخدمات المجهرية
- **تكامل أنابيب CI/CD** للاختبار التلقائي
- **تحليلات متقدمة** حول سرعة التطوير
- **لوحات أداء الفريق** مع تصور المؤشرات

### توسعات المجتمع
- **تكامل Slack/Discord** لإشعارات الفريق
- **مزامنة Jira** للبيئات المؤسسية  
- **قوالب تدفق عمل مخصصة** لأنواع مشاريع مختلفة
- **تكامل مراجعة كود مدعوم بـ AI**

## الخلاصة: تغيير طريقة شحن الفرق للبرمجيات

CCMP يمثل تحولاً جوهرياً في كيفية عمل التطوير بمساعدة AI. بالانتقال من المحادثات المعزولة إلى التنفيذ التعاوني، القابل للتتبع، والمتوازي، يمكن للفرق:

1. **الشحن بشكل أسرع** من خلال التنفيذ المتوازي الذكي
2. **الحفاظ على الجودة** من خلال التطوير الموجه بالمواصفات
3. **تحسين التعاون** مع تتبع التقدم الشفاف
4. **تقليل فقدان السياق** مع ذاكرة المشروع المستمرة
5. **التوسع بفعالية** كلما نمت الفرق والمشاريع

النظام مختبر في المعركة من قبل فرق تشحن برمجيات الإنتاج ويمثل مستقبل التعاون إنسان-AI في تطوير البرمجيات.

### البدء اليوم

1. **استنسخ CCMP** في مشروعك التالي
2. **ابدأ بميزة بسيطة** لتعلم تدفق العمل
3. **توسع إلى epics معقدة** كلما بنيت الثقة
4. **شارك مع فريقك** واختبر التطوير التعاوني مع AI

التحول من البرمجة بالحدس إلى التطوير المتوازي الموجه بالمواصفات يبدأ بأمر واحد:

```bash
/pm:prd-new your-next-feature
```

### الموارد والمجتمع

- **مستودع GitHub**: [https://github.com/automazeio/ccpm](https://github.com/automazeio/ccpm)
- **التوثيق**: أدلة شاملة في المستودع
- **المجتمع**: انضم للمناقشات في GitHub Issues
- **الدعم**: تابع [@aroussi](https://x.com/aroussi) للتحديثات والنصائح

---

*مستعد لثورة في تدفق عمل التطوير؟ ابدأ أول مشروع CCMP اليوم واختبر مستقبل تطوير البرمجيات بمساعدة AI.*
