---
title: "NVIDIA AceReason-1.1-SFT: 수학·코딩 추론 특화 SFT 데이터셋 완전 가이드"
excerpt: "NVIDIA의 AceReason-1.1-SFT 데이터셋 상세 분석 - CC BY 4.0 라이센스, 400만 샘플, DeepSeek-R1 기반 고품질 수학·코딩 추론 데이터"
date: 2025-06-18
categories: 
  - datasets
  - llmops
tags: 
  - nvidia
  - acereason
  - sft
  - supervised-fine-tuning
  - math-reasoning
  - code-reasoning
  - deepseek-r1
  - dataset
  - cc-by-4.0
author_profile: true
toc: true
toc_label: "AceReason-1.1-SFT 가이드"
---

## 개요

NVIDIA에서 2025년 6월 16일에 공개한 **AceReason-1.1-SFT**는 수학과 코딩 추론에 특화된 대규모 지도 학습(Supervised Fine-Tuning) 데이터셋입니다. 이 데이터셋은 **AceReason-Nemotron-1.1-7B** 모델의 SFT 훈련 데이터로 사용되었으며, 모든 응답이 **DeepSeek-R1** 모델에 의해 생성되었습니다.

총 **3,970,332개**의 샘플로 구성되어 있으며, 수학 추론 데이터 **2,668,741개**와 코딩 추론 데이터 **1,301,591개**를 포함합니다.

## 데이터셋 상세 정보

### 기본 정보

