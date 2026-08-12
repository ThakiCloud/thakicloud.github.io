---
title: "تقييم الوكلاء الذين يحوّلون قواعد التصميم إلى نصوص تحقق عبر التنفيذ: معيار Rule2DRC"
seo_title: "Rule2DRC: معيار قائم على التنفيذ لوكلاء LLM في فحص DRC للرقائق | ThakiCloud"
seo_description: "يقيّم Rule2DRC وكلاء LLM الذين يترجمون قواعد التصميم بلغة طبيعية إلى نصوص DRC قابلة للتنفيذ عبر تشغيلها في KLayout، لا عبر تشابه الشيفرة. يضم 1000 قاعدة و13921 تخطيطًا ويقيس الصحة الوظيفية دون إعطاء الوكيل تخطيطات الإجابة. كما أطلقت جامعة سيول الوطنية ومركز سامسونج للذكاء الاصطناعي تطبيق واجهة رسومية للنشر داخل الشبكة الداخلية."
excerpt: "المهم ليس الشيفرة التي تبدو معقولة بل الشيفرة التي تنجح فعليًا. نستعرض Rule2DRC كحالة ملموسة لوكلاء متخصصين يحلّون محل التحقق اليدوي الخبير في EDA داخل بيئة منظّمة وآمنة."
date: 2026-07-23
tags:
  - DRC
  - التحقق من التصميم
  - EDA
  - أشباه الموصلات
  - وكيل LLM
  - التقييم القائم على التنفيذ
  - معيار
  - وكيل متخصص
  - داخل المؤسسة
  - KLayout
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ar/research/rule2drc-drc-llm-agent-benchmark/"
---

إذا كنت مهندسًا يريد أتمتة التحقق من آلاف قواعد التصميم التي يجب أن تستوفيها الرقاقة قبل الإنتاج الكمي، فهذه المقالة لك. لنبدأ بالخلاصة. إن Rule2DRC (arXiv:2605.15669، من فريق البروفيسور هيون أوه سونغ في جامعة سيول الوطنية ومركز سامسونج للذكاء الاصطناعي، ICML 2026) هو معيار واسع النطاق يقيّم وكلاء LLM الذين يترجمون قواعد التصميم المكتوبة بلغة طبيعية إلى نصوص تحقق DRC قابلة للتنفيذ، عبر ما إذا كانت النصوص تعمل وتنجح فعليًا في محرك تحقق، لا عبر مدى تشابه الشيفرة مع مرجع. علاوة على ذلك، بنى الفريق تطبيق واجهة رسومية لوكيل يعمل على التخطيطات مباشرةً ويمكن نشره داخل الشبكة الداخلية الآمنة لسامسونج. وهو جدير بالمتابعة كإشارة إلى دخول الوكلاء المتخصصين إلى بيئات صناعية صارمة التنظيم والأمان.

![صورة تجريدية تصوّر تدفق قواعد التصميم بلغة طبيعية إلى شيفرة تحقق قابلة للتنفيذ](/assets/images/rule2drc-drc-llm-agent-benchmark-hero.webp)
*تصوير لأنماط شبكة التخطيط وهي تتدفق إلى منطق تحقق منظّم.*

## لماذا تقرأ هذا

هذه المقالة موجّهة للمهندسين الذين ينشرون وكلاء LLM متخصصين في بيئات منظّمة وآمنة، ولمسؤولي المنصات الراغبين في أتمتة أعمال متخصصة مثل التحقق في EDA وأشباه الموصلات عبر الوكلاء. السؤال الذي تواجهه هو: حين تسند عملًا للتحقق كان يتطلب خبيرًا إلى وكيل، كيف تثق أنه يؤديه بصورة صحيحة فعلًا؟ جواب Rule2DRC واضح. تُشغّل النصوص التي ينتجها الوكيل في محرك تحقق حقيقي وتقيّمها بالصحة الوظيفية. فالشيفرة التي تبدو معقولة والشيفرة التي تعمل فعلًا شيئان مختلفان، والصناعة تحتاج الثانية.

## نظرة عامة

قبل أن تدخل رقاقة أشباه الموصلات الإنتاج الكمي، يجب التحقق من استيفائها لآلاف قواعد التصميم الهندسية. يُسمّى هذا التحقق DRC أي فحص قواعد التصميم. المشكلة أن القواعد نفسها مكتوبة كوثائق بلغة طبيعية. فجملة مثل «يجب ألّا تقل المسافة الدنيا بين الأسلاك المعدنية عن قيمة معيّنة» يجب تحويلها إلى نص بلغة تحقق مخصّصة مثل KLayout أو SVRF قبل أن يتمكن المحرك من فحص التخطيط فعليًا.

