---
title: "ميتا-سكيل تتعامل مع المهارات 'كأنها برمجيات': تقرير تحقّق مباشر من yao-meta-skill v1.1.0"
excerpt: "قمنا باستنساخ أداة الميتا-سكيل مفتوحة المصدر yao-meta-skill — التي شاع أنها أقوى من Skill-creator الرسمية من Anthropic — مباشرةً في بيئة ThakiCloud وشغّلنا بوابات التحقّق المحلية. نفكّك بنية Skill IR وOutput Eval Lab وReview Studio 2.0 بأرقام مقيسة، ونلخّص الدلالات من منظور حوكمة .claude/skills الداخلية."
seo_title: "تقرير التحقّق من yao-meta-skill v1.1.0 - Thaki Cloud"
seo_description: "تقرير مقيس باستنساخ yao-meta-skill (YAO) والتحقّق منها مباشرةً. نفكّك تمثيل Skill IR المحايد للمنصّات وOutput Eval Lab وبوابات حوكمة Review Studio 2.0 على مقياس 632 ملفًّا و77 اختبارًا، ونطبّقها على تشغيل ThakiCloud .claude/skills."
date: 2026-06-21
last_modified_at: 2026-06-21
tags:
  - claude-skills
  - meta-skill
  - skill-governance
  - skill-ir
  - agent-skills
  - evaluation
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
categories:
  - dev
published: false
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/yao-meta-skill-engineering-governance/"
---

![صورة تجريدية لكتل وحدوية تُشكّل خط تجميع دقيقًا مع بوابات حوكمة متوهّجة]({{ '/assets/images/yao-meta-skill-hero.webp' | relative_url }})
*رسم مفاهيمي للميتا-سكيل التي تتعامل مع المهارة لا كموجّه لمرّة واحدة، بل كـ"أصل قابل لإعادة الاستخدام" مرفق بالإصدار والتحقّق والحوكمة.*

## نظرة عامة

في بيئات الوكلاء مثل Claude Code وCursor وCodex CLI، لم تعد المهارة (Skill) مجرّد مجموعة من الموجّهات. إنها أقرب إلى منتج قدرات يغلّف العمل المتكرّر لإعادة استخدامه عبر عدّة أُطُر تشغيل (harness). لكن كلّما تكاثرت المهارات، كبرت في الوقت نفسه ثلاث مشكلات: تباين الجودة، وتصادم المُحفِّزات (triggers)، وتكلفة السياق. ومشروع yao-meta-skill مفتوح المصدر — الذي صار حديث الناس بعد أن أوصى به المؤثّر الصيني @vista8 (نحو 113K متابع) بوصفه "أقوى من Skill-creator الرسمية من Anthropic" — يستهدف هذه النقطة بالذات.

اسم YAO اختصار لـ "Yielding AI Outcomes"، ويصف المستودع نفسه بأنه "نظام صارم للهندسة والتقييم والحوكمة وقابلية النقل لمهارات الوكلاء القابلة لإعادة الاستخدام". ولم آخذ هذا الادّعاء كما هو، بل استنسخته مباشرةً في بيئة عمل ThakiCloud ثم شغّلت فعليًّا بوابات التحقّق المحلية التي يوفّرها المستودع. هذا المقال تقرير تنفيذ يفكّك بنية yao-meta-skill انطلاقًا من تلك النتائج المقيسة، ويتأمّل ما يمكن استعارته من منظور تشغيل `.claude/skills` الداخلي.

## ما هي هذه الأداة

yao-meta-skill هي "مهارة تصنع مهارات"، أي ميتا-سكيل. تأخذ العمل المتكرّر — مثل ملاحظات سير العمل، ومجموعات الموجّهات، ونصوص المحادثات، وكتب التشغيل (runbooks)، وأنماط المستندات — مُدخَلًا، وتحوّله إلى حزمة مهارة قابلة للتحقّق. ويتلخّص تصميمها الجوهري في ثلاثة أعمدة.

