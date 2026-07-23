---
title: "vLLM مقابل Ollama - استدلال LLM المحلي: متى تختار أيهما"
excerpt: "نعيد اختبار المفهوم الشائع بأن Ollama سهل وvLLM سريع، باستخدام معايير أداء RTX 4090 المنشورة عام 2026. الفجوة لا تتجاوز 13% عند مستخدم واحد، غير أنها تبلغ نحو ستة أضعاف في الإنتاجية عند 50 مستخدماً متزامناً. نستعرض منحنيات التوسع التي يصنعها PagedAttention والتجميع المستمر، إضافة إلى دلالات ذلك لخدمة ThakiCloud على Kubernetes."
seo_title: "مقارنة معايير أداء vLLM مقابل Ollama للاستدلال المحلي على LLM (2026) - Thaki Cloud"
seo_description: "مقارنة بين vLLM وOllama من حيث الإنتاجية والكمون واستهلاك VRAM عبر معايير أداء RTX 4090. PagedAttention والتجميع المستمر ومنحنيات التوسع المتزامن واعتبارات الخدمة متعددة المستأجرين على Kubernetes."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - vllm
  - ollama
  - llm-serving
  - kubernetes
  - inference
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/vllm-vs-ollama-local-inference/"
reading_time: true
categories:
  - dev
---

حين تبحث عن كيفية تشغيل نموذج لغوي كبير محلياً، يظهر اسمان في الغالب: Ollama وvLLM. وكثيراً ما تقرأ حججاً قاطعة من قبيل "إن كنت تريد الأداء فلا تستخدم Ollama، استخدم vLLM". هل هذا صحيح؟ الإجابة المختصرة: نصفه فقط. الجهاز المحمول الذي يستخدمه شخص واحد بطلب واحد في كل مرة مشكلة مختلفة تماماً عن خادم يخدم عشرات المستخدمين المتزامنين. يستند هذا المقال إلى أرقام معايير أداء RTX 4090 المنشورة عام 2026 لدراسة أين تتباين الأداتان، وما دلالة ذلك التباين لمنصة ThakiCloud المستندة إلى Kubernetes.

## نظرة عامة

كلتا الأداتين محرك استدلال لتشغيل نماذج لغوية كبيرة محلياً أو على بنية تحتية خاصة، غير أن أهدافهما التصميمية تختلف. Ollama مصنوع ليتيح لشخص واحد سحب نموذج بسرعة وتشغيله بأدنى احتكاك. التثبيت بسيط وإدارة النماذج مدمجة فيه، والخادم الخفيف المكتوب بـGo يبدأ سريعاً. أما vLLM فهو محرك خدمة إنتاجي مصمم من الأساس لإشباع GPU واحد بطلبات متزامنة متعددة وتعظيم الإنتاجية، وأبرز أسلحته PagedAttention والتجميع المستمر (continuous batching).

لماذا يعود هذا التمييز إلى الواجهة الآن؟ خضعت كلتا الأداتين لتغييرات معمارية جوهرية بعد عام 2024. حسّن Ollama تحسينات نواة llama.cpp ومسارات الاستدلال بالتكميم لرفع أداء التدفق الواحد، بينما بسّط vLLM تجربة التثبيت مع مواصلة تطوير PagedAttention والتشفير التخميني. معايير الأداء القديمة لم تعد تعكس الواقع الحالي، لذا يستحق الأمر مراجعة بأرقام حديثة.

تعالج ThakiCloud طلبات استدلال من عملاء متعددين على مجمع GPU مشترك في بيئة متعددة المستأجرين. في هذا السياق، سؤال "هل هو سريع لمستخدم واحد؟" شبه عديم المعنى؛ ما يهم هو "هل يصمد حين يتدفق المستخدمون في آن واحد؟". من هذه الزاوية نستعرض منحنيات التوسع لكلتا الأداتين.

## ماهية كل أداة

الفارق الحاسم بين المحركين يكمن في طريقة إدارة ذاكرة تخزين KV المؤقتة. خلال التوليد، يتراكم في المحول مفاتيح وقيم الرموز السابقة في ذاكرة مؤقتة. هذه الذاكرة هي المستهلك الأكبر لذاكرة GPU. يخصص Ollama وllama.cpp كتلة ذاكرة متجاورة لكل طلب مسبقاً. التنفيذ بسيط، لكن مع تزايد الطلبات المتزامنة يتراكم التشرذم وتصطدم القدرة على المعالجة الموازية بسقف سريع.

