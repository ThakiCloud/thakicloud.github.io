---
title: "مهارات الوكيل الموثَّقة من NVIDIA: كيف تُضفي ثقةً على سلسلة توريد المهارات بتوقيع OMS"
excerpt: "أتاحت NVIDIA أكثر من 200 مهارة وكيل بوصفها مصدراً مفتوحاً مصحوبةً بتوقيعات تشفيرية عبر OMS. يعمل ملف SKILL.md ذاته عبر Claude Code وCodex وCursor، ويستطيع أي شخص التحقق من أن المهارة التي نزّلها لم تُعبَث بها. نُجري هنا اختباراً عملياً: نستنسخ المستودع، ونتحقق من التوقيع، ثم نُعدِّل سطراً واحداً لنرى ما إذا كانت آلية كشف التلاعب تعمل فعلاً، ونستخلص دلالات ذلك على عمليات مهارات ThakiCloud."
seo_title: "مهارات الوكيل الموثَّقة من NVIDIA وتوقيع OMS - ثقة سلسلة توريد المهارات - Thaki Cloud"
seo_description: "نستعرض خط أنابيب التحقق ذا الثماني مراحل لـ NVIDIA Verified Agent Skills، والتوقيع المنفصل (detached) المستند إلى OpenSSF Model Signing (OMS)، وفحص الأمان بـ SkillSpector، ونُجري الاختبار بأنفسنا. نقيس 226 مهارة و237 توقيعاً، ونُعيد إنتاج التحقق من التوقيع وكشف التلاعب عبر model_signing، ونستخلص ما يعنيه ذلك لحوكمة المهارات على منصة ThakiCloud للذكاء الاصطناعي/تعلم الآلة القائمة على Kubernetes."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - agentic
  - agent-skills
  - supply-chain-security
  - nvidia
  - claude-code
  - governance
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "shield-alt"
toc_sticky: true
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/nvidia-verified-agent-skills/"
reading_time: true
categories:
  - agentops
published: false
---

![صورة تجريدية لكتل مهارات نمطية يحمل كل منها ختم تشفيري يربطها في سلسلة ثقة]({{ '/assets/images/nvidia-verified-agent-skills-hero.webp' | relative_url }})

## نظرة عامة

باتت مهارات الوكيل مكوِّناً معيارياً في سرعة متصاعدة. يكفي أن تُدوِّن في ملف SKILL.md طريقة استخدام الأدوات والإجراءات المطلوبة، فيقرأ وكيل البرمجة تلك التعليمات وينفِّذ المهمة. المشكلة تبدأ بعد ذلك: لم تكن ثمة وسيلة واضحة للتحقق من هوية من صنع المهارة التي حصلت عليها من الإنترنت، أو من خلوِّها من شيفرة خطيرة، أو من أن أحداً لم يُعدِّلها بعد تنزيلها. والمهارات في نهاية المطاف تعليمات تمنح الوكيل صلاحيات وأفعالاً، فتشغيل مهارات مجهولة المصدر في بيئة الإنتاج ينطوي على مخاطر أكبر مما يبدو.

جاءت NVIDIA لتسدَّ هذه الثغرة بإطلاق مهارات الوكيل الموثَّقة (NVIDIA Verified Agent Skills). يرتكز الإطار على ركيزتين: إرفاق توقيع تشفيري بكل مهارة يُتيح التحقق من سلامتها ومصدرها حتى بعد التنزيل، وإخضاع كل مهارة قبل نشرها لفحص أمني وتوثيق بطاقة مهارة. فضلاً عن ذلك، تتَّبع هذه المهارات مواصفة agentskills.io المفتوحة، مما يعني أن ملف SKILL.md ذاته مُصمَّم للعمل عبر أدوات مختلفة كـ Claude Code وCodex وCursor.

تُشغِّل ThakiCloud منصة SaaS للذكاء الاصطناعي وتعلم الآلة قائمة على Kubernetes، وتُدير داخلياً مئات المهارات ومهام الوكيل الذاتية. لذلك فإن سؤال "كيف نثق بالمهارة؟" ليس لدينا تساؤلاً أكاديمياً، بل تحدياً تشغيلياً يومياً. في هذا المقال نستنسخ المستودع الذي أتاحته NVIDIA، ونتحقق من التوقيعات، ونُضيف سطراً واحداً لنرى ما إذا كان كشف التلاعب يعمل فعلاً، ثم نستخلص ما يُغيِّره هذا البناء لمن يُشغِّل منصة وكيل متعددة المستأجرين.

