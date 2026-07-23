---
title: "رسم مخططات المعمارية بالكلمات: شغّلنا Archify فعليًا ورسمنا به بنية ThakiCloud"
excerpt: "Archify مهارة وكيل تُنشئ مخططات معمارية بصيغة HTML ذاتية الاكتفاء من وصف بجملة عادية دون الحاجة لتعلّم صيغة Mermaid. حين ثبّتناها فعليًا ورسمنا بها بنية ai-platform من ThakiCloud، تبيّن أن جوهرها ليس الرسم نفسه بل مُصيّر يفرض التحقق من التخطيط. نوضّح في هذا المقال لماذا يتقاطع هذا التصميم مع فلسفة إطار المهارات في Paxis من ThakiCloud."
date: 2026-07-22
tags:
  - Archify
  - 아키텍처다이어그램
  - ClaudeCode
  - AI에이전트
  - 개발도구
  - 시각화
  - JSON-IR
  - Paxis
author_profile: true
toc: true
toc_label: Archify في الممارسة
published: true
categories:
  - dev
  - agentops
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/archify-agent-architecture-diagrams/"
---

![صورة تجريدية تصوّر صناديق وخطوط ربط عديدة تتقارب في بنية شبكية واحدة مرتّبة]({{ '/assets/images/archify-agent-architecture-diagrams-hero.png' | relative_url }})

## لماذا تقرأ هذا

هذا المقال موجّه لـ**المطورين ومهندسي المنصات الذين يرسمون مخططات معمارية باستمرار لكنهم يفقدون وقتهم في صيغة Mermaid أو أدوات الرسم بالسحب والإفلات**. إنه مفيد لمن يحتاج أساسًا ملموسًا لاختيار أداة.

لنبدأ بالخلاصة. القيمة الحقيقية لـ Archify ليست في راحة "ارسم لي الصورة بالكلام"، بل في أن **المُصيّر يفرض التحقق من التخطيط الذي ينتجه الوكيل، بحيث يستحيل إنتاج رسم خاطئ من الأساس**. حين شغّلناها فعليًا، رُفضت محاولتنا الأولى للرسم، وكان ذلك الرفض هو ما يجعل هذه الأداة تستحق الاستخدام.

## نظرة عامة

مخططات المعمارية من أكثر المخرجات التي يرسمها المطورون تكرارًا وأكثرها إزعاجًا لهم. Mermaid يتطلب حفظ صيغته، وأدوات الرسم تتطلب سحب الصناديق والخطوط يدويًا لضبطها. وحتى بعد الانتهاء من الرسم، قد لا يتطابق الوضع الداكن، أو يجب إعادة التصدير لإدراجه في عرض تقديمي.

**Archify**، الذي حظي مؤخرًا باهتمام واسع في مجتمع المطورين الصيني، يستهدف هذه النقطة تحديدًا. أعطِ Claude Code أو Codex جملة عادية مثل "اقرأ هذه المستودعات وارسم لي مخططًا مقارنًا لبنياتها"، فتحصل على مخطط HTML ذاتي الاكتفاء يُفتح مباشرة في المتصفح. يمكنك التبديل بين السمتين الداكنة والفاتحة، وتصديره إلى PNG أو SVG.

حتى هذه النقطة، يبدو الكلام كعبارات تسويقية معتادة. لذلك، بدل تصديق العبارات، ثبّتناها فعليًا وشغّلناها، ورسمنا بها بنية ai-platform الخاصة بـ ThakiCloud. كشفت هذه العملية لماذا تختلف هذه الأداة عن "مولّد رسوم بالذكاء الاصطناعي" بسيط. هذا المقال سجل لتلك التجربة، وفي الوقت نفسه محاولة لفهم كيف تتصل بفلسفة تصميم Paxis، منصة الوكلاء التي تبنيها ThakiCloud.

## ما هذه الأداة

Archify مهارة وكيل مفتوحة المصدر أصدرها `tt-a1i` برخصة MIT. عند وقت تجربتنا كان الإصدار 2.11.0، وهي نسخة أُعيدت كتابتها كفرع (fork) من architecture-diagram-generator v1.0 لشركة Cocoon AI، وتنسب لغتها البصرية الأصلية إلى Cocoon AI. تُثبَّت على عدة أوقات تشغيل للوكلاء منها Claude وCodex CLI وopencode.

