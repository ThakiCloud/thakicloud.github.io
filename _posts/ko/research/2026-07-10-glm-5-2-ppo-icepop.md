---
title: "GRPO에서 다시 PPO로: GLM-5.2가 IcePop으로 RL을 안정화한 방법"
seo_title: "GLM-5.2 PPO IcePop 강화학습 분석 - Thaki Cloud"
seo_description: "GLM-5.2가 GRPO 대신 학습된 value model을 쓰는 PPO로 돌아가고, IcePop으로 학습-추론 분포 불일치를 잡은 과정을 분석합니다. slime·Megatron·SGLang 인프라와 ThakiCloud LLM 훈련 플랫폼 적용 관점까지 정리합니다."
excerpt: "요즘 RL 포스트트레이닝의 대세는 critic을 버리는 GRPO 계열입니다. 그런데 GLM-5.2는 value model을 되살린 PPO로 돌아가고, IcePop으로 학습-추론 불일치를 잡았습니다. 이 선택의 근거와 ThakiCloud 훈련 인프라 관점의 시사점을 정리합니다."
date: 2026-07-10
tags:
  - reinforcement-learning
  - ppo
  - grpo
  - icepop
  - glm
  - llm-training
  - rlhf
categories:
  - research
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/glm-5-2-ppo-icepop/"
---

대규모 언어 모델의 강화학습(RL) 포스트트레이닝을 실제로 돌려 본 팀이라면, 지난 1~2년의 흐름이 한 방향으로 쏠려 있었다는 사실을 압니다. DeepSeek이 GRPO를 공개한 이후, 별도의 value model(critic)을 없애고 그룹 내부의 상대 보상만으로 advantage를 추정하는 방식이 사실상 표준처럼 자리 잡았습니다. critic을 학습시키지 않아도 되니 메모리와 연산이 절약되고, 구현도 단순해집니다. "critic은 이제 필요 없다"는 이야기가 반쯤은 정설처럼 통했습니다.

그런데 Zhipu가 공개한 GLM-5.2는 이 흐름을 정면으로 거스릅니다. 이 모델은 그룹 상대 방식을 버리고 학습된 value model을 다시 쓰는 PPO로 돌아갔고, 대신 RL의 고질적 불안정 요인인 학습-추론 분포 불일치를 IcePop이라는 기법으로 잡았습니다. 흥미로운 점은 이 선택이 단순한 회귀가 아니라, "GRPO가 만능"이라는 최근의 통념을 실측으로 반박하는 성격을 띤다는 것입니다.

![GRPO에서 PPO로 되돌아가는 강화학습 경로를 형상화한 추상 이미지]({{ '/assets/images/glm-5-2-ppo-icepop-hero.webp' | relative_url }})
*critic을 버렸다가 다시 불러오는 RL 포스트트레이닝의 방향 전환을 형상화했습니다.*

## 개요

GLM-5.2는 100만 토큰 컨텍스트 윈도우를 갖고 장기 호흡의 코딩·에이전트 벤치마크에서 강한 성능을 보인 오픈웨이트 모델입니다. 이 글이 다루는 것은 모델 자체의 성능 수치가 아니라, 그 성능을 만든 RL 포스트트레이닝의 설계 결정입니다. 핵심은 두 가지입니다. 첫째, 그룹 상대 방식(GRPO) 대신 학습된 value model을 쓰는 PPO로 돌아갔다는 것. 둘째, 그 과정에서 발생하는 학습-추론 불일치를 IcePop으로 완화하되, 원래 IcePop 정식화에 있던 KL 정규화 항을 제거해 RL 개선 속도를 끌어올렸다는 것입니다.

이 주제가 ThakiCloud 관점에서 중요한 이유가 있습니다. 우리가 운용하는 LLM 훈련 파이프라인은 SFT·CPT·DPO·GRPO·GKD 같은 여러 포스트트레이닝 방법을 지원합니다. RL 방법론의 선택은 단순한 알고리즘 취향이 아니라, GPU 예산·학습 안정성·재현성에 직접 영향을 주는 인프라 결정입니다. GLM-5.2의 사례는 "무엇을 쓸 것인가"보다 "왜 그것을 쓰는가"를 다시 묻게 만듭니다.

