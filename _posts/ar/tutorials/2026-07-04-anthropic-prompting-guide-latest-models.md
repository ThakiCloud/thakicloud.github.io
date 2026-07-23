---
title: "قراءة دليل الموجّهات من Anthropic: استراتيجية خاصة بكل نموذج لـ Fable 5 وSonnet 5 وOpus 4.8"
excerpt: "نستعرض دليل Anthropic الرسمي لأفضل ممارسات الموجّهات للنماذج الأحدث. فروق النماذج، والتقنيات الأساسية (الوضوح، الأمثلة، XML، سلسلة التفكير، الأدوار، التسلسل، التفكير الممتد)، والترحيل. ونربطه بكيفية تصليب ThakiCloud للموجّهات كعقود داخل مِهاز مهارات Paxis."
tags:
  - prompt-engineering
  - claude
  - developer-experience
  - agent-native
  - paxis
date: 2026-07-04
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/anthropic-prompting-guide-latest-models/"
categories:
  - tutorials
---

![صورة تجريدية لتعليمات مبنيّة تتراكم وتتجمّع في مخرَج واحد مرتّب]({{ '/assets/images/anthropic-prompting-guide-latest-models-hero.webp' | relative_url }})
*تصوير لكيفية تجمّع التعليمات الواضحة والبنية في مخرَج يمكن التنبّؤ به.*

## نظرة عامة

كتابة الموجّهات جيداً لا تزال ثمانية أعشار حسن استخدام النموذج. مع ازدياد قوة النماذج تتبع التعليمات المرنة إلى حدّ ما، لكن انتزاع شكل وجودة مستقرّين لا يزال يحتاج إلى عقد واضح.

تحتفظ Anthropic بمستند رسمي لأفضل ممارسات الموجّهات لنماذجها الأحدث. يغطّي هذا الدليل النماذج الحالية بما فيها Claude Fable 5 وClaude Sonnet 5 وClaude Opus 4.8، ويفصل أين يتصرّف كل نموذج بشكل مختلف، وأي التقنيات تنطبق عموماً على كل النماذج، وما ينبغي إصلاحه عند الانتقال من جيل أسبق. في هذه المقالة نعرض بنيته وتقنياته الأساسية، ونربطه بكيفية تعامل ThakiCloud مع الموجّهات كعقود لا كارتجال داخل منصة الوكلاء Paxis.

## ما هذا الدليل

مستند الموجّهات من Anthropic منظّم في ثلاثة أجزاء كبيرة.

الأول إرشاد خاص بالنماذج. يشير إلى أين يستجيب Fable 5 وSonnet 5 وOpus 4.8 بشكل مختلف، لتعرف أن الموجّه نفسه قد يحتاج إلى تعديل بحسب النموذج. الثاني تقنيات تنطبق عموماً على كل النماذج الحالية. يغطّي مدى واسعاً من المبادئ العامة إلى تنسيق المخرجات واستخدام الأدوات والتفكير وتصميم الأنظمة الوكيلة. الثالث اعتبارات الترحيل، يرشد إلى كيفية مراجعة الموجّهات المنقولة من جيل أسبق.

