#!/bin/bash

# n8n-free-templates zshrc aliases 설정 스크립트

echo "🚀 n8n-free-templates aliases 설정"
echo "==================================="

# 백업 생성
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)
    echo "✅ zshrc 백업 생성됨"
fi

# n8n aliases 추가
cat >> ~/.zshrc << 'EOF'

# n8n-free-templates 관련 aliases
# =====================================
# 생성일: $(date +%Y-%m-%d)

# 기본 n8n 관리
alias n8n-start="docker run -d --name n8n -p 5678:5678 -v ~/.n8n:/home/node/.n8n docker.n8n.io/n8nio/n8n"
alias n8n-stop="docker stop n8n && docker rm n8n"
alias n8n-logs="docker logs -f n8n"
alias n8n-url="echo '🌐 n8n 접속: http://localhost:5678'"

# 템플릿 관리
alias n8n-templates="cd ~/.n8n/templates"
alias n8n-backup="n8n-backup-workflows"

# 빠른 접근
alias n8n-web="open http://localhost:5678"
alias n8n-status="docker ps | grep n8n || echo '❌ n8n 컨테이너가 실행되지 않았습니다'"

# 워크플로우 관리 함수
function n8n-clone-templates() {
    local target_dir=${1:-~/.n8n/templates}
    echo "📥 n8n-free-templates 클론 중..."
    
    if [ -d "$target_dir" ]; then
        echo "⚠️  $target_dir 이미 존재합니다."
        read -p "덮어쓰시겠습니까? (y/N): " confirm
        if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
            echo "취소되었습니다."
            return 1
        fi
        rm -rf "$target_dir"
    fi
    
    git clone https://github.com/wassupjay/n8n-free-templates.git "$target_dir"
    echo "✅ 템플릿 클론 완료: $target_dir"
}

function n8n-list-templates() {
    local category=${1:-"all"}
    local templates_dir="$HOME/.n8n/templates"
    
    if [ ! -d "$templates_dir" ]; then
        echo "❌ 템플릿 디렉토리가 없습니다. n8n-clone-templates를 먼저 실행하세요."
        return 1
    fi
    
    cd "$templates_dir"
    
    if [ "$category" = "all" ]; then
        echo "📋 모든 카테고리의 템플릿:"
        find . -name "*.json" -type f | sed 's|./||' | sort
    else
        echo "📋 $category 카테고리 템플릿:"
        find "./$category" -name "*.json" -type f 2>/dev/null | sed 's|./||' | sort
    fi
}

function n8n-template-info() {
    local template_file=$1
    local templates_dir="$HOME/.n8n/templates"
    
    if [ -z "$template_file" ]; then
        echo "사용법: n8n-template-info <템플릿파일>"
        echo "예시: n8n-template-info AI_ML/product_description_generator.json"
        return 1
    fi
    
    local full_path="$templates_dir/$template_file"
    
    if [ ! -f "$full_path" ]; then
        echo "❌ 템플릿 파일을 찾을 수 없습니다: $template_file"
        return 1
    fi
    
    echo "📄 템플릿 정보: $template_file"
    echo "=================="
    
    # 파일 크기
    local size=$(du -h "$full_path" | cut -f1)
    echo "📏 파일 크기: $size"
    
    # JSON 구조 분석
    if command -v jq >/dev/null 2>&1; then
        local node_count=$(jq '.nodes | length' "$full_path" 2>/dev/null)
        echo "🔗 노드 수: $node_count개"
        
        # 노드 타입 추출
        echo "🧩 노드 타입:"
        jq -r '.nodes[].type' "$full_path" 2>/dev/null | sort | uniq -c | sed 's/^/  /'
    else
        echo "💡 jq가 설치되지 않아 상세 분석을 건너뜁니다."
    fi
}

function n8n-import-template() {
    local template_file=$1
    local templates_dir="$HOME/.n8n/templates"
    
    if [ -z "$template_file" ]; then
        echo "사용법: n8n-import-template <템플릿파일>"
        echo "예시: n8n-import-template AI_ML/product_description_generator.json"
        return 1
    fi
    
    local full_path="$templates_dir/$template_file"
    
    if [ ! -f "$full_path" ]; then
        echo "❌ 템플릿 파일을 찾을 수 없습니다: $template_file"
        return 1
    fi
    
    echo "📤 템플릿 가져오기: $template_file"
    
    # n8n이 실행 중인지 확인
    if ! curl -s http://localhost:5678/healthz >/dev/null 2>&1; then
        echo "❌ n8n이 실행되지 않았습니다. n8n-start를 먼저 실행하세요."
        return 1
    fi
    
    # 웹 브라우저 열기
    if command -v open >/dev/null 2>&1; then
        open http://localhost:5678
    fi
    
    echo "💡 웹 브라우저에서 수동 임포트:"
    echo "1. Settings → Import Workflows 선택"
    echo "2. 다음 파일 선택: $full_path"
    
    # 파일 내용을 클립보드에 복사 (macOS)
    if command -v pbcopy >/dev/null 2>&1; then
        cat "$full_path" | pbcopy
        echo "✅ 템플릿 JSON이 클립보드에 복사되었습니다."
    fi
}

