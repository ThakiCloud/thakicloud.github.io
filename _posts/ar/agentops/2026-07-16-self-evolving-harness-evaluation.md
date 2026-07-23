---
title: "قد تكون مكاسب الأداة ذاتية التطور وهمية: الفصل بين تحديث الأداة والاستفادة منها"
seo_title: "إعادة النظر في تقييم أداة الوكيل ذاتية التطور - الفصل بين التحديث والاستفادة - Thaki Cloud"
seo_description: "التحسّن الذي تُنسب إليه أدوات الوكلاء ذاتية التطور مزيج بين قدرتين مختلفتين تمامًا. حين نفصل بين القدرة على تحديث الأداة والقدرة على الاستفادة من أداة محدَّثة، تتضح حقيقة مفاجئة: جودة التحديث تكاد تكون ثابتة بصرف النظر عن فئة النموذج، بينما الاستفادة الفعلية تبلغ ذروتها عند النماذج متوسطة القدرة. نستعرض هنا نتائج الورقة البحثية arXiv 2605.30621 ونحدد ما يمكن نقله إلى حلقة التطور الذاتي للمهارات في Paxis من ThakiCloud، حيث تُعامَل المهارات كموارد من الدرجة الأولى."
excerpt: "المكاسب المنسوبة إلى الأدوات ذاتية التطور هي في الحقيقة مزيج بين 'القدرة على إنتاج تحديثات جيدة' و'القدرة على استخدام تلك التحديثات جيدًا'، متشابكتان داخل حلقة واحدة. حين نفصل بينهما، ينقلب السؤال حول أين ينبغي إنفاق ميزانية القدرة."
date: 2026-07-16
tags:
  - self-evolving-agents
  - agent-harness
  - evaluation
  - skill-library
  - llm-agents
  - agentops
  - paxis
  - benchmarking
categories:
  - agentops
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/self-evolving-harness-evaluation/"
---

كل من شغّل وكلاء ذكاء اصطناعي لفترة طويلة رأى على الأرجح رسمًا بيانيًا كهذا: وكيل يعدّل موجّهاته ومهاراته وذاكرته باستمرار، ودرجة الأداء على معيار القياس ترتفع، فيخلص الفريق إلى أن "الأداة ذاتية التطور تعمل". لكن دراسة نُشرت مؤخرًا تشير إلى أن جزءًا كبيرًا من ذلك الرسم البياني قد يكون وهمًا. فحتى الآن، لم تكن طرق التقييم قادرة على التمييز بين ما إذا كان الارتفاع في الدرجة ناتجًا فعلًا عن أداة أفضل، أو ببساطة عن نموذج كان أصلًا جيدًا في اتباع التعليمات. هذا المقال موجّه إلى مهندسي التعلم الآلي والمنصات الذين يشغّلون وكلاء ويطوّرون مكتبات المهارات والأدوات في بيئة إنتاجية. والخلاصة مقدَّمًا: رد الفعل المعتاد بقول "لنرفع فئة النموذج" كلما تعثّر الأداء، يتبيّن أنه صحيح بنصفه فقط في ضوء بيانات هذه الدراسة.

## نظرة عامة

عنوان الورقة البحثية هو "Harness Updating Is Not Harness Benefit"، أي أن تحديث الأداة والاستفادة منها أمران مختلفان. معظم الأنظمة التي تتعامل مع الوكلاء ذاتية التطور قاست هذين الأمرين ككتلة واحدة. يحل الوكيل مهمة، ثم يستخرج من سجل التنفيذ تعديلات على الموجّهات أو المهارات، ثم يُعاد تشغيل المهمة التالية بالأداة المعدَّلة، وإذا ارتفعت الدرجة النهائية، يُعلَن أن "التطور نجح".

المشكلة أن هذا الحكم يخلط بين قدرتين مختلفتين تمامًا: القدرة على إنتاج تحديث دائم ومفيد من أدلة التنفيذ، والقدرة على استخدام تلك الأداة المحدَّثة فعليًا عند حل المهمة. القدرتان تعيشان داخل النموذج نفسه، لكن طبيعتهما مختلفة تمامًا. ولأن التقييمات السابقة قاست القدرتين **معًا داخل حلقة التنفيذ نفسها**، لم يكن ممكنًا من النظر إلى الدرجة النهائية وحدها معرفة مصدر التحسّن. يقترح المؤلفون تصميمًا تجريبيًا يفكّ هذا التشابك، وتأتي نتيجته معاكسة تمامًا للحدس السائد في هذا المجال.

## ما الذي تسأله هذه الدراسة

