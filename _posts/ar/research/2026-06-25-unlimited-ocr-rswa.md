---
title: "قراءة كتاب كامل في تمريرة واحدة: سر ذاكرة KV الثابتة في Unlimited OCR من Baidu"
excerpt: "يستبدل نموذج Unlimited OCR من Baidu انتباه فك التشفير بآلية Reference Sliding Window Attention للحفاظ على ذاكرة KV ثابتة. نشرح كيف يحلل عشرات الصفحات في تمريرة أمامية واحدة وماذا يعني ذلك للاستدلال متعدد المستأجرين في ThakiCloud."
seo_title: "Unlimited OCR R-SWA ذاكرة KV ثابتة لتحليل المستندات الطويلة - Thaki Cloud"
seo_description: "تحليل نموذج Baidu Unlimited OCR (arXiv 2606.23050) وآلية Reference Sliding Window Attention. ذاكرة KV ثابتة تعالج سياق 32K في تمريرة واحدة، 93.23% على OmniDocBench v1.5. منظور استدلال المستندات متعدد المستأجرين على كوبرنيتس في ThakiCloud."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - unlimited-ocr
  - document-parsing
  - sliding-window-attention
  - kv-cache
  - long-context
  - on-premise
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "file-text"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/research/unlimited-ocr-rswa/"
reading_time: true
categories:
  - research
published: false
---

## نظرة عامة

عاد تحويل المستندات إلى بنية قابلة للقراءة آليًا ليكون محوريًا في عصر RAG والوكلاء. قد يمتد عقد واحد إلى عشرات الصفحات، وتحمل التقارير المالية أو الأبحاث جداول ومعادلات وتخطيطات متعددة الأعمدة تتدفق عبر حدود الصفحات. تحتاج هذه المستندات الطويلة إلى تحليلها بالترتيب الصحيح للقراءة، دفعة واحدة، قبل أن يتمكن نموذج اللغة الكبير من استخدامها جيدًا.

المشكلة هي التكلفة. عندما يحلل نموذج اللغة البصري مستندًا، يولّد فك التشفير رموز الإخراج واحدًا تلو الآخر بشكل انحداري ذاتي، ويجعل الانتباه الكامل في المحوّل القياسي ذاكرة KV تنمو خطيًا مع طول التسلسل. ومع تراكم الصفحات تتضخم الذاكرة، ويظهر سقف لطول المستند الذي يمكن معالجته دفعة واحدة. لهذا تقسّم معظم الأدوات الحالية المستندات صفحة بصفحة وتعالجها منفصلة ثم تعيد تجميع النتائج، فتكسر استمرارية الجداول والفقرات التي تعبر حدود الصفحات.

يزيل **Unlimited OCR** من Baidu (arXiv 2606.23050) هذا السقف بطريقة مختلفة. فهو يستبدل كل طبقة انتباه في فك التشفير بآلية Reference Sliding Window Attention (R-SWA)، محافظًا على حجم ذاكرة KV ثابتًا طوال فك التشفير. ونتيجة لذلك يمكنه نسخ عشرات الصفحات من مستند في تمريرة أمامية واحدة ضمن سياق 32K. وعبارة الورقة "التحليل أحادي اللقطة طويل الأفق" ليست مبالغة.

في ThakiCloud نشغّل أحمال الاستدلال متعدد المستأجرين ومعالجة المستندات مباشرة على منصة SaaS للذكاء الاصطناعي والتعلّم الآلي قائمة على كوبرنيتس. في بيئة تأتي فيها حصة كبيرة من تكلفة الاستدلال من ذاكرة KV، فإن "ذاكرة ثابتة بصرف النظر عن الطول" ليست فضولًا أكاديميًا بل موضوعًا يمس اقتصاديات الخدمة مباشرة. يشرح هذا المنشور ما هي R-SWA، ولماذا تبقى ذاكرة KV ثابتة، وأين تناسب من منظور منصتنا.

## ما هو Unlimited OCR

