---
title: "Omnara 튜토리얼: MCP 기반 원격 모니터링 · 리모트 런칭 완전 가이드"
excerpt: "Omnara로 Claude·Cursor 등 에이전트를 실시간 모니터링하고, 휴대폰에서 원격으로 런칭·응답하는 워크플로우를 단계별로 구현합니다. 실전 시나리오와 테스트 스크립트까지 제공합니다."
seo_title: "Omnara 튜토리얼: MCP 원격 모니터링/런칭 가이드 - Thaki Cloud"
seo_description: "Omnara로 AI 에이전트를 어디서나 제어하세요. 설치, 실시간 모니터링, 원격 런칭, MCP/SDK/REST 연동, macOS 테스트 스크립트, zsh 별칭까지 한 번에 정리한 실전형 튜토리얼."
date: 2025-08-14
last_modified_at: 2025-08-14
categories:
  - tutorials
  - llmops
tags:
  - Omnara
  - MCP
  - Claude
  - FastAPI
  - uv
  - PostgreSQL
  - AgentOps
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/omnara-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 개요

**Omnara**는 Claude Code, Cursor 등 다양한 AI 에이전트를 실시간으로 모니터링하고, 모바일/웹 대시보드에서 즉시 응답·승인·지시할 수 있게 해주는 플랫폼입니다. 이 글에서는 설치부터 실전 시나리오(프로덕션 장애 대응, 데이터 마이그레이션 감시, 레거시 리팩터링, 테스트 실패 해결)까지, **여러 활용 관점**으로 정리합니다. 참고: [omnara-ai/omnara GitHub 리포지토리](https://github.com/omnara-ai/omnara).

## 무엇을 만들 것인가

- **실시간 모니터링 파이프라인**: 로컬에서 돌리는 Claude/Cursor 세션의 모든 스텝을 대시보드에서 확인하고, 질의가 오면 휴대폰으로 바로 응답.
- **리모트 런처(serve)**: 노트북에서 서버를 올려두고, 외부에서 에이전트를 트리거해 배치성 업무 시작/중지/승인.
- **MCP/SDK/REST 통합**: 팀/제품 맞춤형으로 MCP, Python SDK, REST API 중 적합한 인터페이스 선택.

## 사전 요구사항 및 macOS 테스트 환경

- **OS**: macOS Sonoma/Sequoia 이상 권장
- **Python**: 3.10+
- **uv**: 0.4+ (선택, 빠른 설치/실행용)
- **Node.js**: 18+ (CLI 도구 일부 개발용)

버전 예시:

```bash
python --version    # Python 3.11.x
uv --version        # uv 0.4.x
node --version      # v20.x.x
```

## 빠른 시작

### 옵션 1: 로컬 Claude/Cursor 세션 모니터링

```bash
# 권장: uv로 설치/실행 (빠름)
uv pip install omnara
uv run omnara

# 또는 pip
pip install omnara
omnara
```

첫 실행 시 브라우저 인증 창이 열립니다. 로그인 후 대시보드에서 **에이전트 진행 로그**와 **질의 알림**이 실시간으로 표시됩니다.

### 옵션 2: 원격 런칭 서버(serve)

```bash
# uv
uv pip install omnara
uv run omnara serve

# pip
pip install omnara
omnara serve
```

터미널에 표시되는 **Webhook URL**을 모바일 앱에 등록하면, 폰에서 바로 에이전트를 실행하고 커뮤니케이션할 수 있습니다.

## 고급 사용법(클라이언트 도구 없이)

### 방법 1: 직접 래퍼 스크립트 실행

```bash
# 기본
python -m webhooks.claude_wrapper_v3 --api-key YOUR_API_KEY

# git diff 추적
python -m webhooks.claude_wrapper_v3 --api-key YOUR_API_KEY --git-diff

# 자체 호스팅 API 엔드포인트 지정
python -m webhooks.claude_wrapper_v3 --api-key YOUR_API_KEY --base-url https://your-server.com
```

### 방법 2: 수동 MCP 설정

```json
{% raw %}
{
  "mcpServers": {
    "omnara": {
      "command": "pipx",
      "args": ["run", "--no-cache", "omnara", "mcp", "--api-key", "YOUR_API_KEY"]
    }
  }
}
{% endraw %}
```

### 방법 3: Python SDK

```python
from omnara import OmnaraClient
import uuid

client = OmnaraClient(api_key="your-api-key")
instance_id = str(uuid.uuid4())

# 로그 전송(사용자 입력 불필요)
client.send_message(
    agent_type="claude-code",
    content="Analyzing codebase structure",
    agent_instance_id=instance_id,
    requires_user_input=False,
)

# 사용자 입력 요청
answer = client.send_message(
    content="Should I refactor this legacy module?",
    agent_instance_id=instance_id,
    requires_user_input=True,
)
print(answer)
```

### 방법 4: REST API

```bash
curl -X POST https://api.omnara.ai/api/v1/messages/agent \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -d '{"content":"Starting deployment process","agent_type":"claude-code","requires_user_input":false}'
```

## 실전 시나리오별 레시피

### 프로덕션 장애 대응(Incident Firefighter)

- **목표**: 운영 이슈 발생 시, 에이전트가 점검 로그/메트릭을 나열하고, 필요한 추가 정보만 사용자가 모바일에서 빠르게 승인/제공.
- **설정**:
  - 로컬/서버에 `uv run omnara` 또는 `uv run omnara serve` 실행
  - Git diff 추적 옵션으로 변경 포인트 중심으로 조사
- **플로우**:
  1) 에이전트가 이상 징후 탐지 → 2) 관련 로그 링크/요약 생성 → 3) 모바일 알림 → 4) 사용자가 추가 로그 범위/시간대 선택 응답 → 5) 원인/조치 제안.

