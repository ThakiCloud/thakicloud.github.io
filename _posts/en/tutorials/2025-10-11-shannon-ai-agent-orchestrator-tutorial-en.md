---
title: "Shannon AI Agent Orchestrator: Complete Tutorial for Enterprise-Grade AI Agent Management"
excerpt: "Learn how to set up and use Shannon, an open-source AI agent orchestrator with enterprise-grade security, cost controls, and vendor flexibility. A comprehensive guide from installation to advanced multi-agent workflows."
seo_title: "Shannon AI Agent Orchestrator Tutorial - Enterprise AI Agent Management"
seo_description: "Complete tutorial for Shannon AI Agent Orchestrator: installation, configuration, multi-agent workflows, security features, and enterprise deployment guide."
date: 2025-10-11
tags:
  - AI-Agent
  - Orchestrator
  - Multi-Agent
  - Enterprise-AI
  - Shannon
  - Docker
  - Microservices
  - LLM
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/shannon-ai-agent-orchestrator-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/shannon-ai-agent-orchestrator-tutorial-en/"
categories:
  - tutorials
---

⏱️ **Estimated Reading Time**: 15 minutes

## Introduction

Shannon is an open-source AI agent orchestrator that provides enterprise-grade security, cost controls, and vendor flexibility. Unlike proprietary solutions like OpenAI AgentKit, Shannon offers complete control over your AI infrastructure while maintaining production-ready reliability and scalability.

### What Makes Shannon Special?

Shannon stands out in the AI agent orchestration landscape with its unique architecture and features:

- **Multi-language Architecture**: Go orchestrator, Rust agent-core, Python LLM service
- **Enterprise Security**: OPA policy enforcement, WASI sandbox, fine-grained access control
- **Cost Management**: Token budget management, circuit breaker patterns, automatic failure recovery
- **Vendor Flexibility**: Multi-provider LLM support (OpenAI, Anthropic, Google, DeepSeek)
- **Advanced Memory**: Vector memory with Qdrant, hierarchical memory, near-duplicate detection
- **Real-time Communication**: WebSocket and SSE streaming with event filtering

## Prerequisites

Before starting this tutorial, ensure you have:

- Docker and Docker Compose installed
- Basic understanding of containerized applications
- Familiarity with REST APIs and microservices
- An API key from at least one LLM provider (OpenAI, Anthropic, etc.)

## Installation and Setup

### 1. Clone the Repository

```bash
git clone https://github.com/Kocoro-lab/Shannon.git
cd Shannon
```

### 2. Environment Configuration

Create your environment configuration:

```bash
cp .env.example .env
```

Edit the `.env` file with your configuration:

```bash
# LLM Provider Configuration
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# Database Configuration
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=shannon
POSTGRES_USER=shannon
POSTGRES_PASSWORD=your_secure_password

# Redis Configuration
REDIS_HOST=redis
REDIS_PORT=6379

# Qdrant Vector Database
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# Service Ports
ORCHESTRATOR_PORT=8080
AGENT_CORE_PORT=8081
LLM_SERVICE_PORT=8082
```

### 3. Start Shannon Services

Shannon provides a convenient Makefile for service management:

```bash
# Start all services
make up

# View service status
make ps

# View logs
make logs

# Stop services
make down
```

### 4. Verify Installation

Check that all services are running:

```bash
# Check orchestrator health
curl http://localhost:8080/health

# Check agent-core health
curl http://localhost:8081/health

# Check LLM service health
curl http://localhost:8082/health
```

## Core Concepts

### Architecture Overview

Shannon follows a microservices architecture with three main components:

1. **Go Orchestrator**: Manages workflows, sessions, and agent coordination
2. **Rust Agent-Core**: Handles agent execution, memory management, and tool integration
3. **Python LLM Service**: Provides unified interface to multiple LLM providers

