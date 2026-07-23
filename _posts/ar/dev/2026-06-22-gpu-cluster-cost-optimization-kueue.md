---
title: "تحسين تكاليف تشغيل مجموعة GPU: Kueue Fair-Share + Gang Scheduling + Scale-to-Zero"
excerpt: "شرح كيفية استرداد ما يصل إلى عشرات الملايين من الدولارات سنويًا المُهدَرة في ثلاث نقاط اختناق في مجموعة GPU مؤلفة من 1000 وحدة، باستخدام جدولة Kubernetes الأصيلة."
seo_title: "تحسين تكاليف مجموعة GPU: Kueue Fair-Share و Gang Scheduling و Scale-to-Zero - Thaki Cloud"
seo_description: "معمارية Kubernetes الأصيلة التي تخفض تكاليف توقف GPU بنسبة 30-50% باستخدام جدولة Kueue GPU و vLLM Scale-to-Zero، موضحةً من منظور تشغيل ThakiCloud."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: ar
tags:
  - kueue
  - gpu-scheduling
  - cost-optimization
  - kubernetes
  - vllm
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/gpu-cluster-cost-optimization-kueue/"
reading_time: true
categories:
  - dev
published: false
---

![تحسين تكاليف مجموعة GPU - معمارية Kueue Fair-Share و Gang Scheduling و Scale-to-Zero]({{ '/assets/images/gpu-cluster-cost-optimization-kueue-hero.webp' | relative_url }})

## نظرة عامة

تواجه كل منظمة تُشغِّل مجموعة GPU مؤسسية الحقيقة المُزعجة ذاتها: الفجوة بين حجم الاستثمار في الأجهزة ومعدل الاستخدام الفعلي. عندما تبلغ معدلات توقف GPU نسبة 30-50% في مجموعة مؤلفة من 1000 وحدة، يُترجَم ذلك إلى هدر يبلغ عشرات الملايين من الدولارات سنويًا [تقديري/أرقام وثائق العرض التقديمي]. هذه ليست تكلفة الأجهزة -- بل هي تكلفة دفع فواتير الطاقة والتبريد دون إجراء أي حسابات.

يكمن جوهر المشكلة في عجز الإنسان عن تحسين جدولة أعباء العمل بسرعة الآلة. تُهدر مهام التدريب الموزع الموارد المُقتناة جزئيًا عندما تفشل في تأمين جميع حاويات GPU في آنٍ واحد. يؤدي تنافس الفرق المتعددة على قائمة انتظار المجموعة ذاتها إلى تصادم في الأولويات وتأخر في مهام التدريب الحرجة. تحتجز خدمات الاستدلال وحدات GPU طوال الليل دون أي حركة مرور.

تعالج منصة ThakiCloud AI هذه الاختناقات الثلاثة بمزيج من Kueue والمجدول المخصص KAI، إلى جانب vLLM وKEDA Scale-to-Zero. يشرح هذا المقال كيفية عمل كل آلية فعليًا، وما هي قرارات المعمارية التي تُتيح استرداد التكاليف.

---

## 3 نقاط تتسرب منها تكاليف GPU

### النقطة 1: توقف GPU بلا جدولة

عند مشاركة فرق متعددة لمجموعة K8s دون إدارة قوائم الانتظار، لا تكون العدالة مضمونة. الفريق الذي يُنفِّذ `kubectl apply` أولًا يستحوذ على وحدات GPU، وتظل طلبات الفريق الأحدث في حالة انتظار. عند انتهاء مهمة الفريق الأول، تُحرَّر وحدات GPU -- لكن إذا لم تكن ثمة مهمة تالية في الانتظار فورًا، فإن وحدات GPU تظل خاملة لفترة وجيزة. تتراكم هذه الفجوات عبر المجموعة بأكملها وتُخفِّض معدل الاستخدام الفعلي بشكل ملحوظ.

### النقطة 2: تأخر التدريب الموزع بسبب غياب Gang Scheduling

