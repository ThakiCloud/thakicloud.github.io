---
title: "بناء الويب التفاعلي مع Fable 5: من التلات ثلاثية الأبعاد إلى تأثيرات GLSL بمطالبة واحدة"
excerpt: "يضع Claude Fable 5 من Anthropic معيارًا جديدًا في توليد واجهات الويب الأمامية. نستعرض هنا، استنادًا إلى دليل عملي منشور ومعرض مفتوح المصدر حقيقيين، سير عمل يستخرج مشاهد ثلاثية الأبعاد يتحكم فيها التمرير، وتظليل GLSL، وإعادة تصميم مبنية على لقطات الشاشة، كل ذلك من مطالبة واحدة، ونوضح ما تعنيه هذه الموجة من منظور Paxis من ThakiCloud الذي يتعامل مع وكلاء البرمجة كموارد من الدرجة الأولى."
seo_title: "تصميم الويب التفاعلي بـ Claude Fable 5 - سير عمل التلات ثلاثية الأبعاد وتأثيرات GLSL (2026) - Thaki Cloud"
seo_description: "تحليل لأساليب توليد مواقع ويب تفاعلية ثلاثية الأبعاد، وتأثيرات تمرير متحكم بها، وتظليل GLSL بمطالبة واحدة عبر Claude Fable 5، استنادًا إلى دليل عملي منشور (Viktor Oddy) ومعرض مفتوح المصدر (claude-directory). يتناول المقال سير عمل توليد الواجهة الأمامية، وإعادة التصميم من لقطات الشاشة، والتكامل مع Three.js، ويستعرض دلالات ذلك من منظور Paxis Agent-Native Cloud من ThakiCloud الذي يتعامل مع وكلاء البرمجة كموارد من الدرجة الأولى."
date: 2026-07-09
last_modified_at: 2026-07-09
tags:
  - claude-fable-5
  - web-design
  - frontend
  - interactive-animation
  - threejs
  - ai-coding
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/fable5-interactive-web-design/"
reading_time: true
categories:
  - dev
---

## لمن هذا المقال

يُكتب هذا المقال لمطوري الواجهات الأمامية ومهندسي التصميم الذين يبنون شاشات منتجات حقيقية بأدوات الذكاء الاصطناعي، وكذلك لمهندسي المنصات الذين يسعون إلى دمج وكلاء البرمجة في سير عمل فرقهم. لم تعد فكرة أن الذكاء الاصطناعي يستطيع إخراج نموذج أولي مقنع لصفحة هبوط أمرًا جديدًا. أما السؤال الذي نتعمق فيه هنا فهو أبعد من ذلك بخطوة: إلى أي مدى يستطيع النموذج فعليًا إنتاج تفاعلات كانت تستغرق أيامًا من البرمجة اليدوية، مثل مشهد ثلاثي الأبعاد يستجيب للتمرير أو خلفية معتمدة على التظليل، وكيف يمكن وضع هذه المخرجات ضمن خط إنتاج حقيقي. إن كنت تقف أمام قرار من هذا النوع، فغاية هذا المقال أن يميّز لك، دون مبالغة، بين ما هو ممكن فعلًا اليوم وما يظل بحاجة إلى يد بشرية.

![صورة تجريدية لتفاعل ثلاثي الأبعاد يتكوّن فيه العمق من تراكب الضوء وأسطح زجاجية]({{ '/assets/images/fable5-interactive-web-design-hero.webp' | relative_url }})

## نظرة عامة

ظل الجدار الذي يواجهه توليد الذكاء الاصطناعي في الواجهة الأمامية "ساكنًا" لفترة طويلة. تخرج الصفحات ذات الأزرار والبطاقات المرتبة بشكل جيد، لكن التفاعلات التي تتشابك فيها الحالة والزمن، كمشهد ثلاثي الأبعاد تتحرك فيه الكاميرا تبعًا لموضع التمرير، أو مادة زجاجية تنكسر مع حركة الفأرة، كانت غالبًا ما تتعثر فيها النماذج. فإما أن الشيفرة تُترجم بنجاح لكن لا يحدث شيء على الشاشة، أو أن الإطارات تتقطع بشكل ملحوظ.

