---
title: "مستويات الجهد لمراجعة الكود: أمر /code-review في Claude Code من low إلى ultra"
excerpt: "في الإصدار v2.1.101 أعاد Claude Code تسمية /simplify إلى /code-review وأضاف مستويات الجهد إلى المراجعة. يعيد المستويان low وmedium عددًا قليلًا من النتائج عالية الثقة، بينما يضيف high وmax تغطية أوسع مع نتائج غير مؤكدة، أما ultra فيشغّل مراجعة عميقة تتحقق فيها عدة وكلاء من كل نتيجة على السحابة. ننظر في سبب كون هذا التدرّج هو الطريقة الصحيحة لفصل التكلفة عن الجودة في مراجعة الكود، وكيف تنعكس الفكرة على حزمة المهارات في Paxis."
tags:
  - claude-code
  - code-review
  - effort-levels
  - ultrareview
  - ai-coding
  - agent
  - developer-tools
  - cost-quality
  - paxis
  - dev
date: 2026-07-17
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/claude-code-review-effort-levels/"
categories:
  - dev
---

## نظرة عامة

هناك سؤال يتجاهله الناس عند اختيار أداة مراجعة الكود: كم من المراجعة يحتاجها هذا التغيير فعلًا؟ إن تشغيل الشدة نفسها من المراجعة على تصحيح خطأ مطبعي من سطر واحد وعلى إعادة كتابة منطق الدفع يكون إما هدرًا أو نقصًا. معظم أدوات المراجعة الآلية لا تترك هذا الخيار للمستخدم وتعمل بشدة ثابتة واحدة.

عالج Claude Code هذا الأمر مباشرة في الإصدار v2.1.101. ففي إصدار 11 أبريل 2026 أعاد تسمية الأمر `/simplify` إلى `/code-review` وأضاف علامة مستوى الجهد التي تحكم مدى عمق تفكير النموذج قبل الإجابة. هناك خمسة مستويات، هي low وmedium وhigh وmax وultra، وتُعاد كتابة المراجعة نفسها عند كل مستوى. تُرجع المستويات الضحلة نتائج سريعة عالية الثقة، بينما تنفق المستويات العميقة وقتًا أطول وتمسح الحالات الطرفية والانحدارات الدقيقة.

يقرأ هذا المقال ذلك التصميم من منظور ThakiCloud التي تُشغّل وكلاء برمجة بالذكاء الاصطناعي. ننظر في سبب كون مستوى الجهد هو المحور الصحيح لفصل التكلفة عن الجودة في مراجعة الكود، ومتى نختار كل مستوى عمليًا، وكيف تتداخل الفكرة مع حزمة المهارات وحلقة التحقق في Paxis، منصتنا للوكلاء. المُدد والتكاليف المذكورة أدناه كلها قيم مُبلَّغ عنها من وثائق Anthropic العامة وملاحظات الإصدار، وليست أرقامًا قاسها ThakiCloud.

## ما هي هذه الميزة

`/code-review` أمر خط مائل يقرأ الفرق (diff) في شجرة العمل الحالية، ويجد المشكلات ويُبلّغ عنها. التغيير الجوهري أنه بإمكانك إلحاق مستوى بالأمر. تحديد مستوى مثل `/code-review low` يجعل محرك المراجعة يضبط نطاق استكشافه وعمق تفكيره ليطابق ذلك المستوى. حذف المستوى يشغّل القيمة الافتراضية.

