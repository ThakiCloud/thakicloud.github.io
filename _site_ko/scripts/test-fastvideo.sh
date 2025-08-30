#!/bin/bash

# FastVideo 테스트 스크립트
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
PROJECT_DIR="$HOME/ai-projects/fastvideo"

echo "🚀 FastVideo 환경 테스트 시작"
echo "==============================="

# 1. 시스템 요구사항 확인
log_info "시스템 정보 확인 중..."
echo "📱 OS: $(uname -s) $(uname -r)"
echo "🐍 Python: $(python3 --version 2>/dev/null || echo 'Python3 not found')"
echo "💻 Architecture: $(uname -m)"

# GPU 확인
if command -v nvidia-smi &> /dev/null; then
    echo "🎮 NVIDIA GPU 정보:"
    nvidia-smi --query-gpu=name,memory.total --format=csv,noheader,nounits | head -3
    echo "📊 GPU 드라이버 버전: $(nvidia-smi --query-gpu=driver_version --format=csv,noheader,nounits | head -1)"
elif python3 -c "import torch; print('🍎 MPS Available:', torch.backends.mps.is_available())" 2>/dev/null | grep -q "True"; then
    echo "🍎 Apple Silicon MPS 지원 감지됨"
else
    log_warning "GPU 가속 사용 불가 (CPU 모드로 실행)"
fi

# 2. Python 환경 확인
if ! command -v python3 &> /dev/null; then
    log_error "Python3가 설치되어 있지 않습니다."
    log_info "설치 방법:"
    echo "  macOS: brew install python"
    echo "  Ubuntu: sudo apt install python3 python3-pip"
    echo "  CentOS: sudo yum install python3 python3-pip"
    exit 1
fi

# 3. Conda 확인
if command -v conda &> /dev/null; then
    echo "🐍 Conda 발견: $(conda --version)"
    USE_CONDA=true
else
    echo "📦 Conda 없음, venv 사용"
    USE_CONDA=false
fi

# 4. 프로젝트 디렉토리 생성
log_info "프로젝트 디렉토리 설정 중..."
mkdir -p "$PROJECT_DIR"
cd "$PROJECT_DIR"

# 5. 가상환경 생성 및 활성화
if [ "$USE_CONDA" = true ]; then
    log_info "Conda 환경 생성 중..."
    if ! conda env list | grep -q "fastvideo"; then
        conda create -n fastvideo python=3.12 -y
    fi
    source "$(conda info --base)/etc/profile.d/conda.sh"
    conda activate fastvideo
    echo "✅ Conda 환경 활성화: fastvideo"
else
    log_info "Python 가상환경 생성 중..."
    if [ ! -d "fastvideo-env" ]; then
        python3 -m venv fastvideo-env
    fi
    source fastvideo-env/bin/activate
    echo "✅ Python 가상환경 활성화"
fi

# 6. 의존성 설치
log_info "의존성 업그레이드 중..."
pip install --upgrade pip setuptools wheel

# FastVideo 설치
log_info "FastVideo 설치 중..."
pip install fastvideo

# PyTorch 설치 (GPU 환경에 따라)
if command -v nvidia-smi &> /dev/null; then
    log_info "NVIDIA GPU용 PyTorch 설치 중..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cu118
    pip install xformers triton  # GPU 최적화 패키지
elif [[ $(uname -s) == "Darwin" ]] && [[ $(uname -m) == "arm64" ]]; then
    log_info "Apple Silicon용 PyTorch 설치 중..."
    pip install torch torchvision torchaudio
else
    log_info "CPU용 PyTorch 설치 중..."
    pip install torch torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu
fi

# 7. 추가 의존성 설치
log_info "추가 도구 설치 중..."
pip install pillow opencv-python ffmpeg-python numpy

# 8. 테스트 스크립트 생성
log_info "테스트 스크립트 생성 중..."

cat > test_fastvideo_env.py << 'EOF'
#!/usr/bin/env python3
"""
FastVideo 환경 종합 테스트
"""

import sys
import time
import os

