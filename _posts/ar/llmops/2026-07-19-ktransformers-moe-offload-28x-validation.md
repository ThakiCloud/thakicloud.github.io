---
title: "خزانة بقيمة 400 ألف دولار على بطاقة رسومات بسعة 24 جيجابايت؟ أعدنا إنتاج \"28 ضعفاً\" الخاصة بـ ktransformers بأنفسنا"
excerpt: "تدّعي ktransformers أنه يمكنك تشغيل نموذج MoE ضخم على بطاقة GPU واحدة بسعة 24 جيجابايت عبر نقل الخبراء (experts) إلى وحدة المعالجة المركزية. اختبرنا الادعاءات الرائجة \"28 ضعفاً\" و\"400 ألف دولار إلى 24 جيجابايت\" باستئجار وحدات GPU من RunPod مرتين، بتكلفة تقارب 5 دولارات. الحيلة كانت حقيقية، لكن الرقم كان قائماً على ثلاثة افتراضات خفية."
date: 2026-07-19
tags:
  - ktransformers
  - MoE
  - LLM서빙
  - GPU
  - AMX
  - LLMOps
  - 벤치마크
  - 인프라
author_profile: true
toc: true
toc_label: "تشريح الـ 28 ضعفاً"
published: true
categories:
  - llmops
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/ktransformers-moe-offload-28x-validation/"
---

كُتب هذا المقال للمهندسين الذين يفكرون في استضافة نموذج MoE بأنفسهم، وكذلك لمسؤولي البنية التحتية الذين عليهم أن يقرروا إلى أي مدى يثقون بموجة التغريدات الحالية التي تقول "شغّل نموذجاً ضخماً على GPU واحدة". باختصار: حيلة ktransformers حقيقية وتعمل فعلاً. لكن عبارتي "28 ضعفاً" و"خزانة بقيمة 400 ألف دولار على بطاقة واحدة بسعة 24 جيجابايت" اللتين انتشرتا تقومان كل منهما على افتراض خفي. إليكم ما هي هذه الافتراضات، بناءً على قياسات من عمليتي استئجار GPU منفصلتين على RunPod.

## ما الذي أثار الجدل

فكرة ktransformers (kvcache-ai/ktransformers، رخصة Apache 2.0، 17 ألف نجمة)، التي أصدرها مختبر MADSYS في جامعة تسينغهوا، يمكن تلخيصها في جملة واحدة. في نموذج MoE، أبقِ فقط الخبراء الذين يتم استدعاؤهم فعلياً بالقرب من GPU، وضع الخبراء الخاملين معظم الوقت في ذاكرة CPU، مع استدعائهم فقط عند الحاجة. بهذا الترتيب، يُقال إن DeepSeek-V3 وR1 يعملان على 24 جيجابايت من VRAM بسياق يبلغ 139 ألف رمز، وبسرعة تصل إلى 28 ضعفاً مقارنة بالإعداد القياسي.

الحيلة نفسها بسيطة إلى حد يثير الريبة. وهذا بالضبط ما جعلها مثيرة للشك. الطريقة الوحيدة لمعرفة ما إذا كانت هذه وجبة مجانية حقيقية، أو ما إذا كانت هناك فاتورة مخفية في مكان ما، هي استخراج الأرقام بأنفسنا.

## تصميم التجربة: عزل الآلية باستخدام نموذج أصغر

DeepSeek-V3 يبلغ حجمه 671 مليار معامل، أي أنه لن يتسع على بطاقة بسعة 24 جيجابايت. استخدمنا Qwen3-30B-A3B (بإجمالي 30 مليار معامل، منها 3.3 مليار نشطة) كنموذج بديل، وهو نسخة مصغّرة من نفس العائلة (MLA مع MoE دقيق التحبيب). لم يكن الهدف إعادة إنتاج أرقام المُورّد الخاصة بنموذج 671 مليار معامل، بل معرفة ما إذا كانت آلية "نقل الخبراء إلى CPU" تحقق فائدة فعلية، وإذا كانت كذلك، تفكيك مصدر هذه الفائدة.

