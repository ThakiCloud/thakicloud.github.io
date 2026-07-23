---
title: "من التكلفة الحقيقية لوحدة GPU الواحدة: كيف تُحسّن ThakiCloud تكاليف استدلال الذكاء الاصطناعي"
excerpt: "معادلات استهلاك GPU، جدولة العصابات مع Kueue، تقليص vLLM إلى الصفر، وتوجيه طبقات النماذج — نستعرض بالأكواد والصيغ الرياضية كيف تخفّض ThakiCloud تكاليف الاستدلال داخلياً، وكيف يمكن للعملاء تشغيل ذات الآليات عبر منتجنا."
seo_title: "تحسين تكاليف استدلال الذكاء الاصطناعي: تكلفة GPU · Kueue · vLLM Scale-to-Zero - Thaki Cloud"
seo_description: "دليل عملي لتحسين تكاليف استدلال الذكاء الاصطناعي من ThakiCloud. صيغة تكلفة GPU في الساعة، تفكيك OpEx، جدولة عصابات Kueue+KAI، تقليص vLLM+KEDA إلى الصفر، توجيه طبقات النماذج، ومراجعة التكاليف اليومية — كل ذلك بالأكواد والصيغ الرياضية."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - cost-optimization
  - finops
  - gpu
  - kueue
  - vllm
  - scale-to-zero
  - inference
  - llmops
  - on-premise
  - thakicloud
header:
  teaser: /assets/images/cost-opt-hero.webp
toc: true
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/gpu-inference-cost-optimization-thakicloud/"
categories:
  - llmops
published: false
---

![تكاليف الحوسبة تتدفق عبر مركز بيانات GPU]({{ '/assets/images/cost-opt-hero.webp' | relative_url }})

## لا يمكن تخفيض ما لا تستطيع قياسه

يبدأ تخفيض تكاليف استدلال الذكاء الاصطناعي عادةً بفكرة "لنشترِ GPU أرخص"، غير أن هذه نقطة انطلاق خاطئة في معظم الأحيان. فحتى مع GPU H100 واحدة، تتباين تكلفة الرمز المميز (token) بمقدار أضعاف مضاعفة تبعاً لأسلوب الجدولة، ومحرك الاستدلال المستخدم، وطبقة النموذج التي يُوجَّه إليها الطلب. الأجهزة ليست سوى الحد الأدنى للتكاليف، أما الهدر الحقيقي فيتسرب بصمت من طبقة التشغيل الموجودة فوقها.

تواجه ThakiCloud هذه المشكلة يومياً في تشغيل منصة AI/ML المبنية على Kubernetes. هذه المقالة توضح بالتفصيل كيف نخفّض تكاليف الاستدلال داخلياً، وكيف يمكن للعملاء تشغيل ذات الآليات عبر منتجنا، مع الصيغ الرياضية والإعدادات الفعلية — لا شرائح تسويقية، بل المعادلات والأنماط التي نعتمدها فعلاً.

الادعاء الجوهري واحد: **التكاليف لا تنخفض إلا بعد تثبيتها في وحدات قابلة للقياس.** لذا نبدأ بتثبيت تكلفة GPU في الساعة كمعادلة رياضية.

## 1. تثبيت تكلفة GPU في الساعة كمعادلة

السؤال "كم تكلّف وحدة H100 الواحدة؟" لا يكتمل إلا بنصفه. سعر الشراء هو نفقة رأسمالية (CapEx)، بينما الكهرباء وإيجار مركز البيانات والكوادر البشرية تُمثّل نفقات تشغيلية شهرية (OpEx). يجب دمج الاثنين في رقم واحد لكل ساعة لكي نتمكن من احتساب تكلفة الرمز المميز.

آلة حساب التكاليف الداخلية لدينا (`scripts/gen_model_token_cost_xlsx.py`) تُرسّخ هذه المعادلة في الكود:

```text
الاستهلاك الشهري = سعر الشراء / 48 شهراً
تكلفة GPU في الساعة = (الاستهلاك الشهري + OpEx الشهري) / 730 ساعة
تكلفة الرمز المميز ($/1K) = تكلفة GPU في الساعة / (معدل المعالجة tok/s × 3.6)
```

الاستهلاك على 48 شهراً (4 سنوات) افتراض محافظ لعمر GPU مركز البيانات. أما 730 فهو متوسط ساعات الشهر (24 × 365 / 12). الأهم هنا هو **تفكيك OpEx بدقة بدلاً من تجميعه**:

| بند OpEx | التكلفة الشهرية (USD) | أساس الاحتساب |
|---|---|---|
| الطاقة الكهربائية | $58 | TDP × PUE 1.3 × $0.08/kWh × 730h |
| إيجار مركز البيانات | $312 | مساحة الرف والتبريد |
| الشبكة | $150 | عرض النطاق والعبور |
| حصة الكوادر | $100 | توزيع تكاليف التشغيل |
| تراخيص البرمجيات | $52 | المراقبة والتنسيق |
| **الإجمالي** | **$672/شهر** | ثابت بصرف النظر عن نوع GPU |

لافت أن تكلفة إيجار مركز البيانات ($312) تفوق تكلفة الكهرباء ($58). الاعتقاد الشائع بأن "GPU مكلفة لأنها تستهلك طاقة كهربائية كبيرة" مضلّل — في الواقع، الطاقة الكهربائية ليست سوى جزء من OpEx، والإيجار والشبكة أكبر منها. هذا يفسّر لماذا تقتصر بعض عمليات التحسين على فاتورة الكهرباء دون أن تُجدي نفعاً.

يُضاف إلى ذلك واقع السوق الكورية: يُضاف على سعر شراء GPU **علاوة تبلغ نحو 30%** تشمل الجمارك والشحن وهوامش التوزيع. تعكس آلة حسابنا ذلك صراحةً — السعر الأساسي H100 بـ$32,500 يصبح $42,250 في كوريا، وB200 بـ$20,000 يصبح $26,000.

حين تُطبّق هذه المعادلة فعلياً، تحصل على رقم واحد لتكلفة GPU في الساعة، ومن فوقه يصبح حساب "كم تكلّف خدمة هذا النموذج بهذا معدل معالجة لكل رمز مميز" ممكناً. حين تتثبّت التكلفة كمعادلة، يتحوّل التحسين من تخمين إلى حسابيات.

![مخطط مفاهيمي يُظهر تفكيك تكلفة GPU طبقة تلو الأخرى]({{ '/assets/images/cost-opt-amortization.webp' | relative_url }})

## 2. الاستضافة الذاتية مقابل واجهات برمجة التطبيقات: تشريح الفجوة

بعد تثبيت التكلفة كمعادلة، يصبح السؤال التالي واضحاً: أيهما أرخص — شراء ذات الرموز المميزة عبر API خارجية أم إنتاجها بالاستضافة الذاتية؟

تُظهر ورقة مقارنة API في آلة حسابنا أن الفجوة بين تكلفة الرمز المميز في API التجارية والاستضافة الذاتية تبلغ **50 إلى 100 ضعف**. بطبيعة الحال، هذه الفجوة لا تتحقق إلا حين يكون معدل استغلال GPU مرتفعاً بما فيه الكفاية. فإن استُخدم نصف طاقة GPU فقط، تتضاعف تكلفة الاستضافة الذاتية للرمز المميز. لذا فإن الجدوى الاقتصادية للاستضافة الذاتية تعتمد كلياً على القدرة في "إبقاء GPU مشغولة"، أي على كفاءة الجدولة والاستدلال.

للإشارة، تُخزّن أسعار API الخارجية في سكريبت مراجعة التكاليف اليومية لدينا (`scripts/cost_audit.py`):

```python
# جدول الأسعار في scripts/cost_audit.py (USD / MTok، إدخال/إخراج)
PRICING = {
    "opus":   {"in": 15.0, "out": 75.0},
    "sonnet": {"in": 3.0,  "out": 15.0},
    "haiku":  {"in": 0.80, "out": 4.0},
}
```

رمز إخراج Opus أغلى بنحو 19 مرة من Haiku. استيعاب هذا الجدول وحده يشرح "لماذا تتضخم التكاليف عند تشغيل نفس المهمة بـOpus". سواء أكانت استضافة ذاتية أم API، فإن نصف تحسين التكاليف يكمن في **توجيه كل مهمة إلى النموذج الصحيح**. سنتناول هذا التوجيه لاحقاً.

> للمشاركة برقم داخلي واحد: مررنا بمرحلة أدرنا فيها جزءاً كبيراً من أحمال عمل الوكلاء عبر Claude API الخارجية، بتكلفة شهرية تجاوزت ₩40M (نحو $30K). [تقديري] كان Opus يمثّل ما يقارب نصف هذا الإنفاق، وكان هذا الرصد الدافع المباشر للتحوّل إلى الاستضافة الذاتية وتطبيق توجيه طبقات النماذج.