مع منتصف عام 2026، بدأ هذا الجدار يتراجع بشكل ملحوظ، وفي صميم هذا التحول يقف Claude Fable 5 من Anthropic. سجّل المطور Viktor Oddy، في دليل عملي منشور بعنوان "Claude Fable 5 Just Changed Web Design Forever!"، العملية كاملة من البداية إلى النهاية، موضحًا كيف يمكن إنتاج موقع ثلاثي الأبعاد وتفاعلي ومزوّد بالحركة من مطالبة واحدة فقط. ثم ظهر لاحقًا في المجتمع معرض مفتوح المصدر يجمع تجارب واجهات مستخدم مبنية بـ Fable 5. يتتبّع هذا المقال هذه الموجة، ويوضّح ما الذي تغيّر فعليًا، وماذا تعنيه بالنسبة لشركة مثل ThakiCloud التي تتعامل مع الوكلاء كبنية تحتية.

{% include video id="_JF_s-ZRTyY" provider="youtube" %}

الفيديو أعلاه هو الدليل العملي الذي سجّله Viktor Oddy لعملية بناء موقع ويب تفاعلي ثلاثي الأبعاد باستخدام Fable 5.

## ما الذي يميّز Fable 5

Fable 5 نموذج من سلسلة Claude أطلقته Anthropic، ويُظهر تفوقًا خاصًا في هندسة الواجهة الأمامية وفي المهام الوكيلية متعددة المراحل. عبارة "متعددة المراحل" هنا مهمة. فبناء موقع ويب تفاعلي واحد هو في جوهره حزمة من المهام المتتابعة: ترتيب التخطيط، تحديد الهندسة الثلاثية الأبعاد، ربط أحداث التمرير بالمشهد، إضافة التظليل، تنظيم الملفات، ثم تحسين الأداء. وبينما كانت النماذج السابقة تنجز مرحلة أو اثنتين من هذه السلسلة وتترك الباقي للبشر، يمضي Fable 5 في هذه السلسلة لمسافة أطول بنفسه.

على وجه التحديد، تتكرر السمات التالية في الحالات المنشورة. أولًا، يُترجم الحركات المتحكم بها عبر التمرير إلى شيفرة فعلية، حيث يربط النموذج بنفسه تقدّم التمرير بحالة الكاميرا أو عناصر المشهد، وهو جزء يصعب برمجته يدويًا بسبب تعقيد إدارة الحالة. ثانيًا، يمزج مكتبات ثلاثية الأبعاد مثل Three.js مع تظليل GLSL لإنتاج تأثيرات بصرية كالانكسار والتشويش والجسيمات. ثالثًا، يستقبل لقطة شاشة كمُدخل ويقترح إعادة تصميم تُحسّن التخطيط والتفاعل في موقع قائم. رابعًا، يرتّب بنفسه بنية ملفات المشروع وأصوله، ويدفع بالنتيجة حتى تصبح قابلة للتشغيل من مطالبة واحدة.

القاسم المشترك بين هذه القدرات ليس "توليد ترميز ساكن" بل "توليد شيفرة تتشابك فيها الحالة والزمن". وهذه بالضبط النقطة التي كانت الحلقة الأضعف في الذكاء الاصطناعي الخاص بالواجهة الأمامية، وهي ما رفعه Fable 5 بشكل ملحوظ.

## كيف يُبنى تصميم الويب التفاعلي

