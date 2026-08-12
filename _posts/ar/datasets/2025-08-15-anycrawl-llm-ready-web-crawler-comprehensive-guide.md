---
title: "AnyCrawl: الدليل الشامل لزاحف الويب الجاهز للنماذج اللغوية الكبيرة - معيار جديد لجمع بيانات الذكاء الاصطناعي"
excerpt: "أتقن كيفية تحويل مواقع الويب إلى بيانات جاهزة للنماذج اللغوية الكبيرة وجمع نتائج Google/Bing SERP بكفاءة باستخدام AnyCrawl المبني على Node.js/TypeScript."
seo_title: "دليل AnyCrawl الشامل لزاحف الويب بالذكاء الاصطناعي - أداة جمع بيانات AI - Thaki Cloud"
seo_description: "كيفية تنفيذ استخراج الويب وزحف SERP وجمع البيانات متعدد الخيوط باستخدام AnyCrawl من Any4AI. دليل تفصيلي من تثبيت Docker إلى الاستخدام الفعلي."
date: 2025-08-15
last_modified_at: 2025-08-15
tags:
  - anycrawl
  - web-crawler
  - llm-data
  - serp-scraping
  - any4ai
  - node-js
  - typescript
  - docker
  - data-collection
  - ai-tools
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/datasets/anycrawl-llm-ready-web-crawler-comprehensive-guide/"
lang: ar
reading_time: true
categories:
  - datasets
---

⏱️ **وقت القراءة المقدر**: 15 دقائق

![نظرة عامة على خط جمع البيانات الملائمة للنماذج اللغوية الكبيرة في AnyCrawl]({{ '/assets/images/anycrawl-llm-ready-web-crawler-comprehensive-guide-hero.webp' | relative_url }})

## نظرة عامة

