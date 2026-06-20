---
title: "ntfy 푸시 알림 서비스 완전 가이드 - 무료로 알림 시스템 구축하기"
excerpt: "ntfy를 이용해 스크립트에서 휴대폰으로 알림을 보내는 방법부터 자체 서버 구축까지 단계별로 알아봅니다."
seo_title: "ntfy 푸시 알림 서비스 완전 가이드 - macOS 실습 포함 - Thaki Cloud"
seo_description: "ntfy를 이용한 무료 푸시 알림 시스템 구축 가이드. 기본 사용법부터 Docker 자체 서버 설치까지 macOS 환경에서 실습 가능한 예제로 설명합니다."
date: 2025-07-01
last_modified_at: 2025-07-01
categories:
  - tutorials
tags:
  - ntfy
  - push-notification
  - notification-system
  - open-source
  - self-hosting
  - docker
  - macos
  - tutorial
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/ntfy-push-notification-service-complete-guide/"
reading_time: true
published: false
---

⏱️ **예상 읽기 시간**: 12분

## ntfy란 무엇인가?

**ntfy**는 오픈소스 HTTP 기반 pub-sub 알림 서비스입니다. 간단한 PUT/POST 요청으로 **휴대폰이나 데스크톱에 푸시 알림을 전송**할 수 있으며, 회원가입이나 결제 없이 무료로 사용할 수 있습니다.

### 주요 특징

- **무료 사용**: 회원가입 없이 즉시 사용 가능
- **크로스 플랫폼**: Android, iOS, 웹 지원
- **오픈소스**: 자체 서버 구축 가능
- **간단한 API**: HTTP PUT/POST로 알림 전송
- **다양한 기능**: 파일 첨부, 우선순위, 이모지 지원

## 기본 사용법 - 첫 번째 알림 보내기

### 1. 모바일 앱 설치

먼저 알림을 받을 앱을 설치합니다:

- **Android**: [Google Play Store](https://play.google.com/store/apps/details?id=io.heckel.ntfy) 또는 [F-Droid](https://f-droid.org/packages/io.heckel.ntfy/)
- **iOS**: [App Store](https://apps.apple.com/app/ntfy/id1625396347)

### 2. 토픽 구독

앱에서 **토픽**을 구독합니다. 토픽은 알림을 받을 채널명입니다:

1. 앱을 열고 `+` 버튼 클릭
2. 토픽명 입력 (예: `my-alerts`)
3. 서버 URL: `https://ntfy.sh` (기본값)
4. 구독 완료

### 3. 첫 번째 알림 전송

macOS 터미널에서 다음 명령어를 실행합니다:

```bash
curl -d "Hello from ntfy!" ntfy.sh/my-alerts
```

**실행 결과**: 구독한 모든 기기에 알림이 도착합니다!

## macOS 환경에서의 실습 예제

### 개발환경 요구사항

이 튜토리얼은 다음 환경에서 테스트되었습니다:

- **macOS**: 26.0 (Darwin 25.0)
- **curl**: 8.7.1
- **zsh**: 5.9

### 테스트 스크립트 작성

실습을 위한 테스트 스크립트를 작성해보겠습니다:

```bash
#!/bin/bash
# 파일명: test-ntfy.sh

# 토픽 설정
TOPIC="test-$(date +%s)"
NTFY_URL="https://ntfy.sh"

echo "=== ntfy 테스트 시작 ==="
echo "토픽: $TOPIC"
echo "서버: $NTFY_URL"
echo ""

# 1. 기본 알림 테스트
echo "1. 기본 알림 전송..."
curl -s -d "테스트 메시지입니다!" "$NTFY_URL/$TOPIC"
echo " ✓ 전송 완료"

# 2. 제목과 내용이 있는 알림
echo "2. 제목 포함 알림 전송..."
curl -s \
  -H "Title: 시스템 알림" \
  -d "서버 상태가 정상입니다." \
  "$NTFY_URL/$TOPIC"
echo " ✓ 전송 완료"

# 3. 우선순위가 높은 알림
echo "3. 긴급 알림 전송..."
curl -s \
  -H "Priority: urgent" \
  -H "Title: 🚨 긴급 알림" \
  -d "즉시 확인이 필요합니다!" \
  "$NTFY_URL/$TOPIC"
echo " ✓ 전송 완료"

# 4. 태그와 이모지 포함
echo "4. 태그 포함 알림 전송..."
curl -s \
  -H "Tags: warning,backup" \
  -H "Title: 백업 완료" \
  -d "데이터베이스 백업이 성공적으로 완료되었습니다." \
  "$NTFY_URL/$TOPIC"
echo " ✓ 전송 완료"

echo ""
echo "=== 테스트 완료 ==="
echo "모바일 앱에서 '$TOPIC' 토픽을 구독하여 알림을 확인하세요."
echo "구독 URL: $NTFY_URL/$TOPIC"
```

### 실행 방법

```bash
# 스크립트 실행 권한 부여
chmod +x test-ntfy.sh

# 테스트 실행
./test-ntfy.sh
```

### 실행 결과 예시

```bash
=== ntfy 테스트 시작 ===
토픽: test-1751368601
서버: https://ntfy.sh

1. 기본 알림 전송...
{"id":"xZx2RWS3yQiJ","time":1751368601,"expires":1751411801,"event":"message","topic":"test-1751368601","message":"테스트 메시지입니다!"}
 ✓ 전송 완료

2. 제목 포함 알림 전송...
{"id":"9RA3ohj04JMa","time":1751368602,"expires":1751411802,"event":"message","topic":"test-1751368601","title":"시스템 알림","message":"서버 상태가 정상입니다."}
 ✓ 전송 완료

3. 긴급 알림 전송...
{"id":"riazUtTIG37b","time":1751368603,"expires":1751411803,"event":"message","priority":5}
 ✓ 전송 완료

4. 태그 포함 알림 전송...
{"id":"0iPjhUqAhkkR","time":1751368603,"expires":1751411803,"event":"message","tags":["warning","backup"]}
 ✓ 전송 완료

=== 테스트 완료 ===
```

각 알림마다 **고유한 ID**와 **만료 시간**이 할당되며, **우선순위**와 **태그**가 정상적으로 처리됩니다.

## 고급 기능 활용

### 1. 파일 첨부 알림

```bash
# 이미지 파일 첨부
curl -T screenshot.png \
  -H "Title: 스크린샷 공유" \
  -H "Filename: screenshot.png" \
  ntfy.sh/my-alerts

# 로그 파일 첨부
curl -T system.log \
  -H "Title: 시스템 로그" \
  -H "Filename: system.log" \
  ntfy.sh/my-alerts
```

### 2. 우선순위 설정

```bash
# 낮은 우선순위 (silent)
curl -H "Priority: min" -d "정보성 메시지" ntfy.sh/my-alerts

# 기본 우선순위 (default)
curl -H "Priority: default" -d "일반 알림" ntfy.sh/my-alerts

# 높은 우선순위 (urgent)
curl -H "Priority: urgent" -d "긴급 알림!" ntfy.sh/my-alerts
```

### 3. 액션 버튼 추가

```bash
curl \
  -H "Actions: view, 확인하기, https://example.com" \
  -H "Title: 웹사이트 확인" \
  -d "새로운 업데이트가 있습니다." \
  ntfy.sh/my-alerts
```

### 4. 스케줄링된 알림

```bash
# 5분 후 알림 전송
curl \
  -H "At: in 5 minutes" \
  -H "Title: 리마인더" \
  -d "회의 시간입니다!" \
  ntfy.sh/my-alerts

# 특정 시간에 알림 전송
curl \
  -H "At: tomorrow 9am" \
  -H "Title: 일정 알림" \
  -d "오늘 할 일을 확인하세요." \
  ntfy.sh/my-alerts
```

## 실제 사용 사례

### 1. 서버 모니터링 스크립트

```bash
#!/bin/bash
# 파일명: server-monitor.sh

TOPIC="server-alerts"
HOSTNAME=$(hostname)

# 디스크 사용량 체크
DISK_USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
if [ $DISK_USAGE -gt 80 ]; then
    curl -s \
      -H "Priority: urgent" \
      -H "Tags: warning,disk" \
      -H "Title: 🚨 디스크 사용량 경고" \
      -d "$HOSTNAME의 디스크 사용량이 ${DISK_USAGE}%입니다." \
      ntfy.sh/$TOPIC
fi

# 메모리 사용량 체크
MEMORY_USAGE=$(free | grep Mem | awk '{printf("%.0f", $3/$2 * 100.0)}')
if [ $MEMORY_USAGE -gt 90 ]; then
    curl -s \
      -H "Priority: urgent" \
      -H "Tags: warning,memory" \
      -H "Title: 🚨 메모리 사용량 경고" \
      -d "$HOSTNAME의 메모리 사용량이 ${MEMORY_USAGE}%입니다." \
      ntfy.sh/$TOPIC
fi
```

### 2. 백업 완료 알림

```bash
#!/bin/bash
# 파일명: backup-notify.sh

TOPIC="backup-status"
BACKUP_DIR="/backup"
TIMESTAMP=$(date '+%Y-%m-%d %H:%M:%S')

# 백업 실행 (예시)
if rsync -av /home/user/ $BACKUP_DIR/; then
    curl -s \
      -H "Tags: white_check_mark,backup" \
      -H "Title: ✅ 백업 성공" \
      -d "백업이 성공적으로 완료되었습니다. ($TIMESTAMP)" \
      ntfy.sh/$TOPIC
else
    curl -s \
      -H "Priority: urgent" \
      -H "Tags: x,backup" \
      -H "Title: ❌ 백업 실패" \
      -d "백업 작업이 실패했습니다. 즉시 확인하세요. ($TIMESTAMP)" \
      ntfy.sh/$TOPIC
fi
```

### 3. 코드 배포 알림

```bash
#!/bin/bash
# 파일명: deploy-notify.sh

TOPIC="deployment"
PROJECT_NAME="my-app"
BRANCH=$(git branch --show-current)
COMMIT=$(git rev-parse --short HEAD)

curl -s \
  -H "Tags: rocket,deployment" \
  -H "Title: 🚀 배포 시작" \
  -d "$PROJECT_NAME ($BRANCH@$COMMIT) 배포를 시작합니다." \
  ntfy.sh/$TOPIC

# 배포 작업 수행...
# (배포 스크립트 실행)

curl -s \
  -H "Tags: white_check_mark,deployment" \
  -H "Title: ✅ 배포 완료" \
  -d "$PROJECT_NAME ($BRANCH@$COMMIT) 배포가 완료되었습니다." \
  ntfy.sh/$TOPIC
```

## 자체 서버 구축하기

### Docker Compose를 이용한 설치

```yaml
# docker-compose.yml
version: '3.8'

services:
  ntfy:
    image: binwiederhier/ntfy
    container_name: ntfy
    command:
      - serve
    environment:
      - NTFY_BASE_URL=https://ntfy.yourdomain.com
      - NTFY_UPSTREAM_BASE_URL=https://ntfy.sh
      - NTFY_LISTEN_HTTP=:80
      - NTFY_BEHIND_PROXY=true
    volumes:
      - ./data:/var/lib/ntfy
      - ./ntfy.yml:/etc/ntfy/server.yml:ro
    ports:
      - "8080:80"
    restart: unless-stopped
```

### 설정 파일 작성

```yaml
# ntfy.yml
# 서버 설정
base-url: "https://ntfy.yourdomain.com"
listen-http: ":80"
behind-proxy: true

# 데이터베이스 설정
cache-file: "/var/lib/ntfy/cache.db"
cache-duration: "12h"

# 인증 설정
auth-file: "/var/lib/ntfy/user.db"
auth-default-access: "read-write"

# 첨부 파일 설정
attachment-cache-dir: "/var/lib/ntfy/attachments"
attachment-total-size-limit: "5G"

# 로그 설정
log-level: "info"
log-file: "/var/lib/ntfy/ntfy.log"
```

### 실행 및 관리

```bash
# 서버 시작
docker-compose up -d

# 로그 확인
docker-compose logs -f ntfy

# 서버 상태 확인
curl -s http://localhost:8080/v1/health
```

## 보안 고려사항

### 1. 토픽명 보안

```bash
# 예측 어려운 토픽명 사용
TOPIC="alerts-$(openssl rand -hex 8)"
echo "생성된 토픽: $TOPIC"
```

### 2. 액세스 토큰 사용

```bash
# 토큰 기반 인증
curl \
  -H "Authorization: Bearer tk_your_token_here" \
  -d "보안 메시지" \
  ntfy.sh/secure-topic
```

### 3. HTTPS 사용

```bash
# 항상 HTTPS 사용
curl -d "메시지" https://ntfy.sh/my-topic
```

## 문제 해결

### 자주 발생하는 문제들

1. **알림이 오지 않을 때**
   - 토픽명 확인
   - 인터넷 연결 상태 확인
   - 앱의 알림 권한 확인

2. **파일 첨부가 안될 때**
   - 파일 크기 제한 확인 (무료 버전: 16MB)
   - 파일 경로 확인

3. **자체 서버 연결 문제**
   - 방화벽 설정 확인
   - SSL 인증서 확인

### 디버깅 명령어

```bash
# 상세 정보 확인
curl -v -d "테스트" ntfy.sh/debug-topic

# 서버 상태 확인
curl -s ntfy.sh/v1/health

# 토픽 정보 확인
curl -s ntfy.sh/v1/stats
```

## 추가 자료 및 참고 링크

- [ntfy 공식 문서](https://docs.ntfy.sh/)
- [GitHub 저장소](https://github.com/binwiederhier/ntfy)
- [Discord 커뮤니티](https://discord.gg/cT7ECsZj9w)
- [API 참조 문서](https://docs.ntfy.sh/publish/)

## zshrc Aliases 설정

편리한 사용을 위한 `~/.zshrc` 설정을 추가하세요:

```bash
# ~/.zshrc에 추가
# ntfy 관련 alias 설정
export NTFY_SERVER="https://ntfy.sh"
export NTFY_TOPIC="my-alerts"

# 기본 알림 전송
alias notify="curl -d"
alias ntfy-send="curl -d '$1' $NTFY_SERVER/$NTFY_TOPIC"

# 우선순위별 알림
alias ntfy-urgent="curl -H 'Priority: urgent' -d"
alias ntfy-normal="curl -H 'Priority: default' -d"
alias ntfy-low="curl -H 'Priority: min' -d"

# 서버 상태 확인
alias ntfy-health="curl -s $NTFY_SERVER/v1/health"
alias ntfy-stats="curl -s $NTFY_SERVER/v1/stats"

# 편의 함수
ntfy() {
    if [ -z "$1" ]; then
        echo "사용법: ntfy <메시지> [토픽]"
        return 1
    fi
    
    local message="$1"
    local topic="${2:-$NTFY_TOPIC}"
    
    curl -d "$message" "$NTFY_SERVER/$topic"
}

ntfy-title() {
    if [ -z "$1" ] || [ -z "$2" ]; then
        echo "사용법: ntfy-title <제목> <메시지> [토픽]"
        return 1
    fi
    
    local title="$1"
    local message="$2"
    local topic="${3:-$NTFY_TOPIC}"
    
    curl -H "Title: $title" -d "$message" "$NTFY_SERVER/$topic"
}
```

### 설정 적용 및 사용법

```bash
# 설정 적용
source ~/.zshrc

# 사용 예시
ntfy "테스트 메시지"
ntfy-title "시스템 알림" "서버가 정상 작동 중입니다"
ntfy-urgent "긴급 상황!" my-alerts
ntfy-health
```

## 마무리

ntfy는 간단하면서도 강력한 알림 시스템입니다. 기본적인 텍스트 알림부터 파일 첨부, 우선순위 설정, 액션 버튼까지 다양한 기능을 제공하며, 자체 서버 구축을 통해 완전한 제어권을 가질 수 있습니다.

이 가이드의 예제들을 활용하여 **서버 모니터링**, **백업 알림**, **배포 상태 확인** 등 다양한 용도로 활용해보세요. 무료로 시작할 수 있으며, 필요에 따라 유료 플랜이나 자체 서버로 확장할 수 있습니다.

---

**다음 단계**: 이제 ntfy를 활용한 실제 프로젝트에 통합해보거나, 더 복잡한 워크플로우 자동화에 도전해보세요! 