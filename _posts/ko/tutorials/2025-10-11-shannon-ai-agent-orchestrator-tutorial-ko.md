---
title: "Shannon AI Agent Orchestrator: 엔터프라이즈급 AI 에이전트 관리 완전 가이드"
excerpt: "엔터프라이즈급 보안, 비용 제어, 벤더 유연성을 제공하는 오픈소스 AI 에이전트 오케스트레이터 Shannon의 설치부터 고급 멀티 에이전트 워크플로우까지 완전한 가이드를 제공합니다."
seo_title: "Shannon AI Agent Orchestrator 튜토리얼 - 엔터프라이즈 AI 에이전트 관리"
seo_description: "Shannon AI Agent Orchestrator 완전 튜토리얼: 설치, 구성, 멀티 에이전트 워크플로우, 보안 기능, 엔터프라이즈 배포 가이드까지 상세히 다룹니다."
date: 2025-10-11
tags:
  - AI-Agent
  - Orchestrator
  - Multi-Agent
  - Enterprise-AI
  - Shannon
  - Docker
  - Microservices
  - LLM
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/shannon-ai-agent-orchestrator-tutorial/
canonical_url: "https://thakicloud.com/tech-blog/ko/tutorials/shannon-ai-agent-orchestrator-tutorial-ko/"
categories:
  - tutorials
---

⏱️ **예상 읽기 시간**: 15분

## 소개

Shannon은 엔터프라이즈급 보안, 비용 제어, 벤더 유연성을 제공하는 오픈소스 AI 에이전트 오케스트레이터입니다. OpenAI AgentKit과 같은 독점 솔루션과 달리, Shannon은 프로덕션 수준의 안정성과 확장성을 유지하면서 AI 인프라에 대한 완전한 제어권을 제공합니다.

### Shannon의 특별한 점

Shannon은 독특한 아키텍처와 기능으로 AI 에이전트 오케스트레이션 분야에서 차별화됩니다:

- **다중 언어 아키텍처**: Go 오케스트레이터, Rust 에이전트 코어, Python LLM 서비스
- **엔터프라이즈 보안**: OPA 정책 시행, WASI 샌드박스, 세밀한 액세스 제어
- **비용 관리**: 토큰 예산 관리, 회로 차단기 패턴, 자동 장애 복구
- **벤더 유연성**: 다중 공급자 LLM 지원 (OpenAI, Anthropic, Google, DeepSeek)
- **고급 메모리**: Qdrant를 활용한 벡터 메모리, 계층적 메모리, 중복 감지
- **실시간 통신**: 이벤트 필터링을 지원하는 WebSocket 및 SSE 스트리밍

## 사전 요구사항

이 튜토리얼을 시작하기 전에 다음이 필요합니다:

- Docker 및 Docker Compose 설치
- 컨테이너화된 애플리케이션에 대한 기본 이해
- REST API 및 마이크로서비스에 대한 친숙함
- 최소 하나의 LLM 공급자 API 키 (OpenAI, Anthropic 등)

## 설치 및 설정

### 1. 저장소 클론

```bash
git clone https://github.com/Kocoro-lab/Shannon.git
cd Shannon
```

### 2. 환경 구성

환경 구성 파일을 생성합니다:

```bash
cp .env.example .env
```

`.env` 파일을 편집하여 구성을 설정합니다:

```bash
# LLM 공급자 구성
OPENAI_API_KEY=your_openai_api_key_here
ANTHROPIC_API_KEY=your_anthropic_api_key_here

# 데이터베이스 구성
POSTGRES_HOST=postgres
POSTGRES_PORT=5432
POSTGRES_DB=shannon
POSTGRES_USER=shannon
POSTGRES_PASSWORD=your_secure_password

# Redis 구성
REDIS_HOST=redis
REDIS_PORT=6379

# Qdrant 벡터 데이터베이스
QDRANT_HOST=qdrant
QDRANT_PORT=6333

# 서비스 포트
ORCHESTRATOR_PORT=8080
AGENT_CORE_PORT=8081
LLM_SERVICE_PORT=8082
```

### 3. Shannon 서비스 시작

Shannon은 서비스 관리를 위한 편리한 Makefile을 제공합니다:

```bash
# 모든 서비스 시작
make up

# 서비스 상태 확인
make ps

# 로그 보기
make logs

# 서비스 중지
make down
```

