---
title: "لم يكن هناك Q4 حقيقي تقريبا داخل Q4_K_M: تشريح دقيق لآلية التكميم في GGUF"
excerpt: "هناك فرق حقيقي بين من يحمل ملف GGUF من Hugging Face ويضغط زر التشغيل فقط، ومن يعرف بالضبط أي المصفوفات (tensors) مخزنة وبكم بت داخل ذلك الملف. قمنا فعليا بتحميل ملف Q4_K_M لنموذج Qwen2.5-0.5B وفتحناه مصفوفة تلو الأخرى. وعلى الرغم من الاسم، لم تشكل مصفوفات Q4_K الحقيقية ذات 4 بت سوى 6 بالمئة من الملف، وكان عرض البت الفعلي ليس 4 بل 6.16. يشرح هذا المقال سبب حدوث ذلك، بالاستناد إلى بيانات مقاسة فعليا حول بنية الكتل الفائقة (superblock) في تكميم K وقاعدة القسمة على 256."
tags:
  - quantization
  - gguf
  - llama-cpp
  - llmops
  - self-hosting
  - vllm
  - paxis
date: 2026-07-11
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/gguf-quantization-internals/"
categories:
  - llmops
---

![رسم توضيحي تجريدي لأوزان شبكة عصبية مكممة يعاد ترتيبها إلى كتل بأحجام مختلفة]({{ '/assets/images/gguf-quantization-internals-hero.webp' | relative_url }})

## نظرة عامة

إذا سبق لك تشغيل نموذج لغوي كبير محليا، فمن المرجح أنك رأيت تسميات مثل `Q4_K_M` و`Q5_K_M` و`Q8_0`. يتوقف معظم الناس عند فهم مفاده أن "Q4 يعني 4 بت، إذن لا بد أنه الأصغر والأسرع"، ثم يقومون بتحميل الملف وتشغيله مباشرة. لكن هذه التسمية تخفي أكثر مما تظهر. قلة قليلة من الناس فتحوا فعليا ملفا موسوما بـ `Q4_K_M` وتحققوا، مصفوفة تلو الأخرى، مما إذا كان ممتلئا حقا ببيانات ذات 4 بت.

هذا المقال موجه لقادة الهندسة، والممارسين المسؤولين عن تكلفة الاستدلال، والفرق التي تسعى لتقديم النماذج محليا (on-premises). قمنا بتحميل ملف GGUF لنموذج Qwen2.5-0.5B-Instruct على عدة مستويات تكميم، وقسنا أحجام الملفات الفعلية، وقمنا بتشريح ملف واحد من نوع `Q4_K_M` بشكل كامل مصفوفة تلو الأخرى. جاءت النتيجة مختلفة تماما عن الحدس. نوضح لماذا يهم فهم هذه الفجوة لتكلفة الخدمة وجودتها، وماذا يعني ذلك بالنسبة لبنية الاستدلال التحتية لدى ThakiCloud.

ولنذكر الخلاصة أولا: في ملف `Q4_K_M` الخاص بهذا النموذج، لم تشكل المصفوفات التي هي فعلا تكميم K رباعي البت (Q4_K) سوى 6.1 بالمئة من إجمالي سعة الأوزان، وكان عرض البت الفعلي للملف ليس 4 بل **6.16 بت**. أي أن التسمية كانت أقرب إلى كذبة تقريبا.

## ما هي هذه التقنية

GGUF هو صيغة نموذج أحادية الملف تستخدم في منظومة llama.cpp. يجمع ملف واحد بين البيانات الوصفية (البنية المعمارية، أداة تجزئة الرموز، المعاملات الفائقة) وأوزان جميع المصفوفات المكممة معا. النقطة الجوهرية هي أن **كل مصفوفة يمكن أن تستخدم نوع تكميم مختلفا**. لذلك فإن تسمية على مستوى الملف مثل `Q4_K_M` لا تشير إلا إلى "النوع السائد"، وليس إلى أن الملف بأكمله من ذلك النوع.

