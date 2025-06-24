---
title: "MultiFinBen: 다국어·다중모달 금융 LLM 평가 벤치마크 완전 가이드"
excerpt: "최초의 다국어·다중모달 금융 도메인 벤치마크 - 5개 언어, 텍스트·비전·오디오 모달리티, 22개 SOTA 모델 평가 결과"
date: 2025-06-24
categories: 
  - datasets
tags: 
  - multifinben
  - multilingual
  - multimodal
  - financial-llm
  - benchmark
  - polyfiiqa
  - ocr
  - evaluation
  - cross-lingual
  - finai
author_profile: true
toc: true
toc_label: "MultiFinBen 가이드"
---

## 개요

**MultiFinBen**은 글로벌 금융 도메인을 위한 최초의 다국어·다중모달 벤치마크입니다. 기존 금융 벤치마크가 단일언어·단일모달에 제한되어 실제 금융 업무의 복잡성을 반영하지 못한다는 한계를 극복하기 위해 개발되었습니다.

이 벤치마크는 **5개 언어(영어, 중국어, 일본어, 스페인어, 그리스어)**와 **3개 모달리티(텍스트, 비전, 오디오)**를 지원하며, 22개 최신 모델을 대상으로 한 광범위한 평가를 통해 현재 LLM들이 복잡한 다국어·다중모달 금융 태스크에서 현저한 성능 저하를 보인다는 중요한 발견을 제시합니다.

## 데이터셋 상세 정보

### 기본 정보

- **벤치마크명**: MultiFinBen (Multilingual, Multimodal, and Difficulty-Aware Financial Benchmark)
- **개발기관**: The FinAI 등 20개 대학·연구기관 협력
- **공개일**: 2024년
- **라이센스**: 다양 (CC BY 4.0, CC BY-NC, MIT License 등)
- **언어**: 영어, 중국어, 일본어, 스페인어, 그리스어
- **모달리티**: 텍스트, 비전(차트/표/OCR), 오디오

### 벤치마크 구성

MultiFinBen은 **32개 데이터셋**으로 구성되며, 다음과 같은 태스크를 포함합니다:

| **태스크 유형** | **설명** | **데이터셋 수** |
|---|---|---|
| **IE (정보 추출)** | 금융 엔티티 및 관계 추출 | 4개 |
| **TA (텍스트 분석)** | 감정 분석, 분류 | 8개 |
| **QA (질의응답)** | 금융 문서 기반 Q&A | 8개 |
| **TG (텍스트 생성)** | 요약, 보고서 생성 | 4개 |
| **RM (위험 관리)** | 신용 위험, 사기 탐지 | 2개 |
| **FO (금융 예측)** | 주가, 트렌드 예측 | 2개 |
| **DM (의사결정)** | 투자 결정 지원 | 1개 |
| **비전** | OCR, 차트/표 분석 | 2개 |
| **오디오** | 음성 기반 분석 | 1개 |

## 혁신적 기여사항

### 1. 새로운 다국어 태스크

#### PolyFiQA-Easy & PolyFiQA-Expert
- **최초의 다국어 금융 벤치마크**: 혼합 언어 입력에 대한 복잡한 추론 요구
- **Easy**: 재무제표 기반 답변, 뉴스로 검증
- **Expert**: 뉴스 기반 답변, 재무제표로 검증
- **고품질 주석**: 금융 전문가들이 직접 주석 작업 수행

#### 데이터 구조 예시
```json
{
  "question": "What was Apple's revenue growth in Q3 2023?",
  "financial_statements": "...",
  "english_news": "...",
  "chinese_news": "...",
  "japanese_news": "...",
  "spanish_news": "...",
  "greek_news": "...",
  "answer": "Apple's revenue grew by 1.4% YoY...",
  "evidence": "According to the financial statements..."
}
```

### 2. OCR 임베디드 금융 태스크

#### EnglishOCR & SpanishOCR
- **최초의 OCR 임베디드 금융 QA**: 시각-텍스트 금융 문서에서 정보 추출 및 추론
- **실제 금융 문서**: 연차보고서, 재무제표, 투자 보고서 등
- **복합 추론**: OCR 텍스트 추출 + 금융 지식 추론

### 3. 난이도 인식 선별 메커니즘

기존 벤치마크의 단순 집계 방식을 넘어선 **동적 난이도 인식 선별**:

```python
# 난이도 분류 기준
difficulty_levels = {
    'Easy': '기본적인 정보 추출, 단순 계산',
    'Medium': '중간 수준의 추론, 도메인 지식 필요',
    'Hard': '복잡한 다단계 추론, 전문 지식 요구'
}
```

## 주요 평가 결과

### 모델별 성능 분석

