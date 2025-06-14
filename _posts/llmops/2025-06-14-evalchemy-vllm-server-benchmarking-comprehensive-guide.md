---
title: "vLLM 서버로 고성능 모델 벤치마킹하기: Evalchemy 완벽 실전 가이드"
excerpt: "vLLM 서버와 Evalchemy를 연동하여 대규모 언어 모델을 효율적으로 평가하는 방법과 50+ 벤치마크 태스크 총정리"
date: 2025-06-14
categories: 
  - llmops
  - dev
tags: 
  - vllm
  - evalchemy
  - benchmarking
  - model-evaluation
  - gpu-inference
  - performance-optimization
author_profile: true
toc: true
toc_label: "목차"
---

## 소개

GPU 서버에서 vLLM으로 모델을 고속 실행하면서 체계적인 벤치마크를 원하셨나요? **vLLM + Evalchemy** 조합이면 OpenAI API와 동일한 인터페이스로 50+ 종류의 평가 태스크를 실행할 수 있습니다. 

이 가이드에서는 vLLM 서버 설정부터 Evalchemy 연동, 그리고 수학 추론(MATH500), 코딩(HumanEval), 과학 지식(MMLU), 상식 추론(HellaSwag) 등 다양한 벤치마크 태스크를 실행하는 전 과정을 다룹니다. Evalchemy의 `Curator` 모델 어댑터와 `LM-Eval-Harness`를 통해 REST API로 모델을 호출하고 평가하는 전 과정을 정리합니다. CLI 플래그에서 `--model curator` 또는 `--model openai`만 바꿔주면 GPT-4o, Claude 3, Gemini는 물론, 자체 vLLM 서버나 100종 이상의 API 모델을 설치 없이 동일한 방식으로 평가할 수 있다는 것이 핵심입니다.

### 핵심 장점

- **20배 빠른 추론 속도**: CPU 기반 대비 GPU vLLM의 압도적 성능
- **확장 가능한 배치 처리**: 동시 요청 처리로 처리량 극대화
- **표준화된 평가**: LM-Eval-Harness 기반 일관된 평가 환경
- **50+ 벤치마크 지원**: 다양한 도메인의 종합적 모델 평가

## vLLM 서버 설정 및 실행

### 환경 준비

```bash
# vLLM 설치 (CUDA 환경 필요)
pip install vllm

# 필요한 의존성 설치
pip install transformers torch accelerate
```

### vLLM 서버 실행

#### 표준 설정으로 서버 시작

```bash
# 기본 vLLM 서버 실행
vllm serve microsoft/DialoGPT-medium \
  --host 0.0.0.0 \
  --port 8000 \
  --api-key your-secret-key
```

#### 고성능 최적화 설정

```bash
# 성능 최적화된 vLLM 서버 실행
vllm serve deepseek-ai/deepseek-r1-0528-qwen3-8b \
  --host 0.0.0.0 \
  --port 8000 \
  --api-key your-secret-key \
  --tensor-parallel-size 2 \
  --max-model-len 8192 \
  --max-num-batched-tokens 8192 \
  --enable-chunked-prefill \
  --gpu-memory-utilization 0.9 \
  --disable-log-requests
```

#### 주요 파라미터 설명

| 파라미터 | 설명 | 권장값 |
|:---------|:-----|:-------|
| `--tensor-parallel-size` | GPU 병렬 처리 개수 | GPU 개수에 맞춰 설정 |
| `--max-model-len` | 최대 시퀀스 길이 | 8192 또는 4096 |
| `--max-num-batched-tokens` | 배치 처리 최대 토큰 | 8192-16384 |
| `--enable-chunked-prefill` | 청크 단위 prefill 활성화 | 처리량 향상 |
| `--gpu-memory-utilization` | GPU 메모리 사용률 | 0.85-0.95 |

### 서버 상태 확인

```bash
# 모델 목록 확인
curl http://localhost:8000/v1/models

# 간단한 채팅 테스트
curl -X POST http://localhost:8000/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer your-secret-key" \
  -d '{
    "model": "deepseek-ai/deepseek-r1-0528-qwen3-8b",
    "messages": [{"role": "user", "content": "Hello"}],
    "max_tokens": 100
  }'
```

## Evalchemy + vLLM 연동 설정

### 환경 변수 설정

```bash
# 1. LiteLLM 최신 버전 설치
pip install -U "litellm>=1.72"

# 2. vLLM 서버 정보 환경 변수 설정
export OPENAI_API_BASE="http://localhost:8000/v1"
export OPENAI_API_KEY="your-secret-key"

# 3. Evalchemy 설치
pip install evalchemy
```

