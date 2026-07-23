---
title: "لا يمكن الفصل بين تصميم الـ harness والـ post-training - كيف يحدد الـ harness الواعي بالـ post-training أداء وكلاء LLM"
excerpt: "يعمل وكيل LLM المستخدِم للأدوات فوق harness يحيط بالنموذج. وتُثبت ورقة بحثية حديثة على arXiv، عملياً، أن الفصل بين تصميم هذا الـ harness والـ post-training يؤدي إلى انهيار الأداء، خصوصاً عند تغيّر بيئة الأدوات. نستعرض هذه النتيجة من منظور يتعامل مع الـ harness كمورد من الدرجة الأولى."
seo_title: "التفاعل بين تصميم الـ harness والـ post-training - تعلّم واعٍ بالـ harness لوكلاء LLM - Thaki Cloud"
seo_description: "ملخص لورقة The Interplay of Harness Design and Post-Training in LLM Agents (arXiv:2606.25447). نتناول اكتشاف أن مقدار المعلومات في الـ harness يرفع أداء zero-shot والـ post-training معاً، وأن الـ post-training الواعي بالـ harness وحده هو ما يُعمِّم بمتانة عند تغيّر بيئة الأدوات (OOD)، من منظور السحابة الأصيلة للوكلاء (agent-native cloud) وبنية الاستدلال والتدريب التحتية."
date: 2026-07-20
last_modified_at: 2026-07-20
canonical_url: "https://thakicloud.com/tech-blog/ar/research/harness-design-post-training/"
lang: ar
reading_time: true
tags:
  - agent-harness
  - harness-engineering
  - post-training
  - tool-use
  - llm-agents
  - ood-generalization
  - agent-native-cloud
  - rlvr
author_profile: true
toc: true
categories:
  - research
---

