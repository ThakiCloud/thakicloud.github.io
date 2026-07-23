---
title: "8배 큰 모델이 5배 싼 이유: LLM 추론 비용의 실제 구조"
excerpt: "284B DeepSeek V4 Flash가 35B Qwen3.6보다 output 토큰이 5배 저렴한 역설을 roofline 모델로 해부합니다. KV 캐시 읽기, MoE 배치 경제학, 8xH100 서빙 형태 계산까지 추론 원가의 실제 구조를 숫자로 설명합니다."
seo_title: "LLM 추론 비용 구조 분석: KV 캐시와 MoE 서빙 경제학 - Thaki Cloud"
seo_description: "DeepSeek V4 Flash와 Qwen3.6 가격 역설을 통해 LLM 추론 비용의 실제 구조를 분석합니다. KV 캐시 읽기, MoE 배치 경제학, 8xH100 roofline 계산 포함."
date: 2026-07-05
tags:
  - LLM-추론
  - KV-캐시
  - MoE
  - vLLM
  - 서빙-비용
  - DeepSeek
  - Qwen
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/llmops/llm-inference-economics-kv-cache-moe-roofline/
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/llm-inference-economics-kv-cache-moe-roofline/"
categories:
  - llmops
header:
  teaser: /assets/images/llm-inference-economics-kv-cache-moe-roofline-hero.webp
---

![LLM 추론 비용 구조]({{ '/assets/images/llm-inference-economics-kv-cache-moe-roofline-hero.webp' | relative_url }})

## 개요: 8배 큰 모델이 5배 싸다는 역설

최근 추론 인프라 커뮤니티에서 흥미로운 질문이 돌았습니다. DeepSeek V4 Flash는 총 284B 파라미터 모델인데, 35B짜리 Qwen3.6-35B-A3B보다 output 토큰 가격이 5배가량 저렴합니다. 실측 가격을 보면 input은 둘 다 $0.14/M 수준으로 비슷하지만, output은 DeepSeek V4 Flash가 $0.18~0.28/M, Qwen3.6이 $1.00~1.49/M입니다.

더 이상한 점이 있습니다. 토큰당 활성 파라미터로 보면 Qwen3.6은 3B, DeepSeek V4 Flash는 13B입니다. 연산량 기준으로는 오히려 Qwen이 4배 가벼운데도 시장 가격은 정반대입니다. 파라미터 수가 곧 비용이라는 직관이 두 번 연속으로 깨지는 셈입니다.

이 글은 그 역설을 세 가지 층위로 해부합니다. 첫째, 디코드 비용의 지배항이 왜 연산이 아니라 메모리 읽기인지. 둘째, KV 캐시 깊이와 고정 요금 사이의 구조적 긴장. 셋째, 8xH100 기준의 최적 서빙 형태를 roofline 모델로 직접 계산했을 때 무엇이 보이는지. ThakiCloud처럼 고객 환경에서 모델을 직접 서빙하는 입장에서는 이 구조가 곧 원가 경쟁력이기 때문에, 실무 관점의 시사점도 함께 정리합니다.

## 두 모델의 아키텍처 사실 확인

먼저 스펙을 정확히 잡고 시작하겠습니다.

DeepSeek V4 Flash는 284B total / 13B active MoE입니다. 라우터가 256개 routed expert 중 top-6과 shared expert 1개를 선택합니다. 어텐션은 CSA(Compressed Sparse Attention)와 HCA(Heavily Compressed Attention)를 결합한 하이브리드 스택으로, 쿼리 패스마다 압축된 KV 엔트리 top-1,024개만 읽습니다. 공식 자료 기준으로 V3.2 대비 1M 컨텍스트에서 토큰당 추론 FLOPs 27%, KV 캐시 10% 수준입니다. 체크포인트는 MoE expert가 FP4, 나머지가 FP8인 혼합 포맷입니다.

Qwen3.6-35B-A3B는 35B total / 3B active MoE입니다(256 experts, 8 routed + 1 shared). 어텐션은 Gated DeltaNet 선형 어텐션 층과 full attention 층(KV head 2개, head dim 256)의 하이브리드입니다. 네이티브 컨텍스트는 262K이고 YaRN으로 1M까지 확장됩니다. FP8 체크포인트 기준 약 35GB로 H100 한 장에 들어갑니다.

요약하면 둘 다 세대 최신의 효율 지향 설계입니다. Qwen이 순진한 dense 모델이라서 비싼 것이 아니라는 점이 이 비교를 더 흥미롭게 만듭니다.

## 디코드 비용의 실제 구조: roofline 모델

