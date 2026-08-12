---
title: "لماذا قُلّص التعليمات النظامية بنسبة 80 بالمئة: النماذج الأذكى تريد أطرا رقيقة"
excerpt: "أثار خبر تخفيض أنثروبيك حجم التعليمات النظامية في Claude Code بنسبة 80 بالمئة نقاشا واسعا بين المطورين. وأوضح المسؤول عن ذلك أن النموذج الجديد \"يريد تعليمات نظامية أصغر\"، وأنه في الواقع أكثر خيالا مما تسمح به التعليمات التي نكتبها له. نستعرض هذا التحول، حيث يزداد الإطار رقة كلما اشتد ذكاء النموذج وتتحول القواعد إلى سياق، مع ما لاحظته Thaki Cloud فعليا في تشغيل إطار مهارات Paxis ونظام قواعدها."
seo_title: "تقليص التعليمات النظامية في Claude Code بنسبة 80 بالمئة: الإطار الرقيق والتوجيه بالسياق - Thaki Cloud"
seo_description: "تحليل لخبر تقليص أنثروبيك التعليمات النظامية في Claude Code بنسبة 80 بالمئة. لماذا تريد النماذج القوية تعليمات أقصر، وماذا تقول أبحاث تداخل السقالات، والانتقال من القواعد الصارمة إلى التوجيه بالسياق، وما يعنيه ذلك لتصميم Paxis من Thaki Cloud القائم على إطار رقيق ومهارات ثقيلة."
date: 2026-07-20
last_modified_at: 2026-07-20
tags:
  - ai-coding
  - agentic
  - system-prompt
  - prompt-engineering
  - claude-code
  - claude-fable-5
  - agentops
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/claude-code-system-prompt-cut/"
categories:
  - agentops
---

![تحوّل موجّه نظام سميك إلى هيكل رفيع]({{ '/assets/images/claude-code-system-prompt-cut-hero.webp' | relative_url }})

## نظرة عامة

في الآونة الأخيرة، تداول مجتمع المطورين خبرا قصيرا بشكل لافت. وهو أن أنثروبيك أزالت نحو 80 بالمئة من التعليمات النظامية في Claude Code. والجزء المثير للاهتمام لم يكن التقليص بحد ذاته، بل السبب وراءه. فقد قال طارق شيهيبار (@trq212) من أنثروبيك إن سلسلة النماذج الجديدة Fable 5 "تريد تعليمات نظامية أصغر"، وأوضح أن إدراج الكثير من التعليمات والأمثلة قد يعيق النموذج فعليا. والسبب، بحسب قوله، أن النموذج أكثر خيالا من القواعد التي نكتبها له.

هذه الجملة ليست مجرد خبر تحسين منتج عادي. فعلى مدى السنوات الماضية، تطورت هندسة التعليمات في اتجاه "اكتب كل شيء ولا تترك شيئا". وكان يُنظر إلى حشر ما يجب تجنبه، والصيغة الواجب اتباعها، وحتى الحالات الاستثنائية بكثافة داخل التعليمات النظامية على أنه إطار عمل جيد. لكن الإشارة التي ظهرت الآن هي أنه عندما يصبح النموذج قويا بما يكفي، قد تتحول هذه الكثافة من أصل إلى عبء.

تشغّل Thaki Cloud منصة SaaS للذكاء الاصطناعي وتعلم الآلة قائمة على Kubernetes، وتدير من خلال طبقة تحكم الوكلاء Paxis العاملة فوقها أكثر من 960 مهارة وعشرات القواعد الدائمة كإطار عمل. لذلك، فإن سؤال "كم يجب أن ندرج في التعليمات النظامية" ليس بالنسبة لنا جملة رائجة بل قرار تصميم نواجهه يوميا. يستعرض هذا المقال ما يعنيه هذا التقليص، ولماذا تريد النماذج الأذكى إطارا أرق، وكيف يمكن ترجمة هذا المبدأ إلى ممارسة تشغيلية فعلية.

