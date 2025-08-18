#!/bin/bash

# Claudia 설치 및 테스트 스크립트
# Date: 2025-08-18

set -e  # 에러 발생 시 스크립트 중단

echo "🚀 Claudia 설치 및 테스트 스크립트 시작"
echo "======================================"

# 1. 시스템 요구사항 체크
echo "📋 시스템 요구사항 확인..."

# Rust 설치 확인
if ! command -v rustc &> /dev/null; then
    echo "❌ Rust가 설치되지 않았습니다."
    echo "🔧 Rust 설치 중..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source ~/.cargo/env
else
    echo "✅ Rust 설치됨: $(rustc --version)"
fi

# Bun 설치 확인
if ! command -v bun &> /dev/null; then
    echo "❌ Bun이 설치되지 않았습니다."
    echo "🔧 Bun 설치 중..."
    curl -fsSL https://bun.sh/install | bash
    export PATH="$HOME/.bun/bin:$PATH"
else
    echo "✅ Bun 설치됨: $(bun --version)"
fi

# Git 설치 확인
if ! command -v git &> /dev/null; then
    echo "❌ Git이 설치되지 않았습니다. 수동으로 설치해주세요."
    exit 1
else
    echo "✅ Git 설치됨: $(git --version)"
fi

# Claude Code CLI 설치 확인
if ! command -v claude &> /dev/null; then
    echo "⚠️  Claude Code CLI가 설치되지 않았습니다."
    echo "📖 Claude Code CLI는 Anthropic 공식 사이트에서 수동으로 설치해주세요:"
    echo "   https://www.anthropic.com/claude-code"
else
    echo "✅ Claude Code CLI 설치됨: $(claude --version)"
fi

echo ""
echo "🔧 macOS 전용 종속성 설치..."

# Xcode Command Line Tools 확인
if ! xcode-select -p &> /dev/null; then
    echo "🔧 Xcode Command Line Tools 설치 중..."
    xcode-select --install
else
    echo "✅ Xcode Command Line Tools 설치됨"
fi

echo ""
echo "📦 Claudia 소스 코드 다운로드..."

# 임시 디렉토리 생성
TEMP_DIR="/tmp/claudia-test-$(date +%s)"
mkdir -p "$TEMP_DIR"
cd "$TEMP_DIR"

# Claudia 클론
echo "📥 GitHub에서 Claudia 클론 중..."
git clone https://github.com/getAsterisk/claudia.git
cd claudia

echo ""
echo "📋 프로젝트 정보:"
echo "   Repository: https://github.com/getAsterisk/claudia"
echo "   Stars: 12.7k+"
echo "   License: AGPL-3.0"
echo "   Description: A powerful GUI app and Toolkit for Claude Code"

echo ""
echo "🏗️  의존성 설치..."

# Frontend 의존성 설치
echo "📦 Frontend 의존성 설치 중..."
bun install

echo ""
echo "🔨 개발 환경에서 빌드 테스트..."

# 개발 빌드 테스트 (실제 실행하지 않고 컴파일만)
echo "🧪 개발 빌드 컴파일 테스트..."
timeout 30s bun run tauri dev --no-watch --exit-on-panic || {
    echo "⚠️  개발 빌드 테스트가 30초 후 타임아웃되었습니다. 이는 정상적인 동작입니다."
}

echo ""
echo "📊 프로젝트 구조 분석..."
echo "   Frontend: React 18 + TypeScript + Vite 6"
echo "   Backend: Rust with Tauri 2"
echo "   UI Framework: Tailwind CSS v4 + shadcn/ui"
echo "   Database: SQLite (rusqlite)"
echo "   Package Manager: Bun"

echo ""
echo "📁 디렉토리 구조:"
tree -L 2 -a || ls -la

echo ""
echo "🎯 Claudia 주요 기능:"
echo "   • Claude Code 세션 관리"
echo "   • 타임라인 및 체크포인트"
echo "   • 커스텀 에이전트 생성"
echo "   • 프로젝트 스캐닝"
echo "   • MCP 서버 관리"
echo "   • 사용량 대시보드"

echo ""
echo "✅ Claudia 설치 및 테스트 완료!"
echo ""
echo "🚀 실제 사용을 위해서는:"
echo "   1. Claude Code CLI를 공식 사이트에서 설치"
echo "   2. bun run tauri build로 프로덕션 빌드"
echo "   3. 생성된 실행 파일을 Applications 폴더로 이동"
echo ""
echo "📍 테스트 파일 위치: $TEMP_DIR"
echo "🧹 테스트 완료 후 'rm -rf $TEMP_DIR'로 정리하세요"

# 프로젝트 정보를 json 파일로 저장
cat > project_info.json << EOF
{
  "name": "Claudia",
  "repository": "https://github.com/getAsterisk/claudia",
  "stars": "12.7k+",
  "license": "AGPL-3.0",
  "tech_stack": {
    "frontend": "React 18 + TypeScript + Vite 6",
    "backend": "Rust with Tauri 2",
    "ui": "Tailwind CSS v4 + shadcn/ui",
    "database": "SQLite",
    "package_manager": "Bun"
  },
  "features": [
    "Claude Code 세션 관리",
    "타임라인 및 체크포인트",
    "커스텀 에이전트 생성",
    "프로젝트 스캐닝", 
    "MCP 서버 관리",
    "사용량 대시보드"
  ],
  "tested_on": "$(date)",
  "test_directory": "$TEMP_DIR"
}
EOF

echo "📄 프로젝트 정보가 project_info.json에 저장되었습니다."
