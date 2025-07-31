---
title: "Qwen3-4B GRPO 학습 완전 가이드 - 한국어 추론 데이터셋 활용 및 Colab 노트북 분석"
excerpt: "Qwen3-4B 모델의 GRPO(Gradient-based Reasoning Policy Optimization) 학습 과정을 상세 분석하고, 한국어 추론 데이터셋을 활용한 효과적인 모델 훈련 방법을 제공합니다."
seo_title: "Qwen3-4B GRPO 한국어 추론 모델 훈련 가이드 - Thaki Cloud"
seo_description: "Qwen3-4B 모델의 GRPO 학습 과정 완전 분석. Colab 노트북 해부부터 한국어 추론 데이터셋 활용법까지 실무진을 위한 상세 가이드."
date: 2025-07-30
last_modified_at: 2025-07-30
categories:
  - llmops
  - tutorials
tags:
  - Qwen3-4B
  - GRPO
  - 한국어추론
  - 강화학습
  - Colab
  - Unsloth
  - 추론모델
  - 데이터셋
  - 알리바바
  - Korean-Reasoning
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "brain"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/llmops/qwen3-4b-grpo-korean-reasoning-training-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 8분

## Colab 노트북 분석 및 한국어 데이터셋 활용 가이드

본 문서는 제공된 Colab 노트북의 분석 결과를 바탕으로 모델 학습에 사용된 주요 요소들을 설명하고, 한국어 데이터셋을 활용하여 모델을 학습시키기 위한 구체적인 가이드를 제공합니다.

### 1. Colab 노트북 분석 결과

#### 1.1 사용된 데이터셋
- **사전 학습 (Pre-finetuning):** `unsloth/OpenMathReasoning-mini` 데이터셋의 일부를 사용하여 모델이 커스텀 GRPO 포맷팅에 익숙해지도록 학습시켰습니다. 이 데이터셋은 Open Math Reasoning 데이터셋 중 DeepSeek R1 추론 과정을 포함하는 고품질 샘플을 필터링한 것입니다.
- **GRPO 학습:** `open-r1/DAPO-Math-17k-Processed` 데이터셋 (영어 버전)을 사용하여 모델의 추론 능력을 강화하는 GRPO 학습을 진행했습니다. 이 데이터셋은 다양한 수학 문제와 그 해답을 포함하고 있습니다.

#### 1.2 사용된 프레임워크 및 라이브러리
- **Unsloth:** LoRA 모델 학습 속도 최적화를 위한 핵심 프레임워크입니다.
- **Hugging Face Transformers:** 모델 로딩, 토큰화 등 기본적인 자연어 처리 작업을 수행합니다.
- **trl:** SFT (Supervised Fine-Tuning) 및 GRPO (Gradient-based Reasoning Policy Optimization)와 같은 고급 학습 기법을 구현하는 데 사용됩니다.
- **datasets:** 데이터셋 로딩, 전처리 및 관리를 효율적으로 처리합니다.
- **vllm:** 학습된 모델의 빠른 추론을 지원합니다.
- **torch:** 딥러닝 연산을 위한 파이토치 라이브워크입니다.

#### 1.3 학습 설정
- **SFT 사전 학습:**
    - **Epochs:** 2
    - **Learning Rate:** 2e-4
    - **Batch Size (per device):** 1
    - **Gradient Accumulation Steps:** 1
- **GRPO 학습:**
    - **Max Steps:** 100 (전체 데이터셋에 대해 1 Epoch를 완료하려면 이 값을 조정해야 합니다.)
    - **Learning Rate:** 5e-6
    - **Batch Size (per device):** 4 (num_generations와 동일하게 설정됨)
    - **Gradient Accumulation Steps:** 1 (더 부드러운 학습을 위해 4로 늘릴 수 있습니다.)
    - **num_generations:** 4 (메모리 부족 시 감소시킬 수 있습니다.)
    - **max_prompt_length:** 202 (데이터셋의 90% 분위수 길이 + 1)
    - **max_completion_length:** 1846 (max_seq_length - max_prompt_length)

