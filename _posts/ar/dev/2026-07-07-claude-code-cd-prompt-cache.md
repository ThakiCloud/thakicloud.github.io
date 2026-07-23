---
title: "أمر /cd في Claude Code: كيف تنتقل بين المجلدات دون إعادة تشغيل الجلسة وتحافظ على ذاكرة التخزين المؤقت للـ prompt"
excerpt: "في المستودعات أحادية الجذر (monorepo)، عندما تتنقل بين مجلد مكتبة ومجلد خدمة تستهلكها، تؤدي إعادة تشغيل الجلسة إلى فقدان سياق المحادثة وإبطال ذاكرة التخزين المؤقت للـ prompt معاً. أمر /cd الذي أُدرج في Claude Code v2.1.169 ينقل الجلسة الجارية إلى مجلد آخر مع الحفاظ على الذاكرة المؤقتة كما هي. استناداً إلى الفارق بين سعر قراءة الذاكرة المؤقتة (0.1x) وسعر كتابتها (1.25x)، نوضح لماذا يغيّر هذا السطر الواحد تكلفة تشغيل وكيل البرمجة بشكل كبير، ونربط ذلك بوكيل البرمجة Paxis وتكلفة الخدمة في ai-platform لدى Thaki Cloud."
seo_title: "أمر /cd في Claude Code والحفاظ على ذاكرة التخزين المؤقت للـ prompt عند تغيير المجلد (2026) - Thaki Cloud"
seo_description: "أمر /cd في Claude Code v2.1.169 ينقل مجلد العمل دون إعادة تشغيل الجلسة، مع الحفاظ على ذاكرة التخزين المؤقت للـ prompt. نحسب نموذج التكلفة استناداً إلى سعر القراءة 0.1x وسعر الكتابة 1.25x، ونشرح سبب عدم إعادة كتابة الـ CLAUDE.md لسياق النظام (system prompt)، إضافة إلى منظور تكلفة وكيل البرمجة Paxis والخدمة متعددة المستأجرين في ai-platform."
date: 2026-07-07
lang: ar
last_modified_at: 2026-07-07
tags:
  - claude-code
  - prompt-caching
  - ai-agent
  - developer-tools
  - cost-optimization
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/claude-code-cd-prompt-cache/"
reading_time: true
categories:
  - dev
---

عندما تعمل لفترة طويلة مع وكيل برمجة (coding agent)، تأتي حتماً لحظة تحتاج فيها إلى الانتقال بين المجلدات. المثال النموذجي هو العمل في مستودع أحادي الجذر (monorepo): تعدّل وحدة أساسية في مكتبة مشتركة، ثم تنتقل إلى الخدمة التي تستخدم هذه الوحدة للتحقق من التكامل. حتى الآن كان عليك في هذه الحالة إغلاق الجلسة وفتح جلسة جديدة في المجلد الآخر، أو تفريغ السياق باستخدام /clear. والنتيجة ليست فقط ضياع سياق المحادثة الذي بنيته حتى تلك اللحظة، بل تكلفة خفية إضافية لا تظهر بسهولة للعين: إبطال ذاكرة التخزين المؤقت للـ prompt بالكامل، بحيث يُحاسَب الطلب التالي بسعر كتابة الذاكرة المؤقتة من جديد. أمر /cd الذي أُدرج بهدوء في Claude Code v2.1.169 يمنع هاتين الخسارتين في آن واحد. يوضّح هذا المقال، استناداً إلى الأسعار المُعلنة في الوثائق الرسمية، لماذا لا يُعد هذا السطر الواحد مجرد ميزة راحة، بل مسألة تتعلق بتكلفة تشغيل وكيل البرمجة.

![رسم تجريدي لتدفق بيانات متصل ينقسم إلى مسارين، أحدهما يعيد بناء الكتل بتكلفة عالية والآخر يترك الشبكة تتدفق كما هي]({{ '/assets/images/claude-code-cd-prompt-cache-hero.png' | relative_url }})

## نظرة عامة

يقوم الأمر `/cd <المسار>` بنقل جلسة Claude Code الجارية إلى مجلد عمل آخر. لا تُعاد الجلسة من الصفر، لذا ينتقل سجل المحادثة، والنموذج المختار، وإعدادات الأذونات، كلها كما هي إلى المجلد الجديد. حتى هذه النقطة، يبدو الأمر ميزة راحة معتادة. لكن الجوهر الحقيقي يكمن فيما بعد: لا يكسر /cd ذاكرة التخزين المؤقت للـ prompt. الرسالة التي تُرسل مباشرة بعد الانتقال إلى المجلد الجديد تُحاسَب بسعر قراءة الذاكرة المؤقتة، وليس بسعر كتابتها.

