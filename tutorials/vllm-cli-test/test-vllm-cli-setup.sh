#!/bin/bash

# vLLM CLI 테스트 스크립트
# macOS에서 vLLM CLI 설치 및 기본 기능 테스트

echo "🚀 vLLM CLI 테스트 시작"
echo "==========================="

# 현재 환경 정보 출력
echo "📍 현재 디렉토리: $(pwd)"
echo "🐍 Python 버전: $(python --version)"
echo "💻 시스템: $(uname -s) $(uname -m)"

# 1. 현재 설치 상태 확인
echo -e "\n1️⃣ vLLM CLI 설치 상태 확인"
echo "--------------------------------"

if command -v vllm-cli &> /dev/null; then
    echo "✅ vLLM CLI가 이미 설치되어 있습니다."
    echo "📦 버전 정보:"
    vllm-cli --version 2>/dev/null || echo "버전 정보를 가져올 수 없습니다."
else
    echo "❌ vLLM CLI가 설치되지 않았습니다."
    echo "💡 설치 방법:"
    echo "   pip install vllm-cli"
    
    # 설치 옵션 제시
    read -p "지금 설치하시겠습니까? (y/n): " install_choice
    if [[ $install_choice == "y" || $install_choice == "Y" ]]; then
        echo "📦 vLLM CLI 설치 중..."
        pip install vllm-cli
        
        if [[ $? -eq 0 ]]; then
            echo "✅ 설치 완료!"
        else
            echo "❌ 설치 실패"
            exit 1
        fi
    else
        echo "⏭️  설치를 건너뜁니다."
        echo "💡 수동 설치 후 다시 실행해주세요."
        exit 0
    fi
fi

# 2. 기본 의존성 확인
echo -e "\n2️⃣ 의존성 패키지 확인"
echo "------------------------"

# Python 패키지 확인 함수
check_package() {
    local package=$1
    if pip list | grep -q "^$package "; then
        local version=$(pip list | grep "^$package " | awk '{print $2}')
        echo "✅ $package ($version)"
        return 0
    else
        echo "❌ $package (미설치)"
        return 1
    fi
}

echo "📦 필수 패키지 상태:"
check_package "torch" && TORCH_OK=1 || TORCH_OK=0
check_package "transformers" && TRANSFORMERS_OK=1 || TRANSFORMERS_OK=0
check_package "vllm" && VLLM_OK=1 || VLLM_OK=0

# 3. 시스템 정보 확인
echo -e "\n3️⃣ 시스템 정보 확인"
echo "--------------------"

if command -v vllm-cli &> /dev/null; then
    echo "🖥️  시스템 정보:"
    vllm-cli info 2>/dev/null || echo "시스템 정보를 가져올 수 없습니다."
else
    echo "⚠️  vLLM CLI가 설치되지 않아 시스템 정보를 확인할 수 없습니다."
fi

# 4. GPU 확인 (CUDA/MPS)
echo -e "\n4️⃣ GPU 지원 확인"
echo "-----------------"

# CUDA 확인
if command -v nvidia-smi &> /dev/null; then
    echo "🟢 NVIDIA GPU 감지됨:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader
else
    echo "🔴 NVIDIA GPU가 감지되지 않았습니다."
fi

# MPS (Apple Silicon) 확인
if python -c "import torch; print('🍎 Apple MPS 사용 가능:', torch.backends.mps.is_available())" 2>/dev/null; then
    python -c "import torch; print('🍎 Apple MPS 사용 가능:', torch.backends.mps.is_available())" 2>/dev/null
else
    echo "🔴 Apple MPS를 확인할 수 없습니다."
fi

# 5. 모델 목록 확인 (간단히)
echo -e "\n5️⃣ 사용 가능한 모델 확인"
echo "--------------------------"

if command -v vllm-cli &> /dev/null; then
    echo "🤖 로컬 모델 목록 (상위 5개):"
    vllm-cli models --local-only 2>/dev/null | head -5 || echo "모델 목록을 가져올 수 없습니다."
else
    echo "⚠️  vLLM CLI가 설치되지 않아 모델 목록을 확인할 수 없습니다."
fi

# 6. 테스트 요약
echo -e "\n📊 테스트 요약"
echo "=============="

if command -v vllm-cli &> /dev/null; then
    echo "✅ vLLM CLI: 설치됨"
else
    echo "❌ vLLM CLI: 미설치"
fi

if [[ $TORCH_OK -eq 1 ]]; then
    echo "✅ PyTorch: 설치됨"
else
    echo "❌ PyTorch: 미설치"
fi

if [[ $VLLM_OK -eq 1 ]]; then
    echo "✅ vLLM: 설치됨"
else
    echo "❌ vLLM: 미설치"
fi

# 7. 별칭 설정 가이드
echo -e "\n🔧 유용한 별칭 설정"
echo "==================="

cat << 'EOF'
다음 별칭을 ~/.zshrc에 추가하면 편리합니다:

# vLLM CLI 별칭
alias vllm="vllm-cli"
alias vserve="vllm-cli serve"
alias vstatus="vllm-cli status"
alias vmodels="vllm-cli models"
alias vinfo="vllm-cli info"
alias vlogs="vllm-cli logs"

# 프로필 별칭
alias vquick="vllm-cli serve --profile standard"
alias vfast="vllm-cli serve --profile high_throughput"
alias vmem="vllm-cli serve --profile low_memory"

적용 방법:
echo "위 별칭들" >> ~/.zshrc
source ~/.zshrc
EOF

echo -e "\n🎉 테스트 완료!"
echo "================"

# 다음 단계 안내
echo "📝 다음 단계:"
echo "1. 필요한 패키지가 누락되었다면 설치해주세요"
echo "2. 별칭을 설정하여 사용 편의성을 높이세요"
echo "3. 간단한 모델로 서빙 테스트를 진행해보세요"
echo ""
echo "🔗 도움말:"
echo "- vLLM CLI GitHub: https://github.com/Chen-zexi/vllm-cli"
echo "- vLLM 공식 문서: https://docs.vllm.ai/"
