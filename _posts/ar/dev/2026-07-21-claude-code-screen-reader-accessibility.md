---
title: "وضع قارئ الشاشة في Claude Code: سطر واحد يفتح البرمجة الطرفية بالذكاء الاصطناعي للجميع"
excerpt: "أضاف Claude Code وضع قارئ الشاشة الذي يستبدل واجهة الطرفية البصرية بنص خطي بسيط. إليك ما يغيّره الأمر `claude --ax-screen-reader` فعليًا، وكيف يعمل، ولماذا تهمّ إمكانية الوصول لواجهات الوكلاء منصات مثل ThakiCloud."
date: 2026-07-21
tags:
  - ClaudeCode
  - Accessibility
  - ScreenReader
  - AICoding
  - DeveloperProductivity
  - Paxis
  - InclusiveDev
author_profile: true
toc: true
toc_label: وضع الوصول
published: true
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/claude-code-screen-reader-accessibility/"
---

![تصور تجريدي لطرفية أُعيد تنظيمها إلى تدفق خطي نظيف من النص]({{ '/assets/images/claude-code-screen-reader-accessibility-hero.png' | relative_url }})

## نظرة عامة

تطورت أدوات البرمجة الطرفية المعتمدة على الذكاء الاصطناعي في معظمها نحو ملء الشاشة بشكل جميل: مؤشرات دوران حية، فروقات ملوّنة، نوافذ أذونات محاطة بإطارات، ومؤشرات تقدّم تُعاد رسمتها مع تحرك المؤشر. بالنسبة للمستخدمين المبصرين، تُعدّ هذه الكثافة البصرية ميزة. أما بالنسبة للمطوّر الذي يقرأ الطرفية بقارئ شاشة بدلًا من عينيه فإنها تعمل بالعكس. الشاشة التي تُعاد رسمتها باستمرار تجعل من الصعب على قارئ الشاشة أن يقرر ما هو الجديد فعلًا، وتُقرأ الإطارات والحركات كضجيج بلا ترتيب.

يتصدى Claude Code الآن لهذه المشكلة مباشرة بوضع قارئ شاشة. سطر واحد، `claude --ax-screen-reader`، يحوّل واجهة الطرفية البصرية إلى نص خطي بسيط. فبدلًا من العرض المزخرف، يطبع أسطرًا موسومة بالترتيب حتى تستطيع قارئات الشاشة مثل VoiceOver وNVDA وJAWS القراءة من الأعلى إلى الأسفل بشكل طبيعي. يستعرض هذا المقال بالضبط ما يغيّره الوضع، وكيف يعمل، ولماذا تُعدّ إمكانية الوصول لواجهات الوكلاء مشكلة يجب أن تتبنّاها منظومة التطوير بأكملها الآن.

يبدو الأمر علمًا صغيرًا، لكن التغيير يوسّع الإجابة عن سؤال حقيقي: من يستطيع فعلًا استخدام وكيل ذكاء اصطناعي طرفي؟ إنه موضوع تصطدم به ThakiCloud باستمرار أثناء بناء سحابة أصلية للوكلاء، لذا نتناوله ليس كملاحظة عن ميزة فحسب، بل من منظور تصميم الواجهة.

## ما هو وضع قارئ الشاشة

تتعامل جلسة Claude Code العادية مع الطرفية كأنها لوحة رسم. تحرّك المؤشر، وتمسح الأسطر التي طبعتها بالفعل وتعيد رسمها، وتُظهر التقدّم كحركة حية. هذا مثالي لمن يمسح الشاشة بعينيه، لكنه أسوأ مُدخل ممكن لقارئ الشاشة. على قارئ الشاشة أن يقرر ما يقرأه في كل مرة تتغير فيها ذاكرة العرض، وحين تُعاد رسم الشاشة في كل إطار فإنه يميل إلى تكرار المحتوى نفسه أو إغفال المخرجات الجديدة المهمة تمامًا.

