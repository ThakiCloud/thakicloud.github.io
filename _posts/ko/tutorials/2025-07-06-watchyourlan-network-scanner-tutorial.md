---
title: "WatchYourLAN: 웹 GUI를 갖춘 경량 네트워크 IP 스캐너 완전 가이드"
excerpt: "6k 스타를 받은 WatchYourLAN으로 네트워크 보안 강화하기. 새로운 호스트 탐지, 알림 설정, Grafana 대시보드 연동까지 macOS에서 실습해보세요."
seo_title: "WatchYourLAN 네트워크 스캐너 Go Docker 완벽 튜토리얼 - Thaki Cloud"
seo_description: "Go와 TypeScript로 구축된 WatchYourLAN 네트워크 IP 스캐너의 설치, 설정, 모니터링, Grafana 연동을 macOS 환경에서 실습과 함께 상세히 알아봅니다."
date: 2025-07-06
last_modified_at: 2025-07-06
categories:
  - tutorials
tags:
  - watchyourlan
  - network-scanner
  - ip-scanner
  - go
  - docker
  - network-security
  - monitoring
  - grafana
  - influxdb
  - prometheus
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/watchyourlan-network-scanner-tutorial/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 14분

## 서론

네트워크 보안은 현대 IT 환경에서 가장 중요한 요소 중 하나입니다. 특히 홈 오피스나 소규모 사무실에서는 누가 네트워크에 연결되어 있는지 파악하고, 새로운 디바이스의 무단 접속을 감지하는 것이 필수적입니다.

