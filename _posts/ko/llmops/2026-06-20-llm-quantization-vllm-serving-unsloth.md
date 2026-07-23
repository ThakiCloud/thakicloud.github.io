---
title: "NVFP4 다음을 준비한다: vLLM으로 서빙하는 양자화 기법 총정리 (Unsloth 포함)"
excerpt: "Blackwell 전용 NVFP4 말고, Hopper·Ampere에서 오늘 당장 vLLM으로 서빙 가능한 양자화 기법을 정리합니다. AWQ·GPTQ·FP8·W4A16·compressed-tensors부터 Unsloth Dynamic 2.0까지, 실제 레시피와 서빙 플래그로."
seo_title: "vLLM 양자화 서빙 총정리: AWQ·GPTQ·FP8·W4A16·Unsloth - Thaki Cloud"
seo_description: "vLLM으로 서빙 가능한 LLM 양자화 기법을 비교합니다. llm-compressor(compressed-tensors) W4A16·W8A8·FP8, AWQ+Marlin, GPTQModel, AutoRound, Unsloth Dynamic 2.0와 merge→AWQ 프로덕션 경로까지 실제 코드로 정리."
date: 2026-06-20
last_modified_at: 2026-06-20
tags:
  - quantization
  - vllm
  - awq
  - gptq
  - fp8
  - llm-compressor
  - unsloth
  - compressed-tensors
  - moe
  - thakicloud
header:
  teaser: /assets/images/llm-quant-vllm-hero.webp
toc: true
toc_sticky: true
categories:
  - llmops
published: false
---

![vLLM이 서빙하는 양자화 포맷 지도]({{ '/assets/images/llm-quant-vllm-hero.webp' | relative_url }})

## 왜 또 양자화인가

서빙 비용의 대부분은 GPU 메모리와 처리량에서 나옵니다. 모델을 4비트로 줄이면 같은 카드에 더 큰 모델을 올리고, 같은 모델을 더 많은 동시 사용자에게 제공할 수 있습니다. 문제는 "어떤 양자화를 골라야 vLLM에서 실제로 잘 서빙되느냐"입니다.