토큰 생성(디코드)은 연산이 아니라 메모리 대역폭에 묶입니다. 디코드 스텝 시간의 1차 근사는 다음과 같습니다.

```text
T_step = (읽어야 할 weight 바이트 + Σ 요청별 KV 읽기 바이트) / 메모리 대역폭
throughput = batch_size / T_step
```

여기서 두 항의 성격이 완전히 다릅니다.

Weight 읽기는 배치가 나눠 갖습니다. 한 스텝에 weight를 한 번 읽으면 배치 안의 모든 요청이 공유합니다. 배치가 512면 토큰당 weight 비용은 512분의 1로 떨어집니다. MoE의 총 파라미터가 "배치가 크면 거의 공짜"가 되는 이유입니다.

KV 읽기는 요청마다 개별입니다. 각 요청은 자기 컨텍스트의 KV 캐시를 읽어야 하고, 이 비용은 배치를 키워도 나눠지지 않습니다. 컨텍스트가 깊어질수록 선형으로 늘어납니다.

그래서 배치가 충분히 크고 컨텍스트가 길어지면 비용의 지배항은 weight가 아니라 KV 읽기가 됩니다. 그런데 API 요금은 컨텍스트 깊이와 무관하게 토큰당 고정입니다. 32K 히스토리를 가진 요청과 500K 히스토리를 가진 요청이 같은 output 단가를 냅니다. 서빙 사업자 입장에서는 KV 읽기를 깊이와 무관하게 묶어둘 수 있는 모델이 고정 요금 체제에서 마진을 만듭니다.

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
<div class="d3-arch" data-arch-root id="nomicskvcachemoeroofline-1"></div>
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
  .d3-arch svg { display: block; width: 100%; min-width: 760px; height: auto; font-family: inherit; }

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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 484, "height": 790, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 223, "y": 24, "w": 120, "h": 46, "title": "디코드 스텝 비용"}, {"id": "B", "x": 318, "y": 148, "w": 120, "h": 46, "title": "Weight 읽기"}, {"id": "C", "x": 128, "y": 148, "w": 120, "h": 46, "title": "KV 캐시 읽기"}, {"id": "B1", "x": 303, "y": 272, "w": 149, "h": 62, "title": ["배치 전체가 공유", "배치 512면 1/512로 분할"]}, {"id": "C1", "x": 128, "y": 272, "w": 120, "h": 62, "title": ["요청마다 개별 발생", "배치로 나눠지지 않음"]}, {"id": "D", "x": 119, "y": 412, "w": 138, "h": 52, "title": "컨텍스트 깊이"}, {"id": "E", "x": 221, "y": 556, "w": 120, "h": 62, "title": ["깊이에 비례해 증가", "O(L) 읽기"]}, {"id": "F", "x": 24, "y": 556, "w": 142, "h": 62, "title": ["top-1,024 엔트리 고정", "깊이 무관 상수"]}, {"id": "G", "x": 221, "y": 696, "w": 120, "h": 62, "title": ["긴 컨텍스트에서", "비용 폭발"]}, {"id": "H", "x": 35, "y": 696, "w": 120, "h": 62, "title": ["고정 요금 체제에서", "마진 확보"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[318, 70], [378, 109], [378, 109], [378, 148]]}, {"src": "A", "dst": "C", "kind": "data", "curve": [[248, 70], [188, 109], [188, 109], [188, 148]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [378, 194, 378, 272]}, {"src": "C", "dst": "C1", "kind": "data", "line": [188, 194, 188, 272]}, {"src": "C1", "dst": "D", "kind": "data", "line": [188, 334, 188, 412]}, {"src": "D", "dst": "E", "kind": "data", "label": "\"일반 어텐션\"", "curve": [[222, 464], [281, 510], [281, 510], [281, 556]], "off": "50%"}, {"src": "D", "dst": "F", "kind": "data", "label": "\"희소 어텐션 CSA/HCA\"", "curve": [[154, 464], [95, 510], [95, 510], [95, 556]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "line": [281, 618, 281, 696]}, {"src": "F", "dst": "H", "kind": "data", "line": [95, 618, 95, 696]}]});
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
      const container = document.getElementById('nomicskvcachemoeroofline-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nomicskvcachemoeroofline-1';
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

## 8xH100 서빙 형태: 숫자로 비교

이제 실제로 8xH100(SXM5, 장당 80GB HBM3, 3.35TB/s, 총 640GB, 집계 26.8TB/s) 위에 두 모델을 올려보겠습니다. 시간당 비용은 온디맨드 기준 약 $20로 잡았습니다.

모델링 전제는 다음과 같습니다. Qwen3.6은 FP8 weight 약 35GB, 하이브리드 40층 중 full attention 층을 10개로 가정하면 [추정] 토큰당 KV는 약 10KB입니다(2 KV head × 256 dim × K/V 2개 × 10층 × 1바이트). DeepSeek V4 Flash는 FP4 expert + FP8 dense로 실효 weight 약 150GB [추정], 저장 KV는 V3.2 대비 10% 공식 주장을 기준으로 토큰당 약 3.5KB [추정], 디코드 시 읽기는 top-1,024 엔트리로 요청당 스텝마다 약 4MB 상수입니다.

### 서빙 형태부터 다릅니다

Qwen3.6의 최적 형태는 독립 레플리카 8개(DP8)입니다. 모델이 한 장에 들어가니 GPU 간 통신이 전혀 없고, 장당 약 38GB의 KV 예산이 남습니다. 로컬호스트 지향 설계의 전형적인 서빙 형태입니다.

DeepSeek V4 Flash는 8장을 하나의 TP/EP 그룹으로 묶어야 합니다. all-to-all 통신이 발생하는 대신, 약 490GB의 KV 예산을 배치 전체가 공유합니다.

### 컨텍스트 깊이별 처리량 계산

roofline 계산 결과입니다(실제 달성치는 통상 이 값의 50~60%이고, EP 통신과 prefill은 미반영입니다).

8K 컨텍스트에서는 Qwen 클러스터 약 76k tok/s, DeepSeek V4 Flash 약 90k tok/s로 비슷합니다. 통신 오버헤드까지 감안하면 사실상 Qwen이 우세합니다. 짧은 컨텍스트에서는 작은 모델이 하드웨어적으로 더 싸거나 동급이라는 뜻입니다.

32K에서 격차가 벌어지기 시작합니다. Qwen은 요청당 KV 읽기가 320MB로 늘며 약 31k tok/s, DeepSeek V4 Flash는 KV 읽기가 여전히 상수라 약 90k tok/s를 유지합니다. 약 3배 차이입니다.

256K에서 Qwen은 요청당 KV가 2.56GB에 달해 저장 상한 때문에 장당 배치가 14로 묶이고 약 5.3k tok/s로 떨어집니다. DeepSeek V4 Flash는 약 45k tok/s로 8.5배 차이가 납니다.

1M에서 Qwen은 스텝마다 요청당 10GB를 읽어야 해서 약 1.2k tok/s, 동시 24세션이 한계입니다. DeepSeek V4 Flash는 약 11k tok/s에 동시 64세션으로 10배 가까이 벌어집니다.

달러로 환산하면 32K에서 Qwen $0.18/M vs DeepSeek V4 Flash $0.06/M, 1M에서 Qwen $4.6/M vs DeepSeek V4 Flash $0.5/M입니다. 에이전틱 워크로드의 평균 깊이인 수십에서 수백 K 구간에서 원가 격차가 3~10배로 벌어지는데, 이것이 관측된 API 가격 차이(약 5배)와 정확히 같은 자리수입니다.

![컨텍스트 깊이별 처리량과 원가 비교]({{ '/assets/images/llm-inference-economics-kv-cache-moe-roofline-results.webp' | relative_url }})

한 가지 정직하게 밝혀둘 부분이 있습니다. DeepSeek V4 Flash의 토큰당 저장 KV에 대해 공개 자료 간 최대 40배의 모순이 존재합니다(vLLM recipes의 "V3.2 대비 10%" 주장과 일부 배포 가이드의 KV 표가 충돌). 위 계산은 1차 소스에 가까운 전자를 채택했고, 절대값보다 스케일링 방향(깊이에 따라 격차가 벌어지는 구조)이 결론이라는 점을 강조합니다.

## 계산이 드러내는 세 가지

첫째, Qwen의 병목은 KV 저장이 아니라 KV 읽기입니다. Gated DeltaNet 덕분에 저장(토큰당 약 10KB)은 이미 훌륭합니다. 문제는 full attention 층의 O(L) 읽기가 디코드 스텝마다 반복된다는 점입니다. DeepSeek V4 Flash는 저장도 작고 읽기는 아예 상수로 묶었습니다.

둘째, MoE 284B의 weight 읽기는 배치가 흡수합니다. 큰 배치에서 스텝당 weight 읽기는 약 150GB로 고정인데 512개 토큰이 나눠 가지면 토큰당 0.3GB입니다. 반면 Qwen DP8은 장마다 35GB를 각자 읽어 클러스터 집계로는 280GB/스텝입니다. 총 파라미터 8배 차이가 실효 읽기에서는 역전됩니다.

셋째, 짧은 컨텍스트에서는 Qwen이 하드웨어적으로 더 싼데도 시장 가격은 5배 비쌉니다. 가격표가 물리 원가를 반영하지 않는다는 정량적 증거입니다. DeepSeek는 1st-party API를 대규모 트래픽으로 굴리며 전용 커널(deep_gemm_mega_moe, FP4 indexer cache), prefill/decode 분리, MTP, 캐시 히트 98% 할인 같은 인프라 최적화의 원가 절감을 가격에 반영합니다. Qwen3.6-35B는 설계 자체가 로컬/싱글 GPU 지향이라 API 서빙은 주로 서드파티가 범용 vLLM 스택으로 담당하는데, 트래픽 밀도가 낮으면 GPU 유휴 시간까지 요금에 녹여야 하니 호가가 올라갑니다. 시장 가격은 원가가 아니라 수요 밀도와 최적화 수준의 함수입니다.

## ThakiCloud 제품 적용 시사점

이 분석은 ThakiCloud ai-platform이 매일 마주하는 의사결정과 직결됩니다. 온프렘과 소버린 클라우드 환경에서 고객의 GPU로 모델을 서빙할 때, 같은 하드웨어에서 토큰 원가를 결정하는 것은 모델 크기가 아니라 서빙 형태입니다. 위 계산이 보여주듯 같은 8xH100에서도 DP8과 TP/EP 그룹의 선택, KV 캐시 dtype, max-model-len 설정에 따라 실효 처리량이 몇 배씩 달라집니다. ai-platform은 K8s와 Kueue 기반 GPU 스케줄링 위에서 vLLM 서빙 파라미터를 워크로드 프로파일(평균 컨텍스트 깊이, 동시 세션 수)에 맞춰 구성하는 것을 표준 프로세스로 두고 있으며, 이 글의 roofline 모델이 그 사이징의 출발점입니다.

에이전트 워크로드 관점도 있습니다. Paxis(ThakiCloud의 Agent-Native Cloud)에서 에이전트는 긴 히스토리와 반복 tool call을 만드는데, 이는 정확히 KV 깊이가 깊은 트래픽입니다. 컨텍스트 깊이에 강한 모델과 prefix 캐시 인프라의 조합이 에이전트 경제성을 좌우한다는 것이 이 분석의 실무적 결론입니다. 낮은 서빙 원가(ai-platform)가 에이전트 단가(Paxis)를 만드는 구조입니다.

## 한계 및 반론

이 분석의 한계를 명시합니다. 첫째, roofline은 상한 모델입니다. 실제 처리량은 커널 효율, EP all-to-all 통신, prefill과 decode의 간섭 때문에 통상 50~60% 수준이고, MTP 같은 speculative 기법은 반대로 처리량을 끌어올립니다. 둘째, DeepSeek V4 Flash의 KV 수치는 공개 자료 간 모순이 있어 [추정] 라벨을 유지했습니다. 셋째, Qwen3.6의 full attention 층 수는 공개 config 기준의 추정이며, 하이브리드 비율이 다르면 절대값이 달라집니다. 넷째, 품질은 별개 축입니다. DeepSeek V4 Flash는 V4 Pro 대비 복잡한 다단계 추론에서 열세이므로, 원가만으로 모델을 고르는 것은 잘못된 결론입니다. 원가 분석은 "같은 품질 요구 수준에서 어떤 서빙 형태가 경제적인가"라는 질문에만 답합니다.

## 참고 자료

- [vLLM Recipes: DeepSeek-V4-Flash](https://recipes.vllm.ai/deepseek-ai/DeepSeek-V4-Flash)
- [vLLM Recipes: Qwen3.6-35B-A3B](https://recipes.vllm.ai/Qwen/Qwen3.6-35B-A3B)
- [DeepSeek API Docs: Models & Pricing](https://api-docs.deepseek.com/quick_start/pricing)
- [OpenRouter: DeepSeek V4 Flash](https://openrouter.ai/deepseek/deepseek-v4-flash)
- [OpenRouter: Qwen3.6 35B A3B](https://openrouter.ai/qwen/qwen3.6-35b-a3b)
- [Qwen 공식 블로그: Qwen3.6-35B-A3B](https://qwen.ai/blog?id=qwen3.6-35b-a3b)
- [Spheron: Deploy DeepSeek V4-Flash on GPU Cloud](https://www.spheron.network/blog/deploy-deepseek-v4-flash-gpu-cloud/)
