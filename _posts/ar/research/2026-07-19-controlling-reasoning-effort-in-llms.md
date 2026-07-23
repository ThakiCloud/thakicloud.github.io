---
title: "التحكم في جهد الاستدلال (reasoning effort) - كيف تتعلم نماذج اللغة الكبيرة أوضاع التفكير المنخفض والمتوسط والعالي"
excerpt: "مع طرح GPT-5.6 لخمسة أو ستة إعدادات لجهد الاستدلال لكل حجم، أصبح التحكم في الجهد ركيزة أساسية لنماذج الاستدلال. نتناول هنا وصفة التدريب الكامنة خلف التسمية نفسها، بالاستناد إلى التقارير التقنية لستة نماذج مفتوحة الأوزان لرسم الهيكل المشترك بينها."
seo_title: "التحكم في جهد الاستدلال - كيف تتعلم نماذج اللغة الكبيرة أوضاع الاستدلال المنخفض والمتوسط والعالي - Thaki Cloud"
seo_description: "ما هو جهد الاستدلال وكيف يتم تدريبه؟ من SFT المشروط بالجهد وعقوبات الطول في RLVR إلى وصفات التدريب والتحكم في الميزانية وقت الاستدلال لستة نماذج مفتوحة الأوزان (DeepSeek V4 وNemotron 3 Ultra وKimi K2.5 وGLM-5 وQwen3 وInkling)، نلخص تحليل Sebastian Raschka من منظور السحابة وخدمة الاستدلال."
date: 2026-07-19
last_modified_at: 2026-07-19
canonical_url: "https://thakicloud.com/tech-blog/ar/research/controlling-reasoning-effort-in-llms/"
lang: ar
reading_time: true
tags:
  - reasoning-models
  - reasoning-effort
  - rlvr
  - test-time-compute
  - inference-cost
  - deepseek-v4
  - qwen3
  - glm-5
  - kimi-k2
  - nemotron
author_profile: true
toc: true
categories:
  - research
---

