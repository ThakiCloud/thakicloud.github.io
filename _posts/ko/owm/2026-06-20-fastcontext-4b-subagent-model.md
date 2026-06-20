---
title: "FastContext-1.0-4B-SFT: 코딩 에이전트 저장소 탐색 전용 4B 서브에이전트 모델"
excerpt: "Microsoft가 공개한 FastContext-1.0-4B-SFT는 Qwen3-4B를 파인튜닝한 코딩 에이전트 서브에이전트 모델이다. READ/GLOB/GREP 세 가지 도구만 써서 저장소를 탐색하고 근거를 찾는다. 262K 컨텍스트, MIT 라이선스."
seo_title: "FastContext-1.0-4B-SFT 코딩 에이전트 서브에이전트 모델 가이드 - ThakiCloud"
seo_description: "Microsoft FastContext-1.0-4B-SFT 아키텍처(Qwen3-4B 기반, 262K 컨텍스트), arXiv:2606.14066, SWE-bench 벤치마크, vLLM 서빙, subagent-model-routing 직결."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - owm
tags:
  - fastcontext
  - microsoft
  - qwen3
  - coding-agent
  - subagent
  - repository-exploration
  - long-context
  - mit
  - vllm
  - self-hosting
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/owm/fastcontext-4b-subagent-model/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 7분

![FastContext-1.0-4B-SFT 개념도](/assets/images/fastcontext-4b-subagent-model-hero.png)

## 무엇이 새로운가

Microsoft가 `microsoft/FastContext-1.0-4B-SFT`를 공개했습니다. 논문은 arXiv:2606.14066 "FastContext: Training Efficient Repository Explorer for Coding Agents"입니다. 이 모델의 역할은 단 하나입니다. 코딩 에이전트가 어떤 태스크를 받았을 때, 저장소 전체를 훑어 관련 파일과 코드 조각을 찾아오는 서브에이전트입니다.

설계가 단순해서 좋습니다. 도구는 READ, GLOB, GREP 세 가지만 씁니다. 파일을 읽고, 경로를 찾고, 텍스트를 검색합니다. 쓰기 작업은 없습니다. 메인 에이전트가 코드를 작성하고 판단할 때, FastContext는 그 메인 에이전트에게 필요한 컨텍스트를 긁어오는 역할만 합니다.

왜 전용 모델이 필요한가에 대해 설명드리겠습니다. SWE-bench 같은 코딩 에이전트 벤치마크에서 저장소 탐색 단계가 전체 토큰 소비의 상당 부분을 차지합니다. 메인 모델(예: GPT-5.4, GLM-5.1)이 직접 탐색을 수행하면 비싸고 느립니다. 4B 소형 모델에 탐색을 위임하면 비용을 줄이면서 전체 파이프라인 정확도를 높일 수 있습니다.

## 아키텍처

기반 모델은 `Qwen/Qwen3-4B-Instruct-2507`입니다. 파라미터는 4B이고 컨텍스트 길이는 262K 토큰입니다. dtype은 BF16입니다.

학습은 SFT(Supervised Fine-Tuning)와 RL(GRPO 기반)을 함께 썼습니다. 학습 데이터는 세 가지 소스로 구성된다고 논문과 모델 카드에 명시되어 있습니다.

- `parallel_toolcalls`: 첫 번째 턴에서 여러 파일을 병렬로 넓게 탐색하는 패턴
- `multiturn_traj`: 여러 턴에 걸쳐 증거를 수집하는 패턴
- `linerange`: 정확한 라인 범위를 인용하는 패턴

이 세 소스는 실제 에이전트의 런타임 행동을 반영한 것입니다. 탐색 방식이 맥락에 따라 달라져야 한다는 점을 학습 데이터 설계에 녹였습니다.

모델 패밀리에는 FC-4B-SFT(이 모델), FC-4B-RL, FC-30B-SFT가 있습니다. FC-30B-SFT는 Qwen3-Coder-30B-A3B 기반입니다.

## 벤치마크

모델 카드와 논문에 기재된 수치는 메인 에이전트에 FastContext를 서브에이전트로 붙였을 때의 변화량입니다. 탐색 없이 동작하는 기준(w/o Explore)과 비교한 결과입니다.

