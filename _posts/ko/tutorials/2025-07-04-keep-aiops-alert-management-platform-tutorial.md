---
title: "Keep 완벽 가이드 - 오픈소스 AIOps 및 알림 관리 플랫폼으로 모니터링 자동화하기"
excerpt: "Keep 오픈소스 AIOps 플랫폼을 활용한 알림 관리 자동화 방법을 알아보고, 워크플로우 기반 모니터링 도구 통합 가이드를 제공합니다."
seo_title: "Keep AIOps 플랫폼 완벽 가이드 - 알림 관리 자동화 - Thaki Cloud"
seo_description: "Keep 오픈소스 AIOps 플랫폼으로 알림 관리를 자동화하는 방법과 워크플로우 기반 모니터링 도구 통합 방법을 상세히 알아보세요."
date: 2025-07-04
last_modified_at: 2025-07-04
tags:
  - Keep
  - AIOps
  - 알림관리
  - 모니터링
  - 워크플로우
  - 자동화
  - DevOps
  - 오픈소스
  - YAML
  - 통합
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/tutorials/keep-aiops-alert-management-platform-tutorial/"
reading_time: true
published: false
categories:
  - tutorials
  - dev
---

⏱️ **예상 읽기 시간**: 15분

## 서론

현대 IT 환경에서 모니터링 도구들은 끊임없이 알림을 생성하지만, 이들을 효과적으로 관리하고 자동화하는 것은 여전히 큰 과제입니다. [Keep](https://github.com/keephq/keep)은 이러한 문제를 해결하기 위한 오픈소스 AIOps 및 알림 관리 플랫폼으로, "모니터링 도구를 위한 GitHub Actions"라는 컨셉으로 개발되었습니다.

Keep은 **10.4k stars**를 받은 활발한 오픈소스 프로젝트로, 다양한 모니터링 도구와 통합하여 알림 관리를 자동화하고 인시던트 대응을 효율화할 수 있습니다. 이 가이드에서는 Keep의 핵심 개념부터 실제 구현까지 상세히 알아보겠습니다.

## Keep 핵심 개념

### AIOps 플랫폼으로서의 Keep

Keep은 **AIOps(Artificial Intelligence for IT Operations)**와 **알림 관리**를 결합한 플랫폼입니다:

- **워크플로우 기반 자동화**: YAML로 정의된 워크플로우를 통한 지능적 알림 처리
- **다양한 도구 통합**: 100개 이상의 provider를 통한 모니터링 생태계 연결
- **Enterprise-ready**: 대규모 환경에서의 안정적인 운영 지원

### 주요 특징

1. **Developer First**: 현대적인 REST API, 네이티브 SDK, 포괄적인 문서
2. **Enterprise Security**: SSO, SAML, OIDC, RBAC 등 완전한 보안 지원
3. **Flexible Deployment**: 온프레미스, 클라우드, 에어갭 환경 지원
4. **Production Scale**: 고가용성, 수평적 확장 지원

## 아키텍처 분석

### 워크플로우 구조

Keep 워크플로우는 세 가지 주요 구성요소로 이루어집니다:

#### 1. Triggers (트리거)
워크플로우를 시작하는 조건들:
- **알림 기반**: 특정 알림 조건에 따른 자동 실행
- **인시던트 기반**: 인시던트 발생 시 자동 실행
- **스케줄 기반**: 정기적인 실행 (cron 표현식)
- **수동 실행**: 사용자 요청에 따른 실행

#### 2. Steps (단계)
데이터 읽기 및 가져오기:
- **데이터 enrichment**: 추가 컨텍스트 정보 수집
- **외부 시스템 조회**: API 호출을 통한 데이터 획득
- **조건부 로직**: 복잡한 비즈니스 로직 실행

#### 3. Actions (액션)
실제 작업 수행:
- **알림 전송**: Slack, 이메일, SMS 등으로 알림
- **티켓 생성**: Jira, ServiceNow 등에 티켓 생성
- **자동 복구**: 서버 재시작, 스케일링 등 자동 작업

### 아키텍처 다이어그램

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
<div class="d3-arch" data-arch-root id="nagementplatformtutorial-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 622, "height": 722, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 378, "y": 24, "w": 120, "h": 46, "title": "모니터링 도구들"}, {"id": "B", "x": 378, "y": 148, "w": 121, "h": 46, "title": "Keep Platform"}, {"id": "C", "x": 378, "y": 272, "w": 120, "h": 46, "title": "워크플로우 엔진"}, {"id": "D", "x": 470, "y": 396, "w": 120, "h": 46, "title": "Triggers"}, {"id": "E", "x": 291, "y": 396, "w": 120, "h": 46, "title": "Steps"}, {"id": "F", "x": 112, "y": 396, "w": 120, "h": 46, "title": "Actions"}, {"id": "G", "x": 470, "y": 520, "w": 120, "h": 46, "title": "알림 필터링"}, {"id": "H", "x": 287, "y": 520, "w": 128, "h": 46, "title": "데이터 enrichment"}, {"id": "I", "x": 112, "y": 520, "w": 120, "h": 46, "title": "자동 대응"}, {"id": "J", "x": 374, "y": 644, "w": 120, "h": 46, "title": "Slack 알림"}, {"id": "K", "x": 199, "y": 644, "w": 120, "h": 46, "title": "Jira 티켓"}, {"id": "L", "x": 24, "y": 644, "w": 120, "h": 46, "title": "자동 복구"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [438, 70, 438, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [438, 194, 438, 272]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[472, 318], [530, 357], [530, 357], [530, 396]]}, {"src": "C", "dst": "E", "kind": "data", "curve": [[406, 318], [351, 357], [351, 357], [351, 396]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[378, 309], [172, 357], [172, 357], [172, 396]]}, {"src": "D", "dst": "G", "kind": "data", "line": [530, 442, 530, 520]}, {"src": "E", "dst": "H", "kind": "data", "line": [351, 442, 351, 520]}, {"src": "F", "dst": "I", "kind": "data", "line": [172, 442, 172, 520]}, {"src": "I", "dst": "J", "kind": "data", "curve": [[232, 557], [434, 605], [434, 605], [434, 644]]}, {"src": "I", "dst": "K", "kind": "data", "curve": [[204, 566], [259, 605], [259, 605], [259, 644]]}, {"src": "I", "dst": "L", "kind": "data", "curve": [[139, 566], [84, 605], [84, 605], [84, 644]]}]});
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
      const container = document.getElementById('nagementplatformtutorial-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nagementplatformtutorial-1';
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

## Provider 생태계

Keep은 100개 이상의 provider를 지원하여 다양한 도구와 통합할 수 있습니다:

### 모니터링 도구
- **Prometheus**: 메트릭 기반 모니터링
- **Grafana**: 시각화 및 대시보드
- **Datadog**: 종합 모니터링 플랫폼
- **New Relic**: APM 및 인프라 모니터링
- **PagerDuty**: 인시던트 관리

### 커뮤니케이션 도구
- **Slack**: 팀 커뮤니케이션
- **Microsoft Teams**: 기업 협업
- **Discord**: 커뮤니티 소통
- **Telegram**: 모바일 알림

### 티켓팅 도구
- **Jira**: 프로젝트 관리
- **GitHub Issues**: 코드 관련 이슈
- **ServiceNow**: 기업 서비스 관리
- **Linear**: 현대적 이슈 트래킹

### 클라우드 플랫폼
- **AWS**: 클라우드 서비스 모니터링
- **Azure**: Microsoft 클라우드 통합
- **GCP**: Google Cloud 연동
- **Kubernetes**: 컨테이너 오케스트레이션

## 기본 워크플로우 예시

### Sentry 알림을 Jira 티켓으로 변환

```yaml
{% raw %}
workflow:
  id: sentry-to-jira
  description: Sentry 크리티컬 알림을 Jira 티켓으로 생성
  triggers:
    - type: alert
      filters:
        - key: source
          value: sentry
        - key: severity
          value: critical
        - key: service
          value: r"(payments|api)"
  actions:
    - name: create-jira-ticket
      if: "not '{{ alert.ticket_id }}'"
      provider:
        type: jira
        config: "{{ providers.jira }}"
        with:
          board_name: "Oncall Board"
          issuetype: "Bug"
          summary: "{{ alert.name }} - {{ alert.description }}"
          description: |
            크리티컬 알림이 발생했습니다.
            
            **알림 세부사항:**
            - 서비스: {{ alert.service }}
            - 심각도: {{ alert.severity }}
            - 시간: {{ alert.timestamp }}
            
            ```json
            {{ alert | tojson }}
{% endraw %}
            ```
          enrich_alert:
            - key: ticket_id
              value: results.issue.key
            - key: ticket_url
              value: results.ticket_url
```

### 복합 워크플로우: 알림 → Slack + 자동 복구

```yaml
{% raw %}
workflow:
  id: disk-space-automation
  description: 디스크 공간 부족 시 자동 대응
  triggers:
    - type: alert
      filters:
        - key: source
          value: prometheus
        - key: alert_name
          value: DiskSpaceHigh
  steps:
    - name: check-disk-usage
      provider:
        type: bash
        with:
          command: "df -h | grep '{{ alert.device }}'"
  actions:
    - name: notify-ops-team
      provider:
        type: slack
        config: "{{ providers.slack-ops }}"
        with:
          channel: "#ops-alerts"
          message: |
            🚨 **디스크 공간 부족 알림**
            
            **서버**: {{ alert.hostname }}
            **디스크**: {{ alert.device }}
            **사용률**: {{ alert.usage }}%
            
            **현재 상태**:
{% endraw %}
            ```
            {{ steps.check-disk-usage.results.stdout }}
            ```
            
            자동 정리 작업을 시작합니다...
    
    - name: auto-cleanup
      if: "{{ alert.usage }} > 90"
      provider:
        type: bash
        with:
          command: |
            # 로그 파일 정리
            find /var/log -name "*.log" -mtime +7 -delete
            # 임시 파일 정리
            find /tmp -type f -mtime +3 -delete
            # Docker 이미지 정리
            docker system prune -f
    
    - name: notify-cleanup-result
      provider:
        type: slack
        config: "{{ providers.slack-ops }}"
        with:
          channel: "#ops-alerts"
          message: |
            ✅ **자동 정리 완료**
            
            **정리 결과**:
            ```
            {{ steps.auto-cleanup.results.stdout }}
            ```
```

## 설치 및 환경 구성

### Docker Compose를 사용한 로컬 설치

```bash
# Keep 저장소 클론
git clone https://github.com/keephq/keep.git
cd keep

# Docker Compose로 실행
docker-compose up -d

# 웹 인터페이스 접속
open http://localhost:8080
```

### Kubernetes 배포

```yaml
# keep-namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: keep-system
---
# keep-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: keep-server
  namespace: keep-system
spec:
  replicas: 2
  selector:
    matchLabels:
      app: keep-server
  template:
    metadata:
      labels:
        app: keep-server
    spec:
      containers:
      - name: keep-server
        image: keephq/keep:latest
        ports:
        - containerPort: 8080
        env:
        - name: DATABASE_URL
          value: "postgresql://user:password@postgres:5432/keep"
        - name: REDIS_URL
          value: "redis://redis:6379"
---
# keep-service.yaml
apiVersion: v1
kind: Service
metadata:
  name: keep-server
  namespace: keep-system
spec:
  selector:
    app: keep-server
  ports:
    - protocol: TCP
      port: 80
      targetPort: 8080
  type: LoadBalancer
```

### 환경 변수 설정

```bash
# .env 파일 생성
cat > .env << EOF
# 데이터베이스 설정
DATABASE_URL=postgresql://username:password@localhost:5432/keep
REDIS_URL=redis://localhost:6379

# 보안 설정
SECRET_KEY=your-secret-key-here
JWT_SECRET=your-jwt-secret-here

# 외부 서비스 연동
SLACK_BOT_TOKEN=xoxb-your-slack-bot-token
JIRA_URL=https://your-company.atlassian.net
JIRA_USERNAME=your-jira-username
JIRA_PASSWORD=your-jira-password

# 프로메테우스 연동
PROMETHEUS_URL=http://localhost:9090
GRAFANA_URL=http://localhost:3000
EOF
```

## Provider 설정

### Slack Provider 설정

```yaml
{% raw %}
# providers.yaml
providers:
  slack-ops:
    type: slack
    config:
      webhook_url: "{{ env.SLACK_WEBHOOK_URL }}"
      bot_token: "{{ env.SLACK_BOT_TOKEN }}"
      signing_secret: "{{ env.SLACK_SIGNING_SECRET }}"
{% endraw %}
```

### Jira Provider 설정

```yaml
{% raw %}
providers:
  jira:
    type: jira
    config:
      url: "{{ env.JIRA_URL }}"
      username: "{{ env.JIRA_USERNAME }}"
      password: "{{ env.JIRA_PASSWORD }}"
      # 또는 API 토큰 사용
      api_token: "{{ env.JIRA_API_TOKEN }}"
{% endraw %}
```

### Prometheus Provider 설정

```yaml
{% raw %}
providers:
  prometheus:
    type: prometheus
    config:
      url: "{{ env.PROMETHEUS_URL }}"
      username: "{{ env.PROMETHEUS_USERNAME }}"
      password: "{{ env.PROMETHEUS_PASSWORD }}"
{% endraw %}
```

## 실무 활용 사례

### 1. 인시던트 대응 자동화

```yaml
{% raw %}
workflow:
  id: incident-response
  description: 인시던트 발생 시 자동 대응 워크플로우
  triggers:
    - type: alert
      filters:
        - key: severity
          value: critical
        - key: service
          value: production
  steps:
    - name: gather-context
      provider:
        type: prometheus
        with:
          query: "up{service='{{ alert.service }}'}"
    
    - name: check-recent-deployments
      provider:
        type: github
        with:
          repo: "{{ alert.repository }}"
          query: "recent deployments"
  
  actions:
    - name: create-incident
      provider:
        type: pagerduty
        with:
          service_key: "{{ alert.service_key }}"
          incident_key: "{{ alert.fingerprint }}"
          description: "{{ alert.description }}"
    
    - name: notify-on-call
      provider:
        type: slack
        with:
          channel: "#incidents"
          message: |
            🚨 **인시던트 발생**
            
            **서비스**: {{ alert.service }}
            **상태**: {{ steps.gather-context.results.up }}
            **최근 배포**: {{ steps.check-recent-deployments.results.latest }}
            
            PagerDuty 인시던트: {{ actions.create-incident.results.incident_url }}
    
    - name: auto-rollback
      if: "{{ steps.check-recent-deployments.results.within_1_hour }}"
      provider:
        type: kubernetes
        with:
          namespace: "{{ alert.namespace }}"
          deployment: "{{ alert.service }}"
          action: "rollback"
{% endraw %}
```

### 2. 성능 모니터링 및 자동 스케일링

```yaml
{% raw %}
workflow:
  id: auto-scaling
  description: CPU 사용률 기반 자동 스케일링
  triggers:
    - type: alert
      filters:
        - key: alert_name
          value: HighCPUUsage
        - key: usage
          value: "> 80"
  
  steps:
    - name: get-current-replicas
      provider:
        type: kubernetes
        with:
          namespace: "{{ alert.namespace }}"
          deployment: "{{ alert.deployment }}"
          action: "get_replicas"
    
    - name: calculate-new-replicas
      provider:
        type: python
        with:
          code: |
            current = {{ steps.get-current-replicas.results.replicas }}
            usage = {{ alert.usage }}
            
            if usage > 90:
                new_replicas = min(current * 2, 20)
            elif usage > 80:
                new_replicas = min(current + 2, 20)
            else:
                new_replicas = current
            
            return {"new_replicas": new_replicas}
  
  actions:
    - name: scale-deployment
      if: "{{ steps.calculate-new-replicas.results.new_replicas > steps.get-current-replicas.results.replicas }}"
      provider:
        type: kubernetes
        with:
          namespace: "{{ alert.namespace }}"
          deployment: "{{ alert.deployment }}"
          action: "scale"
          replicas: "{{ steps.calculate-new-replicas.results.new_replicas }}"
    
    - name: notify-scaling
      provider:
        type: slack
        with:
          channel: "#ops"
          message: |
            📈 **자동 스케일링 실행**
            
            **서비스**: {{ alert.deployment }}
            **네임스페이스**: {{ alert.namespace }}
            **이전 replica**: {{ steps.get-current-replicas.results.replicas }}
            **새 replica**: {{ steps.calculate-new-replicas.results.new_replicas }}
            **CPU 사용률**: {{ alert.usage }}%
{% endraw %}
```

### 3. 로그 분석 및 이상 탐지

```yaml
{% raw %}
workflow:
  id: log-anomaly-detection
  description: 로그 패턴 분석을 통한 이상 탐지
  triggers:
    - type: schedule
      cron: "*/5 * * * *"  # 5분마다 실행
  
  steps:
    - name: fetch-error-logs
      provider:
        type: elasticsearch
        with:
          index: "app-logs-*"
          query: |
            {
              "query": {
                "bool": {
                  "must": [
                    {"term": {"level": "ERROR"}},
                    {"range": {"@timestamp": {"gte": "now-5m"}}}
                  ]
                }
              }
            }
    
    - name: analyze-patterns
      provider:
        type: python
        with:
          code: |
            import json
            from collections import Counter
            
            logs = {{ steps.fetch-error-logs.results.hits }}
            
            # 에러 패턴 분석
            error_patterns = Counter()
            for log in logs:
                error_patterns[log['_source']['message'][:100]] += 1
            
            # 임계값 초과 패턴 찾기
            anomalies = []
            for pattern, count in error_patterns.items():
                if count > 10:  # 5분 내 10회 이상 발생
                    anomalies.append({
                        "pattern": pattern,
                        "count": count
                    })
            
            return {"anomalies": anomalies}
  
  actions:
    - name: alert-anomalies
      if: "{{ steps.analyze-patterns.results.anomalies | length > 0 }}"
      provider:
        type: slack
        with:
          channel: "#alerts"
          message: |
            🔍 **로그 이상 패턴 탐지**
            
            지난 5분간 다음과 같은 이상 패턴이 감지되었습니다:
            
            {% for anomaly in steps.analyze-patterns.results.anomalies %}
            **패턴**: {{ anomaly.pattern }}
            **발생 횟수**: {{ anomaly.count }}
            ---
            {% endfor %}
    
    - name: create-investigation-ticket
      if: "{{ steps.analyze-patterns.results.anomalies | length > 3 }}"
      provider:
        type: jira
        with:
          project: "OPS"
          issuetype: "Investigation"
          summary: "로그 이상 패턴 조사 필요"
          description: |
            자동 로그 분석 결과 다음과 같은 이상 패턴들이 감지되었습니다:
            
            {{ steps.analyze-patterns.results | tojson }}
{% endraw %}
```

## Enterprise 기능 및 보안 설정

### 인증 및 권한 관리

#### SSO (Single Sign-On) 설정

```yaml
{% raw %}
# config/auth.yaml
auth:
  providers:
    - type: saml
      config:
        entity_id: "keep-production"
        sso_url: "https://your-idp.com/sso"
        x509_cert: "{{ env.SAML_CERT }}"
        attributes:
          email: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/emailaddress"
          name: "http://schemas.xmlsoap.org/ws/2005/05/identity/claims/name"
    
    - type: oidc
      config:
        client_id: "{{ env.OIDC_CLIENT_ID }}"
        client_secret: "{{ env.OIDC_CLIENT_SECRET }}"
        discovery_url: "https://your-provider.com/.well-known/openid-configuration"
        scopes: ["openid", "profile", "email"]
{% endraw %}
```

#### RBAC (Role-Based Access Control)

```yaml
# config/rbac.yaml
roles:
  admin:
    permissions:
      - "workflows:create"
      - "workflows:edit"
      - "workflows:delete"
      - "providers:manage"
      - "users:manage"
  
  operator:
    permissions:
      - "workflows:view"
      - "workflows:execute"
      - "alerts:manage"
      - "incidents:manage"
  
  viewer:
    permissions:
      - "workflows:view"
      - "alerts:view"
      - "incidents:view"

# 사용자 역할 할당
users:
  - email: "admin@company.com"
    roles: ["admin"]
  - email: "ops-team@company.com"
    roles: ["operator"]
  - email: "dev-team@company.com"
    roles: ["viewer"]
```

### 고가용성 및 스케일링

#### 클러스터 구성

```yaml
# docker-compose.ha.yaml
version: '3.8'
services:
  keep-server-1:
    image: keephq/keep:latest
    environment:
      - INSTANCE_ID=keep-1
      - REDIS_URL=redis://redis-cluster:6379
      - DATABASE_URL=postgresql://user:pass@postgres-primary:5432/keep
    deploy:
      replicas: 2
  
  keep-server-2:
    image: keephq/keep:latest
    environment:
      - INSTANCE_ID=keep-2
      - REDIS_URL=redis://redis-cluster:6379
      - DATABASE_URL=postgresql://user:pass@postgres-replica:5432/keep
    deploy:
      replicas: 2
  
  redis-cluster:
    image: redis:7-alpine
    command: redis-server --cluster-enabled yes
    deploy:
      replicas: 3
  
  postgres-primary:
    image: postgres:15
    environment:
      - POSTGRES_DB=keep
      - POSTGRES_USER=keep_user
      - POSTGRES_PASSWORD=secure_password
    volumes:
      - postgres_data:/var/lib/postgresql/data
  
  nginx-lb:
    image: nginx:alpine
    ports:
      - "80:80"
      - "443:443"
    volumes:
      - ./nginx.conf:/etc/nginx/nginx.conf
```

#### 성능 모니터링

```yaml
# monitoring/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: 'keep-metrics'
    static_configs:
      - targets: ['keep-server-1:8080', 'keep-server-2:8080']
    metrics_path: '/metrics'
    scrape_interval: 10s

  - job_name: 'keep-database'
    static_configs:
      - targets: ['postgres-exporter:9187']
```

### 보안 모범 사례

#### 시크릿 관리

```yaml
# secrets/vault-config.yaml
vault:
  address: "https://vault.company.com"
  auth_method: "kubernetes"
  role: "keep-production"
  
secrets:
  slack_webhook: "vault:secret/keep/slack#webhook_url"
  jira_token: "vault:secret/keep/jira#api_token"
  database_password: "vault:secret/keep/database#password"
```

#### 네트워크 보안

```yaml
# security/network-policy.yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: keep-network-policy
  namespace: keep-system
spec:
  podSelector:
    matchLabels:
      app: keep-server
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - namespaceSelector:
        matchLabels:
          name: ingress-nginx
    ports:
    - protocol: TCP
      port: 8080
  egress:
  - to:
    - namespaceSelector:
        matchLabels:
          name: postgres
    ports:
    - protocol: TCP
      port: 5432
```

## 고급 워크플로우 패턴

### 조건부 분기 처리

```yaml
{% raw %}
workflow:
  id: conditional-escalation
  description: 알림 심각도에 따른 조건부 에스컬레이션
  triggers:
    - type: alert
  
  actions:
    - name: level-1-notification
      if: "{{ alert.severity == 'warning' }}"
      provider:
        type: slack
        with:
          channel: "#monitoring"
          message: "⚠️ Warning: {{ alert.message }}"
    
    - name: level-2-notification
      if: "{{ alert.severity == 'critical' }}"
      provider:
        type: slack
        with:
          channel: "#incidents"
          message: "🚨 Critical: {{ alert.message }}"
    
    - name: page-oncall
      if: "{{ alert.severity == 'critical' and alert.service in ['payment', 'auth'] }}"
      provider:
        type: pagerduty
        with:
          service_key: "{{ alert.service }}_oncall"
          incident_key: "{{ alert.fingerprint }}"
    
    - name: executive-notification
      if: "{{ alert.severity == 'critical' and alert.duration > 300 }}"
      provider:
        type: email
        with:
          to: ["cto@company.com", "vp-engineering@company.com"]
          subject: "Critical System Alert - {{ alert.service }}"
          body: |
            A critical alert has been ongoing for over 5 minutes.
            
            Details:
            - Service: {{ alert.service }}
            - Duration: {{ alert.duration }}s
            - Message: {{ alert.message }}
{% endraw %}
```

### 루프 처리 및 배치 작업

```yaml
{% raw %}
workflow:
  id: batch-server-health-check
  description: 여러 서버의 상태를 배치로 확인
  triggers:
    - type: schedule
      cron: "0 */6 * * *"  # 6시간마다 실행
  
  steps:
    - name: get-server-list
      provider:
        type: kubernetes
        with:
          namespace: "production"
          resource: "nodes"
          action: "list"
    
    - name: check-server-health
      foreach: "{{ steps.get-server-list.results.nodes }}"
      provider:
        type: ssh
        with:
          host: "{{ item.ip }}"
          username: "monitoring"
          key: "{{ secrets.ssh_key }}"
          command: |
            echo "=== System Health Check ==="
            echo "CPU Usage: $(top -bn1 | grep 'Cpu(s)' | awk '{print $2}' | cut -d'%' -f1)"
            echo "Memory Usage: $(free | grep Mem | awk '{printf \"%.2f%%\", $3/$2 * 100.0}')"
            echo "Disk Usage: $(df -h | grep '/$' | awk '{print $5}')"
            echo "Load Average: $(uptime | awk -F'load average:' '{print $2}')"
  
  actions:
    - name: generate-health-report
      provider:
        type: python
        with:
          code: |
            import json
            from datetime import datetime
            
            servers = {{ steps.check-server-health.results }}
            
            report = {
                "timestamp": datetime.now().isoformat(),
                "total_servers": len(servers),
                "healthy_servers": 0,
                "unhealthy_servers": [],
                "summary": {}
            }
            
            for server in servers:
                # 서버 상태 분석 로직
                if server.get("success", False):
                    report["healthy_servers"] += 1
                else:
                    report["unhealthy_servers"].append({
                        "host": server["host"],
                        "error": server.get("error", "Unknown error")
                    })
            
            return report
    
    - name: send-health-report
      provider:
        type: slack
        with:
          channel: "#infrastructure"
          message: |
            📊 **서버 상태 점검 보고서**
            
            **점검 시간**: {{ steps.generate-health-report.results.timestamp }}
            **전체 서버**: {{ steps.generate-health-report.results.total_servers }}
            **정상 서버**: {{ steps.generate-health-report.results.healthy_servers }}
            **문제 서버**: {{ steps.generate-health-report.results.unhealthy_servers | length }}
            
            {% if steps.generate-health-report.results.unhealthy_servers | length > 0 %}
            **문제 서버 목록**:
            {% for server in steps.generate-health-report.results.unhealthy_servers %}
            - {{ server.host }}: {{ server.error }}
            {% endfor %}
            {% endif %}
{% endraw %}
```

### 다중 환경 관리

```yaml
{% raw %}
# workflows/multi-env-deployment.yaml
workflow:
  id: multi-env-deployment
  description: 다중 환경 배포 자동화
  triggers:
    - type: webhook
      config:
        path: "/deploy"
        method: "POST"
  
  steps:
    - name: validate-deployment
      provider:
        type: python
        with:
          code: |
            import json
            
            payload = {{ trigger.body }}
            
            # 필수 필드 검증
            required_fields = ["service", "version", "environments"]
            for field in required_fields:
                if field not in payload:
                    raise ValueError(f"Missing required field: {field}")
            
            # 환경 순서 검증
            valid_order = ["development", "staging", "production"]
            environments = payload["environments"]
            
            if not all(env in valid_order for env in environments):
                raise ValueError("Invalid environment specified")
            
            return {
                "service": payload["service"],
                "version": payload["version"],
                "environments": environments
            }
    
    - name: deploy-to-environment
      foreach: "{{ steps.validate-deployment.results.environments }}"
      provider:
        type: kubernetes
        with:
          namespace: "{{ item }}"
          resource: "deployment"
          name: "{{ steps.validate-deployment.results.service }}"
          action: "update"
          spec:
            containers:
              - name: "{{ steps.validate-deployment.results.service }}"
                image: "registry.company.com/{{ steps.validate-deployment.results.service }}:{{ steps.validate-deployment.results.version }}"
    
    - name: run-health-check
      foreach: "{{ steps.validate-deployment.results.environments }}"
      provider:
        type: http
        with:
          url: "https://{{ steps.validate-deployment.results.service }}.{{ item }}.company.com/health"
          method: "GET"
          timeout: 30
          retries: 3
  
  actions:
    - name: notify-success
      if: "{{ steps.deploy-to-environment.success and steps.run-health-check.success }}"
      provider:
        type: slack
        with:
          channel: "#deployments"
          message: |
            ✅ **배포 성공**
            
            **서비스**: {{ steps.validate-deployment.results.service }}
            **버전**: {{ steps.validate-deployment.results.version }}
            **환경**: {{ steps.validate-deployment.results.environments | join(', ') }}
            
            모든 환경에서 상태 확인이 완료되었습니다.
    
    - name: notify-failure
      if: "{{ not (steps.deploy-to-environment.success and steps.run-health-check.success) }}"
      provider:
        type: slack
        with:
          channel: "#deployments"
          message: |
            ❌ **배포 실패**
            
            **서비스**: {{ steps.validate-deployment.results.service }}
            **버전**: {{ steps.validate-deployment.results.version }}
            
            **실패한 단계**:
            {% if not steps.deploy-to-environment.success %}
            - 배포 단계
            {% endif %}
            {% if not steps.run-health-check.success %}
            - 상태 확인 단계
            {% endif %}
            
            자세한 로그를 확인하고 수동으로 롤백을 진행하세요.
{% endraw %}
```

## 모범 사례 및 최적화

### 성능 최적화

#### 워크플로우 최적화

```yaml
{% raw %}
# Best practices for workflow optimization
workflow:
  id: optimized-workflow
  description: 성능 최적화된 워크플로우 예시
  
  # 1. 적절한 타임아웃 설정
  timeout: 300  # 5분
  
  # 2. 재시도 정책 설정
  retry:
    max_attempts: 3
    backoff_factor: 2
    
  steps:
    # 3. 병렬 처리 활용
    - name: parallel-checks
      parallel:
        - name: check-database
          provider:
            type: postgres
            with:
              query: "SELECT 1"
        - name: check-cache
          provider:
            type: redis
            with:
              command: "ping"
        - name: check-external-api
          provider:
            type: http
            with:
              url: "https://api.external.com/health"
    
    # 4. 조건부 실행으로 불필요한 작업 방지
    - name: detailed-analysis
      if: "{{ steps.parallel-checks.results.check-database.success == false }}"
      provider:
        type: bash
        with:
          command: "pg_stat_activity analysis script"
{% endraw %}
```

#### 리소스 관리

```yaml
# docker-compose.optimized.yaml
version: '3.8'
services:
  keep-server:
    image: keephq/keep:latest
    environment:
      # 워커 프로세스 수 조정
      - WORKERS=4
      # 메모리 제한 설정
      - MAX_MEMORY=2G
      # 연결 풀 크기 조정
      - DB_POOL_SIZE=20
      - REDIS_POOL_SIZE=10
    deploy:
      resources:
        limits:
          memory: 2G
          cpus: '2'
        reservations:
          memory: 1G
          cpus: '1'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3
```

### 보안 모범 사례

#### 시크릿 로테이션

```yaml
{% raw %}
workflow:
  id: secret-rotation
  description: 주기적 시크릿 로테이션
  triggers:
    - type: schedule
      cron: "0 2 1 * *"  # 매월 1일 오전 2시
  
  steps:
    - name: rotate-api-keys
      provider:
        type: vault
        with:
          action: "rotate"
          secrets:
            - "secret/keep/slack"
            - "secret/keep/jira"
            - "secret/keep/pagerduty"
    
    - name: update-provider-configs
      provider:
        type: python
        with:
          code: |
            # 새로운 시크릿으로 provider 설정 업데이트
            import requests
            
            new_secrets = {{ steps.rotate-api-keys.results }}
            
            # Keep API를 통해 provider 설정 업데이트
            for secret_name, secret_value in new_secrets.items():
                requests.put(
                    f"http://keep-api:8080/providers/{secret_name}",
                    json={"config": {"token": secret_value}},
                    headers={"Authorization": f"Bearer {api_token}"}
                )
  
  actions:
    - name: notify-rotation-complete
      provider:
        type: slack
        with:
          channel: "#security"
          message: |
            🔐 **시크릿 로테이션 완료**
            
            다음 시크릿들이 성공적으로 로테이션되었습니다:
            {% for secret in steps.rotate-api-keys.results.keys() %}
            - {{ secret }}
            {% endfor %}
{% endraw %}
```

## 트러블슈팅 가이드

### 일반적인 문제들

#### 1. 워크플로우 실행 실패

```bash
# 로그 확인
docker-compose logs keep-server

# 워크플로우 상태 확인
curl -H "Authorization: Bearer $API_TOKEN" \
  http://localhost:8080/workflows/sentry-alerts/executions

# 디버그 모드로 실행
docker-compose -f docker-compose.debug.yaml up
```

#### 2. Provider 연결 문제

```python
# provider 테스트 스크립트
import requests
import json

def test_provider(provider_name, config):
    response = requests.post(
        f"http://localhost:8080/providers/{provider_name}/test",
        json={"config": config},
        headers={"Authorization": f"Bearer {api_token}"}
    )
    
    if response.status_code == 200:
        print(f"✅ {provider_name} 연결 성공")
    else:
        print(f"❌ {provider_name} 연결 실패: {response.text}")

# 주요 provider 테스트
test_provider("slack", {"webhook_url": "https://hooks.slack.com/..."})
test_provider("jira", {"url": "https://company.atlassian.net", "username": "...", "password": "..."})
```

#### 3. 성능 문제 진단

```yaml
{% raw %}
# 성능 모니터링 워크플로우
workflow:
  id: performance-monitoring
  description: Keep 성능 모니터링
  triggers:
    - type: schedule
      cron: "*/15 * * * *"  # 15분마다
  
  steps:
    - name: check-metrics
      provider:
        type: prometheus
        with:
          queries:
            - "keep_workflow_execution_duration_seconds"
            - "keep_workflow_execution_total"
            - "keep_active_workflows"
            - "keep_memory_usage_bytes"
  
  actions:
    - name: alert-performance-issues
      if: "{{ steps.check-metrics.results.keep_workflow_execution_duration_seconds.value > 60 }}"
      provider:
        type: slack
        with:
          channel: "#ops"
          message: |
            ⚠️ **Keep 성능 이슈 감지**
            
            **평균 실행 시간**: {{ steps.check-metrics.results.keep_workflow_execution_duration_seconds.value }}초
            **메모리 사용량**: {{ steps.check-metrics.results.keep_memory_usage_bytes.value | filesizeformat }}
            **활성 워크플로우**: {{ steps.check-metrics.results.keep_active_workflows.value }}
{% endraw %}
```

## 결론

Keep은 현대적인 IT 환경에서 필수적인 **AIOps 및 알림 관리 자동화**를 위한 강력한 오픈소스 플랫폼입니다. 이 가이드를 통해 다음과 같은 핵심 사항들을 학습했습니다:

### 🚀 핵심 장점

1. **워크플로우 기반 자동화**: YAML로 정의된 직관적인 워크플로우
2. **광범위한 통합**: 100+ provider를 통한 모니터링 생태계 연결
3. **Enterprise-ready**: 대규모 환경에서의 안정적인 운영
4. **개발자 친화적**: 현대적인 API와 포괄적인 문서화

### 🛠️ 실무 적용 전략

1. **단계적 도입**: 간단한 알림 워크플로우부터 시작
2. **점진적 확장**: 성공적인 패턴을 다른 서비스로 확장
3. **모니터링 중심**: 워크플로우 자체의 성능과 안정성 모니터링
4. **팀 협업**: 개발, 운영, 보안 팀 간의 협력적 접근

### 🔮 향후 방향

Keep을 도입함으로써 다음과 같은 이점을 기대할 수 있습니다:

- **MTTR 단축**: 자동화된 인시던트 대응으로 복구 시간 단축
- **운영 효율성**: 반복적인 작업의 자동화로 인력 절약
- **일관성 향상**: 표준화된 프로세스를 통한 품질 개선
- **가시성 증대**: 통합된 모니터링과 알림으로 시스템 투명성 향상

Keep과 같은 AIOps 플랫폼의 도입은 단순한 도구 사용을 넘어서, **조직의 운영 문화를 자동화와 데이터 기반 의사결정으로 변화**시키는 중요한 전환점이 될 것입니다.

지금 바로 [Keep GitHub Repository](https://github.com/keephq/keep)에서 프로젝트를 시작하고, 여러분의 모니터링 환경을 혁신해보세요!

---

**관련 글:**
- [Prometheus 모니터링 완벽 가이드](https://thakicloud.com/tech-blog/tutorials/prometheus-monitoring-guide/)
- [Grafana 대시보드 구축하기](https://thakicloud.com/tech-blog/tutorials/grafana-dashboard-guide/)
- [Kubernetes 모니터링 최적화](https://thakicloud.com/tech-blog/dev/kubernetes-monitoring-optimization/) 