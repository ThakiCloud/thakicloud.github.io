---
title: "في الأسبوع الذي انخفضت فيه أسعار التوكنات إلى النصف، قفزت قيمة رقاقات الاستدلال خمسة أضعاف"
excerpt: "عندما تنخفض الأسعار، هل نستهلك أقل؟ في سوق الاستدلال (inference) يحدث العكس تماما. نقرأ التناقض بين حرب أسعار التوكنات المخفضة إلى النصف وقفزة تقييم سامبانوفا خمسة أضعاف من خلال مفارقة جيفونز، ونستعرض إلى أين ينتقل الاختناق الحقيقي في الشركات."
seo_title: "حرب أسعار التوكنات وقفزة رقاقات الاستدلال 5 أضعاف: مفارقة جيفونز في عصر الذكاء الاصطناعي"
seo_description: "انخفض سعر التوكن الواحد إلى النصف بينما قفزت التكلفة الإجمالية للذكاء الاصطناعي لدى الشركات وارتفعت قيمة رقاقات الاستدلال خمسة أضعاف. من خلال حالات سامبانوفا وCXL وتحقق UST وClaude، نستعرض الاختناق الحقيقي في عصر الاستدلال وتحديات حوكمة الوكلاء."
date: 2026-07-12
last_modified_at: 2026-07-12
lang: ar
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
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/token-price-war-jevons-paradox-inference/"
---

![مخطط مفاهيمي يوضح أنه كلما تدفقت التوكنات الرخيصة كالفيضان، ارتفعت قيمة البنية التحتية للاستدلال أسفلها نحو الأعلى]({{ '/assets/images/token-price-war-jevons-paradox-inference-hero.webp' | relative_url }})

## خبران متناقضان وصلا في الأسبوع نفسه

وصل هذا الأسبوع إلى صفحات الذكاء الاصطناعي خبران يبدوان متناقضين جنبا إلى جنب. الأول خبر انخفاض الأسعار. طرحت OpenAI نموذج GPT-5.6 بثلاث فئات تسعير هي سول (Sol) وتيرا (Terra) ولونا (Luna)، ووضعت الفئة المتوسطة تيرا بنصف سعر الجيل السابق. أما DeepSeek V4-Pro فقد ضاهى أداء البرمجة في Claude Opus 4.7 بسعر يتراوح بين 10% و20% منه فقط، بينما طرحت MiniMax M2.7 سعرا يصل إلى ثلث سعر نظيراتها من الفئة نفسها. تصف الصناعة هذه المرحلة صراحة بـ"حرب التوكنات" (token war).

والخبر الآخر خبر ارتفاع الأسعار. حصلت شركة سامبانوفا (SambaNova)، الناشئة المتخصصة في رقاقات الاستدلال المخصصة، على تقييم بلغ 11 مليار دولار (نحو 16 تريليون وون)، بعد أن جمعت مليار دولار في الإغلاق الأول من جولة السلسلة F. وكان تقييمها في جولة السلسلة E قبل خمسة أشهر فقط 2.2 مليار دولار، أي أن قيمتها قفزت خمسة أضعاف خلال خمسة أشهر. سعر التوكن الواحد انخفض إلى النصف، لكن قيمة الشركة التي تصنع الرقاقة التي تُنتج ذلك التوكن ارتفعت خمسة أضعاف. فهل أحد الخبرين خاطئ؟ لا. فالخبران صورتان لتيار واحد، واحدة من الأمام والأخرى من الخلف.

## القانون القديم القائل بأن انخفاض السعر يزيد الاستهلاك

في القرن التاسع عشر، قلب الاقتصادي البريطاني ويليام جيفونز (William Jevons) الاعتقاد السائد بأن محرك البخار الأكثر كفاءة في استهلاك الفحم سيقلل من استهلاكه. فحين انخفض سعر الوقود، لم يوفر الناس، بل شغّلوا عددا أكبر من الآلات، فارتفع الاستهلاك الإجمالي للفحم فعليا. هذه المفارقة، التي تقول إن انخفاض سعر وحدة المورد يؤدي إلى زيادة إجمالي استهلاكه، تتكرر اليوم في سوق الاستدلال (inference) وكأنها مثال من كتاب مدرسي.

