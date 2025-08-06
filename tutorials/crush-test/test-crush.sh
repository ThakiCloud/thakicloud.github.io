#!/bin/bash

# Crush AI Coding Agent 테스트 스크립트
# macOS 환경에서 실행 가능

echo "🤖 Crush AI Coding Agent 테스트 시작"
echo "==============================================="

# 1. 기본 환경 확인
echo "1. 환경 확인"
echo "   OS: $(uname -s)"
echo "   아키텍처: $(uname -m)"
echo "   Crush 버전: $(crush --version)"
echo "   현재 디렉토리: $(pwd)"
echo ""

# 2. Crush 명령어 확인
echo "2. Crush 기본 명령어 테스트"
echo "   - 도움말 확인 (crush --help)"
echo "   - 버전 확인 (crush --version)"
echo "   - 로그 명령어 확인 (crush logs --help)"
echo ""

# 3. 테스트 프로젝트 설정
echo "3. 테스트 프로젝트 설정"
cat > main.py << 'EOF'
def fibonacci(n):
    """피보나치 수열을 계산하는 함수"""
    if n <= 1:
        return n
    return fibonacci(n-1) + fibonacci(n-2)

def main():
    """메인 함수"""
    n = 10
    print(f"피보나치({n}) = {fibonacci(n)}")

if __name__ == "__main__":
    main()
EOF

echo "   ✅ Python 테스트 파일 생성 완료"
echo ""

# 4. 설정 파일 예제 생성
echo "4. Crush 설정 파일 예제"
cat > .crush.json << 'EOF'
{
  "$schema": "https://charm.land/crush.json",
  "options": {
    "debug": false
  },
  "permissions": {
    "allowed_tools": [
      "view",
      "ls",
      "grep"
    ]
  }
}
EOF

echo "   ✅ 설정 파일 (.crush.json) 생성 완료"
echo ""

# 5. 실행 가이드
echo "5. Crush 실행 가이드"
echo "   ⚠️  API 키 설정이 필요합니다:"
echo "   - OpenAI: export OPENAI_API_KEY='your-key'"
echo "   - Anthropic: export ANTHROPIC_API_KEY='your-key'"
echo "   - Groq: export GROQ_API_KEY='your-key'"
echo ""
echo "   🚀 실행 명령어:"
echo "   - 대화형 모드: crush"
echo "   - 단일 질문: crush run \"코드를 리뷰해주세요\""
echo "   - 디버그 모드: crush -d"
echo ""

echo "✅ Crush 테스트 환경 구성 완료!"
echo "💡 API 키를 설정한 후 'crush' 명령어로 시작하세요."