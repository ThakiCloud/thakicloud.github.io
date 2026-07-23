---
title: "‏Qwen3.6-27B بدقة 4 بت: لماذا نزل تكميم NVFP4 إلى معمارية Hopper"
excerpt: "نموذج Qwen3.6-27B-NVFP4 من NVIDIA يضغط نموذج استدلال بـ 27 مليار معامل ذا انتباه هجين إلى 4 بت، فيخفض الذاكرة بنحو 2.5 ضعف مع إبقاء فجوة المعايير ضمن نقطة واحدة عن FP8. وخلافاً لإصدار Gemma NVFP4 السابق الذي كان يتطلب Blackwell عملياً، يذكر هذا الإصدار معمارية Hopper ضمن العتاد المدعوم، فيستطيع أي فريق يشغّل H100/H200 تجربته على خوادمه الخاصة اليوم. نستعرض حقائق النموذج وآلية NVFP4 ومسار الخدمة ومنظور ThakiCloud."
seo_title: "دليل خدمة Qwen3.6-27B-NVFP4 على الخوادم الخاصة - تكميم 4 بت لـ Hopper/Blackwell - Thaki Cloud"
seo_description: "خدمة Qwen3.6-27B-NVFP4 (27 مليار معامل، انتباه هجين، سياق 262 ألف رمز، استدلال متعدد الوسائط) عبر vLLM: تكميم NVFP4 رباعي البت يخفض الذاكرة نحو 2.5 ضعف، والمعايير ضمن نقطة واحدة من FP8. دعم Hopper وBlackwell، رخصة Apache 2.0. منظور خدمة ThakiCloud على K8s وعمّال الوكلاء."
date: 2026-07-01
last_modified_at: 2026-07-01
tags:
  - qwen3
  - nvfp4
  - quantization
  - hopper
  - blackwell
  - hybrid-attention
  - multimodal
  - vllm
  - on-premise
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/owm/qwen3-6-27b-nvfp4-onprem-serving/"
lang: ar
reading_time: true
categories:
  - owm
---

⏱️ **وقت القراءة المتوقع**: 11 دقيقة

![مخطط مفاهيمي لتكميم Qwen3.6-27B NVFP4 رباعي البت]({{ '/assets/images/qwen3-6-27b-nvfp4-onprem-serving-hero.webp' | relative_url }})

## نظرة عامة

أصدرت NVIDIA النموذج `nvidia/Qwen3.6-27B-NVFP4`، وهو نسخة مكمّمة بدقة NVFP4 رباعية البت من نموذج Qwen3.6-27B الخاص بشركة Alibaba. يضغط نموذج استدلال بـ 27 مليار معامل ذا انتباه هجين إلى 4 بت، فيخفض ذاكرة الأوزان بنحو 2.5 ضعف مع إبقاء الفجوة عن خط أساس FP8 ضمن نقطة واحدة عبر المعايير التسعة كلها. والرخصة هي Apache 2.0.

هناك ثلاث نقاط جديرة بالتوضيح. أولاً، خلافاً لإصدار `Gemma-4-26B-A4B-NVFP4` السابق الذي لم يحصل على تسريع 4 بت عملياً إلا على Blackwell، تذكر بطاقة هذا الإصدار **معماريتَي Hopper وBlackwell معاً ضمن العتاد المدعوم**. أي أن الفريق الذي يشغّل H100 أو H200 يستطيع تجربته اليوم دون شراء عتاد جديد. ثانياً، هذا ليس نموذجاً لغوياً نصياً فقط بل **نموذج استدلال متعدد الوسائط يستقبل مدخلات نصية وصورية وفيديو**. ثالثاً، تتسع نافذة السياق حتى **262 ألف رمز**، فتستوعب المستندات الطويلة والمحادثات الممتدة دفعة واحدة.

