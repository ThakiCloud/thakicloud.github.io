---
title: "سرب من الوكلاء أعاد كتابة SQLite بلغة Rust: اقتصاديات الوكلاء المتعددين من Cursor"
excerpt: "عرضت Cursor سربًا من الوكلاء أعاد بناء SQLite بلغة Rust اعتمادًا على دليلها المؤلف من 835 صفحة فقط. اجتاز 100% من مجموعة اختبارات محجوزة، وتفاوتت التكلفة 15 ضعفًا حسب مزيج النماذج، ودفع معدل الإنتاج Cursor إلى بناء نظام تحكم بالإصدارات جديد. نتحقق من الأرقام الرسمية لا من الضجيج، ونقرأه بعدسة السحابة الأصيلة للوكلاء."
seo_title: "سرب وكلاء Cursor يعيد بناء SQLite بلغة Rust: شرح اقتصاديات تكلفة الوكلاء المتعددين"
seo_description: "تحليل موثّق لسرب وكلاء Cursor الذي أعاد بناء SQLite بلغة Rust: بنية المخطِّط/العامل، فجوة تكلفة 15 ضعفًا عبر مزائج النماذج، نظام VCS بمعدل 1000 التزام في الثانية، ووكيل حلّ التعارضات، مقروءًا بعدستَي Paxis وai-platform."
date: 2026-07-21
last_modified_at: 2026-07-21
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
tags:
  - agentops
  - cursor
  - agent-swarm
  - multi-agent
  - model-economics
  - orchestration
  - paxis
  - thakicloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/cursor-agent-swarm-sqlite-rust/"
---

نشرت Cursor نهاية الأسبوع عرضًا لافتًا. أعطت سربًا من الوكلاء مهمة إعادة بناء SQLite من الصفر. لا شيفرة مصدرية، ولا مجموعة اختبارات قائمة، ولا إنترنت. كان المُدخل الوحيد هو دليل SQLite الرسمي المؤلف من 835 صفحة. قرأ السرب هذا المستند وكتب نسخة من SQLite بلغة Rust، واجتازت تلك النسخة مجموعة اختبارات محجوزة بشكل منفصل (sqllogictest) بنسبة 100%.

الأرقام تلفت الانتباه، لكن محور هذا المقال ليس بهرجة العرض. حملت خطوط الزمن على LinkedIn وX جملة واحدة: "الذكاء الاصطناعي أعاد كتابة SQLite." لم نكتفِ بترديدها. راجعنا مدونة Cursor الرسمية والإعلان الأصلي مباشرة. القصة الحقيقية ليست "نجح" مقابل "فشل"، بل أن **النتيجة نفسها كلّفت حتى 15 ضعفًا بحسب طريقة تركيب النماذج**. ولمن يُشغّل أنظمة الوكلاء المتعددين فعليًا، فإن معنى هذه الـ15 ضعفًا هو جوهر هذا المقال.

![صورة تجريدية لسرب من الوكلاء تتجمع فيه عقد مستقلة في بنية شجرية متفرعة واحدة]({{ '/assets/images/cursor-agent-swarm-sqlite-rust-hero.webp' | relative_url }})

## ماذا حدث

كانت المهمة التي استخدمتها Cursor للتحقق هي "تنفيذ SQLite بلغة Rust من الصفر باستخدام الوثائق فقط". هذه المهمة سبق أن هزمت سربًا سابقًا مرة واحدة، فصارت بمثابة اختبار حاسم لما إذا كان النظام قد تحسّن فعلًا. بالأرقام الرسمية:

- **الصحة**: اجتازت نسخة Rust التي أنتجها السرب الجديد مجموعة sqllogictest المحجوزة بنسبة 100%. تتألف هذه المجموعة من ملايين الاستعلامات.
- **سرعة التقدّم**: بتركيبة Grok 4.5 بلغ نقطة 80% خلال أربع ساعات. أما السرب السابق فقد انهار تقدّمه في المهمة نفسها ووجب إيقافه قبل الساعة الثانية.
- **تفاوت التكلفة**: بلغ فرق تكلفة تحقيق الهدف نفسه تمامًا **15 ضعفًا** حسب مزيج النماذج. كلّفت أرخص تركيبة، وهي مخطِّط Opus 4.8 مع عمّال Composer 2.5، مبلغ 1339 دولارًا، بينما كلّف تشغيل جميع الأدوار على GPT-5.5 مبلغ 10565 دولارًا.

