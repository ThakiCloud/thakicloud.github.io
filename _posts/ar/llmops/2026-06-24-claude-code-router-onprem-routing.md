---
title: "توجيه Claude Code إلى نماذجك الخاصة، بنية برمجة فعّالة التكلفة باستخدام claude-code-router"
excerpt: "توجيه حركة Claude Code عبر glm-5.2 وMiniMax-M2.7 وKimi K2 باستخدام claude-code-router. سجل عملي للتحقق من النماذج الثلاثة مباشرةً، وإصلاح تسرّب تفكير MiniMax، وبناء حلقة تتحقق باستمرار من أن كل نموذج موجَّه أرخص من Sonnet."
seo_title: "توجيه التكلفة عبر claude-code-router، إعداد Claude Code متعدد النماذج، Thaki Cloud"
seo_description: "دليل عملي لتوجيه Claude Code عبر glm-5.2/MiniMax-M2.7/Kimi K2 باستخدام claude-code-router. تقسيم النماذج حسب المهمة، وإصلاح تسرّب التفكير في MiniMax، وحلقة قياس مستمرة للتكلفة مقابل Sonnet، جميعها مُتحقَّق منها في بيئة ThakiCloud."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - claude-code
  - model-routing
  - cost-optimization
  - ollama
  - minimax
  - on-premise
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/claude-code-router-onprem-routing/"
reading_time: true
categories:
  - llmops
published: false
---

