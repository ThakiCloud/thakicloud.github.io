---
title: "تشريح عناقيد GPU وTPU: كيف يحدد الاتصال الجماعي سرعة التدريب الموزع"
excerpt: "عند تدريب أو تقديم نموذج كبير موزّع على عدة مسرّعات، لا تكون عملية الحساب هي عنق الزجاجة الحقيقي، بل البيانات المتنقلة بين المسرّعات. يشرح هذا المقال ماهية العمليات الجماعية (collective operations) مثل all-reduce وall-gather وreduce-scatter وall-to-all، وكيف تعمل هذه العمليات فوق بنيتين فيزيائيتين مختلفتين تماماً: عناقيد GPU (عبر NVLink وNVSwitch وInfiniBand) وعناقيد TPU (عبر توروس ICI ثلاثي الأبعاد ومفاتيح الدارة الضوئية). من معادلة تكلفة عرض النطاق الترددي في ring all-reduce إلى العمليات الجماعية التي يستدعيها كل من التوازي البياني والتنسوري وخطوط الأنابيب والتوازي على مستوى الخبراء، يتناول المقال هذه الموضوعات من منظور ThakiCloud القائم على تشغيل بنية تحتية لوحدات GPU."
tags:
  - dev
  - distributed-training
  - gpu
  - tpu
  - nccl
  - nvlink
  - infiniband
  - kubernetes
  - self-hosting
  - paxis
date: 2026-07-15
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/collective-communication-clusters/"
categories:
  - dev
---

## نظرة عامة

لقد مضى وقت طويل منذ أن كان من الممكن وضع نموذج لغوي كبير على GPU واحد. فالنماذج التي تحتوي على عشرات المليارات إلى تريليونات المعاملات (parameters) تُقسّم على عشرات إلى آلاف المسرّعات (accelerators)، وفي كل خطوة تدريب يجب على هذه المسرّعات أن توائم نتائجها مع بعضها البعض. هذه العملية من "المواءمة المتبادلة" هي بالضبط ما يُعرف بالاتصال الجماعي (collective communication)، والنقطة التي تستهلك الوقت فعلياً في التدريب الموزع الحديث غالباً ما تكون هذا الاتصال وليست عمليات ضرب المصفوفات.

هذا المقال موجّه لمهندسي البنية التحتية الذين يدرّبون أو يقدّمون النماذج على عناقيد GPU أو TPU، ولمن يتحمل مسؤولية تكلفة التقديم (serving) وقابلية التوسع. ننطلق من التحليل المعمّق الشهير الذي كتبه Aleksa Gordić بعنوان "Inside TPU and GPU Clusters: The Anatomy of Collective Communication"، ونعيد التحقق من المفاهيم الأساسية التي يتناولها بالرجوع إلى مراجع قياسية (مثل NCCL وورقة TPU v4).

نبدأ برسالة أساسية موجزة. أولاً، يمكن اختزال أداء التدريب الموزع في عدد قليل من عمليات الاتصال الجماعي. ثانياً، حتى العملية نفسها تختلف تكلفتها اختلافاً جذرياً بحسب البنية الطوبولوجية الفيزيائية التي تعمل عليها (بنية NVIDIA القائمة على المفاتيح switch مقابل بنية Google القائمة على التوروس). ثالثاً، استراتيجية التوازي (parallelism) المُختارة هي التي تحدد أي عملية جماعية تُستدعى ومدى تكرارها. وفهم هذه العناصر الثلاثة يوضح لماذا يؤثر مكان وكيفية توزيع عدد من وحدات GPU تأثيراً كبيراً على الأداء.

## ما هو الاتصال الجماعي؟

العملية الجماعية هي نمط اتصال يشارك فيه عدد من العمليات (غالباً واحدة لكل مسرّع) معاً. فإذا كان الاتصال من نقطة إلى نقطة (P2P) هو أن يرسل طرف واحد بيانات إلى طرف آخر، فإن العملية الجماعية تعني أن المجموعة بأكملها تقسّم البيانات وتجمعها وفق قاعدة محددة. وفيما يلي أبرز العمليات التي تتكرر في التدريب الموزع.

