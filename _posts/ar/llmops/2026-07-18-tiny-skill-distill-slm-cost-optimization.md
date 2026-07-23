---
title: "فاتورة الذكاء الاصطناعي تتسرّب عبر العمل المتكرر — كيف تخفضها هيكليًا بنماذج متخصّصة محلية"
excerpt: "معظم تكلفة وكيل الذكاء الاصطناعي ليست في الحكم الذكي، بل في قرارات بسيطة متكرّرة آلاف المرات يوميًا. افصل هذه المهام إلى نماذج صغيرة متخصّصة تعمل على بنيتك الخاصة، فتنخفض التكلفة لكل استدعاء بشكل حاد ولا تغادر بياناتك أبدًا. قاست ThakiCloud هذا النمط ونشرته بالكامل."
date: 2026-07-18
tags:
  - AICostReduction
  - OnPremises
  - SLM
  - FineTuning
  - DataSovereignty
  - LLMOps
  - EnterpriseAI
  - Platform
author_profile: true
toc: true
toc_label: دراسة التكلفة
published: true
categories:
  - llmops
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/tiny-skill-distill-slm-cost-optimization/"
---

## الخلاصة أولًا

جزء كبير مما تنفقه على الذكاء الاصطناعي لا يذهب لأن النموذج ذكي. بل يذهب إلى **القرار نفسه المكرَّر آلاف أو عشرات آلاف المرات يوميًا**: "هل هذا الطلب آمن؟"، "إلى أي فئة ينتمي هذا المستند؟"، "هل نبرة هذه الجملة مناسبة؟" حين تستدعي نموذجًا خارجيًا من الطبقة العليا لهذا العمل المتكرر في كل مرة، تتضخّم التكلفة مع الحجم وتغادر البيانات الحسّاسة جدرانك عند كل استدعاء.

اقتراح ThakiCloud بسيط: **افصل هذا العمل المتكرر وحده إلى نماذج صغيرة متخصّصة تعمل على بنيتك الخاصة (محليًا)**، واحتفظ بالنموذج الأعلى المكلف للمهام القليلة التي تتطلب حكمًا فعليًا. تحقّقنا أن ذلك يعمل فعلًا — بالقياس لا بالتنبؤ — ونشرنا كل شيء. يصوغ هذا المقال قصة التكلفة تلك بلغة صنّاع القرار.

## لماذا يهم هذا الآن

بمجرد إدخال الذكاء الاصطناعي التوليدي إلى التشغيل الفعلي، تنمو ثلاثة أمور معًا. **التكلفة** ترتفع خطيًا مع حجم الاستدعاءات. **تعرّض البيانات** يحدث في كل استدعاء لواجهة خارجية. و**الارتهان** لمزوّد نموذج خارجي بعينه يزداد عمقًا. الثلاثة مخاطر يريد التنفيذيون السيطرة عليها.

وهنا الجوهر. عند تحليل ما يفعله الذكاء الاصطناعي لديك فعلًا، معظمه **حُكم ضيّق ومتكرر**، والحكم الإبداعي الحقيقي هو الأقلية. ومع ذلك يُسنَد كلاهما اليوم إلى النموذج الأعلى نفسه دون تمييز — كإسناد فرز مستندات بسيط إلى أعلى خبير أجرًا لديك.

## نهجنا: العمل المتكرر إلى نماذج متخصّصة، محليًا

للطريقة ثلاث خطوات. أولًا، صمّم سير العمل بنموذج كبير. ثانيًا، ثبّت ما يمكن اختزاله إلى قواعد كشيفرة. ثالثًا، خذ فقط **القرارات المتكررة الضيقة التي تحتاج فعلًا إلى نموذج لغوي ودرّب نموذجًا صغيرًا متخصّصًا (أقل من مليار معامل، 4 بت)** لها. عندها يعمل ذلك العمل على وحدة معالجة رسومية محلية شائعة واحدة، ويُنفَق النموذج الأعلى على ما يهم فعلًا فقط.

