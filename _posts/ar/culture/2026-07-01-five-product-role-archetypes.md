---
title: "خمسة نماذج أصيلة تبقى حين تذوب حدود الوظائف: من المبتكر حتى الصائن"
excerpt: "في عصر تتشابك فيه الهندسة والمنتج والتصميم والبيانات في كتلة واحدة، يستعرض هذا المقال النماذج الأصيلة الخمسة التي رصدها Boris Cherny صانع Claude Code، وصيغة تشكيل الفرق وفق مرحلة نضج المنتج."
date: 2026-07-01
last_modified_at: 2026-07-01
lang: ar
tags:
  - مستقبل-العمل
  - ثقافة-تنظيمية
  - فريق-المنتج
  - توظيف
  - Boris Cherny
  - Claude Code
author_profile: true
toc: true
toc_label: المحتويات
canonical_url: "https://thakicloud.com/tech-blog/ar/culture/five-product-role-archetypes/"
header:
  image: /assets/images/five-product-role-archetypes-hero.webp
categories:
  - culture
---

![تصور تجريدي يجسد تلاشي حدود الوظائف وبروز نماذج أصيلة جديدة للأدوار]({{ '/assets/images/five-product-role-archetypes-hero.webp' | relative_url }})

## نظرة عامة

يتكرر مشهد بات مألوفا: المسمى الوظيفي لا يصف بعد الآن ما يفعله صاحبه فعلا. المصمم يكتب نماذج أولية بالكود، والمهندس يجري مقابلات مع المستخدمين، وعالم البيانات يحسم اتجاه المنتج. مع امتصاص أدوات الذكاء الاصطناعي للجانب الميكانيكي من كل وظيفة، تتداخل حدود الهندسة والمنتج والتصميم والتحليل وتذوب في كتلة واحدة.

أمام هذا التحول، رصد Boris Cherny صانع Claude Code ملاحظة لافتة: حين أمعن النظر في فريق Claude Code الذي ينتمي إليه، وجد خمسة نماذج أصيلة للأدوار تتشكل بمعزل عن الوظائف الرسمية. وأهمية هذه الملاحظة بسيطة: إنها تطرح فرضية مفادها أن منظمات المستقبل قد تبني فرقها على أساس هذه النماذج لا على أساس الوظائف التقليدية.

يتناول هذا المقال ماهية النماذج الخمسة، وسبب انفصالها عن الوظائف الرسمية، والتركيبة اللازمة منها في كل مرحلة من مراحل نضج المنتج. هذا ليس ملخصا تقنيا، بل مقال ثقافي يتساءل: كيف نبني الفرق وكيف ننظر إلى التوظيف؟ وهو سؤال مباشر بصفة خاصة لمنظمات كـ ThakiCloud حيث يعمل البشر والوكلاء الآليون جنبا إلى جنب.

## النماذج الأصيلة الخمسة

النماذج التي صاغها Cherny هي كالتالي، مع توضيح كيف يظهر كل نموذج في الفرق الفعلية.

**المبتكر (Prototyper)** هو من يتصور أفكارا جديدة كليا. يطرح أفكارا بكثافة، لكن معظمها لا يصل إلى الإطلاق. قيمة هذا النموذج ليست في معدل نجاحه، بل في كثافة الأفكار التي ينتجها. حتى لو رُفض تسعة من كل عشرة أفكار، فإن غياب من يفتح آفاقا جديدة يعني توقف المنظمة عن التقدم إلى أراض مجهولة.

**المنفذ (Builder)** هو من يحول النماذج الأولية والأفكار بسرعة إلى منتجات أو بنية تحتية جاهزة للإنتاج. دوره تضييق المسافة بين الفكرة والإطلاق. إن كان المبتكر يرسم المخططات، فالمنفذ يحول تلك المخططات إلى مبانٍ قائمة.

**المنظف (Sweeper)** هو المرتب بامتياز: يصقل الواجهات المبعثرة، ويبسط الكود والأنظمة، ويزيل الميزات غير المستخدمة، ويرفع الأداء. عمله الحذف لا الإضافة. قرار إلغاء ميزة (unship) يستدعي شجاعة لا تقل عن شجاعة بنائها.

