---
title: "كيفية أتمتة العمليات التصنيعية بفرق العملاء الذكيين المستقلين"
excerpt: "نهج عملي لحل نقص كوادر MLOps ومشكلات إدارة مجموعات المصانع المتعددة باستخدام فرق عملاء ذكيين مستقلين متعددي الأدوار. يُشرح ذلك عبر دراسة حالة افتراضية لمصنّع توضح كيفية تطبيق ThakiCloud AI Platform وPaxis في عمليات المصانع الذكية."
seo_title: "أتمتة عملاء الذكاء الاصطناعي في التصنيع - عمليات GPU متعددة المجموعات وفرق العملاء المستقلة - Thaki Cloud"
seo_description: "كيفية أتمتة اختناقات كوادر MLOps وإدارة مجموعات المصانع المتعددة في المصانع الذكية والصناعات الثقيلة وشركات التصنيع الإلكتروني باستخدام فرق العملاء الذكيين المستقلين. تطبيق عملي للإدارة المركزية متعددة المجموعات في ThakiCloud AI Platform وسحابة عمليات عملاء Paxis."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - manufacturing
  - autonomous-agents
  - multi-cluster
  - mlops
  - automation
lang: ar
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/manufacturing-autonomous-agent-teams/"
reading_time: true
categories:
  - agentops
published: false
---

![صورة رأسية لفرق العملاء الذكيين المستقلين في العمليات التصنيعية]({{ '/assets/images/manufacturing-autonomous-agent-teams-hero.webp' | relative_url }})

## نظرة عامة

يواجه التصنيع الحديث تناقضاً هيكلياً: رغبة عالية في تبني الذكاء الاصطناعي، لكن نقصاً حاداً في الكوادر التشغيلية. حتى حين تريد المصانع نشر نماذج فحص بصري على خطوط الإنتاج، تفتقر إلى متخصصي MLOps القادرين على صيانة تلك النماذج وخدمتها وإعادة تدريبها. ومع إدارة ثلاث مجموعات GPU في مصانع مختلفة من فرق منفصلة، يتكرر هدر الموارد وتوقف الإنتاج في حلقة مفرغة.

يوضح هذا المقال كيف تحل فرق العملاء الذكيين المستقلين متعددي الأدوار هذه المشكلة، وكيف يمكن توحيد مجموعات GPU الموزعة عبر مصانع متعددة تحت مستوى تحكم واحد -- وذلك من خلال دراسة حالة الشركة التصنيعية الافتراضية "HanTek". التقنيات الأساسية التي يتناولها المقال هي الإدارة المركزية متعددة المجموعات في ThakiCloud AI Platform وسحابة عمليات العملاء Paxis.

---

## اختناق الكوادر في عمليات الذكاء الاصطناعي التصنيعي

HanTek شركة تصنيع مكونات إلكترونية متوسطة الحجم تشغّل مجموعات GPU في مرافق بمدن أولسان وغومي وغوانغجو. على مدى العامين الماضيين، نشرت الشركة نماذج الذكاء الاصطناعي البصري على كل خط مصنع، غير أن ثلاث مشكلات متكررة برزت في العمليات.

**أولاً، نقص حاد في كوادر MLOps.** تتطلب إعادة تدريب النماذج ونشرها ومراقبة أدائها مهندسين متخصصين. فريق ML في HanTek المكون من ثلاثة مهندسين عجز عن إدارة دورة حياة النماذج عبر المصانع الثلاثة. حتى حين يبدأ أداء النماذج بالتراجع، كانت طلبات إعادة التدريب تنتظر في قائمة الانتظار لأيام.

**ثانياً، إدارة متشظية لمجموعات متعددة.** كانت مجموعة GPU لكل مصنع تعمل باستقلالية تامة. نشأت مواقف تُقف فيها مهام التدريب في غومي في قائمة الانتظار بينما مجموعة أولسان خاملة، مما يستلزم التنسيق اليدوي عبر Slack. كانت مقاييس DCGM أيضاً تُجمع بشكل منفصل لكل مصنع، مما يجعل من المستحيل رؤية معدل استخدام GPU على مستوى الشركة بنظرة واحدة.

**ثالثاً، استحالة الاستجابة على مدار الساعة.** عند اكتشاف شذوذات الجودة في خطوط العمل الليلية أو في عطلات نهاية الأسبوع، لم يكن فريق ML قادراً على الاستجابة الفورية. كانت التنبيهات تصل، لكن المعالجة الفعلية تُؤجل إلى صباح اليوم التالي -- مع احتمال وصول المنتجات المعيبة إلى المرحلة الإنتاجية التالية في غضون ذلك.

