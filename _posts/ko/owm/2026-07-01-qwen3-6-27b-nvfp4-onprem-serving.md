---
title: "Qwen3.6-27B을 4비트로: NVFP4 양자화가 Hopper까지 내려온 이유"
excerpt: "NVIDIA가 공개한 Qwen3.6-27B-NVFP4는 27B 하이브리드 어텐션 추론 모델을 4비트로 눌러 메모리를 약 2.5배 줄이면서도 FP8 대비 벤치마크 차이를 1%p 이내로 유지합니다. 지난 Gemma NVFP4가 Blackwell 전용이었던 것과 달리 이번 빌드는 Hopper까지 지원해, 이미 H100/H200을 가진 조직이 오늘 당장 온프렘에서 돌릴 수 있습니다. 모델 팩트와 NVFP4 원리, 서빙 경로, 그리고 ThakiCloud 서빙 관점을 정리했습니다."
seo_title: "Qwen3.6-27B-NVFP4 온프렘 서빙 가이드 - Hopper/Blackwell 4비트 양자화 - Thaki Cloud"
seo_description: "Qwen3.6-27B-NVFP4(27B, 하이브리드 어텐션, 262K 컨텍스트, 멀티모달 추론)를 vLLM으로 서빙: NVFP4 4비트 양자화로 메모리 약 2.5배 절감, FP8 대비 벤치 1%p 이내. Hopper/Blackwell 동시 지원, Apache 2.0. ThakiCloud K8s 온프렘 서빙과 에이전트 워커 관점."
date: 2026-07-01
last_modified_at: 2026-07-01
tags:
  - qwen3
  - nvfp4
  - quantization
  - hopper
  - blackwell
  - hybrid-attention
  - multimodal
  - vllm
  - on-premise
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/owm/qwen3-6-27b-nvfp4-onprem-serving/"
reading_time: true
audiobook: https://drive.google.com/file/d/1KfD7pjbIrnA-wY6kc2je_tyHPwu5s9Lx/view
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
categories:
  - owm
---

⏱️ **예상 읽기 시간**: 11분

![Qwen3.6-27B NVFP4 4비트 양자화 개념도]({{ '/assets/images/qwen3-6-27b-nvfp4-onprem-serving-hero.webp' | relative_url }})

## 개요

NVIDIA가 Alibaba의 Qwen3.6-27B을 NVFP4 4비트로 양자화한 `nvidia/Qwen3.6-27B-NVFP4`를 공개했습니다. 27B급 하이브리드 어텐션 추론 모델을 4비트로 눌러 가중치 메모리를 약 2.5배 줄이면서, FP8 기준선 대비 아홉 개 벤치마크 전부에서 차이를 1%p 이내로 유지합니다. 라이선스는 Apache 2.0입니다.

이 글에서 짚고 싶은 지점은 세 가지입니다. 첫째, 지난번 `Gemma-4-26B-A4B-NVFP4`가 사실상 Blackwell에서만 4비트 가속을 받았던 것과 달리, 이번 빌드는 모델카드에서 **Hopper와 Blackwell을 함께 지원 대상**으로 명시합니다. 이미 H100이나 H200을 굴리는 조직이 새 하드웨어를 사지 않고도 오늘 당장 시험해 볼 수 있다는 뜻입니다. 둘째, 이 모델은 텍스트만 다루는 순수 LLM이 아니라 **텍스트와 이미지, 비디오를 입력받는 멀티모달 추론 모델**입니다. 셋째, 컨텍스트가 **262K 토큰**까지 열려 있어 긴 문서와 장기 대화를 한 번에 받아냅니다.

ThakiCloud는 Kubernetes 위에서 Kueue로 GPU 쿼터를 관리하고 vLLM으로 모델을 멀티테넌트 서빙하는 플랫폼을 운영합니다. 그래서 "기존에 가진 GPU 위에서 더 큰 모델을, 더 많은 테넌트에게 얼마나 얹을 수 있는가"는 신기한 소식이 아니라 비용 모델과 직결되는 질문입니다. 이 글은 모델 팩트를 정리하고, NVFP4가 왜 Hopper까지 내려왔는지 따져 본 뒤, 서빙 경로와 우리 플랫폼에서의 쓸모를 솔직하게 리뷰합니다.

## 이 모델은 무엇인가

`nvidia/Qwen3.6-27B-NVFP4`는 Alibaba의 `Qwen3.6-27B`을 NVIDIA Model Optimizer(nvidia-modelopt v0.45.0)로 NVFP4 양자화한 버전입니다. 모델카드 기준 핵심 스펙은 다음과 같습니다.

