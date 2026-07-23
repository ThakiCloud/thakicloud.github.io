---
title: "عصر ينجز فيه الذكاء الاصطناعي اختراقاً من 32 خطوة حتى النهاية: GPT-5.6 Sol والأمن السيبراني"
excerpt: "أعلنت OpenAI أن GPT-5.6 Sol سجل رقماً قياسياً جديداً في ساحة اختبار سيبرانية. عندما تبدأ النماذج المتقدمة بتنفيذ سلاسل هجوم حقيقية بشكل مستقل، تنتقل نقطة الحسم من أداء النموذج نفسه إلى المكان والضوابط التي يُشغَّل النموذج تحتها."
seo_title: "GPT-5.6 Sol والأمن السيبراني: تحليل هجوم The Last Ones ذي الـ32 خطوة وحزمة الدفاع"
seo_description: "سجل GPT-5.6 Sol من OpenAI نسبة 73.5% في ExploitBench2 ليتصدر كأقوى نموذج في الأمن السيبراني. نحلل لماذا أصبحت ساحة The Last Ones ذات الـ32 خطوة التابعة لـ AISI، وحزمة الأمان متعددة الطبقات، والذكاء الاصطناعي السيادي المحلي، وبوابات سياسات الوكلاء، جوهر الدفاع الآن."
date: 2026-07-19
last_modified_at: 2026-07-19
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
tags:
  - cybersecurity
  - frontier-model
  - agentops
  - paxis
  - sovereign-ai
  - thakicloud
categories:
  - news
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/news/gpt-5-6-sol-cybersecurity/"
---

بقيت جملة واحدة عالقة في ذهني هذا الصباح وأنا أتصفح خط الزمن. الجملة التي أعلنت فيها OpenAI عن نموذجها الرائد الجديد GPT-5.6 Sol، وذكرت أنه سجل رقماً قياسياً جديداً في ساحة تقييم الأمن السيبراني المعروفة باسم "The Last Ones". المهم هنا ليس الرقم بحد ذاته، بل دلالة الجملة. فهي تعني أن الذكاء الاصطناعي يصل إلى نقطة يتجاوز فيها مجرد مساعدة البشر في اكتشاف الثغرات، ليبدأ بتنفيذ سيناريوهات هجوم متعددة المراحل حتى النهاية دون تدخل بشري.

سبب عدم استطاعة شركة بنية تحتية مثل ThakiCloud أن تنظر إلى هذا الخبر باعتباره شأناً بعيداً عنها واضح. فكلما ارتفعت القدرات الهجومية للنماذج المتقدمة، ينتقل مركز ثقل الدفاع من سؤال "أي نموذج أذكى" إلى سؤال "أين يُشغَّل هذا النموذج، وتحت سيطرة من، وبأي سجلات تدقيق". النماذج ستستمر في التقوي على أي حال. وبالتالي فإن نقطة الحسم تصبح عزل بيئة التنفيذ، وبوابات السياسات، وإمكانية التتبع بعد وقوع الحادث. سنتناول اليوم أولاً ما أنجزه GPT-5.6 Sol فعلياً استناداً إلى حقائق مؤكدة، ثم ننتقل لشرح لماذا تُضاعف هذه القدرة من الحاجة إلى الذكاء الاصطناعي السيادي المحلي وطبقة تحكم الوكلاء.

## ما هو GPT-5.6 Sol ولماذا يُركَّز على الأمن السيبراني

GPT-5.6 هو عائلة نماذج كشفت عنها OpenAI في 9 يوليو 2026. تضم ثلاث فئات مرتبة حسب القدرة: لونا (Luna)، تيرا (Terra)، وسول (Sol)، حيث يُعد Sol النموذج الرائد الأقوى. وأوضحت OpenAI أنها تُشغِّل Sol فوق بنية Cerebras بمعدل يصل إلى 750 رمزاً في الثانية، مؤكدة أنها رفعت سرعة المعالجة إلى جانب القدرة نفسها.