هذه المشكلات ليست حكراً على HanTek. عبر قطاع التصنيع، يتكرر نمط واحد: تبني الذكاء الاصطناعي، لكن القدرات التشغيلية لا تواكب التطور، مما يُنصّف الفعالية.

---

## تكوين فريق العملاء المستقل -- تعدد الأدوار والمهام الديناميكية

الحل الذي اعتمدته HanTek هو فريق عملاء ذكيين مستقلين متعددي الأدوار مبني على Paxis. Paxis سحابة عمليات تُعامل العملاء كموارد من الدرجة الأولى "مثل الأجهزة الافتراضية على AWS". المهارات والأدوات والسياسات وسجلات التدقيق هي الموارد الأساسية للمنصة، ويرجع كل عميل إلى ويكي نطاقه (محرك المعرفة الهجين، HKE) لاتخاذ القرارات استناداً إلى المعرفة المتراكمة.

كوّنت HanTek فريق العملاء بثلاثة أدوار.

### عميل عمليات البنية التحتية

يتولى عميل عمليات البنية التحتية مراقبة حالة مجموعات GPU، وتحسين جدولة المهام، والاسترداد التلقائي عند اكتشاف الشذوذات. يجمع مقاييس Kueue وKAI Scheduler باستمرار، ويتخذ قراراً مستقلاً بإعادة توزيع المهام على مجموعة أخرى حين يتجاوز وقت انتظار قائمة الانتظار في مجموعة معينة الحد المسموح.

يُنفذ هذا العميل المهام المتكررة المعرّفة بلغة طبيعية -- مثل "توليد تقرير استخدام GPU كل صباح الساعة السابعة" -- عبر مجدول المهام الديناميكي في Paxis. لم يعد المشغلون بحاجة إلى كتابة نصوص cron منفصلة؛ يكفي إدخال مواصفات المهمة في المحادثة أو Slack ليجدول العميل نفسه.

### عميل جودة النماذج (شخصية محلل المعايير)

يراقب عميل جودة النماذج باستمرار أداء نماذج الذكاء الاصطناعي البصري على كل خط. يحلل مقاييس زمن الاستدلال والدقة المجمّعة من VictoriaMetrics، ويُشغّل خط أنابيب إعادة التدريب تلقائياً حين يتجاوز تدهور الأداء الحد المحدد. بعد اكتمال إعادة التدريب، ينشر ملخص نتائج المعايير في قناة Slack لفريق ML.

يرجع هذا العميل إلى سجل النماذج المتراكم خط بخط في HKE. المعرفة بالنطاق مثل "نموذج هذا الخط يحتاج إعادة تدريب كل ثلاثة أشهر، ومعيار الدقة الأساسي 98.5% أو أعلى" موثقة في الويكي، مما يُمكّن العميل من اتخاذ قرارات ذات سياق واعٍ.

### عميل تقارير العمليات (شخصية أتمتة التقارير)

يُولّد عميل تقارير العمليات تلقائياً تقارير تشغيل الذكاء الاصطناعي اليومية والأسبوعية والشهرية ويوزعها. يجمع معدل استخدام GPU وعدد حالات الاستدلال لكل نموذج وأحداث اكتشاف شذوذات الجودة وحالة إعادة التدريب، ثم يُنسّقها في شكل يسهل على الإدارة قراءته. تُنشر التقارير في Slack والبريد الإلكتروني ولوحات الويب في آن واحد عبر قدرة التسليم متعدد القنوات في Paxis.

### هيكل تعاون فريق العملاء

يعمل العملاء الثلاثة باستقلالية، لكنهم يتعاونون عند الحاجة عبر تنسيق العملاء المتعددين في Paxis. على سبيل المثال، حين يُشغّل عميل جودة النماذج إعادة التدريب، يحدث تفويض تلقائي عبر العملاء -- يطلب من عميل عمليات البنية التحتية تأمين طاقة مجموعة GPU للتدريب. تُسجّل عملية التفويض هذه جميع قرارات صنع القرار عبر محرك السياسات وسجل التدقيق.

---

## الإدارة المركزية متعددة المجموعات -- توحيد GPU عبر مصانع متعددة

لكي يعمل فريق العملاء بشكل صحيح، يجب إدارة مجموعات GPU عبر مصانع متعددة مركزياً تحت مستوى تحكم واحد. نظام Multi-Cluster Cloud (MCC) في ThakiCloud AI Platform يؤدي هذا الدور.

