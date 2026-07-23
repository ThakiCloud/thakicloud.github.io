---
title: "دليل شامل لـ LandingAI Agentic Document Extraction: معالجة PDF والصور بالذكاء الاصطناعي"
excerpt: "إتقان مكتبة LandingAI's Agentic Document Extraction لمعالجة المستندات الذكية. استخراج البيانات المنظمة من ملفات PDF والصور والمستندات المعقدة باستخدام قدرات التحليل بالذكاء الاصطناعي."
seo_title: "دروس LandingAI Agentic Document Extraction - دليل معالجة PDF بالذكاء الاصطناعي"
seo_description: "تعلم كيفية استخدام مكتبة LandingAI's Agentic Document Extraction لمعالجة المستندات بالذكاء الاصطناعي. دروس شاملة مع أمثلة الكود والمعالجة المجمعة وميزات التصور."
date: 2025-10-05
tags:
  - LandingAI
  - استخراج-المستندات
  - الذكاء-الاصطناعي
  - معالجة-PDF
  - Python
  - التعلم-الآلي
  - OCR
  - ذكاء-المستندات
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/agentic-document-extraction-complete-guide/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/agentic-document-extraction-complete-guide-ar/"
categories:
  - tutorials
---

⏱️ **وقت القراءة المقدر**: 12 دقيقة

## مقدمة

في عالم اليوم المعتمد على البيانات، يُعد استخراج المعلومات المنظمة من المستندات المعقدة مثل ملفات PDF والصور والمخططات تحدياً حاسماً للشركات والمطورين. غالباً ما تواجه حلول OCR التقليدية صعوبات في التعامل مع التخطيطات المعقدة بصرياً والجداول وأنواع المحتوى المختلط. هنا تأتي مكتبة **LandingAI's Agentic Document Extraction** للإنقاذ.

إن Agentic Document Extraction API هي مكتبة Python قوية تستفيد من الذكاء الاصطناعي المتقدم لاستخراج البيانات المنظمة من المستندات المعقدة بصرياً وتُرجع JSON هرمي مع مواقع العناصر الدقيقة. سواء كنت تتعامل مع التقارير المالية أو الأوراق البحثية أو الوثائق التقنية متعددة الصفحات، توفر هذه المكتبة قدرات معالجة المستندات على مستوى المؤسسات.

## ما هو Agentic Document Extraction؟

إن LandingAI's Agentic Document Extraction هي مكتبة معالجة المستندات المدعومة بالذكاء الاصطناعي التي تتفوق في:

- **فهم التخطيط المعقد**: التعامل مع الجداول والصور والمخططات وتخطيطات المحتوى المختلط
- **دعم المستندات الطويلة**: معالجة ملفات PDF بأكثر من 100 صفحة في استدعاء واحد
- **الإخراج المنظم**: إرجاع JSON هرمي مع مواقع العناصر الدقيقة
- **التأسيس البصري**: توفير معلومات الصندوق المحيط للمحتوى المستخرج
- **المعالجة المجمعة**: التعامل مع مستندات متعددة بشكل متزامن مع المعالجة المتوازية

