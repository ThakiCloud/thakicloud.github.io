---
title: "هل ماتت عملية الضبط الدقيق فعلا؟ استراتيجية البقاء لعام 2026 عبر إشارات موثّقة من شهر يونيو"
excerpt: "كلما تحسّنت النماذج اللغوية الكبيرة ومهارات الوكلاء، ينتشر في الصناعة شعور بأن fine-tuning (الضبط الدقيق) لم يعد ضروريا. بل إن OpenAI بصدد إيقاف واجهة برمجة الضبط الدقيق ذاتية الخدمة فعليا. لكن في الشهر نفسه، تدفقت إشارات معاكسة تماما: توقف نماذج طليعية لمدة 19 يوما، ورخصة أوزان مفتوحة مصممة على أساس الضبط الدقيق، وانتصار عملي لعامل ضبط دقيق أرخص بـ11 مرة من النموذج الطليعي. بالاعتماد فقط على مصادر نُشرت بين 5 يونيو و5 يوليو 2026، نقدّم هنا تحليلا متقاطعا لما يموت فعلا وما يبقى حيا."
seo_title: "استراتيجية بقاء الضبط الدقيق 2026: النماذج المتخصصة في عصر مهارات LLM - Thaki Cloud"
seo_description: "تحليل مبني على بيانات موثّقة من يونيو 2026 يغطي إغلاق واجهة الضبط الدقيق في OpenAI، وتعطل Anthropic بسبب ضوابط التصدير، وNVIDIA Nemotron 3، وحالة Harvey الهجينة، لاستخلاص شروط بقاء الضبط الدقيق والنماذج الصغيرة، واستراتيجية ملكية النماذج في عصر الذكاء الاصطناعي السيادي."
date: 2026-07-05
last_modified_at: 2026-07-05
lang: ar
tags:
  - fine-tuning
  - slm
  - sovereign-ai
  - grpo
  - distillation
  - agent-skills
  - llmops
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "flask"
canonical_url: "https://thakicloud.com/tech-blog/ar/research/finetuning-survival-strategy-2026/"
categories:
  - research
  - llmops
header:
  teaser: /assets/images/finetuning-survival-strategy-2026-hero.webp
  overlay_image: /assets/images/finetuning-survival-strategy-2026-hero.webp
  overlay_filter: 0.5
published: false
---

![صورة توضيحية لاستراتيجية بقاء الضبط الدقيق]({{ '/assets/images/finetuning-survival-strategy-2026-hero.webp' | relative_url }})

## مدخل: "ألا يكفي الآن أن نستغني عن الضبط الدقيق؟"

كل من يبني منصة ذكاء اصطناعي أو يبيعها اليوم لا بد أنه سمع هذا السؤال مرة على الأقل. بما أن النماذج الطليعية أصبحت بهذا القدر من الجودة، وبما أنه يمكن حقن المعرفة الخاصة بالمجال عبر المهارات (skills) وسقالات الوكلاء (agentic scaffolding)، فهل يستحق الأمر إنفاق المال والوقت لتدريب نموذج مستقل؟ طرحنا على أنفسنا السؤال ذاته. لذلك تحققنا منه بالاعتماد حصرا على مصادر نُشرت خلال شهر واحد بالضبط، من 5 يونيو إلى 5 يوليو 2026.

المنهجية بسيطة. قسّمنا البحث إلى أربعة محاور: أدلة انتفاء الحاجة إلى الضبط الدقيق، أدلة استمرار بقائه، تحركات السوق والموردين، ونقاشات الممارسين الميدانيين. ثم أعدنا التحقق من ستة ادعاءات محورية تؤثر في اتجاه القرار عبر تدقيق تفنيدي (adversarial) مستقل. من أصل ستة، تأكدت أربعة ادعاءات بالكامل وتأكد ادعاءان جزئيا، ولم يُفنَّد أي منها. هذا المقال مبني حصرا على الحقائق التي اجتازت هذا التحقق.

