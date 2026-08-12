---
title: "대화가 스킬이 된다: 과거 세션에서 워크플로를 캐내고 스스로 진화시키는 에이전트"
excerpt: "800개가 넘는 과거 대화에서 반복 워크플로를 결정론 엔진으로 캐내 스킬로 만들고, 실패를 근거로 스킬 본문을 leak-free로 진화시키는 두 개의 자율 루프를 코드와 함께 공개합니다."
seo_title: "과거 대화를 스킬로: Chronicle 마이닝과 selfharness 자가진화 - Thaki Cloud"
seo_description: "ThakiCloud가 Claude Code 세션 801개에서 반복 워크플로를 결정론 마이너로 추출해 스킬로 변환하고, Self-Harness 논문 기반으로 스킬 본문을 누수 없이 진화시키는 방식을 코드와 수치로 정리합니다."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - skill-evolution
  - self-improvement
  - agent-memory
  - workflow-mining
  - claude-code
  - self-harness
  - chronicle
  - deterministic-pipeline
  - agentops
  - thakicloud
header:
  teaser: /assets/images/self-evolving-skills-hero.webp
toc: true
toc_sticky: true
categories:
  - agentops
---

![과거 대화가 재사용 가능한 스킬로 응결되는 모습]({{ '/assets/images/self-evolving-skills-hero.webp' | relative_url }})

## 매번 같은 것을 다시 설명하고 있다면

에이전트를 오래 쓰다 보면 한 가지 패턴이 보입니다. 같은 작업을, 같은 관례로, 매번 처음부터 다시 지시하고 있다는 것입니다. "이 내용을 docs 폴더 아래 영어로 계획해줘", "이 깃헙을 받아서 스킬로 변환해줘" 같은 요청은 표현만 조금씩 다를 뿐 사실상 같은 워크플로입니다.

스킬은 공짜가 아닙니다. 인덱스에 올라가는 순간부터 이름과 설명이 매 세션 컨텍스트 비용을 차지합니다. 그래서 "반복하니까 일단 스킬로 만들자"는 무책임합니다. 정말로 반복되는지, 이미 있는 스킬과 겹치지 않는지, 만든 다음에 품질이 유지되는지가 전부 검증되어야 합니다.

이 글은 마케팅이 아니라 우리가 실제로 돌리는 두 개의 자율 루프를 그대로 공개합니다. 하나는 과거 대화에서 반복 워크플로를 캐내 스킬로 만드는 Chronicle 마이닝이고, 다른 하나는 실패를 근거로 기존 스킬의 본문을 스스로 고치는 selfharness 자가진화입니다.

## 1. Chronicle: 과거 대화를 코퍼스로 만든다

먼저 재료가 필요합니다. Claude Code 세션은 `~/.claude/projects/<repo>/*.jsonl`에 원본 트랜스크립트로 쌓입니다. 우리는 `scripts/memory/extract-sessions.py`로 이 원본에서 고신호 항목만 추려 `memory/sessions/` 아래에 마크다운 세션 로그로 추출해 둡니다. 현재 801개. 각 파일은 프론트매터에 `date`, `session_id`, `title`, `files_touched`를 담고 본문에 메시지를 담습니다.

이 코퍼스가 우리의 Chronicle입니다. 비용은 0입니다. 추출은 야간 메모리 파이프라인의 결정론 단계에서 증분으로만 돌기 때문입니다.

## 2. 카운팅은 모델이 아니라 코드가 소유한다

핵심 설계 원칙이 하나 있습니다. 빈도, 패턴 시그니처, 중복 판정 같은 숫자는 절대 모델에게 맡기지 않습니다. 모델은 "몇 개 세션에서 반복됐다"를 추정하면 거의 틀립니다. 그래서 마이닝 엔진 `scripts/skills/chronicle_mine.py`는 LLM을 한 번도 호출하지 않는 순수 결정론 코드입니다. 실행 비용은 사실상 0입니다.

