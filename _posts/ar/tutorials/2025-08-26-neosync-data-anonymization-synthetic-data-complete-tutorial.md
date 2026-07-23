---
title: "دليل Neosync الشامل: إتقان إخفاء هوية البيانات وتوليد البيانات التركيبية"
excerpt: "دليل شامل لمنصة Neosync مفتوحة المصدر لإخفاء هوية المعلومات الشخصية وتوليد البيانات التركيبية ومزامنة البيئات مع أمثلة عملية"
seo_title: "دليل Neosync: إخفاء البيانات والبيانات التركيبية الشامل - Thaki Cloud"
seo_description: "تعلم منصة Neosync مفتوحة المصدر لإخفاء هوية البيانات وتوليد البيانات التركيبية ومزامنة البيئات الآمنة. دليل شامل مع إعداد Docker وأمثلة."
date: 2025-08-26
tags:
  - neosync
  - إخفاء-البيانات
  - البيانات-التركيبية
  - docker
  - postgresql
  - خصوصية
  - gdpr
  - أمان-البيانات
author_profile: true
toc: true
toc_label: "المحتويات"
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/neosync-data-anonymization-synthetic-data-complete-tutorial/"
lang: ar
permalink: /ar/tutorials/neosync-data-anonymization-synthetic-data-complete-tutorial/
published: false
categories:
  - tutorials
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة إلى Neosync ونظرة عامة

