---
layout: single
title: "Vibe Coding مقابل Agentic Coding: الدليل العملي الشامل لاستخدام ChatGPT وCursor AI"
excerpt: "فهم نموذجي برمجة الذكاء الاصطناعي استناداً إلى ورقة بحثية من جامعة كورنيل، وكيفية استخدام ChatGPT وCursor AI بفعالية في التطوير الفعلي"
date: 2025-06-25
tags: [vibe-coding, agentic-coding, chatgpt, cursor-ai, ai-assisted-development, prompt-engineering]
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/vibe-coding-vs-agentic-coding-practical-guide/"
toc: true
toc_sticky: true
toc_label: "الدليل العملي لنماذج برمجة الذكاء الاصطناعي"
published: false
categories:
  - dev
  - tutorials
---

## نظرة عامة: نموذجان جديدان للتطوير

تُقدّم ورقة بحثية من جامعة كورنيل بعنوان "Vibe Coding vs. Agentic Coding in Software Engineering" نموذجين جديدين للتطوير بمساعدة الذكاء الاصطناعي يُحدّدان اتجاه الصناعة.

**Vibe Coding**: تطوير بالإحساس التعاوني، حيث يقود المطور النتيجة ويوجّه الذكاء الاصطناعي. دور المطور هنا هو **المدير الإبداعي (Creative Director)**.

**Agentic Coding**: تطوير بالوكيل المستقل، حيث يعمل الذكاء الاصطناعي باستقلالية ضمن قيود مُحدَّدة. دور المطور هنا هو **المشرف الاستراتيجي (Strategic Supervisor)**.

هذا الدليل يشرح كيفية تطبيق كلا النموذجين باستخدام ChatGPT وCursor AI في مشاريع حقيقية.

---

## الجزء الأول: فهم النموذجين

### Vibe Coding: أنت المدير الإبداعي

```
المطور (المدير الإبداعي)
    |
    | يُحدد الهدف والإحساس العام
    v
[ChatGPT / Cursor AI]
    |
    | يُنتج الشيفرة
    v
المطور يراجع ويُوجّه
    |
    | يُعدّل ويُحسّن
    v
النتيجة النهائية
```

**متى تستخدم Vibe Coding؟**
- النماذج الأولية السريعة
- استكشاف أفكار جديدة
- تطوير الواجهات الأمامية الإبداعية
- مشاريع الفرد الواحد

### Agentic Coding: أنت المشرف الاستراتيجي

```
المطور (المشرف الاستراتيجي)
    |
    | يُحدد القيود والأهداف والمعايير
    v
[Cursor AI Agent / Claude Code]
    |
    | يُحلل، يُخطط، يُنفّذ، يختبر
    v
المطور يراجع النتائج
    |
    | يُقرر القبول أو التعديل
    v
الدورة التالية
```

**متى تستخدم Agentic Coding؟**
- الميزات المعقدة التي تمتد على ملفات متعددة
- إعادة هيكلة قاعدة الشيفرة
- أتمتة المهام المتكررة
- التطوير في المشاريع الكبيرة

---

## الجزء الثاني: Vibe Coding مع ChatGPT

### استراتيجية 1: بناء النموذج الأولي بسرعة

```
# نموذج Vibe Coding الأساسي مع ChatGPT

أريد بناء [وصف التطبيق] بالإحساس الآتي:
- التصميم العام: [عصري / بسيط / جريء / رقيق]
- الألوان الرئيسية: [بالوصف، لا الـ hex]
- التجربة المرغوبة: [ما يشعر به المستخدم]

ابدأ بمكون [اسم المكون] وأضف الشعور الذي وصفته.
```

### مثال عملي: لوح معلومات تحليلي

