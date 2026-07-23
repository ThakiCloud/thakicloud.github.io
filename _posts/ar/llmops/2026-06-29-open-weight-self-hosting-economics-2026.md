---
title: "عام اللحاق: حين تقترب النماذج مفتوحة الأوزان من الحدود الأمامية وتصبح اقتصاديات self-hosting هي معركة الحسم"
excerpt: "في منتصف عام 2026، باتت النماذج مفتوحة الأوزان على بُعد ثلاثة إلى ستة أشهر من الحدود الأمامية، والفجوة لا تتسع. القرار الحقيقي الآن لم يعد عن أداء النموذج، بل عن مكان التشغيل وطريقته، أي اقتصاديات self-hosting. نستعرض هذا التحول من منظور منصة K8s لدى ThakiCloud."
seo_title: "ازدهار النماذج مفتوحة الأوزان واقتصاديات self-hosting 2026 - Thaki Cloud"
seo_description: "تحليل مشهد النماذج مفتوحة الأوزان في 2026 من خلال DeepSeek V4 Flash وGLM-5.2 وMiniMax M3 وNemotron 3 Ultra، ونقطة التعادل في التكلفة مقارنة بالنماذج المغلقة، من منظور خدمة K8s لدى ThakiCloud"
date: 2026-06-29
last_modified_at: 2026-06-29
tags:
  - open-weight
  - self-hosting
  - llm-serving
  - cost-efficiency
  - on-premise
  - vllm
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/open-weight-self-hosting-economics-2026/"
reading_time: true
header:
  image: /assets/images/open-weight-self-hosting-economics-2026-hero.webp
categories:
  - llmops
---

![صورة تجريدية تعبر عن النماذج مفتوحة الأوزان واقتصاديات self-hosting]({{ '/assets/images/open-weight-self-hosting-economics-2026-hero.webp' | relative_url }})

يمكن تلخيص مشهد النماذج مفتوحة الأوزان في منتصف 2026 بجملة واحدة: **الفجوة ضاقت، ولم تتسع من جديد.** يرى التقرير الذي أصدره OpenRouter في يونيو أن النماذج مفتوحة الأوزان باتت تحافظ على فجوة قدرة لا تتجاوز ثلاثة إلى ستة أشهر عن مختبرات الحدود الأمامية، دون أن تتسع. إذا صح هذا الافتراض، فالقرار الحقيقي الذي يجب على المؤسسات اتخاذه لم يعد "أي النماذج أذكى؟"، بل أصبح "أين نشغّل هذا الحِمل، وبأي تكلفة؟"

نحن في ThakiCloud نتعامل مع خدمة النماذج عبر منصة AI/ML SaaS المبنية على K8s. لذا نقرأ هذا التحول من زاوية **اقتصاديات self-hosting** لا من قائمة النماذج. حين يرتقي مفتوح الأوزان إلى مستوى الحدود الأمامية، لا يعود self-hosting مثالية رومانسية، بل يصير مسألة حساب تكلفة. في هذا المقال نستعرض أبرز النماذج مفتوحة الأوزان في منتصف 2026 لتحديد أين تتشكل نقطة التعادل في التكلفة، وكيف تجعل K8s هذا القرار قابلا للتشغيل.

## الفجوة لا تتسع: مشهد النماذج مفتوحة الأوزان في منتصف 2026

نبدأ بالحقائق. النماذج الأربعة أدناه مستخلصة من مصادر مستقلة متعددة (Artificial Analysis، بطاقات نماذج Hugging Face، إعلانات المختبرات)، ولم نعتمد على مرجع معياري واحد.

| النموذج | الحجم (إجمالي/نشط) | الرخصة | مؤشر AA الذكائي | ملاحظات |
|---|---|---|---|---|
| DeepSeek V4 Flash | 284B / 13B (MoE) | MIT | ~40 | SWE-bench Verified 79.0%، سياق 1M |
| GLM-5.2 (Z AI) | 753B | MIT | 51 | الأول بين مفتوحة الأوزان، ضمن المراتب الأربع الأولى عالميا |
| MiniMax M3 | 428B / 23B (MoE) | رخصة مجتمعية | 44 | متعدد الوسائط أصيل، سياق 1M |
| NVIDIA Nemotron 3 Ultra | 550B / 55B (MoE) | OpenMDW | 48 | نموذج أمريكي مفتوح، أكثر من 300 tok/s |

