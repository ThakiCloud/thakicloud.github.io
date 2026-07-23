---
title: "Is Fine-Tuning Really Dead? A Survival Strategy Read from June 2026's Verified Signals"
excerpt: "As frontier LLMs and agent skills keep improving, the industry has started to feel that fine-tuning is no longer necessary. OpenAI is, in fact, winding down its self-serve fine-tuning API. Yet the very same month produced signals pointing the opposite direction: a 19-day frontier model shutdown, an open-weight license built around the assumption that customers will fine-tune, and a fine-tuning worker beating a frontier model in production at 11 times lower cost. Using only sources published between June 5 and July 5, 2026, we cross-checked what is actually dying and what is actually surviving."
seo_title: "2026 Fine-Tuning Survival Strategy: Domain-Specific Models in the Agent Skill Era - Thaki Cloud"
seo_description: "An analysis built on verified June 2026 data covering OpenAI's fine-tuning API shutdown, Anthropic's export-control outage, NVIDIA Nemotron 3, and the Harvey hybrid case study, laying out the survival conditions for fine-tuning and small models and a model-ownership strategy for the sovereign AI era."
date: 2026-07-05
last_modified_at: 2026-07-05
lang: en
tags:
  - fine-tuning
  - slm
  - sovereign-ai
  - grpo
  - distillation
  - agent-skills
  - llmops
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "flask"
canonical_url: "https://thakicloud.com/tech-blog/en/research/finetuning-survival-strategy-2026/"
categories:
  - research
  - llmops
header:
  teaser: /assets/images/finetuning-survival-strategy-2026-hero.webp
  overlay_image: /assets/images/finetuning-survival-strategy-2026-hero.webp
  overlay_filter: 0.5
---

![Fine-tuning survival strategy hero image]({{ '/assets/images/finetuning-survival-strategy-2026-hero.webp' | relative_url }})

## Introduction: "Don't we not need fine-tuning anymore?"

Anyone building or selling an AI platform today has probably heard some version of this question. Frontier models have gotten so good, and skills plus agent scaffolding let you inject domain knowledge on the fly, so why bother spending the money and time to train a separate model at all? We asked ourselves the same question. So we spent one month, from June 5 to July 5, 2026, checking it against sources published in that window only.

The method was simple. We researched four threads: the case against fine-tuning, the case for its survival, market and vendor moves, and practitioner discourse. Then we took six core claims that carry the most weight for our conclusion and re-verified each one with an independent adversarial check. Four of the six came back confirmed, two came back partially confirmed, and none were refuted. This piece is written using only the facts that survived that verification.

The short version: fine-tuning as a product really is dying. But what is dying is a specific segment, the self-serve SFT API. The same underlying technology is being repackaged into two other products, model ownership and agent worker economics, and in those forms it is actually becoming a premium offering.

## What is actually dying

The most telling event is OpenAI's decision. OpenAI announced on May 7, 2026 that it would block new fine-tuning job creation for new organizations, moved on July 2 to cut off access for organizations inactive for 60 days or more, and plans to fully end new fine-tuning job creation for all customers, including existing active ones, on January 6, 2027. Inference on models that have already been fine-tuned will keep running until the base model itself is deprecated, but the path to training a new one is closing.

The exception clause is worth noting. RFT, reinforcement-learning-based fine-tuning, is being split off into its own track and kept alive through this shutdown. In other words, OpenAI is winding down supervised fine-tuning while preserving high-value customization built on verifiable rewards. Anthropic never opened self-serve fine-tuning on its public API in the first place, and is instead pushing Agent Skills, which load domain knowledge dynamically from a folder structure, as the standard path. Two of the top-tier model vendors are pointing in the same direction.

Pricing tells the same story. The LoRA fine-tuning price war between Together AI and Fireworks AI signals that this segment has already become commoditized, with thin margins. Running a lightweight supervised fine-tune yourself, self-serve, is no longer technically hard, and that is exactly why it has stopped being an attractive business.

## But skills aren't a universal answer either