## 3. الجدولة: إبقاء GPU في حالة عمل دائمة

إذا كانت الجدوى الاقتصادية للاستضافة الذاتية رهينةً بمعدل الاستغلال، فإن المُجدوِل هو قلب تحسين التكاليف. تعتمد ThakiCloud **Kueue + KAI Scheduler** لإدارة قوائم انتظار أحمال عمل GPU على Kubernetes.

تقوم على ثلاثة آليات جوهرية:

**أولاً: جدولة العصابات (Gang Scheduling).** تبدأ مهام التدريب الموزّع فقط حين تُحجز جميع وحدات GPU المطلوبة في آنٍ واحد. يمنع هذا الهدر الناجم عن الاستيلاء على نصف الطاقة وانتظار النصف الآخر.

**ثانياً: قوائم حصص عادلة (Fair-Share) لكل فريق.** حين تتشارك فرق متعددة مجموعة عناقيد (cluster)، يُوزَّع الجدول بعدالة لمنع فريق واحد من احتكار الموارد. الحصص الفائضة يستعيرها فريق آخر، ويُعيدها حين يطلبها صاحبها.

**ثالثاً: حصص LocalQueue + ClusterQueue.** تُطبّق حدوداً قصوى لاستخدام GPU على مستوى كل فضاء عمل. وهذا هو الأساس الذي تقوم عليه آليات التحكم بالميزانية المُقدّمة للعملاء.

