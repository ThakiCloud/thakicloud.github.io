---
title: "Paxis: تشغيل فريق كامل من موظفي الذكاء الاصطناعي دون كتابة أي كود"
excerpt: "كما تعامل السحابة التقليدية الخوادم موارد من الدرجة الأولى، يعامل Paxis مهارات الوكلاء وأدواتهم وسياساتهم وسجلات التدقيق باعتبارها موارد من الدرجة الأولى. 849 مهارة تُحمَّل تلقائيًا، وCostRouter يختار النموذج المناسب لكل مهمة، وقدرات تتحسّن مع الاستخدام. نشارك PoC عاملًا مع كود حقيقي."
seo_title: "Paxis Agent-Native Cloud: الحوكمة وCostRouter والمهارات المتطورة - Thaki Cloud"
seo_description: "ThakiCloud Paxis هو Agent-Native Cloud لتشغيل وكلاء الذكاء الاصطناعي المستقلة بأمان. يضمّ حوكمة استقلالية L0-L3، وتحسين تكاليف CostRouter متعدد النماذج، ومحرك معرفة HKE مبني على Git، وحزمة 849 مهارة. مع شرح بكود حقيقي."
lang: ar
canonical_url: https://thakicloud.com/tech-blog/ar/agentops/praxis-agent-native-cloud/
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - agent-native-cloud
  - praxis
  - agentops
  - llm-cost-optimization
  - governance
  - rag
  - knowledge-engine
  - multi-agent
  - skill-harness
  - thakicloud
header:
  teaser: /assets/images/praxis-architecture-hero.webp
toc: true
toc_sticky: true
categories:
  - agentops
published: false
---

![البنية الطبقية لـ Paxis: البنية التحتية السحابية في القاعدة، ثم Paxis Core فوقها، ثم طبقة قدرات 849 مهارة و14 وكيل نطاق في الأعلى]({{ '/assets/images/praxis-architecture-hero.webp' | relative_url }})

## السؤال التالي في السحابة: كيف تُشغّل الوكلاء؟

على مدى العقد الماضي، تحددت أجيال السحابة بما تديره. في البداية كانت الخوادم والبنية التحتية، ثم البيانات والأنابيب. أما السؤال الذي يطفو على السطح في بيئات الإنتاج الآن فهو مختلف. في اللحظة التي تبدأ فيها تشغيل عدة وكلاء ذكاء اصطناعي معًا، تفقد الرؤية على مَن فعل ماذا، وتخرج التكاليف عن التوقعات، ولا تُستوفى متطلبات الأمان والتدقيق، ويُعيد كل فريق بناء الشيء ذاته باستقلالية تامة.

Paxis يستهدف هذا الفراغ. تعامَلت السحابة التقليدية مع الحوسبة وقواعد البيانات والشبكات باعتبارها موارد من الدرجة الأولى. Paxis يعامل قدرات وكلاء الذكاء الاصطناعي (Skills) وأدواتهم (Tools) وسياساتهم (Policies) وسجلات التدقيق (Audit) باعتبارها موارد من الدرجة الأولى. يستطيع العملاء توظيف "فريق كامل من موظفي الذكاء الاصطناعي" وإدارته ومراجعته دون كتابة أي كود. نُسمّي هذه الفئة Agent-Native Cloud.

![السحابة التقليدية تُدير Compute وDB وNetwork كموارد درجة أولى؛ Paxis يُدير Skills وTools وPolicies وAudit Logs]({{ '/assets/images/praxis-cloud-analogy.webp' | relative_url }})

هذه المقالة ليست شعارات تسويقية، بل شرح لـ PoC عامل مع كود حقيقي. كل رقم أدناه تحقّق من خلال خادم فعلي (`localhost:8080`).

## الوحدات الأساسية: ثلاثة أشياء للتذكر

الواجهة الخلفية لـ Paxis مكتوبة بـ Go. تُقرأ البنية بوضوح على ثلاث طبقات: البنية التحتية في الأسفل، ثم الـ core فوقها، ثم طبقة القدرات في الأعلى.

