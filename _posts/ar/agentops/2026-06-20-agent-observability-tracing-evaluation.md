---
title: "قابلية مراقبة وكلاء LLM: التتبع وحلقات التقييم وتصحيح الأخطاء في الإنتاج"
excerpt: "نشرح سبب عجز التسجيل التقليدي في أنظمة الوكلاء المتعددين، وكيفية بناء تتبع النطاقات وخطوط أنابيب التقييم وآليات تصحيح الأخطاء في الإنتاج من منظور عملي."
seo_title: "دليل بناء قابلية مراقبة وكلاء LLM - Thaki Cloud"
seo_description: "طرق بناء تتبع وكلاء LLM وحلقات التقييم باستخدام MLflow وLangSmith وArize AI. دليل عملي يستند إلى حقيقة أن 65% من إخفاقات وكلاء الإنتاج تنبع من مشكلات السياق."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - observability
  - tracing
  - evaluation
  - llm-ops
  - mlflow
  - langsmith
  - agent-debugging
  - production
lang: ar
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ar/agentops/agent-observability-tracing-evaluation/"
reading_time: true
categories:
  - agentops
published: false
---

⏱️ **وقت القراءة المقدر**: 9 دقائق

<!-- evolve-diagram -->
*رسم تخطيطي توضيحي*

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
<div class="d3-arch" data-arch-root id="abilitytracingevaluation-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 729, "height": 554, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "R", "x": 24, "y": 250, "w": 177, "h": 46, "title": "agent_run (root span)"}, {"id": "P", "x": 290, "y": 476, "w": 177, "h": 46, "title": "plan: decompose query"}, {"id": "L1", "x": 307, "y": 359, "w": 142, "h": 62, "title": ["llm_call: sonnet", "tokens + latency"]}, {"id": "T1", "x": 290, "y": 242, "w": 177, "h": 62, "title": ["tool_call: web_search", "input + result"]}, {"id": "S1", "x": 279, "y": 141, "w": 198, "h": 46, "title": "subagent: research_agent"}, {"id": "L2", "x": 566, "y": 192, "w": 120, "h": 46, "title": "llm_call"}, {"id": "T2", "x": 555, "y": 91, "w": 142, "h": 46, "title": "tool_call: fetch"}, {"id": "C", "x": 290, "y": 24, "w": 177, "h": 62, "title": ["cost attribution", "per-span tokens + USD"]}], "edges": [{"src": "R", "dst": "P", "kind": "data", "curve": [[125, 296], [240, 499], [240, 499], [290, 499]]}, {"src": "R", "dst": "L1", "kind": "data", "curve": [[138, 296], [240, 390], [240, 390], [307, 390]]}, {"src": "R", "dst": "T1", "kind": "data", "line": [201, 273, 290, 273]}, {"src": "R", "dst": "S1", "kind": "data", "curve": [[139, 250], [240, 164], [240, 164], [279, 164]]}, {"src": "S1", "dst": "L2", "kind": "data", "curve": [[441, 187], [516, 215], [516, 215], [566, 215]]}, {"src": "S1", "dst": "T2", "kind": "data", "curve": [[441, 141], [516, 114], [516, 114], [555, 114]]}, {"src": "R", "dst": "C", "kind": "data", "curve": [[126, 250], [240, 55], [240, 55], [290, 55]]}]});
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
      const container = document.getElementById('abilitytracingevaluation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'abilitytracingevaluation-1';
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

## لماذا يفقد التسجيل معناه في بيئة الوكلاء

يُؤدي التسجيل التقليدي مهمته جيداً مع استدعاءات LLM الفردية: تسجيل أزواج الإدخال والإخراج، وقياس زمن الاستجابة، والتقاط الأخطاء.

الصورة تتغير حين ننتقل إلى الوكلاء المتعددين. يستدعي الوكيل الأدوات من تلقاء نفسه، ويُحيل التحكم إلى وكلاء آخرين، ويتسلسل عبر استدعاءات LLM متعددة. لمعرفة أين أخفق الوكيل ولماذا، لا يكفي معرفة "ما الذي جرى"، بل يجب إعادة بناء "بأي ترتيب، وفي أي سياق، واتُّخذت أي قرارات".

خلص تحليل عام 2025 إلى أن نحو 65% من إخفاقات الوكلاء لا تعود إلى قدرات النموذج، بل إلى مشكلات في تركيب السياق. بلا قابلية للمراقبة، يستحيل تشخيص هذا النوع من الإخفاقات.

---


![مخطط مفاهيمي]({{ '/assets/images/agent-observability-tracing-evaluation-diagram.svg' | relative_url }})

*مخطط مفاهيمي*

## العناصر الثلاثة لتتبع الوكلاء

### 1. النطاقات المتشعبة

تنفيذ الوكيل هو هيكل شجري: النطاق الجذر يُغلّف تنفيذ الوكيل بالكامل، والنطاقات الفرعية تُمثل كل استدعاء LLM واستدعاء أداة واستدعاء وكيل فرعي.

إن اخترت التنفيذ المباشر على OpenTelemetry، فاتبع هذه البنية:

```python
with tracer.start_as_current_span("agent_run") as root_span:
    root_span.set_attribute("agent.name", "research_agent")
    root_span.set_attribute("input.query", query)
    
    with tracer.start_as_current_span("llm_call") as llm_span:
        llm_span.set_attribute("model", "claude-sonnet-4-6")
        llm_span.set_attribute("prompt_tokens", prompt_tokens)
        response = llm.invoke(prompt)
        llm_span.set_attribute("completion_tokens", completion_tokens)
    
    with tracer.start_as_current_span("tool_call") as tool_span:
        tool_span.set_attribute("tool.name", "web_search")
        tool_span.set_attribute("tool.input", search_query)
        result = search_tool.run(search_query)
```

المحوري هنا هو نقل علاقة الأب بالابن عبر سياق النطاق. في تحويلات الوكلاء المتعددين، يجب أن ينتقل هذا النقل عبر حدود الوكلاء.

### 2. تتبع الذاكرة والحالة

يجب تسجيل السياق الذي كان لدى الوكيل في كل خطوة. في الوكلاء طويلة التشغيل تحديداً، يُعدّ تتبع تطور السياق أمراً لا غنى عنه في التشخيص.

احفظ لقطات الحالة عند كل نقطة قرار رئيسية. إن كانت اللقطات الكاملة عبئاً ثقيلاً في الإنتاج، يكفي تسجيل تجزئة الحالة والفروقات للتمكن من إعادة البناء.

### 3. إسناد التكاليف

لا يكفي في خطوط الأنابيب المتعددة الوكلاء تجميع التكاليف فحسب. يجب النزول إلى مستوى النطاق لمعرفة أي خطوة في أي وكيل استهلكت الرموز، لتحديد اتجاه تحسين التكاليف.

```python
# إضافة إسناد التكاليف إلى النطاق
span.set_attribute("cost.input_tokens", input_tokens)
span.set_attribute("cost.output_tokens", output_tokens)
span.set_attribute("cost.model_tier", "sonnet")  # haiku/sonnet/opus
span.set_attribute("cost.estimated_usd", estimated_cost)
```

---

## تصميم حلقة التقييم

إن أجاب التتبع على "ماذا جرى"، فإن التقييم يُجيب على "هل سارت الأمور على ما يرام". الطبقتان مختلفتان.

### التقييم دون اتصال مقابل التقييم المتصل

**التقييم دون اتصال** يتحقق من تغييرات النموذج والتلقين قبل النشر باستخدام مجموعة بيانات مرجعية ثابتة. دمجه في خط أنابيب CI/CD يُمسك بالانحدارات.

**التقييم المتصل** يُراقب مقاييس الجودة بأخذ عينات من آثار الإنتاج في الوقت الحقيقي، ويرصد الانجراف في التوزيع أو مشكلات التلقين بعد النشر.

يجب تشغيل كلاهما معاً. الاتكاء على التقييم دون اتصال وحده يُفوّت تغيرات توزيع البيانات الفعلية في الإنتاج، بينما يعني الاقتصار على التقييم المتصل غياب بوابة الجودة قبل النشر.

### مخاطر التقييم التلقائي القائم على LLM

شاع توظيف LLM مُقيِّماً، لكن الأمر يستلزم يقظة. استخدام نفس النموذج للتوليد وللتقييم يُولّد تحيز التعزيز الذاتي. يُستحسن استخدام نماذج مختلفة للتوليد والتقييم كلما أمكن.

علاوة على ذلك، يجب أن يتفحص الإنسان دورياً موثوقية حكم LLM المقيِّم ذاته، وتتبع ارتباط درجات التقييم التلقائي بالتغذية الراجعة الفعلية للمستخدمين.

### اختيار مقاييس التقييم

تتباين المقاييس باختلاف نوع المهمة:

| نوع المهمة | أمثلة على المقاييس |
|------------|-------------------|
| استرجاع المعلومات | الصلة، الاكتمال، الدقة الواقعية |
| توليد الكود | معدل اجتياز الاختبارات، الثغرات الأمنية، الالتزام بأسلوب الكتابة |
| استخدام الأدوات | صحة اختيار الأداة، دقة المعاملات |
| الاستدلال متعدد الخطوات | دقة الخطوات الوسيطة، دقة الإجابة النهائية |

ينبغي كبح الرغبة في تلخيص جودة الوكيل برقم واحد. تتبع مقاييس متعددة الأبعاد وبناء بنية تُرسل إنذارات حين يهبط أي مقياس تحت عتبته أكثر فائدة.

---

## اختيار المنصة: MLflow مقابل LangSmith مقابل Arize

المنصات الثلاث جاهزة للإنتاج، لكن نقاط قوتها تختلف.

**MLflow** مفتوح المصدر مما يُتيح الاستضافة الذاتية، ويوفر ميزة إعادة تشغيل الوكلاء في التتبع. يتكامل بسهولة مع سير عمل تتبع تجارب ML القائمة. مناسب للبيئات المؤسسية التي تجد صعوبة في إرسال البيانات خارجياً.

**LangSmith** متكامل عمقاً مع نظام LangChain البيئي. تتميز بآثار عالية الدقة تُصيّر شجرة تنفيذ الوكيل الكاملة. توفر إدارة التلقين والتقييم معاً.

**Arize AI** تتميز بتتبع على مستوى النطاق ولوحات بيانات فورية على نطاق مؤسسي. تُتيح مكتبة Phoenix مفتوحة المصدر البدء من بيئة التطوير المحلية.

تدعم المنصات الثلاث التكامل مع الأطر الرئيسية مثل LangGraph وOpenAI Agents SDK وCrewAI.

---

## أنماط تصحيح الأخطاء في الإنتاج

### إعادة إنتاج آثار الإخفاق

لإعادة إنتاج إخفاق الوكيل محلياً، يلزم حفظ لقطة من الحالة الكاملة عند الإخفاق (الاستعلام الأولي، جميع نتائج استدعاءات الأدوات، حالة الذاكرة). يُتيح تشغيل الوكيل ذاته محلياً بهذه اللقطة إعادة إنتاج الإخفاق.

توفر MLflow لهذا الغرض ميزة إعادة تشغيل الوكلاء: يمكن اختيار نطاق معين من الأثر وإعادة تشغيل التنفيذ من تلك النقطة.

### رصد انجراف السياق

نمط إخفاق متكرر في الوكلاء طويلة التشغيل: نسيان الوكيل هدفه الأولي أو تصرفه بما يناقض المعلومات التي جمعها سابقاً.

مقاييس التشخيص: تتبع نسبة استخدام نافذة السياق، وقياس التشابه الدلالي بين التعليمات الأولية والسلوك الراهن للوكيل، وتتبع مدى اختلاف أنماط استدعاء الأدوات عن الخطوات السابقة.

### تصنيف أنماط أخطاء الأدوات

لا تكتفِ بالنظر إلى معدل الخطأ الكلي لاستدعاءات الأدوات، بل صنّفها حسب النوع:

- **أخطاء المعاملات**: الوكيل يُمرر مدخلات بتنسيق خاطئ للأداة. السبب عادة غموض مواصفة الأداة أو وصف سيئ لأسلوب استخدامها في تلقين الوكيل.
- **انتهاء المهلة**: شائع في الأدوات المعتمدة على APIs خارجية. يستلزم منطق إعادة المحاولة وقاطع الدائرة.
- **أخطاء الصلاحيات**: الوكيل يحاول استدعاء أداة تتجاوز نطاق صلاحياته.

مشاهدة تكرار كل نوع جنباً إلى جنب مع سياق الوكيل تكشف الأسباب الجذرية المنهجية.

---

## ترتيب بناء قابلية المراقبة

بناء منظومة كاملة من الصفر يستغرق وقتاً طويلاً؛ المقاربة التدريجية أكثر واقعية.

**المرحلة 1**: تسجيل عدد الرموز وزمن الاستجابة لكل استدعاء LLM. يكفي هذا لفهم التكاليف وتحديد نقاط الاختناق.

**المرحلة 2**: إضافة نطاقات استدعاء الأدوات. يُوضّح أي الأدوات يُخفق وبأي معدل.

**المرحلة 3**: تغليف تنفيذ الوكيل بأكمله في نطاق جذر وبناء شجرة متشعبة.

**المرحلة 4**: بناء مجموعة بيانات تقييم دون اتصال للمهام الأساسية ودمجها في CI.

**المرحلة 5**: إضافة تقييم متصل قائم على أخذ عينات من آثار الإنتاج.

لا تُحاول تنفيذ المراحل الخمس دفعة واحدة؛ استقرار المرحلتين الأولى والثانية أولاً ثم البناء التدريجي هو النهج المستدام.

---

## خلاصة

تشغيل وكلاء الإنتاج بلا قابلية مراقبة يشبه قيادة طائرة بلا أجهزة قياس: يبدو الأمر على ما يرام حين تسير الأمور حسناً، لكن حين يحدث خطأ لا توجد طريقة لمعرفة مصدره.

التتبع وإسناد التكاليف وحلقات التقييم ليست اختيارية بل هي متطلبات تشغيلية لوكلاء الإنتاج. لا بأس بالبدء بسيطاً؛ لكن البدء بلا أي منظومة بنية على تأجيلها لاحقاً يعني الوقوع في الاضطرار إلى بناء البنية التحتية بعد تراكم أنماط الإخفاق.

---

<!-- evolve-refs -->
## المراجع

- [MLflow Tracing](https://mlflow.org/docs/latest/genai/tracing/)
- [LangSmith](https://docs.langchain.com/langsmith)
- [Arize Phoenix](https://github.com/Arize-ai/phoenix)
- [OpenTelemetry GenAI Semantic Conventions](https://github.com/open-telemetry/semantic-conventions-genai)