تحوّل منصّة ThakiCloud هذا السير بالضبط إلى منتج. فهي **تُدرّب النموذج الصغير المتخصّص كخدمة مُدارة** (دون أن تضطر للتعامل مع بنية وحدات المعالجة الرسومية) و**تخدّمه على عتادك المحلي الخاص**. التجربة في هذا المقال دليل على أن النمط يعمل؛ والمنصّة هي ما يجعله قابلًا للتكرار والتشغيل.

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
<div class="d3-arch" data-arch-root id="stillslmcostoptimization-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 719, "height": 948, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 421, "y": 24, "w": 266, "h": 410, "label": "Build pipeline", "lx": 433, "ly": 42}], "nodes": [{"id": "A", "x": 132, "y": 203, "w": 170, "h": 46, "title": "AI workflow requests"}, {"id": "B", "x": 133, "y": 327, "w": 167, "h": 68, "title": ["Repetitive narrow", "judgment?"]}, {"id": "C", "x": 367, "y": 526, "w": 212, "h": 78, "title": ["Small specialized SLM", "under 1B params, 4-bit", "~5MB LoRA adapter per task"]}, {"id": "D", "x": 24, "y": 534, "w": 191, "h": 62, "title": ["Top-tier external model", "reserved for the few"]}, {"id": "E", "x": 381, "y": 682, "w": 184, "h": 78, "title": ["On-prem GPU", "data never leaves your", "walls"]}, {"id": "F", "x": 367, "y": 838, "w": 212, "h": 78, "title": ["~3.6x cheaper per 1k calls", "tone accuracy 38.6% to", "99.1%"]}, {"id": "G", "x": 35, "y": 690, "w": 170, "h": 62, "title": ["Higher per-call cost", "used sparingly"]}, {"id": "H", "x": 458, "y": 63, "w": 191, "h": 62, "title": ["1. Design flow with top", "model"]}, {"id": "I", "x": 458, "y": 203, "w": 191, "h": 46, "title": "2. Freeze rules as code"}, {"id": "J", "x": 462, "y": 330, "w": 184, "h": 62, "title": ["3. Fine-tune small SLM", "for narrow judgments"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [217, 249, 217, 327]}, {"src": "B", "dst": "C", "kind": "data", "label": "Yes: safety check, doc class, tone check", "curve": [[276, 395], [345, 434], [345, 480], [414, 526]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "No: genuine judgment", "curve": [[171, 395], [120, 434], [120, 480], [120, 534]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [473, 604, 473, 682]}, {"src": "E", "dst": "F", "kind": "data", "line": [473, 760, 473, 838]}, {"src": "D", "dst": "G", "kind": "data", "line": [120, 596, 120, 690]}, {"src": "H", "dst": "I", "kind": "data", "line": [554, 125, 554, 203]}, {"src": "I", "dst": "J", "kind": "data", "line": [554, 249, 554, 330]}, {"src": "J", "dst": "C", "kind": "event", "label": "provisions", "curve": [[554, 392], [554, 434], [554, 480], [510, 526]], "off": "50%"}]});
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
      const container = document.getElementById('stillslmcostoptimization-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'stillslmcostoptimization-1';
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
*وجّه القرارات المتكررة الضيقة إلى نموذج صغير متخصّص محلي لخفض التكلفة لكل استدعاء وإبقاء البيانات داخليًا، واحتفظ بالنموذج الأعلى للمهام القليلة التي تحتاج حكمًا فعليًا. كل نموذج متخصّص مُرفق بنحو 5 ميغابايت لكل مهمة، فتتبدّل عدة مهام على نموذج أساس واحد مشترك.*

## ما الذي قِسناه

تجنّبًا للمبالغة، قِسنا ونشرنا كل رقم. البيئة بطاقة واحدة، دون أي استدعاء لواجهة خارجية في أي مرحلة من التدريب أو الاستدلال — تبقى السلسلة كاملة داخل بنيتك الخاصة. هكذا تبدو سيادة البيانات عمليًا.

**التكلفة.** محليًا، عالج النموذج الصغير المتخصّص 1000 استدعاء بتكلفة أقل بنحو **3.6 مرة** من واجهة خارجية من الطبقة العليا. هذا الرقم بتيار مفرد؛ والمعالجة على دفعات كما في التشغيل الحقيقي توسّع الفارق أكثر.

**الجودة.** في القرارات المتكررة الضيقة قفز النموذج الصغير. ارتفع تصنيف النبرة الكورية من 38.6% قبل التدريب إلى 99.1% بعده؛ وانتقل تصنيف الأخبار من شبه العشوائي إلى أكثر من 80%. وعند إعادة الفحص على جمل حقيقية لم تُرَ في التدريب، بقي متوافقًا مع الإجابة الصحيحة بنحو 88% في قرارات الأمان و89% في التصنيف.

**الاقتصاد.** يُنتَج كل نموذج متخصّص كمُرفق صغير بنحو 5 ميغابايت لكل مهمة. تكاد جودته تطابق إعادة تدريب النموذج بالكامل من الصفر (99.1% مقابل 96.9%) بنحو جزء من 300 من الحجم، ويمكنك تبديل عدة مهام على نموذج أساس واحد مشترك. بل تولّى نموذج صغير واحد أربع مهام متكررة في آن. تشغيليًا، يُترجَم هذا مباشرة إلى "عمل أكثر بعتاد أقل".

## الحدود، بصدق

نقطة نذكرها بوضوح: في مهمة عامة كان النموذج الأعلى يتقنها أصلًا، أدى التدريب المتخصّص المتسرّع إلى إضعافها. بمعنى آخر، هذا النهج **ليس شيئًا تطبّقه على أي مهمة، بل على مهام متكررة وضيقة تُنتقى بعناية**. ومعرفة أين تطبّقه وأين لا، هي بالضبط حيث تثبت المنصّة والخبرة قيمتهما. ننشر النتائج الجيدة والسيئة معًا.

## لصانع القرار، باختصار

أولًا، جزء كبير من تكلفة تشغيل الذكاء الاصطناعي لديك يتسرّب إلى العمل المتكرر، وهذا الجزء يمكن خفضه هيكليًا. ثانيًا، طريقة الخفض هي فصل ذلك العمل المتكرر إلى نماذج صغيرة متخصّصة تعمل محليًا، ما يؤمّن توفير التكلفة وسيادة البيانات معًا. ثالثًا، تقدّم منصّة ThakiCloud هذا كخدمة مُدارة، فتتبنّاه دون أن تتحمّل شخصيًا تعقيد بنية وحدات المعالجة الرسومية وتدريب النماذج.

الشيفرة الكاملة للتجربة والنتائج المقيسة متاحة وقابلة لإعادة الإنتاج: [github.com/sylvanus4/tiny-skill-distill](https://github.com/sylvanus4/tiny-skill-distill). ويسعدنا أن نقيّم معك أي أحمال عمل الذكاء الاصطناعي لديك يمكن نقلها إلى نماذج متخصّصة وكم سيخفض ذلك تكلفتك.