| 항목 | 값 |
|---|---|
| 베이스 모델 | Alibaba Qwen3.6-27B |
| 아키텍처 | 하이브리드 어텐션 (Gated DeltaNet + Gated Attention) |
| 총 파라미터 | 27B |
| 컨텍스트 | 262K 토큰 |
| 입력 모달리티 | 텍스트 + 이미지 + 비디오 |
| 출력 | 텍스트 |
| 양자화 | NVFP4 (Model Optimizer v0.45.0) |
| 타깃 하드웨어 | NVIDIA Hopper, Blackwell |
| 라이선스 | Apache 2.0 |

주목할 부분은 아키텍처의 **하이브리드 어텐션**입니다. Gated DeltaNet은 선형 어텐션 계열로, 시퀀스 길이에 비례해 비용이 늘어나는 일반 어텐션과 달리 장문을 효율적으로 처리하도록 설계된 경로입니다. 여기에 표현력을 담당하는 Gated Attention을 섞어, 262K 같은 긴 컨텍스트를 감당하면서도 품질을 유지하는 절충을 취합니다. 서빙 시 `--reasoning-parser qwen3`를 요구한다는 점에서, 이 모델은 최종 답 이전에 추론 과정을 생성하는 **리즈닝 모델**이라는 것도 확인됩니다.

한 가지 정직하게 밝혀 둘 부분이 있습니다. 모델카드는 하이브리드 어텐션이라는 사실은 명시하지만, 정확한 레이어 수나 전문가(expert) 구성, 토큰당 활성 파라미터 같은 세부는 공개하지 않습니다. 따라서 이 글에서는 카드에 적힌 사실만 다루고, 미공개 수치는 추정하지 않습니다.

## NVFP4 양자화: 무엇을 어떻게 누르는가

NVFP4는 NVIDIA가 밀어붙이는 4비트 부동소수점 포맷입니다. 가중치를 4비트 정수로 단순 절단하는 INT4와 달리, 작은 블록 단위로 FP8 스케일을 두는 마이크로스케일링 방식이라 4비트 수준의 메모리 절감을 누리면서도 정확도 손실을 작게 억제합니다.

이번 빌드에서 양자화 대상은 **트랜스포머 블록 안 선형 연산자의 가중치와 활성값(activation)**입니다. 비선형 층은 건드리지 않습니다. 모델카드는 파라미터당 비트 수를 16에서 4로 줄여 디스크와 GPU 메모리 요구량을 **약 2.5배 감소**시킨다고 밝힙니다. 27B 파라미터를 BF16으로 올리면 약 54GB가 필요한데, 약 2.5배 감소를 적용하면 체크포인트가 20GB 안팎으로 내려옵니다. 같은 GPU에 모델을 2배 이상 얹거나, 남은 메모리를 KV 캐시로 돌려 동시 세션을 늘릴 여지가 생깁니다.

