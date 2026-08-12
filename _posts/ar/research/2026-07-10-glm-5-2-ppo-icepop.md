---
title: "من GRPO إلى PPO مجددًا: كيف ثبّت GLM-5.2 التعلم المعزز عبر IcePop"
seo_title: "تحليل GLM-5.2 PPO IcePop في التعلم المعزز - Thaki Cloud"
seo_description: "نحلل كيف عاد GLM-5.2 إلى PPO باستخدام نموذج قيمة (value model) مدرَّب بدلاً من GRPO، وكيف عالج IcePop عدم التطابق بين توزيعي التدريب والاستدلال. نستعرض أيضًا بنية slime وMegatron وSGLang ودلالات ذلك على منصة تدريب النماذج اللغوية الكبيرة لدى ThakiCloud."
excerpt: "التيار السائد اليوم في التدريب اللاحق بالتعلم المعزز هو عائلة GRPO التي تتخلى عن الـ critic. لكن GLM-5.2 عاد إلى PPO بإحياء نموذج القيمة، وعالج عدم التطابق بين التدريب والاستدلال عبر IcePop. نستعرض أسباب هذا الاختيار ودلالاته من منظور بنية تدريب ThakiCloud."
date: 2026-07-10
tags:
  - reinforcement-learning
  - ppo
  - grpo
  - icepop
  - glm
  - llm-training
  - rlhf
categories:
  - research
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/glm-5-2-ppo-icepop/"
---

أي فريق خاض تجربة تشغيل التعلم المعزز (RL) الفعلي كتدريب لاحق للنماذج اللغوية الكبيرة يعرف أن اتجاه العام أو العامين الماضيين كان منحازًا لجهة واحدة. منذ أن كشفت DeepSeek عن GRPO، أصبح التخلص من نموذج القيمة (critic) المنفصل وتقدير الأفضلية (advantage) بالاعتماد فقط على المكافأة النسبية داخل المجموعة أشبه بالمعيار الفعلي. بما أن الـ critic لم يعد بحاجة إلى تدريب، توفَّرت الذاكرة والحوسبة، وأصبح التنفيذ أبسط. وقد شاع القول بأن «الـ critic لم يعد ضروريًا» كأنه حقيقة شبه مسلَّم بها.

لكن GLM-5.2 الذي كشفت عنه Zhipu يسير عكس هذا التيار تمامًا. تخلى هذا النموذج عن الأسلوب النسبي الجماعي وعاد إلى PPO باستخدام نموذج قيمة مدرَّب من جديد، وعالج بدلاً من ذلك عدم التطابق بين توزيعي التدريب والاستدلال، وهو أحد أكبر مصادر عدم الاستقرار المزمنة في التعلم المعزز، عبر تقنية تُسمى IcePop. والمثير أن هذا الاختيار ليس مجرد رجوع بسيط، بل يحمل طابع الدحض العملي للفكرة الشائعة مؤخرًا بأن «GRPO هو الحل الشامل».

![مسار تصوّري مجرد للعودة من GRPO إلى PPO في التعلم المعزز]({{ '/assets/images/glm-5-2-ppo-icepop-hero.webp' | relative_url }})
*تصوير لتحول الاتجاه في التدريب اللاحق بالتعلم المعزز، من التخلي عن الـ critic إلى استعادته مجددًا.*

## نظرة عامة

GLM-5.2 نموذج مفتوح الأوزان بنافذة سياق تصل إلى مليون رمز (token)، ويُظهر أداءً قويًا في اختبارات المعايير الطويلة النفَس للبرمجة والوكلاء (agents). ما يتناوله هذا المقال ليس أرقام أداء النموذج نفسه، بل قرارات التصميم في التدريب اللاحق بالتعلم المعزز التي أنتجت هذا الأداء. والجوهر هنا نقطتان. الأولى، العودة إلى PPO باستخدام نموذج قيمة مدرَّب بدلاً من الأسلوب النسبي الجماعي (GRPO). والثانية، تخفيف عدم التطابق بين التدريب والاستدلال الناتج عن ذلك عبر IcePop، مع إزالة حد التنظيم KL الذي كان موجودًا في الصياغة الأصلية لـ IcePop من أجل رفع سرعة تحسّن التعلم المعزز.

