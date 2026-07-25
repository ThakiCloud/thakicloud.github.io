---
title: "لقد انتقل مركز الثقل: قراءة منظومة النماذج المفتوحة عبر تقرير ATOM"
excerpt: "يقيس تقرير ATOM النماذج اللغوية المفتوحة عبر التنزيلات واستخدام الاستدلال في مكان واحد، ويُظهر بالبيانات أن النماذج المفتوحة الصينية تجاوزت المعسكر الأمريكي في صيف 2025 ووسّعت الفجوة منذ ذلك الحين. تجاوز Qwen نحو مليار تنزيل تراكمي على Hugging Face، بينما يتصدّر DeepSeek سوق الاستدلال على OpenRouter. نقرأ ما يعنيه هذا التحوّل من منظور ThakiCloud التي تُشغّل بنية تحتية داخلية وسيادية."
seo_title: "قراءة منظومة النماذج المفتوحة عبر تقرير ATOM - Thaki Cloud"
seo_description: "يقيس تقرير ATOM (arXiv 2604.07190) تنزيلات Hugging Face واستخدام الاستدلال على OpenRouter معًا لرسم خريطة منظومة النماذج اللغوية المفتوحة. نلخّص أبرز نتائجه، مليار تنزيل لـ Qwen، وتجاوز الصين منتصف 2025، وتصدّر DeepSeek في الاستدلال، وصعود GPT-OSS، ثم نستخلص الدلالات لمنصة ai-platform من ThakiCloud التي تخدم النماذج المفتوحة في عناقيد متعددة المستأجرين داخل المؤسسة."
date: 2026-07-06
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/atom-report-open-model-ecosystem/"
tags:
  - research
  - open-weight
  - qwen
  - deepseek
  - open-source-llm
  - inference
  - on-prem-llm
  - sovereign-ai
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "flask"
categories:
  - research
published: false
---

## لمن هذه المقالة

هذه المقالة موجّهة إلى المهندسين والقادة التقنيين الذين عليهم أن يقرّروا أي نموذج مفتوح يُشغّلونه على بنيتهم التحتية. إنها لمن يريد تجاوز الانطباعات من نوع "سمعت أن Llama جيد هذه الأيام" والتأكّد بالبيانات مما يُنزّله الناس فعلًا وما يُشغّلون عليه الاستدلال فعلًا. تقرير ATOM عمل نادر يقيس هذين المحورين في مكان واحد، وخلاصته أن مركز ثقل النماذج المفتوحة قد انتقل بوضوح خلال العام الماضي.

## نظرة عامة: لماذا خريطة لمشهد النماذج المفتوحة الآن

حين نتحدّث عن النماذج اللغوية المفتوحة، ننظر عادةً إلى جداول المعايير. لكن لوحة النتائج تخبرنا بما يؤدّي جيدًا لا بما يُستخدَم فعلًا. من الشائع أن يكون النموذج المتصدّر نموذجًا لا ينشره أحد تقريبًا، ومن الشائع بالقدر نفسه أن يكون نموذج بدرجات عادية هو الأكثر تبنّيًا في الميدان. بالنسبة لأي مُشغّل بنية تحتية، فإن الأخير هو الإشارة الحقيقية. فما يمسكه المجتمع بيديه ويضعه في الإنتاج هو ما يحدّد أي منظومة يجب أن نراهن عليها.

يجيب تقرير ATOM (arXiv 2604.07190، نُشر في 8 أبريل 2026) عن هذا السؤال مباشرة. أعدّته Interconnects، ويغطّي نحو 1500 نموذج مفتوح رئيسي، ويربط بين تنزيلات Hugging Face وعدد النماذج المشتقة وحصة سوق الاستدلال ومقاييس الأداء لرسم لقطة للمنظومة بأكملها. تكمن قيمته في كونه خريطة للمنظومة من أعلى إلى أسفل بدلًا من كونه تفاخر منظّمة واحدة بنجاح نموذجها.

## ماذا قاس تقرير ATOM

