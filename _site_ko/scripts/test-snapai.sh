#!/bin/bash

# SnapAI 테스트 스크립트
# 실행: chmod +x scripts/test-snapai.sh && ./scripts/test-snapai.sh

set -e  # 에러 발생시 스크립트 종료

echo "🤖 SnapAI CLI 도구 테스트 시작"
echo "=================================="

# 환경 정보 출력
echo "📋 시스템 환경:"
echo "- OS: $(uname -s) $(uname -r)"
echo "- Node.js: $(node --version)"
echo "- npm: $(npm --version)"
echo ""

# SnapAI 설치 확인
echo "🔍 SnapAI 설치 상태 확인..."
if command -v snapai &> /dev/null; then
    echo "✅ SnapAI 설치됨: $(snapai --version)"
else
    echo "❌ SnapAI가 설치되지 않음. 설치를 진행합니다..."
    npm install -g snapai
    echo "✅ SnapAI 설치 완료"
fi
echo ""

# API 키 설정 확인
echo "🔑 API 키 설정 확인..."
if [ -z "$OPENAI_API_KEY" ]; then
    echo "⚠️  OPENAI_API_KEY 환경변수가 설정되지 않았습니다."
    echo "   다음 명령으로 API 키를 설정하세요:"
    echo "   export OPENAI_API_KEY='your-api-key-here'"
    echo "   snapai config --api-key \$OPENAI_API_KEY"
    echo ""
    echo "🔄 기존 설정 확인 중..."
    snapai config --show || echo "   설정 파일이 없습니다."
else
    echo "✅ OPENAI_API_KEY 환경변수 설정됨"
    snapai config --api-key "$OPENAI_API_KEY"
    echo "✅ API 키 설정 완료"
fi
echo ""

# 도움말 확인
echo "📖 SnapAI 도움말:"
snapai --help
echo ""

# 테스트용 디렉토리 생성
TEST_DIR="./test-snapai-icons"
echo "📁 테스트 디렉토리 생성: $TEST_DIR"
mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

echo ""
echo "🎨 아이콘 생성 테스트 준비 완료"
echo "=================================="
echo ""
echo "💡 다음 명령어들을 실행해 볼 수 있습니다:"
echo ""
echo "1. 기본 아이콘 생성:"
echo "   snapai icon --prompt 'modern fitness app icon'"
echo ""
echo "2. GPT-Image-1 고품질 아이콘:"
echo "   snapai icon --prompt 'business app icon' --model gpt-image-1 --quality high"
echo ""
echo "3. 투명 배경 아이콘:"
echo "   snapai icon --prompt 'weather app icon' --model gpt-image-1 --background transparent"
echo ""
echo "4. 여러 변형 생성:"
echo "   snapai icon --prompt 'social media app' --num-images 3 --model gpt-image-1"
echo ""
echo "5. DALL-E 3 HD 품질:"
echo "   snapai icon --prompt 'creative app icon' --model dall-e-3 --quality hd"
echo ""
echo "6. DALL-E 2 빠른 프로토타입:"
echo "   snapai icon --prompt 'game app icon' --model dall-e-2 --num-images 5"
echo ""

# API 키가 설정된 경우 실제 테스트 실행
if [ ! -z "$OPENAI_API_KEY" ]; then
    echo "🚀 API 키가 설정되어 있어 실제 테스트를 진행합니다..."
    echo ""
    
    echo "📱 테스트 1: 기본 앱 아이콘 생성..."
    snapai icon --prompt "modern mobile app icon with clean design" --model dall-e-2
    
    echo ""
    echo "📊 생성된 파일 확인:"
    ls -la *.png *.jpg *.webp 2>/dev/null || echo "   생성된 이미지 파일이 없습니다."
    
    echo ""
    echo "✅ 테스트 완료! 생성된 아이콘을 확인해보세요."
else
    echo "⏭️  API 키 설정 후 실제 아이콘 생성 테스트를 진행할 수 있습니다."
fi

echo ""
echo "🔗 참고 링크:"
echo "- SnapAI GitHub: https://github.com/betomoedano/snapai"
echo "- OpenAI API Keys: https://platform.openai.com/api-keys"
echo ""
echo "📝 테스트 완료 시간: $(date)"
