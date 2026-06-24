---
title: "free-claude-code로 Claude Code를 자체호스팅 모델에 연결하기 - 17개 프로바이더 라우팅 프록시 실측"
excerpt: "36.7k 스타의 free-claude-code는 Claude Code 트래픽을 Anthropic 호환 FastAPI 프록시로 받아 17개 프로바이더로 분기합니다. 로컬 Ollama 백엔드로 직접 라우팅해 레이턴시를 측정하고, Python 3.14 하드 요구가 만든 배포 리스크까지 정직하게 기록한 실측 리포트입니다."
seo_title: "free-claude-code 자체호스팅 라우팅 - Claude Code 멀티프로바이더 프록시 - Thaki Cloud"
seo_description: "free-claude-code로 Claude Code를 Ollama·vLLM 등 자체호스팅 모델로 라우팅하는 실전 기록. Anthropic 호환 FastAPI 프록시 구조, 로컬 Ollama 레이턴시 실측, Python 3.14 하드 요구가 만든 배포 리스크를 ThakiCloud K8s 환경 관점에서 분석합니다."
date: 2026-06-24
last_modified_at: 2026-06-24
categories:
  - llmops
tags:
  - free-claude-code
  - Claude Code
  - LLM Gateway
  - Model Routing
  - Ollama
  - vLLM
  - Self-Hosting
  - FastAPI
  - LLM Ops
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.github.io/ko/llmops/free-claude-code-router/"
---

## 개요

Claude Code는 강력한 코딩 에이전트입니다. 그런데 모든 요청이 Anthropic API로 직접 나가는 구조라, 비용을 통제하거나 데이터를 사내에 가두려는 조직에게는 제약이 됩니다. 최근 X 타임라인에서 화제가 된 `free-claude-code`는 바로 이 지점을 건드립니다. Claude Code의 트래픽을 가로채 17개의 다른 프로바이더로 라우팅하는 프록시 계층입니다. GitHub 스타 36.7k, 포크 5.7k, 712개 커밋의 MIT 라이선스 프로젝트입니다.

프로젝트의 마케팅 문구는 "Claude Code를 영원히 무료로"입니다. 무료 또는 저가 티어 프로바이더로 트래픽을 흘려보내는 방식인데, 이 프레이밍은 솔직히 과장된 측면이 있고 약관(ToS) 관점의 회색지대도 있습니다. 그래서 이 글은 "공짜" 각도가 아니라, ThakiCloud처럼 **K8s 위에서 자체 모델을 서빙하는 조직이 Claude Code를 자기 인프라에 연결**할 때 이 도구가 어떤 의미를 갖는지에 집중합니다. 데이터가 테넌시 밖으로 나가지 않고, 토큰당 클라우드 청구서가 사라지며, Anthropic 호환 엔드포인트라 클라이언트 수정이 필요 없다는 점이 핵심입니다.

> 참고: 이전 글 "Claude Code를 사내 모델로 라우팅하기 - claude-code-router"는 클라우드 모델(glm·MiniMax·Kimi) 간 **비용 차익**에 초점을 맞췄습니다. 이번 글은 다른 도구(`free-claude-code`)로, 클라우드가 아니라 **자체호스팅 백엔드(Ollama·vLLM)** 연결과 그 과정에서 드러난 배포 리스크를 다룹니다.

## 이 도구는 무엇인가

`free-claude-code`는 Claude Code(그리고 Codex)가 보내는 요청을 받아내는 로컬 프록시 서버입니다. 핵심은 **Anthropic 호환 엔드포인트**를 그대로 흉내 낸다는 데 있습니다. 클라이언트 입장에서는 진짜 Anthropic API와 구분이 안 되므로, Claude Code 쪽 코드를 한 줄도 고치지 않고 백엔드만 바꿀 수 있습니다.

서버는 FastAPI로 작성되어 다음 엔드포인트를 노출합니다.

- `/v1/messages` - Anthropic Messages API 호환 (Claude Code의 주 경로)
- `/v1/models` - 모델 목록
- `/v1/responses` - OpenAI Responses API 호환 (Codex용, 내부적으로 Messages로 변환)

요청이 들어오면 **모델 라우터**가 어느 프로바이더로 보낼지 결정하고, **정규화기**가 thinking 블록·tool_call·에러 응답을 각 클라이언트가 기대하는 모양으로 변환합니다. 프로바이더마다 응답 포맷이 다르기 때문에 이 정규화 계층이 실질적인 난이도를 가집니다.

