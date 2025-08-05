#!/bin/bash

# Chatterbox-vLLM zshrc 별칭 설정 스크립트
# 작성자: Thaki Cloud

echo "🔧 Chatterbox-vLLM zshrc 별칭 설정"
echo "=================================="

# 백업 생성
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ 기존 .zshrc 백업 완료"
fi

# 별칭 추가
cat >> ~/.zshrc << 'EOF'

# =======================================
# Chatterbox-vLLM 관련 별칭 (추가일: $(date +%Y-%m-%d))
# =======================================

# 프로젝트 디렉토리 관련
export CHATTERBOX_VLLM_DIR="$HOME/ai-projects/chatterbox-vllm-test"
alias chatterbox-vllm="cd \$CHATTERBOX_VLLM_DIR/chatterbox-vllm && source ../chatterbox-vllm-env/bin/activate"
alias cbvllm="chatterbox-vllm"

# 테스트 및 실행 관련
alias cbvllm-test="cd \$CHATTERBOX_VLLM_DIR/chatterbox-vllm && source ../chatterbox-vllm-env/bin/activate && python test_basic.py"
alias cbvllm-gradio="cd \$CHATTERBOX_VLLM_DIR/chatterbox-vllm && source ../chatterbox-vllm-env/bin/activate && python gradio_tts_app.py"
alias cbvllm-bench="cd \$CHATTERBOX_VLLM_DIR/chatterbox-vllm && source ../chatterbox-vllm-env/bin/activate && python benchmark.py"
alias cbvllm-example="cd \$CHATTERBOX_VLLM_DIR/chatterbox-vllm && source ../chatterbox-vllm-env/bin/activate && python example-tts.py"

# 개발 유틸리티
alias cbvllm-status="cd \$CHATTERBOX_VLLM_DIR && echo 'Project: \$(pwd)' && echo 'Python: \$(source chatterbox-vllm-env/bin/activate && python --version)' && echo 'GPU: \$(python -c \"import torch; print(torch.backends.mps.is_available())\" 2>/dev/null || echo 'N/A')'"
alias cbvllm-clean="cd \$CHATTERBOX_VLLM_DIR && rm -rf *.wav *.mp3 *.log"

# 모델 다운로드
alias cbvllm-download="cd \$CHATTERBOX_VLLM_DIR/chatterbox-vllm && source ../chatterbox-vllm-env/bin/activate && python -c 'from huggingface_hub import snapshot_download; snapshot_download(repo_id=\"chatterbox/chatterbox-vllm\", local_dir=\"./models\")'"

# 오디오 재생 (macOS)
alias play-wav="afplay"
alias cbvllm-play="cd \$CHATTERBOX_VLLM_DIR/chatterbox-vllm && find . -name '*.wav' -exec afplay {} \;"

# GPU/시스템 모니터링
alias gpu-info="system_profiler SPDisplaysDataType"
alias torch-info="python -c 'import torch; print(f\"PyTorch: {torch.__version__}\"); print(f\"MPS: {torch.backends.mps.is_available()}\"); print(f\"Device: {torch.device(\"mps\" if torch.backends.mps.is_available() else \"cpu\")}\")"

EOF

echo "✅ zshrc 별칭 추가 완료"
echo ""
echo "🔄 다음 명령어로 설정을 적용하세요:"
echo "source ~/.zshrc"
echo ""
echo "📋 사용 가능한 별칭들:"
echo "  cbvllm                - 프로젝트 디렉토리로 이동 & 가상환경 활성화"
echo "  cbvllm-test          - 기본 환경 테스트 실행"
echo "  cbvllm-gradio        - Gradio 웹 인터페이스 실행"
echo "  cbvllm-bench         - 성능 벤치마크 실행"
echo "  cbvllm-example       - 기본 TTS 예제 실행"
echo "  cbvllm-download      - 모델 다운로드"
echo "  cbvllm-status        - 환경 상태 확인"
echo "  cbvllm-clean         - 생성된 오디오 파일 정리"
echo "  cbvllm-play          - 생성된 오디오 파일 재생"