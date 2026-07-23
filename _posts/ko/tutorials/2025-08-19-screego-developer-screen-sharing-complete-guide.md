---
title: "Screego: 개발자를 위한 고품질 스크린 공유 서버 완벽 가이드 - 실시간 WebRTC 기반 자체 호스팅"
excerpt: "낮은 지연시간과 고해상도를 자랑하는 Screego 스크린 공유 서버를 Docker로 쉽게 구축하고, 개발팀의 원격 협업을 위한 완벽한 솔루션을 만들어보세요."
seo_title: "Screego 스크린 공유 서버 구축 가이드 - WebRTC 개발자 도구 - Thaki Cloud"
seo_description: "Screego를 활용한 개발자 전용 스크린 공유 서버 구축 방법. Docker 설치부터 WebRTC 설정, TURN 서버 구성까지 실무 중심의 완벽 가이드. 고품질 화면 공유 솔루션"
date: 2025-08-19
last_modified_at: 2025-08-19
tags:
  - screego
  - screen-sharing
  - webrtc
  - docker
  - self-hosted
  - remote-work
  - developer-tools
  - golang
  - turn-server
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/tutorials/screego-developer-screen-sharing-complete-guide/"
reading_time: true
published: false
categories:
  - tutorials
---

⏱️ **예상 읽기 시간**: 15분

## 서론

원격 개발 협업에서 가장 중요한 것 중 하나는 고품질 스크린 공유입니다. Microsoft Teams나 Zoom 같은 기업용 솔루션들은 종종 지연시간이 길거나 화질이 떨어져 코드 리뷰나 디버깅 세션에서 아쉬움을 남깁니다.

**Screego**는 이런 문제를 해결하기 위해 만들어진 개발자 중심의 스크린 공유 서버입니다. WebRTC 기술을 기반으로 낮은 지연시간과 고해상도를 제공하며, 자체 호스팅이 가능해 보안과 프라이버시를 완벽하게 통제할 수 있습니다.

### 왜 Screego인가?

- 🚀 **낮은 지연시간**: WebRTC P2P 연결로 실시간 화면 공유
- 🔒 **자체 호스팅**: 민감한 코드나 데이터가 외부로 나가지 않음
- 💻 **개발자 친화적**: 단순하고 깔끔한 인터페이스
- 🐳 **간편한 배포**: Docker 컨테이너로 5분 내 구축
- 🌐 **통합 TURN 서버**: NAT 통과 문제 자동 해결
- 👥 **다중 사용자**: 여러 명이 동시에 화면 공유 가능

## 시스템 요구사항

### 최소 요구사항

- **운영체제**: Linux, macOS, Windows (Docker 지원)
- **Docker**: 20.10+
- **Docker Compose**: 2.0+
- **메모리**: 최소 512MB (권장 1GB+)
- **네트워크**: 인터넷 연결 (TURN 서버용)

### 권장 사양

- **CPU**: 2코어 이상
- **메모리**: 2GB 이상
- **디스크**: 10GB 이상 여유 공간
- **대역폭**: 업로드 10Mbps 이상

### 포트 요구사항

- **5050**: 웹 인터페이스 (기본값)
- **3478**: TURN 서버 포트
- **UDP 포트 범위**: 49152-65535 (WebRTC 미디어 전송용)

## Screego 소개

### 핵심 특징

Screego는 Go 언어로 개발된 경량 스크린 공유 서버로, 다음과 같은 특징을 가지고 있습니다:

1. **WebRTC 기반**: 브라우저 네이티브 기술로 높은 성능
2. **P2P 연결**: 서버 부하 최소화
3. **통합 TURN 서버**: NAT/방화벽 문제 자동 해결
4. **사용자 관리**: 간단한 파일 기반 인증
5. **보안 중심**: HTTPS, TURN 인증 지원

