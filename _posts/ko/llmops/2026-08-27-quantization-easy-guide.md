---
title: "눈금이 16칸뿐인 자로 재봅니다: 양자화 쉽게 읽기"
seo_title: "LLM 양자화 쉬운 설명 - GGUF, MLX, NVFP4, Unsloth Dynamic 3.0까지 한판 정리 | ThakiCloud"
seo_description: "양자화가 무엇인지 비유 하나로 끝까지 설명하고 GGUF와 MLX와 NVFP4와 MXFP4가 서로 무엇이 다른지, 어떤 하드웨어에 어떤 포맷을 올려야 하는지를 정리합니다. 4비트로 저장했는데 16비트로 계산하는 함정과, 저희가 B200과 H200에서 직접 재본 수치도 함께 담았습니다."
excerpt: "4비트는 숫자를 열여섯 칸짜리 자로 재는 일입니다. 그런데 파일이 4비트여도 그 GPU가 4비트를 읽을 줄 모르면 매번 16비트로 펼쳐서 계산합니다. 포맷 이름이 아니라 이 갈림길이 속도를 정합니다."
date: 2026-08-27
tags:
  - 양자화
  - quantization
  - GGUF
  - MLX
  - NVFP4
  - MXFP4
  - FP8
  - AWQ
  - GPTQ
  - Unsloth
  - 추론 최적화
  - LLMOps
  - 입문
header:
  teaser: /assets/images/quantization-easy-guide-hero.webp
categories: [llmops]
author_profile: true
toc: true
toc_label: "목차"
toc_sticky: true
reading_time: true
canonical_url: "https://thakicloud.com/tech-blog/ko/llmops/quantization-easy-guide/"
---

허깅페이스에서 모델을 받으려는데 `Q4_K_M`, `UD-IQ2_M`, `NVFP4`, `MXFP4`, `AWQ`, `4bit-DWQ` 같은 이름표가 줄줄이 붙어 있어서 뭘 눌러야 할지 몰랐다면, 이 글 하나로 그 목록을 읽는 법을 가져가실 수 있습니다. 결론을 먼저 드리면 이렇습니다. **양자화에서 진짜 갈림길은 몇 비트냐가 아니라, 내 하드웨어가 그 비트를 읽을 줄 아느냐입니다.** 같은 4비트 파일이 어떤 GPU에서는 1.28배 빨라지고 다른 GPU에서는 오히려 0.81배로 느려집니다. 저희가 직접 잰 값이고 이 글 뒤쪽에서 그 숫자를 그대로 보여 드리겠습니다.

![눈금이 열여섯 칸뿐인 자로 수십억 개의 숫자를 다시 적는 양자화 개념도]({{ '/assets/images/quantization-easy-guide-hero.webp' | relative_url }})
*4비트는 눈금이 열여섯 칸인 자입니다. 그 자로도 쓸 만한 결과가 나오는 이유가 이 글의 앞부분입니다.*

## 무거운 책을 얇게 만드는 일

[지난번 투기 디코딩 글](/tech-blog/ko/llmops/speculative-decoding-easy-guide/)에서 큰 언어 모델이 왜 느린지를 도서관에 비유했습니다. 글자 하나를 쓸 때마다 선생님이 서고에서 아주 무거운 책 수백 권을 꺼내 책상에 전부 펼쳐야 하고 정작 읽는 시간은 눈 깜짝할 사이라는 이야기였죠. 시간의 대부분은 책을 나르는 데 들어갑니다.

투기 디코딩은 그 책을 **덜 자주 꺼내는** 방법이었습니다. 양자화는 다른 쪽을 공격합니다. **책 자체를 얇게 만듭니다.**

얇아지면 세 가지가 따라옵니다. 우선 서고에 더 많은 책이 들어갑니다. GPU 한 장에 안 올라가던 모델이 올라가고 남는 자리로 동시 접속자를 더 받습니다. 다음으로 나르는 시간이 줄어듭니다. 책이 절반 두께면 나르는 시간도 대략 절반이니 글자가 그만큼 빨리 나옵니다. 마지막 하나는 조건부입니다. **책을 얇은 상태 그대로 읽을 수 있다면** 읽는 속도까지 빨라집니다. 그런데 이 세 번째가 실제로는 가장 자주 어긋나고 이 글의 절반은 그 이야기입니다.

## 눈금이 16칸뿐인 자

모델의 가중치는 결국 숫자 수십억 개입니다. 그 숫자를 얼마나 촘촘한 자로 재서 적어 둘 것인가, 그게 양자화입니다.

16비트로 적으면 대략 6만 5천 개의 눈금 중 하나를 고를 수 있습니다. 8비트면 256개고 4비트면 **열여섯 개**입니다. 실제로 4비트 부동소수점 형식인 E2M1이 표현할 수 있는 값을 전부 적어 보면 이렇습니다.

```
0, 0.5, 1, 1.5, 2, 3, 4, 6  (그리고 각각의 음수)
```

이게 전부죠. 여덟 개의 양수와 여덟 개의 음수. 처음 보면 이걸로 언어 모델이 돌아간다는 게 믿기지 않습니다. 실제로 이 자만 가지고는 안 돌아갑니다.

## 그래서 자를 동네마다 새로 맞춥니다

여기가 4비트 양자화의 핵심이고 이것만 이해하면 포맷 이름표의 절반이 읽힙니다.

