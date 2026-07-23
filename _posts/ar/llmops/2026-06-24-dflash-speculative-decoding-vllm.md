---
title: "DFlash والفك التخميني: تسريع الاستدلال في vLLM حتى 15 ضعفاً باستخدام الانتشار الكتلي"
excerpt: "يستبدل DFlash مسودة EAGLE-3 القائمة على التوليد التلقائي بمسودة انتشار كتلي، تقترح كتلة من الرموز المستقبلية في تمريرة أمامية واحدة. يتكامل DFlash مباشرة مع vLLM وSGLang وTensorRT-LLM، ويُرجع وفق الأرقام المنشورة تسريعاً خالياً من الخسارة يبلغ 6 أضعاف في التدفق المفرد، وإنتاجية تصل إلى 15 ضعفاً على Blackwell. نحلل ما يعنيه ذلك من منظور منصة الخدمة متعددة المستأجرين المبنية على Kubernetes."
seo_title: "تحليل تكامل DFlash في vLLM - الفك التخميني بالانتشار الكتلي - Thaki Cloud"
seo_description: "نحلل من منظور منصة ThakiCloud على Kubernetes كيف يتكامل الفك التخميني القائم على الانتشار الكتلي في DFlash مع vLLM وSGLang وTensorRT-LLM، مع استعراض المعايير المنشورة (Qwen3-8B بتسريع 6.08× خالٍ من الخسارة، و15× على Blackwell)."
date: 2026-06-24
last_modified_at: 2026-06-24
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/dflash-speculative-decoding-vllm/"
tags:
  - speculative-decoding
  - dflash
  - vllm
  - inference-optimization
  - block-diffusion
  - eagle
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "bolt"
toc_sticky: true
reading_time: true
categories:
  - llmops
published: false
---

![مرئية تجريدية لكتل رموز متوازية تنطلق للأمام دفعة واحدة]({{ '/assets/images/dflash-speculative-decoding-vllm-hero.webp' | relative_url }})

صورة تجسّد مفهوم DFlash: تحويل مرحلة الصياغة في الفك التخميني من نهج تسلسلي إلى نهج متوازي.

## نظرة عامة

في خدمة نماذج اللغة الكبيرة، يُحدَّد التكلفة وسرعة الاستجابة المحسوسة للمستخدم في آنٍ واحد من خلال إنتاجية فك التشفير. طالما أن النموذج يولّد الرموز واحداً تلو الآخر بالنهج الانحداري الذاتي (autoregressive)، فسيظل القيد البنيوي قائماً: يجب إجراء تمريرة كاملة عبر النموذج لكل رمز، بصرف النظر عن سرعة وحدة معالجة الرسومات. لقد أصبح الفك التخميني (speculative decoding) الأسلوب الأكثر عملية لتجاوز هذا الاختناق، غير أن المسودّات التقليدية أيضاً كانت تُولّد الرموز تسلسلياً، مما جعل معاملات التسريع تتوقف في الغالب عند نطاق 2-3×.

في 23 يونيو 2026، نشرت NVIDIA في مدونتها التقنية دراسة حول DFlash من باحثي جامعة كاليفورنيا سان دييغو. يُدخل DFlash نموذج انتشار كتلي (block diffusion) في مرحلة الصياغة من الفك التخميني، إذ يقترح الرموز المستقبلية ككتلة في تمريرة أمامية واحدة بدلاً من اقتراحها رمزاً رمزاً. وفقاً للأرقام المنشورة، يبلغ التسريع الخالي من الخسارة في التدفق المفرد ما يصل إلى 6×، فيما تصل الإنتاجية على NVIDIA Blackwell إلى 15× مقارنةً بنفس هدف الاستجابة.

والميزة التشغيلية الأكثر أهمية هي **التكامل المباشر (drop-in)**. يدعم DFlash كلاً من vLLM وSGLang وTensorRT-LLM؛ وفي vLLM يكفي استبدال إعداد الصياغة من EAGLE-3 بإعداد DFlash دون أي تعديل في كود التطبيق. تستعرض هذه المقالة آلية عمل DFlash، وما تكشفه المعايير المنشورة، والتداعيات من منظور ThakiCloud في تشغيل منصة AI/ML متعددة المستأجرين مبنية على Kubernetes. جميع الأرقام الواردة هنا هي قياسات رسمية منشورة من NVIDIA وUCSD، ونتناول موضوع إعادة الإنتاج على معداتنا الخاصة بصدق في القسم المناسب.

## ما هي هذه التقنية؟

