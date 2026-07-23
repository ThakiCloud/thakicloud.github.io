---
title: "إنشاء الفيديو من Claude Code: جرّبت claude-code-video-toolkit بنفسي"
excerpt: "أداة مفتوحة المصدر تعرض فيديو بدقة 1080p من داخل Claude Code بأمرين من أوامر الشرطة المائلة. استنسخت examples/hello-world وعرضته دون أي مفاتيح API، فخرج مقطع 1080p بطول 25 ثانية و750 إطارًا خلال نحو 18 ثانية. إليك البنية والنتائج المقاسة، وكيف تنظر منصة ThakiCloud السحابية على Kubernetes إلى أحمال عمل الفيديو على وحدات GPU."
seo_title: "تجربة عملية مع claude-code-video-toolkit ومنظور المنصة - Thaki Cloud"
seo_description: "تشغيل عملي لـ digitalsamba/claude-code-video-toolkit دون مفاتيح API (تثبيت npm 3.5 ثانية، عرض بارد 18.4 ثانية، 1920x1080 بطول 25 ثانية و2.15 ميجابايت) مع تحليل بنيوي. Remotion، حزمة نماذج مفتوحة المصدر، ومنظور أحمال GPU على منصة ThakiCloud على Kubernetes."
date: 2026-06-23
last_modified_at: 2026-06-23
tags:
  - ai-coding
  - claude-code
  - remotion
  - video-generation
  - gpu
  - platform-engineering
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/technique/claude-code-video-toolkit/"
categories:
  - tutorials
---

![تمثيل تجريدي لخط إنتاج فيديو مؤتمت]({{ '/assets/images/claude-code-video-toolkit-hero.webp' | relative_url }})
*خط إنتاج فيديو مؤتمت، مصوّر كجسيمات ضوء تتجمّع في إطارات منظّمة.*

## نظرة عامة

طالما تطلّب إنتاج الفيديو محرّرات مخصّصة ولمسة بشرية. لكن مؤخرًا ترسّخ نمط حيث يُوصَف الفيديو بالشيفرة ويُعرَض، تمامًا كما تكتب وكلاء البرمجة الشيفرة. يضع `digitalsamba/claude-code-video-toolkit` هذا النمط فوق Claude Code. عند إصداره يُظهر نحو 1.6 ألف نجمة على GitHub و268 تفريعة و182 إيداعًا، برخصة MIT.

الفكرة الأساسية بسيطة. تصف مشروع فيديو باستخدام Remotion، وهو إطار قائم على React؛ وتفوّض توليد الأصول مثل الصوت والصور والموسيقى ولقطات الـ b-roll إلى نماذج ذكاء اصطناعي مفتوحة المصدر؛ وتربط العملية كلها بأوامر الشرطة المائلة ومهارات Claude Code. ينشئ المستخدم مشروعًا من قالب بأمر `/video` واحد، ويهيّئ وحدة GPU السحابية والتخزين والصوت بأمر `/setup`، ثم ينتقل إلى العرض.

تشغّل ThakiCloud منصة SaaS للذكاء الاصطناعي والتعلّم الآلي قائمة على Kubernetes وتتعامل مع أحمال GPU يوميًا. عرض الفيديو وتركيب الأصول التوليدية مهام نموذجية مرتبطة بوحدة GPU، وفي بيئة متعددة المستأجرين فإن كيفية توزيع الموارد هي التكلفة نفسها. لذلك تستحق هذه الأداة القراءة لا كأداة محتوى فحسب، بل كمثال على نوع الحمل الذي تتعامل معه منصتنا. في هذه التدوينة أعرض أولًا ما حدث حين استنسخت الأداة وشغّلتها فعليًا، ثم أناقش معناها من منظور المنصة.

## ما هذه الأداة

تحوّل claude-code-video-toolkit بيئة Claude Code إلى محطة عمل لإنتاج الفيديو. من المفيد فهمها في ثلاث طبقات.

الأولى هي طبقة أوامر الشرطة المائلة. يرشدك `/setup` تفاعليًا عبر التهيئة الأولى مثل GPU السحابية ونقل الملفات والصوت. ينشئ `/video` المشاريع ويفتحها، ويساعد `/scene-review` في المراجعة مشهدًا مشهدًا داخل Remotion Studio. وإلى جانب ذلك توجد أوامر لكل مرحلة من مراحل الإنتاج: `/brand` و`/template` و`/generate-voiceover` و`/voice-clone` و`/redub` و`/record-demo` و`/publish` وغيرها. يرفع `/publish` الفيديو المكتمل إلى YouTube ويملأ البيانات الوصفية تلقائيًا من `project.json`.