키를 재는데 눈금이 열여섯 칸뿐인 자를 들고 있다고 해 봅시다. 그 자로 성인과 갓난아기를 모두 재려면 눈금 간격이 너무 커서 아무것도 제대로 못 잽니다. 그런데 **초등학교 3학년 교실 하나만** 잰다면 이야기가 달라집니다. 그 교실 아이들 키는 130에서 145 사이에 몰려 있으니, 그 구간만 열여섯 칸으로 나누면 1센티 단위로 잴 수 있습니다.

양자화가 하는 일이 정확히 이겁니다. 가중치를 몇십 개씩 묶어서 **묶음마다 배율(스케일)을 따로 저장합니다.** 묶음 안의 값들은 서로 비슷하니 열여섯 칸으로도 충분히 구분됩니다.

그러면 남는 질문은 두 개입니다. 몇 개씩 묶을 것인가, 그리고 그 배율은 어떤 정밀도로 적을 것인가. **NVFP4와 MXFP4의 차이가 정확히 이 두 개입니다.**

MXFP4는 업계 표준화 단체 OCP가 정한 형식으로, **32개씩** 묶고 배율을 E8M0으로 적습니다. E8M0은 지수만 있고 가수가 없어서 **2의 거듭제곱 배율만** 표현합니다. 2배, 4배, 8배는 되는데 1.5배는 안 되죠. NVIDIA가 만든 NVFP4는 **16개씩** 묶어 더 잘게 자르고 배율을 FP8 E4M3으로 적어서 1.5배나 2.5배 같은 어중간한 배율도 씁니다. 여기에 텐서 전체에 걸리는 FP32 배율을 한 겹 더 얹습니다. 동네마다 자를 맞추고 도시 전체에도 한 번 더 맞추는 셈입니다.

대가는 용량입니다. 16개마다 8비트짜리 배율을 하나씩 붙이면 값 하나당 0.5비트가 추가되니, NVFP4는 이름은 4비트지만 실효 4.5비트입니다. 공짜인 정밀도는 없죠.

## 가중치는 쉽고 그날 들어온 재료는 어렵습니다

여기서 한 겹을 더 벗겨야 합니다. 모델 안에서 곱해지는 숫자는 두 종류입니다.

**가중치**는 학습이 끝나면 고정된 값입니다. 요리사가 외우고 있는 레시피 같은 것이라, 미리 천천히 들여다보고 최적의 자를 골라 둘 수 있습니다. 반면 **활성값**은 사용자가 무슨 말을 넣느냐에 따라 매번 새로 계산되는 값입니다. 그날 들어온 재료라 미리 볼 수가 없죠.

그런데 이 재료 중에 아주 가끔 유난히 큰 게 섞여 들어옵니다. 이걸 이상치(outlier)라고 부르는데, 다른 채널의 스무 배쯤 되는 값이 나오기도 합니다. 문제는 배율이 그 큰 값에 맞춰지면서 **나머지 평범한 값들이 전부 같은 칸에 뭉개진다**는 겁니다. 교실에 키 3미터인 사람이 한 명 서 있으면 나머지 아이들 키가 전부 "0칸"으로 기록되는 상황이죠.

그래서 표기법이 생겼습니다. `W4A16`은 가중치만 4비트로 줄이고 활성값은 16비트 그대로 둔다는 뜻입니다. `W8A8`은 둘 다 8비트, `W4A4`는 둘 다 4비트입니다. 뒤로 갈수록 어려워집니다.

이상치를 다루는 방법도 그래서 나왔습니다. SmoothQuant는 수학적으로 동등한 변형으로 **활성값의 어려움을 가중치 쪽으로 떠넘깁니다.** 가중치는 미리 볼 수 있으니 감당이 되죠. QuaRot이나 SpinQuant는 한 걸음 더 나가서, 출력이 바뀌지 않는 회전을 걸어 이상치를 여러 채널에 **골고루 흩어 버립니다.** 3미터인 사람 한 명 대신 조금씩 큰 사람 여럿으로 바꾸는 셈입니다. 이 회전 덕에 가중치와 활성값을 모두 4비트로 내리는 W4A4가 실용권에 들어왔습니다.

## 중요한 것만 촘촘하게 재면 됩니다

또 하나의 큰 발상은 이겁니다. **모든 층이 똑같이 중요하지는 않습니다.**

어떤 층은 4비트로 뭉개도 결과가 거의 안 바뀌는데, 어떤 층은 조금만 건드려도 모델이 헛소리를 시작합니다. 그러면 중요한 층만 정밀하게 남기고 나머지를 과감하게 줄이는 게 이깁니다. 요즘 나오는 방법들은 사실상 "어느 층이 중요한지 어떻게 알아내느냐"의 경쟁입니다.

llama.cpp의 **중요도 행렬(imatrix)** 은 가장 직관적인 답입니다. 대표 문장들을 실제로 모델에 통과시켜서 각 가중치가 출력에 얼마나 영향을 주는지 재고 그 결과를 양자화에 반영합니다. 이름에 `IQ`가 붙은 형식들은 애초에 이 행렬이 있다는 전제로 설계돼서, 없이 만들면 품질이 눈에 띄게 무너집니다.

