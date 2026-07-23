---
title: "1비트로 줄인 744B: Unsloth GLM-5.2 Dynamic GGUF가 던지는 온프레미스 질문"
excerpt: "Unsloth가 GLM-5.2(약 744B MoE)의 1.51TB BF16 가중치를 1비트 Dynamic GGUF로 줄여 176GB까지 압축했습니다. 프런티어급 오픈 모델을 256GB Mac이나 멀티 GPU 한 대에서 돌릴 수 있게 된 셈입니다. 양자화 단계별 용량·정확도 공개 수치와 함께, GGUF 로컬 서빙이 ThakiCloud 같은 멀티테넌트 K8s 플랫폼에 어디까지 들어맞고 어디서 갈라지는지 정리합니다."
seo_title: "Unsloth GLM-5.2 1비트 Dynamic GGUF 양자화 온프레미스 서빙 분석 - Thaki Cloud"
seo_description: "Unsloth GLM-5.2 Dynamic GGUF(1.51TB→176GB, 1비트)의 양자화 단계별 용량·정확도, 256GB Mac 로컬 실행, llama.cpp vs vLLM 서빙 트레이드오프를 ThakiCloud K8s 멀티테넌트 서빙 플랫폼 관점에서 분석합니다."
date: 2026-06-25
last_modified_at: 2026-06-25
tags:
  - gguf
  - quantization
  - unsloth
  - glm-5
  - llama-cpp
  - on-premise
  - moe
  - inference-optimization
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "microchip"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/unsloth-glm-5-2-1bit-gguf/"
reading_time: true
categories:
  - llmops
published: false
---

자체 인프라에서 큰 모델을 돌리려는 팀이 가장 먼저 부딪히는 벽은 언제나 메모리입니다. 프런티어급 모델을 외부 API로 부르면 데이터가 회사 밖으로 나가고, 직접 호스팅하려면 수백 GB에서 1TB가 넘는 가중치를 어딘가에 올려야 합니다. Unsloth가 2026년 6월 공개한 `unsloth/GLM-5.2-GGUF`는 이 벽을 양자화로 낮춘 사례입니다. 약 744B 파라미터의 MoE 오픈 모델 GLM-5.2를, 원본 BF16 기준 1.51TB에 달하던 가중치를 1비트 Dynamic GGUF로 176GB까지 줄였습니다. 이 글의 모든 수치는 Unsloth와 Hugging Face가 공개한 측정치이며, 744B 모델은 본 분석 환경에서 직접 실행이 불가능해 자체 재현 대신 공개 벤치마크를 인용하고 그 한계를 분명히 밝힙니다.

![1.51TB 원본을 1비트 Dynamic GGUF 176GB로 압축해 256GB 단일 노드에 올리는 개념도]({{ '/assets/images/unsloth-glm-5-2-1bit-gguf-slide-02.webp' | relative_url }})

## 개요

GLM-5.2는 Z.ai(Zhipu)가 공개한 오픈웨이트 대형 언어 모델입니다. 약 744B 총 파라미터의 Mixture-of-Experts(MoE) 구조에 최대 100만 토큰 컨텍스트를 지원하며, Unsloth 문서와 여러 매체 보도에 따르면 Artificial Analysis를 비롯한 종합 벤치마크에서 Claude 4.8 Opus, GPT-5.5, Gemini 3.1 Pro와 대등한 수준으로 평가됩니다. "현재까지 가장 강한 오픈 모델"이라는 평가가 붙는 이유입니다.

문제는 크기입니다. 원본 BF16 체크포인트는 약 1.51TB로, 단일 서버에 그대로 올리기 어렵습니다. Unsloth가 한 일은 이 가중치를 Dynamic 2.0 GGUF 방식으로 양자화해, 1비트에서 4비트까지 단계별 버전을 만든 것입니다. 그 결과 1비트 버전은 176GB까지 내려가, 256GB 통합 메모리를 가진 Mac Studio 한 대나 멀티 GPU 한 대에서도 로딩이 가능해졌습니다. 프런티어급으로 평가받는 모델을 데이터센터 랙이 아니라 책상 위 장비에서 돌릴 수 있다는 뜻입니다.

