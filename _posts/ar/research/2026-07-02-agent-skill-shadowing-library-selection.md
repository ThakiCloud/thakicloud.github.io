---
title: "مهارات أكثر، وكلاء أسوأ: تظليل المهارات وعنق زجاجة الاختيار"
excerpt: "تُظهر أبحاث حديثة أن أداء الوكيل قد يتراجع كلما كبرت مكتبة المهارات. تُفكّك الورقة arXiv 2605.24050 هذا التراجع إلى تظليل المهارات وعبء السياق، وتجد أن عنق الزجاجة الحقيقي هو اختيار المهارة الخاطئة لا حجم السياق. نستعرض كيف يمنع Skill Harness في Paxis من ThakiCloud ذلك عمليًا عبر استرجاع BM25 وبوابة امتناع، مع أرقام قياس حقيقية."
seo_title: "تظليل المهارات: لماذا تجعل المكتبات الأكبر الوكلاء أسوأ | Thaki Cloud"
seo_description: "استنادًا إلى arXiv 2605.24050، يفصل هذا المقال بين تظليل المهارات وعبء السياق، ويوضح كيف يوقف Skill Harness في Paxis من ThakiCloud عنق زجاجة الاختيار عبر استرجاع BM25 وبوابة امتناع، مدعومًا بأرقام قياس حقيقية."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - agent-skills
  - skill-retrieval
  - llm-agents
  - skill-shadowing
  - paxis
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "layer-group"
canonical_url: "https://thakicloud.com/tech-blog/ar/research/agent-skill-shadowing-library-selection/"
categories:
  - research
published: false
---

## نظرة عامة

يبدو أن منح الوكيل مزيدًا من المهارات ينبغي أن يجعله أكثر كفاءة، لكن الأبحاث الحديثة تُبلّغ بالعكس. فكلما كبرت مكتبة المهارات، قد ينخفض فعليًا معدل نجاح الوكيل في المهام نفسها. تواجه الورقة arXiv 2605.24050 بعنوان "More Skills, Worse Agents?" هذه المفارقة مباشرة، وتُبلّغ بأن معدل اجتياز المهام يتراجع بنسبة تصل إلى 21% عند التوسع من مجموعة صغيرة من المهارات المفيدة إلى مكتبة من 202 مهارة.

هذه حقيقة تشغيلية لا فضول أكاديمي. فسحابة ThakiCloud الموجَّهة للوكلاء Paxis تُدير بالفعل أكثر من 960 مهارة، وعليها أن تقرر في كل طلب أيها تُحمِّل. إضافة المهارات سهلة، أما انتقاء المهارة الصحيحة من مكتبة متضخمة فيزداد صعوبة باطراد. يستخدم هذا المقال تظليل المهارات عدسةً لتسمية عنق الزجاجة هذا، ثم يوضح كيف يمنعه Skill Harness في Paxis عمليًا عبر الاسترجاع وبوابة امتناع، مدعومًا بقياسات حقيقية.

## ما هو تظليل المهارات

تتيح مكتبة المهارات لوكيل نموذج اللغة تحميل تعليمات خاصة بالمهمة عند الطلب. والهدف تمكين مستخدم غير خبير من حل مهام في مجاله بلغة طبيعية دون معرفة أي المهارات موجودة أو كيف تعمل داخليًا. تبدأ المشكلة كلما كبرت المكتبة.

المساهمة الجوهرية في arXiv 2605.24050 هي تفكيك تراجع الأداء إلى أثرين. الأول هو **تظليل المهارات (skill shadowing)**: مع كبر المكتبة تتصادم المهارات المتشابهة في وصفها فيختار الوكيل المهارة الخاطئة أكثر. والثاني هو **عبء السياق (context overhead)**: تملأ أوصاف المهارات السياق فتتدهور جودة التنفيذ حتى حين يكون الاختيار صحيحًا.

