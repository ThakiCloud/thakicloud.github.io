---
title: "تشريح Kimi Code CLI: كيف يستحوذ وكيل الطرفية مفتوح المصدر على المحررات عبر ACP"
excerpt: "نحلل أداة سطر الأوامر المفتوحة المصدر للبرمجة التي أطلقتها Moonshot AI إلى جانب Kimi K3، استناداً إلى الوثائق الرسمية والمستودع الفعلي. من الوكلاء الفرعيين coder وexplore وplan، مروراً بإعداد MCP التفاعلي، وصولاً إلى الدعم الأصلي لـ Agent Client Protocol الذي يمثل الفارق الحقيقي، نتحقق إلى أي مدى تصح عبارة الترويج القائلة إن هذه ميزات غير موجودة في Claude Code."
seo_title: "تحليل شامل لـ Kimi Code CLI وACP: الفارق الحقيقي لأداة الوكيل المفتوحة المصدر"
seo_description: "نتحقق من الوكلاء الفرعيين وMCP وAgent Client Protocol في Kimi Code CLI من Moonshot AI استناداً إلى الوثائق الرسمية. نقرأ الفوارق الحقيقية مقارنة بـ Claude Code ومنظور الاستضافة الذاتية داخل المؤسسة من خلال عدستي Paxis وai-platform."
date: 2026-07-20
last_modified_at: 2026-07-20
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
tags:
  - agentops
  - kimi
  - moonshot
  - coding-agent
  - mcp
  - agent-client-protocol
  - paxis
  - thakicloud
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/kimi-code-cli-acp-open-source-agent/"
---

في الأسبوع الماضي، تصدرت Moonshot AI قوائم الترتيب في البرمجة بعد إطلاق نموذجها المفتوح الأوزان Kimi K3. لكن ما رافق هذا الإطلاق بهدوء كان أداة أقرب إلى سير عمل المطورين من النموذج نفسه، وهي Kimi Code CLI، وكيل برمجة طرفي مفتوح المصدر أطلقته Moonshot برخصة MIT. تداول مستخدمو LinkedIn تعريفاً يقول إن هذه الأداة تقدم ميزات غير موجودة في Claude Code. لم ننقل هذه العبارة كما هي، بل تحققنا مباشرة من المستودع الرسمي والوثائق. والخلاصة أن نصف هذا التعريف صحيح ونصفه الآخر مبالغ فيه. والنقطة الأكثر إثارة للاهتمام كانت في موضع لم تبرزه مواد الترويج.

يستعرض هذا المقال ماهية Kimi Code CLI، وما تقدمه فعلياً، ولماذا تستحق المتابعة من منظورنا كمشغّلين لمنصة ذكاء اصطناعي قائمة على K8s. وقد خصصنا مساحة واسعة لشرح لماذا يُعد معيار Agent Client Protocol المفتوح قطعة قد تغير قواعد اللعبة في منظومة الوكلاء.

## ما هو Kimi Code CLI

