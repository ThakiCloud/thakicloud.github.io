---
title: "지능 전쟁에서 가치 전쟁으로: 프론티어 API를 떠나는 기업들과 이전의 경제학"
excerpt: "마이크로소프트는 엑셀과 아웃룩의 대량 AI 요청을 자사 모델로 돌리기 시작했고, 중국 오픈 모델은 미국 기업 AI 사용량의 절반 가까이를 잠식했으며, 시장에서는 1조 달러가 넘는 시가총액이 하루아침에 사라졌습니다. 프리미엄 프론티어 모델을 영원히 결제한다는 가정이 무너지는 중입니다. 이 글은 그 신호를 읽고, 대량 워크로드를 오픈 모델로 옮기는 이전 플레이북을 정리한 뒤, 그것을 실행하는 제어 평면으로서 ThakiCloud의 ai-platform과 Paxis가 어떻게 맞물리는지 설명합니다."
tags:
  - cost-optimization
  - model-routing
  - open-weights
  - self-hosting
  - vllm
  - paxis
date: 2026-07-10
lang: ko
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/ai-cost-war-migration-frontier-to-open/"
categories:
  - llmops
---

![프론티어 API에서 오픈 모델로 이전하는 흐름을 표현한 추상 일러스트]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-hero.png' | relative_url }})

지난 몇 주 사이 AI 업계의 화제는 "누가 더 똑똑한가"에서 "누가 더 싼가"로 옮겨갔습니다. 가장 상징적인 장면은 마이크로소프트에서 나왔습니다. 오픈AI를 현대 AI 산업의 궤도에 올려놓은 바로 그 회사가, 엑셀과 아웃룩 안에서 매주 수만 건씩 발생하는 AI 요청을 오픈AI와 앤트로픽 대신 자사 모델로 돌리기 시작했습니다. 마이크로소프트 AI 책임자 무스타파 술레이만은 이를 감추지 않았습니다. "앤트로픽은 극도로 비쌉니다. 우리 목표는 그 비용을 줄이고 궁극적으로는 없애는 것입니다"라고 그는 말했습니다.

이 글은 엔지니어링 리더와 AI 팀, 그리고 자사 서비스의 추론 비용을 책임지는 의사결정자를 위한 것입니다. 지금 벌어지는 비용 전쟁이 왜 일시적 소음이 아니라 구조적 전환인지 짚고, 프론티어 API 지출을 오픈 모델과 자체 호스팅으로 옮기는 이전 플레이북을 정리합니다. 마지막으로 그 이전을 실제로 굴리는 제어 평면으로서 ThakiCloud가 어떤 위치에 있는지 설명합니다.

## 무엇이 바뀌었나

한 회사의 결정만으로 추세를 말할 수는 없습니다. 그런데 같은 방향의 신호가 몇 주 사이에 겹쳐서 나왔습니다.

