---
title: "ByteDance Dolphin لتحليل صور المستندات: تحليل شامل لمجموعة بيانات Fox والاختبارات المرجعية"
excerpt: "تحليل مفصل لمجموعة بيانات Fox والاختبارات المرجعية لمشروع Dolphin الصادر عن ByteDance. تعرف على أحدث تقنيات فهم المستندات المنشورة في ACL 2025 ومجموعة البيانات الضخمة المكونة من أكثر من 30 مليون نموذج."
seo_title: "تحليل ByteDance Dolphin Fox - دليل الاختبارات المرجعية لتحليل صور المستندات - Thaki Cloud"
seo_description: "تحليل شامل لمجموعة بيانات Fox والاختبارات المرجعية لـ ByteDance Dolphin. شرح مفصل لأحدث تقنيات فهم المستندات بالذكاء الاصطناعي المبنية على ورقة ACL 2025 ومجموعة البيانات المكونة من 30 مليون نموذج."
date: 2025-08-08
last_modified_at: 2025-08-08
tags:
  - dolphin
  - bytedance
  - document-parsing
  - fox-dataset
  - acl-2025
  - multimodal
  - vision-language-model
  - ocr
  - document-understanding
  - benchmark
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/datasets/bytedance-dolphin-document-parsing-dataset-fox-benchmark-guide/"
reading_time: true
lang: ar
published: true
categories:
  - datasets
  - research
---

⏱️ **وقت القراءة المقدر**: 18 دقائق

![نظرة عامة على خط معالجة Analyze-then-Parse في ByteDance Dolphin]({{ '/assets/images/bytedance-dolphin-document-parsing-dataset-fox-benchmark-guide-hero.png' | relative_url }})

## مقدمة

