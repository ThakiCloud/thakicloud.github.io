---
title: "iTool: الضبط الدقيق المعزز مع معايرة النقص الديناميكي لاستخدام الأدوات المتقدمة"
excerpt: "تحليل معمق لمنهجية iTool المبتكرة للضبط الدقيق المعزز، التي تعالج مشكلة تناقص فعالية التدريب في بيانات استخدام الأدوات الاصطناعية"
seo_title: "بحث iTool للضبط الدقيق المعزز: تحسين قدرة LLM على استخدام الأدوات - Thaki Cloud"
seo_description: "تحليل ورقة بحث iTool المطورة بالتعاون بين معهد هاربين للتكنولوجيا وشركة هواوي. تحقق تحسينا بنسبة 13% في أداء LLM عبر البحث القائم على MCTS وتحسين التفضيل"
date: 2025-08-21
last_modified_at: 2025-08-21
tags:
  - iTool
  - reinforcement-learning
  - fine-tuning
  - tool-use
  - LLM
  - MCTS
  - preference-optimization
  - harbin-institute-of-technology
  - huawei
author_profile: true
toc: true
toc_label: "جدول المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/research/itool-reinforced-fine-tuning-tool-use-research/"
lang: ar
reading_time: true
published: false
categories:
  - research
---

⏱️ **وقت القراءة المقدر**: 12 دقائق

## المقدمة

باتت قدرة النماذج اللغوية الكبيرة (LLMs) على استخدام الأدوات الخارجية إمكانية محورية لبناء أنظمة ذكاء اصطناعي عملية. فمن خلال استدعاء واجهات برمجة التطبيقات (APIs)، والاستعلام عن قواعد البيانات، والتفاعل مع الخدمات الخارجية، تستطيع النماذج تجاوز حدودها المعرفية الزمنية وحل المهام الواقعية التي يعجز عنها توليد النص الصرف.

اعتمد النهج السائد في تعليم استخدام الأدوات على الضبط الدقيق بالإشراف (SFT) باستخدام مجموعات بيانات مُوَلَّدة اصطناعياً. تقوم فرق البحث بجمع أو بناء أمثلة على السلوك الصحيح في استدعاء الأدوات، ثم تدرّب النماذج على محاكاة تلك الأمثلة. وعلى الرغم من النجاحات الأولية لهذا النهج، فإنه يصطدم بسقف أساسي: كلما كبرت بيانات التدريب، تضاءل التحسن الهامشي في قدرة النموذج. يصبح النموذج بارعاً في استنساخ الأنماط السطحية للبيانات الاصطناعية، بدلاً من بناء فهم راسخ وقابل للتعميم حول متى وكيف يستدعي الأدوات بصورة صحيحة.

