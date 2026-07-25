---
title: "الوكيل يُصلح تجهيزه بنفسه: ماذا يكشف Self-Harness عن العنق الحقيقي للتحسين الذاتي"
seo_title: "مراجعة ورقة Self-Harness: حلقة من ثلاث مراحل يُحسّن فيها التجهيز نفسه | ThakiCloud"
seo_description: "شرح لورقة Self-Harness (arXiv 2606.09498) التي رفعت النماذج MiniMax M2.5 وQwen3.5-35B-A3B وGLM-5 على Terminal-Bench-2.0 من 40.5% حتى 61.9% في معدل النجاح. من دون مهندسين بشر، يُصلح الوكيل تجهيزه عبر تعدين الضعف واقتراح التجهيز والتحقق من الاقتراح. نتناول من منظور ThakiCloud لماذا يكون المُقيّم هو العنق الحقيقي لأي حلقة تحسين ذاتي."
excerpt: "من دون المساس بأوزان النموذج، رفع إصلاح التجهيز وحده معدلات النجاح على Terminal-Bench بأكثر من 60% نسبياً. لكن سقف هذه الحلقة يحدده مدى صرامة المُقيّم."
date: 2026-07-25
tags:
  - 에이전트
  - 자가개선
  - 하네스
  - 에이전트 하네스
  - Terminal-Bench
  - 평가자
  - LLM 에이전트
  - 에이전트 루프
  - 프로덕션 에이전트
  - MLOps
categories: [research]
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/self-improving-agent-harness/"
---

إن كنت تُشغّل تجهيز وكيل في الإنتاج، فأنت على الأرجح تتساءل دائماً أين يختبئ الهامش المتاح لرفع معدلات النجاح بعد أن تتوقف عن استبدال النموذج بآخر أكبر. خلاصة Self-Harness (arXiv 2606.09498) هي أن هذا الهامش لا يقع في النموذج بل في التجهيز، والمدهش أن الوكيل يستطيع استعادة جزء كبير منه بإصلاح تجهيزه بنفسه من دون تدخل بشري. أما مدى ارتفاع حلقة التحسين الذاتي هذه فيعتمد لا على المُولّد بل على مدى صرامة المُقيّم. يعرض هذا المقال الآلية وحدودها.

## لماذا تقرأ هذا

هذا المقال موجّه للمهندسين الذين يُشغّلون تجهيز وكيل مباشرة، ولمسؤولي المنصات الراغبين في تصميم حلقة تحسين ذاتي. نقصد بالتجهيز كامل الهيكل المحيط بالنموذج: موجّه النظام وتعريفات الأدوات وقواعد التوجيه وبوابات التحقق من المخرجات. الخلاصة الجوهرية أن رافعة رفع أداء الوكيل ليست فقط استبدال النموذج بل تحسين التجهيز، وأن الوكيل يستطيع تكرار ذلك التحسين بنفسه. غير أن السقف يحدده جودة المُقيّم. معرفة هذا تتيح لك تأجيل القرار الانعكاسي "الأداء ضعيف فلننتقل إلى نموذج أكبر" وإصلاح التجهيز والمُقيّم أولاً.

## نظرة عامة

خلال العامين الماضيين انتقل مركز ثقل أبحاث الوكلاء من النموذج نفسه إلى الهيكل المحيط به. تأكد مراراً أن النتائج تتغير كثيراً بالنموذج ذاته تبعاً لكيفية كتابة موجّه النظام والأدوات المقدَّمة وطريقة تغذية الإخفاقات عكسياً. ومع ذلك ظل تحسين هذا التجهيز مهمة مهندس بشري: العمل اليدوي الممل في جمع حالات الفشل وقراءتها وتنقيح الموجّهات وصقل الأدوات.

يُسلّم Self-Harness هذا العمل اليدوي إلى الوكيل. من دون جلب مهندس بشري أو وكيل خارجي أقوى، يجعل الوكيل يُصلح تجهيزه بنفسه. السؤال الذي تطرحه الورقة بسيط: كم يرتفع الأداء إذا تركت أوزان النموذج دون مساس وأصلحت التجهيز وحده مراراً، وأين يتوقف ذلك التحسين؟

## ما هو هذا البحث

