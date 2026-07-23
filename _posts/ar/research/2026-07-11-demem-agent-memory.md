---
title: "تذكّر القرار لا الوصف: دراسة بمشاركة Meta تعيد صياغة ذاكرة الوكلاء كمسألة rate-distortion"
excerpt: "تعمل الوكلاء طويلة المدى ضمن ذاكرة محدودة، لكن أساليب الذاكرة حتى الآن كانت تنظّم الماضي وفق معايير وصفية مثل الصلة أو جودة التلخيص. هذه الورقة، التي شارك في تأليفها باحث من Meta AI، تقول إن هذا المعيار نفسه خاطئ. قيمة الذاكرة لا تكمن في وصف الماضي بأمانة، بل في الفصل بين المواقف التي تتطلب سلوكيات مختلفة حتى ضمن ميزانية ثابتة. يصوغ المؤلفون هذه المسألة كمسألة rate-distortion محورها القرار، ويقترحون خوارزمية تعلّم باسم DeMem تتفوق باستمرار على الأساليب القائمة عند نفس ميزانية الذاكرة."
tags:
  - agent-memory
  - rate-distortion
  - long-horizon-agents
  - llm-agents
  - paxis
date: 2026-07-11
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/demem-agent-memory/"
categories:
  - research
---

![رسم تجريدي يصوّر ذكريات تتفرّع إلى مسارات منفصلة تؤدي إلى قرارات مختلفة]({{ '/assets/images/demem-agent-memory-hero.png' | relative_url }})

