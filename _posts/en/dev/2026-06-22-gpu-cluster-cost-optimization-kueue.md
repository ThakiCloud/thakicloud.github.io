---
title: "GPU Cluster Cost Optimization: Kueue Fair-Share + Gang Scheduling + Scale-to-Zero"
excerpt: "How to reclaim tens of millions of dollars annually wasted across three bottlenecks in a 1,000-GPU cluster using Kubernetes-native scheduling."
seo_title: "GPU Cluster Cost Optimization: Kueue Fair-Share, Gang Scheduling, Scale-to-Zero - Thaki Cloud"
seo_description: "A K8s-native architecture that cuts GPU idle costs by 30-50% using Kueue GPU scheduling and vLLM Scale-to-Zero, explained from ThakiCloud's operational perspective."
date: 2026-06-22
last_modified_at: 2026-06-22
lang: en
tags:
  - kueue
  - gpu-scheduling
  - cost-optimization
  - kubernetes
  - vllm
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/dev/gpu-cluster-cost-optimization-kueue/"
reading_time: true
categories:
  - dev
---

![GPU Cluster Cost Optimization - Kueue Fair-Share, Gang Scheduling, Scale-to-Zero Architecture]({{ '/assets/images/gpu-cluster-cost-optimization-kueue-hero.webp' | relative_url }})

## Overview

Every organization running an enterprise GPU cluster faces the same uncomfortable truth: the gap between the scale of hardware investment and actual utilization. When GPU idle rates reach 30-50% across a 1,000-GPU cluster, that translates to tens of millions of dollars in annual waste [estimate/pitch-deck figures]. This is not the hardware cost -- it is the cost of paying for power and cooling while nothing is being computed.

The root of the problem is that humans cannot optimize workload scheduling at machine speed. Distributed training jobs waste partially acquired resources when they cannot simultaneously secure all the GPU pods they need. Multiple teams competing for the same cluster queue leads to priority contention and delays for critical training jobs. Inference services hold GPUs overnight with zero traffic.

ThakiCloud AI Platform addresses these three bottlenecks with a combination of Kueue + the KAI custom scheduler and vLLM + KEDA Scale-to-Zero. This article explains how each mechanism actually works and what architectural decisions make cost reclamation possible.

---

## 3 Points Where GPU Costs Leak

### Point 1: GPU Idling Without Scheduling

When multiple teams share a K8s cluster without queue management, fairness is not guaranteed. The team that runs `kubectl apply` first claims the GPUs, and later requests queue up in a waiting state. When the first team's job finishes, GPUs are released -- but if no job is immediately waiting, they idle briefly. These gaps accumulate across the entire cluster and significantly depress effective utilization.

### Point 2: Delayed Distributed Training Due to Missing Gang Scheduling

Distributed training jobs (DDP, Megatron, DeepSpeed, etc.) can only begin meaningful computation when all worker pods start simultaneously. Without Gang Scheduling, the following happens:

- A job requiring 8 GPUs starts 6 pods but 2 remain Pending due to insufficient nodes
- The 6 running pods hold their GPUs waiting for the 2 Pending pods but perform no computation
- This partial-occupancy state persists for tens of minutes -- sometimes hours

When another team's smaller job enters the cluster in this state, remaining resources fragment further, causing the larger job to wait even longer.

### Point 3: Always-On GPU Occupation by Inference Endpoints

Model-serving endpoints allocate GPU memory when they first start. Inference services deployed without KEDA or a similar autoscaler hold GPUs at 2 AM when there are no requests. For small organizations, occupying 1-2 GPUs unnecessarily may seem minor, but for organizations running dozens of model endpoints the waste grows exponentially.

---

## Kueue Fair-Share + Gang Scheduling

### ClusterQueue and LocalQueue Hierarchy

Kueue is a Kubernetes-native workload queue management system composed of two layers: `ClusterQueue` and `LocalQueue`. `ClusterQueue` defines the GPU allocation policy across the entire cluster; `LocalQueue` is the queue visible to individual namespaces (teams/projects).

