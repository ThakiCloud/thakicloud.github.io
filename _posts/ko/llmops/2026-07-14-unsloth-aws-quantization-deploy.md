---
title: "양자화한 모델을 어디에 올릴 것인가: AWS와 Unsloth의 배포 패턴 4가지"
excerpt: "Unsloth로 모델을 4비트로 줄이는 방법을 아는 팀은 많습니다. 그런데 그 파일을 실제로 EC2에 올릴지, SageMaker 엔드포인트로 감쌀지, EKS 파드로 띄울지 정하는 순간 대부분 막힙니다. AWS가 Unsloth와 함께 낸 배포 가이드는 이 질문에 명확한 지도를 제시합니다. 핵심은 모델 파일 형식이 런타임을 정하고, 런타임이 AWS 서비스를 정한다는 것입니다. GGUF는 어디로, 병합 safetensors는 어디로 가야 하는지, 그리고 이것이 ThakiCloud의 서빙 인프라 설계와 어떻게 맞닿는지 정리합니다."
tags:
  - unsloth
  - quantization
  - aws
  - sagemaker
  - vllm
  - llmops
  - self-hosting
  - paxis
date: 2026-07-14
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/unsloth-aws-quantization-deploy/"
categories:
  - llmops
---

![대형 모델이 압축된 층으로 정제되어 클라우드 서빙 인프라로 흘러 들어가는 모습을 표현한 추상 일러스트]({{ '/assets/images/unsloth-aws-quantization-deploy-hero.webp' | relative_url }})

## 개요

모델을 양자화하는 방법을 다룬 글은 이미 넘칩니다. GPTQ, AWQ, GGUF, Unsloth Dynamic까지, 16비트 모델을 4비트로 줄이는 레시피는 검색 몇 번이면 찾을 수 있습니다. 그런데 정작 실무에서 팀이 멈추는 지점은 그다음입니다. 4비트로 줄인 그 파일을, 대체 어디에 어떻게 올려야 하는가. EC2 인스턴스에 직접 띄울 것인가, SageMaker 엔드포인트로 감쌀 것인가, 아니면 이미 굴리고 있는 EKS 클러스터의 파드로 넣을 것인가. 이 질문에는 정답이 하나가 아니라, 모델 파일의 형식에 따라 갈리는 지도가 있습니다.

이 글은 자체 인프라에 오픈웨이트 모델을 서빙하려는 플랫폼 엔지니어와 추론 비용을 설계하는 실무자를 위한 것입니다. 최근 AWS가 Unsloth와 함께 공개한 "Deploying quantized models on Amazon SageMaker AI with Unsloth" 가이드는 이 배포 결정을 네 가지 패턴으로 정리했습니다. 저희는 이 가이드의 핵심 논리를 뜯어보고, 왜 모델 파일 형식이 런타임을 정하고 런타임이 다시 AWS 서비스를 정하는지, 그리고 이 사고방식이 ThakiCloud처럼 Kubernetes 기반으로 멀티테넌트 서빙을 하는 인프라 설계와 어떻게 이어지는지 정리합니다.

먼저 밝혀 둘 것이 있습니다. 이 글의 명령 예시는 AWS 공식 가이드와 Unsloth 문서에서 확인한 경로이며, 벤치마크 수치를 지어내지 않았습니다. 본 검증 환경은 Apple Silicon이라 CUDA가 필요한 Unsloth 양자화와 vLLM 서빙을 로컬에서 실제로 돌려 재현하지는 못했습니다. 따라서 이 글은 실험 리포트가 아니라, 검증된 가이드에 대한 구조 분석입니다.

## 왜 배포 단계에서 양자화가 다시 중요해지는가

