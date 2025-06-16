---
title: "Mistral AI Magistral-Small-2506: 추론 능력을 갖춘 24B 파라미터 모델"
excerpt: "순수 강화학습으로 훈련된 Mistral AI의 첫 번째 추론 모델 Magistral-Small-2506을 소개합니다. 24B 파라미터로 강력한 수학적, 논리적 추론 능력을 제공하며 Apache 2.0 라이선스로 공개되었습니다."
date: 2025-06-16
categories: 
  - owm
tags: 
  - mistral-ai
  - reasoning-model
  - rlhf
  - open-source
  - magistral
author_profile: true
toc: true
toc_label: 목차
---

## 개요

Mistral AI가 2025년 6월에 발표한 **Magistral-Small-2506**은 순수 강화학습(Reinforcement Learning)으로 훈련된 첫 번째 추론 모델입니다. Mistral Small 3.1 (2503)을 기반으로 하여 추론 능력을 추가한 24B 파라미터 모델로, 복잡한 수학 문제와 논리적 추론 작업에서 뛰어난 성능을 보입니다.

이 모델의 가장 큰 특징은 기존 모델의 추론 트레이스(reasoning traces)에 의존하지 않고, 처음부터 자체 모델과 인프라만을 사용하여 개발되었다는 점입니다. 또한 Apache 2.0 라이선스로 공개되어 상업적 이용이 자유롭습니다.

## 주요 특징

### 추론 능력
- **Chain-of-Thought**: 답변을 제공하기 전에 긴 추론 과정을 거치는 능력
- **수학적 추론**: AIME-24에서 70.68% pass@1 성능 달성
- **논리적 사고**: 복잡한 문제 해결을 위한 단계별 사고 과정

### 다국어 지원
다음 24개 언어를 지원합니다:
- 아시아 언어: 한국어, 일본어, 중국어, 힌디어, 인도네시아어, 말레이어, 네팔어, 벵골어, 페르시아어
- 유럽 언어: 영어, 프랑스어, 독일어, 그리스어, 이탈리아어, 폴란드어, 포르투갈어, 루마니아어, 러시아어, 세르비아어, 스페인어, 터키어, 우크라이나어, 베트남어
- 아랍어

### 기술적 특징
- **파라미터**: 24B (240억 개)
- **컨텍스트 윈도우**: 128k 토큰 (권장: 40k 토큰)
- **토크나이저**: Tekken 토크나이저 (131k 어휘)
- **라이선스**: Apache 2.0

### 하드웨어 요구사항
- **추천 사양**: RTX 4090 또는 32GB RAM MacBook (양자화 시)
- **최소 메모리**: 양자화를 통해 단일 GPU에서 실행 가능

## 성능 벤치마크

| 모델 | AIME24 pass@1 | AIME25 pass@1 | GPQA Diamond | Livecodebench (v5) |
|------|---------------|---------------|--------------|-------------------|
| Magistral Medium | 73.59% | 64.95% | 70.83% | 59.36% |
| **Magistral Small** | **70.68%** | **62.76%** | **68.18%** | **55.84%** |

## 훈련 방법론

### 강화학습 알고리즘 (GRPO)
Magistral-Small은 Group Relative Policy Optimization (GRPO) 알고리즘을 사용하여 훈련되었습니다:

- **베이스라인 계산**: 각 프롬프트당 여러 생성물의 평균 보상을 사용
- **KL 발산 제거**: 참조 모델과의 KL 발산 패널티 제거로 계산 효율성 향상
- **어드밴티지 정규화**: 미니배치 내에서 어드밴티지 정규화 적용

### 다국어 추론 전략
모델이 사용자 언어로 추론과 답변을 모두 제공하도록 하는 간단하면서도 효과적인 전략을 구현했습니다.

## 사용법

### vLLM 설치 및 서빙 (권장)

```bash
# vLLM 설치
pip install -U vllm \
    --pre \
    --extra-index-url https://wheels.vllm.ai/nightly

# 모델 서빙
vllm serve mistralai/Magistral-Small-2506 \
    --tokenizer_mode mistral \
    --config_format mistral \
    --load_format mistral \
    --tool-call-parser mistral \
    --enable-auto-tool-choice \
    --tensor-parallel-size 2
```

### Python 코드 예제

```python
from openai import OpenAI
from huggingface_hub import hf_hub_download

# OpenAI API 설정 (vLLM 서버용)
openai_api_key = "EMPTY"
openai_api_base = "http://localhost:8000/v1"

TEMP = 0.7
TOP_P = 0.95
MAX_TOK = 40_960

client = OpenAI(
    api_key=openai_api_key,
    base_url=openai_api_base,
)

# 시스템 프롬프트 로드
def load_system_prompt(repo_id: str, filename: str) -> str:
    file_path = hf_hub_download(repo_id=repo_id, filename=filename)
    with open(file_path, "r") as file:
        system_prompt = file.read()
    return system_prompt

SYSTEM_PROMPT = load_system_prompt("mistralai/Magistral-Small-2506", "SYSTEM_PROMPT.txt")

# 질문 예제
query = "딸기(strawberry)에 'r'이 몇 개 들어있나요?"

messages = [
    {"role": "system", "content": SYSTEM_PROMPT},
    {"role": "user", "content": query}
]

# 스트리밍 생성
stream = client.chat.completions.create(
    model="mistralai/Magistral-Small-2506",
    messages=messages,
    stream=True,
    temperature=TEMP,
    top_p=TOP_P,
    max_tokens=MAX_TOK,
)

print("응답 스트리밍 시작...")
for chunk in stream:
    content = chunk.choices[0].delta.content
    if content:
        print(content, end="", flush=True)
```