ليس Unlimited OCR نموذجًا بُني من الصفر بل نموذج يدفع DeepSeek-OCR خطوة أبعد. فهو يحتفظ بـ**DeepEncoder** القوي من DeepSeek-OCR كمشفّر له ويستبدل انتباه فك التشفير فقط بـ R-SWA.

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
<div class="d3-arch" data-arch-root id="20260625unlimitedocrrswa-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 458, "height": 948, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 49, "y": 24, "w": 121, "h": 62, "title": ["مستند الإدخال", "(PDF، صورة)"]}, {"id": "B", "x": 42, "y": 164, "w": 135, "h": 62, "title": ["SAM-ViT", "استخراج الميزات"]}, {"id": "C", "x": 45, "y": 304, "w": 128, "h": 62, "title": ["CLIP-ViT", "ضغط الرموز 16×"]}, {"id": "D", "x": 24, "y": 444, "w": 170, "h": 62, "title": ["رموز المرجع البصري", "(256 رمزًا لكل صفحة)"]}, {"id": "E", "x": 154, "y": 584, "w": 138, "h": 52, "title": "انتباه R-SWA"}, {"id": "F", "x": 249, "y": 444, "w": 177, "h": 62, "title": ["نافذة منزلقة", "النص المُولَّد مؤخرًا"]}, {"id": "G", "x": 43, "y": 714, "w": 170, "h": 62, "title": ["فك تشفير MoE", "3B معامل / ~500M نشط"]}, {"id": "H", "x": 254, "y": 854, "w": 149, "h": 62, "title": ["ذاكرة KV ثابتة", "(مستقلة عن الطول)"]}, {"id": "I", "x": 36, "y": 854, "w": 163, "h": 62, "title": ["النص المخرج", "(Markdown / منظَّم)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [109, 86, 109, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [109, 226, 109, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [109, 366, 109, 444]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[109, 506], [109, 545], [109, 545], [178, 584]]}, {"src": "F", "dst": "E", "kind": "data", "curve": [[338, 506], [338, 545], [338, 545], [269, 584]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[185, 636], [128, 675], [128, 675], [128, 714]]}, {"src": "G", "dst": "H", "kind": "data", "line": [174, 776, 286, 854]}, {"src": "G", "dst": "I", "kind": "data", "line": [123, 776, 118, 854]}, {"src": "H", "dst": "E", "kind": "event", "label": "محفوظة", "curve": [[333, 854], [339, 815], [339, 675], [269, 636]], "off": "50%"}]});
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
      const container = document.getElementById('20260625unlimitedocrrswa-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260625unlimitedocrrswa-1';
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

*يضغط DeepEncoder كل صفحة إلى 256 رمزًا بصريًا، ويستوعب فك تشفير R-SWA المستندات الطويلة دفعةً واحدة بذاكرة KV ثابتة. انقر المخطط لتكبيره.*
*يقلّص مشفّر عالي الضغط الصفحة إلى عدد قليل من الرموز البصرية، ويولّد فك تشفير R-SWA مخرجات طويلة بذاكرة KV ثابتة.*

**المشفّر (DeepEncoder)**: يُربط SAM-ViT وCLIP-ViT على التوالي مع تطبيق ضغط رموز بمقدار 16 ضعفًا. تُضغط صفحة PDF واحدة بدقة 1024×1024 إلى 256 رمزًا بصريًا فقط. ولأن عدد الرموز مُقلّص بشدة على جانب الإدخال، تكون كمية المعلومات البصرية التي يجب على فك التشفير الرجوع إليها صغيرة. ويعمل هذا التصميم عالي الضغط مع ذاكرة KV الثابتة المذكورة أدناه لتمكين معالجة المستندات الطويلة.

**فك التشفير (نموذج لغوي بـ R-SWA)**: فك التشفير نموذج خليط خبراء (MoE) بحجم 3 مليار معامل مع نحو 500 مليون معامل مُفعّل. وبما أن مجموعة فرعية فقط من الخبراء تُفعّل لكل رمز بدلًا من الـ 3 مليار كاملة، فإن الحوسبة لكل رمز خفيفة نسبةً إلى عدد المعاملات. وعلاوة على ذلك، يُعد استبدال جميع طبقات الانتباه بـ R-SWA هو الميزة الجوهرية للنموذج.

النموذج الكامل نحو ثلاثة مليارات معامل، صدر بأوزان BF16 تحت رخصة MIT المسموح بها تجاريًا. تتوفر الأوزان على Hugging Face في `baidu/Unlimited-OCR` وعلى ModelScope، منشورة مع الكود على GitHub. وعند الإصدار يعمل وفق التقارير على وحدة معالجة رسوميات NVIDIA متوسطة المدى واحدة.

هذا النموذج من سلالة Baidu نفسها مثل PaddleOCR-VL الذي تناولناه سابقًا، لكن النهج يختلف. يقسم PaddleOCR-VL تحليل التخطيط والتعرف على العناصر إلى مرحلتين لتأمين الاستقرار بنماذج صغيرة، بينما يحتفظ Unlimited OCR بنموذج واحد من طرف إلى طرف لكنه يغيّر آلية الانتباه لملاحقة معالجة المستندات الطويلة دفعة واحدة. ومن الممتع مقارنة فلسفتي تصميم تحلّان المشكلة نفسها.

## الآلية الجوهرية: Reference Sliding Window Attention

لفهم R-SWA انظر أولًا إلى نقاط ضعف نهجين قائمين.

**الانتباه الكامل** يجعل كل رمز إخراج يرى كل رمز سابق. إنه دقيق، لكن ذاكرة KV تنمو بتناسب مع طول التسلسل. ومع زيادة الصفحات تنمو الذاكرة خطيًا وتصطدم بسقف.

**انتباه النافذة المنزلقة العادي (SWA)** يرى فقط آخر W رمزًا. تُثبَّت ذاكرة KV على حجم النافذة فتصبح الذاكرة ثابتة، لكن المعلومات التي تُدفع خارج النافذة تُنسى. ينفع هذا في توليد النص العام، لكنه قاتل في OCR حيث يجب "النظر إلى المصدر ونسخه بأمانة". فبمجرد أن تتجاوز النافذة، تفقد دليل أي صفحة كنت تنسخها.

تجمع R-SWA بين الأمرين. وفكرتها الأساسية تأتي من طريقة نسخ البشر لمستند طويل. يكتب الشخص وهو ينظر إلى آخر بضع جمل كتبها (الذاكرة العاملة قصيرة المدى) وإلى المستند الأصلي المنشور أمامه (المرجع). و"Reference" في R-SWA هي بالضبط هذا المرجع الأصلي. فهي تحتفظ بالرموز البصرية عالية الضغط التي ينتجها المشفّر كمرساة يمكن الوصول إليها دائمًا، مع تطبيق نافذة منزلقة على رموز النص المولّد.

بعبارة أخرى، ينظر الانتباه إلى مجموعتين. الأولى رموز المرجع البصري ثابتة الحجم (مخرجات المشفّر)، والثانية نافذة منزلقة على النص المولّد حديثًا. وكلتا المجموعتين محدودتان في الطول، لذا مهما طال الإخراج تبقى ذاكرة KV الإجمالية ثابتة. إنه انتباه يحاكي الذاكرة العاملة بالمعنى الحرفي: لا ينسى المصدر أبدًا، ومع ذلك يبقي الذاكرة مستقرة.

تؤكد الورقة أن R-SWA ليست حيلة خاصة بـ OCR بل انتباه تحليل عام الغرض. ينطبق الهيكل نفسه على المهام التي تقرأ مدخلًا طويلًا وتنتج مخرجًا طويلًا، مثل التعرف على الكلام (ASR) أو الترجمة. وقد يتعمم نمط تثبيت المدخل كمرجع مرساة وتطبيق نافذة منزلقة على المخرج عبر مسائل التسلسل إلى التسلسل.

## نتائج القياس

تُبلَّغ الأداء على OmniDocBench، وهو معيار لتحليل المستندات يقيّم بشمولية النص الأساسي والجداول والمعادلات وترتيب القراءة.

- **النتيجة الإجمالية على OmniDocBench v1.5 بنسبة 93.23%**: تحسّن بمقدار 6.22 نقطة مئوية عن خط أساس DeepSeek-OCR.
- **النتيجة الإجمالية على OmniDocBench v1.6 بنسبة 93.92%**: مُبلَّغ عنها كأحدث ما توصلت إليه التقنية من طرف إلى طرف.

ما يبرز هو تحقيق مكاسب الدقة وكفاءة الذاكرة في آنٍ واحد. عادةً يخلق تضييق النافذة لتوفير الذاكرة مقايضة في الدقة، لكن R-SWA تبلغ ذاكرة KV ثابتة دون خسارة في الدقة بالاحتفاظ بالمرجع البصري كمرساة ثابتة. والقدرة على بثّ مستند متصل دفعة واحدة، دون تقطيع الصفحات ومعالجتها منفصلة، تُحدث فرقًا عمليًا كبيرًا، لأنها تحافظ على استمرارية الجداول والحواشي والنص متعدد الأعمدة التي تنكسر عند حدود الصفحات.

ومع ذلك، فإن جميع الأرقام أعلاه قيم بلّغتها الورقة وبطاقة النموذج، وليست أرقامًا أعدنا إنتاجها بأنفسنا. فـ Unlimited OCR نموذج MoE بحجم 3 مليار، لذا يتطلب التحقق ذو المعنى وحدة معالجة رسوميات وتنزيل النموذج، ويركّز هذا المنشور على تحليل التصميم. ونخطط لتناول إعادة الإنتاج العملي في تجربة منفصلة.

## تطبيقه على منصة ThakiCloud لـ K8s AI/ML SaaS

من منظور منصتنا، سبب أهمية هذا النموذج واضح: أصعب مورد في خدمة الاستدلال متعدد المستأجرين هو بالضبط ذاكرة KV.

**اقتصاديات الخدمة**: في محركات الخدمة مثل vLLM، يعتمد عدد الطلبات المتزامنة، أي حجم الدفعة، على مقدار ما تشغله ذاكرة KV من ذاكرة وحدة المعالجة الرسومية. يدع نموذج الانتباه الكامل طلب مستند طويل واحد يلتهم ذاكرة KV كبيرة، فيخفض الإنتاجية المتزامنة. أما نموذج ذاكرة KV الثابتة فلديه ذاكرة لكل طلب يمكن التنبؤ بها بصرف النظر عن طول المستند. وسواء كان فاتورة من صفحة واحدة أو عقدًا من 200 صفحة، تُعالَج ببصمة الذاكرة نفسها، فيمكنك تخطيط حجم الدفعة باستقرار دون أن يهزّك توزيع أطوال الحمل. وفي بيئة متعددة المستأجرين، يصبح عزل الموارد لكل مستأجر وتخطيط السعة أبسط بكثير.

**في الموقع وكفاءة التكلفة**: الأوزان المفتوحة تحت رخصة MIT والتشغيل على وحدة معالجة رسوميات متوسطة المدى واحدة عاملان حاسمان للعملاء الذين لا يمكنهم إرسال البيانات إلى الخارج. ففي مجالات تكون فيها المستندات نفسها حساسة، مثل المال والقطاع العام والرعاية الصحية، قد يكون رفع عقد إلى واجهة OCR سحابية انتهاكًا للامتثال بحد ذاته. وإذا أتاح تصميم الذاكرة الثابتة إقامة خط أنابيب للمستندات الطويلة في الموقع بوحدة معالجة رسوميات معقولة واحدة، فإنه يجلس بطبيعته فوق مكدّسنا حيث نجدول وحدات المعالجة الرسومية بـ Kueue ونخدم بـ vLLM.

**خارطة طريق التطبيق**: على منصتنا، تدخل أحمال ذكاء المستندات كمعالجة مسبقة لفهرسة RAG وكأدوات مستندات للوكلاء. ويمكن لـ OCR ذي ذاكرة KV الثابتة أن يكون البوابة الأولى في كلا المسارين، محلّلًا مستندًا طويلًا بدقة وبالكامل قبل تقطيعه. وخاصة للمستندات الحكومية الكورية والمستندات المالية ذات الجداول العابرة للصفحات والتخطيطات متعددة الأعمدة، تساهم القدرة على المعالجة المستمرة دون تقسيم الصفحات مباشرة في جودة RAG اللاحقة. وتتمثل استراتيجية تشغيل واقعية في نشر استقرار المراحل المنفصلة في PaddleOCR-VL ومعالجة Unlimited OCR للمستندات الطويلة دفعة واحدة بشكل انتقائي وفق خصائص الحمل.

## القيود والحجج المضادة

التصميم الأنيق لا يعني أنه يناسب كل حالة.

**الحدود المتأصلة للنافذة المنزلقة**: رغم احتفاظ R-SWA بالمرجع البصري كمرساة، يظل جانب النص المولّد نافذة منزلقة. فالاعتماديات بعيدة المدى جدًا بين رموز الإخراج، مثل التوسيع المتسق لاختصار عُرّف في الصفحة 1 عبر الصفحة 180، قد لا تكون مضمونة بالدرجة نفسها كالانتباه الكامل حتى مع تعزيز المرجع البصري لها. وهذه نقطة يجب تأكيدها عبر إعادة الإنتاج العملي.

**العبء التشغيلي لـ MoE**: نموذج MoE بحجم 3 مليار خفيف في الحوسبة لكل رمز، لكن مجموعة الخبراء الكاملة يجب أن تكون في الذاكرة، فيتجاوز شغل الذاكرة الفعلي المعاملات النشطة (500 مليون). ولـ MoE أيضًا خاصية أن الإنتاجية تتذبذب عندما يصبح توجيه الخبراء عبر الرموز في دفعة غير متوازن، فيعتمد الأداء على نضج محرك الخدمة في دعم MoE.

**الفجوة بين القياس والاستخدام الحقيقي**: النتيجة العالية على OmniDocBench لا تضمن المستوى نفسه على المدخلات الصعبة في التشغيل الحقيقي، مثل الكتابات غير اللاتينية كالكورية والعربية، والخط اليدوي، والمسوحات منخفضة الجودة، أو المستندات الحكومية المغطاة بالأختام. وOCR المستندات مجال تكون فيه الفجوة بين القياس والميدان كبيرة بشكل خاص، وتقييم منفصل على توزيع مستنداتك الخاص أمر أساسي قبل الاعتماد.

**الحاجة إلى التحقق**: كل رقم في هذا المنشور قيمة بلّغتها الورقة وبطاقة النموذج. وما إذا كانت ذاكرة KV الثابتة تقدّم مكسب الإنتاجية الذي تَعِد به في الخدمة الحقيقية، وما إذا كانت تملأ 32K دون خسارة في الدقة، لا يمكن تأكيده إلا بقياسه بأنفسنا.

ومع ذلك، فإن فكرة "تثبيت المرجع وتطبيق نافذة منزلقة على التوليد" حركة نظيفة للتعامل مع سقف الذاكرة لمهام التسلسل إلى التسلسل الطويلة. وإذا صحّ الادعاء بأنها تتعمم إلى ما بعد OCR لتشمل ASR والترجمة، فإنها جديرة بالمتابعة من منظور تشغيل منصة استدلال متعددة المستأجرين.

## المصادر

- [Unlimited OCR Works: Welcome the Era of One-shot Long-horizon Parsing (arXiv 2606.23050)](https://arxiv.org/abs/2606.23050)
- [صفحة الورقة على Hugging Face](https://huggingface.co/papers/2606.23050)
- [baidu/Unlimited-OCR (نموذج وأوزان Hugging Face)](https://huggingface.co/baidu/Unlimited-OCR)
- [baidu/Unlimited-OCR (كود GitHub)](https://github.com/baidu/Unlimited-OCR)
