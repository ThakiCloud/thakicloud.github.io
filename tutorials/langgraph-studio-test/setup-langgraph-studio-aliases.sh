#!/bin/bash

# LangGraph Studio 테스트 스크립트 및 alias 설정
# 작성일: 2025-08-21
# 용도: LangGraph Studio 환경 설정 및 테스트 자동화

set -e  # 에러 발생시 스크립트 중단

echo "🚀 LangGraph Studio 환경 설정 시작..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수: 성공 메시지
success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# 함수: 경고 메시지
warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# 함수: 에러 메시지
error() {
    echo -e "${RED}❌ $1${NC}"
}

# 함수: 정보 메시지
info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# 시스템 요구사항 확인
check_requirements() {
    info "시스템 요구사항 확인 중..."
    
    # Python 버전 확인
    if command -v python3 &> /dev/null; then
        PYTHON_VERSION=$(python3 --version | cut -d' ' -f2)
        success "Python $PYTHON_VERSION 설치됨"
    else
        error "Python 3.8+ 필요"
        exit 1
    fi
    
    # Docker 확인
    if command -v docker &> /dev/null; then
        if docker ps &> /dev/null; then
            success "Docker 실행 중"
        else
            warning "Docker 데몬이 실행되지 않음"
        fi
    else
        error "Docker 설치 필요"
        exit 1
    fi
    
    # Git 확인
    if command -v git &> /dev/null; then
        success "Git 설치됨"
    else
        warning "Git 설치 권장"
    fi
}

# LangGraph Studio 환경 설정
setup_langgraph_studio() {
    info "LangGraph Studio 환경 설정 중..."
    
    # 프로젝트 디렉토리 생성
    PROJECT_DIR="langgraph-studio-demo"
    if [ ! -d "$PROJECT_DIR" ]; then
        mkdir -p "$PROJECT_DIR"
        cd "$PROJECT_DIR"
        success "프로젝트 디렉토리 생성: $PROJECT_DIR"
    else
        cd "$PROJECT_DIR"
        info "기존 프로젝트 디렉토리 사용: $PROJECT_DIR"
    fi
    
    # Python 가상환경 생성 및 활성화
    if [ ! -d "venv" ]; then
        python3 -m venv venv
        success "Python 가상환경 생성"
    fi
    
    source venv/bin/activate
    success "가상환경 활성화"
    
    # LangGraph CLI 설치
    info "LangGraph CLI 설치 중..."
    pip install --upgrade pip
    pip install -U "langgraph-cli[inmem]"
    success "LangGraph CLI 설치 완료"
    
    # 버전 확인
    LANGGRAPH_VERSION=$(langgraph --version | head -1)
    success "$LANGGRAPH_VERSION"
}

# 샘플 프로젝트 생성
create_sample_project() {
    info "샘플 프로젝트 생성 중..."
    
    # 새 프로젝트 디렉토리 생성
    DEMO_DIR="demo-agent"
    if [ ! -d "$DEMO_DIR" ]; then
        mkdir -p "$DEMO_DIR"
        cd "$DEMO_DIR"
        
        # 자동으로 프로젝트 생성 (1번 템플릿, Python 선택)
        printf ".\n1\n1\n" | langgraph new
        
        # .env 파일 생성
        if [ -f ".env.example" ]; then
            cp .env.example .env
            success ".env 파일 생성"
        fi
        
        # 프로젝트 의존성 설치
        pip install -e .
        success "프로젝트 의존성 설치 완료"
        
        cd ..
        success "샘플 프로젝트 생성 완료: $DEMO_DIR"
    else
        info "기존 샘플 프로젝트 사용: $DEMO_DIR"
    fi
}

