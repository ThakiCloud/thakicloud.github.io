---
title: "vLLM + Evalchemy 벤치마킹 완벽 최적화 가이드: 동적 배칭부터 실전 튜닝까지"
excerpt: "동적 배칭과 요청 큐를 이해하여 신뢰할 수 있는 LLM 성능 측정을 위한 서버-클라이언트 통합 최적화 전략"
date: 2025-06-14
categories: 
  - llmops
  - dev
tags: 
  - vllm
  - evalchemy
  - benchmarking
  - dynamic-batching
  - performance-optimization
  - llm-evaluation
author_profile: true
toc: true
toc_label: "목차"
published: false
---

## 소개

"그냥 돌려도" 결과는 나옵니다. 하지만 대규모 언어 모델(LLM)의 성능을 정확하게 측정하고, 실제 서비스 환경과 유사한 부하 상황을 시뮬레이션하려면 몇 가지 핵심 요소를 반드시 이해해야 합니다. 부정확한 벤치마크는 잘못된 모델 선택으로 이어질 수 있기 때문입니다.

이 가이드에서는 **vLLM의 동적 배칭(Dynamic Batching)**과 **요청 큐(Request Queue)** 시스템을 이해하고, Evalchemy와 같은 평가 도구를 사용할 때 서버와 클라이언트 양쪽에서 정확도, 속도, 안정성을 극대화하는 통합 최적화 전략을 제공합니다.

### 왜 튜닝이 필요한가?

LLM 서버는 한 번에 하나의 요청만 처리하지 않습니다. vLLM과 같은 고성능 서빙 엔진은 다음과 같은 메커니즘으로 동작합니다:

- **비동기 요청 큐**: 요청을 즉시 큐에 저장하고 연결 유지
- **동적 배칭**: 서로 다른 길이의 요청들을 효율적으로 묶어 처리
- **Prefill-First 정책**: 새 요청의 첫 토큰 생성 시간(TTFT) 최소화

따라서 서버의 배치·큐 파라미터와 클라이언트의 요청량, 배치 크기를 조율하지 않으면 다음 문제가 발생합니다:

| 문제 | 결과 |
|:-----|:-----|
| **부정확한 속도 측정** | 대기 큐 지연을 고려하지 못해 모델 순수 추론 속도 오해 |
| **결과 비일관성** | 서버 상태에 따라 결과가 달라져 공정한 비교 불가 |
| **불안정한 환경** | 429 오류나 메모리 부족으로 테스트 중단 |

## vLLM 핵심 메커니즘 이해

### 동적 배칭과 요청 큐 시스템

vLLM의 핵심 차별화 요소는 **continuous batching**과 **비동기 요청 큐**입니다.

**비동기 요청 처리 흐름:**

1. HTTP 요청 수신 → 즉시 `asyncio.Queue`에 저장
2. 요청 상태: **waiting**(대기) ↔ **running**(GPU 처리 중)
3. 스케줄러가 매 토큰 생성마다 상태 동적 관리

**과부하 상황 대응:**

- GPU 토큰 버짓 초과 → 다음 스텝에서 재시도
- 큐 길이 한계 초과 → HTTP 429/503 응답
- 긴 요청 → Partial Prefill로 점진적 처리

### 동적 배칭의 장점

기존 정적 배칭과 달리, vLLM은 서로 다른 프롬프트/생성 길이를 같은 GPU 커널에서 효율적으로 처리:

- **처리량(TPS) 극대화**: GPU 활용률 향상
- **TTFT 최소화**: 새 요청 우선 처리
- **메모리 효율성**: KV Cache 동적 할당

## 서버 측 최적화 전략

### vLLM 필수 파라미터

