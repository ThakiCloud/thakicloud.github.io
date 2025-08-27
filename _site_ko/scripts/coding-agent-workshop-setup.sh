#!/bin/bash
# coding-agent-workshop-setup.sh
# 코딩 에이전트 워크샵 완전 설정 및 테스트 스크립트
# macOS 환경에서 실행 가능

set -e

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# 로그 함수들
log_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

log_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

log_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

log_error() {
    echo -e "${RED}❌ $1${NC}"
}

log_step() {
    echo -e "${PURPLE}🔧 $1${NC}"
}

# 스크립트 정보
echo -e "${CYAN}"
cat << 'EOF'
╔══════════════════════════════════════════════════════════════╗
║                    코딩 에이전트 워크샵                           ║
║                    완전 설정 및 테스트 스크립트                     ║
║                                                              ║
║  GitHub: https://github.com/ghuntley/how-to-build-a-coding-agent  ║
║  Blog Post: thakicloud.github.io                           ║
╚══════════════════════════════════════════════════════════════╝
EOF
echo -e "${NC}"

# 변수 설정
WORKSHOP_DIR="$HOME/coding-agent-workshop"
REQUIRED_GO_VERSION="1.24.0"
API_KEY_FILE="$HOME/.anthropic_api_key"

# 시스템 요구사항 확인
check_system_requirements() {
    log_step "시스템 요구사항 확인 중..."
    
    # macOS 확인
    if [[ "$OSTYPE" != "darwin"* ]]; then
        log_error "이 스크립트는 macOS 전용입니다."
        exit 1
    fi
    
    # Homebrew 확인
    if ! command -v brew &> /dev/null; then
        log_warning "Homebrew가 설치되어 있지 않습니다."
        log_info "Homebrew 설치 중..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        log_success "Homebrew 설치됨"
    fi
    
    # Git 확인
    if ! command -v git &> /dev/null; then
        log_info "Git 설치 중..."
        brew install git
    else
        log_success "Git 설치됨"
    fi
    
    # curl 확인
    if ! command -v curl &> /dev/null; then
        log_info "curl 설치 중..."
        brew install curl
    else
        log_success "curl 설치됨"
    fi
}

# Go 설치 및 확인
setup_go() {
    log_step "Go 환경 설정 중..."
    
    if ! command -v go &> /dev/null; then
        log_info "Go 설치 중..."
        brew install go
    else
        # Go 버전 확인
        CURRENT_GO_VERSION=$(go version | awk '{print $3}' | sed 's/go//')
        if [[ "$(printf '%s\n' "$REQUIRED_GO_VERSION" "$CURRENT_GO_VERSION" | sort -V | head -n1)" != "$REQUIRED_GO_VERSION" ]]; then
            log_warning "Go 버전이 $REQUIRED_GO_VERSION 미만입니다. 현재: $CURRENT_GO_VERSION"
            log_info "Go 업데이트 중..."
            brew upgrade go
        else
            log_success "Go 버전 확인: $CURRENT_GO_VERSION"
        fi
    fi
    
    # Go 환경 변수 설정
    if ! grep -q 'export GOPATH' ~/.zshrc 2>/dev/null; then
        echo 'export GOPATH=$HOME/go' >> ~/.zshrc
        echo 'export PATH=$PATH:$GOPATH/bin' >> ~/.zshrc
        log_info "Go 환경 변수를 ~/.zshrc에 추가했습니다."
    fi
}

# Ripgrep 설치 (코드 검색용)
setup_ripgrep() {
    log_step "Ripgrep 설정 중..."
    
    if ! command -v rg &> /dev/null; then
        log_info "Ripgrep 설치 중..."
        brew install ripgrep
    else
        log_success "Ripgrep 설치됨"
    fi
}

# 워크샵 저장소 복제
clone_workshop() {
    log_step "워크샵 저장소 복제 중..."
    
    if [ -d "$WORKSHOP_DIR" ]; then
        log_warning "워크샵 디렉터리가 이미 존재합니다: $WORKSHOP_DIR"
        read -p "기존 디렉터리를 삭제하고 다시 복제하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$WORKSHOP_DIR"
            log_info "기존 디렉터리 삭제됨"
        else
            log_info "기존 디렉터리 사용"
            return 0
        fi
    fi
    
    log_info "GitHub에서 워크샵 저장소 복제 중..."
    git clone https://github.com/ghuntley/how-to-build-a-coding-agent.git "$WORKSHOP_DIR"
    log_success "워크샵 저장소 복제 완료"
}

