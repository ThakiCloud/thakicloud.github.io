---
title: "ربط Claude Code بنماذج مفتوحة مستضافة ذاتياً: تشريح وسيط free-claude-code"
excerpt: "وكلاء البرمجة مثل Claude Code وCodex مرتبطون بشكل وثيق بواجهة برمجة تطبيقات Anthropic. يضع free-claude-code وسيطاً متوافقاً مع Anthropic بين الطرفين، فتحتفظ الفرق بنفس واجهة الوكيل بينما توجَّه الطلبات إلى خلفيات مستضافة ذاتياً مثل Ollama وllama.cpp وvLLM. نستعرض المستودع الفعلي وكيف يتيح اختيار أحد 24 مزوداً من واجهة إدارة، وتوجيه حركة Opus وSonnet وHaiku إلى نماذج مختلفة، ثم نوضح دلالة ذلك بالنسبة لـThakiCloud من زاوية وكلاء البرمجة الداخليين (on-premise)."
tags:
  - llmops
  - claude-code
  - proxy
  - self-hosting
  - ollama
  - vllm
  - agent
  - paxis
date: 2026-07-12
lang: ar
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/claude-code-open-model-proxy/"
categories:
  - llmops
---

## نظرة عامة

أصبح Claude Code وCodex خلال العام الماضي من أكثر وكلاء البرمجة استخداماً داخل الطرفيات وبيئات التطوير المتكاملة. المشكلة أن كلا الوكيلين مرتبط ارتباطاً وثيقاً بواجهة برمجة تطبيقات سحابية واحدة، Anthropic بالنسبة لأحدهما وOpenAI للآخر. بالنسبة للفرق التي لا تستطيع، بموجب سياسات داخلية، إرسال الكود المصدري إلى واجهة خارجية، أو التي تعمل ضمن شبكات معزولة، أو التي تُشغّل بالفعل نماذج مفتوحة الأوزان على وحدات معالجة رسومية خاصة بها، يتحول هذا الارتباط إلى جدار حقيقي.

هذا المقال موجّه لقادة الهندسة الذين يوازنون بين تكلفة تشغيل وكلاء البرمجة وسيادة البيانات، وللممارسين الذين يسعون لتقديم النماذج داخل بنيتهم التحتية الخاصة. تناولنا بالفحص وسيطاً مفتوح المصدر يُدعى `free-claude-code` أثار اهتماماً واسعاً في مجتمعات المطورين مؤخراً، وذلك بالرجوع إلى المستودع الفعلي مباشرة. عُرف هذا المشروع بشعار تسويقي مثير للجدل نوعاً ما حول "التخلص من الاشتراك"، لكن الجانب المثير تقنياً يكمن في مكان آخر. فهو يحافظ على تجربة استخدام وكيل مُثبَت الجدارة، هو Claude Code، بينما يستبدل فقط النموذج القابع خلفه ببنية تحتية خاصة.

وللإيجاز منذ البداية: القيمة الجوهرية لهذا الوسيط ليست "المجانية" بل "العزل". فصل واجهة الوكيل عن خلفية النموذج يتيح نقل نفس سير العمل إلى نموذج مفتوح يعمل على وحدات معالجة رسومية داخلية. نستعرض هنا سبب أهمية هذا الفصل من منظور من يُشغّل بنية تحتية للذكاء الاصطناعي داخل مؤسسته، والقيود التي يجب أخذها بعين الاعتبار معه.

## ما هذه الأداة

`free-claude-code` هو خادم وسيط محلي مبني على FastAPI. يوفر نقطة نهاية متوافقة مع واجهة برمجة تطبيقات Anthropic، لذا فإن Claude Code CLI وCodex CLI وامتدادات VS Code وJetBrains ACP، وحتى بعض روبوتات المحادثة، تظنه خادم Anthropic الحقيقي وتتصل به مباشرة. من منظور الوكيل لم يتغير شيء، فقط النموذج الذي يعالج الطلب فعلياً هو الذي يُستبدَل من خلف الكواليس.

ما يميز هذا المشروع هو اتساع نطاق الخلفيات المدعومة. وفقاً لوصف المستودع، يمكن التبديل بين 24 مزوداً بين السحابي والمحلي من واجهة الإدارة، تشمل واجهات برمجة تطبيقات سحابية مثل NVIDIA NIM وOpenRouter وDeepSeek، إلى جانب أوقات تشغيل محلية مثل LM Studio وllama.cpp وOllama. بمعنى آخر، يمكن الاتصال بواجهة تجارية أو بنموذج مفتوح يعمل على وحدة معالجة رسومية خاصة بك.

