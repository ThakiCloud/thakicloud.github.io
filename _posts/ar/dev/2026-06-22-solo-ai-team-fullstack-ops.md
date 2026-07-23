---
title: "كيف يُدير مهندس ذكاء اصطناعي منفرد مكتبةً من 1620 مهارة"
excerpt: "1620 مهارة، 55 وكيلاً فرعياً، تطور ذاتي ليلي، وضوابط للتكاليف. الكشف الكامل عن منظومة التشغيل التي تُمكّن فريق ذكاء اصطناعي منفرداً من إدارة مكدس أتمتة ضخم."
seo_title: "مكدس أتمتة مهندس الذكاء الاصطناعي المنفرد: 1620 مهارة، 55 وكيلاً - Thaki Cloud"
seo_description: "كيف يُدير مهندس ذكاء اصطناعي منفرد 1620 مهارة، 55 وكيلاً فرعياً، وحلقات تطور ذاتي ليلي، وتوجيه تكاليف haiku/sonnet/opus لإدارة مكدس أتمتة ذكاء اصطناعي ضخم. التجربة الأصلية وراء منتج ThakiCloud Paxis."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: ar
tags:
  - solo-engineer
  - ai-automation
  - agent-ops
  - productivity
  - claude-code
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/solo-ai-team-fullstack-ops/"
reading_time: true
categories:
  - dev
published: false
---

![نظرة عامة على تشغيل مهندس الذكاء الاصطناعي المنفرد]({{ '/assets/images/solo-ai-team-fullstack-ops-hero.webp' | relative_url }})

## نظرة عامة: كيف يتمكن شخص واحد من إدارة هذا الحجم؟

يتكرر هذا السؤال كثيراً. نحو 1620 مهارة، 55 وكيلاً فرعياً، 36 قاعدة دائمة التفعيل، 22 أمر مائل (slash command)، و12 ربط (hook). في الليل، تُشغّل وظائف launchd غير المراقبة حلقات تطورها الذاتي. يتزامن جهازان -- جهاز المنزل وجهاز المكتب -- عبر فرع main واحد. مهندس واحد فقط يُدير كل هذا بمفرده.

تبدو الأرقام مستحيلة للوهلة الأولى. لكن هذه الأرقام ليست أشياء تحتاج إلى إدارة؛ فالنظام يستخدم معظمها من تلقاء نفسه. بينما يكتب المهندس الكود، يختار موجّه المهارات المهارة المناسبة؛ وبينما ينام، تُنقّح حلقة التطور المهاراتِ؛ وتحافظ ضوابط التكاليف على الميزانية.

السر ليس في إدارة الحجم، بل في **تصميم الحجم ليُدير نفسه بنفسه**. المهارات تُطور المهارات، والوكلاء يُوجّهون الوكلاء، وحلقات المراجعة تُحسّن اختيار النماذج. مهمة الإنسان هي تحديد الاتجاه، ورصد الإشارات الشاذة، وإصدار الأحكام الرئيسية فحسب.

هذه المقالة هي المرة الأولى التي يُكشف فيها عن منظومة التشغيل الكاملة دفعةً واحدة. وتشرح كيف يتشابك توجيه المهارات والتطور الليلي وضبط التكاليف في نظام تشغيلي واحد -- وكيف أصبحت هذه التجربة المصدر الأصلي لمنتج ThakiCloud Paxis.

---

## لمحة عامة عن المكدس: بنية الأتمتة في 4 طبقات