هذا البند الأخير هو العنوان الحقيقي. فإذا كانت جودة المُخرَج واحدة بينما تتأرجح الفاتورة 15 ضعفًا، فإن المتغيّر الذي يحسم نتائج الوكلاء المتعددين ليس "أي نموذج أذكى" بل "أي نموذج يوضع أين".

## كيف يبدو هذا السرب

يتكوّن سرب Cursor من نوعين من الوكلاء. وكلاء **المخطِّط (planner)** تُشغَّل على أذكى النماذج الحدودية وتقسّم الهدف إلى بنية شجرية وتُفوّض الأجزاء. وكلاء **العامل (worker)** تُشغَّل على نماذج سريعة ورخيصة وتنفّذ الأجزاء المُفوّضة. تصف Cursor هذا بأنه مجموعة أشمل من أنظمة التنسيق الأكثر صرامة: بدل فرض بنية طوبولوجية ثابتة، ينمو شكل السرب ليلائم ملامح المشكلة، ويتوسّع الحساب والسياق بتناسب مع تعقيد المهمة.

حتى هنا الصورة مألوفة. الجزء الذي يتضمن هندسة حقيقية يأتي بعده: **التحكم بالإصدارات ومعالجة تعارض الدمج**.

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
<div class="d3-arch" data-arch-root id="rsoragentswarmsqliterust-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 667, "height": 834, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 352, "w": 611, "h": 124, "label": "مجمّع وكلاء العامل (نماذج سريعة ورخيصة)", "lx": 36, "ly": 370}], "nodes": [{"id": "GOAL", "x": 155, "y": 24, "w": 212, "h": 94, "title": ["الهدف: تنفيذ SQLite بلغة", "Rust", "(المُدخل: دليل من 835 صفحة", "فقط)"]}, {"id": "PLANNER", "x": 158, "y": 196, "w": 205, "h": 78, "title": ["وكيل المخطِّط", "نموذج حدودي · يقسّم الهدف", "إلى شجرة"]}, {"id": "W1", "x": 470, "y": 391, "w": 128, "h": 46, "title": "عامل: المُحلّل"}, {"id": "W2", "x": 252, "y": 391, "w": 163, "h": 46, "title": "عامل: محرّك التخزين"}, {"id": "W3", "x": 62, "y": 391, "w": 135, "h": 46, "title": "عامل: منفّذ SQL"}, {"id": "VCS", "x": 231, "y": 554, "w": 205, "h": 78, "title": ["نظام VCS جديد", "يتحمّل نحو 1000 التزام في", "الثانية"]}, {"id": "MERGE", "x": 122, "y": 732, "w": 177, "h": 62, "title": ["وكيل دمج محايد", "يحلّ التعارضات بإنصاف"]}, {"id": "TEST", "x": 354, "y": 724, "w": 205, "h": 78, "title": ["sqllogictest محجوز", "ملايين الاستعلامات · نجاح", "100%"]}], "edges": [{"src": "GOAL", "dst": "PLANNER", "kind": "data", "line": [261, 118, 261, 196]}, {"src": "PLANNER", "dst": "W1", "kind": "data", "curve": [[363, 264], [534, 313], [534, 352], [534, 391]]}, {"src": "PLANNER", "dst": "W2", "kind": "data", "curve": [[297, 274], [333, 313], [333, 352], [333, 391]]}, {"src": "PLANNER", "dst": "W3", "kind": "data", "curve": [[195, 274], [129, 313], [129, 352], [129, 391]]}, {"src": "W1", "dst": "VCS", "kind": "data", "curve": [[534, 437], [534, 476], [534, 515], [433, 554]]}, {"src": "W2", "dst": "VCS", "kind": "data", "line": [333, 437, 333, 554]}, {"src": "W3", "dst": "VCS", "kind": "data", "curve": [[129, 437], [129, 476], [129, 515], [231, 554]]}, {"src": "VCS", "dst": "MERGE", "kind": "event", "label": "تعارض ظهر", "line": [299, 632, 228, 732], "lx": 259, "ly": 674}, {"src": "MERGE", "dst": "VCS", "kind": "event", "label": "التزام محلول", "curve": [[193, 732], [163, 678], [163, 678], [255, 632]], "off": "50%"}, {"src": "VCS", "dst": "TEST", "kind": "data", "curve": [[389, 632], [456, 678], [456, 678], [456, 724]]}]});
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
      const container = document.getElementById('rsoragentswarmsqliterust-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rsoragentswarmsqliterust-1';
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

## لماذا بناء نظام تحكم بالإصدارات جديد

رقم واحد يفسّر هذا القرار كليًا. بلغ السرب السابق، وهو يبني متصفحًا، ذروة نحو 1000 التزام في الساعة على Git. أما النظام الجديد فيبلغ ذروة نحو 1000 التزام في **الثانية**. تحوّلت وحدة الزمن من ساعات إلى ثوانٍ، أي نحو 3600 ضعف. لا تستطيع أدوات التحكم بالإصدارات القياسية تحمّل هذا المعدل، لذا بنت Cursor نظام تحكم بالإصدارات خاصًا بها من الصفر.

لم تكن السرعة المشكلة الوحيدة. حين يلمس وكلاء كثيرون قاعدة الشيفرة نفسها دفعة واحدة، تنفجر تعارضات الدمج. وبحسب أرقام Cursor الرسمية، راكم الأسلوب القديم أكثر من 70000 تعارض حتى لحظة إيقافه، وتسارع هذا العدد بدل أن يستقر. أما التشغيل الجديد فسجّل أقل من 1000 تعارض عبر الساعات الأربع كاملة.

ما صنع الفارق هو **وكيل دمج محايد**. يتدخّل وكيل طرف ثالث في تعارضات الدمج ويحلّها نيابة عن جميع الأطراف. هدفه الوحيد أن يكون منصفًا وفعّالًا، على نحو مشابه لعمل طابور الدمج (merge queue) في فرق الهندسة. بعبارة أخرى، ما جعل السرب يعمل فعلًا لم يكن نماذج فردية أذكى بل **بنية التنسيق التحتية** التي تمتص التعارض.

## ما الذي جرى التحقق منه فعلًا

من الأمانة الفصل بين ما أكّده الإعلان وما لم يؤكّده.

المؤكّد: إعادة بناء برمجيات نُظُم بحجم SQLite انطلاقًا من الوثائق وحدها صارت الآن في متناول السرب، وقد جرى التحقق من هذا البناء باختبار محجوز مستقل. واجتياز مجموعة محجوزة بنسبة 100% يقدّم بعض الضمان بأن الوكلاء لم يفرطوا في الملاءمة للاختبارات، لأن التحقق جرى على استعلامات لم تُرَ أثناء التشغيل.

في الوقت نفسه، ثمة حذر مبرَّر. جملة "أعاد كتابة SQLite" صحيحة ضمن نطاق دلالات SQL التي تغطيها sqllogictest. لا تعني أن السرب أعاد إنتاج كل ما عالجه SQLite الحقيقي عبر عقود: توافق صيغة الملفات، والتعافي من الأعطال، والتزامن المتطرّف، ومسارات الأداء الدقيقة. هذا العرض دليل على أن السرب يستطيع ملء مواصفة قابلة للتعبير عنها باختبارات، لا دليلًا على بديل مطابق 1:1 لـ SQLite الإنتاجي. وقد قدّمته Cursor نفسها كمهمة مرجعية لا كإطلاق منتج.

## دلالات ذلك على ThakiCloud

تكاد هذه الحالة تؤكّد افتراضات التصميم خلف **Paxis** (السحابة الأصيلة للوكلاء) التي نبنيها. كما تتشابك مع منطق الجدوى الاقتصادية لـ **ai-platform** (بنيتنا التحتية للذكاء الاصطناعي والتعلّم الآلي المبنية على K8s) الكامنة تحتها.

**عدسة Paxis: التنسيق هو القدرة.** درس Cursor في جملة واحدة هو أن "تنسيقًا أفضل، لا نموذجًا أذكى، يصنع النتيجة". يقوم Paxis على هذا الافتراض تحديدًا. Paxis مستوى تحكّم يعامل المهارات والأدوات والسياسات وسجلّات التدقيق كموارد من الدرجة الأولى: يختار من بين أكثر من 960 مهارة عبر BM25، ويشغّلها في صناديق رمل معزولة، ويفكّك العمل بتنسيق متعدد الوكلاء قائم على DAG. لفصل Cursor بين المخطِّط والعامل الهيكل نفسه لتنسيق DAG في Paxis. وعلى وجه الخصوص، فإن امتصاص Cursor لتعارضات الدمج بوكيل محايد ينبع من الهاجس نفسه الذي يجعل Paxis يُمرّر كل فعل للوكيل عبر **بوابات السياسات وسجلّات التدقيق**. حين يلمس وكلاء كثيرون حالة مشتركة دفعة واحدة، فإن ما يمنع الفوضى ليس الذكاء الفردي بل قواعد التنسيق.

**عدسة ai-platform: الـ15 ضعفًا مسألة تموضع.** كون التكلفة تأرجحت 15 ضعفًا بحسب مزيج النماذج يعني أن اقتصاديات الوكلاء المتعددين تعود في النهاية إلى **أين تضع أي نموذج**. نموذج حدودي على المخطِّط ونموذج رخيص على العمّال يكلّف 1339 دولارًا؛ ودفع كل دور إلى أغلى نموذج يكلّف 10565 دولارًا. يستهدف ai-platform من ThakiCloud تحديدًا جعل هذا التموضع رخيصًا على مستوى البنية التحتية. جدولة GPU المبنية على Kueue تحشد طبقة العمّال بكثافة وبتكلفة منخفضة، وخدمة vLLM والعزل متعدد المستأجرين يخفّضان سعر الوحدة للاستدلال المتوازي واسع النطاق للنماذج الرخيصة، والنشر داخل المؤسسة والسيادي يؤمّن جدوى الاستضافة الذاتية بدل الفوترة بالاستخدام لواجهات API. فإذا خفّضت Cursor الـ15 ضعفًا بمزيج من واجهات API سحابية، فإن مؤسسة تملك بنيتها التحتية تستطيع دفع هذا المنحنى للأسفل مرة أخرى بنقل طبقة العمّال إلى الاستضافة الذاتية. الخدمة منخفضة التكلفة (ai-platform) هي ما يصنع اقتصاديات الوكلاء (Paxis).

باختصار، عرض Cursor ليس قصة عن وكلاء يفعلون شيئًا مذهلًا. إنها قصة مفادها أن البنية التحتية لتنسيق الوكلاء بتكلفة منخفضة هي حيث يُحسَم التنافس. وبناء تلك البنية التحتية في صورة منتج هو ما نفعله.

## الحدود والاعتراضات

نبدأ بأقوى اعتراض. كل هذه الأرقام نشرتها Cursor نفسها. تركيب المجموعة المحجوزة، والحالات الفاشلة، وتفاصيل التشغيل المُوقَف، لم تُتحقَّق منها جهة خارجية مستقلة. كما أن فجوة التكلفة 15 ضعفًا خاصة بتنفيذ Cursor المعيّن للسرب، ومهمة معيّنة، وأسعار نماذج في لحظة معيّنة، ومن الصعب افتراض انتقالها المباشر إلى أعباء عمل أخرى. تتغيّر أسعار النماذج فصليًا، لذا من المرجّح ألا يدوم هذا المضاعِف نفسه طويلًا.

ثانيًا، صياغة "أعاد كتابة SQLite" تترك مجالًا للمبالغة. كما ذُكر، فإن ملء مواصفة قابلة للتعبير عنها باختبارات يختلف عن استبدال قاعدة بيانات إنتاجية تراكمت فيها حالات حدّية على مدى عقود. في برمجيات النُّظُم، ثمة فجوة واسعة بين "نجاح 100% من الاختبارات" و"جدير بالثقة في الإنتاج".

ثالثًا، بناء نظام تحكم بالإصدارات من الصفر لأجل 1000 التزام في الثانية يعني أن هذا الأسلوب يفترض **استثمارًا ضخمًا في البنية التحتية**. لمعظم الفرق، العائق الأكبر ليس تشغيل السرب بل إقامة بنية VCS والعزل والدمج القادرة على تحمّله. وهذا، على نحو مفارِق، هو تحديدًا سبب الحاجة إلى مستوى تحكّم مثل السحابة الأصيلة للوكلاء. قيمة السرب تأتي لا من الوكلاء الأفراد بل من البنية التحتية القادرة على تشغيله، وللمؤسسات التي لا تملك القدرة على بناء تلك البنية بنفسها، تصبح طبقة تنسيق مُنتَجة هي البديل.

أخيرًا، للتوازن، الاتجاه المعاكس. رغم كل هذه التحفظات، فإن اجتياز دلالات SQL لبرمجيات بحجم SQLite تحقّقًا محجوزًا انطلاقًا من الوثائق وحدها نتيجة كان المتشكّك سيرفضها قبل عام. الاتجاه واضح. السؤال المتبقّي ليس "هل هو ممكن" بل "بأي رخص وبأي موثوقية تستطيع تنسيقه"، وجواب هذا السؤال يكمن في البنية التحتية.

## المصادر

- [Agent swarms and the new model economics (مدونة Cursor الرسمية)](https://cursor.com/blog/agent-swarm-model-economics)
- [إعلان Cursor الرسمي (X)](https://x.com/cursor_ai/status/2079256614238814551)
- [Cursor's AI Swarm Rebuilt SQLite From Scratch at 15x Lower Cost (AlphaSignal)](https://alphasignal.ai/news/cursor-s-ai-swarm-rebuilt-sqlite-from-scratch-at-15x-lower-cost)
