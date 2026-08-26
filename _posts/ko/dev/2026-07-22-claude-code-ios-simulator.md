---
title: "Claude Code + iOS 시뮬레이터: 빌드하고 실행하고 직접 보는 닫힌 코딩 루프"
excerpt: "Claude Code 데스크톱이 iOS 시뮬레이터를 대화 옆 패널에 띄우는 기능을 공개 베타로 내놨습니다. 앱을 빌드해 실행하고, Claude가 실행 중인 화면을 직접 보며 고쳐 나가는 이 닫힌 루프가 무엇을 바꾸는지, 어떻게 켜는지, 그리고 에이전트 네이티브 클라우드 관점에서 왜 중요한지 정리했습니다."
date: 2026-07-22
tags:
  - ClaudeCode
  - iOS
  - 시뮬레이터
  - AI코딩
  - 에이전트루프
  - 개발생산성
  - Paxis
author_profile: true
toc: true
toc_label: iOS 시뮬레이터 루프 해부
published: true
categories:
  - dev
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/claude-code-ios-simulator/"
audiobook: /assets/audio/posts/claude-code-ios-simulator/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![실행 화면과 코드가 하나의 빛 고리로 이어지는 닫힌 루프를 형상화한 추상 이미지]({{ '/assets/images/claude-code-ios-simulator-hero.webp' | relative_url }})

## 왜 읽어야 하나

macOS에서 Claude Code로 iOS 앱을 만드는 개발자라면, 이 글의 결론은 하나입니다. 코딩 에이전트가 자기가 만든 앱을 직접 실행해 보고 화면을 관찰하면서 고치는 "닫힌 루프"가 이제 별도 도구 없이 데스크톱 앱 안에서 돌아간다는 것입니다. 새로 익힐 것은 많지 않습니다. 다만 이 변화는 단순한 편의 기능이 아니라, 에이전트가 코드 품질을 스스로 수렴시키는 방식 자체를 바꾸는 문제입니다.

## 개요

AI 코딩 에이전트가 정말로 유용해지는 순간은 코드를 한 번 뱉어 놓고 끝나는 게 아니라 그 코드가 실제로 동작하는지를 스스로 확인하고 다시 고칠 때입니다. 백엔드 코드라면 테스트를 돌려서 통과 여부라는 객관적 신호를 얻을 수 있습니다. 그런데 모바일 앱의 UI는 이야기가 다릅니다. 온보딩 화면이 의도대로 나오는지, 버튼을 눌렀을 때 다음 화면으로 넘어가는지는 눈으로 화면을 봐야 알 수 있는 영역이었습니다. 지금까지 이 확인은 사람의 몫이었고, 에이전트는 코드를 짜 놓고 사람이 시뮬레이터를 켜서 눌러 보고 피드백을 줄 때까지 멈춰 있었습니다.

2026년 7월 21일 Claude Code 데스크톱 앱은 이 간극을 정면으로 메우는 기능을 공개 베타로 내놨습니다. iOS 앱을 빌드해 실행하면 Apple의 iOS 시뮬레이터가 대화 바로 옆 패널에 열리고, Claude가 실행 중인 앱 화면을 직접 보면서 인터페이스와 상호작용하고, 원하는 대로 동작할 때까지 코드를 계속 고칩니다. 사람이 시뮬레이터를 켜서 확인하고 결과를 다시 말로 옮겨 주던 왕복이 하나의 루프 안으로 접혀 들어간 셈입니다.

다키클라우드는 에이전트 네이티브 클라우드를 만들면서 "에이전트가 자기 행동의 결과를 어떻게 관찰하고 다음 행동을 정하는가"라는 질문에 계속 부딪힙니다. 이번 기능은 그 질문에 대한 아주 구체적인 답 하나입니다. 그래서 단순한 기능 소개보다는 루프 설계의 관점에서 다뤄볼 가치가 있습니다.

