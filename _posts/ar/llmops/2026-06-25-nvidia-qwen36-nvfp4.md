---
title: "NVIDIA Qwen3.6-35B-A3B-NVFP4: تشغيل نموذج 35B بسرعة 3B عبر تكميم FP4"
excerpt: "أصدرت NVIDIA نسخة مكمَّمة بصيغة NVFP4 (4 بت) من نموذج Qwen3.6-35B-A3B من Alibaba. خفض الأوزان من 16 بت إلى 4 بت يقلّل مساحة القرص وذاكرة GPU بنحو 3.06 ضعف، بينما يبقى فقدان الدقة مقابل BF16 في حدود 0.1 إلى 0.8 نقطة وفق الأرقام المنشورة في بطاقة النموذج. نحلّل كيف تتكامل بنية MoE (إجمالي 35B، 3B نشطة) مع تكميم NVFP4، وأوامر النشر في vLLM، وما يعنيه ذلك للخدمة المحلية لدى ThakiCloud."
seo_title: "تحليل تكميم NVIDIA Qwen3.6-35B-A3B-NVFP4 بصيغة FP4 ونشره في vLLM - Thaki Cloud"
seo_description: "تحليل لنموذج NVIDIA Qwen3.6-35B-A3B-NVFP4 (تكميم NVFP4 بأربع بتات): توفير ذاكرة بنحو 3.06×، والحفاظ على الدقة مقابل BF16، وأوامر النشر في vLLM، ومتطلبات عتاد Blackwell/Hopper من منظور منصة ThakiCloud متعددة المستأجرين على Kubernetes."
date: 2026-06-25
last_modified_at: 2026-06-25
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/nvidia-qwen36-nvfp4/"
tags:
  - nvfp4
  - quantization
  - vllm
  - qwen3
  - moe
  - inference-optimization
  - model-optimizer
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "microchip"
toc_sticky: true
reading_time: true
categories:
  - llmops
published: false
---

بالنسبة لأي فريق يحاول خدمة النماذج الكبيرة على بنيته التحتية الخاصة، فإن أكبر عائق هو ذاكرة GPU. إن وضع نموذج أكبر على نفس وحدة GPU، أو نفس النموذج على وحدة GPU أرخص، ينعكس مباشرة على تكلفة الخدمة. النموذج `nvidia/Qwen3.6-35B-A3B-NVFP4` الذي نشرته NVIDIA على Hugging Face في 28 مايو 2026 هو محاولة لخفض هذا العائق عبر التكميم بأربع بتات. أرقام الدقة والذاكرة في هذه المقالة هي قياسات رسمية من بطاقة نموذج NVIDIA، وقد كمّمت ThakiCloud النموذج الأساسي نفسه إلى NVFP4 على وحدات GPU في RunPod وتعرض نتيجة إعادة الإنتاج هذه في قسم «نتائج تجريبية حقيقية» أدناه.

## نظرة عامة

`nvidia/Qwen3.6-35B-A3B-NVFP4` هو نموذج `Qwen/Qwen3.6-35B-A3B` من Alibaba بعد تكميمه باستخدام NVIDIA Model Optimizer (ModelOpt). النموذج الأساسي بنية خليط الخبراء (MoE) بإجمالي 35B معامل و3B فقط نشطة، وطول سياق يصل إلى 262K، ورخصة Apache-2.0 تتيح الاستخدام التجاري وغير التجاري. وتوضّح NVIDIA صراحةً في بطاقة النموذج أن هذا ليس نموذجاً أساسياً من بناء NVIDIA بل نسخة مكمَّمة من نموذج طرف ثالث.

تتلخّص القيمة الجوهرية في فكرتين. **بنية MoE تتكفّل بالسرعة، وتكميم NVFP4 يتكفّل بالذاكرة.** بفضل بنية MoE، فإن توليد رمز واحد يشغّل فقط 3B من الخبراء النشطين بدلاً من كامل الـ35B، فيعمل نموذج 35B بحِمل حسابي قريب من نموذج كثيف بحجم 3B. أضف إلى ذلك تكميم NVFP4 الذي يخفض الأوزان من 16 بت إلى 4 بت، فتنخفض متطلبات القرص وذاكرة GPU بنحو 3.06 ضعف وفق بطاقة النموذج. هذا المزيج يشغّل "ذكاء بمستوى 35B بسرعة 3B وبذاكرة أقل بكثير."