### 아키텍처 구성

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
<div class="d3-arch" data-arch-root id="reensharingcompleteguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 1024, "height": 561, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [{"x": 60, "y": 24, "w": 899, "h": 124, "label": "클라이언트 브라우저들", "lx": 72, "ly": 42}, {"x": 519, "y": 226, "w": 471, "h": 303, "label": "Screego 서버", "lx": 531, "ly": 244}, {"x": 24, "y": 226, "w": 475, "h": 140, "label": "P2P 연결", "lx": 36, "ly": 244}], "nodes": [{"id": "C1", "x": 164, "y": 63, "w": 120, "h": 46, "title": "발표자 브라우저"}, {"id": "C2", "x": 489, "y": 63, "w": 120, "h": 46, "title": "참가자 브라우저 1"}, {"id": "C3", "x": 747, "y": 63, "w": 120, "h": 46, "title": "참가자 브라우저 2"}, {"id": "WS", "x": 733, "y": 265, "w": 120, "h": 62, "title": ["웹 서버", "Port 5050"]}, {"id": "TURN", "x": 558, "y": 265, "w": 120, "h": 62, "title": ["TURN 서버", "Port 3478"]}, {"id": "AUTH", "x": 833, "y": 444, "w": 120, "h": 46, "title": "인증 시스템"}, {"id": "ROOM", "x": 647, "y": 444, "w": 120, "h": 46, "title": "방 관리"}, {"id": "RTC1", "x": 252, "y": 273, "w": 135, "h": 46, "title": "WebRTC Stream 1"}, {"id": "RTC2", "x": 62, "y": 273, "w": 135, "h": 46, "title": "WebRTC Stream 2"}], "edges": [{"src": "C1", "dst": "WS", "kind": "data", "curve": [[284, 104], [432, 148], [665, 226], [736, 265]]}, {"src": "C2", "dst": "WS", "kind": "data", "curve": [[578, 109], [627, 148], [793, 226], [793, 265]]}, {"src": "C3", "dst": "WS", "kind": "data", "curve": [[841, 109], [900, 148], [900, 226], [840, 265]]}, {"src": "WS", "dst": "AUTH", "kind": "data", "curve": [[837, 327], [893, 366], [893, 405], [893, 444]]}, {"src": "WS", "dst": "ROOM", "kind": "data", "curve": [[755, 327], [707, 366], [707, 405], [707, 444]]}, {"src": "C1", "dst": "TURN", "kind": "event", "curve": [[284, 106], [412, 148], [590, 226], [606, 265]]}, {"src": "C2", "dst": "TURN", "kind": "event", "curve": [[542, 109], [529, 148], [685, 226], [648, 265]]}, {"src": "C3", "dst": "TURN", "kind": "event", "curve": [[813, 109], [823, 148], [823, 226], [678, 276]]}, {"src": "C1", "dst": "RTC1", "kind": "event", "curve": [[228, 109], [234, 148], [234, 226], [291, 273]]}, {"src": "C2", "dst": "RTC1", "kind": "event", "curve": [[513, 109], [452, 148], [349, 226], [329, 273]]}, {"src": "C1", "dst": "RTC2", "kind": "event", "curve": [[189, 109], [129, 148], [129, 226], [129, 273]]}, {"src": "C3", "dst": "RTC2", "kind": "event", "curve": [[747, 109], [647, 148], [372, 226], [197, 277]]}]});
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
      const container = document.getElementById('reensharingcompleteguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'reensharingcompleteguide-1';
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

### 기술 스택

- **백엔드**: Go (Golang)
- **프론트엔드**: TypeScript, WebRTC
- **컨테이너**: Docker
- **프로토콜**: WebRTC, TURN/STUN
- **인증**: 파일 기반 사용자 관리

## 설치 및 환경 준비

### 1. Docker 환경 준비

macOS에서 Docker Desktop이 설치되어 있는지 확인합니다:

```bash
# Docker 버전 확인
docker --version
docker-compose --version

# Docker 데몬 실행 상태 확인
docker info
```

### 2. 프로젝트 디렉토리 생성

```bash
# Screego 프로젝트 디렉토리 생성
mkdir -p ~/screego-server
cd ~/screego-server

# 설정 및 데이터 디렉토리 생성
mkdir -p config data certs
```

### 3. Docker Compose 설정

`docker-compose.yml` 파일을 생성합니다:

```yaml
version: '3.8'

services:
  screego:
    image: screego/server:latest
    container_name: screego-server
    ports:
      - "5050:5050"
      - "3478:3478/udp"
    environment:
      # 기본 서버 설정
      SCREEGO_EXTERNAL_IP: localhost
      SCREEGO_SECRET: "change-this-super-secret-key-2025"
      SCREEGO_CHECK_ORIGIN: false
      SCREEGO_LOG_LEVEL: info
      
      # TURN 서버 설정 (NAT 통과용)
      SCREEGO_TURN_EXTERNAL_IP: localhost
      SCREEGO_TURN_PORT: 3478
      SCREEGO_TURN_STRICT_AUTH: false
      
      # 사용자 인증 설정
      SCREEGO_AUTH_MODE: turn
      SCREEGO_USERS_FILE: /config/users
    volumes:
      - ./config:/config
      - ./data:/data
    restart: unless-stopped
    networks:
      - screego-network

networks:
  screego-network:
    driver: bridge
```

### 4. 사용자 설정 파일 생성

`config/users` 파일을 생성하여 접근 가능한 사용자를 정의합니다:

```bash
# 사용자 파일 생성
cat > config/users << 'EOF'
# Screego 사용자 설정
# 형식: username:password
admin:secure-admin-password
dev1:dev-password-123
dev2:another-password
team:team-collaboration-key
EOF
```

## 서버 실행 및 설정

### 1. Screego 서버 시작

```bash
# 서버 시작
docker-compose up -d

# 서비스 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f screego
```

### 2. 서비스 접근 확인

```bash
# 웹 서비스 확인
curl -I http://localhost:5050

# 브라우저에서 접속
open http://localhost:5050  # macOS
```

### 3. 자동 설정 스크립트

편의를 위해 자동 설정 스크립트를 생성할 수 있습니다:

```bash
#!/bin/bash
# setup-screego.sh

set -e

echo "🎯 Screego 서버 자동 설정 시작..."

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

# Docker 확인
if ! command -v docker &> /dev/null; then
    echo "Docker가 설치되어 있지 않습니다."
    exit 1
fi

# 디렉토리 생성
print_status "설정 디렉토리 생성 중..."
mkdir -p config data

# 사용자 파일 생성
print_status "사용자 설정 파일 생성 중..."
cat > config/users << 'EOF'
admin:admin123
demo:demo123
team:team123
EOF

# 서버 시작
print_status "Screego 서버 시작 중..."
docker-compose up -d

print_success "설정 완료! http://localhost:5050 에서 접속하세요."

echo ""
echo "📋 테스트 계정:"
echo "  - admin / admin123"
echo "  - demo / demo123"
echo "  - team / team123"
```

## 프로덕션 환경 설정

### 1. 도메인 및 HTTPS 설정

프로덕션 환경에서는 HTTPS가 필요합니다. Let's Encrypt를 사용한 설정:

```yaml
version: '3.8'

services:
  screego:
    image: screego/server:latest
    container_name: screego-prod
    ports:
      - "443:5050"
      - "3478:3478/udp"
    environment:
      SCREEGO_EXTERNAL_IP: yourdomain.com
      SCREEGO_SECRET: "production-super-secret-key"
      SCREEGO_CHECK_ORIGIN: true
      SCREEGO_LOG_LEVEL: warn
      
      # TLS 설정
      SCREEGO_TLS_CERT_FILE: /certs/fullchain.pem
      SCREEGO_TLS_KEY_FILE: /certs/privkey.pem
      
      # TURN 서버 설정
      SCREEGO_TURN_EXTERNAL_IP: yourdomain.com
      SCREEGO_TURN_PORT: 3478
      SCREEGO_TURN_STRICT_AUTH: true
      SCREEGO_TURN_USERNAME: turn-user
      SCREEGO_TURN_PASSWORD: secure-turn-password
      
      # 인증 설정
      SCREEGO_AUTH_MODE: turn
      SCREEGO_USERS_FILE: /config/users
      
      # CORS 설정
      SCREEGO_CORS_ALLOWED_ORIGINS: https://yourdomain.com
    volumes:
      - ./config:/config
      - ./data:/data
      - /etc/letsencrypt/live/yourdomain.com:/certs:ro
    restart: unless-stopped
```

### 2. Nginx 리버스 프록시 설정

Nginx를 통한 프록시 설정 예제:

```nginx
server {
    listen 443 ssl http2;
    server_name screego.yourdomain.com;
    
    ssl_certificate /etc/letsencrypt/live/screego.yourdomain.com/fullchain.pem;
    ssl_certificate_key /etc/letsencrypt/live/screego.yourdomain.com/privkey.pem;
    
    location / {
        proxy_pass http://localhost:5050;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # WebSocket 지원
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
    }
}
```

### 3. 방화벽 설정

필요한 포트를 열어줍니다:

```bash
# UFW 방화벽 설정 (Ubuntu)
sudo ufw allow 5050/tcp
sudo ufw allow 3478/udp
sudo ufw allow 49152:65535/udp  # WebRTC 미디어 포트

# iptables 설정
sudo iptables -A INPUT -p tcp --dport 5050 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 3478 -j ACCEPT
sudo iptables -A INPUT -p udp --dport 49152:65535 -j ACCEPT
```

## 사용법 및 기능

### 1. 웹 인터페이스 접속

1. 브라우저에서 `http://localhost:5050` 접속
2. 설정한 사용자 계정으로 로그인
3. 새 방 생성 또는 기존 방 참여

### 2. 화면 공유 시작

**발표자 (스크린 공유하는 사람)**:
1. "Create Room" 버튼 클릭
2. 방 이름 입력 (예: "code-review-session")
3. "Share Screen" 버튼 클릭
4. 공유할 화면/창/탭 선택
5. 방 URL을 참가자들에게 공유

**참가자 (화면을 보는 사람)**:
1. 공유받은 방 URL로 접속
2. 동일한 사용자 계정으로 로그인
3. 자동으로 발표자의 화면이 표시됨

### 3. 고급 기능

**다중 발표자**:
- 한 방에서 여러 명이 동시에 화면 공유 가능
- 각 스트림이 개별 창으로 표시

**화질 조정**:
- 네트워크 상황에 따라 자동 품질 조정
- 수동으로 해상도 및 프레임레이트 설정 가능

**권한 관리**:
- 방 생성자가 참가자 권한 제어
- 화면 공유 허용/차단 설정

### 4. 모바일 지원

Screego는 모바일 브라우저에서도 동작합니다:

- **iOS Safari**: 화면 공유 지원 (iOS 15+)
- **Android Chrome**: 완전 지원
- **모바일 최적화**: 터치 인터페이스 지원

## 설정 옵션 상세

### 환경 변수 전체 목록

```bash
# 기본 서버 설정
SCREEGO_EXTERNAL_IP=localhost           # 외부 접속 IP
SCREEGO_PORT=5050                       # 웹 서버 포트
SCREEGO_SECRET=your-secret-key          # JWT 토큰 암호화 키
SCREEGO_LOG_LEVEL=info                  # 로그 레벨 (debug, info, warn, error)

# 인증 설정
SCREEGO_AUTH_MODE=turn                  # 인증 모드 (turn, none)
SCREEGO_USERS_FILE=/config/users        # 사용자 파일 경로
SCREEGO_CHECK_ORIGIN=true               # Origin 헤더 검증

# TURN 서버 설정
SCREEGO_TURN_EXTERNAL_IP=your-ip        # TURN 서버 외부 IP
SCREEGO_TURN_PORT=3478                  # TURN 서버 포트
SCREEGO_TURN_STRICT_AUTH=true           # TURN 인증 강제
SCREEGO_TURN_USERNAME=turn-user         # TURN 사용자명
SCREEGO_TURN_PASSWORD=turn-pass         # TURN 비밀번호

# TLS 설정
SCREEGO_TLS_CERT_FILE=/certs/cert.pem   # TLS 인증서 파일
SCREEGO_TLS_KEY_FILE=/certs/key.pem     # TLS 개인키 파일

# CORS 설정
SCREEGO_CORS_ALLOWED_ORIGINS=*          # 허용할 Origin 목록

# 방 설정
SCREEGO_ROOM_TIMEOUT=24h                # 방 타임아웃
SCREEGO_MAX_ROOM_SIZE=10                # 방 최대 인원

# 성능 설정
SCREEGO_MAX_BITRATE=5000                # 최대 비트레이트 (kbps)
```

### 사용자 파일 형식

`config/users` 파일은 다음 형식을 사용합니다:

```
# 주석은 #으로 시작
username1:password1
username2:password2
admin:very-secure-password

# 팀별 계정 예제
frontend-team:frontend-2025
backend-team:backend-secure
devops-team:devops-tools
```

### 로그 레벨 설정

```bash
# 개발 환경: 상세한 디버그 정보
SCREEGO_LOG_LEVEL=debug

# 프로덕션 환경: 필요한 정보만
SCREEGO_LOG_LEVEL=warn

# 문제 해결시: 모든 정보
SCREEGO_LOG_LEVEL=debug
```

## 문제 해결

### 1. 일반적인 문제들

**연결이 안 되는 경우**:
```bash
# 포트 확인
netstat -tulpn | grep :5050
netstat -tulpn | grep :3478

# 방화벽 상태 확인
sudo ufw status
```

**화면 공유가 시작되지 않는 경우**:
- 브라우저가 HTTPS를 요구하는지 확인
- 마이크/카메라 권한이 필요할 수 있음
- 브라우저 개발자 도구에서 오류 메시지 확인

**WebRTC 연결 실패**:
```bash
# TURN 서버 로그 확인
docker-compose logs screego | grep -i turn

# ICE 연결 상태 확인 (브라우저 개발자 도구)
# about:webrtc (Firefox) 또는 chrome://webrtc-internals (Chrome)
```

### 2. 네트워크 문제 해결

**NAT 통과 문제**:
```yaml
# docker-compose.yml에서 TURN 설정 강화
environment:
  SCREEGO_TURN_STRICT_AUTH: true
  SCREEGO_TURN_USERNAME: secure-turn-user
  SCREEGO_TURN_PASSWORD: very-secure-turn-password
```

**기업 방화벽 환경**:
```bash
# 추가 포트 범위 개방 필요
sudo ufw allow 49152:65535/udp
```

### 3. 성능 최적화

**높은 CPU 사용률**:
```yaml
# 컨테이너 리소스 제한
services:
  screego:
    deploy:
      resources:
        limits:
          cpus: '2.0'
          memory: 1G
        reservations:
          cpus: '0.5'
          memory: 512M
```

**네트워크 대역폭 최적화**:
```bash
# 비트레이트 조정
SCREEGO_MAX_BITRATE=2000  # 낮은 대역폭 환경
SCREEGO_MAX_BITRATE=8000  # 고품질 환경
```

### 4. 디버깅 도구

**연결 상태 확인**:
```bash
# 실시간 연결 모니터링
docker-compose logs -f screego | grep -E "(connect|disconnect|error)"

# 네트워크 트래픽 확인
netstat -i
iftop -i docker0
```

**WebRTC 상태 확인**:
- Chrome: `chrome://webrtc-internals`
- Firefox: `about:webrtc`
- 연결 상태, 비트레이트, 패킷 손실률 등 확인 가능

## 실무 활용 사례

### 1. 개발팀 코드 리뷰

```bash
# 코드 리뷰 전용 설정
cat > config/users << 'EOF'
senior-dev:code-review-lead
junior-dev1:review-participant
junior-dev2:review-participant
product-owner:review-observer
EOF
```

**활용 방법**:
1. 시니어 개발자가 방 생성
2. 코드 에디터 화면 공유
3. 실시간으로 코드 설명 및 피드백
4. 참가자들이 질문 및 토론

### 2. 버그 재현 및 디버깅

```bash
# 디버깅 세션 예제
# 방 이름: "bug-reproduction-issue-1234"
```

**워크플로우**:
1. QA가 버그 재현 과정 화면 공유
2. 개발자가 실시간으로 관찰
3. 디버깅 도구 사용 과정 공유
4. 해결 과정 문서화

### 3. 기술 교육 및 멘토링

```yaml
# 교육용 설정 - 더 많은 참가자 허용
environment:
  SCREEGO_MAX_ROOM_SIZE: 20
  SCREEGO_ROOM_TIMEOUT: 4h
```

**교육 시나리오**:
- 새로운 기술 스택 소개
- 개발 환경 설정 가이드
- 실시간 코딩 세션
- 아키텍처 설계 워크샵

### 4. 고객 지원 및 데모

```bash
# 고객 지원용 계정
cat > config/users << 'EOF'
support-agent:customer-help-2025
customer-demo:demo-account
sales-engineer:sales-demo-lead
EOF
```

## 모니터링 및 관리

### 1. 로그 관리

```yaml
# 로그 로테이션 설정
services:
  screego:
    logging:
      driver: "json-file"
      options:
        max-size: "10m"
        max-file: "3"
```

### 2. 헬스 체크

```bash
#!/bin/bash
# health-check.sh

# 웹 서비스 확인
if curl -f http://localhost:5050/health > /dev/null 2>&1; then
    echo "✅ Screego 웹 서비스 정상"
else
    echo "❌ Screego 웹 서비스 문제 발생"
    docker-compose restart screego
fi

# TURN 서버 확인
if netstat -ulpn | grep -q :3478; then
    echo "✅ TURN 서버 정상"
else
    echo "❌ TURN 서버 문제 발생"
fi
```

### 3. 자동 백업

```bash
#!/bin/bash
# backup-screego.sh

BACKUP_DIR="/backups/screego/$(date +%Y%m%d)"
mkdir -p "$BACKUP_DIR"

# 설정 파일 백업
cp -r config/ "$BACKUP_DIR/"

# 데이터 백업 (필요시)
cp -r data/ "$BACKUP_DIR/"

echo "백업 완료: $BACKUP_DIR"
```

## zsh Aliases 설정

생산성 향상을 위한 편리한 명령어 aliases:

```bash
# ~/.zshrc에 추가할 Screego 관련 aliases

# 기본 관리 명령어
alias screego-start='cd ~/screego-server && docker-compose up -d'
alias screego-stop='cd ~/screego-server && docker-compose down'
alias screego-restart='cd ~/screego-server && docker-compose restart'
alias screego-logs='cd ~/screego-server && docker-compose logs -f'
alias screego-status='cd ~/screego-server && docker-compose ps'

# 업데이트 및 관리
alias screego-update='cd ~/screego-server && docker-compose pull && docker-compose up -d'
alias screego-clean='cd ~/screego-server && docker-compose down -v && docker system prune -f'

# 설정 관리
alias screego-config='cd ~/screego-server && code config/users'
alias screego-backup='cd ~/screego-server && tar -czf screego-backup-$(date +%Y%m%d).tar.gz config/ data/'

# 디버깅
alias screego-debug='cd ~/screego-server && docker-compose logs screego | tail -100'
alias screego-health='curl -s http://localhost:5050/health || echo "서비스 응답 없음"'

# 빠른 접속
alias screego-open='open http://localhost:5050'

# 네트워크 진단
alias screego-ports='netstat -tulpn | grep -E "(5050|3478)"'
alias screego-connections='netstat -an | grep -E "(5050|3478)" | wc -l'
```

aliases 적용 방법:

```bash
# aliases 파일 생성
cat > ~/screego-aliases.sh << 'EOF'
# Screego 관리 aliases
alias screego-start='cd ~/screego-server && docker-compose up -d'
# ... (위의 모든 aliases)
EOF

# .zshrc에 추가
echo "source ~/screego-aliases.sh" >> ~/.zshrc

# 즉시 적용
source ~/.zshrc
```

## 보안 고려사항

### 1. 사용자 인증 강화

```bash
# 강력한 비밀번호 생성
openssl rand -base64 32

# 사용자 파일 보안 설정
chmod 600 config/users
chown root:root config/users
```

### 2. 네트워크 보안

```yaml
# 내부 네트워크만 허용하는 설정
environment:
  SCREEGO_CORS_ALLOWED_ORIGINS: "https://internal.company.com"
  SCREEGO_CHECK_ORIGIN: true
```

### 3. 컨테이너 보안

```yaml
# 보안 강화된 컨테이너 설정
services:
  screego:
    security_opt:
      - no-new-privileges:true
    read_only: true
    tmpfs:
      - /tmp
    user: "1000:1000"
```

## 결론

Screego는 개발팀의 원격 협업을 위한 완벽한 스크린 공유 솔루션입니다. WebRTC 기반의 P2P 연결로 낮은 지연시간과 고품질을 제공하며, 자체 호스팅을 통해 보안과 프라이버시를 완벽하게 통제할 수 있습니다.

### 주요 장점 요약

- **🚀 성능**: WebRTC P2P 연결로 실시간 화면 공유
- **🔒 보안**: 민감한 데이터가 외부로 나가지 않는 자체 호스팅
- **💻 편의성**: Docker로 5분 내 구축 가능
- **🌐 호환성**: 모든 모던 브라우저에서 동작
- **👥 확장성**: 다중 사용자 및 방 관리 지원

### 다음 단계

1. **기본 설치**: Docker Compose로 로컬 환경 구축
2. **팀 도입**: 개발팀 내부 테스트 진행
3. **프로덕션 배포**: HTTPS 및 도메인 설정으로 본격 운영
4. **워크플로우 통합**: CI/CD, 이슈 트래킹 시스템과 연동

Screego를 통해 더 효율적이고 안전한 개발팀 협업 환경을 구축해보세요. 코드 리뷰부터 기술 교육까지, 모든 화면 공유 요구사항을 만족하는 완벽한 솔루션이 될 것입니다.

### 참고 자료

- **공식 문서**: [screego.net](https://screego.net/)
- **GitHub 저장소**: [screego/server](https://github.com/screego/server)
- **WebRTC 가이드**: [webrtc.org](https://webrtc.org/)
- **Docker 공식 문서**: [docs.docker.com](https://docs.docker.com/)

