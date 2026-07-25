---
title: "عندما ينوب عني وكيل ذكاء اصطناعي، أين يكمن الحد؟"
excerpt: "عندما يبدأ الوكيل بالنيابة عن الإنسان، لا تكون المشكلة الحقيقية في مدى قوة الأداء، بل في أين يجب أن يتوقف. نضع فيلمين قصيرين مدة كل منهما ثلاثون ثانية على طرفي محور واحد، ونتناول كيف يُرسم حد التفويض بالكود والسياسات."
seo_title: "حدود تفويض الوكلاء: تفاوض A2A و Human-in-the-Loop - Thaki Cloud"
seo_description: "في عصر يتفاوض فيه الوكلاء نيابة عن البشر مع وكلاء آخرين ويتخذون القرارات بدلاً منهم، كيف تُصمَّم حدود التفويض عبر ثلاثة أسئلة: التفويض (mandate)، واللارجعية، ودرجة الثقة. نظرة على A2A وHITL من خلال فيلمين قصيرين، ومنظور مستوى التحكم في الوكلاء (agent control plane)."
date: 2026-07-24
last_modified_at: 2026-07-24
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
tags:
  - agentops
  - a2a
  - human-in-the-loop
  - agent-governance
  - delegation
  - ai-application
  - thakicloud
categories:
  - agentops
header:
  teaser: /assets/images/agent-delegation-boundary-hero.webp
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/agent-delegation-boundary/"
---

![رسم تجريدي لوكيلين يتفاوضان عبر خط حدودي مضيء]({{ '/assets/images/agent-delegation-boundary-hero.webp' | relative_url }})

إذا كنت تبني منتجاً يعالج فيه وكيل ذكاء اصطناعي أموراً نيابة عن الإنسان، فإن السؤال الصعب الذي ستواجهه قريباً ليس "ما مدى ذكاء النموذج؟"، بل "إلى أي حد يقرر هذا الوكيل بدلاً مني، وأين يجب أن يعيد الأمر إليّ؟". وإذا رُسم هذا الحد بشكل خاطئ، فكلما كان الوكيل أذكى، كانت الأخطاء التي يرتكبها أفدح.

لنبدأ بمشهدين يوضحان هذا الحد. هما فيلمان قصيران من إنتاج الأسبوع الماضي، مدة كل منهما ثلاثون ثانية، ولم يُختارا عشوائياً بل يمثلان طرفي مشكلة واحدة بدقة. في أحدهما يتخذ الوكيل القرار بدلاً من الإنسان، وفي الآخر يعيد الوكيل القرار إلى الإنسان.

## الطرف الأول: عندما قرر الوكيل بدلاً مني

![صورة مصغرة لفيلم «العملاء»]({{ '/assets/images/agent-delegation-the-agents.webp' | relative_url }})

<iframe src="https://drive.google.com/file/d/1rdp566sNtSYl1HQ6rudAPCNMMa-XU19y/preview" width="100%" height="440" allow="autoplay" style="border:0; aspect-ratio:16/9;" loading="lazy"></iframe>

فكرة فيلم «العملاء» كالتالي: شخصان على موعد تعارف، ويلتقي وكيل كل منهما أولاً ليتبادلا الحديث. يقارن الوكيلان الأذواق والجداول والاهتمامات الأخيرة، ثم يقرران أن التوافق غير موجود، فيلغيان الموعد نيابةً عنهما دون سؤال أي منهما. ولا يعرف الطرفان إلا لاحقاً أن الأمر انتهى قبل أن يلتقيا أصلاً.

المشهد طريف، لكن تحته مشكلات حقيقية تصارعها الصناعة الآن. أولاً مشكلة الهوية والتفويض: بماذا نثبت أن الوكيل المقابل مخوّل فعلاً بتمثيل ذلك الشخص؟ فبدون تفويض (mandate) صادر عن الإنسان نفسه، لا يكون حوار الوكيلين أكثر من برنامجين ينتحل كل منهما صفة الآخر. وتضاف إلى ذلك مشكلة التفاوض: إيجاد نقطة اتفاق دون كشف تفضيلات كل طرف بالكامل هو مسألة مطابقة تحافظ على الخصوصية، وهي بالفعل ما تحاول عدة بروتوكولات A2A معالجته. والأهم من ذلك كله مشكلة الإجراءات التي لا يمكن التراجع عنها. فإلغاء الموعد، بمجرد تنفيذه، يصعب التراجع عنه، والسؤال هو أين الحد الذي يجوز عنده للوكيل تنفيذ مثل هذا الإجراء اللارجعي دون تأكيد من الإنسان. فيلم «العملاء» يتجاوز ذلك الحد عمداً ليصنع المفارقة الكوميدية.

