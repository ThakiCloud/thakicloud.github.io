---
title: "في الصباح نفسه، تحركت بطاقتا سعر في اتجاهين متعاكسين"
excerpt: "دفعت صدمة الذاكرة تكلفة امتلاك البنية التحتية للذكاء الاصطناعي إلى أعلى مستوى في تاريخها، بينما خفض نموذج كيمي K3 والنماذج الصينية مفتوحة الأوزان تكلفة استخدام الذكاء الاصطناعي إلى أدنى مستوى في تاريخها. وفي هذه الفجوة المتسعة بين بطاقتي السعر، تنتقل ساحة المعركة الحقيقية من النماذج إلى معدل الاستغلال."
seo_title: "تكلفة امتلاك الذكاء الاصطناعي ترتفع بينما تكلفة استخدامه تنهار: المقص المتسع وحرب معدل الاستغلال"
seo_description: "في يوليو 2026، رفعت صدمة الذاكرة تكلفة شراء الخوادم بنسبة 70%، بينما خفض كيمي K3 والنماذج الصينية مفتوحة الأوزان تكلفة استخدام الذكاء الاصطناعي حتى 1/50. يحلل هذا المقال لماذا يصبح معدل استغلال وحدات معالجة الرسوميات وتوجيه النماذج ساحة المعركة الجديدة بينما تتباعد تكلفة الامتلاك وتكلفة الاستخدام في اتجاهين متعاكسين."
date: 2026-07-19
last_modified_at: 2026-07-19
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
  - news
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/news/two-price-tags-moving-opposite-utilization-war/"
published: true
---

أثناء تصفح الأخبار هذا الصباح، لفت انتباهي أمر واحد. بطاقتا سعر تتحركان في اتجاهين متعاكسين تمامًا في التاريخ نفسه، موضوعتان جنبًا إلى جنب. من جهة، كانت تكلفة شراء المعدات اللازمة لتشغيل الذكاء الاصطناعي ترتفع إلى أعلى مستوى في تاريخها. ومن جهة أخرى، كانت تكلفة تشغيل الذكاء الاصطناعي مرة واحدة تنهار إلى أدنى مستوى في تاريخها. عادة، حين ترتفع تكلفة المدخلات ترتفع أسعار البيع أيضًا. لكن الآن، يتباعد سعر المواد الخام عن سعر المنتج النهائي، وكأنهما يديران ظهريهما لبعضهما البعض. هذا التباعد هو كل القصة التي أريد سردها اليوم.

## تكلفة الامتلاك ترتفع إلى أعلى مستوى في تاريخها

لنبدأ بالجانب المرتفع. تفيد سلسلة تقارير "تضخم حزمة الذكاء الاصطناعي" في ديجيتال ديلي بأن صدمة الذاكرة وصلت إلى ما هو أبعد من كبرى شركات الحوسبة السحابية، حتى غرف الخوادم الخاصة بالشركات الناشئة في مجال الذكاء الاصطناعي. ارتفعت تكلفة تركيب الخوادم الجديدة لدى شركة 42Maru، المتخصصة في الذكاء الاصطناعي للأسئلة والأجوبة، بنحو 70% مقارنة بالسابق. عرض سعر لقرص SSD سعة 4 تيرابايت كان 1.3 مليون وون قبل أسبوعين وصل هذا الأسبوع إلى 2.8 مليون وون، أي أكثر من الضعف. أخطرت سامسونج إلكترونيكس وإس كيه هاينيكس عملاءها الكبار مثل جوجل ومايكروسوفت برفع أسعار عقود ذاكرة DRAM للخوادم بنسبة 60 إلى 70%، وهما الآن لا تورّدان سوى 70% من الكميات المطلوبة. تقلصت مدة صلاحية عروض الأسعار من عدة أشهر إلى أسبوع أو أسبوعين، لذا تتحرك الشركات إما بحجز الكميات مسبقًا قبل ارتفاع الأسعار أكثر أو بتأجيل عمليات التركيب غير العاجلة.

بمجرد ارتفاع الأسعار، تحركت الشركات الأخف عبئًا أولًا. حولت خدمة تلخيص البحث لاينر (Liner) مزود الخدمة السحابية بالكامل، مستشهدة بتقلبات تكلفة السحابة التي هزّتها أسعار الذاكرة. كلما كانت الشركة تحمل غرفة خوادم خاصة بها أثقل، واجهت هذه الصدمة مباشرة، وكلما اعتمدت الشركة على بنية تحتية مستأجرة، تحركت بسرعة أكبر. هذه هي اللحظة التي تتحول فيها كلفة الامتلاك إلى جمود.

