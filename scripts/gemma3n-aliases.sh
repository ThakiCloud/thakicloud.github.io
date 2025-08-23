#!/bin/bash
# Gemma3n FineVideo 파인튜닝을 위한 유용한 aliases
# 사용법: source scripts/gemma3n-aliases.sh

echo "🦥 Gemma3n FineVideo 파인튜닝 Aliases 로딩중..."

# 기본 환경 설정
export GEMMA3N_PROJECT_DIR="$(pwd)"
export GEMMA3N_ENV_NAME="gemma3n_env"
export GEMMA3N_CHECKPOINTS_DIR="$GEMMA3N_PROJECT_DIR/gemma3n-finevideo-checkpoints"
export GEMMA3N_MODELS_DIR="$GEMMA3N_PROJECT_DIR/models"

# 환경 관리
alias gemma3n-env-create="python -m venv $GEMMA3N_ENV_NAME && source $GEMMA3N_ENV_NAME/bin/activate"
alias gemma3n-env-activate="source $GEMMA3N_ENV_NAME/bin/activate"
alias gemma3n-env-deactivate="deactivate"

# 패키지 설치
alias gemma3n-install-base="pip install torch torchvision torchaudio transformers datasets accelerate huggingface_hub wandb"
alias gemma3n-install-video="pip install opencv-python pillow numpy matplotlib"
alias gemma3n-install-training="pip install bitsandbytes peft"
alias gemma3n-install-unsloth="pip install --upgrade --force-reinstall --no-cache-dir unsloth unsloth_zoo"

# 테스트 및 검증
alias gemma3n-test="python scripts/test_gemma3n_finevideo.py"
alias gemma3n-test-minimal="python gemma3n_minimal_test.py"
alias gemma3n-check-memory="python -c 'import psutil; m=psutil.virtual_memory(); print(f\"Total: {m.total/1024**3:.1f}GB, Available: {m.available/1024**3:.1f}GB\")'"
alias gemma3n-check-gpu="python -c 'import torch; print(f\"MPS available: {torch.backends.mps.is_available()}\") if hasattr(torch.backends, \"mps\") else print(\"MPS not supported\")'"

# HuggingFace 관리
alias gemma3n-hf-login="huggingface-cli login"
alias gemma3n-hf-whoami="huggingface-cli whoami"
alias gemma3n-hf-cache-clear="rm -rf ~/.cache/huggingface/"

# 모델 관리
alias gemma3n-model-list="ls -la $GEMMA3N_MODELS_DIR"
alias gemma3n-checkpoint-list="ls -la $GEMMA3N_CHECKPOINTS_DIR"

# 시스템 모니터링
alias gemma3n-monitor-memory="watch -n 2 'vm_stat | grep -E \"Pages free|Pages active|Pages inactive|Pages speculative|Pages wired down\"'"

# 프로젝트 관리
alias gemma3n-clean-cache="rm -rf __pycache__ .DS_Store *.pyc"
alias gemma3n-clean-temp="rm -rf /tmp/temp_video.mp4 /tmp/*.mp4"

# 프로젝트 디렉토리로 이동
alias gemma3n-cd="cd $GEMMA3N_PROJECT_DIR"

# 함수 정의
gemma3n_install_all() {
    echo "📦 모든 필수 패키지 설치 시작..."
    gemma3n-install-base && \
    gemma3n-install-video && \
    gemma3n-install-training && \
    gemma3n-install-unsloth
    echo "✅ 패키지 설치 완료!"
}

gemma3n_backup() {
    local timestamp=$(date +%Y%m%d_%H%M%S)
    echo "📦 프로젝트 백업 시작..."
    tar -czf "gemma3n_backup_${timestamp}.tar.gz" \
        --exclude='*.tar.gz' \
        --exclude='__pycache__' \
        --exclude='.git' \
        --exclude='*.log' .
    echo "✅ 백업 완료: gemma3n_backup_${timestamp}.tar.gz"
}

gemma3n_status() {
    echo "======================================"
    echo "🦥 Gemma3n FineVideo 환경 상태"
    echo "======================================"
    echo "📍 현재 위치: $(pwd)"
    echo "🐍 Python 버전: $(python --version 2>/dev/null || echo 'Python not found')"
    
    if python -c "import psutil" 2>/dev/null; then
        memory_info=$(python -c "import psutil; m=psutil.virtual_memory(); print(f'{m.percent:.1f}% ({m.used/1024**3:.1f}GB/{m.total/1024**3:.1f}GB)')")
        echo "💾 메모리 사용량: $memory_info"
    else
        echo "💾 메모리 사용량: psutil not available"
    fi
    
    if huggingface-cli whoami >/dev/null 2>&1; then
        hf_user=$(huggingface-cli whoami 2>/dev/null | grep '"name"' | cut -d'"' -f4)
        echo "🤗 HuggingFace: Logged in as $hf_user"
    else
        echo "🤗 HuggingFace: Not logged in"
    fi
    
    echo "======================================"
}

gemma3n_help() {
    cat << 'EOF'
🦥 Gemma3n FineVideo 파인튜닝 도우미 명령어

📦 환경 설정:
  gemma3n-env-create        - 가상환경 생성
  gemma3n-env-activate      - 가상환경 활성화
  gemma3n_install_all       - 모든 필수 패키지 설치

🔍 테스트 및 검증:
  gemma3n-test             - 전체 환경 테스트
  gemma3n-check-memory     - 메모리 사용량 확인
  gemma3n-check-gpu        - GPU 상태 확인

🤗 HuggingFace:
  gemma3n-hf-login         - HuggingFace 로그인
  gemma3n-hf-whoami        - 현재 사용자 확인

📊 모델 관리:
  gemma3n-model-list       - 모델 목록 확인
  gemma3n-checkpoint-list  - 체크포인트 목록 확인

📈 모니터링:
  gemma3n-monitor-memory   - 메모리 사용량 모니터링

🧹 정리:
  gemma3n-clean-cache      - 캐시 파일 정리
  gemma3n_backup           - 프로젝트 백업

❓ 기타:
  gemma3n-cd               - 프로젝트 디렉토리로 이동
  gemma3n_status           - 현재 상태 확인
  gemma3n_help             - 이 도움말 표시
EOF
}

echo "✅ Gemma3n 파인튜닝 Aliases 로드 완료!"
echo "💡 사용 가능한 명령어를 보려면 'gemma3n-help'를 입력하세요"
echo "📊 현재 상태를 확인하려면 'gemma3n-status'를 입력하세요" 