- بيئة تشغيل الوكيل (Native Loop): نقطة دخول التنفيذ الوحيدة التي تجتمع فيها حلقة ReAct وتنفيذ الأدوات وتتبع التكاليف وبوابات الاستقلالية.
- حزمة المهارات (Skill Harness): تحمّل المهارات تلقائيًا عند الإقلاع وتختار المهارات ذات الصلة باستخدام TF-IDF.
- محرك المعرفة الهجين (HKE): طبقة معرفة مبنية على Git لاستيعاب وكلاء الفريق والاستعلام منها.
- بوابة LLM: تجرّد مزوّدي النماذج المتعددين وتعمل كمصدر وحيد للحقيقة في توجيه التكاليف.
- الأمان والسياسة: مصفوفة الاستقلالية (L0-L3) وأمان المطالبات والتدقيق الكامل للإجراءات.
- الذاكرة: ذاكرة الجلسة والبحث الدلالي pgvector وتتبع مسار البيانات (provenance).

يرتكز كل ذلك على تنفيذ في بيئة معزولة (sandbox) وتنسيق متعدد الوكلاء. إن احتجت لتذكّر ثلاثة أشياء فقط: بيئة التشغيل، وحزمة المهارات، ومحرك المعرفة.

## إضافة قدرة = ملف واحد

تكلفة إضافة قدرة جديدة في Paxis هي صفر عمليات نشر. ضَع ملف `skills/<domain>/<name>/SKILL.md` واحدًا ويفحص الخادم الدليل تلقائيًا ويُضيفه فورًا.

```markdown
---
name: competitor-digest
description: >-
  Collects and summarizes competitor news. Use when tracking competitor activity or news digests.
allowed-tools: [web_search, web_fetch]
---
# Competitor Digest
## Instructions
Gather the latest articles from the specified sources and distill the key points into bullets.
```

احفظ الملف ويظهر في `GET /api/v1/skills` دون إعادة تشغيل الخادم. في الـ PoC، حُمِّلت 849 مهارة تلقائيًا عند الإقلاع إلى جانب 14 وكيل نطاق افتراضي. يعني مبدأ "المهارات السميكة، الحزمة النحيفة" أن القدرات تتراكم كملفات فيما تبقى الحزمة خفيفة.

إنشاء مهمة متكررة بلغة طبيعية يتبع النمط ذاته.

```bash
curl -X POST http://localhost:8080/api/v1/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"team_id":"dev-team","agent_id":"research-bot",
       "schedule":{"type":"cron","expr":"0 9 * * *"},
       "skill":"competitor-digest","params":{"topN":10}}'
```

اكتب في المحادثة "لخّص لي أبرز 10 أخبار منافسين كل صباح عند الساعة 9" ويُترجم النموذج ذلك إلى هذا الـ cron والمهارة والمعاملات ويسجّلها. صفر أسطر من الكود.

## CostRouter: الكود يختار النموذج لكل مهمة

