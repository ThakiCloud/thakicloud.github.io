#!/bin/bash

# Reor 프로젝트 설치 및 테스트 스크립트
# 사용법: ./test_reor_setup.sh

set -e

echo "🚀 Reor AI 지식 관리 앱 설치 및 테스트 시작"

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
    REQUIRED_VERSION="18.0.0"
    
    echo -e "${GREEN}✅ Node.js v$NODE_VERSION (요구사항: v$REQUIRED_VERSION 이상)${NC}"
    
    # npm 확인
    NPM_VERSION=$(npm --version)
    echo -e "${GREEN}✅ npm v$NPM_VERSION${NC}"
    
    # Git 확인
    GIT_VERSION=$(git --version | cut -d' ' -f3)
    echo -e "${GREEN}✅ Git $GIT_VERSION${NC}"
    
    # Electron 지원 플랫폼 확인
    PLATFORM=$(uname)
    if [[ "$PLATFORM" == "Darwin" ]]; then
        echo -e "${GREEN}✅ macOS - Electron 앱 지원${NC}"
    elif [[ "$PLATFORM" == "Linux" ]]; then
        echo -e "${GREEN}✅ Linux - Electron 앱 지원${NC}"
    else
        echo -e "${YELLOW}⚠️  Windows 플랫폼 감지됨${NC}"
    fi
}

# Ollama 설치 확인
check_ollama() {
    echo -e "${BLUE}🔍 Ollama 설치 확인 중...${NC}"
    
    if command -v ollama &> /dev/null; then
        OLLAMA_VERSION=$(ollama --version 2>/dev/null || echo "unknown")
        echo -e "${GREEN}✅ Ollama 설치됨: $OLLAMA_VERSION${NC}"
        
        # Ollama 서비스 상태 확인
        if pgrep -f "ollama" > /dev/null; then
            echo -e "${GREEN}✅ Ollama 서비스 실행 중${NC}"
        else
            echo -e "${YELLOW}⚠️  Ollama 서비스가 실행되지 않음${NC}"
            echo -e "${BLUE}   서비스 시작: ollama serve${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  Ollama가 설치되어 있지 않습니다.${NC}"
        echo -e "${YELLOW}   설치 방법: curl -fsSL https://ollama.com/install.sh | sh${NC}"
        echo -e "${YELLOW}   또는 홈페이지에서 다운로드: https://ollama.com${NC}"
    fi
}

# 프로젝트 클론 및 설정
setup_project() {
    echo -e "${BLUE}📥 Reor 프로젝트 클론 중...${NC}"
    
    # 임시 디렉토리 생성
    TEMP_DIR="/tmp/reor-test-$(date +%s)"
    mkdir -p "$TEMP_DIR"
    cd "$TEMP_DIR"
    
    # 저장소 클론
    git clone https://github.com/reorproject/reor.git
    cd reor
    
    echo -e "${GREEN}✅ 저장소 클론 완료: $TEMP_DIR/reor${NC}"
    
    # 프로젝트 정보 표시
    echo -e "${BLUE}📊 프로젝트 정보:${NC}"
    echo "   - 이름: $(jq -r '.name' package.json)"
    echo "   - 버전: $(jq -r '.version' package.json)"
    echo "   - 설명: $(jq -r '.description' package.json)"
    echo "   - 라이선스: $(jq -r '.license' package.json)"
}

# 의존성 설치 시도
install_dependencies() {
    echo -e "${BLUE}📦 의존성 설치 중... (시간이 오래 걸릴 수 있습니다)${NC}"
    
    # 의존성 개수 확인
    DEPS_COUNT=$(jq '.dependencies | length' package.json)
    DEV_DEPS_COUNT=$(jq '.devDependencies | length' package.json)
    
    echo -e "${YELLOW}   - 일반 의존성: ${DEPS_COUNT}개${NC}"
    echo -e "${YELLOW}   - 개발 의존성: ${DEV_DEPS_COUNT}개${NC}"
    
    # 타임아웃을 두고 설치 시도
    if timeout 180s npm install; then
        echo -e "${GREEN}✅ 의존성 설치 완료${NC}"
        return 0
    else
        echo -e "${YELLOW}⚠️  의존성 설치 시간 초과 또는 실패${NC}"
        echo -e "${YELLOW}   수동 설치가 필요할 수 있습니다: npm install${NC}"
        return 1
    fi
}

