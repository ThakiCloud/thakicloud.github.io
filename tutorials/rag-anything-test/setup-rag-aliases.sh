#!/bin/bash

# RAG-Anything zshrc Aliases 설정 스크립트
# macOS에서 RAG-Anything 관리를 위한 편의 기능 추가

echo "🔧 RAG-Anything zshrc aliases 설정 스크립트"
echo "==========================================="

# 백업 생성
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)
    echo "✅ 기존 .zshrc 백업 완료"
fi

# RAG-Anything aliases 추가
cat >> ~/.zshrc << 'EOF'

# ===== RAG-Anything Multimodal RAG System Aliases =====
export RAG_ANYTHING_DIR="$HOME/rag-anything"
export RAG_ENV="$HOME/rag-anything-env"

# 환경 관리 명령어
alias rag-activate="source $RAG_ENV/bin/activate && echo '🤖 RAG-Anything 환경 활성화됨'"
alias rag-deactivate="deactivate && echo '💤 RAG-Anything 환경 비활성화됨'"
alias rag-dir="cd $RAG_ANYTHING_DIR && echo '📁 RAG-Anything 디렉토리: $(pwd)'"
alias rag-env="cd $RAG_ANYTHING_DIR && source $RAG_ENV/bin/activate"

# 상태 확인
alias rag-version="python3 -c \"import raganything; print(f'🤖 RAG-Anything: {getattr(raganything, '__version__', '1.2.7')}')\""
alias rag-status="echo '📊 RAG-Anything 상태:' && rag-version && echo '📍 위치: $RAG_ANYTHING_DIR' && echo '🐍 환경: $RAG_ENV'"

# 테스트 명령어
alias rag-test-text="python3 examples/text_format_test.py"
alias rag-test-image="python3 examples/image_format_test.py"
alias rag-test-office="python3 examples/office_document_test.py"
alias rag-check="echo '🧪 의존성 확인 중...' && rag-test-text --check-reportlab --file dummy && rag-test-image --check-pillow --file dummy"

# 파싱 명령어
alias rag-parse="python3 examples/raganything_example.py"
alias rag-modal="python3 examples/modalprocessors_example.py"
alias rag-batch="python3 examples/batch_processing_example.py"
alias rag-enhanced="python3 examples/enhanced_markdown_example.py"
alias rag-insert="python3 examples/insert_content_list_example.py"

# 개발 및 관리
alias rag-install="cd $RAG_ANYTHING_DIR && pip install -e . && echo '✅ RAG-Anything 재설치 완료'"
alias rag-update="cd $RAG_ANYTHING_DIR && git pull && pip install -e . && echo '⬆️ RAG-Anything 업데이트 완료'"
alias rag-clean="cd $RAG_ANYTHING_DIR && rm -rf test_output *.png *.md *.pdf && echo '🧹 테스트 파일 정리 완료'"

# 환경 설정
alias rag-config="cd $RAG_ANYTHING_DIR && cp .env.example .env && echo '⚙️ .env 파일 생성됨 - API 키를 설정하세요'"
alias rag-edit-config="cd $RAG_ANYTHING_DIR && code .env 2>/dev/null || nano .env"

# 빠른 시작
alias rag-start="cd $RAG_ANYTHING_DIR && source $RAG_ENV/bin/activate && echo '🚀 RAG-Anything 준비됨'"
alias rag-demo="cd $RAG_ANYTHING_DIR && source $RAG_ENV/bin/activate && echo '🎬 데모 실행을 위해 다음 명령어를 사용하세요:' && echo '   rag-test-sample' && echo '   rag-parse-sample'"

