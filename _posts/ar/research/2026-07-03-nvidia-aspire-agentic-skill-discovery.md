---
title: "NVIDIA ASPIRE: روبوتات تحوّل الفشل إلى مهارات"
excerpt: "تتخلّص الروبوتات من محاولاتها وأخطائها في كل مرة تحلّ فيها مهمة، ثم تتعثّر من الصفر في المهمة التالية. نظام ASPIRE من NVIDIA نظام تعلّم مستمر يكتب فيه نموذج لغوي كبير كود تحكّم الروبوت مباشرةً، ويراقب حالات الفشل أثناء التنفيذ، ويصلحها، ثم يقطّر خبرة الإصلاح المُتحقَّق منها في مكتبة مهارات قابلة لإعادة الاستخدام. إلى جانب نتيجة ارتفاع نجاح تسليم الجسم بذراعين من 20% إلى 92% دون تدريب إضافي، نستعرض كيف يطبّق هذا الحلقةَ منصةُ المهارات ذاتية التطوّر في ThakiCloud Paxis."
seo_title: "NVIDIA ASPIRE: اكتشاف مهارات الروبوت والتعلّم المستمر | Thaki Cloud"
seo_description: "شرح لنظام ASPIRE من مختبر NVIDIA GEAR (arXiv 2607.00272): كتابة كود تحكّم الروبوت كسياسة، وإصلاح الأخطاء وتقطيرها إلى مهارات، ونتيجة الانتقال من 20% إلى 92%، وتطبيقه على منصة مهارات ThakiCloud Paxis."
date: 2026-07-03
last_modified_at: 2026-07-03
lang: ar
categories:
  - research
tags:
  - agent-skills
  - robotics
  - continual-learning
  - code-as-policy
  - nvidia
  - llm-agents
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ar/research/nvidia-aspire-agentic-skill-discovery/"
published: false
---

![شبكة مجرّدة من العقد المتوهّجة تتراكم في بنية كثيفة قابلة لإعادة الاستخدام]({{ '/assets/images/nvidia-aspire-agentic-skill-discovery-hero.webp' | relative_url }})

## نظرة عامة

من شغّل الروبوتات مدة طويلة يرى هدرًا مألوفًا. حتى عندما ينجح الروبوت في مهمة بشقّ الأنفس، يُلقى معظم ما مرّ به من محاولة وخطأ في سلة المهملات. وفي المهمة التالية يتعثّر من الصفر مجددًا. أمّا المعرفة الدقيقة المكتسبة من الفشل، مثل كيفية التعافي حين تنزلق الماسكة أو زاوية الاقتراب الصحيحة لجسم بعينه، فلا تبقى في أي مكان من النظام. الإنسان يعيد استخدام حيلة تعلّمها مرة، أمّا الروبوت فلا.

عالج فريق GEAR في NVIDIA هذا الأمر تحديدًا عبر **ASPIRE** (Agentic /Skills Discovery for Robotics، arXiv 2607.00272)، الذي أُطلق في 30 يونيو 2026. الفكرة بسيطة لكنها قوية. فبدلًا من حقن سياسة ثابتة في الروبوت، **يكتب نموذج لغوي كبير (LLM) كود تحكّم الروبوت بنفسه**، ويشغّل ذلك الكود في بيئة التنفيذ الحقيقية، ويراقب حالات الفشل، ويصلحه تكراريًا، ثم يقطّر خبرة الإصلاح المُتحقَّق منها في **مهارات (Skills) قابلة لإعادة الاستخدام**. الخبرة لا تُهدر بل تتراكم.

يعرض هذا المقال بنية ASPIRE ونتائجها المقيسة استنادًا إلى الورقة المُتحقَّق منها وصفحة المشروع. ثم يبيّن أن هذه ليست قصة روبوتات فحسب: النمط نفسه ينطبق على وكلاء البرمجيات، ونختم بربطه بكيفية تعامل منصة ThakiCloud السحابية الأصيلة للوكلاء، Paxis، مع المهارات بوصفها موارد من الدرجة الأولى.

## ما هو ASPIRE

يضع ASPIRE حلقة تعلّم مستمر فوق نمط **code-as-policy**. غالبًا ما يدرّب تعلّم الروبوتات التقليدي سياسةً عصبية على كميات كبيرة من بيانات العرض، ثم يعيد جمع البيانات وإعادة التدريب كلما ظهر موقف جديد. وهذا يحمل عبأين: جمع البيانات مكلف، والمعرفة المكتسبة مرة تنهار بسهولة أمام تغيّرات جديدة.