ThakiCloud는 K8s 기반 멀티테넌트 AI/ML SaaS 플랫폼을 운영하면서, 고객이 데이터를 외부로 내보내지 않고도 강한 모델을 쓰도록 온프레미스·VPC 서빙을 다룹니다. 그래서 "프런티어급 오픈 모델을 얼마나 작은 하드웨어에서 돌릴 수 있는가"라는 질문은 곧 우리 고객의 서빙 단가와 데이터 주권에 직결됩니다. 다만 결론을 먼저 말하면, GGUF 양자화는 로컬·단일 사용자 시나리오에 강력하지만 고동시성 멀티테넌트 서빙에서는 결이 다릅니다. 이 글은 그 경계를 다룹니다.

## 이 기술은 무엇인가

GGUF는 llama.cpp 생태계에서 쓰는 모델 파일 포맷이고, 양자화는 16비트 부동소수점 가중치를 더 적은 비트로 표현해 용량과 메모리를 줄이는 기법입니다. 여기서 핵심은 Unsloth의 **Dynamic 2.0** 방식입니다. 모든 레이어를 똑같이 1비트로 깎는 것이 아니라, 정보 손실에 민감한 레이어는 더 높은 비트로 보존하고 둔감한 레이어만 공격적으로 압축합니다. "1비트"라는 이름이 붙어도 실제로는 레이어별로 비트 폭이 섞여 있고, 그래서 같은 평균 비트 수에서도 단순 양자화보다 정확도가 덜 떨어집니다.

