---
title: "VibeKit: الطبقة الأمنية المثلى لوكلاء البرمجة بالذكاء الاصطناعي - دليل شامل"
excerpt: "تعلم كيفية تشغيل Claude Code وGemini ووكلاء البرمجة الأخرى بالذكاء الاصطناعي في بيئات معزولة آمنة مع تحرير البيانات المدمج والمراقبة الشاملة باستخدام VibeKit."
seo_title: "دليل VibeKit: بيئة آمنة لوكلاء البرمجة بالذكاء الاصطناعي مع تحرير البيانات - Thaki Cloud"
seo_description: "دليل شامل لـ VibeKit - تشغيل وكلاء البرمجة بالذكاء الاصطناعي مثل Claude Code وGemini في حاويات Docker معزولة مع تحرير البيانات الحساسة التلقائي والمراقبة الفورية"
date: 2025-10-05
tags:
  - vibekit
  - ai-agents
  - coding-security
  - docker-sandbox
  - claude-code
  - gemini-cli
  - data-redaction
  - observability
author_profile: true
toc: true
toc_label: "فهرس المحتويات"
lang: ar
permalink: /ar/tutorials/vibekit-secure-ai-coding-agent-sandbox-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/vibekit-secure-ai-coding-agent-sandbox-tutorial-ar/"
categories:
  - tutorials
published: false
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

## مقدمة

مع تزايد قوة وكلاء البرمجة بالذكاء الاصطناعي مثل Claude Code وGemini CLI وCodex، أصبحت الحاجة إلى بيئات تنفيذ آمنة أكثر أهمية من أي وقت مضى. يظهر **VibeKit** كطبقة أمان أساسية تتيح لك الاستفادة من الإمكانات الكاملة لهذه الأدوات الذكية مع الحفاظ على الأمان والمراقبة الكاملة.

في هذا الدليل الشامل، سنستكشف كيف ينشئ VibeKit بيئات Docker معزولة، ويحرر البيانات الحساسة تلقائياً، ويوفر مراقبة فورية لجميع عمليات البرمجة بالذكاء الاصطناعي.

## ما هو VibeKit؟

VibeKit هو إطار عمل أمني مفتوح المصدر مصمم خصيصاً لوكلاء البرمجة بالذكاء الاصطناعي. يعمل كحاجز وقائي بين الكود المُولد بالذكاء الاصطناعي وبيئة التطوير المحلية، مما يضمن:

- عدم قدرة **الكود الضار** على التأثير على نظامك
- **اكتشاف وتحرير البيانات الحساسة** تلقائياً
- **تسجيل ومراقبة جميع العمليات** في الوقت الفعلي
- **التوافق الشامل** مع أدوات البرمجة الذكية الشائعة

### نظرة عامة على الميزات الرئيسية

🐳 **بيئة الحماية المحلية**
- تشغيل جميع الأكواد المُولدة بالذكاء الاصطناعي في حاويات Docker معزولة
- خطر صفر على إعداد التطوير المحلي
- عزل كامل لنظام الملفات

🔒 **تحرير البيانات المدمج**
- اكتشاف وإزالة مفاتيح API وكلمات المرور والأسرار تلقائياً
- قواعد تحرير قابلة للتكوين لأنماط البيانات الحساسة المخصصة
- فحص فوري لجميع إكمالات الكود

📊 **مراقبة شاملة**
- سجلات فورية وتتبع التنفيذ
- مقاييس الأداء ومراقبة استخدام الموارد
- مسار تدقيق كامل لجميع عمليات الذكاء الاصطناعي

🌐 **دعم الوكلاء الشامل**
- يعمل مع Claude Code وGemini CLI وGrok CLI وCodex CLI
- متوافق مع OpenCode ووكلاء الذكاء الاصطناعي المخصصة
- هيكل إضافات لتوسيع الدعم

💻 **التشغيل دون اتصال**
- لا يتطلب اعتماديات سحابية
- يعمل بالكامل على جهازك المحلي
- خصوصية كاملة وسيادة البيانات

