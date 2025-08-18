#!/bin/bash

# Bytebot 설치 및 테스트 스크립트
# macOS 환경에서 Docker를 통한 Bytebot 자동 설치

set -e

echo "🤖 Bytebot AI Desktop Agent 설치 스크립트"
echo "========================================"

# 기본 변수 설정
BYTEBOT_DIR="$HOME/bytebot"
BACKUP_DIR="$HOME/bytebot-backup-$(date +%Y%m%d-%H%M%S)"

# Docker 설치 확인
echo "📋 Docker 설치 확인 중..."
if ! command -v docker &> /dev/null; then
    echo "❌ Docker가 설치되어 있지 않습니다."
    echo "💡 Docker Desktop을 설치해주세요: https://www.docker.com/products/docker-desktop/"
    exit 1
fi

echo "✅ Docker 버전: $(docker --version)"

# Docker 실행 상태 확인
if ! docker info &> /dev/null; then
    echo "❌ Docker가 실행되고 있지 않습니다."
    echo "💡 Docker Desktop을 시작해주세요."
    exit 1
fi

echo "✅ Docker가 정상적으로 실행 중입니다."

# 기존 설치 백업
if [ -d "$BYTEBOT_DIR" ]; then
    echo "📦 기존 Bytebot 설치 발견 - 백업 중..."
    mv "$BYTEBOT_DIR" "$BACKUP_DIR"
    echo "✅ 백업 완료: $BACKUP_DIR"
fi

# Bytebot 리포지토리 클론
echo "📥 Bytebot 리포지토리 클론 중..."
git clone https://github.com/bytebot-ai/bytebot.git "$BYTEBOT_DIR"
cd "$BYTEBOT_DIR"

# AI API 키 설정
echo ""
echo "🔑 AI API 키 설정"
echo "=================="
echo "지원되는 AI 프로바이더:"
echo "1. Anthropic Claude (ANTHROPIC_API_KEY)"
echo "2. OpenAI GPT (OPENAI_API_KEY)"
echo "3. Google Gemini (GEMINI_API_KEY)"
echo ""

read -p "AI 프로바이더를 선택하세요 (1-3): " choice
case $choice in
    1)
        read -p "Anthropic API 키를 입력하세요: " api_key
        echo "ANTHROPIC_API_KEY=$api_key" > docker/.env
        ;;
    2)
        read -p "OpenAI API 키를 입력하세요: " api_key
        echo "OPENAI_API_KEY=$api_key" > docker/.env
        ;;
    3)
        read -p "Google Gemini API 키를 입력하세요: " api_key
        echo "GEMINI_API_KEY=$api_key" > docker/.env
        ;;
    *)
        echo "❌ 잘못된 선택입니다. 테스트용 더미 키를 사용합니다."
        echo "ANTHROPIC_API_KEY=sk-ant-test-key-demo" > docker/.env
        ;;
esac

echo "✅ API 키 설정 완료"

# Docker 이미지 다운로드
echo ""
echo "📥 Docker 이미지 다운로드 중..."
echo "⚠️  첫 실행 시 약 1.5GB 이미지를 다운로드합니다. 시간이 소요될 수 있습니다."
docker-compose -f docker/docker-compose.yml pull

# Bytebot 실행
echo ""
echo "🚀 Bytebot 시작 중..."
docker-compose -f docker/docker-compose.yml up -d

# 서비스 상태 확인
echo ""
echo "⏱️  서비스 시작 대기 중 (30초)..."
sleep 30

echo ""
echo "📊 서비스 상태 확인:"
docker-compose -f docker/docker-compose.yml ps

# 접속 정보 표시
echo ""
echo "🎉 Bytebot 설치 완료!"
echo "===================="
echo "🌐 UI 접속: http://localhost:9992"
echo "🖥️  Desktop 접속: http://localhost:9990"
echo "🔧 API 엔드포인트: http://localhost:9991"
echo ""
echo "📝 사용법:"
echo "1. 브라우저에서 http://localhost:9992 접속"
echo "2. '+ New Task' 버튼으로 작업 생성"
echo "3. 자연어로 원하는 작업 입력"
echo "4. Desktop 탭에서 실시간 작업 확인"
echo ""
echo "⚠️  주의사항:"
echo "- 유효한 AI API 키가 필요합니다"
echo "- 처음 실행 시 컨테이너 초기화에 시간이 소요됩니다"
echo "- 메모리 사용량이 높을 수 있습니다 (권장: 8GB+ RAM)"

# 종료 스크립트 생성
cat > "$BYTEBOT_DIR/stop-bytebot.sh" << 'EOF'
#!/bin/bash
echo "🛑 Bytebot 중지 중..."
cd "$(dirname "$0")"
docker-compose -f docker/docker-compose.yml down
echo "✅ Bytebot이 중지되었습니다."
EOF

chmod +x "$BYTEBOT_DIR/stop-bytebot.sh"

echo ""
echo "🛑 중지 방법: $BYTEBOT_DIR/stop-bytebot.sh 실행"
echo ""
echo "📚 더 많은 정보: https://github.com/bytebot-ai/bytebot"