**GPTQ**는 한 가중치를 양자화하면서 생긴 오차를 **남은 가중치에 나눠 보상시킵니다.** 2차 미분 정보를 써서 "이 값을 반올림해 손해를 봤으니 옆 값을 이만큼 옮겨 메우자"를 푸는 방식입니다. **AWQ**는 반대로 활성값 분포를 봅니다. 자주 크게 활성화되는 상위 1퍼센트 채널을 찾아 그 채널만 보호하는 방식이죠. 캘리브레이션 데이터에 덜 과적합해서 다른 도메인으로 옮겨도 잘 버티는 편입니다. **HQQ**는 아예 캘리브레이션 데이터 없이 가중치 분포만 보고 푸는데, 70B 모델을 5분 만에 양자화합니다.

**Unsloth Dynamic**은 이 발상을 파일 단위로 밀어붙인 경우입니다. 층마다 다른 비트를 배정하고 그 배정을 모델마다 다시 계산합니다. 이름 앞에 붙는 `UD-`가 그 표시입니다. 2026년 8월에 나온 Dynamic 3.0은 캘리브레이션 소스를 에이전틱 코딩과 다국어 대화까지 넓혔다고 밝히고 있습니다.

Unsloth 문서에서 눈여겨볼 만한 경고가 하나 있습니다. **1비트 파일은 에이전트나 툴 호출 용도로 쓰지 말라**는 겁니다. 2비트에서 그 아래로 내려가는 구간에 정확도가 급격히 무너지는 절벽이 있고 그 절벽은 짧은 문답보다 도구를 부르고 결과를 읽는 작업에서 먼저 드러납니다. 용량이 반가워서 제일 작은 파일을 받았다가 에이전트가 이상해진다면 대개 이 지점입니다.

맥에서 쓰는 MLX도 같은 흐름 위에 있습니다. `mlx_lm.dwq`는 원본 모델을 교사로 두고 **양자화되지 않는 파라미터(배율과 바이어스)만 증류로 미세조정합니다.** 고정된 규칙으로 자를 맞추는 대신 자 눈금 자체를 학습시키는 셈이라, 같은 4비트에서 손실이 줄어듭니다. `mlx_lm.dynamic_quant`는 층별 민감도를 재서 비트를 자동 배분합니다.

## 이름표를 그대로 믿으면 안 됩니다

여기서 실무자들이 자주 걸려 넘어집니다. `Q4_K_M`이라는 이름을 보면 "아, 4비트구나" 하게 되는데, **그렇지 않습니다.**

저희가 [Qwen2.5-0.5B의 Q4_K_M 파일을 실제로 열어 텐서 단위로 세어 본 적](/tech-blog/ko/llmops/gguf-quantization-internals/)이 있습니다. 진짜 4비트인 Q4_K 텐서는 파일 용량의 **6.1퍼센트**뿐이었고 파일 전체의 실효 비트폭은 4가 아니라 **6.16비트**였습니다. 나머지는 8비트와 6비트, 그리고 32비트 그대로 남은 정규화 파라미터였습니다. 이름표는 비트 수보다 레시피 이름에 가깝습니다.