المحور الأبرز في هذا الإعلان هو الأمن السيبراني. وصفت OpenAI Sol بأنه أقوى نموذج أمن سيبراني في تاريخها، موضحة أنه نقل حدود الأداء والكفاءة في المهام الأمنية طويلة النفس، بما فيها بحوث الثغرات والاستغلال. الجوهر هنا هو "الذهاب أبعد برموز أقل". فانخفاض عدد رموز الاستدلال اللازمة للوصول إلى النتيجة نفسها يعني أيضاً إمكانية أتمتة محاولات هجوم أكثر بالميزانية ذاتها. وفي المرحلة التي يُترجم فيها تحسن القدرة مباشرة إلى انخفاض في التكلفة، ينخفض العتبة أمام كل من المدافعين والمهاجمين على حد سواء.

هناك نقطة يجب توضيحها بأمانة. النص الأصلي للتغريدة هو إعلان صادر عن OpenAI نفسها، بينما التقييم المستقل لساحة "The Last Ones" التي سنتناولها لاحقاً (من قِبل معهد سلامة الذكاء الاصطناعي البريطاني AISI) كان حتى وقت النشر يقتصر على GPT-5.5. لذا فإن ادعاء Sol بـ"الرقم القياسي الجديد" هو رقم قدمته OpenAI نفسها، ومن الأسلم قراءته كادعاء من الجهة المعلنة إلى حين اكتمال نشر نتائج إعادة الإنتاج من طرف ثالث. يقتبس هذا المقال الأرقام القابلة للتحقق مع تمييزها بوضوح عن الجهة التي أعلنتها.

## "The Last Ones": ما تقيسه ساحة الاختبار السيبرانية ذات الـ32 خطوة

"The Last Ones" هو سيناريو اختراق محاكى لشبكة شركة افتراضية تديره AISI. يتكون من 32 خطوة إجمالاً، ويُقدَّر أن إنجازه من البداية إلى النهاية على يد خبير بشري متمرس يستغرق نحو 20 ساعة. وليس مجرد حل مسائل منفصلة، بل بنية يجب فيها ربط عدة قدرات ضرورية للاختراق الفعلي في خيط واحد لاجتيازه. يتعين على الوكيل أن يستولي على النظام، وأن يفكك البروتوكولات والمصادقة المشفرة عبر الهندسة العكسية، وأن يتلاعب بوحدات التحكم، كل ذلك عبر سلسلة من القرارات المستقلة المتصلة.

عدد النماذج التي أكملت هذه الساحة حتى النهاية حتى الآن قليل جداً. كان Claude Mythos preview أول من نجح، حيث أكمل ثلاث مرات من أصل عشر محاولات (3/10)، تلاه GPT-5.5 كثاني نموذج ينجزها حتى النهاية بمعدل مرتين من أصل عشر (2/10). قد يبدو معدل النجاح منخفضاً مقارنةً بعدد المحاولات، لكن مجرد إتمام هجوم متعدد المراحل يستغرق 20 ساعة دون تدخل بشري ولو مرة واحدة يُعد إشارة على تجاوز عتبة حرجة. وتشير دراسة ذات صلة (arXiv 2603.11214) إلى أن هذه القدرة تتناسب لوغاريتمياً وخطياً مع حجم الحساب في وقت الاستدلال، ولم يُلاحَظ بعد أي مستوى استقرار لها. وتحمل النتيجة القائلة إن رفع ميزانية الرموز من عشرة ملايين إلى مئة مليون يمكن أن يرفع الأداء بنسبة تصل إلى 59% دلالة مقلقة، مفادها أن احتمال إتمام الهجوم يستمر في الارتفاع كلما زاد المال والوقت المستثمَران فيه.

## القفزة في القدرات كما تظهرها المقاييس المرجعية

تظهر هذه القفزة في القدرات أيضاً في المقاييس المرجعية الفردية. وفقاً لـ OpenAI، سجل GPT-5.6 نسبة 73.5% في ExploitBench2، وهو مقياس تقييم قدرات الاستغلال، متفوقاً بفارق كبير على نسبة 47.9% التي حققها GPT-5.5 بميزانية رموز إخراج مماثلة تقريباً. أي ارتفاع بأكثر من 25 نقطة مئوية في جيل واحد فقط. لكن هناك تفصيلاً هنا أيضاً. تشير اختبارات OpenAI نفسها إلى أن GPT-5.6 أكثر براعة في اكتشاف الثغرات وإصلاحها منه في تنفيذ الهجوم الفعلي حتى النهاية بشكل موثوق. أي أن ميزان القدرة لا يزال، حتى الآن، يميل لصالح الدفاع.

