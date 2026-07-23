---
title: "Qwen3.6-27B بصيغة NVFP4: اقتصاد الخدمة على GPU واحدة من Blackwell"
excerpt: "أعادت NVIDIA تكميم Qwen3.6-27B إلى NVFP4 ليُخدَم على GPU واحدة من Blackwell عبر vLLM مباشرةً. نفكّك كيف تُوائم الدقة المختلطة (MLP بصيغة NVFP4 والانتباه وذاكرة KV بصيغة FP8) نموذجًا بحجم 27B ضمن نحو 22GB، وماذا يعني ذلك لاقتصاد خدمة GPU متعددة المستأجرين في ThakiCloud ai-platform."
seo_title: "Qwen3.6-27B-NVFP4 على vLLM: تحليل الخدمة على GPU واحدة من Blackwell | Thaki Cloud"
seo_description: "كيف تُخدَم إعادة تكميم NVIDIA ModelOpt لـ Qwen3.6-27B-NVFP4 (MLP بصيغة NVFP4 W4A16 والانتباه وذاكرة KV بصيغة FP8) عبر vLLM، وماذا تعني الخدمة على GPU واحدة من Blackwell لكفاءة تكلفة GPU في ThakiCloud ai-platform."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - vllm
  - nvfp4
  - quantization
  - blackwell
  - model-serving
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "microchip"
published: true
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/qwen3-6-27b-nvfp4-vllm-blackwell/"
categories:
  - llmops
---

## نظرة عامة

إذا أمكنك خدمة نموذج من فئة 27B على GPU واحدة وبدقة شبه خالية من الخسارة، يتغير اقتصاد الاستدلال في البيئات المحلية. تعيد نقطة التحقق nvidia/Qwen3.6-27B-NVFP4 تكميم Qwen3.6-27B إلى نوع بيانات NVFP4 ليعمل على vLLM حديث دون أي إعداد إضافي. هذه هي خلفية إعلان مشروع vLLM أن نقطة التحقق هذه جاهزة للاستدلال على وحدات Blackwell.

الجوهر ليس مجرد "التخفيض إلى 4 بت" بل **ما الذي خُفّض وما الذي بقي**. يشرّح هذا المقال تصميم الدقة المختلطة في إعادة تكميم NVFP4، ويعرض كيفية خدمته فعليًا عبر vLLM، ثم يستعرض ماذا يعني ذلك لبنية تكلفة خدمة GPU متعددة المستأجرين في ThakiCloud ai-platform. وحيثما يلزم القياس، نُشير إليه بصدق.

## ما هذا

NVFP4 صيغة عائمة بأربع بتات تخفض عدد البتات لكل معامِل من 16 إلى 4، فتقلّص متطلبات القرص وذاكرة GPU بنحو 2.5 مرة. لكن التصميم الفعلي لـ nvidia/Qwen3.6-27B-NVFP4 لا يسحق كل شيء إلى 4 بت. فإعادة تكميم NVIDIA ModelOpt **تخفض طبقات MLP الخطية فقط إلى NVFP4 (W4A16)، مع إبقاء طبقات الانتباه الخطية وذاكرة KV بصيغة FP8.** ونتيجة لذلك تتّسع نحو 22GB من الأوزان على GPU واحدة من Blackwell. وتُبلّغ NVIDIA بأن هذا التكوين شبه خالٍ من الخسارة في الدقة مقارنةً بخط أساس FP8.

