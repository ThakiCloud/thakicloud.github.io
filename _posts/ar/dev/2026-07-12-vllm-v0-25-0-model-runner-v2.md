---
title: "vLLM v0.25.0: أصبح Model Runner V2 هو المسار الافتراضي واختفى PagedAttention"
excerpt: "صدر vLLM v0.25.0 بـ 558 التزامًا (commit) من 232 مساهمًا. يتمحور هذا الإصدار حول تغييرين رئيسيين: أولًا، أصبح Model Runner V2 هو مسار التنفيذ الافتراضي لجميع النماذج الكثيفة. ثانيًا، أُزيل من قاعدة الكود التنفيذ القديم لـ PagedAttention، الذي كان السبب في شهرة vLLM في البداية. إلى جانب ذلك، أُضيفت ميزة أخذ العينات الفعّال من الفيديو (EVS)، وفك التشفير التخميني الديناميكي، والتخزين المؤقت الهجين لبادئات Mamba. نستعرض هنا ما تغيّر وما ينبغي الاستعداد له من منظور فريق يشغّل بنية تحتية للاستدلال."
tags:
  - dev
  - vllm
  - inference
  - serving
  - cuda
  - self-hosting
  - kubernetes
  - paxis
date: 2026-07-12
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/vllm-v0-25-0-model-runner-v2/"
categories:
  - dev
---

## نظرة عامة

يُعد vLLM محرك الاستدلال المعياري الفعلي لتشغيل نماذج اللغة الكبيرة مفتوحة الأوزان في بيئات الإنتاج. وبفضل إنتاجيته العالية ودعمه الواسع للعتاد، فإن معظم الفرق التي تستضيف نماذجها على وحدات معالجة رسومية خاصة بها تمرّ عبر vLLM. وإصدار جديد لمحرك بهذا الحجم ليس مجرد رفع رقم إصدار، بل حدث يؤثر في طريقة تشغيل حزمة الخدمة بأكملها.

هذا المقال موجّه للمهندسين الذين يشغّلون بنية استدلال تحتية مباشرة أو يتحملون مسؤولية تكاليف الخدمة. صدر vLLM v0.25.0 في عام 2026 ويضم 558 التزامًا من 232 مساهمًا، منهم 64 مساهمًا جديدًا. والحجم يعكس الاتجاه بوضوح: فقد تم في هذا الإصدار ترقية بنية التنفيذ الجديدة التي جرى الإعداد لها عبر عدة إصدارات سابقة لتصبح الافتراضية، وفي هذه العملية تم تنظيف المسارات القديمة.

يمكن تلخيص جوهر الإصدار في نقطتين. أولًا، **أصبح Model Runner V2 (يُختصر MRv2) مسار التنفيذ الافتراضي لجميع النماذج الكثيفة (dense)**. ثانيًا، **أُزيل التنفيذ القديم لـ PagedAttention** الذي جعل vLLM مشهورًا في الأساس. سنتناول ما يعنيه هذان التغييران لمن يشغّل خدمات على نطاق واسع، وما الفائدة العملية لميزات الفيديو وفك التشفير التخميني المرافقة لهما.

## ما الذي غيّره هذا الإصدار

أكبر تغيير بنيوي هو ترقية MRv2. فقد جرى بناء MRv2 على مدى الإصدارات السابقة أثناء تعزيز دعم النماذج المكمّمة (quantized)، وابتداءً من v0.25.0 أصبح المسار القياسي لتنفيذ النماذج الكثيفة. وباتت معظم النماذج تعمل الآن على هذا النواة الجديدة دون الحاجة لأي أعلام (flags) خاصة. ويصف فريق vLLM هذه النواة بأنها أكثر تجزئة وأسرع، وقد ثبّت هذا الإصدار وضعها كمسار افتراضي.

