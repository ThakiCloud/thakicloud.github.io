---
title: "웹 터미널 오픈소스 비교 튜토리얼 — GoTTY vs ttyd vs Wetty"
excerpt: "브라우저에서 터미널을 제공하는 대표 오픈소스인 GoTTY, ttyd, Wetty를 아키텍처, 성능, 보안, 운영 편의성, 사용성 관점에서 비교하고 macOS에서 직접 실행·테스트하는 방법을 안내합니다."
seo_title: "GoTTY vs ttyd vs Wetty: 웹 터미널 비교 튜토리얼 - Thaki Cloud"
seo_description: "GoTTY, ttyd, Wetty의 아키텍처·보안·성능·운영 관점 비교와 macOS 설치·실행·스모크 테스트 스크립트, zsh alias 설정까지 한 번에 정리했습니다."
date: 2025-08-13
last_modified_at: 2025-08-13
categories:
  - tutorials
tags:
  - Web Terminal
  - GoTTY
  - ttyd
  - Wetty
  - DevOps
  - Security
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/web-terminal-gotty-ttyd-wetty-comparison/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 12분

## 개요

브라우저에서 터미널을 제공하는 오픈소스는 원격 교육, 데모, 운영 자동화, 임시 접근 공유 등 다양한 활용처가 있습니다. 본 글에서는 대표 프로젝트인 **GoTTY**, **ttyd**, **Wetty**를 여러 관점에서 비교하고, macOS에서 바로 실행 가능한 스모크 테스트 스크립트와 zsh alias를 제공합니다.

