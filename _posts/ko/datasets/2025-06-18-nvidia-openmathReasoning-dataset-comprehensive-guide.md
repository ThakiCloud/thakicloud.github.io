---
title: "NVIDIA OpenMathReasoning: AIMO-2 우승 모델의 기반이 된 대규모 수학 추론 데이터셋"
excerpt: "306K 수학 문제와 568만 솔루션으로 구성된 OpenMathReasoning 데이터셋 완전 분석 - CoT, TIR, GenSelect 방법론과 OpenMath-Nemotron 시리즈 성과"
date: 2025-06-18
categories: 
  - datasets
  - llmops
tags: 
  - nvidia
  - openmathReasoning
  - aimo-2
  - math-reasoning
  - chain-of-thought
  - tool-integrated-reasoning
  - genselect
  - aops
  - deepseek-r1
  - qwq-32b
  - cc-by-4.0
author_profile: true
toc: true
toc_label: "OpenMathReasoning 가이드"
published: false
---

## 개요

**OpenMathReasoning**은 NVIDIA에서 개발한 대규모 수학 추론 데이터셋으로, **AIMO-2 Kaggle 컴페티션**에서 우승한 모델의 기반이 되었습니다. 이 데이터셋은 **306K개의 독특한 수학 문제**와 **총 568만 개의 솔루션**으로 구성되어 있으며, **CC BY 4.0 라이센스**로 공개되어 있습니다.

**AoPS(Art of Problem Solving) 포럼**에서 수집한 고품질 수학 문제들을 **DeepSeek-R1**과 **QwQ-32B** 모델로 처리하여 다양한 추론 방법론(CoT, TIR, GenSelect)을 적용한 솔루션을 생성했습니다.

## 데이터셋 구성 및 규모

### 핵심 통계

| **구성 요소** | **규모** | **설명** |
|---|---|---|
| **독특한 수학 문제** | 306K개 | AoPS 포럼에서 수집된 고유 문제 |
| **CoT 솔루션** | 3.2M개 | 긴 연쇄 사고(Chain-of-Thought) 솔루션 |
| **TIR 솔루션** | 1.7M개 | 도구 통합 추론(Tool-Integrated Reasoning) |
| **GenSelect 샘플** | 566K개 | 다수 후보 중 최적 솔루션 선택 |
| **추가 문제** | 193K개 | 솔루션 없는 추가 문제 |
| **총 데이터 포인트** | **5,678,317개** | 전체 데이터셋 크기 |

### 데이터 소스

- **주요 소스**: AoPS(Art of Problem Solving) 포럼
- **포럼 카테고리**: 고등학교 올림피아드, 수학 경시대회 등
- **추가 소스**: MATH 훈련 데이터셋 일부
- **전처리**: Qwen2.5-32B-Instruct로 문제 정제

## 데이터셋 필드 구조

### 주요 필드 설명

```json
{
  "problem": "AoPS 포럼에서 추출하고 Qwen2.5-32B-Instruct로 정제한 문제 설명",
  "generated_solution": "DeepSeek-R1 또는 QwQ-32B로 생성한 합성 솔루션",
  "generation_model": "DeepSeek-R1 | QwQ-32B",
  "problem_type": "has_answer_extracted | no_answer_extracted | converted_proof",
  "expected_answer": "추출된 정답 또는 다수결 투표 결과",
  "problem_source": "해당 AoPS 포럼명 (예: aops_c6_high_school_olympiads)",
  "inference_mode": "cot | tir | genselect",
  "pass_rate_72b_tir": "Qwen2.5-Math-72B-Instruct TIR 모드 통과율",
  "used_in_kaggle": "AIMO-2 Kaggle 우승 모델 훈련 사용 여부"
}
```

### 문제 유형 분류

1. **has_answer_extracted**: 명확한 답을 추출할 수 있는 문제
2. **no_answer_extracted**: 답 추출이 어려운 문제
3. **converted_proof**: 증명 문제를 답변 문제로 변환