**الشكل 1. خط معالجة Agentic Document Extraction.**

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
<div class="d3-arch" data-arch-root id="xtractioncompleteguidear-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 531, "height": 770, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IN", "x": 152, "y": 24, "w": 205, "h": 62, "title": ["Input: PDF / Image / URL,", "any length"]}, {"id": "SPLIT", "x": 166, "y": 164, "w": 177, "h": 46, "title": "Auto-split 100+ pages"}, {"id": "BATCH", "x": 152, "y": 288, "w": 205, "h": 46, "title": "Parallel Batch Processing"}, {"id": "PARSE", "x": 163, "y": 412, "w": 184, "h": 62, "title": ["Layout Parser: tables,", "figures, charts"]}, {"id": "JSON", "x": 173, "y": 552, "w": 163, "h": 62, "title": ["Hierarchical JSON +", "Bounding Boxes"]}, {"id": "MD", "x": 291, "y": 692, "w": 177, "h": 46, "title": "Render-ready Markdown"}, {"id": "VIS", "x": 24, "y": 692, "w": 212, "h": 46, "title": "Visual Grounding and Debug"}], "edges": [{"src": "IN", "dst": "SPLIT", "kind": "data", "line": [255, 86, 255, 164]}, {"src": "SPLIT", "dst": "BATCH", "kind": "data", "line": [255, 210, 255, 288]}, {"src": "BATCH", "dst": "PARSE", "kind": "data", "line": [255, 334, 255, 412]}, {"src": "PARSE", "dst": "JSON", "kind": "data", "line": [255, 474, 255, 552]}, {"src": "JSON", "dst": "MD", "kind": "data", "curve": [[310, 614], [380, 653], [380, 653], [380, 692]]}, {"src": "JSON", "dst": "VIS", "kind": "data", "curve": [[200, 614], [130, 653], [130, 653], [130, 692]]}, {"src": "PARSE", "dst": "PARSE", "kind": "event", "label": "retry with backoff", "curve": [[347, 425], [426, 412], [426, 474], [347, 461]], "off": "50%"}]});
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
      const container = document.getElementById('xtractioncompleteguidear-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'xtractioncompleteguidear-1';
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

### الميزات الرئيسية

- 📦 **تثبيت بسيط**: تثبيت بسطر واحد من pip بدون تبعيات إضافية
- 🗂️ **دعم الملفات الشامل**: ملفات PDF بأي طول، صور، وروابط URL
- 📚 **نطاق المؤسسة**: تقسيم تلقائي ومعالجة متوازية للمستندات بأكثر من 1000 صفحة
- 🧩 **إخراج منظم**: JSON هرمي بالإضافة إلى Markdown جاهز للعرض
- 👁️ **تصحيح بصري**: مقاطع الصندوق المحيط وتصورات الصفحة الكاملة
- 🏃 **معالجة متوازية**: معالجة مجمعة قابلة للتكوين مع إدارة الخيوط
- 🔄 **مرونة**: إعادة محاولة تلقائية مع تراجع أسي لأخطاء API
- ⚙️ **تكوين مرن**: إعدادات قائمة على البيئة للنشر الإنتاجي

## المتطلبات الأساسية والإعداد

### متطلبات النظام

- Python 3.9, 3.10, 3.11, أو 3.12
- مفتاح LandingAI API (احصل عليه من [LandingAI](https://landing.ai/))
- اتصال بالإنترنت لاستدعاءات API

### التثبيت

عملية التثبيت مباشرة باستخدام pip:

```bash
# تثبيت مكتبة agentic-doc
pip install agentic-doc

# التحقق من التثبيت
python -c "import agentic_doc; print('تم التثبيت بنجاح!')"
```

### تكوين مفتاح API

بعد الحصول على مفتاح LandingAI API، قم بتكوينه كمتغير بيئة:

```bash
# تعيين مفتاح API كمتغير بيئة
export VISION_AGENT_API_KEY=your-api-key-here

# أو إنشاء ملف .env في دليل مشروعك
echo "VISION_AGENT_API_KEY=your-api-key-here" > .env
```

للبيئات الإنتاجية، فكر في استخدام أنظمة إدارة الأسرار الآمنة بدلاً من متغيرات البيئة النصية العادية.

## أمثلة الاستخدام الأساسي

### تحليل المستندات البسيط

لنبدأ بالاستخدام الأساسي - تحليل مستند واحد:

```python
from agentic_doc.parse import parse

# تحليل ملف PDF محلي
results = parse("path/to/your/document.pdf")

# تحليل من URL
results = parse("https://example.com/document.pdf")

# تحليل صورة
results = parse("path/to/your/image.jpg")

# الوصول إلى المحتوى المحلل
parsed_doc = results[0]
print(f"عنوان المستند: {parsed_doc.title}")
print(f"عدد القطع: {len(parsed_doc.chunks)}")
print(f"محتوى Markdown: {parsed_doc.markdown}")
```

### فهم هيكل النتيجة

تُرجع المكتبة نتيجة منظمة مع المكونات الرئيسية التالية:

```python
from agentic_doc.parse import parse

results = parse("document.pdf")
parsed_doc = results[0]

# بيانات وصفية للمستند
print(f"العنوان: {parsed_doc.title}")
print(f"عدد الصفحات: {parsed_doc.page_count}")
print(f"وقت المعالجة: {parsed_doc.processing_time}")

# التكرار عبر قطع المحتوى
for i, chunk in enumerate(parsed_doc.chunks):
    print(f"القطعة {i}:")
    print(f"  النوع: {chunk.chunk_type}")
    print(f"  المحتوى: {chunk.content[:100]}...")  # أول 100 حرف
    print(f"  الصفحة: {chunk.page}")
    print(f"  الصندوق المحيط: {chunk.grounding[0].bbox if chunk.grounding else 'غير متوفر'}")
    print("---")

# الحصول على تمثيل Markdown الكامل
markdown_content = parsed_doc.markdown
print("المستند الكامل كـ Markdown:")
print(markdown_content)
```

## الميزات المتقدمة

### معالجة ملفات PDF الكبيرة

إحدى الميزات البارزة للمكتبة هي قدرتها على التعامل مع المستندات الكبيرة تلقائياً:

```python
from agentic_doc.parse import parse

# تتعامل المكتبة تلقائياً مع ملفات PDF الكبيرة
# عن طريق تقسيمها إلى قطع قابلة للإدارة ومعالجتها بالتوازي
results = parse("very-large-document.pdf")

parsed_doc = results[0]
print(f"تمت معالجة {parsed_doc.page_count} صفحة بنجاح")

# التحقق من أخطاء المعالجة
if parsed_doc.errors:
    print("تم مواجهة أخطاء في المعالجة:")
    for error in parsed_doc.errors:
        print(f"  الصفحة {error.page}: {error.message}")
```

### معالجة مستندات متعددة بالدفعات

معالجة مستندات متعددة بشكل متزامن مع التوازي القابل للتكوين:

```python
from agentic_doc.parse import parse

# معالجة مستندات متعددة بالدفعات
document_paths = [
    "document1.pdf",
    "document2.pdf", 
    "https://example.com/document3.pdf",
    "image.jpg"
]

# معالجة بالدفعات مع الإعدادات الافتراضية
results = parse(document_paths)

# معالجة النتائج
for i, parsed_doc in enumerate(results):
    print(f"المستند {i+1}: {parsed_doc.title}")
    print(f"  الصفحات: {parsed_doc.page_count}")
    print(f"  القطع: {len(parsed_doc.chunks)}")
    
    # التحقق من الأخطاء
    if parsed_doc.errors:
        print(f"  الأخطاء: {len(parsed_doc.errors)}")
```

### التأسيس البصري وتصحيح الأخطاء

استخراج وحفظ المناطق البصرية حيث تم العثور على المحتوى:

```python
from agentic_doc.parse import parse

# تحليل المستند وحفظ صور التأسيس
results = parse(
    "document.pdf",
    grounding_save_dir="./grounding_images"
)

parsed_doc = results[0]

# طباعة مسارات صور التأسيس المحفوظة
for chunk in parsed_doc.chunks:
    for grounding in chunk.grounding:
        if grounding.image_path:
            print(f"تم حفظ التأسيس في: {grounding.image_path}")
```

### تصور المستندات

إنشاء تصورات مشروحة تُظهر نتائج الاستخراج:

```python
from agentic_doc.parse import parse
from agentic_doc.utils import viz_parsed_document
from agentic_doc.config import VisualizationConfig
from agentic_doc.schema import ChunkType

# تحليل المستند
results = parse("document.pdf")
parsed_doc = results[0]

# إنشاء تصورات مع الإعدادات الافتراضية
images = viz_parsed_document(
    "document.pdf",
    parsed_doc,
    output_dir="./visualizations"
)

# تخصيص مظهر التصور
viz_config = VisualizationConfig(
    thickness=3,  # صناديق محيطة أكثر سمكاً
    text_bg_opacity=0.9,  # خلفية نص أكثر عتامة
    font_scale=0.8,  # نص أكبر
    color_map={
        ChunkType.TITLE: (255, 0, 0),    # أحمر للعناوين
        ChunkType.TEXT: (0, 255, 0),     # أخضر للنص
        ChunkType.TABLE: (0, 0, 255),    # أزرق للجداول
    }
)

# إنشاء تصورات مخصصة
custom_images = viz_parsed_document(
    "document.pdf",
    parsed_doc,
    output_dir="./custom_visualizations",
    viz_config=viz_config
)

print(f"تم إنشاء {len(custom_images)} صورة تصور")
```

## التكوين والتحسين

### تكوين البيئة

إنشاء ملف `.env` لتخصيص سلوك المكتبة:

```bash
# تكوين ملف .env
VISION_AGENT_API_KEY=your-api-key-here

# إعدادات التوازي
BATCH_SIZE=4          # عدد الملفات للمعالجة بالتوازي
MAX_WORKERS=5         # الخيوط لكل ملف لمعالجة المستندات الكبيرة

# تكوين إعادة المحاولة
MAX_RETRIES=100       # الحد الأقصى لمحاولات إعادة المحاولة
MAX_RETRY_WAIT_TIME=60  # الحد الأقصى لوقت الانتظار لكل إعادة محاولة (ثواني)

# تكوين التسجيل
RETRY_LOGGING_STYLE=log_msg  # الخيارات: log_msg, inline_block, none
```

### تحسين الأداء

```python
import os
from agentic_doc.parse import parse

# تكوين إعدادات الأداء برمجياً
os.environ['BATCH_SIZE'] = '6'
os.environ['MAX_WORKERS'] = '8'
os.environ['MAX_RETRIES'] = '50'

# معالجة المستندات مع الإعدادات المحسنة
results = parse(["doc1.pdf", "doc2.pdf", "doc3.pdf"])
```

### خيارات التحليل المتقدمة

```python
from agentic_doc.parse import parse

# تحليل متقدم مع خيارات مخصصة
results = parse(
    "document.pdf",
    include_marginalia=False,        # استبعاد الرؤوس/التذييلات
    include_metadata_in_markdown=False,  # إخراج markdown نظيف
    grounding_save_dir="./groundings"    # حفظ التأسيس البصري
)

parsed_doc = results[0]
print(f"تم استخراج محتوى نظيف: {len(parsed_doc.chunks)} قطعة")
```

## معالجة الأخطاء واستكشاف الأخطاء وإصلاحها

### معالجة أخطاء قوية

```python
from agentic_doc.parse import parse
import logging

# تفعيل التسجيل المفصل
logging.basicConfig(level=logging.INFO)

try:
    results = parse("problematic-document.pdf")
    parsed_doc = results[0]
    
    # التحقق من أخطاء التحليل
    if parsed_doc.errors:
        print("تمت معالجة المستند مع أخطاء:")
        for error in parsed_doc.errors:
            print(f"  الصفحة {error.page}: {error.error_code} - {error.message}")
    else:
        print("تمت معالجة المستند بنجاح!")
        
except Exception as e:
    print(f"فشل في معالجة المستند: {e}")
    # التعامل مع مشاكل مفتاح API، مشاكل الشبكة، إلخ.
```

### المشاكل الشائعة والحلول

```python
# التعامل مع تحديد المعدل بأناقة
import os
from agentic_doc.parse import parse

# تقليل التوازي للحسابات محدودة المعدل
os.environ['BATCH_SIZE'] = '1'
os.environ['MAX_WORKERS'] = '2'
os.environ['RETRY_LOGGING_STYLE'] = 'inline_block'

try:
    results = parse("large-document.pdf")
    print("اكتملت المعالجة بنجاح")
except Exception as e:
    if "rate limit" in str(e).lower():
        print("تم تجاوز حد المعدل. فكر في تقليل BATCH_SIZE و MAX_WORKERS")
    elif "api key" in str(e).lower():
        print("مشكلة في مفتاح API. تحقق من متغير البيئة VISION_AGENT_API_KEY")
    else:
        print(f"خطأ غير متوقع: {e}")
```

## حالات الاستخدام الواقعية

### معالجة المستندات المالية

```python
from agentic_doc.parse import parse
import json

def process_financial_reports(report_paths):
    """معالجة التقارير المالية واستخراج المعلومات الرئيسية."""
    results = parse(report_paths)
    
    financial_data = []
    for i, parsed_doc in enumerate(results):
        doc_data = {
            'filename': report_paths[i],
            'title': parsed_doc.title,
            'page_count': parsed_doc.page_count,
            'tables': [],
            'key_figures': []
        }
        
        # استخراج الجداول والبيانات الرقمية
        for chunk in parsed_doc.chunks:
            if chunk.chunk_type.name == 'TABLE':
                doc_data['tables'].append(chunk.content)
            elif any(keyword in chunk.content.lower() 
                    for keyword in ['إيرادات', 'ربح', 'خسارة', 'دولار', '%']):
                doc_data['key_figures'].append(chunk.content)
        
        financial_data.append(doc_data)
    
    return financial_data

# معالجة التقارير الربعية
reports = ['q1_report.pdf', 'q2_report.pdf', 'q3_report.pdf']
financial_analysis = process_financial_reports(reports)

# حفظ البيانات المنظمة
with open('financial_analysis.json', 'w', encoding='utf-8') as f:
    json.dump(financial_analysis, f, indent=2, ensure_ascii=False)
```

### تحليل الأوراق البحثية

```python
from agentic_doc.parse import parse
import re

def analyze_research_papers(paper_urls):
    """تحليل الأوراق البحثية واستخراج الملخصات والخلاصات."""
    results = parse(paper_urls)
    
    analysis = []
    for i, parsed_doc in enumerate(results):
        paper_analysis = {
            'url': paper_urls[i],
            'title': parsed_doc.title,
            'abstract': None,
            'conclusion': None,
            'references_count': 0,
            'figures_count': 0
        }
        
        for chunk in parsed_doc.chunks:
            content_lower = chunk.content.lower()
            
            # استخراج الملخص
            if 'abstract' in content_lower and not paper_analysis['abstract']:
                paper_analysis['abstract'] = chunk.content
            
            # استخراج الخلاصة
            if any(word in content_lower for word in ['conclusion', 'summary', 'findings']):
                paper_analysis['conclusion'] = chunk.content
            
            # عد المراجع والأشكال
            if 'reference' in content_lower or 'bibliography' in content_lower:
                paper_analysis['references_count'] += len(re.findall(r'\[\d+\]', chunk.content))
            
            if chunk.chunk_type.name in ['FIGURE', 'IMAGE']:
                paper_analysis['figures_count'] += 1
        
        analysis.append(paper_analysis)
    
    return analysis

# تحليل الأوراق البحثية
paper_urls = [
    'https://arxiv.org/pdf/2301.00001.pdf',
    'https://arxiv.org/pdf/2301.00002.pdf'
]

research_analysis = analyze_research_papers(paper_urls)
for paper in research_analysis:
    print(f"العنوان: {paper['title']}")
    print(f"الأشكال: {paper['figures_count']}")
    print(f"المراجع: {paper['references_count']}")
    print("---")
```

## أفضل الممارسات والنصائح

### تحسين الأداء

1. **المعالجة بالدفعات**: معالجة مستندات متعددة معاً لإنتاجية أفضل
2. **تكوين التوازي**: ضبط `BATCH_SIZE` و `MAX_WORKERS` حسب حدود API الخاصة بك
3. **معالجة الأخطاء**: تحقق دائماً من أخطاء المعالجة في النتائج
4. **إدارة الموارد**: استخدم صور التأسيس فقط عند الحاجة لتصحيح الأخطاء

### النشر الإنتاجي

```python
import os
from agentic_doc.parse import parse
import logging

# تكوين الإنتاج
def setup_production_config():
    """تكوين المكتبة للاستخدام الإنتاجي."""
    os.environ['BATCH_SIZE'] = '2'  # محافظ للاستقرار
    os.environ['MAX_WORKERS'] = '3'
    os.environ['MAX_RETRIES'] = '10'
    os.environ['RETRY_LOGGING_STYLE'] = 'none'  # تقليل ضوضاء السجل
    
    # إعداد التسجيل
    logging.basicConfig(
        level=logging.WARNING,
        format='%(asctime)s - %(levelname)s - %(message)s'
    )

def process_documents_safely(document_paths):
    """معالجة المستندات بأمان مع معالجة شاملة للأخطاء."""
    setup_production_config()
    
    successful_results = []
    failed_documents = []
    
    try:
        results = parse(document_paths)
        
        for i, result in enumerate(results):
            if result.errors:
                failed_documents.append({
                    'path': document_paths[i],
                    'errors': result.errors
                })
            else:
                successful_results.append(result)
                
    except Exception as e:
        logging.error(f"فشلت المعالجة بالدفعات: {e}")
        return None, document_paths
    
    return successful_results, failed_documents

# الاستخدام في الإنتاج
documents = ['doc1.pdf', 'doc2.pdf', 'doc3.pdf']
success, failures = process_documents_safely(documents)

if success:
    print(f"تمت معالجة {len(success)} مستندات بنجاح")
if failures:
    print(f"فشل في معالجة {len(failures)} مستندات")
```

## الخلاصة

تمثل مكتبة LandingAI's Agentic Document Extraction تقدماً مهماً في معالجة المستندات المدعومة بالذكاء الاصطناعي. قدرتها على التعامل مع التخطيطات المعقدة ومعالجة المستندات الكبيرة وتوفير إخراج منظم مع التأسيس البصري يجعلها أداة لا تقدر بثمن لسير عمل استخراج البيانات الحديثة.

### النقاط الرئيسية

- **جاهز للمؤسسة**: يتعامل مع المستندات بأي حجم مع التوسع التلقائي
- **مدعوم بالذكاء الاصطناعي**: فهم متقدم لتخطيطات المستندات المعقدة
- **صديق للمطور**: API بسيط مع خيارات تكوين قوية
- **جاهز للإنتاج**: آليات إعادة المحاولة المدمجة ومعالجة الأخطاء
- **إخراج مرن**: تنسيقات JSON منظمة و Markdown

### الخطوات التالية

1. **التجريب**: جرب المكتبة مع مستنداتك الخاصة
2. **التحسين**: ضبط التكوين لحالة الاستخدام المحددة الخاصة بك
3. **التكامل**: بناء المكتبة في سير العمل الموجود لديك
4. **التوسع**: الاستفادة من المعالجة بالدفعات لأحمال العمل الإنتاجية

مستقبل معالجة المستندات هنا، ومع LandingAI's Agentic Document Extraction، أنت مجهز للتعامل مع أكثر تحديات معالجة المستندات تعقيداً بثقة.

---

**الموارد:**
- [LandingAI Agentic Document Extraction GitHub](https://github.com/landing-ai/agentic-doc)
- [الوثائق الرسمية](https://landing.ai/agentic-document-extraction)
- [وثائق API](https://landing.ai/docs)
- [احصل على مفتاح API](https://landing.ai/)

*معالجة مستندات سعيدة! 🚀*
