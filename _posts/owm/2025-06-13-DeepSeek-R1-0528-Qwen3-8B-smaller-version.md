---
title: "DeepSeek-R1-0528-Qwen3-8B: 오픈소스 LLM의 새로운 지평"
date: 2025-06-13
categories: 
  - owm
  - ai
tags: 
  - DeepSeek
  - Qwen
  - LLM
  - Open Source
  - Reasoning
  - Model Optimization
author_profile: true
toc: true
toc_label: "목차"
---

# DeepSeek-R1-0528-Qwen3-8B: 오픈소스 LLM의 새로운 지평

DeepSeek가 최근 출시한 DeepSeek-R1-0528-Qwen3-8B는 오픈소스 대규모 언어 모델(LLM)의 새로운 이정표를 세웠습니다. 이 모델은 단일 GPU에서도 실행 가능하면서도 뛰어난 성능을 보여주는 혁신적인 모델입니다.

## 주요 특징

### 1. 효율적인 리소스 활용
- 단일 GPU에서 실행 가능 (최소 40GB VRAM 필요)
- 8B 파라미터 규모로 경량화된 버전
- MIT 라이선스로 상업적/비상업적 사용 모두 가능

### 2. 뛰어난 성능
- AIME 2025 테스트에서 76.3% 정확도 달성
- Qwen3-32B(72.9%)보다 우수한 성능
- o3-mini medium effort(76.7%)에 근접하는 성능

### 3. 기술적 특징
- 최대 64,000 토큰의 입력/출력 처리 가능
- JSON 출력 지원
- 도구 사용 기능 내장
- 추론 시 토큰 소비량 최적화

## 가격 정책
- Hugging Face를 통한 무료 사용 가능
- DeepSeek API 사용 시:
  - 일반 시간대: 입력/출력 각각 $0.14/$2.19 per 1M 토큰
  - 특별 시간대(태평양 시간 4:30 PM - 12:30 AM): 입력/출력 각각 $0.035/$0.55 per 1M 토큰

## 사용 방법

### 1. 로컬 실행
```bash
# vLLM을 사용한 서버 실행
python3 -m vllm.entrypoints.openai.api_server \
    --model deepseek-ai/DeepSeek-R1-0528-Qwen3-8B \
    --tensor-parallel-size 1 \
    --max-model-len 32768 \
    --enforce-eager

# SGLang을 사용한 서버 실행
python3 -m sglang.launch_server \
    --model deepseek-ai/DeepSeek-R1-0528-Qwen3-8B \
    --trust-remote-code \
    --tp 1
```

### 2. 사용 권장사항
- Temperature는 0.5-0.7 사이로 설정 (권장값: 0.6)
- 시스템 프롬프트는 사용하지 않음 (모든 지시사항은 사용자 프롬프트에 포함)
- 수학 문제의 경우 "Please reason step by step, and put your final answer within \boxed{}"와 같은 지시사항 포함
- 성능 평가 시 여러 번 테스트 후 평균값 사용

### 3. 추론 최적화
- 모델이 충분한 추론을 하도록 하기 위해 출력 시작을 "<think>\n"로 강제하는 것을 권장
- 긴 응답의 경우 구조화된 형식으로 작성
- 객관적 Q&A의 경우 간단한 답변에 관련 정보 1-2문장 추가

## 혁신적 접근
DeepSeek-R1-0528-Qwen3-8B는 Qwen3-8B를 기반으로 하며, DeepSeek-R1-0528의 추론 지식을 증류하여 개발되었습니다. 이는 오픈소스 모델들 간의 협력을 통한 혁신적인 접근 방식을 보여줍니다.

## 결론
DeepSeek-R1-0528-Qwen3-8B는 오픈소스 LLM의 새로운 가능성을 보여주는 중요한 모델입니다. 단일 GPU에서도 실행 가능하면서도 뛰어난 성능을 보여주는 이 모델은, 더 많은 개발자들이 고성능 AI 모델을 활용할 수 있게 해줄 것입니다.

## 참고 자료
- [Hugging Face 모델 페이지](https://huggingface.co/deepseek-ai/DeepSeek-R1-0528-Qwen3-8B)
- [DeepLearning.AI The Batch](https://www.deeplearning.ai/the-batch/deepseek-r1s-update-leads-all-open-models-and-brings-it-up-to-date-with-the-latest-from-google-and-openai/)
- [GitHub 저장소](https://github.com/deepseek-ai/DeepSeek-R1)
