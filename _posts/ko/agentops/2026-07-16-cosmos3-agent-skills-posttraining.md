---
title: "에이전트가 GPU 학습을 직접 운전한다: NVIDIA Cosmos 3 에이전트 스킬 해부"
seo_title: "NVIDIA Cosmos 3 에이전트 스킬 포스트트레이닝 분석 - Thaki Cloud"
seo_description: "NVIDIA가 공개한 TAO 에이전트 스킬로 코딩 에이전트가 Cosmos 3 비전 모델의 LoRA 파인튜닝과 AutoML 스윕을 자동으로 운전합니다. 프롬프트 두 개로 검증 정확도가 54.41%에서 93.35%까지 오른 워크플로를 뜯어보고, 스킬을 일급 리소스로 다루는 ThakiCloud Paxis와 GPU 학습을 스케줄링하는 ai-platform 관점에서 무엇을 옮길 수 있는지 정리합니다."
excerpt: "코딩 에이전트에게 자연어 프롬프트 두 개를 주면 비전 파운데이션 모델의 포스트트레이닝이 하루 만에 끝납니다. NVIDIA의 에이전트 스킬을 해부하고, 스킬을 일급 리소스로 다루는 우리 플랫폼에 무엇이 옮겨지는지 봅니다."
date: 2026-07-16
tags:
  - agent-skills
  - post-training
  - lora
  - automl
  - cosmos-3
  - tao
  - nvidia
  - gpu
  - mlops
  - vision-language
categories:
  - agentops
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/agentops/cosmos3-agent-skills-posttraining/"
published: false
---

지난주 우리는 디자인시스템 UI 생성 실험에서 "모델보다 게이트를 먼저 만들어야 한다"는 결론에
도달했습니다. NVIDIA가 이번에 공개한 Cosmos 3 포스트트레이닝 사례는 그 이야기의 다른 절반입니다.
여기서는 사람이 게이트를 손으로 만드는 대신, **에이전트 스킬**이라는 캡슐화된 지식을 코딩 에이전트에게
쥐여 주고, 그 에이전트가 파인튜닝과 평가와 하이퍼파라미터 탐색을 직접 운전합니다. 읽는 대상은
자기 인프라 위에서 파운데이션 모델을 포스트트레이닝하려는 ML·플랫폼 엔지니어입니다. 결론부터 말하면,
이 사례의 진짜 주인공은 모델도 GPU도 아니라 **워크플로 지식을 스킬로 굳혀 에이전트가 반복 실행하게
만든 하네스**입니다.

![중앙 오케스트레이션 노드가 GPU 서버 무리를 지휘하는 추상 일러스트]({{ '/assets/images/cosmos3-agent-skills-posttraining-hero.png' | relative_url }})
*에이전트 스킬은 GPU 학습·평가·튜닝의 반복 노동을 지휘합니다. 사람은 프롬프트로 목적만 줍니다.*

## Cosmos 3와 에이전트 스킬은 무엇인가

Cosmos 3는 NVIDIA가 물리 세계를 다루기 위해 만든 파운데이션 모델입니다. 텍스트와 이미지, 영상,
주변 소리, 동작 추적을 하나로 묶는 Mixture-of-Transformers 구조를 쓰고, 논리와 계획을 담당하는
자기회귀 추론 타워와 미래 상태를 예측하는 디퓨전 트랜스포머를 함께 갖습니다. NVIDIA는 이 모델이
VANTAGE-Bench, PAI-Bench, Physics-IQ, RoboLab, RoboArena 여러 벤치마크에서 1위라고 밝혔습니다.
크기는 64B의 Cosmos 3 Super와 16B의 Cosmos 3 Nano가 있고, 이번 사례는 Nano를 씁니다.

핵심은 모델이 아니라 그 옆에 붙은 **TAO 에이전트 스킬**입니다. TAO 에이전트 스킬은 비전 모델의
포스트트레이닝 워크플로를 자동화하는 지식 묶음입니다. 프레임워크 세부, 런처 동작, config 구조,
데이터 로딩 방식, 평가 워크플로 같은 태스크별 지식을 캡슐화해서, Codex나 Claude 같은 코딩 에이전트가
사람의 개입을 최소한으로 하고도 학습 파이프라인을 스스로 조율하게 만듭니다. 다시 말해 스킬은
프롬프트 한 줄이 아니라, 실행 가능한 절차와 실패 복구까지 포장한 재사용 단위입니다.

## 두 개의 프롬프트로 끝나는 포스트트레이닝

이 사례가 인상적인 이유는 사람이 입력한 것이 자연어 프롬프트 두 개뿐이라는 점입니다.