Contrary to the general feeling, the academic evidence that skills universally replace fine-tuning is still thin. Within this window, the SkillJuror study showed that structuring skills, rather than delivering them flat, raises verification pass rates by 4.1 percentage points. The effect is real, but small. An earlier background paper, SkillsBench, has a more interesting result. Well-curated skills raise average pass rates by 16.2 percentage points, but the variance across domains swings from negative to as much as plus 51.9 percentage points, and performance actually dropped in 16 of 84 tasks. Critically, skills the model wrote for itself showed no benefit on average.

In other words, "skills solve everything" only holds as a conditional claim: it works when a human carefully curates a skill and applies it to the right domain. Skill curation is not free, and there is no guarantee it is always cheaper than fine-tuning. For what it's worth, we could not find a benchmark within this window that directly compares a fine-tuned model against a frontier model equipped with skills on the same task set. That gap remains homework for both camps.

## The month's countersignals

The same month also produced strong signals pointing toward fine-tuning and model ownership. All of the following are independently cross-verified events.

First, the geopolitical risk of depending on a frontier API stopped being theoretical. On June 12, 2026, a US government export-control order forced Anthropic to disable Fable 5 and Mythos 5 globally. Real-time nationality filtering wasn't feasible, so essentially every user was affected, not just customers outside the US, and it took 19 days to lift the restriction. Any company that has put core operations on a single frontier API just learned a 19-day lesson in June.

Second, the open-weight ecosystem is being designed around the assumption that customers will fine-tune. NVIDIA Nemotron 3 Ultra, announced on June 4, is a mixture-of-experts model with 550B total parameters and 55B active, and ships with LoRA SFT, full SFT, and GRPO reinforcement-learning recipes out of the box. Its license, OpenMDW-1.1, explicitly permits commercializing and redistributing fine-tuned derivative models. The license's entire design goal is: own and sell the model you tuned on your own data. On June 29, Palantir and NVIDIA released a sovereign AI bundle built around fine-tuning open weights and operating them inside air-gapped environments. In the EU, legislation has been proposed to grade public-sector workloads with sovereignty-assurance ratings, and domestic sovereign AI projects are similarly underway.

Third, a fine-tuning worker won in production. In a benchmark published by legal AI company Harvey together with Fireworks, a standalone Kimi K2.6 model with only SFT applied hit a 15% overall pass rate across 100 tasks, beating a standalone Claude Opus 4.7 at 14%, at roughly 11.4 times lower cost. A hybrid configuration that selectively escalates to a frontier model from a fine-tuned worker scored highest at 18%. It's a vendor-run benchmark, so there's a limit to how far it generalizes, but it's real-world evidence that combining a fine-tuned worker with selective frontier escalation can win on quality and cost at the same time in a narrow domain.

Fourth, small models still reproduce a domain advantage. In a paper published June 11, a Mistral-7B model fine-tuned with QLoRA showed up to a 12-percentage-point F1 advantage over GPT-4o and GPT-5 on biomedical claim verification. It was trained on just 1,008 samples.

## The market is splitting into three tracks

