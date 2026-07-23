---
title: "عندما تبدأ عوامل البرمجة بالتحدث مع بعضها البعض: تصميم Claude Code متعدد اللاعبين وعوامل التعاون"
seo_title: "Claude Code متعدد اللاعبين - تحليل تصميم عوامل البرمجة التعاونية - Thaki Cloud"
seo_description: "انطلاقاً من Claude Code متعدد اللاعبين الذي يتيح لعدة أشخاص وعدة نسخ من Claude التحدث مع بعضها البعض في الطرفية نفسها، نفكك تحديات تصميم عوامل البرمجة التعاونية ونتحقق من الأمر من منظور Paxis من ThakiCloud الذي يتعامل مع العوامل المتعددة كموارد من الدرجة الأولى."
excerpt: "ننتقل من بنية يستخدم فيها كل شخص عاملاً واحداً، إلى بنية يتحدث فيها عدة أشخاص وعدة عوامل مع بعضهم البعض في مساحة العمل نفسها. انطلاقاً من Claude Code متعدد اللاعبين، نتناول مسائل التزامن والتصادم وحدود الثقة في عوامل التعاون، ونتحقق منها من منظور تشغيل ThakiCloud."
date: 2026-07-12
tags:
  - claude-code
  - multi-agent
  - collaboration
  - agentops
  - paxis
  - orchestration
categories:
  - agentops
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/claude-code-multiplayer-collaborative-agents/"
---

![من العوامل المعزولة إلى شبكة مترابطة من عوامل التعاون]({{ '/assets/images/claude-code-multiplayer-collaborative-agents-hero.webp' | relative_url }})

عند استخدام عوامل البرمجة (coding agents) ضمن فريق، نصطدم بجدار غريب. العامل ملك لي وحدي. حتى لو كان زميلي في المكتب المجاور يعمل على المستودع نفسه، فإن كل Claude لا يعرف بوجود الآخر. البشر يتعاونون عبر Slack ومشاركة الشاشة، بينما العوامل التي تعدّل الكود نيابة عنا محبوسة كل واحدة في جزيرتها الخاصة. أداة **Claude Code متعدد اللاعبين** التي كُشف عنها مؤخراً وأثارت ضجة تستهدف هذا الجدار بالتحديد. إنها تجربة تتيح لعدة أشخاص استخدام الطرفية (terminal) نفسها معاً، وربط كل Claude بالآخر بحيث تتحدث العوامل فيما بينها. تنطلق هذه المقالة من هذه المحاولة لتفكيك تحديات التصميم التي يجب أن تحلها عوامل البرمجة التعاونية، وتتحقق مما يعنيه هذا الاتجاه من منظور تشغيل ThakiCloud الذي يتعامل مع العوامل المتعددة والسياسات كموارد من الدرجة الأولى.

## نظرة عامة

حتى الآن كانت الوحدة الأساسية لعوامل البرمجة هي **عامل واحد لكل شخص**. يعيش Claude Code في طرفيتي الخاصة، يفهم قاعدة الكود الخاصة بي، ويتلقى أوامري أنا وحدي. هذه البنية ممتازة للإنتاجية الفردية، لكنها تتعارض مع حقيقة أن البرمجيات، في جوهرها، عمل جماعي. Claude Code متعدد اللاعبين الذي كشفت عنه المطوّرة دورسا روهاني (Dorsa Rohani) يقلب هذا الافتراض رأساً على عقب. وفقاً لما أُعلن، تتيح هذه الأداة أمرين. أولاً، يشارك عدة أشخاص **جلسة الطرفية نفسها** ويعملون معاً. ثانياً، يتم **ربط كل Claude بالآخر** بحيث تتحدث العوامل فيما بينها.

الجدير بالملاحظة أن هذا ليس مجرد لعبة عابرة، بل قطعة من تيار أكبر. ظهرت في الفترة نفسها تقريباً مشاريع متتالية تجمع عدة أشخاص وعدة عوامل برمجة في مساحة عمل واحدة. من الأمثلة على ذلك `oh-my-claudecode` الذي يتبنى تنسيقاً متعدد العوامل يضع الفريق أولاً، و`claude_codex_bridge` الذي يمزج بين عدة عوامل من بينها Codex وClaude في مساحة عمل واحدة، و`codeg` وهو مساحة عمل تعاونية تجمّع جلسات عدة عوامل. يتقارب الاتجاه في نقطة واحدة: **التعامل مع العوامل ليست كوحدات معزولة، بل كمشاركين يتواصلون فيما بينهم**.