| 파라미터 | 설명 | 권장값 | 효과 |
|:---------|:-----|:-------|:-----|
| `--max-num-batched-tokens` | 배치당 최대 토큰 수 | 8,000-16,000 | TPS↑, TTFT↑ 트레이드오프 |
| `--enable-chunked-prefill` | 청크 단위 prefill 활성화 | 활성화 권장 | 대기 큐↓, 메모리 효율↑ |
| `--scheduling-policy priority` | 우선순위 기반 스케줄링 | priority | 서비스 레벨 차별화 |
| `--concurrency-limit` | 최대 동시 요청 수 | 32-128 | 429 오류 방지 |
| `--gpu-memory-utilization` | GPU 메모리 사용률 | 0.85-0.95 | OOM 방지 |

### 고성능 vLLM 서버 실행 예시

```bash
# 최적화된 vLLM 서버 설정
vllm serve deepseek-ai/deepseek-r1-0528-qwen3-8b \
  --host 0.0.0.0 \
  --port 8000 \
  --api-key your-secret-key \
  --tensor-parallel-size 4 \
  --max-model-len 4096 \
  --max-num-batched-tokens 16384 \
  --max-num-seqs 256 \
  --enable-chunked-prefill \
  --scheduling-policy priority \
  --gpu-memory-utilization 0.9 \
  --swap-space 4 \
  --disable-log-requests \
  --quantization awq
```

### LM Studio 사용 시 주의사항

LM Studio는 vLLM과 달리 자체 큐나 동적 배칭이 없으므로:

- **엔드포인트**: `/v1` 포함 필수
- **모델 ID**: 밑줄 형식 확인 (예: `deepseek-ai_deepseek-r1-...`)
- **API 키**: 더미 키 설정 (`LM_STUDIO_API_KEY=dummy`)
- **동시 요청**: 애플리케이션 레벨에서 제한 필요

```bash
# LM Studio 연동 설정
export LM_STUDIO_API_BASE="http://127.0.0.1:1234/v1"
export LM_STUDIO_API_KEY="dummy"
```

## 클라이언트 측 최적화 전략

### 빠른 사전 확인

본격적인 벤치마크 전 연결 테스트:

```bash
# Sanity Check - 연결/포맷 오류 즉시 검출
python -m eval.eval \
  --model curator \
  --tasks hellaswag \
  --limit 1 \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://localhost:8000/v1"
```

### 시나리오별 요청 전략

| 시나리오 | 권장 설정 | 이유 |
|:---------|:----------|:-----|
| **대규모 벤치마크 (>1,000샘플)** | `--batch_size auto:8` 또는 수동 `4-8` | 서버-클라이언트 배치 중복 방지, 안정성 확보 |
| **실서비스 부하 시뮬레이션** | `--batch_size 1` + 멀티프로세스 | 진정한 동시 요청으로 큐/스케줄러 동작 관찰 |
| **빠른 성능 테스트** | `--batch_size auto:16` + 캐시 활용 | 처리량 극대화, 반복 테스트 효율성 |

### 캐시와 재현성 관리

**부하 측정 vs 정밀 비교:**

```bash
# 실제 서버 부하 측정 (캐시 없음)
python -m eval.eval \
  --model curator \
  --tasks MMLU,HellaSwag \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --seed 42 \
  --output_path logs/load_test.json

# 정밀 성능 비교 (캐시 활용)
python -m eval.eval \
  --model curator \
  --tasks MMLU,HellaSwag \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --use_cache ./cache \
  --seed 42 \
  --output_path logs/performance_test.json
```

## 모니터링과 성능 진단

### 핵심 모니터링 지표

vLLM은 Prometheus 형식 메트릭을 `/metrics` 엔드포인트로 제공:

| 지표 | 의미 | 임계값 | 대응 방안 |
|:-----|:-----|:-------|:----------|
| `vllm:num_requests_waiting` | 대기 큐 길이 | <10 | `max-num-batched-tokens` 증가 |
| `time_to_first_token_seconds` | 첫 토큰 지연 | <2초 | 큐 길이 모니터링, 스케줄링 정책 조정 |
| `vllm:gpu_cache_usage_perc` | KV Cache 사용률 | <90% | 모델 길이 제한, 메모리 최적화 |
| `vllm:avg_generation_throughput_toks_per_s` | 초당 토큰 생성 | 모델별 상대평가 | 배치 크기 조정 |

### Grafana 대시보드 설정

