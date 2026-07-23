---
title: "أعمال Claude Code تستدعي موصلات MCP: بناء لوحات معلومات حية تُحدّث نفسها"
seo_title: "بناء لوحات معلومات حية باستخدام أعمال Claude Code وموصلات MCP - Thaki Cloud"
seo_description: "أصبحت أعمال Claude Code قادرة الآن على استدعاء موصلات MCP مباشرة لجلب البيانات وتنفيذ الإجراءات. نستعرض هنا كيفية بناء لوحة معلومات أو تطبيق يعيد استعلام الموصلات في كل مرة يُفتح فيها، وكيف تعمل بوابات الموافقة ونطاق الوصول، ونظرة Paxis من ThakiCloud على معاملة موصلات MCP كموارد من الدرجة الأولى."
excerpt: "كانت الأعمال تنتهي كملفات ماركداون ثابتة. الآن أصبحت تطبيقات حية تستدعي الموصلات. نستعرض كيفية بناء لوحة معلومات تسحب بيانات جديدة في كل مرة تفتحها."
date: 2026-07-16
tags:
  - claude-code
  - mcp
  - artifacts
  - connectors
  - dashboard
  - developer-tools
  - paxis
  - ai-coding
categories:
  - tutorials
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/claude-code-artifacts-mcp-connectors/"
---

حتى وقت قريب، كانت أعمال Claude Code وسيلة لالتقاط نتائج جلسة عمل وتجميدها في صفحة ويب واحدة قابلة للمشاركة. وصف طلب سحب مع فرق مُعلّق، ملخص حادثة، قائمة مهام: كل هذه كانت مخرجات ثابتة تحافظ على حالة اللحظة التي أُنشئت فيها. مع هذا التحديث، تتقدم الأعمال خطوة أخرى. أصبحت الأعمال قادرة الآن على **استدعاء موصلات MCP مباشرة** لجلب البيانات، بل وتنفيذ الإجراءات أيضًا. بمعنى آخر، بدلًا من صفحة متحجرة عند لحظة إنشائها، نحصل على **تطبيق حي يعيد استعلام الموصلات في كل مرة يُفتح فيها ويعرض الحالة الراهنة**. هذا المقال موجّه للمطورين الذين سئموا كتابة نفس لوحات المعلومات الداخلية وأدوات التشغيل يدويًا مرارًا وتكرارًا. والخلاصة المختصرة: يمكن الآن استبدال جزء كبير من تلك اللوحات بعمل واحد فقط، دون الحاجة إلى نشر واجهة أمامية.

## نظرة عامة

التحول الجوهري هو أن الأعمال انتقلت من "مخرج للقراءة فقط" إلى "عميل قابل للتنفيذ". بينما كان العمل القديم يعرض لقطة من البيانات، فإن العمل الحي يرسل استعلامات إلى المصدر الفعلي عبر موصل. حالات الاستخدام التي يفتحها هذا واضحة: عرض خط أنابيب علاقات العملاء، متتبعات المشاريع، الإحاطات الصباحية، لوحات المؤشرات الأسبوعية؛ أي شاشة **تتغير بياناتها الأساسية باستمرار**. ولأنه يسحب بيانات جديدة في كل مرة يُفتح فيها، لا يحتاج أحد إلى الضغط على زر التحديث، ولا يحتاج أي نظام خلفي منفصل إلى دفع البيانات عبر مهمة مجدولة.

يمثّل MCP خط الأنابيب خلف هذه الصورة. MCP بروتوكول مفتوح يتيح لـ Claude التحدث مع أدوات خارج نافذة المحادثة، والموصلات هي التكاملات بنقرة واحدة التي بنتها Anthropic وشركاؤها فوق هذا البروتوكول. حين يستدعي عمل موصلًا، فهذا يعني أن العمل أصبح قادرًا الآن على قراءة وكتابة البيانات مباشرة في الأنظمة الخارجية المرتبطة بخادم MCP ذاك.

## ما هي أعمال Claude Code وموصلات MCP

