---
title: "أين تختنق فعلياً وكالات الصوت الفورية: حاسبة ميزانية زمن الاستجابة وقياسات تشغيل GPU"
seo_title: "ميزانية زمن استجابة وكيل الصوت الفوري + قياس أداء GPU ذاتي الاستضافة - Thaki Cloud"
seo_description: "نقدم voice-latency-budget، وهي حاسبة مفتوحة تقسّم زمن الاستجابة من انتهاء الكلام حتى صوت الاستجابة الأول إلى مراحل لتشخيص نقاط الاختناق، ونشارك قياسات لمكدسنا الفعلي (Qwen3-ASR وVoxCPM2 وQwen3-TTS وQwen3.5-9B) على وحدة RunPod H200 لبيان أين تكمن نقطة الاختناق الحقيقية في مكدس صوتي ذاتي الاستضافة. كما ننشر تحسين تكلفة قائم على تنزيل واحد لحجم شبكي وآلية ضمان تفكيك (teardown) قابلة لإعادة الإنتاج."
excerpt: "بنينا أداة مفتوحة تُشخّص أي مرحلة من وكيل الصوت لديك هي نقطة الاختناق، دون أي SDK من مزود، وقسنا مكدسنا الفعلي (Qwen3-ASR وVoxCPM2 وQwen3-TTS) على وحدة RunPod H200. كان التعرف على الكلام سريعاً؛ وكانت أداة تحويل النص إلى كلام غير المتدفقة هي نقطة الاختناق الحقيقية."
date: 2026-07-19
tags:
  - voice-agent
  - latency
  - vllm
  - qwen3-asr
  - voxcpm2
  - qwen3-tts
  - runpod
  - gpu-serving
  - ttft
  - llmops
  - real-time
categories:
  - llmops
author_profile: true
toc: true
toc_label: المحتويات
published: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/voice-agent-latency-budget-gpu-serving/"
---

كل من بنى وكيل صوت فوري يصطدم بالجدار نفسه. بمجرد أن يطول قليلاً زمن الاستجابة بين لحظة توقف المستخدم عن الكلام ولحظة إصدار الوكيل لصوته الأول، تبدأ المحادثة تبدو غير طبيعية. لكن حين تسأل "أي مرحلة من مكدسي بطيئة"، لا تأتي الإجابة بسهولة. كشف نهاية الكلام، والذهاب والإياب عبر الشبكة، والتعرف على الكلام (STT)، والرمز الأول من نموذج اللغة الكبير (LLM)، وتحويل النص إلى كلام (TTS)، كلها مراحل متسلسلة كالحلقات، وكل SDK من مزوّد لا يُظهر إلا أرقام مقطعه الخاص. يتناول هذا المقال أداة مفتوحة بنيناها لتشخيص هذه السلسلة كاملة بنظرة واحدة، تُدعى voice-latency-budget، إلى جانب نتائج قياس سيناريو الاستضافة الذاتية لهذه الأداة على وحدات GPU فعلية. هذا المقال موجّه لمهندسي البنية التحتية والذكاء الاصطناعي الذين يريدون تشغيل وكيل صوت فوري بأنفسهم. والخلاصة المختصرة: في الاستضافة الذاتية على GPU، لم تكن نقطة اختناق زمن الاستجابة في نموذج اللغة الكبير كما يُفترض عادة، بل في تصميم التزامن واختيار أداة تحويل النص إلى كلام.

## لماذا نحتاج إلى منظور ميزانية زمن الاستجابة

تشير الأبحاث إلى أنه عندما يتحدث شخصان، تتقارب الفجوة الزمنية بين انتهاء أحدهما من الكلام واستجابة الآخر إلى وسيط يبلغ نحو 200 ميلي ثانية بغض النظر عن اللغة (Stivers et al., 2009, PNAS). لكي يشعر وكيل الصوت الفوري بأنه "بشري"، يجب أن يكون الزمن من انتهاء الكلام إلى صوت الاستجابة الأول قريباً من هذا النطاق، وفي الممارسة العملية، يُعد البقاء دون الثانية الواحدة، أي أقل من 800 ميلي ثانية، هدفاً شائعاً. يتطابق هذا الرقم إلى حد كبير مع الأهداف التي ينشرها مزودو الخدمة أيضاً. تذكر Deepgram أقل من 300 ميلي ثانية، وتذكر Vapi أقل من 500 ميلي ثانية.

