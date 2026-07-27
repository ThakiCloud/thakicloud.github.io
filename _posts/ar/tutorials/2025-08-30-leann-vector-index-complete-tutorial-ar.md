---
title: "LEANN: دليل شامل لنظام الفهرسة الثوري الذي يوفر 97% من مساحة التخزين"
excerpt: "إتقان LEANN، نظام الفهرسة الثوري الذي يحقق توفير 97% من مساحة التخزين مع الحفاظ على البحث السريع والدقيق. دليل شامل من التثبيت إلى الاستخدام المتقدم"
seo_title: "دليل LEANN للفهرسة الشعاعية - نظام RAG بتوفير 97% من التخزين"
seo_description: "تعلم LEANN، نظام الفهرسة الشعاعية الثوري الذي يوفر 97% من مساحة التخزين. دليل شامل يغطي التثبيت والاستخدام والميزات المتقدمة لتطبيقات RAG فعالة"
date: 2025-08-30
tags:
  - LEANN
  - الفهرسة-الشعاعية
  - RAG
  - تحسين-التخزين
  - التعلم-الآلي
  - الذكاء-الاصطناعي
  - قاعدة-البيانات-الشعاعية
  - التضمين
author_profile: true
toc: true
toc_label: "دليل LEANN"
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/leann-vector-index-complete-tutorial-ar/"
lang: ar
permalink: /ar/tutorials/leann-vector-index-complete-tutorial/
published: false
categories:
  - tutorials
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

> **الخلاصة** LEANN هو نظام فهرسة شعاعية ثوري يحقق **توفير 97% من مساحة التخزين** مقارنة بقواعد البيانات الشعاعية التقليدية مع الحفاظ على أداء البحث السريع والدقيق. يغطي هذا الدليل الشامل كل شيء من التثبيت الأساسي إلى الاستخدام المتقدم، مما يمكنك من بناء تطبيقات RAG فعالة بأقل متطلبات تخزين.

---

## ما هو LEANN؟

LEANN (Low-Storage Vector Index) هو نظام فهرسة شعاعية رائد طورته Berkeley Sky Computing Lab، والذي يعيد تصور طريقة عمل قواعد البيانات الشعاعية بشكل جذري. بدلاً من تخزين كل تضمين منفرد (وهو أمر مكلف)، يقوم LEANN بتخزين هيكل رسم بياني مُقلم ويعيد حساب التضمينات فقط عند الحاجة.

### ثورة التخزين

قواعد البيانات الشعاعية التقليدية مثل FAISS تخزن جميع التضمينات في الذاكرة، مما يؤدي إلى متطلبات تخزين ضخمة:

| مجموعة البيانات | قاعدة البيانات التقليدية | LEANN | التوفير |
|-----------------|---------------------------|-------|---------|
| DPR (2.1 مليون وثيقة) | 3.8 جيجابايت | 324 ميجابايت | **91%** |
| ويكيبيديا (60 مليون وثيقة) | 201 جيجابايت | 6 جيجابايت | **97%** |
| المحادثة (400 ألف وثيقة) | 1.8 جيجابايت | 64 ميجابايت | **97%** |
| البريد الإلكتروني (780 ألف وثيقة) | 2.4 جيجابايت | 79 ميجابايت | **97%** |

### الابتكار الأساسي: إعادة الحساب الانتقائي القائم على الرسم البياني

سحر LEANN يكمن في تقنياته الأساسية:

- **إعادة الحساب الانتقائي القائم على الرسم البياني**: حساب التضمينات فقط للعقد في مسار البحث
- **التقليم مع الحفاظ على الدرجة العالية**: الاحتفاظ بالعقد "المحورية" المهمة مع إزالة الاتصالات المتكررة
- **المعالجة الديناميكية بالدفعات**: معالجة فعالة لحسابات التضمين لاستخدام GPU
- **البحث ثنائي المستوى**: اجتياز ذكي للرسم البياني يعطي الأولوية للعقد الواعدة