- **All-reduce**: يقوم جميع المشاركين بجمع (أو أخذ متوسط) التنسور (tensor) الذي يملكه كل منهم عنصراً بعنصر، ثم تُعاد النتيجة إلى الجميع. وهذه هي العملية المستخدمة تحديداً لمواءمة التدرجات (gradients) في التدريب الموازي للبيانات (data parallel).
- **Reduce-scatter**: يُحسب المجموع، لكن النتيجة لا يحتفظ بها طرف واحد بالكامل، بل تُقسّم إلى أجزاء يوزَّع كل جزء منها على طرف مختلف.
- **All-gather**: تُجمع الأجزاء التي يملكها كل طرف بحيث يحصل الجميع على النسخة الكاملة. وهي العملية المقابلة لـ reduce-scatter، وعند ضمهما معاً ينتج all-reduce.
- **All-to-all**: يرسل كل مشارك جزءاً مختلفاً من البيانات إلى كل واحد من المشاركين الآخرين. وهو نمط أقرب إلى النقل المقلوب (transpose)، وهو محوري في تمرير الرموز (tokens) إلى الخبراء (experts) في نماذج مزيج الخبراء (Mixture of Experts, MoE).
- **Broadcast / Reduce**: عمليتان أحادّيتا الاتجاه، إما أن يبثّ طرف واحد نفس البيانات للجميع، أو أن تُجمَع بيانات الجميع وتُختزل عند طرف واحد.

