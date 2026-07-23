---
title: "Helm Dashboard: Complete Guide to Kubernetes Helm Charts UI Management"
excerpt: "A comprehensive tutorial on Helm Dashboard - the missing UI for Helm that simplifies Kubernetes chart management with visual interface, revision history, and easy rollback capabilities."
seo_title: "Helm Dashboard Tutorial: Kubernetes Helm Charts UI Guide - Thaki Cloud"
seo_description: "Learn how to install and use Helm Dashboard for Kubernetes. Complete guide covering installation methods, chart management, rollback operations, and best practices for Helm UI."
date: 2025-10-10
tags:
  - helm
  - kubernetes
  - helm-dashboard
  - k8s
  - devops
  - helm-plugin
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/helm-dashboard-kubernetes-ui-complete-guide/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/helm-dashboard-kubernetes-ui-complete-guide-en/"
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

Managing Helm charts in Kubernetes can be challenging when you're limited to command-line interfaces. **Helm Dashboard** is an open-source project that provides a user-friendly web interface for viewing installed Helm charts, examining revision history, and performing operations like rollbacks and upgrades with visual manifest diffs.

This comprehensive tutorial will guide you through installing Helm Dashboard, exploring its features, and leveraging it for efficient Kubernetes chart management.

### What is Helm Dashboard?

Helm Dashboard is an open-source tool developed by Komodor that offers a UI-driven approach to working with Helm charts. Unlike the traditional Helm CLI, it provides:

- **Visual chart management**: See all installed charts at a glance
- **Revision history**: Track changes across chart versions
- **Manifest diff viewer**: Compare configurations between revisions
- **Resource browsing**: Explore Kubernetes resources created by charts
- **Easy operations**: Perform rollbacks and upgrades with confidence
- **Multi-cluster support**: Switch between different Kubernetes clusters
- **Standalone operation**: Works without requiring Helm or kubectl installed

