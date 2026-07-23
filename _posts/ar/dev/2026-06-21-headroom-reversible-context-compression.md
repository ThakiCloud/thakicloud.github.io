---
title: "خفض تكلفة الرموز بنسبة 34-71% عبر الضغط القابل للعكس: تقرير ميداني عن Headroom ونظافة السياق في ThakiCloud"
excerpt: "أكبر تكلفة خفية لوكيل البرمجة بالذكاء الاصطناعي هي السياق. شغّلنا Headroom (headroom-ai) مباشرةً على ثلاثة مخرجات أدوات JSON حقيقية من مستودع ThakiCloud وقِسنا خفض الرموز. نوضّح كيف خفض SmartCrusher الرموز بنسبة تصل إلى 71.2% بضغط قابل للعكس وبلا فقدان، من أمر التثبيت حتى الأرقام المقاسة."
seo_title: "تقرير ميداني عن الضغط القابل للعكس Headroom - Thaki Cloud"
seo_description: "قياس ضغط JSON القابل للعكس عبر SmartCrusher من Headroom (headroom-ai) على بيانات مستودع حقيقية (خفض رموز 34-71%)، أوامر التثبيت والدمج، وتحليل تكلفة الرموز ونظافة السياق في تقديم نماذج LLM على K8s"
date: 2026-06-21
last_modified_at: 2026-06-21
tags: [headroom, context-compression, token-cost, llm-serving, rag, mcp]
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/headroom-reversible-context-compression/"
reading_time: true
categories:
  - dev
published: false
---

![صورة تجريدية لتكثّف البيانات]({{ '/assets/images/headroom-reversible-context-compression-hero.webp' | relative_url }})
*السياق ليس مجانيًا. تكثيف الرموز المبعثرة بلا فقدان هو ما يفعله Headroom.*

## نظرة عامة

أي فريق يشغّل وكلاء برمجة بالذكاء الاصطناعي يوميًا يعرف من أين تأتي أكبر تكلفة خفية. إنها السياق. تتراكم مخرجات الأدوات ونتائج RAG والسجلات والملفات وتاريخ المحادثة في كل دور، وتتحول تلك الرموز إلى الفاتورة. في سير العمل متعدد الوكلاء تنمو هذه التكلفة لا خطيًا بل تضاعفيًا، لأنه في كل مرة يُسقط فيها وكيل فرعي مخرَج JSON كبيرًا في السياق، تنمو رموز قراءة الذاكرة المؤقتة معه.

هذه المقالة ليست مجرد تعريف بأداة. تشغّل ThakiCloud بالفعل Headroom ضمن سلسلة أدواتها الإنتاجية، وهذه المرة سحبنا ثلاثة مخرجات أدوات JSON حقيقية من مستودعنا وشغّلنا Headroom عليها مباشرةً. نوثّق أمر التثبيت وكود الدمج والأرقام المقاسة لخفض الرموز بصيغة قابلة لإعادة الإنتاج. الخلاصة المختصرة: كلما زاد التكرار في بنية JSON زاد التوفير، وعلى بياناتنا بلغ خفض الرموز 71.2%. كل رقم قِيس في بيئة معزولة حقيقية دون خلط أي تقديرات.

## ما هو Headroom

Headroom (اسم الحزمة على PyPI هو `headroom-ai`، وعلى GitHub `chopratejas/headroom`) أداة ضغط سياق فتح مصدرها المهندس السابق في Netflix، Tejas Chopra. هدفها المعلن واضح: ضغط مخرجات الأدوات والسجلات والملفات وأجزاء RAG قبل وصولها إلى نموذج LLM، لخفض الرموز مع الإبقاء على الإجابة كما هي.