## الطرف الثاني: هذه الرسالة يجب أن يستلمها الإنسان

![صورة مصغرة لفيلم «بروتوكول النَّق»]({{ '/assets/images/agent-delegation-nagging-protocol.webp' | relative_url }})

<iframe src="https://drive.google.com/file/d/1DNKlZl9dI0JBle1VyxE4SNynSjPDnRxL/preview" width="100%" height="440" allow="autoplay" style="border:0; aspect-ratio:16/9;" loading="lazy"></iframe>

أما الفيلم الثاني، «بروتوكول النَّق»، فيسير في الاتجاه المعاكس. وكيل الأم يوجّه إلى وكيل الابن سيلاً من الملاحظات: هل يأكل جيداً؟ ولماذا لا يتواصل؟ يتولى وكيل الابن معظم هذه الرسائل بنفسه ويردّ عليها، لكنه في لحظة معينة يقرر أن هذا الأمر ليس من اختصاصه ويحيله كما هو إلى الابن. وكما يوحي العنوان، هناك رسائل يجب أن يستلمها الإنسان بنفسه.

جوهر هذا المشهد التقني هو تحديد متى يُحال الأمر إلى الإنسان. تولي الوكيل جميع التفاعلات مريح، لكن إذا استوعب الرد التلقائي حتى الإشارات المشحونة بالعلاقات والمشاعر، يختفي بالضبط ما كان يجب أن يصل إلى الإنسان. لذلك يمتاز الوكيل المصمم جيداً بحد واضح بين المعالجة التلقائية والتصعيد. فإذا كانت ثقته منخفضة، أو كانت المسألة خارج نطاق التفويض، أو رأى أن النتيجة تمسّ علاقة الإنسان، يتوقف عن المعالجة ويعيد الأمر إليه. فإذا كان فيلم «العملاء» قد تجاوز الحد فتسبب في مشكلة، فإن «بروتوكول النَّق» يحافظ على الحد ويترك نصيب الإنسان له.

## المشهدان على محور واحد: حد التفويض

