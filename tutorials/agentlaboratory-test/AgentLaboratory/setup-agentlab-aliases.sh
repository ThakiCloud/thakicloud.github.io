#!/bin/bash

echo "🔬 Agent Laboratory zshrc aliases 설정 스크립트"
echo "=============================================="

# zshrc 파일에 Agent Laboratory aliases 추가
cat >> ~/.zshrc << 'EOF'

# Agent Laboratory Aliases
# =========================
export AGENTLAB_DIR="$HOME/thaki/thaki.github.io/tutorials/agentlaboratory-test/AgentLaboratory"

# 기본 명령어
alias agentlab="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate"
alias agentlab-run="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate && python ai_lab_repo.py"
alias agentlab-test="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate && ./test-setup.sh"

# 설정 파일 편집
alias agentlab-config="code $AGENTLAB_DIR/experiment_configs/"
alias agentlab-math="agentlab-run --yaml-location experiment_configs/MATH_agentlab.yaml"
alias agentlab-arxiv="agentlab-run --yaml-location experiment_configs/MATH_agentrxiv.yaml"

# 로그 및 결과 확인
alias agentlab-logs="cd $AGENTLAB_DIR && find . -name '*.log' -o -name 'state_saves' -type d"
alias agentlab-results="cd $AGENTLAB_DIR && ls -la results/ 2>/dev/null || echo 'No results directory found'"

# 개발환경 확인
alias agentlab-deps="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate && pip list | grep -E '(torch|transformers|openai|anthropic)'"
alias agentlab-status="cd $AGENTLAB_DIR && source venv_agent_lab/bin/activate && python -c 'import torch; import transformers; import openai; print(\"✅ All dependencies loaded successfully\")'"

EOF

echo "✅ zshrc에 Agent Laboratory aliases가 추가되었습니다!"
echo ""
echo "🔄 다음 명령어로 변경사항을 적용하세요:"
echo "source ~/.zshrc"
echo ""
echo "📋 사용 가능한 aliases:"
echo "  agentlab        - Agent Laboratory 디렉토리로 이동 및 가상환경 활성화"
echo "  agentlab-run    - Agent Laboratory 실행"
echo "  agentlab-test   - 설정 테스트 실행"
echo "  agentlab-config - 설정 파일 편집"
echo "  agentlab-math   - MATH 실험 실행"
echo "  agentlab-arxiv  - AgentRxiv 실험 실행"
echo "  agentlab-logs   - 로그 파일 확인"
echo "  agentlab-results- 결과 디렉토리 확인"
echo "  agentlab-deps   - 의존성 패키지 확인"
echo "  agentlab-status - 환경 상태 확인"
