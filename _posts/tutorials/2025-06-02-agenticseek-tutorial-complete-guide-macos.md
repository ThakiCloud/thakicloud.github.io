---
title: "AgenticSeek 완전 가이드: 100% 로컬 AI 어시스턴트 맥북 설치 및 활용법"
date: 2025-06-02
categories: 
  - 튜토리얼
  - AI
tags: 
  - AgenticSeek
  - AI어시스턴트
  - 로컬AI
  - 맥북설치
  - 오픈소스
author_profile: true
toc: true
toc_label: "목차"
---

## AgenticSeek란 무엇인가?

AgenticSeek는 완전히 로컬에서 동작하는 음성 지원 자율 AI 에이전트입니다. 🔥 API 키나 구독료 없이, 여러분의 맥북에서 직접 실행되어 프라이버시를 완벽히 보장하면서도 강력한 AI 기능을 제공합니다.

### 주요 특징

- **🔒 완전 로컬 & 프라이빗**: 모든 작업이 여러분의 기기에서 실행되며, 클라우드나 데이터 공유가 전혀 없습니다.
- **🌐 스마트 웹 브라우징**: 자동으로 인터넷을 브라우징하고, 정보를 검색하며, 웹 폼까지 작성합니다.
- **💻 자율 코딩 어시스턴트**: Python, C, Go, Java 등 다양한 언어로 코드를 작성하고 디버깅합니다.
- **🧠 스마트 에이전트 선택**: 작업에 따라 최적의 AI 에이전트를 자동으로 선택합니다.
- **📋 복잡한 작업 계획 및 실행**: 여행 계획부터 복잡한 프로젝트까지 단계별로 나누어 처리합니다.
- **🎙️ 음성 지원**: 깔끔하고 빠른 음성 인식으로 SF 영화 속 개인 AI처럼 대화할 수 있습니다.

## 왜 AgenticSeek를 선택해야 할까요?

기존의 Manus AI와 달리 AgenticSeek는 외부 시스템에 의존하지 않고 완전한 독립성을 제공합니다. API 비용 걱정 없이 더 많은 제어권과 프라이버시를 보장받을 수 있습니다.

## 맥북 설치 가이드

### 사전 요구사항

맥북에서 AgenticSeek를 설치하기 전에 다음 사항들을 확인해주세요:

- **macOS 호환성**: macOS 10.15 (Catalina) 이상
- **Python 3.10**: 정확히 Python 3.10 버전을 권장합니다
- **Google Chrome**: 최신 버전
- **Docker**: Docker Desktop for Mac
- **하드웨어 요구사항**:
  - 최소: 12GB VRAM (RTX 3060 수준)
  - 권장: 24GB+ VRAM (RTX 4090 수준)
  - 최적: 48GB+ VRAM (Mac Studio 수준)

### 1단계: 필수 도구 설치

#### Homebrew 설치 (미설치 시)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Python 3.10 설치

```bash
brew install python@3.10
```

#### ChromeDriver 설치

```bash
brew install --cask chromedriver
```

#### Docker Desktop 설치

```bash
brew install --cask docker
```

Docker Desktop을 실행하고 완전히 시작될 때까지 기다립니다.

#### PortAudio 설치

```bash
brew install portaudio
```

### 2단계: AgenticSeek 다운로드 및 설정

#### 저장소 클론

```bash
git clone https://github.com/Fosowl/agenticSeek.git
cd agenticSeek
mv .env.example .env
```

#### 가상 환경 생성

```bash
python3.10 -m venv agentic_seek_env
source agentic_seek_env/bin/activate
```

### 3단계: 자동 설치

AgenticSeek는 맥북용 자동 설치 스크립트를 제공합니다:

```bash
./install.sh
```

이 스크립트가 다음 작업들을 자동으로 수행합니다:

- pip 업그레이드
- setuptools 및 wheel 업그레이드
- 필요한 Python 패키지들 설치

### 4단계: 로컬 LLM 설정

#### Ollama 설치 및 실행

```bash
# Ollama 설치
brew install ollama

# Ollama 서비스 시작
ollama serve
```

새 터미널 창에서 Deepseek R1 모델을 다운로드합니다:

```bash

ollama pull deepseek-r1:8b
# 14B 모델 (최소 사양)
ollama pull deepseek-r1:14b

# 32B 모델 (권장 사양)
ollama pull deepseek-r1:32b

# 70B 모델 (최고 성능)
ollama pull deepseek-r1:70b
```

#### 설정 파일 수정

`config.ini` 파일을 열어 다음과 같이 수정합니다:

```ini
[MAIN]
is_local = True
provider_name = ollama
provider_model = deepseek-r1:32b  # 여러분의 하드웨어에 맞게 조정
provider_server_address = 127.0.0.1:11434
agent_name = Friday
recover_last_session = True
save_session = True
speak = True
listen = False
work_dir = /Users/$(whoami)/Documents/workspace
jarvis_personality = False
languages = en ko

[BROWSER]
headless_browser = False  # CLI 모드에서는 False 권장
stealth_mode = True
```

### 5단계: 서비스 시작 및 실행

#### 필수 서비스 시작

```bash
sudo ./start_services.sh
```

이 명령어는 다음 서비스들을 시작합니다:

- SearXNG (검색 엔진)
- Redis (SearXNG 필요)
- Frontend (웹 인터페이스)

#### AgenticSeek 실행

**옵션 1: CLI 인터페이스**

```bash
python3 cli.py
```

**옵션 2: 웹 인터페이스**

백엔드 시작:

```bash
python3 api.py
```

웹 브라우저에서 `http://localhost:3000/`으로 접속합니다.

## 실제 사용 예시

AgenticSeek를 설치한 후 다음과 같은 명령어들을 시도해보세요:

### 코딩 작업

```
Python으로 뱀 게임을 만들어줘!
```

```
팩토리얼을 계산하는 Go 프로그램을 작성하고 factorial.go로 저장해줘
```

### 웹 검색 및 파일 작업

```
웹에서 렌느, 프랑스의 인기 카페를 검색하고 주소와 함께 세 곳을 선정해서 rennes_cafes.txt 파일로 저장해줘
```

```
2024년 인기 SF 영화를 온라인에서 검색해서 오늘 밤 볼 영화 세 편을 선택하고 movie_night.txt로 저장해줘
```

### 고급 작업

```
웹에서 무료 주식 가격 API를 찾아서 등록하고, 테슬라의 일일 주가를 가져오는 Python 스크립트를 작성해서 stock_prices.csv로 결과를 저장해줘
```

## 음성 기능 활성화

음성-텍스트 기능을 사용하려면 `config.ini`에서 다음을 수정합니다:

```ini
listen = True
agent_name = Friday  # 원하는 이름으로 변경 가능
```

음성 기능 사용법:

1. "Friday"라고 말해서 시스템을 깨웁니다
2. 명령어를 명확하게 말합니다
3. "실행해", "시작해", "고마워" 등의 확인 문구로 마무리합니다

## 문제 해결

### ChromeDriver 버전 불일치

Chrome 버전과 ChromeDriver 버전이 맞지 않는 경우:

```bash
# Chrome 버전 확인
google-chrome --version

# 맞는 ChromeDriver 다운로드
# https://developer.chrome.com/docs/chromedriver/downloads
```

### 연결 어댑터 오류

LM Studio나 다른 서버 사용 시 URL 앞에 `http://`를 추가해야 합니다:

```ini
provider_server_address = http://127.0.0.1:11434
```

### SearxNG 오류

`.env` 파일이 제대로 설정되지 않은 경우:

```bash
export SEARXNG_BASE_URL="http://127.0.0.1:8080"
```

## 성능 최적화 팁

### 하드웨어별 모델 선택

| 모델 크기 | GPU 메모리 | 성능 |
|-----------|------------|------|
| 7B | 8GB VRAM | ⚠️ 비추천 (성능 부족) |
| 14B | 12GB VRAM | ✅ 간단한 작업용 |
| 32B | 24GB+ VRAM | 🚀 대부분 작업 성공 |
| 70B+ | 48GB+ VRAM | 💪 최고 성능 |

### 메모리 최적화

맥북의 통합 메모리를 효율적으로 사용하려면:

1. 다른 메모리 집약적 앱들을 종료합니다
2. 더 작은 모델로 시작해서 점차 큰 모델로 업그레이드합니다
3. `headless_browser = True`로 설정해서 메모리를 절약합니다

## 보안 및 프라이버시

AgenticSeek의 가장 큰 장점 중 하나는 완전한 로컬 실행입니다:

- **데이터 유출 없음**: 모든 대화와 파일이 로컬에 저장됩니다
- **API 키 불필요**: 외부 서비스에 의존하지 않습니다
- **네트워크 격리**: 인터넷 연결 없이도 대부분 기능이 작동합니다

## 고급 설정

### 원격 서버에서 LLM 실행

더 강력한 서버가 있다면 모델을 원격으로 실행할 수 있습니다:

```bash
# 서버에서
git clone https://github.com/Fosowl/agenticSeek.git
cd agenticSeek/llm_server/
pip3 install -r requirements.txt
python3 app.py --provider ollama --port 3333
```

클라이언트 `config.ini`:

```ini
provider_name = server
provider_model = deepseek-r1:70b
provider_server_address = SERVER_IP:3333
```

### 다국어 지원

한국어와 영어를 모두 지원하려면:

```ini
languages = en ko
```

## 결론

AgenticSeek는 완전히 로컬에서 실행되는 강력한 AI 어시스턴트로, 프라이버시를 중시하는 사용자들에게 완벽한 솔루션을 제공합니다. 맥북에서의 설치는 생각보다 간단하며, 한 번 설정하면 API 비용 걱정 없이 무제한으로 사용할 수 있습니다.

특히 개발자들에게는 코드 작성부터 웹 스크래핑, 복잡한 작업 자동화까지 다양한 기능을 제공하여 생산성을 크게 향상시킬 수 있습니다.

오픈소스 프로젝트이므로 커뮤니티의 기여와 피드백을 통해 지속적으로 발전하고 있으며, 여러분도 [GitHub 저장소](https://github.com/Fosowl/agenticSeek)에서 최신 업데이트를 확인하고 참여하실 수 있습니다.

---

이 글이 도움이 되셨다면 댓글로 설치 경험이나 활용 사례를 공유해 주세요! 🚀
