---
title: "Ornith-1.0: نموذج برمجة مفتوح المصدر يبني سقالات التعلم المعزز بنفسه"
excerpt: "Ornith-1.0 الصادر عن DeepReinforce في 25 يونيو 2026 هو عائلة نماذج برمجة مفتوحة المصدر تعتمد آلية التسقيل الذاتي (self-scaffolding)، حيث يكتب النموذج بنفسه سقالات التدريب بالتعلم المعزز. أربعة أحجام: 9B و31B كثيفان و35B و397B MoE، رخصة MIT، سياق 262K، وSWE-Bench Verified 82.4، مع تحليل من منظور خدمة الاستدلال متعدد المستأجرين وعوامل البرمجة الذاتية على K8s في ThakiCloud."
seo_title: "Ornith-1.0 نموذج برمجة مفتوح المصدر بالتعلم المعزز التسقيلي الذاتي vLLM - Thaki Cloud"
seo_description: "تحليل آلية التعلم المعزز التسقيلي الذاتي في DeepReinforce Ornith-1.0 (MIT، 9B/31B/35B/397B) والمعايير المعلنة (SWE-Bench Verified 82.4، Terminal-Bench 2.1 77.5) ووصفات vLLM، من منظور تشغيل عوامل البرمجة متعددة المستأجرين على K8s في ThakiCloud."
date: 2026-06-26
last_modified_at: 2026-06-26
lang: ar
tags:
  - ornith
  - deepreinforce
  - reinforcement-learning
  - coding-agent
  - self-scaffolding
  - open-weights
  - vllm
  - moe
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/ornith-1-self-scaffolding-coding-model/"
reading_time: true
categories:
  - llmops
---

![صورة تجريدية تجسّد بنية التسقيل الذاتي التي تبني سقالاتها بنفسها]({{ '/assets/images/ornith-1-self-scaffolding-coding-model-hero.webp' | relative_url }})
*صورة تجسّد التعلم المعزز بالتسقيل الذاتي حين يبني النموذج سقالات تدريبه بنفسه.*

بات التنافس بين نماذج البرمجة مفتوحة الأوزان يتجاوز سؤال "كم تبلغ درجة المعيار؟" إلى سؤال أعمق: "بأي منهجية تدريب تحققت تلك الدرجة؟" `Ornith-1.0` الذي أصدرته DeepReinforce في 25 يونيو 2026 هو نموذج تصدّر فيه المنهجية ذاتها العناوين. صُمّم التعلم المعزز فيه ليجعل النموذج يولّد الحلول ويكتب في الوقت ذاته **سقالات التدريب (scaffold)** التي تقود تلك الحلول.

هذا المقال لا يعرض نتائج إعادة تشغيل المعايير بشكل مستقل. تشغيل نموذج بحجم 397B على معايير البرمجة يستلزم عقد GPU متعددة وساعات استدلال، لذا لم يُجرَ ذلك في هذا التحليل الآني. وعليه، فجميع الأرقام الواردة هنا **أرقام أعلنتها DeepReinforce في مواد مفتوحة**، وما يتضارب بين المصادر مُشار إليه بـ`[تقديري]`. لم تُخترع أي أرقام.

## نظرة عامة

`Ornith-1.0` ليس نموذجاً واحداً، بل عائلة نماذج مفتوحة المصدر متخصصة في البرمجة. تنقسم إلى أربعة أحجام: 9B كثيف، و31B كثيف، و35B Mixture-of-Experts (MoE)، و397B MoE الرائد، وجميعها بترخيص MIT منشور على نطاق `deepreinforce-ai` في Hugging Face وجاهز للتنزيل الفوري. إلى جانبها نسخ مكمّمة: 9B و35B بصيغة GGUF، و35B و397B بصيغة FP8، مما يدل على أن طيف النشر (من GPU فردي على الحافة إلى عقد متعددة في مراكز البيانات) كان مقصوداً منذ البداية.

من منظور ThakiCloud، يبرز أمران فوراً: الترخيص وإمكانية الاستضافة الذاتية. MIT لا يفرق بين التجاري وغير التجاري، ولا يحمل أي عبء قانوني من الشروط الفيروسية أو البنود غير التجارية. للمؤسسات الراغبة في تشغيل عوامل برمجة على بنيتها التحتية الخاصة دون إرسال الكود إلى واجهات برمجة خارجية، هذا الترخيص هو الجواب الأكثر وضوحاً بـ"نعم".