```yaml
# prometheus.yml
scrape_configs:
  - job_name: 'vllm'
    static_configs:
      - targets: ['localhost:8000']
    metrics_path: '/metrics'
    scrape_interval: 5s
```

## 권장 워크플로우: 5단계 최적화

### 1단계: 시스템 워밍업

```bash
# JIT 컴파일과 CUDA 그래프 캐싱
for i in {1..5}; do
  curl -X POST http://localhost:8000/v1/chat/completions \
    -H "Content-Type: application/json" \
    -H "Authorization: Bearer your-secret-key" \
    -d '{"model":"deepseek-ai/deepseek-r1-0528-qwen3-8b","messages":[{"role":"user","content":"Hello"}],"max_tokens":10}'
done
```

### 2단계: 연결 테스트

```bash
# 빠른 연결/포맷 확인
python -m eval.eval --model curator --tasks hellaswag --limit 1 \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://localhost:8000/v1"
```

### 3단계: 규모별 2단계 테스트

```bash
# 소규모 테스트 (100개 샘플)
python -m eval.eval --model curator --tasks MMLU --limit 100 \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --batch_size 8 --output_path logs/small_scale.json

# 전체 테스트
python -m eval.eval --model curator --tasks MMLU \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --batch_size 8 --output_path logs/full_scale.json
```

### 4단계: 실시간 최적화

Prometheus 메트릭을 모니터링하며 파라미터 조정:

| 관찰된 문제 | 조정 방향 |
|:------------|:----------|
| 대기 큐 길이 증가 | `--max-num-batched-tokens` 증가 |
| TTFT 과도한 증가 | `--enable-chunked-prefill` 활성화 |
| GPU 활용률 저조 | 클라이언트 `--batch_size` 증가 |
| 메모리 부족 | `--gpu-memory-utilization` 감소 |

### 5단계: 일관성 검증

동일한 조건에서 여러 모델 비교:

```bash
# 공정한 비교를 위한 설정 고정
export EVAL_SEED=42
export EVAL_CACHE_DIR="./eval_cache"
export EVAL_BATCH_SIZE=8

# 모델별 순차 평가
for model in "deepseek-ai/deepseek-r1-0528-qwen3-8b" "Qwen/Qwen2.5-7B-Instruct"; do
  python -m eval.eval --model curator --tasks MMLU,HellaSwag \
    --model_name "openai/$model" \
    --seed $EVAL_SEED \
    --use_cache $EVAL_CACHE_DIR \
    --batch_size $EVAL_BATCH_SIZE \
    --output_path "logs/${model//\//_}_results.json"
done
```

## 실전 튜닝 팁

### TTFT vs TPS 트레이드오프 최적화

**배치 크기별 성능 특성:**

| 배치 설정 | TPS | TTFT | 사용 케이스 |
|:----------|:----|:-----|:------------|
| 작은 배치 (1-4) | 낮음 | 빠름 | 인터랙티브 서비스 |
| 중간 배치 (8-16) | 보통 | 보통 | 일반적 벤치마크 |
| 큰 배치 (32+) | 높음 | 느림 | 대량 배치 처리 |

### 서비스 레벨별 우선순위 설정

```json
{
  "model": "deepseek-ai/deepseek-r1-0528-qwen3-8b",
  "messages": [{"role": "user", "content": "Urgent question"}],
  "priority": 1,  // 낮을수록 높은 우선순위
  "max_tokens": 100
}
```

### 리소스 관리 최적화

```bash
# 환경 변수 최적화
export HF_HUB_CACHE=/nvme/cache          # 고속 SSD 활용
export HF_TOKEN=<your_token>             # Private 모델 접근
export CUDA_VISIBLE_DEVICES=0,1,2,3     # GPU 선택
export VLLM_ATTENTION_BACKEND=FLASHINFER # 메모리 효율성 향상
```

## 성능 벤치마크 결과 해석

### 표준 출력 분석

