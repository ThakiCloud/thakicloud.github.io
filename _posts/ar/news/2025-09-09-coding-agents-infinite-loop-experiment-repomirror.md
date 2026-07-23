---
title: "تجربة ثورية: وكيل الترميز في حلقة لانهائية ينشئ 6 مستودعات خلال ليلة واحدة"
excerpt: "اكتشف كيف نجح وكيل ترميز Claude في حلقة while لانهائية في إنتاج أكثر من 1000 التزام تلقائياً ونقل مشاريع لغات البرمجة المتعددة بنجاح في هذه التجربة الرائدة في الأتمتة."
seo_title: "تجربة وكيل الترميز في حلقة لانهائية: كيف بنى الذكي الاصطناعي 6 مستودعات في ليلة واحدة - Thaki Cloud"
seo_description: "تعرف على التجربة الثورية حيث نجح وكيل ترميز Claude في حلقة لانهائية في أتمتة نقل React→Vue و Python→TypeScript وتطوير أداة RepoMirror."
date: 2025-09-09
lang: ar
tags:
  - وكيل_الترميز
  - أتمتة_الذكي_الاصطناعي
  - نقل_الكود
  - RepoMirror
  - Claude
  - أتمتة_البرمجة
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.com/tech-blog/ar/news/coding-agents-infinite-loop-experiment-repomirror/"
permalink: /ar/news/coding-agents-infinite-loop-experiment-repomirror/
categories:
  - news
published: false
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

![رسم تجريدي لمستودعين يعكس كل منهما الآخر أثناء النقل داخل حلقة لانهائية]({{ '/assets/images/coding-agents-infinite-loop-experiment-repomirror-hero.webp' | relative_url }})
*تجسيد تجريدي لبنية المرآة في RepoMirror، التي تحوّل المستودع المصدر إلى صيغته الهدف بشكل متكرر داخل حلقة لانهائية.*

## مقدمة: نموذج جديد في أتمتة التطوير المدفوعة بالذكاء الاصطناعي

استحوذت تجربة ثورية مؤخراً على اهتمام مجتمع المطورين، حيث عرضت مستوى غير مسبوق من الأتمتة في تطوير البرمجيات. وضع أحد المطورين وكيل ترميز Claude في حلقة while لانهائية بدون رأس، وخلال ليلة واحدة، أكمل الوكيل تلقائياً أكثر من 1000 التزام مع مشاريع نقل قواعد أكواد متعددة ومكتملة. تتجاوز هذه التجربة مجرد إظهار قدرات الترميز للذكاء الاصطناعي، وتقدم إمكانيات جديدة لأتمتة تطوير البرمجيات يمكن أن تغير بشكل جذري كيفية تعاملنا مع مهام البرمجة.

## آليات وكلاء الترميز في الحلقة اللانهائية

### المفهوم الأساسي وطريقة التنفيذ