بنية التوجيه أيضاً ليست مجرد مفتاح تبديل بسيط. يُقسّم Claude Code داخلياً العمل على ثلاث فئات من النماذج حسب الموقف: Opus وSonnet وHaiku. يُرسَل الاستدلال الثقيل إلى Opus، وتُرسَل المهام اليومية إلى Sonnet، ويُرسَل الاستكشاف الخفيف إلى Haiku. يتيح `free-claude-code` تعيين كل من هذه الفئات الثلاث، إضافة إلى حركة الاحتياط (fallback)، إلى نموذج خلفي مختلف. يبقى دعم البث (streaming) واستدعاء الأدوات (tool use) والاستدلال (reasoning) قائماً ضمن حدود ما يدعمه النموذج المستهدف. هذا التوجيه القائم على الفئات يتطابق تماماً مع مبدأ مطبَّق بالفعل داخل ThakiCloud: إرسال الاستكشاف إلى نموذج رخيص، والتنفيذ إلى نموذج متوسط، وحجز النموذج الأغلى لقرارات الهندسة المعمارية فقط.

يمكن تلخيص تدفق الطلب الكامل في المخطط التالي.

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
<div class="d3-arch" data-arch-root id="claudecodeopenmodelproxy-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 713, "height": 622, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 354, "y": 24, "w": 177, "h": 78, "title": ["وكيل البرمجة", "Claude Code / Codex /", "امتداد IDE"]}, {"id": "B", "x": 354, "y": 180, "w": 177, "h": 78, "title": ["وسيط free-claude-code", "FastAPI، نقطة نهاية", "متوافقة مع Anthropic"]}, {"id": "C", "x": 469, "y": 339, "w": 212, "h": 78, "title": ["واجهة الإدارة", "127.0.0.1:8082/admin", "اختيار المزوّد والتحقق منه"]}, {"id": "D", "x": 205, "y": 336, "w": 209, "h": 84, "title": ["توجيه حسب الفئة", "Opus / Sonnet / Haiku /", "احتياطي"]}, {"id": "E", "x": 460, "y": 512, "w": 191, "h": 78, "title": ["خلفيات سحابية", "OpenRouter / DeepSeek /", "NIM"]}, {"id": "F", "x": 214, "y": 512, "w": 191, "h": 78, "title": ["أوقات تشغيل محلية", "Ollama / llama.cpp / LM", "Studio"]}, {"id": "G", "x": 24, "y": 520, "w": 135, "h": 62, "title": ["vLLM داخلي", "عنقود GPU داخلي"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [442, 102, 442, 180]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[509, 258], [575, 297], [575, 297], [575, 339]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[376, 258], [310, 297], [310, 297], [310, 336]]}, {"src": "D", "dst": "E", "kind": "data", "label": "استدلال ثقيل", "curve": [[414, 415], [556, 466], [556, 466], [556, 512]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "مهام يومية", "line": [310, 420, 310, 512], "lx": 310, "ly": 462}, {"src": "D", "dst": "G", "kind": "data", "label": "خدمة ذاتية الاستضافة", "curve": [[205, 420], [92, 466], [92, 466], [92, 520]], "off": "50%"}]});
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
      const container = document.getElementById('claudecodeopenmodelproxy-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'claudecodeopenmodelproxy-1';
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

الفرق عن الطريقة السابقة واضح. حتى الآن، كان تشغيل وكيل برمجة على نموذج مفتوح يعني إما فرع (fork) الوكيل نفسه، أو بناء غلاف واجهة برمجة تطبيقات مختلف يدوياً لكل نموذج. يجمع هذا الوسيط طبقة التحويل هذه في مكان واحد، تاركاً الوكيل دون مساس بينما يتغير النموذج فقط.

## التثبيت والتكامل

يوفر المستودع مسارين للتثبيت. الأول هو تنزيل سكربت التثبيت وتشغيله دفعة واحدة.

```bash
curl -fsSL "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh?raw=1" | sh
```

يجهّز هذا السكربت `free-claude-code` نفسه مع `uv` وPython 3.14. إذا لم يكن Claude Code وCodex مثبّتَين، يتم تثبيتهما أيضاً، وهذا يتطلب وجود npm مسبقاً، أي أن Node.js يجب أن يكون مثبتاً قبل ذلك. تشغيل نفس الأمر مرة أخرى يعمل كتحديث.

لمن يفضّل التثبيت اليدوي، يمكن استنساخ المستودع مباشرة ثم تجهيز ملف البيئة بدلاً من ذلك.

```bash
git clone https://github.com/Alishahryar1/free-claude-code.git
cd free-claude-code
cp .env.example .env
pip install uv
```

بعد تشغيل الوسيط، يمكن فتح واجهة الإدارة المحلية حصراً من المتصفح لاختيار المزوّد والتحقق من الاتصال.

```text
http://127.0.0.1:8082/admin
```

من هذه الشاشة تُدخَل مفاتيح كل مزوّد ويُتحقَّق من حالة الاتصال، ثم يُحدَّد النموذج الذي يوضع في فتحات Opus وSonnet وHaiku والاحتياط. بعد إتمام الإعداد، يكفي تغيير عنوان قاعدة واجهة برمجة التطبيقات في Claude Code ليشير إلى هذا الوسيط. من هنا فصاعداً تُستخدَم أوامر Claude Code المعتادة كما هي، لكن الاستدلال الفعلي يحدث على الخلفية التي حُدِّدت.

## كيف يعمل فعلياً، وما الذي تحقّقنا منه

في هذا التحليل تحققنا من الوثائق العامة للمستودع وسكربت التثبيت فعلياً للتأكد من صحة الأوامر والبنية أعلاه. لكننا لم نقس زمن الاستجابة الفعلي ولا الدقة عبر جميع الخلفيات الأربع والعشرين. أي قياس أداء ذي معنى يجب أن يُجرى بعد تحميل نموذج مفتوح فعلياً على وحدة معالجة رسومية خاصة، والبيئة التي كُتب فيها هذا المقال لا تملك وحدة معالجة رسومية محلية، لذا لم نتمكن من إجراء قياس فعلي للرحلة الكاملة عبر كل خلفية. تجنباً لاختلاق أرقام، لم نُدرج في هذا المقال أي أرقام زمن استجابة أو معدل نقل غير موثَّقة.

في المقابل، هناك حقيقة بنيوية يمكن التحقق منها بوضوح. بما أن الوسيط يعرض نقطة نهاية متوافقة مع Anthropic، فإن الوكيل ليس بحاجة لمعرفة ما هي الخلفية فعلياً. طالما بقي هذا العقد قائماً، فإن تبديل الخلفية من Ollama إلى نشر vLLM داخلي لا يتطلب أكثر من إعادة تعيين فتحة واحدة من واجهة الإدارة. لا حاجة لإعادة تثبيت الوكيل ولا لتغيير سير العمل. اقتراب تكلفة هذا التبديل من الصفر هو نقطة القوة الفعلية في هذه البنية.

من المهم أيضاً تسجيل الحقيقة الموضوعية بخصوص الجودة. جودة البرمجة عند الاتصال بنموذج مفتوح ليست مماثلة لنماذج Anthropic العليا. وقد تظهر الفجوة تحديداً في سلاسل استدعاء الأدوات الطويلة أو عمليات إعادة الهيكلة المعقدة. لذا فالأدق فهم هذا الوسيط لا بوصفه "أداة تحافظ على الجودة مجاناً" بل بوصفه "أداة تتيح للفريق نفسه اختيار نقطة التوازن بين الجودة والسيادة".

## دلالات لمنتجات ThakiCloud

السؤال الذي تطرحه هذه الأداة يتقاطع تماماً مع المشكلة التي تحلها ThakiCloud عبر منتجين.

أولاً، من زاوية **Paxis**. Paxis هو مستوى التحكم الخاص بـThakiCloud لسحابة موجَّهة بالوكلاء (Agent-Native Cloud)، حيث تُعامَل المهارات والأدوات والسياسات وسجلات التدقيق كموارد من الدرجة الأولى. الفصل بين واجهة الوكيل وخلفية النموذج الذي يُظهره `free-claude-code` هو نسخة مصغرة من الاتجاه الذي تسعى إليه Paxis. في Paxis، لا يُترَك توجيه نموذج وكيل البرمجة لاختيار فردي يدوي من واجهة إدارة محلية، بل يمكن ضبطه عبر بوابة سياسات على مستوى المؤسسة بأكملها. أي فريق يرسل أي طلب إلى أي خلفية، وهل يُفرَض إلزامياً أن يُعالَج كود مستودع حساس عبر نموذج داخلي فقط، كل ذلك يُسجَّل في السياسات وسجلات التدقيق. إذا كان وسيط واحد يغيّر إنتاجية الفرد، فإن Paxis ترفع نفس المبدأ إلى مستوى حوكمة المؤسسة. وإذا أُضيفت إلى ذلك موصلات MCP وتنفيذ ضمن بيئة معزولة (sandbox)، يدخل حتى استدعاء الأدوات الخارجية ضمن نطاق التحكم.

ثانياً، من زاوية **ai-platform**. كون هذا الوسيط يدعم Ollama وllama.cpp كأوقات تشغيل محلية يعني، في النهاية، أن على أحدهم أن يقدّم ذلك النموذج المفتوح بشكل موثوق. يكفي Ollama على حاسوب محمول شخصي لعرض توضيحي، لكنه لا يتحمل الحمل الناتج عن فريق كامل يشغّل وكيل برمجة طوال اليوم. تُجدوِل منصة ai-platform الخاصة بـThakiCloud وحدات معالجة الرسومات عبر K8s وKueue، وتقدّم النماذج المفتوحة عبر vLLM في بيئة متعددة المستأجرين. عند توجيه حركة وكيل البرمجة إلى طبقة التقديم هذه، يصبح ممكناً تشغيل وكيل برمجة داخلي بحجم فريق كامل دون سقف قدرة الجهاز الفردي. تنخفض تكلفة التقديم ويصبح التعامل مع الشبكات المعزولة ميزة تنافسية هنا.

يُكمِّل المنظوران أحدهما الآخر. عندما تقدّم ai-platform النماذج المفتوحة بتكلفة منخفضة وموثوقية عالية، تتولى Paxis التحكم في حركة الوكيل فوق ذلك عبر السياسات والتدقيق. التقديم منخفض التكلفة هو ما يصنع جدوى الوكيل اقتصادياً، والحوكمة هي ما يحوّل تلك الجدوى إلى شكل تستطيع المؤسسة استخدامه براحة بال.

## القيود والاعتراضات

أولاً، يجب الإشارة بصراحة إلى مسألة الشروط والأحكام. استخدام عملاء مثل Claude Code أو Codex بطريقة تلتف حول اشتراك مدفوع قد يتعارض مع شروط استخدام كل خدمة. الاستخدام الذي يعتبره هذا المقال ذا معنى يقتصر على السيناريو الداخلي المتمثل في توجيه الحركة إلى نماذج مفتوحة مملوكة ذاتياً أو خلفية واجهة برمجة تطبيقات متعاقَد عليها بشكل قانوني، وليس التفافاً غير مصرَّح به على خدمة مدفوعة. أي مؤسسة تعتزم تبني هذا الحل يجب أن تراجع شروط استخدام كل عميل أولاً.

ثانياً، تتسع سطح الهجوم. الوسيط، بحكم تعريفه، يقف في موقع يعترض كل الحركة بين الوكيل والنموذج، أي الكود المصدري والمطالبات (prompts) بالكامل. أي إعداد وسيط لا يمكن الوثوق به قد يتحول إلى مسار تسريب للكود. لا تتحقق الفائدة إلا عند تشغيله داخل بنية تحتية خاصة وبطريقة قابلة للتدقيق. هذه بالضبط النقطة التي تجعل بوابات السياسات وسجلات التدقيق في Paxis ضرورية.

ثالثاً، هناك عبء يتعلق بالجودة والصيانة. كما ذُكر سابقاً، جودة البرمجة على النماذج المفتوحة تختلف عن أفضل النماذج التجارية، ودعم أربع وعشرين خلفية يعني أيضاً هشاشة أكبر أمام تغييرات واجهات برمجة تطبيقات المزوّدين. عندما تغيّر Anthropic أو أي مزوّد عقد واجهة برمجة تطبيقاته، على الوسيط أن يواكب ذلك. تحميل سير عمل مؤسسة بأكمله على صيانة بمستوى مشروع فردي أمر محفوف بالمخاطر.

وخلاصة القول، تكتسب `free-claude-code` قيمتها الحقيقية حين تُقرأ لا بوصفها شعار "Claude Code مجاني"، بل بوصفها "تجربة مفتوحة المصدر تفصل طبقة النموذج عن وكيل البرمجة". وعندما يلتقي هذا الفصل بالتقديم الداخلي، ينفتح طريق واقعي لتشغيل وكيل برمجة بحجم فريق كامل مع الحفاظ على سيادة البيانات. وما تبنيه ThakiCloud عبر ai-platform وPaxis هو بالضبط تمكين المؤسسة من السير في هذا الطريق بأمان.

## المصادر

- مستودع free-claude-code: [github.com/Alishahryar1/free-claude-code](https://github.com/Alishahryar1/free-claude-code)
- سكربت التثبيت: [scripts/install.sh](https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh)