هذه هي المشكلة التي يعالجها بحث iTool. طُوِّر هذا البحث بالتعاون بين مختبر SCIR في معهد هاربين للتكنولوجيا، وشركة هواوي للتكنولوجيا (Huawei Technologies)، ومختبر هواوي للسفينة نوح (Huawei Noah's Ark Lab). يقترح iTool إطاراً للضبط الدقيق المعزز يتجاوز التعلم بالمحاكاة. الورقة البحثية متاحة على arXiv تحت الرقم arXiv:2501.09766.

## المشكلات القائمة

### تناقص فعالية التدريب

يواجه SFT القياسي على بيانات استخدام الأدوات الاصطناعية ظاهرة التشبع. مع تنامي حجم مجموعة البيانات من عشرات الآلاف إلى مئات الآلاف من العينات، تتراجع مكاسب الأداء على مجموعات الاختبار تدريجياً. يقوم النموذج في الجوهر بحفظ توزيع التدريب بدلاً من اكتساب قدرة استدلالية حقيقية حول استخدام الأدوات.

تتجلى هذه الظاهرة بصورة أحدّ في السيناريوهات المركبة متعددة الخطوات. حين تستلزم مهمة ما تسلسل استدعاءات متعددة، أو التعامل مع معاملات غامضة، أو التعافي من أخطاء وسيطة، كثيراً ما تُخفق النماذج المدربة بـ SFT. تنتج هذه النماذج استدعاءات أدوات تبدو صحيحة شكلاً لكنها خاطئة مضموناً، لأنها تعلمت مطابقة الأنماط لا الاستدلال حول البنية الجوهرية للمهمة.

### مفهوم نقص الشظايا (Fragment Deficiency)

من أبرز الرؤى المحورية في ورقة iTool مفهوم نقص الشظايا (Fragment Deficiency). في SFT القياسي، يُدرَّب النموذج على إعادة إنتاج تسلسلات استدعاء الأدوات كاملةً وصحيحةً. غير أن النموذج الذي ينتج استدعاءً صحيحاً جزئياً، يُصيب اسم الدالة لكنه يُخطئ في قيم المعاملات، لا يحصل على أي ائتمان ولا يتلقى تغذية راجعة مُستهدَفة. تتعامل إشارة التدرج مع الاستجابة بأكملها باعتبارها خاطئة، حتى وإن أظهر النموذج كفاءة جزئية.

يُشير نقص الشظايا إلى هذه الفجوة: النموذج لديه نقاط ضعف موضعية في مكونات محددة من سلوك استدعاء الأدوات (توليد قيم المعاملات، استنتاج الأنواع، الربط الدلالي)، لكن إشارة التدريب خشنة للغاية لمعالجتها بصورة مستقلة. على مدار دورات التدريب المتعددة، تظل هذه النقاط الضعيفة الموضعية قائمة وتُقيّد سقف الأداء الكلي للنموذج.

### قيود السيناريوهات المركبة

علاوة على مشكلة نقص الشظايا، تُعاني النماذج المدربة بـ SFT من صعوبة في التعامل مع السيناريوهات التي تستلزم تأليف سلسلة متسقة من استدعاءات الأدوات. يتضمن استخدام الأدوات في العالم الواقعي كثيراً من المنطق الشرطي: استدعاء الأداة A، مراقبة النتيجة، ثم اتخاذ قرار باستدعاء الأداة B أو الأداة C. لا يستطيع التعلم بالمحاكاة الساكن تجهيز النماذج لهذا النوع من الاستدلال الديناميكي.

## منهجية iTool

يُعالج iTool هذه المشكلات عبر ثلاثة مكونات متشابكة: مرحلة إحماء SFT من السهل إلى الصعب، وآلية بحث مسار قائمة على MCTS، وحلقة ضبط دقيق معزز تكرارية مع تحسين التفضيل.

### إحماء SFT من السهل إلى الصعب

قبل الدخول إلى حلقة الضبط الدقيق المعزز، يمر النموذج بمرحلة إحماء باستخدام SFT التقليدي. والأهم أن هذا الإحماء مُنظَّم وفق منهج تدريجي من السهل إلى الصعب. تُرتَّب بيانات التدريب حسب مستوى تعقيد المهمة، ويُعرَّض النموذج أولاً لسيناريوهات الأداة الواحدة الأبسط قبل الانتقال إلى سلاسل الأدوات المتعددة الأكثر تعقيداً.

يخدم هذا التصميم المنهجي غرضين: أولاً يُرسي خطاً أساسياً كافي القوة للاستفادة من الضبط الدقيق المعزز اللاحق، وثانياً يضمن امتلاك النموذج أساساً متيناً في بناء جملة استدعاء الأدوات ودلالاتها قبل أن يُطلب منه استكشاف السيناريوهات الأصعب عبر MCTS.

### البحث عن المسار القائم على MCTS

جوهر نهج iTool هو استخدام بحث شجرة مونتي كارلو (MCTS) لتوليد مسارات استدعاء أدوات متنوعة للمهام المركبة. بالنظر إلى موجّه معقد، يستخدم النموذج MCTS لاستكشاف مسارات استجابة ممكنة متعددة. يتوافق كل عقدة في شجرة البحث مع تسلسل جزئي لاستدعاء الأدوات، وتُوسَّع الشجرة بأخذ عينات من الخطوات التالية الممكنة من التوزيع الحالي للنموذج.

تُسنَد إلى كل عقدة طرفية (تسلسل استدعاء أدوات مكتمل) قيمة Q استناداً إلى دالة مكافأة تُقيّم صحة استدعاء الأداة. هذه الدالة متعددة الأبعاد، وتلتقط دقة اسم الدالة، وصحة عدد المعاملات، ودقة أسماء المعاملات، وصحة قيم المعاملات وأنواعها. تُحسَب أيضاً درجة التشابه الدلالي لمعالجة الحالات التي ينتج فيها النموذج استجابات مكافئة دلالياً لكنها مختلفة تركيبياً.

ينتج البحث بـ MCTS مجموعة من المسارات المتنوعة لكل موجّه معقد، تتراوح بين الاستدعاءات الصحيحة عالية الجودة وأنواع مختلفة من الأخطاء. هذا التنوع هو بالضبط ما يجعل تحسين التفضيل اللاحق فعالاً.

### الضبط الدقيق المعزز التكراري

من المسارات التي يولدها MCTS، يُنشئ iTool أزواج التفضيل: استجابة مختارة (مسار ذو قيمة Q أعلى) واستجابة مرفوضة (مسار ذو قيمة Q أدنى). تُستخدم هذه الأزواج لتدريب النموذج بأساليب تحسين التفضيل، تحديداً DPO (التحسين المباشر للتفضيل) وSimPO (التحسين البسيط للتفضيل).

هذه العملية تكرارية. بعد كل جولة من تحسين التفضيل، يُستخدم النموذج المحدَّث لتوليد مسارات MCTS جديدة على المجموعة الفرعية من البيانات المركبة التي لم يتقنها النموذج بعد. تستمر الحلقة حتى التقارب، حيث يكون النموذج قد معاير بصورة منهجية على مجالات نقصه الخاصة بدلاً من التدريب بصورة موحدة على مجموعة البيانات بأكملها.

هذه المعايرة التكرارية هي الآلية التي تعالج نقص الشظايا. لأن مسارات MCTS تُظهر صراحةً الأخطاء الجزئية التي يرتكبها النموذج (قيم معاملات خاطئة، أنواع خاطئة، معاملات مفقودة)، توفر أزواج التفضيل إشارة تدرج دقيقة تستهدف تلك نقاط الضعف بالذات. يحصل النموذج على ائتمان لما يُصيبه وعلى إشارة تصحيحية لما يُخطئ فيه على مستوى المكونات.

## تصميم التجربة

### مجموعة بيانات ToolACE

تستخدم التجارب مجموعة بيانات ToolACE التي تحتوي على ما يصل إلى 100,000 عينة اصطناعية لاستخدام الأدوات، تغطي مجموعة واسعة من فئات API. تتضمن المجموعة أمثلة تتراوح بين استدعاءات الدالة الواحدة البسيطة وسلاسل الأدوات المتعددة الخطوات المركبة.

يوضح مثالان تمثيليان من مجموعة البيانات نطاق صعوبة المهام:

**Get Trending Result**: مهمة أبسط تطلب من النموذج استرجاع المحتوى الرائج من منصة محددة. يستلزم الاستدعاء الصحيح تحديد اسم الدالة وعدد محدود من المعاملات ذات الدلالة الواضحة.

**Complex Analysis Task**: مهمة أصعب تستلزم أن يجمع النموذج بين استدعاءات أدوات متعددة، ويتعامل مع نتائج وسيطة، ويطبق منطقاً شرطياً بناءً على المخرجات الملاحظة. تختبر هذه المهام قدرة النموذج على الاستدلال حول تأليف الأدوات والتعافي من الأخطاء.

### معيار BFCL

المعيار القياسي الأساسي للتقييم هو لوحة المتصدرين لاستدعاء الدوال في بيركلي (BFCL)، التي توفر مجموعة موحدة من مهام استخدام الأدوات عبر مستويات صعوبة متعددة وفئات API متنوعة. يُستخدم BFCL على نطاق واسع في مجتمع البحث لتقييم قدرة LLM على استدعاء الأدوات.

### معايير التقييم

يستخدم إطار التقييم خمسة أبعاد لتقييم جودة استدعاء الأداة:

1. **دقة اسم الدالة**: هل يختار النموذج الدالة الصحيحة للاستدعاء؟
2. **عدد المعاملات**: هل يتطابق عدد المعاملات في الاستدعاء مع العدد المتوقع؟
3. **أسماء المعاملات**: هل أسماء مفاتيح المعاملات صحيحة؟
4. **قيم المعاملات وأنواعها**: هل قيم المعاملات صحيحة ومن النوع المتوقع؟
5. **التشابه الدلالي**: مقياس أكثر مرونة يُقيّم ما إذا كانت استجابة النموذج مكافئة دلالياً للإجابة المرجعية حتى وإن اختلفت تركيبياً.

### درجات الجودة

استناداً إلى هذه الأبعاد الخمسة، تُصنَّف الاستجابات إلى أربع درجات جودة:

- **Excellent (ممتاز)**: جميع الأبعاد الخمسة صحيحة.
- **Acceptable (مقبول)**: تباينات طفيفة في بُعد أو بُعدين لا تؤثر على النتيجة الوظيفية.
- **Fair (مقبول بحدود)**: أخطاء في قيم المعاملات أو أنواعها قد تُسبب فشل استدعاء الأداة أو إنتاج نتائج غير صحيحة.
- **Poor (ضعيف)**: أخطاء جوهرية في اسم الدالة أو بنية المعاملات تجعل الاستدعاء غير صالح للاستخدام.

## النتائج التجريبية

### التحسن الكلي في الأداء

عبر المعيار الكامل BFCL، يحقق iTool تحسناً كلياً بنسبة 13.11% مقارنةً بنماذج SFT الخط الأساسي. هذا مكسب جوهري، لا سيما مع الأخذ بعين الاعتبار أن خطوط الأساس المقارنة تستخدم بيانات تدريب اصطناعية عالية الجودة.

التحسن متسق عبر مستويات صعوبة مختلفة في المعيار، لكنه أبرز في السيناريوهات المركبة متعددة الخطوات التي أخفقت فيها مناهج SFT السابقة.

### مكاسب السيناريوهات المركبة

على المجموعة الفرعية للمهام المركبة تحديداً، يحقق iTool تحسناً إضافياً بنسبة 6.5% فوق المكسب الكلي المتوسط. هذا يُؤكد أن الاستكشاف القائم على MCTS والمعايرة التكرارية للنقص هما الأكثر فعالية تحديداً في السيناريوهات التي تُقصِّر فيها SFT القياسية أكثر.

تضيق الهوة بين أداء المهام البسيطة والمركبة بصورة ملحوظة مع iTool مقارنةً بخطوط أساس SFT، مما يدل على أن النموذج طوّر استدلالاً تأليفياً أكثر رسوخاً حول استخدام الأدوات.

### نموذج 8B ينافس النماذج الأكبر

من أبرز النتائج أن نموذجاً بحجم 8 مليار معامل مدرباً بـ iTool يستطيع مضاهاة أداء نماذج أكبر بكثير مدربة بـ SFT التقليدي أو التفوق عليها. تُشير هذه النتيجة إلى أن جودة إشارة التدريب، لا كمية المعاملات، هي القيد الأساسي على قدرة استخدام الأدوات.

لهذا تداعيات عملية مهمة: المؤسسات التي لا تستطيع تحمّل تكلفة نشر النماذج الكبيرة يمكنها تحقيق أداء مماثل في استخدام الأدوات بالاستثمار في منهجية تدريب أفضل بدلاً من سعة نموذج أكبر.

### أداء مزيج SimPO

من بين أساليب تحسين التفضيل المُقيَّمة، ينتج SimPO بالتزامن مع توليد مسار iTool القائم على MCTS أفضل النتائج. تجعل بساطة SimPO واستقراره أثناء التدريب منه خياراً ملائماً لحلقة الضبط الدقيق المعزز التكرارية، حيث يتحول توزيع بيانات التفضيل مع كل جولة من تحديثات النموذج.

### دراسة الاستئصال

تُؤكد دراسة الاستئصال مساهمة كل مكون:

- إزالة إحماء SFT من السهل إلى الصعب والبدء مباشرةً بالضبط الدقيق المعزز القائم على MCTS يُدهور الأداء، مما يُظهر أن خطاً أساسياً قوياً ضروري للاستكشاف الفعال.
- إزالة MCTS واستخدام أخذ عينات عشوائي فحسب لتوليد المسار يُقلل من تنوع أزواج التفضيل وجودتها، مما يُفضي إلى مكاسب أداء أصغر.
- استخدام جولة واحدة من تحسين التفضيل بدلاً من التكرار حتى التقارب يُخفض الأداء أيضاً، مما يُؤكد قيمة حلقة المعايرة التكرارية.

## مسار عملية التعلم

يوضح المخطط التالي خط أنابيب تدريب iTool الكامل:

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
<div class="d3-arch" data-arch-root id="inetuningtooluseresearch-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1361, "height": 1667, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 331, "y": 24, "w": 261, "h": 707, "label": "عملية MCTS التفصيلية", "lx": 343, "ly": 42}, {"x": 613, "y": 24, "w": 716, "h": 140, "label": "عملية تحسين التفضيل", "lx": 625, "ly": 42}], "nodes": [{"id": "A", "x": 52, "y": 71, "w": 128, "h": 46, "title": "النموذج الأولي"}, {"id": "B", "x": 28, "y": 242, "w": 177, "h": 62, "title": ["SFT التهيئة التدريجية", "Easy-to-Hard"]}, {"id": "C", "x": 24, "y": 382, "w": 184, "h": 46, "title": "تحديد البيانات المعقدة"}, {"id": "D", "x": 82, "y": 506, "w": 212, "h": 46, "title": "استكشاف المسار بواسطة MCTS"}, {"id": "E", "x": 103, "y": 630, "w": 170, "h": 62, "title": ["توليد مسارات استجابة", "متنوعة"]}, {"id": "F", "x": 128, "y": 809, "w": 120, "h": 46, "title": "تقييم قيمة Q"}, {"id": "G", "x": 110, "y": 933, "w": 156, "h": 46, "title": "بناء أزواج التفضيل"}, {"id": "H", "x": 99, "y": 1057, "w": 177, "h": 62, "title": ["الاستجابة المختارة vs", "الاستجابة المرفوضة"]}, {"id": "I", "x": 120, "y": 1197, "w": 135, "h": 46, "title": "تحسين DPO/SimPO"}, {"id": "J", "x": 127, "y": 1321, "w": 121, "h": 46, "title": "تحديث النموذج"}, {"id": "K", "x": 33, "y": 1445, "w": 167, "h": 52, "title": "التحقق من التقارب"}, {"id": "L", "x": 35, "y": 1589, "w": 163, "h": 46, "title": "نموذج iTool النهائي"}, {"id": "D1", "x": 383, "y": 71, "w": 120, "h": 46, "title": "العقدة الجذر"}, {"id": "D2", "x": 379, "y": 250, "w": 128, "h": 46, "title": "اختيار الإجراء"}, {"id": "D3", "x": 431, "y": 382, "w": 120, "h": 46, "title": "التوسع"}, {"id": "D4", "x": 431, "y": 506, "w": 120, "h": 46, "title": "المحاكاة"}, {"id": "D5", "x": 375, "y": 638, "w": 135, "h": 46, "title": "الانتشار العكسي"}, {"id": "I1", "x": 650, "y": 63, "w": 177, "h": 62, "title": ["زيادة تفضيل الاستجابة", "الصحيحة"]}, {"id": "I2", "x": 882, "y": 63, "w": 177, "h": 62, "title": ["تقليل تفضيل الاستجابة", "الخاطئة"]}, {"id": "I3", "x": 1114, "y": 71, "w": 177, "h": 46, "title": "تصحيح الأخطاء الجزئية"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [116, 117, 116, 242]}, {"src": "B", "dst": "C", "kind": "data", "line": [116, 304, 116, 382]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[143, 428], [188, 467], [188, 467], [188, 506]]}, {"src": "D", "dst": "E", "kind": "data", "line": [188, 552, 188, 630]}, {"src": "E", "dst": "F", "kind": "data", "line": [188, 692, 188, 809]}, {"src": "F", "dst": "G", "kind": "data", "line": [188, 855, 188, 933]}, {"src": "G", "dst": "H", "kind": "data", "line": [188, 979, 188, 1057]}, {"src": "H", "dst": "I", "kind": "data", "line": [188, 1119, 188, 1197]}, {"src": "I", "dst": "J", "kind": "data", "line": [188, 1243, 188, 1321]}, {"src": "J", "dst": "K", "kind": "data", "curve": [[188, 1367], [188, 1406], [188, 1406], [145, 1445]]}, {"src": "K", "dst": "C", "kind": "data", "label": "No", "curve": [[87, 1445], [44, 1088], [44, 731], [89, 428]], "off": "50%"}, {"src": "K", "dst": "L", "kind": "data", "label": "Yes", "line": [116, 1497, 116, 1589], "lx": 116, "ly": 1539}, {"src": "D1", "dst": "D2", "kind": "data", "line": [443, 117, 443, 250]}, {"src": "D2", "dst": "D3", "kind": "data", "curve": [[459, 296], [491, 343], [491, 343], [491, 382]]}, {"src": "D3", "dst": "D4", "kind": "data", "line": [491, 428, 491, 506]}, {"src": "D4", "dst": "D5", "kind": "data", "curve": [[491, 552], [491, 591], [491, 591], [459, 638]]}, {"src": "D5", "dst": "D2", "kind": "data", "curve": [[426, 638], [394, 529], [394, 405], [426, 296]]}]});
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
      const container = document.getElementById('inetuningtooluseresearch-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'inetuningtooluseresearch-1';
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

يبدأ خط الأنابيب بدخول النموذج الأولي في مرحلة إحماء SFT من السهل إلى الصعب. بعد هذا الإحماء، يحدد النظام نقاط البيانات المركبة ويطبق البحث عن المسار القائم على MCTS لتوليد مسارات استجابة متنوعة. تُقيَّم هذه المسارات باستخدام قيم Q، وتُنشأ أزواج التفضيل من الاستجابات المختارة والمرفوضة. ثم يُحدِّث تحسين DPO أو SimPO النموذج، وتتكرر العملية حتى التقارب.

تُظهر العملية الفرعية لـ MCTS (أسفل يسار) العمليات الأربع القياسية: اختيار الإجراء، والتوسيع، والمحاكاة، والانتشار الخلفي. تُظهر العملية الفرعية لتحسين التفضيل (أسفل يمين) أهداف المعايرة الثلاثة: زيادة التفضيل للاستجابات الصحيحة، وتخفيض التفضيل للاستجابات الخاطئة، وتصحيح نقاط الضعف الجزئية للشظايا.

## الابتكارات التقنية

### مفهوم نقص الشظايا (Fragment Deficiency)

يُعد إدخال مفهوم Fragment Deficiency إسهاماً مفاهيمياً ذا قيمة. لم تمتلك الأبحاث السابقة حول استخدام LLM للأدوات مصطلحات دقيقة لوصف الأخطاء الموضعية على مستوى المكونات التي تُحدّ من أداء النموذج. من خلال تسمية هذه الظاهرة وإضفاء الطابع الرسمي عليها، يوفر بحث iTool إطاراً أوضح لتشخيص سبب توقف SFT عند سقف الأداء وما هو نوع إشارة التدريب المطلوبة للتخطي ذلك السقف.

### مزيج MCTS والتعلم التعزيزي

تطبيق MCTS لتوليد بيانات التدريب لتحسين التفضيل هو أسلوب مستعار من أدبيات الألعاب والتخطيط، معدَّل هنا لمجال استخدام الأدوات. التكيف الأساسي هو تصميم دالة المكافأة: بدلاً من إشارة فوز/خسارة ثنائية، يستخدم iTool درجة جودة متعددة الأبعاد تتوافق مباشرةً مع تصنيف Fragment Deficiency.

تصميم دالة المكافأة هذا هو ما يجعل مسارات MCTS مفيدة للمعايرة المستهدفة. ستُنتج دالة مكافأة ثنائية أزواج تفضيل تُخبر النموذج "هذه الاستجابة أفضل من تلك" دون تحديد السبب. تُنشئ دالة المكافأة متعددة الأبعاد أزواج تفضيل تُشفِّر أي مكونات بالضبط من استدعاء الأداة كانت صحيحة أو خاطئة، مما يتيح تحديثات تدرجية أكثر دقة.

### التحسين التكراري المنهجي

البنية التكرارية لحلقة التدريب، حيث تُركز كل جولة على البيانات التي لا يزال النموذج الحالي يُخفق في التعامل معها، هي شكل من أشكال التكيف المنهجي. مع تحسّن النموذج، يتحول توزيع التدريب الفعلي نحو حالات أصعب. هذا يتجنب مشكلة إهدار موارد الحوسبة التدريبية على أمثلة أتقنها النموذج بالفعل، ويضمن أن النموذج يعمل دائماً عند حافة قدرته الحالية.

## القيود

### التكلفة الحسابية العالية لـ MCTS

MCTS مُكلف حسابياً. يستلزم كل استدعاء تشغيل مرورات أمامية كثيرة عبر النموذج لتوسيع شجرة البحث وتقييم المسارات. عند الحجم المطلوب للتدريب على 100,000 عينة، تكون التكلفة الحسابية الإجمالية أعلى بكثير من SFT القياسي. تُقرّ الورقة بهذا لكنها لا تقترح حلاً ملموساً، موضعةً إياه كعمل مستقبلي.

بالنسبة للممارسين، هذا يعني أن iTool كما هو موصوف يُناسب أكثر خطوط أنابيب التدريب غير المتصلة (offline) حيث لا تكون موازنة الحوسبة القيد الأساسي. ستستلزم إعدادات التعلم المتصل أو المستمر تقريبات بحث شجري أكثر كفاءة.

### التقييم مُركَّز على دقة استدعاء الدوال

يُقيِّم معيار BFCL استخدام الأدوات أساساً على مستوى صحة استدعاء الدالة: هل يُنتج النموذج اسم الدالة الصحيح بالمعاملات الصحيحة؟ هذا معيار محدد وقابل للقياس، لكنه لا يلتقط كل ما يهم في سيناريوهات استخدام الأدوات العملية.

في النشر الفعلي، يتضمن استخدام الأدوات وقت الاستجابة، ومعالجة الأخطاء، والتعافي من النجاح الجزئي، والتفاعل متعدد الأدوار. قد يُخفق النموذج الذي يُنتج استدعاءات أدوات صحيحة تركيبياً في الممارسة إذا كان غير قادر على التعامل مع استجابات API غير متوقعة، أو إذا لم يستطع الاستدلال حول متى يُعيد محاولة استدعاء فاشل. لا يُعالج إطار تقييم iTool هذه الأبعاد العملية.

### غياب الجوانب العملية

مرتبطاً بنقطة التقييم السابقة، تُركز الورقة على منهجية التدريب غير المتصلة وتقييم المعيار بدلاً من اعتبارات النشر العملية. أسئلة حول أداء iTool في بيئات الإنتاج، وكيفية تعامله مع الانتقال التوزيعي بين واجهات برمجة التدريب وواجهات برمجة النشر، وكيفية تكاملها مع أطر تنفيذ الأدوات الواقعية، تبقى مفتوحة.

## الاتجاهات المستقبلية

تنبثق عدة اتجاهات بحثية مستقبلية بصورة طبيعية من منهجية iTool وقيودها الحالية:

**كفاءة الحوسبة**: الحاجة الأكثر إلحاحاً هي جعل توليد المسار القائم على MCTS أكثر قابلية للتنفيذ حسابياً. يمكن لأساليب مثل تقريبات بحث الشعاع (beam search)، أو تسريع نموذج المسودة (draft-model)، أو دوال القيمة المُتعلَّمة التي تُقلل من عدد عمليات المحاكاة، أن تُخفض تكلفة التدريب بصورة ملحوظة.

**التوسع في مجالات متنوعة**: تغطي مجموعة بيانات ToolACE نطاقاً تمثيلياً لكن غير شامل من أنواع API. سيختبر توسيع إطار iTool إلى مجالات إضافية، بما في ذلك واجهات برمجة التطبيقات العلمية المتخصصة بالمجال، وخطوط أنابيب معالجة البيانات، وبيئات تنفيذ الكود، عمومية النهج وقد يكشف عن تحديات معايرة خاصة بالمجال.

**آليات السلامة والموثوقية**: مع نشر LLMs بوصول حقيقي للأدوات، تصبح عواقب استدعاءات الأدوات الخاطئة أكثر خطورة. يمكن لأبحاث مستقبلية دمج قيود السلامة في دالة المكافأة، وعقوبة استدعاءات الأدوات التي قد يكون لها آثار جانبية ضارة حتى وإن كانت صحيحة تقنياً. آليات الموثوقية، مثل تقدير الثقة لاستدعاءات الأدوات المُولَّدة والامتناع المبدئي حين تكون الثقة منخفضة، مهمة أيضاً للنشر العملي.

## الخلاصة

يُقدم iTool حلاً مبدئياً لمشكلة تناقص العوائد التي تؤثر على مناهج SFT في تعليم LLM استخدام الأدوات. من خلال إدخال مفهوم Fragment Deficiency، وتطبيق MCTS لتوليد مسارات تدريب متنوعة ومفيدة، واستخدام تحسين التفضيل في حلقة معايرة تكرارية، يحقق الإطار تحسناً كلياً بنسبة 13.11% ومكسباً إضافياً بنسبة 6.5% على السيناريوهات المركبة.

النتيجة التي تُظهر أن نموذجاً بحجم 8 مليار معامل مدرباً بـ iTool يستطيع منافسة النماذج الأكبر المدربة بـ SFT جديرة بالاهتمام بصفة خاصة. تُشير إلى أن التركيز الحالي في هذا المجال على توسيع حجم النموذج قد يكون جزئياً في غير محله: بالنسبة لقدرة استخدام الأدوات تحديداً، تهم جودة إشارة التدريب وبنيتها بالقدر ذاته على الأقل من عدد المعاملات.

القيد العملي الرئيسي هو التكلفة الحسابية لـ MCTS، التي تحصر iTool في خطوط أنابيب التدريب غير المتصلة في الوقت الحالي. معالجة هذه التكلفة هي الأولوية البحثية قصيرة الأجل الأهم إذا كانت المنهجية ستحظى باعتماد عملي واسع.

بالنسبة للفرق التي تبني أنظمة LLM تعتمد على استخدام الأدوات الخارجية، يوفر إطار iTool مساراً واضحاً ومُتحقَّقاً منه لتحسين قدرة النموذج إلى ما هو أبعد مما يستطيع SFT القياسي تحقيقه. المنهجية مستقلة عن النموذج وعن مجموعة البيانات، مما يجعلها قابلة للتطبيق عبر مجموعة واسعة من سياقات النشر.

## المراجع

- ورقة iTool: arXiv:2501.09766
- مختبر SCIR في معهد هاربين للتكنولوجيا، Huawei Technologies، Huawei Noah's Ark Lab
- معيار BFCL: Berkeley Function Calling Leaderboard
- مجموعة بيانات ToolACE: حتى 100,000 عينة اصطناعية لاستخدام الأدوات
- DPO: Direct Preference Optimization
- SimPO: Simple Preference Optimization
- MCTS: Monte Carlo Tree Search
