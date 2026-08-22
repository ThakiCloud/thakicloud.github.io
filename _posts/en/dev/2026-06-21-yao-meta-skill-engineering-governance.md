---
title: "Treating Skills Like Software: A Hands-On Verification of yao-meta-skill v1.1.0"
excerpt: "yao-meta-skill, an open-source meta-skill rumored to be more powerful than Anthropic's official Skill-creator, gets cloned into the ThakiCloud environment and put through its local verification gates. We break down Skill IR, the Output Eval Lab, and Review Studio 2.0 with measured numbers, and draw lessons for in-house .claude/skills governance."
seo_title: "yao-meta-skill v1.1.0 Verification Report - Thaki Cloud"
seo_description: "A hands-on report cloning and verifying yao-meta-skill (YAO). We dissect its Skill IR platform-neutral representation, Output Eval Lab, and Review Studio 2.0 governance gates at 632-file/77-test scale, and apply them to ThakiCloud .claude/skills operations."
date: 2026-06-21
last_modified_at: 2026-06-21
tags:
  - claude-skills
  - meta-skill
  - skill-governance
  - skill-ir
  - agent-skills
  - evaluation
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/en/dev/yao-meta-skill-engineering-governance/"
published: false
---

![Abstract modular blocks forming a precision assembly line with glowing governance gates]({{ '/assets/images/yao-meta-skill-hero.webp' | relative_url }})
*A conceptual view of treating skills not as one-off prompts but as reusable assets carrying versioning, verification, and governance.*

## Overview

In agent environments like Claude Code, Cursor, and Codex CLI, a Skill is no longer just a bundle of prompts. It is closer to a capability product that packages repetitive work for reuse across multiple harnesses. But as skills multiply, three problems grow at once: quality variance, trigger collisions, and context cost. yao-meta-skill, an open-source project that went viral after Chinese influencer @vista8 (~113K followers) recommended it as "more powerful than Anthropic's official Skill-creator," takes direct aim at this.

YAO stands for "Yielding AI Outcomes," and the repository describes itself as "a rigorous engineering, evaluation, governance, and portability system for reusable agent skills." Rather than take that claim at face value, I cloned it into a ThakiCloud workspace and actually ran the local verification gates the repo ships with. This is an implementation report that dissects yao-meta-skill's structure from those measured results and considers what we can borrow for our own `.claude/skills` operations.

## What This Tool Is

yao-meta-skill is a "skill that makes skills" — a meta-skill. It takes repetitive work such as workflow notes, prompt sets, conversation transcripts, runbooks, and document patterns, and converts them into a verifiable skill package. Its core design rests on three pillars.

First, **Skill IR (Intermediate Representation)**. Intent, triggers, inputs, outputs, boundaries, references, and expected artifacts are first described in a platform-neutral intermediate representation. Target compilers and adapters then convert this IR into five targets: OpenAI, Claude, generic agent skills, Agent-Skills-compatible packages, and VS Code-oriented workflows. Describing a skill once and compiling it to many environments precisely targets the burden of maintaining the same skill twice across Claude Code and Cursor.

Second, the **Output Eval Lab**. It is a layer that verifies skill output quality with data: trigger checks, output assertions, execution evidence, timing and token evidence, benchmark reproducibility, and blind-review packs. The fact that code actually verifies, instead of the model merely claiming "it worked," is striking.

Third, **Review Studio 2.0**. It consolidates intent, triggers, output evaluation, context cost, runtime checks, and release evidence into a single HTML gate page — a checkpoint that fixes exactly what a skill must pass before release.

