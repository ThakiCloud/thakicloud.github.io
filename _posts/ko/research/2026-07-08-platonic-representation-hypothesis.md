---
title: "모든 AI가 같은 '뇌'로 수렴한다는 가설: 플라토닉 표현 가설 읽기"
excerpt: "서로 다른 데이터로, 서로 다른 목적으로 학습한 비전 모델과 언어 모델이 시간이 갈수록 데이터를 같은 방식으로 표현하기 시작합니다. MIT의 플라토닉 표현 가설(Platonic Representation Hypothesis)은 이 수렴이 우연이 아니라 규모와 능력이 커질수록 나타나는 구조적 압력의 결과이며, 그 종착점이 현실의 공통 통계 모델이라고 주장합니다. 이 글은 가설의 근거와 측정 방법, 그리고 멀티모델을 서빙하는 AI 플랫폼에 주는 실무적 함의를 정리합니다."
seo_title: "플라토닉 표현 가설 - AI 모델은 왜 같은 표현으로 수렴하는가 - Thaki Cloud"
seo_description: "MIT의 플라토닉 표현 가설(Platonic Representation Hypothesis, arXiv:2405.07987)을 소개합니다. 상호 최근접 이웃 정렬 지표로 78개 비전 모델과 언어 모델의 표현 수렴을 측정하고, 멀티태스크 스케일링·용량·단순성 편향이라는 세 가지 압력으로 수렴을 설명하며, 멀티모델 서빙과 공통 임베딩 인프라를 운영하는 AI 플랫폼 관점에서의 함의와 한계를 다룹니다."
date: 2026-07-08
last_modified_at: 2026-07-08
tags:
  - research
  - representation-learning
  - platonic-representation
  - model-convergence
  - multimodal
  - embeddings
  - foundation-models
  - model-interoperability
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "flask"
categories:
  - research
canonical_url: "https://thakicloud.com/tech-blog/ko/research/platonic-representation-hypothesis/"
audiobook: /assets/audio/posts/platonic-representation-hypothesis/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

## 이 글을 누가 읽으면 좋은가

이 글은 여러 종류의 파운데이션 모델을 한 플랫폼에서 서빙하거나, 임베딩 기반 검색·추천·멀티모달 파이프라인을 설계하는 엔지니어와 데이터 과학자를 위해 씁니다. "왜 서로 다른 모델의 임베딩을 억지로 정렬하려는 시도가 생각보다 잘 통할까", "모델을 바꿔도 다운스트림 성능이 크게 흔들리지 않는 이유는 무엇일까" 같은 실무 질문의 밑바탕에 깔린 이론을 다룹니다. MIT 연구진이 2024년 ICML에서 발표한 플라토닉 표현 가설을 근거와 함께 읽고, 그 주장이 실제 플랫폼 설계에서 어떤 의미를 갖는지까지 이어 봅니다.

![서로 다른 색의 입자 흐름이 중심의 빛나는 결정 구조로 수렴하는 추상 이미지]({{ '/assets/images/platonic-representation-hypothesis-hero.png' | relative_url }})

## 개요

서로 다른 팀이, 서로 다른 데이터로, 서로 다른 목적 함수를 걸고 학습한 신경망이 왜 점점 비슷해지는 걸까요. 이 질문은 오래된 현상 관찰에서 출발합니다. 비전 모델 두 개를 서로 다른 방식으로 학습해도, 어떤 이미지 쌍이 서로 가깝고 어떤 쌍이 먼지를 판단하는 방식이 시간이 갈수록 닮아 갑니다. 더 놀라운 것은 이 닮음이 모달리티를 건너뛴다는 점입니다. 이미지를 본 적 없는 언어 모델과 텍스트를 본 적 없는 비전 모델이, 데이터 사이의 거리 구조를 점점 같은 방식으로 재현하기 시작합니다.

Minyoung Huh, Brian Cheung, Tongzhou Wang, Phillip Isola가 쓴 「The Platonic Representation Hypothesis」(arXiv:2405.07987, ICML 2024 Oral)는 이 관찰을 하나의 주장으로 묶습니다. 신경망의 표현이 서로 다른 아키텍처와 목적을 넘어 하나의 공통된 통계적 실재 모델로 수렴하고 있으며, 그 이상적 종착점을 플라톤의 이데아에 빗대어 "플라토닉 표현"이라고 부릅니다. 이 글은 그 근거가 무엇인지, 어떻게 측정했는지, 그리고 여러 모델을 실제로 운영하는 입장에서 이 가설이 왜 실용적인 함의를 갖는지를 정리합니다.

## 플라토닉 표현 가설이란 무엇인가