## ما هذه التقنية

مهارات وكيل NVIDIA عبارة عن حزم تعليمات قابلة للنقل تُرشد الوكيل إلى الاستخدام الصحيح لمكتبات CUDA-X وخرائط Blueprint للذكاء الاصطناعي وأدوات المنصة. كلمة "موثَّقة (verified)" هنا ذات معنى محدد: مُدرَجة في الكتالوج، وخضعت لفحص أمني، ومُزوَّدة بتوقيع تشفيري، وموثَّقة ببطاقة مهارة. التمييز الجوهري عن السجلات التقليدية هو القدرة على التحقق من المخرج ذاته لا الاكتفاء بقرينة "نشره ناشر موثوق".

تمر المهارة بثماني مراحل للتحقق: من المستودع المصدر إلى المراجعة والفحص والتقييم وإنشاء البطاقة والتوقيع والإدراج في الكتالوج والمزامنة. يتزامن هذا الخط يومياً، ولا تنتقل المهارة إلى المرحلة التالية إلا بعد اجتياز السابقة.

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
<div class="d3-arch" data-arch-root id="vidiaverifiedagentskills-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 1300, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 104, "y": 24, "w": 135, "h": 46, "title": "المستودع المصدر"}, {"id": "B", "x": 112, "y": 148, "w": 120, "h": 46, "title": "المراجعة"}, {"id": "C", "x": 112, "y": 272, "w": 120, "h": 62, "title": ["الفحص الأمني", "SkillSpector"]}, {"id": "D", "x": 112, "y": 412, "w": 120, "h": 46, "title": "التقييم"}, {"id": "E", "x": 111, "y": 536, "w": 121, "h": 46, "title": "بطاقة المهارة"}, {"id": "F", "x": 112, "y": 660, "w": 120, "h": 46, "title": "توقيع OMS"}, {"id": "G", "x": 90, "y": 784, "w": 163, "h": 46, "title": "الإدراج في الكتالوج"}, {"id": "H", "x": 101, "y": 908, "w": 142, "h": 46, "title": "المزامنة اليومية"}, {"id": "V", "x": 88, "y": 1046, "w": 167, "h": 68, "title": ["التحقق من التوقيع", "model_signing"]}, {"id": "OK", "x": 199, "y": 1206, "w": 120, "h": 62, "title": ["تم التحقق", "يستمر النشر"]}, {"id": "NG", "x": 24, "y": 1206, "w": 120, "h": 62, "title": ["رُصد تلاعب", "حُظر النشر"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [172, 70, 172, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [172, 194, 172, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [172, 334, 172, 412]}, {"src": "D", "dst": "E", "kind": "data", "line": [172, 458, 172, 536]}, {"src": "E", "dst": "F", "kind": "data", "line": [172, 582, 172, 660]}, {"src": "F", "dst": "G", "kind": "data", "line": [172, 706, 172, 784]}, {"src": "G", "dst": "H", "kind": "data", "line": [172, 830, 172, 908]}, {"src": "H", "dst": "V", "kind": "event", "label": "تنزيل", "line": [172, 954, 172, 1046], "lx": 172, "ly": 996}, {"src": "V", "dst": "OK", "kind": "data", "label": "تطابق التجزئة", "curve": [[209, 1114], [259, 1160], [259, 1160], [259, 1206]], "off": "50%"}, {"src": "V", "dst": "NG", "kind": "data", "label": "عدم تطابق", "curve": [[134, 1114], [84, 1160], [84, 1160], [84, 1206]], "off": "50%"}]});
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
      const container = document.getElementById('vidiaverifiedagentskills-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'vidiaverifiedagentskills-1';
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
*خط أنابيب التحقق ذو الثماني مراحل من NVIDIA وتدفق التحقق من التوقيع بعد التنزيل. انقر المخطط لتكبيره.*

يستند هذا البناء إلى ثلاثة محاور.

**المحور الأول: التوقيع.** اعتمدت NVIDIA تنسيق OpenSSF Model Signing (OMS) لتوزيع ملف توقيع منفصل `skill.oms.sig` مع كل مهارة. يشمل هذا التوقيع جميع الملفات والمجلدات الفرعية داخل مجلد المهارة، أي أنه يضمن سلامة شجرة المجلد بأكملها لا ملفاً بعينه. OMS امتداد لحزم Sigstore يُتيح التحقق على مستوى المجلد.

**المحور الثاني: الفحص الأمني.** قبل النشر، تمر كل مهارة عبر SkillSpector الذي يتحقق من الاعتمادات الضعيفة والسكريبتات المريبة وأنماط الشيفرة الخطيرة والوصول إلى بيانات الاعتماد ومسارات تسريب البيانات، وهي مخاطر البرمجيات التقليدية. لكنه يتجاوز ذلك ليتناول مخاطر الوكيل الخاصة: التعليمات المخفية وحقن المطالبات وإساءة استخدام المشغِّلات والصلاحيات المفرطة وتلوُّث الأدوات والتناقض بين الغرض المُعلَن للمهارة والصلاحيات التي تطلبها والسلوكيات المُجمَّعة معها. قد تبدو المهارة بريئة على مستوى الملفات، لكنها قادرة على توجيه الوكيل نحو أفعال خطيرة، ولذلك يبقى فحص طبقة النية أمراً بالغ الأهمية. يستند نطاق فحص SkillSpector إلى دليل OWASP لمخاطر تطبيقات LLM ودليل مخاطر الذكاء الاصطناعي الوكيل.

**المحور الثالث: بطاقة المهارة.** يُرافق كل مهارة موثَّقة سجل ثقة قابل للقراءة آلياً يتضمن: ما تفعله المهارة، ومن أنشأها، وترخيصها، واعتمادياتها، والمخاطر التقنية المعروفة وحدودها وإجراءات التخفيف. يستطيع المطور بقراءة هذه البطاقة تحديد مدى توافقها مع الوكيل المستهدف وما يلزم التحقق منه قبل النشر.

## التثبيت والتحقق

الأمر أوضح بالتطبيق المباشر، فجربناه بأنفسنا. ثبَّتنا أداة التحقق في البيئة الافتراضية المشتركة. التزاماً بقواعد وقت تشغيل Python في ThakiCloud، استخدمنا `.venv` الأصلي للمشروع دون إنشاء بيئة منفصلة.

```bash
# تثبيت أداة التحقق من OMS (حزمة model-signing)
VIRTUAL_ENV="$PWD/.venv" uv pip install model-signing
# الإصدار المُثبَّت: model-signing 1.1.1
# الاعتماديات المصاحبة: sigstore-models 0.0.6, sigstore-rekor-types 0.0.18, tuf 7.0.0
```

استنسخنا بعد ذلك الكتالوج العام. بدلاً من مهارة cuOpt التي استشهد بها مدوَّنة NVIDIA، اخترنا مهارة Dynamo للتحقق لارتباطها المباشر ببيئتنا.

```bash
# استنساخ سطحي للكتالوج العام (استغرق نحو 5.5 ثوانٍ)
git clone --depth 1 https://github.com/nvidia/skills
cd skills

# شهادة الجذر مُدرَجة في المستودع
ls nv-agent-root-cert.pem

# الانتقال إلى المهارة الموقَّعة
cd plugins/nvidia-skills/skills/dynamo-interconnect-check
ls
# BENCHMARK.md  evals  references  scripts  skill-card.md  SKILL.md  skill.oms.sig
```

صيغة أمر التحقق هي `model_signing verify certificate`. نُحدِّد فيه ملف التوقيع وسلسلة الشهادات والمسارات المُستثناة من التحقق (ملف التوقيع نفسه).

```bash
python -m model_signing verify certificate . \
  --signature skill.oms.sig \
  --certificate_chain /path/to/nv-agent-root-cert.pem \
  --ignore-paths skill.oms.sig
```

باستعراض المستودع بأكمله، وجدنا في مجلد `skills/` مهاراتٍ يبلغ عددها 226، وملفات توقيع `skill.oms.sig` يبلغ عددها 237. شهادة الجذر مُضمَّنة في المستودع أيضاً، مما يعني إمكانية البدء في التحقق فوراً دون الحاجة إلى استلام مرساة الثقة عبر قناة منفصلة.

## نتائج الاختبار العملي

**أولاً: التحقق من توقيع سليم.** عند تشغيل التحقق على مهارة `dynamo-interconnect-check` دون المساس بها، جاء النتيجة فورية:

```text
Verification succeeded
verify_seconds=0.58
```

تحقَّقت سلامة شجرة المجلد بالكامل ومصدرها في 0.58 ثانية. سريع ومباشر.

**الجوهر: كشف التلاعب.** كي يكون للتوقيع معنى حقيقي، ينبغي أن يفشل التحقق عند أدنى تعديل على الملفات. أضفنا سطر تعليق واحداً إلى `BENCHMARK.md` داخل مجلد المهارة ثم أعدنا التحقق:

```text
Verification failed with error: Signature mismatch:
['Hash mismatch for 'BENCHMARK.md':
  Expected Digest(algorithm='sha256', digest_value=b's\xa5\xf6i!...'),
  Actual   Digest(algorithm='sha256', digest_value=b'Uy\xb9\xf6#b...')']
```

فشل التحقق كما توقعنا، وليس بصورة مبهمة من قبيل "شيء ما أخطأ"، بل بتحديد دقيق لأي ملف وأي قيمة SHA-256 تختلف عن المتوقع. مجرد إضافة سطر واحد غيَّر هاش الملف كلياً وكشفه أداة التحقق. هذا هو الفارق بين قرينة "نشره ناشر موثوق" وبين ضمان "المخرج ذاته لم يُعبَث به".

**بطاقة المهارة.** فتحنا `skill-card.md` الخاصة بـ `dynamo-interconnect-check`، فوجدنا فيها البيانات الوصفية للثقة الفعلية:

- **الوصف:** التحقق من استعداد ربط NIXL/UCX/NCCL في نشر Dynamo للخدمة الموزعة المعتمدة على RDMA/NVLink
- **المالك:** NVIDIA
- **الترخيص:** Apache-2.0
- **حالة الاستخدام:** للمطور الذي ينشر وصفة Dynamo الموزعة أو متعددة العقد قبل الوثوق بأرقام المعيار للتحقق من عمل طبقة نقل NIXL/UCX/NCCL
- **المخاطر المعروفة وإجراءات التخفيف:** قد يُضمِّن المقترح توجيهات خاطئة أو مضلِّلة في المهارة، لذا يجب مراجعتها وفحصها قبل النشر
- **تنسيق الإخراج:** JSON منظَّم يحتوي حكم ok/warn/fail/skipped لكل فحص

يمكن قراءة هذه البطاقة وحدها لتقييم ما إذا كانت المهارة مناسبة للبيئة التشغيلية. **ملاحظة حول قيد عملي:** الأمر المُستشهَد به في مدوَّنة NVIDIA يستخدم العلامة القديمة `--ignore-unsigned-files`، في حين تغيَّر اسم الخيار في model-signing 1.1.1 المُثبَّت فعلياً إلى `--ignore-paths` و`--ignore_unsigned_files`، مما تسبَّب في خطأ عند المحاولة الأولى. علامة واضحة على أن الأداة لا تزال في طور التطور السريع.

## التطبيق والدلالات على منصة ThakiCloud K8s AI/ML SaaS

لهذا الموضوع صلة مباشرة بنا. تُشغِّل ThakiCloud المنصة باستخدام حزمة مهاراتها الخاصة، وفيها مهارات تحمل الاسم ذاته للمهارات التي وقَّعتها NVIDIA ووزَّعتها. `dynamo-interconnect-check` و`dynamo-router-starter` أدوات نستخدمها في التعامل مع حزمة الاستدلال الموزع. أن تأتي هذه المهارات الآن مرفقةً بتوقيعات تشفيرية يعني أنه يمكننا التحقق من مصدر المهارات الخارجية وسلامتها برمجياً ضمن خط الأنابيب التشغيلي.

من منظور تعدد المستأجرين تزداد الأهمية. تُشغِّل منصتنا وكلاء في بيئات عملاء متعددة. قبل نشر أي مهارة أنشأها عميل أو طرف ثالث في وقت تشغيل الوكيل على Kubernetes، يجب التحقق من عدم التلاعب بها بعد نشرها ومن الجهة المسؤولة عنها. يُتيح التحقق من توقيع OMS تحويل هذه البوابة من قاعدة نثرية إلى بوابة كود حتمية: إذا فشل التحقق أوقفنا النشر، وإذا نجح مضينا. وكما رأينا في الاختبار، التحقق يستغرق نحو 0.58 ثانية، مما يجعله عملياً جداً للدمج في مراحل CI أو admission دون تحميل إضافي يُذكر.

نُشغِّل بالفعل آليات حوكمة المهارات: بوابة استيراد المهارات وماسح أمان المهارات وحوكمة مهارات الثقة (TSG). خط أنابيب NVIDIA ذو الثماني مراحل يتداخل بصورة طبيعية مع هذا التدفق. الفارق أن NVIDIA أضافت طبقة أخيرة، "سلامة قابلة للتحقق حتى بعد التنزيل"، بتنسيق قياسي. من منظورنا، يمكن دراسة تطبيق توقيع OMS ذاته على مهاراتنا الداخلية لإغلاق سلسلة الثقة في كتالوجنا الداخلي.

في البيئات المحلية والبيئات الخاضعة للتنظيم تتضاعف هذه القيمة. في بيئات العملاء ذات الشبكات المعزولة أو المتطلبات الأمنية العالية، يُصبح إثبات "هذه المهارة هي فعلاً تلك التي أصدرتها NVIDIA ولم تتغير في طريقها إلينا" متطلباً تمتثيلياً بحد ذاته. إذا كانت الاستضافة الذاتية والتشغيل المحلي من نقاط القوة في المنصة، فإن قابلية التحقق من سلسلة توريد المهارات ليست شعاراً تسويقياً، بل متطلب تقني يُحدِّد ما إذا كان العميل يُجيز اعتماد المنتج.

## القيود والاعتراضات

من الأمانة ألا نُبالغ في تقدير التوقيعات. ما يضمنه التوقيع التشفيري هو السلامة والمصدر، لا أن المهارة آمنة أو صحيحة. يمكن توقيع مهارة سيئة. التوقيع يقول فقط "هذا هو ما أصدره الناشر ولم يُعدَّل"، لا "اتباع تعليمات هذه المهارة آمن". بل إن بطاقة مهارة `dynamo-interconnect-check` ذاتها نصَّت على "راجعها وافحصها قبل النشر".

للفحص الأمني أيضاً حدوده. SkillSpector يعمل على جانب الناشر، أي أننا نثق بأن NVIDIA أجرت الفحص كما يجب دون أن نُعيد إنتاج نتائجه بأنفسنا. طبقة التقييم، دقة المشغِّل وإكمال المهمة وكفاءة الرمز المميز، لا تزال في مرحلة خارطة الطريق، مما يعني غياب مقاييس جودة معيارية حتى تُقاس وتعمل عبر أدوات مشتركة.

ثمة ملاحظة أيضاً على نضج الأدوات. تصف NVIDIA التوقيعات بأنها "تجريبية علناً". كما رأينا، تغيَّر اسم الخيار فلم تعمل أمثلة المدوَّنة مباشرةً، ومنظومة أدوات التحقق لا تزال في مراحلها الأولى. ارتباط مرساة الثقة بشهادة جذر واحدة له وجهان: يُبسِّط التحقق لكنه يُركِّز الثقة في كيان واحد هو NVIDIA. إمكانية النقل عبر الأدوات "مُصمَّمة للعمل" لكنها غير مضمونة في كل أداة، لذا يستوجب الاعتماد تشغيل اختبار فعلي على الأداة المستهدفة.

ومع ذلك، الاتجاه واضح. ما دامت المهارات مكوِّنات تُحدِّد سلوك الوكيل، فإن متطلب التحقق من مصدر تلك المكوِّنات وسلامتها لن يزول. ما قدَّمته NVIDIA إجابة محددة وقابلة للإعادة على هذا المتطلب، وهي الإجابة الأولى من نوعها.

## المصادر

- NVIDIA Technical Blog, [NVIDIA-Verified Agent Skills Provide Capability Governance for AI Agents](https://developer.nvidia.com/blog/nvidia-verified-agent-skills-provide-capability-governance-for-ai-agents/)
- GitHub, [NVIDIA/skills](https://github.com/nvidia/skills)
- GitHub, [NVIDIA/skillspector](https://github.com/nvidia/skillspector)
- NVIDIA Skill Documentation, [Verify Signed Agent Skills](https://docs.nvidia.com/skills/signing-agent-skills)
- OpenSSF, [Model Signing (OMS)](https://github.com/sigstore/model-transparency)
- الأرقام الواردة في النص (226 مهارة · 237 توقيعاً · تحقق 0.58 ثانية · كشف التلاعب) مقاسة من استنساخ المستودع مباشرةً بتاريخ 2026-06-25.