양자화는 흔히 학습이나 추론 속도의 문제로만 이야기됩니다. 하지만 AWS 가이드는 배포 단계에서 양자화가 세 가지를 동시에 바꾼다고 짚습니다. 첫째는 인스턴스 결정입니다. 큰 모델이 더 작은 GPU나 심지어 CPU에서도 실용적으로 돌아갈 수 있게 되면서, 필요한 인스턴스 등급 자체가 내려갑니다. 둘째는 기동과 저장 프로파일입니다. 모델 파일이 작아지면 옮기고 저장하는 속도가 빨라져 콜드 스타트와 스케일 아웃이 유리해집니다. 셋째는 배포 유연성입니다. 비용에 민감한 추론에는 더 작은 모델을, 품질에 민감한 추론에는 더 높은 정밀도의 내보내기를 골라 쓸 수 있습니다.

Unsloth의 장점은 파인튜닝, 실행, 내보내기, 배포를 하나의 워크플로로 묶는다는 데 있습니다. 특히 Unsloth Dynamic v2.0 양자화는 정확도를 최대한 보존하면서 양자화된 LLM을 실행하고 파인튜닝할 수 있게 하고, PyTorch와 협업한 양자화 인식 학습(QAT)은 순진한 4비트 양자화 대비 잃어버린 정확도를 상당 부분 회복한다고 보고됩니다. 즉 배포 전에 품질과 크기의 거래를 어느 지점에서 할지 세밀하게 고를 수 있습니다.

## 파일 형식이 런타임을 정하고, 런타임이 AWS를 정한다

가이드의 핵심 통찰은 배포 결정을 "어느 서비스를 쓸까"에서 시작하지 말라는 것입니다. 대신 "어떤 파일 형식으로 내보낼까"에서 출발하면 나머지가 자연스럽게 따라옵니다. 두 갈래가 있습니다.

한쪽은 GGUF입니다. GGUF는 가중치와 토크나이저, 메타데이터를 하나의 파일로 묶는 단일 파일 형식으로, llama.cpp, Ollama, Unsloth 같은 경량 런타임이 이걸 씁니다. AWS에서는 이 갈래가 Amazon EC2나 SageMaker AI 커스텀 컨테이너로 매핑됩니다. 가볍게 검증하고 직접 통제하고 싶을 때의 경로입니다.

