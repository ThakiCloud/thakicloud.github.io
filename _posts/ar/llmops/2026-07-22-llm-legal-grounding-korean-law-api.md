---
title: "كيف تمنع نموذج LLM من اختلاق النصوص القانونية: تأريض الإجابات القانونية على واجهة National Law Open API الكورية"
excerpt: "حين تسأل ChatGPT أو Claude عن القانون قد تحصل أحياناً على نص قانوني معقول لكنه مختلق. المشكلة ليست في ذكاء النموذج بل في تصميم لا يربط الإجابة بنص مصدري موثّق. نشرح كيف تحوّل إجابات LLM القانونية إلى مخرجات مؤرّضة بالاستشهادات باستخدام واجهة National Law Information Open API الكورية، من منظور التشغيل والخدمة."
date: 2026-07-22
tags:
  - RAG
  - grounded-generation
  - legal-AI
  - LLM-hallucination
  - citations
  - national-law-data
  - LLMOps
  - on-prem
  - self-hosting
  - Paxis
author_profile: true
toc: true
toc_label: تأريض نماذج LLM القانونية
published: true
lang: ar
categories:
  - llmops
canonical_url: "https://thakicloud.github.io/ar/llmops/llm-legal-grounding-korean-law-api/"
---

![خط معالجة يربط الإجابات بنص مصدري موثّق](/assets/images/llm-legal-grounding-korean-law-api-hero.png)

## لماذا تقرأ هذا

كُتب هذا للمهندسين الذين يريدون ربط نموذج LLM بأسئلة قانونية أو تنظيمية، ولمسؤولي البنية التحتية الذين يتحملون مسؤولية جودة الإجابة في المجالات عالية المخاطر. الخلاصة أولاً: حين يختلق النموذج نصوصاً قانونية في استعلام قانوني فلن تحلّ المشكلة باستبدال نموذج أكبر. تُحل فقط بتصميم مؤرّض (RAG) يربط الإجابة بنص قانوني موثّق. اربط واجهة National Law Information Open API الكورية كمصدر مرجعي، فيستشهد النموذج بأرقام مواد وتواريخ نفاذ حقيقية بدلاً من اختلاقها.

## نظرة عامة

انتشرت نصيحة على منصات التواصل: إن أردت مساعدة قانونية من ChatGPT أو Claude لكنك تخشى أن يختلق نصوصاً، فزوّده ببيانات قانونية محلية. القلق له ما يبرره. في الولايات المتحدة رُفعت دعوى ضد OpenAI بتهمة السماح لـ ChatGPT بتقديم استشارة قانونية دون تدخل مختص مرخّص، ويحذّر الخبراء من أن مجرد مناقشة المسائل القانونية مع روبوت محادثة قد يكون محفوفاً بالمخاطر. النموذج مُحسَّن لإكمال النص بشكل معقول، ولا يستطيع بمفرده أن يمنع نفسه من كتابة مادة غير موجودة وكأنها حقيقية.

ومع ذلك يرسل السوق نفسه الإشارة المعاكسة أيضاً. في كوريا الجنوبية تجاوز Claude نموذج ChatGPT لأول مرة في سوق الذكاء الاصطناعي التوليدي المدفوع، وأعلنت شركة Law&Company القانونية الناشئة أن مساعدها القانوني SuperLawyer المدعوم بـ Claude وصل إلى 6,000 محامٍ، أي نحو 20% من المحامين الممارسين في البلاد، خلال 180 يوماً من الإطلاق. حين تُوصف التقنية نفسها بالخطورة من جهة وتترسّخ في الممارسة اليومية من جهة أخرى، فالفارق ليس في النموذج بل في التصميم الذي يتعامل مع الإجابة. يفكّك هذا المقال ذلك التصميم، أي خط المعالجة المؤرّض الذي يربط إجابة LLM القانونية بنص مصدري موثّق، متخذاً واجهة National Law Open API مثالاً.

## ما هذه التقنية

الفكرة الأساسية بسيطة. بدلاً من أن تسأل النموذج "هل تعرف ماذا يقول القانون"، تأمره بأن "يسترجع أولاً المواد ذات الصلة ثم يجيب مستنداً إلى ذلك النص المصدري فقط". يوفّر الاسترجاع المادة الخام للإجابة، ويتم التوليد داخل تلك المادة وحدها، ويحمل كل ادعاء استشهاداً على هيئة رقم مادة وتاريخ نفاذ. الفراغات التي كان النموذج يملؤها بالخيال تُستبدل بنص موثّق.

