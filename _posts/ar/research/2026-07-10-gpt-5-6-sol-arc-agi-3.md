---
title: "التوجّه قبل التنفيذ: كيف كسر GPT-5.6 Sol حاجز ARC-AGI-3 لأول مرة"
seo_title: "تحليل اختراق GPT-5.6 Sol لـ ARC-AGI-3 بنسبة 7.8% - Thaki Cloud"
seo_description: "يحلل هذا المقال كيف حقق GPT-5.6 Sol أول نتيجة SOTA على ARC-AGI-3 بنسبة 7.78%، وأصبح أول نموذج يُنهي إحدى الألعاب بالكامل. نستعرض من منظور ThakiCloud لماذا يُعد الاستدلال القائم على orientation أساسياً لبنية العملاء الذكيين واقتصاديات الخدمة."
excerpt: "يقيس ARC-AGI-3 قدرة العميل الذكي على فهم الموقف والتكيّف بنفسه داخل لعبة تفاعلية بلا تعليمات. حقق GPT-5.6 Sol أول اختراق لهذا المقياس بنسبة 7.78%، وكان الدافع وراءه ليس تنفيذاً أدق، بل قدرة على orientation، أي تحديد الاتجاه أولاً في بيئة غير مألوفة."
date: 2026-07-10
tags:
  - arc-agi
  - reasoning
  - agents
  - gpt-5-6
  - benchmark
  - agentic-ai
  - orientation
categories:
  - research
author_profile: true
toc: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/research/gpt-5-6-sol-arc-agi-3/"
---

الفرق التي شغّلت عملاء ذكاء اصطناعي فعلياً في الإنتاج لا تتحمّس بسهولة لرقم واحد في اختبار قياسي. رأينا حالات كثيرة لنموذج يتجاوز 90% في حل مسائل ثابتة، ثم يفقد اتجاهه أمام أداة غير مألوفة، أو واجهة مستخدم يراها لأول مرة، أو بيئة بلا أي تعليمات. لذلك حين أعلنت ARC Prize أنها تحقّقت من نتائج GPT-5.6 Sol على ARC-AGI-3، لم يكن الرقم نفسه هو الأمر اللافت، بل الطريقة التي تحقق بها هذا الرقم.

الحقيقة الأساسية هي التالية: سجّل GPT-5.6 Sol نسبة 7.78% على مجموعة ARC-AGI-3 شبه الخاصة (semi-private)، محققاً رقماً قياسياً جديداً (SOTA)، وأصبح أول نموذج طليعي تم التحقق منه ينهي إحدى ألعاب ARC-AGI-3 بالكامل من البداية للنهاية. لكن اللافت هو تفسير ARC Prize لسبب هذا التفوق: لم ينجح Sol لأنه ينفّذ كل خطوة بدقة أكبر، بل لأنه كان أفضل في orientation، أي القدرة على تحديد اتجاهه بنفسه في موقف لم يره من قبل.

![صورة تجريدية تجسد عملية توجّه عميل ذكاء اصطناعي داخل عالم شبكي غريب وتقاربه نحو مسار واحد]({{ '/assets/images/gpt-5-6-sol-arc-agi-3-hero.png' | relative_url }})
*تجسّد اللحظة التي تتقارب فيها الفوضى المتناثرة في بيئة غريبة بلا تعليمات نحو اتجاه واحد، وهي جوهر ما يُعرف بـ orientation.*

## نظرة عامة

هذا المقال لا يتناول ترتيب GPT-5.6 Sol العام بين النماذج. بل يتناول لماذا حقق هذا النموذج تقدماً ملموساً تحديداً في ARC-AGI-3 دون غيره من الاختبارات، وماذا يعني هذا التقدم لمن يبني عملاء ذكاء اصطناعي ويشغّلها فعلياً في الإنتاج، كما هو حالنا.

تنقسم سلسلة ARC-AGI إلى نوعين مختلفين جوهرياً من المسائل. تقيس ARC-AGI-1 وARC-AGI-2، وهما ألغاز شبكية ثابتة، ما يُسمى fluid intelligence السلبي، أي القدرة على استنتاج قاعدة وإنتاج الشبكة الصحيحة. أما ARC-AGI-3 فهي مسألة من نوع مختلف تماماً: بيئة لعبة تفاعلية تُلعب بالأدوار (turn-based) بلا أي تعليمات، يتوجّب على العميل فيها أن يتصرف بنفسه ليكتشف القواعد ويحقق الهدف. بعبارة أخرى، انتقل المحور من مسألة إصابة الإجابة الصحيحة إلى مسألة التكيّف مع عالم غير مألوف.