عمود Self-Harness حلقة من ثلاث مراحل متشابكة: تعدين الضعف (Weakness Mining)، واقتراح التجهيز (Harness Proposal)، والتحقق من الاقتراح (Proposal Validation).

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
<div class="d3-arch" data-arch-root id="elfimprovingagentharness-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 428, "height": 664, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 198, "h": 94, "title": ["تعدين الضعف", "Weakness Mining", "استخراج نقاط خلل التجهيز", "من التشغيلات الفاشلة"]}, {"id": "B", "x": 205, "y": 196, "w": 191, "h": 110, "title": ["اقتراح التجهيز", "Harness Proposal", "توليد تعديلات محددة على", "الموجّهات والأدوات", "والقواعد"]}, {"id": "C", "x": 113, "y": 384, "w": 198, "h": 94, "title": ["التحقق من الاقتراح", "Proposal Validation", "تقييم ما إذا كان التعديل", "يرفع معدل النجاح فعلاً"]}, {"id": "D", "x": 48, "y": 570, "w": 191, "h": 62, "title": ["تجهيز محسّن", "أوزان النموذج دون تغيير"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[220, 118], [301, 157], [301, 157], [301, 196]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[301, 306], [301, 345], [301, 345], [260, 384]]}, {"src": "C", "dst": "D", "kind": "data", "label": "\"نجاح: دمج في التجهيز\"", "curve": [[212, 478], [212, 524], [212, 524], [171, 570]], "off": "50%"}, {"src": "C", "dst": "A", "kind": "event", "label": "\"إخفاق: إلغاء\"", "curve": [[163, 384], [123, 345], [123, 157], [123, 118]], "off": "50%"}, {"src": "D", "dst": "A", "kind": "data", "curve": [[95, 570], [22, 431], [22, 251], [68, 118]]}]});
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
      const container = document.getElementById('elfimprovingagentharness-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'elfimprovingagentharness-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

المرحلة الأولى، تعدين الضعف، تنقّب في التشغيلات الفاشلة لتجد أي جزء من التجهيز سبّب المشكلة. النقطة ليست مجرد "كان خطأً" بل تحديد أي ملف أو أي إجراء قاد الوكيل في الاتجاه الخطأ. المرحلة الثانية، اقتراح التجهيز، تستهدف ذلك الضعف وتُنتج تعديلات محددة لكيفية تغيير موجّه النظام وتعريفات الأدوات وقواعد التوجيه. المرحلة الثالثة، التحقق من الاقتراح، تتحقق مما إذا كان ذلك التعديل يرفع معدل النجاح فعلاً. التعديلات التي تجتاز هنا فقط تُدمج في التجهيز، وما لا يجتاز يُلغى.

النقطة الحاسمة في هذا الهيكل أن أوزان النموذج لا تُدرَّب إطلاقاً. الشيء الوحيد الذي يتحسن هو الهيكل خارج النموذج. وهذا يترك مجالاً للفرق التي لا تملك ميزانية لإعادة تدريب الأوزان، وللفرق التي تستخدم نماذج مغلقة عبر واجهة برمجية فقط، لتطبيق هذه الطريقة مباشرة.

## النتائج التجريبية الفعلية

شغّلت الورقة Self-Harness على معيار اسمه Terminal-Bench-2.0 بثلاثة نماذج أساس. النتائج ملخّصة أدناه.

| النموذج الأساس | معدل النجاح قبل | معدل النجاح بعد | التحسن النسبي |
|---|---|---|---|
| MiniMax M2.5 | 40.5% | 61.9% | نحو +53% |
| Qwen3.5-35B-A3B | 23.8% | 38.1% | نحو +60% |
| GLM-5 | 42.9% | 57.1% | نحو +33% |

أظهرت النماذج الثلاثة جميعها مكاسب واضحة في معدل النجاح على مسائل محجوزة (لم تُستخدم في التحسين)، رغم أن الأوزان لم تُمسّ. بلغ التحسن النسبي لـ Qwen3.5-35B-A3B نحو 60%. ومن اللافت أيضاً أن النموذج الأضعف بدايةً تحسّن بأكبر هامش بالقيم المطلقة، ما يفتح قراءة مفادها أن كلما كان التجهيز أهشّ زاد المجال المتاح لإصلاح نفسه.

تنبيه هنا: هذه الأرقام قيم أكدناها من ملخص الورقة ومقدمتها، لا أرقام أعدنا إنتاجها بأنفسنا. يقيس Terminal-Bench-2.0 القدرة على تنفيذ مهام حقيقية في بيئة طرفية، لذا فإن ما إذا كانت التقنية ذاتها تنتقل بالهامش نفسه إلى مجالات أخرى (كتوليد المستندات أو تحليل البيانات) يجب التحقق منه على حدة.

## العنق الحقيقي لحلقة التحسين الذاتي: المُقيّم

أجدر مقطع بالتأمل في هذه الورقة ليس أرقام الأداء بل أين تتوقف تلك الأرقام. المرحلة الثالثة، التحقق من الاقتراح، هي مُقيّم هذه الحلقة. وحلقة التحسين الذاتي تميل إلى التوقف لحظة يكفّ المُقيّم عن أن يصير أصعب. إذا كان معيار قبول الاقتراح متساهلاً، يظل الوكيل يقبل تغييرات لا تجعله أفضل فعلاً، وتدور الحلقة في مكانها.

يتطابق هذا تماماً مع نظام داخلي شددنا عليه مراراً: قبل دمج النتائج المتفرّعة يجب إغلاقها بمرحلة تحقق، وأن يكون ذلك التحقق تخاصمياً بمنظور مختلف عن المُولّد، وأن السبب الأشيع لضعف الجودة ليس "النموذج ضعيف" بل "لا توجد مرحلة تحقق أو أنها ضعيفة". يدعم Self-Harness هذا المبدأ بأرقام معيارية. أي إن أردت رفع سقف التحسين الذاتي فاجعل المُقيّم أكثر صرامة قبل أن تكبّر المُولّد.

## دلالات لمنتجات ThakiCloud

هذه الورقة مباشرة بوجه خاص من منظور Paxis لدينا. Paxis هو Agent-Native Cloud من ThakiCloud، مستوى تحكّم يتعامل مع Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. يختار من أكثر من 960 مهارة عبر BM25، ويشغّلها في صناديق رمل معزولة، ويمرّر كل فعل عبر بوابات السياسة وسجلات التدقيق. التجهيز الذي يتحدث عنه Self-Harness، أي مجموعة الموجّهات والأدوات وقواعد التوجيه، هو بالضبط تجهيز مهارات Paxis.

تنطبق حلقة المراحل الثلاث في Self-Harness طبيعياً على طبقة المهارات ذاتية التطور في Paxis. تعدين الضعف الذي يسحب نقاط الضعف من سجلات التشغيل الفاشلة تتولاه روتينات الاستعادة والتعدين لدينا، واقتراح التجهيز يقابل مرحلة التطور التي تنقّح المهارات والقواعد، والتحقق من الاقتراح يقابل البوابات الحتمية والتصويت التخاصمي. خلاصة الورقة أن "المُقيّم هو العنق" تلامس مباشرة نظامنا في امتلاك البوابات بالشيفرة وفصل مرحلة التحقق عن المُولّد واعتبار المُقيّم الذي لا يرفض شيئاً معطوباً.

من زاوية البنية التحتية تعمل عدسة ai-platform جنباً إلى جنب. تحسين الأداء بإصلاح التجهيز وحده يعني التحسين بتغيير هيكل زمن الاستدلال فقط، من دون إعادة تدريب مكلفة. في بيئة خدمة متعددة المستأجرين قائمة على K8s، يفتح هذا مساراً لتحسين تجهيزات كل عميل تكرارياً من دون دفع تكاليف إعادة تدريب GPU. الخدمة منخفضة التكلفة تصنع اقتصاديات الوكلاء، وفوقها يرفع التحسين الذاتي للتجهيز الجودة.

## القيود والحجج المضادة

لـ Self-Harness حدود واضحة أيضاً. أولاً، سقف هذه الطريقة مرتبط في النهاية بجودة المُقيّم. إن عجزت مرحلة التحقق عن فصل الأداء الحقيقي بشكل صحيح، تتوقف الحلقة أو، أسوأ، تفرط في المواءمة مع أنماط خاصة بالمعيار. ثانياً، هذه أرقام من معيار واحد محدد، Terminal-Bench-2.0، لذا لم يتأكد ما إذا كان الهامش نفسه يتكرر تحت توزيع مهام مختلف. ثالثاً، ثمة خطر أن ينمو التجهيز في اتجاهات يصعب ضبطها كلما كبر وتعقّد بنفسه. إن تُرك يُصلح نفسه بلا حدود دون مراجعة بشرية، قد يبلغ حالاً لا يستطيع أحد فيها تفسير سبب تصرفه.

لذا عند إدخال هذه التقنية في نظام حقيقي، الأوقع إضافة ضمانات، بأن يراجع البشر عينات دورياً ويقووا المُقيّم نفسه باستمرار، بدلاً من ترك التحسين الذاتي يعمل بذاتية كاملة. مبدأ أن الأتمتة أداة لمساعدة التفكير لا لاستبداله ينطبق هنا أيضاً.

## الخلاصة

اختصاراً في جملة واحدة، الدرس العملي من Self-Harness هو: حين يصطدم أداء الوكيل بجدار، أول ما يجب لمسه ليس نموذجاً أكبر بل التجهيز والمُقيّم الذي يقيّمه. نتيجة رفع معدلات النجاح بأكثر من 60% نسبياً من دون المساس بأوزان النموذج تُظهر أن قدراً كبيراً من الأداء غير المستعاد لا يزال داخل الهيكل. لكن سقف تلك الاستعادة يحدده المُقيّم. إن كنت تُشغّل حلقة تحسين ذاتي، نقترح أن تجعل المُقيّم أكثر صرامة قبل المُولّد في سبرينتك القادم. تلك هي الرافعة الأوثق التي أثبتتها هذه الورقة بالأرقام.

## المصادر

- Self-Harness: Harnesses That Improve Themselves، arXiv 2606.09498 (<https://arxiv.org/abs/2606.09498>)
