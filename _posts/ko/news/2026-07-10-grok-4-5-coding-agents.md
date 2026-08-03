---
title: "Grok 4.5, 코딩과 에이전트를 겨냥해 나오다: 값싼 Opus급이 바꾸는 계산"
seo_title: "Grok 4.5 코딩 에이전트 모델 분석 - Thaki Cloud"
seo_description: "SpaceXAI가 공개한 Grok 4.5는 코딩과 자율 에이전트를 겨냥해 훈련된 첫 모델로, Opus급 성능을 낮은 가격에 제공합니다. 토큰당 지능에 투자한 RL 훈련, Cursor 통합, 그리고 ThakiCloud의 에이전트 클라우드 관점에서 이 발표가 의미하는 바를 분석합니다."
excerpt: "SpaceXAI가 Grok 4.5를 공개했습니다. 코딩과 에이전트를 위해 처음부터 훈련됐고, Opus급 성능을 백만 토큰당 입력 2달러·출력 6달러에 제공합니다. 값싼 에이전트 지능이 만드는 계산의 변화를 ThakiCloud 관점에서 짚습니다."
date: 2026-07-10
tags:
  - grok
  - xai
  - coding-agents
  - llm-pricing
  - agentic-coding
  - reinforcement-learning
categories:
  - news
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/news/grok-4-5-coding-agents/"
audiobook: /assets/audio/posts/grok-4-5-coding-agents/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

에이전트로 코드를 짜 본 팀이라면 한 가지 벽을 압니다. 긴 작업 하나를 에이전트에게 맡기면, 모델은 파일을 읽고 도구를 호출하고 다시 생각하기를 수십 번 반복합니다. 이 과정에서 토큰이 빠르게 쌓이고, 성능 좋은 모델일수록 그 비용이 뼈아프게 다가옵니다. 지금까지 "가장 똑똑한 코딩 모델"과 "실제로 하루 종일 굴릴 만한 모델"은 서로 다른 이야기였습니다. SpaceXAI가 공개한 Grok 4.5는 바로 이 간극을 겨냥합니다.

![코드와 에이전트 작업이 흐르는 추상적 파이프라인을 형상화한 이미지]({{ '/assets/images/grok-4-5-coding-agents-hero.png' | relative_url }})
*코딩과 에이전트 작업을 위해 처음부터 설계된 모델이라는 방향성을 추상적으로 형상화했습니다.*

## 개요

Grok 4.5는 SpaceXAI가 코딩과 자율 에이전트를 위해 처음부터 훈련했다고 밝힌 모델입니다. 소비자용 챗봇이라기보다 개발과 지식 노동을 위한 도구로 포지셔닝됐고, 큰 코드베이스·도구 사용·장기 실행 작업을 겨냥합니다. Elon Musk는 이 모델을 "Opus급이지만 더 빠르고 토큰 효율이 높으며 비용이 낮은" 모델이라고 소개했습니다. 여기서 참조된 Opus는 최근까지 Anthropic의 최상위 모델군이었습니다.

이 발표가 단순한 신모델 출시 이상인 이유는 가격과 훈련 방식에 있습니다. Grok 4.5는 백만 입력 토큰당 2달러, 백만 출력 토큰당 6달러로 책정됐습니다. 프론티어급 성능을 이 가격대에 내놓는 것은, "똑똑한 모델은 비싸서 에이전트로 오래 굴리기 어렵다"는 그동안의 전제를 흔듭니다. ThakiCloud 관점에서 이 변화는 남의 일이 아닙니다. 값싼 에이전트 지능은 곧 에이전트를 상시 운용하는 플랫폼의 경제성을 바꾸기 때문입니다.

![새 모델의 정체성, 토큰당 지능의 진화, 에이전트 단가 변화, ThakiCloud 전략적 함의로 이어지는 분석 흐름]({{ '/assets/images/grok-4-5-coding-agents-slide-02.png' | relative_url }})
*이 글은 새 모델의 정체성부터 토큰당 지능, 에이전트 단가 변화, ThakiCloud 전략적 함의까지 네 갈래로 짚습니다.*

## 무엇이 발표되었나

