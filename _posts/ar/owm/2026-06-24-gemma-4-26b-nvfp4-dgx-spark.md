---
title: "تشغيل Gemma 4 26B بتوازي 16 ضعفاً على جهاز DGX Spark واحد: مراجعة صريحة لتقنية NVFP4 والقيمة مقابل التكلفة"
excerpt: "نموذج Gemma-4-26B-A4B-NVFP4 الذي أصدرته NVIDIA يعمل على جهاز DGX Spark واحد (128 جيجابايت من الذاكرة الموحدة) بتوازي 16 ضعفاً، محققاً نحو 18 رمزاً في الثانية لكل تدفق وما يزيد على 300 رمز في الثانية إجمالاً. نستعرض في هذا المقال آلية NVFP4 التي تضغط 25.2 مليار معامل MoE إلى نحو 14 جيجابايت، والمقايضة بين التدفق المفرد والتزامن، ومدى تفوق DGX Spark فعلاً من حيث القيمة مقابل التكلفة مقارنة بوحدات Blackwell الأخرى."
seo_title: "Gemma-4-26B-A4B-NVFP4 على DGX Spark: استدلال بتوازي 16 ضعفاً - مراجعة صريحة - Thaki Cloud"
seo_description: "Gemma-4-26B-A4B-NVFP4 (25.2 مليار معامل MoE / 3.8 مليار معامل نشطة) على DGX Spark بذاكرة 128 جيجابايت: 18 رمزاً/ثانية لكل تدفق، 300 رمز/ثانية إجمالاً. تحليل تكميم NVFP4 رباعي البت، وعنق الزجاجة في النطاق الترددي للذاكرة، ومقارنة القيمة مع RTX 5090 وRTX PRO 6000 وB200 من منظور الخوادم الخاصة لـ ThakiCloud."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - gemma-4
  - nvfp4
  - dgx-spark
  - blackwell
  - mixture-of-experts
  - quantization
  - vllm
  - on-premise
  - inference
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/owm/gemma-4-26b-nvfp4-dgx-spark/"
lang: ar
reading_time: true
categories:
  - owm
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

![مخطط مفاهيمي للاستدلال المتوازي لـ Gemma 4 26B NVFP4]({{ '/assets/images/gemma-4-26b-nvfp4-dgx-spark-hero.webp' | relative_url }})

## نظرة عامة

أثار اهتماماً واسعاً عرضٌ تجريبي يُظهر تشغيل نموذج MoE كبير في 16 جلسة متزامنة على جهاز صغير يُوضع على المكتب. يتعلق الأمر بنموذج `Gemma-4-26B-A4B-NVFP4` الذي أصدرته NVIDIA، إذ يعمل على جهاز DGX Spark واحد (128 جيجابايت من الذاكرة الموحدة) بتوازي 16 ضعفاً، محققاً نحو 18 رمزاً في الثانية لكل تدفق وما يزيد على 300 رمز في الثانية إجمالاً. وقد أشار صاحب العرض إلى أن التزامن العالي جداً جعل من الصعب إظهاره بصرياً فاضطر إلى تقديمه برمجياً، مؤكداً إمكانية الوصول إلى 32 ضعفاً وأن flashinfer لم تُطبق بعد في هذه المرحلة.

ثمة نقطتان جوهريتان نود تسليط الضوء عليهما. الأولى: هذا ليس نموذجاً خفيف الوزن من نوع E2B أو E4B يعمل على الحواسيب المحمولة، بل هو **نموذج Gemma MoE كبير** يبلغ مجموع معاملاته 25.2 مليار معامل. الثانية: ما يجعل هذا ممكناً هو التقاء ثلاثة عوامل: **تكميم NVFP4 رباعي البت، وصغر المعاملات النشطة في MoE، وسعة الذاكرة الموحدة الكبيرة في DGX Spark**.

