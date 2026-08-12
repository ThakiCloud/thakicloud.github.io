---
title: "من حرب الذكاء إلى حرب القيمة: الشركات التي تغادر واجهات النماذج المتقدمة واقتصاديات الترحيل"
excerpt: "بدأت مايكروسوفت بتوجيه طلبات الذكاء الاصطناعي الجماعية من Excel وOutlook إلى نماذجها الخاصة، وأصبحت النماذج الصينية المفتوحة تعالج ما يقارب نصف استخدام الذكاء الاصطناعي لدى بعض الشركات الأمريكية، كما تبخر أكثر من تريليون دولار من القيمة السوقية خلال أيام معدودة. الافتراض القائل بأن الشركات ستدفع إلى الأبد أسعار النماذج المتقدمة المرتفعة بدأ ينهار. يستعرض هذا المقال هذه الإشارات، ويضع دليلاً عملياً لترحيل الأحمال الضخمة إلى النماذج المفتوحة، ثم يوضح كيف تندمج منصتا ai-platform وPaxis من ThakiCloud كطبقة تحكم تُنفذ هذا الترحيل."
tags:
  - cost-optimization
  - model-routing
  - open-weights
  - self-hosting
  - vllm
  - paxis
date: 2026-07-10
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/ai-cost-war-migration-frontier-to-open/"
categories:
  - llmops
---

![رسم تخيلي مجرد يعبر عن الانتقال من واجهات النماذج المتقدمة إلى النماذج المفتوحة]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-hero.webp' | relative_url }})

في الأسابيع الأخيرة، تحول حديث صناعة الذكاء الاصطناعي من سؤال "من الأذكى" إلى سؤال "من الأرخص". وجاء المشهد الأكثر دلالة من مايكروسوفت. فالشركة ذاتها التي وضعت OpenAI على المسار الذي تسير عليه اليوم، بدأت بتوجيه عشرات آلاف الطلبات الأسبوعية للذكاء الاصطناعي داخل Excel وOutlook إلى نماذجها الخاصة بدلاً من نماذج OpenAI وAnthropic. ولم يُخفِ مصطفى سليمان، مسؤول الذكاء الاصطناعي في مايكروسوفت، هذا التوجه، إذ قال: "Anthropic باهظة الثمن للغاية. هدفنا هو خفض هذه التكلفة والقضاء عليها في نهاية المطاف."

هذا المقال موجّه لقادة الهندسة وفرق الذكاء الاصطناعي وصنّاع القرار المسؤولين عن تكلفة الاستدلال في خدماتهم. سنوضح لماذا حرب التكاليف الدائرة اليوم ليست ضجيجاً عابراً بل تحولاً بنيوياً، ونضع دليلاً عملياً لترحيل إنفاق واجهات النماذج المتقدمة نحو النماذج المفتوحة والاستضافة الذاتية، ثم نختم بموقع ThakiCloud كطبقة تحكم تُنفذ هذا الترحيل فعلياً.

## ما الذي تغيّر

قرار شركة واحدة لا يصنع اتجاهاً عاماً. لكن إشارات متعددة تشير إلى الاتجاه نفسه تراكمت خلال أسابيع قليلة.