تنقسم أنواع التكميم في llama.cpp إلى فئتين رئيسيتين. الأولى هي **الفئة القديمة (legacy)** (Q4_0، Q5_0، Q8_0) التي تجمع 32 وزنا في كتلة واحدة. والثانية هي **فئة تكميم K** (Q4_K، Q5_K، Q6_K) التي تجمع 256 وزنا في كتلة فائقة واحدة (superblock). ولأن تكميم K يقسم المقياس (scale) والحد الأدنى داخل الكتلة الفائقة بشكل أدق، فإنه يقدم جودة أفضل من الفئة القديمة عند نفس عرض البت. الحرف `K` في `Q4_K_M` يشير إلى تكميم K هذا، بينما `M` يعني الإعداد المسبق "المتوسط" الذي يرفع بعض المصفوفات الحساسة إلى دقة أعلى (Q6_K).

بالنظر عن قرب إلى بنية الكتلة الفائقة، يتضح سبب كفاءة تكميم K الأعلى. على سبيل المثال، يخزن Q4_K 256 وزنا في 144 بايت. من ذلك، تشغل القيم النقية ذات 4 بت مساحة 256 × 4 بت = 128 بايت، أما البايتات الـ16 المتبقية فهي بيانات وصفية تقسم الكتلة الفائقة إلى 8 كتل فرعية وتعيد تكميم مقياس كل منها وحدها الأدنى بـ6 بت. بعبارة أخرى، القيم نفسها ذات 4 بت، لكن الاحتفاظ بمقاييس دقيقة لإعادة بنائها يقلل من الخطأ. وهذا يتباين مع Q4_0 القديم الذي يحتفظ بمقياس واحد فقط لكل 32 وزنا. لذا فإن عرض البت الفعلي لـ Q4_K هو 144 × 8 ÷ 256 = 4.5 بت، أكبر قليلا من 4 بت النقية، لكن الجودة أكثر استقرارا بكثير.

