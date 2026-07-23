---
title: "فاتورة بقيمة 25 مليار وون تطرح سؤالا: لماذا تكلفة وكلاء الذكاء الاصطناعي غير مرئية؟"
excerpt: "من حادثة فوترة بقيمة 25 مليار وون طالت مستخدما محليا إلى شبهات فوترة زائدة شملت 60 شركة، تشير أخبار تكلفة الذكاء الاصطناعي في الشهر الأخير إلى فجوة واحدة. في عصر الوكلاء حيث يتحول الطلب الواحد إلى مئات من استدعاءات النموذج، لم تعد الفاتورة تفسر ما الذي دُفع المال مقابله. هذا المقال يلخص كيفية سد فجوة المراقبة هذه."
seo_title: "مراقبة تكلفة وكلاء الذكاء الاصطناعي و FinOps: الدروس المستفادة من حادثة فوترة 25 مليار وون"
seo_description: "خطأ فوترة أنثروبيك بقيمة 25 مليار وون في يوليو 2026، شبهات فوترة زائدة بقيمة 1.7 مليون دولار طالت 60 شركة، وصولا إلى عاصفة إعادة المحاولة (retry storm) والتقنية المعلوماتية الظل (shadow IT). نحلل البنية التي تجعل التكلفة في أحمال عمل الوكلاء غير قابلة للمراقبة، ونستعرض استراتيجية ThakiCloud للتعامل معها عبر الاستضافة الذاتية ومراقبة تكلفة الوكلاء وحوكمتها."
date: 2026-07-20
tags:
  - LLMOps
  - FinOps
  - تكلفة الوكلاء
  - مراقبة التكلفة
  - توجيه النماذج
  - self-hosting
  - Paxis
  - بنية الذكاء الاصطناعي التحتية
author_profile: true
toc: true
toc_label: تشريح الفاتورة غير المرئية
published: true
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/agent-cost-observability-billing-crisis/"
---

كُتب هذا المقال لمهندسي المنصات والبنية التحتية الذين يخططون لإدخال Claude Code أو وكلاء الذكاء الاصطناعي إلى مؤسساتهم، وللمسؤولين الماليين ومسؤولي المشتريات الذين سيضطرون لتفسير فاتورة الذكاء الاصطناعي في الشهر القادم. ولنبدأ بالخلاصة: أخبار تكلفة الذكاء الاصطناعي التي توالت خلال الشهر الأخير لا تدور حول أن "الذكاء الاصطناعي مكلف". المشكلة الحقيقية هي أن **الفاتورة لا تفسر ما الذي تمثله**. ففي بنية الوكلاء، حيث يتحول طلب مستخدم واحد إلى عشرات أو مئات من استدعاءات النموذج وتنفيذ الأدوات، ثم إلى إعادة محاولة تلقائية عند الفشل، لا يمكن للمبلغ النهائي وحده أن يكشف أين تسربت الأموال داخل أي حلقة تنفيذ. نرى أن هذه الفجوة في المراقبة هي بالضبط جوهر الألم الذي يعيشه السوق الآن.

## نظرة عامة

يمكن تلخيص أخبار الفترة من أواخر يونيو حتى يوليو 2026 في سطر واحد: الاستخدام العشوائي للنماذج المتطورة (frontier models) في كل مهمة يجعل التكلفة يصعب تحملها، بل ويصعب حتى تتبع مصدرها. وقد ظهرت الحادثة بشكل درامي. فقد جرت محاولة تحصيل مبلغ يقارب 2.5 مليار وون من مستخدم محلي واحد، ثم محاولة تحصيل نحو 25 مليار وون لاحقا. ولحسن الحظ لم يُسحب أي مبلغ فعليا بسبب تجاوز حد البطاقة، غير أن تكرار وصول مبلغ غير طبيعي إلى مرحلة طلب موافقة البطاقة، وليس مجرد خطأ عرض، هو ما يمنح الحادثة وزنها المختلف.

