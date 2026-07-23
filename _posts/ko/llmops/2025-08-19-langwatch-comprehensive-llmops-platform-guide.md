---
title: "LangWatch: 오픈소스 LLMOps 플랫폼으로 AI 운영 체계 구축하기"
excerpt: "LangWatch로 LLM 추적, 평가, 데이터셋 관리부터 프롬프트 최적화까지 - RunPod, vLLM과 연계한 종합 LLMOps 가이드"
seo_title: "LangWatch LLMOps 플랫폼 완벽 가이드 - AI 운영 체계 구축 - Thaki Cloud"
seo_description: "오픈소스 LangWatch로 LLM 관찰성, 평가, 데이터셋 관리, 프롬프트 최적화를 구현하고 RunPod, vLLM과 연계하여 종합적인 LLMOps 환경을 구축하는 방법"
date: 2025-08-19
last_modified_at: 2025-08-19
tags:
  - LangWatch
  - LLMOps
  - OpenTelemetry
  - LLM모니터링
  - AI플랫폼
  - RunPod
  - vLLM
  - 프롬프트최적화
  - 관찰성
  - 평가시스템
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/langwatch-comprehensive-llmops-platform-guide/"
reading_time: true
published: false
categories:
  - llmops
  - tutorials
---

⏱️ **예상 읽기 시간**: 12분

## 서론

