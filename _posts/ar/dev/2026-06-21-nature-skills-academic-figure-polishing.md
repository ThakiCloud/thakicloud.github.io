---
title: "أشكال ومراجعة بمستوى Nature عبر الكود: تقرير عمودي أكاديمي بعد تشغيل nature-skills فعليًا"
excerpt: "قمنا باستنساخ حزمة skills مفتوحة المصدر لـ Claude باسم nature-skills، التي تجمع بين توليد الأشكال العلمية والمراجعة الأكاديمية وفق معايير مجلة Nature، ثم استخدمنا nature-figure لعرض بيانات خدمة ThakiCloud في شكل من لوحتين بمستوى جاهز للنشر. قِسنا فعليًا حتى 36 وسم نص قابل للتحرير في SVG، ولخّصنا الدلالات من منظور الملاءمة العمودية للمنتج في سوق الـ skills."
seo_title: "تقرير قياس فعلي لمهارات الأشكال والمراجعة الأكاديمية nature-skills - Thaki Cloud"
seo_description: "تقرير عن تشغيل حزمة skills الخاصة بـ Claude باسم nature-skills (Yuan1z0825) فعليًا. عرضنا شكلًا من لوحتين بمستوى جاهز للنشر باستخدام rcParams وPALETTE الخاصة بـ nature-figure بدقة 600dpi، وحللنا SVG القابل للتحرير ودلالات السوق العمودي الأكاديمي."
date: 2026-06-21
last_modified_at: 2026-06-21
tags:
  - claude-skills
  - academic-writing
  - matplotlib
  - data-visualization
  - nature-figure
  - skill-marketplace
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
categories:
  - dev
published: false
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/nature-skills-academic-figure-polishing/"
---

![صورة تجريدية لمنحنيات بيانات متعددة اللوحات وألواح أشكال تطفو بأجواء أكاديمية]({{ '/assets/images/nature-skills-hero.webp' | relative_url }})
*تجسّد أجواء مهارة الأشكال الأكاديمية التي تتعامل مع الشكل بوصفه "حجة بصرية" لا مجرد "رسم جميل".*

## نظرة عامة

أكثر مهمتين يطلبهما الباحثون من Claude Code هما "أنشئ لي شكلًا يدخل في الورقة البحثية" و"حسّن هذه المسودة الإنجليزية لتصل إلى مستوى المجلة". وكلتاهما، إذا أُسندتا إلى نموذج لغوي عام، تأتيان بنتائج متذبذبة في كل مرة. فالأشكال تكون أحجام خطوطها وألوانها عشوائية، والمراجعة تغيّر الجمل دون قواعد. تهدف حزمة skills مفتوحة المصدر nature-skills (Yuan1z0825/nature-skills) إلى تحجيم هذا التذبذب ضمن هيكل مُتحقَّق منه.

ومع انتشارها، قدّمتها بعض المنشورات بأنها حازت "أكثر من 20 ألف نجمة على GitHub"، لكن الرقم الفعلي الذي تحققتُ منه كان أصغر بكثير، نحو 265 فقط [تقديري]. وبما أن تضخيم عدد النجوم أمر شائع، فقد قيّمتُ في هذا المقال القيمة بنتائج القياس الفعلي بعد تشغيل الأداة بنفسي، لا بعدد النجوم. هذا تقرير تنفيذي قمتُ فيه باستنساخ nature-skills إلى بيئة ThakiCloud، ثم عرضتُ بيانات خدمة فعلية في شكل بمستوى جاهز للنشر باستخدام مهارة nature-figure بداخلها.

## ما هي هذه الأداة

التكوين الفعلي الذي تأكدت منه بعد استنساخ المستودع كان 12 مهارة (باستثناء الوحدات المشتركة) تحت `skills/`. فهي تغطي كامل سير العمل الأكاديمي: nature-figure (الأشكال العلمية)، nature-polishing (المراجعة الأكاديمية)، nature-academic-search (البحث في المراجع)، nature-citation، nature-reviewer، nature-response (الرد على المراجِعين) وغيرها. والترخيص هو MIT.