#### 1.4 학습 시간 및 권장 GPU
- **SFT 사전 학습 시간:** 약 2.8분 (170.89 초)
- **GRPO 학습 시간:** 약 2.95 시간 (10607.69 초)
- **권장 GPU:** **Tesla T4**. 노트북 실행 환경 및 Unsloth 초기화 결과에서 확인되었습니다.

### 2. 한국어 추론 데이터셋 목록

한국어 추론 모델 학습에 활용될 수 있는 Hugging Face Hub의 데이터셋 목록입니다.

| Dataset Name                                            | Description               | Source           |
|---------------------------------------------------------|---------------------------|------------------|
| lemon-mint/korean_reasoning_v0.1                        | No description available. | Hugging Face Hub |
| lemon-mint/korean_reasoning_v0.2                        | No description available. | Hugging Face Hub |
| lemon-mint/korean_reasoning_v1.0                        | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-sample                  | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-test                    | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01                         | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02                         | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01                  | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02-raw                     | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v02-raw-conversational      | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-raw                     | No description available. | Hugging Face Hub |
| lemon-mint/korean-reasoning-v01-raw-conversational      | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-raw              | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-raw-conversational | No description available. | Hugging Face Hub |
| lemon-mint/korean-realqa-reasoning-v01-preference       | No description available. | Hugging Face Hub |
| exp-models/korean-reasoning-mixture-20250203-preference | No description available. | Hugging Face Hub |
| exp-models/korean-reasoning-mixture-20250203-plaintext  | No description available. | Hugging Face Hub |
| koreankiwi99/mnlp_stem_reasoning                        | No description available. | Hugging Face Hub |

### 3. 한국어 데이터셋 활용 학습 가이드

한국어 데이터셋을 사용하여 모델을 학습시키려면 기존 노트북 코드의 일부 수정이 필요합니다. 다음은 주요 수정 방향입니다.

#### 3.1 데이터셋 로딩

`datasets` 라이브러리의 `load_dataset` 함수를 사용하여 원하는 한국어 데이터셋을 로딩합니다.

```python
from datasets import load_dataset

# 예시: 'lemon-mint/korean_reasoning_v0.1' 데이터셋 로딩
# 데이터셋에 따라 split 이름 ('train', 'validation', 'test' 등)이 다를 수 있습니다.
dataset = load_dataset("lemon-mint/korean_reasoning_v0.1", split="train")
```

#### 3.2 데이터 전처리 및 포맷팅

GRPO 학습을 위해서는 데이터셋이 특정 대화 형식 (`system`, `user`, `assistant`) 및 추론/해답 포맷 (`<start_working_out>`, `<end_working_out>`, `<SOLUTION>`, `</SOLUTION>`)을 따라야 합니다. 로딩한 한국어 데이터셋의 구조에 맞게 전처리 및 포맷팅 함수를 수정해야 합니다.

- **컬럼 매핑:** 로딩한 데이터셋의 문제(prompt)와 해답(solution) 컬럼 이름이 원본 노트북과 다를 수 있습니다. 데이터셋 정보를 확인하여 컬럼 이름을 매핑하거나 직접 접근하도록 코드를 수정합니다.

```python
# 데이터셋 컬럼 이름 확인 후 필요에 따라 수정
# dataset = dataset.rename_columns({"original_prompt_col": "prompt", "original_solution_col": "solution"})
```

- **커스텀 포맷팅 함수 (`format_dataset` 수정):** 원본 노트북의 `format_dataset` 함수는 영어 데이터셋의 `<think>` 및 `</think>` 태그를 제거하고 새로운 GRPO 태그를 추가하는 방식입니다. 한국어 데이터셋의 경우, 문제와 해답 텍스트의 구성 방식에 따라 이 함수를 완전히 새로 작성하거나 수정해야 합니다. 목표는 각 샘플을 `{% raw %}{"role": "system", "content": system_prompt}, {"role": "user", "content": 문제}, {"role": "assistant", "content": "<start_working_out>추론 과정<end_working_out><SOLUTION>해답</SOLUTION>"}{% endraw %}` 형태의 대화 메시지 리스트로 변환하는 것입니다. 한국어 데이터셋에 추론 과정이 포함되어 있다면 해당 부분을 추출하여 `<start_working_out>`와 `<end_working_out>` 사이에 넣고, 최종 해답은 `<SOLUTION>`와 `</SOLUTION>` 사이에 넣습니다.

