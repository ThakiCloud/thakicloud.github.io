---
title: "التعلّم المعزز للوكلاء لا ينتظر المجموعة: التعلّم من rollout واحد فقط"
seo_title: "تحليل SAO: التحسين غير المتزامن أحادي الـ rollout للتعلّم المعزز للوكلاء - Thaki Cloud"
seo_description: "تحليل ورقة SAO (Single-Rollout Asynchronous Optimization) التي طبّقتها جامعة تسينغهوا وZ AI فعلياً في تدريب GLM-5.2. لماذا لا يتناسب أخذ العينات الجماعي في GRPO مع التعلّم غير المتزامن للوكلاء، وكيف يحلّ الـ rollout الواحد مع التقليم ثنائي الاتجاه على مستوى الرمز هذه المشكلة، وما الذي يعنيه ذلك لبنية تدريب GPU لدى ThakiCloud ومنصة الوكلاء Paxis."
excerpt: "عند تدريب مهام الوكلاء الطويلة عبر التعلّم المعزز، يُبقي أخذ العينات الجماعي في GRPO وحدات GPU عاطلة في انتظار أبطأ rollout. استخدمت جامعة تسينغهوا وZ AI طريقة SAO فعلياً في تدريب GLM-5.2، إذ تتخلّى تماماً عن المجموعة وتتعلّم من rollout واحد، وتحافظ على الاستقرار عبر تقليم الرموز ثنائي الاتجاه بدلاً من ذلك."
date: 2026-07-11
tags:
  - reinforcement-learning
  - agentic-rl
  - grpo
  - async-rl
  - llm-training
  - post-training
categories:
  - research
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/sao-single-rollout-async-agentic-rl/"
---

لم يعد الحديث عن صقل الوكلاء عبر التعلّم المعزز مصطلحاً مختبرياً بحتاً. فالنماذج التي تُتقن مهاماً مثل إصلاح قواعد الأكواد على مدى عشرات الجولات كما في SWE-Bench، أو حل البراهين الرياضية عبر خطوات متعددة، لا تُبنى في الغالب بالتدريب المسبق وحده. جوهر الأمر يكمن في مرحلة ما بعد التدريب (post-training)، حيث يُشغَّل الوكيل فعلياً باستخدام الأدوات والتفاعل مع البيئة عبر rollout يُمنح على أساسه المكافأة. لكن كلما طال هذا الـ rollout، بدأ أسلوب التدريب الذي كان يُستخدم كمعيار قياسي حتى الآن في الانهيار.

تتناول الورقة البحثية "Single-Rollout Asynchronous Optimization for Agentic Reinforcement Learning" (arXiv 2607.07508)، التي نشرها باحثون من جامعة تسينغهوا وشركة Z AI في 8 يوليو 2026، هذه النقطة مباشرة. والخلاصة أن الباحثين تخلّوا عن "أخذ العينات الجماعي" (group sampling)، وهو جوهر GRPO الشائع الاستخدام. ولم يقتصر الأمر على تجربة هذا الأسلوب في تجارب الورقة فحسب، بل طبّقوه فعلياً في خط أنابيب حقيقي لتدريب النموذج المفتوح GLM-5.2 البالغ حجمه 750B.

## نظرة عامة

سبب أهمية هذه الورقة الآن هو أن عنق الزجاجة في تكلفة التدريب انتقل من الخوارزمية إلى معدل استغلال البنية التحتية. فدوال الخسارة التي تجعل النموذج أكثر ذكاءً موجودة بالفعل بأشكال متعددة. المشكلة الحقيقية هي أنه حتى مع تشغيل مئات وحدات GPU معاً، يُنفَق معظم الوقت في "الانتظار" لإنتاج خطوة تدريب واحدة فقط.

تُشغّل ThakiCloud أيضاً خمس تقنيات لما بعد التدريب، هي SFT وCPT وDPO وGRPO وGKD، ضمن نظام تدريب نماذج اللغة الكبيرة المبني على kubeflow. لذلك فإن الثمن الذي يدفعه أخذ العينات الجماعي في GRPO عند التعامل مع rollouts طويلة، والمخاطر الجديدة التي قد يجلبها أي بديل يُزيل هذا الثمن، ليست قضية بعيدة عنا. يستعرض هذا المقال ما غيّرته SAO، وما تعنيه هذه التغييرات لمؤسسة مثلنا تسعى لتدريب وكلاء على عناقيد GPU متعددة المستأجرين (multi-tenant).

