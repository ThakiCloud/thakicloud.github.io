---
title: "البرمجة باستخدام Kimi K3: ربط نموذج مفتوح بحجم 2.8T بوكيل الطرفية OpenCode"
seo_title: "البرمجة باستخدام Kimi K3 و OpenCode في الطرفية - Thaki Cloud"
seo_description: "كيفية ربط Kimi K3، نموذج Moonshot AI المفتوح من نوع MoE بحجم 2.8 تريليون معامل، بوكيل البرمجة مفتوح المصدر OpenCode الذي يعمل في الطرفية. نُثبّت OpenCode 1.18.3، ونستعرض مسار مصادقة المزوّد واختيار النموذج عمليًا، ثم نقرأ الدلالات على منصة ThakiCloud: ai-platform لخدمة نموذج مفتوح بحجم 2.8T محليًا، و Paxis كسحابة أصلية للوكلاء يكون فيها دماغ الوكيل قابلًا للاستبدال."
excerpt: "يمكن تشغيل Kimi K3، الذي يصفه كثيرون بأنه من فئة Fable 5، داخل وكيل طرفية مفتوح المصدر بدلًا من بيئة تطوير مغلقة مملوكة. ثبّتنا OpenCode للتحقق من مسار اتصال المزوّد من طرف إلى طرف."
date: 2026-07-18
tags:
  - kimi-k3
  - opencode
  - moonshot-ai
  - coding-agent
  - open-weight
  - terminal
  - developer-tools
  - paxis
  - ai-coding
categories:
  - tutorials
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/kimi-k3-opencode-coding/"
---

خلال الأيام القليلة الماضية امتلأت الخطوط الزمنية للمطورين بمواضيع بعنوان "كيف تبرمج باستخدام
Kimi K3". انقسمت الردود إلى اتجاهين. الأول أن نتائج القياس قوية فعلًا. والثاني أنه يمكنك تشغيل
هذا النموذج من طرفيتك الخاصة، داخل وكيل برمجة اخترته أنت، بدلًا من أداة مغلقة تابعة لشركة واحدة.
يتناول هذا المقال الاتجاه الثاني. القارئ المستهدف هو مطوّر يفضّل تبديل النماذج داخل أداة مفتوحة
المصدر بدلًا من الارتباط بواجهة رسومية لمزوّد بعينه. باختصار: اربط Kimi K3 من Moonshot AI كمزوّد
بوكيل الطرفية مفتوح المصدر OpenCode، وستتمكن من البرمجة بنموذج من فئة 2.8 تريليون معامل دون
الارتباط بأي بيئة تطوير واحدة.

## نظرة عامة

أصدرت Moonshot AI نموذج Kimi K3 في 16 يوليو 2026. وفق الشركة، فهو نموذج Mixture-of-Experts بحجم
2.8 تريليون معامل ومن بين أكبر النماذج مفتوحة الأوزان الصادرة حتى الآن. الجزء المثير للاهتمام ليس
النتائج فحسب. فهذا النموذج غير محصور داخل روبوت محادثة مملوك؛ بل يتصل كمزوّد بوكيل برمجة مفتوح
المصدر يعمل في الطرفية. بعبارة أخرى، أصبح بالإمكان الفصل بين "أي بيئة تطوير تستخدم" و"أي نموذج
تبرمج به".

من منظور ThakiCloud، يهمّ هذا الاقتران لسببين. أولًا، وكيل برمجة قادر على تبديل النماذج بحرية بدلًا
من الارتباط بمزوّد يتوافق مع الفرضية الأساسية لتصميم منصات الوكلاء. ثانيًا، نموذج مفتوح الأوزان بحجم
2.8 تريليون معامل يجب أن يخدمه أحدهم على وحدات GPU حقيقية، وتكلفة تلك الخدمة ومتطلبات التشغيل المحلي
تعود مباشرةً كأسئلة بنية تحتية. فيما يلي نثبّت الأداة عمليًا للتحقق من مسار الاتصال، ثم نعالج المنظورين.

## ما هي هذه الأدوات

OpenCode هو وكيل برمجة مفتوح المصدر يعمل في الطرفية. يقرأ ملفات قاعدة الشيفرة، ويشرح البنية، ويحرّر
الشيفرة، ويراجع التغييرات، وينفّذ المهام عبر مزوّد LLM متصل. ولأنه غير مرتبط بنموذج واحد بل يبدّل
المزوّدين، يمكنك الاحتفاظ بسير العمل نفسه وتغيير النموذج تحته فقط.