**المنمي (Grower)** يأخذ منتجا قائما ويحسنه باستمرار لرفع مستوى الملاءمة مع السوق (PMF). لا يعيد رسم اللوحة من الصفر، بل يعمل على الصورة الموجودة ليرفع معدلات التحويل ويخفض الاضطراب ويراكم تحسينات صغيرة.

**الصائن (Maintainer)** هو من يتملك الأنظمة الناضجة. يحافظ على الأمن والاستقرار والسرعة والكفاءة مع تنامي الأنظمة. لا بريق في عمله، لكن من دونه ينهار المنتج الناجح تحت ثقله.

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
<div class="d3-arch" data-arch-root id="iveproductrolearchetypes-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 365, "height": 692, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "P", "x": 81, "y": 24, "w": 170, "h": 62, "title": ["المبتكر (Prototyper)", "يولد أفكارا جديدة"]}, {"id": "B", "x": 60, "y": 164, "w": 212, "h": 62, "title": ["المنفذ (Builder)", "يحول إلى منتج جاهز للإنتاج"]}, {"id": "S", "x": 135, "y": 304, "w": 198, "h": 62, "title": ["المنظف (Sweeper)", "التبسيط والترتيب والأداء"]}, {"id": "G", "x": 146, "y": 458, "w": 177, "h": 62, "title": ["المنمي (Grower)", "تحسين PMF بصفة مستمرة"]}, {"id": "M", "x": 67, "y": 598, "w": 198, "h": 62, "title": ["الصائن (Maintainer)", "الأمن والاستقرار والتوسع"]}], "edges": [{"src": "P", "dst": "B", "kind": "data", "line": [166, 86, 166, 164]}, {"src": "B", "dst": "S", "kind": "data", "curve": [[196, 226], [234, 265], [234, 265], [234, 304]]}, {"src": "S", "dst": "G", "kind": "data", "line": [234, 366, 234, 458]}, {"src": "G", "dst": "M", "kind": "data", "curve": [[234, 520], [234, 559], [234, 559], [196, 598]]}, {"src": "M", "dst": "B", "kind": "event", "label": "الصيانة وإعادة الاختراع", "curve": [[136, 598], [98, 489], [98, 335], [136, 226]], "off": "50%"}]});
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
      const container = document.getElementById('iveproductrolearchetypes-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'iveproductrolearchetypes-1';
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

## النموذج ليس وظيفة

جوهر هذه الملاحظة ليس القائمة في حد ذاتها، بل حقيقة أن هذه النماذج لا ترتبط بالوظائف الرسمية. يقول Cherny إنه حين ينظر إلى Anthropic في مجملها يجد بعض المصممين ينتمون إلى النموذج الأول (المبتكر)، وآخرين إلى الثاني (المنفذ)، وغيرهم إلى الثالث (المنظف). والأمر ذاته ينطبق على المهندسين ومديري المنتجات وعلماء البيانات.

بمعنى آخر، تفقد عبارة "نوظف مصمما" من معناها يوما بعد يوم. فالمصمم المبتكر الذي يفتح آفاقا جديدة يختلف اختلافا جذريا في طريقة إسهامه عن المصمم المنظف الذي يصقل ويكمل. المسمى الوظيفي يخبرك بالأدوات التي تعلمها، لكنه لا يخبرك بالحظة التي يتألق فيها.

كثيرون يجمعون بين نموذجين، وأحيانا ثلاثة. من يجمع بين المبتكر والمنفذ نادر وثمين في الشركات الناشئة المبكرة. ومن يجمع بين المنظف والصائن يشكل عمود فقري فرق البنية التحتية الناضجة. بدلا من حشر كل شخص في صندوق واحد، الأدق أن ننظر إلى الطيف الذي يقع عليه في هذه النماذج.

## تشكيل الفرق وفق دورة حياة المنتج

السبب الحقيقي لأهمية هذه النماذج هو أنها تصبح صيغة لتشكيل الفرق. يرى Cherny أن الفريق الصحي يحتاج إلى تركيبة مختلفة من النماذج وفق درجة نضج المنتج.

المنتج الجديد الذي لم يجد بعد ملاءمته مع السوق يحتاج إلى أشخاص أقوياء في النماذج الأول والثاني والثالث (المبتكر + المنفذ + المنظف). في هذه المرحلة لا أحد يعرف ما الصواب، لذا القدرة على البناء السريع والتخلي السريع وتغيير الاتجاه باستمرار هي ما يهم. تجميع أشخاص ذوي ميول صون قوية في هذه المرحلة يعني صون ما لم يُبن بعد.

المنتج في طور النمو بعد تحقيق الملاءمة مع السوق يحتاج إلى النماذج الثاني والثالث والرابع (المنفذ + المنظف + المنمي) مع جرعة من النموذج الخامس (الصائن). الاتجاه معروف الآن، فالمهمة رفع الجودة وتحسين التحويل مع قدر أدنى من الاستقرار لاستيعاب المستخدمين المتزايدين.

المنتج الناضج ذو الملاءمة القوية مع السوق يحتاج إلى النماذج الثالث والرابع والخامس (المنظف + المنمي + الصائن) مع جرعة من النموذج الثاني (المنفذ). المهمة إبقاء النظام بسيطا، والتحسين المستمر، والحفاظ على الأمن والسرعة في مستويات التوسع، مع البناء الجديد حين يلزم فحسب.

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
<div class="d3-arch" data-arch-root id="iveproductrolearchetypes-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 554, "height": 426, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "PRE", "x": 50, "y": 24, "w": 120, "h": 62, "title": ["قبل PMF", "منتج جديد"]}, {"id": "GROW", "x": 50, "y": 178, "w": 120, "h": 62, "title": ["مرحلة النمو", "تحقق PMF"]}, {"id": "MATURE", "x": 50, "y": 332, "w": 120, "h": 62, "title": ["مرحلة النضج", "PMF قوي"]}, {"id": "المنمي", "x": 225, "y": 32, "w": 121, "h": 46, "title": "+ جرعة الصائن"}, {"id": "الصائن", "x": 401, "y": 32, "w": 121, "h": 46, "title": "+ جرعة المنفذ"}], "edges": [{"src": "PRE", "dst": "GROW", "kind": "data", "label": "\"المبتكر + المنفذ + المنظف\"", "line": [110, 86, 110, 178], "lx": 110, "ly": 128}, {"src": "GROW", "dst": "MATURE", "kind": "data", "label": "\"المنفذ + المنظف + المنمي\"", "line": [110, 240, 110, 332], "lx": 110, "ly": 282}, {"src": "MATURE", "dst": "MATURE", "kind": "data", "label": "\"المنظف + المنمي + الصائن\"", "curve": [[170, 350], [271, 332], [271, 394], [170, 376]], "off": "50%"}]});
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
      const container = document.getElementById('iveproductrolearchetypes-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'iveproductrolearchetypes-2';
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

الدلالة العملية لهذه الصيغة واضحة: حين تضيف شخصا إلى الفريق، السؤال الأول ليس "هل يعاني الفريق من نقص في المهندسين؟" بل "أي نموذج يغيب عن فريقنا في هذه المرحلة؟" إشباع فريق منتج ناضج بالمبتكرين يعني فيضا من الأفكار الجديدة دون من يصون النظام. والعكس، جمع الصائنين في منتج لم يجد ملاءمته بعد يعني التحصن لحماية ما لا وجود له أصلا.

## منظور ThakiCloud: إعادة رسم الأدوار في عصر الوكلاء

الملاحظة القائلة بأن حدود الوظائف تذوب تصبح أحد المشهدية في المنظمات التي يعمل فيها البشر والوكلاء جنبا إلى جنب. حين تستوعب وكلاء الذكاء الاصطناعي حصة وافرة من عمليات البناء الميكانيكية، ينجرف البشر تلقائيا نحو النماذج الأصيلة الأكثر أهمية في كل مرحلة من مراحل المنتج. العنق الزجاجي لن يكون الأيدي التي تكتب الكود، بل العقول التي تشخص أي نموذج تحتاجه اللحظة.

Paxis، الحوسبة السحابية Native للوكلاء التي تشغلها ThakiCloud، تجسد هذا التحول على مستوى طبقة النظام. تعامل Paxis المهارات والأدوات والسياسات وسجلات التدقيق بوصفها موارد من الدرجة الأولى، وتختار أكثر من 960 مهارة عبر BM25 وتنفذها في بيئات معزولة. كما قال Cherny إن الأشخاص تُعاد صياغتهم وفق لحظات المنتج لا وفق مسمياتهم الوظيفية، كذلك تُجمع Paxis قدرات الوكلاء ديناميكيا وفق متطلبات المهمة لا وفق خطوط أنابيب جامدة. المبتكر يطرح الأفكار، فيحولها وكيل بدور المنفذ إلى كود جاهز للإنتاج، ثم يرتب بوابة التحقق بدور المنظف المخرجات، وكل ذلك يتكرر داخل حزمة المهارات.

على صعيد البنية التحتية، يضطلع ai-platform من ThakiCloud بالعمل الكامل للنموذج الصائن. جدولة وحدات GPU عبر Kueue، وتقديم النماذج عبر vLLM، والوفاء بمتطلبات الخصوصية والسيادة في بيئات K8s متعددة المستأجرين: كل ذلك هو بالضبط عمل الصائن الذي يحفظ الأمن والاستقرار والكفاءة في الأنظمة الناضجة. تفويض منظمات العملاء لهذا الجانب إلى المنصة يتيح لفرقهم الانتشار أكثر في اتجاه المبتكرين والمنميين.

هذا المنظور مفيد للتوظيف أيضا. تنظر ThakiCloud إلى المتقدمين من زاوية أي نموذج يمثلون، لا من زاوية مسمياتهم في السيرة الذاتية. الشخص الذي يملأ النموذج الغائب عن مرحلتنا الحالية هو من يخلق أكبر قدر من الرافعة للفريق. السؤال ليس "ماذا تحسن؟" فحسب، بل "أي لحظة تتألق فيها؟"

## حدود الإطار والحجج المضادة

قبل قبول هذا الإطار دون نقد، تستحق الحجج المقابلة الاستماع. أشار Ben Vinegar في السياق ذاته إلى أن "الناس يكتشفون كيف تعمل منظمات البرمجيات للتو، ثم يخطئون في عزو ديناميكيات الفرق القديمة إلى الذكاء الاصطناعي." اعتراض حاد ومشروع: التمييز بين المبتكر والصائن موجود منذ ما قبل الذكاء الاصطناعي، وأن درجة نضج المنتج تحدد نوع الموهبة المطلوبة ليست فكرة جديدة.

ثمة حدود للتصنيف في حد ذاته. كل محاولة لوضع الناس في خمسة صناديق تعاني من خطر تبسيط الأفراد تبسيطا مفرطا. في الواقع، يتنقل الشخص الواحد بين عدة نماذج من مشروع لآخر، بل خلال اليوم الواحد. الخطأ هو النظر إلى النماذج بوصفها هويات ثابتة، فيصدر حكم من قبيل "أنت منظف إذن لا تقترح أفكارا جديدة"، وهذا عكس الغرض تماما. لهذا شدد Cherny نفسه على أن كثيرين يجمعون بين نماذج متعددة.

ومع ذلك، تبقى قيمة هذا الإطار في اللغة التي يمنحها لا في قدرته التنبؤية. حين يصبح بإمكانك القول "يعاني فريقنا من نقص في المنمين" بدلا من "نحتاج مزيدا من المهندسين"، تنتقل محادثات التوظيف وتشكيل الفرق إلى مستوى أكثر دقة وجدوى. كلما جردت الذكاء الاصطناعي الوظائف من طبقتها الميكانيكية، كلما كان ما يبقى هو الأحكام على مستوى هذه النماذج. أدوار المنتج في المستقبل قد تشبه هذه النماذج أكثر مما تشبه المسميات الوظيفية اليوم.

## خاتمة

ذوبان حدود الوظائف ليس أزمة، بل إعادة تشكيل. النماذج الخمسة: المبتكر والمنفذ والمنظف والمنمي والصائن تكشف ما يبقى حين تختفي المسميات الوظيفية. ما يبقى ليس الأدوات، بل جوهر السؤال: في أي لحظة وبأي طريقة يقدم الشخص إسهامه؟

تبني ThakiCloud منظمة يتقاسم فيها البشر والوكلاء هذه النماذج. كلما تولت الوكلاء قدرا أكبر من عمليات البناء والصون المتكررة، كلما تركزت قدرة البشر على قراءة أي نموذج تحتاجه مرحلة المنتج الراهنة. تلك القراءة ستكون أثمن القدرات في العقد القادم.

## المصادر

- Boris Cherny, X(@bcherny), 2026-06-29: [التغريدة الأصلية](https://x.com/bcherny/status/2071379474277613732)
- Ben Vinegar, X(@bentlegen): [تغريدة الرد والاعتراض](https://x.com/bentlegen/status/2071576459538567463)
