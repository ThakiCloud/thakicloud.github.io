---
title: "أداء بمستوى Opus بثلث السعر: كيف يعيد Grok 4.5 رسم اقتصاديات النماذج"
excerpt: "قدّمت SpaceXAI نموذج Grok 4.5 بأداء قريب جداً من Opus 4.8 وGPT-5.5، لكن بسعر أقل من النصف. حين تضيق الفجوة بين النماذج إلى نقطة أو نقطتين في الاختبارات المعيارية، تصبح تكلفة المهمة الواحدة وكفاءة الرموز هما ما يحدد الاختيار العملي. نستعرض الأرقام المعلنة ونوضح ما تعنيه هذه المعادلة الاقتصادية لاستراتيجية توجيه النماذج في ThakiCloud."
tags:
  - model-economics
  - cost-optimization
  - model-routing
  - inference
  - llmops
date: 2026-07-09
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/grok-4-5-opus-class-cheap/"
categories:
  - llmops
---

على مدى الأرباع القليلة الماضية، كان التنافس بين النماذج المتقدمة يدور حول نقطة أو نقطتين في الاختبارات المعيارية. لكن في 8 يوليو 2026، غيّر إصدار Grok 4.5 من SpaceXAI طبيعة السؤال نفسه. فحين يقترب أداء نموذج ما من Opus 4.8 وGPT-5.5، يصبح السؤال التالي ليس "من الأذكى" بل "من ينجز المهمة نفسها بتكلفة أقل". هذا المقال موجّه إلى قادة الهندسة وفرق الذكاء الاصطناعي الذين يديرون بنية تحتية ويدفعون فاتورة النماذج شهرياً. بالاستناد إلى الأرقام المعلنة لـ Grok 4.5، نناقش إلى أين تتجه اقتصاديات النماذج، وما تعنيه هذه الاتجاهات لمنصة استدلال متعددة المستأجرين مثل ThakiCloud.

## نظرة عامة: من سباق الاختبارات المعيارية إلى سباق الجدوى الاقتصادية

طوّرت SpaceXAI، إحدى شركات مجموعة xAI، نموذج Grok 4.5، وهو متاح فوراً عبر Grok Build وCursor وكونسول xAI. وصف إيلون ماسك هذا النموذج بأنه "نموذج بمستوى Opus"، وقد تفوّق فعلاً على Opus 4.8 وGPT-5.5 في بعض الاختبارات. لكن أبرز ما يميز هذا الإصدار ليس الأداء بل جدول الأسعار. يبلغ سعر Grok 4.5 دولارين لكل مليون رمز إدخال، وستة دولارات لكل مليون رمز إخراج. وبالمقارنة مع GPT-5.5 وGPT-5.6 اللذين يُصنّفان في فئة مماثلة بسعر خمسة دولارات للإدخال و30 دولاراً للإخراج، يصبح Grok 4.5 أرخص بنحو خمس المرات من حيث تكلفة الإخراج.

يتضح سبب أهمية هذا الهيكل السعري عند النزول إلى مستوى وحدة العمل الفعلية. تحمل نتائج الاختبارات المعيارية معنى على لوحات الصدارة، لكن ما يحدد الفاتورة فعلياً هو عدد الرموز المستهلكة فعلاً لكل مهمة مضروباً في سعر الوحدة. وهنا بالتحديد يوسّع Grok 4.5 الفجوة بشكل كبير.

## ما هو هذا النموذج: أداء متقارب وتكلفة متباعدة

لنكن صريحين بشأن الأداء أولاً. لا يتفوّق Grok 4.5 في كل الاختبارات المعيارية. فيما يلي الأرقام المعلنة كما وردت:

- في اختبار Terminal Bench 2.1، سجّل Grok 4.5 نسبة 83.3 بالمئة، وهي متساوية تقريباً مع نسبة GPT-5.5 البالغة 83.4 بالمئة.
- في مؤشر Coding Agent Index، سجّل 76 نقطة، وهو مستوى مطابق لـ GPT-5.5 عند تشغيله في بيئة Codex.
- في اختبار DeepSWE 1.1، سجّل 53 بالمئة، متأخراً بفارق كبير عن نسبة GPT-5.5 البالغة 67 بالمئة.
- في مؤشر الذكاء الخاص بـ Artificial Analysis، سجّل 54 نقطة، وهو رقم قريب من نقاط GPT-5.5 البالغة 55.

