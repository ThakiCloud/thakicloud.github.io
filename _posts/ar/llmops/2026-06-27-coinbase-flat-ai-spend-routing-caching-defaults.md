---
title: "استخدام الرموز ينفجر والإنفاق على الذكاء الاصطناعي يتراجع للنصف: استراتيجية الإعدادات الافتراضية الأفضل لدى Coinbase"
excerpt: "وصفة الرئيس التنفيذي لـ Coinbase بريان أرمسترونغ للتحكم في كلفة الذكاء الاصطناعي لم تكن حدود الاستخدام ولا تنبيهات الإنفاق، بل إعدادات افتراضية أفضل وتوجيه وتخزين مؤقت. واستناداً إلى اكتشاف أن 91% من الموظفين لا يبلغون حدود استخدامهم أصلاً، بدّلت الشركة إعدادات بوابة LLM الافتراضية إلى نماذج مفتوحة الأوزان بدل إضافة الاحتكاك. نحلل الاستراتيجية وما تعنيه من منظور الخدمة منخفضة الكلفة على منصة ai-platform من ThakiCloud."
seo_title: "استراتيجية Coinbase لكلفة الذكاء الاصطناعي: توجيه وتخزين وإعدادات - Thaki Cloud"
seo_description: "خفّضت Coinbase الإنفاق على الذكاء الاصطناعي إلى النصف تقريباً رغم النمو الأسي لاستخدام الرموز. المفاتيح هي توجيه النماذج والتخزين المؤقت الفعّال والإعدادات الافتراضية مفتوحة الأوزان. نحلل بيانات أن 91% من الموظفين لا يبلغون الحدود واستراتيجية بوابة LLM، ونربطها بالخدمة متعددة المستأجرين منخفضة الكلفة على ai-platform من ThakiCloud."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - llmops
  - model-routing
  - inference-cost
  - open-weight-models
  - llm-gateway
  - cost-optimization
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "coins"
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/coinbase-flat-ai-spend-routing-caching-defaults/"
categories:
  - llmops
---

## نظرة عامة

أي مؤسسة تستخدم الذكاء الاصطناعي بجدية تصطدم بالمعضلة نفسها في مرحلة ما. كلما زاد استخدام الموظفين لنماذج اللغة، ارتفعت الإنتاجية، لكن فاتورة الرموز ترتفع أسياً معها. الاستجابة الشائعة هي وضع حدّ للاستخدام، وإرسال تنبيهات عند تجاوزه، وجعل استخدام النماذج باهظة الثمن مرهقاً. غير أن هذا النهج، بدل كبح الكلفة، يضيف احتكاكاً لإنتاجية الموظف كأثر جانبي.

في يونيو 2026، شارك الرئيس التنفيذي لـ Coinbase بريان أرمسترونغ حلّ شركته المختلف. بعبارته، إنه «كيف تبقي الإنفاق على الذكاء الاصطناعي ثابتاً بينما ينمو استخدام الرموز أسياً»، والخلاصة واضحة: حُلّها بإعدادات افتراضية أفضل وتوجيه وتخزين مؤقت، لا بالاحتكاك وتنبيهات الإنفاق. تقول Coinbase إنها خفّضت الإنفاق على الذكاء الاصطناعي إلى النصف تقريباً بينما انفجر استخدام الرموز.

تشغّل ThakiCloud منصة ai-platform التي تخدم النماذج عبر بيئات عملاء متنوعة، لذا فإن كيفية التحكم في كلفة الاستدلال ليست قصة الآخرين. استراتيجية Coinbase سياسة داخلية لشركة واحدة، لكن في داخلها مبادئ LLMOps تنطبق على كل من يشغّل بنية خدمة النماذج. يعرض هذا المقال تلك الاستراتيجية كما هي، ويحلل ما تعنيه من منظور منصة الخدمة.

## الجوهر: الإعدادات الافتراضية لا الاحتكاك

نقطة انطلاق نهج Coinbase هي البيانات. أثناء محاولة إحكام حدود الاستخدام، اكتشفوا أن 91% من الموظفين لا يبلغون حدود استخدامهم أصلاً. بعبارة أخرى، لم يكن مُحرّك ارتفاع الكلفة «حفنة من المستخدمين الكثيفين يستنفدون حدودهم»، بل مشكلة بنيوية: السلوك الافتراضي للاستخدام العام كان موجّهاً نحو النماذج باهظة الثمن.