The license is MIT, and the manifest declares a maturity tier of "governed," a lifecycle stage of "library," and a review cadence of "quarterly." The intent to manage skills like code — with versions, tiers, and review cadences — is visible at the metadata level itself.

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
<div class="d3-arch" data-arch-root id="illengineeringgovernance-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 233, "height": 738, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "IN", "x": 24, "y": 24, "w": 177, "h": 46, "title": "Repetitive task input"}, {"id": "IR", "x": 53, "y": 148, "w": 120, "h": 46, "title": "Skill IR"}, {"id": "COMPILE", "x": 42, "y": 272, "w": 142, "h": 62, "title": ["Target compiler", "(multi-platform)"]}, {"id": "EVAL", "x": 45, "y": 412, "w": 135, "h": 46, "title": "Output Eval Lab"}, {"id": "REVIEW", "x": 38, "y": 536, "w": 149, "h": 46, "title": "Review Studio 2.0"}, {"id": "REL", "x": 42, "y": 660, "w": 142, "h": 46, "title": "Release evidence"}], "edges": [{"src": "IN", "dst": "IR", "kind": "data", "line": [113, 70, 113, 148]}, {"src": "IR", "dst": "COMPILE", "kind": "data", "line": [113, 194, 113, 272]}, {"src": "COMPILE", "dst": "EVAL", "kind": "data", "line": [113, 334, 113, 412]}, {"src": "EVAL", "dst": "REVIEW", "kind": "data", "line": [113, 458, 113, 536]}, {"src": "REVIEW", "dst": "REL", "kind": "data", "line": [113, 582, 113, 660]}]});
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
      const container = document.getElementById('illengineeringgovernance-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'illengineeringgovernance-1';
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
*Repetitive-work inputs pass through Skill IR, compile to multiple platforms, then clear the Output Eval Lab and Review Studio gates to finish as release evidence.*

## Installation and Integration (Real Commands)

Verification ran in an isolated sandbox. Per our rules, the worktree lived outside the repository and was cleaned up afterward.

```bash
# 1) Clone the external repo
git clone --depth 1 https://github.com/yaojingang/yao-meta-skill

# 2) Install the minimal dependency into the shared .venv (python-runtime rule)
VIRTUAL_ENV="$REPO_ROOT/.venv" uv pip install "PyYAML==6.0.3"
```

The dependencies are surprisingly light. The CI requirements (`requirements-ci.txt`) were a single line: `PyYAML==6.0.3`. This means the verification tooling is built around the pure-Python standard library rather than heavy runtimes — a good sign for slotting it into a CI pipeline.

The actual composition I measured right after cloning was: 632 tracked files, 77 tests, 29 evals, 10 skill-atlas entries, 3 schemas, and 2 templates. This is not a single "skill" but closer to a small factory that produces, verifies, and governs skills.

![Chart of the yao-meta-skill repository composition and local verification gate results]({{ '/assets/images/yao-meta-skill-results.webp' | relative_url }})
*Left: the repository's measured composition (log scale). Right: all four local verification gates passing.*

## Real Verification Results

The `Makefile` defined more than 25 verification targets. I actually ran four of them — skill IR, compiler, output eval, and lint — and captured the results.

```bash
make skill-ir-check
# python3 tests/verify_skill_ir.py        -> {"ok": true}
# python3 tests/verify_skill_ir_paths.py  -> {"ok": true}

make compiler-check
# python3 tests/verify_compile_skill.py    -> {"ok": true}

make output-eval-check
# python3 tests/verify_output_eval_lab.py  -> {"ok": true}

python3 scripts/lint_skill.py ./   # against the bundled SKILL.md
# {"ok": true, "failures": [], "warnings": []}
```

All four gates passed with `ok: true`, and lint reported zero failures and zero warnings. These numbers were captured by running it myself, not quoted from elsewhere. What is notable is that the verification output is deterministic JSON in the form `{"ok": true}` rather than prose. This is a machine-readable format an upstream pipeline can gate on automatically — the same direction as ThakiCloud's own principle that "format is owned by code."

One limitation also surfaced through measurement. `lint_skill.py` raised a usage error when called without arguments and required an explicit skill directory. The context-sizing script (`context_sizer.py`) returned a token estimate of 0 on some paths, appearing sensitive to how arguments are passed. In short, "the make targets work well, but calling individual scripts directly requires matching the interface precisely" is a practical caveat.

## Application and Implications for the ThakiCloud K8s AI/ML SaaS Platform

ThakiCloud already operates over a thousand in-house skills and rules. At this scale, the biggest cost is not the skills themselves but the context tax every indexed skill pays each session, plus trigger collisions. There are three points worth borrowing from yao-meta-skill.

First, **partial adoption of the Skill IR idea**. Instead of maintaining in-house skills twice across Claude Code and Cursor, describing intent, triggers, and boundaries neutrally once and compiling per environment reduces the management surface. Full adoption may be overkill, but structuring new skills' descriptions and triggers like an IR schema already helps.

Second, **borrowing the Output Eval Lab style of gating**. We already have editorial gates and deterministic verification scripts, but trigger evaluation — checking with data whether a trigger fires as intended — is relatively weak. This pattern is directly usable for reducing skill-router distractor noise.

Third, **a Review Studio-style single release gate**. A checkpoint that confirms intent, triggers, context cost, and runtime on one page before merging a new skill is philosophically isomorphic to the deployment gates (ArgoCD, Kueue) of an AI/ML SaaS running on K8s. Just as we gate code deployment, we gate skill deployment.

## Limitations and Counterarguments

To avoid a one-sided endorsement, here are the counterarguments.

First, **the "more powerful than the official" claim traces back to an influencer recommendation**. The repository structure and local verification are solid, but Anthropic's official Skill-creator excels at fast, conversation-first creation loops — a different purpose. The two are complementary rather than competitive. The "more powerful" comparison is accurate only when scoped to building governed team assets.

Second, **adoption cost**. Bringing in a 632-file factory wholesale is overkill for a solo or small team. Selectively borrowing the core ideas (IR, trigger evaluation, single gate) is the realistic path.

Third, **interface sensitivity**. As measured above, individual scripts were sensitive to arguments and some metrics returned 0. When slotting into CI, wrap things at the make-target level and pin the interfaces of individual scripts.

In conclusion, yao-meta-skill is one of the most concrete open-source examples of "engineering skills like software." Even without adopting all of it, any organization where skills become assets will find its design principles worth studying.

## Sources

- yao-meta-skill (GitHub, MIT): [github.com/yaojingang/yao-meta-skill](https://github.com/yaojingang/yao-meta-skill)
- Repository manifest and verification results: all numbers in this article were measured locally by cloning v1.1.0.