لا يقتصر الأمر على ارتفاع أسعار المعدات فقط. تنغلق أيضًا محافظ كبار اللاعبين الذين يمولون اللعبة بأكملها. تتوقع UBS أن ينخفض معدل نمو الإنفاق الرأسمالي لدى أربع كبريات شركات الحوسبة السحابية، بما فيها مايكروسوفت وأمازون، بشكل حاد من 76% في 2026 إلى 25% في 2027 ثم إلى 6% في 2028. في استطلاع بنك أوف أمريكا لمديري الصناديق في يوليو، اعتبر 82% من المستجيبين أشباه الموصلات أكثر تجارة مزدحمة في السوق حاليًا، وهي أعلى نسبة سجلها الاستطلاع على الإطلاق. أصبحت أزمة الطاقة والمخاطر التنظيمية واقعًا ملموسًا أيضًا، لدرجة أن ولاية نيويورك فرضت تجميدًا لمدة عام على بناء مراكز بيانات جديدة. انتهى عصر التوسع العشوائي، وتحوّل السؤال من "هل نبني" إلى "كم سنربح". لم يسبق أن كان قرار امتلاك البنية التحتية بهذا الثقل وهذه التكلفة.

## تكلفة الاستخدام تنهار إلى أدنى مستوى في تاريخها

الآن لننظر إلى بطاقة السعر الأخرى. أطلقت صحيفة كوريا إيكونوميك ديلي على هذا الوضع اسم "مفارقة انهيار أشباه الموصلات". قفز مؤشر فيلادلفيا لأشباه الموصلات 89% في الربع الثاني ثم تراجع 15% في يوليو، وارتفع صندوق مؤشرات متداولة للذاكرة أُدرج في أبريل بنسبة 166% خلال ثلاثة أشهر فقط قبل أن يتراجع أكثر من 20%. وبينما كانت سوق المواد الخام تتأرجح بهذا الشكل الحاد، كانت تكلفة استخدام الذكاء الاصطناعي فعليًا تخترق القاع بهدوء.

كان الزناد هو كيمي K3، النموذج مفتوح الأوزان الذي أطلقته شركة Moonshot AI الصينية هذا الأسبوع. يحمل النموذج 2.8 تريليون معامل ضمن بنية خليط من الخبراء، ويُفعّل جزءًا فقط من شبكاته الخبيرة البالغ عددها 896 لتوفير الحساب. يدعم نافذة سياق تصل إلى مليون رمز، وهو متوافق مع OpenAI SDK، ما يخفض عتبة الانتقال أمام المطورين الحاليين. اللافت هو السعر. تبلغ تكلفة معالجة مهمة واحدة 0.94 دولار، أي نحو نصف تكلفة أنثروبيك أوبس 4.8 البالغة 1.80 دولار. وينخفض السعر إلى 0.02 دولار لدى DeepSeek V4 Flash، وإلى 0.37 دولار لدى GLM 5.2.

لم يكن الأمر تفردًا لنموذج واحد، بل مالت الموجة بأكملها. وفقًا لنيوسيس، استحوذت النماذج الصينية مفتوحة الأوزان مثل Tencent وXiaomi وDeepSeek وMiniMax وZhipu AI على المراكز الخمسة الأولى في استخدام الرموز الأسبوعي على منصة OpenRouter الوسيطة للنماذج. حتى الأسبوع الأخير من يونيو، بلغت حصة النماذج الصينية 48%، متقدمة بفارق كبير على حصة الولايات المتحدة البالغة 20%، في انعكاس كامل للوضع قبل عام واحد، حين كانت الولايات المتحدة تتصدر بنسبة 74% مقابل 20% للصين. وأوضح رافي كريكوريان، كبير مسؤولي التقنية في موزيلا، أنه بحسب طبيعة العمل يمكن خفض التكلفة إلى 1/50 من تكلفة أفضل النماذج. تُباع واجهات برمجة تطبيقات نماذج مثل DeepSeek وQwen بأسعار أرخص بمقدار 10 إلى 150 مرة من أفضل النماذج الأمريكية. تتحول الشركات إلى نهج مزدوج، تعهد فيه بالمهام الروتينية إلى النماذج الرخيصة مفتوحة الأوزان وتحتفظ بالمهام الصعبة فقط لأفضل النماذج.

