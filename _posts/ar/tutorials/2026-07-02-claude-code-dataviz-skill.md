---
title: "مهارة /dataviz في Claude Code: التعامل مع الرسوم البيانية كتصميم لا كمجرد كود"
excerpt: "مهارة /dataviz المضافة في الإصدار 2.1.198 من Claude Code تحمّل إرشادات تصميم الرسوم البيانية ولوحات المعلومات مباشرة إلى السياق. نستعرض قاعدة الشكل، وصيغة اللون، ومدقق لوحة الألوان القابل للتشغيل، ثم ننظر في كيفية استفادة منصة ThakiCloud منها."
tags:
  - claude-code
  - dataviz
  - data-visualization
  - dashboard
  - skill
date: 2026-07-02
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/claude-code-dataviz-skill/"
header:
  image: /assets/images/claude-code-dataviz-skill-hero.png
categories:
  - tutorials
---

## نظرة عامة

بإمكان أي شخص أن يكتب كوداً يرسم رسماً بيانياً. استخراج رسم أعمدة من `matplotlib` أو ربط لوحة معلومات باستخدام Recharts لا يتطلب أكثر من بضعة أسطر. المشكلة أن معظم ما ينتج عن هذه العملية لا يُقرأ فعلياً. محور لا يبدأ من الصفر يبالغ في الفروقات، ولون مختلف لكل سلسلة بيانات يضطرك لمراجعة وسيلة الإيضاح ثلاث مرات، والانتقال إلى الوضع الداكن يفقد التباين حتى تختفي الحروف. الكود يعمل، لكن الصورة لا تساعد أحداً على اتخاذ قرار.

أضاف Claude Code في إصداره 2.1.198 مهارة مدمجة باسم `/dataviz` تستهدف هذه الفجوة تحديداً. سجل التغييرات الرسمي وصفها في سطر واحد مختصر بأنها تقدّم "إرشادات تصميم الرسوم البيانية ولوحات المعلومات"، لكن ما تفعله فعلياً هو إعادة الرسم البياني من مشكلة برمجية إلى مشكلة تصميم. قبل كتابة أي سطر كود، تحمّل إلى السياق إرشادات حول أي شكل يُختار، وكيف يُخصص اللون، وكيف تُحمى إمكانية الوصول. تستحق هذه المهارة وقفة متأنية لأنها تقلب الترتيب المعتاد "ارسم أولاً ثم حسّن لاحقاً"، وهو الترتيب الذي كان يتكرر كلما بنينا لوحة استهلاك وحدات معالجة رسومية أو تقرير تقييم نموذج داخل ThakiCloud.

## ما هي مهارة /dataviz

`/dataviz` هي مهارة مرجعية يُفترض قراءتها قبل بناء أي رسم بياني أو رسم أو لوحة معلومات، في أي وسيط إخراج. لا يهم إن كانت الوجهة عنصر HTML أو React، أو SVG مضمّن، أو كوداً في مكتبة مثل `matplotlib` أو `plotly` أو d3 أو Recharts، أو صورة PNG سيتم عرضها ورفعها، أو رسماً بياناً سيُشارَك في Slack. صُممت لتُحمَّل قبل كتابة أول سطر من كود الرسم، وقبل اختيار ألوان الرسم، وقبل ترتيب بطاقة مؤشر أداء أو مقياس أو صف من المؤشرات.

النقطة الجوهرية أنها غير مرتبطة بأي نظام تصميم محدد. تقدّم المهارة لوحة ألوان محايدة العلامة التجارية كقيمة افتراضية، وتوجّهك لاستبدال تلك القيم بألوان علامتك التجارية الخاصة. بعبارة أخرى، هي أقرب إلى "استخدم هذه الطريقة في اختيار الألوان" من "استخدم هذا اللون". ولأنها تعلّم منهجية، ينطبق الانضباط نفسه حتى وإن اختلفت لوحة الألوان من مشروع لآخر.

