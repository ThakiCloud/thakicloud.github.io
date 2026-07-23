---
title: "ما بعد الذكاء العام: مسارات DeepMind الأربعة نحو الذكاء الفائق"
excerpt: "يتعامل تقرير Google DeepMind المكوّن من نحو 57 صفحة From AGI to ASI مع الذكاء الفائق لا كتجربة فكرية بعيدة بل كمشكلة تخطيط ينبغي الاستعداد لها الآن. يرسم أربعة مسارات، التوسّع، وتحوّل خوارزمي، والتحسين الذاتي التكراري، وتشكّل مجموعات متعددة الوكلاء، والحدود الفيزيائية التي تقيّد كلًّا منها. نقرأ الخريطة من منظور ThakiCloud Paxis التي تُشغّل هيكل مهارات ذاتي التطوّر وتنسيق وكلاء متعدد على شكل DAG."
seo_title: "DeepMind From AGI to ASI: شرح المسارات الأربعة - Thaki Cloud"
seo_description: "يعرض تقرير Google DeepMind بعنوان From AGI to ASI (arXiv 2606.12683) أربعة مسارات من الذكاء العام إلى الذكاء الفائق، التوسّع وتحوّل النموذج الخوارزمي والتحسين الذاتي التكراري وتشكّل مجموعات متعددة الوكلاء، ويناقش حدودًا جوهرية كسرعة الضوء والديناميكا الحرارية ونظرية التعقيد وعدم اكتمال غودل. نستخلص الدلالات من منظور ThakiCloud Paxis التي تُشغّل مهارات ذاتية التطوّر وتنسيق وكلاء على شكل DAG."
date: 2026-07-06
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/deepmind-agi-to-asi-pathways/"
tags:
  - research
  - agi
  - asi
  - superintelligence
  - deepmind
  - recursive-self-improvement
  - multi-agent
  - ai-strategy
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "flask"
categories:
  - research
published: false
---

## لمن هذه المقالة

هذه المقالة موجّهة إلى المهندسين والقادة التقنيين الذين يريدون خريطة منظّمة جيدًا بدلًا من قلق غامض أو تفاؤل مبالغ فيه بشأن وجهة الذكاء الاصطناعي. تُستهلَك كلمة "الذكاء الفائق" عادةً بوصفها مفردة من الخيال العلمي، لكن الأمر مختلف حين يبدأ مختبر رائد عالميًا بالتعامل معها جديًا كمشكلة تخطيط. نقرأ معًا ماذا تتوقّع DeepMind وعلى أي أساس، وماذا يعني ذلك التوقّع لنا نحن من نبني بنية تحتية ومنصّات وكلاء حقيقية.

## نظرة عامة: الذكاء الفائق كمشكلة تخطيط لا كتجربة فكرية

يرسم تقرير Google DeepMind بعنوان From AGI to ASI (arXiv 2606.12683)، البالغ نحو 57 صفحة، الطريق من الذكاء العام على المستوى البشري إلى الذكاء الفائق، تمامًا كما يقول عنوانه. كتبه باحثون في DeepMind من بينهم Tim Genewein، ووفقًا للتغطية فهو الجزء الثالث في سلسلة متعمّدة من المختبر. بعبارة أخرى، بدأ هذا المختبر يتعامل مع الذكاء الفائق لا كموضوع يُناقَش يومًا ما بل كأمر ينبغي التخطيط له بدءًا من الآن.

هذا التحوّل في الموقف هو السبب الأول لقراءة الوثيقة. لا يؤكّد التقرير أن الذكاء الفائق سيصل حتمًا. بل يصنّف برصانة عبر أي مسارات قد يصل إن وصل، وما الذي يعيق كل مسار. هذا التصنيف، الذي لا هو متحمّس ولا خائف، هو الجزء الأكثر فائدة للممارِس. فالتوقّعات الغامضة لا تُنتِج استعدادًا، لكن حين تتّضح المسارات والاختناقات، يصبح جليًّا أين ينبغي أن ننظر وما ينبغي أن نُعِدّ له.

