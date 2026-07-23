---
title: "أنماط معمارية خوادم MCP: لماذا يربك تعدّد الأدوات نماذج LLM"
excerpt: "ورقة بحثية جديدة تحلّل 15 خادم MCP في الإنتاج تصنّف خمسة أنماط معمارية وأربعة أنماط مضادّة. النتيجة الأبرز: بعد عدد معيّن من الأدوات تنهار دقّة اختيار النموذج للأداة الصحيحة."
seo_title: "أنماط معمارية خوادم MCP وإرباك الأدوات لـ LLM - Thaki Cloud"
seo_description: "تحليل الورقة arXiv 2606.30317. أنماط خوادم MCP الخمسة وأثر عدد الأدوات على دقّة اختيار الأداة، واختيار BM25 في Paxis Skill Harness."
date: 2026-07-03
last_modified_at: 2026-07-03
tags:
  - MCP
  - Model-Context-Protocol
  - LLM-Agents
  - Architecture-Patterns
  - Tool-Selection
  - Agent-Native-Cloud
  - Paxis
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/research/mcp-server-architecture-patterns/"
reading_time: true
header:
  image: /assets/images/mcp-server-architecture-patterns-hero.webp
  teaser: /assets/images/mcp-server-architecture-patterns-hero.webp
categories:
  - research
published: false
---

## نظرة عامة

بروتوكول Model Context Protocol (MCP) هو واجهة قياسية أطلقتها Anthropic في نوفمبر 2024. يوفّر طريقة موحّدة لربط نماذج اللغة الكبيرة بالأدوات ومصادر البيانات والخدمات الخارجية. وخلال أشهر ظهرت مئات خوادم MCP التي بنتها المجتمعات على GitHub. ومع ذلك لم يوجد أدب في صيانة البرمجيات يصف كيف تُبنى هذه الخوادم فعليًّا في الإنتاج.

