---
title: "Buying More GPUs Won't Fix It: llm-d Distributed Inference and a Heterogeneous Architecture with GPUs and Any NPU/XPU"
excerpt: "llm-d is an inference scheduler that gets more requests through the same GPUs rather than buying more. We cover the principles of KV-cache aware routing and prefill/decode disaggregation, then show how any vLLM-compatible accelerator (NPUs like Rebellions and Furiosa, XPUs like Intel Gaudi and TPUs) can plug into the same accelerator-neutral heterogeneous orchestration layer."
seo_title: "llm-d Distributed Inference and GPU+NPU/XPU Heterogeneous Architecture"
seo_description: "How llm-d's KV-cache routing and prefill/decode disaggregation work, and how to run GPUs alongside diverse NPUs and XPUs (Rebellions, Furiosa, Intel Gaudi, TPU) on a vendor-neutral sovereign AI inference reference architecture."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - llm-d
  - distributed-inference
  - vllm
  - kv-cache-routing
  - prefill-decode
  - heterogeneous-computing
  - npu
  - xpu
  - rebellions
  - furiosa
  - sovereign-ai
  - kubernetes
  - thakicloud
header:
  teaser: /assets/images/llm-d-heterogeneous-hero.webp
toc: true
toc_sticky: true
categories:
  - llmops
published: false
canonical_url: "https://thakicloud.com/tech-blog/en/llmops/llm-d-distributed-inference-heterogeneous-accelerators/"
---

![Heterogeneous cluster where a GPU pool and NPU pool jointly serve inference workloads]({{ '/assets/images/llm-d-heterogeneous-hero.webp' | relative_url }})

## Buying More GPUs Won't Speed Up Inference

Running LLM inference in production means hitting a wall that feels counterintuitive: adding more GPUs does not proportionally increase throughput. The root cause is that inference splits into two phases with fundamentally opposite characteristics.

The prefill phase, which computes the full prompt in one shot, is compute-bound and keeps GPU utilization above 90%. The decode phase, which generates one token at a time, is memory-bound and can drop utilization below 30%. When a single GPU handles both phases, utilization swings wildly, and requests that share a system prompt or common prefix cannot reuse cached KV state. Horizontal scale-up by replicating GPUs is therefore expensive and inefficient. What you actually need is scheduling that extracts more requests from the same GPUs.

That is the one-sentence pitch for llm-d: an inference scheduler that solves what buying more GPUs cannot. This post shares the operating principles of llm-d as we have worked through them in internal seminars and architecture reports, together with the heterogeneous design we are building on top of it, combining GPUs and domestic NPUs in a single cluster. This is the reference design we intend to validate, not a marketing slide.

## What llm-d Is: Built on Three Proven Foundations

llm-d is a Kubernetes-native, high-performance, distributed LLM inference framework. Crucially, it does not start from scratch; it assembles three components that are already proven.

First is vLLM, the actual inference engine providing PagedAttention, continuous batching, and speculative decoding. Second is Kubernetes, the foundation for deployment, scheduling, autoscaling, and fault recovery. Third is the Inference Gateway (GAIE), a Gateway API extension for state-aware routing.

On top of these, llm-d contributes two core capabilities: KV-cache aware routing and prefill/decode disaggregation. On the governance side, it has earned institutional trust: llm-d was adopted into the CNCF Sandbox in 2026, sponsored by IBM, Red Hat, Google, CoreWeave, and NVIDIA.

## Weapon 1: KV-Cache Aware Routing

The first lever is not sending requests to an arbitrary pod. Instead, requests are routed to the pod that already holds the KV cache for the incoming prompt's prefix in GPU memory, even when those requests come from different users.

The payoff is eliminating redundant prefill computation. The gains are especially large for workloads with overlapping prefixes: multi-turn conversations, RAG pipelines, and shared system prompts. Latency drops and throughput rises.

Two routing modes are available. Approximate mode infers cache locality from traffic patterns: lightweight but imprecise. Precise mode subscribes directly to vLLM's KV-Events to read actual KV block state: accurate. Both modes are backed by the KV-Cache Indexer, a high-performance library that maintains a near-real-time global view of KV block locality across all vLLM pods.