```
أريد بناء لوح معلومات تحليلي لتطبيق SaaS.

الإحساس المطلوب:
- احترافي مثل Stripe Dashboard  
- بساطة Apple + قوة Notion
- بيانات كثيرة لكن لا إرباك

ابدأ بمكون KPI Cards يعرض:
- إيرادات الشهر الحالي
- عدد المستخدمين النشطين
- معدل التحويل
- النمو مقارنة بالشهر السابق

استخدم React مع TypeScript وTailwind CSS
```

**استجابة ChatGPT التقريبية:**

```tsx
// KPICards.tsx
// مكون بطاقات مؤشرات الأداء الرئيسية بتصميم Stripe

import { ArrowUpIcon, ArrowDownIcon } from '@heroicons/react/24/solid';

interface KPICardProps {
  title: string;
  value: string;
  change: number;
  icon: React.ComponentType<{ className?: string }>;
}

const KPICard: React.FC<KPICardProps> = ({ title, value, change, icon: Icon }) => {
  const isPositive = change >= 0;
  
  return (
    <div className="bg-white rounded-2xl p-6 shadow-sm border border-gray-100 hover:shadow-md transition-shadow duration-200">
      <div className="flex items-center justify-between mb-4">
        <div className="p-2 bg-blue-50 rounded-xl">
          <Icon className="w-5 h-5 text-blue-600" />
        </div>
        <span className={`flex items-center gap-1 text-sm font-medium ${
          isPositive ? 'text-emerald-600' : 'text-red-500'
        }`}>
          {isPositive ? (
            <ArrowUpIcon className="w-4 h-4" />
          ) : (
            <ArrowDownIcon className="w-4 h-4" />
          )}
          {Math.abs(change)}%
        </span>
      </div>
      <p className="text-gray-500 text-sm font-medium mb-1">{title}</p>
      <p className="text-gray-900 text-2xl font-bold">{value}</p>
    </div>
  );
};

export const KPICards: React.FC = () => {
  const metrics = [
    {
      title: "الإيرادات الشهرية",
      value: "$48,295",
      change: 12.5,
      icon: CurrencyDollarIcon,
    },
    // ... بقية البيانات
  ];
  
  return (
    <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-4">
      {metrics.map((metric) => (
        <KPICard key={metric.title} {...metric} />
      ))}
    </div>
  );
};
```

### استراتيجية 2: التكرار السريع مع Vibe Coding

```
# جولة التحسين في Vibe Coding

الكود السابق جيد لكنه يحتاج:
1. الرسوم المتحركة تبدو بطيئة - أريد حيوية أكثر (مثل Linear.app)
2. الأرقام تحتاج تحريكًا عند التحديث
3. أضف حالة skeleton loading

حافظ على نفس البنية لكن أضف الحياة
```

---

## الجزء الثالث: Agentic Coding مع Cursor AI

### استراتيجية 3: تكليف الوكيل بمهمة محددة

```
# نموذج Agentic Coding مع Cursor

@codebase 
لديّ مهمة محددة ومُقيّدة:

الهدف: [وصف دقيق للوظيفة]

القيود:
- لا تُعدّل الملفات: [قائمة الملفات المحمية]
- يجب الحفاظ على: [السلوك الحالي X]
- المتطلبات الصارمة: [قائمة المتطلبات]

خطوات التنفيذ:
1. حلل [الملفات المحددة] أولًا
2. خطّط التعديلات قبل التنفيذ
3. نفّذ مع اختبارات وحدة
4. تحقق من عدم كسر الاختبارات الحالية

ابدأ بتحليل البنية الحالية وأخبرني بخطتك قبل أي تغيير.
```

### استراتيجية 4: دورة TDD مع Agentic Coding

```
# نمط TDD مع وكيل Cursor

المرحلة 1 (أكتبها أنا):
- أحتاج اختبارات لوظيفة تحقق من صحة البريد الإلكتروني
- يجب أن تفشل في: عناوين بدون @ وبدون نقطة ومكررة
- يجب أن تنجح في: عناوين صالحة ومع نطاقات فرعية

المرحلة 2 (ينفذها الوكيل):
@cursor اكتب الاختبارات أولًا (TDD)، ثم نفّذ الوظيفة حتى تنجح جميعها.
استخدم Jest مع TypeScript. أخبرني إذا احتجت قراراتي في أي مفترق.
```

