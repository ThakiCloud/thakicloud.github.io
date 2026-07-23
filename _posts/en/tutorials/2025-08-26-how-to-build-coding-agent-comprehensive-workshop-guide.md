---
title: "How to Build a Coding Agent: A Comprehensive Workshop Guide"
excerpt: "Learn to build your own AI coding agent similar to Cursor, Cline, and Windsurf with this step-by-step tutorial using Go and Anthropic Claude API"
seo_title: "Build AI Coding Agent: Step-by-Step Tutorial with Go & Claude - Thaki Cloud"
seo_description: "Complete guide to building coding agents like Cursor and Windsurf. Learn tool integration, API management, and progressive development with practical examples"
date: 2025-08-26
tags:
  - ai-agent
  - coding-agent
  - anthropic-claude
  - go-programming
  - developer-tools
  - cursor-alternative
author_profile: true
toc: true
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/how-to-build-coding-agent-comprehensive-workshop-guide/
canonical_url: "https://thakicloud.com/tech-blog/en/tutorials/how-to-build-coding-agent-comprehensive-workshop-guide/"
published: false
categories:
  - tutorials
---

⏱️ **Expected Reading Time**: 15 minutes

## Introduction: The Rise of AI Coding Agents

The AI development landscape has been revolutionized by coding agents like Cursor, Cline, Amp, and Windsurf. These tools transform how developers write, debug, and maintain code by providing intelligent assistance that understands context, executes commands, and manages entire codebases.