معظم أدوات تقليل السياق الحالية غير قابلة للعكس. بمجرد القطع لا يمكنك استعادة الأصل. ميزة Headroom الجوهرية أنها تعمل محليًا وتغطي أنواع محتوى متعددة وقابلة للعكس. يمكن استعادة الأصل ضمن مدة صلاحية (TTL) محددة عبر تجزئات تتبّع. هذا يمنع بنيويًا الفشل التقليدي: "ضغطنا فضاع التفصيل لدى الوكيل." يمكنك العمل على النسخة المضغوطة افتراضيًا واستعادة الأصل فقط عند الحاجة لقسم محدد.

هناك ثلاث طرق للربط: كمكتبة تستدعيها مباشرة، أو كوكيل (proxy)، أو كخادم MCP. تتعرف على نوع المحتوى وتضغط انتقائيًا، فتبقي على القيم الشاذة فقط في JSON أو على أسطر الفشل فقط في السجلات.

### البنية الداخلية: SmartCrusher هو الجوهر

يوجّه Headroom إلى ضاغط مختلف لكل نوع محتوى. في هذه التجربة ظهرت التحويلات الفعلية في سجل الموجّه على هيئة `router:protected:user_message` و`router:mixed:...`، أي أنه يحمي رسالة المستخدم ويضغط فقط حمولة JSON في رسائل الأدوات.

- **SmartCrusher**: ضاغط JSON عام يتعامل مع مصفوفات القواميس والكائنات المتداخلة والأنواع المختلطة. لمخرجات أدوات JSON المتكررة (نتائج البحث، صفوف السجلات، قوائم السجلات) يطوي المفاتيح المكررة ويستنتج المخطط ليختصر بشكل حتمي. وقد تحمّل معظم التوفير في قياسنا.
- **ضاغط الكود**: ضغط شيفرة المصدر بوعي بنيوي.
- **ضغط الصور**: حمولات الصور تُختصر أيضًا.

