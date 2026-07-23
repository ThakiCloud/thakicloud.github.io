---
title: "تحرير الفيديو بواسطة وكيل برمجي: نظرة داخل مهارة video-use"
excerpt: "شاركها midudev فانتشرت بسرعة. مهارة video-use من فريق browser-use مفتوحة المصدر ومجانية بالكامل: ضع اللقطات الخام في مجلد، اكتب جملة واحدة، ويتولى الوكيل البرمجي القص وإزالة الحشو والترجمة وتدرّج الألوان والرسوم المتحركة والإخراج. نحلل تصميمها القائم على وكلاء فرعيين متوازيين لكل رسم متحرك، وما يعنيه ذلك من منظور Paxis، السحابة الأصيلة للوكلاء من ThakiCloud، وحزمة المهارات Skill Harness فيها."
seo_title: "video-use: تحرير الفيديو بوكيل برمجي - Thaki Cloud"
seo_description: "مهارة video-use مفتوحة المصدر من browser-use تؤتمت القص وإزالة الحشو والترجمة وتدرّج الألوان والرسوم المتحركة والإخراج انطلاقاً من مجلد لقطات وجملة واحدة. نحلل تصميم الوكلاء الفرعيين المتوازيين ومحركات HyperFrames/Remotion/Manim/PIL، ونربطها بحزمة المهارات في Paxis من ThakiCloud."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - ai-coding
  - claude-code
  - agent-skills
  - video-editing
  - browser-use
  - agent-orchestration
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "film"
canonical_url: "https://thakicloud.com/tech-blog/ar/technique/video-use-coding-agent-video-editor/"
categories:
  - tutorials
---

## نظرة عامة

ظل تحرير الفيديو لوقت طويل مجالاً للعمل اليدوي، حيث يقصّ الإنسان المقاطع ويجمعها على الخط الزمني. إنهاء فيديو واحد كان يتطلب أدوات متخصصة ويداً مدربة للقص وإزالة الكلام الزائد وإضافة الترجمات وتدرّج الألوان والرسوم المتحركة. ثم في يونيو 2026، انتشرت بسرعة بين المطورين تغريدة من سطر واحد للمطور الإسباني المؤثر midudev: «بات بإمكان Claude Code تحرير الفيديو أيضاً. هذه المهارة مجانية بنسبة 100% ومفتوحة المصدر».

بطل الضجة هو `video-use` الذي أصدره فريق browser-use. الفريق نفسه المعروف بـ browser-use الذي يقود متصفحاً عبر وكيل برمجي، يقدّم الآن مهارة تسلّم تحرير الفيديو بالكامل إلى وكيل برمجي. الاستخدام بسيط. تضع ملفات الفيديو الخام في مجلد، وتكتب جملة واحدة تصف الفيديو الذي تريده، ويتولى الوكيل الباقي.

تعمل ThakiCloud على تحويل البنية التي يختار فيها الوكيل المهارات ويشغّلها داخل بيئة معزولة إلى منتج باسم السحابة الأصيلة للوكلاء. لذلك قرأنا video-use لا كأداة تحرير فحسب، بل كدراسة حالة لكيفية تفكيك الوكيل البرمجي للأعمال غير البرمجية وتوزيعها على التوازي. يوثّق هذا المقال ما تفعله video-use فعلاً، وكيف يبدو هيكلها الداخلي، وما الذي يوحي به تصميمها من منظور منصتنا.

## ما هذه التقنية

الفكرة الجوهرية لـ video-use هي اختزال تحرير الفيديو إلى أمر واحد بلغة طبيعية. لا يلمس المستخدم الخط الزمني مباشرة. بدلاً من ذلك، يصف النتيجة المرجوة في جملة، ويفكّك الوكيل تلك الجملة إلى عدة إجراءات تحرير ملموسة.

وفقاً للوصف المنشور، تتولى video-use تلقائياً ما يلي.

- قص المقاطع غير الضرورية من اللقطات الخام
- إزالة كلمات الحشو تلقائياً مثل «أم» و«آه»
- التعرّف على الكلام لتوليد الترجمات ودمجها في الفيديو
- تطبيق تدرّج الألوان لتوحيد النغمة
- إضافة طبقات رسوم متحركة عند النقاط التي تحتاج إلى تأكيد
- إخراج كل ما سبق في ملف MP4 نهائي واحد

الجزء المثير هو كيفية التعامل مع الرسوم المتحركة. عند إنشاء طبقات الرسوم المتحركة، لا ترتبط video-use بمحرك واحد، بل تختار من بين HyperFrames وRemotion وManim وPIL حسب طبيعة المهمة. والأهم أنها تطلق وكيلاً فرعياً منفصلاً على التوازي لكل رسم متحرك تنشئه. وكيل واحد لكل رسم متحرك.

