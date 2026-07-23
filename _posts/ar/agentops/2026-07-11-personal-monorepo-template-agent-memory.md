---
title: "عامل برمجي يتذكّر عبر المجلدات بلا قاعدة بيانات متجهية: تحليل personal-monorepo-template"
seo_title: "منح العامل البرمجي ذاكرة دائمة - personal-monorepo-template - Thaki Cloud"
seo_description: "يمنح personal-monorepo-template الذي كشف عنه jxnl مؤسس Instructor عامل البرمجة ذاكرة دائمة باستخدام مجلدات عادية وملف AGENTS.md فقط، دون الحاجة إلى قاعدة بيانات متجهية. نفكك البنية ونتحقق منها من منظور حاضنة مهارات Paxis في ThakiCloud."
excerpt: "يمنح personal-monorepo-template الذي كشف عنه مهندس فريق OpenAI Codex، jxnl، العامل البرمجي ذاكرة دائمة عبر بنية مجلدات وملف AGENTS.md فقط، دون قاعدة بيانات متجهية. نفكك هذا التصميم ونتحقق منه من منظور ThakiCloud الذي يتعامل مع المهارات كموارد من الدرجة الأولى."
date: 2026-07-11
tags:
  - agent-memory
  - coding-agent
  - agents-md
  - codex
  - agentops
  - paxis
categories:
  - agentops
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/personal-monorepo-template-agent-memory/"
---

عند استخدام عامل البرمجة يوميًا، يصطدم المرء مرارًا بحائط واحد. القرارات التي اتُّخذت أمس، الأعراف التي حُدّدت الأسبوع الماضي، أسلوب عمل زميل معيّن، كل هذا يعيد العامل سؤاله عنه في كل جلسة وكأنه يسمعه للمرة الأولى. ظهر مؤخرًا مستودع يحل هذه المشكلة دون قاعدة بيانات متجهية باهظة أو بنية تحتية منفصلة للذاكرة، بل عبر **بنية مجلدات عادية وملف ماركداون واحد فقط**، وأثار ضجة بين المطورين. إنه `personal-monorepo-template` الذي كشف عنه jxnl (جيسون ليو)، صانع مكتبة `Instructor`. يفكك هذا المقال تلك البنية، ويتحقق من دلالات هذا التصميم من منظور تشغيل ThakiCloud الذي يتعامل مع المهارات والمعرفة كموارد من الدرجة الأولى.

## نظرة عامة

النهج الشائع لمعالجة مشكلة ذاكرة العامل هو قاعدة البيانات المتجهية. تُحوَّل المحادثات والمستندات إلى متجهات تضمين (embeddings) وتُخزَّن، ثم تُستدعى عند الحاجة عبر بحث دلالي. هذا النهج قوي لكن عبء تشغيله كبير. يجب إدارة خط أنابيب التضمين، والفهرس المتجهي، وجدولة إعادة الفهرسة، وهي بنية تحتية مفرطة بالنسبة لفرد يريد إضافتها إلى سير عمله الخاص.

يسلك `personal-monorepo-template` اتجاهًا معاكسًا تمامًا. يعيد تعريف الذاكرة لا كمشكلة بحث، بل **كمشكلة بنية ملفات**. يوضع الأشخاص في مجلد `people/`، والمشاريع كحزم مشاريع، وأنماط العمل المتكررة كمهارات داخل المستودع نفسه. ويحمّل العامل هذه البنية باستمرار عبر `AGENTS.md` في بداية كل جلسة. فبدلًا من التطابق التقريبي للبحث المتجهي، يصل العامل إلى الذاكرة عبر عنوان دقيق هو مسار المجلد.

خلفية صاحب المشروع تضفي ثقلًا على هذا التصميم. jxnl هو صانع مكتبة الإخراج المهيكل (structured output) المسماة `Instructor`، والتي تُحمَّل ملايين المرات شهريًا، ويُقال إن OpenAI استشهدت بها كمصدر إلهام لميزة الإخراج المهيكل الخاصة بها. وهو حاليًا مهندس تجربة المطوّرين (Developer Experience) في فريق OpenAI Codex، ما يجعل قيمة هذا المرجع كبيرة كونه أداة صنعها شخص يشغّل عوامل البرمجة يوميًا في الميدان لحل مشكلته الخاصة.

## ما هذه التقنية

الفكرة الجوهرية واحدة. **تمثيل ذاكرة العامل عبر مجلدات وماركداون عادية داخل مستودع أحادي (monorepo)، وتحميلها تلقائيًا في كل جلسة.** يمكن تقسيمها إلى ثلاثة محاور.

