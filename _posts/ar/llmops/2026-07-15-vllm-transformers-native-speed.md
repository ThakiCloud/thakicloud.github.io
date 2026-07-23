---
title: "نفّذ مرة واحدة واخدم بسرعة vLLM الأصلية: خلفية Transformers تُنهي البناء المزدوج"
excerpt: "حتى الآن كان يجب بناء كل بنية نموذج مرتين: مرة في Transformers للتدريب والبحث، ومرة أخرى في vLLM للاستدلال الإنتاجي. خلفية Transformers بالسرعة الأصلية في vLLM v0.25.0 تُنهي هذا التكرار. تعمل عبر استخدام torch.fx لتحليل رسم النموذج بشكل ثابت، والعثور على أنماط معروفة مثل الانتباه والتطبيع وطبقات MLP، ثم إعادة توصيلها بنوى vLLM المُحسّنة. أعدنا إنتاج خطوة تحليل الرسم التي تنفّذها الخلفية فعليًا على مُفكّك من أربع طبقات وقِسنا أيًّا من عُقده الـ178 يصبح هدفًا للدمج. ثم ننظر في ما يعنيه ذلك لبنية ThakiCloud التحتية متعددة المستأجرين لخدمة النماذج مفتوحة الأوزان."
tags:
  - vllm
  - transformers
  - inference
  - serving
  - torch-fx
  - llmops
  - self-hosting
  - open-weights
  - paxis
date: 2026-07-15
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/vllm-transformers-native-speed/"
categories:
  - llmops
---

## نظرة عامة

إذا سبق لك أن استضفت نماذج مفتوحة الأوزان ذاتيًا، فأنت تعرف جدارًا مألوفًا. يصدر نموذج رائع، لكن لخدمته بسرعة فعليًا عليك الانتظار حتى يدعم محرك الخدمة تلك البنية. البنية الجديدة التي تصل إلى مكتبة Transformers قابلة للاستخدام فورًا للتدريب والبحث، لكن لبلوغ السرعة الكاملة في محرك استدلال عالي الأداء مثل vLLM كان على أحدهم إعادة تنفيذ تلك البنية من الصفر داخل vLLM. أي أنك تبني النموذج نفسه مرتين عمليًا.

هذا المقال موجّه لقادة الهندسة المسؤولين عن كلفة الاستدلال وزمن الخدمة، وللممارسين الذين يشغّلون نماذج مفتوحة الأوزان محليًا أو في بيئات سيادية، ولعلماء البيانات الذين يجرّبون بنى جديدة مع القلق بشأن سرعة النشر. في يوليو 2026، شارك Clement Delangue من Hugging Face نقطة تحوّل كبيرة للاستدلال مفتوح المصدر: بدءًا من vLLM v0.25.0، يمكن تشغيل نماذج Transformers داخل vLLM **بالسرعة الأصلية**، وغالبًا بما يضاهي التطبيقات المكتوبة يدويًا أو يتفوق عليها.

الفكرة الجوهرية هي التالية. بمجرد أن ينفّذ مؤلف النموذج بنية في Transformers، يمكنه الاستفادة من كومة الاستدلال المُحسّنة في vLLM مجانًا، دون أي عمل نقل منفصل. لم نأخذ هذا الادعاء تسليمًا. أعدنا إنتاج خطوة تحليل الرسم التي تنفّذها الخلفية داخليًا على كتلة مُفكّك صغيرة وقِسناها. يشرح هذا المقال الآلية وقياساتنا وما تعنيه لبنية تحتية تخدم نماذج مختلفة كثيرة تحت سقف واحد متعدد المستأجرين.

## ما هذه التقنية

براية واحدة هي `--model-impl transformers`، يُحمّل vLLM تعريف النموذج مباشرة من مكتبة Transformers بدلًا من تطبيق منقول مخصص، ويخدمه. ظاهريًا يبدو ذلك طبقة توافق، لكن ما يميّز خلفية v0.25.0 هو أن هذا التوافق لم يعد يكلّف سرعة. كان مسار التوافق القديم أقرب إلى بديل «يعمل لكنه بطيء». أما الآن فتُطبَّق عمليات دمج الطبقات الخاصة بالاستدلال ديناميكيًا في وقت التشغيل، فتضاهي الخلفية سرعة الشيفرة المخصصة للبنى المتوافقة.