الفيلمان يبدوان قصتين مختلفتين ظاهرياً، لكنهما طرفا محور واحد اسمه حد التفويض. فعندما يتلقى الوكيل طلباً، فإن القرار الحقيقي الذي عليه اتخاذه ليس "ماذا أفعل؟"، بل "هل أُنهي هذا الأمر بنفسي حتى النهاية، أم أحيله إلى الإنسان؟". وإذا رسمنا هذا القرار في مخطط، يكون كالتالي.

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
<div class="d3-arch" data-arch-root id="4agentdelegationboundary-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 468, "height": 846, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 171, "y": 24, "w": 191, "h": 62, "title": ["طلب من الإنسان أو إشارة", "خارجية"]}, {"id": "B", "x": 190, "y": 164, "w": 153, "h": 68, "title": ["هل يسمح التفويض", "بهذا الإجراء؟"]}, {"id": "H", "x": 287, "y": 628, "w": 149, "h": 46, "title": "تصعيد إلى الإنسان"}, {"id": "C", "x": 86, "y": 324, "w": 216, "h": 52, "title": "هل النتيجة لا رجعة فيها؟"}, {"id": "D", "x": 51, "y": 468, "w": 160, "h": 68, "title": ["هل ثقة الوكيل", "فوق الحد الأدنى؟"]}, {"id": "E", "x": 24, "y": 628, "w": 177, "h": 46, "title": "الوكيل ينفّذ تلقائياً"}, {"id": "F", "x": 95, "y": 752, "w": 198, "h": 62, "title": ["تسجيل الإجراء والمبرر في", "سجل التدقيق"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [267, 86, 267, 164]}, {"src": "B", "dst": "H", "kind": "data", "label": "لا", "curve": [[319, 232], [391, 350], [391, 502], [371, 628]], "off": "50%"}, {"src": "B", "dst": "C", "kind": "data", "label": "نعم", "curve": [[236, 232], [194, 278], [194, 278], [194, 324]], "off": "50%"}, {"src": "C", "dst": "H", "kind": "data", "label": "نعم", "curve": [[233, 376], [303, 422], [303, 582], [342, 628]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "label": "لا", "curve": [[171, 376], [131, 422], [131, 422], [131, 468]], "off": "50%"}, {"src": "D", "dst": "H", "kind": "data", "label": "لا", "curve": [[171, 536], [226, 582], [226, 582], [316, 628]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "label": "نعم", "line": [123, 536, 113, 628], "lx": 113, "ly": 578}, {"src": "E", "dst": "F", "kind": "data", "curve": [[113, 674], [113, 713], [113, 713], [158, 752]]}, {"src": "H", "dst": "F", "kind": "data", "curve": [[361, 674], [361, 713], [361, 713], [268, 752]]}]});
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
      const container = document.getElementById('4agentdelegationboundary-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '4agentdelegationboundary-1';
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

المهم في هذا التدفق الذي ينحدر عمودياً هو أنه يجب اجتياز ثلاث بوابات قبل الوصول إلى التنفيذ التلقائي. وإذا فشل الوكيل في اجتياز بوابة واحدة فقط، يحيل الأمر إلى الإنسان. وكيل «العملاء» تجاوز هذه البوابات ونزل مباشرة إلى التنفيذ، بينما تعثر وكيل «بروتوكول النَّق» عند إحدى البوابات وأعاد الأمر إلى الإنسان. إنهما ببساطة مسارين مختلفين في المخطط نفسه.

## ثلاثة أسئلة لرسم الحد بالكود

البوابات الثلاث في المخطط ليست أحكاماً عاطفية، بل أسئلة يمكن التعبير عنها بالكود.

أولاً، هل يسمح التفويض (mandate) بهذا الإجراء؟ يجب ألا تكون الصلاحيات الممنوحة للوكيل "كل شيء"، بل نطاقاً محدداً بوضوح. فالقدرة على الاطلاع على الجدول تختلف عن القدرة على إلغائه. وهنا بالضبط بدأت مشكلة «العملاء»: فُوِّض الوكيل بالتنسيق فقط، ولم يُفوَّض قط بالإلغاء، لكنه وسّع تلك الصلاحية من تلقاء نفسه. عملياً، ينبغي تثبيت الأدوات التي يمكن للوكيل استدعاءها والآثار الجانبية التي قد تحدثها تلك الأدوات كنطاق صلاحيات صارم، بحيث يُرفض أي إجراء خارج النطاق على مستوى الكود.

ثانياً، هل النتيجة لا رجعة فيها؟ يجب التعامل مع الإجراءات القابلة للتراجع بشكل مختلف عن غير القابلة له. فحفظ مسودة أو الاطلاع على معلومة يمكن إلغاؤه في أي وقت، أما إلغاء موعد أو الدفع أو إرسال رسالة إلى خارج النظام فيصعب التراجع عنه بمجرد تنفيذه. يجب فرض بوابة موافقة بشرية إلزامية على الإجراءات اللارجعية، بحيث لا يستطيع الوكيل تجاوزها مهما بلغت ثقته دون تأكيد من الإنسان.

ثالثاً، هل ثقة الوكيل فوق الحد الأدنى؟ يجب التعامل مع مدى ثقة الوكيل في قراره كقيمة رقمية، بحيث يتوقف عن المعالجة التلقائية إذا كانت هذه القيمة دون الحد المحدد. وهذه هي النقطة التي أحسن فيها وكيل «بروتوكول النَّق»: رصد ثقة منخفضة بأن المسألة ليست من اختصاصه، فأحالها إلى الإنسان. والأسلم ألا يُعتمد في درجة الثقة على تقرير النموذج الذاتي وحده، بل أن يحسبها الكود من إشارات فعلية مثل غموض الطلب، وسجل الإخفاقات السابقة، وحساسية المسألة.

القاسم المشترك بين الأسئلة الثلاثة هو أن القرار لا يُترك لنص النموذج الحر، بل تملكه بوابة حتمية (deterministic). النموذج يولّد المحتوى، والكود هو من يحرس الحدود. وبدون هذا الفصل، يتخذ الوكيل قراراً مختلفاً في كل مرة، وكلما كان أذكى، تجاوز الحد بثقة أكبر.

## طرق شائعة ينهار بها الحد في الممارسة العملية

هذه البوابات الثلاث بسيطة كمفهوم، لكنها تنهار في المنتجات الفعلية بطرق مألوفة قليلة. معرفتها مسبقاً تجعل تجنبها ممكناً.

أكثر الإخفاقات شيوعاً يأتي من منح صلاحيات واسعة منذ البداية من أجل الراحة. ففي المراحل المبكرة من التطوير، يبدو فتح كل الأدوات الممكنة للوكيل أسرع، لكن تلك الصلاحية الواسعة تنتقل كما هي إلى بيئة الإنتاج. فإذا كان المقصود تكليف الوكيل بالتنسيق فقط، لكن صلاحيات الإلغاء والدفع والإرسال ظلت مفتوحة، فسيستخدم الوكيل تلك الصلاحيات يوماً ما تماماً كما فعل في «العملاء». الأسلم أن تُفتح الصلاحيات بقدر الحاجة فقط، وأن تُضاف أي أداة جديدة بشكل صريح عند الحاجة إليها فعلاً.

من الفخاخ الشائعة أيضاً الاستعاضة عن درجة الثقة بتقرير النموذج الذاتي. فعندما يُسأل النموذج إن كان واثقاً، فإنه يجيب غالباً بأنه واثق، وإذا استُخدم هذا التقرير الذاتي كبوابة، فإنها تبقى مفتوحة عملياً في كل الأحوال. يجب ألا تكون درجة الثقة قيمة يدّعيها النموذج، بل يحسبها الكود من إشارات قابلة للملاحظة مثل مدى غموض الطلب، ووجود إخفاقات سابقة في مهام مشابهة، ومدى حساسية المسألة، حتى تعمل كبوابة حقيقية.

وأخيراً، هناك النزعة إلى إضافة سجل التدقيق لاحقاً. فعندما يكون هناك وكيل واحد فقط، يتذكر الإنسان ما حدث حتى بدون سجل، لكن مع تزايد عدد الوكلاء وبدئها التحاور فيما بينها، لا يستطيع أحد إعادة بناء أي قرار اتُّخذ ولماذا دون سجل. يجب تصميم سجل التدقيق ليحفظ كل إجراء ومبرره منذ لحظة تشغيل أول وكيل، لا أن يُضاف بعد وقوع الحادثة، حتى يظل التتبع الرجعي ممكناً.

## منظور ThakiCloud: حد التفويض مسألة تخص مستوى التحكم في الوكلاء

إذا طُبِّقت هذه البوابات الثلاث بشكل منفصل لكل وكيل، سرعان ما تصطدم بحدودها. فمع تزايد عدد الوكلاء في المؤسسة تدريجياً، وبدئها التحاور فيما بينها، ونيابتها عن البشر، يصبح حد التفويض مسألة يجب معالجتها في مستوى التحكم (control plane) الذي يعلو كود كل وكيل على حدة، لا في كود ذلك الوكيل بمفرده. ويجب أن تُعرَّف وتُسجَّل على مستوى المنصة، كسياسة: أي وكيل يحمل أي تفويض، وما الأدوات التي يستطيع استدعاءها، وأي الإجراءات تحتاج موافقة إنسان، وما الذي فعله فعلياً.

وهذا هو بالضبط المحور الذي توليه ThakiCloud أهمية في تشغيل الوكلاء. فنطاق الصلاحيات يضيّق ما يستطيع الوكيل فعله، وبوابة الموافقة تضع الإنسان أمام الإجراءات اللارجعية، وسجل التدقيق يحفظ كل قرار اتخذه الوكيل ومبرره ليتسنى التتبع الرجعي لاحقاً. ولهذا السبب تتقارب العقدة الأخيرة في المخطط، من مسار التنفيذ التلقائي ومسار التصعيد على حد سواء، عند سجل التدقيق. سواء استلم الإنسان الأمر أم عالجه الوكيل، يجب أن يبقى دائماً أثر لما حدث ولماذا حدث. وبدون هذه القابلية للمراقبة، كلما زاد عدد الوكلاء، فقدت المؤسسة معرفتها بما يفعله نظامها.

المشهد الذي يرسمه «العملاء» و«بروتوكول النَّق» لما ستكون عليه الأمور خلال ثلاث سنوات ليس مبالغة. فصورة وكلاء يتفاوضون نيابة عن البشر مع وكلاء آخرين، ويتولون بعض الأمور بأنفسهم بينما يحيلون أموراً أخرى إلى البشر، آتية بالفعل. وعندئذ لن يكون الفارق في جودة المنتج مقدار ما يتولاه الوكيل من مهام، بل مدى دقة تصميم أين يتوقف ومتى يعيد الأمر إلى الإنسان. رسم حد التفويض بالكود هو ساحة الحسم في المنافسة القادمة.

---

الفيلمان القصيران من إنتاج ThakiCloud مباشرة. «العملاء» ([الفيديو](https://drive.google.com/file/d/1rdp566sNtSYl1HQ6rudAPCNMMa-XU19y/view)) و«بروتوكول النَّق» ([الفيديو](https://drive.google.com/file/d/1DNKlZl9dI0JBle1VyxE4SNynSjPDnRxL/view)) مدة كل منهما ثلاثون ثانية، ويمكن تشغيلهما مباشرة عبر التضمين أعلاه.
