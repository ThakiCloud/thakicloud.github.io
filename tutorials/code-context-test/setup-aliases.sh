#!/bin/bash

# Code Context MCP를 위한 zshrc aliases 설정 스크립트
echo "🔧 Code Context MCP - zshrc Aliases 설정"
echo "========================================"

# 백업 생성
echo "📋 ~/.zshrc 백업 생성 중..."
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
echo "✅ 백업 완료: ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)"

# Code Context aliases 추가
echo "
# Code Context MCP Aliases
# ========================
# Added by Code Context setup script - $(date)

# 기본 Code Context 명령어
alias cc-help='npx @zilliz/code-context-mcp@latest --help'
alias cc-version='npm list @zilliz/code-context-mcp'

# 환경 변수 설정 도우미
alias cc-env-check='echo \"OPENAI_API_KEY: \${OPENAI_API_KEY:+SET}\"; echo \"MILVUS_ADDRESS: \${MILVUS_ADDRESS:+SET}\"; echo \"EMBEDDING_PROVIDER: \${EMBEDDING_PROVIDER:-OpenAI}\"'

# 프로젝트 인덱싱
function cc-index-project() {
    if [ -z \"\$1\" ]; then
        echo \"📁 현재 디렉토리 인덱싱...\"
        PROJECT_PATH=\".\"
    else
        echo \"📁 \$1 디렉토리 인덱싱...\"
        PROJECT_PATH=\"\$1\"
    fi
    
    echo \"🚀 Code Context로 \$PROJECT_PATH 인덱싱 시작\"
    echo \"⚠️  API 키가 설정되어 있는지 확인하세요: cc-env-check\"
    
    # 실제로는 MCP 서버를 통해 인덱싱하겠지만, 여기서는 시뮬레이션
    echo \"📊 예상 결과: TypeScript, JavaScript, Python 파일들을 벡터 DB에 저장\"
}

# 시맨틱 검색 시뮬레이션
function cc-search() {
    if [ -z \"\$1\" ]; then
        echo \"사용법: cc-search 'search query'\"
        echo \"예시: cc-search 'authentication logic'\"
        return 1
    fi
    
    echo \"🔍 시맨틱 검색: \$1\"
    echo \"⚠️  실제 검색은 AI 에이전트(Claude Code, Cursor 등)에서 수행됩니다\"
    echo \"📝 검색 타입: 의미 기반 코드 검색\"
    echo \"🎯 검색 범위: 인덱싱된 코드베이스\"
}

# MCP 서버 테스트
function cc-test() {
    echo \"🧪 Code Context MCP 테스트 실행\"
    if [ -f \"test-mcp-basic.js\" ]; then
        node test-mcp-basic.js
    else
        echo \"❌ test-mcp-basic.js 파일을 찾을 수 없습니다\"
        echo \"💡 테스트 파일을 생성하시겠습니까? (y/n)\"
    fi
}

# 설정 파일 생성 도우미
function cc-setup-claude() {
    echo \"🤖 Claude Code MCP 설정 생성\"
    echo \"📝 ~/.config/Claude/claude_desktop_config.json\"
    echo \"⚠️  실제 API 키를 입력해야 합니다\"
    
    cat << 'EOF'
{
  \"mcpServers\": {
    \"code-context\": {
      \"command\": \"npx\",
      \"args\": [\"@zilliz/code-context-mcp@latest\"],
      \"env\": {
        \"OPENAI_API_KEY\": \"your-openai-api-key\",
        \"MILVUS_ADDRESS\": \"your-zilliz-cloud-endpoint\",
        \"MILVUS_TOKEN\": \"your-zilliz-cloud-token\"
      }
    }
  }
}
EOF
}

function cc-setup-cursor() {
    echo \"✏️  Cursor MCP 설정 생성\"
    echo \"📝 Cursor의 mcp_settings.json\"
    echo \"⚠️  실제 API 키를 입력해야 합니다\"
    
    cat << 'EOF'
{
  \"mcpServers\": {
    \"code-context\": {
      \"command\": \"npx\",
      \"args\": [\"@zilliz/code-context-mcp@latest\"],
      \"env\": {
        \"OPENAI_API_KEY\": \"your-openai-api-key\",
        \"MILVUS_ADDRESS\": \"your-zilliz-cloud-endpoint\",
        \"MILVUS_TOKEN\": \"your-zilliz-cloud-token\"
      }
    }
  }
}
EOF
}

# 프로젝트 정리
function cc-clean() {
    echo \"🧹 Code Context 프로젝트 정리\"
    echo \"📁 node_modules 및 임시 파일 제거\"
    
    if [ -d \"node_modules\" ]; then
        echo \"🗑️  node_modules 삭제 중...\"
        rm -rf node_modules
    fi
    
    if [ -f \"package-lock.json\" ]; then
        echo \"🗑️  package-lock.json 삭제 중...\"
        rm package-lock.json
    fi
    
    echo \"✅ 정리 완료\"
}

# Code Context 상태 확인
function cc-status() {
    echo \"📊 Code Context MCP 상태 확인\"
    echo \"================================\"
    
    # 패키지 설치 확인
    if npm list @zilliz/code-context-mcp >/dev/null 2>&1; then
        echo \"✅ @zilliz/code-context-mcp 설치됨\"
        npm list @zilliz/code-context-mcp --depth=0
    else
        echo \"❌ @zilliz/code-context-mcp 설치되지 않음\"
    fi
    
    # 환경 변수 확인
    echo \"\"
    cc-env-check
    
    # 현재 디렉토리 파일 수
    echo \"\"
    echo \"📁 현재 디렉토리 코드 파일:\"
    find . -name \"*.ts\" -o -name \"*.js\" -o -name \"*.py\" | head -10 | while read file; do
        echo \"   📄 \$file\"
    done
}

# 도움말
function cc-help-aliases() {
    echo \"🆘 Code Context MCP Aliases 도움말\"
    echo \"==================================\"
    echo \"\"
    echo \"🔧 기본 명령어:\"
    echo \"  cc-help          - MCP 서버 도움말\"
    echo \"  cc-version       - 설치된 버전 확인\"
    echo \"  cc-status        - 전체 상태 확인\"
    echo \"\"
    echo \"🔍 검색 관련:\"
    echo \"  cc-search 'query' - 시맨틱 검색 시뮬레이션\"
    echo \"  cc-index-project  - 프로젝트 인덱싱\"
    echo \"\"
    echo \"⚙️  설정 관련:\"
    echo \"  cc-env-check     - 환경 변수 확인\"
    echo \"  cc-setup-claude  - Claude Code 설정 출력\"
    echo \"  cc-setup-cursor  - Cursor 설정 출력\"
    echo \"\"
    echo \"🧪 테스트 및 정리:\"
    echo \"  cc-test          - 기본 테스트 실행\"
    echo \"  cc-clean         - 프로젝트 정리\"
    echo \"\"
    echo \"💡 사용 예시:\"
    echo \"  cc-search 'vector similarity calculation'\"
    echo \"  cc-index-project ./my-code\"
    echo \"  cc-status\"
}

# End of Code Context MCP Aliases
" >> ~/.zshrc

echo ""
echo "✅ zshrc aliases 추가 완료!"
echo ""
echo "🔄 변경사항을 적용하려면 다음 명령어를 실행하세요:"
echo "   source ~/.zshrc"
echo ""
echo "📖 사용 가능한 명령어를 확인하려면:"
echo "   cc-help-aliases"
echo ""
echo "🎉 설정 완료! Code Context MCP를 즐겁게 사용하세요!" 