---
title: "Kimi K3: ماذا يعني فعلياً تشغيل نموذج مفتوح الأوزان بـ 2.8 تريليون معلمة"
excerpt: "أطلقت Moonshot نموذج Kimi K3، أكبر نموذج مفتوح الأوزان في العالم حتى الآن. المثير ليس فقط تفوقه على أفضل النماذج المغلقة في اختبار برمجة الواجهات الأمامية، بل السؤال الحقيقي يأتي بعد ذلك: ماذا يتطلب فعلياً تشغيل نموذج بـ 2.8 تريليون معلمة على بنيتك التحتية الخاصة؟ نستعرض هذا من منظور التشغيل لدى ThakiCloud."
date: 2026-07-18
tags:
  - KimiK3
  - 오픈웨이트
  - MoE
  - LLM서빙
  - 온프레미스
  - 소버린AI
  - LLMOps
  - 프론트엔드코딩
author_profile: true
toc: true
toc_label: حدود النماذج المفتوحة
published: true
categories:
  - llmops
  - owm
lang: ar
canonical_url: https://thakicloud.com/tech-blog/ar/llmops/kimi-k3-open-weight-frontier-serving/
---

## نظرة عامة

في 16 يوليو 2026، أطلقت شركة Moonshot AI الصينية نموذج Kimi K3. بإجمالي 2.8 تريليون معلمة، يُعد هذا أكبر نموذج مفتوح الأوزان تم الإفصاح عنه حتى الآن. وصفت وسائل إعلام عديدة هذا الإطلاق بأنه اللحظة التي وصل فيها معسكر النماذج المفتوحة الأوزان إلى مستوى الأداء المتقدم (frontier).

الجانب الذي لفت الانتباه أكثر من غيره كان الواجهة الأمامية (frontend). في اختبار من منصة تقييم الذكاء الاصطناعي Arena يقيس القدرة على بناء واجهات الويب، احتل Kimi K3 المرتبة الأولى، وفي اختبارات عمياء فضّل المطورون Kimi على Fable 5 من Anthropic وGPT-5.6 من OpenAI في برمجة الواجهات الأمامية. وقد عرضت Moonshot ذلك من خلال عرض توضيحي بنى لعبة ثلاثية الأبعاد بعالم مفتوح داخل متصفح الويب باستخدام Three.js وWebGPU.

بدلاً من تكرار ترتيب نتائج الاختبارات، تركز هذه المقالة على السؤال الذي يلي ذلك. مفتوح الأوزان يعني أن بإمكان أي شخص تشغيل هذا النموذج على بنيته التحتية الخاصة. فماذا يتطلب فعلياً تشغيل نموذج بـ 2.8 تريليون معلمة. بما أن ThakiCloud تعتبر تشغيل النماذج في البيئات المحلية (on-premise) لدى العملاء قدرة أساسية لديها، سنقرأ هذا الإطلاق من منظور المشغّل.

## ما هو Kimi K3

Kimi K3 هو نموذج بمعمارية خليط الخبراء (Mixture of Experts، أو MoE). يمتلك إجمالي 2.8 تريليون معلمة، لكن ليست جميعها تُفعّل عند معالجة كل رمز (token). وفقاً للمعلومات المُعلنة، يُفعّل النموذج 16 خبيراً من أصل 896 خبيراً، ويُقدَّر عدد المعلمات النشطة المستخدمة فعلياً في الحساب بنحو 50 مليار [تقديري]. لم تُفصح Moonshot رسمياً عن عدد المعلمات النشطة.

من الناحية المعمارية، جرى تقديم ابتكارين. الأول هو Kimi Delta Attention (KDA)، والثاني هو Attention Residuals (AttnRes). تشرح Moonshot أن هذين العنصرين معاً يرفعان الكفاءة وجودة الاستدلال في آن واحد. يبلغ طول السياق مليون رمز، وهو تصميم يُقرأ على أنه موجّه نحو أعباء عمل الوكلاء (agent) التي تتعامل مع سياقات طويلة.