لا يمكن لمهام التدريب الموزع (DDP وMegatron وDeepSpeed وما شابهها) بدء حساب ذي معنى إلا عند انطلاق جميع حاويات العمل في الوقت ذاته. بغياب Gang Scheduling، تحدث الظاهرة التالية:

- مهمة تتطلب 8 وحدات GPU تُطلق 6 حاويات، لكن حاويتين تظلان معلقتين (Pending) بسبب شح العقد
- تحتجز الحاويات الست المُشغَّلة وحدات GPU انتظارًا للحاويتين المعلقتين دون تنفيذ أي حسابات
- تستمر حالة الاحتلال الجزئي هذه لعشرات الدقائق، وأحيانًا لساعات

عندما تدخل مهمة صغيرة من فريق آخر إلى المجموعة في هذه الحالة، تتشظى الموارد المتبقية أكثر، مما يجعل المهمة الكبرى تنتظر مدة أطول.

### النقطة 3: احتجاز GPU المستمر من قِبَل نقاط نهاية الاستدلال

تُخصِّص نقاط نهاية تقديم النماذج ذاكرة GPU لحظة إقلاعها الأول. تحتجز خدمات الاستدلال المنشورة دون KEDA أو مُوسِّع مشابه وحدات GPU في الساعة الثانية صباحًا دون أي طلبات. قد يبدو احتجاز 1-2 وحدة GPU غير ضروري أمرًا هيِّنًا للمنظمات الصغيرة، لكن لدى المنظمات التي تُشغِّل عشرات نقاط نهاية النماذج يتضاعف هذا الهدر بشكل هندسي.

---

## Kueue Fair-Share + Gang Scheduling

### تسلسل ClusterQueue و LocalQueue

Kueue هو نظام إدارة قوائم انتظار أعباء العمل الأصيل في Kubernetes، ويتكون من طبقتين: `ClusterQueue` و`LocalQueue`. تُحدِّد `ClusterQueue` سياسة تخصيص GPU عبر المجموعة بأكملها؛ أما `LocalQueue` فهي قائمة الانتظار المرئية لكل مساحة أسماء فردية (فريق/مشروع).

```yaml
# مثال مفاهيمي -- ليس التقاطًا تنفيذيًا
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: research-cluster-queue
spec:
  namespaceSelector: {}
  resourceGroups:
    - coveredResources: ["cpu", "memory", "nvidia.com/gpu"]
      flavors:
        - name: "h100-flavor"
          resources:
            - name: "nvidia.com/gpu"
              nominalQuota: 64      # الحصة الافتراضية لكل فريق
              borrowingLimit: 32    # حد أقصى لاستعارة الحصة غير المستخدمة من الفرق الأخرى
              lendingLimit: 16      # حد أقصى للإقراض للفرق الأخرى
  cohort: "all-teams"              # مجموعة المشاركة العادلة
```

