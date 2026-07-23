---
title: "الرفوف تنفجر صعودا والاستدلال ينهار هبوطا: الشركات تقف في منتصف مقص الذكاء الاصطناعي"
excerpt: "رقمان صدرا في اليوم نفسه تحركا في اتجاهين متضادين تماما: رف ذكاء اصطناعي بـ21 مليون دولار، ورسوم استدلال أرخص بـ34 ضعفا. إليك المقابض التي يجب أن تمسك بها الشركات في منتصف هذا المقص المتسع."
seo_title: "مقص الذكاء الاصطناعي: ما يقوله رف بـ21 مليون دولار واستدلال أرخص بـ34 ضعفا في يوم واحد"
seo_description: "ارتفاع أسعار رفوف HBM4 وانهيار أسعار الاستدلال بفعل DeepSeek وصلا في اليوم نفسه. تحليل لبنية تتباعد فيها تكاليف رأس مال البنية التحتية عن تكلفة النماذج في اتجاهين متضادين، والمتغيرات التي يمكن للشركات فعلا التحكم بها بينهما."
date: 2026-07-10
last_modified_at: 2026-07-10
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/news/ai-price-scissors-infra-vs-inference/"
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
tags:
  - ai-infrastructure
  - hbm4
  - inference-cost
  - sovereign-ai
  - gpu-cloud
  - model-routing
  - tco
categories:
  - news
---

![رسم تخطيطي لمفهوم مقص الذكاء الاصطناعي يظهر شركة عالقة بين ارتفاع أسعار الرفوف من الأعلى وانهيار أسعار الاستدلال من الأسفل]({{ '/assets/images/ai-price-scissors-infra-vs-inference-hero.webp' | relative_url }})

## في اليوم نفسه، سار رقمان بعيدا أحدهما عن الآخر

حملت أخبار هذا الصباح رقمين يتحركان في اتجاهين متضادين تماما، جنبا إلى جنب. أحدهما قفز صعودا: أُفيد أن متوسط سعر بيع رف Nvidia Rubin Ultra بلغ 21 مليون دولار، أي أكثر من خمسة أضعاف الجيل السابق Blackwell Ultra البالغ 4 ملايين دولار. أما الآخر فقد هوى إلى القاع: خفّضت DeepSeek أسعار V4-Pro بنسبة 75 بالمئة بشكل دائم، طارحة بطاقة سعر أرخص بـ34 ضعفا من OpenAI وبـ29 ضعفا من Anthropic على أساس رموز الإخراج.

من جهة، يرتفع سعر الحديد الذي يشغّل الذكاء الاصطناعي بشكل حاد. ومن جهة أخرى، تنهار قيمة الإجابات التي ينتجها ذلك الحديد. ما يبدو للوهلة الأولى تناقضا هو في الحقيقة حدث واحد. القصة التي تخترق ملخص اليوم ليست عن مدى ذكاء نموذج بعينه، بل عن حقيقة أن الطابقين العلوي والسفلي لاقتصاد الذكاء الاصطناعي يتباعدان في اتجاهين متضادين. والعالق بين الشفرتين المتباعدتين هو، في النهاية، الشركة التي تريد فعلا استخدام هذه التقنية.

## الطابق العلوي: الحديد يزداد غلاء باستمرار

