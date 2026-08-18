---
title: "How to stop an LLM from inventing statutes: grounding legal answers on Korea's National Law Open API"
excerpt: "Ask ChatGPT or Claude about the law and you sometimes get a plausible but fabricated statute. The problem is not the model's intelligence but a design that never binds the answer to verified source text. We walk through how to turn LLM legal answers into citation-grounded output using Korea's National Law Information Open API, from a serving perspective."
date: 2026-07-22
tags:
  - RAG
  - grounded-generation
  - legal-AI
  - LLM-hallucination
  - citations
  - national-law-data
  - LLMOps
  - on-prem
  - self-hosting
  - Paxis
author_profile: true
toc: true
toc_label: Grounding legal LLMs
published: true
lang: en
categories:
  - llmops
canonical_url: "https://thakicloud.github.io/en/llmops/llm-legal-grounding-korean-law-api/"
---

![A grounding pipeline that binds answers to verified source text](/assets/images/llm-legal-grounding-korean-law-api-hero.webp)

## Why read this

This is written for engineers who want to wire an LLM to legal or regulatory questions, and for infrastructure owners who have to answer for answer quality in high-stakes domains. The conclusion first: when an LLM invents statutes in a legal query, you do not fix it by swapping in a bigger model. You fix it with a grounded (RAG) design that binds the answer to verified statute text. Connect Korea's National Law Information Open API as the source of record, and the model cites real article numbers and effective dates instead of making them up.

## Overview

A tip made the rounds on social timelines: if you want legal help from ChatGPT or Claude but worry it will fabricate statutes, feed it domestic legal data. The worry is well founded. In the United States, a lawsuit was filed against OpenAI for allowing ChatGPT to provide legal advice without a licensed professional involved, and experts warn that simply discussing legal matters with a chatbot can be risky. The model is optimized to complete text plausibly, and it cannot, on its own, stop itself from writing a nonexistent provision as if it were real.

Yet the same market sends the opposite signal too. In South Korea, Claude overtook ChatGPT in the paid generative AI market for the first time, and the legal startup Law&Company reported that its Claude-powered AI legal assistant, SuperLawyer, reached 6,000 lawyers, about 20% of the country's practicing lawyers, within 180 days of launch. When the same technology is called dangerous by one side and landed in daily practice by the other, the difference is not the model but the design that handles the answer. This post takes that design apart, the grounded pipeline that binds an LLM's legal answer to verified source text, using the National Law Open API as the example.

## What this technique is

The core idea is simple. Instead of asking the model "do you know what the law says," you tell it to "first retrieve the relevant provisions, then answer using only that source text." Retrieval supplies the raw material for the answer, generation happens only within that material, and every claim carries a citation in the form of an article number and effective date. The blanks the model used to fill with imagination get replaced by verified text.

Here the trustworthiness of the material decides everything. A statute summary scraped from any web page might be a pre-amendment provision or of unknown origin. So the source of record must be the authoritative original. Korea's National Law Information Open API provides current statute text, article numbers, effective dates, revision history, and the responsible agency in structured form. It even lets you query the statutes that were in force on a given date, so you can cite "the provision valid now" separately from "the provision valid then." In legal queries, distinguishing the effective date is not a minor detail; it is the axis that separates a correct answer from a wrong one.