## 추론 방법론

### 1. CoT (Chain-of-Thought)

**연쇄 사고 추론**으로 단계별 논리적 사고 과정을 보여줍니다.

```python
# CoT 예시 구조
problem = "함수 f(x) = x² + 2x + 1에서 f(3)의 값을 구하시오."

cot_solution = """
1단계: 주어진 함수에 x = 3을 대입
f(3) = 3² + 2(3) + 1

2단계: 각 항을 계산
3² = 9
2(3) = 6

3단계: 모든 항을 합산
f(3) = 9 + 6 + 1 = 16

따라서 f(3) = 16이다.
"""
```

### 2. TIR (Tool-Integrated Reasoning)

**도구 통합 추론**으로 외부 도구나 계산기를 활용한 추론입니다.

```python
# TIR 예시 구조
problem = "복잡한 적분을 계산하시오: ∫(x³ + 2x² - x + 5)dx"

tir_solution = """
1단계: 각 항목별로 적분 적용
∫x³dx = x⁴/4
∫2x²dx = 2x³/3
∫(-x)dx = -x²/2
∫5dx = 5x

2단계: 계산 도구로 검증
[도구 사용: 적분 계산기]
결과: x⁴/4 + 2x³/3 - x²/2 + 5x + C

3단계: 최종 답안 정리
∫(x³ + 2x² - x + 5)dx = x⁴/4 + 2x³/3 - x²/2 + 5x + C
"""
```

### 3. GenSelect (Generation Selection)

**생성 선택** 방법으로 여러 후보 솔루션 중 최적을 선택합니다.

```python
# GenSelect 워크플로우
candidates = [
    "솔루션 A: 기하학적 접근",
    "솔루션 B: 대수적 접근",
    "솔루션 C: 삼각함수 접근"
]

selection_criteria = [
    "정확성",
    "효율성", 
    "이해하기 쉬움"
]

selected_solution = "솔루션 B (대수적 접근이 가장 직관적이고 정확함)"
```

## 데이터 생성 파이프라인

### 1단계: 문제 수집 및 전처리

```python
# 데이터 전처리 예시
from datasets import load_dataset

# AoPS 포럼 데이터 로드
raw_problems = load_aops_forum_data()

# Qwen2.5-32B-Instruct로 정제
refined_problems = []
for problem in raw_problems:
    refined = qwen_refine(problem)
    if validate_problem(refined):
        refined_problems.append(refined)
```

### 2단계: 솔루션 생성

```python
# DeepSeek-R1과 QwQ-32B로 솔루션 생성
solutions = []

for problem in refined_problems:
    # CoT 솔루션 생성
    cot_solutions = deepseek_r1.generate_cot(problem, num_solutions=32)
    
    # TIR 솔루션 생성  
    tir_solutions = qwq_32b.generate_tir(problem, num_solutions=16)
    
    solutions.extend(cot_solutions + tir_solutions)
```

### 3단계: 품질 필터링

```python
# 솔루션 품질 검증
filtered_solutions = []

for solution in solutions:
    # 형식 제한 확인
    if not validate_format(solution):
        continue
        
    # 벤치마크 중복 제거
    if is_benchmark_contaminated(solution):
        continue
        
    # 답변 검증
    if verify_answer(solution):
        filtered_solutions.append(solution)
```

## OpenMath-Nemotron 모델 시리즈

### 모델 라인업