بتتبّع الدليل المنشور ونتائج المعرض بشكل عكسي، يتّضح أن سير العمل الفعلي يتّبع في الغالب التسلسل التالي. بدلًا من توقّع نتيجة كاملة من المحاولة الأولى، تُسند إلى النموذج المراحل التي يُجيدها في كتل كبيرة، بينما يراجع الإنسان النتيجة ويضيّق الفجوات تدريجيًا.

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
<div class="d3-arch" data-arch-root id="ble5interactivewebdesign-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 402, "height": 912, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 72, "y": 24, "w": 191, "h": 78, "title": ["مطالبة القصد", "(تحديد المزاج والمرجعية", "والتقنية)"]}, {"id": "B", "x": 79, "y": 180, "w": 177, "h": 78, "title": ["توليد المسودة", "التخطيط + هيكل المشهد", "ثلاثي الأبعاد"]}, {"id": "C", "x": 83, "y": 336, "w": 170, "h": 78, "title": ["ربط التفاعل", "تقدّم التمرير → حالة", "المشهد"]}, {"id": "D", "x": 158, "y": 492, "w": 212, "h": 62, "title": ["التأثيرات البصرية", "تظليل GLSL · مواد Three.js"]}, {"id": "E", "x": 65, "y": 632, "w": 205, "h": 78, "title": ["مراجعة بشرية", "الأداء · إمكانية الوصول ·", "الهوية البصرية"]}, {"id": "F", "x": 90, "y": 802, "w": 156, "h": 78, "title": ["البناء · النشر", "React · Tailwind ·", "Three.js"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [168, 102, 168, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [168, 258, 168, 336]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[216, 414], [264, 453], [264, 453], [264, 492]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[264, 554], [264, 593], [264, 593], [216, 632]]}, {"src": "E", "dst": "C", "kind": "data", "label": "\"تعليمات تعديل\"", "curve": [[120, 632], [72, 593], [72, 453], [120, 414]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "\"اجتياز\"", "line": [168, 710, 168, 802], "lx": 168, "ly": 752}]});
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
      const container = document.getElementById('ble5interactivewebdesign-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ble5interactivewebdesign-1';
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

جوهر الأمر هو تضمين "ما تريده بالضبط" بقدر كافٍ من التحديد في المطالبة الأولى. فتحديد المزاج المرغوب والمواقع المرجعية والتقنية المستخدمة (مثل React وTailwind وThree.js) يُحدث فرقًا كبيرًا في جودة المسودة الأولى للنموذج. كما أن إرفاق لقطة شاشة يرفع من دقة إعادة التصميم. بعد ظهور المسودة، تعمل تعليمات التعديل على مستوى التفاعل، مثل "اجعل الكاميرا تتحرك بشكل أبطأ عند أسفل التمرير"، بفعالية جيدة. بعبارة أخرى، لا ينتهي الأمر بمطالبة واحدة، بل يُترك الهيكل الكبير للنموذج بينما يضبط الإنسان دقائق التفاعل.

وهناك أيضًا نقاط يجب الانتباه إليها. فالتظليل اللافت والتلات ثلاثية الأبعاد لهما ثمن على صعيد الأداء على الأجهزة المحمولة وإمكانية الوصول. فحتى لو بدت نتيجة النموذج رائعة على سطح المكتب، تبقى معالجة الأجهزة منخفضة الإمكانيات ومستخدمي قارئات الشاشة مسؤولية الإنسان. وإن لم تُدرج مرحلة المراجعة هذه بشكل صريح في سير العمل، فمن السهل أن تتراكم نتائج "جميلة لكن غير قابلة للاستخدام الفعلي".

## أمثلة واقعية ومعرض مفتوح المصدر

الدليل على أن هذه الموجة ليست تباهيًا فرديًا موجود في المصادر المنشورة. سجّل Viktor Oddy المذكور آنفًا العملية بأكملها في دليله، كما أُتيح في المجتمع معرض مفتوح المصدر `pulkitxm/claude-directory` الذي يجمع تجارب واجهات مستخدم مبنية بـ Fable 5. يضم هذا المستودع أمثلة لصفحات هبوط وأقسام رئيسية وتظليل GLSL وأنظمة تصميم وحركات ومشاهد ثلاثية الأبعاد، مُنفّذة فوق React وTailwind وThree.js، ويمكن فتح النتائج مباشرة والاطلاع على الشيفرة كاملة. وبما أنه يمكن معاينة كل تجربة في المتصفح مباشرة، فإن السؤال "هل هذا يعمل فعلًا؟" يمكن التحقق منه بالتشغيل الفعلي لا بمجرد لقطة شاشة، وهذا أمر مهم.

وهناك مثال آخر يجمع بين Fable 5 وHiggsfield MCP لبناء موقع ويب سينمائي متحرك بالتمرير، موثّق بشكل علني أيضًا. ما يستحق الانتباه هنا هو أن النموذج لا يقوم بكل شيء بمفرده، بل يتصل عبر موصّل MCP بأداة خارجية (توليد الأصول البصرية في هذه الحالة) وتُدمج النتيجة في مخرج واحد. وهذا مؤشر على أن توليد الويب التفاعلي يتطور من كونه موهبة نموذج واحد إلى ثمرة خط إنتاج تتشابك فيه النماذج مع الأدوات.

وخلاصة ما يمكن تأكيده حتى الآن هو ما يلي. أولًا، تخرج من مطالبة واحدة مسودة قابلة للتشغيل لموقع ثلاثي الأبعاد تفاعلي. ثانيًا، يتم التحقق من هذه النتيجة عبر شيفرتها الكاملة في مستودعات منشورة. ثالثًا، تتكامل روابط الأدوات كـ MCP مع خط الإنتاج وصولًا إلى توليد الأصول. غير أنه لا توجد في هذه الحالات مقاييس أداء كمية موحّدة ومنشورة (معدل الإطارات، حجم الحزمة، درجة إمكانية الوصول)، وهذا ليس تخمينًا بل حقيقة يُستحسن التعامل معها بجدية عند تقييم الجودة، إذ يبقى الحكم على الجودة رهينًا بمعايير المراجعة الخاصة بكل جهة.

## دلالات على مستوى منتجات ThakiCloud

تتقاطع هذه الموجة تمامًا مع الاتجاه الذي تسير فيه Paxis من ThakiCloud. فـ Paxis هو مستوى التحكم في Agent-Native Cloud الذي يعمل فوق ai-platform، ويتعامل مع المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. ما أظهره Fable 5 هو أن وكيل البرمجة تجاوز كونه مستجيبًا لمهمة واحدة ليصبح كيانًا توليديًا يواصل سلسلة من المراحل بنفسه. ولوضع هذا النوع من الوكلاء في سير عمل المنتج، يصبح "أين يُنفَّذ وبأي صلاحية وماذا يُسجَّل" أمرًا لا يقل أهمية عن "ماذا يولّد".

وإذا نظرنا إلى سير العمل أعلاه من منظور Paxis، تتحوّل كل مرحلة إلى مورد ضمن مستوى التحكم. فمهمة متكررة مثل توليد الويب التفاعلي تُسجَّل كمهارة واحدة تُختار عبر BM25 من مجموعة تضم نحو 960 مهارة، بينما يُنفَّذ توليد الشيفرة والبناء الفعلي في بيئة معزولة (sandbox). وكما في حالة Higgsfield MCP، إذا احتاج الأمر إلى أداة خارجية، يتولى موصّل MCP إعادة الاتصال عبر OAuth تلقائيًا. وقبل أن يصل الناتج إلى بيئة الإنتاج، تفرض بوابة السياسات قواعد المراجعة، ويُسجَّل كل إجراء في سجل التدقيق. وباختصار، ما يفعله مستوى التحكم هو الارتقاء بـ"براعة الذكاء الاصطناعي الفردية في إنتاج واجهات جيدة" إلى خط إنتاج قابل للتكرار يمكن للفريق أن يثق به ويراجعه.

وهناك دلالات أيضًا على مستوى البنية التحتية. فالواجهات الأمامية التي تتضمن مشاهد ثلاثية الأبعاد وتظليلًا تتطلب في مرحلة التوليد عمليات معالجة رسومية ثقيلة وبناءً متكررًا. وتعتمد منصة ai-platform لدى ThakiCloud على K8s وKueue لجدولة هذه الأعباء المتقطعة داخل مستأجرين معزولين، وربط الموارد وفصلها عند الحاجة فقط لضبط التكلفة. والقدرة على تشغيل خط الإنتاج هذا ذاتيًا في بيئات محلية وسيادية تكتسب أهمية خاصة للعملاء الذين يصعب عليهم إخراج الشيفرة وأصول التصميم إلى خارج بيئتهم. فوجود بنية تحتية موثوقة ومنخفضة الكلفة للتوليد والبناء (ai-platform) هو الأساس الذي تقوم عليه جدوى اقتصاد الوكلاء (Paxis).

## الحدود والحجج المضادة

الاكتفاء بالتفاؤل يُخلّ بالتوازن. لذا نوضّح هنا بعض النقاط المقابلة بجلاء.

أولًا، لا تزال قابلية صيانة شيفرة التفاعل المولَّدة غير مؤكدة. فمشهد ثلاثي الأبعاد ناتج عن مطالبة واحدة قد يكون مبهرًا، لكن قدرة شخص آخر على فهم منطق إدارة الحالة فيه وتعديله بعد أشهر قضية مختلفة تمامًا. وغالبًا ما يتعارض البهاء مع قابلية الصيانة.

ثانيًا، لا يأتي الأداء وإمكانية الوصول تلقائيًا. فكما أُشير سابقًا، معدل الإطارات على الأجهزة المحمولة، وحجم الحزمة، ودعم قارئات الشاشة، ليست مجالات يتكفّل بها النموذج افتراضيًا، وإن لم تُحدَّد كبوابة مراجعة صريحة، ستتحول إلى دين تقني.

ثالثًا، هناك مسألة أصالة النتائج. فإذا أنتجت مطالبات متشابهة أقسامًا رئيسية ثلاثية الأبعاد متشابهة، قد ينشأ ما يمكن تسميته "توحيد جماليات الذكاء الاصطناعي"، حيث تتقارب كل المواقع نحو مزاج واحد. وكلما ازدادت قوة الأداة، ازدادت أهمية حكم الإنسان في تحديد ما يجب بناؤه.

رابعًا، غياب مقاييس كمية موحّدة في الحالات المنشورة يستدعي الحذر. فرغم كثرة الشهادات الانطباعية التي تصف الفارق بأنه "من مستوى مختلف تمامًا"، لا يزال هذا الادّعاء يفتقر إلى تحقق كافٍ عبر معايير قابلة لإعادة الإنتاج. لذا يُنصح، قبل التبنّي الفعلي، بإجراء تجربة مباشرة على البنية التقنية والمعايير الخاصة بك.

في المحصلة، خفّض Fable 5 بشكل فعلي عتبة الدخول إلى توليد الويب التفاعلي. لكن تحويل هذه النتيجة إلى منتج يمكن الوثوق به يظل مسألة مراجعة وسياسات وبنية تحتية. وكيفية إغلاق تلك المرحلة الأخيرة كنظام متكامل هو ما يفصل بين فريق يستخدم أداة وفريق يبني منتجًا.

## المصادر

- Viktor Oddy، "Claude Fable 5 Just Changed Web Design Forever!" (فيديو ومقال إرشادي)، <https://www.youtube.com/watch?v=_JF_s-ZRTyY>
- pulkitxm/claude-directory، معرض مفتوح المصدر لتجارب واجهات مستخدم مبنية بـ Fable 5 (React·Tailwind·Three.js·GLSL)، <https://github.com/pulkitxm/claude-directory>
- "I Built a Cinematic Scroll Website Using Claude Fable 5 and Higgsfield MCP"، Medium، <https://medium.com/@info.booststash/i-built-a-cinematic-scroll-website-using-claude-fable-5-and-higgsfield-mcp-72fbcebb8ad1>
