---
title: "fable-advisor: سير عمل متعدد الموردين يقوده Fable 5 وينفذه Grok 4.5"
seo_title: "قيادة Grok 4.5 بواسطة Fable 5 - تحليل إضافة fable-advisor - Thaki Cloud"
seo_description: "fable-advisor هو سير عمل متعدد الوكلاء عبر البائعين حيث يتولى Claude Fable 5 كتابة المواصفات والمراجعة، بينما يتولى Grok 4.5 كتابة التنفيذ الفعلي. يحلل هذا المقال بنية الفصل بين الموجّه والعامل ويتحقق منها من منظور Paxis الخاص بـ ThakiCloud."
excerpt: "نحلل بنية الفصل بين الموجّه والعامل في إضافة fable-advisor، حيث يقود Claude Fable 5 كتابة المواصفات ومراجعة الفروقات (diff)، بينما يتولى Grok 4.5 وحده كتابة الشيفرة الفعلية، ونتحقق منها من منظور ThakiCloud الذي يتعامل مع الوكلاء المتعددين كمورد أساسي من الدرجة الأولى."
date: 2026-07-11
lang: ar
tags:
  - claude-code
  - multi-agent
  - model-routing
  - fable
  - grok
  - agentops
  - paxis
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/fable-advisor-multi-model-orchestration/"
---

عند استخدام وكلاء البرمجة، يطرأ سؤال طبيعي على الذهن. كتابة المواصفات بدقة ومراجعة الفروقات (diff) الناتجة بعين ثاقبة عمل يختلف في طبيعته عن كتابة الشيفرة سطراً سطراً، فلماذا إذن يتوجب على نموذج واحد أن يقوم بالمهمتين معاً؟ إضافة `fable-advisor` التي طُرحت مؤخراً وأثارت اهتماماً واسعاً تجيب على هذا السؤال مباشرة. إنها سير عمل متعدد الموردين حيث **يقتصر دور Claude Fable 5 على القيادة، بينما يتولى Grok 4.5 وحده التنفيذ الفعلي**. يحلل هذا المقال تلك البنية، ويتحقق مما تعنيه هذه الهندسة من منظور تشغيل ThakiCloud الذي يتعامل مع الوكلاء المتعددين وتوجيه النماذج كمورد أساسي من الدرجة الأولى.

## نظرة عامة

حتى الآن، كانت سير عمل البرمجة متعددة الوكلاء تجري غالباً ضمن مورد واحد فقط. ففي Claude Code مثلاً، يقود Opus العمل بينما تعمل Sonnet أو Haiku كوكلاء فرعيين. والنقطة اللافتة في `fable-advisor` هي أنها تبني هذا التقسيم **عبر حدود الموردين**. حيث يتولى Fable 5 من Anthropic طبقة التنسيق، بينما يتولى Grok 4.5 من xAI طبقة التنفيذ.

الرؤية الجوهرية لهذا التصميم واضحة. القيادة والتنفيذ يتطلبان قدرات مختلفة، وبنية تكلفة مختلفة أيضاً. كتابة المواصفات ومراجعة الفروقات تقع في مجال الحكم والاستدلال، مما يستلزم نموذجاً مناسباً للقيادة، بينما تتطلب كتابة كميات كبيرة من الشيفرة كفاءة في الإنتاجية والتكلفة. تضع `fable-advisor` كلاً من هاتين المهمتين على نماذج من موردين مختلفين، بحيث يُستخدم في كل طبقة النموذج الأنسب لها. كونها مفتوحة المصدر ومجانية، وإمكانية تخصيص منطق التوجيه مباشرة، يخفّض أيضاً عتبة التبني في الاستخدام الفعلي.

## ما هذه التقنية

`fable-advisor` هي إضافة تُركَّب فوق Claude Code، وتفرض فصلاً بين ثلاثة أدوار.