مع ذلك، لا يعني انخفاض السعر إمكانية استخدامه في أي مكان. خلف السعر الجذاب للنماذج ذات المنشأ الصيني يكمن ظل سيادة البيانات والمراجعة الأمنية، ما يجعل القطاعين العام والمالي مترددين في تبنيها بسهولة. عند إصدار الأوزان الكاملة لكيمي K3 في 27 يوليو، ستتمكن الشركات من تحميل النموذج وتشغيله مباشرة على بنيتها التحتية الخاصة. الجمع بين جاذبية السعر وأمان السيطرة يقود في النهاية إلى تشغيل النماذج مفتوحة الأوزان على العنقود الخاص بك. لهذا السبب لا تقتل النماذج الأرخص الطلب على الحلول المحلية، بل تؤججه.

## حين يتسع المقص، تتغير ساحة المعركة

حين نضع بطاقتي السعر فوق بعضهما، تتضح الصورة. إنه مقص، تكلفة امتلاك المعدات تتجه للأعلى، وتكلفة استخدام الذكاء الاصطناعي تتجه للأسفل. أريد أن أشير هنا إلى سوء فهم شائع، وهو الاستنتاج بأن النماذج أصبحت شائعة ورخيصة، وبالتالي لم تعد البنية التحتية مهمة. العكس تمامًا هو الصحيح. كلما أصبح المنتج النهائي أرخص، أصبحت نسبة تكلفة المعدات التي تنتجه هي التي تحدد الهامش الربحي بأكمله.

كلام المستثمر غافين بيكر، الذي نقلته كوريا إيكونوميك ديلي، يصيب هذه النقطة تمامًا. يرى أن انتشار النماذج منخفضة التكلفة هو، على العكس، "أقوى سيناريو صاعد للبنية التحتية للذكاء الاصطناعي". حين تنخفض تكلفة الرموز، يستخدم الناس رموزًا أكثر. لا يستخدمون أقل بما يتناسب مع انخفاض السعر، بل يستخدمون أكثر بكثير لأن السعر انخفض. المفارقة التي رصدها جيفونز في الفحم تتكرر الآن فوق وحدات معالجة الرسوميات. إذا كان الأمر كذلك، تنتقل ساحة المعركة من "من يملك النموذج الأفضل" إلى "من يستخرج أكبر قدر من الرموز من وحدات المعالجة التي يملكها بالفعل"، أي معدل الاستغلال.

