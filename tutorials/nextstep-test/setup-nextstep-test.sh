#!/bin/bash

# NextStep-1 테스트 환경 설정 스크립트
# 작성일: 2025-08-19
# 용도: StepFun NextStep-1 모델 로컬 테스트 환경 구축

set -e

echo "🚀 NextStep-1 테스트 환경 설정 시작..."

# 색상 정의
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# 로그 함수
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

# 시스템 정보 확인
check_system() {
    log_info "시스템 정보 확인 중..."
    
    echo "🖥️  시스템 정보:"
    echo "   OS: $(uname -s) $(uname -r)"
    echo "   아키텍처: $(uname -m)"
    echo "   메모리: $(sysctl -n hw.memsize | awk '{printf "%.0f GB", $1/1024/1024/1024}')"
    
    # Python 버전 확인
    if command -v python3 &> /dev/null; then
        echo "   Python: $(python3 --version)"
    else
        log_error "Python3가 설치되어 있지 않습니다."
        exit 1
    fi
    
    # Conda 확인
    if command -v conda &> /dev/null; then
        echo "   Conda: $(conda --version)"
    else
        log_warning "Conda가 설치되어 있지 않습니다. Miniforge 설치를 권장합니다."
    fi
    
    # Git LFS 확인
    if command -v git-lfs &> /dev/null; then
        echo "   Git LFS: $(git lfs version | head -n1)"
    else
        log_warning "Git LFS가 설치되어 있지 않습니다."
        log_info "설치 명령: brew install git-lfs"
    fi
}

# GPU 지원 확인
check_gpu_support() {
    log_info "GPU 지원 확인 중..."
    
    # NVIDIA GPU 확인 (CUDA)
    if command -v nvidia-smi &> /dev/null; then
        echo "🔥 NVIDIA GPU 감지됨:"
        nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | \
        awk -F, '{printf "   GPU: %s (VRAM: %d GB)\n", $1, $2/1024}'
        export USE_CUDA=true
    # Apple Silicon GPU 확인 (MPS)
    elif [[ "$(uname -m)" == "arm64" ]] && [[ "$(uname -s)" == "Darwin" ]]; then
        echo "🍎 Apple Silicon GPU (Metal Performance Shaders) 지원"
        export USE_MPS=true
    else
        echo "⚠️  GPU 가속 미지원 - CPU만 사용"
        export USE_CPU_ONLY=true
    fi
}

# Conda 환경 설정
setup_conda_env() {
    log_info "Conda 환경 설정 중..."
    
    ENV_NAME="nextstep"
    
    # 기존 환경 확인
    if conda env list | grep -q "^${ENV_NAME} "; then
        log_warning "기존 ${ENV_NAME} 환경이 발견되었습니다."
        read -p "기존 환경을 삭제하고 새로 만드시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            conda env remove -n ${ENV_NAME} -y
        else
            log_info "기존 환경을 사용합니다."
            conda activate ${ENV_NAME}
            return
        fi
    fi
    
    # 새 환경 생성
    log_info "Python 3.11 환경 생성 중..."
    conda create -n ${ENV_NAME} python=3.11 -y
    
    # 환경 활성화
    log_info "환경 활성화 중..."
    conda activate ${ENV_NAME}
    
    log_success "Conda 환경 '${ENV_NAME}' 생성 완료"
}

# 패키지 매니저 설치
install_package_managers() {
    log_info "패키지 매니저 설치 중..."
    
    # uv 설치 (선택사항)
    if ! command -v uv &> /dev/null; then
        log_info "uv 패키지 매니저 설치 중..."
        pip install uv
        log_success "uv 설치 완료"
    else
        log_info "uv 이미 설치됨: $(uv --version)"
    fi
}