هذا الفرق مهم من منظور ThakiCloud. معظم أعباء العمل الخاصة بالعملاء الذكيين التي نتعامل معها أقرب إلى الحالة الثانية. مدى سرعة إدراك العميل للموقف وتحركه بأمان أمام موصل MCP يتصل به لأول مرة، أو واجهة API داخلية لم يرها من قبل، أو مصدر بيانات تغيّر مخططه (schema). هذا هو ما يحدد فعلياً نجاح العميل الذكي في الإنتاج من فشله. وARC-AGI-3 يقيس هذه القدرة بالتحديد ضمن ظروف مخبرية.

## ما هو ARC-AGI-3 ولماذا هو بهذه الصعوبة

صُمم ARC-AGI-3 ليكون مقاوماً لنوع التقدم الذي أشبع الجيل السابق. فARC-AGI-1 بات الآن مُشبعاً فعلياً؛ يتقارب Sol وTerra عند نحو 96.5%، بينما يصل حتى النموذج منخفض التكلفة Luna إلى 88%. الاستدلال الثابت بات اليوم قريباً من مسألة محلولة بالنسبة للنماذج الطليعية.

عند الانتقال إلى ARC-AGI-2، تتّسع الفجوة: يسجل Sol نسبة 92% (بتكلفة نحو 1.44 دولار لكل مهمة)، وTerra 83.9% (1.09 دولار)، وLuna 59.5% (0.67 دولار). وحتى هذا المستوى لا يزال يقع ضمن نطاق مدى إتقان حل مسألة معطاة.

