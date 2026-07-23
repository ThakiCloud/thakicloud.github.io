---
title: "اختبار تطبيقات iOS عبر المتصفح على Mac سحابي بدون واجهة رسومية: serve-sim"
seo_title: "محاكي iOS عبر الويب مع serve-sim للتطوير بدون واجهة - Thaki Cloud"
seo_description: "serve-sim، الذي طوره Evan Bacon أحد مطوري نواة Expo، يبث شاشة محاكي iOS إلى المتصفح ويتيح للوكلاء التحكم فيها عبر سطر الأوامر. نستعرض في هذا المقال سير العمل الذي يمكّن وكلاء البرمجة بالذكاء الاصطناعي من بناء تطبيقات iOS واختبارها مباشرة على Mac سحابي بدون واجهة رسومية، وما يعنيه ذلك لمنصة Paxis للوكلاء وبنية التطوير بدون واجهة لدى ThakiCloud."
excerpt: "عند وضع Mac Mini في السحابة، ينعدم وجود واجهة رسومية تتيح رؤية محاكي iOS. يبث serve-sim الإطارات المرئية للمحاكي إلى المتصفح، ويفتح أيضاً قناة تحكم عبر WebSocket، مما يتيح لوكلاء البرمجة بالذكاء الاصطناعي بناء تطبيقات iOS والتفاعل معها واختبارها فعلياً في بيئة بدون واجهة رسومية."
date: 2026-07-11
tags:
  - ios-simulator
  - agent-skills
  - developer-tools
  - headless
  - claude-code
  - expo
categories:
  - dev
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/serve-sim-ios-simulator-web/"
---

عندما تطلب من وكيل برمجة يعمل بالذكاء الاصطناعي بناء تطبيق iOS، يصطدم بحائط أساسي. يستطيع الوكيل كتابة الكود بل وحتى بناء المشروع، لكنه لا يستطيع رؤية ما يحدث فعلاً على الشاشة. وتتفاقم المشكلة أكثر عندما تكون بيئة التطوير مستضافة على جهاز Mac Mini في السحابة، لأن نافذة محاكي Xcode نفسها لا تظهر أصلاً على خادم بدون واجهة رسومية (headless).

