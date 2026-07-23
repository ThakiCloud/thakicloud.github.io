---
title: "كيف توجّه Claude Fable 5: خمسة مبادئ من دليل Anthropic الرسمي"
excerpt: "نحلل دليل التوجيه الرسمي الذي أصدرته Anthropic لنموذج Claude Fable 5. يطرح الدليل خمسة مبادئ: التخلص من التعليمات التي كُتبت للنماذج القديمة، ومراجعة التقدم بالاستناد إلى نتائج الأدوات، والاعتماد بثقة على الوكلاء الفرعيين، والتعلم من التشغيلات السابقة، وتحديد القيود بوضوح. نقرأ هذه المبادئ من زاوية كيفية تشغيل ThakiCloud الفعلي لوكلائها."
tags:
  - claude
  - fable-5
  - prompt-engineering
  - agent
  - anthropic
date: 2026-07-02
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/prompting-claude-fable-5/"
header:
  image: /assets/images/prompting-claude-fable-5-hero.webp
categories:
  - llmops
---

## نظرة عامة

في كل مرة يصدر فيها نموذج جديد، نميل إلى نقل التعليمات ذاتها التي بنيناها للنموذج القديم. لكن دليل التوجيه الرسمي الذي نشرته Anthropic لنموذج Claude Fable 5 يوصي بعكس ذلك تماماً. فالتعليمات التي كانت تجعل النماذج السابقة تتصرف بشكل جيد قد تُضعف فعلياً جودة مخرجات Fable 5. وبكلمات الدليل نفسه، فإن المهارات المبنية للنماذج السابقة تكون غالباً "مُفصّلة أكثر من اللازم بالنسبة لـ Claude Fable 5، ما قد يُضعف جودة المخرجات".

هذه الجملة الواحدة تلخص روح الدليل بأكمله. النموذج الأذكى يحتاج إلى قواعد أقل، لا أكثر. وبالنسبة لمؤسسة مثل ThakiCloud تُشغّل الوكلاء فعلياً في بيئة الإنتاج، هذا التحول ليس مشكلة الآخرين. إنه تحذير من أن مئات المهارات والقواعد التي نستخدمها للتحكم في الوكلاء قد تتحول إلى عبء أمام نموذج أحدث. لنستعرض معاً المبادئ الخمسة التي يطرحها الدليل واحداً تلو الآخر، ولنلاحظ كم منها يتقاطع مع الانضباط الذي نمارسه بالفعل.

## ما الذي تغيّر

