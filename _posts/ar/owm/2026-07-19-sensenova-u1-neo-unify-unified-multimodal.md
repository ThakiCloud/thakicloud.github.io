---
title: "الوسائط المتعددة الموحدة بلا VAE: SenseNova U1 و NEO-Unify، والتقديم في البنية المحلية"
excerpt: "أطلقت SenseTime نموذج 日日新 SenseNova U1 برخصة Apache 2.0. تعتمد بنية NEO-Unify التي تلغي كلاً من المشفر البصري و VAE، وتعالج الفهم والتوليد والتحرير والتوليد المتشابك (interleave) داخل نموذج واحد. نستعرض الفرق بين الأوزان المفتوحة (8B-MoT / A3B-MoT) ونسخة U1 Pro المستضافة، وموقعها في المعايير القياسية، ومسارات التقديم عبر transformers و vLLM-Omni و ComfyUI، وسبب استحالة تشغيلها على A1111، من منظور التقديم في البنية التحتية المحلية."
seo_title: "SenseNova U1 و NEO-Unify للوسائط المتعددة الموحدة - الأوزان المفتوحة والتقديم المحلي - Thaki Cloud"
seo_description: "قراءة قائمة على الوقائع لنموذج SenseNova U1 (NEO-Unify، إلغاء VAE، MoE بحجم 8B-MoT/A3B-MoT، رخصة Apache 2.0). التمييز بين U1 Pro والأوزان المفتوحة، المعايير القياسية، التقديم عبر transformers و vLLM-Omni و GGUF، دعم ComfyUI وعدم توافقه مع A1111، ومنظور التقديم المحلي على Kubernetes لدى ThakiCloud."
date: 2026-07-19
last_modified_at: 2026-07-19
tags:
  - sensenova-u1
  - sensetime
  - neo-unify
  - unified-multimodal
  - text-to-image
  - mixture-of-transformers
  - open-weight
  - vllm
  - comfyui
  - on-premise
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/owm/sensenova-u1-neo-unify-unified-multimodal/"
reading_time: true
categories:
  - owm
---

⏱️ **وقت القراءة المقدر: 15 دقيقة**

![رؤية مفاهيمية لنموذج SenseNova U1 NEO-Unify للوسائط المتعددة الموحدة]({{ '/assets/images/sensenova-u1-neo-unify-unified-multimodal-hero.webp' | relative_url }})

## نظرة عامة

ظلت نماذج توليد الصور لفترة طويلة منقسمة إلى مسارين. في جانب، هناك نموذج لغوي يفهم النص. وفي الجانب الآخر، هناك نموذج انتشار (diffusion) يرسم البكسلات. وتُعد سلسلة Stable Diffusion المثال الأبرز على ذلك. يفسّر مشفر النص التوجيه (prompt)، ثم يزيل UNet أو DiT الضوضاء في الفضاء الكامن، ثم يعيد VAE (المشفر التلقائي التبايني) بناء تلك القيم الكامنة إلى بكسلات من جديد. إنها بنية يحدث فيها الفهم والتوليد في وحدتين مختلفتين وبتمثيلين مختلفين.

أما 日日新 SenseNova U1 من SenseTime (سنسه‌تايم)، الذي أُطلق بشكل تدريجي ابتداءً من أبريل 2026، فيرفض هذا الانفصال جملة وتفصيلاً. فهو يلغي كلاً من المشفر البصري و VAE، ويطرح بدلاً منهما بنية NEO-Unify التي تعالج المعلومات اللغوية والبصرية حتى النهاية داخل فضاء تمثيل واحد. يتولى النموذج المفرد معالجة الفهم والتوليد والتحرير، وصولاً إلى التوليد المتشابك (interleave) الذي يبثّ النص والصورة بالتناوب. أُتيحت الأوزان برخصة Apache 2.0، وبحجم يقارب 8B فإنها تعمل على بطاقة RTX 5090 واحدة. وهذا يعني إمكانية الاستضافة الذاتية لأغراض تجارية.

