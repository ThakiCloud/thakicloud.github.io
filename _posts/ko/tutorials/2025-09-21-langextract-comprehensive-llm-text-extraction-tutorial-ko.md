---
title: "LangExtract: LLM 기반 구조화된 텍스트 추출 완전 가이드"
excerpt: "Google의 LangExtract 라이브러리를 활용해 비구조화된 텍스트에서 정확한 소스 추적과 대화형 시각화를 통해 구조화된 정보를 추출하는 방법을 마스터하세요."
seo_title: "LangExtract 튜토리얼: LLM 텍스트 추출 완전 가이드 - Thaki Cloud"
seo_description: "Google의 LangExtract 라이브러리를 사용한 구조화된 데이터 추출 튜토리얼. Gemini, OpenAI, Ollama 모델을 활용한 실용적인 예제로 완벽 학습."
date: 2025-09-21
categories:
  - tutorials
tags:
  - LangExtract
  - LLM
  - Google
  - Gemini
  - 텍스트추출
  - 구조화데이터
  - 자연어처리
  - Python
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/langextract-comprehensive-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/langextract-comprehensive-tutorial/"
---

⏱️ **예상 읽기 시간**: 12분

## 소개

LangExtract는 Google에서 개발한 강력한 Python 라이브러리로, 대형 언어 모델(LLM)을 사용하여 비구조화된 텍스트에서 구조화된 정보를 추출하는 방식을 혁신적으로 변화시켰습니다. GitHub에서 15,400개 이상의 스타를 받은 이 최첨단 도구는 정확한 소스 추적과 대화형 시각화 기능을 제공하여 현대적인 데이터 추출 워크플로우에 필수적인 도구가 되었습니다.

## LangExtract란 무엇인가?

LangExtract는 비구조화된 텍스트 데이터와 구조화된 정보 추출 사이의 격차를 해소하도록 설계되었습니다. 기존의 파싱 방법과 달리, LangExtract는 고급 LLM의 힘을 활용하여 텍스트 문서 내의 맥락, 관계, 그리고 미묘한 정보를 이해합니다.

### 주요 기능

- **다중 모델 지원**: Gemini, OpenAI, 로컬 Ollama 모델과 호환
- **소스 추적**: 원본 텍스트에 대한 정확한 귀속 제공
- **대화형 시각화**: 추출 결과 탐색을 위한 내장 도구
- **스키마 제약**: 구조화된 출력 형식 강제
- **병렬 처리**: 대용량 문서를 효율적으로 처리
- **플러그인 시스템**: 사용자 정의 모델 제공자를 위한 확장 가능한 아키텍처

## 설치 및 설정

### 기본 설치

pip를 통한 가장 간단한 시작 방법:

```bash
# 가상 환경 생성
python -m venv langextract_env
source langextract_env/bin/activate  # Windows: langextract_env\Scripts\activate

# LangExtract 설치
pip install langextract
```

### 개발용 설치

개발 작업이나 최신 기능 접근을 위해:

```bash
git clone https://github.com/google/langextract.git
cd langextract

# 기본 설치
pip install -e .

# 개발 도구 포함
pip install -e ".[dev]"

# 테스트 의존성 포함
pip install -e ".[test]"
```

### Docker 설정

컨테이너화된 배포를 위해:

```bash
docker build -t langextract .
docker run --rm -e LANGEXTRACT_API_KEY="your-api-key" langextract python your_script.py
```

## API 키 구성

### 클라우드 모델 설정

LangExtract는 여러 클라우드 제공자를 지원합니다. API 키 구성 방법:

#### 옵션 1: 환경 변수

```bash
export LANGEXTRACT_API_KEY="your-api-key-here"
```

#### 옵션 2: .env 파일 (권장)

```bash
# .env 파일 생성
cat >> .env << 'EOF'
LANGEXTRACT_API_KEY=your-api-key-here
EOF

# API 키 보안 설정
echo '.env' >> .gitignore
```

#### 옵션 3: Vertex AI 인증

Google Cloud를 사용하는 기업 환경의 경우:

