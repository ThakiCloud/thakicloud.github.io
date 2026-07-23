---
title: "Grok 4.5 يظهر مستهدفاً البرمجة والوكلاء: كيف يغيّر أداء بمستوى Opus بسعر رخيص المعادلة"
seo_title: "تحليل نموذج Grok 4.5 للبرمجة والوكلاء البرمجية - Thaki Cloud"
seo_description: "كشفت SpaceXAI عن Grok 4.5، أول نموذج مُدرَّب خصيصاً للبرمجة والوكلاء المستقلين، ويقدم أداءً بمستوى Opus بسعر منخفض. نحلل تدريب التعلم المعزز RL الذي استثمر في الذكاء لكل رمز (token)، وتكامل Cursor، وما يعنيه هذا الإعلان من منظور Thaki Cloud للسحابة الوكيلية."
excerpt: "كشفت SpaceXAI عن Grok 4.5. تم تدريبه من الأساس للبرمجة والوكلاء، ويقدم أداءً بمستوى Opus مقابل 2 دولار لكل مليون رمز إدخال و6 دولارات لكل مليون رمز إخراج. نستعرض من منظور Thaki Cloud التحول في معادلة التكلفة الذي يحدثه الذكاء الوكيلي الرخيص."
date: 2026-07-10
tags:
  - grok
  - xai
  - coding-agents
  - llm-pricing
  - agentic-coding
  - reinforcement-learning
categories:
  - news
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ar/news/grok-4-5-coding-agents/"
lang: ar
published: false
---

كل فريق جرّب كتابة الكود عبر وكيل ذكاء اصطناعي يعرف عائقاً واحداً. عندما تُسند مهمة طويلة إلى وكيل، يكرر النموذج قراءة الملفات واستدعاء الأدوات وإعادة التفكير عشرات المرات. في هذه الأثناء تتراكم الرموز (tokens) بسرعة، وكلما كان النموذج أقوى أداءً، ازدادت وطأة هذه التكلفة. حتى الآن كان "النموذج الأذكى في البرمجة" و"النموذج القابل للتشغيل فعلياً طوال اليوم" قصتين مختلفتين. Grok 4.5 الذي كشفته SpaceXAI يستهدف بالضبط هذه الفجوة.

![صورة تجسّد بشكل تجريدي مسار عمل يجمع بين الكود ومهام الوكلاء]({{ '/assets/images/grok-4-5-coding-agents-hero.png' | relative_url }})
*تجسيد تجريدي لفكرة نموذج صُمم من الأساس للبرمجة ومهام الوكلاء.*

## نظرة عامة

Grok 4.5 هو نموذج أعلنت SpaceXAI أنها دربته من الصفر للبرمجة والوكلاء المستقلين. لم يُموضَع كروبوت محادثة استهلاكي، بل كأداة للتطوير والعمل المعرفي، ويستهدف قواعد الأكواد الكبيرة واستخدام الأدوات والمهام طويلة الأمد. وصفه Elon Musk بأنه نموذج "بمستوى Opus لكنه أسرع وأكثر كفاءة من حيث الرموز وأقل تكلفة". وOpus المشار إليه هنا كان حتى وقت قريب فئة النماذج الأعلى لدى Anthropic.

سبب تجاوز هذا الإعلان مجرد إطلاق نموذج جديد يكمن في السعر وطريقة التدريب. سُعّر Grok 4.5 بـ2 دولار لكل مليون رمز إدخال، و6 دولارات لكل مليون رمز إخراج. طرح أداء بمستوى الطليعة (frontier) بهذا السعر يهز الافتراض السائد بأن "النماذج الذكية باهظة الثمن بحيث يصعب تشغيلها كوكلاء لفترات طويلة". من منظور Thaki Cloud، هذا التحول ليس شأناً بعيداً عنا. فالذكاء الوكيلي الرخيص يغيّر مباشرة اقتصاديات المنصات التي تشغّل الوكلاء بشكل دائم.

## ماذا أُعلن

فيما يلي ملخص الحقائق المُعلنة. Grok 4.5 هو أول نموذج من SpaceXAI مُدرَّب خصيصاً لمهام البرمجة والوكلاء، وتزعم الشركة أنه يتفوق على النماذج المماثلة في الهندسة والعمل المعرفي. جرى التدريب جنباً إلى جنب مع محرر الأكواد Cursor، في سياق استحواذ SpaceXAI على Cursor ثم صقل النموذج داخل بيئة استخدامه. وبالفعل، أصبح Grok 4.5 متاحاً منذ إطلاقه في جميع خطط Cursor، كما يُقدَّم عبر Grok Build وواجهة SpaceXAI. غير أنه، حتى وقت الإعلان، لا يزال غير متاح في الاتحاد الأوروبي.

كُشف أيضاً عن البنية التحتية للتدريب. أوضحت الشركة أنها دربت هذا النموذج على عشرات الآلاف من وحدات معالجة الرسوميات NVIDIA GB300، واستثمرت بشكل كبير في التعلم المعزز (RL) لرفع الذكاء لكل رمز (per-token intelligence). وتشرح SpaceXAI أن هذا الاستثمار بالتحديد هو ما خلق فجوة الكفاءة في الرموز مقارنةً بـOpus 4.8. بمعنى آخر، دُرِّب النموذج على إنجاز المهمة ذاتها بعدد أقل من الرموز، وهو ما يترجم مباشرة إلى خفض تكلفة الاستخدام الفعلي.

