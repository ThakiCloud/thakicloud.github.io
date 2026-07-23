---
title: "حذفنا 423 غيغابايت من GLM-5.2 دون تكميم: قياس الهدر في حقل الأس في BF16"
excerpt: "ادعى أحدهم أنه قلّص GLM-5.2 من 1403 غيغابايت إلى 980 غيغابايت. لا تكميم ولا تشذيب، بل ضغط بلا خسارة مطابق للأصل بت ببت. كان من الصعب تصديق ذلك، لذا فتحنا 490 مليون وزن من Qwen2.5-0.5B وقِسنا بأنفسنا إنتروبيا حقل الأس في BF16. اتضح أن الثمانية بتات المخصصة لا تحمل فعليا سوى 2.64 بت من المعلومات، ما يعني إمكانية إزالة نحو 33.5 بالمئة دون خسارة. يشرح هذا المقال من أين يأتي هذا الهدر، ولماذا يظهر التوفير ليس على القرص فحسب بل في ذاكرة VRAM أيضا، بالاستناد إلى بيانات مقاسة."
tags:
  - lossless-compression
  - bf16
  - quantization
  - vram
  - llmops
  - self-hosting
  - vllm
  - paxis
date: 2026-07-14
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/lossless-bf16-compression/"
categories:
  - llmops
---

![رسم توضيحي تجريدي لمكعبات زجاجية متراصة تُضغط دون خسارة إلى كتلة أصغر]({{ '/assets/images/lossless-bf16-compression-hero.png' | relative_url }})

## نظرة عامة

كل فريق خدَم نموذجا كبيرا مفتوح الأوزان محليا يعرف أن العائق الأول هو دائما الحجم. نموذج مثل GLM-5.2، بأكثر من 700 مليار معامل، يقترب من 1.4 تيرابايت في صيغة BF16 الخام، وتوزيعه على عدة وحدات GPU يجعل ذاكرة VRAM تكلفة مباشرة. وكان الجواب على هذه المشكلة دائما تقريبا هو التكميم: خفض 16 بت إلى 8 ثم إلى 4 بل إلى 2، مع التضحية بقليل من الجودة في الطريق.

هذا المقال موجه لقادة الهندسة المسؤولين عن تكلفة الاستدلال، وللممارسين الذين ينشرون النماذج محليا (on-premises)، ولعلماء البيانات في البيئات الخاضعة للتنظيم الذين لا يمكنهم فقدان بت واحد من الدقة. نشر مؤخرا باحث باسم brianbell-x أنه حذف 423 غيغابايت من GLM-5.2. صار 1403 غيغابايت يساوي 980 غيغابايت، والمثير أن الطريقة لم تكن تكميما. لم تكن تشذيبا ولا تقطيرا، بل ضغطا بلا خسارة يعيد بناء الأصل بت ببت عند فك الضغط. فإذا كان شيء بلا خسارة ومع ذلك يتقلص بنسبة 30 بالمئة، فهذا يعني أن الصيغة الأصلية كانت تهدر هذا القدر بالضبط.

بدل أن نأخذ الادعاء على محمل الثقة، قررنا التحقق منه مباشرة. فتحنا 490 مليون وزن مُدرّب فعلي من Qwen2.5-0.5B وقِسنا إنتروبيا حقل الأس في BF16، مؤكدين أن الثمانية بتات المخصصة تحمل فقط 2.64 بت من المعلومات الحقيقية. جاء الحد النظري للضغط بلا خسارة عند 33.5 بالمئة، وهو ما تطابق تقريبا مع 30.17 بالمئة التي حققها المؤلف الأصلي بترميز فعلي. يغطي هذا المقال تلك القياسات ويشرح لماذا يحدث التوفير ليس على القرص فحسب بل في VRAM أيضا.

## ما هي هذه التقنية

علينا أولا أن نرى كيف يخزّن BF16 رقما واحدا. يقسم BF16 (brain floating point 16) الستة عشر بت إلى ثلاثة أجزاء: بت إشارة واحد، و8 بتات أس، و7 بتات جزء عشري (mantissa). يحصل الأس على 8 بتات كاملة لأن BF16 مصمم للحفاظ على نطاق ديناميكي واسع مماثل لـ FP32، حتى يستطيع تمثيل قيم كبيرة جدا أو صغيرة جدا.

المشكلة أن أوزان نموذج مُدرّب بالكاد تستخدم هذا النطاق الواسع. في شبكة عصبية مدربة جيدا، تتجمع معظم الأوزان حول قيم صغيرة قرب الصفر. ونتيجة لذلك يتكتل حقل الأس حول حفنة من القيم، ومن بين 256 احتمالا تستطيع الثمانية بتات تمثيلها، لا يظهر فعليا سوى جزء ضئيل. هنا يكمن الهدر: تُخصَّص 8 بتات، لكن المعلومات المحمولة فعليا أقل بكثير.