أولاً، **الموجّه (Fable 5)** يكتب المواصفات ويراجع النتائج. يستقبل طلب المستخدم ويحلله إلى مواصفات تنفيذ، ثم يراجع الفروقات (diff) بعد اكتمال التنفيذ. والمهم هنا أن الموجّه **لا يكتب الشيفرة مباشرة**، بل يركز على الحكم وتعريف العقود.

ثانياً، **المُنفِّذ (Grok 4.5)** يتولى الكتابة الفعلية وحده. يستقبل المواصفات التي يسلّمها الموجّه، ويكتب Grok 4.5 الشيفرة عبر Grok CLI. وإذا تفحصنا تاريخ المستودع، نجد أنه اعتباراً من الإصدار v3 تم استبدال وكلاء التنفيذ السابقين المعتمدين على Sonnet/Opus بـ `grok-implementer`، ليصبح Grok 4.5 مسار الكتابة الافتراضي. بعبارة أخرى، لم تكن هذه الإضافة متعددة الموردين منذ البداية، بل هي نتاج تطور تدريجي نحو نقل مسار التنفيذ إلى نموذج منخفض التكلفة وعالي الإنتاجية.

ثالثاً، **التنفيذ المتوازي**. تُنفَّذ المواصفات المستقلة عن بعضها البعض في آن واحد عبر وكلاء متوازيين. فعندما يقسّم الموجّه المهمة إلى وحدات لا تعتمد على بعضها، تمضي كل وحدة قدماً في وقت واحد عبر وكيل تنفيذ منفصل. وهذا ليس مجرد تفويض تسلسلي بسيط، بل أقرب إلى تقسيم عمل على شكل DAG (رسم بياني موجّه غير دوري).