# 모델 다운로드
download_model() {
    log_info "NextStep-1 모델 다운로드 중..."
    
    MODEL_DIR="NextStep-1-Large-Pretrain"
    
    # Git LFS 체크
    if ! command -v git-lfs &> /dev/null; then
        log_error "Git LFS가 필요합니다. 다음 명령으로 설치하세요:"
        echo "brew install git-lfs"
        exit 1
    fi
    
    # 기존 모델 디렉토리 확인
    if [ -d "$MODEL_DIR" ]; then
        log_warning "기존 모델 디렉토리가 발견되었습니다."
        read -p "다시 다운로드하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            rm -rf "$MODEL_DIR"
        else
            log_info "기존 모델을 사용합니다."
            cd "$MODEL_DIR"
            return
        fi
    fi
    
    # 모델 클론 (대용량 파일 제외)
    log_info "모델 저장소 클론 중... (대용량 파일 제외)"
    GIT_LFS_SKIP_SMUDGE=1 git clone https://huggingface.co/stepfun-ai/NextStep-1-Large-Pretrain
    cd "$MODEL_DIR"
    
    # Hugging Face CLI 확인 및 설치
    if ! command -v huggingface-cli &> /dev/null; then
        log_info "Hugging Face CLI 설치 중..."
        pip install --upgrade huggingface_hub
    fi
    
    log_success "모델 저장소 클론 완료"
}

# 의존성 설치
install_dependencies() {
    log_info "의존성 패키지 설치 중..."
    
    # requirements.txt 확인
    if [ ! -f "requirements.txt" ]; then
        log_warning "requirements.txt 파일이 없습니다. 기본 패키지를 설치합니다."
        
        # 기본 패키지 목록 생성
        cat > requirements.txt << EOF
torch>=2.0.0
torchvision>=0.15.0
transformers>=4.35.0
accelerate>=0.24.0
diffusers>=0.24.0
Pillow>=9.5.0
numpy>=1.24.0
scipy>=1.10.0
opencv-python>=4.8.0
matplotlib>=3.7.0
tqdm>=4.65.0
safetensors>=0.4.0
huggingface-hub>=0.17.0
EOF
        log_info "기본 requirements.txt 생성됨"
    fi
    
    # PyTorch GPU 지원 설치
    if [[ "${USE_CUDA}" == "true" ]]; then
        log_info "CUDA 지원 PyTorch 설치 중..."
        if command -v uv &> /dev/null; then
            uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
        else
            pip install torch torchvision --index-url https://download.pytorch.org/whl/cu118
        fi
    elif [[ "${USE_MPS}" == "true" ]]; then
        log_info "Apple Silicon MPS 지원 PyTorch 설치 중..."
        if command -v uv &> /dev/null; then
            uv pip install torch torchvision
        else
            pip install torch torchvision
        fi
    else
        log_info "CPU 전용 PyTorch 설치 중..."
        if command -v uv &> /dev/null; then
            uv pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
        else
            pip install torch torchvision --index-url https://download.pytorch.org/whl/cpu
        fi
    fi
    
    # 나머지 의존성 설치
    log_info "기타 의존성 설치 중..."
    if command -v uv &> /dev/null; then
        uv pip install -r requirements.txt
    else
        pip install -r requirements.txt
    fi
    
    log_success "모든 의존성 설치 완료"
}

# VAE 모델 다운로드
download_vae_model() {
    log_info "VAE 모델 다운로드 중..."
    
    # VAE 디렉토리 생성
    mkdir -p vae
    
    # Hugging Face CLI로 VAE 다운로드
    log_info "VAE checkpoint 다운로드 중... (약 2-3GB)"
    huggingface-cli download stepfun-ai/NextStep-1-Large-Pretrain "vae/checkpoint.pt" --local-dir ./
    
    if [ -f "vae/checkpoint.pt" ]; then
        log_success "VAE 모델 다운로드 완료"
        echo "   파일 크기: $(du -h vae/checkpoint.pt | cut -f1)"
    else
        log_error "VAE 모델 다운로드 실패"
        exit 1
    fi
}

