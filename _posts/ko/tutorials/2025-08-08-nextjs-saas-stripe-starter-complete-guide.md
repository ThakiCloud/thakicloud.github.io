---
title: "Next.js SaaS Stripe Starter: 완전한 구독 결제 시스템 구축 가이드"
excerpt: "Next.js, Supabase, Stripe를 활용한 완전한 SaaS 애플리케이션 구축 방법을 알아보세요. 구독 결제, 사용자 인증, 데이터베이스 관리까지 모든 것을 다룹니다."
seo_title: "Next.js SaaS Stripe Starter 완전 가이드 - 구독 결제 시스템 구축 - Thaki Cloud"
seo_description: "Next.js, Supabase, Stripe를 사용한 SaaS 애플리케이션 개발 완전 가이드. 구독 결제, 웹훅, 사용자 관리, 배포까지 실무 중심의 단계별 튜토리얼을 제공합니다."
date: 2025-08-08
last_modified_at: 2025-08-08
tags:
  - nextjs
  - saas
  - stripe
  - supabase
  - subscription
  - payment
  - vercel
  - react
  - typescript
  - tailwind
  - webhook
  - authentication
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/tutorials/nextjs-saas-stripe-starter-complete-guide/"
reading_time: true
published: false
categories:
  - tutorials
  - dev
---

⏱️ **예상 읽기 시간**: 22분

## 서론

