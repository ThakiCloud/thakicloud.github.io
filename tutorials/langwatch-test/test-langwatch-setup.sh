#!/bin/bash

# LangWatch 로컬 설정 및 테스트 스크립트
# macOS 환경에서 LangWatch Docker 환경 구축

set -e

echo "🚀 LangWatch 로컬 환경 구축 시작..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 함수 정의
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 사전 요구사항 확인
check_requirements() {
    print_status "사전 요구사항 확인 중..."
    
    # Docker 설치 확인
    if ! command -v docker &> /dev/null; then
        print_error "Docker가 설치되어 있지 않습니다. Docker Desktop을 설치해주세요."
        echo "  다운로드: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    # Docker Compose 확인
    if ! command -v docker-compose &> /dev/null && ! docker compose version &> /dev/null; then
        print_error "Docker Compose가 설치되어 있지 않습니다."
        exit 1
    fi
    
    print_success "Docker 환경 확인 완료"
    
    # 시스템 아키텍처 확인
    ARCH=$(uname -m)
    print_status "시스템 아키텍처: $ARCH"
    
    if [[ "$ARCH" == "arm64" ]]; then
        print_warning "ARM64 (Apple Silicon) 감지됨 - ARM64 오버라이드 파일을 사용합니다"
        USE_ARM_OVERRIDE=true
    else
        USE_ARM_OVERRIDE=false
    fi
}

# LangWatch 클론 및 설정
setup_langwatch() {
    print_status "LangWatch 리포지토리 클론 중..."
    
    # 기존 디렉토리가 있다면 업데이트
    if [ -d "langwatch" ]; then
        print_status "기존 LangWatch 디렉토리 발견, 업데이트 중..."
        cd langwatch
        git pull origin main
        cd ..
    else
        git clone https://github.com/langwatch/langwatch.git
    fi
    
    cd langwatch
    
    print_status "환경 설정 파일 복사 중..."
    cp langwatch/.env.example langwatch/.env
    
    # 로컬 개발용 환경 변수 설정
    print_status "로컬 개발용 환경 변수 설정 중..."
    
    # .env 파일 수정
    cat >> langwatch/.env << EOF

# 로컬 개발 설정
LANGWATCH_HOST=localhost
LANGWATCH_PORT=5560
ENVIRONMENT=development

# 디버그 모드 활성화
DEBUG=true
LOG_LEVEL=debug

# 테스트용 API 키 (로컬 개발만)
LANGWATCH_API_KEY=lw-dev-$(date +%s)
EOF

    print_success "환경 설정 완료"
}

# Docker Compose 실행
start_langwatch() {
    print_status "LangWatch Docker 컨테이너 시작 중..."
    
    if [[ "$USE_ARM_OVERRIDE" == true ]]; then
        print_status "ARM64용 Docker Compose 실행..."
        docker compose -f compose.yml -f docker-compose.arm64.override.yml up -d --wait --build
    else
        print_status "x86_64용 Docker Compose 실행..."
        docker compose up -d --wait --build
    fi
    
    print_success "LangWatch 컨테이너 시작 완료"
}

# 헬스체크
health_check() {
    print_status "LangWatch 서비스 헬스체크 중..."
    
    local max_attempts=30
    local attempt=0
    
    while [ $attempt -lt $max_attempts ]; do
        if curl -s -f http://localhost:5560/health >/dev/null 2>&1; then
            print_success "LangWatch가 정상적으로 실행되고 있습니다!"
            break
        fi
        
        attempt=$((attempt + 1))
        print_status "헬스체크 시도 $attempt/$max_attempts..."
        sleep 2
    done
    
    if [ $attempt -eq $max_attempts ]; then
        print_warning "헬스체크 실패, 하지만 서비스가 여전히 시작 중일 수 있습니다."
        print_status "수동으로 확인해주세요: http://localhost:5560"
    fi
}

# Python 테스트 환경 설정
setup_python_test() {
    print_status "Python 테스트 환경 설정 중..."
    
    # 가상환경 생성
    if [ ! -d "langwatch-test-env" ]; then
        python3 -m venv langwatch-test-env
    fi
    
    source langwatch-test-env/bin/activate
    
    # 필요한 패키지 설치
    pip install --upgrade pip
    pip install langwatch openai python-dotenv requests
    
    print_success "Python 테스트 환경 준비 완료"
}