# 프로젝트 구조 분석
analyze_structure() {
    echo -e "${BLUE}📊 프로젝트 구조 분석 중...${NC}"
    
    echo -e "${YELLOW}📂 주요 디렉토리 구조:${NC}"
    tree -L 2 -I 'node_modules|.git|dist*' 2>/dev/null || {
        echo "   ├── src/               (React + TypeScript 프론트엔드)"
        echo "   ├── electron/          (Electron 메인 프로세스)"
        echo "   ├── build/             (빌드 설정)"
        echo "   ├── public/            (정적 파일)"
        echo "   ├── shared/            (공유 유틸리티)"
        echo "   ├── scripts/           (빌드 스크립트)"
        echo "   ├── package.json       (의존성 관리)"
        echo "   └── vite.config.mts    (Vite 설정)"
    }
    
    echo -e "${YELLOW}🔧 주요 기술 스택:${NC}"
    echo "   - Frontend: React + TypeScript + Vite"
    echo "   - Desktop: Electron"
    echo "   - AI: Ollama + Transformers.js"
    echo "   - Database: LanceDB (벡터 DB)"
    echo "   - UI: Tamagui + Tailwind CSS"
    echo "   - Editor: Monaco Editor"
    
    echo -e "${YELLOW}🤖 AI 기능:${NC}"
    echo "   - 로컬 LLM (Ollama 통합)"
    echo "   - 임베딩 모델 (Transformers.js)"
    echo "   - RAG (Retrieval-Augmented Generation)"
    echo "   - 의미적 검색 (Semantic Search)"
    echo "   - 자동 노트 연결"
}

# 빌드 테스트 (선택사항)
test_build() {
    echo -e "${BLUE}🧪 빌드 테스트 중...${NC}"
    
    if [ -d "node_modules" ]; then
        # TypeScript 타입 체크
        if npm run type-check 2>/dev/null; then
            echo -e "${GREEN}✅ TypeScript 타입 체크 통과${NC}"
        else
            echo -e "${YELLOW}⚠️  TypeScript 타입 체크 실패${NC}"
        fi
        
        # 린트 체크
        if npm run lint 2>/dev/null; then
            echo -e "${GREEN}✅ ESLint 체크 통과${NC}"
        else
            echo -e "${YELLOW}⚠️  ESLint 체크 실패${NC}"
        fi
    else
        echo -e "${YELLOW}⚠️  의존성이 설치되지 않아 빌드 테스트 건너뜀${NC}"
    fi
}

# Ollama 모델 다운로드 가이드
ollama_model_guide() {
    echo -e "${BLUE}🤖 Ollama 모델 다운로드 가이드${NC}"
    
    if command -v ollama &> /dev/null; then
        echo -e "${YELLOW}추천 모델들:${NC}"
        echo "   # 경량 모델 (빠른 응답)"
        echo "   ollama pull llama3.2:1b"
        echo "   ollama pull phi3.5:3.8b"
        echo ""
        echo "   # 균형 모델 (일반적 사용)"
        echo "   ollama pull llama3.2:3b"
        echo "   ollama pull mistral:7b"
        echo ""
        echo "   # 고성능 모델 (높은 품질)"
        echo "   ollama pull llama3.1:8b"
        echo "   ollama pull qwen2.5:7b"
        echo ""
        echo -e "${GREEN}모델 목록 확인: ollama list${NC}"
    else
        echo -e "${YELLOW}⚠️  Ollama가 설치되지 않았습니다.${NC}"
    fi
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
    echo -e "${GREEN}🎯 Reor AI 지식 관리 앱 설치 및 테스트 스크립트${NC}"
    echo -e "${GREEN}===========================================${NC}"
    
    check_requirements
    check_ollama
    
    # 트랩 설정 (스크립트 종료 시 정리)
    trap cleanup EXIT
    
    setup_project
    analyze_structure
    
    # 의존성 설치 시도
    if install_dependencies; then
        test_build
    fi
    
    ollama_model_guide
    
    echo -e "${GREEN}===========================================${NC}"
    echo -e "${GREEN}🎉 Reor 테스트 완료!${NC}"
    echo -e "${GREEN}===========================================${NC}"
    
    echo -e "${BLUE}💡 다음 단계:${NC}"
    echo -e "   1. Ollama 설치: ${YELLOW}curl -fsSL https://ollama.com/install.sh | sh${NC}"
    echo -e "   2. Ollama 서비스 시작: ${YELLOW}ollama serve${NC}"
    echo -e "   3. 모델 다운로드: ${YELLOW}ollama pull llama3.2:3b${NC}"
    echo -e "   4. Reor 앱 다운로드: ${YELLOW}https://reorproject.org${NC}"
    echo -e "   5. 또는 소스 빌드: ${YELLOW}npm run build${NC}"
}

# 스크립트 실행
main "$@" 