كانت جوهر هذه التجربة في توفير بيئة عمل مستمرة ومتكررة لوكلاء الترميز. نفذ المطور نص shell بسيط باستخدام أوامر مثل `while :; do cat prompt.md | claude -p --dangerously-skip-permissions; done` لتمكين وكيل ترميز Claude من العمل إلى ما لا نهاية. هذا النهج، المبني على منهجيات اقترحها Geoff Huntley، يؤتمت العملية الكاملة حيث يقوم الوكيل بتعديل الملفات، والالتزام بالتغييرات، ودفع التحديثات في كل دورة عمل، مما يخلق خط أنابيب تطوير سلس بدون تدخل بشري.

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
<div class="d3-arch" data-arch-root id="loopexperimentrepomirror-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 356, "height": 758, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "P", "x": 73, "y": 24, "w": 135, "h": 46, "title": "قراءة prompt.md"}, {"id": "C", "x": 157, "y": 148, "w": 135, "h": 46, "title": "تشغيل claude -p"}, {"id": "E", "x": 126, "y": 272, "w": 198, "h": 62, "title": ["تعديل الملفات · التزام ·", "دفع"]}, {"id": "T", "x": 133, "y": 412, "w": 184, "h": 46, "title": "تحديث .agent · TODO.md"}, {"id": "Q", "x": 64, "y": 536, "w": 153, "h": 52, "title": "هل اكتمل العمل؟"}, {"id": "Z", "x": 80, "y": 680, "w": 121, "h": 46, "title": "انتهاء الحلقة"}], "edges": [{"src": "P", "dst": "C", "kind": "data", "curve": [[172, 70], [225, 109], [225, 109], [225, 148]]}, {"src": "C", "dst": "E", "kind": "data", "line": [225, 194, 225, 272]}, {"src": "E", "dst": "T", "kind": "data", "line": [225, 334, 225, 412]}, {"src": "T", "dst": "Q", "kind": "data", "curve": [[225, 458], [225, 497], [225, 497], [174, 536]]}, {"src": "Q", "dst": "P", "kind": "data", "label": "\"لم يكتمل\"", "curve": [[107, 536], [56, 373], [56, 171], [109, 70]], "off": "50%"}, {"src": "Q", "dst": "Z", "kind": "data", "label": "\"اكتمل، إنهاء ذاتي عبر pkill\"", "line": [140, 588, 140, 680], "lx": 140, "ly": 630}]});
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
      const container = document.getElementById('loopexperimentrepomirror-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'loopexperimentrepomirror-1';
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

### أنظمة تتبع العمل والإدارة

طوال العملية، وثق الوكيل تقدمه وتخطيطه بشكل منهجي. حافظ على سجلات مفصلة لتاريخ العمل والخطط المستقبلية في دليل `.agent/`، ويحدث باستمرار حالة الإنجاز والمهام المتبقية من خلال ملف `TODO.md`. تُظهر قدرة التوثيق الذاتي هذه أن الوكيل يمتلك مهارات إدارة المشاريع تتجاوز مجرد إنتاج الكود، مما يُظهر فهماً لسير عمل التطوير وتتبع التقدم ينافس المطورين البشر.

## إنجازات رائعة في النقل عبر اللغات

### تحويل React إلى Vue

كان أحد أبرز الإنجازات هو النقل الكامل لمشروع assistant-ui React إلى Vue. حول الوكيل تلقائياً هيكل مكونات React ومنطق إدارة الحالة ليتماشى مع Composition API لـ Vue ونظام التفاعل. خلال هذه العملية، تم إعادة كتابة كل جانب بما في ذلك طرق دورة حياة المكونات، ومعالجة الأحداث، والتصميم ليتوافق مع اتفاقيات Vue، مع الحفاظ على وظائف المشروع الأصلي والالتزام بأفضل ممارسات نظام Vue البيئي.

### تحويل Python إلى TypeScript المبتكر

أسفر نقل مشروع Browser Use Python إلى TypeScript عن نتائج أكثر إثارة للإعجاب. عمل الوكيل باستمرار في GCP VM من خلال جلسة tmux، وعندما فحص المطور في الصباح، كان منفذ TypeScript يعمل بشكل مثالي تقريباً مكتملاً. تم التعامل تلقائياً مع المهمة المعقدة لتحويل نظام الكتابة الديناميكي لـ Python إلى نظام الكتابة الثابت لـ TypeScript، مع إعادة هيكلة أنماط استخدام مكتبات Python المحددة لتناسب نظام TypeScript البيئي بشكل مناسب.

### النقل ثنائي الاتجاه وتكيف النظام البيئي

من المثير للاهتمام أن الوكيل قام أيضاً بالنقل العكسي لـ Vercel AI SDK من TypeScript إلى Python. خلال هذه العملية، أنتج محولات تلقائية لـ FastAPI و Flask، مما يضمن التوافق مع أدوات التحقق من مخطط Python المختلفة. هذا يُظهر مستوى عالي من الذكاء يتجاوز مجرد تحويل بناء الجملة، مُظهراً فهماً وتطبيقاً لخصائص واتفاقيات كل نظام بيئي للغة.

## السلوكيات الناشئة غير المتوقعة للوكيل

### إنشاء كود اختبار مستقل

كان أحد أكثر الاكتشافات مفاجأة خلال التجربة هو إنشاء الوكيل التلقائي لكود الاختبار بدون تعليمات صريحة. أنتج الوكيل تلقائياً اختبارات الوحدة واختبارات التكامل للتحقق من دقة الكود المنقول، حتى أنه بنى مجموعات اختبار شاملة أخذت في الاعتبار الحالات الحدية. يشير هذا السلوك إلى أن الذكاء الاصطناعي يدرك ويمارس أهمية التطوير المدفوع بالاختبار (TDD) في تطوير البرمجيات الحديثة بشكل مستقل.

### آلية الإنهاء الذاتي الذكية

كانت ظاهرة أكثر إثارة للاهتمام هي قدرة الوكيل على تحديد إنجاز المهمة بشكل مستقل وإنهاء عمليته الخاصة باستخدام أمر `pkill`. يبدو أن هذا يقدم حلاً عملياً لمشكلة التوقف (Halting Problem)، مُظهراً أن الذكاء الاصطناعي يمكنه تقييم إنجاز العمل بشكل مستقل وإنهاء المهام بشكل مناسب في الوقت المناسب. مثل هذه الاستقلالية تُعتبر عنصراً أساسياً في أنظمة الأتمتة غير المأهولة وتمثل خطوة مهمة نحو وكلاء تطوير مستقلين حقاً.

### تحسين الميزات والتحسينات المبتكرة

بعد إكمال مهام النقل، بدأ الوكيل في تنفيذ ميزات إضافية لم تكن موجودة في النسخة الأصلية بشكل تلقائي. قدم دعم تكامل كامل لـ FastAPI و Flask، وضمن التوافق مع أدوات التحقق من مخطط مختلفة، وحتى نفذ تحسينات الأداء. هذا يُظهر قدرات إبداعية تتجاوز مجرد نسخ الكود، مُظهراً قدرات تحسين وتطور البرمجيات الفعلية التي يمكن أن تُحدث ثورة في كيفية تفكيرنا في تحسين الكود.

## دروس حاسمة في تحسين التوجيهات

### قوة البساطة

كانت إحدى أهم الرؤى المكتسبة من التجربة أن بساطة التوجيه ترتبط مباشرة بتحسن الأداء. حقق توجيه بسيط من 103 حرفاً نتائج فائقة مقارنة بتوجيه معقد من 1500 حرف. التعليمات المعقدة والمفصلة شوشت فعلياً على حكم الوكيل وقللت من سرعة التنفيذ. هذا يُظهر مدى أهمية الوضوح والإيجاز في التواصل الفعال مع الذكاء الاصطناعي، متحدياً الافتراض أن التعليمات الأكثر تفصيلاً تؤدي دائماً إلى نتائج أفضل.

### توازن فهم السياق والاستقلالية

ركزت التوجيهات الفعالة على تقديم واضح للأهداف والسياق بدلاً من طرق التنفيذ المحددة. كان بإمكان الوكيل تحديد وتنفيذ جميع التفاصيل الضرورية بشكل مستقل من تعليمة بسيطة مثل "انقل React إلى Vue"، بينما التعليمات المفصلة خطوة بخطوة ميلت إلى تحديد قدرات حل المشاكل الإبداعية. هذا يشير إلى أن وكلاء الذكاء الاصطناعي يؤدون أفضل عندما يُعطون أهدافاً واضحة ويُوثق بهم لتحديد تفاصيل التنفيذ بأنفسهم.

## RepoMirror: أداة مبتكرة للأتمتة

### خلفية تطوير الأداة

مع ظهور تعقيد إدارة مهام النقل بين مستودعات مصدر وهدف متعددة خلال التجربة، برزت الحاجة لأداة مخصصة. أدى هذا إلى تطوير RepoMirror، أداة مفتوحة المصدر مصممة بمبادئ الصندوق المفتوح بأسلوب shadcn، مما يسمح للمستخدمين بتخصيص النصوص والتوجيهات بحرية بعد الإعداد الأولي. تمثل الأداة حلاً عملياً للتحديات التي واجهتها تجربة الحلقة اللانهائية.

### الوظائف الأساسية والتشغيل

يسمح RepoMirror للمستخدمين بتحديد أدلة المصدر والهدف وتعريف مهام التحويل من خلال أمر `npx repomirror init`. تنشئ الأداة تلقائياً مجلد `.repomirror/` يحتوي على ملفات أساسية مثل `prompt.md` و `sync.sh` و `ralph.sh`. يمكن للمستخدمين تنفيذ مهام مزامنة لمرة واحدة أو مستمرة باستخدام أوامر `sync` أو `sync-forever`، مع أتمتة العملية الكاملة لتحليل الذكاء الاصطناعي للكود المصدر وتحويله إلى تنسيق الهدف في كل دورة تكرار.

### حالات الاستخدام العملية

يمكن استخدام RepoMirror لمجموعة واسعة من الأغراض تتجاوز انتقالات إطار العمل من React إلى Vue، بما في ذلك تغييرات معمارية من gRPC إلى REST API ونقل المكتبات بين لغات برمجة مختلفة. يثبت قوة خاصة في تحديث الأنظمة القديمة، وتوسيع قاعدة الكود لدعم منصات متعددة، والهجرة إلى مكدسات تقنية جديدة، مقدماً للمطورين أداة متعددة الاستخدامات لإدارة مشاريع التحويل المعقدة.

## القيود والتحديات

### مسائل الاكتمال

بينما كانت نتائج التجربة مثيرة للإعجاب، لم يعمل الكود المُنتج دائماً بشكل مثالي. لم تُنفذ بعض عروض المتصفح بالكامل، وأظهرت حالات حدية معينة سلوكاً غير متوقع. هذا يكشف القيود الأساسية لإنتاج الكود التلقائي ويشير إلى أن مراجعة وتعديل المطور البشري تبقى ضرورية لتطوير البرمجيات الجاهزة للإنتاج.

### مخاوف الأمان والسلامة

تقدم وكلاء الذكاء الاصطناعي التي تعمل في حلقات لانهائية مخاطر محتملة إلى جانب قدراتها القوية في الأتمتة. هناك إمكانية أن الوكلاء ذوي الصلاحيات المميزة قد يؤدون مهاماً في اتجاهات غير متوقعة أو يستهلكون موارد النظام بشكل مفرط. بالإضافة إلى ذلك، قد يحتوي الكود المُنتج تلقائياً على ثغرات أمنية، مما يؤكد أهمية آليات اكتشاف وتصحيح مثل هذه المسائل في سير عمل التطوير التلقائي.

### اعتبارات التكلفة والكفاءة

كلفت التجربة حوالي 800 دولار، منتجة 1100 التزام بمعدل 10.50 دولار في الساعة لكل وكيل. يمكن أن يمثل هذا عبء تكلفة كبير للمشاريع واسعة النطاق أو العمليات المستمرة. لذلك، إيجاد التوازن بين فوائد الأتمتة والكفاءة في التكلفة سيكون تحدياً رئيسياً للاعتماد العملي لمثل هذه الأنظمة في بيئات التطوير الحقيقية.

## تحولات النموذج والآفاق المستقبلية في التطوير

### التغييرات الفلسفية في إدارة التبعيات

تقدم هذه التجربة نهجاً جديداً يحل محل تتبع التبعيات المعقد وإدارة المكتبات بالنقل الانتقائي للوظائف الأساسية الضرورية فقط. سيطرح المطورون بشكل متزايد أسئلة مثل "هل هذه التبعية ضرورية حقاً؟" و "ألن يكون أكثر كفاءة تنفيذ القيمة الأساسية فقط مباشرة من خلال الاستخراج؟" هذا التغيير يمكن أن يقدم حلاً جذرياً لمشكلة جحيم التبعية في تطوير البرمجيات.

### "Vibe Coding" وفرص السوق الجديدة

مفهوم "vibe coding" المذكور في التجربة، رغم كونه مصطلحاً حديثاً ظهر منذ خمسة أشهر فقط، خلق بالفعل سوق خدمات مهنية لحل المشاكل التي يسببها. الزيادة السريعة في الطلب على أشكال جديدة من الدعم التقني وخدمات الاسترداد بسبب مشاكل الجودة والأخطاء غير المتوقعة في الكود المُنتج بالذكاء الاصطناعي تُظهر الأهمية المتنامية لضمان الجودة والدعم المتابع في تطوير البرمجيات في عصر الذكاء الاصطناعي.

### الأهمية الجديدة للتطوير المدفوع بالاختبار

في بيئات التطوير المؤتمتة بالكامل، تصبح مجموعات الاختبار الشاملة والموثوقة جوهر ضمان الجودة، محلة محل مراجعات الكود التقليدية أو البرمجة الزوجية. اكتشف المجربون أن تعريفات المتطلبات القائمة على جدول الأمثلة بأسلوب Cucumber ومنهجيات الإثبات الرسمي مثل TLA+ فعالة بشكل خاص في التعاون مع وكلاء الذكاء الاصطناعي. هذا يشير إلى أن التطوير القائم على المواصفات والتحقق الرسمي سيصبح أكثر أهمية بشكل كبير في تطوير البرمجيات المستقبلي.

## خاتمة: إمكانيات جديدة في عصر أتمتة الذكاء الاصطناعي

أظهرت هذه التجربة المبتكرة أن وكلاء ترميز الذكاء الاصطناعي يمكن أن يتطوروا تجاوز الأدوات المساعدة البسيطة ليصبحوا شركاء تطوير مستقلين وإبداعيين. مستوى الأتمتة المحقق من خلال مفهوم الحلقات اللانهائية البسيط يوفر خيالاً جديداً لمستقبل تطوير البرمجيات. ومع ذلك، كشف أيضاً بوضوح التحديات العملية بما في ذلك الاكتمال والأمان وكفاءة التكلفة التي يجب معالجتها للاعتماد الواسع النطاق.

ظهور أدوات مثل RepoMirror يُظهر أن تقنيات الأتمتة هذه تتطور تدريجياً إلى أشكال عملية ومتاحة. سيحتاج المطورون إلى تعلم طرق تعاون فعالة مع الذكاء الاصطناعي، وتطوير مجموعات مهارات جديدة تزيد من فوائد الأتمتة بينما تفهم وتعوض قيودها. هذا يمثل تحولاً جذرياً في كيفية وجوب تفكير المطورين في دورهم في منظر تطوير معزز بالذكاء الاصطناعي.

أهم رؤية تقدمها هذه التجربة هي أن الإبداع البشري والحكمة في استخدام الذكاء الاصطناعي، وليس قدرات الذكاء الاصطناعي وحدها، تبقى في جوهر الابتكار. النتائج الرائعة التي أنتجها وضع الذكاء الاصطناعي في حلقة لانهائية كانت بسبب البصيرة البشرية في تصميمه واستخدامه بشكل مناسب، وليس بسبب قدرات الذكاء الاصطناعي الكامنة. لذلك، للمطورين في عصر الذكاء الاصطناعي، ستصبح مهارات التواصل والتعاون الفعال مع الذكاء الاصطناعي قدرات أكثر أهمية إلى جانب الكفاءة التقنية، مما يحدد الجيل القادم من التميز في هندسة البرمجيات.

## المصادر

- مستودع RepoMirror مفتوح المصدر: <https://github.com/repomirrorhq/repomirror>
- Geoff Huntley, "ralph wiggum as a software engineer" (أصل تقنية حلقة ralph اللانهائية): <https://ghuntley.com/ralph>
