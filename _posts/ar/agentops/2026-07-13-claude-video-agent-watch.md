---
title: "Claude Code يشاهد الفيديو: claude-video يحقن الإطارات والنصوص في الوكيل عبر /watch"
excerpt: "طالما اقتصرت وكلاء البرمجة على قراءة النص فقط. يربط claude-video بشكل رقيق بين yt-dlp وffmpeg وWhisper ليحوّل فيديوهات YouTube وZoom وLoom أو الملفات المحلية إلى صور إطارات ونصوص مؤقّتة زمنيا، ثم يحقنها في سياق Claude متعدد الوسائط عبر أداة Read. يفكّك هذا المقال التثبيت والاستخدام الفعليين لهذه المهارة مفتوحة المصدر (أكثر من 5400 نجمة على GitHub) وآليتها الداخلية (الترجمات أولا، استخراج الإطارات على ثلاثة مستويات، إزالة التكرار، بديل التفريغ)، ويقرأ معناها من خلال إطار مهارات Paxis السحابة الأصيلة للوكلاء في ThakiCloud وعدسة خدمة ai-platform."
seo_title: "claude-video: مهارة /watch التي تجعل Claude Code يرى الفيديو - Thaki Cloud"
seo_description: "تحليل لـ claude-video (bradautomates): مسار yt-dlp القائم على الترجمات أولا في مهارة /watch، واستخراج الإطارات ثلاثي المستويات بـ ffmpeg، وإزالة التكرار بتدرج رمادي 16x16، وتفريغ Whisper (Groq large-v3 وOpenAI كبديل) المحقون عبر Claude متعدد الوسائط Read، مع تبعات Paxis وai-platform في ThakiCloud."
date: 2026-07-13
last_modified_at: 2026-07-13
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/claude-video-agent-watch/"
tags:
  - agentops
  - claude-code
  - multimodal
  - agent-skills
  - video-understanding
  - ffmpeg
  - whisper
  - platform-engineering
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "robot"
categories:
  - agentops
---

## نظرة عامة

اقتصرت وكلاء البرمجة حتى الآن على قراءة النص فقط. ملفات المصدر والسجلات والوثائق واستجابات الواجهات، كلها كانت حروفا. ومع ذلك، فإن جزءا كبيرا مما يهم فعليا يعيش داخل الفيديو. تسجيلات عروض المنتجات، وشاشات إعادة إنتاج الأخطاء، وتسجيلات الاجتماعات، والفيديوهات التعليمية، ومقاطع إصدارات المنافسين. يفتح الإنسان أحدها فيقول "تنكسر الشاشة قرب الدقيقة 2:30"، لكن بالنسبة للوكيل كان ذلك الفيديو مجرد ملف ثنائي لا يمكن فتحه.

يهدم `claude-video` هذا الجدار بشكل رقيق. باختصار هو "يمنح Claude القدرة على مشاهدة الفيديو"، وما يفعله فعليا هو تحويل الفيديو إلى صور إطارات ونص مصحوب بطوابع زمنية، ثم دفعها إلى سياق Claude متعدد الوسائط عبر أداة Read. حتى يوليو 2026 تجاوز 5400 نجمة على GitHub، وتضعه بعض الإحصاءات عند 7000، مما يجعله أحد أكثر المشاريع تداولا في هذه اللحظة.

جمهور هذا المقال واضح. المطورون ومهندسو المنصات الذين يستخدمون وكلاء البرمجة مثل Claude Code وCursor وCopilot وGemini CLI في العمل الفعلي ويتساءلون كيف يدخلون المواد المرئية إلى خطوط أنابيبهم. وكل من يتساءل عن معنى هذه التقنية لتصميم منصات الوكلاء بما يتجاوز مجرد الراحة. الجواب المختصر: يعدّ claude-video مثالا جيدا على كيفية إضافة حاسة جديدة (البصر) إلى الوكيل عبر "إطار مُشغّل رقيق مع تركيبة من أدوات مُثبتة"، وهو ينسجم تماما مع الاتجاه الذي تنتهجه ThakiCloud في Paxis.

![صورة تجريدية تصوّر وكيلا يكتسب البصر بينما تتدفق إطارات الفيديو وموجات الصوت نحو عدسة واحدة]({{ '/assets/images/claude-video-agent-watch-hero.png' | relative_url }})

