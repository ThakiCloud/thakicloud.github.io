---
title: "everything-claude-code: تشريح هيكل برمجة بالذكاء الاصطناعي صُقل عبر ستة أشهر من الاستخدام الفعلي"
excerpt: "أدوات البرمجة بالذكاء الاصطناعي تنسى قواعدك مع كل جلسة جديدة. حلّ أحد الفائزين بهاكاثون Anthropic هذه المشكلة بنشر إعداداته مفتوحة المصدر بعد صقلها ستة أشهر على خدمة TypeScript مصغّرة حقيقية. نشرّح تصميم everything-claude-code القائم على هيكل رفيع ومهارات ثقيلة، ونبيّن كيف يحوّل Paxis من ThakiCloud المبدأ نفسه إلى منتج."
date: 2026-07-20
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/everything-claude-code-agent-harness/"
tags:
  - ClaudeCode
  - 에이전트하네스
  - Skills
  - Rules
  - AI코딩
  - AgentOps
  - Paxis
  - 개발생산성
author_profile: true
toc: true
toc_label: تشريح الهيكل
published: true
categories:
  - dev
  - agentops
---

![نواة هيكل رفيعة متصلة بوحدات مهارات متعددة]({{ '/assets/images/everything-claude-code-agent-harness-hero.webp' | relative_url }})

## نظرة عامة

أي مطوّر يستخدم أداة برمجة بالذكاء الاصطناعي بجدية لبضعة أيام يصطدم بالجدار نفسه. بالأمس أخبرتها بوضوح "هذا المشروع يُلتزَم به هكذا، لا تلمس ذلك المجلد، شغّل الاختبارات بهذا الأمر"، ومع ذلك اليوم، عند فتح جلسة جديدة، لا تتذكر الأداة أيًّا من ذلك. تلصق القواعد نفسها من جديد، وتتراجع عن الكود المخالف للأعراف من جديد. وكلما ازداد النموذج ذكاءً، ازدادت هذه الفجوة إحباطًا: القدرة موجودة، لكن لا يوجد هيكل يجعل تلك القدرة تطبّق قواعدك باتساق.

مستودع `everything-claude-code` هو مجموعة إعدادات مفتوحة المصدر تعالج هذا الهيكل تحديدًا. نشر أحد الفائزين بهاكاثون Anthropic كامل إعداداته بمستوى إنتاجي بعد أن صقلها أكثر من ستة أشهر على مشروع خدمة TypeScript مصغّرة حقيقي، وجمع المستودع نجومًا بسرعة بعد الإصدار (نحو 9,700 بحسب التغريدة المصدر، [تقديري]). يستعرض هذا المقال ما يحتويه المستودع، والمبادئ التصميمية التي يقوم عليها، وكيف تتصل تلك المبادئ بمنصة الوكلاء التي تبنيها ThakiCloud. وقد تبنّت ThakiCloud مجموعة قواعد هذا المستودع كمعيار داخلي فعلي، لذا فهذا رأي قائم على التجربة لا مجرد تعريف.

## ما هو everything-claude-code

يعرّف `everything-claude-code` (اختصارًا ECC) نفسه بأنه "نظام تحسين أداء هيكل الوكيل". وهو يجمّع ستة أنواع من أصول الإعداد: وكلاء فرعيون يعالجون المهام المفوّضة (agents)، وحزم معرفة متخصصة تُستدعى عند الطلب (skills)، وخطّافات تتدخّل تلقائيًا قبل تنفيذ الأدوات وبعده (hooks)، وأوامر مائلة تغلّف الأعمال المتكررة (commands)، وقواعد تُطبَّق دائمًا (rules)، وإعدادات خوادم MCP التي تربط الأدوات الخارجية (MCPs).

