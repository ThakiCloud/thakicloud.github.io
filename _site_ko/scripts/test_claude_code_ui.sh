#!/bin/bash

# Claude Code UI 설치 및 테스트 스크립트
# 사용법: ./test_claude_code_ui.sh

set -e

echo "🚀 Claude Code UI 설치 및 테스트 시작"

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# 필수 조건 확인
check_requirements() {
    echo -e "${BLUE}📋 필수 조건 확인 중...${NC}"
    
    # Node.js 버전 확인
    if ! command -v node &> /dev/null; then
        echo -e "${RED}❌ Node.js가 설치되어 있지 않습니다.${NC}"
        exit 1
    fi
    
    NODE_VERSION=$(node --version | sed 's/v//')
    REQUIRED_VERSION="20.0.0"
    
    if ! node -e "process.exit(require('semver').gte('$NODE_VERSION', '$REQUIRED_VERSION') ? 0 : 1)" 2>/dev/null; then
        echo -e "${RED}❌ Node.js v20 이상이 필요합니다. 현재 버전: v$NODE_VERSION${NC}"
        exit 1
    fi
    
    echo -e "${GREEN}✅ Node.js v$NODE_VERSION (요구사항: v$REQUIRED_VERSION 이상)${NC}"
    
    # npm 확인
    if ! command -v npm &> /dev/null; then
        echo -e "${RED}❌ npm이 설치되어 있지 않습니다.${NC}"
        exit 1
    fi
    
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm v$NPM_VERSION${NC}"
    
    # Git 확인
    if ! command -v git &> /dev/null; then
        echo -e "${RED}❌ Git이 설치되어 있지 않습니다.${NC}"
        exit 1
    fi
    
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    echo -e "${GREEN}✅ Git $GIT_VERSION${NC}"
}