تشغّل ThakiCloud منصة تدير حصص وحدات GPU عبر Kueue وتخدم النماذج بأسلوب متعدد المستأجرين عبر vLLM على Kubernetes. لذا فإن سؤال "كم نموذجاً أكبر، وكم مستأجراً إضافياً، يمكننا وضعه على وحدات GPU التي نملكها أصلاً؟" ليس خبراً طريفاً بل يغذّي نموذج التكلفة مباشرة. يستعرض هذا المقال حقائق النموذج، ويحلل سبب نزول NVFP4 إلى Hopper، ثم يقيّم بصراحة مسار الخدمة وفائدته على منصتنا.

## ما هذا النموذج

`nvidia/Qwen3.6-27B-NVFP4` هو نموذج `Qwen3.6-27B` من Alibaba مكمّماً بدقة NVFP4 عبر NVIDIA Model Optimizer (nvidia-modelopt v0.45.0). وفيما يلي المواصفات الأساسية حسب بطاقة النموذج.

| العنصر | القيمة |
|---|---|
| النموذج الأساسي | Alibaba Qwen3.6-27B |
| المعمارية | انتباه هجين (Gated DeltaNet + Gated Attention) |
| إجمالي المعاملات | 27 مليار |
| السياق | 262 ألف رمز |
| وسائط الإدخال | نص + صورة + فيديو |
| الإخراج | نص |
| التكميم | NVFP4 (Model Optimizer v0.45.0) |
| العتاد المستهدف | NVIDIA Hopper، Blackwell |
| الرخصة | Apache 2.0 |

الجزء اللافت هو معمارية **الانتباه الهجين**. فـ Gated DeltaNet مسار من فئة الانتباه الخطي، مصمَّم لمعالجة المتتاليات الطويلة بكفاءة، خلافاً للانتباه المعتاد الذي تنمو كلفته مع طول المتتالية. ومزجه مع Gated Attention الذي يحمل القدرة التعبيرية يمنح توازناً يستوعب سياقاً بطول 262 ألف رمز مع الحفاظ على الجودة. كما أن اشتراط `--reasoning-parser qwen3` عند الخدمة يؤكد أن هذا **نموذج استدلال** يولّد أثر التفكير قبل الإجابة النهائية.

ونذكر بصراحة أمراً واحداً: تذكر بطاقة النموذج الانتباه الهجين لكنها لا تفصح عن عدد الطبقات الدقيق أو تكوين الخبراء أو المعاملات النشطة لكل رمز. لذا يقتصر هذا المقال على الحقائق المذكورة في البطاقة ولا يقدّر الأرقام غير المعلنة.

## تكميم NVFP4: ماذا يُضغط وكيف

‏NVFP4 هو صيغة الفاصلة العائمة رباعية البت التي تدفع بها NVIDIA. وخلافاً لـ INT4 الذي يقتطع الأوزان إلى أعداد صحيحة رباعية البت ببساطة، فهو أسلوب قياس مصغّر يضع مقياس FP8 لكل كتلة صغيرة، فينعم بتوفير الذاكرة على مستوى 4 بت مع إبقاء فقدان الدقة صغيراً.

في هذا الإصدار، أهداف التكميم هي **أوزان وقيم تنشيط المعاملات الخطية داخل كتل المحوّل**. أما الطبقات غير الخطية فتُترك دون مساس. وتذكر البطاقة أن خفض عدد البتات لكل معامل من 16 إلى 4 يقلّص متطلبات القرص وذاكرة GPU بنحو **2.5 ضعف**. فتحميل 27 مليار معامل بدقة BF16 يحتاج نحو 54 جيجابايت، وبتطبيق الخفض بنحو 2.5 ضعف تنزل نقطة التفتيش إلى نحو 20 جيجابايت. وهذا يفتح مجالاً لوضع أكثر من ضعف النموذج على وحدة GPU نفسها، أو لتحويل الذاكرة المحرَّرة إلى مخزن KV لرفع التزامن.