هناك ملاحظة مهمة هنا وهي أن all-reduce ليست عملية ذرية (atomic) بحد ذاتها. فهي تتحلل إلى **reduce-scatter يليها all-gather**. وهذا التحلل هو الأساس الذي تُبنى عليه معادلة التكلفة التي سنتناولها لاحقاً.

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
<div class="d3-arch" data-arch-root id="ivecommunicationclusters-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 694, "height": 538, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 246, "y": 24, "w": 205, "h": 46, "title": "كل مسرّع: تدرج/تنسور محلي"}, {"id": "B", "x": 467, "y": 148, "w": 177, "h": 78, "title": ["Reduce-scatter", "توزيع المجموع على شكل", "أجزاء"]}, {"id": "C", "x": 450, "y": 304, "w": 212, "h": 62, "title": ["All-gather", "استعادة الأجزاء لدى الجميع"]}, {"id": "D", "x": 453, "y": 444, "w": 205, "h": 62, "title": ["اكتمال All-reduce", "يمتلك الجميع المجموع نفسه"]}, {"id": "E", "x": 284, "y": 156, "w": 128, "h": 62, "title": ["All-to-all", "توجيه رموز MoE"]}, {"id": "F", "x": 24, "y": 156, "w": 205, "h": 62, "title": ["Broadcast/Reduce", "توزيع/تجميع أحادي الاتجاه"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[425, 70], [556, 109], [556, 109], [556, 148]]}, {"src": "B", "dst": "C", "kind": "data", "line": [556, 226, 556, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [556, 366, 556, 444]}, {"src": "A", "dst": "E", "kind": "data", "line": [348, 70, 348, 156]}, {"src": "A", "dst": "F", "kind": "data", "curve": [[266, 70], [127, 109], [127, 109], [127, 156]]}]});
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
      const container = document.getElementById('ivecommunicationclusters-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ivecommunicationclusters-1';
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

## البنية الفيزيائية لعناقيد GPU

يسهل فهم عناقيد NVIDIA إذا نظرنا إليها كطبقتين: داخل العقدة (node) الواحدة (scale-up)، وبين العقد (scale-out).

داخل العقدة، تربط **NVLink** و**NVSwitch** وحدات GPU ببعضها بكثافة عالية. فوحدات GPU الثماني مثلاً الموجودة داخل خادم واحد تُربط عبر NVSwitch بشكل شبه متصل بالكامل (fully connected)، بحيث يتواصل أي GPU مع أي GPU آخر بعرض نطاق ترددي (bandwidth) عالٍ وموحّد. وهذا هو سبب حصر الأعمال التي تتطلب اتصالاً متكرراً جداً، مثل التوازي التنسوري (tensor parallelism)، داخل هذا النطاق.

أما بين العقد، فتُستخدم شبكة من نوع ورقة الشجرة السمينة (leaf-spine / fat-tree) مبنية على **InfiniBand** أو **RoCE** (RDMA over Converged Ethernet). وهذه النسيجة الموسّعة (scale-out fabric) تربط وحدات GPU عبر الرفوف (racks) والخوادم. ومن التصاميم الشائعة هنا الطوبولوجيا المحسّنة بالمسارات (rail-optimized)، حيث يُربط منفذ الشبكة (NIC) بنفس الترتيب في كل عقدة بنفس المفتاح ("المسار" أو rail)، بحيث تمر عملية all-reduce بين العقد بأقل قدر ممكن من طبقة العمود الفقري (spine).

وهذه المرونة لها ثمن. فآلاف المفاتيح (switches) اللازمة للتوسع الأفقي (scale-out) تستهلك ما يقارب 5 إلى 10 بالمئة من إجمالي طاقة العنقود [تقديري وقد يختلف بحسب التهيئة]، وتتطلب نفقات رأسمالية كبيرة. أي أن نهج NVIDIA، بدلاً من الاكتفاء بجعل "أي GPU يتواصل جيداً مع أي GPU آخر"، يشتري هذا التجانس عبر مفاتيح تعالج الحزم (packets) بشكل فعّال.

## الخيار المختلف لعناقيد TPU

تسلك Google في وحدات TPU مساراً مختلفاً تماماً. فبدلاً من نسيجة مفاتيح فعّالة، تُربط شرائح TPU مباشرة بجاراتها عبر رابط عالي السرعة مخصص يُسمى **ICI** (Inter-Chip Interconnect). في الجيل الأحدث، تمتد روابط ICI من كل شريحة في ست اتجاهات (X موجب، X سالب، Y موجب، Y سالب، Z موجب، Z سالب) لتشكّل شبكة **توروس ثلاثي الأبعاد (3D torus)** (أما الأجيال الأولى فكانت تستخدم توروس ثنائي الأبعاد لتشكيل "pod" بسعة 256 شريحة). وبما أن الاتصال يتم مباشرة مع الجيران فقط، فإن طبقة المفاتيح تختفي في معظمها.

يبقى سؤال: كيف تُربط الشرائح البعيدة عن بعضها، أو ما هو أكبر من حجم الـ pod؟ هنا يظهر **مفتاح الدارة الضوئية (OCS, Optical Circuit Switch)**. وبحسب ورقة TPU v4 البحثية، يعمل OCS عبر إعادة توجيه ألياف ضوئية باستخدام مرايا MEMS، أي أنه لا يفسّر الإشارة الضوئية بشكل فعّال بل يكتفي بعكسها. وبفضل ذلك يمكن ربط ما يصل إلى 4096 شريحة بطريقة قابلة لإعادة التشكيل، بينما لا يستهلك سوى طاقة قليلة جداً مقارنة بمفاتيح InfiniBand، لأن الطاقة تُستخدم فقط للحفاظ على اتجاه المرايا. كما يمكن لف أحد محاور التوروس ضوئياً، أو إعادة توجيه الطوبولوجيا برمجياً لتجاوز عقدة معطوبة.

باختصار، تستثمر عناقيد GPU في مفاتيح فعّالة من أجل وصول موحّد، بينما تعتمد عناقيد TPU على توروس متصل مباشرة بالجيران مع إعادة تشكيل ضوئية لتوفير الطاقة والتكلفة. ولا يتفوق أي من الخيارين على الآخر بشكل مطلق. فالتوروس مثالي للاتصال مع الجيران لكنه يحتاج قفزات (hops) أكثر للاتصال البعيد العشوائي، بينما نسيجة المفاتيح موحّدة لكنها مكلفة وتستهلك طاقة أكبر.

## كيف تُترجم العمليات الجماعية إلى استراتيجيات التوازي

أي عملية جماعية تُستدعى وبأي وتيرة، يتحدد في النهاية بنوع التوازي المُستخدم.

- **التوازي البياني (Data Parallel, DP)**: تعالج كل نسخة (replica) دفعة (batch) مختلفة، ثم تُوائَم التدرجات عبر **all-reduce**. وحجم الاتصال يتناسب مع حجم النموذج ويحدث مرة واحدة في كل خطوة.
- **التوازي البياني الكامل التشظّي (FSDP/ZeRO)**: تُقسّم المعاملات (parameters) إلى أجزاء توزَّع بين المسرّعات، ثم قبل التمرير الأمامي (forward pass) مباشرة تُجمع المعاملات اللازمة عبر **all-gather**، وبعد التمرير الخلفي (backward pass) تُعاد تشظية التدرجات عبر **reduce-scatter**. توفر هذه الطريقة الذاكرة لكنها تزيد من تكرار الاتصال.
- **التوازي التنسوري (Tensor Parallel, TP)**: تُقسَّم عملية طبقة واحدة على عدة وحدات GPU، وعند حدود كل طبقة تُدمج النتائج عبر **all-reduce** أو من خلال all-gather/reduce-scatter. والاتصال هنا متكرر للغاية، لذا يكاد يكون حصره داخل نطاق NVLink المذكور سابقاً أمراً ضرورياً.
- **التوازي عبر خطوط الأنابيب (Pipeline Parallel, PP)**: يُقسَّم النموذج على مستوى الطبقات وتُوزَّع على وحدات GPU مختلفة، وتُنقل القيم المفعّلة (activations) بين المراحل غالباً عبر اتصال **P2P**. وهنا يسود الاتصال من نقطة إلى نقطة بدلاً من العمليات الجماعية.
- **التوازي على مستوى الخبراء (Expert Parallel, EP/MoE)**: يجب إرسال الرموز (tokens) إلى المسرّع الذي يستضيف الخبير المعني، لذا فإن **all-to-all** هو جوهر هذا النوع. وعدد أزواج الاتصال في all-to-all يزداد تربيعياً مع زيادة عدد المشاركين، ما يجعله حساساً بشكل خاص للطوبولوجيا.

في الممارسة العملية تُستخدم هذه الأنواع مجتمعة. فمثلاً يُصمَّم التوزيع بحيث يُوضع TP داخل نطاق NVLink في العقدة الواحدة، وتُنقل عمليات all-reduce الخاصة بـ DP عبر InfiniBand بين العقد، ويربط PP بين هذه الأجزاء. وإذا أُسيء التوزيع، فقد يتسرب اتصال التوازي التنسوري المتكرر إلى رابط أبطأ بين العقد، مما يبطئ التدريب بأكمله.

## القاعدة التي تحكم الأداء: الحلقة والشجرة

توجد خوارزميات متعددة لتنفيذ العمليات الجماعية فعلياً، لكن الأشهر من منظور عرض النطاق الترددي هي **all-reduce الحلقي (ring all-reduce)**. حيث يُربط المشاركون في شكل دائري واحد، وفي كل خطوة يُرسل كل طرف جزءه إلى الجار التالي، وتُنفَّذ عمليتا reduce-scatter وall-gather كل منهما عبر N-1 خطوة.

ومن المعروف أن إجمالي حجم البيانات التي يحملها كل رابط يُحسب تقريباً على النحو التالي. عند تنفيذ all-reduce لتنسور بحجم S عبر N مشارك، تكون حركة المرور لكل رابط تقريباً

```
2 × (N − 1) / N × S
```

وذلك لأن (N−1)/N × S تتدفق في مرحلة reduce-scatter، ومثلها مرة أخرى في مرحلة all-gather. والخاصية المهمة هنا أن (N−1)/N تقترب من 1 كلما كبر N، أي أن حركة المرور لكل رابط تستقر عند نحو 2S تقريباً. لهذا السبب يُوصف ring all-reduce بأنه أمثل من حيث عرض النطاق الترددي (bandwidth-optimal)، وهو ما استخدمته مكتبات مثل NCCL وGloo لفترة طويلة.

المشكلة تكمن في زمن الوصول (latency). فالحلقة تمر عبر N−1 خطوة بشكل متسلسل، لذا فإن زمن الوصول الثابت (α) المرتبط بكل خطوة يتراكم بما يتناسب مع عدد المشاركين. فإذا نفّذت أعداد كبيرة جداً من العقد عملية all-reduce على تنسور صغير، يتبقى عرض النطاق الترددي فائضاً بينما يصبح زمن الوصول هو عنق الزجاجة. لهذا السبب تختار المكتبات الفعلية تلقائياً بين خوارزميات الحلقة والشجرة (أو الهرمية) بحسب حجم التنسور وعدد العقد. فطريقة الشجرة تقلّل زمن الوصول ليقترب من log(N)، لكنها تتنازل عن جزء من كفاءة عرض النطاق الترددي. وهذا هو سبب اختيار NCCL خوارزميات مختلفة بحسب حجم الرسالة.

والدلالة العملية لهذه القاعدة واضحة: عند تغيير حجم الدفعة (batch)، أو حجم النموذج، أو عدد العقد، ينتقل عنق الزجاجة المهيمن بين عرض النطاق الترددي وزمن الوصول. ولهذا لا يمكن الافتراض، من دون قياس فعلي، أن "مضاعفة عدد العقد يعني مضاعفة السرعة".

## دلالات تطبيقية على منتجات ThakiCloud

هذا الموضوع يلامس جوهر البنية التحتية، وهو ذو أهمية عملية خاصة من منظور **ai-platform** التابعة لـ ThakiCloud (بنية تحتية لـ AI/ML كخدمة SaaS قائمة على K8s).

أولاً، **الجدولة الواعية بالطوبولوجيا (topology-aware scheduling)**. تستخدم ai-platform أداة Kueue لجدولة أعباء عمل GPU، ومبدأ التوزيع الذي يضع مهام التوازي التنسوري داخل نطاق NVLink نفسه (أي العقدة نفسها)، ويوجّه عمليات all-reduce الخاصة بالتوازي البياني عبر روابط بين العقد محسّنة بالمسارات (rail-optimized)، يتطابق تماماً مع خصائص الاتصال الجماعي التي عرضناها في هذا المقال. فمعرفة أي عملية جماعية تسري عبر أي رابط هي ما يجعل توزيع المهام يُترجَم فعلياً إلى أداء.

ثانياً، **التوازي التنسوري في التقديم (serving)**. عند تقديم نموذج كبير عبر عدة وحدات GPU بتوازٍ تنسوري باستخدام محرّك مثل vLLM، تحدث عملية all-reduce في كل طبقة. وإذا وُزِّعت الحاويات (pods) بحيث يبقى هذا الاتصال داخل نطاق NVLink، يسهل الحفاظ على هدف زمن الوصول، أما إذا تجاوز حدود العقدة فإن زمن الوصول لكل رمز (token) يزداد بشكل ملحوظ. وفي بيئة متعددة المستأجرين (multi-tenant)، ينعكس هذا الانضباط في التوزيع مباشرة على تكلفة التقديم واتفاقيات مستوى الخدمة (SLA).

ثالثاً، **جدوى التكلفة في السحابة المحلية والسيادية (on-prem/sovereign cloud)**. حقيقة أن مفاتيح شبكة GPU تستهلك حصة كبيرة من الطاقة تعني أنه عند تصميم عنقود في بيئة داخلية أو سيادية محلية، لا تُعد الشبكة عنصراً ثانوياً، بل متغيراً محورياً في إجمالي تكلفة الملكية (TCO). والاستضافة الذاتية (self-hosting) وكفاءة التكلفة التي تسعى إليها ThakiCloud لا تقوم إلا على قرارات تصميم شبكي من هذا النوع.

وهناك أيضاً نقطة تقاطع مع منتج تنسيق الوكلاء (agent orchestration) **Paxis**. ففي سياق تنسيق مهام التدريب الموزع والاستدلال (inference) الكبير عبر رسم بياني موجّه غير دوري (DAG) وتنفيذها بعزل، فإن فهم البروفايل الاتصالي لكل عملية جماعية تستدعيها كل مرحلة يتيح تصميماً أدق لحجز الموارد وبوابات السياسات. لكن ثقل هذا المقال ينصبّ على طبقة البنية التحتية، لذا يبقى منظور ai-platform هو المحور الرئيسي.

## القيود والاعتراضات

هذا الطرح ليس بلا اعتراضات. أولاً، توفّر أطر العمل تجريداً (abstraction) كبيراً للعمليات الجماعية. فعند استخدام واجهات برمجة عليا مثل PyTorch أو JAX، تتم معظم قرارات التوزيع تلقائياً داخل المكتبة والمجدول (scheduler)، ولا يحتاج مطوّر التطبيق لمعرفة هذه التفاصيل. وعليه، فإن السؤال "هل يجب على كل فريق أن يعرف معادلات التوروس والحلقة؟" يكون جوابه أقرب إلى لا.

غير أن هذا التجريد ينهار في اللحظة التي يصبح فيها الأداء مشكلة. فعندما يكون التدريب أبطأ من المتوقع أو يتذبذب زمن وصول التقديم، فإن إيجاد السبب يتطلب في النهاية معرفة أي عملية جماعية تسري عبر أي رابط. فالتجريد مريح على المسار الطبيعي، لكنه يتحول إلى تجريد "متسرّب" (leaky abstraction) عند تشخيص عنق الزجاجة.

كما أن القواعد التي عرضها هذا المقال تتغير باستمرار مع كل جيل من الأجهزة. فعرض النطاق الترددي لـ NVLink وInfiniBand، وعدد روابط ICI في TPU، وحجم OCS، تختلف من جيل إلى آخر، لذا يجب دائماً التحقق من الأرقام الدقيقة عبر المصادر الرسمية الخاصة بكل جيل. توفر معادلات هذا المقال وبنيته إطاراً للتفكير، لكن القرار الإنتاجي يجب أن يُحسم عبر قياسات فعلية (benchmark). وأخيراً، تبقى الفجوة بين البرمجيات والأجهزة واقعاً قائماً، فحتى الطوبولوجيا المثلى نظرياً تصبح عديمة الجدوى إذا لم تستطع النواة (kernel) ومكتبة الاتصال استغلالها بالكامل.

## المصادر

- Aleksa Gordić، "Inside TPU and GPU Clusters: The Anatomy of Collective Communication": https://www.aleksagordic.com/blog/collective-operations
- وثائق NVIDIA NCCL ونموذج تكلفة اتصال ring all-reduce (reduce-scatter + all-gather، الأمثلية من حيث عرض النطاق الترددي)
- ورقة Google TPU v4 البحثية، "TPU v4: An Optically Reconfigurable Supercomputer for Machine Learning with Hardware Support for Embeddings" (توروس ICI ثلاثي الأبعاد، OCS): https://arxiv.org/abs/2304.01433
