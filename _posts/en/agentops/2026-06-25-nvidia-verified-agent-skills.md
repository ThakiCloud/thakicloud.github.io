---
title: "NVIDIA-Verified Agent Skills: Planting Trust in the Skill Supply Chain with OMS Signatures"
excerpt: "NVIDIA has open-sourced over 200 agent skills paired with OMS cryptographic signatures. The same SKILL.md works across Claude Code, Codex, and Cursor, and anyone can verify that a downloaded skill has not been tampered with. We cloned the repository, ran signature verification end-to-end, mutated a single line to confirm tamper detection, and drew out the implications for ThakiCloud's skill operations."
seo_title: "NVIDIA Verified Agent Skills and OMS Signatures - Skill Supply-Chain Trust - Thaki Cloud"
seo_description: "A hands-on walkthrough of NVIDIA Verified Agent Skills: the 8-step verification pipeline, OpenSSF Model Signing (OMS) detached signatures, and SkillSpector security scans. We measured 226 skills and 237 signatures, reproduced signature verification and tamper detection with model_signing, and distilled the governance implications for ThakiCloud's Kubernetes AI/ML SaaS platform."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - agentic
  - agent-skills
  - supply-chain-security
  - nvidia
  - claude-code
  - governance
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "shield-alt"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/nvidia-verified-agent-skills/"
reading_time: true
categories:
  - agentops
---

![Abstract image showing modular skill blocks sealed with cryptographic stamps, linked into a chain of trust]({{ '/assets/images/nvidia-verified-agent-skills-hero.webp' | relative_url }})

## Overview

Agent skills are fast becoming standard components. Write a SKILL.md that describes how to use a tool and what procedure to follow, and a coding agent reads those instructions to carry out the task. The hard part comes next. There was no good way to verify where a skill downloaded from the internet came from, whether it contained dangerous code, or whether someone had tampered with it after the download. Because a skill is essentially a directive that grants an agent authority and shapes its behavior, dropping an unvetted skill straight into a production environment is riskier than it looks.

NVIDIA released NVIDIA Verified Agent Skills to close this gap. The approach has two pillars. First, every skill ships with a cryptographic signature so that integrity and provenance can be verified even after download. Second, skills must pass a security scan and have their documentation captured in a skill card before publication. On top of that, these skills follow the agentskills.io open specification, meaning the same SKILL.md is designed to work across different harnesses such as Claude Code, Codex, and Cursor.

ThakiCloud runs a Kubernetes-based AI/ML SaaS platform with hundreds of internal skills and autonomous agent jobs. "How do we trust a skill?" is not an academic question for us -- it is a daily operational concern. In this post we clone NVIDIA's public repository, verify the signatures, mutate a single line to confirm tamper detection, and summarize what this architecture changes for an operator running a multi-tenant agent platform.

## What This Technology Is

NVIDIA agent skills are a bundle of portable instructions that teach an agent how to use CUDA-X libraries, AI Blueprints, and platform tools correctly. The word "verified" carries a specific meaning here: a skill has been catalogued, passed a security scan, received a cryptographic signature, and been documented with a skill card. Unlike the circumstantial evidence of "a well-known publisher uploaded it," the key distinction from a typical registry is that the downloaded artifact itself can be verified.

