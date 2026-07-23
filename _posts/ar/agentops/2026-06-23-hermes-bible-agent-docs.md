---
title: "Hermes Bible: ابحث في وثائق Hermes Agent وسير العمل الواقعية في مكان واحد"
excerpt: "موقع مجتمعي غير رسمي يفهرس 169 صفحة من وثائق Hermes Agent من Nous Research إضافة إلى 28 سير عمل بناها المجتمع، وكلها قابلة للبحث بضغطة ⌘K واحدة. إليك ما يحتويه، وكيف يختلف عن الوثائق الرسمية، ولماذا يهمّ هذا النمط ThakiCloud التي تشغّل أكثر من 1000 مهارة وقاعدة."
seo_title: "تحليل Hermes Bible ونمط البحث في وثائق الوكلاء - Thaki Cloud"
seo_description: "Hermes Bible (hermesbible.com) موقع غير رسمي يفهرس 169 صفحة من وثائق Hermes Agent و28 سير عمل مجتمعيًا. نحلّل بنيته واختلافه عن الوثائق الرسمية وانعكاساته على بحث المهارات والقواعد في منصة ThakiCloud على نطاق واسع."
date: 2026-06-23
last_modified_at: 2026-06-23
tags:
  - ai-coding
  - hermes-agent
  - documentation
  - agent-workflows
  - knowledge-base
  - platform-engineering
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/hermes-bible-agent-docs/"
categories:
  - agentops
published: false
---

![تمثيل تجريدي لمكتبة معرفة مفهرسة]({{ '/assets/images/hermes-bible-agent-docs-hero.webp' | relative_url }})
*بحث مفهرس، مصوّر كعقد مستندات كثيرة تتقارب نحو نقطة مضيئة واحدة.*

## نظرة عامة

كلما ازداد إطار الوكيل قوة، ازدادت وثائقه عرقلةً على نحو متناقض. فمع نمو الميزات بسرعة تنتفخ صفحات الوثائق إلى المئات، ويصبح العثور على السطر الذي تحتاجه فعلًا أصعب فأصعب. وHermes Agent الذي أطلقته Nous Research في فبراير 2026 ليس استثناءً. فالوثائق الرسمية منظّمة جيدًا لكنها ضخمة، وفوق ذلك تتناثر المعرفة العملية التي يتشاركها المجتمع على X (تويتر) وغيره.

`Hermes Bible` (hermesbible.com) موقع مجتمعي غير رسمي يواجه هذه المشكلة مباشرة. يفهرس كل صفحة من وثائق Hermes Agent الرسمية إلى جانب سير عمل واقعية بناها المجتمع في مكان واحد، ويوفّر بحثًا نصيًا كاملًا بضغطة مفتاح واحدة. ويذكر الموقع نفسه بوضوح أنه "غير رسمي، من بناء المجتمع، وغير تابع لـ Nous Research".

تشغّل ThakiCloud منصة SaaS للذكاء الاصطناعي والتعلّم الآلي قائمة على Kubernetes، وتتعامل داخليًا مع أكثر من 1000 مهارة والعديد من قواعد التشغيل. لذا فإن سؤال "كيف تجعل كمًّا هائلًا من معرفة الوكلاء قابلًا للبحث" شاغل يومي لنا أيضًا. في هذه التدوينة نطّلع على ما يحتويه Hermes Bible وكيف، وكيف يختلف عن الوثائق الرسمية، وانعكاساته من منظور منصتنا.

## ما هذا الموقع

الوظيفة الأساسية لـ Hermes Bible هي الفهرسة والبحث. يحتوي الموقع على 169 صفحة من وثائق Hermes Agent مقسّمة إلى 10 أقسام: Getting Started (6 صفحات تشمل التثبيت والبدء السريع ومسار التعلّم)، وCore Features (45 صفحة تشمل نظرة عامة على الميزات والأدوات ونظام المهارات والمنسّق)، وMessaging Platforms (30 صفحة تشمل بوابة المراسلة وتيليجرام وديسكورد وسلاك)، وSecrets (صفحتان)، وSkills، وUsing Hermes (15 صفحة تشمل CLI وTUI والإعداد وتهيئة النماذج)، وغيرها.