22개 최신 모델을 평가한 결과, **강력한 다중모달·다국어 능력을 가진 모델들도 금융 도메인의 복잡한 크로스링구얼·다중모달 태스크에서 현저한 성능 저하**를 보였습니다.

#### 주요 발견사항

1. **언어별 성능 격차**: 영어 대비 다른 언어에서 10-30% 성능 저하
2. **모달리티 통합의 어려움**: 텍스트+비전 태스크에서 20-40% 성능 감소
3. **도메인 특화 지식 부족**: 금융 전문 용어 및 개념 이해 한계
4. **복잡한 추론의 취약성**: 다단계 금융 추론에서 일관성 부족

### 벤치마크별 상세 결과

| **벤치마크** | **최고 모델** | **성능 점수** | **주요 도전과제** |
|---|---|---|---|
| **PolyFiQA-Easy** | GPT-4V | 65.2% | 다국어 금융 뉴스 통합 |
| **PolyFiQA-Expert** | Claude-3 | 58.7% | 복합 증거 추론 |
| **EnglishOCR** | GPT-4V | 71.4% | OCR 정확도 + 금융 추론 |
| **SpanishOCR** | Gemini-Pro | 63.9% | 비영어 OCR + 도메인 지식 |

## 데이터 접근 및 사용법

### Hugging Face에서 데이터 로드

```python
from datasets import load_dataset

# PolyFiQA-Easy 데이터셋
polyfiiqa_easy = load_dataset("TheFinAI/PolyFiQA-Easy")

# PolyFiQA-Expert 데이터셋
polyfiiqa_expert = load_dataset("TheFinAI/PolyFiQA-Expert")

# OCR 데이터셋
english_ocr = load_dataset("TheFinAI/MultiFinBen-EnglishOCR")
spanish_ocr = load_dataset("TheFinAI/MultiFinBen-SpanishOCR")
```

### 평가 코드 실행

```bash
# GitHub 리포지토리 클론
git clone https://github.com/xueqingpeng/MultiFinBen

# 의존성 설치
pip install -r requirements.txt

# 벤치마크 실행
python evaluate.py --model_name "gpt-4" --task "polyfiiqa_easy"
```

### 사용자 정의 평가

```python
import json
from multifinben import MultiFinBenEvaluator

# 평가자 초기화
evaluator = MultiFinBenEvaluator()

# 모델 결과 로드
with open('model_predictions.json', 'r') as f:
    predictions = json.load(f)

# 평가 실행
results = evaluator.evaluate(
    predictions=predictions,
    tasks=['polyfiiqa_easy', 'english_ocr'],
    metrics=['accuracy', 'f1', 'rouge']
)

print(f"Overall Score: {results['overall_score']:.2f}")
```

## 라이센스 및 사용 조건

### 혼합 라이센스 구조

MultiFinBen은 구성 데이터셋별로 다양한 라이센스를 적용합니다:

| **라이센스** | **데이터셋 수** | **상업적 이용** | **주요 제약사항** |
|---|---|---|---|
| **CC BY 4.0** | 8개 | ✅ 가능 | 저작자 표시 |
| **CC BY-NC 4.0** | 6개 | ❌ 불가 | 비상업적 용도만 |
| **MIT License** | 5개 | ✅ 가능 | 최소한의 제약 |
| **Public** | 7개 | ✅ 가능 | 제약 없음 |
| **기타** | 6개 | 변동 | 개별 확인 필요 |

### 권장 인용 방식

```bibtex
@article{peng2024multifinben,
  title={MultiFinBen: A Multilingual, Multimodal, and Difficulty-Aware Benchmark for Financial LLM Evaluation},
  author={Peng, Xueqing and Qian, Lingfei and Wang, Yan and others},
  journal={arXiv preprint arXiv:2506.14028},
  year={2024}
}
```

## 실제 활용 사례

### 1. 다국어 금융 Q&A 시스템

```python
# 다국어 금융 뉴스 기반 질의응답
def multilingual_finqa(question, financial_data, news_data):
    """
    다국어 금융 뉴스와 재무제표를 활용한 질의응답
    """
    # 언어별 뉴스 통합
    combined_context = {
        'statements': financial_data,
        'news': {
            'english': news_data.get('en', ''),
            'chinese': news_data.get('zh', ''),
            'japanese': news_data.get('ja', ''),
            'spanish': news_data.get('es', ''),
            'greek': news_data.get('el', '')
        }
    }
    
    # 모델 추론 실행
    response = model.generate(
        question=question,
        context=combined_context,
        max_length=100
    )
    
    return response
```

### 2. OCR 기반 금융 문서 분석