تُدير ThakiCloud منصة لتقديم نماذج اللغة الكبيرة بصورة متعددة المستأجرين فوق Kubernetes. لذا فإن سؤال "كم طلباً متزامناً يمكن استقباله على جهاز خاص صغير واحد؟" ليس مجرد عرض مثير للاهتمام، بل هو سؤال مباشر يتعلق بنموذج التكلفة. يُرتب هذا المقال الحقائق التقنية للنموذج، ويفصل بين أداء التدفق المفرد والتزامن، ويناقش بصدق ما إذا كان DGX Spark يوفر قيمة حقيقية مقارنة بوحدات Blackwell الأخرى، فضلاً عن تحديد مدى صلاحية هذا النموذج لمنظومة المهارات لدينا.

## ما الذي قدمه العرض التجريبي؟

يمكن تلخيص ادعاءات العرض الأصلي ([تغريدة فريق Google Gemma](https://x.com/googlegemma/status/2069452783523401804)) على النحو التالي:

- الجهاز: **جهاز DGX Spark واحد، ذاكرة موحدة 128 جيجابايت (GB10 Grace-Blackwell)**
- النموذج: [`nvidia/Gemma-4-26B-A4B-NVFP4`](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- التزامن: **16 ضعفاً متوازياً**، بمعدل **نحو 18 رمزاً/ثانية** لكل تدفق و**نحو 300 رمز/ثانية** إجمالاً
- قابلية التوسع: ممكنة حتى **32 ضعفاً**، لكنه عُرض بـ 16 ضعفاً لاعتبارات وضوح الشاشة
- هامش التحسين: **flashinfer لم تُطبق بعد**، مما يعني إمكانية تحسين الأداء لاحقاً

نوضح هنا نقطة يسهل إساءة فهمها: "18 رمزاً/ثانية لكل تدفق" هي القيمة عند تشغيل 16 تدفقاً متزامناً، وتدفق واحد وحيد يعطي أداءً أسرع. سيتم تناول المقايضة بين التزامن والتأخير المفرد بالأرقام الفعلية في قسم لاحق.

## الحقائق التقنية لنموذج Gemma-4-26B-A4B-NVFP4

النموذج الذي رفعته NVIDIA هو نسخة مُكممة بتقنية NVFP4 من نموذج `gemma-4-26B-A4B-it` الخاص بـ Google DeepMind، وذلك باستخدام NVIDIA Model Optimizer. المواصفات الرئيسية وفقاً لبطاقة النموذج:

| العنصر | القيمة |
|---|---|
| النموذج الأساسي | google/gemma-4-26B-A4B-it |
| البنية | Mixture-of-Experts (Transformer) |
| إجمالي المعاملات | 25.2 مليار |
| المعاملات النشطة | 3.8 مليار (لكل رمز) |
| تكوين الخبراء | 8 من أصل 128 نشطون + خبير مشترك واحد |
| عدد الطبقات | 30 |
| طول السياق | 256 ألف رمز |
| نافذة الانزلاق | 1024 رمز |
| أنماط الإدخال | نص + صورة |
| التكميم | NVFP4 (Model Optimizer v0.43.0) |
| الجهاز المستهدف | NVIDIA Blackwell |
| الرخصة | Apache 2.0 |

### ما هو NVFP4 ولماذا يستلزم Blackwell؟

NVFP4 هو تنسيق نقطة عائمة رباعي البت تُعجله NVIDIA بالجهاز في جيل Blackwell. خلافاً لتكميم INT4 الذي يقطع الأوزان إلى أعداد صحيحة رباعية البت فحسب، يعتمد NVFP4 على مقياس FP8 لكل كتلة صغيرة (micro-scaling)، مما يتيح تقليص الذاكرة المعادل لأربعة بتات مع الحفاظ على دقة عالية.

يظهر الأثر بوضوح في متطلبات الذاكرة: تحميل 25.2 مليار معامل بتنسيق BF16 يتطلب نحو 50 جيجابايت، بينما يُقلص NVFP4 الأوزان إلى **14-16 جيجابايت** تقريباً. في DGX Spark بذاكرته الموحدة البالغة 128 جيجابايت، يعني الاحتفاظ بالأوزان في 16 جيجابايت أن ما يزيد على 100 جيجابايت تبقى متاحة بالكامل لذاكرة التخزين المؤقت KV Cache. هذا الهامش الواسع هو ما يتيح التزامن من 16 إلى 32 ضعفاً واستيعاب سياقات طويلة تصل إلى 256 ألف رمز.

غير أن تسريع جهاز NVFP4 مقصور على Blackwell حصراً. الأجيال السابقة كـ Hopper (H100) وAda (RTX 4090) تفتقر إلى مسار Tensor Core الخاص بـ NVFP4، مما يعني عدم الاستفادة الكاملة من هذا التنسيق. بمعنى آخر، هذا النموذج مبني عملياً "للتشغيل على Blackwell".

### المعايير القياسية: هل خسارة الدقة في NVFP4 مقبولة؟

تقدم بطاقة النموذج مقارنة جنباً إلى جنب بين نسخة NVFP4 والنموذج الأساسي غير المُكمم:

| المعيار | NVFP4 | الأساس | المجال |
|---|---|---|---|
| AIME 2025 | 90.00% | 88.95% | الرياضيات التنافسية |
| MMLU Pro | 84.80% | 85.00% | المعرفة العامة والاستدلال |
| IFBench | 78.1% | 77.77% | اتباع التعليمات |
| GPQA Diamond | 79.90% | 80.30% | الاستدلال العلمي |

جميع المعايير الأربعة في فارق أقل من 1% مقارنة بالأساس. تتفوق نسخة NVFP4 قليلاً في AIME وIFBench، لكن يُفضل قراءة هذا الفارق باعتباره ضمن نطاق التشتت القياسي. الخلاصة: "ضغط الأوزان إلى أربعة بتات يحافظ على الجودة فعلياً"، وهذا ما يُميز NVFP4 عن INT4. مع ذلك، يُنصح بإجراء تقييم مستقل على مجموعات بيانات المهام العربية وغيرها من اللغات، إذ لا تظهر هذه في المعايير العامة المنشورة.

## الأداء الفعلي: التدفق المفرد مقابل التزامن

قد تُوهم "18 رمزاً/ثانية لكل تدفق" في العرض بالبطء. الفصل بين التدفق المفرد والتزامن ضروري. بالاستناد إلى تقارير المجتمع من قياسات على DGX Spark:

- **التدفق المفرد الأساسي**: نحو 32 رمزاً/ثانية (بدون MTP، بإعداد 64 ألف رمز)
- **التدفق المفرد + MTP (التنبؤ بعدة رموز)**: نحو **55-61 رمزاً/ثانية** (بإعداد 32 ألف رمز، أعلى أداء للاستجابات القصيرة إلى المتوسطة و JSON المنظم)
- **16 تدفقاً متزامناً**: نحو 18 رمزاً/ثانية لكل تدفق و**نحو 300 رمز/ثانية** إجمالاً
- **معالجة السياق الطويل**: نحو 11.9 ثانية لمدخل 25 ألف رمز، ونحو 28.6 ثانية لمدخل 50 ألف رمز (بإعداد 64 ألف رمز)

تبرز هنا حقيقتان:

الأولى: **فك ترميز MoE محدود بالنطاق الترددي للذاكرة**. صحيح أن المعاملات النشطة لكل رمز تبلغ 3.8 مليار فقط مما يُقلل العمليات الحسابية (FLOPs)، لكن كل رمز يتطلب قراءة أوزان الخبراء النشطين من الذاكرة. النطاق الترددي لذاكرة LPDDR5X الموحدة في DGX Spark أدنى من HBM في مراكز البيانات، وهذا ما يُفسر سبب كون سرعة التدفق المفرد "متحفظة لجهاز Blackwell". فائض قدرة FP4 الحسابية يصطدم بسقف النطاق الترددي.

الثانية: **القوة الحقيقية لهذا الجهاز ليست في التأخير المفرد بل في الإنتاجية المتزامنة**. الحصول على 300 رمز/ثانية إجمالاً مع تشغيل 16 ضعفاً يعني أن طلبات متعددة تتشارك النطاق الترددي معاً لرفع الكفاءة. الهامش الواسع للذاكرة الموحدة يتيح KV Cache سخياً، وهذا ما يُمكن هذا السيناريو. باختصار: الجهاز مُصمم لـ "استجابات كافية لعدة وكلاء ومستخدمين في آن واحد" لا لـ "استجابة سريعة لشخص واحد".

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
<div class="d3-arch" data-arch-root id="24gemma426bnvfp4dgxspark-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 722, "height": 697, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 220, "h": 254, "label": "DGX Spark · 128GB Unified Memory", "lx": 36, "ly": 42}], "nodes": [{"id": "W", "x": 74, "y": 62, "w": 121, "h": 62, "title": ["NVFP4 Weights", "~16GB"]}, {"id": "KV", "x": 63, "y": 179, "w": 142, "h": 62, "title": ["KV Cache Pool", "~100GB+ headroom"]}, {"id": "R1", "x": 74, "y": 316, "w": 120, "h": 46, "title": "Request 1"}, {"id": "Spark", "x": 322, "y": 467, "w": 120, "h": 46, "title": "Spark"}, {"id": "R2", "x": 74, "y": 417, "w": 120, "h": 46, "title": "Request 2"}, {"id": "R3", "x": 74, "y": 518, "w": 120, "h": 46, "title": "..."}, {"id": "R16", "x": 74, "y": 619, "w": 120, "h": 46, "title": "Request 16"}, {"id": "O", "x": 520, "y": 459, "w": 170, "h": 62, "title": ["~18 tok/s per stream", "~300 tok/s total"]}], "edges": [{"src": "R1", "dst": "Spark", "kind": "data", "curve": [[194, 339], [244, 339], [283, 339], [367, 467]]}, {"src": "R2", "dst": "Spark", "kind": "data", "curve": [[194, 440], [244, 440], [283, 440], [337, 467]]}, {"src": "R3", "dst": "Spark", "kind": "data", "curve": [[194, 541], [244, 541], [283, 541], [337, 513]]}, {"src": "R16", "dst": "Spark", "kind": "data", "curve": [[194, 642], [244, 642], [283, 642], [367, 513]]}, {"src": "Spark", "dst": "O", "kind": "data", "line": [442, 490, 520, 490]}]});
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
      const container = document.getElementById('24gemma426bnvfp4dgxspark-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '24gemma426bnvfp4dgxspark-1';
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

## مراجعة صريحة 1: هل يوفر DGX Spark قيمة حقيقية مقابل التكلفة؟

الخلاصة المباشرة: **"قيمة استثنائية من حيث السعة التخزينية للجيجابايت، وقيمة متوسطة من حيث التأخير لكل رمز"**. حتى ضمن جيل Blackwell الواحد، تتباين طبيعة كل شريحة.

| الشريحة | السعر (دولار) | الذاكرة | النطاق الترددي | حالة NVFP4 MoE (يونيو 2026) | الطابع |
|---|---|---|---|---|---|
| **DGX Spark** (GB10, SM121) | نحو $4,699 | 128 جيجابايت LPDDR5X موحدة | 273 جيجابايت/ث | ✅ يعمل (vLLM Marlin backend) | ذاكرة كبيرة وتزامن عالٍ، نطاق ترددي أدنى |
| **RTX 5090** (SM120) | نحو $2,000 [تقديري] | 32 جيجابايت GDDR7 | 1,792 جيجابايت/ث | ⚠️ غير مستقر حالياً (flashinfer #2577) | أعلى إمكانية لتكلفة الرمز، ذاكرة VRAM محدودة |
| **RTX PRO 6000** Blackwell (SM120) | نحو $8,500 | 96 جيجابايت GDDR7 | 1,792 جيجابايت/ث | ⚠️ نفس مشكلة SM120 | ذاكرة VRAM كبيرة، مبالغ فيه لهذا النموذج |
| **B200** (SM100، مراكز البيانات) | سحابة نحو $3-10/ساعة [تقديري] | 192 جيجابايت HBM3e | 8,000 جيجابايت/ث | ✅ دعم كامل (TRT-LLM/flashinfer) | أعلى أداء، فارق كبير في التكلفة |

أهم خانة في هذا الجدول ليست السعر بل **"حالة NVFP4 MoE"**، لأنها حيث تنفصل الحسابات النظرية عن الواقع.

- **نظرياً، RTX 5090 هو الأكثر كفاءة من حيث التكلفة لكل رمز.** نطاقه الترددي يبلغ 6.6 أضعاف DGX Spark (1,792 مقابل 273 جيجابايت/ث)، وفك ترميز MoE يعتمد على النطاق الترددي، مما يعني أن السقف النظري يتبع هذه النسبة مباشرة. قراءة 16 جيجابايت من الأوزان بـ 273 جيجابايت/ث تُعطي نظرياً نحو 170 رمزاً/ثانية، بينما بـ 1,792 جيجابايت/ث تصل إلى نحو 1,100 رمز/ثانية. والسعر هو نصف الثمن، فالحساب البسيط يُرجح الـ 5090 بمقدار 5 إلى 6 أضعاف.
- **لكن في الواقع، نواة NVFP4 MoE معطوبة حالياً على شرائح Blackwell الاستهلاكية والمهنية (SM120).** مشكلة NVFP4 GEMM في flashinfer على SM120 ([#2577](https://github.com/flashinfer-ai/flashinfer/issues/2577)) مفتوحة، مما يجعل تشغيل هذا النموذج رباعي البت على RTX 5090 وRTX PRO 6000 أمراً صعباً حالياً. الأفضل على الورق هو عملياً "لا يعمل الآن".
- **لذا يبقى DGX Spark (SM121) الجهاز الاستهلاكي الوحيد الذي يعمل عليه NVFP4 MoE فعلاً.** النطاق الترددي أدنى والسرعة متحفظة، لكن "صندوق MoE رباعي البت يعمل اليوم" هو السبب الحقيقي لصدور العرض من DGX Spark.
- **Blackwell لمراكز البيانات (B200, SM100)** مدعوم بالكامل عبر TRT-LLM وflashinfer NVFP4، لكن فارق التكلفة شاسع. للاستضافة الذاتية المستمرة يُفضل امتلاك الجهاز، أما لتحميل الأعباء المتفرقة ومتعددة المستأجرين فـ B200 سحابياً أجدى.

خلاصة: DGX Spark ليس "آلة شراء أداء الطليعة"، بل هو **"آلة شراء ذاكرة كبيرة وتزامن عالٍ بشكل يعمل اليوم، للتطوير والنمذجة الأولية والخدمة المتزامنة الصغيرة"**. حين تُصلح مشكلة SM120، ستنزل الكفاءة النظرية لـ RTX 5090 إلى الواقع، لكن حتى ذلك الحين موقع DGX Spark واضح. العرض المبهر بتوازي 16 ضعفاً مبني بالضبط على هذه الميزة.

## مراجعة صريحة 2: ما المهام الملائمة لهذا النموذج؟

حين يتضح طابع الكفاءة، تتضح المهام الملائمة.

**المهام الأنسب**

- تشغيل عدة وكلاء متزامنين: نمط 16 إلى 32 عاملاً يعملون معاً بسرعة معقولة. الإنتاجية الإجمالية هي نقطة القوة.
- أعباء المخرجات المنظمة: تدعم بطاقة النموذج استدعاء الدوال ومخرجات JSON المنظمة، و MTP يُحقق أعلى سرعة للاستجابات القصيرة إلى المتوسطة والـ JSON التحكمي. مناسب للتصنيف والتسمية والاستخراج المنظم.
- معالجة السياق الطويل: سياق 256 ألف رمز مع KV Cache واسع يمنح مرونة في تلخيص الوثائق الطويلة وحقن سياق RAG.
- النمذجة الأولية في البيئات الخاصة: تجربة خدمة نماذج MoE الكبيرة دون وحدات GPU لمراكز البيانات.

**المهام الأقل ملاءمة**

- محادثة فردية منخفضة التأخير: سرعة التدفق لكل مستخدم واحد أبطأ من بطاقات GDDR7. إن كان الهدف "أسرع استجابة لشخص واحد"، فهذا الجهاز ليس المناسب.
- استدلال أحادي عالي الصعوبة: المهام التي تتطلب أعلى دقة ممكنة تستفيد من نماذج أكثر كثافة أو أكبر حجماً. 26 ملياراً هي فئة الإنتاجية لا الدقة القصوى.

## دليل التشغيل

الطريق الموصى به في بطاقة النموذج هو vLLM. ثمة قيود موثقة حالياً:

- **vLLM TP=1 فقط**: البنية الحالية تدعم التوازي التنسوري 1 فقط (GPU واحد/جهاز واحد).
- **محلل Gemma 4 مخصص**: يلزم تحديد `--tool-call-parser gemma4` و`--reasoning-parser gemma4` عند التشغيل لتحليل مخرجات استدعاء الدوال والاستدلال بشكل صحيح.
- **flashinfer غير مُطبقة**: كما أشار صاحب العرض، لم تُستخدم flashinfer بعد. تطبيق تحسينات نواة الانتباه سيضيف هامشاً إضافياً من الأداء.

يستلزم التشغيل نظام Linux وجهاز Blackwell (Tensor Cores لـ NVFP4). الأجيال السابقة لا تستفيد من ميزة التسريع رباعي البت.

## دلالات التطبيق على منصة ThakiCloud K8s للذكاء الاصطناعي

تُدير ThakiCloud منصة متعددة المستأجرين تستخدم Kueue لإدارة حصص GPU وvLLM لخدمة النماذج. ثمة ثلاثة دلالات رئيسية يمنحها هذا العرض لنموذج تشغيلنا:

**مرشح للاستضافة الذاتية في طبقة العمال.** انضباطنا في التكاليف يتبع قاعدة "العمال بالرخيص، والبوابات بالغالي". مهام العمال كالاستكشاف والتصنيف والتلخيص والاستخراج المنظم لا تستلزم النماذج الأعلى رتبة. NVFP4 26B بإنتاجيته الإجمالية البالغة 300 رمز/ثانية ودعمه لاستدعاء الدوال ومخرجات JSON، مرشح مناسب لتشغيل عمال متعددين محلياً في آن واحد. إبقاء مراحل التحقق والتوليف والأحكام المعمارية للنماذج الأعلى رتبة يُقلص تكلفة الرموز هيكلياً.

**الذاكرة الموحدة الكبيرة تُبسط ميزانية KV لمتعدد المستأجرين.** مع أوزان تبلغ 16 جيجابايت في ذاكرة موحدة 128 جيجابايت، يتجاوز هامش KV Cache 100 جيجابايت. في البيئات متعددة المستأجرين، KV Cache هو أول مورد ينضب، وهذا الهامش يتيح تحديد حدود تزامن سخية لكل مستأجر.

**مرجع لاقتراحات الخوادم الخاصة والامتثال.** رخصة Apache 2.0 والتشغيل على جهاز واحد تكوين قابل للاقتراح مباشرة على عملاء القطاع العام والمالي الذين يشترطون الاستضافة الذاتية. إمكانية تشغيل MoE كبيرة على صندوق صغير دون GPU لمراكز البيانات توفر مساراً عملياً للبيئات التي تحظر نقل البيانات خارجياً أو تستلزم امتثالاً أمنياً صارماً.

## مراجعة صريحة 3: ما حدود استخدام هذا النموذج في منظومة مهاراتنا؟

معظم مهارات ThakiCloud ووكلائها تعتمد النماذج الأعلى رتبة كـ Opus/Sonnet أساساً. إذن أين يمكن إدراج NVFP4 26B؟ بصدق:

- **قابل للاستبدال فوراً (طبقة العمال)**: قراءة الملفات وتلخيص Grep، التصنيف وتطبيع Enum (عمال حتمية التنسيق)، توليد المسودات الأولى، استخراج الأخبار والوثائق. مهام read-only والمهام المنظمة التي يتولاها حالياً haiku/sonnet كعمال فرعيين يمكن نقل جزء كبير منها إلى 26B محلياً.
- **ممكن بشروط (مع تعزيز التحقق)**: عمال استدعاء أدوات الوكيل. دعم استدعاء الدوال ومخرجات JSON يجعله صالحاً كعامل طرفي في حلقات استدعاء الأدوات. لكن نتائج fan-out يجب دائماً إغلاقها بـ adversarial verify من نموذج أعلى (منع تراكم هلوسات العمال).
- **غير موصى به (طبقة البوابات)**: الاستدلال المعماري متعدد الخطوات، وأحكام التوليف والتحقق، وتوليد المحتوى عالي المخاطر. المراحل التي تتطلب أعلى دقة ممكنة تبقى على Opus.

الجوهر هو مطابقة رتبة النموذج مع رتبة المهمة. رؤية NVFP4 26B كـ "بديل لـ Opus" تُخيب الآمال، لكن رؤيته كـ "مرشح للاستضافة الذاتية في طبقة عمال haiku/sonnet" تجعله بطاقة قادرة على تغيير هيكل التكاليف. هذا بالضبط ما تقوله قاعدة توجيهنا: الاستكشاف بالرخيص، والبوابات بالغالي.

## القيود والنقد

للتوازن، نذكر الجوانب التي تستحق المراجعة:

- **سرعة التدفق المفرد متحفظة.** بطء النطاق الترددي يجعله أبطأ من بطاقات GDDR7. أعباء العمل الحساسة للتأخير تستلزم إعادة النظر في اختيار الجهاز.
- **أرقام العرض مرتبطة بالإعداد.** 18 رمزاً/ثانية و300 رمز/ثانية هي قيم لتزامن 16 ضعفاً وإعداد محدد، وتتفاوت حسب طول المدخل والمخرج وتطبيق MTP. يجب إعادة القياس على أعباء العمل الخاصة بك.
- **vLLM TP=1 وغياب flashinfer قيود اللحظة الحالية.** إضافة التحسينات قد تُغير الأرقام، لذا يُقرأ هذا المقال كـ "لقطة الحال".
- **تعقيد تشغيل MoE.** رغم أن المعاملات النشطة 3.8 مليار، تبقى الأوزان الكاملة في الذاكرة، وتوجيه الخبراء يؤثر على كفاءة الدفعات. "صغير الحجم" تفسير مبسط.
- **يلزم التحقق من الاستخدام الفعلي بالعربية والكورية.** المعايير العامة تُركز على اللغة الإنجليزية. دقة RAG واستدعاء الأدوات بالعربية تستلزم تقييماً داخلياً منفصلاً.

مع ذلك، يبقى الجمع بين رخصة Apache 2.0 وخدمة MoE كبيرة على جهاز واحد وتزامن مبني على ذاكرة واسعة خياراً جذاباً حقاً للمؤسسات التي تدرس الاستضافة الذاتية. بالنظر إليه من زاوية "شراء ذاكرة رخيصة وتزامن" لا "شراء سرعة الطليعة"، يُقدم DGX Spark + NVFP4 26B قيمة واضحة.

## روابط مرجعية

- [بطاقة نموذج Gemma-4-26B-A4B-NVFP4 (Hugging Face)](https://huggingface.co/nvidia/Gemma-4-26B-A4B-NVFP4)
- [تغريدة العرض الأصلي (Google Gemma)](https://x.com/googlegemma/status/2069452783523401804)
- [ملخص تشكيلة Gemma 4 الكاملة (مدونة ThakiCloud)](https://thakicloud.com/tech-blog/owm/gemma-4-open-weight-lineup/)
- [NVIDIA TensorRT Model Optimizer](https://github.com/NVIDIA/TensorRT-Model-Optimizer)
- [مقدمة NVFP4 (NVIDIA Developer)](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [مشكلة NVFP4 GEMM على SM120 في flashinfer #2577](https://github.com/flashinfer-ai/flashinfer/issues/2577)
- [معايير DGX Spark مع Gemma 4 26B NVFP4 (ai-muninn)](https://ai-muninn.com/en/blog/dgx-spark-gemma4-26b-nvfp4-52-toks)
