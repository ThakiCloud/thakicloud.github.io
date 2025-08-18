#!/bin/bash

# Bytebot zshrc Aliases 설정 스크립트
# macOS에서 Bytebot 관리를 위한 편의 기능 추가

echo "🔧 Bytebot zshrc aliases 설정 스크립트"
echo "====================================="

# 백업 생성
if [ -f ~/.zshrc ]; then
    cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d-%H%M%S)
    echo "✅ 기존 .zshrc 백업 완료"
fi

# Bytebot aliases 추가
cat >> ~/.zshrc << 'EOF'

# ===== Bytebot AI Desktop Agent Aliases =====
export BYTEBOT_DIR="$HOME/bytebot"

# 기본 관리 명령어
alias bytebot-start="cd $BYTEBOT_DIR && docker-compose -f docker/docker-compose.yml up -d && echo '🚀 Bytebot 시작됨 - UI: http://localhost:9992'"
alias bytebot-stop="cd $BYTEBOT_DIR && docker-compose -f docker/docker-compose.yml down && echo '🛑 Bytebot 중지됨'"
alias bytebot-restart="bytebot-stop && sleep 3 && bytebot-start"
alias bytebot-status="cd $BYTEBOT_DIR && docker-compose -f docker/docker-compose.yml ps"
alias bytebot-logs="cd $BYTEBOT_DIR && docker-compose -f docker/docker-compose.yml logs -f"

# 빠른 접속
alias bytebot-ui="open http://localhost:9992"
alias bytebot-desktop="open http://localhost:9990"
alias bytebot-health="curl -s http://localhost:9991/health | jq"

# 개발자 도구
alias bytebot-shell="docker exec -it bytebot-desktop bash"
alias bytebot-agent-shell="docker exec -it bytebot-agent bash"
alias bytebot-clean="cd $BYTEBOT_DIR && docker-compose -f docker/docker-compose.yml down -v && docker system prune -f"

# 설정 관리
alias bytebot-env="cat $BYTEBOT_DIR/docker/.env 2>/dev/null || echo '❌ .env 파일이 없습니다'"
alias bytebot-edit-env="code $BYTEBOT_DIR/docker/.env 2>/dev/null || nano $BYTEBOT_DIR/docker/.env"
alias bytebot-set-anthropic="read -p 'Anthropic API Key: ' key && echo \"ANTHROPIC_API_KEY=\$key\" > $BYTEBOT_DIR/docker/.env && echo '✅ Anthropic API 키 설정됨'"
alias bytebot-set-openai="read -p 'OpenAI API Key: ' key && echo \"OPENAI_API_KEY=\$key\" > $BYTEBOT_DIR/docker/.env && echo '✅ OpenAI API 키 설정됨'"

# 백업 및 복원
alias bytebot-backup="tar -czf bytebot-backup-$(date +%Y%m%d-%H%M%S).tar.gz -C $HOME bytebot && echo '📦 Bytebot 백업 완료'"
alias bytebot-update="cd $BYTEBOT_DIR && git pull && docker-compose -f docker/docker-compose.yml pull && echo '⬆️  Bytebot 업데이트 완료'"

# 통계 및 모니터링
alias bytebot-stats="docker stats --no-stream --format 'table {{.Name}}\t{{.CPUPerc}}\t{{.MemUsage}}\t{{.MemPerc}}' $(docker ps --filter label=com.docker.compose.project=bytebot --format '{{.Names}}')"
alias bytebot-disk="docker system df"

# 도움말
alias bytebot-help="echo '
🤖 Bytebot AI Desktop Agent 명령어
===================================

📋 기본 관리:
  bytebot-start     - Bytebot 시작
  bytebot-stop      - Bytebot 중지  
  bytebot-restart   - Bytebot 재시작
  bytebot-status    - 서비스 상태 확인
  bytebot-logs      - 로그 확인

🌐 빠른 접속:
  bytebot-ui        - 웹 UI 열기 (9992)
  bytebot-desktop   - 데스크톱 화면 열기 (9990)
  bytebot-health    - API 상태 확인

🔧 개발자 도구:
  bytebot-shell     - 데스크톱 컨테이너 접속
  bytebot-agent-shell - 에이전트 컨테이너 접속
  bytebot-clean     - 완전 정리 (데이터 삭제)

⚙️  설정 관리:
  bytebot-env       - 현재 환경변수 확인
  bytebot-edit-env  - 환경변수 편집
  bytebot-set-anthropic - Anthropic API 키 설정
  bytebot-set-openai    - OpenAI API 키 설정

📊 모니터링:
  bytebot-stats     - 리소스 사용량 확인
  bytebot-disk      - 디스크 사용량 확인

🔄 유지보수:
  bytebot-backup    - 백업 생성
  bytebot-update    - 최신 버전 업데이트
  bytebot-help      - 이 도움말 표시
'"

# 자동 완성 함수
function _bytebot_completions() {
    local commands=(
        "start:Bytebot 시작"
        "stop:Bytebot 중지"
        "restart:Bytebot 재시작"
        "status:상태 확인"
        "logs:로그 확인"
        "ui:웹 UI 열기"
        "desktop:데스크톱 열기"
        "health:API 상태 확인"
        "shell:컨테이너 접속"
        "clean:완전 정리"
        "env:환경변수 확인"
        "backup:백업 생성"
        "update:업데이트"
        "help:도움말"
    )
    
    _describe 'bytebot commands' commands
}

# Bytebot 메인 명령어 (옵션)
function bytebot() {
    case "$1" in
        start) bytebot-start ;;
        stop) bytebot-stop ;;
        restart) bytebot-restart ;;
        status) bytebot-status ;;
        logs) bytebot-logs ;;
        ui) bytebot-ui ;;
        desktop) bytebot-desktop ;;
        health) bytebot-health ;;
        shell) bytebot-shell ;;
        clean) bytebot-clean ;;
        env) bytebot-env ;;
        backup) bytebot-backup ;;
        update) bytebot-update ;;
        help|*) bytebot-help ;;
    esac
}

# 자동 완성 등록
compdef _bytebot_completions bytebot

# ===== End of Bytebot Aliases =====
EOF

echo "✅ Bytebot aliases가 ~/.zshrc에 추가되었습니다"
echo ""
echo "🔄 설정을 적용하려면 다음 명령어를 실행하세요:"
echo "   source ~/.zshrc"
echo ""
echo "📚 사용 가능한 명령어를 보려면:"
echo "   bytebot-help"
echo ""
echo "🚀 Bytebot을 시작하려면:"
echo "   bytebot-start"
