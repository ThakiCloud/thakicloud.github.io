---
title: "VibeKit: The Ultimate Security Layer for AI Coding Agents - Complete Tutorial"
excerpt: "Learn how to run Claude Code, Gemini, and other AI coding agents in secure, isolated sandboxes with built-in data redaction and comprehensive observability using VibeKit."
seo_title: "VibeKit Tutorial: Secure AI Coding Agent Sandbox with Data Redaction - Thaki Cloud"
seo_description: "Complete guide to VibeKit - run AI coding agents like Claude Code and Gemini in isolated Docker containers with automatic sensitive data redaction and real-time monitoring."
date: 2025-10-05
tags:
  - vibekit
  - ai-agents
  - coding-security
  - docker-sandbox
  - claude-code
  - gemini-cli
  - data-redaction
  - observability
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/vibekit-secure-ai-coding-agent-sandbox-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/vibekit-secure-ai-coding-agent-sandbox-tutorial-en/"
categories:
  - tutorials
published: false
---

⏱️ **Estimated Reading Time**: 12 minutes

## Introduction

As AI coding agents like Claude Code, Gemini CLI, and Codex become increasingly powerful, the need for secure execution environments has never been more critical. **VibeKit** emerges as the essential safety layer that allows you to harness the full potential of these AI tools while maintaining complete security and observability.

In this comprehensive tutorial, we'll explore how VibeKit creates isolated Docker sandboxes, automatically redacts sensitive data, and provides real-time monitoring for all your AI coding operations.

## What is VibeKit?

VibeKit is an open-source security framework designed specifically for AI coding agents. It acts as a protective barrier between AI-generated code and your local development environment, ensuring that:

- **No malicious code** can affect your system
- **Sensitive data** is automatically detected and redacted
- **All operations** are logged and monitored in real-time
- **Universal compatibility** with popular AI coding tools

### Key Features Overview

🐳 **Local Sandbox Environment**
- Runs all AI-generated code in isolated Docker containers
- Zero risk to your local development setup
- Complete filesystem isolation

🔒 **Built-in Data Redaction**
- Automatically detects and removes API keys, passwords, and secrets
- Configurable redaction rules for custom sensitive data patterns
- Real-time scanning of all code completions

📊 **Comprehensive Observability**
- Real-time logs and execution traces
- Performance metrics and resource usage monitoring
- Complete audit trail of all AI operations

🌐 **Universal Agent Support**
- Works with Claude Code, Gemini CLI, Grok CLI, Codex CLI
- Compatible with OpenCode and custom AI agents
- Plugin architecture for extending support

💻 **Offline Operation**
- No cloud dependencies required
- Works entirely on your local machine
- Complete privacy and data sovereignty

