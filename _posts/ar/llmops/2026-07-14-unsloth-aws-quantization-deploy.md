---
title: "أين تضع نموذجا مكمَّما؟ أربعة أنماط للنشر مع AWS و Unsloth"
excerpt: "كثير من الفرق تعرف كيف تقلّص نموذجا إلى 4 بت باستخدام Unsloth. لكن لحظة اتخاذ القرار بوضع ذلك الملف على EC2، أو تغليفه في نقطة نهاية SageMaker، أو تشغيله كحجيرة (pod) في EKS، يتعثر معظمها. يقدم دليل AWS المشترك مع Unsloth خريطة واضحة لذلك. الفكرة الأساسية: صيغة ملف النموذج تحدد بيئة التشغيل، وبيئة التشغيل تحدد خدمة AWS. يغطي هذا المقال أين يذهب GGUF، وأين تذهب safetensors المدمجة، وكيف ينسجم هذا التفكير مع بنية الخدمة لدى ThakiCloud."
tags:
  - unsloth
  - quantization
  - aws
  - sagemaker
  - vllm
  - llmops
  - self-hosting
  - paxis
date: 2026-07-14
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/unsloth-aws-quantization-deploy/"
categories:
  - llmops
---

![رسم توضيحي تجريدي لنموذج كبير يُقطَّر إلى طبقات مضغوطة تتدفق نحو بنية خدمة سحابية]({{ '/assets/images/unsloth-aws-quantization-deploy-hero.png' | relative_url }})

## نظرة عامة

هناك بالفعل مقالات كثيرة عن كيفية تكميم نموذج. GPTQ و AWQ و GGUF و Unsloth Dynamic؛ وصفة لتقليص نموذج 16 بت إلى 4 بت تبعد بضع عمليات بحث. لكن النقطة التي تتعثر عندها الفرق فعلا هي ما يأتي بعد ذلك. أين بالضبط تضع ذلك الملف ذا الـ 4 بت، وكيف؟ هل تشغّله مباشرة على مثيل EC2، أم تغلّفه في نقطة نهاية SageMaker، أم تدرجه في حجيرة على عنقود EKS الذي تديره أصلا؟ لا يوجد جواب واحد، لكن توجد خريطة تتفرع بحسب صيغة ملف النموذج.

هذا المقال موجه لمهندسي المنصات الذين ينشرون نماذج مفتوحة الأوزان على بنيتهم التحتية، وللممارسين الذين يصممون تكلفة الاستدلال. نشرت AWS مؤخرا دليلا مع Unsloth بعنوان "Deploying quantized models on Amazon SageMaker AI with Unsloth" ينظّم قرار النشر هذا في أربعة أنماط. نحلل المنطق الأساسي لهذا الدليل، ونشرح لماذا تحدد صيغة ملف النموذج بيئة التشغيل، وبيئة التشغيل بدورها تحدد خدمة AWS، ونربط هذا التفكير بكيفية تصميم بنية مثل ThakiCloud التي تقوم بالخدمة متعددة المستأجرين على Kubernetes.

نوضّح أمرا مسبقا: أمثلة الأوامر هنا مسارات تم التحقق منها في دليل AWS الرسمي ووثائق Unsloth، ولم نختلق أي أرقام قياس أداء. بيئة تحققنا هي Apple Silicon، لذا لم نتمكن فعليا من تشغيل وإعادة إنتاج تكميم Unsloth وخدمة vLLM المعتمدين على CUDA محليا. لذلك فهذا المقال ليس تقرير تجربة بل تحليل بنيوي لدليل موثوق.

## لماذا يعود التكميم مهما عند النشر