# API 키 설정
setup_api_key() {
    log_step "Anthropic API 키 설정 중..."
    
    if [ -f "$API_KEY_FILE" ]; then
        ANTHROPIC_API_KEY=$(cat "$API_KEY_FILE")
        export ANTHROPIC_API_KEY
        log_success "API 키를 파일에서 로드했습니다."
        return 0
    fi
    
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        log_warning "ANTHROPIC_API_KEY가 설정되지 않았습니다."
        echo
        log_info "Anthropic API 키를 얻는 방법:"
        echo "1. https://console.anthropic.com/ 방문"
        echo "2. 계정 생성 또는 로그인"
        echo "3. API Keys 섹션에서 새 키 생성"
        echo
        read -p "API 키를 입력하세요 (Enter를 누르면 나중에 설정): " -r
        
        if [ -n "$REPLY" ]; then
            echo "$REPLY" > "$API_KEY_FILE"
            chmod 600 "$API_KEY_FILE"
            export ANTHROPIC_API_KEY="$REPLY"
            log_success "API 키가 저장되었습니다: $API_KEY_FILE"
            
            # zshrc에 자동 로드 추가
            if ! grep -q "ANTHROPIC_API_KEY" ~/.zshrc 2>/dev/null; then
                echo "export ANTHROPIC_API_KEY=\"\$(cat $API_KEY_FILE 2>/dev/null || echo '')\"" >> ~/.zshrc
                log_info "API 키 자동 로드를 ~/.zshrc에 추가했습니다."
            fi
        else
            log_warning "API 키 설정을 건너뜁니다. 나중에 ANTHROPIC_API_KEY 환경 변수를 설정해주세요."
        fi
    else
        log_success "API 키가 이미 설정되어 있습니다."
    fi
}

# 의존성 설치
install_dependencies() {
    log_step "Go 의존성 설치 중..."
    
    cd "$WORKSHOP_DIR"
    
    if [ ! -f "go.mod" ]; then
        log_info "Go 모듈 초기화 중..."
        go mod init coding-agent-workshop
    fi
    
    log_info "의존성 다운로드 중..."
    go mod tidy
    
    log_success "의존성 설치 완료"
}

