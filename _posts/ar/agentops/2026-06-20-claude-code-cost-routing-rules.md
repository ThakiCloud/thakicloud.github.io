---
title: "تخفيض تكاليف تشغيل الوكلاء بالتوجيه: مستويات النماذج، وموجّه المهارات، وسبع قواعد للتكلفة"
excerpt: "انطلاقاً من حادثة أحرقت 705 دولارات في يوم واحد، نكشف القواعد العملية والأرقام الحقيقية وراء تخفيضنا الهيكلي لتكاليف تشغيل وكلاء Claude Code من خلال توجيه نماذج LLM وموجّه المهارات وصحة التوكن."
seo_title: "تحسين تكلفة Claude Code: توجيه النماذج وموجّه المهارات وقواعد التوكن"
seo_description: "قواعد ThakiCloud الميدانية لتخفيض تكاليف وكلاء Claude Code: توجيه haiku/sonnet/opus/fable، وموجّه مهارات BM25، وقاعدة 2K توكن، وترقية النماذج بالمراجعة التراجعية، والتدقيق اليومي -- مع بيانات حوادث حقيقية."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - cost-optimization
  - model-routing
  - token-economy
  - claude-code
  - subagent
  - finops
  - skill-router
  - agentops
  - llm-ops
  - thakicloud
header:
  teaser: /assets/images/cost-routing-hero.webp
toc: true
toc_sticky: true
categories:
  - agentops
published: false
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/claude-code-cost-routing-rules/"
---

![مهام الوكيل تتفرع عبر مستويات النماذج بينما تنخفض التكاليف]({{ '/assets/images/cost-routing-hero.webp' | relative_url }})

## اليوم الذي أحرقنا فيه 705 دولارات

لنبدأ بالحادثة. في الأول من يونيو 2026، شغّلنا جميع الجلسات التسع على نموذج Opus فبلغت التكلفة اليومية المقدّرة 705 دولارات. جلسة مراقبة واحدة استهلكت 381 دولاراً -- أي 54% من الإجمالي. السبب: 9.4 ساعات و1145 دورة و138 استدعاءً لـ ScheduleWakeup تراكمت في جلسة واحدة. جاء اثنان وأربعون بالمئة من تلك التكلفة من cache_read بقيمة 195M توكن. في اليوم ذاته نفّذنا أمر `cd` 153 مرة وأعدنا قراءة الملف نفسه 10 مرات.

المفارقة أن الوكلاء الـ18 الفرعيين الذين أطلقناهم في ذلك اليوم كانوا جميعاً موجَّهين بصورة صحيحة إلى sonnet. المشكلة لم تكن في الفرعيين بل في الوكيل الرئيسي. الإبقاء على الجلسة الرئيسية بـ Opus مع تدوير سياق ضخم عبر دورات متكررة كان المصدر الوحيد للتسرب.

يغطي هذا المقال القواعد التي وضعناها في أعقاب تلك الحادثة. نتجاهل نقاشات منصة الذكاء الاصطناعي ووحدات GPU ونركز كلياً على كيفية تخفيض التكلفة التشغيلية للوكلاء أنفسهم من خلال التوجيه وصحة التوكن.

## 1. مستويات النماذج: توقف عن دفع 19 ضعفاً للعمل ذاته

أكبر رافعة هي اختيار النموذج. مضاعفات التكلفة في بيئتنا واضحة: haiku يساوي تقريباً 1x، وsonnet تقريباً 4x، وopus تقريباً 19x. تشغيل مهمة استكشاف على opus يكلف 19 ضعف haiku.

لذلك نربط النماذج بأنواع المهام بصورة ثابتة.

| المستوى | متى | المضاعف |
|---|---|---|
| `haiku` | الاستكشاف، قراءة الملفات، البحث، grep، التلخيص، الترجمة | ~1x |
| `sonnet` | التحليل، التنفيذ، توليد الكود، المراجعة، الكتابة (افتراضي) | ~4x |
| `opus` | الهندسة المعمارية، الاستدلال متعدد الخطوات، التصحيح المعقد، كتابة المواصفات | ~19x |
| `fable` | المنسق/القائد (توفير حصة الاستخدام) | منخفض |