The full flow, laid out vertically:

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
<div class="d3-arch" data-arch-root id="galgroundingkoreanlawapi-1"></div>
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 378, "height": 1192, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q", "x": 70, "y": 24, "w": 170, "h": 78, "title": ["User question", "e.g. cap on contract", "termination penalty"]}, {"id": "R", "x": 73, "y": 180, "w": 163, "h": 78, "title": ["Query normalization", "issue and keyword", "extraction"]}, {"id": "S", "x": 52, "y": 336, "w": 205, "h": 62, "title": ["National Law Open API", "relevant provision search"]}, {"id": "F", "x": 145, "y": 476, "w": 198, "h": 78, "title": ["Filter", "check effective date and", "current status"]}, {"id": "C", "x": 145, "y": 632, "w": 198, "h": 78, "title": ["Context assembly", "provision text + article", "number + effective date"]}, {"id": "G", "x": 141, "y": 788, "w": 205, "h": 78, "title": ["LLM generation", "answer only from provided", "provisions"]}, {"id": "V", "x": 49, "y": 944, "w": 212, "h": 78, "title": ["Citation verification gate", "every claim maps to a", "provision"]}, {"id": "A", "x": 49, "y": 1114, "w": 212, "h": 46, "title": "Answer + article citations"}], "edges": [{"src": "Q", "dst": "R", "kind": "data", "line": [155, 102, 155, 180]}, {"src": "R", "dst": "S", "kind": "data", "line": [155, 258, 155, 336]}, {"src": "S", "dst": "F", "kind": "data", "curve": [[194, 398], [244, 437], [244, 437], [244, 476]]}, {"src": "F", "dst": "C", "kind": "data", "line": [244, 554, 244, 632]}, {"src": "C", "dst": "G", "kind": "data", "line": [244, 710, 244, 788]}, {"src": "G", "dst": "V", "kind": "data", "curve": [[244, 866], [244, 905], [244, 905], [199, 944]]}, {"src": "V", "dst": "S", "kind": "data", "label": "mapping fails", "curve": [[110, 944], [66, 749], [66, 515], [115, 398]], "off": "50%"}, {"src": "V", "dst": "A", "kind": "data", "label": "mapping succeeds", "line": [155, 1022, 155, 1114], "lx": 155, "ly": 1064}]});
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
      const container = document.getElementById('galgroundingkoreanlawapi-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'galgroundingkoreanlawapi-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

The difference from a plain approach is the verification gate. Simple RAG stops at pasting retrieved documents into the prompt and taking the answer. In a high-stakes domain you add one more step. Code checks whether every legal claim in the generated answer maps to a provision that was actually retrieved, and if even one claim fails to map, that answer is never sent to the user. This gate is the last line that filters out sentences the model invented outside its evidence.

## Setup and integration

The first step in attaching the source of record is issuing an API key. You register at the National Law Information portal (open.law.go.kr) and receive an authentication key. Provision search and full-text lookup then happen over URL-based calls, and the official guide provides examples in several languages, including Python and Node.js.

Below is a minimal pattern that searches current statutes by an issue keyword and assembles only that source text as context. Treat the portal's usage guide as the reference for the actual response schema and parameters.

```python
import requests

LAW_API = "https://www.law.go.kr/DRF/lawSearch.do"

def search_statutes(keyword: str, oc_key: str) -> list[dict]:
    """Search current statutes via the National Law Open API. Return provisions as the source of record."""
    params = {
        "OC": oc_key,          # issued authentication key
        "target": "law",       # statute search
        "type": "JSON",
        "query": keyword,
        "display": 5,
    }
    resp = requests.get(LAW_API, params=params, timeout=10)
    resp.raise_for_status()
    return resp.json().get("LawSearch", {}).get("law", [])

def build_context(hits: list[dict]) -> str:
    """Assemble retrieved provisions into citable context, carrying effective date and agency to make the basis explicit."""
    lines = []
    for h in hits:
        lines.append(
            f"[{h.get('법령명한글')}] "
            f"effective {h.get('시행일자')}, agency {h.get('소관부처명')}\n"
            f"{h.get('법령상세링크')}"
        )
    return "\n\n".join(lines)
```

When you load this context into the prompt, make the instruction explicit: "Answer only from the provisions provided below, do not cite provisions that were not provided, and if there is no relevant provision, say so." The instruction that makes the model say "there is none" when the basis is missing is the core of stopping hallucination. It makes the model leave the blank honestly rather than filling it in.

Finally, you own the verification gate in code. You extract the article numbers cited in the generated answer and compare them against the list of provisions actually loaded into the context. If it cites an article not in the list, that answer goes back into the retrieval loop. This judgment has to come from deterministic code, not the model's self-report, for it to be trustworthy.

## What grounded design changes

We did not run our own benchmark to produce new numbers. Instead, an already published operational metric shows the effect of grounded design. Law&Company's SuperLawyer runs on Claude but is designed to bind answers to case law and statutes, and according to the customer case Anthropic published, it reached 6,000 lawyers (about 20% of the country's practicing lawyers) within 180 days of launch, with a 60.2% free-to-paid conversion rate, a 79.1% second-month retention rate, and 2.3 million cumulative hours saved in the first 180 days. That a tool professionals verify every day sustains this kind of retention reads as a signal that the answers were not merely plausible but actually trustworthy.