تبرز عدة نقاط. **GLM-5.2** حقق 51 نقطة في مؤشر Artificial Analysis الذكائي ليتصدر قائمة النماذج مفتوحة الأوزان، ويحتل موقعا بين المراتب العليا حتى عند إدراج النماذج المغلقة. ما يلفت الانتباه أن النماذج المغلقة الأعلى مرتبة (Fable 5 وOpus 4.8 وGPT-5.5) لا تزال تتصدر القائمة. بمعنى أن القول بأن "مفتوح الأوزان تجاوز الحدود الأمامية" مبالغة لا تصح. العبارة الدقيقة هي أن **الحدود الأمامية لم تستطع الفرار**، أي أن المُطارِد اقترب كفاية دون أن يكون المُطارَد قد توقف.

**DeepSeek V4 Flash** يُعدّ أول نموذج مفتوح الأوزان يصلح للتضمين المباشر في أنابيب عوامل البرمجة. SWE-bench Verified 79.0% يقل عن النسخة Pro من نفس العائلة بفارق 1.6 نقطة فحسب، فيما يبلغ سعره نحو 0.14 دولار إدخالا و0.28 دولار إخراجا لكل مليون رمز. **MiniMax M3** هو النموذج الوحيد في هذه المجموعة الذي يوفر دعما أصيلا متعدد الوسائط (صورة وفيديو)، مما يمنحه ميزة في أحمال عمل مثل أتمتة واجهة المستخدم وتحويل لقطات الشاشة إلى كود. **Nemotron 3 Ultra** هو النموذج الأمريكي المفتوح الذي أعلنت عنه NVIDIA في Computex 2026، ويتميز بمعدل أكثر من 300 tok/s ورخصة صديقة للمؤسسات.

ملاحظة ضرورية: تضمّن المصدر الأصلي لـ OpenRouter ادعاءا جيوسياسيا مفاده أن GLM-5.2 برز بسبب تعطّل بعض النماذج المغلقة جراء قيود تصدير أمريكية. غير أن تصنيفات المعايير المستقلة المتاحة للعموم في الفترة ذاتها تُظهر تلك النماذج في المراتب العليا، مما يجعل هذه العلاقة السببية غير مؤكدة. لذا نكتفي في هذا المقال بالحقائق الموثقة المتعلقة بالنماذج والأداء والتسعير، ونتجنب تفسيرات الأسباب والنتائج غير المثبتة.

## إعادة حساب التكلفة: ليست سعر الرمز، بل التكلفة الإجمالية للتشغيل

حين يرتقي مفتوح الأوزان إلى مستوى الحدود الأمامية، يتبدل محور نقاش التكلفة. كان السؤال سابقا: "كم من الأداء نتنازل عنه لتوفير التكلفة؟"، أما الآن فصار: **"من أين نحصل على الذكاء ذاته بأقل سعر؟"** وإجابة هذا السؤال لا تنبثق من جدول أسعار الرموز وحده.

ثمة ثلاثة أنماط تكلفة ينبغي التمييز بينها.

أولا، **واجهة برمجة التطبيقات المغلقة**. لا تكاليف تشغيلية، وإمكانية وصول فورية لأعلى أداء، لكن التكلفة المتغيرة تتناسب طرديا مع الاستخدام وتخرج البيانات إلى الخارج. هذا النمط مناسب لأحمال العمل ذات الحجم المنخفض أو غير المنتظم أو التي تستلزم الأداء الأقصى.

ثانيا، **مفتوح الأوزان مع استضافة طرف ثالث**. الأوزان متاحة للعموم لكن التشغيل يتم عبر مزود استدلال خارجي. سعر الرمز أقل بكثير من النماذج المغلقة، وهو ما تُبرزه تقارير النماذج مفتوحة الأوزان، غير أن الفوترة لا تزال قائمة على الاستخدام وحوكمة البيانات رهينة بالمزود.