우리가 앞서 다룬 [NVFP4 양자화](https://github.com/ThakiCloud/praxis)는 W4A4를 Blackwell(B200) 텐서코어에서 돌리는 최신 경로입니다. 다만 NVFP4 텐서코어는 Blackwell에만 있습니다. H100·A100 같은 이전 세대나, 혼합된 클러스터에서는 다른 기법이 필요합니다. 이 글은 NVFP4를 빼고, 지금 가진 하드웨어에서 vLLM으로 바로 서빙할 수 있는 기법을 실제 레시피와 함께 정리합니다. Unsloth Dynamic 2.0도 포함합니다.

## vLLM이 서빙하는 양자화 지도

| 방법 | 비트폭 | vLLM 로드 | GPU | 메모 |
|---|---|---|---|---|
| AWQ + Marlin | W4A16 | `--quantization awq` (Marlin 자동) | Turing+ | 프로덕션 4비트 표준 |
| GPTQ / GPTQModel | W4A16, W3 | `--quantization gptq` | Volta+ | 호환성 가장 넓음 |
| compressed-tensors | W4A16 / W8A8 / FP8 | 자동 감지(플래그 불요) | Turing+ ~ Blackwell | llm-compressor 공식 포맷 |
| FP8 (E4M3) | W8A8 FP8 | `--quantization fp8` 또는 자동 | Ada(cc≥8.9)·Hopper·Blackwell | MoE 1순위 |
| INT8 W8A8 | W8A8 INT8 | compressed-tensors 자동 | Turing+ | SmoothQuant 계열 |
| AutoRound | W4A16, INT2-4 | compressed-tensors 자동 | CUDA·CPU·Intel | 초저비트 정확도 우수 |
| bitsandbytes NF4 | W4A16 | `--quantization bitsandbytes` | Volta-Hopper | 메모리용, 처리량 낮음 |
| GGUF | Q4-Q8 | `repo:quant` (플러그인) | 실험적 | llama.cpp 생태계용 |

핵심은 두 가지입니다. 첫째, vLLM의 4비트 프로덕션 표준은 AWQ나 GPTQ를 **Marlin 커널**로 돌리는 W4A16입니다. JarvisLabs 벤치마크에서 Qwen2.5-32B 기준 Marlin-AWQ가 741 tok/s로, 기본 AWQ 커널 68 tok/s 대비 크게 빨랐습니다([출처](https://jarvislabs.ai/blog/vllm-quantization-complete-guide-benchmarks)). 둘째, neuralmagic(Red Hat)와 vLLM 프로젝트가 함께 만든 **compressed-tensors** 포맷은 모델의 `quantization_config`를 vLLM이 읽어 플래그 없이 자동 로드합니다.

## compressed-tensors와 llm-compressor: 권장 경로

`llm-compressor`로 양자화하면 결과물이 compressed-tensors 포맷으로 저장되고, vLLM이 자동 감지합니다. W4A16, W8A8-INT8, FP8을 모두 한 도구로 다룹니다([llm-compressor](https://github.com/vllm-project/llm-compressor)).

```python
# W4A16 (AWQ 스타일) llm-compressor 레시피
from llmcompressor.transformers import oneshot
from llmcompressor.modifiers.quantization import GPTQModifier

recipe = GPTQModifier(scheme="W4A16", targets="Linear", ignore=["lm_head"])
oneshot(
    model="Qwen/Qwen3-30B-A3B",
    dataset="open_platypus",   # 보정(calibration) 셋
    recipe=recipe,
    output_dir="Qwen3-30B-A3B-W4A16",
    max_seq_length=2048, num_calibration_samples=512,
)
```

서빙은 플래그가 거의 필요 없습니다.

```bash
# compressed-tensors는 자동 감지, --quantization 생략 가능
vllm serve ./Qwen3-30B-A3B-W4A16 --served-model-name qwen3-w4a16
# AWQ 체크포인트를 직접 서빙할 때
vllm serve TheBloke/...-AWQ --quantization awq
```

FP8은 보정 데이터 없이도 동적으로 만들 수 있어 가장 손이 적게 갑니다.

```python
from llmcompressor.modifiers.quantization import QuantizationModifier
recipe = QuantizationModifier(targets="Linear", scheme="FP8_DYNAMIC", ignore=["lm_head"])
```

## MoE 모델(Qwen3-MoE)은 FP8 블록-와이즈

우리 기본 서빙 대상은 Qwen3-MoE 계열입니다. MoE는 양자화에서 까다롭습니다. 결론부터 말하면 cc≥8.9 GPU(Ada·Hopper·Blackwell)에서는 **FP8 블록-와이즈**가 1순위입니다. 보정 데이터가 필요 없고 vLLM이 공식 지원합니다. 메모리가 더 빠듯하면 W4A16으로 내려갑니다. 단, Qwen3-MoE에서 FP8 per-tensor는 차원 불일치 버그가 보고됐으니 블록-와이즈를 쓰는 편이 안전합니다([이슈](https://github.com/vllm-project/llm-compressor/issues/2043)).

## Unsloth: 파인튜닝과 Dynamic 2.0 양자화

Unsloth는 두 가지로 유용합니다. 하나는 QLoRA 파인튜닝, 다른 하나는 Dynamic 2.0 양자화입니다.

**Dynamic 2.0(UD)**는 모든 레이어에 같은 비트폭을 일괄 적용하지 않고, 레이어별 민감도를 평가해 중요한 레이어는 높은 정밀도로, 덜 중요한 레이어는 더 낮은 비트로 압축합니다. 모델마다 다른 맞춤형 양자화 맵이 나옵니다. Unsloth가 공개한 벤치마크에서 Gemma 3 27B의 Dynamic Q4_K_XL이 MMLU 5-shot 71.47%로, Google QAT 베이스라인 70.64%보다 높으면서 파일은 15.64GB로 더 작았습니다(Unsloth-reported, [블로그](https://unsloth.ai/blog/dynamic-v2)). 초기 Dynamic이 MoE에서만 잘 동작했던 것과 달리 2.0은 dense 모델까지 확장됐습니다.

`unsloth/...-bnb-4bit` 모델은 NF4 4비트로 사전 양자화된 체크포인트로, 주로 QLoRA 파인튜닝의 출발점입니다. 학습 후에는 `save_pretrained_gguf()` 한 줄로 llama.cpp용 GGUF를 만들 수 있습니다.

### Unsloth 모델을 vLLM으로 서빙하는 현실적 경로

여기서 정직해야 합니다. Unsloth가 만든 포맷 중 vLLM 프로덕션 서빙에 바로 적합한 것은 제한적입니다. bitsandbytes NF4는 vLLM에서 로드되긴 하지만 처리량이 낮고(일부 모델에서 shape 오류 보고), Dynamic UD-GGUF는 vLLM 공식 문서에 없는 llama.cpp 전용 포맷입니다. vLLM의 GGUF 지원 자체가 "highly experimental"로 명시돼 있습니다([vLLM GGUF](https://docs.vllm.ai/en/latest/features/quantization/gguf/)).

그래서 프로덕션 경로는 **파인튜닝은 Unsloth, 서빙용 양자화는 다시**입니다.

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
<div class="d3-arch" data-arch-root id="zationvllmservingunsloth-1"></div>
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 871, "height": 267, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 24, "y": 99, "w": 121, "h": 62, "title": ["Unsloth QLoRA", "NF4 4-bit 학습"]}, {"id": "B", "x": 223, "y": 99, "w": 120, "h": 62, "title": ["LoRA 병합", "merged_16bit"]}, {"id": "C1", "x": 421, "y": 157, "w": 142, "h": 78, "title": ["로컬/소규모:", "GGUF Q4_K_M", "Ollama·llama.cpp"]}, {"id": "C2", "x": 428, "y": 24, "w": 128, "h": 78, "title": ["프로덕션 vLLM:", "W4A16/FP8 재양자화", "llm-compressor"]}, {"id": "D", "x": 641, "y": 32, "w": 198, "h": 62, "title": ["vllm serve", "compressed-tensors 자동 로드"]}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [145, 130, 223, 130]}, {"src": "B", "dst": "C1", "kind": "data", "curve": [[329, 161], [382, 196], [382, 196], [421, 196]]}, {"src": "B", "dst": "C2", "kind": "data", "curve": [[329, 99], [382, 63], [382, 63], [428, 63]]}, {"src": "C2", "dst": "D", "kind": "data", "line": [556, 63, 641, 63]}]});
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
      const container = document.getElementById('zationvllmservingunsloth-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = 'zationvllmservingunsloth-1';
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

```python
# Unsloth: QLoRA 학습 후 16bit 병합
model.save_pretrained_merged("merged_model", tokenizer, save_method="merged_16bit")
# 이어서 위 llm-compressor W4A16/FP8 레시피로 재양자화 → vLLM 서빙
```

로컬·실험 서빙이라면 Unsloth의 Dynamic GGUF를 Ollama나 llama.cpp로 그대로 쓰는 것이 정확도·편의 면에서 좋습니다. 멀티 사용자 프로덕션이라면 병합 후 W4A16 또는 FP8로 다시 양자화해 vLLM에 올리는 편이 처리량에서 유리합니다.

## 비용과 관측 관점

양자화는 비용 절감 수단이지만 공짜가 아닙니다. 세 가지를 함께 봐야 합니다. 첫째 메모리 절감(같은 카드에 더 큰 모델, 또는 더 긴 컨텍스트), 둘째 처리량(Marlin 커널 여부가 토큰/초를 좌우), 셋째 정확도(과제별 회귀를 반드시 측정). 서빙 후에는 vLLM의 메트릭으로 토큰 처리량과 TTFT, 카드별 메모리 점유를 모니터링하고, 양자화 전후로 핵심 평가셋을 돌려 회귀를 확인하는 절차를 권장합니다.

## ThakiCloud 관점: 왜 이 정리가 필요했나

ThakiCloud의 AI 플랫폼은 Kubernetes 위에서 Kueue로 GPU를 스케줄링하고 vLLM으로 모델을 서빙합니다. 우리 에이전트 플랫폼 Paxis는 self-hosted vLLM 백엔드(코드네임 Metis)를 OpenAI 호환 API로 호출합니다. 즉 양자화 선택은 곧 우리 서빙 단가와 직결됩니다.

운영 현실은 하드웨어가 섞여 있다는 것입니다. Blackwell(B200)에서는 NVFP4가 최선이지만, Hopper·Ampere 노드에서는 그 길이 막힙니다. 그래서 우리는 하드웨어 계층에 따라 양자화를 라우팅합니다. Blackwell은 NVFP4 또는 FP8 블록-와이즈, Hopper는 FP8과 W4A16, Ampere는 AWQ/GPTQ W4A16. 모두 compressed-tensors로 통일해두면 vLLM이 자동 감지하므로 서빙 코드를 거의 바꾸지 않아도 됩니다. 도메인 파인튜닝은 Unsloth로 저렴하게 끝내고, 서빙용으로는 병합 후 W4A16/FP8로 재양자화하는 경로를 표준으로 둡니다.

이 구성의 이점은 분명합니다. 온프레미스와 self-hosting 환경에서 데이터를 밖으로 내보내지 않고도, 고객이 가진 GPU 세대에 맞춰 가장 싼 서빙 단가를 뽑아낼 수 있습니다. 양자화는 단순한 압축이 아니라, 우리가 제안하는 비용 효율의 핵심 레버입니다.

## 정리

- vLLM 프로덕션 4비트 표준은 Marlin 커널을 쓰는 W4A16(AWQ/GPTQ)입니다.
- 한 도구로 통일하려면 llm-compressor + compressed-tensors가 가장 매끄럽습니다(자동 감지).
- MoE는 FP8 블록-와이즈가 1순위, 메모리가 빠듯하면 W4A16.
- Unsloth는 파인튜닝과 정확도 높은 Dynamic 양자화에 강하지만, vLLM 프로덕션 서빙은 병합 후 W4A16/FP8 재양자화가 현실적인 경로입니다.

## 더 보기

- vLLM 양자화 문서: [docs.vllm.ai](https://docs.vllm.ai/en/latest/features/quantization/)
- llm-compressor: [github.com/vllm-project/llm-compressor](https://github.com/vllm-project/llm-compressor)
- Unsloth Dynamic 2.0: [unsloth.ai/blog/dynamic-v2](https://unsloth.ai/blog/dynamic-v2)
- ThakiCloud Paxis: [github.com/ThakiCloud/praxis](https://github.com/ThakiCloud/praxis)
