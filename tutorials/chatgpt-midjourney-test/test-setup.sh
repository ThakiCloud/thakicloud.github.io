#!/bin/bash

# ChatGPT Web Midjourney Proxy 테스트 설정 스크립트
# macOS 개발환경 버전: Docker 28.2.2, Node.js v22.17.1, npm 10.9.2

set -e

echo "🚀 ChatGPT Web Midjourney Proxy 테스트 환경 설정 시작..."

# 프로젝트 디렉토리로 이동
cd chatgpt-web-midjourney-proxy

echo "📦 의존성 설치 중..."
# pnpm 설치 (없는 경우)
if ! command -v pnpm &> /dev/null; then
    echo "pnpm 설치 중..."
    npm install -g pnpm
fi

# 프로젝트 의존성 설치
pnpm install

echo "🐳 Docker 환경 설정 중..."

# Docker 서비스 상태 확인
if ! docker info &> /dev/null; then
    echo "❌ Docker가 실행되지 않았습니다. Docker Desktop을 시작해주세요."
    exit 1
fi

echo "⚙️ 환경변수 설정 중..."

# 테스트용 환경변수 파일 생성
cat > .env.local << EOF
# 로컬 테스트용 환경변수
VITE_GLOB_API_URL=/api
VITE_APP_API_BASE_URL=http://127.0.0.1:3002
VITE_GLOB_OPEN_LONG_REPLY=false
VITE_GLOB_APP_PWA=false

# 테스트용 OpenAI 설정 (실제 키는 별도 설정 필요)
OPENAI_API_KEY=sk-test-key-replace-with-real-key
OPENAI_API_BASE_URL=https://api.openai.com
OPENAI_API_MODEL=gpt-3.5-turbo

# 테스트용 보안 키
AUTH_SECRET_KEY=test-secret-key

# UI 설정
SYS_THEME=dark
UPLOAD_IMG_SIZE=1
EOF

echo "📋 Docker Compose 설정 확인..."
cp docker-compose/docker-compose.yml docker-compose-test.yml

echo "✅ 테스트 환경 설정 완료!"
echo ""
echo "📝 다음 단계:"
echo "1. .env.local 파일에서 실제 OpenAI API 키 설정"
echo "2. Docker Compose로 서비스 시작: docker-compose -f docker-compose-test.yml up -d"
echo "3. 개발 서버 실행: pnpm dev"
echo "4. 브라우저에서 http://localhost:3000 접속"
echo ""
echo "🔗 주요 포트:"
echo "- 프론트엔드: http://localhost:3000"
echo "- API 서버: http://localhost:3002"
echo "- Docker 컨테이너: http://localhost:6050"
