#!/bin/bash

# Chatterbox-vLLM 테스트 스크립트
# 작성자: Thaki Cloud
# 날짜: 2025-08-05

set -e  # 오류 발생 시 스크립트 중단

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로깅 함수
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# 프로젝트 디렉토리 설정
PROJECT_DIR="$HOME/ai-projects/chatterbox-vllm-test"
VENV_NAME="chatterbox-vllm-env"

echo "🎙️ Chatterbox-vLLM 테스트 시작"
echo "================================"

# 1. 시스템 요구사항 확인
log_info "시스템 정보 확인 중..."
echo "📱 OS: $(sw_vers -productName) $(sw_vers -productVersion)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Python3 not found')"
echo "💻 Architecture: $(uname -m)"

# GPU 확인 (NVIDIA GPU가 있는 경우)
if command -v nvidia-smi &> /dev/null; then
    echo "🎮 GPU 정보:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | head -1
else
    log_warning "NVIDIA GPU 감지되지 않음 (CPU 모드로 테스트)"
fi

# 2. Python 환경 확인
if ! command -v python3 &> /dev/null; then
    log_error "Python3가 설치되어 있지 않습니다."
    log_info "Homebrew를 통해 Python 설치:"
    echo "brew install python"
    exit 1
fi

# 3. 프로젝트 디렉토리 생성
log_info "프로젝트 디렉토리 설정 중..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 4. 가상환경 생성 및 활성화
if [ ! -d "$VENV_NAME" ]; then
    log_info "Python 가상환경 생성 중..."
    python3 -m venv "$VENV_NAME"
fi

log_info "가상환경 활성화 중..."
source "$VENV_NAME/bin/activate"

# 5. 저장소 클론 (아직 없는 경우)
if [ ! -d "chatterbox-vllm" ]; then
    log_info "Chatterbox-vLLM 저장소 클론 중..."
    git clone https://github.com/randombk/chatterbox-vllm.git
else
    log_info "기존 저장소 업데이트 중..."
    cd chatterbox-vllm
    git pull origin master
    cd ..
fi

cd chatterbox-vllm

# 6. 의존성 설치
log_info "의존성 설치 중..."
pip install --upgrade pip

# CPU 전용 PyTorch 설치 (macOS M1/M2에서 권장)
if [[ $(uname -m) == "arm64" ]]; then
    log_info "Apple Silicon용 PyTorch 설치 중..."
    pip install torch torchvision torchaudio
else
    log_info "Intel Mac용 PyTorch 설치 중..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
fi

# 7. 프로젝트 설치
log_info "Chatterbox-vLLM 설치 중..."
if pip install -e .; then
    log_success "설치 완료"
else
    log_error "설치 실패"
    log_info "의존성을 개별적으로 설치해보겠습니다..."
    
    # 필수 패키지 개별 설치
    pip install transformers
    pip install vllm
    pip install gradio
    pip install soundfile
    pip install librosa
    pip install numpy
fi

# 8. 추가 의존성 설치
log_info "추가 의존성 설치 중..."
pip install huggingface_hub

# 9. 테스트 스크립트 생성
log_info "테스트 스크립트 생성 중..."

# 기본 테스트 스크립트
cat > test_basic.py << 'EOF'
#!/usr/bin/env python3
"""
Chatterbox-vLLM 기본 기능 테스트
"""

import sys
import time

def test_imports():
    """패키지 import 테스트"""
    print("📦 패키지 import 테스트...")
    
    try:
        import torch
        print(f"  ✅ PyTorch {torch.__version__}")
        print(f"  🔧 CUDA 사용 가능: {torch.cuda.is_available()}")
        if torch.backends.mps.is_available():
            print("  🍎 MPS(Metal) 사용 가능: True")
    except ImportError as e:
        print(f"  ❌ PyTorch import 실패: {e}")
        return False
    
    try:
        import transformers
        print(f"  ✅ Transformers {transformers.__version__}")
    except ImportError as e:
        print(f"  ❌ Transformers import 실패: {e}")
        return False
    
    try:
        import vllm
        print(f"  ✅ vLLM {vllm.__version__}")
    except ImportError as e:
        print(f"  ❌ vLLM import 실패: {e}")
        return False
    
    try:
        import soundfile
        print("  ✅ SoundFile")
    except ImportError as e:
        print(f"  ❌ SoundFile import 실패: {e}")
        return False
    
    return True