def test_imports():
    """패키지 import 테스트"""
    print("📦 필수 패키지 import 테스트...")
    
    try:
        import torch
        print(f"  ✅ PyTorch {torch.__version__}")
        
        # GPU 정보
        if torch.cuda.is_available():
            gpu_count = torch.cuda.device_count()
            print(f"  🎮 CUDA GPU: {gpu_count}개")
            for i in range(min(gpu_count, 3)):  # 최대 3개까지만 표시
                gpu_name = torch.cuda.get_device_name(i)
                gpu_memory = torch.cuda.get_device_properties(i).total_memory / 1e9
                print(f"    GPU {i}: {gpu_name} ({gpu_memory:.1f}GB)")
        elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
            print("  🍎 MPS (Apple Silicon) 사용 가능")
        else:
            print("  💻 CPU 모드")
            
    except ImportError as e:
        print(f"  ❌ PyTorch import 실패: {e}")
        return False
    
    try:
        from fastvideo import VideoGenerator
        print("  ✅ FastVideo 메인 모듈")
    except ImportError as e:
        print(f"  ❌ FastVideo import 실패: {e}")
        return False
    
    try:
        import PIL
        print(f"  ✅ Pillow {PIL.__version__}")
    except ImportError as e:
        print(f"  ❌ Pillow import 실패: {e}")
        return False
    
    # 선택적 패키지 확인
    optional_packages = [
        ("xformers", "메모리 효율적 어텐션"),
        ("triton", "GPU 커널 최적화"),
        ("cv2", "OpenCV")
    ]
    
    for package, description in optional_packages:
        try:
            __import__(package)
            print(f"  ✅ {package} ({description})")
        except ImportError:
            print(f"  ⚠️ {package} 없음 ({description}) - 선택사항")
    
    return True

def test_fastvideo_access():
    """FastVideo 모델 접근 테스트"""
    print("\n🤖 FastVideo 모델 접근 테스트...")
    
    try:
        from fastvideo import VideoGenerator
        
        # 사용 가능한 디바이스 확인
        import torch
        if torch.cuda.is_available():
            device_count = torch.cuda.device_count()
            print(f"  🎮 사용 가능한 GPU: {device_count}개")
        elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
            device_count = 1
            print("  🍎 MPS 디바이스 사용 가능")
        else:
            device_count = 0
            print("  💻 CPU 모드 사용")
        
        # 모델 정보만 확인 (실제 다운로드 X)
        model_name = "FastVideo/FastWan2.1-T2V-1.3B-Diffusers"
        print(f"  📋 테스트 모델: {model_name}")
        print("  💡 실제 모델 다운로드는 첫 실행 시에만 수행됩니다")
        
        # 간단한 생성기 초기화 테스트 (메타데이터만)
        print("  🔍 VideoGenerator 클래스 테스트...")
        
        # 클래스 존재 확인
        assert hasattr(VideoGenerator, 'from_pretrained')
        assert hasattr(VideoGenerator, 'generate_video')
        print("  ✅ 필수 메서드 확인 완료")
        
        return True
        
    except Exception as e:
        print(f"  ❌ FastVideo 접근 실패: {e}")
        return False

def test_system_resources():
    """시스템 리소스 테스트"""
    print("\n💾 시스템 리소스 확인...")
    
    try:
        import psutil
        
        # CPU 정보
        cpu_count = psutil.cpu_count()
        cpu_freq = psutil.cpu_freq()
        print(f"  🖥️ CPU: {cpu_count}코어")
        if cpu_freq:
            print(f"      주파수: {cpu_freq.current:.0f}MHz")
        
        # 메모리 정보
        memory = psutil.virtual_memory()
        print(f"  💾 RAM: {memory.total/1e9:.1f}GB (사용가능: {memory.available/1e9:.1f}GB)")
        
        # 디스크 정보
        disk = psutil.disk_usage('.')
        print(f"  💿 디스크: {disk.free/1e9:.1f}GB 여유공간")
        
        # 최소 요구사항 체크
        if memory.total < 8e9:
            print("  ⚠️ 메모리가 8GB 미만입니다. 성능에 영향을 줄 수 있습니다.")
        
        if disk.free < 10e9:
            print("  ⚠️ 디스크 여유공간이 10GB 미만입니다.")
            
        return True
        
    except ImportError:
        print("  💡 psutil 패키지가 없어 시스템 정보를 건너뜁니다")
        return True
    except Exception as e:
        print(f"  ❌ 시스템 리소스 확인 실패: {e}")
        return False

def test_output_directory():
    """출력 디렉토리 테스트"""
    print("\n📁 출력 디렉토리 테스트...")
    
    try:
        output_dirs = ["outputs", "outputs/test", "outputs/basic", "outputs/advanced"]
        
        for dir_path in output_dirs:
            os.makedirs(dir_path, exist_ok=True)
            print(f"  ✅ 생성됨: {dir_path}")
        
        # 쓰기 권한 테스트
        test_file = "outputs/test/write_test.txt"
        with open(test_file, 'w') as f:
            f.write("FastVideo write test")
        
        os.remove(test_file)
        print("  ✅ 쓰기 권한 확인")
        
        return True
        
    except Exception as e:
        print(f"  ❌ 디렉토리 테스트 실패: {e}")
        return False

