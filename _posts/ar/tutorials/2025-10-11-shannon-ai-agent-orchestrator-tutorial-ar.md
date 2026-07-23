---
title: "Shannon AI Agent Orchestrator: دليل شامل لإدارة وكلاء الذكاء الاصطناعي على مستوى المؤسسات"
excerpt: "تعلم كيفية إعداد واستخدام Shannon، منسق وكلاء الذكاء الاصطناعي مفتوح المصدر مع أمان على مستوى المؤسسات وضوابط التكلفة ومرونة البائعين. دليل شامل من التثبيت إلى سير العمل المتقدم متعدد الوكلاء."
seo_title: "دروس Shannon AI Agent Orchestrator - إدارة وكلاء الذكاء الاصطناعي للمؤسسات"
seo_description: "دروس شاملة لـ Shannon AI Agent Orchestrator: التثبيت والتكوين وسير العمل متعدد الوكلاء وميزات الأمان ودليل النشر للمؤسسات."
date: 2025-10-11
tags:
  - AI-Agent
  - Orchestrator
  - Multi-Agent
  - Enterprise-AI
  - Shannon
  - Docker
  - Microservices
  - LLM
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/shannon-ai-agent-orchestrator-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/shannon-ai-agent-orchestrator-tutorial-ar/"
categories:
  - tutorials
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## مقدمة

Shannon هو منسق وكلاء الذكاء الاصطناعي مفتوح المصدر يوفر أماناً على مستوى المؤسسات وضوابط التكلفة ومرونة البائعين. على عكس الحلول الاحتكارية مثل OpenAI AgentKit، يوفر Shannon تحكماً كاملاً في البنية التحتية للذكاء الاصطناعي مع الحفاظ على الموثوقية والقابلية للتوسع الجاهزة للإنتاج.

### ما يجعل Shannon مميزاً

يتميز Shannon في مجال تنسيق وكلاء الذكاء الاصطناعي بهندسته المعمارية الفريدة وميزاته:

- **هندسة متعددة اللغات**: منسق Go، نواة الوكيل Rust، خدمة LLM Python
- **أمان المؤسسات**: تطبيق سياسات OPA، صندوق الحماية WASI، التحكم الدقيق في الوصول
- **إدارة التكلفة**: إدارة ميزانية الرموز، أنماط قاطع الدائرة، الاسترداد التلقائي من الأعطال
- **مرونة البائع**: دعم متعدد الموردين LLM (OpenAI، Anthropic، Google، DeepSeek)
- **ذاكرة متقدمة**: ذاكرة متجهة مع Qdrant، ذاكرة هرمية، كشف التكرار
- **التواصل في الوقت الفعلي**: تدفق WebSocket و SSE مع تصفية الأحداث

## المتطلبات المسبقة

قبل بدء هذا البرنامج التعليمي، تأكد من وجود:

- Docker و Docker Compose مثبتان
- فهم أساسي للتطبيقات المحتواة
- الإلمام بـ REST APIs والخدمات المصغرة
- مفتاح API من موفر LLM واحد على الأقل (OpenAI، Anthropic، إلخ)

## التثبيت والإعداد

### 1. استنساخ المستودع

```bash
git clone https://github.com/Kocoro-lab/Shannon.git
cd Shannon
```

### 2. تكوين البيئة

إنشاء ملف تكوين البيئة:

```bash
cp .env.example .env
```

تحرير ملف `.env` مع التكوين الخاص بك:

```bash
# تكوين موفر LLM
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# تكوين قاعدة البيانات
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=shannon
POSTGRES_USER=shannon
POSTGRES_PASSWORD=your_secure_password

# تكوين Redis
REDIS_HOST=redis
REDIS_PORT=6379

# قاعدة بيانات Qdrant المتجهة
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# منافذ الخدمة
ORCHESTRATOR_PORT=8080
AGENT_CORE_PORT=8081
LLM_SERVICE_PORT=8082
```

### 3. بدء خدمات Shannon

يوفر Shannon ملف Makefile مريح لإدارة الخدمات:

```bash
# بدء جميع الخدمات
make up

# عرض حالة الخدمة
make ps

# عرض السجلات
make logs

# إيقاف الخدمات
make down
```

### 4. التحقق من التثبيت

تحقق من تشغيل جميع الخدمات:

```bash
# فحص صحة المنسق
curl http://localhost:8080/health

# فحص صحة نواة الوكيل
curl http://localhost:8081/health

# فحص صحة خدمة LLM
curl http://localhost:8082/health
```

## المفاهيم الأساسية

### نظرة عامة على الهندسة المعمارية

يتبع Shannon هندسة الخدمات المصغرة مع ثلاثة مكونات رئيسية:

1. **منسق Go**: يدير سير العمل والجلسات وتنسيق الوكلاء
2. **نواة الوكيل Rust**: يتعامل مع تنفيذ الوكيل وإدارة الذاكرة وتكامل الأدوات
3. **خدمة LLM Python**: توفر واجهة موحدة لموفري LLM متعددين

**الشكل 1. هندسة منسق Shannon (منسق Go، نواة الوكيل Rust، خدمة LLM Python).**

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
<div class="d3-arch" data-arch-root id="ntorchestratortutorialar-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 718, "height": 708, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Client", "x": 239, "y": 24, "w": 149, "h": 46, "title": "Client / REST API"}, {"id": "GO", "x": 207, "y": 148, "w": 212, "h": 78, "title": ["Go Orchestrator:", "workflows, sessions, agent", "coordination"]}, {"id": "RUST", "x": 214, "y": 304, "w": 198, "h": 62, "title": ["Rust Agent Core:", "execution, memory, tools"]}, {"id": "PY", "x": 474, "y": 466, "w": 212, "h": 62, "title": ["Python LLM Service:", "unified provider interface"]}, {"id": "LLM", "x": 485, "y": 614, "w": 191, "h": 62, "title": ["LLM Providers: OpenAI /", "Anthropic / others"]}, {"id": "PAT", "x": 207, "y": 458, "w": 212, "h": 78, "title": ["ReAct / Tree-of-Thoughts /", "Chain-of-Thought / Debate", "/ Reflection"]}, {"id": "MEM", "x": 24, "y": 474, "w": 128, "h": 46, "title": "Session Memory"}], "edges": [{"src": "Client", "dst": "GO", "kind": "data", "line": [313, 70, 313, 148]}, {"src": "GO", "dst": "RUST", "kind": "data", "line": [313, 226, 313, 304]}, {"src": "RUST", "dst": "PY", "kind": "data", "curve": [[412, 364], [580, 412], [580, 412], [580, 466]]}, {"src": "PY", "dst": "LLM", "kind": "data", "line": [580, 528, 580, 614]}, {"src": "RUST", "dst": "PAT", "kind": "event", "label": "patterns", "line": [313, 366, 313, 458], "lx": 313, "ly": 408}, {"src": "RUST", "dst": "MEM", "kind": "data", "curve": [[222, 366], [88, 412], [88, 412], [88, 474]]}]});
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
      const container = document.getElementById('ntorchestratortutorialar-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ntorchestratortutorialar-1';
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

### أنماط الوكيل

يدعم Shannon أنماط تنسيق متعددة:

- **ReAct**: التفكير والعمل في نماذج اللغة
- **Tree-of-Thoughts**: استكشاف مسارات التفكير المتعددة
- **Chain-of-Thought**: خطوات التفكير المتسلسلة
- **Debate**: وكلاء متعددون يناقشون ويصلون إلى إجماع
- **Reflection**: التقييم الذاتي والتحسين

## دروس الاستخدام الأساسي

### 1. إنشاء وكيلك الأول

لننشئ وكيلاً بسيطاً يمكنه الإجابة على الأسئلة وأداء المهام الأساسية:

```bash
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "research-assistant",
    "description": "مساعد بحث مفيد",
    "system_prompt": "أنت مساعد بحث مطلع. قدم إجابات دقيقة ومدروسة جيداً لأسئلة المستخدمين.",
    "model_provider": "openai",
    "model_name": "gpt-4",
    "max_tokens": 2000,
    "temperature": 0.7
  }'
```

### 2. بدء جلسة

إنشاء جلسة للتفاعل مع وكيلك:

```bash
curl -X POST http://localhost:8080/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "research-assistant",
    "session_config": {
      "max_turns": 50,
      "context_window": 10,
      "memory_enabled": true
    }
  }'
```

### 3. إرسال الرسائل

إرسال رسالة إلى وكيلك:

```bash
curl -X POST http://localhost:8080/api/v1/sessions/{session_id}/messages \
  -H "Content-Type: application/json" \
  -d '{
    "content": "ما هي الفوائد الرئيسية لهندسة الخدمات المصغرة؟",
    "message_type": "user"
  }'
```

### 4. الاستجابات المتدفقة

للاستجابات في الوقت الفعلي، استخدم نقطة النهاية المتدفقة:

```bash
curl -N http://localhost:8080/api/v1/sessions/{session_id}/stream \
  -H "Accept: text/event-stream"
```

## الميزات المتقدمة

### سير العمل متعدد الوكلاء

يتفوق Shannon في تنسيق وكلاء متعددين يعملون معاً. إليك كيفية إعداد سير عمل متعدد الوكلاء:

#### 1. تحديد أدوار الوكيل

```yaml
# workflow.yaml
name: "content-creation-pipeline"
description: "سير عمل إنشاء المحتوى متعدد الوكلاء"

agents:
  - name: "researcher"
    role: "research"
    system_prompt: "أنت باحث شامل. اجمع معلومات شاملة حول المواضيع المعطاة."
    model: "gpt-4"
    
  - name: "writer"
    role: "content-creation"
    system_prompt: "أنت كاتب ماهر. أنشئ محتوى جذاب بناءً على البحث."
    model: "claude-3-sonnet"
    
  - name: "editor"
    role: "review"
    system_prompt: "أنت محرر دقيق. راجع وحسن جودة المحتوى."
    model: "gpt-4"

workflow:
  pattern: "sequential"
  steps:
    - agent: "researcher"
      task: "ابحث في الموضوع المعطى بشمولية"
      output_to: ["writer"]
      
    - agent: "writer"
      task: "أنشئ محتوى بناءً على البحث"
      input_from: ["researcher"]
      output_to: ["editor"]
      
    - agent: "editor"
      task: "راجع وحسن المحتوى"
      input_from: ["writer"]
      final_output: true
```

#### 2. تنفيذ سير العمل متعدد الوكلاء

```bash
curl -X POST http://localhost:8080/api/v1/workflows \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_file": "workflow.yaml",
    "input": {
      "topic": "مستقبل الذكاء الاصطناعي في الرعاية الصحية",
      "target_audience": "المهنيين الصحيين",
      "word_count": 1500
    }
  }'
```

### إدارة الذاكرة

يوفر Shannon قدرات إدارة ذاكرة متطورة:

#### تكوين الذاكرة المتجهة

```json
{
  "memory_config": {
    "vector_memory": {
      "enabled": true,
      "collection_name": "agent_memory",
      "embedding_model": "text-embedding-ada-002",
      "similarity_threshold": 0.8,
      "max_results": 10
    },
    "hierarchical_memory": {
      "enabled": true,
      "recent_messages": 20,
      "semantic_compression": true,
      "deduplication_threshold": 0.95
    }
  }
}
```

#### الاستعلام عن ذاكرة الوكيل

```bash
curl -X GET "http://localhost:8080/api/v1/sessions/{session_id}/memory?query=فوائد+الخدمات+المصغرة&limit=5" \
  -H "Accept: application/json"
```

### الأمان والتحكم في الوصول

يستخدم Shannon Open Policy Agent (OPA) للتحكم الدقيق في الوصول:

#### 1. تحديد سياسات الأمان

```rego
# policies/agent_access.rego
package shannon.agent_access

import future.keywords.if

# السماح بالوصول إذا كان لدى المستخدم الدور المطلوب
allow if {
    input.user.roles[_] == "agent_operator"
    input.action == "create_agent"
}

# تقييد الوصول للنموذج بناءً على مستوى المستخدم
allow if {
    input.user.tier == "premium"
    input.agent.model in ["gpt-4", "claude-3-opus"]
}

# تطبيق الميزانية
allow if {
    input.user.monthly_budget > input.estimated_cost
}
```

#### 2. تطبيق السياسات

```bash
curl -X POST http://localhost:8080/api/v1/policies \
  -H "Content-Type: application/json" \
  -d '{
    "name": "agent_access_policy",
    "policy_file": "policies/agent_access.rego",
    "enabled": true
  }'
```

### إدارة التكلفة

يوفر Shannon ميزات إدارة تكلفة شاملة:

#### 1. تعيين حدود الميزانية

```bash
curl -X POST http://localhost:8080/api/v1/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user123",
    "monthly_limit": 100.00,
    "per_session_limit": 10.00,
    "alert_threshold": 0.8,
    "currency": "USD"
  }'
```

#### 2. مراقبة الاستخدام

```bash
curl -X GET http://localhost:8080/api/v1/usage/user123 \
  -H "Accept: application/json"
```

### تكامل الأدوات

يدعم Shannon طرق تكامل أدوات متعددة:

#### 1. أدوات MCP (Model Context Protocol)

```json
{
  "tools": [
    {
      "type": "mcp",
      "name": "file_operations",
      "server_url": "mcp://localhost:3000",
      "capabilities": ["read_file", "write_file", "list_directory"]
    }
  ]
}
```

#### 2. أدوات OpenAPI

```json
{
  "tools": [
    {
      "type": "openapi",
      "name": "weather_api",
      "spec_url": "https://api.weather.com/openapi.json",
      "auth": {
        "type": "api_key",
        "key": "your_weather_api_key"
      }
    }
  ]
}
```

## النشر الإنتاجي

### إعداد Docker Compose للإنتاج

للنشر الإنتاجي، استخدم التكوين الإنتاجي المقدم:

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  orchestrator:
    image: shannon/orchestrator:latest
    environment:
      - ENV=production
      - LOG_LEVEL=info
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  agent-core:
    image: shannon/agent-core:latest
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 2G
          cpus: '1.0'

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: shannon_prod
      POSTGRES_USER: shannon
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 2G

volumes:
  postgres_data:
```

### نشر Kubernetes

يوفر Shannon أيضاً بيانات Kubernetes للنشر السحابي:

```yaml
# k8s/orchestrator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shannon-orchestrator
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shannon-orchestrator
  template:
    metadata:
      labels:
        app: shannon-orchestrator
    spec:
      containers:
      - name: orchestrator
        image: shannon/orchestrator:latest
        ports:
        - containerPort: 8080
        env:
        - name: POSTGRES_HOST
          value: "postgres-service"
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## المراقبة والملاحظة

يتضمن Shannon قدرات مراقبة شاملة:

### 1. جمع المقاييس

يعرض Shannon مقاييس Prometheus:

```bash
# عرض المقاييس المتاحة
curl http://localhost:8080/metrics
```

### 2. لوحات معلومات Grafana

استيراد لوحة معلومات Grafana المقدمة:

```bash
# استيراد لوحة معلومات Shannon
curl -X POST http://grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @observability/grafana/shannon-dashboard.json
```

### 3. التتبع الموزع

تمكين التتبع الموزع مع Jaeger:

```yaml
# docker-compose.yml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### 1. مشاكل اتصال الخدمة

```bash
# فحص سجلات الخدمة
make logs

# إعادة تشغيل خدمة محددة
docker-compose restart orchestrator

# فحص اتصال الشبكة
docker network ls
docker network inspect shannon_default
```

#### 2. مشاكل الذاكرة

```bash
# مراقبة استخدام الذاكرة
docker stats

# تعديل حدود الذاكرة في docker-compose.yml
services:
  agent-core:
    deploy:
      resources:
        limits:
          memory: 4G
```

#### 3. مشاكل اتصال قاعدة البيانات

```bash
# فحص سجلات PostgreSQL
docker-compose logs postgres

# اختبار اتصال قاعدة البيانات
docker-compose exec postgres psql -U shannon -d shannon -c "SELECT 1;"
```

### تحسين الأداء

#### 1. تجميع الاتصالات

تكوين تجميع الاتصالات لأداء أفضل:

```yaml
# config/database.yaml
database:
  max_connections: 100
  max_idle_connections: 10
  connection_max_lifetime: 3600
```

#### 2. تكوين التخزين المؤقت

تحسين تخزين Redis المؤقت:

```yaml
# config/redis.yaml
redis:
  max_connections: 50
  idle_timeout: 300
  cache_ttl: 3600
```

## أفضل الممارسات

### 1. تصميم الوكيل

- **المسؤولية الواحدة**: تصميم وكلاء بأدوار محددة ومعرفة جيداً
- **تعليمات النظام الواضحة**: تقديم تعليمات مفصلة وغير غامضة
- **اختيار النموذج المناسب**: اختيار النماذج بناءً على تعقيد المهمة ومتطلبات التكلفة

### 2. تصميم سير العمل

- **معالجة الأخطاء**: تنفيذ معالجة أخطاء قوية وآليات احتياطية
- **إدارة الموارد**: تعيين مهلات زمنية وحدود موارد مناسبة
- **المراقبة**: تضمين تسجيل ومراقبة شاملين

### 3. الأمان

- **إدارة مفاتيح API**: استخدام أنظمة إدارة أسرار آمنة
- **التحكم في الوصول**: تنفيذ سياسات تحكم وصول دقيقة
- **تسجيل المراجعة**: تمكين تسجيل مراجعة شامل للامتثال

### 4. تحسين التكلفة

- **مراقبة الميزانية**: إعداد تنبيهات لحدود الميزانية
- **اختيار النموذج**: استخدام نماذج فعالة من حيث التكلفة للمهام المناسبة
- **التخزين المؤقت**: تنفيذ تخزين مؤقت ذكي لتقليل استدعاءات API

## الخلاصة

يوفر Shannon AI Agent Orchestrator منصة قوية ومرنة لبناء ونشر أنظمة وكلاء الذكاء الاصطناعي على مستوى المؤسسات. مع هندسته المعمارية للخدمات المصغرة وميزات الأمان الشاملة وقدرات التنسيق المتقدمة، يمكن Shannon للمؤسسات من تسخير قوة وكلاء الذكاء الاصطناعي مع الحفاظ على التحكم والأمان وكفاءة التكلفة.

تضمن طبيعة المنصة مفتوحة المصدر الشفافية وقابلية التخصيص، بينما تجعل ميزاتها الجاهزة للإنتاج مناسبة للنشر المؤسسي. سواء كنت تبني روبوتات محادثة بسيطة أو سير عمل معقد متعدد الوكلاء، يوفر Shannon الأدوات والبنية التحتية اللازمة للنجاح.

### الخطوات التالية

1. **استكشاف الأنماط المتقدمة**: تجريب أنماط تنسيق مختلفة مثل Tree-of-Thoughts و Debate
2. **تطوير أدوات مخصصة**: إنشاء أدوات مخصصة باستخدام بروتوكول MCP
3. **النشر الإنتاجي**: نشر Shannon في بيئتك الإنتاجية
4. **المشاركة المجتمعية**: انضم إلى مجتمع Shannon على Discord وساهم في المشروع

### الموارد

- **مستودع GitHub**: [https://github.com/Kocoro-lab/Shannon](https://github.com/Kocoro-lab/Shannon)
- **التوثيق**: متاح في دليل `docs/`
- **مجتمع Discord**: انضم للدعم والمناقشات
- **دليل المساهمة**: راجع `CONTRIBUTING.md` لإرشادات المساهمة

يمثل Shannon مستقبل تنسيق وكلاء الذكاء الاصطناعي - مفتوح وآمن وجاهز للمؤسسات. ابدأ في بناء أنظمة وكلاء الذكاء الاصطناعي اليوم!