والأهم أن هذا ليس إعداد مشروع هواية. فقد فاز المؤلف بهاكاثون Anthropic x Forum Ventures في سبتمبر 2025 ببناء منتج باستخدام Claude Code وحده، ثم صقل هذا الإعداد أكثر من عشرة أشهر وهو يشحن منتجات حقيقية يوميًا. ومؤشرات الجودة التي يذكرها المستودع محدّدة: 1,282 اختبارًا، وتغطية 98٪، و102 قاعدة تحليل ساكن. إن كون مجموعة إعدادات تحمل هذا المستوى من الانضباط هو بذاته دليل على أن المؤلف يفصل بين "قواعد تُسلَّم للذكاء الاصطناعي" و"كود يتحقق من الالتزام بتلك القواعد".

سمة أخرى هي حياد الهيكل. صُمِّم ECC ليعمل ليس فقط في Claude Code بل أيضًا في وكلاء برمجة آخرين مثل Codex وOpencode وCursor. وفكرة إعادة استخدام القواعد والمهارات نفسها عبر أدوات متعددة هي نتيجة طبيعية لفلسفة التصميم التي نناقشها أدناه.

## البنية: هيكل رفيع، مهارات ثقيلة

قلب ECC مبدأ واحد: **ابنِ القدرة في المهارات لا في الهيكل.** فالهيكل نفسه، أي الهيكل التنفيذي لحلقة النموذج والوصول إلى الملفات والصلاحيات والأمان، يبقى في حدّه الأدنى، بينما تُكدَّس المعرفة المجالية ومعايير الحكم والقوالب وحالات الفشل بكثافة في المهارات والقواعد. هذا ما يتيح للمهارة نفسها أن تعمل عبر أكثر من هيكل، سواء Claude Code أو Cursor.

تقود هذه الفلسفة مباشرة إلى تمييزين عمليين. الأول هو الفصل بين أدوار القواعد (Rules) والمهارات (Skills). القواعد معايير وقوائم تحقّق واسعة تُطبَّق دائمًا، مثل "تغطية اختبار 80٪ أو أعلى" أو "لا أسرار مكتوبة في الكود". وهي تُحمَّل كل دور. أما المهارات فمعرفة تنفيذية مطلوبة بعمق لمهمة محدّدة، تُحمَّل فقط حين يستدعيها الطلب. القواعد تحدّد *ماذا* تفعل، والمهارات تخبرك *كيف*.

الثاني هو أن القواعد نفسها تُكدَّس في طبقات. يحتوي مجلد `common/` على المبادئ العامة المستقلّة عن اللغة (أسلوب البرمجة، سير عمل git، الاختبار، الأمان، وغيرها)، وفوقه تمدّد المجلدات الخاصة باللغة مثل `typescript/` و`python/` و`golang/` و`web/` القواعدَ العامة أو تتجاوزها. تعمل الأولوية مثل خصوصية CSS أو قواعد `.gitignore`: القاعدة الأكثر تحديدًا تتغلب على الأكثر عمومية. مثلًا توصي القواعد العامة بعدم القابلية للتغيير كمبدأ افتراضي، لكن قواعد Go الخاصة باللغة تنصّ على أن تعديل البنية عبر مستقبِلات المؤشرات أمر اصطلاحي، فتتجاوز تلك النقطة وحدها.

