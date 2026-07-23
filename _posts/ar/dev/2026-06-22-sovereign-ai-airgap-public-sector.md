---
title: "دليل بناء الذكاء الاصطناعي السيادي للقطاع العام المعزول: بنية مرجعية لنماذج اللغة الكبيرة على البيئات المحلية"
excerpt: "دليل للمؤسسات الحكومية والقطاع العام التي لا تستطيع استخدام الخدمات السحابية الخارجية لتشغيل نماذج اللغة الكبيرة بأمان على البنية التحتية لوحدات معالجة الرسومات الداخلية. يقدم البنية المرجعية لنشر ThakiCloud AI Platform في البيئات المعزولة، إلى جانب تصميم الأمان والحوكمة."
seo_title: "بنية مرجعية لنماذج اللغة الكبيرة المحلية للقطاع العام المعزول - Thaki Cloud"
seo_description: "بنية مرجعية للمؤسسات الحكومية والقطاع العام في البيئات المعزولة لبناء سحابة ذكاء اصطناعي سيادية محلية. تشمل متطلبات أمان الاستخبارات الوطنية، وإلزامية التخزين المحلي للبيانات، وKeycloak RBAC، وArgoCD GitOps، والاستدلال بدون خادم عبر vLLM."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - sovereign-ai
  - on-premise
  - llm
  - air-gap
  - public-sector
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/saas/sovereign-ai-airgap-public-sector/"
reading_time: true
categories:
  - dev
published: false
---

![بنية مرجعية للذكاء الاصطناعي السيادي للقطاع العام المعزول]({{ '/assets/images/sovereign-ai-airgap-public-sector-hero.webp' | relative_url }})

## نظرة عامة: لماذا يهم الذكاء الاصطناعي السيادي للقطاع العام الآن

منذ عام 2024، تسارعت نقاشات تبني الذكاء الاصطناعي التوليدي في المؤسسات الحكومية والجهات العامة الكورية. غير أن كثيرا من هذه المؤسسات تواجه عقبات جوهرية تحول دون استخدام خدمات نماذج اللغة الكبيرة التجارية المستضافة على السحابة العامة، وذلك بسبب متطلبات الأمان والأطر التشريعية النافذة. فمتطلبات مراقبة الأمن الصادرة عن جهاز الاستخبارات الوطني، والتزامات التخزين المحلي للبيانات بموجب قانون شبكات المعلومات والاتصالات وقانون حماية المعلومات الشخصية، فضلا عن سياسات العزل الشبكي الراسخة، تحول جميعها دون إمكانية إجراء طلبات API إلى جهات خارجية.

في هذا السياق، يتقارب مطلب "الاستفادة من الذكاء الاصطناعي دون السماح للبيانات بمغادرة المنشأة" نحو حل وحيد: تشغيل نماذج اللغة الكبيرة مباشرة على البنية التحتية الداخلية لوحدات معالجة الرسومات، وهو ما يُعرف بـ **الذكاء الاصطناعي السيادي (Sovereign AI)**.

ThakiCloud منصة SaaS للذكاء الاصطناعي والتعلم الآلي قائمة على Kubernetes، صُمِّمت لتدعم النشر الكامل في البيئات المحلية والمعزولة (Air-Gap). يعرض هذا المقال، من خلال حالة افتراضية لجهة حكومية، بنية مرجعية مفصلة لبناء خدمات نماذج اللغة الكبيرة بصورة آمنة في بيئة شبكية منفصلة.

---

## القيود التي تواجهها مؤسسات القطاع العام

### العزل الشبكي والفجوة الهوائية

السمة الأبرز لبيئات تكنولوجيا المعلومات في القطاع العام الكوري هي الفصل التام بين شبكة الإنترنت والشبكة الوظيفية الداخلية. وتتجاوز كثير من الجهات الفصل المنطقي لتشترط إعدادات عزل هوائي حيث تنقطع الشبكة فيزيائيا. في هذه الحالات، لا يمكن إجراء طلبات API للسحابة العامة فحسب، بل يصبح الوصول الخارجي إلى سجلات صور الحاويات (Container Registries) أمرا مستحيلا أيضا. يستلزم ذلك النسخ المسبق لجميع الصور والحزم اللازمة للنشر في سجل داخلي.

### متطلبات أمان جهاز الاستخبارات الوطني