يستعرض هذا المقال حقائق SenseNova U1، وما يمكننا فعلياً تشغيله في بيئتنا المحلية (on-premise)، بصراحة تامة، بما في ذلك سبب استحالة تشغيله مباشرة على أدوات شائعة كـ Automatic1111 كما قد يتوقع البعض. وبما أن ThakiCloud تعمل على تقديم النماذج ضمن بيئات عملاء متنوعة، فإن جوهر هذا المقال هو سدّ الفجوة بين عنوان "صدرت أوزان مفتوحة" وواقع "يمكن تشغيلها على مجموعتنا الحاسوبية".

## ما هو SenseNova U1: معنى التخلي عن VAE

تنطلق NEO-Unify من ملاحظة بسيطة: البكسلات والكلمات مترابطة بعمق في جوهرها، لكن خطوط الأنابيب (pipelines) التقليدية أجبرتها على الانفصال. لذلك يزيل U1 محوّلين وسيطين كاملين. لا يوجد مشفر بصري (VE) كان يضغط الصورة إلى سمات، ولا يوجد VAE كان يعيد القيم الكامنة إلى بكسلات. بدلاً من ذلك، يدمج المعلومات اللغوية والبصرية في تمثيل مركّب واحد ويعالجه من البداية إلى النهاية. وتوضح SenseTime أن هذا يعمل فوق بنية MoT (خليط من المحولات، Mixture-of-Transformers) أصيلة، مما يتيح استنتاجاً كفؤاً بلا تعارض بين الوسائط المختلفة.

من منظور المستخدم، يتجلى هذا الفرق في "نموذج واحد يقوم بكل شيء". فهو يفهم الصور (الإجابة عن أسئلة بصرية، VQA)، ويولّد الصور، ويحرّرها، ويولّد النص والصورة بالتناوب ضمن تدفق واحد. ويُطرح كمثال بارز إنتاج محتوى يتناوب فيه الشرح مع الرسوم التوضيحية، كدروس الطهي أو يوميات السفر، وذلك في عملية توليد واحدة. كما تشدد SenseTime على قدرته في مجال الذكاء المكاني (spatial intelligence) على فهم التخطيطات المعقدة والعلاقات بين الأجسام، وهو ما يمهد لمستقبل يكتمل فيه الإدراك والاستدلال والتنفيذ في نموذج واحد ضمن الذكاء الاصطناعي المتجسّد (embodied AI) للروبوتات.