같은 현상을 이 글을 쓰게 만든 그 저장소에서도 볼 수 있습니다. Unsloth가 올린 [Qwen3.8-Flash-Next의 GGUF](https://huggingface.co/unsloth/Qwen3.8-Flash-Next-GGUF)에는 UD가 붙은 변형이 일곱 개 있는데, 가장 작은 1비트 파일이 72.5GB이고 가장 큰 4비트 파일이 111GB입니다. **비트 수는 네 배 차이인데 용량은 1.5배 차이입니다.** 1비트라는 이름표는 "모든 가중치를 1비트로 눌렀다"는 뜻이 아닙니다. "제일 공격적인 배합"이라는 뜻입니다.

그래서 파일을 고를 때 이름표의 숫자로 용량을 추정하지 마시고 **표시된 파일 크기를 직접 보시는 게 맞습니다.** 그 숫자가 여러분의 RAM에 들어가느냐가 실제로 답해야 할 질문입니다.

## 가장 중요한 갈림길: 저장이냐 계산이냐

이제 이 글에서 제일 중요한 부분입니다. 여기를 놓치면 나머지 지식이 전부 헛돕니다.

가중치를 4비트로 저장했다고 해서 계산이 4비트로 일어나지는 않습니다. 대부분의 경우 GPU는 곱셈 직전에 그 4비트를 **다시 16비트로 펼쳐서** 계산합니다. 펼치는 그 작업 자체도 연산이니 공짜가 아니죠.

도서관 비유로 돌아가면 이렇습니다. 책을 진공 압축팩에 넣어 얇게 만들어 서고에 꽂았습니다. 나르기는 편해졌습니다. 그런데 책상에 놓고 읽으려면 매번 압축을 풀어서 원래 두께로 되돌려야 합니다. **나르는 시간은 줄었지만 푸는 시간이 새로 생겼습니다.**

이게 손해가 아니려면 조건이 있습니다. 나르는 시간이 병목일 때, 즉 동시 사용자가 적어서 GPU가 계산 능력을 남기고 있을 때는 이득입니다. 반대로 사람이 몰려서 GPU가 이미 계산으로 꽉 차 있으면, 압축 푸는 일이 그 꽉 찬 계산에 얹히니 손해가 납니다.

**진짜 4비트 계산은 다릅니다.** GPU 안에 4비트짜리 숫자를 압축된 상태 그대로 곱할 수 있는 회로가 들어 있으면, 풀 필요가 없습니다. 그러면 나르는 시간도 줄고 계산도 빨라집니다. 이 회로를 텐서코어라고 부르고 **어느 세대 GPU에 어느 정밀도용 텐서코어가 들어 있는지가 이 글의 핵심 표입니다.**

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="827quantizationeasyguide-1"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 563, "height": 618, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "A", "x": 225, "y": 24, "w": 120, "h": 46, "title": "4비트로 저장된 가중치"}, {"id": "B", "x": 194, "y": 148, "w": 181, "h": 52, "title": "이 GPU에 FP4 텐서코어가 있나"}, {"id": "C", "x": 311, "y": 292, "w": 142, "h": 46, "title": "곱하기 전에 16비트로 펼친다"}, {"id": "D", "x": 39, "y": 292, "w": 120, "h": 46, "title": "압축된 채로 곱한다"}, {"id": "E", "x": 411, "y": 416, "w": 120, "h": 46, "title": "메모리는 아낀다"}, {"id": "F", "x": 228, "y": 416, "w": 128, "h": 46, "title": "펼치는 연산이 새로 생긴다"}, {"id": "G", "x": 221, "y": 540, "w": 142, "h": 46, "title": "FP8보다 느려진다 0.81배"}, {"id": "H", "x": 24, "y": 416, "w": 149, "h": 46, "title": "메모리도 아끼고 계산도 빨라진다"}, {"id": "I", "x": 39, "y": 540, "w": 120, "h": 46, "title": "FP8 대비 1.28배"}], "edges": [{"src": "A", "dst": "B", "kind": "data", "line": [285, 70, 285, 148]}, {"src": "B", "dst": "C", "kind": "data", "label": "없다 H200 Ada", "curve": [[320, 200], [382, 246], [382, 246], [382, 292]], "off": "50%"}, {"src": "B", "dst": "D", "kind": "data", "label": "있다 B200 RTX50", "curve": [[217, 200], [99, 246], [99, 246], [99, 292]], "off": "50%"}, {"src": "C", "dst": "E", "kind": "data", "curve": [[415, 338], [471, 377], [471, 377], [471, 416]]}, {"src": "C", "dst": "F", "kind": "data", "curve": [[348, 338], [292, 377], [292, 377], [292, 416]]}, {"src": "F", "dst": "G", "kind": "data", "line": [292, 462, 292, 540]}, {"src": "D", "dst": "H", "kind": "data", "line": [99, 338, 99, 416]}, {"src": "H", "dst": "I", "kind": "data", "line": [99, 462, 99, 540]}]});
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
      const container = document.getElementById('827quantizationeasyguide-1')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '827quantizationeasyguide-1';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

*같은 4비트 파일이 어느 쪽으로 가느냐가 속도를 정합니다. 왼쪽으로 가면 메모리만 아끼고 느려지죠.*

구분하는 법도 알아 두시면 좋습니다. 서빙 엔진 로그에서 실제로 어떤 커널이 불렸는지를 보면 됩니다. `aten.mm.default` 같은 범용 행렬곱 커널로 떨어지고 있다면 압축을 풀어 계산하는 중이고 FP4 전용 커널 이름이 찍혀 있다면 압축된 채로 곱하는 중입니다. 저희는 **같은 실행에서 나온 커널 경로 증거 없이는 어떤 FP4 속도 수치도 인용하지 않는다**는 규칙을 두고 있는데, 이 함정에 여러 번 빠졌기 때문입니다.

특히 조심할 지점이 하나 더 있습니다. NVIDIA의 Model Optimizer로 PyTorch에서 양자화하면 그건 **시뮬레이션**입니다. NVIDIA 문서가 직접 그렇게 적어 두었습니다. 정확도를 확인하는 용도이고 실제 속도와 메모리 이득은 TensorRT-LLM이나 vLLM으로 내보낸 뒤에야 나옵니다. PyTorch에서 재고 "4비트인데 왜 안 빨라지지" 하면 원인이 여기 있습니다.

## 그래서 어느 GPU가 어느 자를 읽나

여기가 사람들이 제일 헷갈려 하는 표입니다. 정밀도를 **저장할 수 있느냐**와 **곱할 수 있느냐**는 다른 질문이고 아래는 곱할 수 있느냐입니다.

| 하드웨어 | FP8 텐서코어 | FP4 텐서코어 |
|---|---|---|
| RTX 4090, L40S (Ada) | 있음 | 없음 |
| H100, H200 (Hopper) | 있음 | **없음** |
| B200, GB200 (Blackwell 데이터센터) | 있음 | 있음 |
| RTX 50 시리즈 (Blackwell 컨슈머) | 있음 | 있음 |
| AMD MI300X (CDNA3) | 있음 | 없음 |
| AMD MI355X (CDNA4) | 있음 | 있음 (MXFP4) |
| Apple M1에서 M4까지 | 없음 | 없음 |
| CPU | 없음 | 없음 |

이 표에서 제일 자주 오해되는 칸은 **H100과 H200**입니다. 지금 국내에서 돌아가는 GPU 서버의 상당수가 이 세대인데, 성능이 훌륭한 최신 장비라서 "당연히 FP4도 되겠지" 하고 넘어가기 쉽습니다. 안 됩니다. FP4 텐서코어는 Blackwell부터죠.

