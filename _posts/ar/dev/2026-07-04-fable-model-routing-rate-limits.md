---
title: "العمل دون حدود معدّل على Fable 5: توجيه النماذج واستراتيجية ميزانية الرموز"
excerpt: "نحلّل نصائح سير العمل مع Claude Fable 5 التي شاركها Theo مبتكر T3: مستويات الجهد، وتنسيق Codex، وأولوية النماذج في CLAUDE.md، وإسناد المهام كثيفة الرموز. ونضعها بجانب انضباط توجيه النماذج الذي تستخدمه ThakiCloud بالفعل عبر Paxis وai-platform."
tags:
  - claude-code
  - model-routing
  - cost-optimization
  - agent-native
  - paxis
date: 2026-07-04
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/fable-model-routing-rate-limits/"
categories:
  - dev
---

![صورة تجريدية لتدفقات معالجة بأحجام متعددة تتجمع في عقدة قائد واحدة ثم تتفرّع من جديد]({{ '/assets/images/fable-model-routing-rate-limits-hero.webp' | relative_url }})
*تصوير للتوجيه، حيث يتدفّق العمل الثقيل والخفيف إلى نماذج مختلفة.*

## نظرة عامة

الإمساك بنموذج برمجة واحد قوي وإلقاء كل مهمة عليه أمر مريح. المشكلة أن هذه الراحة تعود على شكل فاتورة ميزانية رموز وحدود معدّل. إذا استخدمت النموذج الأغلى حتى لأبسط المهام، فستنفد حصتك بحلول الوقت الذي تحتاج فيه فعلاً إلى استدلال صعب.

في أوائل يوليو 2026، شارك Theo مبتكر حزمة T3 كيف يشغّل Claude Fable 5 طوال اليوم دون بلوغ حدود المعدّل. الفكرة بسيطة. بدلاً من تكديس كل شيء على نموذج واحد، قسّم النموذج والجهد بحسب طبيعة العمل. في هذه المقالة نستعرض استراتيجياته الأربع مع اقتباسات حقيقية، ونضعها بجانب انضباط توجيه النماذج الذي تطبّقه ThakiCloud بالفعل في تشغيل Paxis وai-platform.

سبب الأهمية واضح. في عصر تعمل فيه الوكلاء بشكل مستقل لفترة طويلة، فإن كيفية تصميم تدفّق الرموز عبر الجلسة كاملة، لا جودة استدعاء نموذج واحد، هي ما يحدّد الإنتاجية والتكلفة الحقيقية.

## المشكلة: حدود المعدّل مسألة تخصيص لا جودة

المستخدمون الذين يبلغون حدود المعدّل غالباً ما يفعلون ذلك لا لأن النموذج ضعيف بل لأن تخصيصهم أخرق. إذا شغّلت نموذج الطبقة العليا بأعلى جهد حتى لعمل منخفض الصعوبة مثل قراءة ملف واحد أو grep بسيط أو تلخيص سجل، فإن الرموز تحترق لا خطياً بل أسّياً. ورموز التفكير على وجه الخصوص تتراكم بشكل غير مرئي.

الرؤية الأساسية هي هذه. أفضل نموذج مورد محدود، وتحديد أين تنفقه هو بالضبط ما يعنيه التوجيه. نصائح Theo الأربع كلها المبدأ نفسه مطبَّقاً من زوايا مختلفة.

## استراتيجيات Theo الأربع

### 1. اجعل الجهد الافتراضي high واحتفظ بـ xhigh وmax

يقول Theo إنه يستخدم Fable على جهد "high" فقط في الوقت الحالي. بكلماته، xhigh "نهم للرموز"، وmax وextra هما "فرن بمخرجات أسوأ من الخيارات الأدنى".

الدرس هنا أن رفع الجهد لا يرفع الجودة بشكل مطّرد. مع نمو رموز التفكير، قد يصبح المخرج مشتتاً أو يسلك التفافات مفرطة. لمعظم العمل العملي، high هو نقطة التوازن بين الجودة والتكلفة. احتفظ بـ xhigh وmax للمراحل التي تحتاج فعلاً إلى استدلال عميق.

### 2. نسّق Codex كمنفّذ فرعي

الاستراتيجية الثانية هي جعل النماذج طبقات. علّم Theo نظام Claude Code أن يستدعي Codex (GPT-5.5) كمنفّذ فرعي لعمل التنفيذ. وبحسب ملاحظته، فإن GPT-5.5 قابل للتوجيه بدرجة عالية، لذا يستطيع Fable تعلّم كيفية توجيهه.

بعبارة أخرى، يعمل Fable كقائد يتولّى الحكم والتفرّع، بينما يُسنَد التنفيذ المتكرر عالي الحجم إلى منفّذ أرخص. بهذه الطريقة ينفق نموذج القائد الغالي رموزه على الحكم، ويخرج حجم التنفيذ من ميزانية أخرى.

