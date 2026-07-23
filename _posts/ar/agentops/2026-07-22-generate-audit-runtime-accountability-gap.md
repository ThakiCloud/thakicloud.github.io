---
title: "الوكيل الذي يكتب الكود والوكيل الذي يراقبه ظهرا في اليوم نفسه"
excerpt: "في الثاني والعشرين من يوليو، وقف إصداران مفتوحا الأوزان وجها لوجه كالمرآة. أحدهما يولد الكود، والآخر يبحث عن ثغراته. لكن يبقى سؤال واحد لم يجب عليه أي منهما، وهو على بنية تحتية من، وبأي صلاحية، يعمل ذلك الكود فعليا."
seo_title: "ثنائي التوليد والتدقيق، مشكلة المساءلة في طبقة التنفيذ التي كشفتها وكلاء الكود مفتوحة الأوزان"
seo_description: "صدر Laguna S 2.1 من Poolside وAntares من سيسكو في اليوم نفسه. في عصر يتم فيه استضافة توليد الكود وتدقيقه ذاتيا بأوزان مفتوحة، نستعرض مشكلة المساءلة الغائبة في طبقة التنفيذ."
date: 2026-07-22
last_modified_at: 2026-07-22
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
tags:
  - agentops
  - paxis
  - enterprise-ai
  - thakicloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/generate-audit-runtime-accountability-gap/"
---

يبدو التطابق دقيقا أكثر من أن يكون محض صدفة. في الثاني والعشرين من يوليو 2026، ظهر نموذجان مفتوحا الأوزان، متعاكسان تماما في طبيعتهما، إلى العالم في اليوم نفسه. أحدهما يكتب الكود، والآخر يبحث عن ثغرات ذلك الكود. أطلقت شركة Poolside نموذج Laguna S 2.1 المخصص لوكلاء البرمجة الذين يستضيفهم المستخدم بنفسه، بينما كشفت سيسكو عن Antares، نموذج صغير مفتوح الأوزان متخصص في كشف الثغرات البرمجية. السيف والدرع معروضان جنبا إلى جنب في الواجهة نفسها.

عند قراءة هذين الإصدارين كل على حدة، يبدوان خبرين عاديين. أما عند وضعهما جنبا إلى جنب، فتتغير القصة كليا. فهذا يعني أن الجهة التي تصنع البرمجيات والجهة التي تدقق تلك البرمجيات تنتقلان في الوقت نفسه إلى نموذج الوكلاء. وفي اللحظة التي يضع فيها أي طرف كلا النموذجين على بنيته التحتية الخاصة، يبقى سؤال لا يجيب عليه أحد بالنيابة عنه، وهو على بنية تحتية من، وبأي صلاحية، وبأي سجل يتم توثيقه، تعمل هذه الوكلاء فعليا.

## نفس اليوم، من الطرف المقابل تماما

يمثل Laguna S 2.1 من Poolside ورقة رد أقرب ما تكون إلى الجبهة الغربية. جاء هذا الإعلان في سياق التيار الذي كانت تتصدره نماذج مفتوحة الأوزان من أصل صيني مثل DeepSeek وQwen في مجال وكلاء البرمجة. وصفته وسائل إعلام أجنبية بأنه الخيار الأكثر موثوقية بين النماذج الغربية مفتوحة الأوزان خلال العام الماضي لغرض البرمجة الوكيلية المستضافة ذاتيا. واللافت هنا ليس الأداء بل الحجم. فبنية منخفضة التنشيط تضم ثمانية مليارات معامل نشط استطاعت مجاراة منافسين أكبر بأضعاف في مقاييس الأداء، وهذا يعني أن الرسالة الحقيقية هي خفض تكلفة الاستدلال وعبء التشغيل على المنشأة في آن واحد. والقدرة على تشغيله على جهاز واحد بمستوى DGX Spark تعني أنه يمكن الآن تشغيل وكيل برمجة مخصص حتى على تقسيمات GPU صغيرة.

يطرح Antares من سيسكو المنطق نفسه من الجهة المقابلة. فالنماذج اللغوية الصغيرة التي تعمل على الجهاز مباشرة تتفوق على النماذج العامة الضخمة في مجال الأمن من ناحيتي التكلفة والدقة معا. وتقول سيسكو إن Antares تفوق في مقاييس الأداء على أكثر من عشرة نماذج كبيرة مفتوحة ومغلقة المصدر، مع كلفة تشغيل أقل بكثير. والعامل الحاسم هنا هو موقع التنفيذ. فتشغيله محليا يعني أن الكود المصدري لا يغادر البيئة الداخلية، وهذه الجملة وحدها هي التي تحدد إمكانية التبني في القطاعين المالي والحكومي حيث تشدد القيود على تصدير الكود المصدري.