أولًا، **Skill IR (التمثيل الوسيط — Intermediate Representation)**. تُوصَف أولًا النيّة والمُحفِّزات والمُدخَلات والمُخرَجات والحدود (boundaries) والمراجع والمخرجات المتوقّعة في تمثيل وسيط محايد للمنصّات. ثم تحوّل المُصرِّفات (compilers) والمحوّلات (adapters) المستهدفة هذا الـ IR إلى خمسة أهداف: OpenAI وClaude والمهارات العامة للوكلاء والحزم المتوافقة مع Agent-Skills وسير العمل الموجَّه نحو VS Code. وفكرة وصف المهارة مرّة واحدة وتصريفها إلى بيئات متعدّدة تستهدف بدقّة عبء إدارة المهارة نفسها مرّتين عبر Claude Code وCursor داخليًّا.

ثانيًا، **Output Eval Lab**. وهي طبقة تتحقّق من جودة مخرجات المهارة بالبيانات: فحص المُحفِّزات، وتأكيدات المخرجات (assertions)، وأدلّة التنفيذ، وأدلّة الزمن والرموز (tokens)، وقابلية إعادة إنتاج القياس المرجعي (benchmark)، وحُزَم المراجعة المُعمّاة. وما يلفت النظر أن البنية تجعل الكود يتحقّق فعليًّا، بدلًا من أن يدّعي النموذج "أن الأمر نجح".

ثالثًا، **Review Studio 2.0**. تجمع النيّة والمُحفِّزات وتقييم المخرجات وتكلفة السياق وفحوص وقت التشغيل وأدلّة الإصدار في صفحة بوابة HTML واحدة. إنها بوابة تُثبّت بصريًّا ما الذي يجب اجتيازه قبل إصدار أي مهارة.

