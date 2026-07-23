---
title: "ترميز المعرفة التخصصية كبنية تحتية: إعادة تعريف الأتمتة في عصر الوكلاء"
seo_title: "المعرفة التخصصية كبنية تحتية - الأتمتة في عصر الوكلاء - Thaki Cloud"
seo_description: "يرى Boris Cherny أن الأتمتة، وهي أكثر الأنشطة قيمة بالنسبة للمهندس، أصبحت أكثر أهمية في عصر الوكلاء. عندما يتم ترميز المعرفة التخصصية إلى ما هو أبعد من قواعد lint واختبارات e2e، لتشمل CLAUDE.md والمهارات وقواعد المراجعة والذاكرة، يصبح بإمكان الوكلاء وغير المهندسين المساهمة في قاعدة الكود منذ اليوم الأول. نراجع بالأرقام الفعلية مدى التزام ThakiCloud بهذا المبدأ، عبر 52 قاعدة و آلاف المهارات و41 أتمتة تعمل بلا إشراف بشري."
excerpt: "إذا لم يستطع الوكيل العمل بفعالية داخل قاعدة الكود، فذلك ليس فشلا في النموذج، بل فشل في الأتمتة. نقل المعرفة التخصصية إلى البنية التحتية هو امتداد طبيعي لما اعتاد المهندسون فعله دائما."
date: 2026-07-16
tags:
  - agent-native-development
  - domain-knowledge
  - claude-md
  - agent-harness
  - developer-experience
  - agentops
  - paxis
  - automation
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/domain-knowledge-as-infrastructure/"
lang: ar
---

## نظرة عامة

شارك Boris Cherny، الذي بنى Claude Code في Anthropic، فكرة تستحق التوقف عندها. خلاصة رأيه بسيطة. أفضل المهندسين قضوا دائما جزءا كبيرا من وقتهم في أتمتة عملهم الخاص: ماكرو محرر أفضل، قواعد lint تلتقط الأخطاء المتكررة، ومجموعات اختبارات e2e تلغي الحاجة إلى اختبار يدوي سريع. كانت هذه الأتمتة أعلى نشاط ذي قيمة لأنها ضاعفت الإنتاجية.

يذهب رأيه خطوة أبعد. في عصر الوكلاء، أصبحت هذه الأتمتة نفسها أكثر أهمية مما كانت عليه من قبل. يفصل هذا المقال هذه الفكرة إلى ثلاثة محاور، ثم يختتم بمراجعة صادقة لمدى ممارسة ThakiCloud لهذا المبدأ فعليا، بالاستناد إلى أرقام مستودعنا الفعلية. هذا ليس مديحا ذاتيا، بل تدقيق يتأكد مما إذا كانت البنية التحتية التي بنيناها تحمل المعرفة التخصصية فعلا، أم أنها تبدو كذلك فحسب.

## لماذا تغيرت مكانة الأتمتة

رفع ظهور الوكلاء قيمة الأتمتة لثلاثة أسباب.

أولا، تزيد أتمتة البنية التحتية وتجربة المطور من السرعة، وإذا كنت تشغل عدة وكلاء في آن واحد، يصبح كل وكيل منهم أسرع أيضا. مع تزايد الأتمتة يزداد الناتج لكل وحدة زمن، لكن الجهة المنتجة لهذا الناتج لم تعد شخصا واحدا، بل عدة وكلاء. لقد تغير حجم المضاعف نفسه.

ثانيا، نقل العمل إلى الكود يرفع الكفاءة. يستطيع الوكيل إصلاح المشكلة نفسها يدويا في كل مرة يواجهها، لكن ذلك يستهلك التوكنات وقد يفوت حالات معينة. بدلا من ذلك، بمجرد أن يكتب الوكيل قاعدة lint أو خطوة CI أو روتينا واحدا، تصبح تلك الفئة من المشكلات مؤتمتة إلى الأبد. هذا هو المعنى الحقيقي لما يسميه الناس عادة الحلقة أو loop. الأمر لا يتعلق بحل مشكلة فردية، بل بأتمتة فئة المشكلة بأكملها. وهذه ليست فكرة جديدة، فقد عمل المهندسون بهذه الطريقة منذ زمن طويل.