لهذا الاختيار المختلط سبب. فطبقات MLP تحمل الحصة الطاغية من المعامِلات، فوفر الذاكرة فيها كبير وتتحمّل التخفيض إلى 4 بت نسبيًّا. أما الانتباه وذاكرة KV فحساسان للجودة في السياقات الطويلة، فيبقيان بصيغة FP8 حفاظًا على الدقة. المبدأ: "خفّض الجزء الأثقل بأشد قدر، وأبقِ الجزء الأكثر حساسية بتحفّظ".

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
<div class="d3-arch" data-arch-root id="n3627bnvfp4vllmblackwell-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 605, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 185, "y": 24, "w": 205, "h": 62, "title": ["أوزان Qwen3.6-27B الأصلية", "FP16"]}, {"id": "B", "x": 210, "y": 164, "w": 156, "h": 62, "title": ["إعادة تكميم NVIDIA", "ModelOpt"]}, {"id": "C", "x": 431, "y": 304, "w": 142, "h": 62, "title": ["طبقات MLP الخطية", "NVFP4 W4A16"]}, {"id": "D", "x": 199, "y": 304, "w": 177, "h": 62, "title": ["طبقات الانتباه الخطية", "تبقى FP8"]}, {"id": "E", "x": 24, "y": 304, "w": 120, "h": 62, "title": ["ذاكرة KV", "تبقى FP8"]}, {"id": "F", "x": 206, "y": 444, "w": 163, "h": 46, "title": "نحو 22GB من الأوزان"}, {"id": "G", "x": 189, "y": 568, "w": 198, "h": 62, "title": ["تُحمَّل على GPU واحدة من", "Blackwell"]}, {"id": "H", "x": 199, "y": 708, "w": 177, "h": 62, "title": ["vLLM يكتشف تلقائيًا", "quantization modelopt"]}, {"id": "I", "x": 192, "y": 848, "w": 191, "h": 62, "title": ["نقطة استدلال متوافقة مع", "OpenAI"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [288, 86, 288, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[366, 220], [502, 265], [502, 265], [502, 304]]}, {"src": "B", "dst": "D", "kind": "data", "line": [288, 226, 288, 304]}, {"src": "B", "dst": "E", "kind": "data", "curve": [[210, 222], [84, 265], [84, 265], [84, 304]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[502, 366], [502, 405], [502, 405], [367, 444]]}, {"src": "D", "dst": "F", "kind": "data", "line": [288, 366, 288, 444]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[84, 366], [84, 405], [84, 405], [212, 444]]}, {"src": "F", "dst": "G", "kind": "data", "line": [288, 490, 288, 568]}, {"src": "G", "dst": "H", "kind": "data", "line": [288, 630, 288, 708]}, {"src": "H", "dst": "I", "kind": "data", "line": [288, 770, 288, 848]}]});
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
      const container = document.getElementById('n3627bnvfp4vllmblackwell-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'n3627bnvfp4vllmblackwell-1';
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

مقارنةً بتكميم موحّد إلى 4 بت (مثل W4 عبر كل الطبقات)، يلتقط هذا النهج معظم وفر الذاكرة مع الدفاع عن الجودة بإبقاء الطبقات الحساسة بصيغة FP8. وضبط مقايضة الوفر مقابل الدقة لكل طبقة هو الميزة الفارقة لإعادة تكميم NVFP4.

## التثبيت والخدمة

يكتشف vLLM تكميم ModelOpt تلقائيًّا من نقطة التحقق، فلا حاجة صارمة لتمرير راية تكميم. لكنك تحتاج vLLM حديثًا يدعم NVFP4/W4A16، وتوصي NVIDIA بإصدار nightly أو بناء من المصدر يتضمن دعم ModelOpt. شغّل صورة nightly عبر Docker وقدّم الخدمة كالتالي.

```bash
# vLLM حديث بدعم NVFP4/ModelOpt (صورة nightly)
docker run --gpus all -p 8000:8000 \
  vllm/vllm-openai:nightly \
  vllm serve nvidia/Qwen3.6-27B-NVFP4 \
    --port 8000 \
    --quantization modelopt \
    --max-model-len 262144 \
    --reasoning-parser qwen3
```

تستخدم `--max-model-len 262144` السياق الطويل لعائلة Qwen3.6 كما هو، وتتولى `--reasoning-parser qwen3` تحليل رموز الاستدلال. والنقطة متوافقة مع OpenAI، فتتصل بها العملاء القائمة دون تغيير.

## نتائج التجربة

بصراحة: تفترض نقطة التحقق هذه GPU من فئة Blackwell، والبيئة التي كُتب فيها هذا المقال لا تملك هذا العتاد، لذا **لم نتمكن من إعادة إنتاجها محليًّا.** ومن ثم فالأرقام أدناه ليست قياساتنا بل أرقام أبلغت بها مصادر عامة، مقتبسة كما هي مع الإسناد.

- تُبلّغ NVIDIA بأن تكوين NVFP4 المُعاد تكميمه **شبه خالٍ من الخسارة** في الدقة مقارنةً بخط أساس FP8 (بحسب بطاقة النموذج).
- حجم الأوزان نحو **22GB**، يتّسع على GPU واحدة من Blackwell (بحسب بطاقة النموذج).
- يُبلّغ أحد المعايير الخارجية (loFT LLC) بنحو **190 tok/s من إنتاجية التوليد** بتكوين NVFP4+MTP على RTX PRO 6000 Blackwell Max-Q مزدوجة. وهذا قياس خارجي بدرجة [تقديري]، لا قيمة بيئتنا.

ما أمكننا التحقق منه هو حقائق مسار الخدمة. فكون vLLM يكتشف تكميم ModelOpt تلقائيًّا، وأن التكوين مختلط الدقة (MLP بصيغة NVFP4 والانتباه وKV بصيغة FP8)، وأن نحو 22GB من الأوزان تتّسع على GPU واحدة من Blackwell، كلها مؤكدة في بطاقة النموذج العامة ووصفة vLLM. أما الإنتاجية والكمون الفعليان فيبقيان مسألة تُقاس حين يتوفر العتاد.

## الأثر على منتجات ThakiCloud

ما يجعل نقطة التحقق هذه مثيرة للاهتمام ليس أرقام المعايير نفسها بل **تحول اقتصاد الخدمة**. تُخدِّم ThakiCloud ai-platform النماذج عبر بيئات عملاء متنوعة على K8s وKueue، وGPU دومًا أغلى مورد. فإذا أمكن لنموذج من فئة 27B أن يتّسع على GPU واحدة، وبشكل شبه خالٍ من الخسارة، فأنت تخفض إشغال GPU لكل مستأجر وتستطيع استضافة مزيد من النماذج أو مزيد من المستأجرين على العتاد نفسه.

من منظور تعدد المستأجرين، يتضاعف هذا الوفر. فحين ينزل نموذج من GPU إلى واحدة، تكاد فتحات الخدمة المتزامنة في العنقود تتضاعف. وضمن تخصيص GPU المستند إلى Kueue، يُترجم ذلك مباشرةً إلى طوابير انتظار أقصر وتقاسم عادل أسهل بين المستأجرين. ويهم ذلك خاصةً العملاء ذوي المتطلبات المحلية والسيادية القوية، لأن عدد وحدات GPU الواجب شراؤها يقل، فينخفض حاجز الاستثمار الأولي وتكلفة التشغيل.

كما يتوافق تصميم الدقة المختلطة مع فلسفتنا التشغيلية. فبدل خفض الدقة عشوائيًّا، يتماشى نهج إبقاء الأجزاء الحساسة للجودة وخفض الأجزاء الثقيلة فقط بقوة مع هدف "كفاءة التكلفة والجودة معًا". ولهذا، عند تبني نقطة تحقق مكمَّمة جديدة على ai-platform، نراجع لا درجة المعيار فحسب بل أي طبقات عُوملت بأي دقة. وإعادة تكميم NVFP4 حالة مرجعية جيدة لتلك المراجعة، وحالما نؤمّن إنتاجية مقاسة نخطط لمقال متابعة عن ملف تكلفتها وجودتها في مكدس الخدمة لدينا.

## الحدود والاعتراضات

أولًا، الاعتماد على العتاد صارخ. فمنفعة NVFP4 تبلغ ذروتها على وحدات GPU من جيل Blackwell، ولا ينبغي للأجيال الأسبق توقع الكفاءة نفسها. وجاذبية الخدمة على GPU واحدة لا تصمد إلا على فرض تأمين Blackwell. وفي بيئة يكون فيها توريد GPU نفسه هو عنق الزجاجة، لا تتحول "GPU واحدة تكفي" فورًا إلى وفر في التكلفة.

ثانيًا، "شبه خالٍ من الخسارة" حكاية عن متوسطات المعايير. ففي مجالات محددة أو سياقات طويلة أو مهام حساسة للدقة كالأرقام والشيفرة، قد يظهر انخفاض جودة طفيف مقابل خط أساس FP8. وينبغي تأكيد قرار تبني NVFP4 بتقييم على عبء العمل الفعلي الذي ستخدمه، لا بأرقام بطاقة النموذج الموجزة.

ثالثًا، رقم الإنتاجية في هذا المقال ليس قياسنا. فالمعايير الخارجية تعتمد بشدة على تكوين العتاد (RTX PRO 6000 مزدوجة، واستخدام MTP من عدمه) وعلى حجم الدفعة وطول السياق، لذا تبقى قيمة عنقودنا الفعلية غير محددة حتى نقيسها مباشرةً. وتبلغ خلاصة هذا المقال فقط "الخدمة على GPU واحدة بصيغة NVFP4 تملك إمكان تحويل اقتصاد الخدمة"؛ أما "كم tok/s في بيئتنا" فمسألة تُقال بعد تحقق منفصل.

## المصادر

- nvidia/Qwen3.6-27B-NVFP4 بطاقة النموذج، Hugging Face (<https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4>)
- Qwen/Qwen3.6-27B، vLLM Recipes (<https://recipes.vllm.ai/Qwen/Qwen3.6-27B>)
- Measuring Qwen3.6-27B NVFP4+MTP on vLLM، loFT LLC (<https://loftllc.dev/en/docs/tech/llm-research/qwen3-6-27b-nvfp4-mtp-vllm-benchmark/>)