그러니까 H200에서 4비트 모델을 올리면 무슨 일이 일어나느냐. 메모리는 확실히 아낍니다. 그런데 계산은 매번 펼쳐서 하니, 앞 절에서 말한 "푸는 시간"을 그대로 냅니다. **FP8보다 느려집니다.**

## 저희가 직접 재보고 세 번 놀랐습니다

위 문단은 추론이 아닙니다. 측정한 값입니다. Qwen3-Coder-30B-A3B를 같은 엔진(vLLM 0.27.1)에 올리고 GPU만 바꿔 가며 잰 값입니다. 동시성 32에서 128 구간의 중앙값 기준입니다.

**첫 번째 놀람은 4비트가 지는 쪽이었습니다.** H200에서 가중치만 4비트로 줄인 W4A16은 FP8 대비 0.81배에서 0.84배였습니다. 4비트 파일을 만들어 올렸는데 8비트보다 느립니다.

**두 번째가 더 이상했습니다.** 같은 W4A16을 최신 하드웨어인 B200에 올리면 나아질 것 같은데, **오히려 더 나빠집니다.** 0.76배에서 0.67배로 떨어집니다. 이유를 생각해 보면 당연합니다. 저정밀 텐서코어가 빨라질수록, 그 텐서코어를 안 쓰고 펼쳐서 계산하는 경로는 상대적으로 더 뒤처집니다. **4비트를 잘못 쓰면 최신 장비일수록 손해가 커집니다.**

같은 B200에서 NVFP4를 제대로 태우면 FP8 대비 1.22배에서 1.28배가 나옵니다. 같은 4비트 계열인데 W4A16은 0.67배, NVFP4는 1.28배입니다. **거의 두 배 차이가 포맷 이름이 아니라 커널 경로 하나에서 갈립니다.**

**세 번째 놀람은 품질 쪽이었습니다.** MXFP4가 NVFP4보다 HumanEval 점수가 높았습니다(0.9268 대 0.9024). 그런데 속도는 NVFP4의 0.66배에서 0.74배였습니다. 둘 다 B200의 네이티브 FP4 커널에 도달했는데, NVFP4는 TensorRT-LLM의 융합 MoE 커널을 받고 MXFP4는 CUTLASS 경로를 받습니다. **커널 성숙도가 갈랐다**는 뜻이라, 이건 언젠가 뒤집힐 수 있는 격차입니다.

| B200에서 FP8 대비 (동시성 32/64/128) | 처리량 비 | HumanEval |
|---|---|---|
| NVFP4 | 1.28 / 1.26 / 1.22 | 0.9024 |
| MXFP4 | 0.84 / 0.89 / 0.90 | 0.9268 |
| W4A16 (가중치만 4비트) | 0.76 / 0.71 / 0.67 | 0.9268 |

**그리고 진짜 상은 처리량이 아니라 전력이었습니다.** 다른 실험에서 bf16과 NVFP4를 포화 상태에서 맞붙였더니 처리량은 사실상 동률이었는데(23,415 대 23,771 tok/s, 1.5퍼센트 차이) 전력이 500W와 867W로 갈렸습니다. 토큰당 에너지로는 **1.71배**입니다. GPU를 임대해 쓰는 입장에서는 이 숫자가 처리량 배수보다 원가에 직접 들어옵니다.

마지막으로, 정직하게 덧붙여야 할 게 있습니다. 저희가 같은 기간에 찾은 **가장 큰 처리량 레버는 양자화가 아니었습니다.** 서빙 설정 두 개를 바로잡았더니 단일 스트림에서 18.77배가 움직였습니다. `torch.compile`이 꺼져 있었고 동시 처리 요청 수가 기본값 32에 묶여 있었습니다. 포맷 싸움이 1.2배에서 1.3배를 다투는 동안 설정 하나가 18배를 움직인 겁니다. **양자화를 만지기 전에 기본 설정부터 확인하시는 게 순서입니다.**

## 맥북이라면

맥은 이야기가 완전히 다릅니다. GPU 메모리와 시스템 메모리가 하나라서, 128GB 맥이면 128GB짜리 모델을 통째로 올릴 수 있습니다. 같은 값의 GPU 서버로는 어림도 없는 일이라 로컬 실험에서 맥이 강한 이유가 여기 있습니다.

대신 천장이 대역폭입니다. 글자를 한 자 만들 때마다 가중치를 전부 다시 읽어야 하니, **초당 몇 GB를 읽을 수 있느냐가 초당 몇 글자냐를 거의 그대로 정합니다.** M4 Pro가 273GB/s, M4 Max가 사양에 따라 410GB/s 또는 546GB/s, M3 Ultra가 819GB/s입니다. 4비트로 줄이면 읽을 양이 줄어드니 그만큼 빨라지고 이게 맥에서 양자화가 거의 항상 이기는 이유입니다.

포맷은 두 갈래입니다. **GGUF**는 llama.cpp 생태계의 파일 포맷이고 Ollama, LM Studio가 전부 이걸 씁니다. CPU에서도 돌고 윈도우와 리눅스에서도 돌아서 이식성이 최고입니다. **MLX**는 애플이 만든 프레임워크 전용이라 맥에서만 도는 대신 맥에 최적화돼 있습니다. 실측 비교에서 MLX가 생성 단계에서 밀집 모델 1.4배에서 1.6배, MoE 모델에서는 최대 3배까지 앞섰다는 보고가 있습니다. 다만 프롬프트를 처음 읽어 들이는 단계는 llama.cpp 쪽이 나은 경우가 있어서, 짧은 대화를 자주 새로 시작하는 패턴이면 차이가 줄어듭니다.

