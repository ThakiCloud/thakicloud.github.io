---
title: "المحادثات تتحول إلى مهارات: استخراج سير العمل من الجلسات السابقة وتطويرها ذاتياً"
excerpt: "نكشف عن حلقتين مستقلتين: الأولى تستخدم محرك حتمي لاستخراج سير العمل المتكررة من أكثر من 800 محادثة سابقة وتحويلها إلى مهارات، والثانية تطور محتوى المهارات الموجودة تلقائياً بناءً على أدلة الفشل الفعلية."
seo_title: "المحادثات إلى مهارات: Chronicle Mining و Selfharness"
seo_description: "يستخرج ThakiCloud سير العمل المتكررة من 801 جلسة Claude Code بمحرك حتمي، ويحولها إلى مهارات، ويطورها بدون تسرب باستخدام منهج ورقة Self-Harness."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - skill-evolution
  - self-improvement
  - agent-memory
  - workflow-mining
  - claude-code
  - self-harness
  - chronicle
  - deterministic-pipeline
  - agentops
  - thakicloud
header:
  teaser: /assets/images/self-evolving-skills-hero.webp
toc: true
toc_sticky: true
categories:
  - agentops
published: false
---

![المحادثات السابقة تتبلور في مهارات قابلة لإعادة الاستخدام]({{ '/assets/images/self-evolving-skills-hero.webp' | relative_url }})

## إذا كنت تشرح الشيء ذاته مراراً وتكراراً

من يستخدم وكيل الذكاء الاصطناعي لفترة طويلة سيلاحظ نمطاً واحداً: المهمة ذاتها، بالاصطلاحات ذاتها، تُعطى من الصفر في كل مرة. طلبات من قبيل "ضع هذا المحتوى خطةً باللغة الإنجليزية في مجلد docs" أو "احصل على هذا المستودع وحوّله إلى مهارة" هي في جوهرها سير عمل واحدة، مع اختلاف طفيف في الصياغة.

المهارات ليست مجانية. فور إدراج مهارة في الفهرس، يستهلك اسمها ووصفها رموز السياق في كل جلسة. لذلك فإن القول بثقة "نكرر هذا، فلنصنع منه مهارة" هو أمر غير مسؤول. يجب التحقق من أن التكرار حقيقي، وأنه لا يتداخل مع المهارات الموجودة، وأن الجودة تُحافَظ عليها بعد الإنشاء.

هذه المقالة ليست تسويقاً. نكشف صراحةً عن حلقتين مستقلتين نشغلهما فعلياً. الأولى هي Chronicle mining -- استخراج سير العمل المتكررة من المحادثات السابقة وتحويلها إلى مهارات. والثانية هي selfharness self-evolution -- تصحيح محتوى المهارات الموجودة تلقائياً بناءً على أدلة الفشل.

## 1. Chronicle: تحويل المحادثات السابقة إلى مدوّنة نصية

نحتاج أولاً إلى المادة الخام. جلسات Claude Code تتراكم كنصوص أصلية في `~/.claude/projects/<repo>/*.jsonl`. نستخدم `scripts/memory/extract-sessions.py` لاستخراج العناصر عالية الإشارة فقط من تلك النصوص، وكتابتها كسجلات جلسات بصيغة markdown ضمن `memory/sessions/`. العدد الحالي 801 ملف. يحمل كل ملف في مقدمته `date` و`session_id` و`title` و`files_touched`، مع الرسائل في الجسم.

هذه المدوّنة هي Chronicle الخاصة بنا. التكلفة: صفر. الاستخراج يعمل بشكل تدريجي كخطوة حتمية في خط أنابيب الذاكرة الليلي.

## 2. العد ملك للكود، لا للنماذج

ثمة مبدأ تصميمي واحد جوهري: الأرقام -- التكرار، وتوقيعات الأنماط، وأحكام إزالة التكرار -- لا تُفوَّض أبداً إلى نموذج. حين يُطلب من نموذج تقدير "كم جلسة كررت هذا"، تكون الإجابة خاطئة في الغالب. لذلك فإن محرك الاستخراج `scripts/skills/chronicle_mine.py` هو كود حتمي بحت لا يستدعي LLM أبداً. تكلفة التشغيل فعلياً صفر.