## ما الذي تغيّر

يتلخص جوهر الخبر المنشور في نقطتين. الأولى أن حجم التعليمات النظامية في Claude Code انخفض بشكل كبير. والثانية أن السبب ليس "النموذج ضعيف فنملؤه أكثر" بل على العكس "النموذج أصبح قويا فنملؤه أقل".

بحسب تفسير أنثروبيك، ازدادت قدرة النموذج الجديد على استيعاب معايير السلوك داخليا أثناء التدريب. فما كان يجب سابقا كتابته بالتفصيل في التعليمات النظامية عند لحظة النشر، أصبح النموذج الآن يحمله إلى حد ما داخل أوزانه. ونتيجة لذلك، انتقل دور التعليمات النظامية من "دفتر لوائح يحتوي كل القواعد" إلى "مُعِدّ سياق خفيف"، بحسب التفسير المرافق للخبر. كما وردت إشارة إلى توجيه النموذج بالاعتماد على السياق بدلا من صيغ المنع الجافة مثل "لا تفعل هذا".

يوضح الرسم البياني أدناه بنية هذا التحول. فالطريقة القديمة القائمة على دفتر لوائح ثقيل على اليسار، والطريقة الجديدة القائمة على إعداد سياق رقيق على اليمين، تختلفان في مكان تراكم القدرة داخل كل منهما.

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
<div class="d3-arch" data-arch-root id="laudecodesystempromptcut-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 793, "height": 538, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 245, "h": 482, "label": "سابقا: تعليمات نظامية ثقيلة", "lx": 36, "ly": 42}, {"x": 495, "y": 24, "w": 266, "h": 482, "label": "حاليا: إطار رقيق مع سياق", "lx": 507, "ly": 42}], "nodes": [{"id": "A1", "x": 65, "y": 63, "w": 163, "h": 94, "title": ["تحديد كل القواعد", "والاستثناءات", "والصيغ في التعليمات", "النظامية"]}, {"id": "A2", "x": 62, "y": 257, "w": 170, "h": 62, "title": ["توقع أن يتبع النموذج", "التعليمات كما هي"]}, {"id": "A3", "x": 72, "y": 405, "w": 149, "h": 62, "title": ["قد تحد التعليمات", "من القدرة الفعلية"]}, {"id": "B1", "x": 532, "y": 79, "w": 191, "h": 62, "title": ["التعليمات النظامية تحدد", "سياقا خفيفا فقط"]}, {"id": "B2", "x": 543, "y": 249, "w": 170, "h": 78, "title": ["استثمار الحكم", "الذي استوعبه النموذج", "داخليا"]}, {"id": "B3", "x": 546, "y": 405, "w": 163, "h": 62, "title": ["تُحقن القواعد كسياق", "عند الحاجة فقط"]}, {"id": "OLD", "x": 322, "y": 87, "w": 120, "h": 46, "title": "OLD"}, {"id": "NEW", "x": 322, "y": 265, "w": 120, "h": 46, "title": "NEW"}], "edges": [{"src": "A1", "dst": "A2", "kind": "data", "line": [147, 157, 147, 257]}, {"src": "A2", "dst": "A3", "kind": "data", "line": [147, 319, 147, 405]}, {"src": "B1", "dst": "B2", "kind": "data", "line": [628, 141, 628, 249]}, {"src": "B2", "dst": "B3", "kind": "data", "line": [628, 327, 628, 405]}, {"src": "OLD", "dst": "NEW", "kind": "event", "label": "الانتقال مع تعاظم قوة النموذج", "line": [382, 133, 382, 265], "lx": 382, "ly": 199}]});
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
      const container = document.getElementById('laudecodesystempromptcut-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodesystempromptcut-1';
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

وهنا نقطة تستحق الحذر. فـ"تقليص التعليمات النظامية" لا يعني "إلغاء التعليمات". ما تقلص هو الإطار الدائم الذي كان مرفقا دوما عند لحظة النشر، أما المعرفة المجالية وأساس الأحكام فلا تزال بحاجة إلى مكان تُحفظ فيه. الذي تغيّر هو مكان تخزين هذه المعرفة.

## لماذا تريد النماذج الأذكى تعليمات أرق

هذه الظاهرة ليست حديثا يدور بالحدس وحده. فهناك أبحاث تشير إلى أن زيادة سقالات الوكيل (الإطار) لا تُحسّن الأداء بالضرورة، بل قد تسبب تداخلا بينها. على سبيل المثال، تتناول ورقة "More Is Not Always Better: Cross-Component Interference in LLM Agent Scaffolding" (arXiv 2605.05716) النقطة التي يبدأ عندها إضافة المزيد من مكونات الإطار في خلق تداخل بين هذه المكونات، مما يؤدي إلى تراجع الأداء الإجمالي. وهذه ملاحظة تفيد بأن إضافة المزيد من التعليمات ليست منفعة متزايدة باطراد.

ولفهم الأمر بشكل بديهي، يمكن تفسيره كالتالي. كلما أضيفت قاعدة إلى التعليمات النظامية، يتعامل النموذج معها كقيد يجب الالتزام به في كل لحظة. وعندما تكون القواعد قليلة، يشكل هذا القيد حاجزا وقائيا مفيدا. لكن عندما يزداد عدد القواعد إلى العشرات، تتعارض بعضها مع بعض أو تُشوّش تعليمات غير ذات صلة بالمهمة الحالية على الحكم. وكانت النماذج الضعيفة تتيه دون تعليمات صريحة، لذلك كان تحمل هذه التكلفة يستحق العناء. أما النماذج القوية، فقد ازدادت قدرتها على قراءة الموقف بنفسها، فبدأت تكلفة التداخل الناتجة عن التعليمات غير الضرورية تتجاوز الفائدة التي تقدمها تلك التعليمات.

وهنا بالضبط تصبح عبارة "النموذج أكثر خيالا من التعليمات التي نكتبها له" مفهومة. فالقواعد الكثيفة تضع حدا أدنى يمنع أسوأ المخرجات، لكنها في الوقت نفسه تصبح سقفا يكبح أفضل المخرجات. فحين يستطيع النموذج الصعود فوق ذلك السقف، يصبح إزالة القواعد فعليا فتحا للأداء.

غير أن هذا المنطق ليس مطلقا. فإزالة الحد الأدنى قد ترفع المتوسط، لكنها تزيد التباين في الوقت نفسه. أي أن الحاجز الوقائي الذي كان يمنع ظهور مخرجات سيئة من حين لآخر يختفي. لهذا السبب، فإن "ما الذي يجب إزالته" أهم عمليا من "كم يجب إزالته".

## من القواعد إلى السياق

أكثر ما يفيد عمليا في هذا الخبر هو جزء "التوجيه بالسياق بدلا من صيغ المنع الجافة". فهناك طريقتان لنقل النية نفسها.

الأولى هي القاعدة الصارمة. وتُصاغ بالمنع والإلزام، مثل "لا تستخدم مصطلحات تقنية" أو "التزم حتما بهذه الصيغة". هذه الطريقة واضحة، لكنها إذا تراكمت كإطار دائم تُنتج التداخل المذكور آنفا. أما الثانية فهي إعداد السياق. وفيها يُوصف الحالة المرجوة للنتيجة، مثل "اكتب هذا النص بمستوى يسهل على قارئ في السادسة عشرة فهمه". وغالبا ما تعمل الطريقة الثانية بثبات أكبر مع النماذج القوية. ليس لأنها لا تفهم الصيغ السلبية، بل لأن الهدف المصاغ إيجابا يمنح النموذج مساحة ليملأ التفاصيل بنفسه.

وهنا ينشأ تمييز مهم. فالأمر لا يتعلق بإزالة كل المعرفة من التعليمات النظامية، بل بفصل الإطار الدائم عن المعرفة المطلوبة عند الحاجة. يُبقى فقط ما يلزم في كل لحظة دائما، بينما تُستدعى المعرفة اللازمة لمهمة محددة كسياق عند بدء تلك المهمة. وبهذا يظل الإطار الدائم رقيقا، بينما تُقدَّم المعرفة المجالية بكثافة عند اللحظة المطلوبة.

غير أن ما يجب ألا يتزعزع، مثل اتساق الصيغة، ينبغي أن يبقى بحوزة الشيفرة الحتمية. فبدلا من أن نطلب من النموذج "أجب دائما بالصيغة نفسها من JSON"، يكون من الأسلم أن تفرض الشيفرة صيغة المخرجات والتجميع، ويكتفي النموذج بتوليد المحتوى فقط. وتيار جعل التعليمات أرق لا يتعارض مع مبدأ تثبيت الصيغة بالشيفرة، بل يكمل كل منهما الآخر. فما لا يجوز أن يتزعزع يُنزَّل إلى الشيفرة، وما يحتاج إلى حكم يُترك للنموذج، وكلاهما يُخفَّف من الإطار الدائم.

## دلالات على مستوى منتجات Thaki Cloud

يتقاطع هذا التيار بدقة مع فلسفة تصميم منصة الوكلاء Paxis الخاصة بـ Thaki Cloud. فـ Paxis طبقة تحكم للسحابة الأصيلة للوكلاء (Agent-Native Cloud) تعمل فوق ai-platform، وتتعامل مع المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. ومن أبرز مبادئ التصميم فيها "إطار رقيق، ومهارات ثقيلة". فحلقة النموذج والصلاحيات والأمان، أي الإطار، تُبقى عند الحد الأدنى، بينما تُكدَّس المعرفة المجالية والأحكام وحالات الفشل بكثافة في المهارات.

لا يضع إطار المهارات في Paxis أكثر من 960 مهارة كلها في التعليمات النظامية الدائمة. بل يختار عند وصول الطلب، عبر بحث BM25، المهارات ذات الصلة فقط ويستدعيها كسياق في تلك اللحظة تحديدا. وهذا بالضبط تجسيد لما يعنيه هذا الخبر بـ"مُعِدّ السياق الخفيف". إذ يظل الإطار الدائم الذي يُدفع ثمنه في كل حالة رقيقا، بينما تُقدَّم المعرفة الكثيفة فقط عند مهمة محددة. ومنذ لحظة إدراج أي مهارة في الفهرس، يبدأ اسمها ووصفها بتحمل تكلفة رمزية (توكن) في كل جلسة، لذلك نحكم على إدراج كل جملة في الإطار الدائم بمعيار: هل يخطئ الوكيل من دونها؟

يرتبط مبدأ التوجيه بالسياق أيضا بتشغيلنا. فبوابات السياسات وسجلات التدقيق في Paxis تفرض بالشيفرة الحتمية القواعد التي لا يجوز أن تتزعزع. أما المجالات التي تتطلب جودة محتوى أو حكما، فتُترك للنموذج، مع توجيه اتجاهه فقط بقاعدة رقيقة. ولأن القواعد الدائمة تُدفع ثمنها رمزيا في كل دورة تفاعل، نُبقي دائما فقط ما هو ضروري باستمرار، بينما نُنزّل ما يُحتاج إليه أحيانا إلى مهارات تُحمَّل عند الطلب. وبهذا نطبق يوميا في رسم الحدود بين المهارات والقواعد الدرس نفسه الذي تعلمته أنثروبيك من تعليماتها النظامية.

وهناك دلالة أيضا من منظور البنية التحتية. فحين تصبح التعليمات النظامية أرق، تقل رموز الإدخال (input tokens)، وهذا يؤثر مباشرة على تكلفة الخدمة والتأخير. وفي بيئة تخدم فيها ai-platform النماذج عبر vLLM بتشغيل متعدد المستأجرين، فإن تقليص الإطار الدائم ليس مسألة جودة فحسب بل مسألة اقتصادية أيضا. فانخفاض تكلفة الخدمة يُتيح تشغيل الوكلاء بشكل أكثر تواترا وعلى نطاق أوسع، وهذه القدرة بدورها تصنع جدوى اقتصادية للوكلاء.

## الحدود والاعتراضات

يجب توخي الحذر عند تعميم هذا التيار كما هو. وفيما يلي بعض الاعتراضات نطرحها بأمانة.

أولا، الاستنتاج القائل بأن "كلما كان أرق كان أفضل" استنتاج خطير. فتقليص التعليمات لا يفتح الأداء إلا حين يكون النموذج قويا بما يكفي، وتلك العتبة تختلف باختلاف النموذج والمهمة. فإزالة الإطار بتسرع في نموذج ضعيف أو مهمة عالية المخاطر يُزيل الحد الأدنى الوقائي ويزيد من احتمال ظهور مخرجات سيئة. وفعليا، حين تتزعزع جودة المحتوى في نموذج منخفض التكلفة ضمن تشغيلنا، نستجيب بتثبيت الصيغة بشكل أشد عبر الشيفرة.

ثانيا، الأرقام المحددة في هذا الخبر مستندة إلى تصريح علني من مسؤول في أنثروبيك وما نقلته وسائل الإعلام عنه، ولم تُنشر بيانات دقيقة عن طول التعليمات النظامية قبل التقليص وبعده أو نتائج قياسية مرجعية. فرقم "80 بالمئة" هو تعبير أُعلن رسميا، لكننا لم نُعِد قياس أثره على الأداء بشكل مستقل، ونوضح ذلك بجلاء.

ثالثا، السؤال المحوري هو ما الذي يملأ المكان الذي أُزيلت منه التعليمات. فحذف التعليمات من التعليمات النظامية لا يعني اختفاء المعرفة. فتلك المعرفة يجب أن تنتقل إلى مكان آخر، سواء داخل أوزان النموذج، أو مهارة تُستدعى عند الطلب، أو بوابة شيفرة حتمية. وإذا حُذفت المعرفة دون تجهيز مكان لنقلها، سرعان ما يعود الإطار الأرق إلى مخرجات غير محكومة. وفي النهاية، هذه ليست منافسة على "الكتابة الأقل" بل مسألة تصميم تتعلق بـ"ما الذي يوضع وأين".

خلاصة القول، هذا التقليص مؤشر واحد يكشف عن انتقال مركز ثقل هندسة التعليمات. فكلما اشتد ذكاء النموذج، يزداد الإطار الدائم رقة، وتُعاد صياغة القواعد وتوزيعها بين السياق والشيفرة. وقد طبقت Thaki Cloud هذا المبدأ فعليا من خلال إطار Paxis الرقيق ومهاراته الثقيلة، ويؤكد هذا الخبر أن هذا الاتجاه ليس ذائقة خاصة بنا بل تيار تتجه إليه الصناعة معا.

## المصادر

- تصريح علني منسوب لطارق شيهيبار (@trq212) من أنثروبيك، نقلا عن موقع [the-decoder.com](https://the-decoder.com/anthropic-says-it-cut-80-percent-of-claude-codes-system-prompt-because-fable-5-models-want-a-smaller-system-prompt/)
- ["Anthropic Slashes Claude Code System Prompt by 80%", ClaudeAINews](https://www.claudeainews.com/news/anthropic-cuts-claude-code-system-prompt-80-percent)
- ["More Is Not Always Better: Cross-Component Interference in LLM Agent Scaffolding", arXiv 2605.05716](https://arxiv.org/abs/2605.05716)