## نظرة عامة على البنية

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
<div class="d3-arch" data-arch-root id="rindexcompletetutorialar-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1051, "height": 1048, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 200, "y": 24, "w": 428, "h": 124, "label": "طبقة التخزين", "lx": 212, "ly": 42}, {"x": 648, "y": 24, "w": 371, "h": 124, "label": "محرك البحث", "lx": 660, "ly": 42}], "nodes": [{"id": "A", "x": 42, "y": 63, "w": 121, "h": 46, "title": "إدخال الوثيقة"}, {"id": "B", "x": 42, "y": 226, "w": 120, "h": 46, "title": "تقسيم النص"}, {"id": "C", "x": 24, "y": 350, "w": 156, "h": 46, "title": "بناء الرسم البياني"}, {"id": "D", "x": 31, "y": 474, "w": 142, "h": 46, "title": "خوارزمية التقليم"}, {"id": "E", "x": 35, "y": 598, "w": 135, "h": 46, "title": "التخزين المضغوط"}, {"id": "F", "x": 232, "y": 474, "w": 121, "h": 46, "title": "استعلام البحث"}, {"id": "G", "x": 225, "y": 598, "w": 135, "h": 46, "title": "تضمين الاستعلام"}, {"id": "H", "x": 112, "y": 722, "w": 170, "h": 46, "title": "اجتياز الرسم البياني"}, {"id": "I", "x": 105, "y": 846, "w": 184, "h": 46, "title": "إعادة الحساب الانتقائي"}, {"id": "J", "x": 137, "y": 970, "w": 121, "h": 46, "title": "ترتيب النتائج"}, {"id": "K", "x": 238, "y": 63, "w": 142, "h": 46, "title": "البيانات الوصفية"}, {"id": "L", "x": 435, "y": 63, "w": 156, "h": 46, "title": "هيكل الرسم البياني"}, {"id": "M", "x": 686, "y": 63, "w": 120, "h": 46, "title": "خلفية HNSW"}, {"id": "N", "x": 861, "y": 63, "w": 121, "h": 46, "title": "خلفية DiskANN"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [102, 109, 102, 226]}, {"src": "B", "dst": "C", "kind": "data", "line": [102, 272, 102, 350]}, {"src": "C", "dst": "D", "kind": "data", "line": [102, 396, 102, 474]}, {"src": "D", "dst": "E", "kind": "data", "line": [102, 520, 102, 598]}, {"src": "F", "dst": "G", "kind": "data", "line": [292, 520, 292, 598]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[292, 644], [292, 683], [292, 683], [232, 722]]}, {"src": "H", "dst": "I", "kind": "data", "line": [197, 768, 197, 846]}, {"src": "I", "dst": "J", "kind": "data", "line": [197, 892, 197, 970]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[102, 644], [102, 683], [102, 683], [162, 722]]}]});
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
      const container = document.getElementById('rindexcompletetutorialar-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rindexcompletetutorialar-1';
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

## دليل التثبيت

### المتطلبات المسبقة

- **Python**: 3.9 أو أحدث
- **نظام التشغيل**: macOS، Linux (دعم Windows قادم قريباً)
- **الذاكرة**: 4 جيجابايت RAM كحد أدنى (8 جيجابايت+ مُوصى به)
- **التخزين**: يختلف حسب حجم مجموعة البيانات (أقل بكثير من قواعد البيانات الشعاعية التقليدية)

### تثبيت البداية السريعة

```bash
# إنشاء بيئة افتراضية
python3 -m venv .venv
source .venv/bin/activate

# تثبيت uv لإدارة الحزم بشكل أسرع
pip install uv

# استنساخ مستودع LEANN
git clone https://github.com/yichuan-w/LEANN.git
cd LEANN

# تهيئة الوحدات الفرعية (مطلوب للتجميع)
git submodule update --init --recursive

# تثبيت LEANN
uv pip install -e .

# التحقق من التثبيت
leann --help
```

### التثبيت العام (مُوصى به)

للوصول على مستوى النظام وتكامل Claude Code:

```bash
# التثبيت العام باستخدام أداة uv
uv tool install leann-core --with leann

# التحقق من التثبيت العام
leann --help
```

## دليل الاستخدام الأساسي

### 1. بناء أول فهرس لك

لنبدأ بمثال بسيط باستخدام وثائق markdown:

```bash
# إنشاء وثائق اختبار
mkdir test-docs
cat > test-docs/ai-overview.md << 'EOF'
# نظرة عامة على الذكاء الاصطناعي

الذكاء الاصطناعي يحول طريقة عملنا وحياتنا. المجالات الرئيسية تشمل:

## التعلم الآلي
- التعلم المُشرف عليه
- التعلم غير المُشرف عليه
- التعلم التعزيزي

## التعلم العميق
- الشبكات العصبية
- الشبكات التطبيقية
- بنية المحولات

## التطبيقات
- معالجة اللغة الطبيعية
- رؤية الحاسوب
- الروبوتات والأتمتة
EOF

# بناء الفهرس
leann build ai-knowledge --docs ./test-docs
```

**الإخراج المتوقع:**
```
📂 Indexing 1 path:
  📁 Directories (1):
    1. /path/to/test-docs
Loading documents from 1 directory...
🔄 Processing 1 directory...
Loaded 1 documents, 3 chunks
Building index 'ai-knowledge' with hnsw backend...
Index built at .leann/indexes/ai-knowledge/documents.leann
```

### 2. البحث في الفهرس

```bash
# البحث الأساسي
leann search ai-knowledge "ما هو التعلم الآلي؟"

# البحث مع المزيد من النتائج
leann search ai-knowledge "الشبكات العصبية" --top-k 10

# البحث المتقدم مع ضبط التعقيد
leann search ai-knowledge "تطبيقات الذكاء الاصطناعي" --complexity 128
```

### 3. الأسئلة والأجوبة التفاعلية

```bash
# بدء المحادثة التفاعلية (يتطلب Ollama)
leann ask ai-knowledge --interactive

# استخدام مزود LLM محدد
leann ask ai-knowledge --llm openai --model gpt-4

# وضع السؤال الواحد
leann ask ai-knowledge "اشرح مفاهيم التعلم العميق"
```

### 4. إدارة الفهارس

```bash
# عرض قائمة جميع الفهارس
leann list

# إزالة فهرس
leann remove ai-knowledge

# الإزالة القسرية بدون تأكيد
leann remove ai-knowledge --force
```

## الميزات المتقدمة

### الفهرسة متعددة المصادر

LEANN يتفوق في فهرسة أنواع المحتوى المتنوعة:

```bash
# فهرسة عدة مجلدات وملفات
leann build comprehensive-docs \
  --docs ./documentation ./source-code ./config-files

# فهرسة أنواع ملفات محددة فقط
leann build presentations \
  --docs ./content \
  --file-types .pptx,.pdf,.docx

# فهرسة المحتوى المختلط
leann build mixed-content \
  --docs ./readme.md ./src/ ./config.json ./docs/
```

### اختيار الخلفية

LEANN يوفر خلفيتين قويتين:

#### خلفية HNSW (افتراضية)
- **الأفضل لـ**: معظم حالات الاستخدام، أقصى توفير في التخزين
- **الميزات**: إعادة حساب كاملة، مثالية للبيئات محدودة الذاكرة

```bash
leann build my-index --docs ./data --backend hnsw
```

#### خلفية DiskANN
- **الأفضل لـ**: مجموعات البيانات الكبيرة التي تتطلب أقصى سرعة بحث
- **الميزات**: اجتياز الرسم البياني القائم على PQ مع إعادة الترتيب في الوقت الفعلي

```bash
leann build my-index --docs ./data --backend diskann
```

### ضبط الأداء

#### معاملات البناء

```bash
# فهرس عالي الجودة (بناء أبطأ، بحث أفضل)
leann build high-quality \
  --docs ./data \
  --graph-degree 64 \
  --complexity 128

# بناء سريع (فهرسة أسرع، جيد للتطوير)
leann build fast-build \
  --docs ./data \
  --graph-degree 16 \
  --complexity 32

# تخزين مضغوط (أقصى توفير في المساحة)
leann build compact \
  --docs ./data \
  --compact
```

#### تحسين البحث

```bash
# بحث عالي الدقة
leann search my-index "استعلام" \
  --complexity 128 \
  --top-k 20

# بحث سريع (دقة أقل)
leann search my-index "استعلام" \
  --complexity 32 \
  --top-k 5

# استراتيجيات التقليم
leann search my-index "استعلام" \
  --pruning-strategy proportional
```

### تصفية البيانات الوصفية

LEANN يدعم تصفية البيانات الوصفية المتطورة:

```python
# مثال Python API
from leann import IndexBuilder, IndexSearcher

# البناء مع البيانات الوصفية
builder = IndexBuilder("filtered-index")
builder.add_text(
    "Python هي لغة برمجة",
    metadata={"language": "python", "difficulty": "beginner"}
)
builder.add_text(
    "مفاهيم التعلم الآلي المتقدمة",
    metadata={"topic": "ml", "difficulty": "advanced"}
)
builder.build()

# البحث مع المرشحات
searcher = IndexSearcher("filtered-index")
results = searcher.search(
    "مفاهيم البرمجة",
    metadata_filters={
        "difficulty": {"==": "beginner"},
        "language": {"in": ["python", "javascript"]}
    }
)
```

**عوامل التصفية المدعومة:**
- `==`, `!=`: المساواة/عدم المساواة
- `<`, `<=`, `>`, `>=`: المقارنات الرقمية
- `in`, `not_in`: عضوية القائمة
- `contains`, `starts_with`, `ends_with`: عمليات النص
- `is_true`, `is_false`: القيم المنطقية

## الفهرسة الواعية للكود

LEANN يوفر معالجة ذكية للكود مع تقسيم واعٍ لـ AST:

```bash
# فهرسة كود المصدر مع التقسيم الذكي
leann build codebase \
  --docs ./src ./tests ./config \
  --file-types .py,.js,.ts,.java,.cs

# النظام تلقائياً:
# - يحلل هيكل AST
# - يحافظ على حدود الدوال/الفئات
# - يحتفظ بسياق الكود
# - يفهرس التعليقات والتوثيق
```

**اللغات المدعومة:**
- Python
- JavaScript/TypeScript
- Java
- C#
- المزيد من اللغات قادم قريباً

## أمثلة التكامل

### تكامل Claude Code

LEANN يتكامل بسلاسة مع Claude Code عبر MCP (Model Context Protocol):

1. **التثبيت العام** (مطلوب):
```bash
uv tool install leann-core --with leann
```

2. **تكوين Claude Code** بإضافة إلى إعدادات MCP:
```json
{
  "mcpServers": {
    "leann": {
      "command": "leann_mcp"
    }
  }
}
```

3. **الاستخدام في Claude Code**:
```
@leann search my-codebase "منطق المصادقة"
@leann ask my-docs "كيفية تنفيذ OAuth؟"
```

### استخدام Python API

```python
from leann import IndexBuilder, IndexSearcher

# بناء الفهرس برمجياً
builder = IndexBuilder("my-index")
builder.add_directory("./documents")
builder.add_file("./important-doc.pdf")
builder.build(backend="hnsw", graph_degree=32)

# البحث برمجياً
searcher = IndexSearcher("my-index")
results = searcher.search("التعلم الآلي", top_k=10)

for result in results:
    print(f"النقاط: {result.score}")
    print(f"المحتوى: {result.content[:200]}...")
    print(f"البيانات الوصفية: {result.metadata}")
    print("---")
```

### تكامل LangChain

```python
from leann.integrations.langchain import LeannVectorStore
from langchain.chains import RetrievalQA
from langchain.llms import Ollama

# إنشاء مخزن LEANN الشعاعي
vector_store = LeannVectorStore("my-index")

# إنشاء سلسلة الاسترجاع
llm = Ollama(model="llama2")
qa_chain = RetrievalQA.from_chain_type(
    llm=llm,
    chain_type="stuff",
    retriever=vector_store.as_retriever(search_kwargs={"k": 5})
)

# طرح الأسئلة
response = qa_chain.run("ما هي الميزات الرئيسية لهذا النظام؟")
print(response)
```

## معايير الأداء

### مقارنة التخزين

توفير التخزين الفعلي عبر مجموعات بيانات مختلفة:

```bash
# تشغيل المعايير (يتطلب تبعيات التطوير)
uv pip install -e ".[dev]"
python benchmarks/run_evaluation.py

# معيار مخصص مع بياناتك
python benchmarks/run_evaluation.py /path/to/your/data --num-queries 1000
```

### مقايضات السرعة مقابل الدقة

| التكوين | وقت البناء | سرعة البحث | الدقة | التخزين |
|---------|------------|-------------|-------|---------|
| سريع | 1x | 5ms | 85% | توفير 95% |
| متوازن | 2x | 8ms | 92% | توفير 96% |
| عالي الجودة | 4x | 12ms | 97% | توفير 97% |

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

#### 1. خطأ تهيئة الوحدة الفرعية
```bash
# خطأ: لا يمكن العثور على CMakeLists.txt
git submodule update --init --recursive
```

#### 2. مشاكل الذاكرة أثناء البناء
```bash
# استخدام التخزين المضغوط لمجموعات البيانات الكبيرة
leann build large-index --docs ./big-data --compact

# أو المعالجة في دفعات أصغر
leann build batch1 --docs ./data/part1
leann build batch2 --docs ./data/part2
```

#### 3. البحث لا يعطي نتائج
```bash
# فحص حالة الفهرس
leann list

# التحقق من سلامة الفهرس
leann search my-index "استعلام اختبار" --top-k 1

# إعادة البناء إذا كان تالفاً
leann remove my-index --force
leann build my-index --docs ./data
```

#### 4. أداء بحث بطيء
```bash
# تقليل التعقيد للبحث الأسرع
leann search my-index "استعلام" --complexity 32

# استخدام الخلفية المناسبة
leann build my-index --docs ./data --backend diskann
```

### نصائح تحسين الأداء

1. **اختيار الخلفية الصحيحة**:
   - HNSW: أقصى توفير في التخزين، جيد لمعظم حالات الاستخدام
   - DiskANN: أداء بحث أفضل لمجموعات البيانات الكبيرة

2. **ضبط معاملات البناء**:
   - `graph-degree` أعلى: اتصال أفضل، فهرس أكبر
   - `complexity` أعلى: جودة أفضل، بناء أبطأ

3. **تحسين معاملات البحث**:
   - `complexity` أقل: بحث أسرع، دقة أقل
   - `top-k` مناسب: توازن بين السرعة والاكتمال

4. **استخدام تصفية البيانات الوصفية**:
   - تصفية الوثائق مسبقاً لتقليل مساحة البحث
   - الجمع مع البحث الدلالي للحصول على أفضل النتائج

## أفضل الممارسات

### 1. إعداد الوثائق

```bash
# جيد: تنظيم الوثائق منطقياً
project/
├── docs/           # الوثائق
├── code/          # كود المصدر
├── configs/       # ملفات التكوين
└── examples/      # ملفات الأمثلة

# الفهرسة مع التقسيم المناسب
leann build project-knowledge --docs ./project
```

### 2. استراتيجية تسمية الفهارس

```bash
# استخدام أسماء وصفية
leann build customer-support-kb --docs ./support-docs
leann build api-documentation --docs ./api-docs
leann build codebase-v2-1 --docs ./src

# تجنب الأسماء العامة
leann build docs --docs ./documents  # عام جداً
leann build index1 --docs ./data     # غير وصفي
```

### 3. الصيانة المنتظمة

```bash
# عرض وتنظيف الفهارس القديمة
leann list
leann remove outdated-index

# إعادة بناء الفهارس عند تغيير الوثائق المصدرية بشكل كبير
leann remove old-version --force
leann build new-version --docs ./updated-docs
```

### 4. النشر في الإنتاج

```bash
# استخدام معاملات بناء متسقة للإنتاج
leann build production-index \
  --docs ./production-docs \
  --backend diskann \
  --graph-degree 64 \
  --complexity 128 \
  --compact

# اختبار أداء البحث
time leann search production-index "استعلام اختبار"
```

## حالات الاستخدام المتقدمة

### 1. الوثائق متعددة اللغات

```bash
# فهرسة الوثائق بعدة لغات
leann build multilang-docs \
  --docs ./docs/en ./docs/ar ./docs/ja

# البحث يعمل عبر جميع اللغات
leann search multilang-docs "دليل التثبيت"
```

### 2. قاعدة المعرفة المُدارة بالإصدارات

```bash
# إنشاء فهارس مُصدرة
leann build kb-v1.0 --docs ./docs/v1.0
leann build kb-v1.1 --docs ./docs/v1.1
leann build kb-latest --docs ./docs/latest

# مقارنة نتائج البحث عبر الإصدارات
leann search kb-v1.0 "الميزة X"
leann search kb-latest "الميزة X"
```

### 3. أنظمة البحث الهجينة

```python
# دمج LEANN مع البحث التقليدي
from leann import IndexSearcher
import elasticsearch

def hybrid_search(query, top_k=10):
    # البحث الدلالي مع LEANN
    leann_searcher = IndexSearcher("my-index")
    semantic_results = leann_searcher.search(query, top_k=top_k//2)
    
    # البحث بالكلمات المفتاحية مع Elasticsearch
    es_results = elasticsearch_search(query, size=top_k//2)
    
    # دمج وإعادة ترتيب النتائج
    return combine_results(semantic_results, es_results)
```

## خارطة الطريق المستقبلية

LEANN يتم تطويره بنشاط مع ميزات مثيرة قادمة:

- **دعم Windows**: توافق Windows الأصلي
- **الفهرسة الموزعة**: التوسع عبر عدة أجهزة
- **التحديثات في الوقت الفعلي**: تحديثات الفهرس التدريجية
- **المزيد من الخلفيات**: استراتيجيات تحسين إضافية
- **تكامل السحابة**: دعم التخزين السحابي الأصلي
- **التصفية المتقدمة**: استعلامات البيانات الوصفية الأكثر تطوراً

## الخلاصة

LEANN يمثل تحولاً في نموذج الفهرسة الشعاعية، حيث يوفر كفاءة تخزين غير مسبوقة دون التضحية بجودة البحث. نهجه المبتكر القائم على الرسم البياني يجعله مثالياً لـ:

- **البيئات محدودة الموارد** حيث التخزين ثمين
- **تطبيقات RAG واسعة النطاق** التي تتطلب استرجاعاً فعالاً
- **سيناريوهات الحوسبة الطرفية** مع ذاكرة محدودة
- **النشر الحساس للتكلفة** حيث تكاليف التخزين مهمة

باتباع هذا الدليل، لديك الآن المعرفة للاستفادة من قدرات LEANN الثورية في مشاريعك الخاصة. توفير 97% من التخزين، مقترناً بالبحث السريع والدقيق، يجعل LEANN أداة أساسية لتطبيقات الذكاء الاصطناعي الحديثة.

### الخطوات التالية

1. **التجريب**: جرب مع مجموعات البيانات الخاصة بك
2. **التكامل**: دمج LEANN في خطوط أنابيب RAG الموجودة
3. **المساهمة**: المساهمة في المشروع مفتوح المصدر
4. **المشاركة**: شارك تجاربك مع المجتمع

---

**🔗 روابط مفيدة:**
- [مستودع LEANN على GitHub](https://github.com/yichuan-w/LEANN)
- [الورقة البحثية](https://arxiv.org/abs/2506.08276)
- [Berkeley Sky Computing Lab](https://sky.cs.berkeley.edu/)
- [مناقشات المجتمع](https://github.com/yichuan-w/LEANN/discussions)

**⭐ ضع نجمة على المشروع إذا وجدت LEANN مفيداً لعملك!**