SaaS(Software as a Service) 애플리케이션 개발에서 가장 중요한 요소 중 하나는 안정적이고 확장 가능한 구독 결제 시스템입니다. [Next.js SaaS Stripe Starter](https://github.com/vercel/nextjs-subscription-payments)는 이러한 복잡한 요구사항을 만족하는 완전한 솔루션을 제공합니다.

이 가이드에서는 Next.js, Supabase, Stripe를 결합하여 프로덕션 준비가 완료된 SaaS 애플리케이션을 구축하는 모든 과정을 다루겠습니다. 사용자 인증부터 구독 관리, 결제 처리, 웹훅 처리까지 실무에 필요한 모든 기능을 구현해보겠습니다.

## 아키텍처 개요

### 🏗️ 기술 스택

```yaml
technology_stack:
  frontend:
    framework: "Next.js 14"
    language: "TypeScript"
    styling: "Tailwind CSS"
    ui_components: "Headless UI"
    
  backend:
    runtime: "Next.js API Routes"
    database: "Supabase (PostgreSQL)"
    auth: "Supabase Auth"
    file_storage: "Supabase Storage"
    
  payments:
    gateway: "Stripe"
    features: ["구독", "일회성 결제", "고객 포털"]
    
  deployment:
    platform: "Vercel"
    cdn: "Vercel Edge Network"
    monitoring: "Vercel Analytics"
```

### 🔄 시스템 아키텍처

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
<div class="d3-arch" data-arch-root id="ripestartercompleteguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 807, "height": 405, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 125, "w": 120, "h": 46, "title": "사용자"}, {"id": "B", "x": 222, "y": 125, "w": 120, "h": 46, "title": "Next.js App"}, {"id": "C", "x": 434, "y": 327, "w": 121, "h": 46, "title": "Supabase Auth"}, {"id": "D", "x": 435, "y": 226, "w": 120, "h": 46, "title": "Supabase DB"}, {"id": "E", "x": 435, "y": 125, "w": 120, "h": 46, "title": "Stripe API"}, {"id": "F", "x": 647, "y": 44, "w": 128, "h": 46, "title": "Stripe Webhook"}, {"id": "G", "x": 420, "y": 24, "w": 149, "h": 46, "title": "Vercel Deployment"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [144, 148, 222, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[293, 171], [381, 350], [381, 350], [434, 350]]}, {"src": "B", "dst": "D", "kind": "data", "curve": [[305, 171], [381, 249], [381, 249], [435, 249]]}, {"src": "B", "dst": "E", "kind": "data", "line": [342, 148, 435, 148]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[555, 148], [608, 148], [608, 148], [682, 90]]}, {"src": "F", "dst": "B", "kind": "data", "curve": [[682, 44], [608, -13], [381, -13], [296, 125]]}, {"src": "B", "dst": "G", "kind": "data", "curve": [[305, 125], [381, 47], [381, 47], [420, 47]]}]});
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
      const container = document.getElementById('ripestartercompleteguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ripestartercompleteguide-1';
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

### 📊 데이터베이스 스키마

```sql
-- 주요 테이블 구조
table_structure = {
  "users": {
    "id": "uuid PRIMARY KEY",
    "email": "text",
    "full_name": "text",
    "avatar_url": "text",
    "billing_address": "jsonb",
    "payment_method": "jsonb"
  },
  
  "products": {
    "id": "text PRIMARY KEY",
    "active": "boolean",
    "name": "text",
    "description": "text",
    "image": "text",
    "metadata": "jsonb"
  },
  
  "prices": {
    "id": "text PRIMARY KEY", 
    "product_id": "text REFERENCES products",
    "active": "boolean",
    "currency": "text",
    "type": "pricing_type",
    "unit_amount": "bigint",
    "interval": "pricing_plan_interval",
    "interval_count": "integer"
  },
  
  "subscriptions": {
    "id": "text PRIMARY KEY",
    "user_id": "uuid REFERENCES users",
    "status": "subscription_status",
    "metadata": "jsonb",
    "price_id": "text REFERENCES prices",
    "quantity": "integer",
    "cancel_at_period_end": "boolean",
    "created": "timestamp",
    "current_period_start": "timestamp",
    "current_period_end": "timestamp",
    "ended_at": "timestamp",
    "cancel_at": "timestamp",
    "canceled_at": "timestamp"
  }
}
```

## 프로젝트 설정

### 🚀 빠른 시작 (Vercel 배포 버튼 사용)

```bash
# 1. Vercel Deploy 버튼 클릭
# https://vercel.com/new/templates/next.js/subscription-starter

# 2. GitHub 저장소 생성 및 Vercel 배포
# 3. Supabase 프로젝트 자동 생성
# 4. 환경 변수 자동 설정

echo "✅ 1-클릭 배포 완료!"
```

### 📦 수동 설치

```bash
# 저장소 클론
git clone https://github.com/vercel/nextjs-subscription-payments.git
cd nextjs-subscription-payments

# 의존성 설치
pnpm install

# 환경 변수 파일 생성
cp .env.local.example .env.local
cp .env.example .env
```

### 🛠️ 개발 환경 설정

```bash
# package.json 스크립트 확인
{
  "scripts": {
    "dev": "next dev",
    "build": "next build", 
    "start": "next start",
    "lint": "next lint",
    "supabase:start": "supabase start",
    "supabase:stop": "supabase stop",
    "supabase:status": "supabase status",
    "supabase:reset": "supabase db reset",
    "supabase:link": "supabase link",
    "supabase:pull": "supabase db pull",
    "supabase:push": "supabase db push",
    "supabase:generate-types": "supabase gen types typescript --local > types_db.ts",
    "supabase:generate-migration": "supabase db diff -f migration_name",
    "supabase:generate-seed": "supabase db dump --data-only -f supabase/seed.sql",
    "stripe:login": "stripe login",
    "stripe:listen": "stripe listen --forward-to localhost:3000/api/webhooks"
  }
}
```

## Supabase 설정

### 🗄️ 데이터베이스 설정

#### 프로젝트 생성 및 초기화

```bash
# Supabase CLI 설치
npm install -g supabase

# 새 Supabase 프로젝트 생성
supabase init

# 로컬 Supabase 시작
pnpm supabase:start

# 데이터베이스 스키마 적용
supabase db reset
```

#### 데이터베이스 스키마

```sql
-- supabase/migrations/001_initial_schema.sql

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- Create custom types
CREATE TYPE pricing_type AS ENUM ('one_time', 'recurring');
CREATE TYPE pricing_plan_interval AS ENUM ('day', 'week', 'month', 'year');
CREATE TYPE subscription_status AS ENUM (
  'trialing', 'active', 'canceled', 'incomplete', 
  'incomplete_expired', 'past_due', 'unpaid', 'paused'
);

-- Users table (extends Supabase auth.users)
CREATE TABLE users (
  id UUID REFERENCES auth.users NOT NULL PRIMARY KEY,
  full_name TEXT,
  avatar_url TEXT,
  billing_address JSONB,
  payment_method JSONB
);

-- Products table
CREATE TABLE products (
  id TEXT PRIMARY KEY,
  active BOOLEAN DEFAULT TRUE,
  name TEXT NOT NULL,
  description TEXT,
  image TEXT,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Prices table
CREATE TABLE prices (
  id TEXT PRIMARY KEY,
  product_id TEXT REFERENCES products(id) ON DELETE CASCADE,
  active BOOLEAN DEFAULT TRUE,
  description TEXT,
  unit_amount BIGINT,
  currency TEXT CHECK (char_length(currency) = 3),
  type pricing_type,
  interval pricing_plan_interval,
  interval_count INTEGER,
  trial_period_days INTEGER,
  metadata JSONB DEFAULT '{}'::jsonb
);

-- Subscriptions table
CREATE TABLE subscriptions (
  id TEXT PRIMARY KEY,
  user_id UUID REFERENCES auth.users NOT NULL,
  status subscription_status,
  metadata JSONB DEFAULT '{}'::jsonb,
  price_id TEXT REFERENCES prices(id),
  quantity INTEGER,
  cancel_at_period_end BOOLEAN DEFAULT FALSE,
  created TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  current_period_start TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  current_period_end TIMESTAMP WITH TIME ZONE DEFAULT timezone('utc'::text, now()) NOT NULL,
  ended_at TIMESTAMP WITH TIME ZONE,
  cancel_at TIMESTAMP WITH TIME ZONE,
  canceled_at TIMESTAMP WITH TIME ZONE,
  trial_start TIMESTAMP WITH TIME ZONE,
  trial_end TIMESTAMP WITH TIME ZONE
);

-- Enable Row Level Security
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE prices ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;

-- Create policies
CREATE POLICY "Users can view own user data" ON users FOR SELECT USING (auth.uid() = id);
CREATE POLICY "Users can update own user data" ON users FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Allow public read-only access to products" ON products FOR SELECT USING (true);
CREATE POLICY "Allow public read-only access to prices" ON prices FOR SELECT USING (true);

CREATE POLICY "Users can view own subscriptions" ON subscriptions FOR SELECT USING (auth.uid() = user_id);

-- Create functions
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO public.users (id, full_name, avatar_url)
  VALUES (new.id, new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'avatar_url');
  RETURN new;
END;
$$ LANGUAGE plpgsql SECURITY definer;

-- Create trigger
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE PROCEDURE handle_new_user();
```

### 🔐 인증 설정

#### GitHub OAuth 설정

```javascript
// 1. GitHub에서 OAuth App 생성
// Settings > Developer settings > OAuth Apps > New OAuth App

const githubOAuthConfig = {
  applicationName: "Your SaaS App",
  homepageURL: "https://your-app.vercel.app",
  authorizationCallbackURL: "https://your-app.vercel.app/auth/callback",
  // 로컬 개발용
  localCallbackURL: "http://localhost:3000/auth/callback"
};

// 2. Supabase에서 GitHub Provider 설정
// Authentication > Settings > Auth Providers > GitHub
```

#### Supabase 환경 변수

```bash
# .env.local
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key
```

### 📱 타입 생성

```bash
# TypeScript 타입 자동 생성
pnpm supabase:generate-types

# 생성된 타입 확인
cat types_db.ts
```

## Stripe 설정

### 🏪 제품 및 가격 설정

#### Stripe 대시보드에서 제품 생성

```javascript
// 제품 예시 구조
const products = [
  {
    name: "Basic Plan",
    description: "기본 기능을 포함한 스타터 플랜",
    prices: [
      {
        amount: 999, // $9.99
        currency: "usd",
        interval: "month"
      },
      {
        amount: 9999, // $99.99 (연간 할인)
        currency: "usd", 
        interval: "year"
      }
    ]
  },
  {
    name: "Pro Plan",
    description: "고급 기능을 포함한 프로 플랜",
    prices: [
      {
        amount: 2999, // $29.99
        currency: "usd",
        interval: "month"
      },
      {
        amount: 29999, // $299.99
        currency: "usd",
        interval: "year"
      }
    ]
  }
];
```

#### Stripe Fixtures로 테스트 데이터 생성

```bash
# Stripe CLI 로그인
stripe login

# 테스트 제품 및 가격 생성
stripe fixtures fixtures/stripe-fixtures.json
```

```json
<!-- fixtures/stripe-fixtures.json -->
{
  "products": [
    {
      "id": "prod_starter",
      "name": "Starter",
      "description": "Perfect for small teams",
      "metadata": {
        "features": "5 users, 10GB storage, Basic support"
      }
    },
    {
      "id": "prod_pro", 
      "name": "Pro",
      "description": "For growing businesses",
      "metadata": {
        "features": "25 users, 100GB storage, Priority support"
      }
    }
  ],
  "prices": [
    {
      "id": "price_starter_monthly",
      "product": "prod_starter",
      "unit_amount": 999,
      "currency": "usd",
      "recurring": {
        "interval": "month"
      }
    },
    {
      "id": "price_starter_yearly",
      "product": "prod_starter", 
      "unit_amount": 9999,
      "currency": "usd",
      "recurring": {
        "interval": "year"
      }
    },
    {
      "id": "price_pro_monthly",
      "product": "prod_pro",
      "unit_amount": 2999,
      "currency": "usd",
      "recurring": {
        "interval": "month"
      }
    },
    {
      "id": "price_pro_yearly",
      "product": "prod_pro",
      "unit_amount": 29999,
      "currency": "usd",
      "recurring": {
        "interval": "year"
      }
    }
  ]
}
```

### 🎣 웹훅 설정

#### 웹훅 엔드포인트 생성

```typescript
// app/api/webhooks/route.ts
import { headers } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';
import Stripe from 'stripe';
import { stripe } from '@/utils/stripe';
import {
  upsertProductRecord,
  upsertPriceRecord,
  manageSubscriptionStatusChange,
  deleteProductRecord,
  deletePriceRecord
} from '@/utils/supabase-admin';

const relevantEvents = new Set([
  'product.created',
  'product.updated',
  'product.deleted',
  'price.created', 
  'price.updated',
  'price.deleted',
  'checkout.session.completed',
  'customer.subscription.created',
  'customer.subscription.updated',
  'customer.subscription.deleted',
  'invoice.payment_succeeded',
  'invoice.payment_failed'
]);

export async function POST(req: NextRequest) {
  const body = await req.text();
  const sig = headers().get('stripe-signature') as string;
  const webhookSecret = process.env.STRIPE_WEBHOOK_SECRET;

  let event: Stripe.Event;

  try {
    if (!sig || !webhookSecret) {
      console.error('Missing stripe signature or webhook secret');
      return new NextResponse('Webhook secret not found.', { status: 400 });
    }
    
    event = stripe.webhooks.constructEvent(body, sig, webhookSecret);
    console.log(`🔔 Webhook received: ${event.type}`);
  } catch (err: any) {
    console.error(`❌ Webhook signature verification failed: ${err.message}`);
    return new NextResponse(`Webhook Error: ${err.message}`, { status: 400 });
  }

  if (relevantEvents.has(event.type)) {
    try {
      switch (event.type) {
        case 'product.created':
        case 'product.updated':
          await upsertProductRecord(event.data.object as Stripe.Product);
          break;
        case 'price.created':
        case 'price.updated':
          await upsertPriceRecord(event.data.object as Stripe.Price);
          break;
        case 'price.deleted':
          await deletePriceRecord(event.data.object as Stripe.Price);
          break;
        case 'product.deleted':
          await deleteProductRecord(event.data.object as Stripe.Product);
          break;
        case 'customer.subscription.created':
        case 'customer.subscription.updated':
        case 'customer.subscription.deleted':
          const subscription = event.data.object as Stripe.Subscription;
          await manageSubscriptionStatusChange(
            subscription.id,
            subscription.customer as string,
            event.type === 'customer.subscription.created'
          );
          break;
        case 'checkout.session.completed':
          const checkoutSession = event.data.object as Stripe.Checkout.Session;
          if (checkoutSession.mode === 'subscription') {
            const subscriptionId = checkoutSession.subscription;
            await manageSubscriptionStatusChange(
              subscriptionId as string,
              checkoutSession.customer as string,
              true
            );
          }
          break;
        default:
          throw new Error('Unhandled relevant event!');
      }
    } catch (error) {
      console.error('Error processing webhook:', error);
      return new NextResponse('Webhook handler failed. View your nextjs function logs.', {
        status: 400
      });
    }
  } else {
    return new NextResponse(`Unsupported event type: ${event.type}`, {
      status: 400
    });
  }
  
  return new NextResponse(JSON.stringify({ received: true }));
}
```

#### 로컬 웹훅 테스트

```bash
# 터미널 1: Next.js 개발 서버
pnpm dev

# 터미널 2: Stripe 웹훅 리스닝  
pnpm stripe:listen

# 출력에서 웹훅 시크릿 복사하여 .env.local에 추가
# STRIPE_WEBHOOK_SECRET=whsec_xxxxx
```

## 핵심 기능 구현

### 💳 구독 체크아웃

```typescript
// utils/stripe-helpers.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';
import { getStripe } from '@/utils/stripe-client';
import { Price, ProductWithPrice } from '@/types';

interface CheckoutResponse {
  errorRedirect?: string;
  sessionId?: string;
}

export const getErrorRedirect = (
  path: string,
  errorMsgPrefix: string,
  errorMsg: string = 'An unknown error occurred.'
) => `${path}?error=${encodeURIComponent(`${errorMsgPrefix}: ${errorMsg}`)}`;

export const redirectToCheckout = async (price: Price): Promise<void> => {
  try {
    const supabase = createClientComponentClient();
    
    // 사용자 인증 확인
    const {
      data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
      throw new Error('사용자가 로그인되어 있지 않습니다.');
    }

    // 체크아웃 세션 생성
    const { data: checkoutResponse, error } = await supabase.functions.invoke(
      'create-checkout-session',
      {
        body: {
          price: price,
          quantity: 1,
          metadata: {
            user_id: user.id
          }
        }
      }
    );

    if (error) {
      throw new Error(error.message);
    }

    const { sessionId } = checkoutResponse as CheckoutResponse;
    
    if (!sessionId) {
      throw new Error('체크아웃 세션 생성에 실패했습니다.');
    }

    // Stripe Checkout으로 리디렉션
    const stripe = await getStripe();
    const { error: stripeError } = await stripe!.redirectToCheckout({
      sessionId
    });

    if (stripeError) {
      throw new Error(stripeError.message);
    }
  } catch (error) {
    console.error('Checkout error:', error);
    return window.location.assign(
      getErrorRedirect(
        '/pricing',
        '체크아웃 오류',
        error instanceof Error ? error.message : '알 수 없는 오류가 발생했습니다.'
      )
    );
  }
};
```

#### 체크아웃 API Route

```typescript
// app/api/create-checkout-session/route.ts
import { createRouteHandlerClient } from '@supabase/auth-helpers-nextjs';
import { cookies } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/utils/stripe';
import { createOrRetrieveCustomer } from '@/utils/supabase-admin';
import { getURL } from '@/utils/helpers';

export async function POST(req: NextRequest) {
  try {
    const { price, quantity = 1, metadata = {} } = await req.json();
    
    const supabase = createRouteHandlerClient({ cookies });
    const {
      data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
      throw new Error('인증되지 않은 사용자입니다.');
    }

    // Stripe 고객 생성 또는 조회
    const customer = await createOrRetrieveCustomer({
      uuid: user.id,
      email: user.email || ''
    });

    // 체크아웃 세션 생성
    const session = await stripe.checkout.sessions.create({
      payment_method_types: ['card'],
      billing_address_collection: 'required',
      customer,
      line_items: [
        {
          price: price.id,
          quantity
        }
      ],
      mode: 'subscription',
      allow_promotion_codes: true,
      subscription_data: {
        metadata
      },
      success_url: `${getURL()}/account`,
      cancel_url: `${getURL()}/pricing`
    });

    return NextResponse.json({ sessionId: session.id });
  } catch (error: any) {
    console.error('Error creating checkout session:', error);
    return new NextResponse(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    );
  }
}
```

### 🎛️ 고객 포털

```typescript
// utils/stripe-helpers.ts 계속
export const redirectToCustomerPortal = async (): Promise<void> => {
  try {
    const supabase = createClientComponentClient();
    
    const {
      data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
      throw new Error('사용자가 로그인되어 있지 않습니다.');
    }

    const { data, error } = await supabase.functions.invoke(
      'create-portal-session'
    );

    if (error) {
      throw new Error(error.message);
    }

    window.location.assign(data.url);
  } catch (error) {
    console.error('Portal redirect error:', error);
    return window.location.assign(
      getErrorRedirect(
        '/account',
        '포털 오류',
        error instanceof Error ? error.message : '알 수 없는 오류가 발생했습니다.'
      )
    );
  }
};
```

#### 포털 API Route

```typescript
// app/api/create-portal-session/route.ts
import { createRouteHandlerClient } from '@supabase/auth-helpers-nextjs';
import { cookies } from 'next/headers';
import { NextRequest, NextResponse } from 'next/server';
import { stripe } from '@/utils/stripe';
import { createOrRetrieveCustomer } from '@/utils/supabase-admin';
import { getURL } from '@/utils/helpers';

export async function POST(req: NextRequest) {
  try {
    const supabase = createRouteHandlerClient({ cookies });
    const {
      data: { user }
    } = await supabase.auth.getUser();

    if (!user) {
      throw new Error('인증되지 않은 사용자입니다.');
    }

    const customer = await createOrRetrieveCustomer({
      uuid: user.id,
      email: user.email || ''
    });

    if (!customer) {
      throw new Error('고객 정보를 찾을 수 없습니다.');
    }

    const { url } = await stripe.billingPortal.sessions.create({
      customer,
      return_url: `${getURL()}/account`
    });

    return NextResponse.json({ url });
  } catch (error: any) {
    console.error('Error creating portal session:', error);
    return new NextResponse(
      JSON.stringify({ error: error.message }),
      { status: 500 }
    );
  }
}
```

### 👤 사용자 계정 관리

```typescript
// components/AccountForm.tsx
'use client';

import { useState } from 'react';
import { useRouter } from 'next/navigation';
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';
import { User } from '@supabase/gotrue-js';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { Button } from '@/components/ui/Button';

interface Props {
  user: User;
}

export default function AccountForm({ user }: Props) {
  const router = useRouter();
  const supabase = createClientComponentClient();
  const [loading, setLoading] = useState(false);
  const [fullName, setFullName] = useState(user.user_metadata?.full_name ?? '');

  const updateProfile = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);

    try {
      const { error } = await supabase.auth.updateUser({
        data: { full_name: fullName }
      });

      if (error) {
        throw error;
      }

      router.refresh();
    } catch (error) {
      console.error('프로필 업데이트 오류:', error);
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="max-w-2xl mx-auto p-6">
      <Card>
        <CardHeader>
          <CardTitle>계정 정보</CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={updateProfile} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">
                이메일 주소
              </label>
              <input
                type="email"
                value={user.email}
                disabled
                className="w-full p-2 border rounded-md bg-gray-50"
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">
                전체 이름
              </label>
              <input
                type="text"
                value={fullName}
                onChange={(e) => setFullName(e.target.value)}
                className="w-full p-2 border rounded-md"
                placeholder="전체 이름을 입력하세요"
              />
            </div>

            <Button
              type="submit"
              disabled={loading}
              className="w-full"
            >
              {loading ? '업데이트 중...' : '프로필 업데이트'}
            </Button>
          </form>
        </CardContent>
      </Card>
    </div>
  );
}
```

### 📊 구독 상태 관리

```typescript
// components/SubscriptionStatus.tsx
'use client';

import { useState } from 'react';
import { redirectToCustomerPortal } from '@/utils/stripe-helpers';
import { Subscription, Price, Product } from '@/types';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';

interface Props {
  subscription: Subscription & {
    prices: Price & {
      products: Product;
    };
  };
}

export default function SubscriptionStatus({ subscription }: Props) {
  const [loading, setLoading] = useState(false);

  const handlePortalRedirect = async () => {
    setLoading(true);
    await redirectToCustomerPortal();
    setLoading(false);
  };

  const formatDate = (dateString: string) => {
    return new Date(dateString).toLocaleDateString('ko-KR', {
      year: 'numeric',
      month: 'long',
      day: 'numeric'
    });
  };

  const getStatusColor = (status: string) => {
    switch (status) {
      case 'active':
        return 'text-green-600 bg-green-100';
      case 'trialing':
        return 'text-blue-600 bg-blue-100';
      case 'past_due':
        return 'text-yellow-600 bg-yellow-100';
      case 'canceled':
        return 'text-red-600 bg-red-100';
      default:
        return 'text-gray-600 bg-gray-100';
    }
  };

  return (
    <Card>
      <CardHeader>
        <CardTitle>구독 정보</CardTitle>
      </CardHeader>
      <CardContent className="space-y-4">
        <div className="flex justify-between items-center">
          <span className="font-medium">플랜:</span>
          <span>{subscription.prices.products.name}</span>
        </div>

        <div className="flex justify-between items-center">
          <span className="font-medium">상태:</span>
          <span className={`px-2 py-1 rounded text-sm ${getStatusColor(subscription.status)}`}>
            {subscription.status.charAt(0).toUpperCase() + subscription.status.slice(1)}
          </span>
        </div>

        <div className="flex justify-between items-center">
          <span className="font-medium">요금:</span>
          <span>
            ${(subscription.prices.unit_amount / 100).toFixed(2)} / {subscription.prices.interval}
          </span>
        </div>

        <div className="flex justify-between items-center">
          <span className="font-medium">다음 결제일:</span>
          <span>{formatDate(subscription.current_period_end)}</span>
        </div>

        {subscription.cancel_at_period_end && (
          <div className="p-3 bg-yellow-50 border border-yellow-200 rounded">
            <p className="text-yellow-800 text-sm">
              구독이 {formatDate(subscription.current_period_end)}에 취소됩니다.
            </p>
          </div>
        )}

        <Button
          onClick={handlePortalRedirect}
          disabled={loading}
          className="w-full"
          variant="outline"
        >
          {loading ? '로딩 중...' : '구독 관리'}
        </Button>
      </CardContent>
    </Card>
  );
}
```

## UI 구성요소

### 🎨 가격 책정 페이지

```typescript
// components/Pricing.tsx
'use client';

import { useState } from 'react';
import { redirectToCheckout } from '@/utils/stripe-helpers';
import { ProductWithPrice } from '@/types';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';
import { CheckIcon } from '@heroicons/react/24/outline';

interface Props {
  products: ProductWithPrice[];
}

export default function Pricing({ products }: Props) {
  const [billingInterval, setBillingInterval] = useState<'month' | 'year'>('month');
  const [loading, setLoading] = useState<string | null>(null);

  const handleCheckout = async (priceId: string) => {
    setLoading(priceId);
    
    const price = products
      .flatMap(product => product.prices)
      .find(price => price.id === priceId);

    if (price) {
      await redirectToCheckout(price);
    }
    
    setLoading(null);
  };

  const getFeatures = (productName: string): string[] => {
    switch (productName.toLowerCase()) {
      case 'starter':
        return [
          '5명의 팀 멤버',
          '10GB 저장 공간',
          '기본 고객 지원',
          '기본 분석',
          '모바일 앱'
        ];
      case 'pro':
        return [
          '25명의 팀 멤버',
          '100GB 저장 공간',
          '우선 고객 지원', 
          '고급 분석',
          '모바일 앱',
          'API 접근',
          '사용자 정의 통합'
        ];
      case 'enterprise':
        return [
          '무제한 팀 멤버',
          '무제한 저장 공간',
          '24/7 전담 지원',
          '엔터프라이즈 분석',
          '모든 플랫폼',
          '전체 API 접근',
          '사용자 정의 개발',
          'SSO 통합',
          '고급 보안'
        ];
      default:
        return [];
    }
  };

  return (
    <div className="max-w-6xl mx-auto p-6">
      {/* 헤더 */}
      <div className="text-center mb-12">
        <h1 className="text-4xl font-bold mb-4">
          간단하고 투명한 가격책정
        </h1>
        <p className="text-xl text-gray-600 mb-8">
          비즈니스 성장에 맞는 플랜을 선택하세요
        </p>
        
        {/* 빌링 주기 토글 */}
        <div className="flex items-center justify-center space-x-4">
          <span className={billingInterval === 'month' ? 'font-semibold' : 'text-gray-600'}>
            월간
          </span>
          <button
            onClick={() => setBillingInterval(billingInterval === 'month' ? 'year' : 'month')}
            className="relative inline-flex h-6 w-11 items-center rounded-full bg-gray-200 transition-colors focus:outline-none focus:ring-2 focus:ring-blue-500 focus:ring-offset-2"
          >
            <span
              className={`inline-block h-4 w-4 transform rounded-full bg-white transition-transform ${
                billingInterval === 'year' ? 'translate-x-6' : 'translate-x-1'
              }`}
            />
          </button>
          <span className={billingInterval === 'year' ? 'font-semibold' : 'text-gray-600'}>
            연간 <span className="text-green-600 text-sm">(20% 할인)</span>
          </span>
        </div>
      </div>

      {/* 가격 카드 */}
      <div className="grid md:grid-cols-3 gap-8">
        {products?.map((product) => {
          const price = product.prices.find(
            (price) => price.interval === billingInterval
          );
          
          if (!price) return null;

          const features = getFeatures(product.name);
          const isPopular = product.name.toLowerCase() === 'pro';

          return (
            <Card 
              key={product.id}
              className={`relative ${isPopular ? 'border-blue-500 ring-2 ring-blue-200' : ''}`}
            >
              {isPopular && (
                <div className="absolute -top-4 left-1/2 transform -translate-x-1/2">
                  <span className="bg-blue-500 text-white px-4 py-1 rounded-full text-sm font-medium">
                    인기
                  </span>
                </div>
              )}
              
              <CardHeader className="text-center">
                <CardTitle className="text-2xl">{product.name}</CardTitle>
                <div className="mt-4">
                  <span className="text-4xl font-bold">
                    ${(price.unit_amount / 100).toFixed(0)}
                  </span>
                  <span className="text-gray-600">/{price.interval}</span>
                </div>
                <p className="text-gray-600 mt-2">{product.description}</p>
              </CardHeader>

              <CardContent>
                <Button
                  onClick={() => handleCheckout(price.id)}
                  disabled={loading === price.id}
                  className={`w-full mb-6 ${
                    isPopular 
                      ? 'bg-blue-500 hover:bg-blue-600' 
                      : 'bg-gray-900 hover:bg-gray-800'
                  }`}
                >
                  {loading === price.id ? '처리 중...' : '시작하기'}
                </Button>

                <ul className="space-y-3">
                  {features.map((feature, index) => (
                    <li key={index} className="flex items-center">
                      <CheckIcon className="h-5 w-5 text-green-500 mr-3 flex-shrink-0" />
                      <span className="text-sm">{feature}</span>
                    </li>
                  ))}
                </ul>
              </CardContent>
            </Card>
          );
        })}
      </div>

      {/* FAQ 섹션 */}
      <div className="mt-16 text-center">
        <h2 className="text-2xl font-bold mb-8">자주 묻는 질문</h2>
        <div className="grid md:grid-cols-2 gap-8 text-left">
          <div>
            <h3 className="font-semibold mb-2">언제든지 취소할 수 있나요?</h3>
            <p className="text-gray-600">
              네, 언제든지 구독을 취소할 수 있습니다. 취소 시 현재 결제 주기 말까지 서비스를 이용할 수 있습니다.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-2">플랜을 변경할 수 있나요?</h3>
            <p className="text-gray-600">
              언제든지 플랜을 업그레이드하거나 다운그레이드할 수 있습니다. 변경 사항은 즉시 적용됩니다.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-2">환불 정책은 어떻게 되나요?</h3>
            <p className="text-gray-600">
              모든 요금제에 대해 30일 환불 보장을 제공합니다. 만족하지 않으시면 전액 환불해드립니다.
            </p>
          </div>
          <div>
            <h3 className="font-semibold mb-2">기업용 플랜이 있나요?</h3>
            <p className="text-gray-600">
              네, 대규모 조직을 위한 Enterprise 플랜을 제공합니다. 문의해 주시면 맞춤 견적을 제공해드립니다.
            </p>
          </div>
        </div>
      </div>
    </div>
  );
}
```

### 🔐 인증 UI

```typescript
// components/AuthUI.tsx
'use client';

import { useState } from 'react';
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';
import { Button } from '@/components/ui/Button';
import { Card, CardContent, CardHeader, CardTitle } from '@/components/ui/Card';

export default function AuthUI() {
  const [loading, setLoading] = useState(false);
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [isSignUp, setIsSignUp] = useState(false);
  const [message, setMessage] = useState('');

  const supabase = createClientComponentClient();

  const handleAuth = async (e: React.FormEvent) => {
    e.preventDefault();
    setLoading(true);
    setMessage('');

    try {
      if (isSignUp) {
        const { error } = await supabase.auth.signUp({
          email,
          password,
          options: {
            emailRedirectTo: `${location.origin}/auth/callback`
          }
        });
        
        if (error) throw error;
        setMessage('확인 이메일을 보냈습니다. 이메일을 확인해주세요.');
      } else {
        const { error } = await supabase.auth.signInWithPassword({
          email,
          password
        });
        
        if (error) throw error;
      }
    } catch (error: any) {
      setMessage(error.message);
    } finally {
      setLoading(false);
    }
  };

  const handleGitHubSignIn = async () => {
    setLoading(true);
    
    const { error } = await supabase.auth.signInWithOAuth({
      provider: 'github',
      options: {
        redirectTo: `${location.origin}/auth/callback`
      }
    });
    
    if (error) {
      setMessage(error.message);
    }
    
    setLoading(false);
  };

  return (
    <div className="max-w-md mx-auto p-6">
      <Card>
        <CardHeader>
          <CardTitle className="text-center">
            {isSignUp ? '회원가입' : '로그인'}
          </CardTitle>
        </CardHeader>
        <CardContent>
          <form onSubmit={handleAuth} className="space-y-4">
            <div>
              <label className="block text-sm font-medium mb-1">
                이메일
              </label>
              <input
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                className="w-full p-2 border rounded-md"
                placeholder="your@email.com"
                required
              />
            </div>
            
            <div>
              <label className="block text-sm font-medium mb-1">
                비밀번호
              </label>
              <input
                type="password"
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                className="w-full p-2 border rounded-md"
                placeholder="••••••••"
                required
              />
            </div>

            <Button
              type="submit"
              disabled={loading}
              className="w-full"
            >
              {loading ? '처리 중...' : (isSignUp ? '회원가입' : '로그인')}
            </Button>
          </form>

          <div className="mt-4">
            <div className="relative">
              <div className="absolute inset-0 flex items-center">
                <div className="w-full border-t border-gray-300" />
              </div>
              <div className="relative flex justify-center text-sm">
                <span className="px-2 bg-white text-gray-500">또는</span>
              </div>
            </div>

            <Button
              onClick={handleGitHubSignIn}
              disabled={loading}
              variant="outline"
              className="w-full mt-4"
            >
              GitHub으로 계속하기
            </Button>
          </div>

          <div className="mt-4 text-center">
            <button
              onClick={() => setIsSignUp(!isSignUp)}
              className="text-sm text-blue-600 hover:underline"
            >
              {isSignUp 
                ? '이미 계정이 있으신가요? 로그인' 
                : '계정이 없으신가요? 회원가입'
              }
            </button>
          </div>

          {message && (
            <div className={`mt-4 p-3 rounded text-sm ${
              message.includes('error') || message.includes('Error')
                ? 'bg-red-50 text-red-700 border border-red-200'
                : 'bg-green-50 text-green-700 border border-green-200'
            }`}>
              {message}
            </div>
          )}
        </CardContent>
      </Card>
    </div>
  );
}
```

## 배포 및 운영

### 🚀 Vercel 배포

```bash
# Vercel CLI 설치
npm i -g vercel

# 프로젝트 배포
vercel --prod

# 환경 변수 설정
vercel env add NEXT_PUBLIC_SUPABASE_URL
vercel env add NEXT_PUBLIC_SUPABASE_ANON_KEY
vercel env add SUPABASE_SERVICE_ROLE_KEY
vercel env add NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
vercel env add STRIPE_SECRET_KEY
vercel env add STRIPE_WEBHOOK_SECRET
vercel env add NEXT_PUBLIC_SITE_URL
```

### 📊 환경 변수 체크리스트

```bash
# .env.local (개발 환경)
NEXT_PUBLIC_SUPABASE_URL=your_supabase_project_url
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key

NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_test_...
STRIPE_SECRET_KEY=sk_test_...
STRIPE_WEBHOOK_SECRET=whsec_...

NEXT_PUBLIC_SITE_URL=http://localhost:3000
```

```bash
# 프로덕션 환경 변수
NEXT_PUBLIC_SUPABASE_URL=https://your-project.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your_production_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_production_service_role_key

NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_...
STRIPE_SECRET_KEY=sk_live_...
STRIPE_WEBHOOK_SECRET=whsec_...

NEXT_PUBLIC_SITE_URL=https://your-app.vercel.app
```

### 🔄 CI/CD 파이프라인

```yaml
# .github/workflows/deploy.yml
name: Deploy to Vercel

on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest

    steps:
      - name: Checkout code
        uses: actions/checkout@v4

      - name: Setup Node.js
        uses: actions/setup-node@v4
        with:
          node-version: '18'
          cache: 'npm'

      - name: Install dependencies
        run: npm ci

      - name: Run tests
        run: npm run test

      - name: Run linting
        run: npm run lint

      - name: Build project
        run: npm run build

      - name: Deploy to Vercel
        if: github.ref == 'refs/heads/main'
        uses: amondnet/vercel-action@v25
        with:
          vercel-token: ${{ secrets.VERCEL_TOKEN }}
          vercel-org-id: ${{ secrets.ORG_ID }}
          vercel-project-id: ${{ secrets.PROJECT_ID }}
          vercel-args: '--prod'
```

## 고급 기능

### 📈 분석 및 추적

```typescript
// utils/analytics.ts
import { createClientComponentClient } from '@supabase/auth-helpers-nextjs';

interface AnalyticsEvent {
  event_name: string;
  user_id?: string;
  properties?: Record<string, any>;
  timestamp?: string;
}

export class Analytics {
  private supabase = createClientComponentClient();

  async track(event: AnalyticsEvent) {
    try {
      const { data: { user } } = await this.supabase.auth.getUser();
      
      const eventData = {
        ...event,
        user_id: user?.id || event.user_id,
        timestamp: event.timestamp || new Date().toISOString()
      };

      // Supabase에 이벤트 저장
      const { error } = await this.supabase
        .from('analytics_events')
        .insert(eventData);

      if (error) {
        console.error('Analytics tracking error:', error);
      }

      // 추가 분석 서비스 (선택사항)
      if (typeof window !== 'undefined' && window.gtag) {
        window.gtag('event', event.event_name, {
          user_id: eventData.user_id,
          ...event.properties
        });
      }
    } catch (error) {
      console.error('Analytics error:', error);
    }
  }

  // 구독 이벤트 추적
  subscriptionStarted(planName: string, planPrice: number) {
    return this.track({
      event_name: 'subscription_started',
      properties: {
        plan_name: planName,
        plan_price: planPrice
      }
    });
  }

  subscriptionCancelled(planName: string) {
    return this.track({
      event_name: 'subscription_cancelled',
      properties: {
        plan_name: planName
      }
    });
  }

  checkoutStarted(planName: string) {
    return this.track({
      event_name: 'checkout_started',
      properties: {
        plan_name: planName
      }
    });
  }
}

// 사용 예시
export const analytics = new Analytics();
```

### 🔔 이메일 알림

```typescript
// utils/email.ts
import { Resend } from 'resend';

const resend = new Resend(process.env.RESEND_API_KEY);

interface EmailTemplate {
  to: string;
  subject: string;
  template: string;
  variables?: Record<string, any>;
}

export class EmailService {
  async sendWelcomeEmail(userEmail: string, userName: string) {
    try {
      await resend.emails.send({
        from: 'noreply@yourdomain.com',
        to: userEmail,
        subject: '환영합니다! 🎉',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h1>안녕하세요 ${userName}님!</h1>
            <p>저희 서비스에 가입해 주셔서 감사합니다.</p>
            <p>이제 모든 기능을 사용하실 수 있습니다:</p>
            <ul>
              <li>대시보드 접근</li>
              <li>프리미엄 기능 사용</li>
              <li>24/7 고객 지원</li>
            </ul>
            <a href="${process.env.NEXT_PUBLIC_SITE_URL}/dashboard" 
               style="background: #007bff; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 20px 0;">
              시작하기
            </a>
          </div>
        `
      });
    } catch (error) {
      console.error('이메일 발송 오류:', error);
    }
  }

  async sendSubscriptionConfirmation(userEmail: string, planName: string) {
    try {
      await resend.emails.send({
        from: 'noreply@yourdomain.com',
        to: userEmail,
        subject: '구독이 활성화되었습니다! ✅',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h1>구독 확인</h1>
            <p><strong>${planName}</strong> 플랜 구독이 성공적으로 활성화되었습니다.</p>
            <p>지금부터 모든 프리미엄 기능을 이용하실 수 있습니다.</p>
            <a href="${process.env.NEXT_PUBLIC_SITE_URL}/account" 
               style="background: #28a745; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 20px 0;">
              계정 관리
            </a>
          </div>
        `
      });
    } catch (error) {
      console.error('구독 확인 이메일 발송 오류:', error);
    }
  }

  async sendPaymentFailedEmail(userEmail: string) {
    try {
      await resend.emails.send({
        from: 'noreply@yourdomain.com',
        to: userEmail,
        subject: '결제 실패 알림 ⚠️',
        html: `
          <div style="font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto;">
            <h1>결제 실패</h1>
            <p>구독 갱신 결제가 실패했습니다.</p>
            <p>서비스 중단을 방지하기 위해 결제 정보를 업데이트해 주세요.</p>
            <a href="${process.env.NEXT_PUBLIC_SITE_URL}/account" 
               style="background: #dc3545; color: white; padding: 12px 24px; text-decoration: none; border-radius: 6px; display: inline-block; margin: 20px 0;">
              결제 정보 업데이트
            </a>
          </div>
        `
      });
    } catch (error) {
      console.error('결제 실패 이메일 발송 오류:', error);
    }
  }
}

export const emailService = new EmailService();
```

### 🛡️ 보안 및 권한 관리

```typescript
// middleware.ts
import { createMiddlewareClient } from '@supabase/auth-helpers-nextjs';
import { NextResponse } from 'next/server';
import type { NextRequest } from 'next/server';

export async function middleware(req: NextRequest) {
  const res = NextResponse.next();
  const supabase = createMiddlewareClient({ req, res });

  const {
    data: { session },
  } = await supabase.auth.getSession();

  // 인증이 필요한 경로
  const protectedPaths = ['/account', '/dashboard'];
  const isProtectedPath = protectedPaths.some(path => 
    req.nextUrl.pathname.startsWith(path)
  );

  // 구독이 필요한 경로
  const subscriptionPaths = ['/dashboard', '/premium'];
  const isSubscriptionPath = subscriptionPaths.some(path =>
    req.nextUrl.pathname.startsWith(path)
  );

  // 인증되지 않은 사용자
  if (isProtectedPath && !session) {
    return NextResponse.redirect(new URL('/auth', req.url));
  }

  // 구독 확인
  if (isSubscriptionPath && session) {
    const { data: subscription } = await supabase
      .from('subscriptions')
      .select('status')
      .eq('user_id', session.user.id)
      .eq('status', 'active')
      .single();

    if (!subscription) {
      return NextResponse.redirect(new URL('/pricing', req.url));
    }
  }

  return res;
}

export const config = {
  matcher: ['/((?!api|_next/static|_next/image|favicon.ico).*)'],
};
```

## 테스트

### 🧪 단위 테스트

```typescript
// __tests__/components/Pricing.test.tsx
import { render, screen, fireEvent, waitFor } from '@testing-library/react';
import '@testing-library/jest-dom';
import Pricing from '@/components/Pricing';
import { redirectToCheckout } from '@/utils/stripe-helpers';

// Mock
jest.mock('@/utils/stripe-helpers');
const mockRedirectToCheckout = redirectToCheckout as jest.MockedFunction<typeof redirectToCheckout>;

const mockProducts = [
  {
    id: 'prod_1',
    name: 'Basic',
    description: 'Basic plan',
    prices: [
      {
        id: 'price_1',
        unit_amount: 999,
        interval: 'month',
        currency: 'usd'
      }
    ]
  }
];

describe('Pricing Component', () => {
  beforeEach(() => {
    jest.clearAllMocks();
  });

  it('renders pricing plans correctly', () => {
    render(<Pricing products={mockProducts} />);
    
    expect(screen.getByText('Basic')).toBeInTheDocument();
    expect(screen.getByText('$9')).toBeInTheDocument();
    expect(screen.getByText('시작하기')).toBeInTheDocument();
  });

  it('handles checkout click', async () => {
    mockRedirectToCheckout.mockResolvedValue();
    
    render(<Pricing products={mockProducts} />);
    
    const checkoutButton = screen.getByText('시작하기');
    fireEvent.click(checkoutButton);
    
    await waitFor(() => {
      expect(mockRedirectToCheckout).toHaveBeenCalledWith(mockProducts[0].prices[0]);
    });
  });

  it('toggles billing interval', () => {
    render(<Pricing products={mockProducts} />);
    
    const toggle = screen.getByRole('button', { name: /billing toggle/i });
    fireEvent.click(toggle);
    
    // 연간 할인 텍스트 확인
    expect(screen.getByText(/20% 할인/)).toBeInTheDocument();
  });
});
```

### 🔧 E2E 테스트

```typescript
// e2e/subscription-flow.spec.ts
import { test, expect } from '@playwright/test';

test.describe('Subscription Flow', () => {
  test('complete subscription purchase', async ({ page }) => {
    // 홈페이지 방문
    await page.goto('/');
    
    // 가격 페이지로 이동
    await page.click('text=Pricing');
    await expect(page.locator('h1')).toContainText('가격책정');
    
    // 플랜 선택
    await page.click('[data-testid="basic-plan-button"]');
    
    // Stripe Checkout 페이지 확인
    await expect(page).toHaveURL(/checkout\.stripe\.com/);
    
    // 테스트 카드 정보 입력
    await page.fill('[data-elements-stable-field-name="cardNumber"]', '4242424242424242');
    await page.fill('[data-elements-stable-field-name="cardExpiry"]', '12/25');
    await page.fill('[data-elements-stable-field-name="cardCvc"]', '123');
    await page.fill('[data-elements-stable-field-name="billingName"]', 'Test User');
    
    // 결제 완료
    await page.click('[data-testid="hosted-payment-submit-button"]');
    
    // 성공 페이지 확인
    await expect(page).toHaveURL('/account');
    await expect(page.locator('text=구독이 활성화되었습니다')).toBeVisible();
  });

  test('customer portal access', async ({ page }) => {
    // 로그인 (구독이 있는 사용자)
    await page.goto('/auth');
    await page.fill('[data-testid="email"]', 'test@example.com');
    await page.fill('[data-testid="password"]', 'password');
    await page.click('[data-testid="sign-in-button"]');
    
    // 계정 페이지로 이동
    await page.goto('/account');
    
    // 구독 관리 버튼 클릭
    await page.click('text=구독 관리');
    
    // Stripe 고객 포털 확인
    await expect(page).toHaveURL(/billing\.stripe\.com/);
  });
});
```

## 문제 해결

### 🔧 일반적인 문제들

#### 1. 웹훅 처리 오류

```typescript
// utils/webhook-logger.ts
import { createServiceRoleClient } from '@/utils/supabase-admin';

export async function logWebhookEvent(
  eventType: string,
  eventData: any,
  success: boolean,
  error?: string
) {
  const supabase = createServiceRoleClient();
  
  await supabase.from('webhook_logs').insert({
    event_type: eventType,
    event_data: eventData,
    success,
    error,
    created_at: new Date().toISOString()
  });
}

// webhook endpoint에서 사용
export async function POST(req: NextRequest) {
  try {
    // ... webhook 처리 로직
    
    await logWebhookEvent(event.type, event.data, true);
    return NextResponse.json({ received: true });
  } catch (error) {
    await logWebhookEvent(event.type, event.data, false, error.message);
    throw error;
  }
}
```

#### 2. 구독 동기화 문제

```bash
# 구독 상태 수동 동기화 스크립트
#!/bin/bash

echo "🔄 Stripe 구독 동기화 시작..."

# Stripe에서 모든 구독 조회
stripe subscriptions list --limit=100 > subscriptions.json

# Node.js 스크립트로 데이터베이스 업데이트
node scripts/sync-subscriptions.js

echo "✅ 동기화 완료"
```

#### 3. 환경 변수 검증

```typescript
// utils/env-validation.ts
const requiredEnvVars = [
  'NEXT_PUBLIC_SUPABASE_URL',
  'NEXT_PUBLIC_SUPABASE_ANON_KEY',
  'SUPABASE_SERVICE_ROLE_KEY',
  'NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY',
  'STRIPE_SECRET_KEY',
  'STRIPE_WEBHOOK_SECRET'
];

export function validateEnvironmentVariables() {
  const missing = requiredEnvVars.filter(envVar => !process.env[envVar]);
  
  if (missing.length > 0) {
    throw new Error(`Missing required environment variables: ${missing.join(', ')}`);
  }
  
  console.log('✅ All environment variables are set');
}

// app/layout.tsx에서 실행
if (process.env.NODE_ENV === 'development') {
  validateEnvironmentVariables();
}
```

## 결론

Next.js SaaS Stripe Starter는 현대적인 SaaS 애플리케이션 개발을 위한 완전한 솔루션을 제공합니다. 이 가이드를 통해 다음과 같은 성과를 달성할 수 있습니다:

### 🎯 주요 성과

- **빠른 개발**: 검증된 아키텍처로 개발 시간 단축
- **확장성**: 사용자 증가에 따른 안정적인 확장
- **보안**: 최신 보안 표준 및 모범 사례 적용
- **사용자 경험**: 직관적이고 반응성 있는 인터페이스
- **비즈니스 성장**: 안정적인 구독 결제 시스템

### 🚀 다음 단계

```javascript
next_steps = {
  immediate: [
    "프로덕션 환경 배포",
    "도메인 연결 및 SSL 설정",
    "모니터링 시스템 구축"
  ],
  
  growth: [
    "A/B 테스트 구현",
    "고급 분석 도구 통합",
    "국제화 (i18n) 지원"
  ],
  
  scale: [
    "마이크로서비스 아키텍처 고려",
    "CDN 최적화",
    "성능 모니터링 강화"
  ]
}
```

### 💡 최종 권장사항

1. **점진적 배포**: 기본 기능부터 시작하여 점진적으로 확장
2. **사용자 피드백**: 실제 사용자 피드백을 통한 지속적 개선
3. **모니터링**: 성능과 오류를 지속적으로 모니터링
4. **보안**: 정기적인 보안 감사 및 업데이트
5. **문서화**: 팀 내 지식 공유를 위한 문서화

Next.js SaaS Stripe Starter를 기반으로 여러분만의 성공적인 SaaS 애플리케이션을 구축해보세요!

---

**더 알아보기:**
- [Next.js 공식 문서](https://nextjs.org/docs)
- [Supabase 문서](https://supabase.com/docs)
- [Stripe 개발자 가이드](https://stripe.com/docs)
- [Vercel 배포 가이드](https://vercel.com/docs)