يمثّل ASPIRE السياسة لا بوصفها أوزان شبكة عصبية بل بوصفها **كودًا قابلًا للتنفيذ**. حين يتلقّى النموذج اللغوي مهمة ويكتب برنامج تحكّم، يُشغَّل ذلك البرنامج في المحاكاة أو على روبوت حقيقي. وإذا فشل التنفيذ، يسجّل ASPIRE مسار التنفيذ، ويحلّل سبب الفشل، ويصلح البرنامج، ثم يعيد المحاولة. وحين تبلغ هذه الحلقة النجاح، تُخزَّن معرفة الإصلاح المُتحقَّق منها في مكتبة المهارات. فتبدأ المهمة التالية لا بيدين فارغتين بل بالرجوع إلى تلك المكتبة.

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
<div class="d3-arch" data-arch-root id="ireagenticskilldiscovery-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 736, "height": 806, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 262, "y": 24, "w": 128, "h": 46, "title": "تعليمات المهمة"}, {"id": "B", "x": 224, "y": 148, "w": 205, "h": 62, "title": ["نموذج LLM يكتب كود التحكم", "code-as-policy"]}, {"id": "C", "x": 369, "y": 288, "w": 135, "h": 62, "title": ["تنفيذ حقيقي", "محاكاة أو روبوت"]}, {"id": "D", "x": 426, "y": 428, "w": 138, "h": 52, "title": "نجاح؟"}, {"id": "E", "x": 513, "y": 572, "w": 191, "h": 62, "title": ["تسجيل المسار وتحليل سبب", "الفشل"]}, {"id": "F", "x": 373, "y": 720, "w": 128, "h": 46, "title": "إصلاح البرنامج"}, {"id": "G", "x": 302, "y": 572, "w": 156, "h": 62, "title": ["تقطير خبرة الإصلاح", "المُتحقَّق منها"]}, {"id": "H", "x": 109, "y": 712, "w": 205, "h": 62, "title": ["مكتبة مهارات قابلة لإعادة", "الاستخدام"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [326, 70, 326, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[375, 210], [437, 249], [437, 249], [437, 288]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[462, 350], [495, 389], [495, 389], [495, 428]]}, {"src": "D", "dst": "E", "kind": "data", "label": "فشل", "curve": [[536, 480], [609, 526], [609, 526], [609, 572]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "curve": [[609, 634], [609, 673], [609, 673], [493, 720]]}, {"src": "F", "dst": "C", "kind": "data", "curve": [[380, 720], [265, 603], [265, 454], [369, 346]]}, {"src": "D", "dst": "G", "kind": "data", "label": "نجاح", "curve": [[453, 480], [380, 526], [380, 526], [380, 572]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "curve": [[380, 634], [380, 673], [380, 673], [286, 712]]}, {"src": "H", "dst": "B", "kind": "event", "label": "المهمة التالية ترجع إليها", "curve": [[164, 712], [104, 526], [104, 319], [228, 210]], "off": "50%"}]});
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
      const container = document.getElementById('ireagenticskilldiscovery-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ireagenticskilldiscovery-1';
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

المفتاح هو ذلك السهم الأخير. فمع رجوع مكتبة المهارات إلى كتابة المهمة التالية، يكتب النظام كودًا أفضل وأسرع مع مرور الوقت. تصف الورقة كيف تنتقل هذه المعرفة المتراكمة عبر المهام في صورة قواعد استرشادية للتعافي من الإمساك، واستراتيجيات ملاحة، ووصفات توجيه (prompting)، وإصلاحات إجرائية. الأمر ليس حلّ مهمة بعينها جيدًا، بل إن القدرة على حلّ المهام نفسها هي ما يتراكم.

## تقطير الفشل إلى مهارات

ما يميّز ASPIRE عن غيره من أنظمة تعلّم الروبوتات هو طريقة تعامله مع الفشل. ففي معظم المسارات، الفشل شيء يُطرح جانبًا، أو في أحسن الأحوال إشارة سلبية تقلّص مكافأة. أمّا ASPIRE فيعامل الفشل بوصفه **مادة تعلّم**. فمسار التنفيذ الفاشل يحمل معلومة "ماذا اختلّ ولماذا"، والنموذج اللغوي يقرأها ليستدلّ على أين وكيف يصلح الكود.

لو انتهى ذلك الإصلاح عند ارتجال لمرة واحدة، لكانت قيمته محدودة. مساهمة ASPIRE هي **تقطير الإصلاح المُتحقَّق منه إلى مهارة قابلة للتعميم**. فمثلًا، إذا أُصلح انزلاقٌ أثناء التقاط جسم بعينه ليصبح نجاحًا، يُجرَّد إجراء التعافي إلى صيغة غير مقيّدة بذلك الجسم وحده بل يمكن إعادة تطبيقها على مواقف إمساك مشابهة. ولأن المهارة قطعة كود مُعبَّر عنها نصًّا، يستطيع الإنسان قراءتها ومراجعتها، ويمكن إدارتها وترقيمها كمكتبة. وهذه ميزة كبيرة مقارنةً بالسياسات العصبية ذات الصندوق الأسود.

بفضل هذه البنية، يرفع ASPIRE الأداء **دون أي بيانات تدريب إضافية**. فبدلًا من جمع عروض جديدة لإعادة تدريب النموذج، يكفي تكرار حلقة التنفيذ والفشل والإصلاح والتقطير لرفع معدّل النجاح. وفي الروبوتات، حيث يكون جمع البيانات هو عنق الزجاجة، تُعدّ هذه خاصية مهمة عمليًا.

## النتائج التجريبية الفعلية

تُظهر الأرقام المُبلَّغ عنها في الورقة وصفحة المشروع أن هذه الحلقة أكثر من مجرد مفهوم. أبرز نتيجة هي مهمة تسليم الجسم بذراعين في Robosuite. فبدءًا من معدّل نجاح أساسي بلغ **20%**، ارتفع إلى **92%** عبر التنقيح التكراري وحده، وهو رقم بُلغ بصفر بيانات عرض إضافية، باستخدام حلقة التنفيذ والإصلاح فقط.

وتظلّ الميزة قائمة مع اتّساع أنواع المهام. تُبلّغ الورقة بأن ASPIRE يتفوّق على الطرق السابقة بما يصل إلى **77%** على LIBERO-Pro (مهمة تلاعب تحت اضطراب)، وبـ**72%** على تسليم Robosuite بذراعين، وبما يصل إلى **32%** على BEHAVIOR-1K (مهمة منزلية طويلة الأفق). وعلى وجه الخصوص، في تجارب التعميم طويلة الأفق، ارتفع معدّل النجاح باطّراد مع نمو مكتبة المهارات. وكون نمو المكتبة وارتفاع الأداء يسيران معًا يدعم الادّعاء المركزي لهذا النظام بأن الخبرة تتراكم فعلًا.

يضمّ الفريق البحثي مختبر GEAR في NVIDIA إلى جانب باحثين من جامعة ميشيغان (UMich) وجامعة إلينوي (UIUC) وجامعة كاليفورنيا في بيركلي وجامعة كارنيغي ميلون (CMU). وقد أفادت NVIDIA بأن مكتبة مهارات ASPIRE ستكون مفتوحة المصدر عند الإطلاق، مع التفاصيل على صفحة المشروع (research.nvidia.com/labs/gear/aspire). ومع ذلك، لم يتأكّد بوضوح رخصة مستودع الكود وقت الإطلاق، لذا يُستحسن التحقق مباشرةً من شروط رخصة المستودع الفعلي قبل تبنّيه.

## الأثر على منتجات ThakiCloud

يستهدف ASPIRE ذراع روبوت، لكن الرسالة التي تبعثها بنيته تنتقل مباشرةً إلى وكلاء البرمجيات. خذ جملة "يكتب الوكيل كودًا، ويتعلّم من الفشل، ويقطّر الخبرة المُتحقَّق منها إلى مهارات قابلة لإعادة الاستخدام مكدّسة في مكتبة"، واستبدل "الروبوت" بـ"الوكيل السحابي"، فتحصل تحديدًا على البنية التي تتّجه نحوها منصة ThakiCloud السحابية الأصيلة للوكلاء، **Paxis**.

تعامل Paxis المهارات والأدوات والسياسات وسجلّات التدقيق (Skills وTools وPolicies وAudit Logs) بوصفها موارد من الدرجة الأولى. فمكتبة مهارات ASPIRE تقابل في Paxis منصة مهارات تضمّ نحو 960 مهارة تُنتقى عبر BM25، وتنفيذ ASPIRE بنمط code-as-policy يقابل تنفيذ Paxis في صندوق رمل معزول. وكما يسجّل ASPIRE مسارات الفشل ويحلّلها، تمرّر Paxis كل فعل للوكيل عبر بوابة سياسة وسجلّ تدقيق حتى يمكن تتبّع ما فشل ولماذا بأثر رجعي. وأمّا التحسّن الذاتي الذي تهدف إليه حلقة تقطير ASPIRE فيتحقّق في Paxis بوصفه مهارات ذاتية التطوّر: تعود الدروس المستخلصة من التنفيذ إلى مهارات جديدة أو تنقيحات للمهارات، فلا يبدأ التشغيل التالي بيدين فارغتين.

من منظور البنية التحتية، توفّر **ai-platform** من ThakiCloud الأساس لهذه الحلقة. فحلقة التنفيذ والإصلاح المتكرّرة بأسلوب ASPIRE عليها تشغيل المحاكاة والاستدلال بكثافة، ما يفترض جدولة مرنة لموارد GPU. وقد صُمّمت ai-platform لاستيعاب مثل هذه الأحمال المتكرّرة بكفاءة في التكلفة فوق جدولة GPU المبنية على Kueue وعزل متعدّد المستأجرين. فالخدمة منخفضة التكلفة تجعل تكرار التنفيذ والإصلاح لدى الوكيل اقتصاديًا، والمهارات المتراكمة بهذه الطريقة ترفع بدورها استقلالية الوكيل، في دورة فاضلة. وللعملاء الذين يحتاجون بيئات محليّة وسيادية، تُعدّ القدرة على تشغيل هذه الحلقة كاملةً داخل بنيتهم التحتية أمرًا ذا مغزى خاص.

## القيود والاعتراضات

على إثارة نتائج ASPIRE للإعجاب، ثمة تحفّظات في محلّها. أولًا، تأتي الأرقام المُبلَّغ عنها في معظمها من معايير محاكاة (Robosuite وLIBERO-Pro وBEHAVIOR-1K). فالتنقيح التكراري في المحاكاة رخيص وآمن، لكن على العتاد الحقيقي تحمل كل محاولة وقتًا وتآكلًا ومخاطر سلامة. وما إذا كانت اقتصاديات حلقة التنفيذ والفشل والإصلاح تصمد على الروبوتات المادية يحتاج إلى تحقّق منفصل.

ثانيًا، نمط code-as-policy قوي في المهام التي يستطيع فيها النموذج اللغوي كتابة كود تحكّم صالح، لكن للتحكم المستمر الدقيق أو الأفعال التي تحتاج تغذية راجعة عالية التردّد، يبقى مجالٌ يصعب التعبير عنه كودًا. ويبدو أن ASPIRE يفوّض هذا التحكم منخفض المستوى إلى مهارات أو أوّليّات موجودة، وقد تحدّ جودة تلك الأوّليّات من سقف الأداء الإجمالي.

ثالثًا، مع نمو مكتبة المهارات يزداد عبء الاسترجاع والانتقاء. النتيجة القائلة إن نمو المكتبة يواكب مكاسب الأداء مشجّعة، لكن ما إذا كان انتقاء مهارة خاطئة أو مهارة قديمة تُطلق إجابات خاطئة سيصبح مشكلة على نطاق أكبر يستحقّ متابعة مستمرة. وهذا تحدٍّ واجهته منصة مهارات Paxis فعلًا، وانتقاء BM25 وبوابة السياسة وسجلّات التدقيق هي بالضبط آليات إدارة ذلك الخطر.

ومع ذلك، فالاتجاه الذي يشير إليه ASPIRE، أي عدم التخلّص من الفشل بل تراكمه كمهارات مُتحقَّق منها، يرجّح أن يصبح معيارًا على جانبي الروبوتات ووكلاء البرمجيات معًا. المساهمة الحقيقية لهذا العمل هي تحوّل المنظور: تنمية القدرة عبر المهارات المتراكمة بدلًا من البيانات.

## المصادر

- ASPIRE: Agentic /Skills Discovery for Robotics، arXiv 2607.00272: <https://arxiv.org/abs/2607.00272>
- صفحة المشروع (NVIDIA GEAR): <https://research.nvidia.com/labs/gear/aspire/>
- صفحة الورقة (Hugging Face): <https://huggingface.co/papers/2607.00272>
