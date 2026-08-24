---
title: "에이전트가 스스로 만든 스킬로 자기를 가르친다: SEED가 희소 보상 문제를 푸는 방법"
seo_title: "SEED 자기진화 온폴리시 증류로 에이전트 RL 희소 보상 해결 | ThakiCloud"
seo_description: "결과 기반 강화학습은 궤적 전체에 보상 하나만 줘서 중간 결정을 못 가르칩니다. SEED는 에이전트가 완료한 궤적을 스스로 분석해 자연어 스킬을 만들고, 그 스킬이 만드는 확률 변화를 토큰 단위 증류 신호로 되먹입니다. 텍스트와 비전 에이전트 과제에서 성능과 샘플 효율이 함께 올랐습니다."
excerpt: "에이전트 RL의 진짜 병목은 보상이 궤적 끝에 한 번만 온다는 데 있습니다. SEED는 에이전트가 자기 궤적에서 스스로 뽑은 자연어 스킬을 다시 자기에게 증류해, 그 희소한 신호를 토큰마다 촘촘한 신호로 바꿉니다."
date: 2026-07-23
tags:
  - 에이전트 RL
  - 강화학습
  - 온폴리시 증류
  - 희소 보상
  - 자기진화
  - LLM 에이전트
  - 포스트트레이닝
  - 샘플 효율
  - 힌드사이트 스킬
  - 크레딧 할당
categories: [research]
author_profile: true
toc: true
canonical_url: "https://thakicloud.com/tech-blog/ko/research/seed-self-evolving-distillation-agentic-rl/"
audiobook: /assets/audio/posts/seed-self-evolving-distillation-agentic-rl/audiobook-ko.mp3
audiobook_note: "AI 로컬 합성 오디오북 (Qwen3-TTS)"
---

멀티턴 도구 사용과 환경 피드백으로 움직이는 LLM 에이전트를 강화학습으로 훈련하고 있다면, 이 글이 바로 여러분을 위한 것입니다. 핵심 결론을 먼저 적겠습니다. 에이전트 RL이 잘 안 되는 가장 흔한 이유는 모델이 약해서가 아니라 보상이 궤적 끝에 딱 한 번만 오기 때문이며 SEED는 에이전트가 자기 궤적을 스스로 분석해 만든 자연어 스킬을 다시 자기에게 되먹이는 방식으로 그 희소한 신호를 토큰 단위의 촘촘한 신호로 바꿉니다. 이 방법은 텍스트 기반과 비전 기반 에이전트 과제 모두에서 성능과 샘플 효율을 함께 끌어올렸습니다.

![스스로의 궤적을 되돌아보며 자기 자신에게 지식을 증류하는 에이전트를 형상화한 추상 이미지](/assets/images/seed-self-evolving-distillation-agentic-rl-hero.webp)
*완료된 궤적에서 스킬을 캐내 다시 자기에게 되먹이는 SEED의 자기진화 루프를 형상화했습니다.*

## 왜 읽어야 하나

이 글은 에이전트를 강화학습으로 후처리 훈련하는 엔지니어와, 그 훈련 인프라를 설계하는 플랫폼 담당자를 위한 것입니다. 여러분이 내려야 할 결정은 하나입니다. 결과 하나로만 보상을 주는 지금의 RL 파이프라인에 어떻게 추가 감독 신호를 더 밀어 넣을 것인가입니다. SEED(Self-Evolving On-Policy Distillation, arXiv:2607.14777)는 그 답으로 별도의 강한 교사 모델도, 사람이 만든 보상 모델도 아닌 정책 자기 자신을 교사로 쓰는 길을 제시합니다. 결론부터 말하면 궤적을 분석해 재사용 가능한 스킬을 뽑아내고 그 스킬이 정책의 행동 확률을 얼마나 바꾸는지를 신호로 삼는 이 자기진화 루프는 추가 라벨 없이도 중간 결정에 대한 감독을 만들어 냅니다.

## 개요