def main():
    print("🚀 FastVideo 환경 종합 테스트\n")
    
    tests = [
        ("패키지 Import", test_imports),
        ("FastVideo 접근", test_fastvideo_access),
        ("시스템 리소스", test_system_resources),
        ("출력 디렉토리", test_output_directory)
    ]
    
    passed = 0
    total = len(tests)
    
    for name, test_func in tests:
        try:
            if test_func():
                passed += 1
                print(f"✅ {name}: PASS")
            else:
                print(f"❌ {name}: FAIL")
        except Exception as e:
            print(f"❌ {name}: ERROR - {e}")
    
    print(f"\n📊 테스트 결과: {passed}/{total} 통과")
    
    if passed == total:
        print("\n🎉 모든 테스트 통과!")
        print("💡 이제 FastVideo로 비디오 생성을 시작할 수 있습니다.")
        print("\n🚀 다음 단계:")
        print("  1. python basic_generation.py     # 기본 비디오 생성")
        print("  2. python advanced_generation.py  # 고급 설정 생성")
        print("  3. python model_comparison.py     # 모델 비교")
    else:
        print(f"\n⚠️ {total-passed}개 테스트 실패")
        print("💡 실패한 항목을 확인하고 환경을 재설정해보세요.")
    
    return passed == total

if __name__ == "__main__":
    success = main()
    sys.exit(0 if success else 1)
EOF

# 9. 기본 생성 스크립트 생성
log_info "기본 생성 스크립트 생성 중..."

cat > basic_generation.py << 'EOF'
#!/usr/bin/env python3
"""
FastVideo 기본 비디오 생성 예제
"""

from fastvideo import VideoGenerator
import torch
import time
import os

def generate_test_video():
    """기본 테스트 비디오 생성"""
    
    print("🎬 FastVideo 기본 비디오 생성 테스트")
    print("=" * 50)
    
    # 출력 디렉토리 생성
    os.makedirs("outputs/basic", exist_ok=True)
    
    # GPU 개수 확인
    if torch.cuda.is_available():
        num_gpus = torch.cuda.device_count()
        print(f"🎮 CUDA GPU: {num_gpus}개")
    elif hasattr(torch.backends, 'mps') and torch.backends.mps.is_available():
        num_gpus = 1
        print("🍎 MPS (Apple Silicon) 사용")
    else:
        num_gpus = 0
        print("💻 CPU 모드 사용")
    
    # 비디오 생성기 초기화
    print("\n📦 모델 로딩 중...")
    print("💡 첫 실행 시 모델 다운로드로 시간이 걸릴 수 있습니다.")
    
    try:
        generator = VideoGenerator.from_pretrained(
            "FastVideo/FastWan2.1-T2V-1.3B-Diffusers",
            num_gpus=max(num_gpus, 1) if num_gpus > 0 else 0,
            enable_optimization=True
        )
        print("✅ 모델 로드 완료")
        
    except Exception as e:
        print(f"❌ 모델 로드 실패: {e}")
        print("💡 인터넷 연결을 확인하거나 나중에 다시 시도해보세요.")
        return False
    
    # 테스트 프롬프트들
    test_prompts = [
        "A curious raccoon peers through a vibrant field of yellow sunflowers, its eyes wide with interest.",
        "A peaceful sunset over a calm ocean with gentle waves.",
        "A bustling street market with colorful fruits and vegetables."
    ]
    
    print(f"\n🎯 {len(test_prompts)}개 테스트 비디오 생성 시작")
    
    successful_generations = 0
    
    for i, prompt in enumerate(test_prompts, 1):
        print(f"\n🎬 비디오 {i}/{len(test_prompts)} 생성 중...")
        print(f"📝 프롬프트: {prompt}")
        
        try:
            start_time = time.time()
            
            # 비디오 생성
            video = generator.generate_video(
                prompt=prompt,
                return_frames=True,
                output_path="outputs/basic/",
                save_video=True,
                num_inference_steps=1,  # Sparse Distillation: 1단계
                guidance_scale=7.5,
                height=480,
                width=832,
                num_frames=77,  # 약 2.5초 (30fps)
                fps=30
            )
            
            generation_time = time.time() - start_time
            successful_generations += 1
            
            print(f"✅ 생성 완료!")
            print(f"⏱️ 소요시간: {generation_time:.2f}초")
            print(f"🎞️ 프레임: 77개 (2.5초)")
            print(f"📐 해상도: 480x832")
            print(f"📁 저장 위치: outputs/basic/")
            
        except Exception as e:
            print(f"❌ 생성 실패: {e}")
    
    # 결과 요약
    print(f"\n📊 생성 결과 요약:")
    print(f"  성공: {successful_generations}/{len(test_prompts)}개")
    print(f"  실패: {len(test_prompts) - successful_generations}개")
    
    if successful_generations > 0:
        print(f"\n🎉 {successful_generations}개 비디오가 성공적으로 생성되었습니다!")
        print("📁 outputs/basic/ 폴더에서 결과를 확인해보세요.")
        
        # 생성된 파일 목록
        if os.path.exists("outputs/basic"):
            files = [f for f in os.listdir("outputs/basic") if f.endswith(('.mp4', '.avi', '.mov'))]
            if files:
                print("\n📋 생성된 파일 목록:")
                for file in sorted(files):
                    file_path = os.path.join("outputs/basic", file)
                    file_size = os.path.getsize(file_path) / 1024 / 1024
                    print(f"  • {file} ({file_size:.1f}MB)")
        
        return True
    else:
        print("\n❌ 모든 비디오 생성이 실패했습니다.")
        print("💡 환경 설정을 다시 확인해보세요.")
        return False

