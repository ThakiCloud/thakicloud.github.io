#!/bin/bash

# =============================================================================
# Neosync Tutorial Test Script for macOS
# Description: Comprehensive test script for Neosync data anonymization tutorial
# Author: Thaki Cloud
# Date: 2025-08-26
# =============================================================================

set -euo pipefail  # Exit on any error

# Color codes for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Global variables
NEOSYNC_DIR="neosync-tutorial-test"
NEOSYNC_URL="http://localhost:3000"
TEST_DB_NAME="neosync_test"
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
LOG_FILE="neosync_test_${TIMESTAMP}.log"

# Cleanup function
cleanup() {
    log_info "정리 작업 중..."
    if [ -d "$NEOSYNC_DIR" ]; then
        cd "$NEOSYNC_DIR"
        if [ -f "compose.yml" ]; then
            docker compose down -v --remove-orphans 2>/dev/null || true
        fi
        cd ..
        rm -rf "$NEOSYNC_DIR"
    fi
    log_success "정리 완료"
}

# Trap cleanup on script exit
trap cleanup EXIT

# Function to check prerequisites
check_prerequisites() {
    log_info "필수 요구사항 확인 중..."

    # Check if Docker is installed and running
    if ! command -v docker &> /dev/null; then
        log_error "Docker가 설치되지 않았습니다. 먼저 Docker를 설치하세요."
        exit 1
    fi

    if ! docker info &> /dev/null; then
        log_error "Docker가 실행되지 않았습니다. Docker를 시작하세요."
        exit 1
    fi

    # Check if Docker Compose is available
    if ! docker compose version &> /dev/null; then
        log_error "Docker Compose가 사용할 수 없습니다. Docker Compose를 설치하세요."
        exit 1
    fi

    # Check if Git is installed
    if ! command -v git &> /dev/null; then
        log_error "Git이 설치되지 않았습니다. 먼저 Git을 설치하세요."
        exit 1
    fi

    # Check if curl is installed
    if ! command -v curl &> /dev/null; then
        log_error "curl이 설치되지 않았습니다. 먼저 curl을 설치하세요."
        exit 1
    fi

    log_success "모든 필수 요구사항이 충족되었습니다"
}

# Function to setup Neosync
setup_neosync() {
    log_info "Neosync 설정 중..."

    # Clone Neosync repository
    if [ ! -d "$NEOSYNC_DIR" ]; then
        log_info "Neosync 저장소 클론 중..."
        git clone https://github.com/nucleuscloud/neosync.git "$NEOSYNC_DIR" >> "$LOG_FILE" 2>&1
        if [ $? -eq 0 ]; then
            log_success "Neosync 저장소 클론 완료"
        else
            log_error "Neosync 저장소 클론 실패"
            return 1
        fi
    fi

    cd "$NEOSYNC_DIR"

    # Start Neosync services
    log_info "Neosync 서비스 시작 중..."
    if command -v make &> /dev/null; then
        make compose/up >> "../$LOG_FILE" 2>&1 &
    else
        docker compose up -d >> "../$LOG_FILE" 2>&1 &
    fi

    # Wait for services to be ready
    log_info "서비스 준비 대기 중 (최대 3분)..."
    local max_attempts=18
    local attempt=0

    while [ $attempt -lt $max_attempts ]; do
        if curl -f -s "$NEOSYNC_URL/health" > /dev/null 2>&1; then
            log_success "Neosync 서비스가 준비되었습니다"
            return 0
        fi
        
        attempt=$((attempt + 1))
        log_info "대기 중... (${attempt}/${max_attempts})"
        sleep 10
    done

    log_error "Neosync 서비스 시작 실패 또는 시간 초과"
    return 1
}

# Function to test basic functionality
test_basic_functionality() {
    log_info "기본 기능 테스트 중..."

    # Test 1: Check if web interface is accessible
    log_info "웹 인터페이스 접근성 테스트..."
    if curl -f -s "$NEOSYNC_URL" > /dev/null; then
        log_success "웹 인터페이스 접근 가능"
    else
        log_error "웹 인터페이스 접근 불가"
        return 1
    fi

    # Test 2: Check if API is responding
    log_info "API 응답성 테스트..."
    if curl -f -s "$NEOSYNC_URL/api/health" > /dev/null; then
        log_success "API 정상 응답"
    else
        log_warning "API 상태 확인 실패 (정상일 수 있음)"
    fi

    # Test 3: Check running containers
    log_info "실행 중인 컨테이너 확인..."
    local running_containers
    running_containers=$(docker compose ps --services --filter "status=running" 2>/dev/null | wc -l)
    
    if [ "$running_containers" -gt 0 ]; then
        log_success "실행 중인 컨테이너: $running_containers개"
        docker compose ps --format table
    else
        log_error "실행 중인 컨테이너가 없습니다"
        return 1
    fi

    return 0
}

# Function to test data operations
test_data_operations() {
    log_info "데이터 작업 테스트 중..."

    # Test database connectivity
    log_info "데이터베이스 연결 테스트..."
    
    # Wait for database to be ready
    local max_db_attempts=12
    local db_attempt=0
    
    while [ $db_attempt -lt $max_db_attempts ]; do
        if docker compose exec -T db pg_isready -U postgres > /dev/null 2>&1; then
            log_success "PostgreSQL 데이터베이스 연결 성공"
            break
        fi
        
        db_attempt=$((db_attempt + 1))
        log_info "데이터베이스 연결 대기 중... (${db_attempt}/${max_db_attempts})"
        sleep 5
    done

    if [ $db_attempt -eq $max_db_attempts ]; then
        log_error "데이터베이스 연결 실패"
        return 1
    fi

    # Test sample data existence
    log_info "샘플 데이터 확인..."
    local sample_tables
    sample_tables=$(docker compose exec -T db psql -U postgres -d postgres -t -c "SELECT COUNT(*) FROM information_schema.tables WHERE table_schema = 'public';" 2>/dev/null | tr -d ' \n\r')
    
    if [ "$sample_tables" -gt 0 ]; then
        log_success "샘플 테이블 발견: ${sample_tables}개"
    else
        log_warning "샘플 테이블이 없습니다 (설정 중일 수 있음)"
    fi

    return 0
}