هذا التمييز مهم من الناحية السياسية. فالنموذج نفسه، إن وُضع في يد المدافع، يصبح أداة لاكتشاف الثغرات وترقيعها بكميات كبيرة، وإن وُضع في يد المهاجم، يصبح محرك أتمتة للاختراق. Aardvark، الباحث الأمني الوكيلي الذي كشفت عنه OpenAI بشكل منفصل، يستهدف بالتحديد هذا الاستخدام الدفاعي. قُدِّم Aardvark كوكيل مستقل يساعد المطورين وفرق الأمن على اكتشاف الثغرات وإصلاحها تلقائياً، وحددت OpenAI صراحةً أولويتها في أن تصل هذه القدرة إلى المدافعين أولاً وقبل كل شيء.

## الدفاع قبل الهجوم: حزمة الأمان متعددة الطبقات من OpenAI

في هذا السياق أيضاً امتنعت OpenAI عن فتح Sol بالكامل منذ البداية، واقتصرت إتاحته على مجموعة محدودة من الشركاء الموثوقين. فالوصول مقصور في البداية على عملاء منتقين بعناية، وأوضحت الشركة أن هذا القرار جاء في سياق تنسيق وثيق مع الحكومة الأمريكية حول إطار الأمن السيبراني. وكلما اقتُرِب من الحكم بأن القدرة تجاوزت عتبة حرجة، يُشدَّد النشر بمزيد من الحذر.

