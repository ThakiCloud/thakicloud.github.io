---
title: "دليل شامل لبناء وكيل البرمجة: ورشة عمل عملية"
excerpt: "تعلم كيفية بناء وكيل ذكي للبرمجة مثل Cursor وCline وWindsurf باستخدام Go وAPI من Anthropic Claude مع دليل عملي تدريجي"
seo_title: "تطوير وكيل ذكي للبرمجة: دليل عملي مع Go وClaude - Thaki Cloud"
seo_description: "دليل شامل لبناء وكلاء البرمجة مثل Cursor وWindsurf. تعلم تكامل الأدوات وإدارة API ومنهجية التطوير التدريجي مع أمثلة عملية"
date: 2025-08-26
tags:
  - ai-agent
  - coding-agent
  - anthropic-claude
  - go-programming
  - developer-tools
  - cursor-alternative
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/how-to-build-coding-agent-comprehensive-workshop-guide/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/how-to-build-coding-agent-comprehensive-workshop-guide/"
published: false
categories:
  - tutorials
---

⏱️ **وقت القراءة المتوقع**: ١٥ دقيقة

## مقدمة: صعود وكلاء البرمجة الذكية

لقد شهدت بيئة تطوير الذكاء الاصطناعي ثورة حقيقية بفضل وكلاء البرمجة مثل Cursor وCline وAmp وWindsurf. هذه الأدوات تحول الطريقة التي يكتب بها المطورون الكود ويصححونه ويصونونه من خلال توفير مساعدة ذكية تفهم السياق وتنفذ الأوامر وتدير قواعد الكود بأكملها.

