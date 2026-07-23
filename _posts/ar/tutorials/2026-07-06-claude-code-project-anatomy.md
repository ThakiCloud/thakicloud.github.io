---
title: "إعداد مشروع Claude Code كما يجب: تشريح مجلد .claude/"
excerpt: "معظم المطورين يتخطون الإعداد وينتقلون مباشرة إلى كتابة الأوامر النصية (prompts). هذا خطأ. نشرّح هنا بنية مجلد .claude/ الممتدة من CLAUDE.md إلى rules وcommands وskills وagents وhooks، عبر قياس فعلي لمشروع إنتاجي حقيقي يعمل فيه 1,671 مهارة (skill). ونربط ذلك بالطريقة التي حوّلت بها ThakiCloud هذا النمط إلى منتج باسم Agent-Native Cloud بعنوان 'Paxis'."
tags:
  - claude-code
  - developer-experience
  - agent-native
  - paxis
  - agentops
date: 2026-07-06
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/claude-code-project-anatomy/"
categories:
  - tutorials
---

![صورة تجريدية لطبقات إعداد متراكمة تتقارب في تنفيذ واحد منظم لعميل ذكي]({{ '/assets/images/claude-code-project-anatomy-hero.webp' | relative_url }})
*عندما تُنظَّم التعليمات والقواعد والأدوات المتناثرة ضمن بنية مجلدات واضحة، يصبح سلوك العميل الذكي قابلًا للتنبؤ.*

## نظرة عامة

أكثر خطأ شائع عند بدء العمل مع Claude Code هو تخطي مرحلة الإعداد والانتقال مباشرة إلى كتابة الأوامر النصية (prompts). قد ينجح هذا لبضع مرات، لكن مع نمو المشروع تجد نفسك تكرر التعليمات ذاتها في كل مرة، بينما يبدأ النموذج كل جلسة من صفحة بيضاء تمامًا. عندها تصبح جودة النتيجة رهينة لحظّ ذلك اليوم، لا لمهارتك في كتابة الأوامر.

الحل لهذه المشكلة ليس استبدال النموذج بآخر أفضل، بل **تحويل المشروع نفسه إلى بنية تعاقدية واحدة**. في Claude Code، يعيش هذا التعاقد في مجلد `.claude/` عند جذر المشروع. سلسلة منشورات على منصة X لـ Akshay Pachaar بعنوان "تشريح مجلد .claude/" انتشرت مؤخرًا وقدّمت خلاصة جيدة لهذه البنية. في هذا المقال نتبع الهيكل نفسه، لكن مع إضافة **أرقام مقاسة فعليًا من مشروع إنتاجي حقيقي يعمل عليه Claude Code ويحتوي 1,671 مهارة (skill)**، لنرى كيف تُستخدم كل طبقة على أرض الواقع من حيث الحجم. ثم نربط ذلك بالطريقة التي حوّلت بها ThakiCloud هذا النمط إلى منتج فعلي، وهو سحابتها الموجّهة نحو العملاء الأذكياء (Agent-Native Cloud) باسم Paxis.

## ما هو مجلد .claude/