정규화가 왜 어려운지 조금 더 풀어보겠습니다. Claude Code는 Anthropic 특유의 응답 구조를 가정합니다. 예를 들어 추론 과정은 `thinking` 블록으로, 도구 호출은 `tool_use` 콘텐츠 블록으로 옵니다. 그런데 DeepSeek은 추론을 별도 필드로 내보내고, OpenAI 호환 프로바이더는 도구 호출을 `tool_calls` 배열로 내보냅니다. 같은 "도구를 호출했다"는 의미라도 와이어 포맷이 제각각입니다. 정규화기는 이 차이를 흡수해 어느 백엔드를 쓰든 Claude Code가 동일한 모양의 응답을 받도록 보장해야 합니다. Codex 경로(`/v1/responses`)는 한 술 더 떠서, OpenAI Responses 요청을 내부적으로 Anthropic Messages로 변환한 뒤 동일한 라우터·정규화기·프로바이더 어댑터를 공유합니다. 즉 프로토콜 변환이 양방향으로 일어납니다. 이 부분이 단순 리버스 프록시와 라우팅 프록시를 가르는 지점입니다.

![free-claude-code 라우팅 아키텍처](/assets/images/free-claude-code-router-diagram.png)
*그림 1. Claude Code의 Anthropic 호환 트래픽을 FastAPI 프록시가 받아 17개 프로바이더로 분기합니다. ThakiCloud 관점에서 중요한 경로는 오른쪽 자체호스팅 백엔드(Ollama·LM Studio·vLLM)입니다.*

지원 프로바이더는 17개입니다. 클라우드 쪽으로는 NVIDIA NIM, OpenRouter, Google AI Studio(Gemini), DeepSeek, Mistral La Plateforme, Mistral Codestral, OpenCode Zen, OpenCode Go, Wafer, Kimi, Cerebras, Groq, Fireworks, Z.ai가 있고, **자체호스팅 쪽으로는 LM Studio, llama.cpp, Ollama**가 있습니다. ThakiCloud 관점에서 의미 있는 것은 마지막 세 개입니다. Ollama나 llama.cpp가 OpenAI 호환 엔드포인트를 노출하므로, 같은 방식으로 K8s에 올린 vLLM 서버도 동일하게 붙일 수 있습니다.

티어별 라우팅은 환경 변수로 제어합니다. `MODEL_OPUS`, `MODEL_SONNET`, `MODEL_HAIKU`가 각각 Claude의 세 티어를 어느 모델로 보낼지 지정하고, 지정이 없으면 폴백 `MODEL`을 씁니다. 예를 들어 가벼운 Haiku 트래픽은 작은 로컬 모델로, 무거운 Opus 트래픽은 큰 모델로 분기하는 식의 차등 배치가 가능합니다.

## 설치 및 통합

공식 설치 경로는 셸 원라이너입니다.

```bash
# macOS / Linux
curl -fsSL "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.sh?raw=1" | sh

# Windows PowerShell
irm "https://github.com/Alishahryar1/free-claude-code/blob/main/scripts/install.ps1?raw=1" | iex
```

저는 셸 원라이너 대신 격리된 샌드박스에서 패키지를 직접 설치해 검증했습니다. ThakiCloud의 Python 런타임 규칙상 공유 가상환경을 오염시키지 않기 위해서입니다.

```bash
# 격리 워크트리 + ephemeral venv (공유 .venv는 3.12.8이라 충돌)
uv venv --python 3.14 .expenv
VIRTUAL_ENV=.expenv uv pip install "git+https://github.com/Alishahryar1/free-claude-code.git"
```

패키지 자체는 깔끔하게 설치됩니다. fastapi, uvicorn, httpx, pydantic, openai, loguru 등 의존성이 정상 해결되고 `fcc-server`, `fcc-init`, `fcc-claude` 같은 콘솔 스크립트가 생성됩니다. 서버 기동 후에는 다음처럼 Claude Code를 프록시로 향하게 합니다.

```bash
fcc-server            # FastAPI 프록시 기동 (기본 http://127.0.0.1:8082)
# 자체호스팅 백엔드 예시 (Ollama):
#   MODEL_HAIKU=ollama/llama3.2:3b
#   MODEL_SONNET=ollama/qwen2.5:7b
# Claude Code가 프록시를 보도록 베이스 URL 지정 후 사용
```