```python
import langextract as lx

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="정보 추출...",
    examples=[...],
    model_id="gemini-2.5-flash",
    language_model_params={
        "vertexai": True,
        "project": "your-project-id",
        "location": "global"
    }
)
```

### API 키 소스

- **Gemini 모델**: [AI Studio](https://aistudio.google.com/)에서 API 키 획득
- **OpenAI 모델**: [OpenAI Platform](https://platform.openai.com/)에서 키 접근
- **Vertex AI**: 서비스 계정을 통한 기업용 사용

## 기본 사용 예제

### 간단한 정보 추출

연락처 정보를 추출하는 기본 예제:

```python
import langextract as lx

# 샘플 텍스트
text = """
김지수 박사는 서울대학교병원의 심장내과 의사입니다.
연락처는 jisoo.kim@snuh.org 이며 전화번호는 02-1234-5678입니다.
진료실은 서울시 종로구 대학로 101, 의료진 동 456호에 위치합니다.
"""

# 추출 프롬프트 정의
prompt = "이름, 직책, 이메일, 전화번호, 주소를 포함한 연락처 정보 추출"

# 기본 추출
result = lx.extract(
    text_or_documents=text,
    prompt_description=prompt,
    model_id="gemini-2.5-flash"
)

print(result)
```

### 예제를 통한 구조화된 추출

더 복잡한 시나리오의 경우, 추출을 안내할 예제를 제공:

```python
import langextract as lx

# 의료 텍스트
medical_text = """
환자는 가슴 통증, 호흡 곤란, 심박수 상승을 호소합니다.
메토프롤올 50mg 하루 2회, 리시노프릴 10mg 하루 1회 처방.
2주 후 추적 관찰 예정입니다.
"""

# 예제 정의
examples = [
    {
        "input": "환자가 예방을 위해 아스피린 81mg 매일 복용",
        "output": {
            "medications": [
                {
                    "name": "아스피린",
                    "dosage": "81mg",
                    "frequency": "매일",
                    "purpose": "예방"
                }
            ]
        }
    }
]

# 예제와 함께 추출
result = lx.extract(
    text_or_documents=medical_text,
    prompt_description="약물명, 용량, 복용 빈도, 목적을 포함한 약물 정보 추출",
    examples=examples,
    model_id="gemini-2.5-flash"
)

print(result)
```

## 다양한 모델 제공자 활용

### OpenAI 모델 사용

```python
import langextract as lx
import os

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="핵심 정보 추출",
    examples=examples,
    model_id="gpt-4o",
    api_key=os.environ.get('OPENAI_API_KEY'),
    fence_output=True,
    use_schema_constraints=False  # OpenAI에 필수
)
```

### Ollama를 통한 로컬 모델 사용

개인정보 보호 중심 배포나 오프라인 처리를 위해:

```bash
# Ollama 설치 및 설정
# 설치 지침은 ollama.com 참조
ollama pull gemma2:2b
ollama serve
```

```python
import langextract as lx

result = lx.extract(
    text_or_documents=input_text,
    prompt_description="정보 추출",
    examples=examples,
    model_id="gemma2:2b",
    model_url="http://localhost:11434",
    fence_output=False,
    use_schema_constraints=False
)
```

## 고급 기능

### 대용량 문서 처리

LangExtract는 병렬 처리를 통해 대용량 문서 처리에 뛰어납니다:

```python
import langextract as lx
import requests

# 대용량 문서 다운로드 (로미오와 줄리엣 예제)
url = "https://www.gutenberg.org/files/1513/1513-0.txt"
response = requests.get(url)
full_text = response.text

# 캐릭터 정보 추출
result = lx.extract(
    text_or_documents=full_text,
    prompt_description="등장인물 이름, 관계, 주요 장면 추출",
    model_id="gemini-2.5-flash",
    max_parallel_calls=4  # 병렬 처리
)
```

### 스키마 제약 추출

일관된 결과를 위한 정확한 출력 스키마 정의:

```python
from pydantic import BaseModel
from typing import List

class Medication(BaseModel):
    name: str
    dosage: str
    frequency: str
    route: str = "경구"

class MedicalRecord(BaseModel):
    patient_id: str
    medications: List[Medication]
    symptoms: List[str]

# 스키마를 사용한 추출
result = lx.extract(
    text_or_documents=medical_text,
    prompt_description="의료 정보 추출",
    schema=MedicalRecord,
    model_id="gemini-2.5-flash",
    use_schema_constraints=True
)
```

### 대화형 시각화

LangExtract는 내장 시각화 도구를 제공:

```python
# 시각화 활성화
result = lx.extract(
    text_or_documents=text,
    prompt_description="개체 추출",
    model_id="gemini-2.5-flash",
    visualize=True
)

# 시각화 데이터 접근
print(result.visualization_data)
```

## 실제 사용 사례

### 의료: 의료 기록 처리

```python
def extract_medical_info(clinical_notes):
    """임상 노트에서 구조화된 의료 정보 추출."""
    
    examples = [
        {
            "input": "환자가 심한 두통을 호소하여 이부프로펜 600mg 6시간마다 처방",
            "output": {
                "symptoms": ["심한 두통"],
                "medications": [
                    {
                        "name": "이부프로펜",
                        "dosage": "600mg",
                        "frequency": "6시간마다"
                    }
                ]
            }
        }
    ]
    
    return lx.extract(
        text_or_documents=clinical_notes,
        prompt_description="증상, 약물, 치료 계획 추출",
        examples=examples,
        model_id="gemini-2.5-flash"
    )
```

### 법률: 계약서 분석

```python
def extract_contract_terms(contract_text):
    """법률 계약서에서 핵심 조건 추출."""
    
    prompt = """
    다음을 포함한 계약 정보 추출:
    - 관련 당사자
    - 계약 기간
    - 주요 의무
    - 지불 조건
    - 해지 조항
    """
    
    return lx.extract(
        text_or_documents=contract_text,
        prompt_description=prompt,
        model_id="gemini-2.5-flash",
        temperature=0.1  # 법률 정확성을 위한 낮은 온도
    )
```

### 학술: 연구 논문 분석

```python
def extract_research_info(paper_text):
    """연구 논문에서 구조화된 정보 추출."""
    
    examples = [
        {
            "input": "이 연구는 12개월 동안 500명의 참가자를 대상으로 진행되었습니다...",
            "output": {
                "sample_size": 500,
                "study_duration": "12개월",
                "methodology": "종단 연구"
            }
        }
    ]
    
    return lx.extract(
        text_or_documents=paper_text,
        prompt_description="연구 방법론, 표본 크기, 주요 발견 추출",
        examples=examples,
        model_id="gemini-2.5-flash"
    )
```

## 사용자 정의 모델 제공자

LangExtract의 플러그인 시스템을 통해 사용자 정의 모델 제공자 추가:

```python
from langextract.registry import registry

@registry.register(
    name="custom_provider",
    priority=10,
    model_ids=["custom-model-v1"]
)
class CustomProvider:
    def __init__(self, model_id, api_key=None, **kwargs):
        self.model_id = model_id
        self.api_key = api_key
    
    def generate(self, prompt, **kwargs):
        # 사용자 정의 생성 로직 구현
        pass
    
    @staticmethod
    def get_schema_class():
        # 선택사항: 사용자 정의 스키마 클래스 반환
        return None
```

## 성능 최적화

### 모범 사례

1. **적절한 모델 사용**: 사용 사례에 맞는 올바른 모델 선택
   - Gemini 2.5 Flash: 빠르고 비용 효과적
   - GPT-4: 복잡한 작업에 높은 정확도
   - 로컬 모델: 개인정보 보호 및 오프라인 처리

2. **프롬프트 최적화**: 명확하고 구체적인 프롬프트가 더 나은 결과 제공
3. **예제 활용**: 2-3개의 고품질 예제 제공
4. **배치 처리**: 여러 문서를 병렬로 처리
5. **스키마 제약**: 일관된 출력 형식을 위한 스키마 사용

### 오류 처리

```python
import langextract as lx
from langextract.exceptions import LangExtractError

try:
    result = lx.extract(
        text_or_documents=text,
        prompt_description=prompt,
        model_id="gemini-2.5-flash",
        max_retries=3,
        timeout=30
    )
except LangExtractError as e:
    print(f"추출 실패: {e}")
    # 대체 로직 구현
```

## 테스트 및 검증

### 단위 테스트

```python
import unittest
import langextract as lx

class TestLangExtract(unittest.TestCase):
    def setUp(self):
        self.sample_text = "김철수 박사에게 john@example.com으로 연락하세요"
        
    def test_contact_extraction(self):
        result = lx.extract(
            text_or_documents=self.sample_text,
            prompt_description="이메일 주소 추출",
            model_id="gemini-2.5-flash"
        )
        
        self.assertIn("john@example.com", str(result))

if __name__ == "__main__":
    unittest.main()
```

### 통합 테스트

```bash
# 전체 테스트 스위트 실행
pytest tests

# 특정 제공자 테스트
pytest tests/test_ollama.py

# 커버리지와 함께 실행
pytest --cov=langextract tests
```

## 문제 해결

### 일반적인 문제

1. **API 키 오류**
   - API 키가 올바르게 설정되었는지 확인
   - 키 권한 및 할당량 확인

2. **모델 가용성**
   - 모델 ID가 정확한지 확인
   - 해당 지역에서 모델을 사용할 수 있는지 확인

3. **대용량 문서의 메모리 문제**
   - 매우 큰 텍스트에는 청크 처리 사용
   - 병렬 처리 활성화

4. **일관성 없는 출력 형식**
   - 스키마 제약 사용
   - 더 많은 예제 제공
   - 일관성을 위해 온도 낮추기

### 디버그 모드

```python
import logging
logging.basicConfig(level=logging.DEBUG)

result = lx.extract(
    text_or_documents=text,
    prompt_description=prompt,
    model_id="gemini-2.5-flash",
    debug=True
)
```

## 보안 고려사항

### 데이터 개인정보 보호

- **로컬 처리**: 민감한 데이터에는 Ollama 사용
- **API 보안**: 정기적으로 API 키 교체
- **데이터 보존**: 제공자의 데이터 정책 이해

### 입력 검증

```python
def safe_extract(text, max_length=10000):
    """입력 검증을 통한 안전한 추출."""
    
    if len(text) > max_length:
        raise ValueError("입력 텍스트가 너무 깁니다")
    
    # 입력 정제
    text = text.strip()
    
    return lx.extract(
        text_or_documents=text,
        prompt_description="정보 추출",
        model_id="gemini-2.5-flash"
    )
```

## 결론

LangExtract는 비구조화된 텍스트에서 구조화된 정보 추출 분야의 중요한 발전을 나타냅니다. 강력한 LLM 통합, 정확한 소스 추적, 유연한 아키텍처의 결합으로 현대 데이터 처리 워크플로우에 매우 귀중한 도구가 되었습니다.

의료 기록 처리, 법률 문서 분석, 연구 논문에서 인사이트 추출 등 어떤 작업을 하든, LangExtract는 비구조화된 텍스트를 실행 가능한 구조화된 데이터로 변환하는 데 필요한 도구와 유연성을 제공합니다.

### 다음 단계

1. **예제 탐색**: [공식 예제](https://github.com/google/langextract/tree/main/examples) 확인
2. **커뮤니티 참여**: [커뮤니티 제공자](https://github.com/google/langextract/blob/main/COMMUNITY_PROVIDERS.md)에 기여
3. **문서 읽기**: [공식 문서](https://github.com/google/langextract/tree/main/docs) 방문
4. **라이브 데모 체험**: [RadExtract 데모](https://huggingface.co/spaces/google/radextract) 경험

오늘 LangExtract로 여정을 시작하고 비구조화된 텍스트 데이터로 작업하는 방식을 혁신하세요!

---

**💡 프로 팁**: 간단한 추출 작업부터 시작하여 라이브러리의 기능에 익숙해지면서 점진적으로 복잡성을 높이세요. LangExtract 성공의 핵심은 명확한 프롬프트 작성과 좋은 예제 제공입니다.
