#!/bin/bash

# EmbedPDF 테스트 설정 스크립트
echo "🔗 EmbedPDF 테스트 환경 설정 중..."

# 현재 디렉토리 확인
CURRENT_DIR=$(pwd)
echo "현재 디렉토리: $CURRENT_DIR"

# 필요한 패키지 설치 확인
if [ ! -d "node_modules" ]; then
    echo "📦 npm 패키지 설치 중..."
    npm install
fi

# 개발 서버 포트 확인
echo "🔍 포트 3000 사용 여부 확인 중..."
if lsof -Pi :3000 -sTCP:LISTEN -t >/dev/null ; then
    echo "⚠️  포트 3000이 이미 사용 중입니다."
    echo "다른 프로세스를 종료하거나 다른 포트를 사용하세요."
else
    echo "✅ 포트 3000 사용 가능"
fi

# 개발 환경 정보 출력
echo ""
echo "🛠️  개발 환경 정보:"
echo "Node.js: $(node --version)"
echo "npm: $(npm --version)"

# 사용 가능한 명령어 안내
echo ""
echo "📚 사용 가능한 명령어:"
echo "npm run dev        # React 개발 서버 시작 (포트 3000)"
echo "npm run build      # 프로덕션 빌드"
echo "open vanilla-example.html  # Vanilla JS 예제 열기"

# zshrc alias 추가 제안
echo ""
echo "💡 zshrc에 추가할 수 있는 alias:"
echo "alias embedpdf-dev='cd $CURRENT_DIR && npm run dev'"
echo "alias embedpdf-vanilla='cd $CURRENT_DIR && open vanilla-example.html'"

# 실행 권한 부여
chmod +x setup-aliases.sh

echo ""
echo "✅ EmbedPDF 테스트 환경 설정 완료!"
echo "React 예제 실행: npm run dev"
echo "Vanilla JS 예제: vanilla-example.html 파일을 브라우저에서 열기"
