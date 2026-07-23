---
title: "Helm Dashboard: دليل شامل لإدارة مخططات Helm في Kubernetes عبر واجهة المستخدم"
excerpt: "برنامج تعليمي شامل حول Helm Dashboard - واجهة المستخدم المفقودة لـ Helm التي تبسط إدارة مخططات Kubernetes بواجهة مرئية وسجل المراجعات وإمكانيات الاستعادة السهلة."
seo_title: "دروس Helm Dashboard: دليل واجهة مخططات Helm في Kubernetes - Thaki Cloud"
seo_description: "تعلم كيفية تثبيت واستخدام Helm Dashboard لـ Kubernetes. دليل شامل يغطي طرق التثبيت وإدارة المخططات وعمليات الاستعادة وأفضل ممارسات واجهة Helm."
date: 2025-10-10
tags:
  - helm
  - kubernetes
  - helm-dashboard
  - k8s
  - devops
  - helm-plugin
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/helm-dashboard-kubernetes-ui-complete-guide/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/helm-dashboard-kubernetes-ui-complete-guide-ar/"
categories:
  - tutorials
---

⏱️ **وقت القراءة المقدر**: 12 دقيقة

## المقدمة

يمكن أن تكون إدارة مخططات Helm في Kubernetes أمرًا صعبًا عندما تقتصر على واجهات سطر الأوامر. **Helm Dashboard** هو مشروع مفتوح المصدر يوفر واجهة ويب سهلة الاستخدام لعرض مخططات Helm المثبتة، وفحص سجل المراجعات، وإجراء عمليات مثل الاستعادة والترقية مع مقارنات البيان المرئية.

سيرشدك هذا البرنامج التعليمي الشامل خلال تثبيت Helm Dashboard واستكشاف ميزاته والاستفادة منه لإدارة مخططات Kubernetes بكفاءة.

### ما هو Helm Dashboard؟

Helm Dashboard هو أداة مفتوحة المصدر طورتها Komodor توفر نهجًا قائمًا على واجهة المستخدم للعمل مع مخططات Helm. على عكس Helm CLI التقليدي، يوفر:

- **إدارة المخططات المرئية**: عرض جميع المخططات المثبتة في لمحة واحدة
- **سجل المراجعات**: تتبع التغييرات عبر إصدارات المخططات
- **عارض مقارنة البيان**: مقارنة التكوينات بين المراجعات
- **تصفح الموارد**: استكشاف موارد Kubernetes الناتجة عن المخطط
- **عمليات سهلة**: إجراء الاستعادة أو الترقية بثقة واضحة ومقارنة بيان سهلة
- **دعم متعدد الكتل**: التبديل بين كتل Kubernetes المختلفة
- **تشغيل مستقل**: يعمل دون الحاجة لتثبيت Helm أو kubectl