هنا تحدد موثوقية المادة كل شيء. قد يكون ملخص قانوني مأخوذ من أي صفحة ويب مادةً قبل التعديل أو مجهول المصدر. لذا يجب أن يكون المصدر المرجعي هو الأصل الرسمي. توفّر واجهة National Law Information Open API الكورية نصوص القوانين النافذة وأرقام المواد وتواريخ النفاذ وسجل التعديلات والجهة المختصة بصيغة مهيكلة. بل تتيح الاستعلام عن القوانين النافذة في تاريخ معيّن، فيمكنك الاستشهاد بـ"المادة النافذة الآن" منفصلة عن "المادة النافذة آنذاك". في الاستعلامات القانونية، تمييز تاريخ النفاذ ليس تفصيلاً هامشياً بل هو المحور الذي يفصل الإجابة الصحيحة عن الخاطئة.

التدفق الكامل، مرتّباً عمودياً:

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
<div class="d3-arch" data-arch-root id="galgroundingkoreanlawapi-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 349, "height": 1160, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q", "x": 33, "y": 24, "w": 205, "h": 62, "title": ["سؤال المستخدم", "مثال: سقف غرامة فسخ العقد"]}, {"id": "R", "x": 36, "y": 164, "w": 198, "h": 78, "title": ["تطبيع الاستعلام", "استخراج المسألة والكلمات", "المفتاحية"]}, {"id": "S", "x": 33, "y": 320, "w": 205, "h": 62, "title": ["National Law Open API", "البحث عن المواد ذات الصلة"]}, {"id": "F", "x": 126, "y": 460, "w": 184, "h": 78, "title": ["تصفية", "التحقق من تاريخ النفاذ", "والسريان الحالي"]}, {"id": "C", "x": 119, "y": 616, "w": 198, "h": 78, "title": ["تجميع السياق", "نص المادة + رقم المادة +", "تاريخ النفاذ"]}, {"id": "G", "x": 144, "y": 772, "w": 149, "h": 78, "title": ["توليد LLM", "الإجابة من المواد", "المقدَّمة فقط"]}, {"id": "V", "x": 33, "y": 928, "w": 205, "h": 62, "title": ["بوابة التحقق من الاستشهاد", "كل ادعاء يرتبط بمادة"]}, {"id": "A", "x": 29, "y": 1082, "w": 212, "h": 46, "title": "الإجابة + استشهادات المواد"}], "edges": [{"src": "Q", "dst": "R", "kind": "data", "line": [135, 86, 135, 164]}, {"src": "R", "dst": "S", "kind": "data", "line": [135, 242, 135, 320]}, {"src": "S", "dst": "F", "kind": "data", "curve": [[172, 382], [218, 421], [218, 421], [218, 460]]}, {"src": "F", "dst": "C", "kind": "data", "line": [218, 538, 218, 616]}, {"src": "C", "dst": "G", "kind": "data", "line": [218, 694, 218, 772]}, {"src": "G", "dst": "V", "kind": "data", "curve": [[218, 850], [218, 889], [218, 889], [172, 928]]}, {"src": "V", "dst": "S", "kind": "data", "label": "فشل الربط", "curve": [[99, 928], [53, 733], [53, 499], [99, 382]], "off": "50%"}, {"src": "V", "dst": "A", "kind": "data", "label": "نجاح الربط", "line": [135, 990, 135, 1082], "lx": 135, "ly": 1032}]});
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
      const container = document.getElementById('galgroundingkoreanlawapi-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'galgroundingkoreanlawapi-1';
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

الفارق عن النهج البسيط هو بوابة التحقق. يتوقف RAG البسيط عند لصق المستندات المسترجعة في المُوجّه وأخذ الإجابة. في مجال عالي المخاطر تضيف خطوة أخرى. يتحقق الكود مما إذا كان كل ادعاء قانوني في الإجابة المولّدة يرتبط بمادة استُرجعت فعلاً، وإن فشل ادعاء واحد في الربط فلن تُرسل تلك الإجابة إلى المستخدم أبداً. هذه البوابة هي الخط الأخير الذي يرشّح الجمل التي اختلقها النموذج خارج أدلته.

## التثبيت والتكامل

الخطوة الأولى في ربط المصدر المرجعي هي إصدار مفتاح واجهة. تسجّل في بوابة National Law Information (open.law.go.kr) وتحصل على مفتاح مصادقة. بعدها يتم البحث عن المواد وجلب النص الكامل عبر استدعاءات قائمة على URL، ويوفّر الدليل الرسمي أمثلة بعدة لغات منها Python وNode.js.

فيما يلي نمط أدنى يبحث في القوانين النافذة بكلمة مفتاحية للمسألة ثم يجمّع ذلك النص المصدري وحده كسياق. اعتبر دليل الاستخدام في البوابة مرجعاً لمخطط الاستجابة والمعاملات الفعلية.

```python
import requests

LAW_API = "https://www.law.go.kr/DRF/lawSearch.do"

def search_statutes(keyword: str, oc_key: str) -> list[dict]:
    """البحث في القوانين النافذة عبر National Law Open API. إرجاع المواد كمصدر مرجعي."""
    params = {
        "OC": oc_key,          # مفتاح المصادقة المُصدَر
        "target": "law",       # البحث في القوانين
        "type": "JSON",
        "query": keyword,
        "display": 5,
    }
    resp = requests.get(LAW_API, params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get("LawSearch", {}).get("law", [])

def build_context(hits: list[dict]) -> str:
    """تجميع المواد المسترجعة في سياق قابل للاستشهاد، مع حمل تاريخ النفاذ والجهة لإظهار الأساس."""
    lines = []
    for h in hits:
        lines.append(
            f"[{h.get('법령명한글')}] "
            f"effective {h.get('시행일자')}, agency {h.get('소관부처명')}\n"
            f"{h.get('법령상세링크')}"
        )
    return "\n\n".join(lines)
```

حين تحمّل هذا السياق في المُوجّه، اجعل التعليمة صريحة: "أجب من المواد المقدَّمة أدناه فقط، ولا تستشهد بمواد لم تُقدَّم، وإن لم توجد مادة ذات صلة فقل ذلك." التعليمة التي تجعل النموذج يقول "لا يوجد" عند غياب الأساس هي جوهر منع الهلوسة. تجعله يترك الفراغ بأمانة بدلاً من ملئه.

أخيراً تمتلك بوابة التحقق في الكود. تستخرج أرقام المواد المستشهد بها في الإجابة المولّدة وتقارنها بقائمة المواد المحمّلة فعلاً في السياق. إن استشهد بمادة ليست في القائمة، تعود تلك الإجابة إلى حلقة الاسترجاع. يجب أن يأتي هذا الحكم من كود حتمي لا من تقرير النموذج الذاتي كي يكون جديراً بالثقة.

## ما يغيّره التصميم المؤرّض

لم نجرِ قياساً خاصاً لإنتاج أرقام جديدة. بدلاً من ذلك يُظهر مؤشر تشغيلي منشور بالفعل أثر التصميم المؤرّض. يعمل SuperLawyer من Law&Company على Claude لكنه مصمَّم لربط الإجابات بالسوابق والقوانين، ووفقاً لحالة العميل التي نشرتها Anthropic فقد وصل إلى 6,000 محامٍ (نحو 20% من المحامين الممارسين في البلاد) خلال 180 يوماً من الإطلاق، بمعدل تحويل من المجاني إلى المدفوع 60.2%، ومعدل عودة في الشهر الثاني 79.1%، وتوفير تراكمي قدره 2.3 مليون ساعة في أول 180 يوماً. أن تحافظ أداة يتحقق منها المحترفون يومياً على هذا القدر من العودة يُقرأ كإشارة إلى أن الإجابات لم تكن معقولة فحسب بل جديرة بالثقة فعلاً.

على الجانب الآخر تقف كلفة ترك القانون يُجاب دون تأريض. دعوى OpenAI في الولايات المتحدة والتحذير من مناقشة المسائل القانونية مع روبوت محادثة يُظهران أن الإجابات القانونية غير المؤرّضة قد تتصاعد إلى مسائل مسؤولية قانونية. حتى مع النموذج نفسه، يفصل ربطه بنص مصدري أو عدمه بين النتيجتين بهذه الحدّة. الدرس الذي تعلّمه المؤشرات واضح: في مجال عالي المخاطر، الرافعة التي ترفع الجودة ليست فئة النموذج بل تصميم التأريض.

## ماذا يعني هذا لمنتجات ThakiCloud

يتلاءم هذا النمط طبيعياً مع منتجَي ThakiCloud.

من زاوية Paxis، الإجابة القانونية المؤرّضة هي عبء عمل نموذجي لـ Agent-Native Cloud. يعامل Paxis الـ Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. البحث القانوني هو Tool يُنفَّذ في صندوق رمل معزول، وبوابة التحقق من الاستشهاد هي Policy يجب أن تجتازها الإجابة قبل خروجها، وأيّ مواد أرّضت أيّ إجابة يُسجَّل في Audit Log. في مجال تهم فيه المساءلة، كالقانون، يجب أن تكون قادراً على تتبع سبب صدور الإجابة بعد وقوعها، وتوفّر بوابات السياسة وسجلات التدقيق هذا التتبع افتراضياً. إن جمعت بوابة التأريض التي تفرض استشهاداً على كل ادعاء في skill قابل لإعادة الاستخدام، أمكنك نقلها كما هي إلى مجالات أخرى عالية المخاطر تحتاج استشهادات مصدرية، كالطب والمال والامتثال التنظيمي.

وهناك زاوية ai-platform أيضاً. بيانات كالقوانين والسوابق قد تكون حساسة لإرسالها عبر واجهة خارجية أصلاً، وكثيراً ما تطالب الجهات العامة والتنظيمية بسيادة البيانات والخدمة داخل المنشأة. تخدم ai-platform من ThakiCloud النماذج بنمط متعدد المستأجرين على K8s وجدولة GPU المبنية على Kueue، وهي مصمَّمة لتشغيل المصدر المرجعي والنموذج معاً على بنيتك التحتية الخاصة. أبقِ البيانات القانونية داخلياً وشغّل الاسترجاع والتوليد فوقها، فتحفظ الدقة المؤرّضة وسيادة البيانات معاً. الكلفة المنخفضة للخدمة هي الشرط المسبق الذي يتيح تشغيل خط معالجة متخصص كهذا باستمرار.

## الحدود والاعتراضات

التصميم المؤرّض ليس دواءً شافياً لكل شيء. أولاً، إن لم يكن المصدر المرجعي محدّثاً فالإجابة خاطئة أيضاً. حتى لو عكست بيانات National Law التعديلات فوراً، فقد تستشهد لقطة قديمة خزّنها خط المعالجة بمادة مُلغاة. يجب أن تدعمها مرشّحات تاريخ النفاذ والمزامنة الدورية. ثانياً، الاستشهاد بمادة بدقة لا يضمن صحة تفسيرها. جوهر الاستشارة القانونية ليس البحث عن المادة بل تطبيقها على الوقائع، وذلك الحكم يبقى من اختصاص مختص مؤهل. ينبغي النظر إلى خط المعالجة هذا كأداة مساعِدة تبني مسودة فوق الأدلة، لا كبديل عن الخبير. ثالثاً، إن كانت بوابة التحقق تفحص ربط الاستشهاد فقط، فقد تمرّر إجابة تستشهد بالمادة صحيحاً لكنها تستدل خطأ. تحفظ البوابة الحد الأدنى ضد الهلوسة؛ ولا تضمن جودة الحجة.

## الخلاصة

حين ينتج نموذج LLM نصوصاً قانونية مختلقة على سؤال قانوني، فالمشكلة ليست حدّ النموذج بل فجوة في التصميم. اربط الإجابة بنص مصدري موثّق، واجعلها تقول "لا يوجد" حين لا يوجد أساس، وامتلك في الكود بوابة تفرض استشهاداً على كل ادعاء، فيقدّم النموذج نفسه مستوى ثقة مختلفاً تماماً. هنا بالضبط تكمن الفجوة بين أداة قانونية مدعومة بـ Claude ترسّخت في الممارسة في كوريا واستشارة روبوت محادثة غير مؤرّضة تصاعدت إلى دعوى قضائية. الخطوة التالية واضحة. إن كنت تربط نموذج LLM بمجال عالي المخاطر، فاوصل مصدراً مرجعياً موثوقاً كـ National Law Open API قبل أن تبحث عن نموذج أكبر، وأقم بوابة تحقق من الاستشهاد أولاً. الرافعة دائماً في جانب الأدلة.

## المصادر

- [بوابة National Law Information Open API](https://open.law.go.kr/LSO/openApi/guideList.do)
- [خدمة مشاركة National Law Information (بوابة البيانات العامة)](https://www.data.go.kr/data/15000115/openapi.do)
- [حالة عميل Anthropic: Law&Company](https://www.anthropic.com/customers/law-and-company)
- [KED Global: Claude يتجاوز ChatGPT في سوق الذكاء الاصطناعي التوليدي المدفوع بكوريا الجنوبية](https://www.kedglobal.com/artificial-intelligence/newsView/ked202604270002)
- [Forbes: دعوى ضد OpenAI بشأن الاستشارة القانونية](https://www.forbes.com/sites/lanceeliot/2026/03/09/landmark-lawsuit-against-openai-for-allowing-chatgpt-to-provide-legal-advice-could-be-a-huge-game-changer-for-all-ai-makers/)