# zshrc aliases 추가
setup_aliases() {
    info "zshrc aliases 설정 중..."
    
    ALIASES='
# LangGraph Studio Aliases
export LANGGRAPH_PROJECT_DIR="$HOME/langgraph-projects"

# 환경 관리
alias lg-env="cd $LANGGRAPH_PROJECT_DIR && source venv/bin/activate"
alias lg-install="pip install -U \"langgraph-cli[inmem]\""
alias lg-version="langgraph --version"

# 프로젝트 관리
alias lg-new="langgraph new"
alias lg-init="mkdir -p langgraph-project && cd langgraph-project && python3 -m venv venv && source venv/bin/activate && pip install -U \"langgraph-cli[inmem]\""

# 개발 서버
alias lg-dev="langgraph dev --no-browser"
alias lg-dev-tunnel="langgraph dev --tunnel"
alias lg-up="langgraph up"
alias lg-stop="docker-compose down"

# 디버깅 및 모니터링
alias lg-logs="docker-compose logs -f"
alias lg-status="docker ps | grep langgraph"
alias lg-clean="docker system prune -f"

# Studio 접속
alias lg-studio="open https://smith.langchain.com/studio/"
alias lg-docs="open http://localhost:8123/docs"

# 유틸리티
alias lg-check="docker ps && python3 --version && langgraph --version"
alias lg-help="echo \"LangGraph Studio 명령어:
  lg-env         - 환경 활성화
  lg-install     - CLI 설치/업데이트  
  lg-new         - 새 프로젝트 생성
  lg-dev         - 개발 서버 시작
  lg-dev-tunnel  - 터널로 개발 서버 시작
  lg-studio      - Studio 웹 인터페이스 열기
  lg-check       - 환경 상태 확인
\""
'
    
    # ~/.zshrc에 aliases 추가 (중복 방지)
    if ! grep -q "LangGraph Studio Aliases" ~/.zshrc; then
        echo "$ALIASES" >> ~/.zshrc
        success "zshrc aliases 추가됨"
        info "변경사항 적용: source ~/.zshrc"
    else
        info "aliases가 이미 설정되어 있음"
    fi
}

# 개발 서버 테스트
test_dev_server() {
    info "개발 서버 테스트 중..."
    
    cd demo-agent
    
    # 백그라운드에서 서버 시작
    langgraph dev --no-browser --port 8123 &
    SERVER_PID=$!
    
    # 서버 시작 대기
    sleep 5
    
    # API 엔드포인트 테스트
    if curl -s http://localhost:8123/health > /dev/null; then
        success "개발 서버 정상 작동 확인"
        
        # Studio URL 출력
        info "Studio 접속 URL:"
        echo "  🎨 Studio UI: https://smith.langchain.com/studio/?baseUrl=http://127.0.0.1:8123"
        echo "  📚 API Docs: http://127.0.0.1:8123/docs"
        echo "  🔧 Health Check: http://127.0.0.1:8123/health"
    else
        warning "개발 서버 응답 없음"
    fi
    
    # 서버 정리
    kill $SERVER_PID 2>/dev/null || true
    sleep 2
    
    cd ..
}

# 테스트 스크립트 생성
create_test_script() {
    info "테스트 스크립트 생성 중..."
    
    cat > test-langgraph-studio.sh << 'EOF'
#!/bin/bash

# LangGraph Studio 빠른 테스트 스크립트
set -e

echo "🧪 LangGraph Studio 테스트 시작..."

# 환경 확인
echo "📋 환경 정보:"
echo "  Python: $(python3 --version)"
echo "  LangGraph CLI: $(langgraph --version)"
echo "  Docker: $(docker --version)"

# 프로젝트 구조 확인
echo "📁 프로젝트 구조:"
if [ -d "demo-agent" ]; then
    cd demo-agent
    echo "  ✅ demo-agent 프로젝트 존재"
    
    if [ -f "langgraph.json" ]; then
        echo "  ✅ langgraph.json 설정 파일 존재"
    fi
    
    if [ -f "src/agent/graph.py" ]; then
        echo "  ✅ 에이전트 그래프 파일 존재"
    fi
    
    # 그래프 구조 출력
    echo "📊 그래프 정보:"
    python3 -c "
from src.agent.graph import graph
print(f'  그래프 이름: {graph.name}')
print(f'  노드 수: {len(graph.nodes)}')
print(f'  노드 목록: {list(graph.nodes.keys())}')
" 2>/dev/null || echo "  ⚠️  그래프 정보 조회 실패"
    
    cd ..
else
    echo "  ❌ demo-agent 프로젝트 없음"
fi

echo "✅ 테스트 완료"
EOF

    chmod +x test-langgraph-studio.sh
    success "테스트 스크립트 생성: test-langgraph-studio.sh"
}

# 메인 실행
main() {
    echo "🎯 LangGraph Studio 완전 설치 및 설정"
    echo "======================================"
    
    check_requirements
    setup_langgraph_studio
    create_sample_project
    create_test_script
    setup_aliases
    test_dev_server
    
    echo ""
    success "🎉 LangGraph Studio 설치 및 설정 완료!"
    echo ""
    info "다음 단계:"
    echo "1. 터미널을 다시 시작하거나 'source ~/.zshrc' 실행"
    echo "2. 'lg-help' 명령어로 사용 가능한 aliases 확인"
    echo "3. 'lg-dev' 명령어로 개발 서버 시작"
    echo "4. Studio UI에서 에이전트 테스트: https://smith.langchain.com/studio/"
    echo ""
}

# 스크립트가 직접 실행될 때만 main 함수 호출
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