다른 한쪽은 병합 safetensors입니다. Unsloth로 16비트, 8비트, FP8, 4비트 가중치를 병합해 내보내면 vLLM이나 SGLang 같은 고처리량 엔진에서 돌릴 수 있고, 이것은 SageMaker AI의 대형 모델 추론(LMI) 컨테이너나 EKS, ECS로 매핑됩니다. 처리량과 확장이 중요한 프로덕션 서빙의 경로입니다. 이 갈래를 도식으로 정리하면 다음과 같습니다.

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
<div class="d3-arch" data-arch-root id="othawsquantizationdeploy-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 448, "height": 930, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 128, "y": 24, "w": 177, "h": 46, "title": "Unsloth로 파인튜닝 또는 다운로드"}, {"id": "B", "x": 147, "y": 148, "w": 138, "h": 52, "title": "서빙 런타임 선택"}, {"id": "C", "x": 260, "y": 292, "w": 135, "h": 62, "title": ["GGUF 내보내기", "가중치+토크나이저+메타데이터"]}, {"id": "D", "x": 24, "y": 292, "w": 163, "h": 62, "title": ["병합 safetensors 내보내기", "16 · 8 · FP8 · 4비트"]}, {"id": "E", "x": 242, "y": 432, "w": 170, "h": 62, "title": ["llama.cpp · Ollama ·", "Unsloth"]}, {"id": "F", "x": 45, "y": 440, "w": 121, "h": 46, "title": "vLLM · SGLang"}, {"id": "G", "x": 239, "y": 572, "w": 177, "h": 62, "title": ["Amazon EC2", "또는 SageMaker 커스텀 컨테이너"]}, {"id": "H", "x": 28, "y": 572, "w": 156, "h": 62, "title": ["SageMaker LMI 컨테이너", "또는 EKS · ECS"]}, {"id": "I", "x": 156, "y": 712, "w": 120, "h": 46, "title": "EC2에서 로컬 검증"}, {"id": "J", "x": 152, "y": 836, "w": 128, "h": 62, "title": ["동일 파일+런타임 조합으로", "관리형 배포에 승격"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [216, 70, 216, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "\"경량 단일 파일\"", "curve": [[256, 200], [327, 246], [327, 246], [327, 292]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "\"고처리량 엔진\"", "curve": [[176, 200], [106, 246], [106, 246], [106, 292]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "line": [327, 354, 327, 432]}, {"src": "D", "dst": "F", "kind": "data", "line": [106, 354, 106, 440]}, {"src": "E", "dst": "G", "kind": "data", "line": [327, 494, 327, 572]}, {"src": "F", "dst": "H", "kind": "data", "line": [106, 486, 106, 572]}, {"src": "G", "dst": "I", "kind": "data", "curve": [[327, 634], [327, 673], [327, 673], [257, 712]]}, {"src": "H", "dst": "I", "kind": "data", "curve": [[106, 634], [106, 673], [106, 673], [175, 712]]}, {"src": "I", "dst": "J", "kind": "data", "line": [216, 758, 216, 836]}]});
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
      const container = document.getElementById('othawsquantizationdeploy-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'othawsquantizationdeploy-1';
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

## 설치 및 통합

가이드가 제시하는 워크플로는 네 단계로 요약됩니다. Unsloth에서 모델을 파인튜닝하거나 다운로드하고, 원하는 런타임에 맞는 형식으로 내보내고, EC2나 로컬에서 런타임을 검증한 뒤, 같은 파일과 런타임 조합을 그대로 관리형 배포로 승격하는 것입니다. 여기서 "같은 파일과 런타임 조합"이라는 점이 중요합니다. 검증 환경과 프로덕션 환경에서 형식이나 엔진이 달라지면 예상치 못한 동작이 끼어들기 때문입니다.

Unsloth에서 내보내기는 목적지 런타임에 따라 갈립니다. GGUF 경로는 다음과 같은 형태입니다.

```python
# GGUF 내보내기 (llama.cpp / Ollama / EC2 경로)
model.save_pretrained_gguf(
    "qwen-merged-gguf",
    tokenizer,
    quantization_method="q4_k_m",
)
```

병합 safetensors 경로는 vLLM이나 SGLang을 겨냥합니다.

```python
# 병합 safetensors 내보내기 (vLLM / SGLang / SageMaker LMI 경로)
model.save_pretrained_merged(
    "qwen-merged-16bit",
    tokenizer,
    save_method="merged_16bit",  # 또는 merged_4bit 등
)
```

내보낸 병합 모델은 vLLM으로 곧바로 서빙 검증을 할 수 있습니다.

```bash
# EC2 또는 로컬에서 서빙 검증
vllm serve ./qwen-merged-16bit --port 8000
```

컨테이너 기반 배포에서는 AWS Deep Learning Container(DLC)가 EC2, EKS, ECS에 걸쳐 최적화된 도커 환경을 제공합니다. 특히 vLLM DLC는 고성능 추론에 맞춰져 있어 여러 GPU와 노드에 걸친 텐서 병렬화와 파이프라인 병렬화를 기본 지원합니다. 즉 EC2에서 단일 인스턴스로 검증한 구성을, 같은 런타임을 쓰는 EKS 파드로 옮겨 수평 확장하는 흐름이 매끄럽게 이어집니다.

## ThakiCloud 제품 적용 시사점

이 배포 지도는 ThakiCloud의 ai-platform 설계 철학과 그대로 겹칩니다. ai-platform은 Kubernetes와 Kueue 기반 GPU 스케줄링 위에서 모델을 서빙하는데, AWS 가이드가 말하는 "형식이 런타임을 정하고 런타임이 인프라를 정한다"는 원칙은 특정 클라우드에 종속되지 않습니다. GGUF는 경량 검증과 엣지 배포로, 병합 safetensors는 vLLM 기반 고처리량 서빙으로 가른다는 분기는 AWS의 EKS든 온프레미스 Kubernetes든 동일하게 적용됩니다. 오히려 온프레미스와 소버린 클라우드를 요구하는 국내 고객이 많은 ThakiCloud에게는, 특정 관리형 서비스에 묶이지 않고 파일 형식과 런타임만으로 배포 경로를 표준화하는 이 사고방식이 이식성 측면에서 더 유리합니다.

실무적으로 ai-platform은 vLLM DLC가 제공하는 텐서 병렬화와 파이프라인 병렬화를 Kueue 큐잉과 결합해 멀티테넌트로 운용할 수 있습니다. 고객마다 다른 정밀도의 내보내기를 골라, 비용 민감 워크로드에는 4비트 병합 모델을, 품질 민감 워크로드에는 FP8이나 16비트를 배정하는 식의 세분화가 가능합니다. Unsloth의 QAT로 4비트에서도 정확도를 회복해 두면, 낮은 서빙 비용과 품질을 동시에 잡는 지점이 넓어집니다. ai-platform이 낮은 서빙 단가에서 경쟁력을 갖는 배경이 바로 이런 형식과 런타임의 세밀한 매칭입니다.

이 저비용 서빙은 다시 에이전트 경제성으로 이어집니다. ThakiCloud의 Agent-Native Cloud 제어 평면인 Paxis는 격리 샌드박스에서 스킬을 실행하며 대형 오픈웨이트 모델을 반복 호출하는데, 파인튜닝한 도메인 모델을 Unsloth로 양자화해 ai-platform에 올려 두면 Paxis 에이전트가 그 모델을 저렴하게 소비할 수 있습니다. 형식 기반 배포 표준화가 곧 에이전트 워크로드의 단가를 떨어뜨리는 구조입니다.

## 한계 및 반론

이 가이드는 배포 지도로서는 명확하지만 몇 가지 유의점이 있습니다. 먼저 양자화 방식과 런타임의 조합에 따라 실제 품질과 처리량은 크게 달라집니다. 4비트 병합 모델이 vLLM에서 얼마나 정확도를 유지하는지, 텐서 병렬화가 특정 모델에서 실제로 선형 확장을 주는지는 대상 모델과 하드웨어에서 직접 측정해야 하며, 가이드의 일반론만으로는 알 수 없습니다.

둘째, 관리형 서비스의 편의는 비용과 종속성을 대가로 합니다. SageMaker LMI 컨테이너는 운영 부담을 줄여 주지만, 온프레미스 요구가 강한 환경에서는 EKS나 자체 Kubernetes로 같은 런타임을 직접 운용하는 편이 통제와 비용 면에서 나을 수 있습니다. AWS 가이드가 좋은 지도인 것과 별개로, 그 지도를 자기 인프라에 옮길 때의 판단은 각 팀의 몫입니다.

셋째, 이 글은 앞서 밝힌 대로 로컬 재현을 하지 못한 구조 분석입니다. 실제 도입 전에는 대상 모델을 Unsloth로 내보내 vLLM에서 서빙해 보고, 형식별 지연 시간과 처리량, 정확도를 자체 벤치마크로 확인하는 과정이 반드시 필요합니다.

## 출처

- AWS Machine Learning Blog, "Deploying quantized models on Amazon SageMaker AI with Unsloth": [https://aws.amazon.com/blogs/machine-learning/deploying-quantized-models-on-amazon-sagemaker-ai-with-unsloth/](https://aws.amazon.com/blogs/machine-learning/deploying-quantized-models-on-amazon-sagemaker-ai-with-unsloth/)
- Unsloth Documentation: [https://unsloth.ai/docs](https://unsloth.ai/docs)
- AWS, "Deploy LLMs on Amazon EKS using vLLM Deep Learning Containers"