# 테스트 파일 생성
create_test_files() {
    log_step "테스트 파일 생성 중..."
    
    cd "$WORKSHOP_DIR"
    
    # Python 예제 파일
    cat > test-example.py << 'EOF'
#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Python 예제 파일 - 코딩 에이전트 테스트용
이 파일은 에이전트가 읽고, 편집하고, 분석할 수 있는 샘플 코드입니다.
"""

import math
import time
from typing import List, Optional

def fibonacci(n: int) -> int:
    """
    피보나치 수열의 n번째 값을 계산합니다.
    
    Args:
        n: 계산할 위치 (0 이상의 정수)
        
    Returns:
        n번째 피보나치 수
        
    Raises:
        ValueError: n이 음수인 경우
    """
    if n < 0:
        raise ValueError("n은 0 이상이어야 합니다")
    
    if n <= 1:
        return n
    
    # TODO: 메모이제이션을 추가하여 성능 개선
    return fibonacci(n-1) + fibonacci(n-2)

def prime_numbers(limit: int) -> List[int]:
    """에라토스테네스의 체를 사용하여 소수를 찾습니다."""
    if limit < 2:
        return []
    
    sieve = [True] * (limit + 1)
    sieve[0] = sieve[1] = False
    
    for i in range(2, int(math.sqrt(limit)) + 1):
        if sieve[i]:
            for j in range(i*i, limit + 1, i):
                sieve[j] = False
    
    return [i for i in range(2, limit + 1) if sieve[i]]

class Calculator:
    """간단한 계산기 클래스"""
    
    def __init__(self):
        self.history: List[str] = []
    
    def add(self, a: float, b: float) -> float:
        """두 수를 더합니다."""
        result = a + b
        self.history.append(f"{a} + {b} = {result}")
        return result
    
    def multiply(self, a: float, b: float) -> float:
        """두 수를 곱합니다."""
        result = a * b
        self.history.append(f"{a} * {b} = {result}")
        return result
    
    def get_history(self) -> List[str]:
        """계산 히스토리를 반환합니다."""
        return self.history.copy()

def main():
    """메인 실행 함수"""
    print("🧮 코딩 에이전트 테스트 예제")
    print("=" * 40)
    
    # 피보나치 수열 테스트
    print("\n📊 피보나치 수열 (처음 10개):")
    for i in range(10):
        try:
            fib = fibonacci(i)
            print(f"fibonacci({i}) = {fib}")
        except ValueError as e:
            print(f"에러: {e}")
    
    # 소수 찾기 테스트
    print("\n🔢 100 이하의 소수:")
    primes = prime_numbers(100)
    print(f"총 {len(primes)}개: {primes}")
    
    # 계산기 테스트
    print("\n🧮 계산기 테스트:")
    calc = Calculator()
    print(f"10 + 5 = {calc.add(10, 5)}")
    print(f"7 * 8 = {calc.multiply(7, 8)}")
    print(f"계산 히스토리: {calc.get_history()}")

if __name__ == "__main__":
    main()
EOF

    # JavaScript 예제 파일 (FizzBuzz 개선 버전)
    cat > fizzbuzz-advanced.js << 'EOF'
/**
 * 고급 FizzBuzz 구현
 * 코딩 에이전트 테스트용 JavaScript 파일
 */

/**
 * FizzBuzz 게임을 실행합니다
 * @param {number} max - 최대 숫자
 * @param {Object} rules - 커스텀 규칙 객체
 * @returns {Array<string>} FizzBuzz 결과 배열
 */
function fizzBuzz(max = 100, rules = {}) {
    const defaultRules = {
        3: 'Fizz',
        5: 'Buzz',
        7: 'Bang'  // 추가 규칙
    };
    
    const gameRules = { ...defaultRules, ...rules };
    const result = [];
    
    for (let i = 1; i <= max; i++) {
        let output = '';
        
        // 모든 규칙 확인
        for (const [divisor, word] of Object.entries(gameRules)) {
            if (i % parseInt(divisor) === 0) {
                output += word;
            }
        }
        
        // 규칙에 해당하지 않으면 숫자 추가
        result.push(output || i.toString());
    }
    
    return result;
}

/**
 * 결과를 예쁘게 출력합니다
 * @param {Array<string>} results - FizzBuzz 결과
 * @param {number} columns - 열 개수
 */
function displayResults(results, columns = 10) {
    console.log('🎮 고급 FizzBuzz 결과:');
    console.log('='.repeat(50));
    
    for (let i = 0; i < results.length; i++) {
        process.stdout.write(results[i].padEnd(8));
        
        if ((i + 1) % columns === 0) {
            console.log(); // 새 줄
        }
    }
    
    if (results.length % columns !== 0) {
        console.log(); // 마지막 줄 정리
    }
}

/**
 * 통계를 계산합니다
 * @param {Array<string>} results - FizzBuzz 결과
 * @returns {Object} 통계 정보
 */
function calculateStats(results) {
    const stats = {
        total: results.length,
        fizz: 0,
        buzz: 0,
        fizzBuzz: 0,
        numbers: 0
    };
    
    results.forEach(item => {
        if (item.includes('Fizz') && item.includes('Buzz')) {
            stats.fizzBuzz++;
        } else if (item.includes('Fizz')) {
            stats.fizz++;
        } else if (item.includes('Buzz')) {
            stats.buzz++;
        } else {
            stats.numbers++;
        }
    });
    
    return stats;
}

// 메인 실행
function main() {
    const results = fizzBuzz(30, { 3: 'Fizz', 5: 'Buzz' });
    displayResults(results);
    
    const stats = calculateStats(results);
    console.log('\n📊 통계:');
    console.log(`총 개수: ${stats.total}`);
    console.log(`Fizz: ${stats.fizz}개`);
    console.log(`Buzz: ${stats.buzz}개`);
    console.log(`FizzBuzz: ${stats.fizzBuzz}개`);
    console.log(`숫자: ${stats.numbers}개`);
}

// Node.js에서 직접 실행되는 경우
if (require.main === module) {
    main();
}

module.exports = { fizzBuzz, displayResults, calculateStats };
EOF

    # 수수께끼 파일 (한국어)
    cat > riddle-korean.txt << 'EOF'
🧩 한국 전통 수수께끼 모음

1. 나는 갈기가 있지만 사자가 아니고,
   네 다리가 있지만 테이블이 아니며,
   달릴 수 있지만 사람이 아닙니다.
   나는 무엇일까요?
   
   답: 말

2. 하늘에서 떨어지지만 다치지 않고,
   땅에 닿으면 사라지며,
   겨울에는 하얗고 여름에는 투명합니다.
   나는 무엇일까요?
   
   답: 눈 (雪)

3. 입은 있지만 말하지 못하고,
   귀는 있지만 듣지 못하며,
   머리는 있지만 생각하지 못합니다.
   나는 무엇일까요?
   
   답: 바늘

4. 문은 있지만 들어갈 수 없고,
   창문은 있지만 바라볼 수 없으며,
   지붕은 있지만 비를 막지 못합니다.
   나는 무엇일까요?
   
   답: 책

이 파일은 코딩 에이전트가 한국어 텍스트를 읽고 
분석하는 능력을 테스트하기 위한 샘플입니다.
EOF

    # README 파일
    cat > WORKSHOP_README.md << 'EOF'
# 코딩 에이전트 워크샵 테스트 파일들

이 디렉터리에는 코딩 에이전트의 다양한 기능을 테스트할 수 있는 파일들이 포함되어 있습니다.

## 파일 설명

### 📄 test-example.py
- **목적**: Python 코드 읽기, 편집, 분석 테스트
- **특징**: 함수, 클래스, 타입 힌트, 주석 포함
- **테스트 가능한 기능**:
  - 파일 읽기 (`read_file`)
  - 함수 검색 (`code_search`)
  - 코드 편집 (`edit_file`)
  - TODO 주석 찾기

### 🎮 fizzbuzz-advanced.js
- **목적**: JavaScript 코드 분석 및 실행 테스트
- **특징**: 모듈 시스템, JSDoc, 고급 로직
- **테스트 가능한 기능**:
  - Node.js 실행 테스트 (`bash`)
  - 함수 시그니처 검색
  - 코드 리팩토링

### 🧩 riddle-korean.txt
- **목적**: 한국어 텍스트 처리 테스트
- **특징**: 유니코드, 구조화된 텍스트
- **테스트 가능한 기능**:
  - 텍스트 읽기 및 분석
  - 패턴 검색
  - 내용 요약

## 추천 테스트 시나리오

### 1. 기본 파일 작업
```
에이전트에게 요청: "현재 디렉터리의 모든 파일을 나열해주세요."
예상 결과: list_files 도구 사용하여 파일 목록 표시
```

### 2. 코드 분석
```
에이전트에게 요청: "test-example.py에서 모든 함수를 찾아주세요."
예상 결과: code_search로 def 키워드 검색
```

### 3. 코드 실행
```
에이전트에게 요청: "fizzbuzz-advanced.js를 실행해보세요."
예상 결과: bash 도구로 node fizzbuzz-advanced.js 실행
```

### 4. 텍스트 분석
```
에이전트에게 요청: "riddle-korean.txt의 첫 번째 수수께끼를 읽어주세요."
예상 결과: read_file로 파일 읽고 내용 분석
```

### 5. 코드 편집
```
에이전트에게 요청: "test-example.py의 TODO 주석을 실제 구현으로 바꿔주세요."
예상 결과: edit_file로 메모이제이션 구현 추가
```

## 성공 지표

✅ 모든 파일이 정상적으로 읽히는가?
✅ 코드 검색이 정확한 결과를 반환하는가?
✅ 명령 실행이 올바른 출력을 생성하는가?
✅ 파일 편집이 의도한 대로 동작하는가?
✅ 에러 처리가 적절히 작동하는가?

이 테스트 파일들을 통해 코딩 에이전트의 모든 핵심 기능을 체계적으로 검증할 수 있습니다.
EOF

    log_success "테스트 파일 생성 완료"
}

# 기능 테스트 실행
run_functionality_tests() {
    log_step "기능 테스트 실행 중..."
    
    cd "$WORKSHOP_DIR"
    
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        log_warning "API 키가 설정되지 않아 기능 테스트를 건너뜁니다."
        return 0
    fi
    
    # 컴파일 테스트
    log_info "Go 애플리케이션 컴파일 테스트..."
    
    local apps=("chat.go" "read.go" "list_files.go" "bash_tool.go" "edit_tool.go" "code_search_tool.go")
    
    for app in "${apps[@]}"; do
        if [ -f "$app" ]; then
            if go build -o "/tmp/test_${app%.go}" "$app" 2>/dev/null; then
                log_success "✓ $app 컴파일 성공"
                rm -f "/tmp/test_${app%.go}"
            else
                log_error "✗ $app 컴파일 실패"
            fi
        else
            log_warning "⚠ $app 파일이 존재하지 않음"
        fi
    done
    
    # Python 스크립트 실행 테스트
    if command -v python3 &> /dev/null; then
        log_info "Python 스크립트 테스트..."
        if python3 test-example.py > /dev/null 2>&1; then
            log_success "✓ test-example.py 실행 성공"
        else
            log_error "✗ test-example.py 실행 실패"
        fi
    fi
    
    # JavaScript 스크립트 실행 테스트
    if command -v node &> /dev/null; then
        log_info "JavaScript 스크립트 테스트..."
        if node fizzbuzz-advanced.js > /dev/null 2>&1; then
            log_success "✓ fizzbuzz-advanced.js 실행 성공"
        else
            log_error "✗ fizzbuzz-advanced.js 실행 실패"
        fi
    else
        log_info "Node.js가 설치되어 있지 않아 JavaScript 테스트를 건너뜁니다."
    fi
    
    # Ripgrep 테스트
    if command -v rg &> /dev/null; then
        log_info "Ripgrep 기능 테스트..."
        if rg "def " test-example.py > /dev/null 2>&1; then
            log_success "✓ Ripgrep 검색 성공"
        else
            log_error "✗ Ripgrep 검색 실패"
        fi
    fi
}

# 사용법 안내
show_usage_guide() {
    log_step "사용법 안내"
    
    echo -e "\n${CYAN}🚀 워크샵 시작 가이드${NC}"
    echo "=================================="
    
    echo -e "\n${YELLOW}📁 워크샵 디렉터리:${NC}"
    echo "   $WORKSHOP_DIR"
    
    echo -e "\n${YELLOW}🔧 환경 설정:${NC}"
    echo "   cd $WORKSHOP_DIR"
    echo "   source ~/.zshrc  # 환경 변수 새로고침"
    
    echo -e "\n${YELLOW}🎯 단계별 실행 방법:${NC}"
    echo "   1. 기본 채팅:     go run chat.go"
    echo "   2. 파일 읽기:     go run read.go"
    echo "   3. 파일 목록:     go run list_files.go"
    echo "   4. 명령 실행:     go run bash_tool.go"
    echo "   5. 파일 편집:     go run edit_tool.go"
    echo "   6. 코드 검색:     go run code_search_tool.go"
    
    echo -e "\n${YELLOW}🔍 디버깅 모드:${NC}"
    echo "   go run [앱이름] --verbose"
    echo "   예: go run edit_tool.go --verbose"
    
    echo -e "\n${YELLOW}📝 테스트 시나리오 예제:${NC}"
    echo "   • \"현재 디렉터리의 파일을 나열해주세요\""
    echo "   • \"test-example.py 파일을 읽어주세요\""
    echo "   • \"Python 파일에서 def 키워드를 찾아주세요\""
    echo "   • \"fizzbuzz-advanced.js를 실행해주세요\""
    echo "   • \"riddle-korean.txt의 첫 번째 수수께끼를 알려주세요\""
    
    echo -e "\n${YELLOW}❓ 도움말:${NC}"
    echo "   • GitHub 저장소: https://github.com/ghuntley/how-to-build-a-coding-agent"
    echo "   • 블로그 포스트: https://thakicloud.github.io"
    echo "   • API 키 설정: echo 'your-key' > $API_KEY_FILE"
    
    if [ -z "$ANTHROPIC_API_KEY" ]; then
        echo -e "\n${RED}⚠️  중요: Anthropic API 키가 설정되지 않았습니다!${NC}"
        echo -e "   다음 명령으로 설정하세요:"
        echo -e "   ${CYAN}export ANTHROPIC_API_KEY='your-api-key-here'${NC}"
    fi
    
    echo -e "\n${GREEN}✨ 설정이 완료되었습니다! 즐거운 학습되세요! ✨${NC}\n"
}

# 메인 실행 함수
main() {
    echo -e "${BLUE}🏁 설정 시작...${NC}\n"
    
    check_system_requirements
    setup_go
    setup_ripgrep
    clone_workshop
    setup_api_key
    install_dependencies
    create_test_files
    run_functionality_tests
    
    echo -e "\n${GREEN}🎉 모든 설정이 완료되었습니다!${NC}\n"
    
    show_usage_guide
}

# 에러 트랩 설정
trap 'log_error "스크립트 실행 중 오류가 발생했습니다. 라인 $LINENO에서 중단되었습니다."' ERR

# 메인 함수 실행
main "$@"
