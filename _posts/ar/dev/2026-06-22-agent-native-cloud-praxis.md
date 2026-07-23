---
title: "ما هي السحابة الأصيلة للوكلاء: المهارات والسياسات كموارد من الدرجة الأولى"
excerpt: "لماذا السحابة المعتمدة على الآلات الافتراضية غير ملائمة لتشغيل وكلاء الذكاء الاصطناعي المستقلين، واستعراض مبادئ تصميم البنية التحتية الأصيلة للوكلاء التي تعامل المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى."
seo_title: "مبادئ تصميم السحابة الأصيلة للوكلاء - Thaki Cloud"
seo_description: "تحول نموذجي في بنية السحابة التحتية لتشغيل وكلاء الذكاء الاصطناعي المستقلين. تقديم البنية الأصيلة للوكلاء ومنصة ThakiCloud Paxis، حيث تُعدّ المهارات والأدوات والسياسات وسجلات التدقيق -- لا الآلات الافتراضية -- موارد من الدرجة الأولى."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: ar
tags:
  - agent-native
  - cloud-infrastructure
  - praxis
  - ai-agents
  - platform
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/agent-native-cloud-praxis/"
reading_time: true
categories:
  - dev
published: false
---

![نظرة عامة على Paxis للسحابة الأصيلة للوكلاء]({{ '/assets/images/agent-native-cloud-praxis-hero.webp' | relative_url }})

## نظرة عامة

ركّزت الحوسبة السحابية حتى الآن على سؤال واحد: "كيف نُجرّد البيئة التي تعمل فيها التطبيقات؟" كان التطور من الخوادم المادية إلى الآلات الافتراضية (VM)، ومن الآلات الافتراضية إلى الحاويات، ومن الحاويات إلى الخدمات اللاسيرفرية، مساراً لتحسين الإجابة على هذا السؤال بصورة متزايدة الدقة.

غير أننا نواجه اليوم نوعاً مختلفاً من الأسئلة: "كيف نُجرّد البيئة التي تعمل فيها وكلاء الذكاء الاصطناعي -- الوكلاء الذين يفكرون ويتصرفون باستقلالية؟" يتطلب هذا السؤال شيئاً لم تُصمَّم أطر تجريد السحابة الحالية لتوفيره قط.

تستعرض هذه المقالة تلك الفجوة وتتناول مبادئ تجريد البنية التحتية المطلوبة في عصر الوكلاء. هذه قصة عن نموذج، وليست عرضاً تجارياً لمنتج.

## تطور التجريد في السحابة

تاريخ البنية التحتية السحابية هو تاريخ تراكم طبقات التجريد.

**الجيل الأول: استئجار الخوادم المادية.** نموذج مراكز البيانات المشتركة، حيث يستأجر المشغلون مساحة في الرفوف. كان المشغلون مسؤولين عن كل شيء من تثبيت نظام التشغيل إلى تكوين الشبكة. كانت تكلفة التغيير عالية جداً، وكان من الصعب الاستجابة بمرونة لتقلبات الطلب.

**الجيل الثاني: الآلات الافتراضية (VMs).** النموذج الذي تمثله AWS EC2 وGCP Compute Engine. قُسِّمت الخوادم المادية إلى وحدات منطقية، وأصبح بإمكان المشغلين توفير موارد الحوسبة -- المعالج والذاكرة والتخزين -- عبر واجهة برمجية. أحدث التجريد تحسناً كبيراً في مرونة البنية التحتية.

**الجيل الثالث: الحاويات والتنسيق.** العالم الذي حدده Docker وKubernetes. أصبح معياراً تغليف بيئة التنفيذ ذاتها كصورة ونشر أعباء العمل عبر مواصفات إعلانية. ازدهرت مفاهيم كالبنية التحتية الثابتة وGitOps وشبكة الخدمات في هذا الجيل.

**الجيل الرابع (مرحلة انتقالية حالية): الخدمات اللاسيرفرية والدوال.** النموذج الذي تمثله AWS Lambda وGoogle Cloud Functions. لم يعد المشغلون بحاجة إلى إدارة الخوادم على الإطلاق. يدفعون فقط مقابل تكاليف التنفيذ في وحدات على مستوى الدوال التي تستجيب للأحداث.