---

## الجزء الرابع: سير العمل الهجين

### مخطط تدفق القرار

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
<div class="d3-arch" data-arch-root id="nticcodingpracticalguide-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 821, "height": 1030, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 489, "y": 24, "w": 120, "h": 46, "title": "بدء المهمة"}, {"id": "B", "x": 480, "y": 148, "w": 138, "h": 52, "title": "حجم المهمة؟"}, {"id": "C", "x": 112, "y": 292, "w": 120, "h": 46, "title": "Vibe Coding"}, {"id": "D", "x": 406, "y": 292, "w": 128, "h": 46, "title": "Agentic Coding"}, {"id": "E", "x": 103, "y": 416, "w": 138, "h": 52, "title": "نوع المهمة؟"}, {"id": "F", "x": 24, "y": 560, "w": 120, "h": 46, "title": "ChatGPT Vibe"}, {"id": "G", "x": 199, "y": 560, "w": 120, "h": 46, "title": "Cursor Vibe"}, {"id": "H", "x": 376, "y": 416, "w": 188, "h": 52, "title": "تعريف الاختبار ممكن؟"}, {"id": "I", "x": 374, "y": 560, "w": 156, "h": 46, "title": "Cursor Agent + TDD"}, {"id": "J", "x": 585, "y": 560, "w": 120, "h": 46, "title": "تقسيم المهمة"}, {"id": "K", "x": 112, "y": 684, "w": 120, "h": 46, "title": "مراجعة سريعة"}, {"id": "L", "x": 392, "y": 684, "w": 120, "h": 46, "title": "مراجعة شاملة"}, {"id": "M", "x": 199, "y": 808, "w": 138, "h": 52, "title": "مقبول؟"}, {"id": "N", "x": 190, "y": 952, "w": 120, "h": 46, "title": "الدمج"}, {"id": "O", "x": 669, "y": 952, "w": 120, "h": 46, "title": "التكرار"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [549, 70, 549, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "صغيرة < 2 ساعة", "curve": [[480, 187], [172, 246], [172, 246], [172, 292]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "كبيرة > 2 ساعة", "curve": [[520, 200], [470, 246], [470, 246], [470, 292]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [172, 338, 172, 416]}, {"src": "E", "dst": "F", "kind": "data", "label": "إبداعية/UI", "curve": [[140, 468], [84, 514], [84, 514], [84, 560]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "تقنية/لوغاريتم", "curve": [[203, 468], [259, 514], [259, 514], [259, 560]], "off": "50%"}, {"src": "D", "dst": "H", "kind": "data", "line": [470, 338, 470, 416]}, {"src": "H", "dst": "I", "kind": "data", "label": "نعم", "line": [464, 468, 452, 560], "lx": 452, "ly": 510}, {"src": "H", "dst": "J", "kind": "data", "label": "لا", "line": [505, 468, 619, 560], "lx": 567, "ly": 510}, {"src": "J", "dst": "B", "kind": "data", "curve": [[658, 560], [684, 442], [684, 315], [597, 200]]}, {"src": "F", "dst": "K", "kind": "data", "curve": [[84, 606], [84, 645], [84, 645], [139, 684]]}, {"src": "G", "dst": "K", "kind": "data", "curve": [[259, 606], [259, 645], [259, 645], [204, 684]]}, {"src": "I", "dst": "L", "kind": "data", "line": [452, 606, 452, 684]}, {"src": "K", "dst": "M", "kind": "data", "curve": [[172, 730], [172, 769], [172, 769], [229, 808]]}, {"src": "L", "dst": "M", "kind": "data", "curve": [[452, 730], [452, 769], [452, 769], [337, 810]]}, {"src": "M", "dst": "N", "kind": "data", "label": "نعم", "line": [262, 860, 250, 952], "lx": 250, "ly": 902}, {"src": "M", "dst": "O", "kind": "data", "label": "لا", "curve": [[337, 850], [584, 906], [584, 906], [681, 952]], "off": "50%"}, {"src": "O", "dst": "B", "kind": "data", "curve": [[734, 952], [743, 707], [743, 442], [618, 200]]}]});
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
      const container = document.getElementById('nticcodingpracticalguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nticcodingpracticalguide-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

---

## الجزء الخامس: تتبع الأداء

### نظام تتبع مقارن

```python
# scripts/ai_productivity_tracker.py
# نظام تتبع إنتاجية برمجة الذكاء الاصطناعي

import json
import time
import datetime
from dataclasses import dataclass, asdict
from pathlib import Path
from typing import Literal

@dataclass
class CodingSession:
    """جلسة برمجة واحدة"""
    session_id: str
    date: str
    paradigm: Literal["vibe", "agentic", "hybrid"]
    tool: Literal["chatgpt", "cursor", "claude", "gemini"]
    task_type: str
    duration_minutes: int
    lines_written: int
    lines_reviewed: int
    tests_added: int
    bugs_introduced: int
    bugs_caught_in_review: int
    subjective_quality: int  # 1-10
    notes: str

class AIProductivityTracker:
    def __init__(self, data_file: str = "ai_productivity_data.json"):
        self.data_file = Path(data_file)
        self.sessions = self._load_sessions()
    
    def _load_sessions(self) -> list:
        """تحميل الجلسات المحفوظة"""
        if self.data_file.exists():
            with open(self.data_file) as f:
                return json.load(f)
        return []
    
    def add_session(self, session: CodingSession) -> None:
        """إضافة جلسة جديدة"""
        self.sessions.append(asdict(session))
        self._save()
    
    def _save(self) -> None:
        """حفظ البيانات"""
        with open(self.data_file, "w", encoding="utf-8") as f:
            json.dump(self.sessions, f, ensure_ascii=False, indent=2)
    
    def compare_paradigms(self) -> dict:
        """مقارنة الأداء بين النموذجين"""
        vibe_sessions = [s for s in self.sessions if s["paradigm"] == "vibe"]
        agentic_sessions = [s for s in self.sessions if s["paradigm"] == "agentic"]
        
        def calc_metrics(sessions):
            if not sessions:
                return {}
            return {
                "متوسط_الجودة": sum(s["subjective_quality"] for s in sessions) / len(sessions),
                "متوسط_الإنتاجية_سطر_دقيقة": sum(
                    s["lines_written"] / max(s["duration_minutes"], 1) 
                    for s in sessions
                ) / len(sessions),
                "معدل_الأخطاء": sum(s["bugs_introduced"] for s in sessions) / 
                               max(sum(s["lines_written"] for s in sessions), 1) * 100,
                "عدد_الجلسات": len(sessions)
            }
        
        return {
            "vibe_coding": calc_metrics(vibe_sessions),
            "agentic_coding": calc_metrics(agentic_sessions),
            "التوصية": self._recommend_paradigm(vibe_sessions, agentic_sessions)
        }
    
    def _recommend_paradigm(self, vibe: list, agentic: list) -> str:
        """توصية مبنية على البيانات"""
        if not vibe or not agentic:
            return "بيانات غير كافية لتوصية موثوقة"
        
        vibe_quality = sum(s["subjective_quality"] for s in vibe) / len(vibe)
        agentic_quality = sum(s["subjective_quality"] for s in agentic) / len(agentic)
        
        if agentic_quality > vibe_quality + 1:
            return "Agentic Coding يُنتج جودة أعلى لديك"
        elif vibe_quality > agentic_quality + 1:
            return "Vibe Coding يناسبك أكثر"
        else:
            return "استخدام هجين مثالي لك"

# مثال على الاستخدام
tracker = AIProductivityTracker()

# تسجيل جلسة Vibe Coding
tracker.add_session(CodingSession(
    session_id="s001",
    date=datetime.date.today().isoformat(),
    paradigm="vibe",
    tool="chatgpt",
    task_type="ui_component",
    duration_minutes=45,
    lines_written=120,
    lines_reviewed=120,
    tests_added=0,
    bugs_introduced=2,
    bugs_caught_in_review=2,
    subjective_quality=8,
    notes="مكون جميل ولكن يحتاج اختبارات"
))

# عرض مقارنة الأداء
print(json.dumps(tracker.compare_paradigms(), ensure_ascii=False, indent=2))
```

---

## الجزء السادس: استخدام Cursor للميزات المتقدمة

### ميزة Cursor Composer للمشاريع الكبيرة

```
# نموذج Cursor Composer متقدم

@workspace أحتاج إضافة نظام إشعارات كامل للتطبيق.

المتطلبات الوظيفية:
1. إشعارات في التطبيق (in-app)
2. إشعارات البريد الإلكتروني
3. إشعارات Slack (اختيارية)
4. تفضيلات المستخدم للإشعارات

القيود التقنية:
- يجب استخدام البنية الحالية: @src/services/
- لا تُعدّل: @src/auth/ (هيكل المصادقة ثابت)
- استخدم نمط Observer الموجود في: @src/core/events.ts

خطة التنفيذ المطلوبة:
1. تحليل الهيكل الحالي
2. تصميم NotificationService
3. ربطه بالأحداث الموجودة
4. إضافة اختبارات تكاملية

وافقني على الخطة قبل التنفيذ.
```

---

## الجزء السابع: سيناريوهات عملية

### سيناريو 1: شركة ناشئة في مرحلة مبكرة

```yaml
# .cursor/startup-rules.yaml
# قواعد للشركات الناشئة (السرعة أولًا)

paradigm: vibe-first
workflow:
  mvp_phase:
    primary_tool: chatgpt
    approach: vibe-coding
    goal: إثبات المفهوم في 48 ساعة
    
  growth_phase:
    primary_tool: cursor
    approach: hybrid
    goal: جودة مع سرعة

quality_gates:
  pre_launch:
    - "اختبار يدوي للمسار الحرج"
    - "مراجعة أمان سريعة"
  post_launch:
    - "إضافة اختبارات للأخطاء المُبلَّغ عنها"
```

### سيناريو 2: مؤسسة تُهاجر إلى الذكاء الاصطناعي

```yaml
# .cursor/enterprise-migration-rules.yaml
# قواعد الهجرة المؤسسية (الأمان أولًا)

paradigm: agentic-first
approach:
  phase_1_analysis:
    tool: gemini-cli
    task: "تحليل شامل لقاعدة الشيفرة القديمة"
    
  phase_2_planning:
    tool: claude-code
    task: "خطة هجرة مفصلة مع اختبارات رجعية"
    
  phase_3_implementation:
    tool: cursor-agent
    task: "تنفيذ تدريجي مع gates جودة"
    
security_requirements:
  - "مراجعة بشرية لكل تغيير في قاعدة البيانات"
  - "اختبارات تكاملية قبل كل دمج"
  - "فحص أمان تلقائي في CI/CD"
```

---

## الجزء الثامن: قائمة مراجعة الأمان

### أمان Vibe Coding

```markdown
## قائمة مراجعة Vibe Coding الأمنية

### قبل استخدام الشيفرة المُولَّدة:

[ ] لا توجد مفاتيح API مُضمَّنة في الشيفرة
[ ] التحقق من المدخلات (Input Validation) موجود
[ ] معالجة الأخطاء لا تكشف معلومات حساسة
[ ] استعلامات قاعدة البيانات محمية من SQL Injection
[ ] المصادقة والتفويض صحيحان

### للشيفرة في الإنتاج إضافيًا:

[ ] اختبارات أمان OWASP الأساسية
[ ] مراجعة بشرية من مطور آخر
[ ] فحص التبعيات بحثًا عن ثغرات معروفة
[ ] تسجيل (Logging) مناسب بدون بيانات حساسة
```

### أمان Agentic Coding

```markdown
## قائمة مراجعة Agentic Coding الأمنية

### قبل تشغيل الوكيل:

[ ] تحديد ملفات "للقراءة فقط" يُمنع تعديلها
[ ] تقييد صلاحيات الوكيل بالحد الأدنى اللازم
[ ] إعداد نقطة استعادة (Git checkpoint) قبل البدء
[ ] تحديد ما يمكن وما لا يمكن للوكيل فعله

### بعد تنفيذ الوكيل:

[ ] مراجعة كل ملف تم تعديله
[ ] تشغيل الاختبارات الكاملة
[ ] التحقق من عدم كسر واجهات API
[ ] فحص أي استدعاءات خارجية مُضافة
```

---

## الجزء التاسع: إرشادات العمل الجماعي

### إعداد معايير الفريق

```markdown
# CONTRIBUTING.md - معايير برمجة الذكاء الاصطناعي

## متى نستخدم كل نموذج

### Vibe Coding مسموح به:
- المكونات المرئية الجديدة
- النماذج الأولية للعروض التقديمية
- الصفحات الترويجية والتسويقية

### Agentic Coding مطلوب:
- أي تغيير في طبقة البيانات
- منطق الأعمال الأساسي
- تعديلات على APIs العامة
- أي شيء يؤثر على الأمان

### المراجعة المطلوبة دائمًا:
- مطور آخر يراجع الشيفرة المُولَّدة
- اختبارات تُغطي المسارات الحرجة
- توثيق يوضح ما فعله الذكاء الاصطناعي وما عدّله المطور
```

---

## الجزء العاشر: خارطة طريق التطور

### مؤشرات الإتقان

```markdown
## مستوى المبتدئ (0-3 أشهر)
- [ ] يستخدم Vibe Coding لمهام UI بسيطة
- [ ] يراجع الشيفرة المُولَّدة قبل الاستخدام
- [ ] يُضيف اختبارات للشيفرة المُولَّدة

## مستوى المتوسط (3-6 أشهر)
- [ ] يُحدد متى يستخدم Vibe مقابل Agentic
- [ ] يكتب طلبات (prompts) فعّالة ومحددة
- [ ] يُدمج الذكاء الاصطناعي في سير CI/CD

## مستوى المتقدم (6-12 شهرًا)
- [ ] يُصمم سير عمل هجين مُحسَّن
- [ ] يُنشئ قواعد مخصصة لفريقه
- [ ] يقيس ويُحسّن الإنتاجية بالبيانات

## مستوى الخبير (12+ شهرًا)
- [ ] يُدرّب الفريق على النموذجين
- [ ] يُساهم في أدوات ومكتبات مفتوحة المصدر
- [ ] يُطوّر أدوات مخصصة للشركة
```

---

## الخلاصة: حدد مسارك الشخصي

جدول مقارنة ROI:

| المعيار | Vibe Coding | Agentic Coding | الهجين |
|---------|-------------|----------------|--------|
| سرعة التعلم | سريعة جدًا | متوسطة | تدريجية |
| جودة الكود النهائية | متوسطة | عالية | عالية جدًا |
| الإنتاجية قصيرة المدى | عالية جدًا | متوسطة | عالية |
| الإنتاجية طويلة المدى | متوسطة | عالية جدًا | عالية جدًا |
| متطلبات الخبرة | منخفضة | متوسطة | متوسطة |
| المناسب لـ | المبتدئين / الشركات الناشئة | المحترفين / المؤسسات | الجميع |

**التوصية العملية**: ابدأ بـ Vibe Coding لتسريع التعلم، ثم أضف Agentic Coding تدريجيًا مع نضوجك كمطور. الهدف النهائي هو سير عمل هجين يأخذ أفضل ما في النموذجين.