![claude-code-ios-simulator 슬라이드 1]({{ '/assets/images/claude-code-ios-simulator-slide-01.webp' | relative_url }})

## iOS 시뮬레이터 연동은 무엇인가

핵심은 단순합니다. Claude Code 데스크톱에서 iOS 프로젝트를 열고 앱을 빌드해 실행해 달라고 하면, 시뮬레이터가 대화 옆 패널로 뜨고 Claude가 그 화면을 관찰 대상으로 삼습니다. 세션마다 독립된 시뮬레이터가 열리므로 여러 작업을 동시에 진행해도 서로의 화면이 섞이지 않습니다. 다만 이 패널은 로컬 세션에서만 동작하는데, 시뮬레이터 자체가 macOS 위에서만 도는 소프트웨어이기 때문입니다.

이 기능이 흥미로운 이유는 렌더링을 하나 더 붙인 게 아니라 에이전트에게 "관찰 채널"을 하나 더 열어 줬다는 데 있습니다. 이전까지 코딩 에이전트가 확인할 수 있는 신호는 대부분 텍스트였습니다. 컴파일러 오류, 테스트 결과, 로그 같은 것들입니다. 반면 앱이 실제로 어떻게 보이고 어떻게 반응하는지는 사람이 눈으로 보고 말로 옮겨 줘야만 에이전트에게 전달됐습니다. 시뮬레이터 연동은 이 시각적 결과를 에이전트가 직접 확인할 수 있는 신호로 바꿔 놓습니다.