"مفارقة التوكن" التي رصدتها Digital Daily تجسد هذه الفكرة تماما. فمنذ عام 2023 ينخفض سعر التوكن الواحد باستمرار، لكن التكلفة الإجمالية للذكاء الاصطناعي التي تتحملها الشركات ترتفع بشدة. والمتهم هو وكلاء الذكاء الاصطناعي (AI agents). فالوكيل الذي يبحث بنفسه ويستدعي الأدوات وينجز العمل عبر خطوات متعددة يستهلك ما لا يقل عن 50 ضعفا وقد يصل إلى 500 ضعف عدد التوكنات التي يستهلكها روبوت محادثة يجيب مرة واحدة عن سؤال واحد، لكل مهمة واحدة. وتتوقع Goldman Sachs أن يرتفع الاستهلاك الشهري العالمي للتوكنات من 5 كوادريليون توكن شهريا هذا العام إلى 120 كوادريليون توكن شهريا بحلول عام 2030، أي بمقدار 24 ضعفا. فإذا انخفض السعر إلى النصف بينما يقفز الاستهلاك عشرين ضعفا، تصبح الفاتورة عشرة أضعاف. فكلما اشتدت المنافسة على خفض الأسعار، كبر الإنفاق الإجمالي أكثر.

## الاختناق ينتقل من الأسفل إلى الأعلى

من هنا يتضح بسهولة سبب ارتفاع تقييم سامبانوفا. فإذا كان استخدام التوكنات سيصل إلى حجم لا يُحصى، فإن قيمة الأجهزة القادرة على إنتاج التوكن الواحد بتكلفة أقل وسرعة أعلى ترتفع في المقابل. وتوضح الشركة أن بنيتها المعمارية الخاصة RDU (بدلا من وحدات معالجة الرسوميات GPU)، في أحدث رقاقاتها SN40 وSN50، ترفع أداء فك الترميز (decode) في استدلال النماذج اللغوية الكبيرة بمقدار 5 إلى 10 أضعاف مقارنة بوحدات GPU من Nvidia، ما يخفض التكلفة لكل توكن. واللافت أن JPMorgan Chase قرر بناء بنية تحتية للاستدلال داخل مركز بياناته الخاص (on-premise) باستخدام هذه الرقاقة لمعالجة بيانات مالية حساسة، وهو ما يحمل دلالة خاصة، إذ يعني أن التدريب لم يعد هو الوجهة التي تمتص رأس المال الضخم، بل الاستدلال، وتحديدا الاستدلال على البنية التحتية الداخلية في الصناعات الخاضعة للتنظيم.

ويظهر الضغط نفسه في الذاكرة أيضا. فنتائج تقييم تقنية CXL التي كشفت عنها سامسونج إلكترونيكس هذا الأسبوع تُظهر أن الطلب على سعة ذاكرة التخزين المؤقت للمفاتيح والقيم (KV cache) التي تحفظ سياق المحادثة في استدلال الذكاء الاصطناعي انفجر إلى مئات الجيجابايت، ما كشف عن اختناق يصعب على ذاكرة HBM المرفقة بوحدة GPU وحدها استيعابه. فقد انهار أداء ذاكرة DRAM بسعة 512 جيجابايت عندما فاض حجم KV cache عن حدها، في حين حافظ تجمع ذاكرة CXL بسعة تيرابايت واحد على 92% من أداء DRAM حتى في بيئة مكونة من 8 وحدات GPU. وتتوقع مؤسسة الأبحاث Yole أن ينمو سوق CXL من 2.1 مليار دولار هذا العام إلى نحو 16 مليار دولار بحلول عام 2028. وإذا كانت HBM قد حلت مشكلة عرض النطاق الترددي (bandwidth)، فإن CXL أصبحت تتموضع كمكمل يحل مشكلتي السعة والتكلفة.