القصة ليست عن أسعار الرفوف وحدها. الطابق العلوي بأكمله يرفع أسعاره. توقعت Bernstein أن ترتفع أسعار وحدة ذاكرة HBM4 وLPDDR5X إلى 53 دولارا لكل غيغابايت بحلول عام 2027. وبما أن أكثر من نصف تكلفة الرف يتركز في وحدات معالجة الرسوميات وذاكرة HBM، فإن ارتفاع أسعار الذاكرة يسحب معه سعر الخادم الواحد بأكمله إلى الأعلى. ومع ذلك، لا تُبطئ Samsung Electronics وSK hynix وMicron وتيرة توسعها، بل تسرّعها. الحساب وراء ذلك أن المصنع الجديد يحتاج ثلاث سنوات على الأقل ليقدّم كمية إنتاج فعلية، ما يعني أن زيادة معتبرة في العرض لن تكون ممكنة قبل عام 2028. التزمت Micron بضخ 250 مليار دولار في الولايات المتحدة حتى عام 2035، بينما تحركت SK hynix لإدراج إيصالات إيداع أمريكية بسعر اكتتاب 149 دولارا، بقيمة إدراج تبلغ نحو 40 تريليون وون، وهو أكبر إدراج لشركة أجنبية في البورصة الأمريكية على الإطلاق. استثمار اليوم ليس إشارة إلى أن الأسعار على وشك الانخفاض، بل رهان مسبق لتثبيت موقع أمام الطلب المدفوع بالذكاء الاصطناعي والذي سيستمر لسنوات مقبلة. مع ذلك، حملت أخبار اليوم نفسه أيضا أن وزير التجارة الأمريكي ضغط علنا، في فعالية لمصنع في نيويورك، على الشركات الكورية لتوسيع الإنتاج داخل الولايات المتحدة. وأصبح تحديد كيفية توزيع رأس المال والقوى العاملة بين استثمارات محلية ضخمة ومطالب بالاستثمار في أمريكا واجبا منزليا جديدا لشركات الذاكرة الثلاث.

الأسعار ليست وحدها ما يزداد غلاء، بل التعقيد أيضا. قالت Samsung Electronics إنها تطوّر تعبئة 2.xD تجمع HBM والمنطق والضوئيات السيليكونية في وحدة واحدة. تجاوز اختناقات النطاق الترددي يتطلب دمج شرائح مختلفة بدقة متناهية، وكلما حدث ذلك أكثر أصبحت سلسلة التوريد بأكملها رهينة لسعة المسابك والتعبئة المتقدمة. إنها بنية يتصاعد فيها التعقيد والتكلفة معا مع ارتفاع الأداء. تقول Nvidia إن مكاسب الأداء تحسّن إجمالي تكلفة الملكية، لكن مع تركز نصف تكلفة الرف في وحدات معالجة الرسوميات وذاكرة HBM، برزت سرعة الاسترداد الفعلي للاستثمار كالمتغير الحقيقي الذي يحدد مدى استدامة هذه الدورة.

يقف هنا جدار أثقل: الطاقة. كما أشارت صحيفتا JoongAng Ilbo وJoseA Ilbo، انتقل محور المنافسة في الذكاء الاصطناعي بالفعل من تأمين أشباه الموصلات إلى تشغيل مراكز البيانات. وضعت الحكومة هدفا لجذب أكثر من 550 تريليون وون من استثمارات مراكز بيانات الذكاء الاصطناعي بحلول عام 2029، وأكثر من 1000 تريليون وون بحلول عام 2035، وضمن ذلك تتولى مجموعة SK نسبة 81 بالمئة من هدف قدره 18.4 غيغاواط. المشكلة أن سيول ومقاطعة Gyeonggi تستحوذان على 78.7 بالمئة من عقود الطاقة ذات الصلة، بينما المواقع الأساسية هناك تقترب فعلا من التشبع. يتطلب ربط الشبكة الكهربائية وتوسيع محطات التحويل الفرعية فترة تصاريح أطول من مجرد شراء وحدات معالجة الرسوميات. يمكن للتبريد السائل، مثل التبريد بالغمر، أن يقلص طاقة التبريد بأكثر من 90 بالمئة، لكن نقص العمالة يُشار إليه كاختناق آخر، إذ ليس سهلا الاحتفاظ لثلاث إلى خمس سنوات أو أكثر بالكوادر التشغيلية العالية المهارة اللازمة لتشغيل هذه المرافق على مدار الساعة. لهذا السبب، يُعاد تسعير شركات تعدين البيتكوين السابقة، التي تمتلك بالفعل حقوق نقل كهربائي واسعة النطاق، كموردي بنية تحتية للذكاء الاصطناعي. ومع توقيع شركات مثل Core Scientific وIREN وTeraWulf عقود طاقة طويلة الأجل مع مزودي الحوسبة فائقة الحجم، بدأ السوق يعيد تقييمها ليس بناء على ربحية التعدين بل على سعة الطاقة التي تملكها، مقاسة بالميغاواط. المورد النادر حقا في الطابق العلوي الآن ليس الشريحة، بل الكهرباء.

