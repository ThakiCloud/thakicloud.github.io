---
title: "Claude Code ومحاكي iOS: حلقة برمجة مغلقة تبني وتشغّل وتُشاهد بنفسها"
excerpt: "أطلق تطبيق Claude Code لسطح المكتب ميزة تُظهر محاكي iOS في لوحة جانبية بجوار المحادثة، ضمن نسخة تجريبية عامة. نستعرض ما تغيّره هذه الحلقة المغلقة التي يبني فيها Claude التطبيق ويشغّله ويشاهد الشاشة قيد التنفيذ ليصلح الأخطاء بنفسه، وكيفية تفعيلها، ولماذا تهمّ من منظور السحابة الأصيلة للوكلاء."
date: 2026-07-22
lang: ar
tags:
  - ClaudeCode
  - iOS
  - 시뮬레이터
  - AI코딩
  - 에이전트루프
  - 개발생산성
  - Paxis
author_profile: true
toc: true
toc_label: تشريح حلقة محاكي iOS
published: true
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/claude-code-ios-simulator/"
---

![صورة تجريدية تجسّد حلقة مغلقة تتصل فيها شاشة التنفيذ والكود معًا كحلقة ضوء واحدة]({{ '/assets/images/claude-code-ios-simulator-hero.png' | relative_url }})

## لماذا تستحق هذه المقالة القراءة

إذا كنت مطوّرًا تبني تطبيقات iOS باستخدام Claude Code على macOS، فخلاصة هذه المقالة واحدة: أصبحت "الحلقة المغلقة" التي يشغّل فيها وكيل البرمجة التطبيق الذي بناه بنفسه ويراقب الشاشة أثناء إصلاحها تعمل الآن داخل تطبيق سطح المكتب مباشرة، دون الحاجة إلى أدوات منفصلة. سنستعرض في ما يلي ما يجب تعلّمه من جديد، ولماذا لا يُعدّ هذا التغيير مجرد ميزة راحة بل مسألة تتعلق بالطريقة التي يُقارب بها الوكيل تقارب جودة الكود من تلقاء نفسه.

## نظرة عامة

اللحظة التي يصبح فيها وكيل البرمجة بالذكاء الاصطناعي مفيدًا حقًا ليست عندما يُخرج الكود مرة واحدة وينتهي الأمر، بل عندما يتأكد بنفسه من أن هذا الكود يعمل فعليًا ثم يعيد إصلاحه. في كود الخلفية (backend)، يمكن تشغيل الاختبارات للحصول على إشارة موضوعية بالنجاح أو الفشل. أما واجهة تطبيقات الجوّال فمختلفة تمامًا؛ فمعرفة ما إذا كانت شاشة الترحيب تظهر كما هو مقصود، أو ما إذا كان الضغط على زر ما ينقل إلى الشاشة التالية، أمرٌ لا يمكن التحقق منه إلا بالعين المجرّدة. حتى الآن كان هذا التحقق من مسؤولية الإنسان، وكان الوكيل يتوقف بعد كتابة الكود إلى أن يشغّل الإنسان المحاكي، يضغط على الأزرار، ثم يمرّر الملاحظات.

في 21 يوليو 2026، طرح تطبيق Claude Code لسطح المكتب ميزة تسدّ هذه الفجوة مباشرة، ضمن نسخة تجريبية عامة. عند بناء تطبيق iOS وتشغيله، يفتح محاكي iOS من Apple في لوحة جانبية بجوار المحادثة مباشرة، ويرى Claude شاشة التطبيق قيد التشغيل بنفسه، فيتفاعل مع الواجهة ويستمر في تعديل الكود حتى يعمل كما هو مطلوب. بذلك تنطوي عملية التنقل ذهابًا وإيابًا التي كانت تتطلب من الإنسان تشغيل المحاكي والتحقق ثم إعادة صياغة النتيجة بالكلمات، ضمن حلقة واحدة.

في ThakiCloud، ونحن نبني سحابة أصيلة للوكلاء (agent-native cloud)، نصطدم باستمرار بسؤال "كيف يراقب الوكيل نتيجة فعله ويقرر خطوته التالية؟". ولأن هذه الميزة تمثّل إجابة ملموسة جدًا على هذا السؤال، سنتناولها هنا من منظور تصميم الحلقة، لا كمجرد عرض لميزة جديدة.