첫 번째 프롬프트는 LoRA 포스트트레이닝을 지시합니다. Toyota의 Woven Traffic Safety 데이터셋으로
`nvidia/Cosmos3-Nano`를 LoRA로 학습하되, 비교를 위해 베이스라인 평가를 먼저 하라는 요청입니다.

```
Perform LoRA post-training of the Cosmos 3 model on the Woven Traffic
Safety dataset. Training data: /home/.../WTS_dataset/wts_data_train
Validation data: /home/.../WTS_dataset/wts_data_val
Base model on Hugging Face: nvidia/Cosmos3-Nano
Also perform a baseline evaluation first, to compare with the post-trained model.
```

이 프롬프트 하나로 에이전트는 여러 일을 순서대로 처리했습니다. 데이터 파이프라인에서 누락된 FPS
파라미터를 스스로 찾아 오류를 패치하고, Hugging Face 토큰으로 모델을 캐싱하고, 학습 전 zero-shot
베이스라인을 54.41%로 측정한 다음, LoRA 학습을 돌렸습니다. 여기서 눈여겨볼 대목은 "베이스라인
평가를 먼저 하라"는 지시입니다. 학습 후 결과를 자기 보고로 믿는 대신, 학습 전 숫자를 측정 기준선으로
박아 두고 개선을 실제로 잰 것입니다. 지난주 우리 실험에서 얻은 교훈과 정확히 같은 원리입니다.

두 번째 프롬프트는 AutoML 스윕입니다. 탐색 전략과 어떤 하이퍼파라미터를 튜닝할지는 TAO에게 맡기고,
검증 정확도를 최적화한 뒤 가장 좋은 모델을 요약하라는 요청입니다.

```
Run an AutoML sweep to improve the LoRA result. Let TAO choose suitable
search strategies and tune the important training hyperparameters. Optimize
validation accuracy and summarize the best models.
```

