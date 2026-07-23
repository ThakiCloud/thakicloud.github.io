---
title: "التوجيه نحو النموذج الفائز في كل مهمة: قياس حقيقي لخفض تكلفة أتمتة الوكلاء 44 مرة باستخدام النماذج مفتوحة الأوزان"
excerpt: "معظم أعباء عمل أتمتة الوكلاء لا تتطلب استدلالاً عالياً بقدر ما تتطلب استدعاء أدوات وتنفيذ خطوط أنابيب. نجحنا في تحويل طلبات تشغيل حقيقية إلى استدعاءات أدوات باستخدام Gemma 4 بنسبة نجاح 6/6، ثم حسبنا التكلفة الفعلية عند توجيه كل مهمة إلى نموذج مفتوح الأوزان عبر Paxis CostRouter، بالرموز المميزة الحقيقية والأسعار الفعلية."
seo_title: "تحسين تكلفة وكيل النماذج مفتوحة الأوزان: قياس التوجيه حسب المهمة - Thaki Cloud"
seo_description: "تجربة Gemma 4 لاستدعاء الأدوات بنجاح 6/6، وحساب التكلفة الفعلية عبر Paxis models.yaml لتحقيق وفورات تصل إلى 44 مرة مقارنة بنماذج الحدود. ملخص نمط CostRouter لتوجيه أعباء أتمتة الوكلاء إلى النماذج مفتوحة الأوزان بأرقام قياسية حقيقية."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - open-weight
  - cost-optimization
  - model-routing
  - agent-automation
  - gemma4
  - tool-calling
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/open-weight-agent-cost-routing/"
reading_time: true
header:
  image: /assets/images/open-weight-agent-cost-routing-hero.webp
categories:
  - agentops
published: false
---

![صورة مجردة لتدفق المهام عبر منشور ضوئي ينقسم إلى مسارات تكلفة متعددة]({{ '/assets/images/open-weight-agent-cost-routing-hero.webp' | relative_url }})

حين يفتح معظم الفرق فاتورة تشغيل وكلائهم، يقعون في الوهم ذاته: "وكلاؤنا يجرون استدلالاً معقداً، إذاً لا بد من استخدام أفضل النماذج في قمة الهرم." غير أن فحص حركة البيانات الفعلية يكشف صورة مختلفة تماماً. الغالبية العظمى من الطلبات تتمحور حول تحويل اللغة الطبيعية إلى استدعاءات API، وتصنيف السجلات، وربط خطوط الأنابيب، وتلخيص النتائج، وهي مهام متكررة لا تستلزم استدلالاً على مستوى عالمي. ومع ذلك، حين تُعالَج كلها بنماذج حدود مميزة، فإن الفريق يدفع ثمن مواصفات فائضة عن الحاجة.

يوثق هذا المقال قياساً حقيقياً لرصد هذا الهدر ثم التخلص منه. أجرينا تجارب عملية لتحويل طلبات تشغيل حقيقية إلى استدعاءات أدوات باستخدام نموذج مفتوح الأوزان (Gemma 4)، وتحققنا من الجودة، ثم حسبنا إلى أي مدى تنخفض التكاليف عند توجيه كل مهمة إلى النموذج المناسب لها عبر Paxis CostRouter، مستخدمين رموزاً مميزة حقيقية وأسعاراً فعلية. الخلاصة مباشرة: انخفضت التكلفة على نفس عبء العمل بما يصل إلى 44 مرة مقارنة بنماذج الحدود المميزة.

## ما هذا النهج

الفكرة الجوهرية بسيطة. بدلاً من معالجة جميع مهام الوكيل بنموذج واحد، يُوجَّه كل نوع من المهام إلى درجة مختلفة من النماذج بحسب طبيعته. الاستدلال المعقد واتخاذ القرار يذهبان إلى نماذج الحدود المميزة، وتوليد الشيفرة يذهب إلى نماذج مفتوحة الأوزان متخصصة في البرمجة، واستدعاء الأدوات وتنفيذ خطوط الأنابيب يذهبان إلى نماذج مفتوحة الأوزان من الفئة العاملة، والاستخراج والتصنيف الضخم يذهبان إلى الفئة الاقتصادية الأرخص. إن أرسلت كل مهمة إلى النموذج الأنسب لها، حافظت على الجودة وخففت الفاتورة.

