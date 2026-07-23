---
title: "كيف تتعلم البنية الداخلية لنماذج LLM بشكل منهجي: من التوكنة إلى تحسين الاستدلال"
excerpt: "إذا كنت تشغّل LLM في الإنتاج ولا تستطيع أن تشرح لماذا يستهلك KV Cache هذا القدر من الذاكرة، أو ما الذي يوفره GQA بالضبط، فإن التحسين يصبح مجرد تخمين. مستودع amitshekhariitbhu/llm-internals هو مسار تعلّم يربط التوكنة، ومعادلة الانتباه، وكتلة الترانسفورمر، وKV Cache، وMoE، وGQA في تسلسل واحد متماسك. نستعرض هنا لماذا يشكل كل موضوع منها سلاحاً مباشراً لمهندس البنية التحتية."
seo_title: "خارطة طريق لتعلّم البنية الداخلية لـ LLM: التوكنة، الانتباه، KV Cache، MoE، GQA | Thaki Cloud"
seo_description: "تحليل لمستودع التعلّم llm-internals يغطي التوكنة (BPE)، وQuery/Key/Value في الانتباه، وكتلة الترانسفورمر، وKV Cache، وMoE، وGQA من منظور مهندس البنية التحتية، مع ربطها بتحسين خدمة النماذج عبر vLLM وKueue."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - llm-internals
  - transformer
  - kv-cache
  - mixture-of-experts
  - gqa
  - llm-inference
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "microchip"
published: true
canonical_url: "https://thakicloud.com/tech-blog/ar/technique/llm-internals-learning-path/"
categories:
  - llmops
---

## نظرة عامة

عندما تشغّل خدمة LLM لفترة طويلة، تصل إلى نقطة غريبة. تنشر vLLM، وتراقب استخدام GPU، وتضبط حجم الدفعات (batch size)، لكنك في لحظة ما لا تستطيع أن تشرح بجملة واحدة "لماذا يستهلك هذا الطلب هذا القدر من KV Cache"، أو "ما الذي يقلّصه GQA بالضبط ليوفّر عرض النطاق الترددي للذاكرة". تعرف كيف تستخدم الأدوات، لكن المبادئ التي تقوم عليها تبقى ضبابية. هذه الفجوة تجعل التحسين يعتمد على الحدس، وتمنعك من استنتاج السبب الجذري عندما يحدث عطل.

