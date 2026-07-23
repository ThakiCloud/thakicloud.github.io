---
title: "ربط Claude Code بالنماذج المستضافة ذاتياً باستخدام free-claude-code: اختبار ميداني لبروكسي التوجيه بين 17 مزوداً"
excerpt: "يعترض free-claude-code (36.7k نجمة) حركة مرور Claude Code عبر بروكسي FastAPI متوافق مع Anthropic ويوجهها إلى 17 مزوداً. يوثق هذا التقرير التوجيه المباشر إلى خلفية Ollama محلية مع قياسات للتأخر، ويسجل بصدق مخاطر النشر الناجمة عن اشتراط Python 3.14 بشكل صارم."
seo_title: "توجيه free-claude-code ذاتي الاستضافة - بروكسي Claude Code متعدد المزودين - Thaki Cloud"
seo_description: "توثيق عملي لتوجيه Claude Code إلى نماذج مستضافة ذاتياً مثل Ollama وvLLM باستخدام free-claude-code. يشمل بنية بروكسي FastAPI المتوافقة مع Anthropic، وقياسات تأخر Ollama المحلية، ومخاطر النشر من اشتراط Python 3.14 الصارم، محللةً من منظور بيئة Kubernetes في ThakiCloud."
date: 2026-06-24
last_modified_at: 2026-06-24
tags:
  - free-claude-code
  - Claude Code
  - LLM Gateway
  - Model Routing
  - Ollama
  - vLLM
  - Self-Hosting
  - FastAPI
  - LLM Ops
author_profile: true
toc: true
toc_label: "المحتويات"
canonical_url: "https://thakicloud.com/tech-blog/ar/llmops/free-claude-code-router/"
categories:
  - llmops
published: false
---

## نظرة عامة

Claude Code عميل برمجي قوي. غير أن بنيته القائمة على توجيه كل طلب مباشرةً إلى Anthropic API تُقيّد المؤسسات الراغبة في ضبط التكاليف أو إبقاء البيانات داخل حدودها. يعالج مشروع `free-claude-code` الذي شهد انتشاراً واسعاً مؤخراً هذه النقطة بالذات؛ إذ يُمثّل طبقة بروكسي تعترض حركة مرور Claude Code وتعيد توجيهها إلى 17 مزوداً مختلفاً. وهو مشروع مرخص بـ MIT يحمل 36.7k نجمة على GitHub و5.7k تفرع و712 إيداعاً.

شعار المشروع التسويقي هو "Claude Code مجاناً إلى الأبد." يعمل النهج عبر تحويل حركة المرور نحو مزودين ذوي فئة مجانية أو منخفضة التكلفة، وهذا الإطار مبالغ فيه إلى حد ما وينطوي على منطقة رمادية من حيث شروط الخدمة. لذا يركز هذا المقال لا على زاوية "المجاني"، بل على ما يعنيه هذا الأداة للمؤسسات كـ ThakiCloud التي **تخدم نماذجها الخاصة على Kubernetes وتريد ربط Claude Code ببنيتها التحتية الخاصة**. النقاط الجوهرية هي أن الكود والمطالبات لا تغادر حدود المستأجر، وتختفي فواتير السحابة المحسوبة لكل رمز، ولا حاجة لتعديل جانب العميل لأن نقطة النهاية متوافقة مع Anthropic.

> ملاحظة: ركّز المقال السابق "توجيه Claude Code إلى النماذج الداخلية - claude-code-router" على **المراجحة في التكاليف** بين نماذج السحابة (glm وMiniMax وKimi). يتناول هذا المقال أداةً مختلفة (`free-claude-code`)، ويعالج الاتصال بـ **الخلفيات المستضافة ذاتياً (Ollama وvLLM)** لا بالسحابة، إلى جانب مخاطر النشر التي كشفها هذا المسار.

## ما الذي يفعله هذا الأداة

`free-claude-code` خادم بروكسي محلي يستقبل الطلبات التي يرسلها Claude Code (وCodex). ميزته الجوهرية أنه **يحاكي نقطة نهاية متوافقة مع Anthropic بشكل كامل**. من منظور العميل، لا يمكن تمييزه عن Anthropic API الحقيقية، مما يتيح تبديل الخلفية دون تغيير سطر واحد في Claude Code.

الخادم مكتوب بـ FastAPI ويكشف نقاط النهاية التالية:

- `/v1/messages` - متوافق مع Anthropic Messages API (المسار الرئيسي لـ Claude Code)
- `/v1/models` - قائمة النماذج
- `/v1/responses` - متوافق مع OpenAI Responses API (لـ Codex؛ يُحوَّل داخلياً إلى Messages)