The verification pipeline has eight stages. It begins at the source repository and flows through review, scanning, evaluation, skill-card generation, signing, catalogue registration, and synchronization. The pipeline runs on a daily sync cycle, and each stage must complete before the next begins.

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
<div class="d3-arch" data-arch-root id="vidiaverifiedagentskills-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 381, "height": 1300, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 112, "y": 24, "w": 149, "h": 46, "title": "Source repository"}, {"id": "B", "x": 127, "y": 148, "w": 120, "h": 46, "title": "Review"}, {"id": "C", "x": 126, "y": 272, "w": 121, "h": 62, "title": ["Security scan", "SkillSpector"]}, {"id": "D", "x": 127, "y": 412, "w": 120, "h": 46, "title": "Evaluation"}, {"id": "E", "x": 127, "y": 536, "w": 120, "h": 46, "title": "Skill card"}, {"id": "F", "x": 127, "y": 660, "w": 120, "h": 46, "title": "OMS signing"}, {"id": "G", "x": 119, "y": 784, "w": 135, "h": 46, "title": "Catalog listing"}, {"id": "H", "x": 127, "y": 908, "w": 120, "h": 46, "title": "Daily sync"}, {"id": "V", "x": 107, "y": 1046, "w": 160, "h": 68, "title": ["Signature verify", "model_signing"]}, {"id": "OK", "x": 214, "y": 1206, "w": 135, "h": 62, "title": ["Verified", "deploy proceeds"]}, {"id": "NG", "x": 24, "y": 1206, "w": 135, "h": 62, "title": ["Tamper detected", "deploy blocked"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [187, 70, 187, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [187, 194, 187, 272]}, {"src": "C", "dst": "D", "kind": "data", "line": [187, 334, 187, 412]}, {"src": "D", "dst": "E", "kind": "data", "line": [187, 458, 187, 536]}, {"src": "E", "dst": "F", "kind": "data", "line": [187, 582, 187, 660]}, {"src": "F", "dst": "G", "kind": "data", "line": [187, 706, 187, 784]}, {"src": "G", "dst": "H", "kind": "data", "line": [187, 830, 187, 908]}, {"src": "H", "dst": "V", "kind": "event", "label": "download", "line": [187, 954, 187, 1046], "lx": 187, "ly": 996}, {"src": "V", "dst": "OK", "kind": "data", "label": "hash match", "curve": [[227, 1114], [282, 1160], [282, 1160], [282, 1206]], "off": "50%"}, {"src": "V", "dst": "NG", "kind": "data", "label": "hash mismatch", "curve": [[146, 1114], [92, 1160], [92, 1160], [92, 1206]], "off": "50%"}]});
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
      const container = document.getElementById('vidiaverifiedagentskills-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'vidiaverifiedagentskills-1';
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
*NVIDIA's 8-stage verification pipeline and the post-download signature-verification flow. Click the diagram to enlarge.*

Three axes hold this structure together.

The first is signing. NVIDIA adopts the OpenSSF Model Signing (OMS) format and distributes a detached signature file `skill.oms.sig` alongside each skill. This signature covers every file and subdirectory inside the skill directory -- integrity is guaranteed for the entire directory tree, not just a single file. OMS extends Sigstore-style bundles to support directory-level verification.

The second is security scanning. Before publication, every skill passes through SkillSpector. SkillSpector checks traditional software risks -- vulnerable dependencies, suspicious scripts, dangerous code patterns, credential access, data-exfiltration paths -- and also examines agent-specific risks: hidden instructions, prompt injection, trigger abuse, excessive permissions, tool poisoning, and mismatches between a skill's declared purpose and the access it actually requests or the behaviors bundled within it. A skill can look harmless at the file level yet still steer an agent toward dangerous actions, which is why this intent-layer inspection matters. SkillSpector's scope is grounded in OWASP's LLM Application Risk Guide and the Agentic AI Risk Guide.

The third is skill cards. Each verified skill ships with a machine-readable trust record. It covers what the skill does, who created it, its license, its dependencies, and its known technical limitations, risks, and mitigations. Developers can read the card to quickly decide whether the skill is compatible with their target agent and which dependencies need to be resolved before deployment.

## Installation and Verification

Words alone are abstract, so we ran the process ourselves. We installed the verification tool in the shared virtual environment rather than creating a separate one, consistent with ThakiCloud's Python runtime policy.

```bash
# Install the OMS verifier (model-signing package)
VIRTUAL_ENV="$PWD/.venv" uv pip install model-signing
# Installed version: model-signing 1.1.1
# Pulled dependencies: sigstore-models 0.0.6, sigstore-rekor-types 0.0.18, tuf 7.0.0
```

Next we fetched the public catalogue. Rather than the cuOpt skill used as an example in the NVIDIA blog post, we selected the Dynamo skill as our verification target because it is directly relevant to our environment.

```bash
# Shallow-clone the public catalogue (approximately 5.5 seconds)
git clone --depth 1 https://github.com/nvidia/skills
cd skills

# The root certificate is included in the repository
ls nv-agent-root-cert.pem

# Navigate to a signed skill
cd plugins/nvidia-skills/skills/dynamo-interconnect-check
ls
# BENCHMARK.md  evals  references  scripts  skill-card.md  SKILL.md  skill.oms.sig
```

The verification command takes the form `model_signing verify certificate`. It takes the signature file, the certificate chain, and the paths to exclude from verification (the signature file itself).

```bash
python -m model_signing verify certificate . \
  --signature skill.oms.sig \
  --certificate_chain /path/to/nv-agent-root-cert.pem \
  --ignore-paths skill.oms.sig
```

Surveying the full repository, we found 226 skills under the `skills/` directory and 237 `skill.oms.sig` signature files. The root certificate is included in the repository, so there is no need to retrieve the trust anchor through a separate channel before starting verification.

## Experimental Results

First, normal signature verification. Running verification against the untouched `dynamo-interconnect-check` skill returned a pass immediately.

```text
Verification succeeded
verify_seconds=0.58
```

The integrity and provenance of the entire directory tree was confirmed in 0.58 seconds. Fast and straightforward.

The essential test is tamper detection. For a signature to mean anything, verification must break the moment a file is changed, however slightly. We appended a single comment line to `BENCHMARK.md` inside the skill directory and re-ran verification.

```text
Verification failed with error: Signature mismatch:
['Hash mismatch for 'BENCHMARK.md':
  Expected Digest(algorithm='sha256', digest_value=b's\xa5\xf6i!...'),
  Actual   Digest(algorithm='sha256', digest_value=b'Uy\xb9\xf6#b...')']
```

Verification failed exactly as expected -- and not vaguely. It pinpoints which file has a SHA-256 hash that does not match the expected value. Adding a single line changed the file's hash entirely, and the verifier caught the discrepancy. Anyone who modifies a skill after download leaves a trace that is immediately visible. This is the difference between "a well-known publisher uploaded it" as circumstantial evidence and "the artifact itself proves it has not been tampered with" as a cryptographic guarantee.

We also opened the skill card. `skill-card.md` for `dynamo-interconnect-check` contained the following real trust metadata.

- Description: verifies that the NIXL/UCX/NCCL interconnects of a Dynamo deployment are ready for RDMA/NVLink-based disaggregated serving
- Owner: NVIDIA
- License: Apache-2.0
- Use case: developers deploying Dynamo distributed or multi-node recipes who want to confirm that the NIXL/UCX/NCCL transport fabric is functioning before trusting benchmark figures
- Known risks and mitigations: proposed content could inject misleading or incorrect instructions into the skill, so review and scan before deployment
- Output format: structured JSON with ok/warn/fail/skipped verdicts per check

Everything needed to decide whether to deploy the skill -- what it does, what permissions it requires, and what risks it carries -- is assembled in one document. There was also one reproduction failure worth noting. The example command in the NVIDIA blog post uses an older flag (`--ignore-unsigned-files`), but in model-signing 1.1.1 the flag name had changed to the hyphenated form (`--ignore-paths`, `--ignore_unsigned_files`), which caused an error on the first attempt. That is a signal that the tooling is still moving quickly.

## Application and Implications for ThakiCloud's K8s AI/ML SaaS Platform

This topic lands directly for us. ThakiCloud runs its platform with an in-house skill set that includes skills bearing the same names as the Dynamo skills NVIDIA has signed and distributed. Skills such as `dynamo-interconnect-check` and `dynamo-router-starter` are tools we use when working with our distributed inference stack. The fact that those skills now ship with cryptographic signatures means we can verify the provenance and integrity of externally sourced skills in code, as part of the operational pipeline.

The multi-tenant angle matters even more. Our platform runs agents across multiple customer environments. Before deploying a skill created by a customer or a third party into a Kubernetes agent runtime, we need to be able to verify that it has not been tampered with since publication and that someone is accountable for it. OMS signature verification makes it possible to turn that gate from a prose rule into a deterministic code gate: if the signature breaks, block the deployment; if it passes, proceed. As the experiment above showed, verification runs in roughly 0.58 seconds, so inserting it into a CI or admission step adds negligible overhead.

We already operate skill-governance mechanisms: a skill intake gate, a skill security scanner, and an internal Trusted Skill Governance (TSG) framework. NVIDIA's 8-stage pipeline maps naturally onto that flow. The difference is that NVIDIA has baked in one additional layer -- "verifiable integrity after download" -- as a standardized format. For our part, we can now consider applying the same OMS signatures to our own internal skills to close the chain of trust in our private catalogue.

For on-premises and regulated environments this value is amplified further. In air-gapped or high-security customer environments, proving that "this skill is exactly what NVIDIA published and has not changed since it left their hands" is itself a compliance requirement. For a platform that positions self-hosting and on-premises deployment as core strengths, the verifiability of the skill supply chain is not a marketing claim -- it is a technical requirement for passing real procurement gates.

## Limitations and Counterarguments

It is more honest not to overstate what signatures provide. A cryptographic signature guarantees integrity and provenance; it does not guarantee that a skill is safe or correct. A bad skill can still be signed. A signature says only "this is what the publisher shipped and it has not been altered" -- it does not say "it is safe to follow these instructions." The skill card for `dynamo-interconnect-check` itself says "review and scan before deployment."

Security scanning also has limits. SkillSpector runs on the publisher side, which means we trust that NVIDIA ran the scan correctly rather than reproducing the result ourselves. The evaluation layer -- trigger accuracy, task completion rate, token efficiency -- is still roadmap-stage, so until it runs and reports across shared harnesses there are no standard quality metrics.

Tool maturity deserves mention too. NVIDIA itself describes the signing as "publicly experimental." As noted, flag names had changed since the blog post was written, so the example did not run as printed, and the verifier ecosystem is still early. The trust anchor being tied to a single root certificate cuts both ways: verification is simple, but trust is concentrated in a single entity -- NVIDIA. Cross-harness portability is a design goal, not a guarantee for every harness, so an adoption workflow should include a real test run on the target harness.

The direction is clear despite these caveats. Once skills become the components that determine an agent's behavior, the requirement to verify their provenance and integrity does not go away. NVIDIA's effort is the first concrete, reproducible answer to that requirement.

## Sources

- NVIDIA Technical Blog, [NVIDIA-Verified Agent Skills Provide Capability Governance for AI Agents](https://developer.nvidia.com/blog/nvidia-verified-agent-skills-provide-capability-governance-for-ai-agents/)
- GitHub, [NVIDIA/skills](https://github.com/nvidia/skills)
- GitHub, [NVIDIA/skillspector](https://github.com/nvidia/skillspector)
- NVIDIA Skill Documentation, [Verify Signed Agent Skills](https://docs.nvidia.com/skills/signing-agent-skills)
- OpenSSF, [Model Signing (OMS)](https://github.com/sigstore/model-transparency)
- The verification figures in this post (226 skills, 237 signatures, 0.58s verification time, tamper detection) were measured by cloning the repository directly on 2026-06-25.