هذه الترجمة ليست هيّنة. فمع كل تغيّر في عقدة التصنيع أو في المسبك، كان الخبراء يترجمون آلاف القواعد يدويًا إلى نصوص. ولأن العمل متكرر ويتطلب خبرة عميقة في آن واحد، جاءت محاولات أتمتته بوكلاء LLM بصورة طبيعية. الفكرة بناء وكيل يقرأ وثيقة قاعدة، ويولّد نص تحقق، بل ويصحّح أخطاءه عند وجودها.

تبيّن أن العنق الحقيقي للزجاجة هو تقييم الوكيل بصورة سليمة أكثر من بنائه. حملت المعايير السابقة قيدين. الأول أن مجموعات التقييم صغيرة. والثاني أنها تقيّم النصوص المولّدة بتشابهها مع شيفرة مرجعية لا بتشغيلها فعليًا. علاوة على ذلك، كثيرًا ما تطلبت الطرق السابقة التي استخدمت تغذية التنفيذ الراجعة تخطيطات الاختبار المرجعية كمدخل للوكيل من أجل التقييم. بينما في الواقع لا تُعطى لك مثل هذه التخطيطات.

## ما هو هذا المعيار

يواجه Rule2DRC هذين القيدين مباشرةً. إنه معيار واسع النطاق مكوّن من 1000 مهمة تحويل قاعدة إلى نص، و13921 تخطيط رقاقة لتقييم تلك النصوص. طريقة التقييم هي الجوهر. فهو يشغّل النصوص المولّدة بالذكاء الاصطناعي في محرك التحقق KLayout، ويقيس الصحة الوظيفية بمدى صحة فحصها للتخطيطات. ولا ينظر إلى ما إذا كانت الشيفرة تشبه مرجعًا.

اللافت أن تخطيطات الإجابة لا تُعطى للوكيل كمدخل. فالطرف المقيِّم يملك مخزونًا ضخمًا من تخطيطات التقييم، لكن على الوكيل كتابة النصوص من وثيقة القاعدة وحدها. وهذا يعيد إنتاج الموقف الواقعي بدقة. وهنا يفترق عن الأساليب السابقة التي أظهرت للوكيل مفتاح الإجابة مسبقًا ثم قيّمته.