전체 흐름을 단순화하면 아래와 같은 반복 루프가 됩니다.

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
<div class="d3-arch" data-arch-root id="22claudecodeiossimulator-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 554, "height": 1198, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 132, "y": 24, "w": 177, "h": 62, "title": ["iOS 프로젝트를", "Claude Code 데스크톱에서 열기"]}, {"id": "B", "x": 161, "y": 164, "w": 120, "h": 46, "title": "앱 빌드·실행 요청"}, {"id": "C", "x": 33, "y": 288, "w": 121, "h": 46, "title": "Claude가 빌드 실행"}, {"id": "D", "x": 24, "y": 412, "w": 138, "h": 52, "title": "빌드 성공?"}, {"id": "E", "x": 86, "y": 564, "w": 120, "h": 46, "title": "오류 로그 관찰"}, {"id": "F", "x": 261, "y": 556, "w": 120, "h": 62, "title": ["시뮬레이터 패널에", "앱 실행"]}, {"id": "G", "x": 261, "y": 696, "w": 121, "h": 62, "title": ["Claude가 실행 중인", "화면을 관찰"]}, {"id": "H", "x": 261, "y": 836, "w": 120, "h": 62, "title": ["인터페이스와", "상호작용·테스트"]}, {"id": "I", "x": 252, "y": 976, "w": 138, "h": 52, "title": "의도대로 동작?"}, {"id": "J", "x": 402, "y": 1120, "w": 120, "h": 46, "title": "코드 수정"}, {"id": "K", "x": 227, "y": 1120, "w": 120, "h": 46, "title": "반복 종료"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [221, 86, 221, 164]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[173, 210], [93, 249], [93, 249], [93, 288]]}, {"src": "C", "dst": "D", "kind": "data", "line": [93, 334, 93, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "실패", "curve": [[93, 464], [93, 510], [93, 510], [130, 564]], "off": "50%"}, {"src": "E", "dst": "B", "kind": "data", "curve": [[168, 564], [221, 438], [221, 311], [221, 210]]}, {"src": "D", "dst": "F", "kind": "data", "label": "성공", "curve": [[162, 460], [321, 510], [321, 510], [321, 556]], "off": "50%"}, {"src": "F", "dst": "G", "kind": "data", "line": [321, 618, 321, 696]}, {"src": "G", "dst": "H", "kind": "data", "line": [321, 758, 321, 836]}, {"src": "H", "dst": "I", "kind": "data", "line": [321, 898, 321, 976]}, {"src": "I", "dst": "J", "kind": "data", "label": "아니오", "curve": [[353, 1028], [409, 1074], [409, 1074], [444, 1120]], "off": "50%"}, {"src": "J", "dst": "B", "kind": "data", "curve": [[467, 1120], [477, 797], [477, 438], [281, 202]]}, {"src": "I", "dst": "K", "kind": "data", "label": "예", "curve": [[309, 1028], [287, 1074], [287, 1074], [287, 1120]], "off": "50%"}]});
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
      const container = document.getElementById('22claudecodeiossimulator-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22claudecodeiossimulator-1';
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

그림에서 보이듯, 사람의 개입은 처음 요청과 마지막 확인에만 있고 가운데의 빌드·실행·관찰·수정은 에이전트 안에서 돕니다. 백엔드 개발에서 테스트 러너가 통과와 실패라는 객관적 신호를 돌려주며 루프를 닫는 것과 정확히 같은 구조를, 이번에는 시각적 UI 영역에서 시뮬레이터가 맡는 것입니다.

![claude-code-ios-simulator 슬라이드 2]({{ '/assets/images/claude-code-ios-simulator-slide-02.webp' | relative_url }})

## 어떻게 켜고 쓰는가

이 기능은 별도의 복잡한 설정을 요구하지 않습니다. 대신 몇 가지 전제 조건이 분명합니다. 먼저 macOS여야 합니다. iOS 시뮬레이터는 Apple 생태계 밖에서는 돌지 않기 때문에 Windows나 Linux에서는 이 패널을 쓸 수 없습니다. 여기에 더해 iOS 플랫폼이 설치된 Xcode가 있어야 합니다. Claude가 실제로 빌드를 수행하고 시뮬레이터를 띄우는 밑단은 결국 Xcode의 빌드 도구와 시뮬레이터이기 때문입니다. 요금제 측면에서는 Pro, Max, Team 플랜 사용자가 이 기능을 쓸 수 있습니다.

사용 자체는 대화형입니다. Claude Code 데스크톱에서 iOS 프로젝트를 열고 그 앱의 프로젝트 폴더를 지정해 세션을 시작합니다. iOS 시뮬레이터용 앱을 빌드하는 프로젝트라면 어떤 것이든 동작합니다. 그다음 Claude에게 앱을 실행하거나 테스트해 달라고 요청하면 됩니다. 예를 들어 "앱을 빌드해서 시뮬레이터로 실행하고 온보딩 흐름을 확인해 줘"처럼 자연어로 지시하면, Claude가 빌드를 돌리고 시뮬레이터 패널에 앱을 띄운 뒤 그 화면을 관찰하며 확인 작업을 진행합니다.

정리하면 새로 외워야 할 명령어나 설정 파일은 사실상 없습니다. 바뀌는 것은 "에이전트에게 무엇을 시킬 수 있는가"의 범위입니다. 지금까지 "이 화면이 이렇게 나오게 고쳐 줘"라고 부탁한 뒤 사람이 직접 켜서 확인해야 했다면, 이제는 그 확인까지 지시 안에 포함시킬 수 있습니다. 공개 베타 단계인 만큼 세부 동작은 앞으로 다듬어지겠지만, 상호작용 모델의 방향은 이미 분명합니다.

![claude-code-ios-simulator 슬라이드 3]({{ '/assets/images/claude-code-ios-simulator-slide-03.webp' | relative_url }})

## 닫힌 루프가 코딩 에이전트에 주는 것

이 기능의 진짜 의미는 편의성보다 루프의 완결성에 있습니다. 에이전트가 유용하려면 자기 출력을 검증할 방법이 있어야 하고, 그 검증이 사람의 눈과 손에 매번 의존하면 에이전트는 반쪽짜리 자동화에 머무릅니다. iOS UI 작업은 그동안 이 반쪽 상태의 대표적인 사례였습니다. 코드는 에이전트가 짜지만, 그 결과가 화면에서 맞는지는 사람이 봐야 하는 몫이었습니다.

시뮬레이터를 대화 옆에 붙이고 에이전트가 실행 화면을 관찰하게 하면, 관찰과 판단과 수정이 한 루프 안에서 이어집니다. 빌드가 실패하면 오류를 읽고 고치고, 앱이 뜨면 화면을 보고 의도와 다른 부분을 찾아 다시 고칩니다. 이 반복이 사람의 왕복 없이 돌아간다는 점이 핵심입니다. 물론 이 관찰은 화면을 캡처해 확인하는 방식이라 사람이 손으로 만지며 느끼는 미묘한 인터랙션까지 완벽히 대체하지는 못합니다. 그럼에도 "코드를 고쳤는데 화면이 어떻게 바뀌었는지 모른 채 다음 지시를 기다리는" 단절이 사라진다는 것만으로도 작업의 결이 달라집니다.

이 구조는 다키클라우드가 내부적으로 정리해 온 루프 엔지니어링 원칙과도 맞닿아 있습니다. 신뢰할 수 있는 피드백은 통과와 실패를 객관적으로 돌려주는 결정론적 신호이고, 에이전트의 자기 보고("잘 된 것 같습니다")는 루프의 종료 조건이 될 수 없다는 원칙입니다. 시뮬레이터는 그 결정론적 신호를 시각 영역으로 확장하는 장치입니다. 빌드 성공 여부는 이미 명확한 신호였고, 이제 실행 화면이라는 또 하나의 관찰 채널이 붙으면서 UI 작업의 루프가 한층 촘촘하게 닫힙니다.

![claude-code-ios-simulator 슬라이드 4]({{ '/assets/images/claude-code-ios-simulator-slide-04.webp' | relative_url }})

## ThakiCloud 제품 적용 시사점

이번 기능은 에이전트 주제이므로 Paxis 렌즈로 보는 것이 자연스럽습니다. Paxis는 다키클라우드의 에이전트 네이티브 클라우드로, 스킬과 도구와 정책과 감사 로그를 일급 리소스로 다루며, 스킬을 격리된 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. Claude Code의 시뮬레이터 연동이 보여 주는 "빌드하고 실행하고 관찰하고 고치는 닫힌 루프"는 Paxis가 지향하는 실행 모델과 정확히 같은 계열입니다. 에이전트가 격리된 환경에서 무언가를 실행하고 그 결과를 관찰해 다음 행동을 정하되, 그 과정이 통제된 경계 안에서 이루어진다는 구조입니다.

Paxis 관점에서 이 사례가 주는 시사점은 두 가지로 모입니다. 하나는 에이전트에게 실행 결과를 관찰할 채널을 열어 주는 것이 자동화의 깊이를 결정한다는 점입니다. 텍스트 신호만으로는 닫히지 않던 UI 작업의 루프가 시각적 관찰 채널 하나로 닫히는 것처럼, Paxis에서도 각 스킬이 자기 산출물을 검증할 신호를 갖추는 것이 품질의 관건입니다. 다른 하나는 그 실행이 세션마다 격리된 환경에서 이루어진다는 점입니다. Claude Code가 세션별로 독립된 시뮬레이터를 여는 것처럼, Paxis의 샌드박스 격리 실행도 여러 에이전트 작업이 서로를 오염시키지 않도록 보장하는 같은 원리로 설계돼 있습니다.

인프라 관점에서 한 줄 덧붙이면, 이런 닫힌 루프가 실용적이 되려면 실행 환경을 값싸고 빠르게 띄우고 거둘 수 있어야 합니다. 다키클라우드의 ai-platform이 쿠버네티스 위에서 격리된 실행 환경을 효율적으로 스케줄링하는 역량은, 에이전트 루프를 대규모로 돌릴 때의 경제성을 뒷받침하는 밑단이 됩니다. 저비용의 격리 실행이 있어야 관찰과 수정을 반복하는 에이전트 루프가 비용 부담 없이 돌아갑니다.

## 한계 및 반론

이 기능을 과대평가하지 않기 위해 경계도 분명히 해야 합니다. 우선 플랫폼이 macOS로 못 박혀 있습니다. iOS 시뮬레이터가 Apple 밖에서 돌지 않기 때문에 어쩔 수 없는 제약이지만, 그만큼 이 루프는 Mac 사용자에게만 열려 있습니다. Xcode 설치도 필수 전제이고, Pro와 Max와 Team 플랜에서만 쓸 수 있으며, 패널은 로컬 세션에 한정됩니다. 원격 세션이나 팀 공유 환경에서 같은 경험을 기대하기는 아직 이릅니다.

기능 자체도 공개 베타입니다. 발표와 함께 공개된 것은 동작 방식과 사용법이지, 이 루프가 실제로 얼마나 빠르고 정확하게 수렴하는지에 대한 벤치마크가 아닙니다. 따라서 "얼마나 좋아지는가"를 수치로 단언할 수는 없습니다. 또한 에이전트의 화면 관찰은 실행 화면을 캡처해 확인하는 방식이라, 사람이 실제 기기에서 손끝으로 느끼는 제스처의 미세한 반응이나 성능 체감까지 대체하지는 못합니다. 복잡한 애니메이션, 접근성 동작, 실기기에서만 드러나는 문제는 여전히 사람의 검증이 필요합니다.

마지막 반론은 이렇습니다. 이런 편의가 오히려 검토 없는 신뢰로 이어질 위험이 있습니다. 루프가 매끄럽게 돌수록 사람은 결과를 그대로 받아들이기 쉬워집니다. 에이전트가 "확인했습니다"라고 말한다고 해서 그 판단이 곧 검증은 아닙니다. 시뮬레이터 관찰은 유용한 신호이지 최종 승인이 아니며, 특히 사용자 경험의 미묘한 부분은 여전히 사람이 직접 눌러 보고 판단해야 합니다.

## 정리

Claude Code의 iOS 시뮬레이터 연동은 작아 보이지만 방향은 분명합니다. 코딩 에이전트가 자기가 만든 것을 직접 실행해 관찰하고 고치는 닫힌 루프가, UI라는 그동안 사람에게 의존하던 영역까지 확장됐다는 것입니다. macOS에서 Claude Code로 iOS 앱을 만드는 개발자라면 지금 시도해 볼 만한 변화이고, 무엇을 시킬 수 있는지의 범위가 넓어졌다는 점에서 작업 방식 자체를 다시 생각하게 합니다.

더 크게 보면, 이 사례는 에이전트를 유용하게 만드는 것이 모델의 크기만이 아니라 "결과를 관찰해 다음 행동을 정하는 루프를 얼마나 잘 닫는가"라는 하니스의 문제라는 점을 다시 확인시켜 줍니다. 다키클라우드가 Paxis와 ai-platform으로 풀고 있는 문제도 정확히 이것입니다. 다음에 에이전트에게 UI 작업을 맡길 때는 코드를 고쳐 달라는 데서 멈추지 말고, "실행해서 확인까지 해 줘"라고 지시해 보십시오. 루프를 닫는 주체를 사람에서 에이전트로 옮기는 것, 이번 기능이 주는 가장 실용적인 변화는 바로 여기에 있습니다.


## 출처

- [Claude Code 공식 문서: Test iOS apps in the simulator](https://code.claude.com/docs/en/desktop-ios-simulator)
- [ClaudeDevs 발표 (X)](https://x.com/ClaudeDevs/status/2079674432038248611)
- [9to5Mac: Claude Code brings live iOS app testing into its Mac app](https://9to5mac.com/2026/07/21/claude-code-brings-live-ios-app-testing-into-its-mac-app/)
- [MacRumors: Claude Code Can Now Build and Test iOS Apps in Apple's Simulator](https://www.macrumors.com/2026/07/21/claude-code-ios-simulator/)