[Geoffrey Huntley's workshop repository](https://github.com/ghuntley/how-to-build-a-coding-agent) provides a comprehensive guide to building your own coding agent from scratch. This tutorial will take you through the entire process, from basic chat functionality to advanced code search capabilities.

## Why Build Your Own Coding Agent?

### Understanding the Foundation

Building your own coding agent offers several advantages:

- **Complete Control**: Customize every aspect of the agent's behavior
- **Learning Opportunity**: Deep understanding of AI agent architecture
- **Cost Optimization**: Tailor resource usage to your specific needs
- **Privacy**: Keep sensitive code on your own infrastructure
- **Extensibility**: Add custom tools and integrations

### Modern Coding Agent Capabilities

Today's coding agents typically include:

1. **Natural Language Interface**: Chat-based interaction with developers
2. **File System Operations**: Reading, writing, and managing project files
3. **Code Search**: Advanced pattern matching and code discovery
4. **Command Execution**: Running system commands and build processes
5. **Context Awareness**: Understanding project structure and dependencies

## Workshop Architecture Overview

The workshop follows a progressive enhancement approach with six distinct applications, each building upon the previous one:

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
<div class="d3-arch" data-arch-root id="mprehensiveworkshopguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 748, "height": 846, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 112, "y": 24, "w": 120, "h": 46, "title": "chat.go"}, {"id": "B", "x": 199, "y": 148, "w": 120, "h": 46, "title": "read.go"}, {"id": "C", "x": 286, "y": 272, "w": 121, "h": 46, "title": "list_files.go"}, {"id": "D", "x": 382, "y": 396, "w": 120, "h": 46, "title": "bash_tool.go"}, {"id": "E", "x": 476, "y": 520, "w": 120, "h": 46, "title": "edit_tool.go"}, {"id": "F", "x": 553, "y": 644, "w": 163, "h": 46, "title": "code_search_tool.go"}, {"id": "A1", "x": 24, "y": 148, "w": 120, "h": 46, "title": "Basic Chat"}, {"id": "B1", "x": 111, "y": 272, "w": 120, "h": 46, "title": "File Reading"}, {"id": "C1", "x": 178, "y": 396, "w": 149, "h": 46, "title": "Directory Listing"}, {"id": "D1", "x": 272, "y": 520, "w": 149, "h": 46, "title": "Command Execution"}, {"id": "E1", "x": 378, "y": 644, "w": 120, "h": 46, "title": "File Editing"}, {"id": "F1", "x": 575, "y": 768, "w": 120, "h": 46, "title": "Code Search"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[204, 70], [259, 109], [259, 109], [259, 148]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[292, 194], [347, 233], [347, 233], [347, 272]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[382, 318], [442, 357], [442, 357], [442, 396]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[477, 442], [536, 481], [536, 481], [536, 520]]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[573, 566], [635, 605], [635, 605], [635, 644]]}, {"src": "A", "dst": "A1", "kind": "data", "curve": [[139, 70], [84, 109], [84, 109], [84, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "curve": [[226, 194], [171, 233], [171, 233], [171, 272]]}, {"src": "C", "dst": "C1", "kind": "data", "curve": [[312, 318], [252, 357], [252, 357], [252, 396]]}, {"src": "D", "dst": "D1", "kind": "data", "curve": [[406, 442], [347, 481], [347, 481], [347, 520]]}, {"src": "E", "dst": "E1", "kind": "data", "curve": [[500, 566], [438, 605], [438, 605], [438, 644]]}, {"src": "F", "dst": "F1", "kind": "data", "line": [635, 690, 635, 768]}]});
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
      const container = document.getElementById('mprehensiveworkshopguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'mprehensiveworkshopguide-1';
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

## Phase 1: Basic Chat Agent (chat.go)

### Core Architecture

The foundation starts with a simple chat interface that establishes the conversation loop pattern:

```go
type Agent struct {
    client      *anthropic.Client
    getUserMessage func() (string, bool)
    tools       []ToolDefinition
    verbose     bool
}
```

### Key Learning Points

- **API Integration**: Direct connection to Anthropic Claude API
- **Conversation Management**: Maintaining chat history and context
- **Error Handling**: Robust error management for API calls
- **User Interface**: Terminal-based interaction patterns

### Implementation Highlights

The chat agent demonstrates:
- Streaming responses for real-time interaction
- Conversation state management
- Basic error recovery mechanisms
- Logging and debugging capabilities

## Phase 2: File Reading Agent (read.go)

### Tool Integration Foundation

This phase introduces the tool system that becomes central to all subsequent agents:

```go
type ToolDefinition struct {
    Name        string
    Description string
    InputSchema ToolInputSchemaParam
    Function    func(input json.RawMessage) (string, error)
}
```

### Read File Tool Implementation

```go
type ReadFileInput struct {
    Path string `json:"path" jsonschema:"description=File path to read"`
}

func ReadFile(input json.RawMessage) (string, error) {
    var params ReadFileInput
    if err := json.Unmarshal(input, &params); err != nil {
        return "", err
    }
    
    content, err := os.ReadFile(params.Path)
    if err != nil {
        return "", fmt.Errorf("failed to read file: %w", err)
    }
    
    return string(content), nil
}
```

### Tool Registration Pattern

The workshop establishes a consistent pattern for tool registration:

```go
var readFileTool = ToolDefinition{
    Name:        "read_file",
    Description: "Read the contents of a file",
    InputSchema: GenerateSchema[ReadFileInput](),
    Function:    ReadFile,
}
```

## Phase 3: File System Navigation (list_files.go)

### Directory Operations

Building on file reading, this phase adds directory traversal capabilities:

```go
type ListFilesInput struct {
    Path string `json:"path" jsonschema:"description=Directory path to list"`
}
```

### Enhanced File Management

The list files tool provides:
- Recursive directory scanning
- File type filtering
- Path normalization
- Error handling for permissions and access issues

### Multi-Tool Coordination

This phase demonstrates how multiple tools work together:
- `read_file` for content access
- `list_files` for discovery
- Coordinated operations for complex tasks

## Phase 4: System Integration (bash_tool.go)

### Command Execution Capabilities

The bash tool introduces system-level operations:

```go
type BashInput struct {
    Command string `json:"command" jsonschema:"description=Bash command to execute"`
}

func BashCommand(input json.RawMessage) (string, error) {
    var params BashInput
    if err := json.Unmarshal(input, &params); err != nil {
        return "", err
    }
    
    cmd := exec.Command("bash", "-c", params.Command)
    output, err := cmd.CombinedOutput()
    
    return string(output), err
}
```

### Safety and Security Considerations

The workshop addresses critical security aspects:
- Command validation and sanitization
- Output capture and error handling
- Process management and timeouts
- Permission and access controls

### Real-World Applications

With command execution, the agent can:
- Run build processes and tests
- Install dependencies and packages
- Execute git operations
- Perform system diagnostics

## Phase 5: Code Editing (edit_tool.go)

### File Modification Engine

The edit tool represents a significant capability leap:

```go
type EditFileInput struct {
    Path   string `json:"path" jsonschema:"description=File path to edit"`
    OldStr string `json:"old_str" jsonschema:"description=String to replace"`
    NewStr string `json:"new_str" jsonschema:"description=Replacement string"`
}
```

### Validation and Safety

The edit tool implements several safety mechanisms:
- Content validation before modification
- Backup creation for rollback capability
- Atomic operations to prevent partial edits
- Diff generation for change tracking

### Advanced Editing Features

Key capabilities include:
- Precise string replacement
- Multi-line content handling
- Indentation preservation
- Encoding and character set management

## Phase 6: Code Discovery (code_search_tool.go)

### Ripgrep Integration

The final phase adds powerful code search using ripgrep:

```go
type CodeSearchInput struct {
    Pattern       string `json:"pattern" jsonschema:"description=Search pattern"`
    Path          string `json:"path,omitempty" jsonschema:"description=Search path"`
    FileType      string `json:"file_type,omitempty" jsonschema:"description=File type filter"`
    CaseSensitive bool   `json:"case_sensitive,omitempty" jsonschema:"description=Case sensitive search"`
}
```

### Advanced Search Capabilities

The code search tool provides:
- Regular expression pattern matching
- File type filtering for targeted searches
- Case sensitivity options
- Context line inclusion
- Performance optimization for large codebases

### Search Strategy Patterns

Common search patterns include:
- Function and method definitions
- Variable and constant declarations
- Import and dependency analysis
- TODO and FIXME comment discovery
- Error handling pattern identification

## Development Environment Setup

### Prerequisites and Dependencies

The workshop uses modern development practices:

```yaml
# devenv.yaml
name: coding-agent-workshop
starship: true

imports:
  - devenv-nixpkgs

env:
  ANTHROPIC_API_KEY: "your-api-key-here"

languages:
  go:
    enable: true
    package: "go_1_24"
```

### Environment Benefits

Using devenv provides:
- Reproducible development environments
- Automatic dependency management
- Cross-platform compatibility
- Version consistency across team members

## Tool System Architecture Deep Dive

### Schema Generation

The workshop demonstrates automatic JSON schema generation:

```go
func GenerateSchema[T any]() ToolInputSchemaParam {
    schema := jsonschema.Reflect(&struct{ T }{})
    return ToolInputSchemaParam{
        Type:       "object",
        Properties: schema.Properties,
        Required:   schema.Required,
    }
}
```

### Event Loop Pattern

All agents follow a consistent event loop:

1. **User Input**: Accept and validate user commands
2. **Context Building**: Assemble conversation history
3. **API Request**: Send request to Claude with available tools
4. **Tool Execution**: Process tool use requests
5. **Result Integration**: Combine tool outputs with AI responses
6. **Response Delivery**: Present final results to user

### Error Handling Strategy

The workshop implements comprehensive error handling:
- Input validation and sanitization
- API error recovery and retry logic
- Tool execution timeout management
- User-friendly error messaging
- Debugging and logging capabilities

## Advanced Features and Extensions

### Verbose Logging

All applications support verbose mode for debugging:

```bash
go run edit_tool.go --verbose
```

This provides detailed insights into:
- API call timing and performance
- Tool execution traces
- File operation details
- Error diagnostic information

### Custom Tool Development

The framework supports easy tool extension:

```go
func CustomTool(input json.RawMessage) (string, error) {
    // Custom tool implementation
    return result, nil
}

var customToolDef = ToolDefinition{
    Name:        "custom_tool",
    Description: "Custom functionality",
    InputSchema: GenerateSchema[CustomInput](),
    Function:    CustomTool,
}
```

## Testing and Validation

### Sample Files

The repository includes test files for experimentation:
- `fizzbuzz.js`: JavaScript code for editing practice
- `riddle.txt`: Text content for reading tests
- `AGENT.md`: Documentation for analysis

### Test Scenarios

Recommended testing approach:

1. **Basic Functionality**: File reading and listing
2. **System Integration**: Command execution and output capture
3. **Code Modification**: Safe editing and validation
4. **Search Operations**: Pattern matching and discovery
5. **Error Conditions**: Handling failures and edge cases

## Production Considerations

### Security Best Practices

When deploying coding agents:
- Implement proper authentication and authorization
- Sanitize all user inputs and commands
- Use sandboxed execution environments
- Monitor and log all agent activities
- Implement rate limiting and usage controls

### Performance Optimization

Key optimization strategies:
- Cache frequently accessed files and search results
- Implement lazy loading for large codebases
- Use streaming responses for long operations
- Optimize tool execution order and parallelization
- Monitor memory usage and cleanup resources

### Scalability Planning

For larger deployments:
- Implement horizontal scaling with load balancing
- Use distributed caching for shared state
- Consider microservice architecture for tool isolation
- Plan for concurrent user sessions
- Implement proper monitoring and observability

## Common Issues and Troubleshooting

### API Integration Problems

Typical issues and solutions:
- **Rate Limiting**: Implement exponential backoff
- **Authentication**: Verify API key configuration
- **Network Issues**: Add retry logic with circuit breakers
- **Response Parsing**: Validate JSON schema compatibility

### Tool Execution Challenges

Common problems:
- **Permission Errors**: Check file system permissions
- **Path Issues**: Normalize and validate file paths
- **Command Failures**: Implement proper error capture
- **Resource Limits**: Monitor memory and CPU usage

## Next Steps and Advanced Topics

### Feature Enhancements

Consider adding:
- Web scraping capabilities for external content
- Database integration for persistent storage
- API integration for external services
- Multi-language support beyond Go
- GUI interfaces for non-technical users

### Architecture Evolution

Advanced patterns to explore:
- Event-driven architecture with message queues
- Plugin systems for extensible functionality
- Distributed agent coordination
- Machine learning integration for behavior adaptation
- Real-time collaboration features

## Conclusion

Building a coding agent from scratch provides invaluable insights into AI-assisted development. The [how-to-build-a-coding-agent workshop](https://github.com/ghuntley/how-to-build-a-coding-agent) offers a structured, progressive approach that takes you from basic chat functionality to a fully-featured coding assistant.

The six-phase progression—from simple conversation to advanced code search—demonstrates how complex AI systems can be built incrementally. Each phase introduces essential concepts while building upon previous foundations, creating a comprehensive understanding of agent architecture.

### Key Takeaways

1. **Progressive Development**: Start simple and add complexity gradually
2. **Tool-Centric Design**: Build reusable, composable tool systems
3. **Safety First**: Implement validation and error handling throughout
4. **Real-World Testing**: Use practical examples and edge cases
5. **Production Readiness**: Consider security, performance, and scalability

The modern development landscape increasingly relies on AI-powered tools. Understanding how to build and customize these agents puts you at the forefront of this technological evolution. Whether you're building internal tools, contributing to open-source projects, or creating commercial products, the principles and practices demonstrated in this workshop provide a solid foundation for success.

Start with the basic chat agent, progress through each phase methodically, and soon you'll have your own sophisticated coding agent tailored to your specific needs and workflows.