[AnyCrawl](https://github.com/any4ai/AnyCrawl) هو **زاحف ويب عالي الأداء** طوّرته شركة Any4AI، يحوّل مواقع الويب إلى بيانات محسّنة للنماذج اللغوية الكبيرة (LLMs) ويستخرج صفحات نتائج محركات البحث (SERP) المنظّمة من Google و Bing و Baidu وغيرها.

يحظى AnyCrawl بـ **1.8 ألف نجمة على GitHub** ومجتمع نشط، ويرسي **معياراً جديداً** لجمع البيانات في تطبيقات الذكاء الاصطناعي.

### القيمة الجوهرية

- **تحسين للنماذج اللغوية الكبيرة**: تحويل بيانات الويب إلى صيغة يسهل على النماذج اللغوية معالجتها
- **دعم متعدد المحركات**: Cheerio و Playwright و Puppeteer وغيرها
- **تخصص في SERP**: دعم Google و Bing و Baidu وغيرها من محركات البحث الرئيسية
- **معالجة عالية الأداء**: بنية متعددة الخيوط والعمليات
- **المعالجة الدفعية**: إدارة فعّالة لمهام الزحف الواسعة النطاق

## ما هو AnyCrawl؟

### منصة جمع بيانات في عصر الذكاء الاصطناعي

يتجاوز AnyCrawl كونه مجرد زاحف ويب؛ إذ هو **منصة جمع بيانات مدعومة بالذكاء الاصطناعي**:

```
محتوى الويب -> معالجة AnyCrawl -> بيانات جاهزة للنماذج اللغوية -> تدريب/استنتاج نموذج AI
```

يوضح المخطط أدناه سير العمل الكامل: تمر عناوين URL واستعلامات البحث عبر محركات الاستخراج ومحركات SERP، ثم تُعالج بواسطة عمّال متعددي الخيوط، وأخيراً تُطبّع إلى بيانات ملائمة للنماذج اللغوية الكبيرة:

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
<div class="d3-arch" data-arch-root id="rawlercomprehensiveguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 493, "height": 770, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 151, "y": 24, "w": 191, "h": 46, "title": "URLs and search queries"}, {"id": "API", "x": 186, "y": 148, "w": 120, "h": 46, "title": "AnyCrawl API"}, {"id": "SCRAPE", "x": 277, "y": 272, "w": 184, "h": 62, "title": ["Scrape engines Cheerio", "Playwright Puppeteer"]}, {"id": "SERP", "x": 24, "y": 272, "w": 198, "h": 62, "title": ["SERP engines Google Bing", "Baidu"]}, {"id": "WORK", "x": 140, "y": 412, "w": 212, "h": 62, "title": ["Multithreaded multiprocess", "workers"]}, {"id": "NORM", "x": 144, "y": 552, "w": 205, "h": 62, "title": ["Normalize to LLM friendly", "Markdown and JSON"]}, {"id": "AI", "x": 140, "y": 692, "w": 212, "h": 46, "title": "LLM training and inference"}], "edges": [{"src": "U", "dst": "API", "kind": "data", "line": [246, 70, 246, 148]}, {"src": "API", "dst": "SCRAPE", "kind": "data", "curve": [[292, 194], [369, 233], [369, 233], [369, 272]]}, {"src": "API", "dst": "SERP", "kind": "data", "curve": [[200, 194], [123, 233], [123, 233], [123, 272]]}, {"src": "SCRAPE", "dst": "WORK", "kind": "data", "curve": [[369, 334], [369, 373], [369, 373], [300, 412]]}, {"src": "SERP", "dst": "WORK", "kind": "data", "curve": [[123, 334], [123, 373], [123, 373], [192, 412]]}, {"src": "WORK", "dst": "NORM", "kind": "data", "line": [246, 474, 246, 552]}, {"src": "NORM", "dst": "AI", "kind": "data", "line": [246, 614, 246, 692]}]});
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
      const container = document.getElementById('rawlercomprehensiveguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rawlercomprehensiveguide-1';
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

### بنية معمارية حديثة

**مبنية على Node.js + TypeScript**:
- أداء ممتاز عبر المعالجة غير المتزامنة
- تشغيل مستقر بفضل الأنواع الصارمة
- استفادة من نظام بيئي غني

**نشر معتمد على الحاويات**:
- دعم Docker وDocker Compose
- بنية الخدمات الصغيرة
- قابلية التوسع وسهولة الصيانة

### أربع ميزات جوهرية

#### 1. **زحف SERP** (صفحات نتائج محركات البحث)
```bash
# جمع نتائج بحث Google
curl -X POST http://localhost:8080/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "artificial intelligence trends 2025",
    "limit": 20,
    "engine": "google"
  }'
```

#### 2. **استخراج الويب** (استخراج صفحة واحدة)
```bash
# استخراج محتوى صفحة واحدة
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com/article",
    "engine": "playwright"
  }'
```

#### 3. **زحف الموقع** (زحف الموقع بالكامل)
- اجتياز الروابط بذكاء
- إزالة المحتوى المكرر
- استخراج بيانات منظّمة

#### 4. **المعالجة الدفعية** (عمليات الدُفعات)
- معالجة قوائم URL الضخمة
- تحسين المهام المتوازية
- مراقبة التقدم

## متطلبات النظام

### البيئة الأساسية

```bash
# التحقق من إصدار Docker (يُنصح بـ 20.10 أو أحدث)
docker --version

# التحقق من إصدار Docker Compose (يُنصح بـ 1.29 أو أحدث)
docker-compose --version

# التحقق من Git
git --version

# الذاكرة: 4 GB كحد أدنى، 8 GB أو أكثر موصى به
# القرص: 10 GB مساحة حرة على الأقل
```

### التشغيل القائم على Docker

**التثبيت على macOS**:
```bash
# تثبيت Docker عبر Homebrew
brew install --cask docker

# إتمام الإعداد بعد تشغيل Docker Desktop
```

**التثبيت على Linux**:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose

# CentOS/RHEL
sudo yum install docker docker-compose
```

## التثبيت والإعداد الأولي

### الخطوة 1: استنساخ المستودع

```bash
# استنساخ مستودع AnyCrawl
git clone https://github.com/any4ai/AnyCrawl.git
cd AnyCrawl

# التحقق من الفرع (استخدام الفرع main)
git branch -a
```

### الخطوة 2: تهيئة البيئة

#### ضبط متغيرات البيئة الأساسية
```bash
# إنشاء ملف .env
cp .env.example .env

# مراجعة بنود الإعداد الرئيسية
cat .env
```

#### متغيرات البيئة الرئيسية

| المتغير | القيمة الافتراضية | الوصف |
|--------|--------|------|
| `NODE_ENV` | production | إعداد بيئة التشغيل |
| `ANYCRAWL_API_PORT` | 8080 | منفذ خادم API |
| `ANYCRAWL_HEADLESS` | true | وضع المتصفح بلا واجهة |
| `ANYCRAWL_AVAILABLE_ENGINES` | cheerio,playwright,puppeteer | المحركات المتاحة |
| `ANYCRAWL_REDIS_URL` | redis://redis:6379 | عنوان اتصال Redis |

### الخطوة 3: تشغيل حاويات Docker

```bash
# بناء الحاويات وتشغيلها
docker-compose up --build -d

# التحقق من حالة الخدمة
docker-compose ps

# عرض السجلات
docker-compose logs -f
```

### الخطوة 4: التحقق من التثبيت

```bash
# فحص صحة خادم API
curl http://localhost:8080/health

# الوصول إلى وثائق API (المتصفح)
open http://localhost:8080/docs
```

## دليل مفصّل للميزات الجوهرية

### استخراج الويب

#### محرك Cheerio (HTML الثابت)
```bash
# أسرع تحليل لـ HTML الثابت
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://news.ycombinator.com",
    "engine": "cheerio"
  }'
```

**الخصائص**:
- أعلى سرعة
- استهلاك منخفض للذاكرة
- لا يدعم JavaScript

#### محرك Playwright (عرض JavaScript)
```bash
# محرك متصفح حديث
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com/spa-app",
    "engine": "playwright"
  }'