**Figure 1. Shannon orchestrator architecture (Go orchestrator, Rust agent core, Python LLM service).**

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
<div class="d3-arch" data-arch-root id="ntorchestratortutorialen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 718, "height": 708, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Client", "x": 239, "y": 24, "w": 149, "h": 46, "title": "Client / REST API"}, {"id": "GO", "x": 207, "y": 148, "w": 212, "h": 78, "title": ["Go Orchestrator:", "workflows, sessions, agent", "coordination"]}, {"id": "RUST", "x": 214, "y": 304, "w": 198, "h": 62, "title": ["Rust Agent Core:", "execution, memory, tools"]}, {"id": "PY", "x": 474, "y": 466, "w": 212, "h": 62, "title": ["Python LLM Service:", "unified provider interface"]}, {"id": "LLM", "x": 485, "y": 614, "w": 191, "h": 62, "title": ["LLM Providers: OpenAI /", "Anthropic / others"]}, {"id": "PAT", "x": 207, "y": 458, "w": 212, "h": 78, "title": ["ReAct / Tree-of-Thoughts /", "Chain-of-Thought / Debate", "/ Reflection"]}, {"id": "MEM", "x": 24, "y": 474, "w": 128, "h": 46, "title": "Session Memory"}], "edges": [{"src": "Client", "dst": "GO", "kind": "data", "line": [313, 70, 313, 148]}, {"src": "GO", "dst": "RUST", "kind": "data", "line": [313, 226, 313, 304]}, {"src": "RUST", "dst": "PY", "kind": "data", "curve": [[412, 364], [580, 412], [580, 412], [580, 466]]}, {"src": "PY", "dst": "LLM", "kind": "data", "line": [580, 528, 580, 614]}, {"src": "RUST", "dst": "PAT", "kind": "event", "label": "patterns", "line": [313, 366, 313, 458], "lx": 313, "ly": 408}, {"src": "RUST", "dst": "MEM", "kind": "data", "curve": [[222, 366], [88, 412], [88, 412], [88, 474]]}]});
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
      const container = document.getElementById('ntorchestratortutorialen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ntorchestratortutorialen-1';
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

### Agent Patterns

Shannon supports multiple orchestration patterns:

- **ReAct**: Reasoning and Acting in language models
- **Tree-of-Thoughts**: Explores multiple reasoning paths
- **Chain-of-Thought**: Sequential reasoning steps
- **Debate**: Multiple agents discuss and reach consensus
- **Reflection**: Self-evaluation and improvement

## Basic Usage Tutorial

### 1. Creating Your First Agent

Let's create a simple agent that can answer questions and perform basic tasks:

```bash
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "research-assistant",
    "description": "A helpful research assistant",
    "system_prompt": "You are a knowledgeable research assistant. Provide accurate, well-researched answers to user questions.",
    "model_provider": "openai",
    "model_name": "gpt-4",
    "max_tokens": 2000,
    "temperature": 0.7
  }'
```

### 2. Starting a Session

Create a session to interact with your agent:

```bash
curl -X POST http://localhost:8080/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "research-assistant",
    "session_config": {
      "max_turns": 50,
      "context_window": 10,
      "memory_enabled": true
    }
  }'
```

### 3. Sending Messages

Send a message to your agent:

```bash
curl -X POST http://localhost:8080/api/v1/sessions/{session_id}/messages \
  -H "Content-Type: application/json" \
  -d '{
    "content": "What are the key benefits of microservices architecture?",
    "message_type": "user"
  }'
```

### 4. Streaming Responses

For real-time responses, use the streaming endpoint:

```bash
curl -N http://localhost:8080/api/v1/sessions/{session_id}/stream \
  -H "Accept: text/event-stream"
```

## Advanced Features

### Multi-Agent Workflows

Shannon excels at orchestrating multiple agents working together. Here's how to set up a multi-agent workflow:

#### 1. Define Agent Roles

```yaml
# workflow.yaml
name: "content-creation-pipeline"
description: "Multi-agent content creation workflow"

agents:
  - name: "researcher"
    role: "research"
    system_prompt: "You are a thorough researcher. Gather comprehensive information on given topics."
    model: "gpt-4"
    
  - name: "writer"
    role: "content-creation"
    system_prompt: "You are a skilled writer. Create engaging content based on research."
    model: "claude-3-sonnet"
    
  - name: "editor"
    role: "review"
    system_prompt: "You are a meticulous editor. Review and improve content quality."
    model: "gpt-4"

workflow:
  pattern: "sequential"
  steps:
    - agent: "researcher"
      task: "Research the given topic thoroughly"
      output_to: ["writer"]
      
    - agent: "writer"
      task: "Create content based on research"
      input_from: ["researcher"]
      output_to: ["editor"]
      
    - agent: "editor"
      task: "Review and refine the content"
      input_from: ["writer"]
      final_output: true
```

#### 2. Execute Multi-Agent Workflow

```bash
curl -X POST http://localhost:8080/api/v1/workflows \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_file": "workflow.yaml",
    "input": {
      "topic": "The Future of AI in Healthcare",
      "target_audience": "healthcare professionals",
      "word_count": 1500
    }
  }'
```

### Memory Management

Shannon provides sophisticated memory management capabilities:

#### Vector Memory Configuration

```json
{
  "memory_config": {
    "vector_memory": {
      "enabled": true,
      "collection_name": "agent_memory",
      "embedding_model": "text-embedding-ada-002",
      "similarity_threshold": 0.8,
      "max_results": 10
    },
    "hierarchical_memory": {
      "enabled": true,
      "recent_messages": 20,
      "semantic_compression": true,
      "deduplication_threshold": 0.95
    }
  }
}
```

#### Querying Agent Memory

```bash
curl -X GET "http://localhost:8080/api/v1/sessions/{session_id}/memory?query=microservices+benefits&limit=5" \
  -H "Accept: application/json"
```

### Security and Access Control

Shannon uses Open Policy Agent (OPA) for fine-grained access control:

#### 1. Define Security Policies

```rego
# policies/agent_access.rego
package shannon.agent_access

import future.keywords.if

# Allow access if user has required role
allow if {
    input.user.roles[_] == "agent_operator"
    input.action == "create_agent"
}

# Restrict model access based on user tier
allow if {
    input.user.tier == "premium"
    input.agent.model in ["gpt-4", "claude-3-opus"]
}

# Budget enforcement
allow if {
    input.user.monthly_budget > input.estimated_cost
}
```

#### 2. Apply Policies

```bash
curl -X POST http://localhost:8080/api/v1/policies \
  -H "Content-Type: application/json" \
  -d '{
    "name": "agent_access_policy",
    "policy_file": "policies/agent_access.rego",
    "enabled": true
  }'
```

### Cost Management

Shannon provides comprehensive cost management features:

#### 1. Set Budget Limits

```bash
curl -X POST http://localhost:8080/api/v1/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user123",
    "monthly_limit": 100.00,
    "per_session_limit": 10.00,
    "alert_threshold": 0.8,
    "currency": "USD"
  }'
```

#### 2. Monitor Usage

```bash
curl -X GET http://localhost:8080/api/v1/usage/user123 \
  -H "Accept: application/json"
```

### Tool Integration

Shannon supports multiple tool integration methods:

#### 1. MCP (Model Context Protocol) Tools

```json
{
  "tools": [
    {
      "type": "mcp",
      "name": "file_operations",
      "server_url": "mcp://localhost:3000",
      "capabilities": ["read_file", "write_file", "list_directory"]
    }
  ]
}
```

#### 2. OpenAPI Tools

```json
{
  "tools": [
    {
      "type": "openapi",
      "name": "weather_api",
      "spec_url": "https://api.weather.com/openapi.json",
      "auth": {
        "type": "api_key",
        "key": "your_weather_api_key"
      }
    }
  ]
}
```

## Production Deployment

### Docker Compose Production Setup

For production deployment, use the provided production configuration:

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  orchestrator:
    image: shannon/orchestrator:latest
    environment:
      - ENV=production
      - LOG_LEVEL=info
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  agent-core:
    image: shannon/agent-core:latest
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 2G
          cpus: '1.0'

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: shannon_prod
      POSTGRES_USER: shannon
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 2G

volumes:
  postgres_data:
```

### Kubernetes Deployment

Shannon also provides Kubernetes manifests for cloud deployment:

```yaml
# k8s/orchestrator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shannon-orchestrator
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shannon-orchestrator
  template:
    metadata:
      labels:
        app: shannon-orchestrator
    spec:
      containers:
      - name: orchestrator
        image: shannon/orchestrator:latest
        ports:
        - containerPort: 8080
        env:
        - name: POSTGRES_HOST
          value: "postgres-service"
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## Monitoring and Observability

Shannon includes comprehensive monitoring capabilities:

### 1. Metrics Collection

Shannon exposes Prometheus metrics:

```bash
# View available metrics
curl http://localhost:8080/metrics
```

### 2. Grafana Dashboards

Import the provided Grafana dashboard:

```bash
# Import Shannon dashboard
curl -X POST http://grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @observability/grafana/shannon-dashboard.json
```

### 3. Distributed Tracing

Enable distributed tracing with Jaeger:

```yaml
# docker-compose.yml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```

## Troubleshooting

### Common Issues and Solutions

#### 1. Service Connection Issues

```bash
# Check service logs
make logs

# Restart specific service
docker-compose restart orchestrator

# Check network connectivity
docker network ls
docker network inspect shannon_default
```

#### 2. Memory Issues

```bash
# Monitor memory usage
docker stats

# Adjust memory limits in docker-compose.yml
services:
  agent-core:
    deploy:
      resources:
        limits:
          memory: 4G
```

#### 3. Database Connection Issues

```bash
# Check PostgreSQL logs
docker-compose logs postgres

# Test database connection
docker-compose exec postgres psql -U shannon -d shannon -c "SELECT 1;"
```

### Performance Optimization

#### 1. Connection Pooling

Configure connection pooling for better performance:

```yaml
# config/database.yaml
database:
  max_connections: 100
  max_idle_connections: 10
  connection_max_lifetime: 3600
```

#### 2. Caching Configuration

Optimize Redis caching:

```yaml
# config/redis.yaml
redis:
  max_connections: 50
  idle_timeout: 300
  cache_ttl: 3600
```

## Best Practices

### 1. Agent Design

- **Single Responsibility**: Design agents with specific, well-defined roles
- **Clear System Prompts**: Provide detailed, unambiguous instructions
- **Appropriate Model Selection**: Choose models based on task complexity and cost requirements

### 2. Workflow Design

- **Error Handling**: Implement robust error handling and fallback mechanisms
- **Resource Management**: Set appropriate timeouts and resource limits
- **Monitoring**: Include comprehensive logging and monitoring

### 3. Security

- **API Key Management**: Use secure secret management systems
- **Access Control**: Implement fine-grained access control policies
- **Audit Logging**: Enable comprehensive audit logging for compliance

### 4. Cost Optimization

- **Budget Monitoring**: Set up alerts for budget thresholds
- **Model Selection**: Use cost-effective models for appropriate tasks
- **Caching**: Implement intelligent caching to reduce API calls

## Conclusion

Shannon AI Agent Orchestrator provides a powerful, flexible platform for building and deploying enterprise-grade AI agent systems. With its microservices architecture, comprehensive security features, and advanced orchestration capabilities, Shannon enables organizations to harness the power of AI agents while maintaining control, security, and cost efficiency.

The platform's open-source nature ensures transparency and customizability, while its production-ready features make it suitable for enterprise deployment. Whether you're building simple chatbots or complex multi-agent workflows, Shannon provides the tools and infrastructure needed for success.

### Next Steps

1. **Explore Advanced Patterns**: Experiment with different orchestration patterns like Tree-of-Thoughts and Debate
2. **Custom Tool Development**: Create custom tools using the MCP protocol
3. **Production Deployment**: Deploy Shannon in your production environment
4. **Community Engagement**: Join the Shannon community on Discord and contribute to the project

### Resources

- **GitHub Repository**: [https://github.com/Kocoro-lab/Shannon](https://github.com/Kocoro-lab/Shannon)
- **Documentation**: Available in the `docs/` directory
- **Discord Community**: Join for support and discussions
- **Contributing Guide**: See `CONTRIBUTING.md` for contribution guidelines

Shannon represents the future of AI agent orchestration - open, secure, and enterprise-ready. Start building your AI agent systems today!
