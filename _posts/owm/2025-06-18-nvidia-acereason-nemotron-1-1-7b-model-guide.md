---
title: "NVIDIA AceReason-Nemotron-1.1-7B: SFT+RL 시너지로 진화한 수학·코딩 추론 모델"
excerpt: "Qwen2.5-Math-7B 기반 NVIDIA의 최신 추론 모델 - SFT와 RL의 완벽한 결합으로 AIME 2024/2025, LiveCodeBench에서 기록적 성능 달성"
date: 2025-06-18
categories: 
  - owm
  - llmops
tags: 
  - nvidia
  - acereason
  - nemotron
  - qwen2.5
  - math-reasoning
  - code-reasoning
  - reinforcement-learning
  - supervised-fine-tuning
  - open-weight-model
  - AIME
  - LiveCodeBench
author_profile: true
toc: true
toc_label: "AceReason-Nemotron-1.1-7B 가이드"
---

## 개요

NVIDIA에서 2025년 6월 16일에 발표한 **AceReason-Nemotron-1.1-7B**는 수학과 코딩 추론에 특화된 오픈 웨이트 모델입니다. **Qwen2.5-Math-7B**를 기반으로 하여 지도 학습(SFT)과 강화 학습(RL)의 시너지를 통해 개발되었으며, 동급 모델 중 **기록적인 성능**을 달성했습니다.

이 모델은 **AIME 2024/2025**와 **LiveCodeBench**에서 뛰어난 성능을 보이며, 이전 버전인 AceReason-Nemotron-1.0-7B를 크게 능가하는 결과를 보여줍니다.

## 모델 아키텍처 및 훈련 방법론

### 기본 아키텍처

- **기반 모델**: Qwen2.5-Math-7B
- **모델 크기**: 7.62B 파라미터
- **텐서 타입**: BF16
- **아키텍처**: Transformer 기반
- **특화 분야**: 수학 추론, 코딩 추론

### 2단계 훈련 방법론

#### 1단계: 지도 학습(SFT)

