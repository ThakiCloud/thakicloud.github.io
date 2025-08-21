#!/bin/bash

# Firecrawl Tutorial Setup Script
# 작성자: Thaki Cloud
# 날짜: 2025-08-21

echo "🔥 Firecrawl 튜토리얼 환경 설정을 시작합니다..."

# 가상환경 생성 및 활성화
echo "📦 Python 가상환경 생성 중..."
python3 -m venv firecrawl-venv
source firecrawl-venv/bin/activate

# Python 패키지 설치
echo "🐍 Python SDK 설치 중..."
pip install firecrawl-py pydantic

# Node.js 프로젝트 초기화
echo "📋 Node.js 프로젝트 초기화 중..."
npm init -y
npm install @mendable/firecrawl-js zod

# 환경 변수 파일 생성
echo "🔑 환경 변수 템플릿 생성 중..."
cat > .env.example << 'EOF'
# Firecrawl API Key - https://firecrawl.dev에서 발급
FIRECRAWL_API_KEY=fc-YOUR_API_KEY

# 테스트할 웹사이트 URLs
TEST_URL_1=https://firecrawl.dev
TEST_URL_2=https://news.ycombinator.com
TEST_URL_3=https://docs.firecrawl.dev
EOF

echo "✅ 설정 완료!"
echo ""
echo "다음 단계:"
echo "1. https://firecrawl.dev에서 API 키를 발급받으세요"
echo "2. .env.example을 .env로 복사하고 API 키를 입력하세요"
echo "3. source firecrawl-venv/bin/activate로 가상환경을 활성화하세요"
echo "4. python test-python-sdk.py로 Python 테스트를 실행하세요"
echo "5. node test-nodejs-sdk.js로 Node.js 테스트를 실행하세요"