![مخطط مفاهيمي]({{ '/assets/images/claude-code-router-onprem-routing-hero.webp' | relative_url }})

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
<div class="d3-arch" data-arch-root id="ecoderouteronpremrouting-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1067, "height": 437, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "CC", "x": 67, "y": 242, "w": 120, "h": 46, "title": "Claude Code"}, {"id": "CCR", "x": 422, "y": 192, "w": 191, "h": 46, "title": "وسيط claude-code-router"}, {"id": "GLM", "x": 851, "y": 359, "w": 184, "h": 46, "title": "Ollama Cloud · glm-5.2"}, {"id": "MM", "x": 865, "y": 242, "w": 156, "h": 62, "title": ["MiniMax-M2.7 (نقطة", "Anthropic)"]}, {"id": "KIMI", "x": 879, "y": 125, "w": 128, "h": 62, "title": ["Ollama Cloud ·", "kimi-k2.7-code"]}, {"id": "VLLM", "x": 858, "y": 24, "w": 170, "h": 46, "title": "vLLM داخلي (GLM-air)"}, {"id": "AUDIT", "x": 24, "y": 141, "w": 205, "h": 46, "title": "حلقة قياس التكلفة اليومية"}], "edges": [{"src": "CC", "dst": "CCR", "kind": "data", "curve": [[187, 265], [326, 265], [326, 265], [430, 238]]}, {"src": "CCR", "dst": "GLM", "kind": "data", "label": "default / background", "curve": [[547, 238], [732, 382], [732, 382], [851, 382]], "off": "50%"}, {"src": "CCR", "dst": "MM", "kind": "data", "label": "think / longContext", "curve": [[602, 238], [732, 273], [732, 273], [865, 273]], "off": "50%"}, {"src": "CCR", "dst": "KIMI", "kind": "event", "label": "وسم الوكيل الفرعي للبرمجة", "curve": [[602, 192], [732, 156], [732, 156], [879, 156]], "off": "50%"}, {"src": "CCR", "dst": "VLLM", "kind": "event", "label": "خيار محلي", "curve": [[547, 192], [732, 47], [732, 47], [858, 47]], "off": "50%"}, {"src": "AUDIT", "dst": "CCR", "kind": "data", "label": "تتحقق مقابل Sonnet", "curve": [[229, 164], [326, 164], [326, 164], [430, 192]], "off": "50%"}]});
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
      const container = document.getElementById('ecoderouteronpremrouting-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ecoderouteronpremrouting-1';
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

‏Claude Code أداة برمجة وكيلية تعمل في الطرفية. افتراضياً تُرسِل الطلبات إلى واجهة Anthropic، لكن ليست كل الطلبات بالوزن نفسه. فالتلخيص الخلفي، والإكمال القصير، وتحليل السياق الطويل، والاستدلال العميق لإعادة الهيكلة تتطلب جميعها مستويات نماذج مختلفة. إذا أرسلت كل شيء إلى أغلى نموذج تتراكم التكلفة، وإذا أرسلت كل شيء إلى أرخصها تنهار الجودة.

يحل `claude-code-router` (واختصاراً CCR) هذه المشكلة عبر طبقة توجيه. يقف كوسيط بين Claude Code وخلفيات النماذج ويفرّع الحركة حسب نوع الطلب. هذا المقال ليس مجرد جولة مفاهيمية، بل سجل لاستدعاء ثلاثة نماذج خارجية للتحقق من سلوكها، وإصلاح المشكلات المكتشفة في الطريق (مفتاح API ميت، وتسرّب وسوم التفكير)، وأخيراً إرفاق حلقة تقيس باستمرار ما إذا كان التوجيه أرخص فعلاً من Sonnet.

المبدأ الحاكم، نذكره مقدّماً: **كل نموذج يُوجَّه عبر CCR لا قيمة له إلا إذا كان أكثر كفاءة في التكلفة من Claude Sonnet.** وإلا فإنك تخفض الجودة بينما يستمر صرف المال. لذلك لا نؤكّد، بل نقيس.

---


![مخطط مفاهيمي]({{ '/assets/images/claude-code-router-onprem-routing-diagram.svg' | relative_url }})

*مخطط مفاهيمي*

## ما هو claude-code-router

‏CCR وسيط يتلقى طلبات بصيغة Anthropic، ويحوّلها إلى صيغة متوافقة مع OpenAI (أو غيرها)، ثم يمرّرها إلى المزوّد المُعَدّ. لا يعدّل عميل Claude Code. شغّل جلسة بـ `ccr code` فتُوجَّه حركة تلك الجلسة عبر الوسيط على `localhost:3456`.

أبرز الميزات:

- **التوجيه حسب نوع الطلب**: `default` و`background` و`think` و`longContext` و`webSearch`، لكلٍّ نموذج مختلف.
- **تعدّد المزوّدين**: أي نقطة متوافقة مع OpenAI يمكن تسجيلها. نستخدم هنا Ollama Cloud وMiniMax.
- **المحوّلات (transformers)**: يمتص المحوّل خصوصيات كل مزوّد. ومحوّل التمرير `Anthropic` لنقاط Anthropic الأصلية هو الأداة المحورية في هذا المقال.
- **التبديل الديناميكي**: غيّر النموذج أثناء الجلسة بـ `/model provider,model`.

إصدار CCR المُتحقَّق منه هو `1.0.62`. يقع الإعداد في `~/.claude-code-router/config.json`، ومحوره مصفوفة `Providers` وكائن `Router`.

---

## ماذا يُوجَّه، مثبَّت على ثلاثة نماذج

مجموعة النماذج ثلاثة بالضبط. فزيادة النماذج تعقّد جدول التوجيه وترفع كلفة التحقق، لذا ضيّقناها عمداً.

| الدور | النموذج | المزوّد | ملاحظة |
|------|---------|---------|--------|
| الأساسي (default/background) | `glm-5.2` | Ollama Cloud | برمجة يومية، قوي ورخيص |
| الاستدلال (think/longContext) | `MiniMax-M2.7` | MiniMax | تفكير منفصل، كلفة منخفضة جداً لكل رمز |
| الوكيل الفرعي للبرمجة | `kimi-k2.7-code` | Ollama Cloud | للأدوار البرمجية الصعبة فقط |

‏`glm-5.2` هو حصان العمل؛ والاستدلال العميق والسياق الطويل فقط يذهبان إلى MiniMax، والدور البرمجي الصعب إلى Kimi.

---

## التحقق، استدعينا ولم نفترض

قبل كتابة أي إعداد، استدعينا النماذج الثلاثة مباشرةً. ولتجنّب اختلاق الأرقام فحصنا الاستجابات الفعلية، فظهرت ثلاث حقائق.

**أولاً، مفتاح Ollama Cloud واحد يغطي GLM وKimi معاً.** أرجع كلٌّ من `glm-5.2` و`kimi-k2.7-code` رمز HTTP 200 من `https://ollama.com/v1`. فـ Ollama Cloud يجمع عائلات GLM وKimi وDeepSeek وQwen خلف مفتاح واحد.

**ثانياً، مفتاح Kimi المنفرد كان ميتاً.** أرجع مفتاح Moonshot المنفرد في `.env` رمز 401 (مصادقة غير صالحة) على moonshot.ai وmoonshot.cn ونقطة Anthropic المتوافقة على حدٍّ سواء. لحسن الحظ يمكن الوصول إلى Kimi K2 عبر `kimi-k2.7-code` في Ollama Cloud، فلم يكن المفتاح الميت طريقاً مسدوداً.

**ثالثاً، اختيار نقطة MiniMax يحسم الجودة.** عند الاستدعاء عبر النقطة المتوافقة مع OpenAI (`/v1/chat/completions`) يضمّن النموذج استدلاله داخل المتن بوسوم `<think>...</think>`، وتعجز طبقة التحويل في CCR عن إزالتها فتتسرب إلى المستخدم (musistudio/claude-code-router#964). أما عند الاستدعاء عبر نقطة Anthropic الأصلية (`/anthropic/v1/messages`) فيُرجع النموذج نفسه كتلتي `thinking` و`text` نظيفتين.

البند الأخير علّة وجب إصلاحها لا سبباً لإسقاط MiniMax. والإصلاح مُضمَّن في الإعداد أدناه.

---

## الإعداد، الأسرار خارج المستودع، والإعداد كشيفرة

لا تُكتب المفاتيح مباشرةً في ملف الإعداد. سكربت مولِّد يقرأ `.env` في المستودع ويكتب `~/.claude-code-router/config.json`. فلا تبقى مفاتيح في المستودع، وتدوير المفتاح يعني فقط إعادة تشغيل السكربت.

الإعداد المُولَّد الأساسي:

```json
{
  "LOG": true,
  "HOST": "127.0.0.1",
  "PORT": 3456,
  "API_TIMEOUT_MS": 1800000,
  "Providers": [
    {
      "name": "ollama",
      "api_base_url": "https://ollama.com/v1/chat/completions",
      "api_key": "<OLLAMA_GLM_API_KEY>",
      "models": ["glm-5.2", "kimi-k2.7-code"],
      "transformer": { "use": [["maxtoken", { "max_tokens": 16000 }]] }
    },
    {
      "name": "minimax",
      "api_base_url": "https://api.minimax.io/anthropic/v1/messages",
      "api_key": "<MINIMAX_API_KEY>",
      "models": ["MiniMax-M2.7"],
      "transformer": { "use": ["Anthropic"] }
    }
  ],
  "Router": {
    "default": "ollama,glm-5.2",
    "background": "ollama,glm-5.2",
    "think": "minimax,MiniMax-M2.7",
    "longContext": "minimax,MiniMax-M2.7",
    "longContextThreshold": 60000,
    "webSearch": "ollama,glm-5.2"
  }
}
```

السطران في مزوّد MiniMax هما ما يُصلِح تسرّب التفكير. وجِّه `api_base_url` إلى مسار Anthropic الأصلي واستخدم محوّل التمرير `Anthropic`، فيستجيب MiniMax بصيغة رسائل Anthropic (كتلتا `thinking` و`text`) منذ البداية. وعند إعادة الفحص عبر الوسيط كانت كتل الاستجابة `["thinking", "text"]` بلا أي تسرّب لـ `<think>`.

نماذج الاستدلال بطيئة الإخراج، لذا جُعِلت المهلة سخية (`1800000ms`)، ويحجز `maxtoken` مساحة إخراج كي لا تستنفد نماذج مثل GLM وKimi ( التي تُخرِج الاستدلال أولاً ) الميزانية قبل الإجابة.

تُوجَّه الوكلاء الفرعيون لا بالإعداد بل بوسم في مقدمة المُوجّه. لتفويض مهمة برمجية صعبة، أضِف في مقدمة المُوجّه `<CCR-SUBAGENT-MODEL>ollama,kimi-k2.7-code</CCR-SUBAGENT-MODEL>`.

---

## أين وكيف تتصل

نقطة الاتصال واحدة. ابدأ جلسة بـ `ccr code` في مستودع عملك، فتُوجَّه حركة تلك الجلسة الرئيسية والفرعية كلها عبر الوسيط وفق الجدول أعلاه. أما `claude` الأصلي فيتصل مباشرةً بـ Anthropic، فلا يتأثر.

```bash
# توليد الإعداد ثم تشغيل الموجِّه
python3 scripts/ccr/gen_ccr_config.py && ccr restart

# بدء جلسة موجَّهة للتكلفة (هذه هي نقطة الاتصال)
ccr code

# بدّل النماذج حسب المهمة داخل الجلسة
/model ollama,kimi-k2.7-code     # دور برمجي صعب
/model minimax,MiniMax-M2.7      # دور استدلال عميق
/model ollama,glm-5.2            # برمجة يومية
```

من حيث كفاءة التكلفة، النمط المُوصى به هجين. شغّل الأعمال الكثيفة والمتكررة وغير التفاعلية (توليد الاختبارات، إعادة الهيكلة الجماعية، تحليل السجلات، الترجمة، استكشاف الكود) تحت `ccr code` لخفض التكلفة، وأبقِ الأعمال التي تتطلب حكماً (قرارات معمارية، تصحيح دقيق) على جلسة `claude` الاشتراكية الأصلية. فنقل كل شيء إلى الجلسة الموجَّهة يجعل GLM حلقتك الرئيسية، وقد يخفض الجودة في المهام الصعبة.

---

## كفاءة التكلفة، قياس مستمر مقابل Sonnet

سبب وجود هذا الإعداد هو التكلفة. لذا بدل أن ندّعي أنه "أرخص"، نقيس.

الأسعار المُتحقَّق منها في 2026-06-24 (بالدولار لكل مليون رمز):

| النموذج | الإدخال | الإخراج | نمط الفوترة | مقابل Sonnet |
|--------|---------|---------|-------------|--------------|
| Claude Sonnet 4.6 (المرجع) | $3.00 | $15.00 | لكل رمز | 1.0× |
| MiniMax-M2.7 | $0.24 | $0.96 | لكل رمز | ~0.07× |
| glm-5.2 / kimi-k2.7-code | - | - | اشتراك $20/شهر (Pro) | يعتمد على الاستخدام |

‏MiniMax-M2.7 نحو 7-8% من سعر Sonnet لكل رمز، فهو دوماً أرخص بفارق كبير. أما Ollama Cloud فاشتراك شهري ثابت لا تسعير لكل رمز. سعره الفعلي = `الرسم الشهري ÷ الرموز المستخدمة شهرياً`، وعند الاستخدام المنخفض يكون الرسم الثابت $20 خسارة. وبمعدل مخلوط $9/M، عليك تجاوز **نحو 2.2 مليون رمز شهرياً** قبل أن يتفوق على Sonnet.

نقطة التعادل هذه هدف قياس لا تخمين. تسجّل سجلات CCR النموذج المُوجَّه ورموز الإدخال/الإخراج لكل طلب. وسكربت قياس يجمعها، فيحسب نسبة التكلفة الفعلية إلى تكلفة Sonnet المكافئة للنماذج بالرمز، والتكلفة الشهرية المتوقّعة لـ Sonnet مقابل رسم الاشتراك للنماذج بالاشتراك. وتتراكم النتائج في ملف تاريخي لتتبّع الاتجاه، والتحسّن يعني انخفاض النسبة مع الوقت.

تعمل الحلقة مرة يومياً عبر launchd. ولا يكون Claude داخل الحلقة؛ بل يعمل سكربت بسيط فقط على cron، فتكون كلفة القياس نفسها صفراً. وإذا وُجِد نموذج بالرمز أغلى من Sonnet يُطلَق تنبيه إلى Slack. أما النموذج بالاشتراك دون نقطة التعادل (استخدام ناقص) فيُسجَّل دون تنبيه، تفادياً للضجيج في مرحلة الانطلاق.

قواعد الإجراء مرتبطة بالقياس. إذا بلغت نسبة نموذج بالرمز 1.0 أو أكثر (أغلى من Sonnet) يُزال فوراً من التوجيه. وإذا بقي نموذج بالاشتراك دون الاستخدام أشهراً، خفّض الخطة أو انقل ذلك المسار إلى نموذج رخيص بالرمز. وعند تغيّر الأسعار يكفي تحديث ملف جدول الأسعار لينعكس في التشغيل التالي.

---

## منظور منصة ThakiCloud

ينسجم نموذج التوجيه هذا طبيعياً مع البنية التي تشغّلها ThakiCloud فعلاً.

**أمن الكود.** في البيئات التي لا يمكن أن يغادر فيها الكود المصدري (المالية، القطاع العام، الرعاية الصحية)، يكفي تبديل `default` في الإعداد أعلاه إلى نقطة vLLM داخلية. فتحتفظ بقابلية استخدام Claude Code بينما لا تغادر المُوجّهات والكود قط. وإعداد النماذج الخارجية هنا للتحقق من التكلفة؛ ضع خدمة GPU الداخلية في الهيكل نفسه فتحصل على النسخة المحلية.

**التحكم في التكلفة.** التوجيه حسب المهمة هو توجيه حسب التكلفة. أرسِل الطلبات عالية التكرار منخفضة الصعوبة إلى نماذج رخيصة واحتفظ بالنماذج العليا للاستدلال الصعب، فتضيّق الاستخدام المكلف إلى حيث يلزم فعلاً، وتثبت حلقة القياس الأثر بالأرقام.

**السياسة كشيفرة.** المزوّدون وقواعد التوجيه وجدول الأسعار ومعايير القياس كلها مُدارة كملفات نصية مُودَعة في المستودع. وتبقى المفاتيح وحدها في `.env` ويُعاد إنتاج الإعداد بمولِّد، فيُستعاد الإعداد نفسه على أي جهاز.

---

## الحدود والاعتراضات

الموجِّه لا يحل كل شيء. عدة نقاط تستحق نظرة باردة.

- **فجوة الجودة**: قيمة التوجيه تتبع جودة النموذج الخلفي. فالنماذج المفتوحة لا تجاري دوماً النماذج المغلقة العليا في إعادة الهيكلة المعقدة متعددة الخطوات أو التصحيح الدقيق. ومن هنا توصية النمط الهجين.
- **موثوقية استدعاء الأدوات**: يعتمد Claude Code كثيراً على استدعاء الأدوات. وقد تهتز صيغ استدعاء الأدوات عبر طبقة التحويل المتوافقة مع OpenAI، فهي آمنة لوكلاء الاستكشاف/التلخيص لكنها تستدعي توسعاً تدريجياً لوكلاء التحرير/التنفيذ.
- **فخ الاشتراك**: Ollama Cloud بسعر ثابت، فالاستخدام المنخفض خسارة. ودون نقطة التعادل يكون Sonnet أرخص ببساطة. وحلقة القياس تراقب هذه النقطة بالضبط.
- **الوسيط نقطة فشل واحدة**: تمر الحركة الرئيسية أيضاً عبر CCR، فإذا مات الوسيط تتوقف الجلسة. والبديل هو `claude` الأصلي.
- **فخ تأطير "المجاني"**: تروّج بعض النسخ المعدّلة لإزالة القياس عن بُعد أو حواجز الأمان بوصفها "مجانية". وهذا اتجاه لا تستطيع شركة تأييده. والقيمة التي نأخذها ليست المجانية بل التحكم، نحن من يقرّر أي طلب يذهب إلى أي نموذج، ونحن من يقيس التكلفة.

في الخلاصة، CCR ليس حيلة سحرية لخفض التكلفة بل أداة تحكم في التوجيه. وحين يُدمَج مع مجموعة نماذج مُتحقَّق منها، وإصلاحات لعلل حقيقية مثل تسرّب التفكير، وقياس مستمر مقابل Sonnet، يصبح مكسباً حقيقياً على محوري الأمان والتكلفة.

---

## المصادر

- claude-code-router (musistudio): [https://github.com/musistudio/claude-code-router](https://github.com/musistudio/claude-code-router)
- مشكلة تسرّب تفكير MiniMax: [claude-code-router#964](https://github.com/musistudio/claude-code-router/issues/964)
- سعر MiniMax M2.7: [openrouter.ai/minimax/minimax-m2.7](https://openrouter.ai/minimax/minimax-m2.7)
- أسعار Ollama Cloud: [ollama.com/pricing](https://ollama.com/pricing)
- أسعار Claude API: [platform.claude.com/docs pricing](https://platform.claude.com/docs/en/about-claude/pricing)