الخلاصة المسبقة هي التالية: منتج الضبط الدقيق يحتضر بالفعل، لكن الذي يحتضر هو قطاع محدد هو واجهة SFT ذاتية الخدمة، بينما تُعاد صياغة التقنية ذاتها ضمن منتج مختلف تماما هو ملكية النموذج واقتصاديات عمال الوكلاء (agent workers)، بل تزداد قيمتها العلاوية في هذا الاتجاه.

## ما الذي يموت فعلا

الحدث الأكثر دلالة هو قرار OpenAI. أعلنت الشركة في 7 مايو 2026 حظر إنشاء مهام ضبط دقيق جديدة للمؤسسات الجديدة، وابتداء من 2 يوليو انتقلت إلى مرحلة منع وصول المؤسسات غير النشطة لأكثر من 60 يوما، وفي 6 يناير 2027 ستُنهي بالكامل إمكانية إنشاء مهام ضبط دقيق جديدة حتى للعملاء النشطين الحاليين. يبقى الاستدلال (inference) على النماذج المضبوطة دقيقا سابقا متاحا إلى أن يُلغى النموذج الأساسي، لكن مسار تشغيل تدريب جديد يُغلق.

اللافت هو البند الاستثنائي. الضبط الدقيق القائم على التعلم المعزز، أي RFT، يُفصل في مسار منفصل ويستمر رغم هذا الإغلاق. أوقفت OpenAI الضبط الدقيق المُوجَّه (SFT) بينما أبقت على التخصيص عالي القيمة الذي يمتلك مكافأة قابلة للتحقق. أما Anthropic فلم تفتح أصلا واجهة ضبط دقيق ذاتية الخدمة في واجهتها العامة، وتدفع باتجاه Agent Skills كمسار قياسي يحمّل المعرفة الخاصة بالمجال ديناميكيا من بنية مجلدات. وهكذا فإن أكبر موردَي نماذج يشيران إلى الاتجاه ذاته.

إشارات الأسعار تحمل الرسالة نفسها. منافسة الأسعار على الضبط الدقيق بتقنية LoRA بين Together AI وFireworks AI تعني أن هذا القطاع أصبح سلعة أساسية (commodity) وتقلّصت هوامشه. أصبح تشغيل الضبط الدقيق المُوجَّه بخفة وذاتيا أمرا سهلا تقنيا، وبالتالي فقد جاذبيته كمشروع تجاري.

## لكن لا يوجد دليل على أن المهارات حل شامل أيضا

على عكس الشعور السائد، الأدلة الأكاديمية على أن المهارات تحلّ محل الضبط الدقيق بشكل عام لا تزال ضعيفة. أظهرت دراسة SkillJuror، المقدَّمة ضمن هذه النافذة الزمنية، أن تقديم المهارات بصيغة مُهيكَلة يرفع معدل اجتياز التحقق بمقدار 4.1 نقطة مئوية مقارنة بالصيغة المسطّحة. الأثر حقيقي لكنه ليس كبيرا. أما الدراسة الخلفية الأسبق قليلا، SkillsBench، فتحمل نتيجة أكثر إثارة للاهتمام: المهارات المُنسَّقة (curated) بعناية ترفع معدل الاجتياز بمعدل 16.2 نقطة مئوية في المتوسط، لكن التباين بين المجالات متطرف، إذ يتراوح بين سلبي وحتى +51.9 نقطة مئوية، وفي 16 من أصل 84 مهمة تراجع الأداء فعليا. والأهم أن المهارات التي كتبها النموذج بنفسه لم تُحدث أثرا إيجابيا في المتوسط.

بمعنى آخر، فرضية "المهارات تكفي" فرضية مشروطة تصح فقط عند تطبيق مهارات نسّقها إنسان بعناية على المجال المناسب. تكلفة تنسيق المهارات ليست مجانية، ولا يوجد ما يضمن أنها أرخص دائما من الضبط الدقيق. وللإشارة، لم نجد ضمن هذه النافذة الزمنية أي معيار قياس (benchmark) يقارن مباشرة نموذجا مضبوطا دقيقا مقابل نموذج طليعي مزوَّد بمهارات على نفس مجموعة المهام. هذه الفجوة تبقى واجبا معلّقا على الطرفين.

## إشارات معاكسة تماما خلال شهر يونيو