### 기본 실행 명령어

```bash
# 방법 1: OpenAI 호환 API 어댑터 사용
python -m eval.eval \
  --model openai \
  --tasks MMLU,HellaSwag,ARC-c \
  --model_name "deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --apply_chat_template True \
  --batch_size 8 \
  --output_path logs/vllm_benchmark_results.json

# 방법 2: Curator 어댑터 사용 (LiteLLM 통합)
python -m eval.eval \
  --model curator \
  --tasks MMLU,HellaSwag,ARC-c \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://localhost:8000/v1,api_key=your-secret-key" \
  --apply_chat_template True \
  --batch_size 8 \
  --output_path logs/vllm_curator_results.json
```

## 평가 가능한 태스크 종합 가이드

### 수학 및 추론 태스크

| 태스크명 | 설명 | 문제 수 | 평가 지표 | 난이도 |
|:---------|:-----|:--------|:----------|:-------|
| **AIME24** | 미국 수학 경시대회 문제 | 30 | 정확도 | 매우 어려움 |
| **MATH500** | 고등학교/대학 수학 문제 | 500 | 정확도 | 어려움 |
| **GSM8K** | 초등학교 수학 단어 문제 | 1,319 | 정확도 | 보통 |
| **MATH** | 경쟁 수학 문제 (전체) | 12,500 | 정확도 | 어려움 |
| **MathQA** | 다중 선택 수학 문제 | 37,000 | 정확도 | 보통 |

### 코딩 및 프로그래밍 태스크

| 태스크명 | 설명 | 문제 수 | 평가 지표 | 언어 |
|:---------|:-----|:--------|:----------|:-----|
| **HumanEval** | Python 코딩 문제 | 164 | pass@k | Python |
| **MBPP** | Python 프로그래밍 기초 | 974 | 정확도 | Python |
| **CodeContests** | 프로그래밍 대회 문제 | 13,328 | 정확도 | 다양 |
| **DS-1000** | 데이터 사이언스 코딩 | 1,000 | 실행 성공률 | Python |

### 일반 지식 및 추론 태스크

| 태스크명 | 설명 | 문제 수 | 평가 지표 | 도메인 |
|:---------|:-----|:--------|:----------|:-------|
| **MMLU** | 대학 수준 다분야 지식 | 15,908 | 정확도 | 종합 |
| **HellaSwag** | 상식 추론 (문장 완성) | 10,042 | 정확도 | 상식 |
| **ARC-Challenge** | 과학 추론 (어려운 버전) | 1,172 | 정확도 | 과학 |
| **ARC-Easy** | 과학 추론 (쉬운 버전) | 2,376 | 정확도 | 과학 |
| **TruthfulQA** | 진실성 평가 | 817 | 정확도 | 사실 확인 |
| **Winogrande** | 상식 추론 | 1,267 | 정확도 | 상식 |

### 언어 이해 및 생성 태스크

| 태스크명 | 설명 | 문제 수 | 평가 지표 | 유형 |
|:---------|:-----|:--------|:----------|:-----|
| **SQUAD** | 독해 및 질문 응답 | 10,570 | F1/EM | 독해 |
| **BoolQ** | 예/아니오 질문 | 3,270 | 정확도 | 이해 |
| **COPA** | 인과 관계 추론 | 1,000 | 정확도 | 추론 |
| **RTE** | 텍스트 함의 인식 | 3,000 | 정확도 | 논리 |
| **WSC** | Winograd Schema Challenge | 273 | 정확도 | 상식 |

### 전문 도메인 태스크

| 태스크명 | 설명 | 문제 수 | 평가 지표 | 전문 분야 |
|:---------|:-----|:--------|:----------|:----------|
| **MedQA** | 의학 질문 답변 | 1,273 | 정확도 | 의학 |
| **LegalBench** | 법학 추론 문제 | 20,000+ | 정확도 | 법학 |
| **FinanceQA** | 금융 지식 평가 | 1,486 | 정확도 | 금융 |
| **SciQ** | 과학 지식 문제 | 13,679 | 정확도 | 과학 |

### 멀티모달 및 특수 태스크

| 태스크명 | 설명 | 문제 수 | 평가 지표 | 특징 |
|:---------|:-----|:--------|:----------|:-----|
| **LAMBADA** | 장문 맥락 이해 | 5,153 | 정확도 | 긴 맥락 |
| **DROP** | 수치 추론 및 독해 | 9,536 | F1 | 복합 추론 |
| **QuAC** | 대화형 질문 답변 | 98,407 | F1 | 대화 |
| **CoQA** | 대화형 질문 답변 | 127,000+ | F1 | 대화 |