2026년에 하나 바뀐 게 있습니다. **M5부터 GPU 코어마다 행렬 연산 전용 유닛(Neural Accelerator)이 들어갔습니다.** 애플 자체 측정으로 첫 토큰이 나오기까지의 시간이 M4 대비 3.3배에서 4.06배 빨라졌습니다. 다만 기대를 정확히 조정하실 필요가 있습니다. **생성 속도 자체는 1.19배에서 1.27배**에 그쳤고 애플 문서가 그 이유를 명시합니다. 생성을 묶는 것은 계산이 아닙니다. 메모리 대역폭이고 M5의 대역폭은 M4의 120GB/s에서 153GB/s로 28퍼센트 올랐을 뿐이기 때문입니다. 대역폭이 오른 만큼 빨라진 셈이라 딱 맞아떨어집니다.

한 가지는 분명히 해 두겠습니다. 애플은 이 유닛이 **블록 스케일 FP4를 하드웨어로 가속한다고 명시하지는 않았습니다.** MXFP4 모델을 돌린 측정치를 실었을 뿐입니다. 그러니 "맥에도 이제 FP4 텐서코어가 생겼다"까지 나가면 근거보다 앞선 이야기입니다.

실무 권장은 단순합니다. 맥 전용으로 쓰실 거면 **MLX 4비트**가 기본 균형점입니다. 품질을 조금 더 짜내고 싶으면 `mlx_lm.dwq`로 만든 4비트를, RAM이 넉넉하면 6비트나 8비트를 쓰시면 됩니다. 다른 OS와 파일을 공유하거나 CPU로도 돌려야 하면 GGUF입니다. 용량 감은 4비트 기준으로 7B가 4에서 5GB, 30B가 20GB 안팎, 70B가 40에서 48GB 정도로 잡으시면 크게 어긋나지 않습니다.

## 서버라면

여러 사람이 동시에 쓰는 서빙이면 판단 기준이 하나 더 붙습니다. **배치가 작으냐 크냐**입니다.

배치가 작을 때는 GPU가 계산 능력을 남기고 메모리만 헐떡이는 상태라, 가중치를 덜 나르는 것 자체가 이득입니다. 이때는 AWQ나 GPTQ 같은 가중치 전용 4비트가 잘 듣습니다. 배치가 커지면 GPU가 계산으로 차기 시작하니 압축 푸는 비용이 부담이 되고 이때는 **가중치와 활성값을 모두 낮춘 포맷**이 맞습니다. Hopper 세대면 FP8이고, Blackwell 세대면 NVFP4까지 갑니다. NVIDIA의 공식 선택 가이드도 배치 4 이하면 W4A16, 16 이상이면 W8A8을 권합니다.

만드는 도구는 이제 어느 정도 정리됐습니다. vLLM 진영에서는 `llm-compressor`로 양자화해 `compressed-tensors` 포맷으로 내보내면 vLLM이 바로 읽습니다. AWQ와 GPTQ, bitsandbytes, AMD Quark, torchao도 전부 vLLM이 지원합니다.

```bash
# llm-compressor 로 FP8 W8A8 체크포인트 만들기 (개념 예시)
pip install llmcompressor
# 레시피에 QuantizationModifier(scheme="FP8_DYNAMIC") 를 걸고 oneshot 실행

# vLLM 으로 띄우기
vllm serve <양자화된-모델-경로> \
  --max-num-seqs 256 \
  --max-model-len 32768
```

`--max-num-seqs`를 굳이 적어 둔 이유가 있습니다. 앞에서 말한 18.77배 사고의 절반이 이 값이었습니다. 기본값에 묶여 있으면 동시 요청을 아무리 넣어도 천장이 열리지 않습니다.

띄우고 나서는 로그에서 **커널 이름**을 한 번 확인하시길 권합니다. 4비트 모델을 올렸는데 범용 행렬곱 커널이 찍히고 있으면, 메모리만 아끼고 속도는 손해 보는 상태입니다. 그 상태로 벤치를 돌려 "4비트가 별로네" 하고 접으면 잘못된 결론을 얻습니다.

## 품질은 정말 떨어지나요

솔직하게 말씀드리면 **저희 벤치마크로는 차이가 안 보입니다. 그리고 그게 안심할 이유는 아닙니다.**

위의 하드웨어 비교에서 다섯 개 팔의 HumanEval 점수가 전부 네 문제 이내에 몰렸습니다. 이 벤치의 해상도가 한 문제당 0.61퍼센트포인트인데, 같은 설정을 두 번 돌리면 그 정도는 그냥 움직입니다. Qwen3-30B-A3B에서도 저희 NVFP4가 MMLU 0.7743, bf16이 0.7779로 통계적으로 구분되지 않았습니다.