حقل `cohort` هو جوهر المشاركة العادلة. يمكن لموارد `ClusterQueue` المنتمية إلى المجموعة ذاتها استعارة `nominalQuota` غير المستخدمة من بعضها البعض ضمن حدود `borrowingLimit`. إذا لم يكن الفريق A يستخدم وحدات GPU الخاصة به في الليل، يمكن للفريق B استعارتها مؤقتًا؛ وعند تقديم الفريق A طلبات جديدة تُعاد إليه الأولوية.

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
<div class="d3-arch" data-arch-root id="tercostoptimizationkueue-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 676, "height": 446, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "CQ", "x": 235, "y": 24, "w": 198, "h": 94, "title": ["ClusterQueue", "(research-cluster-queue)", "cohort: all-teams", "H100 x 64 nominalQuota"]}, {"id": "LQ_A", "x": 474, "y": 196, "w": 170, "h": 62, "title": ["LocalQueue: team-a", "namespace: ml-team-a"]}, {"id": "LQ_B", "x": 249, "y": 196, "w": 170, "h": 62, "title": ["LocalQueue: team-b", "namespace: ml-team-b"]}, {"id": "LQ_C", "x": 24, "y": 196, "w": 170, "h": 62, "title": ["LocalQueue: team-c", "namespace: ml-team-c"]}, {"id": "WL_A", "x": 485, "y": 336, "w": 149, "h": 78, "title": ["WorkloadAdmission", "مهمة تدريب A", "طلب GPU: 8"]}, {"id": "WL_B", "x": 260, "y": 336, "w": 149, "h": 78, "title": ["WorkloadAdmission", "دُفعة استدلال B", "طلب GPU: 4"]}, {"id": "WL_C", "x": 35, "y": 336, "w": 149, "h": 78, "title": ["WorkloadAdmission", "الضبط الدقيق C", "طلب GPU: 16"]}], "edges": [{"src": "CQ", "dst": "LQ_A", "kind": "data", "curve": [[433, 109], [559, 157], [559, 157], [559, 196]]}, {"src": "CQ", "dst": "LQ_B", "kind": "data", "line": [334, 118, 334, 196]}, {"src": "CQ", "dst": "LQ_C", "kind": "data", "curve": [[235, 109], [109, 157], [109, 157], [109, 196]]}, {"src": "LQ_A", "dst": "WL_A", "kind": "data", "line": [559, 258, 559, 336]}, {"src": "LQ_B", "dst": "WL_B", "kind": "data", "line": [334, 258, 334, 336]}, {"src": "LQ_C", "dst": "WL_C", "kind": "data", "line": [109, 258, 109, 336]}]});
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
      const container = document.getElementById('tercostoptimizationkueue-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'tercostoptimizationkueue-1';
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

في هذا الهيكل، تتتبع Kueue معدل استهلاك `nominalQuota` لكل فريق وتتخذ قرارات القبول (admission) لضمان التوزيع العادل داخل المجموعة. عندما يتجاوز فريق ما `nominalQuota` الخاص به في حالة استعارة ويُقدِّم فريق آخر طلبًا، تنخفض أولوية حِمل العمل المستعار تلقائيًا.

### مُجدِّل KAI و Gang Scheduling

يضع مُجدِّل Kubernetes الافتراضي الحاويات بشكل فردي. يُتطلَّب Gang Scheduling لأعباء العمل مثل التدريب الموزع حيث يجب انطلاق جميع الحاويات في آنٍ واحد. تُنفِّذ ThakiCloud ذلك عبر مكوِّن المُجدِّل المخصص KAI (Kubernetes AI).

المبدأ الأساسي لـ Gang Scheduling هو "الكل أو لا شيء." لن تُوضَع أي حاوية من مهمة التدريب الموزع الطالبة 16 وحدة GPU على أي عقدة حتى يمكن تأمين الـ 16 وحدة في آنٍ واحد. يُلغي ذلك الهدر الناجم عن الاحتلال الجزئي.

```yaml
# مثال مفاهيمي -- ليس التقاطًا تنفيذيًا
apiVersion: batch/v1
kind: Job
metadata:
  name: distributed-training-llama3
spec:
  parallelism: 16   # 16 حاوية عمل تعمل في وقت واحد
  completions: 16
  template:
    metadata:
      annotations:
        kueue.x-k8s.io/queue-name: "team-a-local-queue"
    spec:
      schedulingGates:
        - name: "kueue.x-k8s.io/admission"   # بوابة الجدولة حتى منح Kueue القبول
      containers:
        - name: trainer
          resources:
            limits:
              nvidia.com/gpu: "1"
```

من خلال `schedulingGates`، لا يتعامل مُجدِّل Kubernetes مع حاويات هذه المهمة حتى تمنح Kueue القبول. بمجرد تأكيد Kueue توفر مساحة لـ 16 وحدة GPU في المجموعة وإزالة البوابة، يضع مُجدِّل KAI الحاويات الـ 16 جميعها في آنٍ واحد على العقد المثلى.

يُنفِّذ مُجدِّل KAI أيضًا التوزيع المدرك للطوبولوجيا (topology-aware placement) عند تخصيص وحدات GPU. يُفضِّل اختيار العقد داخل الرف ذاته المرتبط بـ InfiniBand لتقليل تكاليف الاتصال في التدريب الموزع. يؤثر ذلك مباشرةً ليس فقط في معدل استخدام GPU بل في سرعة التدريب أيضًا.

### ResourceFlavor ومعالجة تغاير العقد

تتضمن بيئات الإنتاج الفعلية مزيجًا من أنواع GPU المختلفة -- H100 وA100 ومثيلات MIG وغيرها. تجرِّد `ResourceFlavor` في Kueue هذا التغاير.

```yaml
# مثال مفاهيمي -- ليس التقاطًا تنفيذيًا
apiVersion: kueue.x-k8s.io/v1beta1
kind: ResourceFlavor
metadata:
  name: h100-full
spec:
  nodeLabels:
    nvidia.com/gpu.product: "NVIDIA-H100-80GB-HBM3"
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: ResourceFlavor
metadata:
  name: h100-mig-3g
spec:
  nodeLabels:
    nvidia.com/gpu.product: "NVIDIA-H100-80GB-HBM3"
    nvidia.com/mig.profile: "3g.40gb"
```

تُوجِّه `ClusterQueue` المهام تلقائيًا إلى `ResourceFlavor` المناسبة بحسب خصائص حِمل العمل. تُوجَّه مهام الضبط الدقيق الصغيرة إلى شرائح MIG، بينما تُوضَع مهام التدريب المسبق الكبيرة على وحدات GPU الكاملة. لا حاجة لكتابة قواعد Node Affinity يدويًا في كل مرة.

---

## تكاليف الاستدلال: vLLM Scale-to-Zero

### التوسع التلقائي المبني على HTTP بواسطة KEDA

تمتلك خدمات الاستدلال خصائص مختلفة عن أعباء عمل التدريب. يستهلك التدريب وحدات GPU باستمرار من البداية حتى النهاية، لكن الاستدلال لا يحتاج إلى وحدات GPU في الفترات التي لا توجد فيها طلبات.

تُشغِّل ThakiCloud نقاط نهاية الاستدلال بأسلوب بدون خادم (serverless) باستخدام مزيج vLLM + KEDA. يراقب محوِّل HTTP في KEDA الطلبات الواردة إلى نقطة النهاية ويُعدِّل عدد نسخ vLLM تلقائيًا بحسب حجم الطلبات.

```yaml
# مثال مفاهيمي -- ليس التقاطًا تنفيذيًا
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: llm-inference-scaler
spec:
  scaleTargetRef:
    name: vllm-llama3-deployment
  minReplicaCount: 0      # يُسمح بالتوسيع إلى الصفر
  maxReplicaCount: 8
  cooldownPeriod: 300     # انتظار 5 دقائق بعد آخر طلب قبل التقليص إلى 0
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://victoria-metrics:8428
        metricName: http_requests_per_second
        threshold: "10"   # 10 طلبات في الثانية لكل نسخة
        query: sum(rate(vllm_request_success_total[1m]))
```

`minReplicaCount: 0` هو مفتاح Scale-to-Zero. عند عدم وجود طلبات في الساعة الثانية صباحًا، تُقلَّص حاوية vLLM إلى الصفر وتُعيد وحدة GPU. عند وصول أول طلب مع بدء يوم العمل، تُشغِّل KEDA الحاوية، تُحمِّل vLLM النموذج في ذاكرة GPU، ثم تُعاد الاستجابة.

### مقايضة زمن انتظار البدء البارد

العيب الواضح لـ Scale-to-Zero هو زمن انتظار البدء البارد (cold start latency). قد يستغرق تحميل نموذج بـ 7 مليارات معامل في vLLM عشرات الثواني. يُعالَج ذلك بإحدى الاستراتيجيات الثلاث التالية وفقًا لمتطلبات اتفاقية مستوى الخدمة (SLA).

أولًا، ضبط `minReplicaCount: 1` للإبقاء دائمًا على نسخة واحدة على الأقل. يُقايض ذلك تكلفة احتجاز وحدة GPU واحدة دائمًا باستجابية خالية من البدء البارد.

ثانيًا، إعداد جدول إحماء مسبق (pre-warm) قائم على ساعات العمل. يرفع CronJob أو مُجدِّل خارجي عدد النسخ إلى 1 قبل ثلاثين دقيقة من بدء العمل، ثم يُنفِّذ Scale-to-Zero بعد انتهاء ساعات العمل.

ثالثًا، الاستفادة من الضغط الكمي (quantization) في vLLM لتقليص زمن التحميل ذاته. النماذج بتنسيق AWQ أو GPTQ أوقات تحميلها أقصر بكثير مقارنةً بـ FP16.

للحصول على أقصى توفير في التكاليف مع الحفاظ على الاستجابية، الأسلوب العملي هو التحقق من أنماط حركة المرور الفعلية لنقطة النهاية في VictoriaMetrics، ثم ضبط مزيج `cooldownPeriod` و`minReplicaCount` ليتوافق مع أنماط الاستخدام.

---

## رؤية التكاليف: DCGM/VictoriaMetrics

### هيكل جمع بيانات قياس GPU عن بُعد

لتحسين التكاليف، يجب معرفة ما يُستهلك وبأي قدر بدقة تامة. تستخدم ThakiCloud مصدِّر NVIDIA DCGM لجمع بيانات قياس GPU الدقيقة على مستوى الوحدة، وتخزينها طويل المدى في VictoriaMetrics.

المقاييس الرئيسية التي يكشفها مصدِّر DCGM هي التالية.

| المقياس | الوصف | الاستخدام في تحليل التكاليف |
|---------|--------|------------------------------|
| `DCGM_FI_DEV_GPU_UTIL` | معدل استخدام وحدة الحوسبة في GPU (%) | خط الأساس لمعدل الاستخدام الفعلي |
| `DCGM_FI_DEV_MEM_COPY_UTIL` | معدل استخدام نطاق ذاكرة GPU | تشخيص الاختناقات المحدودة بالذاكرة |
| `DCGM_FI_DEV_FB_USED` | استخدام المخزن المؤقت للإطارات (MiB) | التحقق من حالة تحميل النموذج |
| `DCGM_FI_PROF_PIPE_TENSOR_ACTIVE` | نسبة نشاط أنوية الموتر (Tensor Core) | ما إذا كانت حسابات الذكاء الاصطناعي الفعلية تجري |

عندما يكون `DCGM_FI_DEV_GPU_UTIL` منخفضًا لكن `DCGM_FI_DEV_FB_USED` مرتفعًا، فإن GPU تحتجز الذاكرة دون تنفيذ حسابات. هذا هو الهدف المباشر لـ Scale-to-Zero.

### إسناد تكاليف GPU لكل فريق

يُتيح دمج بيانات القياس المخزنة في VictoriaMetrics مع تسميات Kubernetes تتبع استهلاك GPU حسب الفريق والمشروع. بما أن `LocalQueue` في Kueue تُعيَّن بعلاقة 1:1 مع مساحات الأسماء، فإن تجميع استخدام GPU وفق تسميات مساحات الأسماء يكشف الاستهلاك الفعلي لكل فريق.

```
# مثال على استعلام VictoriaMetrics (MetricsQL)
# متوسط معدل استخدام GPU حسب مساحة الأسماء (آخر 24 ساعة)
avg by (namespace) (
  avg_over_time(DCGM_FI_DEV_GPU_UTIL{kubernetes_namespace!=""}[24h])
)
```

يُمكِّن تصوير هذه البيانات في لوحة معلومات المسؤولين من رؤية أي الفرق تستخدم وحدات GPU المخصصة لها بكفاءة، وأي المهام تحتجز وحدات GPU لفترات طويلة مع معدلات استخدام منخفضة.

---

## دلالات تطبيق ThakiCloud

يفصل مستوى البيانات في منصة ThakiCloud AI منطقيًا بين مجموعات الاستدلال ومجموعات التدريب ومجموعات التطوير، مع نشر مجموعة التقنيات Kueue + KAI + KEDA ذاتها على كل مجموعة. توفر طبقة إدارة المجموعات المتعددة (MCC) رؤية متكاملة لحالة قوائم الانتظار عبر جميع المجموعات من مستوى تحكم واحد.

من خلال ArgoCD GitOps، تُدار سياسات الجدولة مثل `ClusterQueue` و`ResourceFlavor` و`ScaledObject` بشكل إعلاني من مستودع Git. عند تأهيل فريق جديد أو تعديل `nominalQuota`، تُقترَح التغييرات عبر طلب سحب (PR) وتُراجَع قبل تطبيقها على المجموعة -- بدلًا من استخدام `kubectl apply` مباشرةً. يضمن ذلك مسار تدقيق لتغييرات السياسة ويمنع التخصيص الزائد للموارد بسبب الأخطاء مسبقًا.

يمكن أيضًا أتمتة مُشغِّلات توسيع المجموعة بناءً على المقاييس. عند تجاوز أوقات انتظار قوائم Kueue في VictoriaMetrics 30 دقيقة باستمرار، يُولَّد تنبيه ويُستخدَم كإشارة لإضافة عقد GPU جديدة. عند الحفاظ على متوسط استخدام GPU للمجموعة عند 80% لأكثر من 30 يومًا، يُبادَر إلى مراجعة التوسع بوحدة 72 GPU التالية.

---

## القيود والاعتبارات

### نضج Kueue وتبعيات النظام البيئي

Kueue مشروع CNCF لكنه لا يزال حديثًا نسبيًا. أنواع أعباء العمل الرئيسية بما في ذلك Kubeflow وRay والمهام (Jobs) القياسية مدعومة، لكن بعض الأطر المبنية على CRD المخصص قد تحتاج إلى عمل تكامل إضافي. قبل الاعتماد، من المهم التحقق من توافق أطر عمل ML المستخدمة مع Kueue.

### Gang Scheduling وتفتت المجموعة

يحل Gang Scheduling مشكلة التفتت لكنه يخلق في الوقت ذاته مقايضات جديدة. عند توزع 8 وحدات GPU على عقدتين بواقع 4 لكل منهما في المجموعة، قد تنتظر مهمة طالبة الـ 8 وحدات جميعها في آنٍ واحد انتظارًا طويلًا بسبب Gang Scheduling. في مثل هذه الحالات، يلزم الجمع بين سياسات bin-packing وGang Scheduling وضبطها وفق الوضع.

### التعقيد التشغيلي لـ Scale-to-Zero

بتزايد عدد نقاط نهاية الاستدلال، يزداد عدد KEDA ScaledObjects. يُصبح ضبط `cooldownPeriod` و`threshold` و`minReplicaCount` المناسبين لكل نقطة نهاية والحفاظ عليها عبئًا تشغيليًا. للحد من ذلك، الأسلوب العملي هو تصنيف نقاط النهاية حسب درجة SLA وإدارة نماذج قياسية لكل درجة.

### الشرط المسبق لخفض تكاليف GPU: مقاييس دقيقة

قيمة `GPU_UTIL` التي يجمعها مصدِّر DCGM تمثل نسبة نشاط SM (Streaming Multiprocessor). قيمة منخفضة لا تعني بالضرورة حالة خمول. معدل استخدام SM المنخفض بسبب نسخ الذاكرة أو انتظار الاتصالات هو مشكلة تحسين حِمل العمل لا مشكلة جدولة. للحصول على تشخيص دقيق عند تفسير بيانات القياس، يلزم التحليل المركَّب لمعدل استخدام SM ونطاق الذاكرة ومعدل نشاط أنوية الموتر -- لا مقياس واحد.

---

مجموعة GPU هي في حد ذاتها مورد هائل، لكن دون سياسة جدولة لا يتحقق إمكانها الكامل. المزيج الثلاثي من Kueue Fair-Share لحل تنافس قوائم الانتظار، وGang Scheduling للقضاء على وقت انتظار التدريب الموزع، وScale-to-Zero لمنع تكاليف الاستدلال الخامل هو نقطة الانطلاق العملية لتحسين تكاليف GPU الأصيل في Kubernetes.