المشكلة هي كيفية توزيع هذه الميزانية الإجمالية. إذا استهلكت الشبكة 40 ميلي ثانية ذهاباً وإياباً، واستهلك التعرف على الكلام 300 ميلي ثانية، واستهلك الرمز الأول من نموذج اللغة الكبير 500 ميلي ثانية، تكون الميزانية قد تجاوزت حدها بالفعل. من الصعب الحكم بالحدس على أي مرحلة يجب تقليصها لتحقيق أكبر فائدة. لذلك بنينا حاسبة تُظهر الجدول الزمني التراكمي ونقطة الاختناق وما إذا كنت ضمن نطاق محادثة طبيعية فور إدخال زمن الاستجابة المتوقع لكل مرحلة. تعمل الأداة بالكامل من جانب المتصفح، دون خادم ودون مفتاح API، ولا تغادر مدخلاتك المتصفح أبداً. سعينا لبناء أداة نفع عام لا تروّج لمنتج بعينه.

تغطي الأداة سبع مراحل: كشف نهاية الكلام، والذهاب والإياب عبر الشبكة، والتعرف على الكلام، والرمز الأول من نموذج اللغة الكبير، وجاهزية الجملة الأولى، وتوليف تحويل النص إلى كلام، ومخزن التشغيل المؤقت. يحمل تلميح شريط التمرير لكل مرحلة نطاقاً معتاداً مستمداً من مواد عامة من عامي 2025 و2026، وحين تتجاوز نقطة اختناق ذلك النطاق تعرض الأداة توصية. يمكنك البدء من إعداد مسبق، وتراكب تهيئتين في وضع المقارنة، ورؤية قيمة p95 تقريبية تحت الحمل أيضاً.

