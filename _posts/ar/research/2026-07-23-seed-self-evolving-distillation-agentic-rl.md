---
title: "الوكيل يُعلّم نفسه بمهارات كتبها بنفسه: كيف يحل SEED مشكلة المكافأة النادرة"
excerpt: "العائق الحقيقي في التعلّم المعزّز للوكلاء (agentic RL) هو أن المكافأة تصل مرة واحدة فقط، في نهاية المسار (trajectory). يحوّل SEED هذه الإشارة النادرة الوحيدة إلى إشراف كثيف على مستوى الرمز (per-token) عبر جعل الوكيل يستخرج مهارات باللغة الطبيعية من مساراته الخاصة ويقطّرها (distill) عائدةً إلى نفسه."
tags: [agentic-rl, reinforcement-learning, on-policy-distillation, sparse-reward, self-evolving, llm-agents, post-training, sample-efficiency, hindsight-skills, credit-assignment]
date: 2026-07-23
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/seed-self-evolving-distillation-agentic-rl/"
categories: [research]
author_profile: true
toc: true
---

إذا كنت تدرّب وكلاء نماذج لغوية كبيرة (LLM agents) تتحرك عبر استخدام الأدوات متعدد الأدوار (multi-turn tool use) وتغذية البيئة الراجعة باستخدام التعلّم المعزّز (RL)، فهذا المقال موجّه إليك. إليك الخلاصة أولاً. السبب الأكثر شيوعاً في ضعف أداء agentic RL ليس أن النموذج ضعيف، بل أن المكافأة تصل مرة واحدة فقط في نهاية المسار، وSEED يحوّل تلك الإشارة النادرة الوحيدة إلى إشراف كثيف على مستوى الرمز عبر جعل الوكيل يحلّل مساراته الخاصة، ويستخرج مهارات باللغة الطبيعية، ويقطّرها عائدةً إلى نفسه. رفعت هذه الطريقة كلاً من الأداء وكفاءة العيّنة (sample efficiency) عبر مهام الوكلاء النصية والبصرية على حد سواء.

![تصوير تجريدي لوكيل يتأمل مساره الخاص ويقطّر المعرفة عائدةً إلى نفسه](/assets/images/seed-self-evolving-distillation-agentic-rl-hero.webp)
*تصوير تجريدي لحلقة SEED ذاتية التطور: استخراج المهارات من المسارات المكتملة وتغذيتها عائدةً إلى السياسة (policy) نفسها.*

## لماذا يستحق هذا المقال القراءة

كُتب هذا المقال للمهندس الذي يجري التدريب اللاحق (post-training) للوكلاء باستخدام التعلّم المعزّز، ولمسؤول المنصة الذي يصمم البنية التحتية للتدريب من تحته. أنت أمام قرار واحد: كيف تدفع بإشراف إضافي إلى خط أنابيب RL يكافئ حالياً النتيجة فقط؟ يجيب SEED (Self-Evolving On-Policy Distillation، arXiv:2607.14777) بمسار لا يستخدم نموذج معلّم قوياً منفصلاً ولا نموذج مكافأة بشري الصنع، بل السياسة نفسها بوصفها معلّمة لذاتها. باختصار، إن حلقة تحليل المسار، واستخراج مهارات قابلة لإعادة الاستخدام، واستخدام مقدار ما تحدثه تلك المهارات من إزاحة في احتمالات الأفعال بوصفه إشارة التدريب، تصنع إشرافاً على القرارات الوسيطة دون أي تسميات (labels) إضافية.

## نظرة عامة

قادت السنوات القليلة الماضية من تدريب نماذج الاستدلال التعلّمُ المعزّز القائم على النتيجة، أي عائلة RLVR التي تستخدم مكافآت قابلة للتحقق. تمنح مكافأة على مستوى المسار مثل 1 للصحيح و0 للخطأ وتدفع السياسة إلى الأعلى. في مسائل الرياضيات أو البرمجة ذات الاستجابة الواحدة، ينجح هذا جيداً. المشكلة هي الوكلاء. في مسار طويل يستدعي الأدوات مراراً، ويتلقى ملاحظات، ثم يتصرف مجدداً، لا يخبرك نجاح الإجابة النهائية بشيء يُذكر عن جودة كل قرار من عشرات القرارات الوسيطة بينهما. تنفتح فجوة إشراف (supervision gap) بين النتيجة على مستوى الحلقة (episode) والتعلّم على مستوى الرمز. تلك الفجوة هي العائق الجوهري الذي يقضم كفاءة العيّنة في agentic RL.

