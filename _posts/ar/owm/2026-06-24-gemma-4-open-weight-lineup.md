---
title: "تشكيلة Gemma 4 الكاملة: خمسة نماذج مفتوحة الأوزان برخصة Apache 2.0 ودليل التشغيل المحلي"
excerpt: "أصدرت Google DeepMind نموذج Gemma 4 في أبريل 2026، وهو عائلة متعددة الوسائط مفتوحة الأوزان مكوّنة من خمسة نماذج تمتد من E2B إلى 31B. نشرح رخصة Apache 2.0، وسياق 256 ألف رمز، والفرق بين 26B MoE و31B Dense، وكيفية اختيار كل نموذج من منظور التشغيل المحلي."
seo_title: "مقارنة تشكيلة Gemma 4 - دليل التشغيل المحلي E2B/E4B/12B/26B MoE/31B - Thaki Cloud"
seo_description: "تشكيلة Gemma 4 (E2B، E4B، 12B Unified، 26B A4B MoE، 31B Dense): المعاملات والسياق وتعدد الوسائط والمعايير (MMLU-Pro 85.2%، GPQA 84.3%) والخدمة عبر vLLM/SGLang/Ollama ورخصة Apache 2.0."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - gemma-4
  - google-deepmind
  - open-weight
  - apache-2.0
  - mixture-of-experts
  - multimodal
  - edge-ai
  - vllm
  - sglang
  - on-premise
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/owm/gemma-4-open-weight-lineup/"
lang: ar
reading_time: true
categories:
  - owm
---

⏱️ **وقت القراءة المقدر**: 10 دقائق

![مخطط مفاهيمي لتشكيلة Gemma 4]({{ '/assets/images/gemma-4-open-weight-lineup-hero.webp' | relative_url }})

## نظرة عامة على Gemma 4

أصدرت Google DeepMind نموذج Gemma 4 في الثاني من أبريل 2026، وهو أذكى عائلة نماذج مفتوحة الأوزان أطلقتها Gemma حتى الآن. وتذكر Google أنه بُني على نفس الأبحاث والتقنيات التي يقوم عليها Gemini 3. بعبارة أخرى، يمكن اعتباره وصفة التدريب وراء نموذج رائد مغلق، مقطّرة إلى تشكيلة مفتوحة الأوزان.

من منظور ThakiCloud، يبرز تغييران في هذا الجيل. أولًا، انتقلت الرخصة إلى **Apache 2.0**. فخلافًا للأجيال السابقة من Gemma التي كانت تحمل سياسة استخدام منفصلة، يتبنى Gemma 4 رخصة مفتوحة المصدر قياسية ومتساهلة تجاريًا. ثانيًا، لا يُطرح بحجم واحد بل كتشكيلة من خمسة نماذج تمتد من **الحافة (الهواتف) إلى وحدة معالجة رسومية واحدة على الخادم**. أي أنه يمكنك اختيار هدف النشر حسب فئة الجهاز ضمن نفس عائلة النماذج.

بدلًا من التعمق في نموذج واحد، يهدف هذا المقال إلى **مقارنة النماذج الخمسة دفعة واحدة وتوضيح أيها يُختار لكل حالة**.

## تشكيلة Gemma 4: النماذج الخمسة كاملة

يتكوّن Gemma 4 من النماذج الخمسة التالية، منظمة حسب المعاملات والسياق والوسائط والبنية وفق بطاقة النموذج:

| النموذج | المعاملات | السياق | وسائط الإدخال | البنية |
|---|---|---|---|---|
| **E2B** | 2.3B فعّالة (5.1B مع التضمينات) | 128K | نص + صورة + صوت | Dense |
| **E4B** | 4.5B فعّالة (8B مع التضمينات) | 128K | نص + صورة + صوت | Dense |
| **12B Unified** | 11.95B | 256K | نص + صورة + صوت | Dense |
| **26B A4B** | 25.2B إجمالًا / 3.8B نشطة | 256K | نص + صورة | MoE (8 خبراء نشطون من 128) |
| **31B Dense** | 30.7B | 256K | نص + صورة | Dense |

تُخرج النماذج الخمسة جميعها نصًا. ودعم إدخال الصوت متاح فقط في نماذج E2B وE4B و12B، بينما يتعامل 26B و31B مع النص والصورة.

يرمز حرف "E" في `E2B` و`E4B` إلى المعاملات الفعّالة (effective). وهو الحجم المبني على معاملات الحوسبة الفعلية باستثناء جدول التضمينات، والقيم الفعّالة هي الرقم الأكثر واقعية عند تقدير ميزانيات الذاكرة والحوسبة. ويستهدف هذان النموذجان مباشرةً الأجهزة الطرفية كالهواتف والحواسيب المحمولة.

