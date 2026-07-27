---
title: "دليل RAGLight الشامل: من RAG الأساسي إلى سير العمل الوكيل"
excerpt: "إتقان إطار RAGLight مع أمثلة عملية تغطي RAG، Agentic RAG، RAT pipelines، وتكامل MCP لبناء أنظمة توليد معززة بالاسترجاع قوية."
seo_title: "دروس RAGLight: دليل إطار RAG الكامل - Thaki Cloud"
seo_description: "تعلم إطار RAGLight مع أمثلة عملية. بناء RAG، Agentic RAG، و RAT pipelines على macOS باستخدام Ollama أو OpenAI أو Mistral لتطبيقات الذكاء الاصطناعي الواعية بالسياق."
date: 2025-10-14
tags:
  - raglight
  - rag
  - agentic-rag
  - ollama
  - python
  - llm
  - vector-database
  - mcp
  - huggingface
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/raglight-comprehensive-guide/
canonical_url: "https://thakicloud.com/tech-blog/ar/tutorials/raglight-comprehensive-guide-ar/"
categories:
  - tutorials
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## مقدمة

**RAGLight** هو إطار عمل Python خفيف الوزن ومعياري مصمم لتبسيط تنفيذ **التوليد المعزز بالاسترجاع (Retrieval-Augmented Generation - RAG)**. من خلال الجمع بين استرجاع المستندات ونماذج اللغة الكبيرة (Large Language Models - LLM)، يتيح لك RAGLight بناء أنظمة ذكاء اصطناعي واعية بالسياق يمكنها الإجابة على الأسئلة بناءً على مستنداتك وقواعد معرفتك الخاصة.

في هذا الدليل الشامل، ستتعلم كيفية:

- إعداد RAGLight مع مزودي LLM المختلفين (Ollama، OpenAI، Mistral)
- بناء خطوط RAG الأساسية للإجابة على الأسئلة القائمة على المستندات
- تنفيذ Agentic RAG لمهام الاستدلال متعددة الخطوات
- استخدام RAT (Retrieval-Augmented Thinking) للاستدلال المحسّن
- دمج الأدوات الخارجية باستخدام MCP (Model Context Protocol)

### ما الذي يجعل RAGLight مميزاً؟

يتميز RAGLight بما يلي:

- **البنية المعيارية**: سهولة تبديل LLMs والتضمينات ومخازن المتجهات
- **دعم موفرين متعددين**: Ollama، OpenAI، Mistral، LMStudio، vLLM، Google AI
- **خطوط أنابيب متقدمة**: RAG الأساسي، Agentic RAG، و RAT مع طبقات الاستدلال
- **تكامل MCP**: ربط الأدوات ومصادر البيانات الخارجية بسلاسة
- **تكوين مرن**: تخصيص كل جانب من جوانب خط RAG الخاص بك

## المتطلبات الأساسية

قبل البدء في هذا الدليل، تأكد من توفر:

### 1. بيئة Python

```bash
# تحقق من إصدار Python (مطلوب 3.8 أو أعلى)
python3 --version

# إنشاء بيئة افتراضية (موصى به)
python3 -m venv raglight-env
source raglight-env/bin/activate  # على macOS/Linux
# raglight-env\Scripts\activate  # على Windows
```

### 2. تثبيت Ollama (لـ LLM المحلي)

```bash
# macOS
brew install ollama

# أو التنزيل من https://ollama.ai/download

# بدء خدمة Ollama
ollama serve

# سحب نموذج (في terminal جديد)
ollama pull llama3.2:3b
```

**البديل**: استخدم OpenAI أو Mistral API إذا كنت تفضل LLMs المستندة إلى السحابة.

### 3. تثبيت RAGLight

```bash
pip install raglight
```

## التثبيت والإعداد

### تكوين البيئة

أنشئ ملف `.env` لتخزين مفاتيح API الخاصة بك (عند استخدام موفري السحابة):

```bash
# ملف .env
OPENAI_API_KEY=your_openai_key_here
MISTRAL_API_KEY=your_mistral_key_here
```

### هيكل المشروع

قم بإعداد دليل مشروعك:

```bash
mkdir raglight-tutorial
cd raglight-tutorial
mkdir data
mkdir knowledge_base
```

