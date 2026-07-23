---
title: "لا أكتب موجّهات، بل أكتب حلقات: هندسة الحلقات لوكلاء البرمجة"
excerpt: "قال أحد المطورين: “لم أعد أُدخل موجّهات (Prompts) في Claude Code. أُشغّل حلقة تُدخل الموجّهات في Fable، ومهمتي الوحيدة هي كتابة تلك الحلقة.” إذا نزعنا المبالغة عن هذه العبارة، فإنها تشير إلى تحوّل فعلي في وحدة العمل من الموجّه إلى الحلقة. نستعرض هندسة الحلقات التي تكرر الملاحظة والحكم والتنفيذ، وتجعل من المُجمّع والاختبارات إشارة مكافأة، من خلال حالتَي pge-loop وGoal Mode اللتين تُشغّلهما ThakiCloud فعلياً."
seo_title: "هندسة الحلقات: التعامل مع وكلاء البرمجة كحلقات لا كموجّهات - Thaki Cloud"
seo_description: "تحليل لنمط تشغيل وكلاء البرمجة أثناء الانتقال من الموجّه إلى الحلقة. بنية Act-Observe-Learn-Repeat، استخدام البوابات الحتمية كإشارة مكافأة، التطبيق الفعلي لـ pge-loop وGoal Mode في ThakiCloud، ومنظور التطبيق على Paxis Agent-Native Cloud."
date: 2026-07-04
last_modified_at: 2026-07-04
lang: ar
tags:
  - ai-coding
  - agentic
  - loop-engineering
  - claude-fable-5
  - agentops
  - verification
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/loop-engineering-coding-agents/"
categories:
  - agentops
published: false
---

## نظرة عامة

انتشرت مؤخراً بين المطورين عبارة أثارت نقاشاً واسعاً: "لم أعد أُدخل موجّهات (Prompts) في Claude Code. أُشغّل حلقة تُدخل الموجّهات في Fable، ومهمتي الوحيدة هي كتابة تلك الحلقة." العبارة استفزازية، لكن إذا نزعنا عنها المبالغة التسويقية، نجد فيها ملاحظة عملية ذات معنى حقيقي: وحدة العمل تنتقل من موجّه واحد إلى حلقة كاملة.

هذا التحول مختلف تماماً عن الحديث عن تحسّن النماذج. مهما كان النموذج قوياً، فإنه لا يستطيع إنجاز مهمة معقدة حتى النهاية من خلال طلب واحد ينتهي بموجّه واحد. لكن الأمر يتغير عندما يُبنى فوق بنية تكرارية يستدعي فيها النموذج أداة، ثم يستقبل نتيجتها كمُدخل جديد ليقرر الخطوة التالية. تُشغّل ThakiCloud مثل هذه الحلقات فعلياً في تطويرها الداخلي، إلى جانب تشغيل منصة AI/ML كخدمة (SaaS) قائمة على Kubernetes. لذلك فإن عبارة "كتابة حلقة" ليست بالنسبة لنا جملة رائجة، بل مهمة هندسية يومية. يستعرض هذا المقال ما تتكون منه هذه الحلقة فعلياً، وما الذي يجعلها موثوقة.

![صورة توضيحية لمفهوم هندسة الحلقات لدى وكلاء البرمجة]({{ '/assets/images/loop-engineering-coding-agents-hero.webp' | relative_url }})

## من الموجّه إلى الحلقة: ما الذي تغيّر

في عقلية كتابة الموجّهات، يحاول الإنسان انتزاع النتيجة المرجوة بأكبر قدر من الدقة من خلال تعليمة واحدة. الموجّه الجيد لا يزال مهماً، لكن حدود هذا الأسلوب واضحة: عندما تكون النتيجة خاطئة، يجب على الإنسان قراءتها بنفسه، وتحديد ما الذي انحرف، ثم إعادة صياغة الموجّه من جديد. إنها بنية يكون فيها الإنسان هو الحكم في كل تكرار، وهو من يعطي التعليمة التالية أيضاً.

أما عقلية كتابة الحلقات فتُسلّم مهمة التقييم وإعادة التوجيه إلى البنية نفسها. لا يُحدد الإنسان موجّهات فردية، بل يُعرّف "ما الهدف، وما الذي يجب مراقبته، ومتى يتوقف الأمر". يتصرف النموذج داخل هذا الإطار، وتحكم أداة خارجية على النتيجة، ويصبح هذا الحكم هو المُدخل التالي للنموذج. ينتقل دور الإنسان من مراقبة كل جولة إلى تصميم حدود الحلقة وشروط إنهائها.

