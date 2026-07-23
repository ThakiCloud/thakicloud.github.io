---
title: "에이전트 네이티브 클라우드란 무엇인가: Skills와 Policies를 일급 리소스로"
excerpt: "VM 중심 클라우드가 자율 AI 에이전트 운영에 부적합한 이유, 그리고 Skills·Tools·Policies·Audit Logs를 일급 리소스로 다루는 에이전트 네이티브 인프라 설계 원칙을 살펴봅니다."
seo_title: "에이전트 네이티브 클라우드 설계 원칙 - Thaki Cloud"
seo_description: "자율 AI 에이전트 운영을 위한 클라우드 인프라 패러다임 전환. VM이 아닌 Skills·Tools·Policies·Audit를 일급 리소스로 다루는 에이전트 네이티브 아키텍처와 ThakiCloud Paxis 구현을 소개합니다."
date: 2026-06-22
last_modified_at: 2026-06-22
tags:
  - agent-native
  - cloud-infrastructure
  - praxis
  - ai-agents
  - platform
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/dev/agent-native-cloud-praxis/"
reading_time: true
categories:
  - dev
published: false
audiobook: /assets/audio/posts/agent-native-cloud-praxis/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

![에이전트 네이티브 클라우드 Paxis 개요]({{ '/assets/images/agent-native-cloud-praxis-hero.webp' | relative_url }})

## 개요

클라우드 컴퓨팅은 지금까지 한 가지 질문에 집중해 왔습니다. "애플리케이션이 실행될 환경을 어떻게 추상화할 것인가?" 물리 서버에서 가상머신(VM)으로, VM에서 컨테이너로, 컨테이너에서 서버리스로 이어지는 흐름은 그 질문에 대한 답을 점점 더 세밀하게 다듬어 온 과정입니다.

그런데 이제 우리는 다른 종류의 질문과 마주하고 있습니다. "자율적으로 판단하고 행동하는 AI 에이전트를 실행할 환경을 어떻게 추상화할 것인가?" 이 질문은 기존의 클라우드 추상화 체계가 설계 당시 전혀 상정하지 않은 무언가를 요구합니다.

이 글은 그 갭을 들여다보고, 에이전트 시대에 필요한 인프라 추상화의 원칙을 살펴봅니다. 제품 소개가 아니라 패러다임에 관한 이야기입니다.

## 클라우드 추상화의 진화

클라우드 인프라의 역사는 추상화 계층을 쌓아 온 역사입니다.

**1세대: 물리 서버 임대.** 코로케이션 데이터센터가 랙을 빌려 주는 모델입니다. 운영자는 OS 설치부터 네트워크 구성까지 모든 것을 직접 관리해야 했습니다. 변경 비용이 매우 높았고, 수요 변화에 유연하게 대응하기 어려웠습니다.

**2세대: 가상머신(VM).** AWS EC2, GCP Compute Engine이 대표하는 모델입니다. 물리 서버는 논리적 단위로 분할되었고, 운영자는 CPU·메모리·스토리지 같은 컴퓨팅 리소스를 API로 프로비저닝할 수 있게 되었습니다. 추상화 덕분에 인프라 탄력성이 크게 향상되었습니다.

**3세대: 컨테이너와 오케스트레이션.** Docker와 Kubernetes가 정의한 세계입니다. 실행 환경 자체를 이미지로 패키징하고, 선언적 명세로 워크로드를 배치하는 방식이 자리를 잡았습니다. 불변 인프라(immutable infrastructure), GitOps, 서비스 메시 같은 개념들이 이 세대에서 꽃을 피웠습니다.

**4세대(현재 과도기): 서버리스와 함수.** AWS Lambda, Google Cloud Functions로 대표되는 모델입니다. 운영자는 서버 자체를 더 이상 관리하지 않아도 됩니다. 이벤트에 반응하는 함수 단위로 실행 비용만 지불합니다.

이 모든 세대를 관통하는 공통점이 있습니다. 관리 대상이 항상 **실행 환경**이었다는 점입니다. VM이든 컨테이너든 함수든, 클라우드는 "무언가를 실행하는 공간"을 제공하는 데 집중해 왔습니다.