في الشهر نفسه، تدفقت أيضا إشارات قوية في اتجاه الضبط الدقيق وملكية النموذج. جميعها أحداث تم التحقق منها عبر مصادر مستقلة.

أولا، تحوّلت مخاطر الاعتماد الجيوسياسي على واجهات النماذج الطليعية إلى حدث واقعي مُقاس. في 12 يونيو 2026، وبناء على توجيه من ضوابط التصدير الأمريكية، عطّلت Anthropic نموذجَي Fable 5 وMythos 5 على مستوى العالم بأكمله. تعذّر تطبيق فلترة الجنسية في الزمن الحقيقي، فتأثر عمليا جميع المستخدمين وليس فقط العملاء خارج الولايات المتحدة، واستغرق رفع التعطيل 19 يوما. أي شركة وضعت أعمالها الجوهرية على واجهة نموذج طليعي واحدة، تكون قد تلقّت في يونيو درسا مدته 19 يوما.

ثانيا، منظومة الأوزان المفتوحة تُصمَّم اليوم على أساس الضبط الدقيق. أعلنت NVIDIA في 4 يونيو عن Nemotron 3 Ultra، وهو نموذج خليط خبراء (MoE) بحجم إجمالي 550 مليار معلمة ونشِط منها 55 مليارا، ويأتي مزودا افتراضيا بوصفات LoRA SFT وSFT الكامل وتعلم معزز GRPO. رخصة OpenMDW-1.1 تسمح صراحة بتسويع وإعادة توزيع النماذج المشتقة من الضبط الدقيق. الهدف من تصميم هذه الرخصة هو أن تملك الشركات وتبيع النموذج الذي دربته على بياناتها الخاصة. وفي 29 يونيو، أطلقت Palantir وNVIDIA معا منتجا مدمجا للذكاء الاصطناعي السيادي يتيح ضبط الأوزان المفتوحة دقيقا وتشغيلها داخل بيئة معزولة عن الشبكة (air-gapped). في الاتحاد الأوروبي، طُرح مشروع قانون لتصنيف أحمال العمل العامة وفق درجات ضمان السيادة، وفي كوريا كذلك مشاريع الذكاء الاصطناعي السيادي قيد التنفيذ.

ثالثا، ظهرت حالة انتصار عملي لعامل الضبط الدقيق. في معيار قياس نشرته شركة الذكاء الاصطناعي القانوني Harvey بالتعاون مع Fireworks، حقق نموذج Kimi K2.6 المضبوط بتقنية SFT فقط، ودون أي مساعدة من نموذج طليعي، معدل اجتياز إجمالي بلغ 15% على 100 مهمة، متجاوزا نموذج Claude Opus 4.7 المستقل الذي حقق 14%، وبتكلفة أقل بنحو 11.4 مرة. أما التركيبة الهجينة التي تستدعي نموذجا طليعيا انتقائيا إلى جانب عامل الضبط الدقيق، فحققت أعلى معدل اجتياز عند 18%. رغم أن هذا معيار قياس صادر عن المورّد نفسه، فإنه دليل عملي على أن الجمع بين عامل مضبوط دقيقا وتصعيد انتقائي إلى نموذج طليعي، في مجال ضيق، يحقق الجودة والتكلفة معا.

رابعا، تفوق النماذج الصغيرة في مجالات ضيقة لا يزال يتكرر. في ورقة بحثية نُشرت في 11 يونيو، أظهر نموذج Mistral-7B المضبوط دقيقا بتقنية QLoRA تفوقا في التحقق من الادعاءات الطبية الحيوية على GPT-4o وGPT-5، بفارق يصل إلى 12 نقطة مئوية في مقياس F1. وقد استُخدم لهذا التدريب 1,008 عينة فقط.

## السوق ينقسم إلى ثلاثة مسارات