قد يبدو هذا الفرق صغيراً، لكنه يُحدث فارقاً كبيراً في النتيجة. في أسلوب الموجّهات، يكون الإنسان هو عنق الزجاجة، لأن التقدّم لا يحصل إلا بعد أن يقرأ الإنسان النتيجة كاملة. أما في أسلوب الحلقات، فعنق الزجاجة ليس الإنسان بل جودة شرط الإنهاء. فإذا كان شرط الإنهاء واضحاً، تتقدم الحلقة نحو التقارب حتى في غياب الإنسان، وإذا كان ضعيفاً، تقع حتى أقوى النماذج في تكرار عقيم لا طائل منه. لذلك فإن جوهر هندسة الحلقات ليس مهارة صياغة جمل الموجّه، بل القدرة على تصميم آلية تجعل الجهاز قادراً على الحكم بنفسه على ما يُعدّ نجاحاً.

## تشريح الحلقة: تكرار الملاحظة والحكم والتنفيذ

الحلقة البرمجية التي تعمل بشكل جيد فعلياً تُكرر عادة الخطوات الأربع نفسها. يقترح النموذج تغييراً (Act)، ثم يُطبَّق هذا التغيير على قاعدة الكود ويُشغَّل أداة خارجية للحصول على نتيجة (Observe)، ثم يُحلَّل ذلك المخرَج لتحويله إلى سياق يوضح ما الذي فشل ولماذا (Learn)، ثم يُعاد إدخال هذا السياق إلى النموذج للحصول على الاقتراح التالي (Repeat). تستمر هذه الدورة حتى تجتاز بوابة الإنهاء أو تُستنفد الميزانية المخصصة.

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
<div class="d3-arch" data-arch-root id="pengineeringcodingagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 536, "height": 900, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 183, "y": 24, "w": 184, "h": 62, "title": ["اقتراح النموذج للتغيير", "Act"]}, {"id": "B", "x": 110, "y": 164, "w": 191, "h": 46, "title": "التطبيق على قاعدة الكود"}, {"id": "C", "x": 103, "y": 288, "w": 205, "h": 78, "title": ["تشغيل أداة خارجية", "اختبارات·مُجمّع·مدقق لغوي", "Observe"]}, {"id": "D", "x": 117, "y": 444, "w": 177, "h": 94, "title": ["تحليل المخرَج", "رسالة الخطأ·السطر·سبب", "الفشل", "Learn"]}, {"id": "E", "x": 29, "y": 630, "w": 146, "h": 68, "title": ["هل اجتازت", "بوابة الإنهاء؟"]}, {"id": "F", "x": 341, "y": 790, "w": 163, "h": 78, "title": ["إعادة حقن السياق في", "النموذج", "Repeat"]}, {"id": "G", "x": 24, "y": 798, "w": 120, "h": 62, "title": ["إنهاء الحلقة", "تقارب"]}, {"id": "H", "x": 230, "y": 641, "w": 156, "h": 46, "title": "توقف·تسليم للإنسان"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[244, 86], [205, 125], [205, 125], [205, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [205, 210, 205, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [205, 366, 205, 444]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[153, 538], [102, 584], [102, 584], [102, 630]]}, {"src": "E", "dst": "F", "kind": "data", "label": "لا", "line": [165, 698, 343, 790], "lx": 250, "ly": 740}, {"src": "F", "dst": "A", "kind": "data", "curve": [[429, 790], [436, 584], [436, 249], [346, 86]]}, {"src": "E", "dst": "G", "kind": "data", "label": "نعم", "line": [94, 698, 84, 798], "lx": 84, "ly": 740}, {"src": "D", "dst": "H", "kind": "event", "label": "استنفاد الميزانية", "curve": [[257, 538], [308, 584], [308, 584], [308, 641]], "off": "50%"}]});
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
      const container = document.getElementById('pengineeringcodingagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'pengineeringcodingagents-1';
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

الخطوة الثالثة، وهي التعلّم، مهمة بشكل خاص هنا. إذا لُخِّص مخرَج الأداة أو ضُغِط قبل إدخاله إلى النموذج، فإن الحلقة لا تتقارب بشكل جيد. يجب إدخال رسالة الخطأ التي يُصدرها المُجمّع، والملف والسطر اللذين فشلا، وتفاصيل عدم تطابق الأنواع كما هي، كسياق للموجّه التالي، حتى يستطيع النموذج استعادة "سبب الفشل" من دون ذاكرة بين الجلسات. هذا السجل قد يبدو مطوّلاً من منظور الإنسان، لكن هذا الإطناب بالنسبة للحلقة هو الإشارة الضرورية للتقارب.

## البوابات الحتمية هي إشارة المكافأة

أكثر نقطة تنحرف فيها هندسة الحلقات غالباً هي شرط الإنهاء. فإذا سألنا النموذج "هل انتهت هذه المهمة؟" وأوقفنا الحلقة بناءً على إجابته، فسينهي النموذج الحلقة مبكراً بتقرير ذاتي من نوع "يبدو أن المهمة اكتملت". هذا ليس تحققاً حقيقياً. الحلقة الموثوقة تُسند قرار الإنهاء إلى أداة حتمية لا إلى النموذج: هل اجتازت الاختبارات؟ هل بُني المشروع دون أخطاء من المُجمّع؟ هل صمت مدقق الأنواع؟ إشارة النجاح أو الفشل هذه تلعب بالضبط دور إشارة المكافأة في التعلّم المعزَّز. من دون الحاجة إلى تدريب نموذج مكافأة منفصل، يحكم مُشغِّل الاختبارات والمُجمّع الموجودان أصلاً على "أن هذا الكود صحيح".

رسّخت ThakiCloud هذا المبدأ فعلياً في حلقاتها الداخلية. مثال بارز هو pge-loop، الذي يُطبّق الفروقات (diff) التي يقترحها النموذج على الخلفية البرمجية المبنية بلغة Go، ثم يُشغّل الأمر `make test-short`، ويُعيد تغذية كامل مخرَج stderr كسياق للاقتراح التالي. شرط الإنهاء هنا ليس حكماً ذاتياً من النموذج، بل رمز خروج الاختبار. وبالمثل، يسعى Goal Mode بشكل مستقل نحو تحقيق الهدف حتى شرط الإنجاز، لكنه يتحقق من تقدّم كل خطوة عبر أمر تحقق محدد مسبقاً، وتشكّل الميزانية (عدد التكرارات والتكلفة والمهلة الزمنية) سقفاً أعلى. فهو لا يدور إلى ما لا نهاية، بل يتوقف عند التقارب أو عند استنفاد الميزانية. من دون هاتين الآليتين، أي بوابة الإنهاء الحتمية وسقف الميزانية، تصبح الحلقة أداة لا يمكن الوثوق بها.

عند استخدام fan-out تُضاف قاعدة إضافية. عندما تُطلَق عدة وكلاء فرعيين بالتوازي لجمع النتائج، يجب إغلاق الحلقة دائماً بمرحلة تحقق قبل دمج تلك النتائج. إن كان الناتج كوداً، تُستخدم بوابة الاختبار؛ وإن كان الناتج حكماً أو نتيجة بحث، تُطلَق عدة مُدقّقين متشككين من زوايا مختلفة ويُرشَّح الناتج عبر التصويت بينهم. دمج النتائج المتوازية مباشرة من دون تحقق يراكم مخرجات تبدو معقولة لكنها خاطئة. وغالباً ما يكون السبب الأول الذي يجب الشك فيه عندما تتراجع الجودة هو غياب مرحلة التحقق، لا مستوى النموذج.

## دلالات التطبيق على منتجات ThakiCloud

ترتبط هندسة الحلقات ارتباطاً مباشراً بمنتج Paxis من ThakiCloud. Paxis هو مستوى تحكم Agent-Native Cloud يعمل فوق ai-platform، ويتعامل مع المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. حتى لا تبقى الحلقة التي يكتبها الإنسان حبيسة بيئة تطوير شخصية، وتصبح بدلاً من ذلك مورداً على مستوى المنصة، يجب أن تُعرَض العناصر المكوّنة للحلقة بشكل قابل للإدارة. يختار Paxis نحو 960 مهارة عبر خوارزمية BM25 وينفّذها في صناديق رملية معزولة، ويمرّر كل سلوك عبر بوابات السياسات وسجلات التدقيق. بعبارة أخرى، عندما يصمم الإنسان "ما الذي يجب مراقبته ومتى يتوقف"، يوفر Paxis البنية التحتية التي تعزل تنفيذ تلك الحلقة وتسجّله وتتحكم فيه.

من هذا المنظور، تقابل البوابة الحتمية بوابة السياسات في Paxis بشكل طبيعي، ويقابل تنفيذ الأداة التنفيذ المعزول في الصندوق الرملي، ويقابل سجل ملاحظة الحلقة سجل التدقيق. والبنية التي تُحقّق فيها الحلقة من نفسها هي نفس المبدأ الذي تؤكد عليه Paxis تحت مسمى "إغلاق fan-out بالتحقق".

من الناحية البنيوية، يكمّل منظور ai-platform هذا الحديث. تشغيل الحلقات بكثرة يعني بالضرورة زيادة في استدعاءات الاستدلال المتكررة وتشغيل الاختبارات. يستوعب ai-platform هذا الحمل المتكرر بكفاءة من حيث التكلفة عبر جدولة وحدات معالجة الرسوميات (GPU) القائمة على Kubernetes وKueue، وخدمة النماذج عبر vLLM، والعزل متعدد المستأجرين. فقط عندما تكون تكلفة الخدمة منخفضة يصبح تشغيل الحلقات بشكل متكرر مجدياً اقتصادياً، وهذه الجدوى الاقتصادية هي ما يجعل الوكيل قابلاً للتشغيل بشكل دائم. تتشكل هنا حلقة الربط التي تجعل خدمة منخفضة التكلفة (ai-platform) تُنتج جدوى اقتصادية للوكيل (Paxis). وبالنسبة للعملاء الذين لديهم متطلبات محلية (on-premise) وسيادية، فإن إمكانية تشغيل هذه الحلقة بأكملها داخل بنيتهم التحتية الخاصة تحمل أهمية خاصة.

## الحدود والاعتراضات

تصوير هندسة الحلقات كحل شامل لكل شيء ليس أمراً صادقاً. أولاً، الحلقة تصبح خطيرة في المهام التي لا يمكن فيها بناء بوابة إنهاء. فمن دون أمر يحكم تلقائياً على النجاح أو الفشل، تستهلك الحلقة الميزانية فقط من دون أن تعرف نقطة التقارب. في هذه الحالات، يكون الأسلوب الأحادي الذي يُنفَّذ دفعة واحدة أفضل، والأولى الاعتراف بذلك بصدق.

ثانياً، كلما تعمّقت الحلقة، يميل الإنسان إلى الوثوق بالنتيجة والتوقف عن المراجعة. موقف "الحلقة ستتحقق من الأمر على أي حال" هو أخفى أنماط الفشل. الأتمتة أداة مساعدة للتفكير لا بديلة عنه، ويجب على الإنسان أن يستمر في مراجعة عيّنات من المخرجات الأساسية بشكل دوري. وإذا لم يُرشّح المُدقّق أي شيء إطلاقاً، فهذا لا يعني أن كل شيء اجتاز التحقق، بل من المرجح أنه إشارة إلى عطل في المُدقّق نفسه.

ثالثاً، التكلفة. الحلقة تستهلك بحكم تعريفها استدعاءات استدلال متعددة. من دون سقف، تُستنفد الميزانية في لحظات، وإذا رُبط نموذج قوي بشكل دائم، تزداد التكلفة بشكل مضاعف لا خطي. في الممارسة العملية، يلزم توجيه (Routing) يستخدم نموذجاً رخيصاً في الاستكشاف والتنفيذ المتكرر، ولا يُخصَّص النموذج المكلف إلا لمرحلة التحقق التي تكون الدقة فيها حرجة. ينطبق هنا أيضاً مبدأ أن يكون العامل (Worker) رخيصاً والبوابة (Gate) وحدها مكلفة.

وخلاصة القول، عبارة "لا أكتب موجّهات بل أكتب حلقات" استفزازية، لكنها تحمل مضموناً حقيقياً. غير أن هذا المضمون لا ينبع من نموذج مبهر، بل من تصميم مُملّ ولكنه دقيق يجعل الجهاز قادراً على الحكم بنفسه على ما يُعدّ نجاحاً. الدرس نفسه استخلصته ThakiCloud من pge-loop وGoal Mode: الحلقة الجيدة تنبع من شرط إنهاء جيد.

## المصادر

- ميلز دويتشر (Miles Deutscher)، منشور على X (تويتر سابقاً)، رأي حول حلقات وكلاء البرمجة
- ممارسات ThakiCloud الداخلية في هندسة الحلقات: pge-loop، Goal Mode (بوابة تحقق + سقف ميزانية)
- [ReAct: الورقة البحثية المؤسِّسة لحلقات الوكلاء القائمة على الاستدلال والفعل (arXiv:2210.03629)](https://arxiv.org/abs/2210.03629)
- [Anthropic, Building Effective Agents: استخدام الأدوات وحلقة المقيّم-المحسّن ونمط المنسّق-العمال](https://www.anthropic.com/research/building-effective-agents)
