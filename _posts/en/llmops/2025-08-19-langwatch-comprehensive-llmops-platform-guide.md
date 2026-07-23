---
title: "LangWatch: Building an AI Operations Framework with an Open-Source LLMOps Platform"
excerpt: "A comprehensive LLMOps guide covering LLM tracing, evaluation, dataset management, and prompt optimization with LangWatch, integrated with RunPod and vLLM"
seo_title: "LangWatch LLMOps Platform Complete Guide - Building AI Operations - Thaki Cloud"
seo_description: "How to implement LLM observability, evaluation, dataset management, and prompt optimization with open-source LangWatch, and build a comprehensive LLMOps environment integrated with RunPod and vLLM"
date: 2025-08-19
last_modified_at: 2025-08-19
tags:
  - LangWatch
  - LLMOps
  - OpenTelemetry
  - LLM모니터링
  - AI플랫폼
  - RunPod
  - vLLM
  - 프롬프트최적화
  - 관찰성
  - 평가시스템
author_profile: true
toc: true
toc_label: "Table of Contents"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/langwatch-comprehensive-llmops-platform-guide/"
lang: en
reading_time: true
published: false
categories:
  - llmops
  - tutorials
---

⏱️ **Estimated reading time**: 12 min

## Introduction

Running LLM (Large Language Model) applications reliably in production requires systematic observability, evaluation, and optimization. [LangWatch](https://github.com/langwatch/langwatch) is an open-source platform that meets these LLMOps requirements. Built on the OpenTelemetry standard, it enables management of the full lifecycle of LLM applications.

### Core Value of LangWatch

**Limitations of conventional monitoring tools**:
- General-purpose APM tools lack LLM-specific metrics
- Tracking prompt quality and response accuracy is difficult
- Cost optimization and performance analysis are complex

**What LangWatch provides**:
- Observability and tracing designed specifically for LLMs
- Real-time and offline evaluation frameworks
- Prompt version control and optimization tools
- Native integration with various LLM frameworks

## LangWatch Core Feature Analysis

### 1. Observability

LangWatch tracks every interaction in an LLM application using the OpenTelemetry standard.

**Key tracing elements**:
- **Request/Response tracing**: Full flow of input prompts and model responses
- **Latency analysis**: Token generation speed and time to first token (TTFT)
- **Cost tracking**: Token usage and cost calculation per API call
- **Error monitoring**: Analysis of failed requests and exception cases

```python
import langwatch
from openai import OpenAI

client = OpenAI()

@langwatch.trace()
def chat_completion(messages):
    """OpenAI API call tracked by LangWatch"""
    langwatch.get_current_trace().autotrack_openai_calls(client)
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=messages,
        temperature=0.7
    )
    
    return response.choices[0].message.content
```

### 2. Evaluation System

**Real-time evaluation**:
- Real-time monitoring of response quality in production
- Combination of user feedback and automated evaluation metrics
- Early detection of performance degradation

**Offline evaluation**:
- Batch evaluation using datasets
- Model performance comparison through A/B testing
- Impact analysis of prompt changes

**Evaluation metrics**:
- **Relevance**: The degree of connection between question and answer
- **Accuracy**: Fact-checking and information correctness
- **Consistency**: Uniformity of responses to identical questions
- **Safety**: Harmful content detection and filtering

### 3. Dataset Management

**Automatic dataset creation**:
- Automatic dataset construction from traced messages
- Analysis of user interaction patterns
- Extraction of test cases based on real usage

**Manual dataset upload**:
- Upload custom datasets for evaluation
- Management of domain-specific test cases
- Construction of golden datasets for continuous evaluation

### 4. Prompt Optimization

**Version control**:
- Tracking prompt changes
- Performance impact analysis
- Support for rollback and A/B testing

**Automatic optimization**:
- Uses the MIPROv2 algorithm from DSPy
- Automatic generation of few-shot examples
- Optimization of prompt templates

```python
# Prompt version control example
from langwatch import prompt_manager

# Register a prompt version
prompt_v1 = prompt_manager.create_prompt(
    name="customer_support",
    version="1.0",
    template="You are a customer support agent. Question: {question}",
    parameters=["question"]
)

# Test new version alongside performance evaluation
prompt_v2 = prompt_manager.test_prompt(
    base_prompt=prompt_v1,
    modifications={"add_examples": True, "tone": "friendly"},
    evaluation_dataset="customer_queries_100"
)
```

## Integration with AI Platforms

### Integration with RunPod

RunPod is a GPU cloud infrastructure platform. Used together with LangWatch, it enables a powerful LLMOps environment.

**Integration architecture**:

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
<div class="d3-arch" data-arch-root id="nsivellmopsplatformguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1112, "height": 598, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 578, "y": 24, "w": 156, "h": 46, "title": "Client Application"}, {"id": "B", "x": 595, "y": 148, "w": 121, "h": 46, "title": "LangWatch SDK"}, {"id": "C", "x": 910, "y": 272, "w": 163, "h": 46, "title": "RunPod GPU Instance"}, {"id": "D", "x": 903, "y": 396, "w": 177, "h": 46, "title": "vLLM Inference Server"}, {"id": "E", "x": 932, "y": 520, "w": 120, "h": 46, "title": "LLM Model"}, {"id": "F", "x": 346, "y": 272, "w": 156, "h": 46, "title": "LangWatch Platform"}, {"id": "G", "x": 657, "y": 396, "w": 191, "h": 46, "title": "Observability Dashboard"}, {"id": "H", "x": 453, "y": 396, "w": 149, "h": 46, "title": "Evaluation System"}, {"id": "I", "x": 242, "y": 396, "w": 156, "h": 46, "title": "Dataset Management"}, {"id": "J", "x": 24, "y": 396, "w": 163, "h": 46, "title": "Prompt Optimization"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [656, 70, 656, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[716, 182], [992, 233], [992, 233], [992, 272]]}, {"src": "C", "dst": "D", "kind": "data", "line": [992, 318, 992, 396]}, {"src": "D", "dst": "E", "kind": "data", "line": [992, 442, 992, 520]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[595, 187], [424, 233], [424, 233], [424, 272]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[502, 310], [753, 357], [753, 357], [753, 396]]}, {"src": "F", "dst": "H", "kind": "data", "curve": [[462, 318], [528, 357], [528, 357], [528, 396]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[385, 318], [320, 357], [320, 357], [320, 396]]}, {"src": "F", "dst": "J", "kind": "data", "curve": [[346, 310], [106, 357], [106, 357], [106, 396]]}]});
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
      const container = document.getElementById('nsivellmopsplatformguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nsivellmopsplatformguide-1';
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

**RunPod + LangWatch setup**:

```python
# Running a vLLM server on RunPod
import requests
import langwatch

# RunPod endpoint configuration
RUNPOD_ENDPOINT = "https://api.runpod.ai/v2/your-endpoint-id"
RUNPOD_API_KEY = "your-runpod-api-key"

@langwatch.trace()
def call_runpod_llm(prompt, model="meta-llama/Llama-2-7b-chat-hf"):
    """Call an LLM hosted on RunPod"""
    
    headers = {
        "Authorization": f"Bearer {RUNPOD_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "input": {
            "prompt": prompt,
            "model": model,
            "max_tokens": 512,
            "temperature": 0.7
        }
    }
    
    # Track the request in LangWatch
    with langwatch.trace_span("runpod_inference") as span:
        span.set_attribute("model", model)
        span.set_attribute("prompt_length", len(prompt))
        
        response = requests.post(
            f"{RUNPOD_ENDPOINT}/run",
            headers=headers,
            json=payload
        )
        
        result = response.json()
        
        # Record response metrics
        span.set_attribute("response_length", len(result.get("output", "")))
        span.set_attribute("inference_time", result.get("execution_time", 0))
        
        return result["output"]
```

### Optimization Integration with vLLM

vLLM is an LLM inference library that provides high throughput and efficient memory usage.

**vLLM + LangWatch integration**:

```python
from vllm import LLM, SamplingParams
import langwatch

class OptimizedLLMService:
    def __init__(self, model_name="meta-llama/Llama-2-7b-chat-hf"):
        self.llm = LLM(
            model=model_name,
            tensor_parallel_size=2,  # GPU parallel processing
            max_model_len=4096,
            trust_remote_code=True
        )
        
        self.sampling_params = SamplingParams(
            temperature=0.7,
            top_p=0.95,
            max_tokens=512
        )
    
    @langwatch.trace()
    def generate(self, prompts, batch_size=8):
        """Batch-optimized generation"""
        
        with langwatch.trace_span("vllm_batch_inference") as span:
            span.set_attribute("batch_size", len(prompts))
            span.set_attribute("model", self.llm.llm_engine.model_config.model)
            
            # vLLM batch inference
            outputs = self.llm.generate(prompts, self.sampling_params)
            
            # Calculate throughput metrics
            total_tokens = sum(len(output.outputs[0].token_ids) for output in outputs)
            span.set_attribute("total_output_tokens", total_tokens)
            span.set_attribute("throughput_tokens_per_second", 
                             total_tokens / span.duration if span.duration > 0 else 0)
            
            return [output.outputs[0].text for output in outputs]

# Usage example
llm_service = OptimizedLLMService()

prompts = [
    "Explain the future of AI.",
    "What are solutions to climate change?",
    "Briefly explain the principles of quantum computing."
]

responses = llm_service.generate(prompts)
```

### TensorRT-LLM Acceleration

NVIDIA TensorRT-LLM can be used to maximize inference performance.

```python
import tensorrt_llm
import langwatch

class TensorRTLLMService:
    def __init__(self, engine_path):
        self.engine = tensorrt_llm.LLMEngine(engine_path)
        
    @langwatch.trace()
    def optimized_inference(self, prompt):
        """TensorRT-optimized inference"""
        
        with langwatch.trace_span("tensorrt_inference") as span:
            # Collect inference performance metrics
            start_time = time.time()
            
            result = self.engine.generate(
                prompt,
                max_new_tokens=512,
                temperature=0.7
            )
            
            inference_time = time.time() - start_time
            
            # Record performance data in LangWatch
            span.set_attribute("inference_time_ms", inference_time * 1000)
            span.set_attribute("tokens_per_second", 
                             len(result.split()) / inference_time)
            
            return result
```

## Practical LLMOps Workflow

### 1. Development Stage

```python
# LangWatch configuration in the development environment
import langwatch

# Development mode configuration
langwatch.init(
    api_key="your-dev-api-key",
    endpoint="http://localhost:5560",  # Local LangWatch instance
    environment="development"
)

@langwatch.trace()
def prototype_chatbot(user_input):
    """Prototype chatbot function"""
    
    # Testing a prompt template
    system_prompt = """You are a helpful AI assistant.
    Please answer user questions accurately and kindly."""
    
    response = call_llm(system_prompt, user_input)
    
    # Immediate evaluation during development
    evaluation_score = langwatch.evaluate_response(
        prompt=user_input,
        response=response,
        criteria=["relevance", "helpfulness", "safety"]
    )
    
    return response, evaluation_score
```

### 2. Staging Stage

```python
# Automatic evaluation configuration in the staging environment
@langwatch.trace()
def staging_deployment():
    """Comprehensive testing in the staging environment"""
    
    # Load test dataset
    test_dataset = langwatch.load_dataset("customer_support_test_100")
    
    results = []
    for test_case in test_dataset:
        response = production_chatbot(test_case.input)
        
        # Run automatic evaluation
        evaluation = langwatch.auto_evaluate(
            input=test_case.input,
            output=response,
            expected=test_case.expected,
            metrics=["accuracy", "relevance", "safety"]
        )
        
        results.append({
            "input": test_case.input,
            "output": response,
            "scores": evaluation.scores,
            "passed": evaluation.overall_score > 0.8
        })
    
    # Staging results report
    langwatch.create_evaluation_report(
        results=results,
        environment="staging",
        deployment_version="v1.2.0"
    )
    
    return results
```

### 3. Production Stage

```python
# Real-time monitoring in the production environment
@langwatch.trace()
def production_chatbot(user_input, user_id=None):
    """Production chatbot with real-time monitoring"""
    
    with langwatch.trace_span("production_inference") as span:
        # Add user context
        span.set_attribute("user_id", user_id)
        span.set_attribute("input_length", len(user_input))
        
        # Safety pre-check
        safety_check = langwatch.safety_filter(user_input)
        if not safety_check.is_safe:
            span.set_attribute("safety_blocked", True)
            return "Sorry. We cannot process this request."
        
        # LLM inference
        response = optimized_llm_call(user_input)
        
        # Real-time quality evaluation
        quality_score = langwatch.real_time_evaluate(
            input=user_input,
            output=response,
            metrics=["relevance", "coherence"]
        )
        
        span.set_attribute("quality_score", quality_score.overall)
        span.set_attribute("response_length", len(response))
        
        # Alert on detection of low-quality responses
        if quality_score.overall < 0.7:
            langwatch.alert(
                type="low_quality_response",
                severity="warning",
                details={
                    "user_id": user_id,
                    "score": quality_score.overall,
                    "input": user_input[:100] + "..."
                }
            )
        
        return response

# Production metrics dashboard configuration
langwatch.setup_dashboard(
    metrics=[
        "requests_per_minute",
        "average_response_time",
        "quality_score_distribution",
        "error_rate",
        "cost_per_token"
    ],
    alerts=[
        {"metric": "error_rate", "threshold": 0.05, "action": "email"},
        {"metric": "avg_quality_score", "threshold": 0.8, "action": "slack"},
        {"metric": "cost_per_hour", "threshold": 100, "action": "email"}
    ]
)
```

## Setting Up a Local Development Environment on macOS

### Docker Compose Configuration

Let us run LangWatch locally to build a development environment.

```bash
# Clone and run LangWatch
git clone https://github.com/langwatch/langwatch.git
cd langwatch

# Copy environment configuration file
cp langwatch/.env.example langwatch/.env

# Run with Docker Compose (for ARM Mac)
docker compose -f compose.yml -f docker-compose.arm64.override.yml up -d --wait --build

# Open in browser
open http://localhost:5560
```

### Development Environment SDK Setup

```bash
# Create Python virtual environment
python3 -m venv langwatch-dev
source langwatch-dev/bin/activate

# Install LangWatch SDK
pip install langwatch

# Install development dependencies
pip install openai python-dotenv jupyter
```

### Environment Variable Configuration

```bash
# Add to ~/.zshrc
export LANGWATCH_API_KEY="lw-your-local-dev-key"
export LANGWATCH_ENDPOINT="http://localhost:5560"
export OPENAI_API_KEY="your-openai-api-key"

# Add aliases
alias langwatch-local="docker compose -f ~/langwatch/compose.yml up -d"
alias langwatch-stop="docker compose -f ~/langwatch/compose.yml down"
alias langwatch-logs="docker compose -f ~/langwatch/compose.yml logs -f"

# Apply changes
source ~/.zshrc
```

### Writing a Test Script

```python
# test_langwatch_integration.py
import os
import langwatch
from openai import OpenAI

# Initialize LangWatch
langwatch.init(
    api_key=os.getenv("LANGWATCH_API_KEY"),
    endpoint=os.getenv("LANGWATCH_ENDPOINT")
)

client = OpenAI()

@langwatch.trace()
def test_basic_integration():
    """Basic integration test"""
    
    # Configure automatic OpenAI tracking
    langwatch.get_current_trace().autotrack_openai_calls(client)
    
    # Test request
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "You are a helpful AI assistant."},
            {"role": "user", "content": "List three advantages of Python."}
        ],
        temperature=0.7,
        max_tokens=200
    )
    
    result = response.choices[0].message.content
    print(f"Response: {result}")
    
    # Run evaluation
    evaluation = langwatch.evaluate_response(
        prompt="List three advantages of Python.",
        response=result,
        criteria=["relevance", "accuracy", "completeness"]
    )
    
    print(f"Evaluation score: {evaluation}")
    
    return result, evaluation

if __name__ == "__main__":
    result, evaluation = test_basic_integration()
    print("\n LangWatch integration test complete!")
    print(f"LangWatch dashboard: http://localhost:5560")
```

### Running and Verifying

```bash
# Run test
python test_langwatch_integration.py

# View results in browser
open http://localhost:5560

# Check logs
langwatch-logs
```

## Advanced Use Cases

### 1. Multi-Model A/B Testing

```python
import random
import langwatch

@langwatch.trace()
def multi_model_ab_test(user_input):
    """Test multiple models simultaneously"""
    
    models = [
        {"name": "gpt-4", "weight": 0.3},
        {"name": "gpt-3.5-turbo", "weight": 0.5},
        {"name": "claude-3-sonnet", "weight": 0.2}
    ]
    
    # Select model based on weights
    selected_model = random.choices(
        models, 
        weights=[m["weight"] for m in models]
    )[0]
    
    with langwatch.trace_span("model_selection") as span:
        span.set_attribute("selected_model", selected_model["name"])
        span.set_attribute("selection_weight", selected_model["weight"])
        
        response = call_model(selected_model["name"], user_input)
        
        # Collect per-model performance metrics
        langwatch.record_metric(
            name=f"response_quality_{selected_model['name']}",
            value=evaluate_response_quality(response),
            tags={"model": selected_model["name"]}
        )
        
        return response
```

### 2. Automatic Prompt Optimization

```python
from langwatch.optimization import DSPyOptimizer

class AutoPromptOptimizer:
    def __init__(self):
        self.optimizer = DSPyOptimizer()
        
    def optimize_prompt(self, base_prompt, training_data, metrics):
        """Automatic prompt optimization"""
        
        optimization_run = langwatch.start_optimization(
            name="customer_support_prompt_v2",
            base_prompt=base_prompt,
            training_data=training_data
        )
        
        # Optimization using DSPy MIPROv2
        optimized_prompt = self.optimizer.optimize(
            prompt_template=base_prompt,
            training_examples=training_data,
            eval_metrics=metrics,
            iterations=50
        )
        
        # Evaluate optimization results
        evaluation_results = langwatch.evaluate_prompt(
            original_prompt=base_prompt,
            optimized_prompt=optimized_prompt,
            test_dataset=training_data,
            metrics=metrics
        )
        
        langwatch.complete_optimization(
            run_id=optimization_run.id,
            results=evaluation_results,
            optimized_prompt=optimized_prompt
        )
        
        return optimized_prompt, evaluation_results

# Usage example
optimizer = AutoPromptOptimizer()

base_prompt = """You are a customer support agent.
Please respond to customer inquiries kindly and accurately.

Customer inquiry: {question}
Response:"""

training_data = [
    {"question": "What is the refund policy?", "expected": "Full refund within 14 days..."},
    {"question": "How long does shipping take?", "expected": "Standard shipping is 2-3 days..."},
    # ... more examples
]

optimized_prompt, results = optimizer.optimize_prompt(
    base_prompt=base_prompt,
    training_data=training_data,
    metrics=["accuracy", "helpfulness", "response_time"]
)
```

### 3. Cost Optimization Monitoring

```python
class CostOptimizedLLMService:
    def __init__(self):
        self.cost_thresholds = {
            "hourly": 50,    # $50/hour
            "daily": 500,    # $500/day
            "monthly": 10000 # $10,000/month
        }
        
    @langwatch.trace()
    def cost_aware_inference(self, prompt, priority="normal"):
        """Inference execution with cost awareness"""
        
        # Check current cost usage
        current_costs = langwatch.get_cost_metrics()
        
        with langwatch.trace_span("cost_check") as span:
            span.set_attribute("hourly_cost", current_costs.hourly)
            span.set_attribute("daily_cost", current_costs.daily)
            span.set_attribute("priority", priority)
            
            # Check cost thresholds
            if current_costs.hourly > self.cost_thresholds["hourly"]:
                if priority == "low":
                    span.set_attribute("cost_limited", True)
                    return "Service is temporarily limited."
                elif priority == "normal":
                    # Fall back to a cheaper model
                    model = "gpt-3.5-turbo"  # instead of gpt-4
                else:
                    model = "gpt-4"  # high priority uses high-performance model
            else:
                model = "gpt-4"
            
            span.set_attribute("selected_model", model)
            
            response = call_model(model, prompt)
            
            # Calculate cost of this request
            estimated_cost = estimate_request_cost(prompt, response, model)
            span.set_attribute("request_cost", estimated_cost)
            
            # Check cost alerts
            if current_costs.daily + estimated_cost > self.cost_thresholds["daily"]:
                langwatch.alert(
                    type="cost_threshold_approached",
                    severity="warning",
                    details={"daily_cost": current_costs.daily + estimated_cost}
                )
            
            return response
```

## Conclusion

LangWatch is a comprehensive platform that meets modern LLMOps requirements. Through features such as OpenTelemetry-based observability, real-time and offline evaluation systems, and automated prompt optimization, it enables effective management of the full lifecycle of LLM applications.

### Summary of Key Advantages

1. **Standardized observability**: Compatible with various LLM frameworks through OpenTelemetry
2. **Comprehensive evaluation**: Combination of real-time monitoring and offline evaluation
3. **Automated optimization**: Automatic prompt optimization using DSPy MIPROv2
4. **Cost efficiency**: Detailed cost tracking and optimization features
5. **Extensibility**: Integration with various infrastructures such as RunPod and vLLM

### Recommended Next Steps

1. **Set up local environment**: Configure the development environment with Docker Compose
2. **Phased adoption**: Apply in the order of development, staging, then production
3. **Define metrics**: Set evaluation indicators aligned with business objectives
4. **Build automation**: Integrate the evaluation process into CI/CD pipelines
5. **Team collaboration**: Build a collaboration process between domain experts and the development team

An LLMOps framework built with LangWatch significantly improves the quality and stability of AI applications, enabling continuous improvement and optimization. Combined with modern AI infrastructure such as RunPod and vLLM, it enables an even more powerful and efficient LLM operations environment.
