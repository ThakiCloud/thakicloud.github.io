---
title: "Fable 5 يحتاج أسلوب برمجة أوامر مختلفًا: التحولات الأربعة التي يطرحها دليل Anthropic الرسمي"
excerpt: "نشرت Anthropic بهدوء دليلًا رسميًا لبرمجة الأوامر (prompting) الخاص بـ Claude Fable 5 و Mythos 5. والفكرة الجوهرية ليست صياغة أوامر أكثر تفصيلًا، بل العكس تمامًا: احذف التعليمات المتراكمة التي بُنيت من أجل النماذج السابقة، واضبط الذكاء والتكلفة عبر معامل effort، وأخضع تقارير التقدم لتدقيق قائم على الأدلة، ونظّم العملاء الفرعيين (subagents) بشكل غير متزامن. نستعرض هذه التحولات الأربعة بالاستناد إلى الوثيقة الأصلية، ونوضح ما الذي يتغير من منظور تشغيل Paxis Agent-Native Cloud ومنصة ai-platform لدى ThakiCloud."
seo_title: "ملخص دليل Anthropic الرسمي لبرمجة أوامر Fable 5: effort والتحقق والعملاء الفرعيون - Thaki Cloud"
seo_description: "تحليل للتحولات الأربعة الجوهرية في دليل Anthropic الرسمي لبرمجة أوامر Fable 5: حذف التعليمات المفرطة، ضبط الذكاء والزمن والتكلفة عبر معامل effort، التحقق من التقدم بالاستناد إلى الأدلة، تنظيم العملاء الفرعيين بشكل غير متزامن، وأثر ذلك على تطبيقات Paxis وai-platform لدى ThakiCloud."
date: 2026-07-06
last_modified_at: 2026-07-06
tags:
  - ai-coding
  - agentic
  - claude-fable-5
  - prompt-engineering
  - agentops
  - verification
  - subagents
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/anthropic-fable5-prompting-guide/"
categories:
  - agentops
published: false
audiobook: "https://drive.google.com/file/d/1_nG1To0QYaWVlnxQxyG0f0KFXGaLJvcO/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

![Fable 5 يحتاج أسلوب برمجة أوامر مختلفًا: التحولات الأربعة التي يطرحها دليل Anthropic الرسمي 개념을 형상화한 이미지](/assets/images/anthropic-fable5-prompting-guide-hero.png)
*글의 핵심 개념을 형상화했습니다.*

## نظرة عامة

قبل أن تعاود فتح Claude Fable 5، ثمة وثيقة يجدر بك الاطلاع عليها أولًا. فقد نشرت Anthropic بهدوء دليلًا رسميًا لبرمجة الأوامر الخاص بـ Claude Fable 5 وClaude Mythos 5 ضمن وثائق هندسة البرومبت لديها. ولأنه صدر كصفحة وثائق واحدة دون أي إعلان صاخب، فاتت هذه الوثيقة كثيرين، لكن مضمونها يقلب رأسًا على عقب جزءًا كبيرًا من العادات التي تعاملنا بها مع الجيل السابق من النماذج، وهو ما يجعله غير قابل للتجاهل.

لنبدأ بالنقطة الأكثر مفارقة للحدس. الرسالة المحورية لهذا الدليل ليست "اكتب بشكل أفضل" بل تقترب أكثر من "اكتب أقل". فالتعليمات المفصّلة التي كانت تُبنى لاستخلاص نتائج جيدة من النماذج السابقة قد تُضعف الجودة فعليًا مع Fable 5. لقد صُمم Fable 5 كنموذج يُفوَّض إليه العمل على مهام معقدة وطويلة وغامضة، من النوع الذي يستغرق من الإنسان ساعات أو أيامًا أو حتى أسابيع لإنجازه، ومثل هذا النموذج تعوقه المقابض الزائدة عن الحاجة. وبما أن ThakiCloud تُشغّل بنية تحتية لخدمات الذكاء الاصطناعي كخدمة (AI/ML SaaS) قائمة على Kubernetes، إلى جانب منصة عملاء (agents) تعمل فوقها، وتتعامل يوميًا مع مثل هذه العملاء المستقلة طويلة الأمد، فإن كل توصية في هذا الدليل تتحول عندنا مباشرة إلى مسألة قواعد تشغيل. بالنسبة إلى الفرق التي تُشغّل عملاء (agents) مستقلين طويلي الأمد، فإن الفائدة العملية التي يمكن استخلاصها من هذا الدليل هي معرفة ما ينبغي حذفه من البرومبت وما يجب الإبقاء عليه حتمًا.

