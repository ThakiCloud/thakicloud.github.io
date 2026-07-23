---
title: "حوكمة الذكاء الاصطناعي وأتمتة التدقيق في القطاع المالي: الامتثال التنظيمي والتحكم في الوكلاء المستقلين"
excerpt: "دراسة حالة افتراضية تستعرض كيف يمكن للبنوك وشركات الأوراق المالية وشركات التأمين استيفاء متطلبات تخزين البيانات محليًا وسجلات التدقيق والرقابة الداخلية عند نشر وكلاء الذكاء الاصطناعي -- باستخدام محرك السياسات وسجلات التدقيق القائمة على سلاسل التجزئة."
seo_title: "حوكمة الذكاء الاصطناعي وأتمتة التدقيق في القطاع المالي - Thaki Cloud"
seo_description: "سجلات تدقيق الذكاء الاصطناعي المالي، وحوكمة الذكاء الاصطناعي في القطاع المالي، وكيفية الامتثال لأنظمة ISMS واللوائح الإشرافية المالية الإلكترونية عند نشر وكلاء الذكاء الاصطناعي على البنية التحتية الداخلية. دراسة تطبيقية لمنصة Paxis مع محرك سياسات 4 مستويات للاستقلالية × 7 درجات للمخاطر، وسجلات تدقيق بسلاسل تجزئة، وإخفاء 16 فئة من البيانات الشخصية."
lang: ar
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - ai-governance
  - finance
  - audit-log
  - policy-engine
  - compliance
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/finance-ai-governance-audit-automation/"
reading_time: true
categories:
  - agentops
published: false
---

![حوكمة الذكاء الاصطناعي وأتمتة التدقيق في القطاع المالي]({{ '/assets/images/finance-ai-governance-audit-automation-hero.webp' | relative_url }})

## نظرة عامة

لم يعد اعتماد وكلاء الذكاء الاصطناعي في القطاع المالي خيارًا اختياريًا. مع توسّع نطاق التطبيقات -- أتمتة تقييم الائتمان واكتشاف المعاملات المشبوهة ودعم خدمة العملاء -- بات على كل مؤسسة مالية أن تحقق هدفَي الكفاءة التشغيلية والامتثال التنظيمي في آنٍ واحد.

تكمن المشكلة في أن منصات الذكاء الاصطناعي الحالية لا تعالج هذين الهدفين معًا. إذ تتمتع واجهات برمجة تطبيقات نماذج اللغة الكبيرة المستندة إلى السحابة بقدرات هائلة، غير أن البيانات تمر عبر خوادم خارجية. وكثيرًا ما تفتقر أطر عمل الوكلاء مفتوحة المصدر إلى مسارات التدقيق أو ضوابط الوصول. في المقابل، تشترط الجهات التنظيمية إمكانية تتبع كل قرار يتخذه الذكاء الاصطناعي، وفقًا للوائح الإشراف المالي الإلكتروني ومعيار ISMS-P وإرشادات معهد أمن المعلومات المالية الكوري.

تتناول هذه المقالة من خلال حالة بنك كوري افتراضي البنية المعمارية التي تُتيح لوكلاء الذكاء الاصطناعي استيفاء اللوائح المالية مع تحقيق أتمتة فعلية للعمليات. ويتمحور ذلك حول آليتَي التحكم في الاستقلالية والإطار التدقيقي المنيع ضد التلاعب.

---

## أوجه توقف المؤسسات المالية عن اعتماد الذكاء الاصطناعي

### متطلبات تخزين البيانات محليًا

تحظر المادة 13-2 من لوائح الإشراف المالي الإلكتروني وإرشادات استخدام الحوسبة السحابية الصادرة عن لجنة الخدمات المالية -- من حيث المبدأ -- معالجة البيانات المالية للعملاء أو تخزينها على خوادم خارجية، أو تشترط الحصول على موافقة مسبقة. قد يؤدي استخدام الذكاء الاصطناعي التوليدي مباشرةً عبر واجهة برمجة تطبيقات خارجية إلى إرسال أرقام الحسابات وسجلات المعاملات وبيانات التعريف الواردة في نصوص الطلبات إلى مراكز بيانات في الخارج. وهذه المسألة وحدها كافية لتوقف كثير من مشاريع إثبات المفهوم لدى المؤسسات المالية.