تسير أحمال العمل وفق دورة حياة واضحة:

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
<div class="d3-arch" data-arch-root id="stoptimizationthakicloud-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 374, "height": 632, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 96, "y": 24, "w": 120, "h": 46, "title": "في الانتظار"}, {"id": "B", "x": 82, "y": 148, "w": 149, "h": 46, "title": "في قائمة الانتظار"}, {"id": "C", "x": 140, "y": 286, "w": 202, "h": 52, "title": "الحصة والموارد متوفرة؟"}, {"id": "D", "x": 181, "y": 430, "w": 120, "h": 46, "title": "قيد التشغيل"}, {"id": "E", "x": 199, "y": 554, "w": 120, "h": 46, "title": "مكتمل"}, {"id": "F", "x": 24, "y": 554, "w": 120, "h": 46, "title": "فشل"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [156, 70, 156, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[189, 194], [254, 240], [254, 240], [246, 286]]}, {"src": "C", "dst": "B", "kind": "data", "label": "لا", "curve": [[210, 286], [156, 240], [156, 240], [156, 194]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "نعم", "line": [241, 338, 241, 430], "lx": 241, "ly": 380}, {"src": "D", "dst": "E", "kind": "data", "line": [248, 476, 259, 554]}, {"src": "D", "dst": "F", "kind": "data", "line": [208, 476, 110, 554]}, {"src": "F", "dst": "B", "kind": "data", "curve": [[80, 554], [74, 453], [74, 312], [129, 194]]}]});
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
      const container = document.getElementById('stoptimizationthakicloud-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'stoptimizationthakicloud-1';
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

جوهر هذا البناء هو **التحزيم الكثيف (Bin Packing)**. حشر المهام الصغيرة في وحدات GPU بإحكام يُقلّل التجزؤ، ويُتيح تنفيذ عمل أكبر بالأجهزة ذاتها، مما يُخفّض تكلفة الرمز المميز. كلما أحسن المُجدوِل الحشوَ، كلما أصبحت ميزة الاستضافة الذاتية البالغة 50 ضعفاً واقعاً ملموساً.

![مخطط مفاهيمي يُظهر التحزيم الكثيف للمهام الصغيرة في وحدات GPU]({{ '/assets/images/cost-opt-binpacking.webp' | relative_url }})

## 4. استخلاص المزيد من طبقة الاستدلال

إذا كانت الجدولة تمنع GPU من الخمول، فإن محرك الاستدلال يُعظّم إنتاج الرموز المميزة من وحدات GPU الفعّالة. نعتمد مزيج **vLLM + KEDA** لخدمة الاستدلال.

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
<div class="d3-arch" data-arch-root id="stoptimizationthakicloud-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 472, "height": 880, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "R", "x": 170, "y": 24, "w": 120, "h": 46, "title": "طلب استدلال"}, {"id": "G", "x": 135, "y": 148, "w": 191, "h": 46, "title": "بوابة متوافقة مع OpenAI"}, {"id": "K", "x": 119, "y": 272, "w": 223, "h": 52, "title": "هل توجد نسخ متماثلة نشطة؟"}, {"id": "Z", "x": 211, "y": 416, "w": 170, "h": 46, "title": "KEDA: توسيع من الصفر"}, {"id": "V", "x": 170, "y": 540, "w": 120, "h": 46, "title": "محرك vLLM"}, {"id": "B", "x": 256, "y": 678, "w": 184, "h": 46, "title": "تجميع مستمر + ذاكرة KV"}, {"id": "O", "x": 288, "y": 802, "w": 120, "h": 46, "title": "الاستجابة"}, {"id": "S", "x": 24, "y": 678, "w": 177, "h": 46, "title": "KEDA: تقليص إلى الصفر"}], "edges": [{"src": "R", "dst": "G", "kind": "data", "line": [230, 70, 230, 148]}, {"src": "G", "dst": "K", "kind": "data", "line": [230, 194, 230, 272]}, {"src": "K", "dst": "Z", "kind": "data", "label": "لا", "curve": [[254, 324], [296, 370], [296, 370], [296, 416]], "off": "50%"}, {"src": "K", "dst": "V", "kind": "data", "label": "نعم", "curve": [[206, 324], [164, 370], [164, 501], [206, 540]], "off": "50%"}, {"src": "Z", "dst": "V", "kind": "data", "curve": [[296, 462], [296, 501], [296, 501], [255, 540]]}, {"src": "V", "dst": "B", "kind": "data", "curve": [[270, 586], [348, 632], [348, 632], [348, 678]]}, {"src": "B", "dst": "O", "kind": "data", "line": [348, 724, 348, 802]}, {"src": "V", "dst": "S", "kind": "event", "label": "خمول مستمر", "curve": [[191, 586], [113, 632], [113, 632], [113, 678]], "off": "50%"}]});
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
      const container = document.getElementById('stoptimizationthakicloud-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'stoptimizationthakicloud-2';
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

ثمة ثلاثة محاور للتخفيض هنا:

**التقليص إلى الصفر (Scale-to-Zero).** يخفّض KEDA نقاط النهاية للنماذج التي لا يصلها حركة مرور إلى صفر نسخ متماثلة، ويُعيد تشغيلها عند وصول طلب. يُلغي ذلك كلياً تكلفة "تشغيل GPU خاملة" في ساعات الليل أو للنماذج نادرة الاستخدام — وهو أكبر أشكال الهدر في الاستضافة الذاتية يُزال من الجذور.

**التجميع المستمر (Continuous Batching).** يجمع vLLM الطلبات الواردة ديناميكياً لتشغيل GPU دون انقطاع. حين يرتفع معدل معالجة كل طلب، يكبر المقام في معادلة القسم 1 (معدل المعالجة tok/s)، فتنخفض تكلفة الرمز المميز بالقدر ذاته.

**إعادة استخدام ذاكرة KV والكمّ (Quantization).** الطلبات التي تتشارك بادئة الموجّه (prompt prefix) ذاتها تُعيد استخدام ذاكرة KV لتفادي الحسابات المكررة. أما الكمّ فيُتيح نماذج أكبر أو معدل معالجة أعلى على GPU ذاتها. (مقاييس الكمّ هي البند التالي في خارطة طريقنا.)

يُضاف طبقة أخرى لتقليل استدعاءات API الخارجية. **بوابة أدوات الوكلاء (ATG)** الخاصة بنا تُطبّق التخزين المؤقت وإلغاء التكرار والضغط على استدعاءات الأدوات الخارجية. حين يُكرّر وكيل ما استدعاء خارجياً، تُعاد النتيجة المخزّنة، مما يخفّض فواتير API الخارجية، لا الرموز المميزة وحدها.

![مخطط مفاهيمي يُظهر انكماش الخادم النشط إلى الصفر (scale-to-zero)]({{ '/assets/images/cost-opt-scale-to-zero.webp' | relative_url }})

## 5. التوجيه والرصد: آخر 30% من تكاليف التشغيل

حتى لو أحكمنا الأجهزة والاستدلال، فإن توجيه المهام إلى نموذج خاطئ يُعيد التسرب. القاعدة الداخلية في ThakiCloud هي **توجيه طبقة النموذج بحسب طبيعة المهمة**، وهي مُرسَّخة في قواعد تشغيل وكلائنا:

| نوع المهمة | طبقة النموذج | التكلفة النسبية |
|---|---|---|
| استكشاف · قراءة ملفات · بحث · grep | haiku | ~1x |
| تنفيذ · مراجعة · اختبار · تلخيص | sonnet | ~4x |
| هندسة معمارية · استدلال متعدد الخطوات | opus | ~19x |

المبدأ بسيط: **العمّال بنماذج رخيصة، والبوابات وحدها بنماذج مكلفة.** الاستكشاف يذهب إلى haiku، ولا يُستخدم opus إلا في الخطوات التي تتطلب حكماً استدلالياً حقاً. حين تقصر الجودة، غالباً ما يكون إضافة خطوة تحقق أرخص وأدق من ترقية النموذج مباشرة.

كل هذا **يُقاس يومياً**. يُحلّل `cost_audit.py` نصوص الجلسات ويُجمّع التكاليف بحسب طبقة النموذج ومعدل إصابة الذاكرة المؤقتة واستخدام الأدوات والأوامر.

```python
# معدل إصابة الذاكرة المؤقتة = مقدار تجنّب إعادة المعالجة المكلفة
cache_hit_ratio = cache_read / (cache_read + cache_write + input_tokens)
```

قدّمت لنا هذه المراجعة أغلى درس تعلمناه: اكتشفنا أن غالبية تكاليف اليوم الواحد كانت تنشأ من جلسة مراقبة ضخمة واحدة، مع أسعار opus علاوة على ذلك. لو لم نكن نقيس، لظلّ هذا التسرب خفياً إلى الأبد. **تحسين التكاليف ليس لوحة تحكم، بل عادة** — وتبدأ بمراجعة يومية.

## 6. كيف يُشغّل العملاء الآليات ذاتها

إن كان ما سبق يصف "ما نفعله نحن"، فإن الآليات ذاتها تتحوّل إلى ميزات منتج متاحة للعملاء. على منصة ThakiCloud، يستطيع العملاء تشغيل هذه الآليات دون الحاجة إلى فريق بنية تحتية مستقل:

**حصص فضاء العمل والميزانيات.** ما يبدو في القسم 3 كـClusterQueue/LocalQueue يظهر للعميل كـ"ميزانية GPU لكل فريق". تُحدَّد سقوف لكل قسم، والحصص الفائضة يستعيرها فريق آخر تلقائياً. تجاوز الميزانية يصبح مستحيلاً هيكلياً.

**مشاركة GPU والحصص العادلة.** تتشارك مهام الاستدلال الصغيرة وحدة GPU واحدة بعدالة. يُلغي ذلك نموذج "GPU واحدة لكل فريق" المُسرف، ويُتيح تشغيل أحمال عمل أكثر بالأجهزة ذاتها.

**استدلال بالتقليص إلى الصفر.** نقاط نهاية نماذج العملاء تنخفض إلى الصفر عند غياب حركة المرور. لا يدفع العميل تكلفة إبقاء نماذج العرض التوضيحي الداخلي أو النماذج نادرة الاستخدام مُشغَّلة على مدار الساعة — بل يدفع بقدر ما يستهلك.

**شفافية الشوباك/الشارجباك (Showback/Chargeback).** تجمع واجهات برمجة تطبيقات الفوترة وتنسيق الوظائف في الواجهة الخلفية (`ai-platform-backend`) استخدام كل فضاء عمل. حين يصبح مرئياً أي فريق استخدم أي نموذج وبأي تكلفة، يصبح التخفيض ممكناً. مبدأ "القياس أولاً" الذي ذكرناه في القسم 5 ينطبق على العملاء بالقدر ذاته.

**النشر المحلي (On-Premises).** عملاء القطاعات المنظَّمة يمكنهم نشر المنصة كاملة في بيئة معزولة (air-gap) مبنية على k0s. بدلاً من إرسال الرموز المميزة عبر API خارجية، يُنتجونها من وحدات GPU الخاصة بهم — مع الحصول على سيادة البيانات وميزة التكلفة في آنٍ واحد.

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
<div class="d3-arch" data-arch-root id="stoptimizationthakicloud-3"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 653, "height": 566, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 355, "h": 510, "label": "فضاء عمل العميل", "lx": 36, "ly": 42}], "nodes": [{"id": "Q", "x": 145, "y": 63, "w": 163, "h": 46, "title": "حصة وميزانية الفريق"}, {"id": "SC", "x": 136, "y": 187, "w": 205, "h": 46, "title": "مشاركة GPU بالحصة العادلة"}, {"id": "SZ", "x": 150, "y": 325, "w": 177, "h": 46, "title": "استدلال scale-to-zero"}, {"id": "SB", "x": 120, "y": 449, "w": 120, "h": 46, "title": "لوحة شوباك"}, {"id": "OP", "x": 416, "y": 187, "w": 205, "h": 46, "title": "خيار النشر المحلي المعزول"}], "edges": [{"src": "Q", "dst": "SC", "kind": "data", "line": [231, 109, 239, 187]}, {"src": "SC", "dst": "SZ", "kind": "data", "line": [239, 233, 239, 325]}, {"src": "SZ", "dst": "SB", "kind": "data", "curve": [[239, 371], [239, 410], [239, 410], [201, 449]]}, {"src": "SB", "dst": "Q", "kind": "event", "label": "قياس→تعديل", "curve": [[150, 449], [99, 348], [99, 210], [179, 109]], "off": "50%"}, {"src": "Q", "dst": "OP", "kind": "data", "curve": [[257, 109], [309, 148], [309, 148], [441, 187]]}]});
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
      const container = document.getElementById('stoptimizationthakicloud-3')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'stoptimizationthakicloud-3';
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