فهم البنية الجوهرية يوضّح سبب تميّز هذه الأداة. لا يرسم Archify الصورة مباشرة. بدلًا من ذلك، يصف المخطط بصيغة **JSON-IR (تمثيل وسيط)**، ويحوّل مُصيّر مخصص لكل نوع ذلك JSON إلى HTML. هناك خمسة مُصيّرات: architecture وworkflow وsequence وdataflow وlifecycle. بعبارة أخرى، "ماذا نرسم" يعيش في JSON مُهيكَل، و"كيف نرسمه" تملكه شيفرة مُتحقَّق منها.

تتولى المُصيّرات الخمسة كل نوع مختلف من الرسوم. architecture يغطي مكونات النظام وحدوده، وworkflow يغطي إجراءات مثل سلاسل الموافقة أو CI/CD، وsequence يغطي دورة حياة الطلب أو ترتيب استدعاءات API، وdataflow يغطي حركة البيانات مثل خطوط ETL وتدفقات الأحداث، وlifecycle يغطي انتقالات الحالة مثل عمليات النشر أو تنفيذ الوكيل. بمجرد تحديد ما تريد رسمه، يُفعَّل المُصيّر والمخطط (schema) المناظران، وذلك المخطط يفرض شكل JSON المُدخَل.

يخلق هذا التقسيم للعمل الفارق الحاسم مقارنة بـ Mermaid. يحلّل Mermaid الصيغة ويرتّب العناصر تلقائيًا (عبر dagre)، لكنه يرسم بلا مانع حتى لو قطع خط صندوقًا أو تداخلت التسميات. يفعل Archify العكس: يجعلك تحدد إحداثيات التخطيط صراحة، وقبيل الرسم مباشرة **يفحص قواعد التخطيط فرضًا**. إن خُرقت قاعدة، يرفض إنتاج الرسم ويصدر خطأ بدلًا منه.

