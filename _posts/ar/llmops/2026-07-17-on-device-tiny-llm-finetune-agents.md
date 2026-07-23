---
title: "من 46% إلى 90% داخل الهاتف: ضبط النماذج اللغوية الصغيرة لوكلاء على الجهاز"
excerpt: "عرض Cormac Brick من Google AI Edge حالة رفع فيها ضبطُ نموذج FunctionGemma بحجم 270 مليون معامل الدقةَ في مهمة وكيل محددة من 46% إلى 90%. الجوهر هو تشغيل نموذج صغير مضبوط على مهمة ضيّقة داخل الهاتف نفسه بدل استدعاء نموذج كبير. ننظر في سبب التقاط هذا النهج للكمون والخصوصية والتكلفة معًا، وماذا يعني صعود النماذج المتخصصة على الجهاز لبنية الخدمة ومنصة الوكلاء في ThakiCloud."
tags:
  - on-device
  - fine-tuning
  - functiongemma
  - gemma
  - litert-lm
  - edge-ai
  - small-language-model
  - function-calling
  - serving
  - self-hosting
  - llmops
  - paxis
date: 2026-07-17
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/on-device-tiny-llm-finetune-agents/"
categories:
  - llmops
---

## نظرة عامة

صمدت طويلًا فكرة أن النماذج الصغيرة ليست ذكية. لذلك ألقى الممارسون كل مهمة تقريبًا على النماذج الكبيرة، ودفعوا ثمن ذلك كمونًا وتكلفةً وخطرَ خروج البيانات من الجهاز. لكن إن حصرت المهمة بشكل ضيّق جدًا تتغير الحكاية. تخلَّ عن العمومية واضبط نموذجًا صغيرًا ليُتقن شيئًا واحدًا بالضبط، وضمن ذلك المجال الضيّق لا يبقى سبب لاستدعاء نموذج كبير.

يستهدف عرض «From 46% to 90%: Fine-Tuning Tiny LLMs for On-Device Agents»، الذي قدّمه Cormac Brick، المهندس الرئيسي في Google AI Edge، هذه النقطة بالضبط. رفع ضبطُ نموذج FunctionGemma بحجم 270 مليون معامل على مهمة وكيل محددة الدقةَ من 46% إلى 90%، وهذا هو عنوان العرض وخلاصته معًا. ويُبلَّغ أن هذا النموذج يحقق نحو 2000 رمز في الثانية من إنتاجية المعالجة المسبقة (prefill) على Pixel 7. كل ذلك يحدث داخل الهاتف، بلا استدعاء خادم.

يقرأ هذا المقال ذلك العرض من منظور ThakiCloud التي تُشغّل بنية استدلال متعددة المستأجرين. ننظر في سبب كون نموذج صغير متخصص منطقيًا على الجهاز، وماذا يغيّر الضبط فعلًا، وكيف يبسّط زمن تشغيل مثل LiteRT-LM النشرَ، وما المعنى العملي الذي يحمله هذا الاتجاه لبنية الخدمة ومنصة الوكلاء لدينا. أرقام الدقة والإنتاجية والمدة المذكورة أدناه كلها قيم مُبلَّغ عنها من العرض والتغطية المرتبطة، وليست قيمًا أعاد ThakiCloud إنتاجها.

{% include video id="-TiET_K-E_g" provider="youtube" %}

الفيديو أعلاه هو عرض Cormac Brick الأصلي كاملًا. والتحليل أدناه مبني على ذلك العرض والتغطية العامة.

## ما هي هذه التقنية

FunctionGemma نموذج بحجم 270 مليون معامل من عائلة Gemma متخصص في استدعاء الدوال (function calling). استدعاء الدوال هو السلوك الجوهري لوكيل على الجهاز، لأنه يحوّل طلب المستخدم بلغة طبيعية إلى استدعاء أداة مُهيكل يستطيع التطبيق تنفيذه. تحويل «اضبط منبّهًا للتاسعة صباح الغد» إلى استدعاء مثل `setAlarm(time="09:00", date="tomorrow")` مثال على ذلك. وما دام هذا التحويل دقيقًا، فلا حاجة لاستدعاء نموذج عام بمليارات المعاملات.