تسدّ هذه الفجوة ورقة [MCP Server Architecture Patterns for LLM-Integrated Applications](https://arxiv.org/abs/2606.30317) لـ Carson Rodrigues وزملائه، المنشورة على arXiv في 29 يونيو 2026. باستخدام مجموعة من 15 خادم MCP طُوِّرت بشكل مستقل، تصنّف الورقة خمسة أنماط معمارية متكرّرة وأربعة أنماط مضادّة، إلى جانب اهتمامات شاملة تتعلّق بالمصادقة وإدارة الإصدارات وقابلية الرصد.

ولمن يشغّل بنية الوكلاء، يبرز جزء واحد بوضوح. فقد قاست الورقة فعليًّا عدد الأدوات التي يمكن إرفاقها، وجاءت الإجابة أقلّ بكثير ممّا يفترضه معظم الفرق. ولأنّ هذا يتقاطع مباشرة مع كيفية تعامل ThakiCloud مع أكثر من 960 مهارة في Paxis، سحابتنا الأصيلة للوكلاء (Agent-Native Cloud)، يستعرض هذا المقال النتائج المقيسة جنبًا إلى جنب مع خياراتنا التصميمية.

## ما هي الدراسة

النهج تجريبي. فبدلًا من وصف ما ينبغي أن تكون عليه الخوادم، فكّك الباحثون 15 خادمًا قيد التشغيل واستخلصوا بنيتها المشتركة استقرائيًّا. وتنقسم الأنماط الخمسة الناتجة وفق محورين: ما الذي يعرضه الخادم لنموذج LLM، وكيف يتعامل مع الحالة.

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
<div class="d3-arch" data-arch-root id="rverarchitecturepatterns-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1154, "height": 644, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "LLM", "x": 531, "y": 24, "w": 120, "h": 46, "title": "وكيل LLM"}, {"id": "Client", "x": 531, "y": 148, "w": 120, "h": 46, "title": "عميل MCP"}, {"id": "Server", "x": 531, "y": 272, "w": 120, "h": 46, "title": "خادم MCP"}, {"id": "P1", "x": 959, "y": 396, "w": 163, "h": 62, "title": ["Resource Gateway", "يعرض مصادر البيانات"]}, {"id": "P2", "x": 741, "y": 396, "w": 163, "h": 62, "title": ["Tool Orchestrator", "ينسّق تنفيذ الأدوات"]}, {"id": "P3", "x": 495, "y": 396, "w": 191, "h": 62, "title": ["Stateful Session Server", "يحفظ حالة الجلسة"]}, {"id": "P4", "x": 270, "y": 396, "w": 170, "h": 62, "title": ["Proxy Aggregator", "يوحّد خلفيات متعدّدة"]}, {"id": "P5", "x": 24, "y": 396, "w": 191, "h": 62, "title": ["Domain-Specific Adapter", "تغليف واعٍ بالمجال"]}, {"id": "X", "x": 731, "y": 550, "w": 184, "h": 62, "title": ["المصادقة · الإصدارات ·", "قابلية الرصد"]}], "edges": [{"src": "LLM", "dst": "Client", "kind": "data", "line": [591, 70, 591, 148]}, {"src": "Client", "dst": "Server", "kind": "data", "line": [591, 194, 591, 272]}, {"src": "Server", "dst": "P1", "kind": "data", "curve": [[651, 303], [1041, 357], [1041, 357], [1041, 396]]}, {"src": "Server", "dst": "P2", "kind": "data", "curve": [[651, 311], [823, 357], [823, 357], [823, 396]]}, {"src": "Server", "dst": "P3", "kind": "data", "line": [591, 318, 591, 396]}, {"src": "Server", "dst": "P4", "kind": "data", "curve": [[531, 311], [355, 357], [355, 357], [355, 396]]}, {"src": "Server", "dst": "P5", "kind": "data", "curve": [[531, 303], [120, 357], [120, 357], [120, 396]]}, {"src": "P1", "dst": "X", "kind": "event", "label": "اهتمامات شاملة", "curve": [[1041, 458], [1041, 504], [1041, 504], [910, 550]], "off": "50%"}, {"src": "P2", "dst": "X", "kind": "event", "label": "اهتمامات شاملة", "line": [823, 458, 823, 550], "lx": 823, "ly": 500}, {"src": "P3", "dst": "X", "kind": "event", "label": "اهتمامات شاملة", "curve": [[591, 458], [591, 504], [591, 504], [731, 550]], "off": "50%"}]});
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
      const container = document.getElementById('rverarchitecturepatterns-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rverarchitecturepatterns-1';
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

قيمة هذا التصنيف أنّه يجبرك على تحديد "أيّ نوع من الخوادم هذا" قبل البناء. فإذا حشرت منطق التنفيذ المعقّد لنمط Tool Orchestrator داخل Resource Gateway، جمعت عيوب النمطين معًا. اختيار النمط صراحةً هو بحدّ ذاته انضباط تصميمي.

## الأنماط المعمارية الخمسة

**Resource Gateway** يعرض مصادر البيانات مثل قواعد البيانات وأنظمة الملفّات وواجهات API بأسلوب يركّز على القراءة. الأدوات نفسها بسيطة، والسؤال الحقيقي هو أيّ الموارد تفتحها وبأيّ صلاحيات.

**Tool Orchestrator** يجمع عدّة أدوات وينسّق تدفّق تنفيذ. غالبًا ما ينفّذ الاستدعاء الواحد خطوات داخلية متعدّدة، لذا تصبح معالجة الأخطاء والتراجع الجزئي هي الصعوبة الأساسية.

**Stateful Session Server** يحفظ الحالة عبر محادثة أو جلسة عمل. استدعاءات LLM بلا حالة في جوهرها، فيحمل الخادم الحالة نيابةً عن النموذج وعليه أن يحدّد عمر الجلسة وسياسة التنظيف بوضوح.

**Proxy Aggregator** يدمج عدّة خلفيات أو خوادم MCP أخرى خلف واجهة واحدة. مريح، لكن مع تكاثر الأدوات خلفه يقود سريعًا إلى مشكلة إرباك الأدوات التي نناقشها أدناه.

**Domain-Specific Adapter** يغلّف مفاهيم مجال محدّد (المال، الرعاية الصحّية، الأنظمة الداخلية) في شكل يتعامل معه LLM جيّدًا. فيدمج مصطلحات المجال وقيوده في مخطّط الأداة كي لا يحاول النموذج تركيبات غير منطقية.

## إرباك الأدوات: لماذا يتعثّر النموذج مع تعدّد الأدوات

أهمّ جزء عمليًّا في الورقة يقيس العلاقة بين عدد الأدوات ودقّة اختيار الأداة. النتيجة واضحة: بمجرّد تجاوز عدد الأدوات في السياق حدًّا معيّنًا، تنخفض دقّة النموذج في اختيار الأداة الصحيحة إلى ما دون 90%.

على وجه التحديد، تفيد الورقة بأنّ دقّة Claude Haiku 4.5 تنخفض دون 90% بين 10 و15 أداة، وبالنسبة لـ Sonnet 4 بين 20 و30 أداة. تتحمّل النماذج الأكبر عددًا أكبر من الأدوات، لكن لا توجد نقطة يصحّ عندها "أرفق ما شئت". فمع تكاثر الأدوات وغموض أوصافها، يرتبك النموذج.

يقلب هذا القياس حدسًا شائعًا. إذ كثيرًا ما يبدأ من يضيف MCP لأوّل مرّة بـ"عرض كلّ واجهة API نملكها كأداة". وبدمج عدّة خلفيات عبر Proxy Aggregator يصل عدد الأدوات بسرعة إلى العشرات، فتسقط من على حافّة الدقّة. عدد الأدوات ليس مجّانيًّا، بل يستهلك ميزانية حكم النموذج.

## الأنماط المضادّة والاهتمامات الشاملة

تصنّف الورقة أيضًا أربعة أنماط مضادّة. الأسماء الدقيقة غير مؤكّدة على مستوى الملخّص، لكنّ الاتّجاه يتّصل بالقياس أعلاه. فزيادة الأدوات دون تمييز، وترك أوصاف الأدوات غامضة كي يستنتج النموذج النيّة، وترك الجلسات تنجرف دون إدارة حالة، ومعالجة المصادقة والإصدارات بشكل غير متّسق لكلّ خادم، هي أنماط الفشل النموذجية.

أمّا الاهتمامات الشاملة فتُبرز المصادقة وإدارة الإصدارات وقابلية الرصد. الثلاثة مطلوبة أيًّا كان النمط الذي تختاره. وقابلية الرصد خصوصًا كثيرًا ما تُؤجَّل في أنظمة الوكلاء، ومع ذلك عندما يفشل استدعاء أداة ولا تستطيع تتبّع السبب، يصبح تصحيح الأخطاء مستحيلًا عمليًّا.

## الآثار على منتجات ThakiCloud

يتطابق استنتاج الورقة حول إرباك الأدوات تمامًا مع سبب بناء ThakiCloud لـ **Paxis**. فـ Paxis هو مستوى تحكّم Agent-Native Cloud يعمل فوق ai-platform، ويتعامل مع المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلّات التدقيق (Audit Logs) كموارد من الدرجة الأولى. والعنصر الجوهري هو **Skill Harness**.

يملك Paxis أكثر من 960 مهارة، لكنّه لا يصبّها كلّها في سياق النموذج كأدوات أبدًا. بل يختار لكلّ طلب مستخدم مجموعة صغيرة من المهارات ذات الصلة عبر بحث BM25 ويعرضها. وبإسقاط ذلك على قياس الورقة، فهذا تصميم يتفادى حافّة الدقّة. يواجه النموذج دائمًا حفنة قابلة للإدارة من الأدوات، بينما تُستدعى المئات المتبقّية من القدرات عند الحاجة. "قدرات كثيرة، عرض قليل" هو جوابنا على مشكلة إرباك الأدوات.

نُدير خطر Proxy Aggregator بالعدسة نفسها. فموصّلات MCP في Paxis تربط خدمات خارجية كثيرة، لكن بدلًا من عرض كلّ أداة موصولة، تصفّيها بوّابة سياسات كي لا يصل إلى مسار التنفيذ في الصندوق المعزول سوى ما يلزم فعلًا. ويترك كلّ استدعاء أداة سجلّ تدقيق، ما يلبّي متطلّب قابلية الرصد. فالمصادقة والإصدارات وقابلية الرصد التي أشارت إليها الورقة كاهتمامات شاملة مبنيّة افتراضيًّا في Paxis، لا اختيارية.

وتجدر الإشارة أيضًا إلى الطبقة التحتية **ai-platform**. فمع تكاثر خوادم MCP، يعمل كلّ منها في النهاية كعملية في مكان ما. يخدم ai-platform هذه الخوادم بموثوقية على K8s وجدولة GPU المبنية على Kueue مع عزل متعدّد المستأجرين، ويمتدّ إلى البيئات المحلّية والسيادية. وبالنسبة للخوادم الحافظة للحالة مثل Stateful Session Server، يهمّ التوضيع وإدارة دورة الحياة، وهنا يصبح نضج تشغيل K8s ميزة مباشرة.

## القيود والاعتراضات

تستند الورقة إلى مجموعة صغيرة نسبيًّا من 15 خادمًا. ونظام MCP البيئي ينمو بسرعة بحيث يبقى السؤال قائمًا حول ما إذا كانت هذه الأنماط الخمسة ستظلّ ممثِّلة. فقد تظهر أنماط جديدة، أو تخفّ الأنماط المضادّة الحالية بأدوات أفضل.

كما يعتمد قياس دقّة اختيار الأداة على النموذج وتصميم المُوجِّه (prompt). فالأوصاف الجيّدة والتسمية الواضحة ترفع الدقّة عند العدد نفسه من الأدوات. بعبارة أخرى، لا يوجد خطّ مطلق بأنّ "N أداة آمنة"، بل عدد الأدوات متغيّر من بين عدّة متغيّرات. ومع ذلك يبقى الاتّجاه واضحًا: الأدوات ليست مجّانية، وانضباط عرض ما يلزم فقط هو أساس موثوقية الوكلاء.

## المصادر

- Carson Rodrigues et al., [MCP Server Architecture Patterns for LLM-Integrated Applications](https://arxiv.org/abs/2606.30317), arXiv:2606.30317 (2026-06-29)
- [مقدّمة Model Context Protocol الرسمية](https://modelcontextprotocol.io/)