# Function to test anonymization features
test_anonymization_features() {
    log_info "익명화 기능 테스트 중..."

    # This is a simplified test since full anonymization testing
    # would require complex setup and sample data
    
    # Test 1: Check if worker service is running
    log_info "워커 서비스 상태 확인..."
    if docker compose ps | grep -q "worker.*Up"; then
        log_success "워커 서비스 실행 중"
    else
        log_warning "워커 서비스 상태 불명 (정상일 수 있음)"
    fi

    # Test 2: Check logs for any obvious errors
    log_info "시스템 로그 오류 확인..."
    local error_count
    error_count=$(docker compose logs 2>&1 | grep -i "error\|fatal\|panic" | wc -l | tr -d ' ')
    
    if [ "$error_count" -eq 0 ]; then
        log_success "심각한 오류 없음"
    else
        log_warning "로그에서 ${error_count}개의 오류/경고 발견"
    fi

    return 0
}

# Function to generate test report
generate_report() {
    log_info "테스트 보고서 생성 중..."
    
    local report_file="neosync_test_report_${TIMESTAMP}.md"
    
    cat > "$report_file" << EOF
# Neosync Tutorial Test Report

**테스트 일시**: $(date)
**시스템**: $(uname -s) $(uname -r)
**Docker 버전**: $(docker --version)
**Docker Compose 버전**: $(docker compose version --short)

## 테스트 결과

### ✅ 성공한 테스트
- Docker 및 Docker Compose 설치 확인
- Neosync 저장소 클론
- 서비스 시작 및 상태 확인
- 웹 인터페이스 접근성
- 데이터베이스 연결성

### ⚠️ 주의사항
- 일부 기능은 실제 데이터 작업 시에만 완전히 테스트 가능
- 프로덕션 환경에서는 추가 보안 설정 필요

### 📋 실행 중인 서비스
\`\`\`
$(docker compose ps 2>/dev/null || echo "서비스 목록을 가져올 수 없습니다")
\`\`\`

### 📊 시스템 리소스 사용량
\`\`\`
$(docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}" 2>/dev/null || echo "리소스 정보를 가져올 수 없습니다")
\`\`\`

## 다음 단계

1. 웹 브라우저에서 http://localhost:3000 접속
2. 사전 구성된 샘플 데이터로 익명화 작업 실행
3. 자체 데이터베이스 연결 구성
4. 커스텀 변환 규칙 설정

## 유용한 명령어

\`\`\`bash
# 서비스 중지
cd ${NEOSYNC_DIR} && docker compose down

# 로그 확인
cd ${NEOSYNC_DIR} && docker compose logs -f

# 서비스 재시작
cd ${NEOSYNC_DIR} && docker compose restart
\`\`\`

---
*이 보고서는 Neosync 튜토리얼 테스트 스크립트에 의해 자동 생성되었습니다.*
EOF

    log_success "테스트 보고서 생성 완료: $report_file"
}

# Function to display next steps
show_next_steps() {
    echo
    echo "=================================================================="
    echo "🎉 Neosync 튜토리얼 테스트 완료!"
    echo "=================================================================="
    echo
    echo "✅ 다음 단계:"
    echo "   1. 웹 브라우저에서 $NEOSYNC_URL 접속"
    echo "   2. Neosync 대시보드 둘러보기"
    echo "   3. 샘플 익명화 작업 실행"
    echo "   4. 자체 데이터베이스 연결 설정"
    echo
    echo "📚 참고 자료:"
    echo "   - Neosync 문서: https://docs.neosync.dev"
    echo "   - GitHub 저장소: https://github.com/nucleuscloud/neosync"
    echo "   - 커뮤니티 Discord: https://discord.gg/neosync"
    echo
    echo "🔧 유용한 명령어:"
    echo "   cd $NEOSYNC_DIR"
    echo "   docker compose logs -f    # 로그 실시간 확인"
    echo "   docker compose down       # 서비스 중지"
    echo "   docker compose up -d      # 서비스 재시작"
    echo
    echo "📄 상세 로그: $LOG_FILE"
    echo "📊 테스트 보고서: neosync_test_report_${TIMESTAMP}.md"
    echo
}

# Main function
main() {
    echo "=================================================================="
    echo "🚀 Neosync 튜토리얼 테스트 스크립트 (macOS 버전)"
    echo "=================================================================="
    echo
    echo "이 스크립트는 Neosync 데이터 익명화 플랫폼을 설치하고 테스트합니다."
    echo "예상 소요 시간: 5-10분"
    echo
    
    # Start logging
    echo "테스트 시작: $(date)" > "$LOG_FILE"
    
    # Run tests
    check_prerequisites || exit 1
    setup_neosync || exit 1
    test_basic_functionality || exit 1
    test_data_operations || exit 1
    test_anonymization_features || exit 1
    
    # Generate report
    generate_report
    
    # Show next steps
    show_next_steps
    
    log_success "모든 테스트 완료!"
    return 0
}

# Run the main function if script is executed directly
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
