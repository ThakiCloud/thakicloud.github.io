---
title: "‏744B في بِت واحد: السؤال المحلي الذي يطرحه Unsloth GLM-5.2 Dynamic GGUF"
excerpt: "قلّص Unsloth أوزان GLM-5.2 (نحو 744B بصيغة MoE) من 1.51 تيرابايت بدقة BF16 إلى 176 جيجابايت عبر GGUF ديناميكي بِبِت واحد. أصبح نموذج مفتوح من الفئة الرائدة يعمل على جهاز Mac واحد بذاكرة 256 جيجابايت أو صندوق GPU واحد متعدد البطاقات. نستعرض الأرقام المنشورة لحجم ودقة كل مستوى تكميم، وأين تناسب الخدمة المحلية بصيغة GGUF منصة Kubernetes متعددة المستأجرين مثل ThakiCloud وأين تختلف."
seo_title: "تحليل تكميم Unsloth GLM-5.2 بِبِت واحد GGUF للخدمة المحلية - Thaki Cloud"
seo_description: "تحليل لـ Unsloth GLM-5.2 Dynamic GGUF (من 1.51 تيرابايت إلى 176 جيجابايت، بِت واحد): حجم ودقة كل مستوى تكميم، والتشغيل المحلي على Mac بذاكرة 256 جيجابايت، والمفاضلة بين llama.cpp و vLLM من منظور منصة ThakiCloud متعددة المستأجرين على Kubernetes."
date: 2026-06-25
last_modified_at: 2026-06-25
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/unsloth-glm-5-2-1bit-gguf/"
tags:
  - gguf
  - quantization
  - unsloth
  - glm-5
  - llama-cpp
  - on-premise
  - moe
  - inference-optimization
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "microchip"
toc_sticky: true
reading_time: true
categories:
  - llmops
published: false
---

أول جدار يصطدم به أي فريق يخدم نموذجًا كبيرًا على بنيته الخاصة هو الذاكرة دائمًا. استدعاء نموذج رائد عبر واجهة برمجية خارجية يُخرج بياناتك من الشركة، واستضافته داخليًا تعني وضع مئات الجيجابايت — وغالبًا أكثر من تيرابايت — من الأوزان في مكانٍ ما. يمثّل `unsloth/GLM-5.2-GGUF` الذي أصدره Unsloth في يونيو 2026 دراسة حالة لخفض هذا الجدار عبر التكميم. فهو يأخذ GLM-5.2، وهو نموذج MoE مفتوح بنحو 744 مليار معامل، ويضغط أوزانه البالغة 1.51 تيرابايت بدقة BF16 إلى 176 جيجابايت عبر GGUF ديناميكي بِبِت واحد. كل رقم في هذه المقالة هو رقم منشور من Unsloth أو Hugging Face. لا يمكن استضافة نموذج 744B في بيئة التحليل هذه، لذا بدلًا من إعادة إنتاج القياسات ذاتيًا نستشهد بالأرقام العامة ونوضّح حدودها بصراحة.

## نظرة عامة

‏GLM-5.2 نموذج لغوي كبير مفتوح الأوزان من Z.ai (Zhipu). وهو نموذج Mixture-of-Experts (MoE) بنحو 744 مليار معامل إجمالي مع نافذة سياق تصل إلى مليون رمز. ووفق وثائق Unsloth وتقارير متعددة، يسجّل نتائج موازية لـ Claude 4.8 Opus و GPT-5.5 و Gemini 3.1 Pro عبر القياسات المجمّعة بما فيها Artificial Analysis — ولهذا يوصَف بأنه أقوى نموذج مفتوح حتى الآن.

المشكلة هي الحجم. نقطة التحقق الأصلية بدقة BF16 تبلغ نحو 1.51 تيرابايت، يصعب وضعها على خادم واحد. ما فعله Unsloth هو تكميم هذه الأوزان بطريقة Dynamic 2.0 GGUF، منتجًا نسخًا من بِت واحد حتى أربعة بتات. وتنزل نسخة البِت الواحد إلى 176 جيجابايت — صغيرة بما يكفي لتحميلها على جهاز Mac Studio واحد بذاكرة موحّدة سعتها 256 جيجابايت، أو صندوق GPU واحد متعدد البطاقات. نموذج مصنّف من الفئة الرائدة بات يعمل على عتاد مكتبي بدلًا من خزانة مركز بيانات.