يُستدعى البحث بضغطة ⌘K، وهو بحث نصي كامل غامض يمسح كل عنوان صفحة وقسم وترويسة. ووفقًا للموقع تظهر النتائج فور الكتابة دون تحميل أو انتظار. والهدف هو تجربة العثور على الموضع الدقيق في وثائق ضخمة خلال ثوانٍ بكلمة مفتاحية واحدة. يوضّح المخطط أدناه كيف يوحّد الموقع الوثائق الرسمية وسير عمل المجتمع في سطح بحث واحد.

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
<div class="d3-arch" data-arch-root id="0623hermesbibleagentdocs-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 661, "height": 538, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 331, "y": 24, "w": 212, "h": 62, "title": ["وثائق Hermes Agent الرسمية", "169 صفحة · 10 أقسام"]}, {"id": "C", "x": 217, "y": 164, "w": 198, "h": 62, "title": ["Hermes Bible", "فهرس نصي كامل (غير رسمي)"]}, {"id": "B", "x": 134, "y": 24, "w": 142, "h": 62, "title": ["سير عمل المجتمع", "28 سير عمل واقعي"]}, {"id": "D", "x": 431, "y": 304, "w": 198, "h": 62, "title": ["بحث نصي كامل غامض ⌘K", "عناوين · أقسام · ترويسات"]}, {"id": "E", "x": 435, "y": 444, "w": 191, "h": 62, "title": ["نتائج فورية فور الكتابة", "دون تحميل"]}, {"id": "F", "x": 256, "y": 304, "w": 120, "h": 62, "title": ["تصفّح /docs", "10 أقسام"]}, {"id": "G", "x": 24, "y": 304, "w": 177, "h": 62, "title": ["/flows", "البنى · اقتصاد الرموز"]}], "edges": [{"src": "A", "dst": "C", "kind": "data", "curve": [[437, 86], [437, 125], [437, 125], [370, 164]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[205, 86], [205, 125], [205, 125], [267, 164]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[411, 226], [530, 265], [530, 265], [530, 304]]}, {"src": "D", "dst": "E", "kind": "data", "line": [530, 366, 530, 444]}, {"src": "C", "dst": "F", "kind": "data", "line": [316, 226, 316, 304]}, {"src": "C", "dst": "G", "kind": "data", "curve": [[226, 226], [113, 265], [113, 265], [113, 304]]}]});
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
      const container = document.getElementById('0623hermesbibleagentdocs-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0623hermesbibleagentdocs-1';
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

عامل التمييز هو مكتبة Flows. فإلى جانب الوثائق الرسمية، تجمع 28 سير عمل واقعيًا لأتمتة متعددة الوكلاء بناها المجتمع فعلًا. ويُنظَّم كل سير عمل بحيث يمكنك البحث فيه ودراسته وتكييفه، شاملًا البنية الكاملة واقتصاد الرموز وأنماط التنسيق. فمثلًا تقدّم إحدى المقالات لوحة Hermes (localhost:9119) التي "لا يتحدث عنها أحد لكنني أفتحها كل يوم" بوصفها سطح تشغيل للحفاظ على صحة وكيل يعمل على مدار الساعة، وتغطي Sessions وMCP وSkills وCron وAnalytics وLogs وSystem. وأخرى بعنوان "المستويات الخمسة عشر لاستخدام Hermes Agent" تعرض كل شيء من أول موجّه بضربة واحدة إلى أتمتة عمل تجاري عبر ملفات متعددة، مع اقتصاد الرموز، وتذكر أنها جرى التحقق منها مقابل Hermes Agent v0.17.0.

للمرجع، Hermes Agent نفسه مشروع برخصة MIT من Nous Research، يُظهر نحو 200 ألف نجمة على GitHub و35.7 ألف تفريعة وأكثر من 12 ألف إيداع حتى كتابة هذه السطور. ويعلن عن "حلقة تعلّم مغلقة" يصنع فيها الوكيل مهارات من التجربة ويحسّنها أثناء الاستخدام ويبني نموذجًا للمستخدم عبر الجلسات. ويمكن النظر إلى Hermes Bible بوصفه استجابة المجتمع لمواكبة هذا المشروع السريع التطوّر.

## انعكاسات من منظور منصة ThakiCloud

النظر إلى Hermes Bible لا كموقع بحث فحسب بل كنمط يجعله درسًا مباشرًا لنا. تشغّل ThakiCloud داخليًا أكثر من 1000 مهارة وقاعدة تشغيل، وهي بالضبط المشكلة نفسها لـ "قابلية بحث المعرفة الهائلة" التي تواجهها وثائق Hermes Agent. وفي الواقع تمتلك منصتنا بالفعل بوابة بحث مهارات قائمة على BM25 تُبرز المرشحين في كل دورة عمل. ويوضّح بحث ⌘K النصي الفوري في Hermes Bible جيدًا، من جانب تجربة المستخدم، الطرح نفسه القائل إنه "كلما نمت المعرفة، صار البحث إنتاجية".

مفهوم Flows مثير للاهتمام بوجه خاص. فإذا كانت الوثائق الرسمية تشرح الميزات، فإن Flows تتشارك وصفات عملية تنسج تلك الميزات معًا، مكتملة بالبنية واقتصاد الرموز. وهذه هي الفكرة نفسها لـ ThakiCloud في معاملة المهارات والقواعد بوصفها "منتجات قدرة مغلّفة مع حالات الفشل والمزالق والهياكل المتحقَّق منها". فحين تراكم المعرفة كسير عمل قابل لإعادة الاستخدام يربط المدخل والمعالجة والمخرج والتعافي من الأخطاء بدلًا من موجّهات مفردة، تتضاعف قيمة البحث والمشاركة أخيرًا.

ثمة نقطة تماس تشغيلية أيضًا. فكما تجمع لوحة Hermes بين Sessions وCron وSkills وAnalytics وLogs في شاشة واحدة لإدارة وكيل يعمل على مدار الساعة، نصمّم نحن كذلك التشغيل نحو جعل الحلقات غير المراقَبة والمهام المجدولة مرئية عبر سجلّ مركزي. ففي نظام وكلاء سريع التطوّر، تُعدّ رؤية "ما الذي يعمل الآن وما الذي يقرؤه ويكتبه" بنظرة واحدة شرطًا أساسيًا للتشغيل المستقر.

## القيود والاعتراضات

أوضح القيود أنه غير رسمي. فـ Hermes Bible مشروع مجتمعي غير تابع لـ Nous Research، لذا لا ضمان بأن المحتوى المفهرس يطابق دائمًا أحدث الوثائق الرسمية. وHermes Agent مشروع سريع الحركة بأكثر من 12 ألف إيداع. والفهرس غير الرسمي يتأخّر بطبيعته، وخاصة في مجالات مثل الإعداد الحسّاس أمنيًا أو إدارة الأسرار يجب أن تعامل الوثائق الرسمية بوصفها المرجع النهائي.

ثانيًا، عليك مراعاة أن الوثائق الرسمية توفّر بالفعل نقاط دخول صديقة للآلة. إذ تقدّم وثائق Hermes Agent الرسمية ملف `/llms.txt` (نحو 17 كيلوبايت) الذي يفهرس كل صفحة بوصف قصير، وملف `/llms-full.txt` (نحو 1.8 ميجابايت) الذي يدمج كل شيء في ملف واحد. ولتحميل الوثائق دفعةً واحدة في نموذج لغوي كبير، يكون هذا المسار الرسمي أكثر موثوقية واستقرارًا. أي إن قوة Hermes Bible تكمن خالصةً في تجربة بحث الإنسان بسرعة وتصفّح سير عمل المجتمع.

ثالثًا، ثمة خطر عام من الاعتماد الخارجي. فإذا جذبت مدونة شركة أو وثيقة تشغيل موقعًا من طرف ثالث إلى مسارها الأساسي، فقد تنكسر الروابط حين يختفي ذلك الموقع أو يغيّر وجهته. والأفضل استخدام Hermes Bible كأداة مساعدة للاكتشاف والتعلّم، ولا يصح معاملته كمصدر الحقيقة الوحيد لعملياتنا الداخلية.

خلاصة القول، يُعدّ Hermes Bible أصلًا مجتمعيًا متقنًا يساعد الناس على مواكبة معرفة إطار وكيل سريع التطوّر. ومع ذلك، تحتاج إلى توازن الإقرار بتأخّره غير الرسمي المتأصل واعتماده الخارجي مع إبقاء الوثائق الرسمية نقطةً مرجعية. وقبل كل شيء، فإن النمط الذي يجسّده، "اجعل معرفة الوكلاء الهائلة قابلة للبحث، وقابلة للمشاركة كسير عمل عملي"، هو أثمن انعكاس لمنصة مثل منصتنا تشغّل مهارات وقواعد واسعة النطاق.

## المصادر

- Hermes Bible: [hermesbible.com](https://www.hermesbible.com/)
- Hermes Agent (Nous Research): [github.com/NousResearch/hermes-agent](https://github.com/NousResearch/hermes-agent)
- الوثائق الرسمية: [hermes-agent.nousresearch.com/docs](https://hermes-agent.nousresearch.com/docs/)