![전통적 PPO에서 GRPO를 거쳐 GLM-5.2의 PPO 회귀로 이어지는 RL 포스트트레이닝의 구조적 흐름]({{ '/assets/images/glm-5-2-ppo-icepop-slide-02.webp' | relative_url }})
*전통적 PPO에서 GRPO로, 다시 GLM-5.2의 PPO 회귀로 이어지는 RL 포스트트레이닝의 구조적 흐름입니다. 알고리즘은 한 방향으로만 진화하지 않습니다.*

## GRPO가 부딪힌 벽: critic을 버린 대가

먼저 왜 그렇게 많은 팀이 GRPO로 옮겨 갔는지부터 짚겠습니다. 전통적인 PPO는 actor-critic 구조입니다. 정책(actor)이 토큰을 생성하고, 별도의 value model(critic)이 각 상태의 기대 보상을 추정합니다. 이 value 추정치로 advantage를 계산하고(대개 GAE), 클리핑된 surrogate 목적함수로 정책을 업데이트합니다. 문제는 이 critic을 학습시키는 비용입니다. 정책과 거의 같은 크기의 모델을 하나 더 얹어야 하고, critic이 잘못 수렴하면 전체 학습이 흔들립니다.

GRPO는 이 critic을 아예 없앱니다. 같은 프롬프트에 대해 여러 응답을 샘플링한 뒤, 그 그룹 안에서 보상을 정규화해 상대적 우열만으로 advantage를 만듭니다. critic이 사라지니 메모리가 줄고, value 학습의 불안정성도 함께 사라집니다. 수학적으로도 깔끔해서 빠르게 퍼졌습니다.

![Actor와 Critic 두 모델을 함께 두는 PPO와 Critic을 덜어 낸 GRPO의 구조 비교]({{ '/assets/images/glm-5-2-ppo-icepop-slide-03.webp' | relative_url }})
*GRPO는 정책과 같은 크기의 critic을 덜어 내 메모리와 연산을 절약하지만, 그 대가로 그룹 내부의 상대 우열이라는 저해상도 신호만 남습니다.*

하지만 공짜 점심은 없었습니다. 그룹 상대 방식은 그룹 내부의 분산이 작을 때, 즉 응답들이 서로 비슷하게 좋거나 비슷하게 나쁠 때 advantage 신호가 뭉개집니다. 또한 긴 시퀀스에서 토큰 단위의 세밀한 credit assignment가 어렵습니다. value model이 있었다면 "이 토큰이 최종 보상에 얼마나 기여했는가"를 상태별로 추정할 수 있지만, 그룹 정규화만으로는 그 해상도가 나오지 않습니다. 장기 호흡의 코딩·에이전트 작업처럼 궤적이 길고 보상이 희소한 문제에서 이 한계가 두드러집니다. GLM-5.2가 겨냥한 영역이 바로 그런 문제였습니다.

![짧은 컨텍스트에서는 GRPO가 성공하지만 긴 컨텍스트에서는 그룹 정규화의 해상도가 무너지는 모습]({{ '/assets/images/glm-5-2-ppo-icepop-slide-04.webp' | relative_url }})
*짧은 궤적에서는 그룹 정규화가 잘 작동하지만, 궤적이 길어지고 보상이 희소해질수록 토큰 단위 신호의 해상도가 무너집니다.*

## GLM-5.2의 선택: value model을 되살린 PPO

GLM-5.2 팀은 여기서 학습된 value model을 다시 불러옵니다. 즉 GRPO가 버렸던 critic을 복원해, 토큰 단위의 advantage 추정 해상도를 되찾는 방향입니다. "PPO 하이프는 과장됐다"는 세간의 정서와 반대로, 이들은 오히려 잘 학습된 value model이 장기 궤적에서 더 안정적인 신호를 준다는 쪽에 베팅했습니다.

![critic을 되살려 에이전트 작업의 토큰 단위 신호를 되찾는 GLM-5.2의 설계 결정]({{ '/assets/images/glm-5-2-ppo-icepop-slide-05.webp' | relative_url }})
*GLM-5.2는 버려졌던 학습된 value model을 다시 불러와, 장기 호흡 에이전트 작업에서 토큰 단위의 고해상도 신호를 되찾는 쪽에 베팅했습니다.*

