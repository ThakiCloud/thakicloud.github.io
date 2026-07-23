---
title: "شراء المزيد من GPU لن يحل المشكلة: الاستدلال الموزع مع llm-d وبنية غير متجانسة تجمع GPU مع أي NPU/XPU"
excerpt: "llm-d هو جدول زمني للاستدلال يعالج طلبات أكثر من نفس الـ GPU بدلاً من شراء المزيد منها. نستعرض مبادئ توجيه KV-cache وفصل prefill/decode، ثم نوضح كيف يمكن لأي مسرّع متوافق مع vLLM سواء NPU مثل Rebellions و Furiosa أو XPU مثل Intel Gaudi و TPU الانضمام إلى نفس طبقة التنسيق المحايدة للمسرّعات."
seo_title: "llm-d: استدلال موزع وبنية GPU+NPU/XPU غير متجانسة"
seo_description: "كيف يعمل توجيه KV-cache وفصل prefill/decode في llm-d، وكيف تُشغّل GPUs إلى جانب NPUs و XPUs متنوعة (Rebellions و Furiosa و Intel Gaudi و TPU) في بنية استدلال ذكاء اصطناعي سيادي محايدة للموردين."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - llm-d
  - distributed-inference
  - vllm
  - kv-cache-routing
  - prefill-decode
  - heterogeneous-computing
  - npu
  - xpu
  - rebellions
  - furiosa
  - sovereign-ai
  - kubernetes
  - thakicloud
header:
  teaser: /assets/images/llm-d-heterogeneous-hero.webp
toc: true
toc_sticky: true
categories:
  - llmops
published: false
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/llm-d-distributed-inference-heterogeneous-accelerators/"
---

![مجموعة GPU ومجموعة NPU تعملان معاً في نفس الكلستر لتقديم الاستدلال]({{ '/assets/images/llm-d-heterogeneous-hero.webp' | relative_url }})

## شراء المزيد من GPU لن يسرّع الاستدلال

عند تشغيل استدلال نماذج اللغة الكبيرة في بيئة إنتاجية، تصطدم بجدار يبدو غير منطقي: إضافة المزيد من GPU لا تزيد معدل المعالجة بنفس القدر. السبب الجذري هو أن الاستدلال ينقسم إلى مرحلتين ذواتَي خصائص متعاكسة تماماً.

مرحلة prefill، التي تحسب المطالبة الكاملة دفعة واحدة، مقيّدة بالحوسبة وترفع استخدام GPU إلى أكثر من 90%. أما مرحلة decode، التي تولّد رمزاً واحداً في كل مرة، فهي مقيّدة بالذاكرة وقد تنخفض إلى أقل من 30%. عندما تتولى GPU واحدة كلتا المرحلتين، يتذبذب الاستخدام بشدة، ولا تستطيع الطلبات التي تشترك في system prompt أو بادئة مشتركة إعادة استخدام حالة KV المخزّنة. لذا، فإن التوسع الأفقي بمضاعفة GPU مكلف وغير كفء. ما تحتاجه فعلاً هو جدولة تستخرج طلبات أكثر من نفس الـ GPU.

هذا هو ملخص llm-d في جملة واحدة: جدول زمني للاستدلال يحل ما لا يحله شراء المزيد من GPU. تشارك هذه المقالة المبادئ التشغيلية لـ llm-d كما استعرضناها في ندواتنا الداخلية وتقاريرنا المعمارية، إلى جانب التصميم غير المتجانس الذي نبنيه فوقه، جامعاً GPU و NPU في كلستر واحد. هذا تصميم مرجعي نعتزم التحقق منه، وليس شرائح تسويقية.

## ما هو llm-d: مبني على ثلاثة أسس موثوقة

llm-d إطار عمل للاستدلال الموزع عالي الأداء يعمل على Kubernetes بطريقة أصيلة. والمهم أنه لا يبدأ من الصفر، بل يجمع ثلاثة مكونات موثوقة مسبقاً.

