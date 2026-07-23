---
title: "النموذج المفتوح الأوزان الذي يضاهي GPT-5.5 بسُدس التكلفة: تحليل استضافة GLM-5.2 ذاتياً"
excerpt: "أصدرت Z.ai نموذج GLM-5.2، وهو نموذج كودينج MoE بحجم 744B بموجب رخصة MIT. تشير التقارير إلى أنه يتفوق على GPT-5.5 في اختباري SWE-bench Pro وTerminal-Bench بنحو سُدس التكلفة. أبدى الرئيس التنفيذي لـ Vercel إعجابه العلني بهذا النموذج. نفحص هنا ادعاءات الاختبارات المعيارية، ومتطلبات الاستضافة الذاتية عبر vLLM وSGLang، وانعكاسات ذلك على استراتيجية ThakiCloud للخدمة المحلية وخدمة الذكاء الاصطناعي السيادي."
seo_title: "تحليل استضافة نموذج GLM-5.2 المفتوح الأوزان للكودينج - Thaki Cloud"
seo_description: "التحقق من نتائج GLM-5.2 في SWE-bench Pro (62.1) وTerminal-Bench (81.0) (نموذج 744B MoE، MIT، سياق 1M)، ومراجعة متطلبات الاستضافة الذاتية FP8/8x H200/vLLM/SGLang، واستخلاص توجهات ThakiCloud لخدمة الذكاء الاصطناعي المحلي السيادي."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - glm-5-2
  - open-weight-llm
  - vllm
  - sglang
  - self-hosting
  - sovereign-ai
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/glm-5-2-open-weight-coding-moe/"
categories:
  - dev
published: false
---

## نظرة عامة

تقليص الفجوة بين النماذج المفتوحة الأوزان وقدرات الكودينج في الطليعة قصة متواصلة على مدى العام الماضي، غير أن GLM-5.2 في يونيو 2026 يمثّل نقطة تحوّل واضحة في هذا المسار. أعلن غييرمو راوخ، الرئيس التنفيذي لـ Vercel، دهشته العلنية من قدرات GLM-5.2 في الكودينج، ما أثار جدلاً واسعاً في أوساط المطورين، وسرعان ما تلاه إعلان نتائج اختبارات مستقلة تُظهر تفوّقه على GPT-5.5 في مهام كودينج متعددة طويلة الأفق. التفصيل الأهم هو السعر: تقديم أداء مماثل بنحو سُدس التكلفة، إلى جانب إتاحة الأوزان بموجب رخصة MIT، يدفع هذا النموذج إلى ما هو أبعد من مجرد أخبار الاختبارات المعيارية، ليصبح متغيراً حقيقياً في قرارات البنية التحتية.

بالنسبة لمنصة مثل ThakiCloud تُشغّل منصة AI/ML SaaS على Kubernetes، هذا التوليف لا يمكن تجاهله. إن أمكن نشر نموذج كودينج على مستوى الطليعة داخل حدود بيانات العميل، بعيداً عن الاعتماد على واجهات برمجية مغلقة، وبتكلفة محكومة، فذلك منتج قابل للتسويق مباشرةً للعملاء الذين تشترطون الاستضافة المحلية أو الذكاء الاصطناعي السيادي. تتناول هذه المقالة أولاً التحقق من الحقائق المتاحة للعامة حول GLM-5.2، ثم توضيح ما تستلزمه الاستضافة الذاتية فعلياً، وأخيراً دلالات ذلك من منظور منصتنا. تشغيل النموذج بأنفسنا على ثمانية وحدات H200 خارج نطاق هذه المقالة، وعليه فإن كل رقم مذكور هنا مستقى من وثائق ومصادر إعلامية متاحة للعموم، وما لم نتمكن من التحقق منه مباشرةً يُشار إليه صراحةً.

## ما هو هذا النموذج