[WatchYourLAN](https://github.com/aceberg/WatchYourLAN)은 이러한 요구를 해결하는 경량화된 네트워크 IP 스캐너입니다. Go와 TypeScript로 구축된 이 도구는 6k GitHub 스타를 받으며 개발자들과 네트워크 관리자들에게 인정받고 있습니다.

본 튜토리얼에서는 WatchYourLAN의 설치부터 고급 설정, Grafana 대시보드 연동까지 macOS 환경에서 실습과 함께 알아보겠습니다.

## WatchYourLAN이란?

### 핵심 기능

**🔍 네트워크 스캐닝**
- 경량화된 ARP 기반 IP 스캐닝
- 실시간 네트워크 호스트 탐지
- 다중 인터페이스 동시 모니터링

**🚨 알림 시스템**
- 새로운 호스트 발견 시 즉시 알림
- Shoutrrr 통합으로 다양한 플랫폼 지원
- Discord, Telegram, Slack, Email 등 지원

**📊 모니터링 및 분석**
- 호스트 온라인/오프라인 히스토리 추적
- 웹 GUI를 통한 직관적인 관리
- InfluxDB2, Prometheus 연동 지원

**🎨 사용자 친화적 인터페이스**
- 현대적인 웹 GUI
- 다양한 Bootstrap 테마 지원
- 반응형 디자인

### 기술 스택

**백엔드**: Go
**프론트엔드**: TypeScript + Bootstrap
**데이터베이스**: SQLite (기본) / PostgreSQL
**모니터링**: InfluxDB2, Prometheus, Grafana
**배포**: Docker, 바이너리

## 시스템 요구사항

### macOS 환경 확인

```bash
# macOS 버전 확인
sw_vers

# 네트워크 인터페이스 확인
ifconfig | grep -E '^[a-z]'

# Docker 설치 확인
docker --version

# Go 설치 확인 (소스 빌드용)
go version
```

### 필수 도구 설치

```bash
# Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Docker Desktop 설치
brew install --cask docker

# Docker 실행 확인
docker run hello-world

# arp-scan 설치 (선택사항)
brew install arp-scan

# 네트워크 정보 확인
ipconfig getifaddr en0
route -n get default | grep gateway
``` 

## 설치 가이드

### 방법 1: Docker를 이용한 설치 (권장)

#### 기본 Docker 실행

```bash
# 네트워크 인터페이스 확인
INTERFACE=$(route get default | grep interface | awk '{print $2}')
echo "Primary interface: $INTERFACE"

# 시간대 설정
TIMEZONE=$(ls -la /etc/localtime | cut -d/ -f8-9)
echo "Timezone: $TIMEZONE"

# WatchYourLAN 실행
docker run -d --name watchyourlan \
  -e "IFACES=$INTERFACE" \
  -e "TZ=$TIMEZONE" \
  --network="host" \
  -v $(pwd)/watchyourlan:/data/WatchYourLAN \
  aceberg/watchyourlan

# 실행 상태 확인
docker ps | grep watchyourlan
docker logs watchyourlan
```

#### Docker Compose 설정

```bash
# docker-compose.yml 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  watchyourlan:
    image: aceberg/watchyourlan
    container_name: watchyourlan
    network_mode: host
    environment:
      - IFACES=$INTERFACE
      - TZ=$TIMEZONE
      - HOST=0.0.0.0
      - PORT=8840
      - THEME=sand
      - COLOR=dark
      - TIMEOUT=60
      - LOG_LEVEL=info
      - TRIM_HIST=48
      - HIST_IN_DB=false
      # 알림 설정 (선택사항)
      # - SHOUTRRR_URL=gotify://192.168.0.1:8083/token/?title=Unknown host detected
    volumes:
      - ./data:/data/WatchYourLAN
    restart: unless-stopped

  # 선택사항: InfluxDB2 (모니터링 데이터 저장용)
  influxdb:
    image: influxdb:2.7
    container_name: influxdb2
    ports:
      - "8086:8086"
    environment:
      - DOCKER_INFLUXDB_INIT_MODE=setup
      - DOCKER_INFLUXDB_INIT_USERNAME=admin
      - DOCKER_INFLUXDB_INIT_PASSWORD=adminpassword
      - DOCKER_INFLUXDB_INIT_ORG=home
      - DOCKER_INFLUXDB_INIT_BUCKET=watchyourlan
    volumes:
      - influxdb-data:/var/lib/influxdb2
    restart: unless-stopped

volumes:
  influxdb-data:
EOF

# 실행
docker-compose up -d

# 로그 확인
docker-compose logs -f watchyourlan
```

### 방법 2: 소스코드 빌드

#### Go 환경 설정

```bash
# Go 설치 (Homebrew)
brew install go

# 작업 디렉토리 생성
mkdir -p ~/projects/watchyourlan
cd ~/projects/watchyourlan

# 소스코드 클론
git clone https://github.com/aceberg/WatchYourLAN.git
cd WatchYourLAN

# 종속성 확인
go mod download
go mod verify

# 빌드
make build

# 실행 파일 확인
ls -la WatchYourLAN

# 설정 디렉토리 생성
mkdir -p ~/watchyourlan-data

# 실행
./WatchYourLAN -d ~/watchyourlan-data
```

#### 자동 설치 스크립트

```bash
#!/bin/bash
# 파일명: install_watchyourlan.sh

set -e

echo "🔍 WatchYourLAN 자동 설치 스크립트"

# 환경 확인
if ! command -v docker &> /dev/null; then
    echo "❌ Docker가 설치되지 않았습니다."
    echo "Homebrew로 Docker Desktop을 설치하세요: brew install --cask docker"
    exit 1
fi

# 네트워크 인터페이스 자동 탐지
INTERFACE=$(route get default | grep interface | awk '{print $2}' 2>/dev/null || echo "en0")
TIMEZONE=$(ls -la /etc/localtime | cut -d/ -f8-9 2>/dev/null || echo "Asia/Seoul")

echo "🌐 감지된 네트워크 인터페이스: $INTERFACE"
echo "🕐 시간대: $TIMEZONE"

# 데이터 디렉토리 생성
DATA_DIR="./watchyourlan-data"
mkdir -p "$DATA_DIR"

# Docker 실행
echo "🚀 WatchYourLAN 시작..."
docker run -d --name watchyourlan \
  -e "IFACES=$INTERFACE" \
  -e "TZ=$TIMEZONE" \
  -e "TIMEOUT=60" \
  -e "LOG_LEVEL=info" \
  --network="host" \
  -v "$(pwd)/$DATA_DIR:/data/WatchYourLAN" \
  aceberg/watchyourlan

# 상태 확인
sleep 5
if docker ps | grep -q watchyourlan; then
    echo "✅ WatchYourLAN이 성공적으로 시작되었습니다!"
    echo "🌐 웹 인터페이스: http://localhost:8840"
    echo "📊 실시간 로그: docker logs -f watchyourlan"
    echo "🛑 중지: docker stop watchyourlan"
    echo "🗑️ 제거: docker rm watchyourlan"
else
    echo "❌ 설치에 실패했습니다. 로그를 확인하세요:"
    docker logs watchyourlan
fi
```

```bash
# 스크립트 실행 권한 부여
chmod +x install_watchyourlan.sh

# 실행
./install_watchyourlan.sh
```

## 기본 설정 및 사용법

### 웹 인터페이스 접속

설치가 완료되면 웹 브라우저에서 `http://localhost:8840`에 접속합니다.

### 기본 구성 요소

**📊 대시보드**
- 실시간 네트워크 스캔 결과
- 온라인/오프라인 호스트 상태
- 최근 활동 히스토리

**⚙️ 설정 페이지**
- 스캔 간격 조정
- 알림 설정
- 테마 변경

**📈 히스토리**
- 호스트별 접속 기록
- 시간대별 네트워크 활동
- 통계 정보

### 환경 변수 설정

주요 환경 변수들을 자세히 알아보겠습니다:

```yaml
# config_v2.yaml 예제
host: "0.0.0.0"           # 리스닝 주소
port: "8840"              # 웹 GUI 포트
theme: "sand"             # Bootstrap 테마
color: "dark"             # 배경색 (light/dark)
ifaces: "en0"             # 스캔할 네트워크 인터페이스
timeout: 60               # 스캔 간격 (초)
log_level: "info"         # 로그 레벨
trim_hist: 48             # 히스토리 보관 기간 (시간)
hist_in_db: false         # DB에 히스토리 저장 여부
``` 

## 알림 시스템 설정

WatchYourLAN은 Shoutrrr를 통해 다양한 플랫폼으로 알림을 보낼 수 있습니다.

### Discord 알림 설정

```bash
# Discord Webhook URL 설정
DISCORD_WEBHOOK="discord://token@id"

# Docker 환경변수로 설정
docker run -d --name watchyourlan \
  -e "IFACES=en0" \
  -e "SHOUTRRR_URL=$DISCORD_WEBHOOK" \
  --network="host" \
  -v $(pwd)/watchyourlan:/data/WatchYourLAN \
  aceberg/watchyourlan
```

### Telegram 알림 설정

```bash
# Telegram Bot Token과 Chat ID 설정
TELEGRAM_TOKEN="your_bot_token"
TELEGRAM_CHAT_ID="your_chat_id"
TELEGRAM_URL="telegram://$TELEGRAM_TOKEN@telegram?chats=$TELEGRAM_CHAT_ID"

# 환경 변수로 설정
export SHOUTRRR_URL="$TELEGRAM_URL"
```

### Email 알림 설정

```bash
# SMTP 이메일 설정
EMAIL_URL="smtp://username:password@smtp.gmail.com:587/?from=from@example.com&to=to@example.com"

# Gotify 자체 호스팅 알림
GOTIFY_URL="gotify://192.168.1.100:8080/AwQqpAae.rrl5Ob/?title=WatchYourLAN Alert"
```

### 알림 테스트 스크립트

```bash
#!/bin/bash
# 파일명: test_notifications.sh

# 알림 설정 테스트 함수
test_notification() {
    local service=$1
    local url=$2
    
    echo "🔔 $service 알림 테스트 중..."
    
    # 임시 컨테이너로 알림 테스트
    docker run --rm \
      -e "SHOUTRRR_URL=$url" \
      aceberg/watchyourlan echo "테스트 알림"
    
    if [ $? -eq 0 ]; then
        echo "✅ $service 알림 설정 성공"
    else
        echo "❌ $service 알림 설정 실패"
    fi
}

# 각 서비스별 테스트
test_notification "Discord" "$DISCORD_WEBHOOK"
test_notification "Telegram" "$TELEGRAM_URL"
test_notification "Email" "$EMAIL_URL"
```

## 고급 설정

### 다중 인터페이스 모니터링

```bash
# 여러 네트워크 인터페이스 동시 모니터링
IFACES="en0 en1 utun0"

docker run -d --name watchyourlan \
  -e "IFACES=$IFACES" \
  -e "TZ=Asia/Seoul" \
  --network="host" \
  -v $(pwd)/watchyourlan:/data/WatchYourLAN \
  aceberg/watchyourlan
```

### VLAN 환경 설정

```bash
# VLAN 인터페이스 스캔 설정
# ARP_ARGS를 사용하여 특정 VLAN 대역 스캔
docker run -d --name watchyourlan \
  -e "IFACES=en0" \
  -e "ARP_ARGS=-r 3 -t 500" \
  -e "ARP_STRS=192.168.1.0/24,192.168.10.0/24" \
  --network="host" \
  -v $(pwd)/watchyourlan:/data/WatchYourLAN \
  aceberg/watchyourlan
```

### PostgreSQL 데이터베이스 연동

```bash
# PostgreSQL 컨테이너 실행
docker run -d --name postgres \
  -e POSTGRES_DB=watchyourlan \
  -e POSTGRES_USER=wyl \
  -e POSTGRES_PASSWORD=password123 \
  -p 5432:5432 \
  postgres:15

# WatchYourLAN PostgreSQL 설정
PG_CONNECT="postgres://wyl:password123@localhost:5432/watchyourlan?sslmode=disable"

docker run -d --name watchyourlan \
  -e "IFACES=en0" \
  -e "USE_DB=postgres" \
  -e "PG_CONNECT=$PG_CONNECT" \
  -e "HIST_IN_DB=true" \
  --network="host" \
  -v $(pwd)/watchyourlan:/data/WatchYourLAN \
  aceberg/watchyourlan
```

## InfluxDB2 및 Grafana 연동

### InfluxDB2 설정

```bash
# InfluxDB2 컨테이너 실행
docker run -d --name influxdb2 \
  -p 8086:8086 \
  -e DOCKER_INFLUXDB_INIT_MODE=setup \
  -e DOCKER_INFLUXDB_INIT_USERNAME=admin \
  -e DOCKER_INFLUXDB_INIT_PASSWORD=adminpassword \
  -e DOCKER_INFLUXDB_INIT_ORG=home \
  -e DOCKER_INFLUXDB_INIT_BUCKET=watchyourlan \
  -v influxdb-data:/var/lib/influxdb2 \
  influxdb:2.7

# InfluxDB2 토큰 생성 (웹 UI: http://localhost:8086)
# 또는 CLI로 토큰 생성
docker exec influxdb2 influx auth create \
  --org home \
  --all-access \
  --description "WatchYourLAN Token"
```

### WatchYourLAN InfluxDB2 연동

```bash
# InfluxDB2 연동 설정
INFLUX_TOKEN="your_influxdb_token_here"

docker run -d --name watchyourlan \
  -e "IFACES=en0" \
  -e "INFLUX_ENABLE=true" \
  -e "INFLUX_ADDR=http://localhost:8086/" \
  -e "INFLUX_BUCKET=watchyourlan" \
  -e "INFLUX_ORG=home" \
  -e "INFLUX_TOKEN=$INFLUX_TOKEN" \
  --network="host" \
  -v $(pwd)/watchyourlan:/data/WatchYourLAN \
  aceberg/watchyourlan
```

### Grafana 대시보드 설정

```bash
# Grafana 컨테이너 실행
docker run -d --name grafana \
  -p 3000:3000 \
  -e GF_SECURITY_ADMIN_PASSWORD=admin \
  -v grafana-data:/var/lib/grafana \
  grafana/grafana:latest

# Grafana 접속: http://localhost:3000 (admin/admin)
```

### Grafana 설정 스크립트

```bash
#!/bin/bash
# 파일명: setup_grafana.sh

# Grafana API를 통한 자동 설정
GRAFANA_URL="http://localhost:3000"
GRAFANA_USER="admin"
GRAFANA_PASS="admin"

# InfluxDB 데이터소스 추가
curl -X POST "$GRAFANA_URL/api/datasources" \
  -H "Content-Type: application/json" \
  -u "$GRAFANA_USER:$GRAFANA_PASS" \
  -d '{
    "name": "InfluxDB-WatchYourLAN",
    "type": "influxdb",
    "url": "http://localhost:8086",
    "access": "proxy",
    "database": "",
    "jsonData": {
      "version": "Flux",
      "organization": "home",
      "defaultBucket": "watchyourlan",
      "tlsSkipVerify": true
    },
    "secureJsonData": {
      "token": "'$INFLUX_TOKEN'"
    }
  }'

echo "✅ Grafana 데이터소스 설정 완료"
```

## 실전 사용 시나리오

### 홈 네트워크 모니터링

```bash
#!/bin/bash
# 파일명: home_network_monitor.sh

# 홈 네트워크 보안 모니터링 설정
echo "🏠 홈 네트워크 모니터링 설정"

# 신뢰할 수 있는 기기 목록 (MAC 주소)
TRUSTED_DEVICES=(
    "aa:bb:cc:dd:ee:ff"  # iPhone
    "11:22:33:44:55:66"  # MacBook
    "77:88:99:aa:bb:cc"  # iPad
)

# 알림 설정 (Telegram)
TELEGRAM_URL="telegram://your_bot_token@telegram?chats=your_chat_id"

# WatchYourLAN 실행 (엄격한 모니터링)
docker run -d --name home-monitor \
  -e "IFACES=en0" \
  -e "TIMEOUT=30" \
  -e "SHOUTRRR_URL=$TELEGRAM_URL" \
  -e "LOG_LEVEL=debug" \
  --network="host" \
  -v $(pwd)/home-monitor:/data/WatchYourLAN \
  aceberg/watchyourlan

echo "🔐 홈 네트워크 보안 모니터링 시작"
echo "📱 알 수 없는 기기 발견 시 Telegram으로 알림"
```

### 사무실 네트워크 관리

```bash
#!/bin/bash
# 파일명: office_network_setup.sh

# 사무실 다중 VLAN 모니터링
echo "🏢 사무실 네트워크 모니터링 설정"

# 다중 네트워크 대역 스캔
NETWORK_RANGES="192.168.1.0/24,192.168.10.0/24,192.168.20.0/24"

# Slack 알림 설정
SLACK_WEBHOOK="slack://token@workspace/channel"

# 전용 PostgreSQL 데이터베이스
PG_CONNECT="postgres://netadmin:securepass@db-server:5432/network_monitor"

docker run -d --name office-monitor \
  -e "IFACES=en0 en1" \
  -e "ARP_STRS=$NETWORK_RANGES" \
  -e "TIMEOUT=60" \
  -e "USE_DB=postgres" \
  -e "PG_CONNECT=$PG_CONNECT" \
  -e "HIST_IN_DB=true" \
  -e "SHOUTRRR_URL=$SLACK_WEBHOOK" \
  -e "INFLUX_ENABLE=true" \
  --network="host" \
  -v $(pwd)/office-monitor:/data/WatchYourLAN \
  aceberg/watchyourlan

echo "📊 모든 네트워크 활동이 데이터베이스에 저장됩니다"
```

## 문제 해결 가이드

### 일반적인 문제와 해결책

#### 1. 네트워크 인터페이스 감지 문제

```bash
# 현재 활성 인터페이스 확인
ifconfig | grep -E '^[a-z]' | grep -v lo

# 기본 게이트웨이 인터페이스 확인
route get default | grep interface

# Docker 네트워크 문제 시 host 모드 강제 사용
docker run --network="host" aceberg/watchyourlan
```

#### 2. 권한 관련 문제

```bash
# ARP 스캔 권한 확인
sudo arp-scan -l

# Docker 실행 시 권한 오류 해결
sudo docker run --privileged aceberg/watchyourlan

# macOS에서 Network Extension 권한 허용
# 시스템 환경설정 > 보안 및 개인정보 보호 > 개인정보 보호
```

#### 3. 포트 충돌 문제

```bash
# 8840 포트 사용 확인
lsof -i :8840

# 다른 포트로 실행
docker run -e "PORT=8841" -p 8841:8841 aceberg/watchyourlan
```

### 디버깅 및 로그 분석

```bash
#!/bin/bash
# 파일명: debug_watchyourlan.sh

echo "🔍 WatchYourLAN 디버깅 도구"

# 컨테이너 상태 확인
echo "📊 컨테이너 상태:"
docker ps -a | grep watchyourlan

# 자세한 로그 확인
echo "📝 상세 로그:"
docker logs --details --timestamps watchyourlan | tail -50

# 네트워크 연결 테스트
echo "🌐 네트워크 연결 테스트:"
curl -s http://localhost:8840/api/health || echo "웹 서비스 응답 없음"

# 메모리 및 CPU 사용량
echo "💻 리소스 사용량:"
docker stats watchyourlan --no-stream

# 설정 파일 확인
echo "⚙️ 설정 확인:"
docker exec watchyourlan cat /data/WatchYourLAN/config_v2.yaml

# 네트워크 스캔 테스트
echo "🔍 수동 ARP 스캔 테스트:"
if command -v arp-scan &> /dev/null; then
    sudo arp-scan -l | head -10
else
    echo "arp-scan이 설치되지 않음. brew install arp-scan으로 설치하세요."
fi
```

### 성능 최적화

```bash
#!/bin/bash
# 파일명: optimize_watchyourlan.sh

echo "⚡ WatchYourLAN 성능 최적화"

# 최적화된 설정
cat > docker-compose-optimized.yml << 'EOF'
version: '3.8'

services:
  watchyourlan:
    image: aceberg/watchyourlan
    container_name: watchyourlan-optimized
    network_mode: host
    environment:
      - IFACES=en0
      - TZ=Asia/Seoul
      - TIMEOUT=30          # 스캔 간격 단축
      - LOG_LEVEL=warn      # 로그 레벨 조정
      - TRIM_HIST=24        # 히스토리 보관 기간 단축
      - HIST_IN_DB=false    # 메모리 저장으로 성능 향상
      - ARP_ARGS=-r 1       # ARP 재시도 횟수 제한
    volumes:
      - ./data:/data/WatchYourLAN
    restart: unless-stopped
    deploy:
      resources:
        limits:
          memory: 256M
          cpus: '0.5'
        reservations:
          memory: 128M
          cpus: '0.2'
EOF

echo "🚀 최적화된 설정으로 실행:"
docker-compose -f docker-compose-optimized.yml up -d
```

## API 활용 및 자동화

### REST API 사용 예제

```bash
#!/bin/bash
# 파일명: api_examples.sh

API_BASE="http://localhost:8840/api"

echo "📡 WatchYourLAN API 사용 예제"

# 현재 온라인 호스트 조회
echo "🟢 온라인 호스트 목록:"
curl -s "$API_BASE/hosts" | jq '.[] | select(.state == "online") | {ip, mac, name}'

# 히스토리 데이터 조회
echo "📈 최근 히스토리:"
curl -s "$API_BASE/history" | jq '.[:5]'

# 설정 확인
echo "⚙️ 현재 설정:"
curl -s "$API_BASE/config" | jq '.'

# 통계 정보
echo "📊 통계 정보:"
curl -s "$API_BASE/stats" | jq '.'
```

### Python 자동화 스크립트

```python
#!/usr/bin/env python3
# 파일명: watchyourlan_automation.py

import requests
import json
import time
from datetime import datetime

class WatchYourLANClient:
    def __init__(self, base_url="http://localhost:8840"):
        self.base_url = base_url
        self.api_base = f"{base_url}/api"
    
    def get_online_hosts(self):
        """온라인 호스트 목록 조회"""
        response = requests.get(f"{self.api_base}/hosts")
        if response.status_code == 200:
            hosts = response.json()
            return [host for host in hosts if host.get('state') == 'online']
        return []
    
    def get_new_hosts(self, hours=24):
        """최근 발견된 새로운 호스트"""
        response = requests.get(f"{self.api_base}/history")
        if response.status_code == 200:
            history = response.json()
            # 최근 24시간 내 첫 등장 호스트 필터링
            new_hosts = []
            for entry in history:
                if entry.get('event') == 'first_seen':
                    new_hosts.append(entry)
            return new_hosts[:10]  # 최근 10개
        return []
    
    def generate_report(self):
        """네트워크 상태 리포트 생성"""
        online_hosts = self.get_online_hosts()
        new_hosts = self.get_new_hosts()
        
        report = {
            "timestamp": datetime.now().isoformat(),
            "online_count": len(online_hosts),
            "online_hosts": online_hosts,
            "new_hosts_count": len(new_hosts),
            "new_hosts": new_hosts
        }
        
        return report

def main():
    client = WatchYourLANClient()
    
    print("🔍 WatchYourLAN 네트워크 리포트")
    print("=" * 50)
    
    report = client.generate_report()
    
    print(f"📅 리포트 시간: {report['timestamp']}")
    print(f"🟢 온라인 호스트: {report['online_count']}개")
    print(f"🆕 새로운 호스트: {report['new_hosts_count']}개")
    
    if report['new_hosts']:
        print("\n🚨 새로 발견된 호스트:")
        for host in report['new_hosts']:
            print(f"  - IP: {host.get('ip', 'N/A')}")
            print(f"    MAC: {host.get('mac', 'N/A')}")
            print(f"    시간: {host.get('time', 'N/A')}")

if __name__ == "__main__":
    main()
```

## zshrc Aliases 설정

```bash
# ~/.zshrc에 추가할 WatchYourLAN 관련 aliases
cat >> ~/.zshrc << 'EOF'

# WatchYourLAN 관련 aliases
alias wyl-start="docker start watchyourlan"
alias wyl-stop="docker stop watchyourlan"
alias wyl-logs="docker logs -f watchyourlan"
alias wyl-restart="docker restart watchyourlan"
alias wyl-update="docker pull aceberg/watchyourlan && docker restart watchyourlan"
alias wyl-web="open http://localhost:8840"
alias wyl-stats="curl -s http://localhost:8840/api/stats | jq"
alias wyl-hosts="curl -s http://localhost:8840/api/hosts | jq '.[] | select(.state == \"online\")'"

# 네트워크 진단 aliases
alias netinfo="ifconfig | grep -E '^[a-z]|inet '"
alias netgw="route get default | grep gateway"
alias netscan="sudo arp-scan -l | head -20"

# WatchYourLAN 설치 및 관리 함수
wyl-install() {
    echo "🔍 WatchYourLAN 설치 시작..."
    INTERFACE=$(route get default | grep interface | awk '{print $2}' 2>/dev/null || echo "en0")
    docker run -d --name watchyourlan \
        -e "IFACES=$INTERFACE" \
        -e "TZ=Asia/Seoul" \
        --network="host" \
        -v $(pwd)/watchyourlan:/data/WatchYourLAN \
        aceberg/watchyourlan
    echo "✅ 설치 완료: http://localhost:8840"
}

wyl-backup() {
    echo "💾 WatchYourLAN 데이터 백업..."
    docker exec watchyourlan tar czf /tmp/backup.tar.gz /data/WatchYourLAN
    docker cp watchyourlan:/tmp/backup.tar.gz ./watchyourlan-backup-$(date +%Y%m%d).tar.gz
    echo "✅ 백업 완료"
}

EOF

# zshrc 재로드
source ~/.zshrc
```

## 성능 벤치마킹

```bash
#!/bin/bash
# 파일명: benchmark_watchyourlan.sh

echo "📊 WatchYourLAN 성능 벤치마킹"

# 테스트 시작 시간
START_TIME=$(date +%s)

echo "🔍 1. 스캔 속도 테스트..."
docker logs watchyourlan 2>&1 | grep -E "Scan completed|Found [0-9]+ hosts" | tail -5

echo "💾 2. 메모리 사용량 테스트..."
docker stats watchyourlan --no-stream | awk 'NR==2 {print "메모리 사용량:", $4}'

echo "🌐 3. API 응답 시간 테스트..."
for endpoint in "hosts" "history" "config" "stats"; do
    response_time=$(curl -o /dev/null -s -w "%{time_total}" http://localhost:8840/api/$endpoint)
    echo "  /$endpoint: ${response_time}초"
done

echo "📈 4. 대용량 네트워크 시뮬레이션..."
# 여러 서브넷 동시 스캔 테스트
docker exec watchyourlan sh -c 'env | grep ARP_STRS'

END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo "✅ 벤치마킹 완료 (소요 시간: ${DURATION}초)"
```

## 결론

WatchYourLAN은 네트워크 보안과 모니터링을 위한 강력하면서도 사용하기 쉬운 도구입니다. 이 튜토리얼을 통해 다음과 같은 내용을 학습했습니다:

### 🎯 주요 성과

**✅ 완전한 설치 가이드**
- Docker와 소스코드 빌드 두 가지 방법 마스터
- macOS 환경 최적화 설정
- 자동화 스크립트를 통한 원클릭 설치

**✅ 실전 모니터링 시스템 구축**
- 홈/사무실 네트워크 보안 강화
- 실시간 알림 시스템 구축
- 다중 플랫폼 알림 연동

**✅ 고급 데이터 분석 환경**
- InfluxDB2와 Grafana 연동
- 장기간 네트워크 트렌드 분석
- API 기반 자동화 시스템

### 🚀 다음 단계

1. **모니터링 확장**: 더 많은 네트워크 세그먼트로 확장
2. **보안 강화**: 침입 탐지 시스템과 연동
3. **자동화**: 의심스러운 활동 자동 차단
4. **분석 고도화**: 머신러닝 기반 이상 탐지

### 📚 추가 학습 리소스

**공식 문서**: [WatchYourLAN GitHub](https://github.com/aceberg/WatchYourLAN)
**Docker Hub**: [aceberg/watchyourlan](https://hub.docker.com/r/aceberg/watchyourlan)
**커뮤니티**: [GitHub Discussions](https://github.com/aceberg/WatchYourLAN/discussions)

WatchYourLAN은 단순한 네트워크 스캐너를 넘어서 종합적인 네트워크 보안 솔루션의 핵심 구성 요소가 될 수 있습니다. 지속적인 모니터링과 적절한 알림 설정을 통해 네트워크 보안을 크게 향상시킬 수 있습니다.

**💡 Pro Tip**: 정기적으로 스캔 결과를 검토하고, 새로운 기기가 발견될 때마다 해당 기기의 정체를 확인하는 습관을 들이세요. 이것이 효과적인 네트워크 보안의 첫걸음입니다.