تبدأ المنهجية بمحاولة تجنّب فخّ المقياس الواحد. فمحاولات اختزال نجاح نموذج مفتوح في رقم واحد تُشوّه دائمًا تقريبًا. إذا نظرت إلى تنزيلات Hugging Face وحدها بولغ في تقدير النماذج ذات مجتمعات الضبط الدقيق النشطة، وإذا نظرت إلى استدعاءات واجهة الاستدلال وحدها بولغ في تقدير النماذج التي استقرّت جيدًا على الاستضافة التجارية. يفصل تقرير ATOM بين الاثنين ويضعهما جنبًا إلى جنب. الأول عدسة تنزيل تُظهر ما يسحبه المطورون ويعبثون به بأنفسهم، والثاني عدسة استدلال تُظهر أين تتدفّق حركة الإنتاج الفعلية.

النقطة الجوهرية أن هاتين العدستين تُظهران صورتين مختلفتين. على مقاييس التنزيل، تتقدّم عائلات النماذج ذات المنظومات المشتقة الكبيرة، وعلى مقاييس الاستدلال يتوزّع الاستخدام بشكل أكثر تساويًا عبر المنظّمات. لا تصبح المنظومة ثلاثية الأبعاد إلا بتراكب الصورتين الملتقطتين من زاويتين مختلفتين. وهذا الموقف المنهجي أمر يؤكّده التقرير مرارًا.

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
<div class="d3-arch" data-arch-root id="reportopenmodelecosystem-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 430, "height": 726, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 110, "y": 24, "w": 191, "h": 62, "title": ["منظومة النماذج المفتوحة", "~1500 نموذج رئيسي"]}, {"id": "B", "x": 228, "y": 164, "w": 170, "h": 94, "title": ["عدسة التنزيل", "تنزيلات Hugging Face", "التراكمية", "+ المشتقات"]}, {"id": "C", "x": 24, "y": 172, "w": 149, "h": 78, "title": ["عدسة الاستدلال", "حصة سوق الاستدلال", "على OpenRouter"]}, {"id": "D", "x": 242, "y": 336, "w": 142, "h": 62, "title": ["ما يمسكه", "المطورون بأيديهم"]}, {"id": "E", "x": 39, "y": 336, "w": 120, "h": 62, "title": ["أين تتدفّق", "حركة الإنتاج"]}, {"id": "F", "x": 114, "y": 476, "w": 184, "h": 62, "title": ["تحليل متقاطع", "= خريطة ثلاثية الأبعاد"]}, {"id": "G", "x": 107, "y": 616, "w": 198, "h": 78, "title": ["الخلاصة الأساسية", "النماذج المفتوحة الصينية", "نقلت مركز الثقل"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[253, 86], [313, 125], [313, 125], [313, 164]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[158, 86], [99, 125], [99, 125], [99, 172]]}, {"src": "B", "dst": "D", "kind": "data", "line": [313, 258, 313, 336]}, {"src": "C", "dst": "E", "kind": "data", "line": [99, 250, 99, 336]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[313, 398], [313, 437], [313, 437], [253, 476]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[99, 398], [99, 437], [99, 437], [158, 476]]}, {"src": "F", "dst": "G", "kind": "data", "line": [206, 538, 206, 616]}]});
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
      const container = document.getElementById('reportopenmodelecosystem-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'reportopenmodelecosystem-1';
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

## النتيجة الأساسية: النماذج المفتوحة الصينية أعادت تشكيل المشهد

أثقل نتائج التقرير هي انقلاب في التوازن الإقليمي. تجاوزت النماذج المفتوحة الصينية المعسكر الأمريكي في صيف 2025، ووسّعت الفجوة منذ ذلك الحين بدلًا من إغلاقها. ليس هذا إصدارًا لامعًا واحدًا يتقدّم لفترة وجيزة، بل تحوّل بنيوي يُلاحَظ على محوري التنزيل والاستدلال معًا.

على محور التنزيل، الاسم الذي يرمز إلى هذا التحوّل هو Qwen. عائلة Qwen من Alibaba هي أكثر عائلة نماذج مفتوحة استخدامًا، إذ بلغت نحو مليار تنزيل تراكمي حتى مارس 2026. ويتجاوز عدد مشتقّاتها 100 ألف. تتبعها عائلات أخرى مثل Llama وDeepSeek وKimi، لكن الفجوة مع Qwen كبيرة. حمل عائلة واحدة لمنظومة مشتقة بهذا الحجم يعني أن طبقة المطورين الذين يُجرون الضبط الدقيق ويعيدون التوزيع فوقها أكثر سماكة بكثير. تعمل المنظومات بهذا النوع من الزخم. فالاستخدام الكثيف يُراكم الأدوات والوصفات، ووفرة الأدوات تدفع مزيدًا من الاستخدام.

يبدو محور الاستدلال مختلفًا قليلًا. على قياسات OpenRouter، يتوزّع الاستخدام عبر المنظّمات أكثر من تركّزه في عائلة واحدة، وضمن هذا التوزّع يتصدّر DeepSeek. يتقدّم Qwen في التنزيلات بينما يحمل DeepSeek حضورًا قويًا في الحركة الفعلية، وهذا التباين هو بالضبط سبب استحقاق العدستين قراءة منفصلة. فالنماذج التي يُنزّلها الناس للتجريب ليست بالضرورة النماذج التي يضعونها في الخدمة ويدفعون لتشغيلها.

لا يغطّي التقرير النماذج التي في مركز الاهتمام فقط. بل يتتبّع أيضًا صعود GPT-OSS، عائلة OpenAI المفتوحة الأوزان؛ والنفوذ المتنامي لمنظّمات صينية من الفئة الوسطى مثل Moonshot وZ.ai وMiniMax؛ وإشارات إلى إحراز المعسكر الأمريكي تقدّمًا متجدّدًا في النماذج المفتوحة. الملاحظة بأن المشهد تصنعه هذه الطبقة الوسطى السميكة لا بضعة أسماء في القمة تُحذّر بهدوء من خطورة استراتيجية تتّكئ على نموذج نجم واحد.

## التنزيلات والاستدلال، عدستان مختلفتان

تستحق هذه النقطة نظرة أعمق، لأن الفرق بين هاتين العدستين بالنسبة لمن يصمّم بنية تحتية ليس مسألة إحصاء بل قرار عملي.

مقاييس التنزيل مفيدة لقراءة حيوية المنظومة واتجاهها المستقبلي. فإذا انفجر عدد مشتقّات عائلة ما، فهذا يعني أن البناءات المكمّمة وتحسينات الخدمة وسكربتات الضبط الدقيق والمهايئات لتلك العائلة تتدفّق جنبًا إلى جنب. وتنمو تبعًا لذلك الأدوات ودعم المجتمع الذي يمكننا الاتّكاء عليه عند تبنّي تلك العائلة. أما مقاييس الاستدلال فمفيدة لقراءة اقتصاديات اللحظة الراهنة. فأين تتدفّق الحركة الفعلية دليل اجتماعي على أن نسبة السعر إلى الأداء لنموذج ما تنجح في الميدان، وإشارة إلى أن بنية الاستضافة على الأرجح مضبوطة له بالفعل.

أي عدسة نصدّق عند تباعد الاثنتين يعتمد على الهدف. إذا كنت تختار نموذجًا أساسيًا ليحمل خط أنابيب ضبط دقيق داخلي لفترة طويلة، فسماكة منظومة التنزيل والمشتقات أهم. وإذا كنت تختار هدف خدمة فعّال التكلفة الآن، فالحصة الفعلية في سوق الاستدلال هي البوصلة الأدق. ولهذا بالضبط يُبقي تقرير ATOM المحورين منفصلين حتى النهاية.

## دلالات لـ ThakiCloud

يتداخل هذا التحوّل في المشهد تمامًا مع المشكلة التي تستهدفها منصة ai-platform من ThakiCloud. تجدول ai-platform موارد GPU باستخدام Kueue فوق Kubernetes، وتخدم مجموعة متنوّعة من النماذج المفتوحة في بيئة متعددة المستأجرين باستخدام vLLM. منظومة نماذج مفتوحة تتّسع ويتحرّك مركز ثقلها تعني أن قائمة النماذج التي يريد عملاؤنا خدمتها تتغيّر باستمرار.

أولًا، تزداد قيمة تجريد الخدمة الذي لا يرتبط بأي عائلة نماذج واحدة. فإذا كان التباين الحالي، مع تصدّر Qwen في التنزيلات وDeepSeek في الاستدلال، قد يتغيّر مجددًا خلال ستة أشهر، فإن على البنية التحتية أن تكون قادرة على نشر وتوسيع أي عائلة تصعد بالطريقة نفسها. هذه التقلّبية هي بالضبط سبب تعامل ai-platform مع النماذج كموارد من الدرجة الأولى وتوحيدها لخط أنابيب الخدمة.

ثانيًا، يعزّز صعود الأوزان المفتوحة الحجّة الاقتصادية للنشر الداخلي والسيادي. فمع أن نماذج مفتوحة تقترب من الفئة العليا صارت قابلة للتشغيل على عنقودك الخاص دون الاعتماد على واجهات تجارية، يحصل عملاء القطاع العام والمالي والدفاعي الذين لا يمكنهم إرسال البيانات إلى الخارج على خيار حقيقي. تستهدف ThakiCloud النقطة التي تتحقّق فيها تكلفة الخدمة المنخفضة وسيادة البيانات في آنٍ معًا في مثل هذه البيئات. وكلما اتّسع مشهد النماذج المفتوحة، صار هذا الموقع أكثر إقناعًا.

ثالثًا، تقدّم منهجية تقرير ATOM ذاتها في قراءة التنزيلات والاستدلال منفصلين درسًا تشغيليًا. فحين يطلب عميل نموذجًا لأن "هذا رائج"، ينبغي أن نكون قادرين على التمييز بين ضجيج التنزيل واقتصاديات الاستدلال الحقيقية. على مزوّد البنية التحتية مسؤولية أن يوصي بأهداف الخدمة استنادًا إلى بيانات الاستخدام الفعلية لا إلى الموضة.

## الحدود والاعتراضات

ثمة تحفّظات ينبغي مراعاتها أثناء قراءة هذا التقرير. فكلٌّ من التنزيلات واستخدام الاستدلال مقياس بديل. يمكن أن تتضخّم التنزيلات بخطوط أنابيب آلية أو نسخ متطابق، وتُشوّه الزواحف وإعادة التوزيع الأرقام. وتعكس حصة الاستدلال على OpenRouter الحركة التي تمرّ عبر ذلك الموجّه فقط، فالاستخدام الهائل الذي يُشغّله كبار المُشغّلين مباشرة على بنيتهم الخاصة خارج نطاق القياس من البداية. تبقى النقاط العمياء حتى بعد تراكب العدستين.

مساواة انقلاب التوازن الإقليمي مباشرة بانقلاب في القدرة متسرّعة أيضًا. فالتبنّي نتيجة للسعر والترخيص وسهولة الوصول وزخم المنظومة معًا، لا للأداء وحده. واستخدام النماذج المفتوحة الصينية على نطاق واسع يعود إلى استراتيجيات انفتاح جريئة وحواجز دخول منخفضة بقدر ما يعود إلى أداء قوي. "واسع الاستخدام" قضية مختلفة عن "الأفضل"، وما قاسه التقرير هو الأولى.

أخيرًا، تتقادم هذه اللقطة بسرعة. ففي مجال يترنّح على مقياس الأشهر، قد تختلف خريطة أبريل 2026 قليلًا عن تضاريس اليوم بالفعل. ومع ذلك، تكمن قيمة التقرير لا في الترتيبات الفردية بل في منهجية قراءة التنزيلات والاستدلال منفصلين وفي التيار العريض بأن مركز الثقل قد انتقل. من المرجّح أن يصمد هذا التيار لفترة، وما علينا نحن المُعِدّين للبنية التحتية إلا أن نُبقي مكدّس الخدمة مفتوحًا في ذلك الاتجاه.

## المصادر

- ATOM Report: Measuring the Open Language Model Ecosystem, arXiv:2604.07190 (2026-04-08). <https://arxiv.org/abs/2604.07190>
- Interconnects, "What I've been building: ATOM Report". <https://www.interconnects.ai/p/what-ive-been-building-atom-report>