### إنشاء بيانات تجريبية

أنشئ بعض المستندات التجريبية للاختبار:

```bash
# data/document1.txt
cat > data/document1.txt << 'EOF'
RAGLight هو إطار عمل Python معياري للتوليد المعزز بالاسترجاع.
يدعم العديد من موفري LLM بما في ذلك Ollama و OpenAI و Mistral.
تشمل الميزات الرئيسية التكامل المرن لمخزن المتجهات مع ChromaDB و FAISS.
EOF

# data/document2.txt
cat > data/document2.txt << 'EOF'
يوسع Agentic RAG RAG التقليدي من خلال دمج الوكلاء المستقلين.
يمكن لهؤلاء الوكلاء أداء الاستدلال متعدد الخطوات واسترجاع المعلومات الديناميكي.
تشمل حالات الاستخدام الإجابة على الأسئلة المعقدة ومساعدي الأبحاث.
EOF

# data/document3.txt
cat > data/document3.txt << 'EOF'
يضيف RAT (Retrieval-Augmented Thinking) طبقة استدلال متخصصة.
يستخدم LLMs الاستدلالية لتعزيز جودة الاستجابة والعمق التحليلي.
RAT مثالي للمهام التي تتطلب تفكيراً عميقاً واستدلالاً متعدد القفزات.
EOF
```

## خط RAG الأساسي

### فهم بنية RAG

يتكون خط RAG الأساسي من ثلاثة مكونات رئيسية:

1. **استيعاب المستندات (Document Ingestion)**: يتم تقسيم مستنداتك إلى أجزاء وتحويلها إلى تضمينات
2. **التخزين المتجه (Vector Storage)**: يتم تخزين التضمينات في قاعدة بيانات متجهات (ChromaDB، FAISS، إلخ)
3. **الاسترجاع والتوليد (Retrieval & Generation)**: عند الاستعلام، يتم استرجاع المستندات ذات الصلة وتمريرها إلى LLM

