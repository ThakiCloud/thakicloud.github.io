---
title: "كيف تمنح وكلاء الذكاء الاصطناعي ذاكرة حقيقية - 4 تقنيات في هندسة السياق"
excerpt: "النافذة السياقية الأوسع لا تعني بالضرورة أداءً أفضل. مع ازدياد عدد الرموز، تتراجع دقة استرجاع النموذج في ظاهرة تُعرف بتلف السياق. يستعرض هذا المقال أربع تقنيات أوصى بها Anthropic - الضغط، وتدوين الملاحظات المنظم، والوكلاء الفرعيون، وأدوات الذاكرة المستندة إلى الملفات - مع توضيح كيف تطبقها ThakiCloud في تشغيل الوكلاء الفعلي."
seo_title: "ذاكرة وكيل الذكاء الاصطناعي وهندسة السياق - 4 تقنيات - Thaki Cloud"
seo_description: "تلف السياق، ميزانية الانتباه، الضغط، تدوين الملاحظات المنظم، معمارية الوكلاء الفرعيين، أدوات الذاكرة المستندة إلى الملفات. كيف تتجاوز وكلاء الذكاء الاصطناعي طويلة الأمد حدود نافذة السياق، ورؤية من منظور المنصات متعددة المستأجرين."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - ai-agent
  - context-engineering
  - memory
  - llm
  - agent-architecture
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/ai-agent-memory-context-engineering/"
reading_time: true
categories:
  - agentops
published: false
---

كل من شغّل وكلاء نماذج اللغة الكبيرة لفترات طويلة يصطدم بالعقبة ذاتها: كلما امتد الحوار، بدأ الوكيل ينسى التزاماته السابقة ويتجاهل القواعد التي حُددت في البداية. الحل الشائع هو "نافذة سياق أكبر تحل المشكلة"، لكن هذا التشخيص خاطئ. المشكلة الحقيقية ليست في حجم النافذة، بل في كيفية إدارة الرموز داخلها - وهذا هو جوهر هندسة السياق. يستعرض هذا المقال أربع تقنيات مُثبتة تساعد الوكلاء طويلي الأمد على تجاوز حدود السياق، مع توضيح كيف دمجتها ThakiCloud في تشغيل وكلائها الفعلي.

## نظرة عامة

هندسة السياق هي الخطوة التالية بعد هندسة التلقين. إذا ركزت هندسة التلقين على ما يُكتب، فإن هندسة السياق تُعنى بتحديد أي الرموز ينبغي ملء ميزانية الانتباه المحدودة للنموذج بها لحظة الاستدلال. يشمل ذلك كل شيء: تعليمات النظام، وتعريفات الأدوات، وبروتوكول MCP، والبيانات الخارجية، وسجل الرسائل بأكمله. يولّد الوكيل بيانات جديدة في كل تكرار للحلقة، وتلك المعلومات تحتاج إلى تنقية دورية.

لماذا نوفر الرموز؟ تماما كالإنسان، يفقد النموذج اللغوي الكبير تركيزه بعد نقطة معينة. ويُسمى التراجع في قدرة النموذج على الاسترجاع الدقيق مع زيادة عدد الرموز بـ"تلف السياق"، وهو يظهر في جميع النماذج بدرجات متفاوتة. السبب الجذري هو بنية المحول: كل رمز ينتبه إلى كل رمز آخر، فتكون العلاقات بين n رمزاً بمقدار n تربيع. كلما طال السياق، تمددت ميزانية الانتباه وخفّت. لهذا يجب التعامل مع السياق باعتباره موردا محدودا لا مستودعا لا نهائيا. الهدف هو إيجاد الحد الأدنى من الرموز عالية الإشارة الأكثر قدرة على إنتاج النتيجة المطلوبة.

## بنية مشكلة ذاكرة الوكيل

