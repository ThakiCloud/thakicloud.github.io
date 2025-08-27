#!/bin/bash
# Vanna Text-to-SQL 관련 zshrc aliases 설정 스크립트

echo "🔧 Vanna Text-to-SQL zshrc aliases 설정 중..."

# zshrc 백업 생성
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
echo "📄 zshrc 백업 완료: ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

# Vanna aliases 추가
cat >> ~/.zshrc << 'ALIASES_EOF'

# ===== Vanna Text-to-SQL Aliases =====
# 환경 관리
alias vanna-env="source vanna-env/bin/activate"
alias vanna-install="pip install vanna pandas plotly chromadb openai sqlite3"
alias vanna-fresh="rm -rf vanna-env && python3 -m venv vanna-env && vanna-env && vanna-install"

# 테스트 및 실행
alias vanna-test="python3 scripts/test_vanna_complete.py"
alias vanna-server="python3 vanna_api_server.py"
alias vanna-check="python3 -c 'import vanna; print(f\"Vanna version: {vanna.__version__}\")' 2>/dev/null || echo 'Vanna not installed'"

# 데이터베이스 관리
alias sqlite-test="sqlite3 ecommerce_test.db"
alias db-backup="cp ecommerce_test.db ecommerce_backup_\$(date +%Y%m%d).db"
alias db-schema="sqlite3 ecommerce_test.db '.schema'"
alias db-tables="sqlite3 ecommerce_test.db '.tables'"

# 개발 도구
alias vanna-clean="rm -rf vanna_vectorstore/ *.db *.log __pycache__/ .chroma/"
alias vanna-logs="tail -f vanna_production.log"
alias vanna-errors="grep ERROR vanna_production.log | tail -10"

# API 및 모니터링
alias vanna-metrics="curl -s http://localhost:5000/api/metrics | python3 -m json.tool 2>/dev/null || echo 'Server not running'"
alias vanna-health="curl -s http://localhost:5000/health 2>/dev/null || echo 'Server not accessible'"

# 개발 환경 확인
alias vanna-deps="pip list | grep -E '(vanna|openai|chromadb|pandas|plotly)'"
alias vanna-env-check="echo 'Python:' \$(python3 --version) && echo 'Pip:' \$(pip --version) && vanna-check"

# 로그 분석
alias vanna-success="grep 'Query successful' vanna_production.log | wc -l"
alias vanna-failed="grep 'Query failed' vanna_production.log | wc -l"
alias vanna-stats="echo 'Successful:' \$(vanna-success) 'Failed:' \$(vanna-failed)"

# 데이터 분석
alias sql-analyze="sqlite3 ecommerce_test.db 'ANALYZE; .quit'"
alias sql-vacuum="sqlite3 ecommerce_test.db 'VACUUM; .quit'"

# 개발 워크플로우
alias vanna-init="mkdir -p vanna-project && cd vanna-project && python3 -m venv vanna-env && vanna-env && vanna-install"
alias vanna-demo="python3 -c 'from scripts.test_vanna_complete import test_simulation_mode; test_simulation_mode()'"

echo "✅ Vanna Text-to-SQL aliases 설정 완료!"
echo "📝 주요 명령어:"
echo "  vanna-env-check - 환경 확인"
echo "  vanna-test      - 테스트 실행"
echo "  vanna-init      - 새 프로젝트 초기화"
echo "  vanna-demo      - 데모 실행"
echo "  sqlite-test     - SQLite 접속"
echo "  vanna-stats     - 성능 통계"
echo ""
echo "🔄 변경사항을 적용하려면 'source ~/.zshrc' 또는 새 터미널을 열어주세요."
ALIASES_EOF