| **모델** | **크기** | **주요 특징** |
|---|---|---|
| [OpenMath-Nemotron-1.5B](https://huggingface.co/nvidia/OpenMath-Nemotron-1.5B) | 1.5B | 경량화된 수학 추론 모델 |
| [OpenMath-Nemotron-7B](https://huggingface.co/nvidia/OpenMath-Nemotron-7B) | 7B | 균형잡힌 성능과 효율성 |
| [OpenMath-Nemotron-14B](https://huggingface.co/nvidia/OpenMath-Nemotron-14B) | 14B | 고성능 수학 추론 모델 |
| [OpenMath-Nemotron-14B-Kaggle](https://huggingface.co/nvidia/OpenMath-Nemotron-14B-Kaggle) | 14B | AIMO-2 우승 모델 |
| [OpenMath-Nemotron-32B](https://huggingface.co/nvidia/OpenMath-Nemotron-32B) | 32B | 최고 성능 모델 |

### 벤치마크 성능

다음은 주요 수학 벤치마크에서의 성능 비교입니다:

| **모델** | **AIME24** | **AIME25** | **HMMT-24-25** | **HLE-Math** |
|---|---|---|---|---|
| **OpenMath-Nemotron-7B CoT** | **74.8** | **61.2** | **49.7** | **6.6** |
| OpenMath-Nemotron-7B TIR | 72.9 | 57.5 | 54.6 | 7.8 |
| + Self GenSelect | 86.7 | 76.7 | 68.4 | 11.5 |
| **OpenMath-Nemotron-14B CoT** | **76.3** | **63.0** | **52.1** | **7.5** |
| OpenMath-Nemotron-14B TIR | 76.3 | 61.3 | 58.6 | 9.5 |
| + Self GenSelect | 86.7 | 76.7 | 72.4 | 14.1 |
| **OpenMath-Nemotron-32B TIR** | **78.4** | **64.2** | **59.7** | **9.2** |
| + Self GenSelect | **93.3** | **80.0** | **73.5** | **15.7** |

### GenSelect 효과

GenSelect 방법론은 모든 모델에서 상당한 성능 향상을 보여줍니다:

- **OpenMath-Nemotron-7B**: AIME24에서 74.8 → 86.7 (+11.9%p)
- **OpenMath-Nemotron-14B**: HMMT에서 52.1 → 72.4 (+20.3%p)
- **OpenMath-Nemotron-32B**: AIME24에서 78.4 → 93.3 (+14.9%p)

## 사용 방법 및 실습

### 데이터셋 로드

```python
from datasets import load_dataset

# 전체 데이터셋 로드
dataset = load_dataset("nvidia/OpenMathReasoning")

# 특정 추론 모드별 필터링
cot_data = dataset.filter(lambda x: x['inference_mode'] == 'cot')
tir_data = dataset.filter(lambda x: x['inference_mode'] == 'tir')
genselect_data = dataset.filter(lambda x: x['inference_mode'] == 'genselect')

print(f"CoT 샘플: {len(cot_data)} 개")
print(f"TIR 샘플: {len(tir_data)} 개") 
print(f"GenSelect 샘플: {len(genselect_data)} 개")
```

### 문제 유형별 분석

```python
# 문제 유형별 통계
problem_types = dataset['train']['problem_type']
type_counts = {}

for ptype in problem_types:
    type_counts[ptype] = type_counts.get(ptype, 0) + 1

print("문제 유형별 분포:")
for ptype, count in type_counts.items():
    print(f"- {ptype}: {count:,} 개")
```

### 생성 모델별 분석

```python
# 생성 모델별 성능 분석
generation_models = dataset['train']['generation_model']
model_counts = {}

for model in generation_models:
    model_counts[model] = model_counts.get(model, 0) + 1

print("생성 모델별 기여도:")
for model, count in model_counts.items():
    percentage = (count / len(generation_models)) * 100
    print(f"- {model}: {count:,} 개 ({percentage:.1f}%)")
```

## AIMO-2 Kaggle 성공 사례

### 컴페티션 개요

- **대회명**: AIMO-2 (AI Mathematical Olympiad)
- **주최**: Kaggle
- **목표**: 수학 올림피아드 수준의 문제 해결
- **결과**: NVIDIA 팀 우승

### 우승 전략

1. **데이터 품질**: 고품질 AoPS 포럼 데이터 활용
2. **다양한 추론**: CoT, TIR, GenSelect 조합
3. **모델 앙상블**: 여러 크기의 모델 활용
4. **지속적 개선**: 파이프라인 최적화

### 핵심 성공 요인

```python
# AIMO-2 우승 모델 훈련 구성
kaggle_training_data = {
    "CoT_solutions": "2.2M samples",
    "TIR_solutions": "15K samples", 
    "base_model": "OpenMath-Nemotron-14B",
    "fine_tuning": "Supervised Fine-Tuning on OpenMathReasoning"
}

performance_metrics = {
    "AIME_2024": 73.7,
    "AIME_2025": 57.9,
    "HMMT_24_25": 50.5,
    "HLE_Math": 5.7
}
```

## 라이센스 및 사용 조건

### CC BY 4.0 라이센스

OpenMathReasoning 데이터셋은 **Creative Commons Attribution 4.0 International License**로 제공됩니다.

**허용사항**:

- ✅ **상업적 사용**: 영리 목적 활용 가능
- ✅ **수정**: 데이터 수정 및 변형 가능  
- ✅ **배포**: 원본 및 수정된 버전 배포 가능
- ✅ **사적 사용**: 개인적 용도 사용 가능

**의무사항**:

- 📝 **저작자 표시**: NVIDIA Corporation 명시 필요
- 📝 **라이센스 표시**: CC BY 4.0 라이센스 고지 필요
- 📝 **변경사항 표시**: 수정한 경우 변경사항 명시 권장

### 권장 사용 사례

1. **교육 목적**: 수학 추론 모델 훈련
2. **연구 목적**: 수학 AI 연구 개발
3. **상업적 활용**: 수학 교육 도구 개발
4. **평가 목적**: 모델 성능 벤치마킹

## 기술적 세부사항

### 데이터 저장 형식

- **포맷**: Parquet
- **크기**: 49.5GB
- **압축**: 효율적인 컬럼형 저장
- **접근**: Hugging Face Datasets API

### 품질 관리 과정

1. **형식 제한 필터링**
   - Yes/No 질문 제거
   - 객관식 문제 제거
   - 부적절한 형식 문제 배제

2. **벤치마크 중복 제거**
   - 기존 평가 데이터와 중복 확인
   - 9-gram 중복 검사
   - 데이터 오염 방지

3. **솔루션 검증**
   - LLM 생성 솔루션 유효성 검사
   - 수학적 정확성 확인
   - 논리적 일관성 검토

### 파이프라인 이슈 및 해결

**초기 문제 수 불일치**:

- 초기 보고: 540K 문제
- 실제 릴리즈: 306K 문제
- 원인: 필터링 과정에서 문제 제거
- 해결: 투명한 데이터 처리 과정 공개

**137K 증명 문제 손실**:

- 파이프라인 버그로 인한 데이터 손실
- 복구 후 성능 저하 발견
- 현재 개선 방안 연구 중

## 활용 사례 및 응용

### 교육 분야

1. **개인 맞춤형 수학 튜터**

   ```python
   # 수학 튜터 시스템 예시
   class MathTutor:
       def __init__(self):
           self.model = load_openmath_nemotron()
           self.dataset = load_dataset("nvidia/OpenMathReasoning")
       
       def solve_problem(self, problem, method="cot"):
           if method == "cot":
               return self.generate_cot_solution(problem)
           elif method == "tir":
               return self.generate_tir_solution(problem)
   ```

2. **수학 문제 생성기**
   - 난이도별 문제 생성
   - 단계별 솔루션 제공
   - 학습자 수준 맞춤형 추천

### 연구 분야

1. **추론 능력 연구**
   - 수학적 추론 메커니즘 분석
   - 다단계 추론 과정 연구
   - 논리적 사고 패턴 파악

2. **AI 교육 도구 개발**
   - 지능형 학습 시스템
   - 자동 채점 및 피드백
   - 학습 진도 추적

## 성능 비교 및 분석

### 베이스라인 모델과의 비교

| **모델** | **AIME24** | **AIME25** | **개선폭** |
|---|---|---|---|
| DeepSeek-R1-Distill-Qwen-7B | 54.4 | 38.6 | - |
| **OpenMath-Nemotron-7B** | **74.8** | **61.2** | **+20.4/+22.6** |
| DeepSeek-R1-Distill-Qwen-14B | 65.8 | 48.4 | - |
| **OpenMath-Nemotron-14B** | **76.3** | **63.0** | **+10.5/+14.6** |

### 추론 방법별 성능 분석

**CoT vs TIR 비교**:

- **CoT 장점**: 논리적 사고 과정 명확
- **TIR 장점**: 복잡한 계산에서 우수
- **GenSelect 효과**: 두 방법 모두 크게 향상

## 향후 발전 방향

### 데이터셋 확장 계획

1. **추가 데이터 소스**
   - 더 많은 수학 포럼 통합
   - 다양한 언어의 수학 문제
   - 실시간 문제 업데이트

2. **품질 개선**
   - 더 정교한 필터링 시스템
   - 자동화된 품질 검증
   - 커뮤니티 기반 검토

### 기술적 개선

1. **생성 모델 업그레이드**
   - 더 강력한 생성 모델 적용
   - 다양한 추론 방법론 실험
   - 멀티모달 수학 문제 지원

2. **평가 방법론 개선**
   - 더 정확한 성능 측정
   - 실시간 벤치마크 업데이트
   - 인간 평가자와의 비교

## 결론

**NVIDIA OpenMathReasoning**은 수학 추론 분야의 새로운 표준을 제시한 대규모 데이터셋입니다. **568만 개의 고품질 솔루션**과 **다양한 추론 방법론**을 통해 OpenMath-Nemotron 시리즈 모델들이 탁월한 성능을 달성할 수 있었습니다.

특히 **AIMO-2 Kaggle 컴페티션 우승**이라는 실질적 성과를 통해 데이터셋의 품질과 효과를 입증했습니다. **CC BY 4.0 라이센스**로 제공되어 교육, 연구, 상업적 활용 모든 분야에서 자유롭게 활용할 수 있습니다.

CoT, TIR, GenSelect라는 **혁신적인 추론 방법론**과 체계적인 **데이터 생성 파이프라인**은 향후 수학 AI 개발의 중요한 기준점이 될 것입니다. 이 데이터셋을 통해 더 많은 연구자와 개발자들이 수학 추론 AI 발전에 기여할 수 있을 것으로 기대됩니다.

## 인용 정보

```bibtex
@article{moshkov2025aimo2,
  title   = {AIMO-2 Winning Solution: Building State-of-the-Art Mathematical Reasoning Models with OpenMathReasoning dataset},
  author  = {Ivan Moshkov and Darragh Hanley and Ivan Sorokin and Shubham Toshniwal and Christof Henkel and Benedikt Schifferer and Wei Du and Igor Gitman},
  year    = {2025},
  journal = {arXiv preprint arXiv:2504.16891}
}
```

## 참고 자료

- [NVIDIA OpenMathReasoning Hugging Face](https://huggingface.co/datasets/nvidia/OpenMathReasoning)
- [ArXiv 논문: AIMO-2 Winning Solution](https://arxiv.org/abs/2504.16891)
- [OpenMath-Nemotron 모델 시리즈](https://huggingface.co/collections/nvidia/openmathReasoning-65f5c88537a3a906b26f0f46)
- [Creative Commons BY 4.0 License](https://creativecommons.org/licenses/by/4.0/legalcode)
- [NVIDIA AI 윤리 정책](https://www.nvidia.com/en-us/ai-data-science/ai-governance/)