يوضّح المخطط أدناه مسار التقييم في Rule2DRC.

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
<div class="d3-arch" data-arch-root id="2drcdrcllmagentbenchmark-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 463, "height": 832, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 39, "y": 24, "w": 191, "h": 62, "title": ["قاعدة تصميم بلغة طبيعية", "(وثيقة قاعدة التصنيع)"]}, {"id": "B", "x": 57, "y": 164, "w": 156, "h": 62, "title": ["وكيل LLM", "توليد النص وتصحيحه"]}, {"id": "C", "x": 67, "y": 304, "w": 135, "h": 62, "title": ["نصوص DRC مرشّحة", "(متعددة)"]}, {"id": "D", "x": 29, "y": 444, "w": 212, "h": 62, "title": ["SplitTester", "توليد حالات اختبار مميِّزة"]}, {"id": "E", "x": 136, "y": 598, "w": 170, "h": 62, "title": ["تنفيذ KLayout", "تقييم الصحة الوظيفية"]}, {"id": "F", "x": 147, "y": 738, "w": 149, "h": 62, "title": ["اختيار Best-of-N", "تحديد النص الأمثل"]}, {"id": "G", "x": 296, "y": 444, "w": 135, "h": 62, "title": ["تخطيطات التقييم", "13921"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [135, 86, 135, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [135, 226, 135, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [135, 366, 135, 444]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[170, 506], [221, 552], [221, 552], [221, 598]]}, {"src": "E", "dst": "F", "kind": "data", "line": [221, 660, 221, 738]}, {"src": "G", "dst": "E", "kind": "event", "label": "للتقييم فقط", "curve": [[363, 506], [363, 552], [363, 552], [279, 598]], "off": "50%"}, {"src": "E", "dst": "D", "kind": "event", "label": "تغذية التنفيذ الراجعة", "curve": [[169, 598], [91, 552], [91, 552], [117, 506]], "off": "50%"}]});
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
      const container = document.getElementById('2drcdrcllmagentbenchmark-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '2drcdrcllmagentbenchmark-1';
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

هنا تأتي المساهمة الثانية، SplitTester. فحين ينتج الوكيل عدة نصوص مرشّحة، يكون اختيار الأفضل أصعب مما يبدو، لأن المرشّحين كثيرًا ما يتصرفون بصورة متشابهة ويتعذّر تمييزهم ظاهريًا. وSplitTester وكيل اختبار يستخدم تغذية التنفيذ الراجعة لتوليد حالات اختبار مميِّزة بنفسه. فهو ينشئ اختبارات تجعل المرشّحين المتعذّر تمييزهم يعطون نتائج مختلفة، فيتضح أيّ مرشّح صحيح فعلًا. وفصل المرشّحين بهذه الطريقة يحسّن بوضوح أداء اختيار Best-of-N، أي مهمة انتقاء نص واحد من بين عدة.

في النتائج الكمية للورقة، كانت الفجوة بين النماذج المتقدمة والنماذج مفتوحة المصدر واضحة، وأدى إلحاق SplitTester إلى تحسين أداء اختيار المرشّحين. أما معدلات النجاح الدقيقة لكل نموذج فننصح بمراجعتها مباشرةً في جداول الورقة. قُبل المعيار في ICML 2026، وذُكر أنه نال جائزة البحث المتميّز وجائزة أفضل ملصق في ورشة NPRC بمركز سامسونج للذكاء الاصطناعي.

## لماذا يهم التقييم القائم على التنفيذ

الانتقال من التقييم بتشابه الشيفرة إلى التقييم القائم على التنفيذ هو مركز الثقل الحقيقي لهذا العمل. فتقييم التشابه يقيس «كم يشبه الإجابة»، والتقييم بالتنفيذ يقيس «هل ينجح فعلًا». والسؤالان مختلفان تمامًا. فالشيفرة التي تبدو مطابقة للإجابة قد تفشل عند تشغيلها، والشيفرة التي تبدو مختلفة تمامًا قد تعمل بإتقان. وما دام جوهر التحقق يكمن في «هل يلتقط مخالفات القواعد فعلًا»، فينبغي أن يتم التقييم بالتنفيذ أيضًا.

وهذا الاتجاه ليس قصة محصورة في تحقق أشباه الموصلات. فنموذج التقييم عبر وكلاء البرمجة عمومًا يتجه إلى المكان نفسه. إنه اتجاه التقييم بالنتائج القابلة للفحص الحتمي: شيفرة تجتاز الاختبارات، وشيفرة تعيد نقاط نهايتها الاستجابات المتوقعة، وشيفرة تترك الصفوف الصحيحة في قاعدة بيانات. فبدلًا من تصديق تقرير النموذج الذاتي بأنه «يبدو أنه نجح»، تدع نتيجة التنفيذ تصدر الحكم.

وما يجعل هذا العمل ذا مغزى خاص هو أنه لم يتوقف عند ذلك. فبالتكامل مع LLM داخلي في بيئة سامسونج الآمنة، بُني تطبيق واجهة رسومية يتعامل مع التخطيطات وشيفرة التحقق في شاشة واحدة. فتجاوز كونه معيارًا وورقة إلى أداة قابلة للنشر في الميدان. وهنا يمكنك قراءة الإشارة إلى أن الوكلاء المتخصصين يدخلون فعلًا صناعات صارمة التنظيم والأمان.

## دلالات على منتجات ThakiCloud

الصورة التي يرسمها Rule2DRC تتقاطع تمامًا مع ما تستهدفه ThakiCloud بمنتجيها. ولأن الموضوع هو تشغيل وكلاء متخصصين في بيئة معزولة أمنيًا، فإن عدسة Paxis مركزية وعدسة ai-platform تسندها.

من منظور الوكلاء، يتلقّى Paxis هذا الطلب مباشرةً. فـ Paxis هو مستوى التحكم Agent-Native Cloud من ThakiCloud الذي يعمل فوق ai-platform، ويتعامل مع Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. وحالة سامسونج المتمثلة في تطبيق واجهة رسومية يعمل على التخطيطات مباشرةً مع تكامل LLM داخلي هي تحديدًا نموذج Agent Builder والنشر داخل المؤسسة لدى Paxis. وعلى وجه الخصوص، يشترك التقييم القائم على التنفيذ في Rule2DRC في الفلسفة نفسها مع تصميم التحقق في Paxis. فحين يقيّم Paxis مهارة، فإنه يميل بالفعل إلى التقييم بنتائج التنفيذ الحتمية، أي التأكيدات وصفوف قاعدة البيانات ومخرجات نقاط النهاية، لا بالتشابه مع مرجع. وطريقة SplitTester في فصل المرشّحين بتغذية التنفيذ الراجعة لرفع Best-of-N جديرة بالاقتباس كمنطق يميّز به المقيِّم في منسّق الوكلاء المتعدد لدى Paxis المخرجات المرشّحة عبر نتائج تنفيذها.

من منظور البنية التحتية، تسند ai-platform هذه الصورة. فخدمة LLM داخلي كخلفية لوكيل تحقق تتطلب مكدس استدلال يعمل بثبات داخل المؤسسة. توفّر ai-platform خدمة vLLM وscale-to-zero فوق جدولة GPU المبنية على K8s وKueue، وتشغّل النماذج في بيئات معزولة متعددة المستأجرين. ولا يمكن لواجهة برمجة سحابية بنظام العدّ بالرمز أن تفي بمتطلبات العزل الشبكي مثل شبكة سامسونج الداخلية. فالاستدلال داخل المؤسسة الذي ينافس بتكلفة خدمة منخفضة هو ما يجعل اقتصاديات مثل هذه الوكلاء المتخصصة ممكنة. فالخدمة منخفضة التكلفة تفتح إمكانية تشغيل الوكلاء باستمرار، وفوق ذلك تتولى بوابات السياسات وسجلات التدقيق في Paxis مسؤولية الامتثال التنظيمي.

باختصار، هذه الحالة دليل على أن الصناعة تحتاج لا إلى روبوتات محادثة عامة بل إلى وكلاء متخصصين يعملون في بيئات معزولة أمنيًا. وSandbox Runtime ومستويات الاستقلالية وPolicy Engine وسجلات التدقيق داخل المؤسسة لدى Paxis تشير تحديدًا إلى هذا الطلب.

## القيود والاعتراضات

تجنّبًا للمبالغة في تقدير هذا العمل، أشير إلى الجانب الآخر. أولًا، مساهمة Rule2DRC الأساسية هي المعيار ومنهجية التقييم، لا الادعاء بأن أتمتة التحقق باتت مكتملة. فحتى النماذج المتقدمة لم تترجم كل قاعدة إلى نص بإتقان، ووجود فجوة يعني أيضًا أننا لسنا بعد في مرحلة إحلال الخبراء البشر.

ثانيًا، التقييم القائم على التنفيذ ممكن فقط حين يتوفر محرك التحقق وتخطيطات التقييم. أعدّ Rule2DRC 13921 تخطيطًا، لكن بناء مجموعة تقييم قابلة للتنفيذ بالحجم نفسه لعملية تصنيع جديدة أو مجال مختلف هو بحد ذاته كلفة كبيرة. فكون التقييم بالتنفيذ أصح من التقييم بالتشابه، وكون إعداد بيئة التنفيذ تلك ممكنًا بثمن زهيد في كل مكان، أمران منفصلان.

ثالثًا، ظهور تطبيق واجهة رسومية داخل المؤسسة، ومقدار ما قلّصه فعليًا من العمل اليدوي للخبراء في الممارسة، سؤالان مختلفان. فلا تزال هناك مسافة بين إثبات في مرحلة الورقة وموثوقية التشغيل الميداني، وما يجسر تلك المسافة ليس معيارًا بل بيانات تشغيل متراكمة عبر الزمن.

## الخلاصة

إذا اختصرنا رسالة Rule2DRC في جملة واحدة، فهي: ينبغي تقييم الوكلاء المتخصصين بالشيفرة التي تنجح فعلًا لا بالشيفرة التي تبدو معقولة، وفقط حين تستطيع تقييمهم بهذه الطريقة يمكنك نشرهم في بيئات منظّمة وآمنة. يمتد خيط واحد من معيار يقيّم العمل المتخصص لتحويل القواعد بلغة طبيعية إلى نصوص تنفيذ بنتائج التنفيذ حتى بلا تخطيطات إجابة، إلى SplitTester الذي يميّز المرشّحين فوق ذلك، إلى تطبيق واجهة رسومية داخل المؤسسة.

إذا كنت تصمّم وكيلًا متخصصًا، فالخطوة التالية واضحة. أنشئ أولًا بوابة تقيّم المخرجات بنتائج التنفيذ لا بالتشابه، وعند تعدّد المرشّحين ألحِق اختبارات مميِّزة تفصل بينهم. وتدمج ThakiCloud هذين بالفعل في الممارسة عبر المقيِّم في Paxis وخدمة الاستدلال داخل المؤسسة في ai-platform. إذا أردت أتمتة التحقق، فدَع التنفيذ يصدر الحكم.

## المصادر

- الورقة: [Rule2DRC (arXiv:2605.15669)](https://arxiv.org/abs/2605.15669)
- أخبار كلية الهندسة بجامعة سيول الوطنية: [SNU Engineering News](https://eng.snu.ac.kr/en/communication/promotion/news?md=v&bbsidx=8189&sc=y)