```yaml
# Conceptual example -- not a captured execution
apiVersion: kueue.x-k8s.io/v1beta1
kind: ClusterQueue
metadata:
  name: research-cluster-queue
spec:
  namespaceSelector: {}
  resourceGroups:
    - coveredResources: ["cpu", "memory", "nvidia.com/gpu"]
      flavors:
        - name: "h100-flavor"
          resources:
            - name: "nvidia.com/gpu"
              nominalQuota: 64      # Default allocation per team
              borrowingLimit: 32    # Upper limit for borrowing unused quota from other teams
              lendingLimit: 16      # Upper limit for lending to other teams
  cohort: "all-teams"              # Fair-share cohort group
```

The `cohort` field is the heart of fair-share. `ClusterQueue` resources belonging to the same cohort can borrow each other's unused `nominalQuota` within their `borrowingLimit`. If team A is not using its GPUs at night, team B can temporarily borrow them; when team A submits requests again, priority is returned to it.

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
<div class="d3-arch" data-arch-root id="tercostoptimizationkueue-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 676, "height": 446, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "CQ", "x": 235, "y": 24, "w": 198, "h": 94, "title": ["ClusterQueue", "(research-cluster-queue)", "cohort: all-teams", "H100 x 64 nominalQuota"]}, {"id": "LQ_A", "x": 474, "y": 196, "w": 170, "h": 62, "title": ["LocalQueue: team-a", "namespace: ml-team-a"]}, {"id": "LQ_B", "x": 249, "y": 196, "w": 170, "h": 62, "title": ["LocalQueue: team-b", "namespace: ml-team-b"]}, {"id": "LQ_C", "x": 24, "y": 196, "w": 170, "h": 62, "title": ["LocalQueue: team-c", "namespace: ml-team-c"]}, {"id": "WL_A", "x": 485, "y": 336, "w": 149, "h": 78, "title": ["WorkloadAdmission", "Training Job A", "GPU request: 8"]}, {"id": "WL_B", "x": 260, "y": 336, "w": 149, "h": 78, "title": ["WorkloadAdmission", "Inference Batch B", "GPU request: 4"]}, {"id": "WL_C", "x": 35, "y": 336, "w": 149, "h": 78, "title": ["WorkloadAdmission", "Fine-tuning C", "GPU request: 16"]}], "edges": [{"src": "CQ", "dst": "LQ_A", "kind": "data", "curve": [[433, 109], [559, 157], [559, 157], [559, 196]]}, {"src": "CQ", "dst": "LQ_B", "kind": "data", "line": [334, 118, 334, 196]}, {"src": "CQ", "dst": "LQ_C", "kind": "data", "curve": [[235, 109], [109, 157], [109, 157], [109, 196]]}, {"src": "LQ_A", "dst": "WL_A", "kind": "data", "line": [559, 258, 559, 336]}, {"src": "LQ_B", "dst": "WL_B", "kind": "data", "line": [334, 258, 334, 336]}, {"src": "LQ_C", "dst": "WL_C", "kind": "data", "line": [109, 258, 109, 336]}]});
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
      const container = document.getElementById('tercostoptimizationkueue-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'tercostoptimizationkueue-1';
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

In this structure, Kueue tracks each team's `nominalQuota` consumption rate and makes admission decisions to ensure fair distribution within the cohort. When one team is borrowing beyond its `nominalQuota` and another team submits a request, the priority of the borrowing workload is automatically lowered.

### KAI Scheduler and Gang Scheduling

The default Kubernetes scheduler places pods individually. Gang Scheduling is required for workloads like distributed training where all pods must start simultaneously. ThakiCloud implements this through the KAI (Kubernetes AI) custom scheduler plugin.

The core principle of Gang Scheduling is "all-or-nothing." A distributed training job requesting 16 GPUs will not place a single pod on any node until all 16 can be secured simultaneously. This eliminates resource waste from partial occupancy.

```yaml
# Conceptual example -- not a captured execution
apiVersion: batch/v1
kind: Job
metadata:
  name: distributed-training-llama3
  labels:
    kueue.x-k8s.io/queue-name: "team-a-local-queue"   # a label, not an annotation
spec:
  parallelism: 16   # 16 worker pods running concurrently
  completions: 16
  template:
    metadata:
      labels:
        kueue.x-k8s.io/queue-name: "team-a-local-queue"
    spec:
      containers:
        - name: trainer
          resources:
            limits:
              nvidia.com/gpu: "1"
```

Two things are worth flagging here. First, the queue name is a **label, not an annotation**. Second, you don't need to set the Job itself to `suspend: true`. Kueue's mutating webhook suspends the Job at creation time and releases it once quota becomes available, so the admission control point for a batch/v1 Job isn't the pod, it's the Job's **`spec.suspend`**.

If you've seen the `kueue.x-k8s.io/admission` scheduling gate before, that's a real mechanism too, but it belongs to Kueue's **plain Pod integration**, not the Job integration, and Kueue injects it directly rather than it being a field you hand-write into a Job manifest. Mix the two and you won't get the wait behavior you intended.

One operational wrinkle we've actually hit: our cluster runs an admission policy that requires the queue label on pods too, so if you put the label only on the Job and leave it off the pod template, the Job sits there looking `Running` while it has zero pods, quietly. The reason only shows up in the events from `kubectl describe job`. That's why the example above sets the same label on both.

And what actually enforces "all or nothing" is Kueue's `waitForPodsReady` setting. Turn it on and Kueue waits until every pod in the workload is ready, requeuing the workload if the timeout passes before that happens. Once quota is secured and the Job wakes up, the KAI scheduler places all 16 pods on optimal nodes at the same time.

The KAI scheduler also performs topology-aware GPU placement. It preferentially selects nodes within the same InfiniBand-connected rack to minimize communication overhead for distributed training. This directly affects not only GPU utilization but also training speed.

### ResourceFlavor and Heterogeneous Node Handling

Real production environments have a mix of GPU types -- H100, A100, MIG instances, and more. Kueue's `ResourceFlavor` abstracts this heterogeneity.

```yaml
# Conceptual example -- not a captured execution
apiVersion: kueue.x-k8s.io/v1beta1
kind: ResourceFlavor
metadata:
  name: h100-full
spec:
  nodeLabels:
    nvidia.com/gpu.product: "NVIDIA-H100-80GB-HBM3"
---
apiVersion: kueue.x-k8s.io/v1beta1
kind: ResourceFlavor
metadata:
  name: h100-mig-3g
spec:
  nodeLabels:
    nvidia.com/gpu.product: "NVIDIA-H100-80GB-HBM3"
    nvidia.com/mig.profile: "3g.40gb"
```

`ClusterQueue` automatically routes jobs to the appropriate `ResourceFlavor` based on workload characteristics. Small fine-tuning jobs are routed to MIG slices; large pre-training jobs are placed on full GPUs. There is no need to manually write node affinity rules each time.

---

## Inference Costs: vLLM Scale-to-Zero

### KEDA HTTP-Based Autoscaling

Inference services have different characteristics from training workloads. Training continuously consumes GPUs from start to finish, but inference does not need GPUs during periods with no requests.

ThakiCloud operates inference endpoints in a serverless fashion using the vLLM + KEDA combination. It's a structure that watches incoming request volume and automatically adjusts the number of vLLM replicas.

It's worth distinguishing between KEDA's two paths here first. One is the KEDA HTTP Add-on, where its own interceptor takes the HTTP request directly and wakes things up from zero. The other is KEDA core's Prometheus scaler, which queries metrics that are already being collected to adjust replicas. The example below is the latter: we already collect vLLM metrics in VictoriaMetrics, so querying what we already have was simpler than inserting a new interceptor into the request path.

```yaml
# Conceptual example -- not a captured execution
apiVersion: keda.sh/v1alpha1
kind: ScaledObject
metadata:
  name: llm-inference-scaler
spec:
  scaleTargetRef:
    name: vllm-llama3-deployment
  minReplicaCount: 0      # Scale-to-Zero allowed
  maxReplicaCount: 8
  cooldownPeriod: 300     # Wait 5 minutes after last request before scaling to 0
  triggers:
    - type: prometheus
      metadata:
        serverAddress: http://victoria-metrics:8428
        threshold: "10"   # 10 requests per second per replica
        query: sum(rate(vllm_request_success_total[1m]))
```

If you've seen a `metricName` field in older examples, don't include it. The current KEDA Prometheus scaler docs list only `serverAddress`, `query`, `threshold`, `activationThreshold`, `namespace`, `customHeaders`, `ignoreNullValues`, `queryParameters`, and `unsafeSsl`, and `metricName` isn't on that list. What you scale on is decided by `query`.

`minReplicaCount: 0` is the key to Scale-to-Zero. When there are no requests at 2 AM, the vLLM pod scales to zero and returns the GPU. When the first request arrives at the start of business, KEDA starts the pod, vLLM loads the model into GPU memory, and the response is returned.

### Cold Start Latency Trade-off

The obvious downside of Scale-to-Zero is cold start latency. Loading a 7B parameter model into vLLM can take tens of seconds. This is addressed with one of three strategies depending on SLA requirements.

First, setting `minReplicaCount: 1` to always maintain at least one replica. This trades the cost of permanently occupying one GPU for responsiveness without cold starts.

Second, setting up a business-hours-based pre-warm schedule. A CronJob or external scheduler raises the replica count to 1 thirty minutes before business starts, then scales to zero after business ends.

Third, using vLLM's quantization to reduce load time itself. Models in AWQ or GPTQ format have significantly shorter load times compared to FP16.

To maximize cost savings while maintaining responsiveness, the practical approach is to check actual traffic patterns for the endpoint in VictoriaMetrics, then tune the `cooldownPeriod` and `minReplicaCount` combination to match usage patterns.

---

## Cost Visibility: DCGM/VictoriaMetrics

### GPU Telemetry Collection Structure

To optimize costs, you must know precisely what is being consumed and how much. ThakiCloud uses the NVIDIA DCGM Exporter to collect fine-grained GPU-level telemetry and stores it long-term in VictoriaMetrics.

The key metrics exposed by DCGM Exporter are as follows.

| Metric | Description | Cost Analysis Use |
|--------|-------------|-------------------|
| `DCGM_FI_DEV_GPU_UTIL` | GPU compute unit utilization (%) | Effective utilization baseline |
| `DCGM_FI_DEV_MEM_COPY_UTIL` | GPU memory bandwidth utilization | Memory-bound bottleneck diagnosis |
| `DCGM_FI_DEV_FB_USED` | GPU framebuffer usage (MiB) | Model load state verification |
| `DCGM_FI_PROF_PIPE_TENSOR_ACTIVE` | Tensor core active ratio | Whether actual AI computation is occurring |

When `DCGM_FI_DEV_GPU_UTIL` is low but `DCGM_FI_DEV_FB_USED` is high, the GPU is occupying memory but not computing. This is the direct target of Scale-to-Zero.

### Per-Team GPU Cost Attribution

Combining telemetry stored in VictoriaMetrics with Kubernetes labels enables tracking GPU consumption by team and project. Since Kueue's `LocalQueue` maps 1:1 to namespaces, aggregating GPU usage by namespace labels reveals each team's actual consumption.

```
# VictoriaMetrics query example (MetricsQL)
# Average GPU utilization by namespace (last 24 hours)
avg by (namespace) (
  avg_over_time(DCGM_FI_DEV_GPU_UTIL{kubernetes_namespace!=""}[24h])
)
```

Visualizing this data on a dashboard allows administrators to see which teams use their allocated GPUs efficiently and which jobs occupy GPUs for long periods with low utilization.

---

## ThakiCloud Implementation Implications

ThakiCloud AI Platform's data plane logically separates inference clusters, training clusters, and development clusters, while deploying the same Kueue + KAI + KEDA stack to each cluster. The Multi-Cluster Control (MCC) management layer provides integrated visibility into queue status across all clusters from a single control plane.

Through ArgoCD GitOps, scheduling policies such as `ClusterQueue`, `ResourceFlavor`, and `ScaledObject` are managed declaratively from a Git repository. When onboarding a new team or adjusting `nominalQuota`, changes are proposed via PR and reviewed before being applied to the cluster -- rather than using `kubectl apply` directly. This guarantees an audit trail for policy changes and prevents accidental resource over-allocation.

Cluster scaling triggers can also be automated based on metrics. When Kueue queue wait times in VictoriaMetrics continuously exceed 30 minutes, an alert is generated and used as a signal for adding new GPU nodes. When GPU utilization maintains a cluster average of 80% for more than 30 days, a review of the next 72-GPU unit expansion is initiated.

---

## Limitations and Considerations

### Kueue Maturity and Ecosystem Dependencies

Kueue is a CNCF project but still relatively young. Major workload types including Kubeflow, Ray, and standard Jobs are supported, but some custom CRD-based frameworks may require additional integration work. Before adoption, it is important to verify that your ML frameworks are compatible with Kueue.

### Gang Scheduling and Cluster Fragmentation

Gang Scheduling resolves fragmentation but simultaneously creates new trade-offs. When a cluster has 8 GPUs spread 4 per node across 2 nodes, a job requesting all 8 simultaneously may wait a long time due to Gang Scheduling. In such cases, bin-packing and Gang Scheduling policies must be combined and tuned to the situation.

### Operational Complexity of Scale-to-Zero

As the number of inference endpoints grows, so does the number of KEDA ScaledObjects. Setting and maintaining appropriate `cooldownPeriod`, `threshold`, and `minReplicaCount` for each endpoint becomes an operational burden. To reduce this, the practical approach is to classify endpoints by SLA tier and manage standardized templates per tier.

### Prerequisite for GPU Cost Reduction: Accurate Metrics

The `GPU_UTIL` value collected by DCGM Exporter represents the SM (Streaming Multiprocessor) active ratio. A low value does not unconditionally mean idle state. Low SM utilization due to memory copies or communication waits is a workload optimization problem, not a scheduling problem. For accurate diagnosis when interpreting telemetry, composite analysis of SM utilization, memory bandwidth, and tensor core active rate is required -- not a single metric.

---

A GPU cluster is itself a vast resource, but without scheduling policy its potential goes unfulfilled. The three-way combination of Kueue fair-share to resolve queue contention, Gang Scheduling to eliminate distributed training wait time, and Scale-to-Zero to block idle inference costs is the practical starting point for Kubernetes-native GPU cost optimization.

## Sources

- [ClusterQueue, Cohort, Fair Sharing (Kueue Docs)](https://kueue.sigs.k8s.io/docs/concepts/cluster_queue/)
- [LocalQueue Concept (Kueue Docs)](https://kueue.sigs.k8s.io/docs/concepts/local_queue/)
- [ResourceFlavor Concept (Kueue Docs)](https://kueue.sigs.k8s.io/docs/concepts/resource_flavor/)
- [Gang Scheduling via waitForPodsReady (Kueue Docs)](https://kueue.sigs.k8s.io/docs/tasks/manage/setup_wait_for_pods_ready/)
- [Preemption and Quota Reclamation (Kueue Docs)](https://kueue.sigs.k8s.io/docs/concepts/preemption/)
- [KAI Scheduler: Gang Scheduling, Topology Aware Placement (NVIDIA, GitHub)](https://github.com/NVIDIA/KAI-Scheduler)
- [KEDA HTTP Add-on (KEDA Core, GitHub)](https://github.com/kedacore/http-add-on)
- [ScaledObject Specification (KEDA Docs)](https://keda.sh/docs/2.15/reference/scaledobject-spec/)
- [Prometheus Scaler (KEDA Docs)](https://keda.sh/docs/2.15/scalers/prometheus/)
- [Quantization Support (vLLM Docs)](https://docs.vllm.ai/en/latest/features/quantization/index.html)
- [Default GPU Metrics Counters (NVIDIA dcgm-exporter, GitHub)](https://github.com/NVIDIA/dcgm-exporter/blob/main/etc/default-counters.csv)
- [MetricsQL Query Language (VictoriaMetrics Docs)](https://docs.victoriametrics.com/metricsql/)