# 샘플 테스트 함수
function rag-test-sample() {
    if [ ! -f "$RAG_ANYTHING_DIR/sample_test.md" ]; then
        cd "$RAG_ANYTHING_DIR"
        cat > sample_test.md << 'SAMPLE_EOF'
# RAG-Anything 샘플 테스트

## 멀티모달 기능 테스트
이 문서는 RAG-Anything의 다양한 기능을 테스트합니다.

### 텍스트 처리
- 자연어 처리
- 의미 검색
- 임베딩 생성

### 테이블 데이터
| 기능 | 지원 여부 | 성능 |
|------|----------|------|
| 텍스트 | ✅ | 우수 |
| 이미지 | ✅ | 양호 |
| 테이블 | ✅ | 우수 |
| 수식 | ✅ | 양호 |

### 수식 예제
E = mc²
∀x ∈ ℝ, f(x) = ax² + bx + c

### 결론
RAG-Anything은 포괄적인 멀티모달 RAG 솔루션입니다.
SAMPLE_EOF
        echo "📝 샘플 테스트 문서 생성됨"
    fi
    
    echo "🧪 텍스트 파싱 테스트 실행 중..."
    python3 examples/text_format_test.py --file sample_test.md
}

function rag-parse-sample() {
    local file_path="$1"
    local api_key="$2"
    
    if [ -z "$file_path" ]; then
        echo "📖 사용법: rag-parse-sample <파일경로> [API키]"
        echo "예시: rag-parse-sample document.pdf sk-your-api-key"
        return 1
    fi
    
    if [ ! -f "$file_path" ]; then
        echo "❌ 파일을 찾을 수 없습니다: $file_path"
        return 1
    fi
    
    cd "$RAG_ANYTHING_DIR"
    source "$RAG_ENV/bin/activate"
    
    if [ -n "$api_key" ]; then
        echo "🚀 RAG 파싱 실행: $file_path"
        python3 examples/raganything_example.py "$file_path" --api-key "$api_key"
    else
        echo "⚠️  API 키가 없어 파서 기능만 테스트합니다"
        echo "📄 파서 테스트 실행: $file_path"
        
        case "${file_path##*.}" in
            md|txt) python3 examples/text_format_test.py --file "$file_path" ;;
            png|jpg|jpeg|bmp|tiff|gif|webp) python3 examples/image_format_test.py --file "$file_path" ;;
            doc|docx|ppt|pptx|xls|xlsx) python3 examples/office_document_test.py --file "$file_path" ;;
            *) echo "❓ 알 수 없는 파일 형식: ${file_path##*.}" ;;
        esac
    fi
}

# 통합 RAG 실행 함수
function rag-run() {
    local action="$1"
    local file_or_dir="$2"
    local api_key="$3"
    
    cd "$RAG_ANYTHING_DIR"
    source "$RAG_ENV/bin/activate"
    
    case "$action" in
        parse)
            if [ -z "$file_or_dir" ]; then
                echo "📖 사용법: rag-run parse <파일> [API키]"
                return 1
            fi
            rag-parse-sample "$file_or_dir" "$api_key"
            ;;
        batch)
            if [ -z "$file_or_dir" ]; then
                echo "📖 사용법: rag-run batch <디렉토리> [API키]"
                return 1
            fi
            if [ -n "$api_key" ]; then
                python3 examples/batch_processing_example.py "$file_or_dir" --api-key "$api_key"
            else
                echo "⚠️  배치 처리에는 API 키가 필요합니다"
            fi
            ;;
        modal)
            if [ -n "$api_key" ]; then
                python3 examples/modalprocessors_example.py --api-key "$api_key"
            else
                echo "⚠️  멀티모달 처리에는 API 키가 필요합니다"
            fi
            ;;
        test)
            rag-test-sample
            ;;
        *)
            echo "❓ 사용법: rag-run <action> [옵션]"
            echo "   Actions:"
            echo "     parse <파일> [API키]     - 단일 파일 파싱"
            echo "     batch <디렉토리> [API키] - 폴더 일괄 처리"
            echo "     modal [API키]           - 멀티모달 예제"
            echo "     test                    - 샘플 테스트"
            ;;
    esac
}

