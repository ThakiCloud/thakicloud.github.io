---
title: "AI Governance and Audit Automation in Financial Services: Regulatory Compliance and Autonomous Agent Control"
excerpt: "A hypothetical case study examining how banks, securities firms, and insurers can meet data localization, audit trail, and internal control requirements when deploying AI agents -- using a policy engine and hash-chain audit logs."
seo_title: "AI Governance and Audit Automation in Financial Services - Thaki Cloud"
seo_description: "Financial AI audit logs, AI governance in financial services, and how to comply with ISMS and Electronic Financial Supervision Regulations when deploying on-premises AI agents. A case study applying the Paxis platform with a 4-level autonomy x 7-tier risk policy engine, hash-chain audit logs, and masking of 16 categories of personal data."
lang: en
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - ai-governance
  - finance
  - audit-log
  - policy-engine
  - compliance
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/finance-ai-governance-audit-automation/"
reading_time: true
categories:
  - agentops
---

![AI Governance and Audit Automation in Financial Services]({{ '/assets/images/finance-ai-governance-audit-automation-hero.webp' | relative_url }})

![Illustration of the core idea of AI Governance and Audit Automation in Financial Services: Regulatory Compliance and Autonomous Agent Control](/assets/images/finance-ai-governance-audit-automation-hero.webp)
*A visual metaphor for the article's key idea.*

## Overview

Adopting AI agents in the financial industry is no longer optional. As applications expand -- credit assessment automation, fraud detection, customer service support -- every financial institution must simultaneously achieve operational efficiency and regulatory compliance.

The problem is that existing AI platforms do not address both goals together. Cloud-based LLM APIs are powerful, but data passes through overseas servers. Open-source agent frameworks often lack audit trails or access controls. Meanwhile, regulators require traceability for every judgment an AI makes, in accordance with the Electronic Financial Supervision Regulations, ISMS-P, and Korea Financial Security Institute guidelines.

This article uses a hypothetical domestic bank case to examine an architecture in which AI agents satisfy financial regulations while delivering meaningful workflow automation. The key elements are an autonomy control mechanism and a tamper-proof audit framework.

---

## Where Financial Institutions Get Stuck with AI Adoption

### Data Localization Requirements

Article 13-2 of the Electronic Financial Supervision Regulations and the Financial Services Commission's cloud usage guidelines in principle prohibit -- or require prior approval for -- processing or storing customer financial data on overseas servers. Using generative AI directly through an external API can transmit account numbers, transaction histories, and customer identification data embedded in prompts to data centers abroad. This single issue has halted many financial institution proof-of-concept projects.

### Absence of Audit Trails

If an AI's recommendation of a specific credit limit or automatic suspension of a suspicious transaction cannot be reproduced after the fact, it becomes a serious risk during FSS inspections or internal audits. "The AI did it" is not an answer regulators accept. A chronologically reproducible record is required: which model, with what inputs, called which tools, and produced what outputs.

### Control Uncertainty with Autonomous Agents

When deploying agents that go beyond simple chatbots -- calling external APIs, reading files, sending emails, executing system commands -- unexpected behavior can occur if the boundary of what the agent is allowed to do is not clearly defined. In finance, an autonomous agent that executes transactions with misplaced autonomy can result not only in financial losses but in regulatory violations.

### Multi-Tenancy and Internal Isolation

Even when different divisions -- securities, insurance, trust -- share the same AI infrastructure, each team's data and audit logs must be completely isolated. If an agent from one department can access customer data or transaction records of another, it violates internal control principles.

---

## Governance Architecture: Policy Engine and Autonomy x Risk Matrix

### Why a Policy Engine Must Exist

Giving an agent a tool and controlling how that tool is used safely are different problems. Simply configuring "this agent may use the customer query API" cannot prevent the agent from executing thousands of queries in succession due to a misjudgment, or reading sensitive fields excessively.

Paxis's policy engine cross-examines two dimensions before any tool call is executed.

**4 Levels of Autonomy:**

- **L0 (Fully Manual):** The agent only proposes; a human approves every execution.
- **L1 (Low-Risk Autonomy):** Only read-only, non-monetary tasks are executed automatically.
- **L2 (Medium-Risk Autonomy):** Transactions below a predefined threshold execute automatically; above threshold, approval is requested.
- **L3 (High Autonomy):** Broad autonomous execution within the scope permitted by the policy engine.

**7 Risk Tiers:**

Tool calls are classified from Tier 1 (simple query) to Tier 7 (irreversible external transaction) based on risk. For example, checking a customer balance is Tier 1; executing an inter-account transfer is Tier 6-7. Each built-in tool has a pre-registered risk tier; unregistered tools are blocked by default.

