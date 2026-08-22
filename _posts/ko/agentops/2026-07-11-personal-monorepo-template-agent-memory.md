---
title: "벡터DB 없이 폴더로 기억하는 코딩 에이전트: personal-monorepo-template 분석"
seo_title: "코딩 에이전트에 영구 기억 부여하기 - personal-monorepo-template - Thaki Cloud"
seo_description: "Instructor 창시자 jxnl이 공개한 personal-monorepo-template은 벡터DB 없이 평범한 폴더와 AGENTS.md만으로 코딩 에이전트에 영구 기억을 부여합니다. 구조를 분해하고 ThakiCloud Paxis 스킬 하네스 관점에서 검증합니다."
excerpt: "OpenAI Codex 팀 엔지니어 jxnl이 공개한 personal-monorepo-template은 벡터DB 없이 폴더 구조와 AGENTS.md만으로 에이전트에 영구 기억을 부여합니다. 이 설계를 분해하고 스킬을 일급 리소스로 다루는 ThakiCloud 관점에서 검증합니다."
date: 2026-07-11
tags:
  - agent-memory
  - coding-agent
  - agents-md
  - codex
  - agentops
  - paxis
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/personal-monorepo-template-agent-memory/"
published: false
---

코딩 에이전트를 매일 쓰다 보면 한 가지 벽에 반복해서 부딪힙니다. 어제 나눈 결정, 지난주에 정한 컨벤션, 특정 동료의 업무 스타일을 에이전트가 매 세션마다 처음 듣는 것처럼 다시 물어봅니다. 이 문제를 값비싼 벡터 데이터베이스나 별도 메모리 인프라 없이, 그냥 **평범한 폴더 구조와 마크다운 파일 하나로** 풀어낸 저장소가 최근 공개되어 개발자들 사이에서 화제가 되었습니다. `Instructor` 라이브러리를 만든 jxnl(Jason Liu)이 공개한 `personal-monorepo-template`입니다. 에이전트에 기억을 붙이려다 인프라부터 고민하고 있었다면, 폴더 구조만으로 어디까지 갈 수 있고 어디서 한계가 오는지가 여기서 확인할 지점입니다.

![벡터DB 없이 폴더로 기억하는 코딩 에이전트: personal-monorepo-template 분석 개념을 형상화한 이미지](/assets/images/personal-monorepo-template-agent-memory-hero.webp)
*글의 핵심 개념을 형상화했습니다.*

## 개요

에이전트의 기억 문제를 다루는 흔한 접근은 벡터 데이터베이스입니다. 대화와 문서를 임베딩해 저장하고, 필요할 때 의미 검색으로 꺼내 오는 방식입니다. 강력하지만 운영 부담이 큽니다. 임베딩 파이프라인, 벡터 인덱스, 재색인 스케줄을 모두 관리해야 하고, 개인이 자기 워크플로에 얹기에는 과한 인프라입니다.

`personal-monorepo-template`은 정반대 방향을 택합니다. 기억을 검색 문제가 아니라 **파일 구조 문제**로 재정의합니다. 사람은 `people/` 폴더에, 프로젝트는 프로젝트 패킷으로, 반복되는 작업 방식은 저장소 안의 스킬로 둡니다. 그리고 에이전트가 세션을 시작할 때마다 `AGENTS.md`를 통해 이 구조를 상시 로드합니다. 벡터 검색의 근사 일치 대신, 폴더 경로라는 정확한 주소로 기억에 접근하는 셈입니다.

만든 사람의 배경이 이 설계에 무게를 더합니다. jxnl은 구조화 출력(structured output) 라이브러리 `Instructor`의 창시자로, 이 라이브러리는 월 수백만 건 다운로드되며 OpenAI가 자사 structured output 기능의 영감으로 인용했다고 알려져 있습니다. 현재 그는 OpenAI Codex 팀의 개발자 경험(Developer Experience) 엔지니어로, 코딩 에이전트를 매일 실전에서 운용하는 사람이 자기 문제를 풀려고 만든 도구라는 점에서 참고 가치가 큽니다.

## 이 기술은 무엇인가

핵심 아이디어는 하나입니다. **에이전트의 기억을 모노레포 안의 평범한 폴더와 마크다운으로 표현하고, 세션마다 자동으로 로드합니다.** 세 가지 축으로 나눠 볼 수 있습니다.

