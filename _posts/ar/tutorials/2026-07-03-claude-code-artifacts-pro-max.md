---
title: "وصول Artifacts في Claude Code إلى خطتي Pro وMax: جلستك تتحول إلى صفحة ويب حية"
excerpt: "توسّعت ميزة Artifacts في Claude Code لتتجاوز خطتي Team وEnterprise إلى خطتي Pro وMax. نحلّل الميزة التي تحوّل جلسة برمجية إلى صفحة ويب حية قابلة للمشاركة، ونستعرض كيف يمكن لمنصة Paxis وبنية ai-platform من ThakiCloud استيعاب هذا النمط."
tags:
  - claude-code
  - artifacts
  - agent-native
  - developer-experience
  - paxis
date: 2026-07-03
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/technique/claude-code-artifacts-pro-max/"
categories:
  - tutorials
---

![صورة تجريدية لمخرجات جلسة تتجمع في صفحة حية واحدة بطبقات متعددة]({{ '/assets/images/claude-code-artifacts-pro-max-hero.webp' | relative_url }})
*يتكثّف تقدّم الجلسة البرمجية في صفحة واحدة قابلة للمشاركة تتحدّث في الوقت الفعلي.*

## نظرة عامة

حين ينهي وكيل برمجي ساعات من العمل، يظل عرض النتيجة على شخص آخر أمراً مرهقاً على نحو مفاجئ. تلتقط سجلات الطرفية وتلصقها، أو تلخّص التغييرات يدوياً، أو تبني لوحة معلومات منفصلة. وكثيراً ما يستهلك شرح العمل جهداً أكبر من العمل نفسه.

في يوليو 2026، وسّعت Anthropic ميزة Artifacts في Claude Code لتشمل خطتي Pro وMax. فقدرة كانت محصورة في خطتي Team وEnterprise باتت متاحة الآن للمطورين الأفراد. الفكرة بسيطة: حين تطلب artifact، يكتب Claude الشيفرة وينشرها مباشرةً على claude.ai، ويواصل تحديث تلك الصفحة في الوقت الفعلي بينما تستمر الجلسة. الصفحة خاصة بحسابك ومكتفية ذاتياً بالكامل.

يشرح هذا المقال ما هي Artifacts في Claude Code بدقة، ولماذا يهمّ توسّعها إلى Pro وMax، وكيف يمكن استيعاب هذا النمط من منظور منصة الوكلاء Paxis وبنية الذكاء الاصطناعي ai-platform لدى ThakiCloud.

## ما هي Artifacts في Claude Code

كانت Artifacts في الأصل تعرض الشيفرة أو المستندات في لوحة منفصلة داخل محادثة claude.ai. أما Artifacts التي وصلت للتو إلى Claude Code فمختلفة قليلاً. فبدلاً من مخرَج تبادل واحد، تحوّل تقدّم جلسة برمجية كاملة إلى صفحة بصرية حية واحدة.

تسرد Anthropic أربعة استخدامات نموذجية: شروحات طلبات الدمج (PR walkthroughs)، وصفحات شرح النظام، ولوحات المعلومات، وقوائم مراجعة الإصدار. القاسم المشترك بينها أن كلّاً منها ملخّص يقرأه الإنسان لما يجري الآن. وبينما تواصل الجلسة عملها، تحدّث تلك الصفحة نفسها.

