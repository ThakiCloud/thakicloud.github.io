#!/bin/bash

# MetaGPT 테스트를 위한 zsh aliases 설정
# 사용법: ./setup-aliases.sh

echo "🔧 MetaGPT 테스트 aliases 설정 중..."

# 현재 디렉토리 저장
METAGPT_TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# aliases 정의
ALIASES="
# MetaGPT 테스트 aliases
export METAGPT_TEST_DIR=\"$METAGPT_TEST_DIR\"
alias mtest=\"cd \$METAGPT_TEST_DIR\"
alias menv=\"source \$METAGPT_TEST_DIR/metagpt-test-env/bin/activate\"
alias mcheck=\"python \$METAGPT_TEST_DIR/test_installation.py\"
alias msimple=\"python \$METAGPT_TEST_DIR/simple_project_test.py\"
alias mdata=\"python \$METAGPT_TEST_DIR/data_analysis_test.py\"
alias mconfig=\"nano ~/.metagpt/config2.yaml\"
alias mlog=\"tail -f ~/.metagpt/logs/metagpt.log\"
alias mclean=\"rm -rf \$METAGPT_TEST_DIR/workspace/*\"
alias mhelp=\"echo '
🤖 MetaGPT 테스트 명령어:
  mtest   - 테스트 디렉토리로 이동
  menv    - 가상환경 활성화
  mcheck  - 설치 확인 테스트
  msimple - 간단한 프로젝트 생성 테스트
  mdata   - 데이터 분석 테스트
  mconfig - 설정 파일 편집
  mlog    - 로그 실시간 확인
  mclean  - 생성된 프로젝트 정리
  mhelp   - 이 도움말 표시
'\"
"

# .zshrc에 추가
if [[ -f ~/.zshrc ]]; then
    # 기존 MetaGPT aliases 제거
    sed -i.bak '/# MetaGPT 테스트 aliases/,/^$/d' ~/.zshrc
    
    # 새 aliases 추가
    echo "$ALIASES" >> ~/.zshrc
    
    echo "✅ ~/.zshrc에 aliases 추가됨"
    echo "🔄 다음 명령어로 적용: source ~/.zshrc"
else
    echo "⚠️ ~/.zshrc 파일이 없습니다"
    echo "💡 수동으로 다음 내용을 shell 설정 파일에 추가하세요:"
    echo "$ALIASES"
fi

echo ""
echo "🎉 Aliases 설정 완료!"
echo ""
echo "📋 사용 가능한 명령어:"
echo "  mtest   - 테스트 디렉토리로 이동"
echo "  menv    - 가상환경 활성화"
echo "  mcheck  - 설치 확인"
echo "  msimple - 간단한 테스트"
echo "  mdata   - 데이터 분석 테스트"
echo "  mconfig - 설정 편집"
echo "  mlog    - 로그 확인"
echo "  mclean  - 정리"
echo "  mhelp   - 도움말"