### Policy Decision Flow

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="overnanceauditautomation-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 747, "height": 1072, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 347, "y": 24, "w": 191, "h": 46, "title": "Agent tool call request"}, {"id": "B", "x": 356, "y": 148, "w": 174, "h": 52, "title": "Unregistered tool?"}, {"id": "C", "x": 510, "y": 862, "w": 205, "h": 46, "title": "Default block + audit log"}, {"id": "D", "x": 165, "y": 292, "w": 149, "h": 46, "title": "Look up risk tier"}, {"id": "E", "x": 142, "y": 416, "w": 195, "h": 68, "title": ["Autonomy level x Risk", "matrix"]}, {"id": "F", "x": 303, "y": 722, "w": 120, "h": 46, "title": "Execute tool"}, {"id": "G", "x": 147, "y": 576, "w": 184, "h": 46, "title": "Request admin approval"}, {"id": "H", "x": 24, "y": 714, "w": 191, "h": 62, "title": ["Block execution + audit", "log"]}, {"id": "I", "x": 271, "y": 854, "w": 184, "h": 62, "title": ["Return result + record", "audit event"]}, {"id": "J", "x": 264, "y": 994, "w": 198, "h": 46, "title": "Add block to audit chain"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [443, 70, 443, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "Yes", "curve": [[504, 200], [613, 377], [613, 668], [613, 862]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "No", "curve": [[369, 200], [239, 246], [239, 246], [239, 292]], "off": "50%"}, {"src": "D", "dst": "E", "kind": "data", "line": [239, 338, 239, 416]}, {"src": "E", "dst": "F", "kind": "data", "label": "Permitted", "curve": [[335, 484], [464, 530], [464, 668], [393, 722]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "Conditionally permitted", "line": [239, 484, 239, 576], "lx": 239, "ly": 526}, {"src": "E", "dst": "H", "kind": "data", "label": "Denied", "curve": [[174, 484], [87, 530], [87, 668], [106, 714]], "off": "50%"}, {"src": "G", "dst": "F", "kind": "data", "label": "Approved", "curve": [[254, 622], [284, 668], [284, 668], [340, 722]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "label": "Denied/Timeout", "line": [224, 622, 149, 714], "lx": 194, "ly": 664}, {"src": "F", "dst": "I", "kind": "data", "line": [363, 768, 363, 854]}, {"src": "C", "dst": "J", "kind": "data", "curve": [[613, 908], [613, 955], [613, 955], [456, 994]]}, {"src": "H", "dst": "J", "kind": "data", "curve": [[120, 776], [120, 815], [120, 955], [273, 994]]}, {"src": "I", "dst": "J", "kind": "data", "line": [363, 916, 363, 994]}]});
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
      const container = document.getElementById('overnanceauditautomation-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'overnanceauditautomation-1';
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

### Hypothetical Case: Bank A Credit Assessment Agent

Bank A wants to deploy an AI agent for SME credit assessment. The tasks the agent performs are as follows:

1. Query corporate credit information from the NICE credit inquiry system (Risk Tier 2)
2. Query the internal loan history database (Risk Tier 1)
3. Analyze financial statements and recommend credit limits (judgment only, no external execution)
4. Draft a credit assessment opinion (document generation)
5. Call the limit registration API upon approval (Risk Tier 6)

In this case, the agent's autonomy level is set to L2. Tasks 1-4 execute automatically, but the Tier 6 limit registration API call for task 5 requires mandatory officer approval. It is structurally impossible for the agent to register the limit directly without approval.

Nine high-risk operations (account termination, bulk transfers, external system integration changes, etc.) require admin approval regardless of the autonomy level.

---

## Audit and Traceability: Hash-Chain Logs and Personal Data Masking

### How Hash-Chain Audit Logs Work

Paxis's audit framework is designed with a hash-chain structure. Each audit event contains the hash value of the previous event, so deleting or modifying a middle record causes hash verification to fail for all subsequent blocks. This structure enables detection of tampering even if a database administrator accidentally or intentionally alters logs.

More than 20 event types are recorded; key items include:

- `agent.tool.invoked`: Tool call request (agent ID, tool name, execution context)
- `agent.tool.policy.denied`: Block by policy engine (risk tier, autonomy level, decision rationale)
- `agent.tool.approval.requested`: Admin approval request generated
- `agent.tool.approval.decided`: Approval/denial result (decision-maker ID, timestamp)
- `agent.session.started`: Agent session started (team ID, agent ID, session ID)
- `sandbox.exec`: Code execution event within sandbox

Each event is keyed by `run_id`, enabling all tool calls, policy decisions, and approval history that make up a single credit assessment workflow to be queried and reproduced under a single `run_id`. Audit logs are retained for 90 days or more.

### Automatic Masking of 16 Personal Data Categories

Data processed by agents may include personal information such as resident registration numbers, account numbers, phone numbers, and email addresses. Paxis's prompt protection layer detects 16 categories of personal data patterns in real time at the input stage and automatically masks them.

For example, if a customer information query result contains a resident registration number, it is replaced with `[Resident Registration Number Masked]` before the agent passes it to the LLM. Since audit logs also record only the masked form rather than the original data, the risk of logs themselves becoming a personal data exposure vector is reduced.

The system also detects 11 types of prompt injection attack patterns in real time (role switching, instruction ignoring, escape attempts, etc.) to block attempts to cause the agent to malfunction through malicious inputs.

### Multi-Tenancy Isolation

Even when Bank A's credit department and asset management department use the same Paxis instance, wikis, sessions, settings, and audit logs are completely isolated based on team identifiers (team IDs). If an agent from the credit team attempts to access customer data from the asset management team, the data itself responds as "not found," exposing not even its existence.

---

## ThakiCloud Implementation Implications

### On-Premises + Air-Gap Deployment for Data Localization Compliance

The ThakiCloud AI Platform can be deployed directly to the internal network of a financial institution's data center on a Kubernetes basis. Since all inference computation takes place within the institution, customer financial information is never transmitted outside. The Paxis roadmap includes an air-gap deployment kit [estimate: Q1 2027], with plans to support configurations that operate independently even in closed network environments where external networks are completely blocked.

Observation infrastructure (VictoriaMetrics/VictoriaLogs) is also deployed together on the internal network, enabling real-time monitoring of agent operations, costs, and anomalous behavior.

### Keycloak OIDC RBAC Integration with Existing User Directories

Financial institutions typically operate employee directories based on AD (Active Directory) or LDAP. The ThakiCloud AI Platform integrates with existing directories through Keycloak's OIDC integration, so that employee account creation, deletion, and permission changes are immediately reflected in the AI platform as well. This prevents retired employees' accounts from retaining access to AI agents.

### Linking the Policy Engine with Internal Control Frameworks

The autonomy x risk matrix can be directly mapped to a financial institution's internal control framework. For example, the "two-person approval for critical operations" principle required by the Financial Services Commission's internal control standards can be implemented as a mandatory approval rule for high-risk operations in the policy engine.

Audit teams can query the complete processing history of a specific credit case using `run_id`, and confirm on a single screen what data the agent referenced, what decisions the policy engine made, and who the approver was. This contributes to securing post-hoc verifiability of AI behavior at the level required by FSS inspections.

### Cost Optimization through the LLM Router

An LLM router supporting more than 10 LLM providers as well as ThakiCloud's own Metis can restrict financial institutions to using only specific models that have received security approval, or automatically route between cost-efficient models and high-accuracy models depending on the task type. A hybrid configuration using on-premises Metis as the primary inference backend and external providers only as a fallback simultaneously achieves data localization requirements and cost efficiency.

---

## Limitations and Considerations

An honest assessment is necessary. No matter how sophisticated the architecture, real-world constraints exist.

**Regulatory Interpretation Uncertainty:** Domestic regulations on financial AI governance are still evolving. The AI utilization provisions of the Electronic Financial Supervision Regulations and the Korea Financial Security Institute's AI security guidelines often do not specify detailed technical requirements, so actual compliance requires prior consultation with legal teams and regulatory authorities. There is no guarantee that the audit logs and policy engine provided by Paxis satisfy specific regulatory requirements; this requires separate review for each institution.

**SOC 2 Type II Certification:** The Paxis SOC 2 Type II certification roadmap is scheduled for Q2 2027 or later. Financial institutions currently requiring SOC 2 Type II certification must take this timeline into account.

**Complexity of Policy Design:** The autonomy x risk matrix is a powerful tool, but correctly designing it to fit an organization's business processes requires considerable domain knowledge and time. If initial policy design is flawed, problems will arise where the agent blocks too many operations (excessive restriction) or has too much autonomy (excessive permissiveness). Phased deployment and data-driven policy adjustment are essential.

**Unpredictability of Agent Behavior:** The policy engine provides control at the tool-call level but does not fully control the LLM's reasoning process itself. Even when an agent uses only policy-permitted tools, it may execute them in unexpected sequences or combinations. Particularly for operations like credit assessment where judgment accuracy is critical, AI agents must be clearly defined as supporting the decision-making of responsible officers -- not holding final decision authority.

**Technical Burden of On-Premises Operations:** Operating an on-premises Kubernetes environment requires significantly more infrastructure operational capability than cloud SaaS. Specialized personnel are needed throughout the entire operational cycle -- ArgoCD GitOps, Keycloak management, model update deployment, and more. This aspect should be reviewed together with an operational support contract with ThakiCloud or an internal capability development plan.

---

Adopting AI agents in the financial sector is not a technology problem -- it is a governance problem. The core questions are: where is data stored, to what extent can an agent act autonomously, and are all of those actions recorded in a verifiable manner? The policy engine and hash-chain audit logs provide technical answers to these three questions, but it is equally important to remember that this is not the entirety of regulatory compliance.
