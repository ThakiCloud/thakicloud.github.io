---
title: "LangGPT: إتقان إطار عمل هندسة المحفزات المنظمة لتفاعلات أفضل مع الذكاء الاصطناعي"
excerpt: "تعلم كيفية إنشاء محفزات عالية الجودة وقابلة لإعادة الاستخدام باستخدام إطار عمل LangGPT المنظم. حول هندسة المحفزات الفوضوية إلى منهجية منظمة مع القوالب والأمثلة وأفضل الممارسات."
seo_title: "دليل LangGPT: إطار عمل هندسة المحفزات المنظمة - Thaki Cloud"
seo_description: "دليل شامل لـ LangGPT يغطي تصميم المحفزات المنظمة والقوالب القائمة على الأدوار وتقنيات هندسة المحفزات المتقدمة لـ ChatGPT وClaude ونماذج اللغة الكبيرة الأخرى."
date: 2025-10-12
tags:
  - LangGPT
  - هندسة-المحفزات
  - الذكاء-الاصطناعي
  - ChatGPT
  - المحفزات-المنظمة
  - نماذج-اللغة-الكبيرة
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/langgpt-structured-prompt-framework-tutorial-ar/"
lang: ar
permalink: /ar/tutorials/langgpt-structured-prompt-framework-tutorial/
categories:
  - tutorials
---

⏱️ **وقت القراءة المتوقع**: 12 دقيقة