ثالثا، والأهم من ذلك، تجعل الأتمتة مساهمة الآخرين في قاعدة الكود أسهل. من المشاهد التي أصبحت شائعة أن يساهم مهندس في يومه الأول بفضل قدرة الوكيل على استكشاف قاعدة الكود نيابة عنه. يساهم غير المهندسين بفعالية لا تقل عن فعالية المهندسين. ما كان يعيق هاتين الفئتين لم يكن أبدا نقصا في الأتمتة، بل كان المعرفة التخصصية الموجودة فقط في رؤوس الأشخاص، تلك المعرفة الضمنية التي كان يجب تعلمها أثناء التأهيل.

## ماذا يعني ترميز المعرفة التخصصية كبنية تحتية

هذا هو جوهر التحول الذي أحدثه الوكلاء. المعرفة التخصصية التي يمكن ترميزها في البنية التحتية لم تعد مقتصرة على ما يمكن التعبير عنه بقواعد lint والأنواع types والاختبارات.

في الماضي، لم يكن بالإمكان تثبيت سوى قواعد مثل هذه الدالة يجب ألا تعيد قيمة nil في الكود. أما معرفة من نوع فريقنا يتحقق دائما من هذا الإذن قبل استدعاء هذا الواجهة البرمجية، أو هذا الترحيل آمن فقط داخل نافذة النشر، أو هذه الشاشة يجب أن تتبع نمط هذه البنية المعمارية، فكانت موجودة في مستند ما، أو فقط في رأس أحد المهندسين الأقدم.

أما الآن فيمكن التقاط تقريبا كل تلك المعرفة في تعليقات الكود والمهارات وقواعد CLAUDE.md والذاكرة. إذا فتحت طلب دمج PR في قاعدة كود iOS لا أعرفها ورفضه المراجع لاستخدامه إطارا خاطئا، أو رُفضت ميزة صممها مصمم لأنها لا تتبع نمط البنية المعمارية، فهذه ليست أخطاء بشرية، بل هي فشل في الأتمتة. لو كانت تلك المعرفة مثبتة في البنية التحتية، لما أخطأ الوكيل من الأساس.