![صورة تجريدية تعبّر عن التحول في أسلوب برمجة الأوامر للعملاء المستقلين طويلي الأمد]({{ '/assets/images/anthropic-fable5-prompting-guide-hero.webp' | relative_url }})

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/anthropic-fable5-prompting-guide/nlm-infographic-1.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## ما هو هذا الدليل؟

هذه الوثيقة هي صفحة "Prompting Claude Fable 5" الواردة ضمن قسم هندسة البرومبت في وثائق منصة Anthropic الرسمية. تتناول أنماط برمجة الأوامر والسقالات (scaffolding) الخاصة بـ Fable 5 والفئة الأعلى منه Mythos 5، وتتألف من أربعة عشر فصلًا. وهي، بمعزل عن وثائق البرومبت العامة الموجهة للأجيال السابقة، دليل ذو طابع انتقالي (migration) يركز على ما تغيّر تحديدًا في هذه العائلة من النماذج.

الفرضية الجوهرية التي تخترق الوثيقة هي قفزة في القدرات. صُمم Fable 5 ليتحمّل مسائل كانت أعقد من أن تُمرَّر للنماذج السابقة، أو أطول من أن تُدار، أو أغمض من أن تُصاغ بوضوح. لذا فإن الطريقة الصحيحة للتعامل مع هذا النموذج ليست تشديد الضبط، بل التحول نحو منح النموذج هامشًا للحكم، مع إرساء هيكل من التحقق والتفويض يمنع ذلك الحكم من الانحراف. وتنقسم توصيات الدليل إلى أربعة محاور رئيسية.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="opicfable5promptingguide-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 975, "height": 570, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 383, "y": 24, "w": 212, "h": 78, "title": ["تفويض مهام مستقلة طويلة", "الأمد", "(بوحدات ساعات·أيام·أسابيع)"]}, {"id": "B", "x": 766, "y": 188, "w": 177, "h": 62, "title": ["التحول 1", "حذف التعليمات المفرطة"]}, {"id": "C", "x": 520, "y": 180, "w": 191, "h": 78, "title": ["التحول 2", "ضبط الذكاء والتكلفة عبر", "effort"]}, {"id": "D", "x": 291, "y": 180, "w": 163, "h": 78, "title": ["التحول 3", "تدقيق تقارير التقدم", "بالأدلة"]}, {"id": "E", "x": 28, "y": 180, "w": 184, "h": 78, "title": ["التحول 4", "تفويض العملاء الفرعيين", "بشكل غير متزامن"]}, {"id": "F", "x": 639, "y": 344, "w": 191, "h": 46, "title": "إتاحة هامش لحكم النموذج"}, {"id": "G", "x": 270, "y": 344, "w": 205, "h": 46, "title": "كبح تقارير التقدم الوهمية"}, {"id": "H", "x": 24, "y": 336, "w": 191, "h": 62, "title": ["معالجة متوازية وإعادة", "استخدام الذاكرة المخبأة"]}, {"id": "I", "x": 298, "y": 476, "w": 149, "h": 62, "title": ["تنفيذ مستقل", "طويل الأمد وموثوق"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[595, 86], [854, 141], [854, 141], [854, 188]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[552, 102], [615, 141], [615, 141], [615, 180]]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[431, 102], [373, 141], [373, 141], [373, 180]]}, {"src": "A", "dst": "E", "kind": "data", "curve": [[383, 85], [120, 141], [120, 141], [120, 180]]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[854, 250], [854, 297], [854, 297], [774, 344]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[615, 258], [615, 297], [615, 297], [695, 344]]}, {"src": "D", "dst": "G", "kind": "data", "line": [373, 258, 373, 344]}, {"src": "E", "dst": "H", "kind": "data", "line": [120, 258, 120, 336]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[735, 390], [735, 437], [735, 437], [447, 493]]}, {"src": "G", "dst": "I", "kind": "data", "line": [373, 390, 373, 476]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[120, 398], [120, 437], [120, 437], [298, 486]]}]});
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
      const container = document.getElementById('opicfable5promptingguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'opicfable5promptingguide-1';
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

## التحول 1: لا تُضِف إلى البرومبت، بل احذف منه

أول توصية ترد في الدليل هي إعادة قراءة البرومبتات والمهارات (skills) الحالية وحذف التعليمات التي لم تعد ضرورية. يوضح الدليل أن البرومبتات والمهارات التي صُممت من أجل النماذج السابقة كثيرًا ما تكون مفرطة التوجيه (too prescriptive) بالنسبة لـ Fable 5، بل قد تُضعف جودة المخرجات فعليًا. وبعبارة أخرى، فإن لحظة القفزة الكبيرة في القدرات هي بالضبط اللحظة المناسبة لتنظيف التعليمات القديمة.

يبدو هذا النصح غريبًا لأننا اعتدنا أن نتعامل مع هندسة البرومبت غالبًا كعملية إضافة. فكلما واجهنا استثناء أضفنا قاعدة، وكلما لاحظنا خطأً أضفنا بندًا منعيًا، فتستمر البرومبتات في التضخم. غير أن كثيرًا من تلك القواعد أُدرجت أصلًا لسدّ ثغرة معينة في نموذج بذاته. فإذا كان النموذج قد تجاوز تلك الثغرة فعلًا، فإن القاعدة المتبقية لا تصبح عونًا، بل تتحول إلى قيد يضيّق على حكم النموذج. وهذا هو السبب في تشديد الدليل على الحذف.

بالطبع، إن قرأنا هذه التوصية على أنها "احذف كل شيء من البرومبت" فسيكون ذلك خطرًا. فثمة تعليمات لا يزال يتوجب إدراجها صراحة، كتعليمات التحقق التي سنتناولها لاحقًا. عمليًا، الأمر أقرب إلى عملية تدقيق: تُزال التعليمات واحدة تلو الأخرى مع التأكد من عدم تراجع الجودة، مع التمييز بين البند الذي كان يسدّ عيبًا في نموذج بعينه، والبند الذي يمثل قيدًا جوهريًا في طبيعة المهمة نفسها.

## التحول 2: effort هو لوحة التحكم الرئيسية في الذكاء والزمن والتكلفة

في Fable 5، المقبض الأساسي لضبط التوازن بين الذكاء وزمن الاستجابة والتكلفة هو معامل effort. يوصي الدليل ببدء معظم المهام بمستوى high، واستخدام xhigh للأعباء التي تكون فيها القدرة أمرًا حاسمًا بشكل خاص، بينما تُستخدم medium أو low للأعمال المتكررة والنمطية. بعبارة أخرى، بدلًا من إطالة البرومبت لاستخلاص أداء أفضل، أصبح رفع effort أو خفضه بحسب طبيعة المهمة هو أسلوب التشغيل الأساسي.

هذا التغيير مهم من منظور تشغيلي. فرفع effort يجعل النموذج يجري استدلالًا (reasoning) أكثر، مما يرفع زمن الاستجابة والتكلفة معًا. لذا لا ينبغي التعامل مع effort كقيمة تُرفع دائمًا إلى أقصى حد، بل كمفهوم موازنة (budget) يُوزَّع بحسب صعوبة المهمة. فتشغيل المهام النمطية بمستوى xhigh يهدر التكلفة فقط، بينما معالجة القرارات الصعبة بمستوى low يقوّض الجودة. وهنا تصبح دقة توزيع effort، لا رهافة صياغة جملة البرومبت، هي العامل الذي يحدد النتيجة والفاتورة في آن واحد.

## التحول 3: أخضِع تقارير التقدم لتدقيق قائم على الأدلة

أشدّ أنماط الفشل إيلامًا في المهام المستقلة طويلة الأمد هو أن يُبلَّغ بثقة عن إنجاز عمل لم يُتحقق منه فعليًا. فحين تدور حلقة تستغرق ساعات ويقول النموذج "لقد أنهيت هذه الخطوة" دون أساس حقيقي لهذا الادّعاء، يصبح هذا التقرير غير موثوق، وقد تُبنى المهام اللاحقة فوق حالة خاطئة دون أن يُنتبه لذلك.

يقدّم الدليل جملة تعليمات محددة لهذه المشكلة: قبل الإبلاغ عن التقدم، ينبغي تدقيق كل ادّعاء بمقارنته مع نتائج الأدوات (tool results) في الجلسة الحالية، والإبلاغ فقط عن العمل الذي يمكن الإشارة إلى دليل عليه، مع التصريح بوضوح إن كان أمر ما لم يُتحقق منه بعد. وفيما يلي نص التعليمة الأصلية كما ورد:

```text
Before reporting progress, audit each claim against a tool result
from this session. Only report work you can point to evidence for;
if something is not yet verified, say so.
```

تشير Anthropic إلى أن هذه التعليمة، في اختباراتها الداخلية، قضت شبه كليًا على تقارير التقدم الملفّقة، حتى في المهام المصمّمة خصيصًا لاستدراج تقارير وهمية. والنقطة الجوهرية هنا مزدوجة. أولًا، هذا لا يتناقض مع التحول الأول القاضي بالحذف؛ فالقواعد القديمة التي كانت تسدّ عيوب النموذج تُحذف، لكن تعليمات من هذا النوع، التي تحمي موثوقية التنفيذ المستقل، يجب أن تُدرج صراحة. ثانيًا، معيار التحقق هنا لا يُستمد من ثقة النموذج بنفسه، بل من دليل خارجي هو نتيجة الأداة. وهذا يتطابق تمامًا مع مبدأ التزمناه طويلًا، وهو ألا يُعتمد تقرير النموذج الذاتي كشرط لإنهاء الحلقة.

## التحول 4: نظّم العملاء الفرعيين بشكل غير متزامن

التحول الرابع يتعلق ببنية تعدد العملاء (multi-agent). وفقًا للدليل، يتمتع Fable 5 باستقرار أعلى بكثير في إطلاق العملاء الفرعيين المتوازين والحفاظ عليهم، كما يدير بموثوقية العملاء الفرعيين طويلي الأمد والتواصل المستمر مع عملاء آخرين. والتوصية واضحة: استخدم العملاء الفرعيين بكثرة، مع تزويدهم بتوجيه صريح حول متى يكون التفويض مناسبًا، وفضّل التواصل غير المتزامن على أن ينتظر المنسّق (orchestrator) عودة كل عميل فرعي مع تعطّل التنفيذ في الأثناء.

وثمة أساس اقتصادي وأدائي فعلي لذلك. فالعملاء الفرعيون طويلو الأمد (long-lived) الذين يحافظون على السياق (context) عبر مهام فرعية متعددة، يوفرون الوقت والتكلفة عبر إعادة استخدام الذاكرة المخبأة (cache reuse)، ويتجنبون اختناقًا يعطّل النظام بأكمله بسبب أبطأ عميل فرعي. والنصيحة بتفويض المهام الفرعية المستقلة إلى العملاء الفرعيين مع استمرار المنسّق في العمل في الأثناء تشبه إلى حد كبير الطريقة التي يدير بها الإنسان فريقًا. أما التوصية باستخدام عميل فرعي مستقل للتحقق بدلًا من الاكتفاء بالنقد الذاتي وحده لضمان الجودة، فهي ترفع مبدأ التحقق القائم على الأدلة من التحول الثالث إلى مستوى تعدد العملاء.

## دلالات التطبيق على منتجات ThakiCloud

ينعكس هذا الدليل بشكل مباشر بوجه خاص على منصة Paxis التي نُشغّلها. Paxis هي Agent-Native Cloud الخاصة بـ ThakiCloud، وهي مستوى تحكم يختار من بين أكثر من 960 مهارة (skill) عبر خوارزمية BM25 وينفّذها في صناديق معزولة (sandboxes)، مع تمرير كل إجراء عبر بوابات سياسة وسجلات تدقيق (audit logs). وتتطابق التحولات الأربعة في الدليل مع هذه البنية واحدًا واحدًا.

فلسفة الحذف في التحول الأول تتقاطع مع مبادئ تصميم المهارات في Skill Harness لدينا؛ إذ التزمنا فعلًا بإبقاء المهارات خفيفة (thin) وتكديس المعرفة النطاقية بكثافة في متن المهارة، مع التعامل مع أي جملة زائدة كتكلفة على السياق يجب إزالتها. وهذا التأكيد الرسمي على أن Fable 5 لا يفضّل التعليمات المفرطة يمنحنا سندًا لإزالة البنود التي كانت تسدّ ثغرات نماذج جيل سابق من مهاراتنا القديمة. أما التحقق القائم على الأدلة في التحول الثالث، فهو الدور الذي تؤديه أصلًا بوابات السياسة وسجلات التدقيق لدينا؛ فادّعاء النموذج بإنجاز مهمة يختلف عن كون هذا الإنجاز مدعومًا فعليًا بنتائج الأدوات وسجلات التدقيق، وPaxis تتعامل مع الثاني كمورد من الدرجة الأولى. وتنظيم العملاء الفرعيين بشكل غير متزامن في التحول الرابع يطابق تمامًا تنفيذ تعدد العملاء القائم على DAG لدينا؛ فبنية منسّق يُمرّر المهام المستقلة بالتوازي دون تعطّل ثم يُغلق الحلقة عبر عقدة تحقق، تتطابق تمامًا مع مبدأنا القاضي بإغلاق أي تفرّع متوازٍ (fan-out) عبر مرحلة تحقق.

كما يجب النظر إلى الأمر من زاوية البنية التحتية لمنصة ai-platform. فرفع effort إلى xhigh يزيد من عدد رموز الاستدلال (reasoning tokens) مما يرفع الطلب على حوسبة GPU، وإطلاق عدد كبير من العملاء الفرعيين المتوازين يولّد ذروة مؤقتة في حِمل GPU. صُممت منصة ai-platform لدى ThakiCloud لامتصاص هذا الحِمل المتغيّر عبر جدولة GPU قائمة على Kueue وعزل متعدد المستأجرين (multi-tenant). كما أن ملاحظة الدليل بأن إعادة استخدام الذاكرة المخبأة لدى العملاء الفرعيين طويلي الأمد تخفض التكلفة تتفق مع هدفنا في خفض تكلفة الخدمة (serving) في البيئات المحلية والسيادية. فالخدمة منخفضة التكلفة تصنع جدوى اقتصادية للعملاء، وهذه الجدوى تتيح بدورها تفويضًا متوازيًا أكثر جرأة، في حلقة تعزيز متبادلة.

## القيود والاعتراضات

قبل التسليم المطلق بهذا الدليل، لا بد من توضيح عدة نقاط. أولًا، هذه الوثيقة موجهة تحديدًا لـ Fable 5 وMythos 5. فإن نُقلت استراتيجية الحذف أو الإعدادات الافتراضية لـ effort الموصى بها هنا مباشرة إلى نماذج بائعين آخرين أو إلى الجيل السابق، فقد تتراجع الجودة فعليًا. لذا يجب قراءة نطاق هذه التوصيات محصورًا داخل هذه العائلة من النماذج.

ثانيًا، نصيحة "احذف من البرومبت" قابلة لسوء الاستخدام بسهولة. فثمة تعليمات يجب أن تبقى بصرف النظر عن أداء النموذج، كقيود السلامة واللوائح النطاقية وسياسات المؤسسة. فالحذف ليس تنظيفًا عشوائيًا، بل يجب أن يكون تدقيقًا يميّز بين البند الذي كان يسدّ عيبًا في نموذج جيل سابق، والقيد الذي يمثل جوهر المهمة نفسها. والدليل نفسه يوصي بإدراج تعليمات التحقق صراحةً، مما يعني أن رسالته أقرب إلى "اكتب أقل، لكن أبقِ بوضوح على ما يجب أن يبقى".

ثالثًا، الرقم القائل بأن تقارير التقدم الوهمية كادت أن تختفي تمامًا هو نتيجة اختبار داخلي أجرته Anthropic نفسها، وليست قيمة أُعيد التحقق منها بشكل مستقل خارج Anthropic. نحن نتفق مع اتجاه فعالية تعليمات التحقق، لكن على كل مؤسسة أن تقيس معدل الفشل الفعلي في عبء عملها الخاص قبل أن تحدد مستوى الثقة المناسب. وأخيرًا، توصية جعل effort افتراضيًا عند high ترفع التكلفة وزمن الاستجابة معًا، لذا يجب على الفرق ذات الميزانية المحدودة أن تخفض بجرأة المهام النمطية إلى medium وlow لإيجاد توازنها الخاص في التوزيع.

قيمة هذا الدليل لا تكمن في عبارة سحرية جديدة، بل في تحوّل في الموقف تجاه التعامل مع نموذج أقوى: امنحه هامشًا للحكم بدلًا من إضافة مزيد من الضبط، ثم تحقق من ذلك الحكم بالأدلة، ووازِه عبر التفويض. ومن منظور من يُشغّل فعليًا عملاء مستقلين طويلي الأمد، هذا ليس شعارًا رائجًا، بل إعادة ترتيب لقواعد التشغيل ذاتها.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/anthropic-fable5-prompting-guide/nlm-infographic-2.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## المصادر

- Anthropic, "Prompting Claude Fable 5", Claude Platform Docs: [https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5](https://platform.claude.com/docs/en/build-with-claude/prompt-engineering/prompting-claude-fable-5)
</content>