قسّمنا القياس إلى مرحلتين. أولاً، اختبرنا الآلية نفسها على جهاز AMD جاهز تجارياً. ثانياً، قسنا بشكل منفصل نواة Intel AMX التي تدّعي ktransformers أنها مصدر الأداء.

## المرحلة الأولى: قياس الآلية على بطاقة 4090 تجارية مع AMD

استأجرنا RTX 4090 (بسعة 24 جيجابايت) مع معالج AMD Ryzen 9 7950X و188 جيجابايت من الذاكرة العشوائية على RunPod. هنا ظهر الافتراض الخفي الأول على الفور. نواة الخبراء الخاصة بـ CPU في ktransformers مُحسّنة لتعليمات Intel AMX، وهذا المعالج من AMD لا يملك AMX. لذلك، بدلاً من نواة ktransformers الخاصة، قسنا الآلية بشكل نظيف باستخدام خاصية `--n-cpu-moe` في llama.cpp (الخبراء على CPU، والانتباه (attention) وذاكرة KV المؤقتة على GPU)، التي تنفّذ نفس الحيلة تماماً.

قمنا بضغط (quantize) Qwen3-30B-A3B إلى Q4 وقارنّا سرعة فك الترميز (decode) عبر ثلاثة أوضاع.

| الوضع | سرعة فك الترميز |
|---|---|
| النموذج بالكامل على GPU (full-GPU) | 261.5 tok/s |
| الخبراء على CPU، والانتباه على GPU (الآلية) | 12.0 tok/s |
| الكل على CPU (CPU-only) | 7.4 tok/s |

يظهر هنا أمران. الآلية أسرع بـ 1.62 ضعفاً من CPU الخالص. نقل الانتباه إلى GPU حقق فائدة فعلية. لكن عندما يتسع النموذج بالكامل في VRAM (نسخة Q4 حجمها 18 جيجابايت، وهي تتسع في 24 جيجابايت)، تفوّق full-GPU على الآلية بـ 22 ضعفاً. بمعنى آخر، إذا كان النموذج يتسع على GPU، فإن نقل الخبراء إلى CPU خيار خاسر. هذه الحيلة لا تكتسب معناها إلا في اللحظة التي يتجاوز فيها النموذج سعة VRAM. في تلك الحالة، القيمة تكمن في "أنه يعمل أصلاً، ولو بسرعة 12 tok/s"، وليس في السرعة بحد ذاتها.

## المرحلة الثانية: قياس المضاعف الحقيقي لنواة Intel AMX

لمواجهة نواة AMX مباشرة، وهي المصدر المزعوم للـ 28 ضعفاً، احتجنا إلى معالج Xeon من جيل Sapphire Rapids. بعد تشغيل عدة نسخ من H100 pods على RunPod والتحقق من معالجاتها، حصلنا على مضيف يحتوي على Intel Xeon Platinum 8470 (يدعم AMX bf16/int8/tile)، و208 نواة معالجة افتراضية، و1 تيرابايت من الذاكرة العشوائية.

حزمة kt_kernel تضم أنوية لكل خلفية (backend)، لذا استطعنا داخل نفس العملية تشغيل نواة AMX ونواة AVX2 جنباً إلى جنب على نفس أوزان BF16. قسنا عمليات التمرير الأمامي (forward pass) لـ MoE بحجم يعادل DeepSeek-V3 (256 خبيراً، وبُعد مخفي 7168) باستخدام كلا النواتين.

| النواة (BF16 مطابقة، فك ترميز) | السرعة |
|---|---|
| AMX (AMXBF16_MOE) | 145.5 tok/s |
| AVX2 (AVX2BF16_MOE) | 105.5 tok/s |

كانت نواة AMX أسرع من AVX2 بـ 1.38 ضعفاً. فائدة واضحة، لكنها بعيدة كل البعد عن 28 ضعفاً. استخدام عمليات التبليط (tile) الخاصة بـ INT8 وحدها قد يوسّع هذه الفجوة أكثر (اقتصرنا في هذه الجولة على مقارنة BF16 بنفس مستوى الدقة بسبب التكلفة)، لكن نواة واحدة بمفردها لا تنتج مضاعفاً بـ 28 ضعفاً.

## عند تفكيك "28 ضعفاً"