المحور الأول هو **سجلات الأشخاص والمشاريع**. يفحص المستودع سلاك والبريد الإلكتروني والتقويم وGitHub لإنشاء ملفات `people` وحزم المشاريع، ويقترح تحديثات على `AGENTS.md` المحمَّل باستمرار. عند ذكر اسم زميل معيّن، يقرأ العامل ملف ذلك الشخص لاستعادة السياق فورًا. دون قاعدة بيانات متجهية، يجد العامل "من هو هذا الشخص" عبر مسار مجلد دقيق.

المحور الثاني هو **المهارات المحلية داخل المستودع**. حين توضع أنماط العمل المتكررة كمهارات داخل المستودع، تُحمَّل تلقائيًا في كل جلسة ويتبعها العامل. من أبرز الأمثلة مهارة write-like-me المدمجة، التي تتعلم من رسائل البريد الإلكتروني ورسائل سلاك المُرسَلة سابقًا لتكتب بأسلوب المستخدم نفسه. بنية يصبح فيها الإنتاج السابق للمستخدم بيانات تدريب للمهارة نفسها.

المحور الثالث هو **التسجيل التلقائي (check-in)**. صُمم المستودع لتشغيل تسجيل تلقائي في التاسعة صباحًا والرابعة مساءً يوميًا، حيث يلخّص حالة المشاريع والسياق المتعلق بالأشخاص لذلك اليوم ويقترح التحديثات. هذه حلقة يحدّث فيها العامل ذاكرته من تلقاء نفسه في أوقات محددة، بدلًا من انتظار استدعاء يدوي.