### 4. 설치 확인

모든 서비스가 실행 중인지 확인합니다:

```bash
# 오케스트레이터 상태 확인
curl http://localhost:8080/health

# 에이전트 코어 상태 확인
curl http://localhost:8081/health

# LLM 서비스 상태 확인
curl http://localhost:8082/health
```

## 핵심 개념

### 아키텍처 개요

Shannon은 세 가지 주요 구성 요소로 이루어진 마이크로서비스 아키텍처를 따릅니다:

1. **Go 오케스트레이터**: 워크플로우, 세션, 에이전트 조정 관리
2. **Rust 에이전트 코어**: 에이전트 실행, 메모리 관리, 도구 통합 처리
3. **Python LLM 서비스**: 여러 LLM 공급자에 대한 통합 인터페이스 제공

**그림 1. Shannon 오케스트레이터 아키텍처 (Go 오케스트레이터 · Rust 에이전트 코어 · Python LLM 서비스).**

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
<div class="d3-arch" data-arch-root id="ntorchestratortutorialko-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 718, "height": 708, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Client", "x": 239, "y": 24, "w": 149, "h": 46, "title": "Client / REST API"}, {"id": "GO", "x": 207, "y": 148, "w": 212, "h": 78, "title": ["Go Orchestrator:", "workflows, sessions, agent", "coordination"]}, {"id": "RUST", "x": 214, "y": 304, "w": 198, "h": 62, "title": ["Rust Agent Core:", "execution, memory, tools"]}, {"id": "PY", "x": 474, "y": 466, "w": 212, "h": 62, "title": ["Python LLM Service:", "unified provider interface"]}, {"id": "LLM", "x": 485, "y": 614, "w": 191, "h": 62, "title": ["LLM Providers: OpenAI /", "Anthropic / others"]}, {"id": "PAT", "x": 207, "y": 458, "w": 212, "h": 78, "title": ["ReAct / Tree-of-Thoughts /", "Chain-of-Thought / Debate", "/ Reflection"]}, {"id": "MEM", "x": 24, "y": 474, "w": 128, "h": 46, "title": "Session Memory"}], "edges": [{"src": "Client", "dst": "GO", "kind": "data", "line": [313, 70, 313, 148]}, {"src": "GO", "dst": "RUST", "kind": "data", "line": [313, 226, 313, 304]}, {"src": "RUST", "dst": "PY", "kind": "data", "curve": [[412, 364], [580, 412], [580, 412], [580, 466]]}, {"src": "PY", "dst": "LLM", "kind": "data", "line": [580, 528, 580, 614]}, {"src": "RUST", "dst": "PAT", "kind": "event", "label": "patterns", "line": [313, 366, 313, 458], "lx": 313, "ly": 408}, {"src": "RUST", "dst": "MEM", "kind": "data", "curve": [[222, 366], [88, 412], [88, 412], [88, 474]]}]});
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
      const container = document.getElementById('ntorchestratortutorialko-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ntorchestratortutorialko-1';
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

### 에이전트 패턴

Shannon은 여러 오케스트레이션 패턴을 지원합니다:

- **ReAct**: 언어 모델에서의 추론과 행동
- **Tree-of-Thoughts**: 여러 추론 경로 탐색
- **Chain-of-Thought**: 순차적 추론 단계
- **Debate**: 여러 에이전트가 토론하고 합의에 도달
- **Reflection**: 자기 평가 및 개선

## 기본 사용법 튜토리얼

### 1. 첫 번째 에이전트 생성

질문에 답하고 기본 작업을 수행할 수 있는 간단한 에이전트를 생성해보겠습니다:

```bash
curl -X POST http://localhost:8080/api/v1/agents \
  -H "Content-Type: application/json" \
  -d '{
    "name": "research-assistant",
    "description": "도움이 되는 연구 보조원",
    "system_prompt": "당신은 지식이 풍부한 연구 보조원입니다. 사용자 질문에 정확하고 잘 연구된 답변을 제공하세요.",
    "model_provider": "openai",
    "model_name": "gpt-4",
    "max_tokens": 2000,
    "temperature": 0.7
  }'
```

### 2. 세션 시작

에이전트와 상호작용할 세션을 생성합니다:

```bash
curl -X POST http://localhost:8080/api/v1/sessions \
  -H "Content-Type: application/json" \
  -d '{
    "agent_id": "research-assistant",
    "session_config": {
      "max_turns": 50,
      "context_window": 10,
      "memory_enabled": true
    }
  }'
```

### 3. 메시지 전송

에이전트에게 메시지를 보냅니다:

```bash
curl -X POST http://localhost:8080/api/v1/sessions/{session_id}/messages \
  -H "Content-Type: application/json" \
  -d '{
    "content": "마이크로서비스 아키텍처의 주요 이점은 무엇인가요?",
    "message_type": "user"
  }'
```

### 4. 스트리밍 응답

실시간 응답을 위해 스트리밍 엔드포인트를 사용합니다:

```bash
curl -N http://localhost:8080/api/v1/sessions/{session_id}/stream \
  -H "Accept: text/event-stream"
```

## 고급 기능

### 멀티 에이전트 워크플로우

Shannon은 여러 에이전트가 함께 작업하는 오케스트레이션에 뛰어납니다. 멀티 에이전트 워크플로우를 설정하는 방법은 다음과 같습니다:

#### 1. 에이전트 역할 정의

```yaml
# workflow.yaml
name: "content-creation-pipeline"
description: "멀티 에이전트 콘텐츠 생성 워크플로우"

agents:
  - name: "researcher"
    role: "research"
    system_prompt: "당신은 철저한 연구원입니다. 주어진 주제에 대한 포괄적인 정보를 수집하세요."
    model: "gpt-4"
    
  - name: "writer"
    role: "content-creation"
    system_prompt: "당신은 숙련된 작가입니다. 연구를 바탕으로 매력적인 콘텐츠를 작성하세요."
    model: "claude-3-sonnet"
    
  - name: "editor"
    role: "review"
    system_prompt: "당신은 꼼꼼한 편집자입니다. 콘텐츠 품질을 검토하고 개선하세요."
    model: "gpt-4"

workflow:
  pattern: "sequential"
  steps:
    - agent: "researcher"
      task: "주어진 주제를 철저히 연구하세요"
      output_to: ["writer"]
      
    - agent: "writer"
      task: "연구를 바탕으로 콘텐츠를 작성하세요"
      input_from: ["researcher"]
      output_to: ["editor"]
      
    - agent: "editor"
      task: "콘텐츠를 검토하고 개선하세요"
      input_from: ["writer"]
      final_output: true
```

#### 2. 멀티 에이전트 워크플로우 실행

```bash
curl -X POST http://localhost:8080/api/v1/workflows \
  -H "Content-Type: application/json" \
  -d '{
    "workflow_file": "workflow.yaml",
    "input": {
      "topic": "의료 분야에서의 AI의 미래",
      "target_audience": "의료 전문가",
      "word_count": 1500
    }
  }'
```

### 메모리 관리

Shannon은 정교한 메모리 관리 기능을 제공합니다:

#### 벡터 메모리 구성

```json
{
  "memory_config": {
    "vector_memory": {
      "enabled": true,
      "collection_name": "agent_memory",
      "embedding_model": "text-embedding-ada-002",
      "similarity_threshold": 0.8,
      "max_results": 10
    },
    "hierarchical_memory": {
      "enabled": true,
      "recent_messages": 20,
      "semantic_compression": true,
      "deduplication_threshold": 0.95
    }
  }
}
```

#### 에이전트 메모리 쿼리

```bash
curl -X GET "http://localhost:8080/api/v1/sessions/{session_id}/memory?query=마이크로서비스+이점&limit=5" \
  -H "Accept: application/json"
```

### 보안 및 액세스 제어

Shannon은 세밀한 액세스 제어를 위해 Open Policy Agent(OPA)를 사용합니다:

#### 1. 보안 정책 정의

```rego
# policies/agent_access.rego
package shannon.agent_access

import future.keywords.if

# 사용자가 필요한 역할을 가진 경우 액세스 허용
allow if {
    input.user.roles[_] == "agent_operator"
    input.action == "create_agent"
}

# 사용자 등급에 따른 모델 액세스 제한
allow if {
    input.user.tier == "premium"
    input.agent.model in ["gpt-4", "claude-3-opus"]
}

# 예산 시행
allow if {
    input.user.monthly_budget > input.estimated_cost
}
```

#### 2. 정책 적용

```bash
curl -X POST http://localhost:8080/api/v1/policies \
  -H "Content-Type: application/json" \
  -d '{
    "name": "agent_access_policy",
    "policy_file": "policies/agent_access.rego",
    "enabled": true
  }'
```

### 비용 관리

Shannon은 포괄적인 비용 관리 기능을 제공합니다:

#### 1. 예산 한도 설정

```bash
curl -X POST http://localhost:8080/api/v1/budgets \
  -H "Content-Type: application/json" \
  -d '{
    "user_id": "user123",
    "monthly_limit": 100.00,
    "per_session_limit": 10.00,
    "alert_threshold": 0.8,
    "currency": "USD"
  }'
```

#### 2. 사용량 모니터링

```bash
curl -X GET http://localhost:8080/api/v1/usage/user123 \
  -H "Accept: application/json"
```

### 도구 통합

Shannon은 여러 도구 통합 방법을 지원합니다:

#### 1. MCP (Model Context Protocol) 도구

```json
{
  "tools": [
    {
      "type": "mcp",
      "name": "file_operations",
      "server_url": "mcp://localhost:3000",
      "capabilities": ["read_file", "write_file", "list_directory"]
    }
  ]
}
```

#### 2. OpenAPI 도구

```json
{
  "tools": [
    {
      "type": "openapi",
      "name": "weather_api",
      "spec_url": "https://api.weather.com/openapi.json",
      "auth": {
        "type": "api_key",
        "key": "your_weather_api_key"
      }
    }
  ]
}
```

## 프로덕션 배포

### Docker Compose 프로덕션 설정

프로덕션 배포를 위해 제공된 프로덕션 구성을 사용합니다:

```yaml
# docker-compose.prod.yml
version: '3.8'

services:
  orchestrator:
    image: shannon/orchestrator:latest
    environment:
      - ENV=production
      - LOG_LEVEL=info
    deploy:
      replicas: 3
      resources:
        limits:
          memory: 1G
          cpus: '0.5'
    healthcheck:
      test: ["CMD", "curl", "-f", "http://localhost:8080/health"]
      interval: 30s
      timeout: 10s
      retries: 3

  agent-core:
    image: shannon/agent-core:latest
    deploy:
      replicas: 2
      resources:
        limits:
          memory: 2G
          cpus: '1.0'

  postgres:
    image: postgres:15
    environment:
      POSTGRES_DB: shannon_prod
      POSTGRES_USER: shannon
      POSTGRES_PASSWORD: ${POSTGRES_PASSWORD}
    volumes:
      - postgres_data:/var/lib/postgresql/data
    deploy:
      resources:
        limits:
          memory: 2G

volumes:
  postgres_data:
```

### Kubernetes 배포

Shannon은 클라우드 배포를 위한 Kubernetes 매니페스트도 제공합니다:

```yaml
# k8s/orchestrator-deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: shannon-orchestrator
spec:
  replicas: 3
  selector:
    matchLabels:
      app: shannon-orchestrator
  template:
    metadata:
      labels:
        app: shannon-orchestrator
    spec:
      containers:
      - name: orchestrator
        image: shannon/orchestrator:latest
        ports:
        - containerPort: 8080
        env:
        - name: POSTGRES_HOST
          value: "postgres-service"
        - name: REDIS_HOST
          value: "redis-service"
        resources:
          requests:
            memory: "512Mi"
            cpu: "250m"
          limits:
            memory: "1Gi"
            cpu: "500m"
```

## 모니터링 및 관측성

Shannon은 포괄적인 모니터링 기능을 포함합니다:

### 1. 메트릭 수집

Shannon은 Prometheus 메트릭을 노출합니다:

```bash
# 사용 가능한 메트릭 보기
curl http://localhost:8080/metrics
```

### 2. Grafana 대시보드

제공된 Grafana 대시보드를 가져옵니다:

```bash
# Shannon 대시보드 가져오기
curl -X POST http://grafana:3000/api/dashboards/db \
  -H "Content-Type: application/json" \
  -d @observability/grafana/shannon-dashboard.json
```

### 3. 분산 추적

Jaeger를 사용한 분산 추적을 활성화합니다:

```yaml
# docker-compose.yml
services:
  jaeger:
    image: jaegertracing/all-in-one:latest
    ports:
      - "16686:16686"
      - "14268:14268"
    environment:
      - COLLECTOR_OTLP_ENABLED=true
```

## 문제 해결

### 일반적인 문제 및 해결책

#### 1. 서비스 연결 문제

```bash
# 서비스 로그 확인
make logs

# 특정 서비스 재시작
docker-compose restart orchestrator

# 네트워크 연결 확인
docker network ls
docker network inspect shannon_default
```

#### 2. 메모리 문제

```bash
# 메모리 사용량 모니터링
docker stats

# docker-compose.yml에서 메모리 한도 조정
services:
  agent-core:
    deploy:
      resources:
        limits:
          memory: 4G
```

#### 3. 데이터베이스 연결 문제

```bash
# PostgreSQL 로그 확인
docker-compose logs postgres

# 데이터베이스 연결 테스트
docker-compose exec postgres psql -U shannon -d shannon -c "SELECT 1;"
```

### 성능 최적화

#### 1. 연결 풀링

더 나은 성능을 위한 연결 풀링 구성:

```yaml
# config/database.yaml
database:
  max_connections: 100
  max_idle_connections: 10
  connection_max_lifetime: 3600
```

#### 2. 캐싱 구성

Redis 캐싱 최적화:

```yaml
# config/redis.yaml
redis:
  max_connections: 50
  idle_timeout: 300
  cache_ttl: 3600
```

## 모범 사례

### 1. 에이전트 설계

- **단일 책임**: 특정하고 잘 정의된 역할을 가진 에이전트 설계
- **명확한 시스템 프롬프트**: 상세하고 명확한 지침 제공
- **적절한 모델 선택**: 작업 복잡성과 비용 요구사항에 따른 모델 선택

### 2. 워크플로우 설계

- **오류 처리**: 강력한 오류 처리 및 폴백 메커니즘 구현
- **리소스 관리**: 적절한 타임아웃 및 리소스 한도 설정
- **모니터링**: 포괄적인 로깅 및 모니터링 포함

### 3. 보안

- **API 키 관리**: 안전한 비밀 관리 시스템 사용
- **액세스 제어**: 세밀한 액세스 제어 정책 구현
- **감사 로깅**: 규정 준수를 위한 포괄적인 감사 로깅 활성화

### 4. 비용 최적화

- **예산 모니터링**: 예산 임계값에 대한 알림 설정
- **모델 선택**: 적절한 작업에 비용 효율적인 모델 사용
- **캐싱**: API 호출을 줄이기 위한 지능적 캐싱 구현

## 결론

Shannon AI Agent Orchestrator는 엔터프라이즈급 AI 에이전트 시스템을 구축하고 배포하기 위한 강력하고 유연한 플랫폼을 제공합니다. 마이크로서비스 아키텍처, 포괄적인 보안 기능, 고급 오케스트레이션 기능을 통해 Shannon은 조직이 제어, 보안, 비용 효율성을 유지하면서 AI 에이전트의 힘을 활용할 수 있게 합니다.

플랫폼의 오픈소스 특성은 투명성과 커스터마이징을 보장하며, 프로덕션 준비 기능은 엔터프라이즈 배포에 적합합니다. 간단한 챗봇을 구축하든 복잡한 멀티 에이전트 워크플로우를 구축하든, Shannon은 성공에 필요한 도구와 인프라를 제공합니다.

### 다음 단계

1. **고급 패턴 탐색**: Tree-of-Thoughts 및 Debate와 같은 다양한 오케스트레이션 패턴 실험
2. **커스텀 도구 개발**: MCP 프로토콜을 사용한 커스텀 도구 생성
3. **프로덕션 배포**: 프로덕션 환경에 Shannon 배포
4. **커뮤니티 참여**: Discord의 Shannon 커뮤니티에 참여하고 프로젝트에 기여

### 리소스

- **GitHub 저장소**: [https://github.com/Kocoro-lab/Shannon](https://github.com/Kocoro-lab/Shannon)
- **문서**: `docs/` 디렉토리에서 확인 가능
- **Discord 커뮤니티**: 지원 및 토론을 위해 참여
- **기여 가이드**: 기여 지침은 `CONTRIBUTING.md` 참조

Shannon은 AI 에이전트 오케스트레이션의 미래를 나타냅니다 - 개방적이고, 안전하며, 엔터프라이즈 준비가 완료된 솔루션입니다. 지금 AI 에이전트 시스템 구축을 시작하세요!