## ماذا يعني "التدريب المخصص للبرمجة والوكلاء"

عبارة "دُرِّب للبرمجة والوكلاء" يسهل تجاهلها كشعار تسويقي، لكنها تحمل توجهاً تصميمياً محدداً. تُحسَّن النماذج الحوارية العامة للإجابة بشكل طبيعي عن مواضيع واسعة النطاق. أما نماذج الوكلاء فجوهرها القدرة على استدعاء الأدوات عبر خطوات متعددة، ومراقبة النتائج الوسيطة، وتعديل الخطة، وإتمام مهام طويلة. هذه القدرة لا تُكتسب من جودة استجابة واحدة فقط، بل يلعب التعلم المعزز الذي يُعيد تغذية نجاح المسار (trajectory) بأكمله كإشارة مكافأة دوراً كبيراً فيها.

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
<div class="d3-arch" data-arch-root id="260710grok45codingagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 562, "height": 802, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 205, "h": 46, "title": "تعليمات المهمة من المطوّر"}, {"id": "B", "x": 38, "y": 148, "w": 177, "h": 62, "title": ["الوكيل: استكشاف قاعدة", "الأكواد"]}, {"id": "C", "x": 346, "y": 302, "w": 184, "h": 62, "title": ["استدعاء الأدوات: تعديل", "الملفات واختبارها"]}, {"id": "D", "x": 274, "y": 456, "w": 184, "h": 46, "title": "مراقبة النتائج الوسيطة"}, {"id": "E", "x": 163, "y": 580, "w": 167, "h": 52, "title": "هل اكتملت المهمة؟"}, {"id": "F", "x": 182, "y": 724, "w": 128, "h": 46, "title": "الناتج النهائي"}, {"id": "G", "x": 270, "y": 148, "w": 191, "h": 62, "title": ["تدريب RL على الذكاء لكل", "رمز"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [127, 70, 127, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[171, 210], [236, 256], [236, 256], [357, 302]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[438, 364], [438, 410], [438, 410], [390, 456]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[366, 502], [366, 541], [366, 541], [294, 580]]}, {"src": "E", "dst": "B", "kind": "data", "label": "\"لا\"", "curve": [[194, 580], [117, 479], [117, 333], [122, 210]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "\"نعم\"", "line": [246, 632, 246, 724], "lx": 246, "ly": 674}, {"src": "G", "dst": "C", "kind": "event", "label": "تأثير", "curve": [[395, 210], [438, 256], [438, 256], [438, 302]], "off": "50%"}, {"src": "G", "dst": "D", "kind": "event", "label": "تأثير", "curve": [[321, 210], [256, 256], [256, 410], [329, 456]], "off": "50%"}]});
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
      const container = document.getElementById('260710grok45codingagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '260710grok45codingagents-1';
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

يجب قراءة "الذكاء لكل رمز" الذي شددت عليه SpaceXAI في هذا السياق. السبب البنيوي وراء انفجار استهلاك الرموز عندما يشغّل الوكيل مهمة طويلة هو أن النموذج يفكر بإسهاب أكثر من اللازم للوصول إلى الاستنتاج ذاته، أو يكرر استدعاءات أدوات غير ضرورية. عندما يُدرَّب النموذج على حمل قدر أكبر من الحكم في كل رمز، يمكنه إنهاء المهمة ذاتها بمسار أقصر. ويرتبط بهذا أيضاً كون التدريب جرى داخل بيئة برمجة فعلية هي Cursor. فاستخدام أنماط استدعاء الأدوات الفعلية كإشارة تدريب يمكن أن يدفع الوكيل إلى التعامل مع الأدوات بكفاءة أكبر.

## التحول الذي يصنعه السعر

تقديم أداء بمستوى الطليعة مقابل 2 دولار لكل مليون رمز إدخال و6 دولارات لكل مليون رمز إخراج يغيّر حسابات الربح والخسارة في تشغيل الوكلاء. في مسارات العمل التي يستهلك فيها الوكيل ملايين الرموز وهو يتنقل طوال اليوم عبر قاعدة الأكواد، يحدد سعر الرمز مباشرة هامش ربح الخدمة. وإذا تقارب الأداء، يفوز النموذج الأرخص. وبالفعل تشير عدة تحليلات إلى أن Grok 4.5 أرخص بكثير من Fable 5 وGPT 5.5، بحيث قد يُختار على أساس السعر وحده إذا لم تكن فجوة النتائج القياسية (benchmark) كبيرة.

أهمية هذه النقطة تكمن في أن الذكاء الوكيلي الرخيص يعيد فتح مسارات عمل كانت قد طُويت بسبب التكلفة. فكلما كانت المهمة أكثر استهلاكاً للرموز - كأتمتة مراجعة الأكواد، وإعادة الهيكلة (refactoring) واسعة النطاق، ووكلاء المراقبة الدائمة - كان أثر خفض السعر أكبر. لكن هذا الحساب يأتي مع تحفظ. فانخفاض سعر واجهة برمجة التطبيقات (API) هو أيضاً ثمن للتبعية لمزود سحابي. تخرج البيانات إلى الخارج، وتخضع سياسة التسعير والتوافر لقرارات المزود. وحقيقة أن Grok 4.5 لا يزال غير متاح في الاتحاد الأوروبي تُظهر أن هذه التبعية خطر حقيقي وليس افتراضياً.

## من منظور Thaki Cloud

ظهور نماذج الوكلاء الرخيصة يمسّ منتجَي Thaki Cloud كليهما.

من منظور Paxis، تعزز نماذج الوكلاء منخفضة التكلفة وعالية الأداء مثل Grok 4.5 فرضية Agent-Native Cloud. Paxis هي طبقة تحكم للوكلاء تعمل فوق ai-platform، وتتعامل مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. في بنية ينفّذ فيها الوكيل مهمة طويلة عبر عشرات الخطوات، تحتاج - أياً كان النموذج المستخدم - إلى طبقة تُمرِّر سلوكه عبر بوابات السياسات وتُسجّله في سجلات التدقيق. فكلما رخُص النموذج، زاد تشغيل الوكلاء أكثر ولفترات أطول، وكلما زادت قيمة التنسيق (orchestration) والحوكمة. الذكاء الرخيص لا يقلل من الحاجة إلى منصة الوكلاء، بل يزيدها.

من منظور ai-platform، تتضح المفاضلة مع الاستضافة الذاتية. سعر API المنخفض جذاب، لكنه عائق أمام المؤسسات التي لديها متطلبات سيادة البيانات والامتثال التنظيمي والنشر داخل المنشأة (on-premise) بسبب التبعية. تقدّم ai-platform التابعة لـThaki Cloud نماذج مفتوحة الأوزان (open-weight) تُخدَّم في بيئتها الخاصة اعتماداً على K8s وKueue، مما يتيح تشغيل مسارات عمل الوكلاء دون إخراج البيانات إلى الخارج. الجمع بين "الذكاء لكل رمز" والخدمة الفعالة الذي أظهره Grok 4.5 يطرح على معسكر الاستضافة الذاتية تحدياً في الاتجاه نفسه: للمنافسة مع واجهات برمجة التطبيقات السحابية الرخيصة، لا بد من تحقيق كفاءة في الرموز وتكلفة خدمة منخفضة أيضاً على مستوى المنشأة. وهذا يتقاطع تماماً مع توجهنا الذي يجعل من انخفاض تكلفة الخدمة ميزة تنافسية.

## القيود وحجج مضادة

عند تقييم هذا الإعلان، ينبغي التحفظ على عدة نقاط. أولاً، يستند جزء كبير من ادعاءات الأداء إلى إعلانات الشركة نفسها. تعبيرات مثل "بمستوى Opus" أو "يتفوق على النماذج المماثلة" من الأسلم التعامل معها كتسويق إلى أن يجري التحقق منها بشكل مستقل عبر نتائج قياسية (benchmarks) مستقلة. والتفوق الفعلي في مهام البرمجة والوكلاء يختلف بشكل كبير باختلاف عبء عمل كل مستخدم.

ثانياً، لا تعني القدرة التنافسية في السعر أنه الخيار الأفضل بالضرورة. يأتي السعر المنخفض مصحوباً بمخاطر التبعية للمزود وانتقال البيانات والتوافر. توجد قيود إقليمية وتنظيمية فعلية، مثل عدم التوفر في الاتحاد الأوروبي، ويمكن أن تشكل هذه القيود عائقاً حاسماً في مجالات تكون فيها سيادة البيانات أساسية، كالقطاع العام والمالي المحلي. واتخاذ قرار التبني بناءً على الأداء والسعر فقط قد يضطر المؤسسة لاحقاً إلى التراجع عند مواجهة متطلبات تنظيمية أو حوكمية.

أخيراً، الحقائق الواردة في هذا المقال هي تجميع للتقارير المنشورة وإعلانات الشركة. ينبغي التحقق من الأرقام التفصيلية للنتائج القياسية أو تفاصيل التدريب الدقيقة من المصادر الأصلية مباشرة، وقد تتغير الصورة مع تراكم التقييمات المستقلة بمرور الوقت.

## المصادر

- [Axios, "Scoop: SpaceXAI launches new model, Grok 4.5"](https://www.axios.com/2026/07/08/spacexai-grok-new-model)
- [TechCrunch, "SpaceXAI releases Grok 4.5, which Elon describes as an 'Opus-class model'"](https://techcrunch.com/2026/07/08/spacexai-releases-grok-4-5-which-elon-describes-as-an-opus-class-model/)
- [The Decoder, "Grok 4.5 is so cheap compared to Fable 5 and GPT 5.5 that benchmark gaps may not matter much"](https://the-decoder.com/grok-4-5-is-so-cheap-compared-to-fable-5-and-gpt-5-5-that-benchmark-gaps-may-not-matter-much/)