Kimi Code CLI أداة برمجة عاملة بأسلوب الوكيل تعمل من الطرفية، وتنتمي إلى نفس فئة Claude Code وGemini CLI وCodex CLI. المستودع الرسمي هو [MoonshotAI/kimi-code](https://github.com/MoonshotAI/kimi-code)، وقد تطور من المشروع السابق [MoonshotAI/kimi-cli](https://github.com/MoonshotAI/kimi-cli) مع الحفاظ على استمرارية الجلسات والإعدادات القديمة. كلا المستودعين رسميان من Moonshot، وينبغي الحذر من الخلط بينهما وبين مشاريع طرف ثالث تحمل أسماء مشابهة.

وهنا يجب توضيح تصحيح أول. الاسم الرسمي لهذه الأداة ليس "CLI مخصصة لـ Kimi K3" بل Kimi Code CLI. فهي أداة غير مقيدة بنموذج واحد، وتستخدم افتراضياً نموذج Moonshot المتخصص في البرمجة Kimi K2.7 Code، لكن يمكن عبر الإعدادات التحول إلى نماذج أخرى بما فيها K3. أي أن K3 هو أحد النماذج المتعددة التي يمكن ربطها بهذه الأداة، وليست الأداة مصممة حصراً له. أما K3 نفسه فهو نموذج MoE مفتوح بحجم 2.8 تريليون معلمة أطلقته Moonshot في 16 يوليو 2026، ويعتمد على Kimi Delta Attention مع نافذة سياق تصل إلى مليون رمز. وقد غطت هذا الإطلاق وسائل إعلام رئيسية مثل CNBC وBloomberg وForbes.

من المفيد رسم الصورة الكاملة أولاً لتترابط التفاصيل لاحقاً بسهولة أكبر. جوهر الأمر هو الدور المزدوج الذي تلعبه Kimi Code CLI: فمن جهة تتصل بالأدوات والبيانات كعميل MCP، ومن جهة أخرى تتصل بالمحررات كخادم ACP.

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
<div class="d3-arch" data-arch-root id="odecliacpopensourceagent-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1394, "height": 908, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 582, "h": 124, "label": "محرر المطور (عميل ACP)", "lx": 36, "ly": 42}, {"x": 574, "y": 380, "w": 424, "h": 310, "label": "Kimi Code CLI (نواة الوكيل)", "lx": 586, "ly": 398}, {"x": 801, "y": 24, "w": 561, "h": 124, "label": "خوادم MCP (الأدوات والبيانات)", "lx": 813, "ly": 42}], "nodes": [{"id": "ZED", "x": 62, "y": 63, "w": 120, "h": 46, "title": "Zed"}, {"id": "JB", "x": 237, "y": 63, "w": 135, "h": 46, "title": "عائلة JetBrains"}, {"id": "VSC", "x": 427, "y": 63, "w": 142, "h": 46, "title": "VS Code / Neovim"}, {"id": "ACP", "x": 615, "y": 226, "w": 177, "h": 62, "title": ["Agent Client Protocol", "JSON-RPC over stdio"]}, {"id": "MAIN", "x": 612, "y": 419, "w": 184, "h": 62, "title": ["الوكيل الرئيسي", "يحافظ على سجل المحادثة"]}, {"id": "SUB", "x": 776, "y": 573, "w": 184, "h": 78, "title": ["الوكلاء الفرعيون", "coder · explore · plan", "لكل منهم سياق معزول"]}, {"id": "MODEL", "x": 634, "y": 782, "w": 198, "h": 94, "title": ["طبقة النموذج", "Kimi K2.7 Code / K3", "أو نقطة نهاية متوافقة مع", "OpenAI"]}, {"id": "T1", "x": 839, "y": 63, "w": 120, "h": 46, "title": "Context7"}, {"id": "T2", "x": 1014, "y": 63, "w": 135, "h": 46, "title": "Chrome DevTools"}, {"id": "T3", "x": 1204, "y": 63, "w": 121, "h": 46, "title": "موصلات داخلية"}, {"id": "EDITOR", "x": 644, "y": 63, "w": 120, "h": 46, "title": "EDITOR"}, {"id": "MCP", "x": 417, "y": 589, "w": 120, "h": 46, "title": "MCP"}], "edges": [{"src": "EDITOR", "dst": "ACP", "kind": "data", "line": [704, 109, 704, 226]}, {"src": "ACP", "dst": "MAIN", "kind": "data", "label": "kimi acp", "line": [704, 288, 704, 419], "lx": 704, "ly": 330}, {"src": "MAIN", "dst": "SUB", "kind": "data", "curve": [[770, 481], [868, 527], [868, 527], [868, 573]]}, {"src": "MAIN", "dst": "MODEL", "kind": "data", "label": "طلب استدلال", "curve": [[704, 481], [704, 612], [704, 736], [718, 782]], "off": "50%"}, {"src": "SUB", "dst": "MODEL", "kind": "data", "label": "طلب استدلال", "curve": [[868, 651], [868, 690], [868, 736], [801, 782]], "off": "50%"}, {"src": "MAIN", "dst": "MCP", "kind": "data", "label": "استدعاء أداة", "curve": [[677, 481], [639, 527], [639, 527], [520, 589]], "off": "50%"}]});
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
      const container = document.getElementById('odecliacpopensourceagent-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'odecliacpopensourceagent-1';
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

## الوكلاء الفرعيون: تقسيم السياق للحفاظ على نظافة الوكيل الرئيسي

توفر Kimi Code CLI ثلاثة أنواع من الوكلاء الفرعيين المدمجين. الوكيل coder هو المسؤول الهندسي العام الذي يقرأ الملفات ويكتبها وينفذ الأوامر لتطبيق التغييرات الفعلية. الوكيل explore مخصص للاستكشاف، إذ يتصفح قاعدة الشيفرة للقراءة فقط. أما الوكيل plan فيقتصر عمله على تقديم خطط التنفيذ وتصاميم البنية دون تنفيذ أي أوامر في الصدفة. هذا التقسيم موثق في الصفحة الرسمية [Agents and Sub-Agents](https://moonshotai.github.io/kimi-code/en/customization/agents.html).

الجوهر هنا ليس الأسماء بل عزل السياق. يمتلك كل وكيل فرعي نافذة سياق مستقلة تماماً، ولا يرى سوى وصف المهمة الذي يمرره الوكيل الرئيسي صراحة. لا يُكشف سجل محادثة الوكيل الرئيسي للوكلاء الفرعيين، كما أن سجلات الاستدلال الوسيط واستدعاءات الأدوات التي ينفذها الوكيل الفرعي لا تختلط بسجل الوكيل الرئيسي، إذ يعيد الوكيل الفرعي النتيجة النهائية فقط. ولهذا السبب يظل السياق الرئيسي رفيعاً ولا يتضخم بالسجلات في الجلسات الطويلة. كما تدعم الأداة التنفيذ في الخلفية والتنفيذ المتوازي، بحيث يمكن تشغيل عدة مهام استكشاف في آن واحد وتعود النتائج تلقائياً عند الانتهاء.

هذا النمط ليس غريباً علينا. فحتى إطار التنسيق الداخلي الذي يشغّل هذه المدونة يفوّض مهام الاستكشاف إلى وكلاء فرعيين منخفضي التكلفة، ولا يستعيد سوى الملخصات لحماية السياق الرئيسي. مبدأ أن نظافة السياق تعني في الوقت نفسه التكلفة والجودة يبقى واحداً بغض النظر عن الأداة المستخدمة.

## MCP: تجربة إعداد دون تعديل JSON يدوياً

تُدار عمليات ربط Model Context Protocol عبر مسارين. الأول هو الأوامر الفرعية لسطر الأوامر، حيث تُدار الخوادم عبر kimi mcp add وkimi mcp list وkimi mcp remove وkimi mcp authorize. على سبيل المثال يمكن ربط خادم بحث في الوثائق عبر نقل HTTP، أو ربط خادم أتمتة متصفح عبر نقل stdio.

```bash
# نقل HTTP (يدعم خيار OAuth)
kimi mcp add --transport http context7 https://mcp.context7.com/mcp

# ربط عملية محلية عبر نقل stdio
kimi mcp add --transport stdio chrome-devtools -- npx chrome-devtools-mcp@latest
```

أما المسار الثاني فهو الأمر التفاعلي بشرطة مائلة /mcp-config الذي يُستخدم داخل واجهة TUI، ويتيح إضافة الخوادم وتعديلها والمصادقة عليها دون تحرير ملف إعدادات JSON مباشرة. ويعرض الأمر /mcp قائمة الخوادم المتصلة حالياً والأدوات المحمّلة. والجزء الذي أبرزه تعريف LinkedIn، وهو أنه لا حاجة لتعديل JSON مباشرة، صحيح فعلاً. لكن هذه الميزة بحد ذاتها ليست غائبة عن Claude Code، وسنعود إلى هذه النقطة لاحقاً. الوثائق ذات الصلة موجودة في [إعداد MCP](https://moonshotai.github.io/kimi-cli/en/customization/mcp.html).

## Agent Client Protocol: أهم قطعة في هذه الأداة

هذا هو الجزء الأكثر إثارة للاهتمام في هذا المقال. Agent Client Protocol، ويُختصر بـ ACP، هو معيار مفتوح صممه فريق محرر Zed. يعمل برخصة Apache، ويتبادل الرسائل عبر JSON-RPC 2.0 فوق stdio. تُشغّل المحررات الوكيل كعملية فرعية وتتواصل معه عبر المدخلات والمخرجات القياسية، وآلية النقل نفسها مطابقة لبروتوكول خادم اللغة.

التشبيه هنا يساعد كثيراً على الفهم. قبل ظهور LSP، كان على كل محرر أن يبني تكاملاً منفصلاً لكل لغة برمجة. حوّل LSP هذه المسألة من مشكلة M ضرب N إلى مشكلة M زائد N، فما إن ينفذ محرر واحد المعيار حتى يستفيد من أي خادم لغة بغض النظر عمن صنعه. ويفعل ACP الشيء ذاته تماماً مع الوكلاء، فما إن ينفذ محرر واحد ACP حتى يتصل به أي وكيل بطريقة موحدة بغض النظر عن صانعه. يمكن الاطلاع على هذا المفهوم في [تعريف Zed بـ ACP](https://zed.dev/acp) وفي [مقال مارك نوري التوضيحي](https://blog.marcnuri.com/agent-client-protocol-acp-introduction).

من السهل الخلط بينه وبين MCP، لكن الاتجاه معاكس تماماً. يتجه MCP من الوكيل نحو الأدوات والبيانات، وفي هذه الحالة يكون الوكيل عميل MCP. أما ACP فيتجه من المحرر نحو الوكيل، وهنا يكون الوكيل خادم ACP والمحرر عميل ACP. أي أن الوكيل نفسه يلعب دور عميل MCP من جهة، ودور خادم ACP من جهة أخرى في آن واحد. وهذا هو السبب الذي جعل الرسم البياني السابق يوضح هذا الدور المزدوج.

تدعم Kimi Code CLI هذا البروتوكول بشكل أصلي عبر الأمر الفرعي kimi acp دون الحاجة إلى أي تثبيت إضافي. يتصل بها Zed بشكل أصلي، بينما تتصل به JetBrains عبر إضافة، وقد ظهرت بالفعل عدة تكاملات مع محررات أخرى وفق سجل ACP الخاص بـ Zed. بذلك يستطيع المطور تشغيل جلسة Kimi دون مغادرة المحرر الذي اعتاد عليه.

## إدخال الصور والفيديو، إلى أي حد فعلياً

ذكر تعريف LinkedIn أنه يمكن تمرير لقطة الشاشة كما هي كمدخل. وهذا يحتاج إلى تصحيح. فالميزة التي تبرزها Moonshot فعلياً ليست لقطة شاشة ثابتة بل إدخال مقطع فيديو مسجّل للشاشة. يذكر وصف المستودع أنه عند إسقاط تسجيل شاشة أو مقطع عرض توضيحي في المحادثة، يستطيع الوكيل مشاهدة وفهم السلوك الذي يصعب شرحه بالكلام مباشرة. وبالطبع تدعم نافذة الإدخال في سطر الأوامر لصق الصور أيضاً، إذ إن النموذج الافتراضي Kimi K2.7 Code هو نموذج متعدد الوسائط أصلي مزوّد بمُرمّز رؤية MoonViT بحجم 400 مليون معلمة، يستقبل النص والصور والفيديو معاً. غير أنه عند ربط نموذج مخصص، يجب تحديد دعم الصور صراحة ضمن modalities الخاصة بذلك النموذج ليعمل بشكل صحيح. وخلاصة القول إن إدخال الصور متاح فعلاً، لكن ما يُروَّج له كفارق حقيقي هو إدخال الفيديو، وتعبير لقطة شاشة غير دقيق تماماً.

## التثبيت فعلياً في ثلاث خطوات

تدفق التثبيت بسيط فعلاً كما ورد في التعريف. الأوامر أدناه مستندة إلى [دليل البدء الرسمي](https://moonshotai.github.io/kimi-cli/en/guides/getting-started.html)، ولم نترك سجل تنفيذ مباشر لأن صندوق الاختبار الداخلي لدينا لا يملك صلاحية الوصول إلى نطاق التوزيع المعني. لذلك لم ننتج أي أرقام قياس أداء، واكتفينا بنقل الأوامر الموثقة فقط.

```bash
# 1) تشغيل سكربت التثبيت (يثبّت uv في الوقت نفسه)
curl -LsSf https://code.kimi.com/install.sh | bash

# 2) التشغيل داخل دليل المشروع
kimi

# 3) إعداد المصادقة
/login
```

بالنسبة لنظام macOS تتوفر brew install kimi-code، وبالنسبة لويندوز يتوفر أيضاً سكربت PowerShell. للتطوير من الشيفرة المصدرية يلزم Node بإصدار 24.15 أو أحدث مع pnpm. ولأن الرخصة MIT، فإن القيود قليلة على قراءة الشيفرة وعمل fork لها وتوزيعها داخل المؤسسة.

## انفتاح النماذج ومزودي الخدمة

يبلغ أقصى طول للسياق في عائلة K2.6 نحو 256 ألف رمز، بينما يصل في K3 وفق مواد تسويق Moonshot إلى مليون رمز. لكن الأهم من ذلك هو انفتاح مزودي الخدمة. ففي ملف ~/.kimi-code/config.toml يمكن تسجيل عدة مزودين في آن واحد، من نقاط نهاية متوافقة مع OpenAI، إلى مفاتيح Anthropic API، وصولاً إلى Google GenAI أو Vertex AI. وهذا يعني أن الأداة غير مقيدة بنموذج واحد بعينه. كما تعالج تلقائياً حقل reasoning_content الخاص بنماذج الاستدلال من أطراف ثالثة. الوثائق ذات الصلة في [Providers and models](https://moonshotai.github.io/kimi-cli/en/configuration/providers.html).

## هل هي ميزات غير موجودة في Claude Code: مقارنة صريحة

أكثر العبارات انتشاراً في التعريف كانت أنها تقدم ميزات غير موجودة في Claude Code. وبعد التحقق تبين أن هذا الإطار في معظمه مبالغ فيه.

فالوكلاء الفرعيون وعزل السياق يقدمهما Claude Code أيضاً بالطريقة نفسها عبر ميزة الوكلاء الفرعيين. وMCP مدعوم أصلاً بنضج في Claude Code عبر نقل stdio وSSE وHTTP. كما أن لصق الصور موجود فيه أيضاً. هذه العناصر الثلاثة إذن ليست فوارق حقيقية.

الفارق الحقيقي يكمن في نقطتين. الأولى هي طريقة دعم ACP. فـ Kimi Code CLI تدمج ACP كميزة أساسية من الدرجة الأولى داخل الأداة نفسها عبر الأمر الفرعي kimi acp. أما Claude Code فيتصل بها عبر حزمة محول منفصلة صنعها Zed، وما تزال في مرحلة تجريبية. من منظور المستخدم، الأولى تعمل فور تفعيل الأداة، بينما الثانية تتطلب إضافة جسر إضافي. النقطة الثانية هي انفتاح النماذج. فـ Kimi مفتوح على سلسلة K مفتوحة الأوزان مع إمكانية التحول بين عدة مزودين، بينما يقتصر Claude Code على نماذج Anthropic حصرياً. ومن هذه النقطة يتفرع فارق ثالث يتعلق بإمكانية الاستضافة الذاتية. فبما أن Kimi أداة مفتوحة المصدر مع نموذج مفتوح الأوزان، يمكن تشغيله داخل المؤسسة، بينما تظل Claude Code أداة مفتوحة لكن نموذجها متاح عبر واجهة API فقط. يمكن الاطلاع على الدليل ذي الصلة في [مقال Zed حول Claude Code عبر ACP التجريبي](https://zed.dev/blog/claude-code-via-acp).

## دلالات على منتجات ThakiCloud

يمس هذا الموضوع أداة وكيل من جهة، ومحور بنية تحتية يتعلق بالنماذج المفتوحة والاستضافة داخل المؤسسة من جهة أخرى. لذلك نستخدم العدستين معاً.

من عدسة Paxis، تتداخل بنية Kimi Code CLI إلى حد كبير مع اتجاه تصميم منتجنا. فPaxis هو مستوى التحكم الخاص بـ ThakiCloud لسحابة أصيلة الوكلاء (Agent-Native Cloud)، ويتعامل مع المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. والطريقة التي يعمل بها الوكلاء الفرعيون coder وexplore وplan لدى Kimi بالتوازي وفي سياقات معزولة، تشترك في الفلسفة نفسها مع طريقة عمل حاضنة المهارات في Paxis، التي تختار من بين أكثر من 960 مهارة باستخدام BM25 وتنفذها في صناديق اختبار معزولة. وACP بشكل خاص، بوصفه معياراً محايداً تجاه المزودين، يمثل فرصة مباشرة لـ Paxis. فأي وكيل ننشره، بما في ذلك الوكلاء المزودة بنماذج خضعت لضبط دقيق خاص بنا، يمكنه إذا نفذ ACP أن يتصل بمحررات المطورين لدى العملاء مثل Zed أو JetBrains بطريقة موحدة. وهذا المزيج من معيارين، MCP للاتصال بالبيانات وACP للاتصال بالمحررات، يمثل بالضبط الصورة التكاملية التي نتجه إليها.

ومن عدسة ai-platform، الانفتاح يعني حرية النشر مباشرة. فبوضع سلسلة K مفتوحة الأوزان فوق جدولة GPU عبر Kueue وخدمة vLLM في عنقودنا، وتوجيه الأداة نحو نقطة نهاية داخلية، يمكن بناء وكيل برمجة داخلي دون الاعتماد على API خارجي أو إخراج البيانات إلى الخارج. وهذا ينسجم مع متطلبات الأمن الخاصة بالاستضافة داخل المؤسسة في قطاعي المال والقطاع العام حيث لا يجوز خروج الشيفرة إلى الخارج، وكذلك مع متطلبات جهات مثل NIS. وقد سبق أن تناولنا في مقالات سابقة فكرة أنه كلما أصبحت القدرات شائعة ورخيصة، فإن ما تدفعه الشركات فعلياً هو بيئة تنفيذ محكومة. وأهمية Kimi Code CLI تكمن في أنها فتحت طبقة التنفيذ هذه كمصدر مفتوح.

## القيود والاعتراضات

هناك عدة نقاط ينبغي النظر إليها بموضوعية. أولاً، أسماء المحركات الداخلية أو هياكل الطبقات التي تُذكر في تحليلات طرف ثالث معمقة لا ترد في الوثائق الرسمية، وقد تكون نتيجة هندسة عكسية، لذا من الأسلم الاستناد إلى الوثائق الرسمية قبل اعتبارها حقائق. ثانياً، توجد تقارير من المجتمع تفيد بأن مسار ACP يقدم جودة استجابة أفضل من طرق الاتصال الأخرى، لكنها انطباعات وليست قياسات أداء موثقة، أي أنها ليست أرقاماً محققة. ثالثاً، حتى مع كون النموذج مفتوح الأوزان، فإن خدمة نموذج بحجم 2.8 تريليون معلمة فعلياً داخل المؤسسة تتطلب موارد GPU كبيرة، والانفتاح لا يعني بالضرورة سهولة الاستضافة الذاتية، إذ يظل مسار API خياراً واقعياً للفرق الصغيرة. رابعاً، قد يتفوق نضج واستقرار منظومة الأدوات لدى Claude Code أو Codex CLI. وكون الأداة مفتوحة المصدر لا يعني بالضرورة أنها جاهزة للإنتاج.

## الخاتمة

ومع ذلك، فإن الاتجاه نحو ارتباط رخو بين الوكلاء والمحررات فوق معايير مفتوحة هو تيار واضح. فعالم يستطيع فيه المطور تبديل النموذج والمحرر كل على حدة دون التقيد بأداة سطر أوامر من مزود معين، هو عالم أكثر فائدة للمطورين. وتُعد Kimi Code CLI إحدى القطع التي تُقرّب هذا العالم.

## المصادر

- [MoonshotAI/kimi-code (المستودع الرسمي)](https://github.com/MoonshotAI/kimi-code)
- [MoonshotAI/kimi-cli (المستودع السابق)](https://github.com/MoonshotAI/kimi-cli)
- [دليل بدء Kimi Code CLI](https://moonshotai.github.io/kimi-cli/en/guides/getting-started.html)
- [وثائق Agents and Sub-Agents](https://moonshotai.github.io/kimi-code/en/customization/agents.html)
- [وثائق إعداد MCP](https://moonshotai.github.io/kimi-cli/en/customization/mcp.html)
- [Zed - Agent Client Protocol](https://zed.dev/acp)
- [ACP: The LSP for AI Coding Agents](https://blog.marcnuri.com/agent-client-protocol-acp-introduction)
- [Zed - Claude Code via ACP (تجريبي)](https://zed.dev/blog/claude-code-via-acp)
- [MarkTechPost - إطلاق Kimi K3](https://www.marktechpost.com/2026/07/16/moonshot-ai-releases-kimi-k3-a-2-8-trillion-parameter-open-moe-model-with-kimi-delta-attention-and-1m-context/)