**Figure 1. VibeKit security sandbox architecture.**

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
<div class="d3-arch" data-arch-root id="ngagentsandboxtutorialen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 753, "height": 538, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "AGENT", "x": 270, "y": 24, "w": 198, "h": 78, "title": ["AI Coding Agent: Claude", "Code / Gemini CLI / Grok", "CLI / Codex CLI"]}, {"id": "VK", "x": 277, "y": 180, "w": 184, "h": 46, "title": "VibeKit Security Layer"}, {"id": "BOX", "x": 523, "y": 304, "w": 198, "h": 62, "title": ["Isolated Docker Sandbox:", "filesystem isolation"]}, {"id": "RED", "x": 270, "y": 304, "w": 198, "h": 62, "title": ["Data Redaction: scan API", "keys and secrets"]}, {"id": "LOG", "x": 24, "y": 304, "w": 191, "h": 62, "title": ["Observability: logs and", "audit trail"]}, {"id": "SAFE", "x": 288, "y": 444, "w": 163, "h": 62, "title": ["Protected Local Dev", "Environment"]}], "edges": [{"src": "AGENT", "dst": "VK", "kind": "data", "line": [369, 102, 369, 180]}, {"src": "VK", "dst": "BOX", "kind": "data", "curve": [[461, 226], [622, 265], [622, 265], [622, 304]]}, {"src": "VK", "dst": "RED", "kind": "data", "line": [369, 226, 369, 304]}, {"src": "VK", "dst": "LOG", "kind": "data", "curve": [[277, 226], [120, 265], [120, 265], [120, 304]]}, {"src": "BOX", "dst": "SAFE", "kind": "data", "curve": [[622, 366], [622, 405], [622, 405], [451, 452]]}, {"src": "RED", "dst": "SAFE", "kind": "data", "line": [369, 366, 369, 444]}, {"src": "LOG", "dst": "SAFE", "kind": "data", "curve": [[120, 366], [120, 405], [120, 405], [288, 452]]}]});
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
      const container = document.getElementById('ngagentsandboxtutorialen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ngagentsandboxtutorialen-1';
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

## Prerequisites

Before we begin, ensure you have the following installed on your system:

### System Requirements

- **Node.js**: Version 16 or higher
- **Docker**: Latest stable version
- **npm**: Comes with Node.js installation
- **Operating System**: macOS, Linux, or Windows with WSL2

### Verification Commands

```bash
# Check Node.js version
node --version

# Check Docker installation
docker --version

# Check npm version
npm --version
```

## Installation Guide

### Step 1: Install VibeKit CLI

The easiest way to get started with VibeKit is through the global CLI installation:

```bash
# Install VibeKit CLI globally
npm install -g vibekit

# Verify installation
vibekit --version
```

### Step 2: Docker Setup Verification

VibeKit relies on Docker for creating isolated sandboxes. Let's ensure Docker is properly configured:

```bash
# Test Docker functionality
docker run hello-world

# Check available Docker images
docker images

# Verify Docker daemon is running
docker info
```

### Step 3: Initial Configuration

Create a basic configuration file for VibeKit:

```bash
# Create VibeKit configuration directory
mkdir -p ~/.vibekit

# Generate default configuration
vibekit init
```

This creates a `.vibekit.json` configuration file with default settings:

```json
{
  "sandbox": {
    "timeout": 30000,
    "memory_limit": "512m",
    "cpu_limit": "1.0"
  },
  "redaction": {
    "enabled": true,
    "patterns": [
      "api_key",
      "password",
      "secret",
      "token"
    ]
  },
  "logging": {
    "level": "info",
    "output": "console"
  }
}
```

## Basic Usage Tutorial

### Running Claude Code with VibeKit

The most common use case is running Claude Code through VibeKit's security layer:

```bash
# Run Claude Code with VibeKit protection
vibekit claude

# Run with verbose logging
vibekit claude --verbose

# Run with custom timeout
vibekit claude --timeout 60000
```

### Example: Secure Python Script Execution

Let's walk through a practical example of running AI-generated Python code securely:

1. **Start VibeKit with Claude Code:**
```bash
vibekit claude --language python
```

2. **Request AI to generate code:**
```
Generate a Python script that analyzes CSV data and creates visualizations
```

3. **VibeKit automatically:**
   - Receives the AI-generated code
   - Scans for sensitive data patterns
   - Creates an isolated Docker container
   - Executes the code safely
   - Returns results with security logs

### Working with Different AI Agents

VibeKit supports multiple AI coding agents. Here's how to use them:

```bash
# Gemini CLI integration
vibekit gemini

# Codex CLI integration  
vibekit codex

# Custom agent integration
vibekit custom --agent-command "your-ai-agent"
```

## Advanced Configuration

### Custom Redaction Patterns

You can define custom patterns for sensitive data detection:

```json
{
  "redaction": {
    "enabled": true,
    "patterns": [
      {
        "name": "custom_api_key",
        "regex": "sk-[a-zA-Z0-9]{32}",
        "replacement": "[REDACTED_API_KEY]"
      },
      {
        "name": "database_url",
        "regex": "postgresql://[^\\s]+",
        "replacement": "[REDACTED_DB_URL]"
      }
    ]
  }
}
```

### Sandbox Resource Limits

Configure resource limits for enhanced security:

```json
{
  "sandbox": {
    "memory_limit": "1g",
    "cpu_limit": "2.0",
    "disk_limit": "500m",
    "network_access": false,
    "timeout": 45000
  }
}
```

### Logging and Monitoring Setup

Enable comprehensive logging for audit trails:

```json
{
  "logging": {
    "level": "debug",
    "output": "file",
    "file_path": "~/.vibekit/logs/vibekit.log",
    "max_file_size": "10mb",
    "max_files": 5
  }
}
```

## SDK Integration

For developers building applications with VibeKit, the SDK provides programmatic access:

### Installation

```bash
npm install @vibe-kit/sdk
```

### Basic SDK Usage

```javascript
import { VibeKit } from '@vibe-kit/sdk';

const vibekit = new VibeKit({
  sandbox: {
    timeout: 30000,
    memory_limit: '512m'
  },
  redaction: {
    enabled: true
  }
});

// Execute code in sandbox
const result = await vibekit.execute({
  code: 'print("Hello, secure world!")',
  language: 'python'
});

console.log('Execution result:', result.output);
console.log('Security logs:', result.security_logs);
```

### Advanced SDK Features

```javascript
// Custom redaction rules
vibekit.addRedactionRule({
  name: 'credit_card',
  pattern: /\b\d{4}[\s-]?\d{4}[\s-]?\d{4}[\s-]?\d{4}\b/g,
  replacement: '[REDACTED_CC]'
});

// Real-time monitoring
vibekit.on('execution_start', (event) => {
  console.log('Code execution started:', event.timestamp);
});

vibekit.on('security_alert', (alert) => {
  console.log('Security alert:', alert.message);
});
```

## Security Best Practices

### 1. Regular Updates

Keep VibeKit updated to receive the latest security patches:

```bash
# Update VibeKit CLI
npm update -g vibekit

# Update SDK
npm update @vibe-kit/sdk
```

### 2. Configuration Hardening

Use restrictive sandbox settings for maximum security:

```json
{
  "sandbox": {
    "network_access": false,
    "file_system_access": "read-only",
    "environment_isolation": true,
    "resource_monitoring": true
  }
}
```

### 3. Audit Log Management

Implement proper log rotation and monitoring:

```bash
# Set up log rotation
vibekit config set logging.rotation.enabled true
vibekit config set logging.rotation.max_size "50mb"
vibekit config set logging.rotation.max_files 10
```

### 4. Custom Security Policies

Define organization-specific security policies:

```json
{
  "security_policies": {
    "allowed_languages": ["python", "javascript", "bash"],
    "blocked_imports": ["os", "subprocess", "socket"],
    "max_execution_time": 30000,
    "require_approval": ["file_operations", "network_requests"]
  }
}
```

## Troubleshooting Common Issues

### Docker Connection Issues

```bash
# Check Docker daemon status
sudo systemctl status docker

# Restart Docker service
sudo systemctl restart docker

# Test Docker connectivity
docker run --rm hello-world
```

### Permission Problems

```bash
# Add user to docker group (Linux)
sudo usermod -aG docker $USER

# Reload group membership
newgrp docker
```

### Memory and Resource Issues

```bash
# Check system resources
docker system df

# Clean up unused containers
docker system prune

# Monitor resource usage
docker stats
```

### Configuration Validation

```bash
# Validate VibeKit configuration
vibekit config validate

# Reset to default configuration
vibekit config reset

# Show current configuration
vibekit config show
```

## Performance Optimization

### Container Image Optimization

Use lightweight base images for better performance:

```json
{
  "sandbox": {
    "base_images": {
      "python": "python:3.11-alpine",
      "node": "node:18-alpine",
      "general": "ubuntu:22.04"
    }
  }
}
```

### Resource Allocation Tuning

Optimize resource allocation based on your use case:

```json
{
  "performance": {
    "parallel_executions": 3,
    "container_reuse": true,
    "image_caching": true,
    "memory_optimization": true
  }
}
```

## Monitoring and Observability

### Real-time Monitoring Dashboard

VibeKit provides a web-based monitoring interface:

```bash
# Start monitoring dashboard
vibekit monitor --port 8080

# Access dashboard at http://localhost:8080
```

### Metrics Collection

Enable comprehensive metrics collection:

```json
{
  "metrics": {
    "enabled": true,
    "collection_interval": 5000,
    "export_format": "prometheus",
    "custom_metrics": [
      "execution_time",
      "memory_usage",
      "security_events"
    ]
  }
}
```

### Integration with External Monitoring

```javascript
// Export metrics to external systems
const metrics = await vibekit.getMetrics();

// Send to monitoring service
await monitoringService.send({
  timestamp: Date.now(),
  metrics: metrics,
  tags: ['vibekit', 'ai-agents']
});
```

## Use Cases and Examples

### 1. Secure Code Review Automation

```bash
# Review pull requests with AI assistance
vibekit claude --mode review --input "path/to/pr.diff"
```

### 2. Safe Dependency Analysis

```bash
# Analyze package.json for security issues
vibekit gemini --task security-audit --file package.json
```

### 3. Automated Testing Generation

```bash
# Generate unit tests securely
vibekit codex --generate tests --source-dir src/
```

### 4. Documentation Generation

```bash
# Create documentation from code
vibekit claude --task documentation --input-dir src/
```

## Community and Support

### Getting Help

- **GitHub Repository**: [https://github.com/superagent-ai/vibekit](https://github.com/superagent-ai/vibekit)
- **Documentation**: Official docs at vibekit.sh
- **Discord Community**: Join the discussion
- **Issue Tracker**: Report bugs and feature requests

### Contributing

VibeKit is open source and welcomes contributions:

```bash
# Clone the repository
git clone https://github.com/superagent-ai/vibekit.git

# Install development dependencies
cd vibekit
npm install

# Run tests
npm test

# Submit pull request
```

## Conclusion

VibeKit represents a paradigm shift in how we approach AI coding agent security. By providing isolated execution environments, automatic data redaction, and comprehensive observability, it enables developers to harness the full power of AI coding tools without compromising security.

Key takeaways from this tutorial:

1. **Security First**: Always run AI-generated code in isolated environments
2. **Data Protection**: Implement automatic redaction for sensitive information
3. **Monitoring**: Maintain comprehensive logs and metrics for all AI operations
4. **Best Practices**: Follow security guidelines and keep systems updated
5. **Community**: Leverage the open-source community for support and contributions

As AI coding agents continue to evolve, VibeKit ensures that security and observability evolve alongside them, providing a robust foundation for the future of AI-assisted development.

## Next Steps

1. **Install VibeKit** and try the basic examples
2. **Configure custom redaction rules** for your specific use case
3. **Integrate the SDK** into your existing development workflow
4. **Set up monitoring** and observability dashboards
5. **Join the community** and contribute to the project

Start your secure AI coding journey with VibeKit today!