يمكن تلخيص جوهر النموذج في جملة واحدة: **لا تتعلم Ornith-1.0 في مرحلة التعلم المعزز الحلولَ وحسب، بل تتعلم أيضاً السقالات المهمية التي تقود تلك الحلول.** ومعالجة السقالة بوصفها هدفاً يتطور عوضاً عن كونها أداة ثابتة هي الفارق عن نماذج RL البرمجية الأخرى.

وصف التغريدة الأصلية للنموذج بأنه "أول نموذج مفتوح المصدر من مختبر أمريكي يبرمج على مستوى الحدود." غير أن مقر DeepReinforce لم يتحقق بشكل مستقل من المصادر المفتوحة، لذا يُركز هذا المقال على الآليات القابلة للتحقق والأرقام المعلنة، لا على أُطر الجنسية.

## ما هذا النموذج؟

`Ornith-1.0` مبني على تدريب ما بعد التدريب المسبق (post-training) فوق نماذج أساس مدرّبة مسبقاً. أعلنت DeepReinforce أنها استخدمت Gemma 4 وعائلة Qwen 3.5 كأساس، أي أن الأمر لا يتعلق بتدريب مسبق من الصفر، بل بتطبيق **تعلم معزز مخصص** على قواعد مفتوحة قوية لرفع قدرات البرمجة. يتشابه هذا مع ما تفعله NVIDIA حين تعيد توزيع نماذج جهات خارجية مكمّمة، أي مبدأ "القاعدة أصل مشترك، والتمييز في ما بعد التدريب"، وهو نمط تقسيم عمل بارز في المنظومة المفتوحة الراهنة.

النموذج في جوهره نموذج استدلال (reasoning). يفتح استجاباته بكتلة `<think> … </think>` ليطوّر عملية التفكير أولاً قبل إعطاء الإجابة النهائية. وصفة الخدمة المعلنة توجّه إلى تفعيل محلل reasoning يفصل عملية التفكير في حقل `reasoning_content` مستقل، ومحلل tool-call يعرض كتل استدعاء الأدوات بصيغة `tool_calls` متوافقة مع OpenAI. القصد التصميمي واضح: يُوصل مباشرة في حلقات العوامل. أقصى طول للسياق هو 262,144 رمز، وهو طول يستهدف مهام البرمجة ذات الأفق الطويل التي تدفع فيها مستودعات كاملة دفعة واحدة.

DeepReinforce ليست وافداً جديداً على التعلم المعزز. `CUDA-L1` الصادر عام 2025 استخدم التعلم المعزز لتحسين نواة CUDA تلقائياً، وأفاد بتسارع متوسط 3.12× وتسارع ذروة يبلغ عشرات الأضعاف على مهام GPU متعددة. الخط البحثي المتواصل القائل "اجعل الكود/النواة تحسّن نفسها بالتعلم المعزز" يمتد الآن إلى هذا النموذج البرمجي.

## الجوهر: تعلم معزز بتسقيل ذاتي

في معظم تدريب RL العاملاتي، يُثبّت البشر السقالة (بنية التوجيه، واتفاقيات استخدام الأدوات، وإطار تحليل المهمة) ثم تتعلم السياسة ضمنها فحسب. إن كانت السقالة جيدة ارتفعت الدرجات، وإن كانت رديئة صطدمت السياسة بسقف بمعزل عن جودتها. والمشكلة أن السقالة المثالية تختلف من مهمة إلى أخرى. تتجاوز Ornith-1.0 ذلك بأن ترفع السقالة من **ثابت** إلى **متغيّر قابل للتعلم**.