# 테스트 스크립트 생성
create_test_script() {
    log_info "테스트 스크립트 생성 중..."
    
    cat > test_nextstep.py << 'EOF'
#!/usr/bin/env python3
"""
NextStep-1 모델 테스트 스크립트
macOS 환경에서 기본 이미지 생성 테스트
"""

import torch
import sys
import os
from datetime import datetime
from pathlib import Path

def check_environment():
    """환경 점검"""
    print("🔍 환경 점검 시작...")
    
    # PyTorch 버전
    print(f"PyTorch 버전: {torch.__version__}")
    
    # 디바이스 확인
    if torch.cuda.is_available():
        device = "cuda"
        print(f"CUDA 사용 가능: {torch.cuda.get_device_name(0)}")
        print(f"CUDA 메모리: {torch.cuda.get_device_properties(0).total_memory / 1024**3:.1f} GB")
    elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        device = "mps"
        print("Apple Silicon MPS 사용 가능")
    else:
        device = "cpu"
        print("CPU 전용 모드")
    
    print(f"선택된 디바이스: {device}")
    return device

def test_basic_import():
    """기본 임포트 테스트"""
    print("\n📦 모듈 임포트 테스트...")
    
    try:
        from transformers import AutoTokenizer, AutoModel
        print("✅ Transformers 임포트 성공")
    except ImportError as e:
        print(f"❌ Transformers 임포트 실패: {e}")
        return False
    
    try:
        from PIL import Image
        print("✅ PIL 임포트 성공")
    except ImportError as e:
        print(f"❌ PIL 임포트 실패: {e}")
        return False
    
    return True

def test_model_loading():
    """모델 로딩 테스트"""
    print("\n🤖 모델 로딩 테스트...")
    
    try:
        from transformers import AutoTokenizer, AutoModel
        
        model_path = "."  # 현재 디렉토리
        
        print("토크나이저 로딩 중...")
        tokenizer = AutoTokenizer.from_pretrained(
            model_path,
            local_files_only=True,
            trust_remote_code=True
        )
        print("✅ 토크나이저 로딩 성공")
        
        print("모델 로딩 중... (시간이 걸릴 수 있습니다)")
        model = AutoModel.from_pretrained(
            model_path,
            local_files_only=True,
            trust_remote_code=True,
            torch_dtype=torch.float16,
            low_cpu_mem_usage=True
        )
        print("✅ 모델 로딩 성공")
        
        # 모델 정보
        total_params = sum(p.numel() for p in model.parameters())
        print(f"총 파라미터 수: {total_params:,}")
        
        return tokenizer, model
        
    except Exception as e:
        print(f"❌ 모델 로딩 실패: {e}")
        return None, None

def test_simple_generation(tokenizer, model, device):
    """간단한 생성 테스트"""
    print("\n🎨 이미지 생성 테스트...")
    
    try:
        # 파이프라인 import 시도
        try:
            from models.gen_pipeline import NextStepPipeline
            pipeline_available = True
        except ImportError:
            print("⚠️ gen_pipeline 모듈을 찾을 수 없습니다.")
            print("기본 생성 테스트를 건너뜁니다.")
            pipeline_available = False
        
        if not pipeline_available:
            return False
        
        # 파이프라인 생성
        pipeline = NextStepPipeline(tokenizer=tokenizer, model=model)
        
        # 디바이스로 이동 (MPS는 일부 연산에서 문제가 있을 수 있음)
        if device == "mps":
            print("⚠️ MPS에서는 일부 연산이 지원되지 않을 수 있습니다.")
            device = "cpu"  # MPS 대신 CPU 사용
        
        pipeline = pipeline.to(device=device, dtype=torch.float16)
        
        # 간단한 프롬프트로 테스트
        test_prompt = "A simple red apple on a white background"
        
        print(f"프롬프트: {test_prompt}")
        print("이미지 생성 중... (몇 분 소요될 수 있습니다)")
        
        image = pipeline.generate_image(
            test_prompt,
            hw=(512, 512),
            num_images_per_caption=1,
            positive_prompt="masterpiece, best quality",
            negative_prompt="lowres, bad quality",
            cfg=7.5,
            num_sampling_steps=20,  # 빠른 테스트를 위해 단계 수 감소
            seed=42
        )[0]
        
        # 이미지 저장
        timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
        output_path = f"test_output_{timestamp}.jpg"
        image.save(output_path)
        
        print(f"✅ 이미지 생성 성공: {output_path}")
        print(f"이미지 크기: {image.size}")
        
        return True
        
    except Exception as e:
        print(f"❌ 이미지 생성 실패: {e}")
        import traceback
        traceback.print_exc()
        return False

def main():
    """메인 테스트 함수"""
    print("🚀 NextStep-1 모델 테스트 시작")
    print("=" * 50)
    
    # 환경 점검
    device = check_environment()
    
    # 기본 임포트 테스트
    if not test_basic_import():
        print("\n❌ 기본 임포트 테스트 실패")
        sys.exit(1)
    
    # 모델 로딩 테스트
    tokenizer, model = test_model_loading()
    if tokenizer is None or model is None:
        print("\n❌ 모델 로딩 테스트 실패")
        sys.exit(1)
    
    # 간단한 생성 테스트
    if test_simple_generation(tokenizer, model, device):
        print("\n🎉 모든 테스트 통과!")
        print("\n다음 단계:")
        print("1. 생성된 이미지를 확인해보세요")
        print("2. 다양한 프롬프트로 실험해보세요")
        print("3. 설정값들을 조정해보세요")
    else:
        print("\n⚠️ 이미지 생성 테스트 실패")
        print("모델 로딩은 성공했으니 설정을 확인해보세요")

if __name__ == "__main__":
    main()
EOF

    chmod +x test_nextstep.py
    log_success "테스트 스크립트 생성 완료: test_nextstep.py"
}

