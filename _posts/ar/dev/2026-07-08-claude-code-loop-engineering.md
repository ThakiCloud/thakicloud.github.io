---
title: "توقّف عن كتابة الأوامر وابدأ بتصميم الحلقات: قراءة في دليل هندسة الحلقات الرسمي من Claude Code"
excerpt: "في السابع من يوليو 2026 نشرت Anthropic أول وثيقة رسمية عن هندسة الحلقات بعنوان 'Getting started with loops'. إنها تحوّل من أن يوجّه الإنسان كل خطوة بأمر، إلى تصميم نظام يوجّه الوكيل نيابةً عنك. تستعرض هذه المقالة الحلقات اليدوية، وحلقات /loop بفواصل زمنية، وروتينات /schedule، وشروط إتمام /goal، ثم تربطها بكيفية توصيل ThakiCloud لهذه الأنماط في خطوط أنابيب غير مراقَبة فعلية وبمنصّة تحكّم الوكلاء Paxis."
seo_title: "هندسة الحلقات في Claude Code - قراءة في دليل /goal /loop /schedule (2026) - Thaki Cloud"
seo_description: "مقدمة إلى وثيقة Anthropic الرسمية 'Getting started with loops' (2026-07-07). نغطّي الحلقات اليدوية، وحلقات /loop بفواصل زمنية، وروتينات /schedule، وشروط إتمام /goal وسقف الأدوار، وتصميم معايير نجاح قابلة للتحقّق، والتحقّق القائم على المهارات، وكيف وصّلت ThakiCloud هذه الأنماط في خطوط أنابيب غير مراقَبة فعلية عبر pge-loop وGoal Mode وlaunchd cron، ودلالات Paxis كسحابة أصلية للوكلاء."
date: 2026-07-08
last_modified_at: 2026-07-08
tags:
  - claude-code
  - loop-engineering
  - ai-agent
  - agentic-automation
  - developer-tools
  - orchestration
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/claude-code-loop-engineering/"
reading_time: true
categories:
  - dev
---

## لمن هذه المقالة

هذه المقالة موجَّهة للمطوّرين ومهندسي المنصّات الذين يريدون تشغيل وكيل الترميز لا كأداة لمرة واحدة بل كنظام أتمتة طويل الأمد. تتناول أسئلة عملية مثل: "ما الذي يجب أن أحدّده كي يكرّر الوكيل من تلقاء نفسه بدلًا من أن أكتب كل أمر؟" و"كيف أمنع الحلقات اللانهائية وانفلات التكلفة؟". نقرأ وثيقة الحلقات الرسمية من Anthropic ونضعها فوق خبرتنا التشغيلية في توصيل هذه الأنماط في خطوط أنابيب غير مراقَبة فعلية.

![حلقة من مقاطع متشابكة تشكّل حلقة تغذية راجعة لا نهائية مع أسهم متوهّجة وبوابة تحقّق في مركزها]({{ '/assets/images/claude-code-loop-engineering-hero.png' | relative_url }})

## نظرة عامة

حتى الآن كان استخدام وكيل الترميز محادثة. يكتب الشخص أمرًا، فيستجيب الوكيل مرة واحدة، ثم يتوقّف. ينتظر التعليمة التالية. هذا رائع للمهام القصيرة، لكنه لا يناسب تدفّق العمل المتكرّر والمحدّد النهاية مثل تطبيق مراجعات PR، وإصلاح CI، وفرز المشكلات، وترقية الاعتماديات، لأن على الإنسان أن يبقى ملتصقًا يوجّه في كل دور.

في السابع من يوليو 2026 نشرت Anthropic وثيقة رسمية بعنوان «Getting started with loops» وسمّت هذا التحوّل: هندسة الحلقات. الجملة الجوهرية في الوثيقة هي: توقّف عن كتابة كل أمر بنفسك، وابدأ بتصميم النظام الذي يوجّه الوكيل نيابةً عنك. تقرأ هذه المقالة أنواع الحلقات وشروط التوقّف التي تعرضها تلك الوثيقة، وتتابع حتى كيفية توصيلنا الفعلي لهذه الأنماط في خطوط أنابيب غير مراقَبة.

## ما هي هندسة الحلقات

