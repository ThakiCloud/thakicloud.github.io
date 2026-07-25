---
title: "AWS Agent Squad: دليل شامل لإطار تنسيق الوكلاء المتعددة"
excerpt: "دليل شامل لإطار Agent Squad من AWS Labs - من الإعداد الأساسي إلى تنسيق الوكلاء المتعددة المتقدم مع تطبيقات Python و TypeScript"
seo_title: "دليل AWS Agent Squad: إطار تنسيق الوكلاء المتعددة للذكاء الاصطناعي"
seo_description: "تعلم إطار AWS Agent Squad لتنسيق الوكلاء المتعددة للذكاء الاصطناعي. دليل شامل مع أمثلة Python/TypeScript وتكامل Bedrock والتطبيقات العملية."
date: 2025-09-07
tags:
  - aws
  - agent-squad
  - الوكلاء-المتعددة
  - التنسيق
  - bedrock
  - ai-agents
  - python
  - typescript
author_profile: true
toc: true
toc_label: "محتويات الدليل"
lang: ar
permalink: /ar/tutorials/aws-agent-squad-multi-agent-orchestration-framework-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/aws-agent-squad-multi-agent-orchestration-framework-tutorial/"
published: false
categories:
  - tutorials
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة حول Agent Squad

**Agent Squad** من AWS Labs (المعروف سابقاً باسم Multi-Agent Orchestrator) هو إطار عمل مفتوح المصدر مرن وخفيف الوزن مصمم لتنسيق وكلاء الذكاء الاصطناعي المتعددة للتعامل مع المحادثات المعقدة. مع أكثر من 6.6 ألف نجمة على GitHub ودعم مجتمعي متنامٍ، يمثل تقدماً مهماً في أنظمة الذكاء الاصطناعي متعددة الوكلاء.

### ما يجعل Agent Squad مميزاً

يعالج Agent Squad الحاجة المتزايدة للتوجيه الذكي للمحادثات في تطبيقات الذكاء الاصطناعي. بدلاً من وجود وكيل ذكاء اصطناعي واحد يتعامل مع جميع الاستعلامات، يقوم بتوزيع المحادثات بذكاء على وكلاء متخصصين بناءً على السياق والقصد.

## الميزات والقدرات الرئيسية

### 🧠 تصنيف القصد الذكي
يوجه الإطار الاستعلامات ديناميكياً إلى الوكيل الأنسب بناءً على:
- **تحليل السياق**: فهم تدفق المحادثة والتاريخ
- **تقييم المحتوى**: تحليل دلالات الاستعلام والقصد
- **تخصص الوكيل**: مطابقة الاستعلامات مع خبرة الوكيل

### 🔤 دعم لغة مزدوجة
تطبيق كامل في كل من **Python** و **TypeScript**:
- وظائف متطابقة عبر اللغات
- تحسينات خاصة باللغة
- تكامل سلس مع قواعد الكود الموجودة

### 🌊 معالجة استجابة مرنة
دعم للاستجابات المتدفقة وغير المتدفقة:
- **التدفق في الوقت الفعلي**: للمحادثات التفاعلية
- **المعالجة المجمعة**: للمهام التحليلية
- **دعم الوضع المختلط**: وكلاء مختلفون يمكنهم استخدام أنواع استجابة مختلفة

### 📚 إدارة السياق
معالجة سياق المحادثة المتطورة:
- **ذاكرة عبر الوكلاء**: الحفاظ على السياق عند التبديل بين الوكلاء
- **استمرارية الجلسة**: تذكر تاريخ المحادثة
- **وراثة السياق**: تمرير المعلومات ذات الصلة بين الوكلاء