يجب توخي الحذر فيما يتعلق بالترخيص. صدرت السلسلة السابقة، Kimi K2، بترخيص MIT معدّل في يوليو 2025، لكن شروط ترخيص K3 نفسها لم تكن قد تأكدت أو أُعلنت بشكل نهائي وقت كتابة هذا المقال. تصف Moonshot النموذج K3 بأنه مفتوح، وأعلنت أنها ستنشر كامل الأوزان بحلول 27 يوليو 2026، لكن حتى وقت النشر لم تكن نقاط التحقق (checkpoints) الرسمية قد ظهرت بعد على حساب Moonshot التنظيمي في Hugging Face. لذلك، فإن أي جهة تفكر في اعتماد النموذج فعلياً يجب أن تتحقق بنفسها من نص الترخيص النهائي ومن حالة توفر الأوزان.

## لماذا يهم هذا الإطلاق

لم يعد أمراً نادراً أن يتفوق نموذج مفتوح الأوزان على أفضل النماذج المغلقة في مهمة ضيقة محددة. لكن أن يحتل هذا الموقع في مجال يستخدمه المطورون يومياً، وهو برمجة الواجهات الأمامية، وبأكبر مجموعة أوزان مفتوحة في العالم، أمر يحمل دلالة مختلفة. فهذا إشارة إلى ظهور بديل يمكن تشغيله ذاتياً، بعد أن كانت الحاجة إلى الأداء وحدها تفرض الارتباط بواجهات برمجية مغلقة.

الواجهة الأمامية وتوليد واجهات المستخدم تحديداً مجال يمكن فيه رؤية النتيجة بالعين مباشرة. وفي هذا السياق يأتي تأكيد Moonshot على ما تسميه الرؤية داخل الحلقة (vision in the loop)، وهي دورة يرى فيها النموذج ما ولّده ثم يصححه. الادعاء هو أن هذه الحلقة مفيدة بشكل خاص في المهام البصرية مثل تطوير الألعاب وتصميم واجهات المستخدم والتصميم بمساعدة الحاسوب. إنه تجاوز لمجرد توليد الكود كنص، نحو اعتماد النتيجة المعروضة فعلياً كتغذية راجعة.

## ماذا يعني فعلياً تشغيل نموذج بـ 2.8 تريليون معلمة

هنا يبدأ مجال المشغّل. هناك مسافة كبيرة بين حقيقة أن النموذج مفتوح الأوزان وحقيقة أن بإمكانك تشغيله ذاتياً.

الذاكرة أولاً. تحميل كامل 2.8 تريليون معلمة بدقتها الأصلية يتطلب عدة تيرابايت من ذاكرة GPU. هذا مستوى يصعب على GPU واحد التعامل معه، بل حتى على خادم واحد يحتوي عدة وحدات GPU، مما يجعل التشغيل الموزّع عبر عقد (nodes) متعددة أمراً مفروضاً مسبقاً. غير أن بنية MoE تخفف العبء إلى حد ما. بما أن جزءاً فقط من الخبراء يُفعّل لكل رمز وليس النموذج بأكمله، يبقى حجم الحساب الفعلي قريباً من حجم المعلمات النشطة. ومع ذلك، يجب أن تبقى أوزان جميع الخبراء مقيمة في الذاكرة كي يمكن استدعاؤها في أي وقت، لذا يبقى عبء التخزين مرتبطاً بإجمالي عدد المعلمات.

