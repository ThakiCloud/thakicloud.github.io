---
title: "نظرة داخل slime، إطار التعلّم المعزّز مفتوح المصدر الذي بنى GLM-5.2"
excerpt: "تم فتح المصدر بالكامل لإطار البنية التحتية للتعلّم المعزّز غير المتزامن slime، وهو الذي قاد مرحلة التدريب اللاحق للنموذج مفتوح الأوزان GLM-5.2 من Z.ai بسياق مليون رمز. نحلّل بنيته المكوّنة من ثلاثة أجزاء التي تربط تدريب Megatron بتوليد SGLang عبر Data Buffer، ووضعَي التشغيل colocated وdisaggregated، وتصميمه للتعلّم المعزّز للوكلاء متعدد الأدوار، من منظور منصة ThakiCloud القائمة على K8s وجدولة وحدات GPU عبر Kueue."
seo_title: "تحليل إطار GLM-5.2 للتعلّم المعزّز slime: تدريب لاحق Megatron SGLang - Thaki Cloud"
seo_description: "تحليل لإطار THUDM slime (إطار تدريب لاحق للتعلّم المعزّز أصيل لـ SGLang): بنيته المكوّنة من Training/Rollout/Data Buffer، وضعا colocated وdisaggregated، ميزات التعلّم المعزّز للوكلاء متعدد الأدوار، والتحقق عبر GLM-5.x، من منظور عمليات GPU متعددة المستأجرين على منصة ThakiCloud القائمة على K8s."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - slime
  - glm-5.2
  - reinforcement-learning
  - post-training
  - sglang
  - megatron
  - agent-rl
  - open-source
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/glm52-slime-rl-framework/"
reading_time: true
categories:
  - llmops
---

![صورة تجريدية تُظهر عنقود توليد وعنقود تدريب يتبادلان البيانات بشكل غير متزامن عبر مخزن مؤقت مركزي]({{ '/assets/images/glm52-slime-rl-framework-hero.webp' | relative_url }})
*صورة تجسّد تصميم slime للتعلّم المعزّز غير المتزامن، الذي يفصل التوليد عن التدريب لرفع الإنتاجية.*

## نظرة عامة

GLM-5.2، الذي أصدرته Z.ai (المعروفة سابقًا باسم Zhipu AI) في يونيو 2026، نموذج مفتوح الأوزان بسياق يبلغ مليون رمز وبرخصة MIT. لفت الانتباه لمنافسته النماذج التجارية المغلقة في مهام البرمجة ومهام الوكلاء طويلة المدى. لكنّ هذا الإصدار يأتي بشيء يكاد يضاهي أهمية أوزان النموذج نفسها: فقد تم فتح مصدر **slime**، البنية التحتية للتعلّم المعزّز التي شغّلت مرحلة التدريب اللاحق للنموذج، إلى جانبه.

تطلق معظم النماذج الرائدة أوزانها المدرَّبة مسبقًا، لكنها تُبقي خط أنابيب التعلّم المعزّز الذي يحوّل تلك الأوزان إلى وكيل مفيد فعلًا سرّيًا. فالبنية التحتية التي تربط تصميم المكافأة وتوليد الـ rollout وحلقة التدريب هي بالضبط الخبرة الخاصة التي تحدّد جودة النموذج. يفتح slime هذا المجال بأكمله. تذكر Z.ai أن GLM-5.2، بل أيضًا GLM-5.1 وGLM-5 وGLM-4.7 وGLM-4.6 وGLM-4.5، خضعت جميعها للتدريب اللاحق على الإطار نفسه. ومرور إطار واحد عبر عدة إصدارات من فئة الأحدث عالميًا يعني أن هذه بنية تحتية مُثبَتة في الإنتاج، لا شيفرة مختبرية.

تشغّل ThakiCloud منصة SaaS متعددة المستأجرين للذكاء الاصطناعي والتعلّم الآلي قائمة على K8s، فتخدم النماذج وتشغّل الوكلاء عبر بيئات عملاء متنوعة. لذا فإن السؤال "أي نموذج جيد" يهمّنا بقدر السؤال "أي بنية تحتية بنته وتشغّله". وبوصفه مرجعًا عامًا للجانب الثاني، يستحق slime التمعّن. في هذه التدوينة نعرض بنية slime وفلسفته التصميمية، ونتأمّل دلالاته لجدولة GPU عبر Kueue ولمنظومة الخدمة SGLang/vLLM في منصتنا.