ثالثا، **مفتوح الأوزان مع self-hosting**. يُنزَّل الأوزان ويُشغَّل على معدات GPU الخاصة بالمؤسسة أو على بنيتها التحتية الداخلية. يتحول هيكل التكلفة من متغير إلى **ثابت (إهلاك GPU + تشغيل)**. الجوهر هنا نقطة التعادل: حين يكفل معدل المعالجة المستمر قسمة التكلفة الثابتة على عدد كافٍ من الرموز، يصبح سعر الرمز الفعلي أدنى من أي خيار API. وعدم خروج البيانات خارج الحدود يُعدّ، في البيئات ذات المتطلبات التنظيمية والسيادية، شرطا أساسيا لا عاملا تكلفة.

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
<div class="d3-arch" data-arch-root id="selfhostingeconomics2026-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 611, "height": 894, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 198, "y": 24, "w": 198, "h": 78, "title": ["تعريف حمل العمل", "(الإنتاجية·الكمون·حساسية", "البيانات)"]}, {"id": "B", "x": 207, "y": 180, "w": 181, "h": 68, "title": ["هل هي إنتاجية عالية", "مستمرة؟"]}, {"id": "لا", "x": 451, "y": 40, "w": 128, "h": 46, "title": "متقطع·حجم صغير"}, {"id": "C", "x": 42, "y": 660, "w": 163, "h": 62, "title": ["API مملوكة", "أو استضافة طرف ثالث"]}, {"id": "D", "x": 300, "y": 340, "w": 195, "h": 68, "title": ["هل هناك متطلبات سيادة", "البيانات أو تنظيمية؟"]}, {"id": "E", "x": 292, "y": 660, "w": 212, "h": 62, "title": ["self-hosting مفتوح الأوزان", "(داخلي/مجموعة خاصة)"]}, {"id": "F", "x": 220, "y": 500, "w": 202, "h": 68, "title": ["هل يتجاوز نقطة التعادل", "الفعلية لتكلفة الرمز؟"]}, {"id": "G", "x": 295, "y": 800, "w": 205, "h": 62, "title": ["تشغيل خدمة K8s GPU", "(الجدولة·التعدد·المراقبة)"]}, {"id": "H", "x": 24, "y": 808, "w": 198, "h": 46, "title": "مراقبة التكاليف المتغيرة"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [297, 102, 297, 180]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"لا\"", "curve": [[235, 248], [151, 374], [151, 534], [134, 660]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "\"نعم\"", "curve": [[340, 248], [398, 294], [398, 294], [398, 340]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "\"نعم\"", "curve": [[431, 408], [475, 454], [475, 614], [429, 660]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "\"لا\"", "curve": [[365, 408], [321, 454], [321, 454], [321, 500]], "off": "50%"}, {"src": "F", "dst": "E", "kind": "data", "label": "\"يتجاوز\"", "curve": [[321, 568], [321, 614], [321, 614], [367, 660]], "off": "50%"}, {"src": "F", "dst": "C", "kind": "data", "label": "\"لا يتجاوز\"", "curve": [[225, 568], [95, 614], [95, 614], [112, 660]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "line": [398, 722, 398, 800]}, {"src": "C", "dst": "H", "kind": "data", "line": [123, 722, 123, 808]}]});
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
      const container = document.getElementById('selfhostingeconomics2026-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'selfhostingeconomics2026-1';
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

أكثر الأخطاء شيوعا في هذا المسار القراري هو **الحكم على المرحلتين الثانية والثالثة بسطر واحد من جدول أسعار الرموز**. التكلفة الحقيقية لـ self-hosting ليست في الأوزان (متاحة مجانا)، بل في توفير GPU وحزمة الخدمة والجدولة والمراقبة وكوادر التشغيل. لذا فإن عبارة "مفتوح الأوزان مجاني" صحيحة إلى النصف فحسب: النموذج مجاني، **أما التشغيل فليس كذلك.** مدى كفاءة هذا التشغيل وثباته هو ما تدور حوله اقتصاديات self-hosting في جوهرها.

## دلالات تطبيقية لمنتجات ThakiCloud

اقتصاديات self-hosting للنماذج مفتوحة الأوزان هي بالضبط المسألة التي تعالجها ThakiCloud بمنتجين اثنين.

**منظور ai-platform (البنية التحتية والخدمة).** منصة ai-platform من ThakiCloud تُشغّل خدمة النماذج على K8s. ما يُقرّب نقطة التعادل في self-hosting فعليا هو كفاءة البنية التحتية. جدولة مهام GPU المبنية على Kueue تُقلّل تعطّل المعجّلات الباهظة، ومحركات الخدمة عالية الإنتاجية كـ vLLM مع التكميم (FP8 وNVFP4) تستخرج رموزا أكثر من نفس المعدات، مما يخفض نقطة التعادل حتى في مستويات معالجة أقل. البنية متعددة المستأجرين تُتيح توزيع أحمال العمل على مجموعة GPU مشتركة، مما يوزع التكاليف الثابتة. أما نشر النماذج داخليا أو في بيئات سيادية فيُلبّي متطلبات سيادة البيانات دون عقوبة تكلفة، وهو أمر بالغ الأهمية في السياقات ذات المتطلبات التنظيمية والأمنية الصارمة. باختصار، ai-platform يُسوّق المرحلة الأخيرة من المخطط أعلاه، وهي **تشغيل خدمة GPU على K8s**.

**منظور Paxis (اقتصادية العوامل).** الخدمة منخفضة التكلفة لا تنتهي عند ذاتها، بل تُوجد اقتصادية عوامل. حين يتاح الأداء الحدودي في البرمجة كـ DeepSeek V4 Flash بعشرات السنتات لكل مليون رمز، تصبح تكلفة الرموز في سير عمل العوامل متعددة الخطوات قابلة للاحتمال. Paxis من ThakiCloud هو مستوى تحكم Agent-Native Cloud يعمل فوق ai-platform، يختار من أكثر من 960 مهارة عبر BM25 وينفذها في بيئات معزولة، مع تمرير كل إجراء عبر بوابات سياسية وسجلات تدقيق. حين تخفض الخدمة الرخيصة من ai-platform تكلفة استدعاء العوامل، يتسع هامش تصميم تنسيق العوامل متعددة المراحل في نفس الميزانية. بمعنى أن اقتصاديات self-hosting لا تنحصر في توفير البنية التحتية، بل تُوسّع هامش التصميم لطبقة العوامل التي تعمل فوقها مباشرة.

## القيود والاعتراضات المضادة

دعونا نُفنّد تفاؤل هذا المقال من الداخل.

أولا، self-hosting ليس دائما الأرخص. نقطة التعادل تفترض معدل معالجة مرتفعا ومستمرا. إن كان حجم المرور منخفضا أو غير منتظم، لن تُستهلك التكاليف الثابتة وتبقى API الخيار الأوفر. إغفال إهلاك GPU والطاقة والتبريد وكوادر التشغيل يجعل self-hosting يبدو أرخص مما هو عليه.

ثانيا، أرقام المعايير لها فترات ثقة. مؤشر AA الذكائي ودرجات SWE-bench المستشهد بها هي قياسات في بيئات تقييم محددة، ولا تطابق بالضرورة أداء أحمال العمل الحقيقية. بعض المعايير لنماذج حديثة العهد قد لا تتوفر إعادة إنتاج مستقلة كافية في المراحل الأولى من الإطلاق، مما يستوجب التقييم المباشر على أحمال عمل المؤسسة قبل الاعتماد.

ثالثا، الرخصة والمصدر يستحقان التدقيق. "مفتوح الأوزان" ليس مصطلحا متجانسا. MIT (DeepSeek وGLM) والرخصة المجتمعية (MiniMax) وOpenMDW (Nemotron) تختلف في حقوق إعادة التوزيع التجاري والضبط الدقيق. كذلك قد يُحدّد بلد منشأ النموذج وسياسات بياناته مدى إمكانية اعتماده في ظل بيئات تنظيمية بعينها.

رابعا، مشهد النماذج يتقادم بسرعة. الجدول أعلاه لقطة من منتصف 2026 وقابل للتغيير خلال أشهر. لذا فإن الجوهر ليس في أسماء النماذج، بل في المبدأ الثابت: **ما إن تبلغ النماذج مفتوحة الأوزان مستوى الحدود الأمامية، كلما كانت متطلبات التكلفة والسيادة لحِمل العمل أكبر، كلما صارت نقطة التعادل في self-hosting أكثر ملاءمة.** النماذج تتغير، لكن هذا الاتجاه لن يتغير.

## المصادر

- [The Open Weight Models that Matter: June 2026 · OpenRouter Blog](https://openrouter.ai/blog/insights/the-open-weight-models-that-matter-june-2026/)
- [GLM-5.2 is the new leading open weights model on the Artificial Analysis Intelligence Index](https://artificialanalysis.ai/articles/glm-5-2-is-the-new-leading-open-weights-model-on-the-artificial-analysis-intelligence-index)
- [NVIDIA Nemotron 3 Ultra released · Artificial Analysis](https://artificialanalysis.ai/articles/nvidia-nemotron-3-ultra-released)
- [DeepSeek V4 Flash · OpenRouter](https://openrouter.ai/deepseek/deepseek-v4-flash)
- [GLM-5.2 is probably the most powerful text-only open weights LLM · Simon Willison](https://simonwillison.net/2026/jun/17/glm-52/)