الثانية هي طبقة المهارات. تجمّع هذه المعرفة المجالية كي يتعامل معها Claude Code بعمق: remotion (إطار فيديو قائم على React)، وelevenlabs (الصوت)، وffmpeg (معالجة الوسائط)، وplaywright-recording (تسجيل العروض في المتصفح)، وfrontend-design (التصميم البصري)، وqwen-edit (تحرير الصور)، وideogram4 (توليد صور بنص داخلي قوي)، وacestep (الموسيقى)، وltx2 (مقاطع فيديو مدفوعة بالنص والصورة)، وmoviepy (تركيب فيديو بلغة بايثون)، وrunpod (وحدة GPU سحابية)، بإجمالي إحدى عشرة مهارة.

الثالثة هي طبقة القوالب والعلامة التجارية. يتضمّن `templates/` قوالب sprint-review وsprint-review-v2 وproduct-demo وconcept-explainer-short للمقاطع العمودية بنسبة 9:16. ويعرّف `brands/` ملفات علامة تجارية تحمل الألوان والخطوط وإعدادات الصوت، وتُطبَّق تلقائيًا عند إنشاء مشروع بأمر `/video`. يوضّح المخطط أدناه كيف تتصل هذه الطبقات الثلاث في خط إنتاج واحد.

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
<div class="d3-arch" data-arch-root id="23claudecodevideotoolkit-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 939, "height": 910, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 315, "y": 24, "w": 121, "h": 46, "title": "موجّه / سكربت"}, {"id": "B", "x": 316, "y": 148, "w": 120, "h": 46, "title": "أمر /video"}, {"id": "C", "x": 280, "y": 272, "w": 191, "h": 62, "title": ["ملف العلامة التجارية", "brand.json · voice.json"]}, {"id": "D", "x": 308, "y": 412, "w": 135, "h": 62, "title": ["تركيبة Remotion", "فيديو React"]}, {"id": "E", "x": 473, "y": 552, "w": 156, "h": 62, "title": ["طبقة مهارات الذكاء", "الاصطناعي"]}, {"id": "E1", "x": 786, "y": 692, "w": 121, "h": 62, "title": ["Qwen3-TTS", "صوت · استنساخ"]}, {"id": "E2", "x": 568, "y": 692, "w": 163, "h": 62, "title": ["FLUX.2 · Ideogram4", "صور · بطاقات عناوين"]}, {"id": "E3", "x": 393, "y": 692, "w": 120, "h": 62, "title": ["ACE-Step", "موسيقى"]}, {"id": "E4", "x": 218, "y": 692, "w": 120, "h": 62, "title": ["LTX-2", "b-roll"]}, {"id": "F", "x": 28, "y": 552, "w": 149, "h": 62, "title": ["remotion render", "h264 · 1080p · 6x"]}, {"id": "G", "x": 42, "y": 700, "w": 121, "h": 46, "title": "out/video.mp4"}, {"id": "H", "x": 24, "y": 832, "w": 156, "h": 46, "title": "/publish → YouTube"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [376, 70, 376, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [376, 194, 376, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [376, 334, 376, 412]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[443, 470], [551, 513], [551, 513], [551, 552]]}, {"src": "E", "dst": "E1", "kind": "data", "curve": [[629, 601], [846, 653], [846, 653], [846, 692]]}, {"src": "E", "dst": "E2", "kind": "data", "curve": [[594, 614], [649, 653], [649, 653], [649, 692]]}, {"src": "E", "dst": "E3", "kind": "data", "curve": [[507, 614], [453, 653], [453, 653], [453, 692]]}, {"src": "E", "dst": "E4", "kind": "data", "curve": [[473, 603], [278, 653], [278, 653], [278, 692]]}, {"src": "D", "dst": "F", "kind": "data", "curve": [[308, 460], [102, 513], [102, 513], [102, 552]]}, {"src": "F", "dst": "G", "kind": "data", "line": [102, 614, 102, 700]}, {"src": "G", "dst": "H", "kind": "data", "line": [102, 746, 102, 832]}]});
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
      const container = document.getElementById('23claudecodevideotoolkit-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '23claudecodevideotoolkit-1';
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

تبرز بنية التكلفة على نحو خاص. صُمّمت الأداة كي تعتمد الأصول التوليدية مثل الصوت (Qwen3-TTS) والصور (FLUX.2) والموسيقى (ACE-Step) على نماذج مفتوحة المصدر بدلًا من واجهات API تجارية. تنشر النماذج على حساب GPU السحابي الخاص بك وتشغّلها بسعر التكلفة. للتخزين تشير إلى الطبقة المجانية من Cloudflare R2 (10 غيغابايت، دون رسوم خروج)، وللحوسبة إلى خطة Modal Starter برصيد مجاني 30 دولارًا شهريًا. هذا الخيار القائم على الاستضافة الذاتية يتطابق تمامًا مع منظور المنصة الذي سنناقشه لاحقًا.

## التثبيت والتكامل

البدء السريع الموثّق كالتالي: استنساخ المستودع، وتثبيت اعتماديات بايثون اختياريًا، وفتح Claude Code.

```shell
git clone https://github.com/digitalsamba/claude-code-video-toolkit.git
cd claude-code-video-toolkit
python3 -m pip install -r tools/requirements.txt   # اختياري: التعليق الصوتي وتوليد الصور والموسيقى وأمثلة moviepy
claude                                              # تشغيل Claude Code داخل الأداة
```

ثم داخل Claude Code، تهيّئ GPU السحابية والتخزين والصوت تفاعليًا لنحو خمس دقائق بأمر `/setup`، وتنشئ مشروعك الأول بأمر `/video`. المتطلبات هي Node.js 18+ وClaude Code؛ ويُنصح ببايثون 3.9+ لأدوات الذكاء الاصطناعي. أما FFmpeg فاختياري.

الأهم هنا أن ثمة مسارًا منفصلًا للتحقق من العرض فورًا دون أي تهيئة. `examples/hello-world` مثال مصغّر لا يحتاج أي مفاتيح API. اتّبعت هذا المسار بالضبط وشغّلته فعليًا.

```shell
cd examples/hello-world
npm install
npm run render
```

بالنظر إلى `package.json` الخاص بـ `hello-world`، يكون سكربت العرض `npx remotion render src/index.ts SprintReview out/video.mp4`، والاعتماديات هي إصدار Remotion 4.0.425 وReact 18. أي إنه يحوّل تركيبة React مباشرة إلى فيديو دون أي استدعاءات نماذج خارجية.

## نتائج التجربة الفعلية

أجريت التحقق داخل شجرة عمل git معزولة، وكل رقم مأخوذ مباشرة من سجل التشغيل. كانت البيئة Apple Silicon (arm64) وNode.js 24.1.0 وnpm 11.3.0.

أولًا، تثبيت الاعتماديات. أضاف `npm install` نحو 230 حزمة واستغرق قرابة 3.5 ثانية. لكن التدقيق أبلغ عن 10 ثغرات (7 متوسطة و3 عالية)، وهو ما أعود إليه في قسم القيود.

في خطوة العرض، ينزّل Remotion مرة واحدة عند التشغيل الأول Chrome Headless Shell. في هذا التشغيل نزّل نحو 90.2 ميجابايت، وهي تكلفة لمرة واحدة. ثم تلت ذلك عملية التجميع والتركيب. كانت التركيبة `SprintReview`، والترميز h264، والتزامن 6x، وعرض كامل الإطارات البالغة 750 إطارًا. ترك السجل الملاحظة "Cached bundle. Subsequent renders will be faster"، موضحًا أن عمليات العرض اللاحقة أسرع بفضل ذاكرة التجميع المؤقتة.

من حالة باردة، بلغ الزمن الفعلي لأمر `npm run render`، شاملًا التنزيل والتجميع والعرض والترميز، 18.4 ثانية. كان الناتج النهائي فيديو h264 بدقة 1920x1080 و30 إطارًا في الثانية وطول 25.0 ثانية وحجم 2.15 ميجابايت (2,152,829 بايت)، متضمنًا مسار صوت AAC. لم يُستخدم أي مفتاح API على الإطلاق.

![مخطط الأزمنة المقاسة لكل مرحلة في خط عرض hello-world]({{ '/assets/images/claude-code-video-toolkit-results.webp' | relative_url }})
*الزمن الفعلي لكل مرحلة في خط عرض hello-world بدقة 1080p، مقاسًا دون أي مفاتيح API.*

باختصار، ودون أي تهيئة منفصلة، صار فيديو 1080p واحد في متناول اليد خلال نحو 30 ثانية من الاستنساخ. كان ذلك أسرع حتى من وصف المثال "يُعرَض في دقيقتين"، لكن بما أن هذا يتفاوت بحسب العتاد وظروف الشبكة فلا ينبغي اعتبار الرقم مطلقًا. المهم أن حاجز الدخول منخفض إلى هذا الحد.

## التطبيق على منصة ThakiCloud السحابية للذكاء الاصطناعي على Kubernetes

تكمن جاذبية هذه الأداة في أنها تشبه بنيويًا الأحمال التي تتعامل معها منصتنا. عرض الفيديو وتركيب الأصول التوليدية كلاهما مهام دفعية مرتبطة بوحدة GPU، بنمط استخدام الموارد في دفعات قصيرة وكثيفة قبل العودة إلى الخمول. تصفّ ThakiCloud مهام GPU وتمنحها الأولوية باستخدام Kueue فوق Kubernetes وتخدم النماذج عبر vLLM وغيره. إن الاستمرارية اللاخادمية بأسلوب Modal/Daytona التي توصي بها الأداة، حيث تدخل البيئة في سبات عند الخمول وتستيقظ عند الطلب، تحل المشكلة نفسها لكفاءة الموارد التي نسعى إليها عبر Kueue، لكن في طبقة مختلفة.

النقاط الجديرة بالإبراز هي التكلفة والاستضافة الذاتية. صُمّمت الأداة لتشغيل نماذج مفتوحة الأوزان مثل Qwen3-TTS وFLUX.2 وACE-Step على وحدة GPU الخاصة بك بسعر التكلفة بدلًا من واجهات API تجارية. يتوافق هذا تمامًا مع توجّه ThakiCloud في اعتبار التشغيل المحلي والاستضافة الذاتية نقاط قوة. حين يرغب عميل في تشغيل أحمال توليدية متعددة المستأجرين في بيئة عالية الأمان دون إرسال بيانات أو نماذج إلى الخارج، يمكن لمنصتنا أن تستوعب بطبيعتها خط إنتاج الفيديو والوسائط هذا أيضًا.

زاوية الاستخدام الداخلي واضحة كذلك. قالبا sprint-review وproduct-demo من المخرجات التي تنتجها فرق الهندسة بشكل متكرر. وإذا غلّفت هذا التوليد للفيديو كمهام Kubernetes ووضعتها في طابور Kueue، أمكنك نقل العرض الثقيل من حواسيب المطورين المحمولة إلى مجمّع GPU مشترك يُعالج بحسب الأولوية. كون الأداة نفسها مرتبطة بـ Claude Code قيدٌ، لكن فصل مرحلة عرض Remotion وحدها وتحويلها إلى حاوية يجعل وضعها على بنيتنا الدفعية أمرًا مباشرًا.

## القيود والاعتراضات

ثمة نقاط ضعف واضحة إلى جانب نقاط القوة. أولًا، أمان الاعتماديات. حتى `npm install` للمثال المصغّر أبلغ عن 10 ثغرات (منها 3 عالية). لطرحها في الإنتاج تحتاج أولًا إلى تدقيق الاعتماديات وتثبيتها، والأأمن فرض ذلك كبوابة في خط الأتمتة لديك.

ثانيًا، نطاق كلمة "مجاني". ما يعمل فورًا دون مفاتيح API هو العرض القائم على القوالب. ولاستخدام الأصول التوليدية مثل الصوت والصور والموسيقى وb-roll، عليك في النهاية نشر النماذج على وحدة GPU السحابية الخاصة بك، ومن تلك اللحظة تظهر تكلفة الحوسبة وعبء التشغيل. "مجاني" تعني التشغيل بنفسك بسعر التكلفة، لا أن لا تكلفة هناك.

ثالثًا، الارتباط بالأداة. يرتبط سير العمل هذا ارتباطًا وثيقًا بـ Claude Code. وبقدر ما تكون تجريدات أوامر الشرطة المائلة والمهارات مريحة، ثمة جانب من الاعتماد على بيئة وكيل بعينها. لحسن الحظ يتولّى العرض الأساسي إطار Remotion المستقل، فإذا لزم الأمر يمكنك فصل ذلك الجزء ونقله إلى تنسيق آخر.

رابعًا، يصف Remotion الفيديو بلغة React. وقد يكون هذا حاجزًا للمصممين وغير المطورين، كما أن التعامل مع رسوميات الحركة المعقّدة بالشيفرة قد يستلزم جهدًا أكبر من محرّر مخصّص. في النهاية تناسب هذه الأداة أكثر الفرق المعتادة على التعامل مع الفيديو بالشيفرة.

خلاصة القول، يُعدّ claude-code-video-toolkit نقطة انطلاق جيدة لأتمتة الفيديو الصديقة للشيفرة. تجربة إنتاج فيديو 1080p خلال 30 ثانية دون مفاتيح API نقطة قوة واضحة، وفلسفته القائمة على النماذج مفتوحة المصدر والاستضافة الذاتية تتوافق جيدًا مع توجّه منصتنا. ومع ذلك، تحتاج إلى موازنة التكلفة الحقيقية لمرحلة الأصول التوليدية وأمان الاعتماديات والارتباط بالأداة معًا للوصول إلى حكم متوازن.

## المصادر

- GitHub: [digitalsamba/claude-code-video-toolkit](https://github.com/digitalsamba/claude-code-video-toolkit)
- Remotion: [remotion.dev](https://www.remotion.dev/)
- بيئة الاختبار: Apple Silicon (arm64)، Node.js 24.1.0، npm 11.3.0 / جميع الأرقام مستخرجة مباشرة من سجلات التشغيل.
