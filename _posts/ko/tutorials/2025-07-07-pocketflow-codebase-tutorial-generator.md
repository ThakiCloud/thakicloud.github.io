---
title: "PocketFlow로 AI 기반 코드베이스 튜토리얼 자동 생성하기"
excerpt: "복잡한 GitHub 저장소를 AI가 자동으로 분석하여 초보자 친화적인 튜토리얼로 변환해주는 PocketFlow 프로젝트를 설치하고 사용하는 방법을 단계별로 알아봅니다."
seo_title: "PocketFlow 튜토리얼: AI로 코드베이스 분석하고 튜토리얼 생성하기 - Thaki Cloud"
seo_description: "PocketFlow를 사용하여 GitHub 저장소를 분석하고 AI가 자동으로 초보자용 튜토리얼을 생성하는 방법을 배워보세요. 설치부터 실제 사용까지 완벽 가이드입니다."
date: 2025-07-07
last_modified_at: 2025-07-07
categories:
  - tutorials
tags:
  - PocketFlow
  - AI
  - LLM
  - GitHub
  - Python
  - Tutorial Generator
  - Code Analysis
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/pocketflow-codebase-tutorial-generator/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 10분

## 서론

새로운 코드베이스를 마주했을 때 "이 코드가 대체 어떻게 작동하는 거지?"라고 생각해본 적이 있나요? [PocketFlow-Tutorial-Codebase-Knowledge](https://github.com/The-Pocket/PocketFlow-Tutorial-Codebase-Knowledge)는 바로 이런 문제를 해결하기 위해 만들어진 프로젝트입니다.

이 도구는 GitHub 저장소를 크롤링하고 AI를 사용하여 복잡한 코드베이스를 분석한 후, 초보자도 쉽게 이해할 수 있는 튜토리얼을 자동으로 생성해줍니다. 100줄짜리 LLM 프레임워크인 Pocket Flow를 기반으로 하여 놀라울 정도로 간단하면서도 강력한 기능을 제공합니다.

### 개발 환경

이 튜토리얼은 다음 환경에서 테스트되었습니다.

- **OS:** macOS
- **Python:** 3.8+
- **필요한 API:** Google Gemini API Key (또는 다른 LLM API)

## 본론

### 1. 프로젝트 클론 및 설치

먼저 PocketFlow 프로젝트를 클론하고 의존성을 설치합니다.

```bash
git clone https://github.com/The-Pocket/PocketFlow-Tutorial-Codebase-Knowledge
cd PocketFlow-Tutorial-Codebase-Knowledge
```

Python 의존성을 설치합니다.

```bash
pip install -r requirements.txt
```

### 2. API 키 설정

PocketFlow는 LLM API를 사용하여 튜토리얼을 생성합니다. 기본적으로 Google Gemini API를 사용하지만, 다른 모델도 지원합니다.

#### Google Gemini API 키 설정

1. [Google AI Studio](https://aistudio.google.com/)에서 API 키를 발급받습니다.
2. 환경 변수로 설정하거나 직접 코드에 입력합니다.

```bash
export GEMINI_API_KEY="your-api-key-here"
```

#### LLM 설정 확인

`utils/call_llm.py` 파일에서 LLM 설정을 확인하고 테스트할 수 있습니다.

```python
import os
import google.generativeai as genai

client = genai.Client(
    api_key=os.getenv("GEMINI_API_KEY", "your-api_key"),
)
```

설정이 올바른지 확인하려면 다음 명령어를 실행합니다.

```bash
python utils/call_llm.py
```

### 3. 기본 사용법

#### GitHub 저장소 분석

가장 기본적인 사용법은 GitHub 저장소 URL을 제공하는 것입니다.

```bash
python main.py --repo https://github.com/username/repo --include "*.py" "*.js" --exclude "tests/*" --max-size 50000
```

#### 로컬 디렉토리 분석

로컬에 있는 코드베이스를 분석할 수도 있습니다.

```bash
python main.py --dir /path/to/your/codebase --include "*.py" --exclude "*test*"
```

#### 한국어 튜토리얼 생성

한국어로 튜토리얼을 생성하려면 `--language` 옵션을 사용합니다.

```bash
python main.py --repo https://github.com/username/repo --language "Korean"
```

### 4. 고급 옵션

PocketFlow는 다양한 옵션을 제공하여 분석을 세밀하게 조정할 수 있습니다.

#### 주요 옵션들

- `--repo` 또는 `--dir`: GitHub 저장소 URL 또는 로컬 디렉토리 경로 (필수, 상호 배타적)
- `-n, --name`: 프로젝트 이름 (선택사항, URL/디렉토리에서 자동 추출)
- `-t, --token`: GitHub 토큰 (또는 GITHUB_TOKEN 환경 변수 설정)
- `-o, --output`: 출력 디렉토리 (기본값: ./output)
- `-i, --include`: 포함할 파일들 (예: "*.py" "*.js")
- `-e, --exclude`: 제외할 파일들 (예: "tests/*" "docs/*")
- `-s, --max-size`: 최대 파일 크기 (바이트 단위, 기본값: 100KB)
- `--language`: 생성할 튜토리얼의 언어 (기본값: "english")
- `--max-abstractions`: 식별할 최대 추상화 개수 (기본값: 10)
- `--no-cache`: LLM 응답 캐싱 비활성화 (기본값: 캐싱 활성화)

#### 실제 사용 예시

복잡한 Python 프로젝트를 분석하는 예시:

```bash
python main.py \
  --repo https://github.com/fastapi/fastapi \
  --include "*.py" \
  --exclude "tests/*" "docs/*" "*.md" \
  --max-size 100000 \
  --language "Korean" \
  --output ./fastapi_tutorial \
  --max-abstractions 15
```

### 5. Docker를 사용한 실행

Docker를 사용하면 환경 설정 없이 바로 PocketFlow를 실행할 수 있습니다.

#### Docker 이미지 빌드

```bash
docker build -t pocketflow-app .
```

#### 공개 GitHub 저장소 분석

```bash
docker run -it --rm \
  -e GEMINI_API_KEY="YOUR_GEMINI_API_KEY_HERE" \
  -v "$(pwd)/output_tutorials":/app/output \
  pocketflow-app --repo https://github.com/username/repo
```

#### 로컬 디렉토리 분석

```bash
docker run -it --rm \
  -e GEMINI_API_KEY="YOUR_GEMINI_API_KEY_HERE" \
  -v "/path/to/your/local_codebase":/app/code_to_analyze \
  -v "$(pwd)/output_tutorials":/app/output \
  pocketflow-app --dir /app/code_to_analyze
```

### 6. 실제 테스트 및 결과 확인

간단한 Python 프로젝트로 테스트해보겠습니다.

```bash
# 환경 변수 설정
export GEMINI_API_KEY="your-api-key"

# 작은 프로젝트로 테스트
python main.py \
  --repo https://github.com/psf/requests \
  --include "*.py" \
  --exclude "tests/*" "docs/*" \
  --max-size 50000 \
  --language "Korean" \
  --output ./requests_tutorial
```

실행이 완료되면 `./requests_tutorial` 디렉토리에 다음과 같은 파일들이 생성됩니다:

- `tutorial.md`: 메인 튜토리얼 문서
- `codebase_analysis.json`: 코드베이스 분석 결과
- `abstractions.json`: 식별된 핵심 추상화들

### 7. 결과 활용하기

생성된 튜토리얼은 다음과 같은 구조를 가집니다:

1. **프로젝트 개요**: 코드베이스의 전체적인 목적과 구조
2. **핵심 추상화**: 주요 클래스, 함수, 모듈의 역할
3. **상호작용 다이어그램**: 컴포넌트 간의 관계
4. **사용 예시**: 실제 코드 사용법
5. **학습 경로**: 단계별 학습 가이드

### 8. 온라인 서비스 활용

설치가 번거롭다면 [code2tutorial.com](https://code2tutorial.com/)에서 온라인 버전을 사용할 수 있습니다. GitHub 링크만 붙여넣으면 바로 튜토리얼을 생성해줍니다.

## 결론

PocketFlow-Tutorial-Codebase-Knowledge는 복잡한 코드베이스를 이해하는 데 드는 시간을 크게 단축시켜주는 혁신적인 도구입니다. AI의 힘을 활용하여 코드의 핵심 구조와 동작 방식을 자동으로 분석하고, 이를 초보자도 쉽게 이해할 수 있는 형태로 변환해줍니다.

특히 오픈소스 프로젝트에 기여하고 싶지만 코드베이스가 복잡해서 어디서부터 시작해야 할지 모르는 개발자들에게 매우 유용한 도구가 될 것입니다. 100줄짜리 LLM 프레임워크로 이런 강력한 기능을 구현한 것도 인상적입니다.

이 도구를 활용하여 새로운 기술 스택을 빠르게 학습하고, 복잡한 프로젝트의 구조를 쉽게 파악해보세요. AI가 생성한 튜토리얼을 통해 코드 이해의 새로운 경험을 해보실 수 있을 것입니다. 