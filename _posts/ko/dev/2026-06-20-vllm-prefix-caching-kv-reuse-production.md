---
title: "vLLM Prefix Caching 실전 운용: KV Cache 재사용으로 추론 비용 절반 이하로"
excerpt: "vLLM의 Automatic Prefix Caching을 프로덕션에서 어떻게 설정하고 측정하는지, 실제 히트율과 비용 절감 수치를 중심으로 정리했습니다."
seo_title: "vLLM Prefix Caching KV Cache 재사용 프로덕션 가이드 - Thaki Cloud"
seo_description: "vLLM Automatic Prefix Caching 활성화 방법, PagedAttention KV 블록 해싱 원리, 히트율 60-85% 달성 조건, 멀티테넌트 SaaS에서의 실전 적용 패턴을 설명합니다."
date: 2026-06-20
last_modified_at: 2026-06-20
categories:
  - dev
tags: [vllm, prefix-caching, kv-cache, llm-serving, gpu, inference, kubernetes, pagedattention]
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/dev/vllm-prefix-caching-kv-reuse-production/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 7분

LLM 추론 비용에서 가장 쉽게 챙길 수 있는 최적화가 Prefix Caching이다. 시스템 프롬프트나 긴 컨텍스트가 요청마다 반복된다면, KV Cache를 재계산하지 않고 재사용하는 것만으로 GPU 시간을 절반 이하로 줄일 수 있다. vLLM은 이를 Automatic Prefix Caching(APC)이라는 이름으로 기본 탑재하고 있다.

## Prefix Caching이 왜 효과적인가

LLM 추론은 크게 prefill(입력 처리)과 decode(토큰 생성) 두 단계로 나뉜다. Prefix Caching은 prefill 단계에만 작용한다. 두 요청이 동일한 앞부분(prefix)을 공유하면, 그 구간의 KV(Key-Value) 상태를 다시 계산하지 않고 캐시에서 불러온다.

구체적인 수치를 보면 의미가 선명해진다. 캐시 히트 시 85-95% 비용 절감이 보고되고 있고, 에이전트 루프나 멀티테넌트 SaaS 환경에서 히트율 60-85%는 어렵지 않게 달성된다. 캐시 미스 시 패널티가 없으므로 켜두는 것이 기본 전략이다.

단, Prefix Caching은 decode 속도에는 영향을 주지 않는다. "첫 토큰 지연시간(TTFT)"은 개선되지만 "분당 토큰 수(TPS)"는 그대로다. 이 점을 혼동하면 기대치가 빗나간다.

## vLLM의 KV 블록 해싱 원리

vLLM은 PagedAttention을 기반으로 KV Cache를 고정 크기 블록 단위로 관리한다. Automatic Prefix Caching은 각 블록을 그 블록의 토큰과, 그 앞의 모든 토큰 시퀀스를 함께 해싱해서 식별한다.

```
블록 해시 = hash(이전 블록들의 해시 || 현재 블록의 토큰 ID들)
```

덕분에 두 요청이 접두사를 공유하는 한 정확히 어느 블록까지 재사용 가능한지 O(1)로 확인된다. 신규 요청이 들어오면 vLLM이 블록 테이블에서 해시가 일치하는 블록을 찾아 재사용한다. 일치하지 않는 블록부터 새로 prefill을 시작한다.

2026년 기준 프로덕션 추론 스택에서 PagedAttention은 사실상 표준이다. vLLM, SGLang, TensorRT-LLM 모두 기본 탑재하고 있으며, 이로 인해 KV Cache 낭비는 4% 미만으로 줄어들었다. 2-4배 처리량 향상은 이 구조에서 나온다.

## 활성화 방법

vLLM 서버 실행 시 `--enable-prefix-caching` 플래그 하나로 켜진다.

```bash
python -m vllm.entrypoints.openai.api_server \
  --model meta-llama/Llama-3-70b-instruct \
  --enable-prefix-caching \
  --max-model-len 32768 \
  --gpu-memory-utilization 0.90
```

Kubernetes 환경이라면 Deployment의 args 섹션에 추가한다.