첫째, 마이크로소프트의 우회는 정밀했습니다. 가장 어렵고 희귀한 작업은 여전히 프론티어 모델로 보내되, 이메일 답장이나 스레드 요약, 간단한 스프레드시트 수식처럼 지루하고 양이 많은 작업만 자사 모델로 되찾는 방식입니다. 이것이 중요한 이유는 바로 그 지루한 대량 작업이 실제로 돈이 흐르는 곳이기 때문입니다({% raw %}[SiliconANGLE 보도](https://siliconangle.com/2026/07/07/microsoft-reportedly-ditching-openais-anthropics-ai-models-favor-cut-costs/){% endraw %}).

둘째, 미국 기업들이 가격을 피해 중국 오픈 모델로 이동하고 있습니다. CNBC 보도에 따르면 한 주요 라우팅 플랫폼에서 중국 모델이 미국 기업 AI 사용량의 30퍼센트 이상을 처리했고 최고 46퍼센트까지 올랐습니다. 1년 전 평균 11퍼센트에서 급등한 수치입니다. 비용은 60에서 90퍼센트 저렴하고, 일부 에이전트 벤치마크에서는 최고 미국 모델과 1점 차이까지 좁혔습니다({% raw %}[CNBC 보도](https://www.cnbc.com/2026/07/07/chinese-ai-models-costs-us-openai-anthropic.html){% endraw %}).

셋째, 공급 과잉의 신호가 나왔습니다. 메타는 "잉여" AI 컴퓨트를 판매하는 클라우드 사업을 준비한다고 밝혔습니다. 너무 많이 지었다는 사실을 사업 모델로 인정한 셈입니다({% raw %}[CNBC 보도](https://www.cnbc.com/2026/07/01/meta-stock-cloud-ai-compute.html){% endraw %}).

넷째, 시장이 반응했습니다. 6월 말 반도체와 AI 관련 주식에서 1조 달러가 넘는 시가총액이 며칠 만에 사라졌고, 월스트리트는 이 막대한 지출이 정말 회수될 수 있는지 묻기 시작했습니다(로이터 집계 기준 약 1.3조 달러 [추정]).

이 신호들의 공통점은 하나입니다. 프론티어 모델의 성능이 나빠져서가 아닙니다. 오히려 성능은 계속 좋아지고 있습니다. 문제는 가장 큰 고객들조차 "모든 작업에 최고 모델을 쓰고 최고가를 낸다"는 전제를 더는 받아들이지 않는다는 데 있습니다.

가격 자체도 빠르게 내려가고 있습니다. 오픈AI가 최근 공개한 GPT-5.6 Sol은 100만 토큰당 입력 5달러, 출력 30달러 수준으로, 직전 세대보다 토큰당 비용이 큰 폭으로 떨어졌습니다({% raw %}[CNBC 보도](https://www.cnbc.com/2026/07/08/openai-expanding-gpt-5point6-ai-model-release-ending-government-limits.html){% endraw %}). 프론티어 연구소들끼리도 가격 전쟁에 들어갔다는 뜻입니다. 최전선은 더 이상 지능 전쟁이 아니라 가치 전쟁으로 바뀌었습니다.

![시장의 붕괴 신호를 정리한 슬라이드. 중국 오픈 모델 60에서 90퍼센트 저렴, GPT-5.6 Sol 100만 토큰당 입력 5달러 출력 30달러, 반도체와 AI 주식에서 1조 달러 규모 증발]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-slide-03.png' | relative_url }})

## 왜 지금인가

비용 전쟁이 지금 터진 이유는 워크로드의 분포에 있습니다.

![워크로드를 어려운 추론과 정형화된 대량 작업이라는 두 세계로 나눈 구조적 진단 슬라이드]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-slide-04.png' | relative_url }})

에이전트가 하루에 처리하는 일을 뜯어보면 성격이 뚜렷하게 갈립니다. 한쪽에는 진짜 어려운 추론이 있습니다. 애매한 설계 결정, 미묘한 디버깅, 처음 보는 문제의 분해 같은 것입니다. 다른 한쪽에는 정형화된 대량 작업이 있습니다. 분류, 라우팅, 요약, 규격 검사, 정해진 양식의 답장이 여기 속합니다. 건수로 보면 후자가 압도적으로 많습니다.

프론티어 연구소들의 재무 가정은 단순했습니다. 전 세계 기업이 이 작은 요청 수십억 건을 영원히 비싼 모델로 처리하리라는 것이었습니다. 끝없이 흐르는 그 토큰의 강이 프론티어 기업들의 높은 밸류에이션을 떠받치는 근거였습니다.

그런데 정형화된 작업의 품질은 모델의 지능보다 가드레일이 좌우합니다. 출력 포맷이 흔들리는 이유는 모델이 부족해서가 아니라, 포맷을 산문으로 부탁했기 때문입니다. 길이 상한과 허용값 집합, 렌더링 규격, 통과 기준을 코드가 강제하면, 그 작업은 훨씬 값싼 오픈 모델로도 안정적으로 나옵니다. "충분히 좋은" 수준이 가격의 일부만으로 가능해지는 순간, 대량 작업의 강물을 되찾는 것이 합리적 선택이 됩니다. 마이크로소프트가 정확히 그 판단을 했습니다.

## 프론티어에서 오픈으로: 이전 플레이북

그렇다면 이 강물을 어떻게 옮길까요. 즉흥적으로 모델을 바꾸는 것은 위험합니다. 신뢰할 수 있는 이전은 다음 다섯 단계를 거칩니다.

![프론티어에서 오픈으로 넘어가는 이전 플레이북의 다섯 단계. 분류, 평가, 라우팅, 자체 호스팅, 검증]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-slide-05.png' | relative_url }})

먼저 워크로드를 분류합니다. 각 요청을 난이도와 민감도 두 축으로 나눕니다. 어렵거나 민감한 작업은 프론티어에 남기고, 정형화된 대량 작업만 이전 대상으로 표시합니다.

다음으로 대체 후보를 평가합니다. 이전 대상 작업마다 오픈 모델 후보를 실제 데이터로 채점합니다. 여기서 핵심은 사람의 인상이 아니라 코드가 계산한 통과율입니다. 실제 출력을 규격 검사에 통과시키고, 임계에 못 미치면 후보에서 탈락시킵니다.

세 번째로 라우팅을 구성합니다. 작업 유형별로 어떤 모델을 쓸지 규칙을 한곳에 정의합니다. 이 규칙이 단일 진실 공급원이 되어야 나중에 모델을 교체하거나 되돌리기가 쉽습니다.

네 번째로 오픈 모델을 자체 호스팅합니다. 선정된 오픈 모델을 vLLM 같은 서빙 엔진으로 자사 인프라에 올립니다. 이 단계에서 온프레미스와 데이터 주권, 그리고 단위 비용의 이점이 실현됩니다.

마지막으로 검증하고 되돌립니다. 이전 후에도 품질을 계속 측정하고, 통과율이 흔들리면 해당 작업만 다시 프론티어로 올립니다. 되돌림 경로가 없는 이전은 이전이 아니라 도박입니다.

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
<div class="d3-arch" data-arch-root id="rmigrationfrontiertoopen-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 542, "height": 820, "legendTitle": "Legend", "legend": {"data": "Flow", "event": "Dotted / alternate path"}, "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 126, "y": 24, "w": 120, "h": 46, "title": "들어오는 워크로드"}, {"id": "B", "x": 117, "y": 148, "w": 138, "h": 68, "title": ["분류 게이트", "난이도 · 민감도"]}, {"id": "C", "x": 340, "y": 462, "w": 170, "h": 62, "title": ["프론티어 API", "Claude · GPT-5.6 Sol"]}, {"id": "D", "x": 126, "y": 308, "w": 120, "h": 62, "title": ["오픈 모델 후보", "eval 통과율로 선정"]}, {"id": "E", "x": 87, "y": 462, "w": 198, "h": 62, "title": ["자체 호스팅 서빙", "vLLM · Metis · Kueue GPU"]}, {"id": "F", "x": 122, "y": 602, "w": 128, "h": 62, "title": ["정책 게이트 + 감사 로그", "Paxis 제어 평면"]}, {"id": "G", "x": 126, "y": 742, "w": 120, "h": 46, "title": "결과"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [186, 70, 186, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "어렵거나 민감", "curve": [[255, 205], [425, 262], [425, 416], [425, 462]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "정형화된 대량 작업", "line": [186, 216, 186, 308], "lx": 186, "ly": 258}, {"src": "D", "dst": "E", "kind": "data", "line": [186, 370, 186, 462]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[425, 524], [425, 563], [425, 563], [250, 614]]}, {"src": "E", "dst": "F", "kind": "data", "line": [186, 524, 186, 602]}, {"src": "F", "dst": "G", "kind": "data", "line": [186, 664, 186, 742]}, {"src": "F", "dst": "B", "kind": "event", "label": "품질 저하 감지", "curve": [[126, 602], [50, 493], [50, 339], [128, 216]], "off": "50%"}]});
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
      const container = document.getElementById('rmigrationfrontiertoopen-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'rmigrationfrontiertoopen-1';
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

X상에서 한 개발자는 이 방식으로 월 6만 달러의 API 지출을 오픈 모델로 옮겨 1만 2천 달러까지, 약 80퍼센트 줄였다고 공유했습니다. 원문 게시물은 접근이 제한되어 독립적으로 검증하지는 못했으므로 수치는 참고용입니다([추정]). 다만 절감의 크기 자체는 검증된 자료와 결이 같습니다. 중국 오픈 모델의 60에서 90퍼센트 저렴한 단가, 그리고 프론티어 연구소들끼리 벌어지는 가격 인하가 같은 방향을 가리킵니다.

![안전망을 갖춘 이전이 약 80퍼센트의 비용 절감으로 이어지는 구조를 표현한 슬라이드]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-slide-08.png' | relative_url }})

## ThakiCloud 제품 적용 시사점

이 플레이북은 개념으로는 명료하지만 실제로 굴리려면 두 가지가 필요합니다. 하나는 오픈 모델을 싸게 서빙하는 인프라이고, 다른 하나는 작업마다 모델을 고르고 정책과 감사로 안전을 보장하는 제어 평면입니다. ThakiCloud는 두 제품으로 이 두 축을 함께 제공합니다.

![이전을 굴리는 두 개의 기둥. 저비용 서빙 인프라 ai-platform과 에이전트 네이티브 제어 평면 Paxis]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-slide-09.png' | relative_url }})

### ai-platform: 저비용 서빙 인프라

ai-platform은 쿠버네티스 기반의 AI/ML 서빙 인프라입니다. Kueue로 GPU를 스케줄링하고, vLLM으로 오픈 모델을 서빙하며, 멀티테넌트 격리와 온프레미스 배포를 지원합니다. 이전 플레이북의 네 번째 단계, 즉 선정된 오픈 모델을 자사 인프라에 올려 단위 비용을 낮추는 일이 바로 이 계층에서 일어납니다. 국가 기관이나 규제 산업처럼 데이터를 외부로 내보낼 수 없는 고객에게는 소버린 배포가 결정적입니다. 프론티어 API로는 애초에 만족시킬 수 없는 요구이기 때문입니다.

### Paxis: 이전을 실행하는 Agent-Native Cloud

Paxis는 ai-platform 위에서 도는 에이전트 네이티브 제어 평면입니다. 기존 클라우드가 가상 머신과 데이터베이스를 일급 리소스로 다루듯, Paxis는 스킬과 도구, 정책, 감사 로그를 일급 리소스로 다룹니다. 이전 플레이북의 관점에서 가장 중요한 부분은 모델 라우팅입니다. Paxis는 `models.yaml`을 단일 진실 공급원으로 삼아 Claude, OpenAI, Ollama, Kimi, MiniMax, 그리고 ai-platform의 vLLM 서빙(Metis)을 한곳에서 교차 라우팅합니다. 앞서 정리한 플레이북의 3단계와 5단계가 여기에 그대로 대응합니다. 작업 유형별로 모델을 지정하고, 품질이 흔들리면 그 작업만 프론티어로 되돌리는 판단이 이 계층에서 이뤄집니다.

![Paxis가 models.yaml을 단일 진실 공급원으로 Claude, OpenAI, Ollama, Kimi, MiniMax, Metis를 교차 라우팅하는 제어 평면 슬라이드]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-slide-11.png' | relative_url }})

여기에 더해 Paxis는 960개가 넘는 스킬을 BM25로 선택하는 스킬 하네스, 격리 샌드박스 실행, 위키 기반 지식 엔진, DAG 멀티에이전트 오케스트레이션, OAuth 자동 재연결을 갖춘 MCP 커넥터를 제공합니다. 그리고 모든 에이전트 행동은 정책 게이트와 감사 로그를 통과합니다. 모델을 싸게 바꾸면서도 무엇이 어떤 모델로 처리됐는지 추적할 수 있다는 뜻입니다.

두 제품의 관계는 한 문장으로 요약됩니다. 저비용 서빙(ai-platform)이 에이전트의 경제성(Paxis)을 만듭니다. 오픈 모델을 싸게 올릴 인프라가 없으면 라우팅 규칙은 종이 위 계획에 그치고, 라우팅과 정책이 없으면 싼 서빙은 통제 불가능한 위험이 됩니다. 이전을 사업으로 만들려면 두 축이 동시에 필요합니다. 참고로 Paxis는 아직 PoC 단계이며 인터페이스와 스키마는 빠르게 바뀔 수 있습니다.

## 한계 및 반론

이 이야기를 낙관 일변도로 끝내는 것은 정직하지 않습니다. 반대편의 논거도 분명합니다.

![한계와 반론을 정리한 슬라이드. 품질 격차, 자체 호스팅 비용, 벤치마크 신뢰성, 라우팅 복잡도]({{ '/assets/images/ai-cost-war-migration-frontier-to-open-slide-13.png' | relative_url }})

첫째, 품질 격차는 여전히 존재합니다. 오픈 모델이 좁힌 것은 정형화된 작업과 일부 에이전트 벤치마크에서입니다. 처음 보는 문제의 분해나 긴 맥락의 미묘한 추론에서는 프론티어가 여전히 앞섭니다. 모든 작업을 오픈 모델로 옮기려는 시도는 대량 작업에서 아낀 돈을 어려운 작업의 실패 비용으로 토해내게 만듭니다. 이전의 핵심은 전면 교체가 아니라 정밀한 분류입니다.

둘째, 자체 호스팅은 공짜가 아닙니다. API 호출은 운영 부담을 연구소에 떠넘기지만, 자체 호스팅은 GPU 확보와 서빙 최적화, 장애 대응을 직접 떠안습니다. 초기 자본 지출과 운영 인력을 고려하면 소규모 트래픽에서는 오히려 API가 쌀 수 있습니다. 손익 분기는 트래픽 규모와 활용률에 달려 있습니다.

셋째, 회자되는 벤치마크 숫자를 그대로 믿어서는 안 됩니다. 이번 글을 준비하면서도 특정 벤치마크 표와 일부 수치는 원출처를 확인할 수 없어 본문에서 제외했습니다. 모델 비교는 자사 워크로드로 직접 측정한 결과로만 판단해야 합니다. 남의 벤치마크는 출발점일 뿐입니다.

넷째, 라우팅 자체가 복잡성을 더합니다. 여러 모델을 오가는 시스템은 단일 모델보다 디버깅과 관측이 어렵습니다. 정책 게이트와 감사 로그가 선택이 아니라 필수인 이유입니다.

그럼에도 방향은 분명합니다. 마이크로소프트조차 모든 작업에 프론티어 가격을 내기를 거부하는 지금, 진짜 질문은 "누가 그 가격을 계속 낼 것인가"입니다. 대량 워크로드를 오픈 모델로 정밀하게 옮기고, 그 이전을 안전하게 통제하는 역량은 앞으로 몇 년간 AI 운영의 핵심 경쟁력이 될 것입니다. ThakiCloud는 그 이전을 인프라와 제어 평면 양쪽에서 함께 제공하는 자리에 있습니다.

## 출처

- {% raw %}[Microsoft reportedly ditching OpenAI's, Anthropic's AI models to cut costs (SiliconANGLE)](https://siliconangle.com/2026/07/07/microsoft-reportedly-ditching-openais-anthropics-ai-models-favor-cut-costs/){% endraw %}
- {% raw %}[Chinese AI models gain ground with US companies on cost (CNBC)](https://www.cnbc.com/2026/07/07/chinese-ai-models-costs-us-openai-anthropic.html){% endraw %}
- {% raw %}[Meta plans cloud business to sell AI compute (CNBC)](https://www.cnbc.com/2026/07/01/meta-stock-cloud-ai-compute.html){% endraw %}
- {% raw %}[OpenAI expands GPT-5.6 Sol access and pricing (CNBC)](https://www.cnbc.com/2026/07/08/openai-expanding-gpt-5point6-ai-model-release-ending-government-limits.html){% endraw %}
