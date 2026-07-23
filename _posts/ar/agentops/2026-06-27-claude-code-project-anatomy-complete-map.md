---
title: "قرأنا الخريطة الكاملة لبنية مشروع Claude Code وقسنا مستودعنا الفعلي عليها"
excerpt: "من CLAUDE.md وقواعد rules وskills وagents وhooks حتى MCP، قرأنا الخريطة الكاملة التي ترسم حدود دور كل مكوّن في مشروع Claude Code، ثم قسنا مستودعنا الحقيقي (40 قاعدة، 1655 مهارة، 54 وكيلاً) مباشرةً على تلك الخريطة لنرى ما يتطابق وما يغيب. نستعرض شجرة قرار التوضيع ومنظور تشغيل منصة SaaS لـ AI/ML على Kubernetes."
seo_title: "الخريطة الكاملة لبنية مشروع Claude Code - قياس فعلي - Thaki Cloud"
seo_description: "حدود دور كل مكوّن في مشروع Claude Code من CLAUDE.md و.claude/rules وskills وagents وhooks وMCP، وشجرة قرار التوضيع، وقياس فعلي لمستودع ThakiCloud بـ 40 قاعدة و1655 مهارة و54 وكيلاً. يتناول المقال أيضاً استراتيجية نظافة السياق من منظور منصة SaaS لـ AI/ML على Kubernetes."
date: 2026-06-27
last_modified_at: 2026-06-27
tags:
  - ai-coding
  - claude-code
  - project-structure
  - context-engineering
  - agent-skills
  - platform-engineering
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "sitemap"
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/technique/claude-code-project-anatomy-complete-map/"
categories:
  - agentops
published: false
---

![بنية تجريدية لخطوط ضوئية متعددة تتقارب نحو عقدة مركزية ثم تتفرع من جديد بشكل هرمي]({{ '/assets/images/claude-code-project-anatomy-complete-map-hero.webp' | relative_url }})
*صورة تجريدية لبنية مشروع Claude Code التي تتشعب من دماغ مشروع واحد إلى قواعد ومهارات ووكلاء وذاكرة.*

## نظرة عامة

يكفي أن تعمل مع Claude Code فترة من الوقت حتى تتحوّل مجلدات `.claude` إلى فوضى من الأشياء المتناثرة. محتوى يستحق أن يكون قاعدة ينتهي في `CLAUDE.md`، ومعرفة متخصصة لا تُحتاج إلا أحياناً تُدفن في قواعد مُحمَّلة دائماً، ومسارات بيئة شخصية تتسلل إلى ملفات مشتركة بين أعضاء الفريق. حين تضبب الحدود بين ما يحتويه كل مكوّن، يصبح المستخدم يدفع رموزاً توكن لسياق لا فائدة منه في كل جلسة.

في يونيو 2026، أثارت مقالة Prakash Bhandari بعنوان "Claude Code Project Structure: The Complete Map" اهتمام مجتمع المطورين. ترسم المقالة خريطة وحيدة لخمسة أنظمة فرعية تتحكم فيها مجلدات `.claude`: التعليمات (CLAUDE.md وrules)، وتدفقات العمل (skills وcommands)، والخبراء (agents)، والصلاحيات (settings.json)، والذاكرة (memory). إذ تُشغّل ThakiCloud مئات المهارات وعشرات الوكلاء على هذه البنية بالفعل، لم نكتفِ بقراءة المقالة بل قسنا مستودعنا عليها مباشرةً.

هذا المقال هو سجلّ تلك المقارنة الميدانية. نُحدد حدود دور كل مكوّن، ونقيس الأرقام الفعلية لمكوّنات مستودع `ai-platform-strategy`، ثم نناقش لماذا تتخطى هذه البنية مجرد التنظيم حين يتعلق الأمر بتشغيل منصة SaaS متعددة المستأجرين لـ AI/ML على Kubernetes.

## ما هي بنية مشروع Claude Code؟

