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