يُلزم برنامج ضمان أمان الحوسبة السحابية (CSAP) وإرشادات مراقبة الأمن الصادرة عن جهاز الاستخبارات الوطني بالاحتفاظ بسجلات تدقيق لتاريخ الوصول إلى الأنظمة، وتطبيق المصادقة متعددة العوامل (MFA)، والتحكم في الوصول القائم على الأدوار (RBAC)، وتخزين جميع البيانات الحساسة داخل الأراضي الكورية. ونظرا لأن طلبات الاستدلال الموجهة إلى نماذج اللغة الكبيرة قد تتضمن محتوى استفسار يُصنَّف في حد ذاته معلومة حساسة، فإن نقاط نهاية الاستدلال (Inference Endpoints) تخضع هي الأخرى لنطاق هذه الضوابط.

### قيود الشبكة في البيئات المحلية

يفرض تصميم عناوين URL للخدمات في البيئات المحلية قيودا متميزة. فمن الثابت في هذا السياق أن بيئات الاشتغال المحلي كثيرا ما لا تتيح استخدام نطاقات DNS البديلة (Wildcard DNS) وشهادات SSL البديلة (Wildcard SSL) معا. لذا يتعين إما التحديد المسبق لمجموعة ثابتة من النطاقات الفرعية (مثل: `api.aiplatform.agency.go.kr`، `console.aiplatform.agency.go.kr`)، أو اعتماد نهج رقم المنفذ للتمييز بين الخدمات على اسم مضيف واحد. ينبغي أخذ هذه القيود بعين الاعتبار منذ مرحلة تصميم المنصة.

### إلزامية التخزين المحلي للبيانات

بموجب قانون إدارة البيانات العامة وقانون حماية المعلومات الشخصية، يجب تخزين البيانات التي تعالجها الجهات العامة على خوادم داخل كوريا الجنوبية. وقد يُعدّ إرسال استفسارات نماذج اللغة الكبيرة إلى مزودي السحابة العامة خارج البلاد انتهاكا لهذا الالتزام في حد ذاته.

---

## البنية المرجعية: تكوين النشر في البيئات المعزولة

