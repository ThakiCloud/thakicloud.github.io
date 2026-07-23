---
title: "파인튜닝은 정말 죽었을까: 2026년 6월 한 달의 검증된 신호로 읽는 생존 전략"
excerpt: "거대 LLM과 에이전트 스킬이 좋아질수록 파인튜닝은 필요 없어진다는 체감이 업계에 퍼지고 있습니다. 실제로 OpenAI는 셀프서브 파인튜닝 API를 접는 중입니다. 그런데 같은 한 달 동안 정반대 방향의 신호도 쏟아졌습니다. 19일간의 프론티어 모델 셧다운, 파인튜닝을 전제로 설계된 오픈웨이트 라이선스, 프론티어보다 11배 싼 파인튜닝 워커의 실전 승리까지. 2026년 6월 5일부터 7월 5일까지 발행된 소스만으로, 무엇이 죽고 무엇이 사는지 교차 검증해 정리했습니다."
seo_title: "2026 파인튜닝 생존 전략: LLM 스킬 시대의 도메인 특화 모델 - Thaki Cloud"
seo_description: "OpenAI 파인튜닝 API 폐쇄, Anthropic 수출통제 셧다운, NVIDIA Nemotron 3, Harvey 하이브리드 사례까지 2026년 6월 검증 데이터로 분석한 파인튜닝과 소형 모델의 생존 조건, 그리고 소버린 AI 시대의 모델 소유권 전략을 정리했습니다."
date: 2026-07-05
last_modified_at: 2026-07-05
tags:
  - fine-tuning
  - slm
  - sovereign-ai
  - grpo
  - distillation
  - agent-skills
  - llmops
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "flask"
canonical_url: "https://thakicloud.com/tech-blog/ko/research/finetuning-survival-strategy-2026/"
categories:
  - research
  - llmops
header:
  teaser: /assets/images/finetuning-survival-strategy-2026-hero.webp
  overlay_image: /assets/images/finetuning-survival-strategy-2026-hero.webp
  overlay_filter: 0.5
published: false
---

![파인튜닝 생존 전략 히어로 이미지]({{ '/assets/images/finetuning-survival-strategy-2026-hero.webp' | relative_url }})

## 들어가며: "이제 파인튜닝 안 해도 되는 것 아닌가요"

요즘 AI 플랫폼을 만들거나 파는 사람이라면 한 번쯤 이런 질문을 받았을 것입니다. 프론티어 모델이 이렇게 좋아졌고, 스킬과 에이전트 스캐폴딩으로 도메인 지식을 주입할 수 있는데, 굳이 돈과 시간을 들여 모델을 따로 학습할 이유가 있느냐는 질문입니다. 저희도 같은 질문을 스스로에게 던졌습니다. 그래서 2026년 6월 5일부터 7월 5일까지, 딱 한 달 동안 발행된 소스만으로 이 질문을 검증해 봤습니다.

방법은 단순합니다. 파인튜닝 무용론의 근거, 생존론의 근거, 시장과 벤더의 움직임, 실무자 담론이라는 네 갈래로 나눠 조사한 뒤, 방향 결정에 하중이 실리는 핵심 주장 여섯 건을 별도의 반증 검증으로 다시 확인했습니다. 여섯 건 중 네 건이 확정, 두 건이 부분 확정이었고 반증된 것은 없었습니다. 이 글은 그 검증을 통과한 사실만으로 씁니다.

결론부터 말하면 이렇습니다. 파인튜닝이라는 상품은 죽어가는 것이 맞습니다. 그런데 죽는 것은 셀프서브 SFT API라는 특정 세그먼트이고, 같은 기술이 모델 소유권과 에이전트 워커 경제학이라는 다른 상품으로 재편되며 오히려 프리미엄화되고 있습니다.

## 무엇이 실제로 죽고 있는가

가장 상징적인 사건은 OpenAI의 결정입니다. OpenAI는 2026년 5월 7일 신규 조직의 파인튜닝 작업 생성을 차단한다고 공지했고, 7월 2일부터는 60일 이상 비활성 조직의 접근을 막는 단계로 넘어갔으며, 2027년 1월 6일에는 기존 활성 고객까지 포함해 신규 파인튜닝 작업 생성을 완전히 종료할 예정입니다. 이미 만들어진 파인튜닝 모델의 추론은 베이스 모델이 폐기되기 전까지 유지되지만, 새로 학습을 돌리는 길은 닫힙니다.