وتتأكد هذه الطفرة في الطلب من خلال مؤشرات حقيقية أيضا. فقد بلغت صادرات تايوان في يونيو 748 مليار دولار، وهي ثالث أكبر رقم شهري في تاريخها، ودفعت شحنات منتجات تقنية المعلومات والاتصالات، التي تشمل بطاقات الرسوميات وخوادم الذكاء الاصطناعي، هذا الأداء بارتفاع بلغ 72.3% على أساس سنوي. وخلف هذا الرقم يقف الطلب على ذاكرة HBM وتقنية التغليف المتقدم CoWoS. ومن هذا المنطلق أيضا عرض تشوي تاي وون (Chey Tae-won)، رئيس مجموعة SK، مباشرة أمام مستثمرين عالميين مخططا لأشباه موصلات الذكاء الاصطناعي محوره الريادة في HBM. فكلما أصبحت التوكنات أكثر وفرة، أصبحت الرقاقات والذاكرة القادرة على استيعابها أكثر ندرة. إنها صورة اختناق ينتقل من الأسفل إلى الأعلى، مباشرة تحت الطبقة التي تنخفض فيها الأسعار.

## الأغلى فعلا ليس التوكن، بل التنفيذ الذاتي المستقل

لكن كون الاختناق لا يتوقف عند الأجهزة وحدها هو الإشارة الحقيقية في أخبار اليوم. فلننظر إلى حالة UST التي تعاونت مع Anthropic لربط Claude بعملية التحقق من صحة أشباه الموصلات (semiconductor verification). يقرأ Claude Code مباشرة مخططات دبابيس الرقاقة (pinout) والدوائر الكهربائية للأجهزة، ويكتب بنفسه اختبارات الانحدار (regression tests) التي كان المهندسون يكتبونها يدويا وينفذها، ويقارن بيانات الأجهزة الفعلية بالتوأم الرقمي (digital twin) ليكتشف العيوب تلقائيا. وقد تقلصت مدة دورة التحقق التي كانت تستغرق عادة أربعة أيام إلى 48 ساعة، وانخفض زمن دورة التحقق بنسبة تتراوح بين 50% و70%. لم يعد الوكيل مجرد أداة إكمال تلقائي للكود، بل أصبح عاملا يُنجز عملية هندسية فعلية بشكل مستقل ضمن حلقة مغلقة (closed loop).

ويسير القطاع المصرفي المحلي في الاتجاه نفسه. أنفق بنك Woori 88.4 مليار وون لربط أكثر من 175 وكيلا بـ29 مهمة موزعة على خمسة مجالات رئيسية، بينما يعمل KB Financial على بناء نحو 300 وكيل لتغطية 59 مهمة خلال العام الحالي استهدافا لما يسمى "الخدمات المصرفية القائمة على الوكلاء" (Agentic Banking). أما بنك Hana فقد اختصر كتابة رأي تقييم الجدارة الائتمانية للشركات من متوسط 30 دقيقة إلى نحو 10 ثوان، ما يُتوقع أن يوفر أكثر من 27 ألف ساعة عمل سنويا. وعندما تبدأ الوكلاء بهذا الحجم بالتدخل مباشرة في أعمال جوهرية مثل التقييم وإدارة الأصول والرقابة الداخلية، يتغير السؤال الذي يقلق الإدارة التنفيذية ليلا. فلم يعد السؤال "كم يبلغ سعر التوكن؟"، بل أصبح "من يتحكم في هذه المئات من عمليات التنفيذ الذاتي وكيف يُراجعها؟". ومن هنا برز التحدي التالي المتمثل في كيفية دمج مبدأ الموافقة المزدوجة الذي حافظ عليه القطاع المصرفي طويلا مع هذه الوكلاء.

