---
title: "يؤدي أفضل بعد إزالة الأمثلة: القواعد الجديدة لهندسة السياق لأحدث النماذج"
seo_title: "ماذا يعلّمنا خفض موجّه نظام Claude Code بنسبة 80% | القواعد الجديدة لهندسة السياق | ThakiCloud"
seo_description: "خفضت Anthropic موجّه نظام Claude Code بأكثر من 80% لأحدث جيل من النماذج. كلما كان النموذج أذكى، أدى أفضل حين تُزيل الأمثلة وقوائم المنع. نشرح لماذا تصبح الأمثلة قيداً الآن، وكيف تُعيد كتابة موجّه النظام، وماذا يعني ذلك لتجهيز مهارات ThakiCloud."
excerpt: "كلما ازداد النموذج ذكاءً، صارت الأمثلة وقوائم المنع قيداً بدل أن تكون عوناً. نتناول لماذا خفضت Anthropic موجّه نظامها بنسبة 80% ولماذا يجب أن تُعيد تشذيب موجّهك مع كل نموذج جديد."
date: 2026-07-25
tags:
  - 컨텍스트 엔지니어링
  - 프롬프트 엔지니어링
  - 시스템 프롬프트
  - Claude Code
  - 에이전트 하네스
  - LLM
  - 프롬프트 설계
  - 베스트 프랙티스
  - 개발 생산성
  - AI 코딩
categories: [tutorials]
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/context-engineering-smaller-system-prompts/"
---

إن كنت تكتب موجّهات النظام وتصونها بنفسك، فقد شعرت على الأرجح في وقت ما أن النتائج تتحسن كلما حشوت مزيداً من الأمثلة والقواعد. غير أن الاتجاه الذي شاركته Anthropic مؤخراً يقلب ذلك الحدس رأساً على عقب. الخلاصة أولاً: متى صار النموذج ذكياً بما يكفي، تصبح الأمثلة وقواعد المنع لا عوناً بل قيداً يقتطع من الأداء فعلاً، ولذا فالممارسة الفضلى الجديدة هي الحذف من الموجّه لا الإضافة إليه. طبّقت Anthropic هذا المبدأ ذاته على منتجها فخفضت موجّه نظام Claude Code بأكثر من 80%. يعرض هذا المقال لماذا حدث ذلك وكيف يجب أن نُعيد كتابة موجّهاتنا.

## لماذا تقرأ هذا

هذا المقال موجّه للمطورين الذين يصممون موجّهات النظام ويصونونها، ولمسؤولي المنصات الذين يُشغّلون تجهيز وكيل. الخلاصة الجوهرية: عند التعامل مع أحدث جيل من النماذج، تحصل على نتائج أفضل بنقل السياق الموجز للنتيجة التي تريدها فقط وترك الباقي لحكم النموذج، بدلاً من إرفاق أمثلة وإطالة قوائم "لا تفعل هذا ولا تفعل ذاك". معرفة هذا تتيح لك كسر عادة توريث الموجّه مع كل نموذج جديد ومواصلة الإضافة إليه، وجعل تشذيب الموجّه بنداً دورياً في قائمة الفحص.

## نظرة عامة

خلال السنوات القليلة الماضية كانت حكمة هندسة الموجّهات الشائعة "كن محدداً وكن وافراً". إرفاق مثالين أو ثلاثة للمخرَج المطلوب، وتعداد ما لا يُفعل، وتثبيت الصيغة، كانت تُعدّ طريق النتائج المستقرة. وللجيل السابق من النماذج نجح هذا النهج جيداً، لأن الإنسان كان يملأ بالأمثلة والقواعد الفجوات التي لم يستطع النموذج ملأها بنفسه.

لكن مع ازدياد ذكاء النماذج عبر الأجيال، تقلصت تلك الفجوات. شذّبت Anthropic موجّه نظام Claude Code بأكثر من 80% لأحدث جيل من النماذج وأفادت بعدم وجود انخفاض قابل للقياس في تقييمات البرمجة. حتى بعد إزالة كمّ كبير من الأمثلة والقواعد، لم تسوأ النتائج. وفي بعض الحالات كان التشخيص أن الأمثلة كانت تحبس النموذج في قالب معيّن وتحجب إجابة أفضل.

## لماذا تصبح الأمثلة قيداً