첫째는 **사람과 프로젝트의 기록**입니다. 저장소는 슬랙, 이메일, 캘린더, 깃허브를 스캔해 `people` 파일과 프로젝트 패킷을 만들고, 상시 로드되는 `AGENTS.md`의 업데이트를 제안합니다. 특정 동료의 이름을 언급하면 에이전트가 그 사람의 파일을 읽어 맥락을 즉시 복원합니다. 벡터DB 없이도 "이 사람이 누구인지"를 정확한 폴더 경로로 찾아냅니다.

둘째는 **저장소 로컬 스킬**입니다. 반복되는 작업 방식을 저장소 안에 스킬로 넣어 두면, 세션마다 자동으로 로드되어 에이전트가 그 절차를 따릅니다. 대표적으로 보낸 이메일과 슬랙 메시지를 학습해 사용자의 문체로 글을 쓰는 write-like-me 스킬이 내장되어 있습니다. 사용자의 과거 산출물이 곧 스킬의 학습 데이터가 되는 구조입니다.

셋째는 **자동 체크인**입니다. 저장소는 매일 오전 9시와 오후 4시에 자동 체크인을 실행하도록 설계되어, 그날의 프로젝트 상태와 사람 관련 맥락을 정리하고 업데이트를 제안합니다. 에이전트가 수동 호출을 기다리는 것이 아니라 정해진 시각에 스스로 기억을 갱신하는 루프입니다.

