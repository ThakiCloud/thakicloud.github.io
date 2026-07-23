---
title: "158 مهارة و24 وكيلًا في مكوّن إضافي واحد: كيف يروّض هيكل حتمي انفجار الوكلاء"
excerpt: "يجمع المكوّن الإضافي مفتوح المصدر Digital Marketing Pro بين 158 مهارة و24 وكيلًا متخصصًا دون أن ينهار. السر هيكل حتمي: تدفّق ثابت من 12 جزءًا. نحلّل التصميم ونبيّن كيف تحوّل Paxis من ThakiCloud المبدأ نفسه إلى منتج."
date: 2026-07-21
tags:
  - AgentOps
  - Skills
  - MultiAgent
  - ClaudeCode
  - Plugins
  - Determinism
  - Paxis
  - AIAgents
author_profile: true
toc: true
toc_label: تشريح المكوّن
published: true
categories:
  - dev
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/agent-plugin-158-skills-deterministic-flow/"
---

![تصور تجريدي لوحدات مهارات عديدة تتقارب في خط أنابيب عمودي مرتّب واحد]({{ '/assets/images/agent-plugin-158-skills-deterministic-flow-hero.png' | relative_url }})

## نظرة عامة

كل من بنى نظام وكلاء جادًّا يصطدم بالمفارقة نفسها. إضافة مزيد من المهارات والوكلاء يبدو أنه سيجعل النظام أذكى، لكنه غالبًا يفعل العكس. فبمجرد تجاوز بضع عشرات من المهارات، يبدأ الوكيل بالحيرة حول أي مهارة يستخدم ومتى، وبمجرد وجود عدة وكلاء، يعالجون المهمة نفسها بطرق مختلفة أو ينحرف ترتيب وصيغة المخرجات في كل تشغيل. ترتفع القدرة بينما تنخفض اتساقية النتائج.

يُعدّ المكوّن الإضافي مفتوح المصدر **Digital Marketing Pro** حالة مثيرة تتصدى لهذه المفارقة مباشرة. فهو يجمع بين 158 مهارة و24 وكيلًا متخصصًا (وثائق المستودع تذكر 25، والتغريدة الأصلية قالت 24) ويحافظ مع ذلك على اتساق إنتاج الملفات نفسها بالترتيب نفسه في كل مرة. السر ليس نموذجًا أذكى بل تدفّق استراتيجية مثبّت في 12 جزءًا، أي هيكل حتمي. يحلّل هذا المقال ليس أداة التسويق نفسها بل تصميم هندسة الوكلاء بداخلها. ما البنية التي تصمد حتى حين تنفجر المهارات عددًا، وكيف يتصل ذلك المبدأ بمنصة الوكلاء التي تبنيها ThakiCloud.

سبب أهمية هذه الحالة للمطوّرين واضح. فهي تُظهر، بشيفرة مفتوحة المصدر ملموسة، لماذا يفشل الأمل الساذج بأن "أنشئ الكثير من المهارات" كثيرًا في الممارسة، وما الذي يوقف ذلك الفشل.

## ما هو هذا المكوّن الإضافي

Digital Marketing Pro مكوّن إضافي تسويقي مفتوح المصدر صادر برخصة MIT. غرضه الظاهري مساعدة الوكالات والفرق التسويقية الداخلية على إنتاج مستندات تسويقية باتساق عبر علامات تجارية عديدة. ووفقًا لوصف المستودع، يستهدف الوكالات التي تتعامل مع ما بين 50 و200 علامة تجارية للعملاء، مُمرّرًا كل علامة عبر التدفّق نفسه المكوّن من 12 جزءًا لإنتاج الملفات نفسها بالترتيب نفسه.

من حيث الأرقام، المكوّن كبير نسبيًا. لديه 158 مهارة و24 وكيلًا متخصصًا، وتدفّق استراتيجية من 12 جزءًا مُوسّع إلى 61 خطوة تفصيلية. وفوق ذلك يقع الاستعداد للمادة 50 من قانون الذكاء الاصطناعي الأوروبي، وميزات AEO/GEO (تحسين محرّكات الإجابة) لست منصّات بما فيها Google AI Mode، ودعم Cowork الذي يحفظ الحالة على مستوى الفريق.

ما يستحق الملاحظة هو هدف التثبيت. فالمكوّن ليس مقيّدًا بـ Claude Code وحده؛ إنه يُثبَّت عبر عدة أوقات تشغيل للوكلاء منها Cowork وCodex وCursor وCopilot CLI وAntigravity. بعبارة أخرى، صُمّمت حزمة واحدة من المهارات والوكلاء لتعمل عبر عدة أطر (harnesses). وهذا قرار تصميمي مهم بما يكفي لتناوله على حدة أدناه.

باختصار، تحت مظهر "أداة تسويق"، يحمل هذا المكوّن إجابة واحدة عن كيفية تنظيم حزمة كبيرة من المهارات والوكلاء وتنفيذها باتساق.

## هيكل حتمي يروّض انفجار المهارات

