---
title: "How to Automate Manufacturing Operations with Autonomous Agent Teams"
excerpt: "A practical approach to resolving MLOps talent shortages and multi-factory cluster management challenges using multi-persona autonomous agent teams. Explained through a hypothetical manufacturer case study showing how ThakiCloud AI Platform and Paxis apply to smart factory operations."
seo_title: "Manufacturing AI Agent Automation - Multi-Cluster GPU Operations and Autonomous Agent Teams - Thaki Cloud"
seo_description: "How to automate MLOps talent bottlenecks and multi-factory cluster management for smart factories, heavy industry, and electronics manufacturers using autonomous agent teams. Real-world application of ThakiCloud AI Platform multi-cluster central management and Paxis agent operations cloud."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - manufacturing
  - autonomous-agents
  - multi-cluster
  - mlops
  - automation
lang: en
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/manufacturing-autonomous-agent-teams/"
reading_time: true
categories:
  - agentops
published: false
---

![Manufacturing Operations Autonomous Agent Teams Header Image]({{ '/assets/images/manufacturing-autonomous-agent-teams-hero.webp' | relative_url }})

## Overview

Modern manufacturing faces a structural contradiction: high intent to adopt AI, but a critical shortage of operational personnel. Even when factories want to deploy vision inspection models on production lines, they lack the MLOps specialists to maintain, service, and retrain those models. With three factory GPU clusters each managed by different teams, resource waste and downtime repeat in a cycle.

This article explains how multi-persona autonomous agent teams resolve this problem and how GPU clusters distributed across multiple factories can be unified under a single control plane -- using the hypothetical manufacturer "HanTek" as a case study. The core technologies covered are ThakiCloud AI Platform's multi-cluster central management and the Paxis agent operations cloud.

---

## The Talent Bottleneck in Manufacturing AI Operations

HanTek is a mid-size electronics components manufacturer operating GPU clusters at facilities in Ulsan, Gumi, and Gwangju. Over the past two years, the company deployed vision AI models on each factory line, but three recurring problems emerged in operations.

**First, an absolute shortage of MLOps talent.** Model retraining, deployment, and performance monitoring require dedicated engineers. HanTek's ML team of three engineers struggled to manage the model lifecycle across all three factories. Even as model performance began to degrade, retraining requests routinely sat in a queue for days.

**Second, fragmented multi-cluster management.** Each factory's GPU cluster operated independently. Situations arose where training jobs at Gumi were queued while the Ulsan cluster sat idle, requiring manual coordination via Slack. DCGM metrics were also collected separately per factory, making it impossible to see company-wide GPU utilization at a glance.

**Third, the impossibility of 24/7 response.** When quality anomalies were detected on night or weekend lines, the ML team could not respond immediately. Alerts arrived, but actual remediation was pushed to the next morning -- with defective products sometimes advancing to the next process in the interim.

These problems are not unique to HanTek. Across the manufacturing industry, a recurring pattern emerges: AI has been adopted, but operational capability has not kept pace, cutting effectiveness in half.

---

## Autonomous Agent Team Configuration - Multi-Persona and Dynamic Tasks

The solution HanTek adopted is a Praxis-based multi-persona autonomous agent team. Paxis is an agent operations cloud that treats agents as first-class resources "like VMs on AWS." Skills, Tools, Policies, and Audit Logs are the platform's core resources, and each agent references its domain wiki (Hybrid Knowledge Engine, HKE) to make judgments based on accumulated knowledge.

HanTek configured the agent team with three personas.

### Infrastructure Operations Agent

The infrastructure operations agent is responsible for GPU cluster status monitoring, job scheduling optimization, and automatic recovery when anomalies are detected. It continuously collects metrics from Kueue and KAI Scheduler, and autonomously decides to relocate jobs to another cluster when a particular cluster's queue wait time exceeds a threshold.

This agent executes recurring tasks defined in natural language -- such as "generate a GPU utilization report every morning at 7 AM" -- through Paxis's dynamic task scheduler. Operators no longer need to write separate cron scripts; they simply enter the task specification in chat or Slack and the agent self-schedules.