الفكرة الجوهرية بسيطة. يقرأ Claude Code التكوين من موضعين: مجلد `.claude` في دليل المشروع، ومجلد `~/.claude` في الدليل الرئيسي. يُودَع ملفات المشروع في git لمشاركتها بين أعضاء الفريق، بينما تنطبق ملفات الدليل الرئيسي على جميع المشاريع كإعدادات شخصية. يستقر كل مكوّن في موضعه وفق هذين المسارين.

جوهر الخريطة يكمن في سؤال واحد: متى يُحمَّل كل مكوّن في السياق؟ بعضها يدخل السياق تلقائياً مع كل جلسة، وبعضها لا يدخل إلا حين تُفعّله طلب بعينه. هذا الفارق في توقيت التحميل هو الفارق في تكلفة التوكن، وهو ما يجعل قرار توضيع أي شيء في أي مكان مسألة تشغيلية لا مجرد تفضيل شخصي.

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
<div class="d3-arch" data-arch-root id="rojectanatomycompletemap-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 742, "height": 860, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "ROOT", "x": 24, "y": 555, "w": 120, "h": 46, "title": "جذر المشروع"}, {"id": "BRAIN", "x": 222, "y": 750, "w": 205, "h": 78, "title": ["CLAUDE.md", "دماغ المشروع", "(تحميل تلقائي مع كل جلسة)"]}, {"id": "LOCAL", "x": 257, "y": 617, "w": 135, "h": 78, "title": ["CLAUDE.local.md", "تجاوز شخصي", "(gitignore)"]}, {"id": "IGNORE", "x": 264, "y": 500, "w": 121, "h": 62, "title": [".claudeignore", "حدود السياق"]}, {"id": "MCP", "x": 233, "y": 383, "w": 184, "h": 62, "title": [".mcp.json", "توصيل الأدوات الخارجية"]}, {"id": "DOTC", "x": 265, "y": 282, "w": 120, "h": 46, "title": ".claude/"}, {"id": "SET", "x": 505, "y": 641, "w": 205, "h": 78, "title": ["settings.json", "الأذونات·الخطافات·متغيرات", "البيئة"]}, {"id": "RULES", "x": 530, "y": 508, "w": 156, "h": 78, "title": ["rules/", "القواعد الدائمة", "(تحميل مع كل دورة)"]}, {"id": "SKILLS", "x": 516, "y": 375, "w": 184, "h": 78, "title": ["skills/", "معرفة متخصصة عند الطلب", "(تحميل عند الطلب)"]}, {"id": "AGENTS", "x": 512, "y": 258, "w": 191, "h": 62, "title": ["agents/", "تعريفات العوامل الفرعية"]}, {"id": "MEM", "x": 509, "y": 141, "w": 198, "h": 62, "title": ["agent-memory/", "المعرفة المكتسبة للعوامل"]}, {"id": "WT", "x": 548, "y": 24, "w": 120, "h": 62, "title": ["worktrees/", "عزل متوازٍ"]}], "edges": [{"src": "ROOT", "dst": "BRAIN", "kind": "data", "curve": [[95, 601], [183, 789], [183, 789], [222, 789]]}, {"src": "ROOT", "dst": "LOCAL", "kind": "data", "curve": [[113, 601], [183, 656], [183, 656], [257, 656]]}, {"src": "ROOT", "dst": "IGNORE", "kind": "data", "curve": [[133, 555], [183, 531], [183, 531], [264, 531]]}, {"src": "ROOT", "dst": "MCP", "kind": "data", "curve": [[98, 555], [183, 414], [183, 414], [233, 414]]}, {"src": "ROOT", "dst": "DOTC", "kind": "data", "curve": [[92, 555], [183, 305], [183, 305], [265, 305]]}, {"src": "DOTC", "dst": "SET", "kind": "data", "curve": [[333, 328], [466, 680], [466, 680], [505, 680]]}, {"src": "DOTC", "dst": "RULES", "kind": "data", "curve": [[338, 328], [466, 547], [466, 547], [530, 547]]}, {"src": "DOTC", "dst": "SKILLS", "kind": "data", "curve": [[354, 328], [466, 414], [466, 414], [516, 414]]}, {"src": "DOTC", "dst": "AGENTS", "kind": "data", "line": [385, 298, 512, 289]}, {"src": "DOTC", "dst": "MEM", "kind": "data", "curve": [[349, 282], [466, 172], [466, 172], [509, 172]]}, {"src": "DOTC", "dst": "WT", "kind": "data", "curve": [[338, 282], [466, 55], [466, 55], [548, 55]]}]});
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
      const container = document.getElementById('rojectanatomycompletemap-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rojectanatomycompletemap-1';
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
*مخطط بنية مشروع Claude Code مُرتَّب وفق توقيت التحميل في السياق.*

## حدود دور كل مكوّن

القيمة الحقيقية للخريطة تتجلى في الإجابة عن: ما الذي يذهب إلى أين؟ فيما يلي ملخص مسؤولية كل مكوّن مقروناً بطريقة تطبيقنا الفعلي.

**CLAUDE.md هو دماغ المشروع.** يُحمَّل تلقائياً مع كل جلسة ويمثّل الموجز المرجعي المشترك بين الفريق. تخيّله كالكرّاس الذي تسلّمه للمتعاقد الجديد في يومه الأول. أربعة أسئلة فحسب ينبغي أن يجيب عنها: ماذا نبني؟ على أي حزمة تعمل؟ أي اتفاقيات نتّبع؟ وما قواعد سير العمل؟ المبدأ الحاسم أن كل سطر يدفع إيجاراً، فـ`CLAUDE.md` المنتفخ هو في حقيقته هدر في السياق.

**CLAUDE.local.md هو تجاوز الإعدادات الشخصية.** يشارك CLAUDE.md تنسيقه ذاته لكنه لا يدخل git أبداً. المسارات المحلية للبيئة، ومختصرات تصحيح الأخطاء، والتفضيلات الشخصية، وخصوصيات جهازك: هذه هي ما يذهب هنا. يجوز أن يختلف بين الزملاء، وهو الصمام الأماني الذي يُبقي `CLAUDE.md` المشترك نظيفاً.

**.claudeignore هو حدود السياق.** يستخدم صياغة `.gitignore` ذاتها ليقيّد نطاق قراءة Claude. بدونه، يستنزف `node_modules` وملفات الترحيل المولّدة وتبعيات البائع والتركيبات الضخمة السياقَ. في مستودعات الأحادي الكبيرة يصبح هذا الملف شرطاً لا خياراً.

**rules هي القواعد الدائمة.** تُحمَّل تلقائياً مع كل دورة، لذا لا ينبغي أن تحتوي إلا على القواعد الثابتة التي تسري على جميع المهام. وضع وثيقة معمارية من 200 سطر في ملف قاعدة يعني استهلاك سياقها في كل جلسة حتى وإن كانت لا صلة لها بما يُنجَز. لهذا يجب أن تنام الوثائق حتى تستدعيها مهارة صريحة.

**skills هي المعرفة المتخصصة عند الطلب.** لا تُحمَّل إلا حين تُفعّلها طلبٌ ما. وصفات العمل المتخصصة وخطوط أنابيب المجالات والمهام المتكررة: هذا مكانها. السؤال الفاصل بين CLAUDE.md وskills: هل يُحتاج هذا دائماً أم أحياناً؟

**agents هي تعريفات الوكلاء الفرعيين.** خبراء مستقلون لكل منهم دوره وأدواته ومستوى نموذجه، يُستدعَون عند الحاجة. المنطق أن تسند مهام الاستكشاف إلى نماذج أرخص، والتنفيذ إلى نماذج متوازنة، والقرارات المعمارية إلى النماذج الأكثر تكلفة، توجيهاً مرناً وفق طبيعة المهمة.

**agent-memory هي المعرفة التي اكتسبها الوكيل بنفسه.** هنا يكمن الفرق الجوهري عن CLAUDE.md: الأخير يحتوي ما أخبرته أنت به، أما agent-memory فتحتوي ما تعلّمه الوكيل من التجربة. الوكلاء طويلو المدى يراكمون الأنماط المتكررة والأخطاء والاتفاقيات غير الموثّقة.

## أين تضع المعرفة الجديدة؟

حتى لو استظهرت الخريطة، يظل السؤال العملي مُحيّراً حين تضيف قاعدة أو تدفق عمل جديداً. شجرة قرار التوضيع التي تقترحها المقالة تبسّط هذا الحكم.

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
<div class="d3-arch" data-arch-root id="rojectanatomycompletemap-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 841, "height": 1058, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "START", "x": 520, "y": 24, "w": 205, "h": 62, "title": ["إضافة معرفة·قواعد·سير عمل", "جديدة"]}, {"id": "Q1", "x": 525, "y": 164, "w": 195, "h": 68, "title": ["تطبيق دائم +", "مشاركة الفريق كاملاً؟"]}, {"id": "CMD", "x": 646, "y": 327, "w": 163, "h": 62, "title": ["CLAUDE.md (باختصار)", "أو .claude/rules/"]}, {"id": "Q2", "x": 445, "y": 324, "w": 146, "h": 68, "title": ["سير عمل متخصص", "مطلوب أحياناً؟"]}, {"id": "SK", "x": 546, "y": 495, "w": 135, "h": 46, "title": ".claude/skills/"}, {"id": "Q3", "x": 353, "y": 484, "w": 138, "h": 68, "title": ["دور مستقل·", "مزيج أدوات؟"]}, {"id": "AG", "x": 453, "y": 655, "w": 135, "h": 46, "title": ".claude/agents/"}, {"id": "Q4", "x": 252, "y": 644, "w": 146, "h": 68, "title": ["خصوصيات البيئة", "الشخصية؟"]}, {"id": "LO", "x": 358, "y": 807, "w": 135, "h": 62, "title": ["CLAUDE.local.md", "(gitignore)"]}, {"id": "Q5", "x": 143, "y": 804, "w": 160, "h": 68, "title": ["ما تعلّمه العامل", "من التجربة؟"]}, {"id": "ME", "x": 249, "y": 972, "w": 177, "h": 46, "title": ".claude/agent-memory/"}, {"id": "PL", "x": 24, "y": 964, "w": 170, "h": 62, "title": ["plugins/", "(نشر لمشاريع متعددة)"]}], "edges": [{"src": "START", "dst": "Q1", "kind": "data", "line": [623, 86, 623, 164]}, {"src": "Q1", "dst": "CMD", "kind": "data", "label": "نعم", "curve": [[667, 232], [728, 278], [728, 278], [728, 327]], "off": "50%"}, {"src": "Q1", "dst": "Q2", "kind": "data", "label": "لا", "curve": [[578, 232], [518, 278], [518, 278], [518, 324]], "off": "50%"}, {"src": "Q2", "dst": "SK", "kind": "data", "label": "نعم", "curve": [[559, 392], [614, 438], [614, 438], [614, 495]], "off": "50%"}, {"src": "Q2", "dst": "Q3", "kind": "data", "label": "لا", "curve": [[477, 392], [422, 438], [422, 438], [422, 484]], "off": "50%"}, {"src": "Q3", "dst": "AG", "kind": "data", "label": "نعم", "curve": [[464, 552], [520, 598], [520, 598], [520, 655]], "off": "50%"}, {"src": "Q3", "dst": "Q4", "kind": "data", "label": "لا", "curve": [[381, 552], [325, 598], [325, 598], [325, 644]], "off": "50%"}, {"src": "Q4", "dst": "LO", "kind": "data", "label": "نعم", "curve": [[368, 712], [426, 758], [426, 758], [426, 807]], "off": "50%"}, {"src": "Q4", "dst": "Q5", "kind": "data", "label": "لا", "curve": [[281, 712], [223, 758], [223, 758], [223, 804]], "off": "50%"}, {"src": "Q5", "dst": "ME", "kind": "data", "label": "نعم", "curve": [[272, 872], [338, 918], [338, 918], [338, 972]], "off": "50%"}, {"src": "Q5", "dst": "PL", "kind": "data", "label": "لا", "curve": [[175, 872], [109, 918], [109, 918], [109, 964]], "off": "50%"}]});
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
      const container = document.getElementById('rojectanatomycompletemap-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rojectanatomycompletemap-2';
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
*شجرة القرار لتحديد موضع أي معرفة جديدة: هل تُحتاج دائماً؟ هل تُحتاج أحياناً؟ من صنعها؟*

الأخطاء الشائعة واضحة أيضاً. حشو المعرفة التي "تُحتاج أحياناً" في `CLAUDE.md` يعني هدر توكن في كل جلسة. مستودع أحادي بلا `.claudeignore` يستنزف السياق. إيداع `CLAUDE.local.md` في git يكشف البيانات الشخصية والمسارات. تفعيل أكثر من 10 خوادم MCP دائماً يهدر نحو 10 آلاف توكن بلا استخدام.

## قياس مستودع ThakiCloud على هذه الخريطة

بعد قراءة الخريطة، قسنا مستودعنا عليها فعلاً. هذه هي نتائج قياس مجلد `.claude` في مستودع `ai-platform-strategy`:

| المكوّن | القياس الفعلي | توقيت التحميل |
|---|---|---|
| CLAUDE.md | 94 سطراً | تلقائي مع كل جلسة |
| .claude/rules | 40 ملفاً | تلقائي مع كل دورة |
| .claude/skills | 1655 مجلداً | عند الطلب |
| .claude/agents | 54 تعريفاً | عند الاستدعاء |
| .claude/hooks | 15 ملفاً | عند وقوع الحدث |
| .claudeignore | موجود (442 بايت) | حدود دائمة |
| .mcp.json | موجود (166 بايت) | عند اتصال الخادم |
| .claude/settings.json | موجود (5KB) | مع كل جلسة |

![رسم بياني شريطي يجمع مكوّنات .claude في مستودع ThakiCloud مُرتَّبةً حسب توقيت التحميل]({{ '/assets/images/claude-code-project-anatomy-complete-map-results.webp' | relative_url }})
*40 قاعدة و94 سطراً من CLAUDE.md هي تكلفة دائمة تدخل السياق مع كل دورة، بينما 1655 مهارة و54 وكيلاً أصول يدخلون السياق عند الطلب فحسب.*

هذه الأرقام تُثبت جوهر الخريطة بنفسها. لو أُدرجت الـ 1655 مهارة كلها في `CLAUDE.md` أو في القواعد، لتجاوزت كل جلسة حدّ السياق فوراً. في الواقع، تُحمَّل هذه المهارات الـ 1655 عند الطلب فحسب، ويُضيّق موجّه مستقل المرشحين في كل دورة. في المقابل، تُضبط تكلفة الحضور الدائم إرادياً عند 40 قاعدة، وهو نتاج ضبط نظافة يستهدف أقل من 2KB لكل ملف قاعدة مع تخفيض أي ملف يتجاوز ذلك إلى مهارة.

اللافت أننا حين انتهينا من قراءة مصدر هذا المقال، استخلصناه مباشرةً في ملف قاعدة باسم `claude-code-project-anatomy.md` وأدرجناه في المستودع. أي أن "خريطة بنية المشروع" ذاتها اجتازت شجرة القرار لتستقر قاعدةً دائمة الحضور. الخريطة وضعت نفسها على الخريطة.

## ما يعنيه هذا لمنتجات ThakiCloud

يتمثّل سجل SKILL.md وتعريفات الوكلاء الفرعيين وبنية القواعد في Claude Code في المبادئ التصميمية لـ Paxis، السحابة الأصيلة للوكلاء Agent-Native Cloud التي تطوّرها ThakiCloud حالياً في مرحلة إثبات المفهوم. يُشغّل Paxis منظومة Skill Harness التي تختار من بين أكثر من 960 مهارة عبر استرجاع BM25 وتنفّذها في بيئات عزل sandbox مستقلة، وهو تعميم على مستوى الإنتاج لنمط المهارة عند الطلب ذاته الذي يصفه هذا المقال. مبدأ "إبقاء ما هو دائم التحميل في حدوده الدنيا، ووضع سير العمل المتخصصة في المهارات الجاهزة عند الطلب" هو المبدأ نفسه الذي يعتمده Paxis في تعامله مع المهارات باعتبارها موارد أولى درجة. ومنهج "harness رفيع، مهارات سمينة" هو الأساس المعماري لسجل وكلاء Paxis.

يأخذ Paxis هذه البنية من بيئة المطوّر الفردي ويرفعها إلى وقت التشغيل الإنتاجي. يُدير المنصة مهاراتٍ وأدواتٍ وسياساتٍ وسجلاتِ تدقيق باعتبارها موارد أولى درجة، وينفّذ مستوى التحكم في الوكلاء عبر تنسيق متعدد الوكلاء بـ DAG، وجدولة المهام بالغة عربية طبيعية NL Cron، وموصّلات MCP. أما المهارات ذاتية التطوّر وبوابات السياسة فهي ارتقاء بفكرة agent-memory التي يُعبّر عنها Claude Code إلى مستوى المنتج: الفصل بين القناة التي تراكم فيها الوكلاء معرفتها المكتسبة والقناة التي يُراجعها فيها المسؤولون ويعتمدونها.

تُوفّر ai-platform نقاط نهاية LLM التي تُشغّل هذه المنظومة عند الاستنتاج، إذ تُشغّل ThakiCloud طبقة بنية AI/ML التحتية القائمة على Kubernetes مع خدمة نماذج متعددة المستأجرين عبر vLLM وجدولة GPU عبر Kueue، وهي الركيزة التنفيذية التي تستقبل طلبات استنتاج وكلاء Paxis وتعالجها.

## قيود وتحفظات

هذه الخريطة ليست حلاً مطلقاً. إليك تحفظات صريحة.

أولاً، حدود المكوّنات توصيات لا قيود. لا يمنعك Claude Code نفسه من وضع المحتوى الخاطئ في المكان الخاطئ. الالتزام بالحدود يبقى مسؤولية الفريق، وكما في حالتنا، يتطلب تثبيتها قواعد نظافة توكن وبوابات موجّه بالكود. قراءة الخريطة وحدها لا تُنظّف المستودع من تلقاء ذاته.

ثانياً، رقم 1655 مهارة ليس إنجازاً صافياً، بل سيف ذو حدّين. كلما زاد عدد المرشحين، زادت مخاطر توجيه الموجّه مهارةً خاطئة. المهارات عند الطلب لا تستهلك توكن دائمة، لكنها تُنتج تكلفة أخرى هي دقة البحث. "عند الطلب يعني مجاناً" استنتاج مبسّط.

ثالثاً، هذه البنية مُخصصة لـ Claude Code. الانتقال إلى بيئة تنفيذ وكلاء أخرى يغيّر اتفاقيات الدليل وآليات التحميل. لذا من الأجدر صياغة المعرفة ذاتها بحيادية تجاه بيئة التنفيذ، مع إبقاء التوصيل بالبيئة رفيعاً قدر الإمكان.

أخيراً، بعض أرقام المصدر، كـ 1000 توكن تقريباً لكل خادم MCP، تقديرات تتفاوت بحسب البيئة والإصدار. الأجدر قراءتها كاتجاه: "كل ما يُحمَّل دائماً يُكلّف"، لا كأرقام مطلقة.

## المصادر

- [Claude Code Project Structure Explained: The Complete 2026 Guide](https://www.prakashbhandari.com.np/posts/claude-code-project-structure-2026/) (Prakash Bhandari)
- [Explore the .claude directory (التوثيق الرسمي لـ Claude Code)](https://code.claude.com/docs/en/claude-directory)
- المستودع المقيس: مجلد `.claude` في مستودع ThakiCloud `ai-platform-strategy` (القياس بتاريخ 2026-06-27)
