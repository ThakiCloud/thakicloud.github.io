---
title: "NVIDIA FlashInfer로 고성능 LLM 추론 최적화하기"
excerpt: "NVIDIA의 FlashInfer 라이브러리를 활용해 LLM 추론 성능을 극대화하는 방법과 실제 구현 가이드"
date: 2025-06-17
categories:
  - tutorials
tags:
  - NVIDIA
  - FlashInfer
  - LLM Inference
  - GPU Optimization
  - CUDA
  - TensorRT
author_profile: true
toc: true
toc_label: "목차"
---

## FlashInfer 개요

FlashInfer는 NVIDIA에서 개발한 고성능 LLM 추론을 위한 커스터마이징 가능한 라이브러리입니다. MLSys 2025에서 최우수 논문상을 수상한 이 기술은 현재 vLLM, SGLang, MLC Engine 등 주요 LLM 서빙 프레임워크에 통합되어 있습니다.

### 핵심 특징

**속도와 개발자 생산성** - FlashInfer는 두 가지 핵심 요소에 집중합니다:

- **속도**: 고도로 최적화된 컴퓨트 커널 알고리즘으로 하드웨어 효율성 극대화
- **개발자 생산성**: 새로운 커널을 빠르게 도입하고 새로운 모델, 알고리즘, 하드웨어를 가속화할 수 있는 능력

**KV-Cache 최적화** - 블록 스파스 및 조합 가능한 포맷을 사용하여 KV-cache 저장소를 최적화하고, 메모리 액세스를 개선하며 중복성을 줄입니다.

**JIT 컴파일** - Just-in-Time 컴파일을 통해 다양한 설정에 적응하는 커스터마이징 가능한 어텐션 템플릿을 제공합니다.

---

## 아키텍처 구조

FlashInfer는 LLM 워크로드를 4개의 연산자 패밀리로 분할하여 각각을 경량화된 고성능 집합체로 노출합니다.

### Attention

현대의 추론 요청은 매우 다양한 시퀀스 길이, KV 캐시 블록 크기, 마스킹 규칙, 위치 인코딩 스키마로 도착합니다. FlashInfer는 다음을 통해 이러한 동적 특성을 흡수합니다:

- **통합 저장소**: 모든 캐시 레이아웃을 블록/벡터 스파스 매트릭스로 표현
- **템플릿 & JIT 커널**: 특수화 노브, 로짓/키/쿼리, 그룹화, MLA 및 향후 변형을 가진 CUDA/CUTLASS 코드베이스
- **Inspector-Executor 인터페이스**: 요청 형태와 접두사 공유 패턴을 먼저 검사한 후, 경량 스케줄러를 통해 튜닝된 커널을 실행하여 GPU를 포화 상태로 유지하는 PyTorch 친화적 API

### GEMM 및 Communication

LLM 블록은 여전히 행렬 곱셈에 크게 의존합니다. 전통적인 GEMV/GEMM 계산과 all-reduce 통신 외에도, mixture-of-experts 및 LoRA 레이어와 같은 최근 발전은 다음과 같은 새로운 요구사항을 도입합니다:

- **Grouped GEMM**: 단일 호출에서 많은 작은 행렬 곱셈
- **All-to-all 통신**: 분산 처리를 위한 효율적인 데이터 교환

FlashInfer는 가장 빠른 오픈소스 또는 NVIDIA 커널(fp4/fp8 텐서 코어 경로 포함)을 선택하고 일관된 API 뒤에 제시하여, 서빙 스택이 애플리케이션 로직을 건드리지 않고 GPU나 커널을 교체할 수 있도록 합니다.

### Token Sampling

다음 토큰 생성은 종종 Top-K/Top-P 필터링에서 병목이 됩니다. 전통적인 구현은 전체 어휘를 정렬하는데, 이는 소수의 로짓만 중요할 때 낭비적인 작업입니다. FlashInfer는 전역 정렬을 거부 기반, 정렬 없는 샘플러로 대체하여 가능성이 낮은 토큰을 즉석에서 제거하고, 대형 어휘에서 지연 시간을 줄이며 수치적으로 충실함을 유지합니다.

---

## 설치 및 기본 사용법

### 설치

FlashInfer는 PyPI에서 사용할 수 있습니다:

```bash
pip install flashinfer-python
```

### 기본 Attention API

FlashInfer는 커널 컴파일/선택/튜닝과 커널 실행을 분리하는 `plan/run` 설계의 Torch 네이티브 API를 제공합니다:

```python
from flashinfer.attention import BatchAttention

# 어텐션 인스턴스 생성 (여러 백엔드 구현 제공)
attention = BatchAttention(backend="cutlass")

# Plan 단계: 커널 선택 및 튜닝 수행
attention.plan(
    qo_offsets,      # 가변 길이 쿼리/출력에서 각 요청의 오프셋
    kv_lens,         # 페이지 테이블에서 각 요청의 kv 길이
    kv_block_table,  # 페이지 테이블의 블록 인덱스를 나타내는 블록 테이블
    num_qo_heads,    # 쿼리/출력 헤드 수
    num_kv_heads,    # 키/값 헤드 수
    head_dim_qk,     # 쿼리/키의 헤드 차원
    head_dim_vo,     # 값/출력의 헤드 차원
    dtype_q=torch.bfloat16,   # 쿼리 데이터 타입
    dtype_kv=torch.bfloat16,  # kv 데이터 타입
    dtype_o=torch.bfloat16,   # 출력 데이터 타입
    **variant_kwargs  # 어텐션 변형을 지정하는 기타 인수
)

# Run 단계: 실제 추론 실행
O, lse = attention.run(q, (k, v))  # 출력/lse 반환
```

### Logits Processing

모듈러 인터페이스로 다양한 로짓 프로세서를 조합하고, FlashInfer는 효율적인 융합된 거부 샘플링 기반 구현을 제공합니다:

```python
import flashinfer
from flashinfer.logits_processor import LogitsPipe, Temperature, Softmax, TopP, Sample

# 파이프라인 생성
pipe = LogitsPipe([
    Temperature(),      # 온도로 로짓 스케일링
    Softmax(),          # 로짓을 확률로 변환
    TopP(),             # top-p 필터링 적용
    Sample()            # 분포에서 샘플링
])

# 파이프라인 적용
logits = torch.randn(batch_size, vocab_size, device="cuda")
output_ids = pipe(logits, temperature=0.7, top_p=0.9)
```

---

## 성능 최적화 전략

### Plan/Run 패턴 활용

FlashInfer의 핵심 설계 철학은 `plan/run` 패턴입니다:

1. **Plan 단계**: 메타데이터 수집 및 커널 선택/튜닝
2. **Run 단계**: 실제 계산 실행

동일한 메타데이터를 공유하는 후속 실행(LLM 생성 단계의 모든 레이어)에서 동일한 plan 정보를 재사용할 수 있어 오버헤드를 크게 줄입니다.

### 백엔드 선택

사용 사례에 따라 최적의 성능을 위해 여러 어텐션 백엔드 중에서 선택할 수 있습니다:

```python
# CUTLASS 백엔드 (일반적으로 권장)
attention = BatchAttention(backend="cutlass")

# 다른 백엔드 옵션들
attention = BatchAttention(backend="flashattention")
attention = BatchAttention(backend="triton")
```

### CUDA Graph 호환성

모든 커널은 CUDA Graph와 안전하게 호환되어 저지연 LLM 추론 서빙을 가능하게 합니다:

```python
# CUDA Graph 캡처 예시
with torch.cuda.graph(graph):
    O, lse = attention.run(q, (k, v))

# 그래프 재실행
graph.replay()
```

---

## 실제 통합 사례

### vLLM 통합

FlashInfer는 vLLM에 직접 통합되어 있어 기존 vLLM 워크플로우에서 자동으로 성능 향상을 얻을 수 있습니다:

```python
from vllm import LLM, SamplingParams

# FlashInfer가 자동으로 사용됨
llm = LLM(model="meta-llama/Llama-2-7b-hf")
sampling_params = SamplingParams(temperature=0.8, top_p=0.95)

prompts = ["Hello, my name is", "The future of AI is"]
outputs = llm.generate(prompts, sampling_params)
```

### SGLang 통합

SGLang에서도 FlashInfer를 활용하여 구조화된 생성 작업의 성능을 향상시킬 수 있습니다:

```python
import sglang as sgl

@sgl.function
def multi_turn_question(s, question_1, question_2):
    s += sgl.system("You are a helpful assistant.")
    s += sgl.user(question_1)
    s += sgl.assistant(sgl.gen("answer_1", max_tokens=256))
    s += sgl.user(question_2)
    s += sgl.assistant(sgl.gen("answer_2", max_tokens=256))

# FlashInfer가 백엔드에서 자동 사용됨
state = multi_turn_question.run(
    question_1="What is the capital of France?",
    question_2="What is its population?"
)
```

---

## 고급 기능 및 최적화

### KV-Cache 블록 관리

FlashInfer는 효율적인 KV-cache 관리를 위한 고급 기능을 제공합니다:

```python
# 블록 스파스 KV-cache 설정
block_size = 16
max_blocks = 1024

# 페이지 테이블 기반 메모리 관리
kv_block_table = torch.randint(0, max_blocks, (batch_size, max_seq_len // block_size))
kv_lens = torch.randint(1, max_seq_len, (batch_size,))
```

### 혼합 정밀도 지원

다양한 데이터 타입을 지원하여 메모리 사용량과 성능을 최적화할 수 있습니다:

```python
# FP16/BF16 혼합 사용
attention.plan(
    # ... 기타 파라미터
    dtype_q=torch.bfloat16,    # 쿼리는 BF16
    dtype_kv=torch.float16,    # KV는 FP16
    dtype_o=torch.bfloat16,    # 출력은 BF16
)

# FP8 지원 (최신 하드웨어에서)
attention.plan(
    # ... 기타 파라미터
    dtype_kv=torch.float8_e4m3fn,  # FP8 KV-cache
)
```

---

## 성능 벤치마킹

### 처리량 측정

FlashInfer의 성능을 측정하기 위한 기본적인 벤치마킹 코드:

```python
import time
import torch
from flashinfer.attention import BatchAttention

def benchmark_attention(batch_size, seq_len, num_heads, head_dim):
    # 테스트 데이터 생성
    q = torch.randn(batch_size, seq_len, num_heads, head_dim, 
                   dtype=torch.bfloat16, device="cuda")
    k = torch.randn(batch_size, seq_len, num_heads, head_dim, 
                   dtype=torch.bfloat16, device="cuda")
    v = torch.randn(batch_size, seq_len, num_heads, head_dim, 
                   dtype=torch.bfloat16, device="cuda")
    
    # FlashInfer 설정
    attention = BatchAttention(backend="cutlass")
    
    # Plan 단계 (한 번만 수행)
    qo_offsets = torch.arange(0, (batch_size + 1) * seq_len, seq_len, device="cuda")
    kv_lens = torch.full((batch_size,), seq_len, device="cuda")
    
    attention.plan(qo_offsets, kv_lens, None, num_heads, num_heads, 
                  head_dim, head_dim)
    
    # 워밍업
    for _ in range(10):
        _ = attention.run(q, (k, v))
    
    torch.cuda.synchronize()
    
    # 실제 측정
    start_time = time.time()
    num_iterations = 100
    
    for _ in range(num_iterations):
        output, _ = attention.run(q, (k, v))
    
    torch.cuda.synchronize()
    end_time = time.time()
    
    avg_time = (end_time - start_time) / num_iterations
    throughput = batch_size * seq_len / avg_time
    
    print(f"Average time: {avg_time:.4f}s")
    print(f"Throughput: {throughput:.2f} tokens/sec")

# 벤치마크 실행
benchmark_attention(batch_size=32, seq_len=2048, num_heads=32, head_dim=128)
```

---

## 문제 해결 및 디버깅

### 일반적인 문제들

**메모리 부족 오류**:

```python
# 배치 크기나 시퀀스 길이 줄이기
# 또는 그래디언트 체크포인팅 사용
torch.cuda.empty_cache()
```

**커널 컴파일 오류**:

```python
# CUDA 버전 확인
import torch
print(f"CUDA version: {torch.version.cuda}")
print(f"PyTorch version: {torch.__version__}")

# 호환되는 버전 설치 확인
```

**성능 저하**:

```python
# 적절한 백엔드 선택
attention = BatchAttention(backend="cutlass")  # 일반적으로 최고 성능

# Plan 재사용 확인
# 동일한 메타데이터에 대해 plan을 반복 호출하지 않기
```

---

## 결론

FlashInfer는 NVIDIA의 최신 LLM 추론 최적화 기술을 집약한 강력한 라이브러리입니다. Plan/Run 패턴을 통한 효율적인 커널 관리, 다양한 백엔드 지원, 그리고 주요 프레임워크와의 원활한 통합을 통해 LLM 추론 성능을 크게 향상시킬 수 있습니다.

특히 대규모 배치 처리, 긴 시퀀스 처리, 그리고 실시간 서빙 환경에서 FlashInfer의 장점이 극대화됩니다. 지속적인 개발과 커뮤니티 기여를 통해 앞으로도 더욱 발전된 기능들이 추가될 예정입니다.

더 자세한 정보는 [FlashInfer GitHub 저장소](https://github.com/flashinfer-ai/flashinfer)와 [공식 문서](https://docs.flashinfer.ai/)를 참조하시기 바랍니다.