```yaml
containers:
- name: vllm
  image: vllm/vllm-openai:latest
  args:
  - "--model"
  - "meta-llama/Llama-3-70b-instruct"
  - "--enable-prefix-caching"
  - "--max-model-len"
  - "32768"
  resources:
    limits:
      nvidia.com/gpu: "1"
```

## 히트율을 높이는 실전 패턴

### 시스템 프롬프트를 앞에 고정한다

히트율은 prefix의 길이와 안정성에 비례한다. 시스템 프롬프트가 매 요청마다 앞에 동일하게 붙는다면 그 구간의 KV Cache는 한 번만 계산된다. 시스템 프롬프트가 길수록, 그리고 자주 바뀌지 않을수록 절감폭이 커진다.

```python
messages = [
    {"role": "system", "content": SYSTEM_PROMPT},  # 항상 동일
    {"role": "user", "content": user_query},         # 요청마다 다름
]
```

### 에이전트 루프에서 컨텍스트를 누적한다

멀티스텝 에이전트는 이전 대화 히스토리를 누적하는 방식으로 prefix를 길게 유지한다. 2번째 스텝부터는 1번째 스텝까지의 KV가 캐시에서 재사용된다.

### RAG 문서를 앞부분에 배치한다

Retrieval-Augmented Generation에서 검색 결과를 앞에 두고 질문을 뒤에 붙이면, 동일 문서 셋을 참조하는 요청들 사이에서 캐시 히트가 발생한다. 문서 캐시 히트율 60-80%는 코드베이스 QA, 긴 문서 분석 같은 사용 패턴에서 현실적인 수치다.

## 히트율 모니터링

vLLM은 Prometheus 메트릭으로 캐시 히트율을 노출한다.

```promql
# 캐시 히트율
rate(vllm:cache_hit_tokens_total[5m]) 
/ rate(vllm:prompt_tokens_total[5m])
```

히트율이 낮을 때 먼저 확인할 것들:

- 시스템 프롬프트가 요청마다 조금씩 다른 문자열을 포함하고 있지 않은가 (타임스탬프, 세션 ID 등)
- GPU 메모리가 부족해서 캐시가 너무 자주 evict되지 않는가
- 블록 사이즈와 prefix 길이가 맞는가

## LMCache와의 비교

최근 vLLM Prefix Caching과 LMCache를 비교한 벤치마크([Level Up Coding, 2026년 4월](https://levelup.gitconnected.com/vllm-prefix-caching-vs-lmcache-benchmarking-kv-reuse-tradeoffs-944fbaf98b56))에 따르면, 단일 노드에서는 vLLM의 내장 APC가 충분한 성능을 보여준다. 분산 다중 노드 서빙이 필요한 경우에는 LMCache나 llm-d 같은 분산 KV 레이어를 별도로 올리는 방향이 검토된다. ThakiCloud 규모에서는 우선 내장 APC로 시작하고, 서빙 노드가 늘어나면 그때 분산 스토리지를 추가하는 순서가 현실적이다.

## 주의할 점

멀티테넌트 환경에서 서로 다른 테넌트 간 KV Cache 공유는 잠재적 정보 유출 경로가 될 수 있다. vLLM은 기본적으로 동일한 prefix 토큰이면 테넌트 구분 없이 캐시를 공유한다. 테넌트별 시스템 프롬프트가 다르면 자연히 분리되지만, 공유 시스템 프롬프트를 쓰면서 테넌트 데이터를 컨텍스트에 넣는 구조라면 신중하게 설계해야 한다.

Prefix Caching을 쓸 때 `--enable-chunked-prefill`을 함께 켜면 처리량이 더 오른다. 두 기능은 잘 맞물린다.

## 정리

vLLM Prefix Caching은 플래그 하나로 켜지는 무료 최적화다. 히트율 60% 이상이 나오는 워크로드에서는 GPU 비용을 절반 이하로 줄일 수 있다. 시스템 프롬프트 고정, 에이전트 루프 컨텍스트 누적, RAG 문서 앞배치가 히트율을 높이는 세 가지 패턴이다. 켜두지 않을 이유가 없다.