ينقسم الفك التخميني إلى مرحلتين: يقترح نموذج مسودة صغير الرموز المستقبلية، ثم يتحقق النموذج المستهدف الكبير من هذه الرموز بالتوازي ويقبل الصيغة الصحيحة الأطول. إذا كانت المسودة صحيحة، تُؤكَّد رموز متعددة بتمريرة تحقق واحدة من النموذج المستهدف. المشكلة أن المسودّات التقليدية تعتمد النهج الانحداري الذاتي، فترتفع تكلفة الصياغة خطياً مع زيادة عدد الرموز التخمينية، مما يُصعّب رفع الإنتاجية أكثر.

يستبدل DFlash هذا المسودّ الانحداري بمسودّ انتشار كتلي خفيف. يُزيل نموذج الانتشار الكتلي التشويش عن كتلة رموز مُخفاة دفعةً واحدة، جامعاً بين التوليد المتوازي والبنية الكتلية الانحدارية. يُطبّق DFlash هذه الفكرة على مرحلة الصياغة فحسب، بينما يتولى النموذج المستهدف الانحداري الموثوق التحقق. هذا الفصل هو مفتاح الحفاظ على الجودة: كثيراً ما تفتقر نماذج الانتشار المنفردة إلى دقة النماذج الانحدارية وتتطلب مراحل إزالة تشويش متعددة، لكن في DFlash يكفي أن تكون المسودة "جيدة بما يكفي لتجتاز التحقق"، وتكفل تمريرة التحقق المتوازية من النموذج المستهدف التزام توزيع المخرجات بالنموذج المستهدف. أي أن العملية خالية من الخسارة (lossless).

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
<div class="d3-arch" data-arch-root id="hspeculativedecodingvllm-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1043, "height": 568, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 987, "h": 121, "label": "EAGLE-3 (صياغة انحدارية ذاتية)", "lx": 36, "ly": 42}, {"x": 24, "y": 399, "w": 481, "h": 137, "label": "DFlash (صياغة بالانتشار الكتلي)", "lx": 36, "ly": 417}], "nodes": [{"id": "E1", "x": 63, "y": 62, "w": 120, "h": 46, "title": "رمز t1"}, {"id": "E2", "x": 304, "y": 62, "w": 120, "h": 46, "title": "رمز t2"}, {"id": "E3", "x": 619, "y": 62, "w": 120, "h": 46, "title": "رمز t3"}, {"id": "E4", "x": 852, "y": 62, "w": 120, "h": 46, "title": "رمز t4"}, {"id": "D0", "x": 63, "y": 445, "w": 120, "h": 46, "title": "كتلة مُخفاة"}, {"id": "D1", "x": 261, "y": 437, "w": 205, "h": 62, "title": ["t1 · t2 · t3 · t4 (تمريرة", "أمامية واحدة)"]}, {"id": "V1", "x": 279, "y": 183, "w": 170, "h": 62, "title": ["تحقق متوازٍ بالنموذج", "المستهدف"]}, {"id": "EAGLE", "x": 63, "y": 191, "w": 120, "h": 46, "title": "EAGLE"}, {"id": "V2", "x": 279, "y": 300, "w": 170, "h": 62, "title": ["تحقق متوازٍ بالنموذج", "المستهدف"]}, {"id": "DFLASH", "x": 63, "y": 308, "w": 120, "h": 46, "title": "DFLASH"}, {"id": "OUT", "x": 583, "y": 249, "w": 191, "h": 46, "title": "مخرجات خالية من الخسارة"}], "edges": [{"src": "E1", "dst": "E2", "kind": "data", "line": [183, 85, 304, 85]}, {"src": "E2", "dst": "E3", "kind": "data", "line": [424, 85, 619, 85]}, {"src": "E3", "dst": "E4", "kind": "data", "line": [739, 85, 852, 85]}, {"src": "D0", "dst": "D1", "kind": "data", "line": [183, 468, 261, 468]}, {"src": "EAGLE", "dst": "V1", "kind": "data", "line": [183, 214, 279, 214]}, {"src": "DFLASH", "dst": "V2", "kind": "data", "line": [183, 331, 279, 331]}, {"src": "V1", "dst": "OUT", "kind": "data", "curve": [[449, 214], [505, 214], [544, 214], [626, 249]]}, {"src": "V2", "dst": "OUT", "kind": "data", "curve": [[449, 331], [505, 331], [544, 331], [626, 295]]}]});
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
      const container = document.getElementById('hspeculativedecodingvllm-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'hspeculativedecodingvllm-1';
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

الميزة الثانية تكمن في بنية تكلفة الصياغة. ترتفع تكلفة المسودّ الانحداري خطياً مع عدد الرموز التخمينية، بينما يُولّد مسودّ الانتشار جميع الرموز في تمريرة متوازية واحدة، فيظل تأخر الصياغة شبه ثابت بتوسع الكتلة. هذا يُتيح لـDFlash استخدام نماذج صياغة أعمق وأكثر تعبيراً دون زيادة التأخر. يستخدم DFlash فعلياً مسودّاً صغيراً بـ5 طبقات (8 طبقات في حالة Qwen3-Coder)، وهو تباين واضح مع أبحاث مسودّات الانتشار السابقة (DiffuSpec، SpecDiff-2) التي استخدمت مسودّات ضخمة بمليارات المعاملات فأبقت التسريع عند 3-4×.

التقنيات الثلاث التي يجمعها DFlash هي: أولاً **الصياغة بالانتشار الكتلي** للتنبؤ المتوازي بالرموز المستقبلية، وثانياً **التكييف بالحالات الخفية للنموذج المستهدف (target hidden-state conditioning)** لتمرير ميزات السياق من النموذج المستهدف إلى المسودّ عبر حقن KV، وثالثاً التدريب الصديق للتحقق لرفع معدل قبول الكتل المُسوَّدة. هذا المزيج يُحقق توازن "مسودّ صغير + اقتراح كتلي متوازٍ + تحقق خالٍ من الخسارة".

## التثبيت والتكامل

يُوزَّع DFlash مع نقاط التفتيش ودعم الأطر معاً، مما يجعل التبني يتطلب حداً أدنى من الكود. نقاط التفتيش العامة متاحة من مجموعة `z-lab/dflash` على Hugging Face، وفي وقت الإعلان تتضمن 20 نقطة تفتيش. في vLLM، يكفي استبدال إعداد EAGLE-3 بإعداد DFlash دون إعادة هيكلة التطبيق. المثال التالي من التوثيق الرسمي:

```bash
vllm serve Qwen/Qwen3.5-27B \
  --speculative-config '{"method": "dflash", "model": "z-lab/Qwen3.5-27B-DFlash", "num_speculative_tokens": 15}' \
  --attention-backend flash_attn \
  --max-num-batched-tokens 32768
```

المفتاح هو تحديد `"method": "dflash"` في `--speculative-config` مع تمرير مسار نقطة تفتيش المسودّ. تظل بنية الأعلام مطابقة تقريباً لما كان يُستخدم في خدمة EAGLE-3، مما يجعل التحويل مجرد استبدال نهج الفك التخميني في نشر vLLM القائم. يقبل SGLang وTensorRT-LLM بالمثل نقطة تفتيش مسودّ DFlash عبر واجهة API الخاصة بالفك التخميني.

يدعم خلفية Transformers سلسلتَي Qwen3 وLLaMA-3.1، ويوفر واجهة `spec_generate` تستدعي نموذج المسودّ والنموذج المستهدف معاً:

```python
from transformers import AutoModel, AutoModelForCausalLM, AutoTokenizer

draft = AutoModel.from_pretrained(
    "z-lab/Qwen3-8B-DFlash-b16", trust_remote_code=True,
    dtype="auto", device_map="cuda:0").eval()
target = AutoModelForCausalLM.from_pretrained(
    "Qwen/Qwen3-8B", dtype="auto", device_map="cuda:0").eval()
tokenizer = AutoTokenizer.from_pretrained("Qwen/Qwen3-8B")

messages = [{"role": "user", "content": "196의 양의 약수는 몇 개인가?"}]
input_ids = tokenizer.apply_chat_template(
    messages, return_tensors="pt", add_generation_prompt=True,
    enable_thinking=False).to(draft.device)

output = draft.spec_generate(
    input_ids=input_ids, max_new_tokens=2048, temperature=0.0, target=target)
```

كتل الكود أعلاه مستشهد بها من الأمثلة الرسمية الواردة في مدونة NVIDIA التقنية وMarkTechPost، وليست نتائج التقاط مباشر من بيئة ThakiCloud. قياسات إنتاجية DFlash أُجريت على بيئة NVIDIA Blackwell (DGX B300، 8 وحدات GPU)، ولا تتوفر في بيئة كتابة هذا المقال المُعجِّلات ونقاط التفتيش المطلوبة لإعادة إنتاج نفس الظروف. وبناءً على ذلك، فإن جميع النتائج المذكورة أدناه أرقام منشورة من مصادر موثّقة، ولا تشمل قياسات محققة ذاتياً.

## نتائج التجارب الفعلية (وفق الأرقام المنشورة)

تنقسم أرقام تسريع DFlash إلى فئتين تختلف طرق قياسهما، لذا ينبغي قراءتهما بتمييز:

أولاً، **التسريع الخالي من الخسارة في التدفق المفرد**. يُرجع بحث UCSD متوسط 4.86× لـQwen3-8B بالفك الجشع (Transformers backend)، وأعلى قيمة 6.08× على MATH-500. في نفس الظروف، يُحقق EAGLE-3 متوسط 1.76× بحجم شجرة 16، و2.02× بحجم 60. أرقام كل مهمة موضحة في الرسم البياني أدناه.

![رسم بياني شريطي لمقارنة التسريع الخالٍ من الخسارة لـDFlash وEAGLE-3 على Qwen3-8B عبر المهام]({{ '/assets/images/dflash-speculative-decoding-vllm-results.webp' | relative_url }})

الرسم البياني أعلاه يُمثّل بيانياً الأرقام الرسمية من ورقة UCSD حول DFlash، وليس قياسات مباشرة من ThakiCloud. GSM8K: 5.15×، MATH-500: 6.08×، AIME25: 5.62×، HumanEval: 5.14×، LiveCodeBench: 5.51×، وهي قيم مرتفعة بشكل خاص في مهام الاستدلال الرياضي والبرمجي. في المقابل، تبلغ قيمة MT-Bench للمحادثات المفتوحة 2.75× فقط، وهو أمر متوقع لأن مكاسب الفك التخميني تتناسب مع إمكانية التنبؤ بالمخرجات (معدل القبول).

ثانياً، **الإنتاجية عند هدف استجابة ثابت**. الرقم 15× الذي تُرجعه NVIDIA يعني أن خدمة gpt-oss-120b عبر TensorRT-LLM على DGX B300 (8 وحدات Blackwell GPU) تُنتج إنتاجية أعلى بأكثر من 15× مقارنة بالفك التشفيري الانحداري، في النطاق الذي يتراوح فيه 500-600 رمز/ثانية للمستخدم. وفي نفس النقطة، يبلغ التسريع مقارنة بـEAGLE-3 نحو 1.5×. في اختبار Speed-Bench المنفصل من NVIDIA (تسريع الاستجابة عند نفس التزامن)، حقق gpt-oss-120b: DFlash 2.3× مقابل EAGLE-3 1.7×، وحقق Llama 3.1 8B Instruct: DFlash 2.8× مقابل EAGLE-3 2.2×. عبر المهام، تصل الأرقام إلى Gemma 4 31B: 5.8× (vLLM)، Qwen3 8B: 5.1× (SGLang).

خلاصة القول، "6×" هو تسريع خالٍ من الخسارة لطلب منفرد، أما "15×" فهو إنتاجية الخدمة عند تقييد عدد كبير من المستخدمين بنفس هدف الاستجابة. الرقمان يُجيبان على سؤالين مختلفين؛ لذا عند تقدير التأثير المتوقع في بيئة الإنتاج، حدد أولاً نسبة التزامن وهدف الاستجابة لديك ثم ارجع إلى الأرقام المقابلة لذلك النطاق.

## التداعيات على منصة ThakiCloud AI/ML SaaS على Kubernetes

تُشغّل ThakiCloud بنية تُجدول فيها GPU عبر Kueue على Kubernetes وتخدم نماذج مستأجرين متعددين عبر vLLM. DFlash نوع من التحسين يتناسب بشكل خاص مع هذه البنية، لثلاثة أسباب:

أولاً، **التكامل المباشر يُخفض مخاطر التشغيل**. إذا كنت تستخدم الفك التخميني مع EAGLE-3، يمكنك تبديل method ونقطة تفتيش المسودّ إلى DFlash والتحقق من النتائج بنشر كناري. بما أنها تقنية خالية من الخسارة لا تُغير عقد التطبيق (مخطط API، توزيع المخرجات)، تبقى الاستجابات المُدرَكة من المستأجرين متطابقة وتتحسن الإنتاجية والتأخر فقط. التحسينات التي لا تكسر اتساق المخرجات في SaaS متعدد المستأجرين نادرة القيمة.

ثانياً، **كفاءة GPU تساوي تكلفة الوحدة**. القدرة على معالجة طلبات متزامنة أكثر بنفس وحدة GPU وعند نفس مستوى الاستجابة تعني انخفاض تكلفة الخدمة لكل مستأجر. يتضاعف هذا التأثير في بيئات GPU يصعب فيها التوسع مثل GPU محلية أو في مناطق إقليمية. هذا يتوافق تماماً مع رسالة ThakiCloud المتعلقة بالخدمة الذاتية وكفاءة التكلفة. غير أن الـ15× من NVIDIA هو الحد الأعلى لمزيج Blackwell + TensorRT-LLM، وينبغي معايرة التوقعات وفق جيل GPU والخلفية لديك.

ثالثاً، **مكاسب أكبر في أحمال عمل الرياضيات والبرمجة**. عوامل الكود الداخلية وخطوط معالجة البيانات وأعباء عمل الوكلاء الغنية بالأدوات تُنتج مخرجات منظمة نسبياً تُحقق معدلات قبول عالية. المستأجرون الذين يخدمون هذه الأحمال بكثافة يُرجَّح أن يحققوا مكاسب DFlash فوق المتوسط. لما كانت ThakiCloud تستهدف منصة وكلاء متعددي المستأجرين، فإن تطبيق ملف تعريف خدمة DFlash أولاً على المستأجرين المتمحورين حول الكود والاستدلال استراتيجية تستحق الدراسة.

على صعيد خارطة طريق النضج، المسار الطبيعي هو الكشف عن نهج الفك التخميني في مخطط خدمة vLLM كملف تعريف لكل مستأجر، مع تشغيل حلقة قياس تكلفة في الخلفية لتتبع "هل انخفض سعر الرمز الواحد فعلاً بعد تطبيق DFlash؟" في الزمن الفعلي. مبدأ القياس لا الجزم ينطبق على تحسين الاستدلال بنفس القدر.

## القيود والاعتراضات

DFlash ليس الحل الشامل لكل شيء. أولاً، أقصى الأرقام المُرجَعة مقيّدة بأجهزة وخلفيات بعينها. الـ15× نتيجة مزيج Blackwell + TensorRT-LLM، وستنخفض عوامل التسريع مع GPU أقدم أو مكدسات خدمة مختلفة. الـ6× الخالية من الخسارة هي أيضاً للفك الجشع في تدفق مفرد؛ في أعباء عمل المحادثة عالية الحرارة أو المتنوعة، تنخفض معدلات القبول وتتضاءل المكاسب (2.75× لـMT-Bench يُوضح ذلك).

ثانياً، الفك التخميني نفسه يتطلب ذاكرة إضافية. يشغل نموذج المسودّ وذاكرة KV الخاصة به مساحة GPU، مما قد يُحدث مقايضة مع الحد الأقصى للتزامن في بيئات متعددة المستأجرين ذات الذاكرة الضيقة. صغر حجم المسودّ يُخفف هذا العبء لكنه لا يُلغيه.

ثالثاً، مسؤولية التحقق التشغيلي تقع على عاتق المُطبِّق. الأرقام المنشورة من مصادر موثّقة، لكن لا يوجد ضمان بإعادة إنتاجها على نموذجك وحركة مرورك ومستوى تزامنك. في هذا المقال لم نتمكن من إعادة الإنتاج في بيئة ThakiCloud، لذا قبل أي تبني فعلي ينبغي قياس تكلفة الرمز وتأخر p50/p99 مباشرةً عبر نشر كناري. أخيراً، مسودّات الانتشار الكتلي نهج جديد نسبياً قد لا تتوفر له نقاط تفتيش لجميع بنى النماذج، لذا تحقق أولاً من وجود نقطة تفتيش مسودّ مناسبة للنموذج المستهدف الذي تخدمه.

## المصادر

- [Boost Inference Performance up to 15x on NVIDIA Blackwell Using DFlash Speculative Decoding (NVIDIA Technical Blog, 2026-06-23)](https://developer.nvidia.com/blog/boost-inference-performance-up-to-15x-on-nvidia-blackwell-using-dflash-speculative-decoding)
- [DFlash Speculative Decoding Drafts Whole Token Blocks in Parallel (MarkTechPost, 2026-06-24)](https://www.marktechpost.com/2026/06/24/dflash-speculative-decoding-drafts-whole-token-blocks-in-parallel-for-up-to-15x-higher-throughput-on-nvidia-blackwell/)
- [مجموعة نقاط تفتيش DFlash العامة (Hugging Face, z-lab/dflash)](https://huggingface.co/collections/z-lab/dflash)
- [توثيق الفك التخميني في vLLM](https://docs.vllm.ai/en/latest/features/speculative_decoding/)