```python
# 금융 문서 OCR + 분석 파이프라인
def ocr_financial_analysis(document_image, question):
    """
    금융 문서 이미지에서 OCR로 텍스트 추출 후 질의응답
    """
    # OCR 수행
    extracted_text = ocr_engine.extract_text(document_image)
    
    # 금융 도메인 특화 후처리
    processed_text = financial_text_processor(extracted_text)
    
    # 질의응답 수행
    answer = financial_qa_model(
        question=question,
        context=processed_text
    )
    
    return {
        'extracted_text': processed_text,
        'answer': answer,
        'confidence': calculate_confidence(answer)
    }
```

### 3. 모델 벤치마킹 자동화

```python
# 자동화된 벤치마크 평가 시스템
class MultiFinBenRunner:
    def __init__(self, model_list):
        self.models = model_list
        self.tasks = [
            'polyfiiqa_easy', 'polyfiiqa_expert',
            'english_ocr', 'spanish_ocr'
        ]
    
    def run_comprehensive_evaluation(self):
        results = {}
        
        for model in self.models:
            model_results = {}
            
            for task in self.tasks:
                # 태스크별 평가 실행
                performance = self.evaluate_task(model, task)
                model_results[task] = performance
            
            # 종합 점수 계산
            model_results['overall'] = self.calculate_overall_score(
                model_results
            )
            
            results[model.name] = model_results
        
        return results
```

## 연구 의의 및 향후 전망

### 학술적 기여

1. **최초의 포괄적 다국어·다중모달 금융 벤치마크** 구축
2. **실제 금융 업무 복잡성 반영**한 평가 체계 제시
3. **현재 LLM의 한계점 명확히 규명** - 도메인 특화 다국어·다중모달 태스크에서의 성능 저하
4. **균형잡힌 난이도 분포**를 통한 정확한 모델 능력 측정

### 산업적 임팩트

- **금융 AI 시스템 개발** 가이드라인 제공
- **글로벌 금융 서비스**를 위한 LLM 평가 기준 확립
- **규제 준수** 및 **위험 관리** 시스템 성능 검증 도구

### 향후 연구 방향

1. **실시간 금융 데이터** 통합 벤치마크 확장
2. **규제 준수**(Regulatory Compliance) 태스크 추가
3. **설명 가능한 AI**(Explainable AI) 평가 메트릭 개발
4. **개인정보 보호** 강화 벤치마크 버전 개발

## 오픈 리더보드

MultiFinBen은 투명성과 재현성을 위해 **[공개 리더보드](https://huggingface.co/spaces/TheFinAI/Open-FinLLM-Leaderboard)**를 운영합니다.

### 리더보드 특징

- **실시간 모델 성능 비교** 및 순위
- **Model Openness Framework (MOF)** 태그 제공
- **필터링 및 비교** 기능으로 사용자 맞춤 분석
- **지속적 업데이트**로 최신 모델 성능 추적

### 참여 방법

```bash
# 모델 평가 결과 제출
python submit_results.py \
  --model_name "your_model" \
  --results_file "evaluation_results.json" \
  --contact_email "your_email@domain.com"
```

## 주요 연구진 및 기관

### 참여 기관 (20개)

- **The FinAI** (주도 기관)
- **Yale University**, **Columbia University**
- **NVIDIA**, **New York University**
- **University of Manchester**, **Harvard University**
- **University of Montreal** 등

### 주요 연구진

- **Xueqing Peng** (xqq.sincere@gmail.com) - The FinAI
- **Qianqian Xie** - 프로젝트 리더
- **Kaleb E Smith** - NVIDIA
- **Arman Cohan** - Yale University
- **Sophia Ananiadou** - University of Manchester

## 결론

MultiFinBen은 글로벌 금융 AI 연구의 새로운 이정표를 제시합니다. 실제 금융 업무의 복잡성을 반영한 포괄적 평가를 통해 현재 LLM들의 한계를 명확히 드러내고, 향후 연구 방향을 제시했습니다.

특히 **다국어·다중모달 태스크에서의 현저한 성능 저하**는 금융 AI 시스템 개발 시 반드시 고려해야 할 중요한 발견입니다. 이 벤치마크를 통해 더욱 강건하고 실용적인 금융 AI 시스템 개발이 가속화될 것으로 기대됩니다.

### 주요 리소스

- **논문**: [arXiv:2506.14028](https://arxiv.org/pdf/2506.14028)
- **데이터셋**: [Hugging Face Collections](https://huggingface.co/collections/TheFinAI)
- **코드**: [GitHub Repository](https://github.com/xueqingpeng/MultiFinBen)
- **리더보드**: [Open FinLLM Leaderboard](https://huggingface.co/spaces/TheFinAI/Open-FinLLM-Leaderboard) 