---
title: "الوكيل يقود تدريب GPU مباشرة: تشريح مهارات وكيل NVIDIA Cosmos 3"
seo_title: "تحليل التدريب اللاحق لمهارات وكيل NVIDIA Cosmos 3 - Thaki Cloud"
seo_description: "بمهارة وكيل TAO التي كشفت عنها NVIDIA، يقود وكيل برمجي تلقائياً الضبط الدقيق بأسلوب LoRA ومسح AutoML لنموذج الرؤية Cosmos 3. نشرّح سير العمل الذي رفع دقة التحقق من 54.41% إلى 93.35% بمطالبتين فقط، ونحدد ما يمكن نقله منه من زاويتَي Paxis التي تعامل المهارات كموارد من الدرجة الأولى، وai-platform الذي يجدول تدريب GPU."
excerpt: "بمطالبتين فقط بلغة طبيعية يُسلَّمان إلى وكيل برمجي، ينتهي التدريب اللاحق لنموذج رؤية أساسي في يوم واحد. نشرّح مهارة وكيل NVIDIA، وننظر إلى ما يمكن أن يُنقل منها إلى منصتنا التي تعامل المهارات كموارد من الدرجة الأولى."
date: 2026-07-16
tags:
  - agent-skills
  - post-training
  - lora
  - automl
  - cosmos-3
  - tao
  - nvidia
  - gpu
  - mlops
  - vision-language
categories:
  - agentops
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/cosmos3-agent-skills-posttraining/"
---

في الأسبوع الماضي توصلنا، في تجربة توليد واجهات نظام التصميم، إلى استنتاج مفاده أن "البوابة يجب
أن تُبنى قبل النموذج". حالة التدريب اللاحق لنموذج Cosmos 3 التي كشفت عنها NVIDIA هذه المرة هي
النصف الآخر من تلك القصة. هنا، بدلاً من أن يبني الإنسان البوابة بيده، تُسلَّم معرفة مغلفة تسمى
**مهارة الوكيل (Agent Skill)** إلى وكيل برمجي، فيتولى هذا الوكيل بنفسه قيادة الضبط الدقيق
والتقييم والبحث عن المعاملات الفائقة. الجمهور المقصود هنا هو مهندسو التعلم الآلي والمنصات الذين
يريدون إجراء تدريب لاحق لنموذج أساسي على بنيتهم التحتية الخاصة. وبإيجاز الخلاصة منذ البداية:
البطل الحقيقي في هذه الحالة ليس النموذج ولا وحدات GPU، بل **الحاضنة (harness) التي تُجمّد معرفة
سير العمل في شكل مهارة يكررها الوكيل تلقائياً**.

![رسم توضيحي مجرد لعقدة تنسيق مركزية تقود أسطولاً من خوادم GPU]({{ '/assets/images/cosmos3-agent-skills-posttraining-hero.webp' | relative_url }})
*تقود مهارات الوكيل العمل المتكرر في تدريب GPU وتقييمه وضبطه. أما الإنسان فيقدّم الهدف فقط عبر مطالبة.*

## ما هو Cosmos 3، وما هي مهارات الوكيل (TAO Agent Skills)؟

Cosmos 3 هو نموذج أساسي طورته NVIDIA للتعامل مع العالم الفيزيائي. يستخدم بنية
Mixture-of-Transformers التي تجمع النص والصورة والفيديو والصوت المحيط وتتبع الحركة في كيان
واحد، ويضم برجاً استدلالياً ذاتي الانحدار (autoregressive) مسؤولاً عن المنطق والتخطيط إلى جانب
محول انتشار (diffusion transformer) يتنبأ بالحالات المستقبلية. أعلنت NVIDIA أن هذا النموذج
يتصدر عدة معايير قياسية منها VANTAGE-Bench وPAI-Bench وPhysics-IQ وRoboLab وRoboArena. يأتي
النموذج بحجمين هما Cosmos 3 Super بسعة 64B وCosmos 3 Nano بسعة 16B، وتستخدم هذه الحالة نسخة
Nano.