وهنا يفترق الأمر عن مراجعة Gemma NVFP4 السابقة. فقد كان لدى إصدار Gemma نواة NVFP4 لنماذج MoE معطّلة على Blackwell الاستهلاكي والاحترافي (SM120)، فكان المسار الاستهلاكي الوحيد الذي يعمل فعلاً هو DGX Spark. أما إصدار Qwen3.6 هذا فتذكر بطاقته **معماريتَي Hopper وBlackwell معاً ضمن العتاد المدعوم**، وتستخدم الخدمة مسار `--quantization modelopt` في vLLM. ومع تكميم قيم التنشيط إلى جانب الأوزان ووجود مسار خدمة modelopt، يمكن تشغيل هذا النموذج رباعي البت على وحدات H100 وH200 المثبتة أصلاً في مراكز البيانات. لقد تراخى هذه المرة بشكل ملموس قيد "يجب شراء Blackwell جديد لرؤية مكاسب 4 بت".

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
<div class="d3-arch" data-arch-root id="n3627bnvfp4onpremserving-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 374, "height": 850, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 128, "y": 24, "w": 121, "h": 62, "title": ["Qwen3.6-27B", "BF16 نحو 54GB"]}, {"id": "B", "x": 96, "y": 164, "w": 184, "h": 62, "title": ["NVIDIA Model Optimizer", "v0.45.0"]}, {"id": "C", "x": 89, "y": 304, "w": 198, "h": 94, "title": ["تكميم NVFP4", "أوزان المعاملات الخطية +", "التنشيط", "من 16 بت إلى 4 بت"]}, {"id": "D", "x": 93, "y": 476, "w": 191, "h": 62, "title": ["نقطة تفتيش NVFP4", "نحو 20GB · خفض ~2.5 ضعف"]}, {"id": "E", "x": 93, "y": 616, "w": 191, "h": 62, "title": ["خدمة vLLM", "--quantization modelopt"]}, {"id": "F", "x": 221, "y": 756, "w": 121, "h": 62, "title": ["NVIDIA Hopper", "H100 / H200"]}, {"id": "G", "x": 24, "y": 756, "w": 142, "h": 62, "title": ["NVIDIA Blackwell", "B200 وغيرها"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [188, 86, 188, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [188, 226, 188, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [188, 398, 188, 476]}, {"src": "D", "dst": "E", "kind": "data", "line": [188, 538, 188, 616]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[230, 678], [282, 717], [282, 717], [282, 756]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[147, 678], [95, 717], [95, 717], [95, 756]]}]});
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
      const container = document.getElementById('n3627bnvfp4onpremserving-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'n3627bnvfp4onpremserving-1';
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

## المعايير: كم تكلّف الدقة الرباعية

تعرض بطاقة النموذج النسخة المكمّمة بـ NVFP4 جنباً إلى جنب مع خط أساس FP8 عبر تسعة معايير.

| المعيار | FP8 | NVFP4 | مجال القياس |
|---|---|---|---|
| MMLU Pro | 86.1 | 86.3 | المعرفة العامة والاستدلال |
| GPQA Diamond | 86.0 | 85.5 | الاستدلال العلمي للدراسات العليا |
| HLE | 21.7 | 21.8 | الاستدلال العام الصعب |
| τ²-Bench Telecom | 95.2 | 95.4 | استخدام الوكيل للأدوات |
| MMMU Pro | 74.6 | 74.3 | الاستدلال متعدد الوسائط |
| SciCode | 44.8 | 44.5 | البرمجة العلمية |
| AIME 2025 | 93.1 | 92.7 | مسابقة الرياضيات |
| AA-LCR | 68.8 | 68.3 | الاستدلال ذو السياق الطويل |
| IFBench | 65.1 | 65.5 | اتباع التعليمات |

جميع البنود التسعة ضمن نقطة واحدة من FP8. وفي MMLU Pro وHLE وτ²-Bench Telecom وIFBench يتفوق إصدار NVFP4 بفارق ضئيل، والأسلم قراءة ذلك ضمن تباين القياس. الاتجاه واضح: **الجودة محفوظة عملياً تحت 4 بت**، وهنا تظهر ميزة NVFP4 على INT4.

كما يشير تكوين المعايير نفسه إلى طابع النموذج. فـ τ²-Bench Telecom يقيس وكيلاً يستدعي الأدوات لإنجاز المهام، وAA-LCR يقيس الاستدلال ذا السياق الطويل، وMMMU Pro يقيس الفهم متعدد الوسائط. أي أن هذا النموذج يستهدف **استخدام الأدوات لدى الوكلاء، والسياق الطويل، وتعدد الوسائط**، لا مجرد أسئلة المعرفة. ومع ذلك، لا تظهر مهام النطاق الكوري في المعايير العامة، لذا نوصي بتحقق منفصل عبر مجموعة تقييم داخلية قبل التبني.

## دليل الخدمة

المسار الموصى به في بطاقة النموذج هو vLLM. وأمر التشغيل كالآتي.

```bash
vllm serve nvidia/Qwen3.6-27B-NVFP4 \
  --port 8000 \
  --quantization modelopt \
  --max-model-len 262144 \
  --reasoning-parser qwen3
```

ثلاث نقاط تشغيلية مهمة. أولاً، `--quantization modelopt` هو العلَم الأساسي الذي يحمّل نقطة تفتيش NVFP4. ثم `--reasoning-parser qwen3` لازم كي يُحلَّل أثر التفكير والإجابة النهائية تحليلاً صحيحاً. وأخيراً `--max-model-len 262144` يفتح سياق 262 ألف رمز كاملاً، وتنمو ميزانية مخزن KV تبعاً لذلك، فالأكفأ للذاكرة خفضه إلى الطول الذي تحتاجه فعلاً.

يفترض العتاد Hopper أو Blackwell، ونظام التشغيل Linux. وبفضل دعم Hopper، يمكنك التحقق من مسار الخدمة على عُقد H100 وH200 الموجودة أصلاً في مركز البيانات دون معدات إضافية.

## منظور خدمة ThakiCloud

تشغّل ThakiCloud منصة AI/ML قائمة على K8s تدير حصص GPU عبر Kueue وتخدم النماذج بأسلوب متعدد المستأجرين عبر vLLM. وتأتي دلالات هذا النموذج على نموذج تشغيلنا من اتجاهين: البنية التحتية والوكلاء.

**مضاعفة الكثافة على أصول Hopper القائمة.** هذه أبرز قيمة عملية لهذا الإصدار. فدعم NVFP4 لـ Hopper يعني إمكان جني مكسب 4 بت على H100 وH200 التي تملكها أصلاً، دون استثمار جديد في Blackwell. وحين تنزل أوزان نموذج بـ 27 مليار معامل إلى نحو 20 جيجابايت، يمكنك وضع مزيد من نسخ النموذج على وحدة GPU نفسها، أو تحويل الذاكرة المحرَّرة إلى مخزن KV لضبط حدود تزامن سخية لكل مستأجر. ومن منظور حصص Kueue، تتحمل البطاقة نفسها عبئاً أكبر، فتنخفض تكلفة الوحدة ببساطة.

**مرشح على الخوادم الخاصة لعامل استدلال متعدد الوسائط.** إن Paxis، مستوى التحكم بالوكلاء لدى ThakiCloud، سحابةٌ أصيلة الوكلاء تشغّل المهارات في صناديق رمل معزولة وتمرّر كل إجراء عبر بوابات السياسات وسجلات التدقيق. وفي هذه البنية يقرأ عدد من العمّال المستندات ويستدعون الأدوات وينجزون المهام. ويتميز Qwen3.6-27B-NVFP4 في معايير استخدام الأدوات لدى الوكلاء مثل τ²-Bench Telecom، ويستقبل الصورة والفيديو إلى جانب النص، ويستوعب سياق 262 ألف رمز. فهو مرشح مناسب للتشغيل على الخوادم الخاصة كعامل متعدد الوسائط يتعامل مع المستندات والشاشات والفيديو، وكعامل طرفي في حلقات استدعاء الأدوات. وبحسب انضباط التكلفة لدينا، شغّل العامل بثمن زهيد لكن أغلق التوسع بمرحلة تحقق على نموذج أعلى كي لا تتراكم هلوسات العامل.

**مرجع لعروض الخوادم الخاصة والامتثال.** إن تكويناً برخصة Apache 2.0 وخدمة على عقدة واحدة هو تكوين يمكن اقتراحه مباشرة على عملاء القطاع العام والمالي حيث يُحظر تسريب البيانات. وفي البيئات المقيَّدة مثل متطلبات الأمن القومي أو الذكاء الاصطناعي السيادي، يصبح تشغيل نموذج استدلال كبير متعدد الوسائط على وحدات GPU خاصة دون واجهة برمجة تجارية مساراً حقيقياً للتبني.

## القيود والاعتراضات

من باب التوازن، إليك التحفظات.

- **تفاصيل المعمارية غير معلنة.** الانتباه الهجين مذكور، لكن عدد الطبقات وتكوين الخبراء والمعاملات النشطة غائبة عن البطاقة. وحساب كفاءة الدفعة والذاكرة المقيمة بدقة يتطلب مزيداً من المعلومات.
- **لا توجد أرقام إنتاجية مقيسة.** يستند هذا المقال إلى حقائق البطاقة مثل توفير الذاكرة والمعايير. وتتفاوت سرعة الرموز لكل تدفق وحدود التزامن كثيراً بحسب العتاد والإعدادات، فأعد القياس بحمل عملك قبل التبني.
- **تباين ناتج عن تكميم التنشيط.** دفع قيم التنشيط، لا الأوزان فحسب، إلى 4 بت قد يُدخل تبايناً في الدقة على الأحمال ذات التوزيعات المائلة. وحتى مع بقاء المعايير العامة ضمن نقطة واحدة، تحقق من المهام الخاصة بالنطاق منفصلة.
- **نضج مسار الخدمة متعدد الوسائط.** استقبال الصورة والفيديو بثبات في الإنتاج يتطلب التحقق من كل من خط المعالجة الأولية ونضج مسار vLLM متعدد الوسائط.
- **التحقق من الاستخدام الكوري الفعلي.** المعايير العامة تتمحور حول الإنجليزية. ويجب التحقق من دقة RAG واستدعاء الأدوات بالكورية منفصلة عبر مجموعة تقييم داخلية.

ومع ذلك، فإن مزيج Apache 2.0، وتسريع 4 بت الذي بات يصل إلى Hopper، والاستدلال متعدد الوسائط، وسياق 262 ألف رمز، خيارٌ جذاب للمؤسسات التي تدرس الخدمة على الخوادم الخاصة. ومجرد انخفاض جدار "اشترِ عتاداً جديداً لتنال مكاسب 4 بت" يجعله جديراً بالتحقق اليوم لأي فريق يملك أسطول Hopper.

## روابط مرجعية

- [بطاقة نموذج Qwen3.6-27B-NVFP4 (Hugging Face)](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4)
- [NVIDIA TensorRT Model Optimizer](https://github.com/NVIDIA/TensorRT-Model-Optimizer)
- [التعريف بـ NVFP4 (NVIDIA Developer)](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [توثيق vLLM](https://docs.vllm.ai/)
- [مراجعة Gemma-4-26B-NVFP4 على DGX Spark (مدونة ThakiCloud)](https://thakicloud.com/tech-blog/ar/owm/gemma-4-26b-nvfp4-dgx-spark/)
