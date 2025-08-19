#!/bin/bash

# DeepCode 설치 및 설정 테스트 스크립트
# macOS 환경에서 DeepCode 설치부터 실행까지 자동화

set -e

echo "🧬 DeepCode 설치 및 설정 테스트 시작"
echo "========================================"

# 현재 디렉토리 저장
ORIGINAL_DIR=$(pwd)
TEST_DIR="deepcode-test"

# 테스트 디렉토리 생성
if [ ! -d "$TEST_DIR" ]; then
    mkdir -p "$TEST_DIR"
fi

cd "$TEST_DIR"

# 1. 시스템 요구사항 확인
echo ""
echo "📋 시스템 요구사항 확인 중..."
echo "Python 버전: $(python3 --version)"
echo "Node.js 버전: $(node --version)"
echo "npm 버전: $(npm --version)"

# UV 설치 확인
if command -v uv &> /dev/null; then
    echo "UV 버전: $(uv --version)"
else
    echo "⚠️  UV가 설치되지 않음. 설치 중..."
    curl -LsSf https://astral.sh/uv/install.sh | sh
    source ~/.cargo/env
fi

# 2. DeepCode 리포지토리 클론 (이미 존재하면 스킵)
if [ ! -d "DeepCode" ]; then
    echo ""
    echo "📦 DeepCode 리포지토리 클론 중..."
    git clone https://github.com/HKUDS/DeepCode.git
fi

cd DeepCode

# 3. 가상환경 생성 및 의존성 설치
echo ""
echo "🔧 가상환경 설정 및 의존성 설치 중..."
if [ ! -d ".venv" ]; then
    uv venv
fi

source .venv/bin/activate
uv pip install -r requirements.txt

# 4. LibreOffice 설치 (선택사항)
echo ""
echo "📄 LibreOffice 설치 확인 중..."
if command -v libreoffice &> /dev/null; then
    echo "✅ LibreOffice가 이미 설치됨"
else
    echo "⚠️  LibreOffice가 설치되지 않음"
    read -p "LibreOffice를 설치하시겠습니까? (y/n): " install_libreoffice
    if [ "$install_libreoffice" = "y" ] || [ "$install_libreoffice" = "Y" ]; then
        echo "LibreOffice 설치 중..."
        brew install --cask libreoffice
    fi
fi

# 5. MCP 서버 설치
echo ""
echo "🔌 MCP 서버 설치 중..."
npm install -g @modelcontextprotocol/server-brave-search
npm install -g @modelcontextprotocol/server-filesystem

# 6. 설정 파일 예시 생성
echo ""
echo "⚙️  설정 파일 예시 생성 중..."

# API 키 설정 예시 파일 생성
cat > mcp_agent.secrets.example.yaml << 'EOF'
openai:
  api_key: "your_openai_api_key_here"
  base_url: "https://api.openai.com/v1"

anthropic:
  api_key: "your_anthropic_api_key_here"
EOF

# Brave API 키 설정 업데이트 예시
cp mcp_agent.config.yaml mcp_agent.config.example.yaml

# 7. 기본 실행 테스트 (API 키 없이)
echo ""
echo "🧪 기본 실행 테스트 중..."
echo "주의: API 키가 설정되지 않아 일부 기능은 작동하지 않을 수 있습니다."

# deepcode.py 도움말 출력
timeout 10s python deepcode.py --help || echo "⚠️  API 키 설정 후 정상 작동됩니다."

# 8. 설치 완료 메시지
echo ""
echo "✅ DeepCode 설치 완료!"
echo ""
echo "📝 다음 단계:"
echo "1. API 키 설정:"
echo "   - mcp_agent.secrets.yaml 파일에 OpenAI/Anthropic API 키 입력"
echo "   - mcp_agent.config.yaml 파일에 BRAVE_API_KEY 입력"
echo ""
echo "2. 실행 명령어:"
echo "   - Web Interface: python deepcode.py"
echo "   - CLI Interface: python cli/main_cli.py"
echo ""
echo "3. 접속 URL: http://localhost:8501"
echo ""
echo "🔧 설정 예시 파일:"
echo "   - mcp_agent.secrets.example.yaml"
echo "   - mcp_agent.config.example.yaml"

cd "$ORIGINAL_DIR"
echo ""
echo "🎉 DeepCode 설정 완료! 즐거운 코딩하세요!"