لكن الجوهر ليس النموذج بل **مهارة وكيل TAO (TAO Agent Skill)** المرفقة به. مهارة وكيل TAO هي
حزمة معرفة تُؤتمت سير عمل التدريب اللاحق لنماذج الرؤية. فهي تغلف معرفة خاصة بالمهمة مثل تفاصيل
الإطار البرمجي، وسلوك المُشغِّل (launcher)، وبنية ملفات الإعداد (config)، وطريقة تحميل البيانات،
وسير عمل التقييم، بحيث يستطيع وكيل برمجي مثل Codex أو Claude أن ينسق خط أنابيب التدريب بنفسه
بأقل قدر ممكن من تدخل الإنسان. بعبارة أخرى، المهارة ليست سطر مطالبة واحداً، بل وحدة قابلة لإعادة
الاستخدام تغلف إجراءً قابلاً للتنفيذ إلى جانب آليات التعافي من الفشل.

## المطالبتان الاثنتان اللتان تنهيان التدريب اللاحق

سبب لفت هذه الحالة للانتباه هو أن كل ما أدخله الإنسان كان مطالبتين بلغة طبيعية لا أكثر.

المطالبة الأولى توجه بإجراء تدريب لاحق بأسلوب LoRA. وهي طلب لتدريب `nvidia/Cosmos3-Nano` بأسلوب
LoRA على مجموعة بيانات Woven Traffic Safety الخاصة بشركة Toyota، مع إجراء تقييم أساسي (baseline)
أولاً لأغراض المقارنة.

```
Perform LoRA post-training of the Cosmos 3 model on the Woven Traffic
Safety dataset. Training data: /home/.../WTS_dataset/wts_data_train
Validation data: /home/.../WTS_dataset/wts_data_val
Base model on Hugging Face: nvidia/Cosmos3-Nano
Also perform a baseline evaluation first, to compare with the post-trained model.
```

بمطالبة واحدة فقط، عالج الوكيل عدة مهام بالتتابع: اكتشف بنفسه معامل FPS المفقود في خط أنابيب
البيانات وأصلح الخطأ، ثم خزّن النموذج مؤقتاً باستخدام رمز Hugging Face، وقاس دقة الأساس بأسلوب
zero-shot قبل التدريب فسجّلت 54.41%، ثم شغّل تدريب LoRA. النقطة الجديرة بالملاحظة هنا هي التوجيه
القائل "أجرِ تقييم الأساس أولاً". فبدلاً من الثقة بنتيجة يبلغ عنها النموذج بنفسه بعد التدريب، جرى
تثبيت رقم ما قبل التدريب كخط أساس للقياس، وقيس التحسن فعلياً. هذا المبدأ مطابق تماماً للدرس الذي
استخلصناه من تجربتنا في الأسبوع الماضي.

المطالبة الثانية هي عملية مسح AutoML. وهي طلب لترك استراتيجية البحث وتحديد المعاملات الفائقة
الواجب ضبطها لـ TAO، مع تحسين دقة التحقق (validation accuracy) ثم تلخيص أفضل النماذج.

```
Run an AutoML sweep to improve the LoRA result. Let TAO choose suitable
search strategies and tune the important training hyperparameters. Optimize
validation accuracy and summarize the best models.
```