يوفر [مستودع ورشة العمل من Geoffrey Huntley](https://github.com/ghuntley/how-to-build-a-coding-agent) دليلاً شاملاً لبناء وكيل البرمجة الخاص بك من الصفر. سيأخذك هذا البرنامج التعليمي عبر العملية بأكملها، من وظائف الدردشة الأساسية إلى قدرات البحث المتقدمة في الكود.

## لماذا نبني وكيل البرمجة الخاص بنا؟

### فهم الأساس

بناء وكيل البرمجة الخاص بك يوفر عدة مزايا:

- **السيطرة الكاملة**: تخصيص كل جانب من جوانب سلوك الوكيل
- **فرصة للتعلم**: فهم عميق لهندسة الوكلاء الذكية
- **تحسين التكاليف**: تخصيص استخدام الموارد حسب احتياجاتك المحددة
- **الخصوصية**: الاحتفاظ بالكود الحساس على البنية التحتية الخاصة بك
- **القابلية للتوسع**: إضافة أدوات وتكاملات مخصصة

### قدرات وكلاء البرمجة الحديثة

وكلاء البرمجة اليوم عادة ما تتضمن:

١. **واجهة اللغة الطبيعية**: تفاعل قائم على الدردشة مع المطورين
٢. **عمليات نظام الملفات**: قراءة وكتابة وإدارة ملفات المشروع
٣. **البحث في الكود**: مطابقة الأنماط المتقدمة واكتشاف الكود
٤. **تنفيذ الأوامر**: تشغيل أوامر النظام وعمليات البناء
٥. **الوعي بالسياق**: فهم هيكل المشروع والتبعيات

## نظرة عامة على هندسة الورشة

تتبع الورشة نهج التحسين التدريجي مع ستة تطبيقات منفصلة، كل منها يبني على السابق:

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
<div class="d3-arch" data-arch-root id="mprehensiveworkshopguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 758, "height": 846, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 128, "y": 24, "w": 120, "h": 46, "title": "chat.go"}, {"id": "B", "x": 221, "y": 148, "w": 120, "h": 46, "title": "read.go"}, {"id": "C", "x": 309, "y": 272, "w": 121, "h": 46, "title": "list_files.go"}, {"id": "D", "x": 399, "y": 396, "w": 120, "h": 46, "title": "bash_tool.go"}, {"id": "E", "x": 486, "y": 520, "w": 120, "h": 46, "title": "edit_tool.go"}, {"id": "F", "x": 563, "y": 644, "w": 163, "h": 46, "title": "code_search_tool.go"}, {"id": "A1", "x": 24, "y": 148, "w": 142, "h": 46, "title": "الدردشة الأساسية"}, {"id": "B1", "x": 133, "y": 272, "w": 121, "h": 46, "title": "قراءة الملفات"}, {"id": "C1", "x": 216, "y": 396, "w": 128, "h": 46, "title": "قائمة المجلدات"}, {"id": "D1", "x": 310, "y": 520, "w": 121, "h": 46, "title": "تنفيذ الأوامر"}, {"id": "E1", "x": 387, "y": 644, "w": 121, "h": 46, "title": "تحرير الملفات"}, {"id": "F1", "x": 581, "y": 768, "w": 128, "h": 46, "title": "البحث في الكود"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[223, 70], [281, 109], [281, 109], [281, 148]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[314, 194], [369, 233], [369, 233], [369, 272]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[402, 318], [459, 357], [459, 357], [459, 396]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[491, 442], [546, 481], [546, 481], [546, 520]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[583, 566], [645, 605], [645, 605], [645, 644]]}, {"src": "A", "dst": "A1", "kind": "data", "curve": [[154, 70], [95, 109], [95, 109], [95, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "curve": [[248, 194], [193, 233], [193, 233], [193, 272]]}, {"src": "C", "dst": "C1", "kind": "data", "curve": [[336, 318], [280, 357], [280, 357], [280, 396]]}, {"src": "D", "dst": "D1", "kind": "data", "curve": [[426, 442], [371, 481], [371, 481], [371, 520]]}, {"src": "E", "dst": "E1", "kind": "data", "curve": [[510, 566], [448, 605], [448, 605], [448, 644]]}, {"src": "F", "dst": "F1", "kind": "data", "line": [645, 690, 645, 768]}]});
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
      const container = document.getElementById('mprehensiveworkshopguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'mprehensiveworkshopguide-1';
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

## المرحلة الأولى: وكيل الدردشة الأساسي (chat.go)

### الهندسة الأساسية

تبدأ الأسس بواجهة دردشة بسيطة تؤسس نمط حلقة المحادثة:

```go
type Agent struct {
    client      *anthropic.Client
    getUserMessage func() (string, bool)
    tools       []ToolDefinition
    verbose     bool
}
```

### نقاط التعلم الرئيسية

- **تكامل API**: اتصال مباشر بـ Anthropic Claude API
- **إدارة المحادثة**: الحفاظ على تاريخ الدردشة والسياق
- **معالجة الأخطاء**: إدارة قوية للأخطاء لاستدعاءات API
- **واجهة المستخدم**: أنماط التفاعل القائمة على المحطة الطرفية

### أبرز التنفيذ

يُظهر وكيل الدردشة:
- الاستجابات المتدفقة للتفاعل في الوقت الفعلي
- إدارة حالة المحادثة
- آليات الاسترداد الأساسية من الأخطاء
- قدرات التسجيل والتصحيح

## المرحلة الثانية: وكيل قراءة الملفات (read.go)

### أساس تكامل الأدوات

تقدم هذه المرحلة نظام الأدوات الذي يصبح محورياً لجميع الوكلاء اللاحقين:

```go
type ToolDefinition struct {
    Name        string
    Description string
    InputSchema ToolInputSchemaParam
    Function    func(input json.RawMessage) (string, error)
}
```

### تنفيذ أداة قراءة الملفات

```go
type ReadFileInput struct {
    Path string `json:"path" jsonschema:"description=مسار الملف للقراءة"`
}

func ReadFile(input json.RawMessage) (string, error) {
    var params ReadFileInput
    if err := json.Unmarshal(input, &params); err != nil {
        return "", err
    }
    
    content, err := os.ReadFile(params.Path)
    if err != nil {
        return "", fmt.Errorf("فشل في قراءة الملف: %w", err)
    }
    
    return string(content), nil
}
```

### نمط تسجيل الأدوات

تؤسس الورشة نمطاً متسقاً لتسجيل الأدوات:

```go
var readFileTool = ToolDefinition{
    Name:        "read_file",
    Description: "قراءة محتويات الملف",
    InputSchema: GenerateSchema[ReadFileInput](),
    Function:    ReadFile,
}
```

## المرحلة الثالثة: التنقل في نظام الملفات (list_files.go)

### عمليات المجلدات

بناءً على قراءة الملفات، تضيف هذه المرحلة قدرات اجتياز المجلدات:

```go
type ListFilesInput struct {
    Path string `json:"path" jsonschema:"description=مسار المجلد لعرض محتوياته"`
}
```

### إدارة محسنة للملفات

توفر أداة قائمة الملفات:
- مسح المجلدات بشكل تكراري
- تصفية أنواع الملفات
- تطبيع المسارات
- معالجة الأخطاء للصلاحيات ومشاكل الوصول

### تنسيق الأدوات المتعددة

تُظهر هذه المرحلة كيف تعمل الأدوات المتعددة معاً:
- `read_file` للوصول للمحتوى
- `list_files` للاكتشاف
- العمليات المنسقة للمهام المعقدة

## المرحلة الرابعة: تكامل النظام (bash_tool.go)

### قدرات تنفيذ الأوامر

تقدم أداة bash العمليات على مستوى النظام:

```go
type BashInput struct {
    Command string `json:"command" jsonschema:"description=أمر bash للتنفيذ"`
}

func BashCommand(input json.RawMessage) (string, error) {
    var params BashInput
    if err := json.Unmarshal(input, &params); err != nil {
        return "", err
    }
    
    cmd := exec.Command("bash", "-c", params.Command)
    output, err := cmd.CombinedOutput()
    
    return string(output), err
}
```

### اعتبارات الأمان والحماية

تتناول الورشة الجوانب الأمنية الحاسمة:
- تحقق من صحة الأوامر وتعقيمها
- التقاط المخرجات ومعالجة الأخطاء
- إدارة العمليات والمهلة الزمنية
- ضوابط الصلاحيات والوصول

### التطبيقات الواقعية

مع تنفيذ الأوامر، يمكن للوكيل:
- تشغيل عمليات البناء والاختبار
- تثبيت التبعيات والحزم
- تنفيذ عمليات git
- إجراء تشخيصات النظام

## المرحلة الخامسة: تحرير الكود (edit_tool.go)

### محرك تعديل الملفات

تمثل أداة التحرير قفزة كبيرة في القدرات:

```go
type EditFileInput struct {
    Path   string `json:"path" jsonschema:"description=مسار الملف للتحرير"`
    OldStr string `json:"old_str" jsonschema:"description=النص المراد استبداله"`
    NewStr string `json:"new_str" jsonschema:"description=النص البديل"`
}
```

### التحقق والأمان

تنفذ أداة التحرير عدة آليات أمان:
- التحقق من المحتوى قبل التعديل
- إنشاء نسخ احتياطية لإمكانية الاستعادة
- عمليات ذرية لمنع التحريرات الجزئية
- توليد الفروق لتتبع التغييرات

### ميزات التحرير المتقدمة

تشمل القدرات الرئيسية:
- استبدال دقيق للنصوص
- التعامل مع المحتوى متعدد الأسطر
- المحافظة على المسافات البادئة
- إدارة الترميز ومجموعات الأحرف

## المرحلة السادسة: اكتشاف الكود (code_search_tool.go)

### تكامل Ripgrep

تضيف المرحلة الأخيرة بحثاً قوياً في الكود باستخدام ripgrep:

```go
type CodeSearchInput struct {
    Pattern       string `json:"pattern" jsonschema:"description=نمط البحث"`
    Path          string `json:"path,omitempty" jsonschema:"description=مسار البحث"`
    FileType      string `json:"file_type,omitempty" jsonschema:"description=مرشح نوع الملف"`
    CaseSensitive bool   `json:"case_sensitive,omitempty" jsonschema:"description=بحث حساس لحالة الأحرف"`
}
```

### قدرات البحث المتقدمة

توفر أداة البحث في الكود:
- مطابقة أنماط التعبيرات النمطية
- تصفية أنواع الملفات للبحث المستهدف
- خيارات الحساسية لحالة الأحرف
- تضمين أسطر السياق
- تحسين الأداء لقواعد الكود الكبيرة

### أنماط استراتيجيات البحث

الأنماط الشائعة للبحث تشمل:
- تعريفات الدوال والطرق
- إعلانات المتغيرات والثوابت
- تحليل الاستيراد والتبعيات
- اكتشاف تعليقات TODO وFIXME
- تحديد أنماط معالجة الأخطاء

## إعداد بيئة التطوير

### المتطلبات المسبقة والتبعيات

تستخدم الورشة ممارسات التطوير الحديثة:

```yaml
# devenv.yaml
name: coding-agent-workshop
starship: true

imports:
  - devenv-nixpkgs

env:
  ANTHROPIC_API_KEY: "your-api-key-here"

languages:
  go:
    enable: true
    package: "go_1_24"
```

### فوائد البيئة

استخدام devenv يوفر:
- بيئات تطوير قابلة للاستنساخ
- إدارة تلقائية للتبعيات
- التوافق عبر المنصات
- اتساق الإصدارات بين أعضاء الفريق

## غوص عميق في هندسة نظام الأدوات

### توليد المخطط

تُظهر الورشة التوليد التلقائي لمخطط JSON:

```go
func GenerateSchema[T any]() ToolInputSchemaParam {
    schema := jsonschema.Reflect(&struct{ T }{})
    return ToolInputSchemaParam{
        Type:       "object",
        Properties: schema.Properties,
        Required:   schema.Required,
    }
}
```

### نمط حلقة الأحداث

جميع الوكلاء تتبع حلقة أحداث متسقة:

١. **دخل المستخدم**: قبول وتحقق من أوامر المستخدم
٢. **بناء السياق**: تجميع تاريخ المحادثة
٣. **طلب API**: إرسال الطلب إلى Claude مع الأدوات المتاحة
٤. **تنفيذ الأدوات**: معالجة طلبات استخدام الأدوات
٥. **دمج النتائج**: دمج مخرجات الأدوات مع استجابات AI
٦. **تسليم الاستجابة**: تقديم النتائج النهائية للمستخدم

### استراتيجية معالجة الأخطاء

تنفذ الورشة معالجة شاملة للأخطاء:
- تحقق من صحة المدخلات وتعقيمها
- منطق استرداد وإعادة المحاولة لأخطاء API
- إدارة مهلة تنفيذ الأدوات
- رسائل خطأ ودية للمستخدم
- قدرات التصحيح والتسجيل

## الميزات المتقدمة والتوسعات

### التسجيل المفصل

جميع التطبيقات تدعم الوضع المفصل للتصحيح:

```bash
go run edit_tool.go --verbose
```

هذا يوفر رؤى مفصلة في:
- توقيت وأداء استدعاءات API
- تتبع تنفيذ الأدوات
- تفاصيل عمليات الملفات
- معلومات تشخيص الأخطاء

### تطوير أدوات مخصصة

يدعم الإطار توسع الأدوات بسهولة:

```go
func CustomTool(input json.RawMessage) (string, error) {
    // تنفيذ الأداة المخصصة
    return result, nil
}

var customToolDef = ToolDefinition{
    Name:        "custom_tool",
    Description: "وظيفة مخصصة",
    InputSchema: GenerateSchema[CustomInput](),
    Function:    CustomTool,
}
```

## الاختبار والتحقق

### ملفات العينة

يتضمن المستودع ملفات اختبار للتجريب:
- `fizzbuzz.js`: كود JavaScript لممارسة التحرير
- `riddle.txt`: محتوى نصي لاختبارات القراءة
- `AGENT.md`: وثائق للتحليل

### سيناريوهات الاختبار

النهج الموصى به للاختبار:

١. **الوظائف الأساسية**: قراءة الملفات وإدراجها
٢. **تكامل النظام**: تنفيذ الأوامر والتقاط المخرجات
٣. **تعديل الكود**: التحرير الآمن والتحقق
٤. **عمليات البحث**: مطابقة الأنماط والاكتشاف
٥. **حالات الخطأ**: التعامل مع الفشل والحالات الحدية

## اعتبارات الإنتاج

### أفضل ممارسات الأمان

عند نشر وكلاء البرمجة:
- تنفيذ المصادقة والتفويض المناسبين
- تعقيم جميع مدخلات وأوامر المستخدم
- استخدام بيئات تنفيذ معزولة
- مراقبة وتسجيل جميع أنشطة الوكيل
- تنفيذ حدود المعدل وضوابط الاستخدام

### تحسين الأداء

الاستراتيجيات الرئيسية للتحسين:
- تخزين مؤقت للملفات ونتائج البحث المتكررة
- تنفيذ التحميل الكسول لقواعد الكود الكبيرة
- استخدام الاستجابات المتدفقة للعمليات الطويلة
- تحسين ترتيب تنفيذ الأدوات والتوازي
- مراقبة استخدام الذاكرة وتنظيف الموارد

### تخطيط القابلية للتوسع

للنشر على نطاق أوسع:
- تنفيذ التوسع الأفقي مع توزيع الأحمال
- استخدام التخزين المؤقت الموزع للحالة المشتركة
- النظر في هندسة الخدمات الدقيقة لعزل الأدوات
- التخطيط لجلسات المستخدمين المتزامنة
- تنفيذ المراقبة والملاحظة المناسبة

## المشاكل الشائعة والاستكشاف

### مشاكل تكامل API

المشاكل الشائعة والحلول:
- **حدود المعدل**: تنفيذ التراجع الأسي
- **المصادقة**: تحقق من تكوين مفتاح API
- **مشاكل الشبكة**: إضافة منطق إعادة المحاولة مع قواطع الدائرة
- **تحليل الاستجابة**: التحقق من توافق مخطط JSON

### تحديات تنفيذ الأدوات

المشاكل الشائعة:
- **أخطاء الصلاحيات**: فحص صلاحيات نظام الملفات
- **مشاكل المسار**: تطبيع والتحقق من مسارات الملفات
- **فشل الأوامر**: تنفيذ التقاط مناسب للأخطاء
- **حدود الموارد**: مراقبة استخدام الذاكرة والمعالج

## الخطوات التالية والمواضيع المتقدمة

### تحسينات الميزات

اعتبارات إضافية:
- قدرات كشط الويب للمحتوى الخارجي
- تكامل قاعدة البيانات للتخزين الدائم
- تكامل API للخدمات الخارجية
- دعم متعدد اللغات بخلاف Go
- واجهات رسومية للمستخدمين غير التقنيين

### تطور الهندسة

الأنماط المتقدمة للاستكشاف:
- الهندسة القائمة على الأحداث مع قوائم انتظار الرسائل
- أنظمة المكونات الإضافية للوظائف القابلة للتوسع
- تنسيق الوكلاء الموزعة
- تكامل التعلم الآلي لتكيف السلوك
- ميزات التعاون في الوقت الفعلي

## سكريبت اختبار قابل للتنفيذ

### سكريبت إعداد بيئة macOS

```bash
#!/bin/bash
# setup-coding-agent.sh
# إعداد بيئة ورشة عمل وكيل البرمجة

set -e

echo "🚀 بدء إعداد بيئة ورشة عمل وكيل البرمجة..."

# فحص تثبيت Go
if ! command -v go &> /dev/null; then
    echo "❌ Go غير مثبت."
    echo "يرجى تثبيت Go من https://golang.org/dl/"
    exit 1
fi

# فحص إصدار Go
GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
REQUIRED_VERSION="1.24.0"

if [[ "$(printf '%s\n' "$REQUIRED_VERSION" "$GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]]; then
    echo "❌ يجب أن يكون إصدار Go $REQUIRED_VERSION أو أحدث. الحالي: $GO_VERSION"
    exit 1
fi

# استنساخ مستودع الورشة
WORKSHOP_DIR="coding-agent-workshop"
if [ ! -d "$WORKSHOP_DIR" ]; then
    echo "📦 استنساخ مستودع الورشة..."
    git clone https://github.com/ghuntley/how-to-build-a-coding-agent.git "$WORKSHOP_DIR"
fi

cd "$WORKSHOP_DIR"

# تثبيت التبعيات
echo "📚 تثبيت التبعيات..."
go mod tidy

# فحص إعداد مفتاح API
if [ -z "$ANTHROPIC_API_KEY" ]; then
    echo "⚠️  يرجى تعيين متغير البيئة ANTHROPIC_API_KEY."
    echo "export ANTHROPIC_API_KEY='your-api-key-here'"
    echo ""
fi

# إنشاء ملفات الاختبار
echo "📝 إنشاء ملفات الاختبار..."

cat > test-example.py << 'EOF'
# ملف مثال Python
def fibonacci(n):
    """حساب متتالية فيبوناتشي."""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def main():
    """الدالة الرئيسية"""
    for i in range(10):
        print(f"fibonacci({i}) = {fibonacci(i)}")

if __name__ == "__main__":
    main()
EOF

cat > test-riddle.txt << 'EOF'
لدي عرف لكني لست أسداً،
ولدي أربعة أرجل لكني لست طاولة،
ويمكنني الجري لكني لست إنساناً.
فما أنا؟

الجواب: حصان
EOF

echo "✅ تم إكمال إعداد البيئة!"
echo ""
echo "🎯 طريقة الاستخدام:"
echo "1. الدردشة الأساسية: go run chat.go"
echo "2. قراءة الملفات: go run read.go"
echo "3. قائمة الملفات: go run list_files.go"
echo "4. تنفيذ الأوامر: go run bash_tool.go"
echo "5. تحرير الملفات: go run edit_tool.go"
echo "6. البحث في الكود: go run code_search_tool.go"
echo ""
echo "🔍 التسجيل المفصل: استخدم العلامة --verbose"
echo "مثال: go run edit_tool.go --verbose"
```

## الخلاصة

بناء وكيل البرمجة من الصفر يوفر رؤى لا تقدر بثمن حول التطوير المدعوم بالذكاء الاصطناعي. تقدم [ورشة عمل how-to-build-a-coding-agent](https://github.com/ghuntley/how-to-build-a-coding-agent) نهجاً منظماً ومتدرجاً يأخذك من وظائف الدردشة الأساسية إلى مساعد برمجة كامل الميزات.

التقدم السداسي المراحل—من المحادثة البسيطة إلى البحث المتقدم في الكود—يُظهر كيف يمكن بناء أنظمة الذكاء الاصطناعي المعقدة تدريجياً. كل مرحلة تقدم مفاهيم أساسية بينما تبني على الأسس السابقة، مما يخلق فهماً شاملاً لهندسة الوكلاء.

### النقاط الرئيسية

١. **التطوير التدريجي**: ابدأ بساطة وأضف التعقيد تدريجياً
٢. **التصميم المتمحور حول الأدوات**: بناء أنظمة أدوات قابلة للإعادة الاستخدام والتركيب
٣. **الأمان أولاً**: تنفيذ التحقق ومعالجة الأخطاء في جميع أنحاء
٤. **الاختبار الواقعي**: استخدام أمثلة عملية وحالات حدية
٥. **الاستعداد للإنتاج**: النظر في الأمان والأداء وقابلية التوسع

بيئة التطوير الحديثة تعتمد بشكل متزايد على أدوات مدعومة بالذكاء الاصطناعي. فهم كيفية بناء وتخصيص هذه الوكلاء يضعك في مقدمة هذا التطور التكنولوجي. سواء كنت تبني أدوات داخلية، أو تساهم في مشاريع مفتوحة المصدر، أو تصنع منتجات تجارية، فإن المبادئ والممارسات المُظهرة في هذه الورشة توفر أساساً قوياً للنجاح.

ابدأ بوكيل الدردشة الأساسي، وتقدم خلال كل مرحلة بشكل منهجي، وسرعان ما ستحصل على وكيل برمجة متطور مصمم خصيصاً لاحتياجاتك ومتطلبات عملك المحددة.