تشغّل ThakiCloud منصة SaaS متعددة المستأجرين للذكاء الاصطناعي وتعلّم الآلة على Kubernetes، وتتعامل مع الخدمة المحلية وداخل VPC ليستخدم العملاء نماذج قوية دون إخراج البيانات. لذا فإن سؤال «إلى أي حجم صغير يمكن تشغيل نموذج مفتوح من الفئة الرائدة» يرتبط مباشرة بتكلفة الخدمة وسيادة البيانات لدى عملائنا. لكن الخلاصة مقدمًا: تكميم GGUF قوي في السيناريوهات المحلية وأحادية المستخدم، لكنه يتصرّف بشكل مختلف تحت الخدمة متعددة المستأجرين عالية التزامن. هذه المقالة تتناول هذا الحد.

## ما هذه التقنية

‏GGUF هي صيغة ملف النموذج المستخدمة في منظومة llama.cpp، والتكميم يمثّل أوزان الفاصلة العائمة 16 بت بعدد أقل من البتات لتقليل الحجم والذاكرة. والمفتاح هنا هو طريقة **Dynamic 2.0** من Unsloth. فبدلًا من تقليص كل طبقة إلى بِت واحد بشكل موحّد، تحافظ على الطبقات الأكثر حساسية لفقدان المعلومات بعرض بتات أعلى وتضغط الطبقات غير الحساسة بقوة فقط. حتى عندما تُسمّى «بِت واحد»، فإن عرض البت فعليًا مختلط لكل طبقة، ولهذا تفقد دقة أقل من التكميم الساذج عند المتوسط نفسه من البتات.

