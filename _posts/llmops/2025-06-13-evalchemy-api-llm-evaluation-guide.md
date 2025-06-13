---
title: "Evalchemy로 API 호출만으로 100+ LLM 모델 평가하기: 설치 없는 벤치마크 완벽 가이드"
excerpt: "Evalchemy + Curator + LiteLLM 조합으로 GPT-4o, Claude-3, Gemini 등 100여 종 API 모델을 설치 없이 평가하는 방법을 단계별로 알아봅니다."
date: 2025-06-13
categories: 
  - llmops
  - dev
tags: 
  - Evalchemy
  - LLM 평가
  - Curator
  - LiteLLM
  - 벤치마크
  - API 호출
  - MLOps
author_profile: true
toc: true
toc_label: "목차"
---

## 한눈에 보는 핵심 요약

**Evalchemy**는 원래 로컬에 모델을 설치해 올리는(HuggingFace, vLLM 등) 방식을 기본으로 하지만, **Curator 모델 어댑터**(LiteLLM 연동)와 **LM-Eval-Harness의 OpenAI / Anthropic / 기타 API 백엔드** 덕분에 **REST API로만** 모델을 호출해 동일한 벤치마크를 실행할 수 있습니다.

즉, `--model curator` 또는 `--model openai` 같이 CLI 플래그만 바꾸면 GPT-4o, Claude-3, Gemini-2, 자체 vLLM 서버 등 **100여 종 이상의 API 모델**을 설치 없이 평가할 수 있습니다.

이 가이드에서는 환경 설정부터 대표적인 세 가지 패턴(공식 OpenAI, 사내 vLLM OpenAI-호환 엔드포인트, Google Gemini)까지 단계별로 살펴보겠습니다.

## 사전 준비

### 의존성 설치

```bash
# Conda 환경 생성 (권장)
conda create -n evalchemy python=3.10
conda activate evalchemy

# Evalchemy + Curator + LiteLLM 설치
pip install -e "git+https://github.com/mlfoundations/Evalchemy.git#egg=evalchemy[eval]" 
pip install bespokelabs-curator litellm  # Curator-LiteLLM 연결용
```

**Evalchemy**는 LM-Eval-Harness를 래핑하고 있어 추가 패키지가 자동으로 설치됩니다.

### API 크리덴셜 설정

```bash
export OPENAI_API_KEY="<your-openai-key>"
export ANTHROPIC_API_KEY="<your-anthropic-key>"
export GEMINI_API_KEY="<your-gcp-vertex-ai-key>"
# 자체 vLLM 서버라면 별도 키가 없거나 dummy 값을 사용
```

LiteLLM는 환경 변수를 그대로 읽어 각 API 제공자에게 전달합니다.

## CLI 형식 이해하기

| 인자 | 의미 | 예시 |
|------|------|------|
| `--model` | 백엔드 유형<br>(`curator`, `openai`, `anthropic` 등) | `--model curator` |
| `--model_name` | `provider/model` 표기<br>(LiteLLM 규칙) | `openai/gpt-4o-mini` |
| `--model_args` | API 베이스 URL‧토큰화 옵션 등<br>`key=value` 콤마 구분 | `api_base=https://api.openai.com/v1` |
| `--tasks` | 벤치마크 리스트(쉼표 구분) | `MTBench,LiveCodeBench` |
| 기타 | `--batch_size`, `--apply_chat_template`, `--output_path` 등 | - |

상세 옵션은 README와 `configs/` 폴더의 YAML 예시에서 확인할 수 있습니다.

## 대표 시나리오별 명령어

### OpenAI GPT-4o 평가

```bash
python -m eval.eval \
  --model curator \
  --tasks MTBench,LiveCodeBench \
  --model_name "openai/gpt-4o-mini" \
  --model_args "api_base=https://api.openai.com/v1" \
  --batch_size 8 \
  --output_path logs/gpt4o.json
```

Curator → LiteLLM을 통해 OpenAI ChatCompletion 엔드포인트로 요청이 전달됩니다.

### 사내 vLLM (OpenAI-호환) 서버 평가

