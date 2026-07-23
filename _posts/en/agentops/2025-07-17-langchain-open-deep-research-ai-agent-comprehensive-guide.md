---
title: "LangChain Open Deep Research: Complete Guide to the Multi-Agent AI Research Automation System"
excerpt: "An in-depth guide to LangChain Open Deep Research covering quality-focused agents, multi-agent research systems, and advanced RAG architecture. Practical implementation patterns for production research automation."
seo_title: "LangChain Open Deep Research Complete Guide - Multi-Agent Research System - Thaki Cloud"
seo_description: "LangChain Open Deep Research comprehensive analysis. QualityFocusedAgent, MultiAgentResearchSystem, AdvancedRAGSystem implementation, domain-specific agents, and Kubernetes deployment guide for AI-powered research automation."
date: 2025-07-17
last_modified_at: 2025-07-17
tags:
  - langchain
  - open-deep-research
  - multi-agent
  - research-automation
  - advanced-rag
  - ai-research
  - langgraph
  - llm-orchestration
  - knowledge-synthesis
  - production-ai
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/langchain-open-deep-research-ai-agent-comprehensive-guide/"
lang: en
reading_time: true
categories:
  - agentops
published: false
---

⏱️ **Estimated reading time**: 20 min

## Introduction

**LangChain Open Deep Research** is an open-source multi-agent system designed to automate complex research tasks end to end. It combines web search, document retrieval, synthesis, and report generation into a coordinated pipeline where specialized agents handle distinct phases of the research process.

This guide covers the full architecture from core concepts to production deployment, including the quality-focused agent design, multi-agent orchestration patterns, advanced RAG, and domain-specific adaptations for financial and medical research.

![Concept diagram]({{ '/assets/images/langchain-open-deep-research-ai-agent-comprehensive-guide-diagram.svg' | relative_url }})

*Concept diagram*

## System Architecture Overview