## 실행 예시 및 최적화

### 단일 태스크 평가

```bash
# 수학 추론 평가 - OpenAI 어댑터
python -m eval.eval \
  --model openai \
  --tasks AIME24 \
  --model_name "deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --apply_chat_template True \
  --batch_size 4 \
  --output_path logs/aime24_results.json

# 수학 추론 평가 - Curator 어댑터
python -m eval.eval \
  --model curator \
  --tasks AIME24 \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://localhost:8000/v1" \
  --apply_chat_template True \
  --batch_size 4 \
  --output_path logs/aime24_curator_results.json
```

### 다중 태스크 종합 평가

```bash
# 종합 벤치마크 실행 (수학, 코딩, 추론) - OpenAI 어댑터
python -m eval.eval \
  --model openai \
  --tasks MATH500,HumanEval,MMLU,HellaSwag,ARC-c \
  --model_name "deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --apply_chat_template True \
  --batch_size 8 \
  --output_path logs/comprehensive_benchmark.json

# 종합 벤치마크 실행 (수학, 코딩, 추론) - Curator 어댑터
python -m eval.eval \
  --model curator \
  --tasks MATH500,HumanEval,MMLU,HellaSwag,ARC-c \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://localhost:8000/v1" \
  --apply_chat_template True \
  --batch_size 8 \
  --output_path logs/comprehensive_curator_benchmark.json
```

### 도메인별 특화 평가

```bash
# 의료 도메인 평가
python -m eval.eval \
  --model openai \
  --tasks MedQA,MedMCQA,PubMedQA \
  --model_name "microsoft/BioGPT-Large" \
  --apply_chat_template True \
  --batch_size 6 \
  --output_path logs/medical_benchmark.json

# 코딩 능력 집중 평가
python -m eval.eval \
  --model openai \
  --tasks HumanEval,MBPP,CodeContests,DS-1000 \
  --model_name "codellama/CodeLlama-13b-Instruct-hf" \
  --apply_chat_template True \
  --batch_size 4 \
  --output_path logs/coding_benchmark.json
```

## 성능 최적화 전략

### vLLM 서버 최적화

```bash
# 고성능 설정 예시
vllm serve deepseek-ai/deepseek-r1-0528-qwen3-8b \
  --host 0.0.0.0 \
  --port 8000 \
  --api-key your-secret-key \
  --tensor-parallel-size 4 \
  --pipeline-parallel-size 1 \
  --max-model-len 4096 \
  --max-num-batched-tokens 16384 \
  --max-num-seqs 256 \
  --enable-chunked-prefill \
  --gpu-memory-utilization 0.9 \
  --swap-space 4 \
  --disable-log-requests \
  --quantization awq
```

### Evalchemy 최적화 설정

| 파라미터 | 설명 | 권장값 | 효과 |
|:---------|:-----|:-------|:-----|
| `--batch_size` | 배치 크기 | 8-16 | API 호출 횟수 감소 |
| `--limit` | 태스크당 샘플 수 제한 | 100-1000 | 빠른 테스트 |
| `--num_fewshot` | Few-shot 예시 개수 | 0-5 | 성능 vs 속도 트레이드오프 |
| `--max_batch_size` | 최대 배치 크기 | 32 | 메모리 효율성 |

## 결과 분석 및 해석

### 표준 출력 예시

```text
python -m eval.eval --model curator --tasks MMLU,HellaSwag,ARC-c \
  --model_name "openai/deepseek-ai/deepseek-r1-0528-qwen3-8b" \
  --model_args "api_base=http://localhost:8000/v1" \
  --batch_size 8 --output_path logs/multi_task_results.json

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━ 100% • Time Elapsed 0:15:32 • Time Remaining 0:00:00
Requests: Total: 1,247 • Cached: 0✓ • Success: 1,247✓ • Failed: 0✗ • Req/min: 4.8 • Res/min: 4.8

                            Final Benchmark Results
╭─────────────────────────┬──────────────────────────────────────────────────╮
│ Task                    │ Score                                            │
├─────────────────────────┼──────────────────────────────────────────────────┤
│ MMLU                    │ 0.7234 (72.34%)                                 │
│ HellaSwag               │ 0.8456 (84.56%)                                 │
│ ARC-Challenge           │ 0.6789 (67.89%)                                 │
│ Average                 │ 0.7493 (74.93%)                                 │
├─────────────────────────┼──────────────────────────────────────────────────┤
│ Total Time              │ 932.1s                                           │
│ Requests per Minute     │ 4.8                                              │
│ Tokens per Second       │ 156.7                                            │
╰─────────────────────────┴──────────────────────────────────────────────────╯
```