여기서 지난 Gemma NVFP4 리뷰와 갈리는 대목이 나옵니다. Gemma 빌드는 소비자·프로 Blackwell(SM120)에서 NVFP4 MoE 커널이 아직 깨져 있어, 실제로 도는 소비자급 경로가 DGX Spark에 한정됐습니다. 반면 이번 Qwen3.6 빌드는 모델카드가 **Hopper와 Blackwell을 함께 지원 대상으로 명시**하고, 서빙도 vLLM의 `--quantization modelopt` 경로를 씁니다. 가중치뿐 아니라 활성값까지 양자화한 구성과 modelopt 서빙 경로가 맞물리면서, 데이터센터에 이미 깔린 H100·H200 위에서도 이 4비트 모델을 돌릴 수 있게 된 것입니다. "새 Blackwell을 사야만 4비트 이득을 본다"는 제약이 이번에는 상당히 풀렸습니다.

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
<div class="d3-arch" data-arch-root id="n3627bnvfp4onpremserving-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 374, "height": 834, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 128, "y": 24, "w": 120, "h": 62, "title": ["Qwen3.6-27B", "BF16 약 54GB"]}, {"id": "B", "x": 96, "y": 164, "w": 184, "h": 62, "title": ["NVIDIA Model Optimizer", "v0.45.0"]}, {"id": "C", "x": 117, "y": 304, "w": 142, "h": 78, "title": ["NVFP4 양자화", "선형 연산자 가중치 + 활성값", "16비트 → 4비트"]}, {"id": "D", "x": 100, "y": 460, "w": 177, "h": 62, "title": ["NVFP4 체크포인트", "약 20GB 안팎 · 약 2.5배 감소"]}, {"id": "E", "x": 93, "y": 600, "w": 191, "h": 62, "title": ["vLLM 서빙", "--quantization modelopt"]}, {"id": "F", "x": 221, "y": 740, "w": 121, "h": 62, "title": ["NVIDIA Hopper", "H100 / H200"]}, {"id": "G", "x": 24, "y": 740, "w": 142, "h": 62, "title": ["NVIDIA Blackwell", "B200 등"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [188, 86, 188, 164]}, {"src": "B", "dst": "C", "kind": "data", "line": [188, 226, 188, 304]}, {"src": "C", "dst": "D", "kind": "data", "line": [188, 382, 188, 460]}, {"src": "D", "dst": "E", "kind": "data", "line": [188, 522, 188, 600]}, {"src": "E", "dst": "F", "kind": "data", "curve": [[230, 662], [282, 701], [282, 701], [282, 740]]}, {"src": "E", "dst": "G", "kind": "data", "curve": [[147, 662], [95, 701], [95, 701], [95, 740]]}]});
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
      const container = document.getElementById('n3627bnvfp4onpremserving-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'n3627bnvfp4onpremserving-1';
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

## 벤치마크: 4비트 손실은 얼마인가

모델카드는 NVFP4 양자화본과 FP8 기준선을 아홉 개 벤치마크에서 나란히 제시합니다.

| 벤치마크 | FP8 | NVFP4 | 측정 영역 |
|---|---|---|---|
| MMLU Pro | 86.1 | 86.3 | 일반 지식·추론 |
| GPQA Diamond | 86.0 | 85.5 | 대학원 과학 추론 |
| HLE | 21.7 | 21.8 | 고난도 종합 |
| τ²-Bench Telecom | 95.2 | 95.4 | 에이전트 툴 사용 |
| MMMU Pro | 74.6 | 74.3 | 멀티모달 추론 |
| SciCode | 44.8 | 44.5 | 과학 코딩 |
| AIME 2025 | 93.1 | 92.7 | 수학 경시 |
| AA-LCR | 68.8 | 68.3 | 장문 추론 |
| IFBench | 65.1 | 65.5 | 지시 이행 |

아홉 항목 모두 FP8 대비 1%p 안쪽 차이입니다. MMLU Pro, HLE, τ²-Bench Telecom, IFBench는 오히려 NVFP4가 근소하게 높은데, 이는 측정 분산 범위로 읽는 편이 안전합니다. 방향성은 분명합니다. **4비트로 눌러도 품질이 사실상 유지된다**는 것이고, NVFP4가 INT4 대비 갖는 강점이 여기서 드러납니다.

벤치 구성 자체도 이 모델의 성격을 보여 줍니다. τ²-Bench Telecom은 에이전트가 도구를 호출하며 과제를 수행하는 능력을, AA-LCR은 장문 컨텍스트 추론을, MMMU Pro는 멀티모달 이해를 측정합니다. 순수 지식 QA만이 아니라 **에이전트 툴 사용과 장문, 멀티모달**을 함께 겨냥한 모델이라는 뜻입니다. 다만 한국어 도메인 태스크는 공개 벤치에 드러나지 않으므로, 실제 도입 전에는 내부 평가셋으로 별도 검증을 권장합니다.

## 서빙 가이드

모델카드가 제시하는 권장 경로는 vLLM입니다. 실행 명령은 다음과 같습니다.

```bash
vllm serve nvidia/Qwen3.6-27B-NVFP4 \
  --port 8000 \
  --quantization modelopt \
  --max-model-len 262144 \
  --reasoning-parser qwen3
```

운영에서 챙길 포인트는 세 가지입니다. 먼저 `--quantization modelopt`가 NVFP4 체크포인트를 로드하는 핵심 플래그입니다. 다음으로 `--reasoning-parser qwen3`가 있어야 추론 과정과 최종 답이 올바로 분리돼 파싱됩니다. 마지막으로 `--max-model-len 262144`는 262K 컨텍스트를 전부 여는 설정이며, KV 캐시 예산이 그만큼 커지므로 실제로 필요한 길이에 맞춰 낮춰 잡는 것이 메모리 효율에 유리합니다.

하드웨어는 Hopper 또는 Blackwell, OS는 Linux가 전제입니다. Hopper까지 지원한다는 점 덕분에, 데이터센터에 이미 있는 H100·H200 노드에서 별도 장비 없이 서빙 경로를 검증할 수 있습니다.

## ThakiCloud 서빙 관점

ThakiCloud는 Kueue로 GPU 쿼터를 관리하고 vLLM으로 모델을 멀티테넌트 서빙하는 K8s 기반 AI/ML 플랫폼을 운영합니다. 이 모델이 우리 운용 모델에 주는 시사점은 인프라와 에이전트 두 방향에서 나옵니다.

**기존 Hopper 자산 위에서 밀도를 2배 이상으로.** 이 부분이 이번 빌드의 가장 실질적인 가치입니다. NVFP4가 Hopper까지 지원한다는 것은, 새 Blackwell 투자 없이 이미 보유한 H100·H200 위에서 4비트 이득을 볼 수 있다는 뜻입니다. 27B 모델의 가중치가 20GB 안팎으로 내려오면 같은 GPU에 더 많은 모델 인스턴스를 올리거나, 남는 메모리를 KV 캐시로 돌려 테넌트별 동시성 한도를 넉넉히 잡을 수 있습니다. Kueue 쿼터 관점에서는 같은 카드로 더 많은 워크로드를 받는 셈이라 단가가 그대로 내려갑니다.

**멀티모달 추론 워커의 온프렘 후보.** ThakiCloud의 에이전트 제어 평면인 Paxis는 Agent-Native Cloud로, 스킬을 격리 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. 이 구조에서 다수의 워커가 문서를 읽고 도구를 호출하며 과제를 처리합니다. Qwen3.6-27B-NVFP4는 τ²-Bench Telecom 같은 에이전트 툴 사용 벤치에서 강하고, 텍스트뿐 아니라 이미지와 비디오를 입력받으며, 262K 컨텍스트를 감당합니다. 문서·화면·영상을 함께 다루는 멀티모달 워커, 툴 호출 루프의 말단 워커로 온프렘에서 돌리기에 적합한 후보입니다. 다만 우리 비용 규율대로 워커는 싸게 돌리되, fan-out 결과는 상위 모델의 검증 단계로 닫아 워커 환각이 누적되지 않게 해야 합니다.

**온프렘·컴플라이언스 제안의 레퍼런스.** Apache 2.0 라이선스에 단일 노드 서빙이 가능한 구성은, 데이터 외부 반출이 금지된 공공·금융 고객에게 그대로 제안할 수 있습니다. 국정원 요구 대응이나 소버린 AI 같은 제약 환경에서, 상용 API 없이 자체 GPU로 대형 멀티모달 추론 모델을 돌린다는 그림은 실질적인 도입 경로가 됩니다.

## 한계 및 반론

균형을 위해 짚을 부분입니다.

- **아키텍처 세부가 공개되지 않았습니다.** 하이브리드 어텐션이라는 사실은 있지만 레이어 수, 전문가 구성, 활성 파라미터가 카드에 없습니다. 배치 효율과 메모리 상주량을 정밀하게 계산하려면 추가 정보가 필요합니다.
- **실측 처리량 수치가 없습니다.** 이 글은 메모리 절감과 벤치마크 같은 카드 팩트에 근거합니다. 스트림당 토큰 속도나 동시성 한도는 하드웨어와 설정에 따라 크게 달라지므로, 도입 전 자체 워크로드로 재측정해야 합니다.
- **활성값 양자화의 변동성.** 가중치뿐 아니라 활성값까지 4비트로 누르는 구성은 일부 분포가 치우친 워크로드에서 정확도 변동을 낳을 수 있습니다. 공개 벤치가 1%p 이내라 해도, 도메인 특화 태스크는 별도로 확인하는 편이 안전합니다.
- **멀티모달 서빙 경로의 성숙도.** 이미지·비디오 입력을 실제 프로덕션에서 안정적으로 받으려면 전처리 파이프라인과 vLLM 멀티모달 경로의 성숙도를 함께 검증해야 합니다.
- **한국어 실사용 검증.** 공개 벤치는 영어권 중심입니다. 한국어 RAG·툴콜 정확도는 내부 평가셋으로 따로 봐야 합니다.

그럼에도 Apache 2.0, Hopper까지 내려온 4비트 가속, 멀티모달 추론, 262K 컨텍스트라는 조합은 온프렘 서빙을 고민하는 조직에게 충분히 매력적인 선택지입니다. "새 하드웨어를 사야 4비트 이득을 본다"는 벽이 낮아졌다는 점만으로도, 이미 Hopper 플릿을 가진 팀에게는 오늘 검증해 볼 값어치가 있습니다.

## 참고 링크

- [Qwen3.6-27B-NVFP4 모델카드 (Hugging Face)](https://huggingface.co/nvidia/Qwen3.6-27B-NVFP4)
- [NVIDIA TensorRT Model Optimizer](https://github.com/NVIDIA/TensorRT-Model-Optimizer)
- [NVFP4 소개 (NVIDIA Developer)](https://developer.nvidia.com/blog/introducing-nvfp4-for-efficient-and-accurate-low-precision-inference/)
- [vLLM 공식 문서](https://docs.vllm.ai/)
- [Gemma-4-26B-NVFP4 DGX Spark 리뷰 (ThakiCloud 블로그)](https://thakicloud.com/tech-blog/ko/owm/gemma-4-26b-nvfp4-dgx-spark/)
