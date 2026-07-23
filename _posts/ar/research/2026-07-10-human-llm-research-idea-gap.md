---
title: "أفكار البحث لدى LLM تخسر في الاتساع لا في الجودة"
seo_title: "تحليل الفجوة بين أفكار البحث البشرية وأفكار LLM - Thaki Cloud"
seo_description: "ورقة بحثية من جامعتي Yale وChicago قاست الفجوة بين أفكار البحث البشرية وأفكار LLM عبر 11,683 ورقة بحثية. نستعرض اكتشاف أن نماذج LLM تتركز بمعدل 4 إلى 5 أضعاف على نمط 'الربط'، وما يعنيه ذلك لوكلاء البحث المستقل وتصميم Paxis في ThakiCloud."
excerpt: "قارن باحثون من Yale وجامعة Chicago بين أفكار البحث البشرية وأفكار LLM باستخدام 11,683 ورقة بحثية حقيقية. الخلاصة مفاجئة. مشكلة أفكار LLM ليست في الجودة، بل في الاتساع. تنحصر نماذج LLM في مساحة أضيق بكثير من البشر، وتتركز بمعدل 4 إلى 5 أضعاف على فكرة 'ربط الأبحاث القائمة'."
date: 2026-07-10
tags:
  - research-agents
  - idea-generation
  - llm-evaluation
  - ai-research
  - multi-agent
  - scientific-discovery
categories:
  - research
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/human-llm-research-idea-gap/"
---

عندما نسمع عبارة "وكيل بحثي"، يتخيل معظمنا المشهد نفسه: قراءة الأوراق البحثية، اكتشاف ثغرة، اقتراح فكرة، تشغيل تجارب، ثم كتابة ورقة بحثية. لكن الباحثين في جامعتي Yale وChicago طرحوا سؤالاً أعمق من ذلك. ما مدى الاختلاف بين الأفكار البحثية التي يولّدها LLM وتلك التي حوّلها الباحثون البشريون فعلاً إلى أوراق منشورة، وما حجم هذا الاختلاف؟

خلاصة الورقة البحثية "Measuring the Gap Between Human and LLM Research Ideas" (arXiv 2607.01233) تتعارض مع الحدس السائد. نقطة ضعف أفكار LLM لم تكن ما نسميه عادة "الجودة". الفجوة الحقيقية كانت في الاتساع (range). فكّر LLM ضمن مساحة أضيق بكثير من الباحثين البشريين، وتركّز هذا الضيق بشكل شبه كامل في نمط واحد، وهو فكرة "ربط الأبحاث القائمة ببعضها".

![صورة تجريدية تقابل بين مجموعة نجوم أفكار متناثرة على اتساع كبير ومجموعة نجوم متكتلة في نقطة ضيقة]({{ '/assets/images/human-llm-research-idea-gap-hero.png' | relative_url }})
*تصوير بصري يقابل بين التوزيع الواسع لأفكار البشر والتكتل الضيق لأفكار LLM حول نمط واحد.*

## نظرة عامة

أهمية هذا البحث تنبع من أن وكلاء البحث المستقل لم تعد فكرة بعيدة المنال. تدير فرق عديدة بالفعل حلقات (loops) تُولّد فيها LLM فرضيات، ويُختار جزء منها لتشغيل تجارب تلقائياً. تشغّل ThakiCloud أيضاً حلقة بحثية خاصة بها تسحب فرضيات تجريبية ليلاً من نشاط الوحدات الفرعية (submodules) والاتجاهات، وتضعها في قائمة انتظار، ثم تنفّذها تلقائياً. جودة حلقة كهذه تعتمد في النهاية على مدى تنوّع وجودة البذور التي ينتجها مولّد الأفكار.

هذه الورقة تحلّل بالضبط خصائص تلك البذور بشكل تجريبي. تتجاوز الحكم البسيط بأن "أفكار LLM جيدة" أو "سيئة"، وترسم بدلاً من ذلك موضع كل من البشر وLLM في مساحة الأفكار الممكنة. وما تخبرنا به هذه الخريطة هو ما سنخسره إن استمررنا في الاعتماد على مولّد فرضيات واحد قائم على LLM كما هو حالياً.