يوضّح المخطط التالي التدفق الكامل.

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
<div class="d3-arch" data-arch-root id="orepotemplateagentmemory-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 915, "height": 534, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "SRC", "x": 356, "y": 24, "w": 212, "h": 62, "title": ["سلاك · البريد الإلكتروني ·", "التقويم · GitHub"]}, {"id": "SCAN", "x": 235, "y": 178, "w": 205, "h": 46, "title": "نص برمجي للتسجيل التلقائي"}, {"id": "PEOPLE", "x": 467, "y": 310, "w": 149, "h": 46, "title": "اقتراح ملف people"}, {"id": "PKT", "x": 263, "y": 310, "w": 149, "h": 46, "title": "اقتراح حزمة مشروع"}, {"id": "AGD", "x": 24, "y": 310, "w": 184, "h": 46, "title": "اقتراح تحديث AGENTS.md"}, {"id": "AGENT", "x": 478, "y": 456, "w": 128, "h": 46, "title": "العامل البرمجي"}, {"id": "SKILL", "x": 671, "y": 302, "w": 212, "h": 62, "title": ["مهارات محلية داخل المستودع", "بما فيها write-like-me"]}, {"id": "CRON", "x": 89, "y": 24, "w": 212, "h": 62, "title": ["تسجيل تلقائي يوميًا الساعة", "09:00 و16:00"]}], "edges": [{"src": "SRC", "dst": "SCAN", "kind": "data", "label": "فحص", "curve": [[462, 86], [462, 132], [462, 132], [379, 178]], "off": "50%"}, {"src": "SCAN", "dst": "PEOPLE", "kind": "data", "curve": [[413, 224], [542, 263], [542, 263], [542, 310]]}, {"src": "SCAN", "dst": "PKT", "kind": "data", "line": [338, 224, 338, 310]}, {"src": "SCAN", "dst": "AGD", "kind": "data", "curve": [[255, 224], [116, 263], [116, 263], [116, 310]]}, {"src": "AGD", "dst": "AGENT", "kind": "event", "label": "تحميل مستمر عند بدء الجلسة", "curve": [[116, 356], [116, 410], [116, 410], [478, 469]], "off": "50%"}, {"src": "PEOPLE", "dst": "AGENT", "kind": "event", "label": "استعلام عبر مسار المجلد", "line": [542, 356, 542, 456], "lx": 542, "ly": 406}, {"src": "SKILL", "dst": "AGENT", "kind": "event", "label": "تحميل تلقائي", "curve": [[777, 364], [777, 410], [777, 410], [606, 460]], "off": "50%"}, {"src": "CRON", "dst": "SCAN", "kind": "data", "curve": [[195, 86], [195, 132], [195, 132], [290, 178]]}]});
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
      const container = document.getElementById('orepotemplateagentmemory-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'orepotemplateagentmemory-1';
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

سبب أهمية هذا التصميم أنه يتقاطع تمامًا مع فلسفة "Codex-maxxing" التي شرحها صاحب المستودع نفسه في مقال منفصل. الاتجاه هنا ليس إلحاق نموذج أفضل بالعامل، بل **بناء بنية محيطة سميكة** حتى لا يبدأ العامل من صفحة بيضاء في كل مرة.

## التثبيت والتكامل

هذا المستودع قالب (template) كما يوحي اسمه. يُدمج بنسخه إلى حساب GitHub الخاص بالمستخدم، ثم بضبط عامل البرمجة (Codex أو واجهة سطر أوامر مشابهة) ليتخذ جذر المستودع دليل عمل له. نقطة الدخول الأساسية هي ملف `AGENTS.md` في جذر المستودع، حيث يقرأه العامل عند بدء الجلسة ليتعرف على بنية المجلدات، وسياق الأشخاص والمشاريع، وقائمة المهارات الواجب تحميلها.

نقطة التكامل المهمة هنا أن `AGENTS.md` ليس **مجرد مستند، بل عقد يُحمَّل باستمرار**. بما أن هذا الملف يوضع في مقدمة السياق في كل جلسة، فإن ما يُكتب فيه يحدد مباشرة السلوك الافتراضي للعامل. ولأن بنية المجلدات ثابتة، يصل العامل إلى الذاكرة بطريقة حتمية على شاكلة "إذا احتجت سياق الزميل A، فاقرأ `people/A.md`". وبخلاف التقريب الاحتمالي للبحث المتجهي، يشير مسار الملف دائمًا إلى المكان نفسه.

يُدمج التسجيل التلقائي عبر ربط نص برمجي للتسجيل بجدولة (من نوع cron) ليعمل في وقت محدد يوميًا. هذا الجزء آلية تُبقي الذاكرة محدَّثة دون حاجة إلى استدعاء بشري في كل مرة، وهو أيضًا قرار تصميمي مهم من زاوية التكلفة. فبدلًا من الاستطلاع المستمر، هناك تنفيذان محدودان يوميًا فقط، فلا يُستهلك عدد رموز (tokens) هائل في حلقة لا نهائية.

## كيف يعمل هذا التصميم فعليًا

هذا المستودع ليس أداة تعرض أرقام قياس أداء، بل **نمط سير عمل**، لذا نتناول هنا الأثر الفعلي للتصميم من الناحية البنيوية. لا يقدّم المستودع أرقام أداء قابلة لإعادة الإنتاج، وحتى صاحب المشروع نفسه يستند إلى تحسّن سير العمل اليومي لا إلى مؤشرات كمية. لذلك لن نختلق أرقامًا في هذا المقال، بل نتناول المزايا البنيوية فقط.

الأثر الأكبر هو **إزالة تكلفة استعادة السياق**. يمر الوصول عبر قاعدة بيانات متجهية بحساب تضمين وبحث تشابه في كل استعلام، بينما يقتصر الوصول عبر مسار المجلد على قراءة ملف واحد. حين يقول المستخدم "ذلك المشروع من المرة السابقة"، يقرأ العامل حزمة ذلك المشروع مباشرة، ويستعيد السياق الدقيق دون أخطاء إيجابية كاذبة يسببها البحث التقريبي. تصبح دقة الذاكرة رهينة جودة تصميم المجلدات لا جودة البحث.

الأثر الثاني هو **إمكانية التدقيق**. بما أن كل الذاكرة مخزَّنة كماركداون قابل للقراءة البشرية، يمكن للمطور فتحها والتحقق منها وتعديلها مباشرة ليعرف ما يعرفه العامل. من الصعب على الإنسان التحقق بصريًا من متجهات التضمين، لكن `people/A.md` مجرد ملف نصي. القدرة على تصحيح ذاكرة العامل فورًا حين تكون خاطئة تُحدث فرقًا كبيرًا في الممارسة العملية.

الأثر الثالث هو **قابلية النقل**. بما أن التصميم لا يرتبط بمزوّد قاعدة بيانات متجهية أو نموذج تضمين معيّن، فإن المستودع نفسه هو الذاكرة الكاملة. عند النقل إلى جهاز آخر أو عامل آخر، تعمل المجلدات والماركداون كما هي. هذا الاستقلال عن البنية التحتية يرتبط مباشرة بمنظور السيادة والحوسبة الداخلية (on-premise) الذي نتناوله لاحقًا.

## دلالات التطبيق على منتجات ThakiCloud

يتقاطع هذا التصميم مع محورَي تشغيل العوامل في ThakiCloud كليهما.

من **منظور Paxis** يبدو التقاطع الأكثر مباشرة. Paxis هو مستوى تحكم السحابة الأصلية للعوامل (Agent-Native Cloud) في ThakiCloud، ويتعامل مع المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. النمط الذي يعرضه `personal-monorepo-template`، أي "مهارات محلية داخل المستودع + عقد محمَّل باستمرار (AGENTS.md)"، يتطابق تمامًا مع اتجاه تصميم حاضنة المهارات في Paxis. يختار Paxis بالفعل عددًا من المهارات عبر BM25 وينفّذها في بيئة معزولة (sandbox)، ونهج هذا المستودع يجيب بوضوح، عبر بنية المجلدات، على سؤال أسبق وهو "أي معرفة توضع باستمرار في سياق الجلسة". وبشكل خاص، إبقاء الذاكرة كملفات قابلة للقراءة البشرية وجعل كل تحديث قابلًا للتدقيق ينسجم مع نفس فلسفة Paxis التي تُمرّر كل سلوك للعامل عبر بوابات السياسات وسجلات التدقيق. فكرة استخلاص قدرة العامل من البنية المحيطة لا من درجة النموذج نفسها تتطابق شكليًا مع تصميمنا الذي يتعامل مع المهارات كموارد من الدرجة الأولى.

من **منظور ai-platform**، تبرز زاوية عبء البنية التحتية بشكل لافت. منصة ai-platform في ThakiCloud بنية تحتية للذكاء الاصطناعي وتعلّم الآلة قائمة على K8s، وتخدم أحمال عمل عملاء الذكاء الاصطناعي السيادي والداخلي (on-premise). بالنسبة لهؤلاء العملاء، فإن بنية ذاكرة تتطلب تشغيل قاعدة بيانات متجهية باستمرار تعني سطحًا إضافيًا للبنية التحتية وتكلفة إدارة إضافية. في المقابل، الذاكرة المُمثَّلة بمجلدات وماركداون تعمل بنظام الملفات وحده دون مخزن حالة منفصل، ما يقلل عبء التشغيل كثيرًا في البيئات الخاضعة للتنظيم أو الشبكات المغلقة. زاوية "منح العامل استمرارية مع تقليل بنية الذاكرة التحتية إلى أدنى حد" يمكن أن تكون نقطة بيع فعلية للعملاء الذين يتطلبون ذكاءً اصطناعيًا سياديًا.

## القيود والحجج المضادة

هذا التصميم ليس حلًا شاملًا. القيد الأوضح هو **الحجم**. الوصول عبر مسار المجلد قوي حين يعرف الإنسان أو العامل عنوان الذاكرة مسبقًا. لكن في المواقف التي يجب فيها البحث عن معلومة "لا يُعرف مكانها" بين عشرات الآلاف من المستندات، يظل البحث المتجهي الدلالي متفوقًا. يفترض هذا المستودع فضاء ذاكرة صغيرًا نسبيًا وواضح البنية، وهو أشخاص المستخدم ومشاريعه وخبراته الشخصية. عند التوسع إلى قاعدة معرفة ضخمة لفريق كامل بأسره، تظهر حدود بنية المجلدات وحدها.

الحجة المضادة الثانية هي **خصوصية الفحص**. إن فحص سلاك والبريد الإلكتروني والتقويم لإنشاء ملفات الأشخاص يعني أيضًا أن محادثات حساسة تُخزَّن كنص عادي في ماركداون. هذا مريح للاستخدام الشخصي، لكن تبنّيه في منظمة يتطلب حتمًا ضوابط وصول وسياسات احتفاظ. بقدر ما تُعد إمكانية التدقيق ميزة، فإنها تتحول إلى مخاطرة إن لم يوجد ضبط لمن يصل إلى تلك الملفات.

الثالثة هي **موثوقية التحديث التلقائي**. إذا كتب التسجيل التلقائي، الذي يعمل مرتين يوميًا، ملخصًا خاطئًا في ملف شخص، يستمر هذا الخطأ في الحقن في الجلسات اللاحقة. هذا هو السبب في أن المستودع يجعل التحديثات "اقتراحات" تفترض مراجعة بشرية. فالدفع نحو الأتمتة الكاملة قد يلوّث الذاكرة بصمت، لذا فإن إبقاء بوابة مراجعة بشرية أكثر أمانًا.

وأخيرًا، يُقدَّم هذا النهج كـ"بديل مجاني مقابل راتب مساعد بشري"، لكن الحفاظ فعليًا على سير عمل بهذا المستوى يتطلب قدرة هندسية معتبرة على تصميم بنية المستودع وصقلها ذاتيًا. مجانية الأداة وتكلفة تشغيله بكفاءة أمران مختلفان تمامًا.

ومع ذلك، فإن الرسالة الجوهرية التي يطرحها هذا المستودع واضحة. ذاكرة العامل لا يجب أن تكون بالضرورة بنية تحتية ثقيلة، ويمكن تحقيق استمرارية معتبرة ببنية مجلدات جيدة وعقد يُحمَّل باستمرار فقط. وهذا يشير بالضبط إلى الاتجاه نفسه الذي تسلكه ThakiCloud في تعاملها مع المهارات والمعرفة كموارد من الدرجة الأولى.

## المصادر

- [jxnl/personal-monorepo-template (GitHub)](https://github.com/jxnl/personal-monorepo-template)
- [Codex-maxxing (jxnl.co)](https://jxnl.co/writing/2026/05/10/codex-maxxing/)