# 도움말 함수
alias rag-help="echo '
🤖 RAG-Anything 멀티모달 RAG 시스템 명령어
==========================================

🏠 환경 관리:
  rag-activate     - 가상환경 활성화
  rag-deactivate   - 가상환경 비활성화  
  rag-dir          - RAG-Anything 디렉토리 이동
  rag-env          - 환경 활성화 + 디렉토리 이동
  rag-start        - 빠른 시작 (환경 + 디렉토리)

📊 상태 확인:
  rag-version      - 버전 확인
  rag-status       - 전체 상태 확인
  rag-check        - 의존성 확인

🧪 테스트:
  rag-test-text    - 텍스트 파싱 테스트
  rag-test-image   - 이미지 파싱 테스트
  rag-test-office  - Office 문서 테스트
  rag-test-sample  - 샘플 문서 테스트

📄 파싱 (API 키 필요):
  rag-parse        - 메인 파싱 예제
  rag-modal        - 멀티모달 처리 예제
  rag-batch        - 배치 처리 예제
  rag-enhanced     - 고급 마크다운 예제
  rag-insert       - 콘텐츠 삽입 예제

🔧 관리:
  rag-install      - 개발 모드 재설치
  rag-update       - 최신 버전 업데이트
  rag-clean        - 테스트 파일 정리

⚙️  설정:
  rag-config       - .env 파일 생성
  rag-edit-config  - .env 파일 편집

🚀 빠른 실행:
  rag-run parse <파일> [API키]      - 파일 파싱
  rag-run batch <폴더> [API키]      - 폴더 일괄 처리  
  rag-run modal [API키]            - 멀티모달 예제
  rag-run test                     - 샘플 테스트

🎬 데모:
  rag-demo                         - 데모 가이드
  rag-parse-sample <파일> [API키]   - 샘플 파싱

💡 사용 예시:
  rag-start                        # 환경 준비
  rag-test-sample                  # 기본 테스트
  rag-parse-sample doc.pdf api-key # 파일 파싱
  rag-run batch ./docs api-key     # 폴더 처리
'"

# 자동 완성 함수
function _rag_completions() {
    local commands=(
        "activate:가상환경 활성화"
        "deactivate:가상환경 비활성화"
        "dir:디렉토리 이동"
        "env:환경 + 디렉토리"
        "start:빠른 시작"
        "version:버전 확인"
        "status:상태 확인"
        "check:의존성 확인"
        "test-text:텍스트 테스트"
        "test-image:이미지 테스트"
        "test-office:Office 테스트"
        "test-sample:샘플 테스트"
        "parse:파싱 예제"
        "modal:멀티모달 예제"
        "batch:배치 처리"
        "install:재설치"
        "update:업데이트"
        "clean:정리"
        "config:설정 생성"
        "edit-config:설정 편집"
        "demo:데모 가이드"
        "help:도움말"
    )
    
    _describe 'rag commands' commands
}

# 자동 완성 등록
compdef _rag_completions rag-*

# ===== End of RAG-Anything Aliases =====
EOF

echo "✅ RAG-Anything aliases가 ~/.zshrc에 추가되었습니다"
echo ""
echo "🔄 설정을 적용하려면 다음 명령어를 실행하세요:"
echo "   source ~/.zshrc"
echo ""
echo "📚 사용 가능한 명령어를 보려면:"
echo "   rag-help"
echo ""
echo "🚀 RAG-Anything를 시작하려면:"
echo "   rag-start"
echo ""
echo "🎬 데모를 보려면:"
echo "   rag-demo"
echo ""
echo "💡 사용 예시:"
echo "   rag-test-sample              # 기본 기능 테스트"
echo "   rag-parse-sample doc.pdf     # 파일 파싱 (API 키 없음)"
echo "   rag-run parse doc.pdf api-key # 완전한 RAG 파싱"