جوهر التشكيلة هو **تقسيم العمل بين النموذجين الأعلى: 26B A4B (MoE) و31B (Dense)**.

- **26B A4B** هو نموذج Mixture-of-Experts. يضم 25.2B معاملًا إجماليًا لكنه يُفعّل نحو 3.8B فقط لكل رمز. ولا تزال الأوزان الكاملة بحاجة إلى الوجود في ذاكرة VRAM، لكن حوسبة كل رمز (FLOPs) تُحسب على أساس المعاملات النشطة، وهو ما **يصب في صالح زمن الاستجابة والإنتاجية**. ويناسب الخدمة التي تتطلب تمرير أعداد كبيرة من الطلبات بسرعة.
- **31B Dense** نموذج كثيف قياسي يشارك فيه كل معامل في كل رمز. وهو موجّه نحو تعظيم الجودة وملاءمة الضبط الدقيق، وتضع Google نموذج 31B كسقف الجودة في التشكيلة.

ووفقًا لـ Google، احتل 31B المركز الثالث بين النماذج المفتوحة عالميًا على لوحة Arena AI النصية، وحل 26B في المركز السادس، ووصفت التشكيلة بأنها "تنافس نماذج أكبر منها بعشرين ضعفًا". وتتغير مثل هذه الترتيبات بمرور الوقت، لذا يُفضّل قراءتها كاتجاه ("كثافة ذكاء عالية مقارنة بفئتها") لا كأرقام مطلقة.

