#!/bin/bash
# LangExtract 설치 및 설정 스크립트

echo "🚀 LangExtract 설치 시작"

# 가상환경 생성 (선택사항)
read -p "가상환경을 생성하시겠습니까? (y/n): " create_venv
if [ "$create_venv" = "y" ]; then
    python -m venv langextract_env
    source langextract_env/bin/activate
    echo "✅ 가상환경 생성 및 활성화 완료"
fi

# LangExtract 설치
pip install langextract

# API 키 설정 가이드
echo ""
echo "🔑 API 키 설정이 필요합니다:"
echo "1. Gemini API: https://ai.google.dev/"
echo "2. OpenAI API: https://platform.openai.com/"
echo ""
echo "API 키를 받은 후 다음 중 하나를 선택하세요:"
echo ""
echo "방법 1: 환경변수 설정"
echo "export LANGEXTRACT_API_KEY='your-api-key'"
echo ""
echo "방법 2: .env 파일 생성"
echo "echo 'LANGEXTRACT_API_KEY=your-api-key' > .env"
echo ""

# 테스트 실행
echo "📋 설치 확인 테스트 실행..."
python test_langextract_basic.py

echo "✅ LangExtract 설치 완료!"