```

**الخصائص**:
- يدعم جميع المتصفحات (Chrome وFirefox وSafari)
- عرض كامل لـ JavaScript
- يدعم أحدث معايير الويب

#### محرك Puppeteer (مخصص لـ Chrome)
```bash
# عرض قائم على Chrome
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com/react-app",
    "engine": "puppeteer"
  }'
```

**الخصائص**:
- مخصص لـ Chrome/Chromium
- معالجة موثوقة لـ JavaScript
- إمكانيات تصحيح أخطاء غنية

### زحف SERP (نتائج البحث)

#### جمع نتائج بحث Google
```bash
# بحث أساسي
curl -X POST http://localhost:8080/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "machine learning tutorials",
    "engine": "google",
    "pages": 2,
    "lang": "en"
  }'
```

#### دعم البحث متعدد اللغات
```bash
# نتائج البحث بالعربية
curl -X POST http://localhost:8080/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "دروس الذكاء الاصطناعي",
    "engine": "google",
    "lang": "ar"
  }'
```

#### معاملات البحث المتقدمة

| المعامل | النوع | الوصف | الافتراضي |
|----------|------|------|--------|
| `query` | string | استعلام البحث | مطلوب |
| `engine` | string | محرك البحث (google) | google |
| `pages` | number | عدد الصفحات للجمع | 1 |
| `lang` | string | رمز اللغة | en-US |
| `limit` | number | حد النتائج | 10 |

### الوكلاء والإعدادات المتقدمة

#### استخدام وكيل HTTP
```bash
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com",
    "engine": "playwright",
    "proxy": "http://proxy.example.com:8080"
  }'
```

#### استخدام وكيل SOCKS
```bash
# إعداد وكيل SOCKS5
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com",
    "proxy": "socks5://proxy.example.com:1080"
  }'
```

## أمثلة تطبيقية عملية

### المثال 1: أتمتة جمع بيانات الأخبار

```bash
#!/bin/bash
# news-collector.sh

API_URL="http://localhost:8080"
OUTPUT_DIR="./news-data"

mkdir -p "$OUTPUT_DIR"

# قائمة المواقع الإخبارية الرئيسية
NEWS_SITES=(
    "https://news.ycombinator.com"
    "https://techcrunch.com"
    "https://www.wired.com"
)

for site in "${NEWS_SITES[@]}"; do
    echo "بدء الزحف: $site"
    
    # جمع البيانات لكل موقع
    curl -X POST "$API_URL/v1/scrape" \
      -H 'Content-Type: application/json' \
      -d "{
        \"url\": \"$site\",
        \"engine\": \"playwright\"
      }" > "$OUTPUT_DIR/$(basename $site).json"
    
    echo "اكتمل: $site"
    sleep 2  # التحكم في معدل الطلبات
done
```

### المثال 2: البحث عن الأوراق الأكاديمية وجمعها

```python
# academic_research.py
import requests
import json
import time

class AcademicCrawler:
    def __init__(self, base_url="http://localhost:8080"):
        self.base_url = base_url
        
    def search_papers(self, keywords, pages=3):
        """البحث عن الأوراق الأكاديمية"""
        results = []
        
        for keyword in keywords:
            response = requests.post(
                f"{self.base_url}/v1/search",
                json={
                    "query": f"{keyword} site:arxiv.org OR site:scholar.google.com",
                    "pages": pages,
                    "limit": 20
                }
            )
            
            if response.status_code == 200:
                data = response.json()
                results.extend(data.get('data', {}).get('results', []))
                
            time.sleep(1)  # احترام حدود معدل API
            
        return results
    
    def extract_paper_content(self, url):
        """استخراج محتوى صفحة الورقة"""
        response = requests.post(
            f"{self.base_url}/v1/scrape",
            json={
                "url": url,
                "engine": "playwright"
            }
        )
        
        if response.status_code == 200:
            return response.json()
        return None

# مثال على الاستخدام
crawler = AcademicCrawler()

# البحث عن أوراق متعلقة بالذكاء الاصطناعي
keywords = [
    "transformer neural network",
    "large language model",
    "computer vision 2025"
]

papers = crawler.search_papers(keywords)
print(f"الأوراق المجمّعة: {len(papers)}")

# استخراج تفاصيل الورقة الأولى
if papers:
    first_paper = papers[0]
    content = crawler.extract_paper_content(first_paper['url'])
    print(f"عنوان الورقة: {first_paper['title']}")
