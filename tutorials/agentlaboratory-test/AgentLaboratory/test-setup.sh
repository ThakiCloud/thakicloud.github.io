#!/bin/bash

echo "🔬 Agent Laboratory 테스트 설정 스크립트"
echo "========================================"

# 현재 디렉토리 확인
echo "📁 현재 작업 디렉토리: $(pwd)"

# Python 버전 확인
echo "🐍 Python 버전: $(python --version)"

# 가상환경 활성화 상태 확인
if [[ "$VIRTUAL_ENV" != "" ]]; then
    echo "✅ 가상환경 활성화됨: $VIRTUAL_ENV"
else
    echo "⚠️  가상환경이 활성화되지 않음. 활성화 중..."
    source venv_agent_lab/bin/activate
fi

# 필수 패키지 확인
echo "📦 필수 패키지 설치 확인..."
python -c "import torch; print(f'✅ PyTorch: {torch.__version__}')" 2>/dev/null || echo "❌ PyTorch 설치 필요"
python -c "import transformers; print(f'✅ Transformers: {transformers.__version__}')" 2>/dev/null || echo "❌ Transformers 설치 필요"
python -c "import openai; print(f'✅ OpenAI: {openai.__version__}')" 2>/dev/null || echo "❌ OpenAI 설치 필요"

# 설정 파일들 확인
echo "📋 설정 파일 확인..."
if [ -f "experiment_configs/MATH_agentlab.yaml" ]; then
    echo "✅ MATH 실험 설정 파일 존재"
else
    echo "❌ MATH 실험 설정 파일 없음"
fi

# API 키 설정 안내
echo ""
echo "🔑 API 키 설정 안내:"
echo "   - OpenAI API 키가 필요합니다"
echo "   - experiment_configs/MATH_agentlab.yaml 파일에서 'OPENAI-API-KEY-HERE'를 실제 키로 교체하세요"
echo "   - 또는 DeepSeek API 키를 사용할 수 있습니다"

echo ""
echo "🚀 테스트 실행 준비 완료!"
echo "   다음 명령어로 Agent Laboratory를 실행할 수 있습니다:"
echo "   python ai_lab_repo.py --yaml-location experiment_configs/MATH_agentlab.yaml"