خلاصة الورقة تخالف الحدس. فالمُسبِّب الرئيسي ليس السياق المنتفخ بل **اختيار المهارة الخاطئة نفسه**. بعبارة أخرى، عنق الزجاجة ليس "على النموذج قراءة نصوص كثيرة" بل "لا يستطيع النموذج انتقاء المهارة الصحيحة بين أوصاف متشابهة". هذا التشخيص يغيّر الاستجابة. فضغط السياق وحده لا يكفي؛ نحتاج خطوة استرجاع تُضيّق المرشحين وتختار بدقة من البداية.

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
<div class="d3-arch" data-arch-root id="hadowinglibraryselection-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 663, "height": 1114, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 297, "y": 24, "w": 120, "h": 46, "title": "طلب المستخدم"}, {"id": "B", "x": 270, "y": 148, "w": 174, "h": 52, "title": "حجم مكتبة المهارات"}, {"id": "C", "x": 447, "y": 610, "w": 184, "h": 46, "title": "اختيار المهارة الصحيحة"}, {"id": "D", "x": 145, "y": 292, "w": 170, "h": 62, "title": ["تصادم أوصاف المهارات", "المتشابهة"]}, {"id": "E", "x": 256, "y": 454, "w": 184, "h": 62, "title": ["تظليل المهارات", "ازدياد الاختيار الخاطئ"]}, {"id": "F", "x": 24, "y": 446, "w": 177, "h": 78, "title": ["عبء السياق", "تدهور التنفيذ رغم صحة", "الاختيار"]}, {"id": "G", "x": 124, "y": 602, "w": 212, "h": 62, "title": ["تراجع معدل الاجتياز حتى 21", "بالمئة"]}, {"id": "H", "x": 254, "y": 756, "w": 205, "h": 62, "title": ["الاسترجاع يُضيّق المرشحين", "أولًا"]}, {"id": "I", "x": 265, "y": 896, "w": 184, "h": 62, "title": ["بوابة الامتناع ترفض", "المهارات منخفضة الدرجة"]}, {"id": "J", "x": 251, "y": 1036, "w": 212, "h": 46, "title": "التنفيذ في صندوق رمل معزول"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [357, 70, 357, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "مهارات مفيدة قليلة", "curve": [[423, 200], [539, 323], [539, 485], [539, 610]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "توسّع إلى مئات", "curve": [[311, 200], [230, 246], [230, 246], [230, 292]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "curve": [[278, 354], [348, 400], [348, 400], [348, 454]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[183, 354], [113, 400], [113, 400], [113, 446]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[348, 516], [348, 563], [348, 563], [282, 602]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[113, 524], [113, 563], [113, 563], [178, 602]]}, {"src": "C", "dst": "H", "kind": "data", "curve": [[539, 656], [539, 710], [539, 710], [430, 756]]}, {"src": "G", "dst": "H", "kind": "event", "label": "تشخيص", "curve": [[230, 664], [230, 710], [230, 710], [306, 756]], "off": "50%"}, {"src": "H", "dst": "I", "kind": "data", "line": [357, 818, 357, 896]}, {"src": "I", "dst": "J", "kind": "data", "line": [357, 958, 357, 1036]}]});
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
      const container = document.getElementById('hadowinglibraryselection-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'hadowinglibraryselection-1';
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

يتطابق هذا المسار تمامًا مع مشكلة واجهناها من قبل. فحشو قائمة المهارات كاملةً في المُوجِّه ينهار لحظة تجاوز العدد بضع مئات. وبدل تكبير المكتبة بلا نهاية، لا بد من التحول إلى استرجاع المرشحين الأعلى فقط لكل طلب.

## لماذا يهم هذا الآن

مشكلة الحجم لا تقتصر على ورقة واحدة. فمعيار SkillRet (arXiv 2605.05726) الصادر في الفترة نفسها يجمع 17,810 مهارة وكيل عامة في معيار استرجاع واسع النطاق منظَّم ضمن تصنيف من مستويين يضم 6 فئات رئيسية و18 فئة فرعية. صارت المهارات تتراكم بمقياس عشرات الآلاف، وأصبح استرجاع المهارة الصحيحة من هذا المجمع مسألة بحثية قائمة بذاتها.

باختصار، تتسع فجوة بين وتيرة إضافة المجتمعات للمهارات والقدرة على اختيارها بدقة. تُظهر أبحاث التظليل كميًّا أن هذه الفجوة تتحول إلى خسارة أداء حقيقية، بينما توفر معايير مثل SkillRet مسطرة مشتركة لقياسها. وكلاهما يشير إلى وصفة عملية واحدة: **عاملْ الاسترجاع والاختيار كمسألتين من الدرجة الأولى، منفصلتين عن تكبير المكتبة.**

## الأثر على منتجات ThakiCloud

يتطابق اتجاه هذا البحث تمامًا مع تصميم يُطبّقه Skill Harness في Paxis بالفعل. فـ Paxis هي سحابة ThakiCloud الموجَّهة للوكلاء وتعامل المهارات كموارد من الدرجة الأولى. وبدل دفع قائمة المهارات كاملةً في كل طلب، تُضيّق المرشحين إلى الأعلى مطابقةً عبر استرجاع BM25 المعجمي وتُحمّل هؤلاء فقط. هذا هو خط الدفاع الأول ضد تظليل المهارات. فحين تنكمش مجموعة المرشحين من مئات إلى قلة، ينكمش معها مجال تصادم الأوصاف المتشابهة.

خط الدفاع الثاني هو **بوابة الامتناع (abstain gate)**. فحين تقل أعلى درجة استرجاع عن عتبة معيّنة، لا تُفرض أي مهارة، بل يتحول الطلب إلى المعالجة الأصلية. وإذا كان جوهر تظليل المهارات هو "انتقاء مهارة خاطئة معقولة عند عدم اليقين"، فبوابة الامتناع هي الآلية التي تمنع تلك المطابقة غير المؤكدة حتميًّا في الشيفرة. فبدل الوثوق بحكم النموذج على "الغموض"، تملك عتبةُ الدرجة القرار.

تُظهر قياسات Skill Harness الفعلية أن التصميم يعمل. ففي معيارنا الداخلي SRA (63 حالة) بلغ Recall@5 نسبة 82.2%، وبلغت الدقة المُبوَّبة مع تطبيق بوابة الامتناع 66.7%، وبلغ Top-1 نسبة 40.0%، وكانت الهلوسة (اختلاق مهارة غير موجودة للمطابقة) 0%. وتحديدًا فإن الهلوسة 0% أثر مباشر لبوابة الامتناع: فمهما كبرت المكتبة، لا تختلق مهارة غائبة ولا تفرض مطابقة دون العتبة.

يعلو ذلك التنفيذُ المعزول في صندوق رمل، وبوابات السياسة، وسجلات التدقيق في Paxis. فحتى لو اختير أحيانًا مهارة خاطئة، يجري تنفيذها في بيئة معزولة ويُسجَّل كل فعل في سجل التدقيق. وحتى حين لا يزول تظليل المهارات كليًّا، يُحتوى مداه عند حدود التنفيذ. هكذا يُمنع عنق الزجاجة الذي يشخّصه البحث (فشل الاختيار) وخطره اللاحق (التنفيذ الخاطئ) في ثلاث طبقات: الاسترجاع والبوابة والعزل.

## الحدود والاعتراضات

للبحث ولتصميمنا حدود واضحة. أولًا، نسبة التراجع 21% في arXiv 2605.24050 قيمة ضمن إعداد محدد (مكتبة من 202 مهارة) وتتباين كثيرًا بحسب جودة أوصاف المهارات وتداخلها ومجال المهمة. فإذا وُصفت المهارات جيدًا وحُفظت من التداخل، تقلّ نسبة التراجع عند المقياس نفسه. الدرس الدقيق ليس "لا تُضِف مهارات" بل "أدِر جودة الوصف والاسترجاع معًا".

ثانيًا، استرجاع BM25 المعجمي ليس دواءً لكل داء. فمع الاستعلامات بمصطلحات كورية صرفة تفتقر إلى مفردات توسعة إنجليزية، قد يعجز عن إظهار المهارة الصحيحة، ونسبة Top-1 البالغة 40.0% في معيارنا تترك مجالًا واسعًا للتحسين. وثمة تعزيزات مثل مجاميع التضمين مطروحة، لكن هل تبرر التخلي عن حتمية إشارة واحدة وكلفتها المنخفضة فمسألة منفصلة. وقبل تثقيل الاسترجاع، غالبًا ما يمنح تحسين أوصاف المهارات نفسها المكسب الأكبر.

ثالثًا، تختزل بوابة الامتناع إلى مسألة ضبط عتبة. فعتبة عالية جدًّا تستبعد مهارات مفيدة وتضر بالتغطية، وعتبة منخفضة جدًّا تعجز عن منع التظليل. ونتيجة الهلوسة 0% ثمرة عتبة مضبوطة بحذر، وتأتي بكلفة إغفال بعض المطابقات المشروعة. في النهاية، إدارة مكتبة مهارات ليست سؤال "كم نُكبّرها" بل "كيف نوازن بين الاسترجاع والبوابة وجودة الوصف"، وأبحاث التظليل تحذير كمّي بأن هذا التوازن يبدأ بالاختلال عند مقياس أصغر مما تتوقع.

## المصادر

- More Skills, Worse Agents? Skill Shadowing Degrades Performance When Expanding Skill Libraries, arXiv 2605.24050 (<https://arxiv.org/abs/2605.24050>)
- SkillRet: A Large-Scale Benchmark for Skill Retrieval in LLM Agents, arXiv 2605.05726 (<https://arxiv.org/abs/2605.05726>)