## ما هو تكامل محاكي iOS

الفكرة الأساسية بسيطة. عندما تفتح مشروع iOS في Claude Code لسطح المكتب وتطلب منه بناء التطبيق وتشغيله، تظهر لوحة المحاكي بجانب المحادثة ويجعل Claude من تلك الشاشة موضوع مراقبته. يُفتح محاكٍ مستقل لكل جلسة، بحيث يمكن تنفيذ عدة مهام في آنٍ واحد دون أن تتداخل شاشات كل منها مع الأخرى. وتعمل هذه اللوحة في الجلسات المحلية فقط، لأن المحاكي نفسه برنامج لا يعمل إلا على macOS.

ما يجعل هذه الميزة لافتة ليس أنها مجرد طبقة عرض إضافية، بل أنها فتحت للوكيل "قناة مراقبة" جديدة. حتى الآن، كانت معظم الإشارات التي يمكن لوكيل البرمجة التحقق منها إشارات نصية: أخطاء المُصرّف (compiler)، نتائج الاختبارات، السجلّات. أما كيف يبدو التطبيق فعليًا وكيف يستجيب، فكان لا يصل إلى الوكيل إلا عبر عين الإنسان ولسانه. تكامل المحاكي يحوّل هذه النتيجة البصرية إلى إشارة يمكن للوكيل التحقق منها مباشرة بنفسه.