### 추론 템플릿

모델은 다음과 같은 추론 템플릿을 사용합니다:

```
<think>
여기에 단계별 사고 과정을 작성합니다. 
마치 연습장에서 문제를 풀어나가는 것처럼 
자유롭고 상세하게 생각 과정을 기록합니다.
</think>

최종적으로 명확한 답변을 제공합니다.
```

### 양자화 버전 사용

메모리가 제한된 환경에서는 양자화된 버전을 사용할 수 있습니다:

**llama.cpp 사용:**
```bash
# 모델 다운로드
huggingface-cli download \
    "mistralai/Magistral-Small-2506_gguf" \
    --local-dir "mistralai/Magistral-Small-2506_gguf/"

# 실행
llama-cli --jinja \
    -m mistralai/Magistral-Small-2506_gguf/Magistral-Small-2506_Q8_0.gguf \
    --ctx-size 40960 \
    --temp 0.7 \
    --top_p 0.95
```

**Ollama 사용:**
```bash
ollama run hf.co/unsloth/Magistral-Small-2506-GGUF:UD-Q4_K_XL
```

## 추천 설정 파라미터

모델의 최적 성능을 위해 다음 파라미터를 사용하세요:

- `temperature`: 0.7
- `top_p`: 0.95
- `max_tokens`: 40,960
- `context_length`: 40,960 (권장)

## 활용 사례

### 수학 문제 해결
```python
query = """
존은 4명의 자녀 중 한 명입니다. 첫 번째 여동생은 4살입니다. 
내년에 두 번째 여동생은 첫 번째 여동생의 두 배 나이가 됩니다. 
세 번째 여동생은 두 번째 여동생보다 2살 많습니다. 
세 번째 여동생은 오빠 나이의 절반입니다. 존의 나이는?
"""
# 답: 22살
```

### 논리 추론
```python
query = """
9.11과 9.8 중 어느 것이 더 큰가요?
"""
# 답: 9.8 (소수점 자릿수 비교)
```

### 문자 개수 세기
```python
query = """
"strawberry"라는 단어에 'r'이 몇 개 들어있나요?
"""
# 답: 3개
```

## 파인튜닝 및 확장

### 지원 프레임워크
- **Axolotl**: [GitHub 예제](https://github.com/axolotl-ai-cloud/axolotl/tree/main/examples/magistral)
- **Unsloth**: [문서](https://docs.unsloth.ai/basics/magistral)

### 추가 플랫폼
- **Kaggle**: [모델 페이지](https://www.kaggle.com/models/mistral-ai/magistral-small-2506)
- **LM Studio**: GUI 환경에서 사용 가능
- **Ollama**: 간편한 로컬 실행

## 기술적 혁신

### 순수 RL 접근법
- 기존 추론 모델의 지식 증류 없이 처음부터 강화학습으로 훈련
- 자체 모델과 인프라만을 사용한 확장 가능한 RL 파이프라인
- 비동기 시스템으로 효율적인 온라인 학습 구현

### 다중 모달 능력 보존
텍스트 데이터만으로 RL 훈련을 진행했음에도 불구하고:
- 다중 모달 이해 능력 유지 또는 향상
- 함수 호출 기능 보존
- 지시사항 따르기 능력 개선

## 성능 비교

### DeepSeek-R1과의 비교
논문에서 공개된 결과에 따르면, Magistral Medium은 AIME-24에서 DeepSeek-R1과 유사한 성능을 보이며, 순수 RL 접근법의 효과를 입증했습니다.

### 베이스 모델 대비 개선
- AIME-24에서 Mistral Medium 3 대비 거의 50% 성능 향상
- 수학, 코딩, 논리 추론 작업에서 일관된 개선

## 한계점 및 고려사항

### 컨텍스트 길이
- 이론적으로 128k 토큰 지원하지만, 40k 토큰 이후 성능 저하 가능
- 최적 성능을 위해 40k 토큰 제한 권장

### 함수 호출
- GGUF 양자화된 버전에서는 함수 호출 기능 미지원
- 함수 호출이 필요한 경우 원본 모델 사용 필요

## 결론

Magistral-Small-2506은 Mistral AI의 첫 번째 추론 모델로서 다음과 같은 의의를 가집니다:

1. **순수 RL 접근법**: 기존 모델에 의존하지 않는 독립적인 개발 방식
2. **뛰어난 추론 성능**: 24B 파라미터로 강력한 수학적, 논리적 추론 능력
3. **오픈 소스**: Apache 2.0 라이선스로 자유로운 상업적 이용
4. **실용성**: 단일 GPU에서도 실행 가능한 효율적인 모델

특히 복잡한 추론이 필요한 교육, 연구, 데이터 분석 분야에서 활용도가 높을 것으로 예상되며, 오픈 소스 생태계에 중요한 기여를 할 것으로 보입니다.

## 참고 자료

- [Magistral 논문](https://arxiv.org/pdf/2506.10910): 상세한 기술적 내용과 실험 결과
- [Hugging Face 모델 페이지](https://huggingface.co/mistralai/Magistral-Small-2506): 모델 다운로드 및 사용법
- [Mistral AI 블로그](https://mistral.ai/news/magistral/): 공식 소개 및 활용 가이드