من هنا جاء الشعار «إعدادات افتراضية أفضل، لا حدود استخدام». لا يزال بإمكان المهندسين اختيار أي نموذج يريدونه بحرية. التغيير هو في النموذج الافتراضي الذي يصلون إليه حين لا يحدّدون شيئاً، بتبديله من نموذج حدودي باهظ إلى نموذج مفتوح الأوزان أرخص. تقول Coinbase إنها تجرّب جعل نماذج مفتوحة الأوزان مثل GLM 5.2 وKimi 2.7 هي الافتراضية في بوابة LLM الخاصة بها.

قوة هذه الفكرة أنها لا تحارب أنماط السلوك البشري. معظم المستخدمين يأخذون الإعداد الافتراضي ببساطة. غيّر الافتراضي ودون إجبار أي شيء، ينتقل سلوك الأغلبية طبيعياً. إنه عكس خفض الحدود وإضافة التنبيهات الذي يخلق احتكاكاً بين المستخدمين والنظام. ويبدو المسار الكامل كالتالي.

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
<div class="d3-arch" data-arch-root id="ndroutingcachingdefaults-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 709, "height": 958, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 253, "y": 24, "w": 128, "h": 62, "title": ["طلب المهندس", "نموذج غير محدد"]}, {"id": "B", "x": 257, "y": 164, "w": 120, "h": 46, "title": "بوابة LLM"}, {"id": "C", "x": 94, "y": 288, "w": 209, "h": 52, "title": "سياسة الإعداد الافتراضي"}, {"id": "D", "x": 24, "y": 440, "w": 142, "h": 62, "title": ["نموذج حدودي مكلف", "تكلفة رمز مرتفعة"]}, {"id": "E", "x": 221, "y": 432, "w": 163, "h": 78, "title": ["إعداد افتراضي مفتوح", "الأوزان", "GLM 5.2 / Kimi 2.7"]}, {"id": "F", "x": 241, "y": 602, "w": 184, "h": 46, "title": "توجيه حسب صعوبة المهمة"}, {"id": "G", "x": 184, "y": 748, "w": 121, "h": 46, "title": "نموذج اقتصادي"}, {"id": "H", "x": 360, "y": 740, "w": 120, "h": 62, "title": ["نموذج حدودي", "اختيار صريح"]}, {"id": "I", "x": 479, "y": 448, "w": 198, "h": 46, "title": "البحث في الذاكرة المؤقتة"}, {"id": "J", "x": 535, "y": 740, "w": 121, "h": 62, "title": ["استجابة مخزنة", "رموز 0"]}, {"id": "K", "x": 360, "y": 880, "w": 121, "h": 46, "title": "تسطيح الإنفاق"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [317, 86, 317, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[273, 210], [199, 249], [199, 249], [199, 288]]}, {"src": "C", "dst": "D", "kind": "data", "label": "الإعداد الحالي", "curve": [[161, 340], [95, 386], [95, 386], [95, 440]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "بعد التغيير", "curve": [[236, 340], [303, 386], [303, 386], [303, 432]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "curve": [[303, 510], [303, 556], [303, 556], [323, 602]]}, {"src": "F", "dst": "G", "kind": "data", "label": "مهام بسيطة متكررة", "curve": [[303, 648], [245, 694], [245, 694], [245, 748]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "label": "مهام عالية الصعوبة", "curve": [[362, 648], [420, 694], [420, 694], [420, 740]], "off": "50%"}, {"src": "B", "dst": "I", "kind": "data", "curve": [[377, 201], [578, 249], [578, 386], [578, 448]]}, {"src": "I", "dst": "J", "kind": "data", "label": "إصابة", "curve": [[583, 494], [596, 556], [596, 694], [596, 740]], "off": "50%"}, {"src": "I", "dst": "F", "kind": "data", "label": "إخفاق", "curve": [[554, 494], [490, 556], [490, 556], [385, 602]], "off": "50%"}, {"src": "G", "dst": "K", "kind": "data", "curve": [[245, 794], [245, 841], [245, 841], [360, 882]]}, {"src": "H", "dst": "K", "kind": "data", "line": [420, 802, 420, 880]}, {"src": "J", "dst": "K", "kind": "data", "curve": [[596, 802], [596, 841], [596, 841], [481, 882]]}]});
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
      const container = document.getElementById('ndroutingcachingdefaults-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ndroutingcachingdefaults-1';
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

*كيف يمرّ طلب لم يُحدَّد له نموذج عبر سياسة الإعداد الافتراضي للبوابة والبحث في الذاكرة المؤقتة والتوجيه حسب الصعوبة ليتسطّح الإنفاق بكلفة منخفضة. (تسميات الرسم بالكورية، مشتركة عبر اللغات.)*

## ثلاث تقنيات

يتلخص ضبط الكلفة الذي طرحه أرمسترونغ في ثلاثة محاور. لا أحد منها اختراع جديد، لكن المفتاح هو جمع الثلاثة في مكان واحد، البوابة.

أولاً، **توجيه أذكى للنماذج**. بدل معالجة كل مهمة بالنموذج نفسه، تُرسل كل مهمة إلى أرخص نموذج قادر على إنجازها. المهام البسيطة المتكررة مثل التلخيص أو التصنيف تكفيها نماذج صغيرة، ولا يُرفع إلى نموذج حدودي إلا المهام التي تحتاج استدلالاً معقداً. الفكرة الجوهرية أن النموذج الأعلى أداءً ليس ضرورياً دائماً. لا داعي لاستخدام نموذج باهظ في مهام روتينية لا يصنع فيها أداء النماذج الحدودية أي فرق في النتيجة.

ثانياً، **التخزين المؤقت الفعّال**. تُزال المخرجات المكرّرة للاستعلامات المتكررة. حين يَرِد السؤال نفسه عدة مرات، يُعاد رد مخزّن بدل استدعاء النموذج في كل مرة. إصابة الذاكرة المؤقتة لا تستهلك رموزاً إطلاقاً، لذا كلما زاد تكرار عبء العمل، كبر التوفير. في بيئات تتكرر فيها أسئلة متشابهة، مثل مساعدي الشيفرة أو استعلامات الوثائق الداخلية، يكون التخزين المؤقت رافعة بسيطة لكن قوية.

ثالثاً، **التحوّل إلى نماذج أرخص مفتوحة الأوزان**. في الأعمال الروتينية التي لا يضيف فيها أداء النماذج الحدودية قيمة، ينتقل العمل إلى نماذج مفتوحة الأوزان. وبالاقتران مع استراتيجية الإعدادات الافتراضية السابقة، تُضبط الوجهة الافتراضية للتوجيه نفسها على مفتوح الأوزان. ومضى أرمسترونغ أبعد، متوقعاً أن 80% من أعباء عمل الذكاء الاصطناعي ستنتقل خلال 18 شهراً إلى نماذج أرخص بنسبة 99%، وأن ما يحدّد سقف نمو الذكاء الاصطناعي سيكون بنية الطاقة والحوسبة، لا جودة النماذج.

التقنيات الثلاث يعزّز بعضها بعضاً. التوجيه يوزّع المهام على النموذج المناسب، والتخزين المؤقت يزيل الاستدعاءات المكرّرة، والإعدادات الافتراضية مفتوحة الأوزان تنقل مركز ثقل ذلك التوزيع نحو الكلفة المنخفضة. هذا المزيج هو سرّ تحقّق الاستخدام المنفجر والإنفاق الثابت في آن واحد.

## دلالات على منتجات ThakiCloud

استراتيجية Coinbase قصة شركة واحدة لها بوابة LLM داخلية، لكن مبادئها تتداخل تماماً مع عرض القيمة لخدمة النماذج متعددة المستأجرين التي تقدّمها منصة **ai-platform** من ThakiCloud. تخدم ai-platform النماذج بـ vLLM وأمثاله فوق جدولة موارد GPU القائمة على Kubernetes وKueue، وما فعلته Coinbase عند بوابة واحدة يمكننا تقديمه بعمق أكبر على مستوى منصة الخدمة.

أولاً، **التوجيه كميزة منصة**. وزّعت Coinbase المهام على النماذج عند البوابة. ولأن ai-platform من ThakiCloud تخدم نماذج كثيرة في آن واحد في بيئة متعددة المستأجرين، يمكنها ضبط سياسات التوجيه على مستوى البنية لكل مستأجر: «نموذج صغير للمهام البسيطة، ونموذج كبير للصعبة فقط». ولأننا نستضيف النماذج مباشرة، فإن حرية قرارات التوجيه وشفافية الكلفة أكبر مما هي عليه عند الاعتماد على واجهات برمجة خارجية.

ثانياً، **اقتصاديات خدمة مفتوحة الأوزان**. السبب الجوهري لجعل Coinbase نماذج مثل GLM 5.2 وKimi 2.7 افتراضية هو الكلفة المنخفضة. تتخصص ai-platform في خدمة هذه النماذج مفتوحة الأوزان مباشرة في بيئات داخل المؤسسة أو سيادية. عبر الخدمة المُكمّمة على وحدات GPU استهلاكية، والاستدلال عالي الإنتاجية القائم على vLLM، وعزل الموارد متعدد المستأجرين، يكون خفض كلفة الخدمة لكل رمز ميزتنا التنافسية. وبالتحرّر من تسعير الرموز لواجهات النماذج الحدودية الخارجية، كلما شغّلت النماذج مفتوحة الأوزان بكفاءة أكبر على بنيتك، اقتربت فعلاً من منطقة «الأرخص بنسبة 99%» التي وصفتها Coinbase.

ثالثاً، **الرؤية بأن الطاقة والحوسبة هما السقف**. رأى أرمسترونغ أن ما يحدّد سقف نمو الذكاء الاصطناعي هو بنية الطاقة والحوسبة، لا جودة النماذج. وهذا يشير إلى المكان نفسه الذي يشير إليه اتجاه ThakiCloud في جدولة موارد GPU بكفاءة عبر Kueue والتأكيد على كفاءة الكلفة داخل المؤسسة. في عصر تحدّد فيه كلفة الاستدلال أعباء العمل، تصبح بنية الخدمة نفسها، التي تشغّل النموذج نفسه أرخص وأكثر، عامل التمايز.

وعلى صعيد السياسة والتدقيق، تبرز أيضاً **Paxis**، السحابة الأصيلة للوكلاء من ThakiCloud. «سياسة الإعداد الافتراضي» لدى Coinbase هي في جوهرها بوابة سياسة تُطبَّق على كل طلب يمرّ عبر البوابة. ولأن Paxis تمرّر كل إجراء وكيل عبر بوابات السياسة وسجلات التدقيق، يمكنها ترك سجلّ قابل للتتبّع لأي نموذج استُخدم افتراضياً لأي مهمة وأين نشأت الكلفة. ضبط الكلفة يبدأ في النهاية من الوضوح، والوضوح يتحقق حين يُسجَّل كل استدعاء.

## القيود والاعتراضات

لهذه الاستراتيجية قيود واضحة أيضاً. أولاً، مشكلة دقة التوجيه. إن كان حكم «هذه المهمة تكفيها نماذج صغيرة» خاطئاً، تنخفض الجودة، وقد تتجاوز تلك الخسارة توفير الرموز. حين تتطلب مهمة تبدو بسيطة استدلالاً دقيقاً في الواقع، يعود ثمن توجيهها إلى نموذج رخيص نتيجةً خاطئة. سياسة التوجيه ليست شيئاً تكتبه مرة وتنتهي؛ تحتاج إلى تقييم وتصحيح مستمرين.

ثانياً، نطاق التخزين المؤقت. التخزين المؤقت قوي للاستعلامات المتكررة، لكن في الأعمال الإبداعية أو المخصّصة التي يَرِد فيها سياق مختلف ومدخل مختلف كل مرة، تكون نسب الإصابة منخفضة. لا يستفيد كل عبء عمل بالقدر نفسه من التخزين المؤقت، لذا يعتمد التوفير بشدة على طبيعة عبء العمل.

ثالثاً، فجوة جودة النماذج مفتوحة الأوزان. توقّع أن «80% ستنتقل خلال 18 شهراً إلى نماذج أرخص بنسبة 99%» توقّع جريء. صحيح أن النماذج مفتوحة الأوزان تلحق بسرعة، لكن الفجوة مع النماذج الحدودية لا تزال قائمة في المجالات التي يهمّ فيها الاستدلال العالي الصعوبة أو السياق الطويل أو الاستقرار. اضبط الافتراضي على مفتوح الأوزان، لكن إن رسمت حدّ متى تَرفع إلى الحدودي خطأً، تتدهور تجربة المستخدم. هذا التوقّع أأمن قراءةً بوصفه اتجاهاً لا يقيناً.

ومع ذلك، الدرس الجوهري من حالة Coinbase متين. ينبغي حلّ ضبط الكلفة بتغيير الإعدادات الافتراضية والبنية، لا بإضافة احتكاك للمستخدمين. وكلما امتلكت تلك البنية، أي كلما خدمت النماذج بنفسك، اتسع نطاق تحكّمك. والخدمة متعددة المستأجرين منخفضة الكلفة التي تنشدها منصة ai-platform من ThakiCloud هي بالضبط ذلك الأساس للتحكّم.

## المصادر

- [تغريدة بريان أرمسترونغ](https://x.com/brian_armstrong/status/2070670644577280109): "How to keep AI spend flat while token usage grows exponentially" (2026-06-27)
- [Coinbase Says AI Costs Are Staying Flat As Token Usage Explodes (CryptoAdventure)](https://cryptoadventure.com/coinbase-says-ai-costs-are-staying-flat-as-token-usage-explodes/)
- [Coinbase CEO Halved AI Costs (Yahoo Finance)](https://finance.yahoo.com/markets/crypto/articles/coinbase-ceo-halved-ai-costs-130000536.html)