هذا الموضوع مهم من منظور ThakiCloud لسبب واضح. خط أنابيب تدريب النماذج اللغوية الكبيرة الذي نشغّله يدعم عدة أساليب للتدريب اللاحق مثل SFT وCPT وDPO وGRPO وGKD. اختيار منهجية التعلم المعزز ليس مجرد تفضيل خوارزمي، بل قرار بنيوي يؤثر مباشرة في ميزانية وحدات معالجة الرسوميات (GPU) واستقرار التدريب وقابلية إعادة الإنتاج. حالة GLM-5.2 تدفعنا إلى إعادة طرح السؤال، ليس «ماذا نستخدم» بل «لماذا نستخدمه».

## الجدار الذي اصطدم به GRPO: ثمن التخلي عن الـ critic

لنبدأ أولاً بسبب انتقال هذا العدد الكبير من الفرق إلى GRPO. الـ PPO التقليدي بنية actor-critic. السياسة (actor) تولّد الرموز، ونموذج قيمة منفصل (critic) يقدّر المكافأة المتوقعة لكل حالة. من هذا التقدير تُحسب الأفضلية (advantage، غالبًا عبر GAE)، وتُحدَّث السياسة عبر دالة هدف بديلة (surrogate) مقصوصة (clipped). المشكلة هي تكلفة تدريب هذا الـ critic. يجب إضافة نموذج آخر بحجم يقارب حجم السياسة نفسها، وإذا تقارب الـ critic بشكل خاطئ، يهتز التدريب بأكمله.

يتخلى GRPO عن هذا الـ critic تمامًا. بعد أخذ عينات من عدة استجابات لنفس المُوجِّه (prompt)، يُطبَّع المكافأة داخل تلك المجموعة، فتُبنى الأفضلية اعتمادًا فقط على التفوق النسبي. باختفاء الـ critic، تنخفض الذاكرة المستخدمة، ويختفي معه عدم استقرار تدريب نموذج القيمة. وبفضل أناقته الرياضية أيضًا، انتشر بسرعة.

لكن لا توجد وجبة مجانية. تتلاشى إشارة الأفضلية في الأسلوب النسبي الجماعي عندما يكون التباين داخل المجموعة صغيرًا، أي عندما تكون الاستجابات متقاربة في الجودة سواء كانت جيدة أو سيئة. كذلك يصعب إسناد الفضل (credit assignment) الدقيق على مستوى الرمز في التسلسلات الطويلة. لو وُجد نموذج قيمة، لأمكن تقدير «مدى إسهام هذا الرمز في المكافأة النهائية» لكل حالة، لكن التطبيع الجماعي وحده لا يوفر هذه الدقة. تبرز هذه المحدودية بوضوح في المسائل ذات المسارات الطويلة والمكافآت النادرة، كأعمال البرمجة والوكلاء طويلة النفَس. وهذا بالضبط المجال الذي استهدفه GLM-5.2.

## اختيار GLM-5.2: PPO بإحياء نموذج القيمة

هنا يستعيد فريق GLM-5.2 نموذج القيمة المدرَّب. أي أنهم يستعيدون الـ critic الذي تخلى عنه GRPO، لاستعادة دقة تقدير الأفضلية على مستوى الرمز. وعلى عكس التصور السائد بأن «ضجة PPO مبالغ فيها»، راهن الفريق على أن نموذج قيمة مدرَّبًا جيدًا يمنح إشارة أكثر استقرارًا في المسارات الطويلة.