يُناقَش التكميم عادة بوصفه مسألة سرعة تدريب أو استدلال فقط. لكن دليل AWS يشير إلى أن التكميم عند مرحلة النشر يغيّر ثلاثة أمور دفعة واحدة. الأول قرار المثيل. فمع صيرورة نموذج كبير قابلا للتشغيل عمليا على GPU أصغر بل على CPU، تنخفض فئة المثيل المطلوبة نفسها. الثاني ملف تعريف الإقلاع والتخزين. فملفات النموذج الأصغر تُنقل وتُخزَّن أسرع، ما يساعد على الإقلاع البارد والتوسع الأفقي. الثالث مرونة النشر. إذ يمكنك اختيار نموذج أصغر للاستدلال الحساس للتكلفة وتصدير أعلى دقة للاستدلال الحساس للجودة.

قوة Unsloth أنه يربط الضبط الدقيق والتشغيل والتصدير والنشر في سير عمل واحد. وبخاصة، يتيح تكميم Unsloth Dynamic v2.0 تشغيل وضبط نماذج LLM المكمَّمة مع الحفاظ على الدقة قدر الإمكان، ويُفاد أن التدريب المدرك للتكميم (QAT)، المبني بالتعاون مع PyTorch، يستعيد جزءا كبيرا من الدقة المفقودة في التكميم الساذج إلى 4 بت. بعبارة أخرى، يمكنك اختيار موضعك بدقة على مقايضة الجودة مقابل الحجم قبل النشر.

## الصيغة تحدد بيئة التشغيل، وبيئة التشغيل تحدد AWS

الفكرة الجوهرية للدليل: لا تبدأ قرار النشر من "أي خدمة أستخدم". بل ابدأ من "إلى أي صيغة أصدّر"، وسيتبع الباقي طبيعيا. هناك فرعان.

الأول GGUF. وهو صيغة ملف واحد تجمع الأوزان والمُرمِّز (tokenizer) والبيانات الوصفية معا، وتستخدمه بيئات تشغيل خفيفة مثل llama.cpp و Ollama و Unsloth. على AWS يُربَط هذا الفرع بـ Amazon EC2 أو حاوية SageMaker AI مخصصة. إنه المسار حين تريد التحقق بخفة والاحتفاظ بتحكم مباشر.