بدايةً، لنوضّح المصطلحات. **الأداة (harness)** هنا تشير إلى كل المكوّنات الخارجية القابلة للتعديل التي تشكّل سلوك الوكيل دون المساس بمعاملات النموذج نفسه. الموجّهات والمهارات والذاكرة وتعريفات الأدوات كلها جزء من الأداة. والتطور الذاتي هو العملية التي يراجع فيها الوكيل نتائج تنفيذه الخاصة ويعدّل هذه الأداة بنفسه. يبقى النموذج ثابتًا، ويتغيّر فقط ما يحيط به من معرفة وأدوات.

تقسّم الدراسة عملية التطور هذه إلى قدرتين.

الأولى هي **قدرة تحديث الأداة (harness-updating)**: القدرة على النظر إلى أدلة مهمة منجَزة وإنتاج تحديث دائم وقابل لإعادة الاستخدام. استخلاص درس من حالة فاشلة وتدوينه في وثيقة مهارة، أو ملاحظة نمط متكرر وترسيخه كقاعدة في الموجّه، كلاهما يندرج تحت هذه الفئة.

الثانية هي **قدرة الاستفادة من الأداة (harness-benefit)**: القدرة، عند توفّر أداة محدَّثة، على استدعائها فعليًا واتباعها لرفع أداء المهمة. مهارة جيدة تجلس دون استخدام في المكتبة، أو مهارة يتم استدعاؤها لكن لا تُتَّبع تعليماتها حتى النهاية، كلتاهما تنتج استفادة تساوي صفرًا.

