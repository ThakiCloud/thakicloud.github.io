#!/bin/bash

# vLLM CLI 별칭 자동 설정 스크립트
# macOS zsh 환경에 최적화

echo "🔧 vLLM CLI 별칭 설정 스크립트"
echo "============================="

# 현재 셸 확인
CURRENT_SHELL=$(echo $SHELL)
echo "🐚 현재 셸: $CURRENT_SHELL"

# zsh 설정 파일 경로
ZSHRC_FILE="$HOME/.zshrc"

# 별칭 블록 시작/끝 마커
ALIAS_START="# === vLLM CLI Aliases START ==="
ALIAS_END="# === vLLM CLI Aliases END ==="

# 기존 별칭 블록 제거 함수
remove_existing_aliases() {
    if [[ -f "$ZSHRC_FILE" ]]; then
        # 기존 별칭 블록이 있는지 확인
        if grep -q "$ALIAS_START" "$ZSHRC_FILE"; then
            echo "🗑️  기존 vLLM CLI 별칭 제거 중..."
            
            # 임시 파일을 사용해서 별칭 블록 제거
            awk "/$ALIAS_START/,/$ALIAS_END/ {next} {print}" "$ZSHRC_FILE" > "${ZSHRC_FILE}.tmp"
            mv "${ZSHRC_FILE}.tmp" "$ZSHRC_FILE"
            
            echo "✅ 기존 별칭이 제거되었습니다."
        fi
    fi
}

# 새 별칭 추가 함수
add_new_aliases() {
    echo "📝 새로운 vLLM CLI 별칭 추가 중..."
    
    cat >> "$ZSHRC_FILE" << 'EOF'

# === vLLM CLI Aliases START ===
# vLLM CLI 기본 명령어 별칭
alias vllm="vllm-cli"
alias vserve="vllm-cli serve"
alias vstatus="vllm-cli status"
alias vmodels="vllm-cli models"
alias vinfo="vllm-cli info"
alias vlogs="vllm-cli logs"
alias vstop="vllm-cli stop"

# vLLM CLI 프로필 별칭
alias vquick="vllm-cli serve --profile standard"
alias vfast="vllm-cli serve --profile high_throughput"
alias vmem="vllm-cli serve --profile low_memory"
alias vmoe="vllm-cli serve --profile moe_optimized"

# vLLM CLI 유틸리티 별칭
alias vtest="bash ~/work/thakicloud/thakicloud.github.io/tutorials/vllm-cli-test/test-vllm-cli-setup.sh"
alias vhelp="vllm-cli --help"

# 자주 사용하는 모델 서빙 별칭 (예시)
alias vserve-small="vllm-cli serve microsoft/DialoGPT-small --port 8000"
alias vserve-medium="vllm-cli serve microsoft/DialoGPT-medium --port 8001"

# 서버 관리 편의 별칭
alias vkill="pkill -f vllm"  # 모든 vLLM 프로세스 종료 (주의!)
alias vps="ps aux | grep vllm"  # vLLM 관련 프로세스 확인

# GPU 모니터링 별칭 (NVIDIA GPU가 있는 경우)
if command -v nvidia-smi &> /dev/null; then
    alias vgpu="watch -n 1 nvidia-smi"
    alias vgpu-simple="nvidia-smi --query-gpu=utilization.gpu,memory.used,memory.total --format=csv"
fi

# 개발 편의 별칭
alias vlog-tail="tail -f ~/.cache/vllm-cli/logs/latest.log"
alias vconfig="code ~/.config/vllm-cli/"

# === vLLM CLI Aliases END ===
EOF

    echo "✅ 새로운 별칭이 추가되었습니다."
}