وفق وصف DeepReinforce، تسير كل خطوة RL في مرحلتين: أولاً يقترح النموذج **سقالة مكيّفة** شرطياً بالمهمة المعطاة، ثم يولّد **طرح حل (rollout)** شرطياً بتلك السقالة. يُنشر مكسب المكافأة على كلتا المرحلتين، أي أن "أي سقالة بُنيت؟" و"ماذا حُلّ فوقها؟" كلاهما يُقيَّم ويُحسَّن معاً. السقالة تصبح هدفاً يتطور بالتزامن مع السياسة.

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
<div class="d3-arch" data-arch-root id="lfscaffoldingcodingmodel-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 433, "height": 612, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 148, "w": 377, "h": 294, "label": "خطوة RL (مرحلتان)", "lx": 36, "ly": 166}], "nodes": [{"id": "T", "x": 147, "y": 24, "w": 121, "h": 46, "title": "المهمة (Task)"}, {"id": "S1", "x": 105, "y": 187, "w": 205, "h": 62, "title": ["المرحلة 1: اقتراح السقالة", "(شرطي بالمهمة)"]}, {"id": "S2", "x": 190, "y": 341, "w": 163, "h": 62, "title": ["المرحلة 2: طرح الحل", "(شرطي بالسقالة)"]}, {"id": "R", "x": 137, "y": 534, "w": 149, "h": 46, "title": "المكافأة (reward)"}], "edges": [{"src": "T", "dst": "S1", "kind": "data", "line": [207, 70, 207, 187]}, {"src": "S1", "dst": "S2", "kind": "data", "curve": [[257, 249], [332, 295], [332, 295], [296, 341]]}, {"src": "S2", "dst": "R", "kind": "data", "curve": [[298, 403], [332, 442], [332, 488], [252, 534]]}, {"src": "R", "dst": "S1", "kind": "event", "label": "ينتشر إلى السقالة", "curve": [[174, 534], [98, 442], [98, 295], [164, 249]], "off": "50%"}, {"src": "R", "dst": "S2", "kind": "event", "label": "ينتشر إلى السياسة", "curve": [[215, 534], [222, 488], [222, 442], [250, 403]], "off": "50%"}, {"src": "S1", "dst": "S2", "kind": "event", "label": "تطور مشترك", "curve": [[212, 249], [218, 295], [218, 295], [250, 341]], "off": "50%"}]});
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
      const container = document.getElementById('lfscaffoldingcodingmodel-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lfscaffoldingcodingmodel-1';
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

أهمية هذا التصميم تتجلى في وجهين: أولاً يزول عنق الزجاجة المتمثل في ضبط السقالات يدوياً من قِبل البشر، فحتى لو تغيّر توزيع المهام يعيد النموذج بناء سقالاته. ثانياً لأن السقالة معرّضة مباشرة لإشارة المكافأة، يمكن تصحيح نمط الفشل الشائع "السياسة سليمة لكن السقالة رديئة فتضيع الدرجات" داخل حلقة التعلم ذاتها. يتشابه هذا مع فكرة [نمط Loop Engineering](https://thakicloud.com/tech-blog/ar/llmops/) حين تُستخدم أدوات خارجية (مترجمات، اختبارات) إشارةً للمكافأة، مع خطوة إضافية: **السقالة ذاتها** أصبحت هدفاً تلقى المكافأة.

## المعايير المعلنة

الأرقام الرائدة التي أعلنتها DeepReinforce لنموذجها الأكبر هي كالتالي. جميعها بحسب إعلان الشركة ولم تُعاد نسخها في بيئتنا.

| المعيار | Ornith-1.0-397B | للمقارنة |
|---|---|---|
| SWE-Bench Verified | 82.4 | Claude Opus 4.8: 87.6 (الوحيد الذي يتفوق في القائمة) |
| Terminal-Bench 2.1 | 77.5 | الأعلى بين نماذج مفتوحة المصدر من حجم مماثل وفق الإعلان |
| SWE-Bench Pro | 62.2 `[تقديري]` | تباين بين المصادر |

تدّعي DeepReinforce تحقيق أعلى أداء بين النماذج مفتوحة المصدر من الحجم ذاته على Terminal-Bench 2.1 وSWE-Bench وNL2Repo وOpenClaw. ويبرز تحديداً أن 35B MoE يتفوق على بعض النماذج الأكبر حجماً، ما يُفسَّر بأن ندرة MoE مقترنة بما بعد التدريب التسقيلي الذاتي ترفع الكفاءة نسبةً إلى عدد المعاملات النشطة. بيد أن معايير SWE-Bench تتفاوت تفاوتاً كبيراً بين نسخها (Verified/Pro/الأصلية)، والمقارنة المباشرة دون التحقق من النسخة المستخدمة ضربٌ من المجازفة، ولهذا وُضعت قيمة SWE-Bench Pro بعلامة `[تقديري]`.

أهم ما يلفت انتباه المشغّل ليس الأرقام ذاتها، بل أن **مصدرها آلية مُعلنة**. أرقام النماذج المغلقة لا يمكن إعادة إنتاجها، أما الأوزان المُرخّصة بـMIT والوصف التدريبي المنشور فإنهما يفتحان باب التحقق المستقل.

## التثبيت والخدمة

صُمّمت Ornith-1.0 لتعمل مباشرة على مكدسات الاستدلال القياسية. منطق تدرّج التحقق ينطبق هنا: ابدأ بالأصغر. صُمّم 9B للعمل على GPU فردي، وهو نقطة انطلاق مناسبة لاختبار تكامل أنابيب العمل.

```bash
# تنزيل الأوزان من Hugging Face (مثال: 9B)
huggingface-cli download deepreinforce-ai/Ornith-1.0-9B \
  --local-dir ./ornith-1.0-9b
```

بما أنه نموذج استدلال واستدعاء أدوات في آن، يلزم عند الخدمة تفعيل محلل reasoning ومحلل tool-call معاً ليُفصلا عملية التفكير واستدعاءات الأدوات في حقول منظّمة. الشكل النموذجي لتشغيل vLLM هو الآتي، وأسماء المحللات الدقيقة تُرجع إلى بطاقة النموذج.

```bash
# خدمة vLLM (شكل نموذجي، أسماء المحللات تتبع بطاقة النموذج)
vllm serve deepreinforce-ai/Ornith-1.0-9B \
  --max-model-len 262144 \
  --enable-auto-tool-choice \
  --tool-call-parser <محدد في بطاقة النموذج> \
  --reasoning-parser <محدد في بطاقة النموذج>
```

عند تشغيل 397B MoE الرائد، الذاكرة هي العائق الأول. لذا نُشرت نسخة FP8 (`Ornith-1.0-397B-FP8`) منذ البداية: تخفّض ذاكرة الأوزان بنسبة النصف مقارنة بـBF16، مما يقلص عدد العقد ودرجة التوازي الموتّري. أما 35B MoE فهو نقطة التوازن المثلى التي يمثّل فيها MoE ميزته الجوهرية "معاملات نشطة أقل، طاقة معرفية أكبر"، وهو مرشح واقعي للخدمة على عقدة واحدة بـGPU متعدد.

```bash
# 397B: نسخة FP8 مع توازي موتّري للتعامل مع جدار الذاكرة (هيكل إرشادي)
vllm serve deepreinforce-ai/Ornith-1.0-397B-FP8 \
  --tensor-parallel-size 8 \
  --max-model-len 262144 \
  --enable-auto-tool-choice
```

## ما يعنيه هذا لمنتجات ThakiCloud

يتماثل التسقيل الذاتي في Ornith-1.0 تماثلاً بنيوياً مع مفهوم المهارات المتطورة ذاتياً في Paxis. Paxis هو السحابة الأصيلة للعوامل (Agent-Native Cloud) من ThakiCloud بوصفه نموذجاً أولياً (PoC)، يعمل مستوى تحكم عاملاتي مبنياً فوق بنية ai-platform على Kubernetes، ويُعامل المهارات والأدوات والسياسات وسجلات التدقيق موارد من الدرجة الأولى. تشمل مكوناته الجوهرية منظومة المهارات (Skill Harness) التي تختار من بين 960 مهارة وأكثر عبر BM25، والتنفيذ المعزول في بيئة حماية (Sandbox)، ومحرك عوامل متعددة بـDAG، والجدولة بلغة طبيعية (NL Cron)، وموصلات MCP، والمهارات المتطورة ذاتياً. تماماً كما يقترح Ornith-1.0 سقالته التدريبية في كل خطوة RL ثم يعرّضها لإشارة المكافأة جنباً إلى جنب مع الحل، تتيح حلقة المهارات المتطورة في Paxis للعوامل أن تولّد بنية عملها وتحسّنها، شاملةً تكوين المهارات وتدفق التنفيذ واتفاقيات استخدام الأدوات. "رفع السقالة إلى متغير مكتسب" و"رفع المهارة إلى كيان متطور" تعبيران عن فلسفة تصميم واحدة.

تتجلى قدرة Paxis على الإدارة الذاتية، حيث تجدول العوامل أعمالها وتتتبع مهامها وتدير جلساتها باستقلالية عبر تنسيق متعدد العوامل بالـDAG وNL Cron، في تماثلها المباشر مع التسقيل الذاتي: في كلتيهما يبني العامل المستقل بنية عمله ويصونها بدلاً من الاشتغال داخل إطار ثابت يضعه الإنسان. Paxis مبني بـGo 1.26 وReact 19 وغير مرتبط بنموذج لغوي بعينه (LLM-agnostic)، مما يعمّم هذا النمط قدرةً على مستوى المنصة بدلاً من ربطه بنموذج محدد. يُقدّم Ornith-1.0 سابقة ملموسة يمكن الاستناد إليها مباشرة عند تصميم حلقة المهارات المتطورة في منظومة مهارات Paxis أو تحسينها.

تستند البنية التحتية لتدريب نماذج التسقيل الذاتي وخدمتها إلى ai-platform. تُجدول منصة ThakiCloud للذكاء الاصطناعي أحمال GPU عبر Kueue فوق K8s وتقدم الاستدلال متعدد المستأجرين عبر vLLM. يتماشى طيف أحجام عائلة Ornith-1.0 من 9B إلى 397B MoE بسلاسة مع التخصيص الطبقي لـGPU في Kueue: 9B للمهام المساعدة الخفيفة، و35B MoE لخدمة الاستدلال الرئيسية، و397B لأحواض المهام شديدة الصعوبة، بينما ينسّق Kueue التوزيع بحسب أولوية كل مستأجر. يكفل ترخيص MIT والإخراج بصيغة `tool_calls` المتوافقة مع OpenAI إمكانية تكامل أي حجم من العائلة في أنابيب خدمة vLLM القائمة باستبدال النموذج الأساسي، وهو أمر ذو قيمة بالغة في البيئات المقيّدة التي تُعدّ فيها السيادة على الكود الداخلي متطلباً صارماً.

## القيود والاعتراضات

أبرز القيود هو **التناظر اللامتكافئ في التحقق**. الأوزان والوصف التدريبي منشوران، لكن أرقام المعايير المعلنة قياسات داخلية لم تُعاد نسخها هنا. معايير SWE-Bench تتفاوت تفاوتاً كبيراً بحسب النسخة والتهيئة، والنموذج ذاته يُعطي نتائج مختلفة بحسب درجة الحرارة وإعدادات إعادة المحاولة والبيئة. الانتقال المباشر من هذه الأرقام إلى استنتاج "تجاوز النماذج الحدودية" استنتاجٌ متسرع. قرار التبنّي الفعلي يحتاج تقييماً مستقلاً على عيّنة من قواعد الكود الداخلية.

ثانياً **التكلفة التشغيلية**. 397B MoE جذاب بأرقامه، لكن ذاكرة GPU وعدد العقد المطلوبان حاجزان واقعيان عند الاستضافة الذاتية. نسخة FP8 تخفّف ذلك، لكن المقايضة "مفتوح المصدر إذاً مجاني" لا تصح، والأدق هو "مفتوح المصدر إذاً تكلفة البنية التحتية علينا". مقارنة تكلفة رمز واجهة البرمجة المغلقة بتكلفة عقدة الاستضافة الذاتية يستلزم تحليلاً بنمط الحمل الفعلي.

ثالثاً **تساؤل التعميم في التسقيل الذاتي**. التصميم القائل بأن النموذج يبني سقالته بنفسه أنيقٌ من حيث المفهوم، لكن ليس هناك تحقق خارجي حتى الآن من أن جودة السقالة لا تتدهور على مهام بعيدة عن توزيع التدريب. لا يمكن استبعاد احتمال أن تكون السقالة قد انحدرت نحو التخصص المفرط في أشكال معايير محددة. هذا مما سيتضح حين تُنشر إعادة إنتاج مستقلة بالأوزان المفتوحة.

خلاصة القول: Ornith-1.0 نموذج يستحق الاهتمام لمنهجيته قبل درجاته. كونه مرخّصاً بـMIT يجعله مرشحاً واقعياً لعوامل البرمجة ذاتية الاستضافة، وآلية التسقيل الذاتي فكرة يستحق اقتباسها في تصميم أنابيب تدريب العوامل سواء اعتُمدت الأوزان أم لا. لكن جميع أرقام المعايير تبقى "أرقاماً مُعلنة" ريثما تخضع للتقييم الذاتي.

## المصادر

- DeepReinforce، "Ornith-1.0: Self-Scaffolding LLMs for Agentic Coding" (يونيو 2026): <https://deep-reinforce.com/ornith_1_0.html>
- بطاقات النموذج على Hugging Face: <https://huggingface.co/deepreinforce-ai/Ornith-1.0-397B>، <https://huggingface.co/deepreinforce-ai/Ornith-1.0-9B>
- GitHub: <https://github.com/deepreinforce-ai/Ornith-1>
- MarkTechPost، "DeepReinforce Releases Ornith-1.0" (2026-06-25): <https://www.marktechpost.com/2026/06/25/deepreinforce-releases-ornith-1-0-an-open-source-coding-model-family-that-learns-its-own-rl-scaffolds/>
- Tech Times (2026-06-26): <https://www.techtimes.com/articles/319122/20260626/open-source-coding-model-ornith-10-writes-its-own-training-scaffold-reinforcement-learning.htm>
- DeepReinforce، CUDA-L1 (بحث سابق): <https://deepreinforce-ai.github.io/cudal1_blog/>