### 3. أعلن أولوية النماذج في CLAUDE.md

الثالثة هي تصليب هذا التوجيه كعقد لا كارتجال. كتب Theo قسماً كبيراً في ملف CLAUDE.md حول أي نموذج يُقدَّم لأي عمل، وكيفية التخصيص عند تنسيق الوكلاء الفرعيين وسير العمل.

هذه النقطة مهمة بخاصة. إذا رسّخت قواعد التوجيه في مستند، فلن تضطر إلى القرار من جديد كل جلسة، ويشترك الفريق كله في انضباط التخصيص نفسه. تحويل موجّه متكرر إلى قاعدة مبدأ أساسي من مبادئ نظافة الموجّهات.

### 4. أسنِد العمل كثيف الرموز واستردّ النتائج فقط

أخيراً، يشغّل Theo المهام كثيفة الرموز (استخدام الحاسوب، تحليل قاعدة الشيفرة الكامل ونحوها) بنماذج أخرى، ثم يجعل النتيجة فقط تُبلَّغ إلى Fable.

هذا يرتبط مباشرة بنظافة السياق الرئيسي. إذا صببت مخرَج استكشاف كبير مباشرة في سياق نموذج القائد، فإن كلفة إعادة قراءة ذلك السياق الكبير في كل دور لاحق تنمو خطياً. إذا تولّى منفّذ فرعي القراءة الثقيلة ومرّر ملخّصاً فقط، بقي سياق نموذج القائد نظيفاً.