## ماذا تم قياسه: تجربة أفكار محكومة

أبرز ما يميز هذه الورقة هو الصرامة المنهجية. الحكم على الأفكار بأنها "جيدة" أو "سيئة" أمر ذاتي ويصعب قياسه مباشرة. تجاوز الباحثون هذه المشكلة عبر تجربة محكومة.

اختاروا أولاً 11,683 ورقة بحثية عالية الجودة من ICLR وICML وNeurIPS وNature Communications. ولكل ورقة، أعادوا هندسة مجموعة صغيرة من الأبحاث السابقة الوثيقة الصلة التي يُرجَّح أنها ألهمت فكرتها الأساسية. ثم أعطوا LLM عناوين وملخصات تلك الأبحاث السابقة فقط، وطلبوا منه توليد فكرة جديدة انطلاقاً من هذه النقطة. بمعنى آخر، أُعطي الباحثون البشريون وLLM نقطة انطلاق واحدة تماماً، وهي المجموعة نفسها من الأبحاث السابقة، والمقارنة تسأل إلى أين يتجه كلٌّ منهما من هناك.

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
<div class="d3-arch" data-arch-root id="0humanllmresearchideagap-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 479, "height": 974, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 140, "y": 24, "w": 191, "h": 94, "title": ["11,683 ورقة بحثية عالية", "الجودة", "ICLR, ICML, NeurIPS,", "Nature Comm"]}, {"id": "B", "x": 137, "y": 196, "w": 198, "h": 46, "title": "الفكرة الأساسية لكل ورقة"}, {"id": "C", "x": 137, "y": 320, "w": 198, "h": 62, "title": ["الأبحاث السابقة الملهمة", "مستخرجة بالهندسة العكسية"]}, {"id": "D", "x": 161, "y": 460, "w": 149, "h": 46, "title": "نقطة انطلاق واحدة"}, {"id": "E", "x": 263, "y": 584, "w": 184, "h": 62, "title": ["البشر: الفكرة المنشورة", "فعلاً"]}, {"id": "F", "x": 24, "y": 584, "w": 184, "h": 62, "title": ["LLM: فكرة جديدة مولّدة", "من العناوين والملخصات"]}, {"id": "G", "x": 130, "y": 724, "w": 212, "h": 78, "title": ["تصنيف ثنائي المحاور لذائقة", "البحث", "نمط الفرصة x منهج البحث"]}, {"id": "H", "x": 168, "y": 880, "w": 135, "h": 62, "title": ["مقارنة التوزيع", "البشر مقابل LLM"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [236, 118, 236, 196]}, {"src": "B", "dst": "C", "kind": "data", "line": [236, 242, 236, 320]}, {"src": "C", "dst": "D", "kind": "data", "line": [236, 382, 236, 460]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[280, 506], [355, 545], [355, 545], [355, 584]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[191, 506], [116, 545], [116, 545], [116, 584]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[355, 646], [355, 685], [355, 685], [295, 724]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[116, 646], [116, 685], [116, 685], [176, 724]]}, {"src": "G", "dst": "H", "kind": "data", "line": [236, 802, 236, 880]}]});
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
      const container = document.getElementById('0humanllmresearchideagap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0humanllmresearchideagap-1';
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

معيار المقارنة كان تصنيفاً يقسّم "ذائقة البحث" إلى محورين. الأول هو نمط الفرصة، أي نوع الثغرة التي تحفّز العمل البحثي. والثاني هو منهج البحث، أي المنهجية التي تعالج بها تلك الثغرة. رسم الباحثون أفكار البشر وLLM على هذا النظام الإحداثي، وقاسوا كمياً مدى تداخل التوزيعين ونقاط تباعدهما. شملت النماذج التي جرى تقييمها عائلات LLM الرئيسية بما فيها Claude وGemini وGPT وDeepSeek وQwen.

## الاكتشاف الجوهري: الفجوة في الاتساع لا في الجودة

يمكن تلخيص النتيجة بجملة واحدة. أفكار LLM المولَّدة شغلت مساحة أضيق بكثير من أفكار البشر ضمن النظام الإحداثي لذائقة البحث.

يظهر هذا الضيق بأوضح صوره في نمط "الربط" (connection). نمط الربط يؤطّر دافعه بأن "أدبيات أو أساليب أو أدلة متفرقة تحتاج إلى ربطها ببعضها"، ويطوّر منهجه عبر دمج مقاربات قائمة أو التوفيق بينها أو توحيدها. بعبارة بسيطة، هي أفكار من نوع "ماذا لو جمعنا بين A وB".

الأرقام تُظهر الفجوة بوضوح تام. لم تتجاوز نسبة أفكار البشر التي كان دافعها نمط الربط 12.1%، ولم تتجاوز نسبة من استخدم الدمج أو التوحيد كمنهج أساسي 5.1%. في المقابل، تراوحت هذه النسب عبر تسعة نماذج LLM رئيسية بين 47.1% و64.2% وبين 22.5% و38.7% على التوالي، أي بمعدل يفوق 4 إلى 5 أضعاف الاعتماد على هذا النمط.

كانت أفكار الباحثين البشريين موزّعة على اتساع أكبر بكثير. أفكار تسعى لتفسير آلية ما، وأفكار تتعمّق في حالات الفشل، وأفكار تحاول قياس أدلة، وأفكار تبني أنظمة، وأفكار تحسّن الكفاءة، جميعها ظهرت بنسب متقاربة نسبياً. أما LLM، فبدلاً من الانتشار عبر هذا الطيف، استمر في الاستقرار داخل الوادي الضيق نفسه لأفكار "الربط" الآمنة والمقنعة ظاهرياً.

## لماذا تنجذب LLM إلى "الربط"

هذا التركّز ليس صدفة، بل هو بنيوي. فكرة "ادمج A وB القائمين" هي الخطوة التالية الأكثر أماناً التي يمكن اشتقاقها من مجموعة معطاة من الأبحاث السابقة، حتى على مستوى التنبؤ بالرمز التالي (next token). فهي منخفضة المخاطر، ومقنعة دائماً، وتبدو جديدة على السطح. أما فكرة من نوع "ما هي الآلية الخفية وراء هذه الظاهرة"، فتتطلب قفزة تتجاوز النص المعطى. تميل LLM إحصائياً إلى التقارب نحو الخيار الأول.

المشكلة أن الاختراقات العلمية الحقيقية غالباً ما تأتي من الخيار الثاني. الأفكار التي تصل بين أشياء قائمة تميل إلى إنتاج تحسّن تدريجي، بينما الاكتشافات التي تغيّر قواعد اللعبة تبدأ عادة من نوع مختلف من الأسئلة. إذا اعتمدنا على مولّد فرضيات واحد قائم على LLM كما هو، سننحبس دون وعي داخل واد واحد من مساحة الأفكار.

## تداعيات على منتجات ThakiCloud

يمنحنا هذا الاكتشاف توجيهاً تصميمياً مباشراً للوكلاء المستقلين الذين نشغّلهم.

**عدسة Paxis: فرض التنوّع عبر الـharness.** Paxis هو Agent-Native Cloud الخاص بـThakiCloud، ويتعامل مع تنسيق متعدد الوكلاء قائم على DAG ومهارات ذاتية التطور كموارد من الدرجة الأولى. درس هذه الورقة واضح: ترك توليد الأفكار لنموذج واحد يحصره داخل وادي "الربط"، لذا يجب ألا نترك التنوّع للصدفة، بل يجب فرضه عبر الـharness. عملياً، يعني هذا ثلاثة أمور. أولاً، اعتماد نهج mixture-of-agents يجمع مرشحين من عائلات نماذج مختلفة (Claude وGemini وGPT وDeepSeek وQwen) لتقليل تحيّز النموذج الواحد. ثانياً، تخصيص عدسات مختلفة صراحةً للمشكلة نفسها، كالتفسير الآلي وتحليل الفشل وتحسين الكفاءة، بحيث لا تتقارب الأفكار على نمط الربط وحده. ثالثاً، عدم الوثوق بالأفكار المولَّدة كما هي، بل تصفيتها عبر مرحلة تحقق عدائي (adversarial verify)، بما يمنع الأفكار المقنعة ظاهرياً لكنها ضيقة من عبور خط الأنابيب.

عندما تسحب ThakiCloud فرضياتها من حلقتها البحثية الليلية، يتحوّل هذا المبدأ إلى انضباط تشغيلي فعلي. فبدلاً من الحصول على فرضية واحدة من موجّه (prompt) واحد، يمنع التفرّع عبر عدسات متعددة والتقارب لاحقاً عبر مرحلة التحقق نمط الفشل "الاتساع الضيق" الذي قاسته هذه الورقة مباشرة.

**عدسة ai-platform: تكلفة البنية التحتية لتنوّع النماذج.** تشغيل عدة عائلات نماذج في آن واحد لضمان تنوّع الأفكار يتطلب طبقة قادرة على خدمة نماذج مفتوحة الأوزان غير متجانسة بكفاءة عبر عدة مستأجرين (tenants). تشغّل منصة ai-platform الخاصة بـThakiCloud مجموعة نماذج غير متجانسة بكفاءة من حيث التكلفة عبر Kubernetes وجدولة GPU بواسطة Kueue وخدمة عبر vLLM. ما يكشفه هذا هو أن تنوّع الأفكار، وهو هدف نوعي، لا يتحقق إلا فوق بنية تحتية للخدمة قادرة على تشغيل نماذج متنوعة بتكلفة منخفضة وبالتوازي.

## قيود وحجج مضادة

نقبل هذه النتيجة، لكن مع بعض التحفظات.

أولاً، التصنيف نفسه هو زاوية نظر واحدة. تقسيم "ذائقة البحث" إلى نمط فرصة ومنهج بحث مفيد، لكنه ليس التفكيك الوحيد الممكن. تصنيف مختلف قد يُظهر شكلاً مختلفاً لهذه الفجوة. استنتاج "الاتساع ضيق" نسبي إلى هذا النظام الإحداثي تحديداً.

ثانياً، اتساع الأفكار الأكبر ليس بالضرورة أمراً أفضل. جزء كبير من تنوّع أفكار البشر قد ينتهي في اتجاهات فاشلة في النهاية، وميل LLM نحو أفكار "الربط" قد يكون في الواقع خياراً أكثر أماناً بمعدل نجاح تنفيذي أعلى. قاست هذه الورقة توزيع الأفكار، لا الأفضلية النسبية لنتائج تنفيذها. تبقى العلاقة بين الاتساع والنتائج سؤالاً منفصلاً.

ثالثاً، هناك حساسية تجاه تصميم الموجّه (prompt). لو طُلب من LLM صراحةً "أنتج نوعاً من الأفكار مختلفاً تماماً عمّا هو قائم"، ربما كان التوزيع أوسع. بمعنى آخر، جزء من هذه الفجوة قد يكون نتاج الموجّه الافتراضي وليس قيداً جوهرياً في النموذج، وكون هذا الأمر قابلاً على الأرجح للتصحيح بدرجة كبيرة عبر الـharness هو، من الناحية العملية، الجانب المشجّع في هذه القصة.

ومع ذلك، التوجيه العملي واضح. بناء خط أنابيب للبحث المستقل أو توليد الأفكار على نموذج واحد وموجّه واحد يحصره داخل وادٍ ضيق. فرض التنوّع عبر الـharness وإغلاق الحلقة بمرحلة تحقق هو الطريق المباشر لتجنّب نمط الفشل الذي قاسته هذه الورقة.

## المصادر

- [Measuring the Gap Between Human and LLM Research Ideas (arXiv 2607.01233)](https://arxiv.org/abs/2607.01233)
- [الورقة الكاملة (HTML)](https://arxiv.org/html/2607.01233v1)
- [مراجعة أدبية (The Moonlight)](https://www.themoonlight.io/en/review/measuring-the-gap-between-human-and-llm-research-ideas)