전체 흐름을 도식으로 보면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="orepotemplateagentmemory-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 752, "height": 518, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "SRC", "x": 314, "y": 24, "w": 128, "h": 46, "title": "슬랙·이메일·캘린더·깃허브"}, {"id": "SCAN", "x": 228, "y": 162, "w": 120, "h": 46, "title": "체크인 스크립트"}, {"id": "PEOPLE", "x": 403, "y": 294, "w": 120, "h": 46, "title": "people 파일 제안"}, {"id": "PKT", "x": 228, "y": 294, "w": 120, "h": 46, "title": "프로젝트 패킷 제안"}, {"id": "AGD", "x": 24, "y": 294, "w": 149, "h": 46, "title": "AGENTS.md 업데이트 제안"}, {"id": "AGENT", "x": 403, "y": 440, "w": 120, "h": 46, "title": "코딩 에이전트"}, {"id": "SKILL", "x": 578, "y": 286, "w": 142, "h": 62, "title": ["저장소 로컬 스킬", "write-like-me 포함"]}, {"id": "CRON", "x": 110, "y": 24, "w": 149, "h": 46, "title": "매일 09시·16시 자동 체크인"}], "edges": [{"src": "SRC", "dst": "SCAN", "kind": "data", "label": "스캔", "curve": [[378, 70], [378, 116], [378, 116], [318, 162]], "off": "50%"}, {"src": "SCAN", "dst": "PEOPLE", "kind": "data", "curve": [[348, 206], [463, 247], [463, 247], [463, 294]]}, {"src": "SCAN", "dst": "PKT", "kind": "data", "line": [288, 208, 288, 294]}, {"src": "SCAN", "dst": "AGD", "kind": "data", "curve": [[228, 205], [99, 247], [99, 247], [99, 294]]}, {"src": "AGD", "dst": "AGENT", "kind": "event", "label": "세션 시작 시 상시 로드", "curve": [[99, 340], [99, 394], [99, 394], [403, 452]], "off": "50%"}, {"src": "PEOPLE", "dst": "AGENT", "kind": "event", "label": "폴더 경로로 조회", "line": [463, 340, 463, 440], "lx": 463, "ly": 390}, {"src": "SKILL", "dst": "AGENT", "kind": "event", "label": "자동 로드", "curve": [[649, 348], [649, 394], [649, 394], [523, 441]], "off": "50%"}, {"src": "CRON", "dst": "SCAN", "kind": "data", "curve": [[184, 70], [184, 116], [184, 116], [253, 162]]}]});
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
      const container = document.getElementById('orepotemplateagentmemory-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'orepotemplateagentmemory-1';
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

이 설계가 흥미로운 이유는, 정확히 이 저장소의 저자가 별도 글에서 정리한 "Codex-maxxing" 철학과 맞닿아 있기 때문입니다. 에이전트에게 더 좋은 모델을 붙이는 것이 아니라, 에이전트가 매번 백지에서 시작하지 않도록 **주변 구조를 두텁게 쌓는** 방향입니다.

## 설치 및 통합

이 저장소는 이름 그대로 템플릿입니다. 자신의 깃허브 계정으로 템플릿을 복제한 뒤, 코딩 에이전트(Codex 또는 유사 CLI)가 저장소 루트를 작업 디렉터리로 삼도록 설정하는 방식으로 통합합니다. 핵심 진입점은 저장소 루트의 `AGENTS.md`로, 에이전트가 세션을 시작할 때 이 파일을 읽어 폴더 구조와 사람·프로젝트 맥락, 그리고 로드해야 할 스킬 목록을 파악합니다.

여기서 중요한 통합 포인트는 `AGENTS.md`가 **단순 문서가 아니라 상시 로드되는 계약**이라는 점입니다. 세션마다 이 파일이 컨텍스트 앞머리에 들어가므로, 여기에 무엇을 적느냐가 곧 에이전트의 기본 행동을 정의합니다. 폴더 구조가 정해져 있으므로 에이전트는 "동료 A의 컨텍스트가 필요하면 `people/A.md`를 읽는다"처럼 결정론적으로 기억에 접근합니다. 벡터 검색의 확률적 근사와 달리, 파일 경로는 항상 같은 곳을 가리킵니다.

자동 체크인은 스케줄러(cron 계열)에 체크인 스크립트를 걸어 매일 정해진 시각에 실행하는 형태로 통합됩니다. 이 부분은 에이전트를 사람이 매번 호출하지 않아도 기억이 최신 상태로 유지되게 하는 장치이며, 동시에 비용 관점에서도 중요한 설계 결정입니다. 상시 폴링이 아니라 하루 두 번의 유한 실행이므로, 무한 루프로 토큰을 태우지 않습니다.

## 이 설계가 실제로 어떻게 동작하는가

이 저장소는 벤치마크 수치를 내세우는 도구가 아니라 **워크플로 패턴**입니다. 재현 가능한 성능 수치는 저장소가 제시하지 않으며, 저자 본인도 정량 지표가 아니라 일상 워크플로의 개선을 근거로 제시합니다. 그래서 판단 기준도 수치가 아니라 설계가 만들어 내는 구조적 효과여야 합니다.

가장 큰 효과는 **컨텍스트 복원 비용의 제거**입니다. 벡터DB 접근은 매 질의마다 임베딩 계산과 유사도 검색을 거치지만, 폴더 경로 접근은 파일 읽기 한 번입니다. 사람이 "지난번 그 프로젝트"라고 말하면 에이전트가 해당 프로젝트 패킷을 직접 읽고, 근사 검색의 오탐 없이 정확한 맥락을 복원합니다. 기억의 정밀도가 검색 품질이 아니라 폴더 설계 품질에 달리게 됩니다.

두 번째 효과는 **감사 가능성**입니다. 모든 기억이 사람이 읽을 수 있는 마크다운으로 저장되므로, 에이전트가 무엇을 알고 있는지 개발자가 직접 열어 확인하고 수정할 수 있습니다. 벡터 임베딩은 사람이 눈으로 검증하기 어렵지만, `people/A.md`는 그냥 텍스트 파일입니다. 에이전트의 기억이 틀렸을 때 그 자리에서 고칠 수 있다는 것은 실무에서 큰 차이를 만듭니다.

세 번째 효과는 **이식성**입니다. 특정 벡터DB 벤더나 임베딩 모델에 종속되지 않으므로, 저장소 자체가 곧 완결된 기억입니다. 다른 머신, 다른 에이전트로 옮겨도 폴더와 마크다운은 그대로 동작합니다. 인프라 종속이 없다는 점은 뒤에서 다룰 온프렘·소버린 관점과 직접 연결됩니다.

## ThakiCloud 제품 적용 시사점

이 설계는 ThakiCloud가 에이전트를 운용하는 두 축 모두와 맞닿습니다.

**Paxis 관점**에서 가장 직접적입니다. Paxis는 ThakiCloud의 Agent-Native Cloud 제어 평면으로, 스킬(Skills)·도구(Tools)·정책(Policies)·감사 로그(Audit Logs)를 일급 리소스로 다룹니다. `personal-monorepo-template`이 보여 주는 "저장소 로컬 스킬 + 상시 로드 계약(AGENTS.md)" 패턴은 Paxis의 스킬 하네스 설계 방향과 정확히 겹칩니다. Paxis는 이미 다수의 스킬을 BM25로 선택해 격리 샌드박스에서 실행하는데, 이 저장소의 접근은 그보다 앞단인 "어떤 지식을 세션 컨텍스트에 상시 둘 것인가"라는 문제를 폴더 구조로 명료하게 답합니다. 특히 기억을 사람이 읽을 수 있는 파일로 두고 모든 갱신을 감사할 수 있게 만든다는 점은, 모든 에이전트 행동을 정책 게이트와 감사 로그로 통과시키는 Paxis의 원칙과 같은 철학입니다. 에이전트의 능력을 모델 등급이 아니라 주변 구조에서 끌어낸다는 발상 자체가 스킬을 일급 리소스로 다루는 우리 설계와 동형입니다.

**ai-platform 관점**에서는 인프라 부담의 관점이 흥미롭습니다. ThakiCloud의 ai-platform은 K8s 기반 AI/ML 인프라로 온프렘·소버린 AI 고객사의 워크로드를 서빙합니다. 이런 고객에게 벡터DB를 상시 운영해야 하는 기억 아키텍처는 추가적인 인프라 표면과 관리 비용을 의미합니다. 반면 폴더와 마크다운으로 표현되는 기억은 별도 상태 저장소 없이 파일시스템만으로 동작하므로, 규제 환경이나 폐쇄망에서 운영 부담이 훨씬 적습니다. "기억 인프라를 최소화하면서도 에이전트에 지속성을 준다"는 각도는 소버린 AI를 요구하는 고객에게 실질적인 셀링 포인트가 될 수 있습니다.

## 한계 및 반론

이 설계가 만능은 아닙니다. 가장 분명한 한계는 **규모**입니다. 폴더 경로 접근은 기억의 주소를 사람이나 에이전트가 이미 알고 있을 때 강력합니다. 그러나 수만 개의 문서에서 "어디에 있는지 모르는" 정보를 찾아야 하는 상황에서는, 의미 기반 벡터 검색이 여전히 우월합니다. 이 저장소는 개인의 사람·프로젝트·경험이라는, 상대적으로 작고 구조가 뚜렷한 기억 공간을 전제로 합니다. 팀 전체의 방대한 지식베이스로 확장하면 폴더 구조만으로는 한계가 옵니다.

두 번째 반론은 **스캔의 프라이버시**입니다. 슬랙·이메일·캘린더를 스캔해 사람 파일을 만든다는 것은, 민감한 대화가 평문 마크다운으로 저장된다는 뜻이기도 합니다. 개인용으로는 편리하지만 조직에 도입하려면 접근 통제와 보존 정책이 반드시 필요합니다. 감사 가능성이 장점인 만큼, 그 파일에 누가 접근하는지에 대한 통제가 없으면 그대로 위험이 됩니다.

세 번째는 **자동 갱신의 신뢰성**입니다. 하루 두 번의 자동 체크인이 잘못된 요약을 사람 파일에 써 넣으면, 그 오류가 이후 세션에 계속 주입됩니다. 이 저장소가 갱신을 "제안"으로 두고 사람의 확인을 전제하는 이유가 여기에 있습니다. 완전 자동화로 밀어붙이면 기억이 조용히 오염될 수 있으므로, 사람이 검토하는 게이트를 남겨 두는 것이 안전합니다.

마지막으로, 이 접근은 "인간 비서 연봉 대비 무료 대안"으로 소개되지만, 실제로 이 수준의 워크플로를 유지하려면 저장소 구조를 스스로 설계하고 다듬을 수 있는 상당한 엔지니어링 역량이 필요합니다. 도구가 무료라는 것과 그것을 잘 운용하는 비용이 무료라는 것은 다른 이야기입니다.

그럼에도 이 저장소가 던지는 핵심 메시지는 분명합니다. 에이전트의 기억은 반드시 무거운 인프라여야 하는 것이 아니며, 좋은 폴더 구조와 상시 로드되는 계약만으로도 상당한 지속성을 얻을 수 있다는 것입니다. 이는 스킬과 지식을 일급 리소스로 다루는 ThakiCloud의 방향과 정확히 같은 곳을 가리킵니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`prismatic_tech` 스타일)으로 요약한 슬라이드입니다.

![personal-monorepo-template-agent-memory 슬라이드 1]({{ '/assets/images/personal-monorepo-template-agent-memory-slide-01.webp' | relative_url }})

![personal-monorepo-template-agent-memory 슬라이드 2]({{ '/assets/images/personal-monorepo-template-agent-memory-slide-02.webp' | relative_url }})

![personal-monorepo-template-agent-memory 슬라이드 3]({{ '/assets/images/personal-monorepo-template-agent-memory-slide-03.webp' | relative_url }})

![personal-monorepo-template-agent-memory 슬라이드 4]({{ '/assets/images/personal-monorepo-template-agent-memory-slide-04.webp' | relative_url }})

## 출처

- [jxnl/personal-monorepo-template (GitHub)](https://github.com/jxnl/personal-monorepo-template)
- [Codex-maxxing (jxnl.co)](https://jxnl.co/writing/2026/05/10/codex-maxxing/)