- **데이터셋**: [AceReason-1.1-SFT](https://huggingface.co/datasets/nvidia/AceReason-1.1-SFT)
- **데이터 규모**: 약 400만 개 샘플
- **구성**: 수학 추론 데이터 267만 개, 코딩 추론 데이터 130만 개
- **품질**: DeepSeek-R1 기반 고품질 응답 생성

#### 2단계: 강화 학습(RL)

- **방법론**: AceReason-Nemotron-1.0-7B와 동일한 RL 레시피 적용
- **핵심 발견**: 더 강한 SFT 모델이 RL 후에도 지속적으로 우수한 성능 유지
- **성능 격차**: RL 훈련 중 성능 격차는 줄어들지만 상대적 우위는 유지

## 벤치마크 성능 결과

### 주요 벤치마크 성과

다음은 동급 모델들과의 성능 비교입니다:

| **모델** | **AIME 2024** | **AIME 2025** | **LCB v5** | **LCB v6** |
|---|---|---|---|---|
| **AceReason-Nemotron-1.1-7B** | **72.6** | **64.8** | **57.2** | **52.1** |
| OpenMath-Nemotron-7B | 74.8 | 61.2 | - | - |
| Skywork-OR1-7B | 70.2 | 54.6 | 47.6 | 42.7 |
| MiMo-7B-RL | 68.2 | 55.4 | 57.8 | 49.3 |
| AceReason-Nemotron-1.0-7B | 69.0 | 53.6 | 51.8 | 44.1 |
| Magistral Small (24B) | 70.7 | 62.8 | 55.8 | 47.4 |
| o3-mini (low) | 60.0 | 48.3 | 60.9 | - |

### RL 훈련 효과

**AceReason-Nemotron-1.1-7B**는 RL 훈련을 통해 다음과 같은 성능 향상을 달성했습니다:

- **AIME 2024**: 62.0 → 72.6 (+10.6%p)
- **AIME 2025**: 48.4 → 64.8 (+16.4%p)
- **LCB v5**: 48.8 → 57.2 (+8.4%p)
- **LCB v6**: 43.8 → 52.1 (+8.3%p)

## 사용 방법

### 기본 사용법

```python
from transformers import AutoModelForCausalLM, AutoTokenizer

model_name = 'nvidia/AceReason-Nemotron-1.1-7B'
tokenizer = AutoTokenizer.from_pretrained(model_name)
model = AutoModelForCausalLM.from_pretrained(
    model_name, 
    torch_dtype="auto", 
    device_map="auto"
)

prompt = "Jen enters a lottery by picking $4$ distinct numbers from $S=\\{1,2,3,\\cdots,9,10\\}.$ $4$ numbers are randomly chosen from $S.$ She wins a prize if at least two of her numbers were $2$ of the randomly chosen numbers, and wins the grand prize if all four of her numbers were the randomly chosen numbers. The probability of her winning the grand prize given that she won a prize is $\\tfrac{m}{n}$ where $m$ and $n$ are relatively prime positive integers. Find $m+n$."

messages = [{"role": "user", "content": prompt}]

text = tokenizer.apply_chat_template(
    messages,
    tokenize=False,
    add_generation_prompt=True
)
model_inputs = tokenizer([text], return_tensors="pt").to("cuda")

generated_ids = model.generate(
    **model_inputs,
    max_new_tokens=32768,
    temperature=0.6,
    top_p=0.95
)

generated_ids = [
    output_ids[len(input_ids):] 
    for input_ids, output_ids in zip(model_inputs.input_ids, generated_ids)
]

response = tokenizer.batch_decode(generated_ids, skip_special_tokens=True)[0]
print(response)
```

### 시스템 프롬프트 권장사항

```python
system_instruction = "You are a helpful and harmless assistant. You should think step-by-step."
```

### 수학 문제 해결 프롬프트

```python
math_question = "수학 문제 내용"
math_instruction = "Please place your final answer inside \\boxed{}."
system_instruction = "You are a helpful and harmless assistant. You should think step-by-step."

final_prompt = f"""<|im_start|>system
{system_instruction}<|im_end|>
<|im_start|>user
{math_question}

{math_instruction}<|im_end|>
<|im_start|>assistant
<think>
"""
```

### 코딩 문제 해결 프롬프트

```python
code_question = "코딩 문제 내용"
starter_code = "함수 헤더 코드"  # 없으면 빈 문자열

code_instruction_nostartercode = """Write Python code to solve the problem. Please place the solution code in the following format:
```python
# Your solution code here
```"""

code_instruction_hasstartercode = """Please place the solution code in the following format:
```python
# Your solution code here
```"""

if starter_code != "":
    code_question += f"\n\nSolve the problem starting with the provided function header.\n\nFunction header:\n```\n{starter_code}\n```"
    code_question += f"\n\n{code_instruction_hasstartercode}"
else:
    code_question += f"\n\n{code_instruction_nostartercode}"

final_prompt = f"""<|im_start|>system
{system_instruction}<|im_end|>
<|im_start|>user
{code_question}<|im_end|>
<|im_start|>assistant
<think>
"""
```

## 추론 설정 및 최적화

### 권장 추론 설정

```python
# vLLM 추론 엔진 설정 (v0.7.3)
generation_config = {
    "top_p": 0.95,
    "temperature": 0.6,
    "max_tokens": 32768
}
```

### 성능 최적화 팁

1. **GPU 메모리 최적화**

   ```python
   model = AutoModelForCausalLM.from_pretrained(
       model_name,
       torch_dtype=torch.bfloat16,
       device_map="auto",
       trust_remote_code=True
   )
   ```

2. **배치 처리**

   ```python
   # 여러 문제를 동시에 처리
   prompts = [prompt1, prompt2, prompt3]
   model_inputs = tokenizer(prompts, return_tensors="pt", padding=True)
   ```

3. **메모리 효율적 추론**

   ```python
   with torch.no_grad():
       outputs = model.generate(**model_inputs, **generation_config)
   ```

## 평가 도구 및 벤치마크

### 평가 도구킷

NVIDIA는 공식 평가 도구킷을 제공합니다:

- **평가 코드**: [GitHub 링크](https://huggingface.co/nvidia/AceReason-Nemotron-14B/blob/main/README%5FEVALUATION.md)
- **벤치마크 데이터**: AIME 2024/2025, LiveCodeBench v5/v6
- **메트릭**: avg@64 (AIME), avg@8 (LiveCodeBench)

### 벤치마크 상세 정보

1. **AIME (American Invitational Mathematics Examination)**
   - 고난도 수학 경시대회 문제
   - 2024년, 2025년 버전 모두 평가
   - 평가 방식: 64회 추론 평균

2. **LiveCodeBench**
   - 실시간 코딩 문제 벤치마크
   - v5: 2024/08/01 - 2025/02/01
   - v6: 2025/02/01 - 2025/05/01
   - 평가 방식: 8회 추론 평균

## 라이센스 및 사용 조건

### NVIDIA Open Model License

이 모델은 **NVIDIA Open Model License**에 따라 제공됩니다.

**주요 특징**:

- 연구 및 상업적 사용 허용
- 수정 및 배포 가능
- 특정 제한 사항 존재 (상세 내용은 라이센스 문서 참조)

**라이센스 전문**: [NVIDIA Open Model License](https://developer.nvidia.com/nvidia-open-model-license)

### 사용 제한사항

1. **윤리적 사용**: 해로운 목적으로 사용 금지
2. **법적 준수**: 해당 지역 법률 준수 필요
3. **저작권 표시**: 원본 모델 및 라이센스 고지 필요

## 기술적 특징 및 혁신

### SFT+RL 시너지

1. **강화 학습의 효과**
   - 더 강한 SFT 모델이 RL 후에도 우수한 성능 유지
   - 성능 격차는 줄어들지만 상대적 우위는 지속

2. **대규모 RL 훈련**
   - 동일한 RL 레시피로 다양한 SFT 모델 훈련
   - 일관된 성능 향상 확인

### 모델 최적화

1. **메모리 효율성**
   - BF16 정밀도로 메모리 사용량 최적화
   - Safetensors 형식 지원

2. **추론 속도**
   - vLLM 엔진 최적화
   - 배치 처리 지원

## 활용 사례

### 교육 분야

1. **수학 교육**
   - 단계별 문제 해결 과정 제시
   - 다양한 난이도의 수학 문제 대응
   - 개인 맞춤형 학습 지원

2. **프로그래밍 교육**
   - 알고리즘 문제 해결 가이드
   - 코드 작성 및 디버깅 지원
   - 프로그래밍 개념 설명

### 연구 분야

1. **AI 추론 연구**
   - 수학적 추론 능력 분석
   - 다단계 추론 과정 연구
   - 강화 학습 효과 분석

2. **교육 기술 개발**
   - 지능형 튜터링 시스템
   - 자동 문제 생성 및 채점
   - 학습자 행동 분석

## 비교 분석

### 이전 버전과의 비교

| **특징** | **AceReason-Nemotron-1.0-7B** | **AceReason-Nemotron-1.1-7B** |
|---|---|---|
| 기반 모델 | DeepSeek-R1-Distill-Qwen-7B | Qwen2.5-Math-7B (더 강한 SFT) |
| AIME 2024 | 69.0 | **72.6** (+3.6%p) |
| AIME 2025 | 53.6 | **64.8** (+11.2%p) |
| LCB v5 | 51.8 | **57.2** (+5.4%p) |
| LCB v6 | 44.1 | **52.1** (+8.0%p) |

### 경쟁 모델과의 비교

**수학 추론 부문**:

- **OpenMath-Nemotron-7B**: AIME 2024에서 74.8로 최고 성능
- **AceReason-Nemotron-1.1-7B**: AIME 2025에서 64.8로 최고 성능

**코딩 추론 부문**:

- **AceReason-Nemotron-1.1-7B**: LCB v5, v6 모두에서 최고 성능
- **o3-mini**: LCB v5에서 경쟁적 성능 (60.9)

## 연구진 및 기술 지원

### 주요 연구진

- **Zihan Liu** (zihanl@nvidia.com)
- **Zhuolin Yang** (zhuoliny@nvidia.com)
- **Yang Chen** (yachen@nvidia.com)
- **Chankyu Lee** (chankyul@nvidia.com)
- **Wei Ping** (wping@nvidia.com)

### 기술 문서

- **ArXiv 논문**: [AceReason-Nemotron 1.1: Advancing Math and Code Reasoning through SFT and RL Synergy](https://arxiv.org/abs/2506.13284)
- **모델 카드**: [Hugging Face 모델 페이지](https://huggingface.co/nvidia/AceReason-Nemotron-1.1-7B)
- **평가 도구**: [GitHub 레포지토리](https://huggingface.co/nvidia/AceReason-Nemotron-14B/blob/main/README%5FEVALUATION.md)

## 결론

**NVIDIA AceReason-Nemotron-1.1-7B**는 SFT와 RL의 시너지를 통해 수학과 코딩 추론 분야에서 새로운 기준을 제시한 모델입니다. **Qwen2.5-Math-7B**라는 더 강력한 기반 모델과 체계적인 RL 훈련을 통해 이전 버전 대비 **현저한 성능 향상**을 달성했습니다.

특히 **AIME 2025**에서 64.8점을 기록하며 동급 모델 중 최고 성능을 보이고, **LiveCodeBench**에서도 일관되게 우수한 결과를 나타냅니다. **NVIDIA Open Model License**로 제공되어 연구 및 상업적 활용 모두 가능하며, 교육과 연구 분야에서 광범위한 활용이 기대됩니다.

이 모델은 AI 추론 능력의 새로운 가능성을 보여주며, 향후 더욱 발전된 추론 모델 개발의 기반이 될 것으로 예상됩니다.

## 인용 정보

```bibtex
@article{liu2025acereason,
  title={AceReason-Nemotron 1.1: Advancing Math and Code Reasoning through SFT and RL Synergy},
  author={Liu, Zihan and Yang, Zhuolin and Chen, Yang and Lee, Chankyu and Shoeybi, Mohammad and Catanzaro, Bryan and Ping, Wei},
  journal={arXiv preprint arXiv:2506.13284},
  year={2025}
}
```

## 참고 자료

- [NVIDIA AceReason-Nemotron-1.1-7B Hugging Face](https://huggingface.co/nvidia/AceReason-Nemotron-1.1-7B)
- [AceReason-1.1-SFT 데이터셋](https://huggingface.co/datasets/nvidia/AceReason-1.1-SFT)
- [ArXiv 기술 보고서](https://arxiv.org/abs/2506.13284)
- [NVIDIA Open Model License](https://developer.nvidia.com/nvidia-open-model-license)
- [평가 도구킷](https://huggingface.co/nvidia/AceReason-Nemotron-14B/blob/main/README%5FEVALUATION.md)
