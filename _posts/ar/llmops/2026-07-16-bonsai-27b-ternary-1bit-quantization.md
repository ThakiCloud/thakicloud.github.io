---
title: "احتواء نموذج بحجم 27B داخل هاتف: تشريح ضغط Bonsai 27B بصيغتي 1-bit وternary"
excerpt: "لا يُعد Bonsai 27B، الذي أصدرته PrismML، نموذجا تم تدريبه من جديد، بل هو نتيجة ضغط أوزان Qwen3.6-27B إلى صيغتي 1-bit وternary مع إبقاء البنية المعمارية كما هي دون تغيير. وتفيد التقارير بأن نسخة ternary تحافظ على 94.6% من جودة FP16 بحجم 5.9GB، بينما تحافظ نسخة 1-bit على 89.5% بحجم 3.9GB. نستعرض في هذا المقال كيف يعمل هذا الضغط فعليا، ولماذا تُعد الذاكرة، لا سعة التخزين، القيد الحقيقي، وماذا تعني الخدمة منخفضة البت لبنية ThakiCloud التحتية للاستدلال متعددة المستأجرين."
tags:
  - quantization
  - bonsai-27b
  - ternary
  - 1-bit
  - llama-cpp
  - mlx
  - inference
  - serving
  - kv-cache
  - on-device
  - self-hosting
  - llmops
  - paxis
date: 2026-07-16
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/bonsai-27b-ternary-1bit-quantization/"
categories:
  - llmops
---

## نظرة عامة

تسير معظم محاولات تشغيل النماذج الكبيرة على أجهزة صغيرة في أحد اتجاهين. الأول هو تدريب نموذج صغير من الصفر، والثاني هو ضغط أوزان نموذج كبير بعد تدريبه. وقد اصطدم الاتجاه الثاني دائما بالجدار نفسه: عند النزول إلى ما دون 4-bit، تبدو نتائج المعايير القصيرة جيدة، لكن الجودة تنهار في مهام الاستدلال الطويلة مثل الرياضيات أو البرمجة.

في 14 يوليو 2026، أصدرت PrismML نموذج Bonsai 27B الذي يواجه هذا الجدار مباشرة. Bonsai 27B ليس نموذجا مدربا من جديد، بل يُبقي Qwen3.6-27B كما هو ويكتفي بتمثيل الأوزان فقط بصيغة منخفضة البت. البنية المعمارية لم تتغير. صدرت نسختان بترخيص Apache 2.0، وأفادت التقارير بأن نسخة ternary تحافظ على 94.6% من جودة النموذج الأصلي بحجم 5.9GB، بينما تحافظ نسخة 1-bit على 89.5% بحجم 3.9GB.

يقرأ هذا المقال Bonsai 27B من منظور ThakiCloud في خدمة النماذج منخفضة البت لبيئة متعددة المستأجرين. سنستعرض بالترتيب كيفية عمل الضغط، ولماذا تُعد الذاكرة، لا سعة التخزين، القيد الحقيقي، وما الأثر العملي لهذا التوجه على بنيتنا التحتية للاستدلال. ونوضح مسبقا أن جميع أرقام المعايير أدناه هي قيم نشرتها PrismML، وليست قيما أعادت ThakiCloud إنتاجها بنفسها.

## ما هو Bonsai 27B

Bonsai 27B هو تمثيل منخفض البت لنموذج Qwen3.6-27B. وبالتطبيق على نموذج متعدد الوسائط يتكون من نحو 24.8B من أوزان اللغة، و0.46B لبرج الرؤية، و2.5B للتضمينات ورأس LM، يُحوَّل النموذج بالكامل، بكل مكوناته كثيفة عمليات المصفوفات، إلى صيغة منخفضة البت. ويشمل ذلك التضمينات، وإسقاطات الانتباه، وإسقاطات MLP، ورأس LM، بينما يبقى جزء ضئيل جدا فقط، مثل معاملات التطبيع والمقياس، بدقة عالية. أما برج الرؤية فيُحفظ بشكل منفصل بصيغة 4-bit HQQ ولا يُحمَّل إلا عند وجود مدخل صورة.