عند دمج التجربتين معاً، يتضح كيف تتكوّن الـ 28 ضعفاً التي أعلن عنها المُورّد. هذا الرقم ليس سحر نواة واحدة، بل هو مقارنة للنظام بأكمله مع تنفيذ llama.cpp الخالص على CPU. عند التفكيك، يبدو الأمر كالتالي.

نقل الانتباه وذاكرة KV المؤقتة إلى GPU هو الرافعة الأكبر بلا منازع. على جهاز AMD التجاري، حقق هذا الترتيب وحده مكسباً بـ 1.62 ضعفاً مقارنة بـ CPU الخالص، وعندما يتسع النموذج على GPU، تتسع هذه الفجوة إلى 35 ضعفاً. فوق ذلك، تضيف نواة الخبراء AMX نحو 1.4 ضعف إضافي مقارنة بـ AVX2. يُضاف إلى ذلك ضغط INT8/INT4 وتحسينات خط الأنابيب (pipeline). كل عامل على حدة مضاعف متواضع، لكن في ظروف معينة تتضاعف هذه العوامل معاً لتُنتج مكسباً من رتبتين عدديتين. تلك الظروف هي: أن يتجاوز النموذج سعة VRAM، وأن يدعم المعالج AMX، وأن يكون معيار المقارنة هو llama.cpp الخالص على CPU.

## حقيقة "400 ألف دولار إلى 24 جيجابايت"

هذه العبارة لا تُلغي الذاكرة، بل تنقلها. كانت وحدتا الحوسبة لدينا تملكان 188 جيجابايت و1 تيرابايت من ذاكرة النظام على التوالي. تشغيل DeepSeek-V3 بضغط Q4 يتطلب نحو 380 جيجابايت من DRAM على جانب CPU. أوزان الخبراء لا تختفي، بل تنتقل فقط من VRAM إلى ذاكرة النظام. لذا فإن الوصف الدقيق هو "بطاقة GPU واحدة بسعة 24 جيجابايت زائد خادم بذاكرة عشوائية ضخمة". تم استبدال بطاقة GPU باهظة الثمن بذاكرة عشوائية رخيصة، وليس تقليل إجمالي الاحتياج من الذاكرة. هذا يختلف عن الصورة القائلة إن بطاقة استهلاكية واحدة بسعة 24 جيجابايت تحل محل خزانة كاملة في مركز بيانات.

## إذن، كم tok/s فعلياً، وبأي تكلفة

فكّكت التجارب السابقة الآلية، لكنها أغفلت الرقمين اللذين يهمّان الممارسين فعلياً: ما مدى سرعة نموذج كبير حقيقي، وكم من المال يوفّر ذلك فعلاً. لذا أعدنا القياس في الإعداد الذي تكون فيه ktransformers ذات معنى فعلاً: معالج خادم متعدد الأنوية (Intel Xeon Platinum 8570، يدعم AMX، 224 نواة)، و2 تيرابايت من ذاكرة النظام، وقرص NVMe محلي، وبطاقة GPU واحدة. النموذج هو Qwen3-235B-A22B (بضغط Q4، بحجم يقارب 130 جيجابايت)، وهو لا يتسع لا على بطاقة 24 جيجابايت ولا على بطاقة واحدة بسعة 80 جيجابايت. هذه حالة يكون فيها النقل (offload) ضرورة لا خياراً.

أولاً، يتم التحقق من صحة الادعاء المتعلق بالعتاد. عند نقل جميع الخبراء إلى CPU، لا تتجاوز ذاكرة GPU المستخدَمة 11 جيجابايت. أي أن نموذجاً من فئة 235 مليار معامل يستهلك فقط 11 جيجابايت من ذاكرة GPU. هذا يتسع ليس فقط على 24 جيجابايت، بل على بطاقة بسعة 12 جيجابايت أيضاً. صورة "تشغيل نموذج من فئة 671 مليار معامل على خادم كبير مع بطاقة 4090 واحدة" تتحقق فعلياً.

