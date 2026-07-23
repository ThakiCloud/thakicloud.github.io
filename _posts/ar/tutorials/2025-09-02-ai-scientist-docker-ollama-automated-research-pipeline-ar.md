---
title: "عالم الذكاء الاصطناعي مع Docker و Ollama: بناء خطوط أنابيب البحث الآلي"
excerpt: "حول سير عمل البحث الخاص بك مع عالم الذكاء الاصطناعي من SakanaAI يعمل في بيئة OrbStack Docker. يوضح هذا الدليل الشامل كيفية إعداد خطوط أنابيب البحث الآلي على مدار 24/7 باستخدام النماذج اللغوية المحلية مثل Ollama و LM Studio مع إدارة الطوابير للتشغيل المستمر."
seo_title: "دليل إعداد عالم الذكاء الاصطناعي Docker Ollama - بناء خط أنابيب البحث الآلي - Thaki Cloud"
seo_description: "برنامج تعليمي كامل حول إعداد عالم الذكاء الاصطناعي من SakanaAI مع OrbStack Docker و Ollama و LM Studio للبحث الآلي. يتضمن إدارة الطوابير والمراقبة وأمثلة التشغيل على مدار 24/7 مع أدلة التنفيذ العملية."
date: 2025-09-02
last_modified_at: 2025-09-02
tags:
  - عالم-الذكاء-الاصطناعي
  - Docker
  - Ollama
  - LM-Studio
  - أتمتة-البحث
  - OrbStack
  - إدارة-الطوابير
  - البحث-العلمي
author_profile: true
toc: true
toc_label: "فهرس المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/ai-scientist-docker-ollama-automated-research-pipeline/"
lang: ar
permalink: /ar/tutorials/ai-scientist-docker-ollama-automated-research-pipeline/
published: false
categories:
  - tutorials
---

⏱️ **وقت القراءة المقدر**: 18 دقيقة

## مقدمة

تخيل وجود باحث ذكاء اصطناعي لا يكل ولا يمل يعمل على مدار 24/7، ينتج الأوراق البحثية، ويجري التجارب، ويدفع حدود الاكتشاف العلمي بينما أنت نائم. مع **عالم الذكاء الاصطناعي من SakanaAI** والبنية التحتية للنماذج اللغوية المحلية، لم تعد هذه خيالاً علمياً - بل واقع عملي يمكنك تنفيذه اليوم.

سيرشدك هذا الدليل الشامل خلال إعداد خط أنابيب بحث آلي باستخدام:
- **عالم الذكاء الاصطناعي من SakanaAI**: أول نظام في العالم للاكتشاف العلمي الآلي بالكامل
- **OrbStack Docker**: الحاويات خفيفة الوزن للنشر السلس
- **Ollama و LM Studio**: الاستدلال المحلي للنماذج اللغوية للبحث الفعال من حيث التكلفة والخصوصية
- **إدارة الطوابير**: التشغيل المستمر مع جدولة المهام الذكية

بحلول نهاية هذا البرنامج التعليمي، ستحصل على بيئة بحث قوية ومكتفية ذاتياً قادرة على إنتاج الأوراق العلمية عبر مجالات متعددة دون تدخل بشري مستمر.

## فهم عالم الذكاء الاصطناعي

### ما يجعل عالم الذكاء الاصطناعي ثورياً