# 테스트 스크립트 생성
create_test_script() {
    print_status "테스트 스크립트 생성 중..."
    
    cat > test_langwatch_basic.py << 'EOF'
#!/usr/bin/env python3
"""
LangWatch 기본 기능 테스트 스크립트
"""

import os
import sys
import time
import requests
from dotenv import load_dotenv

# 환경 변수 로드
load_dotenv()

def test_langwatch_connection():
    """LangWatch 서버 연결 테스트"""
    print("🔗 LangWatch 서버 연결 테스트...")
    
    try:
        response = requests.get("http://localhost:5560/health", timeout=5)
        if response.status_code == 200:
            print("✅ LangWatch 서버 연결 성공")
            return True
        else:
            print(f"❌ LangWatch 서버 응답 오류: {response.status_code}")
            return False
    except requests.exceptions.RequestException as e:
        print(f"❌ LangWatch 서버 연결 실패: {e}")
        return False

def test_langwatch_api():
    """LangWatch API 기본 테스트"""
    print("🧪 LangWatch API 기본 테스트...")
    
    try:
        # LangWatch SDK import 테스트
        import langwatch
        print("✅ LangWatch SDK 임포트 성공")
        
        # 로컬 LangWatch 초기화
        langwatch.init(
            api_key="lw-test-key",
            endpoint="http://localhost:5560"
        )
        print("✅ LangWatch 초기화 성공")
        
        return True
        
    except ImportError as e:
        print(f"❌ LangWatch SDK 임포트 실패: {e}")
        print("   pip install langwatch로 설치해주세요")
        return False
    except Exception as e:
        print(f"❌ LangWatch API 테스트 실패: {e}")
        return False

def test_basic_tracing():
    """기본 트레이싱 기능 테스트"""
    print("📊 기본 트레이싱 기능 테스트...")
    
    try:
        import langwatch
        
        @langwatch.trace()
        def simple_function(message):
            """간단한 함수 트레이싱 테스트"""
            time.sleep(0.1)  # 시뮬레이션 지연
            return f"처리됨: {message}"
        
        result = simple_function("테스트 메시지")
        print(f"✅ 트레이싱 테스트 완료: {result}")
        return True
        
    except Exception as e:
        print(f"❌ 트레이싱 테스트 실패: {e}")
        return False

def main():
    """메인 테스트 함수"""
    print("🚀 LangWatch 로컬 테스트 시작\n")
    
    tests = [
        ("서버 연결", test_langwatch_connection),
        ("API 초기화", test_langwatch_api),
        ("기본 트레이싱", test_basic_tracing)
    ]
    
    passed = 0
    total = len(tests)
    
    for test_name, test_func in tests:
        print(f"\n{'='*50}")
        print(f"테스트: {test_name}")
        print('='*50)
        
        if test_func():
            passed += 1
        
        time.sleep(1)
    
    print(f"\n{'='*50}")
    print(f"테스트 결과: {passed}/{total} 통과")
    print('='*50)
    
    if passed == total:
        print("🎉 모든 테스트 통과!")
        print("📱 LangWatch 대시보드: http://localhost:5560")
    else:
        print("⚠️ 일부 테스트 실패")
        print("   Docker 컨테이너 상태를 확인해주세요")
        print("   docker compose logs -f")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

    chmod +x test_langwatch_basic.py
    print_success "테스트 스크립트 생성 완료"
}

# zshrc 별칭 생성
create_aliases() {
    print_status "유용한 별칭 생성 중..."
    
    cat > langwatch-aliases.sh << 'EOF'
#!/bin/bash
# LangWatch 관련 유용한 별칭들

# LangWatch Docker 관리
alias langwatch-start="cd tutorials/langwatch-test/langwatch && docker compose up -d"
alias langwatch-start-arm="cd tutorials/langwatch-test/langwatch && docker compose -f compose.yml -f docker-compose.arm64.override.yml up -d"
alias langwatch-stop="cd tutorials/langwatch-test/langwatch && docker compose down"
alias langwatch-restart="langwatch-stop && langwatch-start"
alias langwatch-logs="cd tutorials/langwatch-test/langwatch && docker compose logs -f"
alias langwatch-status="cd tutorials/langwatch-test/langwatch && docker compose ps"

# LangWatch 개발
alias langwatch-test="cd tutorials/langwatch-test && source langwatch/langwatch-test-env/bin/activate && python test_langwatch_basic.py"
alias langwatch-shell="cd tutorials/langwatch-test && source langwatch/langwatch-test-env/bin/activate"

# 빠른 접근
alias langwatch-dash="open http://localhost:5560"
alias langwatch-dir="cd tutorials/langwatch-test"

echo "🔧 LangWatch 별칭이 로드되었습니다!"
echo "   langwatch-start    : LangWatch 시작"
echo "   langwatch-stop     : LangWatch 중지"
echo "   langwatch-logs     : 로그 확인"
echo "   langwatch-test     : 기본 테스트 실행"
echo "   langwatch-dash     : 대시보드 열기"
EOF

    chmod +x langwatch-aliases.sh
    print_success "별칭 스크립트 생성 완료"
    
    print_status "별칭을 zshrc에 추가하려면 다음 명령을 실행하세요:"
    echo "  echo 'source $(pwd)/langwatch-aliases.sh' >> ~/.zshrc"
    echo "  source ~/.zshrc"
}

# 메인 실행
main() {
    echo "🚀 LangWatch 로컬 개발 환경 구축 스크립트"
    echo "================================================"
    
    check_requirements
    setup_langwatch
    start_langwatch
    health_check
    setup_python_test
    create_test_script
    create_aliases
    
    echo ""
    echo "🎉 LangWatch 설정 완료!"
    echo "================================================"
    echo "📱 대시보드: http://localhost:5560"
    echo "🧪 테스트 실행: python test_langwatch_basic.py"
    echo "📜 로그 확인: docker compose logs -f"
    echo "🛑 중지: docker compose down"
    echo ""
    echo "💡 유용한 별칭을 사용하려면:"
    echo "   source langwatch-aliases.sh"
    echo ""
}

# 스크립트 실행
main "$@"