مجلد `.claude/` هو مجموعة الاتفاقيات التي تُخبر Claude Code كيف يعمل ضمن هذا المشروع تحديدًا. الفكرة الجوهرية هي أنه ليس أمرًا نصيًا ضخمًا واحدًا، بل مجموعة طبقات لكل منها دور مختلف. تختلف هذه الطبقات في توقيت تحميلها وفي كلفتها.

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
<div class="d3-arch" data-arch-root id="claudecodeprojectanatomy-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 778, "height": 703, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 325, "w": 170, "h": 46, "title": ".claude/ جذر المشروع"}, {"id": "B", "x": 304, "y": 609, "w": 120, "h": 62, "title": ["CLAUDE.md", "عقل المشروع"]}, {"id": "C", "x": 304, "y": 492, "w": 120, "h": 62, "title": ["rules/", "قواعد دائمة"]}, {"id": "D", "x": 304, "y": 375, "w": 121, "h": 62, "title": ["commands/", "سير عمل متكرر"]}, {"id": "E", "x": 272, "y": 258, "w": 184, "h": 62, "title": ["skills/", "معرفة متخصصة عند الطلب"]}, {"id": "F", "x": 279, "y": 141, "w": 170, "h": 62, "title": ["agents/", "عملاء فرعيون معزولون"]}, {"id": "G", "x": 300, "y": 24, "w": 128, "h": 62, "title": ["settings.json", "أذونات وخطافات"]}, {"id": "B1", "x": 545, "y": 617, "w": 191, "h": 46, "title": "تحميل تلقائي في كل جلسة"}, {"id": "C1", "x": 545, "y": 500, "w": 191, "h": 46, "title": "تحميل تلقائي في كل دورة"}, {"id": "E1", "x": 534, "y": 258, "w": 212, "h": 62, "title": ["يُحمّل فقط عند تفعيل الطلب", "له"]}, {"id": "F1", "x": 548, "y": 149, "w": 184, "h": 46, "title": "يُستدعى عبر أداة Agent"}, {"id": "G1", "x": 545, "y": 24, "w": 191, "h": 62, "title": ["PreToolUse وPostToolUse", "وStop وغيرها"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[119, 371], [233, 640], [233, 640], [304, 640]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[125, 371], [233, 523], [233, 523], [304, 523]]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[158, 371], [233, 406], [233, 406], [304, 406]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[158, 325], [233, 289], [233, 289], [272, 289]]}, {"src": "A", "dst": "F", "kind": "data", "curve": [[125, 325], [233, 172], [233, 172], [279, 172]]}, {"src": "A", "dst": "G", "kind": "data", "curve": [[119, 325], [233, 55], [233, 55], [300, 55]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [424, 640, 545, 640]}, {"src": "C", "dst": "C1", "kind": "data", "line": [424, 523, 545, 523]}, {"src": "E", "dst": "E1", "kind": "data", "line": [456, 289, 534, 289]}, {"src": "F", "dst": "F1", "kind": "data", "line": [449, 172, 548, 172]}, {"src": "G", "dst": "G1", "kind": "data", "line": [428, 55, 545, 55]}]});
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
      const container = document.getElementById('claudecodeprojectanatomy-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'claudecodeprojectanatomy-1';
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

إذا قسّمنا دور كل طبقة، تصبح الصورة كالتالي.

**CLAUDE.md** هو عقل المشروع. يُحمَّل تلقائيًا في كل جلسة، ويجيب فقط على أربعة أمور: لمحة عامة عن البنية المعمارية، والحزمة التقنية، والاتفاقيات المتّبعة، وقواعد سير العمل. إذا حشرت فيه معرفة "تُحتاج أحيانًا فقط"، فأنت تهدر جزءًا من سعة السياق في كل جلسة. لهذا يجب أن يبقى CLAUDE.md خفيفًا كمبدأ أساسي.

**rules/** هي القواعد الدائمة التي تُطبَّق في كل دورة (turn). هنا توضع القواعد الثابتة التي تخص جميع الأعمال، مثل أسلوب كتابة الشيفرة وسياسات الأمان وسير عمل git وبوابات الجودة. عندما يصبح CLAUDE.md مثقلًا، يُنقل جزء منه إلى هنا.

**commands/** هي سير عمل متكرر يُختزل في أوامر شرطة مائلة (slash commands). أمر واحد مثل `/review` أو `/ship` يستدعي سلسلة خطوات محددة مسبقًا.

**skills/** هي معرفة متخصصة تُحمَّل فقط عند تفعيل الطلب لها. هنا توضع خطوط أنابيب (pipelines) خاصة بمجال معيّن أو وصفات تحليل لا تُحتاج دائمًا. تبقى المهارة مجرد اسم ووصف في الفهرس حتى يصل طلب ذو صلة، عندها فقط يُحمَّل محتواها الكامل.

**agents/** هي تعريفات لخبراء مستقلين لكل منهم دوره وأدواته ونموذجه الخاص. يُستدعون عبر أداة Agent، فيُوجَّه الاستكشاف إلى نموذج رخيص، والتنفيذ إلى نموذج متوازن، والقرارات المعمارية إلى نموذج قوي.

**settings.json** يضبط الأذونات والخطافات (hooks). تسمح الخطافات بإدخال شيفرة حتمية قبل استدعاء الأداة وبعده (`PreToolUse`/`PostToolUse`) أو عند إنهاء الجلسة (`Stop`)، بحيث تصبح الشيفرة، لا النموذج، هي المسؤولة عن التنسيق والتحقق.

إضافة إلى ذلك، يوجد نسختان من مجلد `.claude/`: واحدة تُحفظ ضمن المستودع (repository) وتُشارَك مع الفريق بأكمله، وأخرى عامة (global) موجودة في `~/.claude/` تحتفظ بالتفضيلات الشخصية وبذاكرة تلقائية مشتركة بين المشاريع.

## التثبيت والإعداد

أسرع طريقة للبدء هي التهيئة (initialization) من جذر المشروع.

```bash
# من جذر المشروع
claude
# داخل الجلسة، إنشاء مسودة عقل المشروع
/init
```

يقوم `/init` بمسح المستودع وإنشاء مسودة لملف `CLAUDE.md`. بعد ذلك تُنقَّح المسودة يدويًا. يمكن أيضًا إنشاء هيكل المجلدات يدويًا كما يلي.

```bash
mkdir -p .claude/rules .claude/commands .claude/skills .claude/agents .claude/hooks
```

مثال على ربط خطاف (hook) داخل `settings.json`. هذا خطاف من نوع PostToolUse يُشغّل تنسيقًا تلقائيًا بعد التعديل.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "command": "python3 .claude/hooks/format-on-save.py",
        "description": "تنسيق تلقائي للملف الذي تم تعديله"
      }
    ]
  }
}
```

الشكل الأدنى لأي مهارة هو ترويسة (frontmatter) في ملف `SKILL.md`. بما أن حقل `description` هو ما يشغّل عملية البحث، يجب وضع كلمات مفتاحية بالإنجليزية والعربية/الكورية معًا، وتوضيح "متى لا تُستخدم هذه المهارة" حتى لا يقع الخلط مع مهارات مجاورة.

```yaml
---
name: my-pipeline
description: >-
  Does X in one sentence. Use when <english + local trigger phrases>.
  Do NOT use for <anti-pattern> (use other-skill).
---
```

القاعدة الجوهرية واحدة فقط: **القدرات تُبنى في المهارات (skills)، لا في الهيكل التنفيذي (harness)**. يُبقى CLAUDE.md وrules خفيفين، بينما تُحشى المهارات بالمعرفة الخاصة بالمجال والأحكام والقوالب وحالات الفشل السابقة. الهدف أن تعمل المهارة نفسها عبر Claude Code أو أي هيكل تنفيذي آخر دون تغيير.

## قياس فعلي: تشريح مشروع إنتاجي حقيقي لـ Claude Code

المستودع الذي كُتب فيه هذا المقال نفسه هو مشروع Claude Code مُعدّ بشكل مكثف. قسنا كل طبقة عبر عدّ الملفات فعليًا لنرى حجم استخدامها على أرض الواقع. الأرقام أدناه جميعها قيم مقاسة فعلًا.

| الطبقة | العدد الفعلي المقاس | وقت التحميل | الدور |
|---|---|---|---|
| CLAUDE.md | 94 سطرًا | كل جلسة | عقل المشروع (يُبقى خفيفًا) |
| rules/ | 49 | كل دورة | قواعد دائمة |
| commands/ | 22 | عند الاستدعاء | سير عمل متكرر |
| skills/ | 1,671 | عند التفعيل | معرفة متخصصة عند الطلب |
| agents/ | 60 | عند الاستدعاء | عملاء فرعيون معزولون |
| hooks/ | 12 | قبل/بعد استخدام الأداة | بوابات حتمية (deterministic) |

مبدأ التصميم الذي يظهر هنا واضح تمامًا. ملف CLAUDE.md خفيف جدًا بـ94 سطرًا فقط. بما أنه يُحمَّل في كل جلسة، فهو يدفع "إيجارًا" مستمرًا، ولذلك لا يُحمَّل فيه إلا الحد الأدنى الضروري. في المقابل، عدد المهارات ضخم جدًا ويبلغ 1,671. بما أن المهارات لا تُحمَّل إلا عند تفعيلها، فهذا الحجم الهائل لا يفرض أي كلفة في كل دورة.

أظهر القياس أن أحداث الخطافات المسجَّلة كانت خمسة أنواع: `PreToolUse` و`PostToolUse` و`Stop` و`SessionStart` و`UserPromptSubmit`، وأن ملف `settings.json` كان مبنيًا على ثلاثة محاور: `permissions` و`hooks` و`env`. أي أن كل ما يعمل بشكل دائم (rules وhooks) يُبقى عدده صغيرًا عمدًا، بينما كل ما يُستدعى عند الحاجة فقط (skills وagents) يُسمح له بالتوسّع بلا حدود تقريبًا.

لكن حين يصل عدد المهارات إلى 1,671، تنشأ مشكلة جديدة. لا يستطيع لا الإنسان ولا النموذج تصفّح هذه القائمة كاملة لاختيار "المهارة المناسبة الآن". وهذا بالضبط ما يقودنا إلى القسم التالي.

## دلالات التطبيق على منتجات ThakiCloud

بمجرد أن يصل عدد المهارات إلى الآلاف، لم تعد إدارة ملفات مجلد `.claude/` مسألة تنظيم شخصي، بل تتحول إلى **مشكلة توجيه (routing) في وقت التشغيل (runtime)**. حوّلت ThakiCloud هذا النمط إلى منتج فعلي تحت اسم **Paxis**، وهي سحابتها الموجّهة نحو العملاء الأذكياء (Agent-Native Cloud).

Paxis هو مستوى تحكّم للعملاء الأذكياء يعمل فوق البنية التحتية للذكاء الاصطناعي في ThakiCloud (ai-platform)، ويتعامل مع Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى (first-class resources). الجزء الذي يتقاطع مباشرة مع تشريح مجلد `.claude/` هو **Skill Harness**. كما رأينا أعلاه، مهما أنشأت مهارات كثيرة، فإن تحميلها كلها في كل دورة يُفجّر السياق. عندما يصل طلب ما، يختار Paxis من مجموعة المهارات الضخمة فقط المهارات ذات الصلة عبر بحث BM25، ويحمّلها، ثم ينفّذها ضمن بيئة معزولة (sandbox). ولهذا يظل التوجيه فعالًا حتى عندما يتجاوز عدد المهارات 1,000 كما رأينا في القياس الفعلي في هذا المقال.

إلى جانب ذلك، يرتقي Paxis بما تقوم به الخطافات (بوابات حتمية) إلى مستوى بوابات سياسات (policy gates) وسجلات تدقيق (audit logs). تمامًا كما يمنع خطاف PreToolUse في `.claude/settings.json` أمرًا خطيرًا، يمرر Paxis كل سلوك لأي عميل ذكي عبر بوابة سياسات وسجل تدقيق، مسجّلًا "من نفّذ ماذا ومتى". هذا تحويل لخطاف مشروع شخصي إلى آلية يمكن الوثوق بها حتى في بيئة متعددة المستأجرين (multi-tenant).

طبقة agents/ تمتد إلى تنسيق Paxis متعدد العملاء الأذكياء عبر رسم بياني موجّه غير دوري (DAG). النمط المحلي الذي يفصل بين عملاء فرعيين حسب الدور والنموذج يتوسّع هنا ليصبح بنية تربط عدة عملاء ضمن رسم بياني للاعتماديات، تُنفَّذ بالتوازي وتُغلَق بمرحلة تحقق (verification).

هذا له معنى أيضًا من منظور البنية التحتية (عدسة ai-platform). كل تنفيذ لهذه المهارات والعملاء يستهلك في النهاية موارد GPU وكلفة استدلال (inference). منصة ai-platform التابعة لـ ThakiCloud، القائمة على K8s وKueue للجدولة وvLLM للخدمة، تدعم هذا التنفيذ بتكلفة منخفضة، وتتيح للبيئات التي لديها متطلبات سيادة بيانات أو استضافة محلية (on-premise) تشغيل الهيكل التنفيذي نفسه ذاتيًا (self-hosting). الخدمة منخفضة الكلفة هي التي تجعل اقتصاديات العميل الذكي ممكنة، وفوقها يعمل هيكل مهارات Paxis.

## الحدود ووجهات النظر المعارضة

هذا النهج ليس دائمًا الإجابة الصحيحة. أولًا، فرض بنية `.claude/` الثقيلة على سكربت صغير أو عمل لمرة واحدة هو مبالغة. قبل إضافة قاعدة واحدة في rules، يجب أن تسأل "هل هذه حقًا مطلوبة في كل دورة؟"، وإن لم تكن كذلك، فيجب تنزيلها إلى مستوى مهارة. لا ينبغي أن يتحول الإعداد نفسه إلى الهدف.

ثانيًا، عندما يصل عدد المهارات إلى الآلاف، يصبح ضجيج البحث عنق زجاجة جديدًا. كلما زاد عدد المهارات ذات الأسماء المتشابهة، تنخفض دقة التوجيه، ويزداد خطر تحميل مهارة غير مناسبة. هذه المشكلة لا تُحل برفع درجة النموذج، بل فقط عبر العمل الدؤوب والممل لضبط محفزات (triggers) وحدود (boundaries) وصف المهارة (description).

ثالثًا، يجب ألا يحتوي مجلد `.claude/` المُحفَّظ (committed) إلا على الإعدادات المشتركة مع الفريق، بينما تُترك المسارات الشخصية والرموز (tokens) واختصارات التصحيح إلى `~/.claude/` أو `CLAUDE.local.md`. عدم الالتزام بهذا الفصل يعني تعرّض معلومات شخصية للانكشاف في المستودع.

خلاصة القول، إعداد مجلد `.claude/` ليس عملًا يهدف إلى "جعل النموذج أفضل"، بل إلى "جعل سلوك النموذج قابلًا للتنبؤ". عندما يكون المشروع صغيرًا، يكفي ملف CLAUDE.md واحد، وكلما كبر المشروع يمكن تقسيمه إلى rules وskills وagents وhooks. وعندما يصل عدد المهارات إلى مقياس الآلاف، لم تعد المسألة تنظيم مجلدات، بل تصبح مشكلة بنية توجيه (routing infrastructure) بحتة. وهذه بالضبط النقطة التي يتعامل معها Paxis كمنتج.

## المصادر

- [Akshay Pachaar, "How to setup your Claude code project?" (X)](https://x.com/akshay_pachaar/status/2035706568142893229)
- [Builder.io, "Setting Up a New Claude Code Project: The Complete Guide"](https://www.builder.io/blog/setting-up-claude-code-project)
- [Claude Code Docs: Quickstart](https://code.claude.com/docs/en/quickstart)