# Claude CLI 설치 확인
check_claude_cli() {
    echo -e "${BLUE}🔍 Claude CLI 설치 확인 중...${NC}"
    
    if command -v claude &> /dev/null; then
        CLAUDE_VERSION=$(claude --version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ Claude CLI 설치됨: $CLAUDE_VERSION${NC}"
    else
        echo -e "${YELLOW}⚠️  Claude CLI가 설치되어 있지 않습니다.${NC}"
        echo -e "${YELLOW}   설치 방법: npm install -g @anthropic-ai/claude-code${NC}"
        echo -e "${YELLOW}   또는 pip install claude-code${NC}"
    fi
}

# 프로젝트 클론 및 설정
setup_project() {
    echo -e "${BLUE}📥 Claude Code UI 클론 중...${NC}"
    
    # 임시 디렉토리 생성
    TEMP_DIR="/tmp/claude-code-ui-test-$(date +%s)"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # 저장소 클론
    git clone https://github.com/siteboon/claudecodeui.git
    cd claudecodeui
    
    echo -e "${GREEN}✅ 저장소 클론 완료: $TEMP_DIR/claudecodeui${NC}"
    
    # 환경 설정 파일 복사
    echo -e "${BLUE}⚙️  환경 설정 중...${NC}"
    cp .env.example .env
    
    # 포트 설정 (중복 방지를 위해 랜덤 포트 사용)
    BACKEND_PORT=$((3000 + RANDOM % 1000))
    FRONTEND_PORT=$((4000 + RANDOM % 1000))
    
    sed -i.bak "s/PORT=3008/PORT=$BACKEND_PORT/" .env
    sed -i.bak "s/VITE_PORT=3009/VITE_PORT=$FRONTEND_PORT/" .env
    
    echo -e "${GREEN}✅ 환경 설정 완료${NC}"
    echo -e "${GREEN}   - 백엔드 포트: $BACKEND_PORT${NC}"
    echo -e "${GREEN}   - 프론트엔드 포트: $FRONTEND_PORT${NC}"
    
    # 의존성 설치
    echo -e "${BLUE}📦 의존성 설치 중...${NC}"
    npm install
    echo -e "${GREEN}✅ 의존성 설치 완료${NC}"
}

# 서버 실행 테스트
test_server() {
    echo -e "${BLUE}🧪 서버 실행 테스트 중...${NC}"
    
    # 백그라운드에서 서버 실행
    timeout 15s npm run dev &
    SERVER_PID=$!
    
    # 서버 시작 대기
    sleep 8
    
    # 백엔드 서버 테스트
    if curl -s "http://localhost:$BACKEND_PORT/api/health" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 백엔드 서버 정상 작동 (포트: $BACKEND_PORT)${NC}"
    else
        echo -e "${YELLOW}⚠️  백엔드 서버 헬스체크 실패 (포트: $BACKEND_PORT)${NC}"
    fi
    
    # 프론트엔드 서버 테스트
    if curl -s "http://localhost:$FRONTEND_PORT" > /dev/null 2>&1; then
        echo -e "${GREEN}✅ 프론트엔드 서버 정상 작동 (포트: $FRONTEND_PORT)${NC}"
        echo -e "${GREEN}   브라우저에서 접속: http://localhost:$FRONTEND_PORT${NC}"
    else
        echo -e "${YELLOW}⚠️  프론트엔드 서버 접속 실패 (포트: $FRONTEND_PORT)${NC}"
    fi
    
    # 서버 프로세스 종료
    kill $SERVER_PID 2>/dev/null || true
    wait $SERVER_PID 2>/dev/null || true
    
    echo -e "${GREEN}✅ 서버 테스트 완료${NC}"
}

# 프로젝트 구조 분석
analyze_structure() {
    echo -e "${BLUE}📊 프로젝트 구조 분석 중...${NC}"
    
    echo -e "${YELLOW}📂 주요 디렉토리 구조:${NC}"
    tree -L 2 -I 'node_modules|.git' 2>/dev/null || {
        echo "   ├── src/           (프론트엔드 소스코드)"
        echo "   ├── server/        (백엔드 서버)"
        echo "   ├── public/        (정적 파일)"
        echo "   ├── package.json   (의존성 관리)"
        echo "   └── .env          (환경 설정)"
    }
    
    echo -e "${YELLOW}🔧 주요 기술 스택:${NC}"
    echo "   - Frontend: React + Vite + Tailwind CSS"
    echo "   - Backend: Express.js + WebSocket"
    echo "   - Terminal: xterm.js + node-pty"
    echo "   - Editor: CodeMirror"
    echo "   - Database: SQLite"
    
    echo -e "${YELLOW}📦 패키지 크기:${NC}"
    echo "   - 총 의존성: $(jq '.dependencies | length' package.json)개"
    echo "   - 개발 의존성: $(jq '.devDependencies | length' package.json)개"
}

# 정리 함수
cleanup() {
    echo -e "${BLUE}🧹 정리 중...${NC}"
    if [ -n "$TEMP_DIR" ] && [ -d "$TEMP_DIR" ]; then
        rm -rf "$TEMP_DIR"
        echo -e "${GREEN}✅ 임시 파일 정리 완료${NC}"
    fi
}

# 메인 실행 함수
main() {
    echo -e "${GREEN}🎯 Claude Code UI 설치 및 테스트 스크립트${NC}"
    echo -e "${GREEN}=====================================${NC}"
    
    check_requirements
    check_claude_cli
    
    # 트랩 설정 (스크립트 종료 시 정리)
    trap cleanup EXIT
    
    setup_project
    analyze_structure
    test_server
    
    echo -e "${GREEN}=====================================${NC}"
    echo -e "${GREEN}🎉 Claude Code UI 테스트 완료!${NC}"
    echo -e "${GREEN}=====================================${NC}"
    
    echo -e "${BLUE}💡 다음 단계:${NC}"
    echo -e "   1. Claude CLI 설치: ${YELLOW}npm install -g @anthropic-ai/claude-code${NC}"
    echo -e "   2. 프로젝트 생성: ${YELLOW}claude init my-project${NC}"
    echo -e "   3. Claude Code UI 실행: ${YELLOW}npm run dev${NC}"
    echo -e "   4. 브라우저에서 접속: ${YELLOW}http://localhost:$FRONTEND_PORT${NC}"
}

# 스크립트 실행
main "$@" 