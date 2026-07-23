---
title: "لم يخترق Hugging Face بشرٌ بل وكيل ذكاء اصطناعي ذاتي: عندما صار خط معالجة البيانات سطح الهجوم"
excerpt: "في يوليو 2026 كشف Hugging Face عن اختراق داخلي قاده وكيل ذكاء اصطناعي ذاتي. كانت نقطة الدخول مجموعة بيانات خبيثة واحدة، وأدت ثغرتان في خط معالجة مجموعات البيانات إلى تنفيذ التعليمات البرمجية. نفصل ما تأكد عمّا لا يزال قيد التحقيق، ونشرح لماذا يجب التعامل مع معالجة البيانات بوصفها حدّ ثقة."
seo_title: "اختراق Hugging Face عبر وكيل ذكاء اصطناعي ذاتي: خط البيانات كسطح هجوم"
seo_description: "تحليل لكيفية اختراق Hugging Face عبر وكيل ذكاء اصطناعي ذاتي من خلال ثغرتي تنفيذ تعليمات برمجية (محمّل بيانات بتنفيذ عن بُعد وحقن قوالب في إعداد مجموعة البيانات) أطلقتهما مجموعة بيانات خبيثة. ما المؤكد وما لا يزال مفتوحًا، وكيف يعامل العزل بالصناديق الرملية مع السياسات والتدقيق معالجة البيانات بوصفها حدّ ثقة."
date: 2026-07-21
last_modified_at: 2026-07-21
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "shield-alt"
tags:
  - security
  - huggingface
  - ai-agent
  - supply-chain
  - sandbox
  - dataset-security
  - news
  - thakicloud
categories:
  - news
canonical_url: "https://thakicloud.com/tech-blog/ar/news/huggingface-agentic-ai-breach/"
---

![صورة تجريدية لسرب من الوكلاء الذاتيين يتسلل إلى خط بيانات]({{ '/assets/images/huggingface-agentic-ai-breach-hero.png' | relative_url }})

الخبر الذي هزّ التسلسلات الزمنية في نهاية الأسبوع لم يكن نموذجًا جديدًا ولا معيارًا جديدًا، بل إشعارًا بأن Hugging Face، مركز منظومة الذكاء الاصطناعي المفتوحة، قد اُخترق. وما لفت الانتباه أكثر هو من فعل ذلك. فبحسب الشركة، لم يجلس قرصان بشري ليكتب الأوامر طوال الليل، بل قاد إطار وكيل ذكاء اصطناعي ذاتي الهجوم من أوله إلى آخره.

إن اختراق شركة تبيع النماذج على يد نموذج يشكّل حكاية لافتة. لكن هدف هذه المقالة ليس استهلاك تلك المفارقة. فبالنسبة لشركة مثل ThakiCloud تتعامل مع النماذج والبيانات فوق بنية تحتية للعملاء، فإن العمل الحقيقي هو التمييز بهدوء بين المكان الذي دخل منه الهجوم بالضبط وما الذي تأكد. ونقطة الدخول هنا لم تكن ثغرة يوم صفري براقة، بل الشيء الذي نلمسه كل يوم: مجموعة بيانات.

## ماذا حدث

كشف Hugging Face عن الاختراق في تدوينة يوم الخميس 16 يوليو 2026. جاء ذلك بعد أن أكدت الشركة في وقت سابق من ذلك الأسبوع وصولًا غير مصرّح به إلى مجموعات بيانات وبيانات اعتماد داخلية، واحتوت التسلل. وبحسب رواية الشركة، بدأ التسلل في خط معالجة البيانات، حيث استخدم المهاجم مجموعة بيانات خبيثة واحدة لفتح مسارَي تنفيذ للتعليمات البرمجية.

هذا هو الهيكل المؤكد: قاده وكيل ذاتي، وكانت نقطة الدخول مجموعة بيانات، وأدّت ثغرتان إلى تنفيذ التعليمات البرمجية. أما التفاصيل المتبقية فتختلف نقاط تركيزها من منصة إلى أخرى، لذا يجب قراءة الحقائق المؤكدة بمعزل عن التقارير الثانوية.

## مسار الهجوم: خط معالجة البيانات كان سطح الهجوم

الجوهر هو أسلوب الدخول. رفع المهاجم مجموعة بيانات خبيثة إلى Hugging Face Hub. وفي اللحظة التي مرّت فيها تلك المجموعة عبر خط المعالجة، انطلقت ثغرتان تباعًا. الأولى مسار محمّل بيانات بتنفيذ عن بُعد، والثانية حقن قوالب أثناء تحليل إعداد مجموعة البيانات. وكلتاهما انتهتا إلى تنفيذ تعليمات برمجية اعتباطية.