if __name__ == "__main__":
    success = generate_test_video()
    if success:
        print("\n🚀 FastVideo 기본 테스트 완료!")
        print("💡 이제 advanced_generation.py로 더 많은 기능을 테스트해보세요.")
    else:
        print("\n⚠️ 테스트 실패. 환경을 다시 설정해보세요.")
EOF

# 10. 환경 테스트 실행
log_info "기본 환경 테스트 실행 중..."
if python test_fastvideo_env.py; then
    log_success "환경 테스트 통과!"
else
    log_warning "일부 테스트 실패했지만 계속 진행합니다."
fi

# 11. 사용법 안내
echo ""
echo "🎯 FastVideo 사용 가이드:"
echo "========================="
echo "1. 프로젝트 디렉토리로 이동:"
echo "   cd $PROJECT_DIR"
echo ""
echo "2. 환경 활성화:"
if [ "$USE_CONDA" = true ]; then
    echo "   conda activate fastvideo"
else
    echo "   source fastvideo-env/bin/activate"
fi
echo ""
echo "3. 첫 번째 비디오 생성:"
echo "   python basic_generation.py"
echo ""
echo "4. 환경 재테스트:"
echo "   python test_fastvideo_env.py"
echo ""

# 12. 성능 팁 안내
echo "🚀 성능 최적화 팁:"
echo "================="
echo "• GPU 메모리 8GB+ 권장 (RTX 3070 이상)"
echo "• CUDA 11.8+ 또는 Apple Silicon MPS 사용"
echo "• 충분한 RAM (16GB+) 및 디스크 공간 (20GB+)"
echo "• 인터넷 연결 (첫 실행 시 모델 다운로드)"
echo ""

# 13. 별칭 설정 안내
echo "🔧 편의 별칭 (선택사항):"
echo "====================="
cat << 'EOF'
# ~/.zshrc 또는 ~/.bashrc에 추가:
alias fastvideo="cd ~/ai-projects/fastvideo && conda activate fastvideo"  # Conda 사용 시
alias fastvideo="cd ~/ai-projects/fastvideo && source fastvideo-env/bin/activate"  # venv 사용 시
alias fv-test="cd ~/ai-projects/fastvideo && python test_fastvideo_env.py"
alias fv-basic="cd ~/ai-projects/fastvideo && python basic_generation.py"
alias fv-clean="cd ~/ai-projects/fastvideo && rm -rf outputs/*.mp4 outputs/*.avi"
EOF

echo ""
log_success "FastVideo 환경 설정 완료!"
echo "📁 프로젝트 위치: $PROJECT_DIR"
echo "🚀 이제 50배 빠른 비디오 생성을 경험해보세요!"
echo ""
echo "💡 주요 특징:"
echo "  • Sparse Distillation: 50-65배 가속화"
echo "  • Video Sparse Attention: 메모리 효율화"
echo "  • 1-2 디노이징 단계로 고품질 비디오 생성"
echo "  • 실시간에 가까운 비디오 생성 가능"