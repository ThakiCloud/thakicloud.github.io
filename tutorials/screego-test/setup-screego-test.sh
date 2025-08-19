#!/bin/bash

# Screego 서버 테스트 환경 설정 스크립트
# Author: Thaki Cloud
# Date: 2025-08-19

set -e

echo "🎯 Screego 서버 테스트 환경 설정 시작..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
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

# Docker 설치 확인
check_docker() {
    print_status "Docker 설치 확인 중..."
    if ! command -v docker &> /dev/null; then
        print_error "Docker가 설치되어 있지 않습니다."
        print_status "Docker Desktop을 설치해주세요: https://www.docker.com/products/docker-desktop"
        exit 1
    fi
    
    if ! docker info &> /dev/null; then
        print_error "Docker 데몬이 실행되지 않았습니다."
        print_status "Docker Desktop을 실행해주세요."
        exit 1
    fi
    
    print_success "Docker 확인 완료"
}

# 설정 디렉토리 생성
setup_directories() {
    print_status "설정 디렉토리 생성 중..."
    mkdir -p config data
    print_success "디렉토리 생성 완료"
}

# 사용자 설정 파일 생성
create_users_file() {
    print_status "사용자 설정 파일 생성 중..."
    cat > config/users << EOF
# Screego 사용자 설정 파일
# 형식: username:password
# 테스트용 사용자
demo:demo123
admin:admin123
thaki:cloud123
EOF
    print_success "사용자 설정 파일 생성 완료"
}

# Screego 컨테이너 실행
start_screego() {
    print_status "Screego 컨테이너 시작 중..."
    
    # 기존 컨테이너 정리
    if docker ps -a --format "table {{.Names}}" | grep -q "screego-test"; then
        print_warning "기존 screego-test 컨테이너 제거 중..."
        docker rm -f screego-test || true
    fi
    
    # 컨테이너 실행
    docker-compose up -d
    
    print_success "Screego 컨테이너 시작 완료"
}

# 서비스 상태 확인
check_service() {
    print_status "서비스 상태 확인 중..."
    
    # 5초 대기 (컨테이너 시작 시간)
    sleep 5
    
    # 컨테이너 상태 확인
    if docker ps --format "table {{.Names}}\t{{.Status}}" | grep -q "screego-test.*Up"; then
        print_success "Screego 컨테이너가 정상 실행 중입니다"
    else
        print_error "Screego 컨테이너 실행 실패"
        print_status "로그 확인:"
        docker logs screego-test
        exit 1
    fi
    
    # 웹 서비스 확인
    print_status "웹 서비스 접근성 확인 중..."
    for i in {1..10}; do
        if curl -s http://localhost:5050/health > /dev/null 2>&1; then
            print_success "웹 서비스가 정상 응답합니다"
            break
        elif curl -s http://localhost:5050 > /dev/null 2>&1; then
            print_success "웹 서비스가 정상 응답합니다"
            break
        else
            print_warning "웹 서비스 응답 대기 중... ($i/10)"
            sleep 2
        fi
        
        if [ $i -eq 10 ]; then
            print_warning "웹 서비스 응답 확인 실패, 수동으로 확인해주세요"
        fi
    done
}

# 접속 정보 출력
print_access_info() {
    echo ""
    echo "🎉 Screego 서버 설정 완료!"
    echo ""
    echo "📋 접속 정보:"
    echo "  🌐 웹 URL: http://localhost:5050"
    echo "  👤 테스트 계정:"
    echo "    - demo / demo123"
    echo "    - admin / admin123"
    echo "    - thaki / cloud123"
    echo ""
    echo "🔧 관리 명령어:"
    echo "  서비스 상태: docker-compose ps"
    echo "  로그 확인: docker-compose logs -f"
    echo "  서비스 중지: docker-compose down"
    echo "  서비스 재시작: docker-compose restart"
    echo ""
    echo "📚 테스트 방법:"
    echo "  1. 브라우저에서 http://localhost:5050 접속"
    echo "  2. 테스트 계정으로 로그인"
    echo "  3. 방 생성 후 스크린 공유 테스트"
    echo "  4. 다른 브라우저/탭에서 동일한 방 접속하여 공유 확인"
    echo ""
}

# 메인 실행
main() {
    echo "🚀 Screego 서버 자동 설정 시작"
    echo "================================="
    
    check_docker
    setup_directories
    create_users_file
    start_screego
    check_service
    print_access_info
}

# 스크립트 실행
main "$@"