## المسارات الأربعة

ينظّم التقرير الطريق من الذكاء العام إلى الذكاء الفائق في أربعة مسارات. وهي ليست متعارضة، وقد تعمل عدة مسارات في آنٍ معًا متداخلة في الواقع.

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
<div class="d3-arch" data-arch-root id="deepmindagitoasipathways-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 971, "height": 618, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 419, "y": 24, "w": 170, "h": 78, "title": ["الذكاء العام", "ذكاء عام على المستوى", "البشري"]}, {"id": "B", "x": 783, "y": 188, "w": 156, "h": 78, "title": ["المسار 1: التوسّع", "حوسبة وبيانات أكثر", "نماذج أكبر"]}, {"id": "C", "x": 537, "y": 188, "w": 191, "h": 78, "title": ["المسار 2: تحوّل خوارزمي", "بنية جديدة", "تتجاوز المحوّلات"]}, {"id": "D", "x": 270, "y": 180, "w": 212, "h": 94, "title": ["المسار 3: تحسين ذاتي", "تكراري", "الذكاء يُسرّع أبحاث الذكاء", "حلقة تغذية راجعة"]}, {"id": "E", "x": 24, "y": 180, "w": 191, "h": 94, "title": ["المسار 4: متعدد الوكلاء", "وكلاء بشريو المستوى", "منسّقون", "على نطاق واسع وبإحكام"]}, {"id": "F", "x": 444, "y": 352, "w": 121, "h": 62, "title": ["الذكاء الفائق", "ASI"]}, {"id": "G", "x": 412, "y": 492, "w": 184, "h": 94, "title": ["مقيّد بحدود جوهرية", "سرعة الضوء والديناميكا", "الحرارية", "التعقيد وغودل"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[589, 82], [861, 141], [861, 141], [861, 188]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[568, 102], [633, 141], [633, 141], [633, 188]]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[440, 102], [376, 141], [376, 141], [376, 180]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[419, 80], [120, 141], [120, 141], [120, 180]]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[861, 266], [861, 313], [861, 313], [565, 371]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[633, 266], [633, 313], [633, 313], [561, 352]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[376, 274], [376, 313], [376, 313], [447, 352]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[120, 274], [120, 313], [120, 313], [444, 372]]}, {"src": "F", "dst": "G", "kind": "data", "line": [504, 414, 504, 492]}]});
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
      const container = document.getElementById('deepmindagitoasipathways-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'deepmindagitoasipathways-1';
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

الأول هو التوسّع. المسار المألوف لدفع القدرة أعلى بمزيد من الحوسبة والبيانات ونماذج أكبر. الثاني هو تحوّل النموذج الخوارزمي. بنية جديدة تتجاوز محوّلات اليوم تظهر وتستخرج قدرة أعلى بكثير من الموارد نفسها. الثالث هو التحسين الذاتي التكراري. ذكاء اصطناعي ذكي بما يكفي يبدأ بتحسين بنيته وطرق تدريبه واستدلاله، وكل تحسين يجعل التالي أسهل، فيدخل في حلقة تغذية راجعة. الرابع هو تشكّل مجموعات متعددة الوكلاء. فمن دون بناء نموذج خارق واحد، قد يبلغ تنسيق وكلاء بشريي المستوى بعدد وسرعة وقُرب كافٍ قدرةً تعادل الذكاء الفائق.

هذا المسار الرابع مثير للاهتمام بوجه خاص لأنه يعيد تعريف الذكاء الفائق لا كمشكلة نموذج عملاق واحد بل كمشكلة تنسيق وتنظيم. فحتى لو لم يتجاوز كل عضو المستوى البشري، قد يفوق الناتج الفكري للمجموعة التي يشكّلونها مجموع الأفراد بكثير. إنه المنطق نفسه الذي بنت به المجتمعات البشرية حضارة لا يفسّرها الذكاء الفردي وحده.

## التحسين الذاتي التكراري: المسار الأكثر سخونة

من بين المسارات الأربعة، الأشدّ جدلًا هو التحسين الذاتي التكراري. الفكرة الجوهرية أنه في اللحظة التي يبدأ فيها الذكاء الاصطناعي بمساعدة أبحاث الذكاء وتطويره ذاته، يساعد نظام محسّن الجولة التالية من الأبحاث بشكل أفضل، ويُسرّع النظام الأكثر تحسّنًا الجولة التي تليها، فتنفتح دورة. وإذا كانت هذه الدورة سريعة بما يكفي، فقد يحدث الانتقال من الذكاء العام إلى الفائق لا تدريجيًا بل انفجاريًا، وهذا هو سيناريو هذا المسار.

ما يثير الإعجاب في طريقة تناول التقرير لهذا المسار أنه لا يعلنه حتميًا ولا مستحيلًا. فلكي تُحدِث حلقة تحسين ذاتي انتقالًا انفجاريًا فعلًا، يجب أن تتوافق عدة شروط في آنٍ واحد، ولكل شرط اختناقه الخاص. هل تجعل كل خطوة التحسين التالي أسهل فعلًا، أم أن العوائد تتناقص؟ هل تتجاوز سرعة التحسين سرعة التحقّق وفحوص السلامة؟ تحكم هذه الأسئلة الميل الفعلي للانفجار. وبتعداد هذه الاختناقات، يسحب التقرير التحسين الذاتي التكراري من الأسطورة إلى سيناريو هندسي قابل للفحص.

## حتى الذكاء الفائق مقيّد بالقانون الفيزيائي

أكثر مقاطع هذا التقرير توازنًا هو الادّعاء بأن حتى الذكاء الفائق ليس غير محدود. لا يمكن لأي ذكاء أن يفلت من حدود فيزيائية وحسابية جوهرية. فالإشارات لا يمكن أن تسافر أسرع من الضوء، وتحمل الحوسبة كلفة طاقة دنيا تفرضها الديناميكا الحرارية، وبعض المسائل لا يمكن حلّها بكفاءة مهما بلغ ذكاء الحلّال بحسب نظرية التعقيد، وكما يُظهر عدم اكتمال غودل، بعض العبارات الصحيحة لا يمكن إثباتها داخل نظام صوري معطى.

تُنزِل حجّة الحدود هذه نقاش الذكاء الفائق إلى الأرض. فالذكاء الفائق ليس سحرًا بل لا يزال نظامًا حاسوبيًا يعمل في العالم الفيزيائي، وعلى ذلك النظام أن يعمل ضمن ميزانيات حقيقية من الطاقة والكمون وتعقيد الحوسبة. وهذا المقطع مرحّب به خصوصًا لمن يبني بنية تحتية، لأنه يوضّح أن سقف القدرة يُختزَل في النهاية إلى مسألة موارد فيزيائية. فمهما كانت الخوارزمية بارعة، فإنها تعمل على واقع فيزيائي من الطاقة والتبريد وعرض نطاق الربط البيني.

## دلالات لـ ThakiCloud

تبدو المسارات الأربعة في هذا التقرير مستقبليات مجرّدة، لكنها تتداخل بدرجة ملموسة مدهشة مع محاور تصميم المنتجات التي نبنيها. Paxis من ThakiCloud هي مستوى تحكّم من نوع Agent-Native Cloud يعمل فوق ai-platform، ويتعامل مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. يرتبط مساران من مسارات التقرير هنا مباشرة.

أولًا، التحسين الذاتي التكراري. يختار هيكل المهارات في Paxis من بين أكثر من 960 مهارة باستخدام BM25، ويشغّلها في صندوق رمل معزول، ويتأمّل النتائج ليحسّن المهارات ذاتها في حلقة ذاتية التطوّر. هذا ليس نسخة مصغّرة من التحسين الذاتي الانفجاري الذي يصفه التقرير، بل ممارسة تحمل الدرس المعاكس. فنحن نصمّم التحسين الذاتي لا كجموح غير قابل للسيطرة بل كتكرار قابل للتحقّق يمرّ عبر بوابات السياسة وسجلات التدقيق. وبربط كل خطوة تحسين بالمرور عبر بوابة حتمية قبل الانتقال إلى التالية، يمكننا هيكليًا سدّ الاختناق الذي يشير إليه التقرير، حيث تتجاوز سرعة التحسين سرعة التحقّق.

ثانيًا، تشكّل مجموعات متعددة الوكلاء. تعالج Paxis الأعمال المعقّدة لا بوكيل عملاق واحد بل بتنسيق وكلاء متعدد على شكل DAG يفكّكها. يركّز كل وكيل على أدوار محدّدة، ويُنتج الرسم الذي يشكّلونه ناتجًا يتجاوز مجموع القدرات الفردية. قوة التنسيق التي يتحدّث عنها المسار الرابع في التقرير أمر نتعامل معه فعلًا كنموذج تنفيذ للمنتج. والنقطة أننا نتعامل مع تنسيق الوكلاء المتعدد لا كقصة كبرى نحو الذكاء الفائق بل كطريقة لحلّ مشكلات اليوم العملية بشكل أفضل.

وحجّة الحدود ليست بلا صلة أيضًا. فحدود الديناميكا الحرارية والكمون والربط البيني التي يؤكّدها التقرير هي بالضبط مشكلات جدولة GPU والطاقة والتبريد وعرض نطاق الشبكة التي تواجهها ai-platform كل يوم. والبصيرة بأن سقف القدرة يُختزَل إلى موارد فيزيائية تعني أن من ينظّم تلك الموارد بكفاءة أكبر يصبح صاحب الميزة التنافسية. وجدولة GPU المستندة إلى Kueue وتحسين الخدمة عبر vLLM وعزل الموارد متعدد المستأجرين هي بالضبط الآليات لإنفاق تلك الميزانية الفيزيائية باقتصاد قدر الإمكان.

## الحدود والاعتراضات

ثمة أمور ينبغي ملاحظتها كي لا نبالغ في تقدير هذا التقرير. أولًا، هذه خريطة مفاهيمية لا نتائج تجريبية. فهي لا تتضمّن تنبّؤات مُتحقَّقًا منها بأي من المسارات الأربعة سيُنتِج الذكاء الفائق فعلًا، أو متى. تكمن قيمة التقرير في إطار تصنيفه لا في الإجابات، والإطار مفيد لكنه لا يكشف المستقبل بذاته.

الشكّ في فرضية الذكاء الفائق ذاتها مشروع أيضًا. فإلى أي مدى يمتدّ منحنى القدرة الحالي سؤال مفتوح، وحتى بلوغ الوجهة المسمّاة بالذكاء العام ليس مستقبلًا محسومًا. وقبل مناقشة المسارات الأربعة، فإن وصول الذكاء العام، نقطة انطلاقها، بالصورة التي نتخيّلها هو ذاته محلّ جدل. لقد رسم التقرير خريطة مشروطة لا ضمانًا للوصول.

أخيرًا، الفائدة الحقيقية لمثل هذا الخطاب للممارسة لا تكمن في التنبّؤ بالذكاء الفائق بل في شحذ مبادئ التصميم اليوم. فتخيّل خطر التحسين الذاتي الانفجاري مسبقًا يوضّح لماذا تحتاج الحلقات ذاتية التطوّر التي نبنيها اليوم إلى بوابات تحقّق. وأخذ قوة تنسيق الوكلاء المتعدد على محمل الجدّ يمنحنا سببًا لبناء تنسيق اليوم بمتانة أكبر. واستخلاص أسسٍ لممارسة قريبة المدى من وثيقة عن المستقبل البعيد هو الطريقة الأكثر عملية لقراءة هذا التقرير.

## المصادر

- From AGI to ASI, arXiv:2606.12683 (2026). <https://arxiv.org/abs/2606.12683>
- Google DeepMind, "From AGI to ASI" publication page. <https://deepmind.google/research/publications/239142/>