# 별칭 사용법 출력
show_usage() {
    echo ""
    echo "🎯 추가된 별칭 사용법"
    echo "===================="
    echo ""
    echo "📦 기본 명령어:"
    echo "  vllm          → vllm-cli (메인 CLI)"
    echo "  vserve        → vllm-cli serve (모델 서빙)"
    echo "  vstatus       → vllm-cli status (서버 상태)"
    echo "  vmodels       → vllm-cli models (모델 목록)"
    echo "  vinfo         → vllm-cli info (시스템 정보)"
    echo "  vlogs         → vllm-cli logs (로그 보기)"
    echo "  vstop         → vllm-cli stop (서버 중지)"
    echo ""
    echo "🚀 프로필 별칭:"
    echo "  vquick        → 표준 프로필로 서빙"
    echo "  vfast         → 고성능 프로필로 서빙"
    echo "  vmem          → 저메모리 프로필로 서빙"
    echo "  vmoe          → MoE 최적화 프로필로 서빙"
    echo ""
    echo "🔧 유틸리티:"
    echo "  vtest         → 설치 테스트 스크립트 실행"
    echo "  vhelp         → 도움말 보기"
    echo "  vgpu          → GPU 모니터링 (NVIDIA)"
    echo ""
    echo "📖 사용 예시:"
    echo "  vserve microsoft/DialoGPT-medium"
    echo "  vfast meta-llama/Llama-2-7b-chat-hf"
    echo "  vstatus --port 8000"
    echo ""
}

# 메인 실행 부분
main() {
    # zsh 확인
    if [[ "$CURRENT_SHELL" != *"zsh"* ]]; then
        echo "⚠️  현재 셸이 zsh가 아닙니다. 이 스크립트는 zsh용입니다."
        echo "💡 bash 사용자는 ~/.bashrc를 수동으로 편집해주세요."
        exit 1
    fi
    
    # .zshrc 파일 존재 확인
    if [[ ! -f "$ZSHRC_FILE" ]]; then
        echo "📝 .zshrc 파일이 없습니다. 새로 생성합니다."
        touch "$ZSHRC_FILE"
    fi
    
    # 사용자 확인
    echo ""
    echo "🤔 다음 작업을 수행합니다:"
    echo "   1. 기존 vLLM CLI 별칭 제거 (있는 경우)"
    echo "   2. 새로운 vLLM CLI 별칭 추가"
    echo "   3. ~/.zshrc 파일 수정"
    echo ""
    
    read -p "계속하시겠습니까? (y/n): " confirm
    
    if [[ $confirm == "y" || $confirm == "Y" ]]; then
        # 백업 생성
        echo "💾 .zshrc 백업 생성 중..."
        cp "$ZSHRC_FILE" "${ZSHRC_FILE}.backup.$(date +%Y%m%d_%H%M%S)"
        
        # 기존 별칭 제거 및 새 별칭 추가
        remove_existing_aliases
        add_new_aliases
        
        echo ""
        echo "🎉 별칭 설정이 완료되었습니다!"
        echo ""
        echo "🔄 다음 명령어로 변경사항을 적용하세요:"
        echo "   source ~/.zshrc"
        echo ""
        echo "또는 새 터미널을 열어주세요."
        
        # 사용법 표시
        show_usage
        
        # 자동 적용 옵션
        echo ""
        read -p "지금 바로 변경사항을 적용하시겠습니까? (y/n): " apply_now
        
        if [[ $apply_now == "y" || $apply_now == "Y" ]]; then
            source "$ZSHRC_FILE"
            echo "✅ 변경사항이 적용되었습니다!"
            echo ""
            echo "🧪 테스트해보세요:"
            echo "   vllm --version"
        fi
        
    else
        echo "❌ 설정이 취소되었습니다."
        exit 0
    fi
}

# 스크립트 실행
main

echo ""
echo "📚 추가 정보:"
echo "- 별칭을 수정하려면 이 스크립트를 다시 실행하세요"
echo "- 별칭을 제거하려면 ~/.zshrc에서 vLLM CLI Aliases 블록을 삭제하세요"
echo "- 문제가 있으면 백업 파일 (~/.zshrc.backup.*)을 복원하세요"