| 메인 에이전트 | 벤치마크 | 정확도 변화 | 토큰 변화 |
|---|---|---|---|
| GPT-5.4 | SWE-bench Multilingual | +3.3% | -26.0% |
| GLM-5.1 | SWE-bench Pro | +5.0% | 미상 |
| Kimi-K2.6 | SWE-bench Multilingual | +2.0% | 미상 |

정확도가 오르고 토큰이 줄었다는 것이 핵심입니다. GPT-5.4 기준으로 26% 토큰 절감은 비용 관점에서 의미 있는 숫자입니다. 메인 에이전트가 넓게 검색하던 부분을 4B 모델이 효율적으로 대신하면서 메인 에이전트는 실제 코드 작성과 판단에만 집중할 수 있습니다.

코드 저장소는 https://github.com/microsoft/fastcontext에 공개되어 있습니다.

## 서빙과 배포

MIT 라이선스입니다. 상업적 사용, 수정, 배포가 자유롭습니다.

4B 모델이므로 자원 요구량이 낮습니다. BF16 기준 약 8GB VRAM이면 A100 40GB, A10G 24GB, RTX 4090 24GB 등에서 동작합니다. vLLM, SGLang을 공식 지원하며 llama.cpp, Ollama, LM Studio, Jan용 양자화 변형도 있습니다.

vLLM 서빙은 단일 GPU로 충분합니다.

```bash
vllm serve microsoft/FastContext-1.0-4B-SFT \
  --dtype bfloat16 \
  --max-model-len 131072
```

262K 전체 컨텍스트를 쓰려면 GPU VRAM과 KV 캐시 메모리 계산이 필요합니다. 실제 저장소 탐색 태스크에서 필요한 컨텍스트 길이는 대부분 그보다 짧으므로 먼저 실제 사용 패턴의 p95 길이를 측정하고 `max-model-len`을 정하는 것이 합리적입니다.

## ThakiCloud 관점과 subagent-model-routing 연결

**에이전트 파이프라인의 서브에이전트 역할 분리.** ThakiCloud 플랫폼에서 운영 중인 `subagent-model-routing` 규칙은 탐색/파일 읽기 태스크에 Haiku 같은 소형 모델을 쓰도록 명시하고 있습니다. FastContext는 그 역할에 딱 맞는 전용 모델입니다. 메인 코딩 에이전트로 claude-sonnet이나 다른 대형 모델을 쓰고, 저장소 탐색 서브에이전트로 FastContext-4B를 온프렘 vLLM 엔드포인트로 붙이는 구성이 가능합니다.

```yaml
# Kueue WorkloadPriorityClass 예시
apiVersion: kueue.x-k8s.io/v1beta1
kind: LocalQueue
metadata:
  name: fastcontext-inference
  namespace: ai-agents
spec:
  clusterQueue: small-gpu-queue
```

4B 모델은 자원이 작아서 Kueue의 소형 GPU 큐에 배치하면 비용 효율이 좋습니다. 메인 에이전트가 대형 GPU 큐를 쓰는 동안 FastContext는 별도 소형 큐에서 독립적으로 동작합니다.

**비용 절감 경로.** 현재 ThakiCloud 플랫폼에서 코딩 에이전트 태스크의 상당 비율이 저장소 탐색에 토큰을 쓰고 있다면, FastContext 도입으로 메인 에이전트 토큰 소비를 줄일 수 있습니다. SWE-bench 기준 26% 토큰 절감이 실제 워크로드에서 얼마나 재현되는지는 자체 코드베이스 특성에 따라 달라지므로 파일럿 측정이 선행되어야 합니다.

MIT 라이선스로 온프렘 배포와 파인튜닝 모두 가능합니다. 특정 사내 코드베이스 언어나 구조에 맞게 추가 파인튜닝을 하면 탐색 정확도를 더 높일 수 있습니다. 학습 데이터 형식(`parallel_toolcalls`, `multiturn_traj`, `linerange`)이 공개되어 있으므로 사내 저장소 탐색 트레이스로 유사 데이터셋을 만드는 것도 가능합니다.