فيما يلي رسم واحد يلخص كيف يؤدي اتساع بطاقتي السعر إلى تحويل ساحة المعركة.

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
<div class="d3-arch" data-arch-root id="ngoppositeutilizationwar-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 592, "height": 662, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 314, "y": 24, "w": 212, "h": 78, "title": ["Cost to OWN AI infra", "rising", "memory shock, +70% servers"]}, {"id": "C", "x": 200, "y": 180, "w": 191, "h": 46, "title": "Widening price scissors"}, {"id": "B", "x": 75, "y": 24, "w": 184, "h": 78, "title": ["Cost to USE AI falling", "Kimi K3, Chinese", "open-weight"]}, {"id": "D", "x": 204, "y": 304, "w": 184, "h": 62, "title": ["Battleground shifts to", "GPU utilization"]}, {"id": "E", "x": 411, "y": 444, "w": 149, "h": 62, "title": ["Model routing:", "cheap vs top-tier"]}, {"id": "F", "x": 235, "y": 444, "w": 121, "h": 62, "title": ["Scheduling:", "no idle cards"]}, {"id": "G", "x": 24, "y": 444, "w": 156, "h": 62, "title": ["Control and audit:", "policy gate, logs"]}, {"id": "H", "x": 197, "y": 584, "w": 198, "h": 46, "title": "Paxis agent-native cloud"}], "edges": [{"src": "A", "dst": "C", "kind": "data", "curve": [[420, 102], [420, 141], [420, 141], [342, 180]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[167, 102], [167, 141], [167, 141], [248, 180]]}, {"src": "C", "dst": "D", "kind": "data", "line": [296, 226, 296, 304]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[380, 366], [486, 405], [486, 405], [486, 444]]}, {"src": "D", "dst": "F", "kind": "data", "line": [296, 366, 296, 444]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[210, 366], [102, 405], [102, 405], [102, 444]]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[486, 506], [486, 545], [486, 545], [366, 584]]}, {"src": "F", "dst": "H", "kind": "data", "line": [296, 506, 296, 584]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[102, 506], [102, 545], [102, 545], [224, 584]]}]});
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
      const container = document.getElementById('ngoppositeutilizationwar-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ngoppositeutilizationwar-1';
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

يُظهر مقال "الذكاء الاصطناعي للجميع" في ديجيتال ديلي هذه المشكلة على المستوى الوطني. مع نشر الحكومة 512 وحدة معالجة رسوميات من طراز Nvidia B200 لروبوت دردشة وطني بالذكاء الاصطناعي، وقعت في معضلة حول تقسيم العمل بين مزودَين أو ثلاثة أم تركيزه لدى جهة واحدة. التقسيم يعني أن كل خدمة لن تتحمل ذروة حركة المرور، والتركيز يعني فقدان تنوع النظام البيئي. اللافت هو أن الحكومة تخطط لتعديل الطاقة الاستئجارية شهريًا بأثر رجعي، استنادًا إلى عدد المستخدمين النشطين شهريًا واستخدام الرموز. حيثما يكون عدد البطاقات محدودًا، تحسم القدرة على إعادة توزيع الموارد ديناميكيًا وفق الاستخدام من يفوز ومن يخسر. سواء كانت 512 بطاقة أو 50 ألف بطاقة، الجوهر واحد.

## إذن، ما الذي يجب أن تمتلكه

كلما اتسع المقص، يضيق التمايز المتبقي إلى ثلاثة أمور. التوجيه الذي يرسل كل مهمة تلقائيًا إلى النموذج المناسب من حيث السعر، والجدولة التي تملأ أحمال العمل من دون ترك بطاقات خاملة، والتحكم والتسجيل اللذان يتيحان تتبع كل عملية تنفيذ لاحقًا. هذا هو السبب الذي يدفعني لذكر Paxis، السحابة الأصلية للوكلاء من تاكي كلاود (ThakiCloud)، في هذا السياق تحديدًا. تعامل Paxis المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى، وتضمّن في صميم المنتج النهج المزدوج، الذي يوزع العمل بين النماذج الرخيصة مفتوحة الأوزان والنماذج المتقدمة، عبر CostRouter المسؤول عن اختيار النموذج لكل مهمة. الاستراتيجية المزدوجة التي تتبناها الشركات المذكورة أعلاه هي بالضبط حالة استخدام هذه الميزة.

تعمل الجدولة عبر Kueue فوق منصة Kubernetes سيادية محلية، ما يجعلها تتعامل مع نفس فئة المشكلة التي تواجهها حالة "الذكاء الاصطناعي للجميع" في إعادة التوزيع القائمة على الاستخدام. أما التحكم فتتولاه بوابات السياسات وسجلات التدقيق والتنفيذ في بيئة معزولة. هذه النقطة تتقاطع مع أخبار السياسات اليوم. يفرض قانون الذكاء الاصطناعي الأساسي المعدَّل، الذي يدخل حيز التنفيذ في 21 يوليو، بالفعل التزامًا بوسم الذكاء الاصطناعي التوليدي ومعايير إدارة للذكاء الاصطناعي عالي التأثير، ويمنح المشتريات العامة مزايا مثل تخفيف شروط العقود للمنتجات المعتمدة. وهذا يتماشى مع نصيحة هيئة البحوث التشريعية في الجمعية الوطنية بإعادة تعريف جوهر الذكاء الاصطناعي السيادي، ليس بحسب منشأ النموذج، بل بـ"القدرة على السيطرة السيادية". وقد أظهرت واقعة قطع وزارة التجارة الأمريكية الوصول الخارجي إلى نماذج أنثروبيك لثلاثة أيام في يونيو الماضي، ثم إعادته بعد ثلاثة أسابيع، مدى هشاشة الخدمة المبنية على واجهة برمجة تطبيقات تابعة لجهة أخرى. القدرة على تنفيذ العمليات داخل عنقودك الخاص، وتصفيتها عبر السياسات، وإثباتها بالسجلات هي امتثال تنظيمي وسيطرة فعلية في آن واحد.

خلاصة القول، الامتلاك يزداد كلفة، والنماذج تزداد شيوعًا. وما يخلق القيمة بين الاثنين ليس الحصول على نموذج جيد، بل كثافة التشغيل، أي توجيه النماذج الشائعة بتكلفة منخفضة، وجدولتها من دون فجوات، والتحكم بها بطريقة قابلة للتدقيق. بطاقتا السعر اللتان تحركتا في اتجاهين متعاكسين هذا الصباح كانتا، في النهاية، تطرحان السؤال نفسه: إلى أي مدى تُدير جيدًا ما تملكه بالفعل؟

## المصادر

كُتب هذا المقال استنادًا إلى تجميع الأخبار التالية.

- نيوز1، ["اعتماد بعد تجربة K-NPU"... فيريوسا AI تسرّع "استراتيجية إثبات الجدوى الكاملة" في أوروبا](https://www.news1.kr/industry/sb-founded/6226804)
- ديجيتال ديلي، [[تضخم حزمة الذكاء الاصطناعي ⑤] صدمة الذاكرة تصل حتى شركات الذكاء الاصطناعي... "تكلفة شراء الخوادم ترتفع 70%"](https://www.ddaily.co.kr/page/view/2026071617390023984)
- كوريا إيكونوميك ديلي، ["كلما رخُص، ازداد الاستخدام"... مفارقة انهيار أشباه الموصلات التي هزّها الذكاء الاصطناعي "بأفضل قيمة مقابل السعر"](https://www.hankyung.com/article/202607192100i)
- ويكي تري، [إتشد تُقيَّم بـ20 مليار دولار قبل شحن أي رقاقة... جين ستريت وسيكويا يراهنان في آن واحد](https://www.wikitree.co.kr/articles/1147129)
- غلوبال إيكونوميك، [استثمارات الذكاء الاصطناعي تتحول من "التوسع" إلى "الانتقاء"... تباطؤ إنفاق شركات الحوسبة السحابية الرأسمالي يرتد على أشباه الموصلات](https://www.g-enews.com/view.php?ud=2026071906435432182bd56fbc3c_1)
- ديجيتال ديلي، [[الذكاء الاصطناعي للجميع ④ الأخيرة] معضلة توزيع وحدات معالجة الرسوميات... "انتشار متعدد الشركات مقابل التركيز والاختيار"](https://www.ddaily.co.kr/page/view/2026071613325666245)
- زد دي نت كوريا، [سبيس إكس تتفاوض مع البنتاغون الأمريكي على صفقة توريد حوسبة ذكاء اصطناعي بمليارات الدولارات](https://zdnet.co.kr/view/?no=20260719071015)
- زد دي نت كوريا، [مونشوت الصينية تكشف عن نموذج الذكاء الاصطناعي الجديد "كيمي K3"... تطارد OpenAI وأنثروبيك عن قرب](https://zdnet.co.kr/view/?no=20260718173700)
- زد دي نت كوريا، [ZTE تكشف عن هاتف وكيل الذكاء الاصطناعي "NaviX Ultra"](https://zdnet.co.kr/view/?no=20260719003653)
- آي نيوز24، ["ما تقييمات السكن الفعلي لهذه الشقة؟"... تبويب البحث الحواري بالذكاء الاصطناعي من نايفر يطور المعلومات المخصصة](http://www.inews24.com/view/1986464)
- ذا بيز، [[قضية البنك الأسبوعية] "الذكاء الاصطناعي هو المستقبل"... انتشار "AX" على نطاق واسع في القطاع المصرفي](http://www.the-biz.co.kr/news/articleView.html?idxno=724547)
- نيوز1، ["نمنحكم خصمًا على جيميناي"... شركات الاتصالات الكورية الثلاث تتنافس على جذب المستخدمين في عصر الذكاء الاصطناعي كسلعة أساسية](https://www.news1.kr/it-science/cc-newmedia/6230746)
- يونهاب نيوز، [[قانون الذكاء الاصطناعي الأساسي] الجزء 1: القانون المعدَّل يدخل حيز التنفيذ في 21... التشريع الكوري للذكاء الاصطناعي جاهز](https://www.yna.co.kr/view/AKR20260717029400017?input=1195m)
- نيوسيس، [بعد أشباه الموصلات، يصبح الذكاء الاصطناعي أيضًا أصلًا استراتيجيًا... هيئة البحوث التشريعية تنصح بـ"إعادة صياغة استراتيجية الذكاء الاصطناعي السيادي"](https://www.newsis.com/view/NISX20260714_0003709278)
- نيوسيس، [الصين تكتسح المراكز 1 إلى 5 في الاستخدام الأسبوعي لمنصات الذكاء الاصطناعي... تهز الذكاء الاصطناعي الأمريكي المرتفع الثمن](https://www.newsis.com/view/NISX20260719_0003713825)
- زد دي نت كوريا، [داتابريكس الأمريكية تجمع تمويلًا جديدًا... تصل قيمتها إلى 188 مليار دولار](https://zdnet.co.kr/view/?no=20260718234826)
- زد دي نت كوريا، ["تطوير أمن الذكاء الاصطناعي التوليدي"... مونيتورلاب ترتقي بحلول أمن الذكاء الاصطناعي](https://zdnet.co.kr/view/?no=20260718202637)
