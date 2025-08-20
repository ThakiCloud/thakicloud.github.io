#!/bin/bash

# gitego Git Identity Manager 테스트 스크립트
# 작성일: 2025-08-20

set -e  # 에러 발생시 스크립트 중단

echo "🚀 gitego Git Identity Manager 설치 및 테스트"
echo "=============================================="

# 색상 정의
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo_success() {
    echo -e "${GREEN}✓${NC} $1"
}

echo_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

echo_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

echo_error() {
    echo -e "${RED}✗${NC} $1"
}

# 1. 현재 환경 정보 출력
echo_info "환경 정보 확인"
echo "Go Version: $(go version)"
echo "Git Version: $(git --version)"
echo "OS: $(uname -s)"
echo "Architecture: $(uname -m)"
echo ""

# 2. gitego 다운로드 및 설치
echo_info "gitego 다운로드 및 설치"

# 최신 릴리즈 URL 확인
LATEST_URL=$(curl -s https://api.github.com/repos/bgreenwell/gitego/releases/latest | grep "browser_download_url.*darwin.*arm64" | cut -d '"' -f 4)

if [ -z "$LATEST_URL" ]; then
    echo_warning "다운로드 URL을 찾을 수 없습니다. Go build로 설치합니다."
    
    # 소스에서 빌드
    echo_info "소스에서 gitego 빌드"
    git clone https://github.com/bgreenwell/gitego.git
    cd gitego
    go build -o gitego .
    
    # /usr/local/bin에 설치
    sudo cp gitego /usr/local/bin/
    echo_success "gitego가 /usr/local/bin/에 설치되었습니다."
    cd ..
else
    echo_info "다운로드 URL: $LATEST_URL"
    
    # 다운로드 및 설치
    curl -L "$LATEST_URL" -o gitego.tar.gz
    tar -xzf gitego.tar.gz
    sudo cp gitego /usr/local/bin/
    echo_success "gitego가 설치되었습니다."
fi

# 3. 설치 확인
echo_info "gitego 설치 확인"
if command -v gitego >/dev/null 2>&1; then
    echo_success "gitego 설치 성공!"
    gitego --version
else
    echo_error "gitego 설치 실패"
    exit 1
fi

echo ""

# 4. 기본 설정 및 테스트
echo_info "기본 Git 설정 백업"

# 현재 Git 설정 백업
git config --global user.name > /tmp/git_backup_name.txt 2>/dev/null || echo "No name set" > /tmp/git_backup_name.txt
git config --global user.email > /tmp/git_backup_email.txt 2>/dev/null || echo "No email set" > /tmp/git_backup_email.txt

echo_success "Git 설정이 백업되었습니다."

# 5. gitego 프로필 생성 테스트
echo_info "gitego 프로필 생성 테스트"

# 테스트 프로필들 생성
gitego add personal --name "John Doe" --email "john.personal@example.com"
echo_success "개인 프로필 생성 완료"

gitego add work --name "John Doe" --email "john.work@company.com"
echo_success "회사 프로필 생성 완료"

# 프로필 목록 확인
echo_info "생성된 프로필 목록:"
gitego list

echo ""

# 6. 프로필 전환 테스트
echo_info "프로필 전환 테스트"

# 글로벌 프로필 설정
gitego use personal
echo_success "개인 프로필로 전환 완료"

# 현재 상태 확인
echo_info "현재 gitego 상태:"
gitego status

echo ""

# 7. 자동 전환 설정 테스트
echo_info "자동 전환 설정 테스트"

# 테스트 디렉토리 생성
mkdir -p ~/test-work-dir
mkdir -p ~/test-personal-dir

# 자동 전환 규칙 설정
gitego auto ~/test-work-dir work
gitego auto ~/test-personal-dir personal

echo_success "자동 전환 규칙 설정 완료"

# 8. 디렉토리별 테스트
echo_info "디렉토리별 프로필 전환 테스트"

cd ~/test-work-dir
echo "작업 디렉토리에서 gitego 상태:"
gitego status

cd ~/test-personal-dir  
echo "개인 디렉토리에서 gitego 상태:"
gitego status

# 원래 디렉토리로 복귀
cd "$(dirname "$0")"

echo ""

# 9. 크리덴셜 헬퍼 설정 (옵션)
echo_info "Git credential helper 설정"
git config --global credential.helper '!gitego credential'
echo_success "gitego가 Git credential helper로 설정되었습니다."

echo ""

# 10. 완료 메시지
echo_success "gitego 테스트가 완료되었습니다!"
echo ""
echo_info "주요 명령어 요약:"
echo "  - gitego add <name>: 새 프로필 추가"
echo "  - gitego list: 프로필 목록 보기"
echo "  - gitego use <name>: 글로벌 프로필 설정"
echo "  - gitego auto <path> <name>: 자동 전환 규칙 설정"
echo "  - gitego status: 현재 상태 확인"
echo "  - gitego edit <name>: 프로필 편집"
echo "  - gitego rm <name>: 프로필 삭제"

echo ""
echo_warning "테스트 환경 정리를 원하시면 다음 명령어를 실행하세요:"
echo "  - gitego rm personal"
echo "  - gitego rm work"
echo "  - rm -rf ~/test-work-dir ~/test-personal-dir"

# Git 설정 복원 옵션 안내
echo ""
echo_info "Git 설정 복원 (필요시):"
echo "  - git config --global user.name \"\$(cat /tmp/git_backup_name.txt)\""
echo "  - git config --global user.email \"\$(cat /tmp/git_backup_email.txt)\""