ينقسم المكدس الكامل إلى أربع طبقات.

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
<div class="d3-arch" data-arch-root id="22soloaiteamfullstackops-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 647, "height": 1144, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 40, "y": 24, "w": 512, "h": 156, "label": "الطبقة 1: الواجهة", "lx": 52, "ly": 42}, {"x": 74, "y": 258, "w": 420, "h": 296, "label": "الطبقة 2: التوجيه", "lx": 86, "ly": 276}, {"x": 84, "y": 632, "w": 457, "h": 140, "label": "الطبقة 3: التنفيذ", "lx": 96, "ly": 650}, {"x": 24, "y": 864, "w": 591, "h": 248, "label": "الطبقة 4: التطور الذاتي الليلي", "lx": 36, "ly": 882}], "nodes": [{"id": "CMD", "x": 77, "y": 63, "w": 177, "h": 78, "title": ["22 أمراً مائلاً", "/morning /eod /review", "/ship /debug"]}, {"id": "HOOK", "x": 309, "y": 63, "w": 205, "h": 78, "title": ["12 ربطاً", "UserPromptSubmit · Stop ·", "PreToolUse"]}, {"id": "GATE", "x": 193, "y": 297, "w": 191, "h": 62, "title": ["بوابة موجّه المهارات", "SRA + تعيين تلقائي BM25"]}, {"id": "RULES", "x": 183, "y": 437, "w": 212, "h": 78, "title": ["36 قاعدة دائمة التفعيل", "التكاليف · التنسيق · توجيه", "النماذج · الأمان"]}, {"id": "SKILLS", "x": 343, "y": 671, "w": 135, "h": 62, "title": ["~1620 مهارة", ".claude/skills/"]}, {"id": "AGENTS", "x": 121, "y": 671, "w": 142, "h": 62, "title": ["55 وكيلاً فرعياً", ".claude/agents/"]}, {"id": "M", "x": 62, "y": 1027, "w": 205, "h": 46, "title": "23:30 دورة أحلام memkraft"}, {"id": "S", "x": 379, "y": 903, "w": 198, "h": 46, "title": "00:00 selfharness-evolve"}, {"id": "E", "x": 322, "y": 1027, "w": 177, "h": 46, "title": "00:15 skill-evolution"}], "edges": [{"src": "CMD", "dst": "GATE", "kind": "data", "curve": [[166, 141], [166, 180], [166, 258], [234, 297]]}, {"src": "HOOK", "dst": "GATE", "kind": "data", "curve": [[412, 141], [412, 180], [412, 258], [343, 297]]}, {"src": "GATE", "dst": "RULES", "kind": "data", "line": [289, 359, 289, 437]}, {"src": "RULES", "dst": "SKILLS", "kind": "data", "curve": [[349, 515], [410, 554], [410, 632], [410, 671]]}, {"src": "RULES", "dst": "AGENTS", "kind": "data", "curve": [[240, 515], [192, 554], [192, 632], [192, 671]]}, {"src": "SKILLS", "dst": "S", "kind": "event", "label": "التطور الليلي", "curve": [[440, 733], [478, 772], [478, 864], [478, 903]], "off": "50%"}, {"src": "S", "dst": "E", "kind": "data", "curve": [[478, 949], [478, 988], [478, 988], [435, 1027]]}, {"src": "E", "dst": "SKILLS", "kind": "data", "curve": [[361, 1027], [279, 926], [279, 818], [352, 733]]}]});
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
      const container = document.getElementById('22soloaiteamfullstackops-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22soloaiteamfullstackops-1';
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

**الطبقة 1 (الواجهة)** هي نقطة التواصل المباشر مع الإنسان. تُشكّل الأوامر المائلة مثل `/morning` و`/eod` و`/review` و`/ship` و`/debug` إيقاع اليوم. تعمل الربطات بهدوء في المساحات البينية. ربط `UserPromptSubmit` يُشغَّل قبل كل طلب، أما ربط `Stop` فيتحقق من ملفات العلامات عند انتهاء المهمة.

**الطبقة 2 (التوجيه)** هي دماغ هذا المكدس. من بين 1620 مهارة، يجب إيجاد المهارة المناسبة للطلب الحالي. بوابة موجّه المهارات تُؤتمت هذه المهمة. المبادئ التفصيلية مشروحة في [توجيه المهارات SRA](/ar/dev/skill-ecosystem-routing-sra/).

**الطبقة 3 (التنفيذ)** هي حيث يجري العمل الفعلي. تُغلّف المهارات سير العمل القابلة للتكرار، فيما يتولى الوكلاء الفرعيون التنفيذ المتوازي والفصل بين الأدوار. يتوزع الوكلاء الخمسة والخمسون على 8 فرق بنية محوَر وأطراف: البحث، والمحتوى، والاستخبارات الاستراتيجية، والحوادث، وشحن الكود، والمعرفة، والاجتماعات، والمبيعات. لكل فريق مُنسّق تحته وكلاء فرعيون متخصصون.

**الطبقة 4 (التطور الذاتي الليلي)** هي الميزة التمييزية الجوهرية لهذا النظام. بينما ينام المهندس، يُحسّن المكدس نفسه بنفسه.

---

## التوجيه في كل لحظة: ما تفعله بوابة المهارات

جميع مهارات 1620 موجودة تحت `.claude/skills/`، لكنها لا تُحمَّل كلها في كل دورة. فعل ذلك وحده كفيل بتبديد الميزانية على تكلفة السياق. إذا افترضنا أن وصف المهارة الواحدة يُكلّف 300-500 رمز [تقديري]، فإن تحميلها جميعاً يستهلك مئات الآلاف من الرموز في كل دورة. عوضاً عن ذلك، يُضيّق `skill-router-gate.py` -- المرتبط بربط `UserPromptSubmit` -- المرشحين عبر بحث BM25 ويُدرجهم في السياق.

تؤدي البوابة ثلاثة أدوار.

أولاً، **التصفية المسبقة**. الدورات التي لا تحتاج إلى مهارة -- التحيات، والتأكيدات، والأوامر الصرفة -- تمر فوراً دون أي استهلاك للرموز. تشغيل BM25 على كل طلب سيكون هو نفسه تكلفةً.

ثانياً، **حقن المرشحين**. عند تصنيف دورة ما على أنها تنفيذية، يُضاف كتلة `🧭 مرشحو موجّه المهارات` إلى السياق. يرى النموذج هذا التلميح ويختار المهارة المناسبة. تُقصر المرشحات على 5 مرشحين، وإذا تعادل مرشحان أو أكثر، يُطلب من المستخدم التأكيد.

ثالثاً، **منع التطابق القسري**. لا تُختار مهارة لمجرد أن اسمها يتداخل جزئياً. إذا كانت أعلى درجة دون عتبة التأهل، يُمرَّر التنفيذ إلى المسار الأصلي. في بيئة من 1620 مهارة، أكثر حالات الفشل شيوعاً هي تدخّل مهارة غير ذات صلة كضجيج. مبادئ تصميم هذا الموجّه التفصيلية مشروحة في [توجيه المهارات SRA](/ar/dev/skill-ecosystem-routing-sra/).

تنطبق القواعد الدائمة البالغة 36 قاعدة على جميع المهام بمعزل عن التوجيه. ضبط التكاليف، وحتمية تنسيق Slack، وجدول توجيه النماذج، وانضباط رموز الإخراج -- هذه القواعد لا تُطلب من النموذج بل يُطبّقها الكود.

على سبيل المثال، جاء حقل `quality_gate` في مهارة محتوى مجمّع بثلاثة أشكال مختلفة في مرة من المرات: `"passed"` و`True` و`{...}`. أعطِ النموذج حرية وسيُخرج Sonnet نتائج مختلفة في كل استدعاء. الآن يقيس الكود مباشرةً بـ`len()` ويُجري فحوصات العتبات. لا يُوثق بالأرقام التي يُبلّغ عنها النموذج ذاتياً.

الأوامر المائلة البالغة 22 أمراً هي نوع من الماكروهات تعمل فوق هذا التوجيه. يُشغّل `/morning` مزامنة git لبداية اليوم، ثم إيجاز Google Workspace، ثم خط أنابيب الأسهم بالتسلسل. يجمع `/eod` مزامنة Cursor وإرسال الإصدار وملخص Slack. لا يحتاج الإنسان إلى تذكّر الترتيب في كل مرة.

---

## تطور كل ليلة: حلقة launchd الليلية

هذا هو الجزء الأكثر إثارة للدهشة. بينما ينام المهندس، تعمل ثلاث وظائف launchd بالتسلسل.

**23:30 دورة أحلام memkraft.** تستخلص الأفكار والدروس والأنماط من محادثات اليوم وتعكسها على بنية الذاكرة. دون أن يُسجّل المهندس أي شيء يدوياً، يُحوّل النظام تجربة اليوم إلى سياق الغد.

**00:00 selfharness-evolve.** يُحلّل مقاييس أداء المهارات الحالية ويُقيّم جودة الأوصاف، وتعارضات المشغّلات، وتكرار الاستخدام. يُحدد المهارات التي تحتاج إلى تحسين ويُولّد مقترحات التحسين. تعمل هذه الوظيفة دائماً على launchd المحلي، وليس على routine السحابة أبداً. في صناديق رمل السحابة، لا يمكن لـbash أن يعمل بشكل صحيح وقد تُزوَّر البوابات.

**00:15 skill-evolution.** تُطبّق ما اقترحه selfharness. تُنقّح أوصاف المهارات، وتُولّد مهارات جديدة عند اكتشاف أنماط جديدة، وتُنظّف المحتوى الذي لم يعد صالحاً.

المبادئ التفصيلية لحلقة التطور الذاتي مشروحة بشكل منفصل في [هارنس التطور الذاتي الليلي](/ar/research/self-evolving-harness-nightly/).

ثمة مبدأ تصميم مهم هنا. هذه الوظائف الليلية مبدعة في محتوى المهارات، لكن الكود يمتلك التنسيق. لا يكتب النموذج JSON يدوياً ولا يُبلّغ ذاتياً عن أحكام الجودة. يقيس الكود بـ`len()`، ويتحقق بالتعبيرات النمطية (regex)، ويُعيد إرسال أي شيء يقل عن العتبة. الطريقة الوحيدة لجعل نموذج من مستوى Sonnet يُنتج تنسيقاً متسقاً عبر مهام الدُّفعات المتكررة هي إزالة الحرية منه.

---

## منع تسرب التكاليف: ضوابط أمان من 4 طبقات

كان ثمة يوم وصلت فيه تكاليف الذكاء الاصطناعي اليومية إلى 705 دولارات. جلسة مراقبة واحدة (9.4 ساعات، 1145 دورة) استأثرت بـ54% من الإجمالي. ضوابط الأمان الأربع الطبقات المستخدمة اليوم ظهرت من ذلك الحادث. الأرقام التفصيلية منشورة في [ضوابط توجيه تكاليف LLM](/ar/llmops/llm-cost-routing-guardrails/).

**الطبقة 1: جدول توجيه النماذج.** الاستكشاف وقراءة الملفات وgrep تستخدم haiku (~1x). الترميز والمراجعة وكتابة الاختبارات تستخدم sonnet (~4x). الهندسة المعمارية والاستدلال متعدد الخطوات المعقد يستخدمان opus (~19x). يجب تحديد معامل `model` دائماً عند استدعاء أداة Agent. الإغفال يُشغّل النموذج على النموذج الافتراضي للجلسة (أعلى تكلفة). الوكلاء الفرعيون من نوع haiku لا يُولّدون وكلاء فرعيين إضافيين أبداً. إذا لم تُحلّ مهمة بواسطة haiku، فإن المهمة قد صُنّفت بشكل خاطئ.

**الطبقة 2: قاعدة 2K رمز.** أي استدعاء أداة متوقع أن يُعيد أكثر من 2K رمز يُفوَّض إلى وكيل فرعي. يقرأ الوكيل الفرعي ويعالج ويُعيد الملخص فقط. يحتفظ السياق الرئيسي بالملخص ومسار الملف فحسب. تُضغط مصفوفات JSON الكبيرة بأكثر من 50% باستخدام headroom SmartCrusher قبل إدراجها. استجابات أدوات MCP هي المصدر الخفي الأكبر لتكلفة السياق. قراءات صفحات Playwright، واستجابات GitHub API، وقراءات خيوط Notion يمكنها إفراغ آلاف الرموز دفعةً واحدة. أي شيء يتجاوز 200 سطر يُحفظ في `/tmp/ctx-{task-id}.json`، ولا يصل إلى السياق الرئيسي سوى المخطط والعيّنة.

**الطبقة 3: حظر الاستطلاع الدوري.** تشغيل مراقبة على مدار 24 ساعة كحلقة ساخنة لـClaude محظور. مهام الاستطلاع الدوري كلقطات الأسعار ومقارنات الحالة وفحوصات الصحة تعمل كوظائف cron من launchd وترسل تنبيه Slack فقط عند اكتشاف شذوذات. يحقق ذلك نفس الأثر بتكلفة صفر دولار لـClaude. الجلسة التي استمرت 9.4 ساعات واستهلكت 381 دولاراً أرست هذا المبدأ.

**الطبقة 4: تصعيد المراجعة الراجعة.** تبدأ المهارات المجدولة بـsonnet افتراضياً. يتتبع `skill_model_policy.json` النموذج وسلسلة الفشل لكل مهارة. إذا فشلت مهارة `max_fail_streak` مرات متتالية، تُرقَّى تلك المهارة وحدها تلقائياً إلى opus ويُرسل إشعار إلى Slack `#h-report`. تُعيد دورة العمل النظيفة ضبط السلسلة على الصفر. بدلاً من ترقية كل شيء إلى opus، تُرقَّى فقط المهارات التي ثبت عملياً أن لديها مشكلة في الجودة.

مع تشابك هذه الطبقات الأربع، يبقى يوم العمل النموذجي الآن مسيطراً عليه بـsonnet. يُنتج نفس حجم المخرجات بتكلفة أقل بكثير. الأرقام الكاملة لتصميم ضبط التكاليف منشورة في [ضوابط توجيه تكاليف LLM](/ar/llmops/llm-cost-routing-guardrails/).

تُعدّ نظافة السياق مهمة أيضاً. قراءة نفس الملف مرات عديدة خلال جلسة واحدة يُراكم رموز `cache_read`. إضافة بادئة `cd` غير ضرورية إلى الأوامر ذات المسارات المطلقة يفعل الشيء ذاته. تعمل أوامر `git` مباشرةً على شجرة العمل الحالية، لذا لا تحتاج إلى `cd` أبداً. تتراكم هذه العادات الصغيرة لتخفض تكلفة الجلسة بشكل ملحوظ [تقديري].

---

## هذا هو المنتج: Paxis ومنصة الذكاء الاصطناعي

أسلوب التشغيل المنفرد هذا هو بالضبط ما تُحوّله ThakiCloud إلى منتج تحت اسم Paxis. الهدف جعل وقت تشغيل الوكيل المستقل وبيئة المهارات والتطور الذاتي والحوكمة وضبط التكاليف متاحةً لأي مهندس.

منظومة التشغيل الموصوفة حتى الآن تُثبت شيئين.

الأول هو **أن هذا الأسلوب التشغيلي يعمل فعلاً**. ليس مفهوماً نظرياً أو ورقة بحثية -- بل نظام يستخدمه مهندس منفرد يومياً. حلقة التطور الليلية تعمل، وضوابط التكاليف تُقيّد الإنفاق، والأوامر المائلة تُنشئ إيقاع اليوم.

الثاني هو **أن هذا الأسلوب قابل للتوسع**. المهندس المنفرد الذي يُدير 1620 مهارة لا يفعل ذلك بلمس كل مهارة يدوياً. النظام يتطور بنفسه، والموجّه يجد المهارة الصحيحة، وضوابط الأمان تحمي الميزانية. هذا الهيكل يعمل بالطريقة ذاتها عند التوسع إلى فريق.

Paxis هو عمل تحويل هذه التجربة إلى منصة. يُعرّف المشغلون المهارات، ويُهيّئون الوكلاء، ويضعون سياسات التكاليف -- ثم يتولى وقت التشغيل الباقي. تُضيف منصة الذكاء الاصطناعي فوق ذلك تنسيق أحمال العمل القائم على K8s (Kueue وArgoCD).

---

## القيود والدروس المستفادة

للصراحة التامة.

**1620 مهارة هي أيضاً دين تقني.** المهارات المُتقنة أصول، لكن المهارات المهملة أشباح تستهلك رموز السياق. حين تكون أوصاف المهارات متشابهة جداً، يصاب الموجّه بالارتباك. حلقة التطور الليلية تُنظّف هذا الدين، لكن الأساس يقتضي تحديد intent وboundary واضحين عند إنشاء المهارة.

**التطور الذاتي الليلي بطيء.** يستغرق الأمر أسابيع لتراكم تغييرات ذات معنى خلال ليلة واحدة. التحولات الجذرية في الاتجاه تستلزم تدخلاً بشرياً مباشراً. التطور الذاتي يُحسّن تدريجياً في الاتجاه الحالي -- لا يُغيّر الاتجاه.

**ضوابط التكاليف ليست مثالية أيضاً.** إذا أفرغت أداة MCP آلاف الرموز في استجابة واحدة، يتلوث السياق فوراً في غياب قواعد الصندوق الرملي. لا تتكاثف ضوابط الأمان في لحظة التصميم، بل باستخلاص الدروس بعد وقوع المشكلة وتضمينها.

**المزامنة بين أجهزة متعددة تتطلب انضباطاً.** إذا تفرّق جهاز المنزل وجهاز المكتب على فرع ميزات، فإن تحديثات الأمس على جهاز المنزل لن تظهر في جلسة المكتب اليوم. في الواقع، جرت جلسة على فرع ميزات يتأخر 25 إيداعاً عن origin/main، فلم تنعكس تعليمات الاستراتيجية المطبّقة اليوم السابق مما أفضى إلى أحكام خاطئة. كل العمل يجري على main، وكل مهمة مكتملة يجب رفعها (push) فوراً. بسيط، لكن إهماله يُفضي إلى اتخاذ قرارات بناءً على كود قديم. أصبحت عادةً تشغيل `git log --oneline HEAD..origin/main` قبل بدء أي جلسة.

**من السهل الاستهانة بتكلفة الفرصة للمهارات.** إنشاء مهارة يبدو فوراً كإضافة أصل. لكن المهارة، لحظة دخولها الفهرس، تدفع تكلفة سياق الوصف في كل جلسة. مهارتان متشابهتان تُربكان الموجّه. قبل إنشاء مهارة، يجب أن يكون السؤال الأول: "هل سيُخطئ الوكيل فعلاً بدونها؟" إذا كانت الإجابة لا، فسطر قاعدة واحد يكفي.

---

منظومة التشغيل الموصوفة في هذه المقالة لم تُبنَ في يوم واحد. إنها تراكم مواجهة المشكلة، واستخلاص الدرس، وتضمينه في قاعدة أو مهارة. الدروس المسجّلة بصيغة `2026-XX-XX حادثة:` متناثرة في جميع ملفات القواعد البالغة 36 ملفاً. قراءة رأس أي قاعدة تُخبرك فوراً عن أي عطل نشأت منه.

إذا أردت تشغيل فريق ذكاء اصطناعي منفرد، فأول ما يجب الاستثمار فيه هو جودة المهارات وضوابط التكاليف. ليس الميزات البراقة -- الرافعة الحقيقية هي التوجيه الذي يعمل بصمت وحلقة التطور التي تُحسّن نفسها ليلاً. أرجو أن تكون هذه المقالة مرجعاً مفيداً لمن يفكر في أتمتة بهذا الحجم.

في المقالة التالية، أعتزم تناول مبادئ تصميم بيئة مهارات Paxis -- ولا سيما سبب أهمية التمييز بين الهارنس الرفيع والمهارة السمينة.