On the other side is the cost of letting the law be answered without grounding. The OpenAI lawsuit in the United States and the warning not to discuss legal matters with a chatbot show that ungrounded legal answers can escalate into questions of legal liability. Even with the same model, binding it to source text or not splits the outcome this sharply. The lesson the metrics teach is clear: in a high-stakes domain, the lever that lifts quality is not model tier but grounding design.

## What this means for ThakiCloud's products

This pattern fits naturally into ThakiCloud's two products.

From the Paxis angle, grounded legal answering is a typical workload for an Agent-Native Cloud. Paxis treats Skills, Tools, Policies, and Audit Logs as first-class resources. Statute search is a Tool that runs in an isolated sandbox, the citation verification gate is a Policy that an answer must pass before it leaves, and which provisions grounded which answer is left in the Audit Log. In a domain where accountability matters, like law, you have to be able to trace after the fact why an answer came out the way it did, and policy gates plus audit logs provide that traceability by default. If you bundle the grounding gate that forces a citation on every claim into a reusable skill, you can carry it over as-is to other high-stakes domains that need source citations, such as medicine, finance, and regulatory compliance.

There is an ai-platform angle too. Data such as statutes and case law can be sensitive to send out over an external API at all, and public and regulatory bodies often demand data sovereignty and on-prem serving. ThakiCloud's ai-platform serves models multi-tenant on K8s and Kueue-based GPU scheduling, and is designed to operate the source of record and the model together on your own infrastructure. Keep the legal data in-house and run both retrieval and generation on top of it, and you preserve grounded accuracy and data sovereignty at once. Low serving cost is the precondition that lets you run such a domain-specific pipeline continuously.

## Limits and counterarguments

Grounded design is not a cure-all. First, if the source of record is not current, the answer is wrong too. Even if the National Law data reflects amendments immediately, an old snapshot cached by the pipeline can cite a repealed provision. Effective-date filters and regular synchronization have to back it up. Second, citing a provision accurately does not guarantee the interpretation is correct. The essence of legal advice is not statute search but application to the facts, and that judgment still belongs to a qualified professional. This pipeline should be seen as an aid that builds a draft on top of the evidence, not a replacement for the expert. Third, if the verification gate only checks citation mapping, it can pass an answer that cites the provision correctly but reasons wrongly. The gate holds the floor on hallucination; it does not guarantee the quality of the argument.

## Wrapping up

When an LLM produces fabricated statutes on a legal question, the problem is not the model's limit but a gap in the design. Bind the answer to verified source text, make it say "there is none" when there is no basis, and own in code a gate that forces a citation on every claim, and the same model delivers an entirely different level of trust. That is exactly where the gap lies between a Claude-powered legal tool landing in practice in Korea and an ungrounded chatbot consultation escalating into a lawsuit. The next move is clear. If you are attaching an LLM to a high-stakes domain, connect an authoritative source of record like the National Law Open API before you go looking for a bigger model, and stand up a citation verification gate first. The lever is always on the side of the evidence.

## Sources

- [National Law Information Open API portal](https://open.law.go.kr/LSO/openApi/guideList.do)
- [National Law Information sharing service (Public Data Portal)](https://www.data.go.kr/data/15000115/openapi.do)
- [Anthropic customer story: Law&Company](https://www.anthropic.com/customers/law-and-company)
- [KED Global: Claude overtakes ChatGPT in South Korea's paid generative AI market](https://www.kedglobal.com/artificial-intelligence/newsView/ked202604270002)
- [Forbes: Lawsuit against OpenAI over legal advice](https://www.forbes.com/sites/lanceeliot/2026/03/09/landmark-lawsuit-against-openai-for-allowing-chatgpt-to-provide-legal-advice-could-be-a-huge-game-changer-for-all-ai-makers/)