المشكلة تكمن في السرعة. عند تحميل نفس النموذج بالكامل على 2×A100 بسعة 80 جيجابايت، يبلغ فك الترميز 51.5 tok/s، وهذا كافٍ بشكل مريح لمحادثة فورية. لكن حالة النقل، حيث الخبراء على CPU، عالم مختلف تماماً. قسنا ذلك بطريقتين مستقلتين، وكانت النتيجتان من رتبة عددية واحدة (خانة آحاد). تشغيل llama.cpp من البداية للنهاية يعطي 1.2 tok/s. وقياس حساب الخبراء فقط باستخدام نواة AMX الفعلية الخاصة بـ ktransformers (kt_kernel) يعطي 3.8 tok/s بمعيار BF16. حتى مع وضع بعض الخبراء على بطاقة GPU بسعة 24 جيجابايت، ترتفع النتيجة قليلاً فقط من 1.2 إلى 1.5.

لماذا لا يمكن لتغيير النواة كسر حاجز الخانة الآحادية. لأن العنق الحقيقي للزجاجة هو حساب 22 مليار معامل نشط على CPU في كل رمز. صحيح أن نواة AMX أسرع من AVX2 بنحو 1.3 ضعف، لكن هذا المضاعف لا يكفي لتجاوز الجدار. أرقام 8 إلى 15 tok/s التي أعلنتها ktransformers علناً (استناداً إلى DeepSeek-V3 الأكبر) تجمع ضغط INT4 وتوزيع الخبراء على GPU وخط الأنابيب معاً، وحتى هذا الرقم هو رقم إنتاجية دفعية (batch)، وليس سرعة خدمة تفاعلية.

هذا الرقم يقلب الاستنتاج. عند حساب التكلفة لكل مليون رمز باستخدام أسعار الإيجار الفعلية في RunPod، تكون النتيجة كالتالي.

| الإعداد | العتاد | التكلفة بالساعة | فك الترميز | التكلفة لكل مليون رمز |
|---|---|---|---|---|
| Full-GPU | 2×A100 80GB | نحو 3 دولارات | 51.5 tok/s | نحو 16 دولاراً |
| Offload | خادم AMX + بطاقة GPU واحدة | نحو 3 دولارات | نحو 2 إلى 4 tok/s | نحو 80 إلى 280 دولاراً |

على أساس الإيجار، يكلف النقل (offload) أكثر بـ 5 إلى 17 ضعفاً لكل رمز. إنها ليست، بأي معنى، أداة لخفض تكاليف تشغيل السحابة. وفوق ذلك، خادم AMX الكبير نفسه ليس رخيصاً. RunPod لا يوفر أصلاً تركيبة "بطاقة 4090 رخيصة مع خادم AMX كبير"، لذا يأتي AMX دائماً مرتبطاً ببطاقات GPU الخاصة بمراكز البيانات.

إذن، المكان الوحيد الذي تنجح فيه الاقتصاديات هو داخل المنشأة، على خادم تملكه بالفعل. إذا كان لديك بالفعل خادم Xeon كبير قيد التشغيل، فإن إضافة بطاقة 4090 بقيمة 1,600 دولار فوق تلك التكلفة الغارقة لتشغيل نموذج من فئة 671 مليار معامل بشكل دفعي، أرخص بكثير من شراء بطاقتي A100 جديدتين بقيمة 30 ألف دولار. إنها ليست أداة لخفض تكاليف التشغيل، بل أداة تُغيّر، على العتاد الذي تملكه أصلاً، الحد الفاصل بين "يعمل" و"لا يعمل". واستخدامها ليس في الخدمة الفورية، بل في الأعمال الدفعية وغير المتصلة والوكلاء (agents) التي لا تحساس فيها للتأخير.

## إذن، هل يجب اعتمادها

ابدأ بالتحقق مما إذا كانت هذه الشروط الثلاثة متوفرة جميعها. هل تملك بالفعل (أو يمكنك الحصول عليه بتكلفة زهيدة) خادم AMX كبير بذاكرة عشوائية ضخمة. هل النموذج الذي تريد تشغيله هو نموذج MoE كبير (من فئة V3، R1) يتجاوز فعلياً سعة VRAM لبطاقة GPU. وهل هذا العمل يتحمّل التأخير، أي أنه دفعي أو غير متصل أو من نوع الوكلاء، وليس استجابة فورية. إذا تحققت الشروط الثلاثة جميعها، تصبح ktransformers المسار الواقعي الوحيد لتشغيل ذلك النموذج دون شراء إعداد باهظ بعدة بطاقات GPU. أما إذا اختلّ شرط واحد، يتغيّر الجواب. إذا كنت بحاجة إلى محادثة فورية، فإن سرعة النقل من رتبة عددية واحدة (خانة آحاد) بالـ tok/s غير كافية، وإذا كان النموذج يتسع على GPU، فإن تحميله بالكامل مباشرة على GPU أسرع، دون أدنى شك، بعشرات الأضعاف.