엔진이 하는 일은 단순합니다. 세션의 제목과 작업한 파일에서 신호 토큰을 뽑고, 여러 세션에 걸친 문서 빈도를 셉니다. 임계치(기본 4개 세션) 이상 반복되는 토큰과 동시출현 쌍을 후보로 올립니다. 동시에 기존 `.claude/skills/`의 이름과 대조해 `update`(이미 존재) 와 `create`(신규) 를 태깅합니다.

진짜 어려운 부분은 노이즈입니다. 첫 실행에서 1위로 올라온 패턴은 `hooks+state`(260회), `cursor+plan`(198회) 같은 것이었습니다. 이건 반복 워크플로가 아니라 거의 모든 세션이 건드리는 레포 인프라 경로일 뿐입니다. 이른바 lexical mismatch입니다. 그래서 IDF 방식의 최대 문서빈도 컷오프를 넣었습니다. 코퍼스의 16%를 넘는 토큰은 "어디에나 있는" 환경 잡음으로 보고 버립니다.

```python
# 코퍼스의 16%를 넘는 토큰은 ambient(어디에나 있음) -> 워크플로 정체성 아님
MAX_DF_RATIO = 0.16
ambient = {t for t, c in raw_df.items() if c / n > MAX_DF_RATIO}
```

그래도 `.cursor/plugins/cache/` 아래 플러그인 캐시의 SKILL.md 이름들이 거짓 신호로 상위를 점령했습니다. 실제 세션 몇 개를 열어보고서야 원인을 찾았습니다. 그래서 캐시, 생성된 플랜, vendored 경로를 통째로 제외하고, 신호를 "사용자의 의도가 담긴 제목" 과 "실제로 호출한 스킬 정체성" 으로만 좁혔습니다. 그제서야 진짜 워크플로가 드러났습니다.

이 과정 자체가 교훈입니다. 품질이 안 나올 때 모델 등급부터 올리는 것은 게으른 선택입니다. 먼저 엔진을 측정하고, 노이즈의 원인을 데이터로 찾아 고쳐야 합니다.

## 3. 진화 판정: 업데이트냐, 신규냐, 분할이냐