```text
python -m eval.eval --model curator --tasks MMLU,HellaSwag \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --batch_size 8 --output_path logs/results.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% • Time Elapsed 0:15:32
Requests: Total: 1,247 • Success: 1,247✓ • Failed: 0✗ • Req/min: 4.8

                            Final Benchmark Results
╭─────────────────────────┬──────────────────────────────────────────────────╮
│ Task                    │ Score                                            │
├─────────────────────────┼──────────────────────────────────────────────────┤
│ MMLU                    │ 0.7234 (72.34%)                                 │
│ HellaSwag               │ 0.8456 (84.56%)                                 │
│ Average                 │ 0.7845 (78.45%)                                 │
├─────────────────────────┼──────────────────────────────────────────────────┤
│ Requests per Minute     │ 4.8                                              │
│ Tokens per Second       │ 156.7                                            │
╰─────────────────────────┴──────────────────────────────────────────────────╯
```

### 성능 지표 기준

| 지표 | vLLM (좋음) | CPU (일반) | 해석 |
|:-----|:------------|:-----------|:-----|
| **Requests per Minute** | 5+ | 0.5-1 | API 처리 효율성 |
| **Tokens per Second** | 100+ | 10-20 | 생성 속도 |
| **Success Rate** | 99%+ | 99%+ | 안정성 |
| **Average TTFT** | <2초 | <10초 | 응답성 |

## 문제 해결 가이드

### 자주 발생하는 오류와 해결책

| 오류 | 원인 | 해결책 |
|:-----|:-----|:-------|
| **CUDA OOM Error** | GPU 메모리 부족 | `--gpu-memory-utilization 0.8`, `--max-model-len` 감소 |
| **Connection Refused** | 서버 미실행/포트 충돌 | 서버 상태 확인, 포트 변경 |
| **429 Too Many Requests** | 동시 요청 초과 | `--concurrency-limit` 증가, 클라이언트 `--batch_size` 감소 |
| **Model Loading Failed** | 모델 경로/권한 오류 | HuggingFace 토큰 확인, 모델명 검증 |

### 성능 최적화 체크리스트

- [ ] vLLM 서버 워밍업 완료
- [ ] `--max-num-batched-tokens` 최적화 (8K-16K)
- [ ] `--enable-chunked-prefill` 활성화
- [ ] 클라이언트 배치 크기 조정 (4-8)
- [ ] Prometheus 모니터링 설정
- [ ] 캐시 및 시드 관리 정책 수립
- [ ] 다중 모델 비교 환경 통일

## 결론

vLLM과 Evalchemy를 활용한 LLM 벤치마킹은 단순히 스크립트를 실행하는 것에서 끝나지 않습니다. **동적 배칭과 요청 큐 시스템**을 이해하고, **서버-클라이언트 통합 최적화**를 통해 다음 세 가지 축의 균형을 맞춰야 합니다:

1. **서버 측 배치 토큰과 스케줄러** → 처리량 최적화
2. **클라이언트 배치 크기와 요청 패턴** → 실제 사용 환경 시뮬레이션
3. **캐시와 시드 관리** → 재현 가능한 벤치마크 환경

### 핵심 성과

- **정확성**: 실제 서비스 부하와 유사한 조건에서 측정
- **효율성**: GPU 활용률 극대화로 20-50배 속도 향상
- **안정성**: 체계적인 모니터링으로 일관된 결과 보장
- **재현성**: 표준화된 설정으로 공정한 모델 비교

이 가이드를 따라 설정하면, 실제 서비스 부하에 근접한 조건에서 신뢰할 수 있는 성능 측정 결과를 얻을 수 있습니다. Prometheus 메트릭을 통한 실시간 모니터링으로 지연 원인을 즉시 파악하고 대응하여, 벤치마크의 정확도와 효율성을 동시에 확보하세요! 🚀

---

**참고 자료:**

- [vLLM 공식 문서](https://docs.vllm.ai/)
- [Evalchemy API 가이드](https://docs.bespokelabs.ai/)
- [Prometheus 모니터링 설정](https://prometheus.io/docs/)
- [LM Evaluation Harness](https://github.com/EleutherAI/lm-evaluation-harness)