**الشكل 1. معمارية خط أنابيب RAGLight (RAG الأساسي، RAG الوكيل، RAT).**

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
<div class="d3-arch" data-arch-root id="ightcomprehensiveguidear-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 741, "height": 1036, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "D", "x": 199, "y": 24, "w": 120, "h": 46, "title": "Documents"}, {"id": "C", "x": 191, "y": 148, "w": 135, "h": 46, "title": "Chunk and Embed"}, {"id": "VS", "x": 160, "y": 272, "w": 198, "h": 62, "title": ["Vector Store: ChromaDB /", "FAISS / Qdrant"]}, {"id": "Q", "x": 413, "y": 280, "w": 120, "h": 46, "title": "User Query"}, {"id": "MODE", "x": 296, "y": 426, "w": 139, "h": 52, "title": "Pipeline Mode"}, {"id": "B1", "x": 581, "y": 702, "w": 128, "h": 46, "title": "Retrieve top-k"}, {"id": "B2", "x": 585, "y": 834, "w": 120, "h": 46, "title": "LLM Generate"}, {"id": "A1", "x": 270, "y": 694, "w": 191, "h": 62, "title": ["Agent Loop: reason then", "retrieve"]}, {"id": "A2", "x": 306, "y": 834, "w": 120, "h": 46, "title": "LLM Generate"}, {"id": "T1", "x": 60, "y": 570, "w": 120, "h": 46, "title": "Retrieve"}, {"id": "T2", "x": 24, "y": 694, "w": 191, "h": 62, "title": ["Reasoning LLM: thinking", "steps"]}, {"id": "T3", "x": 56, "y": 834, "w": 128, "h": 46, "title": "Generation LLM"}, {"id": "ANS", "x": 306, "y": 958, "w": 120, "h": 46, "title": "Answer"}], "edges": [{"src": "D", "dst": "C", "kind": "data", "line": [259, 70, 259, 148]}, {"src": "C", "dst": "VS", "kind": "data", "line": [259, 194, 259, 272]}, {"src": "Q", "dst": "MODE", "kind": "data", "curve": [[473, 326], [473, 380], [473, 380], [404, 426]]}, {"src": "VS", "dst": "MODE", "kind": "event", "label": "retrieve", "curve": [[259, 334], [259, 380], [259, 380], [327, 426]], "off": "50%"}, {"src": "MODE", "dst": "B1", "kind": "data", "label": "Basic RAG", "curve": [[435, 470], [645, 524], [645, 655], [645, 702]], "off": "50%"}, {"src": "B1", "dst": "B2", "kind": "data", "line": [645, 748, 645, 834]}, {"src": "MODE", "dst": "A1", "kind": "data", "label": "Agentic RAG", "line": [366, 478, 366, 694], "lx": 366, "ly": 589}, {"src": "A1", "dst": "A1", "kind": "data", "label": "iterate", "curve": [[461, 703], [511, 694], [511, 756], [461, 747]], "off": "50%"}, {"src": "A1", "dst": "A2", "kind": "data", "line": [366, 756, 366, 834]}, {"src": "MODE", "dst": "T1", "kind": "data", "label": "RAT", "curve": [[296, 472], [120, 524], [120, 524], [120, 570]], "off": "50%"}, {"src": "T1", "dst": "T2", "kind": "data", "line": [120, 616, 120, 694]}, {"src": "T2", "dst": "T3", "kind": "data", "line": [120, 756, 120, 834]}, {"src": "B2", "dst": "ANS", "kind": "data", "curve": [[645, 880], [645, 919], [645, 919], [426, 968]]}, {"src": "A2", "dst": "ANS", "kind": "data", "line": [366, 880, 366, 958]}, {"src": "T3", "dst": "ANS", "kind": "data", "curve": [[120, 880], [120, 919], [120, 919], [306, 966]]}]});
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
      const container = document.getElementById('ightcomprehensiveguidear-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ightcomprehensiveguidear-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

### التنفيذ

إليك مثال كامل لخط RAG أساسي:

```python
#!/usr/bin/env python3
"""خط RAG أساسي باستخدام RAGLight"""

from raglight.rag.simple_rag_api import RAGPipeline
from raglight.config.rag_config import RAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

# تحميل متغيرات البيئة
load_dotenv()

# إعداد التسجيل
Settings.setup_logging()

# تكوين مخزن المتجهات
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./chroma_db",
    collection_name="my_knowledge_base"
)

# تكوين RAG
config = RAGConfig(
    llm="llama3.2:3b",  # نموذج Ollama
    k=5,  # عدد المستندات للاسترجاع
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    knowledge_base=[FolderSource(path="./data")]
)

# تهيئة وبناء خط الأنابيب
print("تهيئة خط RAG...")
pipeline = RAGPipeline(config, vector_store_config)

print("بناء قاعدة المعرفة...")
pipeline.build()

# الاستعلام من خط الأنابيب
query = "ما هي الميزات الرئيسية لـ RAGLight؟"
print(f"\nالاستعلام: {query}")

response = pipeline.generate(query)
print(f"\nالاستجابة:\n{response}")
```

### خيارات التكوين الرئيسية

**خيارات مخزن المتجهات:**
- `database`: CHROMA أو FAISS أو QDRANT
- `provider`: HUGGINGFACE أو OLLAMA أو OPENAI للتضمينات
- `persist_directory`: مكان تخزين قاعدة بيانات المتجهات

**خيارات RAG:**
- `llm`: اسم النموذج (مثل "llama3.2:3b"، "gpt-4"، "mistral-large-2411")
- `k`: عدد المستندات ذات الصلة للاسترجاع
- `provider`: OLLAMA أو OPENAI أو MISTRAL أو LMSTUDIO أو GOOGLE

### استخدام موفري LLM المختلفين

**OpenAI:**
```python
config = RAGConfig(
    llm="gpt-4",
    k=5,
    provider=Settings.OPENAI,
    api_key=Settings.OPENAI_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

**Mistral:**
```python
config = RAGConfig(
    llm="mistral-large-2411",
    k=5,
    provider=Settings.MISTRAL,
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)
```

## خط Agentic RAG

### ما هو Agentic RAG؟

يوسع Agentic RAG RAG التقليدي من خلال دمج وكيل مستقل يمكنه:

- أداء الاستدلال متعدد الخطوات
- تحديد متى يتم استرجاع معلومات إضافية
- التكرار خلال دورات استرجاع-توليد متعددة
- التعامل مع الأسئلة المعقدة التي تتطلب مصادر بيانات متعددة

### التنفيذ

```python
"""خط Agentic RAG باستخدام RAGLight"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource
from dotenv import load_dotenv

load_dotenv()
Settings.setup_logging()

# تكوين مخزن المتجهات
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./agentic_chroma_db",
    collection_name="agentic_knowledge_base"
)

# تكوين Agentic RAG
config = AgenticRAGConfig(
    provider=Settings.MISTRAL,
    model="mistral-large-2411",
    k=10,
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,  # الحد الأقصى لخطوات الاستدلال
    api_key=Settings.MISTRAL_API_KEY,
    knowledge_base=[FolderSource(path="./data")]
)

# التهيئة والبناء
print("تهيئة خط Agentic RAG...")
agentic_rag = AgenticRAGPipeline(config, vector_store_config)

print("بناء قاعدة المعرفة...")
agentic_rag.build()

# استعلام معقد يتطلب خطوات متعددة
query = """
قارن قدرات RAG الأساسي و Agentic RAG.
ما هي حالات الاستخدام المحددة التي سيكون فيها Agentic RAG أكثر فائدة؟
"""

print(f"\nالاستعلام: {query}")
response = agentic_rag.generate(query)
print(f"\nالاستجابة:\n{response}")
```

### الميزات الرئيسية لـ Agentic RAG

**max_steps**: يتحكم في عدد تكرارات الاستدلال التي يمكن للوكيل تنفيذها
```python
# استعلام بسيط: خطوات أقل مطلوبة
config = AgenticRAGConfig(max_steps=2, ...)

# تحليل معقد: خطوات أكثر مسموح بها
config = AgenticRAGConfig(max_steps=10, ...)
```

**موجه وكيل مخصص**: تخصيص سلوك الوكيل
```python
custom_agent_prompt = """
أنت مساعد بحث. عند الإجابة على الأسئلة:
1. قسّم الاستعلامات المعقدة إلى أسئلة فرعية
2. استرجع المعلومات ذات الصلة لكل سؤال فرعي
3. اجمع النتائج في إجابة شاملة
4. اذكر المصادر عند الإمكان
"""

config = AgenticRAGConfig(
    system_prompt=custom_agent_prompt,
    ...
)
```

## RAT (التفكير المعزز بالاسترجاع)

### فهم RAT

يضيف RAT طبقة استدلال متخصصة إلى خط RAG:

1. **الاسترجاع (Retrieval)**: جلب المستندات ذات الصلة
2. **الاستدلال (Reasoning)**: استخدام LLM استدلالي لتحليل المحتوى المسترجع
3. **التفكير (Thinking)**: توليد خطوات استدلال وسيطة
4. **التوليد (Generation)**: إنتاج الإجابة النهائية مع سياق محسّن

### التنفيذ

```python
"""خط RAT باستخدام RAGLight"""

from raglight.rat.simple_rat_api import RATPipeline
from raglight.config.rat_config import RATConfig
from raglight.config.vector_store_config import VectorStoreConfig
from raglight.config.settings import Settings
from raglight.models.data_source_model import FolderSource

Settings.setup_logging()

# تكوين مخزن المتجهات
vector_store_config = VectorStoreConfig(
    embedding_model=Settings.DEFAULT_EMBEDDINGS_MODEL,
    api_base=Settings.DEFAULT_OLLAMA_CLIENT,
    provider=Settings.HUGGINGFACE,
    database=Settings.CHROMA,
    persist_directory="./rat_chroma_db",
    collection_name="rat_knowledge_base"
)

# تكوين RAT
config = RATConfig(
    cross_encoder_model=Settings.DEFAULT_CROSS_ENCODER_MODEL,
    llm="llama3.2:3b",
    k=Settings.DEFAULT_K,
    provider=Settings.OLLAMA,
    system_prompt=Settings.DEFAULT_SYSTEM_PROMPT,
    reasoning_llm=Settings.DEFAULT_REASONING_LLM,
    reflection=3,  # عدد تكرارات الاستدلال
    knowledge_base=[FolderSource(path="./data")]
)

# التهيئة والبناء
print("تهيئة خط RAT...")
pipeline = RATPipeline(config, vector_store_config)

print("بناء قاعدة المعرفة...")
pipeline.build()

# استعلام يتطلب استدلالاً عميقاً
query = """
حلل الاختلافات المعمارية بين RAG و Agentic RAG و RAT.
ما هي المقايضات من حيث التعقيد والأداء وجودة الإخراج؟
"""

print(f"\nالاستعلام: {query}")
response = pipeline.generate(query)
print(f"\nالاستجابة:\n{response}")
```

### خيارات تكوين RAT

**reflection**: عدد تكرارات الاستدلال
```python
# استدلال سريع
config = RATConfig(reflection=1, ...)

# تفكير تحليلي عميق
config = RATConfig(reflection=5, ...)
```

**cross_encoder_model**: نموذج إعادة الترتيب لاسترجاع أفضل
```python
config = RATConfig(
    cross_encoder_model="cross-encoder/ms-marco-MiniLM-L-12-v2",
    ...
)
```

## تكامل MCP

### ما هو MCP؟

يسمح Model Context Protocol (MCP) لخط RAG الخاص بك بالتفاعل مع الأدوات والخدمات الخارجية. هذا يتيح:

- تكامل البحث على الويب
- استعلامات قاعدة البيانات
- استدعاءات API للخدمات الخارجية
- بيئات تنفيذ الكود
- تكامل الأدوات المخصصة

### إعداد خادم MCP

أولاً، قم بتكوين خادم MCP الخاص بك (مثال باستخدام MCPClient):

```python
"""تكوين خادم MCP"""

from raglight.rag.simple_agentic_rag_api import AgenticRAGPipeline
from raglight.config.agentic_rag_config import AgenticRAGConfig
from raglight.config.settings import Settings

# تكوين عنوان URL لخادم MCP
config = AgenticRAGConfig(
    provider=Settings.OPENAI,
    model="gpt-4o",
    k=10,
    mcp_config=[
        {% raw %}{"url": "http://127.0.0.1:8001/sse"}{% endraw %}  # عنوان URL لخادم MCP الخاص بك
    ],
    system_prompt=Settings.DEFAULT_AGENT_PROMPT,
    max_steps=4,
    api_key=Settings.OPENAI_API_KEY
)

# التهيئة مع MCP
pipeline = AgenticRAGPipeline(config, vector_store_config)
pipeline.build()

# يمكن للوكيل الآن استخدام الأدوات الخارجية
query = "ابحث في الويب عن التحديثات الأخيرة على أطر RAG ولخص النتائج"
response = pipeline.generate(query)
```

### حالات استخدام MCP

**تكامل البحث على الويب:**
```python
# يمكن للوكيل البحث ودمج نتائج الويب
query = "ما هي آخر التطورات في تقنية RAG في عام 2024؟"
```

**استعلامات قاعدة البيانات:**
```python
# يمكن للوكيل الاستعلام عن قواعد البيانات للحصول على بيانات في الوقت الفعلي
query = "استرجع إحصائيات المستخدم من قاعدة بياناتنا وحلل الاتجاهات"
```

**تكامل API:**
```python
# يمكن للوكيل استدعاء APIs الخارجية
query = "تحقق من API الطقس وأوصِ بالأنشطة بناءً على التوقعات"
```

## مقارنة الأداء

### خصائص خطوط الأنابيب

| نوع خط الأنابيب | التعقيد | وقت الاستجابة | حالة الاستخدام |
|----------------|---------|---------------|-----------------|
| **RAG الأساسي** | منخفض | سريع (< 5 ثواني) | Q&A بسيط، البحث عن المستندات |
| **Agentic RAG** | متوسط | معتدل (5-15 ثانية) | استدلال متعدد الخطوات، بحث |
| **RAT** | عالي | بطيء (15-30 ثانية) | تحليل عميق، استدلال معقد |
| **RAG + MCP** | متغير | يعتمد على الأدوات | تكامل الأدوات الخارجية |

### اختيار خط الأنابيب المناسب

**استخدم RAG الأساسي عندما:**
- تحتاج إلى استجابات سريعة
- الأسئلة مباشرة
- البحث عن مستند واحد كافٍ

**استخدم Agentic RAG عندما:**
- الأسئلة تتطلب خطوات متعددة
- تحتاج إلى استرجاع ديناميكي
- المهمة تتضمن بحثاً أو استكشافاً

**استخدم RAT عندما:**
- مطلوب تفكير تحليلي عميق
- الجودة أكثر أهمية من السرعة
- مطلوب استدلال معقد متعدد القفزات

**استخدم تكامل MCP عندما:**
- تحتاج إلى بيانات خارجية في الوقت الفعلي
- المهمة تتطلب استخدام أدوات
- المعلومات الديناميكية ضرورية

## أفضل الممارسات

### 1. إعداد المستندات

**تحسين حجم الجزء:**
```python
# للمستندات التقنية
chunk_size = 512

# للمحتوى السردي
chunk_size = 1024
```

**تنظيم المجلدات:**
```
knowledge_base/
├── technical_docs/
├── user_manuals/
├── api_reference/
└── faq/
```

### 2. إدارة مخزن المتجهات

**الاستمرارية:**
```python
# استخدم دائماً التخزين الدائم في الإنتاج
vector_store_config = VectorStoreConfig(
    persist_directory="./prod_vectordb",
    collection_name="production_kb"
)
```

**تنظيم المجموعات:**
```python
# مجموعات منفصلة للمجالات المختلفة
collections = {
    "technical": "tech_docs_collection",
    "business": "business_docs_collection",
    "general": "general_knowledge_collection"
}
```

### 3. اختيار LLM

**التطوير:**
```python
# استخدم النماذج المحلية للتطوير
config = RAGConfig(
    llm="llama3.2:3b",
    provider=Settings.OLLAMA
)
```

**الإنتاج:**
```python
# استخدم نماذج أقوى للإنتاج
config = RAGConfig(
    llm="gpt-4",
    provider=Settings.OPENAI
)
```

### 4. معالجة الأخطاء

```python
"""خط RAG قوي مع معالجة الأخطاء"""

try:
    pipeline = RAGPipeline(config, vector_store_config)
    pipeline.build()
    response = pipeline.generate(query)
except Exception as e:
    print(f"خطأ في خط الأنابيب: {e}")
    # الرجوع إلى LLM الأساسي بدون RAG
    response = fallback_generate(query)
```

### 5. تكوين المجلدات المتجاهلة

عند فهرسة مستودعات الكود، استبعد الدلائل غير الضرورية:

```python
# مجلدات مخصصة للتجاهل
custom_ignore_folders = [
    ".venv",
    "venv",
    "node_modules",
    "__pycache__",
    ".git",
    "build",
    "dist",
    "my_custom_folder_to_ignore"
]

config = AgenticRAGConfig(
    ignore_folders=custom_ignore_folders,
    ...
)
```

### 6. المراقبة والتسجيل

```python
"""تمكين التسجيل التفصيلي"""

import logging

# تكوين مستوى التسجيل
logging.basicConfig(level=logging.INFO)

# أو استخدم إعداد RAGLight
Settings.setup_logging()

# مراقبة الأداء
import time

start_time = time.time()
response = pipeline.generate(query)
elapsed_time = time.time() - start_time

print(f"تمت معالجة الاستعلام في {elapsed_time:.2f}ث")
```

## التخصيص المتقدم

### منشئ خط أنابيب مخصص

```python
"""خط RAG مخصص بنمط المنشئ"""

from raglight.rag.builder import Builder
from raglight.config.settings import Settings

# بناء خط أنابيب مخصص
rag = Builder() \
    .with_embeddings(
        Settings.HUGGINGFACE,
        model_name=Settings.DEFAULT_EMBEDDINGS_MODEL
    ) \
    .with_vector_store(
        Settings.CHROMA,
        persist_directory="./custom_db",
        collection_name="custom_collection"
    ) \
    .with_llm(
        Settings.OLLAMA,
        model_name="llama3.2:3b",
        system_prompt_file="./custom_prompt.txt",
        provider=Settings.OLLAMA
    ) \
    .build_rag(k=5)

# استيعاب المستندات
rag.vector_store.ingest(data_path='./data')

# الاستعلام
response = rag.generate("سؤالك هنا")
```

### فهرسة مستودع الكود

```python
"""فهرسة مستودعات الكود"""

# فهرسة الكود مع استخراج التوقيعات
rag.vector_store.ingest(repos_path=['./repo1', './repo2'])

# البحث عن الكود
code_results = rag.vector_store.similarity_search("منطق المصادقة")

# البحث عن توقيعات الصف
class_results = rag.vector_store.similarity_search_class("تعريف صف User")
```

### تكامل مستودع GitHub

```python
"""فهرسة مستودعات GitHub مباشرة"""

from raglight.models.data_source_model import GitHubSource

knowledge_base = [
    GitHubSource(url="https://github.com/Bessouat40/RAGLight"),
    GitHubSource(url="https://github.com/your-org/your-repo")
]

config = RAGConfig(
    knowledge_base=knowledge_base,
    ...
)
```

## نشر Docker

### مثال Dockerfile

```dockerfile
FROM python:3.10-slim

WORKDIR /app

# تثبيت التبعيات
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# نسخ التطبيق
COPY . .

# إضافة تعيين المضيف لـ Ollama/LMStudio
# التشغيل: docker run --add-host=host.docker.internal:host-gateway your-image

CMD ["python", "app.py"]
```

### البناء والتشغيل

```bash
# بناء الصورة
docker build -t raglight-app .

# التشغيل مع الوصول إلى شبكة المضيف (لـ Ollama)
docker run --add-host=host.docker.internal:host-gateway raglight-app
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

**1. خطأ اتصال Ollama:**
```python
# تحقق من تشغيل Ollama
# macOS/Linux:
ollama serve

# تحديث قاعدة API إذا لزم الأمر
vector_store_config = VectorStoreConfig(
    api_base="http://localhost:11434",  # عنوان URL الافتراضي لـ Ollama
    ...
)
```

**2. مشاكل الذاكرة:**
```python
# تقليل حجم الجزء وقيمة k
config = RAGConfig(
    k=3,  # استرجاع عدد أقل من المستندات
    ...
)
```

**3. الأداء البطيء:**
```python
# استخدام نماذج تضمين أصغر
vector_store_config = VectorStoreConfig(
    embedding_model="all-MiniLM-L6-v2",  # نموذج أصغر وأسرع
    ...
)
```

**4. أخطاء مخزن المتجهات:**
```bash
# المسح وإعادة البناء
rm -rf ./chroma_db
python rebuild_kb.py
```

## الخلاصة

يوفر RAGLight إطار عمل قوي ومرن لبناء أنظمة التوليد المعززة بالاسترجاع. سواء كنت بحاجة إلى Q&A بسيط للمستندات أو سير عمل وكيل معقدة مع تكامل الأدوات الخارجية، فإن البنية المعيارية لـ RAGLight تجعل من السهل البناء والتوسع.

### النقاط الرئيسية

- **ابدأ ببساطة**: ابدأ بـ RAG الأساسي وقم بالترقية إلى Agentic RAG أو RAT حسب الحاجة
- **اختر بحكمة**: اختر خط الأنابيب المناسب بناءً على حالة الاستخدام ومتطلبات الأداء
- **خصص بشكل واسع**: يتيح تصميم RAGLight المعياري التخصيص الكامل
- **قم بالتوسع تدريجياً**: ابدأ محلياً مع Ollama، ثم انتقل إلى موفري السحابة للإنتاج

### الخطوات التالية

1. **تجربة**: جرب موفري LLM ومخازن المتجهات المختلفة
2. **تحسين**: ضبط قيم k وأحجام الأجزاء واختيار النماذج
3. **دمج**: أضف خوادم MCP للوصول إلى الأدوات الخارجية
4. **نشر**: احتوي مع Docker للنشر في الإنتاج

### الموارد

- **RAGLight GitHub**: [https://github.com/Bessouat40/RAGLight](https://github.com/Bessouat40/RAGLight)
- **حزمة PyPI**: [https://pypi.org/project/raglight/](https://pypi.org/project/raglight/)
- **Ollama**: [https://ollama.ai](https://ollama.ai)
- **ChromaDB**: [https://www.trychroma.com](https://www.trychroma.com)
- **بروتوكول MCP**: ابحث عن "Model Context Protocol" للوثائق

بناءً سعيداً مع RAGLight! 🚀

