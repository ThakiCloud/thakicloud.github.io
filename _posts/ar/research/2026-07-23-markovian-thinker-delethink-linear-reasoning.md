---
title: "تفكير أطول بكلفة خطية: كيف يعيد Markovian Thinker وDelethink تصميم الاستدلال الطويل"
excerpt: "الكلفة الحقيقية للاستدلال الطويل تأتي من نمو الحالة (state) بلا حدود. يقسّم التفكير الماركوفي (Markovian Thinking) الاستدلال إلى كتل (chunks) ثابتة الحجم ويمرّر حالة قصيرة فقط عبر كل حدّ، فيحوّل الكلفة من تربيعية إلى خطية."
tags: [long-reasoning, chain-of-thought, markovian-thinking, delethink, reinforcement-learning, inference-cost-optimization, linear-scaling, kv-cache, test-time-scaling, inference-serving]
date: 2026-07-23
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/markovian-thinker-delethink-linear-reasoning/"
categories: [research]
author_profile: true
toc: true
---

إذا بلغت النقطة التي يصبح فيها جعل نموذج الاستدلال يفكر لمدة أطول باستمرار أمراً لا يُحتمل كلفةً، فهذا المقال موجّه إليك. إليك الخلاصة أولاً. الكلفة الحقيقية لسلسلة التفكير (chain of thought) الطويلة هي أن الحالة (state) تنمو بلا حدود بينما يفكر النموذج، فتتناسب الكلفة مع مربع طول التفكير، ويخفض التفكير الماركوفي (Markovian Thinking) تلك الكلفة إلى خطية بجعل السياسة (policy) تُقدّم الاستدلال معتمدةً على حالة ثابتة الحجم فقط. في Delethink، وهي البيئة التي تجسّد هذه الفكرة، يفكر نموذج بحجم 1.5B دُرّب بكتل من 8K رمز حتى 24K رمز، ويضاهي أو يتفوق على خط الأساس بالميزانية نفسها، وعند طول تفكير يبلغ 96K تنخفض كلفة التدريب من 27 H100-شهر إلى 7.

![تصوير تجريدي للاستدلال الطويل يتدفق على مسار خطي في كتل ثابتة الحجم](/assets/images/markovian-thinker-delethink-linear-reasoning-hero.png)
*تصوير تجريدي للتفكير الماركوفي: تقسيم الاستدلال الطويل إلى كتل ثابتة الحجم وتمرير حالة قصيرة فقط إلى الأمام.*

## لماذا يستحق هذا المقال القراءة

كُتب هذا المقال للمهندس الذي يخدم أو يدرّب نماذج الاستدلال الطويل باستخدام التعلّم المعزّز (RL)، ولمسؤول المنصة المسؤول عن كلفة الاستدلال تلك. القرار الذي تواجهه هو التالي: تريد أن يفكر النموذج لمدة أطول، لكن كيف تستوعب الحوسبة والذاكرة اللتين تقفزان تربيعياً مع ذلك الطول؟ يجيب التفكير الماركوفي (arXiv:2510.06557، McGill-NLP) بفصل طول التفكير عن حجم السياق (context size). باختصار، إذا قسّمت الاستدلال إلى كتل ثابتة الحجم وأبقيت على حالة نصية قصيرة فقط لنقلها عبر كل حدّ كتلة، فمهما طال التفكير تنمو الكلفة خطياً فقط وتبقى الذاكرة ثابتة.

## نظرة عامة

على مدى السنوات القليلة الماضية، ارتفع أداء نماذج الاستدلال عبر إطالة سلسلة التفكير. والفرضية أن التفكير الأطول يتيح حل مسائل أصعب. لكن هذا التفكير المتطاول يحمل ثمناً خفياً. في بيئة التفكير القياسية لـ RL، تُعرَّف الحالة بأنها الموجّه (prompt) مضافاً إليه كل رمز استدلال وُلِّد حتى الآن. وكلما واصل النموذج التفكير، تضخّمت الحالة، وكان على سياسة قائمة على الانتباه (attention) أن تعيد قراءة تلك الحالة المتنامية في كل مرة، فتتناسب الحوسبة مع مربع طول التفكير. وتنمو الذاكرة معها. ضاعِف التفكير، تتضاعف الكلفة أربع مرات.

يعيد التفكير الماركوفي النظر في تلك الفرضية نفسها. فبدلاً من ترك الحالة تنمو بلا حدود، يجعل السياسة تُقدّم الاستدلال معتمدةً على حالة ثابتة الحجم فقط. إنه يقطع الرابط الذي ربط طول التفكير بحجم السياق، بحيث تبقى الحوسبة خطية والذاكرة ثابتة مع إطالة التفكير. وكما أن الحالة التالية في عملية ماركوف تعتمد فقط على الحالة الثابتة السابقة مباشرة، تعتمد قطعة التفكير التالية فقط على الحالة الثابتة التي جرى تسليمها للتو، لا على كل الرموز السابقة.

## ما هي هذه التقنية