```bash
python -m eval.eval \
  --model curator \
  --tasks AIME24,MATH500 \
  --model_name "openai/hf-mistral-7b-instruct" \
  --model_args "api_base=http://vllm.company.local:8000/v1,api_key=dummy" \
  --apply_chat_template True \
  --output_path logs/mistral_vllm.json
```

**LiteLLM**의 "`openai/` prefix" 규칙과 `api_base` 플래그로 어떤 OpenAI-호환 서버라도 호출 가능합니다.

### Google Gemini-2 (Vertex AI) 평가

```bash
python -m eval.eval \
  --model curator \
  --tasks AIME24,GPQADiamond \
  --model_name "gemini/gemini-2.0-flash-thinking-exp-01-21" \
  --model_args "project_id=my-gcp-project" \
  --apply_chat_template False \
  --output_path logs/gemini.json
```

Curator가 **Gemini** 전용 래퍼를 제공해 별도 설치 없이 동작합니다.

## 고급 활용 팁

### YAML 컨피그로 반복 작업 단축

`configs/light_gpt4omini0718.yaml` 같은 예시 파일에 `tasks`, `batch_size` 등을 정의한 뒤:

```bash
python -m eval.eval \
  --model curator \
  --model_name openai/gpt-4o-mini \
  --config configs/light_gpt4omini0718.yaml
```

이렇게 호출하면 CLI가 간결해집니다.

### 비동기‧배치 처리 최적화

LM-Eval-Harness v0.4부터 OpenAI 스타일 API 호출 시 `batch_size`와 `--parallelism` 플래그가 지원되어 토큰 단가를 크게 절감할 수 있습니다.

```bash
python -m eval.eval \
  --model curator \
  --model_name "openai/gpt-4o-mini" \
  --batch_size 16 \
  --tasks MTBench \
  --parallelism 4
```

### 결과 해석

```bash
jq '.results' logs/gpt4o.json             # 각 벤치마크별 메트릭
jq '.config'  logs/gpt4o.json             # 실행 당시 CLI 옵션 기록
```

JSON 구조는 LM-Eval-Harness 표준을 따르므로 기존 파이프라인에 바로 연동 가능합니다.

## 문제 해결 FAQ

| 증상 | 원인 · 해결책 |
|------|---------------|
| `401 Unauthorized` | API 키 환경 변수 누락 → `echo $OPENAI_API_KEY` 확인 |
| `Not Found /v1` | `api_base` 뒤에 `/v1` 빠짐 → `http://host:port/v1` 형식 필수 |
| `ValueError: must set tokenized_requests` | 일부 모델(예: Gemini)에서 필요 → `--model_args 'tokenized_requests=False'` 추가 |
| 속도가 너무 느림 | `batch_size` 조정, LiteLLM proxy에서 **stream=False** 사용 권장 |

### 추가 디버깅 팁

**로그 레벨 조정**
```bash
export LOGLEVEL=DEBUG
python -m eval.eval --model curator --model_name "openai/gpt-4o-mini" --tasks MTBench
```

**네트워크 연결 테스트**
```bash
curl -H "Authorization: Bearer $OPENAI_API_KEY" \
     -H "Content-Type: application/json" \
     -d '{"model":"gpt-4o-mini","messages":[{"role":"user","content":"Hello"}]}' \
     https://api.openai.com/v1/chat/completions
```

## 실제 사용 사례

### 모델 스크리닝 워크플로우

```bash
#!/bin/bash
# 여러 모델을 동시에 평가하는 스크립트

models=(
  "openai/gpt-4o-mini"
  "anthropic/claude-3-haiku-20240307"
  "gemini/gemini-1.5-flash"
)

for model in "${models[@]}"; do
  echo "Evaluating $model..."
  python -m eval.eval \
    --model curator \
    --model_name "$model" \
    --tasks MTBench,MATH500 \
    --batch_size 8 \
    --output_path "logs/$(echo $model | tr '/' '_').json" &
done

wait
echo "All evaluations completed!"
```

### CI/CD 파이프라인 통합