فيما يلي بنية مرجعية لجهة حكومية مركزية افتراضية (أ) تنشر ThakiCloud AI Platform في بيئة معزولة هوائيا على البنية التحتية المحلية.

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
<div class="d3-arch" data-arch-root id="eignaiairgappublicsector-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1580, "height": 1165, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 449, "h": 124, "label": "طبقة المستخدمين", "lx": 36, "ly": 42}, {"x": 60, "y": 240, "w": 364, "h": 333, "label": "طبقة التحكم في الوصول", "lx": 72, "ly": 258}, {"x": 444, "y": 240, "w": 485, "h": 551, "label": "مستوى التحكم (k0s)", "lx": 456, "ly": 258}, {"x": 1059, "y": 651, "w": 245, "h": 482, "label": "مستوى البيانات أ - الاستدلال", "lx": 1071, "ly": 669}, {"x": 1324, "y": 651, "w": 224, "h": 319, "label": "مستوى البيانات ب - التدريب", "lx": 1336, "ly": 669}, {"x": 948, "y": 24, "w": 210, "h": 549, "label": "مجموعة الرصد والمراقبة", "lx": 960, "ly": 42}, {"x": 1178, "y": 433, "w": 370, "h": 140, "label": "السجل الداخلي", "lx": 1190, "ly": 451}], "nodes": [{"id": "U1", "x": 273, "y": 63, "w": 163, "h": 46, "title": "محطة الموظف الإداري"}, {"id": "U2", "x": 62, "y": 63, "w": 156, "h": 46, "title": "محطة الموظف البحثي"}, {"id": "GW", "x": 165, "y": 279, "w": 163, "h": 62, "title": ["Traefik Gateway API", "HTTP/gRPC/WebSocket"]}, {"id": "KC", "x": 98, "y": 472, "w": 121, "h": 62, "title": ["Keycloak IdP", "OIDC/MFA/RBAC"]}, {"id": "CP", "x": 581, "y": 472, "w": 120, "h": 62, "title": ["خادم Go API", ":3000"]}, {"id": "WEB", "x": 756, "y": 480, "w": 135, "h": 46, "title": "لوحة تحكم React"}, {"id": "ARGO", "x": 642, "y": 287, "w": 121, "h": 46, "title": "ArgoCD GitOps"}, {"id": "PG", "x": 481, "y": 698, "w": 120, "h": 46, "title": "PostgreSQL"}, {"id": "NATS", "x": 660, "y": 698, "w": 128, "h": 46, "title": "NATS JetStream"}, {"id": "VLLM", "x": 1097, "y": 690, "w": 170, "h": 62, "title": ["vLLM Serverless", "+ KEDA Scale-to-Zero"]}, {"id": "KAI", "x": 1121, "y": 869, "w": 121, "h": 62, "title": ["KAI Scheduler", "+ Kueue"]}, {"id": "GPU1", "x": 1118, "y": 1048, "w": 128, "h": 46, "title": "عقدة GPU (MIG)"}, {"id": "KF", "x": 1362, "y": 690, "w": 149, "h": 62, "title": ["Kubeflow TrainJob", "SFT/DPO/LoRA"]}, {"id": "GPU2", "x": 1365, "y": 877, "w": 142, "h": 46, "title": "عقدة GPU (كاملة)"}, {"id": "VM", "x": 986, "y": 287, "w": 135, "h": 46, "title": "VictoriaMetrics"}, {"id": "VL", "x": 993, "y": 63, "w": 120, "h": 46, "title": "VictoriaLogs"}, {"id": "DCGM", "x": 993, "y": 480, "w": 121, "h": 46, "title": "DCGM Exporter"}, {"id": "REG", "x": 1216, "y": 472, "w": 120, "h": 62, "title": ["Harbor", "مرآة الصور"]}, {"id": "GIT", "x": 1391, "y": 472, "w": 120, "h": 62, "title": ["Gitea", "Git الداخلي"]}], "edges": [{"src": "U1", "dst": "GW", "kind": "data", "label": "HTTPS", "curve": [[354, 109], [354, 148], [354, 240], [294, 279]], "off": "50%"}, {"src": "U2", "dst": "GW", "kind": "data", "label": "HTTPS", "curve": [[140, 109], [140, 148], [140, 240], [199, 279]], "off": "50%"}, {"src": "GW", "dst": "KC", "kind": "data", "label": "OIDC Token", "curve": [[211, 341], [158, 387], [158, 433], [158, 472]], "off": "50%"}, {"src": "GW", "dst": "WEB", "kind": "data", "curve": [[294, 341], [364, 387], [364, 433], [756, 493]]}, {"src": "GW", "dst": "CP", "kind": "data", "curve": [[253, 341], [262, 387], [262, 433], [581, 492]]}, {"src": "CP", "dst": "VLLM", "kind": "data", "curve": [[696, 534], [765, 573], [765, 651], [1097, 707]]}, {"src": "CP", "dst": "KF", "kind": "data", "curve": [[701, 532], [785, 573], [785, 651], [1362, 713]]}, {"src": "CP", "dst": "PG", "kind": "data", "curve": [[597, 534], [541, 573], [541, 651], [541, 698]]}, {"src": "CP", "dst": "NATS", "kind": "data", "curve": [[678, 534], [724, 573], [724, 651], [724, 698]]}, {"src": "ARGO", "dst": "GIT", "kind": "data", "curve": [[733, 333], [805, 387], [805, 433], [1391, 496]]}, {"src": "ARGO", "dst": "CP", "kind": "data", "label": "مزامنة GitOps", "curve": [[684, 333], [641, 387], [641, 433], [641, 472]], "off": "50%"}, {"src": "VLLM", "dst": "KAI", "kind": "data", "line": [1182, 752, 1182, 869]}, {"src": "KAI", "dst": "GPU1", "kind": "data", "line": [1182, 931, 1182, 1048]}, {"src": "KF", "dst": "GPU2", "kind": "data", "line": [1436, 752, 1436, 877]}, {"src": "VM", "dst": "DCGM", "kind": "data", "line": [1053, 333, 1053, 480]}, {"src": "VL", "dst": "VM", "kind": "data", "line": [1053, 109, 1053, 287]}]});
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
      const container = document.getElementById('eignaiairgappublicsector-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eignaiairgappublicsector-1';
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

### المكونات الرئيسية

**الفصل بين مستوى التحكم ومستوى البيانات**

وفقا لوثائق ThakiCloud AI Platform (انظر البنية المنطقية لتقييم شركاء KSA)، تفصل المنصة بصرامة بين مستوى التحكم ومستوى البيانات. يتولى مستوى التحكم إدارة خدمات API والحالة ومنطق التنسيق، بينما يتولى مستوى البيانات تنفيذ أحمال عمل GPU وخدمة نقاط نهاية الاستدلال. يضمن هذا الفصل استمرار خدمات الاستدلال في مستوى البيانات دون انقطاع حتى خلال أعمال صيانة مستوى التحكم.

**السجل الداخلي للنشر في البيئات المعزولة**

في البيئات المنقطعة عن الإنترنت الخارجي، يجب إعداد سجل حاويات داخلي مثل Harbor ونسخ جميع صور الحاويات مسبقا. يُستخدم k0s، وهو أداة نشر خفيفة الوزن، بدلا من kubeadm القياسي لنشر مجموعات Kubernetes، مع دعم رسمي للتثبيت في البيئات المعزولة. يتيح الجمع بين مخططات Helm ونمط App-of-Apps في ArgoCD إدارة حالة المجموعة بأكملها بصورة تصريحية، مع اتخاذ مستودع Gitea الداخلي مصدرا وحيدا للحقيقة.

**الاستدلال بدون خادم عبر vLLM ومعدوم الحجم عند الخمول**

تُبنى أحمال عمل الاستدلال على vLLM وتُدمج مع KEDA (موسع أتوماتي تحرّكه الأحداث في Kubernetes) لتحقيق التوسع إلى الصفر (Scale-to-Zero). تُحرَّر موارد GPU في فترات الخمول وتتوسع تلقائيا عند ورود الطلبات، مما يتيح مشاركة موارد GPU المحدودة محليا بكفاءة.

---

## الأمان والحوكمة

### RBAC رباعي المستويات عبر Keycloak OIDC

توفر منصة ThakiCloud AI Platform هيكلا رباعي المستويات للتحكم في الوصول القائم على الأدوار يشمل: المنظمة، والمشروع، والمجموعة، والمستخدم، مع استخدام Keycloak موفرا للهوية (IdP). وفقا لوثائق واجهة الويب، يتوفر نظام لتعيين أدوار Admin وDeveloper وViewer مع دمج الأذونات القائم على خوارزمية Union+Deny، كما يتضمن رمز JWT معلومات المجموعة للتحقق الفوري من الأذونات.

في بيئات القطاع العام، يُعدّ العزل على مستوى المشروع بين الأقسام أمرا بالغ الأهمية. فحتى حين يشترك قسم التخطيط والتنسيق وقسم تكنولوجيا المعلومات في استخدام المنصة ذاتها، يُعزل تاريخ استفسارات كل قسم لنماذج اللغة الكبيرة وبيانات الضبط الدقيق على مستوى مساحة اسم المشروع (Project Namespace) لمنع أي تسرب بين الأقسام.

يمكن أن يستوفي إعداد المصادقة متعددة العوامل (MFA) في Keycloak متطلبات المصادقة المعززة الواردة في إرشادات مراقبة الأمن الصادرة عن جهاز الاستخبارات الوطني. كما يُدعم التكامل مع أنظمة الموارد البشرية أو Active Directory عبر اتحاد LDAP.

### ArgoCD GitOps وإدارة سجل التغييرات

تُدار جميع تغييرات تكوين المنصة على شكل مخططات Helm في مستودع Git داخلي، وتتولى ArgoCD مزامنتها مع المجموعة. يوفر نمط GitOps هذا سجل تدقيق كاملا عبر سجلات Git لمعرفة "من غيّر ماذا ومتى". كما يحول دون وقوع تغييرات ارتجالية عبر `kubectl apply` المباشر (انجراف التكوين)، مما يعزز موثوقية سجل التغييرات اللازم للاستجابة لمتطلبات التدقيق.

### سجلات التدقيق ومجموعة الرصد

تُجمَّع في VictoriaLogs جميع طلبات API الاستدلالية، وأحداث بدء وانتهاء مهام الضبط الدقيق، وتسجيلات دخول المستخدمين وأحداث تغيير الأذونات. يجمع DCGM Exporter بيانات تتبع GPU ويرسلها إلى VictoriaMetrics. ولأن جميع بيانات السجل تُخزَّن على خوادم داخلية، يتحقق الامتثال لإلزامية التخزين المحلي للبيانات بصورة تلقائية.

تحديدا لتلبية متطلبات الاحتفاظ بسجلات الوصول الواردة في إرشادات مراقبة الأمن لدى جهاز الاستخبارات الوطني، يضطلع خادم Python Admin API (FastAPI) بدور مجمع سجلات التدقيق بشكل منفصل. يخزّن هذا المكون -- المحدد صراحة في وثيقة البنية المنطقية لمستوى التحكم -- الجهة والوقت والمورد المستهدف ونتيجة كل طلب API في PostgreSQL، مع البث المتزامن إلى VictoriaLogs. تُضبط سجلات التدقيق وفق سياسة احتفاظ لا تقل عن ستة أشهر، قابلة للتعديل وفقا للوائح الداخلية للمؤسسة.

ميزة بارزة أخرى لمجموعة الرصد هي قابلية رؤية موارد GPU، إذ يجمع DCGM Exporter درجة حرارة GPU واستخدام الذاكرة ومعدل استغلال الحوسبة في الوقت الفعلي، ويعرضها على لوحة تحكم VictoriaMetrics. يُمكّن ذلك فرق التشغيل من اكتشاف التحميل الزائد على عقد GPU المحددة مبكرا واتخاذ إجراءات استباقية كإعادة توزيع أحمال العمل أو اتخاذ تدابير التبريد.

### استيفاء إلزامية التخزين المحلي للبيانات

بما أن جميع مكونات المنصة تعمل على خوادم داخل المؤسسة، لا تُرسَل أي بيانات -- بما فيها محتوى استفسارات نماذج اللغة الكبيرة -- إلى الخارج. كما تُخزَّن ملفات أوزان النماذج وتُدار في التخزين الداخلي (Longhorn أو NFS).

---

## دلالات تبني ThakiCloud AI Platform

### دعم كامل للبيئات المعزولة

صُمِّمت منصة ThakiCloud AI Platform منذ مرحلة التصميم الأولى لدعم البيئات المحلية والمعزولة. تتوفر وثيقة بنية منطقية للنشر السيادي السحابي في المملكة العربية السعودية (KSA)، وثمة مرجع لتشغيل المنصة بأكملها على مجموعة محلية بحتة تشمل خوادم عارية (Bare-Metal) وعقد GPU وشبكة InfiniBand. يتجاوز هذا مجرد "دعم التثبيت المحلي" ليمثل تكوينا كاملا للمكدس يتيح التشغيل المستقل دون أي اعتماد على السحابة العامة.

### ستة خطوط أنابيب للضبط الدقيق

كثيرا ما تحتاج مؤسسات القطاع العام إلى نماذج مضبوطة بدقة على وثائق وبيانات لوائح خاصة بالمؤسسة بدلا من نماذج اللغة الكبيرة للأغراض العامة. تدعم منصة ThakiCloud AI Platform ست طرق للضبط الدقيق -- SFT وDPO وGRPO وCPT وGKD وLoRA -- عبر Kubeflow TrainJob. يُشكّل توفير هذه الطرق المتنوعة ضمن منصة واحدة ميزة تنافسية مقارنة بالحلول المنافسة.

### كفاءة موارد GPU عبر Kueue ومجدول KAI

لا تستطيع مؤسسات القطاع العام ببساطة شراء وحدات GPU إضافية عند الطلب كما هو متاح في السحابة العامة. يغدو التوزيع العادل للموارد المحدودة عبر الأقسام أمرا بالغ الأهمية. يدعم Kueue ومجدول KAI المخصص قوائم الانتظار العادلة وجدولة العصابة (Gang Scheduling)، مع استرداد موارد GPU الخاملة لتحسين معدل الاستغلال (30-50% استرداد [تقديري] وفقا لعرض تقديمي للشركة). يتيح التقسيم المنطقي لوحدة GPU واحدة باستخدام MIG (Multi-Instance GPU) توزيعا أكثر دقة لطلبات الاستدلال الصغيرة.

### أساس تقني للامتثال لمتطلبات أمان جهاز الاستخبارات الوطني

يوفر Keycloak OIDC MFA والتحكم في الوصول الرباعي المستويات وسجل التغييرات القائم على ArgoCD وسجلات التدقيق في VictoriaLogs وتخزين أحداث التدقيق في PostgreSQL الأساس التقني للمتطلبات الجوهرية لإرشادات مراقبة الأمن لدى جهاز الاستخبارات الوطني. غير أن الحصول على شهادة CSAP يتطلب، إضافة إلى التكوين التقني، عناصر غير تقنية كالإجراءات التشغيلية والتوظيف والأمن المادي -- لذا لا تُحقَّق الشهادة تلقائيا بمجرد تبني المنصة. تمثل المنصة نقطة انطلاق تُوفي بمتطلبات الضوابط التقنية.

### الإدارة المركزية لمتعدد المجموعات

في حال وجود وزارات كبيرة أو جهات تابعة متعددة، تُتيح إمكانية الإدارة المركزية لمتعدد المجموعات القائمة على NATS وgRPC تشغيل مجموعات GPU الموزعة من لوحة تحكم واحدة. يتولى مدير ArgoCD إدارة متكاملة لحالة مزامنة GitOps عبر المجموعات، مما يُيسّر الحفاظ على تكوين موحد عند تشغيل مواقع متعددة.

---

## القيود واعتبارات التبني

### تكاليف البناء الأولية والكوادر المتخصصة

على خلاف SaaS للسحابة العامة، يستلزم النشر المحلي المعزول شراء خوادم مسبقا وتكوين الشبكة والحصول على موظفين داخليين أو شركاء يتمتعون بخبرة تشغيل Kubernetes. تحديدا، يتطلب نسخ الصور في البيئات المعزولة وإصدار شهادات TLS من CA داخلي عبر cert-manager وتصميم DNS الداخلي كوادر مهندسين ذوي خبرة.

### إدارة تحديثات النماذج وتصحيحات الأمان

في البيئات المعزولة، لا يمكن تنزيل إصدارات جديدة لنماذج اللغة الكبيرة أو تصحيحات أمان المنصة تلقائيا من مصادر خارجية. يجب وضع إجراءات دورية لنسخ الصور وعمليات التحقق من التغييرات مسبقا، مما ينتج عنه عبء تشغيلي مستمر.

### تسوية قيود DNS/SSL المحلية مسبقا

كما أشرنا، كثيرا ما لا تتيح البيئات المحلية استخدام DNS وSSL البديلَين (Wildcard). قبل تبني المنصة، يجب اتخاذ قرار بشأن مجموعة نطاقات فرعية ثابتة لكل خدمة أو اعتماد سياسة وصول قائمة على رقم المنفذ. يُصعّب تأخير هذا القرار إعادة هيكلة URL بعد النشر.

### شهادة CSAP تستدعي مبادرة مستقلة

رغم أن منصة ThakiCloud AI Platform توفر أساسا يستوفي متطلبات الضوابط التقنية، فإن الحصول على شهادة CSAP في حد ذاته عملية تقييم شاملة تتضمن عناصر غير تقنية كالإجراءات التشغيلية والأمن المادي وأمن الأفراد. إن كانت شهادة CSAP هي الهدف، فيُنصح بالتنسيق مع فريق أمن المعلومات في مؤسستك أو شريك استشاري متخصص لوضع خطة سعي مستقلة للحصول على الشهادة.

### يُوصى بالتبني التدريجي

بدلا من نشر المنصة بأكملها دفعة واحدة، يُعدّ الأكثر عملية البدء بخدمات نقطة نهاية الاستدلال ثم التوسع تدريجيا نحو الضبط الدقيق وخطوط أنابيب التعلم الآلي. نوصي باكتساب الخبرة التشغيلية ابتداء من مجموعة تجريبية صغيرة، ثم التوسع نحو تكوين متعدد المجموعات.

---

قد تبدو قيود العزل الشبكي والبيئات المعزولة كحواجز أمام تبني الذكاء الاصطناعي. غير أن هذه القيود توفر في الواقع حدودا واضحة من منظور السيادة على البيانات والأمان، ويمكن أن تكون فرصة لإدارة البنية التحتية الداخلية لـ GPU واستثمارها بصورة منهجية. منصة ThakiCloud AI Platform حل متكامل المكدس صُمِّم لهذه البيئة تحديدا، ويوفر الأساس التقني الذي يُمكّن مؤسسات القطاع العام من تشغيل الذكاء الاصطناعي السيادي بأمان وكفاءة.

إن كنت تدرس التبني، يُرجى التواصل مع فريق ThakiCloud التقني للحصول على دعم تصميم معماري مفصل يتناسب مع بيئة مؤسستك.