من هنا يبرز معيار للحكم. كل قاعدة، وكل جملة في مهارة، يجب أن تجتاز الاختبار التالي: هل سيخطئ الوكيل من دون هذه الجملة. الجملة التي لا تجتاز هذا الاختبار هي خسارة صافية تدفع تكلفتها في كل جلسة على شكل استهلاك للسياق. المهارة ليست مجانية، بل هي ضريبة.

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
<div class="d3-arch" data-arch-root id="nowledgeasinfrastructure-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 555, "height": 754, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 150, "y": 24, "w": 191, "h": 78, "title": ["المعرفة في رؤوس الأشخاص", "معرفة ضمنية", "(تنتقل فقط عبر التأهيل)"]}, {"id": "B", "x": 285, "y": 194, "w": 142, "h": 78, "title": ["البنية التحتية", "lint · الأنواع ·", "الاختبارات"]}, {"id": "C", "x": 156, "y": 644, "w": 198, "h": 78, "title": ["البنية التحتية 2.0", "CLAUDE.md · المهارات", "قواعد المراجعة · الذاكرة"]}, {"id": "D", "x": 282, "y": 350, "w": 149, "h": 62, "title": ["الوكلاء لا يخطئون", "من الأساس"]}, {"id": "E", "x": 325, "y": 490, "w": 198, "h": 62, "title": ["المهندسون وغير المهندسين", "يساهمون منذ اليوم الأول"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "ترميز", "curve": [[296, 102], [356, 148], [356, 148], [356, 194]], "off": "50%"}, {"src": "A", "dst": "C", "kind": "data", "label": "مسار جديد أصبح ممكنا<br/>في عصر الوكلاء", "curve": [[194, 102], [134, 311], [134, 521], [199, 644]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "line": [356, 272, 356, 350]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[255, 644], [255, 598], [255, 451], [311, 412]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[386, 412], [424, 451], [424, 451], [424, 490]]}, {"src": "E", "dst": "C", "kind": "data", "label": "استخلاص الدروس من الأخطاء", "curve": [[424, 552], [424, 598], [424, 598], [333, 644]], "off": "50%"}]});
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
      const container = document.getElementById('nowledgeasinfrastructure-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nowledgeasinfrastructure-1';
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

السهم الأخير في هذا المخطط هو الأهم. حين يخطئ الوكيل في شيء ما، الهدف ليس إصلاحه مرة واحدة والمضي قدما، بل إعادة ترميز سبب الخطأ كقاعدة أو مهارة. عندها تختفي تلك الفئة من الأخطاء إلى الأبد. من دون حلقة التغذية الراجعة هذه، لن يستطيع النظام التحسن من تلقاء نفسه مع الوقت.

## كيف تطبق ThakiCloud هذا المبدأ فعليا

هذا هو حجم الادعاء. الآن نوجه السؤال نفسه إلى أنفسنا. هل تحمل بنية الوكلاء لدى ThakiCloud المعرفة التخصصية فعلا، أم أنها تبدو كذلك فقط. قمنا بقياس المستودع مباشرة.

يحمل مستودعنا الخلفي الموحد 52 قاعدة دائمة التحميل (`.claude/rules/`)، بإجمالي 3,536 سطرا. هذه القواعد ليست نصائح عامة عن أسلوب الكود، بل معظمها دروس مستخلصة من حوادث فعلية محددة. على سبيل المثال، نشأت قاعدة مصدر البيانات الكلية macro data source من حادثة فعلية استخدمت فيها مكتبة معينة سعر صرف أعلى بمقدار 25 وون وبإغلاق اليوم السابق، مما تسبب في تقرير خاطئ في الإحاطة الصباحية. منذ ذلك الحين، يفرض الكود استخدام مصدر موثوق ومحدد لأسعار الصرف فقط. يبدأ عدد كبير من قواعدنا الـ 52 بعنوان من نوع حادثة بتاريخ كذا، وتضم 18 قاعدة منها قسما مخصصا للأخطاء الشائعة gotchas. هذا دليل على أن حلقة تحول الفشل إلى توثيق ثم إلى قاعدة ملزمة تعمل فعلا، وليست مجرد وصف نظري.

يتجاوز عدد المهارات التي تُحمل عند الطلب، بما فيها الإضافات الخارجية، 1,800 مهارة. تحزم هذه المهارات سير عمل متكررا مثل إنشاء التقارير ومراجعة الكود وكتابة الأبحاث وخطوط أنابيب النشر بصيغة قابلة لإعادة الاستخدام. المهارة ليست مجرد موجه prompt بسيط، فهي خاضعة لإدارة الإصدارات، وتجمع في حزمة واحدة السكربتات والقوالب وحالات الفشل المعروفة، ويعاد استخدامها كسير عمل متكامل من المدخلات وحتى استعادة الأخطاء. المبدأ هو بناء القدرة في مهارات ثقيلة بدلا من غلاف رفيع.

لدينا 63 وكيلا فرعيا متخصصا حسب الدور، و13 خطافا hook يُشغَّل تلقائيا، و41 أتمتة تعمل بلا إشراف بشري (launchd) في أوقات محددة. تندرج تحت هذه الفئة الإحاطات الصباحية وملخصات الأخبار وتطور المدونة والتحسين الذاتي للمهارات. سير العمل الذي أنتج هذا المقال نفسه هو أحد هذه الأتمتة. خط الأنابيب الذي كتب الجملة التي تقرأها الآن يفرض في الكود عملية صياغة المسودة وإزالة آثار الذكاء الاصطناعي وتوحيد اللهجة والترجمة إلى ثلاث لغات قبل النشر. الصيغة النهائية ليست ارتجالا من النموذج، بل يملكها كود حتمي deterministic.

لا يقتصر وجود CLAUDE.md على مستودع واحد أعلى المستوى، بل يوجد في أكثر من 20 موقعا إذا أحصينا الوحدات الفرعية submodules والحزم الفرعية. المستودع الأمامي الموحد، وشبكة الوسيط multi cluster mesh، ومنتج مساعد الذكاء الاصطناعي، كل منها يعلن قواعده الخاصة عبر ملف CLAUDE.md خاص به. الوكيل الذي يعمل على الواجهة الخلفية backend يقرأ ملف CLAUDE.md الخاص بالواجهة الخلفية عند الحاجة، والوكيل الذي يعمل على الواجهة الأمامية frontend يقرأ ملف الواجهة الأمامية. المعرفة لا تتكدس في مكان واحد، بل توضع حيث تُحتاج، وفق بنية إفصاح تدريجي progressive disclosure.

إجمالا، القنوات الأربع للترميز التي ذكرها Boris Cherny، تعليقات الكود، المهارات، قواعد CLAUDE.md، الذاكرة، حية بالكامل في نظامنا. والدليل الأقوى على أننا نمارس هذا المبدأ فعلا وليس مجرد تقليده هو أن حلقة إعادة تغذية الفشل إلى قواعد ليست زخرفا شكليا، بل تعمل فعلا بمواد من حوادث حقيقية.

## ما ينقص بعد، والرأي المضاد

من باب الإنصاف، ننظر إلى الجانب الآخر أيضا. هذا النهج ليس خيرا مطلقا بلا شوائب.

أولا، البنية التحتية نفسها تكلفة. 3,500 سطر من القواعد دائمة التحميل تستهلك توكنات في كل جلسة. كلما ازدادت القواعد، تضخم السياق وتراجع مكان الكود المهم فعليا. لهذا نحذف أي قاعدة لا تجتاز اختبار هل سيخطئ الوكيل من دونها، ونخفض المعرفة غير الضرورية دائما من قاعدة إلى مهارة تُحمل عند الطلب. الترميز ليس شيئا يُزاد بلا حدود، بل موضوع يحتاج حمية مستمرة.

ثانيا، المعرفة المرمزة تشيخ مع الوقت. القاعدة التي نشأت من حادثة قبل ستة أشهر قد تستند إلى فرضية لم تعد صحيحة اليوم. فعليا، كانت إحدى قواعدنا منعا مطلقا لما يسمى averaging down، مستندة إلى قصة قديمة عن تداول سهم مضاربي صغير، ولم تعد متوافقة مع سياق محفظتنا الحالية، فحُذفت واستُبدلت بمبدأ آخر. تحتاج البنية التحتية إلى التقليم بقدر ما تحتاج إلى الزرع.

ثالثا، تشكل 1,800 مهارة ضجيجا في حد ذاتها. كلما زاد عدد المرشحين، ازداد خطر اختيار المهارة الخاطئة. تحميل مهارة لمجرد تطابق جزئي في الاسم يخفض الدقة. لهذا نضيق دائرة المرشحين عبر التوجيه القائم على البحث retrieval based routing وقاعدة صريحة تمنع التطابق القسري. حجم الترميز ليس مرادفا للجودة، وهذا شيء يجب مراقبته باستمرار.

هذه الحدود لا تنفي المبدأ نفسه، بل تظهر أن ممارسته بشكل صحيح تتطلب التعامل مع الترميز والتنظيف بالوزن نفسه من الأهمية.

## خاتمة

خلاصة Boris Cherny متواضعة. يجب على كل فريق كتابة ملفات CLAUDE.md وقواعد المراجعة والمهارات والتوثيق التي تتيح للوكيل العمل بإنتاجية داخل قاعدة الكود من دون أي سياق إضافي. قد يبدو ذلك مطلبا غريبا، لكنه في الوقت نفسه امتداد طبيعي لما اعتاد المهندسون فعله دائما: الأتمتة، وترميز المعرفة التخصصية كبنية تحتية.

كلما ازدادت ذكاء النماذج ونضج الأغلفة harness، يصبح هذا العمل أسهل. وفي الوقت نفسه، المهمة الواضحة أمام كل فريق هي نقل المعرفة التخصصية المبعثرة في الرؤوس والمستندات إلى بنية تحتية يستطيع الوكيل قراءتها واتباعها. حين يتحقق ذلك، يكتب Claude كودا أفضل، وتلتقط مراجعة الكود المشكلات تلقائيا، ويستطيع الشخص التالي الذي يعمل على قاعدة الكود هذه المساهمة بسهولة أكبر. تبني ThakiCloud منصتها، وأتمتة تشغيلها، على هذا المبدأ.

## المصدر

- Boris Cherny، "الأتمتة وبنية المعرفة التخصصية التحتية"، X (تويتر سابقا)، [الرابط الأصلي](https://x.com/bcherny/status/2077460395279692197)