가설의 핵심 문장은 단순합니다. 이미지든 텍스트든 소리든, 우리가 관측하는 데이터는 어떤 공통된 근원적 실재의 서로 다른 투영입니다. 충분히 크고 충분히 유능한 모델은 이 투영을 역으로 거슬러 올라가, 근원적 실재의 통계 구조를 점점 더 정확히 재구성합니다. 그 결과 서로 무관하게 학습한 모델들도 결국 같은 목적지를 향해 수렴합니다.

여기서 "표현이 같다"는 말은 가중치가 같다거나 뉴런이 일대일 대응한다는 뜻이 아닙니다. 표현이 유도하는 데이터 사이의 거리 구조, 즉 어떤 샘플들이 서로 이웃이고 어떤 샘플들이 먼지를 규정하는 커널(kernel)이 같아진다는 의미입니다. 두 표현이 서로 다른 좌표계를 쓰더라도, 데이터 포인트들의 상대적 관계가 같다면 두 표현은 본질적으로 같은 기하학을 담고 있는 것입니다.

![기존 직관(발산)과 플라토닉 가설(수렴)의 대비]({{ '/assets/images/platonic-representation-hypothesis-slide-04.png' | relative_url }})

이 가설은 표현 학습의 오래된 직관을 뒤집습니다. 흔히 우리는 데이터가 많아지고 모델이 커지면 표현이 더 다양해지고 특화될 것이라고 기대합니다. 가설은 반대로 말합니다. 규모가 커질수록 유효한 표현의 후보 공간이 좁아지고, 결국 하나의 최적 표현으로 눌린다는 것입니다.

## 수렴의 증거: 무엇을, 어떻게 측정했나

주장이 흥미로운 것과 그 주장이 참인 것은 다릅니다. 저자들은 수렴을 정량적으로 측정할 수 있는 지표를 세우고, 여러 모델 계열에 걸쳐 그 지표가 실제로 올라가는지를 확인합니다.

![상호 최근접 이웃 정렬, 78개 비전 모델, 모달리티 교차라는 수렴의 정량적 증거]({{ '/assets/images/platonic-representation-hypothesis-slide-05.png' | relative_url }})

핵심 측정 도구는 상호 최근접 이웃(mutual nearest-neighbor) 정렬입니다. 같은 데이터 집합을 두 모델에 통과시켜 각각 임베딩을 얻은 뒤, 한 샘플의 최근접 이웃 집합이 두 표현 공간에서 얼마나 겹치는지를 셉니다. 겹침이 클수록 두 모델은 데이터의 이웃 관계를 같은 방식으로 본다는 뜻이고, 정렬 점수가 높습니다. 이 지표 외에도 중심 커널 정렬(CKA)이나 모델 스티칭(model stitching) 같은 보완적 방법이 같은 결론을 가리킵니다.

첫 번째 증거는 비전 모델 안에서의 수렴입니다. 저자들은 78개의 비전 모델을 Places-365 데이터셋 위에서 서로 비교합니다. 결과는 명확합니다. 다운스트림 벤치마크(VTAB, Visual Task Adaptation Benchmark)에서 더 유능한 모델일수록 서로 더 강하게 정렬됩니다. 능력이 높은 모델들끼리는 하나의 촘촘한 무리를 이루고, 능력이 낮은 모델들은 제각각 흩어집니다. 성능이 올라갈수록 표현이 하나로 모인다는 것입니다.

두 번째 증거가 더 도발적입니다. 모달리티를 건너뛰는 정렬입니다. 이미지-텍스트 쌍 데이터를 이용해 비전 모델의 이미지 표현과 언어 모델의 텍스트 표현을 비교하면, 언어 모델이 유능할수록 그 텍스트 표현이 강한 비전 모델의 이미지 표현과 더 잘 정렬됩니다. 텍스트만 학습한 모델과 이미지만 학습한 모델이, 능력이 올라갈수록 같은 거리 구조를 향해 다가가는 것입니다. 이것이 가설의 이름값을 하는 대목입니다. 수렴은 한 모달리티 안의 우연이 아니라 모달리티를 관통하는 경향입니다.

## 수렴을 이끄는 세 가지 압력