تشكّل المراحل السبع سلسلة، ويجب أن يقع مجموع هذه الأزمنة ضمن الميزانية المستهدفة كي تبدو المحادثة طبيعية. في التدفق أدناه، كانت المرحلة التي استهلكت أكبر جزء من الميزانية فعلياً هي تحويل النص إلى كلام غير المتدفق.

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
<div class="d3-arch" data-arch-root id="tlatencybudgetgpuserving-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 212, "height": 1098, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 31, "y": 24, "w": 142, "h": 62, "title": ["End of utterance", "detection"]}, {"id": "B", "x": 42, "y": 164, "w": 120, "h": 62, "title": ["Network", "round-trip"]}, {"id": "C", "x": 31, "y": 304, "w": 142, "h": 62, "title": ["STT", "Qwen3-ASR ~133ms"]}, {"id": "D", "x": 42, "y": 444, "w": 120, "h": 62, "title": ["LLM", "first token"]}, {"id": "E", "x": 38, "y": 584, "w": 128, "h": 62, "title": ["First sentence", "ready"]}, {"id": "F", "x": 38, "y": 724, "w": 128, "h": 62, "title": ["TTS synthesis", "the bottleneck"]}, {"id": "G", "x": 42, "y": 864, "w": 120, "h": 62, "title": ["Playback", "buffer"]}, {"id": "H", "x": 24, "y": 1004, "w": 156, "h": 62, "title": ["First audio out", "target under 800ms"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [102, 86, 102, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [102, 226, 102, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [102, 366, 102, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [102, 506, 102, 584]}, {"src": "E", "dst": "F", "kind": "data", "line": [102, 646, 102, 724]}, {"src": "F", "dst": "G", "kind": "data", "line": [102, 786, 102, 864]}, {"src": "G", "dst": "H", "kind": "data", "line": [102, 926, 102, 1004]}]});
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
      const container = document.getElementById('tlatencybudgetgpuserving-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'tlatencybudgetgpuserving-1';
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

## كيف تتغيّر الأرقام عند الاستضافة الذاتية

يمكنك الحصول على فكرة تقريبية عن نطاق زمن استجابة واجهة برمجة تطبيقات متدفقة مُدارة من الوثائق. لكن "ما الرقم الذي نحصل عليه فعلياً حين نضع المحرك الذي نستخدمه حقاً على GPU" أمر لا يمكن معرفته دون قياسه مباشرة. لذلك أخذنا المكدس ذاته الذي كنا نشغّله محلياً على جهاز MacBook لأغراض التطوير، ووضعناه على وحدة RunPod H200 (بسعة 141 جيجابايت) لقياسه. كانت المحركات هي Qwen3-ASR-1.7B للتعرف على الكلام، وVoxCPM2 وQwen3-TTS-1.7B لتحويل النص إلى كلام، وأحدث نموذج Qwen3.5-9B لنموذج اللغة الكبير.

أولاً، ملاحظة حول كيفية خفض التكاليف. إذا أعدت تنزيل عشرات الجيجابايتات من النماذج وحزم CUDA في كل مرة تُنشئ فيها وحدة GPU، تبقى وحدة GPU المكلفة خاملة في انتظار التنزيل بينما تُحاسب على وقتها. لذلك قمنا بتنزيل البيئة الافتراضية والأوزان مرة واحدة فقط على حجم شبكي واحد (67 جيجابايت)، ثم جعلنا وحدة GPU تُركّب ذلك الحجم وتُجري القياس دون إعادة التنزيل. وضمِنّا حذف الوحدة والحجم بالكامل بعد الانتهاء باستخدام كتلة finally إضافة إلى شبكة أمان قائمة على الاسم لآلية التفكيك. بلغت التكلفة الإجمالية بما في ذلك تصحيح الأخطاء نحو 17 دولاراً، ولم تتسرب أي موارد.

## نتائج القياس: لم تكن نقطة الاختناق في نموذج اللغة الكبير ولا في التعرف على الكلام، بل في تحويل النص إلى كلام

هذه هي الأرقام التي قسناها على H200، على أساس طلب واحد.

| المحرك | النموذج | زمن الاستجابة (طلب واحد) | معامل الزمن الحقيقي (RTF) |
|---|---|---|---|
| STT | Qwen3-ASR-1.7B | 133 ميلي ثانية / 10 ثوانٍ صوت | 0.013 |
| TTS | VoxCPM2 (غير متدفق) | 673 ميلي ثانية / جملة | 0.149 |
| TTS | Qwen3-TTS-1.7B (غير متدفق) | 6778 ميلي ثانية / جملة | 1.205 |

لم يكن التعرف على الكلام مرحلة تستحق القلق. يقوم Qwen3-ASR بنسخ 10 ثوانٍ من الصوت في 133 ميلي ثانية. معامل زمن حقيقي قدره 0.013 يعني فعلياً استجابة فورية. القصة الحقيقية كانت في تحويل النص إلى كلام. على وحدة H200 نفسها، قام VoxCPM2 بتوليف الجملة الكورية نفسها في 0.67 ثانية، بينما استغرق Qwen3-TTS 6.8 ثانية. على البطاقة نفسها، يكون VoxCPM2 أسرع بنحو عشرة أضعاف. والمهم أن كلا المحركين غير متدفقين. ولأن الجملة كاملة يجب أن تُوَلَّف قبل صدور الصوت الأول، فإن حتى 0.67 ثانية عند VoxCPM2 ليست "زمن وصول أول صوت متدفق قدره 100 ميلي ثانية" بل هي "الصوت الأول بعد 0.67 ثانية". صحيح أن VoxCPM2 انخفض من نطاق الثواني المتعددة على MPS المحلي إلى 0.67 ثانية على GPU، لكن ذلك لا يعني أنه أصبح متدفقاً. لبناء دورة محادثة فورية حقيقية، عليك التحول إلى أداة تحويل نص إلى كلام متدفقة أو توليف الجمل على شكل مقاطع قصيرة. كان إظهار هذه النقطة تحديداً كرقم هو السبب الذي دفعنا لبناء هذه الأداة أصلاً.

## فجوة صريحة: تعطّل نموذج اللغة الكبير على هذا المضيف

لم نتمكن من الحصول على أرقام تشغيل vLLM لنموذج Qwen3.5-9B هذه المرة. لم يكن السبب أداء المحرك، بل عدم تطابق في إصدارات البنية التحتية. اعتباراً من يوليو 2026، يجلب أحدث إصدار من vLLM إصدار torch مبنياً لـ CUDA 13، بينما كان تعريف الوحدة على مضيف H200 المخصص لنا هو CUDA 12.8، فرفض المحرك العمل بحجة أن التعريف قديم جداً. وحين خفّضنا torch إلى إصدار متوافق مع 12.8، تعطّلت عمليات vLLM المُجمَّعة مسبقاً، وحين استخدمنا transformers كبديل، ظهرت أخطاء في مسار التوليد متعدد الوسائط. يتطلب كل محرك إصدار torch مختلفاً، وإصلاح واحد يُعطّل آخر، وهو تعارض تبعيات كلاسيكي. للحصول على أرقام vLLM نظيفة، تحتاج إلى مضيف مزوّد بتعريف CUDA 13. أدخلنا قيمة تقديرية في شريط تمرير نموذج اللغة الكبير في الحاسبة وأوضحنا صراحة أنها تقديرية. الوقوع في تعريف قديم أثناء محاولة تشغيل أحدث نموذج على أحدث مكدس هو أيضاً فخ واقعي في الاستضافة الذاتية، لذا نكتبه بصراحة بدلاً من إخفائه.

## كيف تُعِدّ هذا للتشغيل الفعلي

عند تحويل القياسات إلى وصفة عملية، تصبح كالتالي. التعرف على الكلام جيد كما هو باستخدام Qwen3-ASR. أما تحويل النص إلى كلام، فاختر VoxCPM2، الأسرع بعشرة أضعاف بين المحركين، لكن قرّب صدور الصوت الأول عبر التدفق أو تقسيم النص إلى مقاطع جملية. لا يمكن استخدام زمن Qwen3-TTS غير المتدفق البالغ 6.8 ثانية كما هو في دورة محادثة فورية. شغّل نموذج اللغة الكبير عبر vLLM على مضيف بتعريف CUDA 13. ضع المحركات الثلاثة على العقدة نفسها لإزالة القفزات الشبكية، واستخدم تدفقاً على مستوى الجملة يُشغّل تحويل النص إلى كلام فور جاهزية الجملة الأولى. مكدسنا المحلي على MacBook مخصص للتطوير، وليس نظام تشغيل فعلياً، وقد وسمنا صراحة الإعداد المسبق المحلي في الحاسبة بأنه "غير مناسب للتشغيل الفوري".

نشرنا هذه العملية بأكملها بحيث يمكن إعادة إنتاجها. تُفتح الحاسبة مباشرة في المتصفح، وتجمع أداة القياس بين إنشاء الحجم الشبكي، والتنزيل، وقياس الأداء على GPU، والتفكيك الكامل في سكربت واحد. كما حفظنا نتائج القياس الخام بصيغة JSON ودليل تشغيل في المستودع. نأمل أن يكون هذا نقطة انطلاق لكل من يريد الحديث عن زمن استجابة مكدس صوتي ذاتي الاستضافة بالأرقام بدلاً من الحدس.

- الحاسبة: [voice-latency-budget](https://sylvanus4.github.io/voice-latency-budget/)
- المستودع وأداة القياس ودليل التشغيل: [github.com/sylvanus4/voice-latency-budget](https://github.com/sylvanus4/voice-latency-budget)