문제는 이런 벤치가 **짧은 문답**이라는 점입니다. 2025년 EMNLP에 나온 연구는 5개 양자화 기법을 여러 모델에 걸어 재고 이렇게 보고했습니다. 8비트는 손실이 0.8퍼센트 수준으로 사실상 무손실인데, **4비트는 긴 문맥 과제에서 최대 59퍼센트까지 떨어졌고 문맥이 길어질수록 손실이 커졌습니다.** 추론 과제를 따로 본 연구에서도 난이도에 비례하는 패턴이 나옵니다. W4A4 기준으로 GSM8K는 손실이 0인데 AIME는 4.17퍼센트 떨어졌습니다. 쉬운 문제는 뭉개도 맞히고 어려운 문제부터 틀린다는 뜻입니다.

다국어는 아직 논쟁 중입니다. 자동 지표로는 온건한데 사람이 평가하면 훨씬 크게 체감된다는 연구가 있고 반대로 영어로 만든 K-양자화가 다국어를 불균형하게 해치지는 않는다는 반증 연구도 있습니다. 결론이 안 났으니 결론이 난 것처럼 쓰지 않겠습니다.

그래서 저희 입장은 이렇습니다. **우리가 손실을 못 찾은 것과 손실이 없는 것은 다릅니다.** 그래서 다음 분기 양자화 실험의 1순위로 새 포맷 측정 대신 **대조군 하나 세우기**를 잡았습니다. 눈금자를 못 믿으면 그 눈금자로 잰 모든 것이 흔들리니까요. 여러분 쪽에서도 4비트를 쓰실 거면 **본인 워크로드에서, 특히 긴 문맥과 어려운 추론에서** 한 번은 직접 재보시길 권합니다.

## 고르는 순서

지금까지 이야기를 결정 순서로 압축하면 네 단계입니다.

**첫째, 어디서 돌릴지부터 정합니다.** 맥이면 MLX 또는 GGUF, CPU가 섞이면 GGUF, NVIDIA 서버면 그 GPU의 세대를 확인합니다. 이게 가능한 포맷의 절반을 이미 걸러냅니다.

**둘째, 그 하드웨어에 네이티브 경로가 있는 포맷을 고릅니다.** Blackwell이면 NVFP4, Hopper와 Ada면 FP8입니다. 배치가 작고 메모리가 빠듯하면 그때 AWQ나 GPTQ 같은 가중치 전용 4비트를 봅니다. **Hopper에서 4비트를 골랐다면 그건 속도가 아니라 메모리를 사는 선택**이라는 걸 알고 고르셔야 합니다.

**셋째, 용량은 파일 크기로 확인합니다.** `Q4`가 4비트를 뜻하지 않는다는 걸 앞에서 봤습니다.

{% raw %}
<!--
  animated-architecture-diagram - self-contained D3 embed template.
  HuggingFace research-article style: declarative NODES/EDGES/SEQ model,
  data(solid)/event(dashed) edges, hover-trace + tooltip, flow-dot animation
  along edge paths, replay button, scroll-into-view autoplay, reduced-motion +
  light/dark aware. The renderer injects window.__ARCH_SPEC__ at the marker.
  Format (D3 machinery + CSS) is owned by this committed template; the model
  only authors the JSON spec (content). See references/spec-schema.md.