```python
def format_korean_dataset(x):
    # 한국어 데이터셋의 구조에 맞게 문제와 해답 추출
    problem = x["prompt"] # 예시: 'prompt' 컬럼에 문제가 있다고 가정
    solution = x["solution"] # 예시: 'solution' 컬럼에 해답이 있다고 가정

    # 한국어 데이터셋의 해답 구조에 따라 추론 과정과 최종 해답 분리 및 포맷팅
    # 예시: 해답이 '추론 과정###최종 해답' 형태일 경우
    # parts = solution.split("###")
    # thoughts = parts[0].strip() if len(parts) > 1 else ""
    # answer = parts[-1].strip()

    # 한국어 데이터셋의 해답이 최종 해답만 포함하는 경우
    thoughts = "해당 데이터셋은 추론 과정을 포함하지 않습니다." # 또는 다른 기본값 설정
    answer = solution.strip()


    final_prompt = \
        reasoning_start + thoughts + reasoning_end + \
        solution_start + answer + solution_end

    return [
        {"role" : "system",    "content" : system_prompt},
        {"role" : "user",      "content" : problem},
        {"role" : "assistant", "content" : final_prompt},
    ]

# 데이터셋에 적용
dataset["Messages"] = dataset.apply(format_korean_dataset, axis = 1)
```
- **토큰화 및 길이 필터링:** 포맷팅된 메시지를 토큰화하고 `max_seq_length`에 맞춰 길이를 필터링하는 과정은 원본 노트북과 동일하게 적용할 수 있습니다. 다만, 한국어 토큰화 시 길이가 달라질 수 있으므로 `maximum_length` 계산 결과를 확인해야 합니다.

#### 3.3 reward 함수 수정

GRPO 학습의 핵심인 reward 함수들도 한국어 데이터셋의 특성에 맞게 수정해야 할 수 있습니다.

- **`match_format` 및 관련 함수:** `match_format_exactly`, `match_format_approximately` 함수는 정의된 GRPO 태그(`reasoning_end`, `solution_start`, `solution_end`)를 사용하므로 태그 자체를 변경하지 않았다면 별도 수정 없이 사용 가능합니다.
- **`check_answer` 및 `check_numbers` 함수:** 이 함수들은 생성된 텍스트에서 최종 해답을 추출하고 정답 여부를 판단합니다. 한국어 데이터셋의 해답 형식이 숫자 외 다른 형태 (예: 한글 문장)라면 `match_numbers` 정규 표현식을 수정하거나 해답 비교 로직을 변경해야 합니다. 숫자로 된 해답의 경우에도 한국어 숫자 표현 방식에 따라 추가적인 전처리 (예: 쉼표 제거)가 필요할 수 있습니다.

```python
import re

# 한국어 숫자 및 관련 기호 포함하도록 정규 표현식 수정 필요성 검토
# match_numbers = re.compile(...)

# check_answer 및 check_numbers 함수 내 해답 추출 및 비교 로직 수정 필요성 검토
# 특히 숫자가 아닌 해답을 다루는 경우 로직 변경 필요
```

#### 3.4 GRPO Trainer 설정

`GRPO Trainer` 설정 시 `max_prompt_length` 및 `max_completion_length`는 한국어 데이터셋의 토큰화 결과 길이를 바탕으로 다시 계산하여 적용해야 합니다. 나머지 GRPO 설정 (`learning_rate`, `num_generations` 등)은 모델과 데이터셋의 특성에 맞게 실험적으로 조정할 수 있습니다.

### 4. 결론

본 문서는 Qwen3-4B 모델의 GRPO 학습 과정을 분석하고, 이를 바탕으로 한국어 데이터셋을 활용한 학습 방안을 제시했습니다. 한국어 데이터셋의 특성에 맞게 데이터 전처리 및 reward 함수를 적절히 수정하는 것이 성공적인 모델 학습의 핵심입니다. 제공된 가이드라인을 참고하여 한국어 추론 모델 개발에 활용하시기 바랍니다.