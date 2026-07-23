---
title: "الذاكرة الإجرائية لدى الوكيل: ما وراء استرجاع المطالبات"
excerpt: "إدراج المهارات ضمن المطالبة (Prompt) الموجهة إلى الوكيل يستهلك مساحة السياق وينكسر بسهولة. تنقل الأبحاث الحديثة الذاكرة الإجرائية من قوالب المطالبات إلى بنية تفصل بين البناء والاسترجاع والتحديث، بل وتتجه إلى سياسات عصبية بارامترية. تستعرض هذه المقالة خريطة هذا التحول بالتركيز على Memp ومعيار AFTER، وتبين كيف تجسّد بيئة المهارات (Skill Harness) في Paxis التابعة لـThakiCloud هذا التوجه عملياً."
seo_title: "الذاكرة الإجرائية للوكيل: تخزين المهارات إلى ما وراء استرجاع المطالبات | Thaki Cloud"
seo_description: "تستعرض هذه المقالة أبحاث الذاكرة الإجرائية لعملاء LLM بالتركيز على Memp (arXiv 2508.06433) ومعيار AFTER (arXiv 2606.23127)، وتتناول بنية البناء والاسترجاع والتحديث، والتحول نحو النماذج البارامترية، وتطبيق بيئة مهارات Paxis التابعة لـThakiCloud."
date: 2026-07-02
last_modified_at: 2026-07-02
tags:
  - agent-memory
  - procedural-memory
  - llm-agents
  - skills
  - agent-skills
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "brain"
canonical_url: "https://thakicloud.com/tech-blog/ar/research/agent-procedural-memory-beyond-retrieval/"
categories:
  - research
published: false
---

## نظرة عامة

من يُشغّل عملاء LLM لفترات طويلة يصطدم بالعقبة نفسها مراراً. يعيد الوكيل الاستدلال من الصفر في كل مرة، ويتلمس طريقه من جديد عبر إجراء سبق أن حلّه في الأسبوع الماضي. الحل الشائع هو دفع المهارات المستخدمة بكثرة كاملةً داخل المطالبة. غير أن هذا الأسلوب هشّ لسببين. أولاً، كلما زاد عدد المهارات ازداد استهلاك نافذة السياق، فتقلّ المساحة المتبقية للمهمة نفسها. ثانياً، تنكسر قوالب المطالبات بسهولة عند أي تغيّر طفيف في الظرف.

تعيد أبحاث ذاكرة الوكلاء الحديثة النظر في هذه المشكلة من زاوية **الذاكرة الإجرائية (procedural memory)**. فكما تحمل الذاكرة الإجرائية عند الإنسان حركات ماهرة تُنفَّذ دون وعي، مثل ركوب الدراجة، تختزل الذاكرة الإجرائية لدى الوكيل إجراءات تنفيذ المهام المتكررة في صورة قابلة لإعادة الاستخدام. جوهر هذا التوجه هو نقل المعرفة الإجرائية إلى **ما وراء استرجاع المطالبات**، أي إلى بنية منفصلة للتخزين والاسترجاع والتحديث، بل والانتقال إلى سياسات عصبية داخل بارامترات النموذج نفسه.

تستعرض هذه المقالة خريطة هذا التحول بالاعتماد على أبحاث موثّقة، وتُختتم بربط هذا التوجه البحثي بأسلوب Paxis، السحابة الأصيلة للوكلاء (Agent-Native Cloud) التابعة لـThakiCloud، التي تتعامل مع المهارات بوصفها موارد من الدرجة الأولى وتُجسّد بذلك هذا التوجه البحثي عملياً.

## ما هي الذاكرة الإجرائية

من منظور معرفي، تُقسَّم الذاكرة عادة إلى ثلاثة أنواع: الذاكرة الدلالية (semantic) التي تحفظ الحقائق، والذاكرة العرضية (episodic) التي تحفظ الأحداث، والذاكرة الإجرائية (procedural) التي تحفظ الطرق. وفي أدبيات الوكلاء، تتولى الذاكرة الإجرائية مسؤولية الإجابة عن سؤال "كيف يُنفَّذ الأمر"، إذ تُجرّد تسلسلات الحركة المعقّدة إلى أنماط قابلة لإعادة الاستخدام، بما يتيح التنفيذ دون تخطيط من الصفر في كل مرة.