자율 AI 에이전트는 이 프레임을 벗어납니다.

## 에이전트 운영의 4대 난제

자율 AI 에이전트를 프로덕션 환경에 배치해 본 팀이라면 공통으로 마주치는 어려움들이 있습니다.

### 난제 1: 모델 선택과 비용 제어

에이전트는 단일 LLM 호출로 완결되지 않습니다. 복잡한 목표를 해결하기 위해 계획을 세우고(Planning), 도구를 실행하고(Execution), 결과를 종합하는(Synthesis) 여러 단계를 거칩니다.

문제는 각 단계가 요구하는 모델 역량이 다르다는 점입니다. 계획 단계에는 넓은 문맥과 복잡한 추론이 필요하지만, 단순 검색 단계에는 그럴 필요가 없습니다. 그런데 기존 방식에서는 이를 세밀하게 제어하기가 어렵습니다. 개발자가 각 단계마다 직접 모델을 지정하거나, 하나의 강력한(그리고 비싼) 모델로 전부 처리하거나, 둘 중 하나를 선택해야 합니다.

전자는 코드 복잡성을 높이고, 후자는 비용 폭증으로 이어집니다. [추정] 대규모 에이전트 운영 조직에서 모델 비용이 전체 인프라 비용의 60% 이상을 차지하는 경우도 드물지 않습니다.

### 난제 2: 스킬 관리와 중복 증식

에이전트가 활용하는 도구와 능력의 집합을 편의상 "스킬"이라 부르겠습니다. 에이전트 생태계가 성장하면서 스킬은 빠르게 증식합니다. 비슷한 기능을 하는 스킬이 여러 개 생기고, 그 중 일부는 유지보수되지 않습니다. 어떤 스킬이 어떤 상황에 가장 적합한지 판단하기 어려워집니다.

VM 관리에서 AMI 이미지를 체계적으로 관리하지 않으면 이미지 스프롤이 발생하듯, 에이전트 생태계에서는 스킬 스프롤이 발생합니다. 그러나 기존 클라우드 인프라는 이를 다루는 추상화를 제공하지 않습니다.

### 난제 3: 거버넌스와 자율성의 균형

자율 AI 에이전트는 "얼마나 스스로 판단하고 행동할 것인가"라는 근본적인 질문을 마주합니다. 너무 제한하면 에이전트의 가치가 사라지고, 너무 풀어 주면 예기치 않은 행동이 발생합니다.

이를 운영 레이어에서 제어하려면 정책 엔진이 필요합니다. 어떤 도구를 허용하고, 어떤 데이터에 접근할 수 있으며, 어떤 행동은 사람의 승인이 필요한지를 선언적으로 정의하고 집행해야 합니다.

기존 클라우드의 IAM과 보안 그룹은 "누가 어떤 API를 호출할 수 있는가"를 다룹니다. 그러나 에이전트 거버넌스는 "이 에이전트가 이 상황에서 이런 판단을 내릴 수 있는가"라는 맥락 의존적인 질문을 다뤄야 합니다. 이는 질적으로 다른 추상화를 요구합니다.

실무적으로는 이런 상황을 생각해 볼 수 있습니다. 고객 데이터베이스에 접근하는 에이전트가 평소와 다른 시간대에 대량 조회를 시도할 때, 단순히 API 권한이 있다는 이유만으로 허용해야 할까요? 상황에 따른 판단(contextual authorization)은 기존 IAM 모델이 설계 범위 밖에 두었던 영역입니다.

### 난제 4: 지속적 학습과 스킬 진화

에이전트는 정적인 소프트웨어가 아닙니다. 운영하면서 어떤 전략이 효과적이고 어떤 스킬이 자주 실패하는지 데이터가 쌓입니다. 이 데이터를 바탕으로 에이전트와 스킬을 개선하는 피드백 루프가 필요합니다.

배포 파이프라인을 통해 컨테이너 이미지를 갱신하듯, 에이전트의 능력도 체계적으로 갱신되어야 합니다. 그러나 기존 클라우드 인프라는 이런 "능력의 진화"를 일급 시민으로 다루지 않습니다.

