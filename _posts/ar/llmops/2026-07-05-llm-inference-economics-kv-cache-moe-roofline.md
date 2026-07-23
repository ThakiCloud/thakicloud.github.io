---
title: "لماذا يكون نموذج أكبر بثمانية أضعاف أرخص بخمسة أضعاف: البنية الحقيقية لتكلفة استدلال النماذج اللغوية الكبيرة"
excerpt: "نحلل، باستخدام نموذج roofline، المفارقة التي تجعل DeepSeek V4 Flash بحجم 284B مليار معلمة يسعّر رموز الإخراج بأرخص بخمسة أضعاف من Qwen3.6 بحجم 35B. من قراءات ذاكرة KV المؤقتة إلى اقتصاديات تجميع الدفعات في MoE وصولاً إلى حسابات صيغة الخدمة على 8xH100، نستعرض البنية الحقيقية لتكلفة الاستدلال بالأرقام."
seo_title: "تحليل بنية تكلفة استدلال النماذج اللغوية الكبيرة: ذاكرة KV المؤقتة واقتصاديات خدمة MoE - Thaki Cloud"
seo_description: "نحلل البنية الحقيقية لتكلفة استدلال النماذج اللغوية الكبيرة من خلال مفارقة التسعير بين DeepSeek V4 Flash وQwen3.6، بما في ذلك قراءات ذاكرة KV المؤقتة، واقتصاديات تجميع الدفعات في MoE، وحسابات roofline على 8xH100."
date: 2026-07-05
tags:
  - LLM-الاستدلال
  - KV-التخزين-المؤقت
  - MoE
  - vLLM
  - تكلفة-الخدمة
  - DeepSeek
  - Qwen
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/llmops/llm-inference-economics-kv-cache-moe-roofline/
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/llm-inference-economics-kv-cache-moe-roofline/"
categories:
  - llmops
header:
  teaser: /assets/images/llm-inference-economics-kv-cache-moe-roofline-hero.webp
---

![بنية تكلفة استدلال النماذج اللغوية الكبيرة]({{ '/assets/images/llm-inference-economics-kv-cache-moe-roofline-hero.webp' | relative_url }})

## نظرة عامة: مفارقة أن يكون نموذج أكبر بثمانية أضعاف أرخص بخمسة أضعاف

طرح سؤال مثير للاهتمام مؤخراً في مجتمع بنية استدلال النماذج. فـ DeepSeek V4 Flash، وهو نموذج بإجمالي 284 مليار معلمة، يسعّر رموز الإخراج (output) بأرخص بنحو خمسة أضعاف من Qwen3.6-35B-A3B البالغ 35 مليار معلمة. وإذا نظرنا إلى الأسعار الفعلية، نجد أن رموز الإدخال (input) لكلا النموذجين متقاربة عند نحو 0.14 دولار لكل مليون رمز، لكن رموز الإخراج تبلغ 0.18-0.28 دولار لكل مليون رمز في DeepSeek V4 Flash، مقابل 1.00-1.49 دولار لكل مليون رمز في Qwen3.6.

وهناك ما هو أغرب من ذلك. فمن حيث المعلمات النشطة لكل رمز، يستخدم Qwen3.6 نحو 3 مليارات معلمة بينما يستخدم DeepSeek V4 Flash نحو 13 مليار معلمة. أي أن Qwen، من ناحية حجم الحوسبة، أخف بأربعة أضعاف تقريباً، ومع ذلك يسير سعر السوق في الاتجاه المعاكس تماماً. وهكذا تنكسر مرتين متتاليتين الفكرة البديهية القائلة إن عدد المعلمات يساوي التكلفة.

يشرّح هذا المقال تلك المفارقة على ثلاثة مستويات: أولاً، لماذا يكون الحد المهيمن في تكلفة فك الترميز (decode) هو قراءة الذاكرة وليس الحوسبة؛ ثانياً، التوتر البنيوي بين عمق ذاكرة KV المؤقتة والتسعير الثابت؛ وثالثاً، ما الذي يظهر عند حساب صيغة الخدمة المثلى على 8xH100 مباشرة باستخدام نموذج roofline. وبالنسبة لجهة مثل ThakiCloud تقدم خدمة النماذج مباشرة في بيئات العملاء، فإن هذه البنية تتحول مباشرة إلى قدرة تنافسية في التكلفة، لذا نستعرض أيضاً الدلالات العملية لذلك.