بطلة هذا المقال **nature-figure هي الإصدار 2.0.0**، وتمتلك بنية موجِّه (router) مقسّمة إلى طبقة ثابتة وطبقة ديناميكية. تضع المعرفة الكبيرة في التصميم وAPI والأنماط وQA في ملفات مرجعية عند الطلب، وتكتشف في كل مهمة الواجهة الخلفية (Python/R) لتحمّل فقط الأجزاء اللازمة. وهذا هو بالضبط نفس نمط الكشف التدريجي (progressive disclosure) الذي تؤكد عليه ThakiCloud.

أكثر التصميمات إثارة للإعجاب هو **"عقد الشكل (figure contract)"**. فهو يفرض، قبل كتابة أي كود، تثبيت جملة واحدة للاستنتاج الجوهري، وسلسلة الأدلة، وتصنيف النمط الأصلي (archetype)، والواجهة الخلفية، وعقد المجلة/التصدير أولًا. وتؤكد المهارة بحزم أن "الشكل حجة بصرية لا رسم جميل معزول". كما تجعل اختيار الواجهة الخلفية **بوابة حاجبة (blocking gate)**؛ فإذا لم يحدد المستخدم Python أم R، تسأل "Python or R?" ثم تتوقف. وهذا تقليص لدرجة الحرية كي لا يختار النموذج قيمة افتراضية اعتباطيًا.

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
<div class="d3-arch" data-arch-root id="sacademicfigurepolishing-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 394, "height": 774, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "FC", "x": 90, "y": 24, "w": 184, "h": 62, "title": ["Figure Contract (تحديد", "الخلاصة)"]}, {"id": "BE", "x": 74, "y": 164, "w": 216, "h": 68, "title": ["بوابة الخلفية: Python أم", "R؟"]}, {"id": "PY", "x": 199, "y": 324, "w": 163, "h": 46, "title": "matplotlib rcParams"}, {"id": "RR", "x": 24, "y": 324, "w": 120, "h": 46, "title": "ggplot2"}, {"id": "STYLE", "x": 83, "y": 448, "w": 198, "h": 46, "title": "تطبيق rcParams + PALETTE"}, {"id": "EXP", "x": 87, "y": 572, "w": 191, "h": 46, "title": "SVG / TIFF قابل للتحرير"}, {"id": "QA", "x": 122, "y": 696, "w": 120, "h": 46, "title": "عقد QA"}], "edges": [{"src": "FC", "dst": "BE", "kind": "data", "line": [182, 86, 182, 164]}, {"src": "BE", "dst": "PY", "kind": "data", "label": "Python", "curve": [[224, 232], [281, 278], [281, 278], [281, 324]], "off": "50%"}, {"src": "BE", "dst": "RR", "kind": "data", "label": "R", "curve": [[140, 232], [84, 278], [84, 278], [84, 324]], "off": "50%"}, {"src": "PY", "dst": "STYLE", "kind": "data", "curve": [[281, 370], [281, 409], [281, 409], [219, 448]]}, {"src": "RR", "dst": "STYLE", "kind": "data", "curve": [[84, 370], [84, 409], [84, 409], [146, 448]]}, {"src": "STYLE", "dst": "EXP", "kind": "data", "line": [182, 494, 182, 572]}, {"src": "EXP", "dst": "QA", "kind": "data", "line": [182, 618, 182, 696]}]});
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
      const container = document.getElementById('sacademicfigurepolishing-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'sacademicfigurepolishing-1';
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
*مسار يبدأ بتحديد الاستنتاج الجوهري ثم اجتياز بوابة الواجهة الخلفية Python/R، ثم تطبيق rcParams وPALETTE لتصدير SVG/TIFF قابل للتحرير، وينتهي بعقد QA.*

## التثبيت والتكامل (أوامر حقيقية)

جرى التحقق في صندوق رمل معزول خارج المستودع، ثم نُظّف بعد ذلك.

```bash
# 1) استنساخ المستودع الخارجي
git clone --depth 1 https://github.com/Yuan1z0825/nature-skills

# 2) التحقق من اعتماديات الواجهة الخلفية Python (الـ .venv المشترك)
.venv/bin/python -c "import matplotlib; print(matplotlib.__version__)"
# matplotlib 3.11.0
```

تتضمن البداية السريعة لـ Python في nature-figure (`static/fragments/backend/python.md`) قيم `rcParams` لشكل بمستوى جاهز للنشر، ويُعرّف `references/api.md` لوحة ألوان PALETTE ملائمة للمجلات. والإعدادات الأساسية كالتالي.

```python
mpl.rcParams.update({
    "font.family": "sans-serif",
    "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans", "sans-serif"],
    "svg.fonttype": "none",   # SVG 안의 텍스트를 편집 가능하게 유지
    "pdf.fonttype": 42,       # PDF 안의 텍스트도 편집 가능한 TrueType
    "font.size": 7,           # 슬라이드용 대형 패널이 아니면 7pt 기준
    "axes.linewidth": 0.8,
})
# api.md PALETTE 발췌
P = {"blue_main": "#0F4D92", "red_strong": "#B64342", "neutral_dark": "#4D4D4D"}
```

السطر `svg.fonttype: "none"` هو جوهر الأمر. فالتصدير المعتاد يحوّل النص إلى مسارات (path)، مما يجعل تحرير الأحرف من جديد في Illustrator مستحيلًا. أما هذا الإعداد فيُبقي النص بوصفه وسوم `<text>`، بحيث يمكن تعديل التسميات كما هي في مرحلة تدقيق المجلة.

## نتائج التجربة الفعلية

طبّقتُ قواعد المهارة (rcParams، PALETTE) كما هي، وعرضتُ بيانات ذات صلة مباشرة بـ ThakiCloud في شكل. الموضوع شكل من لوحتين يقارن بين FP16 وINT8 من حيث زمن الاستجابة (latency) والإنتاجية (throughput) وفق حجم الدفعة في خدمة الاستدلال على GPU. أما قيم منحنيات الخدمة في الرسم فهي توضيحية (schematic)، بينما **القيم المقيسة الفعلية هي القيم الوصفية الملتقطة أثناء عملية العرض**.

```
RENDER_MS=195.4
SVG_BYTES=24131
PNG_BYTES=254233          # 600 dpi
SVG_EDITABLE_TEXT_TAGS=36
PANELS=2 (a:latency, b:throughput)
RCPARAMS_FONT_SIZE=7.0
SVG_FONTTYPE=none
```

النتائج الأساسية ثلاث. أولًا، انتهى عرض الشكل ذي اللوحتين خلال نحو 195 ملّي ثانية. ثانيًا، كان حجم PNG بدقة 600dpi نحو 254 كيلوبايت، وSVG نحو 24 كيلوبايت، أي خفيف. ثالثًا، وهو أهم تحقق، **كان داخل SVG المُولّد 36 وسم `<text>`**. وهذا دليل مباشر على أن "النص القابل للتحرير" الذي وعدت به المهارة قد تحقق فعلًا. فلو جرى التحويل إلى مسارات لكان عدد وسوم `<text>` صفرًا.

![شكل من لوحتين بأسلوب Nature يقارن زمن الاستجابة والإنتاجية بين FP16 وINT8]({{ '/assets/images/nature-skills-results.webp' | relative_url }})
*ناتج فعلي معروض بتطبيق rcParams وPALETTE الخاصة بـ nature-figure. اليسار (a) يبيّن زمن الاستجابة حسب حجم الدفعة، واليمين (b) يبيّن الإنتاجية. قيم منحنيات الخدمة بيانات توضيحية.*

كل هذه القيم التقطتُها بنفسي عبر stdout بعد تشغيلها مباشرة، وليست اقتباسًا خارجيًا. والجوهر أن المهارة تثبت الجودة بدليل تنفيذي، لا بادّعاء نثري بأنها "رسمت بشكل جميل".

## التطبيق والدلالات لمنصة ThakiCloud K8s AI/ML SaaS

تُظهر nature-skills نسيجين في آنٍ واحد.

من منظور ممارسة علم البيانات، فإن فكرة **تثبيت نمط الرسوم البيانية برموز مُتحقَّق منها (tokens)** مفيدة فورًا. فتقارير ThakiCloud ولوحاتها تتذبذب فيها الألوان والخطوط والمحاور في كل مرة، لكن تثبيت rcParams وPALETTE في مكان واحد كما في nature-figure يرفع متوسط الجودة. وعلى وجه الخصوص، فإن نمط تصدير SVG قابل للتحرير عبر `svg.fonttype: "none"` يمكن استخدامه كما هو في المواد التسويقية والندوات التي يعالجها فريق التصميم لاحقًا. وشكل النتائج في هذا المقال هو الدليل.

ومن منظور استراتيجية المنصة، تُظهر nature-skills **إشارة على ملاءمة المنتج للسوق (PMF) في العمود الأكاديمي**. فهي ليست مهارة عامة، بل كثّفت القواعد في استخدام ضيق وعميق هو "التقديم لمجلة Nature"، ومن ثَمّ يرتفع اتساق النتائج. وبالنسبة إلى ThakiCloud التي تشغّل AI/ML SaaS على K8s، تُعدّ المهارة العمودية التي تضع قواعد المجال طبقةً رقيقة فوق نموذج لغوي عام نمطًا جوهريًا للتمايز. ويمكن نسخ الهيكل نفسه إلى أعمدة داخلية مثل الطب والمالية وبراءات الاختراع.

## القيود والحجج المضادة

أولًا، **تضخيم عدد النجوم**. اختلف عدد "أكثر من 20 ألف نجمة" في بعض المنشورات اختلافًا كبيرًا عن الواقع (نحو 265) [تقديري]. ويؤكد هذا المثال مجددًا الحاجة إلى إجراء يتمثل في التشغيل بنفسك بدلًا من الثقة المباشرة بالإشارات الفيروسية.

ثانيًا، **مسؤولية صحة بيانات الشكل تقع على المستخدم.** فالمهارة ترسم الشكل جيدًا، لكنها لا تضمن دقة الأرقام التي توضع فيه. ولهذا السبب نفسه حدّدتُ منحنيات الخدمة في هذا المقال بوصفها أمثلة. وفي الأوراق أو التقارير الحقيقية يجب إدخال القيم المقيسة فقط.

ثالثًا، قد تكون **إلزامية بوابة الواجهة الخلفية** عائقًا في خطوط الأنابيب الآلية. فسلوك السؤال "Python or R?" والتوقف في كل مرة هو صمام أمان في الوضع التحاوري، لكنه يحتاج في الدفعات غير المراقَبة إلى غلاف يثبّت الواجهة الخلفية مسبقًا.

وخلاصة القول، تُعدّ nature-skills مثالًا جيدًا على "المهارة العمودية التي تكثّف قواعد المجال في كود". وعندما نحكم على القيمة بأدلة قياس فعلية مثل 36 وسم نص قابل للتحرير، لا بعدد النجوم، فإن تصميمها يستحق التعلّم منه بحق.

## المصادر

- nature-skills (GitHub, MIT): [github.com/Yuan1z0825/nature-skills](https://github.com/Yuan1z0825/nature-skills)
- جميع القيم المقيسة في هذا المقال هي قيم عُرضت محليًا بعد استنساخ nature-figure v2.0.0 مباشرة. وعدد النجوم (نحو 265) تقدير بحسب البحث.