Kimi K3 هو النموذج الذي يشغل خانة المزوّد تلك. وفق إعلان Moonshot AI، المواصفات الأساسية كالتالي.
إنه نموذج MoE بحجم 2.8 تريليون معامل، يُفعَّل منه 16 خبيرًا من أصل 896 لكل رمز (token). ويستخدم
الانتباه آلية Kimi Delta Attention (KDA)، وهي انتباه خطي هجين. يُضاف إلى ذلك تقنية Attention
Residuals (بديل عن الوصلات المتبقية)، وفهم بصري أصيل، ونافذة سياق تصل إلى مليون رمز. ومن المقرر
إصدار أوزان النموذج الكاملة في 27 يوليو 2026.

يبدو مسار ربط الأداتين كالتالي.

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
<div class="d3-arch" data-arch-root id="0718kimik3opencodecoding-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 359, "height": 870, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 54, "y": 24, "w": 163, "h": 62, "title": ["طرفية المطوّر", "OpenCode TUI أو run"]}, {"id": "B", "x": 130, "y": 164, "w": 163, "h": 62, "title": ["طبقة المزوّد", "opencode auth login"]}, {"id": "C", "x": 97, "y": 304, "w": 230, "h": 68, "title": ["اختيار النموذج", "/models أو opencode models"]}, {"id": "D", "x": 137, "y": 464, "w": 149, "h": 62, "title": ["مزوّد Moonshot AI", "Kimi K3"]}, {"id": "E", "x": 106, "y": 604, "w": 212, "h": 78, "title": ["Kimi Delta Attention", "2.8T MoE · 896 خبيرًا · 16", "مُفعَّل لكل رمز"]}, {"id": "F", "x": 36, "y": 760, "w": 198, "h": 78, "title": ["قراءة · تحرير · مراجعة ·", "تشغيل الشيفرة", "سياق حتى 1M"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[169, 86], [212, 125], [212, 125], [212, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [212, 226, 212, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [212, 372, 212, 464]}, {"src": "D", "dst": "E", "kind": "data", "line": [212, 526, 212, 604]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[212, 682], [212, 721], [212, 721], [174, 760]]}, {"src": "F", "dst": "A", "kind": "event", "label": "دورة الجلسة", "curve": [[97, 760], [59, 565], [59, 265], [102, 86]], "off": "50%"}]});
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
      const container = document.getElementById('0718kimik3opencodecoding-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0718kimik3opencodecoding-1';
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

الفرق عن النهج المعتاد واضح. وكيل الواجهة الرسومية لمزوّد ما يأتي بالنموذج والأداة كحزمة واحدة. أما
وكيل مفتوح المصدر مثل OpenCode فيثبّت الأداة ويبدّل المزوّد فقط. نموذج ذاتي الاستضافة بالأمس، و Kimi
K3 اليوم، ونموذج آخر غدًا، عبر واجهة الأوامر نفسها.

## التثبيت والتكامل

تحققنا من مسار التثبيت والاتصال عمليًا في بيئة معزولة. الأوامر والإصدارات أدناه قيم فعلية التقطناها
أثناء إعادة الإنتاج.

أولًا ثبّت OpenCode. نجح التثبيت العام عبر npm فورًا.

```bash
npm install -g opencode-ai
opencode --version
# 1.18.3
```

فحصنا سطح الأوامر الذي توفّره الأداة المثبّتة. من تشغيل واجهة TUI إلى التنفيذ بلا واجهة، وإدارة
المزوّدين، وسرد النماذج، وإدارة خوادم MCP، فهي تغطي ما يحتاجه وكيل البرمجة.

```bash
opencode --help
# opencode [project]        start opencode tui              [default]
# opencode run [message..]  run opencode with a message
# opencode providers        manage AI providers and credentials   [aliases: auth]
# opencode models [provider]  list all available models
# opencode mcp              manage MCP (Model Context Protocol) servers
# opencode agent            manage agents
# opencode serve            starts a headless opencode server
```

تتولّى الأوامر الفرعية `opencode auth` مصادقة المزوّد.

```bash
opencode auth --help
# opencode auth list    list providers and credentials   [aliases: ls]
# opencode auth login   log in to a provider
# opencode auth logout  log out from a configured provider
```

ترتيب ربط Kimi K3 كالتالي، وفق دليل OpenCode الرسمي من Moonshot AI.

1. أنشئ مفتاح API على منصة Kimi المفتوحة واحتفظ به بشكل خاص.
2. شغّل `opencode auth login`، واختر **Moonshot AI** كمزوّد، ثم أدخل مفتاح API.
3. داخل OpenCode، استخدم `/models` (أو `opencode models moonshotai` في الصدفة) لاختيار **Kimi K3**.
4. تحقق من الاتصال بمهمة منخفضة المخاطر.

```bash
opencode run "اشرح بنية مجلدات هذا المشروع وأوصِ بأول ثلاثة ملفات ينبغي قراءتها."
```

حقيقة تستحق التثبيت: بعد التثبيت مباشرةً، لم يتضمن كتالوج النماذج الافتراضي مزوّد Moonshot. أثناء
إعادة الإنتاج، أعادت تصفية `opencode models` بحثًا عن Moonshot/Kimi نتيجة فارغة، ما يعني أنه يجب
إضافة المزوّد صراحةً عبر `auth login` قبل ظهوره في الكتالوج. لذا فالخطوة 2 أعلاه ليست اختيارية بل
إلزامية.

## النتائج الفعلية

نفصل القيم التي التقطناها مباشرةً عن الأرقام المنشورة للنموذج. تثبيت الأداة ومسار الاتصال قِيَما
مُقاسة عمليًا؛ أما درجات القياس فهي أرقام مُبلَّغ عنها من Moonshot وطرف ثالث (Artificial Analysis).

النتائج المقاسة مباشرةً:

- نجح تثبيت OpenCode، الإصدار 1.18.3 (npm `opencode-ai`، رمز الخروج 0).
- تأكدنا أن الأداة توفّر مصادقة المزوّد (`auth`)، وسرد النماذج (`models`)، والتنفيذ بلا واجهة
  (`run`)، وإدارة MCP (`mcp`)، وإدارة الوكلاء (`agent`).
- بعد التثبيت مباشرةً، لم يتضمن الكتالوج الافتراضي مزوّد Moonshot، فوجب إضافته صراحةً عبر `auth login`.

لم نشغّل استدلال Kimi K3 المباشر. يتطلب استدعاء Kimi K3 مفتاح API مدفوعًا برصيد (لا يمكن استخدام
قسائم التحقق للمستخدمين الجدد مع K3)، ولم يتوفّر مثل هذا المفتاح في بيئة إعادة الإنتاج. لذا نرسم الحد
عند "تثبيت واتصال مُقاسان، وجودة توليد الشيفرة الفعلية مُقتبسة من أرقام منشورة". لا نختلق أرقامًا لم نرصدها.

المقاييس المنشورة للنموذج أدناه. هذه الدرجات أرقام مُبلَّغ عنها وفق Artificial Analysis، ولأن الأوزان
لم تُنشر بالكامل بعد، فإنها لم تُتحقق عبر إعادة إنتاج مستقلة.

| المقياس | Kimi K3 | الترتيب | النماذج الأعلى / للمقارنة |
|---|---|---|---|
| GDPval-AA v2 | 1,687 | الثالث | Fable 5 Max 1,815 · GPT-5.6 Sol Max 1,747.8 · (Opus 4.8 1,600) |
| AA-Briefcase | 1,527 | الثاني | Fable 5 Max 1,587 · GPT-5.6 Sol Max 1,495 |

بقراءة الأرقام كما هي، يقع Kimi K3 في النطاق أسفل النماذج الحدّية العليا مباشرةً. واحتلاله المركز
الثاني في AA-Briefcase، الذي يقيس العمل المعرفي طويل الأمد، إشارة إلى أنه صالح لمهام الوكلاء متعددة
الخطوات مثل البرمجة. مع ذلك، هذه أرقام مُبلَّغ عنها، ويبقى الإحساس الفعلي في سير عمل برمجي حقيقيًا
أدق عند التحقق منه على قاعدة شيفرتك الخاصة.

## دلالات على منصة ThakiCloud

يمسّ هذا الاقتران عدستَي منتجَي ThakiCloud معًا. الأولى عدسة منصة الوكلاء، والثانية عدسة خدمة البنية
التحتية.

**عدسة Paxis (الوكلاء والأدوات والنماذج القابلة للاستبدال).** Paxis هو مستوى التحكم في سحابة ThakiCloud
الأصلية للوكلاء (Agent-Native Cloud)، ويعامل Skills و Tools و Policies و Audit Logs كموارد من الدرجة
الأولى. البنية التي يظهرها OpenCode، أي "ثبّت الأداة وبدّل المزوّد"، تتطابق تمامًا مع فلسفة تصميم Paxis.
في Paxis، يختار وكيل البرمجة من أكثر من 960 مهارة عبر BM25، ويشغّلها في صناديق رمل معزولة، ويمرّر كل
إجراء عبر بوابات السياسات وسجلات التدقيق. اربط نموذجًا مفتوح الأوزان مثل Kimi K3 كمزوّد، وستتمكن من
تبديل دماغ الوكيل حسب التكلفة والأداء مع الحفاظ على عزل التنفيذ والتدقيق. كما أن احتواء OpenCode على
إدارة مدمجة لخوادم MCP (`opencode mcp`) يتصل بطبيعة الحال بمعاملة Paxis لموصّلات MCP كموارد من الدرجة الأولى.

**عدسة ai-platform (خدمة نموذج بحجم 2.8T).** مفتوح الأوزان يعني أن على أحدهم خدمة هذا النموذج على وحدات
GPU حقيقية. نموذج MoE بحجم 2.8 تريليون معامل يُفعّل 16 خبيرًا فقط لكل رمز، فالمعاملات النشطة أصغر بكثير
من الإجمالي، لكن البنية ما تزال تتطلب إبقاء جميع الخبراء الـ896 في الذاكرة، لذا فعتبة الخدمة المحلية
ليست منخفضة. هنا تجيب منصة ThakiCloud ai-platform عن السؤال. عندما تجتمع جدولة GPU المبنية على K8s و
Kueue، وخدمة vLLM/SGLang، والتكميم (quantization) لتوفير الذاكرة، يمكن تشغيل نماذج مفتوحة كبيرة كهذه
اقتصاديًا في بيئة متعددة المستأجرين. وحين تصدر الأوزان في 27 يوليو، يمكن مقارنة منحنى تكلفة الاستضافة
الذاتية مقابل استدعاءات API فعليًا. وتكلفة الخدمة المنخفضة تُترجَم إلى اقتصاديات الوكلاء، وهذا بدوره
يخفّض تكلفة تشغيل الوكلاء العاملين على Paxis. كلتا العدستين تشيران إلى الاتجاه نفسه.

## الحدود والاعتراضات

نذكر بعض الاعتراضات الرصينة معًا.

أولًا، درجات القياس تختلف عن الإحساس الفعلي بالبرمجة. المركز الثاني في AA-Briefcase لا يضمن "الأفضل على
قاعدة شيفرتي". فقد يكون النموذج الأعلى ترتيبًا أضعف في لغة أو إطار عمل أو عُرف داخلي بعينه، لذا يجب
التحقق من التبنّي على عملك الفعلي.

ثانيًا، تصل قياسات هذا المقال إلى التثبيت ومسار الاتصال. لم يُشغَّل استدلال Kimi K3 المباشر بسبب قيد
مفتاح API المدفوع. تبقى جودة التوليد الفعلية والكمون وتكلفة الرموز أمورًا عليك إعادة قياسها بمفتاحك الخاص.

ثالثًا، "مفتوح الأوزان" لا يعني "مجاني" أو "سهل التشغيل". حتى مع نشر الأوزان، فإن خدمة نموذج MoE بحجم
2.8T بثبات تتطلب موارد GPU كبيرة وكفاءة تشغيلية. ونقطة التعادل بين الاستضافة الذاتية واستدعاءات API
تعتمد على الاستخدام ومتطلبات الكمون.

رابعًا، تحتاج واجهة Kimi K3 إلى رصيد، ولا يمكن استخدام قسائم المستخدمين الجدد مع K3. لا تتوقع استخدامًا
مجانيًا غير محدود لنموذج من الطبقة العليا. ومع ذلك، فإن الحرية البنيوية في اختيار الأداة والنموذج بشكل
مستقل موقع أفضل على المدى الطويل من الارتباط بمزوّد واحد.

## المصادر

- [MarkTechPost, "Moonshot AI Releases Kimi K3: A 2.8 Trillion Parameter Open MoE Model With Kimi Delta Attention and 1M Context" (2026-07-16)](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
- [Fortune, "Moonshot's Kimi K3 pushes Chinese AI into Fable-level territory" (2026-07-16)](https://fortune.com/2026/07/16/moonshots-kimi-k3-pushes-chinese-ai-into-fable-level-territory/)
- [Artificial Analysis, صفحة نموذج "Kimi K3" (مصدر أرقام معياري GDPval-AA v2 و AA-Briefcase في هذا المقال)](https://artificialanalysis.ai/models/kimi-k3)
- [Kimi API Platform, "Use Kimi Models in OpenCode"](https://platform.kimi.ai/docs/guide/open-code)
- [OpenCode (sst/opencode), إصدار v1.18.3](https://github.com/sst/opencode)
- [Simon Willison, "Kimi K3, and what we can still learn from the pelican benchmark" (2026-07-16)](https://simonwillison.net/2026/Jul/16/kimi-k3/)
- VentureBeat, "China's Moonshot AI releases Kimi K3, the largest open-source model ever" (المقال موجود، لكن لم يتم التحقق من استجابة الرابط في هذه الجلسة)
- OpenCode 1.18.3 (`npm install -g opencode-ai`): الأوامر والإصدار قيم إعادة إنتاج مُلتقطة مباشرةً
