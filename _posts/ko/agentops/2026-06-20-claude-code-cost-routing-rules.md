---
title: "에이전트 운영비를 라우팅으로 접는다: 모델 티어, 스킬 라우터, 그리고 7개의 비용 룰"
excerpt: "하루 705달러를 태운 사고에서 출발해, LLM 모델 라우팅과 스킬 라우터, 토큰 위생 룰로 Claude Code 에이전트 운영비를 구조적으로 줄인 방법을 실제 규칙과 수치로 공개합니다."
seo_title: "Claude Code 비용 최적화: 모델 라우팅·스킬 라우터·토큰 룰 - Thaki Cloud"
seo_description: "ThakiCloud가 Claude Code 에이전트 운영비를 줄이는 실전 규칙. haiku/sonnet/opus/fable 모델 라우팅, BM25 스킬 라우터, 2K 토큰 룰, retro 모델 에스컬레이션, 일일 비용 감사까지 사고 사례와 수치로 정리합니다."
date: 2026-06-20
last_modified_at: 2026-08-27
tags:
  - cost-optimization
  - model-routing
  - token-economy
  - claude-code
  - subagent
  - finops
  - skill-router
  - agentops
  - llm-ops
  - thakicloud
header:
  teaser: /assets/images/cost-routing-hero.webp
toc: true
toc_sticky: true
categories:
  - agentops
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/claude-code-cost-routing-rules/"
audiobook: "https://drive.google.com/file/d/19OiLrvDKR0dlNsiOAbWLiXJ6xNy5OkFI/view"
audiobook_label: "▶ 5분 브리핑으로 듣기"
audiobook_note: "NotebookLM 오디오 개요 (AI 생성)"
---

![에이전트 작업이 모델 티어별로 분기되며 비용이 접히는 모습]({{ '/assets/images/cost-routing-hero.webp' | relative_url }})