## الطابق السفلي: قيمة الإجابة تنخفض باستمرار

في اليوم نفسه، عملت في الطابق السفلي قوة معاكسة تماما. لم يكن خفض أسعار DeepSeek عرضا ترويجيا لمرة واحدة، بل سياسة دائمة، وظهر أثره في الأرقام. على منصات المطورين مثل Vercel وOpenRouter، قفزت حصة حركة مرور النماذج الصينية إلى رقمين خلال فترة قصيرة، وحوّلت شركة ناشئة فعلية مثل Lindy خدمتها بالكامل من Anthropic إلى DeepSeek. العملاء الحساسون للسعر يتحركون بالفعل.

تُظهر تحركات Meta هذا الاتجاه بوضوح أكبر. Meta، التي كانت تبني منظومتها عبر إطلاق Llama كمصدر مفتوح، دخلت لأول مرة أعمال واجهة برمجة تطبيقات مدفوعة عبر Muse Spark 1.1، وطرحت سعرا مذهلا يبلغ نحو ربع سعر المنافسين. أعرب Zuckerberg عن ثقته بأن السعر سيكون جذابا. إلى جانب ذلك، تخطط Meta لبدء الإنتاج الضخم لشرائحها الخاصة بالذكاء الاصطناعي ابتداء من سبتمبر لتقليل اعتمادها على Nvidia، بل وتتحرك لبيع الحوسبة الخاملة للخارج لاسترداد إنفاق بنية تحتية قد يصل إلى 145 مليار دولار هذا العام. بعد TPU من Google وTrainium من Amazon، تنضم شريحة Meta المخصصة إلى المشهد، في مرحلة تطبع فيها شركات التقنية الكبرى شرائحها الخاصة وتعيد بيع ما يتبقى من الحوسبة. كلما زاد الضغط على التكلفة في الطابق العلوي، اشتدت حرب الأسعار في الطابق السفلي لنقل ذلك الضغط إلى طرف آخر.

تُظهر الأخبار المحلية أن حركة المقص هذه ليست قصة وادي السيليكون وحده. قال Ha Jung-woo إن مدينة أولسان تملك فرصة كبيرة للتحول الصناعي بالذكاء الاصطناعي نظرا لما تراكم لديها من بيانات صناعية تصنيعية، وتشاركت ITCEN Core مع KB Kookmin Bank، وطرحت SK AX تحولا متكاملا موجّها لمواقع التصنيع. بدأت LG تطوير نموذج عالمي يفهم قوانين الفيزياء، ووضعت Alipay رهانها في عصر الوكلاء على الدفع والثقة والانفتاح. هذا يعني أن التصنيع والتمويل والقطاع العام بدأوا كل على حدة بدفع الذكاء الاصطناعي إلى العمل الفعلي. المشكلة أن هذه الجهات، لحظة تبنيها الذكاء الاصطناعي، تقع مباشرة بين الشفرتين اللتين استعرضناهما للتو. تضغط تكاليف رأس مال البنية التحتية من الأعلى، بينما تضغط تكلفة النماذج ومخاطر السيادة من الأسفل، في آن واحد.

## لماذا هاتان القوتان واحدة في الجوهر

الاتجاهان اللذان بدَوَا تناقضا ينبعان في الحقيقة من الجذر نفسه. مع انفجار الطلب على الذكاء الاصطناعي، تدفع ندرة أشباه الموصلات والطاقة في المنبع الأسعار إلى الأعلى. وفي الوقت نفسه، تُسقط المنافسة بين موفري النماذج الساعين لالتقاط ذلك الطلب هوامش الربح في المصب. بمعنى آخر، ارتفاع تكاليف رأس المال من الأعلى وانخفاض أسعار البيع من الأسفل توأمان وُلدا من الطلب نفسه. لهذا يشبه هذا البناء مقصا: تتحرك الشفرتان في اتجاهين متضادين، لكنهما مرتبطتان بمحور واحد.