### 성능 지표 해석

| 지표 | 의미 | 좋은 수치 |
|:-----|:-----|:----------|
| **Requests per Minute** | 분당 처리 요청 수 | 5+ (vLLM), 0.5-1 (CPU) |
| **Tokens per Second** | 초당 토큰 생성 속도 | 100+ (GPU), 10-20 (CPU) |
| **Success Rate** | 성공률 | 99%+ |
| **Average Score** | 평균 점수 | 태스크별 상대 평가 |

### 태스크별 성능 기준

| 난이도 | 태스크 예시 | 좋은 성능 | 우수한 성능 |
|:-------|:------------|:----------|:------------|
| **쉬움** | GSM8K, ARC-Easy | 70%+ | 85%+ |
| **보통** | MMLU, HellaSwag | 60%+ | 75%+ |
| **어려움** | MATH, HumanEval | 40%+ | 60%+ |
| **매우 어려움** | AIME24, CodeContests | 20%+ | 40%+ |

## 자주 묻는 질문 (FAQ)

### 서버 관련 문제

| 문제 | 원인 | 해결책 |
|:-----|:-----|:-------|
| **CUDA OOM Error** | GPU 메모리 부족 | `--gpu-memory-utilization` 낮추기 (0.8-0.85) |
| **Connection Refused** | 서버 미실행 또는 포트 충돌 | 서버 상태 확인, 포트 변경 |
| **Model Loading Failed** | 모델 경로 오류 또는 권한 문제 | 모델명 확인, HuggingFace 로그인 |
| **Too Many Requests** | 배치 크기 초과 | `--batch_size` 줄이기 |

### 성능 최적화 팁

| 영역 | 최적화 방법 | 성능 향상 |
|:-----|:------------|:----------|
| **GPU 활용** | `--tensor-parallel-size` 증가 | 2-4배 속도 향상 |
| **메모리 관리** | `--enable-chunked-prefill` 활성화 | 메모리 효율성 증대 |
| **배치 처리** | `--max-num-batched-tokens` 최적화 | 처리량 50% 증가 |
| **양자화** | `--quantization awq/gptq` 사용 | 메모리 사용량 50% 감소 |

## 고급 사용법

### 커스텀 태스크 추가

```python
# custom_task.yaml 예시
task: custom_math_reasoning
dataset_path: ./data/custom_math.json
metric: exact_match
num_fewshot: 3
description: "커스텀 수학 추론 태스크"
```

### 결과 후처리 및 분석

```python
import json
import pandas as pd

# 결과 파일 로드
with open('logs/benchmark_results.json', 'r') as f:
    results = json.load(f)

# 태스크별 성능 분석
df = pd.DataFrame(results['results'])
print(df.groupby('task')['score'].mean())

# 성능 트렌드 분석
df['difficulty'] = df['task'].map({
    'GSM8K': 'Easy',
    'MMLU': 'Medium', 
    'MATH': 'Hard',
    'AIME24': 'Very Hard'
})
print(df.groupby('difficulty')['score'].mean())
```

## 결론

vLLM과 Evalchemy의 조합은 대규모 언어 모델의 종합적 성능 평가를 위한 강력한 도구입니다. GPU 가속을 통한 빠른 추론 속도와 50+ 종류의 다양한 벤치마크 태스크로 모델의 강점과 약점을 정확히 파악할 수 있습니다.

### 주요 성과

- **속도**: CPU 대비 20-50배 빠른 처리 속도
- **확장성**: 다중 GPU 환경에서 선형적 성능 향상
- **정확성**: 표준화된 평가 프로토콜로 일관된 결과
- **효율성**: 배치 처리를 통한 자원 활용도 극대화

### 다음 단계

1. **모델 최적화**: 양자화, 프루닝을 통한 효율성 개선
2. **커스텀 태스크**: 도메인 특화 벤치마크 개발
3. **자동화**: CI/CD 파이프라인에 벤치마크 통합
4. **모니터링**: 지속적인 성능 추적 및 분석

이 가이드를 통해 여러분의 모델이 실제 환경에서 어떤 성능을 보일지 정확히 예측하고, 개선 방향을 설정하실 수 있기를 바랍니다! 🚀

---

**참고 자료:**
- [vLLM 공식 문서](https://docs.vllm.ai/)
- [Evalchemy API 레퍼런스](https://docs.bespokelabs.ai/)
- [LM Evaluation Harness](https://github.com/EleutherAI/lm-evaluation-harness)
- [HuggingFace Transformers](https://huggingface.co/docs/transformers) 