> 📄 **المراجعة المتعمقة الكاملة (DOCX)**: [نزّل المراجعة التفصيلية من Google Drive](https://drive.google.com/file/d/1oxsADQALTfdn7I_mmZbaZfMnmqoCMF9o/view).

## نظرة عامة

كل من شغّل وكيلاً حوارياً لفترة طويلة رأى هذا الفشل من قبل. تفضيل أو قرار أعلنه المستخدم بوضوح قبل أيام ينساه الوكيل في لحظة ما، ويتصرف على عكسه. نافذة السياق محدودة، وعندما تطول المحادثة بما يكفي، يجب ضغط جزء من الماضي أو التخلص منه. السؤال الحقيقي هو: ماذا نتخلص منه؟

أجابت ذاكرة الوكلاء حتى الآن على هذا السؤال في الغالب بمعايير **وصفية**: هل هذا مرتبط بالموضوع؟ هل هو بارز؟ هل يُلخَّص بشكل جيد؟ تجادل هذه الورقة، "Remember the Decision, Not the Description" (arXiv 2605.10870)، التي شارك في تأليفها باحث من Meta AI، بأن هذا المعيار نفسه خاطئ. هذا المقال موجّه للمهندسين والباحثين الذين يصممون وكلاء الذكاء الاصطناعي، وللفرق التي تحتاج إلى وضع ذاكرة طويلة المدى في الإنتاج. نلخّص هنا إعادة الصياغة الجوهرية للورقة والنتائج التجريبية الداعمة لها، ونستعرض كيف ينطبق هذا المبدأ على Paxis، منصة الوكلاء لدى ThakiCloud.

## أين تكمن المشكلة

ينطلق المؤلفون من رؤية بسيطة. الذاكرة قيّمة للوكيل ليس لأنها تصف الماضي بأمانة، بل لأنها **تحافظ على الفصل بين تاريخَين يتطلبان سلوكَين مختلفَين حتى ضمن ميزانية ثابتة**.

لنأخذ مثالاً بسيطاً. قال المستخدم بالأمس: "يجب ألا يتم هذا النشر إلا بعد موافقة يدوية". واليوم، في سياق مشابه، قال: "يمكن تشغيل هذا السكربت تلقائياً". العبارتان متشابهتان جداً في ظاهرهما. تتقاطعان في كلمات مثل النشر والتنفيذ والموافقة، وعند تلخيصهما تصبحان تقريباً نفس الجملة. من السهل أن تدمج الذاكرة القائمة على الصلة هاتين الحالتين في كتلة واحدة توصف بـ"تعليمات متعلقة بالنشر". في تلك اللحظة يفقد الوكيل القدرة على تمييز أي تعليمة تنطبق على أي موقف، ويرتكب خطأ دفع نشر يتطلب موافقة يدوية بشكل تلقائي. الملخّص صحيح وصفياً، لكن الدمج قاتل من حيث القرار.

نمط الفشل الملموس هو كالتالي. موقفان يبدوان متشابهَين نصياً لكنهما في الواقع يتطلبان إجراءَين متعارضَين. عندما تكون ميزانية الذاكرة ضيقة، يصبح الضغط ضرورياً، والضغط يستدعي حتماً الدمج. إذا نظرنا فقط إلى التشابه الوصفي، سيُدمج هذان الموقفان في واحد. والنتيجة أن الوكيل يتخذ قراراً خاطئاً باستمرار كلما وصل إلى تلك الحالة. الصلة أو جودة التلخيص لا تجيبان عن السؤال الحقيقي، وهو: هل يمكن دمج هذين حقاً؟ المعيار يجب ألا يكون ما يبدو متشابهاً، بل ما يتطلب سلوكاً مختلفاً.

## الفكرة الجوهرية: rate-distortion محوره القرار

ينقل المؤلفون هذه المشكلة إلى إطار نظرية المعلومات الخاص بـ rate-distortion. تتناول نظرية rate-distortion أصلاً مقدار التشويه (distortion) الناتج عن قدر معين من الضغط (rate)، والخطوة المحورية هنا هي إعادة تعريف التشويه نفسه. بدلاً من أن يكون التشويه خطأ إعادة بناء الإشارة، يُعرَّف كـ **الخسارة في جودة القرار القابلة للتحقيق نتيجة الضغط (decision loss)**.

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
<div class="d3-arch" data-arch-root id="20260711dememagentmemory-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 514, "height": 888, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 166, "y": 24, "w": 177, "h": 62, "title": ["تاريخ تفاعل طويل", "(ميزانية ذاكرة ثابتة)"]}, {"id": "B", "x": 171, "y": 164, "w": 167, "h": 52, "title": "هل ندمج الموقفين؟"}, {"id": "C", "x": 302, "y": 294, "w": 163, "h": 78, "title": ["معيار محوره الوصف", "الصلة، البروز، جودة", "التلخيص"]}, {"id": "D", "x": 31, "y": 294, "w": 191, "h": 78, "title": ["معيار محوره القرار", "هل تسبب الحالة المشتركة", "تعارضاً في القرار"]}, {"id": "E", "x": 284, "y": 450, "w": 198, "h": 94, "title": ["الدمج إذا بدا الموقفان", "متشابهَين", "-> دمج سلوكَين متعارضَين", "في واحد"]}, {"id": "F", "x": 309, "y": 646, "w": 149, "h": 46, "title": "أخطاء قرار مستمرة"}, {"id": "G", "x": 24, "y": 458, "w": 205, "h": 78, "title": ["الفصل فقط عند إثبات تعارض", "القرار", "certified refinement"]}, {"id": "H", "x": 28, "y": 622, "w": 198, "h": 94, "title": ["حدّ نسيان دقيق (exact", "forgetting boundary)", "+ حدود memory-distortion", "frontier"]}, {"id": "I", "x": 35, "y": 794, "w": 184, "h": 62, "title": ["جودة قرار أفضل عند نفس", "الميزانية"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [255, 86, 255, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[306, 216], [383, 255], [383, 255], [383, 294]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[203, 216], [127, 255], [127, 255], [127, 294]]}, {"src": "C", "dst": "E", "kind": "data", "line": [383, 372, 383, 450]}, {"src": "E", "dst": "F", "kind": "data", "line": [383, 544, 383, 646]}, {"src": "D", "dst": "G", "kind": "data", "line": [127, 372, 127, 458]}, {"src": "G", "dst": "H", "kind": "data", "line": [127, 536, 127, 622]}, {"src": "H", "dst": "I", "kind": "data", "line": [127, 716, 127, 794]}]});
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
      const container = document.getElementById('20260711dememagentmemory-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260711dememagentmemory-1';
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

إليكم تشبيهاً. عند ضغط الصوت، نتخلص أولاً من الترددات التي لا تسمعها الأذن البشرية، لأن معيار التشويه هو "ما يسمعه الإنسان". يرى المؤلفون أن ذاكرة الوكلاء يجب أن تعمل بالطريقة نفسها. ما يجب التخلص منه ليس "الذكرى التي تبدو أقل صلة"، بل "الذكرى التي لن يتغير أي قرار مستقبلي لو حذفناها". هنا، rate هو ميزانية الذاكرة، وdistortion هو خسارة القرار التي يسببها هذا الضغط. إذا لم يؤدِّ دمج موقفَين في نفس الخانة إلى أي قرار خاطئ مستقبلاً، فإن هذا الدمج مجاني. وعلى العكس، إذا كان الدمج يطمس سلوكَين متعارضَين، فهو تشويه باهظ الثمن.

يترتب على هذا التعريف أمران. أولاً، **حد النسيان الدقيق (exact forgetting boundary)**، الذي يحدد بدقة حدود ما يمكن نسيانه بأمان دون الإضرار بجودة القرار. ثانياً، **حدود memory-distortion frontier**، التي تصف منحنى المفاضلة الأمثل بين ميزانية الذاكرة وجودة القرار. بعبارة أخرى، تضع الورقة نظرياً حداً أدنى مفاده: "إذا خفّضت الميزانية بهذا القدر، فستنخفض جودة القرار حتماً بمقدار لا يقل عن كذا".

## DeMem: تحويل النظرية إلى خوارزمية

DeMem هي التي تنقل هذه النظرية إلى ذاكرة وكيل فعلية قائمة على الخانات (slots). DeMem خوارزمية تعلّم ذاكرة عبر الإنترنت (online)، وتعمل وفق مبدأ واحد: **لا تُقسِّم قسمة الذاكرة (partition) إلا عندما تُثبت البيانات (certify) أن حالة مشتركة تسبب تعارضاً في القرار.**

كلمة "تُثبت" هنا مهمة. لا يُفصل الموقفان بمجرد أن يبدوا مختلفَين، بل يُفصلان فقط بعد أن تتراكم أدلة فعلية على أن نفس حالة الذاكرة تتطلب قرارَين مختلفَين. وعلى العكس، إذا لم تتوفر مثل هذه الأدلة، يُبقى على الدمج توفيراً للميزانية. هذا التحفظ هو جوهر الطريقة. الفصل المتسرع يهدر الميزانية ولا يترك مكاناً للتمييزات المهمة فعلاً، بينما الدمج المتسرع يطمس سلوكيات متعارضة. certified refinement هو الانضباط الذي ينتظر، بين هذين الحدين، حتى تتحدث البيانات. يثبت المؤلفون أن هذا الإجراء يحقق ضماناً من نوع near-minimax regret، أي أن الندم (regret) بالمقارنة مع الأمثل يظل، حتى في أسوأ الحالات، مقيداً قريباً من الحد النظري.

يتحقق المؤلفون من هذه الآلية على مستويَين. أولاً، في بيئة تشخيصية اصطناعية، يصممون مهاماً يتعمدون فيها جعل التشابه الوصفي والتشابه القراري متباعدَين. هنا، تستمر المعايير الوصفية فقط في دمج المواقف المتشابهة ظاهرياً، مما يراكم الندم، بينما يتجنب DeMem هذا الفخ بالفصل فقط عند إثبات تعارض القرار. بعد ذلك، يتحققون مما إذا كانت هذه الأفضلية تنتقل إلى معايير قياس محادثات طويلة المدى فعلية، عبر نماذج تجارية ونماذج مفتوحة الأوزان على حد سواء. هذا البناء الذي ينطلق من النظرية، ويمر عبر تحقق آلي مضبوط، وينتهي عند معايير قياس واقعية، يحوّل النتائج إلى تفسير لـ"لماذا يفوز"، لا مجرد جدول أداء.

## نتائج التجارب

في التشخيص الاصطناعي، سجّل DeMem أدنى ندم تراكمي (cumulative regret) بين جميع الأساليب المتساوية في الميزانية، واتسعت الأفضلية كلما زادت الفجوة بين التشابه الوصفي والتشابه القراري. بينما استمرت المعايير الوصفية فقط في دمج المواقف المتعارضة منتجةً أخطاء مستمرة، تجنّب DeMem ذلك بالفصل فقط عند إثبات تعارض القرار.

استمرت النتائج في معايير القياس الفعلية أيضاً. فيما يلي القيم المقاسة للدرجة الإجمالية على LoCoMo (بنموذج GPT-4.1-mini الأساسي).

| الطريقة | Overall | Temporal |
|---|---|---|
| **DeMem** | **0.921** | **0.908** |
| Mnemis | 0.891 | 0.858 |
| EMem-G | 0.757 | 0.660 |
| Nemori | 0.731 | 0.454 |
| RAG | 0.710 | 0.634 |
| FullContext | 0.692 | 0.511 |
| Zep | 0.554 | 0.383 |
| Mem0 | 0.514 | 0.428 |

حقق DeMem أفضل درجة إجمالية، وكان قوياً بشكل خاص في فئات Temporal وOpen-Domain وMulti-Hop، حيث يكون الحفاظ على التمييز بين تفاعلات بعيدة زمنياً أمراً حاسماً. أما في فئة Single-Hop، التي تتعلق باسترجاع حقيقة واحدة، فقد تفوّق Mnemis (0.940) على DeMem (0.935) بفارق ضئيل، وهو ما يتفق مع تفسير أن فائدة الفصل المحوري بالقرار تكون أصغر في الاسترجاع أحادي الخطوة. وفي LongMemEval أيضاً، حقق DeMem أفضل متوسط درجات على كلا النموذجَين الأساسيَين، وكانت أكبر المكاسب في الفئات التي تتطلب دمجاً عبر جلسات متعددة. والأهم أن الأفضلية استمرت حتى على النموذج مفتوح الأوزان Llama-3.1-70B، مما يدل على أن هذه الميزة ليست مرتبطة بنموذج تجاري معين.

## دلالات على منتجات ThakiCloud

تلتقي رؤية هذه الورقة تماماً مع تصميم الذاكرة في Paxis، مستوى التحكم لمنصة Agent-Native Cloud لدى ThakiCloud. Paxis هو مستوى تحكم يعمل فوق ai-platform ويتعامل مع المهارات (skills) والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى، وضمن ذلك يحدد محرك المعرفة وطبقة الذاكرة يومياً ما الذي يُدمج وما الذي يُفصل.

أولاً، يمكن نقل معيار الدمج في محرك معرفة HKE Wiki ليصبح محورياً بالقرار. إذا دُمجت العناصر المتشابهة بمجرد التشابه النصي، فهناك خطر أن تُدمج حالتان تتطلبان إجراءَين متعارضَين في واحدة. وضع بوابة قبل الدمج مباشرة تسأل "هل يسبب هذان الأمران سلوكَين مختلفَين؟" هو نقل مباشر لمبدأ certified refinement في هذه الورقة.

ثانياً، يمنح هذا أساساً نظرياً لإدارة ميزانية الذاكرة الساخنة المقيمة في الجلسة (session-resident hot memory). الذاكرة الساخنة تفرض بالفعل ميزانيتها بحد أقصى من الأحرف، ومحاذاة معيار ما يُبقى وما يُحذف مع مبدأ "الحفاظ على التمييزات المؤثرة في القرار" يرفع جودة التقليم (pruning). أي إعطاء الأولوية للعناصر التي تفرّق بين القرارات، لا العناصر التي تُلخَّص بسلاسة.

ثالثاً، تُعد بوابات السياسات وسجلات التدقيق التي يخلّفها Paxis مصدر بيانات طبيعياً لإثبات لاحقاً أن "نفس الحالة أفضت إلى قرار مختلف". إذا كان تشغيل certified refinement عبر الإنترنت لدى DeMem في الوقت الفعلي صعباً، يمكن اتباع مسار عملي بتحليل سجلات التدقيق هذه على دفعات غير متصلة (offline) وتحديث سياسة الدمج والفصل بشكل دوري. وهنا يلتقي مبدأ الذاكرة المحورية بالقرار مع التنسيق (orchestration) القائم على التدقيق الذي يجعل هذا المبدأ قابلاً للتكرار بأمان.

## القيود والاعتراضات

لا بد من توضيح بعض النقاط.

أولاً، الإثبات (certify) له تكلفة. إثبات تعارض القرار من البيانات يتطلب تراكم ملاحظات، وفي بيئات البداية الباردة (cold start) أو التفاعل النادر، يتأخر الفصل، ولذلك يصعب الحكم من نص الورقة وحده على مصير جودة القرار في المراحل المبكرة.

ثانياً، تقدير "خسارة جودة القرار" عبر الإنترنت في بيئة الإنتاج يتطلب إشارة مكافأة أو حكماً (judge). تملك معايير القياس إجابات صحيحة تجعل الحصول على هذه الإشارة سهلاً، لكن كيفية تأمين هذه الإشارة في محادثات فعلية بلا إجابة صحيحة تبقى مهمة قادمة. قد يكون استخدام سجلات التدقيق المقترح أعلاه أحد الحلول، لكن ذلك خارج نطاق الورقة.

ثالثاً، يتضمن الملحق إثباتاً لصعوبة حسابية (computational hardness)، وهو ما يعني أن إيجاد القسمة (partition) المثلى صعب بشكل عام. DeMem هو تقريب عملي لذلك، وتلزم حدود إضافية حول الشروط التي ينهار عندها هذا التقريب.

ومع ذلك، فإن المبدأ نفسه، وهو نقل ذاكرة الوكيل من الوصف إلى القرار، بسيط وقوي، ويستحق النظر في تبنّيه الآن. إذا كان الوكيل ينسى باستمرار قراراته السابقة، فقد لا تكون المشكلة أن ذاكرته صغيرة، بل أن ذاكرته تحتفظ بالشيء الخطأ.

> 📄 **المراجعة المتعمقة الكاملة (DOCX)**: [نزّل المراجعة التفصيلية من Google Drive](https://drive.google.com/file/d/1oxsADQALTfdn7I_mmZbaZfMnmqoCMF9o/view).

## المصادر

- الورقة: [Remember the Decision, Not the Description: A Rate-Distortion Framework for Agent Memory (arXiv 2605.10870)](https://arxiv.org/abs/2605.10870)
- معايير القياس: LoCoMo، LongMemEval / النماذج الأساسية: GPT-4o-mini، GPT-4.1-mini، Qwen2.5-14B-Instruct، Llama-3.1-70B
- الأرقام في الجدول مقتبسة من الجدول 1 (LoCoMo، GPT-4.1-mini) في الورقة.
