---
title: "Stanford STORM: Complete Guide to the LLM-Based Knowledge Curation Agent System"
excerpt: "Complete analysis of STORM and Co-STORM developed at Stanford. Practical guide covering automated research, report generation, citation systems, and collaborative AI agents."
seo_title: "Stanford STORM Complete Guide - LLM Knowledge Curation Agent System - Thaki Cloud"
seo_description: "Complete analysis of the Stanford STORM project. Automated research, Wikipedia-style report generation, collaborative AI agents, and production deployment guide. How to use the 25.4k-star open-source project."
date: 2025-06-30
last_modified_at: 2025-06-30
tags:
  - stanford-storm
  - knowledge-curation
  - llm-agents
  - report-generation
  - collaborative-ai
  - retrieval-augmented-generation
  - agentic-rag
  - research-automation
  - wikipedia-generation
  - multi-agent-system
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/agentops/stanford-storm-comprehensive-guide/"
lang: en
reading_time: true
published: false
categories:
  - agentops
---

⏱️ **Estimated reading time**: 10 min

## Introduction

**STORM (Synthesis of Topic Outlines through Retrieval and Multi-perspective Question Asking)** developed at Stanford is an LLM-based knowledge curation agent system. With **25.4k GitHub stars**, this project is an innovative system that automatically researches topics and generates full-length reports complete with citations.

**STORM** is not just a text generator. It is an **intelligent agent system** that raises questions from diverse perspectives, collects information, and organizes it systematically to produce Wikipedia-quality reports.

This guide covers the core features of STORM and Co-STORM, practical usage, and customization methods in full detail.

## STORM System Overview

### Core Features

**STORM** has the following innovative characteristics:

- **Automated research**: Multi-angle information gathering on a topic
- **Citation system**: Source attribution for all content
- **Structured organization**: Wikipedia-style hierarchical outlines
- **Multiple perspectives**: Approach from various expert viewpoints
- **Collaborative mode**: Human-AI collaboration support through Co-STORM
- **Customization**: Applicable to various domains