التجسيد الملموس للتفكير الماركوفي هو بيئة تعلّم معزّز تُدعى Delethink. تُنظّم Delethink الاستدلال في كتل ثابتة الحجم. داخل كل كتلة يفكر النموذج بحرية كالمعتاد. وعندما يبلغ حدّ الكتلة، تعيد البيئة ضبط السياق وتعيد تهيئة الموجّه بترحيل (carryover) قصير. والمفتاح هو ما تتعلمه السياسة عبر RL. فقرب نهاية كل كتلة، تتعلم السياسة أن تكتب لنفسها حالة نصية تكفي لمواصلة الاستدلال بسلاسة بعد إعادة الضبط. وترث الكتلة التالية هذه الحالة القصيرة فقط، لا الكتلة السابقة بأكملها.

يوضّح المخطط أدناه هذا التدفق.

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
<div class="d3-arch" data-arch-root id="delethinklinearreasoning-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 508, "height": 836, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 177, "h": 62, "title": ["بداية الكتلة: التهيئة", "بحالة ترحيل قصيرة"]}, {"id": "B", "x": 80, "y": 164, "w": 205, "h": 62, "title": ["التفكير بحرية داخل الكتلة", "كالمعتاد"]}, {"id": "C", "x": 92, "y": 318, "w": 181, "h": 52, "title": "هل بُلغ حدّ الكتلة؟"}, {"id": "D", "x": 80, "y": 462, "w": 205, "h": 62, "title": ["كتابة حالة نصية عند نهاية", "الكتلة"]}, {"id": "E", "x": 91, "y": 602, "w": 184, "h": 46, "title": "البيئة تعيد ضبط السياق"}, {"id": "F", "x": 24, "y": 726, "w": 177, "h": 78, "title": ["الكتلة التالية: ترحيل", "الحالة القصيرة فقط", "بدل التاريخ الكامل"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[144, 86], [183, 125], [183, 125], [183, 164]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[188, 226], [196, 272], [196, 272], [187, 318]]}, {"src": "C", "dst": "B", "kind": "data", "label": "لا", "curve": [[162, 318], [126, 272], [126, 272], [160, 226]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "نعم", "line": [183, 370, 183, 462], "lx": 183, "ly": 412}, {"src": "D", "dst": "E", "kind": "data", "line": [183, 524, 183, 602]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[183, 648], [183, 687], [183, 687], [148, 726]]}, {"src": "F", "dst": "A", "kind": "data", "curve": [[78, 726], [43, 563], [43, 272], [82, 86]]}, {"src": "D", "dst": "D", "kind": "event", "label": "RL يكافئ كتابة حالة جيدة", "curve": [[285, 475], [380, 462], [380, 524], [285, 511]], "off": "50%"}]});
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
      const container = document.getElementById('delethinklinearreasoning-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'delethinklinearreasoning-1';
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

الفرق عن مقاربة سلسلة التفكير الطويلة القياسية (LongCoT) هنا بالضبط. فـ LongCoT يواصل تكديس كل رمز مُولَّد في السياق، فتنمو الحالة بلا حدود. أما Delethink فيُفرغ السياق عند كل كتلة ويمرّر حالة قصيرة فقط، فيبقى حجم الحالة ثابتاً. أنت تُطيل التفكير بخياطة مزيد من الكتل معاً، لكن المقدار المُحمَّل في السياق في أي لحظة محدود بكتلة واحدة.

## ما الذي تقرّره الورقة البحثية

تُظهر الأرقام التي تبلّغ عنها الورقة أن الفكرة تنجح فعلاً. فنموذج R1-Distill 1.5B المُدرَّب في Delethink بكتل من 8K رمز يفكر حتى 24K رمز ويضاهي أو يتفوق على نموذج LongCoT-RL مُدرَّب بميزانية 24K. لقد أدار استدلالاً أطول بثلاث مرات من نافذة 8K التي يراها دفعةً واحدة.

ويتّسع فارق الكلفة مع الحجم. تُبلغ الورقة أنه عند متوسط طول تفكير يبلغ 96K، تكلّف LongCoT-RL 27 H100-شهر من التدريب مقابل 7 لـ Delethink. هذا هو الفارق الذي يصنعه الخطي مقابل التربيعي.

| البند | LongCoT-RL | Delethink (التفكير الماركوفي) |
|---|---|---|
| حجم الحالة | ينمو بلا حدود مع طول التفكير | ثابت عند حجم الكتلة |
| تدرّج الحوسبة | تربيعي مع طول التفكير | خطي مع طول التفكير |
| كلفة التدريب عند 96K تفكير | 27 H100-شهر | 7 H100-شهر |
| التوسّع وقت الاختبار (test-time scaling) | يميل إلى الثبات | يواصل التحسّن |

ويُظهر التوسّع وقت الاختبار فارقاً أيضاً. فحين تدفع بالتفكير إلى الأطول عند الاستدلال، يواصل Delethink التحسّن حيث يثبت LongCoT. وثمة ملاحظة مثيرة أخرى من التحليل عند تهيئة RL: كثيراً ما تعاين نماذج الاستدلال الجاهزة من 1.5B إلى 120B مسارات ماركوفية دون تدريب مسبق عبر معايير متنوعة. هذه العيّنات الإيجابية الطبيعية هي ما يجعل RL فعّالاً على نطاق واسع.

وملاحظة صادقة هنا أيضاً. جميع الأرقام أعلاه قيم تبلّغ عنها الورقة، لا شيء أعدنا إنتاجه وقِسناه بأنفسنا. ونشجعك على التحقق من الشروط التجريبية المحددة مباشرةً في المصدر ومستودع الشيفرة العام.

## ماذا يعني هذا لـ ThakiCloud

يمتد الأثر العملي للتفكير الماركوفي إلى كلا منتجَي ThakiCloud.

زاوية ai-platform مباشرة على نحو خاص. فما يرفع فعلاً كلفة خدمة الاستدلال الطويل هو ذاكرة KV (KV cache) وحوسبة الانتباه اللتان تنموان مع إطالة التفكير. فإذا نما السياق بلا حدود، انخفض عدد الطلبات المتزامنة التي يمكن وضعها على وحدة H200 واحدة، واشتدّ ضغط ذاكرة GPU في بيئة متعددة المستأجرين. وتحديد المقدار المُحمَّل في السياق عند حجم الكتلة، كما في التفكير الماركوفي، يُبقي بصمة ذاكرة KV ثابتة بغضّ النظر عن طول التفكير. وهذا يعني استيعاب مزيد من الاستدلال المتزامن على العتاد نفسه في ظل جدولة GPU القائمة على Kueue، حتى لأحمال تتطلب تفكيراً أطول. وكلما ضاقت ميزانية GPU، كما في النشر داخل المؤسسة والنشر السيادي (sovereign)، كبر مردود الكلفة الخطية.

وثمة زاوية Paxis أيضاً. Paxis هي سحابة ThakiCloud الأصيلة للوكلاء (Agent-Native Cloud)، تُشغّل سير العمل في صناديق رمل معزولة حيث يستدل الوكلاء لمدد طويلة عبر خطوات كثيرة ويستدعون الأدوات. وكلما طال استدلال الوكيل، تضخّم السياق وارتفعت الكلفة والزمن معاً؛ ويقدّم ترحيل الحالة الثابتة في التفكير الماركوفي سبيلاً لإبقاء حلقات الوكيل الطويلة عند ذاكرة ثابتة. وحين يسلسل مُسخّر المهارات (skill harness) عدة مهارات معاً لمهمة طويلة، فإن تصميماً ترث فيه كل خطوة حالة مضغوطة فقط بدل التاريخ الكامل يحسّن اقتصاديات الوكيل مباشرةً.

## الحدود والاعتراضات

أكبر سؤال هو فقدان المعلومات. فإعادة ضبط السياق عند حدّ الكتلة وتمرير حالة قصيرة فقط يعني أن أي تفصيل من الكتلة السابقة لم تلتقطه تلك الحالة القصيرة يضيع إلى الأبد. على السياسة أن تتعلم فعلاً ضغط ما يهم في الحالة، وضبط حجم الحالة وحجم الكتلة على نحو خاطئ قد يضرّ الأداء في مسائل تتطلب تبعيات بعيدة المدى. وليس كل نوع من الاستدلال يتقسّم بنظافة إلى صيغة ماركوفية.

كما أن المقاربة لا تعمل إلا بعد أن يدرّب RL عادة كتابة الحالة. طبّقها كما هي على نموذج لم يتعلم بعد كتابة الحالات فتتفكك الكتل. ومع ذلك، فإن ملاحظة الورقة أن النماذج الجاهزة تعاين مسارات ماركوفية إلى حدّ ما تخفف عبء التمهيد هذا. وأخيراً، فإن المكاسب المُبلَّغ عنها هي لإعداد الورقة التجريبي ومعاييرها، وما إذا كانت تنتقل سليمة إلى استدلال إنتاجي حقيقي في مجالات مختلفة جداً يحتاج إلى تحقق منفصل.

## الخلاصة

قبل محاولة حل كلفة الاستدلال الطويل بتوسيع النموذج، يقول التفكير الماركوفي بتغيير تعريف المشكلة نفسه: لا تدع الحالة تنمو بلا حدود، بل ثبّتها. إذا كنت تخدم أو تدرّب الاستدلال الطويل، فالأمر الوحيد الذي تأخذه اليوم واضح. إطالة التفكير وتنمية السياق بلا حدود ليسا الشيء نفسه، وفصلهما يفتح متسعاً لبلوغ الأداء نفسه بكلفة أقل بكثير. وجعل السياسة تتعلم بنفسها ما تحتفظ به وما تطرحه عند حدّ الكتلة رافعةٌ رخيصة تستحق النظر أولاً، في واقع خدمة تكون فيه كلفة الاستدلال كلفةً للأعمال.

المصدر: [The Markovian Thinker: Architecture-Agnostic Linear Scaling of Reasoning (arXiv:2510.06557)](https://arxiv.org/abs/2510.06557) · [مستودع الشيفرة (McGill-NLP/the-markovian-thinker)](https://github.com/McGill-NLP/the-markovian-thinker)