عند تراكب هذه الإشارات معا، يتضح أن السوق لا ينقسم بين "الموت أو البقاء" فحسب، بل ينقسم إلى ثلاثة مسارات.

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
<div class="d3-arch" data-arch-root id="ningsurvivalstrategy2026-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 774, "height": 602, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 302, "y": 24, "w": 142, "h": 62, "title": ["سوق الضبط الدقيق", "إعادة تشكّل 2026"]}, {"id": "B", "x": 544, "y": 172, "w": 184, "h": 62, "title": ["المسار 1", "واجهة SFT ذاتية الخدمة"]}, {"id": "C", "x": 277, "y": 164, "w": 191, "h": 78, "title": ["المسار 2", "النموذج السيادي المملوك", "المخصص"]}, {"id": "D", "x": 24, "y": 164, "w": 198, "h": 78, "title": ["المسار 3", "الضبط الدقيق بالتعلم", "المعزز واقتصاديات العمال"]}, {"id": "B1", "x": 530, "y": 344, "w": 212, "h": 78, "title": ["مرحلة انكماش", "إغلاق تدريجي من OpenAI", "تحوّل LoRA إلى سلعة أساسية"]}, {"id": "C1", "x": 270, "y": 320, "w": 205, "h": 126, "title": ["ارتفاع علاوة القيمة", "منتجات ضبط دقيق معزولة عن", "الشبكة", "مشروع قانون تصنيف السيادة", "رخص مصممة على أساس الضبط", "الدقيق"]}, {"id": "D1", "x": 31, "y": 336, "w": 184, "h": 94, "title": ["نمو جديد", "RFT يبقى في مسار منفصل", "عامل ضبط دقيق + تصعيد", "لنموذج طليعي"]}, {"id": "E", "x": 166, "y": 524, "w": 163, "h": 46, "title": "ملكية النموذج كمنتج"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[444, 74], [636, 125], [636, 125], [636, 172]]}, {"src": "A", "dst": "C", "kind": "data", "line": [373, 86, 373, 164]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[302, 75], [123, 125], [123, 125], [123, 164]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [636, 234, 636, 344]}, {"src": "C", "dst": "C1", "kind": "data", "line": [373, 242, 373, 320]}, {"src": "D", "dst": "D1", "kind": "data", "line": [123, 242, 123, 336]}, {"src": "C1", "dst": "E", "kind": "data", "curve": [[373, 446], [373, 485], [373, 485], [294, 524]]}, {"src": "D1", "dst": "E", "kind": "data", "curve": [[123, 430], [123, 485], [123, 485], [201, 524]]}]});
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
      const container = document.getElementById('ningsurvivalstrategy2026-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ningsurvivalstrategy2026-1';
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

المسار الأول، واجهة SFT ذاتية الخدمة، في مرحلة انكماش. طول السياق الكبير للنماذج الطليعية، ودعمها الأصلي لاستدعاء الأدوات، والمخرجات المُهيكَلة، استوعبت جزءا كبيرا من مشكلتَي الالتزام بالصيغة ومفردات المجال، اللتين كانتا سبب وجود الضبط الدقيق في الأصل. المسار الثاني، النموذج المخصص المملوك، يُعاد تشكيله كخدمة علاوية (premium). عصر الضبط الدقيق الخفيف عبر الواجهة البرمجية ينتهي، لكن التخصيص الثقيل الذي تملك فيه الشركة نموذجها وتتحكم فيه يزداد قيمة. المسار الثالث طلب جديد يخلقه عصر الوكلاء. كلما تحسّنت أدوات التنسيق (orchestrators)، تزداد استدعاءات العمال منخفضي التكلفة المسؤولين عن المهام الفرعية المتكررة، ولا يمكن تحمّل استدعاء نموذج طليعي في كل شريحة من هذه الاستدعاءات.

## الشروط الخمسة التي يفوز فيها الضبط الدقيق بوضوح

عند تلخيص الحالات الموثّقة كنمط، يتضح أن احتمال فوز الضبط الدقيق وعائده على الاستثمار يرتفعان كلما تجمّعت الشروط التالية.

1. عندما تكون المهمة ضيقة ومتكررة وصيغة المخرجات ثابتة. التصنيف والتحقق والاستخراج المُهيكَل أمثلة نموذجية، والحالة التي حققت تفوقا بـ12 نقطة مئوية بـ1,008 عينة فقط من هذا النوع.
2. عندما توجد مكافأة قابلة للتحقق. إذا توفرت تغذية راجعة من البيئة تسمح بتطبيق GRPO أو RFT، فهذا أفضل من التعلم المُوجَّه، وهو السبب الذي جعل OpenAI تُبقي على RFT وحده بعد إيقاف SFT.
3. عندما يكون تكرار الاستدعاء مرتفعا والتكلفة والزمن هما القيد المُهيمن. شرائح عمال الوكلاء تندرج هنا، وفارق التكلفة بمقدار 11.4 مرة يصبح حاسما كلما ازداد الحجم.
4. عند وجود متطلبات سيادة بيانات أو تنظيم أو شبكة معزولة. المجالات العامة والمالية والدفاعية تكون فيها خيارات الواجهة الخارجية محدودة أصلا.
5. عندما تشكّل واجهة النموذج الطليعي نفسها مخاطرة في سلسلة التوريد. كما أظهر حادث التعطيل لمدة 19 يوما، لم تعد ضوابط التصدير وتغيرات السياسات سيناريو افتراضيا.

في المقابل، لم نجد ضمن هذه النافذة الزمنية أي دليل على أن النموذج المضبوط دقيقا تفوّق على النموذج الطليعي في الاستدلال المفتوح المجال، أو المعرفة الحديثة، أو معالجة الذيل الطويل (long-tail). في هذه المجالات، التقييم الصادق هو ترك الساحة للمهارات وللنماذج الطليعية.

## دلالات هذا التحليل من منظور منتجات ThakiCloud

يتقاطع هذا الانقسام تماما مع اتجاه منتجَينا الرئيسيَّين.

من منظور ai-platform، ما يتطلبه المساران 2 و3 هو في النهاية بنية تحتية للتدريب والخدمة تعمل داخل شبكة العميل المعزولة. تُشغّل منصة ai-platform لدى ThakiCloud خمسة أنابيب تدريب هي SFT وCPT وDPO وGRPO وGKD، فوق جدولة وحدات معالجة الرسوميات (GPU) القائمة على Kubernetes وKueue. من المهم بالنسبة لنا أن هذا البحث أكد أن المحورين اللذين بدأ السوق يعترف بعلاوة قيمتهما هما GRPO المبني على مكافأة قابلة للتحقق، والتقطير (distillation) الذي ينقل مخرجات النموذج الطليعي إلى نموذج صغير. وكلما تزايدت متطلبات النشر الداخلي والسيادة، يتحوّل الضبط الدقيق من ميزة في واجهة برمجية إلى قضية قدرة بُنى تحتية، وهذا هو الموقع الذي نقف فيه.

من منظور Paxis، يوضّح هذا الاستنتاج بجلاء تقسيم الأدوار بين المهارات والضبط الدقيق. Paxis هو مستوى التحكم السحابي الأصلي للوكلاء (Agent-Native Cloud) لدى ThakiCloud، يختار من بين أكثر من 960 مهارة عبر خوارزمية BM25 وينفذها داخل صندوق رملي معزول، بحيث يمر كل سلوك عبر بوابات سياسة وسجلات تدقيق. الدرس الذي كشفته معايير قياس المهارات، وهو أن المهارات فعّالة فقط عند تنسيقها بعناية، وأن المهارات ذاتية التوليد غير موثوقة، يؤكد أن استثمار Paxis في تنسيق المهارات وحلقات التحقق كان الاتجاه الصحيح. وفي الوقت ذاته، يوضّح نمط حالة Harvey أن عامل الضبط الدقيق اقتصادي في المهام الفرعية المتكررة لأسطول الوكلاء، وأن التنسيق القائم على المهارات وعمال الضبط الدقيق ليسا في علاقة تنافس، بل طبقتان لبنية واحدة. إنه تصميم لا يتخلى عن النموذج الطليعي بل يستخدمه باقتصاد.

## الحدود وحجج مضادة

يجب أيضا وضع سيناريوهات قد تُبطل هذا التحليل. أقوى حجة مضادة هي سرعة تطور تحسين فضاء النص. صنّفناها كدراسة خلفية، لكن SkillOpt من Microsoft Research حقق تحسنا في الأداء بمقدار 19 إلى 25 نقطة مئوية بالاعتماد فقط على تحسين وثائق المهارات عبر آلية rollout، دون المساس بأوزان النموذج إطلاقا. إذا نضج هذا المسار، فقد يزحف حتى على آخر معاقل الضبط الدقيق، وهي دقة المهام الضيقة. حتى في هذا السيناريو، ما يبقى حيا ليس وظيفة التدريب بل عقد البنية التحتية الخاص بخدمة وتشغيل نموذج مملوك للعميل داخل شبكة معزولة. وقد لوحظ فعلا ضمن إشارات السوق في هذه النافذة الزمنية أن القيمة المضافة تنتقل من طبقة التدريب إلى طبقة الخدمة.

حد آخر يكمن في البيانات ذاتها. معيار قياس Harvey إعلان صادر عن المورّد نفسه، ولم نتمكن من الحصول ضمن هذه النافذة الزمنية على بيانات سوق كمية مباشرة تُظهر تراجع أو ازدياد الطلب على الضبط الدقيق. كما ينبغي التمييز بين قرار OpenAI بإغلاق الخدمة، الذي هو قرار من جانب العرض، وبين أي دليل مباشر على تراجع الطلب.

## خاتمة

الشعور القائل بأن "الضبط الدقيق لم يعد ضروريا" صحيح فقط بنسبة النصف. صحيح أن SFT كسلعة أساسية يتراجع فعلا، لكن الأحداث الموثّقة خلال شهر يونيو 2026 تُظهر أن الضبط الدقيق يُعاد تشكيله في اتجاهين هما ملكية النموذج واقتصاديات عمال الوكلاء. حان وقت تغيير السؤال. لم يعد السؤال "هل نُجري ضبطا دقيقا أم لا"، بل "في أي الشروط نملك النموذج"، وهذا هو السؤال الصحيح للنصف الثاني من عام 2026.

## المراجع

- [NVIDIA Debuts Nemotron 3 Family of Open Models (NVIDIA Newsroom, 2026-06-04)](https://nvidianews.nvidia.com/news/nvidia-debuts-nemotron-3-family-of-open-models)
- [تقرير Nemotron 3 Ultra التقني (arXiv:2606.15007)](https://arxiv.org/pdf/2606.15007)
- [Small LLMs for Biomedical Claim Verification (arXiv:2606.12854, 2026-06-11)](https://arxiv.org/abs/2606.12854)
- [US orders Anthropic to disable AI models for all foreign nationals (Al Jazeera, 2026-06-13)](https://www.aljazeera.com/news/2026/6/13/us-orders-anthropic-to-disable-ai-models-for-all-foreign-nationals)
- [Anthropic says Trump admin has lifted export controls (CNBC, 2026-06-30)](https://www.cnbc.com/2026/06/30/anthropic-says-trump-admin-has-lifted-export-controls-on-claude-fable-5-and-mythos-5.html)
- [SAGE-OPD: تقطير انتقائي قائم على السياسة (arXiv:2606.19659, 2026-06-17)](https://arxiv.org/abs/2606.19659v1)
- [SkillJuror (arXiv:2606.11543, 2026-06)](https://arxiv.org/abs/2606.11543)
- [How Harvey & Fireworks Beat Closed Source on Cost + Quality (Fireworks AI Blog)](https://fireworks.ai/blog/open-source-agents-frontier-advisors)
- [OpenAI is winding down the fine-tuning API (OpenAI Developer Community)](https://community.openai.com/t/openai-is-winding-down-the-fine-tuning-api-and-platform-discussion-thread/1380522)
- [Linux Foundation Releases OpenMDW-1.1 (Linux Foundation, 2026-05-28)](https://www.linuxfoundation.org/press/linux-foundation-releases-openmdw-1.1-nvidia-adopts-openmdw-for-cosmos-isaac-gr00t-ising-and-nemotron-ai-model-families)
- [SkillsBench (arXiv:2602.12670, دراسة خلفية)](https://arxiv.org/abs/2602.12670)
- [SkillOpt: Agent skills as trainable parameters (Microsoft Research, دراسة خلفية)](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/)
