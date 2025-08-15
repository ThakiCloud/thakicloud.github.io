#!/bin/bash

# Cali AI Agent 테스트 스크립트
# 작성자: ThakiCloud
# 목적: macOS에서 Cali 설치 및 기본 기능 테스트

set -e

echo "🚀 Cali AI Agent 테스트 스크립트 시작"
echo "===================================="

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

# 1. 시스템 요구사항 확인
print_status "시스템 요구사항 확인 중..."

# Node.js 버전 확인
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js 설치됨: $NODE_VERSION"
else
    print_error "Node.js가 설치되지 않았습니다."
    echo "Homebrew로 설치하려면: brew install node"
    exit 1
fi

# npm 버전 확인
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "npm 설치됨: v$NPM_VERSION"
else
    print_error "npm이 설치되지 않았습니다."
    exit 1
fi

# React Native CLI 확인
if command -v npx &> /dev/null; then
    print_success "npx 사용 가능"
else
    print_error "npx가 사용 불가능합니다."
    exit 1
fi

# 2. 테스트 디렉토리 설정
TEST_DIR="$HOME/cali-test-$(date +%Y%m%d-%H%M%S)"
print_status "테스트 디렉토리 생성: $TEST_DIR"

mkdir -p "$TEST_DIR"
cd "$TEST_DIR"

# 3. React Native 프로젝트 생성 (선택사항)
read -p "새 React Native 프로젝트를 생성하시겠습니까? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "React Native 프로젝트 생성 중..."
    npx react-native@latest init CaliTestApp --skip-install
    cd CaliTestApp
    print_success "React Native 프로젝트 'CaliTestApp' 생성 완료"
    
    # 의존성 설치
    print_status "의존성 설치 중..."
    npm install
    print_success "의존성 설치 완료"
    
    # iOS 설정 (macOS에서만)
    if [[ "$OSTYPE" == "darwin"* ]]; then
        print_status "iOS 의존성 설치 중..."
        cd ios && pod install && cd ..
        print_success "iOS 의존성 설치 완료"
    fi
fi

# 4. Cali 실행 테스트
print_status "Cali 실행 가능 여부 확인 중..."

# Cali 패키지 존재 확인
if npm view cali &> /dev/null; then
    print_success "Cali 패키지 확인됨"
else
    print_warning "Cali 패키지를 npm registry에서 찾을 수 없습니다."
fi

# 5. 테스트 명령어 스크립트 생성
cat > test-commands.txt << 'EOF'
Cali AI Agent 테스트 명령어 목록:

기본 테스트 명령어들:
1. "현재 시스템 정보를 보여줘"
2. "연결된 디바이스나 시뮬레이터를 확인해줘"  
3. "이 프로젝트의 의존성을 확인해줘"
4. "사용 가능한 React Native 명령어를 알려줘"

라이브러리 검색 테스트:
5. "react-navigation 라이브러리를 찾아줘"
6. "최고 평점의 상태관리 라이브러리는 뭐야?"
7. "카메라 관련 라이브러리를 추천해줘"

빌드 및 실행 테스트 (프로젝트 내에서):
8. "package.json의 스크립트들을 확인해줘"
9. "iOS 시뮬레이터에서 앱을 실행해줘" (macOS만)
10. "Android 에뮬레이터에서 앱을 실행해줘"

고급 기능 테스트:
11. "프로젝트에 새로운 컴포넌트를 만들어줘"
12. "ESLint 설정을 확인하고 개선점을 제안해줘"
13. "배포를 위한 릴리즈 빌드를 준비해줘"
EOF

print_success "테스트 명령어 목록 생성: test-commands.txt"

# 6. 실행 스크립트 생성
cat > run-cali.sh << 'EOF'
#!/bin/bash
echo "🤖 Cali AI Agent 실행"
echo "====================="
echo ""
echo "Cali를 실행하려면 다음 명령어를 사용하세요:"
echo "npx cali"
echo ""
echo "테스트 명령어들은 test-commands.txt 파일을 참고하세요."
echo ""

# 실제 Cali 실행 시도
echo "Cali 실행 중..."
npx cali
EOF

chmod +x run-cali.sh
print_success "Cali 실행 스크립트 생성: run-cali.sh"

# 7. 환경 정보 수집
cat > environment-info.txt << EOF
Cali 테스트 환경 정보
==================

시스템 정보:
- OS: $(uname -s) $(uname -r)
- 아키텍처: $(uname -m)

Node.js 환경:
- Node.js: $(node --version)
- npm: $(npm --version)
- npx: $(npx --version)

React Native 환경:
- React Native CLI: $(npx react-native --version 2>/dev/null || echo "설치되지 않음")

iOS 개발 환경 (macOS):
- Xcode: $(xcodebuild -version 2>/dev/null | head -1 || echo "설치되지 않음")
- iOS Simulator: $(xcrun simctl list devices available 2>/dev/null | head -5 || echo "확인 불가")

Android 개발 환경:
- ADB: $(adb --version 2>/dev/null | head -1 || echo "설치되지 않음")
- Java: $(java --version 2>/dev/null | head -1 || echo "설치되지 않음")

생성 시간: $(date)
테스트 디렉토리: $(pwd)
EOF

print_success "환경 정보 저장: environment-info.txt"

# 8. 최종 안내
echo ""
echo "🎉 Cali 테스트 환경 설정 완료!"
echo "================================"
echo ""
echo "📁 테스트 디렉토리: $TEST_DIR"
echo ""
echo "🚀 다음 단계:"
echo "1. cd $TEST_DIR"
echo "2. ./run-cali.sh 실행하여 Cali 시작"
echo "3. test-commands.txt의 명령어들로 테스트"
echo ""
echo "📋 생성된 파일들:"
echo "- run-cali.sh: Cali 실행 스크립트"
echo "- test-commands.txt: 테스트 명령어 목록"
echo "- environment-info.txt: 시스템 환경 정보"
if [[ $REPLY =~ ^[Yy]$ ]]; then
    echo "- CaliTestApp/: React Native 테스트 프로젝트"
fi
echo ""
echo "💡 팁: 먼저 test-commands.txt의 기본 명령어들부터 시작하세요!"

# 마지막 확인
echo ""
read -p "지금 Cali를 실행해보시겠습니까? (y/n): " -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]; then
    print_status "Cali 실행 중..."
    ./run-cali.sh
else
    print_success "테스트 환경 준비 완료. 언제든지 ./run-cali.sh로 시작하세요!"
fi