يبدو المسار من العمل إلى النشر على النحو التالي.

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
<div class="d3-arch" data-arch-root id="laudecodeartifactspromax-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 621, "height": 898, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 104, "y": 24, "w": 170, "h": 46, "title": "المطور يطلب artifact"}, {"id": "B", "x": 90, "y": 148, "w": 198, "h": 46, "title": "Claude Code يكتب الشيفرة"}, {"id": "C", "x": 114, "y": 272, "w": 149, "h": 62, "title": ["النشر المباشر على", "claude.ai"]}, {"id": "D", "x": 120, "y": 412, "w": 138, "h": 52, "title": "الجلسة تستمر"}, {"id": "E", "x": 24, "y": 556, "w": 177, "h": 62, "title": ["تحديث الصفحة في الوقت", "الفعلي"]}, {"id": "F", "x": 256, "y": 564, "w": 198, "h": 46, "title": "تثبيت صفحة مكتفية ذاتياً"}, {"id": "G", "x": 281, "y": 696, "w": 149, "h": 46, "title": "مشاركة رابط النشر"}, {"id": "H", "x": 131, "y": 820, "w": 191, "h": 46, "title": "المتلقّي يطّلع دون حساب"}, {"id": "I", "x": 377, "y": 820, "w": 212, "h": 46, "title": "صاحب الحساب ينسخ عبر remix"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [189, 70, 189, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [189, 194, 189, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [189, 334, 189, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "تغيّر حالة العمل", "curve": [[189, 464], [189, 510], [189, 510], [143, 556]], "off": "50%"}, {"src": "E", "dst": "D", "kind": "data", "curve": [[98, 556], [77, 510], [77, 510], [148, 464]]}, {"src": "D", "dst": "F", "kind": "data", "label": "اكتمال", "curve": [[249, 464], [355, 510], [355, 510], [355, 564]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [355, 610, 355, 696]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[307, 742], [227, 781], [227, 781], [227, 820]]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[403, 742], [483, 781], [483, 781], [483, 820]]}]});
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
      const container = document.getElementById('laudecodeartifactspromax-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'laudecodeartifactspromax-1';
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

يبرز هنا قراران تصميميان. أولاً، الصفحة مكتفية ذاتياً. فدون خط بناء خارجي أو إعداد استضافة، يوجد كل ما تحتاجه داخل الصفحة المنشورة الواحدة. ثانياً، الإعداد الافتراضي خاص. فالصفحة تخصّ حسابك، ولا يستطيع أحد رؤيتها حتى تضغط على زر النشر وتشارك الرابط.

## لماذا يهمّ التوسّع إلى Pro وMax

كانت الميزة نفسها متاحة على Team وEnterprise منذ بضعة أشهر. التغيير الأساسي الآن هو أن حدّ الخطة انخفض.

بدقّة: كانت Artifacts العادية المُنشأة في محادثة claude.ai قابلة للنشر أصلاً على كل الخطط بما فيها Free وPro وMax. أما Artifacts التي تحوّل جلسة Claude Code إلى صفحة حية فكانت حصراً على Team وEnterprise. وقد امتدّ هذا الحدّ الآن إلى Pro وMax. فبدون مقعد مؤسسي، يستطيع المطور الفرد تحويل جلسته إلى صفحة قابلة للمشاركة.

يتّضح سبب الأهمية حين تنظر إلى طريقة عمل المطورين الأفراد فعلياً. حين ينهي مساهم في مشروع مفتوح المصدر إعادة هيكلة طويلة، يحتاج إلى وسيلة لنقل سياق التغيير إلى المراجِع. والأمر نفسه ينطبق على مطور منفرد يدير مشروعاً جانبياً ويريد تتبّع تقدّمه أو عرضه على زميل. حتى الآن، لم يكن بمقدور هؤلاء المستخدمين استعمال الميزة ما لم يكونوا مرتبطين بخطة مؤسسية. والتوسّع إلى Pro وMax يسدّ هذه الفجوة.

ملاحظة إضافية: خلال الفترة نفسها، رفعت Anthropic مؤقتاً الحدود الأسبوعية لاستخدام Claude Code لخطط Pro وMax وTeam. فُتح الوصول والهامش معاً، ما يمنح المطورين الأفراد مساحة حقيقية لتجربة الميزة.

## كيف تعمل عملياً

استخدامها أقرب إلى المحادثة. أثناء الجلسة، حين تقول "حوّل هذا العمل إلى artifact"، يولّد Claude Code صفحة تلتقط التقدّم الحالي وينشرها على claude.ai. افتح الرابط المُعاد وسترى صفحة بصرية تلخّص العمل حتى الآن، وبينما تستمر الجلسة تتحدّث الصفحة دون إعادة تحميل.

تجري المشاركة عبر زر النشر أسفل لوحة artifact. ومن يتلقّى الرابط يستطيع الاطلاع على الصفحة دون حساب Claude. ومن يملك حساباً يمكنه استخدام remix لإنشاء نسخته القابلة للتحرير. بعبارة أخرى، يكون artifact واحد مادةً مشتركة للقراءة فقط ونقطة انطلاق يمكن لشخص آخر التقاطها وتطويرها.

نموذج الخصوصية واضح أيضاً. الصفحة المُنشأة في Claude Code خاصة بحسابك افتراضياً. ولا تُكشف خارجياً إلا لحظة نشرك وتسليمك الرابط، وحتى ذلك الحين أنت وحدك من يراها. وبالنسبة للمطورين الذين يتعاملون مع عمل داخلي حساس، يهمّ هذا الإعداد الافتراضي لأنه لا يوجد مسار للكشف العرضي.

أكثر التركيبات عمليةً في هذا المسار هو شرح طلب الدمج. فبعد إنهاء تغيير طويل، يُنتج طلب artifact صفحةً تغطّي ما تغيّر ولماذا، وأي الملفات تأثّرت، وكيف جرى التحقق. ويستطيع المراجِع فهم السياق من هذه الصفحة قبل قراءة الفرق (diff). وتعمل صفحات الاستجابة للحوادث وقوائم مراجعة الإصدار بالطريقة نفسها، إذ تتيح للوكيل الاحتفاظ بملخّص يقرأه الإنسان من تلقاء نفسه.

## ماذا يعني ذلك لـ ThakiCloud

المغزى الحقيقي لهذه الميزة يتجاوز راحة أداة واحدة. فالنمط نفسه، أي "الاحتفاظ بمخرَج عمل الوكيل كأثر قابل للقراءة والمشاركة وإبقاؤه حياً"، هو تحدٍّ جوهري لأي منصة وكلاء.

**عدسة Paxis (مخرَج الوكيل كمورد من الدرجة الأولى).** إن Paxis من ThakiCloud هي مستوى تحكّم Agent-Native Cloud يعمل فوق ai-platform ويتعامل مع Skills وTools وPolicies وAudit Logs كموارد من الدرجة الأولى. وما تُظهره Artifacts في Claude Code هو طريقة لكشف مخرَج الوكيل الوسيط والنهائي كقناة مراقبة منفصلة. فحين تنفّذ شبكة DAG من وكلاء متعددين في Paxis مهمة طويلة، يتيح تكثيف تقدّم كل عقدة في صفحة حية يقرأها الإنسان للمشغّل أن يستوعب المسار دون تمرير السجلات. وبدمج ذلك مع بوابات السياسات وسجلات التدقيق في Paxis، يصبح الأثر مخرَجاً محكوماً يمكن تتبّعه حتى "مَن أنشأ وشارك ماذا ومتى". وبالروح نفسها لأثر Anthropic الخاص افتراضياً، يمكن لـ Paxis إضافة تحكّم بالوصول قائم على السياسات لمشاركة المخرَجات وتوسيعه إلى مستوى المؤسسة.

**عدسة ai-platform (صفحات التشغيل الداخلية).** على صعيد البنية التحتية، تلائم الصفحات المكتفية ذاتياً لوحات المعلومات الداخلية وصفحات الحوادث. فبنية ai-platform من ThakiCloud تشغّل K8s وجدولة Kueue لوحدات GPU وخدمة vLLM متعددة المستأجرين، وتحتاج أعباء العمل الدفعية والخدمية التي تدور عليها إلى قناة لنقل حالتها إلى البشر. وإذا سمحت للوكيل بالاحتفاظ بقائمة مراجعة إصدار أو صفحة تقدّم نشر من تلقاء نفسه، فإنك تكسب رؤية تشغيلية في البيئات المحلية والسيادية دون إضافة كومة مراقبة منفصلة. ولأن الاكتفاء الذاتي يقلّل الاعتماد على الاستضافة الخارجية، يبقى العبء خفيفاً حتى في بيئات العملاء ذات متطلبات العزل الشبكي الصارمة.

تتكامل العدستان. فإذا شغّلت ai-platform أعباء الوكلاء بتكلفة منخفضة وعاملت Paxis مخرَجاتها كآثار قابلة للمشاركة تحت السياسة والتدقيق، أمكنك إعادة إنتاج تجربة "يعمل الوكيل فيصبح ناتجه فوراً شيئاً يقرأه الإنسان" على منصتك الخاصة.

## القيود والاعتراضات

هناك نقاط واضحة ينبغي فيها تعديل التوقعات.

أولاً، الميزة مرتبطة بالنشر على claude.ai. ولأن الصفحة مستضافة على بنية Anthropic، يصعب استخدامها كما هي في بيئة معزولة شبكياً بالكامل أو حيث يُحظر إخراج البيانات. ويحتاج العملاء ذوو متطلبات السيادة القوية إلى بديل مستضاف ذاتياً، وهذه بالضبط الفجوة التي تستطيع منصة موجّهة للاستضافة المحلية مثل ThakiCloud ملأها.

ثانياً، الصفحات المكتفية ذاتياً ممتازة للملخصات ولوحات المعلومات البسيطة، لكنها محدودة أمام التفاعلات المعقّدة أو تكامل البيانات واسع النطاق. فالأثر المنشور في جوهره واجهة أمامية خفيفة ولا يحلّ محلّ منطق خلفي ثقيل.

ثالثاً، لا تصحّ التحديثات في الوقت الفعلي إلا ما دامت الجلسة حية. وبمجرد انتهاء الجلسة، تتجمّد الصفحة كلقطة من تلك اللحظة. وإن احتجت لوحة تشغيل تتحدّث باستمرار، فلا تزال بحاجة إلى خط أنابيب منفصل.

باختصار، يخفّض توسّع Artifacts في Claude Code إلى Pro وMax حاجز تحويل المطورين الأفراد لعمل الوكيل إلى مخرَج قابل للمشاركة بدرجة كبيرة. وتبقى قيود الاستضافة والاستمرارية، وهنا بالضبط تقدّم منصة وكلاء مزوّدة بالسياسة والتدقيق والاستضافة المحلية قيمة مكمّلة. استوعب راحة الأداة، واملأ المجالات التي تتطلب التحكّم والسيادة بمنصتك الخاصة. هذا هو النهج الواقعي.

## المصادر

- [منشور إعلان ClaudeDevs (@ClaudeDevs)](https://x.com/ClaudeDevs/status/2072770790114914317)
- [Publish and share artifacts (Claude Help Center)](https://support.claude.com/en/articles/9547008-publish-and-share-artifacts)
- [What are artifacts and how do I use them? (Claude Help Center)](https://support.claude.com/en/articles/9487310-what-are-artifacts-and-how-do-i-use-them)