ثمة قاعدة صارمة واحدة: كل استدعاء لوكيل فرعي يجب أن يحدد معامل `model` صراحةً. حذفه يعني الرجوع إلى نموذج الجلسة الافتراضي -- وإذا كان ذلك الافتراضي Opus يُحاسَب كل استدعاء فرعي بـ 19x. كان ذلك جوهر حادثة الأول من يونيو.

```python
# صحيح: الاستكشاف موجَّه صراحةً إلى haiku
Agent(subagent_type="Explore", model="haiku", prompt="...")
# خطأ: model محذوف -> الافتراضي (opus) = فوترة بـ 19x
Agent(subagent_type="Explore", prompt="...")
```

نضيف نمطاً إضافياً: ضبط الجلسة الرئيسية على fable وإسناد دور القائد إليه فحسب. التوجيه والتفريع والتجميع تتولاها fable بتكلفة منخفضة؛ فقط المراحل التي تحتاج فعلاً إلى استدلال ثقيل تستدعي `Agent(model="opus")` مرة واحدة. الاستكشاف يذهب إلى haiku. عمق التفرع محدود بحدين، ولا يفرز وكلاء haiku الفرعية مزيداً من الوكلاء.

## 2. موجّه المهارات: منع الوكيل الرئيسي من التجوال في قاعدة الكود

الرافعة الثانية هي موجّه المهارات. لدينا أكثر من 1200 مهارة. حين يبدأ الوكيل الرئيسي في البحث بـ grep داخل قاعدة الكود لتحديد أي مهارة يستخدم، يُحرق بذلك توكنات opus باهظة الثمن.