관리 UI는 `http://127.0.0.1:8082/admin`에 있으며 루프백에서만 접근됩니다. 프로바이더 키, 모델 라우팅, 메시징·음성 설정을 여기서 관리합니다.

## 실제 실험 결과

검증 과정에서 **재현이 막히는 지점**을 만났고, 이를 그대로 기록합니다. 수치를 지어내지 않는 것이 이 리포트의 원칙입니다.

### 부팅 차단: Python 3.14 하드 요구

`free-claude-code` v2.3.14는 `requires-python = ">=3.14.0"`을 하드로 못박았습니다. Python 3.14는 2025년 10월에야 정식 출시된 최신 버전입니다. 문제는 테스트 환경에서 확보 가능한 3.14가 알파 빌드(3.14.0a7)뿐이었다는 점입니다. 이 알파에서 `fcc-server`를 기동하면 다음 에러로 죽습니다.

```text
ImportError: cannot import name 'get_annotate_from_class_namespace'
from 'annotationlib'
```

핀된 pydantic이 정식 3.14의 `annotationlib` API를 기대하는데, 초기 알파에는 해당 심볼이 아직 없어 발생하는 충돌입니다. 그렇다면 한 단계 낮은 안정 버전(3.13)에서 강제로라도 돌릴 수 있을까 싶어 시도했지만, 패키지 메타데이터의 하드 요구 때문에 설치 자체가 거부됩니다.

```text
free-claude-code==2.3.14 cannot be used ... your requirements are unsatisfiable.
```

결론은 명확합니다. **안정판 Python 3.14가 없는 환경에서는 이 프록시가 부팅되지 않습니다.** 재현 시도 중 실패: 패키지가 갓 나온 Python 3.14를 하드로 요구하나, 사용 가능한 3.14는 알파뿐이고 핀된 pydantic과 충돌. 이것은 도구의 결함이라기보다, 프로덕션 이미지가 보통 3.11~3.12에 머무는 현실과 어긋나는 **공격적 버전 핀**의 문제입니다.

### 자체호스팅 라우팅 경로 직접 측정

프록시 자체는 부팅에 막혔지만, 이 도구가 `ollama` 프로바이더에서 실제로 호출하는 **메커니즘**은 OpenAI 호환 엔드포인트입니다. 그래서 그 경로를 로컬 Ollama에 직접 호출해 측정했습니다. fcc가 더하는 프록시 오버헤드는 빠진, 백엔드 자체의 라우팅 성능입니다. Claude의 세 티어를 로컬 모델로 매핑한 결과는 다음과 같습니다(Apple Silicon, 동일 프롬프트, 64토큰 상한).

![자체호스팅 라우팅 실측 결과](/assets/images/free-claude-code-router-results.png)
*그림 2. Claude 티어를 로컬 Ollama 모델로 라우팅했을 때의 레이턴시와 처리 속도. opus 경로에 둔 qwen3:8b는 thinking 모델이라 추론 토큰을 길게 내보내 시간이 크게 늘어납니다.*

| 라우팅 | 모델 | 레이턴시 | 완성 토큰 | 처리 속도 |
|---|---|---|---|---|
| haiku | llama3.2:3b | 0.49s | 33 | 67.3 tok/s |
| sonnet | qwen2.5:7b | 0.56s | 20 | 35.7 tok/s |
| opus | qwen3:8b | 8.12s | 281 | 34.6 tok/s |

작은 모델(llama3.2:3b)은 0.5초 안에 응답을 끝내 Haiku 대체 트래픽에 충분히 빠릅니다. qwen2.5:7b도 0.56초로 실용적입니다. 반면 opus 경로에 올린 qwen3:8b는 8.12초가 걸렸는데, 이는 thinking 모델이 281개의 추론 토큰을 먼저 쏟아내기 때문입니다. 처리 속도(34.6 tok/s) 자체는 정상이지만, **추론형 모델을 무거운 티어에 배치하면 토큰 수가 폭증해 체감 지연이 커진다**는 점을 실측으로 확인했습니다. 티어 매핑을 설계할 때 모델의 추론 토큰 성향까지 고려해야 한다는 실무 교훈입니다.

## ThakiCloud K8s AI/ML SaaS 플랫폼 적용 및 시사점

이 도구의 진짜 가치는 "무료"가 아니라 **연결 패턴**에 있습니다. Anthropic 호환 프록시가 한 겹 들어가면, Claude Code 같은 상용 에이전트를 우리 인프라에 그대로 붙일 수 있습니다.