تدير ThakiCloud منصة SaaS متعددة المستأجرين للذكاء الاصطناعي والتعلم الآلي مبنية على Kubernetes، وتخدم النماذج عبر بيئات عملاء متنوعة. القدرة على أخذ نقطة تحقّق مكمَّمة مسبقاً وتحميلها مباشرة في vLLM تعني خفض تكلفة الخدمة دون إعادة تشغيل خط تكميم في كل مرة. وفي الواقع، تشغّل ThakiCloud بالفعل خط أنابيب داخلياً يكمّم العائلة نفسها Qwen3-MoE إلى NVFP4، ونشارك هذه التجربة لاحقاً في المقالة.

## ما هذه التقنية

NVFP4 صيغة فاصلة عائمة بأربع بتات عرّفتها NVIDIA. وهي لا تسحق كل قيمة إلى 4 بتات ببساطة، بل تطبّق التكميم تحديداً على **أوزان وتنشيطات** المعاملات الخطية داخل كتل محوّل MoE. ونقتبس من بطاقة النموذج مباشرةً: "تم الحصول على هذا النموذج بتكميم أوزان Qwen3.6-35B-A3B إلى صيغة بيانات NVFP4. تُكمَّم فقط أوزان وتنشيطات المعاملات الخطية داخل كتل المحوّل في MoE. يخفض هذا التحسين عدد البتات لكل معامل من 16 إلى 4، ما يقلّل حجم القرص ومتطلبات ذاكرة GPU بنحو 3.06 ضعف."