مرسومة كصورة، تبدو هذه البنية الثلاثية هكذا.

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
<div class="d3-arch" data-arch-root id="omptingguidelatestmodels-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 708, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 444, "w": 128, "h": 46, "title": "دليل الموجّهات"}, {"id": "B", "x": 230, "y": 856, "w": 156, "h": 46, "title": "إرشاد خاص بالنماذج"}, {"id": "C", "x": 248, "y": 444, "w": 121, "h": 46, "title": "تقنيات مشتركة"}, {"id": "D", "x": 248, "y": 24, "w": 120, "h": 46, "title": "الترحيل"}, {"id": "B1", "x": 464, "y": 848, "w": 212, "h": 62, "title": ["فروق سلوك Fable 5 Sonnet 5", "Opus 4.8"]}, {"id": "C1", "x": 510, "y": 747, "w": 121, "h": 46, "title": "تعليمات واضحة"}, {"id": "C2", "x": 510, "y": 646, "w": 120, "h": 46, "title": "أمثلة متعددة"}, {"id": "C3", "x": 496, "y": 545, "w": 149, "h": 46, "title": "سلسلة التفكير CoT"}, {"id": "C4", "x": 499, "y": 444, "w": 142, "h": 46, "title": "البنية بوسوم XML"}, {"id": "C5", "x": 503, "y": 343, "w": 135, "h": 46, "title": "موجّهات الأدوار"}, {"id": "C6", "x": 503, "y": 242, "w": 135, "h": 46, "title": "تسلسل الموجّهات"}, {"id": "C7", "x": 478, "y": 125, "w": 184, "h": 62, "title": ["التفكير الممتد استخدام", "الأدوات"]}, {"id": "D1", "x": 464, "y": 24, "w": 212, "h": 46, "title": "ترحيل موجّهات الجيل الأسبق"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[94, 490], [191, 879], [191, 879], [230, 879]]}, {"src": "A", "dst": "C", "kind": "data", "line": [152, 467, 248, 467]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[94, 444], [191, 47], [191, 47], [248, 47]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [386, 879, 464, 879]}, {"src": "C", "dst": "C1", "kind": "data", "curve": [[317, 490], [425, 770], [425, 770], [510, 770]]}, {"src": "C", "dst": "C2", "kind": "data", "curve": [[321, 490], [425, 669], [425, 669], [510, 669]]}, {"src": "C", "dst": "C3", "kind": "data", "curve": [[335, 490], [425, 568], [425, 568], [496, 568]]}, {"src": "C", "dst": "C4", "kind": "data", "line": [369, 467, 499, 467]}, {"src": "C", "dst": "C5", "kind": "data", "curve": [[335, 444], [425, 366], [425, 366], [503, 366]]}, {"src": "C", "dst": "C6", "kind": "data", "curve": [[321, 444], [425, 265], [425, 265], [503, 265]]}, {"src": "C", "dst": "C7", "kind": "data", "curve": [[317, 444], [425, 156], [425, 156], [478, 156]]}, {"src": "D", "dst": "D1", "kind": "data", "line": [368, 47, 464, 47]}]});
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
      const container = document.getElementById('omptingguidelatestmodels-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'omptingguidelatestmodels-1';
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

بمعزل عن المستند، تنشر Anthropic أيضاً دليلاً تفاعلياً لهندسة الموجّهات في تسعة فصول، لتتعلّم بتشغيل الأمثلة والتمارين مباشرة.

## التقنيات الأساسية

التقنيات التي يشدّد عليها الدليل ليست حيلاً برّاقة بل أساسيات مكرّرة. مرتّبة بحسب الأثر العملي:

التعليمات الواضحة أولاً. اكتب تحديداً ماذا تفعل، وبأي شكل تنتجه، وما تتّخذه معياراً للتقييم. بدلاً من طلب غامض مثل "ساعدني"، حدّد نتيجة واحدة لكل فعل. تحديد شكل المخرَج وحده يرفع الجودة أكثر من غيره.

الأمثلة المتعددة ثانياً. أظهر النبرة والصيغة اللتين تريدهما في مثالين أو ثلاثة فيتّبع النموذج ذلك الإيقاع. حين يكون شكل المخرَج معقّداً بخاصة، فإن إرفاق مثال واحد أدقّ بكثير من وصفه بالكلمات.

سلسلة التفكير ثالثاً. طلب استدلال خطوة بخطوة قبل الجواب يرفع الدقة في الاستدلال المعقّد. غير أن التفكير يكلّف رموزاً، فاستخدمه فقط للعمل الذي يحتاج فعلاً إلى استدلال.

البنية بوسوم XML رابعاً. فصل التعليمات والسياق والأمثلة وبيانات الإدخال بوسوم يمنع النموذج من الخلط بين دور كل جزء. الأثر كبير بخاصة عند التعامل مع سياق طويل.

موجّهات الأدوار خامساً. إعطاء النموذج منظوراً محدّداً أو دور خبير ينتج مفردات وحكماً يلائمان ذلك السياق. وهو مفيد للمراجعة والتدقيق وتحليل مجال محدّد.

تسلسل الموجّهات سادساً. تقسيم طلب كبير واحد إلى عدة مراحل وتمرير مخرَج كل مرحلة إلى التالية يثبّت جودة كل مرحلة أكثر من مطالبة كل شيء دفعة واحدة.

أخيراً هناك التفكير الممتد واستخدام الأدوات وتصميم الأنظمة الوكيلة. التفكير الممتد ميزة تخصّص ميزانية للاستدلال الداخلي، ويغطّي استخدام الأدوات وتصميم الوكلاء الحلقة التي يستدعي فيها النموذج أدوات خارجية ويأخذ النتيجة ليقرّر الفعل التالي. هذه المنطقة التي كبر وزنها في الدليل الأحدث.

## دلالات لمنتجات ThakiCloud

هذا الدليل عملي لنا لأن منصة الوكلاء Paxis من ThakiCloud تتعامل مع الموجّهات بهذه الطريقة بالضبط. Paxis مستوى تحكّم Agent-Native Cloud يعمل فوق ai-platform، ويدير المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. وضمنها، الموجّه ليس شيئاً مرتجلاً يُؤلَّف من جديد كل مرة بل عقد مُحزَّم في مهارة وخاضع للتحكّم في الإصدارات.

تقنية الدليل الأولى، التعليمات الواضحة، تتداخل مباشرة مع مبدأ تصميم مِهاز مهارات Paxis. تتراكم القدرات لا في مِهاز رفيع بل في مهارات سميكة، وتحدّد كل مهارة صراحةً الإدخال والمعالجة والمخرَج وحتى التعافي من الفشل. إذا جعلت الشيفرة تملك شكل المخرَج ومعايير تقييمه، ركّز النموذج على توليد المحتوى فقط ولم يتذبذب التنسيق.

البنية بـ XML وتسلسل الموجّهات يلامسان تنسيق DAG متعدد الوكلاء. تختار Paxis من أكثر من 960 مهارة بواسطة BM25 وتشغّلها في صناديق رمل معزولة، والتسلسل الذي يقسّم مهمة كبيرة إلى مراحل ويمرّر مخرَج كل مرحلة إلى الأمام هو القواعد الأساسية لهذا التنسيق. جعل كل مرحلة مهارة مستقلة يتيح إعادة تشغيل المرحلة الفاشلة فقط، ما يرفع دقة التعافي.

موجّهات الأدوار واستخدام الأدوات يتّحدان مع بوّابات السياسة وسجلات التدقيق. الحلقة التي يستدعي فيها وكيل فرعي أُعطي دوراً محدّداً أدوات ويأخذ النتائج ليقرّر الفعل التالي تصبح مستقلّة بأمان فقط حين يمرّ كل فعل عبر بوّابات سياسة وسجلات تدقيق. ما يسمّيه الدليل تصميم الأنظمة الوكيلة يُترجَم لنا إلى مشكلة التنفيذ المستقلّ القابل للتدقيق.

باختصار، مبادئ الموجّهات الجيدة ومبادئ تصميم منصة وكلاء متينة تشير إلى المكان نفسه جوهرياً. قلّل درجات الحرية واملأ هيكلاً مُتحقَّقاً منه بالمحتوى لترفع متوسط الجودة. يمارس هذا الدليل ذلك المبدأ على مستوى الموجّه، وتمارسه Paxis على مستوى المنصة.

## القيود والاعتراضات

لهذا الدليل تحفّظات أيضاً. أولاً، الإرشاد الخاص بالنماذج يشيخ مع الوقت. حين يُطلَق نموذج أو يُحدَّث، قد يستجيب موجّه نجح بالأمس بشكل مختلف اليوم، فاقرأ الدليل كلقطة للحظة الحالية لا كعقيدة.

ثانياً، معرفة تقنيات كثيرة لا تصنع موجّهاً جيداً. تكديس وسوم XML وسلسلة التفكير وموجّهات الأدوار دفعة واحدة قد يجعل التعليمات ثقيلة ويزيد الرموز فقط. لكل تقنية، معرفة متى لا تستخدمها مهمّة بقدر معرفة متى تستخدمها.

ثالثاً، التفكير الممتد ليس مجانياً. رموز التفكير كلفة، وتشغيل أقصى تفكير لكل مهمة إهدار. كما في منظور توجيه النماذج المتناول سابقاً، يجب أيضاً تخصيص ميزانية التفكير بحسب صعوبة المهمة.

في الختام، قيمة هذا الدليل ليست في تعليم سحر جديد. إنها في شحذ الحكم على متى وكيف تجمع الأساسيات. وتصليب ذلك الحكم في مهارات وسياسة كي لا تعيده كل مرة هو مهمّة المنصة.

## المصادر

- "Prompting best practices"، Claude Platform Docs: [platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/claude-prompting-best-practices)
- "Prompt engineering overview"، Anthropic Docs: [docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview](https://docs.anthropic.com/en/docs/build-with-claude/prompt-engineering/overview)
- "Anthropic's Interactive Prompt Engineering Tutorial"، GitHub: [github.com/anthropics/prompt-eng-interactive-tutorial](https://github.com/anthropics/prompt-eng-interactive-tutorial)