LLM(Large Language Model) 기반 애플리케이션이 프로덕션 환경에서 안정적으로 운영되려면 체계적인 관찰성(Observability), 평가(Evaluation), 최적화 시스템이 필수입니다. [LangWatch](https://github.com/langwatch/langwatch)는 이러한 LLMOps 요구사항을 충족하는 오픈소스 플랫폼으로, OpenTelemetry 표준을 기반으로 LLM 애플리케이션의 전체 라이프사이클을 관리할 수 있게 해줍니다.

### LangWatch의 핵심 가치

**기존 모니터링 도구의 한계**:
- 일반적인 APM 도구들은 LLM 특화 메트릭 부족
- 프롬프트 품질과 응답 정확도 추적 어려움
- 비용 최적화와 성능 분석의 복잡성

**LangWatch가 제공하는 해결책**:
- LLM 전용 관찰성과 추적 시스템
- 실시간/오프라인 평가 프레임워크
- 프롬프트 버전 관리와 최적화 도구
- 다양한 LLM 프레임워크와의 네이티브 통합

## LangWatch 핵심 기능 분석

### 1. 관찰성 (Observability)

LangWatch는 OpenTelemetry 표준을 기반으로 LLM 애플리케이션의 모든 상호작용을 추적합니다.

**주요 추적 요소**:
- **Request/Response 추적**: 입력 프롬프트와 모델 응답의 전체 플로우
- **지연시간 분석**: 토큰 생성 속도, 첫 토큰까지의 시간 (TTFT)
- **비용 추적**: API 호출별 토큰 사용량과 비용 계산
- **오류 모니터링**: 실패한 요청과 예외 상황 분석

```python
import langwatch
from openai import OpenAI

client = OpenAI()

@langwatch.trace()
def chat_completion(messages):
    """LangWatch로 추적되는 OpenAI API 호출"""
    langwatch.get_current_trace().autotrack_openai_calls(client)
    
    response = client.chat.completions.create(
        model="gpt-4",
        messages=messages,
        temperature=0.7
    )
    
    return response.choices[0].message.content
```

### 2. 평가 시스템 (Evaluation)

**실시간 평가**:
- 프로덕션 환경에서 응답 품질 실시간 모니터링
- 사용자 피드백과 자동 평가 메트릭 결합
- 성능 저하 조기 감지 시스템

**오프라인 평가**:
- 데이터셋 기반 일괄 평가
- A/B 테스트를 통한 모델 성능 비교
- 프롬프트 변경사항의 영향도 분석

**평가 메트릭**:
- **관련성(Relevance)**: 질문과 답변의 연관성
- **정확성(Accuracy)**: 팩트 체크와 정보 정확도
- **일관성(Consistency)**: 동일 질문에 대한 응답 일관성
- **안전성(Safety)**: 유해 콘텐츠 감지와 필터링

### 3. 데이터셋 관리

**자동 데이터셋 생성**:
- 추적된 메시지로부터 자동 데이터셋 구성
- 사용자 상호작용 패턴 분석
- 실제 사용 사례 기반 테스트 케이스 추출

**수동 데이터셋 업로드**:
- 커스텀 평가용 데이터셋 업로드
- 도메인 특화 테스트 케이스 관리
- 지속적인 평가를 위한 골든 데이터셋 구축

### 4. 프롬프트 최적화

**버전 관리**:
- 프롬프트 변경사항 추적
- 성능 영향도 분석
- 롤백 및 A/B 테스트 지원

**자동 최적화**:
- DSPy의 MIPROv2 알고리즘 활용
- Few-shot 예제 자동 생성
- 프롬프트 템플릿 최적화

```python
# 프롬프트 버전 관리 예시
from langwatch import prompt_manager

# 프롬프트 버전 등록
prompt_v1 = prompt_manager.create_prompt(
    name="customer_support",
    version="1.0",
    template="당신은 고객 지원 담당자입니다. 질문: {question}",
    parameters=["question"]
)

# 성능 평가와 함께 새 버전 테스트
prompt_v2 = prompt_manager.test_prompt(
    base_prompt=prompt_v1,
    modifications={"add_examples": True, "tone": "friendly"},
    evaluation_dataset="customer_queries_100"
)
```

## AI 플랫폼과의 연계 활용

### RunPod과의 통합

RunPod은 GPU 클라우드 인프라를 제공하는 플랫폼으로, LangWatch와 함께 사용하면 강력한 LLMOps 환경을 구축할 수 있습니다.

**통합 아키텍처**:

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
<div class="d3-arch" data-arch-root id="nsivellmopsplatformguide-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 884, "height": 598, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 462, "y": 24, "w": 120, "h": 46, "title": "클라이언트 애플리케이션"}, {"id": "B", "x": 461, "y": 148, "w": 121, "h": 46, "title": "LangWatch SDK"}, {"id": "C", "x": 717, "y": 272, "w": 135, "h": 46, "title": "RunPod GPU 인스턴스"}, {"id": "D", "x": 724, "y": 396, "w": 120, "h": 46, "title": "vLLM 추론 서버"}, {"id": "E", "x": 724, "y": 520, "w": 120, "h": 46, "title": "LLM 모델"}, {"id": "F", "x": 286, "y": 272, "w": 121, "h": 46, "title": "LangWatch 플랫폼"}, {"id": "G", "x": 549, "y": 396, "w": 120, "h": 46, "title": "관찰성 대시보드"}, {"id": "H", "x": 374, "y": 396, "w": 120, "h": 46, "title": "평가 시스템"}, {"id": "I", "x": 199, "y": 396, "w": 120, "h": 46, "title": "데이터셋 관리"}, {"id": "J", "x": 24, "y": 396, "w": 120, "h": 46, "title": "프롬프트 최적화"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [522, 70, 522, 148]}, {"src": "B", "dst": "C", "kind": "data", "curve": [[582, 185], [784, 233], [784, 233], [784, 272]]}, {"src": "C", "dst": "D", "kind": "data", "line": [784, 318, 784, 396]}, {"src": "D", "dst": "E", "kind": "data", "line": [784, 442, 784, 520]}, {"src": "B", "dst": "F", "kind": "data", "curve": [[461, 192], [347, 233], [347, 233], [347, 272]]}, {"src": "F", "dst": "G", "kind": "data", "curve": [[407, 309], [609, 357], [609, 357], [609, 396]]}, {"src": "F", "dst": "H", "kind": "data", "curve": [[379, 318], [434, 357], [434, 357], [434, 396]]}, {"src": "F", "dst": "I", "kind": "data", "curve": [[314, 318], [259, 357], [259, 357], [259, 396]]}, {"src": "F", "dst": "J", "kind": "data", "curve": [[286, 309], [84, 357], [84, 357], [84, 396]]}]});
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
      const container = document.getElementById('nsivellmopsplatformguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'nsivellmopsplatformguide-1';
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

**RunPod + LangWatch 설정**:

```python
# RunPod에서 vLLM 서버 실행
import requests
import langwatch

# RunPod 엔드포인트 설정
RUNPOD_ENDPOINT = "https://api.runpod.ai/v2/your-endpoint-id"
RUNPOD_API_KEY = "your-runpod-api-key"

@langwatch.trace()
def call_runpod_llm(prompt, model="meta-llama/Llama-2-7b-chat-hf"):
    """RunPod에서 호스팅되는 LLM 호출"""
    
    headers = {
        "Authorization": f"Bearer {RUNPOD_API_KEY}",
        "Content-Type": "application/json"
    }
    
    payload = {
        "input": {
            "prompt": prompt,
            "model": model,
            "max_tokens": 512,
            "temperature": 0.7
        }
    }
    
    # LangWatch에서 요청 추적
    with langwatch.trace_span("runpod_inference") as span:
        span.set_attribute("model", model)
        span.set_attribute("prompt_length", len(prompt))
        
        response = requests.post(
            f"{RUNPOD_ENDPOINT}/run",
            headers=headers,
            json=payload
        )
        
        result = response.json()
        
        # 응답 메트릭 기록
        span.set_attribute("response_length", len(result.get("output", "")))
        span.set_attribute("inference_time", result.get("execution_time", 0))
        
        return result["output"]
```

### vLLM과의 최적화 연계

vLLM은 높은 처리량과 효율적인 메모리 사용을 제공하는 LLM 추론 라이브러리입니다.

**vLLM + LangWatch 통합**:

```python
from vllm import LLM, SamplingParams
import langwatch

class OptimizedLLMService:
    def __init__(self, model_name="meta-llama/Llama-2-7b-chat-hf"):
        self.llm = LLM(
            model=model_name,
            tensor_parallel_size=2,  # GPU 병렬 처리
            max_model_len=4096,
            trust_remote_code=True
        )
        
        self.sampling_params = SamplingParams(
            temperature=0.7,
            top_p=0.95,
            max_tokens=512
        )
    
    @langwatch.trace()
    def generate(self, prompts, batch_size=8):
        """배치 처리로 최적화된 생성"""
        
        with langwatch.trace_span("vllm_batch_inference") as span:
            span.set_attribute("batch_size", len(prompts))
            span.set_attribute("model", self.llm.llm_engine.model_config.model)
            
            # vLLM 배치 추론
            outputs = self.llm.generate(prompts, self.sampling_params)
            
            # 처리량 메트릭 계산
            total_tokens = sum(len(output.outputs[0].token_ids) for output in outputs)
            span.set_attribute("total_output_tokens", total_tokens)
            span.set_attribute("throughput_tokens_per_second", 
                             total_tokens / span.duration if span.duration > 0 else 0)
            
            return [output.outputs[0].text for output in outputs]

# 사용 예시
llm_service = OptimizedLLMService()

prompts = [
    "AI의 미래에 대해 설명해주세요.",
    "기후 변화 해결 방안은 무엇인가요?",
    "양자 컴퓨팅의 원리를 간단히 설명해주세요."
]

responses = llm_service.generate(prompts)
```

### TensorRT-LLM 가속화

NVIDIA TensorRT-LLM을 사용하여 추론 성능을 극대화할 수 있습니다.

```python
import tensorrt_llm
import langwatch

class TensorRTLLMService:
    def __init__(self, engine_path):
        self.engine = tensorrt_llm.LLMEngine(engine_path)
        
    @langwatch.trace()
    def optimized_inference(self, prompt):
        """TensorRT 최적화된 추론"""
        
        with langwatch.trace_span("tensorrt_inference") as span:
            # 추론 성능 메트릭 수집
            start_time = time.time()
            
            result = self.engine.generate(
                prompt,
                max_new_tokens=512,
                temperature=0.7
            )
            
            inference_time = time.time() - start_time
            
            # LangWatch에 성능 데이터 기록
            span.set_attribute("inference_time_ms", inference_time * 1000)
            span.set_attribute("tokens_per_second", 
                             len(result.split()) / inference_time)
            
            return result
```

## 실전 LLMOps 워크플로우

### 1. 개발 단계

```python
# 개발 환경에서의 LangWatch 설정
import langwatch

# 개발 모드 설정
langwatch.init(
    api_key="your-dev-api-key",
    endpoint="http://localhost:5560",  # 로컬 LangWatch 인스턴스
    environment="development"
)

@langwatch.trace()
def prototype_chatbot(user_input):
    """프로토타입 챗봇 함수"""
    
    # 프롬프트 템플릿 테스트
    system_prompt = """당신은 도움이 되는 AI 어시스턴트입니다.
    사용자의 질문에 정확하고 친절하게 답변해주세요."""
    
    response = call_llm(system_prompt, user_input)
    
    # 개발 단계에서 즉시 평가
    evaluation_score = langwatch.evaluate_response(
        prompt=user_input,
        response=response,
        criteria=["relevance", "helpfulness", "safety"]
    )
    
    return response, evaluation_score
```

### 2. 스테이징 단계

```python
# 스테이징 환경에서 자동 평가 설정
@langwatch.trace()
def staging_deployment():
    """스테이징 환경에서 종합 테스트"""
    
    # 테스트 데이터셋 로드
    test_dataset = langwatch.load_dataset("customer_support_test_100")
    
    results = []
    for test_case in test_dataset:
        response = production_chatbot(test_case.input)
        
        # 자동 평가 실행
        evaluation = langwatch.auto_evaluate(
            input=test_case.input,
            output=response,
            expected=test_case.expected,
            metrics=["accuracy", "relevance", "safety"]
        )
        
        results.append({
            "input": test_case.input,
            "output": response,
            "scores": evaluation.scores,
            "passed": evaluation.overall_score > 0.8
        })
    
    # 스테이징 결과 리포트
    langwatch.create_evaluation_report(
        results=results,
        environment="staging",
        deployment_version="v1.2.0"
    )
    
    return results
```

### 3. 프로덕션 단계

```python
# 프로덕션 환경에서 실시간 모니터링
@langwatch.trace()
def production_chatbot(user_input, user_id=None):
    """프로덕션 챗봇 with 실시간 모니터링"""
    
    with langwatch.trace_span("production_inference") as span:
        # 사용자 컨텍스트 추가
        span.set_attribute("user_id", user_id)
        span.set_attribute("input_length", len(user_input))
        
        # 안전성 사전 검사
        safety_check = langwatch.safety_filter(user_input)
        if not safety_check.is_safe:
            span.set_attribute("safety_blocked", True)
            return "죄송합니다. 해당 요청을 처리할 수 없습니다."
        
        # LLM 추론 실행
        response = optimized_llm_call(user_input)
        
        # 실시간 품질 평가
        quality_score = langwatch.real_time_evaluate(
            input=user_input,
            output=response,
            metrics=["relevance", "coherence"]
        )
        
        span.set_attribute("quality_score", quality_score.overall)
        span.set_attribute("response_length", len(response))
        
        # 저품질 응답 감지 시 알림
        if quality_score.overall < 0.7:
            langwatch.alert(
                type="low_quality_response",
                severity="warning",
                details={
                    "user_id": user_id,
                    "score": quality_score.overall,
                    "input": user_input[:100] + "..."
                }
            )
        
        return response

# 프로덕션 메트릭 대시보드 설정
langwatch.setup_dashboard(
    metrics=[
        "requests_per_minute",
        "average_response_time",
        "quality_score_distribution",
        "error_rate",
        "cost_per_token"
    ],
    alerts=[
        {"metric": "error_rate", "threshold": 0.05, "action": "email"},
        {"metric": "avg_quality_score", "threshold": 0.8, "action": "slack"},
        {"metric": "cost_per_hour", "threshold": 100, "action": "email"}
    ]
)
```

## macOS 로컬 개발 환경 구축

### Docker Compose 설정

LangWatch를 로컬에서 실행하여 개발 환경을 구축해보겠습니다.

```bash
# LangWatch 클론 및 실행
git clone https://github.com/langwatch/langwatch.git
cd langwatch

# 환경 설정 파일 복사
cp langwatch/.env.example langwatch/.env

# Docker Compose로 실행 (ARM Mac의 경우)
docker compose -f compose.yml -f docker-compose.arm64.override.yml up -d --wait --build

# 브라우저에서 확인
open http://localhost:5560
```

### 개발환경 SDK 설정

```bash
# Python 가상환경 생성
python3 -m venv langwatch-dev
source langwatch-dev/bin/activate

# LangWatch SDK 설치
pip install langwatch

# 개발용 의존성 설치
pip install openai python-dotenv jupyter
```

### 환경 변수 설정

```bash
# ~/.zshrc에 추가
export LANGWATCH_API_KEY="lw-your-local-dev-key"
export LANGWATCH_ENDPOINT="http://localhost:5560"
export OPENAI_API_KEY="your-openai-api-key"

# alias 추가
alias langwatch-local="docker compose -f ~/langwatch/compose.yml up -d"
alias langwatch-stop="docker compose -f ~/langwatch/compose.yml down"
alias langwatch-logs="docker compose -f ~/langwatch/compose.yml logs -f"

# 변경사항 적용
source ~/.zshrc
```

### 테스트 스크립트 작성

```python
# test_langwatch_integration.py
import os
import langwatch
from openai import OpenAI

# LangWatch 초기화
langwatch.init(
    api_key=os.getenv("LANGWATCH_API_KEY"),
    endpoint=os.getenv("LANGWATCH_ENDPOINT")
)

client = OpenAI()

@langwatch.trace()
def test_basic_integration():
    """기본 통합 테스트"""
    
    # OpenAI 자동 추적 설정
    langwatch.get_current_trace().autotrack_openai_calls(client)
    
    # 테스트 요청
    response = client.chat.completions.create(
        model="gpt-3.5-turbo",
        messages=[
            {"role": "system", "content": "당신은 도움이 되는 AI 어시스턴트입니다."},
            {"role": "user", "content": "Python의 장점을 3가지만 설명해주세요."}
        ],
        temperature=0.7,
        max_tokens=200
    )
    
    result = response.choices[0].message.content
    print(f"응답: {result}")
    
    # 평가 실행
    evaluation = langwatch.evaluate_response(
        prompt="Python의 장점을 3가지만 설명해주세요.",
        response=result,
        criteria=["relevance", "accuracy", "completeness"]
    )
    
    print(f"평가 점수: {evaluation}")
    
    return result, evaluation

if __name__ == "__main__":
    result, evaluation = test_basic_integration()
    print("\n✅ LangWatch 통합 테스트 완료!")
    print(f"LangWatch 대시보드: http://localhost:5560")
```

### 실행 및 검증

```bash
# 테스트 실행
python test_langwatch_integration.py

# 브라우저에서 결과 확인
open http://localhost:5560

# 로그 확인
langwatch-logs
```

## 고급 활용 사례

### 1. 멀티모델 A/B 테스트

```python
import random
import langwatch

@langwatch.trace()
def multi_model_ab_test(user_input):
    """여러 모델을 동시에 테스트"""
    
    models = [
        {"name": "gpt-4", "weight": 0.3},
        {"name": "gpt-3.5-turbo", "weight": 0.5},
        {"name": "claude-3-sonnet", "weight": 0.2}
    ]
    
    # 가중치 기반 모델 선택
    selected_model = random.choices(
        models, 
        weights=[m["weight"] for m in models]
    )[0]
    
    with langwatch.trace_span("model_selection") as span:
        span.set_attribute("selected_model", selected_model["name"])
        span.set_attribute("selection_weight", selected_model["weight"])
        
        response = call_model(selected_model["name"], user_input)
        
        # 모델별 성능 메트릭 수집
        langwatch.record_metric(
            name=f"response_quality_{selected_model['name']}",
            value=evaluate_response_quality(response),
            tags={"model": selected_model["name"]}
        )
        
        return response
```

### 2. 자동 프롬프트 최적화

```python
from langwatch.optimization import DSPyOptimizer

class AutoPromptOptimizer:
    def __init__(self):
        self.optimizer = DSPyOptimizer()
        
    def optimize_prompt(self, base_prompt, training_data, metrics):
        """자동 프롬프트 최적화"""
        
        optimization_run = langwatch.start_optimization(
            name="customer_support_prompt_v2",
            base_prompt=base_prompt,
            training_data=training_data
        )
        
        # DSPy MIPROv2를 사용한 최적화
        optimized_prompt = self.optimizer.optimize(
            prompt_template=base_prompt,
            training_examples=training_data,
            eval_metrics=metrics,
            iterations=50
        )
        
        # 최적화 결과 평가
        evaluation_results = langwatch.evaluate_prompt(
            original_prompt=base_prompt,
            optimized_prompt=optimized_prompt,
            test_dataset=training_data,
            metrics=metrics
        )
        
        langwatch.complete_optimization(
            run_id=optimization_run.id,
            results=evaluation_results,
            optimized_prompt=optimized_prompt
        )
        
        return optimized_prompt, evaluation_results

# 사용 예시
optimizer = AutoPromptOptimizer()

base_prompt = """당신은 고객 지원 담당자입니다.
고객의 문의에 친절하고 정확하게 답변해주세요.

고객 문의: {question}
답변:"""

training_data = [
    {"question": "환불 정책이 어떻게 되나요?", "expected": "14일 이내 전액 환불..."},
    {"question": "배송 기간은 얼마나 걸리나요?", "expected": "일반 배송은 2-3일..."},
    # ... 더 많은 예시
]

optimized_prompt, results = optimizer.optimize_prompt(
    base_prompt=base_prompt,
    training_data=training_data,
    metrics=["accuracy", "helpfulness", "response_time"]
)
```

### 3. 비용 최적화 모니터링

```python
class CostOptimizedLLMService:
    def __init__(self):
        self.cost_thresholds = {
            "hourly": 50,  # $50/hour
            "daily": 500,   # $500/day
            "monthly": 10000  # $10,000/month
        }
        
    @langwatch.trace()
    def cost_aware_inference(self, prompt, priority="normal"):
        """비용을 고려한 추론 실행"""
        
        # 현재 비용 사용량 확인
        current_costs = langwatch.get_cost_metrics()
        
        with langwatch.trace_span("cost_check") as span:
            span.set_attribute("hourly_cost", current_costs.hourly)
            span.set_attribute("daily_cost", current_costs.daily)
            span.set_attribute("priority", priority)
            
            # 비용 임계값 확인
            if current_costs.hourly > self.cost_thresholds["hourly"]:
                if priority == "low":
                    span.set_attribute("cost_limited", True)
                    return "서비스가 일시적으로 제한되었습니다."
                elif priority == "normal":
                    # 더 저렴한 모델로 폴백
                    model = "gpt-3.5-turbo"  # 대신 gpt-4
                else:
                    model = "gpt-4"  # high priority는 고성능 모델 사용
            else:
                model = "gpt-4"
            
            span.set_attribute("selected_model", model)
            
            response = call_model(model, prompt)
            
            # 이번 요청의 비용 계산
            estimated_cost = estimate_request_cost(prompt, response, model)
            span.set_attribute("request_cost", estimated_cost)
            
            # 비용 알림 확인
            if current_costs.daily + estimated_cost > self.cost_thresholds["daily"]:
                langwatch.alert(
                    type="cost_threshold_approached",
                    severity="warning",
                    details={"daily_cost": current_costs.daily + estimated_cost}
                )
            
            return response
```

## 결론

LangWatch는 현대적인 LLMOps 요구사항을 충족하는 종합적인 플랫폼입니다. OpenTelemetry 표준 기반의 관찰성, 실시간/오프라인 평가 시스템, 자동화된 프롬프트 최적화 등의 기능을 통해 LLM 애플리케이션의 전체 라이프사이클을 효과적으로 관리할 수 있습니다.

### 주요 장점 요약

1. **표준화된 관찰성**: OpenTelemetry 기반으로 다양한 LLM 프레임워크와 호환
2. **종합적인 평가**: 실시간 모니터링과 오프라인 평가의 결합
3. **자동화된 최적화**: DSPy MIPROv2를 활용한 프롬프트 자동 최적화
4. **비용 효율성**: 상세한 비용 추적과 최적화 기능
5. **확장 가능성**: RunPod, vLLM 등 다양한 인프라와의 연계

### 다음 단계 권장사항

1. **로컬 환경 구축**: Docker Compose로 개발 환경 설정
2. **단계적 도입**: 개발 → 스테이징 → 프로덕션 순서로 적용
3. **메트릭 정의**: 비즈니스 목표에 맞는 평가 지표 설정
4. **자동화 구축**: CI/CD 파이프라인에 평가 프로세스 통합
5. **팀 협업**: 도메인 전문가와 개발팀 간의 협업 프로세스 구축

LangWatch를 통해 구축된 LLMOps 체계는 AI 애플리케이션의 품질과 안정성을 크게 향상시키며, 지속적인 개선과 최적화를 가능하게 합니다. 특히 RunPod, vLLM과 같은 최신 AI 인프라와 결합하면 더욱 강력하고 효율적인 LLM 운영 환경을 구축할 수 있습니다.