الفكرة الجوهرية لهذا المكوّن أنه لا يترك المهارات الـ158 والوكلاء الـ24 يتعاونون بحرية. بل يُجبر كل مهمة على المرور عبر تدفّق استراتيجية مثبّت في 12 جزءًا. ينتج كل جزء مخرجًا محدّدًا بترتيب محدّد، وهناك قواعد اعتماد صريحة بين الأجزاء. لا يُشغّل جزء لاحق إلا حين تكون نتيجة الجزء السابق موجودة، وتبقى أسماء ملفات النتائج وترتيبها متطابقة حتى مع تغيّر العلامة التجارية.

تتضح أهمية ذلك إذا تخيّلت العكس. لو اختار 24 وكيلًا بحرية المهارة التي "تبدو الأفضل" وشغّلوا بترتيب حر، لاختلف تكوين وصيغة المخرجات بين علامة وأخرى. قد تحصل علامة على تحليل المنافسين أولًا، وقد تتخطّى أخرى تلك الخطوة كليًا. وإذا كانت الوكالة تدير 200 عميل، يصبح هذا التباين سريعًا فوضى غير قابلة للتدقيق. يقلّل التدفّق المكوّن من 12 جزءًا هذه الحرية عمدًا لرفع متوسط الجودة والاتساق.