مرسومة كتدفّق واحد، تبدو الاستراتيجيات الأربع هكذا.

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
<div class="d3-arch" data-arch-root id="lemodelroutingratelimits-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 602, "height": 916, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 260, "y": 24, "w": 120, "h": 46, "title": "وصول المهمة"}, {"id": "B", "x": 240, "y": 148, "w": 160, "h": 52, "title": "تصنيف نوع المهمة"}, {"id": "C", "x": 228, "y": 430, "w": 184, "h": 46, "title": "Fable 5 قائد بجهد high"}, {"id": "D", "x": 242, "y": 292, "w": 156, "h": 46, "title": "منفّذ منخفض الكلفة"}, {"id": "E", "x": 24, "y": 292, "w": 163, "h": 46, "title": "Codex GPT-5.5 منفّذ"}, {"id": "F", "x": 223, "y": 554, "w": 195, "h": 52, "title": "هل يلزم استدلال عميق؟"}, {"id": "G", "x": 323, "y": 698, "w": 177, "h": 62, "title": ["الترقية إلى xhigh max", "باعتدال"]}, {"id": "H", "x": 126, "y": 706, "w": 142, "h": 46, "title": "الإبقاء على high"}, {"id": "I", "x": 260, "y": 838, "w": 121, "h": 46, "title": "تركيب النتائج"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [320, 70, 320, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "الحكم التفرّع التنسيق", "curve": [[386, 200], [503, 246], [503, 384], [381, 430]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "البحث grep قراءة الملفات", "line": [320, 200, 320, 292], "lx": 320, "ly": 242}, {"src": "B", "dst": "E", "kind": "data", "label": "التنفيذ بالجملة", "curve": [[243, 200], [106, 246], [106, 246], [106, 292]], "off": "50%"}, {"src": "D", "dst": "C", "kind": "data", "label": "إعادة الملخّص فقط", "line": [320, 338, 320, 430], "lx": 320, "ly": 380}, {"src": "E", "dst": "C", "kind": "data", "label": "إعادة المنتَج", "curve": [[106, 338], [106, 384], [106, 384], [249, 430]], "off": "50%"}, {"src": "C", "dst": "F", "kind": "data", "line": [320, 476, 320, 554]}, {"src": "F", "dst": "G", "kind": "data", "label": "نعم", "curve": [[353, 606], [411, 652], [411, 652], [411, 698]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "label": "لا", "curve": [[276, 606], [197, 652], [197, 652], [197, 706]], "off": "50%"}, {"src": "G", "dst": "I", "kind": "data", "curve": [[411, 760], [411, 799], [411, 799], [354, 838]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[197, 752], [197, 799], [197, 799], [274, 838]]}]});
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
      const container = document.getElementById('lemodelroutingratelimits-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lemodelroutingratelimits-1';
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

## دلالات لمنتجات ThakiCloud

تُقرأ نصائح Theo كتأكيد مرحّب به لأن منصة الوكلاء Paxis من ThakiCloud تقف بالفعل على المبدأ نفسه. Paxis هي مستوى تحكّم Agent-Native Cloud يعمل فوق ai-platform، ويتعامل مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. وضمنها، توجيه النماذج ليس زينة بل عمود التكلفة الفقري.

انضباط توجيه الوكلاء الفرعيين لدينا يستهدف الغاية نفسها التي تستهدفها استراتيجية Theo الرابعة. يذهب الاستكشاف وقراءة الملفات إلى الطبقة الأرخص، والتنفيذ والمراجعة إلى الطبقة الوسطى، وتذهب فقط الهندسة المعمارية والاستدلال المعقّد متعدد الخطوات إلى الطبقة العليا. لا يدفع الوكلاء الفرعيون المخرجات الكبيرة الخام إلى الأعلى بل يعيدون ملخّصاً ومسارات ملفات فقط. قاعدة إبقاء سياق نموذج القائد نظيفاً هي الممارسة نفسها التي وصفها Theo بـ "بلّغ النتائج فقط".

الاستراتيجية الثانية لفصل القائد عن المنفّذ تلامس أيضاً تصميم Paxis. يختار مِهاز مهارات Paxis من أكثر من 960 مهارة بواسطة BM25 ويشغّلها في صناديق رمل معزولة، حيث تتولّى طبقة التنسيق الحكم الخفيف فقط ويُعزَل التنفيذ الثقيل إلى عمّال منفصلين. استخدام نموذج الحكم الغالي للتوجيه والتركيب فقط، ووضع العمل الثقيل الفعلي على عمّال أرخص، هو الصورة نفسها التي جعل فيها Theo نموذج Fable قائداً وCodex منفّذاً.

الاستراتيجية الثالثة، تصليب التوجيه في مستندات وسياسة، تُنفَّذ في Paxis كبوّابات سياسة وسجلات تدقيق. حين تثبّت أي عمل ينبغي أن يتدفّق إلى أي مورد كقاعدة صريحة لا كحكم ارتجالي، لا يتذبذب انضباط التخصيص حتى مع عمل وكيل مستقل لفترة طويلة.

في طبقة البنية التحتية، تعمل عدسة ai-platform جنباً إلى جنب. عند خدمة النماذج على وحدات معالجة رسومية قائمة على K8s وKueue، فإن تدفّق الطلبات منخفضة الصعوبة إلى نماذج صغيرة بأولوية دفعات منخفضة يوفّر وقت وحدة المعالجة، وهذا التوفير يعود إلى اقتصاديات الوكلاء. الكلفة الأدنى للخدمة تخلق هامشاً يحتمل توجيهاً أكثر جرأة. باختصار، الخدمة منخفضة الكلفة (ai-platform) تسند اقتصاديات تنسيق الوكلاء (Paxis).

## القيود والاعتراضات

لهذا النهج نقاط ضعف أيضاً. أولاً، مع نمو تعقيد التوجيه، تظهر كلفة إدارة. نسج عدة نماذج معاً يعني أن لكل منها نافذة سياق وسعراً وتوافراً مختلفاً، ما يصعّب التنقيح. إذا أساء القائد قراءة مخرَج المنفّذ، تزداد الرحلات ذهاباً وإياباً وينتهي الأمر بإنفاق رموز أكثر.

ثانياً، "high هو الأفضل دائماً" ملاحظة شخصية من Theo وتتفاوت بحسب نوع المهمة. للأحكام المعمارية الصعبة حقاً أو تعقّب العلل الدقيق، يستحق الجهد الأعلى كلفته. القاعدة مجرد افتراضي، والعين للحكم على الاستثناءات ما زالت مطلوبة.

ثالثاً، التنسيق الذي يمزج نماذج من موردين مختلفين يوسّع تدفّق البيانات وحدود الأمان. حين تسلّم تحليل قاعدة الشيفرة إلى منفّذ خارجي، يجب أن تتحكّم بالضبط فيما يدخل سياق ذلك النموذج. لهذا بالضبط تمرّر Paxis كل فعل عبر بوّابات سياسة وسجلات تدقيق.

في الختام، حدود المعدّل ليست مشكلة تُدفَع بخطة أغلى بل تُحلّ بالتخصيص. ابدأ رخيصاً، واستخدم النموذج الغالي للحكم الثقيل فقط، وصلّب تلك القاعدة في مستندات وسياسة. هذا هو الاتجاه الذي تشير إليه نصائح Theo الأربع جميعها، والانضباط الذي تمارسه ThakiCloud كل يوم على Paxis.

## المصادر

- Theo (@theo)، "I've been getting a TON done with Fable today and I'm not hitting rate limits": [x.com/theo/status/2072481845363822914](https://x.com/theo/status/2072481845363822914)
- "T3 Stack creator Theo shares Fable AI workflow"، digg.com: [digg.com/tech/wmowks0x](https://digg.com/tech/wmowks0x)
- "Fable Is Back. Here's How to Actually Code With It"، Wavect: [wavect.io/blog/coding-with-claude-fable-5](https://wavect.io/blog/coding-with-claude-fable-5/)
