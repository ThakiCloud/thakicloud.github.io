#!/bin/bash

# Qwen-Image 테스트 스크립트
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
PROJECT_DIR="$HOME/ai-projects/qwen-image"
VENV_NAME="qwen-image-env"

echo "🎨 Qwen-Image 환경 테스트 시작"
echo "==============================="

# 1. 시스템 요구사항 확인
log_info "시스템 정보 확인 중..."
echo "📱 OS: $(sw_vers -productName 2>/dev/null || uname -s) $(sw_vers -productVersion 2>/dev/null || uname -r)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Python3 not found')"
echo "💻 Architecture: $(uname -m)"

# GPU 확인
if command -v nvidia-smi &> /dev/null; then
    echo "🎮 NVIDIA GPU:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | head -1
elif python3 -c "import torch; print('🍎 MPS Available:', torch.backends.mps.is_available())" 2>/dev/null; then
    echo "🍎 Apple Silicon MPS 지원"
else
    log_warning "GPU 가속 사용 불가 (CPU 모드)"
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

# 5. 의존성 설치
log_info "의존성 설치 중..."
pip install --upgrade pip

# PyTorch 설치
if [[ $(uname -m) == "arm64" ]] && [[ $(uname -s) == "Darwin" ]]; then
    log_info "Apple Silicon용 PyTorch 설치 중..."
    pip install torch torchvision torchaudio
else
    log_info "CUDA/CPU PyTorch 설치 중..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
fi

# Diffusers 및 기타 의존성
log_info "Diffusers 및 관련 패키지 설치 중..."
pip install git+https://github.com/huggingface/diffusers
pip install transformers accelerate safetensors
pip install pillow numpy matplotlib huggingface_hub
pip install fastapi uvicorn  # API 서버용

# 6. 기본 테스트 스크립트 생성
log_info "테스트 스크립트 생성 중..."