후보가 나오면 마이너는 멈추고, 오케스트레이터 스킬 `chronicle-skill-miner`가 판정합니다. 코드의 중복 힌트는 참고일 뿐, 확정은 BM25 스킬 검색기로 다시 검증합니다.

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
<div class="d3-arch" data-arch-root id="nsintoselfevolvingskills-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 701, "height": 838, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 279, "y": 24, "w": 135, "h": 62, "title": ["memory/sessions", "801 세션"]}, {"id": "B", "x": 272, "y": 164, "w": 149, "h": 62, "title": ["chronicle_mine.py", "결정론 엔진"]}, {"id": "C", "x": 276, "y": 304, "w": 142, "h": 62, "title": ["후보 + 빈도", "update/create 태깅"]}, {"id": "D", "x": 278, "y": 444, "w": 138, "h": 68, "title": ["retrieve.py", "중복 검증"]}, {"id": "E", "x": 549, "y": 604, "w": 120, "h": 62, "title": ["UPDATE", "기존 스킬에 병합"]}, {"id": "F", "x": 374, "y": 604, "w": 120, "h": 62, "title": ["CREATE", "신규 스킬"]}, {"id": "G", "x": 199, "y": 604, "w": 120, "h": 62, "title": ["SPLIT", "능력별 분리"]}, {"id": "H", "x": 24, "y": 604, "w": 120, "h": 62, "title": ["DISCARD", "사유와 함께"]}, {"id": "I", "x": 451, "y": 744, "w": 142, "h": 62, "title": ["retrieve.py 재인덱싱", "라우터에 노출"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [347, 86, 347, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [347, 226, 347, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [347, 366, 347, 444]}, {"src": "D", "dst": "E", "kind": "data", "label": "동일 능력", "curve": [[416, 499], [609, 558], [609, 558], [609, 604]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "새 능력", "curve": [[384, 512], [434, 558], [434, 558], [434, 604]], "off": "50%"}, {"src": "D", "dst": "G", "kind": "data", "label": "여러 능력", "curve": [[309, 512], [259, 558], [259, 558], [259, 604]], "off": "50%"}, {"src": "D", "dst": "H", "kind": "data", "label": "중복/단발/저신뢰", "curve": [[278, 499], [84, 558], [84, 558], [84, 604]], "off": "50%"}, {"src": "E", "dst": "I", "kind": "data", "curve": [[609, 666], [609, 705], [609, 705], [560, 744]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[434, 666], [434, 705], [434, 705], [483, 744]]}]});
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
      const container = document.getElementById('nsintoselfevolvingskills-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nsintoselfevolvingskills-1';
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

실제로 801개 세션을 돌렸더니, 흥미로운 결론이 나왔습니다. 사용자의 반복 워크플로 대부분은 이미 기존 스킬 생태계가 커버하고 있었습니다. 주식 분석은 stock-jarvis, 소셜 인입은 x-to-slack, 깃헙 변환은 skill-seekers가 이미 담당합니다. 정직한 큐레이션 결과는 "대부분 폐기"였습니다. 중복 스킬을 양산하는 것이 아니라, 진짜로 빠진 워크플로 단 하나만 신규로 만드는 것이 옳습니다.

그 하나는 "내용을 docs 폴더 아래 영어 계획 문서로, 적절한 스킬을 라우팅해서, 소프트웨어 공학 핵심만" 이라는 사용자의 시그니처 워크플로였습니다. 39회 넘게 반복됐지만 어떤 스킬도 정확히 커버하지 않았습니다. 이것만 신규로 만들고, 트리거가 약했던 기존 스킬 하나를 보강했습니다. 나머지는 사유와 함께 폐기했습니다. 조용히 버리지 않고 임계 미달로 떨군 패턴 수까지 명시하는 것이 규칙입니다.

이 접근이 비슷한 상용 기능과 다른 점은 두 가지입니다. 첫째, 결정론 엔진이 카운팅과 노이즈 필터를 소유해 빈도 환각을 원천 차단합니다. 둘째, 1600개가 넘는 기존 스킬과 검색 기반으로 중복을 강제 검증합니다.

## 4. selfharness: 실패를 근거로 스킬 본문을 고친다

스킬을 만들었다고 끝이 아닙니다. 스킬은 실제 운영에서 틀리고, 그 틀린 방식에는 패턴이 있습니다. selfharness-evolve는 그 실패 패턴을 근거로 스킬의 본문을 스스로 고칩니다. Self-Harness 논문(arXiv:2606.09498)을 SKILL.md 콘텐츠에 이식한 것입니다.

세 단계로 돕니다.

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
<div class="d3-arch" data-arch-root id="nsintoselfevolvingskills-2"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 424, "height": 756, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 90, "y": 24, "w": 191, "h": 62, "title": ["실제 실패 트레이스", "세션 교정·피드백·룰 사고기록·라우터 로그"]}, {"id": "B", "x": 79, "y": 164, "w": 212, "h": 94, "title": ["1. Weakness Mining", "φ = (cause, causal_status,", "mechanism)", "으로 군집화"]}, {"id": "C", "x": 100, "y": 336, "w": 170, "h": 78, "title": ["2. Harness Proposal", "군집당 1 메커니즘", "편집면만 최소 수정 (+20% 상한)"]}, {"id": "D", "x": 93, "y": 492, "w": 184, "h": 78, "title": ["3. Proposal Validation", "한 컨텍스트 3회 반복 채점", "비회귀 게이트"]}, {"id": "E", "x": 204, "y": 662, "w": 156, "h": 62, "title": ["라이브 SKILL.md 자동 반영", "baseline 백업"]}, {"id": "F", "x": 28, "y": 670, "w": 120, "h": 46, "title": "거부"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [185, 86, 185, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [185, 258, 185, 336]}, {"src": "C", "dst": "D", "kind": "data", "line": [185, 414, 185, 492]}, {"src": "D", "dst": "E", "kind": "data", "label": "held-in·validation 개선<br/>sealed test 회귀 없음", "curve": [[230, 570], [282, 616], [282, 616], [282, 662]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "sealed test 회귀 = 오버핏", "curve": [[140, 570], [88, 616], [88, 616], [88, 670]], "off": "50%"}]});
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
      const container = document.getElementById('nsintoselfevolvingskills-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nsintoselfevolvingskills-2';
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

1단계 약점 채굴은 실제 실패를 `φ = (원인, 인과상태, 메커니즘)` 시그니처로 군집화하고, 지지도와 실행가능성으로 순위를 매깁니다. 트레이스의 `cause`는 wrong_output, missing_step, stale_data, ignored_constraint, format_violation 같은 고정 집합에서 옵니다. 출처는 사용자가 스킬을 교정한 세션, 피드백 메모리, 룰 사고 기록, 라우터 로그입니다.

2단계 제안은 상위 군집을 변이 엔진(hermes)에 표적 피드백으로 넘깁니다. 한 변이는 한 메커니즘만 건드리고, 해당 군집의 편집면만 최소로 수정합니다. 성장률은 +20%로 하드 제한합니다. 신선도나 가드레일 수정은 보통 3~5줄입니다.

3단계 검증이 가장 중요합니다. 같은 컨텍스트에서 최소 3회 반복 채점하고, held-in과 validation이 모두 개선되어야 통과합니다. 그리고 결정적으로 `test` 분할은 봉인됩니다. 게이트는 절대 test를 보지 않습니다. 만약 통과했는데 봉인된 test가 회귀하면 그것은 오버핏으로 간주해 거부합니다. 이것이 논문 자체의 held-out 누수 문제를 고친 leak-free 설계입니다. 프론트매터와 모든 트리거 문구는 보존됩니다.

## 5. 두 개의 독립적인 자율 루프

여기서 자주 헷갈리는 지점을 명확히 합니다. 우리에게는 직교하는 두 개의 진화 루프가 있습니다.

하나는 방금 설명한 selfharness로, 스킬의 내용 품질을 진화시킵니다. 다른 하나는 `skill_retro.py`와 `skill_model_policy.json`으로, 스킬이 어떤 모델 티어에서 도는지를 진화시킵니다. 후자는 기본 sonnet으로 싸게 시작했다가, 연속 2회 실패하면 그 스킬만 opus로 자동 승격합니다. 깨끗하게 성공하면 실패 streak를 초기화합니다.

콘텐츠의 품질과 실행의 비용은 서로 다른 문제이고, 그래서 서로 다른 루프가 담당합니다. 이 비용 쪽 이야기는 다음 글에서 따로 다룹니다.

## ThakiCloud 관점: 쓸수록 똑똑해지는 운영

우리가 이 두 루프를 직접 운영하는 이유는 단순합니다. 1인 엔지니어가 1600개가 넘는 스킬 생태계를 관리하려면, 생태계가 사람의 개입 없이도 스스로 정돈되고 자라야 하기 때문입니다.

이것은 우리가 고객에게 제공하려는 온프레미스 AI 플랫폼의 철학과 같습니다. 좋은 자동화는 한 번 만들고 방치되는 것이 아니라, 실제 사용 데이터를 근거로 스스로 개선됩니다. 결정론 코드가 측정과 카운팅을 소유하고, 모델은 판단이 필요한 곳에만 비싸게 투입되며, 모든 변경은 비회귀 게이트를 통과해야 라이브에 반영됩니다. 환각을 구조적으로 막고, 비용을 데이터로만 올리는 이 규율이 우리가 파는 신뢰의 근거입니다.

## 마무리

반복되는 일은 스킬이 되어야 하지만, 아무 반복이나 스킬이 되어서는 안 됩니다. 우리는 과거 대화를 결정론 엔진으로 캐내 진짜 반복만 골라내고, 기존 생태계와 중복을 강제 검증하며, 만든 스킬을 실패 근거로 leak-free하게 진화시킵니다. 빈도는 코드가 세고, 품질은 비회귀 게이트가 지키고, 비용은 별도 루프가 통제합니다.

ThakiCloud는 이런 자기개선형 에이전트 운영을 온프레미스 환경에서 그대로 구현합니다. 같은 규율을 여러분의 인프라 위에서 돌리고 싶다면, 홈페이지에서 더 많은 이야기를 확인하실 수 있습니다.