Open Deep Research uses a hub-and-spoke agent architecture built on LangGraph:

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
<div class="d3-arch" data-arch-root id="iagentcomprehensiveguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 604, "height": 984, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 205, "y": 24, "w": 142, "h": 46, "title": "Research Request"}, {"id": "B", "x": 216, "y": 148, "w": 120, "h": 46, "title": "Orchestrator"}, {"id": "C", "x": 272, "y": 272, "w": 121, "h": 46, "title": "Query Planner"}, {"id": "D", "x": 442, "y": 396, "w": 120, "h": 46, "title": "Search Agent"}, {"id": "E", "x": 93, "y": 396, "w": 128, "h": 46, "title": "Document Agent"}, {"id": "F", "x": 452, "y": 520, "w": 120, "h": 46, "title": "Web Sources"}, {"id": "G", "x": 277, "y": 520, "w": 120, "h": 46, "title": "Vector Store"}, {"id": "H", "x": 87, "y": 520, "w": 135, "h": 46, "title": "Synthesis Agent"}, {"id": "I", "x": 35, "y": 644, "w": 120, "h": 46, "title": "Quality Gate"}, {"id": "J", "x": 24, "y": 782, "w": 142, "h": 46, "title": "Report Generator"}, {"id": "K", "x": 35, "y": 906, "w": 120, "h": 46, "title": "Final Report"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [276, 70, 276, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[297, 194], [333, 233], [333, 233], [333, 272]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[393, 317], [502, 357], [502, 357], [502, 396]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[272, 316], [157, 357], [157, 357], [157, 396]]}, {"src": "D", "dst": "F", "kind": "data", "line": [505, 442, 512, 520]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[221, 441], [335, 481], [335, 481], [336, 520]]}, {"src": "D", "dst": "H", "kind": "data", "curve": [[472, 442], [422, 481], [422, 481], [222, 527]]}, {"src": "E", "dst": "H", "kind": "data", "line": [155, 442, 153, 520]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[154, 566], [154, 605], [154, 605], [117, 644]]}, {"src": "I", "dst": "J", "kind": "data", "label": "Pass", "line": [95, 690, 95, 782], "lx": 95, "ly": 732}, {"src": "I", "dst": "B", "kind": "data", "label": "Fail", "curve": [[76, 644], [43, 481], [43, 295], [216, 187]], "off": "50%"}, {"src": "J", "dst": "K", "kind": "data", "line": [95, 828, 95, 906]}]});
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
      const container = document.getElementById('iagentcomprehensiveguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'iagentcomprehensiveguide-1';
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

### Core Design Principles

1. **Quality over speed**: Every research output passes a quality gate before being delivered
2. **Parallel execution**: Independent searches run concurrently to reduce total latency
3. **Source attribution**: All claims are linked to verifiable sources
4. **Iterative refinement**: The orchestrator can re-dispatch failed quality checks
5. **Domain awareness**: Agents can be configured with domain-specific knowledge

## Quality-Focused Agent

The `QualityFocusedAgent` is the backbone of reliable research output:

```python
from langchain_core.prompts import ChatPromptTemplate
from langchain_anthropic import ChatAnthropic
from langgraph.graph import StateGraph, END
from typing import TypedDict, List, Optional
import asyncio

class ResearchState(TypedDict):
    query: str
    sub_queries: List[str]
    search_results: List[dict]
    synthesized_content: str
    quality_score: float
    final_report: Optional[str]
    iteration: int

class QualityFocusedAgent:
    def __init__(
        self,
        model: str = "claude-3-7-sonnet-latest",
        quality_threshold: float = 0.8,
        max_iterations: int = 3
    ):
        self.llm = ChatAnthropic(model=model)
        self.quality_threshold = quality_threshold
        self.max_iterations = max_iterations
        self.graph = self._build_graph()

    def _build_graph(self) -> StateGraph:
        workflow = StateGraph(ResearchState)

        workflow.add_node("plan_queries", self._plan_queries)
        workflow.add_node("search", self._parallel_search)
        workflow.add_node("synthesize", self._synthesize)
        workflow.add_node("evaluate_quality", self._evaluate_quality)
        workflow.add_node("generate_report", self._generate_report)

        workflow.set_entry_point("plan_queries")
        workflow.add_edge("plan_queries", "search")
        workflow.add_edge("search", "synthesize")
        workflow.add_edge("synthesize", "evaluate_quality")
        workflow.add_conditional_edges(
            "evaluate_quality",
            self._quality_router,
            {
                "retry": "plan_queries",
                "pass": "generate_report",
                "max_retries": END
            }
        )
        workflow.add_edge("generate_report", END)

        return workflow.compile()

    async def _plan_queries(self, state: ResearchState) -> ResearchState:
        prompt = ChatPromptTemplate.from_template(
            "Break down this research query into 3-5 specific sub-queries "
            "that together cover the topic comprehensively.\n\nQuery: {query}"
        )
        response = await self.llm.ainvoke(prompt.format_messages(query=state["query"]))
        sub_queries = self._parse_sub_queries(response.content)
        return {**state, "sub_queries": sub_queries}

    async def _parallel_search(self, state: ResearchState) -> ResearchState:
        tasks = [self._search_one(q) for q in state["sub_queries"]]
        results = await asyncio.gather(*tasks, return_exceptions=True)
        flat_results = []
        for r in results:
            if isinstance(r, list):
                flat_results.extend(r)
        return {**state, "search_results": flat_results}

    async def _search_one(self, query: str) -> List[dict]:
        # Integrate your search backend here (Tavily, Bing, etc.)
        return []

    async def _synthesize(self, state: ResearchState) -> ResearchState:
        context = self._format_results(state["search_results"])
        prompt = ChatPromptTemplate.from_template(
            "Synthesize the following search results into a coherent, "
            "factual summary for the query: {query}\n\nSources:\n{context}"
        )
        response = await self.llm.ainvoke(
            prompt.format_messages(query=state["query"], context=context)
        )
        return {**state, "synthesized_content": response.content}

    async def _evaluate_quality(self, state: ResearchState) -> ResearchState:
        prompt = ChatPromptTemplate.from_template(
            "Rate the quality of this research synthesis on a scale of 0.0 to 1.0. "
            "Consider: factual accuracy, completeness, source diversity, and clarity.\n\n"
            "Query: {query}\n\nSynthesis: {synthesis}\n\n"
            "Respond with just the score, e.g.: 0.85"
        )
        response = await self.llm.ainvoke(
            prompt.format_messages(
                query=state["query"],
                synthesis=state["synthesized_content"]
            )
        )
        try:
            score = float(response.content.strip())
        except ValueError:
            score = 0.5
        return {**state, "quality_score": score}

    def _quality_router(self, state: ResearchState) -> str:
        if state["iteration"] >= self.max_iterations:
            return "max_retries"
        if state["quality_score"] >= self.quality_threshold:
            return "pass"
        return "retry"

    async def _generate_report(self, state: ResearchState) -> ResearchState:
        prompt = ChatPromptTemplate.from_template(
            "Generate a comprehensive research report based on this synthesis.\n\n"
            "Query: {query}\n\nSynthesis: {synthesis}"
        )
        response = await self.llm.ainvoke(
            prompt.format_messages(
                query=state["query"],
                synthesis=state["synthesized_content"]
            )
        )
        return {**state, "final_report": response.content}

    def _parse_sub_queries(self, content: str) -> List[str]:
        lines = [l.strip() for l in content.split("\n") if l.strip()]
        return [l.lstrip("0123456789.-) ") for l in lines if len(l) > 10][:5]

    def _format_results(self, results: List[dict]) -> str:
        return "\n\n".join(
            f"Source: {r.get('url', 'unknown')}\n{r.get('content', '')}"
            for r in results[:10]
        )

    async def research(self, query: str) -> str:
        initial_state = ResearchState(
            query=query,
            sub_queries=[],
            search_results=[],
            synthesized_content="",
            quality_score=0.0,
            final_report=None,
            iteration=0
        )
        final_state = await self.graph.ainvoke(initial_state)
        return final_state.get("final_report", "Research could not be completed.")
```

## Multi-Agent Research System

For large-scale or domain-spanning research, a multi-agent setup distributes the workload:

```python
from dataclasses import dataclass, field
from typing import Dict
import asyncio

@dataclass
class ResearchTask:
    task_id: str
    topic: str
    depth: str = "comprehensive"
    domains: List[str] = field(default_factory=list)

class MultiAgentResearchSystem:
    def __init__(self, num_workers: int = 4):
        self.num_workers = num_workers
        self.agents: Dict[str, QualityFocusedAgent] = {}
        self.task_queue: asyncio.Queue = asyncio.Queue()
        self.results: Dict[str, str] = {}

    def _get_or_create_agent(self, domain: str) -> QualityFocusedAgent:
        if domain not in self.agents:
            self.agents[domain] = QualityFocusedAgent(
                model="claude-3-7-sonnet-latest",
                quality_threshold=0.82
            )
        return self.agents[domain]

    async def _worker(self, worker_id: int):
        while True:
            task: ResearchTask = await self.task_queue.get()
            try:
                domain = task.domains[0] if task.domains else "general"
                agent = self._get_or_create_agent(domain)
                result = await agent.research(task.topic)
                self.results[task.task_id] = result
            except Exception as e:
                self.results[task.task_id] = f"Error: {e}"
            finally:
                self.task_queue.task_done()

    async def run(self, tasks: List[ResearchTask]) -> Dict[str, str]:
        workers = [
            asyncio.create_task(self._worker(i))
            for i in range(self.num_workers)
        ]
        for task in tasks:
            await self.task_queue.put(task)
        await self.task_queue.join()
        for w in workers:
            w.cancel()
        return self.results

# Usage
async def main():
    system = MultiAgentResearchSystem(num_workers=3)

    tasks = [
        ResearchTask("t1", "Impact of large language models on software engineering productivity", domains=["technology"]),
        ResearchTask("t2", "Current state of quantum computing hardware", domains=["physics", "technology"]),
        ResearchTask("t3", "Advances in mRNA vaccine technology post-COVID", domains=["medicine"]),
    ]

    results = await system.run(tasks)
    for task_id, report in results.items():
        print(f"\n=== {task_id} ===\n{report[:500]}...")
```

## Advanced RAG System

The `AdvancedRAGSystem` provides retrieval-augmented generation with hybrid search and reranking:

```python
from langchain_community.vectorstores import Chroma
from langchain_anthropic import ChatAnthropic
from langchain_openai import OpenAIEmbeddings
from langchain_core.documents import Document
from langchain.retrievers import BM25Retriever, EnsembleRetriever
from langchain_community.cross_encoders import HuggingFaceCrossEncoder
from langchain.retrievers.document_compressors import CrossEncoderReranker
from typing import List

class AdvancedRAGSystem:
    def __init__(
        self,
        vector_store_path: str = "./chroma_db",
        top_k: int = 10,
        rerank_top_k: int = 4
    ):
        self.embeddings = OpenAIEmbeddings(model="text-embedding-3-large")
        self.llm = ChatAnthropic(model="claude-3-7-sonnet-latest")
        self.top_k = top_k
        self.rerank_top_k = rerank_top_k

        self.vector_store = Chroma(
            persist_directory=vector_store_path,
            embedding_function=self.embeddings
        )
        self.reranker = CrossEncoderReranker(
            model=HuggingFaceCrossEncoder(model_name="BAAI/bge-reranker-v2-m3"),
            top_n=rerank_top_k
        )

    def add_documents(self, docs: List[Document]) -> None:
        self.vector_store.add_documents(docs)

    def _build_ensemble_retriever(self, docs: List[Document]) -> EnsembleRetriever:
        semantic = self.vector_store.as_retriever(
            search_kwargs={"k": self.top_k}
        )
        bm25 = BM25Retriever.from_documents(docs)
        bm25.k = self.top_k
        return EnsembleRetriever(
            retrievers=[semantic, bm25],
            weights=[0.6, 0.4]
        )

    async def query(self, question: str, docs: List[Document] = None) -> dict:
        if docs:
            retriever = self._build_ensemble_retriever(docs)
        else:
            retriever = self.vector_store.as_retriever(
                search_kwargs={"k": self.top_k}
            )

        raw_docs = retriever.get_relevant_documents(question)
        reranked = self.reranker.compress_documents(raw_docs, question)

        context = "\n\n".join(d.page_content for d in reranked)
        prompt = (
            f"Answer the following question using only the provided context. "
            f"Cite specific sources where possible.\n\n"
            f"Question: {question}\n\nContext:\n{context}"
        )
        response = await self.llm.ainvoke(prompt)

        return {
            "answer": response.content,
            "sources": [d.metadata.get("source", "unknown") for d in reranked],
            "num_sources": len(reranked)
        }
```

## Domain-Specific Agents

### Financial Research Agent

```python
from langchain_community.tools import YahooFinanceNewsTool
from langchain_community.utilities import SerpAPIWrapper

class FinancialResearchAgent(QualityFocusedAgent):
    def __init__(self):
        super().__init__(
            model="claude-3-7-sonnet-latest",
            quality_threshold=0.88,
            max_iterations=4
        )
        self.news_tool = YahooFinanceNewsTool()
        self.search_tool = SerpAPIWrapper()

        self.financial_prompt_suffix = (
            "\n\nIMPORTANT: This is financial research. "
            "Clearly distinguish between facts and projections. "
            "Include relevant risk factors. "
            "Do not make investment recommendations. "
            "Cite all quantitative data with its source and date."
        )

    async def research_company(self, ticker: str, aspects: List[str] = None) -> dict:
        if aspects is None:
            aspects = ["business model", "financials", "competitive position", "risks"]

        tasks = [
            self.research(f"{ticker} {aspect}{self.financial_prompt_suffix}")
            for aspect in aspects
        ]
        results = await asyncio.gather(*tasks)

        return {
            "ticker": ticker,
            "sections": dict(zip(aspects, results)),
            "generated_at": "2025-07-17"
        }

    async def compare_peers(self, tickers: List[str], metric: str) -> str:
        query = (
            f"Compare {', '.join(tickers)} on {metric}. "
            f"Include recent data and trends.{self.financial_prompt_suffix}"
        )
        return await self.research(query)
```

### Medical Research Agent

```python
class MedicalResearchAgent(QualityFocusedAgent):
    def __init__(self):
        super().__init__(
            model="claude-3-7-sonnet-latest",
            quality_threshold=0.92,  # Higher threshold for medical content
            max_iterations=5
        )
        self.pubmed_sources = [
            "pubmed.ncbi.nlm.nih.gov",
            "nejm.org",
            "thelancet.com",
            "jamanetwork.com"
        ]
        self.disclaimer = (
            "\n\nDISCLAIMER: This is for informational purposes only and does not "
            "constitute medical advice. Consult qualified healthcare professionals "
            "for medical decisions."
        )

    async def research_condition(self, condition: str) -> dict:
        sections = {
            "overview": f"Overview and epidemiology of {condition}",
            "pathophysiology": f"Pathophysiology and mechanisms of {condition}",
            "diagnosis": f"Diagnostic criteria and methods for {condition}",
            "treatment": f"Current evidence-based treatments for {condition}",
            "research": f"Recent clinical trials and research advances in {condition}"
        }

        tasks = [self.research(q) for q in sections.values()]
        results = await asyncio.gather(*tasks)

        return {
            "condition": condition,
            "sections": dict(zip(sections.keys(), results)),
            "disclaimer": self.disclaimer.strip()
        }
```

## Production Integration: Slack and Teams

```python
from slack_sdk.web.async_client import AsyncWebClient
from slack_sdk.errors import SlackApiError

class ResearchNotificationService:
    def __init__(self, slack_token: str, default_channel: str):
        self.slack = AsyncWebClient(token=slack_token)
        self.default_channel = default_channel

    async def post_research_complete(
        self,
        channel: str,
        topic: str,
        report: str,
        quality_score: float,
        thread_ts: str = None
    ):
        # Post summary to channel
        summary = report[:500] + "..." if len(report) > 500 else report
        blocks = [
            {
                "type": "header",
                "text": {"type": "plain_text", "text": f"Research Complete: {topic[:50]}"}
            },
            {
                "type": "section",
                "text": {
                    "type": "mrkdwn",
                    "text": f"*Quality Score:* {quality_score:.0%}\n\n{summary}"
                }
            }
        ]

        try:
            response = await self.slack.chat_postMessage(
                channel=channel or self.default_channel,
                blocks=blocks,
                thread_ts=thread_ts
            )
            # Post full report in thread
            if len(report) > 500:
                await self.slack.chat_postMessage(
                    channel=channel or self.default_channel,
                    text=f"*Full Report:*\n\n{report}",
                    thread_ts=response["ts"]
                )
        except SlackApiError as e:
            print(f"Slack error: {e.response['error']}")
```

## Prometheus Metrics and Monitoring

```python
from prometheus_client import Counter, Histogram, Gauge, start_http_server
import time

class ResearchMetrics:
    def __init__(self):
        self.research_total = Counter(
            "research_requests_total",
            "Total research requests",
            ["status", "domain"]
        )
        self.research_duration = Histogram(
            "research_duration_seconds",
            "Research task duration",
            ["domain"],
            buckets=[5, 15, 30, 60, 120, 300]
        )
        self.quality_score = Histogram(
            "research_quality_score",
            "Quality scores of completed research",
            buckets=[0.5, 0.6, 0.7, 0.8, 0.85, 0.9, 0.95, 1.0]
        )
        self.active_tasks = Gauge(
            "research_active_tasks",
            "Currently running research tasks"
        )
        self.token_usage = Counter(
            "llm_tokens_total",
            "Total LLM tokens used",
            ["model", "type"]
        )

    def record_request(self, domain: str, status: str):
        self.research_total.labels(status=status, domain=domain).inc()

    def record_duration(self, domain: str, seconds: float):
        self.research_duration.labels(domain=domain).observe(seconds)

    def record_quality(self, score: float):
        self.quality_score.observe(score)

metrics = ResearchMetrics()

# Instrument the QualityFocusedAgent
original_research = QualityFocusedAgent.research

async def instrumented_research(self, query: str) -> str:
    domain = getattr(self, "domain", "general")
    metrics.active_tasks.inc()
    start = time.time()
    try:
        result = await original_research(self, query)
        metrics.record_request(domain, "success")
        return result
    except Exception as e:
        metrics.record_request(domain, "error")
        raise
    finally:
        metrics.active_tasks.dec()
        metrics.record_duration(domain, time.time() - start)

QualityFocusedAgent.research = instrumented_research
```

## Kubernetes Deployment

```yaml
# open-deep-research-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: open-deep-research
  namespace: ai-research
spec:
  replicas: 3
  selector:
    matchLabels:
      app: open-deep-research
  template:
    metadata:
      labels:
        app: open-deep-research
      annotations:
        prometheus.io/scrape: "true"
        prometheus.io/port: "9090"
        prometheus.io/path: "/metrics"
    spec:
      containers:
      - name: research-service
        image: your-registry/open-deep-research:latest
        ports:
        - containerPort: 8000
          name: http
        - containerPort: 9090
          name: metrics
        env:
        - name: ANTHROPIC_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-keys
              key: anthropic
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-keys
              key: openai
        - name: TAVILY_API_KEY
          valueFrom:
            secretKeyRef:
              name: ai-keys
              key: tavily
        - name: VECTOR_STORE_PATH
          value: "/data/chroma"
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        livenessProbe:
          httpGet:
            path: /health
            port: 8000
          initialDelaySeconds: 30
          periodSeconds: 15
        readinessProbe:
          httpGet:
            path: /ready
            port: 8000
          initialDelaySeconds: 10
          periodSeconds: 5
        volumeMounts:
        - name: vector-store
          mountPath: /data/chroma
      volumes:
      - name: vector-store
        persistentVolumeClaim:
          claimName: chroma-pvc
---
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: research-hpa
  namespace: ai-research
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment
    name: open-deep-research
  minReplicas: 2
  maxReplicas: 15
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 65
  - type: Pods
    pods:
      metric:
        name: research_active_tasks
      target:
        type: AverageValue
        averageValue: "5"
```

## FastAPI Service Layer

```python
from fastapi import FastAPI, BackgroundTasks, HTTPException
from pydantic import BaseModel
from uuid import uuid4
import asyncio

app = FastAPI(title="Open Deep Research API")
research_system = MultiAgentResearchSystem(num_workers=4)
task_store: dict = {}

class ResearchRequest(BaseModel):
    topic: str
    domain: str = "general"
    depth: str = "comprehensive"

class ResearchResponse(BaseModel):
    task_id: str
    status: str

@app.post("/research", response_model=ResearchResponse)
async def submit_research(
    request: ResearchRequest,
    background_tasks: BackgroundTasks
):
    task_id = str(uuid4())
    task_store[task_id] = {"status": "queued", "result": None}
    background_tasks.add_task(
        _run_research, task_id, request.topic, request.domain
    )
    return ResearchResponse(task_id=task_id, status="queued")

async def _run_research(task_id: str, topic: str, domain: str):
    task_store[task_id]["status"] = "running"
    try:
        task = ResearchTask(task_id=task_id, topic=topic, domains=[domain])
        results = await research_system.run([task])
        task_store[task_id]["status"] = "completed"
        task_store[task_id]["result"] = results.get(task_id)
    except Exception as e:
        task_store[task_id]["status"] = "failed"
        task_store[task_id]["error"] = str(e)

@app.get("/research/{task_id}")
async def get_research(task_id: str):
    if task_id not in task_store:
        raise HTTPException(status_code=404, detail="Task not found")
    return task_store[task_id]

@app.get("/health")
async def health():
    return {"status": "ok"}
```

## Cost Management

### Token Usage Tracking

```python
from langchain_core.callbacks import BaseCallbackHandler
from dataclasses import dataclass, field

@dataclass
class UsageStats:
    input_tokens: int = 0
    output_tokens: int = 0
    cache_read_tokens: int = 0
    requests: int = 0

    @property
    def estimated_cost_usd(self) -> float:
        # Claude 3 Sonnet pricing (approximate)
        input_cost = self.input_tokens * 3e-6
        output_cost = self.output_tokens * 15e-6
        cache_cost = self.cache_read_tokens * 0.3e-6
        return input_cost + output_cost + cache_cost

class TokenTracker(BaseCallbackHandler):
    def __init__(self):
        self.stats = UsageStats()

    def on_llm_end(self, response, **kwargs):
        if hasattr(response, "llm_output") and response.llm_output:
            usage = response.llm_output.get("usage", {})
            self.stats.input_tokens += usage.get("input_tokens", 0)
            self.stats.output_tokens += usage.get("output_tokens", 0)
            self.stats.cache_read_tokens += usage.get("cache_read_input_tokens", 0)
            self.stats.requests += 1
```

## Summary and Recommendations

LangChain Open Deep Research provides a solid foundation for automating complex, multi-step research tasks. The architecture is modular enough to adapt to diverse domains while maintaining quality standards through iterative refinement.

**When to use it:**
- Research topics that require synthesizing information from many sources
- Recurring research workflows (competitive intelligence, literature reviews)
- Teams that need structured, cited research outputs at scale

**Key architectural decisions:**
- Use the `QualityFocusedAgent` as the base for all domain-specific agents; override only what differs
- Set quality thresholds conservatively (0.85+) for public-facing outputs
- Deploy the multi-agent system behind a task queue for large workloads
- Instrument with Prometheus from day one to track token costs and quality trends

**Limitations to plan for:**
- Token costs scale with research depth; cache aggressively
- Quality scores are themselves LLM outputs and not perfectly calibrated
- Web search results vary in freshness; add date filters for time-sensitive topics
- The system does not replace domain experts; treat outputs as first drafts

---

**References**:
- [LangChain Open Deep Research](https://github.com/langchain-ai/open_deep_research)
- [LangGraph Documentation](https://langchain-ai.github.io/langgraph/)
- [LangChain Documentation](https://python.langchain.com/docs/introduction/)
- [Anthropic Claude API](https://docs.anthropic.com/)