문제는 critic을 되살리는 순간, 앞서 언급한 학습의 불안정성도 함께 돌아온다는 점입니다. 그리고 여기에 최근 RL 스택 특유의 새로운 골칫거리가 하나 더 겹칩니다. 바로 학습-추론 분포 불일치입니다.

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
<div class="d3-arch" data-arch-root id="20260710glm52ppoicepop-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 430, "height": 930, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 137, "y": 24, "w": 120, "h": 46, "title": "프롬프트 배치"}, {"id": "B", "x": 190, "y": 148, "w": 120, "h": 62, "title": ["추론 엔진 SGLang", "롤아웃 생성"]}, {"id": "C", "x": 190, "y": 288, "w": 120, "h": 46, "title": "생성 토큰 + 보상"}, {"id": "D", "x": 186, "y": 412, "w": 128, "h": 62, "title": ["학습 엔진 Megatron", "forward 재계산"]}, {"id": "E", "x": 181, "y": 552, "w": 139, "h": 68, "title": ["추론 확률 ≠ 학습 확률", "분포 불일치"]}, {"id": "F", "x": 278, "y": 712, "w": 120, "h": 62, "title": ["중요도 비율 폭주", "학습 붕괴"]}, {"id": "G", "x": 103, "y": 712, "w": 120, "h": 62, "title": ["불일치 큰 토큰 억제", "안정적 정책 업데이트"]}, {"id": "H", "x": 24, "y": 852, "w": 170, "h": 46, "title": "value model PPO 업데이트"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[216, 70], [250, 109], [250, 109], [250, 148]]}, {"src": "B", "dst": "C", "kind": "data", "line": [250, 210, 250, 288]}, {"src": "C", "dst": "D", "kind": "data", "line": [250, 334, 250, 412]}, {"src": "D", "dst": "E", "kind": "data", "line": [250, 474, 250, 552]}, {"src": "E", "dst": "F", "kind": "data", "label": "\"보정 없음\"", "curve": [[287, 620], [338, 666], [338, 666], [338, 712]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "\"IcePop 마스킹\"", "curve": [[213, 620], [163, 666], [163, 666], [163, 712]], "off": "50%"}, {"src": "G", "dst": "H", "kind": "data", "curve": [[163, 774], [163, 813], [163, 813], [129, 852]]}, {"src": "H", "dst": "A", "kind": "data", "curve": [[91, 852], [60, 586], [60, 311], [146, 70]]}]});
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
      const container = document.getElementById('20260710glm52ppoicepop-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '20260710glm52ppoicepop-1';
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

## IcePop: 학습-추론 불일치를 잡는 법

현대의 RL 포스트트레이닝은 두 개의 서로 다른 엔진을 오갑니다. 롤아웃(응답 생성)은 SGLang 같은 고처리량 추론 엔진이 담당하고, 실제 정책 업데이트를 위한 forward 계산은 Megatron 같은 학습 엔진이 담당합니다. 문제는 이 두 엔진이 같은 모델 가중치를 쓰더라도 커널 구현·수치 정밀도·연산 순서가 달라, 같은 토큰에 대해 미묘하게 다른 확률을 내놓는다는 것입니다.

RL은 보통 중요도 샘플링(importance sampling)으로 이 간극을 보정합니다. 추론 시 정책과 학습 시 정책의 확률 비율을 곱해 주는 방식입니다. 그런데 두 분포가 어긋난 토큰에서는 이 비율이 폭발적으로 커지거나 작아집니다. 비율이 튀는 토큰 몇 개가 그래디언트를 지배하면 학습 전체가 흔들리고, 심하면 붕괴합니다. 궤적이 길수록, 즉 토큰이 많을수록 이런 튐이 누적될 확률이 높아집니다. 장기 호흡 작업을 겨냥한 GLM-5.2에게는 특히 치명적인 문제였습니다.

![학습 엔진 Megatron과 추론 엔진 SGLang의 확률 차이로 중요도 비율이 폭발하는 학습-추론 분포 불일치]({{ '/assets/images/glm-5-2-ppo-icepop-slide-07.webp' | relative_url }})
*같은 가중치라도 학습 엔진(Megatron)과 추론 엔진(SGLang)의 커널·정밀도 차이로 확률이 어긋나, 중요도 비율이 폭발하며 학습을 붕괴시킵니다.*

IcePop은 이 불일치를 정면으로 다룹니다. 추론 분포와 학습 분포가 크게 어긋나는 토큰을 식별해, 그 토큰의 기여를 억제하거나 마스킹하는 방식으로 그래디언트가 소수의 불안정 토큰에 끌려가지 않게 만듭니다. 결과적으로 안정적인 토큰의 신호만 살려 정책 업데이트에 반영합니다. 이렇게 하면 value model을 되살린 PPO의 이점을 취하면서도, 학습-추론 불일치가 일으키는 붕괴를 피할 수 있습니다.

GLM-5.2가 원래 IcePop과 다른 지점은 KL 정규화 항을 제거했다는 것입니다. 많은 RL 레시피는 정책이 참조 정책에서 너무 멀어지지 않도록 KL 페널티를 겁니다. 이 항은 안정성을 높이지만, 동시에 정책이 개선될 수 있는 폭을 억제합니다. GLM-5.2 팀은 IcePop의 분포 불일치 마스킹이 이미 불안정성을 상당 부분 잡아 준다고 보고, KL 항을 떼어 내 정책이 더 공격적으로 개선되도록 허용했습니다. 안정성 장치를 하나 덜어 내는 대신, 그 역할을 IcePop의 토큰 선별에 맡긴 셈입니다.

![불안정 토큰을 식별해 마스킹하고 KL 정규화 항까지 제거하는 IcePop의 세 단계]({{ '/assets/images/glm-5-2-ppo-icepop-slide-08.webp' | relative_url }})
*IcePop은 분포가 크게 어긋나는 토큰을 식별해 그 기여를 억제하고, GLM-5.2는 여기서 KL 정규화 항까지 제거해 정책 개선의 폭을 넓혔습니다.*

## 인프라: slime, Megatron, SGLang

이 알고리즘이 종이 위의 아이디어에 그치지 않고 실제로 돌아가려면, RL 스케일링을 견디는 인프라가 필요합니다. GLM-5.2의 포스트트레이닝은 slime라는 RL 스케일링 프레임워크 위에서 이뤄졌고, 분산 학습에는 Megatron-LM을, 고처리량 롤아웃 생성에는 SGLang을 씁니다. 앞서 설명한 학습-추론 불일치가 바로 이 구성에서 나옵니다. Megatron(학습)과 SGLang(추론)이 각자 최적화된 커널을 쓰기 때문에 확률이 어긋나는 것이고, IcePop은 정확히 이 구조적 간극을 겨냥한 대응입니다.

즉 IcePop은 순수한 알고리즘 개선이라기보다, 학습 엔진과 추론 엔진을 분리한 현대적 RL 스택에서 필연적으로 발생하는 시스템 수준의 문제에 대한 시스템-알고리즘 공동 설계에 가깝습니다. 이 점이 실무자에게 주는 교훈은 분명합니다. RL 방법론을 고를 때는 알고리즘만 보면 안 되고, 그 알고리즘이 어떤 학습·추론 엔진 조합 위에서 도는지를 함께 봐야 합니다.

## ThakiCloud 제품 적용 시사점

ThakiCloud의 ai-platform은 K8s 기반의 AI/ML 인프라로, Kueue를 통한 GPU 스케줄링과 다양한 포스트트레이닝 방법(SFT·CPT·DPO·GRPO·GKD)을 지원하는 훈련 파이프라인을 운용합니다. GLM-5.2의 사례는 이 파이프라인의 설계에 직접적인 시사점을 줍니다.

![ThakiCloud ai-platform 위에 slime 런타임과 Paxis Agent-Native Cloud가 쌓이는 계층 구조]({{ '/assets/images/glm-5-2-ppo-icepop-slide-09.webp' | relative_url }})
*K8s·Kueue 기반의 ai-platform이 학습-추론 불일치를 방어하고, 그 위에서 모듈형 RL 런타임과 Paxis의 장기 에이전트 워크플로가 동작하는 구조입니다.*

첫째, RL 방법론은 하나로 고정할 대상이 아니라 문제에 맞춰 고르는 선택지입니다. 짧은 궤적의 선호 정렬에는 critic 없는 GRPO가 여전히 경제적이지만, 긴 코딩·에이전트 궤적처럼 토큰 단위 credit assignment가 중요한 문제에서는 value model을 쓰는 PPO가 더 안정적인 신호를 줄 수 있습니다. 우리처럼 여러 방법을 한 플랫폼에서 지원하는 구조라면, 이 선택을 사용자가 문제 특성에 따라 바꿀 수 있게 노출하는 것이 실질적 가치를 만듭니다.

둘째, 학습-추론 불일치는 우리에게도 남의 일이 아닙니다. 롤아웃을 추론 엔진(vLLM/SGLang 계열)에서 뽑고 업데이트를 학습 엔진에서 도는 분리형 RL을 멀티테넌트 환경에서 돌리면, 같은 종류의 확률 불일치가 발생합니다. IcePop 같은 토큰 선별 보정을 훈련 런타임의 옵션으로 준비해 두면, 온프레미스·소버린 환경에서 자체 모델을 RL로 다듬으려는 고객의 학습 안정성을 크게 높일 수 있습니다. 낮은 서빙 비용과 안정적인 학습 파이프라인은 자체 호스팅을 검토하는 팀에게 결정적인 경쟁력입니다.

에이전트 관점에서는 Paxis와도 연결됩니다. Paxis는 ai-platform 위에서 도는 Agent-Native Cloud로, 스킬·도구·정책을 일급 리소스로 다룹니다. GLM-5.2가 강조한 장기 호흡 에이전트 궤적의 학습은, 결국 에이전트가 여러 스텝에 걸쳐 도구를 호출하며 작업을 완수하는 능력을 강화하는 일입니다. 잘 학습된 value model이 긴 궤적에서 세밀한 신호를 준다는 이 사례의 교훈은, Paxis가 다루는 다단계 에이전트 워크플로의 품질을 끌어올리는 학습 전략을 고민할 때 참고할 만한 지점입니다.

## 한계 및 반론

이 사례를 일반화할 때는 신중해야 합니다. 먼저 "PPO가 GRPO보다 낫다"는 단순 결론으로 읽으면 안 됩니다. GLM-5.2의 선택은 장기 호흡·희소 보상이라는 특정 문제 설정에서의 판단입니다. 짧고 밀도 높은 보상의 문제에서는 critic 유지 비용이 이득을 상쇄할 수 있고, 이 경우 GRPO가 여전히 합리적입니다. value model을 되살리는 순간 GPU 메모리 예산이 다시 늘어난다는 현실적 제약도 그대로입니다.

IcePop의 KL 항 제거도 만능은 아닙니다. KL 정규화는 정책이 참조 정책에서 폭주하는 것을 막는 안전장치입니다. 이를 떼어 내고 분포 불일치 마스킹에 안정성을 전적으로 맡기는 것은, 마스킹이 잘 작동한다는 전제 위에서만 성립합니다. 다른 데이터 분포나 다른 추론 엔진 조합에서는 이 전제가 깨질 수 있으므로, 그대로 이식하기보다 자체 환경에서 안정성을 검증하는 절차가 반드시 필요합니다.

마지막으로, 이 글의 기술적 설명은 공개된 분석과 논문(arXiv의 "GLM-5: from Vibe Coding to Agentic Engineering") 및 2차 해설을 종합한 것입니다. 세부 하이퍼파라미터나 정확한 벤치마크 수치는 원문에서 직접 확인해야 하며, 여기서 다루지 않은 구현 디테일이 실제 재현에서 결정적일 수 있습니다. RL 포스트트레이닝은 특히 재현이 까다로운 영역이므로, "이렇게 하면 된다"보다 "이런 방향으로 고민해 볼 수 있다"로 받아들이는 편이 안전합니다.

## 출처

- [arXiv, "GLM-5: from Vibe Coding to Agentic Engineering" (arXiv:2602.15763)](https://arxiv.org/abs/2602.15763)
- ["Why is GLM-5.2 So Good: The GRPO to PPO Switch", Medium (Coding Nexus)](https://medium.com/coding-nexus/why-is-glm-5-2-so-gooood-the-grpo-to-ppo-switch-5b3b7d613ace)
- ["Zhipu's GLM-5.2: A Usability Breakthrough for Chinese Open-Source Models?", Weijin Research](https://weijinresearch.substack.com/p/zhipus-glm-52-a-usability-breakthrough)