ThakiCloud는 K8s 위에서 Kueue로 GPU를 스케줄링하고 vLLM으로 모델을 서빙합니다. vLLM은 OpenAI 호환 엔드포인트(`/v1/chat/completions`)를 제공하므로, `free-claude-code`의 자체호스팅 프로바이더 경로(Ollama·llama.cpp와 동일한 방식)에 그대로 연결됩니다. 연결 방식은 자체호스팅 프로바이더 공통입니다. 베이스 URL을 클러스터의 vLLM 서비스 엔드포인트로 지정하고, 모델 식별자에 프로바이더 프리픽스를 붙이는 식입니다. Ollama가 `ollama/llama3.2:3b`로 표기되듯, 사내 vLLM에 올린 모델도 동일한 프리픽스 규칙으로 라우팅 대상에 넣습니다. 그러면 다음이 가능해집니다.

- **데이터 주권**: 코드와 프롬프트가 테넌시 밖으로 나가지 않습니다. 온프레미스·국정원 요구 대응 같은 규제 환경에서 핵심입니다.
- **비용 구조 전환**: 토큰당 종량 청구가 GPU 고정비로 바뀝니다. 사용량이 많은 팀일수록 자체 서빙의 손익분기가 빨라집니다.
- **티어별 차등 배치**: 가벼운 Haiku 트래픽은 작은 모델로, 무거운 작업은 큰 모델로 분기해 GPU 점유를 최적화할 수 있습니다. 위 실측이 그 차등 배치의 기준 수치를 제공합니다.

다만 우리가 이 도구를 그대로 채택하기보다는, **검증된 라우팅 패턴만 차용**하는 쪽이 합리적입니다. 멀티테넌트 환경에서는 프록시가 테넌트별 인증·격리·관측을 갖춰야 하는데, `free-claude-code`의 관리 UI는 루프백 단일 사용자 가정이라 그대로는 부족합니다. Anthropic 호환 정규화 계층의 발상은 빌려오되, 인증·쿼터·로깅은 우리 게이트웨이 표준에 맞춰 다시 구현하는 것이 맞습니다.

## 한계 및 반론

첫째, **약관 회색지대**입니다. "Claude Code를 무료로" 프레이밍은 무료 티어 프로바이더를 우회 경유하는 방식으로, 각 서비스의 약관과 충돌할 수 있습니다. 기업 환경에서 정당하고 지속 가능한 사용은 어디까지나 **자기 소유 백엔드(자체 서빙 모델)로의 라우팅**입니다. 이 글이 자체호스팅 경로만 강조하는 이유입니다.

둘째, **공격적 버전 핀**입니다. Python 3.14 하드 요구는 앞서 본 대로 안정 런타임이 없는 환경에서 즉시 부팅을 막습니다. 프로덕션 컨테이너 이미지를 3.14로 올리는 비용과 위험을 고려하면, 현 시점에서 이 도구를 그대로 배포 파이프라인에 넣기는 부담스럽습니다.

셋째, **품질 동등성은 보장되지 않습니다**. Claude의 Opus·Sonnet을 다른 모델로 바꾸면 코딩 품질이 그대로 유지되지 않습니다. 라우팅은 비용과 데이터 주권을 얻는 대신 응답 품질을 거래하는 선택이며, 작업 난이도에 따라 어느 트래픽을 어디로 보낼지는 측정으로 결정해야 합니다.

넷째, 이번 측정값은 **프록시를 거치지 않은 백엔드 직접 호출** 수치입니다. fcc의 정규화·라우팅 오버헤드는 포함되지 않았습니다. 안정판 Python 3.14 환경이 확보되면 프록시 경유 왕복 지연을 다시 측정해 보완할 계획입니다.

요약하면 `free-claude-code`는 "무료 해킹"으로 소비하면 위태롭지만, **Anthropic 호환 라우팅 패턴의 오픈소스 레퍼런스**로 읽으면 자체호스팅 추론 인프라에 상용 에이전트를 붙이는 설계의 좋은 출발점이 됩니다.

## 출처

- GitHub: [Alishahryar1/free-claude-code](https://github.com/Alishahryar1/free-claude-code) (MIT, 36.7k stars, v2.3.14)
- 실측 데이터: 로컬 Ollama OpenAI 호환 엔드포인트 직접 호출 (llama3.2:3b · qwen2.5:7b · qwen3:8b, Apple Silicon)
- 관련 글: ThakiCloud 기술 블로그 "Claude Code를 사내 모델로 라우팅하기 - claude-code-router"