أولاً، كان تحرك مايكروسوفت دقيقاً. فالمهام الأصعب والأندر ما زالت تُرسل إلى النماذج المتقدمة، بينما استعادت الشركة إلى نماذجها الخاصة فقط المهام المتكررة عالية الحجم، مثل الرد على البريد الإلكتروني وتلخيص المحادثات وصيغ الجداول البسيطة. وأهمية هذا الأمر تكمن في أن تلك المهام المتكررة الضخمة هي بالضبط حيث يتدفق المال فعلياً ({% raw %}[تقرير SiliconANGLE](https://siliconangle.com/2026/07/07/microsoft-reportedly-ditching-openais-anthropics-ai-models-favor-cut-costs/){% endraw %}).

ثانياً، تتجه الشركات الأمريكية نحو النماذج الصينية المفتوحة هرباً من الأسعار. وبحسب تقرير CNBC، عالجت النماذج الصينية أكثر من 30 بالمئة من استخدام الذكاء الاصطناعي لدى الشركات الأمريكية على إحدى منصات التوجيه الرئيسية، وبلغت ذروتها عند 46 بالمئة، مقارنة بمتوسط 11 بالمئة قبل عام واحد فقط. وتكاليفها أقل بنسبة تتراوح بين 60 و90 بالمئة، وفي بعض اختبارات الأداء الخاصة بالوكلاء ضاقت الفجوة مع أفضل النماذج الأمريكية إلى نقطة واحدة فقط ({% raw %}[تقرير CNBC](https://www.cnbc.com/2026/07/07/chinese-ai-models-costs-us-openai-anthropic.html){% endraw %}).

ثالثاً، ظهرت إشارة إلى فائض في العرض. فقد أعلنت Meta عزمها إنشاء عمل سحابي لبيع قدرة الحوسبة "الفائضة" الخاصة بالذكاء الاصطناعي، وهو ما يعني عملياً تحويل الاعتراف بالإفراط في البناء إلى نموذج عمل ({% raw %}[تقرير CNBC](https://www.cnbc.com/2026/07/01/meta-stock-cloud-ai-compute.html){% endraw %}).

رابعاً، تفاعلت الأسواق. ففي أواخر يونيو، تبخر ما يزيد على تريليون دولار من القيمة السوقية لأسهم أشباه الموصلات والشركات المرتبطة بالذكاء الاصطناعي خلال أيام معدودة، وبدأ وول ستريت يتساءل عمّا إذا كان هذا الإنفاق الهائل قابلاً للاسترداد فعلاً (نحو 1.3 تريليون دولار وفق تجميع رويترز، غير مؤكد ولغرض المرجعية فقط).

القاسم المشترك بين هذه الإشارات ليس تراجع أداء النماذج المتقدمة، فأداؤها في الواقع يستمر في التحسن. المشكلة أن حتى أكبر العملاء لم يعودوا يقبلون الافتراض القائل باستخدام أفضل نموذج لكل مهمة ودفع أعلى سعر مقابل ذلك.

كما أن الأسعار نفسها تنخفض بسرعة. فنموذج GPT-5.6 Sol الذي أطلقته OpenAI مؤخراً يُسعَّر بنحو 5 دولارات لكل مليون رمز إدخال و30 دولاراً لكل مليون رمز إخراج، وهو انخفاض حاد في تكلفة الرمز مقارنة بالجيل السابق ({% raw %}[تقرير CNBC](https://www.cnbc.com/2026/07/08/openai-expanding-gpt-5point6-ai-model-release-ending-government-limits.html){% endraw %}). وهذا يعني أن مختبرات النماذج المتقدمة نفسها دخلت في حرب أسعار فيما بينها. لم تعد الجبهة الأمامية حرب ذكاء، بل تحولت إلى حرب قيمة.

## لماذا الآن

اندلعت حرب التكاليف الآن بسبب طبيعة توزّع الأحمال العملية.

عند تفكيك ما يعالجه الوكلاء يومياً، يتضح انقسام واضح في الطبيعة. من جهة، هناك استدلال صعب فعلياً: قرارات تصميم غامضة، أخطاء برمجية دقيقة، وتفكيك مشكلات لم يسبق مواجهتها. ومن جهة أخرى، هناك مهام نمطية ضخمة الحجم: التصنيف والتوجيه والتلخيص وفحص المواصفات والردود ذات الصيغة الثابتة. ومن حيث العدد، تهيمن هذه الفئة الأخيرة بشكل ساحق.

كان الافتراض المالي لمختبرات النماذج المتقدمة بسيطاً: أن الشركات حول العالم ستستمر في معالجة مليارات هذه الطلبات الصغيرة إلى الأبد باستخدام نماذج باهظة الثمن. وكان ذلك النهر اللامتناهي من الرموز هو الأساس الذي استندت إليه التقييمات المرتفعة لتلك المختبرات.

لكن جودة المهام النمطية تُحدَّدها الضوابط الحاكمة أكثر مما يُحدَّدها ذكاء النموذج. تذبذب صيغة الإخراج لا يعني نقص قدرة النموذج، بل يعني أن الصيغة طُلبت نثراً بدلاً من فرضها. فحين تفرض الشيفرة البرمجية الحد الأقصى للطول ومجموعة القيم المسموحة ومواصفات العرض ومعايير الاجتياز، تخرج تلك المهمة بثبات حتى من نماذج مفتوحة أرخص بكثير. وفي اللحظة التي يصبح فيها "الجيد الكافي" متاحاً بجزء يسير من السعر، تصبح استعادة نهر المهام الضخمة قراراً منطقياً. وهذا بالضبط ما فعلته مايكروسوفت.

## من المتقدم إلى المفتوح: دليل الترحيل العملي

فكيف يُنقل هذا النهر عملياً. تغيير النموذج بشكل ارتجالي أمر محفوف بالمخاطر. الترحيل الموثوق يمر بخمس خطوات.

أولاً، تصنيف الحمل. تُقسَّم كل طلبية على محورين: الصعوبة والحساسية. تبقى المهام الصعبة أو الحساسة على النماذج المتقدمة، بينما تُوضَع علامة على المهام النمطية عالية الحجم فقط باعتبارها هدفاً للترحيل.

ثانياً، تقييم البدائل المرشحة. لكل مهمة مُعلَّمة للترحيل، تُقيَّم نماذج مفتوحة مرشحة باستخدام بيانات فعلية. والعنصر الجوهري هنا هو نسبة الاجتياز التي تحسبها الشيفرة البرمجية، لا الانطباع البشري. تُختبر المخرجات الفعلية مقابل فحوصات المواصفات، ويُستبعد أي مرشح لا يبلغ الحد الأدنى المطلوب.

ثالثاً، بناء التوجيه. تُعرَّف في مكان واحد القواعد التي تحدد أي نموذج يعالج أي نوع من المهام. هذه القواعد يجب أن تكون مصدر الحقيقة الوحيد حتى يسهل لاحقاً استبدال النموذج أو التراجع عنه.

رابعاً، الاستضافة الذاتية للنموذج المفتوح. يُنشر النموذج المفتوح المختار على البنية التحتية الخاصة بالشركة باستخدام محرك تقديم مثل vLLM. في هذه الخطوة تتحقق مزايا النشر المحلي والسيادة على البيانات وانخفاض التكلفة لكل وحدة.

أخيراً، التحقق والتراجع. بعد الترحيل، تستمر عملية قياس الجودة، وإذا تراجعت نسبة الاجتياز، تُعاد تلك المهمة تحديداً إلى النماذج المتقدمة. الترحيل بلا مسار للتراجع ليس ترحيلاً بل مقامرة.

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
<div class="d3-arch" data-arch-root id="rmigrationfrontiertoopen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 568, "height": 836, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 152, "y": 24, "w": 120, "h": 46, "title": "الحمل الوارد"}, {"id": "B", "x": 125, "y": 148, "w": 174, "h": 68, "title": ["بوابة التصنيف", "الصعوبة · الحساسية"]}, {"id": "C", "x": 366, "y": 478, "w": 170, "h": 62, "title": ["واجهة نموذج متقدم", "Claude · GPT-5.6 Sol"]}, {"id": "D", "x": 120, "y": 308, "w": 184, "h": 78, "title": ["نماذج مفتوحة مرشحة", "مختارة عبر نسبة اجتياز", "التقييم"]}, {"id": "E", "x": 113, "y": 478, "w": 198, "h": 62, "title": ["تقديم ذاتي الاستضافة", "vLLM · Metis · Kueue GPU"]}, {"id": "F", "x": 113, "y": 618, "w": 198, "h": 62, "title": ["بوابة سياسات + سجل تدقيق", "طبقة تحكم Paxis"]}, {"id": "G", "x": 152, "y": 758, "w": 120, "h": 46, "title": "النتيجة"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [212, 70, 212, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "صعب أو حساس", "curve": [[299, 211], [451, 262], [451, 432], [451, 478]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "مهام نمطية ضخمة", "line": [212, 216, 212, 308], "lx": 212, "ly": 258}, {"src": "D", "dst": "E", "kind": "data", "line": [212, 386, 212, 478]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[451, 540], [451, 579], [451, 579], [311, 620]]}, {"src": "E", "dst": "F", "kind": "data", "line": [212, 540, 212, 618]}, {"src": "F", "dst": "G", "kind": "data", "line": [212, 680, 212, 758]}, {"src": "F", "dst": "B", "kind": "event", "label": "رصد تراجع الجودة", "curve": [[151, 618], [75, 509], [75, 347], [154, 216]], "off": "50%"}]});
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
      const container = document.getElementById('rmigrationfrontiertoopen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rmigrationfrontiertoopen-1';
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

شارك أحد المطورين على منصة X أن هذا النهج خفّض إنفاقه الشهري على واجهات البرمجة من 60 ألف دولار إلى 12 ألف دولار عبر النماذج المفتوحة، أي بنسبة تقارب 80 بالمئة. ولم يتسنَّ التحقق من المنشور الأصلي بشكل مستقل لأن الوصول إليه كان مقيداً، لذا يُعامَل الرقم باعتباره غير مؤكد ولغرض المرجعية فقط. غير أن حجم الوفورات نفسه يتسق مع البيانات الموثقة: التكلفة الأقل بنسبة 60 إلى 90 بالمئة للنماذج الصينية المفتوحة، وحرب الأسعار الدائرة بين مختبرات النماذج المتقدمة نفسها، تشير جميعها إلى الاتجاه ذاته.

## دلالات الأمر على منتجات ThakiCloud

هذا الدليل واضح من الناحية المفاهيمية، لكن تنفيذه فعلياً يتطلب أمرين: بنية تحتية تقدّم النماذج المفتوحة بتكلفة منخفضة، وطبقة تحكم تختار النموذج المناسب لكل مهمة مع ضمان الأمان عبر السياسات والتدقيق. توفر ThakiCloud هذين المحورين معاً من خلال منتجين.

### ai-platform: بنية تحتية منخفضة التكلفة للتقديم

ai-platform هي بنية تحتية لتقديم أنظمة الذكاء الاصطناعي والتعلم الآلي مبنية على Kubernetes. تُجدوِل وحدات معالجة الرسوميات عبر Kueue، وتُقدّم النماذج المفتوحة عبر vLLM، وتدعم العزل متعدد المستأجرين والنشر المحلي. الخطوة الرابعة من دليل الترحيل، أي نشر النموذج المفتوح المختار على البنية التحتية الخاصة لخفض التكلفة لكل وحدة، تحدث في هذه الطبقة تحديداً. وبالنسبة للعملاء الذين لا يمكنهم إرسال بياناتهم خارج نطاقهم، مثل الجهات الحكومية أو الصناعات الخاضعة للتنظيم، يصبح النشر السيادي عاملاً حاسماً، وهو متطلب لا تستطيع واجهات النماذج المتقدمة تلبيته من الأساس.

### Paxis: السحابة الأصيلة للوكلاء التي تُنفذ الترحيل

Paxis هي طبقة التحكم الأصيلة للوكلاء التي تعمل فوق ai-platform. فكما تتعامل السحابة التقليدية مع الأجهزة الافتراضية وقواعد البيانات كموارد من الدرجة الأولى، تتعامل Paxis مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. ومن منظور دليل الترحيل، يُعد توجيه النموذج الجزء الأهم. تستخدم Paxis ملف `models.yaml` كمصدر حقيقة وحيد لتوجيه Claude وOpenAI وOllama وKimi وMiniMax، بالإضافة إلى تقديم vLLM الخاص بـ ai-platform (المسمى Metis)، جميعها من مكان واحد. وهذا يقابل تماماً الخطوتين الثالثة والخامسة من الدليل المذكور أعلاه: تحديد النموذج لكل نوع مهمة، وإعادة مهمة بعينها إلى النموذج المتقدم لحظة تراجع الجودة، وهو قرار يُتخذ في هذه الطبقة.

إضافة إلى ذلك، توفر Paxis طبقة مهارات تختار من بين أكثر من 960 مهارة باستخدام خوارزمية BM25، وتنفيذاً معزولاً داخل صندوق رملي، ومحرك معرفة قائماً على الويكي، وتنسيقاً متعدد الوكلاء عبر رسم بياني موجه (DAG)، وموصلات MCP مع إعادة اتصال تلقائية عبر OAuth. ويمر كل إجراء يقوم به الوكيل عبر بوابة سياسات وسجل تدقيق. بمعنى آخر، يمكن التحول إلى نماذج أرخص مع الاحتفاظ بالقدرة على تتبع ما عولج بأي نموذج بدقة.

يمكن تلخيص العلاقة بين المنتجين في جملة واحدة: التقديم منخفض التكلفة (ai-platform) هو ما يصنع اقتصاديات الوكيل (Paxis). فبدون بنية تحتية قادرة على تشغيل النماذج المفتوحة بتكلفة منخفضة، تبقى قواعد التوجيه مجرد خطة على الورق، وبدون توجيه وسياسات، يتحول التقديم الرخيص إلى مخاطرة لا يمكن التحكم بها. تحويل الترحيل إلى عمل حقيقي يتطلب المحورين معاً في آنٍ واحد. وتجدر الإشارة إلى أن Paxis ما زالت في مرحلة إثبات المفهوم، وقد تتغير واجهاتها ومخططاتها بسرعة.

## الحدود والحجج المضادة

إنهاء هذا العرض بتفاؤل مطلق لن يكون أمانة. الحجج المضادة واضحة.

أولاً، فجوات الجودة ما زالت قائمة. المجال الذي ضيّقت فيه النماذج المفتوحة الفارق هو المهام النمطية وبعض اختبارات الأداء الخاصة بالوكلاء. أما في تفكيك مشكلات لم تُشاهَد من قبل أو الاستدلال الدقيق عبر سياق طويل، فما زالت النماذج المتقدمة متقدمة. محاولة نقل كل شيء إلى النماذج المفتوحة تعني إعادة دفع ما وُفّر في المهام الضخمة على شكل تكاليف فشل في المهام الصعبة. جوهر الترحيل ليس الاستبدال الشامل بل التصنيف الدقيق.

ثانياً، الاستضافة الذاتية ليست مجانية. استدعاء واجهة برمجية ينقل العبء التشغيلي إلى المختبر، بينما الاستضافة الذاتية تعني تحمّل توفير وحدات معالجة الرسوميات وتحسين التقديم والاستجابة للأعطال بشكل مباشر. وبعد احتساب النفقات الرأسمالية الأولية والقوى العاملة التشغيلية، قد تكون استدعاءات الواجهة البرمجية في الواقع أرخص عند حجوم الحركة الصغيرة. نقطة التعادل تعتمد على حجم الحركة ومعدل الاستغلال.

ثالثاً، لا ينبغي التسليم بأرقام الاختبارات المتداولة كما هي. أثناء إعداد هذا المقال، لم يتسنَّ تتبّع بعض جداول ومقاييس الاختبارات إلى مصدر أصلي موثّق، فاستُبعدت من متن المقال. ينبغي أن تُبنى مقارنة النماذج فقط على نتائج قِيست مباشرة على الحمل الخاص بالشركة. اختبارات الآخرين ليست سوى نقطة انطلاق لا أكثر.

رابعاً، التوجيه نفسه يضيف تعقيداً. نظام يتنقّل بين نماذج متعددة أصعب في التشخيص والمراقبة من نظام أحادي النموذج. وهذا بالضبط سبب كون بوابات السياسات وسجلات التدقيق ليست اختيارية بل ضرورية.

ومع ذلك، فإن الاتجاه واضح. فحتى مايكروسوفت ترفض اليوم دفع أسعار النماذج المتقدمة مقابل كل مهمة، والسؤال الحقيقي هو من سيستمر في دفع ذلك السعر. القدرة على ترحيل الأحمال الضخمة بدقة إلى النماذج المفتوحة، والتحكم في ذلك الترحيل بأمان، ستكون كفاءة جوهرية في تشغيل الذكاء الاصطناعي خلال السنوات المقبلة. وتحتل ThakiCloud موقعاً يمكّنها من تقديم هذا الترحيل عبر البنية التحتية وطبقة التحكم معاً.

## المصادر

- {% raw %}[Microsoft reportedly ditching OpenAI's, Anthropic's AI models to cut costs (SiliconANGLE)](https://siliconangle.com/2026/07/07/microsoft-reportedly-ditching-openais-anthropics-ai-models-favor-cut-costs/){% endraw %}
- {% raw %}[Chinese AI models gain ground with US companies on cost (CNBC)](https://www.cnbc.com/2026/07/07/chinese-ai-models-costs-us-openai-anthropic.html){% endraw %}
- {% raw %}[Meta plans cloud business to sell AI compute (CNBC)](https://www.cnbc.com/2026/07/01/meta-stock-cloud-ai-compute.html){% endraw %}
- {% raw %}[OpenAI expands GPT-5.6 Sol access and pricing (CNBC)](https://www.cnbc.com/2026/07/08/openai-expanding-gpt-5point6-ai-model-release-ending-government-limits.html){% endraw %}