وفي الفترة نفسها توالت أخبار من مستويات أخرى. فقد راجعت شركة تدقيق تكاليف الذكاء الاصطناعي فواتير 60 شركة وادّعت وجود فوترة زائدة كبيرة، وبدأت عدة شركات كبرى بتوزيع استخدام النماذج المتطورة على نماذج أرخص بحسب طبيعة المهمة، كما ورد أن شركات أمريكية وأوروبية انتقلت إلى نماذج صينية مفتوحة الأوزان بدافع خفض التكلفة. والمثير أن مزودي النماذج أنفسهم بدؤوا بالرد بما يفيد أن "تشغيل أفضل النماذج أداءً لفترات طويلة في كل مهمة أمر غير مستدام". وكانت أخبار متعددة الاتجاهات تشير إلى النقطة نفسها.

## ماذا حدث في الشهر الأخير

أول ما لفت الانتباه كان مشكلة موثوقية نظام الفوترة. وبحسب تقرير ZDNet Korea، بدأ المبلغ المطلوب من طالب جامعي محلي بنحو 1.66 مليون دولار، ثم تضخم إلى نحو 16.62 مليون دولار أي عشرة أضعاف. وأوضحت أنثروبيك لاحقا أن الخطأ كان في إعداد مبلغ الشحن التلقائي الذي ضُبط بشكل غير طبيعي المرتفع، إلا أن المستخدم أكد أنه لم يُفعّل خاصية الشحن التلقائي إطلاقا، ما يترك سبب نشوء هذا الإعداد غامضا حتى الآن. وتُظهر واقعة إرسال المستخدم أكثر من خمس عشرة رسالة إلى عدة أقسام دون تلقي رد آلي إلا بعد مرور أربعة أيام، فجوةً في منظومة الاستجابة أوضح من كونها مجرد خطأ تقني.

المشكلة الثانية كانت في قابلية مراقبة تكلفة الوكلاء. وبحسب تقارير AI Times و The Information، أعلنت شركة ناشئة متخصصة في تدقيق التكاليف تُدعى Vaudit أنها راجعت فواتير 60 شركة بقيمة إجمالية نحو 34 مليون دولار، وخلصت إلى أن نحو 1.7 مليون دولار منها كانت فوترة زائدة. وشكّل استخدام Claude Code جزءا كبيرا من نطاق المراجعة، وذُكرت شركات مثل باناسونيك وHP وهوندا ضمن العملاء. وحسب ادعاء الشركة، فإن الأنماط شملت تسجيل استخدام نموذج رخيص بأسعار نموذج أغلى، وفرض رسوم على مهام لم تُنجز، وتكرار إعادة المحاولة التلقائية بعد الخطأ فيما يُعرف بـ**عاصفة إعادة المحاولة (retry storm)**. وهنا ينبغي توضيح نقطتين. أولا، ردت أنثروبيك بأنها لا تفرض رسوما على الطلبات غير المكتملة أو الاستجابات الخاطئة، وأنه لا يوجد دليل واسع على فوترة زائدة. ثانيا، تحصل Vaudit على نسبة من مبالغ الاسترداد الناجحة، أي أنها شركة تدقيق تجارية، لذا يجب قراءة هذه الأرقام كنتيجة تحقيق من طرف واحد لا كتدقيق حسابي مستقل. وبعبارة أخرى، نحن الآن في مرحلة تصادم بين ادعاءات شركة التدقيق ونفي المزود.

المشكلة الثالثة كانت في استجابة السوق. وذكرت The Information أن الشركات بدأت بفصل المهام: النماذج الرخيصة للتصنيف والتلخيص والتحويل البسيط، والنماذج المتطورة للبرمجة المعقدة ومهام الوكلاء، والنماذج مفتوحة الأوزان أو المستضافة ذاتيا للمهام المتكررة عالية الحجم. ونقلت الفايننشال تايمز أن شركات مثل DoorDash وSiemens وAirbnb اعتمدت نماذج DeepSeek أو من عائلة Moonshot لخفض التكلفة. وفي تقرير لـ Business Insider، اعترف حتى مسؤولو المنصة في أنثروبيك بأن ما يُعرف بـ**التقنية المعلوماتية الظل (shadow IT)**، أي اعتماد كل قسم لأدواته الخاصة بشكل منفصل، أدى إلى تضخم تكاليف الذكاء الاصطناعي في بعض الشركات، لكنهم شددوا على أن الحل ليس إيقاف الاستخدام أو فرض سقف ميزانية موحد، بل اختيار النموذج بحسب المهمة وإدارة مركزية للتكلفة على مستوى المؤسسة. كما تغيرت سياسات التسعير نفسها مرارا: تعدّلت مرات عدة شمولية النماذج عالية الأداء الأحدث ضمن الاشتراك وتوقيت التحول إلى الدفع بحسب الاستخدام، وتكرر تمديد مواعيد انتهاء العروض الترويجية. بل ورد أن إتاحة Claude Fable 5 مجانا امتدت حتى 19 يوليو. وكانت صعوبة توقع تكلفة الشهر القادم أكبر إزعاج لمسؤولي المشتريات، أكثر حتى من مسألة الأداء.