ما يفعله المحرك بسيط: يستخرج رموز الإشارة من عناوين الجلسات والملفات التي عمل عليها، ثم يحسب تكرار الوثائق عبر الجلسات. الرموز وأزواج التزامن التي تظهر في عدد من الجلسات يتجاوز حداً معيناً (الافتراضي: 4 جلسات) تُرقَّى إلى المرشحين. في الوقت ذاته يقارن بين أسماء `.claude/skills/` الموجودة ويضع على كل مرشح وسم `update` (موجود مسبقاً) أو `create` (جديد).

الجزء الصعب هو الضوضاء. في التشغيل الأول، كانت الأنماط الأعلى تكراراً مثل `hooks+state` (260 مرة) و`cursor+plan` (198 مرة). هذه ليست سير عمل متكررة -- بل مسارات البنية التحتية للمستودع التي تلمسها كل جلسة تقريباً. ما يُعرف بـ lexical mismatch. لذلك أضفنا نقطة قطع قائمة على IDF لأقصى تكرار للوثائق. الرموز التي تظهر في أكثر من 16% من المدوّنة تُصنَّف كضوضاء محيطة وتُحذف.

```python
# الرموز التي تتجاوز 16% من المدوّنة هي محيطة (في كل مكان) -> ليست هوية سير عمل
MAX_DF_RATIO = 0.16
ambient = {t for t, c in raw_df.items() if c / n > MAX_DF_RATIO}
```

حتى بعد ذلك، كانت أسماء ملفات SKILL.md من ذاكرة التخزين المؤقت للإضافات ضمن `.cursor/plugins/cache/` تملأ النتائج الأعلى بإشارات زائفة. اكتشفنا السبب فقط بعد فتح عدد من الجلسات الفعلية. استبعدنا بعد ذلك ذاكرة التخزين المؤقت والخطط المُولَّدة والمسارات المضمّنة بالكامل، وضيّقنا الإشارة إلى "العناوين الحاملة لنية المستخدم" و"هويات المهارات المستدعاة فعلياً". عندها فقط ظهرت سير العمل الحقيقية.

هذه العملية بحد ذاتها درس. حين تنخفض الجودة، اللجوء فوراً إلى مستوى نموذج أعلى هو الخيار الكسول. قِس المحرك أولاً، وابحث عن مصدر الضوضاء في البيانات، ثم أصلحه.

## 3. حكم التطور: تحديث أم إنشاء أم تقسيم؟