فيما يلي مخطط مفاهيمي يضع خط أنابيب سلسلة SD التقليدي جنباً إلى جنب مع خط الأنابيب الموحد لـ U1.

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
<div class="d3-arch" data-arch-root id="eounifyunifiedmultimodal-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1142, "height": 777, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 273, "h": 721, "label": "سلسلة SD التقليدية (منفصلة)", "lx": 36, "ly": 42}, {"x": 830, "y": 24, "w": 280, "h": 558, "label": "SenseNova U1 (موحد عبر NEO-Unify)", "lx": 842, "ly": 42}], "nodes": [{"id": "A1", "x": 101, "y": 63, "w": 120, "h": 46, "title": "توجيه نصي"}, {"id": "A2", "x": 90, "y": 217, "w": 142, "h": 46, "title": "مشفر النص (CLIP)"}, {"id": "A3", "x": 62, "y": 365, "w": 198, "h": 46, "title": "UNet / DiT (انتشار كامن)"}, {"id": "A4", "x": 101, "y": 497, "w": 120, "h": 46, "title": "مفكّك VAE"}, {"id": "A5", "x": 101, "y": 660, "w": 120, "h": 46, "title": "صورة بكسلية"}, {"id": "B1", "x": 903, "y": 63, "w": 135, "h": 46, "title": "مدخل نصي · صورة"}, {"id": "B2", "x": 885, "y": 209, "w": 170, "h": 62, "title": ["فضاء تمثيل موحد واحد", "(بلا VE · بلا VAE)"]}, {"id": "B3", "x": 868, "y": 357, "w": 205, "h": 62, "title": ["محوّل MoT أصيل", "فهم · توليد · تحرير مشترك"]}, {"id": "B4", "x": 871, "y": 497, "w": 198, "h": 46, "title": "مخرج نصي · صورة · متشابك"}, {"id": "GAP", "x": 335, "y": 209, "w": 212, "h": 62, "title": ["كلفة الانفصال:", "تمثيل مختلف للفهم والتوليد"]}, {"id": "SD", "x": 381, "y": 63, "w": 120, "h": 46, "title": "SD"}, {"id": "WIN", "x": 602, "y": 201, "w": 191, "h": 78, "title": ["فائدة التوحيد:", "حفظ الارتباط بين البكسل", "والكلمة"]}, {"id": "U1", "x": 637, "y": 63, "w": 120, "h": 46, "title": "U1"}], "edges": [{"src": "A1", "dst": "A2", "kind": "data", "line": [161, 109, 161, 217]}, {"src": "A2", "dst": "A3", "kind": "data", "line": [161, 263, 161, 365]}, {"src": "A3", "dst": "A4", "kind": "data", "line": [161, 411, 161, 497]}, {"src": "A4", "dst": "A5", "kind": "data", "line": [161, 543, 161, 660]}, {"src": "B1", "dst": "B2", "kind": "data", "line": [970, 109, 970, 209]}, {"src": "B2", "dst": "B3", "kind": "data", "line": [970, 271, 970, 357]}, {"src": "B3", "dst": "B4", "kind": "data", "line": [970, 419, 970, 497]}, {"src": "SD", "dst": "GAP", "kind": "event", "label": "\"3 وحدات، نوعا تمثيل\"", "line": [441, 109, 441, 209], "lx": 441, "ly": 151}, {"src": "U1", "dst": "WIN", "kind": "event", "label": "\"وحدة واحدة، نوع تمثيل واحد\"", "line": [697, 109, 697, 201], "lx": 697, "ly": 151}]});
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
      const container = document.getElementById('eounifyunifiedmultimodal-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eounifyunifiedmultimodal-1';
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

الجوهر هو أن U1 ليس نقطة تفتيش انتشارية (diffusion checkpoint)، بل محوّل موحد يعمل كنموذج لغوي كبير. وهذه الحقيقة الواحدة هي ما يحدد بالكامل طريقة التقديم وتوافقية الأدوات التي سنتناولها لاحقاً.

## ما أُتيح ليس U1 Pro بل سلسلة U1 Lite

هنا يجب التنويه بتمييز جوهري. **U1 Pro** الظاهر على صفحة منصة SenseTime (`sensenova.cn`) هو النسخة التجارية الرائدة المستضافة. ورغم أن أمثلة توليد الرسوم البيانية والملصقات عالية الكثافة مثيرة للإعجاب، فإن أوزان هذه الفئة "Pro" غير متاحة على HuggingFace. فمن الصواب اعتباره طبقة تجارية يُصار إليها عبر واجهة برمجية (API) فقط.

أما ما يمكن استضافته ذاتياً فهي **سلسلة U1 Lite**. وفيما يلي أهم الأوزان المتاحة:

| النموذج | المعاملات | الطابع |
|---|---|---|
| SenseNova-U1-8B-MoT | 8B (MoT كثيف) | العمود الفقري المفتوح الرائد. وسائط متعددة عامة الغرض |
| SenseNova-U1-A3B-MoT | A3B (MoE، حوالي 3B نشطة) | عمود فقري MoE خفيف |
| SenseNova-U1-8B-MoT-SFT / A3B-SFT | 8B / A3B | أوزان مرحلة SFT (تقليل أخذ العينات ×32) |
| SenseNova-U1-8B-MoT-Infographic (V1/V2/V3) | 8B | متخصص في الرسوم البيانية، والإصدار V3 محدّث بتاريخ 15/7 |
| SenseNova-U1-8B-MoT-Interleaved | 8B | متخصص في التوليد المتشابك |
| SenseNova-U1-8B-MoT-LoRA-8step | 0.4B | LoRA للتوليد السريع بثماني خطوات |

تمر نماذج SFT بمراحل: إحماء الفهم ← التدريب المسبق للتوليد ← التدريب المتوسط الموحد ← الضبط الدقيق الموحد (SFT)، ويُحصل على النموذج النهائي بإضافة تعلم معزز (RL) للتحويل من نص إلى صورة (T2I) فوق ذلك. وتشير SenseTime إلى أن ما صدر اليوم هو نسخة "Lite"، مع الإعلان عن نسخة أكبر حجماً قادمة. أي أن النموذجين 8B/A3B الحاليين نسخة مدمجة نسبياً، والسقف ما زال مفتوحاً.

باختصار، إذا قيل في مدونة أو عرض توضيحي "لقد شغّلنا U1 Pro"، فهذا غير دقيق. النموذج المفتوح الذي نضعه في بيئتنا المحلية هو **U1-8B-MoT** (أو A3B).

## الموقع على المعايير القياسية

تدّعي SenseTime أن U1 هو "أفضل أداء (SoTA) ضمن المعسكر مفتوح المصدر في كل من الفهم والتوليد معاً". أُجري التقييم على معايير OneIG (بالإنجليزية/الصينية)، LongText (بالإنجليزية/الصينية)، BizGenEval (سهل/صعب)، CVTG، IGenBench، ومعايير الرسوم البيانية. وتُبرز بطاقة النموذج مخطط المفاضلة بين الأداء وزمن استجابة التوليد (latency)، مع التركيز على تحقيق الجودة نفسها بسرعة أكبر.

بدلاً من نقل الأرقام كما هي، ينبغي النظر إلى طبيعتها. يُقدَّم U1 Lite بوصفه قادراً على تحقيق نتائج بمستوى تجاري في توليد الرسوم البيانية المعقدة تحديداً، أي في المجالات التي تكون فيها اتساقية التخطيط ودقة عرض النص أموراً حاسمة. وتذكر بعض المصادر الإعلامية أن جودة مخرجات U1 Lite تضاهي Qwen-Image 2.0 Pro أو Seedream 4.5، لكن هذا مستند إلى مصادر البائع أو مصادر ثانوية، لذا يبقى مصنّفاً بـ[تقدير] ويحتاج إلى تحقق فعلي. معيارنا واحد فقط: نثق بالأرقام التي نحصل عليها من تشغيله فعلياً ببياناتنا وتوجيهاتنا على معالجاتنا الرسومية (GPU).

## التثبيت والتقديم: مساران

حقيقة أن U1 ليس نقطة تفتيش انتشارية بل محوّل موحد تنعكس مباشرة على طريقة تقديمه. فبدلاً من وضعه فوق واجهة انتشار (diffusion UI)، يُقدَّم كما يُقدَّم أي نموذج لغوي كبير.

**المسار الأول: transformers الأصيل.** يوفر المستودع الرسمي تثبيت التبعيات عبر uv وسكربتات أمثلة مخصصة لكل مهمة، منها: تحويل النص إلى صورة، وتحرير الصور، والتوليد المتشابك.

```bash
# مثال على تحرير صورة (يمكن التحرير على مستوى البكسل حتى بلا VAE)
python examples/editing/inference.py \
  --model_path sensenova/SenseNova-U1-8B-MoT \
  --prompt "Change the animal's fur color to a darker shade." \
  --image examples/editing/data/images/1.webp \
  --cfg_scale 4.0 --img_cfg_scale 1.0 --num_steps 50 \
  --output output_edited.png --profile --compare

# التوليد المتشابك (شرح + رسوم توضيحية في تدفق واحد)
python examples/interleave/inference.py \
  --model_path sensenova/SenseNova-U1-8B-MoT \
  --prompt "أنشئ دليلاً مصوراً للمبتدئين لطبق البيض المقلي بالطماطم." \
  --resolution "16:9" --output_dir outputs/interleave/ --stem demo
```

**المسار الثاني: التقديم عبر vLLM-Omni.** لإلحاق النموذج بعرض توضيحي أو منتج، يلزم وجود نقطة نهاية متوافقة مع OpenAI. يدعم vLLM-Omni نموذج U1 رسمياً، ويوفر أمثلة لكل من الاستدلال دون اتصال (offline) والتقديم عبر الشبكة (online). ولتخفيف الضغط على ذاكرة VRAM، توجد إمكانية نقل الحمل إلى المعالج المركزي (CPU offload) على مستوى الوحدات. يطبّق خط الأنابيب اكتشاف المكونات (component discovery)، فينقل النموذج اللغوي إلى المعالج المركزي أثناء مراحل ترميز النص/الرؤية، وينقل المشفر البصري إلى المعالج المركزي أثناء حلقة الانتشار، لتقليل الأوزان المقيمة على معالج الرسوميات إلى الحد الأدنى.

```bash
# vLLM-Omni: تحويل نص إلى صورة مع تفعيل نقل الحمل إلى المعالج المركزي
python end2end.py \
  --prompt "A cute cat sitting on a windowsill" \
  --width 2048 --height 2048 \
  --enable-cpu-offload --think
```

**خيارات لذاكرة VRAM المحدودة.** يوفر المستودع الرسمي نمط نقل الطبقات (layer offload) على معالج رسوميات واحد (`--vram_mode full|low|balanced`) إلى جانب تحميل التكميم GGUF. تشير التوجيهات إلى أن الجمع بين Q4 GGUF ووضع `balanced` يتيح التشغيل حتى على بطاقات استهلاكية بذاكرة تقارب 10 إلى 12 جيجابايت. أي أن النشر ينقسم إلى ثلاث مستويات: للحصول على أقصى سرعة استخدم `full` مع 24 جيجابايت فأكثر، وإن لم تتوفر تلك الموارد فاستخدم GGUF مع `balanced`، وللتقشف الشديد استخدم `low`.

## أي الأدوات تُستخدم: ComfyUI نعم، A1111 لا

أكثر توقع شائع هو "لنحمّل النموذج كنقطة تفتيش في Stable Diffusion WebUI (Automatic1111)". والخلاصة أن ذلك غير ممكن. صُمم A1111 لتحميل نقاط تفتيش سلسلة SD المكوّنة من UNet/DiT + VAE + مشفر نص CLIP حصراً. وبما أن U1 محوّل MoT موحد لا يحوي VAE، فإن وضع ملف `.safetensors` في مجلد نقاط التفتيش لا يؤدي حتى إلى نجاح عملية التحميل. إنه عدم توافق جوهري ناتج عن اختلاف البنية.

إن أردت إدخال التوجيهات يدوياً بطريقة تفاعلية، فإن البديل الفعلي لـ A1111 هو **ComfyUI**. توفر عقدة مخصصة أنشأها المجتمع (`smthemex/ComfyUI_SenseNova_U1`) دعماً أصيلاً لنموذج U1، وتتعامل مع 8B-MoT و A3B-MoT وLoRA بثماني خطوات وGGUF جميعاً.

| الأداة | الدعم | ملاحظات |
|---|---|---|
| ComfyUI | مدعوم | عقدة مخصصة `smthemex/ComfyUI_SenseNova_U1`. البديل الفعلي لـ A1111 |
| Automatic1111 | غير متوافق | يحمّل نقاط تفتيش SD فقط. النموذج الموحد بلا VAE غير ممكن بنيوياً |
| vLLM-Omni | مدعوم | تقديم متوافق مع OpenAI. مناسب للعروض التوضيحية والخلفيات البرمجية للمنتجات |
| transformers | مدعوم | أصيل. سكربتات أمثلة مخصصة لكل مهمة |
| diffusers + GGUF | مدعوم | مسار تحميل لذاكرة VRAM المحدودة |
| Replicate | مدعوم | نشر مرجعي (`lucataco/sensenova-u1-8b-mot`) |

باختصار، محوران: الواجهة التفاعلية التي يستخدمها الأشخاص يدوياً هي ComfyUI، والخلفية البرمجية للعروض التوضيحية والمنتجات التي يستدعيها البرنامج هي vLLM-Omni (متوافق مع OpenAI). من كان يتوقع A1111 فعليه تغيير اختيار الأداة.

## منظور ThakiCloud في التقديم

يعمل ai-platform لدى ThakiCloud فوق Kubernetes على تقديم النماذج ضمن بيئات عملاء متنوعة. ويُعد SenseNova U1 مرشحاً جيداً للتناول من هذا المنظور تحديداً.

أولاً، الحجم ملائم للبيئة المحلية (on-premise). فبحجم 8B، يقيم النموذج في نحو 16 إلى 20 جيجابايت وفق دقة fp16، ما يسمح ببناء حاوية تقديم (serving pod) على بطاقة واحدة من RTX 4090 أو 5090 أو A6000، بينما نموذج A3B أخف من ذلك. وهذا ينسجم تماماً مع طريقتنا في وضع معالجات الرسوميات في طابور عبر Kueue وتوزيعها متعددة المستأجرين. فبخلاف النماذج الحدودية الضخمة التي تتطلب 8 وحدات H200، يمكن لعبء عمل فعلي أن يقوم على بطاقة أو بطاقتين من معالجات رسوميات العميل نفسه.

ثانياً، تخفض نقطة النهاية المتوافقة مع OpenAI في vLLM-Omni تكلفة التكامل. وبما أن طبقة التقديم Metis وخطوط أنابيب العروض التوضيحية لدينا مبنية أصلاً على افتراض واجهة متوافقة مع OpenAI، يمكن إلحاق U1 دون الحاجة إلى مكدس انتشار (diffusion stack) منفصل. وتوحيد واجهة توليد الصور مع النموذج اللغوي النصي تحت نظام واحد للمراقبة وقياس التكلفة ميزة عملية حقيقية.

ثالثاً، تتطابق رخصة Apache 2.0 والاستضافة الذاتية الكاملة تماماً مع متطلبات السيادة والتقديم المحلي. بالنسبة للعملاء في القطاعين العام والمالي الذين يجب ألا تغادر بياناتهم عبر واجهة برمجية خارجية، فإن نموذج توليد الصور الذي يعمل على معالجات رسوميات محلية يمثّل بحد ذاته ميزة تنافسية. وتنبع هذه الميزة أيضاً من انخفاض تكلفة التقديم.

كما ينفتح منظور الوكلاء (agents). فـ Paxis، سحابة ThakiCloud الأصيلة للوكلاء (Agent-Native Cloud)، تنفّذ المهارات في بيئات معزولة (sandboxes) وتُخضع كل سلوك لبوابات سياسات وسجلات تدقيق، ونموذج صور موحد مستضاف ذاتياً كـ U1 مناسب تماماً للتسجيل بوصفه "أداة توليد صور" يستدعيها الوكيل. فحين تُستكمل عملية توليد الرسوم البيانية والملصقات في حاويات داخلية دون واجهة برمجية خارجية، فإن التقديم منخفض التكلفة (ai-platform) يرفع مباشرة من جدوى اقتصاديات سير عمل الوكلاء (Paxis).

## القيود والحجج المضادة

للحفاظ على التوازن، لا بد من النظر إلى الجانب الآخر أيضاً. أولاً، ما هو مُتاح الآن هو النسخة Lite (8B/A3B)، ومن المرجح أن تكون الجودة الفائقة محصورة في نسخة U1 Pro المستضافة. فتعبير "أفضل أداء مفتوح" هو مقارنة ضمن المعسكر مفتوح المصدر، وليس ضماناً لمساواته بأفضل النماذج التجارية.

ثانياً، ميزة البنية الموحدة هي في الوقت نفسه نقطة ضعف في النظام البيئي. فبما أن U1 ليس نموذج SD، فإنه لا يرث أصول سير عمل A1111/SD المتراكمة على مدى سنوات، كـ ControlNet ومكتبات LoRA المجتمعية الضخمة وامتدادات إعادة الرسم (inpainting). ونقل خطوط الأنابيب القائمة إلى U1 يتطلب إعادة بناء منظومة الأدوات من الصفر. صحيح أن عقد ComfyUI ومدرّب LoRA الخاص متاحان، لكن نضج النظام البيئي لا يزال في مراحله الأولى.

ثالثاً، معظم أرقام المعايير القياسية مصدرها تقارير البائع الذاتية، وبخاصة عرض النص باللغة الكورية والالتزام بالتوجيه، فهذه تتطلب تحققاً منفصلاً. أما استمرار قوة الرسوم البيانية في تنضيد الحروف الكورية فهو أمر لا يمكن التأكد منه إلا بالتشغيل الفعلي.

رابعاً، وضع ذاكرة VRAM المنخفضة ليس مجانياً. فنقل الحمل إلى المعالج المركزي وتسلسل الطبقات (layer streaming) يوفّران ذاكرة VRAM لكن على حساب زيادة زمن الاستجابة بسبب النقل بين المعالج المركزي ومعالج الرسوميات. وإذا كانت الاستجابة اللحظية أمراً حاسماً للخدمة، فالأفضل التشغيل بوضع `full` على بطاقة بذاكرة 24 جيجابايت فأكثر دون نقل حمل، وهذا ينعكس بدوره على تكلفة معالج الرسوميات.

## الخاتمة

يمثّل SenseNova U1 تحقيقاً فعلياً لاتجاه "الوسائط المتعددة الموحدة بلا VAE" عبر أوزان مفتوحة. ورغم أن مدى ما يمكن أن يبلغه نهج دمج الفهم والتوليد في تمثيل واحد لن يتضح إلا مع صدور نسخة أكبر، فإن النسختين الحاليتين 8B/A3B جذابتان بما يكفي بوصفهما مرشحتين للتقديم المحلي. في المقال القادم، سنضع هذا النموذج فعلياً على RunPod وخط أنابيب العروض التوضيحية لدينا، ونشغّل تقديم vLLM-Omni وسير عمل ComfyUI جنباً إلى جنب، ونستعرض النتائج مدعومة بالأرقام.

**روابط مرجعية**

- بطاقة النموذج: [sensenova/SenseNova-U1-8B-MoT](https://huggingface.co/sensenova/SenseNova-U1-8B-MoT)
- الكود/التوثيق: [OpenSenseNova/SenseNova-U1 (GitHub)](https://github.com/OpenSenseNova/SenseNova-U1)
- الورقة البحثية: [SenseNova-U1: Unifying Multimodal Understanding and Generation with NEO-unify (arXiv:2605.12500)](https://arxiv.org/abs/2605.12500)
- التقديم: [مثال vLLM-Omni لنموذج SenseNova-U1](https://docs.vllm.ai/projects/vllm-omni/en/latest/user_guide/examples/offline_inference/sensenova_u1/)
- عقدة ComfyUI: [smthemex/ComfyUI_SenseNova_U1](https://github.com/smthemex/ComfyUI_SenseNova_U1)
- نسخة U1 Pro المستضافة: [SenseNova U1 Pro](https://www.sensenova.cn/en/u1-pro)