## لماذا لا يمكن مراقبة تكلفة الوكلاء

السبب المشترك الذي يجمع بين هذه المسارات الثلاثة من الأخبار هو في النهاية واحد. ففي أحمال عمل الوكلاء، اتسعت المسافة كثيرا بين ما يراه المستخدم وما تسجله الفاتورة. كانت استدعاءات API التقليدية طلبا واحدا مقابل استجابة واحدة وسطر تكلفة واحد. أما وكلاء البرمجة أو حزم تطوير الوكلاء (agent SDK)، فإن أمرا واحدا فيها يتوسع إلى وضع خطة وتنفيذ واستدعاء أدوات وتحرير ملفات وتحقق، ثم إعادة محاولة عند الفشل. يحدث هذا التوسع في مكان لا يراه المستخدم، بينما تسجل الفاتورة مجموعه الكلي في سطر واحد فقط.

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
<div class="d3-arch" data-arch-root id="servabilitybillingcrisis-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 555, "height": 930, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 179, "y": 24, "w": 135, "h": 46, "title": "طلب مستخدم واحد"}, {"id": "P", "x": 363, "y": 148, "w": 128, "h": 46, "title": "وضع خطة الوكيل"}, {"id": "L", "x": 367, "y": 272, "w": 120, "h": 46, "title": "حلقة التنفيذ"}, {"id": "T", "x": 332, "y": 396, "w": 191, "h": 78, "title": ["استدعاء أدوات · استدعاء", "نموذج", "عشرات إلى مئات المرات"]}, {"id": "R", "x": 358, "y": 552, "w": 138, "h": 52, "title": "هل نجحت؟"}, {"id": "RS", "x": 342, "y": 696, "w": 170, "h": 62, "title": ["إعادة محاولة تلقائية", "(retry storm)"]}, {"id": "ACC", "x": 103, "y": 696, "w": 184, "h": 62, "title": ["توكن · كاش · tool call", "تجميع تراكمي"]}, {"id": "INV", "x": 35, "y": 836, "w": 191, "h": 62, "title": ["الفاتورة: مبلغ نهائي في", "سطر واحد"]}], "edges": [{"src": "U", "dst": "P", "kind": "data", "curve": [[313, 70], [427, 109], [427, 109], [427, 148]]}, {"src": "P", "dst": "L", "kind": "data", "line": [427, 194, 427, 272]}, {"src": "L", "dst": "T", "kind": "data", "line": [427, 318, 427, 396]}, {"src": "T", "dst": "R", "kind": "data", "line": [427, 474, 427, 552]}, {"src": "R", "dst": "RS", "kind": "data", "label": "\"فشل\"", "curve": [[454, 604], [503, 650], [503, 650], [458, 696]], "off": "50%"}, {"src": "RS", "dst": "T", "kind": "data", "curve": [[342, 702], [163, 650], [163, 513], [332, 463]]}, {"src": "R", "dst": "ACC", "kind": "data", "label": "\"نجاح\"", "curve": [[371, 604], [271, 650], [271, 650], [226, 696]], "off": "50%"}, {"src": "ACC", "dst": "INV", "kind": "data", "curve": [[195, 758], [195, 797], [195, 797], [159, 836]]}, {"src": "INV", "dst": "U", "kind": "event", "label": "فجوة المراقبة", "curve": [[102, 836], [66, 578], [66, 295], [179, 70]], "off": "50%"}]});
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
      const container = document.getElementById('servabilitybillingcrisis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'servabilitybillingcrisis-1';
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

في هذه البنية، تقع معظم نقاط تسرب التكلفة خارج مجال رؤية المستخدم. فحلقة إعادة المحاولة تعمل بصمت وتضخم عدد الاستدعاءات، ويحدث تباين بين الاستخدام الفعلي للنموذج والتفاصيل النهائية للفاتورة عند المرور عبر مزود سحابي وسيط، وإذا اختل إعداد واحد مثل الشحن التلقائي فقد يتدفق مبلغ غير طبيعي حتى مرحلة طلب موافقة البطاقة. تبدو الأخبار الثلاثة وكأنها حوادث منفصلة، لكنها في الواقع أوجه مختلفة لفجوة المراقبة نفسها. لذلك لا يكفي مجرد وضع حد شهري لكل مستخدم. المطلوب هو طبقة قياس مركزية تلتقط تكلفة كل نموذج، وتوكنات كل جلسة، وتوكنات الكاش، وعدد استدعاءات الأدوات، وتكلفة الفشل وإعادة المحاولة، ومعدل الزيادة اليومي غير الطبيعي **في اللحظة التي يحدث فيها الاستدعاء نفسه**. فبلا مراقبة لا توجد سيطرة، وبلا سيطرة تبقى الفاتورة دائما وثيقة مفاجأة بعد وقوع الحدث.

## دلالات التطبيق على منتجات ThakiCloud

هذه المشكلة هي النقطة التي يستهدفها منتجا ThakiCloud من زاويتين مختلفتين. ولأن منظور البنية التحتية ومنظور الوكلاء يكملان بعضهما، نستخدم في هذا الموضوع العدستين معا.

**عدسة ai-platform: الملكية هي الحل لأحمال العمل المتكررة.** الاستنتاج الذي وصل إليه السوق واضح. فمعالجة حتى المهام السهلة بنماذج متطورة يجعل التكلفة غير محتملة، بينما تصبح استضافة نموذج مفتوح الأوزان ذاتيا خيارا اقتصاديا للمهام المتكررة عالية الحجم. ومنصة ai-platform من ThakiCloud هي بالضبط بنية تحتية للذكاء الاصطناعي وتعلم الآلة قائمة على K8s مصممة لهذه النقطة. فهي تستخدم Kueue لجدولة وحدات GPU في طابور وزيادة معدل استخدامها، وتستخدم vLLM لخدمة النماذج مفتوحة الأوزان، وتعزل الاستخدام بحسب كل قسم عبر عزل متعدد المستأجرين مع فوترة منفصلة. فإذا كانت واجهات برمجة التطبيقات القائمة على الدفع بحسب الاستخدام تنتج فواتير يصعب توقعها، فإن الاستضافة الذاتية تبني بنية تكلفة GPU ثابتة لا يتقلب سعرها حتى مع تزايد الاستخدام. وعلى عكس الأنظمة الخارجية القائمة على الدفع بحسب الاستخدام التي تتغير سياساتها باستمرار، يحوّل النشر الداخلي أو السيادي إمكانية التنبؤ بالتكلفة نفسها إلى أصل قائم بذاته. كما أن عدم خروج البيانات إلى الخارج يمثل قيمة إضافية للمؤسسات ذات متطلبات التنظيم والأمن المحلية العالية.

**عدسة Paxis: جعل كل تصرف للوكيل قابلا للتدقيق.** كان جوهر فجوة المراقبة هو حلقة الوكيل، وهذا هو بالضبط المجال الذي تعالجه Paxis. فـPaxis هي مستوى التحكم في السحابة الأصيلة للوكلاء (Agent-Native Cloud) من ThakiCloud، وتعمل فوق ai-platform، وتتعامل مع المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. فكل ما يخص أي مهارة استدعاها الوكيل وبأي أداة وكم مرة، وفي أي بيئة معزولة تم التنفيذ، يُسجَّل بالكامل في سجل التدقيق. وفي هذه البنية، بدلا من أن تُضخّم عاصفة إعادة المحاولة الفاتورة بصمت، تظهر حلقة إعادة المحاولة بوضوح في سجل التدقيق، وتوقف بوابات السياسة الاستدعاءات التي تتجاوز العتبة المحددة. فتصميم يختار من بين أكثر من 960 مهارة عبر خوارزمية BM25 وينفذها في بيئة معزولة، ويُمرّر كل تصرف عبر السياسة والتدقيق، هو إجابة بنيوية بالضبط على مشكلة صعوبة معرفة أين نشأت التكلفة من مجرد النظر إلى الفاتورة. فالخدمة منخفضة التكلفة (ai-platform) تجعل الوكلاء اقتصاديين، بينما تجعل المراقبة على مستوى كل تصرف (Paxis) هذه الجدوى الاقتصادية قابلة للتنبؤ. وهكذا تتكامل العدستان.

## الحدود والرأي المعاكس

من أجل التوازن، نوضح الجانب المعاكس بجلاء. أولا، ليست النماذج المتطورة تبذيرا بالضرورة. فبحسب تقرير وول ستريت جورنال، ترى شركات مثل Shopify أن النماذج المتطورة، في مهام البرمجة المعقدة والوكلاء متعددة الخطوات، توفر وقت المهندسين بما يبرر سعرها المرتفع. في المقابل، تتوخى شركات مثل Spotify وTwilio الحذر في تقييم ما إذا كان التحسن الطفيف في الأداء يبرر التكلفة الإضافية. أي أن الجواب ليس "تخلَّ عن النماذج المتطورة"، بل "وزّع بحسب صعوبة المهمة". كما أن الاستضافة الذاتية ليست حلا شاملا لكل شيء؛ فتخفيض المهام التي تتطلب أعلى مستوى من الاستدلال إلى نماذج مفتوحة الأوزان يؤدي إلى تراجع الجودة، ويخلق عبئا تشغيليا جديدا يشمل تشغيل وحدات GPU وتحديث النماذج وتصحيحات الأمان.

ثانيا، الأرقام المتعلقة بالفوترة الزائدة المذكورة في هذا المقال ليست حقائق مؤكدة. فادعاء Vaudit هو إعلان من شركة تدقيق تجارية، وقد نفته أنثروبيك، لذا فإن الأدق حاليا هو قراءة الموقف على أنه تصادم بين طرفين. وحادثة الفوترة بمبلغ 25 مليار وون كذلك لم يُسحب فيها أي مبلغ فعليا، ولم يُكشف بعد عن تفسير تقني لسبب نشوء إعداد الشحن التلقائي. والاستنتاج الذي نخلص إليه من هذه الأخبار لا يستهدف مزودا بعينه، بل هو مبدأ مفاده أنه في عصر الوكلاء، وأيا كان المزود المستخدَم، يجب على الجهة المستخدِمة نفسها أن تؤمّن مراقبة التكلفة وحوكمتها. فمسألة اختيار نموذج جيد ومسألة ضبط ذلك النموذج مسألتان منفصلتان، وما كشفته أخبار الشهر الأخير هو أن المسألة الثانية كانت فارغة طوال الوقت.

## المصادر

- [ZDNet Korea، "مستخدم محلي تلقى طلب دفع بقيمة 25 مليار وون... جدل حول خطأ فوترة أنثروبيك" (2026-07-09)](https://zdnet.co.kr/view/?no=20260709165452)
- [ZDNet Korea، "أنثروبيك التي طالبت بـ25 مليار وون: تبين أنه خطأ في إعداد الشحن التلقائي" (2026-07-16)](https://zdnet.co.kr/view/?no=20260716093004)
- [AI Times، "أنثروبيك في جدل 'الفوترة الزائدة للذكاء الاصطناعي': تحصيل رسوم حتى على المهام الفاشلة" (2026-06)](https://www.aitimes.com/news/articleView.html?idxno=212155)
- [The Information، تقرير عن سيطرة الشركات على تكلفة الذكاء الاصطناعي وتوزيع النماذج (2026-06-23)](https://www.theinformation.com/titv/fedld)
- [Financial Times، "Companies turn to Chinese AI models to cut costs" (2026-07)](https://www.ft.com/content/9c8ff45b-7c20-4c2e-93c9-c52339ffdcee)
- [Business Insider، "Anthropic Official Warns Against 'Wrong' AI Cost Response" (2026-07-15)](https://www.businessinsider.com/anthropic-ai-costs-responses-routers-2026-7)
- [The Wall Street Journal، "Meet the Companies Shelling Out for Top AI Models" (2026-07)](https://www.wsj.com/cio-journal/meet-the-companies-shelling-out-for-top-ai-models-e1fe3375)