يغيّر وضع قارئ الشاشة نموذج العرض نفسه. فبدلًا من إعادة رسم الشاشة، يلحق المعلومات الجديدة كأسطر مفردة موسومة بالترتيب. عند تشغيل أداة مثلًا، تأتي علامات صريحة مثل طلب إذن، وإشعار بتشغيل الأداة، ونتيجة، كنص. يقرأ قارئ الشاشة هذا النص الخطي من الأعلى إلى الأسفل، فتكتمل متابعة المحادثة كاملة والموافقة على أذونات الأدوات ومراجعة المخرجات بالصوت وحده.

يوضّح المخطط أدناه بشكل مبسّط كيف يتفرّع مساران للعرض.

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
<div class="d3-arch" data-arch-root id="creenreaderaccessibility-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 648, "height": 682, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 232, "y": 24, "w": 170, "h": 46, "title": "بدء جلسة Claude Code"}, {"id": "B", "x": 230, "y": 148, "w": 174, "h": 68, "title": ["هل وضع قارئ الشاشة", "مُفعّل؟"]}, {"id": "C", "x": 450, "y": 308, "w": 156, "h": 62, "title": ["إعادة رسم اللوحة", "حركة المؤشر والعرض"]}, {"id": "D", "x": 135, "y": 308, "w": 149, "h": 62, "title": ["مخرجات نص خطي", "إلحاق أسطر موسومة"]}, {"id": "E", "x": 439, "y": 448, "w": 177, "h": 62, "title": ["معلومات عالية الكثافة", "للمستخدمين المبصرين"]}, {"id": "F", "x": 242, "y": 448, "w": 142, "h": 62, "title": ["قارئ الشاشة يقرأ", "من الأعلى للأسفل"]}, {"id": "G", "x": 218, "y": 588, "w": 191, "h": 62, "title": ["محادثة وموافقات ومراجعة", "تكتمل بالصوت"]}, {"id": "H", "x": 24, "y": 448, "w": 163, "h": 62, "title": ["جرس الطرفية", "عند الحاجة للانتباه"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [317, 70, 317, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "الوضع العادي", "curve": [[404, 215], [528, 262], [528, 262], [528, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "--ax-screen-reader", "curve": [[271, 216], [209, 262], [209, 262], [209, 308]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [528, 370, 528, 448]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[255, 370], [313, 409], [313, 409], [313, 448]]}, {"src": "F", "dst": "G", "kind": "data", "line": [313, 510, 313, 588]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[163, 370], [106, 409], [106, 409], [106, 448]]}]});
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
      const container = document.getElementById('creenreaderaccessibility-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'creenreaderaccessibility-1';
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

الفكرة ليست "إعطاء معلومات أقل" بل "إعطاء المعلومات نفسها كنص مرتّب." فبدلًا من تجريد المعنى، يزيل الزخرفة البصرية ويوفّر تدفّق مخرجات رتيبًا ومتوقّعًا يمكن لقارئ الشاشة الوثوق به.

## كيفية التفعيل وطريقة العمل

هناك طريقتان لتشغيل وضع قارئ الشاشة. لتفعيله لجلسة واحدة، مرّر العلم عند الإطلاق.

```bash
claude --ax-screen-reader
```

هذا العلم موجود فعلًا في Claude Code المثبّت. يُظهره فحص مخرجات المساعدة:

```bash
$ claude --help | grep ax-screen
  --ax-screen-reader                    Render screen-reader friendly output
```

لتطبيقه افتراضيًا على كل جلسة تُبدأ من الصدفة، اضبط متغيّر البيئة.

```bash
export CLAUDE_AX_SCREEN_READER=1
```

الآن تستخدم أي جلسة Claude Code تُفتح في تلك الصدفة مخرجات ملائمة لقارئ الشاشة دون علم منفصل. وفقًا للوثائق الرسمية، يعمل هذا الوضع على Claude Code الإصدار v2.1.181 وما بعده، وترفض الإصدارات الأقدم العلم `--ax-screen-reader` بخطأ.

هناك تفاصيل سلوكية مدروسة أيضًا. في وضع قارئ الشاشة، يقرع Claude Code جرس الطرفية عندما يحتاج انتباه المستخدم. وبالتحديد، يُقرع الجرس عند انتهاء أداة استغرقت أكثر من خمس ثوانٍ، للإشارة إلى انتهاء مهمة طويلة دون الحاجة للنظر إلى الشاشة. لا يستطيع مستخدم قارئ الشاشة التأكد بصريًا من وصول نتيجة بعد إطلاق أمر، لذا تُنشئ هذه الإشارة الصوتية إيقاعًا للتفاعل.

هناك إعداد منفصل للمستخدمين ضعاف البصر الذين يعتمدون على مكبّر شاشة.

```bash
export CLAUDE_CODE_ACCESSIBILITY=1
```

ضبط هذا يُبقي مؤشر الطرفية الأصلي ظاهرًا. تكبّر مكبّرات الشاشة مثل Zoom في macOS الشاشة باتباع موضع المؤشر، فإذا أخفت أداة المؤشر فقد المكبّر تركيزه. يكشف هذا الإعداد عن المؤشر ليتمكّن المكبّر من تتبّع موضع المستخدم بدقة.

إذًا ينقسم دعم إمكانية الوصول إلى ثلاثة مسارات: مخرجات نص خطي لقارئات الشاشة، وجرس طرفية للانتباه، وإبقاء المؤشر ظاهرًا للمكبّرات. يستهدف كل منها تقنية مساعِدة مختلفة ويمكن تفعيله بشكل مستقل عبر متغيّرات البيئة.

## لماذا يهمّ الآن

السبب الأول لأهمية هذه الميزة هو أن وكلاء الذكاء الاصطناعي الطرفيين يصبحون بسرعة أداة أساسية للمطوّرين. تحدث قراءة الشيفرة وإصلاحها وتشغيل الأوامر ومراجعة النتائج داخل هذه الأدوات بشكل متزايد. إذا غابت إمكانية الوصول عن هذا التدفق، فلن يتمكن المطوّرون المكفوفون أو ضعاف البصر من استخدام أدوات الإنتاجية نفسها التي يستخدمها زملاؤهم. مهما كانت الأداة قادرة، فإن ضيق باب الوصول إلى تلك القدرة يجعلها بالنسبة لبعض المطوّرين وكأنها غير موجودة.

السبب الثاني هو أن هذه الميزة انطلقت من طلب المجتمع. رُفعت في المستودع العام قضايا تطلب دعم NVDA وJAWS، وتحوّل ذلك الطلب إلى إصدار فعلي. غالبًا ما تُؤجَّل ميزات إمكانية الوصول إلى "لاحقًا"، لذا فإن حالة رفع طلب مستخدم للأولوية مرجع جيد. إمكانية الوصول ليست حاجة خاصة لفئة ضيقة؛ إنها محور تصميمي يحدّد نطاق الأشخاص الذين يمكنهم استخدام الأداة.

السبب الثالث أن هذا النهج يؤكد حقيقة قديمة: النص الخطي واجهة متينة. فتدفّق النص المرتّب والموسوم والمتوقّع ليس جيدًا لقارئات الشاشة فحسب. إنه سهل التسجيل، وسهل التمرير عبر الأنابيب، وسهل التحليل للأتمتة. ليس من قبيل الصدفة أن يكون وضع مخرجات بُني لإمكانية الوصول مواتيًا أيضًا للبرمجة النصية والتدقيق.

## الأثر على منتجات ThakiCloud

تُشغّل ThakiCloud سحابة أصلية للوكلاء تُسمى **Paxis**. تتعامل Paxis مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى: يختار مسخّر المهارات المهارة المناسبة من بين العديد ويشغّلها في صندوق رمل معزول، ممرّرًا كل إجراء عبر بوابات السياسة وسجلات التدقيق. وكلما اتسع السطح الذي يتفاعل فيه الوكيل مع الناس، أصبح سؤال ما إذا كان ذلك السطح "متاحًا للجميع" محورًا تصميميًا أساسيًا لا إضافةً.

الدرس من وضع قارئ الشاشة في Claude Code واضح. إمكانية الوصول لواجهة وكيل، بمعزل عن جعل الشاشة جميلة، تعتمد على قدرتك على تقديم المعلومات نفسها كنص خطي موسوم. منصة مثل Paxis تتعامل بالفعل مع سجلات التدقيق وبوابات السياسة كموارد من الدرجة الأولى في موقع بنيوي جيد هنا. فلأن كل إجراء للوكيل مُسجّل بالفعل كحدث موسوم، فإن إعادة تشكيل تدفّق الأحداث ذلك إلى مخرجات خطية يقرأها البشر ليس بناءً لخط عرض جديد كليًا بقدر ما هو إبراز لسجلات مُهيكلة تملكها أصلًا.

تُظهر هذه الحالة أيضًا أن المخرجات القابلة للوصول والمخرجات الملائمة للأتمتة تنبعان من الجذر نفسه. النص الذي يستطيع قارئ الشاشة قراءته هو أيضًا نص يستطيع جامع السجلات تحليله ومسار التدقيق حفظه. وبالنظر إلى مدى تأكيد ThakiCloud على قابلية الملاحظة والتدقيق في منصة الوكلاء لديها، فإن تصميم واجهة خطية قابلة للوصول إلى جانبهما يحقّق الهدفين معًا. فبدلًا من اعتبار الواجهة الغنية والنص القابل للوصول نقيضين، يعرض النهج الأفضل كلا التمثيلين على أساس مشترك هو تدفّق أحداث مُهيكل.

## القيود والاعتراضات

من المهم عدم المبالغة في تقدير هذه الميزة. وضع قارئ الشاشة خط بداية لإمكانية الوصول لا خط نهاية. فإخراج نص خطي لا يجعل كل تفاعل مريحًا تلقائيًا، وفهم كتلة شيفرة طويلة أو فرق معقّد بالصوت وحده يظل مهمة مرهقة إدراكيًا. ويظل استيعاب السياق الكامل لإعادة هيكلة كبيرة دون شاشة صعبًا حتى مع هذا الوضع.

تختلف أيضًا إشارة الانتباه المعتمدة على جرس الطرفية باختلاف البيئة. فبعض محاكيات الطرفية مضبوطة لتحويل الجرس إلى ومضة بصرية أو لإسكاته تمامًا، فقد لا تصل إشارة الجرس كما يُقصد. يحتاج المستخدمون إلى ضبط إعدادات طرفياتهم للحصول على أفضل تجربة.

أخيرًا، وجود وضع لإمكانية الوصول يختلف عن التحقّق منه جيدًا في الممارسة. يحتاج مطوّرون مكفوفون فعليون إلى استخدامه عبر قارئات شاشة وسير عمل متنوعة على مدى طويل، مراكمين ملاحظات قبل أن تظهر الحواف الخشنة وتُصقل. وبالنظر إلى أن هذا الوضع يعمل أول مرة في v2.1.181، فإنه لا يزال في بدايته، مع مجال واسع للتحسين. ومع ذلك، فإن تضمين ميزة كهذه في التوزيع الافتراضي هو بحد ذاته إشارة ذات معنى إلى توجّه للتعامل مع إمكانية الوصول الآن لا لاحقًا.

## المصادر

- وثائق إمكانية الوصول في Claude Code: [code.claude.com/docs/en/accessibility](https://code.claude.com/docs/en/accessibility)
- قضية طلب الميزة (NVDA/JAWS): [anthropics/claude-code #11002](https://github.com/anthropics/claude-code/issues/11002)
- المصدر الأصلي: [تغريدة @ClaudeDevs](https://x.com/hjguyhan/status/2079435394727416168)
