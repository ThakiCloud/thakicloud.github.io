
# LangExtract 관련 aliases
alias lx-install="pip install langextract"
alias lx-test="python test_langextract_basic.py"
alias lx-api-test="python test_api_usage.py"
alias lx-demo="python test_langextract_advanced.py"

# API 키 설정 helper
alias lx-setkey="echo 'export LANGEXTRACT_API_KEY=your-api-key-here' >> ~/.zshrc && source ~/.zshrc"

# 결과 파일 관리
alias lx-results="ls -la *.jsonl *.html"
alias lx-clean="rm -f *.jsonl *.html test_*.py"

# 가상환경 관리
alias lx-venv="python -m venv langextract_env && source langextract_env/bin/activate"
alias lx-activate="source langextract_env/bin/activate"
