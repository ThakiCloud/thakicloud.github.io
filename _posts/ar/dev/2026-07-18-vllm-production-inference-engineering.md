---
title: "كيف يعمل vLLM، وكيف يُستخدم في بيئة الإنتاج"
excerpt: "عند نشر نموذج لغوي كبير في خدمة حقيقية، تتحدد معظم التكلفة ليس باختيار النموذج، بل بمحرك الاستدلال الذي يشغّله. نستعرض كيف يقلل vLLM من هدر GPU عبر PagedAttention والتجميع المستمر (continuous batching)، وكيف تشغّله ThakiCloud في بيئة الإنتاج من منظور تشغيلي."
date: 2026-07-18
lang: ar
canonical_url: https://thakicloud.com/tech-blog/ar/dev/vllm-production-inference-engineering/
tags:
  - vLLM
  - 추론엔진
  - PagedAttention
  - 연속배칭
  - LLM서빙
  - LLMOps
  - 쿠버네티스
  - 온프레미스
author_profile: true
toc: true
toc_label: تشريح محرك الاستدلال
published: true
categories:
  - dev
  - llmops
---

## نظرة عامة

أي فريق قام بنشر نموذج لغوي كبير في خدمة حقيقية يدرك سريعا حقيقة واحدة: ما يحدد سرعة استجابة الخدمة وتكلفتها ليس النموذج الذي اخترته، بل ما تستخدمه لتشغيله. على نفس بطاقة GPU، وبنفس النموذج، يمكن أن تختلف الإنتاجية في الثانية بعدة أضعاف حسب محرك الاستدلال المستخدم. واختلاف الإنتاجية بعدة أضعاف يعني اختلاف عدد وحدات GPU اللازمة لتحمل نفس حجم الحركة بعدة أضعاف أيضا، وهذا ينعكس مباشرة على حجم فاتورة البنية التحتية.

يتناول هذا المقال vLLM، الذي أصبح اليوم المعيار الفعلي لخدمة النماذج اللغوية الكبيرة في بيئة الإنتاج. سنستعرض بالترتيب المشكلة التي ظهر vLLM لحلها، وما تفعله فعليا تقنياته الأساسية PagedAttention والتجميع المستمر (continuous batching)، وما الذي يجب الانتباه إليه لتشغيله بثبات فوق Kubernetes. تدير ThakiCloud هذا المحرك في كل من البيئات المحلية (on-premise) والبيئات المُدارة لعملائها، لذا سنتجاوز الشرح النظري البسيط ونكتب هذا من منظور المشغّل الفعلي.

## ما هو vLLM

vLLM محرك استدلال مفتوح المصدر أطلقه باحثون من جامعة كاليفورنيا بيركلي عام 2023. الهدف بسيط وواضح: جعل استدلال النماذج اللغوية الكبيرة أسرع وأرخص. انتشر بسرعة بعد إطلاقه، وأصبح اليوم الخيار الافتراضي الذي يقوم عليه استدلال الإنتاج لدى منظمات عديدة مثل Meta وMistral وCohere وIBM.

ما يستهدفه vLLM هو نوعان من الهدر المختبئان في أساليب الاستدلال التقليدية. الأول هو تجزؤ الذاكرة (memory fragmentation)، والثاني هو وقت خمول GPU. لا يظهر أي منهما بوضوح على السطح، لكن مجتمعين يتركان جزءا كبيرا من GPU الباهظة الثمن في حالة خمول دون أي عمل. تستهدف التقنيتان الأساسيتان في vLLM، وهما PagedAttention والتجميع المستمر، كل واحدة نوعا من هذين النوعين من الهدر بشكل مباشر.

