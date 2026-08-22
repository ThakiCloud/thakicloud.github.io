---
title: "Controlling Reasoning Effort - How LLMs Learn Low, Medium, and High Thinking Modes"
excerpt: "With GPT-5.6 shipping five or six reasoning effort settings per size, effort control has become table stakes for reasoning models. We dig into what training recipe sits behind the same labels, drawing on technical reports from six open-weight models to map the shared skeleton."
seo_title: "Controlling Reasoning Effort - How LLMs Learn Low/Medium/High Reasoning Modes - Thaki Cloud"
seo_description: "What is reasoning effort and how is it trained? From effort-conditioned SFT and RLVR length penalties to the training recipes and inference-time budget controls of six open-weight models (DeepSeek V4, Nemotron 3 Ultra, Kimi K2.5, GLM-5, Qwen3, Inkling), we summarize Sebastian Raschka's analysis from a cloud and inference serving perspective."
date: 2026-07-19
last_modified_at: 2026-07-19
canonical_url: "https://thakicloud.com/tech-blog/en/research/controlling-reasoning-effort-in-llms/"
lang: en
reading_time: true
tags:
  - reasoning-models
  - reasoning-effort
  - rlvr
  - test-time-compute
  - inference-cost
  - deepseek-v4
  - qwen3
  - glm-5
  - kimi-k2
  - nemotron
author_profile: true
toc: true
categories:
  - research
published: false
---

If you run inference serving directly, look at GPU budgets, or think about where to attach an expensive model in an agent harness, you have likely run into a setting called "reasoning effort" in recent model release notes more than once. Set it low and things are fast and cheap but the quality suffers; set it high and accuracy improves but tokens and latency balloon. This piece is based on Sebastian Raschka's July 2026 analysis, [Controlling Reasoning Effort in LLMs](https://magazine.sebastianraschka.com/p/controlling-reasoning-effort-in-llms), and unpacks what actually happens behind that setting, and what it takes to train a model to behave that way, from a cloud and inference serving perspective. The bottom line up front: even under the same low/medium/high labels, the training recipe differs from model to model, and there is no single method that can yet be called the correct answer.

## Reasoning models are now the standard, and now you choose the amount of effort

About two years have passed since OpenAI popularized LLM reasoning models with o1, and four months later DeepSeek-R1 opened up the training method itself by publishing a reinforcement learning recipe (RLVR) that uses verifiable rewards. In the time since, reasoning has gone from a special feature to a default building block of new model releases. The GPT-5.6 family released last week ships in three sizes, and each size comes with roughly five or six reasoning effort settings.

A key observation follows from this. Building a reasoning model and letting a user choose how long that model thinks are two separate problems. The former has already been covered extensively, but the latter, namely "how to make the amount of effort a controllable input," is comparatively less well mapped out. In practice, this control capability is a cost lever. If you route easy queries to low effort and reserve high effort only for hard queries, you can raise throughput and quality at the same time on the same GPUs.

## What is reasoning effort

Empirically, raising effort increases the number of tokens generated, and benchmark performance rises along with it. However, this relationship is not linear; the higher the effort tier, the smaller the performance gain per additional token becomes. Thinking Machines' presentation materials for Inkling show exactly this curve: tokens and performance rise together as the effort tier increases, but the gains flatten out in the upper tiers. From a serving standpoint, this means the highest effort setting is not always the best choice.

So how is effort specified at inference time? Surprisingly simply. It is usually controlled with a single line in the system prompt. Even the dropdown menu selection in the ChatGPT UI appears to map internally to a specific system prompt. The problem is that this approach does not work on just any model. The model needs to have been trained so that when it receives an instruction like "effort: low," it actually thinks more briefly while still maintaining quality. In other words, to get easy inference-time control, you have to pay for it by reworking the training pipeline.

## How it is trained: two axes

Whether it is GPT-5.6 or the open-source gpt-oss, the exact training details are not disclosed, but in general the effort label is included inside the prompt during the post-training stage. There are broadly two ways to implement this.

First, during RLVR, you can apply a different length penalty depending on the system prompt. When the setting is "effort: low," a strong length penalty is applied; when it is "effort: high," a weak or absent penalty is applied. This reinforces the model to adjust the length of its thinking on its own, in line with the instructed effort. Second, after RLVR is finished, you can fine-tune with SFT to follow different effort instructions. Here, the training data pairs prompts with target responses that contain the desired amount of reasoning, and those targets may be human-written, generated by another model, or generated and then filtered.