[**Neosync**](https://github.com/nucleuscloud/neosync) هي منصة مفتوحة المصدر وموجهة للمطورين تُحدث ثورة في كيفية تعامل المؤسسات مع البيانات الحساسة. توفر حلولًا شاملة لـ **إخفاء هوية البيانات** و **توليد البيانات التركيبية** و **مزامنة البيئات** لمساعدة الشركات على اختبار البيانات على مستوى الإنتاج بأمان مع الحفاظ على الامتثال للوائح حماية الخصوصية مثل GDPR وHIPAA وFERPA.

### لماذا Neosync مهم؟

في بيئة التطوير الحديثة المدفوعة بالبيانات، يحتاج المطورون إلى الوصول لبيانات واقعية للاختبار والتصحيح والتطوير. ومع ذلك، استخدام بيانات الإنتاج الفعلية يطرح مخاطر أمنية وامتثال كبيرة. Neosync يسد هذه الفجوة من خلال توفير:

1. **اختبار آمن لبيانات الإنتاج** - إخفاء هوية البيانات الحساسة للتطوير المحلي
2. **إعادة إنتاج أخطاء الإنتاج** - إنشاء مجموعات بيانات آمنة وممثلة للتصحيح
3. **بيانات اختبار عالية الجودة** - توليد بيانات على مستوى الإنتاج لبيئات التدريج وضمان الجودة
4. **حل الامتثال** - تقليل نطاق الامتثال للوائح GDPR وHIPAA وFERPA
5. **بذر قواعد بيانات التطوير** - إنشاء بيانات تركيبية للاختبار الوحدوي والعروض التوضيحية

### نظرة عامة على الميزات الرئيسية

- **توليد البيانات التركيبية** بناءً على المخطط الموجود
- **إخفاء هوية بيانات الإنتاج** مع الحفاظ على سلامة المراجع
- **تقسيم قاعدة البيانات** باستخدام استعلامات SQL للاختبار المركز
- **أرشيتيكتة خط أنابيب غير متزامن** مع إعادة المحاولة التلقائية ومعالجة الأخطاء
- **تكامل GitOps** لإدارة التكوين التصريحي
- **محولات مدمجة** لأنواع البيانات الرئيسية (البريد الإلكتروني، الأسماء، العناوين، إلخ)
- **محولات مخصصة** باستخدام JavaScript أو LLMs
- **دعم قواعد بيانات متعددة** - تكامل PostgreSQL وMySQL وS3

## المتطلبات المسبقة وإعداد البيئة

### متطلبات النظام

قبل بدء هذا الدليل، تأكد من وجود:

- **Docker & Docker Compose** (أحدث إصدار)
- **Git** (لاستنساخ المستودع)
- **عميل PostgreSQL** (اختياري، لاختبار الاتصالات)
- **متصفح ويب** (للوصول إلى واجهة Neosync)
- **macOS أو Linux أو Windows** (مع WSL2)

### خطوات التثبيت

لنبدأ بإعداد Neosync على جهازك المحلي:

#### الخطوة 1: استنساخ المستودع

```bash
# استنساخ مستودع Neosync
git clone https://github.com/nucleuscloud/neosync.git
cd neosync

# فحص هيكل المستودع
ls -la
```

#### الخطوة 2: تشغيل خدمات Neosync

يوفر Neosync إعداد Docker Compose جاهز للإنتاج:

```bash
# تشغيل جميع خدمات Neosync
make compose/up

# أو استخدام Docker Compose مباشرة
docker compose up -d
```

ستقوم هذه الأوامر بـ:
- تحميل وتشغيل جميع الحاويات المطلوبة
- إعداد قاعدة بيانات PostgreSQL لبيانات Neosync الوصفية
- تشغيل Neosync backend API
- بدء واجهة الويب الأمامية
- تهيئة الاتصالات والمهام النموذجية

#### الخطوة 3: التحقق من التثبيت

```bash
# فحص الحاويات قيد التشغيل
docker compose ps

# عرض السجلات عند الحاجة
docker compose logs -f neosync-app
```

ادخل إلى Neosync على `http://localhost:3000` في متصفح الويب.

## فهم أرشيتيكتة Neosync

### المكونات الأساسية

يتكون Neosync من عدة مكونات مترابطة:

1. **الواجهة الأمامية (Next.js)** - واجهة ويب للتكوين والمراقبة
2. **Backend API (Go)** - منطق العمل الأساسي وتنسيق المهام
3. **خدمة العامل** - معالجة مهام معالجة وتحويل البيانات
4. **قاعدة بيانات PostgreSQL** - تخزين البيانات الوصفية والتكوينات وحالة المهام
5. **Temporal** - تنسيق سير العمل لتنفيذ المهام الموثوق

### أرشيتيكتة تدفق البيانات

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
<div class="d3-arch" data-arch-root id="eticdatacompletetutorial-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 496, "height": 862, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 272, "w": 177, "h": 46, "title": "قاعدة البيانات المصدر"}, {"id": "B", "x": 154, "y": 396, "w": 120, "h": 46, "title": "عامل Neosync"}, {"id": "C", "x": 147, "y": 520, "w": 135, "h": 46, "title": "محولات البيانات"}, {"id": "D", "x": 136, "y": 644, "w": 156, "h": 62, "title": ["البيانات", "المجهولة/التركيبية"]}, {"id": "E", "x": 115, "y": 784, "w": 198, "h": 46, "title": "قاعدة البيانات المستهدفة"}, {"id": "F", "x": 256, "y": 24, "w": 121, "h": 46, "title": "واجهة Neosync"}, {"id": "G", "x": 169, "y": 148, "w": 120, "h": 46, "title": "Backend API"}, {"id": "H", "x": 256, "y": 272, "w": 120, "h": 46, "title": "مجدول المهام"}, {"id": "I", "x": 81, "y": 24, "w": 120, "h": 46, "title": "التكوين"}, {"id": "J", "x": 344, "y": 148, "w": 120, "h": 46, "title": "Temporal"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[113, 318], [113, 357], [113, 357], [177, 396]]}, {"src": "B", "dst": "C", "kind": "data", "line": [214, 442, 214, 520]}, {"src": "C", "dst": "D", "kind": "data", "line": [214, 566, 214, 644]}, {"src": "D", "dst": "E", "kind": "data", "line": [214, 706, 214, 784]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[316, 70], [316, 109], [316, 109], [261, 148]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[229, 194], [229, 233], [229, 233], [284, 272]]}, {"src": "H", "dst": "B", "kind": "data", "curve": [[316, 318], [316, 357], [316, 357], [252, 396]]}, {"src": "I", "dst": "G", "kind": "data", "curve": [[141, 70], [141, 109], [141, 109], [196, 148]]}, {"src": "J", "dst": "H", "kind": "data", "curve": [[404, 194], [404, 233], [404, 233], [348, 272]]}]});
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
      const container = document.getElementById('eticdatacompletetutorial-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eticdatacompletetutorial-1';
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

## التكوين والإعداد الأولي

### الوصول إلى لوحة القيادة

1. افتح متصفحك وانتقل إلى `http://localhost:3000`
2. ستظهر لوحة قيادة الترحيب الخاصة بـ Neosync
3. يأتي النظام مع اتصالات نموذجية مُكوّنة مسبقًا للتوضيح

### فهم الاتصالات

**الاتصالات** في Neosync تمثل نقاط نهاية قاعدة البيانات أو التخزين. يتضمن الإعداد الافتراضي:

- **اتصال المصدر** - قاعدة بيانات PostgreSQL مع بيانات نموذجية
- **اتصال الوجهة** - قاعدة البيانات المستهدفة للبيانات المجهولة

### نظرة عامة على البيانات النموذجية

يتضمن Neosync بيانات نموذجية مُعبأة مسبقًا لإظهار إمكانياته:

```sql
-- هيكل المخطط النموذجي
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    birth_date DATE,
    salary DECIMAL(10,2)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    order_date TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);
```

## إنشاء أول مهمة إخفاء هوية

### معالج تكوين المهمة

لننشئ مهمة إخفاء هوية البيانات التي تحول المعلومات الحساسة مع الحفاظ على علاقات البيانات:

#### الخطوة 1: إنشاء مهمة جديدة

1. انقر على **"المهام (Jobs)"** في قائمة التنقل
2. اختر **"إنشاء مهمة (Create Job)"**
3. اختر نوع المهمة **"إخفاء هوية البيانات (Data Anonymization)"**
4. اضبط اسم المهمة: `user-data-anonymization`

#### الخطوة 2: تكوين اتصال المصدر

```yaml
# إعدادات اتصال المصدر
نوع الاتصال: PostgreSQL
المضيف: localhost
المنفذ: 5432
قاعدة البيانات: sample_db
اسم المستخدم: postgres
كلمة المرور: [مقدمة في compose]
```

#### الخطوة 3: تعريف قواعد التحويل

لجدول `users`، قم بتكوين هذه التحويلات:

| العمود | المحول | التكوين |
|--------|---------|----------|
| `first_name` | توليد الاسم الأول | توليد عشوائي |
| `last_name` | توليد اسم العائلة | توليد عشوائي |
| `email` | تحويل البريد الإلكتروني | الحفاظ على هيكل النطاق |
| `phone` | توليد رقم الهاتف | التنسيق: +966-XX-XXX-XXXX |
| `birth_date` | تحويل التاريخ | عشوائية ±5 سنوات |
| `salary` | تحويل رقمي | عشوائية ±20% |

#### الخطوة 4: الحفاظ على سلامة المراجع

تكوين علاقات المفاتيح الخارجية:

```yaml
# الحفاظ على علاقات user_id في جدول orders
المفاتيح الخارجية:
  - الجدول المصدر: orders
    العمود المصدر: user_id
    الجدول المرجعي: users
    العمود المرجعي: id
    الإجراء: preserve_relationship
```

#### الخطوة 5: تنفيذ المهمة

```bash
# مراقبة تنفيذ المهمة عبر CLI (اختياري)
docker compose exec neosync-worker neosync jobs run --job-id=user-data-anonymization

# أو استخدام واجهة الويب
# انقر "تشغيل المهمة" في لوحة القيادة
```

## توليد البيانات التركيبية

### إنشاء مجموعات البيانات التركيبية

يمكن لـ Neosync توليد بيانات تركيبية كاملة تتطابق مع قيود المخطط:

#### الخطوة 1: تحليل المخطط

```sql
-- تحليل المخطط الموجود
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users';
```

#### الخطوة 2: تكوين التوليد التركيبي

أنشئ مهمة جديدة بهذه الإعدادات:

```yaml
نوع المهمة: توليد البيانات التركيبية
الصفوف المستهدفة: 10000
توزيع البيانات:
  users:
    - first_name: weighted_random([أسماء_عربية_شائعة])
    - last_name: weighted_random([عائلات_عربية])
    - email: generate_email(first_name, last_name)
    - age_distribution: normal(mean=35, std=12)
    - salary_distribution: lognormal(mean=15000, std=5000)  # بالريال السعودي
```

#### الخطوة 3: أنماط تركيبية متقدمة

```javascript
// محول مخصص لتوليد بريد إلكتروني واقعي
function generateEmail(firstName, lastName) {
    const domains = ['gmail.com', 'hotmail.com', 'yahoo.com', 'company.sa'];
    const domain = domains[Math.floor(Math.random() * domains.length)];
    const username = `${firstName.toLowerCase()}.${lastName.toLowerCase()}`;
    return `${username}@${domain}`;
}

// توليد بيانات مترابطة
function generateSalary(experience, education) {
    const baseSalary = 8000;  // راتب أساسي بالريال السعودي
    const experienceMultiplier = experience * 500;
    const educationBonus = education === 'ماجستير' ? 2000 : 
                          education === 'دكتوراه' ? 4000 : 0;
    
    return baseSalary + experienceMultiplier + educationBonus;
}
```

## تحويلات البيانات المتقدمة

### محولات JavaScript المخصصة

يدعم Neosync التحويلات المخصصة باستخدام JavaScript:

```javascript
// إخفاء هوية رقم بطاقة الائتمان
function anonymizeCreditCard(value) {
    if (!value || value.length < 4) return value;
    
    const lastFour = value.slice(-4);
    const masked = '*'.repeat(value.length - 4);
    return masked + lastFour;
}

// إخفاء هوية العنوان مع الحفاظ على المنطقة الجغرافية
function anonymizeAddress(address, city, state) {
    return {
        street: generateRandomStreet(),
        city: city, // الحفاظ على المدينة للتحليل الجغرافي
        state: state,
        zipCode: generateRandomZipInState(state)
    };
}

// إخفاء هوية الطابع الزمني مع الحفاظ على نمط الوقت
function anonymizeTimestamp(timestamp) {
    const date = new Date(timestamp);
    const randomDays = Math.floor(Math.random() * 365) - 182; // ±6 أشهر
    date.setDate(date.getDate() + randomDays);
    return date.toISOString();
}
```

### التحويلات المدعومة بـ LLM

للتحويلات الأكثر تطورًا، يمكن لـ Neosync التكامل مع نماذج اللغة الكبيرة:

```yaml
# تكوين محول LLM
المحول: LLM_Transform
النموذج: gpt-3.5-turbo
المطالبة: |
  حول مراجعة العميل هذه لإزالة المعلومات الشخصية 
  مع الحفاظ على المشاعر وملاحظات المنتج الرئيسية:
  
  الأصل: "{review_text}"
  
  المتطلبات:
  - إزالة الأسماء والمواقع والتواريخ المحددة
  - الحفاظ على ميزات المنتج المذكورة
  - الحفاظ على النبرة العاطفية
  - الحفاظ على طول المراجعة مماثل

Temperature: 0.3
Max_Tokens: 300
```

## تكامل قاعدة البيانات والتقسيم

### تكامل PostgreSQL

تكوين اتصال PostgreSQL لبيانات الإنتاج:

```yaml
# إعداد PostgreSQL للإنتاج
الاتصال:
  type: postgresql
  host: prod-db.company.com
  port: 5432
  database: production_db
  username: neosync_reader
  password: ${NEOSYNC_DB_PASSWORD}
  ssl_mode: require
  
# أذونات القراءة فقط للأمان
الأذونات:
  - SELECT على public.*
  - لا توجد أذونات كتابة
```

### استراتيجيات تقسيم البيانات

إنشاء مجموعات بيانات مركزة للاختبار:

```sql
-- تقسيم قائم على المستخدم
SELECT * FROM users 
WHERE created_at >= '2024-01-01' 
  AND account_type = 'premium'
LIMIT 1000;

-- تقسيم مدرك للعلاقات
WITH sample_users AS (
    SELECT id FROM users 
    WHERE region = 'SA-RIYADH' 
    LIMIT 500
)
SELECT o.* FROM orders o
JOIN sample_users su ON o.user_id = su.id
WHERE o.order_date >= '2024-01-01';

-- تقسيم زمني مع سلامة المراجع
SELECT * FROM events 
WHERE event_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND user_id IN (
    SELECT id FROM users 
    WHERE last_active >= '2024-06-01'
  );
```

### تكامل MySQL

```yaml
# تكوين اتصال MySQL
الاتصال:
  type: mysql
  host: mysql-server.internal
  port: 3306
  database: app_database
  username: neosync_user
  password: ${MYSQL_PASSWORD}
  charset: utf8mb4
  
# إعدادات خاصة بـ MySQL
الخيارات:
  sql_mode: STRICT_TRANS_TABLES
  time_zone: Asia/Riyadh
  max_connections: 10
```

## أتمتة سير العمل وGitOps

### التكوين التصريحي

إنشاء تكوينات مهام قابلة لإعادة الاستخدام:

```yaml
# .neosync/jobs/user-anonymization.yaml
apiVersion: neosync.dev/v1
kind: Job
metadata:
  name: user-data-anonymization
  namespace: development
spec:
  source:
    connection: prod-postgres
    tables:
      - users
      - user_profiles
      - user_preferences
  
  destination:
    connection: dev-postgres
    
  transformations:
    users:
      first_name:
        type: generate_first_name
      last_name:
        type: generate_last_name
      email:
        type: transform_email
        preserve_domain: true
      ssn:
        type: hash_value
        algorithm: sha256
    
    user_profiles:
      bio:
        type: llm_transform
        model: gpt-3.5-turbo
        prompt: "إخفاء هوية التفاصيل الشخصية مع الحفاظ على المعلومات المهنية"
  
  schedule:
    cron: "0 2 * * *"  # يوميًا في الساعة 2 صباحًا
    timezone: Asia/Riyadh
```

### تكامل CI/CD

```yaml
# .github/workflows/data-sync.yml
name: مزامنة بيانات Neosync

on:
  schedule:
    - cron: '0 6 * * 1'  # كل يوم اثنين في الساعة 6 صباحًا
  workflow_dispatch:

jobs:
  sync-development-data:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: إعداد Neosync CLI
        run: |
          curl -sSL https://install.neosync.dev | sh
          echo "$HOME/.neosync/bin" >> $GITHUB_PATH
      
      - name: تشغيل مهمة الإخفاء
        env:
          NEOSYNC_API_TOKEN: ${{ secrets.NEOSYNC_API_TOKEN }}
          NEOSYNC_API_URL: ${{ secrets.NEOSYNC_API_URL }}
        run: |
          neosync jobs run \
            --job-config .neosync/jobs/user-anonymization.yaml \
            --wait-for-completion \
            --timeout 30m
      
      - name: التحقق من جودة البيانات
        run: |
          neosync validate \
            --connection dev-postgres \
            --check referential-integrity \
            --check data-quality
```

## المراقبة وقابلية الملاحظة

### لوحة قيادة مراقبة المهام

يوفر Neosync إمكانيات مراقبة شاملة:

1. **حالة تنفيذ المهام** - تتبع التقدم في الوقت الفعلي
2. **مقاييس تحويل البيانات** - عدد الصفوف ومعدلات التحويل
3. **تتبع الأخطاء** - التحويلات الفاشلة ومنطق إعادة المحاولة
4. **مقاييس الأداء** - وقت التنفيذ وتحليل الإنتاجية
5. **فحوصات جودة البيانات** - نتائج التحقق واكتشاف الشذوذ

### المقاييس والتنبيهات

```yaml
# تكوين المراقبة
المراقبة:
  المقاييس:
    - job_duration_seconds
    - rows_processed_total
    - transformation_errors_total
    - data_quality_score
  
  التنبيهات:
    - name: job_failure
      condition: job_status == "failed"
      notification: slack_webhook
      
    - name: data_quality_degradation
      condition: data_quality_score < 0.95
      notification: email
      
    - name: long_running_job
      condition: job_duration_seconds > 3600
      notification: pagerduty
```

### تحليل السجلات

```bash
# عرض سجلات تنفيذ المهام
docker compose logs neosync-worker | grep "job_id=user-anonymization"

# مراقبة أداء التحويل
docker compose logs neosync-worker | grep "transformation_stats"

# فحص الأخطاء
docker compose logs neosync-worker | grep "ERROR"
```

## الأمان والامتثال

### أفضل ممارسات خصوصية البيانات

1. **مبدأ أقل امتياز** - منح الحد الأدنى من الأذونات الضرورية
2. **سياسات الاحتفاظ بالبيانات** - حذف البيانات المجهولة القديمة تلقائيًا
3. **تسجيل المراجعة** - تتبع جميع الوصول للبيانات والتحويلات
4. **التشفير** - تشفير البيانات أثناء النقل والتخزين
5. **ضوابط الوصول** - وصول قائم على الأدوار لمستويات حساسية البيانات المختلفة

### ميزات امتثال GDPR

```yaml
# تكوين امتثال GDPR
GDPR:
  حقوق_موضوع_البيانات:
    الحق_في_النسيان:
      enabled: true
      retention_days: 90
      
    حق_الوصول:
      enabled: true
      response_time_days: 30
      
    قابلية_نقل_البيانات:
      enabled: true
      export_formats: [json, csv, xml]
  
  إدارة_الموافقة:
    track_consent_changes: true
    consent_expiry_days: 365
    
  إخطار_الانتهاك:
    enabled: true
    notification_time_hours: 72
```

### امتثال حماية البيانات

```yaml
# امتثال قوانين حماية البيانات العربية
حماية_البيانات:
  تحديد_البيانات_الشخصية:
    automatic_detection: true
    custom_patterns:
      - رقم_الهوية: '\d{10}'
      - رقم_الجوال: '05\d{8}'
      
  طريقة_الإخفاء:
    إزالة_المعرفات_المباشرة: true
    التحكم_في_الإفصاح_الإحصائي: true
    
  ضوابط_المراجعة:
    تسجيل_كل_الوصول: true
    احتفاظ_السجلات_سنوات: 5
```

## تحسين الأداء

### تكوين المعالجة المتوازية

```yaml
# إعدادات تحسين الأداء
الأداء:
  تزامن_العامل: 8
  حجم_الدفعة: 1000
  حد_الذاكرة: "4Gi"
  
  اتصالات_قاعدة_البيانات:
    أقصى_مفتوح: 25
    أقصى_خامل: 5
    عمر_الاتصال: "5m"
  
  ذاكرة_التحويل_المؤقتة:
    enabled: true
    size: "1Gi"
    ttl: "1h"
```

### التعامل مع مجموعات البيانات الكبيرة

```sql
-- معالجة مجزأة للجداول الكبيرة
SELECT * FROM large_table 
WHERE id BETWEEN ? AND ?
ORDER BY id 
LIMIT 10000;

-- تدفق فعال للذاكرة
SET work_mem = '256MB';
SET maintenance_work_mem = '1GB';
```

## دليل استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### المشكلة 1: انتهاء مهلة المهمة

```yaml
# الحل: زيادة المهلة وتحسين حجم الدفعة
المهمة:
  timeout: 3600s  # ساعة واحدة
  batch_size: 500  # دفعات أصغر
  retry_attempts: 3
```

#### المشكلة 2: مشاكل الذاكرة

```bash
# مراقبة استخدام الذاكرة
docker stats neosync-worker

# زيادة ذاكرة الحاوية
docker compose up -d --scale neosync-worker=2
```

#### المشكلة 3: فشل الاتصال

```yaml
# تكوين اتصال قوي
الاتصال:
  retry_attempts: 5
  retry_delay: 30s
  connection_timeout: 60s
  read_timeout: 300s
```

### وضع التصحيح

```bash
# تفعيل تسجيل التصحيح
export NEOSYNC_LOG_LEVEL=debug
docker compose up -d

# عرض سجلات مفصلة
docker compose logs -f neosync-worker | grep DEBUG
```

## الاختبار والتحقق

لننشئ نص اختبار شامل للتحقق من إعداد Neosync:

```bash
#!/bin/bash
# الملف: test-neosync-setup.sh

echo "🚀 اختبار إعداد Neosync..."

# الاختبار 1: فحص تشغيل الخدمات
echo "📡 فحص خدمات Neosync..."
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ واجهة Neosync متاحة"
else
    echo "❌ واجهة Neosync غير متاحة"
    exit 1
fi

# الاختبار 2: التحقق من اتصال قاعدة البيانات
echo "🗄️ اختبار اتصال قاعدة البيانات..."
docker compose exec neosync-app neosync connections test --connection-id=sample-postgres
if [ $? -eq 0 ]; then
    echo "✅ اتصال قاعدة البيانات ناجح"
else
    echo "❌ فشل اتصال قاعدة البيانات"
fi

# الاختبار 3: تشغيل مهمة إخفاء هوية نموذجية
echo "🔄 تشغيل مهمة إخفاء هوية نموذجية..."
JOB_ID=$(docker compose exec neosync-app neosync jobs create \
    --name "test-anonymization" \
    --source-connection sample-postgres \
    --destination-connection sample-postgres-dest)

docker compose exec neosync-app neosync jobs run --job-id=$JOB_ID --wait

# الاختبار 4: التحقق من البيانات المجهولة
echo "🔍 التحقق من البيانات المجهولة..."
docker compose exec postgres psql -U postgres -d neosync -c \
    "SELECT COUNT(*) as anonymized_records FROM users_anonymized;"

echo "✅ اكتمل اختبار إعداد Neosync بنجاح!"
```

## الخطوات التالية والاستخدام المتقدم

### النشر للإنتاج

للنشر في الإنتاج، يجب مراعاة:

1. **نشر Kubernetes** - استخدام Helm charts المقدمة
2. **التوفر العالي** - نشر عدة مثيلات عامل
3. **قاعدة بيانات خارجية** - استخدام PostgreSQL مُدار للبيانات الوصفية
4. **إدارة الأسرار** - التكامل مع HashiCorp Vault أو AWS Secrets Manager
5. **توزيع الأحمال** - توزيع طلبات API عبر مثيلات متعددة

### أنماط التكامل

```yaml
# تكامل الخدمات المصغرة
الخدمات:
  خدمة-المستخدم:
    مهمة_الإخفاء: user-data-anonymization
    الجدولة: "0 3 * * *"
    
  خدمة-الطلبات:
    مهمة_الإخفاء: order-data-anonymization
    يعتمد_على: [خدمة-المستخدم]
    
  خدمة-التحليلات:
    مهمة_البيانات_التركيبية: analytics-synthetic-data
    مصدر_المخطط: production_analytics
```

### الإضافات المخصصة

```go
// محول مخصص في Go
package transformers

type CustomTransformer struct {
    config TransformerConfig
}

func (t *CustomTransformer) Transform(value interface{}) (interface{}, error) {
    // تنفيذ منطق التحويل المخصص
    return transformedValue, nil
}
```

## الخلاصة

يوفر Neosync حلًا شاملًا لتحديات خصوصية البيانات والاختبار الحديثة. من خلال تنفيذ إخفاء هوية البيانات المناسب وتوليد البيانات التركيبية، يمكن للمؤسسات:

- **تسريع التطوير** - وصول آمن لبيانات على مستوى الإنتاج
- **تحسين جودة البيانات** - سيناريوهات اختبار واقعية وحالات حدية
- **ضمان الامتثال** - حماية خصوصية آلية للصناعات المنظمة
- **تقليل المخاطر** - إزالة التعرض لبيانات الإنتاج الحساسة
- **توسيع الاختبار** - توليد مجموعات بيانات تركيبية غير محدودة لسيناريوهات مختلفة

خيارات التكوين التصريحي للمنصة وتكامل GitOps وخيارات التخصيص الواسعة تجعلها مناسبة للمؤسسات من جميع الأحجام، من الشركات الناشئة إلى النشر على مستوى المؤسسة.

### النقاط الرئيسية

1. **ابدأ بساطة** - ابدأ بمهام إخفاء هوية أساسية وأضف التعقيد تدريجيًا
2. **احفظ العلاقات** - احفظ دائمًا سلامة المراجع في تحويلاتك
3. **راقب الجودة** - نفذ فحوصات جودة البيانات لضمان فعالية التحويل
4. **أتمت كل شيء** - استخدم تكامل GitOps وCI/CD لتوفير البيانات المتسق
5. **خطط للنطاق** - صمم خطوط أنابيب التحويل مع مراعاة حجم الإنتاج

### موارد للتعلم الإضافي

- [**وثائق Neosync**](https://docs.neosync.dev) - أدلة شاملة ومرجع API
- [**مجتمع Discord**](https://discord.gg/neosync) - تواصل مع مستخدمين آخرين واحصل على الدعم
- [**مستودع GitHub**](https://github.com/nucleuscloud/neosync) - كود المصدر وتتبع المشاكل
- [**المدونة والدروس**](https://www.neosync.dev/blog) - أحدث الميزات وحالات الاستخدام

---

**تحتاج مساعدة؟** انضم إلى مجتمع Neosync على Discord أو افتح مشكلة على GitHub للحصول على الدعم التقني وطلبات الميزات.