الثاني safetensors المدمجة. فدمج وتصدير أوزان 16 بت أو 8 بت أو FP8 أو 4 بت بواسطة Unsloth يتيح التشغيل على محركات عالية الإنتاجية مثل vLLM و SGLang، ويُربَط ذلك بحاويات الاستدلال للنماذج الكبيرة (LMI) في SageMaker AI، أو EKS، أو ECS. إنه مسار الخدمة الإنتاجية حيث تهمّ الإنتاجية والتوسع. تلخّص الصورة التالية هذا الفرع.

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
<div class="d3-arch" data-arch-root id="othawsquantizationdeploy-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 500, "height": 994, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 149, "y": 24, "w": 191, "h": 62, "title": ["الضبط الدقيق أو التنزيل", "بواسطة Unsloth"]}, {"id": "B", "x": 136, "y": 164, "w": 216, "h": 52, "title": "اختيار بيئة تشغيل الخدمة"}, {"id": "C", "x": 270, "y": 308, "w": 198, "h": 78, "title": ["تصدير GGUF", "أوزان + مُرمِّز + بيانات", "وصفية"]}, {"id": "D", "x": 24, "y": 316, "w": 191, "h": 62, "title": ["تصدير safetensors مدمجة", "16 / 8 / FP8 / 4 بت"]}, {"id": "E", "x": 284, "y": 464, "w": 170, "h": 62, "title": ["llama.cpp · Ollama ·", "Unsloth"]}, {"id": "F", "x": 59, "y": 472, "w": 121, "h": 46, "title": "vLLM · SGLang"}, {"id": "G", "x": 270, "y": 604, "w": 198, "h": 62, "title": ["Amazon EC2", "أو حاوية SageMaker مخصصة"]}, {"id": "H", "x": 38, "y": 604, "w": 163, "h": 62, "title": ["حاوية SageMaker LMI", "أو EKS · ECS"]}, {"id": "I", "x": 138, "y": 744, "w": 212, "h": 62, "title": ["التحقق من بيئة التشغيل على", "EC2"]}, {"id": "J", "x": 166, "y": 884, "w": 156, "h": 78, "title": ["ترقية نفس تركيبة", "الملف+بيئة التشغيل", "إلى نشر مُدار"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [244, 86, 244, 164]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"ملف واحد خفيف\"", "curve": [[289, 216], [369, 262], [369, 262], [369, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "\"محرك عالي الإنتاجية\"", "curve": [[199, 216], [120, 262], [120, 262], [120, 316]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [369, 386, 369, 464]}, {"src": "D", "dst": "F", "kind": "data", "line": [120, 378, 120, 472]}, {"src": "E", "dst": "G", "kind": "data", "line": [369, 526, 369, 604]}, {"src": "F", "dst": "H", "kind": "data", "line": [120, 518, 120, 604]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[369, 666], [369, 705], [369, 705], [299, 744]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[120, 666], [120, 705], [120, 705], [189, 744]]}, {"src": "I", "dst": "J", "kind": "data", "line": [244, 806, 244, 884]}]});
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
      const container = document.getElementById('othawsquantizationdeploy-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'othawsquantizationdeploy-1';
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

## الإعداد والدمج

سير العمل الذي يعرضه الدليل من أربع خطوات. اضبط أو نزّل نموذجا في Unsloth، صدّره بالصيغة المطابقة لبيئة التشغيل المستهدفة، تحقق من بيئة التشغيل على EC2 أو محليا، ثم رقِّ نفس تركيبة الملف وبيئة التشغيل مباشرة إلى نشر مُدار. عبارة "نفس تركيبة الملف وبيئة التشغيل" مهمة هنا، لأنه إذا اختلفت الصيغة أو المحرك بين التحقق والإنتاج، يتسلل سلوك غير متوقع.

يتفرع التصدير من Unsloth بحسب بيئة التشغيل المستهدفة. مسار GGUF يبدو هكذا.

```python
# تصدير GGUF (مسار llama.cpp / Ollama / EC2)
model.save_pretrained_gguf(
    "qwen-merged-gguf",
    tokenizer,
    quantization_method="q4_k_m",
)
```

مسار safetensors المدمجة يستهدف vLLM أو SGLang.

```python
# تصدير safetensors مدمجة (مسار vLLM / SGLang / SageMaker LMI)
model.save_pretrained_merged(
    "qwen-merged-16bit",
    tokenizer,
    save_method="merged_16bit",  # أو merged_4bit، إلخ
)
```

يمكن التحقق من خدمة النموذج المدمج المصدَّر مباشرة بـ vLLM.

```bash
# التحقق من الخدمة على EC2 أو محليا
vllm serve ./qwen-merged-16bit --port 8000
```

للنشر المبني على الحاويات، توفر حاويات التعلم العميق من AWS (DLCs) بيئات Docker محسّنة عبر EC2 و EKS و ECS. وحاوية vLLM DLC على وجه الخصوص مضبوطة للاستدلال عالي الأداء وتدعم أصلا التوازي التنسوري وتوازي خطوط الأنابيب عبر عدة وحدات GPU وعقد. أي أن تكوينا تم التحقق منه على مثيل EC2 واحد يتدفق بسلاسة إلى حجيرة EKS تستخدم بيئة التشغيل نفسها للتوسع الأفقي.

## الآثار على منتجات ThakiCloud

تتداخل خريطة النشر هذه مباشرة مع فلسفة تصميم ai-platform لدى ThakiCloud. يخدم ai-platform النماذج فوق Kubernetes وجدولة GPU المبنية على Kueue، والمبدأ الذي يذكره دليل AWS، وهو أن الصيغة تحدد بيئة التشغيل وبيئة التشغيل تحدد البنية التحتية، غير مقيّد بسحابة بعينها. فتقسيم GGUF للتحقق الخفيف والنشر الطرفي مقابل safetensors المدمجة للخدمة عالية الإنتاجية المبنية على vLLM ينطبق بالتساوي سواء كان EKS من AWS أو Kubernetes محلي. بل إن ThakiCloud، الذي لديه كثير من العملاء الذين يطلبون السحابة المحلية والسيادية، يستفيد أكثر من حيث قابلية النقل بتوحيد مسار النشر عبر صيغة الملف وبيئة التشغيل بدل الارتباط بخدمة مُدارة بعينها.

عمليا، يستطيع ai-platform الجمع بين التوازي التنسوري وتوازي خطوط الأنابيب اللذين توفرهما vLLM DLC وبين طابور Kueue للتشغيل متعدد المستأجرين. يمكنه اختيار تصدير بدقة مختلفة لكل عميل، مسندا نماذج 4 بت المدمجة للأحمال الحساسة للتكلفة و FP8 أو 16 بت للحساسة للجودة. وإذا استخدمت QAT من Unsloth لاستعادة الدقة حتى عند 4 بت، تتسع النقطة التي تربح فيها تكلفة خدمة منخفضة وجودة معا. هذا المطابقة الدقيقة بين الصيغة وبيئة التشغيل هي بالضبط خلفية منافسة ai-platform على تكلفة وحدة خدمة منخفضة.

وهذه الخدمة منخفضة التكلفة تغذّي بدورها اقتصاديات الوكلاء. Paxis، مستوى التحكم Agent-Native Cloud لدى ThakiCloud، يشغّل المهارات في صناديق رمل معزولة ويستدعي نماذج كبيرة مفتوحة الأوزان مرارا، فإذا كمّمت نموذج مجال مضبوطا بواسطة Unsloth ووضعته على ai-platform، أمكن لوكلاء Paxis استهلاكه بثمن زهيد. توحيد النشر المبني على الصيغة هو بحد ذاته البنية التي تخفض تكلفة وحدة أحمال عمل الوكلاء.

## القيود والاعتراضات

كخريطة نشر، هذا الدليل واضح، لكن ثمة تحفظات. أولا، تتفاوت الجودة والإنتاجية الفعليتان كثيرا بحسب تركيبة طريقة التكميم وبيئة التشغيل. كم تحتفظ نماذج 4 بت المدمجة بالدقة على vLLM، أو هل يعطي التوازي التنسوري توسعا خطيا فعلا على نموذج بعينه، يجب قياسه مباشرة على النموذج والعتاد المستهدفين؛ فعموميات الدليل وحدها لا تخبرك.

ثانيا، تأتي ملاءمة الخدمات المُدارة بثمن هو التكلفة والارتباط. حاويات SageMaker LMI تخفّض العبء التشغيلي، لكن في البيئات ذات المتطلبات المحلية القوية، قد يكون تشغيل بيئة التشغيل نفسها بنفسك على EKS أو Kubernetes الخاص بك أفضل للتحكم والتكلفة. كون دليل AWS خريطة جيدة أمر منفصل عن الحكم بنقل تلك الخريطة إلى بنيتك التحتية، وهو قرار كل فريق بنفسه.

ثالثا، كما أُشير أعلاه، هذا المقال تحليل بنيوي دون إعادة إنتاج محلية. قبل التبني الفعلي، يجب تصدير النموذج المستهدف بواسطة Unsloth وخدمته على vLLM وتأكيد زمن الاستجابة والإنتاجية والدقة لكل صيغة عبر قياساتك الخاصة.

## المصادر

- AWS Machine Learning Blog, "Deploying quantized models on Amazon SageMaker AI with Unsloth": [https://aws.amazon.com/blogs/machine-learning/deploying-quantized-models-on-amazon-sagemaker-ai-with-unsloth/](https://aws.amazon.com/blogs/machine-learning/deploying-quantized-models-on-amazon-sagemaker-ai-with-unsloth/)
- Unsloth Documentation: [https://unsloth.ai/docs](https://unsloth.ai/docs)
- AWS, "Deploy LLMs on Amazon EKS using vLLM Deep Learning Containers"