باختصار، يقف Grok 4.5 نداً لأفضل النماذج في مهام البرمجة ووكلاء الطرفية، لكنه ما زال متأخراً في المهمة الهندسية البرمجية الصعبة الممثلة باختبار DeepSWE. أي أن Grok 4.5 ليس "النموذج الذي يتفوّق على الجميع"، بل هو "النموذج الذي ينجز معظم المهام العملية قريباً من القمة".

وهنا يدخل عنصر الجدوى الاقتصادية إلى المشهد. فيما يلي الأرقام المعلنة لمهمة وكيلية فعلية واحدة:

- تكلفة المهمة الواحدة: 2.49 دولار لـ Grok 4.5 على Grok Build، مقابل 5.07 دولار لـ GPT-5.5 على Codex.
- متوسط الرموز المستهلكة لكل مهمة: 1.9 مليون رمز لـ Grok 4.5، مقابل 6.2 مليون رمز لـ GPT-5.5.

إذا كان الفارق في الأداء بضع نقاط مئوية فقط، فإن الفارق في التكلفة يتجاوز الضعف، وفي استهلاك الرموز يتجاوز ثلاثة أضعاف. قد يبدو هذا سطراً واحداً في جدول اختبارات معيارية، لكن في بيئة تشغيلية تعالج آلاف المهام يومياً، يغيّر هذا الفارق مرتبة الفاتورة الشهرية بأكملها.

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
<div class="d3-arch" data-arch-root id="0709grok45opusclasscheap-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 395, "height": 666, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "T", "x": 119, "y": 24, "w": 149, "h": 46, "title": "مهمة وكيلية واحدة"}, {"id": "R", "x": 121, "y": 148, "w": 146, "h": 52, "title": "اختيار النموذج"}, {"id": "G", "x": 221, "y": 292, "w": 142, "h": 62, "title": ["1.9 مليون رمز", "تكلفة 2.49 دولار"]}, {"id": "P", "x": 24, "y": 292, "w": 142, "h": 62, "title": ["6.2 مليون رمز", "تكلفة 5.07 دولار"]}, {"id": "S", "x": 98, "y": 432, "w": 191, "h": 62, "title": ["أداء متقارب", "تفوّق في بعض الاختبارات"]}, {"id": "D", "x": 88, "y": 572, "w": 212, "h": 62, "title": ["القرار العملي:", "النتيجة نفسها بنصف التكلفة"]}], "edges": [{"src": "T", "dst": "R", "kind": "data", "line": [194, 70, 194, 148]}, {"src": "R", "dst": "G", "kind": "data", "label": "\"Grok 4.5\"", "curve": [[229, 200], [292, 246], [292, 246], [292, 292]], "off": "50%"}, {"src": "R", "dst": "P", "kind": "data", "label": "\"GPT-5.5\"", "curve": [[158, 200], [95, 246], [95, 246], [95, 292]], "off": "50%"}, {"src": "G", "dst": "S", "kind": "data", "curve": [[292, 354], [292, 393], [292, 393], [237, 432]]}, {"src": "P", "dst": "S", "kind": "data", "curve": [[95, 354], [95, 393], [95, 393], [150, 432]]}, {"src": "S", "dst": "D", "kind": "data", "line": [194, 494, 194, 572]}]});
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
      const container = document.getElementById('0709grok45opusclasscheap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0709grok45opusclasscheap-1';
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

## لماذا يهم هذا التوجه الآن

الإشارة التي يحملها هذا الإصدار بسيطة. مع تقارب أداء النماذج المتقدمة نحو سقف مشترك، ينتقل معيار اختيار النموذج من "الأذكى" إلى "الذكاء الكافي بأقل تكلفة". وكما أشارت The Decoder، فحين تضيق الفجوة في الاختبارات المعيارية إلى هذا الحد، قد تفقد الفجوة نفسها أهميتها في الاختيار العملي.

تتقاطع هذه الرؤية تماماً مع مبدأ تناولناه في مقال سابق. فمعظم أعمال الوكلاء ليست مسائل إبداعية معقدة، بل مهام منظّمة مثل التصنيف والتلخيص والتوجيه والعرض. وجودة هذا النوع من المهام تتحدد بحواجز الحماية المضمّنة في الكود أكثر من ذكاء النموذج نفسه. وإذا صح ذلك، فإن توجيه المهام المنظّمة إلى نموذج أرخص، والاحتفاظ بالنموذج الأعلى للاستدلال الصعب حقاً، يصبح خياراً منطقياً. ويوسّع Grok 4.5 نطاق الخيارات المتاحة في فئة "الرخيص لكن الذكي بما يكفي".

في المقابل، هناك نقطة تستحق الانتباه. فانخفاض استهلاك الرموز إلى الثلث لكل مهمة لا يتعلق فقط بسعر الوحدة، بل قد يعني أن النموذج ينجز المهمة نفسها بعدد أقل من الجولات، وهو ما ينعكس إيجاباً على زمن الاستجابة والإنتاجية أيضاً. غير أن هذا الرقم مأخوذ من بيئة اختبار محددة (Grok Build مقابل Codex)، وينبغي التحقق منه بقياس ذاتي على عبء العمل الفعلي.

## الأثر على منتجات ThakiCloud

منصة ai-platform التابعة لـ ThakiCloud هي منصة استدلال متعددة المستأجرين، تخدم النماذج لبيئات عملاء متنوعة فوق جدولة موارد GPU المبنية على K8s وKueue. ويحمل إصدار مثل Grok 4.5 دلالة على مستويين بالنسبة لنا.

المستوى الأول هو اقتصاديات توجيه النماذج. نعتمد بالفعل على تقسيم مستويات النماذج بحسب طبيعة العمل: المستوى الرخيص للاستكشاف والتصنيف، والمستوى المتوسط للتنفيذ والمراجعة، والمستوى الأعلى للهندسة المعمارية والاستدلال المعقد. وحين يظهر نموذج يقارب أداء النماذج المتقدمة بأقل من نصف السعر، تتوسّع تغطية المستوى "الرخيص لكن الكافي"، وتتقلّص الحالات التي تستدعي استدعاء النموذج الأعلى. والنتيجة هي الحفاظ على الجودة نفسها بتكلفة إجمالية أقل. والمهم هنا أن يُبنى هذا القرار على جودة المخرجات الفعلية المقيسة بالكود، لا على الحدس البشري.

المستوى الثاني هو منطق التكلفة في البيئات المحلية والسيادية. بالنسبة للعملاء الذين لا يمكنهم إخراج بياناتهم من بيئتهم، مثل الجهات الحكومية والمالية الكورية أو المتطلبات المرتبطة بجهاز الاستخبارات الوطني، يصبح الاستضافة الذاتية شرطاً أساسياً. وفي هذه البيئات تكون موارد GPU محدودة، لذا فإن النموذج الذي يستهلك رموزاً أقل لكل مهمة يتيح للأجهزة نفسها معالجة طلبات متزامنة أكثر. أي أن كفاءة الرموز ليست مسألة فاتورة API فقط، بل هي أيضاً مسألة إنتاجية فعلية للعناقيد المحلية. وهذا بالضبط ما تتفوّق فيه ai-platform، حيث تُعزّز النماذج ذات الكفاءة العالية في الرموز هذه الميزة مباشرة.

أما المستوى الثالث فيتصل بمنظور الوكلاء عبر Paxis. Paxis هي مستوى التحكم الخاص بالسحابة الأصلية للوكلاء (Agent-Native Cloud) الذي يعمل فوق ai-platform، وينفّذ المهارات في بيئات معزولة، ويمرّر كل إجراء عبر بوابات سياسات وسجلات تدقيق. وتنحصر جدوى الوكلاء الاقتصادية في النهاية بـ "تكلفة النموذج اللازمة لإنجاز مهمة واحدة"، وظهور نموذج منخفض التكلفة وعالي الكفاءة يحسّن مباشرة الميزانية التشغيلية لكل تدفق عمل وكيلي. وهذا يؤكد مجدداً الفرضية القائلة إن الاستضافة الرخيصة هي ما يصنع جدوى اقتصادية للوكلاء.

## القيود والحجج المضادة

قبل الانجراف نحو التفاؤل المطلق، لا بد من النظر إلى الجانب الآخر. أولاً، معظم هذه الأرقام صادرة عن الشركة المزوّدة وعن جهات تحليل مبكّرة. ومعايير مثل Terminal Bench أو Coding Agent Index لا ترتبط ارتباطاً كاملاً بأعباء العمل الإنتاجية الفعلية. وكما توضّح الفجوة بين 53 بالمئة و67 بالمئة في اختبار DeepSWE 1.1، ما زالت النماذج الأعلى تحتفظ بتفوّقها في المهام الصعبة. وإذا دُفعت المهام الاستدلالية الصعبة نحو نموذج رخيص لمجرد رخص سعره، فقد ترتفع تكلفة إعادة المحاولة واستعادة الفشل إلى درجة تقلب المعادلة الإجمالية للتكلفة.

ثانياً، رقم الكفاءة البالغ 1.9 مليون رمز لكل مهمة مُقاس في بيئة محددة (Grok Build)، وقد لا يتكرر في إطار عمل وكيلي مختلف أو بنية تلقين مختلفة. واعتماد الأرقام التي تنشرها الشركة المزوّدة مباشرة على فاتورتك الخاصة أمر محفوف بالمخاطر، ويجب التحقق منه عبر قياس A/B ذاتي على مجموعة بيانات مرجعية.

ثالثاً، Grok 4.5 ليس نموذجاً مفتوح الأوزان، بل نموذج مغلق يُقدَّم عبر واجهة برمجة تطبيقات. وهذا يعني استحالة نشره مباشرة في البيئات المحلية التي تكون فيها سيادة البيانات شرطاً جوهرياً. وما زال العملاء ذوو المتطلبات السيادية بحاجة إلى نموذج مفتوح الأوزان قابل للاستضافة الذاتية، وتبقى الجدوى الاقتصادية لـ Grok 4.5 محصورة في أعباء العمل السحابية عبر واجهة برمجة التطبيقات.

في الخلاصة، يجسّد Grok 4.5 بشكل واضح اتجاهاً أوسع: حين يتقارب أداء النماذج المتقدمة، تنتقل المعركة التالية إلى الجدوى الاقتصادية. والفرق الأكثر نجاحاً في هذه المرحلة ليست تلك التي تطارد نقطة أو نقطتين إضافيتين في الاختبارات المعيارية، بل تلك التي تقيس فعلياً تكلفة المهمة الواحدة وكفاءة الرموز على عبء عملها الخاص، وتوجّه النماذج بناءً على تلك النتائج. وأتمتة هذا القياس وهذا التوجيه هي بالضبط ما نقوم به كل ليلة.

## المصادر

- [Introducing Grok 4.5 · Cursor](https://cursor.com/blog/grok-4-5)
- [SpaceXAI releases Grok 4.5, which Elon describes as an 'Opus-class model' · TechCrunch](https://techcrunch.com/2026/07/08/spacexai-releases-grok-4-5-which-elon-describes-as-an-opus-class-model/)
- [Grok 4.5 is so cheap compared to Fable 5 and GPT 5.5 that benchmark gaps may not matter much · The Decoder](https://the-decoder.com/grok-4-5-is-so-cheap-compared-to-fable-5-and-gpt-5-5-that-benchmark-gaps-may-not-matter-much/)
- [Grok 4.5 (high): Intelligence, Performance & Price Analysis · Artificial Analysis](https://artificialanalysis.ai/models/grok-4-5)