### Model Quality Agent (Benchmark Analyst Persona)

The model quality agent continuously monitors the performance of vision AI models on each line. It analyzes inference latency and accuracy metrics collected from VictoriaMetrics, and automatically triggers the retraining pipeline when performance degradation exceeds a threshold. After retraining completes, it posts a summary of the benchmark results to the ML team's Slack channel.

This agent references the line-by-line model history accumulated in the HKE. Domain knowledge such as "this line's model requires retraining every three months, and the baseline accuracy standard is 98.5% or above" is documented in the wiki, enabling the agent to make contextually informed judgments.

### Operations Report Agent (Report Automation Persona)

The operations report agent automatically generates and distributes daily, weekly, and monthly AI operations reports. It aggregates GPU utilization, inference counts per model, quality anomaly detection events, and retraining status, then formats them into a form management can easily read. Through Paxis's multi-channel delivery capability, reports are simultaneously posted to Slack, email, and web dashboards.

### Agent Team Collaboration Structure

The three agents operate independently but collaborate when needed through Paxis's Multi-Agent Orchestration. For example, when the model quality agent triggers retraining, a cross-agent delegation automatically occurs -- requesting the infrastructure operations agent to secure GPU cluster capacity for training. This delegation process records all decision-making through the Policy Engine and Audit Log.

---

## Multi-Cluster Central Management - GPU Unification Across Multiple Factories

For the agent team to function properly, GPU clusters across multiple factories must be centrally managed under a single control plane. ThakiCloud AI Platform's Multi-Cluster Cloud (MCC) system fills this role.