GLM-5.2 نموذج Mixture-of-Experts ضخم أصدرته Z.ai (zai-org)، وهي مختبر صيني للذكاء الاصطناعي، في 13 يونيو 2026. إجمالي المعاملات 744B، في حين تبلغ المعاملات المُفعَّلة لكل رمز حوالي 40B، وهو مستوى مشابه للجيل السابق GLM-5.1. هذه هي جوهر بنية MoE: توسيع الطاقة الإجمالية إلى حد كبير مع تقييد عدد الخبراء المشاركين فعلياً في كل خطوة استنتاج، مما يُبقي تكلفة الاستنتاج في حدود المقبول. قبل الانزعاج من رقم 744B، المهم إدراك أن الحساب الفعلي يجري على مستوى الـ 40B، وهو الرقم الحاسم عند تقدير تكلفة الاستضافة الذاتية.

التغيير الأبرز هو نافذة السياق. يدعم GLM-5.2 مليون (1M) رمز، أي نحو خمسة أضعاف حد 200K رمز تقريباً في GLM-5.1. يبلغ الحد الأقصى لحجم المخرجات 131,072 رمزاً. في مهام الكودينج طويلة الأفق كتحميل قاعدة كود ضخمة كاملةً في السياق وتنفيذ إعادة هيكلة شاملة عبر ملفات متعددة أو تتبع الأخطاء، يغدو حجم السياق هذا حاسماً. ويتجلى توجه التدريب نحو الكودينج في نتائج الاختبارات المعيارية.