المشكلة أن استعادة الـ critic تعيد معها أيضًا عدم استقرار التدريب المذكور سابقًا. وهنا تضاف مشكلة جديدة خاصة ببنى التعلم المعزز الحديثة، وهي عدم التطابق بين توزيعي التدريب والاستدلال.

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
<div class="d3-arch" data-arch-root id="20260710glm52ppoicepop-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 529, "height": 994, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 149, "y": 24, "w": 163, "h": 62, "title": ["دفعة من المُوجِّهات", "(prompts)"]}, {"id": "B", "x": 209, "y": 164, "w": 191, "h": 62, "title": ["محرك الاستدلال SGLang", "توليد التجارب (rollout)"]}, {"id": "C", "x": 227, "y": 304, "w": 156, "h": 62, "title": ["الرموز المولَّدة +", "المكافآت"]}, {"id": "D", "x": 216, "y": 444, "w": 177, "h": 62, "title": ["محرك التدريب Megatron", "إعادة حساب forward"]}, {"id": "E", "x": 193, "y": 584, "w": 223, "h": 84, "title": ["احتمال الاستدلال ≠ احتمال", "التدريب", "عدم تطابق التوزيع"]}, {"id": "F", "x": 334, "y": 768, "w": 163, "h": 62, "title": ["انفجار نسبة الأهمية", "انهيار التدريب"]}, {"id": "G", "x": 109, "y": 760, "w": 170, "h": 78, "title": ["كبح الرموز عالية عدم", "التطابق", "تحديث سياسة مستقر"]}, {"id": "H", "x": 24, "y": 916, "w": 191, "h": 46, "title": "تحديث PPO لنموذج القيمة"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[263, 86], [305, 125], [305, 125], [305, 164]]}, {"src": "B", "dst": "C", "kind": "data", "line": [305, 226, 305, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [305, 366, 305, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [305, 506, 305, 584]}, {"src": "E", "dst": "F", "kind": "data", "label": "\"بلا تصحيح\"", "curve": [[358, 668], [416, 714], [416, 714], [416, 768]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "\"إخفاء IcePop\"", "curve": [[252, 668], [194, 714], [194, 714], [194, 760]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "curve": [[194, 838], [194, 877], [194, 877], [147, 916]]}, {"src": "H", "dst": "A", "kind": "data", "curve": [[97, 916], [58, 626], [58, 335], [154, 86]]}]});
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
      const container = document.getElementById('20260710glm52ppoicepop-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260710glm52ppoicepop-1';
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

## IcePop: كيفية معالجة عدم التطابق بين التدريب والاستدلال

يتنقل التدريب اللاحق الحديث بالتعلم المعزز بين محركين مختلفين. يتولى توليد التجارب (rollout) محرك استدلال عالي الإنتاجية مثل SGLang، بينما يتولى حساب forward الفعلي لتحديث السياسة محرك تدريب مثل Megatron. المشكلة أن هذين المحركين، حتى لو استخدما نفس أوزان النموذج، يختلفان في تنفيذ النواة (kernel) والدقة العددية وترتيب العمليات، فينتجان احتمالات مختلفة قليلاً لنفس الرمز.

يصحّح التعلم المعزز عادةً هذه الفجوة عبر أخذ العينات بالأهمية (importance sampling)، أي ضرب نسبة احتمال السياسة وقت الاستدلال إلى احتمالها وقت التدريب. لكن عند الرموز التي يتباعد فيها التوزيعان، تنفجر هذه النسبة صعودًا أو هبوطًا بشكل حاد. وإذا سيطرت بضعة رموز ذات نسبة متطايرة على التدرّج (gradient)، يهتز التدريب بأكمله، وقد ينهار في الحالات الشديدة. وكلما طال المسار، أي زاد عدد الرموز، ارتفع احتمال تراكم هذا التطاير. وكان هذا تحديًا حاسمًا بالنسبة لـ GLM-5.2 الذي استهدف الأعمال طويلة النفَس.

يتصدى IcePop لهذا التطابق المفقود مباشرة. فهو يحدد الرموز التي يتباعد فيها توزيع الاستدلال عن توزيع التدريب بشكل كبير، ويكبح إسهام تلك الرموز أو يخفيها، بحيث لا ينجرف التدرّج خلف عدد قليل من الرموز غير المستقرة. والنتيجة أن إشارة الرموز المستقرة فقط هي التي تنعكس على تحديث السياسة. بهذه الطريقة يمكن الاستفادة من مزايا PPO بإحياء نموذج القيمة، مع تجنب الانهيار الناتج عن عدم التطابق بين التدريب والاستدلال.

النقطة التي يختلف فيها GLM-5.2 عن IcePop الأصلي هي إزالة حد التنظيم KL. تفرض كثير من وصفات التعلم المعزز عقوبة KL لمنع السياسة من الابتعاد كثيرًا عن السياسة المرجعية. يرفع هذا الحد الاستقرار، لكنه في الوقت نفسه يكبح المدى الذي يمكن أن تتحسن فيه السياسة. رأى فريق GLM-5.2 أن إخفاء IcePop لعدم التطابق في التوزيع يعالج بالفعل جزءًا كبيرًا من عدم الاستقرار، فأزالوا حد KL للسماح للسياسة بالتحسن بجرأة أكبر. وبذلك استغنوا عن أداة استقرار واحدة، وأوكلوا دورها إلى انتقاء الرموز في IcePop.

## البنية التحتية: slime وMegatron وSGLang

لكي لا تبقى هذه الخوارزمية مجرد فكرة على الورق وتعمل فعليًا، لا بد من بنية تحتية تتحمل توسّع التعلم المعزز. جرى التدريب اللاحق لـ GLM-5.2 على إطار عمل لتوسيع التعلم المعزز يُسمى slime، ويستخدم Megatron-LM للتدريب الموزَّع وSGLang لتوليد التجارب عالي الإنتاجية. وعدم التطابق بين التدريب والاستدلال الذي شرحناه سابقًا ينبع بالضبط من هذا التكوين. تتباعد الاحتمالات لأن Megatron (التدريب) وSGLang (الاستدلال) يستخدمان كل منهما نواة محسَّنة خاصة به، ويستهدف IcePop تحديدًا هذه الفجوة البنيوية.

بعبارة أخرى، IcePop ليس تحسينًا خوارزميًا بحتًا، بل أقرب إلى تصميم مشترك بين النظام والخوارزمية يستجيب لمشكلة على مستوى النظام تنشأ حتمًا في بنى التعلم المعزز الحديثة التي تفصل بين محرك التدريب ومحرك الاستدلال. والدرس الذي يقدمه هذا للممارسين واضح: عند اختيار منهجية التعلم المعزز، لا يكفي النظر إلى الخوارزمية وحدها، بل يجب النظر أيضًا إلى مجموعة محركي التدريب والاستدلال التي تعمل عليها.

## دلالات التطبيق على منتجات ThakiCloud

منصة ai-platform لدى ThakiCloud بنية تحتية للذكاء الاصطناعي وتعلم الآلة قائمة على K8s، تشغّل خط أنابيب تدريب يدعم جدولة وحدات معالجة الرسوميات عبر Kueue وأساليب متعددة للتدريب اللاحق (SFT وCPT وDPO وGRPO وGKD). حالة GLM-5.2 تحمل دلالات مباشرة لتصميم هذا الخط.

أولاً، منهجية التعلم المعزز ليست خيارًا يُثبَّت مرة واحدة، بل اختيارًا يُحدَّد بحسب طبيعة المسألة. في محاذاة التفضيلات ذات المسارات القصيرة، يظل GRPO بلا critic خيارًا اقتصاديًا. لكن في المسائل التي يهم فيها إسناد الفضل على مستوى الرمز، كمسارات البرمجة والوكلاء الطويلة، قد يمنح PPO بنموذج قيمة إشارة أكثر استقرارًا. في بنية مثل بنيتنا التي تدعم عدة أساليب على منصة واحدة، فإن إتاحة هذا الاختيار للمستخدم بحسب طبيعة مسألته يخلق قيمة عملية حقيقية.

ثانيًا، عدم التطابق بين التدريب والاستدلال ليس أمرًا بعيدًا عنا. عند تشغيل تعلم معزز مُقسَّم (يُستخرج فيه التجريب من محرك استدلال من عائلة vLLM/SGLang بينما يجري التحديث في محرك التدريب) في بيئة متعددة المستأجرين، تنشأ فجوة الاحتمالات نفسها. وإذا جهّزنا تصحيحًا لانتقاء الرموز على غرار IcePop كخيار في بيئة التشغيل التدريبية، يمكن أن نرفع بشكل كبير استقرار التدريب لدى العملاء الذين يريدون صقل نماذجهم الخاصة بالتعلم المعزز في بيئات محلية (on-premise) أو سيادية. تكلفة خدمة منخفضة وخط أنابيب تدريب مستقر ميزتان تنافسيتان حاسمتان لأي فريق يدرس الاستضافة الذاتية.

من منظور الوكلاء (agents)، ترتبط هذه الحالة أيضًا بـ Paxis. Paxis سحابة أصيلة الوكلاء (Agent-Native Cloud) تعمل فوق ai-platform، تتعامل مع المهارات والأدوات والسياسات كموارد من الدرجة الأولى. تدريب مسارات الوكلاء طويلة النفَس الذي شدّد عليه GLM-5.2 هو في جوهره تعزيز لقدرة الوكيل على إنجاز المهام عبر استدعاء الأدوات على مدى خطوات متعددة. والدرس المستفاد من هذه الحالة، وهو أن نموذج قيمة مدرَّبًا جيدًا يمنح إشارة دقيقة في المسارات الطويلة، مرجع يستحق الاعتبار عند التفكير في استراتيجية تدريب ترفع جودة تدفقات عمل الوكلاء متعددة الخطوات التي تتعامل معها Paxis.

## القيود والاعتراضات

يجب توخي الحذر عند تعميم هذه الحالة. أولاً، لا ينبغي قراءتها كخلاصة مبسطة مفادها أن «PPO أفضل من GRPO». اختيار GLM-5.2 حكمٌ في سياق مسألة محددة تتسم بالمسارات الطويلة والمكافآت النادرة. في المسائل ذات المكافآت القصيرة وعالية الكثافة، قد تفوق تكلفة الحفاظ على الـ critic فائدتَه، وفي هذه الحالة يبقى GRPO خيارًا معقولاً. كما أن القيد الواقعي المتمثل في عودة ميزانية ذاكرة وحدات معالجة الرسوميات إلى الارتفاع بمجرد إحياء نموذج القيمة يظل قائمًا كما هو.

إزالة حد KL في IcePop ليست حلاً شاملاً أيضًا. تنظيم KL آلية أمان تمنع السياسة من الانفلات بعيدًا عن السياسة المرجعية. والاعتماد الكلي على إخفاء عدم تطابق التوزيع بعد إزالة هذا الحد لا يصح إلا في ظل افتراض أن الإخفاء يعمل بشكل جيد. وقد ينهار هذا الافتراض في توزيعات بيانات مختلفة أو تركيبات محركات استدلال مختلفة، لذا فإن التحقق من الاستقرار في البيئة الخاصة إجراء ضروري لا غنى عنه، بدلاً من نقل الأسلوب كما هو.

أخيرًا، الشرح التقني في هذا المقال توليف من تحليلات منشورة وورقة بحثية (على arXiv بعنوان "GLM-5: from Vibe Coding to Agentic Engineering") وشروحات ثانوية. يجب التحقق من المعاملات الفائقة (hyperparameters) الدقيقة والأرقام الفعلية لاختبارات المعايير من المصدر الأصلي مباشرة، وقد تكون تفاصيل تنفيذية لم يتطرق إليها هذا المقال حاسمة في إعادة الإنتاج الفعلية. التدريب اللاحق بالتعلم المعزز مجال يصعب فيه إعادة الإنتاج بشكل خاص، لذا من الأسلم تلقّي هذا المقال باعتباره «اتجاهًا يستحق التفكير فيه» لا «وصفة مضمونة النجاح».

## المصادر

- [arXiv, "GLM-5: from Vibe Coding to Agentic Engineering" (arXiv:2602.15763)](https://arxiv.org/abs/2602.15763)
- ["Why is GLM-5.2 So Good: The GRPO to PPO Switch", Medium (Coding Nexus)](https://medium.com/coding-nexus/why-is-glm-5-2-so-gooood-the-grpo-to-ppo-switch-5b3b7d613ace)
- ["Zhipu's GLM-5.2: A Usability Breakthrough for Chinese Open-Source Models?", Weijin Research](https://weijinresearch.substack.com/p/zhipus-glm-52-a-usability-breakthrough)