بمجرد ظهور المرشحين، يتوقف المحرك ويتولى مهارة المنسق `chronicle-skill-miner` اتخاذ القرار. تلميحات إزالة التكرار من الكود استشارية فقط -- الحكم النهائي يأتي من إعادة التحقق بأداة البحث BM25.

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
<div class="d3-arch" data-arch-root id="nsintoselfevolvingskills-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 801, "height": 838, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 306, "y": 24, "w": 135, "h": 62, "title": ["memory/sessions", "801 جلسة"]}, {"id": "B", "x": 299, "y": 164, "w": 149, "h": 62, "title": ["chronicle_mine.py", "المحرك الحتمي"]}, {"id": "C", "x": 295, "y": 304, "w": 156, "h": 62, "title": ["المرشحون + التكرار", "وسم update/create"]}, {"id": "D", "x": 290, "y": 444, "w": 167, "h": 68, "title": ["retrieve.py", "التحقق من التكرار"]}, {"id": "E", "x": 578, "y": 604, "w": 191, "h": 62, "title": ["UPDATE", "دمج في المهارة الموجودة"]}, {"id": "F", "x": 403, "y": 604, "w": 120, "h": 62, "title": ["CREATE", "مهارة جديدة"]}, {"id": "G", "x": 220, "y": 604, "w": 128, "h": 62, "title": ["SPLIT", "فصل حسب القدرة"]}, {"id": "H", "x": 44, "y": 604, "w": 121, "h": 62, "title": ["DISCARD", "مع بيان السبب"]}, {"id": "I", "x": 472, "y": 744, "w": 191, "h": 62, "title": ["إعادة فهرسة retrieve.py", "كشف للموجّه"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [373, 86, 373, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [373, 226, 373, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [373, 366, 373, 444]}, {"src": "D", "dst": "E", "kind": "data", "label": "القدرة ذاتها", "curve": [[457, 500], [673, 558], [673, 558], [673, 604]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "قدرة جديدة", "curve": [[411, 512], [463, 558], [463, 558], [463, 604]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "label": "قدرات متعددة", "curve": [[335, 512], [284, 558], [284, 558], [284, 604]], "off": "50%"}, {"src": "D", "dst": "H", "kind": "data", "label": "مكرر / منفرد / ثقة منخفضة", "curve": [[290, 503], [104, 558], [104, 558], [104, 604]], "off": "50%"}, {"src": "E", "dst": "I", "kind": "data", "curve": [[673, 666], [673, 705], [673, 705], [614, 744]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[463, 666], [463, 705], [463, 705], [521, 744]]}]});
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
      const container = document.getElementById('nsintoselfevolvingskills-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nsintoselfevolvingskills-1';
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

تشغيل 801 جلسة كاملة أعطى نتيجة مثيرة للاهتمام. معظم سير العمل المتكررة للمستخدم كانت مغطاة مسبقاً بمنظومة المهارات الموجودة. تحليل الأسهم يقع تحت stock-jarvis، وإدراج التغريدات الاجتماعية تحت x-to-slack، وتحويل مستودعات GitHub تحت skill-seekers. نتيجة التنظيم الصادقة كانت "تجاهل معظمها". الهدف ليس توليد مهارات مكررة -- بل إنشاء مهارة واحدة جديدة بالضبط لسير عمل غائبة فعلاً.

تلك المهارة الواحدة كانت: "ضع هذا المحتوى خطةً بالإنجليزية كوثيقة هندسية في مجلد docs، مع توجيه المهارة المناسبة، مركزاً على جوهر هندسة البرمجيات." تكررت 39 مرة لكن لم تغطِّها أي مهارة موجودة بدقة. أنشأنا تلك المهارة الواحدة فقط، وعززنا مهارة واحدة كانت محفزاتها ضعيفة، وتجاهلنا الباقي مع بيان السبب. القاعدة هي: لا تتجاهل بصمت؛ سجل دائماً عدد الأنماط التي لم تبلغ الحد الأدنى.

ما يميز هذا النهج عن ميزات تجارية مشابهة أمران: أولاً، المحرك الحتمي يمتلك العد وتصفية الضوضاء، مما يمنع هلوسة التكرار من المصدر. ثانياً، التحقق من التكرار بالاسترجاع يُطبَّق إلزامياً على مدوّنة تضم أكثر من 1,600 مهارة موجودة.

## 4. selfharness: تصحيح محتوى المهارات بناءً على الفشل

إنشاء المهارة ليس النهاية. المهارات تخطئ في التشغيل الفعلي، ولأخطائها أنماط. يستخدم selfharness-evolve تلك الأنماط لتصحيح محتوى المهارة تلقائياً. إنه ورقة Self-Harness (arXiv:2606.09498) مُزروعة في محتوى SKILL.md.

يعمل في ثلاث مراحل.

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
<div class="d3-arch" data-arch-root id="nsintoselfevolvingskills-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 516, "height": 820, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 155, "y": 24, "w": 198, "h": 94, "title": ["آثار الفشل الفعلية", "تصحيحات الجلسات، التغذية", "الراجعة، سجلات حوادث", "القواعد، سجلات الموجّه"]}, {"id": "B", "x": 152, "y": 196, "w": 205, "h": 78, "title": ["1. استخراج نقاط الضعف", "تجميع بـ φ = (cause,", "causal_status, mechanism)"]}, {"id": "C", "x": 152, "y": 352, "w": 205, "h": 94, "title": ["2. اقتراح الحزام", "آلية واحدة لكل مجموعة", "تعديل أدنى للسطح (+20% حد", "نمو)"]}, {"id": "D", "x": 159, "y": 524, "w": 191, "h": 94, "title": ["3. التحقق من الاقتراح", "تقييم ≥3 مرات في السياق", "ذاته", "بوابة عدم الانحدار"]}, {"id": "E", "x": 272, "y": 710, "w": 205, "h": 78, "title": ["تطبيق تلقائي على SKILL.md", "الحي", "نسخ احتياطي للخط الأساسي"]}, {"id": "F", "x": 74, "y": 726, "w": 120, "h": 46, "title": "رفض"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [254, 118, 254, 196]}, {"src": "B", "dst": "C", "kind": "data", "line": [254, 274, 254, 352]}, {"src": "C", "dst": "D", "kind": "data", "line": [254, 446, 254, 524]}, {"src": "D", "dst": "E", "kind": "data", "label": "تحسّن held-in والتحقق<br/>لا انحدار في الاختبار المختوم", "curve": [[315, 618], [374, 664], [374, 664], [374, 710]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "انحدار الاختبار المختوم = إفراط في التوافق", "curve": [[193, 618], [134, 664], [134, 664], [134, 726]], "off": "50%"}]});
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
      const container = document.getElementById('nsintoselfevolvingskills-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nsintoselfevolvingskills-2';
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

المرحلة الأولى، استخراج نقاط الضعف، تجمّع الفشل الحقيقي بتوقيع `φ = (cause, causal_status, mechanism)` وترتبه حسب الدعم وقابلية التنفيذ. يُسحب حقل `cause` من مجموعة ثابتة: wrong_output, missing_step, stale_data, ignored_constraint, format_violation. المصادر هي الجلسات التي صحّح فيها المستخدمون مهارة، وذاكرة التغذية الراجعة، وسجلات حوادث القواعد، وسجلات الموجّه.

المرحلة الثانية، الاقتراح، تمرر المجموعات الأعلى إلى محرك الطفرة (hermes) كتغذية راجعة مستهدفة. طفرة واحدة تلمس آلية واحدة فقط وتجري الحد الأدنى من التعديل على سطح تحرير تلك المجموعة. النمو محدود بحد صارم +20%. تصحيحات الحداثة والضمانات عادةً 3-5 أسطر.

المرحلة الثالثة، التحقق، هي الأهم. نُقيّم الاقتراح ثلاث مرات على الأقل في السياق ذاته، ويجب أن يتحسن كل من held-in والتحقق ليمر الاقتراح. والأهم: تقسيم `test` مختوم -- البوابة لا ترى الاختبار أبداً. إذا مرّ اقتراح لكن انحدر الاختبار المختوم، يُصنَّف إفراطاً في التوافق ويُرفض. هذا هو التصميم الخالي من التسرب الذي يصلح مشكلة تسرب الاختبار المحتجز في الورقة الأصلية. مقدمة SKILL.md وجميع عبارات التفعيل تُحفظ.

## 5. حلقتان مستقلتان مستقلتان

لنوضح نقطة كثيراً ما تسبب لبساً. لدينا حلقتا تطور متعامدتان.

الأولى هي selfharness المذكورة للتو: تطور جودة محتوى المهارات. والثانية هي `skill_retro.py` مع `skill_model_policy.json`: تطور مستوى النموذج الذي تعمل عليه المهارة. الحلقة الثانية تبدأ رخيصة بـ sonnet افتراضياً، ثم إذا فشلت مهارة مرتين متتاليتين، تُرقَّى تلك المهارة وحدها تلقائياً إلى opus. النجاح النظيف يصفّر سلسلة الفشل.

جودة المحتوى وتكلفة التنفيذ مشكلتان منفصلتان، ولذا تتكفل بهما حلقتان منفصلتان. الجانب المتعلق بالتكلفة نتناوله في مقالة منفصلة.

## منظور ThakiCloud: عمليات تزداد ذكاءً مع الاستخدام

سبب تشغيلنا هاتين الحلقتين بأنفسنا بسيط. مهندس واحد يدير منظومة مهارات تضم أكثر من 1,600 مهارة يحتاج تلك المنظومة أن تُنظّم نفسها وتنمو بدون تدخل بشري.

هذه هي الفلسفة ذاتها وراء منصة الذكاء الاصطناعي المحلية التي نسعى لتقديمها لعملائنا. الأتمتة الجيدة لا تُبنى مرة واحدة وتُترك -- بل تحسّن نفسها بناءً على بيانات الاستخدام الفعلي. الكود الحتمي يمتلك القياس والعد. النماذج تُستدعى بتكلفة عالية فقط حيث يلزم الحكم. كل تغيير يجب أن يمر ببوابة عدم الانحدار قبل أن يظهر في الإنتاج. هذا الانضباط -- المنع الهيكلي للهلوسة، ورفع التكاليف بناءً على أدلة البيانات فقط -- هو أساس الثقة التي نبيعها.

## ختاماً

الأعمال المتكررة ينبغي أن تصبح مهارات، لكن ليس كل تكرار يستحق ذلك. نستخرج المحادثات السابقة بمحرك حتمي لتحديد التكرارات الحقيقية، ونفرض إزالة التكرار مقابل المنظومة الموجودة، ونطور المهارات التي ننشئها بطريقة خالية من التسرب بناءً على أدلة الفشل. الكود يحسب التكرار. بوابة عدم الانحدار تحرس الجودة. حلقة منفصلة تتحكم في التكلفة.

يُنفّذ ThakiCloud هذا النوع من التشغيل العامل الذاتي التحسين بشكل مدمج في البيئات المحلية. إذا أردت تشغيل الانضباط ذاته على بنيتك التحتية، يمكنك العثور على مزيد من المعلومات على موقعنا الإلكتروني.