يمثل [عالم الذكاء الاصطناعي من SakanaAI](https://github.com/SakanaAI/AI-Scientist) تغييراً جذرياً في البحث الآلي. على عكس أدوات الذكاء الاصطناعي التقليدية التي تساعد الباحثين، هذا النظام **يقوم بمشاريع بحثية كاملة بشكل مستقل**:

- **الأتمتة من البداية للنهاية**: من توليد الأفكار إلى كتابة الأوراق ومراجعة الأقران
- **دعم القوالب المتعددة**: مجالات بحث NanoGPT و 2D Diffusion و Grokking
- **التجريب الآلي**: يصمم وينفذ ويحلل التجارب
- **إنتاج أوراق LaTeX**: ينتج أوراقاً أكاديمية جاهزة للنشر
- **نظام مراجعة الأقران**: آليات تقييم مدمجة لتقييم الجودة

### نظرة عامة على هندسة النظام

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
<div class="d3-arch" data-arch-root id="omatedresearchpipelinear-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 184, "height": 1098, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 128, "h": 62, "title": ["🎯 توليد أفكار", "البحث"]}, {"id": "B", "x": 28, "y": 164, "w": 120, "h": 62, "title": ["🔬 تصميم", "التجارب"]}, {"id": "C", "x": 28, "y": 304, "w": 120, "h": 62, "title": ["⚙️ تنفيذ", "الكود"]}, {"id": "D", "x": 28, "y": 444, "w": 120, "h": 62, "title": ["🧪 تنفيذ", "التجارب"]}, {"id": "E", "x": 28, "y": 584, "w": 120, "h": 62, "title": ["📊 تحليل", "النتائج"]}, {"id": "F", "x": 28, "y": 724, "w": 120, "h": 62, "title": ["📝 كتابة", "الورقة"]}, {"id": "G", "x": 28, "y": 864, "w": 120, "h": 62, "title": ["📋 مراجعة", "الأقران"]}, {"id": "H", "x": 28, "y": 1004, "w": 120, "h": 62, "title": ["📄 الورقة", "النهائية"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [88, 86, 88, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [88, 226, 88, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [88, 366, 88, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [88, 506, 88, 584]}, {"src": "E", "dst": "F", "kind": "data", "line": [88, 646, 88, 724]}, {"src": "F", "dst": "G", "kind": "data", "line": [88, 786, 88, 864]}, {"src": "G", "dst": "H", "kind": "data", "line": [88, 926, 88, 1004]}]});
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
      const container = document.getElementById('omatedresearchpipelinear-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'omatedresearchpipelinear-1';
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

## المتطلبات المسبقة وإعداد البيئة

### متطلبات النظام

```bash
# الحد الأدنى لمتطلبات الأجهزة
- الذاكرة: 16GB (32GB موصى به للنماذج الأكبر)
- التخزين: 50GB مساحة حرة
- المعالج: 8+ أنوية (Apple Silicon أو x86_64)
- وحدة معالجة الرسوميات: اختيارية لكن موصى بها (NVIDIA RTX 3080+ أو Apple M-series)

# التبعيات البرمجية
- macOS 13+ أو Linux Ubuntu 20.04+
- OrbStack أو Docker Desktop
- Python 3.8+
- Git
```

### تثبيت OrbStack

يوفر OrbStack أداءً فائقاً مقارنة بـ Docker Desktop، خاصة على macOS:

```bash
# تثبيت OrbStack عبر Homebrew
brew install orbstack

# بدء خدمة OrbStack
orbstack start

# التحقق من التثبيت
orbstack --version
```

### إعداد Ollama

يوفر Ollama حلاً ممتازاً للاستدلال المحلي للنماذج اللغوية:

```bash
# تثبيت Ollama
curl -fsSL https://ollama.ai/install.sh | sh

# بدء خدمة Ollama
ollama serve

# تنزيل النماذج الموصى بها للبحث
ollama pull llama2:70b          # نموذج السياق الكبير
ollama pull codellama:34b       # توليد الكود
ollama pull mistral:7b          # الاستدلال السريع
ollama pull deepseek-coder:33b  # البرمجة المتقدمة

# التحقق من التثبيت
ollama list
```

### إعداد بديل LM Studio

لإدارة النماذج القائمة على واجهة المستخدم الرسومية:

```bash
# تنزيل LM Studio من https://lmstudio.ai/
# تثبيت وتكوين خادم API
# نقطة النهاية الافتراضية لـ API: http://localhost:1234/v1
```

## تثبيت وتكوين عالم الذكاء الاصطناعي

### استنساخ وإعداد المستودع

```bash
# استنساخ مستودع عالم الذكاء الاصطناعي
git clone https://github.com/SakanaAI/AI-Scientist.git
cd AI-Scientist

# إنشاء دليل مخصص لإعدادنا
mkdir -p ~/ai-research-lab
cd ~/ai-research-lab

# نسخ ملفات عالم الذكاء الاصطناعي
cp -r /path/to/AI-Scientist/* .
```

### تكوين بيئة Docker

إنشاء إعداد Docker شامل:

```dockerfile
# Dockerfile لعالم الذكاء الاصطناعي مع دعم النموذج اللغوي المحلي
FROM python:3.9-slim

# تثبيت تبعيات النظام
RUN apt-get update && apt-get install -y \
    git \
    wget \
    curl \
    build-essential \
    texlive-full \
    pandoc \
    && rm -rf /var/lib/apt/lists/*

# تعيين دليل العمل
WORKDIR /app

# نسخ المتطلبات وتثبيت تبعيات Python
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# تثبيت حزم إضافية للوظائف المحسنة
RUN pip install \
    ollama \
    openai \
    anthropic \
    tiktoken \
    matplotlib \
    seaborn \
    jupyter \
    notebook

# نسخ كود عالم الذكاء الاصطناعي
COPY . .

# إنشاء الأدلة الضرورية
RUN mkdir -p /app/results /app/logs /app/queue

# تعيين متغيرات البيئة
ENV PYTHONPATH=/app
ENV OLLAMA_HOST=host.docker.internal:11434
ENV LM_STUDIO_BASE_URL=http://host.docker.internal:1234/v1

# فتح المنافذ لـ Jupyter والمراقبة
EXPOSE 8888 8080

# إنشاء سكريبت البدء
COPY scripts/startup.sh /startup.sh
RUN chmod +x /startup.sh

CMD ["/startup.sh"]
```

### Docker Compose للمكدس الكامل

```yaml
# docker-compose.yml
version: '3.8'

services:
  ai-scientist:
    build: .
    container_name: ai-scientist-main
    volumes:
      - ./results:/app/results
      - ./logs:/app/logs
      - ./queue:/app/queue
      - ./templates:/app/templates
    ports:
      - "8888:8888"  # Jupyter
      - "8080:8080"  # لوحة المراقبة
    environment:
      - OLLAMA_HOST=host.docker.internal:11434
      - LM_STUDIO_BASE_URL=http://host.docker.internal:1234/v1
      - OPENAI_API_KEY=${OPENAI_API_KEY}
      - ANTHROPIC_API_KEY=${ANTHROPIC_API_KEY}
    depends_on:
      - redis
    networks:
      - ai-research-net

  redis:
    image: redis:7-alpine
    container_name: ai-scientist-redis
    ports:
      - "6379:6379"
    volumes:
      - redis_data:/data
    networks:
      - ai-research-net

  queue-manager:
    build: .
    container_name: ai-scientist-queue
    command: python scripts/queue_manager.py
    volumes:
      - ./queue:/app/queue
      - ./logs:/app/logs
    depends_on:
      - redis
      - ai-scientist
    networks:
      - ai-research-net

  monitoring:
    build: .
    container_name: ai-scientist-monitor
    command: python scripts/monitoring_dashboard.py
    ports:
      - "8081:8081"
    volumes:
      - ./logs:/app/logs
      - ./results:/app/results
    networks:
      - ai-research-net

volumes:
  redis_data:

networks:
  ai-research-net:
    driver: bridge
```

## تكامل النماذج اللغوية المحلية

### تكامل Ollama API

إنشاء عميل نموذج لغوي مخصص لـ Ollama:

```python
# scripts/ollama_client.py
import requests
import json
from typing import Dict, List, Optional
import logging

class OllamaClient:
    def __init__(self, base_url: str = "http://localhost:11434"):
        self.base_url = base_url
        self.logger = logging.getLogger(__name__)
    
    def generate(self, 
                model: str,
                prompt: str,
                temperature: float = 0.7,
                max_tokens: int = 4000,
                **kwargs) -> str:
        """توليد النص باستخدام Ollama API"""
        try:
            payload = {
                "model": model,
                "prompt": prompt,
                "stream": False,
                "options": {
                    "temperature": temperature,
                    "num_predict": max_tokens,
                    **kwargs
                }
            }
            
            response = requests.post(
                f"{self.base_url}/api/generate",
                json=payload,
                timeout=300
            )
            response.raise_for_status()
            
            result = response.json()
            return result.get("response", "")
            
        except Exception as e:
            self.logger.error(f"خطأ في توليد Ollama: {e}")
            raise
    
    def list_models(self) -> List[str]:
        """قائمة النماذج المتاحة"""
        try:
            response = requests.get(f"{self.base_url}/api/tags")
            response.raise_for_status()
            
            models = response.json().get("models", [])
            return [model["name"] for model in models]
            
        except Exception as e:
            self.logger.error(f"خطأ في سرد النماذج: {e}")
            return []
    
    def chat_completion(self,
                       model: str,
                       messages: List[Dict],
                       temperature: float = 0.7,
                       max_tokens: int = 4000) -> str:
        """إكمال المحادثة المتوافق مع OpenAI"""
        try:
            # تحويل الرسائل إلى مطالبة واحدة
            prompt = self._messages_to_prompt(messages)
            return self.generate(model, prompt, temperature, max_tokens)
            
        except Exception as e:
            self.logger.error(f"خطأ في إكمال المحادثة: {e}")
            raise
    
    def _messages_to_prompt(self, messages: List[Dict]) -> str:
        """تحويل تنسيق رسائل OpenAI إلى مطالبة"""
        prompt_parts = []
        
        for message in messages:
            role = message.get("role", "user")
            content = message.get("content", "")
            
            if role == "system":
                prompt_parts.append(f"النظام: {content}")
            elif role == "user":
                prompt_parts.append(f"المستخدم: {content}")
            elif role == "assistant":
                prompt_parts.append(f"المساعد: {content}")
        
        prompt_parts.append("المساعد:")
        return "\n\n".join(prompt_parts)

# اختبار العميل
if __name__ == "__main__":
    client = OllamaClient()
    print("النماذج المتاحة:", client.list_models())
    
    test_response = client.generate(
        model="llama2:7b",
        prompt="اشرح الحوسبة الكمية بمصطلحات بسيطة."
    )
    print("استجابة الاختبار:", test_response[:200] + "...")
```

### تكامل LM Studio

```python
# scripts/lm_studio_client.py
import openai
from typing import Dict, List
import logging

class LMStudioClient:
    def __init__(self, base_url: str = "http://localhost:1234/v1"):
        self.client = openai.OpenAI(
            base_url=base_url,
            api_key="lm-studio"  # مطلوب لكن يُتجاهل
        )
        self.logger = logging.getLogger(__name__)
    
    def generate(self, 
                model: str,
                prompt: str,
                temperature: float = 0.7,
                max_tokens: int = 4000,
                **kwargs) -> str:
        """توليد النص باستخدام LM Studio API"""
        try:
            messages = [{"role": "user", "content": prompt}]
            
            response = self.client.chat.completions.create(
                model=model,
                messages=messages,
                temperature=temperature,
                max_tokens=max_tokens,
                **kwargs
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            self.logger.error(f"خطأ في توليد LM Studio: {e}")
            raise
    
    def chat_completion(self,
                       model: str,
                       messages: List[Dict],
                       temperature: float = 0.7,
                       max_tokens: int = 4000) -> str:
        """إكمال المحادثة المباشر"""
        try:
            response = self.client.chat.completions.create(
                model=model,
                messages=messages,
                temperature=temperature,
                max_tokens=max_tokens
            )
            
            return response.choices[0].message.content
            
        except Exception as e:
            self.logger.error(f"خطأ في إكمال المحادثة: {e}")
            raise
    
    def list_models(self) -> List[str]:
        """قائمة النماذج المتاحة"""
        try:
            models = self.client.models.list()
            return [model.id for model in models.data]
            
        except Exception as e:
            self.logger.error(f"خطأ في سرد النماذج: {e}")
            return []

# اختبار العميل
if __name__ == "__main__":
    client = LMStudioClient()
    print("النماذج المتاحة:", client.list_models())
    
    test_response = client.generate(
        model="local-model",
        prompt="اشرح التعلم الآلي بمصطلحات بسيطة."
    )
    print("استجابة الاختبار:", test_response[:200] + "...")
```

## نظام إدارة الطوابير

### تنفيذ الطابور القائم على Redis

```python
# scripts/queue_manager.py
import redis
import json
import time
import logging
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from dataclasses import dataclass, asdict
from enum import Enum

class TaskStatus(Enum):
    PENDING = "pending"
    RUNNING = "running"
    COMPLETED = "completed"
    FAILED = "failed"
    CANCELLED = "cancelled"

@dataclass
class ResearchTask:
    id: str
    template: str
    model: str
    num_ideas: int
    priority: int = 1
    created_at: datetime = None
    started_at: datetime = None
    completed_at: datetime = None
    status: TaskStatus = TaskStatus.PENDING
    progress: int = 0
    error_message: str = ""
    results_path: str = ""
    
    def __post_init__(self):
        if self.created_at is None:
            self.created_at = datetime.now()

class QueueManager:
    def __init__(self, redis_host: str = "localhost", redis_port: int = 6379):
        self.redis_client = redis.Redis(
            host=redis_host, 
            port=redis_port, 
            decode_responses=True
        )
        self.logger = logging.getLogger(__name__)
        
        # مفاتيح الطابور
        self.pending_queue = "ai_scientist:pending"
        self.running_queue = "ai_scientist:running"
        self.completed_queue = "ai_scientist:completed"
        self.failed_queue = "ai_scientist:failed"
        self.task_data = "ai_scientist:tasks"
    
    def add_task(self, task: ResearchTask) -> str:
        """إضافة مهمة بحث جديدة إلى الطابور"""
        try:
            # تخزين بيانات المهمة
            task_json = json.dumps(asdict(task), default=str)
            self.redis_client.hset(self.task_data, task.id, task_json)
            
            # إضافة إلى طابور الانتظار مع الأولوية
            self.redis_client.zadd(
                self.pending_queue, 
                {task.id: task.priority}
            )
            
            self.logger.info(f"تم إضافة المهمة {task.id} إلى الطابور")
            return task.id
            
        except Exception as e:
            self.logger.error(f"خطأ في إضافة المهمة: {e}")
            raise
    
    def get_next_task(self) -> Optional[ResearchTask]:
        """الحصول على المهمة التالية ذات الأولوية العليا"""
        try:
            # الحصول على مهمة الأولوية العليا
            task_ids = self.redis_client.zrevrange(
                self.pending_queue, 0, 0
            )
            
            if not task_ids:
                return None
            
            task_id = task_ids[0]
            
            # الانتقال إلى طابور التشغيل
            self.redis_client.zrem(self.pending_queue, task_id)
            self.redis_client.sadd(self.running_queue, task_id)
            
            # الحصول على بيانات المهمة
            task_data = self.redis_client.hget(self.task_data, task_id)
            if not task_data:
                return None
            
            task_dict = json.loads(task_data)
            task = ResearchTask(**task_dict)
            task.status = TaskStatus.RUNNING
            task.started_at = datetime.now()
            
            # تحديث المهمة
            self.update_task(task)
            
            return task
            
        except Exception as e:
            self.logger.error(f"خطأ في الحصول على المهمة التالية: {e}")
            return None
    
    def update_task(self, task: ResearchTask):
        """تحديث حالة وبيانات المهمة"""
        try:
            task_json = json.dumps(asdict(task), default=str)
            self.redis_client.hset(self.task_data, task.id, task_json)
            
        except Exception as e:
            self.logger.error(f"خطأ في تحديث المهمة: {e}")
    
    def complete_task(self, task_id: str, results_path: str = ""):
        """وضع علامة على المهمة كمكتملة"""
        try:
            task = self.get_task(task_id)
            if not task:
                return
            
            # الانتقال إلى طابور المكتملة
            self.redis_client.srem(self.running_queue, task_id)
            self.redis_client.sadd(self.completed_queue, task_id)
            
            # تحديث المهمة
            task.status = TaskStatus.COMPLETED
            task.completed_at = datetime.now()
            task.progress = 100
            task.results_path = results_path
            
            self.update_task(task)
            self.logger.info(f"تم إكمال المهمة {task_id}")
            
        except Exception as e:
            self.logger.error(f"خطأ في إكمال المهمة: {e}")
    
    def fail_task(self, task_id: str, error_message: str = ""):
        """وضع علامة على المهمة كفاشلة"""
        try:
            task = self.get_task(task_id)
            if not task:
                return
            
            # الانتقال إلى طابور الفاشلة
            self.redis_client.srem(self.running_queue, task_id)
            self.redis_client.sadd(self.failed_queue, task_id)
            
            # تحديث المهمة
            task.status = TaskStatus.FAILED
            task.completed_at = datetime.now()
            task.error_message = error_message
            
            self.update_task(task)
            self.logger.error(f"فشلت المهمة {task_id}: {error_message}")
            
        except Exception as e:
            self.logger.error(f"خطأ في فشل المهمة: {e}")
    
    def get_task(self, task_id: str) -> Optional[ResearchTask]:
        """الحصول على المهمة بواسطة ID"""
        try:
            task_data = self.redis_client.hget(self.task_data, task_id)
            if not task_data:
                return None
            
            task_dict = json.loads(task_data)
            return ResearchTask(**task_dict)
            
        except Exception as e:
            self.logger.error(f"خطأ في الحصول على المهمة: {e}")
            return None
    
    def get_queue_stats(self) -> Dict[str, int]:
        """الحصول على إحصائيات الطابور"""
        try:
            return {
                "pending": self.redis_client.zcard(self.pending_queue),
                "running": self.redis_client.scard(self.running_queue),
                "completed": self.redis_client.scard(self.completed_queue),
                "failed": self.redis_client.scard(self.failed_queue)
            }
            
        except Exception as e:
            self.logger.error(f"خطأ في الحصول على إحصائيات الطابور: {e}")
            return {}
    
    def list_tasks(self, status: TaskStatus = None) -> List[ResearchTask]:
        """قائمة المهام حسب الحالة"""
        try:
            if status == TaskStatus.PENDING:
                task_ids = self.redis_client.zrevrange(self.pending_queue, 0, -1)
            elif status == TaskStatus.RUNNING:
                task_ids = list(self.redis_client.smembers(self.running_queue))
            elif status == TaskStatus.COMPLETED:
                task_ids = list(self.redis_client.smembers(self.completed_queue))
            elif status == TaskStatus.FAILED:
                task_ids = list(self.redis_client.smembers(self.failed_queue))
            else:
                # الحصول على جميع المهام
                task_ids = list(self.redis_client.hkeys(self.task_data))
            
            tasks = []
            for task_id in task_ids:
                task = self.get_task(task_id)
                if task:
                    tasks.append(task)
            
            return tasks
            
        except Exception as e:
            self.logger.error(f"خطأ في سرد المهام: {e}")
            return []

# عملية العامل
class ResearchWorker:
    def __init__(self, queue_manager: QueueManager):
        self.queue_manager = queue_manager
        self.logger = logging.getLogger(__name__)
        self.running = False
    
    def start(self):
        """بدء عملية العامل"""
        self.running = True
        self.logger.info("تم بدء عامل البحث")
        
        while self.running:
            try:
                task = self.queue_manager.get_next_task()
                
                if task:
                    self.logger.info(f"معالجة المهمة: {task.id}")
                    self.process_task(task)
                else:
                    # لا توجد مهام متاحة، انتظار
                    time.sleep(10)
                    
            except KeyboardInterrupt:
                self.logger.info("تم مقاطعة العامل")
                break
            except Exception as e:
                self.logger.error(f"خطأ في العامل: {e}")
                time.sleep(30)
    
    def process_task(self, task: ResearchTask):
        """معالجة مهمة البحث"""
        try:
            # استيراد وحدات عالم الذكاء الاصطناعي
            import subprocess
            import os
            
            # تحضير الأمر
            cmd = [
                "python", "launch_scientist.py",
                "--model", task.model,
                "--experiment", task.template,
                "--num-ideas", str(task.num_ideas),
                "--out-dir", f"results/{task.id}"
            ]
            
            # تحديث التقدم
            task.progress = 10
            self.queue_manager.update_task(task)
            
            # تنفيذ عالم الذكاء الاصطناعي
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=3600  # مهلة زمنية ساعة واحدة
            )
            
            if result.returncode == 0:
                # نجح
                results_path = f"results/{task.id}"
                self.queue_manager.complete_task(task.id, results_path)
                self.logger.info(f"تم إكمال المهمة {task.id} بنجاح")
            else:
                # فشل
                error_msg = result.stderr or "خطأ غير معروف"
                self.queue_manager.fail_task(task.id, error_msg)
                self.logger.error(f"فشلت المهمة {task.id}: {error_msg}")
                
        except subprocess.TimeoutExpired:
            self.queue_manager.fail_task(task.id, "انتهت مهلة المهمة")
        except Exception as e:
            self.queue_manager.fail_task(task.id, str(e))
    
    def stop(self):
        """إيقاف عملية العامل"""
        self.running = False
        self.logger.info("تم إيقاف عامل البحث")

# التنفيذ الرئيسي
if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    
    # تهيئة مدير الطابور
    queue_manager = QueueManager()
    
    # إنشاء وبدء العامل
    worker = ResearchWorker(queue_manager)
    
    try:
        worker.start()
    except KeyboardInterrupt:
        worker.stop()
```

## المراقبة والإدارة

### لوحة المعلومات في الوقت الفعلي

```python
# scripts/monitoring_dashboard.py
import streamlit as st
import plotly.express as px
import plotly.graph_objects as go
import pandas as pd
import time
from datetime import datetime, timedelta
from queue_manager import QueueManager, TaskStatus

st.set_page_config(
    page_title="لوحة معلومات عالم الذكاء الاصطناعي",
    page_icon="🧑‍🔬",
    layout="wide"
)

class MonitoringDashboard:
    def __init__(self):
        self.queue_manager = QueueManager()
    
    def render_header(self):
        """عرض رأس لوحة المعلومات"""
        st.title("🧑‍🔬 لوحة معلومات بحث عالم الذكاء الاصطناعي")
        st.markdown("مراقبة في الوقت الفعلي لخط أنابيب البحث الآلي")
        
        # زر التحديث
        if st.button("🔄 تحديث", key="refresh"):
            st.rerun()
    
    def render_queue_stats(self):
        """عرض إحصائيات الطابور"""
        stats = self.queue_manager.get_queue_stats()
        
        col1, col2, col3, col4 = st.columns(4)
        
        with col1:
            st.metric("⏳ في الانتظار", stats.get("pending", 0))
        
        with col2:
            st.metric("🔄 قيد التشغيل", stats.get("running", 0))
        
        with col3:
            st.metric("✅ مكتملة", stats.get("completed", 0))
        
        with col4:
            st.metric("❌ فاشلة", stats.get("failed", 0))
    
    def render_task_timeline(self):
        """عرض مخطط الجدول الزمني للمهام"""
        st.subheader("📊 الجدول الزمني للمهام")
        
        # الحصول على جميع المهام
        all_tasks = self.queue_manager.list_tasks()
        
        if not all_tasks:
            st.info("لم يتم العثور على مهام")
            return
        
        # تحضير البيانات للجدول الزمني
        timeline_data = []
        for task in all_tasks:
            timeline_data.append({
                "معرف المهمة": task.id[:8],
                "القالب": task.template,
                "النموذج": task.model,
                "الحالة": task.status.value,
                "تم الإنشاء": task.created_at,
                "تم البدء": task.started_at,
                "تم الإكمال": task.completed_at,
                "المدة": self._calculate_duration(task)
            })
        
        df = pd.DataFrame(timeline_data)
        
        # مخطط دائري لتوزيع الحالة
        col1, col2 = st.columns(2)
        
        with col1:
            status_counts = df["الحالة"].value_counts()
            fig_pie = px.pie(
                values=status_counts.values,
                names=status_counts.index,
                title="توزيع حالة المهام"
            )
            st.plotly_chart(fig_pie, use_container_width=True)
        
        with col2:
            # هيستوغرام المدة
            completed_tasks = df[df["الحالة"] == "completed"]
            if not completed_tasks.empty:
                fig_hist = px.histogram(
                    completed_tasks,
                    x="المدة",
                    title="توزيع مدة المهام (دقائق)",
                    nbins=20
                )
                st.plotly_chart(fig_hist, use_container_width=True)
            else:
                st.info("لا توجد مهام مكتملة بعد")
    
    def render_task_list(self):
        """عرض قائمة المهام التفصيلية"""
        st.subheader("📋 تفاصيل المهام")
        
        # فلتر الحالة
        status_filter = st.selectbox(
            "تصفية حسب الحالة",
            ["الكل", "pending", "running", "completed", "failed"]
        )
        
        # الحصول على المهام المفلترة
        if status_filter == "الكل":
            tasks = self.queue_manager.list_tasks()
        else:
            tasks = self.queue_manager.list_tasks(TaskStatus(status_filter))
        
        if not tasks:
            st.info(f"لم يتم العثور على مهام {status_filter}")
            return
        
        # إنشاء جدول المهام
        task_data = []
        for task in tasks:
            task_data.append({
                "المعرف": task.id[:8] + "...",
                "القالب": task.template,
                "النموذج": task.model,
                "الأفكار": task.num_ideas,
                "الحالة": task.status.value.title(),
                "التقدم": f"{task.progress}%",
                "تم الإنشاء": task.created_at.strftime("%Y-%m-%d %H:%M") if task.created_at else "غير متاح",
                "المدة": self._calculate_duration(task),
                "الخطأ": task.error_message[:50] + "..." if len(task.error_message) > 50 else task.error_message
            })
        
        df = pd.DataFrame(task_data)
        st.dataframe(df, use_container_width=True)
    
    def render_resource_usage(self):
        """عرض مقاييس استخدام الموارد"""
        st.subheader("💻 استخدام الموارد")
        
        # يجب أن يتصل بمقاييس النظام الفعلية
        # لأغراض العرض التوضيحي، عرض بيانات وهمية
        col1, col2, col3 = st.columns(3)
        
        with col1:
            # محاكاة استخدام المعالج
            cpu_usage = 65  # يجب أن يأتي من المراقبة الفعلية
            fig_cpu = go.Figure(go.Indicator(
                mode="gauge+number",
                value=cpu_usage,
                domain={'x': [0, 1], 'y': [0, 1]},
                title={'text': "استخدام المعالج %"},
                gauge={'axis': {'range': [None, 100]},
                       'bar': {'color': "darkblue"},
                       'steps': [
                           {'range': [0, 50], 'color': "lightgray"},
                           {'range': [50, 80], 'color': "yellow"},
                           {'range': [80, 100], 'color': "red"}
                       ]}
            ))
            fig_cpu.update_layout(height=250)
            st.plotly_chart(fig_cpu, use_container_width=True)
        
        with col2:
            # محاكاة استخدام الذاكرة
            mem_usage = 78
            fig_mem = go.Figure(go.Indicator(
                mode="gauge+number",
                value=mem_usage,
                domain={'x': [0, 1], 'y': [0, 1]},
                title={'text': "استخدام الذاكرة %"},
                gauge={'axis': {'range': [None, 100]},
                       'bar': {'color': "darkgreen"},
                       'steps': [
                           {'range': [0, 50], 'color': "lightgray"},
                           {'range': [50, 80], 'color': "yellow"},
                           {'range': [80, 100], 'color': "red"}
                       ]}
            ))
            fig_mem.update_layout(height=250)
            st.plotly_chart(fig_mem, use_container_width=True)
        
        with col3:
            # محاكاة استخدام وحدة معالجة الرسوميات (إن وجدت)
            gpu_usage = 45
            fig_gpu = go.Figure(go.Indicator(
                mode="gauge+number",
                value=gpu_usage,
                domain={'x': [0, 1], 'y': [0, 1]},
                title={'text': "استخدام وحدة معالجة الرسوميات %"},
                gauge={'axis': {'range': [None, 100]},
                       'bar': {'color': "darkred"},
                       'steps': [
                           {'range': [0, 50], 'color': "lightgray"},
                           {'range': [50, 80], 'color': "yellow"},
                           {'range': [80, 100], 'color': "red"}
                       ]}
            ))
            fig_gpu.update_layout(height=250)
            st.plotly_chart(fig_gpu, use_container_width=True)
    
    def render_logs(self):
        """عرض السجلات الأخيرة"""
        st.subheader("📜 السجلات الأخيرة")
        
        # يجب أن يقرأ من ملفات السجل الفعلية
        # لأغراض العرض التوضيحي، عرض البيانات الوهمية
        log_entries = [
            "2025-09-02 14:30:15 - معلومات - بدأت معالجة المهمة 12345678",
            "2025-09-02 14:28:42 - معلومات - تم تحميل نموذج Ollama llama2:70b بنجاح",
            "2025-09-02 14:25:10 - معلومات - تم إضافة مهمة جديدة إلى الطابور: nanoGPT_lite",
            "2025-09-02 14:22:33 - معلومات - تم إكمال المهمة 87654321 بنجاح",
            "2025-09-02 14:20:15 - خطأ - فشلت المهمة 11111111: انتهت مهلة الاتصال"
        ]
        
        for entry in log_entries:
            level = "معلومات" if "معلومات" in entry else "خطأ" if "خطأ" in entry else "تحذير"
            if level == "معلومات":
                st.info(entry)
            elif level == "خطأ":
                st.error(entry)
            else:
                st.warning(entry)
    
    def _calculate_duration(self, task) -> str:
        """حساب مدة المهمة"""
        if task.completed_at and task.started_at:
            duration = task.completed_at - task.started_at
            return f"{duration.total_seconds() / 60:.1f} دقيقة"
        elif task.started_at:
            duration = datetime.now() - task.started_at
            return f"{duration.total_seconds() / 60:.1f} دقيقة (جارية)"
        else:
            return "لم تبدأ"
    
    def run(self):
        """تشغيل لوحة المعلومات"""
        self.render_header()
        
        # تحديث تلقائي كل 30 ثانية
        if "last_refresh" not in st.session_state:
            st.session_state.last_refresh = time.time()
        
        if time.time() - st.session_state.last_refresh > 30:
            st.session_state.last_refresh = time.time()
            st.rerun()
        
        # المحتوى الرئيسي
        self.render_queue_stats()
        st.divider()
        
        self.render_task_timeline()
        st.divider()
        
        self.render_task_list()
        st.divider()
        
        self.render_resource_usage()
        st.divider()
        
        self.render_logs()

# تشغيل لوحة المعلومات
if __name__ == "__main__":
    dashboard = MonitoringDashboard()
    dashboard.run()
```

## أمثلة التنفيذ العملي

### المثال 1: بحث متعدد القوالب على مدار 24/7

```bash
#!/bin/bash
# scripts/deploy_ai_scientist_24_7.sh

echo "🚀 نشر خط أنابيب بحث عالم الذكاء الاصطناعي على مدار 24/7"

# تعيين متغيرات البيئة
export OLLAMA_HOST="localhost:11434"
export LM_STUDIO_BASE_URL="http://localhost:1234/v1"

# بدء OrbStack
echo "بدء OrbStack..."
orbstack start

# بدء Ollama
echo "بدء Ollama..."
ollama serve &
OLLAMA_PID=$!

# انتظار حتى يصبح Ollama جاهزاً
echo "انتظار حتى يصبح Ollama جاهزاً..."
sleep 10

# سحب النماذج المطلوبة إذا لم تكن موجودة
echo "التأكد من توفر النماذج..."
ollama pull llama2:70b &
ollama pull codellama:34b &
ollama pull mistral:7b &
ollama pull deepseek-coder:33b &
wait

# بدء مكدس Docker Compose
echo "بدء مكدس عالم الذكاء الاصطناعي..."
cd ~/ai-research-lab
docker-compose up -d

# انتظار حتى تصبح الخدمات جاهزة
echo "انتظار تهيئة الخدمات..."
sleep 30

# إرسال دفعة البحث الأولية
echo "إرسال مهام البحث الأولية..."
python scripts/task_submitter.py --batch

# بدء الجدولة الذكية
echo "بدء الجدولة الذكية..."
python scripts/intelligent_scheduler.py &
SCHEDULER_PID=$!

# بدء مراقبة الموارد
echo "بدء مراقبة الموارد..."
python scripts/resource_monitor.py &
MONITOR_PID=$!

echo "✅ تم نشر خط أنابيب عالم الذكاء الاصطناعي على مدار 24/7 بنجاح!"
echo ""
echo "🌐 نقاط الوصول:"
echo "  - لوحة المراقبة: http://localhost:8081"
echo "  - دفتر Jupyter: http://localhost:8888"
echo "  - إحصائيات الطابور: راجع السجلات أو لوحة المعلومات"
echo ""
echo "📊 للمراقبة:"
echo "  docker-compose logs -f"
echo "  tail -f logs/scheduler.log"
echo "  tail -f logs/resource_monitor.log"
echo ""
echo "🛑 للتوقف:"
echo "  docker-compose down"
echo "  kill $OLLAMA_PID $SCHEDULER_PID $MONITOR_PID"

# حفظ PIDs للتنظيف
echo "$OLLAMA_PID $SCHEDULER_PID $MONITOR_PID" > .ai_scientist_pids

echo "خط الأنابيب يعمل الآن على مدار 24/7. اضغط Ctrl+C للتوقف."

# انتظار المقاطعة
trap 'echo "إيقاف خط أنابيب عالم الذكاء الاصطناعي..."; docker-compose down; kill $OLLAMA_PID $SCHEDULER_PID $MONITOR_PID; exit' INT
while true; do sleep 1; done
```

## حل المشاكل والتحسين

### المشاكل الشائعة والحلول

#### المشكلة 1: فشل اتصال Ollama

```bash
# تشخيص اتصال Ollama
curl http://localhost:11434/api/tags

# فحص سجلات Ollama
journalctl -u ollama --follow

# إعادة تشغيل خدمة Ollama
sudo systemctl restart ollama

# البديل: إعادة التشغيل اليدوي
pkill ollama
ollama serve
```

#### المشكلة 2: مشاكل ذاكرة Docker

```yaml
# docker-compose.override.yml
version: '3.8'

services:
  ai-scientist:
    deploy:
      resources:
        limits:
          memory: 16G
          cpus: '8'
        reservations:
          memory: 8G
          cpus: '4'
    environment:
      - MALLOC_ARENA_MAX=2
      - PYTHONHASHSEED=0
```

### نصائح تحسين الأداء

1. **استراتيجية اختيار النموذج**:
   ```python
   # استخدام نماذج أصغر للتجارب الأولية
   quick_models = ["mistral:7b", "llama2:13b"]
   
   # استخدام نماذج أكبر للتحقق النهائي
   powerful_models = ["llama2:70b", "deepseek-coder:33b"]
   ```

2. **إدارة الموارد**:
   ```bash
   # تحديد المهام المتزامنة حسب قدرة النظام
   export MAX_CONCURRENT_TASKS=2
   
   # استخدام تخزين سريع للملفات المؤقتة
   export TMPDIR=/tmp/ai-scientist-fast
   mkdir -p $TMPDIR
   ```

## الخلاصة

يوفر هذا الدليل الشامل كل ما تحتاجه لإعداد خط أنابيب بحث متطور وآلي باستخدام عالم الذكاء الاصطناعي من SakanaAI. إن الجمع بين النماذج اللغوية المحلية وإدارة الطوابير الذكية وتخصيص الموارد التكيفي ينشئ نظاماً قوياً قادراً على إجراء البحوث على مدار الساعة.

### الفوائد الرئيسية المحققة

1. **تشغيل البحث على مدار 24/7**: اكتشاف علمي مستمر دون تدخل بشري
2. **فعالية من حيث التكلفة**: الاستدلال المحلي للنماذج اللغوية يلغي تكاليف API للبحث واسع النطاق
3. **الذكاء التكيفي**: النظام يتكيف تلقائياً مع ظروف الأداء
4. **المراقبة الشاملة**: رؤية في الوقت الفعلي لتقدم البحث وصحة النظام
5. **الهندسة القابلة للتطوير**: قابلة للتوسع بسهولة لاستيعاب مجالات البحث الجديدة

مستقبل البحث العلمي الآلي هنا، ومع هذا الإعداد، أنت في المقدمة من هذه الثورة التكنولوجية. ابدأ ماراثون البحث اليوم ودع الذكاء الاصطناعي يدفع حدود المعرفة البشرية بينما أنت نائم! 🧑‍🔬🚀