النموذجان متعاكسان في الاتجاه، لكن فلسفة التصميم واحدة، وهي أن يصغر الحجم، وأن يفتح الوزن، وأن يعمل على بنية تحتية داخلية لا على سحابة الغير. حتى استراتيجية النشر متشابهة، فالممارسة الشائعة الآن لدى الشركات الناشئة في مجال الأمن والبائعين الكبار على حد سواء هي طرح النموذج الأساسي مفتوح الأوزان مع الاحتفاظ بأفضل نسخة أداء داخل المنتج التجاري الخاص بالشركة. وهكذا يعاد تشكيل كل من التوليد والتدقيق وفق قواعد الاستضافة الذاتية جنبا إلى جنب.

## النقطة التي غيرت فيها الأوزان المفتوحة قواعد التدقيق

كان فحص الثغرات البرمجية في السابق يعتمد غالبا على استدعاء نموذج طليعي، وكانت المشكلة مزدوجة، إذ كانت التكلفة تعيق التشغيل المستمر، وكان الكود المصدري موضع الفحص يتسرب إلى واجهة برمجة تطبيقات خارجية. وهذا هو السبب الذي دفع عددا كبيرا من فرق الأمن المحلية إلى التخلي عن الفحص المستمر بسبب قيود الميزانية. يعالج Antares هذين العائقين في آن واحد، فالتشغيل المحلي يزيل مشكلة التصدير، والنموذج الصغير يخفض التكلفة. وفي هذا السياق بالذات، حددت سيسكو صراحة الجامعات والقطاع العام وفرق الأمن الصغيرة ذات الميزانية المحدودة كجمهور مستهدف.

وينطبق المنطق نفسه على جانب التوليد أيضا. فامتلاك Laguna S 2.1 لترخيص متساهل إلى جانب كونه مفتوح الأوزان يوسع من إمكانية بناء مساعد برمجة مستضاف ذاتيا في القطاعين المالي والعام اللذين يتعين عليهما تلبية بيئات معزولة عن الشبكة أو متطلبات جهات رقابية وطنية. وهذا يعني ظهور خيار إضافي لتقليل الاعتماد على واجهات برمجة التطبيقات المغلقة. غير أن هذه الحرية تحمل معها واجبا، فبيئة التوزيع والدعم المحلية وقدرة النموذج على التعامل مع التعليقات البرمجية باللغة الكورية لم تُختبر بعد، لذلك يجب أن يمر أي تبني فعلي أولا باختبار إعادة إنتاج مقاييس الأداء واختبار ملاءمة البيئة المحلية.

مع ذلك، رسمت سيسكو حدودها بنفسها، إذ أوضحت أن هذا النموذج لا يحل محل تحليل التبعيات ولا فحص المعلومات السرية ولا الاختبار الديناميكي، وأن مكانه الصحيح هو مرحلة الفرز الأولي. وهذا حد صريح وصادق. وهذا الحد بالذات هو ما يقودنا إلى الموضوع الحقيقي لهذا المقال، وهو أن نموذج التوليد ونموذج التدقيق كليهما لا يؤديان في النهاية سوى جزء من الدور، بينما يظل ربط هذين الجزأين في تدفق واحد قابل للمساءلة مسألة منفصلة تماما.

## الفجوة التي لا يسدها لا التوليد ولا التدقيق

أظهر خبر آخر في اليوم نفسه هذه الفجوة بوضوح تام. أعلنت منصة التجارة الإلكترونية المحلية Imweb أنها أدخلت الذكاء الاصطناعي في كامل عمليات التطوير والتشغيل لديها، ما خفض عملا كان يستغرق أربع سنوات إلى ثلاثة أشهر فقط. وتبنت ثقافة محافظة تستخدم نماذج OpenAI وAnthropic وGoogle في وقت واحد للتحقق المتبادل. لكن جملة واحدة تستوقف القارئ، وهي أن اكتشاف أي خلل في البنية التحتية يؤدي إلى تراجع تلقائي فوري عن النشر دون موافقة بشرية. هذا إنجاز يستحق الفخر من زاوية الإنتاجية، لكنه إشارة إنذار من زاوية الحوكمة. فوكيل يستطيع التراجع عن بيئة الإنتاج من دون موافقة يعني أنه قادر أيضا على القيام بأمور أخرى من دون موافقة.