كون GLM-5.2 نموذج MoE يجعل هذا المزج ذا معنى خاص. فـ MoE يفعّل فقط الخبراء الذين يختارهم الموجّه لكل رمز، وليس كامل الـ 744B، فيتناسب الحساب مع عدد المعاملات النشطة. بعبارة أخرى، **‏MoE يتولّى الحساب، و Dynamic GGUF يتولّى الذاكرة.** يوضّح المخطط أدناه المحورين ومسارات الخدمة المتفرّعة من منظور ThakiCloud.

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
<div class="d3-arch" data-arch-root id="0625unslothglm521bitgguf-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 758, "height": 1130, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 363, "y": 24, "w": 273, "h": 294, "label": "محور التكميم (الذاكرة)", "lx": 375, "ly": 42}, {"x": 24, "y": 540, "w": 216, "h": 558, "label": "محور الخدمة (السرعة)", "lx": 36, "ly": 558}], "nodes": [{"id": "A", "x": 425, "y": 63, "w": 149, "h": 62, "title": ["GLM-5.2 BF16", "نحو 1.51 تيرابايت"]}, {"id": "B", "x": 400, "y": 217, "w": 198, "h": 62, "title": ["GGUF ديناميكي بِبِت واحد", "UD-TQ1_0 176 جيجابايت"]}, {"id": "C", "x": 62, "y": 603, "w": 120, "h": 46, "title": "رمز الإدخال"}, {"id": "D", "x": 75, "y": 751, "w": 120, "h": 46, "title": "موجّه MoE"}, {"id": "E", "x": 68, "y": 889, "w": 135, "h": 46, "title": "الخبراء النشطون"}, {"id": "F", "x": 75, "y": 1013, "w": 120, "h": 46, "title": "رمز الإخراج"}, {"id": "R", "x": 426, "y": 396, "w": 146, "h": 52, "title": "سيناريو الخدمة"}, {"id": "L", "x": 517, "y": 579, "w": 198, "h": 94, "title": ["llama.cpp", "Mac 256 جيجابايت / متعدد", "GPU", "نحو 21.6 رمز/ث"]}, {"id": "V", "x": 278, "y": 595, "w": 184, "h": 62, "title": ["vLLM + FP8/FP4", "تجميع مستمر، K8s/Kueue"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "\"Unsloth Dynamic 2.0<br/>توزيع البتات لكل طبقة\"", "line": [499, 125, 499, 217], "lx": 499, "ly": 167}, {"src": "C", "dst": "D", "kind": "data", "line": [122, 649, 130, 751]}, {"src": "D", "dst": "E", "kind": "data", "label": "\"بعض خبراء 744B فقط\"", "line": [135, 797, 135, 889], "lx": 135, "ly": 839}, {"src": "E", "dst": "F", "kind": "data", "line": [135, 935, 135, 1013]}, {"src": "B", "dst": "R", "kind": "data", "line": [499, 279, 499, 396]}, {"src": "R", "dst": "L", "kind": "data", "label": "\"مستخدم واحد، محلي، إثبات مفهوم محلي\"", "curve": [[541, 448], [616, 494], [616, 540], [616, 579]], "off": "50%"}, {"src": "R", "dst": "V", "kind": "data", "label": "\"متعدد المستأجرين عالي التزامن\"", "curve": [[452, 448], [370, 494], [370, 540], [370, 595]], "off": "50%"}, {"src": "L", "dst": "D", "kind": "data", "curve": [[517, 646], [188, 712], [188, 712], [155, 751]]}, {"src": "V", "dst": "D", "kind": "data", "curve": [[287, 657], [142, 712], [142, 712], [138, 751]]}]});
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
      const container = document.getElementById('0625unslothglm521bitgguf-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0625unslothglm521bitgguf-1';
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

على محور التكميم، تمر أوزان BF16 عبر معايرة Unsloth Dynamic 2.0 لتصبح GGUF بِبِت واحد. وعلى محور الخدمة، يفعّل موجّه MoE بعض الخبراء فقط لكل رمز. وحيث يلتقي المحوران يتفرّع السيناريو: llama.cpp + GGUF للتحقق المحلي أحادي المستخدم؛ و vLLM + تكميم GPU للخدمة عالية التزامن. نعود إلى هذا التفرّع لاحقًا.

## التثبيت والتكامل

ميزة GGUF هي انخفاض حاجز الدخول — تحتاج فقط إلى llama.cpp أو غلاف له. المسار القياسي من وثائق Unsloth كالتالي.

نزّل فقط المستوى الذي تريده من Hugging Face. لنسخة البِت الواحد `UD-TQ1_0`:

```bash
# تنزيل شظايا GGUF بِبِت واحد فقط عبر huggingface_hub
pip install -U huggingface_hub hf_transfer
HF_HUB_ENABLE_HF_TRANSFER=1 \
huggingface-cli download unsloth/GLM-5.2-GGUF \
  --include "*UD-TQ1_0*" \
  --local-dir GLM-5.2-GGUF
```

ثم شغّل خادمًا بـ llama.cpp. وبما أنه نموذج MoE، اضبط `--n-gpu-layers` وطول السياق وفق بيئتك.

```bash
# خادم llama.cpp (نقطة نهاية متوافقة مع OpenAI)
./llama-server \
  --model GLM-5.2-GGUF/GLM-5.2-UD-TQ1_0-00001-of-*.gguf \
  --ctx-size 16384 \
  --n-gpu-layers 999 \
  --jinja \
  --host 0.0.0.0 --port 8080
```

على جهاز Mac Studio (M3 Ultra) بذاكرة موحّدة 256 جيجابايت، يستطيع خلفية Metal الاحتفاظ بكل الطبقات في الذاكرة؛ وعلى إعدادات x86 متعددة الـ GPU توزّع الطبقات بين GPU و CPU/RAM. كلما ارتفع مستوى التكميم زادت حاجته للذاكرة، فتصبح سعة عتادك عمليًا السقف لاختيار مستوى التكميم.

## النتائج الفعلية

من هنا فصاعدًا هذه أرقام منشورة من Unsloth و Hugging Face. لا يمكن استضافة نموذج 744B في بيئة التحليل هذه، فهذه أرقام عامة موثّقة وليست مُعاد إنتاجها ذاتيًا. أدناه جدول حجم الملف لكل مستوى تكميم.

| التكميم | النسخة الممثِّلة | حجم الملف | مقابل BF16 (1.51 تيرابايت) |
|---|---|---|---|
| بِت واحد | UD-TQ1_0 | 176 جيجابايت | أصغر بنحو 88% |
| بِت واحد | UD-IQ1_S | 204 جيجابايت | أصغر بنحو 86% |
| بِتان | UD-IQ2_M | 255 جيجابايت | أصغر بنحو 83% |
| ثلاثة بتات | UD-Q3_K_XL | 332 جيجابايت | أصغر بنحو 78% |
| أربعة بتات | Q4_K_M | 456 جيجابايت | أصغر بنحو 70% |

![حجم ملف GLM-5.2 لكل مستوى تكميم ونسبة الضغط مقابل BF16]({{ '/assets/images/unsloth-glm-5-2-1bit-gguf-results.webp' | relative_url }})

أما الدقة، فيذكر Unsloth أن التكميم الديناميكي يفقد أقل من التكميم الساذج عند المتوسط نفسه من البتات. وتشير المواد العامة إلى أن نسخة البِت الواحد الديناميكية تحتفظ بنحو 76% [تقديري] على مقياس دقتها الداخلي، ونسخة البِتين بنحو 82%، مع كونها أصغر بأكثر من 80% من الأصل. يختلف المقياس الدقيق ومجموعة البيانات حسب النسخة ومجموعة التقييم، لذا اقرأ هذه الأرقام كاتجاه أكثر من كونها قيمًا مطلقة: يزداد الفقد تدريجيًا مع انخفاض البتات، لكن حتى البِت الواحد يبقى في نطاق قابل للاستخدام. كما ينشر Unsloth نتائج GGUF الديناميكي على معيار Aider Polyglot للبرمجة، ما يتيح التحقق المتقاطع لجودة كل مستوى في مهام البرمجة.

تعتمد السرعة بشدة على العتاد. وفق التقارير العامة، عملت نسخة البِت الواحد بنحو 21.6 رمز/ث على جهاز Mac Studio بذاكرة 256 جيجابايت (M3 Ultra). هذا كافٍ لمستخدم واحد في الاستخدام الحواري، لكن الصورة تتغيّر تحت حمل الخادم مع عشرات الطلبات المتزامنة. هذا الفرق هو جوهر القسم التالي.

## التطبيق على منصة ThakiCloud للذكاء الاصطناعي على Kubernetes

تخدم ThakiCloud النماذج عبر بيئات عملاء متنوعة، وعدد لا بأس به منها يحمل قيد «لا يمكن إخراج البيانات». ففي القطاعات المالية والعامة والصحية، حيث سيادة البيانات أساسية، يكون استدعاء نموذج رائد عبر واجهة خارجية ببساطة خارج الطاولة. وهنا يصبح GLM-5.2 Dynamic GGUF ورقة قوية: فهو يحوّل نموذجًا مفتوحًا من الفئة الرائدة بحجم 1.51 تيرابايت إلى شيء قابل للتشغيل على عقدة واحدة بسعة 256 جيجابايت تقريبًا.

هناك ثلاث زوايا ملموسة. أولًا، **إثبات المفهوم والتقييم محليًا**. قبل الدخول إلى مركز بيانات العميل، يكون تشغيل GGUF محليًا أرخص طريقة للتحقق مما إذا كان النموذج جيدًا بما يكفي في ذلك المجال — على جهاز واحد، دون حجز عنقود GPU. ثانيًا، **الأحمال منخفضة التكرار وعالية الحساسية**. للتحليل الداخلي ومعالجة المستندات حيث المستخدمون المتزامنون قليلون لكن البيانات يجب ألا تخرج أبدًا، تحقّق الخدمة أحادية العقدة بصيغة GGUF التكلفة والأمان معًا. ثالثًا، **استيعاب تنوّع العتاد**. يدعم llama.cpp واجهة Metal على Mac، وبطاقات x86 GPU، وإزاحة الحساب إلى CPU، ما يمنح مرونة لاستخدام أي عتاد مختلط يملكه العميل أصلًا.

تصفّ منصة ThakiCloud القياسية وحدات GPU عبر Kueue على Kubernetes وتشغّل النماذج على vLLM. وإضافة مسار GGUF تتيح تقديم قائمة خدمة من مستويين تتناسب مع وضع العميل: «vLLM + FP8/FP4 للخدمة متعددة المستأجرين عالية التزامن، و llama.cpp + Dynamic GGUF للخدمة المحلية أحادية العقدة». ضمن عائلة GLM-5.2 نفسها، نبدّل طريقة التكميم وزمن التشغيل حسب طبيعة الحمل. والفرق بين مزوّد يملك هذا الخيار وآخر لا يملكه يظهر لحظة يقول العميل «هذا لن ينجح في بيئتنا».

## القيود والاعتراضات

لتجنّب المبالغة في تقدير هذه التقنية، يجب توضيح بضعة أمور.

أولًا، **البِت الواحد ليس مجانيًا.** حتى مع تقليل التكميم الديناميكي للفقد، فإن نسخة البِت الواحد أقل دقة بوضوح من الأصل. في الاستدلال المعقّد والبرمجة الطويلة حيث تتراكم الأخطاء، تُلمَس الفجوة مقابل نسخ البِتين إلى الأربعة بتات. عبارة «نموذج رائد بِبِت واحد» جذّابة، لكن التبنّي الفعلي يتطلب قياس نقطة التعادل في الجودة لكل مهمة على حدة.

ثانيًا، **‏GGUF ليست صيغة للخدمة متعددة المستأجرين.** رقم 21.6 رمز/ث أحادي التدفّق. يجمّع التجميع المستمر في vLLM الطلبات المتزامنة لرفع الإنتاجية، و llama.cpp ضعيف في هذا المجال. للخدمة متعددة المستأجرين بنمط SaaS مع عشرات إلى مئات المستخدمين المتزامنين، عادةً ما يتفوّق تكميم GPU بصيغة FP8/FP4 + vLLM على GGUF بِبِت واحد في الإنتاجية لكل وحدة تكلفة. مكان GGUF هو «بأمان في بيئة واحدة»، لا «لكثيرين في آن واحد».

ثالثًا، **العتاد لم يصبح رخيصًا.** جهاز Mac Studio بذاكرة موحّدة 256 جيجابايت أرخص بكثير من وحدات GPU لمراكز البيانات مثل 8×H100، لكنه ليس جهازًا اقتصاديًا بأي حال. «يعمل على المكتب» لا تعني «في متناول الجميع».

رابعًا، **معظم الأرقام العامة هي تقارير Unsloth الذاتية.** تتغيّر الدقة والسرعة لكل مستوى حسب مجموعة التقييم والعتاد وإعدادات التشغيل. وينبغي أن ترتكز قرارات التبنّي على نتائج مُعاد إنتاجها ببياناتك، لا على إعلانات المزوّد. ولهذا بالضبط تستشهد هذه المقالة بالمصادر بدلًا من إعادة الإنتاج الذاتي.

باختصار، يُقيَّم Unsloth GLM-5.2 Dynamic GGUF على أفضل وجه بأنه «أداة تخفض حاجز الدخول المحلي لنموذج مفتوح من الفئة الرائدة بدرجة واحدة». ليس حلًا سحريًا يستبدل كل الخدمة، بل خيار قوي في السيناريوهات التي تهمّ فيها سيادة البيانات وتكلفة العقدة الواحدة. ولمنصة مثل ThakiCloud قادرة على تبديل أزمنة التشغيل حسب الحمل، إنها ورقة إضافية لتحويل «لا نستطيع» لدى العميل إلى «إليك الطريقة».

## المصادر

- [unsloth/GLM-5.2-GGUF · Hugging Face](https://huggingface.co/unsloth/GLM-5.2-GGUF)
- [GLM-5.2 - How to Run Locally | Unsloth Documentation](https://unsloth.ai/docs/models/glm-5.2)
- [Unsloth Dynamic 2.0 GGUFs | Unsloth Documentation](https://unsloth.ai/docs/basics/unsloth-dynamic-2.0-ggufs)
- [unsloth/GLM-5.2-GGUF · GLM-5.2 GGUF Benchmarks! (Discussion)](https://huggingface.co/unsloth/GLM-5.2-GGUF/discussions/3)
- [Unsloth Quantizes GLM-5.2's 1.51TB to 217GB for Local Inference | AI Weekly](https://aiweekly.co/alerts/unsloth-quantizes-glm-52s-151tb-to-217gb-for-local-inference)