من الناحية التقنية أيضاً أُضيفت طبقات دفاع متعددة. وفقاً للإعلان، زُوِّد Sol وTerra بمصنِّف تفعيل جديد مركّز على المجالات الحساسة، يراقب النموذج أثناء عملية التوليد، ويتدخل في المنتصف لإيقافه إذا بدأ بإنتاج إجابة خطيرة. وإلى جانب ذلك، هناك قيود على مستوى النموذج تمنع بشكل جذري أي دعم سيبراني محظور، ومراقبة فورية للمخرجات عبر مصنِّف إساءة الاستخدام، وتحليل سلوكي على مستوى الحساب لرصد الأنماط الخبيثة. لا تُسلَّم المخرجات مباشرة، بل تمر أولاً عبر مراجعة نظام استدلال ثانوي قبل أن تصل إلى المستخدم. والمخطط أدناه يلخص تدفق هذا الدفاع متعدد الطبقات.

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
<div class="d3-arch" data-arch-root id="719gpt56solcybersecurity-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 493, "height": 1020, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 179, "y": 24, "w": 120, "h": 46, "title": "طلب المستخدم"}, {"id": "B", "x": 147, "y": 148, "w": 184, "h": 78, "title": ["قيود على مستوى النموذج", "حظر الدعم السيبراني", "الممنوع"]}, {"id": "C", "x": 133, "y": 304, "w": 212, "h": 78, "title": ["مصنِّف التفعيل", "مراقبة أثناء التوليد وتدخل", "في المنتصف"]}, {"id": "D", "x": 147, "y": 460, "w": 184, "h": 62, "title": ["مراقبة فورية للمخرجات", "مصنِّف إساءة الاستخدام"]}, {"id": "E", "x": 147, "y": 600, "w": 184, "h": 78, "title": ["مراجعة نظام الاستدلال", "الثانوي", "إيقاف مؤقت قبل التسليم"]}, {"id": "F", "x": 151, "y": 756, "w": 177, "h": 78, "title": ["تحليل سلوكي على مستوى", "الحساب", "رصد الأنماط الخبيثة"]}, {"id": "G", "x": 263, "y": 934, "w": 198, "h": 46, "title": "تسليم الاستجابة أو حظرها"}, {"id": "H", "x": 24, "y": 926, "w": 184, "h": 62, "title": ["مراجعة وحظر وإجراء على", "الحساب"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [239, 70, 239, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [239, 226, 239, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [239, 382, 239, 460]}, {"src": "D", "dst": "E", "kind": "data", "line": [239, 522, 239, 600]}, {"src": "E", "dst": "F", "kind": "data", "line": [239, 678, 239, 756]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[295, 834], [362, 880], [362, 880], [362, 934]]}, {"src": "F", "dst": "H", "kind": "event", "label": "نمط غير طبيعي", "curve": [[183, 834], [116, 880], [116, 880], [116, 926]], "off": "50%"}]});
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
      const container = document.getElementById('719gpt56solcybersecurity-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '719gpt56solcybersecurity-1';
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

النقطة الجديرة بالملاحظة أن هذه البنية ليست مرشحاً واحداً. فداخل النموذج (مصنِّف التفعيل)، وعلى حدود المخرجات (مصنِّف إساءة الاستخدام)، وعلى مستوى الحساب (التحليل السلوكي)، تتراقب طبقات مختلفة من زوايا مختلفة في آن واحد. إنه دفاع عميق مصمَّم بحيث تلتقط الطبقة التالية ما تفوته الطبقة السابقة. وهذه الفكرة بالذات هي ما يُنقَل مباشرة إلى مزودي البنية التحتية.

## دلالات التطبيق على منتجات ThakiCloud

خبر ارتفاع القدرة الهجومية للنماذج المتقدمة يصب، بشكل مفارق، في صالح الذكاء الاصطناعي المحلي والسيادي. فكلما أصبح الهجوم المستقل واقعاً، تسعى الشركات والجهات الحكومية إلى وضع الإجابة على سؤال "من استدعى هذا النموذج، وماذا طلب منه، وأي مخرجات تلقى" تحت سيطرتها الخاصة. منصة **ai-platform** من ThakiCloud تتماشى تماماً مع هذا المطلب. فهي، فوق جدولة GPU قائمة على K8s وKueue، تُبقي النموذج داخل عنقود العميل، وتقدمه بعزل متعدد المستأجرين، وتدعم النشر المحلي والسيادي بحيث لا تتجاوز البيانات الحدود الخارجية. وكلما كان عبء العمل الأمني أكثر حساسية، ازدادت قيمة الاستضافة الذاتية التي تُبقي أوزان النموذج وحركة الاستدلال داخل بنيتك التحتية الخاصة. وانخفاض تكلفة التقديم يشكل أيضاً شرطاً عملياً يتيح للمدافع تشغيل مهام متكررة بكميات كبيرة، مثل فحص الثغرات، بميزانية يمكن تحملها.

على مستوى الوكلاء، يتشابه تصميم **Paxis** بشكل لافت مع حزمة الأمان متعددة الطبقات التي رأيناها أعلاه. Paxis هو طبقة تحكم Agent-Native Cloud تعمل فوق ai-platform، وتعامل المهارات (Skills) والأدوات (Tools) والسياسات (Policies) وسجلات التدقيق (Audit Logs) كموارد من الدرجة الأولى. تُنفَّذ المهارة التي يشغِّلها الوكيل داخل صندوق رمل معزول دون تلويث بيئة المضيف، ولا يُنفَّذ أي إجراء إلا بعد اجتياز بوابة سياسات، وتُسجَّل كل هذه العملية في سجل تدقيق. تماماً كما وضعت OpenAI شبكة مراقبة متداخلة عبر داخل النموذج وخارجه وعلى مستوى الحساب، يفصل Paxis اختيار المهارة (هارنس BM25)، والتنفيذ (عزل صندوق الرمل)، والتحكم (بوابة السياسات)، والتتبع (سجل التدقيق) إلى طبقات منفصلة. هذه البنية تمنع الوكيل المستقل من استخدام أداة خاطئة على هدف خاطئ، وتتيح، إن وقع حادث، تتبع أين ومتى حدث الخلل.

كلا المنظورين يكمّل الآخر. إذا كان ai-platform يمثل ضبطاً مادياً يُبقي النموذج داخل حدودك، فإن Paxis يمثل ضبطاً منطقياً يقيّد سلوك الوكيل الذي يستخدم ذلك النموذج بالسياسات والسجلات. في عصر ينجز فيه الذكاء الاصطناعي اختراقاً من 32 خطوة بشكل مستقل، لا تكمن أساسيات الدفاع في اختيار نموذج قوي، بل في تشغيل أي نموذج داخل بيئة خاضعة للرقابة مع ترك أثر لسلوكه. هذا هو السبب في أن طبقة تحكم الذكاء الاصطناعي المحلي والوكلاء تزداد أهمية الآن.

## القيود والحجج المضادة

من أجل التوازن، سنتناول الجانب المقابل أيضاً. أولاً، تستند أفضلية Sol في الأمن السيبراني إلى حد كبير على إعلان OpenAI نفسها، وبما أن الوصول محدود، فإن التحقق المستقل من إعادة الإنتاج لا يزال غير كافٍ. تخضع الأرقام المرجعية لشروط قياس الجهة المعلنة، لذا من الأسلم اعتبارها إشارة اتجاهية فقط إلى حين تراكم تقييمات طرف ثالث.

ثانياً، ملاحظة أن القدرة تميل حالياً لصالح الدفاع ليست سبباً كافياً للاطمئنان. فإذا استمر التوسع اللوغاريتمي الخطي دون توقف، يمكن أن ينقلب التوازن الحالي المؤاتي للدفاع في أي لحظة لمجرد زيادة حجم الحساب. عبارة "الآن هو أكثر براعة في الدفاع منه في الهجوم" وصف للحظة راهنة، وليست ضماناً دائماً للسلامة.

ثالثاً، النشر المحلي والعزل وبوابات السياسات ليست مجانية. فتشغيل بنية تحتية خاصة يتطلب استثماراً أولياً وكوادر متخصصة وعبء ترقيع مستمر. وقد يظل خيار السحابة المُدارة، بما يوفره من سهولة، معقولاً بالنسبة للمؤسسات الصغيرة. الفكرة ليست أن الحل المحلي هو الإجابة الصحيحة دائماً، بل أن النقطة التي تتجاوز فيها قيمة الرقابة وإمكانية التدقيق تكلفة الراحة تتقدم كلما ارتفعت حساسية عبء العمل.

وأخيراً، بوابات السياسات وسجلات التدقيق نفسها ليست بلا عيوب. فحزمة الدفاع تصبح هدفاً لمحاولات الالتفاف، وقد بدأت بالفعل أبحاث لكسر قيود Sol. معنى الدفاع متعدد الطبقات ليس وعداً بعدم الاختراق، بل ضمان أن تلتقط الطبقة التالية أي اختراق وأن يمكن تتبعه لاحقاً. هذا الهدف المتواضع هو بالضبط تصميم الدفاع الواقعي لهذا العصر.

## المصادر

- [التغريدة الأصلية (RT @OpenAI)](https://x.com/hjguyhan/status/2078708617822564773)
- [GPT-5.6: Frontier intelligence that scales with your ambition | OpenAI](https://openai.com/index/gpt-5-6/)
- [Previewing GPT-5.6 Sol: a next-generation model | OpenAI](https://openai.com/index/previewing-gpt-5-6-sol/)
- [GPT-5.6 Preview System Card | OpenAI Deployment Safety Hub](https://deploymentsafety.openai.com/gpt-5-6-preview)
- [Introducing Aardvark: OpenAI's agentic security researcher](https://openai.com/index/introducing-aardvark/)
- [Our evaluation of OpenAI's GPT-5.5 cyber capabilities | AISI](https://www.aisi.gov.uk/blog/our-evaluation-of-openais-gpt-5-5-cyber-capabilities)
- [OpenAI Previews GPT-5.6 Sol With Restricted Access and Stronger Cyber Safeguards | The Hacker News](https://thehackernews.com/2026/06/openai-limits-gpt-56-rollout-as-sol.html)
- [Measuring AI Agents' Progress on Multi-Step Cyber Attack Scenarios | arXiv 2603.11214](https://arxiv.org/html/2603.11214v2)