المشكلة أن نموذجًا صغيرًا منشورًا بشكل عام تكون دقته منخفضة على مخطط أدوات تطبيق محدد. الـ46% التي يذكرها العرض هي تلك النقطة بالضبط. وهنا يدخل الضبط. اضبط النموذج بشكل ضيّق على مخطط الدوال الفعلي وأنماط الطلبات في التطبيق المستهدف، فيرتفع النموذج نفسه بحجم 270 مليون إلى 90%.

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
<div class="d3-arch" data-arch-root id="icetinyllmfinetuneagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 616, "height": 806, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 268, "y": 24, "w": 198, "h": 62, "title": ["طلب المستخدم بلغة طبيعية", "منبّه للتاسعة غدًا"]}, {"id": "B", "x": 300, "y": 164, "w": 135, "h": 46, "title": "وكيل على الجهاز"}, {"id": "C", "x": 280, "y": 288, "w": 174, "h": 52, "title": "FunctionGemma 270M"}, {"id": "D", "x": 400, "y": 432, "w": 184, "h": 62, "title": ["دقة نحو 46%", "مخطط التطبيق غير محاذى"]}, {"id": "E", "x": 140, "y": 432, "w": 205, "h": 62, "title": ["دقة نحو 90%", "محاذى لمخطط الدوال الفعلي"]}, {"id": "F", "x": 270, "y": 572, "w": 191, "h": 62, "title": ["استدعاء دالة مُهيكل", "setAlarm 09:00 tomorrow"]}, {"id": "G", "x": 281, "y": 712, "w": 170, "h": 62, "title": ["التطبيق ينفّذ مباشرة", "بلا استدعاء خادم"]}, {"id": "H", "x": 24, "y": 572, "w": 191, "h": 62, "title": ["زمن تشغيل LiteRT-LM", "‏Pixel 7 نحو 2000 tok/s"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [367, 86, 367, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [367, 210, 367, 288]}, {"src": "C", "dst": "D", "kind": "data", "label": "نشر عام", "curve": [[412, 340], [492, 386], [492, 386], [492, 432]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "ضبط خاص بالمهمة", "curve": [[322, 340], [243, 386], [243, 386], [243, 432]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "curve": [[297, 494], [366, 533], [366, 533], [366, 572]]}, {"src": "F", "dst": "G", "kind": "data", "line": [366, 634, 366, 712]}, {"src": "E", "dst": "H", "kind": "data", "curve": [[188, 494], [120, 533], [120, 533], [120, 572]]}]});
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
      const container = document.getElementById('icetinyllmfinetuneagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'icetinyllmfinetuneagents-1';
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

## من 46% إلى 90%: ماذا يفعل الضبط

فهم طبيعة هذه الفجوة مهم. يستدلّ النموذج الكبير عبر حتى مخطط غير مألوف بفضل معرفة عامة هائلة. أما النموذج الصغير فيفتقر إلى ذلك الفائض. لكن ركّزه على توزيع ضيّق، فيصبح ضمن ذلك التوزيع دقيقًا بقدر نموذج كبير تقريبًا. الضبط أقرب إلى توجيه السعة التي يملكها النموذج أصلًا نحو المهمة المستهدفة منه إلى حقن ذكاء جديد فيه.

وفقًا للعرض، ينتهي هذا الضبط في زمن قصير على نحو لافت. تُبلّغ التغطية المرتبطة بأن التدريب يكتمل في نحو 21 دقيقة. وبفضل الحجم الصغير البالغ 270 مليون، يكون التدريب نفسه خفيفًا وقابلًا للإدارة حتى على عتاد استهلاكي. ويحمل هذا دلالات مباشرة لممارسة علم البيانات. فهو يعني أن نموذج تشغيل يكون فيه لكل تطبيق ولكل مجموعة أدوات نموذجه الصغير المتخصص، ويُدرَّب كلٌّ منها بإيجاز، هو نموذج واقعي. فبدل تغطية كل تطبيق بنموذج عام واحد ضخم، تحتفظ بعدة نماذج متخصصة مُقسَّمة بدقة حسب المهمة.

تلامس هذه الفكرة أيضًا مبدأً حافظنا عليه في عملنا الدُّفعي على المحتوى. حلٌّ متخصص يملأ هيكلًا ضيّقًا مُتحقَّقًا منه يتفوق على حلٍّ عام عالي درجة الحرية في متوسط الجودة. وضبط نموذج صغير يطبّق ذلك المبدأ على مستوى النموذج.

## ماذا يمنحك التشغيل على الجهاز: الكمون والخصوصية والعمل دون اتصال والتكلفة

يشدّد العرض على التشغيل على الجهاز لأربعة أسباب.

ينخفض الكمون. لأن الطلب لا يقطع رحلة ذهاب وإياب عبر الشبكة، ينتهي تحويل استدعاء الدالة فورًا داخل الهاتف. ولواجهة يجب أن يتفاعل فيها الوكيل مع أفعال المستخدم في الزمن الحقيقي، يكون هذا الفارق حاسمًا.

تُصان الخصوصية. لا تغادر طلبات المستخدم وبياناته الشخصية الجهاز أبدًا. وفي سياقات حساسة كالصحة والمال والمراسلة، تصبح حقيقة عدم ذهاب البيانات إلى خادم بحد ذاتها متطلبًا للمنتج.

يعمل دون اتصال. يؤدي الوكيل وظيفته حتى بلا شبكة. النموذج السحابي عاجز حين ينقطع الاتصال؛ أما النموذج على الجهاز فلا.

تختفي التكلفة. لأن الاستدلال يجري على الجهاز، لا توجد محاسبة API لكل رمز. وكلما زاد استخدام التطبيق، كبُر هذا التوفير.

## ‏LiteRT-LM وحزمة النشر

تدريب نموذج صغير ونشره على أجهزة لا تُحصى مشكلتان منفصلتان. يعرض العرض LiteRT-LM كزمن تشغيل للنشر. LiteRT-LM زمن تشغيل يتيح لك وضع نماذج مثل Gemma 4 على طيف واسع من العتاد من المحمول إلى الأنظمة المدمجة. وبدمجه مع AI Core، كما يشرح العرض، يمكنك تشغيل مهارات وكيل على الجهاز.

الجوهر أن ثمة مسارًا لنشر نموذج واحد باتساق عبر عتاد متنوع. فدون عناء إعادة تركيب نموذج متخصص مُدرَّب على مُسرِّع كل جهاز، يمتص زمن التشغيل ذلك التغاير. وهذا هو الشرط العملي الذي يرفع الوكلاء على الجهاز من مستوى التجربة إلى مستوى المنتج.

## ماذا يعني هذا لمنتجات ThakiCloud

قد يبدو اتجاه النماذج المتخصصة على الجهاز إشارةً معاكسة لنا نحن مُشغِّلي الخدمة السحابية، لكنه في الواقع يحمل دلالات مباشرة لكلا المنتجين.

**عدسة ai-platform.** يزيح صعود النماذج الصغيرة المتخصصة تركيز بنية الخدمة. توفّر منصة ai-platform من ThakiCloud جدولة GPU قائمة على K8s وKueue، وعزلًا متعدد المستأجرين، وخدمة داخل المؤسسة. السؤال الذي يطرحه الضبط على الجهاز هنا ليس «إذا انتقل كل شيء إلى الجهاز، فهل يصبح الخادم غير ضروري؟» بل العكس. فلتدريب نموذج متخصص منفصل بإيجاز لكل تطبيق، تحتاج بنية تحتية تشغّل تلك المهام التدريبية بتكلفة منخفضة وعلى نطاق واسع. إن عبء عمل يكرّر ضبطًا بحجم 270 مليون يستغرق 21 دقيقة عبر مئات مجموعات الأدوات هو بالضبط ما تستهدفه بنية تصفّ الـGPU عبر Kueue وتعزل حسب المستأجر. التدريب على الخادم والاستدلال على الجهاز هو الخلاصة الطبيعية.

في الوقت نفسه، لا تكتفي كل مؤسسة بالاستدلال على الجهاز وحده. فحين يلزم سياق أكبر أو استدلال أعقد، يتدخّل نموذج خادم. وللمؤسسات المتحفظة على إرسال بيانات المصدر إلى سحابة خارجية، تصبح الخدمة داخل المؤسسة والاستضافة الذاتية مهمة. والتنافسية على تكلفة خدمة منخفضة هي مفتاح الاحتفاظ بتلك المؤسسات.

**عدسة Paxis.** جوهر FunctionGemma هو تحويل اللغة الطبيعية إلى استدعاء أداة مُهيكل. وهذا نسخة مصغّرة مما تفعله Paxis. إن Paxis هي السحابة الأصيلة للوكلاء من ThakiCloud، تختار من أكثر من 960 مهارة عبر BM25، وتشغّلها في صناديق رملية معزولة، وتمرّر كل فعل عبر بوابات السياسة وسجلات التدقيق. إذا عالج وكيل على الجهاز استدعاءات الدوال لمجموعة أدوات ضيّقة على الهاتف، فإن Paxis تعالج توجيه الأدوات عبر فضاء مهارات أوسع بكثير في السحابة. الطبقتان لا تتنافسان؛ بل تتكاملان. تنشأ بنية طبقية يتولى فيها الجهاز تفسير النية المحلي الخفيف، وتتولى Paxis العمل الذي يتطلب تنسيقًا معقدًا متعدد الوكلاء وتدقيقًا.

## القيود والاعتراضات

لهذا النهج حدود واضحة أيضًا.

أولًا، ثمن التخصص هو العمومية. ذلك النموذج الذي رفع 46% إلى 90% قويٌّ فقط في المهمة الضيّقة التي دُرِّب عليها. غيّر مخطط الأدوات أو انتقل إلى مجال تطبيق جديد وعليك الضبط من جديد. وفي بيئة تتغير فيها التطبيقات والأدوات كثيرًا، يكبُر عبء الصيانة تبعًا لذلك.

ثانيًا، هل تكفي الـ90% يعتمد على المهمة. إن الخطأ في استدعاء دالة يعني تنفيذ فعل خاطئ، ففي المجالات التي تكون فيها كلفة الفشل عالية قد يكون خطأ بنسبة 10% قاتلًا. وفي تلك الحالة تحتاج بنية مزدوجة يتحقق فيها نموذج خادم من نتيجة الجهاز.

ثالثًا، رقم الـ21 دقيقة للتدريب يعتمد بشدة على الحجم والعتاد. فالتكلفة التشغيلية الحقيقية بما فيها إعداد البيانات ومحاذاة المخطط والتقييم لا يمكن الحكم عليها بزمن التدريب وحده. وينبغي أخذ أرقام العرض المبهرة كقيم في ظروف مُرتَّبة جيدًا.

رابعًا، يواجه النشر على الجهاز تجزئة الأجهزة. فحتى لو امتص LiteRT-LM التغاير، يبقى الأداء الفعلي وقيود الذاكرة لكل جهاز يطلبان تحققًا فرديًا.

مع ذلك، اتجاه تشغيل نموذج صغير متخصص على الجهاز مقنع. إنه النقطة التي تتحقق فيها الفوائد الأربع، الكمون والخصوصية والعمل دون اتصال والتكلفة، في آنٍ واحد. وبالنسبة لنا، هذا الاتجاه ليس إشارة إلى أن الخادم يصبح غير ضروري، بل إشارة تجعلنا نعيد رسم أين ينبغي أن يقع الفصل بين التدريب والاستدلال.

## المصادر

- [From 46% to 90%: Fine-Tuning Tiny LLMs for On-Device Agents - Cormac Brick, Google (YouTube)](https://www.youtube.com/watch?v=-TiET_K-E_g)
- [Google's Cormac Brick on Tiny LLMs for On-Device Agents - StartupHub.ai](https://www.startuphub.ai/ai-news/ai-research/2026/google-s-cormac-brick-on-tiny-llms-for-on-device-agents)
- [Fine-tune FunctionGemma 270M for Mobile Actions - Google AI for Developers](https://ai.google.dev/gemma/docs/mobile-actions)