هندسة الحلقات هي الخطوة التالية بعد هندسة الأوامر. إذا كانت هندسة الأوامر تتعلّق بصقل "تعليمة تنتزع استجابة جيدة واحدة"، فإن هندسة الحلقات تتعلّق بتصميم البنية المتكرّرة نفسها: رصد، حكم، تنفيذ، ثم رصد من جديد. ما يحدّد جودة الحلقة الجيدة ليس قدرة النموذج فحسب بل جودة التغذية الراجعة التي تتلقّاها الحلقة في كل تمريرة.

أوثق تغذية راجعة تأتي من تحقّق حتمي يعيد النجاح أو الفشل بموضوعية، مثل الاختبارات ومدقّقات الأنواع والمدقّقات اللغوية. تقرير النموذج الذاتي "يبدو أن هذا اكتمل" لا يمكن أن يكون شرط إنهاء الحلقة. متى يجب أن تتوقّف الحلقة يقرّره حكم أداة، لا زعم النموذج.

## أنواع الحلقات الثلاثة و/goal

تقسّم الوثيقة الرسمية الحلقات إلى ثلاثة أنواع. أيها تستخدم ينقسم على "هل يراقب إنسان في الوقت الحقيقي؟" و"هل هناك نهاية محدّدة؟" و"هل تتكرّر على جدول ثابت؟".

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
<div class="d3-arch" data-arch-root id="laudecodeloopengineering-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 633, "height": 650, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q1", "x": 335, "y": 24, "w": 167, "h": 68, "title": ["هل يراقب إنسان", "في الوقت الحقيقي؟"]}, {"id": "M", "x": 443, "y": 184, "w": 149, "h": 94, "title": ["حلقة يدوية", "تبدأ بأمر", "وتتوقّف عند الحكم", "بالاكتمال"]}, {"id": "Q2", "x": 250, "y": 197, "w": 138, "h": 68, "title": ["حتى تحقيق", "هدف محدّد؟"]}, {"id": "G", "x": 339, "y": 370, "w": 198, "h": 78, "title": ["/goal", "شرط إتمام + سقف ميزانية", "ينتهي عند تحقّق المعايير"]}, {"id": "Q3", "x": 117, "y": 375, "w": 167, "h": 68, "title": ["يتكرّر بفاصل زمني", "أو جدول؟"]}, {"id": "L", "x": 214, "y": 548, "w": 191, "h": 62, "title": ["حلقة /loop بفاصل", "تعيد تشغيل أمر على دورة"]}, {"id": "S", "x": 24, "y": 540, "w": 135, "h": 78, "title": ["روتين /schedule", "يعمل بلا إنسان", "حتى تُطفئه"]}], "edges": [{"src": "Q1", "dst": "M", "kind": "data", "label": "نعم، مهمة قصيرة لمرة واحدة", "curve": [[461, 92], [518, 138], [518, 138], [518, 184]], "off": "50%"}, {"src": "Q1", "dst": "Q2", "kind": "data", "label": "لا", "curve": [[376, 92], [319, 138], [319, 138], [319, 197]], "off": "50%"}, {"src": "Q2", "dst": "G", "kind": "data", "label": "نعم", "curve": [[363, 265], [438, 324], [438, 324], [438, 370]], "off": "50%"}, {"src": "Q2", "dst": "Q3", "kind": "data", "label": "لا", "curve": [[276, 265], [201, 324], [201, 324], [201, 375]], "off": "50%"}, {"src": "Q3", "dst": "L", "kind": "data", "label": "فاصل زمني", "curve": [[244, 443], [310, 494], [310, 494], [310, 548]], "off": "50%"}, {"src": "Q3", "dst": "S", "kind": "data", "label": "حدث · جدول", "curve": [[157, 443], [92, 494], [92, 494], [92, 540]], "off": "50%"}]});
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
      const container = document.getElementById('laudecodeloopengineering-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodeloopengineering-1';
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

الأول هو الحلقة اليدوية. تبدأ بأمر من المستخدم وتتوقّف عندما يحكم Claude باكتمال المهمة أو بحاجته إلى مزيد من السياق. تناسب المهام القصيرة نسبيًّا التي ليست جزءًا من عملية أو جدول منتظم.

الثاني هو حلقة `/loop` بفاصل زمني. تعيد تشغيل أمر واحد على فاصل ثابت. المثال في الوثيقة هو: `/loop 5m check my PR, address review comments, and fix failing CI`، أي فحص الـPR كل خمس دقائق، وتطبيق تعليقات المراجعة، وإصلاح CI الفاشل.

الثالث هو روتين `/schedule`. يُطلَق بحدث أو جدول، دون إنسان يراقب في الوقت الحقيقي. تنتهي كل مهمة عند تحقيق هدفها، لكن الروتين نفسه يظلّ يعمل حتى تطفئه. يناسب تدفّقات العمل المتكرّر المحدّدة جيدًا مثل تقارير الأخطاء، وفرز المشكلات، والترحيلات، وترقية الاعتماديات.

ويجري عبر الثلاثة جميعًا `/goal`. يضبط `/goal` شرط إتمام ويُبقي Claude يعمل نحوه دون أن يوجّهه إنسان في كل خطوة. إنها بنية تحمل هدفًا اتجاهيًّا وتتقارب عبر تغذية الأدوات الراجعة.

## كيف تصمّم معايير نجاح جيدة

يتوقّف نجاح الحلقة على مدى جودة تعريف معايير النجاح. تؤكّد الوثيقة الرسمية ثلاث خصائص لمعيار النجاح الجيد.

الأولى هي القابلية للتحقّق. يجب أن يستطيع Claude تأكيد الاكتمال برمجيًّا أو عبر ملاحظة صريحة. "اجتياز كل اختبارات الوحدة" قابل للتحقّق. أما "تحسين الكود" فليس كذلك.

الثانية هي حدّ النطاق. يجب أن تحدّد ما هو ضمن الحدود وما هو خارجها. "أعد هيكلة خدمة الدفع دون المساس بطبقة قاعدة البيانات" هدف محدّد النطاق وآمن.

الثالثة هي مقياس النجاح. تساعد الأرقام. "اخفض زمن استجابة API لنقطة `/search` دون 200 مللي ثانية" يعطي هدفًا ملموسًا. المعايير المحكوم عليها حتميًّا مثل اجتياز الاختبارات أو درجة Lighthouse أو طابور فارغ تعمل على أفضل نحو.

وهناك صمّام أمان إضافي: سقف الأدوار. من دون حدّ مثل "توقّف بعد خمس محاولات"، قد يحرق هدف غامض وقتًا طويلًا ورموزًا كثيرة بينما يقرّر الوكيل إن كان "قريبًا بما يكفي". تضمين سقف أدوار في شرط الإتمام هو أبسط دفاع.

## بوابات التحقّق والمهارات

المبدأ الذي تعود إليه الوثيقة هو أن جودة التغذية الراجعة تحدّد جودة الحلقة. هنا تدخل المهارات. تحزم المهارة إجراء التحقّق الذي تنفّذه الحلقة في كل تمريرة في صورة قابلة لإعادة الاستخدام، فتمنح الوكيل طريقة للتحقّق من مخرجاته. إذا لم تُصفِّ الحلقة شيئًا ومرّرت دائمًا، فتلك إشارة إلى أن المتحقّق معطّل.

هنا تكمن الأهمية العملية الكبرى. حلقة التوسّع (fan-out) التي تنشر مهام فرعية كثيرة بالتوازي تراكم الهلوسات إذا دمجت النتائج دون مرحلة تحقّق. في عمل الكود، يجب أن يدقّق رمز خروج اختبار؛ وفي عمل البحث أو المحتوى، تصويت دحض عدائي النتائجَ قبل الانتقال للخطوة التالية. القراءة الخاطئة الشائعة عند قصور الجودة هي رفع النموذج إلى فئة أغلى، لكن السبب الأكثر شيوعًا هو غياب مرحلة التحقّق.

## دلالات لمنصّة ThakiCloud

هذه الوثيقة خاصّة بالنسبة لنا لأننا نشغّل بالفعل الأنماط التي تصفها في خطوط أنابيب غير مراقَبة فعلية.

تعمل ثلاث طبقات من الحلقات في مستودعنا. أولًا، pge-loop الذي يستخدم المترجم ومشغّل الاختبارات كإشارات مكافأة لتكرار تحويلات الكود حتى تجتاز الاختبارات. هذا يحقّق "شرط الإتمام القابل للتحقّق" من `/goal` كرمز خروج `make test-short`. ثانيًا، Goal Mode الذي يسعى نحو هدف حتى حالة الإنجاز بشكل ذاتي. بملف حالة، وسقف ميزانية، وبوابة `check_cmd`، يتبع مبادئ سقف الأدوار ومقياس النجاح في الوثيقة مباشرة. ثالثًا، مشغّلات launchd cron التي تتكرّر في أوقات ثابتة بلا إنسان، بما يقابل روتينات `/schedule`. العمل الذي لا يحتاج حكم إنسان في كل نبضة، مثل المراقبة وتوليد المحتوى، يعمل على cron بدلًا من إبقاء Claude مقيمًا، مبقيًا التكلفة عند الصفر.

هذا الانضباط التشغيلي هو تحديدًا فلسفة تصميم Paxis. Paxis هي منصّة تحكّم السحابة الأصلية للوكلاء من ThakiCloud، تعامل المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. من منظور هندسة الحلقات، توفّر Paxis أربعة أشياء: إعلان روتينات الجدولة بلغة طبيعية Cron، وتجميع مراحل التوسّع والتحقّق عبر وكلاء DAG المتعدّدين، واختيار من بين أكثر من 960 مهارة عبر BM25 لتشغيلها في صندوق رمل معزول، وتمرير كل فعل حلقة عبر بوابة سياسة وسجلّ تدقيق. مبدأ الوثيقة القائل إن "التوسّع بلا تحقّق خطر" يصبح في Paxis ميزة بنية تحتية: بوابة السياسة.

وتحتها تعمل عدسة ai-platform أيضًا. الحلقة طويلة الأمد هي في النهاية مسألة تكلفة استدلال. الحفاظ على تكلفة خدمة منخفضة فوق جدولة GPU القائمة على Kubernetes وKueue هو الأساس الاقتصادي الذي يجعل روتينات الجدولة مستدامة. الخدمة منخفضة التكلفة تصنع اقتصاد حلقات الوكلاء، وفوقها تملك Paxis أمان الحلقات وتجميعها.

## القيود والحجج المضادة

اعتبار هندسة الحلقات علاجًا لكل شيء خطر بذاته. القيد الأول هو العمل غير القابل للتحقّق. اجعل مهمة لا يمكن الحكم على نجاحها حتميًّا في حلقة، فيحرق الوكيل الميزانية بلا شرط إنهاء. إذا لم تستطع تعريف البوابة أولًا، فالتشغيل لمرة واحدة، لا الحلقة، هو القرار الصحيح.

القيد الثاني هو التكلفة. حلقة جلسة طويلة تعيد قراءة سياق ضخم في كل نبضة ترى تكلفة قراءة الذاكرة المؤقتة تنمو خطّيًّا. تراكم مراقبة أربع وعشرين ساعة في جلسة واحدة مكلف بوجه خاص. القاعدة أن تستدعي الوكيل فقط عند وجود إنسان أو حدث، وأن تدفع الاستطلاع البسيط إلى cron.

القيد الثالث هو الاستسلام المعرفي. كلما تعمّقت الحلقة، مال المرء إلى الثقة بالنتائج والتوقّف عن المراجعة. الأتمتة أداة تعين التفكير لا تحلّ محلّه. يجب أن يعاين إنسان المخرجات الأساسية دوريًّا بالعيّنة، وإذا لم يصفِّ المتحقّق شيئًا فيجب قراءة ذلك كإشارة فشل.

تختزل هذه القيود الثلاثة جميعًا إلى مبدأ واحد: عرّف بوابة الخروج قبل أن تبدأ الحلقة. بوجود بوابة، تراكم الحلقة الجودة؛ وبغيابها، تراكم الحلقة الهلوسة.

## المصادر

- Anthropic, "Getting started with loops" (2026-07-07): [claude.com/blog/getting-started-with-loops](https://claude.com/blog/getting-started-with-loops)
- Claude Code Docs, "Keep Claude working toward a goal": [code.claude.com/docs/en/goal](https://code.claude.com/docs/en/goal)