إذا بسّطنا التدفق الكامل، نحصل على حلقة متكررة على النحو التالي.

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
<div class="d3-arch" data-arch-root id="22claudecodeiossimulator-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 651, "height": 1198, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 190, "y": 24, "w": 191, "h": 62, "title": ["فتح مشروع iOS في", "Claude Code لسطح المكتب"]}, {"id": "B", "x": 186, "y": 164, "w": 198, "h": 46, "title": "طلب بناء التطبيق وتشغيله"}, {"id": "C", "x": 24, "y": 288, "w": 205, "h": 46, "title": "Claude ينفّذ عملية البناء"}, {"id": "D", "x": 54, "y": 412, "w": 146, "h": 52, "title": "هل نجح البناء؟"}, {"id": "E", "x": 115, "y": 564, "w": 163, "h": 46, "title": "مراقبة سجلّ الأخطاء"}, {"id": "F", "x": 333, "y": 556, "w": 142, "h": 62, "title": ["تشغيل التطبيق في", "لوحة المحاكي"]}, {"id": "G", "x": 323, "y": 696, "w": 163, "h": 62, "title": ["Claude يراقب الشاشة", "قيد التشغيل"]}, {"id": "H", "x": 326, "y": 836, "w": 156, "h": 62, "title": ["التفاعل مع الواجهة", "واختبارها"]}, {"id": "I", "x": 307, "y": 976, "w": 195, "h": 52, "title": "هل يعمل كما هو مقصود؟"}, {"id": "J", "x": 499, "y": 1120, "w": 120, "h": 46, "title": "تعديل الكود"}, {"id": "K", "x": 324, "y": 1120, "w": 120, "h": 46, "title": "إنهاء الحلقة"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [285, 86, 285, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[226, 210], [127, 249], [127, 249], [127, 288]]}, {"src": "C", "dst": "D", "kind": "data", "line": [127, 334, 127, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "فشل", "curve": [[127, 464], [127, 510], [127, 510], [176, 564]], "off": "50%"}, {"src": "E", "dst": "B", "kind": "data", "curve": [[223, 564], [285, 438], [285, 311], [285, 210]]}, {"src": "D", "dst": "F", "kind": "data", "label": "نجح", "curve": [[200, 457], [404, 510], [404, 510], [404, 556]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [404, 618, 404, 696]}, {"src": "G", "dst": "H", "kind": "data", "line": [404, 758, 404, 836]}, {"src": "H", "dst": "I", "kind": "data", "line": [404, 898, 404, 976]}, {"src": "I", "dst": "J", "kind": "data", "label": "لا", "line": [436, 1028, 537, 1120], "lx": 492, "ly": 1070}, {"src": "J", "dst": "B", "kind": "data", "curve": [[563, 1120], [572, 797], [572, 438], [384, 208]]}, {"src": "I", "dst": "K", "kind": "data", "label": "نعم", "curve": [[397, 1028], [384, 1074], [384, 1074], [384, 1120]], "off": "50%"}]});
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
      const container = document.getElementById('22claudecodeiossimulator-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22claudecodeiossimulator-1';
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

كما يتضح من الرسم، يقتصر تدخّل الإنسان على الطلب الأول والتحقق الأخير فقط، بينما تدور عمليات البناء والتشغيل والمراقبة والتعديل في الوسط بالكامل داخل الوكيل. تمامًا كما يُغلق مُشغّل الاختبارات (test runner) الحلقة في تطوير الخلفية عبر إشارة موضوعية بالنجاح أو الفشل، يتولى المحاكي هنا الدور ذاته في مساحة واجهة المستخدم البصرية.

## كيفية تفعيلها واستخدامها

لا تتطلب هذه الميزة إعدادًا معقدًا. لكن شروطها المسبقة واضحة تمامًا. أولًا، يجب أن يكون النظام macOS، إذ لا يعمل محاكي iOS خارج منظومة Apple، وبالتالي لا يمكن استخدام هذه اللوحة على Windows أو Linux. ثانيًا، يجب توفّر Xcode مع تثبيت منصة iOS، لأن البنية التحتية التي يستخدمها Claude فعليًا لتنفيذ البناء وتشغيل المحاكي هي في النهاية أدوات بناء Xcode والمحاكي نفسه. أما من ناحية الاشتراك، فيمكن لمستخدمي خطط Pro وMax وTeam استخدام هذه الميزة.

الاستخدام نفسه حواري بالكامل. تفتح مشروع iOS في Claude Code لسطح المكتب، وتحدّد مجلد المشروع كمساحة عمل الجلسة. يعمل هذا مع أي مشروع يبني تطبيقًا لمحاكي iOS. بعد ذلك، يكفي أن تطلب من Claude تشغيل التطبيق أو اختباره. على سبيل المثال، إذا طلبت بلغة طبيعية "ابنِ التطبيق وشغّله في المحاكي وتحقق من مسار الترحيب"، ينفّذ Claude عملية البناء ويعرض التطبيق في لوحة المحاكي، ثم يراقب الشاشة ويواصل عملية التحقق.

باختصار، لا توجد أوامر أو ملفات إعداد جديدة تحتاج إلى حفظها فعليًا. ما يتغيّر هو نطاق "ما يمكن تكليف الوكيل به". فبعد أن كان الطلب يقتصر سابقًا على "أصلح هذه الشاشة لتظهر بهذا الشكل" ثم يتولى الإنسان تشغيلها والتحقق بنفسه، أصبح بالإمكان الآن تضمين خطوة التحقق ذاتها ضمن التعليمات. ومع أن التفاصيل الدقيقة ستُصقل لاحقًا بما أن الميزة ما زالت في مرحلة النسخة التجريبية العامة، فإن اتجاه نموذج التفاعل واضح فعلًا.

## ما تمنحه الحلقة المغلقة لوكيل البرمجة

المعنى الحقيقي لهذه الميزة لا يكمن في الراحة بقدر ما يكمن في اكتمال الحلقة. لكي يكون الوكيل مفيدًا، يجب أن تتوفر لديه وسيلة للتحقق من مخرجاته بنفسه، وإذا ظلّ هذا التحقق معتمدًا في كل مرة على عين الإنسان ويده، يبقى الوكيل عالقًا في أتمتة منقوصة. وكان العمل على واجهة iOS مثالًا نموذجيًا على هذا النقص؛ فالكود يكتبه الوكيل، لكن التحقق من صحته على الشاشة كان يتطلب دائمًا عين الإنسان.

عندما يُلحق المحاكي بجانب المحادثة ويُتاح للوكيل مراقبة الشاشة قيد التشغيل، تتصل المراقبة والحكم والتعديل ضمن حلقة واحدة. عند فشل البناء، يقرأ الوكيل الخطأ ويصلحه، وعند تشغيل التطبيق، ينظر إلى الشاشة ويكتشف ما يختلف عن المقصود ثم يعيد الإصلاح. المهم هنا أن هذا التكرار يدور دون تنقّل الإنسان ذهابًا وإيابًا. صحيح أن هذه المراقبة تتم عبر التقاط لقطات للشاشة والتحقق منها، ولذلك لا تحلّ محل التفاعلات الدقيقة التي يشعر بها الإنسان بيديه على جهاز حقيقي. ومع ذلك، فإن مجرد اختفاء ذلك الانقطاع الذي كان يحدث عندما "يصلح الوكيل الكود دون أن يعرف كيف تغيّرت الشاشة وينتظر التعليمة التالية" يغيّر طبيعة العمل بشكل ملموس.

تتقاطع هذه البنية مع مبادئ هندسة الحلقات (loop engineering) التي رسّختها ThakiCloud داخليًا: الإشارة الموثوقة هي الإشارة الحتمية التي تُعيد النجاح أو الفشل بشكل موضوعي، ولا يمكن لتقرير الوكيل الذاتي ("يبدو أن الأمر تمّ بنجاح") أن يكون شرط إنهاء للحلقة. المحاكي هنا أداة توسّع تلك الإشارة الحتمية لتشمل المجال البصري. فنجاح البناء كان بالفعل إشارة واضحة، والآن، مع إضافة قناة مراقبة أخرى هي شاشة التنفيذ، تُغلق حلقة العمل على واجهة المستخدم بإحكام أكبر.

## دلالات التطبيق على منتجات ThakiCloud

بما أن هذه الميزة موضوعها الوكلاء، فمن الطبيعي النظر إليها من عدسة Paxis. Paxis هي سحابة ThakiCloud الأصيلة للوكلاء، تُعامل المهارات (skills) والأدوات والسياسات وسجلّات التدقيق كموارد من الدرجة الأولى، وتنفّذ المهارات داخل صناديق رملية (sandboxes) معزولة، وتُمرّر كل فعل عبر بوابات سياسة وسجلّات تدقيق. وما يُظهره تكامل محاكي Claude Code من "حلقة مغلقة تبني وتشغّل وتراقب وتصلح" ينتمي بالضبط إلى نفس فئة نموذج التنفيذ الذي تتطلع إليه Paxis: أن ينفّذ الوكيل شيئًا ما في بيئة معزولة، ويراقب النتيجة ليقرر الخطوة التالية، على أن يجري كل ذلك ضمن حدود محكومة.

من منظور Paxis، تحمل هذه الحالة دلالتين. الأولى، أن فتح قناة يستطيع الوكيل من خلالها مراقبة نتيجة تنفيذه هو ما يحدّد عمق الأتمتة. فتمامًا كما أُغلقت حلقة العمل على واجهة المستخدم التي لم تكن تُغلق بالإشارات النصية وحدها بفضل قناة مراقبة بصرية واحدة، فإن ما يحدّد الجودة في Paxis أيضًا هو امتلاك كل مهارة إشارة تتحقق بها من مخرجاتها الخاصة. الثانية، أن هذا التنفيذ يجري في بيئة معزولة لكل جلسة. فكما يفتح Claude Code محاكيًا مستقلًا لكل جلسة، فإن التنفيذ المعزول داخل الصناديق الرملية في Paxis يضمن، بنفس المبدأ التصميمي، ألا تلوّث مهام الوكلاء المتعددة بعضها بعضًا.

وإذا أردنا إضافة ملاحظة من زاوية البنية التحتية، فإن جعل مثل هذه الحلقات المغلقة عملية يتطلّب القدرة على تشغيل بيئات التنفيذ وإيقافها بسرعة وبتكلفة زهيدة. وقدرة منصّة ai-platform التابعة لـ ThakiCloud على جدولة بيئات تنفيذ معزولة بكفاءة فوق Kubernetes تشكّل الأساس الذي يدعم اقتصاديات تشغيل حلقات الوكلاء على نطاق واسع. فبدون تنفيذ معزول منخفض التكلفة، لا يمكن لحلقة الوكيل التي تكرّر المراقبة والتعديل أن تدور دون عبء مالي.

## الحدود والاعتراضات

لتجنّب المبالغة في تقدير هذه الميزة، لا بدّ من تحديد حدودها بوضوح أيضًا. أولًا، المنصّة مقيّدة بـ macOS. هذا قيد لا مفرّ منه بما أن محاكي iOS لا يعمل خارج منظومة Apple، وهذا يعني أن هذه الحلقة متاحة لمستخدمي Mac فقط. كما أن تثبيت Xcode شرط أساسي، ولا يمكن استخدامها إلا في خطط Pro وMax وTeam، واللوحة تقتصر على الجلسات المحلية. أما توقّع الحصول على التجربة نفسها في الجلسات البعيدة أو بيئات المشاركة الجماعية، فلا يزال أمرًا سابقًا لأوانه.

كذلك، الميزة نفسها ما زالت في نسخة تجريبية عامة. ما أُعلن عنه ونُشر هو طريقة عملها وأسلوب استخدامها، وليس معيارًا (benchmark) يقيس مدى سرعة ودقة تقارب هذه الحلقة فعليًا. وبالتالي لا يمكن الجزم رقميًا بمدى التحسّن المتحقق. علاوة على ذلك، فإن مراقبة الوكيل للشاشة تتم عبر التقاط الشاشة والتحقق منها، ما يعني أنها لا تحلّ محل الاستجابة الدقيقة لإيماءات اللمس التي يشعر بها الإنسان على جهاز حقيقي، ولا الإحساس الفعلي بالأداء. فالرسوم المتحركة المعقّدة، وسلوك إمكانية الوصول (accessibility)، والمشكلات التي لا تظهر إلا على الأجهزة الحقيقية، لا تزال تحتاج إلى تحقّق بشري.

وأخيرًا، ثمة اعتراض جدير بالذكر يتعلق بخطر تحوّل هذه الراحة إلى ثقة غير مُتحقَّق منها. فكلما دارت الحلقة بسلاسة أكبر، سهُل على الإنسان أن يتقبّل النتيجة كما هي دون مراجعة. وكون الوكيل يقول "لقد تحققت من ذلك" لا يعني أن هذا الحكم هو تحقّق فعلي. مراقبة المحاكي إشارة مفيدة، لا موافقة نهائية، وتحديدًا في الجوانب الدقيقة لتجربة المستخدم، لا يزال الإنسان بحاجة إلى الضغط بيده والحكم بنفسه.

## خلاصة

تكامل محاكي iOS مع Claude Code قد يبدو صغيرًا، لكن اتجاهه واضح: الحلقة المغلقة التي يشغّل فيها وكيل البرمجة ما بناه بنفسه ويراقبه ويصلحه، امتدت الآن إلى مجال واجهة المستخدم الذي كان يعتمد على الإنسان طويلًا. بالنسبة لأي مطوّر يبني تطبيقات iOS باستخدام Claude Code على macOS، هذا تغيير يستحق التجربة الآن، وهو يدعو إلى إعادة التفكير في طريقة العمل نفسها، بما أن نطاق ما يمكن تكليف الوكيل به قد اتّسع.

وعلى نطاق أوسع، تُذكّرنا هذه الحالة مجددًا بأن ما يجعل الوكيل مفيدًا ليس حجم النموذج وحده، بل مسألة تتعلق بالبنية التحتية (harness): إلى أي مدى تُغلق الحلقة التي يراقب فيها الوكيل النتيجة ليقرر خطوته التالية. وهذه بالضبط هي المسألة التي تعمل ThakiCloud على حلّها عبر Paxis وai-platform. وخلاصة اليوم في سطر واحد: في المرة القادمة التي تكلّف فيها وكيلًا بمهمة تتعلق بواجهة المستخدم، لا تتوقف عند طلب إصلاح الكود، بل اطلب منه "شغّله وتحقق بنفسك أيضًا". أن تُترك مهمة إغلاق الحلقة للوكيل لا للإنسان، هذا هو التغيير الأكثر عملية الذي تمنحه هذه الميزة.

## المصادر

- [الوثائق الرسمية لـ Claude Code: Test iOS apps in the simulator](https://code.claude.com/docs/en/desktop-ios-simulator)
- [منشور ClaudeDevs (X)](https://x.com/ClaudeDevs/status/2079674432038248611)
- [9to5Mac: Claude Code brings live iOS app testing into its Mac app](https://9to5mac.com/2026/07/21/claude-code-brings-live-ios-app-testing-into-its-mac-app/)
- [MacRumors: Claude Code Can Now Build and Test iOS Apps in Apple's Simulator](https://www.macrumors.com/2026/07/21/claude-code-ios-simulator/)
