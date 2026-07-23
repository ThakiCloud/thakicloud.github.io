---
title: "إطلاق مجموعة بيانات NVIDIA Nemotron متعددة اللغات بستة ملايين مثال -- تعزيز منظومة الذكاء الاصطناعي مفتوح المصدر"
excerpt: "تُطلق NVIDIA مجموعة بيانات استدلال متعددة اللغات تضم ستة ملايين مثال، وتوفر بيانات تدريب عالية الجودة تغطي خمس لغات: الفرنسية والإسبانية والألمانية والإيطالية واليابانية."
seo_title: "إطلاق مجموعة بيانات NVIDIA متعددة اللغات بستة ملايين مثال - بيانات تدريب الذكاء الاصطناعي - Thaki Cloud"
seo_description: "تحليل مجموعة بيانات NVIDIA Nemotron Post-Training Dataset v2. استكشف منهجية الترجمة وضوابط الجودة وأساليب الاستخدام لمجموعة بيانات الاستدلال متعددة اللغات المؤلفة من ستة ملايين مثال. بيانات تدريب عالية الجودة لا غنى عنها لتطوير الذكاء الاصطناعي مفتوح المصدر."
date: 2025-08-21
last_modified_at: 2025-08-21
tags:
  - NVIDIA
  - Nemotron
  - 다국어데이터셋
  - 추론데이터
  - 번역데이터
  - 훈련데이터
  - Qwen2.5
  - 머신러닝
  - 오픈소스
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "database"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/datasets/nvidia-nemotron-6million-multilingual-reasoning-dataset/"
lang: ar
reading_time: true
categories:
  - datasets
  - llmops
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

## مقدمة

لا يمكن المبالغة في أهمية بيانات التدريب عالية الجودة لتحسين أداء نماذج الذكاء الاصطناعي اللغوية. وفي البيئات متعددة اللغات تحديدًا، تُعدّ مجموعات البيانات المُحسَّنة لكل لغة ضرورة لا غنى عنها لتطوير قدرات الاستدلال.

في العشرين من أغسطس 2025، قدّمت NVIDIA إسهامًا مهمًا آخر في منظومة الذكاء الاصطناعي مفتوح المصدر بإطلاق **مجموعة بيانات استدلال متعددة اللغات تضم ستة ملايين مثال**. وتُترجم مجموعة بيانات **Nemotron Post-Training Dataset v2** بيانات الاستدلال الإنجليزية الحالية إلى خمس لغات -- الفرنسية والإسبانية والألمانية والإيطالية واليابانية -- لتوفير أداة قوية لتطوير نماذج الذكاء الاصطناعي متعددة اللغات.

## الخصائص الرئيسية لمجموعة البيانات

### دعم واسع متعدد اللغات

تتميز مجموعة **Nemotron Post-Training Dataset v2** بالخصائص التالية:

- **ستة ملايين مثال للاستدلال متعدد اللغات**
- **خمس لغات مستهدفة**: الفرنسية (fr) والإسبانية (es) والألمانية (de) والإيطالية (it) واليابانية (ja)
- **الحفاظ على سلاسل الاستدلال الإنجليزية**: تُترجم التعليمات والاستجابات فحسب، بينما تُحتفظ بمنطق الاستدلال الإنجليزي الأصلي
- **ترخيص مفتوح**: منشورة بموجب رخصة nvidia-open-model-license

### نهج ترجمة مبتكر

اعتمدت NVIDIA نهجًا مبتكرًا يتخطى حدود الترجمة التقليدية:

```
تعليمات المستخدم    --> [مُترجمة]
استجابة النموذج    --> [مُترجمة]
سلسلة الاستدلال   --> [محتفظ بها بالإنجليزية]
```

يُمثّل هذا النهج استراتيجية متوازنة تستثمر المعرفة الإنجليزية المكتسبة خلال مرحلة التدريب المسبق إلى أقصى حد، مع توفير واجهة متعددة اللغات في الوقت ذاته.

## منهجية الترجمة وضبط الجودة

### آليات لضمان ترجمة عالية الجودة