<!-- evolve-diagram -->
*رسم تخطيطي توضيحي*

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
<div class="d3-arch" data-arch-root id="romptframeworktutorialar-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 495, "height": 586, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Role", "x": 24, "y": 266, "w": 156, "h": 46, "title": "# Role: agent name"}, {"id": "Profile", "x": 258, "y": 492, "w": 205, "h": 62, "title": ["## Profile", "author, version, language"]}, {"id": "Skills", "x": 286, "y": 375, "w": 149, "h": 62, "title": ["## Skills", "capabilities list"]}, {"id": "Rules", "x": 262, "y": 258, "w": 198, "h": 62, "title": ["## Rules", "constraints + guidelines"]}, {"id": "Workflow", "x": 283, "y": 141, "w": 156, "h": 62, "title": ["## Workflow", "ordered steps 1..n"]}, {"id": "Init", "x": 265, "y": 24, "w": 191, "h": 62, "title": ["## Initialization", "greeting + instructions"]}], "edges": [{"src": "Role", "dst": "Profile", "kind": "data", "curve": [[114, 312], [219, 523], [219, 523], [258, 523]]}, {"src": "Role", "dst": "Skills", "kind": "data", "curve": [[125, 312], [219, 406], [219, 406], [286, 406]]}, {"src": "Role", "dst": "Rules", "kind": "data", "line": [180, 289, 262, 289]}, {"src": "Role", "dst": "Workflow", "kind": "data", "curve": [[125, 266], [219, 172], [219, 172], [283, 172]]}, {"src": "Role", "dst": "Init", "kind": "data", "curve": [[114, 266], [219, 55], [219, 55], [265, 55]]}]});
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
      const container = document.getElementById('romptframeworktutorialar-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'romptframeworktutorialar-1';
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

## مقدمة: لماذا تهم المحفزات المنظمة

غالباً ما تبدو هندسة المحفزات التقليدية وكأنها رمي السهام في الظلام. تقوم بصياغة محفز، واختباره، وتعديله، والتكرار حتى يعمل شيء ما. **يغير LangGPT هذه العملية الفوضوية إلى منهجية منظمة تنتج نتائج متسقة وعالية الجودة**.

[LangGPT](https://github.com/langgptai/LangGPT) هو إطار عمل منظم وقابل لإعادة الاستخدام لتصميم المحفزات يمكّن أي شخص من إنشاء محفزات احترافية لنماذج اللغة الكبيرة. فكر فيه كـ **"لغة برمجة للمحفزات"**: منظمة وقائمة على القوالب وقابلة للتوسع بلا حدود.

### ما ستتعلمه

بنهاية هذا الدليل، ستكون قادراً على:
- فهم المبادئ الأساسية وهيكل LangGPT
- إنشاء محفزات قائمة على الأدوار باستخدام قوالب LangGPT
- تطبيق تقنيات هندسة المحفزات المتقدمة
- بناء مكتبات محفزات قابلة لإعادة الاستخدام لمشاريعك
- تحسين تفاعلات الذكاء الاصطناعي عبر حالات استخدام مختلفة

## فهم إطار عمل LangGPT

### الفلسفة الأساسية

يحول LangGPT هندسة المحفزات من فن إلى علم من خلال تقديم:

1. **القوالب المنظمة**: تنسيق متسق لجميع المحفزات
2. **التصميم القائم على الأدوار**: تعريف واضح للشخصية والقدرات
3. **المكونات المعيارية**: كتل بناء قابلة لإعادة الاستخدام
4. **المنهجية المنظمة**: عملية قابلة للتكرار لإنشاء المحفزات

### هيكل LangGPT

يتبع كل محفز LangGPT هذا الهيكل الهرمي:

```
# Role: [اسم الدور]

## Profile
- Author: [المؤلف]
- Version: [رقم الإصدار]
- Language: [اللغة المستهدفة]
- Description: [وصف موجز للدور]

## Skills
- [المهارة 1]: [الوصف]
- [المهارة 2]: [الوصف]
- [المهارة 3]: [الوصف]

## Rules
- [القاعدة 1]: [قيد أو إرشاد]
- [القاعدة 2]: [قيد أو إرشاد]
- [القاعدة 3]: [قيد أو إرشاد]

## Workflow
1. [الخطوة 1]: [وصف الإجراء]
2. [الخطوة 2]: [وصف الإجراء]
3. [الخطوة 3]: [وصف الإجراء]

## Initialization
[التحية الأولية والتعليمات]
```

## مثال عملي: بناء مساعد مراجعة الكود

لننشئ محفز LangGPT عملي لمساعد مراجعة الكود:

```markdown
# Role: مراجع كود أول

## Profile
- Author: Thaki Cloud
- Version: 1.0
- Language: العربية
- Description: مراجع كود خبير متخصص في أفضل الممارسات والأمان وتحسين الأداء

## Skills
- **تحليل الكود**: فهم عميق للغات البرمجة والأطر المتعددة
- **تقييم الأمان**: تحديد الثغرات وأنماط الأمان المضادة
- **تحسين الأداء**: اكتشاف الاختناقات واقتراح التحسينات
- **أفضل الممارسات**: تطبيق معايير البرمجة ومبادئ الهندسة المعمارية
- **التوثيق**: تقديم ملاحظات واضحة وقابلة للتنفيذ مع الأمثلة

## Rules
- قدم دائماً ملاحظات بناءة مع اقتراحات محددة
- أدرج أمثلة الكود عند اقتراح التحسينات
- أعط الأولوية لمخاوف الأمان والأداء
- اشرح المنطق وراء كل توصية
- حافظ على نبرة مهنية وتعليمية

## Workflow
1. **التحليل الأولي**: فحص هيكل الكود والهندسة المعمارية العامة
2. **مراجعة الأمان**: فحص الثغرات الشائعة ومشاكل الأمان
3. **تقييم الأداء**: تحديد اختناقات الأداء المحتملة
4. **فحص أفضل الممارسات**: التحقق من الالتزام بمعايير البرمجة
5. **مراجعة التوثيق**: تقييم قابلية قراءة الكود وجودة التوثيق
6. **تقرير الملخص**: تقديم توصيات مرتبة حسب الأولوية مع الأمثلة

## Initialization
مرحباً! أنا مراجع الكود الأول الخاص بك. يرجى مشاركة الكود الذي تريد مراجعته، وسأقدم ملاحظات شاملة تغطي الأمان والأداء وأفضل الممارسات وجودة الكود العامة. سأتضمن أمثلة محددة واقتراحات قابلة للتنفيذ للتحسين.
```

### اختبار مساعد مراجعة الكود

لنختبر هذا المحفز مع مقطع كود نموذجي:

**الإدخال:**
```python
def get_user_data(user_id):
    query = f"SELECT * FROM users WHERE id = {user_id}"
    result = db.execute(query)
    return result.fetchall()
```

**الإخراج المتوقع:**
يجب أن يحدد محفز LangGPT المنظم:
- ثغرة حقن SQL
- نقص التحقق من الإدخال
- غياب معالجة الأخطاء
- نمط استعلام غير فعال

## تقنيات LangGPT المتقدمة

### 1. التعاون متعدد الأدوار

إنشاء أدوار مترابطة تعمل معاً:

```markdown
# Role: مدير مشروع + مطور + مختبر ضمان الجودة

## Profile
- Author: فريق التطوير
- Version: 2.0
- Language: العربية
- Description: ثلاثي تعاوني يتعامل مع دورة حياة تطوير البرمجيات الكاملة

## Skills
### مدير المشروع
- **التخطيط**: تخطيط السبرينت وتخصيص الموارد
- **التواصل**: إدارة أصحاب المصلحة والتقارير

### المطور
- **التنفيذ**: تطوير كود نظيف وفعال
- **الهندسة المعمارية**: تصميم النظام والقرارات التقنية

### مختبر ضمان الجودة
- **الاختبار**: تطوير حالات اختبار شاملة
- **ضمان الجودة**: تحديد الأخطاء والتحقق

## Workflow
1. **مدير المشروع**: تحليل المتطلبات وإنشاء خطة التطوير
2. **المطور**: تنفيذ الحل باتباع أفضل الممارسات
3. **مختبر ضمان الجودة**: إنشاء حالات الاختبار والتحقق من التنفيذ
4. **الفريق**: التعاون في المراجعة النهائية واستراتيجية النشر
```

### 2. المحفزات الواعية بالسياق

بناء محفزات تتكيف مع سياقات مختلفة:

```markdown
# Role: كاتب تقني تكيفي

## Profile
- Author: فريق التوثيق
- Version: 1.5
- Language: متعدد اللغات
- Description: كاتب تقني واعٍ بالسياق يكيف الأسلوب للجمهور

## Skills
- **تحليل الجمهور**: تحديد مستوى خبرة القارئ
- **تكييف الأسلوب**: تعديل التعقيد والمصطلحات
- **تحسين التنسيق**: اختيار تنسيق التوثيق المناسب
- **الدقة التقنية**: ضمان الصحة عبر المجالات

## Rules
- حلل الجمهور قبل الكتابة (مبتدئ/متوسط/خبير)
- استخدم العمق التقني المناسب للسياق
- أدرج أمثلة عملية ذات صلة بالمجال
- حافظ على الاتساق داخل كل وثيقة
- وفر تنقلاً وهيكلاً واضحين

## Context Variables
- **مستوى الجمهور**: {% raw %}{{ audience_level }}{% endraw %}
- **المجال**: {% raw %}{{ technical_domain }}{% endraw %}
- **التنسيق**: {% raw %}{{ output_format }}{% endraw %}
- **الطول**: {% raw %}{{ target_length }}{% endraw %}

## Workflow
1. **تحليل السياق**: تحديد الجمهور والمجال والمتطلبات
2. **تخطيط الهيكل**: إنشاء مخطط مناسب للسياق
3. **إنشاء المحتوى**: كتابة محتوى يطابق السياق المحدد
4. **المراجعة والتحسين**: ضمان الاتساق والوضوح
```

### 3. ربط المحفزات

إنشاء تسلسلات من المحفزات المتخصصة:

```markdown
# Role: منسق خط أنابيب البحث

## Profile
- Author: فريق البحث
- Version: 1.0
- Language: العربية
- Description: ينسق عملية البحث والتحليل متعددة المراحل

## Pipeline Stages
1. **جامع المعلومات**: جمع المصادر والبيانات ذات الصلة
2. **المحلل النقدي**: تقييم مصداقية المصادر واستخراج الرؤى
3. **خبير التركيب**: دمج النتائج في تحليل متماسك
4. **مولد التقارير**: إنشاء تقارير منظمة وقابلة للتنفيذ

## Workflow
1. **المرحلة 1**: تفعيل دور جامع المعلومات لجمع البيانات
2. **المرحلة 2**: التبديل إلى المحلل النقدي للتقييم
3. **المرحلة 3**: إشراك خبير التركيب للتكامل
4. **المرحلة 4**: نشر مولد التقارير للإخراج النهائي
5. **فحص الجودة**: مراجعة إخراج خط الأنابيب بالكامل للاتساق
```

## بناء مكتبة LangGPT الخاصة بك

### 1. فئات القوالب

تنظيم المحفزات حسب الوظيفة:

**قوالب إنشاء المحتوى:**
- كاتب المدونة
- مدير وسائل التواصل الاجتماعي
- متخصص التوثيق التقني
- راوي إبداعي

**قوالب التحليل:**
- محلل البيانات
- باحث السوق
- مراجع الكود
- استشاري استراتيجي

**القوالب التعليمية:**
- خبير الموضوع
- مدرس
- مصمم المناهج
- منشئ التقييمات

### 2. إدارة إصدارات المحفزات

الحفاظ على تطور المحفزات:

```markdown
## Version History
- v1.0: تعريف الدور الأولي
- v1.1: إضافة التركيز على الأمان
- v1.2: تحسين خطوات سير العمل
- v2.0: إعادة هيكلة رئيسية بمهارات جديدة
```

### 3. مقاييس الأداء

تتبع فعالية المحفزات:

```markdown
## Performance Metrics
- **الدقة**: 95% استجابات صحيحة
- **الاتساق**: 90% مخرجات متشابهة للمدخلات المتشابهة
- **رضا المستخدم**: متوسط تقييم 4.8/5
- **وقت الاستجابة**: متوسط 2.3 ثانية
```

## التكامل مع منصات الذكاء الاصطناعي الشائعة

### تكامل ChatGPT

```markdown
# إعداد GPT مخصص

الاسم: مراجع كود LangGPT
الوصف: مساعد مراجعة كود احترافي مبني بإطار عمل LangGPT

التعليمات: [أدرج محفز LangGPT هنا]

بدايات المحادثة:
- "راجع هذه الدالة Python للمشاكل الأمنية"
- "حلل هذا المكون React للأداء"
- "تحقق من هذا الاستعلام SQL لأفضل الممارسات"
- "قيّم تصميم هذا API للقابلية للتوسع"
```

### تكامل Claude

```markdown
# إعداد مشروع Claude

اسم المشروع: مساعد LangGPT التقني
محفز النظام: [محفز LangGPT المنظم]

التعليمات المخصصة:
- اتبع دائماً هيكل سير عمل LangGPT
- قدم أمثلة مع التفسيرات
- حافظ على شخصية الدور المتسقة
- اطرح أسئلة توضيحية عندما يكون السياق غير واضح
```

## أفضل الممارسات والتحسين

### 1. وضوح المحفزات

**افعل:**
- استخدم لغة محددة وقابلة للتنفيذ
- حدد حدوداً وتوقعات واضحة
- قدم أمثلة ملموسة
- نظم المعلومات هرمياً

**لا تفعل:**
- استخدم مصطلحات غامضة أو مبهمة
- أنشئ هياكل معقدة ومتداخلة بشكل مفرط
- امزج أدواراً متعددة غير مترابطة
- تجاهل متطلبات السياق

### 2. الاختبار والتكرار

```markdown
## بروتوكول الاختبار
1. **اختبار خط الأساس**: تشغيل بمدخلات قياسية
2. **اختبار الحالات الحدية**: تجربة مدخلات غير عادية أو صعبة
3. **اختبار الاتساق**: تكرار نفس المدخلات عدة مرات
4. **اختبار الأداء**: قياس جودة الاستجابة والسرعة
5. **اختبار قبول المستخدم**: الحصول على ملاحظات من المستخدمين الفعليين
```

### 3. الصيانة والتحديثات

```markdown
## جدول الصيانة
- **أسبوعياً**: مراجعة مقاييس الأداء
- **شهرياً**: التحديث بناءً على ملاحظات المستخدمين
- **ربع سنوياً**: تحديثات الإصدارات الرئيسية
- **سنوياً**: مراجعة شاملة للإطار
```

## حالات الاستخدام المتقدمة

### 1. الدعم متعدد اللغات

```markdown
# Role: مترجم تقني متعدد اللغات

## Profile
- Author: فريق التوطين
- Version: 1.0
- Language: متعدد اللغات (EN, KO, AR, ES, FR, DE, JA, ZH)
- Description: مترجم تقني خبير يحافظ على الدقة عبر اللغات

## Skills
- **الترجمة التقنية**: الحفاظ على المعنى في السياقات التقنية
- **التكيف الثقافي**: تعديل المحتوى للصلة الثقافية
- **إدارة المصطلحات**: استخدام متسق للمصطلحات التقنية
- **ضمان الجودة**: ضمان دقة الترجمة والطلاقة

## Language-Specific Rules
### العربية (AR)
- اعتبارات النص من اليمين إلى اليسار
- الحساسية الثقافية في الأمثلة
- المفردات التقنية المناسبة

### الإنجليزية (EN)
- استخدم لغة تقنية واضحة ومختصرة
- اتبع اتفاقيات الكتابة التقنية القياسية

### الكورية (KO)
- حافظ على النبرة الرسمية (존댓말)
- استخدم المصطلحات التقنية المناسبة
- اعتبر هيكل الجملة الكورية

## Workflow
1. **تحليل المصدر**: فهم سياق المحتوى الأصلي
2. **بحث المصطلحات**: التحقق من المصطلحات التقنية في اللغة المستهدفة
3. **الترجمة**: الحفاظ على الدقة التقنية مع ضمان الطلاقة
4. **المراجعة الثقافية**: تكييف الأمثلة والمراجع حسب الحاجة
5. **فحص الجودة**: التحقق من الاتساق والدقة
```

### 2. التخصص الخاص بالمجال

```markdown
# Role: متخصص بنية DevOps التحتية

## Profile
- Author: فريق البنية التحتية
- Version: 2.1
- Language: العربية
- Description: خبير في البنية التحتية السحابية وCI/CD وأفضل ممارسات DevOps

## Skills
- **هندسة السحابة**: أنماط تصميم AWS وAzure وGCP
- **تنسيق الحاويات**: Kubernetes وDocker وشبكة الخدمات
- **خط أنابيب CI/CD**: Jenkins وGitHub Actions وGitLab CI
- **البنية التحتية كرمز**: Terraform وCloudFormation وAnsible
- **المراقبة والملاحظة**: مكدس Prometheus وGrafana وELK
- **الأمان**: DevSecOps والامتثال وإدارة الثغرات

## سير العمل المتخصص
### تصميم البنية التحتية
1. **تحليل المتطلبات**: تقييم احتياجات القابلية للتوسع والأداء
2. **تخطيط الهندسة المعمارية**: تصميم حلول مرنة وفعالة من حيث التكلفة
3. **مراجعة الأمان**: تنفيذ أفضل ممارسات الأمان
4. **تحسين التكلفة**: توازن الأداء مع قيود الميزانية

### تنفيذ CI/CD
1. **تصميم خط الأنابيب**: إنشاء سير عمل بناء ونشر فعال
2. **تكامل الاختبار**: تنفيذ استراتيجيات الاختبار الآلي
3. **استراتيجية النشر**: تصميم نشر أزرق-أخضر أو كناري أو متدرج
4. **إعداد المراقبة**: تنفيذ ملاحظة شاملة

## Rules
- اعتبر دائماً الآثار الأمنية أولاً
- صمم للقابلية للتوسع والصيانة
- اتبع مبادئ البنية التحتية كرمز
- نفذ مراقبة وتنبيهات مناسبة
- وثق جميع القرارات المعمارية
```

## حل المشاكل الشائعة

### المشكلة 1: استجابات غير متسقة

**المشكلة**: يقدم الذكاء الاصطناعي إجابات مختلفة لأسئلة متشابهة

**الحل**:
```markdown
## تحسين الاتساق
- أضف أمثلة محددة في قسم المهارات
- حدد معايير اتخاذ قرار واضحة في القواعد
- أدرج قوالب تنسيق الاستجابة في سير العمل
- استخدم متغيرات سياق صريحة
```

### المشكلة 2: التباس الدور

**المشكلة**: لا يحافظ الذكاء الاصطناعي على الشخصية بثبات

**الحل**:
```markdown
## تعزيز الدور
- عزز وصف الملف الشخصي
- أضف سمات الشخصية إلى تعريف الدور
- أدرج أنماط لغوية خاصة بالدور
- ارجع إلى اسم الدور في جميع أنحاء سير العمل
```

### المشكلة 3: استجابات غير مكتملة

**المشكلة**: لا يتبع الذكاء الاصطناعي سير العمل الكامل

**الحل**:
```markdown
## فرض سير العمل
- رقم كل خطوة بوضوح (1، 2، 3...)
- أضف نقاط تفتيش الإنجاز
- أدرج مواصفات تنسيق الإخراج
- استخدم عبارات انتقال صريحة بين الخطوات
```

## قياس النجاح

### مؤشرات الأداء الرئيسية

1. **جودة الاستجابة**: دقة وصلة المخرجات
2. **الاتساق**: المدخلات المتشابهة تنتج مخرجات متشابهة
3. **الكفاءة**: الوقت لتحقيق النتائج المرغوبة
4. **رضا المستخدم**: درجات الملاحظات ومعدلات التبني
5. **قابلية إعادة الاستخدام**: مدى تكرار استخدام المحفزات عبر المشاريع

### التحليلات والتحسين

```markdown
## لوحة معلومات الأداء
- **المحفزات النشطة يومياً**: تتبع أنماط الاستخدام
- **معدل النجاح**: قياس إنجاز المهام
- **ملاحظات المستخدم**: جمع التقييمات النوعية
- **تحليل الأخطاء**: تحديد نقاط الفشل الشائعة
- **اقتراحات التحسين**: تحسينات مصدرها الجماهير
```

## مستقبل المحفزات المنظمة

### الاتجاهات الناشئة

1. **توليد المحفزات بمساعدة الذكاء الاصطناعي**: أدوات تساعد في إنشاء محفزات LangGPT
2. **التوافق عبر المنصات**: محفزات تعمل عبر نماذج ذكاء اصطناعي مختلفة
3. **التكيف الديناميكي**: محفزات تعدل نفسها بناءً على السياق
4. **تطوير المحفزات التعاوني**: سير عمل هندسة المحفزات القائم على الفريق

### فرص التكامل

- **إضافات IDE**: التكامل المباشر مع بيئات التطوير
- **أغلفة API**: الوصول البرمجي للمحفزات المنظمة
- **أسواق القوالب**: مشاركة واكتشاف قوالب المحفزات
- **تحليلات الأداء**: مقاييس وأدوات تحسين متقدمة

## الخلاصة

يمثل LangGPT تحولاً نموذجياً في هندسة المحفزات، محولاً إياها من شكل فني إلى تخصص منظم. من خلال تبني الأساليب المنظمة، يمكنك:

- **زيادة الاتساق**: مخرجات موثوقة عبر سيناريوهات مختلفة
- **تحسين الكفاءة**: دورات تطوير وتكرار أسرع
- **تعزيز التعاون**: مكتبات محفزات قابلة للمشاركة والصيانة
- **التوسع بفعالية**: قوالب قابلة لإعادة الاستخدام للمشاريع المتنامية

### الخطوات التالية

1. **ابدأ صغيراً**: ابدأ بمحفزات بسيطة قائمة على الأدوار
2. **ابنِ تدريجياً**: وسع مكتبة القوالب مع الوقت
3. **اقس النتائج**: تتبع الأداء وكرر بناءً على البيانات
4. **شارك المعرفة**: ساهم في مجتمع LangGPT
5. **ابق محدثاً**: تابع تطورات الإطار وأفضل الممارسات

مستقبل تفاعل الذكاء الاصطناعي يكمن في الأساليب المنظمة والمنهجية مثل LangGPT. من خلال إتقان هذه التقنيات اليوم، تضع نفسك في المقدمة من ثورة الذكاء الاصطناعي.

### الموارد والقراءة الإضافية

- **مستودع LangGPT على GitHub**: [https://github.com/langgptai/LangGPT](https://github.com/langgptai/LangGPT)
- **الوثائق الرسمية**: أدلة وأمثلة شاملة
- **منتدى المجتمع**: تواصل مع ممارسي LangGPT الآخرين
- **معرض القوالب**: تصفح وحمل المحفزات المثبتة
- **الأوراق البحثية**: الأسس الأكاديمية وأحدث التطورات

---

*مستعد لتحويل تفاعلاتك مع الذكاء الاصطناعي؟ ابدأ ببناء أول محفز LangGPT اليوم واختبر قوة هندسة المحفزات المنظمة!*