تتطلب المهام طويلة الأمد الحفاظ على التماسك والتوجه نحو الهدف عبر سلسلة من الإجراءات تتجاوز بكثير نافذة السياق - كترحيل قواعد الكود الضخمة أو جلسات البحث الممتدة لساعات. مجرد تكديس كل شيء في النافذة ينهار تحت وطأة تلف السياق. الحل هو نقل المعلومات خارج النافذة واسترجاعها فقط عند الحاجة. يوضح المخطط التالي هيكل هذا النهج.

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
<div class="d3-arch" data-arch-root id="memorycontextengineering-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1123, "height": 430, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "LOOP", "x": 24, "y": 290, "w": 120, "h": 46, "title": "Agent Loop"}, {"id": "FULL", "x": 222, "y": 88, "w": 181, "h": 52, "title": "Context limit near?"}, {"id": "COMPACT", "x": 596, "y": 141, "w": 205, "h": 62, "title": ["Compaction: summarize and", "restart in new window"]}, {"id": "NOTE", "x": 603, "y": 24, "w": 191, "h": 62, "title": ["Structured notes: write", "key facts to file"]}, {"id": "STORE", "x": 879, "y": 141, "w": 212, "h": 62, "title": ["File-based memory (outside", "window)"]}, {"id": "SUB", "x": 228, "y": 260, "w": 170, "h": 46, "title": "Sub-agent delegation"}, {"id": "DISTILL", "x": 600, "y": 282, "w": 198, "h": 62, "title": ["Return 1,000-2,000 token", "summary only"]}], "edges": [{"src": "LOOP", "dst": "FULL", "kind": "data", "curve": [[95, 290], [183, 114], [183, 114], [222, 114]]}, {"src": "FULL", "dst": "COMPACT", "kind": "data", "label": "Yes", "curve": [[396, 140], [500, 172], [500, 172], [596, 172]], "off": "50%"}, {"src": "FULL", "dst": "NOTE", "kind": "data", "label": "No", "curve": [[396, 88], [500, 55], [500, 55], [603, 55]], "off": "50%"}, {"src": "NOTE", "dst": "STORE", "kind": "data", "curve": [[794, 55], [840, 55], [840, 55], [947, 141]]}, {"src": "COMPACT", "dst": "STORE", "kind": "data", "line": [801, 172, 879, 172]}, {"src": "LOOP", "dst": "SUB", "kind": "data", "line": [144, 294, 228, 283]}, {"src": "SUB", "dst": "DISTILL", "kind": "data", "curve": [[398, 283], [500, 283], [500, 283], [600, 298]]}, {"src": "DISTILL", "dst": "LOOP", "kind": "data", "curve": [[600, 328], [500, 343], [183, 343], [144, 331]]}, {"src": "STORE", "dst": "LOOP", "kind": "data", "label": "Reload after reset", "curve": [[965, 203], [699, 391], [313, 391], [113, 336]], "off": "50%"}]});
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
      const container = document.getElementById('memorycontextengineering-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'memorycontextengineering-1';
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

هدف هذا الهيكل بسيط: عزل سياق العمل التفصيلي خارج النافذة، والإبقاء داخل نافذة الوكيل الرئيسي فقط على الرموز عالية الإشارة اللازمة لاتخاذ القرارات.

## التقنيات الأربع

### الضغط

الضغط هو تلخيص نافذة السياق حين تقترب من حدودها، ثم إعادة تشغيل نافذة جديدة بدءا من ذلك الملخص. هذا هو الرافعة الأولى لتحسين التماسك على المدى البعيد. المفتاح هو الملخص عالي الدقة: الضغط الكثيف لمحتوى النافذة يتيح للوكيل مواصلة العمل بأدنى قدر من تدهور الأداء. يطبّق Claude Code هذا النهج مثلا بتمرير سجل الرسائل إلى النموذج لتلخيص أهم التفاصيل وضغطها. إذا تم الضغط بصورة صحيحة، يواصل الوكيل عمله دون انقطاع يُذكر.

### تدوين الملاحظات المنظم

يعني تدوين الملاحظات المنظم أن يكتب الوكيل المعلومات الجوهرية في ملف خارج نافذة السياق أثناء العمل، ثم يعود لقراءتها لاحقا. حتى بعد إعادة ضبط السياق، يقرأ الوكيل ملاحظاته ويستأنف مهمة استغرقت ساعات من حيث توقفت. هذا التماسك العابر لعمليات إعادة الضبط يجعل الاستراتيجيات طويلة المدى ممكنة دون الحاجة إلى الاحتفاظ بكل شيء في النافذة في آن واحد. المبدأ مشابه لتدوين شخص ملاحظات خلال اجتماع، ثم استرجاع السياق منها في الاجتماع التالي.

### معمارية الوكلاء الفرعيين

الوكلاء الفرعيون هم مسار آخر للتحايل على حدود السياق. بدلا من أن يحمل وكيل واحد حالة المشروع بأكملها، يتولى وكلاء فرعيون متخصصون مهاما ضيقة بنوافذ سياق نظيفة. يتولى الوكيل الرئيسي التنسيق على مستوى عالٍ، بينما ينفذ الوكلاء الفرعيون العمل التقني العميق أو الاستكشاف. يمكن لكل وكيل فرعي استخدام عشرات الآلاف من الرموز في استكشاف واسع النطاق، لكنه لا يعيد إلى الوكيل الرئيسي إلا ملخصا منقحا يتراوح بين 1,000 و 2,000 رمز. يبقى سياق الاستكشاف التفصيلي معزولا داخل الوكيل الفرعي، وتظل نافذة الوكيل الرئيسي نظيفة ومركزة على اتخاذ القرارات.

### أدوات الذاكرة المستندة إلى الملفات

بالتزامن مع إطلاق Sonnet 4.5، أتاحت Anthropic أدوات ذاكرة مستندة إلى الملفات بوصفها نسخة تجريبية عامة على منصة Claude للمطورين. تستخدم هذه الأدوات نظام الملفات لتخزين المعلومات خارج نافذة السياق واسترجاعها بسهولة لاحقا. بفضلها، يستطيع الوكيل بناء قاعدة معرفية بمرور الوقت، والحفاظ على حالة المشروع عبر جلسات متعددة، والرجوع إلى العمل السابق دون الاحتفاظ بكل شيء في النافذة. إن كانت التقنيات الثلاث السابقة مبادئ، فهذه الأداة هي تنفيذ تلك المبادئ في واجهة موحدة.

## المقارنة مع الأساليب الأبسط

لإدراك قيمة هذه التقنيات، من المفيد مقارنتها بالبدائل الشائعة. البديل الأول هو حشو كل شيء في نافذة سياق كبيرة: بسيط، لكنه ينهار تحت تلف السياق، وإعادة قراءة السجل الضخم كاملا في كل دورة يجعل التكاليف تنمو بصورة خطية. البديل الثاني هو RAG المبني على البحث الاتجاهي: قوي في جلب المعرفة الخارجية، لكنه غير ملائم لمعالجة الحالة التي ينشئها الوكيل ذاته أثناء العمل - القرارات الوسيطة، والتقدم المحرز، والملاحظات الذاتية. RAG مُحسَّن للقراءة لا للكتابة والتحديث.

تسد الذاكرة المستندة إلى الملفات والملاحظات المنظمة هذه الثغرة، لأنها توفر مخزنا للحالة يستطيع الوكيل الكتابة فيه والتحديث منه والقراءة منه بعد إعادة الضبط. مبدأ مكمل هو الاسترجاع في الوقت المناسب: بدلا من تحميل كل المعلومات في النافذة مسبقا، يحتفظ الوكيل بمعرّفات خفيفة فقط - مسارات الملفات، وإدخالات الفهرس - ولا يقرأ المحتوى الكامل إلا عند الحاجة الفعلية. الضغط والملاحظات والوكلاء الفرعيون والاسترجاع في الوقت المناسب لا تتعارض بل تتعاضد وتتقوى معا.

## كيف تطبّق ThakiCloud هذه التقنيات

هذه التقنيات الأربع ليست نظرية مجردة؛ فهي تشكل العمود الفقري للعمليات اليومية لوكلاء ThakiCloud. تنفذ منصتنا الداخلية معمارية ذاكرة مستندة إلى الملفات بثلاث طبقات: فهرس `MEMORY.md` يُحمَّل في كل جلسة ويحتوي على مؤشرات من سطر واحد، وتفاصيل الوقائع في `memory/topics/`، وسجلات العمل الطويلة في `memory/sessions/`. تحميل الفهرس وحده في السياق وسحب التفاصيل عند الطلب هو بالضبط دمج تدوين الملاحظات المنظم والذاكرة المستندة إلى الملفات والاسترجاع في الوقت المناسب.

يبدو الفهرس تقريبا كمجموعة مؤشرات أحادية السطر:

```markdown
- [Model Routing](feedback_model_routing.md) - sub-agent model stacking: low-cost for exploration, mid-tier for implementation, high-cost for architecture
- [Hermes Ecosystem](project_hermes_ecosystem.md) - installation record for the standalone agent framework
```

يحتوي كل إدخال على حقيقة واحدة في ملف واحد، مع روابط إلى ملفات ذاكرة أخرى داخل المحتوى. تقرأ الجلسة هذا الفهرس فقط، وتفتح محتوى أي إدخال ذي صلة في اللحظة التي يصبح فيها ضروريا. عند ظهور حقائق جديدة، تُحدَّث الملفات الموجودة. تُحذف الذكريات التي يتبين خطؤها. هذه الصيانة الدورية تمنع الملاحظات الفاسدة من الانتشار.

التفويض إلى وكلاء فرعيين يسير بالمنهج ذاته. المسح الشامل لقواعد الكود أو عمليات البحث الضخمة لا تُنفَّذ في السياق الرئيسي؛ بل تُفوَّض إلى وكيل فرعي بنموذج منخفض التكلفة يعيد ملخصا للاستنتاجات فحسب. عدم إغراق السياق الرئيسي بالمخرجات الخام يتطابق تماما مع ما أوصت به Anthropic: "يعيد الوكيل الفرعي ملخصا من 1,000 إلى 2,000 رمز فقط." هذا يمنع تكاليف إعادة قراءة ذاكرة التخزين المؤقت من النمو الخطي.

الضغط متأصل أيضا في الانضباط التشغيلي. نحافظ على استخدام السياق أقل من 40% ونوصي بتشغيل الضغط اليدوي قبل بلوغ 60%. الضغط بتركيز مقصود قبل تفعيل الضغط التلقائي يُنتج دقة أعلى. في بيئة متعددة المستأجرين، هذه ليست مسألة جودة فحسب بل مسألة تكلفة أيضا. إعادة قراءة سياق ضخم في كل دورة تجعل رموز ذاكرة التخزين المؤقت تشكل جزءا كبيرا من إجمالي التكلفة. التعامل مع السياق كمورد محدود هو الطريق إلى خفض تكلفة الاستدلال لكل وحدة.

من منظور المنصة، تُعد ذاكرة الوكيل كفاءة أساسية تحتاجها ThakiCloud لتشغيل وكلاء طويلي الأمد لعملاء متعددين بشكل موثوق على بنية تحتية مشتركة. الوكيل الذي يحافظ على حالته عبر جلسات مع إبقاء سياقه خفيفا هو في حد ذاته منتج قابل للنشر. القدرة على عزل طبقة الذاكرة هذه لكل مستأجر على منصة Kubernetes متعددة المستأجرين تمثل ميزة تنافسية محورية في ما نقدمه.

## القيود والاعتراضات

لكل تقنية تكاليفها. الضغط يفقد معلومات في مرحلة التلخيص؛ اختيار ما يُحذف بصورة خاطئة قد يُعطل العمل اللاحق. التلخيص عالي الدقة مشكلة صعبة في حد ذاتها، وتعتمد النتائج اعتمادا كبيرا على جودة تلقين التلخيص.

الملاحظات المنظمة والذاكرة المستندة إلى الملفات تنشر الفساد حين تكون الملاحظات خاطئة. حقيقة مكتوبة بصورة غلط في ملف تُعامَل كحقيقة من قِبل كل جلسة لاحقة. لهذا يلزم وجود بوابة لما يُكتب في الذاكرة، مع صيانة دورية لحذف الوقائع القديمة.

تصبح الوكلاء الفرعيون عبئا حين تُرسم حدود التفويض بصورة خاطئة. تفويض تعديلات الملف الواحد أو الاستعلامات البسيطة إلى وكيل فرعي يضيف تكاليف إرسال بدلا من توفير السياق. التفويض أداة لنظافة السياق الرئيسي، لا الخيار الافتراضي لكل مهمة.

أخيرا، يجب الاعتراف بصدق بأن تحسن النماذج يقلل الحاجة إلى هذه الوصفات. النماذج الأقوى أصلا تُظهر قدرا أكبر من الاستقلالية مع هندسة أقل تقييدا. ومع ذلك، سيبقى مبدأ التعامل مع السياق كمورد محدود حتى مع تطور القدرات. قد تتغير التقنيات، لكن توجه الحفاظ على ميزانية الانتباه يظل صالحا.

## المصادر

- Anthropic، "الهندسة الفعّالة للسياق في وكلاء الذكاء الاصطناعي" (2025-09-29): [https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents](https://www.anthropic.com/engineering/effective-context-engineering-for-ai-agents)
- Anthropic، كتيب إدارة الذاكرة والسياق: [https://platform.claude.com/cookbook/tool-use-memory-cookbook](https://platform.claude.com/cookbook/tool-use-memory-cookbook)