## ما هذه الأداة

لا يبني claude-video نموذجا جديدا. إنه مهارة تربط بشكل رقيق بين ثلاث أدوات مفتوحة المصدر مُثبتة بالفعل. يتولى `yt-dlp` تنزيل الفيديو والحصول على الترجمات، ويتولى `ffmpeg` استخراج الإطارات وتحويل الصوت، ويتولى `Whisper` تفريغ الكلام عند غياب الترجمات. أما التجميع النهائي والحكم فتقوم بهما أداة Read متعددة الوسائط في Claude. الجديد المكتوب هو خط الأنابيب الذي يصل هذه القطع الأربع، ومنطق إزالة التكرار الذي يصفّي الإطارات بذكاء.

الواجهة الأساسية أمر شرطة مائلة واحد هو `/watch`. يمرّر المستخدم رابط فيديو أو مسارا محليا، ويرفق سؤالا، ويحدد نطاقا عند الحاجة. عندها "يشاهد" الوكيل الفيديو ويجيب. مصادر الإدخال واسعة. ليس YouTube فحسب بل Instagram وX وVimeo وعموم أي موقع يدعمه yt-dlp، إضافة إلى تسجيلات Zoom وLoom وملفات mp4 المحلية.

يبدو التدفق الكامل هكذا.

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
<div class="d3-arch" data-arch-root id="713claudevideoagentwatch-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 785, "height": 896, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 284, "y": 24, "w": 212, "h": 78, "title": ["الوكيل: /watch رابط·مسار +", "سؤال", "اختياري --start / --end"]}, {"id": "B", "x": 412, "y": 180, "w": 212, "h": 62, "title": ["yt-dlp: التحقق من الترجمات", "أولا"]}, {"id": "C", "x": 442, "y": 333, "w": 153, "h": 52, "title": "هل توجد ترجمات؟"}, {"id": "D", "x": 548, "y": 506, "w": 205, "h": 62, "title": ["استخدام الترجمات المجانية", "كنص مؤقّت زمنيا"]}, {"id": "E", "x": 281, "y": 490, "w": 212, "h": 94, "title": ["استخراج صوت أحادي 16kHz ثم", "تفريغ Whisper", "Groq large-v3 أولا ·", "OpenAI بديل"]}, {"id": "F", "x": 24, "y": 320, "w": 212, "h": 78, "title": ["استخراج الإطارات بـ ffmpeg", "efficient · balanced ·", "token-burner"]}, {"id": "G", "x": 35, "y": 498, "w": 191, "h": 78, "title": ["إزالة التكرار", "16x16 رمادي · مقابل آخر", "إطار محفوظ"]}, {"id": "H", "x": 281, "y": 662, "w": 212, "h": 62, "title": ["المحاذاة زمنيا: الإطارات +", "النص"]}, {"id": "I", "x": 281, "y": 802, "w": 212, "h": 62, "title": ["الحقن في سياق Claude متعدد", "الوسائط Read"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[454, 102], [518, 141], [518, 141], [518, 180]]}, {"src": "B", "dst": "C", "kind": "data", "line": [518, 242, 518, 333]}, {"src": "C", "dst": "D", "kind": "data", "label": "نعم", "curve": [[559, 385], [650, 444], [650, 444], [650, 506]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "label": "لا", "curve": [[478, 385], [387, 444], [387, 444], [387, 490]], "off": "50%"}, {"src": "A", "dst": "F", "kind": "data", "curve": [[284, 95], [130, 141], [130, 281], [130, 320]]}, {"src": "F", "dst": "G", "kind": "data", "line": [130, 398, 130, 498]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[650, 568], [650, 623], [650, 623], [493, 665]]}, {"src": "E", "dst": "H", "kind": "data", "line": [387, 584, 387, 662]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[130, 576], [130, 623], [130, 623], [281, 664]]}, {"src": "H", "dst": "I", "kind": "data", "line": [387, 724, 387, 802]}]});
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
      const container = document.getElementById('713claudevideoagentwatch-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '713claudevideoagentwatch-1';
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

الفرق عن المقاربات السابقة واضح. حتى الآن كان "الذكاء الاصطناعي يلخّص فيديو YouTube" يعني غالبا قراءة العنوان والوصف ونص الترجمة فقط ثم التخمين. لا يخمّن claude-video من العنوان. يرى الإطارات الفعلية كصور ويقرأ الترجمات أو النص إلى جانبها، جامعا بين البصر والسمع. أسئلة مثل ماذا يظهر على الشاشة، أو متى بالضبط تنكسر الواجهة، لا يمكن الإجابة عنها من نص الترجمة وحده؛ يجب رؤية الإطارات.

## التثبيت والاستخدام

يسير التثبيت في مسارين. يربطه مستخدمو Claude Code عبر سوق الإضافات.

```bash
# Claude Code: سجّل السوق ثم ثبّت مهارة watch
/plugin marketplace add bradautomates/claude-video
/plugin install watch@claude-video
```

على نحو خمسين مضيف وكيل بما فيها Cursor وCopilot وGemini CLI، ثبّته عالميا وفق مواصفة Agent Skills.

```bash
# مواصفة Agent Skills (مشتركة عبر نحو 50 مضيفا)
npx skills add bradautomates/claude-video -g
```

لا حاجة لأي إعداد إضافي للبدء. إن غاب `yt-dlp` و`ffmpeg` فسيثبّتان تلقائيا عبر brew عند أول تشغيل على macOS، وعلى Linux وWindows تُطبع أوامر التثبيت الدقيقة. مفتاح واجهة Whisper ليس مطلوبا دائما؛ إنه ضروري فقط حين لا يملك الفيديو أي ترجمات. كثير من الفيديوهات العامة تأتي مع ترجمات وتُعالج على المسار المجاني.

الاستخدام سطر أمر واحد.

```bash
# اطرح سؤالا عن ملف محلي
/watch tutorial.mp4 "ما اللغة المستخدمة في هذا الدرس؟"

# ركّز على مقطع محدد من فيديو YouTube
/watch https://youtu.be/VIDEO "ماذا يحدث قرب 2:30؟" --start 2:00 --end 3:00
```

`--start` و`--end` مهمان. تمزيق فيديو طويل بأكمله إلى إطارات يفجّر السياق والتكلفة. تضييق النطاق ينزّل ذلك الجزء فقط ويستخرج منه الإطارات، موفّرا الرموز. عمليا، الحركة القياسية هي تضييق النطاق، مثل "مقطع العرض ذي الاثنتي عشرة دقيقة فقط من تسجيل اجتماع مدته 45 دقيقة".

## الآلية الداخلية: الترجمات أولا، استخراج الإطارات، إزالة التكرار، التفريغ

سبب كون claude-video مثيرا للاهتمام هو أن حكما عمليا مطبوع في طريقة وصل القطع. لنمرّ على التصميم الموثّق خطوة بخطوة. الأرقام والمعاملات أدناه هي قيم التصميم التي نشرها المشروع، وليست قياسات أجريتها في هذه البيئة.

أولا، التفريغ يبدأ بالترجمات. يتحقق yt-dlp من وجود ترجمات أولا، وإن وُجدت استخدمها مباشرة كنص مصحوب بطوابع زمنية دون تنزيل جسم الفيديو. الأمر فوري ومجاني. وفقط عند غياب الترجمات يستخرج صوتا أحاديا بتردد 16kHz ويسلّمه إلى Whisper. هنا، مراعاة للسرعة والتكلفة، يفضّل whisper-large-v3 من Groq ويرتد إلى whisper-1 من OpenAI إن لم يتوفر.

ثانيا، يقدّم استخراج الإطارات ثلاثة مستويات تفصيل. يفكّ `efficient` الإطارات المفتاحية فقط وينتهي فوريا تقريبا. يفضّل `balanced` إطارات تغيّر المشهد لكنه يكمّل بأخذ عينات منتظم مراع للمدة حين تقل. يشغّل `token-burner` كشف المشاهد دون سقف لسحب أقصى دقة، محرقا الرموز بالمقابل. تختار "التصفّح السريع أم النظر بدقة" حسب الغرض.

ثالثا، إزالة التكرار هي درّة هذا المشروع الصغيرة. يُصغَّر كل إطار مستخرج إلى صورة مصغّرة رمادية 16x16، ويُحسب متوسط الفرق المطلق ليس مقابل الإطار السابق مباشرة بل مقابل **آخر إطار محفوظ**. إن كانت تلك القيمة عند العتبة 2.0 أو أدنى، يُسقَط الإطار. سبب المقارنة مع آخر إطار محفوظ بدلا من السابق هو المفتاح. المقارنة إطارا بإطار تُبقي التلاشي البطيء جدا يمر بوصفه "بالكاد تغيّر"، لكن المقارنة مع آخر إطار محفوظ تلتقط لحظة تجاوز التغيّر التراكمي للعتبة. إنه تصميم مفيد فعلا في أمور مثل الفيديوهات التعليمية حيث تتقدم الشرائح ببطء.

رابعا، التجميع النهائي. تُحاذى صور الإطارات والنص زمنيا، فتدخل الإطارات سياق Claude كصور والنص كنص مصحوب بأوقات. يقرأ Claude "في هذه اللحظة تُظهر الشاشة كذا، وقيل كذا حينها" معا ويجيب.

## ما تحققت منه: سلوك موثّق وملاحظة إعادة إنتاج

بصراحة. بيئة تأليف هذا المقال تمنع تنزيل الفيديو الخارجي، لذا لم أستطع تشغيل قياس مباشر يثبّت claude-video ويمزّق فيديو YouTube حقيقيا إلى إطارات. لذلك لا أختلق أي أرقام زمن استجابة أو دقة. بدلا من ذلك أعرض تصميم المشروع المنشور وسلوكه بأمانة وأترك نقاط تحقق قابلة لإعادة الإنتاج.

ما يتأكد باستمرار عبر الوثائق وتقارير المستخدمين المتعددة هو التالي. تُفرّغ الفيديوهات العامة ذات الترجمات مجانا دون تنزيل. للإطارات ثلاثة مستويات تفصيل، efficient وbalanced وtoken-burner، يختلف كل منها في السرعة والدقة. تستخدم إزالة التكرار مقارنة رمادية 16x16 بعتبة 2.0. مسار بديل التفريغ هو Groq whisper-large-v3 ثم OpenAI whisper-1. يقدّم التفرّع `mathiaschu/watch` نسخة تستبدل خطوة التفريغ بـ `mlx-whisper` محليا، فتعمل بالكامل على الجهاز دون مفتاح واجهة.

للتحقق مباشرة، أنصح بهذا. اقطع فيديو عاما قصيرا يملك ترجمات إلى مقطع دون دقيقة بـ `--start`/`--end`، وألقه إلى `/watch`، وشغّله بتفصيل efficient ثم token-burner، مقارنا عدد الإطارات ورموز الاستجابة. تُظهر هذه المقارنة بأوضح شكل أثر "تضييق النطاق مع اختيار التفصيل" على التكلفة. بدلا من الاستشهاد بأرقام دون قياس، فإن قياس هذين المحورين في بيئتك أدق.

## تبعات على منتجات ThakiCloud

ينسجم claude-video طبيعيا مع المحورين اللذين تدفع بهما ThakiCloud.

أولا، **عدسة Paxis**. Paxis هو مستوى التحكم للسحابة الأصيلة للوكلاء في ThakiCloud، ويعامل Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. ما يبرهنه claude-video هو تماما بنية "إطار رقيق، مهارة سميكة" التي يهدف إليها Paxis. دون تدريب نموذج جديد، يربط أدوات مُثبتة (yt-dlp وffmpeg وWhisper) عبر إطار مهارات ليضيف حاسة جديدة إلى الوكيل. يختار Skill Harness في Paxis من أكثر من 960 مهارة عبر BM25 ويشغّلها في بيئة معزولة، ومهارة متعددة الوسائط مثل claude-video مرشحة للجلوس مباشرة على هذا الإطار. وبخاصة أن تنزيل الفيديو وتشغيل ffmpeg يتعاملان مع روابط وثنائيات عشوائية، فإن التشغيل المعزول في Paxis وبوابة السياسات مع سجلات التدقيق تؤتي ثمارها مباشرة. حين يُسجّل في سجل التدقيق أي فيديو عُولج، وإلى أي نطاق، وبأي تفصيل، يمكن التحكم في التكلفة والوصول إلى البيانات معا.

ثانيا، **عدسة ai-platform**. يعتمد مسار تفريغ claude-video أساسا على واجهات خارجية (Groq وOpenAI). للعملاء ذوي متطلبات محلية أو سيادية، ذلك الجزء خطر كما هو. هنا يقدّم ai-platform في ThakiCloud الجواب. إن خدمت STT من فئة Whisper داخليا على K8s مع جدولة GPU بواسطة Kueue، أمكنك إنهاء تفريغ الفيديو داخل شبكة مغلقة دون إرساله للخارج. إنه الاتجاه ذاته الذي سلكه التفرّع باختيار mlx-whisper للتفريغ المحلي، منفَّذا على نطاق مؤسسي. خط أنابيب يفرّغ كميات كبيرة من تسجيلات الاجتماعات بلا ترجمات دفعيا على عنقود GPU داخلي، مع استهلاك الوكلاء للنتائج، هو حالة استخدام نموذجية لـ ai-platform الذي تكمن قوته في الخدمة متعددة المستأجرين وكفاءة التكلفة.

تكمّل العدستان إحداهما الأخرى. حين يدعم ai-platform التفريغ ومعالجة الإطارات منخفضة التكلفة داخل شبكة مغلقة، ينسّق Paxis المهارات متعددة الوسائط فوقها بالسياسات والتدقيق. بنية "البنية التحتية الرخيصة تجعل حاسة الوكيل الجديدة اقتصادية" تصح هنا أيضا.

## القيود والاعتراضات

بضعة أمور يجب قولها بوضوح.

أولا، تكلفة الرموز. لحظة دخول الإطارات السياق كصور، تتراكم الرموز بسرعة. تشغيل فيديو طويل بأكمله في وضع token-burner قد يكبّد تكلفة كبيرة لكل سؤال. انضباط التضييق بـ `--start`/`--end` والبدء بتفصيل efficient ضروري. الاستخدام المتهور طلبا للراحة يجعل الفاتورة تستجيب أولا.

ثانيا، إزالة التكرار ليست حلا سحريا. الرمادي 16x16 بعتبة 2.0 يناسب الفيديوهات ذات التغيّر المنفصل مثل الشرائح والعروض، لكن على لقطات محمولة باليد باهتزاز كاميرا مستمر أو شاشات تهم فيها تغيّرات نصية دقيقة، قد يفوّت أو يبقي أكثر من اللازم. العتبة مرشحة للضبط حسب طبيعة الفيديو.

ثالثا، ثقة المصدر والمسائل القانونية. تنزيل الفيديوهات من مواقع عشوائية بـ yt-dlp قد يتعارض مع شروط الخدمة المستهدفة وحقوق النشر. عند إدخاله في خط أنابيب مؤسسي، يجب تثبيت المصادر المسموح بها بالسياسة، وهذا بالضبط سبب الحاجة إلى بوابة سياسات مثل Paxis.

رابعا، الاعتماد على واجهات خارجية. إن خرج تفريغ الفيديوهات بلا ترجمات إلى Groq أو OpenAI، تغادر البيانات المنشأة. لتسجيلات الاجتماعات الداخلية الحساسة، ذلك انكشاف كما هو ما لم تبدّل المسار إلى خدمة Whisper الداخلية المذكورة أعلاه.

ومع ذلك، تبقى الصورة الكبرى صحيحة. كسر claude-video فرضية أن "وكلاء البرمجة تقرأ النص فقط" بطريقة رقيقة وعملية. مقاربة توسيع حاسة عبر تركيبة من أدوات مُثبتة بدلا من نموذج جديد هي نمط يستحق الرجوع إليه باستمرار من منظور تصميم منصات الوكلاء.

## المصادر

- [bradautomates/claude-video (GitHub)](https://github.com/bradautomates/claude-video)
- [claude-video/README.md (GitHub)](https://github.com/bradautomates/claude-video/blob/main/README.md)
- [mathiaschu/watch، تفرّع التفريغ المحلي بـ mlx-whisper (GitHub)](https://github.com/mathiaschu/watch)
- [claude-video: Let Claude Watch Videos with /watch (knightli.com)](https://knightli.com/en/2026/07/08/claude-video-watch-video-transcript-frames-skill/)
- [Claude Video: The Open-Source Tool That Lets AI Coding Agents Watch and Analyze Any Video (CoddyKit)](https://www.coddykit.com/pages/blog-detail?id=512902&slug=claude-video-the-open-source-tool-that-lets-ai-coding-agents-watch-and-analyze-a)
