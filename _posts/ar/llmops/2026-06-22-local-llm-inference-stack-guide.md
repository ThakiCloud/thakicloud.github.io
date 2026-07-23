---
title: "'إنجيل' الاستدلال المحلي لنماذج LLM: حدّد العتاد أولاً ليتبعه المحرّك"
excerpt: "تحليل للدليل الشامل المجاني للاستدلال المحلي لنماذج LLM الذي نشره Ahmad Osman، مشرف GPU في r/LocalLLaMA. من llama.cpp إلى vLLM وTensorRT-LLM وNVIDIA Dynamo، نحلّل اختيار المحرّك حسب السيناريو من منظور خدمة ThakiCloud."
seo_title: "تحليل دليل محركات الاستدلال المحلي لنماذج LLM - Thaki Cloud"
seo_description: "دليل Ahmad Osman للاستدلال المحلي، الاختيار حسب السيناريو عبر llama.cpp وMLX وvLLM وSGLang وTensorRT-LLM وNVIDIA Dynamo، واقتصاديات الخدمة داخل المؤسسة من منظور ThakiCloud."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - local-llm
  - inference-engine
  - vllm
  - llama-cpp
  - on-premise
  - gpu-serving
header:
  image: /assets/images/local-llm-inference-stack-guide-hero.webp
  teaser: /assets/images/local-llm-inference-stack-guide-hero.webp
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/local-llm-inference-stack-guide/"
reading_time: true
categories:
  - llmops
published: false
---

أول سؤال يواجه من يبدأ بالاستدلال المحلي لنماذج LLM هو "أي محرّك يجب أن أستخدم؟" تنهمر أسماء مثل llama.cpp وvLLM وSGLang وTensorRT-LLM، لكن لا يوجد توجيه واضح حول الأساس الذي يُبنى عليه الاختيار. نشر Ahmad Osman (@TheAhmadOsman)، مشرف GPU في r/LocalLLaMA، مؤخراً دليلاً شاملاً مجانياً يسدّ هذه الفجوة.

في ThakiCloud نتعامل مع خدمة النماذج على منصة AI/ML SaaS قائمة على K8s. وفيما يلي ما تعنيه الرسالة الجوهرية لهذا الدليل لمزوّدي سحابة GPU والذكاء الاصطناعي داخل المؤسسة مثلنا.

## ما هو هذا الدليل

دليل Ahmad Osman ليس درساً بسيطاً للتثبيت. إنه أشبه بكتاب مرجعي ينظّم الاستدلال المحلي من البداية إلى النهاية. ورسالته الجوهرية واضحة. أنت لا تختار محرّك الاستدلال أولاً، بل تحدّد استراتيجية العتاد أولاً، ثم يتبعها المحرّك المناسب.

تهمّ هذه الزاوية لأن اختيار المحرّك أولاً يدفعك إلى تجاهل قيود العتاد الذي تملكه فعلاً. فالنموذج الذي تشغّله على حاسوب محمول واحد والنموذج الذي تشغّله على خادم بأربعة معالجات رسومية هما خياران مختلفان منذ البداية. يقرّ الدليل بهذا ويقسّم النقاش عبر بيئات تشغيل متعددة: الأجهزة المقيّدة كالحواسيب المحمولة والحافة، تدفقات العمل المتمحورة حول Mac، معالج RTX رسومي واحد، تكوينات NVIDIA CUDA متعددة المعالجات من اثنين إلى أربعة أو أكثر، الخدمة الإنتاجية العامة، السياق الطويل وتوجيه MoE، استخراج أقصى أداء من NVIDIA، وأخيراً تنسيق العناقيد. ولكل سيناريو يشير إلى الأدوات المناسبة.