الرخصة MIT، وهي من أكثر رخص المصدر المفتوح تساهلاً مع أدنى قيود على الاستخدام التجاري. يُعدّ هذا تمييزاً جوهرياً عن بعض نماذج الأوزان المفتوحة التي تحمل بنوداً تحظر الاستخدام التجاري. الأوزان متاحة على Hugging Face (zai-org/GLM-5.2-FP8)، والمصدر والوصفات في مستودع GitHub (zai-org/GLM-5)، وطريق بدء سريع متاح عبر مكتبة Ollama (glm-5.2).

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
<div class="d3-arch" data-arch-root id="glm52openweightcodingmoe-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 465, "height": 882, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 133, "y": 24, "w": 191, "h": 78, "title": ["GLM-5.2", "744B total parameters ·", "MoE"]}, {"id": "B", "x": 133, "y": 180, "w": 191, "h": 78, "title": ["MoE routing", "~40B active experts per", "token"]}, {"id": "C", "x": 256, "y": 336, "w": 177, "h": 62, "title": ["1M token context", "approx. 5x vs GLM-5.1"]}, {"id": "D", "x": 24, "y": 344, "w": 177, "h": 46, "title": "Coding-first training"}, {"id": "E", "x": 147, "y": 476, "w": 163, "h": 62, "title": ["Long-horizon coding", "workloads"]}, {"id": "F", "x": 133, "y": 616, "w": 191, "h": 62, "title": ["SWE-bench Pro 62.1", "Terminal-Bench 2.1 81.0"]}, {"id": "G", "x": 137, "y": 756, "w": 184, "h": 94, "title": ["MIT open-weight ·", "Self-hosting", "FP8 · 8x H200 · vLLM /", "SGLang"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [229, 102, 229, 180]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[287, 258], [345, 297], [345, 297], [345, 336]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[171, 258], [113, 297], [113, 297], [113, 344]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[345, 398], [345, 437], [345, 437], [280, 476]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[113, 390], [113, 437], [113, 437], [177, 476]]}, {"src": "E", "dst": "F", "kind": "data", "line": [229, 538, 229, 616]}, {"src": "F", "dst": "G", "kind": "data", "line": [229, 678, 229, 756]}]});
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
      const container = document.getElementById('glm52openweightcodingmoe-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'glm52openweightcodingmoe-1';
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
*من إجمالي الطاقة البالغة 744B، لا يُفعَّل سوى نحو 40B معاملة لكل رمز عبر توجيه MoE. يتضافر السياق البالغ 1M والتدريب المتخصص في الكودينج لتحقيق أداء متميز في مهام الكودينج طويلة الأفق.*

## الاختبارات المعيارية: أين تفوق GLM-5.2 على GPT-5.5

يستحق التحقق المباشر من ادعاءات الاختبارات المعيارية التي تقف في قلب التغطية الإعلامية. وفقاً للمعايير المستقلة، يُصنَّف GLM-5.2 حالياً بوصفه النموذج الأوزان المفتوحة الأبرز في الكودينج. الأرقام التفصيلية على النحو التالي.

| الاختبار المعياري | GLM-5.2 | GPT-5.5 | Claude Opus 4.8 |
|---|---|---|---|
| SWE-bench Pro | 62.1 | 58.6 | 69.2 |
| Terminal-Bench 2.1 | 81.0 | (score not available) | slightly ahead of GLM-5.2 |

طريقة القراءة: في SWE-bench Pro، يتقدم GLM-5.2 بنتيجة 62.1 على GPT-5.5 البالغة 58.6، لكنه يقصر عن Claude Opus 4.8 بنتيجة 69.2. في Terminal-Bench 2.1 يسجّل 81.0 ويُصنَّف في المرتبة الثانية قريباً من Claude Opus 4.8. الملخص الدقيق ليس "تفوّق على جميع نماذج الطليعة" بل "يقع مباشرةً تحت أفضل النماذج المغلقة بينما يتفوق على GPT-5.5، وهو واجهة برمجية مغلقة في نفس الفئة، في عدة مهام كودينج طويلة الأفق."

التكلفة تعمّق هذه الصورة. تشير التقارير إلى أن GLM-5.2 يحقق هذا المستوى من الأداء بنحو سُدس تكلفة GPT-5.5. فارق نقطة أو نقطتين في اختبار معياري مقبول في الغالب من الناحية العملية؛ فارق ستة أضعاف في التكلفة كافٍ لإعادة رسم استراتيجية البنية التحتية. للإشارة، يُسعَّر الباقة المُدارة الخاصة بـ Z.ai والمسماة GLM Coding Plan بحوالي 10 دولارات شهرياً للنسخة الخفيفة، و30 دولاراً للنسخة الاحترافية، و80 دولاراً للنسخة القصوى، مما يُتيح نقطة دخول منخفضة التكلفة للفرق الراغبة في التقييم قبل الالتزام بالاستضافة الذاتية.

## الاستضافة الذاتية: ما الذي يلزم لنشر 744B

إتاحة الأوزان لا تعني أن النموذج يعمل على جهاز محمول. فيما يلي ملخص لمتطلبات الأجهزة والبرمجيات المستقاة من أدلة النشر العامة ووصفات vLLM الرسمية لاستضافة نموذج MoE بحجم 744B ذاتياً. الأرقام أدناه منقولة من وثائق عامة لا مُعاد إنتاجها على إعدادنا الخاص من ثمانية وحدات H200، وسيلزم التحقق منها في البيئة الفعلية قبل النشر الإنتاجي.

نقطة التفتيش المُضغَّطة بـ FP8 تبلغ حجمها نحو 750GB. يُشير أحد التقارير إلى أن نسخة FP8 تستهلك نحو 753GB من ذاكرة GPU للأوزان وحدها. ميزة FP8 تكمن في تخفيض متطلبات الذاكرة إلى النصف مقارنةً بـ BF16. خادم مُجهَّز بثمانية وحدات H200 يوفر نحو 1,128GB من إجمالي VRAM، مما يُتيح هامشاً لذاكرة KV cache بعد تحميل أوزان FP8. عند أحمال عمل السياق البالغ 1M، يجب تفعيل FP8 KV cache، وحتى حينها يعمل الإعداد الثُماني H200 بهامش ضيّق.

الإطاران الأكثر شيوعاً في الخدمة: يشترط vLLM الإصدار 0.23.0 كحد أدنى، وينشر النموذج موزَّعاً على ثمانية وحدات GPU بالتوازي الموتري (tensor-parallel-size 8).

```bash
# Conceptual vLLM example (actual flags and versions require verification against official recipes)
vllm serve zai-org/GLM-5.2-FP8 \
  --tensor-parallel-size 8 \
  --kv-cache-dtype fp8 \
  --max-model-len 1000000
```

SGLang الخيار الآخر، وهو طبقة خدمة توليد منظّم مصممة حول الدُّفعات والطلبات المتزامنة. يدعم الفكّ المقيَّد للشيفرة بصورة افتراضية ويشارك KV cache عبر الطلبات بواسطة RadixAttention، مما يجعله نقطة انطلاق طبيعية لأحمال العمل ذات الطلبات المتزامنة الكثيرة. يُستخدم عادةً مع التوازي بين الخبراء (`--enable-moe-ep`) وFP8 KV cache (نمط `fp8_e5m2`).

النقطة التشغيلية الجوهرية واضحة: FP8 KV cache يُنصف استهلاك ذاكرة KV مع تأثير هزيل على الجودة، وهو ليس اختيارياً عند سياق 1M بل ضرورة. التوجيه الشائع في جميع حالات النشر هو أن FP8 هي نقطة البداية الواقعية لأي تقييم استضافة ذاتية أولي.

## تطبيق GLM-5.2 على منصة ThakiCloud K8s AI/ML SaaS

تُجدوِل منصة ThakiCloud للذكاء الاصطناعي أحمال عمل GPU على Kubernetes باستخدام Kueue، وتخدّم النماذج عبر vLLM، وتعزل استنتاجات المستأجرين المتعددين عن بعضها. يندمج GLM-5.2 في هذه البنية بحد أدنى من التعديلات.

أولاً، يُجيب مباشرةً على الطلب المتنامي للاستضافة المحلية والذكاء الاصطناعي السيادي. في بيئات كالقطاع المالي والجهات الحكومية والدفاع حيث يُحظر توجيه البيانات عبر واجهة برمجية خارجية أصلاً، لا يمكن استخدام حتى أكفأ النماذج السحابية المغلقة. GLM-5.2 بوصفه نموذجاً مفتوح الأوزان بموجب رخصة MIT يُتيح تشغيل نموذج كودينج على مستوى الطليعة داخل حدود بيانات العميل. سجِّل عقدة H200 ثُمانية في قائمة انتظار Kueue وتولَّ خدمتها بـ vLLM، ويصبح لديك مساعد كودينج لا تغادر منه بايتة واحدة المحيط الأمني. هذا يسير في الاتجاه ذاته تماماً الذي تبنّته ThakiCloud في مقترحها القيمي للاستضافة المحلية والذاتية.

ثانياً، هيكل التكلفة. إن صحّ رقم سُدس التكلفة، يصبح بمقدورنا أن نعرض على العملاء بنية تحتية بسعر ثابت قابل للتنبؤ قائمة على الاستضافة الذاتية بدلاً من إعادة بيع واجهة برمجية مغلقة. خاصية 40B معاملة نشطة في MoE تُبقي تكلفة الاستنتاج لكل طلب في نطاق مُسيطَر عليه رغم حجمه الإجمالي البالغ 744B. مشاركة وحدات GPU بين المستأجرين المتعددين وإعادة استخدام KV cache عبر RadixAttention في SGLang يرفعان معدل الإنتاجية لكل عقدة، مما يُخفّض تكلفة الوحدة أكثر.

ثالثاً، سياق 1M يتوافق مع أحمال العمل الوكيلة التي تتجه نحوها منصتنا. وكيل كودينج متخصص يُحمّل قاعدة الكود الداخلية بأكملها أو مستودع التوثيق في السياق ويعمل باستمرارية طويلة الأفق ليس منتجاً ممكن البناء على نموذج قصير السياق. غير أن سياق 1M يستهلك ذاكرة KV cache بصورة مكثفة، لذا في بيئة متعددة المستأجرين يلزم أن يتضمن التصميم سياسات تُحدد الحد الأقصى لطول السياق لكل مستأجر ويُطبَّق ذلك على مستوى طبقة الخدمة.

## القيود والحجج المضادة

يجب أن تُصاغ الحجة المضادة بوضوح مماثل للحجة الأصلية. GLM-5.2 ليس الأفضل في كل الجوانب. تأخّر نتيجته في SWE-bench Pro (62.1) عن Claude Opus 4.8 (69.2) بأكثر من سبع نقاط. حين تكون جودة الكودينج المطلقة الأولوية القصوى وتسمح البيئة بتمرير البيانات عبر واجهة برمجية خارجية، تظل النماذج المغلقة الأفضل خياراً عقلانياً. قيمة GLM-5.2 ليست "الأقوى مطلقاً" بل "الأقرب إلى الأقوى ضمن فئة النماذج القابلة للاستضافة الذاتية."

تستوجب أرقام الاختبارات المعيارية ذاتها تعاملاً متحفظاً. كل رقم في هذه المقالة منقول من تغطية مستقلة ووثائق عامة لا مُستخلَص من قياسات أجريناها بأنفسنا في ظروف موحّدة. تتأثر نتائج الاختبارات المعيارية بحزمة التقييم وصياغة المطالبات وإعدادات أخذ العينات، لذا يستلزم أي تقييم جدي للتبني إعادة القياس على المهام الداخلية التمثيلية قبل استخلاص أي استنتاجات.

الحاجز أمام الاستضافة الذاتية واقعي كذلك. عقدة ثُمانية H200 تنطوي على تكلفة اقتناء وتشغيل باهظة، والاستخدام الفعلي لسياق 1M يُقلّص عدد الطلبات المتزامنة التي يمكن خدمتها قبل أن يُشكّل ضغط KV cache عقبة. "يدعم سياق 1M" و"يخدم سياق 1M للمستأجرين المتعددين في آن معاً" مشكلتان بمستويَي صعوبة مختلفَين جذرياً. علاوةً على ذلك، نظراً لأن هذا النموذج صادر عن مختبر صيني، قد يشترط بعض العملاء مراجعة من منظور سلسلة التوريد والحوكمة. كون النموذج مفتوح الأوزان يُتيح فحص الأوزان مباشرةً وتشغيلها في بيئة معزولة هوائياً، مما يُعالج هذا القلق إلى حد بعيد، لكنه بند يجب أن يظهر صراحةً في قرار التبني.

خلاصة القول، الصواب قراءة GLM-5.2 لا على أنه "بديل للنماذج المغلقة بلا تحفظات" بل على أنه "ظهور بديل جدي لواجهات برمجية مغلقة في أحمال العمل التي تكون فيها الاستضافة المحلية وسيادة البيانات والسيطرة على التكلفة أموراً جوهرية." وتلك أحمال العمل التي تتفوق فيها ThakiCloud أكثر من غيرها.

## المصادر

- [Z.ai's open-weights GLM-5.2 beats GPT-5.5 on multiple long-horizon coding benchmarks for 1/6th the cost (VentureBeat)](https://venturebeat.com/technology/z-ais-open-weights-glm-5-2-beats-gpt-5-5-on-multiple-long-horizon-coding-benchmarks-for-1-6th-the-cost)
- [GLM-5.2: Features, Setup, Benchmarks, and Model Switching Guide (DataCamp)](https://www.datacamp.com/blog/glm-5-2)
- [zai-org/GLM-5 (GitHub)](https://github.com/zai-org/GLM-5)
- [zai-org/GLM-5.2-FP8 (Hugging Face)](https://huggingface.co/zai-org/GLM-5.2-FP8)
- [GLM-5 and GLM-5.1 Series Usage (vLLM Recipes)](https://docs.vllm.ai/projects/recipes/en/latest/GLM/GLM5.html)
- [Deploy GLM-5.2 on GPU Cloud (Spheron)](https://www.spheron.network/blog/deploy-glm-5-2-gpu-cloud/)
- [Running GLM-5.2 at Home: SGLang, vLLM, Transformers, KTransformers (Groundy)](https://groundy.com/articles/running-glm-5-2-at-home-sglang-vllm-transformers-and-ktransformers-setup-guide/)