تبدو البنية الكاملة على النحو التالي.

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
<div class="d3-arch" data-arch-root id="ngclaudecodeagentharness-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1013, "height": 926, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 362, "y": 24, "w": 120, "h": 46, "title": "طلب المطوّر"}, {"id": "B", "x": 323, "y": 148, "w": 198, "h": 78, "title": ["هيكل رفيع", "حلقة النموذج، الصلاحيات،", "الأمان"]}, {"id": "C", "x": 707, "y": 309, "w": 146, "h": 52, "title": "يُحمَّل كل دور"}, {"id": "D", "x": 776, "y": 444, "w": 205, "h": 62, "title": ["Rules", "معايير دائمة وقوائم تحقّق"]}, {"id": "E", "x": 621, "y": 584, "w": 121, "h": 46, "title": "مُشغِّل الطلب"}, {"id": "F", "x": 618, "y": 708, "w": 128, "h": 62, "title": ["Skills", "خبرة عند الطلب"]}, {"id": "G", "x": 797, "y": 584, "w": 163, "h": 46, "title": "قواعد common العامة"}, {"id": "H", "x": 801, "y": 708, "w": 156, "h": 62, "title": ["قواعد اللغة", "الخاص يتجاوز العام"]}, {"id": "I", "x": 421, "y": 708, "w": 142, "h": 62, "title": ["Agents", "مختصّون مفوَّضون"]}, {"id": "J", "x": 249, "y": 304, "w": 205, "h": 62, "title": ["Hooks", "تحقّق آلي قبل/بعد التنفيذ"]}, {"id": "K", "x": 24, "y": 304, "w": 170, "h": 62, "title": ["خوادم MCP", "ربط الأدوات الخارجية"]}, {"id": "L", "x": 622, "y": 848, "w": 120, "h": 46, "title": "مخرجات متسقة"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [422, 70, 422, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[521, 209], [780, 265], [780, 265], [780, 309]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[817, 361], [879, 405], [879, 405], [879, 444]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[743, 361], [682, 405], [682, 545], [682, 584]]}, {"src": "E", "dst": "F", "kind": "data", "line": [682, 630, 682, 708]}, {"src": "D", "dst": "G", "kind": "data", "line": [879, 506, 879, 584]}, {"src": "G", "dst": "H", "kind": "data", "line": [879, 630, 879, 708]}, {"src": "B", "dst": "I", "kind": "data", "curve": [[457, 226], [492, 405], [492, 607], [492, 708]]}, {"src": "B", "dst": "J", "kind": "data", "curve": [[387, 226], [352, 265], [352, 265], [352, 304]]}, {"src": "B", "dst": "K", "kind": "data", "curve": [[323, 212], [109, 265], [109, 265], [109, 304]]}, {"src": "F", "dst": "L", "kind": "data", "line": [682, 770, 682, 848]}, {"src": "H", "dst": "L", "kind": "data", "curve": [[879, 770], [879, 809], [879, 809], [742, 852]]}, {"src": "I", "dst": "L", "kind": "data", "curve": [[492, 770], [492, 809], [492, 809], [622, 851]]}]});
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
      const container = document.getElementById('ngclaudecodeagentharness-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ngclaudecodeagentharness-1';
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

يبدأ اتضاح كيف تحلّ هذه البنية مشكلة "نسيان القواعد كل مرة" السابقة. فالقواعد تُحمَّل تلقائيًا كل جلسة، فلا يحتاج المطوّرون إلى إعادة لصق الأعراف. والمهارات تُحمَّل فقط عند الحاجة، فلا تهدر نافذة السياق. والخطّافات تتحقق على مستوى الكود مما إذا كانت أداة قد خالفت قاعدة. بعبارة أخرى، فحوصات حتمية تفرض الجودة بدل الاعتماد على تقرير النموذج الذاتي.

## كيف تتبنّاه فعليًا

هناك مساران للتبنّي. الأسهل هو تثبيته عبر سوق إضافات Claude Code. والأكثر مباشرة هو استنساخ المستودع ونسخ الأصول التي تحتاجها فقط إلى مجلد إعداد Claude لديك. ولتجنّب كسر البنية الطبقية، انسخ على مستوى المجلد.

```bash
# أنشئ مساحة أسماء قواعد ECC مرة واحدة.
mkdir -p ~/.claude/rules/ecc

# انسخ القواعد العامة (مطلوبة لكل المشاريع).
cp -r rules/common ~/.claude/rules/ecc/

# انسخ القواعد الخاصة باللغة المطابقة لحزمة مشروعك.
cp -r rules/typescript ~/.claude/rules/ecc/
cp -r rules/golang ~/.claude/rules/ecc/
cp -r rules/web ~/.claude/rules/ecc/
```

هنا يحذّر المستودع صراحةً من خطأ شائع. لا تنسخ بالتسطيح عبر نمط بدل مثل `rules/common/*`. فالمجلدات العامة والخاصة باللغة تحتوي على ملفات بالأسماء نفسها (`coding-style.md` و`testing.md` وغيرهما)، فالتسطيح يجعل ملف اللغة يكتب فوق الملف العام ويكسر المرجع النسبي (`../common/`). وللحفاظ على التسلسل الهرمي، يجب نسخ المجلدات كاملة.

تحتاج إعدادات خادم MCP إلى معالجة منفصلة. اسحب فقط إعدادات الخوادم التي تحتاجها من `mcp-configs`، لكن النقطة الأساسية هي **عدم تفعيلها كلها دفعة واحدة**. يحذّر المستودع بقوة هنا، لأن كثرة الأدوات المرتبطة قد تقلّص نافذة سياق سعتها 200k إلى 70k فعليًا. فكل خادم MCP مفعَّل يدفع كلفة مخطّط كل دور، لذا تحتاج إلى انضباط تفعيل الخوادم التي تستخدمها فعلًا فقط.

الخطّافات هي جوهر الأتمتة التي يؤكّد عليها المستودع. مثلًا اربط خطّافًا يشغّل منسّق التنسيق بعد تحرير الملفات، وخطّافًا يفحص حجم الملف قبل الالتزام، وخطّافًا يتحقق من بناء الإنتاج عند انتهاء الجلسة بنقاط دخول أدوات مشروعك الحالية. أما الخطّافات التي تشغّل حِزَمًا بعيدة لمرة واحدة فيُنصح بتجنّبها؛ واستخدام اعتماديات محلية يملكها المستودع هو الأسلوب الموصى به.

## دلالات التطبيق على منتجات ThakiCloud

تتداخل المبادئ التصميمية التي يطرحها ECC بشكل لافت مع ما تبنيه ThakiCloud. دعوني أقسّم ذلك إلى عدستين.

**عدسة Paxis (منصة الوكلاء).** إن Paxis من ThakiCloud هو مستوى تحكّم Agent-Native Cloud يعمل فوق ai-platform، ويتعامل مع Skills وTools وPolicies وAudit Logs بوصفها موارد من الدرجة الأولى. وفلسفة ECC "هيكل رفيع، مهارات ثقيلة" هي بالضبط النموذج الذي يحوّله Paxis إلى منتج. فـ Skill Harness في Paxis يختار من أكثر من 960 مهارة عبر BM25، وينفّذها في صناديق رمل معزولة، ويمرّر كل فعل عبر بوابات السياسات وسجلات التدقيق. بعبارة أخرى، طبقات القواعد والمهارات والخطّافات التي يديرها ECC يدويًا في مجلد `~/.claude` لمطوّر فرد، يرفعها Paxis إلى مستوى سحابة متعددة المستأجرين من الاختيار التلقائي والتنفيذ المعزول وفرض السياسات والتدقيق. ويمكن اعتبار Paxis الصورة التشغيلية بحجم المنصّة للمبادئ التي تحقّق منها ECC في سير عمل فردي. ورؤية ECC بأن "القواعد تُحمَّل كل دور وتدفع إيجارًا" تنتقل مباشرة إلى تصميم Paxis القائم على تحميل المهارات عند الطلب فقط وترشيح الضجيج عبر BM25.

**عدسة ai-platform (البنية التحتية).** تنطبق فكرة القواعد الطبقية أيضًا على توحيد البنية التحتية. فكما يفصل ECC بين القواعد العامة وقواعد اللغة، تفصل ai-platform من ThakiCloud بين الإعدادات الافتراضية على مستوى المؤسسة والتجاوزات لكل عنقود ولكل مستأجر. إن تعريف معايير البنية مثل K8s وجدولة Kueue GPU وخدمة vLLM مرة واحدة وتطبيقها باتساق عبر بيئات عملاء متعددة، مع تجاوز خصوصيات كل بيئة في الطبقات الأدنى، هو الشكل نفسه لنموذج أولوية القواعد في ECC. وكلما اشتدّت متطلبات العميل المتعلقة بالتشغيل داخل المؤسسة والسيادة، ازداد تحوّل انضباط "افرض معيارًا عُرّف مرة، مع تجاوزه بأمان لكل بيئة" إلى موثوقية تشغيلية.

باختصار، ECC هو خلاصة نظافة الهيكل المصنوعة يدويًا من قِبل فرد، وThakiCloud تبني منتجات تحافظ فيها المنصّة على تلك النظافة تلقائيًا. الخدمة منخفضة الكلفة (ai-platform) تصنع اقتصاديات الوكلاء، وفوقها يصنع تنفيذ المهارات بسياسة وتدقيق (Paxis) الثقة.

## الحدود والاعتراضات

من أجل التوازن، دعوني أذكر الجانب الآخر. أولًا، ECC إعداد يعكس بقوة ذوق شخص واحد وسير عمله. فهو نتيجة صقل خدمة TypeScript مصغّرة معيّنة ستة أشهر، لذا فإن نسخه كما هو إلى حزمة مختلفة أو ثقافة فريق مختلفة قد يخلق احتكاكًا بدلًا من ذلك. ولهذا يحذّر المستودع مرارًا من النسخ واللصق كما هو، بل التكييف مع احتياجات مشروعك.

ثانيًا، كلما ازداد الإعداد سماكة، ارتفعت كلفة الصيانة. فتحميل القواعد كل دور يعني استهلاك الرموز كل دور. وبينما تضيف قواعد ومهارات، عليك أن تسأل باستمرار "هل يحتاج هذا فعلًا إلى الوجود في كل جلسة؟"، وإلا تسرّبت ميزانية السياق بهدوء. ويعالج ECC نفسه ذلك بانضباط "كل سطر يجب أن يدفع إيجارًا"، لكن الحفاظ على الانضباط في النهاية مهمة بشرية.

ثالثًا، حياد الهيكل مثالٌ لا ضمان. فالوعد بأن المهارة نفسها تعمل بشكل مطابق في Claude Code وCursor لا يصحّ إلا حين يكون سطح الأدوات ونموذج الصلاحيات في كل هيكل متوافقين فعلًا. فإن اختلفت طريقة تنفيذ الخطّافات أو قواعد الوصول إلى الملفات بين الهياكل، فقد تنحرف مهارة مكتوبة بحياد على هيكل معيّن بهدوء.

ومع ذلك، قيمة ECC واضحة. فمشكلات الجودة في أدوات البرمجة بالذكاء الاصطناعي تنشأ عادةً لا لأن النموذج ضعيف، بل لأنه لا يوجد هيكل قواعد وتحقّق يلفّ النموذج. وقد نشر ECC ذلك الهيكل في صورة مجرَّبة ميدانيًا، وThakiCloud على طريق رفع المبادئ نفسها إلى حجم المنصّة. ولأي فريق يسعى إلى تسليم الكود للذكاء الاصطناعي، تستحق رسالة هذا المستودع، "افحص الهيكل قبل أن تبدّل النموذج"، أن تبقى في البال.

## المصادر

- [everything-claude-code (affaan-m/everything-claude-code)، GitHub](https://github.com/affaan-m/everything-claude-code)
- ملف المؤلف المتعلق بـ [zenith.chat](https://zenith.chat/)، الفائز بهاكاثون Anthropic x Forum Ventures
- التغريدة الأصلية: ‎@Ryrenz (RT @hjguyhan)، 2026-07-20
