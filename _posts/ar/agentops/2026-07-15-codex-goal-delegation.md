---
title: "في المهام الصعبة، اجعله يكتب الهدف أولًا: أسلوب تفويض الأهداف في Codex"
excerpt: "شارك أحد المطورين نصيحة: حين تُسند إلى Codex هدفًا /goal صعبًا حقًا، اطلب منه أولًا أن يكتب الهدف بحيث يستطيع خيط آخر تحقيقه. يبدو الأمر لعبًا بالكلمات، لكنه في جوهره نمط تشغيل فعلي للوكلاء: اجعل النموذج يكتب مواصفة هدف قابلة للتحقّق أولًا، ثم فوّض تلك المواصفة إلى خيط جديد. نستعرض كيف تعمل أهداف Codex فعليًا، ونقرأ الأسلوب من منظور Goal Mode وpge-loop وPaxis في ThakiCloud."
seo_title: "تفويض الأهداف في Codex: كتابة هدف قابل للتحقّق أولًا - Thaki Cloud"
seo_description: "نحلّل ميزة /goal في Codex وأسلوب الميتا-برومبت المتمثّل في كتابة هدف لخيط آخر. الأجزاء الثلاثة للهدف (نتيجة قابلة للقياس، سطح تحقّق، قيود)، وتطبيق ThakiCloud الفعلي في Goal Mode وpge-loop، ومنظور Paxis كسحابة أصيلة للوكلاء."
date: 2026-07-15
last_modified_at: 2026-07-15
lang: ar
tags:
  - ai-coding
  - agentic
  - codex
  - goal-mode
  - agentops
  - verification
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/codex-goal-delegation/"
categories:
  - agentops
---

## نظرة عامة

تنتشر بين المطورين الذين يعتمدون على وكلاء البرمجة نصيحة قصيرة. حين تُسند إلى Codex هدفًا `/goal` صعبًا فعلًا، لا تطلب منه أن يبدأ العمل فورًا. اطلب منه أولًا أن "يكتب الهدف بحيث يستطيع خيط آخر تحقيقه." للوهلة الأولى يبدو الأمر لعبًا بالكلمات. ما الفرق بين أن تطلب من النموذج كتابة الهدف وبين أن تطلب منه تحقيقه؟

غير أن هذه النصيحة تلمس بدقة أمرًا يعرفه كل من شغّل الوكلاء لفترة. المهام الصعبة تفشل غالبًا لا لأن النموذج ضعيف، بل لأن الهدف لم يُكتب أصلًا بصيغة تستطيع الآلة الحكم عليها. يظن الناس أن جملة مثل "نظّف عملية إعادة الهيكلة هذه" هدف، لكنها بالنسبة للوكيل تترك كل شيء فارغًا: متى يتوقف، وما الذي يُعدّ نجاحًا، وأين الحدّ. لذا يفكّك هذا المقال أسلوب "اجعله يكتب الهدف" قطعة قطعة، ويبيّن كيف تفرض ThakiCloud، التي تشغّل منصة AI/ML على Kubernetes ومنصة للوكلاء، المبدأ نفسه في الشيفرة.

## ما هي أهداف Codex

أولًا، لننظر عن قرب إلى المكوّن الخام. ميزة `/goal` في Codex تربط هدفًا دائمًا بالخيط. وفقًا لكتيّب OpenAI المنشور "Using Goals in Codex"، ينبغي وصف الهدف بثلاثة أجزاء: نتيجة قابلة للقياس، وسطح تحقّق يتيح تأكيد التقدّم، وقيود. متى توفّرت هذه الثلاثة صار الهدف هدفًا دائمًا مرتبطًا بالخيط.

الآلية مهمة. في نهاية كل دور، يفحص Codex الأدلة المتراكمة حتى الآن ويحكم بنفسه هل تحقّق الهدف. إن لم يتحقّق، وكان الهدف لا يزال نشطًا وضمن الميزانية، يواصل من أحدث حالة. باختصار، بدلًا من استجابة واحدة، يكرّر الملاحظة والحكم حتى يتحقّق الهدف بوصفه شرط إنهاء. جاذبية الميزة أن مهمة طويلة الأمد يمكن أن تتحوّل إلى سير عمل من نوع "اضبطه وانسه."

