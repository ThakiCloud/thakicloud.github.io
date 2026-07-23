---
title: "Neosync Complete Tutorial: Data Anonymization and Synthetic Data Generation"
excerpt: "Complete guide to Neosync - Open-source data security platform for PII anonymization, synthetic data generation, and environment synchronization with practical examples"
seo_title: "Neosync Tutorial: Data Anonymization & Synthetic Data Guide - Thaki Cloud"
seo_description: "Learn Neosync open-source platform for data anonymization, synthetic data generation, and secure environment sync. Complete tutorial with Docker setup and examples."
date: 2025-08-26
tags:
  - neosync
  - data-anonymization
  - synthetic-data
  - docker
  - postgresql
  - privacy
  - gdpr
  - data-security
author_profile: true
toc: true
toc_label: "Contents"
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/neosync-data-anonymization-synthetic-data-complete-tutorial/"
lang: en
permalink: /en/tutorials/neosync-data-anonymization-synthetic-data-complete-tutorial/
published: false
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction to Neosync

[**Neosync**](https://github.com/nucleuscloud/neosync) is an open-source, developer-first platform that revolutionizes how organizations handle sensitive data. It provides comprehensive solutions for **data anonymization**, **synthetic data generation**, and **environment synchronization** to help companies safely test against production-like data while maintaining compliance with privacy regulations like GDPR, HIPAA, and FERPA.

### Why Neosync Matters

In today's data-driven development landscape, developers need access to realistic data for testing, debugging, and development. However, using actual production data poses significant security and compliance risks. Neosync bridges this gap by providing:

1. **Safe Production Data Testing** - Anonymize sensitive production data for local development
2. **Production Bug Reproduction** - Create safe, representative datasets for debugging
3. **High-Quality Test Data** - Generate production-like data for staging and QA environments
4. **Compliance Solution** - Reduce compliance scope for GDPR, HIPAA, FERPA regulations
5. **Development Database Seeding** - Create synthetic data for unit testing and demos

### Key Features Overview

- **Synthetic Data Generation** based on your existing schema
- **Production Data Anonymization** with referential integrity preservation
- **Database Subsetting** using SQL queries for focused testing
- **Async Pipeline Architecture** with automatic retries and failure handling
- **GitOps Integration** for declarative configuration management
- **Built-in Transformers** for major data types (emails, names, addresses, etc.)
- **Custom Transformers** using JavaScript or LLMs
- **Multiple Database Support** - PostgreSQL, MySQL, and S3 integration

## Prerequisites and Environment Setup

### System Requirements

Before starting this tutorial, ensure you have:

- **Docker & Docker Compose** (latest version)
- **Git** for repository cloning
- **PostgreSQL client** (optional, for testing connections)
- **Web browser** for accessing the Neosync UI
- **macOS, Linux, or Windows** with WSL2

### Installation Steps

Let's begin by setting up Neosync on your local machine:

#### Step 1: Clone the Repository

```bash
# Clone Neosync repository
git clone https://github.com/nucleuscloud/neosync.git
cd neosync

# Check repository structure
ls -la
```

#### Step 2: Start Neosync Services

Neosync provides a production-ready Docker Compose setup:

```bash
# Start all Neosync services
make compose/up

# Alternatively, you can use Docker Compose directly
docker compose up -d
```

This command will:
- Download and start all required containers
- Set up PostgreSQL database for Neosync metadata
- Launch the Neosync backend API
- Start the web frontend interface
- Initialize sample connections and jobs

#### Step 3: Verify Installation

```bash
# Check running containers
docker compose ps

# View logs if needed
docker compose logs -f neosync-app
```

Access Neosync at `http://localhost:3000` in your web browser.

## Understanding Neosync Architecture

### Core Components

Neosync consists of several interconnected components:

1. **Frontend (Next.js)** - Web interface for configuration and monitoring
2. **Backend API (Go)** - Core business logic and job orchestration
3. **Worker Service** - Handles data processing and transformation jobs
4. **PostgreSQL Database** - Stores metadata, configurations, and job state
5. **Temporal** - Workflow orchestration for reliable job execution

### Data Flow Architecture

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
<div class="d3-arch" data-arch-root id="eticdatacompletetutorial-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 454, "height": 846, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 272, "w": 135, "h": 46, "title": "Source Database"}, {"id": "B", "x": 119, "y": 396, "w": 128, "h": 46, "title": "Neosync Worker"}, {"id": "C", "x": 109, "y": 520, "w": 149, "h": 46, "title": "Data Transformers"}, {"id": "D", "x": 81, "y": 644, "w": 205, "h": 46, "title": "Anonymized/Synthetic Data"}, {"id": "E", "x": 116, "y": 768, "w": 135, "h": 46, "title": "Target Database"}, {"id": "F", "x": 215, "y": 24, "w": 120, "h": 46, "title": "Neosync UI"}, {"id": "G", "x": 127, "y": 148, "w": 120, "h": 46, "title": "Backend API"}, {"id": "H", "x": 214, "y": 272, "w": 121, "h": 46, "title": "Job Scheduler"}, {"id": "I", "x": 39, "y": 24, "w": 121, "h": 46, "title": "Configuration"}, {"id": "J", "x": 302, "y": 148, "w": 120, "h": 46, "title": "Temporal"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[92, 318], [92, 357], [92, 357], [149, 396]]}, {"src": "B", "dst": "C", "kind": "data", "line": [183, 442, 183, 520]}, {"src": "C", "dst": "D", "kind": "data", "line": [183, 566, 183, 644]}, {"src": "D", "dst": "E", "kind": "data", "line": [183, 690, 183, 768]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[275, 70], [275, 109], [275, 109], [220, 148]]}, {"src": "G", "dst": "H", "kind": "data", "curve": [[187, 194], [187, 233], [187, 233], [242, 272]]}, {"src": "H", "dst": "B", "kind": "data", "curve": [[275, 318], [275, 357], [275, 357], [217, 396]]}, {"src": "I", "dst": "G", "kind": "data", "curve": [[99, 70], [99, 109], [99, 109], [154, 148]]}, {"src": "J", "dst": "H", "kind": "data", "curve": [[362, 194], [362, 233], [362, 233], [307, 272]]}]});
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
      const container = document.getElementById('eticdatacompletetutorial-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eticdatacompletetutorial-1';
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

## Initial Configuration and Setup

### Accessing the Dashboard

1. Open your browser and navigate to `http://localhost:3000`
2. You'll see the Neosync welcome dashboard
3. The system comes pre-configured with sample connections for demonstration

### Understanding Connections

**Connections** in Neosync represent database or storage endpoints. The default setup includes:

- **Source Connection** - PostgreSQL database with sample data
- **Destination Connection** - Target database for anonymized data

### Sample Data Overview

Neosync includes pre-populated sample data to demonstrate its capabilities:

```sql
-- Sample schema structure
CREATE TABLE users (
    id SERIAL PRIMARY KEY,
    first_name VARCHAR(50),
    last_name VARCHAR(50),
    email VARCHAR(100) UNIQUE,
    phone VARCHAR(20),
    birth_date DATE,
    salary DECIMAL(10,2)
);

CREATE TABLE orders (
    id SERIAL PRIMARY KEY,
    user_id INTEGER REFERENCES users(id),
    order_date TIMESTAMP,
    total_amount DECIMAL(10,2),
    status VARCHAR(20)
);
```

## Creating Your First Anonymization Job

### Job Configuration Wizard

Let's create a data anonymization job that transforms sensitive information while preserving data relationships:

#### Step 1: Create New Job

1. Click **"Jobs"** in the navigation menu
2. Select **"Create Job"**
3. Choose **"Data Anonymization"** job type
4. Set job name: `user-data-anonymization`

#### Step 2: Configure Source Connection

```yaml
# Source connection settings
Connection Type: PostgreSQL
Host: localhost
Port: 5432
Database: sample_db
Username: postgres
Password: [provided in compose]
```

#### Step 3: Define Transformation Rules

For the `users` table, configure these transformations:

| Column | Transformer | Configuration |
|--------|-------------|---------------|
| `first_name` | Generate First Name | Random generation |
| `last_name` | Generate Last Name | Random generation |
| `email` | Transform Email | Preserve domain structure |
| `phone` | Generate Phone | Format: +1-XXX-XXX-XXXX |
| `birth_date` | Transform Date | Randomize ±5 years |
| `salary` | Transform Numeric | Randomize ±20% |

#### Step 4: Preserve Referential Integrity

Configure foreign key relationships:

```yaml
# Maintain user_id relationships in orders table
Foreign Keys:
  - Source Table: orders
    Source Column: user_id
    Reference Table: users
    Reference Column: id
    Action: preserve_relationship
```

#### Step 5: Execute the Job

```bash
# Monitor job execution via CLI (optional)
docker compose exec neosync-worker neosync jobs run --job-id=user-data-anonymization

# Or use the web interface
# Click "Run Job" in the dashboard
```

## Synthetic Data Generation

### Creating Synthetic Datasets

Neosync can generate completely synthetic data that matches your schema constraints:

#### Step 1: Schema Analysis

```sql
-- Analyze existing schema
SELECT 
    column_name,
    data_type,
    is_nullable,
    column_default
FROM information_schema.columns 
WHERE table_name = 'users';
```

#### Step 2: Configure Synthetic Generation

Create a new job with these settings:

```yaml
Job Type: Generate Synthetic Data
Target Rows: 10000
Data Distribution:
  users:
    - first_name: weighted_random([common_names])
    - last_name: weighted_random([surnames])
    - email: generate_email(first_name, last_name)
    - age_distribution: normal(mean=35, std=12)
    - salary_distribution: lognormal(mean=75000, std=25000)
```

#### Step 3: Advanced Synthetic Patterns

```javascript
// Custom transformer for realistic email generation
function generateEmail(firstName, lastName) {
    const domains = ['gmail.com', 'yahoo.com', 'company.com'];
    const domain = domains[Math.floor(Math.random() * domains.length)];
    const username = `${firstName.toLowerCase()}.${lastName.toLowerCase()}`;
    return `${username}@${domain}`;
}

// Generate correlated data
function generateSalary(experience, education) {
    const baseSalary = 50000;
    const experienceMultiplier = experience * 2000;
    const educationBonus = education === 'masters' ? 15000 : 
                          education === 'phd' ? 25000 : 0;
    
    return baseSalary + experienceMultiplier + educationBonus;
}
```

## Advanced Data Transformations

### Custom JavaScript Transformers

Neosync supports custom transformations using JavaScript:

```javascript
// Credit card number anonymization
function anonymizeCreditCard(value) {
    if (!value || value.length < 4) return value;
    
    const lastFour = value.slice(-4);
    const masked = '*'.repeat(value.length - 4);
    return masked + lastFour;
}

// Address anonymization while preserving geographic region
function anonymizeAddress(address, city, state) {
    return {
        street: generateRandomStreet(),
        city: city, // Preserve city for geographic analysis
        state: state,
        zipCode: generateRandomZipInState(state)
    };
}

// Timestamp anonymization with time pattern preservation
function anonymizeTimestamp(timestamp) {
    const date = new Date(timestamp);
    const randomDays = Math.floor(Math.random() * 365) - 182; // ±6 months
    date.setDate(date.getDate() + randomDays);
    return date.toISOString();
}
```

### LLM-Powered Transformations

For more sophisticated transformations, Neosync can integrate with Large Language Models:

```yaml
# LLM transformer configuration
Transformer: LLM_Transform
Model: gpt-3.5-turbo
Prompt: |
  Transform this customer review to remove personal information 
  while preserving sentiment and key product feedback:
  
  Original: "{review_text}"
  
  Requirements:
  - Remove specific names, locations, dates
  - Preserve product features mentioned
  - Maintain emotional tone
  - Keep review length similar

Temperature: 0.3
Max_Tokens: 300
```

## Database Integration and Subsetting

### PostgreSQL Integration

Configure PostgreSQL connection for production data:

```yaml
# Production PostgreSQL setup
Connection:
  type: postgresql
  host: prod-db.company.com
  port: 5432
  database: production_db
  username: neosync_reader
  password: ${NEOSYNC_DB_PASSWORD}
  ssl_mode: require
  
# Read-only permissions for safety
Permissions:
  - SELECT on public.*
  - No write permissions
```

### Data Subsetting Strategies

Create focused datasets for testing:

```sql
-- User-based subsetting
SELECT * FROM users 
WHERE created_at >= '2024-01-01' 
  AND account_type = 'premium'
LIMIT 1000;

-- Relationship-aware subsetting
WITH sample_users AS (
    SELECT id FROM users 
    WHERE region = 'US-WEST' 
    LIMIT 500
)
SELECT o.* FROM orders o
JOIN sample_users su ON o.user_id = su.id
WHERE o.order_date >= '2024-01-01';

-- Time-based subsetting with referential integrity
SELECT * FROM events 
WHERE event_date BETWEEN '2024-07-01' AND '2024-07-31'
  AND user_id IN (
    SELECT id FROM users 
    WHERE last_active >= '2024-06-01'
  );
```

### MySQL Integration

```yaml
# MySQL connection configuration
Connection:
  type: mysql
  host: mysql-server.internal
  port: 3306
  database: app_database
  username: neosync_user
  password: ${MYSQL_PASSWORD}
  charset: utf8mb4
  
# MySQL-specific settings
Options:
  sql_mode: STRICT_TRANS_TABLES
  time_zone: UTC
  max_connections: 10
```

## Workflow Automation and GitOps

### Declarative Configuration

Create reusable job configurations:

```yaml
# .neosync/jobs/user-anonymization.yaml
apiVersion: neosync.dev/v1
kind: Job
metadata:
  name: user-data-anonymization
  namespace: development
spec:
  source:
    connection: prod-postgres
    tables:
      - users
      - user_profiles
      - user_preferences
  
  destination:
    connection: dev-postgres
    
  transformations:
    users:
      first_name:
        type: generate_first_name
      last_name:
        type: generate_last_name
      email:
        type: transform_email
        preserve_domain: true
      ssn:
        type: hash_value
        algorithm: sha256
    
    user_profiles:
      bio:
        type: llm_transform
        model: gpt-3.5-turbo
        prompt: "Anonymize personal details while preserving professional information"
  
  schedule:
    cron: "0 2 * * *"  # Daily at 2 AM
    timezone: UTC
```

### CI/CD Integration

```yaml
# .github/workflows/data-sync.yml
name: Neosync Data Synchronization

on:
  schedule:
    - cron: '0 6 * * 1'  # Every Monday at 6 AM
  workflow_dispatch:

jobs:
  sync-development-data:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Neosync CLI
        run: |
          curl -sSL https://install.neosync.dev | sh
          echo "$HOME/.neosync/bin" >> $GITHUB_PATH
      
      - name: Run Anonymization Job
        env:
          NEOSYNC_API_TOKEN: ${{ secrets.NEOSYNC_API_TOKEN }}
          NEOSYNC_API_URL: ${{ secrets.NEOSYNC_API_URL }}
        run: |
          neosync jobs run \
            --job-config .neosync/jobs/user-anonymization.yaml \
            --wait-for-completion \
            --timeout 30m
      
      - name: Verify Data Quality
        run: |
          neosync validate \
            --connection dev-postgres \
            --check referential-integrity \
            --check data-quality
```

## Monitoring and Observability

### Job Monitoring Dashboard

Neosync provides comprehensive monitoring capabilities:

1. **Job Execution Status** - Real-time progress tracking
2. **Data Transformation Metrics** - Row counts, transformation rates
3. **Error Tracking** - Failed transformations and retry logic
4. **Performance Metrics** - Execution time, throughput analysis
5. **Data Quality Checks** - Validation results and anomaly detection

### Metrics and Alerting

```yaml
# Monitoring configuration
Monitoring:
  metrics:
    - job_duration_seconds
    - rows_processed_total
    - transformation_errors_total
    - data_quality_score
  
  alerts:
    - name: job_failure
      condition: job_status == "failed"
      notification: slack_webhook
      
    - name: data_quality_degradation
      condition: data_quality_score < 0.95
      notification: email
      
    - name: long_running_job
      condition: job_duration_seconds > 3600
      notification: pagerduty
```

### Log Analysis

```bash
# View job execution logs
docker compose logs neosync-worker | grep "job_id=user-anonymization"

# Monitor transformation performance
docker compose logs neosync-worker | grep "transformation_stats"

# Check for errors
docker compose logs neosync-worker | grep "ERROR"
```

## Security and Compliance

### Data Privacy Best Practices

1. **Principle of Least Privilege** - Grant minimal necessary permissions
2. **Data Retention Policies** - Automatically purge old anonymized data
3. **Audit Logging** - Track all data access and transformations
4. **Encryption** - Encrypt data in transit and at rest
5. **Access Controls** - Role-based access to different data sensitivity levels

### GDPR Compliance Features

```yaml
# GDPR compliance configuration
GDPR:
  data_subject_rights:
    right_to_be_forgotten:
      enabled: true
      retention_days: 90
      
    right_of_access:
      enabled: true
      response_time_days: 30
      
    data_portability:
      enabled: true
      export_formats: [json, csv, xml]
  
  consent_management:
    track_consent_changes: true
    consent_expiry_days: 365
    
  breach_notification:
    enabled: true
    notification_time_hours: 72
```

### HIPAA Compliance

```yaml
# HIPAA compliance for healthcare data
HIPAA:
  phi_identification:
    automatic_detection: true
    custom_patterns:
      - medical_record_number: '\d{8,12}'
      - patient_id: 'P\d{6,10}'
      
  safe_harbor_method:
    remove_direct_identifiers: true
    statistical_disclosure_control: true
    
  audit_controls:
    log_all_access: true
    log_retention_years: 6
```

## Performance Optimization

### Parallel Processing Configuration

```yaml
# Performance optimization settings
Performance:
  worker_concurrency: 8
  batch_size: 1000
  memory_limit: "4Gi"
  
  database_connections:
    max_open: 25
    max_idle: 5
    connection_lifetime: "5m"
  
  transformation_cache:
    enabled: true
    size: "1Gi"
    ttl: "1h"
```

### Large Dataset Handling

```sql
-- Chunked processing for large tables
SELECT * FROM large_table 
WHERE id BETWEEN ? AND ?
ORDER BY id 
LIMIT 10000;

-- Memory-efficient streaming
SET work_mem = '256MB';
SET maintenance_work_mem = '1GB';
```

## Troubleshooting Guide

### Common Issues and Solutions

#### Issue 1: Job Timeout

```yaml
# Solution: Increase timeout and optimize batch size
Job:
  timeout: 3600s  # 1 hour
  batch_size: 500  # Smaller batches
  retry_attempts: 3
```

#### Issue 2: Memory Issues

```bash
# Monitor memory usage
docker stats neosync-worker

# Increase container memory
docker compose up -d --scale neosync-worker=2
```

#### Issue 3: Connection Failures

```yaml
# Robust connection configuration
Connection:
  retry_attempts: 5
  retry_delay: 30s
  connection_timeout: 60s
  read_timeout: 300s
```

### Debug Mode

```bash
# Enable debug logging
export NEOSYNC_LOG_LEVEL=debug
docker compose up -d

# View detailed logs
docker compose logs -f neosync-worker | grep DEBUG
```

## Testing and Validation

Let's create a comprehensive test script to validate our Neosync setup:

```bash
#!/bin/bash
# File: test-neosync-setup.sh

echo "🚀 Testing Neosync Setup..."

# Test 1: Check if services are running
echo "📡 Checking Neosync services..."
if curl -f http://localhost:3000/health > /dev/null 2>&1; then
    echo "✅ Neosync UI is accessible"
else
    echo "❌ Neosync UI is not accessible"
    exit 1
fi

# Test 2: Verify database connectivity
echo "🗄️ Testing database connectivity..."
docker compose exec neosync-app neosync connections test --connection-id=sample-postgres
if [ $? -eq 0 ]; then
    echo "✅ Database connection successful"
else
    echo "❌ Database connection failed"
fi

# Test 3: Run sample anonymization job
echo "🔄 Running sample anonymization job..."
JOB_ID=$(docker compose exec neosync-app neosync jobs create \
    --name "test-anonymization" \
    --source-connection sample-postgres \
    --destination-connection sample-postgres-dest)

docker compose exec neosync-app neosync jobs run --job-id=$JOB_ID --wait

# Test 4: Validate anonymized data
echo "🔍 Validating anonymized data..."
docker compose exec postgres psql -U postgres -d neosync -c \
    "SELECT COUNT(*) as anonymized_records FROM users_anonymized;"

echo "✅ Neosync setup test completed successfully!"
```

## Next Steps and Advanced Usage

### Production Deployment

For production deployment, consider:

1. **Kubernetes Deployment** - Use the provided Helm charts
2. **High Availability** - Deploy multiple worker instances
3. **External Database** - Use managed PostgreSQL for metadata
4. **Secrets Management** - Integrate with HashiCorp Vault or AWS Secrets Manager
5. **Load Balancing** - Distribute API requests across multiple instances

### Integration Patterns

```yaml
# Microservices integration
Services:
  user-service:
    anonymization_job: user-data-anonymization
    schedule: "0 3 * * *"
    
  order-service:
    anonymization_job: order-data-anonymization
    depends_on: [user-service]
    
  analytics-service:
    synthetic_data_job: analytics-synthetic-data
    schema_source: production_analytics
```

### Custom Extensions

```go
// Custom transformer in Go
package transformers

type CustomTransformer struct {
    config TransformerConfig
}

func (t *CustomTransformer) Transform(value interface{}) (interface{}, error) {
    // Implement custom transformation logic
    return transformedValue, nil
}
```

## Conclusion

Neosync provides a comprehensive solution for modern data privacy and testing challenges. By implementing proper data anonymization and synthetic data generation, organizations can:

- **Accelerate Development** - Safe access to production-like data
- **Improve Data Quality** - Realistic test scenarios and edge cases
- **Ensure Compliance** - Automated privacy protection for regulated industries
- **Reduce Risk** - Eliminate exposure of sensitive production data
- **Scale Testing** - Generate unlimited synthetic datasets for various scenarios

The platform's declarative configuration, GitOps integration, and extensive customization options make it suitable for organizations of all sizes, from startups to enterprise deployments.

### Key Takeaways

1. **Start Simple** - Begin with basic anonymization jobs and gradually add complexity
2. **Preserve Relationships** - Always maintain referential integrity in your transformations
3. **Monitor Quality** - Implement data quality checks to ensure transformation effectiveness
4. **Automate Everything** - Use GitOps and CI/CD integration for consistent data provisioning
5. **Plan for Scale** - Design your transformation pipelines with production volume in mind

### Resources for Further Learning

- [**Neosync Documentation**](https://docs.neosync.dev) - Comprehensive guides and API reference
- [**Community Discord**](https://discord.gg/neosync) - Connect with other users and get support
- [**GitHub Repository**](https://github.com/nucleuscloud/neosync) - Source code and issue tracking
- [**Blog and Tutorials**](https://www.neosync.dev/blog) - Latest features and use cases

---

**Need Help?** Join the Neosync community on Discord or open an issue on GitHub for technical support and feature requests.
