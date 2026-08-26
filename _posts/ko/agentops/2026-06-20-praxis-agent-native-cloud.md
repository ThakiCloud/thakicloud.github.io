---
title: "Paxis: AI 직원 한 팀을 코드 없이 운영하는 Agent-Native Cloud"
excerpt: "기존 클라우드가 서버를 다루듯, Paxis는 에이전트의 능력·도구·정책·감사를 일급 자원으로 다룹니다. 849개 스킬 자동 탑재, 작업마다 모델을 고르는 CostRouter, 쓸수록 다듬어지는 능력까지. 실제 동작하는 PoC를 코드와 함께 공개합니다."
seo_title: "Paxis Agent-Native Cloud: 거버넌스·CostRouter·진화하는 스킬 - Thaki Cloud"
seo_description: "ThakiCloud Paxis는 자율 AI 에이전트를 안전하게 운영하는 Agent-Native Cloud입니다. L0-L3 자율도 거버넌스, 멀티-LLM CostRouter 비용 최적화, Git 기반 HKE 지식엔진, 849 스킬 하니스를 실제 코드와 함께 소개합니다."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - agent-native-cloud
  - praxis
  - agentops
  - llm-cost-optimization
  - governance
  - rag
  - knowledge-engine
  - multi-agent
  - skill-harness
  - thakicloud
header:
  teaser: /assets/images/praxis-architecture-hero.webp
toc: true
toc_sticky: true
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/praxis-agent-native-cloud/"
---

![Paxis 계층 아키텍처: Cloud 인프라 위에 Paxis Core, 그 위에 849 스킬·14 도메인 에이전트 능력 계층]({{ '/assets/images/praxis-architecture-hero.webp' | relative_url }})