تشترك كل هذه الأجيال في شيء واحد: كانت الكيانات المُدارة دائماً **بيئة التنفيذ**. سواء أكانت آلات افتراضية أم حاويات أم دوال، ركّزت السحابة على توفير "مساحة لتشغيل شيء ما."

تخرج وكلاء الذكاء الاصطناعي المستقلون عن هذا الإطار.

## المشكلات الأربع الصعبة في تشغيل الوكلاء

تواجه الفرق التي نشرت وكلاء ذكاء اصطناعي مستقلين في بيئات الإنتاج مجموعة مشتركة من التحديات.

### المشكلة الصعبة الأولى: اختيار النموذج والتحكم في التكلفة

لا يكتمل الوكيل بمجرد استدعاء نموذج لغوي كبير واحد. لحل الأهداف المعقدة، يمر بمراحل متعددة: التخطيط والتنفيذ والتوليف.

تكمن المشكلة في أن كل مرحلة تتطلب قدرات نموذج مختلفة. يحتاج التخطيط إلى سياق واسع واستدلال معقد، في حين لا يحتاج إلى ذلك مرحلة الاسترداد البسيطة. ومع ذلك، يصعب مع الأساليب الحالية التحكم في هذا بدقة. على المطورين إما تحديد نموذج لكل مرحلة يدوياً، أو معالجة كل شيء بنموذج واحد قوي (ومكلف).

الأول يزيد من تعقيد الكود، والثاني يؤدي إلى انفجار في التكاليف. [تقديري] ليس من النادر أن تشكّل تكاليف النماذج أكثر من 60% من إجمالي تكاليف البنية التحتية في المؤسسات التي تُشغّل وكلاء على نطاق واسع.

### المشكلة الصعبة الثانية: إدارة المهارات والانتشار غير المنضبط

لنسمّ مجموعة الأدوات والقدرات التي يستخدمها الوكيل "مهارات" لأغراض الراحة. مع نمو النظام البيئي للوكلاء، تتكاثر المهارات بسرعة. تظهر مهارات متعددة بوظائف متشابهة، بعضها لا يُصان. يصعب تحديد أي مهارة هي الأنسب لأي موقف.

مثلما يحدث انتشار لصور AMI عند عدم إدارة صور الآلات الافتراضية بشكل منهجي، يحدث انتشار للمهارات في النظم البيئية للوكلاء. غير أن البنية التحتية السحابية الحالية لا توفر تجريداً للتعامل مع هذا.

### المشكلة الصعبة الثالثة: التوازن بين الحوكمة والاستقلالية

يواجه وكلاء الذكاء الاصطناعي المستقلون سؤالاً جوهرياً: "إلى أي مدى ينبغي أن يحكموا ويتصرفوا بأنفسهم؟" القيود المفرطة تُلغي قيمة الوكيل؛ التحرير المفرط يُفضي إلى سلوك غير متوقع.

يتطلب التحكم في هذا على مستوى طبقة العمليات محركاً للسياسات. يجب تعريف وإنفاذ الأدوات المسموح بها وإمكانية الوصول إلى البيانات والإجراءات التي تتطلب موافقة بشرية بصورة إعلانية.

تتعامل إدارة الهوية والوصول IAM التقليدية للسحابة ومجموعات الأمان مع سؤال "من يمكنه استدعاء أي API؟". لكن حوكمة الوكلاء يجب أن تعالج السؤال السياقي المعتمد: "هل يمكن لهذا الوكيل اتخاذ هذا الحكم في هذا الموقف؟" يتطلب هذا تجريداً مختلفاً نوعياً.

من الناحية العملية، تأمّل هذا السيناريو: عندما يحاول وكيل يملك حق الوصول إلى قاعدة بيانات العملاء إجراء استعلام جماعي في وقت غير معتاد، هل ينبغي السماح له فقط لأنه يملك صلاحية API؟ كانت التفويض السياقي منطقة وضعتها نماذج IAM التقليدية خارج نطاق تصميمها عمداً.

### المشكلة الصعبة الرابعة: التعلم المستمر وتطور المهارات

الوكلاء ليسوا برمجيات ثابتة. خلال التشغيل، تتراكم بيانات حول الاستراتيجيات الفعّالة والمهارات التي تفشل كثيراً. تحتاج إلى حلقة تغذية راجعة لتحسين الوكلاء والمهارات بناءً على هذه البيانات.