يعامل PagedAttention في vLLM ذاكرة KV المؤقتة كصفحات ذاكرة افتراضية في نظام تشغيل. التخصيص في كتل صغيرة غير متجاورة عند الحاجة يعني أن نفس VRAM يستوعب تسلسلات متزامنة أكثر بكثير. يضاف إلى ذلك التجميع المستمر: حين يصل طلب جديد يُدرج في الدفعة النشطة فوراً دون انتظار انتهاء الطلبات السابقة. هذان العاملان معاً يفسران لماذا يرسم vLLM منحنى مختلفاً تحت ضغط التزامن.

يوضح المخطط أدناه الفارق في كيفية معالجة كل محرك للطلبات المتزامنة.

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
<div class="d3-arch" data-arch-root id="lmvsollamalocalinference-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1125, "height": 584, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 504, "h": 528, "label": "Ollama / llama.cpp - FIFO Queue", "lx": 36, "ly": 42}, {"x": 548, "y": 24, "w": 545, "h": 528, "label": "vLLM - Continuous Batching + PagedAttention", "lx": 560, "ly": 42}], "nodes": [{"id": "Q1", "x": 85, "y": 187, "w": 120, "h": 46, "title": "Request 1"}, {"id": "EXEC1", "x": 129, "y": 319, "w": 170, "h": 46, "title": "Sequential Execution"}, {"id": "Q2", "x": 172, "y": 63, "w": 120, "h": 46, "title": "Request 2"}, {"id": "WAIT", "x": 260, "y": 187, "w": 120, "h": 46, "title": "Queue Wait"}, {"id": "Q3", "x": 347, "y": 63, "w": 120, "h": 46, "title": "Request N"}, {"id": "KVC", "x": 108, "y": 451, "w": 212, "h": 62, "title": ["Contiguous KV Cache (fixed", "block per request)"]}, {"id": "R1", "x": 585, "y": 63, "w": 120, "h": 46, "title": "Request 1"}, {"id": "BATCH", "x": 760, "y": 187, "w": 121, "h": 46, "title": "Unified Batch"}, {"id": "R2", "x": 760, "y": 63, "w": 120, "h": 46, "title": "Request 2"}, {"id": "R3", "x": 935, "y": 63, "w": 120, "h": 46, "title": "Request N"}, {"id": "PAGED", "x": 725, "y": 311, "w": 191, "h": 62, "title": ["PagedAttention KV Pages", "(dynamic allocation)"]}, {"id": "GPU", "x": 728, "y": 451, "w": 184, "h": 62, "title": ["Merged into Single GPU", "Compute"]}], "edges": [{"src": "Q1", "dst": "EXEC1", "kind": "data", "curve": [[145, 233], [145, 272], [145, 272], [191, 319]]}, {"src": "Q2", "dst": "WAIT", "kind": "data", "curve": [[232, 109], [232, 148], [232, 148], [287, 187]]}, {"src": "Q3", "dst": "WAIT", "kind": "data", "curve": [[407, 109], [407, 148], [407, 148], [352, 187]]}, {"src": "WAIT", "dst": "EXEC1", "kind": "data", "curve": [[320, 233], [320, 272], [320, 272], [249, 319]]}, {"src": "EXEC1", "dst": "KVC", "kind": "data", "line": [214, 365, 214, 451]}, {"src": "R1", "dst": "BATCH", "kind": "data", "curve": [[645, 109], [645, 148], [645, 148], [760, 189]]}, {"src": "R2", "dst": "BATCH", "kind": "data", "line": [820, 109, 820, 187]}, {"src": "R3", "dst": "BATCH", "kind": "data", "curve": [[995, 109], [995, 148], [995, 148], [881, 189]]}, {"src": "BATCH", "dst": "PAGED", "kind": "data", "line": [820, 233, 820, 311]}, {"src": "PAGED", "dst": "GPU", "kind": "data", "line": [820, 373, 820, 451]}]});
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
      const container = document.getElementById('lmvsollamalocalinference-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'lmvsollamalocalinference-1';
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

باختصار، Ollama محسّن لمعالجة طلب واحد بشكل نظيف في كل مرة؛ vLLM محسّن لدمج طلبات متعددة في عملية GPU واحدة. هذا الفارق التصميمي يظهر مباشرة في أرقام معايير الأداء.

## التثبيت والتكامل

تشغيل كلتا الأداتين عبر Docker هو الأسلوب الأنظف من حيث قابلية الإعادة. Ollama يبدأ هكذا:

```bash
docker run -d --gpus=all -v ollama:/root/.ollama \
  -p 11434:11434 --name ollama ollama/ollama
docker exec -it ollama ollama run llama3.1:8b
```

يمكن تشغيل vLLM مباشرة من صورة الخادم المتوافقة مع OpenAI:

```bash
docker run --gpus all -p 8000:8000 \
  --ipc=host vllm/vllm-openai:latest \
  --model meta-llama/Llama-3.1-8B-Instruct \
  --dtype auto
```

كلا الخادمين يكشفان واجهة برمجية متوافقة مع OpenAI، فيمكن الإبقاء على كود العميل متطابقاً لكليهما:

```bash
curl http://localhost:8000/v1/completions \
  -H "Content-Type: application/json" \
  -d '{"model":"meta-llama/Llama-3.1-8B-Instruct","prompt":"مرحباً","max_tokens":64}'
```

لضمان قابلية الإعادة، يُنصح بتثبيت digests الصور. توصي معايير الأداء العامة بتسجيل RepoDigest عبر `docker inspect ollama/ollama:<tag>` و`docker inspect vllm/vllm-openai:<tag>`، وحفظ مخرجات `ollama --version` و`pip show vllm` جنباً إلى جنب مع النتائج. حتى تغيير إصدار واحد قد يزعزع الأرقام.

إفصاح ضروري: كُتب هذا المقال على Apple Silicon (macOS, MPS)، لذا لم يكن بالإمكان إعادة إنتاج معايير أداء vLLM المستندة إلى CUDA مباشرة. الأرقام أدناه مستشهد بها من معيار أداء عام على نفس العتاد (SitePoint، مارس 2026، RTX 4090). المصدر مذكور في نهاية المقال. الأرقام المأخوذة من قياسات الآخرين تُبقى متمايزة عن أي ادعاء بأنها قياساتنا.

## نتائج معايير الأداء (استشهاد بمعيار أداء عام)

بيئة معيار الأداء المستشهد به: GPU - NVIDIA RTX 4090 (24GB)، CPU - AMD Ryzen 9 7950X، ذاكرة عشوائية 64GB DDR5، Ubuntu 24.04، CUDA 12.6، Python 3.12. النماذج المقارنة هي Llama 3.1 8B وDeepSeek-R1-Distill-Llama-8B بموجّهات متطابقة.

أولاً، إنتاجية المستخدم الواحد التسلسلية. خلافاً للاعتقاد الشائع، لا يتفوق vLLM تفوقاً ساحقاً. لنموذج Llama 3.1 8B، أنتج Ollama (Q4_K_M) نحو 62 رمزاً/ث، وأنتج vLLM (FP16) نحو 71 رمزاً/ث، وvLLM AWQ نحو 68 رمزاً/ث. الفجوة البالغة نحو 13% تأتي من اختلافات التكميم أكثر مما تأتي من المزايا المعمارية. مع مستخدم واحد، يعوّض انخفاض حمل خادم Ollama وتحسينات نواة التكميم المزايا البنيوية لـvLLM.

تتغير الصورة كلياً تحت ضغط التزامن. الجدول أدناه يُظهر إجمالي إنتاجية الرموز (رمز/ث) بحسب عدد المستخدمين المتزامنين.

| التكوين | Ollama | vLLM FP16 | vLLM AWQ |
|---|---|---|---|
| Llama 3.1 8B، مستخدم واحد | 62 | 71 | 68 |
| Llama 3.1 8B، 10 مستخدمين | 148 | 485 | 452 |
| Llama 3.1 8B، 50 مستخدماً | 155 | 920 | 875 |
| DeepSeek-R1 8B، مستخدم واحد | 58 | 67 | 63 |
| DeepSeek-R1 8B، 10 مستخدمين | 135 | 445 | 418 |
| DeepSeek-R1 8B، 50 مستخدماً | 142 | 840 | 795 |

عند 10 مستخدمين متزامنين يتقدم vLLM بنحو 3.3 أضعاف، وعند 50 مستخدماً يصل التقدم إلى نحو 6 أضعاف. Ollama يعالج عبر قائمة انتظار FIFO - أي بشكل تسلسلي فعلياً - لذا يكاد إجمالي الإنتاجية يبقى ثابتاً مع ازدياد التزامن. في المقابل، يمتص vLLM الطلبات المتزامنة بالتجميع المستمر ويتوسع قريباً من التناسب الخطي.

![مخطط مقارنة إجمالي إنتاجية الرموز بحسب عدد المستخدمين المتزامنين - Ollama مقابل vLLM]({{ '/assets/images/vllm-vs-ollama-local-inference-results.webp' | relative_url }})

الكمون يروي القصة ذاتها من زاوية مختلفة. عند مستخدم واحد، يبلغ زمن الاستجابة الأولى (TTFR) نحو 45 مللي ثانية لـOllama ونحو 82 مللي ثانية لـvLLM، أي Ollama أسرع. عند 50 مستخدماً متزامناً تنعكس الأدوار. يقفز TTFR الخاص بـOllama إلى نحو 3200 مللي ثانية مع تكدس الطلبات في الانتظار، بينما يحافظ vLLM على نحو 145 مللي ثانية بفضل التجميع المستمر. الأداة الأسرع في العزل تصبح الأبطأ تحت الحمل.

استهلاك الموارد يجلّي المفاضلة بوضوح. في وضع الخمول مع Llama 3.1 8B، يستخدم Ollama نحو 5.2GB VRAM ويستخدم vLLM FP16 نحو 16.1GB. عند 50 مستخدماً متزامناً يبقى Ollama قرب 5.4GB بينما يرتفع vLLM FP16 إلى نحو 21.8GB بسبب التخصيص الديناميكي للصفحات لذاكرة KV المؤقتة للتسلسلات النشطة. النسخة AWQ أكثر تحفظاً عند نحو 12.4GB تحت نفس الحمل. استهلاك ذاكرة النظام ووحدة المعالجة المركزية أيضاً أقل لـOllama (نحو 1.8GB مقابل 4.6GB في الخمول). الإنتاجية الأعلى لـvLLM ليست مجانية بل تُدفع ثمناً من VRAM وذاكرة نظام أكبر.

## تجربة المطور والنظام البيئي

إلى جانب الأداء، تجربة المطور تحكم التكلفة التشغيلية. Ollama يُثبَّت بأمر واحد، و`ollama run` يشغّل نموذجاً مع إدارة تحميل وتكميم مدمجة. انخفاض حاجز الدخول جعله يبدو أداة هواة في البداية، غير أنه يظهر اليوم على نطاق واسع في خطوط CI لموجّهات مراجعة الكود وعمليات النشر على الحافة كـJetson Orin وسلاسل أدوات المطورين الداخلية.

كان vLLM يستلزم في السابق إلماماً بأدوات ML بـPython، لكن تجربة التثبيت تبسّطت كثيراً في الإصدارات الأخيرة. سحب صورة الخادم المتوافقة مع OpenAI وتشغيلها يتيح ربط كود عميل OpenAI الحالي بتغييرات طفيفة. الميزات الإنتاجية الثرية - التوازي التنسوري، والتشفير التخميني، ومحولات LoRA القابلة للتبادل السريع - تمثّل ميزة بيئية واضحة. وبما أن كلتا الأداتين تتشاركان واجهة OpenAI المتوافقة، يكون الانتقال من Ollama في التطوير إلى vLLM في الإنتاج سلساً نسبياً.

## منصة ThakiCloud K8s AI/ML SaaS - التطبيق والاستخلاصات

هذه المقارنة تشرح بدقة لماذا تعتمد ThakiCloud محركات عائلة vLLM معياراً للخدمة متعددة المستأجرين. منصتنا ليست مستخدماً واحداً يحتكر نموذجاً واحداً. طلبات عملاء متعددين تتدفق بشكل متزامن عبر مجمع GPU مشترك. في هذا السياق، المهم ليس سرعة التدفق الواحد بل منحنى توسع التزامن واستقرار الكمون تحت الحمل. عند 50 مستخدماً متزامناً، 6 أضعاف الإنتاجية وكمون أقل بأكثر من 20 مرة يُترجمان مباشرة إلى عدد المستأجرين الذين يمكن لـGPU واحد خدمتهم، أي تكلفة الوحدة.

تشغيلياً، نشر ThakiCloud حاويات خدمة vLLM على Kubernetes ويُنظّم أحمال عمل GPU بـKueue. حمل عمل الخدمة يبدو تقريباً هكذا:

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-llama31-8b
spec:
  replicas: 1
  template:
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model=meta-llama/Llama-3.1-8B-Instruct"
            - "--max-num-seqs=64"
            - "--gpu-memory-utilization=0.90"
          resources:
            limits:
              nvidia.com/gpu: "1"
          ports:
            - containerPort: 8000
```

`--max-num-seqs` و`--gpu-memory-utilization` هما مقبضا الضبط الرئيسيان. التغير الديناميكي في VRAM الخاص بـPagedAttention متغير لا بد من حسابه عند تصميم حدود ذاكرة الحاوية وسياسة تقسيم GPU. كما تُظهر الأرقام أعلاه، ينتقل VRAM من 16GB إلى 22GB مع ارتفاع التزامن، لذا التخصيص الثابت يُوقعك إما في نفاد الذاكرة أو الاستغلال الناقص. لذلك نقيس الحد الأقصى للتسلسلات المتزامنة وسقف ذاكرة KV المؤقتة لكل نموذج ونحدد موارد الحاوية وفقاً لذلك. Kueue يُبقي المهام في الانتظار حتى تتوفر طاقة GPU ويُوزّعها عند الإفراج، مما يمنع الاشتراك الزائد في GPU حتى حين يتدفق مستأجرون كثيرون في آن واحد.

هذا لا يجعل Ollama عديم الجدوى. لاختبار النماذج الأولية محلياً من قِبل المطورين الداخليين، وبيئات العرض التجريبي للمستخدم الواحد، وموجّهات مراجعة الكود الخفيفة في خطوط CI، تُعدّ سرعة بدء Ollama وانخفاض حد موارده ميزة حقيقية. بالنسبة لـThakiCloud الحد واضح: الاستدلال الإنتاجي المتعدد المستأجرين الموجّه للعملاء يستخدم vLLM؛ سير عمل المطور الفردي وعروض الحافة تستخدم Ollama. للعملاء الذين يشترطون الاستضافة الذاتية داخل مقارّهم حيث لا يمكن نقل البيانات خارجها (متطلبات أمنية حكومية وما شابهها)، حقيقة أن كلا المحركين يمكن تشغيلهما على GPU خاص بهم تُعدّ في حد ذاتها جوهر عرض القيمة.

## القيود والتحفظات

بعض النقاط الجديرة بالتوضيح. أولاً، معايير الأداء المستشهد بها مبنية على RTX 4090 واحدة. إعدادات متعددة GPU أو نماذج أكبر من 70B أو تكوينات التوازي التنسوري قد تُنتج منحنيات مختلفة. في تلك السيناريوهات يكاد vLLM يكون الخيار الوحيد العملي، لكن الأرقام الدقيقة تستلزم قياساً على العتاد ذي الصلة.

ثانياً، ضعف Ollama في التزامن يعكس الإصدار المختبر. Ollama يحسّن آليات التجميع بنشاط، وقد تتقلص الفجوة في إصدارات مستقبلية. معاملة "Ollama ضعيف في التزامن" باعتبارها حقيقة دائمة خطأ. الأدوات تتغير بسرعة.

ثالثاً، الإنتاجية العالية لـvLLM لها تكلفة حقيقية: VRAM وذاكرة نظام أكثر، وتعقيد تشغيلي أعلى، وحمل إضافي من وقت تشغيل Python. نشر vLLM لأحمال عمل تكاد لا تحوي طلبات متزامنة هو إفراط في التصميم. اختيار الأداة لا ينبغي أن ينطلق من "أيهما أسرع" بل من "أين يقع ملف تزامن حمل العمل لديّ".

أخيراً، الأرقام الجوهرية في هذا المقال مستشهد بها من معيار أداء عام وليست من قياساتنا. قياسات إعادة الإنتاج في بيئة GPU الفعلية لدينا مخططة في مقال لاحق منفصل. تفضّل بقراءة المقال مع مراعاة أن الأرقام المأخوذة من قياسات جهة أخرى لا ينبغي تعميمها باعتبارها استنتاجاتنا الخاصة.

## المصادر

- SitePoint، "Ollama vs vLLM: Performance Benchmark 2026" (2026-03-05): [https://www.sitepoint.com/ollama-vs-vllm-performance-benchmark-2026/](https://www.sitepoint.com/ollama-vs-vllm-performance-benchmark-2026/)
- التوثيق الرسمي لـvLLM: [https://docs.vllm.ai](https://docs.vllm.ai)
- Ollama: [https://ollama.com](https://ollama.com)
