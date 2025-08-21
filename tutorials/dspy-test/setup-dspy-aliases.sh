#!/bin/bash

# DSPy 테스트 설정 스크립트

echo "🚀 DSPy 테스트 환경 설정 중..."

# DSPy 디렉토리 설정
export DSPY_TEST_DIR="$(pwd)"
export DSPY_VENV_DIR="$DSPY_TEST_DIR/dspy-env"

# Alias 설정
cat >> ~/.zshrc << 'EOF'

# === DSPy 테스트 Aliases ===
alias dspy-dir="cd $HOME/thaki/thaki.github.io/tutorials/dspy-test"
alias dspy-activate="source $HOME/thaki/thaki.github.io/tutorials/dspy-test/dspy-env/bin/activate"
alias dspy-test-basic="cd $HOME/thaki/thaki.github.io/tutorials/dspy-test && source dspy-env/bin/activate && python test_dspy_basic.py"
alias dspy-test-advanced="cd $HOME/thaki/thaki.github.io/tutorials/dspy-test && source dspy-env/bin/activate && python test_dspy_advanced.py"
alias dspy-version="cd $HOME/thaki/thaki.github.io/tutorials/dspy-test && source dspy-env/bin/activate && python -c 'import dspy; print(f\"DSPy {dspy.__version__}\")'"

# DSPy 개발 도우미
alias dspy-install="cd $HOME/thaki/thaki.github.io/tutorials/dspy-test && source dspy-env/bin/activate && pip install -U dspy"
alias dspy-jupyter="cd $HOME/thaki/thaki.github.io/tutorials/dspy-test && source dspy-env/bin/activate && pip install jupyter && jupyter notebook"
alias dspy-clean="cd $HOME/thaki/thaki.github.io/tutorials/dspy-test && rm -rf dspy-env && python -m venv dspy-env"

EOF

echo "✅ Aliases가 ~/.zshrc에 추가되었습니다."
echo "📝 다음 명령어로 변경사항을 적용하세요:"
echo "   source ~/.zshrc"
echo ""
echo "🔧 사용 가능한 명령어들:"
echo "  dspy-dir                # DSPy 테스트 디렉토리로 이동"
echo "  dspy-activate           # DSPy 가상환경 활성화"
echo "  dspy-test-basic         # 기본 기능 테스트 실행"
echo "  dspy-test-advanced      # 고급 기능 테스트 실행"
echo "  dspy-version            # DSPy 버전 확인"
echo "  dspy-install            # DSPy 최신 버전 설치"
echo "  dspy-jupyter            # Jupyter 노트북 실행"
echo "  dspy-clean              # 가상환경 초기화"

# 권한 설정
chmod +x "$DSPY_TEST_DIR/setup-dspy-aliases.sh"

echo ""
echo "🎉 DSPy 테스트 환경 설정 완료!"