المخطط أدناه هو تدفق البيانات الذي رصدناه. يمر مخرج الأداة عبر الموجّه إلى SmartCrusher، وبينما يذهب السياق المضغوط إلى استدعاء LLM، يُحفظ الأصل منفصلًا للاستعادة القابلة للعكس عند الحاجة.

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
<div class="d3-arch" data-arch-root id="rsiblecontextcompression-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 755, "height": 820, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 192, "y": 24, "w": 120, "h": 62, "title": ["مخرج الأداة", "Tool Output"]}, {"id": "B", "x": 369, "y": 164, "w": 163, "h": 62, "title": ["موجّه نوع المحتوى", "Content-Type Router"]}, {"id": "C", "x": 367, "y": 304, "w": 167, "h": 52, "title": "تفريع نوع المحتوى"}, {"id": "D", "x": 570, "y": 448, "w": 121, "h": 62, "title": ["SmartCrusher", "ضغط JSON حتمي"]}, {"id": "E", "x": 380, "y": 448, "w": 135, "h": 62, "title": ["ضاغط الكود", "Code Compressor"]}, {"id": "F", "x": 183, "y": 448, "w": 142, "h": 62, "title": ["ضاغط الصور", "Image Compressor"]}, {"id": "G", "x": 369, "y": 588, "w": 156, "h": 62, "title": ["السياق المضغوط", "Compressed Context"]}, {"id": "H", "x": 192, "y": 742, "w": 120, "h": 46, "title": "استدعاء LLM"}, {"id": "I", "x": 30, "y": 588, "w": 142, "h": 62, "title": ["مستودع الأصل", "Reversible Store"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[312, 76], [451, 125], [451, 125], [451, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [451, 226, 451, 304]}, {"src": "C", "dst": "D", "kind": "data", "label": "مصفوفات JSON / كائنات متداخلة", "curve": [[516, 356], [630, 402], [630, 402], [630, 448]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "شيفرة المصدر", "line": [449, 356, 447, 448], "lx": 447, "ly": 398}, {"src": "C", "dst": "F", "kind": "data", "label": "الصور", "curve": [[380, 356], [254, 402], [254, 402], [254, 448]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[630, 510], [630, 549], [630, 549], [525, 589]]}, {"src": "E", "dst": "G", "kind": "data", "line": [447, 510, 447, 588]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[254, 510], [254, 549], [254, 549], [369, 591]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[447, 650], [447, 696], [447, 696], [312, 744]]}, {"src": "A", "dst": "I", "kind": "event", "label": "تجزئة تتبّع + مدة صلاحية", "curve": [[192, 83], [101, 265], [101, 479], [101, 588]], "off": "50%"}, {"src": "I", "dst": "H", "kind": "event", "label": "استعادة قابلة للعكس", "curve": [[101, 650], [101, 696], [101, 696], [201, 742]], "off": "50%"}]});
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
      const container = document.getElementById('rsiblecontextcompression-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rsiblecontextcompression-1';
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
*تدفق بيانات Headroom: يمر مخرج الأداة عبر موجّه نوع المحتوى، يُضغط بواسطة SmartCrusher، ثم يُرسل إلى LLM — بينما يُحفظ الأصل في مستودع قابل للعكس بمدة صلاحية محددة. انقر المخطط لتكبيره.*

## التثبيت والدمج

وقت تشغيل Python لدينا موحّد في مفسّر واحد (3.12.8) داخل `.venv`. التثبيت سطر واحد.

```bash
VIRTUAL_ENV="$PWD/.venv" uv pip install "headroom-ai[code,relevance]"
```

تُفعّل الإضافة `[code,relevance]` الضغط الواعي ببنية الكود والترشيح المبني على الصلة. الضغط الدلالي للنص العادي يحتاج نموذجًا إضافيًا (نحو 261 ميجابايت)، لكن مسار JSON الأعلى تأثيرًا يعمل بهذا التثبيت الأساسي وحده.

أبسط دمج هو تمرير قائمة رسائل مباشرة. جوهر الغلاف الذي نستخدمه فعليًا (`scripts/headroom_compress.py`) أدناه. ضع مخرج الأداة محتوى لرسالة بدور `tool` واستدعِ `compress`.

```python
from headroom import compress

messages = [
    {"role": "user", "content": "Summarize this tool output"},
    {"role": "assistant", "content": None,
     "tool_calls": [{"id": "c1", "type": "function",
                     "function": {"name": "tool", "arguments": "{}"}}]},
    {"role": "tool", "tool_call_id": "c1", "content": raw_json_string},
]

result = compress(messages, model="claude-sonnet-4-5-20250929")
compressed = result.messages[-1]["content"]
print(result.tokens_before, "->", result.tokens_after, result.transforms_applied)
```

يحمل الكائن الذي يعيده `compress` الحقول `tokens_before` و`tokens_after` و`transforms_applied`، فيتحقق الكود لاحقًا مما فعله الضغط فعليًا. الجوهر أن هذه قيم قاستها المكتبة لا أرقام أبلغ عنها النموذج ذاتيًا. وفوق ذلك تحققنا مرة أخرى بمُرمِّز منفصل (tiktoken).

## نتائج التجربة الفعلية

جرت التجربة في بيئة معزولة عبر git worktree. لا تمس هذه البنية شجرة العمل الرئيسية وتبقي النتائج فقط في دليل أدلة. بيانات الاختبار ثلاثة من مخرجات مستودعنا الحقيقية ذات بنية JSON متكررة بوضوح.

1. **skill_index.json**: فهرس BM25 لبحث المهارات. تتكرر سجلات بمخطط متطابق على نطاق واسع.
2. **seedance-prompts/raw-prompts.json**: كتالوج من 605 موجّهات. نص اللغة الطبيعية هو الحصة الغالبة.
3. **أرشيف خط زمني twitter**: 1385 سجلًا زمنيًا. مصفوفة كائنات ببنية مفاتيح متطابقة.

قِيست أعداد الرموز بمُرمِّز `cl100k_base`. سجّلنا البايتات والرموز معًا لأن الضغط يُحكم عليه لا بتوفير البايتات الخام بل بمقدار فائدته في وحدة الفوترة الفعلية، أي الرمز. النتائج أدناه.

| بيانات الاختبار | الرموز الأصلية | الرموز بعد الضغط | خفض الرموز | خفض البايتات | الزمن |
|---|---|---|---|---|---|
| skill_index (فهرس BM25) | 1,618,287 | 465,445 | **71.2%** | 64.9% | 2.08s |
| twitter-timeline (مصفوفة سجلات) | 399,926 | 192,465 | **51.9%** | 57.0% | 0.24s |
| seedance-prompts (كتالوج موجّهات) | 1,085,592 | 713,210 | **34.3%** | 38.5% | 0.57s |

![مخطط الضغط المقاس]({{ '/assets/images/headroom-reversible-context-compression-results.webp' | relative_url }})
*نسب الخفض المقاسة لثلاثة مخرجات أدوات JSON من مستودع ThakiCloud. البايتات والرموز معروضة معًا.*

طريقة قراءة الأرقام مهمة. **كلما زاد تكرار البنية زاد التوفير.** skill_index فهرس لسجلات متطابقة المخطط مكتظة، فبلغ طي المفاتيح في SmartCrusher ذروته وخفض الرموز 71.2% كاملة. وخط twitter الزمني، وهو أيضًا مصفوفة كائنات منتظمة، اختُصر بأكثر من النصف. في المقابل seedance-prompts، حيث يشكّل نص الموجّهات الطبيعي معظم كل سجل، لم يكن أمامه إلا مجال ضيق للاختصار البنيوي فاستقر عند 34.3%. هذا الفرق يبرهن مباشرةً على نية التصميم بأن "JSON هو حيث يعمل أفضل ما يكون."

التوقيت جدير بالملاحظة أيضًا. عالج فهرسًا من 1.6 مليون رمز في ثانيتين، والبقية في أقل من ثانية. هذا سريع بما يكفي لإدراجه قبل دخول مخرج الأداة إلى السياق مباشرةً دون تأخّر محسوس تقريبًا. ولأن الضغط حتمي، يعطي المدخل نفسه دائمًا المخرج نفسه، وهو أيضًا صديق للذاكرة المؤقتة.

تنويه أمين واحد. الأرقام أعلاه قياسات لتشغيل مفرد على ثلاث مجموعات بيانات. على أنواع JSON أخرى، خاصةً البيانات ذات القيم الفريدة غالبًا والمفاتيح المكررة القليلة، قد يكون الخفض أقل. ومع ذلك، ضمن نطاق قياسنا، يُعد مدى خفض رموز من 34 إلى 71% نتيجة ذات معنى واضح، على الأقل لمخرجات الأدوات ذات البنية المتكررة.

## التطبيق على منصة ThakiCloud لخدمات AI/ML على K8s

النقطة التي اعتمدنا فيها Headroom هي بالضبط ما تُظهره التجربة أعلاه: **مخرجات أدوات JSON الكبيرة ذات البنية المتكررة.** قاعدة نظافة السياق لدينا (`ecc-token-strategy`) تنص على ذلك: مخرجات مصفوفات JSON المتكررة تُضغط حتميًا بـ SmartCrusher قبل دخول السياق، والنص العادي ليس هدفًا بل JSON هو الهدف، والأولوية تلخيص الوكيل الفرعي أولًا ثم ضغط headroom.

سبب أهمية هذا الشديدة في تنسيق وكلاء متعدد على K8s هو بنية التكلفة. في سير عمل تعمل فيه وكلاء فرعيون كثر، تعني نظافة السياق ثلاثة أمور دفعة واحدة. الأول التحكم في تكلفة الرموز. الثاني إدارة معدل إصابة الذاكرة المؤقتة؛ فالضغط الحتمي يضمن مخرجًا متطابقًا لمدخل متطابق فلا يكسر ذاكرة الموجّهات المؤقتة. الثالث إدارة زمن الاستجابة؛ فكلما صغر السياق أسرع النموذج في الرد.

تجدول خدمة LLM لدينا أعباء GPU عبر Kueue فوق K8s، وتتدفق طلبات استدلال كثيرة بالتوازي. في هذه البيئة، السياق المتضخم يكلّف أكثر من طلب واحد؛ فهو يلتهم الإنتاجية الكلية. يتيح Headroom إدراج هذه الطبقة دون أي تغيير في الكود تقريبًا. نضغط مصفوفة نتائج بحث أو سجلات بسطر واحد قبل دخولها السياق مباشرةً، ونستعيد بشكل قابل للعكس فقط عند الحاجة لقسم محدد.

وهو عملي من منظور عالِم البيانات أيضًا. في مسار RAG حيث تأتي الأجزاء المسترجعة محمّلة ببيانات وصفية متكررة (مفاتيح متطابقة مثل عنوان المصدر والطابع الزمني والدرجة)، فإن تلك البيانات الوصفية هي تحديدًا المنطقة التي يختصرها SmartCrusher أفضل اختصار. ولأنه يحفظ المتن ويختصر العبء البنيوي فقط، تؤمّن ميزانية سياق دون التضحية بدقة الاسترجاع.

## القيود والاعتراضات

لا نوصي بهذه الأداة دون نقد. إليك القيود والاعتراضات بأمانة.

**أولًا، التنفيذ المحلي شرط مسبق.** يحتاج Headroom إلى تشغيل عملية محلية، فلا يصلح في بيئات تنفيذ معزولة بالكامل. هناك أشكال نشر لا يلائمها هذا القيد.

**ثانيًا، التأثير على النص العادي محدود.** كما تُظهر نتيجة seedance-prompts، فالبيانات ذات الحصة العالية من نص اللغة الطبيعية أمامها مجال ضيق للاختصار البنيوي. اختصار النص العادي دلاليًا يتطلب نموذجًا إضافيًا، وذلك المسار يتنازل عن بعض الحتمية والسرعة.

**ثالثًا، قد يكون مبالغًا فيه للفرق ذات المزوّد الواحد.** إن كفى ضغط المزوّد الأصلي لنموذج واحد ولم تحتج ذاكرة عبر الوكلاء، فقد يفوق عبء تشغيل طبقة ضغط منفصلة المكسب.

**رابعًا، أقوى اعتراض هو "ألا يكفي التلخيص بوكيل فرعي؟"** في الواقع قاعدتنا نفسها تقدّم تلخيص الوكيل الفرعي على ضغط headroom. التلخيص غير قابل للعكس لكنه يختصر أكثر بكثير ويضغط بالمعنى. فأين يقع Headroom إذن؟ الجواب "حين يفقد التلخيص تفاصيل قد تُحتاج لاحقًا." القابلية للعكس تسد هذه الفجوة تحديدًا. تعمل على النسخة المضغوطة عادةً، وفي لحظة احتياجك لأصل سجل محدد، تستعيده بدقة ضمن مدة الصلاحية. التلخيص والضغط ليسا متنافسين بل متكاملين.

باختصار، يجسّد Headroom مبدأ "السياق ليس مجانيًا" بتصميم ملموس هو الضغط القابل للعكس. ضمن نطاق قياسنا خفض الرموز 34-71% على JSON المتكرر البنية، وبفضل الحتمية والقابلية للعكس لم يكسر الذاكرة المؤقتة ولم يفقد التفاصيل. إن كنت مهندسًا يهتم بكيفية تعامل ThakiCloud مع نظافة السياق كمشكلة تكلفة وموثوقية، فنحن المكان الذي يشغّل هذه الطبقة في الإنتاج.

---

المصادر: Headroom (headroom-ai)، PyPI https://pypi.org/project/headroom-ai/ · GitHub https://github.com/chopratejas/headroom (المؤلف Tejas Chopra). الأرقام في هذه المقالة مقاسة مباشرةً على بيانات مستودع ThakiCloud.