عند رسم سير العمل بأكمله كمخطط، يظهر الإنسان عند الطرفين فقط، بينما تملأ المهارة العمل المتكرر
في المنتصف.

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
<div class="d3-arch" data-arch-root id="3agentskillsposttraining-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 781, "height": 1070, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 305, "y": 24, "w": 163, "h": 78, "title": ["مطالبة بلغة طبيعية", "(تدريب LoRA + تقييم", "الأساس)"]}, {"id": "B", "x": 316, "y": 180, "w": 142, "h": 62, "title": ["وكيل برمجي", "(Codex / Claude)"]}, {"id": "C", "x": 288, "y": 320, "w": 198, "h": 94, "title": ["مهارة وكيل TAO", "تغليف معرفة الإطار", "والمُشغِّل وconfig", "وتحميل البيانات والتقييم"]}, {"id": "D", "x": 544, "y": 492, "w": 205, "h": 62, "title": ["إصلاح تلقائي للأخطاء", "(تصحيح معامل FPS المفقود)"]}, {"id": "E", "x": 284, "y": 492, "w": 205, "h": 62, "title": ["تخزين النموذج مؤقتاً", "(Cosmos3-Nano عبر رمز HF)"]}, {"id": "F", "x": 31, "y": 492, "w": 198, "h": 62, "title": ["تقييم الأساس", "(zero-shot بنسبة 54.41%)"]}, {"id": "G", "x": 24, "y": 632, "w": 212, "h": 78, "title": ["التدريب اللاحق بأسلوب LoRA", "(8×A100، نحو 30 دقيقة لكل", "حقبة)"]}, {"id": "H", "x": 31, "y": 788, "w": 198, "h": 78, "title": ["مسح AutoML", "(43 محاولة متوازية، 19.5", "ساعة)"]}, {"id": "I", "x": 28, "y": 944, "w": 205, "h": 94, "title": ["خدمة أفضل مهايئ (adapter)", "عبر Cosmos 3 Reasoner NIM", "(نقطة نهاية متوافقة مع", "OpenAI)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [387, 102, 387, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [387, 242, 387, 320]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[486, 400], [647, 453], [647, 453], [647, 492]]}, {"src": "C", "dst": "E", "kind": "data", "line": [387, 414, 387, 492]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[288, 400], [130, 453], [130, 453], [130, 492]]}, {"src": "F", "dst": "G", "kind": "data", "line": [130, 554, 130, 632]}, {"src": "G", "dst": "H", "kind": "data", "line": [130, 710, 130, 788]}, {"src": "H", "dst": "I", "kind": "data", "line": [130, 866, 130, 944]}]});
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
      const container = document.getElementById('3agentskillsposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '3agentskillsposttraining-1';
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

تحضير البيئة يتطلب ثلاثة رموز (tokens) وسطراً واحداً من نص التثبيت. تُدخل `HUGGINGFACE_TOKEN`
و`NGC_API_KEY` و`AUTOML_LLM_API_KEY` في الطرفية، ثم تُثبَّت مهارة الوكيل بالنص البرمجي أدناه.

```bash
export HUGGINGFACE_TOKEN="your_hf_token"
export NGC_API_KEY="your_ngc_key"
export AUTOML_LLM_API_KEY="your_llm_key"

curl -fsSL https://raw.githubusercontent.com/NVIDIA-TAO/tao-skills-bank/main/scripts/install-codex-agents.sh | bash
```

بيانات التدريب هي مجموعة بيانات Woven Traffic Safety الخاصة بشركة Toyota، وهي مهمة أسئلة وأجوبة
على مقاطع فيديو تضم أكثر من 8,000 عينة تدريب وتحقق. تتألف من أسئلة اختيار من متعدد (أربعة خيارات)
تتناول بنية الطرق وأنواعها وحالات السلامة المرورية.

## الأرقام التي أنتجتها المطالبتان

ارتفع الأداء بوضوح. جميع الأرقام أدناه هي قيم أعلنتها NVIDIA، وليست نتائج أعدنا إنتاجها بأنفسنا.

![رسم بياني شريطي لدقة التحقق في مهمة أسئلة وأجوبة فيديو WTS عبر ثلاث مراحل لنموذج Cosmos 3 Nano: الأساس وLoRA وAutoML]({{ '/assets/images/cosmos3-agent-skills-posttraining-results.webp' | relative_url }})
*ارتفعت دقة التحقق من 54.41% إلى 93.35% بمطالبتين فقط. أرقام معلنة من NVIDIA.*

بلغ الأساس بأسلوب zero-shot نسبة 54.41%، ورفعته مطالبة LoRA الواحدة إلى 87.14%، أي بزيادة قدرها
32.73 نقطة. وفوق ذلك، ضبط مسح AutoML المعاملات الفائقة عبر التحسين البايزي (Bayesian
optimization) ليصل إلى 93.35%، بزيادة قدرها 38.94 نقطة عن الأساس. والنقطة الجوهرية هنا أن هذه
الأرقام تحققت دون أن يلمس إنسان المعاملات الفائقة بيده، بل باختيار الوكيل لاستراتيجية البحث
وتشغيله التدريب بشكل متكرر.

من الأمانة النظر أيضاً إلى أرقام التكلفة. استغرق تدريب LoRA نحو 30 دقيقة لكل حقبة (epoch) على 8
وحدات A100 80GB، بينما استغرق مسح AutoML، الذي شغّل 43 محاولة متوازية عبر عدة عُقد A100، مدة 19.5
ساعة. أما التدريب الدقيق الكامل المعاملات (full-parameter SFT) الذي شُغِّل كمجموعة مقارنة فقد
استغرق 3 ساعات و34 دقيقة على H100، وأعلنت NVIDIA أن LoRA خفّض زمن استخدام GPU إلى نحو سُبع الزمن
مقارنة بهذا التدريب الكامل. وبعد انتهاء التدريب، تتولى Cosmos 3 Reasoner NIM خدمة مهايئ LoRA عبر
نقطة نهاية متوافقة مع OpenAI، ضمن بنية تُنشر مباشرة كخدمة مصغّرة (microservice) مبنية مسبقاً، دون
الحاجة إلى ضبط تبعيات vLLM أو إعدادات CUDA يدوياً.

## هل جربنا هذا بأنفسنا؟

بصراحة، لم نتمكن من إعادة إنتاج سير العمل هذا في بيئتنا. أوزان عائلة Cosmos 3 محفوظة في مستودع
Hugging Face مُقيَّد بالوصول (gated)، وتحتاج العملية إلى 8 وحدات A100 ومفاتيح NGC وAutoML LLM،
كما أن المسح المتوازي المستخدم في هذه الحالة يفترض وجود عدة عُقد GPU. لم نؤمّن مجموعة الموارد هذه
لأجل هذا المقال. لذلك فإن جميع الأرقام أعلاه مقتبسة من قيم أعلنتها NVIDIA، ولا نقدمها كما لو كانت
نتائج قسناها بأنفسنا. نلتزم بمبدأ عدم إنشاء معايير قياسية دون إعادة إنتاج فعلية. ما يمكننا فعله
بدلاً من ذلك هو تشريح بنية هذه الحالة، ومقارنتها بدقة بما يعمل بالفعل على منصتنا، لتحديد أوجه
التشابه والاختلاف.

## الدلالات على منتجات ThakiCloud

هذه الحالة موضوع نادر تتقاطع فيه وجهتا نظر منتجَينا معاً.

**من زاوية Paxis، هذه الحالة تحقق خارجي لأطروحتنا القائلة بأن المهارات يجب أن تُعامل كموارد من
الدرجة الأولى.** Paxis هو مستوى التحكم الخاص بـ ThakiCloud للسحابة الأصيلة الوكيلة (Agent-Native
Cloud)، ويعامل Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. يختار Skill Harness
من بين أكثر من 960 مهارة باستخدام BM25 وينفذها في صندوق رملي معزول، ويمرر كل سلوك عبر بوابات
السياسات (policy gates) وسجلات التدقيق. ما أثبتته مهارة وكيل TAO التابعة لـ NVIDIA هو أن وجود
مهارة تغلف تفاصيل الإطار البرمجي وحتى آليات التعافي من الفشل يجعل الوكيل البرمجي يكرر سير عمل
معقداً بثبات. وهذا يطابق تماماً التوجه الذي اعتمدناه في تعريف المهارة بوصفها وحدة تنفيذ لا مجرد
مطالبة. غير أن الفرق واضح أيضاً: مهارات TAO مرتبطة بشدة بمنظومة NVIDIA، بحيث يصعب استخدامها كما
هي خارج مُشغِّل TAO ونماذج Cosmos وNGC وNIM. أما حاضنة مهارات Paxis فتستهدف عدم الارتباط بمزود
أو نموذج بعينه، وهذه النقطة هي جوهر القيمة التي نريد تقديمها في البيئات المحلية (on-premises)
والبيئات السيادية.

**ومن زاوية ai-platform، هذه الحالة هي بعينها تدريب وخدمة GPU الذي نجدوله يومياً.** إرسال 43
محاولة AutoML متوازية عبر عدة عُقد يتطابق مباشرة مع طريقة إدارة Kueue لطوابير GPU في منصتنا.
وخدمة مهايئ LoRA عبر نقطة نهاية متوافقة مع OpenAI بواسطة NIM تحل المشكلة ذاتها التي نحلها عبر
مسار الخدمة القائم على vLLM. كما أن كون LoRA يقلل زمن استخدام GPU بشكل كبير مقارنة بالتدريب
الكامل SFT يدعم أطروحتنا القائلة بأن الخدمة منخفضة التكلفة والتدريب منخفض التكلفة يصنعان في
النهاية جدوى اقتصادية للوكيل. عندما يريد عميل إجراء تدريب لاحق لنموذج أساسي على بياناته الخاصة،
فإننا نوفر له مساراً يقسّم GPU عبر Kueue ويخدم المهايئ عبر vLLM فوق عنقوده (cluster) الخاص، بدلاً
من سحابة خارجية مقيدة الوصول.

بجمع الزاويتين معاً تكتمل الصورة. تسند ai-platform التدريب والخدمة منخفضي التكلفة، وفوقهما يقود
Paxis الوكيل بالمهارات والسياسات والتدقيق. وحالة NVIDIA أظهرت، عبر معيار قياس لجهة أخرى، أن هذا
التركيب يؤدي فعلاً إلى تحسن حقيقي في الأداء.

## الحدود والاعتراضات

لتجنب المبالغة في تقدير هذه الحالة، ينبغي النظر في أربع نقاط معاً. أولاً، عبارة "في يوم واحد"
مقياسها الزمن الفعلي (wall clock) لا زمن GPU. فمسح استغرق 19.5 ساعة عبر 8 وحدات A100 وعدة عُقد
ليس رخيصاً بأي حال، والنسبة "سُبع الزمن" قيمة نسبية مقارنة بالتدريب الكامل SFT، لا تعني رخصاً
مطلقاً. ثانياً، نسبة 93.35% رقم يخص مهمة ضيقة هي أسئلة وأجوبة فيديو للسلامة المرورية من نوع
الاختيار من أربعة بدائل، ولا ينبغي تعميمها على أنها ارتفاع مماثل في القدرة العامة على الاستدلال
الفيزيائي. ثالثاً، الأتمتة تُخفي التبعية للمزود. السبب في قدرة الوكيل على إصلاح الخطأ "بنفسه" هو
أن بنك المهارات كان يعرف مسبقاً نمط الخطأ الخاص بذلك الإطار البرمجي بالضبط، وهذه السلاسة تختفي
بمجرد الخروج من تلك المنظومة. رابعاً، "الحد الأدنى من التدخل" لا يعني تدخلاً معدوماً. فلا تبدأ
العملية إلا بعد أن يُدخل الإنسان مفاتيح API، ويحدد مسارات مجموعة البيانات، ويثبت أصلاً بنك
المهارات المناسب لتلك المهمة. ما ألغاه الوكيل هو العمل المتكرر، لا الحكم البشري نفسه.

ومع ذلك فإن الاتجاه واضح. إن تجميد معرفة سير العمل في هيئة مهارة، وتكرار الوكيل تنفيذها، والتحقق
من التحسن عبر بوابة قياس فعلية لا عبر تقرير ذاتي من النموذج، ليست استراتيجية خاصة بمزود واحد، بل
تصميم مشترك لعصر الوكلاء. وهذا بالضبط ما نسعى إلى بنائه عبر Paxis وai-platform.

## المصادر

- NVIDIA Developer Blog, "Post-Train NVIDIA Cosmos 3 in One Day Using Agent Skills" (<https://developer.nvidia.com/blog/post-train-nvidia-cosmos-3-in-one-day-using-agent-skills/>)
- GitHub: NVIDIA/cosmos, NVIDIA-TAO/tao-skill-bank
- Hugging Face: nvidia/Cosmos3-Nano, nvidia/Cosmos3-Super
- مجموعة البيانات: Woven Traffic Safety (WTS)، Toyota