يتضح نطاق المهارة عند النظر إلى ما يستدعيها. فكلمات مثل رسم بياني، رسم، مخطط، تصور بيانات، ولوحة معلومات تستدعيها، وكذلك كل عنصر فردي من عناصر التصور: اللون الفئوي، اللوحات التدرجية والمتباينة، بطاقات المؤشرات، الرسوم النبضية، الخرائط الحرارية، وسائل الإيضاح، المحاور، والتلميحات. سواء كنت ترسم رسماً بياناً كاملاً أو تضع صفاً واحداً من مؤشرات الأداء، فإنك تمر بالإرشادات نفسها في الحالتين.

## ما الذي تحمّله هذه المهارة إلى السياق

تنقسم الإرشادات التي تحمّلها `/dataviz` إلى أربع كتل: قاعدة الشكل، وصيغة اللون، ومدقق قابل للتشغيل، ومواصفات العلامات مع قواعد التفاعل.

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
<div class="d3-arch" data-arch-root id="02claudecodedatavizskill-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 327, "height": 1042, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 205, "h": 78, "title": ["طلب التصور", "(رسم بياني، لوحة معلومات،", "مؤشر أداء)"]}, {"id": "B", "x": 28, "y": 180, "w": 198, "h": 62, "title": ["قاعدة الشكل", "شكل البيانات ← شكل الرسم"]}, {"id": "C", "x": 24, "y": 320, "w": 205, "h": 62, "title": ["صيغة اللون", "تخصيص فئوي، تدرجي، متباين"]}, {"id": "D", "x": 104, "y": 460, "w": 191, "h": 78, "title": ["تشغيل مدقق لوحة الألوان", "فحص التباين وإمكانية", "الوصول"]}, {"id": "E", "x": 47, "y": 616, "w": 160, "h": 52, "title": "هل اجتاز التحقق؟"}, {"id": "F", "x": 28, "y": 760, "w": 198, "h": 94, "title": ["مواصفات العلامات + قواعد", "التفاعل", "المحاور، وسيلة الإيضاح،", "التلميحات"]}, {"id": "G", "x": 38, "y": 932, "w": 177, "h": 78, "title": ["تصور متسق", "نفس النظام في الوضعين", "الفاتح والداكن"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [127, 102, 127, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [127, 242, 127, 320]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[159, 382], [199, 421], [199, 421], [199, 460]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[199, 538], [199, 577], [199, 577], [156, 616]]}, {"src": "E", "dst": "C", "kind": "data", "label": "\"لا\"", "curve": [[97, 616], [54, 577], [54, 421], [94, 382]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "\"نعم\"", "line": [127, 668, 127, 760], "lx": 127, "ly": 710}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 854, 127, 932]}]});
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
      const container = document.getElementById('02claudecodedatavizskill-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '02claudecodedatavizskill-1';
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

**قاعدة الشكل** هي مجموعة القواعد التي تحدد شكل الرسم البياني بناءً على شكل البيانات. فإن كانت البيانات سلسلة زمنية، أو توزيعاً، أو علاقة جزء بكل، أو بيانات جغرافية، فإن العلامة المناسبة تختلف تبعاً لذلك. وجود هذه الخطوة هو ما يسمح بكسر عادة اللجوء تلقائياً إلى الرسم الدائري. المبادئ المتراكمة منذ زمن طويل في مجال تصور البيانات، مثل سبب كون الرسم الدائري خياراً سيئاً في معظم الحالات، وسبب وجوب بدء محور رسم الأعمدة من الصفر، مُقننة هنا كقواعد عملية. إنها في جوهرها المعايير التي وضعها أشخاص مثل إدوارد تافتي وكول نوسباومر كنافليك، منقولة إلى قواعد عمل ضمن مهارة.

**صيغة اللون** تعامل اللون كجزء من البيانات لا كزخرفة. تُخصص ألواناً متمايزة بوضوح للبيانات الفئوية، وألواناً تتدرج تدريجياً في السطوع للبيانات التدرجية، وألواناً تتباعد من نقطة مركزية في اتجاهين للبيانات المتباينة. بدلاً من اختيار لون عشوائي لكل سلسلة، تُوائم اللون مع البنية المعنوية للبيانات.

**مدقق لوحة الألوان القابل للتشغيل** هو نقطة التمايز الحقيقية لهذه المهارة. لا تتوقف عند تقديم إرشاد لاختيار الألوان، بل تفحص بالكود ما إذا كانت اللوحة المختارة تُقرأ فعلياً. يفحص المدقق تباين الألوان وإمكانية الوصول ليحدد ما إذا كان النص والعلامات متمايزين بما يكفي في كل من الوضع الفاتح والوضع الداكن. ولأن فحصاً حتمياً هو من يملك قرار النجاح أو الفشل بدلاً من تقدير بشري عابر، يُستبعد الحكم الذاتي من نوع "يبدو جيداً". اللوحة الافتراضية موثقة في `references/palette.md` بقيم اجتازت التحقق فعلاً، وكل ما يلزم هو استبدال تلك القيم بألوان علامتك التجارية.

**مواصفات العلامات وقواعد التفاعل** توحّد تفاصيل الرسم البياني. قرارات مثل كيفية رسم المحاور، وأين توضع وسيلة الإيضاح، وماذا يُدرج في التلميح، تُثبَّت كقواعد بدلاً من اتخاذها من جديد في كل مرة. والنتيجة أن رسوماً بيانية صنعها أشخاص مختلفون بمكتبات مختلفة تبدو وكأنها نظام واحد.

## كيف تُستخدم فعلياً

الاستخدام بحد ذاته بسيط. حمّل المهارة قبل البدء في بناء رسم بياني أو لوحة معلومات، فتدخل إرشادات الكتل الأربع أعلاه إلى السياق. بعد ذلك، أياً كانت المكتبة المستخدمة، يُولَّد الكود على أساس الانضباط نفسه.

النقطة التي يجب الانتباه إليها هي الترتيب. ما يؤكده وصف المهارة مراراً هو قراءتها "قبل كتابة أول سطر من كود الرسم". تصحيح اللون بعد كتابة الكود بالكامل يأتي متأخراً جداً. تصحيح رسم أعمدة لم يبدأ محوره من الصفر بعد الانتهاء منه يعني عادة إعادة العمل على المقياس والتخطيط من جديد، ومشكلات تباين الوضع الداكن غالباً ما تعني إعادة بناء لوحة الألوان بأكملها. وضع قرار التصميم في المقدمة يجعل هذا التكرار في العمل يختفي.

كون الإرشادات نفسها تنطبق على الرسوم البيانية المشاركة عبر Slack أمر مفيد بشكل خاص في الممارسة العملية. الرسم البياني المرتجل الملصق في قناة الفريق عادة ما يعاني من إشكالية مزدوجة: الأكثر إهمالاً في صنعه والأكثر انتشاراً في قراءته. وحين يمر عبر هذه المهارة، حتى هذا النوع من الرسوم يخضع للقواعد نفسها التي تخضع لها لوحة معلومات رسمية.

## دلالات على منتجات ThakiCloud

الرسالة التي تحملها `/dataviz` تتطابق تماماً مع المبدأ الذي تمارسه ThakiCloud بالفعل في منتجَين: عدم ترك التنسيق والجودة لارتجال النموذج، بل جعله يملأ هيكلاً مُتحقَّقاً منه.

من **زاوية ai-platform**، نقوم باستمرار بتصور مؤشرات مثل استهلاك وحدات معالجة الرسومات، وحالة طابور Kueue، وزمن استجابة تقديم النماذج، والتكلفة لكل مستأجر، فوق بنيتنا التحتية للذكاء الاصطناعي والتعلم الآلي القائمة على K8s. لوحات المراقبة هذه هي شاشات يحتاج فيها المشغّل إلى رصد أي خلل خلال ثوانٍ، لذا فإن التسلسل الهرمي البصري يترجم مباشرة إلى سرعة الاستجابة. تدفق يختار رسماً بيانياً يلائم طبيعة كل مؤشر عبر قاعدة الشكل، ويميّز الحالات الطبيعية والتحذيرية وحالات العطل عبر معنى اللون بواسطة صيغة اللون، ويضمن تباين الوضع الداكن عبر المدقق، يرفع مباشرة من موثوقية لوحة العمليات. انضباط استخدام اللون كإشارة حالة لا كزخرفة يقلل من سوء التقدير أثناء الاستجابة أثناء المناوبة.

من **زاوية Paxis**، تمثل `/dataviz` بحد ذاتها نموذجاً مصغراً لما نبنيه من سحابة أصيلة للعملاء الوكلاء. Paxis هو مستوى تحكم الوكلاء الذي يعمل فوق ai-platform، يعامل المهارات كموارد من الدرجة الأولى ويختار من بين نحو 960 مهارة باستخدام BM25 لتشغيلها في بيئة معزولة. الطريقة التي تحزم بها `/dataviz` "القدرة على رسم رسم بياني" في مهارة واحدة وتحمّلها إلى السياق عند الحاجة هي البنية نفسها التي يعتمدها Skill Harness في Paxis، والذي يجمع المعرفة والانضباط في وحدات مهارات قابلة لإعادة الاستخدام. ومدقق لوحة الألوان القابل للتشغيل تحديداً هو النسخة الخاصة بتصور البيانات من مبدأ حافظنا عليه عبر عدة مهارات دفعية: الأرقام والأحكام لا يدّعيها النموذج، بل يملكها الكود الحتمي. النموذج يقترح لوناً، والكود يفحص ما إذا كان هذا اللون يُقرأ فعلياً. من دون هذا الفصل، لا يمكن للمخرجات التي ينتجها أشخاص متعددون ووكلاء متعددون أن تتقارب في نظام واحد.

الزاويتان تكمّلان بعضهما. ai-platform يستخرج المؤشرات، وPaxis يشغّل بأمان المهارة التي تعرض تلك المؤشرات بلغة بصرية متسقة. البنية التحتية منخفضة التكلفة تجعل قابلية المراقبة رخيصة، وحاضنة المهارات تحوّل تلك المراقبة إلى صورة يمكن قراءتها فعلاً.

## الحدود والحجج المضادة

`/dataviz` ليست حلاً سحرياً. ما تحمّله المهارة هو إرشاد، وليس إكمالاً تلقائياً، لذا لا يزال على إنسان أو وكيل أن يكتب الرسم البياني فعلياً. وإن تجاهل أحدهم الإرشاد وكتب الكود أولاً على أي حال، يفقد استدعاء المهارة معناه. انضباط الترتيب ليس شيئاً تفرضه الأداة من تلقاء نفسها.

هناك أيضاً كلفة في استهلاك السياق. تحميل المهارة يستهلك رموزاً. تحميل الإرشاد الكامل في كل مرة من أجل رسم بياني يكفي رسمه بسرعة قد يكون مبالغاً فيه. تستحق قيمتها في لوحات المعلومات والتقارير حيث الجودة هي جوهر المخرج، لكن لا مبرر لفرضها قسراً على رسم مؤقت لمرة واحدة.

كون اللوحة الافتراضية محايدة العلامة التجارية سيف ذو حدين أيضاً. استخدامها كما هي من دون استبدال يعطي رسماً بيانياً باهتاً لا هوية له، لا يمكن تمييز الشركة التي أنتجته. تخطي خطوة استبدال قيم `references/palette.md` بعلامتك التجارية يمنحك الاتساق لكنه يفقدك الهوية. المهارة تمنح المنهجية، والقرار الأخير بإضفاء العلامة التجارية يبقى مسؤوليتنا.

## المصادر

- [سجل تغييرات Claude Code CLI 2.1.198 (ClaudeCodeLog على X)](https://github.com/anthropics/claude-code/blob/main/CHANGELOG.md)
- وصف مهارة `dataviz` المدمجة في Claude Code وملف `references/palette.md`