### مسار اختيار النموذج

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
<div class="d3-arch" data-arch-root id="24gemma4openweightlineup-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 576, "height": 540, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 311, "y": 24, "w": 156, "h": 46, "title": "اختر نموذج Gemma 4"}, {"id": "B", "x": 320, "y": 148, "w": 138, "h": 52, "title": "هدف النشر؟"}, {"id": "C", "x": 409, "y": 292, "w": 135, "h": 62, "title": ["E2B / E4B", "128K، دعم الصوت"]}, {"id": "D", "x": 216, "y": 297, "w": 138, "h": 52, "title": "الأولوية؟"}, {"id": "E", "x": 408, "y": 446, "w": 120, "h": 62, "title": ["26B A4B MoE", "نشطة 3.8B"]}, {"id": "F", "x": 233, "y": 454, "w": 120, "h": 46, "title": "31B Dense"}, {"id": "G", "x": 43, "y": 446, "w": 135, "h": 62, "title": ["12B Unified", "256K، دعم الصوت"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [389, 70, 389, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "هاتف/جهاز طرفي", "curve": [[420, 200], [476, 246], [476, 246], [476, 292]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "تشغيل محلي بوحدة واحدة", "curve": [[351, 200], [285, 246], [285, 246], [285, 297]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "الإنتاجية/زمن الاستجابة", "curve": [[347, 349], [468, 400], [468, 400], [468, 446]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "أعلى جودة/ضبط دقيق", "line": [287, 349, 293, 454], "lx": 293, "ly": 396}, {"src": "D", "dst": "G", "kind": "data", "label": "متعدد الوسائط + صوت + توازن", "curve": [[226, 349], [110, 400], [110, 400], [110, 446]], "off": "50%"}]});
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
      const container = document.getElementById('24gemma4openweightlineup-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '24gemma4openweightlineup-1';
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

## البنية: الانتباه الهجين وتعدد الوسائط

تتشارك نماذج Gemma 4 الخمسة آلية **انتباه هجين**. فهي تتناوب بين انتباه النافذة المنزلقة المحلية والانتباه العالمي الكامل. تُعالَج النطاقات القصيرة بثمن زهيد عبر النافذة المنزلقة، بينما يُدرَج الانتباه العالمي دوريًا لالتقاط ترابطات السياق الكامل، بهدف كبح كلفة الذاكرة والحوسبة في السياقات الطويلة. وهذا التصميم هو الخلفية وراء قدرة النماذج العليا (12B/26B/31B) على التعامل مع سياق 256K.

تعدد الوسائط هو الإعداد الافتراضي في هذا الجيل. تستقبل النماذج الخمسة جميعها النص والصورة كمدخل، وتتعامل الفئات الطرفية والمتوسطة (E2B/E4B/12B) مع إدخال الصوت أيضًا. كما أن الميزات الموجهة لسير عمل الوكلاء مدمجة أيضًا. فاستدعاء الدوال، وإخراج JSON المنظّم، وتعليمات النظام الأصلية مدعومة رسميًا، وتؤكد التشكيلة تحسينات في التخطيط متعدد الخطوات والاستدلال المنطقي مقارنة بالجيل السابق. وتاريخ قطع بيانات التدريب هو يناير 2025.

ودعم اللغات واسع: أكثر من 35 لغة جاهزة، وأكثر من 140 لغة على مستوى التدريب المسبق. وتتطلب الجودة الفعلية في التشغيل بالكورية تقييمًا مباشرًا، لكن التغطية متعددة اللغات نفسها واسعة.

## المعايير

فيما يلي المعايير التمثيلية التي نشرتها Google لنموذج 31B المضبوط على التعليمات، وفق بطاقة النموذج.

| المعيار | 31B (IT) | المجال المقيس |
|---|---|---|
| MMLU-Pro | 85.2% | المعرفة العامة والاستدلال |
| GPQA Diamond | 84.3% | الاستدلال العلمي بمستوى الدراسات العليا |
| LiveCodeBench v6 | 80.0% | توليد الشيفرة |
| MATH-Vision | 85.6% | الرياضيات المعتمدة على الرؤية |
| Codeforces (ELO) | 2150 | البرمجة التنافسية |

عند حجم 31B بعقدة واحدة، يُعد GPQA Diamond بنسبة 84.3% وMMLU-Pro بنسبة 85.2% في الصدارة بين النماذج المفتوحة الأوزان المماثلة. ومع ذلك، فالمعايير خاصة بالنسخة المضبوطة على التعليمات، ويجب التحقق من الأداء في المهام الواقعية بشكل منفصل. وعلى وجه الخصوص، لا تنعكس مهام الاستدلال والبرمجة بالكورية مباشرةً في المعايير العامة، لذا يُنصح بقياسها بمجموعة تقييم داخلية.

## الخدمة والنشر

أمّن Gemma 4 دعمًا واسعًا من منظومة الخدمة منذ الإطلاق. والمسارات الرسمية هي:

- **خوادم الاستدلال**: vLLM، SGLang، llama.cpp، Ollama، LM Studio، NVIDIA NIM
- **الأطر**: Hugging Face Transformers / TRL / Transformers.js / Candle، Keras، MaxText، NeMo
- **الحافة/على الجهاز**: LiteRT-LM، Cactus
- **الضبط الدقيق/التكميم**: Unsloth، Tunix
- **بنية النشر**: Docker، Baseten، Google Cloud (Vertex AI)

يمكن تنزيل الأوزان من [مجموعة google/gemma-4 على Hugging Face](https://huggingface.co/collections/google/gemma-4) وKaggle وOllama.

### متطلبات وحدة المعالجة الرسومية للتشغيل المحلي (تقديري)

دليل تقريبي للنشر المحلي مبني على ذاكرة أوزان BF16 لكل نموذج. هذه تقديرات للأوزان تستثني ذاكرة KV وأعباء وقت التشغيل، لذا اترك هامشًا لطول السياق وعدد الطلبات المتزامنة في النشر الفعلي.

| النموذج | أوزان BF16 (تقديري) | نقطة بداية واقعية للتشغيل المحلي |
|---|---|---|
| E2B / E4B | نحو 5–16GB [تقديري] | وحدة استهلاكية، حاسوب محمول، هاتف (LiteRT) |
| 12B Unified | نحو 24GB [تقديري] | وحدة 24GB واحدة (فئة RTX 4090/L4)، هامش عند التكميم |
| 26B A4B (MoE) | نحو 50GB [تقديري] | وحدة H100/A100 80GB واحدة |
| 31B Dense | نحو 62GB [تقديري] | وحدة H100/A100 80GB واحدة |

تكمن القوة العملية للتشكيلة في أن النموذجين الأعلى (26B و31B) يتسعان في **وحدة معالجة رسومية واحدة بسعة 80GB** بدقة BF16. أي أنه يمكنك تشغيل استدلال بمستوى متقدم على خادم واحد دون توازي موترات متعدد العقد، وهو ما يخفض كثيرًا حاجز التبني المحلي. وبميزانية وحدة أصغر، انزل إلى نموذج 12B أو إلى مسار مكمَّم (GGUF Q4/Q8). وبفضل طبيعته MoE التي تحسب فقط 3.8B النشطة، يتمتع 26B بأفضلية في الإنتاجية لكل رمز مقارنة بـ31B Dense عند نفس سعة VRAM.

## دلالات للتطبيق على منصة ThakiCloud K8s AI/ML SaaS

تتناغم تشكيلة Gemma 4 جيدًا مع استراتيجية الخدمة متعددة المستأجرين لدى ThakiCloud. وهي مهمة على ثلاث جبهات.

**Apache 2.0 يفتح حاجز التبني.** إن إطلاق عائلة مفتوحة الأوزان بمستوى متقدم تحت رخصة Apache 2.0 القياسية أمر بالغ الأهمية للتبني المؤسسي والمحلي. إذ يمكنك دمجها في خدمات تجارية دون عبء مراجعة سياسة استخدام منفصلة، وتوزيع نواتج الضبط الدقيق بحرية. وهي عائلة نماذج يمكن اقتراحها مباشرةً على البيئات ذات الامتثال الصارم للترخيص، كالقطاع العام والمالي محليًا، وعلى العملاء المحليين الذين يشترطون الاستضافة الذاتية.

**التشكيلة نفسها تتوافق مع توجيه وحدات المعالجة الرسومية متعدد المستأجرين.** تدير ThakiCloud حصص وحدات المعالجة الرسومية عبر Kueue وتخدم النماذج عبر vLLM. وتشكيلة Gemma 4 المكوّنة من خمسة نماذج بنية تتيح توجيه فئات النماذج ضمن عائلة واحدة لتلائم احتياجات المستأجرين (حساسية زمن الاستجابة، أولوية الجودة، استدلال الحافة). وجّه المحادثة/التلخيص الخفيف إلى 12B، والدفعات الحرجة للإنتاجية إلى 26B MoE، والاستدلال/البرمجة عالية الصعوبة إلى 31B، فتتمكن من تحسين ميزانية الوحدات حسب فئة المهمة مع الحفاظ على نفس المُرمِّز وصيغة المُوجِّه.

**الخدمة بوحدة 80GB واحدة تبسّط نموذج الكلفة.** كون 26B و31B يتسعان في وحدة H100/A100 واحدة يبسّط تقدير كلفة مهام وحدات المعالجة الرسومية في Kueue. إذ تختفي أعباء الاتصال وتعقيد الجدولة في توازي الموترات متعدد العقد، فيمكنك التسعير بوضوح بنموذج وحدة مخصصة لكل مستأجر. وميزة 26B MoE بتفعيل 3.8B تعني أنه يستطيع استقبال طلبات متزامنة أكثر على نفس الوحدة، وهو ما يصب أيضًا في صالح كلفة الوحدة لكل طلب.

باختصار، يصلح Gemma 4 كعائلة نماذج مرجعية حين تقترح ThakiCloud نمط تشغيل "تشغيل محلي بوحدة واحدة + توجيه نماذج متعدد المستأجرين" على العملاء.

## القيود والاعتراضات

من باب التوازن، تستحق بضع ملاحظات الذكر.

- **الفجوة بين المعايير والاستخدام الواقعي.** تتركز الأرقام المنشورة على المعايير المضبوطة على التعليمات وباللغة الإنجليزية. ويجب إعادة قياس المهام الكورية، خصوصًا دقة RAG واستدعاء أدوات الوكلاء، بمجموعة تقييم خاصة بك.
- **صعوبة تشغيل MoE.** نموذج 26B A4B منخفض الحوسبة لكل رمز لكنه يجب أن يُبقي الأوزان الكاملة مقيمة في VRAM، ويؤثر توجيه الخبراء في كفاءة الدُفعات وأنماط الذاكرة. والقراءة المبسطة "إنه صغير لأن النشط 3.8B" قراءة محفوفة بالمخاطر.
- **عدم تماثل دعم الصوت.** إدخال الصوت موجود فقط في E2B/E4B/12B. وإن أردت أعلى جودة (26B/31B) والصوت معًا، تنشأ مقايضة ضمن التشكيلة.
- **قطع التدريب في يناير 2025.** المهام التي تحتاج أحدث المعلومات يجب تعزيزها بـRAG وتكامل الأدوات.

ومع ذلك، فإن رخصة Apache 2.0، وجدوى الخدمة بوحدة واحدة، وتشكيلة تصل الحافة بالخادم، أسباب كافية لوضع Gemma 4 على رأس قائمة التقييم لأي مؤسسة تفكر في التشغيل المحلي والاستضافة الذاتية.

## المراجع

- [مدونة الإعلان الرسمي عن Gemma 4 (Google)](https://blog.google/innovation-and-ai/technology/developers-tools/gemma-4/)
- [بطاقة نموذج Gemma 4 (Google AI for Developers)](https://ai.google.dev/gemma/docs/core/model_card_4)
- [وثائق نظرة عامة على نموذج Gemma 4](https://ai.google.dev/gemma/docs/core)
- [مجموعة google/gemma-4 على Hugging Face](https://huggingface.co/collections/google/gemma-4)
- [مكتبة Gemma على GitHub من Google DeepMind](https://github.com/google-deepmind/gemma)
- [توفّر Gemma 4 على Google Cloud](https://cloud.google.com/blog/products/ai-machine-learning/gemma-4-available-on-google-cloud)