لنرسم أولا الهيكل العام.

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
<div class="d3-arch" data-arch-root id="tioninferenceengineering-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 515, "height": 950, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 159, "y": 24, "w": 177, "h": 46, "title": "طلبات مستخدمين متعددة"}, {"id": "B", "x": 187, "y": 148, "w": 120, "h": 46, "title": "المجدول"}, {"id": "C", "x": 150, "y": 272, "w": 195, "h": 68, "title": ["تجميع مستمر", "إعادة بناء في كل خطوة"]}, {"id": "D", "x": 231, "y": 418, "w": 170, "h": 62, "title": ["PagedAttention", "إدارة صفحات ذاكرة KV"]}, {"id": "E", "x": 363, "y": 572, "w": 120, "h": 62, "title": ["تنفيذ GPU", "تمرير أمامي"]}, {"id": "F", "x": 167, "y": 712, "w": 160, "h": 68, "title": ["الطلبات المكتملة", "تُعاد فورا"]}, {"id": "G", "x": 187, "y": 872, "w": 120, "h": 46, "title": "بث الاستجابة"}, {"id": "H", "x": 110, "y": 572, "w": 198, "h": 62, "title": ["كتل فيزيائية غير متجاورة", "ذاكرة GPU"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [247, 70, 247, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [247, 194, 247, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[279, 340], [316, 379], [316, 379], [316, 418]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[359, 480], [423, 526], [423, 526], [423, 572]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[423, 634], [423, 673], [423, 673], [327, 713]]}, {"src": "F", "dst": "C", "kind": "data", "label": "تسلسل غير مكتمل", "curve": [[167, 713], [72, 603], [72, 449], [166, 340]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "label": "مكتمل", "line": [247, 780, 247, 872], "lx": 247, "ly": 822}, {"src": "D", "dst": "H", "kind": "event", "label": "جدول الكتل", "curve": [[272, 480], [209, 526], [209, 526], [209, 572]], "off": "50%"}]});
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
      const container = document.getElementById('tioninferenceengineering-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'tioninferenceengineering-1';
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

## PagedAttention: القضاء على هدر الذاكرة

أثناء توليد النموذج اللغوي للرموز (tokens) واحدا تلو الآخر، يخزّن المفاتيح والقيم التي حسبها سابقا. يُسمى هذا ذاكرة KV المؤقتة (KV cache)، وكلما طالت الجملة، زاد حجم هذه الذاكرة المؤقتة في ذاكرة GPU. تكمن المشكلة في أن الأسلوب التقليدي يحجز لكل طلب مسبقا مقدارا من الذاكرة يعادل الطول الأقصى المتوقع، وذلك كقطعة كبيرة متجاورة. فإذا كانت الاستجابة الفعلية أقصر من ذلك، يُهدر جزء كبير من الذاكرة المحجوزة ببساطة. وعندما تصل طلبات متعددة في وقت واحد، يتراكم هذا الهدر، حتى تصل الحالة إلى أن GPU لديه ذاكرة فارغة لكنه لا يستطيع استقبال طلب جديد.

استعار PagedAttention فكرته مباشرة من طريقة أنظمة التشغيل في التعامل مع الذاكرة العشوائية (RAM)، أي الذاكرة الافتراضية والترقيم (paging). فبدلا من حجز ذاكرة KV المؤقتة كقطعة واحدة كبيرة، يقسّمها إلى صفحات صغيرة قابلة لإعادة الاستخدام. تُربط الكتل المنطقية لكل تسلسل، عبر جدول كتل (block table)، بكتل فيزيائية غير متجاورة داخل ذاكرة GPU. وبهذا لا يُخصَّص إلا العدد الفعلي اللازم من الصفحات، ما يقلل هدر الذاكرة بشكل كبير. وبحسب مصادر مشروع vLLM نفسه، يمكن لهذا الأسلوب أن يقلل هدر الذاكرة بنسبة تصل إلى 90 بالمئة.

وله أيضا فائدة جانبية كبيرة. ففي عمليات فك ترميز معقدة تتفرع من موجّه (prompt) واحد إلى مسارات متعددة، مثل أخذ العينات المتوازي (parallel sampling) أو بحث الحزمة (beam search)، لا يحتاج vLLM إلى تكرار ذاكرة KV المؤقتة الخاصة بالموجّه. يمكن لكتل منطقية متعددة أن تشير إلى نفس الكتلة الفيزيائية، ولا تُنشأ نسخة إلا عندما تحتاج إحداها إلى تعديل تلك الكتلة، وهو أسلوب النسخ عند الكتابة (copy-on-write). وبذلك تتمكن الطلبات التي تشترك في نفس السياق البادئ من التعايش مع توفير في الذاكرة.

## التجميع المستمر: إبقاء GPU مشغولا دائما

النوع الثاني من الهدر هو هدر الوقت. يجمّع التجميع الثابت التقليدي (static batching) الطلبات في دفعة (batch) ويعالجها معا، ولا يبدأ الدفعة التالية حتى تنتهي جميع الطلبات في الدفعة الحالية. تكمن المشكلة في أن عدد الرموز التي يولّدها كل طلب يختلف من طلب لآخر. فالطلب الذي ينتج إجابة قصيرة ينتهي مبكرا، لكنه يظل بحاجة إلى الانتظار حتى ينتهي أطول طلب في الدفعة. وخلال ذلك، يبقى مكان GPU الذي كان يشغله الطلب المنتهي خاملا.

يزيل التجميع المستمر هذا الانتظار. يتخذ المجدول قراراته على مستوى التكرار (iteration) وليس على مستوى الدفعة، أي في كل تمرير أمامي (forward pass). فبمجرد انتهاء أي طلب في تلك الخطوة، يُملأ مكانه فورا بطلب جديد من قائمة الانتظار. وبما أن الطلبات الجارية والطلبات الجديدة تُمزج ديناميكيا في كل خطوة، فإن GPU لا يخمل تقريبا أبدا. ويُذكر أن هذا الأسلوب يرفع الإنتاجية على نفس العتاد بمقدار 3 إلى 10 أضعاف.

عند تطبيق PagedAttention والتجميع المستمر معا، الملاحظة الشائعة هي أن الإنتاجية تتحسن بمقدار يتراوح تقريبا بين ضعفين وأربعة أضعاف مقارنة بتنفيذ ساذج للخدمة. تكمّل التقنيتان بعضهما البعض. فلكي يتمكن التجميع المستمر من إدراج طلب جديد في كل خطوة، يحتاج إلى مرونة مماثلة في ربط الذاكرة وفصلها، وهذه المرونة هي بالضبط ما يوفره PagedAttention.

> الأرقام أعلاه مأخوذة من مشروع vLLM ومصادر قياس أداء (benchmark) متعددة، والتحسن الفعلي يختلف باختلاف حجم النموذج، وتوزيع أطوال التسلسلات، والعتاد المستخدم. يجب قياس الأرقام الدقيقة الخاصة ببيئتك عبر حمل العمل الفعلي لديك.

## كيف يُستخدم في بيئة الإنتاج

بعد فهم المفاهيم، يصبح التشغيل الفعلي بسيطا بشكل مفاجئ. يوفر vLLM خادما متوافقا مع OpenAI بشكل افتراضي، لذا فإن الشيفرة التي كانت تستدعي واجهة برمجية خارجية غالبا ما تعمل دون تعديل بمجرد تغيير عنوان نقطة النهاية (endpoint) فقط.

أبسط شكل لتشغيل الخادم كالتالي.

```bash
# تثبيت vLLM (بيئة CUDA)
pip install vllm

# تشغيل خادم متوافق مع OpenAI
vllm serve meta-llama/Llama-3.1-8B-Instruct \
  --tensor-parallel-size 1 \
  --max-model-len 8192 \
  --gpu-memory-utilization 0.90
```

الاستدعاء يستخدم عميل OpenAI الحالي كما هو.

```python
from openai import OpenAI

client = OpenAI(base_url="http://localhost:8000/v1", api_key="EMPTY")
resp = client.chat.completions.create(
    model="meta-llama/Llama-3.1-8B-Instruct",
    messages=[{"role": "user", "content": "اشرح vLLM في جملة واحدة"}],
)
print(resp.choices[0].message.content)
```

النقطة التي تتطلب فعليا اهتماما في بيئة الإنتاج ليست أمر تشغيل الخادم نفسه، بل المعاملات التشغيلية المحيطة به. على وجه الخصوص، يجب الانتباه إلى التالي.

- `--gpu-memory-utilization`: نسبة ذاكرة GPU المخصصة لذاكرة KV المؤقتة. رفعها كثيرا يؤدي إلى تجاوز الذاكرة لحظيا، وخفضها كثيرا يقلل عدد الطلبات التي يمكن استقبالها في وقت واحد.
- `--tensor-parallel-size`: حجم التوازي على مستوى المصفوفات (tensor parallel) الذي يوزع النموذج على عدة وحدات GPU. ضروري عند خدمة نموذج كبير لا يتسع في GPU واحدة.
- `--max-model-len`: الطول الأقصى للسياق (context). كلما زاد هذا الرقم، كبرت ذاكرة KV المؤقتة لكل طلب، ما يخلق مفاضلة تقلل الإنتاجية المتزامنة.

عند التشغيل فوق Kubernetes، تُضاف إلى ذلك طبقة الجدولة وإدارة الموارد. GPU مورد باهظ الثمن ومحدود، لذا فبمجرد أن تشترك عدة فرق وعدة نماذج في عنقود (cluster) واحد، ينشأ تنافس على الموارد فورا. وهنا تأتي الحاجة إلى الجدولة الدفعية القائمة على قوائم الانتظار (queue-based batch scheduling). تضع ThakiCloud Kueue في هذه الطبقة لإدارة أي حمل عمل يشغل كم من GPU ومتى، كسياسة واضحة.

## الآثار المترتبة على منتجات ThakiCloud

منصة ai-platform الخاصة بـ ThakiCloud هي بنية تحتية لخدمات الذكاء الاصطناعي وتعلم الآلة كخدمة (SaaS) قائمة على Kubernetes، وتُعد خدمة النماذج في بيئات متنوعة لدى العملاء قدرتها الأساسية. يمثّل vLLM المحرك الافتراضي في طبقة الخدمة هذه. تنعكس مكاسب الإنتاجية التي يحققها PagedAttention والتجميع المستمر مباشرة على خفض تكلفة الخدمة، وهذا ما يمكّننا من تقديم تكلفة خدمة منخفضة لعملائنا.

وتزداد قيمة هذا المزيج بشكل خاص في البيئات المحلية (on-premise) والبيئات ذات السيادة (sovereign). فالعملاء الذين لا يمكنهم إخراج بياناتهم إلى الخارج مضطرون لتشغيل النماذج داخل بنيتهم التحتية الخاصة من GPU، وفي هذه الحالة، يصبح رفع الإنتاجية التي تتحملها كل بطاقة GPU إلى أقصى حد ممكن هو ما يحدد إمكانية التبني نفسها. فإذا استخدم محرك الاستدلال GPU بكفاءة أعلى بمقدار الضعف، فهذا يعني أن نفس الخدمة يمكن تشغيلها بنصف العتاد.

من الناحية التشغيلية، القيمة التي تضيفها ThakiCloud ليست المحرك نفسه، بل الهيكل المحيط به: إدارة قوائم انتظار GPU عبر Kueue، والعزل بين المستأجرين المتعددين (multi-tenant isolation)، والتوسع التلقائي والمراقبة (observability)، وطبقة السياسات التي تتيح لعدة نماذج التعايش بأمان في عنقود واحد. إذا كان vLLM مسؤولا عن كفاءة خادم واحد، فإن المنصة مسؤولة عن جعل عشرات من هذه الخوادم قابلة للمشاركة بثبات عبر المؤسسة بأكملها.

## القيود والحجج المضادة

vLLM ليس حلا سحريا شاملا. لديه بعض القيود الصادقة التي يجب ذكرها.

أولا، تتألق قوة vLLM في الإنتاجية، أي عند استقبال عدد كبير من الطلبات في وقت واحد. وعلى العكس، في حالات الحمل المنخفض حيث تصل الطلبات نادرا وواحدا تلو الآخر، لا تكون ميزة التجميع المستمر كبيرة، وقد يكون نهج آخر متخصص في تحسين زمن الاستجابة (latency) أفضل. يجب أولا فهم نمط حركة المرور الخاص بك، هل هو طلبات متزامنة بكميات كبيرة أم طلبات متفرقة أحادية.

ثانيا، الأرقام التي يقدمها PagedAttention والتجميع المستمر تعتمد بشدة على حمل العمل. ففي حالات أطوال التسلسل الطويلة جدا أو القصيرة جدا، أو على عتاد معين، قد لا تتكرر نسب التحسن المُبلَّغ عنها كما هي. يجب أن يستند قرار التبني إلى اختبار حمل فعلي يمثّل حمل العمل الخاص بك، ولا ينبغي افتراض أن المضاعف الذي أبلغ عنه طرف آخر سيكون هو نفسه لديك.

ثالثا، كلما تحسنت كفاءة المحرك، ينتقل عنق الزجاجة فعليا إلى مستوى أعلى، أي إلى الجدولة والتشغيل متعدد المستأجرين. مهما بلغت درجة تحسين خادم واحد، فإن مشكلة تنافس عدة فرق على GPU يجب حلها في طبقة المنصة وليس في طبقة المحرك. vLLM نقطة انطلاق ممتازة، لكنه ليس نقطة النهاية، والتحديات الحقيقية في بيئة الإنتاج تبدأ بعده مباشرة.

## المصادر

- [vLLM Explained: PagedAttention and Continuous Batching (RunPod)](https://www.runpod.io/articles/guides/vllm-pagedattention-continuous-batching)
- [LLM Serving Optimization: Continuous Batching, PagedAttention, and Chunked Prefill (Spheron)](https://www.spheron.network/blog/llm-serving-optimization-continuous-batching-paged-attention/)
- [vLLM Production Deployment (Introl)](https://introl.com/blog/vllm-production-deployment-inference-serving-architecture-guide)
- [vLLM: Deploying LLMs at Scale (LearnOpenCV)](https://learnopencv.com/vllm-deploy-llms-at-scale-paged-attention/)
