---
title: "كيف تبني مهارة Claude Code صفحات هبوط احترافية بضربة واحدة"
seo_title: "مهارة Claude Code لصفحات الهبوط بضربة واحدة - Thaki Cloud"
seo_description: "نحلّل كيف تحوّل مهارة Claude Code طلبًا واحدًا بلغة طبيعية إلى صفحة هبوط احترافية عبر إجراء تشغيل معياري قائم على SKILL.md، ونتحقق من ذلك من منظور تشغيل منصة المهارات Paxis لدى ThakiCloud."
excerpt: "مهارة Claude Code تحوّل طلبًا بسيطًا إلى صفحة هبوط احترافية. نفكّك آلية عملها الحقيقية ونتحقق منها من منظور Paxis حيث تُعامَل المهارات كموارد من الدرجة الأولى."
date: 2026-07-10
tags:
  - claude-code
  - agent-skills
  - agentops
  - landing-page
  - frontend
  - paxis
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/claude-code-skill-oneshot-landing-pages/"
audiobook: "https://drive.google.com/file/d/1GkVP3mH4wvRyJR_M3TrOF32VyLAVAf0G/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

شارك مطوّر مؤخرًا على منصة X أنه "بنى مهارة تجعل Claude Code ينشئ صفحات هبوط احترافية بضربة واحدة"، مدّعيًا أن المواقع الثلاثة في الفيديو كانت جميعها من إنتاج ضربة واحدة ([@the_cyw](https://x.com/the_cyw/status/2075338024406409239)). كان التفاعل قويًا بسبب مستوى إتقان النتائج، لكن النقطة الأكثر إثارة للاهتمام بالنسبة للمهندس تكمن في مكان آخر. أعطِ النموذج نفسه الطلب نفسه، "ابنِ لي صفحة هبوط"، فتحصل على شيء عادي؛ أضف مهارة واحدة فتخرج صفحة بمستوى وكالة تصميم في مسار واحد. بالنسبة إلى المهندس الذي يُسند المهام المتكررة إلى عملاء الذكاء الاصطناعي، فإن الاستنتاج الذي يمكن أخذه من هنا هو أن الرافعة التي ترفع الجودة تكمن في تصميم المهارة لا في استبدال النموذج.

![كيف تبني مهارة Claude Code صفحات هبوط احترافية بضربة واحدة 개념을 형상화한 이미지](/assets/images/claude-code-skill-oneshot-landing-pages-hero.png)
*글의 핵심 개념을 형상화했습니다.*

## نظرة عامة

مهارة Claude Code ليست سحرًا بل **إجراء تشغيل معياري (SOP)**. هي لا تجعل النموذج أذكى، بل تقيّد بقوة قدراتٍ يمتلكها النموذج أصلًا نحو اتجاه محدد، فترفع متوسط الجودة. في حالة مهارة صفحات الهبوط، هذا القيد هو تحديدًا مبادئ التصميم وقواعد التخطيط وصيغة المخرجات.

يتوافق هذا المنظور تمامًا مع طريقة تشغيل ThakiCloud للوكلاء. جودة الوكيل لا تأتي من فئة النموذج بل من بنية العقد التي تغلّف النموذج. مهارة صفحات الهبوط مثال جيد على تركيز بنية العقد هذه في مجال ضيّق هو تصميم الواجهة الأمامية. وهي أيضًا تصميم مهارة نموذجي: قلّل درجات الحرية لترفع المتوسط.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 1](/assets/images/posts/news/claude-code-skill-oneshot-landing-pages/nlm-infographic-1.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## ما هذه التقنية

مهارة Claude Code هي في جوهرها ملف markdown واحد اسمه `SKILL.md`. بداخله المبادئ والقواعد التي ينبغي للوكيل اتباعها في مهمة معينة، إضافة إلى تفضيلات المستخدم. عندما يقدّم المستخدم طلبًا بلغة طبيعية، تُحقَن المهارة ذات الصلة في سياق الوكيل، فيتبع الوكيل تلك التعليمات كإجراء تشغيل معياري بينما يولّد HTML وCSS وJavaScript محليًا.

شكل ما تنتجه مهارات صفحات الهبوط يُلاحَظ باتساق عبر عدة مهارات عامة. إنه ملف HTML واحد مكتفٍ بذاته، بكل CSS مضمّن داخل `<style>` وكل JavaScript مضمّن داخل `<script>`. تقتصر الاعتماديات الخارجية على Google Fonts ومكتبة الرسوم المتحركة GSAP المحمّلة عبر CDN ([Claude Directory](https://www.claudedirectory.org/skills/claude-skills-landing)). ملف واحد يكفي لاستضافته وتقديمه في أي مكان.

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
<div class="d3-arch" data-arch-root id="skilloneshotlandingpages-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 486, "height": 692, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "U", "x": 256, "y": 32, "w": 198, "h": 62, "title": ["طلب بلغة طبيعية", "إنشاء صفحة هبوط احترافية"]}, {"id": "A", "x": 163, "y": 194, "w": 142, "h": 46, "title": "وكيل Claude Code"}, {"id": "S", "x": 24, "y": 24, "w": 177, "h": 78, "title": ["SKILL.md", "مبادئ التصميم · قواعد", "التخطيط · التفضيلات"]}, {"id": "G", "x": 149, "y": 318, "w": 170, "h": 62, "title": ["مخرج HTML واحد", "CSS مضمّن · JS مضمّن"]}, {"id": "D1", "x": 270, "y": 458, "w": 120, "h": 62, "title": ["Google Fonts", "CDN"]}, {"id": "D2", "x": 59, "y": 458, "w": 156, "h": 62, "title": ["رسوم GSAP المتحركة", "CDN"]}, {"id": "O", "x": 156, "y": 598, "w": 156, "h": 62, "title": ["صفحة مكتفية بذاتها", "تُشحن كملف واحد"]}], "edges": [{"src": "U", "dst": "A", "kind": "data", "curve": [[355, 94], [355, 148], [355, 148], [274, 194]]}, {"src": "S", "dst": "A", "kind": "event", "label": "حقن", "curve": [[113, 102], [113, 148], [113, 148], [193, 194]], "off": "50%"}, {"src": "A", "dst": "G", "kind": "data", "line": [234, 240, 234, 318]}, {"src": "G", "dst": "D1", "kind": "data", "curve": [[276, 380], [330, 419], [330, 419], [330, 458]]}, {"src": "G", "dst": "D2", "kind": "data", "curve": [[191, 380], [137, 419], [137, 419], [137, 458]]}, {"src": "D1", "dst": "O", "kind": "data", "curve": [[330, 520], [330, 559], [330, 559], [276, 598]]}, {"src": "D2", "dst": "O", "kind": "data", "curve": [[137, 520], [137, 559], [137, 559], [191, 598]]}]});
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
      const container = document.getElementById('skilloneshotlandingpages-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'skilloneshotlandingpages-1';
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

الكلمة المفتاحية هي "ضربة واحدة". حين يصف المستخدم ما يريده بجمل بسيطة، يُنتج الوكيل الصفحة كاملة في مسار واحد دون ذهاب وإياب كثير. ينجح هذا لا لأن النموذج يبدع، بل لأن المهارة اتخذت مسبقًا معظم القرارات حول "ما الذي يصنع صفحة هبوط جيدة" نيابةً عن المستخدم.

## القرارات التي تتخذها المهارة نيابةً عنك

حين تطلب صفحة هبوط دون مهارة، تكون النتيجة عامة لسبب واضح: على الوكيل أن يقرر التخطيط والمسافات والطباعة وتباين الألوان وتوقيت الحركة من الصفر في كل مرة، وتتجه تلك القرارات نحو متوسط آمن. تثبّت مهارات صفحات الهبوط الاحترافية العامة هذه القرارات مسبقًا بالضبط ([تحليل MindStudio](https://www.mindstudio.ai/blog/claude-code-landing-page-generator-skill-city-service-matrix-seo)).

فلسفة التصميم التي ترمّزها هذه المهارات متسقة إلى حد بعيد. تضع أساسًا من التقشف المقصود الذي يزيل غير الضروري، وتستخدم تخطيطات غير متماثلة تكسر التماثل لتوجيه العين، وتضيف فوق ذلك محفّزات نفسية لرفع معدل التحويل. تستهدف سلطة العلامة والتحويل معًا كي تبدو النتيجة مصنوعة بيد إنسان لا مبنية على قالب. يصف بعض مؤلفي المهارات ذلك بأنه "زرع خبرة وكالة تصميم من الطراز الأول داخل الوكيل".

الدرس هنا لا يقتصر على الواجهة الأمامية. المهارة الجيدة لا تمنح النموذج الحرية، بل تمنحه هيكلًا موثّقًا وتتركه يملأ الداخل. كلما ثبّتت رموز التصميم وشبكات التخطيط وصيغة المخرجات كالشيفرة، قلّ التباين لكل استدعاء وارتفع متوسط الجودة. وعلى العكس، رجاء نثري مثل "اجعلها تبدو رائعة" يعطي نتيجة مختلفة في كل مرة.

## أمور ينبغي الانتباه إليها عند بناء مهارتك

إن كتبت مثل هذه المهارة بنفسك، فبعض الأمور مهمة. أولًا، ثبّت صيغة المخرجات صراحةً. تحديد البنية بأنها "HTML واحد، CSS/JS مضمّن، اعتماديات خارجية مقتصرة على الخطوط وGSAP" يُبقي النشر والنقل بسيطين. ثانيًا، اختزل حكم التصميم إلى قواعد. كتابة مقاييس المسافات وتباين الطباعة ولوحة ألوان مسموحة وقاعدة تفضّل `transform` و`opacity` الملائمين للمُركِّب في الحركة داخل الإجراء المعياري يعني ألا يعيد الوكيل التداول في كل مرة. ثالثًا، ضمّن حالات الفشل. أكثف معلومة في المهارة هي قائمة "لا تفعل هذا". بنود مثل منع الحركات التي تُزيح التخطيط ومنع مخالفات أساسيات إمكانية الوصول هي ما يحمي جودة المخرجات فعليًا ([دليل Ryan Doser](https://ryandoser.com/claude-code-landing-pages/)).

ملاحظة أخرى: المهارة ضريبة أيضًا. منذ لحظة تحميلها في السياق تكلّف رموزًا، لذا على كل جملة أن تجتاز اختبار "هل سيخطئ الوكيل بدون هذا؟". الزخرفة غير الضرورية خسارة صافية.

## دلالات لمنتجات ThakiCloud

يتردد صدى هذه الحالة لدى ThakiCloud خصوصًا لأننا نشغّل منصة تعامل المهارات كموارد من الدرجة الأولى.

**منظور Paxis (الوكلاء والمهارات).** Paxis هي سحابة ThakiCloud الأصلية للوكلاء (Agent-Native Cloud)، التي تعامل Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. قدرة وحدوية مثل مهارة صفحات الهبوط هي بالضبط ما يديره Skill Harness في Paxis. نختار من مئات المهارات عبر BM25، ونحقن ذات الصلة فقط في سياق الوكيل، وننفّذها في صندوق رمل معزول، ونمرّر كل فعل عبر بوابة سياسة وسجل تدقيق. كون مهارة صفحة هبوط واحدة تعمل جيدًا يعني أيضًا أن النمط نفسه يمكن أن يمتد إلى مجالات أخرى مثل توليد الشرائح وعرض المستندات ونشر البنية التحتية. صور ومستندات هذه المدونة نفسها تُولَّد على منصة المهارات ذاتها.

على وجه الخصوص، المبدأ الذي تُظهره هذه الحالة، "الشيفرة تملك الصيغة والنموذج يملأ المحتوى فقط"، يتطابق مباشرة مع فلسفة تصميم Paxis. كلما ثبّت بنية المخرجات حتميًا وضيّقت مجال حكم النموذج، زاد اتساق الجودة عبر فئات النماذج.

**منظور ai-platform (البنية التحتية).** بعض العملاء يريدون تشغيل أحمال التوليد هذه على بنيتهم التحتية الخاصة بدل الاعتماد كليًا على واجهات برمجة خارجية. تقدّم منصة ai-platform لدى ThakiCloud نماذج التوليد فوق جدولة GPU قائمة على K8s وKueue، فحتى في البيئات المحلية أو السيادية يمكن استضافة مثل هذه المسارات القائمة على المهارات ذاتيًا. كلما كانت المهمة متكررة ومعيارية، مثل توليد صفحات الهبوط، تحوّلت كلفة التقديم المنخفضة مباشرةً إلى اقتصاديات وكيل.

## القيود والاعتراضات

بالطبع علينا الحذر من المبالغة. عبارة "صفحة احترافية بضربة واحدة" تصحّ أكثر في ظروف العرض التوضيحي. صفحة هبوط منتج حقيقي تحمل متطلبات متداخلة مثل أصول العلامة ومراجعة النصوص والامتثال لإمكانية الوصول وميزانية أداء واختبار A/B، لذا فمخرج الضربة الواحدة مسودة ممتازة لا نسخة نهائية. وعلى وجه الخصوص، HTML واحد بكل شيء مضمّن مريح للنشر السريع لكنه قد يحتاج إلى تقسيم من جديد للتخزين المؤقت والصيانة في موقع حقيقي تتشارك فيه صفحات متعددة الأصول.

كذلك، الذوق التصميمي المخبوز في المهارة هو سقف النتيجة. إن كانت مهارة مُحسَّنة لجمالية معينة، فستقاوم الطلبات التي تخرج عنها. هذا ليس خللًا بل مقايضة مصمّمة. تخلّت عن الأطراف مقابل رفع المتوسط عبر تقليل الحرية، لذا فالفريق الذي يتعامل مع علامات كثيرة أفضل له أن يقسّم المهارات حسب الجمالية بدل إبقاء مهارة واحدة.

القيمة الحقيقية لهذه الحالة ليست "تخرج صفحة جميلة بضربة واحدة" بل أنها أثبتت بوضوح المبدأ القائل إن **جودة الوكيل تأتي من تصميم المهارة لا من النموذج**. وPaxis هي بالضبط تحويل ذلك المبدأ إلى منتج قابل للتشغيل على مستوى المنصة.

<!-- nlm-visual -->
![핵심 개념 요약 인포그래픽 2](/assets/images/posts/news/claude-code-skill-oneshot-landing-pages/nlm-infographic-2.png)
*NotebookLM이 소스를 종합해 생성한 인포그래픽입니다.*

## المصادر

- [@the_cyw، "بنيت مهارة تجعل Claude Code يبني صفحات هبوط احترافية"](https://x.com/the_cyw/status/2075338024406409239)
- [Claude Directory: Landing Page Skills](https://www.claudedirectory.org/skills/claude-skills-landing)
- [MindStudio: Claude Code Landing Page Generator Skill](https://www.mindstudio.ai/blog/claude-code-landing-page-generator-skill-city-service-matrix-seo)
- [Ryan Doser: How to Build Landing Pages With Claude Code](https://ryandoser.com/claude-code-landing-pages/)