الموقع الذي تقف فيه الشركات هو بالضبط منتصف ذلك المقص. إن بنت الشركة بنيتها التحتية بنفسها، عليها تحمّل التكاليف المتصاعدة للطابق العلوي. وإن استخدمت النماذج فقط عبر واجهات برمجية خارجية، عليها أن تسلّم نفسها لسياسة تسعير طرف آخر ولمخاطر سيادة البيانات. فوق ذلك، DeepSeek نموذج صيني، وMeta تحولت إلى نموذج مغلق ومدفوع. في قطاعات مثل التمويل والقطاع العام، حيث لوائح فصل الشبكات وسيادة البيانات صارمة، يصعب الاستفادة من ذلك السعر الرخيص كما هو. حقيقة أن السعر رخيص وحقيقة أنه يمكن استخدامه بأمان مسألتان مختلفتان تماما.

## المقابض التي يجب الإمساك بها في منتصف المقص

يجدر هنا التوقف عند اعتراض شائع. بما أن DeepSeek أرخص بـ34 ضعفا وMeta طرحت ربع السعر، أفلا يكفي ببساطة اختيار أرخص واجهة برمجية خارجية واستخدامها؟ إذا نظرنا إلى السعر وحده، فهذا كلام معقول. لكن السعر الرخيص يأتي بشروط. DeepSeek نموذج صيني، وMeta تحولت من المصدر المفتوح إلى نموذج مغلق مدفوع، وأسعار كليهما يمكن أن ترتفع مجددا في أي وقت وفق ظروف المزوّد. تسليم بنية التكلفة بأكملها لسياسة تسعير طرف آخر ليس توفيرا، بل تبعية جديدة. التوفير الحقيقي لا يكتمل إلا حين تُدخل ذلك السعر الرخيص تحت سيطرتك أنت.

فما المتغيرات التي يمكن للشركات فعلا التحكم بها بين الشفرتين المتباعدتين؟ تركت الأخبار تلميحات. الدرس الجوهري من مقال مراكز بيانات الذكاء الاصطناعي كان أن وحدات معالجة الرسوميات التي أمّنتها الشركة لا قيمة لها إن لم تستطع تشغيلها. بمعنى آخر، المقبض الأول لامتصاص تكاليف الطابق العلوي هو الجدولة التي تقضي على الوقت الخامل. الدرس من حالة DeepSeek كان التوجيه، أي توزيع العمل بين نماذج رخيصة وأخرى مكلفة وفق صعوبة المهمة. المقبض الثاني هو التخصيص، اختيار النموذج المناسب لكل مهمة. الدرس من تحول Meta إلى التسعير المدفوع وانتشار النماذج الصينية كان أن امتصاص السعر الرخيص ضمن سيادة البيانات يتطلب تشغيل نماذج ذات أوزان مفتوحة مباشرة على بنية الشركة التحتية الخاصة. المقبض الثالث هو النشر المحلي والسيادي. وكما حدّد دليل اختبار الاختراق الأمني للذكاء الاصطناعي الصادر عن وزارة العلوم وتكنولوجيا المعلومات وKISA حقن التوجيهات وإساءة استخدام صلاحيات الوكيل كتهديدين معياريين، فإن المقبض الرابع هو السياسات والتدقيق التي تحصر التنفيذ بأمان.