يوضح الرسم التالي كيف يقع Helm Dashboard بين المتصفح وعدة عناقيد Kubernetes. يتصل خادم واحد بالعناقيد عبر سياقات kubeconfig، ويقرأ سجل المراجعات المخزن في أسرار الإصدارات، ويجمع كل شيء من العرض إلى التراجع في شاشة واحدة.

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
<div class="d3-arch" data-arch-root id="ernetesuicompleteguidear-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1146, "height": 738, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 278, "y": 24, "w": 836, "h": 124, "label": "الميزات الأساسية للوحة", "lx": 290, "ly": 42}], "nodes": [{"id": "USER", "x": 121, "y": 63, "w": 120, "h": 46, "title": "متصفح المشغل"}, {"id": "UI", "x": 96, "y": 226, "w": 170, "h": 46, "title": "واجهة Helm Dashboard"}, {"id": "SRV", "x": 82, "y": 350, "w": 198, "h": 78, "title": ["خادم Helm Dashboard", "ملف Go واحد، لا حاجة إلى", "kubectl"]}, {"id": "K1", "x": 410, "y": 520, "w": 156, "h": 46, "title": "عنقود Kubernetes A"}, {"id": "K2", "x": 199, "y": 520, "w": 156, "h": 46, "title": "عنقود Kubernetes B"}, {"id": "REL", "x": 407, "y": 644, "w": 163, "h": 62, "title": ["أسرار إصدارات Helm", "تخزين سجل المراجعات"]}, {"id": "F1", "x": 316, "y": 63, "w": 191, "h": 46, "title": "عرض المخططات والمراجعات"}, {"id": "F2", "x": 562, "y": 63, "w": 128, "h": 46, "title": "مقارنة الملفات"}, {"id": "F3", "x": 745, "y": 63, "w": 142, "h": 46, "title": "التراجع والترقية"}, {"id": "F4", "x": 942, "y": 63, "w": 135, "h": 46, "title": "استكشاف الموارد"}, {"id": "FEAT", "x": 24, "y": 520, "w": 120, "h": 46, "title": "FEAT"}], "edges": [{"src": "USER", "dst": "UI", "kind": "data", "line": [181, 109, 181, 226]}, {"src": "UI", "dst": "SRV", "kind": "data", "line": [181, 272, 181, 350]}, {"src": "SRV", "dst": "K1", "kind": "data", "label": "\"سياقات kubeconfig\"", "curve": [[280, 416], [488, 474], [488, 474], [488, 520]], "off": "50%"}, {"src": "SRV", "dst": "K2", "kind": "data", "label": "\"التبديل بين العناقيد\"", "curve": [[225, 428], [277, 474], [277, 474], [277, 520]], "off": "50%"}, {"src": "K1", "dst": "REL", "kind": "data", "line": [488, 566, 488, 644]}, {"src": "SRV", "dst": "FEAT", "kind": "data", "curve": [[136, 428], [84, 474], [84, 474], [84, 520]]}]});
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
      const container = document.getElementById('ernetesuicompleteguidear-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ernetesuicompleteguidear-1';
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

### لماذا تستخدم Helm Dashboard؟

تتطلب إدارة Helm التقليدية تذكر العديد من أوامر CLI وتجميع المعلومات من مصادر متعددة. يحل Helm Dashboard هذه المشكلة من خلال:

1. **تقليل العبء المعرفي**: تلغي واجهة المستخدم المرئية الحاجة لحفظ الأوامر المعقدة
2. **تحسين الرؤية**: رؤية الحالة الكاملة لإصدارات Helm في مكان واحد
3. **منع الأخطاء**: يظهر الفرق المرئي بالضبط ما سيتغير قبل تطبيق التحديثات
4. **تسريع استكشاف الأخطاء**: تحديد المراجعات الإشكالية بسرعة والاستعادة
5. **تعزيز التعاون**: يمكن لأعضاء الفريق استكشاف المخططات دون خبرة Helm عميقة

## المتطلبات الأساسية

قبل البدء في هذا البرنامج التعليمي، تأكد من توفر:

- **كتلة Kubernetes**: كتلة قيد التشغيل (minikube أو kind أو كتلة إنتاج)
- **معرفة Kubernetes الأساسية**: فهم Pods والخدمات والنشر
- **macOS أو Linux أو Windows**: يدعم Helm Dashboard جميع المنصات الرئيسية
- **متصفح ويب**: متصفح حديث للوصول إلى واجهة المستخدم

**ملاحظة**: Helm و kubectl **غير مطلوبين** عند استخدام طريقة تثبيت الملف التنفيذي المستقل.

## طرق التثبيت

يقدم Helm Dashboard ثلاثة أساليب للتثبيت، كل منها مناسب لحالات استخدام مختلفة.

### الطريقة 1: الملف التنفيذي المستقل (موصى به)

الملف التنفيذي المستقل هو أبسط وأكثر طرق التثبيت مرونة. لا يتطلب تثبيت Helm أو kubectl على نظامك.

#### الخطوة 1: تنزيل الملف التنفيذي

قم بزيارة [صفحة إصدارات Helm Dashboard](https://github.com/komodorio/helm-dashboard/releases) وقم بتنزيل الحزمة المناسبة لمنصتك:

```bash
# لـ macOS (Apple Silicon)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Darwin_arm64.tar.gz
tar -xzf helm-dashboard_Darwin_arm64.tar.gz

# لـ macOS (Intel)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Darwin_x86_64.tar.gz
tar -xzf helm-dashboard_Darwin_x86_64.tar.gz

# لـ Linux (AMD64)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Linux_x86_64.tar.gz
tar -xzf helm-dashboard_Linux_x86_64.tar.gz
```

#### الخطوة 2: جعله قابلاً للتنفيذ والتشغيل

```bash
chmod +x dashboard
./dashboard
```

سيبدأ لوح المعلومات خادم ويب على `http://localhost:8080` وسيفتح متصفحك تلقائيًا.

### الطريقة 2: تثبيت إضافة Helm

إذا كنت تستخدم Helm بالفعل وتفضل الأدوات القائمة على الإضافات، قم بتثبيت Helm Dashboard كإضافة Helm.

#### المتطلبات
- Helm 3.4.0 أو أحدث
- kubectl مهيأ بوصول إلى الكتلة

#### التثبيت

```bash
# تثبيت الإضافة
helm plugin install https://github.com/komodorio/helm-dashboard.git

# التحقق من التثبيت
helm plugin list
```

#### الاستخدام

```bash
# بدء لوح المعلومات
helm dashboard

# البدء بمنفذ مخصص
helm dashboard --port 9090

# البدء دون فتح المتصفح تلقائيًا
helm dashboard --no-browser

# التقييد بمساحة اسم محددة
helm dashboard --namespace production
```

#### إدارة الإضافة

```bash
# تحديث الإضافة
helm plugin update dashboard

# إلغاء تثبيت الإضافة
helm plugin uninstall dashboard
```

### الطريقة 3: النشر في كتلة Kubernetes

لبيئات الفريق، قم بنشر Helm Dashboard مباشرة في كتلة Kubernetes الخاصة بك باستخدام مخطط Helm الرسمي.

```bash
# إضافة مستودع Helm Dashboard
helm repo add komodorio https://helm-charts.komodor.io
helm repo update

# التثبيت في الكتلة
helm install helm-dashboard komodorio/helm-dashboard \
  --namespace helm-dashboard \
  --create-namespace

# الوصول عبر إعادة توجيه المنفذ
kubectl port-forward -n helm-dashboard svc/helm-dashboard 8080:8080
```

ثم انتقل إلى `http://localhost:8080` في متصفحك.

## اختبار التثبيت

دعنا نتحقق من أن Helm Dashboard يعمل بشكل صحيح من خلال تثبيت مخطط عينة واستكشافه عبر واجهة المستخدم.

### الخطوة 1: إنشاء نص الاختبار

```bash
#!/bin/bash
# الملف: test-helm-dashboard.sh

set -e

echo "🚀 اختبار تثبيت Helm Dashboard..."

# التحقق من توفر kubectl
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl غير مثبت. يرجى تثبيت kubectl أولاً."
    exit 1
fi

# التحقق من اتصال الكتلة
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ لا يمكن الاتصال بكتلة Kubernetes. يرجى تكوين kubectl."
    exit 1
fi

# إنشاء مساحة اسم الاختبار
echo "📦 إنشاء مساحة اسم الاختبار..."
kubectl create namespace helm-dashboard-test --dry-run=client -o yaml | kubectl apply -f -

# تثبيت مخطط عينة (nginx)
echo "📥 تثبيت مخطط nginx العينة..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install test-nginx bitnami/nginx \
  --namespace helm-dashboard-test \
  --set service.type=ClusterIP \
  --wait

# التحقق من التثبيت
echo "✅ التحقق من التثبيت..."
helm list -n helm-dashboard-test

echo ""
echo "✨ نجح! يمكنك الآن:"
echo "1. بدء Helm Dashboard: ./dashboard (أو helm dashboard)"
echo "2. الانتقال إلى: http://localhost:8080"
echo "3. اختر مساحة الاسم 'helm-dashboard-test'"
echo "4. عرض الإصدار 'test-nginx'"
echo ""
echo "🧹 للتنظيف: kubectl delete namespace helm-dashboard-test"
```

### الخطوة 2: تشغيل الاختبار

```bash
chmod +x test-helm-dashboard.sh
./test-helm-dashboard.sh
```

### الخطوة 3: استكشاف لوح المعلومات

1. **بدء لوح المعلومات**: قم بتشغيل `./dashboard` أو `helm dashboard`
2. **فتح المتصفح**: انتقل إلى `http://localhost:8080`
3. **اختر مساحة الاسم**: اختر `helm-dashboard-test` من القائمة المنسدلة
4. **عرض الإصدار**: انقر على الإصدار `test-nginx`

يجب أن ترى معلومات تفصيلية حول نشر nginx، بما في ذلك:
- إصدار المخطط وإصدار التطبيق
- الطابع الزمني للتثبيت
- الحالة الحالية
- قائمة موارد Kubernetes التي تم إنشاؤها

## الميزات الأساسية والاستخدام

### 1. عرض المخططات المثبتة

يعرض عرض لوحة المعلومات الرئيسية جميع إصدارات Helm عبر مساحات الأسماء المحددة:

- **اسم الإصدار**: الاسم الذي أعطيته أثناء التثبيت
- **مساحة الاسم**: حيث تم نشر المخطط
- **إصدار المخطط**: إصدار مخطط Helm
- **إصدار التطبيق**: إصدار التطبيق الذي يتم نشره
- **الحالة**: الحالة الحالية (deployed، failed، pending-upgrade، إلخ)
- **محدث**: الطابع الزمني لآخر تعديل

**نصائح التنقل**:
- استخدم مرشح مساحة الاسم للتركيز على مساحات أسماء محددة
- انقر على أي إصدار لعرض معلومات تفصيلية
- استخدم مربع البحث للعثور بسرعة على الإصدارات بالاسم

### 2. فحص سجل المراجعات

يحتفظ كل إصدار Helm بسجل لجميع المراجعات. لعرض سجل المراجعات:

1. انقر على اسم الإصدار
2. انتقل إلى علامة التبويب **History**
3. راجع قائمة المراجعات التي تظهر:
   - رقم المراجعة
   - الطابع الزمني للتحديث
   - الحالة (superseded، deployed، failed)
   - إصدار المخطط
   - وصف التغييرات

**حالات الاستخدام**:
- تتبع من قام بالتغييرات ومتى
- فهم تطور النشر الخاص بك
- تحديد متى تم إدخال المشاكل

### 3. مقارنة الفروقات في البيان

واحدة من أقوى ميزات Helm Dashboard هي القدرة على مقارنة البيانات بين المراجعات:

1. افتح سجل الإصدار
2. اختر مراجعتين للمقارنة
3. انقر على **Diff** لرؤية مقارنة جنبًا إلى جنب
4. راجع الأسطر المضافة (خضراء) والمحذوفة (حمراء) والمتغيرة (صفراء)

**لماذا هذا مهم**:
- فهم ما تغير بالضبط بين الإصدارات
- تحديد مشاكل التكوين
- اتخاذ قرارات استعادة مستنيرة
- التحقق من تغييرات الترقية قبل التطبيق

### 4. تصفح موارد Kubernetes

يتيح لك Helm Dashboard استكشاف جميع موارد Kubernetes التي تم إنشاؤها بواسطة مخطط:

1. انقر على الإصدار
2. انتقل إلى علامة التبويب **Resources**
3. عرض الموارد المصنفة:
   - أحمال العمل (Deployment، StatefulSet، DaemonSet)
   - الخدمات و Ingress
   - ConfigMap و Secret
   - PersistentVolumeClaim
   - موارد مخصصة أخرى

**الميزات التفاعلية**:
- انقر على أي مورد لعرض تعريف YAML الخاص به
- تحقق من حالة المورد وصحته
- حدد علاقات الموارد

### 5. إجراء الاستعادة

عندما تحتاج إلى العودة إلى إصدار سابق:

1. افتح سجل الإصدار
2. حدد موقع المراجعة التي تريد الاستعادة إليها
3. انقر على زر **Rollback**
4. راجع فرق البيان الذي يظهر ما سيتغير
5. تأكيد عملية الاستعادة

**أفضل الممارسات**:
- راجع دائمًا الفرق قبل الاستعادة
- وثق سبب الاستعادة
- راقب التطبيق بعد الاستعادة
- فكر في الإصلاح للأمام بدلاً من الاستعادة عندما يكون ذلك ممكنًا

### 6. ترقية المخططات

لترقية مخطط إلى إصدار أحدث:

1. انقر على الإصدار
2. انقر على زر **Upgrade**
3. اختر إصدار المخطط الجديد
4. عدل القيم إذا لزم الأمر
5. راجع فرق البيان
6. تأكيد وتطبيق الترقية

**سير عمل الترقية**:
```yaml
الإصدار الحالي: nginx-15.0.0
الإصدار المستهدف: nginx-15.1.0

# يظهر لوح المعلومات:
- ما القيم التي ستتغير
- ما الموارد التي ستتم تعديلها
- ما الموارد التي ستتم إضافتها/إزالتها
```

### 7. إدارة متعددة الكتل

يمكن لـ Helm Dashboard العمل مع كتل Kubernetes متعددة:

1. تأكد من أن kubeconfig الخاص بك يتضمن سياقات متعددة
2. استخدم القائمة المنسدلة لمحدد الكتلة في واجهة المستخدم
3. التبديل بسلاسة بين الكتل

**مثال التكوين**:
```bash
# سرد السياقات المتاحة
kubectl config get-contexts

# تبديل السياق عبر kubectl
kubectl config use-context production-cluster

# سيكتشف لوح المعلومات التغيير تلقائيًا
```

## التكوين المتقدم

### المنفذ والربط المخصص

افتراضيًا، يرتبط Helm Dashboard بـ `localhost:8080`. للتخصيص:

```bash
# باستخدام العلم
./dashboard --port 9090 --bind=0.0.0.0

# باستخدام متغير البيئة
export HD_BIND=0.0.0.0
export HD_PORT=9090
./dashboard
```

**تحذير أمني**: يؤدي الربط بـ `0.0.0.0` إلى تعريض لوح المعلومات لجميع واجهات الشبكة. افعل هذا فقط في بيئات آمنة.

### تصفية مساحة الاسم

قصر عمليات لوح المعلومات على مساحات أسماء محددة:

```bash
# مساحة اسم واحدة
./dashboard --namespace production

# مساحات أسماء متعددة
./dashboard --namespace="production,staging,development"
```

### السجل التفصيلي

تمكين السجل التفصيلي لاستكشاف الأخطاء:

```bash
./dashboard --verbose
```

يوفر هذا:
- سجلات طلبات HTTP
- تفاصيل عمليات Helm
- تتبع أخطاء المكدس
- مقاييس الأداء

### تعطيل التحليلات

يجمع Helm Dashboard تحليلات استخدام مجهولة لتحسين المشروع. للتعطيل:

```bash
./dashboard --no-analytics
```

### التحكم في المتصفح

منع فتح المتصفح تلقائيًا:

```bash
./dashboard --no-browser
```

ثم انتقل يدويًا إلى عنوان URL المعروض.

## حالات الاستخدام الواقعية

### حالة الاستخدام 1: تصحيح أخطاء النشر الفاشل

**السيناريو**: فشلت ترقية المخطط وتحتاج إلى فهم السبب.

**الحل مع Helm Dashboard**:
1. افتح الإصدار في لوح المعلومات
2. تحقق من علامة التبويب **History** - سترى مراجعة موسومة بـ "failed"
3. قارن المراجعة الفاشلة مع المراجعة الناجحة السابقة باستخدام **Diff**
4. حدد تغيير التكوين الإشكالي
5. استعد إلى آخر مراجعة عاملة
6. أصلح المشكلة وأعد محاولة الترقية

**الوقت الموفر**: ما كان يستغرق 15-20 دقيقة بأوامر CLI يستغرق 2-3 دقائق مع المقارنة المرئية.

### حالة الاستخدام 2: تأهيل أعضاء الفريق الجدد

**السيناريو**: يحتاج المطورون الجدد إلى فهم التطبيقات المنشورة.

**الحل مع Helm Dashboard**:
1. شارك عنوان URL للوحة المعلومات (إذا تم النشر داخل الكتلة)
2. يمكن لأعضاء الفريق الجدد استكشاف:
   - ما التطبيقات التي تعمل
   - كيف تم تكوينها
   - ما الموارد التي تستخدمها
   - سجل النشر الخاص بها
3. لا حاجة لتعلم Helm CLI على الفور

**الفائدة**: يقلل وقت التأهيل من أيام إلى ساعات.

### حالة الاستخدام 3: تدقيق التغييرات

**السيناريو**: تحتاج إلى إنشاء مسار تدقيق لتغييرات البنية التحتية.

**الحل مع Helm Dashboard**:
1. استخدم علامة التبويب **History** لمراجعة جميع التغييرات
2. تصدير معلومات المراجعة
3. قارن البيانات لرؤية التغييرات الدقيقة
4. وثق من قام بالتغييرات ومتى

**الامتثال**: يساعد في تلبية متطلبات التدقيق للصناعات المنظمة.

### حالة الاستخدام 4: نشر الإنتاج الآمن

**السيناريو**: ترقية خدمة إنتاج حرجة تتطلب التحقق الدقيق.

**الحل مع Helm Dashboard**:
1. اختبر الترقية في بيئة التدريج أولاً
2. استخدم لوح المعلومات لمقارنة تكوينات التدريج مقابل الإنتاج
3. راجع فرق البيان لترقية الإنتاج
4. تحقق من عدم وجود تغييرات غير متوقعة
5. تابع بثقة أو قم بالإلغاء إذا تم اكتشاف مشاكل

**تخفيف المخاطر**: يمنع حوادث الإنتاج الناجمة عن انحراف التكوين.

## استكشاف المشاكل الشائعة

### المشكلة 1: لوح المعلومات لن يبدأ

**الأعراض**: رسالة خطأ عند تشغيل `./dashboard`

**الحلول**:

```bash
# تحقق مما إذا كان المنفذ 8080 قيد الاستخدام بالفعل
lsof -i :8080

# استخدم منفذًا مختلفًا
./dashboard --port 8081

# تحقق من اتصال Kubernetes
kubectl cluster-info

# تحقق من kubeconfig
kubectl config view
```

### المشكلة 2: لا تظهر الإصدارات

**الأعراض**: يتم تحميل لوح المعلومات لكن لا تظهر الإصدارات

**الأسباب المحتملة**:
1. مساحة اسم خاطئة محددة
2. لم يتم تثبيت إصدارات Helm
3. أذونات RBAC غير كافية

**الحلول**:

```bash
# سرد جميع الإصدارات في جميع مساحات الأسماء
helm list --all-namespaces

# تحقق من سياق مساحة الاسم الحالية
kubectl config view --minify | grep namespace:

# تحقق من أذونات RBAC
kubectl auth can-i list secrets
kubectl auth can-i get secrets
```

### المشكلة 3: لا يمكن الاتصال بالكتلة

**الأعراض**: خطأ حول فشل اتصال Kubernetes

**الحلول**:

```bash
# تحقق من تشغيل الكتلة
kubectl cluster-info

# تحقق من مسار kubeconfig
echo $KUBECONFIG
ls -la ~/.kube/config

# اختبار الاتصال
kubectl get nodes

# لمستخدمي minikube
minikube status
minikube start
```

### المشكلة 4: لا يظهر الفرق

**الأعراض**: يظهر فرق البيان فارغًا

**الأسباب المحتملة**:
1. مقارنة مراجعات متطابقة
2. انتهاء مهلة البيانات الكبيرة
3. مشاكل التخزين المؤقت للمتصفح

**الحلول**:
1. قم بتحديث صفحة المتصفح
2. امسح ذاكرة التخزين المؤقت للمتصفح
3. جرب متصفحًا مختلفًا
4. تحقق من السجلات التفصيلية للأخطاء

## اعتبارات الأمان

### التحكم في الوصول

يرث Helm Dashboard الأذونات من kubeconfig الذي يستخدمه. للحد من الوصول:

1. **حساب الخدمة**: أنشئ حساب خدمة مخصصًا بأذونات محدودة
2. **RBAC**: حدد أدوارًا محددة لعمليات Helm Dashboard
3. **عزل مساحة الاسم**: استخدم حسابات خدمة محددة النطاق لمساحة الاسم

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: helm-dashboard-readonly
  namespace: helm-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: helm-dashboard-readonly
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helm-dashboard-readonly
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: helm-dashboard-readonly
subjects:
- kind: ServiceAccount
  name: helm-dashboard-readonly
  namespace: helm-dashboard
```

### أمان الشبكة

عند عرض Helm Dashboard:

1. **محلي فقط**: ربط `localhost` الافتراضي هو الأكثر أمانًا لسيناريوهات المستخدم الواحد
2. **الشبكة الداخلية**: استخدم `0.0.0.0` فقط داخل الشبكات الموثوقة
3. **المصادقة**: فكر في إضافة وكيل مصادقة (OAuth2 Proxy، Pomerium)
4. **TLS**: استخدم TLS لأي عرض خارجي
5. **جدار الحماية**: قصر الوصول على نطاقات IP المصرح بها

### إدارة الأسرار

يمكن لـ Helm Dashboard عرض أسرار Kubernetes التي تخزن بيانات إصدار Helm:

1. **مبدأ الامتياز الأدنى**: امنح الأذونات اللازمة فقط
2. **سجل التدقيق**: مكّن سجلات تدقيق Kubernetes لتتبع الوصول إلى الأسرار
3. **تشفير الأسرار**: تأكد من تمكين تشفير etcd
4. **المراجعة الدورية**: راجع بشكل دوري من لديه حق الوصول

## تحسين الأداء

### للكتل الكبيرة

إذا كنت تدير العديد من إصدارات Helm:

1. **تصفية مساحة الاسم**: استخدم `--namespace` للحد من النطاق
2. **حدود الموارد**: عند النشر داخل الكتلة، ضع حدود موارد مناسبة
3. **التخزين المؤقت**: يخزن Helm Dashboard بيانات الإصدار مؤقتًا - اضبط إعدادات التخزين المؤقت إذا لزم الأمر

```yaml
# عند النشر في الكتلة
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### أداء المتصفح

للبيانات ذات آلاف الأسطر:

1. **استخدم الفرق بشكل انتقائي**: قارن فقط عند الضرورة
2. **أغلق علامات التبويب غير المستخدمة**: يستخدم لوح المعلومات اتصالات WebSocket
3. **متصفح حديث**: استخدم أحدث Chrome/Firefox/Safari لأفضل أداء

## التكامل مع CI/CD

يمكن لـ Helm Dashboard استكمال خط أنابيب CI/CD الخاص بك:

### سير عمل GitOps

```bash
# نشر Helm Dashboard في الكتلة
helm install helm-dashboard komodorio/helm-dashboard

# يستخدم الفريق لوح المعلومات من أجل:
# 1. مراقبة النشر الذي تم تشغيله بواسطة ArgoCD/Flux
# 2. التحقق من أن التغييرات تطابق التزامات Git
# 3. الاستعادة السريعة في حالة اكتشاف مشاكل
```

### التحقق من التدريج

```bash
# في خط أنابيب CI (مثال مع GitHub Actions)
- name: النشر في التدريج
  run: helm upgrade --install myapp ./charts/myapp -n staging

- name: التحقق مع لوح المعلومات
  run: |
    # فتح لوح المعلومات للتحقق اليدوي
    echo "راجع النشر على: http://dashboard.staging.example.com"
    echo "قارن المراجعات وتحقق من التغييرات"
```

### إخطارات النشر

ادمج مع أدوات المراقبة:

```bash
# بعد النشر
helm upgrade --install myapp ./charts/myapp

# أخطر الفريق برابط لوح المعلومات
slack-notify "النشر الجديد جاهز. راجع: http://dashboard/myapp"
```

## المقارنة مع البدائل

| الميزة | Helm Dashboard | K9s | Lens | Rancher |
|---------|---------------|-----|------|---------|
| واجهة مستخدم خاصة بـ Helm | ✅ | ❌ | جزئي | ✅ |
| فرق المراجعة | ✅ | ❌ | ❌ | ✅ |
| ملف تنفيذي مستقل | ✅ | ✅ | ✅ | ❌ |
| متعدد الكتل | ✅ | ✅ | ✅ | ✅ |
| على الويب | ✅ | ❌ | ❌ (سطح المكتب) | ✅ |
| مفتوح المصدر | ✅ | ✅ | ✅ | ✅ |
| منحنى التعلم | منخفض | متوسط | منخفض | عالي |

**متى تستخدم Helm Dashboard**:
- التركيز الأساسي هو إدارة إصدار Helm
- تحتاج إلى مقارنة بيان مرئية
- تريد الوصول على الويب
- تفضل حلاً خفيفًا

**متى تستخدم البدائل**:
- **K9s**: لسير عمل قائم على الطرفية، إدارة K8s أوسع
- **Lens**: لتجربة IDE سطح مكتب شاملة
- **Rancher**: لإدارة متعددة الكتل على مستوى المؤسسة مع ميزات إضافية

## أفضل الممارسات

### 1. التحديثات الدورية

حافظ على تحديث Helm Dashboard:

```bash
# لتثبيت الإضافة
helm plugin update dashboard

# للملف التنفيذي المستقل
# قم بتنزيل أحدث إصدار بشكل دوري
```

### 2. توثيق الإصدارات الخاصة بك

استخدم علامة `--description` في Helm لتوثيق التغييرات:

```bash
helm upgrade myapp ./charts/myapp \
  --description "تم التحديث إلى v2.0.0 - تمت إضافة نقاط نهاية API جديدة"
```

يظهر هذا الوصف في عرض السجل في لوح المعلومات.

### 3. استخدام الإصدار الدلالي

اتبع الإصدار الدلالي لمخططاتك:

```yaml
# Chart.yaml
version: 2.1.0  # MAJOR.MINOR.PATCH
appVersion: 1.16.0
```

يصبح سجل لوح المعلومات أكثر معنى مع تقدم إصدار واضح.

### 4. المراجعة قبل التطبيق

استخدم دائمًا ميزة الفرق في لوح المعلومات قبل:
- الترقية إلى إصدار جديد
- الاستعادة إلى إصدار سابق
- تطبيق تغييرات القيمة

### 5. الجمع مع GitOps

استخدم لوح المعلومات للمراقبة واستكشاف الأخطاء، مع الحفاظ على Git كمصدر للحقيقة:

```bash
# Git يبقى مصدر الحقيقة
git commit -m "تحديث myapp إلى v2.0.0"
git push

# ArgoCD/Flux يطبق التغييرات
# استخدم لوح المعلومات للمراقبة والتحقق
```

### 6. استراتيجية مساحة الاسم

نظم الإصدارات حسب البيئة باستخدام مساحات الأسماء:

```bash
# التطوير
helm install myapp ./charts/myapp -n dev

# التدريج
helm install myapp ./charts/myapp -n staging

# الإنتاج
helm install myapp ./charts/myapp -n production
```

استخدم مرشح مساحة الاسم في لوح المعلومات للتبديل بين البيئات.

### 7. نسخ احتياطي لأسرار الإصدار

يخزن Helm بيانات الإصدار في أسرار Kubernetes. احتفظ بنسخة احتياطية منها:

```bash
# نسخ احتياطي لجميع أسرار إصدار Helm
kubectl get secrets -A -l owner=helm -o yaml > helm-releases-backup.yaml

# الاستعادة إذا لزم الأمر
kubectl apply -f helm-releases-backup.yaml
```

## تنظيف موارد الاختبار

بعد إكمال هذا البرنامج التعليمي، قم بتنظيف موارد الاختبار:

```bash
#!/bin/bash
# cleanup-helm-dashboard-test.sh

echo "🧹 تنظيف موارد اختبار Helm Dashboard..."

# إلغاء تثبيت إصدار الاختبار
helm uninstall test-nginx -n helm-dashboard-test

# حذف مساحة اسم الاختبار
kubectl delete namespace helm-dashboard-test

# إزالة الملفات التنفيذية المنزلة (اختياري)
# rm -f dashboard helm-dashboard_*.tar.gz

echo "✅ اكتمل التنظيف!"
```

قم بتشغيل نص التنظيف:

```bash
chmod +x cleanup-helm-dashboard-test.sh
./cleanup-helm-dashboard-test.sh
```

## الخلاصة

يسد Helm Dashboard الفجوة بين Helm CLI القوي والحاجة إلى أدوات الإدارة المرئية. من خلال توفير واجهة ويب بديهية، فإنه يجعل إدارة مخططات Helm في متناول كل من الخبراء والمبتدئين.

### النقاط الرئيسية

1. **تثبيت سهل**: طرق تثبيت متعددة تناسب بيئات مختلفة
2. **إدارة مرئية**: راجع إصدارات Helm الخاصة بك في لمحة
3. **عمليات آمنة**: تمنع ميزة الفرق أخطاء التكوين
4. **تعاون الفريق**: تقليل حاجز الدخول لأعضاء الفريق
5. **استكشاف الأخطاء**: تحديد وحل مشاكل النشر بسرعة
6. **جاهز للإنتاج**: مناسب لبيئات التطوير والإنتاج

### الخطوات التالية

لمتابعة رحلة Helm Dashboard الخاصة بك:

1. **النشر في كتلتك**: الانتقال من الملف التنفيذي المحلي إلى النشر داخل الكتلة
2. **التكامل مع CI/CD**: دمج لوح المعلومات في سير عمل النشر الخاص بك
3. **استكشاف الميزات المتقدمة**: جرب التكامل مع ماسحات المشاكل
4. **المساهمة**: فكر في المساهمة في [المشروع مفتوح المصدر](https://github.com/komodorio/helm-dashboard)
5. **انضم إلى المجتمع**: اتصل بمستخدمين آخرين على Slack

### موارد إضافية

- **المستودع الرسمي**: [https://github.com/komodorio/helm-dashboard](https://github.com/komodorio/helm-dashboard)
- **وثائق Helm**: [https://helm.sh/docs/](https://helm.sh/docs/)
- **وثائق Kubernetes**: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
- **نظرة عامة على الميزات**: [FEATURES.md](https://github.com/komodorio/helm-dashboard/blob/main/FEATURES.md)

يوضح Helm Dashboard أن الأدوات القوية لا يجب أن تكون معقدة. من خلال جعل Helm أكثر سهولة، فإنه يساعد الفرق على إدارة تطبيقات Kubernetes بثقة وكفاءة أكبر. سواء كنت مطورًا فرديًا أو جزءًا من فريق كبير، يمكن لـ Helm Dashboard تحسين سير عمل Kubernetes الخاص بك.

إدارة مخططات سعيدة! 🚀

