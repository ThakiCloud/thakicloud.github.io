---
title: "ذكاء يعمل في المنزل: حاسوب الذكاء الاصطناعي الشخصي واقتصاديات التشغيل داخل المؤسسة"
excerpt: "انطلاقًا من أدلة بناء حاسوب الذكاء الاصطناعي الشخصي التي شاركها tom_doerr والتي تصل إلى 384GB من ذاكرة VRAM، نحسب كيف تحدد ذاكرة VRAM النماذج التي يمكن تشغيلها فعليًا، ونوضح ما يلزم لتوسيع هذا الجهاز المنزلي الواحد إلى تشغيل بمستوى المؤسسة من منظور منصة ai-platform لدى ThakiCloud."
tags:
  - on-premise
  - vram
  - gpu
  - self-hosting
  - vllm
  - open-weights
date: 2026-07-04
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/personal-ai-computer-onprem-vram/"
categories:
  - llmops
---

في الأيام القليلة الماضية انتشر بهدوء مشروع على خطوط زمنية المطورين. إنه "حاسوب الذكاء الاصطناعي الشخصي": فبدلًا من استئجار واجهة برمجية سحابية، تقوم بتجميع جهاز ذكاء اصطناعي في المنزل أو المكتب وتشغّل النماذج مفتوحة الأوزان بالكامل على عتاد تملكه أنت. تصل الأدلة إلى 384GB من ذاكرة VRAM، وهو ما يطرح سؤالًا عمليًا للغاية: عند هذه السعة، ما النماذج التي يمكن تشغيلها محليًا فعلًا؟ هذا المقال موجّه إلى قادة الهندسة وفرق منصات تعلم الآلة الذين يقيّمون بنية الذكاء الاصطناعي داخل المؤسسة، وإلى علماء البيانات الراغبين في تشغيل النماذج محليًا. نستخدم الحساب للتأكد من كيفية تحديد ذاكرة VRAM لجدوى النماذج، ونتناول ما الذي يتغير عند توسيع جهاز شخصي واحد إلى تشغيل بمستوى المؤسسة، إلى جانب منظور منصة ai-platform لدى ThakiCloud.

لأبدأ بالخلاصة. تُحدَّد جدوى الذكاء الاصطناعي المحلي في معظمها بمتغير واحد: ذاكرة VRAM. وما يثبته البناء الشخصي هو أنه "ممكن تقنيًا"، لا أن "المؤسسة تستطيع تشغيله كما هو". وهذه الفجوة هي بالضبط سبب وجود منصات التشغيل داخل المؤسسة.

## ما هذه التقنية

المستودع في قلب النقاش هو `autonomous-ai/autonomous-computer`، وهو دليل مفتوح المصدر صادر برخصة MIT لبناء حاسوب ذكاء اصطناعي في المنزل من الصفر. ما يميزه أنه لا يشرح بالنص وحده. يأتي كل بناء مع قائمة مواد (BOM) تحمل الأسعار وروابط الشراء، وملفات ثلاثية الأبعاد (STL و STEP) لطباعة الهيكل أو تصنيعه، ومخطط أسلاك، وقيم ضبط BIOS، وصور تجميع خطوة بخطوة. أما جانب البرمجيات فيمتد من تثبيت نظام التشغيل وبرامج تعريف NVIDIA، مرورًا بثلاثة محركات استدلال (Ollama و vLLM و llama.cpp)، وصولًا إلى ربط وكيل محلي.

تُقدَّم ثلاثة تكوينات.

- **Home**: بطاقتا RTX 5090، بإجمالي 64GB من VRAM
- **Business**: تكوين من 8 بطاقات GPU، بإجمالي نحو 256GB من VRAM
- **Team**: أربع بطاقات RTX PRO 6000 Blackwell، بإجمالي 384GB من VRAM

الفلسفة التي يؤكد عليها المشروع باستمرار هي "امتلك ذكاءك". فالنموذج الذي تستأجره من السحابة قد يختفي بين ليلة وضحاها عند تغيّر سياسة أو إيقاف خدمة، بينما لا يحدث ذلك لنموذج يعمل في منزلك. إنه موقف يتعلق بتأمين سيادة البيانات والتحكم على مستوى العتاد، وهو ينسجم تمامًا مع تنامي الإقبال على التشغيل داخل المؤسسة.