كل مهندس شغّل وكيلاً (agent) بنفسه، أو ربط سير عمل يعتمد بكثافة على استدعاء الأدوات، يعرف تجربة مشتركة: مع أن النموذج الأساسي واحد، يختلف أداء الوكيل بشكل ملحوظ بحسب السقالة (scaffolding) التي يُبنى فوقها - قائمة الأدوات، وصف هذه الأدوات، والتلميحات الملحقة بالمشاهدات. أصبحت هذه السقالة تُعرف مؤخراً باسم الـ harness. تستند هذه المقالة إلى ورقة بحثية نُشرت في يونيو 2026 بعنوان [The Interplay of Harness Design and Post-Training in LLM Agents](https://arxiv.org/abs/2606.25447)(arXiv:2606.25447)، وتشرح لماذا لا يمكن فصل تصميم الـ harness الجيد عن تدريب النموذج، وما الذي تعنيه هذه النتيجة للسحابات التي تُشغّل الوكلاء فعلياً في بيئة الإنتاج. والخلاصة مقدَّماً: الـ harness ليس قطعة تُستبدل بعد انتهاء التدريب، بل عنصر يجب تصميمه مع مرحلة التدريب منذ البداية.

## نظرة عامة: لماذا الـ harness الآن

في الأشهر الأخيرة، بات يتكرر الطرح القائل إن "الكود المحيط بالنموذج أهم من النموذج نفسه". فبالنسبة للوكلاء الذين يستخدمون الأدوات، لا يقل أسلوب عرض الأدوات ووصفها، وما يُعاد كمشاهدة (observation) في كل خطوة، أهمية عن أوزان النموذج ذاتها في تحديد الأداء النهائي. وتتناول ورقة استقصائية أخرى تعالج الموضوع نفسه، [From Question Answering to Task Completion](https://arxiv.org/abs/2606.20683)، تصميم الـ harness باعتباره محوراً بحثياً مستقلاً في أنظمة الوكلاء.

تكمن المشكلة في أن هذين الجانبين - تصميم الـ harness والـ post-training - كانا يُعاملان حتى الآن وكأنهما عمل فريقين مختلفين. فريق البحث يصقل السياسة (policy) عبر التعلم المعزّز، بينما يتولى فريق المنصة ضبط الأدوات والمحفزات (prompts). وتكمن مساهمة هذه الورقة في إثبات خطأ هذا التقسيم؛ فمقدار المعلومات في الـ harness والـ post-training متشابكان بعلاقة ضربية، بحيث يؤدي تحسين أحدهما فقط إلى تبديد معظم مكاسب الآخر. وبالنسبة لمنصة مثل ThakiCloud التي تتعامل مع الـ harness كمورد من الدرجة الأولى، تُترجَم هذه النتيجة مباشرة إلى مبدأ تشغيلي.

## ما هو الـ harness وأين يتحدد الأداء

تُعرّف الورقة الـ harness بأنه "السقالة التي تحيط بالنموذج". وبتحديد أدق، هو الطبقة التي تقرر أي الأدوات تُعرض، وكيف تُوصف هذه الأدوات، وما المعلومات المساعدة التي تُرفق بمشاهدة كل خطوة. ويمكن تمثيل دورة واحدة لوكيل يستدعي الأدوات كما يلي:

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
<div class="d3-arch" data-arch-root id="arnessdesignposttraining-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1050, "height": 860, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 281, "y": 24, "w": 737, "h": 140, "label": "harness: السقالة المحيطة بالنموذج", "lx": 293, "ly": 42}], "nodes": [{"id": "U", "x": 122, "y": 71, "w": 121, "h": 46, "title": "مهمة المستخدم"}, {"id": "H", "x": 123, "y": 242, "w": 120, "h": 46, "title": "H"}, {"id": "T", "x": 318, "y": 63, "w": 177, "h": 62, "title": ["اختيار مجموعة الأدوات", "المعروضة"]}, {"id": "D", "x": 550, "y": 71, "w": 184, "h": 46, "title": "وصف الأدوات وتوقيعاتها"}, {"id": "O", "x": 789, "y": 63, "w": 191, "h": 62, "title": ["معلومات مساعدة وتلميحات", "تُرفق بمشاهدة كل خطوة"]}, {"id": "M", "x": 115, "y": 534, "w": 135, "h": 46, "title": "نموذج سياسة LLM"}, {"id": "A", "x": 347, "y": 658, "w": 212, "h": 46, "title": "استدعاء الأدوات والإجراءات"}, {"id": "E", "x": 101, "y": 782, "w": 163, "h": 46, "title": "إرجاع مشاهدة البيئة"}, {"id": "R", "x": 172, "y": 658, "w": 120, "h": 46, "title": "إتمام المهمة"}, {"id": "PT", "x": 42, "y": 380, "w": 163, "h": 62, "title": ["مرحلة post-training", "للسياسة"]}], "edges": [{"src": "U", "dst": "H", "kind": "data", "line": [183, 117, 183, 242]}, {"src": "H", "dst": "M", "kind": "data", "curve": [[203, 288], [242, 334], [242, 488], [203, 534]]}, {"src": "M", "dst": "A", "kind": "data", "curve": [[250, 573], [453, 619], [453, 619], [453, 658]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[453, 704], [453, 743], [453, 743], [264, 786]]}, {"src": "E", "dst": "M", "kind": "data", "curve": [[165, 782], [134, 743], [134, 619], [165, 580]]}, {"src": "M", "dst": "R", "kind": "data", "curve": [[201, 580], [232, 619], [232, 619], [232, 658]]}, {"src": "H", "dst": "PT", "kind": "event", "label": "post-training واعٍ بالـ harness", "curve": [[163, 288], [123, 334], [123, 334], [123, 380]], "off": "50%"}, {"src": "PT", "dst": "M", "kind": "event", "label": "سياسة مدرَّبة مع الـ harness", "curve": [[123, 442], [123, 488], [123, 488], [163, 534]], "off": "50%"}]});
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
      const container = document.getElementById('arnessdesignposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'arnessdesignposttraining-1';
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

المتغير الجوهري هنا هو مقدار المعلومات (informativeness) في الـ harness. فالـ harness ذو المعلومات الغنية يصف الأدوات بتفصيل ويرفق بالمشاهدات تلميحات مفيدة، ما يساعد النموذج على اختيار الأداة الصحيحة دون الاعتماد الكامل على معرفته المسبقة. أما الـ harness منخفض المعلومات فيكتفي بتوقيعات (signatures) دنيا ويترك الباقي لاستدلال النموذج. وهذا الفارق هو ما يحدد النتيجة عند التقائه بالتدريب.

## الافتراض الذي يقلبه هذا البحث

لدى من تعامل مع الوكلاء افتراض ضمني شائع: يكفي إضافة harness جيد قبيل النشر مباشرة. النموذج يُدرَّب جيداً بمعزل عن ذلك، ثم يُضبط الـ harness لاحقاً بتنقيح وصف الأدوات، ويُتوقّع أن يرتفع الأداء تبعاً لذلك. وتدحض الورقة هذا الافتراض بشكل مباشر.

أولاً، حتى في وضع zero-shot (بالاعتماد على المحفزات فقط دون تدريب إضافي)، يتحسّن الأداء بشكل مطّرد كلما زاد مقدار المعلومات في الـ harness، ويكون هذا الأثر أوضح في النماذج ذات القدرة الأعلى. وهذا يعني أن المعرفة المسبقة المضمّنة في harness غني بالمعلومات تُترجم مباشرة إلى أداء.

ثانياً، وهذا الاكتشاف الأهم، يكمن في التفاعل مع الـ post-training. فعند مقارنة نموذج دُرِّب مع الـ harness مدمجاً منذ مرحلة التدريب، بنموذج أُضيف إليه الـ harness نفسه بعد انتهاء التدريب، يستعيد النموذج الثاني جزءاً ضئيلاً فقط من المكاسب التي حظي بها الأول. بعبارة أخرى، الـ post-training الواعي بالـ harness (harness-aware post-training) ليس إضافة تُحسّن الأداء، بل شرط أساسي لتحقيق أداء متين. أما نهج استبدال الـ harness بعد التدريب فهو مقاربة ناقصة.

## يظهر الفرق الحقيقي عند تغيّر بيئة الأدوات

تأتي النتيجة الأكثر عملية من تجارب خارج التوزيع (OOD). ويُقصد بـ OOD هنا بيئة أدوات لم يرها النموذج أثناء التدريب - كأن تُضاف أدوات جديدة أو تُستبدل، أو تتغيّر توقيعات واجهات API. وفي التشغيل الفعلي، هذا النوع من التغيّر ثابت لا يتوقف؛ فالأدوات تتزايد باستمرار، والإصدارات تتحدّث، ومجموعة الأدوات المعروضة تختلف من مستأجر (tenant) إلى آخر.

تقارن الورقة بين مسارين. فالوكيل الذي خضع لـ post-training واعٍ بـ harness غني بالمعلومات يصمد بمتانة حتى عند تغيّر بيئة الأدوات بشكل كبير، ويُعمِّم عبر مجموعات المهام المختلفة. في المقابل، الوكيل الذي دُرِّب مع harness بُذل في تصميمه جهد محدود ينهار أداؤه سريعاً كلما اشتد تغيّر بيئة الأدوات، ويعجز عن الانتقال إلى بيئات جديدة. بعبارة أخرى، تلعب المعرفة المسبقة المضمّنة في الـ harness دور المرساة (anchor) للتعميم. فالسياسة المدرَّبة مع harness مصمَّم جيداً تحتفظ بحسّها حول ماذا وكيف تستدعي حتى أمام أدوات غير مألوفة، بينما تفقد السياسة المدرَّبة مع harness هزيل ذلك الحسّ بالكامل.

هذه النقطة مؤلمة بشكل خاص لمشغّلي السحابة. فالسبب النمطي وراء انهيار وكيل حقق نتائج جيدة في المعايير القياسية (benchmarks) عند وصوله إلى بيئة الإنتاج هو تحديداً تحوّل بيئة الأدوات. وتقول هذه الورقة إن جزءاً كبيراً من هذا الضعف يتحدد أصلاً في مرحلة تصميم الـ harness.

## دلالات التطبيق على منتجات ThakiCloud

يتقاطع هذا الاكتشاف مع محوري منتجات ThakiCloud كليهما، بحيث تفوّت النظرة من زاوية واحدة نصف الصورة.

الزاوية الأولى هي **زاوية Paxis**. فـ Paxis هي لوحة تحكم Agent-Native Cloud تعمل فوق ai-platform، وتتعامل مع الـ Skills والـ Tools والـ Policies وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. وبلغة هذه الورقة، فإن Skill Harness الخاص بـ Paxis هو تحديداً الـ harness المقصود هنا. فاختيار مجموعة الأدوات المعروضة من بين نحو 960 مهارة (skill) عبر BM25، وتنسيق وصف كل مهارة وتوقيعها، وإعادة نتائج التنفيذ في sandbox معزول كمشاهدة - كل هذه العمليات مجتمعة هي ما يحدد مقدار المعلومات في الـ harness. وتدعم استنتاجات الورقة مبادئ تصميم Paxis: فبناء harness غني بالمعلومات عبر اختيار المهارات بما يناسب المهمة، بدلاً من عرضها جميعاً دون تمييز، ثم تطوير ذلك الـ harness مع حلقة التدريب والتقييم، هو ما يقود إلى المتانة أمام بيئات أدوات غير مألوفة. كما أن البنية التي تُمرِّر كل إجراء عبر بوابات السياسات (policy gates) وسجلات التدقيق تندرج ضمن الهمّ نفسه: إبقاء الـ harness موضوعاً للتجريب وخاضعاً لإدارة الإصدارات.

الزاوية الثانية هي **زاوية ai-platform**. فاستنتاج أن الـ post-training الواعي بالـ harness شرط أساسي يرفع قيمة إبقاء التدريب والتقديم (serving) داخل بنية تحتية واحدة. وتُشغِّل ai-platform أعباء الـ post-training مثل الـ fine-tuning والـ RLVR جنباً إلى جنب مع تقديم الاستدلال عبر vLLM، فوق جدولة GPU قائمة على K8s وKueue. ولكي يُدمَج الـ harness عند لحظة التدريب، يجب أن يكون بإمكان خط أنابيب التدريب الرجوع مباشرة إلى مخطط الأدوات (tool schema) وصيغة المشاهدات المستخدَمة في التقديم. فإذا انفصل التدريب عن التقديم في منظمتين أو مكدّسين تقنيين مختلفين، ينحرف الـ harness عن مساره، ويقع المرء في فخ المكسب الناقص الذي حذّرت منه الورقة، أي "استبدال الـ harness بعد التدريب". أما التصميم الذي يعرض مجموعات أدوات مختلفة لكل مستأجر في بيئة متعددة المستأجرين، مع الحفاظ في الوقت ذاته على متطلبات on-premise والسيادة عبر self-hosting يجمع التدريب والتقديم داخل سياج واحد، فهو موقع مؤاتٍ للحفاظ على هذا التوافق بين الـ harness والتدريب.

وتتكامل الزاويتان: تدير Paxis الـ harness كمورد من الدرجة الأولى فتضبط مقدار معلوماته وإصداراته، بينما تُدخِل ai-platform ذلك الـ harness في حلقة التدريب فتُحوّل الـ post-training الواعي بالـ harness إلى واقع ملموس.

## القيود والاعتراضات المحتملة

لتجنّب المبالغة في تفسير نتائج هذه الورقة، ينبغي مراعاة عدة نقاط.

أولاً، تحمل فرضية "كلما زاد مقدار المعلومات في الـ harness كان أفضل" تكلفة مصاحبة. فكلما زادت التلميحات المرفقة بالمشاهدات طال السياق (context)، وكلما ازداد ثراء وصف الأدوات ارتفع عدد رموز المحفز (prompt tokens) والتأخير (latency). ومن منظور التقديم (serving)، مقدار المعلومات ليس مجانياً، ويجب موازنته دائماً مع الإنتاجية (throughput). ولذلك يُستحسَن قراءة مفهوم "مقدار المعلومات" في الورقة لا على أنه "المزيد دائماً أفضل"، بل بمعنى أقرب إلى "هل يحمل معرفة مسبقة مفيدة للمهمة".

كذلك، يتطلب الـ post-training الواعي بالـ harness تكلفة دخول تتمثل في إعادة ضبط خط أنابيب التدريب. وفي كثير من الممارسات العملية التي تستخدم نماذج open-weight جاهزة كما هي، يظل تحسين الـ harness وحده في وضع zero-shot خطوة أولى واقعية. وبما أن الورقة نفسها تؤكد أن مقدار المعلومات يرفع الأداء في وضع zero-shot أيضاً، فهذا يبقى نقطة انطلاق معقولة للفرق التي لا تملك موارد كافية للتدريب.

وأخيراً، من الصعب الجزم بأن تحوّلات بيئة الأدوات التي تتناولها تجارب OOD في الورقة تُمثِّل كامل نطاق التغيّر في بيئة الإنتاج الفعلية. فثمة فجوة بين استبدال الأدوات في المعايير القياسية وبين بيئة تشغيل يحدّث فيها عشرات المستأجرين واجهات API الخاصة بهم كلٌّ على حدة. ومع ذلك، فإن الاتجاه العام - أي أن "الوكيل المصمَّم مع الـ harness منذ التدريب أكثر متانة أمام التغيّر" - يُرجَّح أن يعمل بقوة أكبر كلما كانت السحابة الفعلية أكثر تغيّراً مستمراً في أدواتها.

وخلاصة القول، تدعو هذه الورقة إلى معاملة الـ harness لا كلمسة تشطيب تُضاف قبيل النشر، بل كبنية تُصمَّم مع مرحلة التدريب منذ خطوتها الأولى. والاتجاه القائم على إدارة الـ harness كمورد من الدرجة الأولى، وإبقاء التدريب والتقديم داخل بنية تحتية واحدة، يشير بالضبط إلى الوجهة نفسها التي توصي بها هذه التوصية.

## المصادر

- The Interplay of Harness Design and Post-Training in LLM Agents, arXiv:2606.25447: <https://arxiv.org/abs/2606.25447>
- From Question Answering to Task Completion: A Survey on Agent System and Harness Design, arXiv:2606.20683: <https://arxiv.org/abs/2606.20683>
