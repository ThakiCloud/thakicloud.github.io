---
title: "Building Sovereign AI for Air-Gapped Public Sector: On-Premises LLM Reference Architecture"
excerpt: "A guide for government and public sector organizations that cannot use external cloud services to securely operate LLMs on internal GPU infrastructure. Introduces ThakiCloud AI Platform's air-gap deployment reference architecture, along with security and governance design."
seo_title: "On-Premises LLM Reference Architecture for Air-Gapped Public Sector - Thaki Cloud"
seo_description: "Reference architecture for public sector and government organizations in air-gapped environments to build a sovereign AI cloud on-premises. Covers NIS security requirements, domestic data storage mandates, Keycloak RBAC, ArgoCD GitOps, and vLLM serverless inference."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - sovereign-ai
  - on-premise
  - llm
  - air-gap
  - public-sector
author_profile: true
toc: true
toc_label: "Contents"
toc_icon: "cog"
toc_sticky: true
lang: en
canonical_url: "https://thakicloud.com/tech-blog/en/saas/sovereign-ai-airgap-public-sector/"
reading_time: true
categories:
  - dev
published: false
---

![Sovereign AI Reference Architecture for Air-Gapped Public Sector]({{ '/assets/images/sovereign-ai-airgap-public-sector-hero.webp' | relative_url }})

## Overview: Why Sovereign AI Matters for the Public Sector Now

Since 2024, generative AI adoption discussions have accelerated across Korean government agencies and public institutions. However, many organizations face significant barriers to using commercial cloud LLM services due to security regulations and legal requirements. Security monitoring mandates from the National Intelligence Service (NIS), domestic data storage obligations under the Information and Communications Network Act and the Personal Information Protection Act, and longstanding network separation policies all fundamentally block external API calls.

In this environment, the demand to "use AI without letting data leave the premises" converges on a single solution: operating LLMs directly on internal GPU infrastructure -- what is known as **Sovereign AI**.

ThakiCloud is a Kubernetes-based AI/ML SaaS platform designed for full deployment in on-premises and air-gapped environments. This article uses a hypothetical public sector case to present a detailed reference architecture for securely deploying LLM services in a network-separated environment.

---

## Constraints Facing Public Sector Organizations

### Network Separation and Air-Gap

The most defining characteristic of Korean public sector IT environments is the complete separation of internet networks from internal work networks. Many agencies go beyond logical separation to require physically disconnected air-gap configurations. In these cases, not only are public cloud API calls impossible -- even external access to container image registries is blocked. Every image and package required for deployment must be pre-mirrored into an internal registry.

### NIS Security Requirements

The National Intelligence Service's Cloud Security Assurance Program (CSAP) and security monitoring guidelines mandate audit log retention for system access history, multi-factor authentication (MFA), role-based access control (RBAC), and domestic storage of all sensitive data. Because inference requests to an LLM may contain query content that itself qualifies as sensitive information, inference endpoints fall within this scope of control.

### On-Premises Network Constraints

Designing service URLs for on-premises environments comes with its own unique constraints. As an established fact in this context, on-premises environments frequently cannot support wildcard DNS or wildcard SSL certificates. Service access URLs must therefore either use a pre-defined fixed subdomain pool (e.g., `api.aiplatform.agency.go.kr`, `console.aiplatform.agency.go.kr`) or distinguish services by port number on a single hostname. These constraints must be addressed at the platform design stage.

### Domestic Data Storage Mandate

Under the Public Data Management Act and the Personal Information Protection Act, data processed by public institutions must be stored on servers within South Korea. Sending LLM queries to overseas public cloud providers may itself constitute a violation of this obligation.

---

## Reference Architecture: Air-Gapped Deployment Configuration