## نظرة عامة على البنية المعمارية

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
<div class="d3-arch" data-arch-root id="ationframeworktutorialar-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 701, "height": 1100, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 276, "y": 24, "w": 142, "h": 46, "title": "استعلام المستخدم"}, {"id": "B", "x": 276, "y": 148, "w": 142, "h": 46, "title": "منسق Agent Squad"}, {"id": "C", "x": 287, "y": 272, "w": 120, "h": 46, "title": "مصنف القصد"}, {"id": "D", "x": 278, "y": 396, "w": 138, "h": 52, "title": "قرار التوجيه"}, {"id": "E", "x": 549, "y": 526, "w": 120, "h": 46, "title": "وكيل التقنية"}, {"id": "F", "x": 374, "y": 526, "w": 120, "h": 46, "title": "وكيل الصحة"}, {"id": "G", "x": 199, "y": 526, "w": 120, "h": 46, "title": "وكيل السفر"}, {"id": "H", "x": 24, "y": 526, "w": 120, "h": 46, "title": "وكيل مخصص"}, {"id": "I", "x": 549, "y": 650, "w": 120, "h": 46, "title": "Bedrock LLM"}, {"id": "J", "x": 374, "y": 650, "w": 120, "h": 46, "title": "OpenAI GPT"}, {"id": "K", "x": 199, "y": 650, "w": 120, "h": 46, "title": "Lex Bot"}, {"id": "L", "x": 24, "y": 650, "w": 120, "h": 46, "title": "دالة Lambda"}, {"id": "M", "x": 279, "y": 774, "w": 135, "h": 46, "title": "معالج الاستجابة"}, {"id": "N", "x": 287, "y": 898, "w": 120, "h": 46, "title": "مدير السياق"}, {"id": "O", "x": 269, "y": 1022, "w": 156, "h": 46, "title": "الاستجابة النهائية"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [347, 70, 347, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [347, 194, 347, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [347, 318, 347, 396]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[416, 439], [609, 487], [609, 487], [609, 526]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[382, 448], [434, 487], [434, 487], [434, 526]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[312, 448], [259, 487], [259, 487], [259, 526]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[278, 439], [84, 487], [84, 487], [84, 526]]}, {"src": "E", "dst": "I", "kind": "data", "line": [609, 572, 609, 650]}, {"src": "F", "dst": "J", "kind": "data", "line": [434, 572, 434, 650]}, {"src": "G", "dst": "K", "kind": "data", "line": [259, 572, 259, 650]}, {"src": "H", "dst": "L", "kind": "data", "line": [84, 572, 84, 650]}, {"src": "I", "dst": "M", "kind": "data", "curve": [[609, 696], [609, 735], [609, 735], [414, 781]]}, {"src": "J", "dst": "M", "kind": "data", "curve": [[434, 696], [434, 735], [434, 735], [379, 774]]}, {"src": "K", "dst": "M", "kind": "data", "curve": [[259, 696], [259, 735], [259, 735], [314, 774]]}, {"src": "L", "dst": "M", "kind": "data", "curve": [[84, 696], [84, 735], [84, 735], [279, 781]]}, {"src": "M", "dst": "N", "kind": "data", "line": [347, 820, 347, 898]}, {"src": "N", "dst": "O", "kind": "data", "line": [347, 944, 347, 1022]}]});
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
      const container = document.getElementById('ationframeworktutorialar-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ationframeworktutorialar-1';
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

تتكون البنية من:
1. **المنسق**: التوجيه والإدارة المركزية
2. **المصنفات**: اكتشاف القصد واختيار الوكيل
3. **الوكلاء**: مكونات الذكاء الاصطناعي المتخصصة
4. **مدير السياق**: إدارة الذاكرة والحالة
5. **معالج الاستجابة**: معالجة وتنسيق الإخراج

## التثبيت والإعداد

### تثبيت Python

يوفر Agent Squad خيارات تثبيت معيارية بناءً على احتياجات التكامل:

```bash
# التكامل الأساسي مع AWS (الأكثر شيوعاً)
pip install "agent-squad[aws]"

# تكامل OpenAI
pip install "agent-squad[openai]"

# تكامل Anthropic
pip install "agent-squad[anthropic]"

# التثبيت الكامل مع جميع التكاملات
pip install "agent-squad[all]"
```

### إعداد البيئة

إنشاء بيئة افتراضية للعزل:

```bash
# إنشاء بيئة افتراضية
python -m venv agent-squad-env
source agent-squad-env/bin/activate  # في Windows: agent-squad-env\Scripts\activate

# التثبيت مع دعم AWS
pip install "agent-squad[aws]"
```

### تثبيت TypeScript/Node.js

```bash
# تهيئة مشروع جديد
npm init -y

# تثبيت Agent Squad
npm install @awslabs/agent-squad

# تثبيت AWS SDK (عند استخدام تكاملات AWS)
npm install @aws-sdk/client-bedrock-runtime
```

## دليل التطبيق الأساسي

### تطبيق Python

لننشئ نظام وكلاء متعددة أساسي مع وكلاء متخصصين:

```python
import sys
import asyncio
from agent_squad.orchestrator import AgentSquad
from agent_squad.agents import BedrockLLMAgent, BedrockLLMAgentOptions, AgentStreamResponse

class AgentSquadTutorial:
    def __init__(self):
        # تهيئة المنسق
        self.orchestrator = AgentSquad()
        
        # إعداد الوكلاء
        self._setup_agents()
    
    def _setup_agents(self):
        """إعداد وكلاء متخصصين لمجالات مختلفة"""
        
        # وكيل متخصص في التقنية
        tech_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="خبير التقنية",
            streaming=True,
            description="""خبير في تطوير البرمجيات، الحوسبة السحابية، الذكاء الاصطناعي/تعلم الآلة، 
                         الأمن السيبراني، البلوك تشين، والتقنيات الناشئة. 
                         يقدم إرشادات تقنية، نصائح معمارية، وتحليل تكلفة 
                         للحلول التقنية.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # وكيل الصحة والعافية
        health_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="خبير الصحة والعافية",
            streaming=True,
            description="""متخصص في الصحة، العافية، التغذية، اللياقة البدنية، 
                         الصحة النفسية، والمعلومات الطبية. يقدم 
                         إرشادات صحية قائمة على الأدلة ونصائح العافية.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # وكيل الأعمال والمالية
        business_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name="خبير الأعمال والمالية",
            streaming=True,
            description="""خبير في استراتيجية الأعمال، التخطيط المالي، 
                         تحليل السوق، ريادة الأعمال، وعمليات الأعمال. 
                         يقدم رؤى الأعمال الاستراتيجية.""",
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
        ))
        
        # إضافة الوكلاء إلى المنسق
        self.orchestrator.add_agent(tech_agent)
        self.orchestrator.add_agent(health_agent)
        self.orchestrator.add_agent(business_agent)
    
    async def process_query(self, user_input, user_id="user123", session_id="session456"):
        """معالجة استعلام المستخدم عبر فريق الوكلاء"""
        
        try:
            # توجيه الطلب إلى الوكيل المناسب
            response = await self.orchestrator.route_request(
                user_input=user_input,
                user_id=user_id,
                session_id=session_id,
                additional_params={},
                streaming=True
            )
            
            # معالجة الاستجابة
            await self._handle_response(response)
            
        except Exception as e:
            print(f"خطأ في معالجة الاستعلام: {e}")
    
    async def _handle_response(self, response):
        """معالجة الاستجابات المتدفقة وغير المتدفقة"""
        
        if response.streaming:
            print("\n🤖 **استجابة متدفقة**\n")
            
            # عرض البيانات الوصفية
            self._print_metadata(response.metadata)
            
            print("\n📝 **الاستجابة:**")
            
            # تدفق المحتوى
            async for chunk in response.output:
                if isinstance(chunk, AgentStreamResponse):
                    print(chunk.text, end='', flush=True)
                else:
                    print(f"نوع جزء غير متوقع: {type(chunk)}", file=sys.stderr)
            
            print("\n")  # سطر جديد بعد التدفق
            
        else:
            # معالجة الاستجابة غير المتدفقة
            print("\n🤖 **استجابة**\n")
            self._print_metadata(response.metadata)
            print(f"\n📝 **الاستجابة:** {response.output.content}")
    
    def _print_metadata(self, metadata):
        """طباعة البيانات الوصفية للاستجابة بشكل منسق"""
        print(f"🎯 **الوكيل:** {metadata.agent_name} (المعرف: {metadata.agent_id})")
        print(f"👤 **المستخدم:** {metadata.user_id}")
        print(f"🔗 **الجلسة:** {metadata.session_id}")
        print(f"❓ **الاستعلام:** {metadata.user_input}")
        if metadata.additional_params:
            print(f"⚙️ **المعاملات:** {metadata.additional_params}")

# مثال على الاستخدام والاختبار
async def main():
    """الدالة الرئيسية لعرض قدرات Agent Squad"""
    
    # تهيئة نظام الدليل
    agent_system = AgentSquadTutorial()
    
    # استعلامات اختبار لمجالات مختلفة
    test_queries = [
        "ما هي أفضل الممارسات لتطبيق معمارية الخدمات المصغرة؟",
        "كيف يمكنني تحسين صحة القلب والأوعية الدموية من خلال النظام الغذائي والتمارين؟",
        "ما الذي يجب مراعاته عند إنشاء خطة عمل لشركة تقنية ناشئة؟",
        "اشرح الاختلافات بين حاويات Docker والأجهزة الافتراضية",
        "ما هي تقنيات إدارة الضغط الفعالة للمهنيين المشغولين؟"
    ]
    
    print("🚀 **عرض توضيحي لدليل Agent Squad**\n")
    print("=" * 50)
    
    for i, query in enumerate(test_queries, 1):
        print(f"\n**استعلام الاختبار {i}:**")
        print("-" * 30)
        await agent_system.process_query(query)
        print("=" * 50)

if __name__ == "__main__":
    asyncio.run(main())
```

### تطبيق TypeScript

إليك التطبيق المكافئ في TypeScript:

```typescript
import { AgentSquad } from '@awslabs/agent-squad';
import { BedrockLLMAgent, BedrockLLMAgentOptions } from '@awslabs/agent-squad';

class AgentSquadTutorial {
    private orchestrator: AgentSquad;
    
    constructor() {
        this.orchestrator = new AgentSquad();
        this.setupAgents();
    }
    
    private setupAgents(): void {
        // وكيل خبير التقنية
        const techAgent = new BedrockLLMAgent({
            name: 'خبير التقنية',
            streaming: true,
            description: `خبير في تطوير البرمجيات، الحوسبة السحابية، الذكاء الاصطناعي/تعلم الآلة، 
                         الأمن السيبراني، البلوك تشين، والتقنيات الناشئة.`,
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
        } as BedrockLLMAgentOptions);
        
        // وكيل الصحة والعافية
        const healthAgent = new BedrockLLMAgent({
            name: 'خبير الصحة والعافية',
            streaming: true,
            description: `متخصص في الصحة، العافية، التغذية، اللياقة البدنية، 
                         الصحة النفسية، والمعلومات الطبية.`,
            modelId: 'anthropic.claude-3-sonnet-20240229-v1:0',
        } as BedrockLLMAgentOptions);
        
        // إضافة الوكلاء إلى المنسق
        this.orchestrator.addAgent(techAgent);
        this.orchestrator.addAgent(healthAgent);
    }
    
    async processQuery(
        userInput: string, 
        userId: string = 'user123', 
        sessionId: string = 'session456'
    ): Promise<void> {
        try {
            const response = await this.orchestrator.routeRequest(
                userInput,
                userId,
                sessionId,
                {},
                true
            );
            
            await this.handleResponse(response);
            
        } catch (error) {
            console.error('خطأ في معالجة الاستعلام:', error);
        }
    }
    
    private async handleResponse(response: any): Promise<void> {
        if (response.streaming) {
            console.log('\n🤖 **استجابة متدفقة**\n');
            
            // عرض البيانات الوصفية
            this.printMetadata(response.metadata);
            
            console.log('\n📝 **الاستجابة:**');
            
            // معالجة الاستجابة المتدفقة
            for await (const chunk of response.output) {
                if (chunk.text) {
                    process.stdout.write(chunk.text);
                }
            }
            
            console.log('\n');
            
        } else {
            console.log('\n🤖 **استجابة**\n');
            this.printMetadata(response.metadata);
            console.log(`\n📝 **الاستجابة:** ${response.output.content}`);
        }
    }
    
    private printMetadata(metadata: any): void {
        console.log(`🎯 **الوكيل:** ${metadata.agentName} (المعرف: ${metadata.agentId})`);
        console.log(`👤 **المستخدم:** ${metadata.userId}`);
        console.log(`🔗 **الجلسة:** ${metadata.sessionId}`);
        console.log(`❓ **الاستعلام:** ${metadata.userInput}`);
    }
}

// مثال على الاستخدام
async function main() {
    const agentSystem = new AgentSquadTutorial();
    
    const testQueries = [
        "ما هي أحدث الاتجاهات في الحوسبة السحابية؟",
        "كيف يمكنني الحفاظ على صحة نفسية جيدة أثناء العمل عن بُعد؟"
    ];
    
    console.log('🚀 **عرض توضيحي لدليل Agent Squad (TypeScript)**\n');
    
    for (const query of testQueries) {
        await agentSystem.processQuery(query);
        console.log('='.repeat(50));
    }
}

main().catch(console.error);
```

## التكوين المتقدم

### إنشاء وكيل مخصص

يمكنك إنشاء وكلاء مخصصين عن طريق توسيع فئة الوكيل الأساسية:

```python
from agent_squad.agents import Agent, AgentOptions
from typing import Optional, Dict, Any

class CustomDatabaseAgent(Agent):
    def __init__(self, options: AgentOptions):
        super().__init__(options)
        # تهيئة اتصالات قاعدة البيانات، الأدوات، إلخ.
        
    async def process_request(
        self, 
        input_text: str, 
        user_id: str, 
        session_id: str, 
        chat_history: list,
        additional_params: Optional[Dict[str, Any]] = None
    ):
        # منطق المعالجة المخصص
        # استعلام قواعد البيانات، إجراء الحسابات، إلخ.
        
        # إرجاع استجابة منظمة
        return {
            "content": "نتائج استعلام قاعدة البيانات...",
            "metadata": {
                "query_time": "0.5 ثانية",
                "records_found": 42
            }
        }
```

### تكوين المنسق المتقدم

```python
from agent_squad.orchestrator import AgentSquad
from agent_squad.classifiers import BedrockClassifier, BedrockClassifierOptions

# إنشاء منسق مع مصنف مخصص
classifier = BedrockClassifier(BedrockClassifierOptions(
    model_id="anthropic.claude-3-haiku-20240307-v1:0",
    inference_config={
        "maxTokens": 1000,
        "temperature": 0.1
    }
))

orchestrator = AgentSquad(
    classifier=classifier,
    logger=custom_logger,
    config={
        "LOG_AGENT_CHAT": True,
        "LOG_CLASSIFIER_CHAT": True,
        "LOG_CLASSIFIER_RAW_OUTPUT": True,
        "LOG_CLASSIFIER_OUTPUT": True,
        "LOG_EXECUTION_TIMES": True,
        "MAX_RETRIES": 3,
        "USE_DEFAULT_AGENT_IF_NONE_IDENTIFIED": True,
        "MAX_TOKENS": 1000,
        "TEMPERATURE": 0.1
    }
)
```

## حالات الاستخدام الواقعية والأمثلة

### أتمتة خدمة العملاء

```python
async def setup_customer_service_agents():
    """إعداد وكلاء خدمة العملاء المتخصصين"""
    
    orchestrator = AgentSquad()
    
    # وكيل الدعم التقني
    tech_support = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="الدعم التقني",
        description="يتعامل مع المشاكل التقنية، استكشاف الأخطاء، ودعم المنتجات",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    # وكيل الفوترة والحساب
    billing_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="دعم الفوترة",
        description="يتعامل مع استفسارات الفوترة، إدارة الحساب، ومشاكل الدفع",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    # وكيل المعلومات العامة
    info_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="وكيل المعلومات",
        description="يقدم معلومات الشركة العامة، السياسات، والاستفسارات الأساسية",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    orchestrator.add_agent(tech_support)
    orchestrator.add_agent(billing_agent)
    orchestrator.add_agent(info_agent)
    
    return orchestrator
```

### منصة تعليمية

```python
async def setup_educational_agents():
    """إعداد وكلاء لمواد أكاديمية مختلفة"""
    
    orchestrator = AgentSquad()
    
    subjects = [
        ("الرياضيات", "خبير في الرياضيات، التفاضل والتكامل، الإحصاء، وحل المشاكل"),
        ("العلوم", "متخصص في الفيزياء، الكيمياء، الأحياء، والمفاهيم العلمية"),
        ("الأدب", "خبير في تحليل الأدب، الكتابة، وفنون اللغة"),
        ("التاريخ", "متخصص في التاريخ العالمي، التحليل التاريخي، والدراسات الاجتماعية")
    ]
    
    for name, description in subjects:
        agent = BedrockLLMAgent(BedrockLLMAgentOptions(
            name=f"مدرس {name}",
            description=description,
            model_id="anthropic.claude-3-sonnet-20240229-v1:0",
            streaming=True
        ))
        orchestrator.add_agent(agent)
    
    return orchestrator
```

## تحسين الأداء

### تجميع الاتصالات والتخزين المؤقت

```python
from agent_squad.orchestrator import AgentSquad
import asyncio
from functools import lru_cache

class OptimizedAgentSquad:
    def __init__(self):
        self.orchestrator = AgentSquad()
        self._connection_pool = self._setup_connection_pool()
        self._setup_caching()
    
    def _setup_connection_pool(self):
        """إعداد تجميع الاتصالات لأداء أفضل"""
        # تكوين تجمعات الاتصال لخدمات مختلفة
        return {
            'bedrock': self._create_bedrock_pool(),
            'openai': self._create_openai_pool(),
        }
    
    @lru_cache(maxsize=1000)
    def _cached_classification(self, query_hash: str):
        """تخزين مؤقت لنتائج التصنيف للاستعلامات المشابهة"""
        # تطبيق التخزين المؤقت لنتائج التصنيف
        pass
    
    async def batch_process_queries(self, queries: list):
        """معالجة استعلامات متعددة بشكل متزامن"""
        tasks = [
            self.orchestrator.route_request(query, f"user_{i}", f"session_{i}")
            for i, query in enumerate(queries)
        ]
        
        results = await asyncio.gather(*tasks, return_exceptions=True)
        return results
```

### المراقبة والتسجيل

```python
import logging
import time
from functools import wraps

class AgentSquadMonitor:
    def __init__(self, orchestrator):
        self.orchestrator = orchestrator
        self.logger = logging.getLogger('agent_squad_monitor')
        self._setup_monitoring()
    
    def _setup_monitoring(self):
        """إعداد مراقبة شاملة"""
        self.metrics = {
            'total_requests': 0,
            'successful_requests': 0,
            'failed_requests': 0,
            'average_response_time': 0,
            'agent_usage': {}
        }
    
    def monitor_request(self, func):
        """مزخرف لمراقبة أداء الطلبات"""
        @wraps(func)
        async def wrapper(*args, **kwargs):
            start_time = time.time()
            self.metrics['total_requests'] += 1
            
            try:
                result = await func(*args, **kwargs)
                self.metrics['successful_requests'] += 1
                
                # تتبع استخدام الوكيل
                agent_name = result.metadata.agent_name
                self.metrics['agent_usage'][agent_name] = \
                    self.metrics['agent_usage'].get(agent_name, 0) + 1
                
                return result
                
            except Exception as e:
                self.metrics['failed_requests'] += 1
                self.logger.error(f"فشل الطلب: {e}")
                raise
                
            finally:
                # تحديث متوسط وقت الاستجابة
                response_time = time.time() - start_time
                self._update_average_response_time(response_time)
        
        return wrapper
    
    def _update_average_response_time(self, response_time):
        """تحديث المتوسط الجاري لأوقات الاستجابة"""
        current_avg = self.metrics['average_response_time']
        total_requests = self.metrics['total_requests']
        
        self.metrics['average_response_time'] = \
            (current_avg * (total_requests - 1) + response_time) / total_requests
    
    def get_performance_report(self):
        """إنتاج تقرير الأداء"""
        return {
            'summary': self.metrics,
            'success_rate': self.metrics['successful_requests'] / self.metrics['total_requests'] * 100,
            'most_used_agent': max(self.metrics['agent_usage'], 
                                 key=self.metrics['agent_usage'].get) if self.metrics['agent_usage'] else None
        }
```

## استراتيجيات النشر

### نشر AWS Lambda

```python
import json
import asyncio
from agent_squad.orchestrator import AgentSquad
from agent_squad.agents import BedrockLLMAgent, BedrockLLMAgentOptions

# مثيل منسق عام لإعادة استخدام حاوية Lambda
orchestrator = None

def lambda_handler(event, context):
    """معالج AWS Lambda لـ Agent Squad"""
    
    global orchestrator
    
    # تهيئة المنسق في البداية الباردة
    if orchestrator is None:
        orchestrator = setup_orchestrator()
    
    # استخراج بيانات الطلب
    body = json.loads(event['body'])
    user_input = body['message']
    user_id = body.get('user_id', 'anonymous')
    session_id = body.get('session_id', 'default')
    
    # معالجة الطلب
    loop = asyncio.new_event_loop()
    asyncio.set_event_loop(loop)
    
    try:
        response = loop.run_until_complete(
            orchestrator.route_request(user_input, user_id, session_id)
        )
        
        return {
            'statusCode': 200,
            'headers': {
                'Content-Type': 'application/json',
                'Access-Control-Allow-Origin': '*'
            },
            'body': json.dumps({
                'response': response.output.content,
                'agent': response.metadata.agent_name,
                'success': True
            })
        }
        
    except Exception as e:
        return {
            'statusCode': 500,
            'body': json.dumps({
                'error': str(e),
                'success': False
            })
        }
    
    finally:
        loop.close()

def setup_orchestrator():
    """إعداد المنسق مع تكوين الإنتاج"""
    squad = AgentSquad()
    
    # إضافة وكلاء الإنتاج
    tech_agent = BedrockLLMAgent(BedrockLLMAgentOptions(
        name="وكيل التقنية للإنتاج",
        description="وكيل دعم تقني جاهز للإنتاج",
        model_id="anthropic.claude-3-sonnet-20240229-v1:0",
    ))
    
    squad.add_agent(tech_agent)
    return squad
```

### نشر Docker

```dockerfile
# Dockerfile لتطبيق Agent Squad
FROM python:3.11-slim

WORKDIR /app

# تثبيت تبعيات النظام
RUN apt-get update && apt-get install -y \
    gcc \
    && rm -rf /var/lib/apt/lists/*

# نسخ requirements وتثبيت تبعيات Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# نسخ كود التطبيق
COPY . .

# كشف المنفذ
EXPOSE 8000

# تعيين متغيرات البيئة
ENV PYTHONPATH=/app
ENV AWS_DEFAULT_REGION=us-east-1

# تشغيل التطبيق
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## أفضل الممارسات والنصائح

### 1. مبادئ تصميم الوكيل

- **المسؤولية الواحدة**: كل وكيل يجب أن يكون له مجال محدد بوضوح
- **الأوصاف الواضحة**: كتابة أوصاف وكيل مفصلة لتوجيه أفضل
- **تحسين الأداء**: استخدام أحجام نماذج مناسبة لمهام مختلفة
- **معالجة الأخطاء**: تنفيذ معالجة أخطاء قوية وآليات احتياطية

### 2. إدارة السياق

```python
# إدارة سياق المحادثة الفعالة
async def manage_conversation_context(orchestrator, user_id, session_id):
    """أفضل الممارسات لإدارة السياق"""
    
    # تخزين معلومات السياق المهمة
    context = {
        'user_preferences': get_user_preferences(user_id),
        'conversation_history': get_conversation_history(session_id),
        'current_task': 'information_gathering'
    }
    
    # تمرير السياق عبر additional_params
    response = await orchestrator.route_request(
        user_input="تابع مناقشتنا السابقة",
        user_id=user_id,
        session_id=session_id,
        additional_params=context
    )
    
    return response
```

### 3. اعتبارات الأمان

```python
# التحقق من صحة المدخلات وتطهيرها
def validate_input(user_input: str) -> bool:
    """التحقق من صحة مدخلات المستخدم للأمان"""
    
    # فحص المحتوى الضار
    forbidden_patterns = [
        r'<script.*?</script>',
        r'javascript:',
        r'on\w+\s*='
    ]
    
    import re
    for pattern in forbidden_patterns:
        if re.search(pattern, user_input, re.IGNORECASE):
            return False
    
    # فحص طول المدخل
    if len(user_input) > 10000:
        return False
    
    return True

# تنفيذ تحديد المعدل
from collections import defaultdict
import time

class RateLimiter:
    def __init__(self, max_requests=100, time_window=3600):
        self.max_requests = max_requests
        self.time_window = time_window
        self.requests = defaultdict(list)
    
    def is_allowed(self, user_id: str) -> bool:
        now = time.time()
        user_requests = self.requests[user_id]
        
        # إزالة الطلبات القديمة
        self.requests[user_id] = [
            req_time for req_time in user_requests 
            if now - req_time < self.time_window
        ]
        
        # فحص ما إذا كان تحت الحد
        if len(self.requests[user_id]) < self.max_requests:
            self.requests[user_id].append(now)
            return True
        
        return False
```

## دليل استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

1. **مشاكل اختيار الوكيل**
   ```python
   # تتبع اختيار الوكيل
   orchestrator.config['LOG_CLASSIFIER_OUTPUT'] = True
   orchestrator.config['LOG_CLASSIFIER_RAW_OUTPUT'] = True
   ```

2. **مشاكل الذاكرة مع السياقات الكبيرة**
   ```python
   # تطبيق قطع السياق
   def truncate_context(context, max_length=8000):
       if len(context) > max_length:
           return context[-max_length:]
       return context
   ```

3. **اختناقات الأداء**
   ```python
   # تطبيق المعالجة غير المتزامنة
   import asyncio
   
   async def process_multiple_requests(requests):
       tasks = [process_single_request(req) for req in requests]
       return await asyncio.gather(*tasks)
   ```

## اختبار التطبيق

إنشاء مجموعة اختبار شاملة:

```python
import pytest
import asyncio
from agent_squad.orchestrator import AgentSquad

class TestAgentSquad:
    @pytest.fixture
    async def orchestrator(self):
        """إعداد منسق الاختبار"""
        squad = AgentSquad()
        # إضافة وكلاء الاختبار
        return squad
    
    @pytest.mark.asyncio
    async def test_tech_query_routing(self, orchestrator):
        """اختبار أن الاستعلامات التقنية توجه إلى الوكيل التقني"""
        response = await orchestrator.route_request(
            "كيف أنشر حاوية Docker؟",
            "test_user",
            "test_session"
        )
        
        assert "tech" in response.metadata.agent_name.lower()
    
    @pytest.mark.asyncio
    async def test_streaming_response(self, orchestrator):
        """اختبار وظيفة التدفق"""
        response = await orchestrator.route_request(
            "اشرح تعلم الآلة",
            "test_user",
            "test_session",
            streaming=True
        )
        
        assert response.streaming is True
        
        # جمع المحتوى المتدفق
        content = ""
        async for chunk in response.output:
            content += chunk.text
        
        assert len(content) > 0
```

## الخلاصة

يمثل Agent Squad تطوراً قوياً في أنظمة الذكاء الاصطناعي متعددة الوكلاء، ويوفر:

- **التوجيه الذكي** لتجارب مستخدم أفضل
- **الهندسة المرنة** التي تدعم موفري ذكاء اصطناعي متنوعين
- **ميزات جاهزة للإنتاج** لعمليات النشر المؤسسية
- **دعم مجتمعي قوي** وتطوير نشط

دعم الإطار للغة المزدوجة (Python/TypeScript) والتصميم المعياري يجعله خياراً ممتازاً لكل من النماذج الأولية وعمليات النشر الإنتاجية. سواء كنت تبني أنظمة خدمة العملاء، أو منصات تعليمية، أو تطبيقات ذكاء اصطناعي محادثة معقدة، يوفر Agent Squad الأساس لتنسيق الوكلاء المتعددة المتطور.

### الخطوات التالية

1. **جرب** التطبيق الأساسي
2. **خصص الوكلاء** لحالة الاستخدام المحددة
3. **نفذ المراقبة** وتحسين الأداء
4. **انشر** على منصة السحابة المفضلة لديك
5. **ساهم** في مجتمع المصدر المفتوح

للحصول على ميزات متقدمة ودعم المؤسسات، استكشف [الوثائق الرسمية](https://awslabs.github.io/agent-squad/) وانضم إلى المجتمع المتنامي من مطوري Agent Squad.

---

*يوفر هذا الدليل أساساً شاملاً للعمل مع AWS Agent Squad. مع استمرار تطور الإطار، تابع أحدث الميزات وأفضل الممارسات من خلال المستودع الرسمي والوثائق.*