لكي ينجح هذا النهج، لا بد أن يصح أمران: أولاً، أن تكون النماذج مفتوحة الأوزان قادرة فعلاً على أداء الجزء الأكبر من مهام الوكيل. وثانياً، أن يتولى المنصة عملية التوجيه تلقائياً دون أن يضطر الفريق إلى اختيار النموذج يدوياً في كل مرة. يثبت ما يلي هذين الأمرين بالتجربة والتكوين الفعلي.

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
<div class="d3-arch" data-arch-root id="enweightagentcostrouting-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1016, "height": 682, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 435, "y": 24, "w": 135, "h": 46, "title": "طلب مهمة الوكيل"}, {"id": "B", "x": 423, "y": 148, "w": 160, "h": 52, "title": "تصنيف نوع المهمة"}, {"id": "C", "x": 797, "y": 308, "w": 170, "h": 46, "title": "نماذج الحدود المميزة"}, {"id": "D", "x": 530, "y": 300, "w": 212, "h": 62, "title": ["نماذج مفتوحة الأوزان - فئة", "البرمجة"]}, {"id": "E", "x": 263, "y": 292, "w": 212, "h": 78, "title": ["نماذج مفتوحة الأوزان - فئة", "الوكلاء", "Gemma 4"]}, {"id": "F", "x": 24, "y": 300, "w": 184, "h": 62, "title": ["نماذج مفتوحة الأوزان -", "الفئة الاقتصادية"]}, {"id": "G", "x": 421, "y": 448, "w": 163, "h": 62, "title": ["بوابة السياسة + سجل", "التدقيق"]}, {"id": "H", "x": 414, "y": 588, "w": 177, "h": 62, "title": ["إرجاع النتيجة + تسجيل", "التكلفة"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [503, 70, 503, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "استدلال واتخاذ قرار عالي المستوى", "curve": [[583, 189], [882, 246], [882, 246], [882, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "توليد الشيفرة", "curve": [[551, 200], [636, 246], [636, 246], [636, 300]], "off": "50%"}, {"src": "B", "dst": "E", "kind": "data", "label": "استدعاء أدوات وخطوط أنابيب", "curve": [[454, 200], [369, 246], [369, 246], [369, 292]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "label": "استخراج وتصنيف ضخم", "curve": [[423, 189], [116, 246], [116, 246], [116, 300]], "off": "50%"}, {"src": "C", "dst": "G", "kind": "data", "curve": [[882, 354], [882, 409], [882, 409], [584, 464]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[636, 362], [636, 409], [636, 409], [562, 448]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[369, 370], [369, 409], [369, 409], [443, 448]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[116, 362], [116, 409], [116, 409], [421, 464]]}, {"src": "G", "dst": "H", "kind": "data", "line": [503, 510, 503, 588]}]});
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
      const container = document.getElementById('enweightagentcostrouting-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'enweightagentcostrouting-1';
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

## التثبيت والتكامل

بدأنا بالتحقق من قدرة النماذج مفتوحة الأوزان على أداء المهمة الجوهرية للوكيل، وهي تحويل الطلبات اللغوية الطبيعية إلى استدعاءات أدوات منظمة. كان الهدف التحقق من Gemma 4 بحجم 26 مليار معامل عبر واجهة برمجة تطبيقات مُدارة. صُممت التجربة باستخدام المكتبات القياسية فقط (urllib) دون أي تبعيات إضافية.

المهمة التي أسندناها إلى الوكيل هي مخطط أدوات لخط أنابيب عمليات سحابية. حددنا خمس أدوات: الاستعلام عن المقاييس، وإعادة تشغيل حاويات Pods، وتجميع التكاليف، وتوسيع عمليات النشر، وتدوير الأسرار، ثم طلبنا من الوكيل تحليل طلب لغوي طبيعي وإخراج JSON واحد يتضمن الأداة الصحيحة والمعاملات الإلزامية.

```python
TOOL_SPEC = """You are an operations automation agent. Convert the user request into a single tool-call JSON.
Output only the JSON object, with no explanation or markdown fences.

Available tools and required parameters:
- query_metrics: {metric, window_days, threshold?, region?}
- restart_pods: {region, selector, only_failed(bool)}
- aggregate_cost: {group_by, month, service?}
- scale_deployment: {name, region, replicas}
- rotate_secret: {name, namespace}

Output schema: {"tool": "<name>", "params": { ... }}"""

def call(prompt):
    body = {
        "contents": [{"role": "user",
                      "parts": [{"text": TOOL_SPEC + "\n\nRequest: " + prompt}]}],
        "generationConfig": {"temperature": 0.0, "maxOutputTokens": 1024},
    }
    # call gemma-4-26b-a4b-it via generateContent, capture latency, tokens, and output
```

اصطدمنا هنا بمشكلة عملية تستحق التنبيه. ينتج Gemma 4 رموزاً مميزة للتفكير قبل الإجابة النهائية، وحين يُحدد سقف الإخراج بـ 256 رمزاً تنقطع مرحلة التفكير وتأتي النتيجة الأخيرة فارغة. بمجرد رفع السقف إلى 1024 وتصفية الأجزاء التي تحمل علامة `thought` واستخراج الإجابة الفعلية فقط، عمل النموذج بصورة صحيحة. هذا خطأ شائع يغفل عنه كثيرون عند دمج النماذج مفتوحة الأوزان في خطوط الأنابيب، ولهذا آثرنا توثيقه بكود قياسي فعلي.

أما جانب المنصة فتتولاه كتالوج نماذج Paxis. تتيح Paxis إدارة النموذج المستخدم من أي مزود في ملف تعريفي واحد (`models.yaml`) يتضمن سعر الإدخال والإخراج لكل رمز مميز إلى جانب الدرجة، وهو الأساس الذي يقوم عليه التوجيه.

```yaml
# models.yaml: tier and actual cost per token are the basis for routing (USD / 1M tokens)
- id: claude-opus-4-8      # premium
  tier: premium
  costInput: 5.0
  costOutput: 25.0
- id: claude-sonnet-5      # standard (default)
  tier: standard
  costInput: 3.0
  costOutput: 15.0
# Add open-weight providers (Ollama, vLLM, etc.) with the same schema
# and CostRouter will automatically route tasks to the matching tier.
```

حين تصل مهمة جديدة، يحدد CostRouter درجتها ويختار أرخص نموذج مؤهل من الكتالوج. بمجرد إضافة مزودي النماذج مفتوحة الأوزان بالمخطط ذاته، تتدفق مهام استدعاء الأدوات والمعالجة الضخمة تلقائياً إلى الفئة الاقتصادية الأرخص، دون أن يحتاج الفريق إلى اتخاذ أي قرار يدوي في كل مرة.

## نتائج التجربة الفعلية

قدمنا ستة طلبات تشغيل حقيقية إلى Gemma 4 وقيّمنا النتائج مباشرة بمعيارين: هل الإخراج JSON صالح، وهل يتضمن الأداة الصحيحة مع المعاملات الإلزامية كاملة؟

| المقياس | النتيجة |
|---|---|
| نسبة JSON الصالح | 6/6 (100%) |
| مطابقة المخطط (الأداة + المعاملات الإلزامية) | 6/6 (100%) |
| متوسط وقت الاستجابة | 15.3 ثانية (نقطة نهاية مجانية مشتركة، تشمل رموز التفكير) |
| متوسط رموز الإدخال | 155 |
| متوسط رموز الإخراج | 33 (الإجابة النهائية) |
| متوسط رموز التفكير | 514 |

نجحت الحالات الست جميعها في تحديد الأداة الصحيحة واستكمال المعاملات الإلزامية كاملة. على سبيل المثال، للطلب "أظهر العقد التي تجاوزت فيها نسبة استخدام GPU 80% خلال الأيام السبعة الماضية" أنتج النموذج:

```json
{"tool": "query_metrics", "params": {"metric": "gpu_utilization", "window_days": 7, "threshold": 80}}
```

كان `threshold` معاملاً اختيارياً في المخطط، لكن النموذج استخلص قيمة "80%" من الطلب ووضعها في موضعها الصحيح. وللطلب "زد نسخ نشر inference-api في منطقة ap-northeast إلى 6"، ربط `scale_deployment` بالاسم والمنطقة وعدد النسخ بدقة تامة. هذا قياس نظيف يثبت أن نماذج مفتوحة الأوزان قادرة فعلاً على أداء المهمة الجوهرية لأتمتة الوكلاء، وهي استدعاء الأدوات وتنفيذ خطوط الأنابيب.

متوسط 15.3 ثانية قُيس على نقطة نهاية مشتركة مجانية تشمل رموز التفكير. في بيئة خدمة ذاتية أو معالجة دفعية، ينخفض هذا الرقم بشكل ملحوظ. المهم هنا ليس الكمون المطلق بل الحقيقة الأساسية: الجودة لم تتراجع.

الآن نصل إلى التكلفة. انطلاقاً من ملف تعريف الرموز المميزة المقاسة، افترضنا أن كل مهمة تستهلك 1000 رمز إدخال و300 رمز إخراج وهو سيناريو واقعي لجولة واحدة تشمل موجه النظام ومخطط الأدوات والسياق، مع أسطول وكلاء يعالج 10000 مهمة يومياً على مدى 30 يوماً. استخدمنا أسعار نماذج الحدود من `models.yaml` الفعلي في Paxis، وأسعاراً تقديرية تمثيلية للاستدلال المُدار بالنماذج مفتوحة الأوزان في منتصف عام 2026.

![مخطط مقارنة تكلفة API الشهرية حسب الفئة]({{ '/assets/images/open-weight-agent-cost-routing-results.webp' | relative_url }})

| الفئة | التكلفة لكل مهمة | التكلفة الشهرية (10 آلاف/يوم - 30 يوم) | المقارنة بالمميزة |
|---|---|---|---|
| حدود مميزة | $0.0125 | $3,750 | المرجع |
| حدود قياسية | $0.0075 | $2,250 | أرخص 1.7 مرة |
| حدود اقتصادية | $0.0020 | $600 | أرخص 6.2 مرة |
| نماذج مفتوحة الأوزان مُدارة (مستوى Gemma) | $0.000285 | $86 | أرخص 43.9 مرة |
| نماذج مفتوحة الأوزان اقتصادية | $0.00007 | $21 | أرخص 178.6 مرة |

نفس عبء العمل يكلف $3,750 شهرياً مع النماذج المميزة، مقابل $86 شهرياً مع نماذج مفتوحة الأوزان من مستوى Gemma، أي فارق يبلغ نحو 44 مرة. وكما أثبتت التجربة، بلغت جودة هذه الفئة مفتوحة الأوزان في مهام استدعاء الأدوات 100%. بمعنى آخر، هذا التوفير لم يأتِ على حساب الجودة بل من إزالة المواصفات الفائضة عن الحاجة. قد تتفاوت أسعار النماذج مفتوحة الأوزان بحسب المزود وما إذا كانت ذاتية الاستضافة أم مُدارة، لذلك أشرنا إليها صراحةً بوصفها تقديرية، إلا أن الاتجاه الجوهري، أي وفورات تغير رتبة كاملة، يبقى راسخاً.

## الدلالات التطبيقية لمنتجات ThakiCloud

يتقاطع هذا النمط تقاطعاً دقيقاً مع تصميم Paxis، السحابة الأصيلة للوكلاء من ThakiCloud. تتعامل Paxis مع المهارات والأدوات والسياسات وسجلات التدقيق بوصفها موارد أولى، تماماً كما تتعامل السحابة التقليدية مع الخوادم والشبكات. يعمل CostRouter فوق هذه البنية بوصفه الطبقة التي تختار النموذج الملائم لكل مهمة.

- **التوجيه حسب المهمة وظيفة أساسية.** يمثل `models.yaml` مصدر الحقيقة الوحيد لتحديد المزود والنموذج. بمجرد تسجيل مزودي النماذج مفتوحة الأوزان بالمخطط ذاته، تتدفق مهام استدعاء الأدوات والمعالجة الضخمة تلقائياً إلى الفئة الأرخص. يبقى النموذج القياسي هو الافتراضي، ولا يُستدعى المميز إلا باختيار صريح، مما يمنع التوجيه المفرط من الوقوع بالخطأ.
- **العزل والحوكمة مدمجان.** بصرف النظر عن الفئة الموجه إليها، تمر النتائج جميعها عبر بوابة السياسة وسجل التدقيق. استخدام نموذج أرخص لا يعني إرخاء الرقابة. بل على العكس، يُسجَّل النموذج والرموز المميزة والتكلفة لكل مهمة، مما يتيح تحديد أي المهام تستنزف فئة مكلفة دون مبرر وإعادة توجيهها لاحقاً.
- **التوافق مع متطلبات الاستضافة الذاتية والسيادة الرقمية.** يمكن تشغيل النماذج مفتوحة الأوزان على GPU داخلي، مما يتيح للعملاء الذين لا يمكنهم إخراج البيانات خارجياً تحقيق التوفير والتحكم في آن واحد. تدير منصة ai-platform في ThakiCloud هذه الفئة مفتوحة المصدر بصورة متعددة المستأجرين عبر جدولة GPU المبنية على Kueue وخدمة vLLM، مما يعني أن الكفاءة البنية التحتية لـ ai-platform تدعم كفاءة التوجيه الاقتصادي في Paxis.

خلاصة القول، الرهان الحقيقي ليس "استخدم نماذج أرخص"، بل "استخدم النموذج الفائز في كل مهمة." معظم مهام الوكيل تندرج في استدعاء الأدوات وتنفيذ خطوط الأنابيب، وهي في معظمها لا تتجاوز طاقة النماذج مفتوحة الأوزان.

## القيود والحجج المضادة

لهذا النهج حدود واضحة لا يمكن إغفالها.

في المهام التي تستلزم استدلالاً بالغ التعقيد أو معرفة موسوعية واسعة، لا تزال النماذج مفتوحة الأوزان تقصر عن نماذج الحدود. لذلك يجب أن يكون التوجيه "إلى النماذج مفتوحة الأوزان حيث تتفوق" لا "إلى النماذج مفتوحة الأوزان في كل مكان." القرارات الصعبة تبقى حكراً على الفئة المميزة. إذا أسأ المرء تصميم التوجيه وأرسل مهاماً صعبة إلى فئات رخيصة، فستعود التكاليف محمولةً بأخطاء جودة لا بوفورات.

يصبح تصنيف أنواع المهام بحد ذاته نقطة فشل محتملة. أي خطأ في التصنيف يعني خطأً في التوجيه. لهذا لا بد من مراقبة مستمرة لنتائج التصنيف والجودة الفعلية، مع حلقة مراجعة دورية لإعادة توجيه أنواع المهام التي تتراكم فيها الأخطاء من الفئات الرخيصة إلى مستويات أعلى.

أسعار النماذج مفتوحة الأوزان في هذا المقال تقديرية. تتغير الأرقام المطلقة بحسب ما إذا كانت عبر API مُدار أم استضافة ذاتية، وبحسب المزود. بيد أن أسعار نماذج الحدود المستخدمة هنا حقيقية، والجودة المقاسة فعلية، مما يجعل استنتاج "الوفورات بمقدار رتبة كاملة" صامداً بصرف النظر. ننصح بإعادة هذا الحساب بأسعار بيئتك الفعلية.

أخيراً، الكمون. خمس عشرة ثانية على نقطة نهاية مشتركة مجانية تُعدّ ثقيلة لواجهات مستخدم حوارية آنية. أما خطوط الأنابيب الدفعية والأتمتة في الخلفية فلا تعاني من هذا الأمر. لكن إن كانت الجلسة تنتظر المستخدم، فلا بد من خدمة ذاتية تتحكم في الكمون، أو توجيه تلك المرحلة تحديداً إلى فئة أسرع.

## المصادر

- كود التجربة وسجلات النتائج: تجربة Gemma 4 لاستدعاء الأدوات (6/6 نجاح) موثقة في سجلات قياسية حقيقية ضمن `outputs/blog-impl/open-weight-agent-cost-routing/`.
- أسعار نماذج الحدود: Paxis `models.yaml` (costInput/costOutput، USD لكل مليون رمز مميز).
- أسعار النماذج مفتوحة الأوزان: تقديرات تمثيلية للاستدلال المُدار في منتصف عام 2026 [تقديري].
- [بطاقة نموذج Gemma 4 26B-A4B-it (Hugging Face)](https://huggingface.co/google/gemma-4-26B-A4B-it): تأكيد رسمي لبنية MoE ورموز التفكير ودعم استدعاء الأدوات (tool-call) المدمج.
- [أسعار Claude API (Anthropic)](https://platform.claude.com/docs/en/about-claude/pricing): الصفحة الرسمية لأسعار الإدخال والإخراج لنموذجي Claude Opus 4.8 وSonnet 5.
