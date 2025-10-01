---
title: "AI 소설 생성기로 장편 소설 자동 작성하기 - 완전 가이드"
excerpt: "AI를 활용한 장편 소설 자동 생성 도구 사용법과 설정 방법을 단계별로 설명합니다. OpenAI API와 벡터 검색을 활용한 일관성 있는 장편 소설 작성 방법을 알아보세요."
seo_title: "AI 소설 생성기 튜토리얼 - 장편 소설 자동 작성 가이드"
seo_description: "AI 소설 생성기를 사용한 장편 소설 자동 작성 방법을 단계별로 설명합니다. OpenAI API 설정부터 일관성 있는 소설 생성까지 완전 가이드."
date: 2025-09-30
categories:
  - tutorials
tags:
  - AI
  - 소설생성
  - OpenAI
  - 벡터검색
  - 창작도구
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.github.io/ko/tutorials/ai-novel-generator-tutorial-ko/"
lang: ko
permalink: /ko/tutorials/ai-novel-generator-tutorial-ko/
---

⏱️ **예상 읽기 시간**: 15분

## 소개

AI 기술의 발전으로 이제 인공지능을 활용해 장편 소설을 자동으로 생성할 수 있게 되었습니다. [AI_NovelGenerator](https://github.com/YILING0013/AI_NovelGenerator)는 OpenAI API와 벡터 검색 기술을 활용해 일관성 있는 장편 소설을 자동으로 생성하는 도구입니다.

이 튜토리얼에서는 AI 소설 생성기의 설치부터 설정, 사용법까지 단계별로 설명하겠습니다.

## AI 소설 생성기란?

AI 소설 생성기는 다음과 같은 특징을 가진 도구입니다:

- **장편 소설 자동 생성**: 100장 이상의 긴 소설도 자동으로 생성
- **일관성 유지**: 벡터 검색을 통한 캐릭터와 설정의 일관성 보장
- **GUI 인터페이스**: 사용자 친화적인 그래픽 인터페이스 제공
- **다양한 모델 지원**: OpenAI, Claude, Ollama 등 다양한 AI 모델 지원

## 설치 및 설정

### 1. 프로젝트 클론

```bash
git clone https://github.com/YILING0013/AI_NovelGenerator
cd AI_NovelGenerator
```

### 2. 의존성 설치

```bash
pip install -r requirements.txt
```

### 3. 기본 설정 파일 생성

프로젝트 루트에 `config.json` 파일을 생성하고 다음과 같이 설정합니다:

```json
{
    "api_key": "sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "base_url": "https://api.openai.com/v1",
    "interface_format": "OpenAI",
    "model_name": "gpt-4o-mini",
    "temperature": 0.7,
    "max_tokens": 4096,
    "embedding_api_key": "sk-XXXXXXXXXXXXXXXXXXXXXXXXXXXXXX",
    "embedding_interface_format": "OpenAI",
    "embedding_url": "https://api.openai.com/v1",
    "embedding_model_name": "text-embedding-ada-002",
    "embedding_retrieval_k": 4,
    "topic": "AI가 지배하는 미래 세계에서 인간의 저항을 그린 소설",
    "genre": "SF",
    "num_chapters": 50,
    "word_number": 3000,
    "filepath": "/path/to/your/novel/output"
}
```

## 상세 설정 가이드

### API 키 설정

1. **OpenAI API 키**: [OpenAI Platform](https://platform.openai.com/)에서 API 키를 발급받습니다.
2. **Base URL**: OpenAI의 경우 `https://api.openai.com/v1`을 사용합니다.
3. **모델 선택**: GPT-4, GPT-3.5-turbo 등 원하는 모델을 선택합니다.

### 소설 설정

- **topic**: 소설의 핵심 주제와 설정
- **genre**: 소설의 장르 (SF, 판타지, 로맨스 등)
- **num_chapters**: 총 장 수
- **word_number**: 장당 목표 단어 수

## 사용법 단계별 가이드

### Step 1: 기본 설정

프로그램을 실행하면 GUI가 나타납니다:

```bash
python main.py
```

GUI에서 다음 정보를 입력합니다:
- API Key 및 Base URL
- 모델 이름
- Temperature (창의성 수준)
- 소설 주제와 장르
- 장 수와 장당 단어 수
- 출력 파일 경로

### Step 2: 소설 설정 생성

"Step1. 생성 설정" 버튼을 클릭하면 `Novel_setting.txt` 파일이 생성됩니다. 이 파일에는 다음이 포함됩니다:

- 세계관 설정
- 주요 캐릭터 정보
- 스토리 라인
- 중요한 설정 요소

### Step 3: 목차 생성

"Step2. 생성 목차" 버튼을 클릭하면 `Novel_directory.txt` 파일이 생성됩니다. 이 파일에는 각 장의 제목과 간단한 설명이 포함됩니다.

### Step 4: 장 생성

"Step3. 생성 장 초안" 버튼을 클릭하여 특정 장을 생성합니다:

1. 장 번호 입력
2. 해당 장에 대한 추가 지시사항 입력 (선택사항)
3. 생성 버튼 클릭

시스템은 다음을 자동으로 수행합니다:
- 이전 장들의 내용을 벡터 검색으로 분석
- 캐릭터와 설정의 일관성 확인
- 장 초안 생성 (`outline_X.txt`, `chapter_X.txt`)

### Step 5: 장 확정

"Step4. 현재 장 확정" 버튼을 클릭하면:

- 전역 요약 업데이트 (`global_summary.txt`)
- 캐릭터 상태 업데이트 (`character_state.txt`)
- 벡터 검색 데이터베이스 업데이트
- 플롯 아크 업데이트 (`plot_arcs.txt`)

### Step 6: 일관성 검사 (선택사항)

"일관성 검사" 버튼을 클릭하여 최신 장의 일관성을 검사합니다. 캐릭터의 행동이나 설정의 모순을 찾아냅니다.

## 고급 설정

### 벡터 검색 설정

벡터 검색은 소설의 일관성을 유지하는 핵심 기술입니다:

```json
{
    "embedding_model_name": "text-embedding-ada-002",
    "embedding_retrieval_k": 4
}
```

### 로컬 모델 사용 (Ollama)

로컬에서 Ollama를 사용하려면:

```bash
# Ollama 서비스 시작
ollama serve

# 임베딩 모델 다운로드
ollama pull nomic-embed-text
```

설정 파일에서 다음과 같이 변경:

```json
{
    "embedding_interface_format": "Ollama",
    "embedding_url": "http://localhost:11434",
    "embedding_model_name": "nomic-embed-text"
}
```

## 문제 해결

### 일반적인 오류

1. **"Expecting value: line 1 column 1 (char 0)"**
   - API 응답이 올바르지 않을 때 발생
   - API 키와 URL을 다시 확인

2. **"HTTP/1.1 504 Gateway Timeout"**
   - API 서버 연결 문제
   - 네트워크 상태 확인

3. **벡터 검색 오류**
   - `vectorstore` 디렉토리 삭제 후 재시작
   - 임베딩 모델 변경 시 권장

## 팁과 모범 사례

### 효과적인 소설 생성

1. **명확한 주제 설정**: 구체적이고 명확한 주제를 설정하세요.
2. **적절한 장 수**: 너무 많은 장은 일관성 유지를 어렵게 만듭니다.
3. **정기적인 검토**: 생성된 내용을 정기적으로 검토하고 수정하세요.

### 성능 최적화

1. **적절한 Temperature**: 0.7-0.8 정도가 창의성과 일관성의 균형점입니다.
2. **벡터 검색 설정**: `embedding_retrieval_k` 값을 조정하여 관련성 높은 정보를 검색하세요.

## 결론

AI 소설 생성기는 창작자들에게 새로운 가능성을 제공합니다. 완벽한 소설을 자동으로 생성하는 것은 아니지만, 아이디어 발상과 초기 초안 작성에 큰 도움이 됩니다.

이 도구를 활용하여 여러분만의 독특한 소설을 만들어보세요. AI와 인간의 창작이 만나는 새로운 경험을 해보시기 바랍니다.

## 참고 자료

- [AI_NovelGenerator GitHub 저장소](https://github.com/YILING0013/AI_NovelGenerator)
- [OpenAI API 문서](https://platform.openai.com/docs)
- [Ollama 공식 문서](https://ollama.ai/)

---

**💡 팁**: 첫 번째 소설 생성 시에는 짧은 장 수(10-20장)로 시작하여 도구의 작동 방식을 익혀보세요.