Below is a reference architecture for a hypothetical central government agency deploying ThakiCloud AI Platform in an on-premises air-gapped environment.

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
<div class="d3-arch" data-arch-root id="eignaiairgappublicsector-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1633, "height": 1181, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 24, "y": 24, "w": 491, "h": 140, "label": "User Layer", "lx": 36, "ly": 42}, {"x": 71, "y": 256, "w": 392, "h": 333, "label": "Access Control Layer", "lx": 83, "ly": 274}, {"x": 482, "y": 256, "w": 499, "h": 551, "label": "Control Plane (k0s)", "lx": 494, "ly": 274}, {"x": 1112, "y": 667, "w": 245, "h": 482, "label": "Data Plane A - Inference", "lx": 1124, "ly": 685}, {"x": 1377, "y": 667, "w": 224, "h": 319, "label": "Data Plane B - Training", "lx": 1389, "ly": 685}, {"x": 1001, "y": 24, "w": 210, "h": 565, "label": "Observability Stack", "lx": 1013, "ly": 42}, {"x": 1231, "y": 449, "w": 370, "h": 140, "label": "Internal Registry", "lx": 1243, "ly": 467}], "nodes": [{"id": "U1", "x": 308, "y": 63, "w": 170, "h": 62, "title": ["Administrative Staff", "Terminal"]}, {"id": "U2", "x": 62, "y": 71, "w": 191, "h": 46, "title": "Research Staff Terminal"}, {"id": "GW", "x": 193, "y": 295, "w": 163, "h": 62, "title": ["Traefik Gateway API", "HTTP/gRPC/WebSocket"]}, {"id": "KC", "x": 108, "y": 488, "w": 121, "h": 62, "title": ["Keycloak IdP", "OIDC/MFA/RBAC"]}, {"id": "CP", "x": 619, "y": 488, "w": 121, "h": 62, "title": ["Go API Server", ":3000"]}, {"id": "WEB", "x": 795, "y": 496, "w": 149, "h": 46, "title": "React Web Console"}, {"id": "ARGO", "x": 674, "y": 303, "w": 121, "h": 46, "title": "ArgoCD GitOps"}, {"id": "PG", "x": 520, "y": 714, "w": 120, "h": 46, "title": "PostgreSQL"}, {"id": "NATS", "x": 703, "y": 714, "w": 128, "h": 46, "title": "NATS JetStream"}, {"id": "VLLM", "x": 1150, "y": 706, "w": 170, "h": 62, "title": ["vLLM Serverless", "+ KEDA Scale-to-Zero"]}, {"id": "KAI", "x": 1174, "y": 885, "w": 121, "h": 62, "title": ["KAI Scheduler", "+ Kueue"]}, {"id": "GPU1", "x": 1171, "y": 1064, "w": 128, "h": 46, "title": "GPU Node (MIG)"}, {"id": "KF", "x": 1415, "y": 706, "w": 149, "h": 62, "title": ["Kubeflow TrainJob", "SFT/DPO/LoRA"]}, {"id": "GPU2", "x": 1422, "y": 893, "w": 135, "h": 46, "title": "GPU Node (Full)"}, {"id": "VM", "x": 1039, "y": 303, "w": 135, "h": 46, "title": "VictoriaMetrics"}, {"id": "VL", "x": 1046, "y": 71, "w": 120, "h": 46, "title": "VictoriaLogs"}, {"id": "DCGM", "x": 1046, "y": 496, "w": 121, "h": 46, "title": "DCGM Exporter"}, {"id": "REG", "x": 1269, "y": 488, "w": 120, "h": 62, "title": ["Harbor", "Image Mirror"]}, {"id": "GIT", "x": 1444, "y": 488, "w": 120, "h": 62, "title": ["Gitea", "Internal Git"]}], "edges": [{"src": "U1", "dst": "GW", "kind": "data", "label": "HTTPS", "curve": [[393, 125], [393, 164], [393, 256], [327, 295]], "off": "50%"}, {"src": "U2", "dst": "GW", "kind": "data", "label": "HTTPS", "curve": [[157, 117], [157, 164], [157, 256], [223, 295]], "off": "50%"}, {"src": "GW", "dst": "KC", "kind": "data", "label": "OIDC Token", "curve": [[232, 357], [169, 403], [169, 449], [169, 488]], "off": "50%"}, {"src": "GW", "dst": "WEB", "kind": "data", "curve": [[326, 357], [403, 403], [403, 449], [795, 508]]}, {"src": "GW", "dst": "CP", "kind": "data", "curve": [[278, 357], [283, 403], [283, 449], [619, 508]]}, {"src": "CP", "dst": "VLLM", "kind": "data", "curve": [[737, 550], [810, 589], [810, 667], [1150, 723]]}, {"src": "CP", "dst": "KF", "kind": "data", "curve": [[740, 547], [830, 589], [830, 667], [1415, 729]]}, {"src": "CP", "dst": "PG", "kind": "data", "curve": [[635, 550], [580, 589], [580, 667], [580, 714]]}, {"src": "CP", "dst": "NATS", "kind": "data", "curve": [[718, 550], [767, 589], [767, 667], [767, 714]]}, {"src": "ARGO", "dst": "GIT", "kind": "data", "curve": [[768, 349], [848, 403], [848, 449], [1444, 513]]}, {"src": "ARGO", "dst": "CP", "kind": "data", "label": "GitOps Sync", "curve": [[718, 349], [679, 403], [679, 449], [679, 488]], "off": "50%"}, {"src": "VLLM", "dst": "KAI", "kind": "data", "line": [1235, 768, 1235, 885]}, {"src": "KAI", "dst": "GPU1", "kind": "data", "line": [1235, 947, 1235, 1064]}, {"src": "KF", "dst": "GPU2", "kind": "data", "line": [1489, 768, 1489, 893]}, {"src": "VM", "dst": "DCGM", "kind": "data", "line": [1106, 349, 1106, 496]}, {"src": "VL", "dst": "VM", "kind": "data", "line": [1106, 117, 1106, 303]}]});
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
      const container = document.getElementById('eignaiairgappublicsector-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'eignaiairgappublicsector-1';
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

### Key Components

**Control Plane and Data Plane Separation**

According to ThakiCloud AI Platform documentation (see the logical architecture for KSA partner evaluation), the platform strictly separates the control plane from the data plane. The control plane manages API services, state, and orchestration logic, while the data plane handles GPU workload execution and inference endpoint services. This separation ensures that inference services in the data plane can continue operating without interruption even during control plane maintenance.

**Internal Registry for Air-Gap Deployment**

In environments disconnected from the external internet, an internal container registry such as Harbor must be configured and all container images pre-mirrored. Rather than the standard kubeadm, the lightweight deployment tool k0s is used for Kubernetes cluster deployment, with official support for air-gap installation. Combining Helm charts with ArgoCD's App-of-Apps pattern allows the entire cluster state to be managed declaratively, using an internal Gitea repository as the single source of truth.

**vLLM Serverless Inference and Scale-to-Zero**

Inference workloads are built on vLLM and integrated with KEDA (Kubernetes Event-Driven Autoscaler) to achieve scale-to-zero. GPU resources are released during idle periods and automatically scaled up when requests arrive, enabling efficient sharing of limited on-premises GPU resources.

---

## Security and Governance

### Four-Tier RBAC with Keycloak OIDC

ThakiCloud AI Platform provides a four-tier RBAC structure -- Organization, Project, Group, and User -- using Keycloak as the Identity Provider (IdP). According to the Web UI README, role assignments for Admin, Developer, and Viewer roles are implemented with Union+Deny algorithm-based permission merging, and group information is embedded in JWT tokens for real-time permission validation.

In the public sector context, departmental project isolation is critical. For example, even when the Planning and Coordination Office and the IT Department share the same platform, each department's LLM query history and fine-tuning data are isolated at the project namespace level to prevent cross-department exposure.

Keycloak's MFA configuration can satisfy the enhanced authentication requirements in NIS security monitoring guidelines. Integration with existing HR systems or Active Directory is also supported via LDAP federation.

### ArgoCD GitOps and Change History Management

All platform configuration changes are managed as Helm charts in an internal Git repository and synchronized to the cluster by ArgoCD. This GitOps pattern provides a complete audit trail -- who changed what and when -- through Git commit logs. It eliminates ad hoc changes from direct `kubectl apply` commands (configuration drift), enhancing the reliability of change history needed for compliance audits.

### Audit Logs and Observability Stack

Inference API calls, fine-tuning job start and end events, user logins, and permission change events are all collected centrally in VictoriaLogs. GPU telemetry is collected by the DCGM Exporter and forwarded to VictoriaMetrics. Since all log data is stored on internal servers, the domestic data storage obligation is naturally satisfied.

In particular, to meet the access history retention requirements of NIS security monitoring guidelines, a Python Admin API server (FastAPI) serves as a dedicated audit log collector. This component -- explicitly specified in the control plane logical architecture documentation -- stores the subject, timestamp, target resource, and result of each API request in PostgreSQL and also streams to VictoriaLogs. Audit logs are configured for a minimum retention period of six months, adjustable to institutional policy.

Another key strength of the observability stack is GPU resource visibility. The DCGM Exporter collects GPU temperature, memory usage, and compute utilization in real time, displaying them on the VictoriaMetrics dashboard. This allows operations teams to detect GPU node overload early and take proactive action such as workload redistribution or cooling measures.

### Satisfying the Domestic Data Storage Mandate

Because all platform components run on servers within the institution, no data -- including the content of LLM queries -- is transmitted externally. Model weight files are also stored and managed in internal storage (Longhorn or NFS).

---

## Implications for ThakiCloud AI Platform Adoption

### Full Air-Gap Support

ThakiCloud AI Platform was designed from the ground up to support on-premises and air-gapped environments. A logical architecture document exists for the KSA (Kingdom of Saudi Arabia) sovereign cloud deployment, and there is a reference for operating the entire platform on a purely on-premises stack including bare-metal servers, GPU nodes, and InfiniBand fabric. This goes beyond simply "supporting on-premises installation" -- it represents a complete full-stack configuration capable of independent operation with no public cloud dependencies.

### Six Fine-Tuning Pipelines

Public sector organizations often need models fine-tuned on institution-specific documents and regulatory data rather than general-purpose LLMs. ThakiCloud AI Platform supports six fine-tuning methods -- SFT, DPO, GRPO, CPT, GKD, and LoRA -- via Kubeflow TrainJob. Offering a wider range of fine-tuning options within a single platform is a key differentiator compared to competing solutions.

### GPU Resource Efficiency via Kueue and KAI Scheduler

Public sector organizations cannot simply purchase additional GPUs on demand the way public cloud users can. Fair sharing of limited GPU resources across multiple departments is critical. Kueue and the KAI custom scheduler support fair-share queuing and Gang Scheduling, reclaiming idle GPU resources to improve utilization (30-50% reclaim [estimate] per pitch deck). Logical partitioning of a single GPU using MIG (Multi-Instance GPU) enables even finer-grained allocation of smaller inference requests.

### Technical Foundation for NIS Security Compliance

Keycloak OIDC MFA, four-tier RBAC, ArgoCD-based change history, VictoriaLogs audit logs, and PostgreSQL-based audit event storage provide the technical foundation for the core requirements of NIS security monitoring guidelines. That said, obtaining CSAP certification requires not only technical configuration but also non-technical elements such as operational procedures, staffing, and physical security -- so certification is not automatically achieved by adopting the platform alone. The platform serves as a starting point that satisfies the technical control items.

### Multi-Cluster Centralized Management

For large ministries or those with multiple subsidiary agencies, NATS and gRPC-based multi-cluster centralized management allows distributed GPU clusters to be operated from a single console. ArgoCD Manager handles integrated GitOps synchronization status across clusters, making it easy to maintain consistent configuration when operating multiple sites.

---

## Limitations and Adoption Considerations

### Initial Build Costs and Specialist Personnel

Unlike public cloud SaaS, on-premises air-gap deployment requires upfront server procurement, network configuration, and internal staff or partners with Kubernetes operational expertise. In particular, image mirroring in air-gapped environments, issuing TLS certificates from an internal CA via cert-manager, and internal DNS design are tasks that require experienced engineers.

### Model Updates and Security Patch Management

In an air-gapped environment, new LLM model versions or platform security patches cannot be automatically downloaded from external sources. Periodic image mirroring procedures and change validation processes must be established in advance, creating an ongoing operational burden.

### Resolving On-Premises DNS/SSL Constraints Up Front

As noted above, on-premises environments often cannot support wildcard DNS and SSL. Before platform adoption, a decision must be made on either a fixed subdomain pool per service or a port-based access policy. Delaying this decision makes post-deployment URL restructuring difficult.

### CSAP Certification Requires a Separate Initiative

While ThakiCloud AI Platform provides a foundation that satisfies technical control items, CSAP certification itself is a comprehensive evaluation process that includes non-technical elements such as operational procedures, physical security, and personnel security. If certification is the goal, work with your institution's information security team or a specialized consulting partner to develop a separate certification plan.

### Phased Adoption Recommended

Rather than deploying the full platform at once, a more practical approach is to start with inference endpoint services and progressively expand to fine-tuning and ML pipelines. We recommend building operational experience with a small pilot cluster initially, then expanding to a multi-cluster configuration.

---

The constraints of network separation and air-gapped environments may feel like barriers to AI adoption. However, these constraints actually provide a clear boundary from a data sovereignty and security perspective, and can serve as an opportunity to systematically manage and leverage internal GPU infrastructure. ThakiCloud AI Platform is a full-stack solution designed for precisely this environment, providing the technical foundation for public sector organizations to operate sovereign AI securely and efficiently.

If you are considering adoption, please contact the ThakiCloud technical team for detailed architecture design tailored to your institution's environment.