عند وصول طلب، يقرر **موجّه النماذج** أي مزود يرسل إليه الطلب، ثم يحوّل **المُوحِّد** كتل التفكير وأدوات الاستدعاء واستجابات الخطأ إلى الشكل الذي يتوقعه كل عميل. نظراً لاختلاف صيغ الاستجابة بين المزودين، تكمن في طبقة التوحيد هذه الصعوبة الحقيقية.

لنتوسع قليلاً في سبب صعوبة التوحيد: يفترض Claude Code بنية استجابة خاصة بـ Anthropic؛ فخطوات الاستدلال تأتي ككتل `thinking`، واستدعاءات الأدوات ككتل محتوى `tool_use`. لكن DeepSeek يُصدر الاستدلال كحقل منفصل، في حين تُعيد المزودين المتوافقين مع OpenAI استدعاءات الأدوات كمصفوفة `tool_calls`. المعنى واحد وهو "استُدعيت أداة"، لكن صيغة السلك تختلف في كل حالة. يجب على المُوحِّد استيعاب هذه الفوارق وضمان حصول Claude Code على استجابات بشكل متطابق بغض النظر عن الخلفية المستخدمة. يذهب مسار Codex (`/v1/responses`) خطوة أبعد بتحويل طلبات OpenAI Responses داخلياً إلى Anthropic Messages قبل مشاركة الموجّه والمُوحِّد ومحوّلات المزودين ذاتها. أي أن تحويل البروتوكول يجري في الاتجاهين — وهذا هو الفارق الجوهري بين البروكسي العكسي البسيط وبروكسي التوجيه.

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
<div class="d3-arch" data-arch-root id="0624freeclaudecoderouter-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 500, "height": 904, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "CC", "x": 299, "y": 24, "w": 120, "h": 62, "title": ["Claude Code", "(العميل)"]}, {"id": "CX", "x": 63, "y": 24, "w": 120, "h": 62, "title": ["Codex", "(العميل)"]}, {"id": "FP", "x": 177, "y": 304, "w": 128, "h": 62, "title": ["بروكسي FastAPI", "(خادم محلي)"]}, {"id": "EP1", "x": 277, "y": 164, "w": 163, "h": 62, "title": ["/v1/messages", "متوافق مع Anthropic"]}, {"id": "EP2", "x": 24, "y": 164, "w": 198, "h": 62, "title": ["/v1/responses", "متوافق مع OpenAI → تحويل"]}, {"id": "MR", "x": 143, "y": 444, "w": 195, "h": 84, "title": ["موجّه النماذج", "MODEL_OPUS / SONNET /", "HAIKU"]}, {"id": "NZ", "x": 149, "y": 606, "w": 184, "h": 78, "title": ["طبقة التطبيع", "(thinking · tool_use ·", "تحويل الأخطاء)"]}, {"id": "CLOUD", "x": 263, "y": 762, "w": 205, "h": 110, "title": ["مزودو السحابة", "NVIDIA NIM · OpenRouter ·", "Gemini", "DeepSeek · Mistral · Groq", "+ 8 آخرون"]}, {"id": "SELF", "x": 24, "y": 778, "w": 184, "h": 78, "title": ["خلفيات ذاتية الاستضافة", "Ollama · LM Studio", "llama.cpp / vLLM"]}], "edges": [{"src": "CC", "dst": "EP1", "kind": "data", "line": [359, 86, 359, 164]}, {"src": "CX", "dst": "EP2", "kind": "data", "line": [123, 86, 123, 164]}, {"src": "EP1", "dst": "FP", "kind": "data", "curve": [[359, 226], [359, 265], [359, 265], [293, 304]]}, {"src": "EP2", "dst": "FP", "kind": "data", "curve": [[123, 226], [123, 265], [123, 265], [189, 304]]}, {"src": "FP", "dst": "MR", "kind": "data", "line": [241, 366, 241, 444]}, {"src": "MR", "dst": "NZ", "kind": "data", "line": [241, 528, 241, 606]}, {"src": "NZ", "dst": "CLOUD", "kind": "data", "curve": [[303, 684], [366, 723], [366, 723], [366, 762]]}, {"src": "NZ", "dst": "SELF", "kind": "data", "curve": [[178, 684], [116, 723], [116, 723], [116, 778]]}]});
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
      const container = document.getElementById('0624freeclaudecoderouter-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0624freeclaudecoderouter-1';
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
*يعترض بروكسي FastAPI طلبات Claude Code وCodex ويوجّهها حسب مستوى النموذج إلى 17 مزوداً. انقر المخطط لتكبيره.*

المزودون المدعومون 17 مزوداً. على الجانب السحابي: NVIDIA NIM وOpenRouter وGoogle AI Studio (Gemini) وDeepSeek وMistral La Plateforme وMistral Codestral وOpenCode Zen وOpenCode Go وWafer وKimi وCerebras وGroq وFireworks وZ.ai. على **جانب الاستضافة الذاتية: LM Studio وllama.cpp وOllama**. الثلاثة الأخيرة هي ذات الأهمية من منظور ThakiCloud. إذ يكشف Ollama وllama.cpp نقاط نهاية متوافقة مع OpenAI، مما يعني أن خادم vLLM المنشور بالطريقة ذاتها على Kubernetes يمكن ربطه بنفس الأسلوب.

يتحكم في توجيه الفئات عبر متغيرات البيئة. يحدد كل من `MODEL_OPUS` و`MODEL_SONNET` و`MODEL_HAIKU` أي نموذج يُوجَّه إليه كل فئة من فئات Claude الثلاث؛ وعند غياب التحديد يُستخدم النموذج الاحتياطي `MODEL`. يتيح هذا نشراً متدرجاً، كتوجيه حركة مرور Haiku الخفيفة إلى نماذج صغيرة والحركة الثقيلة من Opus إلى نماذج أكبر.

## التثبيت والتكامل

مسار التثبيت الرسمي هو سطر أوامر واحد:

```bash
# macOS / Linux
curl -fsSL "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh?raw=1" | sh

# Windows PowerShell
irm "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.ps1?raw=1" | iex
```

بدلاً من سطر الأوامر، تحققت من الحزمة بتثبيتها مباشرةً في بيئة اختبار معزولة، حفاظاً على سلامة البيئة الافتراضية المشتركة وفق قواعد وقت تشغيل Python في ThakiCloud.

```bash
# شجرة عمل معزولة + venv مؤقت (البيئة المشتركة .venv على 3.12.8 وستتعارض)
uv venv --python 3.14 .expenv
VIRTUAL_ENV=.expenv uv pip install "git+https://github.com/Alishahryar1/free-claude-code.git"
```

تُثبَّت الحزمة ذاتها بنظافة. تُحلّ التبعيات مثل fastapi وuvicorn وhttpx وpydantic وopenai وloguru بنجاح، وتُنشأ سكريبتات وحدة التحكم مثل `fcc-server` و`fcc-init` و`fcc-claude`. بعد تشغيل الخادم، يُوجَّه Claude Code نحو البروكسي على النحو الآتي:

```bash
fcc-server            # تشغيل بروكسي FastAPI (الافتراضي http://127.0.0.1:8082)
# مثال على خلفية مستضافة ذاتياً (Ollama):
#   MODEL_HAIKU=ollama/llama3.2:3b
#   MODEL_SONNET=ollama/qwen2.5:7b
# حدد عنوان URL الأساسي لتوجيه Claude Code نحو البروكسي ثم استخدمه كالمعتاد
```

واجهة الإدارة متاحة على `http://127.0.0.1:8082/admin` وتكون محدودة بحلقة الاسترداد فقط. تُدار هنا مفاتيح المزودين وتوجيه النماذج وإعدادات الرسائل والصوت.

## نتائج التجربة الفعلية

خلال عملية التحقق، واجهت **نقطة أعاقت إعادة الإنتاج**، وأسجلها كما هي. عدم اختلاق الأرقام مبدأ راسخ في هذا التقرير.

### حاجز التشغيل: الاشتراط الصارم بـ Python 3.14

يُثبّت `free-claude-code` الإصدار v2.3.14 اشتراط `requires-python = ">=3.14.0"` بشكل صارم. Python 3.14 هو الإصدار الأحدث الذي صدر رسمياً في أكتوبر 2025 فحسب. المشكلة أن الإصدار 3.14 الوحيد المتاح في بيئة الاختبار كان بناء ألفا (3.14.0a7). تشغيل `fcc-server` على هذا الإصدار الألفا يفشل بالخطأ التالي:

```text
ImportError: cannot import name 'get_annotate_from_class_namespace'
from 'annotationlib'
```

يحدث هذا التعارض لأن pydantic المثبّت يتوقع واجهة `annotationlib` الخاصة بالإصدار النهائي 3.14، لكن الرمز المطلوب غير موجود بعد في الإصدار الألفا المبكر. حاولت عندئذٍ التشغيل قسراً على الإصدار المستقر الأدنى (3.13)، لكن التثبيت ذاته يُرفض بسبب الاشتراط الصارم في بيانات الحزمة:

```text
free-claude-code==2.3.14 cannot be used ... your requirements are unsatisfiable.
```

الخلاصة واضحة: **في البيئات التي تفتقر إلى Python 3.14 المستقر، لن يعمل هذا البروكسي أبداً.** فشل محاولة إعادة الإنتاج: الحزمة تشترط Python 3.14 الصادر حديثاً، لكن الإصدار 3.14 الوحيد المتاح ألفا يتعارض مع pydantic المثبّت. هذه ليست عيباً في الأداة بقدر ما هي مشكلة **تثبيت إصدار متعجّل** يتعارض مع واقع بيئات الإنتاج التي تبقى في الغالب على 3.11–3.12.

### القياس المباشر لمسار التوجيه المستضاف ذاتياً

رغم أن البروكسي نفسه لم يُشغَّل، فإن **الآلية** التي تستخدمها هذه الأداة لاستدعاء مزود `ollama` هي نقطة النهاية المتوافقة مع OpenAI. لذا قست هذا المسار باستدعاء Ollama المحلي مباشرةً. هذه أرقام أداء التوجيه للخلفية ذاتها دون تضمين الحمل الإضافي للبروكسي الذي ستضيفه fcc. نتائج تعيين فئات Claude الثلاث لنماذج محلية كالآتي (Apple Silicon، مطالبة متطابقة، حد 64 رمزاً):

![نتائج قياس التوجيه المستضاف ذاتياً]({{ '/assets/images/free-claude-code-router-results.webp' | relative_url }})
*الشكل 2. التأخر ومعدل المعالجة عند توجيه فئات Claude إلى نماذج Ollama المحلية. qwen3:8b المُدرج في مسار opus نموذج تفكير يُصدر رموز استدلال مطوّلة مما يزيد الوقت بشكل ملحوظ.*

| التوجيه | النموذج | التأخر | رموز الإكمال | معدل المعالجة |
|---|---|---|---|---|
| haiku | llama3.2:3b | 0.49s | 33 | 67.3 tok/s |
| sonnet | qwen2.5:7b | 0.56s | 20 | 35.7 tok/s |
| opus | qwen3:8b | 8.12s | 281 | 34.6 tok/s |

النموذج الصغير (llama3.2:3b) ينهي استجابته في أقل من 0.5 ثانية، وهو سرعة كافية لحركة مرور بديلة عن Haiku. كذلك qwen2.5:7b عند 0.56 ثانية عملي للاستخدام. في المقابل، استغرق qwen3:8b المُدرج في مسار opus 8.12 ثانية، لأن نموذج التفكير يُصدر أولاً 281 رمز استدلال. معدل المعالجة (34.6 tok/s) طبيعي في حد ذاته، لكن القياس أكد أن **توظيف نموذج استدلالي في فئة ثقيلة يُفجّر عدد الرموز ويزيد التأخر المُدرَك بشكل كبير**. درس عملي: عند تصميم تعيينات الفئات، ينبغي مراعاة ميل النموذج لتوليد رموز الاستدلال.

## التطبيق والدلالات لمنصة ThakiCloud SaaS للذكاء الاصطناعي/تعلم الآلة على Kubernetes

القيمة الحقيقية لهذه الأداة ليست في "المجانية" بل في **نمط الاتصال**. بمجرد إدراج بروكسي متوافق مع Anthropic كطبقة وسيطة، يمكن إرفاق عملاء تجاريين كـ Claude Code مباشرةً ببنيتنا التحتية.

تُجدول ThakiCloud وحدات GPU باستخدام Kueue وتُقدّم النماذج عبر vLLM على Kubernetes. نظراً لأن vLLM يوفر نقطة نهاية متوافقة مع OpenAI (`/v1/chat/completions`)، يمكن ربطها بمسار المزود المستضاف ذاتياً في `free-claude-code` بنفس الطريقة المتبعة مع Ollama أو llama.cpp. أسلوب الاتصال مشترك بين المزودين المستضافين ذاتياً: يُحدَّد عنوان URL الأساسي بنقطة نهاية خدمة vLLM في الكتلة، ويُضاف بادئة المزود إلى معرّف النموذج. تماماً كما تُكتب Ollama بالصيغة `ollama/llama3.2:3b`، يُضاف النموذج المُقدَّم على vLLM الداخلي لأهداف التوجيه باتباع قاعدة البادئة ذاتها. يُتيح ذلك:

- **سيادة البيانات**: لا يغادر الكود والمطالبات حدود المستأجر. هذا أمر جوهري في البيئات التنظيمية مثل النشر داخل المنشأة ومتطلبات الامتثال للأجهزة الحكومية.
- **تحوّل هيكل التكلفة**: تتحوّل فوترة القياس لكل رمز إلى تكاليف GPU ثابتة. كلما ارتفع الاستخدام، تسارعت نقطة التعادل للتقديم الذاتي.
- **النشر المتدرج حسب الفئة**: يمكن توجيه حركة مرور Haiku الخفيفة إلى نماذج صغيرة والأعمال الثقيلة إلى نماذج أكبر، مما يُحسّن الاستفادة من وحدات GPU. تُقدّم القياسات أعلاه الأرقام المرجعية لهذا النشر المتدرج.

غير أن الأنسب بدلاً من اعتماد هذه الأداة كما هي هو **استعارة نمط التوجيه المُتحقَّق منه فحسب**. في بيئة متعددة المستأجرين، يجب أن يمتلك البروكسي مصادقة وعزلاً ومراقبةً لكل مستأجر، في حين تفترض واجهة إدارة `free-claude-code` مستخدماً واحداً في حلقة الاسترداد وهي قاصرة كما هي. الفكرة الكامنة في طبقة التوحيد المتوافقة مع Anthropic تستحق الاستعارة، لكن المصادقة والحصص والتسجيل يجب إعادة تطبيقها وفق معايير بوابتنا.

## القيود والاعتراضات

أولاً، **المنطقة الرمادية لشروط الخدمة**. يعتمد إطار "Claude Code مجاناً" على التوجيه عبر مزودين ذوي فئة مجانية، مما قد يتعارض مع شروط خدمة كل منصة. في البيئات المؤسسية، الاستخدام المشروع والمستدام هو حصراً **التوجيه إلى الخلفيات المملوكة (النماذج المُقدَّمة ذاتياً)**. هذا هو سبب تأكيد هذا المقال على مسار الاستضافة الذاتية فحسب.

ثانياً، **تثبيت الإصدار المتعجّل**. يمنع الاشتراط الصارم بـ Python 3.14 التشغيلَ فوراً في البيئات التي تفتقر إلى وقت تشغيل مستقر كما رأينا. مع الأخذ بعين الاعتبار تكلفة ومخاطر ترقية صور حاويات الإنتاج إلى 3.14، فإن إدراج هذه الأداة مباشرةً في خط أنابيب النشر في الوقت الراهن ينطوي على عبء مفرط.

ثالثاً، **لا يُضمن تكافؤ الجودة**. استبدال Opus أو Sonnet من Claude بنماذج مختلفة لا يُبقي جودة البرمجة على حالها. التوجيه خيار يكسب فيه تكاليف أقل وسيادة بيانات مقابل التنازل عن جودة الاستجابة؛ وأي حركة مرور تُوجَّه إلى أي مكان يجب تحديده بالقياس وفق درجة صعوبة المهمة.

رابعاً، قياسات هذا التقرير هي **أرقام استدعاء مباشر للخلفية دون المرور بالبروكسي**. لا يشمل ذلك الحمل الإضافي للتوحيد والتوجيه في fcc. متى توافرت بيئة Python 3.14 المستقرة، أخطط لإعادة قياس التأخر ذهاباً وإياباً عبر البروكسي وإضافته تكملةً لهذه النتائج.

خلاصة القول، `free-claude-code` محفوف بالمخاطر إذا استُهلك بوصفه "اختراقاً مجانياً"، لكنه نقطة انطلاق ممتازة **كمرجع مفتوح المصدر لأنماط التوجيه المتوافقة مع Anthropic** عند تصميم ربط العملاء التجاريين ببنية الاستدلال المستضافة ذاتياً.

## المصادر

- GitHub: [Alishahryar1/free-claude-code](https://github.com/Alishahryar1/free-claude-code) (MIT, 36.7k stars, v2.3.14)
- بيانات القياس: استدعاءات مباشرة لنقطة النهاية المتوافقة مع OpenAI في Ollama المحلي (llama3.2:3b وqwen2.5:7b وqwen3:8b، Apple Silicon)
- مقال ذو صلة: مدونة ThakiCloud التقنية "توجيه Claude Code إلى النماذج الداخلية - claude-code-router"