- GoTTY: [yudai/gotty](https://github.com/yudai/gotty?utm_source=chatgpt.com)
- ttyd: [tsl0922/ttyd](https://github.com/tsl0922/ttyd)
- Wetty: [butlerx/wetty](https://github.com/butlerx/wetty)

## 프로젝트 한눈에 보기

| 항목 | GoTTY | ttyd | Wetty |
|---|---|---|---|
| 주요 언어 | Go | C(서버) + libwebsockets | Node.js (Express) |
| 최신성/메인터넌스 | 비교적 레거시(마지막 릴리스 2017) | 활발 | 활발 |
| 인증 | Basic Auth(-c) | Basic/Auth 파일/토큰 옵션 제공 | Basic/Auth(옵션·미들웨어) |
| TLS | 자체 옵션(-t) | 자체 옵션(--ssl, cert/key) | 프록시/자체 설정 가능 |
| 다중 접속 | 멀티플렉서(tmux) 조합 권장 | 내장 멀티클라이언트 안정 | 내장 멀티클라이언트 |
| 리버스 프록시 | 가능 | 용이(Nginx/Caddy) | 용이(Express 기반) |
| 배포 난이도 | 중(레거시 빌드) | 낮음(Homebrew) | 낮음(npm/Docker) |
| 사용 사례 | 읽기 전용 쉐어/데모 | 범용 원격 쉘 | 브라우저 SSH/로컬 쉘 |

참고: GoTTY는 레거시 프로젝트로 최신 macOS/ARM 환경에서 빌드 이슈가 있을 수 있습니다. 실무 적용 시 ttyd 또는 Wetty를 우선 검토하는 것을 권장합니다. 원 저장소의 옵션과 보안 경고는 문서에서 확인하세요: [yudai/gotty](https://github.com/yudai/gotty?utm_source=chatgpt.com).

## 아키텍처 및 동작 원리

- **GoTTY**: Go 서버가 로컬 TTY 출력을 WebSocket으로 중계하고, 프론트엔드는 xterm.js/hterm를 사용합니다. 옵션 `-w`로 쓰기를 허용할 수 있으나 기본은 읽기 위주입니다. [yudai/gotty](https://github.com/yudai/gotty?utm_source=chatgpt.com)
- **ttyd**: C 기반 경량 서버가 libwebsockets로 TTY 세션을 브라우저에 중계합니다. 성숙한 옵션 집합과 낮은 오버헤드가 강점입니다. [tsl0922/ttyd](https://github.com/tsl0922/ttyd)
- **Wetty**: Node.js(Express)와 xterm.js를 조합해 SSH 또는 로컬 쉘을 브라우저에 제공합니다. JS 생태계 익숙한 팀에 적합합니다. [butlerx/wetty](https://github.com/butlerx/wetty)

## 보안 관점 비교

- **전송 보안**: 세 프로젝트 모두 기본 HTTP는 평문입니다. 프로덕션에서는 TLS 종단(Nginx/Caddy/Cloudflare) 또는 자체 TLS 옵션(ttyd/GoTTY)을 필수로 고려하세요.
- **인증**:
  - GoTTY: `-c user:pass`로 Basic Auth. `-r` 랜덤 URL 옵션도 제공하지만 보안 강도는 낮습니다.
  - ttyd: `--credential user:pass` 또는 별도 파일/토큰 옵션 제공. 리버스 프록시의 OIDC/SAML과 연계하기 용이.
  - Wetty: 미들웨어/리버스 프록시 조합으로 Basic/OIDC 등 확장 쉬움.
- **권한 제어**: 읽기 전용 데모는 GoTTY 기본값이 안전 측면에서 유리. 상호작용이 필요하면 tmux/명령 래핑, 컨테이너 격리(Docker)로 피해 범위를 줄이세요.
- **감사/로깅**: ttyd/Wetty는 프록시/미들웨어로 접근 로그 적재가 수월합니다. 민감 환경은 Bastion 호스트/세션 레코딩 솔루션을 고려하세요.

## 성능/운영 관점 비교

- **리소스 사용량**: ttyd가 경량인 편이며, Wetty는 Node 런타임 오버헤드가 있으나 확장성과 DX가 좋습니다.
- **확장성**: 세 프로젝트 모두 리버스 프록시에 올려 다중 인스턴스/세션 관리가 가능합니다. 세션 멀티플렉싱은 tmux/containers 조합이 일반적입니다.
- **운영 편의성**: Homebrew/npm/Docker로 배포가 쉬운 ttyd/Wetty가 유리. GoTTY는 레거시로 빌드 이슈를 감안해야 합니다.

## macOS 설치 및 실행

### ttyd 설치

```bash
brew install ttyd
```

실행(로컬 bash 쉘 제공, 포트 7681):

```bash
ttyd -p 7681 bash
```

Basic 인증 예:

```bash
ttyd -p 7681 --credential user:pass bash
```

TLS 자체 종단 예(인증서가 있을 때):

```bash
ttyd --ssl --ssl-cert /path/cert.pem --ssl-key /path/key.pem -p 8443 bash
```

### Wetty 설치

```bash
npm install -g wetty
```

로컬 쉘 제공:

```bash
wetty --port 3000 --command bash
```

리버스 프록시(Nginx 등) 뒤에서 TLS/인증을 처리하는 구성이 일반적입니다. 세부 옵션은 저장소 문서를 참고하세요: [butlerx/wetty](https://github.com/butlerx/wetty).

### GoTTY 설치(참고)

GoTTY는 레거시라 최신 macOS/ARM에서 빌드가 실패할 수 있습니다. 가능하면 컨테이너나 기존 바이너리를 활용하세요. 문서 옵션 예시는 아래와 같습니다.

```bash
# 실행 예시(포트 8080, 읽기 전용 top)
gotty -p 8080 top

# Basic Auth
gotty -p 8080 -c user:pass bash

# 제목 포맷(브라우저 타이틀)
{% raw %}
gotty --title-format "{{ .command }}@{{ .hostname }}" bash
{% endraw %}
```

옵션과 보안 경고는 저장소를 확인하세요: [yudai/gotty](https://github.com/yudai/gotty?utm_source=chatgpt.com).

## 스모크 테스트 스크립트(macOS)

세 도구를 감지해 동시에 기동 후 HTTP 응답을 확인하는 간단한 스크립트입니다. 설치된 항목만 테스트합니다.

```bash
#!/usr/bin/env bash
set -euo pipefail

TTVD_PORT=7681
WETTY_PORT=3000
GOTTY_PORT=8080

cleanup() {
  [[ -n "${TTVD_PID:-}" ]] && kill "$TTVD_PID" 2>/dev/null || true
  [[ -n "${WETTY_PID:-}" ]] && kill "$WETTY_PID" 2>/dev/null || true
  [[ -n "${GOTTY_PID:-}" ]] && kill "$GOTTY_PID" 2>/dev/null || true
}
trap cleanup EXIT

if command -v ttyd >/dev/null 2>&1; then
  ttyd -p "$TTVD_PORT" bash &
  TTVD_PID=$!
fi

if command -v wetty >/dev/null 2>&1; then
  wetty --port "$WETTY_PORT" --command bash &
  WETTY_PID=$!
fi

if command -v gotty >/dev/null 2>&1; then
  gotty -p "$GOTTY_PORT" bash &
  GOTTY_PID=$!
fi

sleep 2

check_port() {
  local name=$1 port=$2
  if curl -fsS "http://127.0.0.1:${port}" >/dev/null 2>&1; then
    echo "${name} OK on :${port}"
  else
    echo "${name} NOT RESPONDING on :${port}" >&2
  fi
}

[[ -n "${TTVD_PID:-}" ]] && check_port ttyd "$TTVD_PORT"
[[ -n "${WETTY_PID:-}" ]] && check_port wetty "$WETTY_PORT"
[[ -n "${GOTTY_PID:-}" ]] && check_port gotty "$GOTTY_PORT"
```

예상 출력:

```text
ttyd OK on :7681
wetty OK on :3000
gotty OK on :8080
```

## zshrc alias 제안

```bash
# ~/.zshrc
alias ttyd-up="ttyd -p 7681 bash"
alias wetty-up="wetty --port 3000 --command bash"
alias gotty-up="gotty -p 8080 bash"
alias ttyd-auth="ttyd -p 7681 --credential user:pass bash"
```

적용:

```bash
source ~/.zshrc
```

## 리버스 프록시 구성 팁

- TLS와 인증은 Nginx/Caddy/Cloudflare 등에서 종단하는 것이 가장 단순합니다.
- 백엔드로는 `http://127.0.0.1:7681`(ttyd) / `:3000`(Wetty) / `:8080`(GoTTY)을 프록시합니다.
- WebSocket 업그레이드 헤더(`Upgrade`, `Connection`)를 꼭 전달해야 합니다.

## 선택 가이드

- **가볍고 빠른 단일 바이너리**: ttyd 권장.
- **JS 생태계 친화/커스터마이즈**: Wetty 권장.
- **레거시/간단 데모**: GoTTY 가능(최신 환경 빌드 이슈 감안).

## 참고 링크(인용)

- GoTTY: [yudai/gotty](https://github.com/yudai/gotty?utm_source=chatgpt.com)
- ttyd: [tsl0922/ttyd](https://github.com/tsl0922/ttyd)
- Wetty: [butlerx/wetty](https://github.com/butlerx/wetty)