تختلف طبيعة النسختين. تُمثل نسخة Ternary Bonsai 27B الأوزان بثلاث قيم `{-1, 0, +1}` لتصل إلى فعالية 1.71 بت وسعة مثالية قدرها 5.9GB. أما نسخة 1-bit Bonsai 27B فتستخدم قيمتين فقط `{-1, +1}` لتصل إلى فعالية 1.125 بت بحجم 3.9GB. ويُدعم السياق حتى 262K رمز (token)، ويظل هذا عمليا لأن نحو 75% من آلية انتباه Qwen3.6-27B خطية.

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
<div class="d3-arch" data-arch-root id="bternary1bitquantization-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 359, "height": 1134, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 114, "y": 24, "w": 120, "h": 62, "title": ["Qwen3.6-27B", "FP16 54GB"]}, {"id": "B", "x": 71, "y": 164, "w": 205, "h": 62, "title": ["تقسيم على مستوى المجموعات", "مجموعة واحدة لكل 128 وزنا"]}, {"id": "C", "x": 69, "y": 304, "w": 209, "h": 52, "title": "دفتر الشيفرة منخفض البت"}, {"id": "D", "x": 199, "y": 448, "w": 128, "h": 62, "title": ["-1, 0, +1", "حوالي 1.585 بت"]}, {"id": "E", "x": 24, "y": 448, "w": 120, "h": 62, "title": ["-1, +1", "1.0 بت"]}, {"id": "F", "x": 68, "y": 588, "w": 212, "h": 62, "title": ["مقياس FP16 واحد لكل مجموعة", "+16/128 بت"]}, {"id": "G", "x": 82, "y": 728, "w": 184, "h": 62, "title": ["Ternary 1.71 bpw 5.9GB", "Binary 1.125 bpw 3.9GB"]}, {"id": "H", "x": 75, "y": 868, "w": 198, "h": 78, "title": ["برج الرؤية", "يُخزَّن بشكل منفصل بصيغة", "HQQ رباعية البت"]}, {"id": "I", "x": 71, "y": 1024, "w": 205, "h": 78, "title": ["llama.cpp / MLX", "استدلال محلي على الحواسيب", "المحمولة والهواتف"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [174, 86, 174, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [174, 226, 174, 304]}, {"src": "C", "dst": "D", "kind": "data", "label": "Ternary", "curve": [[206, 356], [263, 402], [263, 402], [263, 448]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "Binary", "curve": [[141, 356], [84, 402], [84, 402], [84, 448]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "curve": [[263, 510], [263, 549], [263, 549], [213, 588]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 510], [84, 549], [84, 549], [134, 588]]}, {"src": "F", "dst": "G", "kind": "data", "line": [174, 650, 174, 728]}, {"src": "G", "dst": "H", "kind": "data", "line": [174, 790, 174, 868]}, {"src": "H", "dst": "I", "kind": "data", "line": [174, 946, 174, 1024]}]});
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
      const container = document.getElementById('bternary1bitquantization-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'bternary1bitquantization-1';
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

## كيف يعمل الضغط

الفكرة الأساسية بسيطة. يُخزَّن كل وزن كرمز واحد، وتشترك كل مجموعة من 128 وزنا في مقياس FP16 واحد. ويُعاد بناء الوزن الفعلي كحاصل ضرب مقياس المجموعة في الرمز، بالصيغة `w_i = s_g · t_i`.

بتتبع حساب البتات تتضح تكلفة التخزين. تحمل قيمة ternary واحدة `log2(3) ≈ 1.585` بت. وبإضافة مقياس FP16 واحد لكل 128 قيمة، تُضاف `16/128` بت ليصل المجموع إلى نحو 1.71 بت، أي تقليص بمقدار نحو 9.4 مرة مقارنة بـ FP16. أما binary فالقيمة نفسها بت واحد، وبإضافة عبء المقياس نفسه يصبح `1 + 16/128 = 1.125` بت، أي تقليص بمقدار نحو 14.2 مرة.

يظهر هنا تباين لافت. فنسخة Q4_K_XL من Qwen3.6-27B، التي تُسمى عادة 4-bit، يبلغ متوسطها الفعلي 5.2 بت، ونسخة IQ2_XXS التي تُسمى 2-bit يبلغ متوسطها الفعلي 2.8 بت. أي أن الاسم يختلف عن متوسط البت الفعلي. كما يختلف Bonsai عن BitNet. فـ BitNet يُدرَّب من الصفر بدقة منخفضة البت تجنبا للانهيار، بينما يضغط Bonsai نموذجا مدربا مسبقا بعد تدريبه. وتدعي PrismML أنها تجنبت الانهيار دون إعادة تدريب، لكن تفاصيل هذا الادعاء تعتمد على الوثائق التقنية المنشورة.

## نتائج المعايير المُبلَّغ عنها

أفادت PrismML بأنها قيّمت 15 معيارا في وضع thinking باستخدام EvalScope وvLLM على H100. يعرض الجدول أدناه هذه القيم المُبلَّغ عنها. ونؤكد مجددا أن هذه الأرقام هي قيم نشرها المزوّد، وليست قيما أعادت ThakiCloud إنتاجها، وأن إعادة الإنتاج المستقلة تتطلب تحققا منفصلا.

| النسخة | bpw الفعلي | الحجم | متوسط Thinking | مقارنة بـ FP16 |
|---|---|---|---|---|
| Qwen3.6-27B FP16 | 16.0 | 54GB | 85.07 | خط الأساس |
| Q4_K_XL (4-bit) | 5.2 | 17.6GB | 84.99 | 99.9% |
| IQ2_XXS (2-bit) | 2.8 | 9.4GB | 72.73 | 85.5% |
| Ternary Bonsai 27B | 1.71 | 5.9GB | 80.49 | 94.6% |
| 1-bit Bonsai 27B | 1.125 | 3.9GB | 76.11 | 89.5% |

وعند التقسيم حسب الفئة، يتضح أن الضغط لا يُحدث خسارة موحدة. فالرياضيات تصمد نسبيا جيدا، من 95.33 عند FP16 إلى 93.40 لـ ternary و91.66 لـ 1-bit. في المقابل، تنخفض مهام الوكيل (agent) واستدعاء الأدوات بشكل حاد من 80.00 إلى 74.01 لـ ternary و66.03 لـ 1-bit، وتنخفض الرؤية من 72.61 إلى 59.57 لـ 1-bit. كما تنخفض القدرة على اتباع التعليمات بشكل كبير من 78.47 إلى 65.74 لـ 1-bit.

التباين الذي تُبرزه PrismML هو الانهيار الانتقائي في نسخ sub-4-bit السابقة. فنسخة IQ2_XXS تحافظ على 88.93 في مهام الإجابات القصيرة مثل MMLU-Redux، لكنها تنهار إلى 57.5 في AIME26 و56.4 في LiveCodeBench. والملاحظة هي أن المعايير القصيرة تُخفي هذا الانهيار. وهذه الملاحظة بحد ذاتها بصيرة عملية يتفهمها كل من تعامل مع الضغط منخفض البت من قبل.

## الذاكرة هي القيد الحقيقي

قراءة إصدار Bonsai 27B بالاعتماد فقط على أرقام الحجم تُفوّت الجوهر. فشروط تشغيل النموذج على هاتف أكثر صرامة بكثير من سعة التخزين وحدها. يقيّد iOS التطبيق الواحد باستخدام نحو نصف الذاكرة الفعلية فقط، لذا فإن هاتف iPhone بذاكرة 12GB لا يُتيح فعليا سوى نحو 6GB. وهنا تكمن أهمية نسخة 3.9GB.

الميزانية الثانية هي ذاكرة التخزين المؤقت KV cache. وبما أن 16 فقط من أصل 64 طبقة تمتلك ذاكرة تخزين مؤقت كاملة الانتباه ومتنامية، فإن التكلفة تبلغ نحو 64KiB لكل رمز عند FP16. وملء نافذة 262K بالكامل يكلف نحو 17.2GB، ويؤدي استخدام ذاكرة تخزين مؤقت KV بدقة 4-bit إلى خفض ذلك إلى نحو 4.3GB. ومهما قلّصنا أوزان النموذج، فإن السياق الأطول سيستهلك الذاكرة عبر ذاكرة التخزين المؤقت KV، لذا يجب أن تسير الأوزان منخفضة البت وذاكرة التخزين المؤقت منخفضة البت معا.

وأفادت PrismML أيضا بأنها قاست الأثر على الجودة الناتج عن ضغط الذاكرة المؤقتة. فمقارنة بخط الأساس FP16-KV الخاص بها، أظهرت نسخة Ternary Bonsai قيمة forward-KL للمخرجات بلغت 0.0011 nats على MATH-500، بينما أظهرت Q4_K_XL قيمة 0.0146. وعند 100K رمز باستخدام ذاكرة مؤقتة FP16، تبلغ الذروة نحو 11.6GB لنسخة 1-bit ونحو 14.7GB لنسخة ternary. أي أنه حتى بعد تقليص الأوزان، يتطلب السياق الطويل خفض دقة الذاكرة المؤقتة أيضا حتى يتسع النموذج فعليا على الجهاز.

## الإنتاجية وفك الترميز التخميني

التوليد مقيد بعرض النطاق الترددي للذاكرة. فكلما قلّت البايتات المقروءة في كل خطوة، زاد عدد الرموز في الثانية. أما التعبئة المسبقة prefill فمقيدة بالحوسبة، لذا يكون أثر الضغط عليها أصغر نسبيا. والإنتاجية التي نشرتها PrismML تُظهر هذه الخاصية بوضوح.

| المنصة | النسخة | tg128 (التوليد) | pp512 (التعبئة المسبقة) |
|---|---|---|---|
| M5 Max | Binary | 66.4 | 874 |
| M5 Pro | Ternary | 26.2 | 393 |
| iPhone 17 Pro Max | Binary | 11.0 | 111 |
| H100 (CUDA) | Binary | 104.8 | 2755 |

أصدرت PrismML أيضا مُسوِّدا (drafter) باسم DSpark مدربا خصيصا لاستهداف Bonsai 27B. وعلى H100، وبعمق مُسوَّدة (draft depth) k=4، أفادت بطول قبول tau=3.6 للنسخة binary المستهدفة، أي 143.8 tok/s، بتسريع قدره 1.37 مرة. والتحقق بلا فقدان (lossless)، لذا يبقى توزيع المخرجات مطابقا. بيد أن المُسوِّد معطّل افتراضيا على شرائح Apple silicon عند حجم دفعة (batch size) يساوي 1.

التشغيل نفسه معياري تماما. يمكن تشغيل خادم llama.cpp أو التوليد مباشرة عبر llama-cli، كما يُوفَّر مسار MLX أيضا. ويستخدم استدعاء الأدوات مصفوفة `tools` بأسلوب OpenAI كما هي، وتعود الاستجابة عبر `choices[0].message.tool_calls`. ووضع thinking مفعّل افتراضيا ويمكن تبديله لكل طلب.

## ماذا يعني هذا لـ ThakiCloud

تتقاطع الخدمة منخفضة البت مع منتجَي ThakiCloud كليهما.

**منظور ai-platform (البنية التحتية والخدمة).** تخدم منصة ai-platform التابعة لـ ThakiCloud نماذج مفتوحة الأوزان عبر بيئات عملاء متنوعة. وما يُظهره Bonsai هو إمكانية وضع جودة بمستوى 27B على GPU واحدة بسعة 24GB مع ذاكرة تخزين مؤقت KV بدقة 4-bit. وهذا يؤثر مباشرة على كثافة تعدد المستأجرين. فإذا أمكن تشغيل عدد أكبر من المستأجرين على GPU نفسها، أو تحقيق نفس اتفاقية مستوى الخدمة SLA ببطاقة أصغر، تنخفض تكلفة الخدمة. ولهذا أهمية خاصة في عمليات النشر المحلية (on-premises) والسيادية. فالقطاع العام المحلي والصناعات الخاضعة للتنظيم تتطلب استضافة ذاتية self-hosting تمنع خروج البيانات، بينما تظل ميزانيات الأجهزة محدودة. وخفض أوزان النموذج وذاكرة التخزين المؤقت KV معا إلى صيغة منخفضة البت يتيح تجميعا أكثف في تجمع GPU تُجدوله Kueue، وهذا يصب مباشرة في كفاءة التكلفة وكثافة الموارد التي نُشدد عليها دائما. غير أن منخفض البت ليس الحل دائما. فإذا كان عبء العمل متمركزا حول الوكلاء (agent) أو استدعاء الأدوات، تكون خسارة الجودة كبيرة كما يُبيّن قسم القيود أدناه، وهو ما يستدعي توجيها (routing) يُغيّر الدقة بحسب عبء العمل.

**منظور Paxis (الوكلاء والحافة).** Paxis هو مستوى تحكم Agent-Native Cloud الذي يعمل فوق ai-platform، ويتعامل مع Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. والنموذج الذي يعمل على هاتف بحجم 3.9GB يفتح الباب أمام وكلاء on-device في السياقات الحساسة للخصوصية. فإعداد لا يغادر فيه الطلب (prompt) الجهاز مفيد للامتثال التنظيمي ولسير العمل دون اتصال (offline). ومن منظور Paxis، يبدو طبيعيا التعامل مع هذه النماذج المحلية داخل تنفيذ معزول في صندوق رملي (sandbox)، مع تمرير كل إجراء عبر بوابات السياسات وسجلات التدقيق. فالاستدلال المحلي منخفض البت يخلق اقتصاديات وكلاء الحافة، وPaxis هو الطبقة التي تحكم ذلك التنفيذ.

يُكمّل المنظوران أحدهما الآخر. فالخدمة منخفضة التكلفة (ai-platform) هي ما يخلق اقتصاديات الوكلاء (Paxis).

## القيود والحجج المضادة

أكبر تحفظ يتعلق بمصدر المعايير. فكل الأرقام أعلاه هي تقييمات ذاتية من PrismML، ولا توجد إعادة إنتاج مستقلة حتى الآن. والحجة التي تُشير إلى الانهيار الانتقائي لـ IQ2_XXS مقنعة، لكن المعايير التي تُظهر تفوق Bonsai هي أيضا قياسات ذاتية من المزوّد نفسه. والحكم العادل يتطلب إعادة إنتاج من طرف ثالث.

وعدم انتظام خسارة الجودة مهم عمليا أيضا. فدرجة الوكيل واستدعاء الأدوات لنسخة 1-bit لا تتجاوز 66.03. ودقة استدعاء الأدوات عند هذا المستوى تنطوي على مخاطر لخطوط أنابيب الوكلاء في الإنتاج. كما أن الرؤية عند 59.57 واتباع التعليمات عند 65.74 يشهدان انخفاضا كبيرا بالمثل، مما يعني أن نسخة 1-bit تقتصر عمليا على الاستدلال النصي البسيط والاستخدام على الجهاز ذي الأولوية للخصوصية. أما المسارات التي تحتاج جودة، فيجب أن ترتقي إلى ternary أو دقة أعلى.

كما يجب قراءة أرقام أداء الهاتف بحذر. فأرقام tok/s على iPhone كافية للتفاعلات القصيرة لكنها بطيئة للتوليد الطويل. والحرارة والبطارية والإنتاجية المستدامة لا تظهر في جدول المعايير. وتذكر الورقة البيضاء أنها قاست 672 رمزا لكل 1% من بطارية iPhone، لكن زمن الاستجابة الفعلي والاستمرارية في الاستخدام الحقيقي مسألتان منفصلتان.

وأخيرا، يعتمد الادعاء الأساسي بتجنب الانهيار دون إعادة تدريب على تفاصيل المنهجية الواردة في الوثائق المنشورة. والترخيص هو Apache 2.0، لكن علاقة وراثة الترخيص من نموذج Qwen3.6 الأساسي تتطلب تحققا قبل النشر التجاري. وخلاصة القول إن Bonsai 27B يمثل تقدما عمليا حقيقيا في الضغط منخفض البت، لكن قرارات التبني ينبغي أن تُتخذ بالتوازي مع متطلبات الجودة الخاصة بكل عبء عمل وإعادة الإنتاج المستقلة.

## نتائج إعادة الإنتاج المستقلة من ThakiCloud

في القيود أعلاه ذكرنا أنه لا توجد بعد إعادة إنتاج مستقلة. لقد أجريناها. القارئ المستهدف هو مهندس بنية تحتية يفكر في بناء مسار تكميم منخفض البِتّات ذاتي الاستضافة. باختصار، نموذج البِتّة الواحدة الذي أصدرته PrismML يعمل فعلاً، لكن طريقة الضغط نفسها لا يمكن إعادة إنتاجها لأنها لم تُنشر قط.

قرأنا أولاً الأوراق البيضاء الثلاث كاملة بعد استخراج نصها. المنشور هو صيغة التخزين ونوى الاستدلال ونتائج القياس فقط. أما خوارزمية إسناد أوزان البِتّة الواحدة دون إعادة تدريب مع تجنب الانهيار فلا تظهر في أي مكان. تصفها ورقة 8B صراحةً بأنها "ملكية فكرية خاصة من Caltech". الطريقة مغلقة.

ثم حمّلنا إصدارهم `Bonsai-1.7B-unpacked` (أوزان البِتّة الواحدة معادة إلى FP16) بأدوات قياسية. استخدمت كل مجموعة من 128 وزناً مقياساً واحداً فقط، وكانت الحيرة على مقطع ثابت 3.492، أي مطابقة عملياً لنفس أساس Qwen3-1.7B عند FP16 (3.507). النموذج المُصدَر حقيقي وشبه خالٍ من الفقد.

في المقابل، إعادة الإنتاج الساذجة من الصيغة العامة وحدها (تثنية BWN المعيارية) تنهار تماماً عند نفس 1.125 بِتّة. يؤكد شاهد الـ4 بِتّات سلامة أداة القياس.

| المتغير | bpw | الحيرة | مقابل FP16 |
|---|---|---|---|
| Qwen3-1.7B FP16 | 16 | 3.507 | 1.00x |
| PrismML بِتّة واحدة (طريقتهم) | 1.125 | 3.492 | 0.995x، بلا فقد |
| تثنية ساذجة (الصيغة العامة) | 1.125 | 2,109,839 | 601,600x، انهيار |
| شاهد 4 بِتّات | 4.125 | 4.209 | 1.14x، سليم |

الطريقة المغلقة يمكن التنبؤ بها. لأننا نملك أوزانهم الفعلية، قارنّاها مع أوزان الأساس واستخرجنا بصمة الطريقة. توافقت إشاراتهم مع الأساس بنسبة 71.6% فقط، أي أن نحو 28% من الإشارات قُلبت، بينما تحافظ التثنية الساذجة على كل إشارة. كما كانت مقاييس مجموعاتهم أكبر بمقدار 2.26 مرة من المتوسط الساذج. هذه بصمة تعويض الخطأ الذي يقلّل خطأ خرج الطبقة لا خطأ الوزن المفرد، أي عائلة GPTQ. وبما أن التوافق أعلى بكثير من 50% العشوائية، فالأساس هو Qwen غير معدّل، بما يتسق مع ادعائهم "دون إعادة تدريب".

نفّذنا هذا التنبؤ لاختباره. مكمِّم ثنائي بتعويض الخطأ كتبناه يدوياً (عائلة GPTQ) استرجع نحو 10 أضعاف من الانهيار الساذج. الاتجاه كان صحيحاً. لكن بقيت فجوة كبيرة مع FP16 حتى بعد الاسترجاع، وتكبير المقياس 2.26 مرة وحده زاد الأمر سوءاً، ما يعني أن المقياس الأكبر لا يفيد إلا مقترناً بتحسين الإشارة. تعويض الخطأ المعياري ضروري لكنه غير كافٍ. الوصول إلى بِتّتهم الواحدة بلا فقد يحتاج معالجة الأوزان البارزة أو مخططات المتبقي، وهو بالضبط الجزء الذي حجبوه.

تنبيه واحد: هذه الحيرة إشارة خشنة على مقطع قصير وعلى نماذج صغيرة. إعادة إنتاج الاحتفاظ حسب الفئة (استدعاء الأدوات، الرؤية) تتطلب بناء نواهم الخاصة وخدمة نموذج 27B وتشغيل حزمة القياس كاملة، وهو ما نتركه عملاً منفصلاً. مع ذلك، إجابة "هل تعمل البِتّة الواحدة فعلاً" هي نعم، وإجابة "هل يمكن للمواد العامة إعادة إنتاج تلك الجودة" هي لا. تلك الفجوة هي قيمة هذه التقنية.

كما دفعنا أحدث الطرق العامة إلى أقصى حد. في أبحاث التكميم منخفض البِتّات الحديثة (QuIP وBiLLM وQuaRot وSpinQuant) أكبر رافعة هي دوران عدم التماسك: دوران متعامد عشوائي يوزّع الأوزان الشاذة إلى توزيع شبه غاوسي يُثنّى بنظافة، وعند اقترانه بتعويض الخطأ يُنعش البِتّة الواحدة النقية بشكل كبير. الدوران وحده يضر فعلاً ويجب دمجه مع GPTQ، وهو ما أكدناه. مقيساً على نفس الأساس الذي استخدموه، Qwen3-1.7B، بنفس الأداة:

| الطريقة | eff bpw | الحيرة | مقابل FP16 | escape |
|---|---|---|---|---|
| FP16 | 16 | 2.027 | 1.00x | لا |
| PrismML Bonsai (طريقتهم) | 1.125 | 1.971 | 0.97x | لا |
| QuIP لدينا (دوران + تعويض خطأ) | 1.125 | 4.213 | 2.1x | لا |
| QuIP + salient 3% لدينا | 1.571 | 2.24 | 1.1x | 3% |

تبلغ الحزمة العامة (QuIP + salient) قيمة 2.24، تقارب جودتهم 1.971. لكن تبقى فجوة حاسمة: هم يحققون تلك الجودة عند 1.125 bpw نقية دون منفذ عالي الدقة، بينما احتجنا 1.57 bpw و3% دقة عالية، وعند نفس نقطة البِتّة الواحدة النقية نصل إلى 4.21 مقابل 1.97 لهم. الجودة تكاد تتقارب، لكنهم يحتفظون بأفضلية كفاءة على منحنى باريتو. ملاحظة لافتة أن الدوران يفيد أكثر بكثير كلما كبر النموذج: كان المكسب صغيراً عند 0.6B وكبيراً عند 1.7B، ما يفسّر جزئياً كيف يصلون إلى انعدام الفقد عند 27B. هذه الأرقام إشارة خشنة على مقطع قصير، لذا تحتاج الادعاءات القاطعة إلى تقييم قياسي كامل. كود إعادة الإنتاج الكامل منشور مفتوح المصدر.

نقطة أخيرة نوضحها بصراحة. تجري هذه الدراسة كاملة ضمن قيد التكميم بعد التدريب، لمجاراة ادعائهم "دون إعادة تدريب" على قدم المساواة. إذا كنت مستعداً للتدريب، فإن البِتّات المنخفضة شبه عديمة الفقد مسار معروف بالفعل. يدرّب BitNet وBitNet b1.58 أوزاناً ثنائية وثلاثية من الصفر ويطابقان جودة FP16 على نطاق واسع، ويصل التدريب الواعي بالتكميم والتقطير إلى النتيجة نفسها بوسائل أخرى. إذن جواب سؤال "هل يمكن وجود نموذج بِتّة واحدة عديم الفقد" هو نعم بديهياً إن دربت من أجله. المشكلة الصعبة والقيّمة هي بلوغ تلك الجودة لاحقاً على نموذج مدرَّب مسبقاً دون إعادة تدريب، وهو بالضبط ما فعلته PrismML. وبالعكس، بالنسبة لمؤسسة تتحكم في تدريبها، فإن التدريب الأصلي منخفض البِتّات بأسلوب BitNet يتجاوز هذه الفجوة اللاحقة كلياً، مقايضاً كلفة GPU بالجودة.

## المصادر

- [prism-ml/Bonsai-27B-gguf (Hugging Face)](https://huggingface.co/prism-ml/Bonsai-27B-gguf)
- [PrismML Releases Bonsai 27B (MarkTechPost)](https://www.marktechpost.com/2026/07/14/prismml-releases-bonsai-27b-1-bit-and-ternary-builds-of-qwen3-6-27b-that-run-on-laptops-and-phones/)
- [PrismML Bonsai 27B docs](https://docs.prismml.com/models/bonsai-27b)