جاء [serve-sim](https://github.com/EvanBacon/serve-sim)، الذي طوره Evan Bacon من فريق نواة Expo، ليواجه هذا الحائط مباشرة. وقد ذاع صيت هذه الأداة فعلياً عندما قدّمها المطور المستقل levelsio قائلاً إنها "تتيح رؤية تطبيق iOS الذي بناه Claude Code على Mac Mini في السحابة مباشرة عبر المتصفح في الوقت الفعلي". وشعار serve-sim بسيط: "أمر `npx serve` الخاص بمحاكيات آبل".

## نظرة عامة

ما يجعل serve-sim مثيراً للاهتمام هو أنه ليس مجرد أداة لعكس الشاشة. فهذه الأداة تفتح قناتين في آن واحد: الأولى هي تدفق فيديو يرسل شاشة المحاكي إلى المتصفح، والثانية قناة تحكم تتيح للمتصفح أو للوكيل التفاعل مع المحاكي. بعبارة أخرى، تجعل "المشاهدة" و"التحكم" ممكنتين عن بُعد في آن معاً.

أهمية هذا المزيج تكمن في أنه يُكمل حلقة التطوير الخاصة بوكلاء البرمجة بالذكاء الاصطناعي. يصبح بإمكان الوكيل تعديل الكود، وبناء المشروع، وتشغيله، ثم رؤية النتيجة على الشاشة، والضغط على الأزرار للانتقال إلى الخطوة التالية، وتكرار هذه الدورة الكاملة دون تدخل بشري. وهذا يتقاطع تماماً مع توجه Paxis، السحابة المخصصة للوكلاء (Agent-Native Cloud) لدى ThakiCloud، القائم على فكرة "أن ينفذ الوكيل عملاً فعلياً في بيئة معزولة"، مما يجعل من المفيد دراسة كيفية تنفيذ أداة مفتوحة المصدر واحدة لهذا النوع من سير العمل.

![صورة تجريدية لشاشة هاتف ذكي على خادم سحابي بدون واجهة رسومية تتحول إلى جسيمات ضوئية تتدفق عبر الشبكة إلى نافذة متصفح]({{ '/assets/images/serve-sim-ios-simulator-web-hero.png' | relative_url }})
*تصوير لبنية تحوّل شاشة المحاكي على خادم بدون واجهة رسومية إلى تدفق يصل إلى متصفح بعيد.*

## ما هو serve-sim

آلية عمل serve-sim أبسط وأذكى مما قد يبدو للوهلة الأولى. لا حاجة لتثبيت إضافة (plugin) خاصة في Xcode ولا لزرع كود قياس داخل التطبيق. بدلاً من ذلك، يشغّل serve-sim عملية مساعدة صغيرة مكتوبة بلغة Swift تلتقط الإطارات المرئية لمحاكي iOS المُقلع مسبقاً عبر واجهة `simctl io` التي توفرها آبل.

تُعرض الشاشة الملتقطة عبر مسارين. أولاً، تدفق MJPEG يرسل فيديو إلى المتصفح بمعدل يصل إلى 60 إطاراً في الثانية. ثانياً، تُفتح قناة تحكم عبر WebSocket تتيح للمتصفح إرسال مدخلات مثل النقر والإيماءات إلى المحاكي. وفوق ذلك، تُركّب واجهة معاينة مبنية بـ React تتيح للمستخدم التفاعل مع التطبيق في المتصفح وكأنه جهاز فعلي.

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
<div class="d3-arch" data-arch-root id="1servesimiossimulatorweb-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 303, "height": 954, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 49, "y": 24, "w": 142, "h": 46, "title": "محاكي iOS مُقلَع"}, {"id": "B", "x": 24, "y": 148, "w": 191, "h": 46, "title": "عملية مساعدة بلغة Swift"}, {"id": "C", "x": 24, "y": 272, "w": 191, "h": 62, "title": ["التقاط الإطارات المرئية", "عبر simctl io"]}, {"id": "D", "x": 112, "y": 412, "w": 142, "h": 62, "title": ["تدفق فيديو MJPEG", "حتى 60 FPS"]}, {"id": "E", "x": 63, "y": 706, "w": 191, "h": 46, "title": "قناة تحكم عبر WebSocket"}, {"id": "F", "x": 94, "y": 552, "w": 177, "h": 62, "title": ["واجهة معاينة React في", "المتصفح"]}, {"id": "G", "x": 73, "y": 844, "w": 170, "h": 78, "title": ["سطر أوامر الوكيل", "نقر، إيماءات، دوران،", "كاميرا"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [120, 70, 120, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [120, 194, 120, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[147, 334], [183, 373], [183, 373], [183, 412]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[92, 334], [57, 443], [57, 583], [124, 706]]}, {"src": "D", "dst": "F", "kind": "data", "line": [183, 474, 183, 552]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[158, 706], [158, 660], [158, 660], [173, 614]]}, {"src": "E", "dst": "G", "kind": "data", "line": [158, 752, 158, 844]}, {"src": "F", "dst": "E", "kind": "event", "label": "تحكم بشري", "curve": [[192, 614], [207, 660], [207, 660], [174, 706]], "off": "50%"}, {"src": "G", "dst": "E", "kind": "event", "label": "تحكم الوكيل", "curve": [[133, 844], [103, 798], [103, 798], [140, 752]], "off": "50%"}]});
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
      const container = document.getElementById('1servesimiossimulatorweb-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '1servesimiossimulatorweb-1';
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

الجوهر هنا هو أن الأداة تعمل مع "أي محاكي مُقلَع" أياً كان. لا حاجة لتعديل التطبيق، فيمكن ربطها مباشرة بمشروع قائم بالفعل. كذلك، تنقل الأداة سجلات المحاكي إلى المتصفح، مما يتيح لأدوات MCP من فئة browser-use قراءة تلك السجلات لتقييم الحالة. وتوجد أيضاً ميزة عملية تتيح إفلات ملفات فيديو أو صور في نافذة المتصفح لتُضاف كملفات إلى جهاز المحاكي.

## التثبيت والاستخدام

عتبة الدخول إلى serve-sim منخفضة. يكفي سطر واحد على جهاز Mac يحتوي على Node.js.

```bash
npx serve-sim
```

بعد التشغيل، يمكن مشاهدة المعاينة محلياً على `http://localhost:3200`. تدعم الأداة ثلاثة أنماط استخدام: محلياً، أو عبر الشبكة المحلية (LAN) من جهاز آخر على نفس الشبكة، أو على جهاز Mac بعيد مع نفق (tunnel) يتيح الوصول من أي مكان. حالة levelsio هي النمط الثالث تحديداً، حيث يعمل serve-sim على Mac Mini سحابي بدون واجهة رسومية بينما تجري المشاهدة عبر متصفح بعيد.

يُقدَّم دمج الوكلاء عبر مهارة وكيل (Agent Skill) منفصلة. هذه المهارة، الموجودة في `skills/serve-sim` ضمن المستودع، تعلّم Claude Code وCursor وCodex CLI وGemini CLI وأي مضيف آخر يطبّق معيار Agent Skills المفتوح كيفية التحكم في المحاكي عبر سطر الأوامر. وتشمل هذه القدرات النقر والإيماءات وأزرار الأجهزة الفعلية ودوران الشاشة وحقن مدخلات الكاميرا، إضافة إلى تمرير التدفق إلى نافذة المعاينة الخاصة بالمضيف.

## ملاحظة حول إعادة الإنتاج

بيئة التنفيذ التي كُتب فيها هذا المقال هي جلسة معالجة دفعية بدون واجهة رسومية، حيث تشغيل Node.js محظور بموجب السياسة المتبعة، لذا لم يتسنَّ تشغيل `npx serve-sim` مباشرة والتقاط الشاشة فعلياً. وعليه، فإن الأوامر ووصف السلوك في هذا المقال مستندة إلى ما ورد في ملف README الخاص بالمستودع والمواد التعريفية الرسمية، دون اختلاق أي أرقام قياس أداء. يُنصح بالتحقق من مشهد بث المحاكي الفعلي وزمن الاستجابة الحقيقي عبر تشغيل الأمر أعلاه مباشرة في بيئة macOS مع محاكي Xcode مُقلَع.

## دلالات على منتجات ThakiCloud

يبدو serve-sim للوهلة الأولى أداة موجهة لمطوري iOS، لكن خلفها يكمن تيار أوسع هو التطوير المصمم أصلاً للوكلاء (agent-native development).

**عدسة Paxis (التطوير المصمم للوكلاء).** Paxis من ThakiCloud هي مستوى تحكم لسحابة مخصصة للوكلاء يشغّل المهارات في صناديق رملية معزولة ويمرر كل سلوك عبر بوابات سياسات وسجلات تدقيق. ومعيار Agent Skills المفتوح الذي يعتمده serve-sim هو نفس نموذج العقد الذي تتعامل معه بنية مهارات Paxis. فكرة أن تقدّم مهارة واحدة قدرة "النقر على المحاكي وتدويره وقراءة شاشته" لعدة مضيفي وكلاء مختلفين تسير في نفس اتجاه بنية Paxis التي تختار أكثر من 960 مهارة عبر خوارزمية BM25 وتنفذها في عزل. وبشكل خاص، فإن أعباء العمل التي يتحكم فيها الوكيل فعلياً في واجهة مستخدم حقيقية، كما في قناة التحكم لدى serve-sim، لا يمكن رفعها بأمان إلى بيئة الإنتاج إلا إذا مرّ ذلك التحكم عبر بوابة سياسات وسُجّل في سجل تدقيق. إذا كان serve-sim يقدّم "القدرة"، فإن Paxis تقدّم طبقة "الضبط الآمن" لتلك القدرة.

**عدسة ai-platform (بنية التنفيذ بدون واجهة رسومية).** تكمن الجاذبية الحقيقية لـ serve-sim في عمله على جهاز Mac بعيد بدون واجهة رسومية. وفكرة البناء والبث على خادم بدون واجهة رسومية تشبه فلسفياً الطريقة التي تجدول بها منصة ai-platform من ThakiCloud أعباء العمل وتنفذها على Kubernetes دون الحاجة إلى واجهة رسومية. وأي خط أنابيب (pipeline) يُلحق فيه مشغّل macOS المطلوب لبناء تطبيقات iOS عند الطلب، يبني الوكيل عليه ويختبر تلقائياً، ثم يُبث النتيجة فقط إلى المستخدم البشري، يمكن أن يمتد إلى ما هو أبعد من التكامل المستمر (CI) نحو "ضمان جودة يقوده الوكيل". وهذه بنية تجعل فيها البنية التحتية للتنفيذ بدون واجهة رسومية منخفضة التكلفة (ai-platform) ركيزة تدعم جدوى أتمتة الوكلاء اقتصادياً (Paxis).

## القيود والحجج المضادة

هناك عدة نقاط ينبغي تناولها بموضوعية.

أولاً، يستهدف serve-sim المحاكي وليس الجهاز الفعلي. وبما أنه محاكٍ لا جهاز مادي حقيقي، تبقى المشكلات التي تظهر فقط على الأجهزة الفعلية، كالكاميرا والحساسات وخصائص الأداء، خارج نطاق الاكتشاف. ويبقى القيد القديم قائماً: نجاح الاختبار على المحاكي لا يضمن نجاحه على الجهاز الفعلي.

ثانياً، بث MJPEG بسيط ومتوافق على نطاق واسع، لكن كفاءة ضغطه ليست عالية. فبث فيديو عالي الجودة بمعدل 60 إطاراً في الثانية باستمرار عبر نفق بعيد قد يجعل عرض النطاق الترددي وزمن الاستجابة عنق زجاجة. وفي اختبارات الإيماءات التي تتطلب سرعة استجابة، ينعكس زمن الرحلة عبر الشبكة مباشرة كتأخير في التحكم.

ثالثاً، إتاحة "الرؤية والتحكم" للوكيل شيء، ودقة قراره شيء آخر تماماً. يظل احتمال أن يُسيء الوكيل تفسير التدفق ويضغط على زر خاطئ قائماً، وهذه بالتحديد هي النقطة التي تحتاج إلى بوابة سياسات ومراجعة بشرية. فكلما فتحت الأداة مزيداً من القدرات، ازدادت أهمية الطبقة التي تضبط تلك القدرات.

مع ذلك، فإن اتجاه serve-sim واضح. لقد أرسى جسراً عملياً حقيقياً للانتقال من "مرحلة يكتفي فيها الوكيل بكتابة الكود" إلى "مرحلة يبني فيها الوكيل ويشغّل ويتحكم مباشرة في الشاشة للتحقق". وأي فريق يريد تطوير تطبيقات جوّال بواسطة وكلاء ذكاء اصطناعي على سحابة بدون واجهة رسومية يمكنه فتح هذا العالم فوراً بسطر واحد هو `npx serve-sim`.

## المصادر

- Evan Bacon. "serve-sim: The `npx serve` of Apple Simulators." GitHub. <https://github.com/EvanBacon/serve-sim>
- @levelsio، تغريدة تعريفية بـ serve-sim. <https://x.com/levelsio/status/2075328941317886210>