이 난제는 특히 엔터프라이즈 환경에서 두드러집니다. 수백 명의 팀원이 사용하는 에이전트 시스템에서 어떤 스킬이 지난 달에 비해 성능이 떨어졌는지, 어떤 시나리오에서 새로운 스킬이 필요한지를 파악하는 것은 엄청난 운영 비용을 필요로 합니다. 이 과정이 자동화되지 않으면, 에이전트 시스템은 초기 배포 이후 점진적으로 품질이 저하되는 경향을 보입니다.

## 일급 리소스로서의 Skills·Tools·Policies·Audit

이 네 가지 난제는 모두 같은 근원을 가리킵니다. 기존 클라우드가 일급 리소스로 취급하는 것들(VM, 컨테이너, 함수, 스토리지, 네트워크)이 에이전트 운영에서 핵심적인 것들이 아니라는 사실입니다.

에이전트 네이티브 클라우드는 다음 네 가지를 일급 리소스로 취급해야 합니다.

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
<div class="d3-arch" data-arch-root id="22agentnativecloudpraxis-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 611, "height": 587, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [{"x": 381, "y": 42, "w": 198, "h": 504, "label": "기존 클라우드 일급 리소스", "lx": 393, "ly": 60}, {"x": 24, "y": 24, "w": 241, "h": 531, "label": "에이전트 네이티브 일급 리소스", "lx": 36, "ly": 42}], "nodes": [{"id": "VM", "x": 420, "y": 128, "w": 120, "h": 46, "title": "VM / 컨테이너"}, {"id": "DB", "x": 420, "y": 245, "w": 120, "h": 46, "title": "데이터베이스"}, {"id": "NET", "x": 420, "y": 346, "w": 120, "h": 46, "title": "네트워크"}, {"id": "STORAGE", "x": 420, "y": 463, "w": 120, "h": 46, "title": "스토리지"}, {"id": "SKILL", "x": 63, "y": 179, "w": 163, "h": 62, "title": ["Skills", "능력 단위, 버전 관리, 자가 진화"]}, {"id": "TOOLS", "x": 74, "y": 338, "w": 142, "h": 62, "title": ["Tools", "도구 레지스트리, 권한 바인딩"]}, {"id": "POLICY", "x": 70, "y": 62, "w": 149, "h": 62, "title": ["Policies", "자율성·위험 행렬, 선언적 집행"]}, {"id": "AUDIT", "x": 85, "y": 455, "w": 120, "h": 62, "title": ["Audit Logs", "해시체인, 불변 이력"]}], "edges": [{"src": "SKILL", "dst": "VM", "kind": "data", "label": "런타임 실행", "curve": [[226, 210], [265, 210], [381, 210], [441, 174]], "off": "50%"}, {"src": "TOOLS", "dst": "NET", "kind": "data", "label": "API 호출", "line": [216, 369, 420, 369], "lx": 323, "ly": 365}, {"src": "POLICY", "dst": "VM", "kind": "data", "label": "집행 레이어", "curve": [[219, 93], [265, 93], [381, 93], [441, 128]], "off": "50%"}, {"src": "AUDIT", "dst": "STORAGE", "kind": "data", "label": "영속화", "line": [205, 486, 420, 486], "lx": 323, "ly": 482}]});
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
      const container = document.getElementById('22agentnativecloudpraxis-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '22agentnativecloudpraxis-1';
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

**Skills는 능력의 단위입니다.** 단순한 프롬프트 묶음이 아니라, 버전을 가지고, 평가 지표를 가지며, 서로 비교하고 통합할 수 있는 관리 가능한 객체여야 합니다. 사용 빈도, 성공률, 비용 효율성 같은 지표를 바탕으로 어떤 스킬을 유지하고 어떤 스킬을 폐기할지 결정할 수 있어야 합니다.

**Tools는 도구 레지스트리입니다.** 에이전트가 호출할 수 있는 외부 인터페이스의 목록이며, 각 도구에는 접근 권한이 바인딩됩니다. 어떤 에이전트가 어떤 도구를 호출할 수 있는지를 중앙에서 관리할 수 있어야 합니다.

**Policies는 거버넌스의 언어입니다.** 에이전트의 자율성 수준과 허용 가능한 위험의 범위를 교차한 행렬로 정책을 표현합니다. 선언적 정책이 런타임에 집행되어야 하며, 사람의 승인이 필요한 경우 워크플로를 자동으로 트리거해야 합니다.

**Audit Logs는 신뢰의 기반입니다.** 에이전트가 내린 판단과 실행한 행동의 이력이 변조 불가능하게 기록되어야 합니다. 이는 규제 준수의 문제이기 이전에, 에이전트 시스템을 신뢰할 수 있게 만드는 설계 원칙입니다.

이 네 가지 리소스가 일급 시민으로 취급된다는 것은 단순히 이들을 저장하고 조회할 수 있다는 의미가 아닙니다. 컴퓨팅 리소스처럼 프로비저닝하고, 버전을 관리하고, 정책으로 접근을 제어하고, 비용을 추적하고, 장애 시 롤백할 수 있는 라이프사이클 관리가 가능해야 합니다. 쿠버네티스가 컨테이너를 "Deployment"와 "ReplicaSet"이라는 추상화로 다루듯, 에이전트 네이티브 플랫폼은 스킬을 "SkillRelease"와 "SkillPolicy"라는 추상화로 다루어야 합니다.

## ThakiCloud의 구현: Paxis와 AI Platform 연계

ThakiCloud는 이 설계 원칙을 구체화한 플랫폼으로 **Paxis**를 개발하고 있습니다. "AWS for Agents"라는 콘셉트 아래, 기존 클라우드가 VM·DB·Network를 다루듯 Skills·Tools·Policies·Audit Logs를 일급 리소스로 다루는 것을 목표로 합니다.

**LLM·스킬 라우터**는 에이전트 실행의 각 단계(계획·실행·종합)에 맞는 모델을 자동으로 선택합니다. Claude, GPT, Gemini, Kimi, Ollama와 ThakiCloud의 자체 모델인 Metis를 포함한 10개 이상의 제공사를 지원하며, 비용을 인식하는 라우팅을 통해 불필요한 고비용 모델 호출을 줄입니다. 스킬 선택은 2단계로 이루어집니다. 먼저 도메인 후보군을 좁힌 뒤, 적합성·비용·신뢰도 등 7개 요소를 기준으로 최적 스킬을 선택합니다.

**Curator 자가진화 데몬**은 스킬 생태계를 지속적으로 관리합니다. 유사한 스킬을 감지해 통합하고, 성능이 저하된 스킬을 자동으로 패치하며, 운영 데이터를 바탕으로 새로운 스킬을 발굴합니다. 메모리 증류를 통해 반복 실행에서 얻은 통찰을 지식 베이스로 축적합니다.

**보안·거버넌스 계층**은 자율성 4단계와 위험 수준 7단계를 교차한 정책 행렬을 제공합니다. 입력 11종·출력 2종에 대한 프롬프트 보호와 개인정보 16종 마스킹이 적용됩니다. Docker와 Kata 컨테이너 기반의 샌드박스 실행 환경이 에이전트를 격리하며, 20개 이상의 이벤트 유형에 걸친 해시체인 감사 로그가 90일간 보존됩니다.

**멀티채널 인바운드 레이어**는 Web React SPA, Slack(48개 커맨드 지원), CLI를 통해 에이전트와 상호작용할 수 있게 합니다. 자연어로 커스텀 작업을 정의하는 동적 스케줄러도 포함됩니다. "매일 아침 경쟁사 뉴스를 수집해서 요약해 줘"와 같은 지시를 에이전트가 직접 자신의 스케줄로 등록합니다.

**하이브리드 지식엔진(HKE)**은 팀별 위키 기반 RAG와 지식 그래프를 결합합니다. 각 에이전트는 자신의 도메인에 특화된 지식 베이스를 참조하고, 실행 경험을 통해 이를 지속적으로 보강합니다.

Paxis는 **AI Platform(ai-suite)**과 연계하여 동작합니다. AI Platform이 중앙 LLM 정책·비용 통제를 담당하고, Paxis가 에이전트 런타임을 제공하며, Metis가 추론 레이어를 맡는 3층 구조입니다. 각 계층이 명확한 책임을 가지고 결합하는 방식은, 기존 클라우드에서 컨트롤 플레인과 데이터 플레인이 분리되는 방식과 유사합니다.

스택은 Go 1.26(백엔드)과 React 19(프론트엔드)로 구성되며, 프로덕션 환경에서는 PostgreSQL·Redis·MinIO를 스토리지 레이어로 사용합니다.

## 한계 및 전망

에이전트 네이티브 클라우드라는 개념 자체는 아직 성숙하지 않았습니다. 몇 가지 근본적인 어려움을 솔직하게 살펴볼 필요가 있습니다.

**스킬 품질의 측정 문제.** 컨테이너 이미지의 신뢰도는 취약점 스캔, 서명 검증 등 비교적 확립된 방법으로 평가할 수 있습니다. 반면 스킬의 품질은 실행 컨텍스트에 깊이 의존합니다. "이 스킬이 이 상황에 적합한가"는 사전에 자동화된 방법으로 완전히 평가하기 어렵습니다. 현재의 평가 지표(성공률, 비용 효율성)는 대리 지표일 뿐, 진정한 효과성을 측정하지는 못합니다.

**정책의 완전성 환상.** 선언적 정책은 명시된 상황에 대해 집행되지만, 에이전트가 마주치는 상황의 다양성은 정책 설계자의 상상을 초과합니다. 정책이 "거버넌스를 해결했다"는 착각을 주지 않도록 주의가 필요합니다. 정책은 안전망이지 보증이 아닙니다.

**다중 에이전트 조율의 복잡성.** 단일 에이전트를 다루는 것과 여러 에이전트가 협력하는 시스템을 다루는 것은 질적으로 다른 문제입니다. 에이전트 간의 신뢰 모델, 충돌 해소 메커니즘, 책임 귀속 같은 문제들은 아직 인프라 레이어에서 충분히 해결되지 않았습니다.

**산업 표준의 부재.** VM의 경우 OVF/OCI 같은 이미지 표준, 클라우드 제공사 간 호환되는 API 패턴이 존재합니다. 에이전트 스킬과 정책을 기술하는 표준은 아직 형성 중입니다. MCP(Model Context Protocol)처럼 도구 인터페이스 표준화를 시도하는 움직임이 있지만, 더 넓은 생태계 합의까지는 시간이 필요합니다.

그럼에도 방향은 분명합니다. 에이전트가 소프트웨어 시스템의 일부로 자리를 잡아 가면서, 이를 운영하는 인프라의 추상화 수준도 올라가야 합니다. 물리 서버를 직접 관리하던 시대에서 VM API를 호출하는 시대로 넘어갔듯, "에이전트의 능력과 행동 범위를 API로 정의하고 플랫폼이 이를 집행하는" 시대가 가까워지고 있습니다.

Q4 2026에는 스킬 마켓플레이스를, Q2 2027 이후에는 SOC2 인증과 에어갭 배포를 [추정] 로드맵에 포함하고 있는 Paxis의 여정도 그 흐름의 일부입니다. 플랫폼이 성숙할수록 개발자는 에이전트의 능력 설계에 집중하고, 실행 안전성과 비용 최적화는 인프라가 담당하는 분업이 가능해질 것입니다.

에이전트 네이티브 클라우드는 아직 완성된 개념이 아닙니다. 그러나 다음 세대의 소프트웨어 운영이 어떤 문제를 인프라 레이어에서 해결해야 하는지는, 지금 이 시점에 설계 원칙으로 자리를 잡아 가고 있습니다.

## 관련 슬라이드

본문 내용을 NotebookLM(`tech_pitch` 스타일)으로 요약한 슬라이드입니다.

![agent-native-cloud-praxis 슬라이드 1](/assets/images/agent-native-cloud-praxis-slide-01.png)

![agent-native-cloud-praxis 슬라이드 2](/assets/images/agent-native-cloud-praxis-slide-02.png)

![agent-native-cloud-praxis 슬라이드 3](/assets/images/agent-native-cloud-praxis-slide-03.png)

![agent-native-cloud-praxis 슬라이드 4](/assets/images/agent-native-cloud-praxis-slide-04.png)