المشكلة تكمن في ARC-AGI-3. عند إطلاق هذا المقياس في مارس 2026، لم يتجاوز حتى أفضل نموذج آنذاك نسبة 0.37%. والسبب أن على العميل، داخل لعبة تفاعلية، أن يكتشف بنفسه وبلا أي معلومة مسبقة أي فعل يُحدث أي أثر، وما الهدف، وماذا يعني الفشل. أمر سهل بالنسبة للإنسان، لكنه بالنسبة للنموذج منطقة مجهولة تماماً تقع خارج توزيع بيانات تدريبه.

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
<div class="d3-arch" data-arch-root id="20260710gpt56solarcagi3-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 708, "height": 662, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 291, "y": 24, "w": 121, "h": 46, "title": "سلسلة ARC-AGI"}, {"id": "B", "x": 506, "y": 148, "w": 149, "h": 62, "title": ["ARC-AGI-1", "ألغاز شبكية ثابتة"]}, {"id": "C", "x": 277, "y": 148, "w": 149, "h": 62, "title": ["ARC-AGI-2", "استدلال ثابت أصعب"]}, {"id": "D", "x": 38, "y": 148, "w": 184, "h": 62, "title": ["ARC-AGI-3", "ألعاب تفاعلية بالأدوار"]}, {"id": "B1", "x": 485, "y": 288, "w": 191, "h": 62, "title": ["fluid intelligence سلبي", "Sol 96.5% مُشبع"]}, {"id": "C1", "x": 274, "y": 288, "w": 156, "h": 62, "title": ["استدلال قواعد أعمق", "Sol 92% / 1.44$"]}, {"id": "D1", "x": 42, "y": 288, "w": 177, "h": 62, "title": ["بلا تعليمات", "اكتشاف القواعد بالفعل"]}, {"id": "E", "x": 24, "y": 428, "w": 212, "h": 62, "title": ["orientation مطلوب", "التكيّف مع بيئة غير مألوفة"]}, {"id": "F", "x": 31, "y": 568, "w": 198, "h": 62, "title": ["الأفضل عند الإطلاق 0.37%", "غير محلول فعلياً"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[412, 63], [580, 109], [580, 109], [580, 148]]}, {"src": "A", "dst": "C", "kind": "data", "line": [352, 70, 352, 148]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[291, 64], [130, 109], [130, 109], [130, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [580, 210, 580, 288]}, {"src": "C", "dst": "C1", "kind": "data", "line": [352, 210, 352, 288]}, {"src": "D", "dst": "D1", "kind": "data", "line": [130, 210, 130, 288]}, {"src": "D1", "dst": "E", "kind": "data", "line": [130, 350, 130, 428]}, {"src": "E", "dst": "F", "kind": "data", "line": [130, 490, 130, 568]}]});
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
      const container = document.getElementById('20260710gpt56solarcagi3-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260710gpt56solarcagi3-1';
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

يوضح هذا التركيب أن ARC-AGI-3 يقيس محوراً مختلفاً جذرياً عن باقي الاختبارات. فإذا كان الجيلان الأولان يتعلقان برفع دقة الذكاء (resolution)، فإن الجيل الثالث يتطلب قدرة الذكاء على التكيّف (adaptability). وهذه القدرة لا تُبنى بدقة التنفيذ وحدها.

## نتائج GPT-5.6 Sol بالأرقام

سجّل GPT-5.6 Sol، عند أقصى إعداد لجهد الاستدلال (max reasoning effort)، متوسط 13.33% على مجموعة ARC-AGI-3 العامة (public) و7.78% على المجموعة شبه الخاصة. ورقم 7.8% الذي يتصدّر العناوين هو هذا الرقم شبه الخاص تحديداً. وإذا أخذنا بعين الاعتبار أن الرقم القياسي السابق كان لـ Claude Opus 4.8 بنسبة 1.5%، فهذه قفزة تفوق خمسة أضعاف.

الحدث الأكثر دلالة هو أن Sol أصبح أول نموذج طليعي مُتحقق منه ينهي فعلياً إحدى ألعاب ARC-AGI-3 العامة (ft09). وكانت نسبة نجاح Sol في هذه اللعبة 87%. لم ينهِ أي نموذج لعبة واحدة بالكامل منذ إطلاق هذا المقياس مباشرة، لذا فهذا ليس مجرد تحديث لرقم قياسي، بل أول حالة تتجاوز عتبة نوعية.

لكن يجب النظر إلى التكلفة بصراحة. تصل تكلفة تقييم ARC-AGI-3 الكامل عند أقصى جهد استدلال إلى ما يقارب 20,000 دولار إجمالاً. هذه القدرة لا تزال قدرة تنفتح بالكاد عند أغلى إعداد ممكن. رقم 7.78% إشارة اختراق، وليس إعلاناً بأن المسألة قد حُلّت. وبمقارنته بنسبة 92% في ARC-AGI-2، يتضح أن التكيّف التفاعلي لا يزال متأخراً جيلاً كاملاً عن الاستدلال الثابت.

## الاختراق جاء من orientation لا من التنفيذ

أهم نقطة هنا هي تفسير ARC Prize. فسبب أداء Sol الجيد في ARC-AGI-3، بحسب هذا التفسير، ليس أنه نفّذ كل فعل بدقة أكبر، بل أنه تمكّن أولاً من توجيه نفسه (orient) بشكل صحيح داخل بيئة غير مألوفة.

الـ orientation والتنفيذ قدرتان مختلفتان. التنفيذ هو أداء الفعل بدقة عندما تكون تعرف ما يجب فعله في هذا الموقف. أما orientation فهو إدراك بنية الموقف عبر الملاحظة والمحاولة عندما لا يكون واضحاً أصلاً ماذا يجب فعله. تقيس معظم الاختبارات القياسية التنفيذ، لأن المسألة والهدف يُعطيان بوضوح. أما ARC-AGI-3 فيخفي حتى الهدف نفسه، ويقيس orientation بدلاً من ذلك.

هذا التمييز يمسّ مباشرة تصميم العملاء الذكيين في الواقع العملي. اللحظة التي يفشل فيها عميل ذكي في الإنتاج هي غالباً مرحلة orientation، لا مرحلة التنفيذ. نادراً ما ينهار لأنه استدعى الدالة الخطأ؛ بل ينهار لأنه أخطأ منذ البداية في تحديد أي دالة يجب استدعاؤها ولماذا في هذا الموقف بالذات. تشير نتيجة Sol إلى أن orientation محور يمكن أن يتوسّع (scale) بشكل مستقل، وأن اختباراً يقيس هذا المحور قد يكون أكثر ارتباطاً بجودة العميل الذكي الفعلية.

## دلالات التطبيق على منتجات ThakiCloud

هذا الموضوع يمسّ منتجَي ThakiCloud كليهما.

**عدسة Paxis (orientation العملاء الذكيين).** Paxis هي Agent-Native Cloud الخاصة بـ ThakiCloud، حيث تُعامَل Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. هنا لا يكون orientation مفهوماً مجرداً بل مسألة تصميم بحتة. في كل مرة يتصل فيها عميل ذكي بموصل MCP جديد لأول مرة، أو يختار من بين نحو 960 مهارة (skill) عبر BM25، فهو في الواقع يحل مسألة تحديد الاتجاه داخل فضاء قدرات غير مألوف من جديد. والدرس المستفاد من ARC-AGI-3 هو ألا تُترك خطوة orientation هذه للنموذج وحده، بل يجب أن يساعد فيها الـ harness. وحين تُنظّم Paxis فضاء الأفعال عبر أوصاف المهارات وبوابات السياسات وسجلات التدقيق، فإنها تعمل كأداة مساعدة على orientation، تتيح للعميل الذكي أن يجد اتجاهه داخل هيكل مُتحقق منه، بدلاً من أن يتخبّط في بيئة مجهولة. وبدون الاعتماد على استدلال مكلف بأقصى طاقته كما فعل Sol، فإن harness يقلّل عبء orientation يمكن أن يجعل التكيّف المستقر ممكناً حتى مع نماذج أرخص.

**عدسة ai-platform (اقتصاديات الاستدلال).** في الوقت نفسه، تكلفة التقييم البالغة 20,000 دولار هي أيضاً مسألة بنية تحتية للخدمة (serving). فالاستدلال المرتكز على orientation يتطلب عادة مسارات تفكير طويلة ومحاولات كثيرة، وهو ما يترجم مباشرة إلى استهلاك أكبر للـ tokens. تركّز منصة ai-platform الخاصة بـ ThakiCloud على تشغيل أعباء الاستدلال المكلفة هذه بكفاءة من حيث التكلفة في بيئة متعددة المستأجرين (multi-tenant)، عبر K8s وجدولة Kueue للـ GPU وخدمة vLLM. ولكي يُنقل عميل ذكي يتكيّف مع بيئات غير مألوفة إلى الإنتاج فعلياً، لا بد من طبقة خدمة (serving layer) قادرة على خفض تكلفة أقصى جهد استدلال إلى مستوى يمكن تحمّله. وهذا يؤكد مجدداً أن الخدمة الرخيصة هي ما يصنع اقتصاديات العميل الذكي.

باختصار، لا يتحوّل العميل الذكي المتكيّف إلى شيء يمكن تشغيله فعلياً، بدلاً من أن يبقى عرضاً طليعياً مكلفاً، إلا حين توزّع Paxis عبء orientation على الـ harness، وتخفض ai-platform تكلفة ذلك الاستدلال.

## القيود والحجج المضادة

لتجنّب المبالغة في تفسير هذه النتيجة، نضع هنا بعض الحجج المضادة.

أولاً، لا تزال نسبة 7.78% رقماً مطلقاً منخفضاً جداً. فالإنسان يُنهي معظم ألعاب ARC-AGI-3 دون عناء يُذكر، بينما بالكاد أنهى أفضل نموذج لعبة واحدة. القول بأن هذا اختراق وصف عادل، لكنه بعيد عن القول بأن المسألة محلولة. ومدى قوة تعميم قدرة orientation هذه لم يُثبت بعد.

ثانياً، تُقابل مشكلة التكلفة جزءاً كبيراً من ادعاء القدرة. فقدرة لا تنفتح إلا عند أقصى جهد استدلال مسألة منفصلة عن إمكانية النشر الفعلي. والسؤال الحقيقي عن القيمة هو: هل تتكرر نفس قدرة orientation بعُشر هذه التكلفة؟ والبيانات الحالية لا تجيب عن هذا السؤال.

ثالثاً، هذه نتيجة تحقّق منها اختبار قياسي واحد فقط. لم يُختبر Fable 5 بعد على ARC-AGI-3، وما إذا كانت قدرة orientation هذه تنتقل إلى مهام عملاء ذكيين فعلية خارج مجموعة ألعاب ARC-AGI-3 يحتاج إلى تحقق منفصل. ولا تتوفر أدلة كافية بعد لاستبعاد احتمال أن يكون النموذج قد بالغ في التكيّف مع هذا الاختبار تحديداً (overfitting).

مع ذلك، يبقى الاتجاه العام واضحاً. في عصر تتشبّع فيه دقة التنفيذ، تصبح orientation عنق الزجاجة التالي، وسيكون قياسها ومساعدتها عبر harness هو الميزة التنافسية التالية للعملاء الذكيين في الواقع العملي. ورقم 7.78% الذي حققه Sol هو الإحداثية الأولى لتلك النقطة الفاصلة.

## المصادر

- [نتائج GPT-5.6 Sol على ARC-AGI (ARC Prize)](https://arcprize.org/results/openai-gpt-5-6-sol)
- [إعلان ARC Prize (X/Twitter)](https://x.com/arcprize/status/2075270869992264003)
- [لوحة صدارة ARC Prize](https://arcprize.org/leaderboard)
- [GPT 5.6 Sol يتصدر ARC-AGI-3 بنسبة 7.8% (OfficeChai)](https://officechai.com/ai/gpt-5-6-sol-tops-arc-agi-3-with-7-8-becomes-first-model-to-make-meaningful-progress-on-benchmark/)