إذا نظرنا إلى سير العمل الكامل بشكل تخطيطي، يكون كما يلي.

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
<div class="d3-arch" data-arch-root id="rmultimodelorchestration-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 699, "height": 534, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 294, "y": 24, "w": 120, "h": 46, "title": "طلب المستخدم"}, {"id": "F", "x": 258, "y": 148, "w": 191, "h": 78, "title": ["موجّه Fable 5", "كتابة المواصفات ومراجعة", "diff"]}, {"id": "S1", "x": 90, "y": 318, "w": 120, "h": 46, "title": "مواصفة A"}, {"id": "S2", "x": 543, "y": 318, "w": 120, "h": 46, "title": "مواصفة B"}, {"id": "G1", "x": 24, "y": 456, "w": 142, "h": 46, "title": "منفّذ Grok 4.5 A"}, {"id": "G2", "x": 477, "y": 456, "w": 142, "h": 46, "title": "منفّذ Grok 4.5 B"}, {"id": "R", "x": 265, "y": 318, "w": 177, "h": 46, "title": "نتيجة الدمج والمراجعة"}], "edges": [{"src": "U", "dst": "F", "kind": "data", "line": [354, 70, 354, 148]}, {"src": "F", "dst": "S1", "kind": "data", "label": "تحليل مواصفات مستقلة", "curve": [[260, 226], [150, 272], [150, 272], [150, 318]], "off": "50%"}, {"src": "F", "dst": "S2", "kind": "data", "label": "تحليل مواصفات مستقلة", "curve": [[449, 220], [603, 272], [603, 272], [603, 318]], "off": "50%"}, {"src": "S1", "dst": "G1", "kind": "event", "label": "Grok CLI", "curve": [[150, 364], [150, 410], [150, 410], [113, 456]], "off": "50%"}, {"src": "S2", "dst": "G2", "kind": "event", "label": "Grok CLI", "curve": [[603, 364], [603, 410], [603, 410], [566, 456]], "off": "50%"}, {"src": "G1", "dst": "F", "kind": "data", "label": "diff", "curve": [[77, 456], [40, 410], [40, 272], [258, 213]], "off": "50%"}, {"src": "G2", "dst": "F", "kind": "data", "label": "diff", "curve": [[529, 456], [492, 410], [492, 272], [417, 226]], "off": "50%"}, {"src": "F", "dst": "R", "kind": "data", "line": [354, 226, 354, 318]}]});
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
      const container = document.getElementById('rmultimodelorchestration-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rmultimodelorchestration-1';
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

## التثبيت والتكامل

تثبيت الإضافة يتم بسطر واحد فقط. يكفي إضافة المستودع إلى سوق إضافات Claude Code.

```bash
claude plugin marketplace add DannyMac180/fable-advisor
```

يتطلب Grok CLI، المسؤول عن مسار التنفيذ، مصادقة منفصلة. فعند تسجيل الدخول عبر `grok login`، يعمل النظام بمصادقة OAuth قائمة على اشتراك SuperGrok أو X Premium+، وبحسب وصف المستودع، يتيح هذا المسار تشغيل وكيل التنفيذ **بالاشتراك فقط ودون رسوم API لكل رمز (token)**. وهذه النقطة هي جوهر بنية التكلفة. فالموجّه يقوم بعدد قليل فقط من الاستدعاءات التي تتطلب حكماً، بينما تُعالَج الكمية الكبيرة من كتابة الشيفرة ضمن خطة الاشتراك، مما يقلّل إلى أدنى حد الجزء الخاضع للرسوم حسب الاستخدام.

من زاوية التكامل، الجانب الجدير بالملاحظة هو أن منطق التوجيه مفتوح. إذ يمكن للمستخدم أن يضبط بنفسه أي مهمة تُرسَل إلى أي نموذج، وفي أي شروط يتم التوازي، مما يتيح إعادة تشكيل المسارات بما يتناسب مع ميزانية الفريق ومتطلبات الجودة.

## كيف يعمل هذا التصميم فعلياً

بما أن `fable-advisor` ليست أداة تعتمد على أرقام قياسية (بنشمارك)، بل نمط سير عمل، فسنتناول هنا الأثر البنيوي الذي يُحدثه هذا التصميم بدلاً من أرقام أداء قابلة للتكرار. وبما أن المستودع لا يقدّم مؤشرات كمية، فإن هذا المقال أيضاً لن يختلق أرقاماً، بل سيتناول المزايا البنيوية فقط.

أكبر أثر هو **الفصل بين التكلفة والجودة**. فعندما يُوكَل التنسيق الذي يتطلب حكماً إلى الموجّه، ويُوكَل التنفيذ الذي يتطلب إنتاجية عالية إلى منفّذ منخفض التكلفة، ينخفض السعر الإجمالي لسير العمل مع بقاء جودة الحكم كما هي. وهكذا يتشكّل بشكل طبيعي توزيع مفاده "لا يُستدعى الموجّه كثيراً لكنه غالي الثمن، بينما يُستدعى المنفّذ كثيراً دون أن يكون مكلفاً".

الأثر الثاني هو **التحقق المتقاطع**. كون المنفّذ والمراجِع نموذجين من موردين مختلفين يُنتج أثراً جانبياً مثيراً للاهتمام. فعندما يراجع النموذج نفسه شيفرته الخاصة، يسهل عليه إغفال نفس الأخطاء، أما عندما يراجع نموذج من سلالة مختلفة الفروقات (diff)، تزداد فرصة اكتشاف النقاط العمياء لدى كل منهما. وبذلك يصبح الفصل بين الموجّه والعامل أكثر من مجرد تقسيم عمل بسيط، بل نوعاً من آلية التحقق المتبادل.

الأثر الثالث هو **تقليص زمن الاستجابة بفضل التوازي**. فعند تنفيذ المواصفات المستقلة في آن واحد، لا يكون إجمالي وقت العمل مجموعاً تسلسلياً، بل يتقارب مع أطول سلسلة مفردة. وكلما أحسن الموجّه تحليل المهمة إلى وحدات، ازدادت هذه الميزة.

## تعميم نمط الموجّه والعامل

إذا نظرنا إلى `fable-advisor` ليس كإضافة منفردة بل كنمط تصميم، يتضح سياق أوسع. جوهر هذا النمط هو "الجلسة الرئيسية تقود فقط، والمهام الثقيلة تُفوَّض". وكون العمل عابراً للموردين ليس سوى صورة واحدة من صور هذا النمط، إذ يصح فعلياً حتى داخل مورد واحد. فمثلاً في Claude Code، يُستخدم على نطاق واسع بالفعل تكوين يجعل Fable 5 موجّهاً، بينما يُوكَل الاستكشاف إلى Haiku، والتنفيذ إلى Sonnet، والاستدلال المعقد إلى وكلاء فرعيين من Opus. وما فعلته `fable-advisor` هو توسيع نطاق النماذج المستهدفة بهذا التفويض إلى ما وراء حدود المورد الواحد.

من هذا المنظور، تصبح معايير اختيار نموذج الموجّه أكثر وضوحاً. فالموجّه مسؤول عن الحكم والتفرّع والتجميع، لذا فإن الدقة وجودة الاستدلال مهمتان، بينما يكون تكرار الاستدعاء منخفضاً نسبياً. في المقابل، يهتم المنفّذ بالإنتاجية والسعر. لذا فإن التنسيق الجيد ليس "وضع النموذج الأغلى كموجّه ومعالجة كل شيء به"، بل "تخصيص نموذج بالخصائص التي تتطلبها كل طبقة لتلك الطبقة تحديداً". وتطور الإصدار v3 الذي نقل فيه `fable-advisor` مسار التنفيذ إلى نموذج اشتراك منخفض التكلفة هو نتيجة مطابقة تماماً لهذا المبدأ.

نقطة واحدة يجب الانتباه إليها هي أن هذا النمط لا يكون فعالاً إلا إذا كانت حدود التفويض واضحة. فإذا سلّم الموجّه مواصفات غامضة، يضطر المنفّذ إلى ملء الفجوات بالتخمين، وتزداد نتيجة لذلك عبء المراجعة. لا تتحقق فائدة التفويض إلا عندما تكون المواصفات محددة بما فيه الكفاية. وهذا لا يختلف عن تقسيم العمل في المنظمات البشرية، فكلما كانت المواصفات أوضح، عمل التفويض بشكل أفضل.

## دلالات التطبيق على منتجات ThakiCloud

يتقاطع هذا التصميم بشكل لافت مع الطريقة التي تُشغّل بها ThakiCloud وكلاءها.

من منظور **Paxis**، يكون الارتباط الأوثق مباشرةً. فـ Paxis هو مستوى التحكم الخاص بـ ThakiCloud للسحابة القائمة على الوكلاء (Agent-Native Cloud)، ويتعامل مع تنفيذ الوكلاء المتعددين على شكل DAG كقدرة أساسية. البنية التي تُظهرها `fable-advisor` — "كتابة المواصفات ← تنفيذ موزّع ← مراجعة متقاطعة" — تحمل نفس الهيكل الذي يعتمده حزام أدوات المهارات (skill harness) في Paxis، حيث يُحلَّل العمل إلى مهام فرعية، وتُنفَّذ بشكل متوازٍ داخل صناديق رملية معزولة، ثم تُغلَق عبر مرحلة تحقق. وعلى وجه الخصوص، فإن المبدأ القائل بأن الموجّه لا يكتب الشيفرة مباشرة بل يركّز على الحكم وتعريف العقود، يتطابق تماماً مع فلسفة التصميم لدينا التي تستمد القدرة من بنية العقد المحيطة لا من درجة النموذج. كما أن التدفق الذي يُعيد فيه الموجّه مراجعة نتائج نماذج مختلفة، يتقاطع أيضاً مع مبدأنا التشغيلي القاضي بإغلاق توسّع الوكلاء المتعددين (fan-out) عبر مرحلة تحقق لمنع تراكم الهلوسة.

من منظور **ai-platform**، تكون زاوية بنية التكلفة سارية المفعول. فمنصة ai-platform الخاصة بـ ThakiCloud تجدول أحمال عمل وحدات معالجة الرسوميات (GPU) اعتماداً على K8s وKueue، وتخدم أحمال الاستدلال والتدريب لدى العملاء. الفكرة التي تعتمدها `fable-advisor` بتفويض مسار التنفيذ إلى نموذج منخفض التكلفة لخفض السعر الإجمالي لسير العمل، هي نمط يمكن لعملاء السحابة القائمة على GPU تطبيقه مباشرة عند تصميم أحمال عملهم. فعندما تُوضَع مراحل الحكم القليلة التي تتطلب استدلالاً ثقيلاً، ومراحل التنفيذ الكثيرة التي تتطلب إنتاجية عالية، على موارد من فئات مختلفة، يمكن الحصول على النتيجة نفسها بتكلفة أقل. وبما أن الخدمة منخفضة التكلفة هي ما يصنع جدوى الوكلاء الاقتصادية، فإن كفاءة تكلفة ai-platform وتنسيق وكلاء Paxis يكمّلان بعضهما البعض.

## القيود والاعتراضات

لهذا التصميم أيضاً ثمن واضح يجب دفعه. أولاً، **تعقيد التشغيل**. فربط نموذجين من موردين مختلفين في سير عمل واحد يعني إدارة نظامي مصادقة، وخطتي تسعير، ونقطتي فشل محتملتين. فإذا تغيّرت واجهة سطر الأوامر لأحد الموردين أو انتهت صلاحية المصادقة، قد يتوقف سير العمل بأكمله. وبما أن هذا يعني التخلي عن بساطة سير العمل أحادي المورد مقابل هذه الميزة، فإن كل فريق قد يقيّم بشكل مختلف ما إذا كانت الميزة تبرر هذا التعقيد.

ثانياً، **مخاطر تفويض الجودة**. إسناد التنفيذ إلى نموذج منخفض التكلفة يعني أنه إذا لم تكن مواصفات ومراجعات الموجّه دقيقة بما فيه الكفاية، فقد يمر تنفيذ منخفض الجودة دون رصد. وجودة سير العمل هذا تعتمد في نهاية المطاف على مدى صرامة بوابة المراجعة لدى الموجّه. فإذا كانت المراجعة شكلية، يختفي أثر التحقق المتقاطع الناتج عن تقسيم العمل بين الموردين، ويتحول الأمر إلى خط أنابيب منخفض الجودة لا يوفر سوى التكلفة.

ثالثاً، **قيود المصادقة القائمة على الاشتراك**. كون Grok CLI يعمل بمصادقة OAuth قائمة على الاشتراك يمثّل ميزة من حيث التكلفة للأفراد أو الفرق الصغيرة، لكن في الأتمتة واسعة النطاق أو خطوط الأنابيب غير المأهولة، قد تصبح حدود الاشتراك وتجديد المصادقة عنق زجاجة. وميزة عدم وجود رسوم حسب الاستخدام تعني، إذا نظرنا إليها من الجانب الآخر، أن التوسع يُغلَق بمجرد تجاوز الاستخدام للحد المسموح.

ومع ذلك، فإن الرسالة التي تطرحها `fable-advisor` واضحة. مستقبل وكلاء البرمجة لا يكمن في نموذج واحد شامل، بل في تنسيق يجمع بين النماذج الأنسب لكل طبقة. وهذا يشير بالضبط إلى نفس الوجهة التي تسلكها ThakiCloud في تعاملها مع الوكلاء المتعددين وتوجيه النماذج كمورد أساسي من الدرجة الأولى.

## المصادر

- [fable-advisor (GitHub)](https://github.com/DannyMac180/fable-advisor)
- [Grok CLI (x.ai/cli)](https://x.ai/cli)