سبب أهمية هذا التيار واضح. في المنظمات التطويرية الفعلية، يأتي جزء كبير من العمل ذي القيمة من التنسيق: من يعمل على أي ملف، هل يكسر هذا التغيير تلك الوحدة، وما الذي يقلق المراجع. إذا لم تشارك العوامل في هذا التنسيق، فسننتهي في النهاية بأن يقوم البشر بخياطة نواتج العوامل المنفصلة يدوياً من جديد. عوامل التعاون هي محاولة لتقليل تكلفة تلك الخياطة.

## ما هو عامل البرمجة متعدد اللاعبين

كلمة "متعدد اللاعبين" (multiplayer) جاءت من عالم الألعاب، لكنها هنا تشير إلى محورين مختلفين في آنٍ واحد. الأول هو محور **إنسان مقابل إنسان**: عدة مطوّرين يشاركون الجلسة نفسها ويوجّهون تعليماتهم معاً إلى عامل واحد. والثاني هو محور **عامل مقابل عامل**: يتبادل كل عامل الرسائل مع الآخر ويوزّعان العمل فيما بينهما. سبب إثارة Claude Code متعدد اللاعبين للاهتمام هو أنه يتعامل مع هذين المحورين معاً.

يوضّح المخطط أدناه الفرق بين البنية المعزولة التقليدية والبنية التعاونية.

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
<div class="d3-arch" data-arch-root id="layercollaborativeagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1021, "height": 805, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 370, "h": 432, "label": "الوضع الحالي: مطوّر واحد لكل عامل (معزول)", "lx": 36, "ly": 42}, {"x": 589, "y": 24, "w": 400, "h": 749, "label": "التعاون: جلسة مشتركة + عوامل متصلة", "lx": 601, "ly": 42}], "nodes": [{"id": "devA1", "x": 62, "y": 63, "w": 120, "h": 46, "title": "المطوّر A"}, {"id": "claudeA1", "x": 62, "y": 201, "w": 120, "h": 62, "title": ["Claude A", "(سياق A فقط)"]}, {"id": "devB1", "x": 237, "y": 209, "w": 120, "h": 46, "title": "المطوّر B"}, {"id": "claudeB1", "x": 149, "y": 355, "w": 120, "h": 62, "title": ["Claude B", "(سياق B فقط)"]}, {"id": "personA", "x": 634, "y": 63, "w": 120, "h": 46, "title": "المطوّر A"}, {"id": "session", "x": 707, "y": 209, "w": 149, "h": 46, "title": "جلسة طرفية مشتركة"}, {"id": "personB", "x": 819, "y": 63, "w": 120, "h": 46, "title": "المطوّر B"}, {"id": "agentA", "x": 770, "y": 363, "w": 120, "h": 46, "title": "Claude A"}, {"id": "agentB", "x": 819, "y": 548, "w": 120, "h": 46, "title": "Claude B"}, {"id": "sharedState", "x": 745, "y": 672, "w": 170, "h": 62, "title": ["حالة عمل مشتركة", "(المستودع · التقدّم)"]}, {"id": "existing", "x": 432, "y": 63, "w": 120, "h": 46, "title": "existing"}, {"id": "collab", "x": 432, "y": 209, "w": 120, "h": 46, "title": "collab"}], "edges": [{"src": "devA1", "dst": "claudeA1", "kind": "data", "line": [122, 109, 122, 201]}, {"src": "devB1", "dst": "claudeB1", "kind": "data", "curve": [[297, 255], [297, 309], [297, 309], [244, 355]]}, {"src": "claudeA1", "dst": "claudeB1", "kind": "event", "label": "انقطاع", "curve": [[122, 263], [122, 309], [122, 309], [174, 355]], "off": "50%"}, {"src": "personA", "dst": "session", "kind": "data", "curve": [[694, 109], [694, 155], [694, 155], [755, 209]]}, {"src": "personB", "dst": "session", "kind": "data", "curve": [[879, 109], [879, 155], [879, 155], [810, 209]]}, {"src": "session", "dst": "agentA", "kind": "data", "curve": [[796, 255], [830, 309], [830, 309], [830, 363]]}, {"src": "session", "dst": "agentB", "kind": "data", "curve": [[744, 255], [655, 386], [655, 502], [819, 552]]}, {"src": "agentA", "dst": "agentB", "kind": "data", "label": "رسائل بين العوامل", "curve": [[846, 409], [879, 456], [879, 502], [879, 548]], "off": "50%"}, {"src": "agentA", "dst": "sharedState", "kind": "data", "curve": [[792, 409], [714, 502], [714, 633], [779, 672]]}, {"src": "agentB", "dst": "sharedState", "kind": "data", "curve": [[879, 594], [879, 633], [879, 633], [852, 672]]}, {"src": "existing", "dst": "collab", "kind": "data", "label": "تحوّل نموذجي", "line": [492, 109, 492, 209], "lx": 492, "ly": 151}]});
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
      const container = document.getElementById('layercollaborativeagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'layercollaborativeagents-1';
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

في البنية التقليدية، لا يدرك عاملا المطوّرين وجود بعضهما البعض حتى لو كانا يعملان على المستودع نفسه. بما أن كل عامل يحكم ضمن سياقه الخاص فقط، يحدث أن يستدعي Claude الخاص بـ B واجهة أعاد Claude الخاص بـ A هيكلتها، لكن باستخدام التوقيع (signature) القديم دون أن يعلم بذلك. أما في البنية التعاونية، فتُشارَك الجلسة والحالة، وتتبادل العوامل الرسائل فيما بينها، مما يفتح مجالاً لتقليل هذا التضارب في وقت شبه فعلي (near real-time).

إلا أنه من الصعب الجزم، بناءً على المعلومات المُعلَنة فقط، بمدى تطوّر هذا الاتصال فعلياً. تتفاوت الجدوى العملية بشكل كبير حسب ما إذا كانت الطرفية المشتركة مجرد بث للشاشة، أو أن العوامل تتبادل فعلاً خططها ونيّات تعديلها في شكل منظَّم (structured). تركّز هذه المقالة على تناول تحديات التصميم استناداً إلى المفهوم المُعلَن، ولا تجزم بآليات داخلية لم يتم التحقق منها.

## لماذا هذا الاتجاه الآن

هناك سبب لظهور عوامل التعاون في هذا التوقيت بالذات. مع تعاظم قوة النماذج، كبر حجم المهام التي يعالجها عامل واحد، وبالتالي أصبحت **حالات قيام عدة عوامل بإجراء تغييرات كبيرة في آنٍ واحد** أكثر تكراراً فعلياً. أصبح نمط تشغيل شخص واحد لعدة عوامل فرعية بالتوازي لتوزيع تعديل الملفات فيما بينها أمراً شائعاً بالفعل. خطوة واحدة أخرى إلى الأمام من هذه النقطة تكفي لتصل إلى لحظة تتقاطع فيها عوامل أشخاص مختلفين على قاعدة الكود نفسها. وبدون تنسيق، تتحول هذه اللحظة فوراً إلى تصادم.

خلفية أخرى هي تشظّي (fragmentation) نظام الأدوات البيئي. في كل فريق يختلط من يستخدم Claude Code، ومن يستخدم Codex، ومن يستخدم Cursor. ظهور المشاريع المذكورة آنفاً التي تجمع عوامل من عدة موردين في مساحة عمل واحدة هو محاولة لامتصاص هذا التشظّي عبر طبقة تنسيق. بعبارة أخرى، لم تعد عوامل التعاون مجرد ميزة لإضافة أشخاص أكثر، بل تتحوّل إلى **مسألة بنية تحتية للتعامل مع واقع تعايش عوامل غير متجانسة**.

## تحديات التصميم التي يجب أن تحلها عوامل التعاون

خلف المفهوم الجذّاب تكمن هندسة ليست بالسهلة. لكي تصل عوامل التعاون إلى بيئة الإنتاج الفعلية، يجب حل أربع مسائل على الأقل.

أولاً، **التزامن والتصادم (Concurrency and Conflict)**. يجب تحديد ما يحدث عندما يعدّل عاملان المنطقة نفسها من الملف نفسه في الوقت ذاته. في تعاون البشر، امتصت فروع git (branches) وعمليات الدمج (merge) هذه المشكلة، لكن الجلسات المشتركة في الوقت الفعلي تحتاج إلى تنسيق بدورات زمنية أقصر من ذلك بكثير. هل نضع قفلاً (lock)؟ أم نعتمد التعديل التفاؤلي (optimistic editing) ثم الدمج لاحقاً؟ أم نوزّع مناطق العمل منذ البداية بحيث لا تتداخل؟ هذه هي مفترق طرق التصميم.

ثانياً، **نطاق مشاركة السياق (Context)**. لجعل العوامل تتحدث فيما بينها، يجب تحديد ما الذي سيتم مشاركته. إذا نُقل سجل المحادثة الكامل دفعة واحدة، تنفجر تكلفة الرموز (tokens) ويتلوّث السياق. وفي المقابل، إذا شُوركت كمية قليلة جداً، يفقد التعاون معناه. ما هو مطلوب في النهاية هو **تبادل حالة مُلخَّصة ومنظَّمة**. يجب تبادل نية من قبيل "أخطط لتغيير هذه الدالة في هذا الملف على هذا النحو" في صيغة مضغوطة، وليس كنص خام كامل.

ثالثاً، **حدود الثقة (Trust Boundaries)**. وهي مسألة إلى أي مدى يجب أن يثق عاملي بالتغيير الذي يقترحه عامل شخص آخر. تماماً كما لا يدمج البشر التغييرات دون مراجعة، يجب ألا تقبل العوامل نواتج عوامل أخرى دون تحقّق. الدرس القديم في أنظمة العوامل المتعددة واضح: **دمج نتائج عدة عوامل دون مرحلة تحقق يراكم الهلوسات (hallucinations)**. وكلما زاد التعاون، ازدادت الحاجة إلى بوابات تحقق عدائية (adversarial verification) تفحص ناتج كل مشارك.

رابعاً، **التدقيق وتتبّع المسؤولية (Audit and Accountability)**. عندما يعمل عدة أشخاص وعدة عوامل على الكود نفسه، إذا تعذّر تتبّع أي تغيير نتج عن قرار من هو (أو أي عامل)، فلن يمكن إعادة تتبّع السبب عند وقوع حادث. كلما زاد التعاون، تحوّل سجل التدقيق (audit log) من خيار إلى ضرورة.

## الدلالات على تطبيقات منتجات ThakiCloud

تتطابق تحديات التصميم هذه تماماً مع المسائل التي تتصدى لها ThakiCloud بالفعل بشكل مباشر في **Paxis**. Paxis هي مستوى تحكّم (control plane) من نوع Agent-Native Cloud يعمل فوق ai-platform، ويتعامل مع Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. تستجيب بنية Paxis للأسئلة التي يطرحها عامل البرمجة متعدد اللاعبين على النحو التالي.

هيكل التعاون بين العوامل هو تنسيق **العوامل المتعددة القائم على DAG** في Paxis. بدلاً من إطلاق عدة عوامل بشكل عشوائي في المساحة نفسها، يتم تفكيك المهمة إلى رسم بياني موجّه غير دوري (Directed Acyclic Graph)، بحيث تمتلك كل عقدة (node) منطقة مسؤوليتها الخاصة، مما يتيح تجنّب جزء كبير من تصادمات التزامن المذكورة آنفاً بنيوياً. إنها طريقة توزّع العمل منذ البداية بحيث لا يتداخل، بدلاً من دمج التعديلات المتداخلة لاحقاً.

تجيب **بوابات السياسات (policy gates) وسجلات التدقيق** في Paxis على مسألة حدود الثقة. يجب أن يمرّ ناتج أي عامل عبر بوابة سياسة قبل أن ينتقل إلى عامل آخر أو إلى نظام فعلي، وتُسجَّل جميع الإجراءات في سجل التدقيق. هذا يفرض من الناحية البنيوية للبنية التحتية مبدأ "لا تُدمَج نتائج عدة عوامل دون تحقق". وكلما ازداد التعاون، تعاظمت قيمة هذه البوابة.

تخفف **Skill Harness** ومحرك المعرفة في Paxis من مشكلة تكلفة مشاركة السياق. البنية التي تختار أكثر من 960 مهارة (skill) عبر BM25 وتنفّذها في صندوق رملي معزول (isolated sandbox) مصمَّمة بحيث يستدعي العامل القدرات المطلوبة عند الحاجة فقط، بدلاً من حمل السياق الكامل في كل مرة. هذا يتماشى مع المطلب القائل بأن على عوامل التعاون تبادل الحالة في شكل ملخَّص، لا كتبادل كامل.

ما يدعم موارد التنفيذ تحت ذلك هو **ai-platform**. لكي يقوم عدة أشخاص وعدة عوامل بتنفيذ الكود في آنٍ واحد داخل صناديق رملية معزولة، يلزم عزل متعدد المستأجرين (multi-tenant isolation) وحوسبة مرنة. توفّر جدولة GPU القائمة على K8s وKueue، والعزل متعدد المستأجرين، الأساس الذي تعمل عليه عوامل التعاون فعلياً. وكون هذه البنية التعاونية يمكن إقامتها بأمان حتى في بيئات محلية (on-premises) وذات سيادة (sovereign)، له دلالة خاصة بالنسبة للمنظمات القلقة بشأن تسرّب البيانات.

باختصار، إذا كان Claude Code متعدد اللاعبين يجرّب مفهوم التعاون على مستوى الأداة الفردية، فإن Paxis يبنيه هيكلياً على مستوى مستوى التحكّم عبر السياسات والتدقيق والتنسيق. المستويان ليسا في تنافس بل في تكامل. لأن انتقال عوامل التعاون من عرض توضيحي ممتع إلى تشغيل يمكن الوثوق به يحتاج في النهاية إلى مستوى تحكّم مزوّد ببوابات سياسات وسجلات تدقيق وعزل موارد.

## القيود والحجج المضادة

لا يمكن التفاؤل بعوامل التعاون فحسب. أكبر حجة مضادة هي أن **تكلفة التنسيق قد تلتهم فوائد التعاون**. تماماً كالاجتماعات بين البشر، فإن ازدياد الرسائل المتبادَلة بين العوامل يتحوّل بحد ذاته إلى تأخير وتكلفة رموز إضافية. من الممكن تماماً أن ينشغل عاملان بالتحقق المستمر من خطط بعضهما البعض إلى درجة عدم إنتاج الكود فعلياً. التعاون ليس دائماً أسرع من العمل المنفرد المتوازي.

ثانياً، **ترابط أنماط الفشل**. عندما تكون العوامل متصلة ببعضها، ينتقل الحكم الخاطئ لعامل واحد إلى العوامل الأخرى. في البنية المعزولة يبقى خطأ الشخص الواحد محصوراً فيه، أما في البنية المتصلة فينتشر الخطأ عبر السلسلة. وبدون بوابة تحقق، يضخّم التعاون الحوادث بدلاً من أن يقلّلها.

ثالثاً، لم يتم التحقق بعد من مستوى تبادل الحالة الذي نفّذته فعلياً الأداة متعددة اللاعبين المُعلَنة حالياً. تتفاوت الجدوى العملية بشكل كبير حسب ما إذا كانت الطرفية المشتركة أقرب إلى مشاركة الشاشة، أو بروتوكول منظَّم حقيقي بين العوامل. اتجاه المفهوم واضح، لكن قبل نقله إلى بيئة الإنتاج، يجب التأكد حتماً من حدود الثقة ومسار التدقيق. لا تزال هناك مسافة كبيرة بين العرض التوضيحي المثير للاهتمام والبنية التحتية الموثوقة.

ومع ذلك، أرى أن الاتجاه نفسه يصعب التراجع عنه. طالما أن البرمجيات عمل جماعي، فإن العوامل التي تمثّل هذا الفريق يجب أن تتحدث فيما بينها في النهاية. القضية الأساسية ليست ما إذا كنا سنُفعّل التعاون أم لا، بل ما إذا كنا سنبني ذلك التعاون **على بنية تدعمها السياسات والتحقق والتدقيق**.

## المصادر

- Dorsa Rohani, "We made Claude Code multiplayer!" (X, 2026-07-08): [https://x.com/dorsa_rohani/status/2074963064231952832](https://x.com/dorsa_rohani/status/2074963064231952832)
- Claude Code (مستودع Anthropic الرسمي): [https://github.com/anthropics/claude-code](https://github.com/anthropics/claude-code)
- oh-my-claudecode (تنسيق متعدد العوامل يضع الفريق أولاً): [https://github.com/yeachan-heo/oh-my-claudecode](https://github.com/yeachan-heo/oh-my-claudecode)
- claude_codex_bridge (مساحة عمل CLI متعددة العوامل): [https://github.com/SeemSeam/claude_codex_bridge](https://github.com/SeemSeam/claude_codex_bridge)