يقترح SEED طريقة لسدّها. الفكرة الجوهرية أن المسار المكتمل يحتوي أصلاً على ما يستحق التعلّم. المسار الناجح يحمل سير عمل (workflow) قابلاً لإعادة الاستخدام، والفاشل يحمل فخاً يجب تجنّبه. يجعل SEED هذه المعرفة اللاحقة (hindsight) صريحة على هيئة مهارات باللغة الطبيعية، ثم يقطّرها عائدةً إلى السياسة. والمحلّل الذي يستخرج هذه المهارات ليس نموذجاً خارجياً بل السياسة الحالية نفسها. إنها بنية ذاتية التطور تقوم فيها السياسة بجمع المسارات واستخراج المهارات منها في آن واحد.

## ما هو SEED

في جملة واحدة، SEED إطار ذاتي التطور يحوّل المسارات المكتملة على السياسة (on-policy) إلى مهارات معرفة لاحقة في زمن التدريب ويقطّر أثرها السلوكي عائداً إلى نموذج السياسة. قسّمه إلى ثلاث خطوات تتضح البنية.

أولاً، يُضبط النموذج بدقة (fine-tuned) ليحلل المسارات المكتملة ويولّد مهارات باللغة الطبيعية. تلتقط هذه المهارات سير العمل القابل لإعادة الاستخدام، أو الملاحظات الحاسمة، أو قواعد تجنّب الفشل. فبدلاً من أن يحقن إنسانٌ القواعد عبر موجّه (prompt)، يستخرج النموذج القواعد من تجربته الخاصة ويصوغها لغةً.

ثانياً، أثناء RL تؤدي السياسة الحالية دورين في وقت واحد. أحدهما التفاعل مع البيئة وجمع المسارات كالمعتاد، والآخر أن تكون المحلّل الذي يستخرج مهارات المعرفة اللاحقة من تلك المسارات. ولأنه لا يوجد معلّم منفصل، لا ينشأ عدم توافق في التوزيع بين المعلّم والطالب، وتبقى المهارات متوائمة مع توزيع المسارات الذي تسلكه السياسة فعلاً في هذه اللحظة.

ثالثاً، وهنا الأداة الجوهرية في SEED، يعيد تسجيل درجات الأفعال المُعاينة (sampled actions) ضمن سياقين. أحدهما سياق عادي دون مهارات، والآخر سياق مُعزَّز بالمهارات المستخرجة. مقدار ارتفاع أو انخفاض احتمال فعل معيّن عند إرفاق المهارة، تلك الإزاحة في الاحتمال، يصبح إشارة تقطير كثيفة على مستوى الرمز وعلى السياسة (on-policy). ثم تُحسَّن هذه الإشارة بالاشتراك مع RL القائم على النتيجة. إنها تدفع السياسة نحو الأفعال التي كانت ستختارها باحتمال أعلى لو كانت المهارة حاضرة، والأهم أن هذا الإشراف المساعد يبقى متوائماً مع توزيع المسارات الحالي.