The diagram below is a simplified representation of HanTek's actual architecture.

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
<div class="d3-arch" data-arch-root id="ringautonomousagentteams-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1939, "height": 644, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 568, "h": 294, "label": "ThakiCloud Control Plane (HA 3-replica)", "lx": 36, "ly": 42}, {"x": 1163, "y": 24, "w": 744, "h": 294, "label": "Paxis Agent Operations Cloud", "lx": 1175, "ly": 42}], "nodes": [{"id": "CP0", "x": 62, "y": 71, "w": 120, "h": 46, "title": "CP-0 Leader"}, {"id": "CP1", "x": 237, "y": 71, "w": 121, "h": 46, "title": "CP-1 Follower"}, {"id": "CP2", "x": 413, "y": 71, "w": 121, "h": 46, "title": "CP-2 Follower"}, {"id": "VK", "x": 161, "y": 217, "w": 205, "h": 62, "title": ["Valkey Leader Election 3s", "TTL"]}, {"id": "INFRA", "x": 1200, "y": 63, "w": 205, "h": 62, "title": ["Infrastructure Operations", "Agent"]}, {"id": "QA", "x": 1460, "y": 71, "w": 163, "h": 46, "title": "Model Quality Agent"}, {"id": "REPORT", "x": 1678, "y": 71, "w": 191, "h": 46, "title": "Operations Report Agent"}, {"id": "HKE", "x": 1487, "y": 225, "w": 177, "h": 46, "title": "HKE Per-Team Wiki RAG"}, {"id": "US", "x": 1037, "y": 410, "w": 212, "h": 62, "title": ["Ulsan MCC Agent", "GPU Cluster Inference-Only"]}, {"id": "CP", "x": 819, "y": 225, "w": 120, "h": 46, "title": "CP"}, {"id": "GU", "x": 777, "y": 410, "w": 205, "h": 62, "title": ["Gumi MCC Agent", "GPU Cluster Training-Only"]}, {"id": "GJ", "x": 545, "y": 410, "w": 177, "h": 62, "title": ["Gwangju MCC Agent", "GPU Cluster Dev/Mixed"]}, {"id": "PAXIS", "x": 819, "y": 71, "w": 120, "h": 46, "title": "PAXIS"}, {"id": "DCGM1", "x": 1075, "y": 550, "w": 135, "h": 62, "title": ["DCGM Exporter", "VictoriaMetrics"]}, {"id": "DCGM2", "x": 812, "y": 550, "w": 135, "h": 62, "title": ["DCGM Exporter", "VictoriaMetrics"]}, {"id": "DCGM3", "x": 566, "y": 550, "w": 135, "h": 62, "title": ["DCGM Exporter", "VictoriaMetrics"]}], "edges": [{"src": "CP0", "dst": "VK", "kind": "data", "curve": [[122, 117], [122, 171], [122, 171], [206, 217]]}, {"src": "CP1", "dst": "VK", "kind": "data", "curve": [[297, 117], [297, 171], [297, 171], [277, 217]]}, {"src": "CP2", "dst": "VK", "kind": "data", "curve": [[473, 117], [473, 171], [473, 171], [348, 217]]}, {"src": "INFRA", "dst": "HKE", "kind": "data", "curve": [[1303, 125], [1303, 171], [1303, 171], [1494, 225]]}, {"src": "QA", "dst": "HKE", "kind": "data", "curve": [[1542, 117], [1542, 171], [1542, 171], [1565, 225]]}, {"src": "REPORT", "dst": "HKE", "kind": "data", "curve": [[1774, 117], [1774, 171], [1774, 171], [1635, 225]]}, {"src": "CP", "dst": "US", "kind": "data", "label": "\"gRPC Bidirectional Stream\"", "curve": [[939, 264], [1143, 318], [1143, 364], [1143, 410]], "off": "50%"}, {"src": "CP", "dst": "GU", "kind": "data", "label": "\"gRPC Bidirectional Stream\"", "line": [879, 271, 879, 410], "lx": 879, "ly": 360}, {"src": "CP", "dst": "GJ", "kind": "data", "label": "\"gRPC Bidirectional Stream\"", "curve": [[819, 265], [633, 318], [633, 364], [633, 410]], "off": "50%"}, {"src": "PAXIS", "dst": "CP", "kind": "data", "label": "\"Kueue Cross-Cluster Scheduling<br/>Model Retraining Trigger<br/>DCGM Metrics Collection\"", "line": [879, 117, 879, 225], "lx": 879, "ly": 167}, {"src": "US", "dst": "DCGM1", "kind": "data", "line": [1143, 472, 1143, 550]}, {"src": "GU", "dst": "DCGM2", "kind": "data", "line": [879, 472, 879, 550]}, {"src": "GJ", "dst": "DCGM3", "kind": "data", "line": [633, 472, 633, 550]}]});
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
      const container = document.getElementById('ringautonomousagentteams-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ringautonomousagentteams-1';
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

### Control Plane and Data Plane Separation

ThakiCloud AI Platform strictly separates the control plane (CP) from the data plane (DP). This separation matters in manufacturing environments because **inference jobs on factory lines continue running even when the CP experiences a failure**. The Ulsan factory's vision AI operates without interruption during CP network disconnections precisely because of this architecture.

An MCC Agent is deployed in each factory cluster. This agent communicates with the CP via gRPC bidirectional streaming, maintaining connectivity through Make-Before-Break reconnection even when network delays occur. Even when a WAN link is completely severed, data plane jobs are unaffected.

### Kueue and KAI Scheduler Cross-Cluster GPU Scheduling

Each factory cluster manages GPU workloads through Kueue and KAI Scheduler. KAI Scheduler calculates inter-cluster scores in order of GPU > CPU > memory > disk to determine optimal placement. The infrastructure operations agent reads this scheduler's metrics and, upon detecting signals such as "Ulsan cluster training queue wait time exceeds 30 minutes," proposes job relocation to the Gumi cluster or executes it automatically [estimate].

When GPU utilization consistently exceeds 80% of the cluster average, a VictoriaMetrics alert triggers and the infrastructure operations agent generates a capacity expansion recommendation report, posting it to the ML team channel.

### DCGM-Based GPU Telemetry Integration

Each cluster's DCGM (Data Center GPU Manager) Exporter collects GPU telemetry into VictoriaMetrics. HanTek previously had to view separately configured Grafana dashboards per factory, but now VictoriaLogs and VictoriaMetrics provide a centrally aggregated single observability layer. The model quality agent directly queries these metrics to detect inference latency anomalies.

### ArgoCD GitOps and Cluster Consistency

Model deployments and configuration changes across the three factory clusters are all managed through ArgoCD using a GitOps approach. When an MCC Agent is registered to a new cluster, an ArgoCD cluster secret is automatically created. When the operations report agent detects an update to a specific model, it creates a PR in the corresponding Git repository [estimate], and ArgoCD automatically deploys it to each factory cluster.

---

## ThakiCloud Application Implications

The practical application insights from the HanTek case are as follows.

**A substantive approach to resolving talent bottlenecks.** Multi-persona agent teams are not designed to replace MLOps engineers, but to delegate repetitive monitoring and reporting tasks. Engineers focus on high-value work such as model architecture improvements and anomaly case analysis, while agents handle day-to-day operations. The long-term value comes from the fact that the more domain knowledge is accumulated in the HKE wiki, the higher the agent's judgment accuracy becomes.

**Operational flexibility through the dynamic task scheduler.** Paxis's dynamic task scheduler allows tasks to be defined in natural language, enabling field operators to set up automation directly without going through the IT department. Specific operational requirements such as "send a summary report of the previous week's quality anomalies to team leaders' email every Monday at 8 AM" can be reflected immediately.

**Visibility through multi-cluster integration.** Multi-cluster management through a single control plane provides at-a-glance visibility into company-wide GPU utilization, job queue status, and per-cluster costs. Policies that were previously impossible -- such as "automatically allow new training jobs when the combined GPU utilization across three factories falls below 60%" -- can now be configured at the control plane level.

**Reliability of the policy engine and audit logs.** In manufacturing environments, traceability of AI-driven decisions is critical. Paxis's Policy Engine and Audit Log record all agent actions and leave an auditable record of what actions were taken based on what rationale. This provides practical assistance in meeting quality certification audits and internal compliance requirements.

---

## Limitations and Considerations

This approach does not apply uniformly to all manufacturing environments. There are practical constraints to examine before adoption.

**Initial domain knowledge construction cost.** Building out the domain knowledge in the HKE wiki that agents will utilize requires upfront investment. Tacit knowledge such as line-specific model characteristics, normal operating ranges, and retraining criteria must be explicitly documented. Deploying agents without this preparation can result in early judgment errors.

**Defining the scope of agent autonomy.** The range of decisions agents can make autonomously must be clearly defined. Model retraining triggers and report generation are well-suited to autonomous execution, but model replacements and cluster reconfigurations that affect production lines are safer to keep under human approval steps. Paxis's Policy Engine allows these boundaries to be configured.

**The reality of network environments.** In domestic heavy-industry factory environments, firewall policies are often strict for connections between internal factory networks and the cloud. It must be verified in advance whether MCC Agent's gRPC connections are permitted and whether WAN bandwidth is stable. For on-premises-only environments, a configuration deploying both CP and DP on-site should be considered.

**Complexity of agent collaboration.** Multi-agent orchestration creates more complex failure scenarios than a single agent. Rollback policies and alerting systems must be designed to handle cases where one agent sends an incorrect cross-agent delegation. While Paxis's Plan-Execute Pipeline structures execution in three stages -- Planner, Executor, and Synthesizer -- sufficient testing for anomaly cases is essential.

**Gradual acquisition of operational maturity.** Delegating all operations to agents from the outset is not recommended. A gradual approach is more realistic: start with low-risk tasks such as reporting automation, verify the quality of the agent's judgments, and expand autonomy only after trust has been established.

---

The talent bottleneck in manufacturing AI operations cannot be solved simply by hiring more people. The sustainable direction for manufacturing AI operations is a structure where autonomous agent teams handle repetitive operational tasks, multi-cluster central management reduces GPU resource waste, and people focus on more complex judgments and improvements. ThakiCloud AI Platform and Paxis provide the concrete technical means to implement this structure.