![Paxis: AI 직원 한 팀을 코드 없이 운영하는 Agent-Native Cloud 개념을 형상화한 이미지](/assets/images/praxis-agent-native-cloud-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 클라우드의 다음 질문은 "에이전트를 어떻게 운영하나"

지난 10년의 클라우드는 무엇을 다루느냐로 세대가 나뉘었습니다. 처음에는 서버와 인프라를 다뤘고, 다음에는 데이터와 파이프라인을 다뤘습니다. 지금 현장에서 터지는 질문은 다릅니다. AI 에이전트를 여러 개 돌리기 시작한 순간, 누가 무엇을 했는지 통제가 안 되고, 비용이 예측을 벗어나고, 보안·감사 요구를 맞추지 못하고, 팀마다 같은 것을 따로 만듭니다.

Paxis는 이 빈자리를 겨냥합니다. 기존 클라우드가 컴퓨트·데이터베이스·네트워크를 일급 자원으로 다뤘다면, Paxis는 AI 에이전트의 능력(Skill)·도구(Tool)·정책(Policy)·감사(Audit)를 일급 자원으로 다룹니다. 고객은 "AI 직원 한 팀"을 코드 없이 채용하고, 관리하고, 감사하게 됩니다. 우리는 이 범주를 Agent-Native Cloud라고 부릅니다.

![전통 클라우드는 Compute·DB·Network를, Paxis는 Skills·Tools·Policies·Audit Logs를 일급 자원으로 다룬다]({{ '/assets/images/praxis-cloud-analogy.webp' | relative_url }})

이 글은 마케팅 슬로건이 아니라 실제로 기동한 PoC를 코드와 함께 설명합니다. 아래 수치는 모두 실제 서버(`localhost:8080`)에서 확인한 값입니다.

## 핵심 모듈: 외울 것은 세 가지

Paxis 백엔드는 Go로 작성됐고, 아키텍처는 세 계층으로 읽으면 됩니다. 아래는 인프라 위에 코어, 그 위에 능력 계층이 올라가는 구조입니다.

- 에이전트 런타임(Native Loop): ReAct 루프와 도구 실행, 비용 추적, 자율도 게이트가 모이는 단일 실행 진입점.
- 스킬 하니스(Skill Harness): 부팅 시 스킬을 자동 탑재하고 TF-IDF로 관련 스킬을 선택.
- 하이브리드 지식 엔진(HKE): 팀별 위키를 인제스트·쿼리하는 Git 기반 지식 계층.
- LLM 게이트웨이: 여러 모델 프로바이더를 추상화하고 비용 라우팅의 단일 출처를 제공.
- 보안·정책: 자율도 매트릭스(L0-L3), 프롬프트 보안, 전 행동 감사.
- 메모리: 세션 메모리와 pgvector 의미 검색, 출처(provenance) 추적.

나머지는 샌드박스 실행과 멀티 에이전트 오케스트레이션이 받칩니다. 핵심만 기억한다면 런타임·하니스·지식엔진 셋입니다.

## 능력 추가 = 파일 한 장

Paxis에서 새 능력을 더하는 비용은 코드 배포 0입니다. `skills/<도메인>/<이름>/SKILL.md` 파일 하나를 두면, 서버가 디렉터리를 자동 탐색해 즉시 반영합니다.

```markdown
---
name: competitor-digest
description: >-
  경쟁사 뉴스를 수집해 요약한다. Use when 경쟁사 동향, 뉴스 다이제스트.
allowed-tools: [web_search, web_fetch]
---
# Competitor Digest
## 지시사항
지정한 출처에서 최신 기사를 모아 핵심만 불릿으로 정리한다.
```

저장하면 서버 재시작 없이 `GET /api/v1/skills`에 바로 잡힙니다. PoC 서버에서 부팅 직후 자동 탑재된 스킬은 849개, 기본 제공 도메인 에이전트는 14개입니다. 이 "두꺼운 스킬, 얇은 하니스" 원칙 덕분에 능력은 파일로 쌓이고 하니스는 가볍게 유지됩니다.

자연어로 주기 작업을 만드는 것도 같은 결입니다.

```bash
curl -X POST http://localhost:8080/api/v1/tasks \
  -H "Authorization: Bearer $TOKEN" \
  -d '{"team_id":"dev-team","agent_id":"research-bot",
       "schedule":{"type":"cron","expr":"0 9 * * *"},
       "skill":"competitor-digest","params":{"topN":10}}'
```

채팅에서 "매일 아침 9시에 경쟁사 뉴스 10건 요약해줘"라고 말하면, LLM이 이 cron·스킬·파라미터로 변환해 등록합니다. 코드는 0줄입니다.

## CostRouter: 작업마다 모델을 코드가 고른다

"AI 비용 폭탄"은 대부분 모든 작업에 비싼 모델을 쓰기 때문에 생깁니다. Paxis는 작업을 세 단계(Planner → Executor → Synthesizer)로 나누고, 각 단계에 맞는 모델을 자동 배정합니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="20praxisagentnativecloud-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 465, "height": 640, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "Q", "x": 123, "y": 24, "w": 120, "h": 46, "title": "작업 요청"}, {"id": "P", "x": 123, "y": 148, "w": 120, "h": 46, "title": "Planner"}, {"id": "E", "x": 214, "y": 286, "w": 120, "h": 46, "title": "Executor"}, {"id": "S", "x": 309, "y": 424, "w": 120, "h": 46, "title": "Synthesizer"}, {"id": "H", "x": 24, "y": 286, "w": 135, "h": 46, "title": "Haiku · economy"}, {"id": "SO", "x": 105, "y": 424, "w": 149, "h": 46, "title": "Sonnet · standard"}, {"id": "O", "x": 305, "y": 562, "w": 128, "h": 46, "title": "Opus · premium"}], "edges": [{"src": "Q", "dst": "P", "kind": "data", "line": [183, 70, 183, 148]}, {"src": "P", "dst": "E", "kind": "data", "curve": [[213, 194], [274, 240], [274, 240], [274, 286]]}, {"src": "E", "dst": "S", "kind": "data", "curve": [[306, 332], [369, 378], [369, 378], [369, 424]]}, {"src": "P", "dst": "H", "kind": "event", "label": "대부분", "curve": [[152, 194], [92, 240], [92, 240], [92, 286]], "off": "50%"}, {"src": "E", "dst": "SO", "kind": "event", "label": "표준", "curve": [[242, 332], [179, 378], [179, 378], [179, 424]], "off": "50%"}, {"src": "S", "dst": "O", "kind": "event", "label": "임계 단계만", "line": [369, 470, 369, 562], "lx": 369, "ly": 512}]});
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
      const container = document.getElementById('20praxisagentnativecloud-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20praxisagentnativecloud-1';
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

모델 계층은 `models.yaml`이 단일 출처로 관리합니다. 출력 100만 토큰 기준 단가로 보면 격차가 큽니다.

| 계층 | 모델 | 출력 $/1M | 용도 |
|---|---|---|---|
| economy | Haiku 4.5 | $4 | 대부분의 작업 |
| standard | Sonnet 4.6 | $15 | 균형 |
| strong | GPT-4o / Kimi | 중간 | 보강 |
| premium | Opus 4.8 | $25 | 임계 단계만 (opt-in) |

핵심은 대부분의 작업이 가장 싼 Haiku로 충분하고, Opus는 정말 중요한 단계에만 쓴다는 것입니다. 거기에 실행당 예산 상한이 걸려, 비용이 예측 가능해지고 Command Center에서 당일·주간으로 보고됩니다. 그리고 쓸수록 어떤 작업에 싼 모델로 충분한지 라우팅이 학습되어, 반복 작업의 실행당 비용은 점점 내려갑니다.

## 기존 RAG와 무엇이 다른가: HKE

전통 RAG는 그때그때 검색해 붙이는 일회성에 가깝습니다. Paxis의 하이브리드 지식 엔진(HKE)은 지식이 자산으로 쌓입니다.

| 전통 RAG | Paxis HKE |
|---|---|
| stateless 단발 검색 | Git 기반 영속 위키 (쌓인다) |
| 도메인 경계 없음 | 에이전트별 도메인 스코핑 격리 |
| 출처 신뢰 미추적 | provenance(누가·언제·어느 출처) 기록 |
| 비용 무제어 | tool-budget로 큰 결과 절단·지연 fetch |

문서나 코드를 올리면 정제를 거쳐 지식 그래프로 자라고, 답변에는 출처가 인용됩니다. 팀 단위로 격리되어 한 팀의 위키가 다른 팀에 노출되지 않습니다. 그 아래에는 세션·pgvector 의미 검색·팀 위키·provenance의 4계층 메모리가 있어, 대화가 반복될수록 맥락이 누적됩니다.

## 통제되는 에이전트: 거버넌스가 해자

데모가 화려한 에이전트 도구는 많지만, 거버넌스가 약하면 엔터프라이즈에 들어갈 수 없습니다. Paxis는 통제를 기본값으로 둡니다.

- 자율도 매트릭스 L0-L3: 작업 위험도 × 권한으로 실행 전 게이트.
- 프롬프트 보안과 개인정보 제거.
- 전 행동 감사 체인: 누가·언제·무엇을 했는지 전수 기록.
- 멀티테넌시 팀 격리.

여기에 더해, 능력이 사용과 함께 다듬어지는 방향으로 설계돼 있습니다. 제안(Propose) → 증류(Distill) → 패치(Patch)로 이어지는 큐레이터 루프와, 능력의 신뢰도가 사용에 따라 system → learned → promoted로 올라가는 사다리가 그것입니다. 이 자기개선 루프는 일부 동작하고 일부는 고도화 중인 PoC 단계임을 분명히 해둡니다. 과장 없이 방향과 골격은 이미 코드에 들어가 있습니다.

## 영업이 바로 쓰는 데모 3장면

Paxis의 강점은 우리 영업팀이 직접 쓰면서 동시에 고객에게 보여줄 수 있다는 점입니다.

1. 자는 동안 일하는 비서: Proactive 토글 ON 한 번이면 다음 날 아침 브리핑이 Slack에 자동 도착합니다.
2. 말로 일을 시킨다: 자연어 한 줄이 cron과 스킬로 등록됩니다.
3. 문서가 팀 지식이 된다: 제안서 PDF를 끌어다 놓으면 팀 전체가 챗으로 질문하고, 출처까지 인용됩니다.

이 모든 것을 단 하나의 화면(Command Center)에서 스케줄·비용·협업·감사로 관제합니다.

## ThakiCloud 관점: 왜 이 방향인가

ThakiCloud의 AI 플랫폼은 Kubernetes 위에서 Kueue로 GPU를 스케줄링하고 vLLM으로 모델을 서빙하는 멀티테넌트 환경을 운영합니다. Paxis는 그 위에서 에이전트를 안전하게 운용하기 위한 컨트롤 플레인입니다.

이 조합이 의미 있는 이유는 세 가지입니다. 첫째, 거버넌스(L0-L3 자율도·전 행동 감사·팀 격리)가 내장돼 있어, 보안·감사·데이터 분리를 요구하는 공공·금융·대기업 환경에 그대로 맞출 수 있습니다. 둘째, 온프레미스와 self-hosting을 전제로 설계해, 데이터를 외부로 내보낼 수 없는 조직에서도 동작합니다. 셋째, CostRouter가 작업마다 모델을 고르고 예산 상한을 거는 구조라, GPU·API 비용을 통제하면서 운영할 수 있습니다. 낮은 서빙 비용에서의 경쟁력은 그대로 제품의 해자가 됩니다.

현재 Paxis는 PoC 단계입니다. 코어(대화·스킬·스케줄러·관제·비용 라우팅·HKE)는 동작하며, 일부 고도화 기능은 로드맵에 있습니다. "오늘 데모 가능, 한 워크플로부터 파일럿"이 우리의 정직한 메시지입니다.

## 더 보기

- 소스: [github.com/ThakiCloud/praxis](https://github.com/ThakiCloud/praxis)
- 경영 데모 덱(33장, 발표 노트 포함): [Google Slides](https://docs.google.com/presentation/d/11E5ixfWgV6uY-akebEZ--Kwp1JmRQJG1OpPaChbJLmc/edit)

함께 만들 동료와 파일럿 고객을 찾고 있습니다. Agent-Native Cloud라는 범주를 우리가 먼저 정의하려 합니다.

## 관련 슬라이드

본문 내용을 NotebookLM(`neo_swiss` 스타일)으로 요약한 슬라이드입니다.

![praxis-agent-native-cloud 슬라이드 1](/assets/images/praxis-agent-native-cloud-slide-01.png)

![praxis-agent-native-cloud 슬라이드 2](/assets/images/praxis-agent-native-cloud-slide-02.png)

![praxis-agent-native-cloud 슬라이드 3](/assets/images/praxis-agent-native-cloud-slide-03.png)

![praxis-agent-native-cloud 슬라이드 4](/assets/images/praxis-agent-native-cloud-slide-04.png)