관찰을 넘어, 저자들은 왜 이런 수렴이 일어나는지를 세 가지 가설로 설명합니다. 아래 그림은 세 압력이 어떻게 하나의 공통 표현으로 모이는지를 요약합니다.

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
<div class="d3-arch" data-arch-root id="representationhypothesis-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 736, "height": 684, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 24, "w": 128, "h": 62, "title": ["관측 데이터", "이미지 · 텍스트 · 소리"]}, {"id": "B", "x": 28, "y": 180, "w": 120, "h": 46, "title": "신경망 학습"}, {"id": "P1", "x": 203, "y": 164, "w": 142, "h": 78, "title": ["멀티태스크 스케일링 압력", "더 많은 과제를 동시에 풀수록", "가능한 표현이 줄어든다"]}, {"id": "C", "x": 298, "y": 320, "w": 138, "h": 52, "title": "유효 표현 공간의 수축"}, {"id": "P2", "x": 400, "y": 164, "w": 121, "h": 78, "title": ["용량 압력", "모델이 클수록 전역 최적", "표현에 더 잘 근접한다"]}, {"id": "P3", "x": 576, "y": 164, "w": 128, "h": 78, "title": ["단순성 편향 압력", "큰 모델일수록 단순한 해를", "선호한다"]}, {"id": "D", "x": 307, "y": 450, "w": 120, "h": 62, "title": ["공통 표현으로 수렴", "= 플라토닉 표현"]}, {"id": "E", "x": 300, "y": 590, "w": 135, "h": 62, "title": ["현실의 통계 모델", "관측 이면의 공동 발생 구조"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [88, 86, 88, 180]}, {"src": "P1", "dst": "C", "kind": "data", "curve": [[274, 242], [274, 281], [274, 281], [330, 320]]}, {"src": "P2", "dst": "C", "kind": "data", "curve": [[461, 242], [461, 281], [461, 281], [405, 320]]}, {"src": "P3", "dst": "C", "kind": "data", "curve": [[640, 242], [640, 281], [640, 281], [436, 330]]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[88, 226], [88, 281], [88, 281], [298, 330]]}, {"src": "C", "dst": "D", "kind": "data", "line": [367, 372, 367, 450]}, {"src": "D", "dst": "E", "kind": "data", "line": [367, 512, 367, 590]}]});
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
      const container = document.getElementById('representationhypothesis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'representationhypothesis-1';
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

첫째는 멀티태스크 스케일링 가설입니다. 모델이 더 많은 과제를 동시에 풀도록 요구받을수록, 그 모든 과제를 만족시키는 표현의 후보는 줄어듭니다. 하나의 과제만 푸는 표현은 무수히 많지만, 수백 개 과제를 동시에 푸는 표현은 극소수만 남습니다. 데이터와 과제가 커질수록 살아남는 표현의 교집합이 좁아지고, 서로 다른 모델이 그 좁은 교집합으로 몰립니다.

둘째는 용량 가설입니다. 더 큰 모델은 더 나은 최적화와 더 넓은 함수 공간을 갖기 때문에, 아키텍처나 학습 방식의 차이와 무관하게 전역적으로 최적인 표현에 더 잘 근접합니다. 작은 모델들은 저마다 다른 지역 최적해에 머물지만, 용량이 커질수록 모두가 같은 전역 최적해 근처로 이끌립니다.

셋째는 단순성 편향 가설입니다. 신경망은 명시적 정규화든 최적화의 암묵적 성질이든, 데이터를 설명하는 여러 해 중에서 더 단순한 해를 선호하는 경향이 있습니다. 그리고 모델이 커질수록 이 단순성 편향은 오히려 강해집니다. 표현할 수 있는 복잡한 해가 늘어나도, 그중 가장 단순하고 일반적인 해로 눌리는 힘이 세지기 때문입니다. 결과적으로 큰 모델일수록 데이터를 설명하는 가장 간결한 공통 구조로 모입니다.

## 이상적 종착점: 현실의 통계 모델

세 압력이 향하는 종착점은 무엇일까요. 저자들은 이를 이론적으로 모델링합니다. 세상을 이산적인 사건들의 연쇄로 보고, 우리가 관측하는 이미지와 텍스트를 그 사건들의 서로 다른 투영이라고 두면, 최적의 표현은 관측 사건들이 함께 나타나는 정도, 즉 점별 상호정보량(pointwise mutual information)에 수렴하는 커널을 갖게 됩니다. 쉽게 말해 이상적인 표현은 "어떤 것들이 현실에서 함께 등장하는가"라는 공동 발생 통계를 담아냅니다.

이것이 왜 모달리티를 건너뛰는지가 여기서 설명됩니다. 이미지든 텍스트든 같은 현실을 다른 창문으로 본 것이라면, 그 창문 너머의 공동 발생 구조는 하나입니다. 충분히 유능한 모델은 어느 창문으로 들어오든 같은 구조에 도달합니다. 플라토닉 표현이라는 이름은 관측 뒤에 있는 이 공통된 통계적 실재를 가리킵니다.

![점별 상호정보량으로 수렴하는 현실의 통계 모델]({{ '/assets/images/platonic-representation-hypothesis-slide-07.png' | relative_url }})

## ThakiCloud 제품 적용 시사점

이 가설은 추상적으로 들리지만, 여러 모델을 실제로 서빙하는 플랫폼 입장에서는 매우 구체적인 함의를 갖습니다. ThakiCloud의 ai-platform은 Kubernetes와 Kueue 기반 GPU 스케줄링 위에서 다양한 고객 환경에 여러 종류의 모델을 서빙합니다. 서로 다른 비전 인코더, 서로 다른 임베딩 모델, 서로 다른 세대의 LLM이 한 플랫폼에서 공존합니다.

![임베딩 격리 완화, 경량 정렬 계층, 저비용 진단 신호라는 플랫폼 적용 시사점]({{ '/assets/images/platonic-representation-hypothesis-slide-08.png' | relative_url }})

플라토닉 표현 가설이 시사하는 첫 번째 지점은 모델 간 상호운용성입니다. 유능한 모델들의 표현이 공통 기하학으로 수렴한다면, 임베딩 공간을 모델마다 완전히 격리해 관리할 필요가 줄어듭니다. 한 임베딩 모델로 색인한 벡터 저장소를 다른 세대 모델로 교체할 때, 두 표현이 근본적으로 같은 이웃 구조를 공유한다면 재색인 비용과 다운스트림 성능 저하를 예측 가능한 범위로 관리할 수 있습니다. 모델 교체가 곧 임베딩 파이프라인 전면 재구축이라는 통념은, 수렴이 강한 영역에서는 완화됩니다.

두 번째 지점은 멀티모달 정렬의 경제성입니다. 강한 비전 모델과 강한 언어 모델의 표현이 이미 서로 정렬되는 방향으로 움직인다면, 두 모달리티를 잇는 얇은 어댑터만으로도 상당한 정렬을 얻을 수 있습니다. 무거운 공동 학습 없이 각 모달리티의 최신 모델을 독립적으로 갱신하면서 그 위에 경량 정렬 계층을 얹는 설계가, 멀티테넌트 환경에서 자원 효율과 갱신 속도를 동시에 잡는 현실적인 선택지가 됩니다.

세 번째 지점은 벤치마킹의 관점입니다. 능력이 올라갈수록 표현이 공통 구조로 수렴한다는 명제는, 온프렘·소버린 환경에서 여러 후보 모델을 평가할 때 표현 정렬도를 하나의 진단 지표로 쓸 수 있음을 시사합니다. 두 모델의 상호 최근접 이웃 정렬이 낮다면, 그것은 둘 중 하나가 아직 덜 유능하거나 도메인이 어긋나 있다는 신호일 수 있습니다. 정렬 지표는 정확도 벤치마크를 보완하는 저비용 신호가 됩니다.

## 한계 및 반론

가설이 매력적일수록 반대 방향의 논거를 정직하게 세워야 합니다.

![사회학적 동형화, 환원 불가능한 모달리티 차이, 측정 지표 해석 의존성이라는 한계]({{ '/assets/images/platonic-representation-hypothesis-slide-09.png' | relative_url }})

첫 번째 반론은 수렴이 플라톤적 실재 때문이 아니라 사회학적 동형화 때문일 수 있다는 것입니다. 오늘날의 모델들은 상당 부분 같은 웹 규모 데이터, 같은 트랜스포머 계열 아키텍처, 같은 최적화 관행을 공유합니다. 표현이 닮는 이유가 근원적 실재로의 수렴이 아니라 단지 모두가 같은 재료로 요리하기 때문일 가능성을 배제하기 어렵습니다.

두 번째 반론은 모달리티 사이의 환원 불가능한 차이입니다. 시각에만 존재하고 언어로는 결코 포착되지 않는 정보, 그 반대의 정보가 분명히 존재합니다. 모든 표현이 하나로 수렴한다는 강한 주장은, 각 모달리티가 고유하게 담는 정보를 과소평가할 위험이 있습니다. 실제로 특화된 목적으로 학습된 모델이나 서로 다른 정보를 보존하도록 설계된 표현은 수렴하지 않습니다.

세 번째 반론은 측정의 해석 의존성입니다. 상호 최근접 이웃이나 CKA 같은 지표는 특정한 거리 개념을 전제하며, 어떤 지표를 고르느냐에 따라 정렬도의 그림이 달라질 수 있습니다. "표현이 수렴한다"는 결론은 지표 선택과 데이터 분포에 어느 정도 의존하며, 이는 재현 연구들이 계속 검증하고 있는 열린 문제입니다.

그럼에도 이 가설의 실용적 가치는 종착점의 형이상학이 아니라 방향성에 있습니다. 능력이 커질수록 표현이 공통 구조로 이동한다는 경향 자체는 여러 지표에서 반복적으로 관찰되며, 멀티모델 인프라를 설계하는 사람에게는 그 방향성만으로도 충분히 실용적인 나침반이 됩니다.

## 출처

- Minyoung Huh, Brian Cheung, Tongzhou Wang, Phillip Isola, "The Platonic Representation Hypothesis", ICML 2024 (arXiv:2405.07987): [arxiv.org/abs/2405.07987](https://arxiv.org/abs/2405.07987)
- 코드 및 프로젝트: [github.com/minyoungg/platonic-rep](https://github.com/minyoungg/platonic-rep)