![에이전트 운영비를 라우팅으로 접는다: 모델 티어, 스킬 라우터, 그리고 7개의 비용 룰 개념을 형상화한 이미지](/assets/images/claude-code-cost-routing-rules-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 하루에 705달러를 태운 날

먼저 사고부터 공개합니다. 2026년 6월 1일, 우리는 9개 세션을 전부 Opus로 돌렸고 하루 추정 비용은 705달러였습니다. 그중 단 하나의 모니터링 세션이 381달러, 즉 54%를 차지했습니다. 9.4시간 동안 1145턴, ScheduleWakeup 138회를 한 세션에 누적한 결과입니다. 비용의 42%는 cache_read 195M에서 나왔습니다. 같은 날 `cd`를 153회 실행했고, 같은 파일을 10번 다시 읽었습니다.

흥미로운 점은, 그날 띄운 서브에이전트 18개는 전부 sonnet으로 올바르게 라우팅돼 있었다는 것입니다. 문제는 서브가 아니라 메인이었습니다. 메인을 Opus로 둔 채 거대한 컨텍스트를 반복 턴으로 굴린 것이 유일한 누수였습니다.

이 글은 그날 이후 우리가 박은 규칙들입니다. AI 플랫폼이나 GPU 이야기는 빼고, 에이전트 운영 자체의 비용을 라우팅과 토큰 위생으로 어떻게 접는지에만 집중합니다.

## 1. 모델 티어: 같은 일에 19배를 내지 않는다

가장 큰 레버는 모델 선택입니다. 우리 환경의 비용 배수는 명확합니다. haiku는 약 1배, sonnet은 약 4배, opus는 약 19배입니다. 같은 탐색 작업을 opus로 하면 haiku의 19배를 내는 셈입니다.

그래서 작업 유형에 모델을 고정 매핑합니다.

| 티어 | 언제 | 배수 |
|---|---|---|
| `haiku` | 탐색, 파일 읽기, 검색, grep, 요약, 번역 | ~1x |
| `sonnet` | 분석, 구현, 코드 생성, 리뷰, 글쓰기 (기본) | ~4x |
| `opus` | 아키텍처, 다단계 추론, 복잡한 디버깅, 스펙 작성 | ~19x |
| `fable` | 오케스트레이터/지휘자 (구독 한도 절약용, 토큰 단가는 최상위) | 높음 |

배수에 관해 한 가지 못을 박아 둡니다. 위 숫자는 이 글을 쓰던 시점의 모델 세대를 기준으로 한 것이고, 가격표는 그 뒤로 바뀌었습니다. 공식 가격표 기준 현재 세대는 Haiku 4.5가 100만 토큰당 입력 1달러 출력 5달러, Sonnet 5가 2달러와 10달러, Opus 5가 5달러와 25달러입니다. 즉 haiku 대비 sonnet은 약 2배, opus는 약 5배입니다. 19배라는 간격은 이제 나지 않습니다. 배수의 절대값은 반드시 최신 가격표에서 확인하시고, 이 글에서는 "티어 간 간격이 크므로 작업에 맞춰 고정 매핑한다"는 구조만 가져가시기 바랍니다.

`fable` 행은 특히 주의해서 읽어 주십시오. Fable 5의 토큰 단가는 100만 토큰당 입력 10달러 출력 50달러로, 나열한 티어 중 가장 비쌉니다. 지휘자로 쓰는 이유는 토큰이 싸서가 아니라 **구독 플랜의 사용 한도 소진 속도**를 늦추기 위해서입니다. 종량 과금 API로 같은 구성을 그대로 옮기면 비용은 오히려 올라갑니다. 두 가지는 다른 축입니다.

하드 룰이 하나 있습니다. 모든 서브에이전트 호출은 `model` 파라미터를 반드시 명시해야 합니다. 생략하면 세션 기본값으로 청구되는데, 그 기본값이 Opus면 19배입니다. 6월 1일 사고의 본질이 바로 이것이었습니다.

```python
# 좋음: 탐색은 haiku로 명시
Agent(subagent_type="Explore", model="haiku", prompt="...")
# 나쁨: model 생략 -> 세션 기본(opus) = 19x 청구
Agent(subagent_type="Explore", prompt="...")
```

여기에 한 가지 패턴을 더합니다. 세션 메인을 fable로 두고 지휘자 역할만 맡기는 것입니다. 라우팅, 분기, 집약은 fable이 하고, 진짜 무거운 추론이 필요한 단계에서만 `Agent(model="opus")`로 단발 투입합니다. 앞서 적었듯 이 패턴이 아끼는 것은 토큰 단가가 아니라 구독 한도입니다. 탐색은 haiku입니다. 스폰 깊이는 최대 2이고, haiku 서브는 더 이상 서브를 만들지 않습니다.

## 2. 스킬 라우터: 메인이 코드베이스를 헤매지 않게

두 번째 레버는 스킬 라우터입니다. 우리에게는 1200개가 넘는 스킬이 있습니다. 메인 에이전트가 "어떤 스킬을 쓸까" 고민하며 직접 코드베이스를 grep하기 시작하면, 그 자체가 비싼 opus 토큰을 태웁니다.

그래서 `UserPromptSubmit` 훅 `skill-router-gate.py`가 매 턴 BM25 검색을 결정론 코드로 돌려, 상위 후보를 컨텍스트에 주입합니다.

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
<div class="d3-arch" data-arch-root id="audecodecostroutingrules-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 387, "height": 682, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 112, "y": 24, "w": 120, "h": 46, "title": "사용자 입력"}, {"id": "B", "x": 103, "y": 148, "w": 138, "h": 68, "title": ["토큰 0 프리필터", "인사·명령 SKIP"]}, {"id": "C", "x": 199, "y": 308, "w": 121, "h": 62, "title": ["BM25 retrieve", "1200+ 스킬 코퍼스"]}, {"id": "D", "x": 164, "y": 448, "w": 191, "h": 62, "title": ["🧭 스킬 라우터 후보", "상위 5개 주입 (GATE_MIN=6.0)"]}, {"id": "E", "x": 200, "y": 588, "w": 120, "h": 62, "title": ["메인은 grep 대신", "후보에서 바로 선택"]}, {"id": "F", "x": 24, "y": 316, "w": 120, "h": 46, "title": "주입 없음 (0 토큰)"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [172, 70, 172, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "작업성 턴", "curve": [[209, 216], [260, 262], [260, 262], [260, 308]], "off": "50%"}, {"src": "C", "dst": "D", "kind": "data", "line": [260, 370, 260, 448]}, {"src": "D", "dst": "E", "kind": "data", "line": [260, 510, 260, 588]}, {"src": "B", "dst": "F", "kind": "data", "label": "인사·확인", "curve": [[134, 216], [84, 262], [84, 262], [84, 316]], "off": "50%"}]});
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
      const container = document.getElementById('audecodecostroutingrules-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'audecodecostroutingrules-1';
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

점수는 이름 정확매칭에 가중치를 크게 주고(idf 기반), 설명 토큰에는 작게 줍니다. 인사나 단순 명령은 토큰 0 프리필터로 건너뛰고, 연속 동일 턴은 캐시합니다. 추가 LLM 패스 없이 입력 쪽 힌트만 주는 구조라 비용이 거의 없습니다. 효과는 메인이 탐색에 쓸 opus 토큰을 처음부터 아끼는 것입니다.

정직하게 한계도 밝힙니다. 복합 요청을 분해해 단계별로 검색하는 실험(SAD)에서, 완벽히 분해해도 우리 검색기 천장은 step coverage 42.5%였습니다. 논문이 말하는 "검색은 멀쩡, 분해만 고쳐라"가 우리 환경엔 그대로 적용되지 않았습니다. 그래서 결정론 정규식 분해는 기본 끄고, 분해는 복합 요청에만 opt-in으로 씁니다. 측정하지 않고 고치지 않는다는 원칙입니다.

## 3. 토큰 위생: 컨텍스트는 새기 쉽다

세 번째는 토큰 위생입니다. 핵심은 큰 출력이 메인 컨텍스트에 그대로 쌓이지 않게 하는 것입니다.

가장 중요한 규칙은 2K 토큰 룰입니다. 2K 토큰을 넘을 것으로 예상되는 도구 호출은 서브에이전트에 위임합니다. 서브가 읽고 처리해서 요약만 반환하고, 메인 컨텍스트는 깨끗하게 유지합니다. 200줄이나 2KB를 넘는 구조화 출력은 스크래치 파일이나 sqlite로 떨굽니다. 반복 구조의 JSON은 headroom의 결정론 압축으로 50% 이상 줄여 재투입합니다.

쉘 출력에는 `rtk` 프리픽스를 붙여 60~90% 압축합니다. MCP 서버는 각각 매 턴 약 1000토큰의 스키마 비용을 내므로, 안 쓰는 서버는 끄고 10개 이하로 유지합니다. 이것이 ghost token, 즉 로드만 되고 안 쓰이는 보이지 않는 매 턴 오버헤드입니다.

| 룰 파일 | 메커니즘 |
|---|---|
| `loop-monitor-cost-guard` | 폴링·모니터링은 Claude 핫루프에서 빼고 cron으로 (비용 $0), /loop는 50턴·40% 컨텍스트 전에 분할 |
| `ecc-token-strategy` | 2K 토큰 룰 위임, 200줄 초과는 스크래치 파일, JSON은 headroom 압축 |
| `rtk-token-optimization` | `rtk` 프리픽스로 명령 출력 60~90% 압축 |
| `token-diet-hygiene` | MCP 서버 10개 이하, 스킬 설명 512자 이하, ghost token 탐지 |
| `sonnet-format-determinism` | 포맷·enum·카운트는 코드가 소유, 모델은 내용만 |

마지막 룰은 비용과 직접 연결됩니다. 2026년 6월 16일, sonnet 워커 33개가 같은 지시에 `quality_gate`를 5가지 모양으로 출력하고, 24개가 판단 플래그를 과다 표기했습니다. 포맷을 모델에게 산문으로 부탁하면 매번 다르게 풉니다. 그래서 숫자, enum, 렌더링은 결정론 코드가 소유하고 모델은 내용만 생성하게 했습니다. 포맷 일관성 때문에 비싼 모델로 올릴 필요가 사라집니다.

## 4. 회고 기반 에스컬레이션: 싸게 시작, 실패하면 승격

스케줄로 도는 스킬은 모델을 하드코딩하지 않습니다. 중앙 정책 `skill_model_policy.json`이 기본 sonnet으로 시작하고, `skill_retro.py`가 회고로 모델을 정합니다.

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
<div class="d3-arch" data-arch-root id="audecodecostroutingrules-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 351, "height": 784, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 112, "y": 24, "w": 120, "h": 46, "title": "스케줄 러너 시작"}, {"id": "B", "x": 83, "y": 148, "w": 177, "h": 62, "title": ["skill_retro get-model", "정책에서 티어 조회"]}, {"id": "C", "x": 112, "y": 288, "w": 120, "h": 46, "title": "claude -p 실행"}, {"id": "D", "x": 94, "y": 412, "w": 156, "h": 62, "title": ["skill_retro record", "rc + 로그 판정"]}, {"id": "E", "x": 199, "y": 566, "w": 120, "h": 62, "title": ["streak 초기화", "sonnet 유지"]}, {"id": "F", "x": 24, "y": 566, "w": 120, "h": 62, "title": ["opus로 자동 승격", "#h-report 알림"]}, {"id": "G", "x": 24, "y": 706, "w": 120, "h": 46, "title": "streak 0 리셋"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [172, 70, 172, 148]}, {"src": "B", "dst": "C", "kind": "data", "line": [172, 210, 172, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [172, 334, 172, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "clean run", "curve": [[207, 474], [259, 520], [259, 520], [259, 566]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "bad run x2 연속", "curve": [[136, 474], [84, 520], [84, 520], [84, 566]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [84, 628, 84, 706]}]});
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
      const container = document.getElementById('audecodecostroutingrules-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'audecodecostroutingrules-2';
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

bad run 판정은 보수적입니다. 종료 코드가 0이 아니거나, 로그에 인증 실패, API 에러, Traceback 같은 마커가 있을 때만입니다. 일시적인 한 번으로는 승격하지 않고, streak가 쌓여야 합니다. 깨끗하게 성공하면 초기화하고, 자동 강등은 없습니다. 비용 통제를 모델 일괄 강등이 아니라 데이터 기반 선별 승격으로 하는 것입니다. 품질이 정말 필요한 스킬만 비싸집니다. 실제로 `twitter-timeline-to-slack`은 sonnet이 enrichment 단계를 건너뛰어 opus로 핀했습니다.

## 5. 감사: 돈이 어디로 갔는지 본다

마지막은 측정입니다. `scripts/cost_audit.py`가 세션 트랜스크립트를 파싱해 티어별 비용, 캐시 적중률, 비싼 세션과 도구, 다시 읽은 파일을 보고합니다. 6월 1일의 "메인 Opus가 97% 청구" 같은 인사이트가 여기서 나오고, 그 결과가 다시 모델 핀으로 피드백됩니다.

전체 흐름을 한 줄로 요약하면 이렇습니다. 작업 유형으로 세션 모델을 고르고, 스킬 라우터가 메인의 탐색을 줄이고, 서브는 티어별로 라우팅하며, 토큰 위생으로 컨텍스트를 깨끗이 유지하고, 회고가 실패한 스킬만 승격하고, 감사가 다시 어디서 돈이 새는지 알려줍니다.

## ThakiCloud 관점: 비용은 룰로 박는 것

비용 최적화는 한 번의 영웅적 결단이 아니라, 매 턴 자동으로 적용되는 규칙의 누적입니다. 우리가 박은 룰들은 대부분 결정론 코드와 훅으로 동작해 사람이 매번 신경 쓰지 않아도 됩니다. 비싼 모델은 금지가 아니라 데이터가 정당화할 때만 투입됩니다.

이 규율은 온프레미스 환경에서 더 중요합니다. 토큰 단가가 곧 전력과 GPU 시간으로 환산되기 때문입니다. ThakiCloud가 제공하는 플랫폼은 이런 라우팅과 관측을 기본기로 내장해, 고객이 같은 레버를 자기 인프라에서 그대로 당길 수 있게 합니다.

## 마무리

705달러 사고의 교훈은 단순했습니다. 누수는 기계가 아니라 행동에 있었고, 행동은 룰로만 교정됩니다. 모델 티어를 작업에 맞추고, 스킬 라우터로 탐색을 줄이고, 토큰을 위생적으로 다루고, 실패한 것만 승격하고, 매일 감사하면, 같은 일을 19배 싸게 할 수 있습니다.

ThakiCloud는 이 비용 규율을 제품의 기본기로 만듭니다. 자세한 이야기는 홈페이지에서 확인하실 수 있습니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`neo_swiss` 스타일)으로 요약한 슬라이드입니다.

![claude-code-cost-routing-rules 슬라이드 1](/assets/images/claude-code-cost-routing-rules-slide-01.png)

![claude-code-cost-routing-rules 슬라이드 2](/assets/images/claude-code-cost-routing-rules-slide-02.png)

![claude-code-cost-routing-rules 슬라이드 3](/assets/images/claude-code-cost-routing-rules-slide-03.png)

![claude-code-cost-routing-rules 슬라이드 4](/assets/images/claude-code-cost-routing-rules-slide-04.png)

## 출처

- [Create custom subagents (Claude Code Docs)](https://code.claude.com/docs/en/sub-agents)
- [Hooks reference (Claude Code Docs)](https://code.claude.com/docs/en/hooks)
- [Run Claude Code programmatically (Claude Code Docs)](https://code.claude.com/docs/en/headless)
- [Prompt caching (Claude Platform Docs)](https://platform.claude.com/docs/en/build-with-claude/prompt-caching)