전체 흐름을 도식으로 보면 사람은 양 끝에만 있고, 가운데의 반복 작업은 스킬이 채웁니다.

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
<div class="d3-arch" data-arch-root id="3agentskillsposttraining-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 666, "height": 990, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 253, "y": 24, "w": 170, "h": 62, "title": ["자연어 프롬프트", "(LoRA 학습 + 베이스라인 평가)"]}, {"id": "B", "x": 267, "y": 164, "w": 142, "h": 62, "title": ["코딩 에이전트", "(Codex / Claude)"]}, {"id": "C", "x": 267, "y": 304, "w": 142, "h": 78, "title": ["TAO 에이전트 스킬", "프레임워크·런처·config·", "데이터로딩·평가 지식 캡슐화"]}, {"id": "D", "x": 485, "y": 460, "w": 149, "h": 62, "title": ["자동 오류 패치", "(누락된 FPS 파라미터 보정)"]}, {"id": "E", "x": 246, "y": 460, "w": 184, "h": 62, "title": ["모델 캐싱", "(HF 토큰으로 Cosmos3-Nano)"]}, {"id": "F", "x": 35, "y": 460, "w": 156, "h": 62, "title": ["베이스라인 평가", "(zero-shot 54.41%)"]}, {"id": "G", "x": 35, "y": 600, "w": 156, "h": 62, "title": ["LoRA 포스트트레이닝", "(8×A100, 에폭당 ~30분)"]}, {"id": "H", "x": 31, "y": 740, "w": 163, "h": 62, "title": ["AutoML 스윕", "(43개 병렬 시도, 19.5시간)"]}, {"id": "I", "x": 24, "y": 880, "w": 177, "h": 78, "title": ["최적 어댑터 서빙", "Cosmos 3 Reasoner NIM", "(OpenAI 호환 엔드포인트)"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [338, 86, 338, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [338, 226, 338, 304]}, {"src": "C", "dst": "D", "kind": "data", "curve": [[409, 368], [559, 421], [559, 421], [559, 460]]}, {"src": "C", "dst": "E", "kind": "data", "line": [338, 382, 338, 460]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[267, 368], [113, 421], [113, 421], [113, 460]]}, {"src": "F", "dst": "G", "kind": "data", "line": [113, 522, 113, 600]}, {"src": "G", "dst": "H", "kind": "data", "line": [113, 662, 113, 740]}, {"src": "H", "dst": "I", "kind": "data", "line": [113, 802, 113, 880]}]});
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
      const container = document.getElementById('3agentskillsposttraining-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '3agentskillsposttraining-1';
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

환경 준비는 토큰 세 개와 설치 스크립트 한 줄입니다. 터미널에 `HUGGINGFACE_TOKEN`, `NGC_API_KEY`,
`AUTOML_LLM_API_KEY`를 넣고, 아래 스크립트로 에이전트 스킬을 설치합니다.

```bash
export HUGGINGFACE_TOKEN="your_hf_token"
export NGC_API_KEY="your_ngc_key"
export AUTOML_LLM_API_KEY="your_llm_key"

curl -fsSL https://raw.githubusercontent.com/NVIDIA-TAO/tao-skills-bank/main/scripts/install-codex-agents.sh | bash
```

학습 데이터는 Toyota의 Woven Traffic Safety 데이터셋으로, 8,000개가 넘는 학습·검증 샘플을 가진
영상 질의응답 과제입니다. 도로 구조, 도로 유형, 교통 안전 상황을 묻는 4지선다 문제로 구성됩니다.

## 두 프롬프트가 만든 숫자

성능은 명확하게 올랐습니다. 아래 수치는 전부 NVIDIA가 공개한 값이며, 우리가 재현한 결과가 아닙니다.

![Cosmos 3 Nano 베이스라인·LoRA·AutoML 세 단계의 WTS 영상 QA 검증 정확도 막대그래프]({{ '/assets/images/cosmos3-agent-skills-posttraining-results.png' | relative_url }})
*프롬프트 두 개로 검증 정확도가 54.41%에서 93.35%까지 올랐습니다. NVIDIA 공개 수치.*

zero-shot 베이스라인은 54.41%였고, 단일 프롬프트 LoRA가 87.14%로 32.73포인트 올렸습니다. 여기에
AutoML 스윕이 베이지안 최적화로 하이퍼파라미터를 조율해 93.35%까지, 베이스라인 대비 38.94포인트를
끌어올렸습니다. 사람이 손으로 하이퍼파라미터를 만지지 않고, 에이전트가 탐색 전략을 고르고 반복
학습을 돌려서 얻은 숫자라는 점이 핵심입니다.

비용 쪽 숫자도 함께 봐야 정직합니다. LoRA 학습은 8장의 A100 80GB에서 에폭당 약 30분이 걸렸고,
AutoML 스윕은 여러 A100 노드에 걸쳐 43개 시도를 병렬로 돌려 19.5시간이 걸렸습니다. 비교군으로 돌린
풀 파라미터 SFT는 H100에서 3시간 34분이 걸렸는데, LoRA는 이 풀 SFT 대비 GPU 시간을 약 7분의 1로
줄였다고 NVIDIA는 밝혔습니다. 학습이 끝난 뒤에는 Cosmos 3 Reasoner NIM이 LoRA 어댑터를 OpenAI 호환
엔드포인트로 서빙합니다. vLLM 의존성이나 CUDA 설정을 손으로 맞출 필요 없이 사전 빌드된 마이크로
서비스로 바로 배포되는 구조입니다.

## 우리는 이것을 직접 돌려봤나

정직하게 밝히면, 이 워크플로를 우리 환경에서 재현하지는 못했습니다. Cosmos 3 계열 가중치는 게이트가
걸린 Hugging Face 저장소이고, 8장의 A100과 NGC 및 AutoML LLM 키가 필요하며, 사례가 쓴 병렬
스윕은 여러 GPU 노드를 전제로 합니다. 우리는 이 자원 조합을 이 글을 위해 확보하지 않았습니다.
그래서 위의 모든 숫자는 NVIDIA 공개 값을 인용한 것이고, 우리가 측정한 결과처럼 제시하지 않습니다.
재현 없이 만든 벤치마크는 만들지 않는다는 원칙을 지킵니다. 대신 우리가 할 수 있는 것은 이 사례의
구조를 뜯어보고, 우리 플랫폼에서 이미 돌고 있는 것과 무엇이 같고 무엇이 다른지 정확히 대조하는
일입니다.

## ThakiCloud 제품 적용 시사점

이 사례는 우리 두 제품의 관점이 모두 맞물리는 드문 주제입니다.

**Paxis 렌즈에서 보면, 이것은 스킬을 일급 리소스로 다룬다는 우리 명제의 외부 검증입니다.** Paxis는
ThakiCloud의 Agent-Native Cloud 제어 평면으로, Skills와 Tools, Policies, Audit Logs를 일급 리소스로
취급합니다. Skill Harness는 960개가 넘는 스킬을 BM25로 골라 격리된 샌드박스에서 실행하고, 모든 행동을
정책 게이트와 감사 로그로 통과시킵니다. NVIDIA의 TAO 에이전트 스킬이 증명한 것은, 프레임워크 세부와
실패 복구까지 캡슐화한 스킬이 있으면 코딩 에이전트가 복잡한 워크플로를 안정적으로 반복한다는 사실입니다.
이는 우리가 스킬을 프롬프트가 아니라 실행 단위로 정의해 온 방향과 정확히 같습니다. 다만 차이도 분명합니다.
TAO 스킬은 NVIDIA 스택에 강하게 묶여 있어 TAO 런처와 Cosmos 모델, NGC와 NIM을 벗어나면 그대로
쓰기 어렵습니다. Paxis의 스킬 하네스는 특정 벤더나 모델에 종속되지 않는 것을 목표로 하며, 이 지점이
우리가 온프렘과 소버린 환경에서 제공하려는 가치의 핵심입니다.

**ai-platform 렌즈에서 보면, 이것은 우리가 매일 스케줄링하는 GPU 학습·서빙 그 자체입니다.** 43개의
AutoML 시도를 여러 노드에 병렬로 던지는 일은 우리 플랫폼에서 Kueue가 GPU 큐를 관리하는 방식과
직접 겹칩니다. LoRA 어댑터를 OpenAI 호환 엔드포인트로 서빙하는 NIM은 우리가 vLLM으로 제공하는 서빙
경로와 같은 문제를 풉니다. 그리고 LoRA가 풀 SFT 대비 GPU 시간을 크게 줄인다는 사실은, 저비용 서빙과
저비용 학습이 결국 에이전트 경제성을 만든다는 우리 논지를 뒷받침합니다. 고객이 자기 데이터로 파운데이션
모델을 포스트트레이닝하려 할 때, 우리는 게이트가 걸린 외부 클라우드가 아니라 자기 클러스터 위에서
Kueue로 GPU를 나누고 vLLM으로 어댑터를 서빙하는 경로를 제공합니다.

두 렌즈를 합치면 그림이 완성됩니다. 저비용 학습·서빙을 ai-platform이 받치고, 그 위에서 Paxis가
스킬과 정책과 감사로 에이전트를 운전합니다. NVIDIA 사례는 이 조합이 실제 성능 개선으로 이어진다는
것을 남의 벤치마크로 보여 준 셈입니다.

## 한계 및 반론

이 사례를 과장하지 않으려면 네 가지를 함께 봐야 합니다. 첫째, "하루 만에"는 벽시계 기준이지 GPU
시간 기준이 아닙니다. 8장의 A100과 여러 노드에 걸친 19.5시간 스윕은 결코 저렴하지 않으며, 7분의 1은
풀 SFT 대비 상대값이지 절대적으로 싸다는 뜻이 아닙니다. 둘째, 93.35%는 4지선다 교통 안전 영상 QA라는
좁은 과제의 숫자입니다. 일반적인 물리 추론 능력이 그만큼 올랐다는 주장으로 확대하면 안 됩니다.
셋째, 자동화는 벤더 종속을 감춥니다. 에이전트가 "스스로" 오류를 패치할 수 있었던 이유는 스킬 뱅크가
정확히 그 프레임워크의 오류 패턴을 미리 알고 있었기 때문입니다. 스택을 벗어나면 이 매끄러움은 사라집니다.
넷째, "최소한의 개입"이 개입 제로는 아닙니다. 사람이 API 키를 넣고, 데이터셋 경로를 지정하고, 애초에
그 태스크에 맞는 스킬 뱅크를 설치해야 흐름이 시작됩니다. 에이전트가 지운 것은 반복 노동이지 판단
자체가 아닙니다.

그럼에도 방향은 분명합니다. 워크플로 지식을 스킬로 굳히고, 그 스킬을 에이전트가 반복 실행하며, 개선을
자기 보고가 아니라 측정된 게이트로 확인하는 구조는 특정 벤더의 전략이 아니라 에이전트 시대의 공통
설계입니다. 우리가 Paxis와 ai-platform으로 만들려는 것도 바로 그 구조입니다.


## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_mono` 스타일)으로 요약한 슬라이드입니다.

![cosmos3-agent-skills-posttraining 슬라이드 1](/assets/images/cosmos3-agent-skills-posttraining-slide-01.png)

![cosmos3-agent-skills-posttraining 슬라이드 2](/assets/images/cosmos3-agent-skills-posttraining-slide-02.png)

![cosmos3-agent-skills-posttraining 슬라이드 3](/assets/images/cosmos3-agent-skills-posttraining-slide-03.png)

![cosmos3-agent-skills-posttraining 슬라이드 4](/assets/images/cosmos3-agent-skills-posttraining-slide-04.png)

## 출처

- NVIDIA Developer Blog, "Post-Train NVIDIA Cosmos 3 in One Day Using Agent Skills" (<https://developer.nvidia.com/blog/post-train-nvidia-cosmos-3-in-one-day-using-agent-skills/>)
- GitHub: NVIDIA/cosmos, NVIDIA-TAO/tao-skill-bank
- Hugging Face: nvidia/Cosmos3-Nano, nvidia/Cosmos3-Super
- 데이터셋: Woven Traffic Safety (WTS), Toyota