المهم أن المستوى ليس مجرد «إطالة المخرجات أو تقصيرها». وفقًا للوثائق، يعيد low وmedium مجموعة صغيرة من النتائج عالية الثقة، بينما يعيد high وmax نتائج غير مؤكدة إلى جانب النتائج الواثقة. بعبارة أخرى، تفضّل المستويات الضحلة الدقة (precision) وتفضّل المستويات العميقة الاستدعاء (recall)؛ فطبيعة المراجعة نفسها تتغير. وهذا يوافق أيضًا نفسية من يتلقى المراجعة. في رقعة صغيرة، حفنة من النتائج المؤكدة أفضل من قائمة طويلة محشوة بالإيجابيات الكاذبة؛ وقبيل الدمج، عدم تفويت أي شيء أفضل.

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
<div class="d3-arch" data-arch-root id="decoderevieweffortlevels-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 753, "height": 806, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 319, "y": 24, "w": 128, "h": 62, "title": ["تغيير الكود", "فرق شجرة العمل"]}, {"id": "B", "x": 296, "y": 164, "w": 174, "h": 52, "title": "اختيار مستوى الجهد"}, {"id": "C", "x": 530, "y": 308, "w": 191, "h": 62, "title": ["الدقة أولًا", "نتائج قليلة عالية الثقة"]}, {"id": "D", "x": 298, "y": 308, "w": 170, "h": 62, "title": ["الاستدعاء أولًا", "يشمل نتائج غير مؤكدة"]}, {"id": "E", "x": 45, "y": 308, "w": 170, "h": 62, "title": ["صندوق رملي سحابي", "مراجعة وكلاء متوازية"]}, {"id": "F", "x": 530, "y": 448, "w": 191, "h": 62, "title": ["استجابة بمقياس الثواني", "رقعة صغيرة، تغيير إعداد"]}, {"id": "G", "x": 291, "y": 448, "w": 184, "h": 62, "title": ["استكشاف بمقياس الدقائق", "قبيل الدمج، حالة معقدة"]}, {"id": "H", "x": 24, "y": 448, "w": 212, "h": 62, "title": ["التحقق من كل نتيجة مستقلًا", "5-10 دقائق، طبقة مدفوعة"]}, {"id": "I", "x": 281, "y": 588, "w": 205, "h": 46, "title": "‏--comment: تعليق داخل PR"}, {"id": "J", "x": 284, "y": 712, "w": 198, "h": 62, "title": ["‏--fix: التطبيق على شجرة", "العمل"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [383, 86, 383, 164]}, {"src": "B", "dst": "C", "kind": "data", "label": "low / medium", "curve": [[470, 216], [626, 262], [626, 262], [626, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "high / max", "line": [383, 216, 383, 308], "lx": 383, "ly": 258}, {"src": "B", "dst": "E", "kind": "data", "label": "ultra", "curve": [[296, 215], [130, 262], [130, 262], [130, 308]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "line": [626, 370, 626, 448]}, {"src": "D", "dst": "G", "kind": "data", "line": [383, 370, 383, 448]}, {"src": "E", "dst": "H", "kind": "data", "line": [130, 370, 130, 448]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[626, 510], [626, 549], [626, 549], [473, 588]]}, {"src": "G", "dst": "I", "kind": "data", "line": [383, 510, 383, 588]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[130, 510], [130, 549], [130, 549], [289, 588]]}, {"src": "I", "dst": "J", "kind": "data", "line": [383, 634, 383, 712]}]});
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
      const container = document.getElementById('decoderevieweffortlevels-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'decoderevieweffortlevels-1';
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

## متى تستخدم كلًّا من المستويات الخمسة

اختيار المستوى مسألة موازنة بين خطورة التغيير والوقت المتبقي لديك. ترجمةً للطبيعة التي تصفها الوثائق إلى حدس عملي:

يُستخدم low وmedium للفحص السريع للسلامة. استخدمهما قبل دفع تعديل إعداد أو رقعة صغيرة حين تريد فقط تصفية أخطاء الصحة الواضحة. تعود الاستجابات خلال ثوانٍ، فيمكنك تشغيلهما بشكل معتاد قبيل الالتزام دون أن يقطع ذلك انسيابك.

يُستخدم high وmax لمسارات الكود قبيل الدمج أو التي تحمل حالة معقدة. دمج فرع ميزة في main، أو ملامسة مناطق مثل التزامن والمعاملات حيث تختبئ الانحدارات الدقيقة، يقع هنا. تنفق هذه المستويات وقتًا أطول في التحقق من الافتراضات ونبش الحالات الطرفية، فتظهر نتائج موسومة بـ«قد لا تكون مشكلة لكن تحقّق منها» إلى جانب النتائج المؤكدة. سواء عاملت ذلك اللايقين كضجيج أم كشبكة أمان يعتمد على الموقف. قبيل الدمج، تكون شبكة الأمان القراءة الصحيحة.

أما ultra فأداة من نوع مختلف. نتناوله على حدة أدناه.

إذا ضغطت هذا السُّلَّم في جملة واحدة، فهو يقول: طابِق شدة المراجعة مع خطورة التغيير. وهذا بالضبط المبدأ الذي نتبعه عند تشغيل المهارات المجدولة. ابدأ رخيصًا، وارفع فقط المهمة الفاشلة إلى طبقة أغلى. تشغيل كل مراجعة بأقصى شدة يهدر التكلفة، وتشغيل كل مراجعة بأدنى شدة يزرع بذرة حادثة.

## ‏--comment و--fix: وضع المراجعة داخل سير العمل

بمعزل عن مستويات الجهد، تدمج علامتان المراجعة في سير عمل فعلي. تنشر `--comment` النتائج كتعليقات مضمّنة على الـPR، وتطبّق `--fix` النتائج مباشرة على شجرة العمل.

```bash
# مراجعة واسعة قبل الدمج مع تعليقات PR إضافةً إلى التطبيق المحلي
/code-review high --comment --fix

# مراجعة سحابية عميقة، ثم تطبيق النتائج على شجرة العمل
/code-review ultra --fix
```

سير عمل المطوّر الفردي الذي تعرضه الوثائق يجري هكذا. اجمع `--comment --fix` لترك النتائج على الـPR وتطبيقها محليًا، ثم عايِن الفرق وادفع. إنها طريقة لتمرير أول تمريرة مراجعة تلقائيًا دون انتظار مراجِع. مع ذلك، لأن `--fix` تلامس الكود، يجب على إنسان مراجعة الفرق المُطبَّق. التطبيق التلقائي ليس بديلًا عن المراجعة؛ بل هو تحضير لها.

## ‏ultrareview: مراجعة سحابية متعددة الوكلاء

مستوى ultra مختلف عن المستويات الأربعة التي تعمل محليًا. تشغيل `/code-review ultra` يحزم حالة مستودعك، ويرفعها إلى صندوق رملي بعيد، ويترك وكلاء مراجعة متخصصين يحللون الكود بالتوازي هناك. يركّز كل وكيل على صنف مختلف من المشكلات، ويُتحقَّق من النتائج مستقلةً واحدةً تلو الأخرى. وفقًا للوثائق، يستغرق التشغيل من خمس إلى عشر دقائق، وبعد ثلاث تشغيلات مجانية لمشتركي Pro وMax، يكلّف كل تشغيل من خمسة إلى عشرين دولارًا.

يبرز هنا قراران تصميميان. أولًا، تُعالَج المراجعة كتوزّع (fan-out) لعدة وكلاء متخصصين بدل وكيل واحد. وبما أن مراجِعًا واحدًا يصعب عليه التقاط كل صنف من العيوب بالكفاءة نفسها، فإن تقسيم المنظورات حسب نوع المشكلة يوسّع التغطية. ثانيًا، يُتحقَّق من كل نتيجة مستقلةً. التوزّع بذاته يخاطر بتراكم الهلوسات، فلا بد من إغلاقه بمرحلة تحقق قبل الدمج. يُطبّق ultra كلا المبدأين كميزة منتج.

## ماذا يعني هذا لمنتجات ThakiCloud

تتداخل مبادئ تصميم هذه الميزة بشكل لافت مع ما مارسناه في تشغيل منصة وكلاء. نقسّمه على منتجَينا.

**عدسة Paxis.** إن Paxis هي السحابة الأصيلة للوكلاء (Agent-Native Cloud) من ThakiCloud، وتتعامل مع المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. السؤال الذي يطرحه `/code-review` هو نفسه الذي تحلّه حزمة مهارات Paxis كل يوم: أي شدة وكيل تُلحقها بأي مهمة؟ تختار Paxis من أكثر من 960 مهارة عبر BM25 وتشغّلها في صناديق رملية معزولة، وتعمل الفكرة نفسها المتمثلة في مستويات الجهد هنا. يذهب العمل الخفيف مثل الاستكشاف والبحث إلى طبقة رخيصة؛ ويذهب العمل الثقيل مثل الحكم المعماري والتحقق إلى طبقة أغلى. تتشارك مراجعة ultra المتوازية متعددة الوكلاء والتحقق المستقل لكل نتيجة البنية نفسها مع طريقة إغلاق Paxis لنتائج التوزّع بمرحلة تحقق. توزّع بلا تحقق يراكم الهلوسات، وبوابة تحقق توقفه. إذا جرت مراجعة الكود كمهارة وكيل معزولة تمرّ نتائجها عبر بوابات السياسة وسجلات التدقيق، فتلك بالضبط نموذج التشغيل الذي تهدف إليه Paxis.

**عدسة ai-platform.** إن كون ultra يحمّل المراجعة إلى صندوق رملي سحابي ويحاسب لكل تشغيل يؤكد مجددًا أن أعباء عمل الوكلاء تعمل في النهاية على بنية تحتية للـGPU والتنفيذ المعزول. توفّر منصة ai-platform من ThakiCloud جدولة GPU قائمة على K8s وKueue، وعزلًا متعدد المستأجرين، وخدمة داخل المؤسسة (on-premises). إن عبء عمل يشغّل أسطولًا من وكلاء المراجعة بالتوازي هو بالضبط نوع العمل الذي تستهدفه هذه البنية. وللمؤسسات المتحفظة على رفع الشيفرة المصدرية إلى سحابة خارجية خصوصًا، يصبح خيار تشغيل نمط المراجعة نفسه متعدد الوكلاء داخل بنيتها التحتية مهمًا. ولأن اقتصاديات الوكلاء لا تصح إلا حين تتوفّر خدمة منخفضة التكلفة وتنفيذ معزول، تُكمّل العدستان إحداهما الأخرى.

## القيود والاعتراضات

مستويات الجهد ليست دواءً لكل داء. بعض الاعتراضات الصادقة.

أولًا، اختيار المستوى نفسه يعتمد على حكم المستخدم. سوء قراءة الخطورة يمرّر تغييرًا مهمًا بمستوى low، أو يهدر ultra على تغيير تافه. توفّر الأداة المحور؛ أما تحديد موقعك الصحيح عليه فيبقى من شأن الإنسان.

ثانيًا، النتائج غير المؤكدة التي ينتجها high وmax سلاح ذو حدين. قد تعمل كشبكة أمان، لكن إن تراكمت الإيجابيات الكاذبة سبّبت إرهاق المراجعة وانتهى بك الأمر إلى تجاهل القائمة. مقدار الثقة في نتيجة غير مُتحقَّق منها يعتمد على انضباط الفريق.

ثالثًا، يرفع ultra المستودع إلى صندوق رملي بعيد. وللمؤسسات ذات المصدر الحساس، يشكّل ذلك وحده عائق تبنٍّ. كما أن تكلفة الخمسة إلى العشرين دولارًا لكل تشغيل ثقيلة للتشغيل المتكرر، فعلى الفريق أن يحسب اقتصادياته الخاصة بعد التشغيلات المجانية الثلاث.

رابعًا، لا يحلّ `--fix` التلقائي محل المراجعة. الدفع دون فحص الفرق المُطبَّق يدع الأتمتة التي تبدو مريحة تدسّ أخطاءً صامتة بدلًا من ذلك. الأتمتة أداة تساعد التفكير، لا أداة تحلّ محله.

مع ذلك، تشير فكرة مستويات الجهد إلى الاتجاه الصحيح. مطابقة شدة المراجعة مع خطورة التغيير هي بالضبط توازن التكلفة والجودة الذي تعلّمناه من تشغيل الوكلاء.

## المصادر

- [Code Review - Claude Code Docs](https://code.claude.com/docs/en/code-review)
- [Claude Code Review: How to Use /code-review and Ultrareview - Fastio](https://fast.io/resources/claude-code-review-guide/)
- [Claude Code Effort Levels Explained - MindStudio](https://www.mindstudio.ai/blog/claude-code-effort-levels-explained)