المشكلة أن هذه المعرفة الإجرائية توجد حالياً، في معظم الوكلاء، في واحد من ثلاثة أشكال: إما مكتوبة يدوياً، أو محشورة في قوالب مطالبات هشّة، أو متشابكة ضمنياً في بارامترات النموذج بتكلفة تحديث باهظة. وما تستهدفه الأبحاث هو رفع هذه المعرفة إلى مرتبة **كائن من الدرجة الأولى قابل للتعلّم والتحديث**.

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
<div class="d3-arch" data-arch-root id="ralmemorybeyondretrieval-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 362, "height": 932, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 31, "y": 24, "w": 184, "h": 46, "title": "مسارات التنفيذ السابقة"}, {"id": "B", "x": 56, "y": 148, "w": 135, "h": 62, "title": ["استخلاص الإجراء", "Build"]}, {"id": "C", "x": 114, "y": 288, "w": 138, "h": 52, "title": "شكل التخزين"}, {"id": "D", "x": 210, "y": 418, "w": 120, "h": 62, "title": ["غير بارامتري", "نص برمجي"]}, {"id": "E", "x": 35, "y": 418, "w": 120, "h": 62, "title": ["بارامتري", "سياسة عصبية"]}, {"id": "F", "x": 101, "y": 558, "w": 163, "h": 62, "title": ["الاسترجاع والاختيار", "Retrieval"]}, {"id": "G", "x": 123, "y": 698, "w": 120, "h": 46, "title": "تنفيذ المهمة"}, {"id": "H", "x": 24, "y": 822, "w": 198, "h": 78, "title": ["التحديث وفق التغذية", "الراجعة", "إضافة وتعديل وحذف Update"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [123, 70, 123, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[149, 210], [183, 249], [183, 249], [183, 288]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[218, 340], [270, 379], [270, 379], [270, 418]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[148, 340], [95, 379], [95, 379], [95, 418]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[270, 480], [270, 519], [270, 519], [221, 558]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[95, 480], [95, 519], [95, 519], [144, 558]]}, {"src": "F", "dst": "G", "kind": "data", "line": [183, 620, 183, 698]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[183, 744], [183, 783], [183, 783], [153, 822]]}, {"src": "H", "dst": "B", "kind": "data", "curve": [[55, 822], [-13, 659], [-13, 379], [63, 210]]}]});
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
      const container = document.getElementById('ralmemorybeyondretrieval-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ralmemorybeyondretrieval-1';
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

## ما وراء استرجاع المطالبات: فصل التخزين والاسترجاع والتحديث

أبرز الأبحاث التي تناولت هذا التوجه بشكل مباشر هي **Memp: Exploring Agent Procedural Memory** (arXiv 2508.06433). يضع Memp الذاكرة الإجرائية كهدف تحسين من الدرجة الأولى، ويقطّر المسارات السابقة إلى طبقتين: تعليمات دقيقة خطوة بخطوة من جهة، وإجراءات عالية المستوى أشبه بنص برمجي من جهة أخرى. كما يفصل حلقة الذاكرة إلى ثلاث مراحل هي **البناء (build) والاسترجاع (retrieval) والتحديث (update)**. وفي مرحلة التحديث، تُضاف العناصر أو تُعدَّل أو تُحذف وفق التغذية الراجعة من التنفيذ.

تكمن أهمية هذا الفصل في كونه مختلفاً جذرياً عن أسلوب حشو المهارات داخل المطالبة. ففي أسلوب المطالبة، يندمج التخزين والاسترجاع في خطوة واحدة، ويكاد مفهوم التحديث ينعدم. أما فصل المراحل الثلاث فيجعل من توقيت إدراج الإجراء أو إزالته، وما ينبغي تصحيحه من الإخفاقات، هدفاً تصميمياً صريحاً. وتشير المصادر إلى أن الاتجاه العام لهذا التوجه يمكن تلخيصه بالانتقال **من قوالب صريحة غير بارامترية إلى سياسات عصبية بارامترية ضمنية** (مسح الذاكرة في Foundation Agents، arXiv 2602.06052). أي أن التوجه يتجاوز مرحلة تخزين الإجراء نصياً واسترجاعه، نحو صهر الخبرة داخل سياسة النموذج نفسها.

## لماذا يهم هذا الآن: صعوبة التقييم

لم يُفهم بعد بشكل كافٍ ما إذا كانت الذاكرة الإجرائية تُنتج فعلاً مهارات صالحة للاستخدام. والبحث الذي يستهدف هذه الفجوة هو **Managing Procedural Memory in LLM Agents** (arXiv 2606.23127)، الذي يقترح معياراً بعنوان **AFTER**. يتألف هذا المعيار من 382 مهمة مؤسسية واقعية موزعة على 6 أدوار وظيفية، و22 مهارة إجرائية، ويقيس مدى قابلية انتقال المهارات عبر المهام والأدوار وبنية النماذج الأساسية.

السؤال الذي يطرحه هذا المعيار هو الجوهر: هل يصلح الإجراء المتعلَّم في موقف معيّن لموقف آخر؟ وهل تبقى المهارة صالحة عند تغيير النموذج؟ فبمجرد تبنّي الذاكرة الإجرائية، نحتاج إلى وسيلة لقياس "هل هذه المهارة قابلة لإعادة الاستخدام فعلاً"، لأن المهارة التي لا تنتقل، حتى لو امتلكت بنية تخزين واسترجاع وتحديث كاملة، لا تختلف في النهاية عن قالب مطالبة باهظ التكلفة.

## دلالات التطبيق على منتجات ThakiCloud

يتخذ هذا التوجه البحثي شكله العملي بالكامل في **Paxis** التابعة لـThakiCloud. Paxis سحابة أصيلة للوكلاء (Agent-Native Cloud) تتعامل مع **المهارات والأدوات والسياسات وسجلات التدقيق** بوصفها موارد من الدرجة الأولى. وهنا تُعد بيئة المهارات (Skill Harness) بمثابة الذاكرة الإجرائية الإنتاجية فعلياً.

- **المقابل العملي للبناء والاسترجاع والتحديث**: تختار بيئة مهارات Paxis أكثر من 960 مهارة عبر BM25 (الاسترجاع)، وتنفّذها ضمن صناديق رمل معزولة، وتحسّنها عبر حلقة تطوّر ذاتي (التحديث). وبذلك يتجسّد فصل المراحل الثلاث الذي طرحه Memp في صورة نظام تشغيلي فعلي.
- **بنية تتجاوز استرجاع المطالبات**: بدلاً من حشو المهارات في المطالبة في كل مرة، يجري استدعاء مهارات موثّقة انتقائياً، مما يوفّر ميزانية السياق ويحافظ على اتساق الإجراء. وهذا يتطابق تماماً مع التوجه الذي تناولته هذه المقالة تحت عنوان "ما وراء استرجاع المطالبات".
- **التقييم والتدقيق**: تدير Paxis مفهوم "القابلية للانتقال" الذي شدّد عليه معيار AFTER من خلال بوابات السياسات وسجلات التدقيق. وبما أن كل مهارة تُتتبَّع من حيث توقيت اختيارها وما نفّذته، يبقى أساس بيانات واضح للتمييز بين الإجراءات القابلة لإعادة الاستخدام وتلك غير القابلة لذلك.

من منظور البنية التحتية، فإن ai-platform هي التي تسند تنفيذ هذه المهارات. ولأن الوكيل ينفّذ المهارات فوق جدولة GPU عبر Kueue وخدمة متعددة المستأجرين، فإن تكلفة تنفيذ الذاكرة الإجرائية تتحول مباشرة إلى مسألة كفاءة في الخدمة. وبذلك يشكّل تقديم الخدمة منخفض التكلفة (ai-platform) الركيزة التي تسند جدوى الوكلاء الاقتصادية (Paxis).

## القيود والاعتراضات

لنقل الذاكرة الإجرائية إلى سياسات عصبية بارامترية ثمن واضح. فالنصوص البرمجية يمكن للبشر قراءتها وتعديلها، أما الإجراءات المنصهرة داخل البارامترات فيصعب تدقيقها وتحديثها. إذ يصعب معرفة ما المخزَّن فعلياً، كما يصعب انتقاء الإجراءات الخاطئة وحذفها. وفي البيئات التي تكون فيها قابلية التفسير أمراً جوهرياً، مثل البيئات الخاضعة للتنظيم أو ذات السيادة الرقمية، يتحول هذا الغموض مباشرة إلى مخاطرة.

كذلك ليس أسلوب الاسترجاع غير البارامتري حلاً شاملاً. فقد يستدعي الاسترجاع إجراءات خاطئة، وقد تتدهور جودة الاختيار كلما اتسع المستودع. وكما تُظهر معايير مثل AFTER، لا تزال قابلية انتقال المهارات في مرحلة تحقق مبكرة، ولا ضمان أن الإجراء الناجح في مجال معيّن سينجح في مجال آخر. الذاكرة الإجرائية اتجاه واعد يجنّب الوكيل البدء من ورقة بيضاء في كل مرة، لكن نضج شكل التخزين وجودة الاسترجاع وسلامة التحديث ومنهجية التقييم معاً هو ما يجعلها أصلاً موثوقاً في الاستخدام العملي.

## المصادر

- [Memp: Exploring Agent Procedural Memory (arXiv 2508.06433)](https://arxiv.org/abs/2508.06433)
- [Managing Procedural Memory in LLM Agents: Control, Adaptation, and Evaluation (arXiv 2606.23127)](https://arxiv.org/abs/2606.23127)
- [Rethinking Memory Mechanisms of Foundation Agents in the Second Half: A Survey (arXiv 2602.06052)](https://arxiv.org/abs/2602.06052)