공개된 사실을 정리하면 다음과 같습니다. Grok 4.5는 코딩과 에이전트 작업에 특화해 훈련된 SpaceXAI의 첫 모델이며, 회사는 이 모델이 엔지니어링과 지식 노동에서 동급 모델을 능가한다고 주장합니다. 훈련은 코드 편집기 Cursor와 나란히 이뤄졌는데, SpaceXAI가 Cursor를 인수한 뒤 그 사용 환경 안에서 모델을 다듬었다는 맥락입니다. 실제로 Grok 4.5는 출시와 함께 Cursor의 모든 플랜에서 쓸 수 있고, Grok Build와 SpaceXAI 콘솔에서도 제공됩니다. 다만 발표 시점 기준으로 EU에서는 아직 사용할 수 없습니다.

훈련 인프라도 공개됐습니다. 회사는 이 모델을 수만 개의 NVIDIA GB300 GPU에 걸쳐 훈련했고, 토큰당 지능(per-token intelligence)에 강화학습(RL)을 크게 투자했다고 밝혔습니다. SpaceXAI는 바로 이 투자가 Opus 4.8 대비 토큰 효율 격차를 만들었다고 설명합니다. 즉 같은 작업을 더 적은 토큰으로 처리하도록 학습시켰다는 것이며, 이는 곧 실사용 비용의 절감으로 이어집니다.

![Opus급 성능을 더 빠르고 저렴하게, Cursor 훈련 파트너와 수만 개 GB300 GPU 인프라]({{ '/assets/images/grok-4-5-coding-agents-slide-03.png' | relative_url }})
*소비자용 챗봇이 아니라 큰 코드베이스·도구 사용·장기 실행 작업을 겨냥한 아키텍처로, Cursor 환경에서 훈련되고 수만 개 GB300 GPU로 학습됐습니다.*

## '코딩·에이전트 전용 훈련'이 의미하는 것