## Weapon 2: Prefill / Decode Disaggregation

The second lever is physically separating the two phases that have opposite characteristics. Prefill and decode are split into distinct pod pools, letting each phase be tuned independently. The utilization swings that come from one GPU alternating between both phases disappear.

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
<div class="d3-arch" data-arch-root id="eterogeneousaccelerators-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 276, "height": 800, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 74, "y": 24, "w": 120, "h": 46, "title": "Request"}, {"id": "B", "x": 60, "y": 148, "w": 149, "h": 62, "title": ["Inference Gateway", "GAIE + EPP"]}, {"id": "C", "x": 39, "y": 288, "w": 191, "h": 62, "title": ["KV-Cache Indexer", "Global KV locality view"]}, {"id": "D", "x": 74, "y": 428, "w": 121, "h": 62, "title": ["Prefill Pool", "compute-bound"]}, {"id": "E", "x": 74, "y": 582, "w": 120, "h": 62, "title": ["Decode Pool", "memory-bound"]}, {"id": "F", "x": 74, "y": 722, "w": 120, "h": 46, "title": "Token Stream"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [134, 70, 134, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [134, 210, 134, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [134, 350, 134, 428]}, {"src": "D", "dst": "E", "kind": "data", "label": "KV: direct VRAM→VRAM<br/>transfer via NIXL", "line": [134, 490, 134, 582], "lx": 134, "ly": 532}, {"src": "E", "dst": "F", "kind": "data", "line": [134, 644, 134, 722]}]});
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
      const container = document.getElementById('eterogeneousaccelerators-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eterogeneousaccelerators-1';
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

The key is how the KV cache is transferred. It moves directly from the prefill engine's VRAM to the decode engine's VRAM via NIXL, and because the transfer is non-blocking the GPU continues processing other requests during transit. This lets us optimize Time to First Token (TTFT) and Inter-Token Latency (ITL) independently, without interference.

An honest caveat: at small scale and low concurrency, KV transfer overhead can actually slow things down by 20 to 30%. Disaggregation only pays off when traffic volume supports it.

## Components and Performance Evidence

The full data path, broken down by component, looks like this.

| Component | Role |
|---|---|
| Inference Gateway (GAIE) + EPP | EPP scores per-pod cache hit rates and routes to the optimal pod |
| KV-Cache Indexer | Maintains a global view of KV block locality across all vLLM pods (approximate / precise) |
| Prefill/Decode Disaggregation | Separate pools for compute-bound prefill and memory-bound decode; KV transferred via NIXL |
| vLLM (backend) | Actual inference engine: PagedAttention, continuous batching |
| K8s Operator / CRD | Declarative deployment and autoscaling; versioned via ArgoCD GitOps |

Published numbers back up the performance claims. On a 16x16 B200 topology, roughly 50,000 output tok/s and an order-of-magnitude reduction in TTFT have been reported. On the AMD side, a 4x MI300X cluster serving Llama-3.1-70B showed 3x output throughput and 2x TTFT improvement after enabling prefix-cache aware routing.

These numbers depend heavily on topology, model, and precision, however. Whether "N tok/s" refers to single-stream or aggregate throughput, and what input length, batch size, and precision were used, can shift the meaning by an order of magnitude. We treat benchmark figures without full labels as untrustworthy.

The relationship to alternatives is also clear. If a model fits on a single-node GPU, standalone vLLM is the simplest answer. llm-d enters the picture when you need to go beyond a single node and require multi-model serving at Kubernetes scale. NVIDIA Dynamo targets datacenter-scale orchestration; SGLang targets MoE-EP and bleeding-edge PD separation performance. llm-d and Dynamo are not mutually exclusive: Dynamo can handle orchestration while vLLM and llm-d act as the engine layer.

## Heterogeneous: Adding Any NPU/XPU on Top of GPUs

This is the core of our architecture report. And the first point to lock in is that this design is not tied to any specific accelerator vendor. The orchestration layer of llm-d and vLLM is independent of accelerator type. You can swap out the accelerator pool while leaving the routing and disaggregation logic untouched.

This is not a hypothesis: vLLM already officially supports a wide range of backends. Beyond NVIDIA and AMD GPUs, it covers Intel CPU/XPU/Gaudi (HPU), Google TPU, AWS Neuron, and via plugins, IBM Spyre, Huawei Ascend, and domestic NPUs including Rebellions and Furiosa, all behind the same vLLM interface. In other words, the NPU/XPU slot in a "GPU pool + NPU/XPU pool" configuration accepts any vLLM-compatible accelerator.

| Accelerator | vLLM Backend | Notes |
|---|---|---|
| NVIDIA GPU | CUDA (native) | Highest ecosystem and kernel maturity |
| AMD GPU | ROCm | MI300X and others; officially supported |
| Intel Gaudi / XPU | HPU / XPU backend | Datacenter accelerators |
| Google TPU / AWS Neuron | Dedicated backends | Cloud accelerators |
| Rebellions NPU | vLLM-RBLN (plugin) | Domestic; optimum-rbln / RSD |
| Furiosa NPU | Furiosa-LLM (vLLM-compatible) | Domestic; RNGD / TCP |

We mention both domestic NPUs together to make one point: there is more than one option. The key is that the vLLM abstraction lets you swap vendors rather than lock in.

Rebellions connects via the vLLM-RBLN plugin. A model is compiled with optimum-rbln and then referenced by vLLM-RBLN, which ports FlashAttention and PagedAttention to the NPU memory hierarchy and ties them into a single execution graph. Scale-out uses RSD (Rebellions Scalable Design), which handles prefill/decode separation and MoE routing. In Kubernetes, NFD detects the NPU by PCI vendor ID, the Rebellions NPU Operator registers it as a device-plugin, and environment variables such as `VLLM_TARGET_DEVICE=rbln` govern selection. The current lineup includes the ATOM-Max dual-server with 8 NPUs and 128GB for 70B-class models, with the production REBEL Quad targeting MoE optimization.

Furiosa connects via Furiosa-LLM, a vLLM-compatible serving framework. The flagship chip RNGD uses a TCP (Tensor Contraction Processor) architecture with 48GB HBM3 at 1.5TB/s bandwidth and 180W TDP, delivering 512 TFLOPS at FP8. The NXT RNGD server packs 8 cards for 384GB HBM3 and 4 petaFLOPS (FP8) within a 3kW TDP envelope, with volume production beginning in January 2026. Its primary differentiator is power efficiency, which places it in a different category from GPUs.

The commonality between the two NPUs is the general principle. As long as each vendor provides a device-plugin/operator and a vLLM backend, the llm-d orchestration layer above needs no changes: you simply add an accelerator pool.

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
<div class="d3-arch" data-arch-root id="eterogeneousaccelerators-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 486, "height": 586, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "G", "x": 138, "y": 24, "w": 205, "h": 78, "title": ["Inference Gateway + llm-d", "(Accelerator-neutral", "orchestration)"]}, {"id": "K", "x": 135, "y": 180, "w": 212, "h": 62, "title": ["Kueue", "Unified quota and priority"]}, {"id": "P1", "x": 302, "y": 328, "w": 120, "h": 62, "title": ["GPU Pool", "NVIDIA / AMD"]}, {"id": "P2", "x": 28, "y": 320, "w": 184, "h": 78, "title": ["NPU/XPU Pool", "registered via", "device-plugin/operator"]}, {"id": "V1", "x": 270, "y": 484, "w": 184, "h": 62, "title": ["vLLM (CUDA/ROCm)", "H100/H200/B200, MI300X"]}, {"id": "V2", "x": 24, "y": 476, "w": 191, "h": 78, "title": ["vLLM-compatible backend", "Rebellions, Furiosa,", "Intel, TPU, Neuron ..."]}], "edges": [{"src": "G", "dst": "K", "kind": "data", "line": [241, 102, 241, 180]}, {"src": "K", "dst": "P1", "kind": "data", "curve": [[294, 242], [362, 281], [362, 281], [362, 328]]}, {"src": "K", "dst": "P2", "kind": "data", "curve": [[187, 242], [120, 281], [120, 281], [120, 320]]}, {"src": "P1", "dst": "V1", "kind": "data", "line": [362, 390, 362, 484]}, {"src": "P2", "dst": "V2", "kind": "data", "line": [120, 398, 120, 476]}]});
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
      const container = document.getElementById('eterogeneousaccelerators-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eterogeneousaccelerators-2';
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

Comparing the two pool types side by side in one cluster shows their complementary roles. Note that the right column represents NPUs and XPUs in general, not any single vendor.

| | GPU Pool | NPU/XPU Pool (e.g., Rebellions, Furiosa, Intel, TPU) |
|---|---|---|
| Serving engine | vLLM (CUDA/ROCm) | vLLM-compatible backend (vLLM-RBLN, Furiosa-LLM, HPU/XPU, etc.) |
| K8s device exposure | NVIDIA/AMD GPU Operator | Vendor NPU Operator + NFD / device-plugin |
| Disagg/MoE | Mature via llm-d | Vendor-specific (e.g., RSD) + llm-d integration to be validated |
| Strengths | Ecosystem and kernel maturity, peak throughput | Power efficiency, sovereign supply chain diversification, claimed MoE advantage |
| Caveats | Power, supply, cost | Maturity of distributed disagg/KV routing; fewer large-model references |

## ThakiCloud Adoption and Deployment Roadmap

The biggest advantage of this architecture for us is that it layers onto our existing stack without new infrastructure. It runs on top of the Kubernetes, Kueue, and ArgoCD we already use. Kueue gang-schedules prefill and decode worker pools with quota management; ArgoCD manages CRDs via GitOps. Observability covers TTFT, ITL, tok/s, and KV hit rate via Prometheus and Grafana, with per-model-tier SLOs tracked via SRE rules.

Adoption proceeds in phases, each gated on quantitative measurements. Phase 0 establishes a GPU-pool llm-d baseline and measures the effect of KV routing and PD disaggregation. Phase 1 tunes prefix-cache routing, establishes multi-model serving, and defines SLOs. Phase 2 adds one node of an NPU candidate (Rebellions, Furiosa, or another) to Kubernetes and benchmarks the same model under identical conditions. Accelerator selection will be evaluated on power efficiency, supply chain, and model fit, with no prior commitment to a specific vendor. Phase 3 establishes heterogeneous routing policy and re-evaluates MoE workloads as each vendor reaches volume production. Before each phase, we lock in measurement definitions: single-stream vs. aggregate throughput, input length, batch size, and precision.

## Risks and the Opposing Conclusion

A good design document must attack its own arguments. Here are the weaknesses of this architecture, stated plainly.

The maturity of the NPU/XPU path is the biggest unknown. Single-node serving is becoming solid for any vendor, but whether llm-d's distributed disaggregation and precise KV routing work end-to-end on NPU/XPU hardware is still to be validated. Some vendors provide their own disaggregation (Rebellions RSD, for example), so a "vendor-native stack standalone" configuration may be more realistic than "NPU on top of llm-d." Large-model references are also sparse compared to GPUs. A single server's memory fits 70B-class models, but 744B-class MoE requires multiple nodes and public references are thin. These limits reflect the current state of the NPU/XPU ecosystem as a whole, not any single vendor; that our PoC will become a reference is both an opportunity and a risk.

The opposing conclusion: if the goal is purely maximum throughput in the shortest time, adding NPU/XPU only increases complexity. In that case, GPUs and llm-d are sufficient. The value of alternative accelerators materializes only when separate strategic objectives exist: power efficiency, supply chain diversification, and sovereignty. By the same token, if the model fits on a single node and traffic is low, llm-d itself is overengineering and standalone vLLM is the right answer.

## The ThakiCloud Perspective: Inference That Is Not Locked to an Accelerator

The reason we are focused on this architecture is simple. The single property that makes llm-d's orchestration accelerator-independent is what makes it architecturally possible to run GPU pools and diverse NPU/XPU pools in the same cluster without vendor lock-in, creating a sovereign AI inference setup by design.

This matters strategically for us as an on-premises AI platform provider. Customers must be able to choose accelerators freely based on power budget, supply chain, and domestication requirements, and that choice must not translate into the cost of re-engineering the entire inference stack. Locking into one specific NPU simply swaps GPU lock-in for a different lock-in. The vLLM abstraction and llm-d's accelerator independence eliminate both that cost and that lock-in together. A heterogeneous policy that sends large or latency-critical workloads to GPUs and medium or power-sensitive workloads to NPUs/XPUs can be implemented on the same routing logic regardless of which vendor combination is chosen.

All of this is a reference design and pre-PoC validation, of course. That is why we are locking in measurement definitions first and taking the staged path: GPU baseline, quantitative gates, then NPU expansion.

## Closing

The lesson from llm-d is that inference efficiency is a scheduling problem, not a hardware purchasing problem. Eliminating redundant computation with KV-cache aware routing and stabilizing utilization by separating prefill from decode let you handle more requests from the same GPUs. And because that orchestration is accelerator-independent, the path opens to extending it with any NPU/XPU on top of GPUs (Rebellions, Furiosa, and any vLLM-compatible accelerator) to build sovereign inference that is not locked to any vendor.

ThakiCloud is validating this heterogeneous inference architecture on top of Kubernetes, Kueue, and ArgoCD. Learn more on our homepage.

## Sources

- Red Hat Developer, Master KV cache aware routing with llm-d: [https://developers.redhat.com/articles/2025/10/07/master-kv-cache-aware-routing-llm-d-efficient-ai-inference](https://developers.redhat.com/articles/2025/10/07/master-kv-cache-aware-routing-llm-d-efficient-ai-inference)
- llm-d official site: [https://llm-d.ai/](https://llm-d.ai/)
- llm-d + KServe + vLLM in production: [https://llm-d.ai/blog/production-grade-llm-inference-at-scale-kserve-llm-d-vllm](https://llm-d.ai/blog/production-grade-llm-inference-at-scale-kserve-llm-d-vllm)
- llm-d GitHub: [https://github.com/llm-d/llm-d](https://github.com/llm-d/llm-d)
- Rebellions, LLM Serving with NPU: [https://rebellions.ai/llm-serving-with-npu/](https://rebellions.ai/llm-serving-with-npu/)
- Red Hat Developer, Running AI inference on Rebellions ATOM NPU: [https://developers.redhat.com/articles/2026/05/27/running-ai-inference-rebellions-atom-npu-red-hat-ai](https://developers.redhat.com/articles/2026/05/27/running-ai-inference-rebellions-atom-npu-red-hat-ai)
- vLLM-RBLN plugin: [https://github.com/rebellions-sw/vllm-rbln](https://github.com/rebellions-sw/vllm-rbln)
- FuriosaAI RNGD specifications and NXT RNGD server: [https://furiosa.ai/rngd](https://furiosa.ai/rngd)
- FuriosaAI Developer Center (Furiosa-LLM, vLLM-compatible): [https://developer.furiosa.ai/](https://developer.furiosa.ai/)
- vLLM supported hardware (backend matrix): [https://docs.vllm.ai/](https://docs.vllm.ai/)
- PyTorch Foundation, vLLM multiple backends: [https://pytorch.org/blog/pytorch-foundation-welcomes-vllm/](https://pytorch.org/blog/pytorch-foundation-welcomes-vllm/)

Note: The architecture diagrams are reference designs based on public sources and do not constitute a recommendation of any specific accelerator vendor. Rebellions and Furiosa are two examples of vLLM-compatible NPUs; the same principles apply to other NPUs/XPUs supported by vLLM (Intel Gaudi/XPU, Google TPU, AWS Neuron, IBM Spyre, Huawei Ascend, etc.). Some chip specifications were absent from public datasheets and have been left blank. NPU/XPU integration on top of llm-d is a design hypothesis contingent on each vendor's vLLM backend and has not yet been PoC-validated. Performance figures are environment-dependent; always distinguish single-stream from aggregate throughput when interpreting them.