### غياب مسارات التدقيق

إذا تعذّر إعادة إنتاج أساس توصية الذكاء الاصطناعي بحدٍّ ائتماني معين أو تعليقه تلقائيًا لمعاملة مشبوهة، فإن ذلك يمثّل خطرًا جسيمًا في حالات التفتيش الذي يجريه المشرف المالي أو التدقيق الداخلي. وعبارة "قام الذكاء الاصطناعي بذلك" ليست إجابةً مقبولة لدى الجهات التنظيمية. ما يُتطلب هو سجل قابل للاسترجاع زمنيًا يوضح: أي نموذج، بأي مدخلات، استدعى أي أدوات، وأنتج أي مخرجات.

### عدم اليقين في التحكم بالوكلاء المستقلين

عند نشر وكلاء يتجاوزون نطاق برامج الدردشة البسيطة -- باستدعاء واجهات برمجة تطبيقات خارجية وقراءة الملفات وإرسال رسائل البريد الإلكتروني وتنفيذ أوامر النظام -- قد تنشأ تصرفات غير متوقعة إذا لم تُحدَّد بوضوح حدود ما يُسمح للوكيل بفعله. فإذا أجرى وكيل مستقل في القطاع المالي معاملاتٍ بسبب استقلالية مفرطة أو خاطئة، فقد يفضي ذلك إلى خسائر مالية فضلًا عن انتهاكات تنظيمية.

### تعدد المستأجرين والعزل الداخلي

حتى حين تتشارك أقسام الأوراق المالية والتأمين والأمانة البنية التحتية ذاتها للذكاء الاصطناعي، يجب أن تكون بيانات كل فريق وسجلات تدقيقه معزولةً عزلًا تامًا. فإن تمكّن وكيل أحد الأقسام من الوصول إلى بيانات عملاء قسم آخر أو سجلات معاملاته، فذلك يُشكّل انتهاكًا لمبادئ الرقابة الداخلية.

---

## البنية المعمارية للحوكمة: محرك السياسات ومصفوفة الاستقلالية × المخاطر

### لماذا يجب وجود محرك سياسات

إعطاء وكيل أداةً (Tool) وضبط استخدام تلك الأداة بصورة آمنة مسألتان مختلفتان. فمجرد ضبط إعداد "يُسمح لهذا الوكيل باستخدام واجهة برمجة تطبيقات استعلام العملاء" لا يمنع الوكيل من تنفيذ آلاف الاستعلامات تتاليًا بسبب خطأ في التقدير، أو الاطلاع بصورة مفرطة على حقول بيانات حساسة.

يتحقق محرك سياسات Paxis من بُعدَين متقاطعَين قبل تنفيذ أي استدعاء لأداة.

**4 مستويات للاستقلالية:**

- **L0 (يدوي بالكامل):** يقترح الوكيل فقط، ويوافق الإنسان على كل عملية تنفيذ.
- **L1 (استقلالية منخفضة المخاطر):** يُنفَّذ تلقائيًا للمهام القائمة على القراءة فحسب والمهام غير المالية.
- **L2 (استقلالية متوسطة المخاطر):** تُنفَّذ المعاملات دون الحد المحدد مسبقًا تلقائيًا، وتُطلب الموافقة عند تجاوزه.
- **L3 (استقلالية عالية):** تنفيذ مستقل واسع النطاق ضمن النطاق الذي يسمح به محرك السياسات.

**7 درجات للمخاطر:**