## التحقق من الحقائق المعمارية للنموذجين

لنبدأ أولاً بتحديد المواصفات بدقة.

DeepSeek V4 Flash هو نموذج MoE بإجمالي 284 مليار معلمة و13 مليار معلمة نشطة. يختار الموجّه (router) أفضل 6 خبراء (top-6) من بين 256 خبيراً موجَّهاً (routed expert) بالإضافة إلى خبير مشترك واحد (shared expert). أما الانتباه (attention) فهو مكدس هجين يجمع بين CSA (الانتباه المتفرق المضغوط) وHCA (الانتباه شديد الضغط)، حيث يقرأ فقط أفضل 1,024 مُدخلاً مضغوطاً من ذاكرة KV المؤقتة في كل تمريرة استعلام. ووفقاً للمصادر الرسمية، عند سياق يبلغ مليون رمز (1M) يخفّض ذلك عمليات الفاصلة العائمة (FLOPs) لكل رمز إلى 27%، وذاكرة KV المؤقتة إلى 10% مقارنة بـ V3.2. أما نقطة التفتيش (checkpoint) فهي بصيغة مختلطة، حيث تكون خبراء MoE بصيغة FP4 والباقي بصيغة FP8.

Qwen3.6-35B-A3B هو نموذج MoE بإجمالي 35 مليار معلمة و3 مليارات معلمة نشطة (256 خبيراً، 8 موجَّهين + خبير مشترك واحد). والانتباه هجين بين طبقات انتباه خطي من نوع Gated DeltaNet وطبقات انتباه كامل (full attention) (برأسي KV اثنين، وبُعد رأس 256). السياق الأصلي يبلغ 262 ألف رمز، ويمتد حتى مليون رمز عبر تقنية YaRN. وعند نقطة تفتيش بصيغة FP8 يبلغ حجمه نحو 35 جيجابايت، ما يجعله يتسع في وحدة H100 واحدة.

وباختصار، كلا النموذجين تصميمان حديثان وموجهان نحو الكفاءة. وما يجعل هذه المقارنة أكثر إثارة هو أن Qwen ليس مكلفاً لأنه مجرد نموذج كثيف (dense) ساذج.

## البنية الحقيقية لتكلفة فك الترميز: نموذج roofline

توليد الرموز (فك الترميز) مقيد بعرض النطاق الترددي للذاكرة، لا بالحوسبة. والتقريب من الدرجة الأولى لزمن خطوة فك الترميز هو كالتالي.

```text
T_step = (بايتات الأوزان المطلوب قراءتها + مجموع بايتات قراءة KV لكل طلب) / عرض النطاق الترددي للذاكرة
throughput = حجم الدفعة (batch_size) / T_step
```

وهنا يختلف طابع الحدّين اختلافاً تاماً.

قراءة الأوزان (weight) تتقاسمها الدفعة. فإذا قُرئت الأوزان مرة واحدة في كل خطوة، فإن جميع الطلبات داخل الدفعة تشترك في هذه القراءة. فعند دفعة بحجم 512، تنخفض تكلفة الأوزان لكل رمز إلى 1/512. وهذا هو سبب أن إجمالي معلمات MoE يصبح "شبه مجاني عند الدفعات الكبيرة".

أما قراءة ذاكرة KV المؤقتة فهي منفصلة لكل طلب. فكل طلب يجب أن يقرأ ذاكرة KV الخاصة بسياقه، وهذه التكلفة لا تتوزع حتى مع تكبير الدفعة. وتزداد خطياً كلما ازداد عمق السياق.