The diagram below shows how Helm Dashboard sits between the browser and multiple Kubernetes clusters. A single server connects to clusters through kubeconfig contexts, reads the revision history stored in release secrets, and gathers everything from viewing to rollback into one screen.

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
<div class="d3-arch" data-arch-root id="ernetesuicompleteguideen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1238, "height": 738, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 293, "y": 24, "w": 913, "h": 124, "label": "Dashboard core features", "lx": 305, "ly": 42}], "nodes": [{"id": "USER", "x": 113, "y": 63, "w": 142, "h": 46, "title": "Operator browser"}, {"id": "UI", "x": 96, "y": 226, "w": 177, "h": 46, "title": "Helm Dashboard web UI"}, {"id": "SRV", "x": 96, "y": 350, "w": 177, "h": 78, "title": ["Helm Dashboard server", "Single Go binary, no", "kubectl needed"]}, {"id": "K1", "x": 424, "y": 520, "w": 170, "h": 46, "title": "Kubernetes cluster A"}, {"id": "K2", "x": 199, "y": 520, "w": 170, "h": 46, "title": "Kubernetes cluster B"}, {"id": "REL", "x": 410, "y": 644, "w": 198, "h": 62, "title": ["Helm release secrets", "Revision history storage"]}, {"id": "F1", "x": 330, "y": 63, "w": 205, "h": 46, "title": "View charts and revisions"}, {"id": "F2", "x": 590, "y": 63, "w": 149, "h": 46, "title": "Compare manifests"}, {"id": "F3", "x": 794, "y": 63, "w": 170, "h": 46, "title": "Rollback and upgrade"}, {"id": "F4", "x": 1019, "y": 63, "w": 149, "h": 46, "title": "Explore resources"}, {"id": "FEAT", "x": 24, "y": 520, "w": 120, "h": 46, "title": "FEAT"}], "edges": [{"src": "USER", "dst": "UI", "kind": "data", "line": [184, 109, 184, 226]}, {"src": "UI", "dst": "SRV", "kind": "data", "line": [184, 272, 184, 350]}, {"src": "SRV", "dst": "K1", "kind": "data", "label": "\"kubeconfig contexts\"", "curve": [[273, 412], [509, 474], [509, 474], [509, 520]], "off": "50%"}, {"src": "SRV", "dst": "K2", "kind": "data", "label": "\"Multi-cluster switching\"", "curve": [[230, 428], [284, 474], [284, 474], [284, 520]], "off": "50%"}, {"src": "K1", "dst": "REL", "kind": "data", "line": [509, 566, 509, 644]}, {"src": "SRV", "dst": "FEAT", "kind": "data", "curve": [[138, 428], [84, 474], [84, 474], [84, 520]]}]});
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
      const container = document.getElementById('ernetesuicompleteguideen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ernetesuicompleteguideen-1';
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

### Why Use Helm Dashboard?

Traditional Helm management requires remembering numerous CLI commands and piecing together information from multiple sources. Helm Dashboard solves this by:

1. **Reducing cognitive load**: Visual interface eliminates the need to memorize complex commands
2. **Improving visibility**: See the complete state of your Helm releases in one place
3. **Preventing mistakes**: Visual diff shows exactly what will change before applying updates
4. **Accelerating troubleshooting**: Quickly identify problematic revisions and roll back
5. **Enhancing collaboration**: Team members can explore charts without deep Helm expertise

## Prerequisites

Before starting this tutorial, ensure you have:

- **Kubernetes cluster**: A running cluster (minikube, kind, or production cluster)
- **Basic Kubernetes knowledge**: Understanding of pods, services, and deployments
- **macOS, Linux, or Windows**: Helm Dashboard supports all major platforms
- **Web browser**: Modern browser for accessing the dashboard UI

**Note**: Helm and kubectl are **NOT** required when using the standalone binary installation method.

## Installation Methods

Helm Dashboard offers three installation approaches, each suited for different use cases.

### Method 1: Standalone Binary (Recommended)

The standalone binary is the simplest and most flexible installation method. It doesn't require Helm or kubectl to be installed on your system.

#### Step 1: Download the Binary

Visit the [Helm Dashboard releases page](https://github.com/komodorio/helm-dashboard/releases) and download the appropriate package for your platform:

```bash
# For macOS (Apple Silicon)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Darwin_arm64.tar.gz
tar -xzf helm-dashboard_Darwin_arm64.tar.gz

# For macOS (Intel)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Darwin_x86_64.tar.gz
tar -xzf helm-dashboard_Darwin_x86_64.tar.gz

# For Linux (AMD64)
curl -LO https://github.com/komodorio/helm-dashboard/releases/latest/download/helm-dashboard_Linux_x86_64.tar.gz
tar -xzf helm-dashboard_Linux_x86_64.tar.gz
```

#### Step 2: Make it Executable and Run

```bash
chmod +x dashboard
./dashboard
```

The dashboard will start a web server on `http://localhost:8080` and automatically open your browser.

### Method 2: Helm Plugin Installation

If you already use Helm and prefer plugin-based tools, install Helm Dashboard as a Helm plugin.

#### Requirements
- Helm 3.4.0 or later
- kubectl configured with cluster access

#### Installation

```bash
# Install the plugin
helm plugin install https://github.com/komodorio/helm-dashboard.git

# Verify installation
helm plugin list
```

#### Usage

```bash
# Start the dashboard
helm dashboard

# Start with custom port
helm dashboard --port 9090

# Start without auto-opening browser
helm dashboard --no-browser

# Limit to specific namespace
helm dashboard --namespace production
```

#### Plugin Management

```bash
# Update the plugin
helm plugin update dashboard

# Uninstall the plugin
helm plugin uninstall dashboard
```

### Method 3: Deploy to Kubernetes Cluster

For team environments, deploy Helm Dashboard directly into your Kubernetes cluster using the official Helm chart.

```bash
# Add the Helm Dashboard repository
helm repo add komodorio https://helm-charts.komodor.io
helm repo update

# Install into your cluster
helm install helm-dashboard komodorio/helm-dashboard \
  --namespace helm-dashboard \
  --create-namespace

# Access via port-forward
kubectl port-forward -n helm-dashboard svc/helm-dashboard 8080:8080
```

Then navigate to `http://localhost:8080` in your browser.

## Testing the Installation

Let's verify that Helm Dashboard is working correctly by installing a sample chart and exploring it through the UI.

### Step 1: Create Test Script

```bash
#!/bin/bash
# File: test-helm-dashboard.sh

set -e

echo "🚀 Testing Helm Dashboard Installation..."

# Check if kubectl is available
if ! command -v kubectl &> /dev/null; then
    echo "❌ kubectl is not installed. Please install kubectl first."
    exit 1
fi

# Check cluster connectivity
if ! kubectl cluster-info &> /dev/null; then
    echo "❌ Cannot connect to Kubernetes cluster. Please configure kubectl."
    exit 1
fi

# Create test namespace
echo "📦 Creating test namespace..."
kubectl create namespace helm-dashboard-test --dry-run=client -o yaml | kubectl apply -f -

# Install a sample chart (nginx)
echo "📥 Installing sample nginx chart..."
helm repo add bitnami https://charts.bitnami.com/bitnami
helm repo update

helm install test-nginx bitnami/nginx \
  --namespace helm-dashboard-test \
  --set service.type=ClusterIP \
  --wait

# Verify installation
echo "✅ Verifying installation..."
helm list -n helm-dashboard-test

echo ""
echo "✨ Success! You can now:"
echo "1. Start Helm Dashboard: ./dashboard (or helm dashboard)"
echo "2. Navigate to: http://localhost:8080"
echo "3. Select 'helm-dashboard-test' namespace"
echo "4. View the 'test-nginx' release"
echo ""
echo "🧹 To cleanup: kubectl delete namespace helm-dashboard-test"
```

### Step 2: Run the Test

```bash
chmod +x test-helm-dashboard.sh
./test-helm-dashboard.sh
```

### Step 3: Explore the Dashboard

1. **Start Dashboard**: Run `./dashboard` or `helm dashboard`
2. **Open Browser**: Navigate to `http://localhost:8080`
3. **Select Namespace**: Choose `helm-dashboard-test` from the dropdown
4. **View Release**: Click on the `test-nginx` release

You should see detailed information about the nginx deployment, including:
- Chart version and app version
- Installation timestamp
- Current status
- List of Kubernetes resources created

## Core Features and Usage

### 1. Viewing Installed Charts

The main dashboard view displays all Helm releases across selected namespaces:

- **Release name**: The name you gave during installation
- **Namespace**: Where the chart is deployed
- **Chart version**: The version of the Helm chart
- **App version**: The version of the application being deployed
- **Status**: Current state (deployed, failed, pending-upgrade, etc.)
- **Updated**: Last modification timestamp

**Navigation Tips**:
- Use the namespace filter to focus on specific namespaces
- Click on any release to view detailed information
- Use the search box to quickly find releases by name

### 2. Examining Revision History

Every Helm release maintains a history of all revisions. To view revision history:

1. Click on a release name
2. Navigate to the **History** tab
3. Review the list of revisions showing:
   - Revision number
   - Updated timestamp
   - Status (superseded, deployed, failed)
   - Chart version
   - Description of changes

**Use Cases**:
- Track who made changes and when
- Understand the evolution of your deployment
- Identify when issues were introduced

### 3. Comparing Manifest Diffs

One of Helm Dashboard's most powerful features is the ability to compare manifests between revisions:

1. Open a release's history
2. Select two revisions to compare
3. Click **Diff** to see a side-by-side comparison
4. Review added (green), removed (red), and changed (yellow) lines

**Why This Matters**:
- Understand exactly what changed between versions
- Identify configuration issues
- Make informed rollback decisions
- Verify upgrade changes before applying

### 4. Browsing Kubernetes Resources

Helm Dashboard allows you to explore all Kubernetes resources created by a chart:

1. Click on a release
2. Navigate to the **Resources** tab
3. View categorized resources:
   - Workloads (Deployments, StatefulSets, DaemonSets)
   - Services and Ingresses
   - ConfigMaps and Secrets
   - PersistentVolumeClaims
   - Other custom resources

**Interactive Features**:
- Click on any resource to view its YAML definition
- Check resource status and health
- Identify resource relationships

### 5. Performing Rollbacks

When you need to revert to a previous version:

1. Open the release's history
2. Locate the revision you want to roll back to
3. Click the **Rollback** button
4. Review the manifest diff showing what will change
5. Confirm the rollback operation

**Best Practices**:
- Always review the diff before rolling back
- Document the reason for rollback
- Monitor the application after rollback
- Consider fixing forward instead of rolling back when possible

### 6. Upgrading Charts

To upgrade a chart to a newer version:

1. Click on a release
2. Click the **Upgrade** button
3. Select the new chart version
4. Modify values if needed
5. Review the manifest diff
6. Confirm and apply the upgrade

**Upgrade Workflow**:
```yaml
Current Version: nginx-15.0.0
Target Version: nginx-15.1.0

# Dashboard shows:
- What values will change
- What resources will be modified
- What resources will be added/removed
```

### 7. Multi-Cluster Management

Helm Dashboard can work with multiple Kubernetes clusters:

1. Ensure your kubeconfig includes multiple contexts
2. Use the cluster selector dropdown in the UI
3. Switch between clusters seamlessly

**Configuration Example**:
```bash
# List available contexts
kubectl config get-contexts

# Switch context via kubectl
kubectl config use-context production-cluster

# Dashboard will automatically detect the change
```

## Advanced Configuration

### Custom Port and Binding

By default, Helm Dashboard binds to `localhost:8080`. To customize:

```bash
# Using flag
./dashboard --port 9090 --bind=0.0.0.0

# Using environment variable
export HD_BIND=0.0.0.0
export HD_PORT=9090
./dashboard
```

**Security Warning**: Binding to `0.0.0.0` exposes the dashboard to all network interfaces. Only do this in secure environments.

### Namespace Filtering

Limit dashboard operations to specific namespaces:

```bash
# Single namespace
./dashboard --namespace production

# Multiple namespaces
./dashboard --namespace="production,staging,development"
```

### Verbose Logging

Enable detailed logging for troubleshooting:

```bash
./dashboard --verbose
```

This provides:
- HTTP request logs
- Helm operation details
- Error stack traces
- Performance metrics

### Disabling Analytics

Helm Dashboard collects anonymous usage analytics to improve the project. To disable:

```bash
./dashboard --no-analytics
```

### Browser Control

Prevent automatic browser opening:

```bash
./dashboard --no-browser
```

Then manually navigate to the displayed URL.

## Real-World Use Cases

### Use Case 1: Debugging Failed Deployments

**Scenario**: A chart upgrade failed and you need to understand why.

**Solution with Helm Dashboard**:
1. Open the release in dashboard
2. Check the **History** tab - you'll see a revision marked as "failed"
3. Compare the failed revision with the previous successful one using **Diff**
4. Identify the problematic configuration change
5. Rollback to the last working revision
6. Fix the issue and retry the upgrade

**Time Saved**: What took 15-20 minutes with CLI commands takes 2-3 minutes with visual comparison.

### Use Case 2: Onboarding New Team Members

**Scenario**: New developers need to understand the deployed applications.

**Solution with Helm Dashboard**:
1. Share the dashboard URL (if deployed in-cluster)
2. New team members can explore:
   - What applications are running
   - How they're configured
   - What resources they use
   - Their deployment history
3. No need to learn Helm CLI immediately

**Benefit**: Reduces onboarding time from days to hours.

### Use Case 3: Change Auditing

**Scenario**: You need to create an audit trail of infrastructure changes.

**Solution with Helm Dashboard**:
1. Use the **History** tab to review all changes
2. Export revision information
3. Compare manifests to see exact changes
4. Document who made changes and when

**Compliance**: Helps meet audit requirements for regulated industries.

### Use Case 4: Safe Production Deployments

**Scenario**: Upgrading a critical production service requires careful validation.

**Solution with Helm Dashboard**:
1. Test the upgrade in staging environment first
2. Use dashboard to compare staging vs production configurations
3. Review manifest diff for the production upgrade
4. Verify no unexpected changes
5. Proceed with confidence or abort if issues detected

**Risk Mitigation**: Prevents production incidents caused by configuration drift.

## Troubleshooting Common Issues

### Issue 1: Dashboard Won't Start

**Symptoms**: Error message when running `./dashboard`

**Solutions**:

```bash
# Check if port 8080 is already in use
lsof -i :8080

# Use a different port
./dashboard --port 8081

# Check Kubernetes connectivity
kubectl cluster-info

# Verify kubeconfig
kubectl config view
```

### Issue 2: No Releases Showing

**Symptoms**: Dashboard loads but shows no releases

**Possible Causes**:
1. Wrong namespace selected
2. No Helm releases installed
3. Insufficient RBAC permissions

**Solutions**:

```bash
# List all releases in all namespaces
helm list --all-namespaces

# Check current namespace context
kubectl config view --minify | grep namespace:

# Verify RBAC permissions
kubectl auth can-i list secrets
kubectl auth can-i get secrets
```

### Issue 3: Cannot Connect to Cluster

**Symptoms**: Error about Kubernetes connection failure

**Solutions**:

```bash
# Verify cluster is running
kubectl cluster-info

# Check kubeconfig path
echo $KUBECONFIG
ls -la ~/.kube/config

# Test connection
kubectl get nodes

# For minikube users
minikube status
minikube start
```

### Issue 4: Diff Not Showing

**Symptoms**: Manifest diff appears empty

**Possible Causes**:
1. Comparing identical revisions
2. Large manifests timing out
3. Browser caching issues

**Solutions**:
1. Refresh the browser page
2. Clear browser cache
3. Try a different browser
4. Check verbose logs for errors

## Security Considerations

### Access Control

Helm Dashboard inherits permissions from the kubeconfig it uses. To limit access:

1. **Service Account**: Create a dedicated service account with limited permissions
2. **RBAC**: Define specific roles for Helm Dashboard operations
3. **Namespace Isolation**: Use namespace-scoped service accounts

```yaml
apiVersion: v1
kind: ServiceAccount
metadata:
  name: helm-dashboard-readonly
  namespace: helm-dashboard
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRole
metadata:
  name: helm-dashboard-readonly
rules:
- apiGroups: [""]
  resources: ["secrets", "configmaps"]
  verbs: ["get", "list"]
- apiGroups: [""]
  resources: ["pods", "services"]
  verbs: ["get", "list"]
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: helm-dashboard-readonly
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: helm-dashboard-readonly
subjects:
- kind: ServiceAccount
  name: helm-dashboard-readonly
  namespace: helm-dashboard
```

### Network Security

When exposing Helm Dashboard:

1. **Local Only**: Default `localhost` binding is safest for single-user scenarios
2. **Internal Network**: Use `0.0.0.0` only within trusted networks
3. **Authentication**: Consider adding authentication proxy (OAuth2 Proxy, Pomerium)
4. **TLS**: Use TLS for any external exposure
5. **Firewall**: Restrict access to authorized IP ranges

### Secret Management

Helm Dashboard can view Kubernetes secrets that store Helm release data:

1. **Principle of Least Privilege**: Only grant necessary permissions
2. **Audit Logging**: Enable Kubernetes audit logs to track secret access
3. **Secret Encryption**: Ensure etcd encryption is enabled
4. **Regular Review**: Periodically review who has access

## Performance Optimization

### For Large Clusters

If you manage many Helm releases:

1. **Namespace Filtering**: Use `--namespace` to limit scope
2. **Resource Limits**: When deployed in-cluster, set appropriate resource limits
3. **Caching**: Helm Dashboard caches release data - adjust cache settings if needed

```yaml
# When deploying to cluster
resources:
  limits:
    cpu: 500m
    memory: 512Mi
  requests:
    cpu: 100m
    memory: 128Mi
```

### Browser Performance

For manifests with thousands of lines:

1. **Use Diff Selectively**: Only compare when necessary
2. **Close Unused Tabs**: Dashboard uses WebSocket connections
3. **Modern Browser**: Use latest Chrome/Firefox/Safari for best performance

## Integration with CI/CD

Helm Dashboard can complement your CI/CD pipeline:

### GitOps Workflow

```bash
# Deploy Helm Dashboard to cluster
helm install helm-dashboard komodorio/helm-dashboard

# Team uses dashboard to:
# 1. Monitor deployments triggered by ArgoCD/Flux
# 2. Verify changes match Git commits
# 3. Quickly rollback if issues detected
```

### Staging Validation

```bash
# In CI pipeline (example with GitHub Actions)
- name: Deploy to Staging
  run: helm upgrade --install myapp ./charts/myapp -n staging

- name: Verify with Dashboard
  run: |
    # Open dashboard for manual verification
    echo "Review deployment at: http://dashboard.staging.example.com"
    echo "Compare revisions and verify changes"
```

### Deployment Notifications

Combine with monitoring tools:

```bash
# After deployment
helm upgrade --install myapp ./charts/myapp

# Notify team with dashboard link
slack-notify "New deployment ready. Review: http://dashboard/myapp"
```

## Comparison with Alternatives

| Feature | Helm Dashboard | K9s | Lens | Rancher |
|---------|---------------|-----|------|---------|
| Helm-specific UI | ✅ | ❌ | Partial | ✅ |
| Revision diff | ✅ | ❌ | ❌ | ✅ |
| Standalone binary | ✅ | ✅ | ✅ | ❌ |
| Multi-cluster | ✅ | ✅ | ✅ | ✅ |
| Web-based | ✅ | ❌ | ❌ (Desktop) | ✅ |
| Open source | ✅ | ✅ | ✅ | ✅ |
| Learning curve | Low | Medium | Low | High |

**When to Use Helm Dashboard**:
- Primary focus is Helm release management
- Need visual manifest comparison
- Want web-based access
- Prefer lightweight solution

**When to Use Alternatives**:
- **K9s**: For terminal-based workflow, broader K8s management
- **Lens**: For comprehensive desktop IDE experience
- **Rancher**: For enterprise multi-cluster management with additional features

## Best Practices

### 1. Regular Updates

Keep Helm Dashboard updated:

```bash
# For plugin installation
helm plugin update dashboard

# For standalone binary
# Download latest release periodically
```

### 2. Document Your Releases

Use Helm's `--description` flag to document changes:

```bash
helm upgrade myapp ./charts/myapp \
  --description "Updated to v2.0.0 - Added new API endpoints"
```

This description appears in Dashboard's history view.

### 3. Use Semantic Versioning

Follow semantic versioning for your charts:

```yaml
# Chart.yaml
version: 2.1.0  # MAJOR.MINOR.PATCH
appVersion: 1.16.0
```

Dashboard's history becomes more meaningful with clear version progression.

### 4. Review Before Applying

Always use Dashboard's diff feature before:
- Upgrading to a new version
- Rolling back to a previous version
- Applying value changes

### 5. Combine with GitOps

Use Dashboard for monitoring and troubleshooting, while maintaining Git as source of truth:

```bash
# Git remains source of truth
git commit -m "Update myapp to v2.0.0"
git push

# ArgoCD/Flux applies changes
# Use Dashboard to monitor and verify
```

### 6. Namespace Strategy

Organize releases by environment using namespaces:

```bash
# Development
helm install myapp ./charts/myapp -n dev

# Staging
helm install myapp ./charts/myapp -n staging

# Production
helm install myapp ./charts/myapp -n production
```

Use Dashboard's namespace filter to switch between environments.

### 7. Backup Release Secrets

Helm stores release data in Kubernetes secrets. Back them up:

```bash
# Backup all Helm release secrets
kubectl get secrets -A -l owner=helm -o yaml > helm-releases-backup.yaml

# Restore if needed
kubectl apply -f helm-releases-backup.yaml
```

## Clean Up Test Resources

After completing this tutorial, clean up the test resources:

```bash
#!/bin/bash
# cleanup-helm-dashboard-test.sh

echo "🧹 Cleaning up Helm Dashboard test resources..."

# Uninstall test release
helm uninstall test-nginx -n helm-dashboard-test

# Delete test namespace
kubectl delete namespace helm-dashboard-test

# Remove downloaded binaries (optional)
# rm -f dashboard helm-dashboard_*.tar.gz

echo "✅ Cleanup complete!"
```

Run the cleanup script:

```bash
chmod +x cleanup-helm-dashboard-test.sh
./cleanup-helm-dashboard-test.sh
```

## Conclusion

Helm Dashboard bridges the gap between the powerful Helm CLI and the need for visual management tools. By providing an intuitive web interface, it makes Helm chart management accessible to both experts and newcomers.

### Key Takeaways

1. **Easy Installation**: Multiple installation methods suit different environments
2. **Visual Management**: See your Helm releases at a glance
3. **Safe Operations**: Diff feature prevents configuration mistakes
4. **Team Collaboration**: Lower barrier to entry for team members
5. **Troubleshooting**: Quickly identify and resolve deployment issues
6. **Production Ready**: Suitable for both development and production environments

### Next Steps

To continue your Helm Dashboard journey:

1. **Deploy to Your Cluster**: Move from local binary to in-cluster deployment
2. **Integrate with CI/CD**: Incorporate dashboard into your deployment workflow
3. **Explore Advanced Features**: Try integration with problem scanners
4. **Contribute**: Consider contributing to the [open-source project](https://github.com/komodorio/helm-dashboard)
5. **Join Community**: Connect with other users on Slack

### Additional Resources

- **Official Repository**: [https://github.com/komodorio/helm-dashboard](https://github.com/komodorio/helm-dashboard)
- **Helm Documentation**: [https://helm.sh/docs/](https://helm.sh/docs/)
- **Kubernetes Documentation**: [https://kubernetes.io/docs/](https://kubernetes.io/docs/)
- **Feature Overview**: [FEATURES.md](https://github.com/komodorio/helm-dashboard/blob/main/FEATURES.md)

Helm Dashboard demonstrates that powerful tools don't have to be complex. By making Helm more accessible, it helps teams manage Kubernetes applications more confidently and efficiently. Whether you're a solo developer or part of a large team, Helm Dashboard can improve your Kubernetes workflow.

Happy charting! 🚀