الأول هو vLLM، محرك الاستدلال الفعلي الذي يوفر PagedAttention والدُّفعات المستمرة والترميز التخميني. الثاني هو Kubernetes، الأساس للنشر والجدولة والتوسع التلقائي والتعافي من الأعطال. الثالث هو Inference Gateway (GAIE)، وهو امتداد Gateway API للتوجيه الواعي بالحالة.

فوق هذه الأسس، يضيف llm-d قدرتين أساسيتين: توجيه KV-cache الواعي وفصل prefill/decode. وعلى صعيد الحوكمة، اكتسب ثقة مؤسسية: اعتُمد llm-d في CNCF Sandbox عام 2026، بدعم من IBM و Red Hat و Google و CoreWeave و NVIDIA.

## السلاح الأول: توجيه KV-cache الواعي

الرافعة الأولى هي عدم إرسال الطلبات إلى pod عشوائي. بدلاً من ذلك، تُوجَّه الطلبات إلى الـ pod الذي يحتفظ بالفعل بذاكرة KV cache لبادئة المطالبة الواردة في ذاكرة GPU، حتى عندما تأتي الطلبات من مستخدمين مختلفين.

العائد هو إلغاء عمليات prefill المتكررة. الفوائد أكبر بشكل خاص في أحمال العمل ذات البادئات المتداخلة: المحادثات المتعددة الأدوار وخطوط RAG و system prompts المشتركة. تنخفض زمن الاستجابة ويرتفع معدل المعالجة.

يتوفر وضعان للتوجيه: الوضع التقريبي يستنتج موضع الذاكرة المؤقتة من أنماط حركة المرور، خفيف الوزن لكنه غير دقيق. الوضع الدقيق يشترك مباشرة في KV-Events الخاص بـ vLLM لقراءة حالة كتل KV الفعلية، وهو دقيق. كلا الوضعين مدعومان بـ KV-Cache Indexer، وهو مكتبة عالية الأداء تحافظ على رؤية عالمية شبه فورية لموضع كتل KV عبر جميع pods الخاصة بـ vLLM.

## السلاح الثاني: فصل Prefill / Decode