The big picture of both methods looks like this. Most real-world recipes are variations on this skeleton.

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
<div class="d3-arch" data-arch-root id="ingreasoningeffortinllms-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 261, "height": 694, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 52, "y": 24, "w": 149, "h": 46, "title": "베이스 / RLVR 리즈닝 모델"}, {"id": "B", "x": 35, "y": 148, "w": 184, "h": 62, "title": ["1. SFT + chat template", "노력 모드를 입력으로 도입"]}, {"id": "C", "x": 24, "y": 288, "w": 205, "h": 78, "title": ["2. mode-conditioned RL", "노력별 context window·length", "penalty 차등"]}, {"id": "D", "x": 31, "y": 444, "w": 191, "h": 78, "title": ["3. 하드 예산 강건성 학습", "truncated trace·강제 중단 후", "재개·budget toggle"]}, {"id": "E", "x": 28, "y": 600, "w": 198, "h": 62, "title": ["추론: system prompt로 노력 선택", "+ 선택적 토큰 예산"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [127, 70, 127, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [127, 210, 127, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [127, 366, 127, 444]}, {"src": "D", "dst": "E", "kind": "data", "line": [127, 522, 127, 600]}]});
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
      const container = document.getElementById('ingreasoningeffortinllms-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ingreasoningeffortinllms-1';
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

## A deep dive into six open-weight models

Rather than proof-of-concept research, Raschka picked the recipes of six recent open-weight models that have real-world evidence of working. The level of disclosure varies from report to report, but each shows off one useful variation.

### DeepSeek V4: separating effort into distinct experts

The DeepSeek V4 technical report describes three modes. Non-think answers directly with no reasoning trace, Think High is the classic R1-style approach that puts the reasoning trace between `<think>` and `</think>`, and Think Max adds a special system instruction on top of that. The instruction for Think Max begins with "Reasoning Effort: Absolute maximum with no shortcuts permitted." The key idea is to treat different effort levels almost like separate experts and refine them with mode-conditioned RL.

### Nemotron 3 Ultra: combining a trained mode with a hard budget

Nemotron 3 Ultra uses three settings: reasoning-off, regular, and medium-effort. Medium-effort is a cheaper inference mode than regular, and NVIDIA introduces it during the SFT stage using medium-effort outputs from GPT-OSS-120B, then further optimizes it with RLVR. About 2.5% of RLVR prompts correspond to medium-effort, and a length-based reward adjustment is applied there. On top of this, an inference-time token budget can be layered on as an external stop mechanism. It asks the model to finish reasoning near a client-specified limit, and if the model does not emit `</think>` on its own, the client forcibly closes it. So that the answer does not collapse even when cut off this way, the model is trained on randomly truncated traces to secure robustness.

### Kimi K2.5: a Toggle that alternates between budgeted and unconstrained

Kimi K2.5's method, Toggle, starts from the problem that if you only train with a fixed token budget, the model overfits to short solutions and loses the benefit of extra computation. So it alternates between two phases every set number of training iterations. In the budgeted phase, correct solutions are guided to stay within a per-problem token budget, and in the unconstrained phase, the maximum generation length is restored so the model keeps learning from long solutions as well. The budget is estimated from a specific percentile of correct RLVR rollout lengths, but the budget constraint is only turned on once the average accuracy for that problem has crossed a threshold. The goal is to sharply raise token efficiency while keeping overall benchmark performance about the same.

### GLM-5: turn-level, interleaved, and preserved thinking

GLM-5 extends GLM-4.5's binary on/off switch to multi-turn and tool-use scenarios. Its distinguishing feature is that it defines three related behaviors rather than three effort levels. Interleaved thinking places a reasoning block before every response and tool call, preserved thinking keeps prior reasoning blocks around and reusable across multiple turns, and turn-level thinking turns reasoning on and off per request within a conversation. The actual switch at inference time is turn-level. In the Z.ai API it is on by default and can be disabled on individual requests.

### Qwen3: mode fusion and inference-time truncation

Qwen3's post-training pipeline consists of four stages: long-CoT SFT, reasoning RL, Thinking Mode Fusion, and general RL. The core of the on/off effort switch is Thinking Mode Fusion, which performs SFT on a mix of thinking and non-thinking examples. `/think` examples contain a reasoning trace, while `/no_think` examples start with an empty `<think></think>` block followed by a short answer. The general RL that follows reinforces instruction and format adherence in both behaviors. Qwen3 also supports a hard thinking budget, stopping reasoning at a specified threshold, inserting a stop instruction, and then moving on to the final answer. Interestingly, the report notes that this partial-reasoning behavior was not explicitly trained for but emerged after Thinking Mode Fusion. It is simpler than DeepSeek V4 or Nemotron, but it delivers both a trained on/off switch and an inference-time budget together.

### Inkling: system-prompt effort with mode-conditioned RL

Inkling specifies effort via the system prompt, backed by mode-conditioned RL. As seen earlier, it shows the tendency where raising effort increases tokens and performance together but the gains flatten out at the upper tiers, which is a useful reference point for deciding where to cap effort in serving.

## A shared skeleton: same labels, one underlying frame

Lining up the six models side by side reveals a shared framework. First, SFT and the chat template introduce effort mode as an input. Qwen3 explicitly mixes thinking and non-thinking examples, and GLM-5 adds interleaved, preserved, and turn-level patterns on top. Second, in the mode-conditioned RL stage, the context window and length penalty are varied according to the requested effort. DeepSeek V4, Nemotron 3 Ultra, and Inkling use this approach. Third, robustness under an explicit budget is added. Nemotron trains on randomly truncated traces, Qwen3 can resume from a forcibly stopped reasoning point, and Kimi alternates between budgeted and unconstrained RL. These mechanisms preserve answer quality even when the available reasoning length changes or gets cut off mid-way.

The following table summarizes what is actually documented across the six reports.

| Model | Modes / settings | Training mechanism | Inference-time control |
|---|---|---|---|
| DeepSeek V4 | Non-think / Think High / Think Max | Separate effort experts + mode-conditioned RL | System prompt (Think Max adds an instruction) |
| Nemotron 3 Ultra | off / regular / medium | SFT with GPT-OSS-120B outputs + RLVR (about 2.5%) + truncated-trace training | Chat template + external token budget |
| Kimi K2.5 | budgeted / unconstrained | Toggle: alternating two RL phases | Per-problem token budget |
| GLM-5 | turn-level / interleaved / preserved | SFT extended for multi-turn and tool use | Turn-level on/off switch |
| Qwen3 | think / no_think | Thinking Mode Fusion (mixed SFT) + general RL | On/off + hard thinking budget (truncation) |
| Inkling | Multi-tier effort | Mode-conditioned RL | System prompt |

## Conclusion and the ThakiCloud perspective

What these six cases show is that similar labels can be backed by separate experts, mixed SFT data, mode-conditioned rewards, hard token budgets, or some combination of these. It is hard to declare any single method the best. Each model has a different base checkpoint, training data, post-training compute budget, benchmarks, and serving goals, and the reports omit the detail needed for a fair comparison. A method that fits a conversational assistant well could be a poor fit for a long-running coding agent.

The ultimate goal is, of course, automatic selection of effort. GPT-5's Auto mode once attempted exactly that direction, but it was closer to a failure than a success and eventually disappeared from the UI. In the near future, effort will likely remain an explicit model input, usually passed as a system prompt, while the agent harness or an internal router wrapping the LLM increasingly infers the appropriate mode and budget on its own from task state and remaining budget. Of course, a user override would still be kept around for cases that prioritize latency or cost, or that call for maximum performance.

This is exactly where it connects to our platform operations. If inference budget can be treated as a lever, GPU serving cost and latency can be allocated to match query difficulty. Routing easy requests to low effort and saving high effort only for hard requests, combined with Kueue-based GPU scheduling, opens up real room to raise both throughput and quality on the same cluster. In practice, when running an agent harness, it works out better in cost-to-quality terms to reserve expensive reasoning for a handful of steps like verification and synthesis, and to handle exploration and summarization at low effort. Effort control is not a model bragging point but rather a cost-quality lever that teams operating inference infrastructure pull every day, and it is more practical to read this trend from that angle.

The original piece is rich with links to each model's technical report and diagrams, so if you need the detailed recipe for a specific model, we recommend checking [Sebastian Raschka's original article](https://magazine.sebastianraschka.com/p/controlling-reasoning-effort-in-llms) and the corresponding report directly.
