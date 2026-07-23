---
title: "‏295B على بطاقة واحدة: تشريح خدمة Hunyuan Hy3 بدقة 1-bit و4-bit"
excerpt: "تُقلّص نسخ Hy3 من Tencent بصيغة GGUF بدقة 1-bit و4-bit نموذج MoE بحجم 295B من 598GB إلى 85.5GiB ليعمل على وحدة معالجة رسومات واحدة. لكن المقصود بـ«وحدة واحدة» هنا جهاز بذاكرة موحّدة من فئة 128GB، لا بطاقة استهلاكية بسعة 16GB. نتناول ما تكسبه هذه الضغطة وما تخفيه، ولماذا يُذكر MTP إلى جانبها، وماذا تعني خدمة نموذج رائد من عقدة واحدة لاستراتيجية الاستدلال المحلي في ThakiCloud."
tags:
  - quantization
  - hunyuan-hy3
  - moe
  - 1-bit
  - 4-bit
  - gguf
  - llama-cpp
  - mtp
  - inference
  - serving
  - on-prem
  - self-hosting
  - llmops
  - ai-platform
date: 2026-07-17
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/hunyuan-hy3-1bit-4bit-single-gpu/"
categories:
  - llmops
---

## نظرة عامة

أول جدار يصطدم به أي فريق عند خدمة نموذج كبير على بنيته التحتية الخاصة ليس الحوسبة بل الذاكرة. يتطلّب تحميل نموذج بحجم 295B بدقة FP16 نحو 598GB من الأوزان مقيمة في ذاكرة وحدة المعالجة الرسومية، وهو حجم يكاد لا يتّسع إلا عبر ثماني بطاقات H100 بسعة 80GB. لهذا ظلّت النماذج الرائدة مفتوحة الأوزان في موضع محرج: مُعلنة، لكن يصعب علينا خدمتها فعلياً.

تستهدف نسخ Hy3 بصيغة GGUF بدقة 1-bit و4-bit التي أصدرتها Tencent Hunyuan في 14 يوليو 2026 هذه النقطة مباشرةً. فهي تضغط نموذج MoE بحجم 295B إلى صيغة منخفضة البتّات ليعمل على بطاقة واحدة، وتُنشر الأوزان برخصة Apache 2.0. عرّفت Tencent النموذج على منصة X بأنه «نموذج بحجم رائد 295B يمكن خدمته على وحدة معالجة رسومية واحدة»، مع ذكر llama.cpp وMTP معاً.

تقرأ هذه المقالة نسخ Hy3 المكمّمة من منظور ThakiCloud بوصفنا فريقاً يخدم نماذج منخفضة البتّات في بيئة متعددة المستأجرين. نستعرض ما تغيّره الضغطة فعلياً، ولماذا يجب قراءة عبارة «وحدة واحدة» بحذر، وماذا يعني هذا الاتجاه لبنية الاستدلال المحلية لدينا. ولنكن واضحين منذ البداية: كل أرقام الحجم والأداء أدناه قيَم أبلغت عنها Tencent والمجتمع، وليست أرقاماً أعادت ThakiCloud إنتاجها.

## ما هذه التقنية

‏Hy3 نموذج Mixture-of-Experts بإجمالي 295B معامل، لكن ما يُفعَّل لمعالجة رمز واحد نحو 21B فقط. يدعم سياقاً طويلاً بحجم 256K رمز، ويستهدف المهام الوكيلة والبرمجة واستدعاء الأدوات. الجديد هنا ليس نموذجاً جديداً بل تمثيلاً منخفض البتّات بصيغة GGUF لأوزان Hy3 القائمة. صدرت نسختان.