주목할 부분은 예외 조항입니다. 강화학습 기반 파인튜닝인 RFT는 이번 폐쇄에서 별도 트랙으로 분리되어 유지됩니다. 지도학습 파인튜닝은 접으면서 검증 가능한 보상이 있는 고가치 커스터마이징은 남긴 셈입니다. Anthropic은 애초에 공개 API에서 셀프서브 파인튜닝을 열지 않았고, 폴더 구조로 도메인 지식을 동적으로 로드하는 Agent Skills를 표준 경로로 밀고 있습니다. 두 최상위 모델 벤더가 같은 방향을 가리키고 있는 것입니다.

가격 신호도 같은 이야기를 합니다. Together AI와 Fireworks AI의 LoRA 파인튜닝 가격 경쟁은 이 구간이 이미 커머디티가 되어 마진이 얇아졌다는 뜻입니다. 셀프서브로 가볍게 돌리는 지도학습 파인튜닝은 기술적으로 어렵지 않게 되었고, 그래서 사업으로서의 매력을 잃었습니다.

## 그런데 스킬이 만능이라는 근거도 없습니다

체감과 달리, 스킬이 파인튜닝을 보편적으로 대체한다는 학술 근거는 아직 약합니다. 이번 윈도우 안에 제출된 SkillJuror 연구는 스킬을 구조화해 제공하는 방식이 플랫 방식 대비 검증 통과율을 4.1%포인트 올린다는 것을 보였습니다. 효과는 실재하지만 크지 않습니다. 조금 앞선 배경 연구인 SkillsBench는 더 흥미로운 결과를 담고 있습니다. 잘 큐레이션된 스킬은 평균 통과율을 16.2%포인트 올리지만 도메인별 편차가 마이너스부터 플러스 51.9%포인트까지 극단적으로 갈리고, 84개 태스크 중 16개에서는 오히려 성능이 떨어졌습니다. 결정적으로 모델이 스스로 작성한 스킬은 평균적으로 효과가 없었습니다.

즉 "스킬이면 다 된다"는 명제는 사람이 정성껏 큐레이션한 스킬을 맞는 도메인에 적용했을 때만 성립하는 조건부 명제입니다. 스킬 큐레이션 비용은 공짜가 아니며, 그 비용이 파인튜닝 대비 항상 싸다는 보장도 없습니다. 참고로 동일 태스크셋에서 파인튜닝 모델과 스킬을 얹은 프론티어 모델을 나란히 비교한 벤치마크는 이번 윈도우 안에서 찾지 못했습니다. 이 공백은 양쪽 진영 모두에게 남아 있는 숙제입니다.

## 6월 한 달, 정반대 방향의 신호들

같은 한 달 동안 파인튜닝과 모델 소유권 쪽으로도 강한 신호가 쏟아졌습니다. 전부 독립 소스로 교차 확인된 사건들입니다.

첫째, 프론티어 API 의존의 지정학 리스크가 실측 사건이 되었습니다. 2026년 6월 12일 미국 정부의 수출통제 지시로 Anthropic은 Fable 5와 Mythos 5 모델을 전 세계 대상으로 비활성화했습니다. 실시간 국적 필터링이 불가능해 해외 고객만이 아니라 사실상 모든 사용자가 영향을 받았고, 해제까지 19일이 걸렸습니다. 프론티어 API 하나에 핵심 업무를 올려둔 기업이라면 6월에 19일짜리 교훈을 얻은 셈입니다.

둘째, 오픈웨이트 생태계는 파인튜닝을 전제로 설계되고 있습니다. 6월 4일 발표된 NVIDIA Nemotron 3 Ultra는 총 550B에 활성 55B인 MoE 구조로, LoRA SFT와 풀 SFT, GRPO 강화학습 레시피를 기본 제공합니다. 라이선스인 OpenMDW-1.1은 파인튜닝 파생 모델의 상업화와 재배포를 명시적으로 허용합니다. 우리 데이터로 튜닝한 모델을 소유하고 판매하라는 것이 라이선스 설계의 목표입니다. 6월 29일에는 Palantir와 NVIDIA가 에어갭 환경 안에서 오픈웨이트를 파인튜닝해 운영하는 소버린 AI 결합 상품을 내놨습니다. EU에서는 공공 워크로드에 주권 보증 등급을 매기는 법안이 발의되었고, 국내에서도 소버린 AI 사업이 진행형입니다.