النتيجة الطبيعية لهذا التحول هي حذف التنفيذ القديم لـ PagedAttention. فبعد أن أصبحت الواجهتان الخلفيتان V1 وMRv2 هما المسار القياسي، لم يعد هناك مبرر للاحتفاظ بتنفيذ الانتباه القديم. كان PagedAttention، الذي يدير ذاكرة التخزين المؤقت KV صفحةً بصفحة لتقليل هدر الذاكرة، أشبه بالتقنية الرمزية للأيام الأولى لـ vLLM، لكن الفكرة نفسها امتُصت بالفعل داخل الواجهات الخلفية الجديدة. ما أُزيل هنا ليس المفهوم، بل مسار كود قديم.

يوضّح المخطط التالي التحوّل في مسارات التنفيذ:

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
<div class="d3-arch" data-arch-root id="12vllmv0250modelrunnerv2-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 950, "height": 558, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 539, "y": 24, "w": 120, "h": 46, "title": "طلب استدلال"}, {"id": "B", "x": 509, "y": 148, "w": 181, "h": 52, "title": "اختيار مسار التنفيذ"}, {"id": "C", "x": 627, "y": 300, "w": 212, "h": 62, "title": ["مسار PagedAttention القديم", "حُذف في هذا الإصدار"]}, {"id": "D", "x": 360, "y": 292, "w": 212, "h": 78, "title": ["Model Runner V2", "المسار القياسي لكل النماذج", "الكثيفة"]}, {"id": "E", "x": 748, "y": 464, "w": 170, "h": 46, "title": "دعم النماذج المكمّمة"}, {"id": "F", "x": 488, "y": 448, "w": 205, "h": 78, "title": ["فك التشفير التخميني", "الديناميكي", "متوافق مع رسم CUDA الكامل"]}, {"id": "G", "x": 249, "y": 456, "w": 184, "h": 62, "title": ["Mamba الهجين", "التخزين المؤقت للبادئة"]}, {"id": "H", "x": 24, "y": 456, "w": 170, "h": 62, "title": ["بادئة متعددة الوسائط", "انتباه ثنائي الاتجاه"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [599, 70, 599, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "قبل v0.24", "curve": [[647, 200], [733, 246], [733, 246], [733, 300]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "v0.25.0 افتراضي", "curve": [[551, 200], [466, 246], [466, 246], [466, 292]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "curve": [[572, 354], [833, 409], [833, 409], [833, 464]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[528, 370], [591, 409], [591, 409], [591, 448]]}, {"src": "D", "dst": "G", "kind": "data", "curve": [[403, 370], [341, 409], [341, 409], [341, 456]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[360, 354], [109, 409], [109, 409], [109, 456]]}]});
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
      const container = document.getElementById('12vllmv0250modelrunnerv2-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '12vllmv0250modelrunnerv2-1';
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

## تفاصيل التغييرات الرئيسية

الميزات الجديدة المبنية فوق MRv2 في هذا الإصدار تستهدف بشكل أساسي أحمال العمل متعددة الوسائط وذات السياق الطويل.

أولًا، **أخذ العينات الفعّال من الفيديو (EVS، اختصار لـ Efficient Video Sampling)**. تعاني نماذج الرؤية واللغة التي تتعامل مع الفيديو من انفجار في عدد الرموز (tokens) كلما زاد عدد الإطارات، مما يفاقم استهلاك الذاكرة وزمن الاستجابة بسرعة. تقوم EVS بحذف الرموز من المناطق الزمانية-المكانية شبه الثابتة مع الحفاظ على الهوية الموضعية (positional identity) للرموز المتبقية. ولأن عدد الرموز المحتفظ بها ينمو بمعدل أبطأ من الخطي مقارنة بطول المقطع، يمكن للنماذج التعامل مع سياق زمني أطول بكثير دون تجاوز حدود الذاكرة وزمن الاستجابة.

ثانيًا، **أصبح فك التشفير التخميني الديناميكي متوافقًا مع رسم CUDA الكامل**. يعتمد فك التشفير التخميني على نموذج مصغّر لاقتراح عدة رموز مسبقًا، يقوم النموذج الرئيسي بعدها بالتحقق منها، وهو ما يرفع الإنتاجية. وتوافق هذه الآلية مع التقاط رسم CUDA يعني أن بالإمكان الآن الاستفادة في آن واحد من تقليل عبء تشغيل النواة (kernel) الذي يوفره رسم CUDA، ومن مكاسب فك التشفير التخميني نفسه.

ثالثًا، هناك تعارض مهم يجب معرفته. **تفعيل تقليم EVS يعطّل رسم CUDA الخاص بالفيديو تلقائيًا**. والسبب أن EVS تجعل عدد الرموز متغيّرًا حسب البيانات، وهذا يتعارض مع افتراض الشكل الثابت الذي يعتمد عليه التقاط رسم CUDA. بمعنى آخر، اختيار توفير الرموز في الفيديوهات الطويلة يعني التخلي عن تحسين رسم CUDA في ذلك المسار. وتحديد الجانب الأنسب يعتمد على طبيعة حِمل العمل، وهو قرار يجب أن يتخذه كل فريق بنفسه.

كما تضمّن هذا الإصدار التضمينات (embeddings) في الزمن الحقيقي، والتخزين المؤقت للبادئات لنماذج Mamba الهجينة، ودعم الانتباه ثنائي الاتجاه لبادئات الوسائط المتعددة. ومع تزايد انتشار البنى الهجينة المبنية على Mamba، يشكّل دعم التخزين المؤقت للبادئات لها تحسينًا عمليًا يخفّض تكلفة الطلبات المتكررة.

## التثبيت والتحقق

يُثبَّت vLLM v0.25.0 بالطريقة المعتادة.

```bash
uv pip install vllm==0.25.0
```

وأمر تشغيل نموذج للخدمة بعد التثبيت لم يتغيّر عن السابق.

```bash
vllm serve <model-id>
```

وبما أن MRv2 أصبح المسار الافتراضي، فلا حاجة عادةً لتحديد أعلام منفّذ (runner) منفصلة عند تشغيل النماذج الكثيفة.

بصراحة، فإن البيئة التي كُتب فيها هذا المقال لا تحتوي على وحدة معالجة رسومية، ولذلك لم نستطع قياس الإنتاجية أو زمن الاستجابة الفعليين بأنفسنا. ولهذا السبب لم نُدرج في هذا المقال أي أرقام أداء لم نقسها بأنفسنا. وكل الحقائق المذكورة مستقاة من ملاحظات الإصدار الرسمية: عدد الالتزامات والمساهمين، وترقية MRv2 إلى المسار الافتراضي، وحذف التنفيذ القديم لـ PagedAttention، وخصائص EVS وفك التشفير التخميني الديناميكي، كلها مبنية على معلومات الإصدار المنشورة. ونوصي بإجراء قياسات فعلية على عنقود وحدات معالجة رسومية خاص بكم، باستخدام النماذج المستهدفة وأنماط الحركة المرورية الفعلية لديكم.

## دلالات هذا الإصدار على منتجات ThakiCloud

يرتبط هذا الإصدار مباشرة بتشغيل **ai-platform** لدى ThakiCloud. تعتمد ai-platform على K8s وKueue لجدولة وحدات المعالجة الرسومية، وتستخدم vLLM لخدمة النماذج في بيئات متنوعة لعملائها. وبما أن vLLM هو المحرك الأساسي لحزمة الخدمة لدينا، فإن أي تغيير في بنية تنفيذه هو تغيير في طريقة تشغيلنا نفسها.

كون MRv2 أصبح المسار الافتراضي يعني أن بإمكاننا الآن تركيز جهود التحقق والتحسين على مسار تنفيذ قياسي واحد. فعندما تتعايش عدة مسارات، تتشعب عملية إعادة إنتاج الأخطاء وضبط الأداء بحسب كل مسار، أما عند اعتماد مسار قياسي واحد فإن التعقيد التشغيلي ينخفض. وبالنسبة لمنصة تخدم عشرات النماذج في آن واحد ضمن بيئة متعددة المستأجرين، فإن هذا التبسيط ينعكس مباشرة على الاستقرار.

كما يشكّل الجمع بين فك التشفير التخميني الديناميكي ورسوم CUDA، إلى جانب التخزين المؤقت الهجين لبادئات Mamba، تحسينات تصب في اتجاه خفض تكلفة الخدمة. وانخفاض تكلفة الخدمة يمثّل ميزة تنافسية مباشرة للعملاء الذين يحتاجون إلى بنية تحتية داخلية أو حلول ذكاء اصطناعي سيادية. فجدوى الوكلاء (agents) والتطبيقات التي تعمل فوق هذه البنية لا تتحقق إلا إذا أمكن تقديم الخدمة بتكلفة منخفضة على البنية التحتية الخاصة. من هذا المنطلق، تشكّل الخدمة منخفضة التكلفة التي توفرها ai-platform الأساس الذي يدعم جدوى طبقات الوكلاء الأعلى مثل Paxis.

## القيود ووجهات النظر المضادة

أول ما يجب الإشارة إليه هو أن هذا الإصدار يتضمن تغييرًا كاسرًا (breaking change). فبسبب حذف مسار PagedAttention القديم، قد تتعطل أي إعدادات مخصصة أو تكاملات من أطراف ثالثة كانت تعتمد على هذا المسار عند الترقية إلى v0.25.0. وعند رفع الإصدار في بيئة الإنتاج، ينبغي تشغيل النماذج المستهدفة فعليًا في بيئة اختبارية والتحقق من عدم وجود تراجعات قبل تطبيق الترقية. فرفع إصدار جديد مباشرة إلى الإنتاج لمجرد أنه جديد يُعد تصرفًا محفوفًا بالمخاطر.

ثانيًا، وكما أشرنا سابقًا فيما يخص التعارض بين EVS ورسوم CUDA، فإن الميزات الجديدة لا تحمل فائدة مطلقة دائمًا. يحتاج كل فريق إلى تحديد أي التحسينات يفعّلها أو يعطّلها بناءً على خصائص حِمل العمل الخاص به، وهذا قرار يصعب اتخاذه دون قياس فعلي. وتوقّع أن "تفعيل كل الميزات الجديدة يعني سرعة أكبر" كثيرًا ما يخالف الواقع.

ثالثًا، حجم الإصدار نفسه يمثّل مخاطرة. فإصدار يضم 558 التزامًا دفعة واحدة يترك مجالًا أكبر لتفاعلات غير متوقعة. وقد تظهر مشكلات خاصة ببنى نماذج أو مجموعات عتاد معينة فقط، لذا من الأفضل عدم تخطي خطوة التحقق على مجموعة النموذج ووحدة المعالجة الرسومية الفعلية التي تُستخدم لديكم.

باختصار، يمثّل vLLM v0.25.0 إصدارًا يُثبّت نتائج إعداد طويل كإعداد افتراضي. والتوحّد حول MRv2 وتنظيف المسارات القديمة يسيران في اتجاه جعل حزمة الخدمة أبسط وأسرع على المدى الطويل، وهو ما يفيد بشكل مباشر تشغيل ai-platform لدى ThakiCloud التي تعتمد على vLLM كمحرك أساسي. غير أن الاستفادة الآمنة من هذه المزايا تتطلب الالتزام بالأساسيات: التحقق من التغييرات الكاسرة والقياس الفعلي لكل حِمل عمل على حدة.

## المصادر

- إصدار vLLM v0.25.0: [github.com/vllm-project/vllm/releases/tag/v0.25.0](https://github.com/vllm-project/vllm/releases/tag/v0.25.0)
- مقدمة Model Runner V2: [vllm.ai/blog/2026-03-24-mrv2](https://vllm.ai/blog/2026-03-24-mrv2)
- ورقة أخذ العينات الفعّال من الفيديو (EVS): [arxiv.org/pdf/2510.14624](https://arxiv.org/pdf/2510.14624)