قد تبدو فكرة أن مجموعة بيانات يمكنها تشغيل التعليمات البرمجية غريبة، لكن الممارسين يعرفون هذا الخطر جيدًا. فكثير من محمّلات البيانات تثق في نصوص التحميل من المستودعات البعيدة وتنفّذها، وتعرض حقول الإعداد كقوالب. تلك المرونة، المصممة للراحة، تصبح قناة تنفيذ في اللحظة التي تلتقي فيها بمدخل يعبر حدّ الثقة.

وما تلا تأمين تنفيذ التعليمات البرمجية كان سلسلة اختراق نموذجية. رفع المهاجم صلاحياته بوصول على مستوى العقدة، وجمع بيانات اعتماد السحابة والعناقيد، وتحرك أفقيًا إلى عدة عناقيد داخلية خلال عطلة نهاية الأسبوع. كان الدخول نقطة واحدة، لكن من اللحظة التي منحت فيها تلك النقطة صلاحيات التنفيذ، انتشر الأمر تلقائيًا.

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
<div class="d3-arch" data-arch-root id="ggingfaceagenticaibreach-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 514, "height": 1130, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 163, "y": 24, "w": 170, "h": 62, "title": ["المهاجم: يرفع مجموعة", "بيانات خبيثة"]}, {"id": "B", "x": 142, "y": 164, "w": 212, "h": 46, "title": "خط معالجة مجموعات البيانات"}, {"id": "C1", "x": 270, "y": 296, "w": 212, "h": 62, "title": ["الثغرة 1", "remote-code dataset loader"]}, {"id": "C2", "x": 24, "y": 288, "w": 191, "h": 78, "title": ["الثغرة 2", "dataset config template", "injection"]}, {"id": "D", "x": 163, "y": 444, "w": 170, "h": 62, "title": ["تنفيذ تعليمات برمجية", "اعتباطية RCE"]}, {"id": "E", "x": 156, "y": 584, "w": 184, "h": 62, "title": ["الحصول على وصول بمستوى", "العقدة"]}, {"id": "F", "x": 145, "y": 724, "w": 205, "h": 62, "title": ["جمع بيانات اعتماد السحابة", "والعناقيد"]}, {"id": "G", "x": 156, "y": 864, "w": 184, "h": 62, "title": ["تحرك أفقي إلى العناقيد", "الداخلية"]}, {"id": "H", "x": 145, "y": 1004, "w": 205, "h": 94, "title": ["إطار وكيل ذاتي", "آلاف الإجراءات عبر سرب من", "الصناديق الرملية قصيرة", "العمر"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [248, 86, 248, 164]}, {"src": "B", "dst": "C1", "kind": "data", "curve": [[295, 210], [376, 249], [376, 249], [376, 296]]}, {"src": "B", "dst": "C2", "kind": "data", "curve": [[200, 210], [120, 249], [120, 249], [120, 288]]}, {"src": "C1", "dst": "D", "kind": "data", "curve": [[376, 358], [376, 405], [376, 405], [305, 444]]}, {"src": "C2", "dst": "D", "kind": "data", "curve": [[120, 366], [120, 405], [120, 405], [191, 444]]}, {"src": "D", "dst": "E", "kind": "data", "line": [248, 506, 248, 584]}, {"src": "E", "dst": "F", "kind": "data", "line": [248, 646, 248, 724]}, {"src": "F", "dst": "G", "kind": "data", "line": [248, 786, 248, 864]}, {"src": "G", "dst": "H", "kind": "data", "line": [248, 926, 248, 1004]}]});
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
      const container = document.getElementById('ggingfaceagenticaibreach-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ggingfaceagenticaibreach-1';
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

## وزن القول إن وكيلًا ذاتيًا قاد الهجوم

الجزء الجديد في هذا الحادث ليس الأدوات بل مقعد القيادة. وصف Hugging Face الحملة بأنها "إطار وكيل ذاتي ينفّذ آلاف الإجراءات الفردية عبر سرب من الصناديق الرملية قصيرة العمر، مع قناة قيادة وتحكم تنتقل بنفسها فوق خدمات عامة". فبدلًا من تدخل بشري في كل خطوة، تولّى الوكيل الاستطلاع والتنفيذ والتحرك في سلسلة متصلة.

المشكلة التي يطرحها هذا البناء على المدافعين هي السرعة والحجم. فالمهاجم البشري لديه حدود مادية من التعب وسرعة الكتابة، أما سرب الوكلاء فيلقي بآلاف المحاولات على التوازي وينتقل إلى التالية فور فشل خطوة. واستخدام الصناديق الرملية قصيرة العمر ثم التخلص منها يمحو مراسي الاكتشاف، وقناة القيادة والتحكم التي تنتقل عبر خدمات عامة تُبطل قوائم الحظر.

دار هامش مثير للاهتمام في التقارير الثانوية. فمع تطور الاستجابة، عندما حاول الفريق تسليم التحليل الجنائي إلى نماذج تجارية متقدمة (GPT، Claude)، يُقال إن حواجز الأمان اعتبرت حمولات الاستغلال وآثار القيادة والتحكم هجمات ورفضت التعاون، فواصل الفريق الاكتشاف والتحليل بنموذج من فئة GLM 5.2 [تقديري]. تأتي هذه التفصيلة من بعض المنصات لا من الإشعار الرسمي لـ Hugging Face، لذا من الأسلم عدم قراءتها كحقيقة مؤكدة. لكن بصرف النظر عن دقتها، فإن التوتر نفسه، حيث لا يستطيع المدافع استخدام أداة بسبب سياسة أمانها، جدير بالتسجيل بوصفه أمرًا قد يتكرر.

## ما الذي كان آمنًا وما لا يزال قيد التحقيق

كلما كان الحادث أسهل للمبالغة، وجب رسم الحدود بوضوح أكبر. قال Hugging Face إنه أغلق مسارات تنفيذ التعليمات البرمجية المعرّضة، وطرد المهاجم، وأعاد بناء العقد المخترقة، وأبطل جميع بيانات الاعتماد المتأثرة وبدّلها. وأضاف أنه لم يجد دليلًا على العبث بالنماذج العامة أو مجموعات البيانات الموجهة للمستخدمين أو Spaces، وأن سلسلة توريد البرمجيات لديه، بما فيها صور الحاويات والحزم المنشورة، تم التحقق من نظافتها.

كان إجراء المستخدمين توصية احترازية. نصحت الشركة المستخدمين بتبديل رموز الوصول ومراجعة نشاط الحساب الأخير. وهنا تمييز مهم. تلك التوصية ليست تأكيدًا على تسرّب رموز المستخدمين بالجملة، بل تدبير أمان محافظ نظرًا لطبيعة حادث سُرقت فيه بيانات اعتماد داخلية. أما ما إذا كانت بيانات الشركاء أو العملاء قد تأثرت فكان، حتى وقت الكشف، لا يزال قيد التحقيق.

باختصار، المؤكد هو الاختراق الداخلي وسرقة بيانات الاعتماد، ووجود ثغرتين في البيانات، والاحتواء والتبديل السريعان. وما يبقى مفتوحًا هو ما إذا كانت بيانات الشركاء والعملاء قد تأثرت، وتأكيد بعض التفاصيل في التقارير الثانوية (العدد الدقيق للإجراءات، وحكاية رفض النموذج). خلط المؤكد بغير المؤكد يجعل الحادث يبدو أكبر أو أصغر مما هو عليه.

## منظور ThakiCloud: التعامل مع معالجة البيانات بوصفها حدّ ثقة

الدرس الذي يقدمه هذا الحادث لشركة بنية تحتية واضح. مجموعة البيانات ليست ملفًا سلبيًا بل مدخلًا نشطًا يمكنه تنفيذ التعليمات البرمجية في اللحظة التي تُعالَج فيها. لذا ننظر إلى هذا عبر عدستين.

**عبر عدسة ai-platform**، منصة ai-platform من ThakiCloud هي بنية تحتية للذكاء الاصطناعي وتعلم الآلة متعددة المستأجرين قائمة على K8s. في مثل هذه البيئة، يجب التعامل مع تحميل البيانات ومعالجتها الأولية بوصفها مدخلًا من خارج حدّ الثقة لا من داخله. وعمليًا، يعني ذلك تشغيل مهام معالجة البيانات في حاويات معزولة بأدنى صلاحيات، وحجب المخرج الشبكي افتراضيًا، وفصل بيانات اعتماد العقدة والسحابة بحيث لا تلمسها أحمال العمل مباشرة. إن انتشار هذا الاختراق من الوصول بمستوى العقدة إلى سرقة بيانات الاعتماد يُظهر مجددًا لماذا يجب أن يكون عزل التنفيذ وفصل بيانات الاعتماد افتراضًا لا خيارًا. وهذا أيضًا سبب ارتفاع الطلب على الذكاء الاصطناعي المحلي والسيادي: فكلما بقيت البيانات والتنفيذ داخل حدود العميل، صغُر نطاق انفجار مثل هذه الهجمات على خط المعالجة.

**عبر عدسة Paxis**، يتداخل هذا الحادث تمامًا مع نموذج التهديد الذي صُممت له سحابة أصلية للوكلاء منذ البداية. Paxis هي سحابة ThakiCloud الأصلية للوكلاء، وتعتبر تشغيل المهارات والأدوات في صناديق رملية معزولة وتمرير كل إجراء عبر بوابة سياسة وسجل تدقيق مبادئ من الدرجة الأولى. إن إلقاء المهاجم آلاف الإجراءات بسرب وكلاء ذاتي يثبت بالضبط لماذا يلزم بناء يفحص سلوك الوكيل بالسياسة قبل التنفيذ ويسجله في سجل تدقيق بعد التنفيذ. ولمواجهة نمط هجوم يستخدم صناديق رملية قصيرة العمر ثم يتخلص منها، يجب على المدافع أيضًا عزل كل تنفيذ، وتحديد نطاق صلاحياته صراحةً، وترك أثر تدقيق قابل للعكس. التنفيذ المعزول مع السياسة والتدقيق ليس ترفًا في عصر الوكلاء بل حدًا أدنى من المتطلبات.

تتكامل العدستان. تضيّق ai-platform نطاق الانفجار في طبقة البنية التحتية لمعالجة البيانات، بينما تفحص Paxis كل إجراء في طبقة التحكم لسلوك الوكيل. في هجوم كهذا، حيث الدخول خط بيانات والانتشار وكيل ذاتي، يلزم الدفاع في الطبقتين لكسر السلسلة.

## الحدود والاعتراضات

تجنبًا للثقة المفرطة في استنتاجات هذه المقالة، ينبغي توضيح بضعة أمور. أولًا، لا تزال تفاصيل الحادث قيد الاستقرار. التفاصيل الملونة مثل العدد الدقيق للإجراءات، ونطاق سرقة بيانات الاعتماد، وحكاية رفض النموذج التجاري، تعتمد بشدة على التقارير الثانوية ويجب تمييزها عن الحقائق المؤكدة في الإشعار الرسمي.

ثانيًا، سرديتنا الدفاعية لا تعني الأمان الكامل. العزل والسياسة والتدقيق مبادئ تصميم تقلّص نطاق الانفجار، لا سحرًا يزيل الثغرات نفسها. ثغرات مثل تنفيذ التعليمات البرمجية عن بُعد في محمّل بيانات أو الحقن في تحليل الإعداد يجب أن تستمر ملاحقتها وترقيعها على مستوى الشيفرة، والعزل هو خط الدفاع الثاني الذي يحتوي الضرر عند انطلاق مثل تلك الثغرة.

ثالثًا، المبالغة في تقدير هجمات الوكلاء الذاتيين خطرة أيضًا. لم يكن السبب الجذري لهذا الاختراق ذكاءً اصطناعيًا متطورًا بل ثغرتين مألوفتين سمحتا لمدخل يعبر حدّ الثقة بتنفيذ التعليمات البرمجية. لم يكن الوكيل سوى الأتمتة التي استغلت تلك الثغرتين بسرعة واتساع أكبر. لذا تبقى أولوية الاستجابة في الأساسيات: فصل المدخلات غير الموثوقة عن صلاحيات التنفيذ، وفصل بيانات الاعتماد عن أحمال العمل، وجعل كل تنفيذ قابلًا للرصد.

سيبقى احتواء Hugging Face السريع وكشفه الشفاف مثالًا جيدًا على الاستجابة. وما يبقى من واجب علينا بسيط: التعامل مع مجموعات البيانات بوصفها شيفرة لا ملفات، وجعل كل إجراء للوكيل موضوعًا للفحص والتدقيق.

## المصادر

- [Security incident disclosure, July 2026 (مدونة Hugging Face الرسمية)](https://huggingface.co/blog/security-incident-july-2026)
- [Hugging Face breached by autonomous AI agent (Help Net Security)](https://www.helpnetsecurity.com/2026/07/20/hugging-face-breached-by-autonomous-ai-agent/)
- [Hugging Face warns an autonomous AI agent hacked its network (BleepingComputer)](https://www.bleepingcomputer.com/news/security/hugging-face-breach-autonomous-ai-agent-system-internal-datasets-credentials/)
- [World's Largest AI Model Repository Hugging Face Breached by Autonomous AI Agent (The Hacker News)](https://thehackernews.com/2026/07/worlds-largest-ai-model-repository.html)
- تقارير ثانوية (العدد الدقيق للإجراءات وحكاية رفض النموذج تقارير منقولة لا حقائق مؤكدة): Cryptobriefing, Undercode Testing
