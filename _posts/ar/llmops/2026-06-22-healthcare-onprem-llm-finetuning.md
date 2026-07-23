---
title: "الضبط الدقيق للنماذج اللغوية الكبيرة داخليًا دون تصدير بيانات المرضى - بنية الذكاء الاصطناعي للرعاية الصحية والعلوم الحيوية في المنشآت المحلية"
excerpt: "سير عمل متكامل يتيح للمؤسسات الصحية ضبط النماذج اللغوية الكبيرة المتخصصة في المجال وخدمتها على مجموعات GPU داخلية دون إرسال بيانات المرضى إلى سحابة خارجية. يتناول الدليل أساليب الضبط الدقيق الستة لمنصة ThakiCloud AI Platform وDevSpace وvLLM Scale-to-Zero."
seo_title: "ضبط دقيق للنماذج اللغوية الكبيرة في الرعاية الصحية داخليًا - بناء ذكاء اصطناعي دون تصدير بيانات المستشفيات أو الشركات الدوائية - Thaki Cloud"
seo_description: "كيفية ضبط النماذج اللغوية الكبيرة الصحية وخدمتها داخليًا دون تصدير بيانات المرضى. دليل شامل لبناء ذكاء اصطناعي متخصص في الرعاية الصحية داخل المنشأة باستخدام ستة أساليب ضبط (SFT وDPO وLoRA وغيرها) مع vLLM Scale-to-Zero."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: ar
tags:
  - healthcare
  - fine-tuning
  - on-premise
  - llm
  - data-privacy
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/healthcare-onprem-llm-finetuning/"
reading_time: true
categories:
  - llmops
published: false
---

![الضبط الدقيق للنماذج اللغوية الكبيرة الصحية داخليًا دون تصدير بيانات المرضى]({{ '/assets/images/healthcare-onprem-llm-finetuning-hero.webp' | relative_url }})

## نظرة عامة

يتسارع اعتماد النماذج اللغوية الكبيرة في قطاع الرعاية الصحية والعلوم الحيوية بوتيرة متصاعدة. مع توسّع نطاق تطبيقاتها -- من تلخيص الملاحظات السريرية، ومساعدة التشخيص، وتحليل أدبيات الأدوية، إلى أتمتة رموز الوصفات الطبية -- بدأت المستشفيات وشركات الأدوية والمؤسسات البحثية في تقييم بناء نماذج متخصصة في مجالاتها.

بيد أن أكبر عائق أمام الذكاء الاصطناعي في الرعاية الصحية ليس التقنية، بل حوكمة البيانات. إذ تحظر القوانين المحلية كقانون الخدمات الطبية وأنظمة حماية البيانات الشخصية وتشريعات الأخلاقيات الحيوية وضوابط الأمن الوطني نقل معلومات المرضى إلى خوادم خارجية أو تُقيّده تقييدًا شديدًا. في هذا السياق، يغدو نهج "رفع البيانات إلى واجهة برمجة تطبيقات سحابية للضبط الدقيق" غير مجدٍ لا قانونيًا ولا عمليًا.

تستعرض هذه المقالة، من خلال حالتين افتراضيتين لمستشفى عام كبير ومعهد أبحاث دوائية، سير العمل الكامل للضبط الدقيق للنموذج اللغوي المتخصص بالمجال وتشغيله داخل مجموعة Kubernetes في المنشأة دون تصدير البيانات. يعتمد سير العمل على منصة ThakiCloud AI Platform مع تفصيل المكوّنات العاملة في كل مرحلة.

---

## لماذا لا يمكن نقل بيانات الرعاية الصحية إلى السحابة

### البيئة التنظيمية

تخضع بيانات الرعاية الصحية المحلية لطبقات متعددة من الأنظمة والتشريعات.

**المادة الحادية والعشرون من قانون الخدمات الطبية** تحظر تزويد السجلات الطبية لأطراف خارجية دون موافقة المريض. **قانون حماية المعلومات الشخصية** يُلزم بالحصول على موافقة صريحة وباتخاذ تدابير أمنية عند نقل المعلومات الحساسة (كالتشخيصات وسجلات الوصفات والمعلومات الجينية) إلى أطراف ثالثة. **قانون الأخلاقيات الحيوية والسلامة** يُعامل النقل خارج الحدود للمواد المشتقة من الإنسان والمعلومات الجينية باعتباره مسألة تستلزم موافقة مستقلة. فضلًا عن ذلك، تخضع المؤسسات الصحية العامة والمعاهد البحثية المرتبطة بالدفاع لمراجعات الصلاحية الأمنية من الجهات المعنية، وكثيرًا ما تعمل في بيئات معزولة تمامًا عن الشبكات الخارجية.