إذا كنت تدير خدمة استدلال بنفسك، أو تراقب ميزانية وحدات معالجة الرسوميات (GPU)، أو تفكر في أي مرحلة من إطار عمل الوكيل (agent harness) يجب أن تضع فيها نموذجاً مكلفاً، فمن المرجح أنك واجهت مؤخراً إعداداً باسم "reasoning effort" في ملاحظات إصدار النماذج أكثر من مرة. عند ضبطه على قيمة منخفضة تصبح الاستجابة سريعة ورخيصة لكن الجودة تتراجع، وعند رفعه ترتفع الدقة لكن عدد الرموز (tokens) ووقت الاستجابة يتضخمان. تستند هذه المقالة إلى تحليل Sebastian Raschka الصادر في تموز 2026 بعنوان [Controlling Reasoning Effort in LLMs](https://magazine.sebastianraschka.com/p/controlling-reasoning-effort-in-llms)، وتشرح ما يحدث فعلياً خلف ذلك الإعداد، وما يلزم من أجل تدريب نموذج على هذا السلوك، من منظور السحابة وخدمة الاستدلال. والخلاصة منذ البداية: حتى تحت التسميات نفسها low/medium/high، تختلف وصفة التدريب من نموذج لآخر، ولا توجد بعد طريقة واحدة يمكن وصفها بأنها الإجابة الصحيحة.

## أصبحت نماذج الاستدلال هي المعيار، والآن نختار مقدار الجهد

مرّ نحو عامين منذ أن عمّمت OpenAI نماذج الاستدلال في نماذج اللغة الكبيرة عبر o1، وبعد أربعة أشهر فتحت DeepSeek-R1 الباب أمام طريقة التدريب نفسها بنشر وصفة تعلم معزز (RLVR) تستخدم مكافآت قابلة للتحقق. منذ ذلك الحين، تحوّل الاستدلال من ميزة خاصة إلى لبنة بناء افتراضية في إصدارات النماذج الجديدة. عائلة GPT-5.6 التي صدرت الأسبوع الماضي تُطرح بثلاثة أحجام، ويأتي كل حجم مع نحو خمسة إلى ستة إعدادات لجهد الاستدلال.

من هنا تبرز ملاحظة أساسية. بناء نموذج استدلال، وتمكين المستخدم من اختيار مدة تفكير ذلك النموذج، مشكلتان منفصلتان. الأولى نوقشت باستفاضة، أما الثانية، أي "كيفية جعل مقدار الجهد مُدخلاً قابلاً للتحكم"، فهي أقل تنظيماً نسبياً. عملياً، هذه القدرة على التحكم هي رافعة تكلفة. فتوجيه الاستعلامات السهلة إلى جهد منخفض، وتخصيص الجهد العالي فقط للاستعلامات الصعبة، يتيح رفع كل من الإنتاجية والجودة معاً على وحدات المعالجة نفسها.

## ما هو جهد الاستدلال

تجريبياً، رفع الجهد يزيد عدد الرموز المُولَّدة، ويرتفع أداء المعايير القياسية معه. غير أن هذه العلاقة ليست خطية، فكلما ارتفعنا في مستويات الجهد، تضاءل مقدار تحسّن الأداء لكل رمز إضافي. تُظهر مواد عرض Inkling من Thinking Machines بوضوح هذا المنحنى: يرتفع عدد الرموز والأداء معاً مع تصاعد مستوى الجهد، لكن المكاسب تتباطأ في المستويات العليا. من منظور الخدمة، هذا يعني أن أعلى مستوى جهد ليس دائماً الخيار الأفضل.

فكيف يُحدَّد الجهد وقت الاستدلال إذن؟ الأمر بسيط بشكل مفاجئ. يتم التحكم به عادةً بسطر واحد ضمن موجّه النظام (system prompt). وحتى اختيار القائمة المنسدلة في واجهة ChatGPT يبدو أنه يُترجَم داخلياً إلى موجّه نظام محدد. لكن المشكلة أن هذا الأسلوب لا ينجح مع أي نموذج. يجب أن يكون النموذج مدرَّباً بحيث إنه عند تلقيه تعليمات مثل "الجهد: منخفض" يفكر فعلاً بشكل أقصر مع الحفاظ على الجودة. بعبارة أخرى، للحصول على تحكم سهل وقت الاستدلال، لا بد من دفع الثمن بإعادة صياغة خط أنابيب التدريب.

## كيف يتم التدريب: محوران

سواء كان الأمر يتعلق بـ GPT-5.6 أو gpt-oss مفتوح المصدر، فإن تفاصيل التدريب الدقيقة غير معلنة، لكن بشكل عام تُدرَج تسمية الجهد ضمن الموجّه في مرحلة ما بعد التدريب (post-training). وتنقسم طرق تنفيذ ذلك إلى مسارين رئيسيين.

الأول، خلال RLVR يمكن تطبيق عقوبة طول مختلفة بحسب موجّه النظام. فعند إعداد "الجهد: منخفض" تُطبَّق عقوبة طول قوية، وعند "الجهد: عالٍ" تُطبَّق عقوبة ضعيفة أو معدومة. وهذا يعزّز قدرة النموذج على ضبط طول تفكيره بنفسه بما يتوافق مع الجهد المطلوب. الثاني، بعد انتهاء RLVR يمكن إجراء ضبط دقيق (SFT) لجعل النموذج يتبع تعليمات جهد مختلفة. هنا تُقرَن موجّهات بيانات التدريب باستجابات مستهدفة تحتوي على مقدار الاستدلال المطلوب، وقد تكون تلك الأهداف مكتوبة بشرياً أو مولَّدة بنموذج آخر أو مولَّدة ثم مُصفّاة.

الصورة العامة للطريقتين موضحة أدناه. معظم الوصفات الفعلية هي تنويعات على هذا الهيكل.

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
<div class="d3-arch" data-arch-root id="ingreasoningeffortinllms-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 261, "height": 694, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 52, "y": 24, "w": 149, "h": 46, "title": "베이스 / RLVR 리즈닝 모델"}, {"id": "B", "x": 35, "y": 148, "w": 184, "h": 62, "title": ["1. SFT + chat template", "노력 모드를 입력으로 도입"]}, {"id": "C", "x": 24, "y": 288, "w": 205, "h": 78, "title": ["2. mode-conditioned RL", "노력별 context window·length", "penalty 차등"]}, {"id": "D", "x": 31, "y": 444, "w": 191, "h": 78, "title": ["3. 하드 예산 강건성 학습", "truncated trace·강제 중단 후", "재개·budget toggle"]}, {"id": "E", "x": 28, "y": 600, "w": 198, "h": 62, "title": ["추론: system prompt로 노력 선택", "+ 선택적 토큰 예산"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [127, 70, 127, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [127, 210, 127, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [127, 366, 127, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [127, 522, 127, 600]}]});
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
      const container = document.getElementById('ingreasoningeffortinllms-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ingreasoningeffortinllms-1';
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

## تعمّق في ستة نماذج مفتوحة الأوزان

بدلاً من الاكتفاء ببحث إثبات المفهوم، اختار Raschka وصفات ستة نماذج حديثة مفتوحة الأوزان لديها أدلة واقعية على أنها تعمل. يختلف مستوى الإفصاح من تقرير لآخر، لكن كل نموذج منها يُظهر تنويعاً مفيداً واحداً على الأقل.

### DeepSeek V4: فصل الجهد إلى خبراء مستقلين

يصف التقرير التقني لـ DeepSeek V4 ثلاثة أوضاع. Non-think يجيب مباشرة دون أثر استدلال، وThink High هو الأسلوب الكلاسيكي على طريقة R1 الذي يضع أثر الاستدلال بين `<think>` و`</think>`، أما Think Max فيضيف فوق ذلك تعليمات نظام خاصة. تبدأ تعليمات Think Max بعبارة "Reasoning Effort: Absolute maximum with no shortcuts permitted". الفكرة الجوهرية هي التعامل مع مستويات الجهد المختلفة كأنها خبراء منفصلون تقريباً، وصقلها عبر RL مشروط بالوضع (mode-conditioned RL).

### Nemotron 3 Ultra: الجمع بين وضع مدرَّب وميزانية صارمة

يستخدم Nemotron 3 Ultra ثلاثة إعدادات: reasoning-off وregular وmedium-effort. وmedium-effort وضع استدلال أرخص من regular، وتُدخله NVIDIA خلال مرحلة SFT باستخدام مخرجات GPT-OSS-120B بجهد متوسط، ثم تُحسّنه لاحقاً عبر RLVR. ونحو 2.5% من موجّهات RLVR تخص medium-effort، وتُطبَّق عليها معايرة مكافأة مبنية على الطول. وفوق ذلك، يمكن تركيب ميزانية رموز وقت الاستدلال كآلية إيقاف خارجية. إذ يُطلب من النموذج إنهاء الاستدلال قرب حد يحدده العميل، وإن لم يُصدر النموذج `</think>` من تلقاء نفسه يقوم العميل بإغلاقه قسراً. ولضمان ألا تنهار الإجابة عند القطع بهذه الطريقة، يُدرَّب النموذج على آثار مقطوعة عشوائياً لتحقيق المتانة.

### Kimi K2.5: مفتاح Toggle الذي يتناوب بين المُقيَّد وغير المُقيَّد

تنطلق طريقة Toggle الخاصة بـ Kimi K2.5 من مشكلة أن التدريب على ميزانية رموز ثابتة فقط يجعل النموذج يفرط في التلاؤم مع الحلول القصيرة ويفقد فائدة الحوسبة الإضافية. لذلك تتناوب الطريقة بين مرحلتين كل عدد محدد من تكرارات التدريب. في مرحلة budgeted تُوجَّه الحلول الصحيحة للبقاء ضمن ميزانية رموز خاصة بكل مسألة، وفي مرحلة unconstrained يُستعاد أقصى طول للتوليد بحيث يستمر النموذج في التعلم من الحلول الطويلة أيضاً. تُقدَّر الميزانية من نسبة مئوية محددة لأطوال الجولات الصحيحة في RLVR، لكن قيد الميزانية لا يُفعَّل إلا بعد أن تتجاوز دقة تلك المسألة عتبة معينة. الهدف هو رفع كفاءة الرموز بشكل كبير مع الحفاظ على أداء المعايير القياسية الإجمالي عند مستوى مشابه.

### GLM-5: التفكير على مستوى الدور، المتشابك، والمحفوظ

يوسّع GLM-5 مفتاح التشغيل/الإيقاف الثنائي في GLM-4.5 ليشمل سيناريوهات متعددة الأدوار واستخدام الأدوات. وتكمن ميزته المميزة في أنه يعرّف ثلاثة سلوكيات مترابطة بدلاً من ثلاثة مستويات جهد. فـ interleaved thinking يضع كتلة استدلال قبل كل استجابة واستدعاء أداة، وpreserved thinking يحتفظ بكتل الاستدلال السابقة ويعيد استخدامها عبر أدوار متعددة، وturn-level thinking يشغّل الاستدلال ويوقفه لكل طلب ضمن المحادثة. والمفتاح الفعلي وقت الاستدلال هو turn-level. وفي واجهة برمجة تطبيقات Z.ai يكون مفعّلاً افتراضياً ويمكن تعطيله على مستوى كل طلب على حدة.

### Qwen3: دمج الأوضاع والقطع وقت الاستدلال

يتألف خط أنابيب ما بعد التدريب في Qwen3 من أربع مراحل: long-CoT SFT، وRL الاستدلال، وThinking Mode Fusion، وRL عام. وجوهر مفتاح التشغيل/الإيقاف للجهد هو Thinking Mode Fusion، الذي يجري SFT على مزيج من أمثلة thinking وnon-thinking. أمثلة `/think` تحتوي على أثر استدلال، بينما تبدأ أمثلة `/no_think` بكتلة `<think></think>` فارغة تليها إجابة قصيرة. ويعزّز RL العام اللاحق الالتزام بالتعليمات والصيغة في كلا السلوكين. كما يدعم Qwen3 ميزانية تفكير صارمة، حيث يتوقف الاستدلال عند عتبة محددة، ثم تُدرج تعليمات إيقاف، ثم يُنتقل إلى الإجابة النهائية. ومن اللافت أن التقرير يذكر أن سلوك الاستدلال الجزئي هذا لم يُدرَّب عليه صراحة، بل ظهر تلقائياً بعد Thinking Mode Fusion. وهو أبسط من DeepSeek V4 أو Nemotron، لكنه يوفّر معاً مفتاح تشغيل/إيقاف مدرَّباً وميزانية وقت الاستدلال.

### Inkling: جهد عبر موجّه النظام مع RL مشروط بالوضع

يحدد Inkling الجهد عبر موجّه النظام، مدعوماً بـ RL مشروط بالوضع. وكما رأينا سابقاً، يُظهر هذا النموذج النزعة نفسها التي يرتفع فيها عدد الرموز والأداء معاً مع رفع الجهد لكن المكاسب تتباطأ في المستويات العليا، وهو مرجع مفيد لتحديد أين يجب وضع سقف الجهد عند الخدمة.

## هيكل مشترك: تسميات متطابقة لكن إطار واحد

عند وضع النماذج الستة جنباً إلى جنب، يظهر إطار مشترك بينها. أولاً، يُدخَل وضع الجهد كمُدخل عبر SFT وقالب المحادثة (chat template). فـ Qwen3 يمزج صراحة بين أمثلة thinking وnon-thinking، وGLM-5 يضيف فوق ذلك أنماط interleaved وpreserved وturn-level. ثانياً، في مرحلة RL المشروط بالوضع، يتغيّر نافذة السياق وعقوبة الطول بحسب الجهد المطلوب. تستخدم DeepSeek V4 وNemotron 3 Ultra وInkling هذا النهج. ثالثاً، تُضاف متانة تحت ميزانية صريحة. فـ Nemotron يتدرب على آثار مقطوعة عشوائياً، ويمكن لـ Qwen3 استئناف الاستدلال من نقطة توقف قسري، ويتناوب Kimi بين RL المُقيَّد وغير المُقيَّد. هذه الآليات تحافظ على جودة الإجابة حتى عندما يتغير طول الاستدلال المتاح أو يُقطَع في منتصف الطريق.

الجدول التالي يلخّص ما هو موثّق فعلياً عبر التقارير الستة.

| النموذج | الأوضاع / الإعدادات | آلية التدريب | التحكم وقت الاستدلال |
|---|---|---|---|
| DeepSeek V4 | Non-think / Think High / Think Max | فصل خبراء الجهد + RL مشروط بالوضع | موجّه النظام (Think Max يضيف تعليمات) |
| Nemotron 3 Ultra | off / regular / medium | SFT بمخرجات GPT-OSS-120B + RLVR (نحو 2.5%) + تدريب على آثار مقطوعة | قالب المحادثة + ميزانية رموز خارجية |
| Kimi K2.5 | budgeted / unconstrained | Toggle: تناوب مرحلتَي RL | ميزانية رموز خاصة بكل مسألة |
| GLM-5 | turn-level / interleaved / preserved | SFT موسَّع لتعدد الأدوار واستخدام الأدوات | مفتاح تشغيل/إيقاف على مستوى الدور |
| Qwen3 | think / no_think | Thinking Mode Fusion (SFT مختلط) + RL عام | تشغيل/إيقاف + ميزانية تفكير صارمة (قطع) |
| Inkling | جهد متعدد المستويات | RL مشروط بالوضع | موجّه النظام |

## الخلاصة ومنظور ThakiCloud

ما تُظهره هذه الحالات الست هو أن التسميات المتشابهة قد تستند إلى خبراء منفصلين، أو بيانات SFT مختلطة، أو مكافآت مشروطة بالوضع، أو ميزانيات رموز صارمة، أو مزيج من هذه العناصر. ومن الصعب الجزم بأن طريقة واحدة هي الأفضل، لأن كل نموذج يختلف في نقطة انطلاقه الأساسية، وبيانات تدريبه، وحجم حوسبة ما بعد التدريب، والمعايير القياسية المستخدمة، وأهداف الخدمة، كما أن التقارير تحذف تفاصيل ضرورية لمقارنة عادلة. فطريقة تناسب مساعداً محادثياً جيداً قد تكون خياراً سيئاً لوكيل برمجة يعمل لفترة طويلة.

الهدف النهائي هو بالطبع الاختيار التلقائي للجهد. حاول وضع Auto في GPT-5 في وقت ما السير في هذا الاتجاه بالضبط، لكن النتيجة كانت أقرب إلى الفشل منها إلى النجاح، وانتهى الأمر باختفائه من الواجهة. في المستقبل القريب، من المرجح أن يظل الجهد مُدخلاً صريحاً للنموذج، يُمرَّر غالباً عبر موجّه النظام، بينما يتولى إطار عمل الوكيل الذي يغلّف النموذج أو موجّه داخلي استنتاج الوضع والميزانية المناسبين بشكل متزايد تلقائياً من حالة المهمة والميزانية المتبقية. وبالطبع سيظل هناك خيار تجاوز يدوي من المستخدم للحالات التي تُعطي الأولوية لزمن الاستجابة أو التكلفة، أو التي تستهدف أقصى أداء ممكن.

هذه هي النقطة التي تتقاطع بدقة مع تشغيل منصتنا. فإذا أمكن التعامل مع ميزانية الاستدلال كرافعة، يمكن توزيع تكلفة خدمة وحدات المعالجة الرسومية وزمن الاستجابة بما يتناسب مع صعوبة الاستعلام. توجيه الطلبات السهلة إلى جهد منخفض، وحفظ الجهد العالي للطلبات الصعبة فقط، بالاقتران مع جدولة GPU القائمة على Kueue، يفتح مجالاً حقيقياً لرفع الإنتاجية والجودة معاً على العنقود نفسه. وفي الممارسة العملية، عند تشغيل إطار عمل وكيل، يكون من الأفضل من حيث نسبة التكلفة إلى الجودة تخصيص الاستدلال المكلف لعدد قليل من الخطوات مثل التحقق والتوليف، ومعالجة الاستكشاف والتلخيص بجهد منخفض. التحكم في الجهد ليس ميزة يُتفاخر بها في النموذج، بل رافعة تكلفة-جودة تستخدمها يومياً الفرق التي تدير بنية تحتية للاستدلال، ومن الأنسب عملياً قراءة هذا الاتجاه من هذه الزاوية.

يحتوي المقال الأصلي على روابط غنية لتقارير كل نموذج التقنية ورسومات توضيحية، لذا إن احتجت إلى تفاصيل الوصفة الخاصة بنموذج معين، نوصي بمراجعة [مقالة Sebastian Raschka الأصلية](https://magazine.sebastianraschka.com/p/controlling-reasoning-effort-in-llms) والتقرير المعني مباشرة.