التدفّق العام كالتالي.

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
<div class="d3-arch" data-arch-root id="gentarchitecturediagrams-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 459, "height": 934, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 115, "y": 24, "w": 198, "h": 78, "title": ["طلب بلغة طبيعية", "(اقرأ هذا المستودع وارسم", "البنية)"]}, {"id": "B", "x": 133, "y": 180, "w": 163, "h": 62, "title": ["وكيل", "Claude Code / Codex"]}, {"id": "C", "x": 108, "y": 320, "w": 212, "h": 78, "title": ["كتابة JSON-IR", "components · connections ·", "boundaries"]}, {"id": "D", "x": 222, "y": 476, "w": 205, "h": 94, "title": ["مُصيّر حسب النوع", "architecture / workflow /", "sequence / dataflow /", "lifecycle"]}, {"id": "E", "x": 117, "y": 648, "w": 195, "h": 84, "title": ["التحقق من التخطيط", "تقاطع خط-عقدة · تداخل", "التسميات"]}, {"id": "F", "x": 119, "y": 824, "w": 191, "h": 78, "title": ["HTML ذاتي الاكتفاء", "سمة داكنة/فاتحة · تصدير", "PNG/SVG"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [214, 102, 214, 180]}, {"src": "B", "dst": "C", "kind": "data", "line": [214, 242, 214, 320]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[269, 398], [324, 437], [324, 437], [324, 476]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[324, 570], [324, 609], [324, 609], [271, 648]]}, {"src": "E", "dst": "C", "kind": "event", "label": "فشل التحقق + اقتراح إصلاح", "curve": [[157, 648], [104, 609], [104, 437], [159, 398]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "نجاح", "line": [214, 732, 214, 824], "lx": 214, "ly": 774}]});
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
      const container = document.getElementById('gentarchitecturediagrams-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'gentarchitecturediagrams-1';
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

## التثبيت والتكامل

التثبيت أمر npx واحد. التثبيت الشامل (العالمي) كالتالي.

```bash
# تثبيت شامل ثم اختيار وكيل
npx skills add tt-a1i/archify -g

# تجربة لمرة واحدة دون تثبيت دائم
npx skills use tt-a1i/archify@archify --agent codex
```

يمكنك أيضًا استنساخ المستودع مباشرة والتحقق منه عبر CLI لاستخراج الأمثلة. هذه هي الأوامر الفعلية التي شغّلناها ومخرجاتها. كانت بيئة تجربتنا Node.js v24.1.0، ويتطلب Archify Node 18 فأعلى، ولا توجد له فعليًا تبعيات تشغيل (تبعية تطوير واحدة فقط هي ajv، تُستخدم للتحقق من المخطط).

```bash
git clone --depth 1 https://github.com/tt-a1i/archify.git
cd archify/archify

# فحص حالة التثبيت
node bin/archify.mjs doctor
```

هذا هو المخرج الفعلي لأمر `doctor`. تأكّدت جميع المُصيّرات الخمسة والمدقّقات (schema validators) على أنها سليمة.

```text
Archify doctor

[ok] Node.js v24.1.0 (requires >=18)
[ok] Core template
[ok] Standalone schema validators
[ok] architecture renderer, schema, and example
[ok] workflow renderer, schema, and example
[ok] sequence renderer, schema, and example
[ok] dataflow renderer, schema, and example
[ok] lifecycle renderer, schema, and example

Archify is ready.
```

سحب أحد الأمثلة المدمجة ينتج ملف HTML ذاتي الاكتفاء واحدًا بحجم 508 كيلوبايت، يُفتح مباشرة في المتصفح دون أي خادم خارجي.

```bash
node bin/archify.mjs demo ./out
# Demo ready: ./out/archify-demo.html   (نحو 508 كيلوبايت، HTML واحد)
```

## ما وجدناه حين شغّلناها فعليًا

قراءة الوثائق وحدها تجعل الأمر يبدو أن هذا كل شيء. لذلك، بدل استخدام مثال شخص آخر، كتبنا **بنية ai-platform الفعلية لـ ThakiCloud** كـ JSON-IR بأيدينا ورسمناها. أدرجنا تسعة مكونات: جدولة GPU عبر Kueue، تقديم النماذج عبر vLLM، مصادقة متعددة المستأجرين عبر Keycloak، الحالة والأحداث عبر PostgreSQL وNATS، ونشر GitOps عبر ArgoCD.

لم يكن JSON-IR صعب القراءة أو الكتابة على إنسان. المكوّن كائن له نوع وتسمية وموضع وحجم، والاتصال يحمل مصدرًا ووجهة وتسمية. على سبيل المثال، وصفنا البوابة وجزء تقديم GPU كالتالي.

```json
{
  "components": [
    { "id": "gateway", "type": "backend", "label": "API Gateway",
      "sublabel": "Go Fiber :8080", "pos": [280, 300], "size": [140, 60] },
    { "id": "vllm", "type": "backend", "label": "vLLM Server",
      "sublabel": "OpenAI API", "pos": [540, 300], "size": [140, 60] }
  ],
  "connections": [
    { "id": "gw-to-vllm", "from": "gateway", "to": "vllm", "label": "route inference" },
    { "id": "vllm-gpu", "from": "vllm", "to": "gpupool", "label": "CUDA", "variant": "emphasis" }
  ]
}
```

فشلت محاولة الرسم الأولى. **وهذا الفشل هو أهم نقطة في هذا المقال.** بدل رسم أي شيء، أشار المُصيّر إلى ثلاث مشكلات ملموسة.

```text
Error: Architecture layout validation failed:
- [clean-flow/edge-through-node] connection "kueue-gpu" (kueue -> gpupool)
  crosses component "vllm" (unrelated to this relationship)
- [clean-flow/edge-through-node] connection "kueue-gpu" (kueue -> gpupool)
  crosses component "argocd" (unrelated to this relationship)
- Label "publish" overlaps component "gateway"
  Suggested fix: labelDy +24 (below); or labelAt [350, 374]
```

بعبارة أخرى، الاتصال من Kueue إلى مجمّع GPU قطع صندوقي vLLM وArgoCD غير المرتبطين، وتداخلت تسمية "publish" مع صندوق البوابة. اللافت أن المُصيّر لم يكتفِ بالإشارة إلى المشكلة، بل **اقترح أيضًا كيفية إصلاحها**، حتى الإحداثيات الدقيقة لمقدار تحريك التسمية.

اتّبعنا الاقتراح، وأضفنا نقطة توجيه (via) للاتصال وعدّلنا موضع التسمية، ثم أعدنا الرسم. نجح هذه المرة. هذه هي القياسات الفعلية.

| العنصر | القياس |
| --- | --- |
| زمن الرسم | نحو 0.073 ثانية |
| الملف الناتج | 519,709 بايت (نحو 508 كيلوبايت) HTML واحد |
| SVG مضمّن | 1 (الرسم بأكمله SVG واحد) |
| دعم السمات | `data-theme` في 27 موضعًا · `prefers-color-scheme` في 7 مواضع |
| المراجع الخارجية | 1 (خط JetBrains Mono، يتراجع إلى خط النظام) |

خلاصة القول، الرسم نفسه يستغرق 73 ميلي ثانية، أي فوري فعليًا. المخرج ملف HTML ذاتي الاكتفاء لا يعتمد على خادم صور أو CDN، ومرجعه الخارجي الوحيد خط ويب واحد للكود، لذا يُفتح دون كسر حتى دون اتصال، متراجعًا إلى خط النظام. السمتان الداكنة والفاتحة ليستا زخرفة، بل مُنفَّذتان فعليًا عبر متغيرات CSS حقيقية و`prefers-color-scheme`.

الدرس المستفاد هنا واضح. مدقّق Archify ليس أداة لإنتاج "رسم جميل"، بل **بوابة تمنع من الأساس نشر مخطط سيئ، خطوطه متشابكة أو تسمياته متداخلة**. عيب بصري كان سيتجاهله إنسان يرسم يدويًا، أمسكته الشيفرة في كل مرة وبالمعيار نفسه.

## دلالات على منتجات ThakiCloud

تصميم هذه الأداة يتقاطع بدقة مع مبدأ تلتزم به ThakiCloud عبر منتجين.

**عبر عدسة Paxis (الوكلاء والمهارات).** Paxis هي السحابة الأصلية للوكلاء من ThakiCloud، وتتعامل مع المهارات كموارد من الدرجة الأولى. تختار أكثر من 960 مهارة عبر BM25، وتشغّلها في صندوق رمل معزول، وتمرّر كل إجراء عبر بوابات السياسة وسجلات التدقيق. Archify هو تحديدًا شكل الأداة التي يُبنى إطار مهارات كهذا لاختيارها وتشغيلها. والأهم من ذلك هو تصميمها الداخلي. في Archify، **يُنتج النموذج المحتوى (JSON-IR)، بينما تملك الشيفرة الصيغة والتحقق**. هذا يطابق مبدأً تكرّره ThakiCloud في أعمال المخرجات الدفعية: افصل خطوة التوليد الحرة عن خطوة التحقق الحتمية. بدل أن تطلب من النموذج "ارسم شيئًا جميلًا"، تجعله ينتج تمثيلًا مُهيكَلًا، وتفرض الشيفرة ما إذا كان ذلك التمثيل يتبع القواعد. رفض محاولتنا الأولى للرسم كان تحديدًا هذا المبدأ وهو يعمل فعليًا.

**عبر عدسة ai-platform (البنية التحتية والتوثيق).** HTML ذاتي الاكتفاء مفيد بشكل خاص في البيئات المحلية (on-premise) والسيادية. لعميل لا يستطيع رفع بنيته الداخلية إلى SaaS خارجي للرسم، يصبح الرسم محليًا والحصول على ملف واحد قابل للنقل مخرجًا قابلًا للاستخدام مباشرة. وبما أن JSON-IR نص عادي، فهو خاضع لإدارة الإصدارات في Git وقابل للمقارنة (diff). تمامًا كما تدير ArgoCD ملفات manifest، يمكنك إدارة مخططات المعمارية كشيفرة أيضًا، وتتبّع كل تغيير ومراجعته. بدل إعادة رسم وثائق التأهيل أو مخططات النشر للعملاء يدويًا في كل مرة، يكفي تعديل JSON عند تغيّر البنية وإعادة الرسم.

تكمّل العدستان إحداهما الأخرى. مهارة مُتحقَّق منها (Paxis) تنتج مخرجًا قابلًا لإعادة الإنتاج (توثيق ai-platform)، وذلك المخرج بدوره يصبح أصلًا قابلًا للنقل إلى العملاء في البيئات المحلية.

## القيود والاعتراضات

بالطبع، Archify ليست أداة سحرية. لها بعض نقاط الضعف الواضحة.

أولًا، **يجب تحديد إحداثيات التخطيط صراحة.** بخلاف التخطيط التلقائي في Mermaid، يجب إعطاء موضع وحجم كل مكوّن كإحداثيات، ويجب أن يجتاز ذلك التخطيط التحقق. كما أظهرت محاولتنا الأولى الفاشلة، هذه الخطوة ليست مجانية تمامًا. لكن عمليًا، يملأ الوكيل هذه الإحداثيات نيابة عنك ويصلحها بنفسه عند تلقّي خطأ تحقق، فينخفض العبء على الإنسان.

ثانيًا، **المخرج ليس خفيفًا.** المخطط الواحد نحو 508 كيلوبايت من HTML، لأنه يحزم الخطوط والسكربتات في ملف ذاتي الاكتفاء. هذا أثقل من SVG بسيط أو كتلة Mermaid. إن كنت تضع عدة مخططات في صفحة مدونة واحدة، قد يصبح هذا الوزن عبئًا.

ثالثًا، **لم تُوزَّع كمكتبة.** يُعلَّم `package.json` بـ `private: true`، أي أنك تستهلكها كمهارة/CLI من المستودع لا كحزمة npm. ربطها في خط أنابيب كمكتبة يتطلب تفكيرًا إضافيًا.

رابعًا، **إنها لقطة ثابتة.** ليست لوحة تحكم حية تُحدَّث ببيانات لحظية، بل صورة لبنية في لحظة زمنية محددة. إن أردت رسم مسودة سريعة، قد تصبح صرامة قواعد التحقق احتكاكًا. مع ذلك، هذه الصرامة نفسها هي سبب وجود هذه الأداة أصلًا.

## الخلاصة

بعد تثبيت Archify فعليًا ورسم بنية ThakiCloud بها، خلاصتنا كالتالي. جوهر هذه الأداة ليس راحة "ارسم بالكلام"، بل انضباط **جعل المُصيّر يتحقق من كل تخطيط ينتجه الوكيل بالمعيار نفسه في كل مرة، بحيث لا يُنشر مخطط سيئ أبدًا**. كما قلنا في المقدمة، كان رفض محاولتنا الأولى للرسم هو اللحظة التي جعلتنا نثق بهذه الأداة.

لذا فالخطوة التالية واضحة. إن كنت ترسم مخططات معمارية باستمرار، وتريد أن تعيش تلك المخططات في وثائقك أو مستودعك كشيفرة، تستحق Archify تجربة واحدة على الأقل. وإن كنت بالمقابل تريد رسمًا سريعًا أو وضع عدة مخططات في صفحة واحدة، يبقى Mermaid الخيار الأخف. السؤال الفاصل هو: هل تريد إدارة هذا الرسم كأصل قابل لإعادة الإنتاج ومُتحقَّق منه؟ إن كانت الإجابة نعم، فـ Archify، وإطار مهارات Paxis الذي يحوّل المبدأ نفسه إلى منتج، هما الجواب.

> المصادر
> - مستودع Archify: [github.com/tt-a1i/archify](https://github.com/tt-a1i/archify) (MIT، الإصدار 2.11.0)
> - التغريدة الأصلية: [@alin_zone via @hjguyhan](https://x.com/hjguyhan/status/2079683904030777353)
> - سجل التجربة: الأوامر والمخرجات والقياسات في هذا المقال جُمعت من تشغيل محلي في 2026-07-22 (Node v24.1.0).