- **데이터셋명**: AceReason-1.1-SFT
- **개발사**: NVIDIA
- **릴리즈 날짜**: 2025년 6월 16일
- **라이센스**: [Creative Commons Attribution 4.0 International License (CC BY 4.0)](https://creativecommons.org/licenses/by/4.0/legalcode)
- **언어**: 영어
- **형식**: Arrow, Parquet
- **크기**: 1M - 10M 샘플 (약 400만 개)

### 기술적 사양

- **ArXiv 논문**: [arXiv:2506.13284](https://arxiv.org/abs/2506.13284)
- **Hugging Face**: [nvidia/AceReason-1.1-SFT](https://huggingface.co/datasets/nvidia/AceReason-1.1-SFT)
- **파일 크기**: 약 2.19GB (처음 5GB까지의 Parquet 파일)
- **추정 총 행 수**: 3,958,018개

## 데이터 소스 및 구성

### 소스별 통계

| **데이터 소스** | **문제 수** | **샘플 수** | **비율** |
|---|---|---|---|
| OpenMathReasoning | 270,534 | 2,147,570 | 54.1% |
| NuminaMath-CoT | 78,880 | 521,171 | 13.1% |
| OpenCodeReasoning | 35,374 | 763,495 | 19.2% |
| MagicoderEvolInstruct | 27,625 | 27,625 | 0.7% |
| opc-sft-stage2 | 79,938 | 323,163 | 8.1% |
| leetcode | 5,571 | 126,878 | 3.2% |
| TACO | 16,726 | 56,694 | 1.4% |
| apps | 159 | 3,736 | 0.1% |
| **총합** | **514,807** | **3,970,332** | **100%** |

### 카테고리별 분포

- **수학 추론**: 2,668,741 샘플 (67.2%)
  - OpenMathReasoning: 2,147,570 샘플
  - NuminaMath-CoT: 521,171 샘플

- **코딩 추론**: 1,301,591 샘플 (32.8%)
  - OpenCodeReasoning: 763,495 샘플
  - opc-sft-stage2: 323,163 샘플
  - leetcode: 126,878 샘플
  - TACO: 56,694 샘플
  - MagicoderEvolInstruct: 27,625 샘플
  - apps: 3,736 샘플

## 데이터 품질 및 전처리

### 데이터 정제 과정

1. **응답 생성**: 모든 응답이 DeepSeek-R1 모델에 의해 생성되어 일관된 품질 보장
2. **중복 제거**: 수학 및 코딩 벤치마크의 테스트 샘플과 9-gram 중복이 있는 샘플 필터링
3. **품질 검증**: 고품질 추론 과정과 정확한 답변을 포함한 샘플만 선별

### 데이터 구조

각 샘플은 다음과 같은 구조를 가집니다:

```json
{
  "category": "math" | "code",
  "source": "데이터 소스명",
  "input": "문제 또는 질문",
  "output": "상세한 추론 과정과 답변"
}
```

## 라이센스 및 사용 조건

### CC BY 4.0 라이센스

AceReason-1.1-SFT 데이터셋은 **Creative Commons Attribution 4.0 International License**로 제공됩니다.

**허용사항**:

- **상업적 사용**: 영리 목적으로 사용 가능
- **수정**: 데이터셋 수정 및 변형 가능
- **배포**: 원본 및 수정된 버전 배포 가능
- **사적 사용**: 개인적 용도로 사용 가능

**의무사항**:

- **저작자 표시**: 원본 저작자(NVIDIA) 및 라이센스 명시 필요
- **라이센스 표시**: CC BY 4.0 라이센스 고지 필요
- **변경사항 표시**: 수정한 경우 변경사항 명시 권장

## 활용 방안

### SFT 모델 훈련

```python
# 데이터셋 로드 예시
from datasets import load_dataset

dataset = load_dataset("nvidia/AceReason-1.1-SFT")

# 수학 추론 데이터만 필터링
math_data = dataset.filter(lambda x: x['category'] == 'math')

# 코딩 추론 데이터만 필터링
code_data = dataset.filter(lambda x: x['category'] == 'code')
```

### 추천 사용 사례

1. **수학 추론 모델 개발**
   - 수학 문제 해결 능력 향상
   - 단계별 추론 과정 학습
   - 수학적 개념 이해도 증진

2. **코딩 추론 모델 개발**
   - 알고리즘 문제 해결 능력
   - 코드 생성 및 디버깅
   - 프로그래밍 논리 강화

3. **멀티모달 추론 모델**
   - 수학과 코딩을 통합한 STEM 추론
   - 문제 해결 능력 종합 평가
   - 교육용 AI 시스템 개발

## 기술적 세부사항

### 데이터 접근 방법

```python
# Hugging Face Datasets를 이용한 접근
from datasets import load_dataset

# 전체 데이터셋 로드
dataset = load_dataset("nvidia/AceReason-1.1-SFT")

# 스트리밍 모드 (메모리 효율적)
dataset = load_dataset("nvidia/AceReason-1.1-SFT", streaming=True)

# 특정 비율만 샘플링
dataset = load_dataset("nvidia/AceReason-1.1-SFT", split="train[:10%]")
```

### 저장 형식

- **Arrow**: 메모리 효율적인 컬럼형 데이터 형식
- **Parquet**: 압축 효율성과 쿼리 성능 최적화
- **JSON**: 호환성이 높은 텍스트 형식

## 벤치마크 및 성능

### AceReason-Nemotron-1.1-7B 성과

이 데이터셋으로 훈련된 AceReason-Nemotron-1.1-7B 모델은 다음과 같은 벤치마크에서 우수한 성능을 보입니다:

- **수학 추론**: GSM8K, MATH, AMC 등
- **코딩 추론**: HumanEval, MBPP, CodeContests 등
- **종합 추론**: 다양한 STEM 관련 평가

## 연구진 및 연락처

### 주요 연구진

- **Zihan Liu** (zihanl@nvidia.com)
- **Zhuolin Yang** (zhuoliny@nvidia.com)
- **Yang Chen** (yachen@nvidia.com)
- **Chankyu Lee** (chankyul@nvidia.com)
- **Wei Ping** (wping@nvidia.com)

### 인용 정보

```bibtex
@article{liu2025acereason,
  title={AceReason-Nemotron 1.1: Advancing Math and Code Reasoning through SFT and RL Synergy},
  author={Liu, Zihan and Yang, Zhuolin and Chen, Yang and Lee, Chankyu and Shoeybi, Mohammad and Catanzaro, Bryan and Ping, Wei},
  journal={arXiv preprint arXiv:2506.13284},
  year={2025}
}
```

## 윤리적 고려사항

NVIDIA는 신뢰할 수 있는 AI 개발을 위한 정책과 실행 방안을 수립하고 있습니다. 개발자들은:

1. **내부 모델 팀과 협력**하여 해당 산업 및 사용 사례 요구사항 충족 확인
2. **예상치 못한 제품 오용** 문제 해결
3. **보안 취약점** 발견 시 NVIDIA AI Concerns에 신고

## 결론

NVIDIA AceReason-1.1-SFT는 수학과 코딩 추론 분야에서 높은 품질을 자랑하는 대규모 SFT 데이터셋입니다. **CC BY 4.0 라이센스**로 제공되어 상업적 사용이 가능하며, **DeepSeek-R1** 기반의 고품질 응답으로 구성되어 있어 추론 능력이 뛰어난 AI 모델 개발에 매우 유용한 자원입니다.

특히 **400만 개에 가까운 샘플** 규모와 **8개 주요 데이터 소스**의 다양성은 이 데이터셋을 수학·코딩 추론 모델 개발의 새로운 표준으로 만들어줍니다.

## 참고 자료

- [NVIDIA AceReason-1.1-SFT Hugging Face](https://huggingface.co/datasets/nvidia/AceReason-1.1-SFT)
- [ArXiv 논문: AceReason-Nemotron 1.1](https://arxiv.org/abs/2506.13284)
- [Creative Commons BY 4.0 License](https://creativecommons.org/licenses/by/4.0/legalcode)
- [NVIDIA AI Trustworthy AI Policies](https://www.nvidia.com/en-us/ai-data-science/ai-governance/)