-->
<div class="d3-arch" data-arch-root id="827quantizationeasyguide-2"></div>
<style>
  /* ---- Theme tokens (standalone; light default + dark override) ---- */
  .d3-arch {
    --page-bg: #ffffff;
    --surface-bg: #f7f8fa;
    --text-color: #1a1d21;
    --muted-color: #6b7280;
    --border-color: #d5d9e0;
    --primary-color: hsl(217 91% 55%); /* brand accent, swap for #1B4F72 etc. */
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
  /* Size to the spec's natural canvas: JS caps max-width at the spec width so a
     narrow/portrait diagram is never stretched to the article column (blur + giant
     vertical figures); wide diagrams scale down but keep min-width 760 + scroll. */
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
    const SPEC = ({"title": "", "ariaLabel": "", "width": 729, "height": 638, "legendTitle": "Legend", "hint": "Hover a node to trace its connections.", "groups": [], "nodes": [{"id": "S", "x": 402, "y": 24, "w": 120, "h": 46, "title": "어디서 돌릴 것인가"}, {"id": "M", "x": 577, "y": 148, "w": 120, "h": 46, "title": "맥"}, {"id": "P", "x": 402, "y": 148, "w": 120, "h": 46, "title": "CPU 가 섞인다"}, {"id": "N", "x": 218, "y": 148, "w": 120, "h": 46, "title": "NVIDIA 서버"}, {"id": "M1", "x": 577, "y": 275, "w": 120, "h": 46, "title": "MLX 4비트"}, {"id": "P1", "x": 402, "y": 275, "w": 120, "h": 46, "title": "GGUF"}, {"id": "N1", "x": 209, "y": 272, "w": 138, "h": 52, "title": "GPU 세대"}, {"id": "B1", "x": 310, "y": 419, "w": 120, "h": 46, "title": "NVFP4"}, {"id": "H1", "x": 117, "y": 416, "w": 138, "h": 52, "title": "배치 크기"}, {"id": "H2", "x": 199, "y": 560, "w": 177, "h": 46, "title": "AWQ 나 GPTQ 메모리를 사는 선택"}, {"id": "H3", "x": 24, "y": 560, "w": 120, "h": 46, "title": "FP8"}], "edges": [{"src": "S", "dst": "M", "kind": "data", "curve": [[522, 68], [637, 109], [637, 109], [637, 148]]}, {"src": "S", "dst": "P", "kind": "data", "line": [462, 70, 462, 148]}, {"src": "S", "dst": "N", "kind": "data", "curve": [[402, 67], [278, 109], [278, 109], [278, 148]]}, {"src": "M", "dst": "M1", "kind": "data", "line": [637, 194, 637, 275]}, {"src": "P", "dst": "P1", "kind": "data", "line": [462, 194, 462, 275]}, {"src": "N", "dst": "N1", "kind": "data", "line": [278, 194, 278, 272]}, {"src": "N1", "dst": "B1", "kind": "data", "label": "Blackwell", "curve": [[311, 324], [370, 370], [370, 370], [370, 419]], "off": "50%"}, {"src": "N1", "dst": "H1", "kind": "data", "label": "Hopper Ada", "curve": [[245, 324], [186, 370], [186, 370], [186, 416]], "off": "50%"}, {"src": "H1", "dst": "H2", "kind": "data", "label": "작다", "curve": [[222, 468], [288, 514], [288, 514], [288, 560]], "off": "50%"}, {"src": "H1", "dst": "H3", "kind": "data", "label": "크다", "curve": [[149, 468], [84, 514], [84, 514], [84, 560]], "off": "50%"}]});
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
      const container = document.getElementById('827quantizationeasyguide-2')
        || document.querySelector('.d3-arch[data-arch-root]:not([data-mounted])');
      if (!container || (container.dataset && container.dataset.mounted === 'true')) return;
      if (container.dataset) container.dataset.mounted = 'true';

      try {
        const uid = '827quantizationeasyguide-2';
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
        // Never upscale past the spec's natural width; keep 760px readability
        // floor (with horizontal scroll) only for diagrams that are actually wide.
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

*포맷 이름을 외우는 대신 이 순서로 내려오시면 됩니다. 갈림길이 세 개뿐이죠.*

**넷째, 커널 경로와 품질을 실제로 확인하고 나서 결론을 냅니다.** 로그에서 커널 이름을 보고, 본인 워크로드 중 가장 긴 문맥과 가장 어려운 과제로 한 번 재봅니다.

## 정리

양자화를 한 문장으로 줄이면 이렇습니다. **숫자를 성긴 자로 다시 적되, 자를 동네마다 새로 맞춰서 성긴 티가 안 나게 합니다.** 여기까지는 십 년 된 아이디어이고 지금 경쟁은 "어느 동네에 얼마나 촘촘한 자를 줄 것인가"에서 벌어집니다. imatrix, GPTQ, AWQ, Unsloth Dynamic, MLX DWQ가 전부 그 질문의 다른 답입니다.

그런데 실무에서 결과를 가르는 건 그 답들이 아닙니다. **하드웨어와의 궁합**입니다. 같은 4비트가 B200에서는 1.28배가 되고 H200에서는 0.81배가 됩니다. 그래서 포맷 이름을 외우는 것보다 "내 GPU에 이 정밀도용 텐서코어가 있는가, 그리고 엔진이 그 커널을 실제로 부르고 있는가" 두 질문을 챙기시는 편이 훨씬 남습니다.

흐름도 하나 짚어 볼 만합니다. 초기에는 벤더마다 다른 형식을 냈는데, 지금은 OCP의 마이크로스케일링 규격으로 수렴하는 중입니다. AMD의 최신 가속기가 같은 MXFP4를 네이티브로 얹었고 OpenAI가 gpt-oss를 아예 MXFP4 가중치로 배포했습니다. 애플까지 행렬 연산 유닛을 넣기 시작했고요. 몇 년 뒤에는 "이 포맷이 이 칩에서 되나"라는 질문 자체가 지금보다 덜 아플 겁니다. 다만 그때까지는, 그리고 특히 지금 국내에 깔린 Hopper 세대 장비 위에서는, 이 표를 한 번 확인하고 고르시는 게 몇 배를 좌우합니다.

저희 추론 제품인 **Metis**가 하는 일의 상당 부분이 이 결정을 테넌트가 직접 내리지 않아도 되게 만드는 것입니다. 어느 GPU 세대에 어느 포맷을 올릴지, 그 위에 어떤 서빙 설정을 걸어야 커널이 제 경로로 가는지는 한 번 제대로 정해 두면 그다음부터는 반복 작업이니까요. 그리고 앞에서 본 "4비트는 어려운 추론부터 무너진다"는 성질은 **Paxis** 쪽에서 특히 중요합니다. 에이전트는 한 요청 안에서 도구를 부르고 결과를 읽고 다시 판단하기를 반복하는데, 그 판단이 정확히 벤치마크가 잘 못 잡는 종류의 어려움이기 때문입니다. 비용을 아끼려고 비트를 낮췄다가 에이전트가 조용히 나빠지는 게 가장 알아채기 어려운 실패입니다.

이 글에 쓰인 저희 측정값은 전부 사내 B200과 H200에서 같은 엔진으로 잰 것이고 조건과 함께 원장에 남겨 두었습니다. 포맷별 깊은 이야기는 [같은 4비트가 FP8을 사이에 두고 반대편에 섭니다](/tech-blog/ko/llmops/nvfp4-vs-fp8-two-four-bits/)와 [Q4_K_M 안에는 Q4가 거의 없었다](/tech-blog/ko/llmops/gguf-quantization-internals/)에 더 자세히 적어 두었습니다.