GLM-5.2가 MoE라는 점이 이 조합을 특히 의미 있게 만듭니다. MoE는 토큰 하나를 생성할 때 744B 전체가 아니라 라우터가 고른 일부 전문가만 계산에 참여하므로, 연산량은 활성 파라미터 규모에 가깝습니다. 즉 **MoE가 연산을, Dynamic GGUF가 메모리를** 각각 담당하는 구조입니다. 아래 흐름도가 두 축과, ThakiCloud 관점에서 갈라지는 서빙 경로를 함께 보여줍니다.

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
<div class="d3-arch" data-arch-root id="0625unslothglm521bitgguf-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 638, "height": 1114, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 313, "y": 24, "w": 260, "h": 294, "label": "양자화 축 (메모리)", "lx": 325, "ly": 42}, {"x": 24, "y": 540, "w": 205, "h": 542, "label": "서빙 축 (속도)", "lx": 36, "ly": 558}], "nodes": [{"id": "A", "x": 383, "y": 63, "w": 120, "h": 62, "title": ["GLM-5.2 BF16", "약 1.51TB"]}, {"id": "B", "x": 372, "y": 217, "w": 142, "h": 62, "title": ["1비트 Dynamic GGUF", "UD-TQ1_0 176GB"]}, {"id": "C", "x": 62, "y": 595, "w": 120, "h": 46, "title": "입력 토큰"}, {"id": "D", "x": 72, "y": 735, "w": 120, "h": 46, "title": "MoE 라우터"}, {"id": "E", "x": 72, "y": 873, "w": 120, "h": 46, "title": "활성 전문가 연산"}, {"id": "F", "x": 72, "y": 997, "w": 120, "h": 46, "title": "출력 토큰"}, {"id": "R", "x": 374, "y": 396, "w": 138, "h": 52, "title": "서빙 시나리오"}, {"id": "L", "x": 457, "y": 579, "w": 149, "h": 78, "title": ["llama.cpp", "256GB Mac / 멀티GPU", "약 21.6 tok/s"]}, {"id": "V", "x": 267, "y": 587, "w": 135, "h": 62, "title": ["vLLM + FP8/FP4", "연속 배칭·K8s/Kueue"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "\"Unsloth Dynamic 2.0<br/>레이어별 비트 할당\"", "line": [443, 125, 443, 217], "lx": 443, "ly": 167}, {"src": "C", "dst": "D", "kind": "data", "line": [122, 641, 128, 735]}, {"src": "D", "dst": "E", "kind": "data", "label": "\"744B 중 일부 전문가만\"", "line": [132, 781, 132, 873], "lx": 132, "ly": 823}, {"src": "E", "dst": "F", "kind": "data", "line": [132, 919, 132, 997]}, {"src": "B", "dst": "R", "kind": "data", "line": [443, 279, 443, 396]}, {"src": "R", "dst": "L", "kind": "data", "label": "\"단일 사용자·로컬·온프렘 PoC\"", "curve": [[474, 448], [531, 494], [531, 540], [531, 579]], "off": "50%"}, {"src": "R", "dst": "V", "kind": "data", "label": "\"고동시성 멀티테넌트\"", "curve": [[403, 448], [334, 494], [334, 540], [334, 587]], "off": "50%"}, {"src": "L", "dst": "D", "kind": "data", "curve": [[457, 635], [180, 696], [180, 696], [150, 735]]}, {"src": "V", "dst": "D", "kind": "data", "curve": [[267, 645], [142, 696], [142, 696], [135, 735]]}]});
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
      const container = document.getElementById('0625unslothglm521bitgguf-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '0625unslothglm521bitgguf-1';
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

양자화 축에서 BF16 가중치는 Unsloth Dynamic 2.0 보정을 거쳐 1비트 GGUF가 됩니다. 서빙 축에서는 MoE 라우터가 토큰마다 일부 전문가만 활성화합니다. 두 축이 만나는 지점에서 시나리오가 갈리는데, 단일 사용자·로컬 검증에는 llama.cpp + GGUF가, 고동시성 서빙에는 vLLM + GPU 양자화가 더 적합합니다. 이 분기는 글 후반에서 다시 다룹니다.

## 설치 및 통합

GGUF의 장점은 진입 장벽이 낮다는 점입니다. llama.cpp 또는 그 래퍼만 있으면 됩니다. Unsloth 문서가 안내하는 표준 경로는 다음과 같습니다.

Hugging Face에서 원하는 양자화 버전만 내려받습니다. 1비트 `UD-TQ1_0`을 예로 들면 다음과 같습니다.

```bash
# huggingface_hub로 1비트 GGUF 샤드만 선택 다운로드
pip install -U huggingface_hub hf_transfer
HF_HUB_ENABLE_HF_TRANSFER=1 \
huggingface-cli download unsloth/GLM-5.2-GGUF \
  --include "*UD-TQ1_0*" \
  --local-dir GLM-5.2-GGUF
```

내려받은 뒤 llama.cpp로 서버를 띄웁니다. MoE 모델이므로 `--n-gpu-layers`와 컨텍스트 길이를 환경에 맞춰 조정합니다.

```bash
# llama.cpp 서버 (OpenAI 호환 엔드포인트)
./llama-server \
  --model GLM-5.2-GGUF/GLM-5.2-UD-TQ1_0-00001-of-*.gguf \
  --ctx-size 16384 \
  --n-gpu-layers 999 \
  --jinja \
  --host 0.0.0.0 --port 8080
```

256GB 통합 메모리를 가진 Mac Studio(M3 Ultra)에서는 Metal 백엔드로 전체 레이어를 메모리에 올릴 수 있고, x86 멀티 GPU 환경에서는 GPU와 CPU/RAM에 레이어를 분할 배치(offload)하는 방식으로 돌립니다. 양자화 단계가 높을수록 더 많은 메모리가 필요하므로, 가진 하드웨어의 용량이 곧 선택 가능한 양자화 상한이 됩니다.

## 실제 실험 결과

여기서부터는 Unsloth와 Hugging Face가 공개한 측정치입니다. 744B 모델은 본 분석 환경에서 직접 호스팅이 불가능하므로, 자체 재현 수치가 아니라 출처가 분명한 공개 데이터임을 명시합니다. 아래는 양자화 단계별 파일 크기를 정리한 표입니다.

| 양자화 | 대표 버전 | 파일 크기 | BF16(1.51TB) 대비 |
|---|---|---|---|
| 1비트 | UD-TQ1_0 | 176GB | 약 88% 감소 |
| 1비트 | UD-IQ1_S | 204GB | 약 86% 감소 |
| 2비트 | UD-IQ2_M | 255GB | 약 83% 감소 |
| 3비트 | UD-Q3_K_XL | 332GB | 약 78% 감소 |
| 4비트 | Q4_K_M | 456GB | 약 70% 감소 |

![GLM-5.2 양자화 단계별 파일 크기와 BF16 대비 압축률]({{ '/assets/images/unsloth-glm-5-2-1bit-gguf-results.webp' | relative_url }})

정확도 측면에서 Unsloth는 Dynamic 양자화가 같은 평균 비트 수의 단순 양자화보다 손실이 작다고 보고합니다. 공개 자료에 따르면 Dynamic 1비트 버전은 자체 정확도 지표 기준 약 76%[추정], Dynamic 2비트 버전은 약 82% 수준을 유지하면서도 원본 대비 80% 이상 작아진다고 설명합니다. 정확한 측정 지표와 데이터셋 정의는 버전·평가셋에 따라 달라지므로, 이 수치는 절대값보다 "단계가 낮아질수록 손실이 점진적으로 늘지만 1비트에서도 사용 가능한 범위에 머문다"는 경향으로 읽는 편이 안전합니다. Unsloth는 별도로 Aider Polyglot 코딩 벤치마크에서 Dynamic GGUF 결과를 공개하고 있어, 코딩 과제에서의 단계별 품질 변화를 교차 확인할 수 있습니다.

처리 속도는 하드웨어에 크게 좌우됩니다. 공개 보도 기준, 256GB Mac Studio(M3 Ultra)에서 1비트 버전이 약 21.6 tok/s로 동작했습니다. 단일 사용자가 대화형으로 쓰기에는 충분하지만, 동시에 수십 개 요청을 받는 서버 부하에서는 다른 그림이 됩니다. 이 차이가 다음 절의 핵심입니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

ThakiCloud는 다양한 고객 환경에서 모델을 서빙하며, 그중 적지 않은 수가 "데이터를 밖으로 내보낼 수 없다"는 제약을 가집니다. 금융·공공·의료처럼 데이터 주권이 핵심인 곳에서는, 프런티어급 모델을 외부 API로 부르는 선택지 자체가 닫혀 있습니다. 이때 GLM-5.2 Dynamic GGUF는 강력한 협상 카드가 됩니다. 1.51TB짜리 프런티어급 오픈 모델을, 256GB 단일 노드 수준의 하드웨어에서 실행 가능한 형태로 만들어 주기 때문입니다.

![단일 노드 온프레미스 도입의 3대 유스케이스: 온프레미스 PoC·저빈도 고민감 워크로드·하드웨어 다양성 흡수]({{ '/assets/images/unsloth-glm-5-2-1bit-gguf-slide-06.webp' | relative_url }})

구체적인 적용 각도는 세 가지입니다. 첫째, **온프레미스 PoC와 평가**입니다. 고객 데이터센터에 들어가기 전, 모델이 해당 도메인에서 쓸 만한지 빠르게 검증할 때 GGUF 로컬 실행은 GPU 클러스터를 예약하지 않고도 한 대의 장비로 돌려볼 수 있는 가장 싼 경로입니다. 둘째, **저빈도·고민감 워크로드**입니다. 동시 사용자가 많지 않지만 데이터가 절대 외부로 나가면 안 되는 내부 분석·문서 처리에는, 단일 노드 GGUF 서빙이 비용과 보안을 동시에 만족시킵니다. 셋째, **하드웨어 다양성 흡수**입니다. llama.cpp는 Mac의 Metal, x86 GPU, CPU offload를 모두 지원하므로, 고객이 이미 보유한 잡다한 하드웨어를 그대로 활용하는 유연성을 줍니다.

ThakiCloud의 표준 서빙 스택은 K8s 위에서 Kueue로 GPU를 큐잉하고 vLLM으로 모델을 띄우는 구조입니다. 여기에 GGUF 경로를 더하면, "고동시성 멀티테넌트는 vLLM + FP8/FP4, 단일 노드 온프렘은 llama.cpp + Dynamic GGUF"라는 이원화된 서빙 메뉴를 고객 상황에 맞춰 제시할 수 있습니다. 같은 GLM-5.2 계열 안에서도 워크로드 성격에 따라 양자화 방식과 런타임을 바꿔 끼우는 것입니다. 이 선택지를 가진 벤더와 그렇지 않은 벤더의 차이는, 고객이 "우리 환경에서는 이게 안 된다"고 말할 때 드러납니다.

## 한계 및 반론

이 기술을 과대평가하지 않으려면 몇 가지를 분명히 해야 합니다.

![1비트 정확도 손실·멀티테넌트 서빙 한계·장비 비용·자체 검증 필요성을 짚는 현실 점검]({{ '/assets/images/unsloth-glm-5-2-1bit-gguf-slide-07.webp' | relative_url }})

첫째, **1비트는 공짜가 아닙니다.** Dynamic 양자화가 손실을 줄여 준다고 해도, 1비트 버전의 정확도는 원본보다 분명히 낮습니다. 복잡한 추론·장문 코딩처럼 오차가 누적되는 과제에서는 2~4비트 버전과의 차이가 체감됩니다. "프런티어급 모델을 1비트로"라는 문장은 매력적이지만, 실제 도입에서는 과제별로 어느 비트가 품질 손익분기점인지 직접 측정해야 합니다.

둘째, **GGUF는 멀티테넌트 서빙용 포맷이 아닙니다.** 21.6 tok/s라는 수치는 단일 스트림 기준입니다. vLLM의 연속 배칭(continuous batching)은 동시 요청을 묶어 처리량을 끌어올리는데, llama.cpp는 이 영역에서 약합니다. 수십~수백 동시 사용자를 받는 SaaS 멀티테넌트 서빙이라면, 1비트 GGUF보다 GPU 위 FP8/FP4 양자화 + vLLM 조합이 단위 비용당 처리량에서 보통 앞섭니다. GGUF의 자리는 "많은 사람에게 동시에"가 아니라 "한 환경에서 안전하게"입니다.

셋째, **하드웨어가 싸진 것은 아닙니다.** 256GB 통합 메모리 Mac Studio는 8×H100 같은 데이터센터 GPU보다는 훨씬 저렴하지만, 그 자체로는 결코 저가 장비가 아닙니다. "책상 위에서 돌아간다"는 표현이 "누구나 부담 없이"를 뜻하지는 않습니다.

넷째, **공개 수치는 대부분 Unsloth 자체 보고입니다.** 양자화 단계별 정확도와 속도는 평가셋·하드웨어·런타임 설정에 따라 흔들립니다. 도입 결정은 벤더 발표가 아니라 자사 데이터로 재현한 결과 위에서 내려야 합니다. 본 글이 자체 재현 대신 출처를 명시한 이유도 같은 원칙입니다.

정리하면, Unsloth GLM-5.2 Dynamic GGUF는 "프런티어급 오픈 모델의 온프레미스 진입 장벽을 한 단계 낮춘 도구"로 평가하는 것이 정확합니다. 모든 서빙을 대체하는 만능 해법이 아니라, 데이터 주권과 단일 노드 비용이 중요한 시나리오에서 강력한 선택지입니다. ThakiCloud처럼 워크로드별로 런타임을 갈아 끼울 수 있는 플랫폼에게는, 고객의 "안 된다"를 "이렇게 하면 된다"로 바꾸는 카드가 한 장 더 늘어난 셈입니다.

![만능 해법이 아니라 데이터 주권을 지키며 프런티어급 모델을 온프레미스로 안착시키는 선택지]({{ '/assets/images/unsloth-glm-5-2-1bit-gguf-slide-08.webp' | relative_url }})

## 출처

- [unsloth/GLM-5.2-GGUF · Hugging Face](https://huggingface.co/unsloth/GLM-5.2-GGUF)
- [GLM-5.2 - How to Run Locally | Unsloth Documentation](https://unsloth.ai/docs/models/glm-5.2)
- [Unsloth Dynamic 2.0 GGUFs | Unsloth Documentation](https://unsloth.ai/docs/basics/unsloth-dynamic-2.0-ggufs)
- [unsloth/GLM-5.2-GGUF · GLM-5.2 GGUF Benchmarks! (Discussion)](https://huggingface.co/unsloth/GLM-5.2-GGUF/discussions/3)
- [Unsloth Quantizes GLM-5.2's 1.51TB to 217GB for Local Inference | AI Weekly](https://aiweekly.co/alerts/unsloth-quantizes-glm-52s-151tb-to-217gb-for-local-inference)