تحليل صور المستندات (Document Image Parsing) هو تقنية ذكاء اصطناعي محورية لاستخراج معلومات منظمة من المستندات الممسوحة ضوئيا أو ملفات PDF أو المستندات الملتقطة بالكاميرا. يقدم مشروع Dolphin الذي طورته ByteDance نهجا مبتكرا في هذا المجال، وقد نشر الفريق مجموعة بيانات Fox واختباراتها المرجعية استنادا إلى نتائج البحث المنشور في [ACL 2025](https://arxiv.org/abs/2505.14059).

في هذا المقال، سنحلل تقنيات Dolphin الجوهرية، إضافة إلى مجموعة البيانات الضخمة التي بناها الباحثون، ولا سيما تكوين الاختبار المرجعي Fox-Page وطرق استخدامه.

## 🎯 نظرة عامة على مشروع Dolphin

### الفكرة الجوهرية: نموذج Analyze-then-Parse

اعتمد [Dolphin](https://github.com/bytedance/Dolphin) نهج "التحليل ثم التحويل (Analyze-then-Parse)" المتميز عن منهجيات تحليل المستندات التقليدية.

#### قيود المنهجيات التقليدية

```python
# 기존 방법: 전문 모델 조합 방식
traditional_pipeline = {
    "layout_detection": "YOLO/Faster R-CNN",
    "ocr_engine": "Tesseract/PaddleOCR", 
    "table_extraction": "TableNet/CascadeTabNet",
    "formula_recognition": "Im2Latex/InftyReader"
}
# 문제점: 통합 오버헤드, 일관성 부족, 높은 복잡도
```

```python
# 기존 방법: 자기회귀 생성 방식  
autoregressive_approach = {
    "input": "document_image",
    "output": "sequential_text_generation",
    "problem": "layout_structure_degradation"
}
# 문제점: 레이아웃 구조 손실, 효율성 저하
```

#### النهج المبتكر لـ Dolphin

```python
# Dolphin: 2단계 분석-파싱 패러다임
dolphin_paradigm = {
    "stage_1": {
        "task": "layout_analysis",
        "output": "element_sequence_in_reading_order",
        "elements": ["text", "table", "figure", "formula"]
    },
    "stage_2": {
        "task": "parallel_element_parsing", 
        "method": "heterogeneous_anchor_prompting",
        "efficiency": "parallel_processing"
    }
}
```

### 🏗️ البنية المعمارية للنموذج

يستند Dolphin إلى بنية Vision-Encoder-Decoder:

يوضح المخطط أدناه كيف يتم تحويل صورة المستند إلى مخرجات منظمة من خلال مسار التحليل ثم التحويل (Analyze-then-Parse) ذي المرحلتين:

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
<div class="d3-arch" data-arch-root id="datasetfoxbenchmarkguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 701, "height": 1050, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IMG", "x": 283, "y": 24, "w": 128, "h": 46, "title": "Document image"}, {"id": "ENC", "x": 265, "y": 148, "w": 163, "h": 62, "title": ["Vision Encoder Swin", "Transformer"]}, {"id": "S1", "x": 251, "y": 288, "w": 191, "h": 46, "title": "Stage 1 Layout Analysis"}, {"id": "SEQ", "x": 265, "y": 412, "w": 163, "h": 62, "title": ["Element sequence in", "reading order"]}, {"id": "S2", "x": 248, "y": 552, "w": 198, "h": 62, "title": ["Stage 2 Parallel Element", "Parsing"]}, {"id": "T", "x": 549, "y": 692, "w": 120, "h": 46, "title": "Text blocks"}, {"id": "TB", "x": 374, "y": 692, "w": 120, "h": 46, "title": "Tables"}, {"id": "FM", "x": 199, "y": 692, "w": 120, "h": 46, "title": "Formulas"}, {"id": "FG", "x": 24, "y": 692, "w": 120, "h": 46, "title": "Figures"}, {"id": "DEC", "x": 251, "y": 816, "w": 191, "h": 62, "title": ["Text Decoder MBart with", "anchor prompts"]}, {"id": "OUT", "x": 265, "y": 956, "w": 163, "h": 62, "title": ["Structured JSON and", "Markdown"]}], "edges": [{"src": "IMG", "dst": "ENC", "kind": "data", "line": [347, 70, 347, 148]}, {"src": "ENC", "dst": "S1", "kind": "data", "line": [347, 210, 347, 288]}, {"src": "S1", "dst": "SEQ", "kind": "data", "line": [347, 334, 347, 412]}, {"src": "SEQ", "dst": "S2", "kind": "data", "line": [347, 474, 347, 552]}, {"src": "S2", "dst": "T", "kind": "data", "curve": [[446, 609], [609, 653], [609, 653], [609, 692]]}, {"src": "S2", "dst": "TB", "kind": "data", "curve": [[385, 614], [434, 653], [434, 653], [434, 692]]}, {"src": "S2", "dst": "FM", "kind": "data", "curve": [[308, 614], [259, 653], [259, 653], [259, 692]]}, {"src": "S2", "dst": "FG", "kind": "data", "curve": [[248, 609], [84, 653], [84, 653], [84, 692]]}, {"src": "T", "dst": "DEC", "kind": "data", "curve": [[609, 738], [609, 777], [609, 777], [442, 822]]}, {"src": "TB", "dst": "DEC", "kind": "data", "curve": [[434, 738], [434, 777], [434, 777], [385, 816]]}, {"src": "FM", "dst": "DEC", "kind": "data", "curve": [[259, 738], [259, 777], [259, 777], [308, 816]]}, {"src": "FG", "dst": "DEC", "kind": "data", "curve": [[84, 738], [84, 777], [84, 777], [251, 822]]}, {"src": "DEC", "dst": "OUT", "kind": "data", "line": [347, 878, 347, 956]}]});
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
      const container = document.getElementById('datasetfoxbenchmarkguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'datasetfoxbenchmarkguide-1';
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

#### مشفر الرؤية (Vision Encoder)
- **العمود الفقري**: Swin Transformer
- **الوظيفة**: استخراج الميزات البصرية من صور المستندات
- **الدقة**: دعم المعالجة متعددة المقاييس

#### مفكك النص (Text Decoder)
- **الأساس**: بنية MBart
- **اللغات**: دعم متزامن للصينية والإنجليزية
- **عدد الرموز**: حجم مفردات 32K

#### الواجهة القائمة على الموجهات

```python
# 헤테로지니어스 앵커 프롬프팅 예시
prompts = {
    "layout_analysis": "Analyze the layout and generate element sequence:",
    "table_parsing": "Parse the table content in the red box:",
    "formula_recognition": "Recognize the mathematical formula in the blue box:",
    "text_extraction": "Extract text content from the green box:"
}
```

## 📊 تحليل مفصل لمجموعة بيانات Fox

### تكوين مجموعة البيانات

بنى فريق بحث ByteDance مجموعة بيانات ضخمة متعددة المستويات لتدريب Dolphin.

#### حجم مجموعة البيانات الكلي

```yaml
dataset_statistics:
  total_samples: 30_000_000+
  granularity_levels:
    - page_level: "전체 페이지 파싱"
    - element_level: "개별 요소 파싱"
  
  task_distribution:
    layout_analysis: 8_500_000
    table_extraction: 7_200_000  
    formula_recognition: 5_800_000
    text_recognition: 8_500_000
```

#### مميزات الاختبار المرجعي Fox-Page

Fox-Page هو مجموعة فرعية مُنقحة يدويا عالية الجودة مستخرجة من مجموعة بيانات Fox الأصلية.

```yaml
fox_page_benchmark:
  release_date: "2025-07-10"
  quality: "manually_refined"
  purpose: "evaluation_benchmark"
  
  download_links:
    baidu_yun: "https://pan.baidu.com/..."
    google_drive: "https://drive.google.com/..."
  
  characteristics:
    diversity: "다양한 문서 유형"
    complexity: "복잡한 레이아웃 구조"
    quality: "전문가 검증 완료"
```

### 🔍 تحليل فئات البيانات

#### 1. الأوراق الأكاديمية (Academic Papers)

```python
academic_papers = {
    "sources": ["arXiv", "ACL", "NeurIPS", "ICLR"],
    "elements": {
        "multi_column_text": "2단/3단 컬럼 텍스트",
        "complex_tables": "통계 테이블, 결과 비교표",
        "mathematical_formulas": "인라인/디스플레이 수식",
        "figures_with_captions": "그래프, 다이어그램"
    },
    "challenges": [
        "dense_layout",
        "interleaved_elements", 
        "scientific_notation"
    ]
}
```

#### 2. مستندات الأعمال (Business Documents)

```python
business_documents = {
    "types": ["invoices", "reports", "presentations"],
    "layouts": {
        "structured_forms": "양식 기반 문서",
        "mixed_content": "텍스트+차트 혼합",
        "branded_headers": "로고 및 헤더 정보"
    },
    "extraction_targets": [
        "key_value_pairs",
        "financial_data",
        "contact_information"
    ]
}
```

#### 3. المواد التعليمية (Educational Materials)

```python
educational_materials = {
    "categories": ["textbooks", "worksheets", "exams"],
    "special_elements": {
        "question_answer_pairs": "Q&A 형식",
        "step_by_step_solutions": "단계별 풀이",
        "mixed_languages": "다국어 혼재"
    },
    "complexity_factors": [
        "handwritten_annotations",
        "geometric_diagrams",
        "chemical_formulas"
    ]
}
```

### 📈 مقاييس أداء الاختبارات المرجعية

#### مقاييس التقييم على مستوى الصفحة

```python
page_level_metrics = {
    "structure_accuracy": {
        "description": "레이아웃 구조 정확도",
        "calculation": "correct_elements / total_elements",
        "weight": 0.3
    },
    "content_fidelity": {
        "description": "내용 충실도", 
        "measures": ["BLEU", "ROUGE", "Edit Distance"],
        "weight": 0.4
    },
    "reading_order": {
        "description": "읽기 순서 정확성",
        "metric": "sequence_alignment_score", 
        "weight": 0.3
    }
}
```

#### مقاييس التقييم على مستوى العناصر

```python
element_level_metrics = {
    "table_extraction": {
        "cell_accuracy": "셀 단위 정확도",
        "structure_score": "테이블 구조 점수", 
        "format_preservation": "포맷 보존 정도"
    },
    "formula_recognition": {
        "latex_accuracy": "LaTeX 문법 정확도",
        "semantic_correctness": "의미적 정확성",
        "rendering_quality": "렌더링 품질"
    },
    "text_extraction": {
        "character_accuracy": "문자 단위 정확도",
        "word_accuracy": "단어 단위 정확도", 
        "layout_preservation": "레이아웃 보존"
    }
}
```

## دليل الاستخدام العملي

### 🚀 طريقة استخدام نموذج Dolphin

#### التثبيت والإعداد

```bash
# 저장소 클론
git clone https://github.com/bytedance/Dolphin.git
cd Dolphin

# 의존성 설치
pip install -r requirements.txt

# 모델 다운로드 (Hugging Face 방식)
git lfs install
git clone https://huggingface.co/ByteDance/Dolphin ./hf_model
```

#### مثال على التحليل على مستوى الصفحة

```python
# demo_page_hf.py 사용 예제
import argparse
from pathlib import Path

# 단일 문서 이미지 처리
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs/academic_paper.jpeg \
    --save_dir ./results

# PDF 문서 처리  
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs/business_report.pdf \
    --save_dir ./results

# 배치 처리 (디렉토리 전체)
python demo_page_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/page_imgs \
    --save_dir ./results \
    --max_batch_size 16
```

#### مثال على التحليل على مستوى العناصر

```python
# 테이블 추출
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/complex_table.jpeg \
    --element_type table

# 수식 인식  
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/math_formula.jpeg \
    --element_type formula

# 텍스트 단락 추출
python demo_element_hf.py \
    --model_path ./hf_model \
    --input_path ./demo/element_imgs/text_paragraph.jpg \
    --element_type text
```

### 📊 نصائح تحسين الأداء

#### تسريع TensorRT-LLM (أضيف في 2025.06.30)

```bash
# TensorRT-LLM 설치
pip install tensorrt-llm

# 모델 변환
python convert_to_tensorrt.py \
    --model_path ./hf_model \
    --output_dir ./tensorrt_model \
    --precision fp16

# 가속된 추론 실행
python demo_page_tensorrt.py \
    --model_path ./tensorrt_model \
    --input_path ./test_images
```

#### تسريع vLLM (أضيف في 2025.06.27)

```bash
# vLLM 설치  
pip install vllm

# vLLM 서버 시작
python -m vllm.entrypoints.openai.api_server \
    --model ./hf_model \
    --tensor-parallel-size 2 \
    --dtype half

# 클라이언트에서 호출
curl -X POST "http://localhost:8000/v1/chat/completions" \
    -H "Content-Type: application/json" \
    -d '{
        "model": "ByteDance/Dolphin",
        "messages": [{"role": "user", "content": "Parse this document"}]
    }'
```

### 🔧 بناء مجموعة بيانات مخصصة

#### إرشادات إعداد البيانات

```python
# 커스텀 데이터셋 구조
custom_dataset = {
    "images": {
        "format": ["JPEG", "PNG", "PDF"],
        "resolution": "최소 300 DPI 권장",
        "quality": "고해상도, 선명한 이미지"
    },
    "annotations": {
        "layout": {
            "bounding_boxes": "각 요소의 경계 상자",
            "element_types": ["text", "table", "figure", "formula"],
            "reading_order": "자연스러운 읽기 순서"
        },
        "content": {
            "ground_truth": "정확한 텍스트 내용", 
            "markup": "구조화된 마크업 (HTML/Markdown)",
            "latex": "수식의 LaTeX 표현"
        }
    }
}
```

#### دليل عمل التوصيف

```yaml
annotation_guidelines:
  layout_analysis:
    text_blocks:
      - "문단, 제목, 캡션 구분"
      - "읽기 순서 고려한 순서 번호 부여"
    
    tables:
      - "헤더, 데이터 행 구분"
      - "병합된 셀 정보 포함"
      - "테이블 캡션 연결"
    
    figures:
      - "이미지, 차트, 다이어그램"
      - "캡션과의 연결 관계"
      - "참조 번호 정보"
    
    formulas:
      - "인라인 vs 디스플레이 수식 구분" 
      - "LaTeX 형식으로 정확한 표현"
      - "변수 및 기호 일관성"

  quality_control:
    consistency_checks:
      - "동일 문서 내 스타일 일관성"
      - "용어 및 표기법 통일"
    
    accuracy_validation:
      - "OCR 결과와 원본 비교"
      - "수식 렌더링 검증"
      - "테이블 구조 정확성 확인"
```

## المقارنة مع مجموعات البيانات الأخرى

### 📋 مقارنة الاختبارات المرجعية الرئيسية لفهم المستندات

| مجموعة البيانات | الحجم | المميزات | القيود |
|-----------------|-------|----------|--------|
| **Fox-Page** | مجموعة فرعية منقحة عالية الجودة | متعددة اللغات، تخطيطات معقدة | حجم صغير نسبيا |
| DocVQA | 50K+ | صيغة VQA | مقيد بالأسئلة والأجوبة |
| ChartQA | 20K+ | متخصص في الرسوم البيانية | نقص في العناصر الأخرى |
| PubLayNet | 360K+ | محور على التخطيط | نقص في استخراج المحتوى |
| TableBank | 417K+ | متخصص في الجداول | يتضمن الجداول فقط |

### 🎯 ما يميز مجموعة بيانات Dolphin Fox

#### 1. دعم التفصيل متعدد المستويات

```python
multi_granularity = {
    "page_level": {
        "task": "전체 문서 구조 이해",
        "output": "JSON + Markdown",
        "applications": ["문서 디지털화", "자동 요약"]
    },
    "element_level": {
        "task": "개별 요소 정밀 추출", 
        "output": "구조화된 데이터",
        "applications": ["데이터 마이닝", "정보 검색"]
    }
}
```

#### 2. انعكاس سيناريوهات الاستخدام الفعلي

```python
real_world_scenarios = {
    "academic_research": {
        "documents": "arXiv 논문, 컨퍼런스 프로시딩",
        "challenges": "복잡한 수식, 다중 컬럼 레이아웃"
    },
    "business_intelligence": {
        "documents": "재무제표, 사업보고서",
        "challenges": "표 구조, 차트 해석"
    },
    "education_technology": {
        "documents": "교과서, 시험 문제",
        "challenges": "다국어, 손글씨 혼재"
    }
}
```

#### 3. شمولية مقاييس التقييم

```python
comprehensive_evaluation = {
    "structure_preservation": "레이아웃 구조 보존",
    "content_accuracy": "내용 정확도",
    "efficiency_metrics": "처리 속도 및 메모리 사용량",
    "robustness_testing": "다양한 조건에서의 안정성"
}
```

## حالات الاستخدام البحثي والتطويري

### 🔬 التطبيقات البحثية الأكاديمية

#### 1. تطوير نماذج فهم المستندات

```python
research_applications = {
    "baseline_comparison": {
        "purpose": "새로운 모델의 성능 벤치마크",
        "metrics": "Fox-Page 벤치마크 점수",
        "advantage": "표준화된 평가 환경"
    },
    "ablation_studies": {
        "components": ["vision_encoder", "text_decoder", "prompting"],
        "methodology": "단계별 성능 기여도 분석"
    },
    "cross_lingual_analysis": {
        "languages": ["Chinese", "English", "Mixed"],
        "research_questions": "언어별 성능 차이 분석"
    }
}
```

#### 2. التحقق من صحة تقنيات جديدة

```python
technique_validation = {
    "anchor_prompting": {
        "hypothesis": "헤테로지니어스 앵커가 성능 향상",
        "experiment": "프롬프트 유무 비교 실험"
    },
    "parallel_processing": {
        "hypothesis": "병렬 처리가 효율성 개선",
        "measurement": "처리 시간 및 메모리 사용량"
    }
}
```

### 🏭 حالات التطبيق الصناعي

#### 1. مشاريع التحول الرقمي

```python
digital_transformation = {
    "document_digitization": {
        "scope": "대량 문서 아카이브 디지털화",
        "pipeline": [
            "스캔/촬영",
            "Dolphin 파싱",
            "구조화된 데이터 저장",
            "검색 인덱싱"
        ]
    },
    "automated_processing": {
        "workflows": [
            "인보이스 자동 처리",
            "계약서 정보 추출", 
            "보고서 자동 요약"
        ]
    }
}
```

#### 2. أنظمة إدارة المعرفة

```python
knowledge_management = {
    "academic_libraries": {
        "task": "논문 메타데이터 자동 추출",
        "benefits": "분류 및 검색 정확도 향상"
    },
    "corporate_archives": {
        "task": "기업 문서 지식베이스 구축",
        "benefits": "의사결정 지원 정보 제공"
    }
}
```

## الاستخدام المتقدم والتوسع

### 🛠️ دليل الضبط الدقيق للنموذج

#### 1. الضبط الدقيق المتخصص في المجال

```python
# 의료 문서 특화 튜닝 예제
medical_domain_config = {
    "data_preparation": {
        "medical_reports": "의료 진단서, 처방전",
        "terminology": "의학 용어 사전 추가",
        "privacy": "개인정보 마스킹 처리"
    },
    "training_config": {
        "learning_rate": 1e-5,
        "batch_size": 8,
        "epochs": 10,
        "special_tokens": ["<MEDICAL>", "<PRESCRIPTION>", "<DIAGNOSIS>"]
    }
}
```

#### 2. التوسع إلى لغات أخرى

```python
# 한국어 특화 확장 예제
korean_extension = {
    "tokenizer_expansion": {
        "korean_vocab": "한국어 어휘 추가",
        "hanja_support": "한자 표기 지원",
        "mixed_script": "한영 혼재 문서 처리"
    },
    "dataset_creation": {
        "korean_documents": [
            "공문서", "학술논문", "신문기사", "교과서"
        ],
        "annotation_guidelines": "한국어 특성 반영"
    }
}
```

### 📊 مراقبة الأداء وتحسينه

#### 1. تتبع الأداء الفوري

```python
# 성능 모니터링 스크립트
import time
import psutil
import torch

class PerformanceMonitor:
    def __init__(self):
        self.start_time = None
        self.memory_usage = []
        
    def start_monitoring(self):
        self.start_time = time.time()
        self.memory_usage = []
        
    def log_metrics(self, step, accuracy):
        current_memory = psutil.virtual_memory().used / 1024**3  # GB
        elapsed_time = time.time() - self.start_time
        
        metrics = {
            "step": step,
            "accuracy": accuracy,
            "memory_gb": current_memory,
            "elapsed_time": elapsed_time,
            "gpu_memory": torch.cuda.memory_allocated() / 1024**3 if torch.cuda.is_available() else 0
        }
        
        return metrics
```

#### 2. تحسين النشر

```python
# 프로덕션 배포 설정
production_config = {
    "model_optimization": {
        "quantization": "INT8 양자화",
        "pruning": "가중치 프루닝", 
        "distillation": "지식 증류"
    },
    "inference_optimization": {
        "batching": "동적 배칭",
        "caching": "결과 캐싱",
        "parallel_workers": 4
    },
    "monitoring": {
        "latency_tracking": "응답 시간 추적",
        "error_logging": "오류 로깅",
        "usage_analytics": "사용 패턴 분석"
    }
}
```

## الخلاصة والتوقعات المستقبلية

### 🎯 أهمية Dolphin ومجموعة بيانات Fox

قدّم مشروع Dolphin ومجموعة بيانات Fox معلما بارزا في مجال تحليل صور المستندات:

#### 1. الابتكار التقني
- **نموذج Analyze-then-Parse**: نهج بديهي يحاكي عملية قراءة الإنسان للمستندات
- **الموجه المرتكز غير المتجانس (Heterogeneous Anchor Prompting)**: معالجة فعّالة لعناصر المستند المتنوعة
- **آلية المعالجة المتوازية**: ضمان كفاءة وقابلية توسع عالية

#### 2. قيمة مجموعة البيانات
- **تفصيل متعدد المستويات على نطاق واسع**: أكثر من 30 مليون نموذج متنوع
- **انعكاس سيناريوهات الاستخدام الفعلي**: تغطية مجالات الأبحاث الأكاديمية والأعمال والتعليم
- **بيئة تقييم موحدة**: توفير معيار مقارنة عادل لمجتمع البحث العلمي

### 🚀 توجهات البحث المستقبلية

#### 1. التوجهات التقنية المستقبلية

```python
future_directions = {
    "multimodal_fusion": {
        "vision_language": "더 정교한 시각-언어 융합",
        "3d_documents": "3차원 문서 구조 이해"
    },
    "interactive_parsing": {
        "user_feedback": "사용자 피드백 기반 개선",
        "adaptive_learning": "적응적 학습 메커니즘"
    },
    "efficiency_improvements": {
        "edge_deployment": "엣지 디바이스 배포",
        "real_time_processing": "실시간 처리 최적화"
    }
}
```

#### 2. توسيع نطاق التطبيقات

```python
application_expansion = {
    "specialized_domains": [
        "legal_documents",    # 법률 문서
        "medical_records",    # 의료 기록  
        "financial_reports",  # 금융 보고서
        "historical_archives" # 역사 문서
    ],
    "emerging_technologies": [
        "ar_vr_integration",  # AR/VR 통합
        "voice_interaction",  # 음성 상호작용
        "blockchain_verification" # 블록체인 검증
    ]
}
```

### 💡 توصيات التطبيق العملي

#### 1. استراتيجية التبني
1. **مشروع تجريبي**: البدء بنطاق صغير والتوسع التدريجي
2. **التخصص في المجال**: تخصيص النموذج وفق أنواع المستندات المحددة
3. **قياس الأداء المرجعي**: تحديد الخط الأساسي باستخدام مجموعة بيانات Fox
4. **التحسين المستمر**: تحديث النموذج بناء على تغذية المستخدمين الراجعة

#### 2. ضمان الجودة

```python
quality_assurance = {
    "validation_pipeline": {
        "automated_testing": "자동화된 정확도 테스트",
        "human_review": "전문가 검토 프로세스",
        "error_analysis": "오류 패턴 분석 및 개선"
    },
    "continuous_monitoring": {
        "performance_tracking": "실시간 성능 모니터링",
        "drift_detection": "모델 성능 저하 감지",
        "retraining_triggers": "재훈련 시점 자동 결정"
    }
}
```

يقدم ByteDance Dolphin ومجموعة بيانات Fox معيارا جديدا لذكاء اصطناعي فهم المستندات، ويتيح حلولا مبتكرة في مختلف الصناعات ومجالات البحث. ومن المتوقع أن يُسهم التقدم التقني المستمر والمساهمات المجتمعية في بناء أنظمة تحليل مستندات أكثر دقة وعملية.

---

**لمزيد من المعلومات:**
- [Dolphin GitHub Repository](https://github.com/bytedance/Dolphin)
- [ورقة ACL 2025 (arXiv)](https://arxiv.org/abs/2505.14059)
- [Dolphin Hugging Face Model](https://huggingface.co/ByteDance/Dolphin)
- [تحميل Fox-Page Benchmark](https://github.com/bytedance/Dolphin#fox-page-benchmark)
