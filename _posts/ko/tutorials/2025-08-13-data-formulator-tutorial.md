---
title: "Data Formulator 튜토리얼 — AI로 만드는 대화형 데이터 시각화"
excerpt: "마이크로소프트 리서치의 Data Formulator로 자연어와 드래그앤드롭을 섞어 빠르게 시각화를 만드는 방법을 macOS 기준으로 설치부터 실전 예제, 자동화 스크립트까지 단계별로 안내합니다."
seo_title: "Data Formulator 튜토리얼: AI 시각화 입문 - Thaki Cloud"
seo_description: "GitHub의 Data Formulator를 macOS에서 설치하고 OpenAI·Anthropic·Ollama 모델과 연동해 AI 기반 데이터 변환·시각화를 만드는 방법을 단계별로 소개합니다."
date: 2025-08-13
last_modified_at: 2025-08-13
categories:
  - tutorials
tags:
  - Data Formulator
  - 데이터 시각화
  - AI
  - DuckDB
  - LiteLLM
  - Microsoft Research
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/data-formulator-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 10분

## 개요

**Data Formulator**는 대화형 UI와 자연어 입력을 결합해 사용자가 원하는 시각화를 빠르게 만들도록 돕는 AI 기반 도구입니다. 필드 드래그앤드롭과 간단한 설명만으로, 모델이 SQL/파이프라인을 자동 생성해 데이터를 적절히 변환하고 차트를 그려 줍니다. 마이크로소프트 리서치가 공개했으며 MIT 라이선스로 배포됩니다. 자세한 내용은 공식 저장소를 참고하세요: [Data Formulator GitHub 저장소](https://github.com/microsoft/data-formulator).

## 왜 Data Formulator인가

- **UI + 자연어 혼합**: 인코딩 선반에 `x`, `y`, `color` 등을 배치하고, 없는 필드는 이름만 적어도 모델이 필요한 변환을 유추합니다.
- **AI 에이전트 기반 변환**: SQL/데이터 파이프라인을 자동 생성해 중간 테이블부터 최종 시각화까지 만들어 줍니다.
- **여러 데이터셋 조인**: 동시에 여러 테이블을 선택하면 자동으로 조인 전략을 제안합니다.
- **Anchoring(앵커링)**: 중간 결과를 고정해 이후 분석이 명확하고 빨라집니다.
- **로컬 우선, 빠른 응답**: 기본 로컬 DB(DuckDB) 활용로 빠른 탐색성을 제공합니다.
- **다양한 모델 지원**: OpenAI, Azure OpenAI, Anthropic, Ollama 등(내부적으로 LiteLLM 연계) [Data Formulator GitHub 저장소](https://github.com/microsoft/data-formulator) 참고.

## 데모/연구 배경

- 최신 릴리스와 데모는 GitHub 릴리스를 확인하세요: [Data Formulator Releases](https://github.com/microsoft/data-formulator).
- 연구 배경: “Data Formulator 2: Iteratively Creating Rich Visualizations with AI” 
  - 논문: [arXiv:2408.16119](https://arxiv.org/abs/2408.16119)

## 테스트 환경(권장 버전)

- macOS Sonoma/Sequoia
- Python 3.10+ (권장 3.11)
- pip 23+
- Data Formulator 0.2 기준
- 선택: Ollama(로컬 LLM), OpenAI/Anthropic API 키

버전 확인 예시:

```bash
python3 --version
pip --version
``` 

## 설치(macOS)

### 1) 가상환경 준비

```bash
python3 -m venv ~/.venvs/data-formulator
source ~/.venvs/data-formulator/bin/activate
python -m pip install --upgrade pip
```

### 2) Data Formulator 설치

```bash
pip install data_formulator
```

### 3) 모델 키 설정(선택)

Data Formulator는 실행 시 모델 키 입력 UI가 있지만, 파일로 저장해두면 편합니다. 아래 예시처럼 `api-keys.env`를 만들어 두세요.

```bash
mkdir -p ~/.config/data-formulator
cat > ~/.config/data-formulator/api-keys.env << 'EOF'
OPENAI_API_KEY=sk-...
ANTHROPIC_API_KEY=sk-ant-...
# 로컬 모델을 쓰는 경우
OLLAMA_BASE_URL=http://localhost:11434

# Azure OpenAI를 쓸 때 필요(있을 때만)
AZURE_OPENAI_API_KEY=...
AZURE_OPENAI_ENDPOINT=https://<your-resource>.openai.azure.com
AZURE_OPENAI_API_VERSION=2024-10-21
EOF
```

## 실행하기

기본 포트(5000):

```bash
data_formulator
```

다른 포트(예: 8080)로 실행:

```bash
python -m data_formulator --port 8080
```

접속: 브라우저에서 `http://localhost:5000` 또는 `http://localhost:8080`을 엽니다.

실행 로그 예시:

```text
Starting Data Formulator on http://localhost:5000
Loading datasets and UI...
Model providers initialized (OpenAI/Anthropic/Ollama if configured)
```

## 빠른 시작(Hands-on)

### 1) 데이터셋 선택

- 좌측에서 샘플 데이터셋(예: 에너지/매출 등 샘플)을 선택합니다.

### 2) 인코딩 지정

- 차트 유형을 선택한 뒤 `x`, `y`, `color` 등에 필드를 드래그앤드롭합니다.
- 현재 데이터에 없는 파생 필드가 필요하면 필드 이름만 적어 넣으세요(예: `renewable_pct`).

### 3) Formulate 실행

- 우측 상단의 Formulate 버튼을 누르면, 모델이 필요한 변환(SQL/파이프라인)을 만들고 차트를 그립니다.

### 4) 후속 탐색

- 자연어 프롬프트 예: `상위 5개만 보여줘`, `최근 연도만`, `지역별 합계로 묶어줘`.
- 기존 차트를 복제하거나 인코딩 일부를 바꾸면서 빠르게 가설 검증을 반복하세요.

## 고급 기능: 멀티 데이터셋과 조인, 앵커링

- **여러 테이블 동시 선택**: 인코딩 선반에 두 개 이상의 테이블을 지정하면, 모델이 조인 키 후보와 전략을 제안합니다.
- **앵커(Anchor) 고정**: 중간 결과를 고정해 후속 분석이 원본이 아닌 정제된 데이터 위에서 수행되도록 만듭니다. 성능과 재현성이 좋아집니다.

## 팀 협업 팁

- **Data Threads** 패널로 탐색 히스토리를 추적·브랜치화하여, 실험 과정을 팀과 공유하고 재현성을 높일 수 있습니다.

## macOS 자동화 스크립트(테스트 포함)

아래 스크립트는 가상환경 생성 → 설치 → 서버 기동(백그라운드) → 헬스체크(간이) → 종료까지 한 번에 수행합니다.

```bash
#!/usr/bin/env bash
set -euo pipefail

PORT="8080"
VENV="$HOME/.venvs/data-formulator"

python3 -m venv "$VENV"
source "$VENV/bin/activate"
python -m pip install --upgrade pip
pip install -q data_formulator curl

python -m data_formulator --port "$PORT" &
APP_PID=$!

echo "Waiting for Data Formulator to start..."
for i in {1..30}; do
  if curl -fsS "http://localhost:${PORT}" >/dev/null 2>&1; then
    echo "OK: http://localhost:${PORT}"
    break
  fi
  sleep 1
done

if ! kill -0 "$APP_PID" >/dev/null 2>&1; then
  echo "Process not running. Exiting with error." >&2
  exit 1
fi

echo "Smoke test passed. Stopping..."
kill "$APP_PID"
wait "$APP_PID" || true
```

실행 예:

```bash
chmod +x ~/scripts/data-formulator-smoke-test.sh
~/scripts/data-formulator-smoke-test.sh
```

## zshrc alias 권장 설정

```bash
# ~/.zshrc
alias dataf-start="python -m data_formulator --port 8080"
alias dataf-open="open http://localhost:8080"
```

적용:

```bash
source ~/.zshrc
```

## 트러블슈팅

- **포트 충돌**: 이미 5000/8080 포트가 사용 중이면 `--port` 값을 변경하여 실행하세요.
- **모델 키 미인식**: `~/.config/data-formulator/api-keys.env` 위치와 변수명을 재확인합니다.
- **네트워크 제한**: 회사 프록시/방화벽 환경이라면 모델 API에 대한 egress 허용이 필요한지 확인하세요.
- **속도 이슈**: 앵커링을 활용해 중간 결과를 고정하고, 필요 없는 열/행은 초기에 필터링합니다.

## 참고 자료

- GitHub 저장소: [microsoft/data-formulator](https://github.com/microsoft/data-formulator)
- 연구 논문: [Data Formulator 2 (arXiv:2408.16119)](https://arxiv.org/abs/2408.16119)