# 사용법 안내 생성
create_usage_guide() {
    log_info "사용법 가이드 생성 중..."
    
    cat > README.md << 'EOF'
# NextStep-1 테스트 환경

StepFun NextStep-1 모델의 macOS 테스트 환경입니다.

## 설치된 구성 요소

- NextStep-1 14B 메인 모델
- 157M Flow Matching Head
- VAE 모델 (vae/checkpoint.pt)
- 테스트 스크립트

## 사용법

### 1. 환경 활성화
```bash
conda activate nextstep
cd NextStep-1-Large-Pretrain
```

### 2. 기본 테스트 실행
```bash
python test_nextstep.py
```

### 3. 커스텀 이미지 생성
```python
import torch
from transformers import AutoTokenizer, AutoModel
from models.gen_pipeline import NextStepPipeline

# 모델 로딩
tokenizer = AutoTokenizer.from_pretrained(".", local_files_only=True, trust_remote_code=True)
model = AutoModel.from_pretrained(".", local_files_only=True, trust_remote_code=True)

# 파이프라인 생성
pipeline = NextStepPipeline(tokenizer=tokenizer, model=model)
device = "cuda" if torch.cuda.is_available() else "cpu"
pipeline = pipeline.to(device=device, dtype=torch.bfloat16)

# 이미지 생성
image = pipeline.generate_image(
    "Your custom prompt here",
    hw=(1024, 1024),
    cfg=7.5,
    num_sampling_steps=28,
    seed=3407
)[0]

image.save("output.jpg")
```

## 생성 파라미터 설명

- `hw`: 이미지 크기 (높이, 너비)
- `cfg`: Classifier-Free Guidance 강도 (7.0-9.0 권장)
- `num_sampling_steps`: 생성 단계 수 (많을수록 품질 향상, 시간 증가)
- `seed`: 재현 가능한 결과를 위한 시드값

## 문제 해결

### 메모리 부족 오류
- 이미지 크기를 512x512로 줄이기
- 배치 크기를 1로 설정
- `torch_dtype=torch.float16` 사용

### MPS 관련 오류 (Apple Silicon)
- CPU 모드로 전환: `device="cpu"`
- PyTorch 최신 버전 사용

### 모델 로딩 실패
- Git LFS 설치 확인: `brew install git-lfs`
- 인터넷 연결 확인
- 디스크 용량 확인 (최소 50GB)

## 성능 최적화

1. **GPU 사용**: NVIDIA GPU 또는 Apple Silicon 권장
2. **메모리**: 24GB+ VRAM 또는 32GB+ RAM 권장
3. **저장공간**: 50GB+ 여유 공간 필요

## 지원 모델 크기

- NextStep-1-Large-Pretrain: ~15B 파라미터
- VAE: ~157M 파라미터
- 총 디스크 사용량: ~30GB
EOF

    log_success "사용법 가이드 생성 완료: README.md"
}