يوضّح المخطط أدناه بشكل مبسّط كيف يقيّد هذا الهيكل الحتمي حرية المهارات والوكلاء.

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
<div class="d3-arch" data-arch-root id="8skillsdeterministicflow-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 265, "height": 1142, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 69, "y": 24, "w": 120, "h": 62, "title": ["طلب مهمة", "علامة X"]}, {"id": "B", "x": 47, "y": 164, "w": 163, "h": 62, "title": ["دخول التدفّق الثابت", "من 12 جزءًا"]}, {"id": "C", "x": 51, "y": 304, "w": 156, "h": 62, "title": ["كل جزء: مخرج محدّد", "بترتيب محدّد"]}, {"id": "D", "x": 24, "y": 444, "w": 209, "h": 84, "title": ["اختيار المهارة المناسبة", "للجزء", "من بين 158"]}, {"id": "E", "x": 49, "y": 606, "w": 160, "h": 68, "title": ["إسناد دور", "من بين 24 وكيلًا"]}, {"id": "F", "x": 44, "y": 752, "w": 170, "h": 62, "title": ["تطبيق قواعد الاعتماد", "الصريحة بين الأجزاء"]}, {"id": "G", "x": 37, "y": 892, "w": 184, "h": 78, "title": ["الملفات نفسها بالترتيب", "نفسه", "اتساق مستقل عن العلامة"]}, {"id": "H", "x": 68, "y": 1048, "w": 121, "h": 62, "title": ["محفظة مستندات", "قابلة للتدقيق"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [129, 86, 129, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [129, 226, 129, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [129, 366, 129, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [129, 528, 129, 606]}, {"src": "E", "dst": "F", "kind": "data", "line": [129, 674, 129, 752]}, {"src": "F", "dst": "G", "kind": "data", "line": [129, 814, 129, 892]}, {"src": "G", "dst": "H", "kind": "data", "line": [129, 970, 129, 1048]}]});
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
      const container = document.getElementById('8skillsdeterministicflow-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '8skillsdeterministicflow-1';
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

الدرس هنا لا علاقة له بالتسويق. طريقة حماية الجودة مع نمو المهارات والوكلاء ليست جعل النموذج أذكى بل تخفيض التصميم الحر إلى ملء هيكل مُتحقّق منه. يمتلك هيكل حتمي الصيغة والترتيب والاعتماديات، بينما يملأ النموذج المحتوى داخل ذلك الهيكل فقط. سواء كانت 158 مهارة أو 500، فما دام الهيكل يمسك درجات الحرية، تبقى النتيجة قابلة للتنبّؤ.

## ماذا يعني التثبيت عبر ست أوقات تشغيل

تصميم آخر يستحق الملاحظة هو أن هذا المكوّن يُثبَّت عبر عدة أوقات تشغيل للوكلاء. Claude Code وCursor وCodex وCopilot CLI كلٌّ منها إطار مختلف. مُطالبات النظام لديها مختلفة، وأساليب تعريف الأدوات مختلفة، ونماذج الأذونات مختلفة. وأن تُصمَّم حزمة المهارات والوكلاء نفسها لتعمل فوقها جميعًا يعني أن القدرة تراكمت في المهارات، لا في الإطار.

هذا التمييز مهم عمليًا. لو كانت معرفة سير عمل تسويقي محشوّة في ملفات إعداد أداة معيّنة أو مُطالبة نظامها، لعنى تبديل الأداة إعادة بناء كل شيء. وبالعكس، حين تعيش المعرفة في حزمة مهارات قابلة للنقل، يبقى الإطار رفيعًا وتُعاد المهارات عبر الأدوات. تثبيت Digital Marketing Pro عبر أوقات التشغيل ممارسة لمبدأ "إطار رفيع، مهارات سميكة" على نطاق تجاري.

بالطبع لدعم عدة أوقات تشغيل في آن تكلفة. فلأن كل وقت تشغيل يحمّل المهارات ويستدعيها بطريقة مختلفة قليلًا، قد يترك التصميم على القاسم المشترك ميزات فريدة لوقت تشغيل معيّن غير مستغلّة. ومع ذلك، إعطاء الأولوية لقابلية النقل توجّه معقول يحرّر أصول المهارات من الارتباط بأداة ويجعلها تصمد أطول.

## الأثر على منتجات ThakiCloud

ما يجعل هذه الحالة مثيرة أنها تعالج مشكلة تشبه بشكل لافت ما تبنيه ThakiCloud بـ**Paxis**. Paxis هي السحابة الأصلية للوكلاء من ThakiCloud، وتتعامل مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. يختار مسخّر المهارات المهارة المناسبة من بين أكثر من 960 مهارة عبر BM25، ويشغّلها في صندوق رمل معزول، ويمرّر كل إجراء عبر بوابات السياسة وسجلات التدقيق.

المشكلة نفسها التي حلّها Digital Marketing Pro بترويض 158 مهارة عبر تدفّق من 12 جزءًا، تحلّها Paxis على نطاق أكبر. فبمجرد تجاوز المهارات 960، يصل سؤال "أي مهارة ومتى" إلى نطاق لا يستطيع إنسان تحديده يدويًا، فيحلّ اختيار المهارات المعتمد على BM25 محلّ ذلك الهيكل. فبدلًا من استدعاء أي مهارة بحرية، تُطرح فقط المهارات الأوثق صلة بالطلب كمرشّحين، ما يقلّل درجات الحرية. هذا المبدأ نفسه الذي منع به التدفّق من 12 جزءًا الترتيب الحر، لكن بدل تدفّق ثابت يتحكم في الحرية عبر اختيار قائم على الاسترجاع.

كذلك، تأكيد المكوّن على الاستعداد للمادة 50 من قانون الذكاء الاصطناعي الأوروبي وإنتاج مستندات قابلة للتدقيق يتوافق مع تعامل Paxis مع سجلات التدقيق وبوابات السياسة كموارد من الدرجة الأولى. ففي بيئات العملاء حيث تهمّ التنظيمات والتدقيق، يجب أن تكون قادرًا على تتبّع "ما الذي أُنتج، وبأي ترتيب، وعلى أي أساس." التدفّق الحتمي وسجلات التدقيق هما المحوران اللذان يصنعان هذه القابلية للتتبّع، وتوفّرهما Paxis على مستوى المنصة. فمهما كدّست من مهارات، ولأن بوابات السياسة وسجلات التدقيق تسجّل كل إجراء، يمكن تشغيل أصل مهارات كبير بأمان حتى في بيئات منظّمة.

أخيرًا، قابلية النقل عبر أوقات التشغيل تتوافق مع الاتجاه الذي تسعى إليه ThakiCloud. فتصميم يعيد استخدام أصل مهارات عبر الأطر بدل ربطه بأداة معيّنة هو السبب نفسه لتعامل Paxis مع المهارات كموارد من الدرجة الأولى. حين تتراكم القدرة في المهارات لا في الإطار، تبقى الأصول التي بنيتها حتى مع تغيّر الأداة.

## القيود والاعتراضات

من المهم عدم المبالغة في قراءة هذه الحالة. التدفّق الثابت من 12 جزءًا يضحّي بالمرونة مقابل الاتساق. فالحاجة الاستثنائية التي تخرج عن التدفّق القياسي، مثل مهمة غير مهيكلة مطلوبة لعلامة معيّنة فقط، قد تُعالج بشكل محرج داخل هذا الهيكل أو لا تُعالج أصلًا. الهيكل الحتمي قوي للعمل المجمّع القابل للتكرار، لكنه يصبح قيدًا للعمل ذي الاستثناءات الإبداعية الكثيرة.

رقم 158 مهارة نفسه يستحق قراءة متأنّية. فكثرة المهارات تعني كثرة أهداف الصيانة، وما إذا كانت كل مهارة متحقَّقًا منها فعلًا ومُحدّثة مسألة منفصلة. الرقم لا يضمن الجودة. وكم عدد المهارات الأساسية التي يستدعيها التدفّق فعلًا، وكم مرة تُستخدم البقية، أمر يصعب تأكيده من وثائق المستودع وحدها [تقدير].

كذلك، يحلّل هذا المقال مبادئ تصميم المكوّن، لا الجودة الفعلية لمخرجاته التسويقية. فإنتاج تدفّق حتمي لمستندات متسقة مسألة مختلفة عمّا إذا كانت تلك المستندات تؤدّي إلى نتائج تسويقية حقيقية. ما نأخذه من هذه الحالة ليس النتيجة التسويقية بل النمط الهندسي في ترويض حزمة كبيرة من المهارات والوكلاء بهيكل حتمي.

## المصادر

- المستودع: [github.com/indranilbanerjee/digital-marketing-pro](https://github.com/indranilbanerjee/digital-marketing-pro)
- المصدر الأصلي: [تغريدة @tom_doerr](https://x.com/hjguyhan/status/2079315207579660557)
