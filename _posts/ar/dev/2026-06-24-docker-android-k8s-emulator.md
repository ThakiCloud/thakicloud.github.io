---
layout: post
title: "محاكيات أندرويد داخل حاويات - بناء مزرعة أجهزة قابلة للتكرار على Kubernetes باستخدام docker-android"
excerpt: "يُغلّف docker-android محاكي أندرويد في حاوية واحدة ويُشغّله بلا واجهة رسومية. نتحقق من أحجام الصور ومتطلبات KVM وفق التوثيق الرسمي، ونستعرض كيفية تشغيل أحمال عمل مرور الأجهزة على منصة ThakiCloud Kubernetes."
seo_title: "docker-android K8s Emulator - مزرعة أجهزة أندرويد في حاويات - Thaki Cloud"
seo_description: "كيفية تشغيل محاكي أندرويد كحاوية بلا واجهة رسومية باستخدام docker-android. دليل عملي لـ KVM passthrough وتسريع GPU والتحكم عن بُعد عبر scrcpy وأتمتة اختبارات CI/CD على Kubernetes."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - docker
  - android
  - kubernetes
  - kvm
  - ci-cd
lang: ar
dir: rtl
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/dev/docker-android-k8s-emulator/"
reading_time: true
categories:
  - dev
---

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
<div class="d3-arch" data-arch-root id="dockerandroidk8semulator-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 394, "height": 582, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 60, "y": 24, "w": 287, "h": 278, "label": "عقدة K8s مع KVM / Pod", "lx": 72, "ly": 42}], "nodes": [{"id": "EMU", "x": 98, "y": 201, "w": 212, "h": 62, "title": ["محاكي Android (QEMU + KVM،", "اختياري CUDA)"]}, {"id": "KVM", "x": 144, "y": 63, "w": 120, "h": 46, "title": "/dev/kvm"}, {"id": "SVC", "x": 144, "y": 380, "w": 120, "h": 46, "title": "خدمة ADB"}, {"id": "CI", "x": 242, "y": 504, "w": 120, "h": 46, "title": "مزرعة CI"}, {"id": "SCRCPY", "x": 24, "y": 504, "w": 163, "h": 46, "title": "تحكم scrcpy عن بُعد"}], "edges": [{"src": "KVM", "dst": "EMU", "kind": "data", "label": "passthrough", "line": [204, 109, 204, 201], "lx": 204, "ly": 151}, {"src": "EMU", "dst": "SVC", "kind": "data", "line": [204, 263, 204, 380]}, {"src": "SVC", "dst": "CI", "kind": "data", "curve": [[240, 426], [302, 465], [302, 465], [302, 504]]}, {"src": "SVC", "dst": "SCRCPY", "kind": "data", "curve": [[167, 426], [106, 465], [106, 465], [106, 504]]}]});
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
      const container = document.getElementById('dockerandroidk8semulator-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'dockerandroidk8semulator-1';
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
## نظرة عامة

اختبار تطبيق موبايل يستلزم أجهزة أندرويد. إدارة أسطول من الأجهزة الحقيقية عبء صيانة مُضنٍ، وتثبيت محاكٍ ثقيل على كل جهاز مطوّر يُفضي إلى اختلاف البيئات وضعف قابلية التكرار. تتضاعف هذه المشكلة حين تُريد إدراج اختبارات أندرويد في خط CI، إذ يحتاج كل عقدة بناء إلى إعداد محاكٍ متسق.

يحل `docker-android` (إصدار HQarroum) هذه المشكلة بالحاويات. يُغلّف محاكي أندرويد بتهيئة بسيطة، ويُشغّله بلا واجهة رسومية، ويُتيح ADB والتحكم بالشاشة عبر الشبكة. حاوية واحدة توفر بيئة أندرويد نظيفة ومتسقة في ثوانٍ، مما يجعلها مناسبة تماماً لـ CI/CD والاختبارات الآلية.

يتحقق هذا المقال من بنية docker-android ومتطلباته الفعلية وفق التوثيق، ثم يستعرض كيف تتعامل منصة Kubernetes مثل ThakiCloud مع هذا النوع من أحمال عمل الأجهزة. محاكاة أندرويد ليست في صميم منصتنا للذكاء الاصطناعي، لكن السؤال حول عزل الحاويات ذات الامتيازات التي تحتاج KVM passthrough وتسريع GPU يتقاطع مباشرة مع قدرات بنيتنا التحتية.

---

## ما هو docker-android

يجمع docker-android الخاص بـ HQarroum بين محاكي أندرويد ودعم KVM و JRE 11 في صورة مدمجة مبنية على Alpine (الإصدار الحالي 1.1.0). النية التصميمية واضحة: كشف محاكي أندرويد كامل يمكن التحكم به عن بُعد بأقل بصمة برمجية ممكنة. تحتوي الصورة على المحاكي نفسه، وخادم ADB للوصول الخارجي، وQEMU مع libvirt.

الخصائص الرئيسية:

- **بصمة بسيطة**: مبنية على Alpine لتحسين الحجم. البناء بدون SDK أو محاكٍ ينتج صورة أصغر بكثير.
- **قابلية التخصيص**: إصدار أندرويد ونوع الجهاز ونوع الصورة كلها قابلة للاختيار.
- **توجيه المنافذ مدمج**: يُكشف المحاكي و ADB عبر واجهة شبكة الحاوية.
- **بلا واجهة رسومية**: لا تحتاج إلى GUI، مما يجعلها مناسبة لمزارع CI. يمكن الوصول إلى الشاشة عن بُعد عبر [scrcpy](https://github.com/Genymobile/scrcpy).
- **قابلية التكرار**: تُعاد صورة المحاكي إلى حالتها الأصلية عند كل إعادة تشغيل، فكل تشغيل يبدأ من حالة متطابقة.

يُوضح الرسم البياني أعلاه نشراً افتراضياً لهذه الحاوية على ThakiCloud Kubernetes. يعمل المحاكي في pod على عقدة مُفعَّل فيها KVM مع تمرير `/dev/kvm`، ويُستخدم المتغير cuda حين يُحتاج تسريع GPU. يُكشف ADB كـ Service ليصل إليه مزرعة CI و scrcpy.

---

## التثبيت والتكامل

يجمع البناء الافتراضي Android SDK وأدوات المنصة والمحاكي في الصورة. تشغيل كل شيء باستخدام docker-compose:

```bash
# المحاكي الأساسي
docker compose up android-emulator

# تسريع GPU
docker compose up android-emulator-cuda

# تسريع GPU + Google Play Store
docker compose up android-emulator-cuda-store
```

يمكن البناء مباشرة باستخدام Docker:

```bash
docker build -t android-emulator .
```

بعد بناء الصورة، شغّل الحاوية مع تثبيت محرك KVM. استخدام صورة Play Store يستلزم مشاركة المحاكي والعميل لنفس `adbkey`؛ أنشئه بـ `adb keygen adbkey` وضعه في مجلد `./keys`.

يتباين حجم الصورة تبايناً كبيراً حسب متغير البناء. جدول المقارنة من توثيق المستودع:

| متغير البناء | غير مضغوط | مضغوط |
|---|---|---|
| API 33 + المحاكي | 5.84 GB | 1.97 GB |
| API 32 + المحاكي | 5.89 GB | 1.93 GB |
| API 28 + المحاكي | 4.29 GB | 1.46 GB |
| بدون SDK أو محاكٍ | 414 MB | 138 MB |

الصور التي تتضمن المحاكي تتجاوز 1.5 GB حتى بعد الضغط. عند التوزيع على عقد كثيرة، يجب مراعاة عرض نطاق السجل وسعة قرص العقد.

---

## التحقق من السلوك الفعلي

لم يشمل هذا المقال التحقق من إقلاع الحاوية فعلياً. تسجيل أمين: فشل التحقق هنا (لا يوجد Docker daemon على المضيف، وmacOS لا يوفر `/dev/kvm`). يتطلب docker-android تسريع KVM للأجهزة، لذا التشغيل الفعلي ممكن فقط على مضيف Linux أو عقدة KVM تدعم المحاكاة الافتراضية المتداخلة.

ما أمكن التحقق منه استُقي مباشرة من توثيق المستودع. جدول مقارنة أحجام الصور أعلاه يعكس أرقاماً مُصرَّحاً بها في التوثيق؛ متغيرات البناء وأسماء خدمات compose ومتطلبات تثبيت KVM كلها مستندة إلى التوثيق. أرقام كوقت الإقلاع أو معدل معالجة الاختبارات التي لم نقسها لم نُدرجها. عند النشر الفعلي، بعد توفير عقد KVM، الإجراء الصحيح هو قياس وقت إقلاع الحاوية وزمن استجابة ADB والحد الأقصى لعدد المحاكيات المتزامنة مباشرة.

---

## الآثار على منصة ThakiCloud K8s AI/ML SaaS

docker-android ليس أداة ذكاء اصطناعي في حد ذاتها. لكن المتطلبات التشغيلية التي يكشف عنها تتقاطع بدقة مع ما تُتقنه ThakiCloud.

أولاً، **عزل أحمال عمل مرور الأجهزة**. المحاكي حاوية ذات امتيازات في جوهرها تتطلب `/dev/kvm`. تشغيل هذا النوع من أحمال العمل بأمان في بيئة Kubernetes متعددة المستأجرين يستلزم اختيار العقد بعناية والمكوّنات الإضافية للأجهزة وسياقات الأمان. تُجهّز ThakiCloud بالفعل وحدات GPU عبر مكوّنات الأجهزة الإضافية وKueue؛ يمكن التعامل مع KVM passthrough بالنمط ذاته.

ثانياً، **مزارع الاختبار القابلة للتكرار**. تغليف المحاكيات عديمة الواجهة الرسومية كحاويات يتيح توسيع البيئات النظيفة أفقياً عبر عدد العقد المطلوب. تشغيل اختبارات Appium UI متوازية كثيرة من خط CI/CD حالة استخدام نموذجية لجدولة وظائف Kubernetes.

ثالثاً، ونظرة إلى الأمد البعيد، يمتد هذا بشكل طبيعي نحو **التحقق من أداء الذكاء الاصطناعي على الجهاز**. التحقق من سلوك النماذج الخفيفة أو العوامل العاملة على أجهزة الموبايل على نطاق واسع يتطلب مزرعة أجهزة تنشئ بيئات أندرويد معزولة كثيرة وتُشغّل اختبارات الانحدار آلياً. هذا ليس اهتماماً محورياً لمنصتنا اليوم، لكن مع نضج قدرات تنظيم GPU والأجهزة متعددة المستأجرين لدينا، تغدو مزرعة QA للذكاء الاصطناعي على الموبايل من هذا النوع شيئاً يمكن تقديمه على البنية التحتية ذاتها.

باختصار، docker-android ليس منتجاً نبنيه، لكنه دراسة حالة جيدة في ترويض أحمال عمل الحاويات الثقيلة التي تجمع بين الامتياز ومرور الأجهزة وتسريع GPU على Kubernetes. هذه صورة ملموسة لقدرات تنظيم Kubernetes للأغراض العامة التي تُؤكد عليها ThakiCloud.

---

## القيود والاعتراضات

- **اعتماديات ثقيلة**: تسريع KVM للأجهزة غير قابل للتفاوض. في البيئات التي لا تدعم المحاكاة الافتراضية المتداخلة، يتدهور الأداء بشكل حاد أو لا يُقلع المحاكي أصلاً. اختيار عقدة السحابة يصبح قيداً صارماً.
- **تضخم الصورة**: الصور التي تتضمن المحاكي تبلغ عدة GB حتى بعد الضغط. التوزيع عبر عقد كثيرة يُراكم تكاليف السجل والقرص.
- **البُعد عن صلة الذكاء الاصطناعي**: بصراحة، هذه الأداة بعيدة عن أحمال عمل التدريب والاستدلال التي تمثل صميم منصتنا. للمؤسسات التي ليس لديها طلب اختبار موبايل، القيمة المباشرة محدودة. قيمة هذا المقال ليست في "المحاكي بحد ذاته" بل في "أنماط تشغيل حاويات مرور الأجهزة".
- **أمن الحاويات ذات الامتيازات**: الوصول إلى `/dev/kvm` وإعدادات الامتياز تُعقّد حدود أمان المستأجرين المتعددين. الحفاظ على عزل المستأجرين يستلزم مجمّعات عقد مخصصة وسياسات صارمة.

docker-android أداة قوية لأتمتة اختبارات الموبايل، ومرجع مفيد لكيفية التعامل مع أحمال عمل الأجهزة على Kubernetes. حتى قبل اللحظة التي نحتاجها فيها مباشرة، أنماط التشغيل تستحق الإلمام بها مسبقاً.

---

## المصادر

- docker-android (HQarroum): [https://github.com/HQarroum/docker-android](https://github.com/HQarroum/docker-android)
- صورة Docker Hub: `halimqarroum/docker-android`
- scrcpy (التحكم بالشاشة عن بُعد): [https://github.com/Genymobile/scrcpy](https://github.com/Genymobile/scrcpy)
- التغريدة الأصلية: [https://x.com/hjguyhan/status/2069427245295493446](https://x.com/hjguyhan/status/2069427245295493446)