الفكرة الجوهرية هي أن هاتين القدرتين يجب **قياسهما بشكل منفصل**. إذا قرنّا النموذج الذي أنتج التحديث بنموذج آخر يستخدم ذلك التحديث، يمكننا معرفة ما إذا كان التحسّن جاء من جودة التحديث أم من جودة استخدامه. المخطط أدناه يوضّح بنية هذا التشابك ونقطة الفصل بينهما.

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
<div class="d3-arch" data-arch-root id="volvingharnessevaluation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 597, "height": 1044, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 193, "y": 24, "w": 120, "h": 46, "title": "تنفيذ المهمة"}, {"id": "B", "x": 182, "y": 148, "w": 142, "h": 46, "title": "جمع أدلة التنفيذ"}, {"id": "C", "x": 152, "y": 272, "w": 202, "h": 84, "title": ["قدرة تحديث الأداة", "إنتاج تحديثات دائمة من", "الأدلة"]}, {"id": "D", "x": 284, "y": 448, "w": 191, "h": 78, "title": ["أداة محدَّثة", "موجّهات، مهارات، ذاكرة،", "أدوات"]}, {"id": "E", "x": 265, "y": 604, "w": 230, "h": 84, "title": ["قدرة الاستفادة من الأداة", "استدعاء التحديثات واتباعها", "بأمانة"]}, {"id": "F", "x": 418, "y": 796, "w": 128, "h": 46, "title": "أداء حل المهمة"}, {"id": "G", "x": 404, "y": 950, "w": 156, "h": 62, "title": ["المكسب المقاس", "القدرتان متشابكتان"]}, {"id": "H", "x": 24, "y": 448, "w": 205, "h": 78, "title": ["ثابتة", "متشابهة بصرف النظر عن فئة", "النموذج"]}, {"id": "I", "x": 193, "y": 780, "w": 170, "h": 78, "title": ["غير رتيبة", "النماذج متوسطة الفئة", "تستفيد أكثر"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [253, 70, 253, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [253, 194, 253, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[313, 356], [380, 402], [380, 402], [380, 448]]}, {"src": "D", "dst": "E", "kind": "data", "line": [380, 526, 380, 604]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[428, 688], [482, 734], [482, 734], [482, 796]]}, {"src": "F", "dst": "G", "kind": "event", "label": "تُقاس معًا في الحلقة نفسها", "line": [482, 842, 482, 950], "lx": 482, "ly": 900}, {"src": "C", "dst": "H", "kind": "event", "label": "نتيجة القياس المنفصل", "curve": [[193, 356], [127, 402], [127, 402], [127, 448]], "off": "50%"}, {"src": "E", "dst": "I", "kind": "event", "label": "نتيجة القياس المنفصل", "curve": [[331, 688], [278, 734], [278, 734], [278, 780]], "off": "50%"}]});
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
      const container = document.getElementById('volvingharnessevaluation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'volvingharnessevaluation-1';
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

## ما الذي يكشفه فصل القدرتين

تتلخّص نتيجة التجربة المنفصلة في جملتين، وكلتاهما تخالف الحدس العملي.

أولًا، **قدرة تحديث الأداة ثابتة تقريبًا بصرف النظر عن فئة النموذج**. التحديثات التي أنتجتها نماذج من فئات قدرة مختلفة جدًا أعطت مكاسب متقاربة بشكل مفاجئ. وبتعبير المؤلفين أنفسهم، فإن التحديثات التي أنتجها نموذج صغير بحجم 9B ضاهت المكاسب التي حققتها تحديثات من أقوى النماذج المتقدمة. بعبارة أخرى، "من كتب المهارة" لم يؤثر تقريبًا في جودة التحديث. يتبيّن أن استخلاص قاعدة وترسيخها في وثيقة عمل معرفي أرخص مما كان متوقّعًا.

ثانيًا، **قدرة الاستفادة من الأداة غير رتيبة عبر الفئات**. عند إعطاء النموذج الأداة المحدَّثة نفسها، لم تستفد النماذج الضعيفة تقريبًا، واستفادت النماذج متوسطة الفئة أكثر من غيرها، بينما استفادت النماذج الأعلى فئة أقل مما استفادت النماذج المتوسطة. فبدلًا من منحنى يستمر بالارتفاع كلما صعدنا في الفئة، حصلنا على منحنى ينتفخ في المنتصف.

حين نُركّب هاتين النتيجتين تنقلب الصورة. وضع نموذج متقدم باهظ التكلفة في دور **المطوِّر الذي ينتج التحديثات** داخل نظام ذاتي التطور يقترب من إهدار الميزانية، لأن جودة التحديث ثابتة على أي حال. في المقابل، وضع نموذج باهظ التكلفة في دور **الوكيل الذي يحل المهمة فعليًا** ليس بالضرورة الخيار الأمثل أيضًا، لأن الاستفادة غير رتيبة. النموذج القوي غالبًا ما تكون له عاداته الراسخة، وينزع إلى اتباع تعليمات أداة خارجية بدرجة أقل.

## لماذا لا تستفيد النماذج الضعيفة

أكثر جزء عملي في الورقة هو تحليل سبب عدم استفادة النماذج ضعيفة الفئة. يشير المؤلفون إلى نمطين من الفشل.

الأول هو **فشل التفعيل**. حتى حين تكون هناك مهارة مناسبة تمامًا في المكتبة، يفشل النموذج في استرجاعها. الحكم اللازم لربط عنصر ملائم من الأداة بالموقف الحالي لا يحدث ببساطة. المهارة موجودة، لكنها تُفقَد في مرحلة الاسترجاع والاختيار، فلا تفيد كل التحديثات المتراكمة مهما كانت جيدة.

الثاني هو **التنفيذ غير الأمين**. ينجح النموذج في استرجاع المهارة، لكنه يفشل في اتباع تعليماتها متعددة الخطوات حتى النهاية. حين تكون القدرة على الاحتفاظ بسلسلة طويلة من التعليمات ضعيفة، تنحرف أداة جيدة إلى تنفيذ جزئي ومشوَّه في منتصف الطريق.

هذا التشخيص يقود إلى وصفة واضحة. لرفع أداء التطور الذاتي، لا ترفع ذكاء المطوِّر، بل استهدف **استدعاء الأداة (التفعيل) والتنفيذ الأمين للتعليمات الطويلة**. ميزانية القدرة تُثمر أكثر حين تُنفَق على جانب استخدام التحديثات، وتحديدًا على هاتين العقبتين، بدلًا من جانب إنتاجها.

## دلالات على منتجات ThakiCloud

خلاصة هذه الدراسة تتطابق تمامًا مع الانضباط الذي بنيناه في تشغيل Paxis. Paxis هو Agent-Native Cloud من ThakiCloud، ويعامل المهارات والأدوات والسياسات كموارد من الدرجة الأولى. نختار من أكثر من 960 مهارة باستخدام BM25 وننفّذها في بيئات معزولة (sandboxes)، وحلقة التطور الذاتي للمهارات لدينا تستخلص الدروس من الإخفاقات وتعدّل وثائق المهارات. بعبارة أخرى، نحن نُشغّل بالفعل حلقة "تحديث الأداة" كل يوم.

الدرس الأول الذي تقدّمه هذه الدراسة هو: **لا تُلحق نموذجًا باهظ التكلفة بدور المطوِّر**. حلقة التطور الليلية التي تحسّن المهارات وتسجّل المراجعات يمكن أن تعمل على فئة منخفضة التكلفة، انطلاقًا من فرضية أن جودة التحديث ثابتة. والواقع أن سياسة نماذج المهارات لدينا تبدأ مراحل التطور والتنسيق افتراضيًا بنموذج sonnet، وتثبّت نموذجًا أعلى فئة فقط لمجموعة صغيرة من المهارات التي تكون فيها جودة المحتوى نفسها هي الناتج. تمنحنا هذه الدراسة أساسًا مبنيًا على الأدلة لهذا الخيار: لقد كان **تحسينًا دون فقدان الجودة**، لا مجرد توفير في التكلفة.

الدرس الثاني هو التشخيص القائل بأن العقبة تكمن في "التفعيل والتنفيذ". في بيئتنا، هذا هو بالضبط مشكلة **توجيه المهارات والامتثال للبوابات**. مهما كثر عدد المهارات، إذا لم تُسترجَع المهارة الصحيحة عند وقت الطلب فذلك فشل تفعيل، وإذا استُدعيت مهارة لكن لم تُحترَم بوّاباتها الحتمية فذلك تنفيذ غير أمين. قرار Paxis بتعزيز استرجاع المهارات عبر موجّه BM25، وجعل التنسيق والتحقق مملوكَين لبوّابات كودية بدلًا من حكم النموذج النثري، يستهدف بالضبط هاتين العقبتين. الأداء لا يُحدَّد بمجرد تكديس مهارات جيدة أكثر، بل بالبنية التي تسترجع المهارة الصحيحة بدقة وتفرض تعليماتها حتى النهاية.

هناك أيضًا دلالة على مستوى البنية التحتية. تُشغّل ai-platform عدة فئات من النماذج فوق K8s وKueue. تشير هذه الدراسة إلى أنه من المنطقي، عند نشر خط أنابيب ذاتي التطور، وضع **فئات نماذج مختلفة في أدوار مختلفة** للمطوِّر وحلّ المهمة. النشر المختلط، نموذج رخيص كمطوِّر ونموذج متوسط الفئة كحلّال للمهمة، تصميم يمكنه توفير تكلفة كبيرة في جدولة GPU متعددة المستأجرين مع الحفاظ على الجودة.

## حدود الدراسة وحجج مضادة

قبل نقل هذه الدراسة مباشرة إلى الممارسة، تستحق بضع تحفّظات الذكر.

أولًا، استنتاجا "الثبات" و"عدم الرتابة" مرتبطان بتوزيع المهام وأنواع الأدوات التي غطّتها التجارب. عمل استخلاص القواعد مثل تعديل وثائق المهارات قد يُظهر قدرة تحديث ثابتة، لكن التحديثات التي تتضمن تنفيذ أدوات معقّدة أو توليد كود تنسيق طويل قد تعيد فتح الفجوة بين فئات النماذج. أما إلى أي الجانبين تميل تحديثاتنا نحن، فذلك أمر يجب على كل فريق قياسه بنفسه.

ثانيًا، يمكن أيضًا تفسير أن النماذج الأعلى فئة تستفيد أقل من أداة خارجية على أنه أثر سقف: النموذج القوي جيد أصلًا، فلا يبقى له مجال كبير للتحسّن. هذا لا يعني أن الأداة عديمة الفائدة. فالأداء المطلق قد يظل أعلى لنموذج قوي، والأداة ليست سوى مكسب هامشي يُضاف فوقه.

ثالثًا، بالنسبة لمنظمة مثلنا تمارس بالفعل مبدأ "طوِّر بتكلفة منخفضة، وضع البوابات بتكلفة عالية"، تبدو هذه الدراسة أقرب إلى سند كمي لانضباط قائم بالفعل منها إلى توجّه جديد. أما بالنسبة لفريق كان يرفع فئة نموذج المطوِّر بشكل انعكاسي كلما تعثّر أداء التطور الذاتي، فهذه البيانات إشارة واضحة لإعادة توزيع الميزانية.

## الخاتمة

في النهاية، تترك لنا هذه الدراسة قاعدة عملية واحدة. لا تنظر إلى أداء الأداة ذاتية التطور كدرجة واحدة. **حلّله إلى محورين، التحديث والاستفادة، وقِس كلًا منهما على حدة**. فقط عند الفصل بينهما يتضح أين ينبغي أن تذهب ميزانية القدرة فعليًا.

## المصادر

- Harness Updating Is Not Harness Benefit: Disentangling Evolution Capabilities in Self-Evolving LLM Agents، arXiv 2605.30621: [arxiv.org/abs/2605.30621](https://arxiv.org/abs/2605.30621)
- صفحة Hugging Face Papers: [huggingface.co/papers/2605.30621](https://huggingface.co/papers/2605.30621)
- خلفية ذات صلة: Agentic Harness Engineering، arXiv 2604.25850: [arxiv.org/html/2604.25850v3](https://arxiv.org/html/2604.25850v3)