وتشير الإشارة القادمة من القطاع العام إلى النتيجة نفسها من الاتجاه المعاكس تماما. فعند إدخال خدمات الذكاء الاصطناعي التوليدي، وضعت مؤسسة التأمين على الودائع بناء فهرس البيانات ونظام إدارة مخاطر الذكاء الاصطناعي كأولوية سابقة لاختيار النموذج نفسه. وكون مؤسسة تدير أصول المواطنين تضع منظومة الضبط قبل النموذج يكشف بوضوح أن العتبة الحقيقية لتبني الذكاء الاصطناعي في الصناعات الخاضعة للتنظيم ليست الأداء، بل قابلية التفسير وإمكانية تتبع المساءلة. في جهة، يتقدم الاستقلال الذاتي، وفي الجهة الأخرى، يتأسس الضبط أولا. وعند نقطة التقاء هذين المطلبين، توجد اليوم فجوة في طبقة موحدة غائبة.

نموذج التوليد يصنع الكود، ونموذج التدقيق يبحث عن عيوب ذلك الكود. غير أن تسجيل درجة الاستقلالية التي يتحرك بها ذلك الوكيل، والسياسة التي يحصل بموجبها على الإذن للتنفيذ، وما الذي لمسه ومتى، لا يقع ضمن اختصاص أي من النموذجين. هذه ليست مشكلة النموذج، بل مشكلة طبقة التنفيذ.

## سيادة العتاد وحدها لا تغلق الفجوة

قد يبدو أن سد هذه الفجوة ممكن من خلال حجم البنية التحتية، لكن أخبار اليوم نفسها تقول عكس ذلك. ففي اليوم ذاته، التقى رؤساء ثلاث مجموعات، لي جاي يونغ وتشوي تاي وون ولي هاي جين، جنسن هوانغ في وادي السيليكون لإعادة تفعيل تحالف سلسلة توريد الذكاء الاصطناعي المتمحور حول إنفيديا، وهي خطوة كبرى قد تهز مشهد بنية الذكاء الاصطناعي السيادية المحلية. وأطلقت سامسونج SDS خدمة NPUaaS المعتمدة على وحدة معالجة عصبية محلية من FuriosaAI، وهي أول تجارية لبديل محلي عن الاعتماد شبه الكامل على وحدات GPU في بنية الاستدلال. وبالنسبة للقطاعين العام والمالي، فهذا يعني ظهور خيار سيادي إضافي لتقليل الاعتماد على وحدات GPU الأجنبية، وقد تظهر مستقبلا وحدات المعالجة العصبية المحلية كشرط في مناقصات السحابة الحكومية.

تُملأ السيادة على مستوى الرقائق ومراكز البيانات وسلاسل التوريد بسرعة كبيرة. لكن سيادة العتاد لا تجيب سوى عن نصف السؤال. فتشغيل وكيل برمجة مستضاف ذاتيا فوق وحدة معالجة عصبية محلية لا يعرّف تلقائيا ما الذي يملك ذلك الوكيل صلاحية القيام به وما الذي يجب أن يسجله. فمنع التصدير وضبط التنفيذ مسألتان في طبقتين مختلفتين تماما. وكلما اكتملت البنية التحتية السيادية، برز بشكل أوضح غياب طبقة تحدد بالبرمجيات درجة استقلالية الوكيل الذي يعمل فوقها وآلية تدقيقه.

## المطابقة تتم في طبقة التنفيذ