يوضّح المخطط أدناه الحلقة.

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
<div class="d3-arch" data-arch-root id="ingdistillationagenticrl-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 629, "height": 942, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 230, "y": 24, "w": 135, "h": 46, "title": "السياسة الحالية"}, {"id": "B", "x": 334, "y": 162, "w": 177, "h": 46, "title": "جمع المسارات المكتملة"}, {"id": "C", "x": 327, "y": 286, "w": 191, "h": 62, "title": ["السياسة نفسها تتحول إلى", "محلّل"]}, {"id": "D", "x": 320, "y": 440, "w": 205, "h": 62, "title": ["مهارات معرفة لاحقة باللغة", "الطبيعية"]}, {"id": "E", "x": 311, "y": 580, "w": 223, "h": 52, "title": "إعادة تسجيل درجات الأفعال"}, {"id": "F", "x": 455, "y": 724, "w": 142, "h": 46, "title": "الاحتمال الأساسي"}, {"id": "G", "x": 237, "y": 724, "w": 163, "h": 46, "title": "احتمال مدرك للمهارة"}, {"id": "H", "x": 227, "y": 848, "w": 184, "h": 62, "title": ["إزاحة الاحتمال = إشارة", "تقطير على مستوى الرمز"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "التفاعل مع البيئة", "curve": [[339, 70], [422, 116], [422, 116], [422, 162]], "off": "50%"}, {"src": "B", "dst": "C", "kind": "data", "line": [422, 208, 422, 286]}, {"src": "C", "dst": "D", "kind": "data", "label": "سير عمل قابل لإعادة الاستخدام<br/>ملاحظات حاسمة<br/>قواعد تجنّب الفشل", "line": [422, 348, 422, 440], "lx": 422, "ly": 390}, {"src": "D", "dst": "E", "kind": "data", "line": [422, 502, 422, 580]}, {"src": "E", "dst": "F", "kind": "data", "label": "سياق بلا مهارات", "curve": [[460, 632], [526, 678], [526, 678], [526, 724]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "سياق مع المهارات", "curve": [[385, 632], [319, 678], [319, 678], [319, 724]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "curve": [[526, 770], [526, 809], [526, 809], [410, 848]]}, {"src": "G", "dst": "H", "kind": "data", "line": [319, 770, 319, 848]}, {"src": "H", "dst": "A", "kind": "data", "label": "تحسين مشترك مع RL القائم على النتيجة", "curve": [[237, 848], [134, 606], [134, 317], [243, 70]], "off": "50%"}]});
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
      const container = document.getElementById('ingdistillationagenticrl-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ingdistillationagenticrl-1';
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

التباين مع المقاربات السابقة واضح. التقطير من معلّم خارجي قوي يتطلب إيجاد ذلك المعلّم، وإذا انحرف توزيعا المعلّم والطالب تلوّثت الإشارة. وبناء نموذج مكافأة بشري باهظ التسميات. يتجنّب SEED كليهما. المعلّم هو السياسة نفسها، والتسميات تُستخرج آلياً من المسارات، والإشارة متوائمة مع السياسة الحالية في كل خطوة.

## ما الذي تقرّره الورقة البحثية

تُبلغ الورقة عن تجارب واسعة على مهام الوكلاء النصية والبصرية معاً. اتجاه النتائج متسق. حسّن SEED كلاً من الأداء وكفاءة العيّنة، وكان تعميمه على سيناريوهات لم تُرَ أثناء التدريب متيناً. ومقارنةً بطرائق أساس قوية، حقق أقوى متوسط أداء عبر ثلاثة معايير قياس (benchmarks) تمثيلية للوكلاء، وهو الادعاء المركزي للورقة.

تجدر هنا ملاحظة صادقة. كُتب هذا المقال استناداً إلى مُلخّص الورقة وملخّصها العام، ونشجعك على التحقق من الأرقام لكل معيار مباشرةً في المصدر. هذه ليست قيماً قِسناها عبر إعادة إنتاج منفصلة، لذا بدلاً من اقتباس أرقام مطلقة ركّزنا على نقل بنية النتائج واتجاهها. حتى الاتجاه وحده يحمل دلالة واضحة. كفاءة عيّنة أعلى تعني بلوغ الأداء نفسه بعدد أقل من المسارات، أي ساعات GPU أقل، وهذا يقابل مباشرةً توفير أغلى مورد لأي جهة تُشغّل agentic RL فعلاً.

## ماذا يعني هذا لـ ThakiCloud

تمسّ الفكرة التي يطرحها SEED كلا المنتجين اللذين تشغّلهما ThakiCloud.

زاوية Paxis مباشرة على نحو خاص. Paxis هي سحابة ThakiCloud الأصيلة للوكلاء (Agent-Native Cloud)، وتعامل المهارات والأدوات والسياسات وسجلات التدقيق (audit logs) بوصفها موارد من الدرجة الأولى. وفي داخلها طبقة مهارات ذاتية التطور يستخرج فيها الوكلاء المهارات من التجربة ويتحسّنون من تلقاء أنفسهم. ما أثبته SEED أكاديمياً هو هذه الفكرة بالضبط: أن حلقةً تجعل المسارات المكتملة صريحة على هيئة مهارات باللغة الطبيعية وتغذيها عائدةً إلى السلوك تُحسّن السياسة فعلاً. وإذا كان مُسخّر المهارات (skill harness) في Paxis يختار من أكثر من 960 مهارة عبر BM25، وينفّذها في صناديق رمل (sandboxes) معزولة، ويمرّر كل فعل عبر بوابات السياسة وسجلات التدقيق، فإن SEED يقدم السند النظري في زمن التدريب لكيفية ولادة تلك المهارات من التجربة وصقلها. والمهارات المعبّر عنها باللغة الطبيعية يمكن للبشر قراءتها وتدقيقها، وهو ما يتلاءم جيداً مع فلسفة تصميم Paxis التي تُعلي شأن بوابات السياسة وسجلات التدقيق.

وثمة زاوية ai-platform أيضاً. إن تشغيل طريقة مثل SEED فعلياً يتطلب خط أنابيب تدريب لاحق يحسّن بالاشتراك RL القائم على النتيجة وإشارة تقطير، وهذا يستهلك موارد GPU كبيرة. تُشغّل منصة ai-platform لدى ThakiCloud تدريباً لاحقاً مثل SFT وDPO وGRPO فوق جدولة GPU القائمة على Kueue والخدمة متعددة المستأجرين (multi-tenant serving). ويتحول تحسين كفاءة العيّنة الذي يؤكده SEED مباشرةً إلى تكلفة على هذه البنية التحتية. فبلوغ جودة الوكيل نفسها بعدد أقل من المسارات يعني استيعاب مزيد من مهام التدريب على مجمع GPU مشترك، أو التدريب بعمق أكبر ضمن الميزانية نفسها.

## الحدود والاعتراضات

بنية SEED ذاتية التطور قوية، لكن كون السياسة تؤدي دور المحلّل أيضاً سيف ذو حدين. ففي المرحلة المبكرة حين تكون السياسة ما تزال ضعيفة، تكون جودة المهارات التي تستخرجها منخفضة بالضرورة كذلك، وإشارة تقطير مبنية على مهارات منخفضة الجودة قد تدفع التعلّم في الاتجاه الخطأ. وثمن عدم استخدام معلّم خارجي قوي هو أن تأمين جودة الإشارة خلال طور التمهيد (bootstrap) المبكر يصبح المعضلة العملية.

كما أن استخراج المهارات وإعادة تسجيل درجات الأفعال ضمن سياقين يضيف حسابات فوق RL القائم على النتيجة الصرف. والمقايضة بين مكسب تقليل عدد المسارات بفضل كفاءة عيّنة أفضل وكلفة إضافة التحليل وإعادة التسجيل لكل مسار ستعتمد على المهمة والحجم. وأخيراً، فإن النتائج التي يستند إليها هذا المقال هي لثلاثة معايير اختارتها الورقة، وما إذا كان المكسب ينتقل سليماً إلى مجالات أخرى، ولا سيما وكلاء الإنتاج الحقيقيين ذوي منظومات أدوات مختلفة جداً، يحتاج إلى تحقق منفصل.

## الخلاصة

إن تشخيص عائق التعلّم المعزّز للوكلاء بوصفه فجوة إشراف لا نقصاً في قدرة النموذج يشير إلى اتجاه: قبل توسيع النموذج، اجعل الإشارة أكثر كثافة. يُظهر SEED مساراً إلى تلك الإشارة الأكثف لا يشتريها من الخارج بل يستخرجها، على هيئة مهارات باللغة الطبيعية، من مسارات أنتجها الوكيل بالفعل ويعيدها إلى نفسه. إذا كنت تُشغّل خط أنابيب agentic RL، فالأمر الوحيد الذي تأخذه اليوم واضح. إن كنت تكافئ النتيجة فقط، فلا تُلقِ المسار جانباً؛ تحقق أولاً مما إذا كان ثمة متسع لاستخراج مهارات معرفة لاحقة وإعادة تدويرها إشرافاً على مستوى الرمز. فقد يكون ذلك الرافعة الأرخص للتجربة قبل نموذج أكبر أو معلّم أقوى.

المصدر: [SEED: Self-Evolving On-Policy Distillation for Agentic Reinforcement Learning (arXiv:2607.14777)](https://arxiv.org/abs/2607.14777)