صُمم Paxis، وهو Agent-Native Cloud الذي بنته ThakiCloud، ليتيح للمؤسسات الإمساك بهذه المقابض الأربعة بيد واحدة. يقوم CostRouter، الذي يختار النموذج المناسب لكل مهمة، بتوزيع أحمال العمل بين نماذج منخفضة التكلفة على طراز DeepSeek ونماذج عالية الأداء، محوّلا انهيار الأسعار في الطابق السفلي إلى وفورات فعلية في التكلفة. يقلّل التنفيذ داخل صندوق رملي معزول ونظام تعدد المستأجرين من الوقت الخامل لوحدات معالجة الرسوميات المؤمَّنة، مما يمتص تكاليف رأس المال في الطابق العلوي. تتيح بنية Kubernetes السيادية والمحلية تشغيل نماذج ذات أوزان مفتوحة مباشرة ضمن اللوائح المحلية، فتجمع بين السعر الرخيص وسيادة البيانات في آن واحد. أما الحوكمة التي تعامل Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى، وتقسّم مستوى الاستقلالية من L0 إلى L3، فتزرع بوابات السياسات وسجلات التدقيق التي يطالب بها دليل اختبار الاختراق داخل المنتج منذ البداية.

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
<div class="d3-arch" data-arch-root id="scissorsinfravsinference-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 978, "height": 664, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 507, "y": 24, "w": 205, "h": 126, "title": ["الطابق العلوي · ارتفاع", "تكاليف رأس مال البنية", "التحتية", "HBM4 53 دولارا للغيغابايت", "· رف بـ21 مليون دولار ·", "اختناق الطاقة"]}, {"id": "D", "x": 240, "y": 40, "w": 212, "h": 94, "title": ["الطابق السفلي · انهيار", "أسعار الاستدلال", "خفض DeepSeek 34 ضعفا · سعر", "Meta ربع السعر"]}, {"id": "E", "x": 379, "y": 242, "w": 198, "h": 94, "title": ["منتصف المقص · الشركة", "بنية تحتية مكلفة · سياسة", "تسعير طرف آخر · مخاطر", "سيادة البيانات"]}, {"id": "H1", "x": 762, "y": 414, "w": 156, "h": 78, "title": ["المقبض 1 · الجدولة", "إزالة وحدات معالجة", "الرسوميات الخاملة"]}, {"id": "H2", "x": 502, "y": 422, "w": 205, "h": 62, "title": ["المقبض 2 · التوجيه", "تخصيص النماذج حسب الصعوبة"]}, {"id": "H3", "x": 256, "y": 414, "w": 191, "h": 78, "title": ["المقبض 3 · محلي · سيادي", "تشغيل مباشر للأوزان", "المفتوحة"]}, {"id": "H4", "x": 24, "y": 414, "w": 177, "h": 78, "title": ["المقبض 4 · السياسات ·", "التدقيق", "حصر التنفيذ بأمان"]}, {"id": "P1", "x": 734, "y": 570, "w": 212, "h": 62, "title": ["صندوق Paxis الرملي المعزول", "· تعدد المستأجرين"]}, {"id": "P2", "x": 534, "y": 578, "w": 142, "h": 46, "title": "Paxis CostRouter"}, {"id": "P3", "x": 253, "y": 578, "w": 198, "h": 46, "title": "Paxis Kubernetes السيادي"}, {"id": "P4", "x": 38, "y": 578, "w": 149, "h": 46, "title": "حوكمة Paxis L0~L3"}], "edges": [{"src": "U", "dst": "E", "kind": "data", "label": "توأمان انبثقا من الطلب نفسه", "curve": [[610, 150], [610, 196], [610, 196], [545, 242]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "توأمان انبثقا من الطلب نفسه", "curve": [[346, 134], [346, 196], [346, 196], [411, 242]], "off": "50%"}, {"src": "E", "dst": "H1", "kind": "data", "curve": [[577, 313], [840, 375], [840, 375], [840, 414]]}, {"src": "E", "dst": "H2", "kind": "data", "curve": [[547, 336], [605, 375], [605, 375], [605, 422]]}, {"src": "E", "dst": "H3", "kind": "data", "curve": [[409, 336], [352, 375], [352, 375], [352, 414]]}, {"src": "E", "dst": "H4", "kind": "data", "curve": [[379, 312], [113, 375], [113, 375], [113, 414]]}, {"src": "H1", "dst": "P1", "kind": "data", "line": [840, 492, 840, 570]}, {"src": "H2", "dst": "P2", "kind": "data", "line": [605, 484, 605, 578]}, {"src": "H3", "dst": "P3", "kind": "data", "line": [352, 492, 352, 578]}, {"src": "H4", "dst": "P4", "kind": "data", "line": [113, 492, 113, 578]}]});
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
      const container = document.getElementById('scissorsinfravsinference-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'scissorsinfravsinference-1';
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

## كلما اتسع المقص، ازدادت أهمية المقابض

من المرجح أن يستمر رقما اليوم في التباعد أكثر. سيبقى عرض الذاكرة ضيقا حتى عام 2028، ويتطلب اختناق الطاقة سنوات من التراخيص، لذا لن ينخفض الطابق العلوي بسهولة. في المقابل، تواصل موجة الشرائح الخاصة والنماذج فائقة الرخص سحب الطابق السفلي إلى الأسفل. كلما حدث ذلك أكثر، لم تعد النتيجة تُحسم بالشفرتين نفسيهما، بل بالمقبض الذي يمسك المسافة بينهما. لهذا، عند قراءة رقمي سعر الرف وسعر الاستدلال، يجب أيضا قراءة الجدولة والتوجيه والسيادة والأمان الواقعة بينهما. لم تسأل أخبار اليوم أي نموذج فاز. بل سألت عن تكلفة تشغيل ذلك النموذج وطريقة التعامل مع تلك التكلفة. لتقف ثابتا في منتصف المقص، عليك أولا أن تتحقق من مكان مقابضك.

## المراجع

- [توقعات ببيع رف Nvidia Rubin Ultra بـ21 مليون دولار](https://tech.ifeng.com/c/8uco339RORc) · Ifeng
- [Bernstein تتوقع رف Nvidia Vera Rubin بـ9.1 مليون دولار... ارتفاع أسعار HBM4 يضغط على التكاليف](https://www.weeklypost.kr/news/articleView.html?idxno=11422) · Weekly Post
- ["جائزة الـ40 تريليون وون"، SK hynix تتجاوز حتى Alibaba... رقم قياسي](https://www.hankyung.com/article/2026071072846) · Hankyung
- [Micron توسّع استثمارها في أشباه الموصلات الأمريكية إلى 250 مليار دولار... بدء بناء مصنع نيويورك](https://www.thelec.net/news/articleView.html?idxno=12157) · TheElec
- [Samsung Electronics: "نطوّر تعبئة 2.xD تجمع HBM والمنطق والضوئيات السيليكونية"](http://inews24.com/view/1984212) · iNews24
- [DeepSeek تجعل خفض 75% دائما... تصاعد حرب أسعار الذكاء الاصطناعي](https://thenextweb.com/news/deepseek-v4-pro-75-percent-price-cut-permanent) · TheNextWeb
- [Meta تسعّر واجهة Muse Spark 1.1 بـ1.25/4.25 دولار لكل مليون رمز](https://aiweekly.co/alerts/meta-prices-muse-spark-11-api-at-125425-per-m-tokens) · AI Weekly
- [شرائح Meta الجديدة للذكاء الاصطناعي تبدأ الإنتاج في سبتمبر](https://techcrunch.com/2026/07/09/metas-new-ai-chips-will-begin-production-in-september/) · TechCrunch
- [الشركة الناشئة Lindy تتخلى عن Claude كليا لصالح DeepSeek موفرة ملايين الدولارات](https://the-decoder.com/ai-startup-lindy-ditched-claude-entirely-for-deepseek-saving-millions-as-cost-pressure-mounts-on-anthropic/) · The Decoder
- [وزارة العلوم وتكنولوجيا المعلومات وKISA تصدران "دليل اختبار الاختراق الأمني للذكاء الاصطناعي"](https://www.digitaltoday.co.kr/news/articleView.html?idxno=682799) · Digital Today