def test_model_loading():
    """모델 로딩 테스트 (실제 다운로드 없이)"""
    print("\n🤖 모델 로딩 테스트...")
    
    try:
        # Chatterbox-vLLM 모듈 import 시도
        from chatterbox_vllm import ChatterboxVLLM
        print("  ✅ ChatterboxVLLM 모듈 import 성공")
        return True
    except ImportError as e:
        print(f"  ❌ ChatterboxVLLM import 실패: {e}")
        print("  💡 이는 정상적인 현상일 수 있습니다 (모델 파일이 없는 경우)")
        return False

def test_gradio():
    """Gradio 인터페이스 테스트"""
    print("\n🌐 Gradio 인터페이스 테스트...")
    
    try:
        import gradio as gr
        
        # 간단한 인터페이스 생성 테스트
        def hello(name):
            return f"안녕하세요, {name}님!"
        
        iface = gr.Interface(
            fn=hello,
            inputs="text",
            outputs="text",
            title="Chatterbox-vLLM 테스트"
        )
        
        print("  ✅ Gradio 인터페이스 생성 성공")
        print("  💡 실제 서버는 실행하지 않습니다")
        return True
        
    except Exception as e:
        print(f"  ❌ Gradio 테스트 실패: {e}")
        return False

def main():
    print("🧪 Chatterbox-vLLM 환경 테스트 시작\n")
    
    results = []
    
    # 테스트 실행
    results.append(("Import 테스트", test_imports()))
    results.append(("모델 로딩 테스트", test_model_loading()))
    results.append(("Gradio 테스트", test_gradio()))
    
    # 결과 출력
    print("\n📊 테스트 결과 요약:")
    print("=" * 40)
    
    passed = 0
    total = len(results)
    
    for name, result in results:
        status = "✅ PASS" if result else "❌ FAIL"
        print(f"{name}: {status}")
        if result:
            passed += 1
    
    print("=" * 40)
    print(f"통과: {passed}/{total}")
    
    if passed == total:
        print("\n🎉 모든 테스트 통과!")
        print("💡 이제 모델을 다운로드하고 실제 TTS 기능을 테스트할 수 있습니다.")
    else:
        print("\n⚠️  일부 테스트 실패")
        print("💡 의존성을 다시 설치하거나 환경을 확인해보세요.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

# 10. 테스트 실행
log_info "기본 환경 테스트 실행 중..."
if python test_basic.py; then
    log_success "기본 환경 테스트 통과!"
else
    log_warning "일부 테스트 실패, 하지만 계속 진행합니다."
fi

# 11. 사용법 안내
echo ""
echo "🎯 다음 단계:"
echo "============="
echo "1. 모델 다운로드:"
echo "   python -c \"from huggingface_hub import snapshot_download; snapshot_download(repo_id='chatterbox/chatterbox-vllm', local_dir='./models')\""
echo ""
echo "2. 기본 TTS 테스트:"
echo "   python example-tts.py"
echo ""
echo "3. 웹 인터페이스 실행:"
echo "   python gradio_tts_app.py"
echo ""
echo "4. 벤치마크 실행:"
echo "   python benchmark.py"
echo ""

# 12. 별칭 설정 안내
echo "🔧 zshrc 별칭 설정 (선택사항):"
echo "=============================="
cat << 'EOF'
# ~/.zshrc에 추가할 별칭들
alias chatterbox-vllm="cd ~/ai-projects/chatterbox-vllm-test/chatterbox-vllm && source ../chatterbox-vllm-env/bin/activate"
alias cvllm-test="cd ~/ai-projects/chatterbox-vllm-test/chatterbox-vllm && python test_basic.py"
alias cvllm-gradio="cd ~/ai-projects/chatterbox-vllm-test/chatterbox-vllm && python gradio_tts_app.py"
alias cvllm-bench="cd ~/ai-projects/chatterbox-vllm-test/chatterbox-vllm && python benchmark.py"
EOF

echo ""
log_success "Chatterbox-vLLM 환경 설정 완료!"
echo "📁 프로젝트 위치: $PROJECT_DIR/chatterbox-vllm"
echo "🐍 가상환경: $PROJECT_DIR/$VENV_NAME"
echo ""
echo "🚀 실제 사용을 위해서는 GPU가 있는 환경을 권장합니다."
echo "💻 macOS에서는 CPU 모드로도 테스트 가능하지만 속도가 느릴 수 있습니다."