지난 몇 년의 추론 모델 훈련은 결과 기반 강화학습, 즉 검증 가능한 보상을 쓰는 RLVR 계열이 이끌었습니다. 정답이면 1, 오답이면 0 같은 궤적 수준 보상을 주고 정책을 밀어 올리는 방식입니다. 단일 응답을 뱉는 수학이나 코딩 문제에서는 이 방식이 잘 통합니다. 문제는 에이전트입니다. 도구를 여러 번 호출하며 관찰을 받고 다시 행동하는 긴 궤적에서는 마지막 성공 여부 하나가 그 사이에 있었던 수십 개의 중간 결정 각각이 좋았는지 나빴는지를 거의 알려 주지 못합니다. 에피소드 수준의 결과와 토큰 수준의 학습 사이에 감독의 공백이 생기는 것입니다. 이 공백이 에이전트 RL의 샘플 효율을 갉아먹는 근본 병목입니다.

SEED는 이 공백을 메우는 방법을 제안합니다. 핵심 발상은 완료된 궤적 안에 이미 배울 것이 들어 있다는 것입니다. 성공한 궤적에는 재사용할 만한 작업 흐름이 있고 실패한 궤적에는 피해야 할 함정이 있습니다. SEED는 이 사후 지식(hindsight)을 자연어 스킬로 명시화한 다음, 그 스킬을 다시 정책에게 증류해 넣습니다. 그리고 이 스킬을 뽑는 분석가 역할을 외부 모델이 아니라 현재 정책 자신이 맡습니다. 정책이 궤적도 모으고, 그 궤적에서 스킬도 뽑는 자기진화 구조입니다.

## SEED는 무엇인가

SEED를 한 문장으로 요약하면, 완료된 온폴리시 궤적을 훈련 시점의 사후 스킬로 바꾸고 그 스킬의 행동적 효과를 정책 모델에 다시 증류하는 자기진화 프레임워크입니다. 세 단계로 나눠 보면 구조가 분명해집니다.

우선 정책을 미세조정해 완료된 궤적을 스스로 분석하고 자연어 스킬을 생성하도록 만듭니다. 이 스킬은 재사용 가능한 작업 흐름, 결정적이었던 관찰, 실패를 피하는 규칙 같은 것을 담습니다. 사람이 프롬프트로 규칙을 주입하는 것이 아니라 모델이 자기 경험에서 규칙을 언어로 뽑아내는 셈입니다.

이 훈련 루프가 도는 동안 현재 정책은 두 가지 역할을 동시에 맡습니다. 늘 하던 대로 환경과 상호작용하며 궤적을 수집하는 역할과, 그 궤적을 분석해 사후 스킬을 뽑아내는 분석가 역할입니다. 교사가 따로 없으니 교사와 학생 사이의 분포 어긋남이 생기지 않고 스킬은 언제나 지금 정책이 실제로 밟고 있는 궤적 분포에 맞춰져 있습니다.

SEED가 진짜 차별화되는 지점은 다음 장치에 있습니다. 샘플링된 행동을 두 가지 맥락에서 다시 채점하는데, 하나는 스킬이 없는 평범한 맥락이고 다른 하나는 뽑아낸 스킬을 덧붙인 맥락입니다. 스킬을 붙였을 때 특정 행동의 확률이 얼마나 올라가거나 내려가는지 그 확률 변화를 토큰 단위의 촘촘한 온폴리시 증류 신호로 바꾸고 이 신호를 결과 기반 RL과 함께 최적화합니다. 스킬이 있었으면 더 높은 확률로 택했을 행동 쪽으로 정책을 미는 셈인데, 이 보조 감독이 언제나 현재 궤적 분포에 정렬되어 있다는 점이 중요합니다.