ويتزايد ثقل الرقابة التنظيمية أيضا. فقد بدأت الصين تنفيذ تدابير إدارة التفاعل المُؤَنسَن (anthropomorphized interaction) للذكاء الاصطناعي، التي أعدّتها خمس جهات حكومية بالتشارك، اعتبارا من 15 يوليو، وبدأت ByteDance وAlibaba بإلغاء ميزات الشخصيات المخصصة (custom persona) في روبوتات المحادثة تماشيا مع ذلك. وهذه حالة تدفع فيها متطلبات السلامة مباشرة إلى مرحلة تصميم الخدمة نفسها، لذلك يصعب على مشغلي الخدمات المحليين اعتبارها شأنا لا يعنيهم. ويتقاطع مع هذا نقاش الذكاء الاصطناعي السيادي (sovereign AI). فبعد أن قيّدت الولايات المتحدة، بذريعة الأمن القومي، وصول Claude Fable 5 من الخارج ثم أعادت فتحه، وبعد أن بدأت الصين مراجعة تقييد الوصول الخارجي لنماذجها المحلية، أخذ عصر إمكانية استخدام نماذج الذكاء الاصطناعي الحدودية من أي مكان بالأفول. فامتلاك نموذج بمستوى حدودي داخل الحدود الوطنية مباشرة يتطلب رأس مال ووقتا هائلين، ومع ذلك بدأت راحة استعارة نماذج رخيصة من الخارج تصطدم وجها لوجه مع السيادة التي تسعى لإبقاء البيانات الحساسة داخل الحدود.

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
<div class="d3-arch" data-arch-root id="arjevonsparadoxinference-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 999, "height": 1210, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 377, "y": 24, "w": 198, "h": 94, "title": ["حرب التوكنات · منافسة", "النماذج بنصف السعر", "GPT-5.6 Terra · DeepSeek", "V4-Pro · MiniMax M2.7"]}, {"id": "B", "x": 402, "y": 196, "w": 149, "h": 46, "title": "انخفاض سعر التوكن"}, {"id": "C", "x": 374, "y": 320, "w": 205, "h": 78, "title": ["مفارقة جيفونز", "الوكلاء يستهلكون 50 إلى", "500 ضعف التوكنات لكل مهمة"]}, {"id": "D", "x": 370, "y": 476, "w": 212, "h": 94, "title": ["ارتفاع حاد في إجمالي", "استهلاك التوكنات", "توقع Goldman Sachs بارتفاع", "24 ضعفا بحلول 2030"]}, {"id": "E", "x": 374, "y": 648, "w": 205, "h": 62, "title": ["انتقال الاختناق من الأسفل", "إلى الأعلى"]}, {"id": "F", "x": 623, "y": 796, "w": 198, "h": 94, "title": ["قفزة في قيمة رقاقات", "الاستدلال", "SambaNova RDU فك ترميز 5", "إلى 10 أضعاف"]}, {"id": "G", "x": 391, "y": 804, "w": 177, "h": 78, "title": ["تخفيف اختناق الذاكرة", "تجمع CXL يؤمّن سعة KV", "cache"]}, {"id": "H", "x": 124, "y": 788, "w": 212, "h": 110, "title": ["الاختناق الحقيقي · التنفيذ", "الذاتي والتحكم", "تحقق UST المستقل · مئات", "الوكلاء المصرفية · التنظيم", "السيادي"]}, {"id": "P", "x": 384, "y": 976, "w": 191, "h": 62, "title": ["ThakiCloud Paxis ·", "Agent-Native Cloud v1.1"]}, {"id": "P1", "x": 755, "y": 1116, "w": 212, "h": 62, "title": ["CostRouter · توجيه النموذج", "حسب المهمة"]}, {"id": "P2", "x": 495, "y": 1124, "w": 205, "h": 46, "title": "تنفيذ في صندوق رملي معزول"}, {"id": "P3", "x": 256, "y": 1116, "w": 184, "h": 62, "title": ["بوابات السياسات وسجلات", "التدقيق"]}, {"id": "P4", "x": 24, "y": 1116, "w": 177, "h": 62, "title": ["Kubernetes سيادي داخل", "المنشأة"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [476, 118, 476, 196]}, {"src": "B", "dst": "C", "kind": "data", "line": [476, 242, 476, 320]}, {"src": "C", "dst": "D", "kind": "data", "line": [476, 398, 476, 476]}, {"src": "D", "dst": "E", "kind": "data", "line": [476, 570, 476, 648]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[579, 708], [722, 749], [722, 749], [722, 796]]}, {"src": "E", "dst": "G", "kind": "data", "line": [478, 710, 480, 804]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[374, 708], [230, 749], [230, 749], [230, 788]]}, {"src": "F", "dst": "P", "kind": "data", "curve": [[722, 890], [722, 937], [722, 937], [575, 979]]}, {"src": "G", "dst": "P", "kind": "data", "line": [480, 882, 480, 976]}, {"src": "H", "dst": "P", "kind": "data", "curve": [[230, 898], [230, 937], [230, 937], [384, 980]]}, {"src": "P", "dst": "P1", "kind": "data", "curve": [[575, 1025], [861, 1077], [861, 1077], [861, 1116]]}, {"src": "P", "dst": "P2", "kind": "data", "curve": [[532, 1038], [598, 1077], [598, 1077], [598, 1124]]}, {"src": "P", "dst": "P3", "kind": "data", "curve": [[421, 1038], [348, 1077], [348, 1077], [348, 1116]]}, {"src": "P", "dst": "P4", "kind": "data", "curve": [[384, 1025], [113, 1077], [113, 1077], [113, 1116]]}]});
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
      const container = document.getElementById('arjevonsparadoxinference-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arjevonsparadoxinference-1';
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

## فيضان التوكنات الرخيصة يحتاج إلى أنابيب مياه

وتؤكد حسابات كبرى شركات التقنية هذا الضغط أيضا. فقد بلغ إجمالي الإنفاق الرأسمالي المجمّع لشركات Alphabet وMicrosoft وMeta وAmazon لعام 2026 نحو 725 مليار دولار، وهو رقم قياسي غير مسبوق يمثل 30% من الإيرادات، بينما تراجع إجمالي التدفق النقدي الحر (free cash flow) لهذه الشركات مجتمعة إلى أدنى مستوى له منذ نحو عشر سنوات. فقد انخفض التدفق النقدي الحر لأمازون على أساس الاثني عشر شهرا الأخيرة من 25.9 مليار دولار قبل عام واحد إلى 1.2 مليار دولار فقط، أي بانخفاض نسبته 95%. فالمؤسسة التي تكتفي بترك فيضان التوكنات الرخيصة يتدفق دون تحكم، ستنهار أمام الفاتورة أولا. وما تحتاجه ليس أنبوبا أكبر قطرا، بل شبكة أنابيب مصممة جيدا لتوزيع هذا الفيضان بأمان.

ومنتج Paxis من ThakiCloud هو بالضبط المنتج الرسمي الذي يستهدف هذه الشبكة، أي Agent-Native Cloud v1.1. فالنماذج بنصف السعر التي أطلقتها حرب التوكنات ليست تهديدا من منظور CostRouter، بل سلاحا. فتوجيه المهام البسيطة والمتكررة إلى نماذج خفيفة منخفضة التكلفة، وتوجيه الاستدلال المعقد فقط إلى النماذج الحدودية، وتقسيم ذلك حسب كل مهمة على حدة، يمكن أن يكبح بنيويا فاتورة مفارقة جيفونز. وبالنسبة لوكيل مثل UST الذي يقرأ المخططات مباشرة، يصبح التنفيذ في صندوق رملي (sandbox) معزول هو الحل، بينما تصبح بوابات السياسات وسجلات التدقيق وحوكمة الاستقلالية المقسّمة من L0 إلى L3 بديلا آمنا لمبدأ الموافقة المزدوجة في نشر مئات الوكلاء على طريقة بنك Woori. وما أظهرته سامبانوفا وJPMorgan من طلب على الاستدلال داخل المنشأة (on-premise)، ونقاش السيادة المتجه نحو الذكاء الاصطناعي السيادي، يتقاطعان مباشرة مع تصميم Paxis الذي يتعامل مع Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى فوق Kubernetes سيادي داخل المنشأة.

وخلاصة القول: كلما رخصت التوكنات، استهلكناها أكثر وبشكل أكثر استقلالية، وكلما حدث ذلك، انتقل الاختناق والمخاطر من مستوى السعر إلى مستوى التنفيذ والتحكم. وهنا يكمن السبب في أن خبر منافسة الأسعار بالنصف وخبر ارتفاع القيمة خمسة أضعاف لم يكونا متناقضين، بل كانا وجهين لجسد واحد. ففي عالم انخفضت فيه الأسعار، لن يفوز من يوفر التوكنات أكثر من غيره، بل من يُحكم السيطرة على فيضان التوكنات المتدفق بأمان أكثر من غيره.

## المراجع

- [حرب التوكنات تجتاح صناعة الذكاء الاصطناعي، ومفارقة سعر التوكن الأخف والفاتورة الأثقل (Digital Daily)](https://www.ddaily.co.kr/page/view/2026071016360758815)
- [تفاصيل خطة تسعير OpenAI GPT-5.6 بثلاث فئات (eesel.ai)](https://www.eesel.ai/blog/gpt-5-6-pricing)
- [سامبانوفا تجمع مليار دولار بتقييم 11 مليار دولار في الإغلاق الأول من السلسلة F (TechCrunch)](https://techcrunch.com/2026/07/08/sambanova-draws-1b-at-11b-valuation-in-series-f-first-close/)
- [رقاقة SambaNova SN50 RDU المخصصة للاستدلال الوكيلي واعتماد JPMorgan لها داخل المنشأة (SambaNova)](https://sambanova.ai/blog/introducing-the-sn50-rdu-purpose-built-for-agentic-inference)
- [حل اختناق استدلال الذكاء الاصطناعي عبر CXL، وتسريع سامسونج نحو الجيل التالي من HBM (Herald Economy)](https://biz.heraldcorp.com/article/10805245)
- [صادرات تايوان في يونيو تبلغ 74.8 مليار دولار مدفوعة بخوادم الذكاء الاصطناعي (Seoul Economic Daily)](https://www.sedaily.com/article/20066169)
- [تشوي تاي وون: استثمار مئات المليارات من الدولارات في الذكاء الاصطناعي مع استمرار نقص إمدادات HBM (Financial News)](https://www.fnnews.com/news/202607110443238428)
- [شراكة UST وAnthropic للتحقق من صحة أشباه الموصلات باستخدام Claude (Anthropic)](https://www.anthropic.com/news/ust-claude)
- [بنك Woori ينفق 88.4 مليار وون لبناء 175 وكيل ذكاء اصطناعي (BIkorea)](https://m.bikorea.net/news/articleView.html?idxno=45433)
- [الصين تنفذ تدابير إدارة التفاعل المُؤَنسَن للذكاء الاصطناعي، وروبوتات المحادثة توقف ميزات الشخصيات المخصصة (ZDNet Korea)](https://zdnet.co.kr/view/?no=20260707224246)
- [استثمارات كبرى شركات التقنية 725 مليار دولار في الذكاء الاصطناعي بينما يهبط التدفق النقدي الحر إلى أدنى مستوى منذ أكثر من عقد (Financial News)](https://www.fnnews.com/news/202605111154590244)