هناك قيد حاسم واحد هنا. **لا يمكن استخدام تكميم K إلا عندما يكون عدد أعمدة المصفوفة (`ne[0]` بمصطلحات ggml) قابلا للقسمة على 256.** والسبب أن الكتلة الفائقة تعمل بوحدات من 256. وإذا لم يتحقق هذا الشرط، فإن llama.cpp يعود بصمت إلى الفئة القديمة (غالبا Q5_0). هذه القاعدة الواحدة تفسر نتيجة تجربة اليوم بأكملها.

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
<div class="d3-arch" data-arch-root id="gufquantizationinternals-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 746, "height": 838, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 295, "y": 24, "w": 149, "h": 46, "title": "ملف GGUF (Q4_K_M)"}, {"id": "B", "x": 274, "y": 148, "w": 191, "h": 62, "title": ["تحديد النوع لكل مصفوفة", "llama_tensor_get_type()"]}, {"id": "C", "x": 400, "y": 288, "w": 188, "h": 68, "title": ["هل عدد الأعمدة ne[0]", "قابل للقسمة على 256؟"]}, {"id": "D", "x": 523, "y": 448, "w": 191, "h": 78, "title": ["استخدام تكميم K", "Q4_K / Q6_K (كتلة فائقة", "256)"]}, {"id": "E", "x": 270, "y": 456, "w": 198, "h": 62, "title": ["العودة إلى الفئة القديمة", "Q5_0 (كتلة 32)"]}, {"id": "F", "x": 38, "y": 291, "w": 163, "h": 62, "title": ["رفع الدقة للمصفوفات", "الحساسة"]}, {"id": "G", "x": 24, "y": 448, "w": 191, "h": 78, "title": ["output.weight -> Q8_0", "attn_v.weight -> Q8_0", "ffn_down.weight -> Q6_K"]}, {"id": "H", "x": 281, "y": 604, "w": 177, "h": 46, "title": "تجميع عرض البت الفعلي"}, {"id": "I", "x": 281, "y": 728, "w": 177, "h": 78, "title": ["عرض البت الفعلي لكامل", "الملف = 6.16", "(التسمية 'Q4' = 4.0)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [369, 70, 369, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[424, 210], [494, 249], [494, 249], [494, 288]]}, {"src": "C", "dst": "D", "kind": "data", "label": "\"نعم\"", "curve": [[547, 356], [619, 402], [619, 402], [619, 448]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "\"لا\"", "curve": [[441, 356], [369, 402], [369, 402], [369, 456]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "curve": [[274, 206], [120, 249], [120, 249], [120, 291]]}, {"src": "F", "dst": "G", "kind": "data", "line": [120, 353, 120, 448]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[619, 526], [619, 565], [619, 565], [458, 605]]}, {"src": "E", "dst": "H", "kind": "data", "line": [369, 518, 369, 604]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[120, 526], [120, 565], [120, 565], [281, 605]]}, {"src": "H", "dst": "I", "kind": "data", "line": [369, 650, 369, 728]}]});
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
      const container = document.getElementById('gufquantizationinternals-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'gufquantizationinternals-1';
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

## الإعداد والتكامل

يمكن إعادة إنتاج التجربة دون أي تبعيات إضافية. تعيد واجهة برمجة تطبيقات Hugging Face عدد البايتات الفعلي لحجم الملف، ويمكن قراءة أنواع المصفوفات مباشرة باستخدام قارئ `gguf`.

```bash
# 1) تثبيت أداة القراءة والتحميل
pip install gguf huggingface_hub

# 2) تحميل ملف واحد فقط من نوع Q4_K_M (أقل من 500 ميجابايت لأنه نموذج 0.5B)
hf download Qwen/Qwen2.5-0.5B-Instruct-GGUF \
  qwen2.5-0.5b-instruct-q4_k_m.gguf --local-dir ./gguf
```

فيما يلي الشيفرة الخاصة بفتح أنواع مصفوفات الملف المحمل. يحتوي رأس (header) ملف GGUF على اسم كل مصفوفة وأبعادها ورقم نوع ggml مباشرة، لذا فإن مجرد تجميع هذه القيم يكشف بالضبط ما الذي يملأ الملف فعليا.

```python
from collections import Counter
from gguf import GGUFReader

r = GGUFReader("gguf/qwen2.5-0.5b-instruct-q4_k_m.gguf")
hist = Counter()
for t in r.tensors:
    hist[t.tensor_type.name] += 1
    # التحقق من النوع الفعلي لبعض المصفوفات التمثيلية
    if t.name in ("token_embd.weight", "output.weight",
                  "blk.0.attn_v.weight", "blk.0.ffn_down.weight",
                  "blk.0.attn_q.weight"):
        print(f"{t.name:26s} {t.shape} -> {t.tensor_type.name}")
print(dict(hist))
```

عدد البايتات لكل كتلة يأتي مباشرة من تعريفات ggml. فمثلا، يخزن Q4_K 256 وزنا في 144 بايت أي 4.5 بت لكل وزن، ويخزن Q6_K 256 وزنا في 210 بايت أي 6.5625 بت لكل وزن، بينما يخزن Q5_0 القديم 32 وزنا في 22 بايت أي 5.5 بت لكل وزن. وبجمع (عدد العناصر ÷ حجم الكتلة) × بايتات الكتلة لكل مصفوفة، يمكن حساب عرض البت الفعلي للملف بدقة.

## نتائج التجربة الفعلية

أولا، أحجام الملفات. هذه هي القيم المقاسة فعليا لنفس النموذج بعد تحميله على 7 مستويات تكميم، مقارنة بالأصل بصيغة fp16 (1266 ميجابايت).

| التكميم | حجم الملف | مقارنة بـ fp16 |
|---|---|---|
| Q2_K | 415.2 MB | 32.8% |
| Q3_K_M | 432.0 MB | 34.1% |
| Q4_0 | 428.7 MB | 33.9% |
| **Q4_K_M** | **491.4 MB** | **38.8%** |
| Q5_K_M | 522.2 MB | 41.2% |
| Q6_K | 650.4 MB | 51.4% |
| Q8_0 | 675.7 MB | 53.4% |

هناك ما يثير الغرابة بالفعل هنا. الفرق بين Q2_K (415 ميجابايت) و Q4_0 (429 ميجابايت) هو 14 ميجابايت فقط. خفضنا عدد البتات إلى النصف، لكن حجم الملف لم ينخفض تقريبا. بل إن `Q4_K_M` (491 ميجابايت) أكبر فعليا من `Q4_0` (429 ميجابايت) ذي 4 بت النقية. بالنظر إلى الأسماء وحدها، هذه النتيجة غير مفهومة.

يتضح السبب الحقيقي عند فتح ملف `Q4_K_M` مصفوفة تلو الأخرى. فيما يلي توزيع الأنواع عبر 291 مصفوفة فيه.

| النوع الفعلي | عدد المصفوفات | عرض البت الاسمي | حصة سعة الأوزان |
|---|---|---|---|
| Q5_0 | 133 | 5.5 | 54.9% |
| Q8_0 | 13 | 8.5 | 30.1% |
| Q6_K | 12 | 6.5625 | 8.8% |
| Q4_K | 12 | 4.5 | 6.1% |
| F32 (norm/bias) | 121 | 32.0 | 0.1% |

![مخطط يظهر أحجام الملفات عبر مستويات التكميم لنموذج Qwen2.5-0.5B، وتكوين أنواع المصفوفات الفعلي داخل Q4_K_M. عرض البت الفعلي لـ Q4_K_M هو 6.16، بعيدا كثيرا عن رقم التسمية 4.0]({{ '/assets/images/gguf-quantization-internals-results.webp' | relative_url }})

على الرغم من تسمية `Q4_K_M`، لم يشكل تكميم K الحقيقي رباعي البت (Q4_K) سوى **6.1 بالمئة** من إجمالي سعة الأوزان. وبدلا من ذلك، استحوذ النوع القديم Q5_0 ذو 5.5 بت على أكثر من النصف (54.9 بالمئة)، واستهلك Q8_0 ذو 8.5 بت نسبة 30 بالمئة. وعند حساب عرض البت الفعلي لكامل الملف، نحصل على **6.16 بت**، أي أكثر من 1.5 ضعف الـ4 بت التي توحي بها التسمية.

بالتحقق من المصفوفات التمثيلية واحدة تلو الأخرى، يتضح النمط بجلاء. كانت الأنواع المقاسة فعليا كما يلي:

- `token_embd.weight` (896 × 151936) -> **Q5_0**
- `output.weight` (896 × 151936) -> **Q8_0**
- `blk.0.ffn_down.weight` (4864 × 896) -> **Q6_K**
- `blk.0.attn_v.weight` (896 × 128) -> **Q8_0**
- `blk.0.attn_q.weight` (896 × 896) -> **Q5_0**

هل تلاحظ النمط؟ لم تظهر المصفوفات التي تحمل تكميم K (Q4_K، Q6_K) إلا حيث كان عدد الأعمدة `ne[0]` يساوي 4864، كما في `ffn_down`. والرقم 4864 قابل للقسمة على 256 (19 × 256). أما معظم المصفوفات الأخرى فعدد أعمدتها `ne[0]` يساوي 896، والرقم 896 غير قابل للقسمة على 256 (3.5 × 256). لذلك لم تتمكن هذه المصفوفات من استخدام تكميم K إطلاقا وعادت جميعها إلى الفئة القديمة Q5_0. وإذا أضفنا إلى ذلك رفع الدقة (Q5_0، Q8_0) للمصفوفات الحساسة للجودة مثل التضمين (embedding) والمخرجات وقيمة الانتباه (attention value)، نحصل على ملف موسوم بـ `Q4_K_M` لكن جوهره الفعلي كتل تتراوح بين 5.5 و8.5 بت.

هذا بالضبط مصدر عرض البت الفعلي البالغ 6.16. يحتوي هذا الملف على ما مجموعه 630 مليون وزن خاضع للتكميم، مخزنة في نحو 485 ميجابايت من البايتات. 485,452,288 بايت × 8 ÷ 630,167,424 وزنا = 6.16 بت لكل وزن. وبإضافة نحو 6 ميجابايت من البيانات الوصفية للملف وحشو المحاذاة (alignment padding)، تتطابق النتيجة تماما مع حجم الملف الفعلي البالغ 491 ميجابايت. وتطابق الحساب مع حجم الملف هو أيضا دليل على دقة قراءة أنواع المصفوفات.

هذا يفسر أيضا النقطتين الغريبتين في جدول أحجام الملفات. السبب في أن Q2_K (415 ميجابايت) أصغر بالكاد من Q4_0 (429 ميجابايت) هو أن مصفوفات التضمين والمخرجات في هذا النموذج الصغير تشكل حصة كبيرة من إجمالي الأوزان، وهي تبقى بدقة عالية عند أي مستوى تكميم. مهما خفضت عدد البتات، تبقى تكلفة ثابتة في القاع لا تنخفض. أما سبب كون `Q4_K_M` أكبر من `Q4_0` النقي ذي 4 بت، فهو أن الإعداد المسبق `M` دفع ثمن رفع المصفوفات الحساسة إلى Q6_K وQ8_0 على شكل زيادة في حجم الملف. رقم التسمية أقل، لكن عرض البت الفعلي أعلى في الواقع.

وباختصار، أظهرت هذه التجربة من خلال القياس ثلاث حقائق. أولا، تشير التسمية على مستوى الملف إلى النوع السائد فقط ولا تضمن عرض البت الفعلي. ثانيا، في النماذج الصغيرة التي لا يكون فيها الحجم المخفي (hidden size) من مضاعفات 256، يتعطل تكميم K إلى حد كبير، مما يوسع الفجوة بين التسمية والجوهر. ثالثا، تشكل مصفوفات التضمين والمخرجات في النماذج الصغيرة حصة كبيرة من إجمالي السعة، وبمجرد الاحتفاظ بها بدقة عالية، تتضاءل بشكل كبير وفورات "التكميم الرباعي البت" المفترضة.

## الدلالات على منتجات ThakiCloud

اقتصرت هذه التجربة على تشريح نموذج صغير واحد، لكن دروسها تنتقل مباشرة إلى بنية الخدمة الإنتاجية التحتية. تقدم منصة ai-platform التابعة لـ ThakiCloud النماذج لبيئات عملاء متنوعة فوق Kubernetes وجدولة موارد GPU القائمة على Kueue. وفي هذا السياق، فإن "أي تكميم نختار" ليس مسألة ذوق، بل قرار يحدد تخصيص ذاكرة GPU، وحجم الدُفعة (batch)، وفي النهاية التكلفة لكل رمز (token).

الثقة بالتسمية كما هي تخل بتخطيط السعة. إذا افترضت أن `Q4_K_M` يعني "4 بت، إذن ربع الحجم الأصلي" وخصصت ذاكرة GPU على هذا الأساس، فستجد، كما في التجربة أعلاه، أنه يستهلك فعليا نحو 40 بالمئة من الأصل، وتنفد فتحات الدُفعات أسرع مما هو متوقع. يهم هذا الأمر بشكل خاص في الخدمة متعددة المستأجرين (multi-tenant)، حيث يجب حشر العديد من النماذج الصغيرة بكثافة على عقدة واحدة. وهناك، فإن الفرق بين قياس عرض البت الفعلي فعليا والاكتفاء بالثقة بالتسمية ينعكس مباشرة على عدد النماذج التي يمكن للعقدة استيعابها. لهذا السبب بالتحديد نتحقق من ملفات GGUF مصفوفة تلو الأخرى عند بناء صور الخدمة (serving images). وبالنسبة للعملاء الذين يتطلبون استضافة ذاتية أو نشرا محليا أو سياديا على وجه الخصوص، تتحول عادة القياس هذه بدلا من الافتراض إلى ميزة تنافسية حقيقية من حيث التكلفة.

جعل هذا التحقق نفسه مهمة قابلة للتكرار هو دور Paxis. وPaxis هي منصة التحكم الخاصة بـ ThakiCloud للسحابة الأصلية للوكلاء (Agent-Native Cloud) التي تعمل فوق ai-platform، وتتعامل مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. فإذا تم تسجيل تجربة اليوم، أي تحميل ملف GGUF وتجميع أنواع المصفوفات وإطلاق تحذير عند تجاوز عرض البت الفعلي حدا معينا، كمهارة واحدة، فإنها تعمل في بيئة معزولة (sandbox) وتمر جميع النتائج عبر بوابات السياسات وسجلات التدقيق. وبدلا من أن يفتح شخص الملف يدويا في كل مرة يصل فيها نموذج جديد إلى السجل، يعمل هيكل معتمد (validated skeleton) تلقائيا. هكذا يترابط الاقتصاد الذي تخلقه الخدمة منخفضة التكلفة (ai-platform) مع التنسيق (Paxis) الذي يجعل تلك الخدمة قابلة للتكرار بأمان.

## القيود والحجج المضادة

هناك بعض النقاط التي يجب توضيحها بشكل صريح.

أولا، هذه النتائج تقترب من حالة قصوى خاصة بنموذج Qwen2.5-0.5B الذي يبلغ حجمه المخفي 896. أما في النماذج الأكبر التي يكون فيها الحجم المخفي من مضاعفات 256 (مثل 4096 أو 8192)، فإن تكميم K يُطبق بشكل طبيعي، ويقترب عرض البت الفعلي لـ `Q4_K_M` كثيرا من التسمية، عند نحو 4.8 بت.

بعبارة أخرى، الدرس الصحيح ليس أن "التسمية كذبة دائما"، بل أن "الفجوة بين التسمية والجوهر تختلف بشكل كبير حسب بنية النموذج، وتكون أكبر كلما كان النموذج أصغر".

ثانيا، ليس بالضرورة أن يكون حجم الملف الكبير أمرا سيئا. فالاحتفاظ بمصفوفات التضمين والمخرجات بدقة عالية هو خيار متعمد لمنع انهيار الجودة في النماذج الصغيرة. بعبارة أخرى، ملف `Q4_K_M` هذا ليس ملفا "سيء الصنع"، بل هو نتيجة منطقية لرفع الدقة تلقائيا للحفاظ على الجودة في نموذج صغير. غير أن هذا الثمن لا يظهر في التسمية.

ثالثا، اقتصر هذا المقال على قياس بنية الملف وسعته، ولم يقس جودة الاستدلال الفعلية (الحيرة اللغوية perplexity، أو نتائج المعايير القياسية). وتتطلب العلاقة بين عرض البت والجودة تجربة منفصلة، نتركها موضوعا لمقال قادم. وما يمكن قوله هنا هو مبدأ تشغيلي واحد فقط: لا تخطط للسعة والذاكرة استنادا إلى التسمية، بل قسها فعليا.

الفرق بين الاكتفاء بالضغط على زر تشغيل نموذج محلي ومعرفة ما بداخل الملف فعليا يكمن بالضبط في عادة القياس هذه. خمس دقائق تقضيها في التحقق من الأرقام وراء التسمية يمكن أن تغير دقة خطة تكلفة الخدمة بأكملها.

## المصادر

- مستودع نموذج Qwen2.5-0.5B-Instruct-GGUF: [huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF](https://huggingface.co/Qwen/Qwen2.5-0.5B-Instruct-GGUF)
- وثائق التكميم في llama.cpp: [github.com/ggml-org/llama.cpp](https://github.com/ggml-org/llama.cpp/blob/master/tools/quantize/README.md)
- تم قياس أحجام الملفات وتوزيعات أنواع المصفوفات وعروض البت الفعلية مباشرة من ملفات فعلية تم تحميلها من المستودع أعلاه.
