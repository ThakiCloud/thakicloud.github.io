#!/bin/bash
# 다국어 블로그 관리를 위한 zshrc aliases 설정 스크립트

echo "🔧 다국어 블로그 aliases 설정 중..."

# zshrc 백업
cp ~/.zshrc ~/.zshrc.backup.$(date +%Y%m%d_%H%M%S)

# aliases 추가
cat >> ~/.zshrc << 'EOF'

# ========================================
# 🌍 다국어 블로그 관리 Aliases
# ========================================

# 환경 변수
export BLOG_DIR="/Users/$(whoami)/work/thakicloud/thakicloud.github.io"
export SCRIPTS_DIR="$BLOG_DIR/scripts"

# 다국어 포스트 생성
alias newpost-multi="$SCRIPTS_DIR/new-multilingual-post.sh"
alias newpost-ko="$SCRIPTS_DIR/new-multilingual-post.sh"
alias newpost-en="$SCRIPTS_DIR/new-multilingual-post.sh"
alias newpost-ar="$SCRIPTS_DIR/new-multilingual-post.sh"

# 다국어 빌드
alias build-multi="$SCRIPTS_DIR/build-multilingual.sh"
alias build-ko="JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config-ko.yml --destination _site --verbose --limit_posts 10"
alias build-en="JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config-en.yml --destination _site_en --verbose --limit_posts 10"
alias build-ar="JEKYLL_ENV=production bundle exec jekyll build --config _config.yml,_config-ar.yml --destination _site_ar --verbose --limit_posts 10"

# 다국어 서버 실행
alias serve-ko="bundle exec jekyll serve --config _config.yml,_config-ko.yml --port 4000"
alias serve-en="bundle exec jekyll serve --config _config.yml,_config-en.yml --port 4001"
alias serve-ar="bundle exec jekyll serve --config _config.yml,_config-ar.yml --port 4002"

# 디렉토리 이동
alias blogdir="cd $BLOG_DIR"
alias blogdir-ko="cd $BLOG_DIR/_posts/ko"
alias blogdir-en="cd $BLOG_DIR/_posts/en"
alias blogdir-ar="cd $BLOG_DIR/_posts/ar"

# CI/CD 테스트
alias test-ci="$SCRIPTS_DIR/test-multilingual-ci.sh"
alias test-act="act -j build -W .github/workflows/multilingual-deploy.yml --container-architecture linux/amd64"

# 유틸리티
alias blog-status="echo '📊 다국어 블로그 상태:' && echo '🇰🇷 한국어 포스트:' $(find $BLOG_DIR/_posts/ko -name '*.md' | wc -l) && echo '🇺🇸 영어 포스트:' $(find $BLOG_DIR/_posts/en -name '*.md' | wc -l) && echo '🇸🇦 아랍어 포스트:' $(find $BLOG_DIR/_posts/ar -name '*.md' | wc -l)"

# Git 관련
alias blog-commit="cd $BLOG_DIR && git add . && git commit -m"
alias blog-push="cd $BLOG_DIR && git push origin main"
alias blog-pull="cd $BLOG_DIR && git pull origin main"

# 도움말
alias blog-help="echo '🌍 다국어 블로그 명령어:' && echo '  newpost-multi <slug> <category> - 다국어 포스트 생성' && echo '  build-multi - 전체 다국어 빌드' && echo '  serve-ko/en/ar - 언어별 서버 실행' && echo '  blogdir-ko/en/ar - 언어별 디렉토리 이동' && echo '  blog-status - 블로그 상태 확인' && echo '  test-ci - CI/CD 테스트'"

EOF

echo "✅ zshrc aliases 설정 완료!"
echo "🔄 다음 명령어로 설정을 적용하세요:"
echo "   source ~/.zshrc"
echo ""
echo "📝 사용 가능한 명령어:"
echo "   newpost-multi <slug> <category> - 다국어 포스트 생성"
echo "   build-multi - 전체 다국어 빌드"
echo "   serve-ko/en/ar - 언어별 서버 실행"
echo "   blogdir-ko/en/ar - 언어별 디렉토리 이동"
echo "   blog-status - 블로그 상태 확인"
echo "   blog-help - 도움말 보기"