"코딩과 에이전트를 위해 훈련했다"는 표현은 마케팅 문구로 흘려듣기 쉽지만, 그 안에는 구체적인 설계 방향이 담겨 있습니다. 일반 대화형 모델은 폭넓은 주제에 자연스럽게 답하도록 최적화됩니다. 반면 에이전트 모델은 여러 스텝에 걸쳐 도구를 호출하고, 중간 결과를 관찰하고, 계획을 수정하며 긴 작업을 완수하는 능력이 핵심입니다. 이 능력은 단일 응답의 품질만으로는 학습되지 않으며, 궤적 전체의 성공 여부를 보상 신호로 되먹이는 강화학습이 큰 역할을 합니다.

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
<div class="d3-arch" data-arch-root id="260710grok45codingagents-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 422, "height": 770, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 28, "y": 24, "w": 120, "h": 46, "title": "개발자 작업 지시"}, {"id": "B", "x": 24, "y": 148, "w": 128, "h": 46, "title": "에이전트: 코드베이스 탐색"}, {"id": "C", "x": 255, "y": 286, "w": 135, "h": 46, "title": "도구 호출 파일 편집·테스트"}, {"id": "D", "x": 207, "y": 424, "w": 120, "h": 46, "title": "중간 결과 관찰"}, {"id": "E", "x": 109, "y": 548, "w": 138, "h": 52, "title": "작업 완료?"}, {"id": "F", "x": 118, "y": 692, "w": 120, "h": 46, "title": "최종 산출물"}, {"id": "G", "x": 207, "y": 148, "w": 120, "h": 46, "title": "토큰당 지능 RL 훈련"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [88, 70, 88, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[115, 194], [168, 240], [168, 240], [271, 286]]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[323, 332], [323, 378], [323, 378], [286, 424]]}, {"src": "D", "dst": "E", "kind": "data", "curve": [[267, 470], [267, 509], [267, 509], [213, 548]]}, {"src": "E", "dst": "B", "kind": "data", "label": "\"아니오\"", "curve": [[138, 548], [78, 447], [78, 309], [85, 194]], "off": "50%"}, {"src": "E", "dst": "F", "kind": "data", "label": "\"예\"", "line": [178, 600, 178, 692], "lx": 178, "ly": 642}, {"src": "G", "dst": "C", "kind": "event", "label": "영향", "curve": [[286, 194], [323, 240], [323, 240], [323, 286]], "off": "50%"}, {"src": "G", "dst": "D", "kind": "event", "label": "영향", "curve": [[241, 194], [188, 240], [188, 378], [241, 424]], "off": "50%"}]});
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
      const container = document.getElementById('260710grok45codingagents-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '260710grok45codingagents-1';
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

SpaceXAI가 강조한 "토큰당 지능"은 이 맥락에서 읽어야 합니다. 에이전트가 긴 작업을 돌 때 토큰 소비가 폭증하는 구조적 이유는, 모델이 같은 결론에 도달하기까지 필요 이상으로 장황하게 생각하거나 불필요한 도구 호출을 반복하기 때문입니다. 토큰당 더 많은 판단을 담도록 훈련하면, 같은 작업을 더 짧은 궤적으로 끝낼 수 있습니다. Cursor라는 실제 코딩 환경 안에서 훈련했다는 점도 여기에 맞물립니다. 실사용 도구 호출 패턴을 학습 신호로 쓰면, 에이전트가 도구를 더 효율적으로 다루도록 유도할 수 있습니다.

![구불구불한 기존 에이전트 궤적과 곧게 뻗은 Grok 4.5의 RL 최적화 궤적 비교]({{ '/assets/images/grok-4-5-coding-agents-slide-05.png' | relative_url }})
*기존 에이전트가 불필요한 도구 호출과 장황한 사고로 궤적을 늘리는 반면, 궤적 전체의 성공을 보상으로 학습한 모델은 더 적은 스텝으로 목적에 도달합니다.*

## 가격이 만드는 변화

프론티어급 성능을 백만 입력 2달러, 출력 6달러에 제공한다는 것은 에이전트 운용의 손익 계산을 바꿉니다. 에이전트가 하루 종일 코드베이스를 오가며 수백만 토큰을 소비하는 워크플로에서는, 토큰 단가가 곧 서비스의 마진을 결정합니다. 성능이 비슷하다면 더 싼 모델이 이깁니다. 실제로 여러 분석은 Grok 4.5가 Fable 5나 GPT 5.5보다 훨씬 저렴해, 벤치마크 격차가 크지 않다면 가격만으로도 선택받을 수 있다고 지적합니다.

![백만 입력 2달러, 출력 6달러라는 가격이 무너뜨리는 비용 장벽]({{ '/assets/images/grok-4-5-coding-agents-slide-04.png' | relative_url }})
*백만 토큰당 입력 2달러·출력 6달러라는 가격은 코드 리뷰 자동화·상시 모니터링·대규모 리팩터링처럼 단가에 막혀 있던 에이전트 워크플로를 경제적으로 풀어 줍니다.*

이 지점이 중요한 이유는, 값싼 에이전트 지능이 그동안 비용 때문에 접었던 워크플로를 다시 열어 주기 때문입니다. 코드 리뷰 자동화, 대규모 리팩터링, 상시 모니터링 에이전트처럼 토큰을 많이 먹는 작업일수록 단가 인하의 효과가 큽니다. 다만 이 계산에는 단서가 붙습니다. 낮은 API 단가는 클라우드 벤더에 종속되는 대가이기도 합니다. 데이터가 외부로 나가고, 가격 정책과 가용성이 벤더의 결정에 좌우됩니다. Grok 4.5가 아직 EU에서 제공되지 않는다는 사실은 이 종속성이 실재하는 리스크임을 보여 줍니다.

## ThakiCloud 관점

값싼 에이전트 모델의 등장은 ThakiCloud의 두 제품 모두와 맞닿아 있습니다.

Paxis 관점에서 보면, Grok 4.5 같은 저비용·고성능 에이전트 모델은 Agent-Native Cloud의 전제를 강화합니다. Paxis는 ai-platform 위에서 도는 에이전트 제어 평면으로, 스킬·도구·정책·감사 로그를 일급 리소스로 다룹니다. 에이전트가 긴 작업을 수십 스텝에 걸쳐 수행하는 구조에서는, 어떤 모델을 쓰든 그 행동을 정책 게이트로 통과시키고 감사 로그로 남기는 계층이 필요합니다. 모델이 싸질수록 에이전트를 더 많이, 더 오래 굴리게 되고, 그럴수록 오케스트레이션과 거버넌스의 가치가 커집니다. 값싼 지능은 에이전트 플랫폼의 필요를 줄이는 것이 아니라 오히려 키웁니다.

ai-platform 관점에서는 자체 호스팅과의 트레이드오프가 선명해집니다. 낮은 API 단가는 매력적이지만, 데이터 주권·규제 대응·온프레미스 요구가 있는 조직에는 종속성이 걸림돌입니다. ThakiCloud의 ai-platform은 K8s·Kueue 기반으로 오픈웨이트 모델을 자체 환경에서 서빙하며, 데이터를 밖으로 내보내지 않고도 에이전트 워크플로를 운용할 수 있게 합니다. Grok 4.5가 보여 준 "토큰당 지능"과 효율적 서빙의 결합은, 자체 호스팅 진영에도 같은 방향의 과제를 던집니다. 즉 값싼 클라우드 API와 경쟁하려면, 온프레미스에서도 토큰 효율과 낮은 서빙 비용을 함께 달성해야 합니다. 이는 정확히 낮은 서빙 비용을 경쟁력으로 삼는 우리의 지향과 겹칩니다.

![에이전트 오케스트레이션 제어 평면의 가치 상승과 온프레미스 서빙의 과제]({{ '/assets/images/grok-4-5-coding-agents-slide-07.png' | relative_url }})
*값싼 지능은 오히려 스킬·도구·정책·감사 로그를 다루는 제어 평면의 필요를 키우고, 동시에 온프레미스가 클라우드 API와 경쟁하려면 토큰 효율과 낮은 서빙 비용을 함께 달성해야 하는 과제를 남깁니다.*

## 한계 및 반론

이 발표를 평가할 때는 몇 가지를 유보해야 합니다. 먼저 성능 주장의 상당 부분은 회사 자체 발표에 기반합니다. "Opus급", "동급 능가" 같은 표현은 독립적인 벤치마크로 교차 검증되기 전까지는 마케팅으로 취급하는 편이 안전합니다. 실제 코딩·에이전트 작업에서의 우열은 사용자별 워크로드에 따라 크게 갈립니다.

둘째, 가격 경쟁력이 곧 최선의 선택을 뜻하지는 않습니다. 값싼 단가는 벤더 종속·데이터 이동·가용성 리스크와 함께 옵니다. EU 미제공처럼 지역·규제 제약이 실제로 존재하며, 이런 제약은 국내 공공·금융처럼 데이터 주권이 중요한 영역에서 결정적 걸림돌이 될 수 있습니다. 성능과 가격만 보고 도입을 결정하면, 나중에 규제·거버넌스 요구에 부딪혀 되돌아와야 할 수 있습니다.

![벤더 종속성, 지정학적 제약, 검증 대기라는 세 가지 도입 전제 조건과 리스크]({{ '/assets/images/grok-4-5-coding-agents-slide-08.png' | relative_url }})
*값싼 단가는 벤더 종속과 데이터 주권 포기를 요구하고, EU 미제공 같은 지정학적 제약이 실재하며, 성능 주장은 독립 벤치마크로 교차 검증되기 전까지 유보해야 합니다.*

마지막으로 이 글의 사실은 공개된 보도와 회사 발표를 종합한 것입니다. 세부 벤치마크 수치나 정확한 훈련 디테일은 원문에서 직접 확인해야 하며, 시간이 지나며 독립 평가가 쌓이면 그림이 달라질 수 있습니다.

## 출처

- [Axios, "Scoop: SpaceXAI launches new model, Grok 4.5"](https://www.axios.com/2026/07/08/spacexai-grok-new-model)
- [TechCrunch, "SpaceXAI releases Grok 4.5, which Elon describes as an 'Opus-class model'"](https://techcrunch.com/2026/07/08/spacexai-releases-grok-4-5-which-elon-describes-as-an-opus-class-model/)
- [The Decoder, "Grok 4.5 is so cheap compared to Fable 5 and GPT 5.5 that benchmark gaps may not matter much"](https://the-decoder.com/grok-4-5-is-so-cheap-compared-to-fable-5-and-gpt-5-5-that-benchmark-gaps-may-not-matter-much/)