cat > test_qwen_image.py << 'EOF'
#!/usr/bin/env python3
"""
Qwen-Image 기본 기능 테스트
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
        from diffusers import DiffusionPipeline
        print("  ✅ Diffusers (DiffusionPipeline)")
    except ImportError as e:
        print(f"  ❌ Diffusers import 실패: {e}")
        return False
    
    try:
        from PIL import Image
        print("  ✅ Pillow (PIL)")
    except ImportError as e:
        print(f"  ❌ Pillow import 실패: {e}")
        return False
    
    try:
        import numpy as np
        print(f"  ✅ NumPy {np.__version__}")
    except ImportError as e:
        print(f"  ❌ NumPy import 실패: {e}")
        return False
    
    return True

def test_model_access():
    """Qwen-Image 모델 접근 테스트"""
    print("\n🤖 모델 접근 테스트...")
    
    try:
        from huggingface_hub import model_info
        info = model_info("Qwen/Qwen-Image")
        print(f"  ✅ 모델 정보 확인: {info.modelId}")
        print(f"  📊 모델 크기: {info.siblings[0].size if info.siblings else 'Unknown'}")
        print(f"  📅 업데이트: {info.lastModified}")
        return True
    except Exception as e:
        print(f"  ❌ 모델 접근 실패: {e}")
        print("  💡 네트워크 연결이나 Hugging Face 토큰을 확인하세요")
        return False

def test_device_setup():
    """디바이스 설정 테스트"""
    print("\n💻 디바이스 설정 테스트...")
    
    try:
        import torch
        
        # 최적 디바이스 선택
        if torch.cuda.is_available():
            device = "cuda"
            dtype = torch.bfloat16
            gpu_name = torch.cuda.get_device_name()
            gpu_memory = torch.cuda.get_device_properties(0).total_memory / 1e9
            print(f"  🎮 CUDA 디바이스: {gpu_name}")
            print(f"  💾 GPU 메모리: {gpu_memory:.1f}GB")
        elif torch.backends.mps.is_available():
            device = "mps"
            dtype = torch.float32
            print("  🍎 MPS 디바이스 (Apple Silicon)")
        else:
            device = "cpu"
            dtype = torch.float32
            print("  💻 CPU 디바이스")
        
        print(f"  🔧 선택된 디바이스: {device}")
        print(f"  📊 데이터 타입: {dtype}")
        
        # 메모리 테스트
        test_tensor = torch.randn(100, 100, dtype=dtype, device=device)
        del test_tensor
        print("  ✅ 메모리 할당 테스트 통과")
        
        return True
    except Exception as e:
        print(f"  ❌ 디바이스 설정 실패: {e}")
        return False

def test_api_dependencies():
    """API 서버 의존성 테스트"""
    print("\n🌐 API 의존성 테스트...")
    
    try:
        import fastapi
        print(f"  ✅ FastAPI {fastapi.__version__}")
        
        import uvicorn
        print("  ✅ Uvicorn")
        
        from pydantic import BaseModel
        print("  ✅ Pydantic")
        
        return True
    except ImportError as e:
        print(f"  ❌ API 의존성 실패: {e}")
        return False

def main():
    print("🎨 Qwen-Image 환경 테스트\n")
    
    results = []
    
    # 테스트 실행
    results.append(("Import 테스트", test_imports()))
    results.append(("모델 접근 테스트", test_model_access()))
    results.append(("디바이스 설정 테스트", test_device_setup()))
    results.append(("API 의존성 테스트", test_api_dependencies()))
    
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
        print("💡 이제 실제 이미지 생성을 테스트할 수 있습니다.")
        print("\n📝 다음 단계:")
        print("  1. python basic_generation.py  # 기본 이미지 생성")
        print("  2. python web_service.py       # API 서버 실행")
        print("  3. python api_client.py        # API 클라이언트 테스트")
    else:
        print("\n⚠️ 일부 테스트 실패")
        print("💡 의존성을 다시 설치하거나 환경을 확인해보세요.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

# 7. 기본 생성 스크립트 생성
log_info "기본 생성 스크립트 생성 중..."

cat > basic_generation.py << 'EOF'
#!/usr/bin/env python3
"""
Qwen-Image 기본 이미지 생성 예제
"""

from diffusers import DiffusionPipeline
import torch
import time

def setup_qwen_image():
    """Qwen-Image 파이프라인 초기화"""
    
    model_name = "Qwen/Qwen-Image"
    
    # 디바이스 및 데이터 타입 설정
    if torch.cuda.is_available():
        torch_dtype = torch.bfloat16
        device = "cuda"
    elif torch.backends.mps.is_available():
        torch_dtype = torch.float32  # MPS는 bfloat16 미지원
        device = "mps"
    else:
        torch_dtype = torch.float32
        device = "cpu"
    
    print(f"🎮 사용 디바이스: {device}")
    print(f"🔧 데이터 타입: {torch_dtype}")
    
    # 파이프라인 로드
    print("📦 모델 로딩 중... (처음 실행 시 다운로드에 시간이 걸릴 수 있습니다)")
    pipe = DiffusionPipeline.from_pretrained(
        model_name, 
        torch_dtype=torch_dtype,
        safety_checker=None,
        requires_safety_checker=False
    )
    pipe = pipe.to(device)
    
    print("✅ 모델 로드 완료")
    return pipe, device

def generate_test_image():
    """테스트 이미지 생성"""
    
    pipe, device = setup_qwen_image()
    
    # 테스트 프롬프트
    prompt = """
    A beautiful coffee shop storefront with a wooden sign that reads 
    "Qwen Café 通义咖啡馆 Welcome!" in elegant typography. 
    The scene has warm lighting and a cozy atmosphere.
    """
    
    enhanced_prompt = prompt + " Ultra HD, 4K, cinematic composition."
    negative_prompt = "blurry, low quality, distorted text, pixelated"
    
    print("🎨 이미지 생성 중...")
    print(f"📝 프롬프트: {prompt.strip()}")
    
    start_time = time.time()
    
    # 이미지 생성
    image = pipe(
        prompt=enhanced_prompt,
        negative_prompt=negative_prompt,
        width=1328,
        height=1328,
        num_inference_steps=30,  # 빠른 테스트를 위해 단계 수 감소
        true_cfg_scale=4.0,
        generator=torch.Generator(device=device).manual_seed(42)
    ).images[0]
    
    generation_time = time.time() - start_time
    
    # 결과 저장
    output_path = "qwen_test_cafe.png"
    image.save(output_path)
    
    print(f"✅ 이미지 생성 완료!")
    print(f"⏱️ 생성 시간: {generation_time:.2f}초")
    print(f"📁 저장됨: {output_path}")
    print(f"📏 크기: {image.size[0]}x{image.size[1]}")
    
    return image

if __name__ == "__main__":
    try:
        generate_test_image()
        print("\n🎉 테스트 성공! 이제 Qwen-Image를 사용할 준비가 되었습니다.")
    except Exception as e:
        print(f"\n❌ 테스트 실패: {e}")
        print("💡 환경 설정을 다시 확인해주세요.")
EOF

# 8. 테스트 실행
log_info "기본 환경 테스트 실행 중..."
if python test_qwen_image.py; then
    log_success "기본 환경 테스트 통과!"
else
    log_warning "일부 테스트 실패했지만 계속 진행합니다."
fi

# 9. 사용법 안내
echo ""
echo "🎯 다음 단계:"
echo "============="
echo "1. 프로젝트 디렉토리로 이동:"
echo "   cd $PROJECT_DIR"
echo ""
echo "2. 가상환경 활성화:"
echo "   source $VENV_NAME/bin/activate"
echo ""
echo "3. 기본 이미지 생성 테스트:"
echo "   python basic_generation.py"
echo ""
echo "4. 다양한 화면비 테스트:"
echo "   python aspect_ratio_generation.py"
echo ""
echo "5. 텍스트 렌더링 테스트:"
echo "   python advanced_text_rendering.py"
echo ""

# 10. 별칭 설정 안내
echo "🔧 zshrc 별칭 설정 (선택사항):"
echo "=============================="
cat << 'EOF'
# ~/.zshrc에 추가할 별칭들
alias qwen-image="cd ~/ai-projects/qwen-image && source qwen-image-env/bin/activate"
alias qi="qwen-image"
alias qi-test="cd ~/ai-projects/qwen-image && source qwen-image-env/bin/activate && python test_qwen_image.py"
alias qi-basic="cd ~/ai-projects/qwen-image && source qwen-image-env/bin/activate && python basic_generation.py"
alias qi-clean="cd ~/ai-projects/qwen-image && rm -rf *.png *.jpg *.json"
EOF

echo ""
log_success "Qwen-Image 환경 설정 완료!"
echo "📁 프로젝트 위치: $PROJECT_DIR"
echo "🐍 가상환경: $PROJECT_DIR/$VENV_NAME"
echo ""
echo "🚀 이제 최신 텍스트 렌더링 기술을 경험해보세요!"
echo "💡 중국어와 영어 텍스트가 완벽하게 렌더링되는 것을 확인할 수 있습니다."