셋째, 파인튜닝 워커의 실전 승리 사례가 나왔습니다. 법률 AI 기업 Harvey와 Fireworks가 공개한 벤치마크에서, SFT만 적용한 Kimi K2.6 단독 모델이 100개 태스크 기준 전체 통과율 15%로 Claude Opus 4.7 단독의 14%를 넘었고 비용은 약 11.4배 저렴했습니다. 파인튜닝 워커에 프론티어 모델을 선택적으로 호출하는 하이브리드 구성은 18%로 가장 높았습니다. 벤더 자체 벤치마크라는 한계는 있지만, 좁은 도메인에서 파인튜닝 워커와 프론티어 에스컬레이션을 조합하면 품질과 비용을 동시에 잡을 수 있다는 실전 근거입니다.

넷째, 작은 모델의 도메인 우위는 여전히 재현됩니다. 6월 11일 공개된 논문에서 Mistral-7B를 QLoRA로 파인튜닝한 모델이 바이오메디컬 클레임 검증에서 GPT-4o와 GPT-5 대비 F1 기준 최대 12%포인트 우위를 보였습니다. 학습 샘플은 단 1,008개였습니다.

## 시장은 세 갈래로 재편되고 있습니다

이 신호들을 겹쳐 보면 시장은 죽느냐 사느냐의 이분법이 아니라 세 갈래로 갈라지고 있습니다.

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
<div class="d3-arch" data-arch-root id="ningsurvivalstrategy2026-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 588, "height": 554, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 256, "y": 24, "w": 120, "h": 62, "title": ["파인튜닝 시장", "2026년 재편"]}, {"id": "B", "x": 435, "y": 164, "w": 120, "h": 62, "title": ["갈래 1", "셀프서브 SFT API"]}, {"id": "C", "x": 252, "y": 164, "w": 128, "h": 62, "title": ["갈래 2", "소유형 소버린 커스텀 모델"]}, {"id": "D", "x": 45, "y": 164, "w": 135, "h": 62, "title": ["갈래 3", "RL 파인튜닝과 워커 경제학"]}, {"id": "B1", "x": 435, "y": 312, "w": 121, "h": 78, "title": ["축소 국면", "OpenAI 단계적 폐쇄", "LoRA 가격 커머디티화"]}, {"id": "C1", "x": 256, "y": 304, "w": 120, "h": 94, "title": ["프리미엄화", "에어갭 파인튜닝 상품", "주권 등급제 법안", "파인튜닝 전제 라이선스"]}, {"id": "D1", "x": 24, "y": 312, "w": 177, "h": 78, "title": ["신규 성장", "RFT는 별도 트랙 유지", "파인튜닝 워커 + 프론티어 에스컬레이션"]}, {"id": "E", "x": 154, "y": 476, "w": 120, "h": 46, "title": "모델 소유권이 상품"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "curve": [[376, 78], [495, 125], [495, 125], [495, 164]]}, {"src": "A", "dst": "C", "kind": "data", "line": [316, 86, 316, 164]}, {"src": "A", "dst": "D", "kind": "data", "curve": [[256, 76], [113, 125], [113, 125], [113, 164]]}, {"src": "B", "dst": "B1", "kind": "data", "line": [495, 226, 495, 312]}, {"src": "C", "dst": "C1", "kind": "data", "line": [316, 226, 316, 304]}, {"src": "D", "dst": "D1", "kind": "data", "line": [113, 226, 113, 312]}, {"src": "C1", "dst": "E", "kind": "data", "curve": [[316, 398], [316, 437], [316, 437], [252, 476]]}, {"src": "D1", "dst": "E", "kind": "data", "curve": [[113, 390], [113, 437], [113, 437], [177, 476]]}]});
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
      const container = document.getElementById('ningsurvivalstrategy2026-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ningsurvivalstrategy2026-1';
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

갈래 1인 셀프서브 SFT API는 축소 국면입니다. 프론티어 모델의 긴 컨텍스트와 네이티브 툴콜, 구조화 출력이 과거 파인튜닝의 존재 이유였던 포맷 준수와 도메인 어휘 문제를 상당 부분 흡수했습니다. 갈래 2인 소유형 커스텀 모델은 프리미엄 서비스로 재편되고 있습니다. API로 가볍게 튜닝하는 시대는 끝나지만, 기업이 모델을 소유하고 통제하는 무거운 커스터마이징은 오히려 몸값이 오르고 있습니다. 갈래 3은 에이전트 시대가 만드는 신규 수요입니다. 오케스트레이터가 좋아질수록 반복 서브태스크를 담당할 저비용 워커의 호출량이 늘고, 그 슬롯마다 프론티어를 부르면 비용이 감당되지 않습니다.

## 파인튜닝이 확실히 이기는 다섯 가지 조건

검증된 사례들을 패턴으로 정리하면, 다음 조건이 겹칠수록 파인튜닝의 승산과 투자 대비 효과가 함께 올라갑니다.

1. 좁고 반복적인 태스크에 출력 포맷이 고정되어 있을 때. 분류, 검증, 구조화 추출이 대표적이며 1,008개 샘플로 12%포인트 우위를 만든 사례가 이 유형입니다.
2. 검증 가능한 보상이 존재할 때. GRPO나 RFT를 적용할 수 있는 환경 피드백이 있다면 지도학습보다 유리하며, OpenAI가 SFT를 접으면서 RFT만 남긴 이유이기도 합니다.
3. 호출 빈도가 높고 비용과 지연이 지배적인 제약일 때. 에이전트 워커 슬롯이 여기 해당하고, 11.4배 비용 차이는 규모가 커질수록 결정적입니다.
4. 데이터 주권, 규제, 폐쇄망 요구가 있을 때. 공공, 금융, 방산 영역은 애초에 외부 API 선택지가 제한됩니다.
5. 프론티어 API 자체가 공급 리스크일 때. 19일 셧다운 사건이 보여줬듯 수출통제와 정책 변경은 더 이상 가상의 시나리오가 아닙니다.

반대로 오픈도메인 추론, 최신 지식, 롱테일 처리에서 파인튜닝 모델이 프론티어를 이겼다는 근거는 이번 윈도우에서 찾지 못했습니다. 그 영역은 스킬과 프론티어 모델에 양보하는 것이 정직한 판단입니다.

## ThakiCloud 제품 관점에서의 시사점

이 재편 구도는 저희가 만드는 두 제품의 방향과 정확히 맞물립니다.

ai-platform 관점에서 보면, 갈래 2와 3이 요구하는 것은 결국 고객 폐쇄망 안에서 도는 학습과 서빙 인프라입니다. ThakiCloud의 ai-platform은 Kubernetes와 Kueue 기반 GPU 스케줄링 위에서 SFT, CPT, DPO, GRPO, GKD 다섯 종의 학습 파이프라인을 운용합니다. 이번 리서치에서 시장이 프리미엄을 인정하기 시작한 두 축이 검증 가능한 보상 기반의 GRPO와, 프론티어 출력을 소형 모델로 옮기는 증류라는 점은 저희에게 중요한 확인이었습니다. 온프레미스와 소버린 요구가 커질수록 파인튜닝은 API 기능이 아니라 인프라 역량의 문제가 되고, 그 지점이 저희가 서 있는 자리입니다.

Paxis 관점에서는 이번 결론이 스킬과 파인튜닝의 역할 분담을 명확하게 해 줍니다. Paxis는 ThakiCloud의 Agent-Native Cloud 제어 평면으로, 960개 이상의 스킬을 BM25로 선택해 격리 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시킵니다. 스킬 벤치마크가 보여준 교훈, 즉 스킬은 잘 큐레이션될 때만 효과가 있고 자가 생성 스킬은 신뢰할 수 없다는 결론은 Paxis가 스킬 큐레이션과 검증 루프에 투자해 온 방향이 맞았다는 근거이기도 합니다. 동시에 에이전트 플릿의 반복 서브태스크에는 파인튜닝 워커가 경제적이라는 Harvey 사례의 패턴은, 스킬 기반 오케스트레이션과 파인튜닝 워커가 경쟁 관계가 아니라 한 아키텍처의 두 층이라는 것을 보여줍니다. 프론티어를 버리는 것이 아니라 아껴 쓰는 설계입니다.

## 한계 및 반론

이 분석이 틀릴 수 있는 시나리오도 세워 두어야 합니다. 가장 강한 반론은 텍스트 공간 최적화의 발전 속도입니다. 배경 연구로 분류했지만, Microsoft Research의 SkillOpt는 모델 가중치를 건드리지 않고 스킬 문서를 롤아웃 기반으로 최적화하는 것만으로 19에서 25%포인트의 성능 향상을 얻었습니다. 이 계열이 성숙하면 좁은 태스크의 정확도 우위라는 파인튜닝의 마지막 영토마저 잠식될 수 있습니다. 그 경우에도 살아남는 것은 학습 기능이 아니라 고객 소유 모델을 폐쇄망에서 서빙하고 운영하는 인프라 계약입니다. 실제로 이번 윈도우의 시장 신호에서도 부가가치가 학습보다 서빙 레이어로 이동하는 흐름이 관찰되었습니다.

또 하나의 한계는 데이터 자체에 있습니다. Harvey 벤치마크는 벤더 자체 발표이고, 파인튜닝 수요의 감소나 증가를 직접 보여주는 정량 시장 데이터는 이번 윈도우에서 확보하지 못했습니다. OpenAI의 폐쇄는 공급 측 결정이지 수요 감소의 직접 증거가 아니라는 점도 구분해서 읽어야 합니다.

## 맺으며

"파인튜닝이 필요 없어졌다"는 체감은 절반만 맞습니다. 커머디티 SFT는 실제로 저물고 있지만, 2026년 6월 한 달의 검증된 사건들은 모델 소유권과 워커 경제학이라는 두 방향으로 파인튜닝이 재편되고 있음을 보여줍니다. 질문을 바꿔야 할 때입니다. "파인튜닝을 할 것인가"가 아니라 "어떤 조건에서 모델을 소유할 것인가"가 2026년 하반기의 올바른 질문이라고 생각합니다.

## 참고 자료

- [NVIDIA Debuts Nemotron 3 Family of Open Models (NVIDIA Newsroom, 2026-06-04)](https://nvidianews.nvidia.com/news/nvidia-debuts-nemotron-3-family-of-open-models)
- [Nemotron 3 Ultra 기술 보고서 (arXiv:2606.15007)](https://arxiv.org/pdf/2606.15007)
- [Small LLMs for Biomedical Claim Verification (arXiv:2606.12854, 2026-06-11)](https://arxiv.org/abs/2606.12854)
- [US orders Anthropic to disable AI models for all foreign nationals (Al Jazeera, 2026-06-13)](https://www.aljazeera.com/news/2026/6/13/us-orders-anthropic-to-disable-ai-models-for-all-foreign-nationals)
- [Anthropic says Trump admin has lifted export controls (CNBC, 2026-06-30)](https://www.cnbc.com/2026/06/30/anthropic-says-trump-admin-has-lifted-export-controls-on-claude-fable-5-and-mythos-5.html)
- [SAGE-OPD: 선택적 on-policy 증류 (arXiv:2606.19659, 2026-06-17)](https://arxiv.org/abs/2606.19659v1)
- [SkillJuror (arXiv:2606.11543, 2026-06)](https://arxiv.org/abs/2606.11543)
- [How Harvey & Fireworks Beat Closed Source on Cost + Quality (Fireworks AI Blog)](https://fireworks.ai/blog/open-source-agents-frontier-advisors)
- [OpenAI is winding down the fine-tuning API (OpenAI Developer Community)](https://community.openai.com/t/openai-is-winding-down-the-fine-tuning-api-and-platform-discussion-thread/1380522)
- [Linux Foundation Releases OpenMDW-1.1 (Linux Foundation, 2026-05-28)](https://www.linuxfoundation.org/press/linux-foundation-releases-openmdw-1.1-nvidia-adopts-openmdw-for-cosmos-isaac-gr00t-ising-and-nemotron-ai-model-families)
- [SkillsBench (arXiv:2602.12670, 배경)](https://arxiv.org/abs/2602.12670)
- [SkillOpt: Agent skills as trainable parameters (Microsoft Research, 배경)](https://www.microsoft.com/en-us/research/blog/skillopt-agent-skills-as-trainable-parameters/)