جوهر تفسير Anthropic بسيط. كلما ازداد النموذج ذكاءً، احتاج تعليمات أقل وقيوداً أقل وأمثلة أقل. حين تُرفق مثالاً، يقرؤه النموذج على أنه "إذن هذا هو الشكل الذي تريده" ويوائم نفسه مع ذلك الشكل. تنشأ المشكلة حين يكون أحدث نموذج أكثر إبداعاً من ذلك المثال. يصير المثال سقفاً يجرّ إجابة النموذج الأفضل إلى الأسفل.

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
<div class="d3-arch" data-arch-root id="ringsmallersystemprompts-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 732, "height": 616, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 140, "y": 24, "w": 177, "h": 78, "title": ["نهج الجيل القديم", "3 أمثلة + قائمة منع +", "صيغة صارمة"]}, {"id": "B", "x": 152, "y": 193, "w": 153, "h": 68, "title": ["عند تطبيقه على", "نموذج أحدث جيل؟"]}, {"id": "C", "x": 256, "y": 366, "w": 177, "h": 78, "title": ["النموذج محبوس في قالب", "المثال", "تُحجب إجابة أفضل"]}, {"id": "D", "x": 24, "y": 374, "w": 177, "h": 62, "title": ["القواعد السلبية", "تقتطع من جودة النتيجة"]}, {"id": "E", "x": 492, "y": 180, "w": 205, "h": 94, "title": ["نهج الجيل الجديد", "السياق المطلوب بإيجاز فقط", "+", "الحكم متروك للنموذج"]}, {"id": "F", "x": 488, "y": 374, "w": 212, "h": 62, "title": ["النموذج يولّد مخرجه الأمثل", "ليلائم السياق"]}, {"id": "G", "x": 239, "y": 522, "w": 212, "h": 62, "title": ["شذّب الموجّه", "أعد الفحص مع كل نموذج جديد"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [229, 102, 229, 193]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"الأمثلة تحدّ الإبداع\"", "curve": [[271, 261], [345, 320], [345, 320], [345, 366]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "\"قوائم المنع تخفض الجودة\"", "curve": [[186, 261], [113, 320], [113, 320], [113, 374]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [594, 274, 594, 374]}, {"src": "C", "dst": "G", "kind": "data", "line": [345, 444, 345, 522]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[113, 436], [113, 483], [113, 483], [242, 522]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[594, 436], [594, 483], [594, 483], [451, 523]]}]});
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
      const container = document.getElementById('ringsmallersystemprompts-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ringsmallersystemprompts-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

تحمل قواعد المنع فخاً مشابهاً. تعداد "لا تفعل هذا ولا تفعل ذاك" مطوّلاً قد يخفض جودة النتيجة فعلاً على أحدث النماذج. تقول Anthropic الآن إنها توجّه النماذج نحو الاتجاه المرغوب عبر السياق بدل حجبها بقواعد منع صارمة. بدل بناء جدران بالقواعد، تعطي سياق ما تريد وتترك النموذج يحكم داخله.

لذا حين يصل نموذج جديد، النصيحة هي تشذيب الموجّه لا إطالته. كثير من الأمثلة والقواعد المتراكمة للنموذج السابق هي، للنموذج الجديد، عبء غير ضروري، أو، أسوأ، قيد يقتطع من الأداء.

## هذا لا يعني رمي كل قاعدة

هنا يجب ملاحظة توازن مهم. هذه النصيحة تخص التعامل مع أقوى وأحدث جيل من النماذج. أما لمستويات نماذج أرخص، أو لعمل الدفعات حيث يجب أن تكون صيغة المخرَج نفسها تماماً في كل استدعاء، فالقصة مختلفة. في المخرجات المجدولة التي يجب ألا يتذبذب شكلها، كتقرير يجب أن يخرج بالشكل نفسه كل يوم، أو عقد JSON، لا يزال الهيكل الحتمي مطلوباً.

داخل ThakiCloud نتعامل مع هذين المحورين على حدة. في العمل الذي يكون إبداع المحتوى فيه هو المُخرَج، نعطي النموذج القوي سياقاً فقط ونوسّع درجات حريته؛ لكن الأرقام والقيم المعدودة وصيغة العرض تملكها شيفرة حتمية لا النموذج. أي إن نصيحة إزالة الأمثلة ونظام تثبيت الصيغة بالشيفرة لا يتعارضان. الأول مجال الحكم والإبداع؛ والثاني مجال الصيغة والتجميع. اجمع الاثنين في موجّه واحد بلا تمييز، تحصل على أسوأ تركيبة: أمثلة تقيّد النموذج القوي وصيغة تتذبذب للضعيف.

## دلالات لمنتجات ThakiCloud

يقود هذا النقاش مباشرة إلى الممارسة من منظور Paxis لدينا. Paxis هو Agent-Native Cloud من ThakiCloud، مستوى تحكّم يتعامل مع Skills وTools وPolicies كموارد من الدرجة الأولى. يختار من أكثر من 960 مهارة عبر BM25 ويشغّلها في صناديق رمل معزولة. هنا، مواصفة كل مهارة وموجّه نظامها هما بالضبط موضوع هندسة السياق التي يصفها هذا المقال.

نقل درس هذا المقال إلى تجهيز مهارات Paxis يعطي ممارستين. أولاً، في المهارات التي تتعامل مع نماذج قوية، قلّل الأمثلة وقوائم المنع واترك السياق الموجز وحدود النتيجة المرجوة فقط. أبقِ التجهيز رفيعاً والمعرفة كثيفة، لكن اجعل تلك المعرفة مجموعة معايير حكم مستخلصة من الإخفاقات، لا استعراضاً للأمثلة. ثانياً، عند إدخال نموذج جديد، لا تورّث مواصفات المهارات تلقائياً وتواصل الإضافة؛ بل شغّل فحصاً يشذّب الأمثلة والقواعد التي صارت غير ضرورية. هذا هو المعنى نفسه لنصيحة Anthropic بتشذيب الموجّه مع كل نموذج جديد.

ثمة مكسب من عدسة البنية التحتية ai-platform أيضاً. موجّه نظام أقصر يعني رموز إدخال أقل لكل استدعاء، ما يُترجم مباشرة إلى توفير في التكلفة في بيئة خدمة متعددة المستأجرين قائمة على K8s. تشذيب الموجّه عمل نادر يحسّن الجودة والتكلفة في آنٍ.

## القيود والحجج المضادة

قبول هذه النصيحة دون نقد خطر. أولاً، "أزل الأمثلة" مقيّد بالنماذج القوية الأحدث ولا ينتقل كما هو إلى النماذج الأدنى قدرة أو إلى العمل ذي متطلبات الصيغة الصارمة. ثانياً، ما إذا كان الأداء يصمد فعلاً بعد إزالة الأمثلة يجب تأكيده بالتقييم. تقرير Anthropic بعدم انخفاض تقييمات البرمجة كان بذاته نتيجة مقيسة، لا قراراً اتُّخذ بالحدس وحده. تجاوز التقييم أثناء تقليص الموجّه، وقد تفوتك انخفاضات جودة غير مرئية. ثالثاً، يستند هذا الاتجاه إلى خصائص عائلة نماذج بعينها، لذا لا يمكن الجزم بأن الهامش نفسه يصمد لنماذج بائعين آخرين أو لنماذج مفتوحة الأوزان.

## الخلاصة

اختصاراً في جملة واحدة، القاعدة الجديدة لهندسة السياق هي: عند التعامل مع أحدث النماذج، لا تحاول ملء الموجّه بإطالته؛ شذّبه واترك الأمر لحكم النموذج. كانت الأمثلة وقوائم المنع شبكة أمان للجيل السابق، لكنها لهذا الجيل قد تكون سقفاً يحجب إجابة أفضل. مع ذلك، هذه النصيحة مقيّدة بالنماذج القوية ومجال الإبداع؛ وللعمل الذي يجب ألا تتذبذب صيغته، لا يزال الهيكل الحتمي مطلوباً. في المرة القادمة التي تُدخل فيها نموذجاً جديداً، قبل أن تقلق بشأن ما تضيفه إلى الموجّه، افحص أولاً ما يمكنك إزالته. وبعد الإزالة، أكّد دائماً بالتقييم. هكذا تجعل هذا التحول لك، بأمان.

## المصادر

- The new rules of context engineering for Claude 5 generation models، Anthropic (<https://claude.com/blog/the-new-rules-of-context-engineering-for-claude-5-generation-models>)
- A Fireside Chat with Cat and Thariq from the Claude Code team، Simon Willison (<https://simonwillison.net/2026/Jul/21/cat-and-thariq/>)