بالنظر عن قرب، تنقسم الآلية إلى مرحلتين. أولًا تستخدم الخلفية `torch.fx` لتحليل رسم حسابات النموذج بشكل ثابت، بحثًا عن أنماط قابلة للتحسين مثل حساب درجات الانتباه، وتطبيع RMSNorm، وطبقات SwiGLU MLP، ومزيج الخبراء Mixture-of-Experts. ثم تعالج شجرة الصياغة المجردة لإعادة كتابة تلك الشيفرة في مكانها، وتربط العمليات المكتشفة بنوى vLLM المُحسّنة. في نموذج MoE يعني ذلك نوى Expert Parallelization، وفي الانتباه عائلة paged attention. في النهاية، يُحسّن vLLM الإنتاجية وزمن الاستجابة فوق البنية التي عبّر عنها Transformers.

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
<div class="d3-arch" data-arch-root id="mtransformersnativespeed-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 483, "height": 1134, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 179, "y": 24, "w": 142, "h": 46, "title": "بنية نموذج جديدة"}, {"id": "B", "x": 165, "y": 148, "w": 170, "h": 78, "title": ["تُنفَّذ مرة واحدة في", "Transformers", "للتدريب والبحث"]}, {"id": "C", "x": 163, "y": 304, "w": 174, "h": 52, "title": "كيف تُخدَم في vLLM"}, {"id": "D", "x": 288, "y": 884, "w": 163, "h": 62, "title": ["إعادة تنفيذ في vLLM", "نقل يدوي لنوى مخصصة"]}, {"id": "E", "x": 52, "y": 448, "w": 156, "h": 62, "title": ["تحليل رسم ثابت عبر", "torch.fx"]}, {"id": "F", "x": 24, "y": 588, "w": 212, "h": 78, "title": ["كشف أنماط معروفة", "الانتباه، RMSNorm، SwiGLU،", "MoE"]}, {"id": "G", "x": 24, "y": 744, "w": 212, "h": 62, "title": ["إعادة كتابة المصدر عبر ast", "دمج طبقات في وقت التشغيل"]}, {"id": "H", "x": 28, "y": 884, "w": 205, "h": 62, "title": ["الربط بنوى vLLM المُحسّنة", "EP و paged attention"]}, {"id": "I", "x": 147, "y": 1024, "w": 205, "h": 78, "title": ["استدلال بالسرعة الأصلية", "من 4B إلى 235B، مضاهاة أو", "تفوّق"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [250, 70, 250, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [250, 226, 250, 304]}, {"src": "C", "dst": "D", "kind": "data", "label": "سابقًا", "curve": [[293, 356], [369, 549], [369, 775], [369, 884]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "الآن: model-impl transformers", "curve": [[206, 356], [130, 402], [130, 402], [130, 448]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "line": [130, 510, 130, 588]}, {"src": "F", "dst": "G", "kind": "data", "line": [130, 666, 130, 744]}, {"src": "G", "dst": "H", "kind": "data", "line": [130, 806, 130, 884]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[130, 946], [130, 985], [130, 985], [190, 1024]]}, {"src": "D", "dst": "I", "kind": "data", "curve": [[369, 946], [369, 985], [369, 985], [309, 1024]]}]});
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
      const container = document.getElementById('mtransformersnativespeed-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'mtransformersnativespeed-1';
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

المعنى العملي لهذا التحول هو اختفاء الفجوة بين محرك الخدمة ومنظومة النماذج. سابقًا كانت كل بنية جديدة تتطلب قاعدتَي شيفرة، تطبيقًا للتدريب وتطبيقًا للاستدلال، وكانت الفجوة بينهما هي بالضبط نافذة «النموذج الرائع صدر لكن لا نستطيع خدمته بسرعة بعد». الآن تضيق هذه النافذة. سواء كنت فريق بحث يجرّب بنية مخصصة أو فريق تشغيل يحاول وضع نموذج صدر حديثًا في الإنتاج، يمنحك تطبيق Transformers واحد سرعة vLLM.

## التثبيت والتكامل

هذه الخلفية ليست حزمة منفصلة؛ إنها تأتي داخل vLLM نفسه. ثبّت vLLM v0.25.0 أو أحدث وأضف `--model-impl transformers` إلى أمر الخدمة. الأمثلة الحقيقية التي نشرتها Hugging Face كالتالي.

```bash
# وحدة معالجة رسومات واحدة، نموذج كثيف
vllm serve Qwen/Qwen3-4B --model-impl transformers

# توازٍ موتّري عبر وحدتَين، نموذج كثيف كبير
vllm serve Qwen/Qwen3-32B \
  --model-impl transformers \
  --tensor-parallel-size 2

# توازي بيانات مع توازي خبراء، نموذج MoE
vllm serve Qwen/Qwen3-235B-A22B-FP8 \
  --model-impl transformers \
  --data-parallel-size 8 \
  --enable-expert-parallel
```

ويعمل الأمر نفسه من واجهة Python للاستدلال دون اتصال.

```python
from vllm import LLM, SamplingParams

llm = LLM(
    model="Qwen/Qwen3-4B",
    model_impl="transformers",   # استخدام تعريف Transformers بدل نقل مخصص
)
out = llm.generate(
    ["كيف تخدم ThakiCloud النماذج مفتوحة الأوزان؟"],
    SamplingParams(max_tokens=256, temperature=0.7),
)
print(out[0].outputs[0].text)
```

ما يلفت النظر عبر الأمثلة الثلاثة أن خيارات الخدمة الموزعة مثل التوازي الموتّري وتوازي البيانات وتوازي الخبراء تعمل جميعها تحت خلفية Transformers. أي أنك لا تتخلى عن التوسّع الأفقي مقابل التوافق. من نموذج كثيف بحجم 4B إلى نموذج MoE بحجم 235B، تغطّي براية واحدة ذلك.

## نتائج التجربة الفعلية

هذه البيئة هي macOS (Apple Silicon)، لذا لا يمكنها تشغيل نوى CUDA الخاصة بـ vLLM، ولم نتمكن من إعادة إنتاج قياس إنتاجية vLLM نفسه. بدلًا من ذلك أعدنا إنتاج **الخطوة الأهم التي تنفّذها الخلفية داخليًا: استخدام torch.fx لتحليل رسم النموذج بشكل ثابت والعثور على أنماط أهداف الدمج**. بنينا مُفكّكًا من أربع طبقات على نمط Llama بلغة PyTorch خالصة، بالبنية نفسها التي تستخدمها نماذج الخدمة الحقيقية (انتباه الاستعلام المجمّع GQA وطبقة SwiGLU MLP)، وتتبّعنا رسمه عبر `torch.fx.symbolic_trace`، وصنّفنا العُقد.

كانت القياسات كالتالي. أنتج تتبّع هذا المُفكّك الصغير البالغ 2.902 مليون معامل رسم torch.fx بإجمالي **178 عقدة**. حسب نوع العملية كان هناك 80 استدعاء دالة، و60 استدعاء طريقة، و28 استدعاء وحدة، و8 عمليات جلب سمات. من بين هذه، بلغت الأنماط على مستوى الدوال التي تستطيع الخلفية استبدالها فورًا بنوى دمج 16 عملية اختزال RMSNorm، و8 عمليات ضرب مصفوفات متعلقة بالانتباه، و4 عمليات softmax، و4 تفعيلات SwiGLU، أي 32 إجمالًا، إضافة إلى 28 استدعاء وحدة تحمل إسقاطات QKV والإخراج وطبقة MLP والتطبيع. بلغ زمن التمرير الأمامي عند طول تسلسل 64 في المتوسط 1.4 ملّي ثانية، مقيسًا على torch 2.13.0.

![مخطط أعمدة يوضح توزيع عُقد أهداف الدمج في رسم torch.fx]({{ '/assets/images/vllm-transformers-native-speed-results.png' | relative_url }})

ما تُظهره هذه الأرقام واضح. حتى في كتلة صغيرة واحدة من 178 عقدة، تتكرر أنماط جيدة التكوين من الانتباه والتطبيع وتفعيل MLP، وهذه بالضبط النقاط التي تستهدفها الخلفية لاستبدالها بنوى vLLM. في نموذج حقيقي بعشرات الطبقات يتضاعف هذا النمط بعدد الطبقات، فيتيح تحليل رسم واحد للخلفية دمج عمليات الاختناق عبر النموذج كله دفعة واحدة. وفق Hugging Face، أتاح هذا النهج لخلفية Transformers مضاهاة إنتاجية vLLM الأصلية أو التفوّق عليها من 4B إلى 235B، شاملًا إعدادات التوازي الموتّري وMoE. لم تُعد تجربتنا إنتاج تلك الأرقام؛ بل أكّدت بالقياس **الهيكل العظمي للآلية** التي تنتجها.

## دلالات لـ ThakiCloud

**ai-platform** من ThakiCloud هي بنية تحتية متعددة المستأجرين للذكاء الاصطناعي وتعلّم الآلة تخدم النماذج لبيئات عملاء متنوعة فوق K8s وجدولة GPU المستندة إلى Kueue. هذه الخلفية فائدة مباشرة لمشغّل خدمة مثلنا. أولًا، **يتقلّص زمن إدخال النموذج.** عند صدور نموذج جديد مفتوح الأوزان، كان علينا حتى الآن انتظار دعم vLLM الرسمي لتلك البنية أو قبول نقل ذاتي. إذا وُجد تطبيق Transformers، تتيح لنا `--model-impl transformers` تشغيل حجيرة خدمة بسرعة مُحسّنة فورًا. وهذا يؤثر مباشرة في السؤال التنافسي عن سرعة وصول نموذج جديد إلى الإنتاج.

ثانيًا، **يصبح مسار خدمة البنى المخصصة أبسط.** عند خدمة نموذج مضبوط أو معدّل هيكليًا لعميل محدد محليًا، فإن القدرة على النشر من تعريف Transformers وحده، دون نقل مخصص إلى vLLM، تقلّل عبء الصيانة كثيرًا. في بيئات السحابة السيادية أو المنظّمة التي تتطلب الاستضافة الذاتية، نوفّر الوقت المُنفَق في التوفيق بين إصدارات المحرك والنموذج. وبما أن التوازي الموتّري وتوازي البيانات وتوازي الخبراء يعمل كله، يمكننا تبنّي هذا المسار دون تغيير طوبولوجيات الخدمة متعددة الـGPU التي نشغّلها بالفعل.

من منظور الوكلاء، تنطبق عدسة **Paxis** أيضًا. Paxis هي مستوى تحكّم Agent-Native Cloud يعمل فوق ai-platform، ويبدّل نماذج مختلفة كالأدوات أثناء تشغيل الوكلاء. إذا استطاعت طبقة الخدمة إدخال نماذج جديدة مفتوحة الأوزان أسرع وأرخص، اتّسع مجمع النماذج الذي يمكن للوكلاء فوقها اختياره وانخفضت كلفة التبديل. ولأن الخدمة منخفضة الكلفة وزمن الاستجابة هي في النهاية ما يجعل أحمال الوكلاء اقتصادية، تتجه كفاءة خدمة ai-platform ومرونة وكلاء Paxis في الاتجاه نفسه.

## القيود والاعتراضات

هذه الخلفية ليست حلًّا لكل شيء، وثمة حدود واضحة تستحق الذكر إنصافًا. أولًا، ميزة الأداء محصورة في «البنى المتوافقة». يجب أن يكون النموذج قابلًا للتتبع الثابت عبر torch.fx، وأن يطابق أنماطًا تعرفها الخلفية مسبقًا حتى ينطبق الدمج. البنية ذات تدفق تحكّم ديناميكي كثيف أو عمليات جديدة لم ترها الخلفية سترتد إلى مسارات غير مدموجة في بعض الأجزاء، فتتقلّص ميزة السرعة تبعًا لذلك. ليست كل نماذج Transformers تبلغ السرعة الأصلية تلقائيًا.

ثانيًا، بلغت هذه الميزة النضج في v0.25.0 لكنها لا تزال في تطوّر. لبعض تركيبات التكميم، وبعض متغيرات الانتباه، أو مخططات توجيه MoE النادرة، قد يظل التطبيق المنقول المخصص أكثر استقرارًا أو أسرع. قبل الإنتاج، الأأمن أن تقيس بنفسك الإنتاجية والدقة الفعليتين على نموذجك وعتادك المستهدفين. لهذا السبب بالذات لم نستشهد بأرقام إنتاجية vLLM مباشرة بل نسبناها إلى الإعلان الرسمي؛ فالأرقام تختلف حسب البيئة، والقياس على عنقود GPU الخاص بـ ThakiCloud مخطّط له على حدة.

ثالثًا، ثمة اعتراض ممكن. حين يقترن محرك الخدمة ومكتبة النموذج اقترانًا وثيقًا، قد تؤثر تغييرات Transformers في استقرار الخدمة. في زمن قاعدتَي الشيفرة المنفصلتين كان يمكنك تثبيت كومة الاستدلال باستقلال، لكن مشاركة الخلفية تفرض إعادة التفكير في إدارة الإصدارات. ومع ذلك، موازنةً بكلفة تنفيذ كل نموذج جديد مرتين، نرى أن مكسب سرعة الإدخال من هذا الاقتران أكبر في معظم سيناريوهات الخدمة.

## المصادر

- [Native-speed vLLM transformers modeling backend (Hugging Face Blog)](https://huggingface.co/blog/native-speed-vllm-transformers-backend)
- [vLLM v0.25.0: transformers backend now matches native vLLM speed (daily.dev)](https://daily.dev/posts/vllm-v0-25-0-transformers-backend-now-matches-native-vllm-speed-z8kvnsk7c)
- [Transformers modeling backend integration in vLLM (vLLM Blog)](https://blog.vllm.ai/2025/04/11/transformers-backend.html)
- [Clement Delangue (@ClementDelangue) on X](https://x.com/ClementDelangue/status/2076763231788339669)
- شيفرة التجربة والسجلات: `outputs/blog-impl/vllm-transformers-native-speed/` (إعادة إنتاج تحليل رسم torch.fx، torch 2.13.0، وحدة المعالجة المركزية)