يتمتع Fable 5 باستقلالية أعلى من الجيل السابق. فهو يُطلق الوكلاء الفرعيين بمبادرة منه بشكل أكثر جرأة، ويدفع المهام الطويلة إلى الأمام من تلقاء نفسه، بل ويقوم أحياناً بأفعال لم يطلبها أحد. وكلما ارتفعت القدرة، وجب أن تتغير طريقة التحكم أيضاً. فالتعليمات التي تُمسك بيد النموذج وتوجّهه خطوة بخطوة تشبه توجيه موظف جديد كفء في كل حركة، وهي تُعيق حكمه بدلاً من أن تساعده. المبادئ الخمسة في الدليل لا تهدف إلى كبح هذه الاستقلالية، بل إلى توجيهها في الاتجاه الصحيح.

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
<div class="d3-arch" data-arch-root id="702promptingclaudefable5-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 708, "height": 634, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 282, "w": 135, "h": 62, "title": ["Fable 5", "استقلالية عالية"]}, {"id": "B", "x": 237, "y": 540, "w": 191, "h": 62, "title": ["1. التخفيف", "إزالة التعليمات الزائدة"]}, {"id": "C", "x": 248, "y": 407, "w": 170, "h": 78, "title": ["2. مراجعة عبر نتائج", "الأدوات", "ممنوع التقرير الذاتي"]}, {"id": "D", "x": 237, "y": 274, "w": 191, "h": 78, "title": ["3. الاعتماد على الوكلاء", "الفرعيين", "تفويض غير متزامن"]}, {"id": "E", "x": 241, "y": 141, "w": 184, "h": 78, "title": ["4. التعلم من التشغيلات", "السابقة", "تسجيل الدروس"]}, {"id": "F", "x": 241, "y": 24, "w": 184, "h": 62, "title": ["5. تحديد القيود", "ما يجب وما لا يجب فعله"]}, {"id": "G", "x": 506, "y": 282, "w": 170, "h": 62, "title": ["توجيهات تحدد الاتجاه", "وتترك الحكم للنموذج"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[104, 344], [198, 571], [198, 571], [237, 571]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[116, 344], [198, 446], [198, 446], [248, 446]]}, {"src": "A", "dst": "D", "kind": "data", "line": [159, 313, 237, 313]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[116, 282], [198, 180], [198, 180], [241, 180]]}, {"src": "A", "dst": "F", "kind": "data", "curve": [[104, 282], [198, 55], [198, 55], [241, 55]]}, {"src": "B", "dst": "G", "kind": "data", "curve": [[428, 571], [467, 571], [467, 571], [576, 344]]}, {"src": "C", "dst": "G", "kind": "data", "curve": [[418, 446], [467, 446], [467, 446], [562, 344]]}, {"src": "D", "dst": "G", "kind": "data", "line": [428, 313, 506, 313]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[425, 180], [467, 180], [467, 180], [562, 282]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[425, 55], [467, 55], [467, 55], [576, 282]]}]});
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
      const container = document.getElementById('702promptingclaudefable5-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '702promptingclaudefable5-1';
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

## المبدأ الأول: خفّف التعليمات

أول ما يشدد عليه الدليل هو الحذف. فالتعليمات المكتوبة بإحكام للنماذج القديمة تنهك أداء Fable 5. الحدس القائل بأن القواعد الأكثر أفضل ينقلب رأساً على عقب مع هذا النموذج. عند الانتقال إلى نموذج جديد، لا تكون الخطوة الأولى إضافة المزيد إلى التوجيه، بل تحديد أي التعليمات لم تعد ضرورية والتخلص منها.

هذا المبدأ يتقاطع تماماً مع فكرة "غلاف رقيق، مهارات ثقيلة" التي حافظ عليها مستودعنا طويلاً: نُبقي القدرة في المهارات والبيانات لا في الغلاف نفسه، ونُبقي التعليمات التي نُثقل بها كل جولة عند حدها الأدنى. وحين نستقبل نموذجاً جديداً، فإن أول ما نفعله ليس زيادة القواعد والمهارات، بل تنقية أي تعليمة لا تجتاز السؤال: "هل سيُخطئ الوكيل من دون هذه الجملة؟"

## المبدأ الثاني: راجع التقدم عبر نتائج الأدوات

خلال التشغيلات الطويلة المستقلة، ينبغي توجيه Fable 5 لمراجعة تقدمه بنفسه بالاستناد إلى نتائج الأدوات الفعلية. التوجيه المثال الذي يقدمه الدليل هو التالي.

```text
Before reporting progress, audit each claim against a tool result
from this session. Only report work you can point to evidence for.
```

بحسب اختبارات Anthropic، ألغت هذه الجملة الواحدة تقارير التقدم المُختلَقة تقريباً بالكامل. فبدلاً من أن يقول النموذج "أعتقد أنني أنهيت هذا"، تُجبره الجملة على الإبلاغ فقط عن العمل الذي يستطيع الإشارة إلى دليل عليه من بين نتائج أدوات هذه الجلسة.

هذا يطابق مبدأً كررناه في العديد من قواعدنا الخاصة: لا يمكن أبداً أن يكون التقرير الذاتي للنموذج شرط إنهاء لحلقة تكرارية. أوثق تغذية راجعة هي التحقق الحتمي الذي يُعيد نتيجة نجاح أو فشل بموضوعية، تماماً كما تفعل الاختبارات ومدققات الأنواع والمترجمات. لهذا بالضبط تبت بواباتنا الخاصة بالتحقق حكمها بناءً على رمز الخروج، ولهذا تُغلق نتائج التوزيع المتوازي بتصويت لا برواية. وكون Anthropic قد دوّنت هذا المبدأ الآن في دليل رسمي يُظهر أن عدم الثقة بالتقارير الذاتية بات يتحول إلى الافتراضي في تشغيل الوكلاء، لا إلى ذوق فريق بعينه.

## المبدأ الثالث: اعتمد بثقة على الوكلاء الفرعيين

يُطلق Fable 5 الوكلاء الفرعيين المتوازيين بمبادرة أكبر من النماذج السابقة. يوصي الدليل بعدم كبح هذا الميل بل الاستفادة منه، مع توجيه واضح لتحديد متى يكون التفويض مناسباً، وتفضيل التواصل غير المتزامن بين المنسّق والوكلاء الفرعيين. الهدف من التفويض ليس التفويض بحد ذاته، بل دفع العمل المستقل بشكل متوازٍ لرفع الإنتاجية الإجمالية.

هذا بالضبط ما يتناوله انضباط توجيه النماذج في مستودعنا. نُسند الاستكشاف وقراءة الملفات إلى نماذج منخفضة الكلفة، والتنفيذ إلى مستوى متوسط، ونحجز النماذج عالية الكلفة للاستدلال المعقد والتحقق فقط، ونحرص دائماً على تحديد معامل النموذج عند إطلاق أي وكيل فرعي. وكون Fable 5 يتعامل مع الوكلاء الفرعيين بشكل أفضل يعني أن هذا النوع من التوجيه سيُحقق مردوداً أكبر مستقبلاً. فإبقاء المنسّق خفيفاً وعزل العمل الثقيل فقط في وكلاء فرعيين متخصصين نمط يتماشى طبيعياً مع سلوك النموذج.

## المبدأ الرابع: تعلّم من التشغيلات السابقة

يعمل Fable 5 بشكل جيد بوجه خاص عندما يستطيع تسجيل الدروس المستفادة من التشغيلات السابقة والرجوع إليها. يوصي الدليل بتوفير مساحة تخزين بسيطة قدر ملف ماركداون واحد، ويقدّم هذا المثال.

```text
Store one lesson per file with a one-line summary at the top.
Record corrections and confirmed approaches alike, including why
they mattered.
```

خزّن درساً واحداً في كل ملف، وضع ملخصاً بسطر واحد في الأعلى، وسجّل التصحيحات والمقاربات المؤكدة معاً مع سبب أهميتها. هذا التوجيه يشبه إلى حد لافت بنية الذاكرة الخاصة بالنظام نفسه الذي يكتب هذا المقال. تعمل ذاكرة وكلاء ThakiCloud تماماً على هذا النمط: حقيقة واحدة في كل ملف، وملخص بسطر واحد في بيانات الترويسة، وتصحيحات وأنماط مؤكدة مُسجّلة مع أسبابها. وحلقة الذاكرة الساخنة التي تقرأ كل ما تعلمناه حتى الجلسة الأخيرة كموجز دائم عند بداية كل جلسة جديدة تقوم على الفكرة ذاتها. هذا التطابق بين توصية Anthropic وانضباطنا الخاص بالذاكرة إشارة إلى أن عدم ترك الوكيل يبدأ من صفحة بيضاء في كل مرة يقترب من أن يصبح إجابة عالمية، لا عادة محلية.

## المبدأ الخامس: حدّد القيود بوضوح

ثمن الاستقلالية العالية أن Fable 5 يقوم أحياناً بأفعال لم يطلبها أحد. لمنع ذلك، يوصي الدليل بتعريف قيود صريحة على ما يجب على النموذج فعله وما لا يجب فعله. اترك الاتجاه مفتوحاً، لكن ارسم بوضوح الخط الذي لا ينبغي تجاوزه.

في عملياتنا الخاصة، يُنفَّذ هذا الخط عبر بوابات الموافقة وشبكات الأمان حول التغييرات التي لا يمكن التراجع عنها. فأي عمل غير قابل للتراجع، كتعديل المخطط أو النشر، يتطلب خطة مسبقة وموافقة صريحة، وأي فعل عالي المخاطر مثل تنفيذ الصفقات يحصل على حارس صارم. كلما ازدادت كفاءة النموذج، ازدادت أهمية توضيح ما لا يجوز له فعله، أكثر من توضيح ما يستطيع فعله. استقلالية Fable 5 تصبح أصلاً حين تُرسم القيود جيداً، وتصبح خطراً حين لا تُرسم كذلك.

## دلالات التطبيق على منتجات ThakiCloud

تنطبق هذه المبادئ الخمسة مباشرة على فلسفة تصميم Paxis، المنتج الذي تبنيه ThakiCloud. Paxis هو مستوى تحكم Agent-Native Cloud يعمل فوق ai-platform، ويعامل المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. ما يسميه الدليل "التخفيف" هو طريقتنا في إبقاء غلاف المهارات رقيقاً وتكديس القدرة في المهارات بدلاً منه. و"المراجعة عبر نتائج الأدوات" هي طريقتنا في إغلاق التوزيع المتوازي ببوابات تحقق حتمية. و"الاعتماد بثقة على الوكلاء الفرعيين" يتجسد عبر تنسيق متعدد الوكلاء بنمط DAG وتوجيه النماذج. و"التعلم من التشغيلات السابقة" هو محرك ذاكرتنا وحلقة الذاكرة الساخنة. و"تحديد القيود" هو بوابات السياسات وسجلات التدقيق.

بعبارة أخرى، دليل Anthropic للتوجيه يمنح أساساً رسمياً لانضباط نمارسه بالفعل. وكلما ازدادت قوة النماذج الجديدة، ازدادت قيمة هذا الانضباط. فبدلاً من ترك نموذج كفء يبدأ من صفحة بيضاء، أو تصديق تقاريره الذاتية كما هي، أو إعاقة حكمه بتعليمات مفرطة، من الأفضل تغليفه بغلاف رقيق وبوابات تحقق وذاكرة مستمرة. وهذا التغليف بالذات هو ما يبيعه Paxis.

## الحدود والحجج المضادة

لا ينبغي التعامل مع هذا الدليل باعتباره عقيدة مطلقة. مبدأ "خفّف التعليمات" جذاب، لكن تحديد ما الذي يجب حذفه يبقى مسألة حكم. فتعليمة واحدة حُذفت خطأً قد تُسبب انتكاسة، ورصد تلك الانتكاسة يتطلب أصلاً المبدأين السابقين: التحقق الحتمي وسجل التشغيلات السابقة. المبادئ يُسند بعضها بعضاً، لذا فإن تطبيق واحد منها فقط يُنصّف فاعليتها.

كما أن هذا الدليل يستهدف نموذجاً بعينه هو Fable 5. النصائح الواردة فيه لا تنتقل بالكامل إلى كل نموذج، لا سيما النماذج الصغيرة الأقل استقلالية. فالنماذج الصغيرة تحتاج بالأحرى إلى تعليمات أكثر إحكاماً وهيكل ثابت للحفاظ على الجودة. تطبيق "قلّل التعليمات" بشكل موحّد على جميع المستويات سيُزعزع مخرجات العمال منخفضي الكلفة. الانضباط في التوجيه يحتاج إلى معايرة بحسب مستوى النموذج.

وأخيراً، هناك مفارقة: كلما ازدادت استقلالية النموذج، ازدادت صعوبة فرض القيود عليه. لإجبار نموذج يُطلق وكلاءه الفرعيين بنفسه ويقوم بأفعال لم تُطلب على التوقف، لا تكفي التوجيهات وحدها، بل لا بد من دعمها بخطافات حتمية وبوابات موافقة. الدليل يتناول لغة التوجيه، لكن شبكة الأمان الحقيقية يجب أن يمتلكها الكود.

## المصادر

- [Prompting Claude Fable 5، الوثائق الرسمية لشركة Anthropic (platform.claude.com)](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
- [Redeploying Claude Fable 5، أخبار Anthropic](https://www.anthropic.com/news/redeploying-fable-5)