تُصنَّف استدعاءات الأدوات من الدرجة 1 (استعلام بسيط) إلى الدرجة 7 (معاملة خارجية غير قابلة للعكس) وفقًا للمخاطر. مثلًا، الاستعلام عن رصيد العميل يقع في الدرجة 1، بينما تنفيذ تحويل بين الحسابات يقع في الدرجتين 6-7. لكل أداة مضمّنة درجة مخاطر مسجّلة مسبقًا، وتُحجب الأدوات غير المسجّلة تلقائيًا بصورة افتراضية.

### تدفق قرار السياسة

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
<div class="d3-arch" data-arch-root id="overnanceauditautomation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 725, "height": 1072, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 329, "y": 24, "w": 191, "h": 46, "title": "طلب استدعاء أداة الوكيل"}, {"id": "B", "x": 344, "y": 148, "w": 160, "h": 52, "title": "أداة غير مسجّلة؟"}, {"id": "C", "x": 502, "y": 846, "w": 191, "h": 46, "title": "حجب افتراضي + سجل تدقيق"}, {"id": "D", "x": 144, "y": 292, "w": 177, "h": 46, "title": "البحث عن درجة المخاطر"}, {"id": "E", "x": 117, "y": 416, "w": 230, "h": 68, "title": ["مستوى الاستقلالية × مصفوفة", "المخاطر"]}, {"id": "F", "x": 285, "y": 714, "w": 120, "h": 46, "title": "تنفيذ الأداة"}, {"id": "G", "x": 154, "y": 576, "w": 156, "h": 46, "title": "طلب موافقة المسؤول"}, {"id": "H", "x": 24, "y": 714, "w": 191, "h": 46, "title": "حجب التنفيذ + سجل تدقيق"}, {"id": "I", "x": 242, "y": 838, "w": 205, "h": 62, "title": ["إرجاع النتيجة + تسجيل حدث", "التدقيق"]}, {"id": "J", "x": 260, "y": 978, "w": 170, "h": 62, "title": ["إضافة كتلة إلى سلسلة", "التدقيق"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [424, 70, 424, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "نعم", "curve": [[487, 200], [598, 377], [598, 668], [598, 846]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "لا", "curve": [[355, 200], [232, 246], [232, 246], [232, 292]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "line": [232, 338, 232, 416]}, {"src": "E", "dst": "F", "kind": "data", "label": "مسموح", "curve": [[326, 484], [453, 530], [453, 668], [381, 714]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "مسموح بشرط", "line": [232, 484, 232, 576], "lx": 232, "ly": 526}, {"src": "E", "dst": "H", "kind": "data", "label": "مرفوض", "curve": [[168, 484], [82, 530], [82, 668], [107, 714]], "off": "50%"}, {"src": "G", "dst": "F", "kind": "data", "label": "موافقة", "line": [248, 622, 323, 714], "lx": 279, "ly": 664}, {"src": "G", "dst": "H", "kind": "data", "label": "رفض/انتهاء المهلة", "line": [216, 622, 141, 714], "lx": 185, "ly": 664}, {"src": "F", "dst": "I", "kind": "data", "line": [345, 760, 345, 838]}, {"src": "C", "dst": "J", "kind": "data", "curve": [[598, 892], [598, 939], [598, 939], [430, 985]]}, {"src": "H", "dst": "J", "kind": "data", "curve": [[120, 760], [120, 799], [120, 939], [260, 983]]}, {"src": "I", "dst": "J", "kind": "data", "line": [345, 900, 345, 978]}]});
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
      const container = document.getElementById('overnanceauditautomation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'overnanceauditautomation-1';
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

### حالة افتراضية: وكيل تقييم الائتمان في بنك A

يرغب بنك A في نشر وكيل ذكاء اصطناعي لتقييم ائتمان الشركات الصغيرة والمتوسطة. المهام التي يؤديها الوكيل هي التالية:

1. الاستعلام عن المعلومات الائتمانية للشركات من نظام استعلام الائتمان NICE (درجة المخاطر 2)
2. الاستعلام من قاعدة بيانات سجلات القروض الداخلية (درجة المخاطر 1)
3. تحليل القوائم المالية والتوصية بالحد الائتماني (حكم فقط، دون تنفيذ خارجي)
4. صياغة مسودة رأي التقييم الائتماني (توليد مستند)
5. استدعاء واجهة برمجة تطبيقات تسجيل الحد عند الموافقة (درجة المخاطر 6)

في هذه الحالة، يُضبط مستوى استقلالية الوكيل على L2. تُنفَّذ المهام 1-4 تلقائيًا، لكن استدعاء واجهة برمجة تطبيقات تسجيل الحد (المهمة 5) ذو الدرجة 6 يستلزم موافقة المسؤول المختص. يستحيل هيكليًا أن يسجّل الوكيل الحد مباشرةً دون موافقة.

تُشترط موافقة المسؤول لتسع عمليات عالية المخاطر (إلغاء الحساب والتحويلات الجماعية وتغييرات تكامل الأنظمة الخارجية وغيرها) بصرف النظر عن مستوى الاستقلالية.

---

## التدقيق والتتبع: سجلات سلسلة التجزئة وإخفاء البيانات الشخصية

### آلية عمل سجلات تدقيق سلسلة التجزئة

صُمّم إطار التدقيق في Paxis بنية سلسلة التجزئة (Hash Chain). يحتوي كل حدث تدقيق على قيمة التجزئة (Hash) للحدث السابق، لذا فإن حذف أي سجل وسيط أو تعديله يُفشل التحقق من التجزئة لجميع الكتل اللاحقة. تُتيح هذه البنية اكتشاف التلاعب حتى لو حاول مسؤول قاعدة البيانات تغيير السجلات عن طريق الخطأ أو عمدًا.

يتجاوز عدد أنواع الأحداث المسجّلة 20 نوعًا، وأبرزها:

- `agent.tool.invoked`: طلب استدعاء الأداة (معرّف الوكيل واسم الأداة وسياق التنفيذ)
- `agent.tool.policy.denied`: الحجب بواسطة محرك السياسات (درجة المخاطر ومستوى الاستقلالية وأساس القرار)
- `agent.tool.approval.requested`: نشوء طلب موافقة المسؤول
- `agent.tool.approval.decided`: نتيجة الموافقة/الرفض (معرّف متخذ القرار والطابع الزمني)
- `agent.session.started`: بدء جلسة الوكيل (معرّف الفريق ومعرّف الوكيل ومعرّف الجلسة)
- `sandbox.exec`: حدث تنفيذ الكود داخل بيئة الحماية (Sandbox)

يُفهرس كل حدث بـ `run_id`، مما يُتيح الاستعلام وإعادة إنتاج جميع استدعاءات الأدوات وقرارات السياسة وسجلات الموافقة التي تُشكّل تدفق معالجة تقييم ائتماني واحد تحت `run_id` واحد. تُحفظ سجلات التدقيق لمدة 90 يومًا أو أكثر.

### الإخفاء التلقائي لـ 16 فئة من البيانات الشخصية

قد تحتوي البيانات التي يعالجها الوكيل على معلومات شخصية كأرقام تسجيل السكان وأرقام الحسابات وأرقام الهواتف وعناوين البريد الإلكتروني. تكتشف طبقة حماية النصوص في Paxis أنماط 16 فئة من البيانات الشخصية في الوقت الفعلي في مرحلة الإدخال وتُخفيها تلقائيًا.

مثلًا، إذا كان نتيجة استعلام معلومات العميل يحتوي على رقم تسجيل السكان، فإنه يُستبدل بـ `[رقم تسجيل السكان مُخفى]` قبل أن ينقله الوكيل إلى نموذج اللغة الكبيرة. وبما أن سجلات التدقيق تُسجّل الصيغة المُخفاة فحسب دون البيانات الأصلية، ينخفض خطر كون السجلات نفسها مسارًا لتسريب البيانات الشخصية.

كذلك يكتشف النظام 11 نمطًا من أنماط هجمات حقن النصوص (تبديل الأدوار وتجاهل التعليمات ومحاولات التهرب وغيرها) في الوقت الفعلي لمنع محاولات إساءة تشغيل الوكيل من خلال مدخلات ضارة.

### عزل تعدد المستأجرين

حتى حين يستخدم قسم الائتمان وقسم إدارة الأصول في بنك A المثيل ذاته من Paxis، تُعزل الويكي والجلسات والإعدادات وسجلات التدقيق عزلًا تامًا استنادًا إلى معرّفات الفريق (Team IDs). إذا حاول وكيل فريق الائتمان الوصول إلى بيانات عملاء فريق إدارة الأصول، تُجيب البيانات نفسها بـ "غير موجود"، دون الكشف حتى عن وجودها.

---

## دلالات تطبيق ThakiCloud

### النشر المحلي + المعزول لتحقيق متطلبات تخزين البيانات محليًا

يمكن نشر منصة ThakiCloud AI Platform مباشرةً في الشبكة الداخلية لمركز معالجة البيانات التابع للمؤسسة المالية على أساس Kubernetes. إذ تجري جميع عمليات الاستنتاج داخل المؤسسة، فلا تُنقل المعلومات المالية للعملاء خارجها. يتضمن خارطة طريق Paxis مجموعة نشر معزولة (Air-Gap) [تقديري: الربع الأول من 2027]، مع خطط لدعم التكوينات التي تعمل باستقلالية حتى في البيئات المغلقة حيث تُحجب الشبكات الخارجية كليًا.

تُنشر البنية التحتية للمراقبة (VictoriaMetrics/VictoriaLogs) أيضًا على الشبكة الداخلية، مما يُتيح مراقبة عمليات الوكيل والتكاليف والسلوكيات الشاذة في الوقت الفعلي.

### تكامل Keycloak OIDC RBAC مع أدلة المستخدمين الحالية

تُشغّل المؤسسات المالية عمومًا أدلة موظفين قائمة على AD (Active Directory) أو LDAP. تتكامل منصة ThakiCloud AI Platform مع الأدلة الحالية من خلال تكامل OIDC عبر Keycloak، بحيث تنعكس فورًا على المنصة تغييراتُ إنشاء حسابات الموظفين وحذفها وتعديل صلاحياتها. يمنع هذا نظام بقاء حسابات الموظفين المستقيلين محتفظةً بصلاحية الوصول إلى وكلاء الذكاء الاصطناعي.

### ربط محرك السياسات بأطر الرقابة الداخلية

يمكن تعيين مصفوفة الاستقلالية × المخاطر مباشرةً على إطار الرقابة الداخلية للمؤسسة المالية. مثلًا، يمكن تطبيق مبدأ "موافقة شخصَين أو أكثر على العمليات الحرجة" الذي تشترطه معايير الرقابة الداخلية للجنة الخدمات المالية بوصفه قاعدةً إلزامية للموافقة على العمليات عالية المخاطر في محرك السياسات.

يستطيع فريق التدقيق الاستعلام عن كامل سجل المعالجة لقضية ائتمانية بعينها باستخدام `run_id`، والاطلاع على شاشة واحدة على البيانات التي رجع إليها الوكيل والقرارات التي اتخذها محرك السياسات وهوية المعتمد. يُسهم هذا في ضمان إمكانية التحقق اللاحق من سلوك الذكاء الاصطناعي بالمستوى المطلوب في عمليات تفتيش هيئة الإشراف المالي.

### تحسين التكاليف عبر موجّه نماذج اللغة الكبيرة

يستطيع موجّه نماذج اللغة الكبيرة الذي يدعم أكثر من 10 مزودين لنماذج اللغة الكبيرة إضافةً إلى نموذج Metis الخاص بـ ThakiCloud تقييد المؤسسات المالية باستخدام نماذج محددة حصلت على موافقة أمنية فحسب، أو توجيه نماذج اقتصادية في التكلفة ونماذج عالية الدقة تلقائيًا وفقًا لنوع المهمة. يُحقق التكوين الهجين الذي يستخدم Metis المحلي كخلفية استنتاج أساسية والمزودين الخارجيين كاحتياط فحسب متطلبات تخزين البيانات محليًا وكفاءة التكاليف في آنٍ واحد.

---

## القيود والاعتبارات

يلزم تقييم صادق. بالرغم من تطور البنية المعمارية، توجد قيود واقعية.

**عدم اليقين في تفسير الأنظمة:** لا تزال الأنظمة المحلية المتعلقة بحوكمة الذكاء الاصطناعي في القطاع المالي في طور التطور. كثيرًا ما لا تُحدد أحكام توظيف الذكاء الاصطناعي في لوائح الإشراف المالي الإلكتروني وإرشادات أمن الذكاء الاصطناعي الصادرة عن معهد أمن المعلومات المالية الكوري المتطلبات التقنية التفصيلية، لذا يستلزم الامتثال الفعلي التشاور المسبق مع فرق القانون والجهات التنظيمية. لا يُضمن أن سجلات التدقيق ومحرك السياسات التي توفرها Paxis تستوفي متطلبات تنظيمية بعينها؛ ويستلزم هذا مراجعةً منفصلة لكل مؤسسة.

**شهادة SOC 2 Type II:** خارطة طريق شهادة SOC 2 Type II لـ Paxis مجدولة للربع الثاني من 2027 أو ما بعده. يجب على المؤسسات المالية التي تشترط حاليًا شهادة SOC 2 Type II مراعاة هذا الجدول الزمني.

**تعقيد تصميم السياسات:** مصفوفة الاستقلالية × المخاطر أداة قوية، لكن تصميمها بصورة صحيحة لتتناسب مع عمليات المؤسسة يتطلب قدرًا كبيرًا من المعرفة المتخصصة والوقت. إذا كان التصميم الأولي للسياسة معيبًا، فستنشأ مشكلات إما لأن الوكيل يحجب عمليات كثيرة جدًا (قيود مفرطة) أو يتمتع باستقلالية مفرطة (تساهل مفرط). النشر المتدرج والتعديل القائم على بيانات التشغيل ضروريان.

**عدم قابلية التنبؤ بسلوك الوكيل:** يوفر محرك السياسات التحكم على مستوى استدعاء الأدوات، لكنه لا يتحكم كليًا في عملية استنتاج نموذج اللغة الكبيرة ذاتها. حتى حين يستخدم الوكيل أدواتٍ مسموحًا بها بموجب السياسة فحسب، قد ينفذها بتسلسلات أو تركيبات غير متوقعة. لا سيما في العمليات التي تُعدّ فيها دقة الحكم أمرًا حرجًا كتقييم الائتمان، يجب تعريف وكلاء الذكاء الاصطناعي بوضوح بوصفهم داعمةً لاتخاذ قرار المسؤول المختص -- لا حاملةً لسلطة القرار النهائي.

**العبء التقني للعمليات المحلية:** تشغيل بيئة Kubernetes المحلية يستلزم قدرات تشغيل بنية تحتية أعلى بكثير مقارنةً بالخدمات السحابية كاملة الخدمة. يلزم وجود كوادر متخصصة طوال دورة التشغيل بأكملها -- إدارة ArgoCD GitOps وإدارة Keycloak ونشر تحديثات النماذج وغير ذلك. ينبغي مراجعة هذا الجانب جنبًا إلى جنب مع عقد دعم التشغيل مع ThakiCloud أو خطة بناء قدرات داخلية.

---

اعتماد وكلاء الذكاء الاصطناعي في القطاع المالي ليس مسألة تقنية -- بل هو مسألة حوكمة. ما يقع في صميمها هو: أين تُخزَّن البيانات، وإلى أي حد يمكن للوكيل التصرف باستقلالية، وهل تُسجَّل جميع تلك التصرفات بطريقة قابلة للتحقق؟ يقدم محرك السياسات وسجلات التدقيق بسلاسل التجزئة إجاباتٍ تقنية عن هذه الأسئلة الثلاثة، لكن ينبغي أن نُذكّر أنفسنا بأن هذا ليس كل ما يعنيه الامتثال التنظيمي.