function n8n-env-check() {
    echo "🔍 n8n 환경 확인"
    echo "=================="
    
    # Docker 상태 확인
    if command -v docker >/dev/null 2>&1; then
        echo "✅ Docker 설치됨"
        if docker ps | grep -q n8n; then
            echo "✅ n8n 컨테이너 실행 중"
            echo "🌐 접속: http://localhost:5678"
        else
            echo "⚠️  n8n 컨테이너 정지됨"
        fi
    else
        echo "❌ Docker 미설치"
    fi
    
    # 포트 확인
    if lsof -i :5678 >/dev/null 2>&1; then
        echo "✅ 포트 5678 사용 중"
    else
        echo "⚠️  포트 5678 사용 안함"
    fi
    
    # 데이터 디렉토리 확인
    if [ -d "$HOME/.n8n" ]; then
        local size=$(du -sh "$HOME/.n8n" | cut -f1)
        echo "✅ n8n 데이터 디렉토리: $HOME/.n8n ($size)"
    else
        echo "⚠️  n8n 데이터 디렉토리 없음"
    fi
    
    # 템플릿 디렉토리 확인
    if [ -d "$HOME/.n8n/templates" ]; then
        local template_count=$(find "$HOME/.n8n/templates" -name "*.json" | wc -l)
        echo "✅ 템플릿: ${template_count}개"
    else
        echo "⚠️  템플릿 디렉토리 없음 (n8n-clone-templates 실행 필요)"
    fi
}

function n8n-dev-setup() {
    echo "🚀 n8n 개발 환경 설정"
    echo "======================"
    
    # 필요한 디렉토리 생성
    mkdir -p ~/.n8n/{backups,templates,logs}
    
    # 환경 변수 템플릿 생성
    if [ ! -f ~/.n8n/.env.template ]; then
        cat > ~/.n8n/.env.template << 'ENVEOF'
# n8n 기본 설정
N8N_BASIC_AUTH_ACTIVE=true
N8N_BASIC_AUTH_USER=admin
N8N_BASIC_AUTH_PASSWORD=your_secure_password

# 웹훅 URL
WEBHOOK_URL=https://your-domain.com

# AI 서비스 API 키
OPENAI_API_KEY=sk-your-openai-key
ANTHROPIC_API_KEY=your-anthropic-key
COHERE_API_KEY=your-cohere-key

# Vector DB 설정
PINECONE_API_KEY=your-pinecone-key
PINECONE_ENVIRONMENT=your-environment
WEAVIATE_URL=your-weaviate-url
WEAVIATE_API_KEY=your-weaviate-key

# 데이터베이스 (선택사항)
DB_TYPE=postgresdb
DB_POSTGRESDB_HOST=localhost
DB_POSTGRESDB_PORT=5432
DB_POSTGRESDB_DATABASE=n8n
DB_POSTGRESDB_USER=n8n
DB_POSTGRESDB_PASSWORD=password
ENVEOF
        echo "✅ 환경 변수 템플릿 생성: ~/.n8n/.env.template"
    fi
    
    # 템플릿 클론
    if [ ! -d ~/.n8n/templates ]; then
        n8n-clone-templates
    fi
    
    echo "🎉 개발 환경 설정 완료!"
    echo ""
    echo "💡 다음 단계:"
    echo "1. ~/.n8n/.env.template을 ~/.n8n/.env로 복사"
    echo "2. API 키들을 실제 값으로 변경"
    echo "3. n8n-start로 n8n 실행"
}

# 도움말
function n8n-help() {
    echo "🆘 n8n-free-templates 도구 도움말"
    echo "==================================="
    echo ""
    echo "🔧 기본 명령어:"
    echo "  n8n-start                      - n8n Docker 컨테이너 시작"
    echo "  n8n-stop                       - n8n Docker 컨테이너 정지"
    echo "  n8n-logs                       - n8n 로그 실시간 확인"
    echo "  n8n-status                     - n8n 상태 확인"
    echo "  n8n-web                        - n8n 웹 UI 열기"
    echo ""
    echo "📚 템플릿 관리:"
    echo "  n8n-clone-templates [디렉토리]  - 템플릿 저장소 클론"
    echo "  n8n-list-templates [카테고리]   - 템플릿 목록 표시"
    echo "  n8n-template-info <파일>        - 템플릿 상세 정보"
    echo "  n8n-import-template <파일>      - 템플릿 가져오기"
    echo ""
    echo "🔍 유틸리티:"
    echo "  n8n-env-check                  - 환경 상태 확인"
    echo "  n8n-dev-setup                  - 개발 환경 설정"
    echo ""
    echo "💡 사용 예시:"
    echo "  n8n-dev-setup                  # 최초 설정"
    echo "  n8n-start                      # n8n 시작"
    echo "  n8n-list-templates AI_ML       # AI/ML 템플릿 목록"
    echo "  n8n-import-template AI_ML/product_description_generator.json"
    echo ""
    echo "📖 더 많은 정보:"
    echo "  https://github.com/wassupjay/n8n-free-templates"
}

# End of n8n-free-templates Aliases
EOF

echo ""
echo "✅ n8n-free-templates aliases 설치 완료!"
echo ""
echo "🔄 변경사항 적용:"
echo "   source ~/.zshrc"
echo ""
echo "📖 도움말 확인:"
echo "   n8n-help"
echo ""
echo "🚀 빠른 시작:"
echo "   n8n-dev-setup"
echo "   n8n-start"
echo "   n8n-web" 