실행 예시 로그:

```text
[omnara] monitoring session started (project=payments)
[omnara] anomaly detected in service: checkout-api (p95 latency up 48%)
[omnara] need approval: fetch last 30m logs from cloudwatch? (Y/N)
```

### 데이터 파이프라인 가디언(Data Pipeline Guardian)

- **목표**: 대규모 ETL/마이그레이션 작업 진행 중 이상 신호를 조기 감지하고, 스키마 변경 승인/롤백을 원격 승인.
- **설정**: `omnara serve`로 원격 런칭. 배치 시작 전 Slack/Email/SMS 알림 경로 연결.
- **체크포인트**: 레코드 카운트 드리프트, 지연 커브, 에러율 상승 시 사용자 승인 요청.

### 리팩터링 코파일럿(Refactoring Copilot)

- **목표**: 레거시 모듈 리팩터링 중 비즈니스 규칙 확인을 실시간 Q&A로 처리.
- **설정**: 모니터링 모드에서 `--git-diff` 활성화. PR 단위로 진행.
- **팁**: 함수 시그니처 변경은 모바일에서 즉시 검토/승인하여 팀 회의 중에도 진행 지속.

### 테스트 스위트 닥터(Test Suite Doctor)

- **목표**: 야간 테스트 실패 시, 로그 요약·가설 원인·수정 후보 PR 초안까지 자동 생성. 아침에 질문만 답하면 머지 가능 상태로.
- **설정**: CI에서 실패 시 Omnara로 이벤트 발행 → 모바일에서 컨텍스트 보충.

## macOS 테스트 스크립트(필수)

아래 스크립트는 설치 확인, 모니터링/서버 도움말 확인, 짧은 가동 후 종료까지 자동화합니다.

```bash
#!/usr/bin/env bash
set -euo pipefail

echo "[1/5] Checking versions"
python --version || true
uv --version || true

echo "[2/5] Installing omnara via uv"
uv pip install -q omnara

echo "[3/5] CLI help checks"
uv run omnara -h || true
uv run omnara serve -h || true

echo "[4/5] Smoke run (monitor)"
timeout 5s uv run omnara || echo "(monitor exited or timed out as expected)"

echo "[5/5] Smoke run (serve)"
timeout 5s uv run omnara serve || echo "(serve exited or timed out as expected)"

echo "✅ All checks completed"
```

예상 출력:

```text
[1/5] Checking versions
Python 3.11.x
uv 0.4.x
[2/5] Installing omnara via uv
[3/5] CLI help checks
Usage: omnara [OPTIONS]
...
Usage: omnara serve [OPTIONS]
...
[4/5] Smoke run (monitor)
Opening browser for authentication...
...
(monitor exited or timed out as expected)
[5/5] Smoke run (serve)
Serving Omnara on http://localhost:9xxx
...
(serve exited or timed out as expected)
✅ All checks completed
```

## zshrc 별칭 가이드

```bash
# ~/.zshrc
alias omn='uv run omnara'
alias omnserve='uv run omnara serve'
alias omnhelp='uv run omnara -h && uv run omnara serve -h'
```

터미널 재시작 또는 `source ~/.zshrc` 후 다음처럼 사용합니다:

```bash
omn          # 모니터링 모드 실행
omnserve     # 원격 런칭 서버 실행
omnhelp      # 헬프 확인
```

## 트러블슈팅

- **브라우저 인증 창이 열리지 않음**: 로컬 방화벽/프록시 확인. `--base-url`로 자체 호스팅 엔드포인트 지정 가능.
- **CLI가 오래 붙잡고 있음**: 데모/헬프 확인은 `-h` 사용. 스모크 테스트는 `timeout`으로 짧게.
- **MCP 통합이 동작 안 함**: `pipx run` 경로, API Key, `mcpServers` JSON 타이포 확인.
- **Git diff 추적이 비어 있음**: 저장소 루트에서 실행했는지와 변경사항이 커밋/스테이징되어 있는지 확인.

## 참고 링크

- Omnara GitHub: [omnara-ai/omnara](https://github.com/omnara-ai/omnara)