المفتاح هو إدراك أن MoE والتكميم يعملان على محورين مختلفين. ويوضّح المخطط أدناه كلا المحورين.

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
<div class="d3-arch" data-arch-root id="0260625nvidiaqwen36nvfp4-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 514, "height": 984, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 230, "y": 24, "w": 252, "h": 294, "label": "محور التكميم (الذاكرة)", "lx": 242, "ly": 42}, {"x": 24, "y": 410, "w": 216, "h": 542, "label": "محور الخدمة (السرعة)", "lx": 36, "ly": 428}], "nodes": [{"id": "A", "x": 288, "y": 63, "w": 135, "h": 62, "title": ["Qwen3.6-35B-A3B", "أوزان BF16"]}, {"id": "B", "x": 267, "y": 217, "w": 177, "h": 62, "title": ["نقطة تحقّق NVFP4", "16→4 بت، توفير ~3.06×"]}, {"id": "C", "x": 65, "y": 457, "w": 120, "h": 46, "title": "رمز الإدخال"}, {"id": "D", "x": 75, "y": 589, "w": 120, "h": 46, "title": "الموجّه"}, {"id": "E", "x": 68, "y": 727, "w": 135, "h": 62, "title": ["الخبراء النشطون", "(حساب 3B)"]}, {"id": "F", "x": 75, "y": 867, "w": 120, "h": 46, "title": "رمز الإخراج"}, {"id": "G", "x": 278, "y": 449, "w": 156, "h": 62, "title": ["Blackwell / Hopper", "Tensor Core"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "\"ModelOpt PTQ<br/>معايرة NVFP4\"", "line": [356, 125, 356, 217], "lx": 356, "ly": 167}, {"src": "C", "dst": "D", "kind": "data", "line": [125, 503, 132, 589]}, {"src": "D", "dst": "E", "kind": "data", "label": "\"اختيار 3B من 35B\"", "line": [135, 635, 135, 727], "lx": 135, "ly": 677}, {"src": "E", "dst": "F", "kind": "data", "line": [135, 789, 135, 867]}, {"src": "B", "dst": "G", "kind": "data", "label": "\"vLLM --quantization modelopt\"", "line": [356, 279, 356, 449], "lx": 356, "ly": 360}, {"src": "G", "dst": "D", "kind": "data", "curve": [[278, 511], [178, 550], [178, 550], [151, 589]]}]});
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
      const container = document.getElementById('0260625nvidiaqwen36nvfp4-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0260625nvidiaqwen36nvfp4-1';
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

على محور التكميم، تُحوَّل أوزان BF16 إلى نقطة تحقّق NVFP4 عبر التكميم بعد التدريب (PTQ) في ModelOpt. وعلى محور الخدمة، يختار الموجّه لكل رمز إدخال مجموعة فرعية فقط من خبراء الـ35B ويجري نحو 3B من الحساب. يلتقي المحوران عند عملية Tensor Core فوق vLLM، وهنا بالضبط تظهر تبعية NVFP4 للعتاد. تُسرَّع عمليات NVFP4 فقط على معماريتي NVIDIA Hopper وBlackwell. وتُدرج بطاقة النموذج NVIDIA GB300 كعتاد اختبار.

سرّ تقليل فقدان الدقة هو التكميم "بانتقائية لا شمولية." تُترك المسارات الحساسة بما فيها الانتباه دون مساس، ويتركّز الجهد على الأوزان الخطية لـMoE التي تستهلك أكبر قدر من الذاكرة، فيبقى توفير الذاكرة كبيراً ويبقى تدهور الجودة صغيراً.

## التثبيت والتكامل

أمر الخدمة الأساسي في vLLM الذي توفّره NVIDIA في بطاقة النموذج أدناه. تشغّل صورة دوكر `vllm/vllm-openai:nightly` ثم تنفّذه.

```sh
vllm serve nvidia/Qwen3.6-35B-A3B-NVFP4 \
  --port 8000 \
  --quantization modelopt \
  --max-model-len 262144 \
  --reasoning-parser qwen3
```

الراية `--quantization modelopt` هي ما يجعل المحرّك يتعرّف على نقطة تحقّق NVFP4. إذا كانت ذاكرة GPU ضيقة، فإن خفض `--max-model-len` أولاً ثم رفعه تدريجياً نهج آمن، لأن الحفاظ على كامل سياق 262K يتطلّب ذاكرة كبيرة لمخبأ KV.

للبيئات محدودة الذاكرة مثل NVIDIA DGX Spark، توفّر بطاقة النموذج أمراً موصى به منفصلاً.

```sh
vllm serve nvidia/Qwen3.6-35B-A3B-NVFP4 \
  --host 0.0.0.0 \
  --port 8000 \
  --tensor-parallel-size 1 \
  --trust-remote-code \
  --kv-cache-dtype fp8 \
  --attention-backend flashinfer \
  --moe-backend marlin \
  --gpu-memory-utilization 0.4 \
  --max-model-len 262144 \
  --max-num-seqs 4 \
  --max-num-batched-tokens 8192 \
  --enable-chunked-prefill \
  --async-scheduling \
  --enable-prefix-caching \
  --speculative-config '{"method":"mtp","num_speculative_tokens":3,"moe_backend":"triton"}' \
  --load-format fastsafetensors \
  --reasoning-parser qwen3 \
  --tool-call-parser qwen3_xml \
  --enable-auto-tool-choice
```

يحتوي هذا الأمر على عدة خيارات مفيدة تشغيلياً. تُصغّر `--kv-cache-dtype fp8` حتى مخبأ KV إلى 8 بت، وتُبقي `--gpu-memory-utilization 0.4` بصمة الذاكرة منخفضة، وتفعّل `--speculative-config` الفك التخميني القائم على MTP (التنبؤ متعدد الرموز). وتجعل `--tool-call-parser qwen3_xml` و`--enable-auto-tool-choice` استدعاء الأدوات قابلاً للاستخدام فوراً في سيناريوهات الوكلاء وRAG. وحالة الاستخدام التي تذكرها NVIDIA هي بالضبط "المطوّرون الباحثون عن نماذج جاهزة مكمَّمة مسبقاً للنشر في أنظمة وكلاء الذكاء الاصطناعي وروبوتات المحادثة وأنظمة RAG"، وتعكس مجموعة الخيارات هذه ذلك الغرض مباشرةً.

## نتائج تجريبية حقيقية

### إعادة إنتاج ThakiCloud: تشغيل مسار تكميم NVFP4 على RunPod H100

بدلاً من مجرد إعادة سرد أرقام بطاقة النموذج، كمّمت ThakiCloud النموذج الأساسي نفسه `Qwen/Qwen3.6-35B-A3B` إلى NVFP4 مباشرةً، على **وحدتي NVIDIA H100 NVL (Hopper، بإجمالي 191 جيجابايت)** في RunPod، باستخدام NVIDIA Model Optimizer. ولأن حسابات المعايرة (calibration) تجري بدقة BF16، فإن مسار التكميم نفسه يُعاد إنتاجه على Hopper أيضاً. الحقائق المقاسة كالتالي:

| البند | القيمة المقاسة |
|---|---|
| أداة التكميم | `nvidia-modelopt[hf]` 0.44.0 (الأحدث حالياً) |
| تحميل النموذج الأساسي | 34.66 مليار معامل، موزّعة تلقائياً على وحدتي H100 عبر device_map |
| إعداد المعايرة | `NVFP4_DEFAULT_CFG`، اختبار سريع بـ 8 عينات |
| التسجيل التلقائي للبنية الجديدة | `Qwen3_5MoeExperts` → `_QuantFusedExperts` (MoE مدمج)، `Qwen3_5MoeAttention` → `_QuantAttention` (ذاكرة KV) |
| المُكمِّمات المُدرَجة | **21,743** |
| زمن PTQ | **148 ثانية** |

النقطة الجوهرية هي أن **modelopt 0.44 تعرّف تلقائياً على بنية جديدة كلياً صدرت في أواخر مايو 2026 (Qwen3.6، الاسم الداخلي `qwen3_5_moe`، عائلة Gated DeltaNet) وأكمل مسار التكميم بنجاح**. سُجِّلت كتل خبراء MoE المدمجة وذاكرة KV للانتباه تلقائياً كأهداف للتكميم، وأُدرِج 21,743 مُكمِّماً.

لكن بكل صدق، ثمة أمر واحد: نجح مسار التكميم، إلا أن خطوة كتابة نقطة التحقّق المعبّأة بأربع بتات إلى القرص، أي `export_hf_checkpoint`، اصطدمت حالياً بـ**فجوة توافق بين modelopt 0.44 و transformers 5.x** (`transformers>=5.0 support is experimental`). إذ يتطلّب `qwen3_5_moe` الإصدار transformers 5.x، وفي هذا المزيج لا يعمل تصدير HF الموحّد بعد، فتراجع الأمر إلى BF16. وهذا تأخّر في سلسلة الأدوات شائع لبنية عمرها أقل من شهر. لذلك نستشهد بنقطة التحقّق المنشورة من NVIDIA لحجم النموذج المعبّأ (توفير نحو 3.06×، نحو 18.7 مليار) ولأرقام الدقة.

جدول الدقة أدناه هو **التقييم الرسمي من NVIDIA المنشور في بطاقة النموذج**. قارنت NVIDIA النسخة المكمَّمة NVFP4 بالنموذج الأساسي `Qwen3.6-35B-A3B` (BF16) على معايير الاستدلال النصي والبرمجة.

| المعيار | BF16 (الأساس) | NVFP4 | Δ |
|---|---|---|---|
| MMLU Pro | 85.6 | 85.0 | -0.6 |
| GPQA Diamond | 84.9 | 84.8 | -0.1 |
| τ²-Bench Telecom | 95.5 | 94.7 | -0.8 |
| SciCode | 40.8 | 40.6 | -0.2 |
| AIME 2025 | 89.2 | 88.8 | -0.4 |
| AA-LCR | 62.0 | 62.0 | 0.0 |
| IFBench | 62.3 | 62.8 | +0.5 |
| MMMU PRO | 74.1 | 74.5 | +0.4 |

![مخطط أعمدة يقارن دقة NVFP4 بـ BF16]({{ '/assets/images/nvidia-qwen36-nvfp4-results.webp' | relative_url }})

تمثيل بصري للأرقام المنشورة في بطاقة النموذج (تسميات المحاور بالكورية). حتى بعد التكميم بأربع بتات، تبقى معظم فروق الدقة دون نقطة واحدة.

مفتاح قراءة الجدول هو حجم الخسارة. أكبر انخفاض عبر المعايير الثمانية هو -0.8 على τ²-Bench Telecom، أما GPQA Diamond فهو -0.1، وAA-LCR متعادل. بل إن IFBench وMMMU PRO يتقدّم فيهما NVFP4 قليلاً على BF16. حدث التحوّل الطفيف في التوزيع الناتج عن التكميم بشكل مواتٍ في بعض المهام مصادفةً، لكن لا ينبغي تعميم ذلك إلى "التكميم يحسّن الأداء." إجمالاً، رسالة الجدول أن خفض 16 بت إلى الربع عند 4 بتات حافظ على قدرات الاستدلال والرياضيات والبرمجة واستخدام أدوات الوكلاء بشكل شبه كامل. وكانت شروط التقييم لـSciCode عند temperature=0.6 وtop_p=0.95 وبحد أقصى 131072 رمزاً، والبقية عند temperature=1.0 وtop_p=0.95 وبحد أقصى 131072 رمزاً.

أما من ناحية الذاكرة، فتذكر بطاقة النموذج توفيراً بنحو 3.06 ضعف. ووفق مستودع Hugging Face، يُبلَّغ عن حجم المعاملات المحزومة لنقطة تحقّق NVFP4 بنحو 18.7B، وهو شكل مخفّض كثيراً للنموذج 35B مقارنةً بـ BF16 الأصلي. ويجب التحقق من حجم الملف الدقيق مباشرةً في الشريط الجانبي للمستودع، وتحذّر بطاقة النموذج من الخلط بين إحصاءات ملفات الشريط الجانبي ومعاملات بنية النموذج الأساسي.

## التطبيق والدلالات لمنصة ThakiCloud للذكاء الاصطناعي والتعلم الآلي على Kubernetes

من منظور منصة ThakiCloud، جاذبية هذا النموذج واضحة. في بيئة متعددة المستأجرين، تكون GPU أغلى مورد مشترك، وكلما تمكّنّا من تحميل مزيد من نماذج المستأجرين على نفس GPU في آنٍ واحد، انخفضت تكلفة الاستدلال للوحدة. خفض NVFP4 للذاكرة بنحو 3.06 ضعف يعني، بصيغة مبسّطة، مساحة لاستيعاب نموذج أكبر أو جلسات متزامنة أكثر في نفس ذاكرة GPU. أضف خاصية MoE المتمثّلة في تشغيل MoE بحجم 35B بحساب نحو 3B، فتصبح قيمة "نماذج عالية الجودة بتكلفة خدمة منخفضة" المحلية أكثر تجسيداً بكثير.

تعكس ThakiCloud هذا بالفعل في التشغيل. نحافظ على خط أنابيب داخلي يكمّم `Qwen/Qwen3-30B-A3B`، من عائلة Qwen3-MoE نفسها، إلى NVFP4 (W4A4، group_size=16) على RunPod B200 (Blackwell SM100). وفي تشغيل تحقّق في 1 مايو 2026، **أنتج نقطة تحقّق بحجم 17.1GB بـ137 ثانية من حساب PTQ.** بلغ إجمالي الوقت الفعلي نحو 25 دقيقة، والتكلفة نحو 3.48 دولار على B200 عند الطلب. وأثناء إعداد هذه المقالة طبّقنا خط الأنابيب نفسه على النموذج الجديد `Qwen3.6-35B-A3B`، فأعدنا إنتاج مسار تكميم NVFP4 على وحدتي H100 NVL في RunPod (modelopt 0.44، إدراج 21,743 مُكمِّماً، تسجيل تلقائي للـ MoE المدمج الجديد، 148 ثانية). يترتّب على هذه التجربة أمران. أولاً، تكميم NVFP4 نفسه مهمة لمرة واحدة تنتهي في وقت قصير بتكلفة منخفضة. ثانياً، عند نشر نقطة تحقّق مكمَّمة مسبقاً كما فعلت NVIDIA هنا، يمكنك تخطّي حتى تلك المهمة لمرة واحدة والانتقال مباشرةً إلى الخدمة. بعبارة أخرى، نقطة تحقّق NVIDIA العامة مدخل أشمل لخط أنابيبنا.

أما من ناحية تشغيل K8s، فيتوافق كما يلي. تُصفّ أحمال GPU وتُجدول عبر Kueue، وتُشغّل الخدمة كحُجيرات vLLM مع الراية `--quantization modelopt` للتعرّف على نقطة تحقّق NVFP4، ويُعالَج عزل المستأجرين بمساحات الأسماء وتقسيم GPU، مع تعديل التخصيص لكل مستأجر بقدر الذاكرة الموفَّرة. لكن يرافق ذلك شرط عتاد واحد. تسريع NVFP4 يعمل فقط على Blackwell وHopper، لذا لا يمكن لمجمّعات العقد القائمة على A100 التمتّع بفائدة الأربع بتات لهذا النموذج كما هي. وهذا قرار تشغيلي مرتبط مباشرةً بتكوين مجمّع العقد، ونشير إليه كقيد في القسم التالي.

## القيود والحجج المضادة

أولاً، **تبعية العتاد قوية.** توجد نوى Tensor Core الخاصة بـNVFP4 فقط على Blackwell وHopper. على وحدات GPU من الأجيال السابقة مثل A100 أو V100، لا يُسرَّع NVFP4، فلا يمكن توقّع نفس توفير الذاكرة ويجب سلوك مسار آخر مثل INT8 أو FP8. وإذا كانت أصول GPU الحالية لعميل محلي من جيل سابق، فإن جني فائدة هذا النموذج يستلزم تكلفة إضافية لاستبدال العقد.

ثانياً، **توفير الذاكرة ومكاسب الإنتاجية أمران مختلفان.** تذكر بطاقة النموذج توفيراً للقرص والذاكرة بنحو 3.06 ضعف، لكنها لا تقدّم مباشرةً أرقام إنتاجية مثل الرموز/الثانية أو زمن الاستجابة. ومع أن الأوزان بأربع بتات تساعد عادةً في فك التشفير بتخفيف ضغط عرض النطاق للذاكرة، فإن الإنتاجية الفعلية تعتمد على حجم الدفعة وطول السياق وإعدادات مخبأ KV. والجزم بأنه "أسرع بـN ضعفاً" دون معيار خدمة خاص بـThakiCloud سيكون غير دقيق. كما أن تسريع NVFP4 الأصلي لا يعمل إلا على Blackwell، ولم نتمكّن وقت إعادة الإنتاج هذه من تأمين مخزون B200 على RunPod، لذا تحقّقنا من مسار التكميم على Hopper (وحدتا H100 NVL) وتركنا إنتاجية خدمة NVFP4 الأصلية مهمة قياس منفصلة بعد توفّر Blackwell.

ثالثاً، **يرث التكميم قيود النموذج الأساسي كما هي.** كما تذكر بطاقة النموذج مباشرةً، دُرّب النموذج الأساسي على بيانات مسحوبة من الإنترنت تحتوي على لغة سامّة وتحيّزات مجتمعية، وقد يولّد إجابات غير دقيقة أو يحذف معلومات أساسية أو ينتج نصاً غير ذي صلة. التكميم يحسّن الذاكرة والسرعة فقط، ولا يحلّ مشكلات الأمان والدقة هذه. ولا تزال الخدمة متعددة المستأجرين تتطلّب ترشيحاً ومراقبةً منفصلين للمخرجات.

رابعاً، **فقدان الدقة لا يتقارب إلى الصفر.** رغم أن معظم المعايير تُظهر خسارة دون نقطة واحدة، فإن السيناريوهات التي يكون فيها استخدام أدوات الوكلاء والالتزام بالسياسات محورياً، مثل -0.8 في τ²-Bench Telecom، تُظهر خسارة أكبر نسبياً. وفي مجالات مثل المالية والرعاية الصحية حيث تنعكس فروق الدقة الصغيرة مباشرةً على التكلفة، تحتاج إلى سياسة توازن بين اقتصاديات توفير الأربع بتات وفقدان الدقة لكل مستأجر، وتختار بين BF16 وFP8 وNVFP4.

إجمالاً، `nvidia/Qwen3.6-35B-A3B-NVFP4` خيار عملي للغاية للفرق التي تمتلك بنية تحتية قائمة على Blackwell/Hopper لـ"خفض الذاكرة إلى الربع تقريباً دون خسارة تُذكر." لكن هذه الفائدة لا تصمد إلا فوق شرط العتاد والتحقق من الدقة الخاص بكل مجال، وتعتزم ThakiCloud تأكيد الإنتاجية وملاءمة كل مستأجر بمعيار خدمة خاص بها قبل عكسه في سياسة مجمّع العقد.

## المصادر

- بطاقة النموذج: [nvidia/Qwen3.6-35B-A3B-NVFP4 · Hugging Face](https://huggingface.co/nvidia/Qwen3.6-35B-A3B-NVFP4)
- النموذج الأساسي: [Qwen/Qwen3.6-35B-A3B · Hugging Face](https://huggingface.co/Qwen/Qwen3.6-35B-A3B)
- أداة التكميم: [NVIDIA Model Optimizer (GitHub)](https://github.com/NVIDIA/Model-Optimizer)
- محرّك الاستدلال: [vLLM (GitHub)](https://github.com/vllm-project/vllm)