![صورة تجريدية تقابل بين تدفق rollouts يصل واحداً تلو الآخر بشكل غير متزامن وrollouts تنتظر مجمّعة في مجموعة]({{ '/assets/images/sao-single-rollout-async-agentic-rl-hero.webp' | relative_url }})
*تصوير تخيلي يقابل بين rollout واحد يصل تباعاً بشكل مستمر، وrollouts تتجمّد في قائمة الانتظار إلى أن تكتمل المجموعة بأكملها.*

## ما هي هذه التقنية؟

يجمع اسم SAO، كما هو، بين مفهومين: "rollout واحد" (single-rollout) و"التحسين غير المتزامن" (asynchronous optimization).

كانت خطوط أنابيب التعلّم المعزز التقليدية متزامنة (synchronous). تُحدَّد دفعة من الطلبات، ويُولَّد لكل طلب عدد من الـ rollouts، وعندما تكتمل جميعها تُحسَب المكافأة ويُنفَّذ تحديث واحد للسياسة. نجح هذا الأسلوب جيداً في المهام التي تُنتج إجابات قصيرة، لأن أطوال الـ rollouts كانت متقاربة.

لكن المشكلة تظهر في مهام الوكلاء. فمهمة برمجية واحدة قد تنتهي خلال 3 جولات فقط، بينما تستمر مهمة مجاورة في استدعاء الأدوات عبر 40 جولة. وفي خط الأنابيب المتزامن، تبقى بقية وحدات GPU عاطلة حتى ينتهي أبطأ rollout في الدفعة. ظهر التعلّم المعزز غير المتزامن أصلاً لإزالة هذا الهدر: يُحدَّث النموذج فور اكتمال كل rollout، بينما يستمر المولّد (generator) دون توقف في إنتاج الـ rollout التالي.

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
<div class="d3-arch" data-arch-root id="glerolloutasyncagenticrl-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 939, "height": 662, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 360, "h": 606, "label": "GRPO المتزامن", "lx": 36, "ly": 42}, {"x": 579, "y": 24, "w": 329, "h": 606, "label": "SAO غير المتزامن", "lx": 591, "ly": 42}], "nodes": [{"id": "A1", "x": 118, "y": 71, "w": 135, "h": 46, "title": "دفعة من الطلبات"}, {"id": "A2", "x": 90, "y": 217, "w": 191, "h": 62, "title": ["توليد G من الـ rollouts", "لكل طلب كمجموعة"]}, {"id": "A3", "x": 176, "y": 365, "w": 163, "h": 62, "title": ["الانتظار حتى اكتمال", "أبطأ rollout"]}, {"id": "A4", "x": 97, "y": 513, "w": 177, "h": 78, "title": ["حساب المكافأة النسبية", "للمجموعة", "تحديث واحد للسياسة"]}, {"id": "B1", "x": 635, "y": 63, "w": 156, "h": 62, "title": ["توليد rollout واحد", "لكل طلب"]}, {"id": "B2", "x": 718, "y": 217, "w": 120, "h": 62, "title": ["وصول فوري", "عند الاكتمال"]}, {"id": "B3", "x": 686, "y": 357, "w": 184, "h": 78, "title": ["كبح تحديثات off-policy", "عبر تقليم الرموز ثنائي", "الاتجاه"]}, {"id": "B4", "x": 632, "y": 529, "w": 163, "h": 46, "title": "تحديث مستمر للسياسة"}, {"id": "SYNC", "x": 421, "y": 71, "w": 120, "h": 46, "title": "SYNC"}, {"id": "SAO", "x": 421, "y": 225, "w": 120, "h": 46, "title": "SAO"}], "edges": [{"src": "A1", "dst": "A2", "kind": "data", "line": [186, 117, 186, 217]}, {"src": "A2", "dst": "A3", "kind": "data", "curve": [[218, 279], [258, 318], [258, 318], [258, 365]]}, {"src": "A3", "dst": "A4", "kind": "data", "curve": [[258, 427], [258, 474], [258, 474], [222, 513]]}, {"src": "A4", "dst": "A2", "kind": "event", "label": "توقف GPU", "curve": [[149, 513], [113, 474], [113, 318], [154, 279]], "off": "50%"}, {"src": "B1", "dst": "B2", "kind": "data", "curve": [[739, 125], [778, 171], [778, 171], [778, 217]]}, {"src": "B2", "dst": "B3", "kind": "data", "line": [778, 279, 778, 357]}, {"src": "B3", "dst": "B4", "kind": "data", "curve": [[778, 435], [778, 474], [778, 474], [732, 529]]}, {"src": "B4", "dst": "B1", "kind": "data", "curve": [[694, 529], [648, 396], [648, 248], [687, 125]]}, {"src": "SYNC", "dst": "SAO", "kind": "data", "label": "إزالة حاجز المجموعة", "line": [481, 117, 481, 225], "lx": 481, "ly": 167}]});
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
      const container = document.getElementById('glerolloutasyncagenticrl-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'glerolloutasyncagenticrl-1';
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

هنا ينشأ التعارض الجوهري. فاسم GRPO (Group Relative Policy Optimization) يحمل معنى "النسبية الجماعية" منذ البداية. تُجمَع عدة rollouts لطلب واحد في مجموعة واحدة، وتُقارَن داخل هذه المجموعة الـ rollouts الأفضل نسبياً بالأسوأ لحساب الأفضلية (advantage). وميزة GRPO، التي هي في الوقت نفسه قيدها، أنها تُنتج إشارة التدريب من المقارنة داخل المجموعة فقط دون الحاجة إلى دالة قيمة (critic) منفصلة. فإن لم تكتمل المجموعة، يستحيل حساب الأفضلية. وهكذا يتعارض جوهرياً البناء غير المتزامن الذي يتعلّم فور وصول كل rollout مع GRPO الذي يفرض الانتظار حتى تكتمل المجموعة.

## لماذا لا يتناسب GRPO مع التعلّم غير المتزامن؟

لنتأمل هذا التعارض بمزيد من التفصيل. فللحفاظ على المجموعة داخل خط أنابيب غير متزامن، لا مفر من أحد خيارين سيئين.

الأول هو الانتظار على مستوى المجموعة، وحينها تتلاشى ميزة اللاتزامن، وينتهي الأمر بالعودة فعلياً إلى النمط المتزامن الذي ينتظر أبطأ rollout.

والثاني هو توليد rollouts المجموعة الواحدة بسياسات (policies) مختلفة زمنياً. فإذا أنتجت سياسة قديمة بعض rollouts المجموعة، وأنتجت سياسة مُحدَّثة بعد بضع خطوات rollouts أخرى ضمن المجموعة نفسها، فإن تجميعها ومقارنتها نسبياً كمجموعة واحدة يصبح ملوّثاً إحصائياً من الأساس. فحين تتفاوت درجة off-policy من rollout إلى آخر، لكنها تُعامَل كأنها baseline واحد متجانس، يصبح التدريب غير مستقر.

إجابة SAO بسيطة: إلغاء المجموعة تماماً. يُولَّد rollout واحد فقط لكل طلب، وحالما يصل يُستخدَم مباشرة في التدريب. وبزوال حاجز المجموعة، لا يضطر المولّد إلى الانتظار إطلاقاً، فيتقلّص وقت خمول GPU بشكل كبير.

## ركيزتا SAO: rollout واحد وتقليم الرموز ثنائي الاتجاه

لكن إلغاء المجموعة يعني فقدان ما كانت GRPO تحصل عليه مجاناً. فالمقارنة داخل المجموعة كانت تلعب بحد ذاتها دور baseline يُقلّل التباين. وحين يكون هناك rollout واحد فقط، يختفي معيار المقارنة القائم على "هل تفوّق هذا الـ rollout على متوسط المجموعة؟". فضلاً عن ذلك، في البنية غير المتزامنة تنشأ فجوة زمنية بين السياسة التي أنتجت الـ rollout والسياسة التي يُراد تحديثها الآن. وهذه الفجوة، أي مشكلة off-policy، هي الخطر الثاني الذي يهدد استقرار التدريب.

تتصدى SAO لمشكلة الاستقرار هذه عبر "تقليم صارم ثنائي الاتجاه على مستوى الرمز" (strict double-side token-level clipping). فالتقليم (clipping) الذي كانت تستخدمه عائلة PPO أصلاً هو آلية تقصّ التدرّج (gradient) عندما تخرج نسبة الأهمية (importance ratio) عن نطاق محدد. وتُطبّق SAO هذا التقليم على مستوى كل رمز (token) على حدة، وبصرامة في الاتجاهين الأعلى والأسفل معاً. فعند الرموز التي تباعدت فيها rollout السياسة القديمة كثيراً عن السياسة الحالية، يُكبَح التحديث بقوة، مما يمنع الإشارات ذات الفجوة الزمنية الكبيرة من إفساد التدريب.

ونتيجة هذا المزيج، تُفيد الورقة بأن SAO واصلت التدريب باستقرار على مدى 1,000 خطوة. وإذا أخذنا بعين الاعتبار أن حالات التباعد أو الانهيار شائعة في التعلّم المعزز غير المتزامن بعد تجاوز بضع مئات من الخطوات، فإن استقرار التدريب لـ 1,000 خطوة يُعدّ دليلاً داعماً للمزاعم الأساسية لهذه الطريقة.

## النتائج الفعلية والتحقق

قارنت الورقة SAO بـ GRPO ومتغيراتها، وأفادت بتفوّقها باستمرار في معايير قياس الترميز والاستدلال الخاصة بالوكلاء. والمعايير المذكورة هي SWE-Bench Verified (حل مشكلات GitHub الحقيقية)، وBeyondAIME (رياضيات عالية الصعوبة)، وIMOAnswerBench (رياضيات بمستوى الأولمبياد). وتشترك المعايير الثلاثة في كونها مهام متعددة الخطوات وطويلة النَفَس، وليست إجابات قصيرة مباشرة، وهو بالضبط المجال الذي تستهدفه SAO.

أما التحقق الأكثر إقناعاً فليس في جداول المعايير، بل في واقعة النشر ذاتها. فقد استُخدِمت SAO في خط أنابيب فعلي للتعلّم المعزز للوكلاء لتدريب النموذج المفتوح GLM-5.2 (نموذج MoE بحجم إجمالي 750B وحجم فعّال 40B من المعاملات النشطة، 750B-A40B). وكون طريقة بحثية لم تبقَ حبيسة الورقة العلمية، بل استُخدِمت في تدريب إنتاجي لنموذج بحجم مئات المليارات، إشارة قوية على أن هذه الطريقة تصمد عند المقياس الحقيقي، لا في إعدادات تجريبية صغيرة فقط.

غير أن هذا المقال لا يقتبس الأرقام التفصيلية للمعايير. فإن تعذّر إعادة إنتاج الأرقام الدقيقة التي تحقّق منها النص الأصلي في هذا المكان، فالأمانة تقتضي نقل بنية الطريقة وأسماء المعايير المذكورة صراحة دون اختلاق أي رقم. ومن يحتاج إلى الدرجات الدقيقة، فليرجع إلى النص الأصلي أدناه مباشرة.

## دلالات التطبيق على منتجات ThakiCloud

لا يقتصر درس SAO على كونه ورقة خوارزمية واحدة، بل يمسّ مباشرة طريقة تشغيل عناقيد GPU.

**عدسة ai-platform (البنية التحتية لتدريب GPU).** تجدول منصة ai-platform التابعة لـ ThakiCloud تدريب GPU متعدد المستأجرين فوق Kubernetes وKueue. ونظام تدريب نماذج اللغة الكبيرة المبني على kubeflow يدعم بالفعل GRPO كأحد تقنيات ما بعد التدريب. والسؤال الذي تطرحه SAO واضح: كم يتراجع معدل استغلال GPU في مهام تدريبنا بسبب التفاوت في أطوال الـ rollouts؟ ففي المهام المتفاوتة الطول كـ rollouts الوكلاء، يتحوّل انتظار المجموعة المتزامن إلى تكلفة مباشرة. وفصل توليد الـ rollouts غير المتزامن عن التدريب يتيح استخلاص خطوات تدريب فعّالة أكثر من العدد نفسه من وحدات GPU، وهو ما يشكّل رافعة مباشرة لخفض تكلفة التدريب لكل مستأجر في بيئة متعددة المستأجرين. كما أن التحقق مما إذا كانت جدولة gang scheduling وإدارة الطوابير في Kueue تفرض نمط "الانتظار حتى تكتمل المجموعة" يُعدّ نقطة تحسين عملية أخرى.

**عدسة Paxis (نتاج تدريب الوكلاء).** Paxis، وهي منصة Agent-Native Cloud التابعة لـ ThakiCloud، مستوى تحكّم يُشغّل المهارات (skills) في صناديق رملية معزولة (sandbox) ويمرّر كل سلوك عبر بوابات سياسات وسجلات تدقيق. والوكيل الذي تسعى SAO لتدريبه جيداً، أي وكيل يستدعي الأدوات عبر جولات متعددة ويُصلح قواعد الأكواد، هو بالضبط عبء العمل الذي تُشغّله Paxis. بل إن آثار الوكلاء (agent traces) الفعلية التي تُولّدها Paxis داخل الصناديق الرملية المعزولة يمكن أن تكون بحدّ ذاتها مصدر rollouts للتعلّم المعزز غير المتزامن على غرار SAO. وبذلك تكتمل حلقة: تُنتج ai-platform الـ rollouts وتدرّب عليها بتكلفة منخفضة، وتُشغّل Paxis الوكيل الناتج بأمان، لتُولّد بدورها بيانات تدريب جديدة. إنها بنية تقوم فيها بنية التدريب منخفضة التكلفة (ai-platform) بدعم جدوى الوكلاء الاقتصادية (Paxis).

## القيود والاعتراضات

قبل تبنّي هذه الطريقة دون تمحيص، ينبغي التوقف عند بضع نقاط.

أولاً، يتخلّى الـ rollout الواحد عن تقليل التباين الذي كانت توفّره المجموعة. وتُعوّض SAO عن ذلك بالتقليم، لكن التقليم بطبيعته آلية تقصّ إشارة التدريب. فالتقليم الصارم أكثر مما ينبغي قد يُلقي حتى بالتدرّجات الصالحة، مما يُبطئ التدريب. ونقطة التوازن بين "الاستقرار" و"سرعة التعلّم" قابلة للتغيّر بشكل كبير تبعاً للمهمة والمقياس.

ثانياً، التحقق عبر تدريب نموذج بحجم 750B مثير للإعجاب، لكن نجاحه عند هذا المقياس لا يعني أنه الأمثل بالضرورة في إعدادات المؤسسات الصغيرة. فخط الأنابيب غير المتزامن يتطلّب تعقيداً إضافياً في البنية التحتية لفصل المولّد عن المدرّب. وبالنسبة للفرق التي تُجري ضبطاً دقيقاً قصيراً بعدد محدود من الـ rollouts، قد يكون GRPO المتزامن أبسط وكافياً.

ثالثاً، توجد مقاربات نشطة في الاتجاه المعاكس أيضاً. فقد ظهرت في الفترة نفسها دراسة تتناول العلاقة بين staleness ومعدل التعلّم في RLHF غير المتزامن عبر قوانين تحجيم (scaling laws) (arXiv 2607.01083)، كما ظهرت مقاربات تُثبّت التدريب غير المتزامن عبر محاذاة التدرّجات (gradient alignment). ولذلك فالأدق أن نعتبر مبدأ SAO القائم على "إلغاء المجموعة وكبح ذلك بالتقليم" واحداً من عدة إجابات قوية محتملة على مسألة مفتوحة هي التعلّم المعزز غير المتزامن للوكلاء، لا الإجابة الوحيدة الصحيحة.

ومع ذلك، فإن إسهام SAO واضح. فقد حدّدت المشكلة بدقة (عدم كفاءة أخذ العينات الجماعي عند طول الـ rollouts)، وتحقّقت من الحل (rollout واحد مع تقليم ثنائي الاتجاه) عبر تدريب إنتاجي فعلي بمقياس مئات المليارات من المعاملات. وأي مؤسسة يمثّل فيها معدل استغلال GPU تكلفة التدريب مباشرة، لديها سبب وجيه لحساب المبلغ الذي يُهدَر في خط أنابيبها بسبب "انتظار المجموعة".

## المصادر

- Zhenyu Hou, Yujiang Li, Jie Tang, Yuxiao Dong. "Single-Rollout Asynchronous Optimization for Agentic Reinforcement Learning." arXiv 2607.07508 (2026-07-08). <https://arxiv.org/abs/2607.07508>
- ذو صلة: "Staleness-Learning Rate Scaling Laws for Asynchronous RLHF." arXiv 2607.01083. <https://arxiv.org/abs/2607.01083>