مشكلة "انفجار تكاليف الذكاء الاصطناعي" لها سبب واحد في الغالب: استخدام نموذج مكلف لكل شيء. Paxis يقسّم المهمة إلى ثلاث مراحل -- Planner وExecutor وSynthesizer -- ويُسند إلى كل مرحلة النموذج المناسب تلقائيًا.

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
<div class="d3-arch" data-arch-root id="20praxisagentnativecloud-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 465, "height": 640, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q", "x": 123, "y": 24, "w": 120, "h": 46, "title": "Task Request"}, {"id": "P", "x": 123, "y": 148, "w": 120, "h": 46, "title": "Planner"}, {"id": "E", "x": 214, "y": 286, "w": 120, "h": 46, "title": "Executor"}, {"id": "S", "x": 309, "y": 424, "w": 120, "h": 46, "title": "Synthesizer"}, {"id": "H", "x": 24, "y": 286, "w": 135, "h": 46, "title": "Haiku · economy"}, {"id": "SO", "x": 105, "y": 424, "w": 149, "h": 46, "title": "Sonnet · standard"}, {"id": "O", "x": 305, "y": 562, "w": 128, "h": 46, "title": "Opus · premium"}], "edges": [{"src": "Q", "dst": "P", "kind": "data", "line": [183, 70, 183, 148]}, {"src": "P", "dst": "E", "kind": "data", "curve": [[213, 194], [274, 240], [274, 240], [274, 286]]}, {"src": "E", "dst": "S", "kind": "data", "curve": [[306, 332], [369, 378], [369, 378], [369, 424]]}, {"src": "P", "dst": "H", "kind": "event", "label": "most tasks", "curve": [[152, 194], [92, 240], [92, 240], [92, 286]], "off": "50%"}, {"src": "E", "dst": "SO", "kind": "event", "label": "standard", "curve": [[242, 332], [179, 378], [179, 378], [179, 424]], "off": "50%"}, {"src": "S", "dst": "O", "kind": "event", "label": "critical phases only", "line": [369, 470, 369, 562], "lx": 369, "ly": 512}]});
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
      const container = document.getElementById('20praxisagentnativecloud-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20praxisagentnativecloud-1';
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

تُدار طبقات النماذج من مصدر وحيد هو `models.yaml`. الفارق في السعر لكل مليون رمز مخرجات ملحوظ.

| الطبقة | النموذج | السعر $/1M | الاستخدام |
|---|---|---|---|
| economy | Haiku 4.5 | $4 | غالبية المهام |
| standard | Sonnet 4.6 | $15 | الأحمال المتوازنة |
| strong | GPT-4o / Kimi | متوسط | التعزيز |
| premium | Opus 4.8 | $25 | المراحل الحرجة فقط (opt-in) |

الفكرة الجوهرية أن معظم المهام تكفيها Haiku الأرخص، ويُستخدم Opus فقط في المراحل الحرجة حقًا. تُفرض حدود ميزانية لكل عملية تنفيذ مما يجعل التكاليف قابلة للتنبؤ وظاهرة في Command Center يوميًا وأسبوعيًا. ومع تراكم الاستخدام، يتعلم التوجيه أي المهام يكفيها نموذج أرخص، فتنخفض تكلفة تنفيذ المهام المتكررة تدريجيًا.

## ما الذي يُميّز HKE عن RAG التقليدي؟

RAG التقليدي هو في جوهره استرجاع مؤقت يُضاف عند الاستعلام. محرك المعرفة الهجين (HKE) في Paxis يعامل المعرفة كأصل يتراكم.

| RAG التقليدي | Paxis HKE |
|---|---|
| استرجاع منفرد عديم الحالة | ويكي دائم مبني على Git (يتراكم) |
| لا حدود نطاق | عزل نطاق لكل وكيل |
| لا تتبع لمصدر البيانات | سجلات provenance (مَن، متى، أي مصدر) |
| تكلفة غير محكومة | tool-budget يقطع النتائج الكبيرة أو يؤجّل الجلب |

المستندات أو الكود المُحمَّل يمر بمعالجة ويتطور إلى رسم بياني للمعرفة، وتستشهد الإجابات بمصادرها. ويكي كل فريق معزول تمامًا بحيث لا تظهر معرفة فريق لفريق آخر. تحت ذلك تقبع ذاكرة من أربع طبقات -- ذاكرة الجلسة والبحث الدلالي pgvector وويكي الفريق وسجلات provenance -- فيتراكم السياق كلما تكررت المحادثات.

## وكلاء تحت السيطرة: الحوكمة كميزة تنافسية

العروض التوضيحية البراقة كثيرة، لكن ضعف الحوكمة يحول دون دخول الوكلاء إلى بيئات المؤسسات. Paxis يجعل السيطرة هي الإعداد الافتراضي.

- مصفوفة الاستقلالية L0-L3: بوابات تنفيذ قبل تشغيل المهمة، بناءً على مستوى المخاطر والصلاحيات.
- أمان المطالبات وإزالة المعلومات الشخصية.
- سلسلة تدقيق كاملة للإجراءات: كل إجراء مسجّل -- مَن، ومتى، وماذا.
- عزل متعدد المستأجرين بين الفرق.

فوق ذلك، صُمّم النظام لتحسين القدرات بالاستخدام. تعمل حلقة العناية بالترتيب التالي: Propose ثم Distill ثم Patch، وسلّم ثقة المهارة يرفع المهارات من `system` إلى `learned` إلى `promoted` بناءً على الاستخدام. هذه الحلقة التحسينية الذاتية تعمل جزئيًا وهي قيد التطوير -- هذا PoC صادق. وبلا مبالغة، الاتجاه والهيكل موجودان بالفعل في الكود.

## ثلاثة سيناريوهات تجريبية لفريق المبيعات

قوة Paxis أن الفريق الداخلي الذي يستخدمه هو نفسه الذي يعرضه على العملاء.

1. مساعد يعمل أثناء نومك: شغّل Proactive مرة واحدة وسيصل إحاطة الصباح التالي إلى Slack تلقائيًا.
2. أوكِل العمل بالكلام: جملة واحدة بلغة طبيعية تُسجَّل كـ cron ومهارة.
3. المستندات تصبح معرفة الفريق: اسحب ملف PDF لعرض ما ويستطيع الفريق بأكمله طرح الأسئلة في المحادثة مع الاستشهاد بالمصادر.

كل هذا يُدار من شاشة واحدة هي Command Center، تشمل الجداول الزمنية والتكاليف والتعاون والتدقيق.

## منظور ThakiCloud: لماذا هذا الاتجاه؟

منصة الذكاء الاصطناعي في ThakiCloud تُشغّل بيئة متعددة المستأجرين على Kubernetes، وتجدول GPUs باستخدام Kueue وتخدّم النماذج عبر vLLM. Paxis هو مستوى التحكم فوق ذلك لتشغيل الوكلاء بأمان.

ثلاثة أسباب تجعل هذا التوليف ذا معنى. أولًا، الحوكمة -- استقلالية L0-L3 والتدقيق الكامل وعزل الفرق -- مدمجة بشكل أصيل، مما يعني أن بيئات القطاع العام والمالي والمؤسسات الكبرى التي تشترط الأمان والتدقيق وفصل البيانات تحصل عليها خارج الصندوق. ثانيًا، التصميم يفترض النشر المحلي (on-premises) والاستضافة الذاتية (self-hosting)، لذا تستطيع المؤسسات التي لا تستطيع إرسال البيانات خارج نطاقها تشغيله. ثالثًا، يُتيح اختيار CostRouter للنموذج لكل مهمة مع حدود الميزانية التشغيل مع إبقاء تكاليف GPU وواجهات برمجة التطبيقات تحت السيطرة. ميزة التكلفة على مستوى التخديم تتحول مباشرة إلى ميزة تنافسية للمنتج.

Paxis في مرحلة PoC حاليًا. النواة -- المحادثة والمهارات والجدولة وCommand Center وتوجيه التكاليف وHKE -- تعمل. بعض الميزات المتقدمة على خارطة الطريق. "جاهز للعرض التجريبي اليوم، ابدأ بسير عمل واحد" هي رسالتنا الصادقة.

## للمزيد

- المصدر: [github.com/ThakiCloud/praxis](https://github.com/ThakiCloud/praxis)
- مجموعة شرائح العرض التنفيذي (33 شريحة مع ملاحظات العرض): [Google Slides](https://docs.google.com/presentation/d/11E5ixfWgV6uY-akebEZ--Kwp1JmRQJG1OpPaChbJLmc/edit)

نبحث عن زملاء للبناء معنا وعملاء للتجربة التجريبية. نعزم على تعريف فئة Agent-Native Cloud قبل الجميع.
