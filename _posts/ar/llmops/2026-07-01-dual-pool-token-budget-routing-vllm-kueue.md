---
title: "التوجيه المزدوج بميزانية الرموز — تقليص وقت GPU في استدلال vLLM بنسبة 31–42% عبر الجدولة ثنائية المجمّعات"
excerpt: "الطلبات القصيرة التي تنتظر خلف الطلبات الطويلة في قائمة انتظار واحدة تُهدر وقت GPU في صمت — وهذا ما يُعرف بـ HoL Blocking. يقترح أسلوب Dual-Pool Token-Budget Routing الوارد في arXiv 2604.08075 تقسيم الطلبات بين مجمّع سياق قصير ومجمّع سياق طويل، محققًا توفيرًا في وقت GPU بنسبة 31–42% وتحسينًا بنسبة 6% في P99 TTFT. يشرح هذا المقال خطوات تطبيق هذه التقنية على Kubernetes باستخدام Kueue LocalQueue."
seo_title: "Dual-Pool Token-Budget Routing: توفير 31–42% من GPU في vLLM | Thaki Cloud"
seo_description: "تعرّف على كيفية التخلص من HoL Blocking وتوفير 31–42% من وقت GPU بتوجيه طلبات الاستدلال في vLLM إلى مجمّعَي سياق قصير وطويل، مع التكامل مع Kueue LocalQueue على Kubernetes."
date: 2026-07-01
last_modified_at: 2026-07-01
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/technique/dual-pool-token-budget-routing-vllm-kueue/"
tags:
  - vllm
  - llm-inference
  - kueue
  - gpu-scheduling
  - llmops
  - kubernetes
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "microchip"
published: true
categories:
  - llmops
---

## المشكلة: HoL Blocking يُهدر وقت GPU في صمت

من يدير خدمة استدلال نماذج اللغة الكبيرة في بيئة إنتاجية يلاحظ حتمًا هذا النمط المتكرر: طلب يُنتج عشرات الرموز فحسب — كردّ بسيط في نظام محادثة — يجلس منتظرًا خلف طلب تلخيص وثيقة طويل أو مهمة توليد كود معقدة، مُهدرًا مئات الميلي ثانية. هذا ما يُعرف بـ Head-of-Line (HoL) Blocking.

يرفع نظام vLLM كفاءة المعالجة الدفعية بشكل ملحوظ عبر continuous batching، غير أن البنية ذات المجمّع الواحد تجعل الطلبات الطويلة تستأثر بذاكرة KV Cache لفترات مطوّلة، مما يُجبر الطلبات القصيرة على الانتظار أو إعادة الحساب عند الاستئناف، فيتراجع الاستخدام الفعلي لوقت GPU.

يعالج أسلوب **Dual-Pool Token-Budget Routing** الوارد في arXiv 2604.08075 هذه المشكلة من جذورها: عند وصول كل طلب، يُقدَّر عدد الرموز المتوقع، ويُوجَّه الطلب إما إلى مجمّع السياق القصير أو مجمّع السياق الطويل، فيتعايش النوعان دون تدخّل متبادل.

النتائج التي رصدها البحث:

| المقياس | التأثير |
|---|---|
| توفير وقت GPU | **31–42%** |
| معدل الاستئناف القسري | **تراجع 5.4 أضعاف** |
| تحسين P99 TTFT | **6%** |

## المبدأ الأساسي: التوجيه القائم على ميزانية الرموز

الفكرة وراء Dual-Pool بسيطة. يُقدَّر لكل طلب **أقصى عدد رموز متوقع**، ثم يُعيَّن الطلب لأحد المجمّعَين بناءً على عتبة محددة.

```
الرموز المتوقعة = رموز الإدخال + رموز الإخراج المتوقعة
```

حين يكون عدد رموز الإخراج مجهولًا — وهو الحال في معظم سيناريوهات الإنتاج — تُستخدم إحدى التقريبتين التاليتين:

1. **معاملات الطلب**: استخدام قيمة `max_tokens` حدًّا أعلى.
2. **التصنيف القائم على السجل التاريخي**: تتبّع توزيع أطوال الطلبات السابقة لكل مسار API أو بصمة نظام الرسالة، ثم التصنيف بناءً على قيمة P75 أو P90.

تعتمد العتبة الفاصلة على طبيعة أعباء العمل؛ وفي تجارب البحث استُخدم 512 رمزًا في الإخراج حدًّا بين القصير والطويل.

## المعمارية: هيكل المجمّعَين

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
<div class="d3-arch" data-arch-root id="enbudgetroutingvllmkueue-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 493, "height": 800, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 179, "y": 24, "w": 128, "h": 46, "title": "Client Request"}, {"id": "B", "x": 147, "y": 148, "w": 191, "h": 62, "title": ["Router", "Token-Budget Classifier"]}, {"id": "C", "x": 288, "y": 302, "w": 156, "h": 62, "title": ["Short-Context Pool", "vLLM Instance A"]}, {"id": "D", "x": 45, "y": 302, "w": 149, "h": 62, "title": ["Long-Context Pool", "vLLM Instance B"]}, {"id": "E", "x": 295, "y": 442, "w": 142, "h": 62, "title": ["Kueue LocalQueue", "short-pool"]}, {"id": "F", "x": 49, "y": 442, "w": 142, "h": 62, "title": ["Kueue LocalQueue", "long-pool"]}, {"id": "G", "x": 270, "y": 582, "w": 191, "h": 62, "title": ["GPU Worker Group A", "Small KV Cache Requests"]}, {"id": "H", "x": 24, "y": 582, "w": 191, "h": 62, "title": ["GPU Worker Group B", "Large KV Cache Requests"]}, {"id": "I", "x": 175, "y": 722, "w": 135, "h": 46, "title": "Return Response"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [243, 70, 243, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "Estimated tokens < threshold", "curve": [[292, 210], [366, 256], [366, 256], [366, 302]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Estimated tokens >= threshold", "curve": [[193, 210], [120, 256], [120, 256], [120, 302]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [366, 364, 366, 442]}, {"src": "D", "dst": "F", "kind": "data", "line": [120, 364, 120, 442]}, {"src": "E", "dst": "G", "kind": "data", "line": [366, 504, 366, 582]}, {"src": "F", "dst": "H", "kind": "data", "line": [120, 504, 120, 582]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[366, 644], [366, 683], [366, 683], [288, 722]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[120, 644], [120, 683], [120, 683], [197, 722]]}]});
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
      const container = document.getElementById('enbudgetroutingvllmkueue-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'enbudgetroutingvllmkueue-1';
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

يُدير مجمّع السياق القصير دورة KV Cache بسرعة عالية للحفاظ على إنتاجية مرتفعة، فيما يحتجز مجمّع السياق الطويل حجمًا كافيًا من ذاكرة KV Cache لإتمام عمليات التوليد الطويلة دون انقطاع. لا يتدخّل المجمّعان في بعضهما البعض.

## التكامل مع Kueue LocalQueue

تعتمد منصة ai-platform الخاصة بـ ThakiCloud على Kueue لجدولة أعباء عمل GPU على Kubernetes. يتيح دمج Dual-Pool Routing مع Kueue LocalQueue إدارة تخصيص موارد كل مجمّع بأسلوب تصريحي على مستوى الكلاستر.

### الخطوة 1: تعريف ClusterQueue و ResourceFlavor

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: llm-inference-cq
spec:
  namespaceSelector: {}
  resourceGroups:
    - coveredResources: ["nvidia.com/gpu"]
      flavors:
        - name: gpu-a100
          resources:
            - name: nvidia.com/gpu
              nominalQuota: 8
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: ResourceFlavor
metadata:
  name: gpu-a100
spec:
  nodeLabels:
    gpu.nvidia.com/model: A100
```

### الخطوة 2: تعريف LocalQueue منفصل لكل مجمّع

```yaml
apiVersion: kueue.x-k8s.io/v1beta1
kind: LocalQueue
metadata:
  name: short-pool-queue
  namespace: llm-serving
spec:
  clusterQueue: llm-inference-cq
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: LocalQueue
metadata:
  name: long-pool-queue
  namespace: llm-serving
spec:
  clusterQueue: llm-inference-cq
```

### الخطوة 3: إضافة التعليق التوضيحي للقائمة في vLLM Deployment

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-short-pool
  namespace: llm-serving
  annotations:
    kueue.x-k8s.io/queue-name: short-pool-queue
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model"
            - "meta-llama/Llama-3.1-8B-Instruct"
            - "--max-model-len"
            - "4096"       # مجمّع قصير: حد سياق صغير
            - "--gpu-memory-utilization"
            - "0.7"        # دوران سريع لـ KV Cache
          resources:
            limits:
              nvidia.com/gpu: "1"
---
apiVersion: apps/v1
kind: Deployment
metadata:
  name: vllm-long-pool
  namespace: llm-serving
  annotations:
    kueue.x-k8s.io/queue-name: long-pool-queue
spec:
  replicas: 2
  template:
    spec:
      containers:
        - name: vllm
          image: vllm/vllm-openai:latest
          args:
            - "--model"
            - "meta-llama/Llama-3.1-8B-Instruct"
            - "--max-model-len"
            - "32768"      # مجمّع طويل: نافذة سياق واسعة
            - "--gpu-memory-utilization"
            - "0.90"       # احتجاز كبير لـ KV Cache
          resources:
            limits:
              nvidia.com/gpu: "1"
```

### الخطوة 4: تطبيق الموجِّه (مثال بـ Python)

```python
from fastapi import FastAPI, Request
import httpx

app = FastAPI()

SHORT_POOL_URL = "http://vllm-short-pool-svc:8000/v1/chat/completions"
LONG_POOL_URL  = "http://vllm-long-pool-svc:8000/v1/chat/completions"
TOKEN_THRESHOLD = 512  # اضبط هذه القيمة وفق السجل التاريخي لأعباء العمل

def estimate_output_tokens(payload: dict) -> int:
    """استخدام max_tokens حدًّا أعلى. الافتراضي 256 عند الغياب."""
    return payload.get("max_tokens") or 256

def route_request(payload: dict) -> str:
    """إعادة عنوان URL المستهدف بحسب عدد الرموز المقدَّر."""
    estimated = estimate_output_tokens(payload)
    if estimated < TOKEN_THRESHOLD:
        return SHORT_POOL_URL
    return LONG_POOL_URL

@app.post("/v1/chat/completions")
async def proxy(request: Request):
    payload = await request.json()
    target_url = route_request(payload)
    async with httpx.AsyncClient(timeout=120.0) as client:
        resp = await client.post(target_url, json=payload)
        return resp.json()
```

يُنشر هذا الموجِّه كـ Kubernetes Service ويُوضع أمام نقطة نهاية الاستدلال الحالية.

## اعتبارات التشغيل

### ضبط العتبة الفاصلة

قيمة 512 رمزًا نقطة بداية لا معيار ثابت. في بيئات الإنتاج الفعلية، يُنصح بجمع المقاييس التالية على مدار سبعة أيام على الأقل قبل التعديل:

- توزيع رموز الإخراج الفعلية لكل طلب (P50، P90، P99)
- معدل الاستئناف القسري لكل مجمّع (`vllm:num_preemptions_total` في Prometheus)
- عمق قائمة الانتظار `vllm:num_requests_waiting` لكل مجمّع

إن ظلّ عمق قائمة انتظار المجمّع القصير مرتفعًا باستمرار، فاخفض العتبة أو أضف نسخًا إضافية. وإن تدنّى معدل استخدام GPU في المجمّع الطويل، فارفع العتبة لتقليل الطلبات الموجَّهة إليه.

### التكامل مع KEDA للتوسع التلقائي

تُتيح إضافة ScaledObject من KEDA مستندًا إلى مقاييس Prometheus الخاصة بـ vLLM توسعًا تلقائيًا مستقلًا لكل مجمّع:

```yaml
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: vllm-short-pool-scaler
  namespace: llm-serving
spec:
  scaleTargetRef:
    name: vllm-short-pool
  minReplicaCount: 1
  maxReplicaCount: 8
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://prometheus:9090
        metricName: vllm_requests_waiting_short
        query: vllm:num_requests_waiting{deployment="vllm-short-pool"}
        threshold: "5"
```

التوسع القائم على المقاييس أكثر استجابةً لأحمال الاستدلال مقارنةً بالتوسع القائم على معدل HTTP. عتبة `5` تعني بدء التوسع حين تتجاوز الطلبات المنتظرة خمسة طلبات.

### مشاركة النموذج مقابل فصل النسخ

لا يشترط الأسلوب استخدام نسختين منفصلتين من vLLM. تشغيل النموذج ذاته بإعدادات `--max-model-len` مختلفة هو التكوين الافتراضي، لكن إن توفّرت ميزانية ذاكرة كافية، يمكن لنسخة واحدة من vLLM أن تعرض منفذَي اتصال خارجيَّين بأولوية داخلية مختلفة.

غير أن **فصل النسخ هو الخيار الأوضح** للقضاء الكامل على تداخل الاستئناف، إذ تتشارك ذاكرة KV Cache داخل عملية vLLM الواحدة.

## الأهمية بالنسبة لمنصة ThakiCloud

تُخدِّم منصة ai-platform الخاصة بـ ThakiCloud أعباء استدلال عدة مستأجرين على كلاستر GPU مشترك. يُضيف Dual-Pool Routing ميزتَين ملموستَين في هذا السياق.

أولًا، يُقلّص التداخل بين المستأجرين. حين تتأخر طلبات المستأجر أ — ذات الطابع القصير — خلف مهام التحليل الطويلة للمستأجر ب، ينتج عن ذلك انتهاك لمستويات الخدمة المتفق عليها. فصل المجمّعات يقطع هذا التداخل على مستوى البنية.

ثانيًا، يرفع كفاءة ميزانية GPU. توفير 31–42% من وقت GPU يعني إما استيعاب طلبات أكثر بالميزانية ذاتها، أو تحقيق الإنتاجية نفسها بعدد أقل من وحدات GPU. في بيئات الخوادم المحلية ذات الموارد الثابتة، ينعكس هذا التوفير مباشرةً على تكلفة الخدمة.

بالنسبة لكلاسترات ThakiCloud التي تستخدم Kueue LocalQueue بالفعل، يتطلب تطبيق هذا الأسلوب إعلان قائمتَي انتظار فحسب وتوزيع موجِّه خفيف الوزن. التوافق مع مواصفات vLLM Deployment الحالية مرتفع، مما يُوسّع نطاق التبنّي.

## خلاصة

المشكلة التي يعالجها Dual-Pool Token-Budget Routing واضحة: حين تتشارك الطلبات القصيرة والطويلة قائمة انتظار واحدة، تخسر القصيرة. فصلها على مستوى قائمة الانتظار يُتيح لكل نوع المعالجة بسرعته الطبيعية.

النتائج التي رصدها arXiv 2604.08075 — توفير 31–42% من وقت GPU، وتراجع معدل الاستئناف بمقدار 5.4 أضعاف، وتحسن بنسبة 6% في P99 TTFT — تمثّل عائدًا كبيرًا قياسًا بتعقيد التطبيق. على Kubernetes، يكفي وجود قائمتَي Kueue LocalQueue واثنتَي نشر vLLM Deployment وموجِّه خفيف واحد لبناء هذه البنية.