النقطة الجوهرية هنا أن جودة الهدف تحسم كل شيء. إن كان سطح التحقّق ضبابيًا لم يستطع Codex تحديد متى يتوقف؛ وبلا قيود يتجاوز نطاقه ويمسّ ملفات لا صلة لها؛ وبلا نتيجة قابلة للقياس يصلح ملفًا واحدًا ثم يعلن أنه انتهى. كتابة هدف جيّد مهارة قائمة بذاتها إذًا، وحين تنقص هذه المهارة تنهار المهام الصعبة.

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
<div class="d3-arch" data-arch-root id="60715codexgoaldelegation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 773, "height": 834, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 292, "y": 24, "w": 128, "h": 46, "title": "فكرة مهمة صعبة"}, {"id": "B", "x": 262, "y": 148, "w": 188, "h": 68, "title": ["هل الهدف بصيغة", "قابلة للتحقّق آليًا؟"]}, {"id": "C", "x": 585, "y": 308, "w": 156, "h": 62, "title": ["حلقة تدور بلا طائل", "أو إنهاء مبكر"]}, {"id": "D", "x": 374, "y": 316, "w": 156, "h": 46, "title": "نتيجة قابلة للقياس"}, {"id": "E", "x": 199, "y": 316, "w": 120, "h": 46, "title": "سطح التحقّق"}, {"id": "F", "x": 24, "y": 316, "w": 120, "h": 46, "title": "القيود"}, {"id": "G", "x": 199, "y": 448, "w": 120, "h": 62, "title": ["هدف دائم", "مرتبط بالخيط"]}, {"id": "H", "x": 171, "y": 602, "w": 177, "h": 62, "title": ["يحكم على نفسه بالأدلة", "عند نهاية كل دور"]}, {"id": "I", "x": 199, "y": 756, "w": 121, "h": 46, "title": "تقارب وانتهاء"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [356, 70, 356, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "لا", "curve": [[450, 206], [663, 262], [663, 262], [663, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "نعم", "curve": [[397, 216], [452, 262], [452, 262], [452, 316]], "off": "50%"}, {"src": "B", "dst": "E", "kind": "data", "label": "نعم", "curve": [[314, 216], [259, 262], [259, 262], [259, 316]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "label": "نعم", "curve": [[262, 210], [84, 262], [84, 262], [84, 316]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "curve": [[452, 362], [452, 409], [452, 409], [319, 457]]}, {"src": "E", "dst": "G", "kind": "data", "line": [259, 362, 259, 448]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[84, 362], [84, 409], [84, 409], [199, 455]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[278, 510], [307, 556], [307, 556], [278, 602]]}, {"src": "H", "dst": "G", "kind": "data", "label": "غير محقّق، ضمن الميزانية", "curve": [[240, 602], [211, 556], [211, 556], [240, 510]], "off": "50%"}, {"src": "H", "dst": "I", "kind": "data", "label": "محقّق", "line": [259, 664, 259, 756], "lx": 259, "ly": 706}]});
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
      const container = document.getElementById('60715codexgoaldelegation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '60715codexgoaldelegation-1';
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

## الأسلوب: "اكتب هدفًا لخيط آخر"

لنعد الآن إلى النصيحة. أمام مهمة صعبة، نادرًا ما يكتب المرء هدفًا جيّدًا من المحاولة الأولى. تحديد ما هي النتيجة القابلة للقياس، وما الذي سيتحقّق من التقدّم، وأي القيود يجب وضعها، هو بحدّ ذاته مهمة تصميم غير بسيطة. ما تقترحه هذه النصيحة هو تفويض ذلك التصميم إلى النموذج أولًا.

بشكل ملموس، يجري الأمر هكذا. يُطلب من الخيط الأول أن "يكتب هدفًا يمكّن خيطًا آخر من تحقيق هذه المهمة الصعبة ذاتيًا." النموذج لا ينجز العمل هنا. بل يفهم المهمة ويُنتج مواصفة هدف تبيّن ما هو النجاح، وكيف يُتحقّق منه، وأين الحدّ. يراجع الإنسان تلك المواصفة ويشحذها، ثم يُدخلها هدفًا في خيط جديد لتشغيل التنفيذ الفعلي. ينطلق خيط التنفيذ بشرط إنهاء محدّد جيدًا، فيكون أقل عرضة بكثير للحلقات التي تدور بلا طائل أو للإنهاء المبكر الموصوفَين آنفًا.

ينجح هذا الأسلوب لسببين. الأول أنه يفصل كتابة الهدف عن تحقيق الهدف. الأمران مختلفان في طبيعتهما. كتابة الهدف تدور حول فهم المشكلة على نطاق واسع وتثبيت معايير النجاح في اللغة؛ أما تحقيق الهدف فحفرٌ ضيّق نحو تلك المعايير. حين يحاول خيط واحد القيام بالأمرين معًا، يندفع إلى التنفيذ وهو لا يزال يقرّر معايير التحقّق، وينتهي به الأمر إلى تقييم نفسه بمعايير لم يضعها أصلًا. بالفصل، يركّز كل خيط على أمر واحد.

الثاني أنه يخلق نقطة مراجعة للإنسان. مواصفة الهدف التي يُنتجها النموذج قطعةٌ يستطيع الإنسان قراءتها وتحريرها قبل التنفيذ. إن كان سطح التحقّق ضعيفًا أمكن تعزيزه في هذه المرحلة؛ وإن كان النطاق واسعًا أمكن إضافة قيود. اكتشاف خطأ بعد بدء التنفيذ باهظ الثمن؛ والتقاطه في مرحلة مواصفة الهدف رخيص. بعبارة أخرى، هذا ليس حيلة برومبت بل أداة بنيوية تُدرج طبقة واحدة من المراجعة الرخيصة.

بالطبع ليس دواءً لكل داء. أطّرت إحدى نشرات المطورين هذا النهج بأنه يحوّل "مهمة من أربع ساعات إلى سير عمل من نوع اضبطه وانسه"، لكن ذلك انطباع عن حالة ناسبته، لا ضمان. حتى لو نجحت في جعل النموذج يكتب هدفًا جيّدًا، يبقى تقارب خيط التنفيذ نحوه مسألة منفصلة. لذا لا يؤتي الأسلوب ثماره إلا مقترنًا ببوابات التحقّق المذكورة أدناه.

## دلالات على منتجات ThakiCloud

ثمة سبب لألّا يبدو هذا الأسلوب غريبًا: تفرض ThakiCloud المبدأ نفسه فعلًا، لا بوصفه طلب برومبت بل انضباطًا في الشيفرة. وبما أن الموضوع تشغيل الوكلاء، نضع هنا منظور منصّتنا للوكلاء Paxis في المركز، مع ربطه ببنية ai-platform التحتية أسفلها.

Paxis هي سحابة ThakiCloud الأصيلة للوكلاء (Agent-Native Cloud)، مستوى تحكّم يعامل المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. بداخلها مُنفّذ يُدعى Goal Mode. حين ننشئ هدفًا في Goal Mode، كتبنا القواعد بحيث لا يمكن ترك `check_cmd` و`success_criteria` والميزانية فارغة. هذه الثلاثة تقابل تقريبًا واحدًا لواحد أجزاء هدف Codex الثلاثة: `success_criteria` هي النتيجة القابلة للقياس، و`check_cmd` هو سطح التحقّق الذي يحكم على التقدّم، والميزانية هي القيد. إن أُنشئ الهدف قشرةً فارغة، فمصمَّم ليفشل عند البوابة في التكرار الأول، فتضمن الشيفرة حالة "إن لم تكتب الهدف جيدًا فلن يبدأ أصلًا."

بنية التفويض المتمثّلة في "اكتب هدفًا لخيط آخر" موجودة داخلنا أيضًا. حين يصل طلب معقّد، يفكّكه الوكيل الرئيسي إلى مهام فرعية ويفوّض كلًّا منها إلى وكيل فرعي منفصل. مَن يفكّك ومَن ينفّذ منفصلان، وهذه هي الفكرة ذاتها لفصل هذا المقال بين خيط كتابة الهدف وخيط تنفيذ الهدف. التفكيك يحتاج حكمًا، فيتولّاه نموذج من طبقة أعلى؛ والتنفيذ عمل ضيّق، فيُرسَل إلى نموذج أرخص. من هنا يأتي مبدأ العمّال رخيصون والبوابات باهظة.

وفوق ذلك كله، لا ندمج أبدًا نتائج التوزّع دون تحقّق. مهما أحسنت كتابة الهدف وتفويضه، يجب أن تحكم على صحّة النتيجة مرحلةُ تحقّق منفصلة لا المُنفِّذ. تُحكَم مخرجات الشيفرة بتشغيل الاختبارات فعليًا وقراءة رمز الخروج؛ وتُصفّى مخرجات المحتوى أو الحكم بتصويت أغلبية من عدة مدقّقين بمنظورات مختلفة. جملة يقول فيها النموذج "يبدو أن هذا انتهى" لا يمكن أن تكون شرط إنهاء الحلقة. يبيّن هذا الانضباط كيف نصلّب سلوك هدف Codex "احكم على نفسك بالأدلة عند نهاية كل دور" إلى صيغة جديرة بالثقة.

وثمة ارتباط عبر عدسة البنية التحتية أيضًا. الحلقة التي تُقطّع الأهداف بدقّة وتشغّلها مع خطوات تحقّق تستهلك موارد الحوسبة باطّراد. ai-platform هي الطبقة التي توفّر جدولة GPU على Kubernetes وKueue، وخدمة vLLM، وعزل متعدّد المستأجرين، فتبني أرضية تستطيع فوقها هذه الحلقات الوكيلة أن تعمل بثمن رخيص وموثوقية. الخدمة منخفضة التكلفة تصنع اقتصاديات الوكلاء، وفوقها تصبح أهداف Paxis المفوَّضة وحلقات التحقّق قابلة للحياة عمليًا. العدستان تكمّلان إحداهما الأخرى.

## الحدود والحجج المضادة

كي لا نبالغ في تقدير هذا الأسلوب، لنأخذ الجانب الآخر.

أولًا، خطوة كتابة الهدف نفسها قد تفشل. إن أنتج النموذج هدفًا معقولًا لكنه غير قابل للتحقّق، انطلق خيط التنفيذ وهو لا يعرف ما الذي يُعدّ نجاحًا. ثمة حالات كثيرة يكون فيها كتابة الإنسان هدفًا قصيرًا ومتينًا مباشرةً أفضل. لذا يجب أن تمرّ مواصفة الهدف التي يكتبها النموذج بنقطة مراجعة بشرية، وتسليمها مباشرة إلى التنفيذ دون مراجعة هدرٌ لنقطة المراجعة الرخيصة التي كسبتها.

ثانيًا، هذا العبء غير مبرَّر لكل مهمة. كتابة الهدف نيابةً وتقسيم الخيوط في تصحيح ملف واحد أو سؤال سريع مبالغة. لا يؤتي هذا الأسلوب ثماره إلا في المهام الصعبة حيث يكون شرط الإنهاء ضبابيًا، والتشغيل طويلًا، والتنفيذ الذاتي ذا قيمة حقيقية. قواعدنا الداخلية ترسم الخطّ ذاته: استخدم أدوات الحلقة للتنفيذ التكراري أو العمل المتقارب فقط، ولا تفرضها على تعديلات لمرة واحدة.

ثالثًا، كلما طال التنفيذ الذاتي مال الناس أكثر إلى الثقة بالنتيجة والتوقّف عن المراجعة. راحة أنك فوّضت الهدف جيدًا هي الخطر نفسه. إن لم يُصفِّ المدقّق شيئًا، فليس ذلك إشارة إلى أن كل شيء نجح بل الأرجح إشارة إلى أن المدقّق معطّل. لذا يجب أن يفحص إنسان المخرجات الجوهرية بأخذ عيّنات دوريًا، وأن يُصمَّم المدقّقون ليصوّبوا نحو الدحض لا التأكيد.

خلاصة القول، "في المهام الصعبة، اكتب الهدف أولًا" ليست براعة برومبت بل نصيحة بنيوية بفصل كتابة الهدف عن تنفيذه، وإدراج نقطة مراجعة بينهما. إن كانت ميزة الهدف في Codex وضعت هذا في أيدي المطورين الأفراد، فإن ThakiCloud تفرض المبدأ نفسه على مستوى الفريق عبر Goal Mode في Paxis وحلقات التحقّق. أن تكون كتابة هدف جيّد هي معنى إدارة الوكيل جيّدًا لا يتغيّر مهما كانت الأداة.

## المصادر

- OpenAI Cookbook، ["Using Goals in Codex"](https://developers.openai.com/cookbook/examples/codex/using_goals_in_codex)
- التغريدة الأصلية: nickbaumann_، منشور نصيحة حول تفويض أهداف Codex (تعذر التحقق الآلي بسبب قيود جلب X/Twitter، المصدر غير موثق آليا)