## منظور ThakiCloud: هيكل تكلفة ينخفض كلما زاد الاستخدام

في الختام، دعونا نستعرض الصورة الإجمالية حين تتضافر كل هذه الآليات معاً.

هيكل تكاليف APIs التجارية متغيّر — كل رمز مميز يُضاف إلى الفاتورة بشكل خطي، والأكثر استخداماً يعني الأكثر دفعاً. حين تنتقل إلى الاستضافة الذاتية أو النشر المحلي، تتحوّل التكاليف إلى **تكاليف ثابتة (CapEx + تكلفة كهرباء هامشية)**. بمجرد شراء GPU، تكاد تقتصر التكلفة الهامشية لكل رمز مميز إضافي على فاتورة الكهرباء. ينشأ بذلك هيكل تنخفض فيه **التكلفة المتوسطة كلما زاد الاستخدام** — وهو جوهر ما نسميه الخندق التكلفوي (cost moat).

نضيف فوق ذلك حلقة التعلم الذاتي. الضبط الدقيق (fine-tuning) لنماذج الأوزان المفتوحة (مثل سلسلة Kimi K2.5) على بيانات العملاء لبناء وكلاء متخصصة بالمجال يُقلّص الاعتماد على API الخارجية ومخاطر تسريب البيانات في آنٍ واحد. حين تُدرَّب خلفاء الوكيل على وحدات GPU الخاصة بنا، تنخفض تكلفة الرمز المميز بتنامي الحجم.