مثلما تُحدَّث صور الحاويات عبر خطوط أنابيب النشر، يجب تحديث قدرات الوكيل بصورة منهجية. غير أن البنية التحتية السحابية الحالية لا تعامل "تطور القدرة" هذا كمواطن من الدرجة الأولى.

هذا التحدي واضح بشكل خاص في البيئات المؤسسية. في نظام وكلاء يستخدمه مئات أعضاء الفريق، يتطلب فهم المهارات التي تراجع أداؤها مقارنةً بالشهر الماضي والسيناريوهات التي تحتاج مهارات جديدة تكاليف تشغيلية هائلة. بدون أتمتة هذه العملية، تميل أنظمة الوكلاء إلى التدهور التدريجي في الجودة بعد النشر الأولي.

## المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى

تشير هذه المشكلات الأربع الصعبة كلها إلى نفس السبب الجذري: الأشياء التي تعاملها السحابة الحالية كموارد من الدرجة الأولى -- الآلات الافتراضية والحاويات والدوال والتخزين والشبكات -- ليست الأهم في تشغيل الوكلاء.

يجب أن تعامل السحابة الأصيلة للوكلاء الأربعة التالية كموارد من الدرجة الأولى.

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
<div class="d3-arch" data-arch-root id="22agentnativecloudpraxis-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 739, "height": 643, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 494, "y": 50, "w": 213, "h": 544, "label": "Traditional Cloud First-Class Resources", "lx": 506, "ly": 68}, {"x": 24, "y": 24, "w": 283, "h": 587, "label": "Agent-Native First-Class Resources", "lx": 36, "ly": 42}], "nodes": [{"id": "VM", "x": 533, "y": 144, "w": 135, "h": 46, "title": "VM / Containers"}, {"id": "DB", "x": 540, "y": 277, "w": 120, "h": 46, "title": "Databases"}, {"id": "NET", "x": 540, "y": 378, "w": 120, "h": 46, "title": "Networks"}, {"id": "STORAGE", "x": 540, "y": 511, "w": 120, "h": 46, "title": "Storage"}, {"id": "SKILL", "x": 67, "y": 195, "w": 198, "h": 78, "title": ["Skills", "Capability unit,", "versioned, self-evolving"]}, {"id": "TOOLS", "x": 63, "y": 362, "w": 205, "h": 78, "title": ["Tools", "Tool registry, permission", "bindings"]}, {"id": "POLICY", "x": 70, "y": 62, "w": 191, "h": 78, "title": ["Policies", "Autonomy-risk matrix,", "declarative enforcement"]}, {"id": "AUDIT", "x": 77, "y": 495, "w": 177, "h": 78, "title": ["Audit Logs", "Hash chain, immutable", "history"]}], "edges": [{"src": "SKILL", "dst": "VM", "kind": "data", "label": "Runtime execution", "curve": [[265, 234], [307, 234], [494, 234], [563, 190]], "off": "50%"}, {"src": "TOOLS", "dst": "NET", "kind": "data", "label": "API calls", "line": [268, 401, 540, 401], "lx": 400, "ly": 397}, {"src": "POLICY", "dst": "VM", "kind": "data", "label": "Enforcement layer", "curve": [[261, 101], [307, 101], [494, 101], [563, 144]], "off": "50%"}, {"src": "AUDIT", "dst": "STORAGE", "kind": "data", "label": "Persistence", "line": [254, 534, 540, 534], "lx": 400, "ly": 530}]});
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
      const container = document.getElementById('22agentnativecloudpraxis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22agentnativecloudpraxis-1';
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

**المهارات هي وحدة القدرة.** يجب أن تكون أكثر من مجرد مجموعات موجّهات بسيطة -- يجب أن تكون كائنات قابلة للإدارة ذات إصدارات ومقاييس تقييم وقدرة على المقارنة والدمج. يجب اتخاذ قرارات بشأن المهارات التي يجب الاحتفاظ بها وتلك التي يجب إلغاؤها بناءً على مقاييس كتكرار الاستخدام ومعدل النجاح وكفاءة التكلفة.

**الأدوات هي سجل الأدوات.** تمثل قائمة الواجهات الخارجية التي يمكن للوكيل استدعاؤها، مع ربط أذونات الوصول بكل أداة. يجب أن يكون بالإمكان إدارة أي وكيل يمكنه استدعاء أي أداة بشكل مركزي.

**السياسات هي لغة الحوكمة.** تُعبَّر عن السياسات كمصفوفة تتقاطع فيها مستوى استقلالية الوكيل مع نطاق المخاطر المقبولة. يجب إنفاذ السياسات الإعلانية في وقت التشغيل، ويجب تشغيل سير العمل تلقائياً عند الحاجة إلى موافقة بشرية.

**سجلات التدقيق هي أساس الثقة.** يجب تسجيل تاريخ الأحكام التي أصدرها الوكيل والإجراءات التي اتخذها بطريقة غير قابلة للتلاعب. هذا، قبل أن يكون مسألة امتثال تنظيمي، مبدأ تصميمي يجعل أنظمة الوكلاء موثوقة.

معاملة هذه الموارد الأربعة كمواطنين من الدرجة الأولى يعني أكثر من مجرد القدرة على تخزينها واسترجاعها. يعني إدارة كاملة لدورة الحياة: توفيرها كموارد حوسبة، والإصدار، والتحكم في الوصول من خلال السياسات، وتتبع التكاليف، والتراجع عند الفشل. مثلما تتعامل Kubernetes مع الحاويات من خلال تجريدات "Deployment" و"ReplicaSet"، يجب أن تتعامل منصة الوكلاء الأصيلة مع المهارات من خلال تجريدات "SkillRelease" و"SkillPolicy".

## تطبيق ThakiCloud: Paxis والتكامل مع منصة الذكاء الاصطناعي

طوّرت ThakiCloud منصة **Paxis** كمنصة تجسّد مبادئ التصميم هذه. تحت مفهوم "AWS للوكلاء"، الهدف هو معاملة المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى -- بنفس الطريقة التي تتعامل فيها السحابة التقليدية مع الآلات الافتراضية وقواعد البيانات والشبكات.

**جهاز توجيه LLM والمهارات** يختار تلقائياً النموذج المناسب لكل مرحلة من مراحل تنفيذ الوكيل (التخطيط والتنفيذ والتوليف). يدعم أكثر من 10 مزودين بما فيهم Claude وGPT وGemini وKimi وOllama ونموذج ThakiCloud الخاص Metis، ويقلل من استدعاءات النماذج المرتفعة التكلفة غير الضرورية من خلال التوجيه المدرك للتكلفة. اختيار المهارات عملية من مرحلتين: أولاً تضييق مجموعة المرشحين في النطاق، ثم اختيار المهارة الأمثل بناءً على 7 معايير بما فيها الملاءمة والتكلفة والموثوقية.

**دايمون Curator للتطور الذاتي** يدير النظام البيئي للمهارات باستمرار. يكتشف المهارات المتشابهة ويدمجها، ويرقّع تلقائياً المهارات ذات الأداء المتدهور، ويكتشف مهارات جديدة بناءً على البيانات التشغيلية. من خلال تقطير الذاكرة، تتراكم الرؤى المكتسبة من التنفيذ المتكرر في قاعدة معرفية.

**طبقة الأمان والحوكمة** توفر مصفوفة سياسات تتقاطع فيها 4 مستويات من الاستقلالية مع 7 مستويات من المخاطر. يُطبَّق حماية الموجّهات لـ11 نوعاً من المدخلات ونوعين من المخرجات، إلى جانب إخفاء هوية 16 فئة من المعلومات الشخصية. بيئات تنفيذ متجزئة قائمة على Docker وحاويات Kata تعزل الوكلاء، وسجلات تدقيق بسلسلة تجزئة تغطي أكثر من 20 نوعاً من الأحداث تُحفظ لمدة 90 يوماً.

**طبقة الوارد متعددة القنوات** تُتيح التفاعل مع الوكلاء عبر تطبيق React SPA للويب وSlack (يدعم 48 أمراً) وواجهة سطر الأوامر CLI. يتضمن أيضاً جدولاً زمنياً ديناميكياً يعرّف المهام المخصصة باللغة الطبيعية. تعليمات مثل "اجمع أخبار المنافسين كل صباح وقدّم ملخصاً" يسجّلها الوكيل مباشرةً كجدول زمني خاص به.

**محرك المعرفة الهجين (HKE)** يجمع بين RAG القائم على wiki الخاص بكل فريق وبين رسم بياني للمعرفة. يرجع كل وكيل إلى قاعدة معرفية متخصصة في نطاقه، ويُثريها باستمرار من خلال تجربة التنفيذ.

تعمل Paxis بالتنسيق مع **منصة الذكاء الاصطناعي (ai-suite)**. هي بنية من ثلاث طبقات حيث تتولى منصة الذكاء الاصطناعي سياسة LLM المركزية والتحكم في التكلفة، وتوفر Paxis وقت تشغيل الوكيل، ويتولى Metis طبقة الاستدلال. الطريقة التي تتمتع بها كل طبقة بمسؤوليات واضحة وتتحد تشبه فصل مستوى التحكم عن مستوى البيانات في السحابة التقليدية.

المكدس البرمجي مبني بـGo 1.26 (الواجهة الخلفية) وReact 19 (الواجهة الأمامية)، مستخدماً PostgreSQL وRedis وMinIO كطبقة تخزين في بيئات الإنتاج.

## القيود والآفاق

مفهوم السحابة الأصيلة للوكلاء ذاته لم ينضج بعد. تستدعي بعض الصعوبات الجوهرية فحصاً صادقاً.

**مشكلة قياس جودة المهارات.** يمكن تقييم موثوقية صور الحاويات من خلال طرق راسخة نسبياً كالفحص عن الثغرات والتحقق من التوقيع. في المقابل، تعتمد جودة المهارة اعتماداً عميقاً على سياق التنفيذ. "هل هذه المهارة مناسبة لهذا الموقف؟" يصعب تقييمه بالكامل مسبقاً بطرق آلية. مقاييس التقييم الحالية (معدل النجاح وكفاءة التكلفة) مقاييس وكالة فحسب -- لا تقيس الفاعلية الحقيقية.

**وهم اكتمال السياسة.** تُنفَّذ السياسات الإعلانية للمواقف المُصرَّح بها، لكن تنوع المواقف التي يواجهها الوكيل يتجاوز خيال مصمميها. الحذر ضروري لضمان أن السياسات لا تخلق الانطباع الزائف بأن "الحوكمة قد حُلّت". السياسات شبكة أمان، وليست ضماناً.

**تعقيد تنسيق الوكلاء المتعددين.** التعامل مع وكيل واحد والتعامل مع نظام تتعاون فيه وكلاء متعددون مشكلتان مختلفتان نوعياً. نماذج الثقة بين الوكلاء وآليات حل النزاعات وإسناد المسؤولية كلها مجالات لم تُحسم بعد بشكل كافٍ على مستوى طبقة البنية التحتية.

**غياب المعايير الصناعية.** للآلات الافتراضية، توجد معايير للصور كـOVF/OCI وأنماط API متوافقة بين مزودي السحابة. معايير وصف مهارات الوكيل وسياساته لا تزال في طور التشكّل. ثمة حركات تحاول توحيد واجهات الأدوات مثل MCP (Model Context Protocol)، لكن التوافق الأوسع للنظام البيئي يحتاج وقتاً.

الاتجاه مع ذلك واضح. مع ترسّخ الوكلاء كجزء من الأنظمة البرمجية، يجب أن يرتفع مستوى التجريد في البنية التحتية التي تديرها. مثلما انتقلنا من عصر الإدارة المباشرة للخوادم المادية إلى عصر استدعاء واجهات برمجة الآلات الافتراضية، يقترب عصر تُعرَّف فيه "قدرات الوكيل ونطاق تصرفاته عبر API وتُنفّذها المنصة".

رحلة Paxis، مع سوق المهارات [تقديري] على خارطة طريق الربع الرابع من 2026 وشهادة SOC2 والنشر المعزول [تقديري] للربع الثاني من 2027 وما بعده، هي جزء من هذا التدفق. مع نضج المنصة، سيتمكن المطورون من التركيز على تصميم قدرات الوكيل، في حين تتولى البنية التحتية سلامة التنفيذ وتحسين التكلفة.

السحابة الأصيلة للوكلاء ليست مفهوماً مكتملاً بعد. لكن ما تحتاج أنظمة تشغيل البرمجيات من الجيل التالي إلى حله على مستوى طبقة البنية التحتية يتشكّل، في هذه اللحظة بالذات، كمبادئ تصميم.