أدخلت NVIDIA عدة آليات لضبط الجودة للتغلب على قيود الترجمة الآلية:

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
<div class="d3-arch" data-arch-root id="ilingualreasoningdataset-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 472, "height": 1260, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 114, "y": 24, "w": 205, "h": 94, "title": ["بيانات الاستدلال", "الإنجليزية", "الطلب · الاستجابة · سلسلة", "الاستدلال"]}, {"id": "B", "x": 126, "y": 196, "w": 181, "h": 52, "title": "تقسيم أهداف الترجمة"}, {"id": "C", "x": 242, "y": 340, "w": 184, "h": 62, "title": ["الترجمة إلى 5 لغات", "fr · es · de · it · ja"]}, {"id": "D", "x": 24, "y": 1002, "w": 149, "h": 62, "title": ["الإبقاء على الأصل", "الإنجليزي"]}, {"id": "E", "x": 235, "y": 480, "w": 198, "h": 110, "title": ["نماذج الترجمة", "الألمانية", "Qwen2.5-32B-Instruct-AWQ", "اللغات الأربع الأخرى", "Qwen2.5-14B-Instruct"]}, {"id": "F", "x": 239, "y": 682, "w": 191, "h": 78, "title": ["ضبط الجودة 1", "ترجمة سطرًا بسطر · تخطي", "كتل الأكواد"]}, {"id": "G", "x": 242, "y": 838, "w": 184, "h": 78, "title": ["ضبط الجودة 2", "فرض تنسيق الأقواس ·", "استبعاد تلقائي للمخالف"]}, {"id": "H", "x": 228, "y": 994, "w": 212, "h": 78, "title": ["ضبط الجودة 3", "تحديد اللغة عبر fastText", "55,567 مثال · استبعاد 1.1%"]}, {"id": "I", "x": 114, "y": 1150, "w": 205, "h": 78, "title": ["مجموعة بيانات استدلال", "متعددة اللغات بـ 6 ملايين", "nvidia-open-model-license"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [216, 118, 216, 196]}, {"src": "B", "dst": "C", "kind": "data", "label": "الطلب · الاستجابة", "curve": [[259, 248], [334, 294], [334, 294], [334, 340]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "سلسلة الاستدلال", "curve": [[174, 248], [99, 441], [99, 799], [99, 1002]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [334, 402, 334, 480]}, {"src": "E", "dst": "F", "kind": "data", "line": [334, 590, 334, 682]}, {"src": "F", "dst": "G", "kind": "data", "line": [334, 760, 334, 838]}, {"src": "G", "dst": "H", "kind": "data", "line": [334, 916, 334, 994]}, {"src": "D", "dst": "I", "kind": "data", "curve": [[99, 1064], [99, 1111], [99, 1111], [157, 1150]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[334, 1072], [334, 1111], [334, 1111], [275, 1150]]}]});
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
      const container = document.getElementById('ilingualreasoningdataset-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ilingualreasoningdataset-1';
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

*خط أنابيب ضبط جودة الترجمة. تُترجم الطلبات والاستجابات فقط إلى 5 لغات بينما تبقى سلسلة الاستدلال بالإنجليزية الأصلية، وتمر البيانات عبر ثلاثة مرشحات (الترجمة سطرًا بسطر، وفرض تنسيق الأقواس، وتحديد اللغة عبر fastText) لتنتج 6 ملايين مثال.*

#### 1. معالجة الترجمة سطرًا بسطر

```python
# مثال على منهجية معالجة الترجمة
def translate_by_line(text):
    lines = text.split('\n')
    translated_lines = []
    
    for line in lines:
        if is_translatable(line):  # تستثني كتل الكود والمسافات البادئة وغيرها
            translated = translate(line)
            translated_lines.append(translated)
        else:
            translated_lines.append(line)  # الاحتفاظ بالأصل
    
    return '\n'.join(translated_lines)
```

#### 2. فرض تنسيق خاص

يُستخدم تنسيق أقواس مخصص لضمان جودة الترجمة:

```
التعليمة: "Wrap the translated text in brackets 〘〙"
الاستجابة: 〘النص المترجم〙
```

تُستبعد تلقائيًا أي ترجمة لا تلتزم بهذا التنسيق.

#### 3. تصفية بالتعرف على اللغة

استُخدم نموذج fastText للتعرف على اللغة لتصفية البيانات غير المكتوبة باللغة المستهدفة:

- **استبعاد 55,567 مثالًا** (1.1% من إجمالي الأمثلة متعددة اللغات)
- ضمان الدقة لكل لغة على حدة

### اختيار نموذج الترجمة

اختار الفريق البحثي نماذج الترجمة وفق المعايير التالية:

| اللغة | النموذج المستخدم | سبب الاختيار |
|---|---|---|
| الألمانية | Qwen2.5-32B-Instruct-AWQ | جودة ترجمة متميزة |
| اللغات الأربع الأخرى | Qwen2.5-14B-Instruct | أداء وكفاءة متوازنان |

**معايير الاختيار**:
- جودة ترجمة متميزة
- قابلية التشغيل على وحدة معالجة رسومية A100 واحدة
- تغطية نطاقات موضوعية واسعة
- ترخيص مفتوح (Apache 2.0)

## تحليل جودة البيانات

### معدلات استبعاد البيانات حسب اللغة

يوضح الجدول التالي نسب البيانات المستبعدة أثناء الترجمة لأغراض ضبط الجودة:

| اللغة | الكود | أسئلة وأجوبة | الرياضيات |
|---|---|---|---|
| الألمانية (de) | 2.28% | 1.11% | 2.47% |
| الإسبانية (es) | 26.14% | 5.15% | 6.38% |
| الفرنسية (fr) | 11.01% | 1.37% | 1.96% |
| الإيطالية (it) | 4.94% | 1.36% | 0.75% |
| اليابانية (ja) | 7.68% | 2.51% | 3.86% |

تكشف نسبة الاستبعاد المرتفعة في ترجمة كود الإسبانية (26.14%) عن مدى صعوبة ترجمة النصوص التقنية.

## الارتباط بنموذج Nemotron Nano 2 9B

صدر بالتزامن مع إطلاق مجموعة البيانات هذه نموذج **NVIDIA Nemotron Nano 2 9B**:

### الخصائص الرئيسية للنموذج

- حجم **9 مليارات معامل**
- **بنية هجينة Transformer-Mamba**: طبقات Mamba-2 مع طبقات انتباه متفرقة
- **سرعة توليد رمز أعلى بما يصل إلى 6 أضعاف**
- **ميزانية استدلال قابلة للتخصيص**: إمكانية ضبط الدقة والإنتاجية والتكلفة
- **خفض تكاليف الاستدلال بما يصل إلى 60%**

### التطبيقات المستهدفة

- وكلاء خدمة العملاء
- روبوتات الدردشة للدعم
- المساعدون التحليليون (copilots)
- بيئات النشر على الحافة (Edge) و RTX

## الاستخدام العملي

### تحميل مجموعة البيانات

```python
from datasets import load_dataset

# تحميل مجموعة البيانات الكاملة
ds = load_dataset("nvidia/Nemotron-Post-Training-Dataset-v2")

# تصفية لغة بعينها
french_data = ds.filter(lambda x: x['language'] == 'fr')

# استكشاف البيانات
print(f"إجمالي البيانات: {len(ds)}")
print(f"عدد البيانات الفرنسية: {len(french_data)}")

# فحص عينة
sample = ds[0]
print("التعليمة:", sample['prompt'])
print("الاستجابة:", sample['response'])
print("سلسلة الاستدلال:", sample['reasoning_chain'])
```

### الضبط الدقيق (Fine-Tuning)

```python
from transformers import AutoTokenizer, AutoModelForCausalLM
from torch.utils.data import DataLoader

# تحميل النموذج والمحلل اللغوي
model_name = "nvidia/nemotron-nano-2-9b"
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(model_name)

def preprocess_data(examples):
    """معالجة بيانات الاستدلال متعددة اللغات"""
    inputs = []
    for prompt, response in zip(examples['prompt'], examples['response']):
        # دمج التعليمة والاستجابة
        text = f"### السؤال: {prompt}\n### الجواب: {response}"
        inputs.append(text)
    
    return tokenizer(inputs, padding=True, truncation=True, return_tensors="pt")

# بناء محمّل البيانات
processed_data = ds.map(preprocess_data, batched=True)
dataloader = DataLoader(processed_data, batch_size=4, shuffle=True)

# الشروع في الضبط الدقيق
# (يجب تعديل كود التدريب الفعلي وفقًا للبيئة المستخدمة)
```

## التأثير على منظومة المصدر المفتوح

### الشفافية وقابلية الاستنساخ

يحمل هذا الإصدار من NVIDIA الدلالات التالية:

1. **شفافية كاملة**: إتاحة بيانات التدريب والأدوات وأوزان النموذج النهائية للعموم
2. **بحث قابل للاستنساخ**: يتمكن الباحثون من إجراء التجارب في ظروف متطابقة
3. **تحسين مستمر**: تطوير النماذج عبر مساهمات المجتمع

### تسريع تطوير الذكاء الاصطناعي متعدد اللغات

- دعم **تطوير نماذج متخصصة لكل لغة**
- توفير **معايير لقياس جودة الترجمة**
- تعزيز البحث في **قدرات الاستدلال متعدد اللغات**

## حالات الاستخدام ومجالات التطبيق

### 1. نظام دعم العملاء متعدد اللغات

```python
class MultilingualSupport:
    def __init__(self, model_path):
        self.model = load_model(model_path)
        self.languages = ['fr', 'es', 'de', 'it', 'ja']
    
    def process_query(self, query, language):
        """معالجة استفسارات العملاء حسب اللغة"""
        if language in self.languages:
            response = self.model.generate(
                prompt=query,
                language=language,
                reasoning_enabled=True
            )
            return response
        else:
            return "اللغة غير مدعومة."
```

### 2. مرشد تعليمي بالذكاء الاصطناعي متعدد اللغات

```python
class MultilingualTutor:
    def __init__(self):
        self.dataset = load_dataset("nvidia/Nemotron-Post-Training-Dataset-v2")
        
    def explain_concept(self, concept, language, difficulty_level):
        """شرح مفهوم بلغة بعينها"""
        examples = self.dataset.filter(
            lambda x: x['language'] == language and 
                     x['difficulty'] == difficulty_level and
                     concept in x['topic']
        )
        
        return self.generate_explanation(examples)
```

## نصائح التنفيذ التقني

### معالجة متعددة اللغات بكفاءة

```python
import torch
from transformers import pipeline

class EfficientMultilingualProcessor:
    def __init__(self):
        self.pipelines = {}
        
    def get_pipeline(self, language):
        """تحميل خطوط المعالجة بصورة كسولة (lazy loading) حسب اللغة"""
        if language not in self.pipelines:
            model_path = f"nvidia/nemotron-{language}-specialized"
            self.pipelines[language] = pipeline(
                "text-generation",
                model=model_path,
                torch_dtype=torch.float16,
                device_map="auto"
            )
        return self.pipelines[language]
    
    def process_batch(self, texts, languages):
        """تحسين الكفاءة عبر المعالجة الدُّفعية"""
        results = []
        
        # التجميع حسب اللغة
        language_groups = {}
        for text, lang in zip(texts, languages):
            if lang not in language_groups:
                language_groups[lang] = []
            language_groups[lang].append(text)
        
        # المعالجة الدُّفعية حسب اللغة
        for lang, lang_texts in language_groups.items():
            pipe = self.get_pipeline(lang)
            lang_results = pipe(lang_texts, batch_size=8)
            results.extend(lang_results)
            
        return results
```

### تحسين استخدام الذاكرة

```python
def optimize_memory_usage():
    """تحسين استخدام ذاكرة وحدة معالجة الرسومات"""
    import gc
    import torch
    
    # مسح الذاكرة المؤقتة غير الضرورية
    torch.cuda.empty_cache()
    gc.collect()
    
    # تفعيل نقاط تفتيش التدرج (gradient checkpointing)
    model.gradient_checkpointing_enable()
    
    # التدريب بدقة مختلطة
    from torch.cuda.amp import autocast, GradScaler
    
    scaler = GradScaler()
    
    with autocast():
        # استدلال النموذج أو تدريبه
        pass
```

## معايير الأداء والتحقق

### تقييم جودة الترجمة

قيّم الفريق البحثي جودة الترجمة وفق المقاييس التالية:

```python
def evaluate_translation_quality(original, translated, language):
    """مقاييس تقييم جودة الترجمة"""
    metrics = {}
    
    # درجة BLEU
    from sacrebleu import corpus_bleu
    metrics['bleu'] = corpus_bleu(translated, [original]).score
    
    # دقة التعرف على اللغة
    from fasttext import load_model
    lid_model = load_model('lid.176.bin')
    predictions = lid_model.predict(translated, k=1)
    language_accuracy = sum(1 for pred in predictions[0] 
                          if pred[0] == f'__label__{language}') / len(predictions[0])
    metrics['language_accuracy'] = language_accuracy
    
    # التشابه الدلالي (باستخدام التضمينات متعددة اللغات)
    from sentence_transformers import SentenceTransformer
    model = SentenceTransformer('paraphrase-multilingual-MiniLM-L12-v2')
    
    orig_embeddings = model.encode(original)
    trans_embeddings = model.encode(translated)
    similarity = cosine_similarity(orig_embeddings, trans_embeddings)
    metrics['semantic_similarity'] = similarity.mean()
    
    return metrics
```

### اختبار قدرة الاستدلال

```python
def test_reasoning_capability(model, test_cases, language):
    """اختبار قدرة الاستدلال متعدد اللغات"""
    results = {
        'accuracy': 0,
        'reasoning_quality': 0,
        'language_consistency': 0
    }
    
    correct_answers = 0
    total_cases = len(test_cases)
    
    for case in test_cases:
        prompt = case[f'prompt_{language}']
        expected_answer = case['correct_answer']
        
        response = model.generate(
            prompt,
            max_length=512,
            temperature=0.1,
            do_sample=True
        )
        
        # التحقق من صحة الإجابة
        if check_answer_correctness(response, expected_answer):
            correct_answers += 1
            
        # تقييم جودة عملية الاستدلال
        reasoning_score = evaluate_reasoning_process(response)
        results['reasoning_quality'] += reasoning_score
    
    results['accuracy'] = correct_answers / total_cases
    results['reasoning_quality'] /= total_cases
    
    return results
```

## الآفاق المستقبلية واتجاهات التطوير

### إمكانيات التوسع

1. **دعم مزيد من اللغات**: التوسع إلى ما هو أبعد من اللغات الخمس الحالية
2. **التخصص حسب المجال**: مجموعات بيانات للمجالات المتخصصة كالطب والقانون والتكنولوجيا
3. **تحسين الترجمة الفورية**: معالجة متعددة اللغات في الوقت الحقيقي ضمن بيئات البث

### فرص البحث

```python
# مثال على اتجاهات البحث المستقبلية
class FutureResearchDirections:
    def cross_lingual_transfer_learning(self):
        """بحث التعلم بالنقل عبر اللغات"""
        pass
    
    def multilingual_reasoning_consistency(self):
        """بحث اتساق الاستدلال متعدد اللغات"""
        pass
    
    def cultural_context_adaptation(self):
        """بحث التكيف مع السياق الثقافي"""
        pass
    
    def real_time_translation_optimization(self):
        """بحث تحسين الترجمة الفورية"""
        pass
```

## الخاتمة

يُمثّل إصدار NVIDIA لـ **مجموعة بيانات الاستدلال متعددة اللغات بستة ملايين مثال** معلمًا بارزًا في مجال الذكاء الاصطناعي. إذ يقدّم نهجًا منهجيًا لتحقيق قدرات استدلال عالية الجودة متعددة اللغات يتخطى حدود الترجمة البسيطة، كما يُتيح موردًا قيّمًا لمجتمع المصدر المفتوح.

### الإنجازات الرئيسية

1. **ضبط جودة منهجي**: نظام تحقق متعدد الطبقات للحدّ من الهلوسة وضمان جودة الترجمة
2. **نهج عملي**: دعم متعدد اللغات بكفاءة عبر الحفاظ على سلاسل الاستدلال الإنجليزية
3. **شفافية كاملة**: إتاحة البيانات والأدوات وأوزان النموذج للعموم دون قيود

### التأثير المستقبلي

من المتوقع أن تُسرّع مجموعة البيانات هذه تطوير تطبيقات الذكاء الاصطناعي متعددة اللغات بصورة ملحوظة. ولا سيما للشركات التي تقدم خدمات عالمية، إذ ستُشكّل أداة فاعلة لهدم الحواجز اللغوية.

سيتمكن الباحثون والمطورون من الاستفادة من هذه المجموعة لبناء أنظمة ذكاء اصطناعي متعددة اللغات أكثر تطورًا وملاءمة ثقافية. وتواصل NVIDIA مساهماتها في المصدر المفتوح، مما يدفع منظومة الذكاء الاصطناعي بأسرها نحو التقدم.

## المراجع

- [NVIDIA Nemotron Post-Training Dataset v2 - Hugging Face](https://huggingface.co/datasets/nvidia/Nemotron-Post-Training-Dataset-v2)
- [مدونة NVIDIA: 6 Million Multi-Lingual Reasoning Dataset](https://huggingface.co/blog/nvidia/multilingual-reasoning-v1)
- [معلومات نموذج Nemotron Nano 2 9B](https://build.nvidia.com)
- [سلسلة نماذج Qwen2.5](https://huggingface.co/Qwen)
- [WMT 2024 Translation Shared Task](https://www.statmt.org/wmt24/)

---

💡 **نصيحة تطبيقية**: لبدء مشروع فعلي باستخدام مجموعة البيانات هذه، يُنصح بالبدء بلغة واحدة صغيرة النطاق والتحقق من جودة الترجمة وأداء الاستدلال قبل التوسع.