فيما يلي هذا القرار موضّحاً في مسار واحد.

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
<div class="d3-arch" data-arch-root id="smoeoffload28xvalidation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 697, "height": 580, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 391, "y": 24, "w": 163, "h": 62, "title": ["Large MoE model", "overflows GPU VRAM?"]}, {"id": "B", "x": 495, "y": 178, "w": 170, "h": 62, "title": ["Load fully on GPU", "tens of times faster"]}, {"id": "C", "x": 291, "y": 178, "w": 149, "h": 62, "title": ["Own an AMX server", "with large RAM?"]}, {"id": "D", "x": 391, "y": 332, "w": 212, "h": 62, "title": ["Rent economics lose", "5 to 17x pricier per token"]}, {"id": "E", "x": 131, "y": 332, "w": 205, "h": 62, "title": ["Workload batch or offline", "latency tolerant?"]}, {"id": "F", "x": 270, "y": 486, "w": 156, "h": 62, "title": ["Single-digit tok/s", "too slow for chat"]}, {"id": "G", "x": 24, "y": 486, "w": 191, "h": 62, "title": ["ktransformers fits", "the only realistic path"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "No", "curve": [[516, 86], [580, 132], [580, 132], [580, 178]], "off": "50%"}, {"src": "A", "dst": "C", "kind": "data", "label": "Yes", "curve": [[430, 86], [366, 132], [366, 132], [366, 178]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "No", "curve": [[419, 240], [497, 286], [497, 286], [497, 332]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "Yes", "curve": [[312, 240], [234, 286], [234, 286], [234, 332]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "No, real-time", "curve": [[280, 394], [348, 440], [348, 440], [348, 486]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "Yes", "curve": [[188, 394], [120, 440], [120, 440], [120, 486]], "off": "50%"}]});
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
      const container = document.getElementById('smoeoffload28xvalidation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'smoeoffload28xvalidation-1';
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

من وجهة نظرنا، القيمة الحقيقية لـ ktransformers ليست "28 ضعفاً" ولا "خدمة رخيصة". إنها مسألة واحدة تتعلق بإمكانية الوصول: فريق لا يستطيع شراء أو استئجار بطاقات GPU متعددة أصبح بإمكانه الآن تشغيل نموذج MoE من فئة 671 مليار معامل أصلاً، باستخدام خادم كبير يملكه بالفعل مع بطاقة GPU واحدة. يجب النظر إليها ليس كبطلة سرعة ولا كأداة لخفض التكاليف، بل كأداة دفعية تخفض حاجز الدخول.

## معلومات إعادة الإنتاج

أُجريت جميع التجارب الثلاث على RunPod، وبلغت التكلفة الإجمالية لاستخدام GPU نحو 15 دولاراً. تم نشر إطار عمل القياس بالكامل (llama.cpp `--n-cpu-moe`، ومقارنة نواتي AMX/AVX2 في kt_kernel، والقياس الشامل لنموذج 235 مليار معامل) بالإضافة إلى نتائج JSON الخام. إذا أردت إعادة الإنتاج بنفسك أو التحقق من الأرقام، يمكنك زيارة [github.com/sylvanus4/ktransformers-moe-offload-bench](https://github.com/sylvanus4/ktransformers-moe-offload-bench) (رخصة Apache-2.0). المرشح المتبقي للتحقق هو بناء حزمة الخدمة الرسمية الكاملة لـ ktransformers مع تفعيل ضغط INT4 وتوزيع الخبراء على GPU وخط الأنابيب معاً، لقياس المدى الحقيقي الذي يمكن أن تصل إليه إنتاجية الدفعات (batch throughput).