```

### المثال 3: مراقبة أسعار التجارة الإلكترونية

```javascript
// price-monitor.js
const axios = require('axios');

class PriceMonitor {
    constructor(baseUrl = 'http://localhost:8080') {
        this.baseUrl = baseUrl;
    }
    
    async scrapeProduct(url) {
        try {
            const response = await axios.post(`${this.baseUrl}/v1/scrape`, {
                url: url,
                engine: 'playwright'
            });
            
            return response.data;
        } catch (error) {
            console.error('خطأ في الاستخراج:', error.message);
            return null;
        }
    }
    
    async monitorPrices(products) {
        const results = [];
        
        for (const product of products) {
            console.log(`مراقبة: ${product.name}`);
            
            const data = await this.scrapeProduct(product.url);
            
            if (data) {
                results.push({
                    name: product.name,
                    url: product.url,
                    timestamp: new Date().toISOString(),
                    data: data
                });
            }
            
            // التحكم في معدل الطلبات
            await new Promise(resolve => setTimeout(resolve, 2000));
        }
        
        return results;
    }
}

// مثال على الاستخدام
const monitor = new PriceMonitor();

const products = [
    {
        name: 'MacBook Pro',
        url: 'https://www.apple.com/macbook-pro/'
    },
    {
        name: 'iPhone 15',
        url: 'https://www.apple.com/iphone-15/'
    }
];

monitor.monitorPrices(products)
    .then(results => {
        console.log('اكتملت مراقبة الأسعار');
        console.log(JSON.stringify(results, null, 2));
    })
    .catch(error => {
        console.error('خطأ في المراقبة:', error);
    });
```

## الاختبار على macOS

فيما يلي سكريبت لإعداد AnyCrawl واختباره على macOS.

### الإعداد التلقائي لبيئة الاختبار

```bash
#!/bin/bash
# test-anycrawl-setup.sh
echo "إعداد بيئة اختبار AnyCrawl"

# التحقق من Docker
if command -v docker &> /dev/null; then
    echo "تم التحقق من Docker"
else
    echo "Docker مطلوب: brew install --cask docker"
    exit 1
fi

# إنشاء دليل الاختبار
TEST_DIR="$HOME/anycrawl-test-$(date +%Y%m%d)"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"

# استنساخ المستودع
git clone https://github.com/any4ai/AnyCrawl.git
cd AnyCrawl

# تهيئة البيئة
cp .env.example .env

# تشغيل Docker
docker-compose up --build -d
sleep 30

# فحص الصحة
if curl -s http://localhost:8080/health | grep -q "ok"; then
    echo "AnyCrawl جاهز!"
    echo "وثائق API: http://localhost:8080/docs"
else
    echo "فشل في تشغيل الخدمة"
fi
```

## الخلاصة

AnyCrawl منصة قادرة على تلبية **متطلبات جمع البيانات في عصر الذكاء الاصطناعي**. من خلال تحويل البيانات بصورة ملائمة للنماذج اللغوية الكبيرة، والمعالجة عالية الأداء متعددة الخيوط، ودعم محركات البحث المتعددة، تتيح هذه المنصة **بناء مجموعات بيانات عالية الجودة** الضرورية لتطوير تطبيقات الذكاء الاصطناعي.

### أبرز المزايا

1. **تحسين للنماذج اللغوية**: توفير بيانات منظّمة يسهل على نماذج AI معالجتها
2. **قابلية التوسع**: نشر قائم على Docker بسيط التوسعة
3. **تعدد الاستخدامات**: دعم شامل من استخراج الويب إلى زحف SERP
4. **الأداء**: معالجة البيانات الضخمة عبر تعدد الخيوط

### حالات الاستخدام المحتملة

- **أنظمة RAG**: بناء قواعد معرفة للتوليد المعزّز بالاسترجاع
- **بيانات تدريب AI**: جمع بيانات تدريب عالية الجودة عبر نطاقات متنوعة
- **المراقبة الفورية**: رصد تغييرات الويب وتحليل الاتجاهات
- **خطوط أنابيب آلية**: جمع البيانات الآلي في بيئات CI/CD

ابدأ تجربة جمع البيانات المدعوم بالذكاء الاصطناعي مع [AnyCrawl](https://github.com/any4ai/AnyCrawl) من Any4AI.

---

**مقالات ذات صلة:**
- [الدليل الشامل لاستخراج الويب](https://thakicloud.com/tech-blog/tutorials/web-scraping-guide/)
- [منهجيات معالجة بيانات النماذج اللغوية الكبيرة](https://thakicloud.com/tech-blog/datasets/llm-data-preprocessing/)
- [بناء بنية تحتية لـ AI قائمة على Docker](https://thakicloud.com/tech-blog/tutorials/docker-ai-infrastructure/)