يختلف هذا التصميم جوهرياً عن النهج الشائع المتمثل في «توليد فيديو بمطالبة عملاقة واحدة». فهو يقسّم المهمة الكبيرة لتحرير الفيديو إلى مهام فرعية مستقلة مثل القص والترجمات وتدرّج الألوان والرسوم المتحركة، ويشغّل غير المترابطة منها على التوازي، ثم يجمعها أخيراً في خط زمني واحد. ويبدو المسار الكامل كالتالي.

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
<div class="d3-arch" data-arch-root id="secodingagentvideoeditor-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1278, "height": 754, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 714, "y": 24, "w": 163, "h": 62, "title": ["مجلد الفيديو الأصلي", "+ تعليمة جملة واحدة"]}, {"id": "B", "x": 714, "y": 164, "w": 163, "h": 46, "title": "العامل: تفكيك النية"}, {"id": "C", "x": 1125, "y": 412, "w": 121, "h": 62, "title": ["تحرير القص", "تحديد الأقسام"]}, {"id": "D", "x": 921, "y": 412, "w": 149, "h": 62, "title": ["حذف الكلمات الحشو", "تحليل الصوت"]}, {"id": "E", "x": 724, "y": 412, "w": 142, "h": 62, "title": ["توليد الترجمات", "التعرف على الصوت"]}, {"id": "F", "x": 549, "y": 412, "w": 120, "h": 62, "title": ["تدرج الألوان", "توحيد النبرة"]}, {"id": "G", "x": 171, "y": 288, "w": 177, "h": 46, "title": "تراكب الرسوم المتحركة"}, {"id": "G1", "x": 374, "y": 412, "w": 120, "h": 62, "title": ["عامل فرعي 1", "HyperFrames"]}, {"id": "G2", "x": 199, "y": 412, "w": 120, "h": 62, "title": ["عامل فرعي 2", "Remotion"]}, {"id": "G3", "x": 24, "y": 412, "w": 120, "h": 62, "title": ["عامل فرعي 3", "Manim / PIL"]}, {"id": "H", "x": 535, "y": 552, "w": 149, "h": 46, "title": "تجميع الخط الزمني"}, {"id": "I", "x": 535, "y": 676, "w": 149, "h": 46, "title": "إخراج MP4 النهائي"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [795, 86, 795, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[877, 200], [1186, 249], [1186, 373], [1186, 412]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[869, 210], [996, 249], [996, 373], [996, 412]]}, {"src": "B", "dst": "E", "kind": "data", "line": [795, 210, 795, 412]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[726, 210], [609, 249], [609, 373], [609, 412]]}, {"src": "B", "dst": "G", "kind": "data", "curve": [[714, 196], [259, 249], [259, 249], [259, 288]]}, {"src": "G", "dst": "G1", "kind": "data", "curve": [[324, 334], [434, 373], [434, 373], [434, 412]]}, {"src": "G", "dst": "G2", "kind": "data", "line": [259, 334, 259, 412]}, {"src": "G", "dst": "G3", "kind": "data", "curve": [[194, 334], [84, 373], [84, 373], [84, 412]]}, {"src": "C", "dst": "H", "kind": "data", "curve": [[1186, 474], [1186, 513], [1186, 513], [684, 567]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[996, 474], [996, 513], [996, 513], [684, 563]]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[795, 474], [795, 513], [795, 513], [678, 552]]}, {"src": "F", "dst": "H", "kind": "data", "line": [609, 474, 609, 552]}, {"src": "G1", "dst": "H", "kind": "data", "curve": [[434, 474], [434, 513], [434, 513], [544, 552]]}, {"src": "G2", "dst": "H", "kind": "data", "curve": [[259, 474], [259, 513], [259, 513], [535, 562]]}, {"src": "G3", "dst": "H", "kind": "data", "curve": [[84, 474], [84, 513], [84, 513], [535, 566]]}, {"src": "H", "dst": "I", "kind": "data", "line": [609, 598, 609, 676]}]});
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
      const container = document.getElementById('secodingagentvideoeditor-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'secodingagentvideoeditor-1';
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

*كيف تفكّك video-use التحرير إلى قص وترجمات وتدرّج ألوان ورسوم متحركة، وتطلق وكيلاً فرعياً لكل رسم متحرك على التوازي، ثم تدمجها في خط زمني واحد. (تسميات الرسم بالكورية، مشتركة عبر اللغات.)*

كما يوضح الرسم، لا تكون كتلة الرسوم المتحركة عقدة واحدة بل تتفرّع إلى عدة وكلاء فرعيين. كل وكيل فرعي مسؤول فقط عن الرسم المتحرك المسند إليه ولا يرى النتائج الوسيطة للآخرين. مع هذا الفصل، سواء كان هناك ثلاثة رسوم متحركة أو خمسة، يمكنها أن تسير في آن واحد، ويتقارب إجمالي الوقت الفعلي إلى مدة أطول رسم متحرك منفرد.

## التثبيت والتكامل

تُشحن video-use كمهارة تعمل فوق وكيل برمجي. يمكنك الحصول عليها من المستودع العام لفريق browser-use (‏`browser-use/video-use`)، وتماشياً مع وصفها من سطر واحد، «Edit videos with coding agents»، يكون الوكيل البرمجي هو المضيف. المسار النموذجي هو جلب المستودع، ووضع المهارة حيث يستطيع الوكيل التعرّف عليها، وإسقاط اللقطات الخام في مجلد عمل، وتوجيه الوكيل بجملة واحدة.

لكل محرك رسوم متحركة طابعه المختلف. Remotion إطار لبرمجة الفيديو بواسطة React، قوي في الرسوم المتحركة القائمة على المكوّنات؛ وManim مكتبة بايثون متخصصة في تحريك المعادلات والأشكال؛ وPIL يتولى التركيب الخفيف للصور؛ وHyperFrames يُستخدم لتوليد التسلسلات إطاراً بإطار. ولأن video-use لا تثبّت على محرك واحد بل تختار المناسب لكل مهمة، تحتاج البيئة إلى أوقات التشغيل التي تتطلبها هذه المحركات (Node وPython وffmpeg وغيرها).

> ملاحظة صادقة حول نطاق إعادة الإنتاج: البيئة التي كُتب فيها هذا المقال معزولة وذات شبكة خارجية وتثبيت تبعيات مقيّدين، لذا لم نتمكن من تشغيل خط الأنابيب الكامل مع أصول فيديو خام وتبعيات إخراج ثقيلة (Remotion وManim وffmpeg) لقياس زمن الإخراج أو أرقام الجودة مباشرة. لذلك يستند التحليل هنا إلى وصف المهارة المنشور وبنيتها، ولا ندرج أي أرقام مرجعية لم نقسها.

## ماذا يعني السلوك فعلاً

رغم أننا لم نشغّل الإخراج الكامل بأنفسنا، فإن مواصفات السلوك المنشورة وحدها توضّح ما تهدف إليه هذه المهارة. أكبر تحوّل هو أن وحدة التحرير تصبح النيّة بدلاً من المقاطع.

في أداة تحرير تقليدية، يفكّر المستخدم بوحدات الإجراء: «اقصص من الثانية 3 إلى 7، وأضف تلاشياً هناك، وألصق ترجمة». في video-use، يفكّر المستخدم بوحدات النتيجة: «خذ هذا الفيديو التقديمي، ونظّفه، واصنع مقطعاً من دقيقة واحدة مع ترجمات ورسوم متحركة للتأكيد». والتحويل بين الاثنين، أي تفكيك النيّة إلى عشرات الإجراءات، هو ما يتولاه الوكيل.

التحوّل الثاني هو التوازي. يبدو تحرير الفيديو متسلسلاً بطبيعته، لكنه في الواقع يحتوي على مهام فرعية مستقلة كثيرة. توليد الترجمات لا علاقة له بتدرّج الألوان، ورسم المشهد الثاني المتحرك لا علاقة له برسم الأول. إطلاق video-use وكيلاً فرعياً لكل رسم متحرك تصميم يستغل هذا الاستقلال بنشاط لتقليل الوقت الفعلي. إنها الفكرة نفسها التي تؤكد عليها ThakiCloud دائماً في تنسيق الوكلاء المتعددين: شغّل المهام غير المترابطة على التوازي.

## دلالات على منتجات ThakiCloud

تعالج video-use مجال الفيديو غير البرمجي، لكن مبادئ تصميمها تلامس جوهر **Paxis** الذي تحوّله ThakiCloud إلى منتج بوصفه سحابة أصيلة للوكلاء. Paxis مستوى تحكّم للوكلاء يعمل فوق ai-platform، يتعامل مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. وعند إسقاط بنية video-use على طبقات Paxis تظهر ثلاثة أمور.

أولاً، **منظور حزمة المهارات Skill Harness**. video-use هي بذاتها مهارة واحدة، وتختار داخلياً من بين عدة أدوات فرعية (HyperFrames وRemotion وManim وPIL) حسب الموقف. تختار حزمة المهارات في Paxis من أكثر من 960 مهارة عبر BM25 وتحمّل فقط المناسب منها إلى السياق؛ وطريقة video-use في اختيار محرك لكل مهمة رسم متحرك مثال صغير على المبدأ نفسه: «حمّل ما تحتاجه فقط». كما يتوافق ذلك مع خبرتنا في أن ملء هيكل مُتحقَّق منه بتصميم حر يرفع متوسط الجودة.

ثانياً، **منظور التنفيذ المعزول في صندوق الرمل**. يجلب إخراج الفيديو تبعيات ثقيلة مثل ffmpeg وNode وPython، وقد يلوّث بيئة المضيف إن لم يُحسَن التعامل. تعالج Paxis كل تنفيذ مهارة في صندوق رمل معزول لحماية شجرة العمل الرئيسية. وكلما استدعت مهارة عدة أوقات تشغيل خارجية، كما تفعل video-use، صار هذا العزل ضرورة لا خياراً. حين يشغّل وكلاء فرعيون متوازون محركاً مختلفاً لكل منهم، تحتاج إلى حدّ يمنع تصادم ملفاتهم المؤقتة وعملياتهم لتعمل الأمور بثبات.

ثالثاً، **منظور تنسيق الوكلاء المتعددين بصيغة DAG**. مسار video-use هو في الواقع رسم بياني موجّه لا دوري (DAG). تتفرّع عقد القص والترجمة وتدرّج الألوان والرسوم المتحركة على التوازي ثم تتقارب من جديد عند عقدة تجميع الخط الزمني. تعبّر Paxis عن هذا التفرّع والتجمّع كدرجة أولى، وتمرّر تنفيذ كل عقدة عبر بوابات السياسة وسجلات التدقيق. ولأن مَن استدعى أي أداة ومتى مسجّل بالكامل، يمكنك تتبّع كيف أُنتجت النتيجة.

باختصار، video-use عرض واحد لوكيل برمجي يفكّك الأعمال غير البرمجية ويوزّعها على التوازي، وPaxis هو مستوى التحكّم الذي يشغّل مثل هذه الأنماط بأمان وقابلية للتتبّع. سواء كان تحرير فيديو أو خط أنابيب بيانات، فالهيكل واحد: غلّف العمل كمهارة، وشغّله على التوازي داخل صندوق رمل معزول، واترك كل إجراء في سجل تدقيق.

## القيود والاعتراضات

هذا النهج ليس علاجاً لكل شيء. أولاً، لأن حكم الوكيل يدخل في مرحلة تفكيك النيّة إلى إجراءات، قد يتباعد المخرج عمّا تصوّره المستخدم. «نظّفه» تعني أشياء مختلفة لأشخاص مختلفين، وقد يكون المقطع الذي قصّه الوكيل هو الأساسي فعلاً. في النهاية، بدلاً من الانتهاء بجملة واحدة، ستتبادل على الأرجح عدة جولات من تعليمات التعديل.

ثانياً، الكلفة والوقت. إطلاق وكيل فرعي لكل رسم متحرك يقلّل الوقت الفعلي عبر التوازي، لكن على حساب استهلاك حوسبة أكبر بقدر عدد الوكلاء وعمليات الإخراج التي تعمل في آن واحد. لصقل مقطع قصير واحد، قد يكون تصميماً مفرطاً في الهندسة. تشغيل مهمة عبر تنسيق الوكلاء بينما ينهيها محرّر تقليدي في خمس دقائق ليس مكسباً دائماً.

ثالثاً، غياب الحتمية. حتى مع المصدر نفسه والتعليمة نفسها، لا ضمان أن تخرج النتيجة نفسها في كل مرة. القابلية لإعادة الإنتاج مهمة في الإنتاج الاحترافي للفيديو، والتحرير القائم على الوكلاء لا يزال يحتاج إلى تحقّق هنا. ولهذا تؤكد ThakiCloud مبدأ أن «التنسيق والتجميع تملكهما الشيفرة الحتمية بينما يولّد النموذج المحتوى فقط» في المخرجات الدفعية. حتى لو تركت التحرير الإبداعي للنموذج، يبقى النهج الهجين الذي تضمن فيه الشيفرة الأجزاء الحتمية مثل توقيت الترجمة ومواصفات المخرج هو التسوية الواقعية.

ومع ذلك، الاتجاه الذي تبرهنه video-use واضح. نمط تغليف المهام المعقدة في المجالات غير البرمجية كمهارات، وتفكيك المهام الفرعية المستقلة إلى وكلاء متوازين، واستخدام النيّة باللغة الطبيعية كنقطة دخول، سينتشر إلى مجالات أكثر. وما تبنيه ThakiCloud بـ Paxis هو بالضبط الأساس لتشغيل ذلك النمط بأمان.

## المصادر

- [browser-use/video-use (GitHub)](https://github.com/browser-use/video-use): "Edit videos with coding agents"
- [تغريدة ‎@midudev](https://x.com/midudev): تعريف بمهارة video-use (2026-06-27)
- [video-use: Edit Videos with Claude Code (AIBit)](https://aibit.im/en/article/video-use-edit-videos-with-claude-code)