아래 도표가 이 루프를 보여 줍니다.

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
<div class="d3-arch" data-arch-root id="ingdistillationagenticrl-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 451, "height": 894, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 142, "y": 24, "w": 120, "h": 46, "title": "현재 정책"}, {"id": "B", "x": 211, "y": 162, "w": 120, "h": 46, "title": "완료된 궤적 수집"}, {"id": "C", "x": 207, "y": 286, "w": 128, "h": 46, "title": "같은 정책이 분석가로 전환"}, {"id": "D", "x": 211, "y": 424, "w": 120, "h": 46, "title": "자연어 사후 스킬"}, {"id": "E", "x": 202, "y": 548, "w": 138, "h": 52, "title": "행동 재채점"}, {"id": "F", "x": 299, "y": 692, "w": 120, "h": 46, "title": "기본 확률"}, {"id": "G", "x": 124, "y": 692, "w": 120, "h": 46, "title": "스킬 반영 확률"}, {"id": "H", "x": 102, "y": 816, "w": 163, "h": 46, "title": "확률 변화 = 토큰 단위 증류 신호"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "label": "환경과 상호작용", "curve": [[225, 70], [271, 116], [271, 116], [271, 162]], "off": "50%"}, {"src": "B", "dst": "C", "kind": "data", "line": [271, 208, 271, 286]}, {"src": "C", "dst": "D", "kind": "data", "label": "재사용 워크플로<br/>결정적 관찰<br/>실패 회피 규칙", "line": [271, 332, 271, 424], "lx": 271, "ly": 374}, {"src": "D", "dst": "E", "kind": "data", "line": [271, 470, 271, 548]}, {"src": "E", "dst": "F", "kind": "data", "label": "스킬 없는 맥락", "curve": [[303, 600], [359, 646], [359, 646], [359, 692]], "off": "50%"}, {"src": "E", "dst": "G", "kind": "data", "label": "스킬 붙인 맥락", "curve": [[240, 600], [184, 646], [184, 646], [184, 692]], "off": "50%"}, {"src": "F", "dst": "H", "kind": "data", "curve": [[359, 738], [359, 777], [359, 777], [249, 816]]}, {"src": "G", "dst": "H", "kind": "data", "line": [184, 738, 184, 816]}, {"src": "H", "dst": "A", "kind": "data", "label": "결과 RL과 공동 최적화", "curve": [[140, 816], [66, 574], [66, 309], [156, 70]], "off": "50%"}]});
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
      const container = document.getElementById('ingdistillationagenticrl-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'ingdistillationagenticrl-1';
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

기존 접근과의 차이는 분명합니다. 강한 외부 모델을 교사로 두고 증류하는 방식은 교사를 구해야 하고 교사와 학생의 분포가 어긋나면 신호가 오염됩니다. 사람이 보상 모델을 만드는 방식은 라벨 비용이 큽니다. SEED는 둘 다 피합니다. 교사는 정책 자신이고 라벨은 궤적에서 자동으로 추출됩니다. 신호는 매 순간 현재 정책에 맞춰집니다.

## 논문이 보고한 실험 결과

논문은 텍스트 기반과 비전 기반 에이전트 과제 양쪽에서 광범위한 실험을 수행했다고 보고합니다. 결과의 방향은 일관됩니다. SEED는 성능과 샘플 효율을 함께 개선했고 훈련에서 보지 못한 시나리오로의 일반화도 견고했다고 합니다. 강력한 베이스라인 방법들과 비교했을 때 세 개의 대표적인 에이전트 벤치마크에서 가장 높은 평균 성능을 기록했다는 것이 논문의 핵심 주장입니다.

여기서 정직하게 짚을 것이 있습니다. 이 글은 논문의 초록과 공개된 요약을 근거로 작성했으며, 벤치마크별 구체적 수치는 원문에서 직접 확인하시기를 권합니다. 저희가 별도로 재현 실험을 돌려 측정한 값이 아니므로, 절대 수치를 인용하기보다 결과의 구조와 방향을 전달하는 데 집중했습니다. 다만 방향성만으로도 시사점은 분명합니다. 샘플 효율이 올랐다는 것은 같은 성능에 도달하는 데 더 적은 궤적, 곧 더 적은 GPU 시간이 든다는 뜻이고 이는 에이전트 RL을 실제로 운용하는 쪽에서 가장 비싼 자원을 아끼는 것과 직결됩니다.

## ThakiCloud 제품 적용 시사점

SEED가 던지는 발상은 ThakiCloud가 운용하는 두 제품 모두와 맞닿아 있습니다.

Paxis 관점이 특히 직접적입니다. Paxis는 ThakiCloud의 Agent-Native Cloud로, 스킬과 도구, 정책, 감사 로그를 일급 리소스로 다룹니다. 그 안에는 에이전트가 경험에서 스킬을 뽑아내 스스로 진화하는 자가진화 스킬 계층이 있습니다. SEED가 학술적으로 보여준 것이 바로 이 발상입니다. 완료된 궤적을 자연어 스킬로 명시화하고 그것을 다시 행동에 되먹이는 루프가 실제로 정책을 개선한다는 점입니다. Paxis의 스킬 하네스가 960개가 넘는 스킬을 BM25로 선택해 격리 샌드박스에서 실행하고 모든 행동을 정책 게이트와 감사 로그로 통과시키는 구조라면, SEED는 그 스킬들이 어떻게 경험에서 태어나 다듬어지는지에 대한 훈련 시점의 이론적 뒷받침을 제공합니다. 자연어로 표현된 스킬은 사람이 읽고 감사할 수 있다는 점에서, 정책 게이트와 감사 로그를 중시하는 Paxis의 설계 철학과도 잘 맞습니다.

ai-platform 관점도 있습니다. SEED 같은 방법을 실제로 돌리려면 결과 기반 RL과 증류 신호를 함께 최적화하는 후처리 훈련 파이프라인이 필요하고 이는 GPU 자원을 상당히 먹습니다. ThakiCloud의 ai-platform은 Kueue 기반 GPU 스케줄링과 멀티테넌트 서빙 위에서 SFT, DPO, GRPO 같은 후처리 훈련을 운용합니다. SEED가 강조하는 샘플 효율 개선은 이 인프라에서 곧바로 비용으로 환산됩니다. 같은 에이전트 품질에 더 적은 궤적으로 도달한다면, 공유 GPU 풀에서 더 많은 훈련 잡을 소화하거나 같은 예산으로 더 깊이 훈련할 수 있습니다.

## 한계 및 반론

SEED의 자기진화 구조는 강력하지만, 정책 자신이 분석가를 겸한다는 점은 양날의 검입니다. 정책이 아직 약한 초기 단계에서는 그 정책이 뽑아내는 스킬의 질도 낮을 수밖에 없고 낮은 질의 스킬로 만든 증류 신호가 학습을 잘못된 방향으로 밀 위험이 있습니다. 강한 외부 교사를 쓰지 않는 대가로, 초기 부트스트랩 구간의 신호 품질을 어떻게 확보하느냐가 실전에서의 관건이 됩니다.

또한 스킬을 뽑고 행동을 두 맥락에서 재채점하는 과정은 순수한 결과 기반 RL보다 계산량이 늘어납니다. 샘플 효율이 좋아져 궤적 수가 줄어드는 이득과, 궤적마다 분석과 재채점을 추가하는 비용 사이의 손익은 과제와 규모에 따라 달라질 것입니다. 마지막으로 이 글이 근거한 결과는 논문이 선정한 세 개 벤치마크에 대한 것이며 그 밖의 도메인, 특히 도구 생태계가 크게 다른 실제 프로덕션 에이전트로 이 이득이 그대로 이전될지는 별도의 검증이 필요합니다.

## 정리

에이전트 강화학습의 병목이 모델 능력이 아니라 감독의 공백이라는 진단은, 모델을 더 키우기 전에 신호를 더 촘촘하게 만들라는 방향을 가리킵니다. SEED는 그 촘촘한 신호를 외부에서 사 오지 않고 에이전트가 이미 만들어 낸 궤적 안에서 자연어 스킬의 형태로 캐내 자기 자신에게 되먹이는 길을 보여 줍니다. 여러분이 에이전트 RL 파이프라인을 운용한다면 오늘 가져갈 한 가지는 분명합니다. 결과 하나로만 보상을 주고 있다면, 그 궤적을 버리지 말고 사후 스킬을 뽑아 토큰 단위 감독으로 재활용할 여지가 있는지 먼저 점검해 보십시오. 그것이 더 큰 모델이나 더 강한 교사보다 먼저 시도해볼 만한 저비용 수단일 수 있습니다.

출처: [SEED: Self-Evolving On-Policy Distillation for Agentic Reinforcement Learning (arXiv:2607.14777)](https://arxiv.org/abs/2607.14777)

## 관련 슬라이드

본문 내용을 NotebookLM(`architectural_timeline` 스타일)으로 요약한 슬라이드입니다.

![seed-self-evolving-distillation-agentic-rl 슬라이드 1](/assets/images/seed-self-evolving-distillation-agentic-rl-slide-01.webp)

![seed-self-evolving-distillation-agentic-rl 슬라이드 2](/assets/images/seed-self-evolving-distillation-agentic-rl-slide-02.webp)

![seed-self-evolving-distillation-agentic-rl 슬라이드 3](/assets/images/seed-self-evolving-distillation-agentic-rl-slide-03.webp)

![seed-self-evolving-distillation-agentic-rl 슬라이드 4](/assets/images/seed-self-evolving-distillation-agentic-rl-slide-04.webp)