يلخّص المخطط أدناه المنطق الجوهري للدليل بوصفه ربطاً بين سيناريوهات العتاد ومحركات الاستدلال.

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
<div class="d3-arch" data-arch-root id="alllminferencestackguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1153, "height": 542, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 462, "y": 24, "w": 191, "h": 46, "title": "تعريف عبء عمل الاستدلال"}, {"id": "B", "x": 456, "y": 148, "w": 202, "h": 68, "title": ["حدّد استراتيجية العتاد", "أولاً"]}, {"id": "C", "x": 978, "y": 308, "w": 120, "h": 46, "title": "llama.cpp"}, {"id": "D", "x": 803, "y": 308, "w": 120, "h": 46, "title": "MLX / MLX-LM"}, {"id": "E", "x": 571, "y": 308, "w": 177, "h": 46, "title": "ExLlamaV2 / ExLlamaV3"}, {"id": "F", "x": 395, "y": 308, "w": 121, "h": 46, "title": "vLLM / SGLang"}, {"id": "G", "x": 220, "y": 308, "w": 120, "h": 46, "title": "TensorRT-LLM"}, {"id": "H", "x": 44, "y": 308, "w": 121, "h": 46, "title": "NVIDIA Dynamo"}, {"id": "I", "x": 451, "y": 432, "w": 212, "h": 78, "title": ["شواغل مشتركة: التكميم،", "حساب الذاكرة، الموازنة بين", "الإنتاجية والكمون"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [557, 70, 557, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "أجهزة مقيّدة: محمول / حافة", "curve": [[658, 199], [1038, 262], [1038, 262], [1038, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "Apple Silicon Mac", "curve": [[658, 208], [863, 262], [863, 262], [863, 308]], "off": "50%"}, {"src": "B", "dst": "E", "kind": "data", "label": "معالج RTX استهلاكي واحد", "curve": [[600, 216], [659, 262], [659, 262], [659, 308]], "off": "50%"}, {"src": "B", "dst": "F", "kind": "data", "label": "خدمة إنتاجية عامة", "curve": [[514, 216], [455, 262], [455, 262], [455, 308]], "off": "50%"}, {"src": "B", "dst": "G", "kind": "data", "label": "أقصى أداء من NVIDIA", "curve": [[456, 211], [280, 262], [280, 262], [280, 308]], "off": "50%"}, {"src": "B", "dst": "H", "kind": "data", "label": "خدمة موزّعة متعددة العُقد", "curve": [[456, 200], [104, 262], [104, 262], [104, 308]], "off": "50%"}, {"src": "C", "dst": "I", "kind": "data", "curve": [[1038, 354], [1038, 393], [1038, 393], [663, 454]]}, {"src": "D", "dst": "I", "kind": "data", "curve": [[863, 354], [863, 393], [863, 393], [663, 444]]}, {"src": "E", "dst": "I", "kind": "data", "curve": [[659, 354], [659, 393], [659, 393], [608, 432]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[455, 354], [455, 393], [455, 393], [506, 432]]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[280, 354], [280, 393], [280, 393], [451, 441]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[104, 354], [104, 393], [104, 393], [451, 453]]}]});
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
      const container = document.getElementById('alllminferencestackguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'alllminferencestackguide-1';
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

تختلف المحركات حسب السيناريو، لكن الشواغل العملية المتمثلة في التكميم وحساب الذاكرة والموازنة بين الإنتاجية والكمون تواجهك بالطريقة نفسها أياً كان المسار الذي تسلكه. وكون الدليل يشرح هذه الشواغل المشتركة يزيد من قيمته كمرجع.

## مشهد محركات الاستدلال

على صعيد البرمجيات، يغطي الدليل تقريباً كل المنظومات الرئيسية في بيئة الاستدلال المحلي اليوم. ويتميّز كل محرّك في شيء مختلف.

- **llama.cpp**: قوته في تعدد الاستخدامات، إذ يعمل على المعالج المركزي والرسومي معاً حين تكون ذاكرة VRAM ضيقة وذاكرة RAM وافرة. وهو نقطة الانطلاق الأقل حاجزاً.
- **MLX وMLX-LM**: منظومات مُحسّنة لمعالجات Apple Silicon. تناسب من يريد تشغيل الاستدلال على MacBook أو Mac Studio باستخدام الذاكرة الموحّدة.
- **ExLlamaV2 وExLlamaV3**: يهدفان إلى استدلال مُكمَّم سريع على معالجات الرسوميات الاستهلاكية، ويناسبان حالات الرغبة في أقصى سرعة من بطاقة RTX واحدة.
- **vLLM وSGLang**: المعيار الفعلي للخدمة الإنتاجية. يرفع كلٌّ من PagedAttention والدفعات المستمرة إنتاجية الطلبات المتعددة.
- **TensorRT-LLM**: محرّك يستخرج أداءً أقصى من عتاد NVIDIA. يخفض التحسين على مستوى النواة الكمون، لكن صعوبة البناء والتشغيل أعلى.
- **NVIDIA Dynamo**: يستهدف الخدمة الموزّعة عبر عُقد متعددة، ويُستخدم حين توزّع الاستدلال خارج خادم واحد.

يتضح أمر واحد من هذه القائمة. لا وجود لشيء اسمه "أفضل محرّك استدلال". قد يكون llama.cpp هو الجواب الصحيح على جهاز مقيّد، بينما قد يكون vLLM أو TensorRT-LLM هو الجواب الصحيح لخدمة تتلقى آلاف الطلبات المتزامنة. المعيار ليس تفوّق المحرّك بل تركيبة عبء العمل والعتاد.

## لماذا الاستدلال المحلي الآن

أسباب تنامي الاهتمام بالاستدلال المحلي واضحة. ويذكر الدليل ونقاشات المجتمع أربعة دوافع مشتركة.

أولاً، سيادة البيانات والخصوصية. الطلب على معالجة البيانات الحساسة داخلياً بدلاً من إرسالها إلى واجهات برمجية خارجية قوي بشكل خاص في الرعاية الصحية والتمويل والقطاع العام. ثانياً، بنية التكلفة. الانتقال من التسعير حسب الرمز إلى تكاليف عتاد ثابتة يقلب الاقتصاديات لصالح المؤسسات كثيفة الاستخدام. ثالثاً، الكمون. الاستدلال المحلي الذي لا يعبر الشبكة يمكن أن يقلّل كمون الاستجابة. رابعاً، التحكّم. الإمساك المباشر بالنموذج والبنية التحتية يتيح ضبط الإصدار والتكميم والتوجيه وفق احتياجات مؤسستك.

مع انتقال مركز الثقل من الاعتماد الكلّي على واجهات السحابة نحو داخل المؤسسة والحافة، يستمر تنامي الطلب على مادة تتيح مقارنة أي محرّك يُوضع على أي عتاد دفعة واحدة. هذه هي خلفية الاهتمام الذي ناله دليل Ahmad Osman.

## تطبيق ذلك على منصة ThakiCloud K8s AI/ML SaaS

تقع الخدمة المحلية وداخل المؤسسة لنماذج LLM التي يغطّيها هذا الدليل في قلب أعمال ThakiCloud تماماً. فموقعنا كمنصة AI/ML SaaS قائمة على K8s، وذكاء اصطناعي سيادي وداخل المؤسسة، وسحابة GPU، وMSP، وذكاء اصطناعي للمؤسسات، هو بالضبط عمل حلّ المشكلات التي تصفها هذه المادة.

منطق الدليل الجوهري، "استراتيجية العتاد أولاً ثم يتبعها المحرّك"، إطار يمكننا استخدامه مباشرة عند اقتراح موارد GPU ومنظومات الاستدلال للعملاء. الطيف الممتد من بطاقة RTX واحدة إلى تعدد المعالجات وتنسيق العناقيد يتداخل تماماً مع المجال الذي تغطّيه فعلاً جدولة أعباء العمل القائمة على Kueue وإدارة دورة حياة GPU لدينا. تحديد مستوى عتاد العميل أولاً ومطابقة تكوين الخدمة المناسب له هو ما نفعله كل يوم.

على صعيد الفرص، إذا جمعنا منظومات الخدمة الإنتاجية مثل vLLM وSGLang وTensorRT-LLM وNVIDIA Dynamo في عروض مُدارة على K8s، يمكننا استيعاب عبء اختيار العملاء للمحركات وضبطها بأنفسهم. قراءة دليل واحد وبناء محرّك يدوياً يختلف تشغيلياً اختلافاً كبيراً عن تلقّي منظومة خدمة مُتحقَّق منها مع اتفاقية مستوى خدمة. وللمؤسسات وعملاء القطاع العام الراغبين في سيادة البيانات والتحكّم في التكلفة، يمكن لهذا الدليل أن يكون أيضاً دليلاً لعرض ميزة التكلفة الإجمالية للملكية للاستدلال داخل المؤسسة مقابل واجهات السحابة بشكل كمّي.

التحدّي الحقيقي الذي نتعامل معه هو تنمية عرض توضيحي على جهاز واحد إلى خدمة إنتاجية متعددة المستأجرين. وتنسيق العناقيد، الذي يضعه الدليل في نهاية سيناريوهاته، هو بالضبط تلك النقطة، ومنها يصبح الأمر مسألة عزل للموارد وكفاءة GPU وأتمتة تشغيل تتجاوز اختيار المحرّك.

## القيود والحجج المضادة

ومع ذلك، علينا أيضاً النظر إلى التهديد. الأدلة المجانية بمستوى "الإنجيل" مثل هذا ونضج أدوات مثل llama.cpp وMLX تخفض حاجز الدخول، ما يسهّل على العملاء الذهاب مباشرة إلى الاستضافة الذاتية. وحين يكون محرّك الاستدلال نفسه مفتوح المصدر والمادة التي تنظّم كيفية تثبيته منشورة مجاناً، فإن مجرد تقديم "سنثبّت لك المحرّك" لا يشكّل أي تمايز.

لذا يجب أن يكمن تمايزنا لا في المحرّك نفسه بل في عزل المستأجرين المتعددين، وتعظيم كفاءة GPU، وأتمتة التشغيل، واتفاقية مستوى الخدمة. علينا إثبات القيمة لا بما تشغّله بل بمدى استقرار تشغيلنا له نيابةً عنك. ما يعلّمه الدليل يصل إلى "أي محرّك يناسب أي عتاد"، أما "ما الذي تحتاجه أكثر لخدمته باستقرار لمستأجرين كثر على مدار الساعة" فهو الأرض التي تتجاوز الدليل. تلك الأرض هي حيث نتحمّل المسؤولية.

نقطة أخرى جديرة بالذكر هي أن أرقام الإنتاجية والأداء التي يقدّمها الدليل تأتي من بيئة العتاد الخاصة بالمؤلف. في النشر الفعلي، عليك إعادة قياس مفاضلات حجم النموذج والعتاد والإنتاجية مقابل عبء عملك. الدليل خريطة، لا ضمان.

## الخاتمة

يقدّم دليل Ahmad Osman للاستدلال المحلي إطاراً بسيطاً لكنه عملي: "العتاد قبل المحرّك". وبعرضه المشهد من llama.cpp إلى NVIDIA Dynamo دفعة واحدة، يصبح نقطة انطلاق جيدة لكل من يبدأ بالاستدلال المحلي. ولمزوّدي الخدمة مثلنا، هذه المادة إطار لمقترحات العملاء وتذكير في الوقت نفسه بالضغط التنافسي للاستضافة الذاتية. وللمهندسين المهتمين بإثبات القيمة عبر التشغيل بما يتجاوز المحرّك، هذا مكان تكون فيه مثل هذه المشكلات هي المهمة اليومية.

---

المصادر: الدليل الشامل للاستدلال المحلي لنماذج LLM بقلم Ahmad Osman (@TheAhmadOsman، مشرف GPU في r/LocalLLaMA). موقع المؤلف [ahmadosman.com](https://ahmadosman.com)، [التغريدة](https://x.com/hjguyhan/status/2068706994480115949) الأصلية، ومرجع مقارنة محركات الاستدلال [مقارنة محركات الاستدلال المحلي 2026](https://www.local-llm.net/compare/inference-engines-2026/). أرقام الأداء مبنية على بيئة المؤلف وتتطلب إعادة تحقّق في الواقع.