الرافعة الثانية هي الفصل الفيزيائي للمرحلتين ذواتَي الخصائص المتعاكسة. تُقسَّم مراحل prefill و decode إلى مجموعات pods منفصلة، مما يسمح بضبط كل مرحلة بشكل مستقل. تختفي التذبذبات في الاستخدام الناجمة عن تبادل GPU واحدة بين المرحلتين.

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
<div class="d3-arch" data-arch-root id="eterogeneousaccelerators-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 276, "height": 800, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 74, "y": 24, "w": 120, "h": 46, "title": "الطلب"}, {"id": "B", "x": 60, "y": 148, "w": 149, "h": 62, "title": ["Inference Gateway", "GAIE + EPP"]}, {"id": "C", "x": 49, "y": 288, "w": 170, "h": 62, "title": ["KV-Cache Indexer", "رؤية عالمية لموضع KV"]}, {"id": "D", "x": 70, "y": 428, "w": 128, "h": 62, "title": ["مجموعة Prefill", "compute-bound"]}, {"id": "E", "x": 74, "y": 582, "w": 121, "h": 62, "title": ["مجموعة Decode", "memory-bound"]}, {"id": "F", "x": 74, "y": 722, "w": 120, "h": 46, "title": "تدفق الرموز"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [134, 70, 134, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [134, 210, 134, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [134, 350, 134, 428]}, {"src": "D", "dst": "E", "kind": "data", "label": "KV: نقل مباشر VRAM→VRAM<br/>عبر NIXL", "line": [134, 490, 134, 582], "lx": 134, "ly": 532}, {"src": "E", "dst": "F", "kind": "data", "line": [134, 644, 134, 722]}]});
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
      const container = document.getElementById('eterogeneousaccelerators-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eterogeneousaccelerators-1';
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

المفتاح هو كيفية نقل KV cache. تنتقل مباشرة من VRAM محرك prefill إلى VRAM محرك decode عبر NIXL، وبما أن النقل غير محجوب، تستمر GPU في معالجة طلبات أخرى أثناء النقل. هذا يتيح لنا تحسين زمن أول رمز (TTFT) ووقت الانتظار بين الرموز (ITL) بشكل مستقل، دون تداخل.

تحذير صادق: في البيئات الصغيرة ذات التزامن المنخفض، يمكن أن تؤدي تكاليف نقل KV إلى إبطاء بنسبة 20 إلى 30%. الفصل يؤتي ثماره فقط عندما يدعمه حجم حركة المرور.

## المكونات وأدلة الأداء

مسار البيانات الكامل، مقسّماً حسب المكون، يبدو كالآتي.

| المكون | الدور |
|---|---|
| Inference Gateway (GAIE) + EPP | يسجّل EPP معدلات إصابة الذاكرة المؤقتة لكل pod ويوجّه إلى الـ pod الأمثل |
| KV-Cache Indexer | يحافظ على رؤية عالمية لموضع كتل KV عبر جميع pods الخاصة بـ vLLM (تقريبي / دقيق) |
| فصل Prefill/Decode | مجموعات منفصلة للـ prefill المقيّد بالحوسبة والـ decode المقيّد بالذاكرة؛ نقل KV عبر NIXL |
| vLLM (الواجهة الخلفية) | محرك الاستدلال الفعلي: PagedAttention، الدفعات المستمرة |
| K8s Operator / CRD | نشر تصريحي وتوسع تلقائي؛ إدارة الإصدارات عبر ArgoCD GitOps |

تدعم الأرقام المنشورة ادعاءات الأداء. على طوبولوجيا 16×16 B200، أُفيد بحوالي 50,000 output tok/s وانخفاض في TTFT بمقدار رتبة ضخامة. على جانب AMD، أظهرت منصة 4×MI300X تقدّم Llama-3.1-70B بزيادة 3 أضعاف في معدل الإخراج وتحسن مضاعف في TTFT بعد تفعيل توجيه prefix-cache الواعي.

غير أن هذه الأرقام تعتمد بشدة على الطوبولوجيا والنموذج والدقة. سواء كانت "N tok/s" تشير إلى معدل تدفق مفرد أم مجمّع، وما هو طول الإدخال وحجم الدفعة والدقة المستخدمة، قد يغير المعنى بمقدار رتبة ضخامة. نعامل أرقام المعيار غير المكتملة التسميات بوصفها غير جديرة بالثقة.

العلاقة بالبدائل واضحة أيضاً. إذا اندرج النموذج في GPU عقدة واحدة، فإن vLLM المستقل هو الإجابة الأبسط. يدخل llm-d عندما تحتاج إلى تجاوز عقدة واحدة وتشغيل نماذج متعددة على مقياس Kubernetes. يستهدف NVIDIA Dynamo التنسيق على نطاق مركز البيانات؛ ويستهدف SGLang أداء MoE-EP وأحدث تقنيات فصل PD. llm-d و Dynamo ليسا متعارضين: يمكن لـ Dynamo التعامل مع التنسيق بينما يعمل vLLM و llm-d كطبقة المحرك.

## غير المتجانس: إضافة أي NPU/XPU فوق GPU

هذا هو جوهر تقرير بنيتنا المعمارية. والنقطة الأولى التي يجب تثبيتها هي أن هذا التصميم غير مقيّد بمورد مسرّعات محدد. طبقة تنسيق llm-d و vLLM مستقلة عن نوع المسرّع. يمكنك استبدال مجموعة المسرّعات مع إبقاء منطق التوجيه والفصل دون تغيير.

هذا ليس فرضية: يدعم vLLM بالفعل رسمياً مجموعة واسعة من الواجهات الخلفية. بالإضافة إلى GPU من NVIDIA و AMD، يغطي Intel CPU/XPU/Gaudi (HPU) و Google TPU و AWS Neuron، وعبر الإضافات، IBM Spyre و Huawei Ascend و NPUs المحلية بما فيها Rebellions و Furiosa، كلها خلف نفس واجهة vLLM. بعبارة أخرى، موقع NPU/XPU في تكوين "مجموعة GPU + مجموعة NPU/XPU" يقبل أي مسرّع متوافق مع vLLM.

| المسرّع | واجهة vLLM الخلفية | ملاحظات |
|---|---|---|
| NVIDIA GPU | CUDA (أصلي) | أعلى نضج في النظام البيئي والنوى |
| AMD GPU | ROCm | MI300X وغيرها؛ مدعوم رسمياً |
| Intel Gaudi / XPU | واجهة HPU / XPU | مسرّعات مراكز البيانات |
| Google TPU / AWS Neuron | واجهات خلفية مخصصة | مسرّعات سحابية |
| Rebellions NPU | vLLM-RBLN (إضافة) | محلي؛ optimum-rbln / RSD |
| Furiosa NPU | Furiosa-LLM (متوافق مع vLLM) | محلي؛ RNGD / TCP |

نذكر كلا الـ NPU المحليين معاً لتوضيح نقطة واحدة: يوجد أكثر من خيار واحد. المفتاح هو أن تجريد vLLM يتيح لك تبديل الموردين بدلاً من الارتباط بأحدهم.

يتصل Rebellions عبر إضافة vLLM-RBLN. يُجمَّع النموذج باستخدام optimum-rbln ثم يُشار إليه بواسطة vLLM-RBLN، الذي ينقل FlashAttention و PagedAttention إلى تسلسل ذاكرة NPU ويجمعهما في رسم بياني تنفيذي واحد. يعتمد التوسع الأفقي على RSD (Rebellions Scalable Design)، الذي يتولى فصل prefill/decode وتوجيه MoE. في Kubernetes، يكتشف NFD الـ NPU عبر معرف بائع PCI، ويسجّله Rebellions NPU Operator كـ device-plugin، وتتحكم فيه متغيرات بيئية مثل `VLLM_TARGET_DEVICE=rbln`. تشمل التشكيلة الحالية ATOM-Max بخادمين مزدوجين مع 8 NPUs و 128GB للنماذج بحجم 70B، مع REBEL Quad الذي يستهدف تحسين MoE.

يتصل Furiosa عبر Furiosa-LLM، إطار عمل متوافق مع vLLM. تستخدم الشريحة الرئيسية RNGD بنية TCP (Tensor Contraction Processor) مع 48GB HBM3 بعرض نطاق ترددي 1.5TB/s و 180W TDP، محققةً 512 TFLOPS عند FP8. يحزم خادم NXT RNGD ثماني بطاقات لتوفير 384GB HBM3 و 4 petaFLOPS (FP8) بظرف حراري 3kW TDP، مع بدء الإنتاج الضخم في يناير 2026. ميزتها التنافسية الأولى هي كفاءة الطاقة، مما يضعها في فئة مختلفة عن GPU.

القاسم المشترك بين الـ NPU الاثنين هو المبدأ العام: طالما يوفر كل مورد device-plugin/operator وواجهة خلفية لـ vLLM، فإن طبقة تنسيق llm-d الفوقية لا تحتاج إلى تغيير، تضيف ببساطة مجموعة مسرّعات.

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
<div class="d3-arch" data-arch-root id="eterogeneousaccelerators-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 479, "height": 570, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "G", "x": 133, "y": 24, "w": 205, "h": 62, "title": ["Inference Gateway + llm-d", "(تنسيق محايد للمسرّعات)"]}, {"id": "K", "x": 158, "y": 164, "w": 156, "h": 62, "title": ["Kueue", "حصة موحدة وأولويات"]}, {"id": "P1", "x": 295, "y": 312, "w": 120, "h": 62, "title": ["مجموعة GPU", "NVIDIA / AMD"]}, {"id": "P2", "x": 24, "y": 304, "w": 184, "h": 78, "title": ["مجموعة NPU/XPU", "مسجّلة عبر", "device-plugin/operator"]}, {"id": "V1", "x": 263, "y": 468, "w": 184, "h": 62, "title": ["vLLM (CUDA/ROCm)", "H100/H200/B200, MI300X"]}, {"id": "V2", "x": 24, "y": 460, "w": 184, "h": 78, "title": ["واجهة متوافقة مع vLLM", "Rebellions, Furiosa,", "Intel, TPU, Neuron ..."]}], "edges": [{"src": "G", "dst": "K", "kind": "data", "line": [236, 86, 236, 164]}, {"src": "K", "dst": "P1", "kind": "data", "curve": [[288, 226], [355, 265], [355, 265], [355, 312]]}, {"src": "K", "dst": "P2", "kind": "data", "curve": [[183, 226], [116, 265], [116, 265], [116, 304]]}, {"src": "P1", "dst": "V1", "kind": "data", "line": [355, 374, 355, 468]}, {"src": "P2", "dst": "V2", "kind": "data", "line": [116, 382, 116, 460]}]});
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
      const container = document.getElementById('eterogeneousaccelerators-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eterogeneousaccelerators-2';
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

مقارنة نوعَي المجموعات جنباً إلى جنب في كلستر واحد تكشف عن أدوارهما التكاملية. لاحظ أن العمود الأيمن يمثل NPUs و XPUs بشكل عام، وليس أي مورد بعينه.

| | مجموعة GPU | مجموعة NPU/XPU (مثال: Rebellions, Furiosa, Intel, TPU) |
|---|---|---|
| محرك التقديم | vLLM (CUDA/ROCm) | واجهة متوافقة مع vLLM (vLLM-RBLN, Furiosa-LLM, HPU/XPU, إلخ) |
| الكشف في K8s | NVIDIA/AMD GPU Operator | مورد NPU Operator + NFD / device-plugin |
| Disagg/MoE | ناضج عبر llm-d | خاص بالمورد (مثل RSD) + تكامل llm-d قيد التحقق |
| نقاط القوة | نضج النظام البيئي والنوى، أعلى معدل معالجة | كفاءة الطاقة، تنويع سلسلة التوريد السيادية، ادعاءات تفوق MoE |
| تحفظات | الطاقة، التوريد، التكلفة | نضج disagg الموزع / توجيه KV؛ مراجع نماذج كبيرة أقل |

## تطبيق ThakiCloud وخارطة طريق النشر

أكبر ميزة لهذه البنية بالنسبة لنا هي أنها تعمل فوق مكدّسنا الحالي دون بنية تحتية جديدة. تعمل فوق Kubernetes و Kueue و ArgoCD التي نستخدمها بالفعل. يجدول Kueue مجموعات عمال prefill و decode بجدولة gang مع إدارة الحصص؛ يدير ArgoCD الـ CRDs عبر GitOps. تغطي قابلية المراقبة TTFT و ITL و tok/s ومعدل إصابة KV عبر Prometheus و Grafana، مع تتبع SLOs لكل طبقة نماذج عبر قواعد SRE.

يسير التبني عبر مراحل مسوّرة بقياسات كمية. تُنشئ المرحلة 0 خط أساس llm-d على مجموعة GPU وتقيس تأثير توجيه KV وفصل PD. تضبط المرحلة 1 توجيه prefix-cache وتُنشئ تقديم نماذج متعددة وتحدد SLOs. تضيف المرحلة 2 عقدة واحدة من مرشح NPU (Rebellions أو Furiosa أو غيرها) إلى Kubernetes وتقارن بنفس النموذج تحت شروط مطابقة. سيُقيَّم اختيار المسرّع بناءً على كفاءة الطاقة وسلسلة التوريد وملاءمة النموذج، دون التزام مسبق بمورد محدد. تُنشئ المرحلة 3 سياسة التوجيه غير المتجانس وتعيد تقييم أحمال عمل MoE مع وصول كل مورد إلى الإنتاج الضخم. قبل كل مرحلة، نُثبّت تعريفات القياس: معدل تدفق مفرد مقابل مجمّع، طول الإدخال، حجم الدفعة، والدقة.

## المخاطر والنتيجة المعاكسة

الوثيقة المعمارية الجيدة يجب أن تهاجم حججها بنفسها. إليك نقاط ضعف هذه البنية بصراحة.

نضج مسار NPU/XPU هو أكبر مجهول. يتحسّن التقديم أحادي العقدة للمورد أياً كان، لكن ما إذا كان disaggregation الموزع لـ llm-d وتوجيه KV الدقيق يعملان على أجهزة NPU/XPU هو أمر لا يزال قيد التحقق. يوفر بعض الموردين فصلهم الخاص (مثل Rebellions RSD)، لذا قد يكون تكوين "مكدّس مورد مستقل" أكثر واقعية من "NPU فوق llm-d". كذلك مراجع النماذج الكبيرة أقل مقارنة بـ GPU. ذاكرة خادم واحد كافية للنماذج بحجم 70B، لكن نماذج MoE بحجم 744B تحتاج عقداً متعددة والمراجع العامة شحيحة. هذه القيود تعكس الحالة الراهنة لنظام NPU/XPU البيئي بأكمله، وليس أي مورد بعينه؛ كون مشروعنا التجريبي سيصبح مرجعاً هو فرصة ومخاطرة في آن واحد.

النتيجة المعاكسة: إذا كان الهدف حصراً هو أعلى معدل معالجة في أقصر وقت، فإن إضافة NPU/XPU لا تزيد إلا التعقيد. في هذه الحالة، GPU و llm-d كافيان. قيمة المسرّعات البديلة لا تتحقق إلا عندما توجد أهداف استراتيجية منفصلة: كفاءة الطاقة وتنويع سلسلة التوريد والسيادة. وبالمثل، إذا كان النموذج يندرج في عقدة واحدة وحجم حركة المرور منخفض، فإن llm-d نفسه استثمار مفرط و vLLM المستقل هو الإجابة الصحيحة.

## منظور ThakiCloud: استدلال غير مقيّد بالمسرّعات

السبب الذي يجعلنا نركز على هذه البنية بسيط. الخاصية الوحيدة التي تجعل تنسيق llm-d مستقلاً عن المسرّع هي ما يجعل تشغيل مجموعات GPU ومجموعات NPU/XPU المتنوعة في نفس الكلستر دون ارتباط بمورد معين ممكناً بالتصميم، مما يُنشئ إعداداً للاستدلال بذكاء اصطناعي سيادي.

هذا مهم استراتيجياً بالنسبة لنا كمزود لمنصات الذكاء الاصطناعي المحلية. يجب أن يتمكن العملاء من اختيار المسرّعات بحرية بناءً على ميزانية الطاقة وسلسلة التوريد ومتطلبات التصنيع المحلي، وألا يُترجم هذا الاختيار إلى تكلفة إعادة هندسة مكدّس الاستدلال بالكامل. الارتباط بـ NPU واحد محدد لا يفعل سوى استبدال ارتباط GPU بارتباط آخر. يُزيل تجريد vLLM واستقلالية llm-d عن المسرّع كلاً من هذه التكلفة وهذا الارتباط معاً. سياسة غير متجانسة ترسل أحمال العمل الكبيرة أو ذات الكمون المنخفض إلى GPU والأحمال المتوسطة أو الحساسة للطاقة إلى NPU/XPU يمكن تطبيقها على نفس منطق التوجيه بغض النظر عن مجموعة الموردين المختارة.

بالطبع، كل هذا تصميم مرجعي وما زال قبيل التحقق التجريبي. لذلك نُثبّت تعريفات القياس أولاً ونسلك المسار المرحلي: خط أساس GPU، بوابات كمية، ثم توسع إلى NPU.

## الخاتمة

الدرس من llm-d هو أن كفاءة الاستدلال مسألة جدولة، وليست مسألة شراء أجهزة. إلغاء العمليات المتكررة بتوجيه KV-cache الواعي وتثبيت الاستخدام بفصل prefill عن decode يسمح بمعالجة طلبات أكثر من نفس GPU. وبما أن هذا التنسيق مستقل عن المسرّع، تنفتح الطريق لتوسيعه بأي NPU/XPU فوق GPU (Rebellions و Furiosa وأي مسرّع متوافق مع vLLM) لبناء استدلال سيادي غير مرتبط بأي مورد.

تُحقَّق ThakiCloud من هذه البنية غير المتجانسة للاستدلال على Kubernetes و Kueue و ArgoCD. تعرّف على المزيد عبر موقعنا الإلكتروني.

## المصادر

- Red Hat Developer, Master KV cache aware routing with llm-d: [https://developers.redhat.com/articles/2025/10/07/master-kv-cache-aware-routing-llm-d-efficient-ai-inference](https://developers.redhat.com/articles/2025/10/07/master-kv-cache-aware-routing-llm-d-efficient-ai-inference)
- الموقع الرسمي لـ llm-d: [https://llm-d.ai/](https://llm-d.ai/)
- llm-d + KServe + vLLM في الإنتاج: [https://llm-d.ai/blog/production-grade-llm-inference-at-scale-kserve-llm-d-vllm](https://llm-d.ai/blog/production-grade-llm-inference-at-scale-kserve-llm-d-vllm)
- llm-d على GitHub: [https://github.com/llm-d/llm-d](https://github.com/llm-d/llm-d)
- Rebellions, LLM Serving with NPU: [https://rebellions.ai/llm-serving-with-npu/](https://rebellions.ai/llm-serving-with-npu/)
- Red Hat Developer, Running AI inference on Rebellions ATOM NPU: [https://developers.redhat.com/articles/2026/05/27/running-ai-inference-rebellions-atom-npu-red-hat-ai](https://developers.redhat.com/articles/2026/05/27/running-ai-inference-rebellions-atom-npu-red-hat-ai)
- إضافة vLLM-RBLN: [https://github.com/rebellions-sw/vllm-rbln](https://github.com/rebellions-sw/vllm-rbln)
- مواصفات FuriosaAI RNGD وخادم NXT RNGD: [https://furiosa.ai/rngd](https://furiosa.ai/rngd)
- مركز مطوري FuriosaAI (Furiosa-LLM، متوافق مع vLLM): [https://developer.furiosa.ai/](https://developer.furiosa.ai/)
- الأجهزة المدعومة في vLLM (مصفوفة الواجهات الخلفية): [https://docs.vllm.ai/](https://docs.vllm.ai/)
- مؤسسة PyTorch، واجهات خلفية متعددة لـ vLLM: [https://pytorch.org/blog/pytorch-foundation-welcomes-vllm/](https://pytorch.org/blog/pytorch-foundation-welcomes-vllm/)

ملاحظة: مخططات البنية تصاميم مرجعية مبنية على مصادر عامة ولا تُشكّل توصية بأي مورد مسرّعات محدد. Rebellions و Furiosa مثالان على NPUs المتوافقة مع vLLM؛ تنطبق نفس المبادئ على NPUs/XPUs الأخرى المدعومة من vLLM (Intel Gaudi/XPU و Google TPU و AWS Neuron و IBM Spyre و Huawei Ascend وغيرها). بعض مواصفات الشرائح غائبة من أوراق البيانات العامة وتُركت فارغة. تكامل NPU/XPU فوق llm-d فرضية تصميمية مشروطة بالواجهة الخلفية لـ vLLM لدى كل مورد ولم يُتحقق منها تجريبياً بعد. أرقام الأداء تعتمد على البيئة؛ دائماً ميّز بين معدل التدفق المفرد والمجمّع عند تفسيرها.