**الشكل 1. معمارية بيئة الحماية الأمنية لـ VibeKit.**

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
<div class="d3-arch" data-arch-root id="ngagentsandboxtutorialar-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 753, "height": 538, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "AGENT", "x": 270, "y": 24, "w": 198, "h": 78, "title": ["AI Coding Agent: Claude", "Code / Gemini CLI / Grok", "CLI / Codex CLI"]}, {"id": "VK", "x": 277, "y": 180, "w": 184, "h": 46, "title": "VibeKit Security Layer"}, {"id": "BOX", "x": 523, "y": 304, "w": 198, "h": 62, "title": ["Isolated Docker Sandbox:", "filesystem isolation"]}, {"id": "RED", "x": 270, "y": 304, "w": 198, "h": 62, "title": ["Data Redaction: scan API", "keys and secrets"]}, {"id": "LOG", "x": 24, "y": 304, "w": 191, "h": 62, "title": ["Observability: logs and", "audit trail"]}, {"id": "SAFE", "x": 288, "y": 444, "w": 163, "h": 62, "title": ["Protected Local Dev", "Environment"]}], "edges": [{"src": "AGENT", "dst": "VK", "kind": "data", "line": [369, 102, 369, 180]}, {"src": "VK", "dst": "BOX", "kind": "data", "curve": [[461, 226], [622, 265], [622, 265], [622, 304]]}, {"src": "VK", "dst": "RED", "kind": "data", "line": [369, 226, 369, 304]}, {"src": "VK", "dst": "LOG", "kind": "data", "curve": [[277, 226], [120, 265], [120, 265], [120, 304]]}, {"src": "BOX", "dst": "SAFE", "kind": "data", "curve": [[622, 366], [622, 405], [622, 405], [451, 452]]}, {"src": "RED", "dst": "SAFE", "kind": "data", "line": [369, 366, 369, 444]}, {"src": "LOG", "dst": "SAFE", "kind": "data", "curve": [[120, 366], [120, 405], [120, 405], [288, 452]]}]});
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
      const container = document.getElementById('ngagentsandboxtutorialar-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ngagentsandboxtutorialar-1';
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

## المتطلبات المسبقة

قبل البدء، تأكد من تثبيت ما يلي على نظامك:

### متطلبات النظام

- **Node.js**: الإصدار 16 أو أحدث
- **Docker**: أحدث إصدار مستقر
- **npm**: يأتي مع تثبيت Node.js
- **نظام التشغيل**: macOS أو Linux أو Windows مع WSL2

### أوامر التحقق

```bash
# فحص إصدار Node.js
node --version

# فحص تثبيت Docker
docker --version

# فحص إصدار npm
npm --version
```

## دليل التثبيت

### الخطوة 1: تثبيت VibeKit CLI

أسهل طريقة للبدء مع VibeKit هي من خلال تثبيت CLI العام:

```bash
# تثبيت VibeKit CLI عالمياً
npm install -g vibekit

# التحقق من التثبيت
vibekit --version
```

### الخطوة 2: التحقق من إعداد Docker

يعتمد VibeKit على Docker لإنشاء بيئات الحماية المعزولة. دعنا نتأكد من تكوين Docker بشكل صحيح:

```bash
# اختبار وظائف Docker
docker run hello-world

# فحص صور Docker المتاحة
docker images

# التحقق من تشغيل Docker daemon
docker info
```

### الخطوة 3: التكوين الأولي

إنشاء ملف تكوين أساسي لـ VibeKit:

```bash
# إنشاء دليل تكوين VibeKit
mkdir -p ~/.vibekit

# توليد التكوين الافتراضي
vibekit init
```

هذا ينشئ ملف تكوين `.vibekit.json` مع الإعدادات الافتراضية:

```json
{
  "sandbox": {
    "timeout": 30000,
    "memory_limit": "512m",
    "cpu_limit": "1.0"
  },
  "redaction": {
    "enabled": true,
    "patterns": [
      "api_key",
      "password",
      "secret",
      "token"
    ]
  },
  "logging": {
    "level": "info",
    "output": "console"
  }
}
```

## دليل الاستخدام الأساسي

### تشغيل Claude Code مع VibeKit

حالة الاستخدام الأكثر شيوعاً هي تشغيل Claude Code من خلال طبقة الأمان في VibeKit:

```bash
# تشغيل Claude Code مع حماية VibeKit
vibekit claude

# التشغيل مع تسجيل مفصل
vibekit claude --verbose

# التشغيل مع مهلة زمنية مخصصة
vibekit claude --timeout 60000
```

### مثال: تنفيذ سكريبت Python آمن

دعنا نتابع مثالاً عملياً لتشغيل كود Python مُولد بالذكاء الاصطناعي بأمان:

1. **بدء VibeKit مع Claude Code:**
```bash
vibekit claude --language python
```

2. **طلب توليد كود من الذكاء الاصطناعي:**
```
أنشئ سكريبت Python يحلل بيانات CSV وينشئ تصورات بيانية
```

3. **VibeKit يقوم تلقائياً بـ:**
   - استقبال الكود المُولد بالذكاء الاصطناعي
   - فحص أنماط البيانات الحساسة
   - إنشاء حاوية Docker معزولة
   - تنفيذ الكود بأمان
   - إرجاع النتائج مع سجلات الأمان

### العمل مع وكلاء ذكاء اصطناعي مختلفين

يدعم VibeKit عدة وكلاء برمجة بالذكاء الاصطناعي. إليك كيفية استخدامها:

```bash
# تكامل Gemini CLI
vibekit gemini

# تكامل Codex CLI  
vibekit codex

# تكامل وكيل مخصص
vibekit custom --agent-command "your-ai-agent"
```

## التكوين المتقدم

### أنماط التحرير المخصصة

يمكنك تعريف أنماط مخصصة لاكتشاف البيانات الحساسة:

```json
{
  "redaction": {
    "enabled": true,
    "patterns": [
      {
        "name": "custom_api_key",
        "regex": "sk-[a-zA-Z0-9]{32}",
        "replacement": "[مفتاح_API_محرر]"
      },
      {
        "name": "database_url",
        "regex": "postgresql://[^\\s]+",
        "replacement": "[رابط_قاعدة_البيانات_محرر]"
      }
    ]
  }
}
```

### حدود موارد بيئة الحماية

تكوين حدود الموارد للأمان المعزز:

```json
{
  "sandbox": {
    "memory_limit": "1g",
    "cpu_limit": "2.0",
    "disk_limit": "500m",
    "network_access": false,
    "timeout": 45000
  }
}
```

### إعداد التسجيل والمراقبة

تمكين التسجيل الشامل لمسارات التدقيق:

```json
{
  "logging": {
    "level": "debug",
    "output": "file",
    "file_path": "~/.vibekit/logs/vibekit.log",
    "max_file_size": "10mb",
    "max_files": 5
  }
}
```

## تكامل SDK

للمطورين الذين يبنون تطبيقات مع VibeKit، يوفر SDK وصولاً برمجياً:

### التثبيت

```bash
npm install @vibe-kit/sdk
```

### الاستخدام الأساسي لـ SDK

```javascript
import { VibeKit } from '@vibe-kit/sdk';

const vibekit = new VibeKit({
  sandbox: {
    timeout: 30000,
    memory_limit: '512m'
  },
  redaction: {
    enabled: true
  }
});

// تنفيذ كود في بيئة الحماية
const result = await vibekit.execute({
  code: 'print("مرحباً، عالم آمن!")',
  language: 'python'
});

console.log('نتيجة التنفيذ:', result.output);
console.log('سجلات الأمان:', result.security_logs);
```

### ميزات SDK المتقدمة

```javascript
// قواعد تحرير مخصصة
vibekit.addRedactionRule({
  name: 'credit_card',
  pattern: /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g,
  replacement: '[بطاقة_ائتمان_محررة]'
});

// المراقبة الفورية
vibekit.on('execution_start', (event) => {
  console.log('بدء تنفيذ الكود:', event.timestamp);
});

vibekit.on('security_alert', (alert) => {
  console.log('تنبيه أمني:', alert.message);
});
```

## أفضل الممارسات الأمنية

### 1. التحديثات المنتظمة

حافظ على تحديث VibeKit لتلقي أحدث تصحيحات الأمان:

```bash
# تحديث VibeKit CLI
npm update -g vibekit

# تحديث SDK
npm update @vibe-kit/sdk
```

### 2. تقوية التكوين

استخدم إعدادات بيئة حماية مقيدة للأمان الأقصى:

```json
{
  "sandbox": {
    "network_access": false,
    "file_system_access": "read-only",
    "environment_isolation": true,
    "resource_monitoring": true
  }
}
```

### 3. إدارة سجلات التدقيق

تنفيذ دوران السجلات والمراقبة المناسبة:

```bash
# إعداد دوران السجلات
vibekit config set logging.rotation.enabled true
vibekit config set logging.rotation.max_size "50mb"
vibekit config set logging.rotation.max_files 10
```

### 4. سياسات الأمان المخصصة

تعريف سياسات أمان خاصة بالمؤسسة:

```json
{
  "security_policies": {
    "allowed_languages": ["python", "javascript", "bash"],
    "blocked_imports": ["os", "subprocess", "socket"],
    "max_execution_time": 30000,
    "require_approval": ["file_operations", "network_requests"]
  }
}
```

## استكشاف الأخطاء وإصلاحها

### مشاكل اتصال Docker

```bash
# فحص حالة Docker daemon
sudo systemctl status docker

# إعادة تشغيل خدمة Docker
sudo systemctl restart docker

# اختبار اتصال Docker
docker run --rm hello-world
```

### مشاكل الصلاحيات

```bash
# إضافة المستخدم إلى مجموعة docker (Linux)
sudo usermod -aG docker $USER

# إعادة تحميل عضوية المجموعة
newgrp docker
```

### مشاكل الذاكرة والموارد

```bash
# فحص موارد النظام
docker system df

# تنظيف الحاويات غير المستخدمة
docker system prune

# مراقبة استخدام الموارد
docker stats
```

### التحقق من صحة التكوين

```bash
# التحقق من تكوين VibeKit
vibekit config validate

# إعادة تعيين إلى التكوين الافتراضي
vibekit config reset

# عرض التكوين الحالي
vibekit config show
```

## تحسين الأداء

### تحسين صور الحاويات

استخدم صور أساسية خفيفة لأداء أفضل:

```json
{
  "sandbox": {
    "base_images": {
      "python": "python:3.11-alpine",
      "node": "node:18-alpine",
      "general": "ubuntu:22.04"
    }
  }
}
```

### ضبط تخصيص الموارد

تحسين تخصيص الموارد بناءً على حالة الاستخدام:

```json
{
  "performance": {
    "parallel_executions": 3,
    "container_reuse": true,
    "image_caching": true,
    "memory_optimization": true
  }
}
```

## المراقبة والمراقبة

### لوحة المراقبة الفورية

يوفر VibeKit واجهة مراقبة قائمة على الويب:

```bash
# بدء لوحة المراقبة
vibekit monitor --port 8080

# الوصول للوحة على http://localhost:8080
```

### جمع المقاييس

تمكين جمع المقاييس الشامل:

```json
{
  "metrics": {
    "enabled": true,
    "collection_interval": 5000,
    "export_format": "prometheus",
    "custom_metrics": [
      "execution_time",
      "memory_usage",
      "security_events"
    ]
  }
}
```

### التكامل مع المراقبة الخارجية

```javascript
// تصدير المقاييس إلى أنظمة خارجية
const metrics = await vibekit.getMetrics();

// إرسال إلى خدمة المراقبة
await monitoringService.send({
  timestamp: Date.now(),
  metrics: metrics,
  tags: ['vibekit', 'ai-agents']
});
```

## حالات الاستخدام والأمثلة

### 1. أتمتة مراجعة الكود الآمنة

```bash
# مراجعة طلبات السحب بمساعدة الذكاء الاصطناعي
vibekit claude --mode review --input "path/to/pr.diff"
```

### 2. تحليل التبعيات الآمن

```bash
# تحليل package.json للمشاكل الأمنية
vibekit gemini --task security-audit --file package.json
```

### 3. توليد الاختبارات التلقائي

```bash
# توليد اختبارات الوحدة بأمان
vibekit codex --generate tests --source-dir src/
```

### 4. توليد الوثائق

```bash
# إنشاء وثائق من الكود
vibekit claude --task documentation --input-dir src/
```

## المجتمع والدعم

### الحصول على المساعدة

- **مستودع GitHub**: [https://github.com/superagent-ai/vibekit](https://github.com/superagent-ai/vibekit)
- **الوثائق**: الوثائق الرسمية في vibekit.sh
- **مجتمع Discord**: انضم للنقاش
- **متتبع المشاكل**: الإبلاغ عن الأخطاء وطلبات الميزات

### المساهمة

VibeKit مفتوح المصدر ويرحب بالمساهمات:

```bash
# استنساخ المستودع
git clone https://github.com/superagent-ai/vibekit.git

# تثبيت تبعيات التطوير
cd vibekit
npm install

# تشغيل الاختبارات
npm test

# تقديم طلب سحب
```

## الخلاصة

يمثل VibeKit تحولاً جذرياً في كيفية تعاملنا مع أمان وكلاء البرمجة بالذكاء الاصطناعي. من خلال توفير بيئات تنفيذ معزولة وتحرير البيانات التلقائي والمراقبة الشاملة، يمكّن المطورين من الاستفادة من القوة الكاملة لأدوات البرمجة الذكية دون التنازل عن الأمان.

النقاط الرئيسية من هذا الدليل:

1. **الأمان أولاً**: قم دائماً بتشغيل الكود المُولد بالذكاء الاصطناعي في بيئات معزولة
2. **حماية البيانات**: نفذ التحرير التلقائي للمعلومات الحساسة
3. **المراقبة**: حافظ على سجلات ومقاييس شاملة لجميع عمليات الذكاء الاصطناعي
4. **أفضل الممارسات**: اتبع إرشادات الأمان وحافظ على تحديث الأنظمة
5. **المجتمع**: استفد من مجتمع المصدر المفتوح للدعم والمساهمات

مع استمرار تطور وكلاء البرمجة بالذكاء الاصطناعي، يضمن VibeKit أن الأمان والمراقبة يتطوران معها، مما يوفر أساساً قوياً لمستقبل التطوير بمساعدة الذكاء الاصطناعي.

## الخطوات التالية

1. **ثبت VibeKit** وجرب الأمثلة الأساسية
2. **كوّن قواعد التحرير المخصصة** لحالة الاستخدام الخاصة بك
3. **ادمج SDK** في سير عمل التطوير الحالي
4. **أعد المراقبة** ولوحات المراقبة
5. **انضم للمجتمع** وساهم في المشروع

ابدأ رحلة البرمجة الآمنة بالذكاء الاصطناعي مع VibeKit اليوم!