# Alias 설정
setup_aliases() {
    log_info "편의 alias 설정 중..."
    
    cat > setup_nextstep_aliases.sh << 'EOF'
#!/bin/bash
# NextStep-1 테스트용 편의 alias 설정

# Conda 환경 관련
alias nextstep-env="conda activate nextstep"
alias nextstep-deenv="conda deactivate"

# 테스트 관련
alias nextstep-test="cd NextStep-1-Large-Pretrain && python test_nextstep.py"
alias nextstep-dir="cd NextStep-1-Large-Pretrain"

# 모니터링 관련
alias nextstep-gpu="watch -n 1 nvidia-smi"  # NVIDIA GPU만
alias nextstep-mem="ps aux | grep python | grep -v grep"

# 로그 관련
alias nextstep-log="tail -f nextstep_generation.log"

echo "✅ NextStep-1 alias 설정 완료"
echo "사용법:"
echo "  nextstep-env     : 환경 활성화"
echo "  nextstep-test    : 기본 테스트 실행"
echo "  nextstep-dir     : 모델 디렉토리 이동"
echo "  nextstep-gpu     : GPU 상태 모니터링"

# zshrc에 추가하려면 다음 명령 실행:
echo ""
echo "🔧 영구 설정을 원한다면:"
echo "echo 'source $(pwd)/setup_nextstep_aliases.sh' >> ~/.zshrc"
EOF

    chmod +x setup_nextstep_aliases.sh
    log_success "Alias 설정 스크립트 생성 완료"
}

# 최종 정리 및 안내
final_setup() {
    log_info "최종 설정 완료 중..."
    
    # 디렉토리 정보
    echo ""
    echo "📁 설치 디렉토리 구조:"
    echo "   $(pwd)/"
    echo "   ├── NextStep-1-Large-Pretrain/"
    echo "   │   ├── models/"
    echo "   │   ├── vae/checkpoint.pt"
    echo "   │   ├── test_nextstep.py"
    echo "   │   └── README.md"
    echo "   └── setup_nextstep_aliases.sh"
    
    # 사용법 안내
    echo ""
    log_success "🎉 NextStep-1 테스트 환경 설정 완료!"
    echo ""
    echo "🚀 시작하기:"
    echo "   1. conda activate nextstep"
    echo "   2. cd NextStep-1-Large-Pretrain"
    echo "   3. python test_nextstep.py"
    echo ""
    echo "📚 추가 정보:"
    echo "   - 사용법: cat NextStep-1-Large-Pretrain/README.md"
    echo "   - Alias: source setup_nextstep_aliases.sh"
    echo "   - 로그: tail -f NextStep-1-Large-Pretrain/nextstep_generation.log"
    
    # 시스템 요구사항 재안내
    echo ""
    echo "⚠️  시스템 요구사항:"
    echo "   - 메모리: 24GB+ VRAM 또는 32GB+ RAM"
    echo "   - 저장공간: 50GB+ 여유공간"
    echo "   - 네트워크: 모델 다운로드용 안정적 연결"
}

# 메인 실행 함수
main() {
    echo "🎯 NextStep-1 테스트 환경 자동 설정"
    echo "   StepFun AI의 14B 자동회귀 이미지 생성 모델"
    echo "   macOS 최적화 버전"
    echo ""
    
    # 단계별 실행
    check_system
    check_gpu_support
    
    # 사용자 확인
    echo ""
    read -p "설치를 진행하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        log_info "설치가 취소되었습니다."
        exit 0
    fi
    
    # 설치 진행
    setup_conda_env
    install_package_managers
    download_model
    install_dependencies
    download_vae_model
    create_test_script
    create_usage_guide
    setup_aliases
    final_setup
    
    log_success "모든 설정이 완료되었습니다! 🎉"
}

# 스크립트 실행
if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
    main "$@"
fi