تُقلّص نسخة 1-bit النموذج من نحو 598GB إلى 85.5GiB. بهذا الحجم تتّسع الأوزان على بطاقة واحدة من فئة 96GB. تشغل نسخة 4-bit مساحة 169.9GiB وتحتاج إلى الامتداد عبر بطاقتين، لكنها بالمقابل تحافظ على جودة أقرب بكثير إلى الأصل وفق ما أُبلغ. تعمل النسختان مع llama.cpp، وصُمِّمتا لتفعيل MTP (التنبؤ متعدد الرموز) لرفع إنتاجية توليد الرموز.

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
<div class="d3-arch" data-arch-root id="yuanhy31bit4bitsinglegpu-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 373, "height": 994, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 113, "y": 24, "w": 128, "h": 62, "title": ["Hy3 295B MoE", "FP16 نحو 598GB"]}, {"id": "B", "x": 69, "y": 164, "w": 216, "h": 52, "title": "تكميم GGUF منخفض البتّات"}, {"id": "C", "x": 199, "y": 308, "w": 142, "h": 62, "title": ["85.5GiB", "بطاقة 96GB واحدة"]}, {"id": "D", "x": 24, "y": 308, "w": 120, "h": 62, "title": ["169.9GiB", "بطاقتان"]}, {"id": "E", "x": 89, "y": 448, "w": 177, "h": 46, "title": "التشغيل عبر llama.cpp"}, {"id": "F", "x": 78, "y": 572, "w": 198, "h": 78, "title": ["تفعيل MTP", "تنبؤ متعدد الرموز لزيادة", "الإنتاجية"]}, {"id": "G", "x": 71, "y": 728, "w": 212, "h": 78, "title": ["‏21B معامل مُفعَّل", "بعض الخبراء فقط يحسبون لكل", "رمز"]}, {"id": "H", "x": 71, "y": 884, "w": 212, "h": 78, "title": ["مهام وكيلة وبرمجة واستدعاء", "أدوات", "سياق طويل 256K"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [177, 86, 177, 164]}, {"src": "B", "dst": "C", "kind": "data", "label": "1-bit", "curve": [[211, 216], [270, 262], [270, 262], [270, 308]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "4-bit", "curve": [[143, 216], [84, 262], [84, 262], [84, 308]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "curve": [[270, 370], [270, 409], [270, 409], [212, 448]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[84, 370], [84, 409], [84, 409], [143, 448]]}, {"src": "E", "dst": "F", "kind": "data", "line": [177, 494, 177, 572]}, {"src": "F", "dst": "G", "kind": "data", "line": [177, 650, 177, 728]}, {"src": "G", "dst": "H", "kind": "data", "line": [177, 806, 177, 884]}]});
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
      const container = document.getElementById('yuanhy31bit4bitsinglegpu-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'yuanhy31bit4bitsinglegpu-1';
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

بنية MoE هي ما يجعل هذه الضغطة جذّابة بوجه خاص. فمن أصل 295B، لا يشارك في الحساب لكل رمز سوى خبراء بحجم 21B، لذا فالحوسبة نفسها في حدود نموذج كثيف بحجم 21B. يكمن عنق الزجاجة كلياً في «أين تُقيم كل أوزان الخبراء». والضغط منخفض البتّات يهاجم تحديداً تكلفة الإقامة تلك.

## لماذا تحتاج عبارة «وحدة واحدة» إلى قراءة متأنية

هذه أسهل عبارة يُساء فهمها في التسويق. «الخدمة على وحدة واحدة» صحيحة، لكن المقصود بالوحدة هنا جهاز بذاكرة موحّدة من فئة 128GB. فكّر في DGX Spark، أو Mac Studio بسعة 128GB، أو Strix Halo. إن تخيّلت بطاقة RTX 3060 واحدة بسعة 16GB، فهذا التوقع بعيد.

يهمّ هذا التمييز لأن الحساب العملي يتغيّر كلياً. يتطلّب تحميل 85.5GiB من الأوزان بطاقة سعتها 96GB على الأقل، وبمجرد إضافة ذاكرة KV cache وذاكرة التنشيط وحالة الانتباه لسياق طويل، يتقلّص الهامش الفعلي أكثر. حتى على جهاز من فئة 128GB يكون العبء ضيّقاً مع عبء عمل يملأ سياق 256K فعلاً. «بطاقة واحدة» تشير إلى عدد المنافذ الفيزيائية، لا إلى عتاد رخيص.

ومع ذلك، فهذا الإصدار مهم لأن مرجع المقارنة عقدة H100 من ثماني بطاقات. فإذا استُبدلت العقدة متعددة البطاقات التي كانت خدمة FP16 تتطلّبها ببطاقة واحدة عالية السعة، تنخفض الطاقة والمساحة وتعقيد الربط البيني بشكل حادّ. لا تنخفض التكلفة المطلقة بقدر ما يصبح شكل النظام المطلوب أبسط جوهرياً.

## ‏1-bit مقابل 4-bit: ماذا تكسب وماذا تخسر

تمثّل النسختان خيارين مختلفين. نسخة 1-bit مُحسّنة لدفع النموذج إلى أقل عتاد ممكن. حجم 85.5GiB نتيجة ضغط شديد، وتقبل في المقابل خسارة جودة مقابل الأصل. أما نسخة 4-bit فتطلب ضعف الذاكرة تقريباً عند 169.9GiB، لكن تقارير المجتمع تقول إنها تحافظ على أداء قريب من الأصل.

هنا تبرز قاعدة قرار عملية. في مهام الوكلاء حيث تتراكم استدعاءات الأدوات وسلاسل الاستدلال الطويلة، تتراكم تراجعات الجودة الصغيرة وتميل إلى إفساد النتيجة النهائية. تبدو الأسئلة القصيرة سليمة حتى مع 1-bit، لكن في العمل الوكيل المتعدد الخطوات يعمل هامش 4-bit الإضافي كحاجز أمان. إن سمحت ميزانية العتاد، فتفضيل 4-bit لخدمة الوكلاء هو الخيار الافتراضي المعقول.

يندرج ذكر MTP في هذا السياق أيضاً. فالتنبؤ متعدد الرموز يقترح ويتحقّق من عدة رموز من تمريرة أمامية واحدة، ما يرفع إنتاجية مرحلة فك التشفير المقيّدة بعرض نطاق الذاكرة. ولأن النماذج منخفضة البتّات أوزانها أصغر، فهي تحرّر هامشاً نسبياً من عرض نطاق الذاكرة يتناسب جيداً مع تقنيات الإنتاجية مثل MTP.

## منظور التثبيت والخدمة

بما أنها ملفات GGUF قائمة على llama.cpp، فمسار الخدمة نفسه مألوف. تجلب ملف GGUF، وتحمّله عبر llama.cpp، وتفعّل خيار MTP، ثم تعرضه كخادم متوافق مع OpenAI. من الناحية المفاهيمية تبدو البنية هكذا.

```bash
# تحميل نسخة 1-bit GGUF (مثال مفاهيمي، راجع مستودع الإصدار لأسماء الملفات والرايات الدقيقة)
./llama-server \
  --model hy3-295b-1bit.gguf \
  --ctx-size 262144 \
  --n-gpu-layers 999 \
  --draft-max 4          # تنبؤ متعدد الرموز على طراز MTP
```

إن أردت إعطاء الأولوية للإنتاجية عند FP8 أو دقة أعلى بدلاً من ذلك، فقد وثّق المجتمع أيضاً مساراً يخدم عبر بطاقات متعددة باستخدام vLLM أو SGLang مع Expert Parallelism. يستهدف مسار GGUF منخفض البتّات الخدمة من عقدة واحدة على أقل عتاد، بينما يستهدف مسار vLLM الإنتاجية وعدد المستخدمين المتزامنين.

لم ننزّل فعلياً نسخة 85.5GiB ولم نشغّل الاستدلال لأجل هذه المقالة. فمتطلّب العتاد بذاكرة موحّدة 96GB أو أكثر يقع خارج نطاق بيئة هذا التصريف. وعليه فالأرقام أعلاه كلها قيَم أبلغت عنها Tencent والمجتمع، ونذكر بصدق غياب إعادة الإنتاج. على أي جهة تقيّم التبنّي أن تدرج خطوة للتحقق من الجودة والإنتاجية بقياساتها الخاصة على العتاد المستهدف.

## دلالات لمنتجات ThakiCloud

يهمّ هذا الإصدار خصوصاً من منظور **ai-platform** لدى ThakiCloud. تجدول ai-platform وحدات المعالجة الرسومية عبر K8s وKueue وتخدم النماذج عبر بيئات عملاء متنوعة بالاعتماد على vLLM. تشغيل نموذج بحجم رائد على عقدة واحدة عالية السعة يعني أن وحدة توزيع العقد للخدمة متعددة المستأجرين تصبح أبسط. فبدلاً من جدولة مبنية على عقد H100 من ثماني بطاقات، تصبح معالجة بطاقة واحدة من فئة 128GB كوحدة خدمة واحدة تجعل إدارة الطوابير وتوزيع الأولويات في Kueue أكثر قابلية للتنبؤ.

في سياق الاستضافة المحلية والذكاء الاصطناعي السيادي، يكون هذا الاتجاه أكثر مباشرةً. فالعملاء الذين لا يمكنهم إرسال بياناتهم المحلية إلى الخارج مضطرون لتشغيل النماذج على عتادهم الخاص، وعقدة بثماني بطاقات حاجز مرتفع في التوريد والمساحة والطاقة. فإذا أمكن خدمة نموذج رائد على جهاز واحد من فئة 128GB، تنخفض عتبة العتاد للنشر السيادي بوضوح. مع ذلك، فإن التحقق مما إذا كانت خسارة الجودة منخفضة البتّات مقبولة لعبء عمل العميل مسؤولية يجب أن نتحمّلها.

من منظور أعباء عمل الوكلاء، يتّصل هذا بـ **Paxis** أيضاً. Paxis هي Agent-Native Cloud التي تعمل فوق ai-platform، تنفّذ المهارات في بيئات معزولة وتمرّر كل إجراء عبر بوّابات السياسات وسجلات التدقيق. فإذا أمكن خدمة نموذج متخصص في الوكلاء واستدعاء الأدوات مثل Hy3 بتكلفة عتاد منخفضة، تنخفض تكلفة التشغيل لكل وكيل، وهذا بدوره يعني إمكانية تشغيل مزيد من التدفقات المستقلة اقتصادياً. الخدمة منخفضة التكلفة هي البنية التي تصنع اقتصاديات الوكلاء.

## القيود والاعتراضات

أكبر اعتراض هو حقيقة «الوحدة الواحدة». فجهاز بذاكرة موحّدة من فئة 96GB إلى 128GB لا يزال باهظاً وليس عتاداً سائداً بحق. قراءة هذا الإصدار على أنه «يمكن للجميع الآن تشغيل 295B على حاسوب محمول» سوء فهم. الأدقّ هو أن «عبء عمل كان يتطلّب عقدة متعددة البطاقات نزل إلى بطاقة واحدة عالية السعة».

ثانياً، قد تكون خسارة جودة نسخة 1-bit قاتلة حسب عبء العمل. تقول ملخّصات القياس «قريب من الأصل»، لكن هذا يُقاس عادةً مقابل 4-bit أو على تقييمات تغلب عليها المهام القصيرة. أما كيف تصمد 1-bit تحت سلاسل استدلال طويلة واستدعاءات أدوات دقيقة متكرّرة في المهام الوكيلة فلا يتأكّد إلا على أعباء العمل الحقيقية.

ثالثاً، لم تُتحقّق هذه الأرقام بعد على نطاق واسع وبشكل مستقل. فهي تعتمد على تقارير من Tencent والمجتمع المبكر، وإلى أن تتراكم نتائج إعادة الإنتاج عبر عتاد ومهام متنوعة، يبقى التعامل معها بحذر الموقف الأكثر أماناً. ونحن أيضاً سنستخدم الأرقام المنشورة نقطة انطلاق فقط عند تقييم التبنّي، ونتّخذ قياساتنا الخاصة على البيئة المستهدفة مرجعاً.

ومع ذلك، فالاتجاه نفسه واضح. انتقال وحدة الخدمة للنماذج الرائدة مفتوحة الأوزان من عقدة متعددة البطاقات إلى بطاقة واحدة عالية السعة إشارة مرحّب بها لأي بنية تحتية تتعامل مع الاستضافة المحلية والذكاء الاصطناعي السيادي.

## المصادر

- [Tencent Hunyuan، إصدار Hy3 بدقة 1-bit و4-bit (X)](https://x.com/TencentHunyuan/status/2076953120765280284)
- [tencent/Hy3 (Hugging Face)](https://huggingface.co/tencent/Hy3)
- [Tencent Hy3 GGUF 1-bit 4-bit Single GPU (explainX)](https://explainx.ai/blog/tencent-hy3-gguf-1-bit-4-bit-single-gpu-llama-cpp-july-2026)
- [تحليل إصدار Hunyuan Hy3 المكمّم (Remio)](https://www.remio.ai/post/tencent-hunyuan-hy3-quantized-release-1bit-single-card-deployment-4bit-near-full-performance)
- [نشر Hunyuan Hy3 عبر vLLM وExpert Parallelism (Spheron)](https://www.spheron.network/blog/deploy-hunyuan-3-gpu-cloud/)