Layering these signals together, the market isn't a binary story of dying versus surviving. It's splitting into three tracks.

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
<div class="d3-arch" data-arch-root id="ningsurvivalstrategy2026-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 802, "height": 618, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 319, "y": 24, "w": 156, "h": 62, "title": ["Fine-tuning market", "2026 realignment"]}, {"id": "B", "x": 586, "y": 172, "w": 156, "h": 62, "title": ["Track 1", "Self-serve SFT API"]}, {"id": "C", "x": 305, "y": 164, "w": 184, "h": 78, "title": ["Track 2", "Owned sovereign custom", "models"]}, {"id": "D", "x": 28, "y": 164, "w": 205, "h": 78, "title": ["Track 3", "RL fine-tuning and worker", "economics"]}, {"id": "B1", "x": 558, "y": 344, "w": 212, "h": 78, "title": ["In decline", "OpenAI phased shutdown", "LoRA price commoditization"]}, {"id": "C1", "x": 291, "y": 320, "w": 212, "h": 126, "title": ["Going premium", "Air-gapped fine-tuning", "products", "Sovereignty-rating", "legislation", "Fine-tuning-first licenses"]}, {"id": "D1", "x": 24, "y": 336, "w": 212, "h": 94, "title": ["New growth", "RFT kept as separate track", "Fine-tuning worker +", "frontier escalation"]}, {"id": "E", "x": 168, "y": 524, "w": 191, "h": 62, "title": ["Model ownership becomes", "the product"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[475, 75], [664, 125], [664, 125], [664, 172]]}, {"src": "A", "dst": "C", "kind": "data", "line": [397, 86, 397, 164]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[319, 75], [130, 125], [130, 125], [130, 164]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [664, 234, 664, 344]}, {"src": "C", "dst": "C1", "kind": "data", "line": [397, 242, 397, 320]}, {"src": "D", "dst": "D1", "kind": "data", "line": [130, 242, 130, 336]}, {"src": "C1", "dst": "E", "kind": "data", "curve": [[397, 446], [397, 485], [397, 485], [323, 524]]}, {"src": "D1", "dst": "E", "kind": "data", "curve": [[130, 430], [130, 485], [130, 485], [204, 524]]}]});
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
      const container = document.getElementById('ningsurvivalstrategy2026-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ningsurvivalstrategy2026-1';
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

Track 1, the self-serve SFT API, is in decline. Long context, native tool calling, and structured output from frontier models have absorbed much of what used to justify fine-tuning: format compliance and domain vocabulary. Track 2, owned custom models, is being reorganized as a premium service. The era of lightly tuning a model through an API is ending, but heavy customization where a company owns and controls its own model is actually getting more expensive, not less. Track 3 is new demand created by the agent era. As orchestrators get better, the volume of calls handled by low-cost workers on repetitive subtasks keeps rising, and calling a frontier model for every one of those slots is simply unaffordable.

## Five conditions where fine-tuning clearly wins

Rolling the verified cases into a pattern, fine-tuning's odds and its return on investment both rise the more these conditions overlap:

1. A narrow, repetitive task with a fixed output format. Classification, verification, and structured extraction are the classic cases, and this is exactly the pattern behind the 12-point advantage from just 1,008 samples.
2. A verifiable reward exists. If there's environmental feedback that lets you apply GRPO or RFT, that beats supervised learning, and it's also why OpenAI kept RFT alive while winding down SFT.
3. Call frequency is high and cost and latency are the dominant constraints. Agent worker slots fall squarely here, and an 11.4x cost gap becomes decisive as it scales.
4. There are data sovereignty, regulatory, or air-gapped network requirements. Public sector, finance, and defense are constrained to a limited set of external API options from the outset.
5. The frontier API itself is a supply risk. As the 19-day shutdown showed, export controls and policy changes are no longer a hypothetical scenario.

Conversely, we found no evidence in this window that fine-tuned models beat frontier models on open-domain reasoning, up-to-date knowledge, or long-tail handling. The honest call there is to cede that ground to skills and frontier models.

## Implications for ThakiCloud's products

This realignment lines up precisely with where our two products are headed.

From the ai-platform angle, what tracks 2 and 3 ultimately demand is training and serving infrastructure that runs inside a customer's air-gapped network. ThakiCloud's ai-platform runs five training pipelines, SFT, CPT, DPO, GRPO, and GKD, on top of Kubernetes and Kueue-based GPU scheduling. It was an important confirmation for us that the two axes the market is starting to pay a premium for, GRPO built on verifiable rewards and distillation that moves frontier output down into a smaller model, are exactly where we've been building. As on-premises and sovereignty requirements grow, fine-tuning stops being an API feature and becomes an infrastructure capability, and that's precisely where we're positioned.

From the Paxis angle, this conclusion draws a clean line between the role of skills and the role of fine-tuning. Paxis is ThakiCloud's control plane for the Agent-Native Cloud, selecting from over 960 skills via BM25, running them in isolated sandboxes, and routing every action through policy gates and audit logging. The lesson from the skills benchmarks, that skills only help when well curated and that self-generated skills can't be trusted, validates the direction Paxis has been investing in: skill curation and verification loops. At the same time, the Harvey case's pattern, that a fine-tuned worker is the economical choice for an agent fleet's repetitive subtasks, shows that skill-based orchestration and fine-tuned workers aren't competitors, they're two layers of the same architecture. It's a design that spends the frontier model sparingly rather than discarding it.

## Limitations and counterarguments

We should also lay out the scenarios where this analysis could be wrong. The strongest counterargument is the pace of progress in text-space optimization. We classified it as background research, but Microsoft Research's SkillOpt achieved a 19 to 25 percentage point performance gain purely by optimizing skill documents through rollout-based tuning, without touching model weights at all. If this line of work matures, it could erode even fine-tuning's last stronghold: accuracy on narrow tasks. Even in that scenario, what survives isn't the training capability itself but the infrastructure contract for serving and operating customer-owned models inside air-gapped networks. In fact, this window's market signals already show value shifting from the training layer toward the serving layer.

Another limitation is in the data itself. The Harvey benchmark is a vendor's own announcement, and we couldn't obtain quantitative market data within this window that directly shows fine-tuning demand rising or falling. It's also worth distinguishing that OpenAI's shutdown is a supply-side decision, not direct evidence of falling demand.

## Closing

The feeling that "fine-tuning isn't necessary anymore" is only half right. Commodity SFT really is fading, but the verified events of June 2026 show fine-tuning being reorganized around two other directions: model ownership and worker economics. It's time to change the question. Not "should we fine-tune," but "under what conditions should we own the model" is, we think, the right question for the second half of 2026.

## References

- [NVIDIA Debuts Nemotron 3 Family of Open Models (NVIDIA Newsroom, 2026-06-04)](https://nvidianews.nvidia.com/news/nvidia-debuts-nemotron-3-family-of-open-models)
- [Nemotron 3 Ultra Technical Report (arXiv:2606.15007)](https://arxiv.org/pdf/2606.15007)
- [Small LLMs for Biomedical Claim Verification (arXiv:2606.12854, 2026-06-11)](https://arxiv.org/abs/2606.12854)
- [US orders Anthropic to disable AI models for all foreign nationals (Al Jazeera, 2026-06-13)](https://www.aljazeera.com/news/2026/6/13/us-orders-anthropic-to-disable-ai-models-for-all-foreign-nationals)
- [Anthropic says Trump admin has lifted export controls (CNBC, 2026-06-30)](https://www.cnbc.com/2026/06/30/anthropic-says-trump-admin-has-lifted-export-controls-on-claude-fable-5-and-mythos-5.html)
- [SAGE-OPD: Selective On-Policy Distillation (arXiv:2606.19659, 2026-06-17)](https://arxiv.org/abs/2606.19659v1)
- [SkillJuror (arXiv:2606.11543, 2026-06)](https://arxiv.org/abs/2606.11543)
- [How Harvey & Fireworks Beat Closed Source on Cost + Quality (Fireworks AI Blog)](https://fireworks.ai/blog/open-source-agents-frontier-advisors)
- [OpenAI is winding down the fine-tuning API (OpenAI Developer Community)](https://community.openai.com/t/openai-is-winding-down-the-fine-tuning-api-and-platform-discussion-thread/1380522)
- [Linux Foundation Releases OpenMDW-1.1 (Linux Foundation, 2026-05-28)](https://www.linuxfoundation.org/press/linux-foundation-releases-openmdw-1.1-nvidia-adopts-openmdw-for-cosmos-isaac-gr00t-ising-and-nemotron-ai-model-families)
- [SkillsBench (arXiv:2602.12670, background)](https://arxiv.org/abs/2602.12670)
- [SkillOpt: Agent skills as trainable parameters (Microsoft Research, background)](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/)