الرخصة MIT، ويُعلن البيان الوصفي (manifest) درجة النضج بأنها "governed"، ومرحلة دورة الحياة بأنها "library"، ودورية المراجعة بأنها "quarterly". فالنيّة في إدارة المهارات كالكود — بالإصدارات والدرجات ودوريات المراجعة — تتجلّى من مستوى البيانات الوصفية نفسه.

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
<div class="d3-arch" data-arch-root id="illengineeringgovernance-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 240, "height": 738, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IN", "x": 28, "y": 24, "w": 177, "h": 46, "title": "مُدخل المهام المتكررة"}, {"id": "IR", "x": 56, "y": 148, "w": 120, "h": 46, "title": "Skill IR"}, {"id": "COMPILE", "x": 24, "y": 272, "w": 184, "h": 62, "title": ["المُجمِّع الهدف (متعدد", "المنصات)"]}, {"id": "EVAL", "x": 49, "y": 412, "w": 135, "h": 46, "title": "Output Eval Lab"}, {"id": "REVIEW", "x": 42, "y": 536, "w": 149, "h": 46, "title": "Review Studio 2.0"}, {"id": "REL", "x": 56, "y": 660, "w": 120, "h": 46, "title": "دليل الإصدار"}], "edges": [{"src": "IN", "dst": "IR", "kind": "data", "line": [116, 70, 116, 148]}, {"src": "IR", "dst": "COMPILE", "kind": "data", "line": [116, 194, 116, 272]}, {"src": "COMPILE", "dst": "EVAL", "kind": "data", "line": [116, 334, 116, 412]}, {"src": "EVAL", "dst": "REVIEW", "kind": "data", "line": [116, 458, 116, 536]}, {"src": "REVIEW", "dst": "REL", "kind": "data", "line": [116, 582, 116, 660]}]});
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
      const container = document.getElementById('illengineeringgovernance-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'illengineeringgovernance-1';
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
*خطّ معالجة تمرّ فيه مُدخَلات العمل المتكرّر عبر Skill IR، فتُصرَّف إلى منصّات متعدّدة، ثم تجتاز بوابتَي Output Eval Lab وReview Studio لتنتهي كأدلّة إصدار.*

## التثبيت والتكامل (أوامر حقيقية)

جرى التحقّق في صندوق رمل معزول. ووفقًا للقواعد الداخلية، وُضِعت شجرة العمل خارج المستودع وجرى تنظيفها بعد الانتهاء.

```bash
# 1) استنساخ المستودع الخارجي
git clone --depth 1 https://github.com/yaojingang/yao-meta-skill

# 2) تثبيت الاعتماد الأدنى في الـ .venv المشترك (قاعدة python-runtime)
VIRTUAL_ENV="$REPO_ROOT/.venv" uv pip install "PyYAML==6.0.3"
```

اعتماديات المستودع خفيفة على نحو مدهش. فمتطلّبات التكامل المستمر (`requirements-ci.txt`) كانت سطرًا واحدًا فقط: `PyYAML==6.0.3`. أي أن أدوات التحقّق مبنية حول مكتبة بايثون القياسية الخالصة بلا أُطُر تشغيل ثقيلة — وهذه إشارة جيّدة لإدراجها في خطّ تكامل مستمر.

والتركيب الفعلي الذي قِسته فور الاستنساخ كان كالآتي: 632 ملفًّا متتبَّعًا، و77 اختبارًا، و29 تقييمًا (evals)، و10 مدخلات في أطلس المهارات (skill_atlas)، و3 مخطّطات (schemas)، وقالبَين (templates). فهذه ليست "مهارة" واحدة، بل أقرب إلى مصنع صغير ينتج المهارات ويتحقّق منها ويحوكمها.

![مخطّط لتركيب مستودع yao-meta-skill ونتائج بوابات التحقّق المحلية]({{ '/assets/images/yao-meta-skill-results.webp' | relative_url }})
*إلى اليسار: التركيب المقيس للمستودع (مقياس لوغاريتمي). وإلى اليمين: اجتياز بوابات التحقّق المحلية الأربع جميعها.*

## نتائج التحقّق الفعلية

عرّف ملف `Makefile` أكثر من 25 هدف تحقّق. وقد شغّلت فعليًّا أربعة منها — Skill IR والمُصرِّف وتقييم المخرجات والتدقيق (lint) — وقَيّدت النتائج.

```bash
make skill-ir-check
# python3 tests/verify_skill_ir.py        -> {"ok": true}
# python3 tests/verify_skill_ir_paths.py  -> {"ok": true}

make compiler-check
# python3 tests/verify_compile_skill.py    -> {"ok": true}

make output-eval-check
# python3 tests/verify_output_eval_lab.py  -> {"ok": true}

python3 scripts/lint_skill.py ./   # مقابل ملف SKILL.md المُرفق
# {"ok": true, "failures": [], "warnings": []}
```

اجتازت البوابات الأربع جميعها بـ `ok: true`، وأبلغ التدقيق عن صفر إخفاقات وصفر تحذيرات. وهذه الأرقام قَيّدتها بتشغيلها بنفسي، لا باقتباس من مصدر خارجي. والمثير للاهتمام أن خرج التحقّق يأتي بصيغة JSON حتمية على هيئة `{"ok": true}` لا نصًّا إنشائيًّا. وهذه صيغة قابلة للقراءة الآلية تستطيع خطوط المعالجة الأعلى أن تبني عليها البوابات تلقائيًّا — وهو الاتجاه ذاته الذي يقوم عليه مبدأ ThakiCloud القائل إن "الصيغة يملكها الكود".

غير أن قيدًا واحدًا تكشّف أيضًا بالقياس. إذ أصدر `lint_skill.py` خطأ استخدام عند استدعائه بلا وسائط، واشترط تحديد دليل المهارة صراحةً. وأرجع سكربت قياس حجم السياق (`context_sizer.py`) تقديرًا للرموز قيمته 0 في بعض المسارات، وبدا حسّاسًا لطريقة تمرير الوسائط. أي إن التنبيه التشغيلي هو: "أهداف make تعمل جيّدًا، لكن استدعاء السكربتات الفردية مباشرةً يتطلّب مطابقة الواجهة بدقّة".

## التطبيق والدلالات لمنصّة ThakiCloud K8s AI/ML SaaS

تشغّل ThakiCloud بالفعل أكثر من ألف مهارة وقاعدة داخلية. وعند هذا الحجم، فإن أكبر تكلفة ليست المهارات نفسها، بل ضريبة السياق التي تدفعها كل مهارة مُفهرَسة في كل جلسة، إضافةً إلى تصادم المُحفِّزات. وتتلخّص النقاط الجديرة بالاستعارة من yao-meta-skill في ثلاث.

أولًا، **التبنّي الجزئي لفكرة Skill IR**. فبدلًا من إدارة المهارات الداخلية مرّتين عبر Claude Code وCursor، يقلّل وصف النيّة والمُحفِّزات والحدود وصفًا محايدًا مرّة واحدة ثم التصريف لكل بيئة من سطح الإدارة. وقد يكون التبنّي الكامل مبالغًا فيه، لكن بنينة وصف (description) المهارات الجديدة ومُحفِّزاتها كأنها مخطّط IR تفيد وحدها.

ثانيًا، **استعارة بوابات على نمط Output Eval Lab**. فلدينا داخليًّا بالفعل بوابات تحرير وسكربتات تحقّق حتمية، لكن تقييم المُحفِّزات — أي الفحص بالبيانات عمّا إذا كان المُحفِّز يُطلَق كما هو مقصود — ضعيف نسبيًّا. وهذا نمط قابل للاستخدام المباشر لتقليل ضوضاء المشتّتات (distractor noise) في موجّه المهارات.

ثالثًا، **بوابة إصدار واحدة على نمط Review Studio**. فبوابة تؤكّد النيّة والمُحفِّزات وتكلفة السياق ووقت التشغيل في صفحة واحدة قبل دمج مهارة جديدة، متماثلة فلسفيًّا مع بوابات النشر (ArgoCD وKueue) لمنصّة AI/ML SaaS العاملة فوق K8s. فكما نضع بوابة على نشر الكود، نضع بوابة على نشر المهارة.

## القيود والحجج المضادة

تفاديًا للتلخيص المتفائل وحده، أُسجّل الحجج المضادة بوضوح.

أولًا، **مصدر ادّعاء "أقوى من الرسمية" هو توصية مؤثّر**. صحيح أن بنية المستودع والتحقّق المحلي متينان، لكن Skill-creator الرسمية من Anthropic تمتاز بحلقات إنشاء سريعة تبدأ بالمحادثة، وهذا غرض مختلف. والأداتان متكاملتان لا متنافستان. ومقارنة "الأقوى" تكون دقيقة فقط حين تُحصَر ببناء أصول فِرَق تحتاج إلى حوكمة.

ثانيًا، **تكلفة التبنّي**. فإدخال مصنع بحجم 632 ملفًّا كما هو مبالغة لفرد واحد أو فريق صغير. والمسار الواقعي هو الاستعارة الانتقائية للأفكار الجوهرية (IR، تقييم المُحفِّزات، البوابة الواحدة).

ثالثًا، **حسّاسية الواجهة التشغيلية**. فكما تأكّد بالقياس سابقًا، كانت السكربتات الفردية حسّاسة للوسائط وأرجع بعض القياسات قيمة 0. وعند الإدراج في التكامل المستمر، يُغلَّف الأمر على مستوى أهداف make وتُثبَّت واجهات السكربتات الفردية.

في الختام، تُعدّ yao-meta-skill من أكثر الأمثلة مفتوحة المصدر تجسيدًا ملموسًا لاتّجاه "هندسة المهارات كأنها برمجيات". وحتى من دون تبنّيها بالكامل، فإن أي منظّمة تصير فيها المهارات أصولًا ستجد مبادئ تصميمها جديرةً بالدراسة.

## المصادر

- yao-meta-skill (GitHub, MIT): [github.com/yaojingang/yao-meta-skill](https://github.com/yaojingang/yao-meta-skill)
- البيان الوصفي للمستودع ونتائج التحقّق: جميع الأرقام في هذا المقال مقيسة محليًّا باستنساخ v1.1.0.