سبب أهمية هذا الفارق يكمن في سعر الذاكرة المؤقتة نفسه. وفقاً للأسعار التي أعلنتها Anthropic لتخزين الـ prompt مؤقتاً، فإن قراءة الذاكرة المؤقتة تبلغ نحو 10 بالمئة من سعر الإدخال القياسي، أي 0.1x. في المقابل، تُضاف علاوة تبلغ 1.25x عند الكتابة الجديدة في الذاكرة المؤقتة. عند إعادة تشغيل الجلسة، يجب إعادة كتابة سياق النظام (system prompt) وتعريفات الأدوات وملف `CLAUDE.md` الخاص بالمشروع، جميعها من جديد في ذاكرة مؤقتة جديدة. وكلما كان المشروع أكبر، بلغت هذه البادئة (prefix) عشرات الآلاف من الرموز (tokens). أمر /cd لا يعيد كتابة هذه البادئة، بل يقرأها كما هي ويعيد استخدامها.

تشغّل Thaki Cloud في بيئة متعددة المستأجرين وكلاء ومهام دفعية لعملاء متعددين على نفس البنية التحتية. في مثل هذه البيئة، اقتصاديات الرموز تعني مباشرة تكلفة الخدمة. إذا أعاد وكيل البرمجة تخزين البادئة مؤقتاً في كل مرة يتنقل فيها بين المجلدات، فإن هذه التكلفة تتراكم بما يتناسب مع عدد الجلسات وعدد مرات التنقل. إجراء واحد مثل /cd يحافظ على الذاكرة المؤقتة يمكن أن يؤدي في التشغيل واسع النطاق إلى وفورات لا يُستهان بها. لذا فمن الأدق النظر إلى هذه الميزة على أنها مسألة "نظافة تكلفة" وليست مجرد "اختصار مريح".

## ما هي هذه التقنية

لفهم قيمة /cd، لا بد أولاً من فهم كيفية عمل ذاكرة التخزين المؤقت للـ prompt. يقوم Claude Code تلقائياً بتخزين سياق النظام وتعريفات الأدوات وملف `CLAUDE.md` مؤقتاً في كل دورة (turn)، دون الحاجة إلى أي إعداد إضافي. تشغل هذه البادئة المخزّنة مؤقتاً بداية المحادثة، وتُلحَق بعدها كل رسالة جديدة. إذا ظلت الذاكرة المؤقتة حيّة، تُحاسَب هذه البادئة بسعر القراءة فقط. أما إذا انكسرت الذاكرة المؤقتة، فيجب إعادة كتابة البادئة بأكملها.

عند إعادة تشغيل الجلسة أو تفريغ السياق باستخدام /clear، تُبطَل الذاكرة المؤقتة. لكن الفخّ الكامن في عملية الانتقال بين المجلدات هو أن المجلد الجديد يحتوي غالباً على ملف `CLAUDE.md` مختلف. منطقياً، يبدو أن تغيير محتوى `CLAUDE.md` الذي يدخل في سياق النظام يجب أن يكسر الذاكرة المؤقتة. وهنا يكمن الجزء الذكي في /cd. فبدلاً من إعادة كتابة `CLAUDE.md` الخاص بالمجلد الوجهة داخل سياق النظام، يُضيفه كرسالة تالية في المحادثة. وبما أن سياق النظام لا يُعاد كتابته، تبقى البادئة المخزّنة مؤقتاً كما هي، ويُعامَل ملف `CLAUDE.md` الجديد باعتباره مجرد رسالة مستخدم مُلحَقة في النهاية. هذه هي الطريقة التي تحافظ بها الذاكرة المؤقتة على نفسها بينما تعكس قواعد المجلد الجديد في الوقت نفسه.