### STORM vs Co-STORM

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
<div class="d3-arch" data-arch-root id="dstormcomprehensiveguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 701, "height": 671, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 305, "w": 135, "h": 46, "title": "STORM Ecosystem"}, {"id": "B", "x": 251, "y": 460, "w": 142, "h": 62, "title": ["STORM", "Automated System"]}, {"id": "C", "x": 237, "y": 133, "w": 170, "h": 62, "title": ["Co-STORM", "Collaborative System"]}, {"id": "D", "x": 503, "y": 577, "w": 149, "h": 62, "title": ["Fully Automated", "Report Generation"]}, {"id": "E", "x": 510, "y": 460, "w": 135, "h": 62, "title": ["Wikipedia-Style", "Outline"]}, {"id": "F", "x": 489, "y": 343, "w": 177, "h": 62, "title": ["Multi-Perspective", "Information Gathering"]}, {"id": "G", "x": 485, "y": 242, "w": 184, "h": 46, "title": "Human-AI Collaboration"}, {"id": "H", "x": 499, "y": 141, "w": 156, "h": 46, "title": "Real-Time Dialogue"}, {"id": "I", "x": 499, "y": 24, "w": 156, "h": 62, "title": ["User-Engaged", "Knowledge Curation"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[106, 351], [198, 491], [198, 491], [251, 491]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[106, 305], [198, 164], [198, 164], [237, 164]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[355, 522], [446, 608], [446, 608], [503, 608]]}, {"src": "B", "dst": "E", "kind": "data", "line": [393, 491, 510, 491]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[355, 460], [446, 374], [446, 374], [489, 374]]}, {"src": "C", "dst": "G", "kind": "data", "curve": [[360, 195], [446, 265], [446, 265], [485, 265]]}, {"src": "C", "dst": "H", "kind": "data", "line": [407, 164, 499, 164]}, {"src": "C", "dst": "I", "kind": "data", "curve": [[357, 133], [446, 55], [446, 55], [499, 55]]}]});
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
      const container = document.getElementById('dstormcomprehensiveguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'dstormcomprehensiveguide-1';
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

## STORM Architecture Deep Dive

### 4 Core Modules

**STORM** consists of the following 4 modules:

#### 1. Knowledge Curation Module

```python
# Knowledge gathering process
class KnowledgeCurationModule:
    def __init__(self, retriever, llm):
        self.retriever = retriever  # Bing, Google, etc.
        self.llm = llm
    
    def collect_information(self, topic):
        """Collect information from diverse perspectives"""
        perspectives = self.generate_perspectives(topic)
        collected_info = []
        
        for perspective in perspectives:
            queries = self.generate_queries(topic, perspective)
            for query in queries:
                results = self.retriever.search(query)
                collected_info.extend(results)
        
        return self.deduplicate_and_filter(collected_info)
```

#### 2. Outline Generation Module

```python
# Hierarchical outline generation
class OutlineGenerationModule:
    def generate_outline(self, collected_info, topic):
        """Systematically organize collected information"""
        key_concepts = self.extract_key_concepts(collected_info)
        hierarchy = self.build_hierarchy(key_concepts)
        
        outline = {
            "title": topic,
            "sections": []
        }
        
        for section in hierarchy:
            outline["sections"].append({
                "title": section["title"],
                "subsections": section["subsections"],
                "key_points": section["key_points"]
            })
        
        return outline
```

#### 3. Article Generation Module

```python
# Write article based on the outline
class ArticleGenerationModule:
    def populate_outline(self, outline, knowledge_base):
        """Fill the outline with actual content"""
        article = {
            "title": outline["title"],
            "content": []
        }
        
        for section in outline["sections"]:
            section_content = self.write_section(
                section, 
                knowledge_base,
                citation_style="wikipedia"
            )
            article["content"].append(section_content)
        
        return article
```

#### 4. Article Polishing Module

```python
# Final article refinement
class ArticlePolishingModule:
    def polish_article(self, article):
        """Improve quality and consistency of the article"""
        polished = {
            "title": article["title"],
            "content": []
        }
        
        for section in article["content"]:
            # Unify style, remove duplicates, clean citations
            polished_section = self.improve_writing_quality(section)
            polished_section = self.verify_citations(polished_section)
            polished["content"].append(polished_section)
        
        return polished
```

## Installation and Usage

### 1. Installation

```bash
# Simple installation via pip
pip install knowledge-storm

# Or install from source
git clone https://github.com/stanford-oval/storm.git
cd storm
pip install -r requirements.txt
pip install -e .
```

### 2. API Key Setup

```toml
# Create secrets.toml file
# ============ language model configurations ============ 
OPENAI_API_KEY="your_openai_api_key"
OPENAI_API_TYPE="openai"

# For Azure OpenAI
OPENAI_API_TYPE="azure"
AZURE_API_BASE="your_azure_api_base_url"
AZURE_API_VERSION="your_azure_api_version"

# ============ retriever configurations ============ 
BING_SEARCH_API_KEY="your_bing_search_api_key"

# ============ encoder configurations ============ 
ENCODER_API_TYPE="openai"
```

### 3. Basic STORM Usage

```python
# Basic STORM usage example
from knowledge_storm import STORMWikiRunnerArguments, STORMWikiRunner
from knowledge_storm import STORMWikiLMConfigs

# Initialize configuration
lm_configs = STORMWikiLMConfigs()
runner_args = STORMWikiRunnerArguments(
    output_dir="./storm_output",
    max_conv_turn=5,
    max_perspective=5
)

# Run STORM
runner = STORMWikiRunner(lm_configs)

# Set topic and run
topic = "Artificial Intelligence in Healthcare"
runner.run(
    topic=topic,
    do_research=True,
    do_generate_outline=True,  
    do_generate_article=True,
    do_polish_article=True
)

# Check results
print(f"Generated article saved to: {runner_args.output_dir}")
```

### 4. Command Line Interface

```bash
# Fully automated run
python examples/storm_examples/run_storm_wiki_gpt.py \
    --output-dir ./results \
    --retriever bing \
    --do-research \
    --do-generate-outline \
    --do-generate-article \
    --do-polish-article

# Run only specific steps
python examples/storm_examples/run_storm_wiki_gpt.py \
    --output-dir ./results \
    --retriever bing \
    --do-research  # Research only
```

## Co-STORM: Collaborative AI System

### Co-STORM Overview

**Co-STORM** is an innovative system for human-AI collaborative knowledge curation:

- **Real-time dialogue**: Conversation between user and AI agents
- **Multiple experts**: Several AI experts collaborating
- **User participation**: Ability to intervene in the dialogue at any time
- **Dynamic adjustment**: Direction adjusted based on user feedback

### Co-STORM Usage

```python
# Initialize and run Co-STORM
from knowledge_storm import CoStormRunner

# Create Co-STORM runner
costorm_runner = CoStormRunner(
    args=costorm_args,
    lm_configs=lm_configs,
    rm=rm,
    conv_simulator_lm=conv_simulator_lm,
    topic=topic,
    callback_handler=StreamlitCallbackHandler()
)

# Start collaborative session
costorm_runner.warm_start()

# Progress step by step
conv_turn = costorm_runner.step()  # Observe AI agent dialogue
costorm_runner.step(user_utterance="User opinion added")  # User intervention

# Generate final report
costorm_runner.knowledge_base.reorganize()
article = costorm_runner.generate_report()
```

### Co-STORM Run Example

```bash
# Co-STORM run command
python examples/costorm_examples/run_costorm_gpt.py \
    --output-dir ./costorm_results \
    --retriever bing
```

## Advanced Customization

### 1. Custom Search Engine

```python
# Implement custom search system
from knowledge_storm.interface import Retriever

class CustomRetriever(Retriever):
    def __init__(self, custom_api_key):
        self.api_key = custom_api_key
    
    def retrieve(self, query, k=10):
        """Custom search logic"""
        # Integrate your search system
        results = self.search_custom_database(query)
        
        return [
            {
                "title": result["title"],
                "content": result["content"], 
                "url": result["url"]
            }
            for result in results[:k]
        ]
    
    def search_custom_database(self, query):
        # Custom database search implementation
        pass
```

### 2. Domain-Specific Modules

```python
# Medical domain-specific STORM
class MedicalSTORMRunner(STORMWikiRunner):
    def __init__(self, lm_configs):
        super().__init__(lm_configs)
        
        # Medical expert prompt configuration
        self.medical_prompts = {
            "research": "Research from a medical expert perspective...",
            "outline": "Structure in medical textbook style...",
            "article": "Write for easy understanding by medical staff..."
        }
    
    def customize_for_medical_domain(self):
        """Customization for the medical domain"""
        # Load medical glossary
        self.load_medical_terminology()
        
        # Set medical citation style
        self.set_medical_citation_style()
```

### 3. Multiple Output Formats

```python
# Support for multiple report formats
class MultiFormatSTORM(STORMWikiRunner):
    def generate_report(self, format_type="wikipedia"):
        """Generate reports in various formats"""
        base_content = super().generate_report()
        
        if format_type == "academic":
            return self.convert_to_academic_paper(base_content)
        elif format_type == "presentation":
            return self.convert_to_slides(base_content)
        elif format_type == "executive_summary":
            return self.create_executive_summary(base_content)
        else:
            return base_content
    
    def convert_to_academic_paper(self, content):
        """Convert to academic paper format"""
        return {
            "abstract": self.generate_abstract(content),
            "introduction": content["sections"][0],
            "literature_review": self.create_literature_review(content),
            "conclusion": content["sections"][-1],
            "references": content["citations"]
        }
```

## Production Deployment Guide

### 1. Docker Containerization

```dockerfile
# Dockerfile for STORM
FROM python:3.9-slim

# Install system packages
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Install STORM
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pip install knowledge-storm

# Application code
COPY . .

# Environment variables
ENV PYTHONPATH=/app
ENV STORM_OUTPUT_DIR=/app/outputs

# Service port
EXPOSE 8000

# Start service
CMD ["python", "storm_server.py"]
```

### 2. Web Service Implementation

```python
# FastAPI-based STORM service
from fastapi import FastAPI, BackgroundTasks
from pydantic import BaseModel
import asyncio

app = FastAPI(title="STORM API", version="1.0.0")

class ResearchRequest(BaseModel):
    topic: str
    max_conv_turn: int = 5
    max_perspective: int = 5
    output_format: str = "wikipedia"

class ResearchResponse(BaseModel):
    task_id: str
    status: str
    result_url: str = None

@app.post("/research", response_model=ResearchResponse)
async def create_research_task(
    request: ResearchRequest, 
    background_tasks: BackgroundTasks
):
    task_id = generate_task_id()
    
    # Run STORM in the background
    background_tasks.add_task(
        run_storm_research, 
        task_id, 
        request.topic,
        request.max_conv_turn,
        request.max_perspective
    )
    
    return ResearchResponse(
        task_id=task_id,
        status="processing"
    )

async def run_storm_research(task_id, topic, max_conv_turn, max_perspective):
    """Background STORM execution"""
    try:
        runner = STORMWikiRunner(lm_configs)
        result = runner.run(
            topic=topic,
            do_research=True,
            do_generate_outline=True,
            do_generate_article=True,
            do_polish_article=True
        )
        
        # Save result
        save_result(task_id, result)
        update_task_status(task_id, "completed")
        
    except Exception as e:
        update_task_status(task_id, "failed", str(e))

@app.get("/research/{task_id}")
async def get_research_result(task_id: str):
    """Retrieve research result"""
    status = get_task_status(task_id)
    
    if status["status"] == "completed":
        result = load_result(task_id)
        return {
            "task_id": task_id,
            "status": "completed",
            "result": result
        }
    else:
        return {
            "task_id": task_id,
            "status": status["status"],
            "message": status.get("message")
        }
```

### 3. Kubernetes Deployment

```yaml
# k8s-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storm-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: storm-api
  template:
    metadata:
      labels:
        app: storm-api
    spec:
      containers:
      - name: storm-api
        image: your-registry/storm-api:latest
        ports:
        - containerPort: 8000
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: storm-secrets
              key: openai-api-key
        - name: BING_SEARCH_API_KEY
          valueFrom:
            secretKeyRef:
              name: storm-secrets
              key: bing-api-key
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
        volumeMounts:
        - name: storm-storage
          mountPath: /app/outputs
      volumes:
      - name: storm-storage
        persistentVolumeClaim:
          claimName: storm-pvc
---
apiVersion: v1
kind: Service
metadata:
  name: storm-service
spec:
  selector:
    app: storm-api
  ports:
  - port: 80
    targetPort: 8000
  type: LoadBalancer
```

## Performance Optimization and Scaling

### 1. Parallel Processing Optimization

```python
# Performance improvement through parallel processing
import asyncio
from concurrent.futures import ThreadPoolExecutor

class OptimizedSTORMRunner:
    def __init__(self, max_workers=4):
        self.executor = ThreadPoolExecutor(max_workers=max_workers)
    
    async def parallel_research(self, topic, perspectives):
        """Multi-perspective parallel research"""
        tasks = []
        
        for perspective in perspectives:
            task = asyncio.create_task(
                self.research_perspective(topic, perspective)
            )
            tasks.append(task)
        
        results = await asyncio.gather(*tasks)
        return self.merge_research_results(results)
    
    async def research_perspective(self, topic, perspective):
        """Research from a specific perspective"""
        loop = asyncio.get_event_loop()
        return await loop.run_in_executor(
            self.executor,
            self.single_perspective_research,
            topic,
            perspective
        )
```

### 2. Caching System

```python
# Efficient caching implementation
from functools import lru_cache
import hashlib
import pickle

class STORMCache:
    def __init__(self, cache_dir="./storm_cache"):
        self.cache_dir = cache_dir
        os.makedirs(cache_dir, exist_ok=True)
    
    def get_cache_key(self, topic, parameters):
        """Generate cache key"""
        content = f"{topic}_{str(sorted(parameters.items()))}"
        return hashlib.md5(content.encode()).hexdigest()
    
    def get_cached_result(self, cache_key):
        """Look up cached result"""
        cache_file = os.path.join(self.cache_dir, f"{cache_key}.pkl")
        
        if os.path.exists(cache_file):
            with open(cache_file, 'rb') as f:
                return pickle.load(f)
        return None
    
    def save_to_cache(self, cache_key, result):
        """Save result to cache"""
        cache_file = os.path.join(self.cache_dir, f"{cache_key}.pkl")
        
        with open(cache_file, 'wb') as f:
            pickle.dump(result, f)

# Cached STORM runner
class CachedSTORMRunner(STORMWikiRunner):
    def __init__(self, lm_configs):
        super().__init__(lm_configs)
        self.cache = STORMCache()
    
    def run_with_cache(self, topic, **kwargs):
        cache_key = self.cache.get_cache_key(topic, kwargs)
        cached_result = self.cache.get_cached_result(cache_key)
        
        if cached_result:
            print(f"Using cached result for: {topic}")
            return cached_result
        
        result = self.run(topic=topic, **kwargs)
        self.cache.save_to_cache(cache_key, result)
        
        return result
```

## Datasets and Benchmarks

### FreshWiki Dataset

**FreshWiki** is a high-quality dataset for STORM evaluation:

- **Scale**: 100 high-quality Wikipedia articles
- **Period**: Most-edited pages from February 2022 to September 2023
- **Use**: Automated knowledge curation research

```python
# FreshWiki dataset utilization
from datasets import load_dataset

# Load dataset from Hugging Face
dataset = load_dataset("stanford-oval/FreshWiki")

# Use evaluation data
for item in dataset["train"]:
    topic = item["title"]
    reference_article = item["content"]
    
    # Generate article with STORM
    generated_article = storm_runner.run(topic=topic)
    
    # Quality evaluation
    score = evaluate_quality(generated_article, reference_article)
    print(f"Topic: {topic}, Quality Score: {score}")
```

### WildSeek Dataset

**WildSeek** is a dataset containing complex information-seeking patterns from real users:

```python
# Evaluate Co-STORM with WildSeek dataset
wildseek_data = load_dataset("stanford-oval/WildSeek")

for item in wildseek_data["train"]:
    topic = item["topic"]
    user_goal = item["user_goal"]
    
    # Simulate collaborative session with Co-STORM
    costorm_runner = CoStormRunner(topic=topic)
    costorm_runner.set_user_goal(user_goal)
    
    result = costorm_runner.collaborative_research()
    print(f"Topic: {topic}")
    print(f"User Goal: {user_goal}")
    print(f"Result Quality: {evaluate_result(result)}")
```

## Comparative Analysis: STORM vs Existing Systems

### Feature Comparison

| Feature | STORM | ChatGPT | Claude | Perplexity |
|------|-------|---------|---------|------------|
| Automated research | Yes | No | No | Yes |
| Structured outline | Yes | No | No | No |
| Citation system | Yes | No | No | Yes |
| Multiple perspectives | Yes | No | No | No |
| Collaborative mode | Yes | No | No | No |
| Customization | Yes | No | No | No |

### Performance Benchmark

```python
# Performance comparison experiment
def benchmark_systems():
    topics = [
        "Quantum Computing Applications",
        "Climate Change Mitigation Strategies", 
        "Artificial Intelligence Ethics"
    ]
    
    results = {
        "STORM": [],
        "ChatGPT": [],
        "Claude": [],
        "Perplexity": []
    }
    
    for topic in topics:
        # Evaluate STORM
        storm_result = storm_runner.run(topic=topic)
        storm_score = evaluate_comprehensive_quality(storm_result, topic)
        results["STORM"].append(storm_score)
        
        # Compare with other systems...
    
    return results

# Evaluation metrics
def evaluate_comprehensive_quality(result, topic):
    """Comprehensive quality evaluation"""
    metrics = {
        "factual_accuracy": evaluate_factual_accuracy(result),
        "completeness": evaluate_completeness(result, topic),
        "citation_quality": evaluate_citations(result),
        "structure_quality": evaluate_structure(result),
        "readability": evaluate_readability(result)
    }
    
    return sum(metrics.values()) / len(metrics)
```

## Real-World Use Cases

### 1. Education

```python
# Generate educational materials
class EducationalSTORM(STORMWikiRunner):
    def generate_course_material(self, topic, education_level="university"):
        """Generate learning materials appropriate for the education level"""
        
        # Customize by education level
        if education_level == "high_school":
            complexity_level = "basic"
            citation_style = "simplified"
        elif education_level == "university":
            complexity_level = "intermediate"
            citation_style = "academic"
        else:
            complexity_level = "advanced"
            citation_style = "scholarly"
        
        result = self.run(
            topic=topic,
            complexity_level=complexity_level,
            citation_style=citation_style
        )
        
        # Add learning objectives and quiz
        result["learning_objectives"] = self.generate_learning_objectives(result)
        result["quiz_questions"] = self.generate_quiz(result)
        
        return result

# Usage example
edu_storm = EducationalSTORM(lm_configs)
course_material = edu_storm.generate_course_material(
    topic="Machine Learning Fundamentals",
    education_level="university"
)
```

### 2. Corporate Research

```python
# Market analysis report for enterprise use
class BusinessSTORM(STORMWikiRunner):
    def generate_market_analysis(self, company_or_industry):
        """Generate market analysis report"""
        
        # Set business perspectives
        business_perspectives = [
            "Market Size and Growth",
            "Competitive Landscape",
            "Consumer Trends",
            "Regulatory Environment",
            "Technology Disruption",
            "Investment Opportunities"
        ]
        
        result = self.run(
            topic=company_or_industry,
            perspectives=business_perspectives,
            citation_style="business"
        )
        
        # Add business insights
        result["executive_summary"] = self.generate_executive_summary(result)
        result["swot_analysis"] = self.generate_swot_analysis(result)
        result["recommendations"] = self.generate_recommendations(result)
        
        return result

# Usage example
business_storm = BusinessSTORM(lm_configs)
market_report = business_storm.generate_market_analysis("Electric Vehicle Industry")
```

### 3. Journalism

```python
# In-depth research for investigative reporting
class JournalismSTORM(STORMWikiRunner):
    def investigative_research(self, topic):
        """In-depth research for investigative reporting"""
        
        journalism_perspectives = [
            "Who (Key Players)",
            "What (Core Facts)",
            "When (Timeline)",
            "Where (Geographic Context)",
            "Why (Motivations and Causes)",
            "How (Mechanisms and Processes)"
        ]
        
        result = self.run(
            topic=topic,
            perspectives=journalism_perspectives,
            fact_checking=True,
            source_verification=True
        )
        
        # Add journalism elements
        result["fact_check_report"] = self.generate_fact_check(result)
        result["source_credibility"] = self.assess_source_credibility(result)
        result["follow_up_questions"] = self.generate_follow_up_questions(result)
        
        return result
```

## Conclusion

**Stanford STORM** is an innovative system that presents a new paradigm for knowledge curation.

### Key Advantages

1. **Systematic approach**: 4-stage modular pipeline
2. **Multiple perspectives**: Information gathering from various expert viewpoints
3. **Citation system**: Source attribution for all content
4. **Collaborative features**: Human-AI collaboration through Co-STORM
5. **Customization**: Applicable to various domains
6. **Open source**: Free use under MIT license

### Recommended Use Cases

- **Researchers**: Literature review and systematic review writing
- **Educators**: Educational materials and lecture note generation
- **Enterprises**: Market analysis and competitor research
- **Journalists**: Investigative reporting and fact-checking
- **Students**: Research for assignments and projects

**STORM** and **Co-STORM** have the potential to fundamentally change the way knowledge work is done, going beyond mere tools. As the 25.4k GitHub stars attest, many users have already recognized their value.

Try incorporating STORM into your knowledge curation workflow!

---

**Reference links**:
- [STORM GitHub Repository](https://github.com/stanford-oval/storm)
- [STORM Official Website](https://storm.genie.stanford.edu)
- [NAACL 2024 Paper](https://aclanthology.org/2024.naacl-long.347/)
- [EMNLP 2024 Co-STORM Paper](https://aclanthology.org/2024.emnlp-main.554/)
- [FreshWiki Dataset](https://huggingface.co/datasets/stanford-oval/FreshWiki)
- [WildSeek Dataset](https://huggingface.co/datasets/stanford-oval/WildSeek)