المصدر التعليمي [amitshekhariitbhu/llm-internals](https://github.com/amitshekhariitbhu/llm-internals) يستهدف هذه المشكلة مباشرة. إنه مستودع تعلّم متدرج يجمع مقالات ومقاطع فيديو بترتيب يبدأ من التوكنة ويمر بالانتباه وبنية الترانسفورمر وKV Cache وصولاً إلى تحسين الاستدلال. المؤلف الأصلي هو Amit Shekhar، وقد رتّب المواضيع بحيث تبني نموذجاً ذهنياً واحداً متماسكاً بدلاً من مجموعة دروس متفرقة وعابرة.

تشغّل ThakiCloud منصة **ai-platform** لتقديم النماذج لعملاء متنوعين فوق Kubernetes. معظم العوامل التي تحدد تكلفة الخدمة وزمن الاستجابة تنبع من هذه البنية الداخلية التي يتناولها هذا المستودع. لذلك، هذا المقال ليس مجرد تعريف بمصدر تعليمي، بل محاولة لتوضيح لماذا يشكّل كل موضوع منها سلاحاً مباشراً لمهندس البنية التحتية.

## ما هو هذا المصدر

llm-internals ليس إطار عمل لتشغيل الكود، بل هو **مسار تعلّم (learning path)**. يتتبع خط الأنابيب الذي يمر به LLM من استقبال المدخل حتى إنتاج التوكن التالي، ويعرض المفاهيم اللازمة في كل مرحلة بترتيب مدعوم بمصادر خارجية. جوهر المستودع هو تصميم المنهج نفسه: "ما الذي يجب فهمه، وبأي ترتيب، حتى تكتمل الصورة الكاملة".

المواضيع الرئيسية التي يغطيها المستودع تتبع التدفق التالي.

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
<div class="d3-arch" data-arch-root id="llminternalslearningpath-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 536, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 206, "y": 24, "w": 120, "h": 46, "title": "النص المدخل"}, {"id": "B", "x": 174, "y": 148, "w": 184, "h": 62, "title": ["التوكنة", "BPE Byte Pair Encoding"]}, {"id": "C", "x": 177, "y": 288, "w": 177, "h": 62, "title": ["التضمين", "تحويل التوكن إلى متجه"]}, {"id": "D", "x": 198, "y": 428, "w": 135, "h": 62, "title": ["الانتباه", "Query Key Value"]}, {"id": "E", "x": 253, "y": 568, "w": 205, "h": 62, "title": ["كتلة الترانسفورمر", "الانتباه + FFN بشكل متكرر"]}, {"id": "F", "x": 383, "y": 708, "w": 121, "h": 62, "title": ["KV Cache", "تسريع التوليد"]}, {"id": "G", "x": 207, "y": 708, "w": 121, "h": 62, "title": ["MoE", "توجيه الخبراء"]}, {"id": "H", "x": 24, "y": 708, "w": 128, "h": 62, "title": ["GQA", "مشاركة رؤوس KV"]}, {"id": "I", "x": 200, "y": 848, "w": 135, "h": 62, "title": ["تحسين الاستدلال", "كفاءة الخدمة"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [266, 70, 266, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [266, 210, 266, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [266, 350, 266, 428]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[305, 490], [356, 529], [356, 529], [356, 568]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[394, 630], [444, 669], [444, 669], [444, 708]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[317, 630], [268, 669], [268, 669], [268, 708]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[198, 486], [88, 529], [88, 669], [88, 708]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[444, 770], [444, 809], [444, 809], [335, 852]]}, {"src": "G", "dst": "I", "kind": "data", "line": [268, 770, 268, 848]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[88, 770], [88, 809], [88, 809], [200, 853]]}]});
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
      const container = document.getElementById('llminternalslearningpath-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'llminternalslearningpath-1';
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

أهمية هذا الترتيب تكمن في أن المواضيع اللاحقة لا يمكن فهمها دون المواضيع السابقة. فـ KV Cache لا يكتسب معناه إلا بعد فهم ما هما Key وValue في الانتباه، وGQA لا يظهر معناه إلا بعد فهم بنية الرؤوس في الانتباه متعدد الرؤوس، أي "ما الذي يتم مشاركته بالضبط". قيمة هذا المستودع لا تكمن في عمق كل مصدر على حدة، بل في هذا الترتيب الذي لا يكسر سلسلة الاعتماد بين المفاهيم.

## استعراض المواضيع الأساسية

### التوكنة: نقطة البداية لكل شيء

لا يتعامل LLM مباشرة مع الحروف أو الكلمات، بل يعالج النص على شكل توكنات. تستخدم معظم النماذج الحديثة عائلة BPE (Byte Pair Encoding)، وهي طريقة تدمج بشكل متكرر أزواج البايتات الأكثر تكرراً معاً لبناء المفردات. قد تبدو التوكنة أمراً بسيطاً، لكنها من منظور الخدمة عامل تكلفة مباشر. نفس الجملة يمكن أن يختلف عدد توكناتها اختلافاً كبيراً باختلاف اللغة والمُرمِّز (tokenizer)، وعدد التوكنات ينعكس مباشرة على استهلاك KV Cache وحجم العمليات الحسابية. ظاهرة استهلاك اللغات غير الإنجليزية مثل الكورية والعربية عدداً أكبر من التوكنات مقارنة بالإنجليزية هي نقطة يجب مراعاتها بالضرورة عند احتساب تكلفة الخدمة.

### الانتباه: Query وKey وValue

قلب الترانسفورمر هو الانتباه الذاتي (self-attention). يُسقَط كل توكن إلى ثلاثة متجهات. Query يمثل "ما الذي أبحث عنه"، وKey يمثل "ما الذي أقدّمه"، وValue يمثل "المحتوى الفعلي الذي سيُنقل". يُحسب مقياس الانتباه عبر الضرب الداخلي بين Query وKey، ثم يمرّ عبر عملية القياس (scaling) والدالة softmax لإنتاج مجموع مرجّح لـ Value.

```
Attention(Q, K, V) = softmax( (Q · Kᵀ) / √d_k ) · V
```

هذه المعادلة بسيطة في ظاهرها، لكن حقيقة أن عملية الانتباه تنمو بمعدل O(n²) بالنسبة لطول التسلسل n هي ما ينتج عنه كل عمليات التحسين اللاحقة. من هنا تبدأ الإجابة عن سبب ارتفاع تكلفة السياقات الطويلة، وسبب حساسية بنية الخدمة لطول السياق.

### كتلة الترانسفورمر وKV Cache

الترانسفورمر هو بنية من طبقات متعددة، تجمع كل طبقة منها الانتباه مع شبكة تغذية أمامية (FFN). في التوليد ذاتي الانحدار (autoregressive)، يُنتج التوكن واحداً تلو الآخر، وإعادة حساب Key وValue لكل التوكنات السابقة في كل خطوة يمثل هدراً كبيراً. **KV Cache** يخزّن قيم Key وValue التي حُسبت سابقاً ويعيد استخدامها، مما يرفع سرعة التوليد.

المشكلة هي أن هذه الذاكرة المؤقتة تستهلك ذاكرة كبيرة. يتناسب حجم الذاكرة المؤقتة تقريباً مع `2 × عدد الطبقات × عدد رؤوس KV × أبعاد الرأس × طول التسلسل × حجم الدفعة`. السياقات الطويلة وكثرة الطلبات المتزامنة تضخّم هذه القيمة بشكل انفجاري. هذا هو بالضبط الضغط البنيوي الذي يجعل تقنية PagedAttention في vLLM تدير KV Cache على شكل صفحات لتقليل التجزئة.

### MoE وGQA: تغييرات بنيوية لأجل الكفاءة

**مزيج الخبراء (Mixture of Experts، MoE)** يقسّم شبكة FFN إلى عدة "خبراء"، ويقوم موجّه (router) بتفعيل جزء فقط من الخبراء لكل توكن. إجمالي عدد المعاملات كبير، لكن حجم العمليات الحسابية الفعلي لكل توكن يصبح صغيراً. في المقابل، يفرض هذا على الخدمة تحديات جديدة: التوازي بين الخبراء، وعدم توازن التوجيه، وتوزيع الذاكرة.

**الانتباه المُجمَّع الاستعلام (Grouped-Query Attention، GQA)** هو حل وسط بين الانتباه متعدد الرؤوس (MHA) والانتباه متعدد الاستعلامات (MQA). في MHA، يملك كل رأس Key وValue خاصين به، بينما في MQA تشترك جميع الرؤوس في Key وValue واحد. أما GQA فيجمّع الرؤوس في عدد قليل من المجموعات، وتشترك كل مجموعة في KV خاص بها. والنتيجة أن **حجم KV Cache وعرض النطاق الترددي للذاكرة ينخفضان** بينما يبقى فقدان الجودة عند حدّه الأدنى. فهم GQA يوضّح لماذا تعتمد النماذج مفتوحة الأوزان الحديثة هذه البنية، ولماذا تختلف موازنة الذاكرة عند الخدمة تبعاً لذلك.

## لماذا تهم هذه المعرفة مهندس البنية التحتية

المواضيع أعلاه ليست موضع فضول أكاديمي، بل هي السبب المباشر لتكلفة الخدمة. فهم معادلة حجم KV Cache يتيح توقّع كيف يصطدم عدد الطلبات المتزامنة وطول السياق بذاكرة GPU. وفهم GQA يفسّر لماذا يستطيع بعض النماذج معالجة عدد أكبر من الطلبات على نفس GPU. وفهم MoE يسمح بالاستعداد لسبب تعقيد الجدولة الناتج عن التوزيع المتوازي للخبراء.

على النقيض، غياب هذه المعرفة يعني أنك ستكتفي، عند حدوث عطل، بملاحظة عرض "نفدت الذاكرة" فقط، وتكرر الاستجابة المكلفة المتمثلة في تقليل حجم الدفعة عشوائياً أو إضافة المزيد من وحدات GPU. المهندس الذي يعرف البنية الداخلية يملك رافعات أدق: ترقيم KV Cache، وسقف طول السياق، والتكميم (quantization)، واختيار نماذج تعتمد GQA.

## تطبيقات على منتجات ThakiCloud

تقدّم منصة **ai-platform** من ThakiCloud استدلالاً قائماً على vLLM لعدة مستأجرين فوق Kubernetes وجدولة GPU عبر Kueue. تنعكس البنية الداخلية التي استعرضناها في هذا المقال مباشرة على رافعات التشغيل الفعلية.

- **KV Cache**: استناداً إلى PagedAttention ومعادلة حجم KV Cache، نحدّد سقف طول السياق وميزانية التزامن لكل مستأجر. توقّع استهلاك الذاكرة المؤقتة يتيح رفع الإنتاجية دون الإفراط في حجز ذاكرة GPU.
- **GQA والتكميم**: من أجل استيعاب عدد أكبر من الطلبات على نفس العتاد، نُعطي الأولوية في المراجعة للنماذج مفتوحة الأوزان التي تعتمد GQA، وندمج ذلك مع التكميم بهدف تحقيق تكلفة خدمة منخفضة في البيئات المحلية (on-premise) والسيادية.
- **خدمة MoE**: نراعي مسبقاً أن نماذج MoE التي تحتاج توازياً بين الخبراء تتطلب معاملة خاصة في تصميم طوابير Kueue وتوزيع العُقد.

من منظور الوكلاء الذكيين (agents)، فإن **Paxis**، السحابة الأصيلة للوكلاء (Agent-Native Cloud) من ThakiCloud، توفّر بيئة مواتية لتراكم هذه المعرفة الداخلية كأصل جماعي للفريق. بما أن Paxis تتعامل مع المهارات (skills) كموارد من الدرجة الأولى، يمكن تحويل قرارات متكررة مثل "حساب ميزانية KV Cache" إلى مهارة موثّقة يُعاد استخدامها داخل بيئة معزولة (sandbox) وتُتبَّع عبر سجل تدقيق. هذا يوفّر قناة لتحويل خبرة الخدمة، التي غالباً ما تظل معرفة ضمنية لدى مهندس بعينه، إلى معرفة إجرائية على مستوى المؤسسة.

## القيود ووجهات النظر المضادة

أكبر نقطة ضعف في هذا المصدر هي القدر المشترك بين جميع المستودعات المُنسَّقة (curation repos). بما أنه يعتمد على ربط مدونات ومقاطع فيديو خارجية، فإن الروابط قد تصبح قديمة أو تختفي، كما توجد فوارق في المستوى والعمق بين المصادر المختلفة. ولا يوجد ضمان بأن التغيرات المعمارية الأحدث (مثل أشكال جديدة من الانتباه) ستنعكس فوراً في المستودع.

كذلك، لا تزال هناك فجوة بين فهم المفهوم والتشغيل الفعلي. حفظ معادلة حجم KV Cache عن ظهر قلب لا يعني بالضرورة الحصول فوراً على الإنتاجية الفعلية على GPU معين. القياس الفعلي، وتحليل الأداء (profiling)، والضبط الخاص بكل حمل عمل تتطلب خبرة تشغيلية منفصلة. هذا المسار التعليمي ذو قيمة كبيرة كنقطة انطلاق لبناء نموذج ذهني دقيق، لكنه ليس بحد ذاته خط النهاية لتحسين الخدمة. لا بد أن تتبعه بالضرورة مرحلة التحقق فوق حركة مرور فعلية بعد استيعاب المبادئ.

## المصادر

- [amitshekhariitbhu/llm-internals (GitHub)](https://github.com/amitshekhariitbhu/llm-internals)
- التغريدة الأصلية المُوصية: Dan Kornas, "Stop learning LLM internals from random one-off tutorials"