لنبدأ بالأعمال. يحوّل العمل نتاج جلسة Claude Code إلى صفحة مرئية حية قابلة للمشاركة. وصف طلب سحب مع فرق مُعلّق، لوحة معلومات مُجمّعة من بيانات الجلسة، خط زمني يُملأ تدريجيًا مع تقدّم تحقيق ما؛ كل هذه يمكن أن تكون أعمالًا. يذهب العمل الحي خطوة أبعد ويُحدّث نفسه تلقائيًا. في كل مرة يُفتح فيها، يعيد استعلام الموصلات المرتبط بها ويعرض الحالة الراهنة.

الموصلات هي طبقة التكامل المبنية فوق خوادم MCP. تُضاف موصلات المكتبة بنقرة واحدة وتسجيل دخول عبر OAuth من قسم Connectors تحت Customize. من بينها Notion وGmail وSlack وHubSpot وLinear وCanva وAtlassian وMicrosoft 365. يضم دليل الموصلات أكثر من 375 تكاملًا يغطي الملفات والبريد الإلكتروني وإدارة المشاريع والتحليلات والتصميم والمبيعات وأدوات المطورين.

يوضّح المخطط أدناه الفرق في تدفق البيانات بين عمل ثابت وعمل حي.

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
<div class="d3-arch" data-arch-root id="deartifactsmcpconnectors-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 488, "height": 1058, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 170, "y": 24, "w": 163, "h": 46, "title": "المستخدم يفتح العمل"}, {"id": "Q", "x": 183, "y": 148, "w": 138, "h": 52, "title": "هل هو عمل حي"}, {"id": "S", "x": 286, "y": 292, "w": 170, "h": 62, "title": ["عرض اللقطة", "المأخوذة عند الإنشاء"]}, {"id": "M", "x": 33, "y": 300, "w": 198, "h": 46, "title": "إعادة استعلام موصلات MCP"}, {"id": "C1", "x": 40, "y": 432, "w": 184, "h": 78, "title": ["المصادر المتصلة:", "Notion وSlack وHubSpot", "وغيرها"]}, {"id": "R", "x": 44, "y": 588, "w": 177, "h": 46, "title": "العرض بالحالة الراهنة"}, {"id": "W", "x": 24, "y": 712, "w": 216, "h": 52, "title": "هل هو إجراء كتابة أو حذف"}, {"id": "A", "x": 113, "y": 856, "w": 163, "h": 46, "title": "طلب موافقة المستخدم"}, {"id": "D", "x": 51, "y": 980, "w": 163, "h": 46, "title": "اكتمال تحديث الشاشة"}], "edges": [{"src": "U", "dst": "Q", "kind": "data", "line": [252, 70, 252, 148]}, {"src": "Q", "dst": "S", "kind": "data", "label": "لا", "curve": [[295, 200], [371, 246], [371, 246], [371, 292]], "off": "50%"}, {"src": "Q", "dst": "M", "kind": "data", "label": "نعم", "curve": [[208, 200], [132, 246], [132, 246], [132, 300]], "off": "50%"}, {"src": "M", "dst": "C1", "kind": "data", "line": [132, 346, 132, 432]}, {"src": "C1", "dst": "R", "kind": "data", "line": [132, 510, 132, 588]}, {"src": "R", "dst": "W", "kind": "data", "line": [132, 634, 132, 712]}, {"src": "W", "dst": "A", "kind": "data", "label": "نعم", "curve": [[155, 764], [195, 810], [195, 810], [195, 856]], "off": "50%"}, {"src": "W", "dst": "D", "kind": "data", "label": "لا", "curve": [[109, 764], [69, 810], [69, 941], [109, 980]], "off": "50%"}, {"src": "A", "dst": "D", "kind": "data", "curve": [[195, 902], [195, 941], [195, 941], [155, 980]]}]});
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
      const container = document.getElementById('deartifactsmcpconnectors-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'deartifactsmcpconnectors-1';
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

## كيف يعمل

تتلخص الآلية في ثلاث قواعد.

أولًا، **يعيد الاستعلام في كل مرة يُفتح فيها.** يعيش العمل الحي في تبويب منفصل داخل الشريط الجانبي لـ Cowork، وفي كل مرة يُفتح فيها يعيد استعلام موصلاته ويرسم الحالة الراهنة. يمكن ربطه بموصل واحد فقط، أو دمج عدة موصلات معًا في شاشة واحدة. ومن هنا تأتي فكرة لوحة معلومات موحّدة تسحب من مصادر متعددة.

ثانيًا، **الكتابة والحذف تمرّان عبر بوابة موافقة.** حين لا يكتفي الموصل بقراءة البيانات بل ينفّذ إجراءً يغيّر فعليًا بيانات المصدر المتصل، يُطلب من Claude أن يطلب موافقة المستخدم أولًا. إنها آلية حماية تمنع الأتمتة من المساس بمصدر الحقيقة بصمت. عند إعداد أداة ما، أول ما يجب التحقق منه هو ما إذا كانت أدوات الكتابة والحذف تخضع لموافقة إلزامية.

ثالثًا، **نطاق الوصول مرتبط بالفرد.** في مؤسسات Team أو Enterprise، يمكن للمالكين فقط إضافة موصل إلى المؤسسة، لكن الاتصال والتفعيل الفعليين يتمّان لكل مستخدم على حدة. لذلك لا يصل Claude إلا إلى الأدوات والبيانات التي يملك ذلك المستخدم الصلاحية عليها أصلًا. من ميزات خطتي Team وEnterprise أنه عند استخدام عمل مشترك من قِبل زميل في الفريق، لا تترتب تكلفة إضافية على من أنشأه.

من زاوية إدارة المؤسسات، أُضيف أيضًا مسار لتوفير الموصلات على مستوى المؤسسة. بمجرد أن يسجّل المسؤول موصلًا عبر مزوّد هوية مثل Okta، يحصل المستخدمون على وصول الموصل تلقائيًا عند تسجيل الدخول الأول دون أي إعداد إضافي. يُهيَّأ التوثيق مركزيًا على مستوى المؤسسة، وتُشارك هذه الصلاحية عبر محادثة Claude وClaude Code وCowork.

## مثال إعداد عملي

إضافة خادم MCP في Claude Code تتطلب أمرًا واحدًا وملف إعدادات واحدًا. إليك الأمر الفعلي لإضافة خادم MCP محلي.

```bash
# تسجيل خادم MCP في Claude Code
claude mcp add my-metrics --command "python3" --args "servers/metrics_mcp.py"

# التحقق من الخوادم المسجَّلة
claude mcp list
```

يمكن الإعلان عن خوادم MCP المرتبطة بمشروع في `.mcp.json` في جذر المستودع ومشاركتها مع الفريق. البنية كالتالي.

```json
{
  "mcpServers": {
    "my-metrics": {
      "command": "python3",
      "args": ["servers/metrics_mcp.py"],
      "env": { "METRICS_DB_URL": "postgres://..." }
    }
  }
}
```

بالنسبة للموصلات البعيدة، يُستخدم نقطة نهاية MCP بعيدة وتدفق OAuth. أما موصلات المكتبة فهي أبسط: انتقل إلى قسم Connectors تحت Customize في الواجهة، اضغط زر الإضافة، وابحث عن التطبيق الذي تريد ربطه. داخل العمل، يُستدعى الموصل المرتبط كأنه دالة لجلب البيانات، وتُعرض النتيجة كمكوّن في لوحة المعلومات. ما نحتاج إلى كتابته ليس خط أنابيب نشر لواجهة أمامية، بل تعليمات بلغة طبيعية تحدد أي الموصلات نستعلم عنها وبأي ترتيب، وماذا نرسم بالنتيجة.

## دلالات على منتجات ThakiCloud

هذه الميزة هي النسخة الموجّهة للمستهلك من مشكلة نعمل عليها منذ فترة طويلة في Paxis. Paxis هو Agent-Native Cloud الخاص بـ ThakiCloud، ويتعامل مع المهارات والأدوات والسياسات كموارد من الدرجة الأولى. من أهم أجزاء طبقة الأدوات تلك خط الأنابيب الذي **يدير موصلات MCP مع إعادة اتصال OAuth تلقائية**. خطوة Anthropic في السماح للأعمال باستدعاء الموصلات تشير بالضبط إلى النقطة ذاتها التي يستهدفها تصميمنا: الوكلاء الذين يتحدثون مع أنظمة خارجية يحتاجون إلى ترقية الموصلات لتصبح موارد من الدرجة الأولى.

ما يلفت انتباهنا بشكل خاص هو **بوابة الموافقة ونطاق الوصول**. الطريقة التي تفرض بها الأعمال الحية موافقة على إجراءات الكتابة والحذف، وتربط الوصول بصلاحيات الفرد، تنبع من نفس الاهتمام الكامن وراء انضباط Paxis في تمرير كل إجراء وكيل عبر بوابة سياسة وسجل تدقيق. كلما ازدادت قوة الموصلات، وجب أن تزداد بالمثل قوة مستوى التحكم الذي يسجّل ما لمسه الموصل ومتى، ويؤجّل الإجراءات الخطرة إلى ما بعد موافقة بشرية. فبمجرد أن يصبح العمل تطبيقًا حيًا، تتحول لوحة معلومات واحدة إلى مسار تنفيذ نحو بيانات الإنتاج.

من الناحية التحتية، تمثّل ai-platform الطبقة التي تخدم خوادم MCP التي يستعلم عنها عمل حي، بشكل موثوق فوق K8s. حين يعرض فريق ما البيانات التي يراجعها كثيرًا كخوادم MCP، مثل MCP للمؤشرات الداخلية أو MCP لحالة النشر أو MCP للتكلفة، يستطيع المطورون تجميع لوحات تشغيل خاصة بهم عبر أعمال حية دون كتابة سطر واحد من الواجهة الأمامية. كون خلفية MCP موثوقة ومنخفضة التكلفة هو ما يجعل اقتصاديات الوكلاء ممكنة، ولهذا تتحرك طبقة الخدمة في ai-platform وطبقة الموصلات في Paxis ككيان واحد.

## القيود والحجج المضادة

هناك بضع نقاط يجب توضيحها قبل التبني.

أولًا، جزء كبير من هذه الميزة مرتبط بخطتي Team وEnterprise، وببيئة Cowork. لا تُستنسخ الأعمال الحية والموصلات المُدارة على مستوى المؤسسة كما هي في الخطط الفردية، لذا يجب أن يفترض حساب القيمة تبنّيًا على مستوى المؤسسة كخط أساس.

ثانيًا، كون العمل الحي يعيد استعلام الموصلات في كل مرة يُفتح فيها يعني أن كل مشاهدة تولّد طلبًا على نظام خارجي. إذا كان عدة أشخاص يفتحون بتكرار لوحة معلومات تحمل استعلامات ثقيلة، فيجب مراقبة حدود المعدل والتكلفة على النظام المصدر أيضًا. لا تزال هناك شاشات تكون فيها اللقطة الثابتة الخيار الأفضل.

ثالثًا، بوابات الموافقة قوية لكنها ليست حلًا شاملًا. قد يبدو استعلام ما للقراءة فقط، لكنه في الواقع يسحب بيانات حسّاسة إلى سطح قابل للمشاركة مثل العمل. يجب أن تسبق سياسة المؤسسة بشأن ما يُسمح بكشفه في عمل مشترك بوابةَ الموافقة، لا أن تتبعها. كلما ازدادت هذه الميزة سهولة، ازدادت الحاجة إلى التساؤل عن أي ضبط تتجاوزه تلك السهولة. هذه هي الطريقة الآمنة لاستخدامها.

## المصادر

- Claude Code now supports artifacts, Anthropic: [claude.com/blog/artifacts-in-claude-code](https://claude.com/blog/artifacts-in-claude-code)
- Connect Claude Code to tools via MCP, Claude Code Docs: [code.claude.com/docs/en/mcp](https://code.claude.com/docs/en/mcp)
- Get started with custom connectors using remote MCP, Claude Help Center: [support.claude.com/en/articles/11175166](https://support.claude.com/en/articles/11175166)
- Anthropic Claude Code Artifacts update, VentureBeat: [venturebeat.com/data/anthropics-claude-code-artifacts-update-brings-live-shared-dashboards-and-interactive-workspaces-to-enterprises](https://venturebeat.com/data/anthropics-claude-code-artifacts-update-brings-live-shared-dashboards-and-interactive-workspaces-to-enterprises)