المخطط التالي تبسيط للهيكل الفعلي لـ HanTek.

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
<div class="d3-arch" data-arch-root id="ringautonomousagentteams-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1939, "height": 644, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 568, "h": 294, "label": "ThakiCloud Control Plane (HA 3-replica)", "lx": 36, "ly": 42}, {"x": 1163, "y": 24, "w": 744, "h": 294, "label": "Paxis Agent Operations Cloud", "lx": 1175, "ly": 42}], "nodes": [{"id": "CP0", "x": 62, "y": 71, "w": 120, "h": 46, "title": "CP-0 Leader"}, {"id": "CP1", "x": 237, "y": 71, "w": 121, "h": 46, "title": "CP-1 Follower"}, {"id": "CP2", "x": 413, "y": 71, "w": 121, "h": 46, "title": "CP-2 Follower"}, {"id": "VK", "x": 161, "y": 217, "w": 205, "h": 62, "title": ["Valkey Leader Election 3s", "TTL"]}, {"id": "INFRA", "x": 1200, "y": 63, "w": 205, "h": 62, "title": ["Infrastructure Operations", "Agent"]}, {"id": "QA", "x": 1460, "y": 71, "w": 163, "h": 46, "title": "Model Quality Agent"}, {"id": "REPORT", "x": 1678, "y": 71, "w": 191, "h": 46, "title": "Operations Report Agent"}, {"id": "HKE", "x": 1487, "y": 225, "w": 177, "h": 46, "title": "HKE Per-Team Wiki RAG"}, {"id": "US", "x": 1037, "y": 410, "w": 212, "h": 62, "title": ["Ulsan MCC Agent", "GPU Cluster Inference-Only"]}, {"id": "CP", "x": 819, "y": 225, "w": 120, "h": 46, "title": "CP"}, {"id": "GU", "x": 777, "y": 410, "w": 205, "h": 62, "title": ["Gumi MCC Agent", "GPU Cluster Training-Only"]}, {"id": "GJ", "x": 545, "y": 410, "w": 177, "h": 62, "title": ["Gwangju MCC Agent", "GPU Cluster Dev/Mixed"]}, {"id": "PAXIS", "x": 819, "y": 71, "w": 120, "h": 46, "title": "PAXIS"}, {"id": "DCGM1", "x": 1075, "y": 550, "w": 135, "h": 62, "title": ["DCGM Exporter", "VictoriaMetrics"]}, {"id": "DCGM2", "x": 812, "y": 550, "w": 135, "h": 62, "title": ["DCGM Exporter", "VictoriaMetrics"]}, {"id": "DCGM3", "x": 566, "y": 550, "w": 135, "h": 62, "title": ["DCGM Exporter", "VictoriaMetrics"]}], "edges": [{"src": "CP0", "dst": "VK", "kind": "data", "curve": [[122, 117], [122, 171], [122, 171], [206, 217]]}, {"src": "CP1", "dst": "VK", "kind": "data", "curve": [[297, 117], [297, 171], [297, 171], [277, 217]]}, {"src": "CP2", "dst": "VK", "kind": "data", "curve": [[473, 117], [473, 171], [473, 171], [348, 217]]}, {"src": "INFRA", "dst": "HKE", "kind": "data", "curve": [[1303, 125], [1303, 171], [1303, 171], [1494, 225]]}, {"src": "QA", "dst": "HKE", "kind": "data", "curve": [[1542, 117], [1542, 171], [1542, 171], [1565, 225]]}, {"src": "REPORT", "dst": "HKE", "kind": "data", "curve": [[1774, 117], [1774, 171], [1774, 171], [1635, 225]]}, {"src": "CP", "dst": "US", "kind": "data", "label": "\"gRPC Bidirectional Stream\"", "curve": [[939, 264], [1143, 318], [1143, 364], [1143, 410]], "off": "50%"}, {"src": "CP", "dst": "GU", "kind": "data", "label": "\"gRPC Bidirectional Stream\"", "line": [879, 271, 879, 410], "lx": 879, "ly": 360}, {"src": "CP", "dst": "GJ", "kind": "data", "label": "\"gRPC Bidirectional Stream\"", "curve": [[819, 265], [633, 318], [633, 364], [633, 410]], "off": "50%"}, {"src": "PAXIS", "dst": "CP", "kind": "data", "label": "\"Kueue Cross-Cluster Scheduling<br/>Model Retraining Trigger<br/>DCGM Metrics Collection\"", "line": [879, 117, 879, 225], "lx": 879, "ly": 167}, {"src": "US", "dst": "DCGM1", "kind": "data", "line": [1143, 472, 1143, 550]}, {"src": "GU", "dst": "DCGM2", "kind": "data", "line": [879, 472, 879, 550]}, {"src": "GJ", "dst": "DCGM3", "kind": "data", "line": [633, 472, 633, 550]}]});
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
      const container = document.getElementById('ringautonomousagentteams-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ringautonomousagentteams-1';
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

### فصل مستوى التحكم عن مستوى البيانات

تفصل ThakiCloud AI Platform بصرامة بين مستوى التحكم (CP) ومستوى البيانات (DP). يكتسب هذا الفصل أهمية في بيئات التصنيع لأن **مهام الاستدلال على خطوط المصنع تستمر في التشغيل حتى حين يواجه CP عطلاً**. يعمل الذكاء الاصطناعي البصري في مصنع أولسان دون انقطاع أثناء فصل شبكة CP تحديداً بفضل هذه البنية.

يُنشر وكيل MCC في كل مجموعة مصنع. يتواصل هذا الوكيل مع CP عبر تدفق gRPC ثنائي الاتجاه، ويحافظ على الاتصال من خلال إعادة الاتصال بأسلوب Make-Before-Break حتى حين تحدث تأخيرات في الشبكة. حتى حين تُقطع وصلة WAN كلياً، لا تتأثر مهام مستوى البيانات.

### جدولة GPU متعددة المجموعات عبر Kueue وKAI Scheduler

تُدير كل مجموعة مصنع أحمال عمل GPU عبر Kueue وKAI Scheduler. يحسب KAI Scheduler درجات المجموعات البينية بترتيب GPU > CPU > ذاكرة > قرص لتحديد التوزيع الأمثل. يقرأ عميل عمليات البنية التحتية مقاييس هذا المجدول، وعند اكتشاف إشارات مثل "وقت انتظار قائمة تدريب مجموعة أولسان يتجاوز 30 دقيقة"، يقترح إعادة توزيع المهام على مجموعة غومي أو يُنفّذها تلقائياً [تقديري].

حين يتجاوز استخدام GPU باستمرار 80% من متوسط المجموعة، يُشغَّل تنبيه VictoriaMetrics ويُولّد عميل عمليات البنية التحتية تقرير توصية بتوسيع الطاقة، ثم ينشره في قناة فريق ML.

### تكامل تيليمتري GPU المستندة إلى DCGM

يجمع مُصدِّر DCGM (مدير GPU لمراكز البيانات) في كل مجموعة تيليمتري GPU في VictoriaMetrics. كانت HanTek في السابق تضطر لمشاهدة لوحات Grafana منفصلة مُهيأة لكل مصنع على حدة، لكن VictoriaLogs وVictoriaMetrics توفران الآن طبقة مراقبة واحدة مجمّعة مركزياً. يستعلم عميل جودة النماذج مباشرة عن هذه المقاييس لاكتشاف شذوذات زمن الاستدلال.

### GitOps لـ ArgoCD واتساق المجموعات

تُدار عمليات نشر النماذج وتغييرات التهيئة في المجموعات الثلاث للمصانع كلها عبر ArgoCD باستخدام نهج GitOps. حين يُسجَّل وكيل MCC في مجموعة جديدة، يُنشأ سر مجموعة ArgoCD تلقائياً. حين يكتشف عميل تقارير العمليات تحديثاً لنموذج معين، يُنشئ PR في مستودع Git المقابل [تقديري]، وينشر ArgoCD تلقائياً على كل مجموعة مصنع.

---

## دلالات التطبيق لـ ThakiCloud

الدروس التطبيقية العملية المستخلصة من حالة HanTek هي التالية.

**نهج جوهري لحل اختناقات الكوادر.** فرق العملاء متعددي الأدوار ليست مصممة لاستبدال مهندسي MLOps، بل لتفويض المهام المتكررة للمراقبة وإعداد التقارير. يُركز المهندسون على العمل عالي القيمة مثل تحسين بنية النماذج وتحليل حالات الشذوذ، بينما يتولى العملاء العمليات اليومية. القيمة طويلة الأمد تنشأ من حقيقة أن دقة حكم العميل تزداد كلما تراكمت المعرفة بالنطاق في ويكي HKE.

**مرونة تشغيلية عبر مجدول المهام الديناميكي.** يتيح مجدول المهام الديناميكي في Paxis تعريف المهام بلغة طبيعية، مما يُمكّن مشغلي الميدان من إعداد الأتمتة مباشرة دون المرور عبر قسم تقنية المعلومات. يمكن تطبيق متطلبات تشغيلية محددة فوراً، مثل "إرسال تقرير ملخص لشذوذات الجودة خلال الأسبوع الماضي إلى البريد الإلكتروني لرؤساء الفرق كل إثنين الساعة الثامنة صباحاً".

**تحقيق الرؤية عبر تكامل المجموعات المتعددة.** توفر إدارة المجموعات المتعددة عبر مستوى تحكم واحد رؤية فورية لمعدل استخدام GPU على مستوى الشركة وحالة قوائم انتظار المهام والتكاليف لكل مجموعة. يمكن الآن تهيئة سياسات كانت مستحيلة في السابق على مستوى مستوى التحكم -- مثل "السماح تلقائياً بمهام تدريب جديدة حين يقل معدل استخدام GPU المجمّع عبر المصانع الثلاثة عن 60%".

**موثوقية محرك السياسات وسجلات التدقيق.** في بيئات التصنيع، تُعدّ قابلية تتبع القرارات التي يتخذها الذكاء الاصطناعي أمراً بالغ الأهمية. يُسجّل محرك السياسات وسجل التدقيق في Paxis جميع إجراءات العملاء ويُبقي على سجل قابل للتدقيق يوضح الإجراءات المتخذة ومسوّغاتها. هذا يُقدم مساعدة عملية في الوفاء بمتطلبات تدقيق شهادات الجودة والامتثال الداخلي.

---

## القيود والاعتبارات

لا ينطبق هذا النهج بشكل موحد على جميع بيئات التصنيع. ثمة قيود عملية يجب فحصها قبل التبني.

**تكلفة بناء المعرفة بالنطاق الأولية.** يتطلب بناء المعرفة بالنطاق في ويكي HKE التي سيستخدمها العملاء استثماراً مسبقاً. يجب توثيق المعرفة الضمنية مثل خصائص النماذج المحددة للخط ونطاقات التشغيل الطبيعية ومعايير إعادة التدريب بشكل صريح. قد يؤدي نشر العملاء دون هذا التحضير إلى أخطاء في الحكم المبكر.

**تحديد نطاق استقلالية العميل.** يجب تحديد نطاق القرارات التي يمكن للعملاء اتخاذها باستقلالية بوضوح. تُناسب مُشغّلات إعادة تدريب النماذج وتوليد التقارير التنفيذ المستقل، لكن استبدال النماذج وإعادة تهيئة المجموعات التي تؤثر على خطوط الإنتاج يكون أكثر أماناً إذا احتفظت بخطوات موافقة بشرية. يتيح محرك السياسات في Paxis تهيئة هذه الحدود.

**واقع بيئات الشبكات.** في بيئات مصانع الصناعة الثقيلة المحلية، كثيراً ما تكون سياسات جدار الحماية للاتصالات بين شبكات المصانع الداخلية والسحابة صارمة. يجب التحقق مسبقاً مما إذا كانت اتصالات gRPC لوكيل MCC مسموحاً بها وما إذا كان عرض نطاق WAN مستقراً. بالنسبة للبيئات المحلية الخالصة، يجب أخذ تهيئة نشر كلٍّ من CP وDP في الموقع بعين الاعتبار.

**تعقيد تعاون العملاء.** يُنشئ تنسيق العملاء المتعددين سيناريوهات عطل أكثر تعقيداً مقارنة بعميل واحد. يجب تصميم سياسات التراجع وأنظمة التنبيه لمعالجة الحالات التي يُرسل فيها عميل تفويضاً خاطئاً عبر العملاء. على الرغم من أن خط أنابيب Plan-Execute في Paxis يُنظّم التنفيذ في ثلاث مراحل -- المخطط والمُنفّذ والمُولّف -- يظل الاختبار الكافي لحالات الشذوذ أمراً ضرورياً.

**الاكتساب التدريجي للنضج التشغيلي.** لا يُنصح بتفويض جميع العمليات للعملاء منذ البداية. النهج التدريجي أكثر واقعية: ابدأ بمهام ذات مخاطر منخفضة كأتمتة التقارير، وتحقق من جودة حكم العميل، ووسّع الاستقلالية فقط بعد ترسّخ الثقة.

---

اختناق الكوادر في عمليات الذكاء الاصطناعي التصنيعي لا يُحل ببساطة بتوظيف المزيد من الأشخاص. الاتجاه المستدام لعمليات الذكاء الاصطناعي التصنيعي هو هيكل تتولى فيه فرق العملاء المستقلين المهام التشغيلية المتكررة، وتُقلل الإدارة المركزية متعددة المجموعات من هدر موارد GPU، ويُركز البشر على القرارات والتحسينات الأكثر تعقيداً. توفر ThakiCloud AI Platform وPaxis الوسائل التقنية الملموسة لتنفيذ هذا الهيكل.