### المخاطر العملية

إلى جانب التنظيمات، ثمة مخاطر عملية واقعية. وُثّقت حالات في الخارج رُفعت فيها دعاوى انتهاك الخصوصية بسبب إرسال ملاحظات سريرية إلى واجهات برمجة تطبيقات AI خارجية دون إخفاء الهوية. حتى الادعاء بأن "إخفاء الهوية يجعل الأمر مقبولًا" يظل هشًا قانونيًا نظرًا لإمكانية إعادة التعريف من خلال ربط المعرّفات شبه-المباشرة.

الخلاصة واضحة: يجب تدريب نماذج الذكاء الاصطناعي الصحية وخدمتها حيث توجد البيانات، أي داخل المجموعة المحلية للمنشأة.

---

## سير عمل الضبط الدقيق الداخلي

صُمّمت منصة ThakiCloud AI Platform على Kubernetes، وتُنجز جميع عمليات التدريب والاستدلال داخل المجموعة المحلية كليًا دون خروج البيانات إلى الشبكة الخارجية. يستعرض المخطط التالي كل مرحلة بالتفصيل.

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
<div class="d3-arch" data-arch-root id="hcareonpremllmfinetuning-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 838, "height": 1512, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 316, "y": 24, "w": 212, "h": 94, "title": ["البيانات المصدر", "الملاحظات السريرية /", "السجلات الطبية الإلكترونية", "/ رموز الوصفات"]}, {"id": "B", "x": 341, "y": 196, "w": 163, "h": 62, "title": ["معالجة إخفاء الهوية", "ETL داخلي بالمستشفى"]}, {"id": "C", "x": 316, "y": 336, "w": 212, "h": 94, "title": ["رفع مجموعة البيانات", "ThakiCloud Dataset Manager", "تنسيق HuggingFace / تخزين", "متوافق مع S3"]}, {"id": "D", "x": 311, "y": 508, "w": 223, "h": 52, "title": "اختيار أسلوب الضبط الدقيق"}, {"id": "E1", "x": 643, "y": 638, "w": 163, "h": 78, "title": ["SFT", "الضبط الدقيق الخاضع", "للإشراف"]}, {"id": "E2", "x": 446, "y": 646, "w": 142, "h": 62, "title": ["LoRA / QLoRA", "محوّل خفيف الوزن"]}, {"id": "E3", "x": 263, "y": 646, "w": 128, "h": 62, "title": ["DPO", "تعلم التفضيلات"]}, {"id": "E4", "x": 24, "y": 646, "w": 184, "h": 62, "title": ["CPT", "التدريب المسبق المستمر"]}, {"id": "F", "x": 351, "y": 794, "w": 142, "h": 78, "title": ["DevSpace", "Jupyter / VSCode", "التجريب والتحقق"]}, {"id": "G", "x": 344, "y": 950, "w": 156, "h": 62, "title": ["Kubeflow TrainJob", "جدولة GPU مع Kueue"]}, {"id": "H", "x": 351, "y": 1090, "w": 142, "h": 62, "title": ["النموذج المدرَّب", "تخزين داخلي"]}, {"id": "I", "x": 320, "y": 1230, "w": 205, "h": 78, "title": ["نقطة نهاية vLLM بدون خادم", "دائم", "KEDA Scale-to-Zero"]}, {"id": "J", "x": 320, "y": 1386, "w": 205, "h": 94, "title": ["مستهلكو واجهة البرمجة", "الداخلية", "نظام السجلات الطبية / دعم", "القرار السريري"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [422, 118, 422, 196]}, {"src": "B", "dst": "C", "kind": "data", "line": [422, 258, 422, 336]}, {"src": "C", "dst": "D", "kind": "data", "line": [422, 430, 422, 508]}, {"src": "D", "dst": "E1", "kind": "data", "curve": [[534, 558], [725, 599], [725, 599], [725, 638]]}, {"src": "D", "dst": "E2", "kind": "data", "curve": [[460, 560], [517, 599], [517, 599], [517, 646]]}, {"src": "D", "dst": "E3", "kind": "data", "curve": [[384, 560], [327, 599], [327, 599], [327, 646]]}, {"src": "D", "dst": "E4", "kind": "data", "curve": [[311, 558], [116, 599], [116, 599], [116, 646]]}, {"src": "E1", "dst": "F", "kind": "data", "curve": [[725, 716], [725, 755], [725, 755], [493, 815]]}, {"src": "E2", "dst": "F", "kind": "data", "curve": [[517, 708], [517, 755], [517, 755], [470, 794]]}, {"src": "E3", "dst": "F", "kind": "data", "curve": [[327, 708], [327, 755], [327, 755], [375, 794]]}, {"src": "E4", "dst": "F", "kind": "data", "curve": [[116, 708], [116, 755], [116, 755], [351, 815]]}, {"src": "F", "dst": "G", "kind": "data", "line": [422, 872, 422, 950]}, {"src": "G", "dst": "H", "kind": "data", "line": [422, 1012, 422, 1090]}, {"src": "H", "dst": "I", "kind": "data", "line": [422, 1152, 422, 1230]}, {"src": "I", "dst": "J", "kind": "data", "line": [422, 1308, 422, 1386]}]});
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
      const container = document.getElementById('hcareonpremllmfinetuning-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'hcareonpremllmfinetuning-1';
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

*يُمثّل المخطط أعلاه تدفقًا مفاهيميًا؛ قد تختلف معاملات الإعداد الفعلية بحسب البيئة.*

### المرحلة الأولى: إعداد مجموعة البيانات ورفعها

لا يمكن استخدام البيانات الطبية في الضبط الدقيق بشكلها الخام. يجب أن تمر عبر خط أنابيب ETL الداخلي بالمستشفى لإخفاء الهوية (إزالة الأسماء وأرقام الهوية الوطنية وأرقام تسجيل المستشفى)، وتحويل التنسيق (تحويل FHIR JSON أو النص الحر إلى أزواج تعليمات-استجابة)، وتصفية الجودة (إزالة التكرارات والسجلات ذات الأحجام الشاذة).

تُرفع البيانات المعالجة بعد ذلك إلى التخزين الداخلي عبر مدير مجموعات البيانات في ThakiCloud. نظرًا لدعم المنصة لتنسيق مجموعات بيانات HuggingFace والتخزين المتوافق مع S3، يكون التكامل مع خطوط بيانات قائمة سهلًا. تتيح ميزات وحدات التخزين والنسخ الاحتياطية إدارة إصدارات مجموعات البيانات والتراجع إلى إصدارات سابقة عند الحاجة.

```python
# مثال مفاهيمي - عنصر نائب، وليس مواصفة API الفعلية
dataset_config = {
    "name": "clinical-notes-sft-v1",
    "format": "jsonl",
    "schema": {
        "instruction": "string",   # مثال: "لخّص الملاحظة السريرية التالية."
        "input": "string",         # نص الملاحظة السريرية
        "output": "string"         # ملخص يكتبه الأخصائي
    },
    "storage": "s3://internal-bucket/datasets/clinical-notes/",
    "privacy_level": "restricted"  # تقييد الوصول عبر RBAC
}
```

يتحكم RBAC المبني على Keycloak في أذونات الوصول إلى مجموعات البيانات على مستوى المؤسسة والمشروع والدور الوظيفي. لا يتمكن أعضاء فريق البحث إلا من رؤية مجموعات البيانات الخاصة بمشاريعهم، ويُحظر خلط بيانات المؤسسات على مستوى النظام.

### المرحلة الثانية: اختيار أسلوب الضبط الدقيق

تدعم منصة ThakiCloud AI Platform ستة أساليب للضبط الدقيق، ويُختار من بينها وفقًا لخصائص المجال الصحي.

**SFT (الضبط الدقيق الخاضع للإشراف)**: الأسلوب الأكثر وضوحًا وبداهة، ويناسب الحالات التي تتوفر فيها بيانات أزواج تعليمات-استجابة كافية. مناسب للمهام ذات الإجابات الصحيحة الواضحة كتلخيص الملاحظات السريرية وتصنيف رموز الوصفات وتفسير نتائج الفحوصات. تُعدّ جودة البيانات أمرًا بالغ الأهمية؛ إذ كثيرًا ما تتفوق مجموعة بيانات صغيرة عالية الجودة مُراجَعة من متخصصين على كميات ضخمة من البيانات غير المدققة.

**LoRA / QLoRA (التكيّف منخفض الرتبة)**: يُتيح الضبط الدقيق الكفؤ للنماذج الأساسية الكبيرة في بيئات محدودة ذاكرة GPU. نظرًا لتدريب طبقات المحوّل فحسب، يُحدَّث [تقديري] 1-5% فقط من المعاملات مقارنةً بإجمالي المعاملات. وهو خيار واقعي للمستشفيات الصغيرة والمتوسطة أو المعاهد البحثية التي تمتلك عددًا محدودًا من وحدات GPU من طراز A100 وتحتاج إلى ضبط نماذج بحجم Llama-3 70B أو Qwen-2.5 72B.

**DPO (التحسين المباشر للتفضيلات)**: يتدرب على بيانات التفضيلات حيث يُختار الرد الأفضل من بين خيارين. يلائم هذا الأسلوب تضمين متطلبات المجال الصحي كـ"يجب أن يُقدّم نظام مساعدة التشخيص إجابات أكثر أمانًا وتحفظًا". ويُستخدم أساسًا كمرحلة توافق تلي SFT.

**CPT (التدريب المسبق المستمر)**: يُستخدم لحقن المعرفة المتخصصة في النموذج الأساسي باستخدام كميات كبيرة من النصوص غير المنظمة كالأوراق الطبية والكتب الدراسية في الصيدلة والإرشادات السريرية. تكون كميات البيانات كبيرة ووقت التدريب طويلًا، غير أن النموذج يكتسب فهمًا أعمق للمصطلحات والمفاهيم الطبية.

**GKD (التقطير المعرفي المعمَّم)**: ينقل المعرفة من نموذج معلّم أكبر (تم التحقق منه داخليًا) إلى نموذج طالب أصغر. يفيد هذا الأسلوب حين يجب تخفيض تكاليف الاستدلال مع الحفاظ على الجودة، وهو مناسب حين يجب أن يكون نموذج الخدمة الفعلي صغيرًا وسريعًا مع الاستفادة القصوى من خبرة النموذج المعلّم.

**GRPO (تحسين السياسة النسبي للمجموعات)**: نهج قائم على التعلم المعزز يستخدم مكافآت نسبية للمجموعات. يُطبَّق على مهام التشخيص الطبي التي تستلزم استدلالًا معقدًا أو لتعزيز إرشادات أمان بعينها.

### المرحلة الثالثة: التجريب والتحقق في DevSpace

قبل إطلاق عملية الضبط الدقيق الكاملة، تُجرى تجارب على نطاق صغير في DevSpace. DevSpace هي بيئة Jupyter Notebook أو VS Code تعمل على Kubernetes Pod مع وصول مباشر إلى وحدات GPU في المجموعة الداخلية.

يتصل الباحثون ببيئة DevSpace عبر Pod SSH ويختبرون نصوص التدريب على مجموعة فرعية صغيرة من البيانات. يُتيح إتمام ضبط المعاملات الفائقة (معدل التعلم وحجم الدفعة ورتبة LoRA وما إلى ذلك) والتحقق من تنسيق البيانات في هذه المرحلة تقليل وقت GPU المُهدَر في مهام التدريب الكاملة لاحقًا.

```bash
# مثال على الاتصال بـ DevSpace Pod (عنصر نائب - تعتمد الأوامر الفعلية على إعدادات المنصة)
# ssh <devspace-pod-name>.<namespace>.svc.cluster.local

# مثال تجربة LoRA على نطاق صغير
python train.py \
  --model_name_or_path /mnt/models/llama3-8b \
  --data_path /mnt/datasets/clinical-notes-sample \
  --method lora \
  --lora_r 16 \
  --lora_alpha 32 \
  --num_train_epochs 3 \
  --per_device_train_batch_size 4 \
  --output_dir /mnt/checkpoints/exp-001
```

### المرحلة الرابعة: التدريب الكامل باستخدام Kubeflow TrainJob

حين تكون نتائج التجارب مُرضية، يُطلق تدريب كامل على مجموعة البيانات الكاملة عبر Kubeflow TrainJob. يتشارك Kueue ومُجدوِل KAI موارد GPU مع أعباء العمل الأخرى في المستشفى مع تخصيص وحدات GPU اللازمة لمهام التدريب وفق الأولويات.

يمكن أيضًا الإعلان عن التدريب الموزع متعدد GPU (مثل PyTorch DDP أو DeepSpeed ZeRO) بصورة تصريحية في مواصفات Kubeflow TrainJob.

```yaml
# مثال مفاهيمي على TrainJob - عنصر نائب
apiVersion: kubeflow.org/v1
kind: PyTorchJob
metadata:
  name: clinical-notes-sft-run1
  namespace: hospital-ai
spec:
  pytorchReplicaSpecs:
    Master:
      replicas: 1
      template:
        spec:
          containers:
          - name: trainer
            image: registry.internal/thakicloud/trainer:v1.2
            args:
            - "--method=sft"
            - "--data=/mnt/datasets/clinical-notes-v1"
            - "--model=/mnt/models/qwen2.5-7b"
            - "--output=/mnt/checkpoints/clinical-qwen-v1"
            resources:
              limits:
                nvidia.com/gpu: "4"
    Worker:
      replicas: 3
      # ...
```

توفر قياسات DCGM لـ GPU مراقبة فورية لمعدل استخدام GPU واستهلاك الذاكرة ودرجات الحرارة أثناء التدريب. تُولَّد تنبيهات عند ظهور شذوذات، ويمكن إعادة التشغيل بأمان بالاستناد إلى نقاط التحقق.

تُخزَّن النماذج المدرَّبة في التخزين الداخلي (بما يشمل إدارة وحدات التخزين والنسخ الاحتياطية). لا تغادر البيانات المجموعة الداخلية من البداية حتى النهاية.

---

## الخدمة والتشغيل

### نقطة نهاية vLLM بدون خادم دائم

تُقدَّم النماذج المتخصصة المدرَّبة عبر نقطة نهاية استدلال بدون خادم دائم مبنية على vLLM. تستخدم vLLM تقنية PagedAttention لإدارة ذاكرة GPU بكفاءة، وتحقق إنتاجية عالية من خلال المعالجة الدفعية المستمرة (continuous batching).

يُنفَّذ التكامل مع KEDA (التحجيم التلقائي المدفوع بالأحداث في Kubernetes) لتحقيق وظيفة Scale-to-Zero. حين لا توجد طلبات، يتقلص خادم الاستدلال إلى صفر، ثم يتوسع تلقائيًا عند وصول الطلبات. نظرًا لتركّز أنماط استخدام LLM في المستشفيات في ساعات النهار عادةً، لا داعي لإبقاء وحدات GPU في حالة خمول طوال الليل.

```yaml
# مثال مفاهيمي على KEDA ScaledObject - عنصر نائب
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: clinical-llm-endpoint
  namespace: hospital-ai
spec:
  scaleTargetRef:
    name: clinical-llm-deployment
  minReplicaCount: 0      # Scale-to-Zero
  maxReplicaCount: 4
  triggers:
  - type: prometheus
    metadata:
      serverAddress: http://prometheus:9090
      metricName: vllm_requests_pending
      threshold: "5"      # التوسع عند وجود 5 طلبات معلّقة أو أكثر
```

### هيكل تكاليف الاستدلال

تعتمد واجهات برمجة تطبيقات LLM الخارجية (كـ GPT-4 API) نموذج الفوترة بالرمز المميز. بالنسبة للمهام ذات النوافذ السياقية الطويلة كتلخيص الملاحظات السريرية، يمكن أن يتصاعد الفاتورة الشهرية بسرعة. علاوة على ذلك، يُشكّل إرسال البيانات السريرية عبر واجهة برمجة التطبيقات المخاطر التنظيمية المذكورة آنفًا.

تستلزم نقطة نهاية vLLM الداخلية استثمارًا أوليًا في بنية تحتية لـ GPU، لكن لا تتكبّد بعدها تكاليف إضافية لكل رمز مميز. إذا أمكن إعادة استخدام خوادم GPU التي يمتلكها المستشفى فعلًا أو البنية التحتية HPC المخصصة للأبحاث السريرية، فإن التكاليف الهامشية تنخفض إلى مستوى استهلاك الكهرباء ونفقات العمالة التشغيلية.

### RBAC وعزل المستأجرين المتعددين

تحتاج المؤسسات الصحية الكبيرة إلى أقسام سريرية وفرق بحثية وإدارية مختلفة تصل إلى بيانات ونماذج متباينة. تُدير RBAC المبنية على Keycloak في ThakiCloud الأذونات على مستوى المؤسسة والمشروع والدور الوظيفي (مدير / مطوّر / مشاهد). تُضمَّن معلومات المجموعة في رموز JWT للتحقق الفوري من الوصول.

يمكن تقييد نطاق نموذج مساعدة تشخيص السكري الذي ضبطه فريق أمراض الغدد الصماء بمشروعه حتى لا يتمكن فريق أمراض القلب من الوصول إليه. هذا يُقلّص ليس فحسب عزل البيانات الداخلي، بل أيضًا مخاطر سوء استخدام النموذج (النموذج الخاطئ في السياق الخاطئ).

### قياس الأداء مع lm-eval

لقياس جودة النموذج كميًا قبل الخدمة، تُستخدم ميزة قياس الأداء lm-eval. تُسجَّل مجموعات تقييم متخصصة في المجال الصحي مبنية داخليًا (مجموعات QA مُدقَّقة من متخصصين)، ويُقاس حجم التحسن الذي حققه النموذج المدرَّب مقارنةً بالنموذج الأساسي.

---

## رؤى التطبيق في ThakiCloud

### حالة افتراضية: تلخيص الملاحظات السريرية في مستشفى عام من الدرجة الثالثة

لنأخذ مستشفى (أ) الافتراضي مثالًا. كانت تواجه مشكلة أن كتابة ملخصات الخروج للمرضى المقيمين تستغرق وقتًا طبيًا مقدّرًا. وكان إدخال واجهة برمجة تطبيقات AI الخارجية صعبًا بسبب إجراءات معقدة تشمل عقود الاستعانة بمعالجة البيانات الشخصية ومراجعات أمنية وموافقات لجان حماية المعلومات.

لو اختارت نهجًا داخليًا، فقد كان يسير على النحو التالي:

1. تعالج بيانات ملخصات الخروج التاريخية مجهولة الهوية (أزواج الملاحظات السريرية الأصلية والملخصات التي يكتبها المتخصصون) عبر خط ETL الداخلي.
2. تُرفع البيانات إلى مدير مجموعات بيانات ThakiCloud وتُمنح أذونات الوصول لمشروع فريق المعلومات السريرية.
3. تُجرى تجارب SFT على نطاق صغير في DevSpace لاستكشاف النموذج الأساسي المناسب (مثل Llama-3 8B أو Qwen2.5 7B) والمعاملات الفائقة.
4. يُطلق التدريب الكامل عبر Kubeflow TrainJob مع استخدام التدريب الموزع عبر 8 عقد GPU داخل المستشفى.
5. حين تستوفي درجات ROUGE و QA للمجال المقيسة بـ lm-eval معايير الجودة، يُنشر النموذج كنقطة نهاية vLLM.
6. يستدعي نظام السجلات الطبية الإلكترونية واجهة البرمجة الداخلية لتلقّي نتائج التلخيص وتقديم مسودات للأطباء.

لا تغادر البيانات مركز بيانات مستشفى (أ) قط.

### حالة افتراضية: تحليل أدبيات التجارب السريرية في معهد أبحاث دوائية

سعى معهد (ب) الافتراضي إلى أتمتة استخراج إشارات السلامة من وثائق بروتوكولات التجارب السريرية وتقارير الآثار الجانبية للأدوية. كانت هذه البيانات تحتوي على معلومات المشاركين في الأبحاث ونتائج سريرية غير منشورة مما جعل تصديرها الخارجي مستحيلًا.

نهج من مرحلتين يبدو فعّالًا هنا: استخدام CPT على مئات الآلاف من الأدبيات الطبية المتاحة داخليًا لتعزيز معرفة النموذج الأساسي بالمجال، ثم استخدام SFT لتخصيصه لمهمة استخراج إشارات السلامة. مع إعداد Scale-to-Zero، لا تُخصَّص وحدات GPU إلا حين يستخدمها فريق البحث، ويمكن لأعباء العمل الحسابية الأخرى الاستفادة من وحدات GPU في الليل وعطلات نهاية الأسبوع.

---

## القيود والاعتبارات

### متطلبات القدرات التشغيلية

تستلزم منصة LLM الداخلية، خلافًا لـ SaaS الخارجي، قدرات تشغيلية داخلية. يحتاج الأمر إلى مهندسي MLOps يتولّون إدارة مجموعات Kubernetes وصيانة تعريفات برامج تشغيل GPU وإدارة إصدارات النماذج وتطبيق تحديثات الأمان. بالنسبة للمستشفيات أو المعاهد البحثية الصغيرة، قد يكون تبنّي هذه القدرات داخليًا أمرًا عسيرًا.

### جودة البيانات تحدد الأداء

تعتمد نتائج الضبط الدقيق اعتمادًا مطلقًا على جودة البيانات. إجراء SFT على ملاحظات سريرية غير مُدقَّقة من متخصصين قد يُفضي إلى تعلّم أخطاء. يجب التخطيط مسبقًا لوقت الأطباء المتخصصين وتكاليف عملية التعليق (annotation) اللازمة لإنتاج بيانات مُصنَّفة عالية الجودة.

### التحقق من تراخيص النماذج الأساسية

حتى عند تطبيق LoRA أو SFT، يجب التحقق حتمًا من شروط ترخيص النموذج الأساسي. تتباين صلاحيات الاستخدام التجاري وبنود تقييد الاستخدام لأغراض طبية من نموذج لآخر. حتى النماذج مفتوحة المصدر الرئيسية كـ Llama-3 وQwen وGemma لكل منها شروط استخدام مختلفة، لذا يجب أن تسبق مراجعة الفريق القانوني أي نشر.

### إدارة زمن استجابة الاستدلال

مع إعداد Scale-to-Zero، يحدث زمن تحميل النموذج (البدء البارد) عند أول طلب. حتى نموذج بحجم 7B يمكن أن يستغرق عشرات الثواني للتحميل على GPU. بالنسبة للتطبيقات الحساسة لزمن الاستجابة كدعم القرار السريري الفوري، يجب إبقاء الحد الأدنى لعدد النسخ عند 1، أو تطبيق استراتيجية تسخين مسبق مختلفة.

### التحقق من النماذج والامتثال التنظيمي

قد تخضع أنظمة دعم القرار الطبي المعتمدة على الذكاء الاصطناعي لإجراءات اعتماد الأجهزة الطبية من قِبَل الجهات التنظيمية المختصة. إذا استُخدم النموذج بطريقة تُصدر "تشخيصات"، يجب مراجعة لوائح البرمجيات بوصفها أجهزة طبية (SaMD). تُعدّ نتائج قياس الأداء lm-eval وبيانات التحقق الداخلي أدلة داعمة في هذه العملية. غير أن الامتثال التنظيمي يتجاوز نطاق ميزات المنصة ويستلزم استشارة تنظيمية متخصصة.

---

في اعتماد النماذج اللغوية الكبيرة في قطاع الرعاية الصحية والعلوم الحيوية، يسبق السؤال "كيف نوظّف الذكاء الاصطناعي مع حماية البيانات" كونه مسألة تقنية ليكون مسألة حوكمة. منصة الضبط الدقيق الداخلية إجابة عملية على هذا السؤال. لقد نضج نهج الإبقاء على البيانات داخل المنشأة دون التفريط في جودة النموذج ليصبح قابلًا للتشغيل الفعلي في بيئة Kubernetes.

*الحالات الافتراضية الواردة في هذه الوثيقة مكتوبة لأغراض توضيحية ولا تشير إلى مؤسسات فعلية. يُوصى بمراجعة الفريق القانوني والخبراء التنظيميين قبل بناء نظام ذكاء اصطناعي للرعاية الصحية.*