لهذا السبب تصبح تقنيتان شبه إلزاميتين للتشغيل الذاتي الواقعي. الأولى هي التكميم (quantization). خفض دقة الأوزان إلى 8 بت أو 4 بت يقلل استهلاك الذاكرة ويخفض بشكل كبير عدد وحدات GPU المطلوبة. والثانية هي التوازي (parallelism). يقسّم التوازي الموتري (tensor parallelism) طبقات النموذج عبر عدة وحدات GPU، وبالنسبة لنماذج MoE، يضيف التوازي بين الخبراء (expert parallelism) توزيع الخبراء عبر عدة أجهزة. مسار التشغيل يمكن تصويره كما يلي.

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
<div class="d3-arch" data-arch-root id="penweightfrontierserving-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 479, "height": 1070, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 179, "y": 24, "w": 120, "h": 46, "title": "طلب المستخدم"}, {"id": "B", "x": 147, "y": 148, "w": 184, "h": 62, "title": ["بوابة التوجيه", "اختيار الخبراء لكل رمز"]}, {"id": "C", "x": 149, "y": 288, "w": 181, "h": 68, "title": ["الخبراء النشطون فقط", "16 of 896"]}, {"id": "D", "x": 270, "y": 434, "w": 177, "h": 62, "title": ["التوازي الموتري", "تقسيم الطبقات عبر GPU"]}, {"id": "E", "x": 24, "y": 434, "w": 191, "h": 62, "title": ["توازي الخبراء", "توزيع الخبراء عبر العقد"]}, {"id": "F", "x": 175, "y": 574, "w": 128, "h": 62, "title": ["أوزان مكمَّمة", "4-bit أو 8-bit"]}, {"id": "G", "x": 144, "y": 714, "w": 191, "h": 46, "title": "تنفيذ الاستدلال الموزّع"}, {"id": "H", "x": 179, "y": 838, "w": 120, "h": 46, "title": "بث الاستجابة"}, {"id": "I", "x": 179, "y": 976, "w": 120, "h": 62, "title": ["ذاكرة GPU", "متعددة العقد"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [239, 70, 239, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [239, 210, 239, 288]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[295, 356], [359, 395], [359, 395], [359, 434]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[183, 356], [120, 395], [120, 395], [120, 434]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[359, 496], [359, 535], [359, 535], [292, 574]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[120, 496], [120, 535], [120, 535], [186, 574]]}, {"src": "F", "dst": "G", "kind": "data", "line": [239, 636, 239, 714]}, {"src": "G", "dst": "H", "kind": "data", "line": [239, 760, 239, 838]}, {"src": "H", "dst": "I", "kind": "event", "label": "ترحيل ذاكرة التخزين المؤقت KV", "line": [239, 884, 239, 976], "lx": 239, "ly": 926}]});
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
      const container = document.getElementById('penweightfrontierserving-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'penweightfrontierserving-1';
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

هذه هي النقطة الجوهرية. مفتوح الأوزان يعني أن الأوزان مجانية، لا أن التشغيل مجاني. تشغيل نموذج بهذا الحجم بشكل موثوق على بنيتك التحتية الخاصة يتطلب عنقود GPU متعدد العقد، وخط أنابيب للتكميم، ومحرك استدلال موزّع، وطبقة جدولة ومراقبة تربط كل ذلك معاً. هنا بالضبط تظهر قيمة المنصة.

## دلالات على منتجات ThakiCloud

يوضح هذا الإطلاق في آن واحد سبب الحاجة إلى منتجين من منتجات ThakiCloud.

أولاً، من منظور البنية التحتية: ai-platform. منصة ai-platform لدى ThakiCloud هي بنية تحتية للذكاء الاصطناعي وتعلّم الآلة قائمة على Kubernetes، توفر جدولة GPU عبر Kueue، وعزلاً متعدد المستأجرين (multi-tenant)، وتشغيلاً موزّعاً، وقابلية مراقبة. بالنسبة لعميل يرغب في تشغيل نموذج ضخم مفتوح الأوزان مثل Kimi K3 على بنيته التحتية الخاصة، هذه الطبقة ليست خياراً بل شرطاً مسبقاً. إدارة موارد GPU عبر عقد متعددة وفق سياسات محددة، وتحويل التشغيل المكمَّم والموازي إلى شكل قابل للتشغيل الفعلي، هو ما يحدد إمكانية الاعتماد من الأساس. في بيئة ذات سيادة بيانات (sovereign) لا يمكن فيها إخراج البيانات إلى الخارج، تصبح القدرة على تشغيل نموذج مفتوح الأوزان بمستوى متقدم ذاتياً مبرراً قوياً بحد ذاته للاعتماد على المنصة.

ثانياً، من منظور الوكلاء (agents): Paxis. قوة Kimi K3 في برمجة الواجهات الأمامية والتوليد البصري ترتبط مباشرة بوكلاء البرمجة. Paxis هي السحابة الأصلية للوكلاء (Agent-Native Cloud) لدى ThakiCloud، وتتعامل مع المهارات (skills) والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. تُشغّل المهارات داخل صناديق رملية (sandbox) معزولة، وتنسّق وكلاء متعددين على شكل رسم بياني موجّه غير دوري (DAG)، وتُمرر كل إجراء عبر بوابات سياسات وسجلات تدقيق. بالنسبة لمنظمة ترغب في تشغيل وكيل برمجة يعتمد على الرؤية داخل الحلقة، أي يولّد كوداً ويتحقق من نتيجته ويصححه، ضمن حدود تنفيذ آمنة، تصبح طبقة التحكم هذه ضرورة. وعندما يلتقي نموذج برمجة قوي مفتوح الأوزان مع بيئة تنفيذ آمنة للوكلاء، تكتمل صورة وكيل برمجة عملي يعمل على البنية التحتية الخاصة بك.

المنظوران يكمّلان بعضهما البعض. التشغيل الذاتي منخفض التكلفة (ai-platform) هو ما يجعل تشغيل الوكلاء بشكل مستمر أمراً مجدياً اقتصادياً (Paxis)، وعبء عمل الوكلاء القوي (Paxis) هو ما يمنح بنية التشغيل هذه (ai-platform) سبب وجودها.

## حدود وحجج مضادة

بمعزل عن الحماس السائد، هناك نقاط تستحق نظرة باردة.

أولاً، حتى وقت كتابة هذا المقال، قد لا تكون كامل الأوزان قد نُشرت بشكل كامل بعد، ولم تُحسم شروط الترخيص النهائية. نتيجة اختبار الأداء وحصولك الفعلي على نموذج يمكن تشغيله تجارياً أمران مختلفان. من يفكر في الاعتماد على النموذج يجب أن يبني قراره على الأوزان المنشورة فعلياً ونص الترخيص، لا على مواد الإعلان.

ثانياً، احتلال المرتبة الأولى في اختبار أداء لا يعني تفوقاً في كل الحالات. اختبار تفضيل الواجهة الأمامية هو تقييم نسبي في مهمة محددة، ويجب التحقق مباشرة من كيفية أداء النموذج في عبء العمل الفعلي لديك. افتراض أن نتيجة أعلنها آخرون تنطبق على نتائجك الخاصة أمر محفوف بالمخاطر.

ثالثاً، التكلفة الإجمالية للتشغيل الذاتي ليست صغيرة على الإطلاق. عند احتساب وحدات GPU والطاقة والكوادر التشغيلية اللازمة لتشغيل نموذج بـ 2.8 تريليون معلمة عبر عقد متعددة، قد يكون استخدام واجهة برمجية مغلقة في الواقع أرخص للمنظمات ذات حركة المرور المنخفضة. الميزة الحقيقية للنماذج مفتوحة الأوزان ليست منخفضة التكلفة بشكل مطلق، بل تكمن في سيادة البيانات، وتجنب الارتباط بمزوّد واحد، وإمكانية التحكم في التكلفة عند الحجم الكافي. يجب حساب حجم حركة المرور ومتطلبات البيانات الخاصة بك أولاً، ثم اتخاذ القرار.

## المصادر

- [China's Moonshot AI releases Kimi K3, the largest open-source model ever (VentureBeat)](https://venturebeat.com/technology/chinas-moonshot-ai-releases-kimi-k3-the-largest-open-source-model-ever-rivaling-top-u-s-systems)
- [Moonshot AI Releases Kimi K3: A 2.8 Trillion Parameter Open MoE Model With Kimi Delta Attention (MarkTechPost)](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
- [China's open-weight Kimi model stuns AI world with frontier-level results (Axios)](https://www.axios.com/2026/07/16/moonshot-kimi-ai-china-model-openai-anthropic)
- [China's Moonshot throws down the gauntlet with Kimi K3 (SiliconANGLE)](https://siliconangle.com/2026/07/16/chinas-moonshot-throws-gauntlet-kimi-k3-worlds-largest-open-weights-model/)