```yaml
# .github/workflows/model-evaluation.yml
name: Model Evaluation

on:
  push:
    branches: [ main ]
  pull_request:
    branches: [ main ]

jobs:
  evaluate:
    runs-on: ubuntu-latest
    steps:
    - uses: actions/checkout@v3
    - name: Set up Python
      uses: actions/setup-python@v3
      with:
        python-version: '3.10'
    
    - name: Install dependencies
      run: |
        pip install -e "git+https://github.com/mlfoundations/Evalchemy.git#egg=evalchemy[eval]"
        pip install bespokelabs-curator litellm
    
    - name: Run evaluation
      env:
        OPENAI_API_KEY: ${{ secrets.OPENAI_API_KEY }}
      run: |
        python -m eval.eval \
          --model curator \
          --model_name "openai/gpt-4o-mini" \
          --tasks MTBench \
          --output_path results.json
    
    - name: Upload results
      uses: actions/upload-artifact@v3
      with:
        name: evaluation-results
        path: results.json
```

## 비용 최적화 전략

### 토큰 사용량 모니터링

```python
import json
import tiktoken

def estimate_cost(log_file, model_name="gpt-4o-mini"):
    """평가 결과에서 토큰 사용량과 비용 추정"""
    with open(log_file, 'r') as f:
        results = json.load(f)
    
    # 입력 토큰 수 계산 (예시)
    encoder = tiktoken.encoding_for_model("gpt-4o-mini")
    total_tokens = 0
    
    for task_result in results.get('results', {}).values():
        if 'samples' in task_result:
            for sample in task_result['samples']:
                if 'prompt' in sample:
                    total_tokens += len(encoder.encode(sample['prompt']))
    
    # OpenAI 가격 기준 (2024년 기준)
    cost_per_1k_tokens = 0.00015  # gpt-4o-mini 입력 토큰 기준
    estimated_cost = (total_tokens / 1000) * cost_per_1k_tokens
    
    print(f"Total tokens: {total_tokens:,}")
    print(f"Estimated cost: ${estimated_cost:.4f}")

# 사용 예시
estimate_cost("logs/gpt4o.json")
```

### 배치 크기 최적화

```bash
# 작은 배치로 시작해서 점진적으로 증가
for batch_size in 1 4 8 16; do
  echo "Testing batch_size=$batch_size"
  time python -m eval.eval \
    --model curator \
    --model_name "openai/gpt-4o-mini" \
    --tasks MTBench \
    --batch_size $batch_size \
    --output_path "logs/batch_${batch_size}.json"
done
```

## 정리

**핵심 장점**
- **설치 대신 REST API 호출만으로** 동일한 벤치마크를 손쉽게 재현
- **OpenAI, Anthropic, Google 등 다양한 LLM 제공자**를 단일 CLI로 테스트
- **YAML 컨피그와 비동기 배치 기능**으로 비용과 시간 대폭 절약

**활용 시나리오**
- GPU 자원 확보 전 신속한 모델 스크리닝
- 여러 API 제공자 간 성능 비교 분석
- CI/CD 파이프라인에서 자동화된 모델 평가
- 비용 효율적인 대규모 벤치마크 실행

Evalchemy + Curator + LiteLLM 조합을 사내 MLOps 파이프라인에 통합하면 **GPU 자원 확보 전에도 신속한 모델 스크리닝과 회귀 테스트**가 가능합니다. 

특히 API 기반 평가는 로컬 GPU 환경 구축 비용 없이도 다양한 최신 모델들을 즉시 검증할 수 있어, 빠르게 변화하는 LLM 생태계에서 경쟁력을 유지하는 데 필수적인 도구가 되고 있습니다.

---

**참고 자료:**
- [Evalchemy GitHub 저장소](https://github.com/mlfoundations/Evalchemy)
- [Bespoke Curator 문서](https://docs.bespokelabs.ai/bespoke-curator/getting-started)
- [LiteLLM 공식 문서](https://docs.litellm.ai/docs/providers)
- [LM-Eval-Harness](https://github.com/EleutherAI/lm-evaluation-harness)
- [OpenAI API 문서](https://platform.openai.com/docs/models) 