## ما هو slime

slime إطار **للتدريب اللاحق لنماذج اللغة الكبيرة من أجل توسيع التعلّم المعزّز**، بناه فريق THUDM (من سلالة جامعة تسينغهوا / Z.ai). الفكرة الجوهرية بسيطة: Megatron-LM بارع في التدريب، وSGLang بارع في الاستدلال عالي الإنتاجية (الـ rollout)، فلنربط الاثنين في تدفّق بيانات واحد. يكرّر التدريب اللاحق للتعلّم المعزّز بلا نهاية حلقةً قوامها "يولّد النموذج إجابة (rollout)، ثم تُقيَّم الإجابة، ثم تُحدِّث تلك المكافأة النموذج"، ولذا فإن مدى سلاسة ربط محرّك التوليد بمحرّك التدريب هو ما يحدّد الإنتاجية الإجمالية.

يفكّك slime هذه الحلقة إلى ثلاثة مكوّنات.

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
<div class="d3-arch" data-arch-root id="627glm52slimerlframework-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 468, "height": 988, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 400, "h": 436, "label": "الـ Rollout (SGLang + Router)", "lx": 36, "ly": 42}, {"x": 149, "y": 552, "w": 287, "h": 172, "label": "Data Buffer (الجسر)", "lx": 161, "ly": 570}, {"x": 36, "y": 816, "w": 326, "h": 140, "label": "التدريب (Megatron-LM)", "lx": 48, "ly": 834}], "nodes": [{"id": "SGL", "x": 123, "y": 219, "w": 163, "h": 62, "title": ["محرك استدلال SGLang", "توليد الاستجابات"]}, {"id": "RT", "x": 98, "y": 63, "w": 212, "h": 78, "title": ["sgl-router", "نقطة وصول واحدة متوافقة مع", "OpenAI"]}, {"id": "RW", "x": 211, "y": 359, "w": 163, "h": 62, "title": ["المكافأة / verifier", "حساب الدرجات"]}, {"id": "DB", "x": 187, "y": 591, "w": 212, "h": 94, "title": ["تهيئة الموجّهات", "بيانات مخصصة", "إدارة استراتيجية توليد الـ", "Rollout"]}, {"id": "MG", "x": 123, "y": 855, "w": 163, "h": 62, "title": ["حلقة تدريب Megatron", "تحديث الأوزان"]}], "edges": [{"src": "RT", "dst": "SGL", "kind": "data", "line": [204, 141, 204, 219]}, {"src": "SGL", "dst": "RW", "kind": "data", "curve": [[243, 281], [293, 320], [293, 320], [293, 359]]}, {"src": "RW", "dst": "DB", "kind": "data", "label": "\"بيانات التوليد + سجل المكافأة\"", "line": [293, 421, 293, 591], "lx": 293, "ly": 502}, {"src": "DB", "dst": "MG", "kind": "data", "label": "\"توفير دفعات التدريب\"", "curve": [[293, 685], [293, 724], [293, 816], [243, 855]], "off": "50%"}, {"src": "MG", "dst": "SGL", "kind": "event", "label": "\"مزامنة المعاملات\"", "curve": [[165, 855], [116, 724], [116, 460], [165, 281]], "off": "50%"}]});
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
      const container = document.getElementById('627glm52slimerlframework-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '627glm52slimerlframework-1';
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

- **التدريب (Megatron-LM)**: يتولّى عملية التدريب الرئيسية. يقرأ البيانات من Data Buffer لتحديث النموذج، ويزامن المعاملات مع وحدة الـ rollout بعد اكتمال التدريب.
- **الـ Rollout (SGLang + Router)**: يولّد بيانات جديدة، تشمل المكافآت ومخرجات الـ verifier، ويكتبها إلى Data Buffer. وهنا يوفّر sgl-router واجهة برمجية متوافقة مع OpenAI لتتفاعل بيئات الوكلاء المعقّدة مع النموذج عبر نقطة وصول HTTP واحدة.
- **Data Buffer**: الجسر بين العالمين. يدير تهيئة الموجِّهات (prompts) والبيانات المخصّصة واستراتيجية توليد الـ rollout.

تتولّى Ray إدارة الموارد. ونتيجةً لذلك، يمكن التبديل بعَلَم واحد بين وضع تتشارك فيه عمليتا التدريب والـ rollout وحدات GPU نفسها، ووضع يفصلهما على وحدات GPU منفصلة.

## وضعا التشغيل: colocated وdisaggregated

أكثر قرارات slime التصميمية عمليةً هو أن الشيفرة نفسها تدعم وضعَي نشر اثنين.

**الوضع المتشارك (colocated) / المتزامن** يضع التدريب والـ rollout على مجمّع GPU نفسه. يُفعَّل بعَلَم واحد `--colocate`. وهو مناسب لاستخلاص أقصى استفادة من بيئات GPU المحدودة، حيث يتقاسم التوليد والتدريب الموارد نفسها زمنيًا.

**الوضع المفصول (disaggregated) / غير المتزامن** يفصل وحدات GPU الخاصة بالتدريب عن تلك الخاصة بالـ rollout. فيمكن للتوليد أن يستمر دون انتظار التدريب، مما يرفع الإنتاجية. و"التعلّم المعزّز غير المتزامن للوكلاء" الذي أبرزه GLM-5.2 يعمل فوق هذا الوضع تحديدًا. ففصل التوليد عن التدريب يقلّص بشدّة زمن خمول GPU في الأحمال التي تكون فيها كل حلقة طويلة وغير منتظمة، مثل التفاعلات متعددة الأدوار ومتعددة الأدوات.

هذا الخيار مهمّ للمشغّلين. فبالإطار نفسه يمكنك تشغيل تجارب صغيرة بتكلفة زهيدة في الوضع المتشارك، ودفع الإنتاجية في الوضع المفصول للتدريب الإنتاجي واسع النطاق، بما يتيح التوسّع التدريجي.

## التصميم من أجل التعلّم المعزّز للوكلاء

ثمّة سبب لاستخدام slime في تدريب نماذج الوكلاء مثل GLM-5.x: فهو يتضمّن ميزات موجَّهة مباشرةً لأحمال الوكلاء متعددة الأدوار.

- **PD Disaggregation**: يفصل مرحلتَي prefill وdecode لأحمال الوكلاء متعددة الأدوار حيث تختلف احتياجات الموارد بين المرحلتين.
- **انتماء الجلسة في الـ Router**: يوفّر سياسة توجيه تُبقي الوكيل متعدد الأدوار على الجلسة نفسها، فتستمرّ أدوار الوكيل الواحد المتعدّدة في حالة متّسقة.
- **Delta Weight Sync**: في بيئة مفصولة بين التدريب والاستدلال، يُزامَن فرق الأوزان فقط، مما يخفض كلفة الاتصال.
- **نقطة وصول واحدة متوافقة مع OpenAI**: بفضل sgl-router، تتفاعل بيئات الوكلاء المعقّدة مع النموذج عبر طلبات HTTP بسيطة. فلا حاجة لحشر شيفرة البيئة داخل إطار التعلّم المعزّز.

البند الأخير عمليّ على نحو خاص. فإذا جرّدت بيئة المهام طويلة المدى مثل تحرير الشيفرة واستخدام الأدوات وحلّ المشكلات متعدد الخطوات إلى استدعاءات لواجهة OpenAI، أمكنك ربط بيئات الوكلاء القائمة بحلقة تدريب التعلّم المعزّز كما هي تقريبًا. وتضيف Z.ai آلية "مكافحة الالتفاف" (anti-hacking) فوق ذلك لكبح اختراق المكافأة، حيث يستغلّ النموذج المكافأة بطرق التفافية في المهام طويلة المدى.

## نظرة عامة على التثبيت والاستخدام

slime متاح على GitHub ([THUDM/slime](https://github.com/THUDM/slime))، ولكونه أصيلًا لـ SGLang فهو يفترض منظومة استدلال SGLang ومنظومة تدريب Megatron-LM. كما نُشر دعم اليوم الأول (Day-0) لوحدات AMD Instinct GPU عبر مدوّنة ROCm، مما يؤكد عمله على مسرّعات خارج NVIDIA.

لكن بصدق، يتطلّب إعادة إنتاج حلقة التدريب اللاحق للتعلّم المعزّز في slime بشكل ذي معنى عنقود GPU متعدّد (عادةً ثمانية مسرّعات من فئة مراكز البيانات أو أكثر) وبيئة تُهيَّأ فيها Megatron وSGLang وRay معًا. لم تُشغّل هذه التدوينة تدريبًا كاملًا للتعلّم المعزّز في صندوق رمل أحادي العقدة لالتقاط الأرقام. لذا لا نقدّم أي أرقام قياس مثل إنتاجية التدريب أو سرعة التقارب، وحالات التحقق الإنتاجية أدناه مبنيّة على مصادر أوّلية منشورة. وعدم اختلاق أرقام أداء اعتباطية مبدأ من مبادئ مدوّنتنا.

من الناحية البنيوية، الأسطح التي يلمسها المشغّل واضحة. فأنت تحدّد أسلوب النشر بعَلَم وضعٍ مثل `--colocate`، وتركّب استراتيجية الـ rollout الخاصة بمجالك عبر واجهة توليد البيانات المخصّصة في Data Buffer، وتربط بيئات الوكلاء بنقطة وصول sgl-router. ولهذا يؤكّد الإطار على المرونة: فلأن واجهة الـ rollout قابلة للتخصيص بالكامل، يمكن تهيئة كل شيء على الهيكل نفسه، من خوارزميات التعلّم المعزّز العامة إلى تدريب الوكلاء المتخصّص بمجال بعينه.

## التحقق عبر GLM-5.x

يُعدّ slime من أكثر أطر التدريب اللاحق المفتوحة للتعلّم المعزّز اختبارًا في الميدان. فقد مرّت عدة إصدارات من فئة الأحدث عالميًا (GLM-5.2 وGLM-5.1 وGLM-5 وGLM-4.7 وGLM-4.6 وGLM-4.5) عبر حلقة تدريبه الكاملة. وذكر GLM-5.2 أنه دُرِّب لاحقًا بخوارزمية جديدة للتعلّم المعزّز غير المتزامن للوكلاء تتعلّم من التفاعلات طويلة المدى متعددة الأدوات، فوق بنية تحتية تفصل التوليد عن التدريب. وقد ذُكر أن التدريب اللاحق الكامل لـ GLM-5.2 اكتمل في نحو يومين، لكننا نُبقي رقم المدّة هذا بوصفه [تقديريًا] لأننا لم نتمكّن من التحقق المتقاطع منه عبر وثائق رسمية أوّلية.

الجوهر ليس الرقم بل قابلية إعادة الإنتاج. فبفتح أوزان النموذج (MIT) وإطار التدريب معًا، تستطيع مؤسسة تملك حوسبة كافية أن تعيد تتبّع وصفة التدريب اللاحق لـ GLM-5.2 على بيانات مجالها. وهذه رافعة تنفرد بها المنظومة المفتوحة، يستحيل بلوغها بالنماذج المغلقة.

## ما الذي يعنيه هذا لمنتجات ThakiCloud

يمسّ تصميم slime للتعلّم المعزّز غير المتزامن طبقتَي منتج متمايزتين في ThakiCloud.

من منظور ai-platform، يتطلّب تدريب التعلّم المعزّز حملين متزامنين مختلفَي الطبيعة تمامًا: الـ rollout (حمل استدلال) والتدريب (حمل انتشار عكسي). تتوافق الطريقة التي يبدّل بها slime بين colocated وdisaggregated عبر Ray توافقًا جيدًا مع نموذج طابور GPU في Kueue. ففي الوضع المفصول، يتيح تقسيم الـ rollout والتدريب إلى مهامّ منفصلة لـ Kueue جدولة كلٍّ منهما عبر طابوره الخاص، مما يرفع استغلال GPU عبر العنقود متعدد المستأجرين ويُبقي تكاليف الحوسبة في حدودها. وبما أن منظومة الخدمة لدينا تستخدم vLLM أصلًا، فإن الخبرة المكتسبة حول التجميع المستمر وإدارة ذاكرة KV المؤقتة تنتقل مباشرةً إلى جانب الـ rollout في خط أنابيب التعلّم المعزّز. والنتيجة العملية هي خط أنابيب RL داخلي يعمل دون تصدير البيانات خارج العنقود، مما يحوّل التدريب اللاحق الذاتي الاستضافة من هدف مبهم إلى منتج ملموس.

من منظور Paxis، يكون الاتصال أكثر مباشرةً. فـ Paxis هو طائرة تحكّم الوكلاء من ThakiCloud، تعمل فوق ai-platform. يشمل جوهره Skill Harness الذي يختار من أكثر من 960 مهارة عبر BM25، وحلقة مهارات ذاتية التطوّر، وتنفيذًا معزولًا، ومحرّك معرفة HKE. يصبح إطار مثل slime هو المحرّك التعليمي لحلقة التطوّر الذاتي تلك. فبتوليد الـ rollouts من بيانات مجال العميل وتقييمها بإشارة مكافأة وتحديث المهارات عبر التعلّم المعزّز، تتحسّن وكلاء مجال Paxis باستمرار مع الاستخدام. وتعمل نقطة وصول sgl-router المتوافقة مع OpenAI كعنصر ربط يصل موصّلات MCP في Paxis وبيئات الأدوات القائمة بحلقة التعلّم المعزّز بأدنى احتكاك. وهكذا يتكامل المنتجان: تزوّد ai-platform طوابير GPU وخط أنابيب RL الداخلي، بينما تستهلك Paxis ذلك الخط بوصفه محرّكًا لتطوّر المهارات.

هذا أقرب إلى خارطة طريق منه إلى ميزة مُشحونة. غير أن التوافق البنيوي بين منظومة ai-platform (K8s وKueue وvLLM) ومعمارية المهارات ذاتية التطوّر في Paxis من جهة، وما يفترضه slime فعلًا من جهة أخرى، يُظهر أن هذا الاتجاه ليس توفيقًا متكلَّفًا.

## القيود والاعتراضات

slime ليس حلًّا سحريًا. لنذكر بضعة قيود واقعية بوضوح.

أكبر عائق للدخول هو **الحوسبة والتعقيد التشغيلي**. فإقامة Megatron + SGLang + Ray في آنٍ واحد وتنسيق التدريب/الـ rollout عبر وحدات GPU متعددة ليس أمرًا هيّنًا البتّة. وليست هذه أداةً يستطيع GPU واحد أو فريق صغير تشغيلها باستهتار، والتدريب اللاحق للتعلّم المعزّز نفسه يتطلّب استثمارًا في البنية التحتية يضاهي التدريب المسبق. وثمّة فجوة كبيرة بين "الإطار مفتوح" و"نستطيع تشغيل التدريب اللاحق للتعلّم المعزّز".

ثانيًا، **صعوبة التدريب اللاحق للتعلّم المعزّز**. فتصميم المكافأة، ومنع اختراق المكافأة، واستقرار التدريب، مصاعب جوهرية لا يحلّها الإطار نيابةً عنك. يوفّر slime البنية التحتية فقط؛ أما دالة المكافأة الجيدة ووصفة التدريب المستقرّة فتبقيان مسؤولية المستخدم. وكون Z.ai أبرزت آلية مكافحة الالتفاف على نحو منفصل هو بذاته دليل على مدى صعوبة هذا المجال.

ثالثًا، **حدود نطاق تحقّقنا**. فقد حلّلت هذه التدوينة البنية اعتمادًا على وثائق slime العامة وما نُشر عنها؛ ولم نُعِد مباشرةً إنتاج حلقة التدريب الكاملة للتعلّم المعزّز لقياس الإنتاجية. لذا فإن مزاعم مثل "تدريب من فئة GLM-5.2 في أيام معدودة" ليست حقائق أكّدناها باستقلال. وعلى من يدرس التبنّي أن يجرّب أولًا بنموذج صغير ومهمة صغيرة في الوضع المتشارك لقياس الكلفة الفعلية في بيئته الخاصة.

ومع ذلك، فإن حدثًا تُفتح فيه أوزان النموذج وإطار التدريب معًا يمثّل شفافية نادرة في منظومة نماذج اللغة المفتوحة. وبالنسبة لمنصة مثل ThakiCloud تشغّل البنية التحتية مباشرةً، فقد اتّسعت مجموعة الخيارات التي تمنح التحكّم حتى مرحلة التدريب اللاحق، بما يتجاوز مجرّد استخدام نموذج صنعه آخرون.

## المصادر

- [THUDM/slime - GitHub](https://github.com/THUDM/slime)
- [slime: An SGLang-Native Post-Training Framework for RL Scaling - LMSYS Org](https://www.lmsys.org/blog/2025-07-09-slime/)
- [GLM-5.2: Built for Long-Horizon Tasks - Hugging Face Blog](https://huggingface.co/blog/zai-org/glm-52-blog)
- [Day-0 Support for the SGLang-Native RL Framework slime on AMD Instinct GPUs - ROCm Blogs](https://rocm.blogs.amd.com/artificial-intelligence/slime/README.html)