فكرة الضغط بلا خسارة بسيطة. رمّز حقل الأس منخفض المعلومات بترميز إنتروبي إلى تمثيل قصير، واترك الثمانية بتات من الإشارة والجزء العشري كما هي لأنها شبه غير قابلة للضغط. يجمع تنفيذ المؤلف الأصلي الإشارة والأس في رمز من 4 بتات يشير إلى جدول بحث يضم أكثر 15 تركيبة أُس شيوعا. أما القيم النادرة غير الموجودة في الجدول فتُخزَّن منفصلة بصيغتها الكاملة. تلخّص الصورة التالية هذه العملية.

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
<div class="d3-arch" data-arch-root id="4losslessbf16compression-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 268, "height": 1070, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 31, "y": 24, "w": 198, "h": 78, "title": ["وزن BF16 مُدرّب", "16 بت = إشارة 1 + أس 8 +", "جزء عشري 7"]}, {"id": "B", "x": 28, "y": 180, "w": 205, "h": 62, "title": ["تحليل حقل الأس", "يظهر عدد قليل من 256 قيمة"]}, {"id": "C", "x": 28, "y": 320, "w": 205, "h": 62, "title": ["قياس إنتروبيا الأس", "تخصيص 8 بت -> نحو 2.64 بت"]}, {"id": "D", "x": 28, "y": 460, "w": 205, "h": 94, "title": ["استبدال الإشارة+الأس برمز", "4 بت", "أكثر 15 تركيبة شيوعا ->", "جدول بحث"]}, {"id": "E", "x": 28, "y": 632, "w": 205, "h": 78, "title": ["الحفاظ على الجزء العشري 7", "بت كما هو", "بلا خسارة بت ببت"]}, {"id": "F", "x": 42, "y": 788, "w": 177, "h": 94, "title": ["تخزين الأسات النادرة", "بصيغتها الكاملة", "مع الحفاظ على العنونة", "ثابتة العرض"]}, {"id": "G", "x": 24, "y": 960, "w": 212, "h": 78, "title": ["الوزن المضغوط", "نحو 10.6 بت لكل وزن (توفير", "نحو 33%)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [130, 102, 130, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [130, 242, 130, 320]}, {"src": "C", "dst": "D", "kind": "data", "line": [130, 382, 130, 460]}, {"src": "D", "dst": "E", "kind": "data", "line": [130, 554, 130, 632]}, {"src": "E", "dst": "F", "kind": "data", "line": [130, 710, 130, 788]}, {"src": "F", "dst": "G", "kind": "data", "line": [130, 882, 130, 960]}]});
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
      const container = document.getElementById('4losslessbf16compression-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '4losslessbf16compression-1';
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

يختلف هذا النهج جوهريا عن التكميم. فالتكميم يقتطع الجزء العشري أو يقرّب القيم، مسقِطا الدقة فعليا. أما الضغط بلا خسارة فلا يسقط شيئا. إنه يعيد كتابة المعلومات نفسها برمز أقصر فقط، فيعيد فك الضغط الأوزان الأصلية دون خطأ بت واحد. تنتمي أعمال حديثة مثل DFloat11 و ZipNN إلى العائلة نفسها. أفاد ZipNN أن حقل الأس في BF16 لأوزان نماذج اللغة المدربة يحمل نحو 2.6 بت فقط من إنتروبيا شانون ضمن تخصيصه البالغ 8 بت. ما أردنا معرفته هو ما إذا كان هذا الرقم يتكرر على نموذج حقيقي.

## قياس إنتروبيا الأس بأنفسنا

للتحقق، فتحنا نموذج BF16 مُدرّبا حقيقيا واحدا في بيئة عمل معزولة. كان الهدف Qwen2.5-0.5B، وهو نموذج منشور فعلي بـ 490 مليون وزن. حللنا البنية الثنائية لملف safetensors مباشرة، وقرأنا كل مصفوفة BF16 كأعداد صحيحة من 16 بت، واستخرجنا الثمانية بتات الخاصة بالأس، وحسبنا توزيع القيم وإنتروبيا شانون. لم نستخدم أي تقدير من إطار عمل، بل الأرقام المستخرجة من بايتات المصفوفة الفعلية فقط.

في ما يلي شفرة القياس الأساسية، وهي الجزء الذي يرى قيمة BF16 كعدد صحيح من 16 بت ويقتطع حقل الأس.

```python
import numpy as np

def bf16_exponent_bytes(raw: np.ndarray) -> np.ndarray:
    # raw = قيم BF16 مرئية كـ uint16. الأس = البتات 14..7 (8 بت)
    return ((raw >> 7) & 0xFF).astype(np.uint8)

# حلّل ترويسة safetensors، اقرأ مصفوفات BF16 كـ uint16، واحسب
# إنتروبيا شانون من تكرار قيم الأس.
```

كانت النتيجة أكثر إثارة مما توقعنا. في ما يلي ما أظهره مسح عبر 290 مصفوفة BF16 بمجموع 494 مليون وزن.

| البند | القيمة المقاسة |
|---|---|
| عدد مصفوفات BF16 | 290 |
| إجمالي الأوزان | 494,032,768 |
| قيم الأس الظاهرة فعليا | 38 من أصل 256 |
| إنتروبيا شانون لحقل الأس | **2.6386 بت** (من 8 مخصصة) |
| نصيب أكثر 3 أسات شيوعا | نحو 72 بالمئة من كل الأوزان |
| البت لكل وزن بعد الضغط | 16 بت -> 10.64 بت |
| التوفير النظري بلا خسارة | **33.5 بالمئة** |

يستطيع حقل الأس تمثيل 256 قيمة، لكن ظهرت 38 فقط، وغطت أعلى 3 منها 72 بالمئة من كل الأوزان. كانت إنتروبيا شانون 2.6386 بت، مطابقة تقريبا لـ 2.6 بت التي أفاد بها ZipNN. بعبارة أخرى، كان حقل الأس البالغ 8 بت يحمل 2.64 بت فقط من المعلومات، والبتات الـ 5.36 المتبقية هدر خالص.

إزالة هذا الهدر بلا خسارة تخفض البت لكل وزن من 16 إلى 10.64، مع الحفاظ على الثمانية بتات من الإشارة والجزء العشري وضغط الأس حتى حده الإنتروبي. وكتوفير، هذا يعادل 33.5 بالمئة.

![مخطط لقياس Qwen2.5-0.5B يظهر أن حقل الأس في BF16 يستخدم فعليا 2.64 بت فقط، وأن ضغطه بلا خسارة يقلّص GLM-5.2 من 1403 غيغابايت إلى نحو 980 غيغابايت]({{ '/assets/images/lossless-bf16-compression-results.png' | relative_url }})

بإسقاط هذه الـ 33.5 بالمئة على حجم GLM-5.2 (753B)، يصبح 1403 غيغابايت نحو 933 غيغابايت. أما القيمة التي حققها المؤلف الأصلي بترميز فعلي فكانت 980 غيغابايت، أي توفير 30.17 بالمئة. الفجوة البالغة نحو 3 نقاط مئوية بين حدنا النظري (33.5 بالمئة) والتنفيذ الفعلي (30.17 بالمئة) ليست صدفة. فمرمّزات الإنتروبيا الفعلية لا تبلغ حد شانون كاملا، ويجب تخزين قيم الأس النادرة بصيغتها الكاملة، ويجب أن تكون الرموز ثابتة العرض للسماح بالوصول العشوائي على GPU، وكل ذلك يضيف عبئا طفيفا. أن تتقارب النظرية والتنفيذ إلى هذا الحد دليل قوي على أن الادعاء الأصلي صحيح وأن النهج سليم.

## لماذا تتقلص VRAM أيضا على GPU

هنا النقطة الأسهل إساءة فهمها. معظم الضغط يتقلص على القرص فقط ويعود إلى حجمه الكامل لحظة تحميل النموذج على GPU، لأنه يجب فك ضغطه للحساب. لكن الـ 30 بالمئة في هذا الضغط بلا خسارة هي رقم VRAM لا رقم قرص. وهذا ما يجعل هذه التقنية مختلفة عن ضغط الملفات العادي.

السر في الرموز ثابتة العرض. لأن رمز كل وزن مضغوط بالعرض نفسه، يمكنك حساب موضع الوزن رقم N بالضبط دون فك ضغط. لا حاجة لتمرير فك تعبئة منفصل ولا لنسخة ثانية بالصيغة الأصلية. تقرأ نواة GPU البايتات المضغوطة مباشرة وتبحث عن كل رمز في جدول صغير محفوظ في المسجلات (registers) أثناء إجراء الضرب. الصيغة الكاملة من 16 بت لا توجد أبدا في VRAM. لذلك تظهر الـ 30 بالمئة في البصمة الفعلية للذاكرة، لا على القرص فحسب.

الأثر العملي كبير. خدمة نموذج 1403 غيغابايت تتطلب 18 بطاقة H100 سعة 80 غيغابايت على الأقل. ومع خفض الضغط بلا خسارة له إلى 980 غيغابايت، ينخفض ذلك إلى نحو 13. توفّر خمس وحدات GPU دون فقدان بت واحد من الجودة. إذا كان التكميم مقايضة للجودة بالذاكرة، فهذه التقنية أقرب إلى وجبة غداء مجانية. لكنها ليست مجانية تماما، ونتناول الثمن أدناه.

## الآثار على منتجات ThakiCloud

هذه التقنية جذابة بشكل خاص من منظور ai-platform لدى ThakiCloud. الـ ai-platform بنية تحتية تخدم النماذج لبيئات عملاء متنوعة فوق Kubernetes وجدولة GPU المبنية على Kueue. كثير من العملاء المحليين يطلبون السحابة المحلية والسيادية، وفي تلك البيئات تكون كل وحدة GPU نفقة رأسمالية ومهلة توريد. يقلّل الضغط بلا خسارة عدد وحدات GPU المطلوبة دون التضحية بأي دقة، ما يجعله ورقة أسهل في الإقناع من التكميم أمام العملاء الحساسين للجودة في القطاعات المنظمة. في المال أو الرعاية الصحية، حيث تصبح قابلية إعادة إنتاج مخرجات النموذج خاضعة للتدقيق، يمكن أن يكون التطابق بت ببت متطلبا بحد ذاته.

الأثر أكبر في الإعدادات متعددة المستأجرين التي تخدم نماذج كبيرة بـ vLLM أو SGLang. استعادة 30 بالمئة من VRAM تتيح تركيب نافذة سياق أكبر على العتاد نفسه، أو تشغيل مزيد من الطلبات المتزامنة، أو تحميل نموذج أكبر على عقدة واحدة. تراكم هذا النوع من كفاءة الموارد بالضبط هو حيث ينافس ai-platform على تكلفة خدمة منخفضة. الضغط بلا خسارة محور متعامد مع التكميم و paged attention والتوازي التنسوري، فيُضاف مباشرة فوق التحسينات القائمة.

والخدمة منخفضة التكلفة تغذّي بدورها اقتصاديات الوكلاء. Paxis، وهو مستوى التحكم Agent-Native Cloud لدى ThakiCloud، يشغّل مئات المهارات في صناديق رمل معزولة ويمرّر كل فعل عبر بوابات سياسة وسجلات تدقيق، وهذه أحمال عمل الوكلاء تستدعي نماذج كبيرة مفتوحة الأوزان مرارا. وكلما انخفضت تكلفة وحدة الخدمة، أمكن تشغيل الوكلاء بجرأة أكبر، فتكون كفاءة موارد ai-platform ركيزة لاقتصاديات تشغيل Paxis.

## القيود والاعتراضات

هذه التقنية ليست علاجا شاملا. أولا، فرضية انخفاض إنتروبيا الأس تصح فقط في النماذج المدربة جيدا. يجب أن تتجمع الأوزان قرب الصفر ليتكتل الأس، لذا فالنماذج غير المدربة بما يكفي، أو ذات التوزيعات الواسعة، أو المكمَّمة بشدة أصلا، ستشهد توفيرا أقل. كما أن قياسنا يأتي من نموذج واحد، فالأرقام الفعلية ستتغير بحسب البنية وطريقة التدريب.

ثانيا، فك رموز الضغط في الوقت الحقيقي يتطلب من نواة GPU معالجة البحث والضرب معا. وإن لم تُحسَّن تلك النواة جيدا، فقد ينتهي بك الأمر إلى توفير الذاكرة مع زيادة زمن الاستجابة. قد تعمل أسرع في أحمال العمل المقيدة بعرض نطاق الذاكرة، لكن هذا يعتمد بشدة على العتاد وتنفيذ النواة، لذا يجب قياس الأداء على GPU المستهدف قبل النشر.

ثالثا، بما أنه بلا خسارة، لا يستطيع هذا النهج بلوغ توفير الضغط الشديد مثل التكميم إلى 4 بت. توفير 30 بالمئة ممتاز، لكنه يخدم غرضا مختلفا عن التكميم الذي يتنازل عن قليل من الجودة ليتقلص 4 أضعاف. الاثنان متكاملان لا متنافسان، والجواب الواقعي يجمعهما: ضغط بلا خسارة حيث تكون الدقة حاسمة تماما، وتكميم حيث يوجد فسحة في الجودة.

أخيرا، تستند هذه النتيجة إلى تجربة عامة لباحث واحد وإلى إعادة إنتاج صغيرة النطاق من جانبنا. تطبيقها في الإنتاج يتطلب التحقق المستقل من التطابق بت ببت للضغط وإعادة البناء، ومن أداء النواة، ومن توفير VRAM الفعلي على النموذج المستهدف وحزمة الخدمة.

## المصادر

- brianbell-x, "Lossless Model Compression Experiment": [https://brianbell-x.github.io/weight-compression/](https://brianbell-x.github.io/weight-compression/)
- النموذج المقاس: Qwen/Qwen2.5-0.5B (Hugging Face)
- أعمال ذات صلة: ZipNN, DFloat11 (عائلة ترميز إنتروبيا الأس في BF16)