لذلك، عندما تكون الدفعة كبيرة بما يكفي ويطول السياق، يتحول الحد المهيمن في التكلفة من الأوزان إلى قراءة ذاكرة KV. غير أن تسعير واجهة برمجة التطبيقات (API) ثابت لكل رمز بغض النظر عن عمق السياق: فالطلب الذي يحمل تاريخاً بطول 32 ألف رمز والطلب الذي يحمل تاريخاً بطول 500 ألف رمز يدفعان السعر نفسه لكل رمز إخراج. ومن منظور مزوّد الخدمة، فإن النموذج القادر على إبقاء قراءة ذاكرة KV محدودة بغض النظر عن العمق هو الذي يحقق هامش ربح ضمن نظام التسعير الثابت.

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
<div class="d3-arch" data-arch-root id="nomicskvcachemoeroofline-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 616, "height": 806, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 277, "y": 24, "w": 177, "h": 46, "title": "تكلفة خطوة فك الترميز"}, {"id": "B", "x": 425, "y": 148, "w": 121, "h": 46, "title": "قراءة الأوزان"}, {"id": "C", "x": 154, "y": 148, "w": 184, "h": 46, "title": "قراءة ذاكرة KV المؤقتة"}, {"id": "B1", "x": 386, "y": 272, "w": 198, "h": 78, "title": ["تتقاسمها الدفعة بأكملها", "تنقسم إلى 1/512 عند دفعة", "512"]}, {"id": "C1", "x": 161, "y": 280, "w": 170, "h": 62, "title": ["تحدث لكل طلب على حدة", "لا تتوزع مع الدفعة"]}, {"id": "D", "x": 177, "y": 428, "w": 138, "h": 52, "title": "عمق السياق"}, {"id": "E", "x": 270, "y": 572, "w": 205, "h": 62, "title": ["يزداد بما يتناسب مع العمق", "قراءة O(L)"]}, {"id": "F", "x": 24, "y": 572, "w": 191, "h": 62, "title": ["1,024 مُدخلاً ثابتاً", "ثابت بغض النظر عن العمق"]}, {"id": "G", "x": 298, "y": 712, "w": 149, "h": 62, "title": ["انفجار التكلفة", "عند السياق الطويل"]}, {"id": "H", "x": 42, "y": 712, "w": 156, "h": 62, "title": ["تأمين الهامش", "ضمن التسعير الثابت"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[410, 70], [485, 109], [485, 109], [485, 148]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[321, 70], [246, 109], [246, 109], [246, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [485, 194, 485, 272]}, {"src": "C", "dst": "C1", "kind": "data", "line": [246, 194, 246, 280]}, {"src": "C1", "dst": "D", "kind": "data", "line": [246, 342, 246, 428]}, {"src": "D", "dst": "E", "kind": "data", "label": "\"الانتباه القياسي\"", "curve": [[292, 480], [373, 526], [373, 526], [373, 572]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "\"الانتباه المتفرق CSA/HCA\"", "curve": [[200, 480], [120, 526], [120, 526], [120, 572]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "line": [373, 634, 373, 712]}, {"src": "F", "dst": "H", "kind": "data", "line": [120, 634, 120, 712]}]});
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
      const container = document.getElementById('nomicskvcachemoeroofline-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nomicskvcachemoeroofline-1';
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

## صيغة الخدمة على 8xH100: مقارنة بالأرقام

لننتقل الآن إلى وضع النموذجين فعلياً على 8xH100 (طراز SXM5، بذاكرة 80 جيجابايت HBM3 لكل وحدة، وعرض نطاق 3.35 تيرابايت/ثانية لكل وحدة، بإجمالي 640 جيجابايت، وتجميع إجمالي 26.8 تيرابايت/ثانية). وحددنا التكلفة بالساعة عند نحو 20 دولاراً وفق نموذج الطلب عند الحاجة (on-demand).

وفرضيات النمذجة هي كالتالي: يمتلك Qwen3.6 أوزاناً بصيغة FP8 تبلغ نحو 35 جيجابايت؛ وبافتراض أن 10 من طبقاته الهجينة الأربعين هي طبقات انتباه كامل، فإن ذاكرة KV لكل رمز تبلغ نحو 10 كيلوبايت [تقدير] (رأسا KV اثنان × بُعد 256 × 2 لـ K/V × 10 طبقات × بايت واحد). أما DeepSeek V4 Flash فوزنه الفعلي يبلغ نحو 150 جيجابايت [تقدير] بخبراء بصيغة FP4 وطبقات كثيفة (dense) بصيغة FP8؛ وذاكرة KV المخزَّنة، استناداً إلى الادعاء الرسمي بنسبة 10% مقارنة بـ V3.2، تبلغ نحو 3.5 كيلوبايت لكل رمز [تقدير]، بينما تكون القراءة عند فك الترميز ثابتة عند نحو 4 ميغابايت لكل طلب في كل خطوة عبر أفضل 1,024 مُدخلاً.

### صيغة الخدمة تختلف من الأساس

الصيغة المثلى لـ Qwen3.6 هي ثماني نسخ مستقلة (DP8). وبما أن النموذج يتسع في وحدة واحدة، فلا يوجد أي اتصال بين وحدات المعالجة على الإطلاق، ويتبقى نحو 38 جيجابايت من ميزانية ذاكرة KV لكل وحدة. وهذه هي صيغة الخدمة النموذجية للتصميم الموجَّه نحو الاستضافة المحلية.

أما DeepSeek V4 Flash فيتطلب تجميع الوحدات الثماني كلها في مجموعة واحدة من نوع TP/EP. وفي مقابل اتصال all-to-all الذي يفرضه ذلك، تشترك الدفعة بأكملها في ميزانية ذاكرة KV تبلغ نحو 490 جيجابايت.

### حسابات الإنتاجية حسب عمق السياق

هذه نتائج حسابات roofline (والقيم المتحققة فعلياً عادة ما تكون 50-60% من هذه الأرقام، ولا تشمل اتصال EP ولا مرحلة prefill).

عند سياق 8 آلاف رمز (8K)، تعمل مجموعة Qwen بمعدل نحو 76 ألف رمز/ثانية وDeepSeek V4 Flash بنحو 90 ألف رمز/ثانية، وهما متقاربان. وإذا أُخذ في الحسبان عبء الاتصال، فإن Qwen يصبح في الواقع أفضل. وهذا يعني أنه عند السياق القصير، يكون النموذج الأصغر أرخص من الناحية الحوسبية أو مكافئاً له.

عند 32 ألف رمز (32K) تبدأ الفجوة بالاتساع. إذ ترتفع قراءة ذاكرة KV لكل طلب في Qwen إلى 320 ميغابايت، فينخفض إلى نحو 31 ألف رمز/ثانية، بينما يحافظ DeepSeek V4 Flash على نحو 90 ألف رمز/ثانية لأن قراءة ذاكرة KV لديه لا تزال ثابتة. أي فارق يقارب ثلاثة أضعاف.

عند 256 ألف رمز (256K)، تصل ذاكرة KV لكل طلب في Qwen إلى 2.56 جيجابايت، ويؤدي سقف التخزين إلى تقييد حجم الدفعة لكل وحدة عند 14، فينخفض إلى نحو 5.3 آلاف رمز/ثانية. أما DeepSeek V4 Flash فيعمل بنحو 45 ألف رمز/ثانية، بفارق قدره 8.5 أضعاف.

عند مليون رمز (1M)، يتعين على Qwen قراءة 10 جيجابايت لكل طلب في كل خطوة، فينخفض إلى نحو 1.2 ألف رمز/ثانية بسقف 24 جلسة متزامنة. أما DeepSeek V4 Flash فيعمل بنحو 11 ألف رمز/ثانية مع 64 جلسة متزامنة، بفارق يقترب من عشرة أضعاف.

وبتحويل ذلك إلى دولارات، عند 32K يكون السعر 0.18 دولار لكل مليون رمز لـ Qwen مقابل 0.06 دولار لكل مليون رمز لـ DeepSeek V4 Flash؛ وعند 1M يكون 4.6 دولار لكل مليون رمز لـ Qwen مقابل 0.5 دولار لكل مليون رمز لـ DeepSeek V4 Flash. وفي النطاق من عشرات إلى مئات الآلاف من الرموز، وهو متوسط العمق لأحمال العمل الوكيلية (agentic)، تتسع فجوة التكلفة إلى 3-10 أضعاف، وهو ما يقع بالضبط في نفس رتبة حجم فارق أسعار واجهة برمجة التطبيقات الملحوظ (نحو خمسة أضعاف).

![مقارنة الإنتاجية والتكلفة حسب عمق السياق]({{ '/assets/images/llm-inference-economics-kv-cache-moe-roofline-results.webp' | relative_url }})

وهناك أمر يجدر الإفصاح عنه بأمانة: يوجد تباين يصل إلى 40 ضعفاً بين المصادر العامة بخصوص ذاكرة KV المخزَّنة لكل رمز في DeepSeek V4 Flash (إذ يتعارض ادعاء وثائق vLLM recipes بنسبة "10% مقارنة بـ V3.2" مع جدول ذاكرة KV في بعض أدلة النشر). وقد اعتمد الحساب أعلاه على الادعاء الأول، الأقرب إلى مصدر أولي، ونشدد على أن الاستنتاج يستند إلى اتجاه التوسع (بنية اتساع الفجوة مع تزايد العمق) لا إلى القيم المطلقة.

## ثلاثة أمور يكشفها الحساب

أولاً، عنق الزجاجة في Qwen ليس تخزين ذاكرة KV بل قراءتها. فبفضل Gated DeltaNet، التخزين (نحو 10 كيلوبايت لكل رمز) ممتاز بالفعل. المشكلة أن قراءة O(L) في طبقات الانتباه الكامل تتكرر في كل خطوة فك ترميز. أما DeepSeek V4 Flash فتخزينه صغير أيضاً، وقراءته مقيدة بثابت تماماً.

ثانياً، تمتص الدفعة قراءة أوزان MoE البالغة 284 مليار معلمة. فعند دفعة كبيرة، تكون قراءة الأوزان لكل خطوة ثابتة عند نحو 150 جيجابايت، وهو ما يصل إلى 0.3 جيجابايت لكل رمز عند توزيعه على 512 رمزاً. في المقابل، تقرأ كل وحدة في Qwen بنمط DP8 نحو 35 جيجابايت بشكل مستقل، ما يصل إجمالاً إلى 280 جيجابايت لكل خطوة على مستوى العنقود (cluster). وهكذا ينعكس الفارق البالغ ثمانية أضعاف في إجمالي المعلمات عند النظر إلى القراءة الفعلية.

ثالثاً، رغم أن Qwen أرخص من الناحية الحوسبية عند السياق القصير، فإن سعره في السوق أعلى بخمسة أضعاف. وهذا دليل كمّي على أن قائمة الأسعار لا تعكس التكلفة الفعلية. فـ DeepSeek يشغّل واجهة برمجة تطبيقاته الخاصة (1st-party API) بحجم حركة مرور ضخم، وينقل إلى التسعير وفورات التكلفة الناتجة عن تحسينات البنية التحتية، مثل النوى المخصصة (deep_gemm_mega_moe، وذاكرة مؤشر FP4)، وفصل مرحلتي prefill وdecode، وMTP، وخصم بنسبة 98% عند إصابة الذاكرة المؤقتة (cache hit). أما Qwen3.6-35B، الذي صُمم أساساً للاستخدام المحلي أو وحدة معالجة رسوميات واحدة، فإن خدمته عبر واجهة برمجة التطبيقات تتولاها غالباً جهات خارجية باستخدام مكدس vLLM عام؛ وعندما تكون كثافة حركة المرور منخفضة، يتعين إدماج وقت خمول وحدة المعالجة ضمن السعر، ما يرفع السعر المعروض. وسعر السوق دالة على كثافة الطلب ومستوى التحسين، لا على التكلفة الفعلية.

## دلالات التطبيق على منتج ThakiCloud

يرتبط هذا التحليل ارتباطاً مباشراً بالقرارات التي تواجهها منصة ai-platform من ThakiCloud يومياً. فعند خدمة النماذج على وحدات معالجة الرسوميات الخاصة بالعملاء في بيئات السحابة المحلية (on-prem) والسحابة السيادية، فإن ما يحدد تكلفة الرمز على العتاد نفسه ليس حجم النموذج بل صيغة الخدمة. وكما توضح الحسابات أعلاه، يمكن أن تختلف الإنتاجية الفعلية بعدة أضعاف على نفس تكوين 8xH100 تبعاً للاختيار بين DP8 ومجموعة TP/EP، ونوع بيانات ذاكرة KV المؤقتة (dtype)، وإعداد max-model-len. وتعتمد ai-platform كإجراء قياسي ضبط معاملات خدمة vLLM، فوق جدولة وحدات معالجة الرسوميات القائمة على K8s وKueue، بما يتناسب مع ملف حمل العمل (متوسط عمق السياق، وعدد الجلسات المتزامنة)، ونموذج roofline في هذا المقال هو نقطة انطلاق ذلك التحجيم (sizing).

وهناك أيضاً بُعد يتعلق بأحمال عمل الوكلاء (agents). ففي Paxis (السحابة الأصيلة للوكلاء من ThakiCloud)، ينتج الوكلاء تاريخاً طويلاً واستدعاءات أدوات (tool call) متكررة، وهذا بالضبط نوع حركة المرور الذي يدفع عمق ذاكرة KV إلى العمق. والاستنتاج العملي لهذا التحليل هو أن الجمع بين نموذج يظل قوياً عند السياق العميق وبنية تحتية للتخزين المؤقت للسوابق (prefix cache) هو ما يحدد اقتصاديات الوكلاء. فتكلفة الخدمة المنخفضة (ai-platform) هي ما ينتج اقتصاديات وحدة الوكيل (Paxis).

## القيود والحجج المضادة

لنوضح قيود هذا التحليل صراحة. أولاً، roofline نموذج للحد الأعلى. فالإنتاجية الفعلية عادة ما تكون عند 50-60% من هذه الأرقام بسبب كفاءة النوى (kernels)، واتصال all-to-all في EP، والتداخل بين prefill وdecode، بينما تدفع تقنيات تنبؤية مثل MTP الإنتاجية في الاتجاه المعاكس إلى الأعلى. ثانياً، تتعارض أرقام ذاكرة KV لدى DeepSeek V4 Flash بين المصادر العامة، لذا أبقينا على وسم [تقدير]. ثالثاً، عدد طبقات الانتباه الكامل في Qwen3.6 تقدير مبني على الإعداد (config) العام، وتتغير القيم المطلقة إذا اختلفت نسبة الهجين. رابعاً، الجودة محور منفصل: فـ DeepSeek V4 Flash أضعف من V4 Pro في الاستدلال متعدد الخطوات المعقد، لذا فإن اختيار النموذج بناءً على التكلفة وحدها استنتاج خاطئ. ويجيب هذا التحليل الخاص بالتكلفة فقط على سؤال: أي صيغة خدمة اقتصادية عند مستوى ثابت ومحدد من متطلبات الجودة.

## المراجع

- [vLLM Recipes: DeepSeek-V4-Flash](https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4-Flash)
- [vLLM Recipes: Qwen3.6-35B-A3B](https://recipes.vllm.ai/Qwen/Qwen3.6-35B-A3B)
- [DeepSeek API Docs: Models & Pricing](https://api-docs.deepseek.com/quick_start/pricing)
- [OpenRouter: DeepSeek V4 Flash](https://openrouter.ai/deepseek/deepseek-v4-flash)
- [OpenRouter: Qwen3.6 35B A3B](https://openrouter.ai/qwen/qwen3.6-35b-a3b)
- [مدونة Qwen الرسمية: Qwen3.6-35B-A3B](https://qwen.ai/blog?id=qwen3.6-35b-a3b)
- [Spheron: Deploy DeepSeek V4-Flash on GPU Cloud](https://www.spheron.network/blog/deploy-deepseek-v4-flash-gpu-cloud/)