يوضّح المخطط التالي كيف يتعامل المساران مع الذاكرة المؤقتة بشكل مختلف عند الانتقال بين المجلدات.

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
<div class="d3-arch" data-arch-root id="7claudecodecdpromptcache-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 497, "height": 762, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 131, "y": 24, "w": 212, "h": 78, "title": ["جلسة جارية في", "المجلد A", "(بادئة مخزّنة مؤقتاً نشطة)"]}, {"id": "B", "x": 168, "y": 180, "w": 139, "h": 68, "title": ["حاجة للانتقال", "إلى المجلد B"]}, {"id": "C", "x": 263, "y": 340, "w": 191, "h": 78, "title": ["إبطال ذاكرة سياق النظام", "والأدوات وملف", "CLAUDE.md المؤقتة"]}, {"id": "D", "x": 253, "y": 496, "w": 212, "h": 78, "title": ["إعادة كتابة البادئة", "بأكملها في الذاكرة المؤقتة", "(سعر 1.25x)"]}, {"id": "E", "x": 277, "y": 668, "w": 163, "h": 46, "title": "فقدان سياق المحادثة"}, {"id": "F", "x": 24, "y": 340, "w": 184, "h": 78, "title": ["الحفاظ على سياق النظام", "وإلحاق CLAUDE.md", "الجديد كرسالة"]}, {"id": "G", "x": 38, "y": 496, "w": 156, "h": 78, "title": ["قراءة البادئة", "من الذاكرة المؤقتة", "(سعر 0.1x)"]}, {"id": "H", "x": 35, "y": 652, "w": 163, "h": 78, "title": ["الحفاظ على المحادثة", "والنموذج والأذونات", "كما هي"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [237, 102, 237, 180]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"إعادة تشغيل أو /clear\"", "curve": [[289, 248], [359, 294], [359, 294], [359, 340]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "line": [359, 418, 359, 496]}, {"src": "D", "dst": "E", "kind": "data", "line": [359, 574, 359, 668]}, {"src": "B", "dst": "F", "kind": "data", "label": "\"مسار /cd\"", "curve": [[186, 248], [116, 294], [116, 294], [116, 340]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [116, 418, 116, 496]}, {"src": "G", "dst": "H", "kind": "data", "line": [116, 574, 116, 652]}]});
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
      const container = document.getElementById('7claudecodecdpromptcache-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '7claudecodecdpromptcache-1';
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

جوهر هذا المخطط أن المسار الأيمن لا يمس سياق النظام إطلاقاً. أما المسار الأيسر فيعيد كتابة البادئة وفي الوقت نفسه يفقد كل ما تراكم من محادثة حتى تلك اللحظة. الوجهة واحدة، لكن التكلفة المدفوعة مختلفة تماماً.

سبب بقاء الذاكرة المؤقتة سليمة عند الإلحاق في النهاية هو أن تخزين الـ prompt مؤقتاً يعمل على مستوى البادئة. تعيد الذاكرة المؤقتة استخدام الجزء الذي يظل مطابقاً لبداية المحادثة، أي جزء البادئة. فإذا تغيّر حرف واحد في البادئة، يجب إعادة حساب كل ما يليها من تلك النقطة فصاعداً. لذلك فإن وضع محتوى يتغيّر باستمرار في البداية يقلّل من معدل إصابة الذاكرة المؤقتة (cache hit rate)، بينما وضع محتوى مستقر في البداية وإلحاق ما يتغيّر في النهاية يرفع هذا المعدل. تصميم /cd الذي يُلحق ملف `CLAUDE.md` الجديد كرسالة في نهاية المحادثة بدلاً من سياق النظام هو بالضبط التزام بهذا المبدأ: عدم لمس البادئة المخزّنة مؤقتاً، واستيعاب التغيير خارج حدود الذاكرة المؤقتة.

## التثبيت والدمج

لا يحتاج /cd إلى أي تثبيت منفصل. يمكن استخدامه مباشرة اعتباراً من Claude Code v2.1.169 فما فوق. صدر هذا الأمر في 8 يونيو 2026. طريقة الاستخدام بسيطة.

```bash
# الانتقال إلى مجلد آخر داخل الجلسة
/cd ../consuming-service

# يمكن أيضاً استخدام مسار مطلق
/cd /Users/me/repo/apps/web

# مسار نسبي إلى المجلد الرئيسي
/cd ~/repo/packages/core
```

عند تنفيذ الأمر، يقوم Claude Code بتحديث مجلد العمل، ويقرأ ملف `CLAUDE.md` الموجود في الموقع الجديد ويُلحقه بالمحادثة، ثم يواصل العمل الجاري. وبما أن سجل المحادثة والقرارات المتخذة حتى تلك اللحظة تبقى محفوظة، فإن طلباً مثل "تحقق من أن الواجهة تستخدم الواجهة البرمجية التي عدّلتها للتو في الوحدة الأساسية" ينساب بشكل طبيعي.

لنأخذ مثالاً محدداً. تُجمّع بيئة عمل منصة Thaki Cloud سبعة مستودعات منتجات، منها الواجهة الخلفية بلغة Go، والواجهة الأمامية، ونشر GitOps، وشبكة الوصل متعددة النطاقات (multi-cluster mesh)، وذلك عبر وحدات فرعية (git submodules). إن تعديل مخطط استجابة واجهة برمجية خلفية ثم التحقق من ظهور الشاشة بشكل صحيح في الواجهة الأمامية التي تستهلك هذا المخطط هو عمل يومي في هذا الهيكل. في الطريقة القديمة، كان يجب إغلاق جلسة الواجهة الخلفية وفتح جلسة جديدة في مجلد الواجهة الأمامية، ثم إعادة شرح ما تم تغييره ولماذا في الجلسة الجديدة. مع /cd لا ينقطع سير العمل.

```bash
# جارٍ تعديل المخطط في الوحدة الفرعية الخلفية
# ...

# الانتقال إلى الواجهة الأمامية التي تستهلك هذا المخطط (مع الحفاظ على السياق والذاكرة المؤقتة)
/cd ../ai-suite/apps/web

# السؤال مباشرة: هل تُشير هذه الشاشة إلى اسم الحقل الذي تم تعديله للتو؟
```

فور الانتقال، يُلحَق ملف `CLAUDE.md` الخاص بمجلد الواجهة الأمامية بالمحادثة، فتنعكس فوراً قواعد ذلك المستودع (مثل حدود FSD أو استخدام رموز TDS). وفي الوقت نفسه، يبقى السياق المتراكم من العمل على الواجهة الخلفية، أي أي حقل تم تعديله ولماذا، حياً، مما يسمح بالانتقال مباشرة إلى التحقق.

لفهم اقتصاديات الذاكرة المؤقتة، لا بد من الاطلاع على جدول الأسعار. الجدول التالي يلخّص أسعار تخزين الـ prompt مؤقتاً التي أعلنتها Anthropic.

| البند | السعر مقارنة بالإدخال القياسي | الوصف |
|---|---|---|
| قراءة الذاكرة المؤقتة | 0.1x | إعادة استخدام البادئة المخزّنة مؤقتاً، خصم 90 بالمئة |
| كتابة الذاكرة المؤقتة (مدة صلاحية 5 دقائق) | 1.25x | تسجيل بادئة جديدة في الذاكرة المؤقتة، تُستَرد التكلفة عند أول قراءة |
| كتابة الذاكرة المؤقتة (مدة صلاحية ساعة واحدة) | 2.0x | عند تفعيل `ENABLE_PROMPT_CACHING_1H=1` |
| إدخال دون استخدام ذاكرة مؤقتة | 1.0x | السعر الأساسي |

هناك سياق واحد يستحق الانتباه. خفّضت Anthropic بهدوء في مارس 2026 مدة صلاحية الذاكرة المؤقتة الافتراضية (TTL) من 60 دقيقة إلى 5 دقائق. إذا لم يصل طلب تالٍ خلال 5 دقائق، تنتهي صلاحية الذاكرة المؤقتة وتُدفَع تكلفة الكتابة من جديد. إذا كنت تعمل بفواصل زمنية طويلة، يمكن التفكير في تفعيل خيار الساعة الواحدة، لكن علاوة الكتابة ترتفع إلى 2.0x، لذا يجب موازنة المقايضة. أمر /cd هو ما يحافظ على الذاكرة المؤقتة حيّة عند استمرار الجلسة ضمن هذه المدة، لذا أصبح أكثر أهمية في عصر مدة الصلاحية القصيرة.

## نتائج التجربة الفعلية

بصراحة، /cd أمر تفاعلي يُكتب بالشرطة المائلة، ولذلك لم نتمكن في البيئة غير التفاعلية (headless) التي كُتب فيها هذا المقال من تشغيل جلسة فعلية وإجراء قياس أداء تفاعلي. لذا، بدلاً من اختلاق أرقام قياس، نعرض نموذج تكلفة يمكن حسابه اعتماداً فقط على الأسعار المُعلَنة. الأرقام أدناه ليست قيماً مقيسة، بل حسابات مبنية على الأسعار الرسمية في الوثائق، ونوضّح ذلك بجلاء.

لنقارن المسارين من حيث كيفية احتساب البادئة المخزّنة مؤقتاً في أول طلب مباشرة بعد الانتقال بين المجلدات. في مسار إعادة التشغيل أو /clear، تُسجَّل البادئة من جديد بسعر كتابة الذاكرة المؤقتة (1.25x). أما في مسار /cd، فتُعاد استخدام البادئة نفسها بسعر قراءة الذاكرة المؤقتة (0.1x). إذا افترضنا أن حجم البادئة متساوٍ في الحالتين، فإن نسبة التكلفة المدفوعة مقابل إعادة احتساب البادئة مباشرة بعد الانتقال هي 1.25 مقسومة على 0.1، أي 12.5 مرة. بعبارة أخرى، مسار إعادة التشغيل أغلى بنحو 12.5 مرة من مسار /cd من حيث إعادة احتساب البادئة.

![مقارنة تكلفة البادئة المخزّنة مؤقتاً عند الانتقال بين المجلدات: مسار إعادة التشغيل/إعادة التخزين المؤقت يُحاسَب بسعر كتابة 1.25x، بينما مسار /cd يُحاسَب بسعر قراءة 0.1x، بفارق نحو 12.5 مرة وفقاً للأسعار الرسمية في الوثائق]({{ '/assets/images/claude-code-cd-prompt-cache-results.png' | relative_url }})

هذه النسبة تصح بغضّ النظر عن العدد المطلق لرموز البادئة. غير أن قيمة الوفورات المطلقة تزداد كلما كانت البادئة أكبر. في المشاريع الكبيرة، من الشائع[تقديري] أن تصل البادئة المكوّنة من سياق النظام وتعريفات الأدوات وملف `CLAUDE.md` الضخم إلى عشرات الآلاف من الرموز، وفي مثل هذه الجلسات، إذا تنقّل المستخدم بين المجلدات عدة مرات يومياً، تتراكم تكلفة إعادة التخزين المؤقت بسرعة. أمر /cd يخفّض علاوة الـ 12.5 مرة التي تُضاف عند كل انتقال إلى سعر القراءة فقط.

نقطة أخرى تستحق الإشارة إليها هي أن ما يحافظ عليه /cd ليس التكلفة فقط. سياق المحادثة الذي يُفقَد في مسار إعادة التشغيل هو تكلفة يصعب ترجمتها إلى رموز. فإذا اضطررت لإعادة شرح نيّة الكود الذي عدّلته للتو، والفرضيات التي وضعتها سابقاً، والمقاربات التي استبعدتها بالفعل، فإن ذلك يستهلك وقتاً بشرياً ورموزاً إضافية معاً. يزيل /cd هذه التكلفة المرتبطة بإعادة الشرح أيضاً.

## دلالات التطبيق في منتجات Thaki Cloud

لهذه الميزة أهمية من منظور منتجَي Thaki Cloud كليهما.

من منظور Paxis، يلامس /cd بدقة مسألة نظافة جلسات وكيل البرمجة. Paxis هو السحابة الأصلية للوكلاء (Agent-Native Cloud) لدى Thaki Cloud، حيث تُعامَل المهارات (skills) والأدوات والسياسات وسجلات التدقيق كموارد أساسية من الدرجة الأولى، ويُشغَّل الوكيل داخل بيئة معزولة (sandbox). التنقل بين مستودعات ووحدات فرعية متعددة أثناء عمل وكيل البرمجة هو سيناريو شائع في Paxis. وإذا أعاد الوكيل تشغيل الجلسة عند كل انتقال، فإن ذلك يعني إعادة احتساب سياق مهارات وسياسات ضخم في كل مرة. الأسلوب الذي يحافظ على البادئة ويُلحق قواعد المجلد كرسالة فقط، كما يفعل /cd، ينسجم جيداً مع نموذج تنسيق (orchestration) Paxis الذي يبدّل مسار العمل فقط مع الحفاظ على اختيار المهارات وبوابات السياسات. فكرة عدم إعادة كتابة سياق النظام وإلحاق السياق في النهاية بدلاً من ذلك هي بعينها المبدأ الذي يُدار به طبقة القواعد المُحمَّلة باستمرار من منظور استقرار الذاكرة المؤقتة.

ومن منظور ai-platform، تُعد اقتصاديات الذاكرة المؤقتة تكلفة الخدمة متعددة المستأجرين مباشرة. تُشغّل منصة ai-platform لدى Thaki Cloud أحمال استدلال (inference) لعملاء متعددين فوق جدولة GPU قائمة على K8s وKueue. تخزين الـ prompt مؤقتاً هو رافعة أساسية لخفض تكلفة الإدخال عبر إعادة استخدام البادئات المتكررة، والمبدأ الذي يُظهره /cd، أي إضافة السياق في نهاية المحادثة وليس في بدايتها كي لا تنكسر الذاكرة المؤقتة، يُطبَّق كما هو في مكدّس الخدمة الخاص بالمنصة. تصميم بنية الـ prompt بحيث تُقلَّل نقاط إبطال الذاكرة المؤقتة يمنح تنافسية عند تكلفة خدمة منخفضة. والعدستان تُكمّلان إحداهما الأخرى: تكلفة الخدمة المنخفضة (ai-platform) تصنع اقتصاديات الوكيل (Paxis)، وسلوك الوكيل الذي يحافظ على الذاكرة المؤقتة (Paxis) يخفّض بدوره حمل البنية التحتية.

## القيود والاعتراضات

/cd ليس حلاً سحرياً. أولاً، الحفاظ على الذاكرة المؤقتة له معنى فقط ضمن مدة الصلاحية البالغة 5 دقائق. إذا تركت المجلد بعد الانتقال إليه لفترة طويلة دون نشاط، تنتهي صلاحية الذاكرة المؤقتة، وسواء استخدمت /cd أم لا، سيُحاسَب الطلب التالي بتكلفة الكتابة. ونظراً لقصر مدة الصلاحية، تكون وفورات /cd في أعلى مستوياتها في سير العمل المتواصل، بينما تتضاءل فائدتها في العمل المتقطّع.

ثانياً، هناك فخّ دقيق في أسلوب إلحاق ملف `CLAUDE.md` كرسالة بدلاً من إدراجه في سياق النظام. إذا عدّلت ملف `CLAUDE.md` الأصلي للمشروع أثناء الجلسة، فإن هذا التعديل لا يكسر الذاكرة المؤقتة، لكنه في المقابل لا يُطبَّق حتى تنفّذ /clear أو /compact أو تُعيد تشغيل الجلسة. أي قد ينشأ وضع تُغيَّر فيه القواعد دون أن تعكسه الجلسة، لذا يجب تحديث الجلسة عمداً بعد تغيير القواعد.

ثالثاً، نسبة توفير الذاكرة المؤقتة البالغة 12.5 مرة هي في نهاية المطاف حساب مبني على الأسعار الرسمية في الوثائق فيما يخص إعادة احتساب البادئة مباشرة بعد الانتقال. أما الوفورات المُحَسّة فعلياً في التكلفة الإجمالية للجلسة، فتختلف بحسب حصة البادئة من التكلفة الكلية، وطول المحادثة، وتكرار الانتقالات. لا ينبغي تفسير نسبة هذا المقال على أنها "تكلفة الجلسة تنخفض 12.5 مرة". الأصح هو أن الوفورات تتمثل تحديداً في "عدم الحاجة إلى إعادة تخزين البادئة مؤقتاً عند لحظة الانتقال".

ومع ذلك، فإن الخلاصة واضحة. إذا كنت تتنقل بين المجلدات بشكل متكرر في مشروع أحادي الجذر أو في مستودعات متعددة، فإن /cd هو أرخص طريقة للحفاظ على سياق المحادثة وذاكرة التخزين المؤقت للـ prompt في آن واحد. إذا كان فريقك يُشغّل وكلاء البرمجة مع مراعاة التكلفة، فهناك ما يكفي من الأسباب لجعل هذا السطر الواحد عادة راسخة.

## المصادر

- [Manage sessions - Claude Code Docs](https://code.claude.com/docs/en/sessions)
- [How Claude Code uses prompt caching - Claude Code Docs](https://code.claude.com/docs/en/prompt-caching)
- [Claude Code /cd: Switch Projects Without Losing Cache](https://claudcod.com/blog/claude-code-cd-command/)
- [التغريدة الأصلية (إعادة تغريد @delba_oliveira)](https://x.com/hjguyhan/status/2074414356058763747)