إذا رسمنا في صورة واحدة التوليد والتدقيق والفجوة القائمة بينهما، تكون النتيجة كما يلي.

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
<div class="d3-arch" data-arch-root id="runtimeaccountabilitygap-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 587, "height": 788, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 352, "w": 531, "h": 404, "label": "ThakiCloud Paxis · Execution Layer", "lx": 36, "ly": 370}], "nodes": [{"id": "G1", "x": 302, "y": 32, "w": 184, "h": 62, "title": ["Agent that writes code", "Laguna S 2.1"]}, {"id": "A1", "x": 105, "y": 24, "w": 142, "h": 78, "title": ["Agent that finds", "vulnerabilities", "Antares"]}, {"id": "GAP", "x": 183, "y": 180, "w": 205, "h": 94, "title": ["The unanswered question", "on whose resources", "with what authority", "logging what, does it run"]}, {"id": "P1", "x": 183, "y": 391, "w": 205, "h": 62, "title": ["Policy gate", "L0-L3 autonomy governance"]}, {"id": "P2", "x": 306, "y": 539, "w": 212, "h": 46, "title": "Isolated sandbox execution"}, {"id": "P3", "x": 352, "y": 671, "w": 120, "h": 46, "title": "Audit logs"}, {"id": "P4", "x": 67, "y": 531, "w": 184, "h": 62, "title": ["CostRouter · Sovereign", "Kubernetes"]}], "edges": [{"src": "G1", "dst": "GAP", "kind": "data", "curve": [[394, 94], [394, 141], [394, 141], [345, 180]]}, {"src": "A1", "dst": "GAP", "kind": "data", "curve": [[176, 102], [176, 141], [176, 141], [226, 180]]}, {"src": "GAP", "dst": "P1", "kind": "data", "line": [285, 274, 285, 391]}, {"src": "P1", "dst": "P2", "kind": "data", "curve": [[341, 453], [412, 492], [412, 492], [412, 539]]}, {"src": "P2", "dst": "P3", "kind": "data", "line": [412, 585, 412, 671]}, {"src": "P1", "dst": "P4", "kind": "data", "curve": [[229, 453], [159, 492], [159, 492], [159, 531]]}]});
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
      const container = document.getElementById('runtimeaccountabilitygap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'runtimeaccountabilitygap-1';
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

منصة Paxis من ThakiCloud تتناول بالضبط هذه الطبقة الغائبة. Paxis منتج فعلي يمثل سحابة مخصصة للوكلاء، يعامل المهارات والأدوات والسياسات وسجلات التدقيق كموارد أساسية من الدرجة الأولى. سواء وصلت وكيل برمجة مثل Laguna S 2.1 بالخلفية، أو وصلت نموذج تدقيق مثل Antares في مقدمة عملية الفحص، فإن ذلك الوكيل يمر في النهاية عبر بوابة سياسة ويُنفذ داخل صندوق رملي معزول، وتُسجَّل كل تصرفاته في سجل تدقيق. وإذا بدا التراجع التلقائي بلا موافقة في حالة Imweb مثيرا للقلق، فإن حوكمة الاستقلالية في Paxis الممتدة من المستوى L0 إلى L3 هي الوجه المقابل لذلك القلق، إذ يمكن الإعلان بالسياسة لا بالكود عن الحد الفاصل بين المهام التي تُترك للاستقلالية الكاملة والمهام التي تُلزَم بموافقة بشرية.

وتلتقي المتطلبات السيادية عند الطبقة نفسها. فكما أن Antares لا يكتسب معناه إلا حين يعمل محليا من دون تصدير الكود المصدري، تعمل Paxis فوق بنية Kubernetes سيادية أو داخلية، وتمتلك CostRouter الذي يختار النموذج المناسب لكل مهمة. وأسلوب تضييق نطاق الملفات المشتبه بها عبر نموذج محلي منخفض التكلفة، ثم استدعاء نموذج أكبر عند الحاجة فقط، هو بالضبط التنفيذ على مستوى البنية التحتية لذلك التصميم الذي أوصت سيسكو بوضع Antares فيه كمرشح أولي. وحتى مع إضافة نماذج وأدوات جديدة عبر موصلات MCP وسوق المهارات، لا تتغير قواعد التنفيذ والتسجيل. وحتى منظومة إدارة البيانات وإدارة المخاطر التي سعت مؤسسة التأمين على الودائع إلى بنائها قبل النموذج نفسه، تُستوعب هنا ضمن طبقة السياسات والتدقيق التي توفرها المنصة افتراضيا، بدلا من إعادة بنائها من الصفر في كل مشروع على حدة.

وهنا قد يُطرح اعتراض مشروع، وهو ألا يكون هذا مجرد طبقة ضبط إضافية أخرى، تعيد تقييد السرعة والاستقلالية التي استعادتها الأوزان المفتوحة بصعوبة تحت اسم السياسة والتدقيق. فإذا كانت Imweb قد أنجزت عملا يستغرق أربع سنوات في ثلاثة أشهر عبر التراجع الفوري دون موافقة بشرية، فتلك السرعة نفسها قد تكون مصدر التفوق التنافسي. هذا اعتراض وجيه. غير أن هدف حوكمة الاستقلالية ليس إلغاء الاستقلالية، بل رسم حدودها بوضوح صريح. فحين تُحدَّد سلفا المهام التي يجوز التراجع عنها دون موافقة والمهام التي تستلزم مرور إنسان بالضرورة، يمكن في الحيز الآمن التفويض بجرأة أكبر لا أقل. فحين تكون الحدود غامضة، يميل الفريق إلى الشك في كل أتمتة، أما حين تكون الحدود مرسومة بسياسة واضحة، يعمل الفريق داخلها بثقة واطمئنان. الضبط والسرعة ليسا في تضاد، بل يكبران معا حين تكون الحدود واضحة. ووضع مؤسسة التأمين على الودائع منظومة الضبط قبل النموذج لم يكن تأخيرا للتبني، بل خيارا لجعل ذلك التبني مستداما.

يعلن إصدارا الثاني والعشرين من يوليو أن الوكلاء بدأوا يمتلكون في الوقت نفسه القدرة على كتابة الكود ومراقبته، وهذا تقدم يستحق الترحيب. غير أن اتساع القدرة يوسع معه فجوة المساءلة أيضا. فكلما ازداد انتشار الوكلاء المولدة للكود والوكلاء المدققة له، ازدرد ندرة المكان الذي تُنفَّذ فيه هذه الوكلاء بأمان وتُسجَّل فيه أفعالها بلا نقصان. وبعد أن يكتمل السيف والدرع معا، يبقى سؤال واحد، وهو على قواعد من، في النهاية، يتقاتل هذان الطرفان. لقد أصبح اختيار النموذج أسهل يوما بعد يوم، غير أن تحمل المسؤولية عن النتيجة التي يصنعها ذلك النموذج لا يزال أمرا صعبا. وما يخبرنا به السيف والدرع المعلقان جنبا إلى جنب اليوم هو أن ساحة المنافسة المقبلة ليست النموذج الأكبر، بل طبقة التنفيذ التي تجعل تلك النماذج تعمل بأمان وحياة فعلية.

## المصادر

هذا المقال يجمع بين التغطية الإخبارية التالية:

- 글로벌경제، [엔비디아, 차세대 AI플랫폼 '베라루빈' 본격 공급 통해 "선두 수성"](https://www.getnews.co.kr/news/articleView.html?idxno=875704)
- 머니투데이، [LGU+·LS일렉트릭, AI 데이터센터 800V DC 공동 개발 나선다](https://www.mt.co.kr/tech/2026/07/22/2026072207035073681)
- 글로벌이코노믹، [HPE, 슈퍼컴퓨팅 개발환경 통합…소버린 AI 인프라 간소화](https://www.g-enews.com/view.php?ud=202607212059199803112616b072_1)
- 뉴스웍스، [[#클라우드 월드] 삼성SDS-퓨리오사AI 'NPUaaS' 출시·LG CNS 'AI 캠퍼스'...](https://www.newsworks.co.kr/news/articleView.html?idxno=847787)
- 지디넷코리아، ["SKT, AI팩토리에 가장 적극적인 통신사...풀스택AI·전국망 경쟁력"](https://zdnet.co.kr/view/?no=20260721191819)
- 약업신문، [BMS‧엔비디아, 생명공학 최강 AI 팩토리 구축](https://www.yakup.com/news/index.html?mode=view&cat=16&nid=330043)
- 글로벌이코노믹، [미국 데이터센터 전력 수요 급증… 호남 반도체 허브, 전력망·용수가 ...](https://www.g-enews.com/view.php?ud=202607220659395424fbbec65dfb_1)
- 디지털투데이، [풀사이드, 코딩 에이전트용 오픈웨이트 모델 '라구나 S 2.1' 공개](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685807)
- 이투데이، [키미 쇼크에 ‘AI 2강’ 험로…'특화 AI' 키우고, 경량화 모델로 차별화...](https://www.etoday.co.kr/news/view/2605803)
- 디지털투데이، [포티투마루, 예금보험공사 데이터 관리체계 고도화·생성형 AI 서비스 구...](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685817)
- 뉴스투데이، [밖에선 AI 인재 찾고 안에선 업무 혁신…NHN의 AX '승부수'](https://www.news2day.co.kr/article/20260721500191)
- 바이라인네트워크، [“4년 걸린 일을 3개월에”…아임웹이 안팎으로 AI 쓰는 법](https://byline.network/?p=9004111222612588)
- IT조선، [내년 지원 불투명한데…정부 '모두의 AI' 출시 서두르나](https://it.chosun.com/news/articleView.html?idxno=2023092166202)
- EBN، [이재용·최태원·이해진, 美서 젠슨 황 만난다…AI 공급망 동맹 재가동](https://www.ebn.co.kr/news/articleView.html?idxno=1717215)
- 디지털투데이، [시스코, 코드 취약점 탐지 특화 오픈웨이트 소형 모델 '안타레스' 공개](https://www.digitaltoday.co.kr/news/articleView.html?idxno=685800)
- 뉴스저널리즘، [AI가 바꾼 보안 공식…에스원 '현장 데이터'로 승부](https://www.ngetnews.com/news/articleView.html?idxno=551683)