من حيث مسار الأهداف الداخلية، نستهدف خفض تكلفة المهمة الواحدة بنحو **83% من المستوى الحالي، من $0.041 إلى $0.007/مهمة** خلال 12 شهراً. [تقديري] هذا الرقم هو هدف تراكم تحسينات الجدولة والاستدلال والتوجيه، ولا يتحقق بآلية واحدة بل بمجموع المنظومة التي استعرضناها هنا.

يتلاءم هذا مع المتطلبات الواقعية للسوق الكورية أيضاً. النشر المحلي وفي البيئات المعزولة لعملاء القطاع العام والمالي يجب أن يستوفي متطلبات اعتماد مثل N²SF (إطار أمن الشبكات الوطنية) وشهادات التحقق من الوظائف الأمنية الصادرة عن الأجهزة الحكومية المعنية، وهذا هدف محوري في إصدار 2026. كفاءة التكاليف والامتثال التنظيمي ليسا منفصلَين — كلاهما يُحلّ في المعمارية المحلية ذاتها.

## خلاصة

تحسين تكاليف الاستدلال ليس حلاً سحرياً واحداً، بل هو سدّ التسرب في كل طبقة. تُثبَّت تكلفة GPU كمعادلة، يُبقيها المُجدوِل مشغولة، يستخلص منها محرك الاستدلال أقصى إنتاج، يُطابق التوجيه كل مهمة مع النموذج الملائم، ويُرصد كل ذلك يومياً لرصد التسرب. ThakiCloud تُشغّل هذه المنظومة داخلياً، وتفتح الآليات ذاتها للعملاء كميزات في المنتج.

التكاليف تنخفض بمقدار ما تراه. لذا نبدأ دائماً بالقياس.

---

*ThakiCloud منصة AI/ML مبنية على Kubernetes توفّر جدولة GPU واستدلالاً فعّالاً ونشراً محلياً لتحسين التكاليف. إن أثارك منتجنا أو فرص العمل لدينا، زر [ThakiCloud](https://thakicloud.com/tech-blog).*