يبدو التدفق الكلي على النحو التالي.

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
<div class="d3-arch" data-arch-root id="onalaicomputeronpremvram-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 549, "height": 912, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 168, "y": 24, "w": 198, "h": 62, "title": ["تحديد الميزانية والنموذج", "المستهدف"]}, {"id": "B", "x": 189, "y": 164, "w": 156, "h": 46, "title": "تقدير ميزانية VRAM"}, {"id": "C", "x": 198, "y": 288, "w": 139, "h": 52, "title": "أي تكوين بناء"}, {"id": "D", "x": 382, "y": 432, "w": 135, "h": 62, "title": ["Home", "بطاقتا RTX 5090"]}, {"id": "E", "x": 207, "y": 432, "w": 120, "h": 62, "title": ["Business", "8 بطاقات GPU"]}, {"id": "F", "x": 24, "y": 432, "w": 128, "h": 62, "title": ["Team", "4 RTX PRO 6000"]}, {"id": "G", "x": 179, "y": 572, "w": 177, "h": 46, "title": "اختيار محرك الاستدلال"}, {"id": "H", "x": 287, "y": 710, "w": 156, "h": 46, "title": "Ollama / llama.cpp"}, {"id": "I", "x": 112, "y": 710, "w": 120, "h": 46, "title": "vLLM"}, {"id": "J", "x": 193, "y": 834, "w": 149, "h": 46, "title": "ربط الوكيل المحلي"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [267, 86, 267, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [267, 210, 267, 288]}, {"src": "C", "dst": "D", "kind": "data", "label": "64GB", "curve": [[333, 340], [450, 386], [450, 386], [450, 432]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "256GB", "line": [267, 340, 267, 432], "lx": 267, "ly": 382}, {"src": "C", "dst": "F", "kind": "data", "label": "384GB", "curve": [[202, 340], [88, 386], [88, 386], [88, 432]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[450, 494], [450, 533], [450, 533], [335, 572]]}, {"src": "E", "dst": "G", "kind": "data", "line": [267, 494, 267, 572]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[88, 494], [88, 533], [88, 533], [201, 572]]}, {"src": "G", "dst": "H", "kind": "data", "label": "تشغيل محلي بسيط", "curve": [[300, 618], [365, 664], [365, 664], [365, 710]], "off": "50%"}, {"src": "G", "dst": "I", "kind": "data", "label": "خدمة عالية الإنتاجية", "curve": [[235, 618], [172, 664], [172, 664], [172, 710]], "off": "50%"}, {"src": "H", "dst": "J", "kind": "data", "curve": [[365, 756], [365, 795], [365, 795], [303, 834]]}, {"src": "I", "dst": "J", "kind": "data", "curve": [[172, 756], [172, 795], [172, 795], [232, 834]]}]});
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
      const container = document.getElementById('onalaicomputeronpremvram-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'onalaicomputeronpremvram-1';
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

## ذاكرة VRAM تحدد الجدوى

أيّ نموذج يعمل محليًا يعود عمليًا إلى ذاكرة VRAM وحدها. القاعدة التقريبية التي استقر عليها المجتمع واضحة. عند FP16 (نصف الدقة) تحتاج إلى نحو 2GB لكل مليار معامل؛ وعند التكميم من فئة INT4 (Q4) نحو 0.5GB؛ وفوق ذلك تضيف 15 إلى 20 بالمئة لذاكرة KV cache والتنشيطات وحمل إطار العمل. بعبارة أخرى، عند Q4 يكون الحد الأدنى من VRAM تقريبًا "عدد المعاملات (B) × 0.5 × 1.2".

يعطي تطبيق هذه الصيغة على أحجام نماذج تمثيلية الجدول أدناه. وتتضمن هذه القيم حمل الـ 20 بالمئة.

| حجم النموذج | VRAM عند Q4 | VRAM عند Q8 |
|---|---|---|
| 8B | 5GB | 10GB |
| 32B | 19GB | 38GB |
| 70B | 42GB | 84GB |
| 122B | 73GB | 146GB |
| 235B | 141GB | 282GB |
| 405B | 243GB | 486GB |

هذا الحساب ليس اختراعًا اعتباطيًا؛ بل يتقاطع مع أدلة منشورة. فتشغيل Llama 3 70B عند Q4_K_M يُبلَّغ عنه بأنه يحتاج نحو 40 إلى 43GB، وهو ما يطابق القيمة المحسوبة 42GB. ويُقال إن نموذجًا من فئة 122B مثل Qwen 3.5 122B يحتاج 70 إلى 81GB عند Q4، والقيمة المحسوبة 73GB تقع ضمن هذا النطاق. أما Llama 3.1 405B فيصل إلى 243GB عند Q4، وهو ما يطابق الجدول تمامًا. وللإشارة، فإن Q4_K_M هو المعيار المجتمعي الذي يكاد لا يُميَّز عن Q8 في معظم المهام، مع ارتفاع في الحيرة (perplexity) بنحو 0.2 إلى 0.5 فقط مقارنةً بـ FP16.

## ما الذي يشغّله كل بناء فعليًا

بمطابقة متطلبات VRAM المحسوبة على خطوط السعة للتكوينات الثلاثة، تتضح الصورة.

![ذاكرة VRAM المطلوبة حسب حجم النموذج والتكميم، مع خطوط سعة التكوينات الثلاثة]({{ '/assets/images/personal-ai-computer-onprem-vram-results.webp' | relative_url }})

يعمل النموذج على تكوين معيّن حين يقع عموده تحت خط سعة ذلك التكوين. وباختصار:

- **Home (64GB)**: يستوعب بأريحية 70B عند Q8 و 122B عند Q4. وهذا يكفي للتجارب الشخصية ومساعدة البرمجة لفريق صغير.
- **Business (256GB)**: يمكنه دفع نموذج من فئة 235B قريبًا من Q8، وهو مناسب لإبقاء عدة نماذج متوسطة مقيمة في آنٍ واحد لأغراض التوجيه.
- **Team (384GB)**: يحمّل 405B عند Q4 (243GB) ويبقى لديه 141GB. وهذا الفائض هو ما يمتص فعليًا ذاكرة KV cache للسياقات الطويلة والطلبات المتزامنة.

هناك نقطة يسهل إغفالها هنا. الأرقام في الجدول ليست سوى "الحد الأدنى اللازم لتحميل الأوزان". في الاستخدام الفعلي، ومع نمو طول السياق وعدد المستخدمين المتزامنين، تتضخم ذاكرة KV cache بأسرع من الخطي وتلتهم ميزانية VRAM. فتكوين "يكاد يتسع" فيه 405B وآخر "يخدمه بمساحة فائضة" قصتان مختلفتان تمامًا.

## دلالات لـ ThakiCloud

ما يثبته حاسوب الذكاء الاصطناعي الشخصي قوي لكنه محدود أيضًا، لأنه لا يصح إلا ضمن مقدمات جهاز واحد ومستخدم واحد وتشغيل يدوي. وفي لحظة توسيع هذا "الجهاز الواحد في المنزل" إلى حجم المؤسسة، تظهر مجموعة مختلفة تمامًا من المشكلات، وهذا بالضبط هو المجال الذي تعالجه منصة **ai-platform** لدى ThakiCloud.

تصف منصة ai-platform وحدات GPU وتجدولها باستخدام Kueue فوق Kubernetes، وتخدم النماذج بتعدد المستأجرين عبر vLLM. في البناء الشخصي يحتكر شخص واحد أربع بطاقات GPU، أما في المؤسسة فتتنافس فرق متعددة ونماذج متعددة على مجمّع GPU نفسه. وما يلزم حينها هو عزل المستأجرين، والاصطفاف العادل، والجدولة القائمة على الأولوية، ومراقبة الاستخدام والتكلفة. فالقرار اليدوي في البناء الشخصي بـ"تحميل هذا النموذج فقط الآن" هو ما تُؤتمِته المنصة عبر السياسة والمجدول.

وتشير الاقتصاديات في الاتجاه نفسه. فإذا كان "امتلك ذكاءك" في البناء الشخصي هو منطق تأمين سيادة البيانات والتحكم عبر العتاد، فإن منصة ai-platform تحقق المنطق نفسه على نطاق المؤسسة. إن النشر داخل المؤسسة والسيادي، وانخفاض تكلفة الخدمة لكل وحدة، والتحكم في البيانات عبر الاستضافة الذاتية، أمور تحمل وزنًا خاصًا في بيئات العملاء التي يجب أن تلبي المتطلبات التنظيمية المحلية. كما أن رفع معدل استغلال وحدات GPU من فئة RTX PRO 6000، التي يصعب على فرد تبريرها، عبر مشاركتها بين أعباء عمل كثيرة، هو أمر لا تقدر عليه سوى منصة.

وإن كنت تشغّل وكلاء فوق نماذج محلية، فإن منظور **Paxis** لدى ThakiCloud يتقاطع أيضًا. فـ Paxis هي مستوى تحكم من نوع Agent-Native Cloud يعمل فوق منصة ai-platform، وينفّذ المهارات في صناديق رمل معزولة ويمرّر كل فعل عبر بوابة سياسة وسجل تدقيق. أرفق مستوى تحكمك الخاص بنموذج يعمل على عتادك الخاص، وستمتد فلسفة البناء الشخصي في "امتلاك الذكاء" إلى حوكمة على مستوى المؤسسة.

## الحدود والحجج المضادة

قبل تبنّي رومانسية البناء الشخصي، تستحق بعض الحقائق الانتباه.

أولًا، تكلفة العتاد نفسه وعبء تشغيله. فتكوين من أربع بطاقات RTX PRO 6000 Blackwell يحمل نفقات رأسمالية أولية كبيرة، وتتبعه باستمرار الطاقة والحرارة والضوضاء والصيانة. كما أن الجهاز الواحد هو نقطة فشل واحدة.

ثانيًا، هناك حالات لا تزال السحابة فيها منطقية بوضوح. فأعباء العمل المتقطعة ذات الاستخدام غير المنتظم، والمهام التي تتطلب فعلًا أحدث نموذج متقدم، والخدمات العالمية منخفضة الكمون، يصعب خدمتها من صندوق واحد داخل المؤسسة. ونقطة التعادل للتشغيل داخل المؤسسة لا تصح إلا على مقدمة "استغلال مرتفع ومستقر".

ثالثًا، تكميم Q4 ليس مجانيًا. ففي المتوسط يكون فقدان الجودة ضئيلًا، لكن في المهام الحساسة للدقة مثل البرمجة أو الرياضيات قد يظهر التدهور. وكما ذُكر، فإن السياقات الطويلة والتزامن العالي يستنزفان ميزانية VRAM عبر ذاكرة KV cache، مما يخلق وضعًا "تتسع فيه الأوزان لكن الخدمة لا تتسع".

في النهاية، حاسوب الذكاء الاصطناعي الشخصي نقطة انطلاق ممتازة وإثبات مفهوم قوي. لكن كي تنعم مؤسسة بأكملها بالتحكم الذي يقدّمه جهاز شخصي واحد، وبطريقة مستقرة، فهي تحتاج إلى طبقة منصة فوقه تضيف العزل والجدولة والمراقبة والحوكمة. إن الإجابة على السؤال الذي يطرحه البناء الشخصي ("هل يمكنك امتلاك ذكائك؟") على نطاق المؤسسة هي المشكلة التي تحلّها منصات الذكاء الاصطناعي داخل المؤسسة.

## المصادر

- [autonomous-ai/autonomous-computer (GitHub)](https://github.com/autonomous-ai/autonomous-computer)
- [Autonomous Computer: Build Your Own Home AI (writeup)](https://pasqualepillitteri.it/en/news/4998/autonomous-computer-build-home-ai-locally)
- [Best Local AI Models by VRAM: 8GB to 384GB (2026)](https://www.modemguides.com/blogs/ai-infrastructure/best-local-ai-models-by-vram-2026)
- [GPU Memory Requirements for LLMs (Spheron)](https://www.spheron.network/blog/gpu-memory-requirements-llm/)
- [Build an AI PC in 2026: Complete Hardware Guide (Local AI Master)](https://localaimaster.com/blog/ai-pc-build-guide)
- شارَكه أصلًا [@tom_doerr، أدلة بناء حاسوب الذكاء الاصطناعي الشخصي](https://x.com/tom_doerr)