لذا يُشغّل خطاف `UserPromptSubmit` المسمى `skill-router-gate.py` بحثاً BM25 بكود حتمي في كل دورة ويحقن أفضل المرشحين في السياق.

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
<div class="d3-arch" data-arch-root id="audecodecostroutingrules-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 427, "height": 698, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 131, "y": 24, "w": 121, "h": 46, "title": "مدخل المستخدم"}, {"id": "B", "x": 98, "y": 148, "w": 188, "h": 68, "title": ["مرشح صفري للتوكن", "التحيات/الأوامر SKIP"]}, {"id": "C", "x": 214, "y": 308, "w": 156, "h": 62, "title": ["BM25 retrieve", "مجموعة 1200+ مهارة"]}, {"id": "D", "x": 197, "y": 448, "w": 191, "h": 78, "title": ["🧭 مرشحو موجّه المهارات", "أفضل 5 محقونة", "(GATE_MIN=6.0)"]}, {"id": "E", "x": 190, "y": 604, "w": 205, "h": 62, "title": ["الرئيسي يختار من المرشحين", "بدلاً من grep"]}, {"id": "F", "x": 24, "y": 316, "w": 135, "h": 46, "title": "لا حقن (0 توكن)"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [192, 70, 192, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "دورة إجرائية", "curve": [[234, 216], [292, 262], [292, 262], [292, 308]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "line": [292, 370, 292, 448]}, {"src": "D", "dst": "E", "kind": "data", "line": [292, 526, 292, 604]}, {"src": "B", "dst": "F", "kind": "data", "label": "تحية/تأكيد", "curve": [[149, 216], [92, 262], [92, 262], [92, 316]], "off": "50%"}]});
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
      const container = document.getElementById('audecodecostroutingrules-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'audecodecostroutingrules-1';
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

يُعطي الترتيب وزناً كبيراً لتطابق الأسماء التام (مستند إلى idf) ووزناً أصغر لتوكنات الوصف. التحيات والأوامر البسيطة تمر عبر مرشح صفري للتوكن، والدورات المتطابقة المتتالية تُخزَّن مؤقتاً. البنية تضيف تلميحات جهة الإدخال فحسب دون مرور إضافي على LLM -- تكلفة شبه معدومة. النتيجة: الوكيل الرئيسي لا يُحرق توكنات opus في الاستكشاف منذ البداية.

نكون صادقين بشأن الحدود: في تجاربنا مع تفكيك الطلبات المركبة والبحث خطوة بخطوة (SAD)، حتى مع التفكيك المثالي لم يتجاوز سقف استرجاع الخطوات 42.5% step coverage. ادعاء الدراسة بأن "الاسترجاع سليم، فقط أصلح التفكيك" لم يُطبَّق مباشرةً في بيئتنا. لذا التفكيك بالتعبيرات النمطية الحتمية معطّل افتراضياً ويُفعَّل اختيارياً للطلبات المركبة فحسب. نقيس قبل أن نُصلح.

## 3. صحة التوكن: السياق يتسرب بسهولة

الرافعة الثالثة هي صحة التوكن. المبدأ الأساسي: لا يجب أن تتراكم المخرجات الكبيرة مباشرةً في السياق الرئيسي.

أهم القواعد هي قاعدة 2K توكن. أي استدعاء أداة يُتوقع إرجاع أكثر من 2K توكن يُفوَّض إلى وكيل فرعي. يقرأ الوكيل الفرعي ويعالج البيانات ويُرجع ملخصاً فحسب فيبقى السياق الرئيسي نظيفاً. المخرجات المنظمة التي تتجاوز 200 سطر أو 2KB تُرحَّل إلى ملفات بيانات أو SQLite. كود JSON ذو البنية المتكررة يمر بضغط headroom الحتمي لتخفيض بنسبة 50% أو أكثر قبل إعادة حقنه.

تُضاف البادئة `rtk` إلى مخرجات الشل لضغط 60-90%. يكلف كل خادم MCP نحو 1000 توكن من مخطط البيانات في كل دورة، لذا نُعطّل الخوادم غير المستخدمة ونبقي العدد عند 10 أو أقل. هذه هي توكنات الأشباح -- الأعباء غير المرئية في كل دورة من المخططات المحمّلة التي لا تُستدعى قط.

| ملف القاعدة | الآلية |
|---|---|
| `loop-monitor-cost-guard` | الاستطلاع/المراقبة يخرج من الحلقة الساخنة لـ Claude إلى cron (تكلفة $0)؛ /loop يُقسَّم قبل 50 دورة أو 40% من السياق |
| `ecc-token-strategy` | تفويض قاعدة 2K توكن؛ 200+ سطر إلى ملفات بيانات؛ JSON عبر ضغط headroom |
| `rtk-token-optimization` | البادئة `rtk` تضغط مخرجات الأوامر 60-90% |
| `token-diet-hygiene` | خوادم MCP بحد أقصى 10؛ أوصاف المهارات بحد أقصى 512 حرفاً؛ كشف توكنات الأشباح |
| `sonnet-format-determinism` | التنسيق والتعدادات والأعداد ملكية الكود؛ النموذج يولّد المحتوى فحسب |

القاعدة الأخيرة مرتبطة مباشرةً بالتكلفة. في 16 يونيو 2026، تلقّى 33 عاملاً من sonnet تعليمات متطابقة وأنتجوا مخرجات `quality_gate` في 5 أشكال مختلفة؛ وزاد 24 منهم في وضع علامات الحكم. حين تطلب من النموذج إنتاج التنسيق في النثر، يتفاوت في كل استدعاء. لذلك الأرقام والتعدادات والتصيير الآن ملكية كود حتمي، والنموذج يولّد المحتوى فحسب. تختفي الحاجة إلى دفع ثمن نموذج أغلى من أجل اتساق التنسيق.

## 4. التصعيد القائم على المراجعة: ابدأ رخيصاً، رقِّ عند الفشل

المهارات المجدولة لا تُشفِّر النموذج بصورة صارمة. السياسة المركزية `skill_model_policy.json` تبدأ بـ sonnet ويحدد `skill_retro.py` النموذج عبر التحليل التراجعي.

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
<div class="d3-arch" data-arch-root id="audecodecostroutingrules-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 469, "height": 784, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 163, "y": 24, "w": 156, "h": 46, "title": "مشغّل الجدولة يبدأ"}, {"id": "B", "x": 135, "y": 148, "w": 212, "h": 62, "title": ["skill_retro get-model", "استعلام المستوى من السياسة"]}, {"id": "C", "x": 170, "y": 288, "w": 142, "h": 46, "title": "claude -p ينفَّذ"}, {"id": "D", "x": 163, "y": 412, "w": 156, "h": 62, "title": ["skill_retro record", "حكم rc + السجل"]}, {"id": "E", "x": 274, "y": 566, "w": 163, "h": 62, "title": ["إعادة تعيين السلسلة", "sonnet مستمر"]}, {"id": "F", "x": 35, "y": 566, "w": 184, "h": 62, "title": ["ترقية تلقائية إلى opus", "إشعار #h-report"]}, {"id": "G", "x": 24, "y": 706, "w": 205, "h": 46, "title": "إعادة تعيين السلسلة إلى 0"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [241, 70, 241, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [241, 210, 241, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [241, 334, 241, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "تشغيل نظيف", "curve": [[287, 474], [355, 520], [355, 520], [355, 566]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "تشغيلان سيئان متتاليان", "curve": [[195, 474], [127, 520], [127, 520], [127, 566]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [127, 628, 127, 706]}]});
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
      const container = document.getElementById('audecodecostroutingrules-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'audecodecostroutingrules-2';
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

حكم التشغيل السيئ متحفظ: فقط عندما يكون رمز الخروج غير صفري أو يحتوي السجل على علامات مثل فشل المصادقة أو خطأ API أو Traceback. الفشل العابر الواحد لا يستدعي الترقية؛ يلزم تراكم سلسلة من الفشل. النجاحات النظيفة تُعيد تعيين السلسلة ولا يوجد تراجع تلقائي. ضبط التكلفة يأتي من الترقية الانتقائية المستندة إلى البيانات لا من خفض النموذج جملةً وتفصيلاً. فقط المهارات التي تحتاج فعلاً إلى الجودة تصبح مكلفة. عملياً رُبطت مهارة `twitter-timeline-to-slack` بـ opus بعد أن تخطى sonnet مرحلة الإثراء.

## 5. التدقيق: انظر إلى أين تذهب الأموال

الجزء الأخير هو القياس. يحلل `scripts/cost_audit.py` نصوص الجلسات ويُقدّم التكلفة حسب المستوى ومعدل ضرب الذاكرة المؤقتة والجلسات والأدوات الأكثر تكلفةً والملفات التي أُعيدت قراءتها. الرؤى كـ "opus الرئيسي شكّل 97% من الفوترة" في الأول من يونيو تأتي من هنا، وتُغذّي النتائج مجدداً تثبيت النماذج.

تدفق العملية بأكملها في جملة واحدة: اختر نموذج الجلسة حسب نوع المهمة، ودع موجّه المهارات يقلل استكشاف الوكيل الرئيسي، ووجّه الوكلاء الفرعيين حسب المستوى، واحتفظ بالسياق نظيفاً بصحة التوكن، ودع المراجعات الترجعية تُرقّي فقط المهارات الفاشلة، ودع التدقيق يخبرك أين يتسرب المال لاحقاً.

## وجهة نظر ThakiCloud: اقفل ضبط التكلفة في قواعد

تحسين التكلفة ليس قراراً بطولياً لمرة واحدة -- بل هو تراكم قواعد تُطبَّق تلقائياً في كل دورة. معظم القواعد التي دمجناها تعمل عبر كود حتمي وخطافات، فلا أحد يحتاج إلى التفكير فيها يدوياً. النماذج المكلفة ليست محظورة؛ هي محجوزة للحالات التي تُبررها البيانات.

هذا الانضباط أكثر أهمية في البيئات المحلية، حيث تتحول تكاليف التوكن مباشرةً إلى استهلاك كهرباء ووقت GPU. المنصة التي تقدمها ThakiCloud تدمج هذا النوع من التوجيه والمراقبة كأساس، حتى يتمكن العملاء من تشغيل ذات الروافع على بنيتهم التحتية الخاصة.

## خاتمة

الدرس المستفاد من حادثة الـ 705 دولارات كان بسيطاً. التسرب كان في السلوك لا في الأجهزة، والسلوك لا يُصحَّح إلا بالقواعد. طابق مستويات النماذج مع أنواع المهام، وقلل الاستكشاف بموجّه المهارات، وتعامل مع التوكنات بنظافة، ورقِّ فقط ما يفشل، ودقّق يومياً -- وستؤدي العمل ذاته بتكلفة أقل بـ 19 ضعفاً.

تعمل ThakiCloud على جعل هذا الانضباط في التكلفة ميزةً أساسية في المنتج. يمكنك معرفة المزيد على موقعنا الإلكتروني.
