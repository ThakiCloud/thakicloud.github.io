#!/bin/bash
# GitHub-hosted runner로 빠르게 전환하는 스크립트

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "🔄 GitHub-hosted runner로 전환 중..."
echo ""

# 현재 워크플로우 백업
if [ -f "$REPO_ROOT/.github/workflows/jekyll.yml" ]; then
    BACKUP_FILE="$REPO_ROOT/.github/workflows/jekyll-self-hosted-backup-$(date +%Y%m%d-%H%M%S).yml"
    cp "$REPO_ROOT/.github/workflows/jekyll.yml" "$BACKUP_FILE"
    echo "✅ 현재 워크플로우 백업: $(basename $BACKUP_FILE)"
fi

# GitHub-hosted runner 워크플로우로 교체
if [ -f "$REPO_ROOT/.github/workflows/jekyll-backup-ubuntu.yml.disabled" ]; then
    cp "$REPO_ROOT/.github/workflows/jekyll-backup-ubuntu.yml.disabled" "$REPO_ROOT/.github/workflows/jekyll.yml"
    echo "✅ GitHub-hosted runner 워크플로우 적용"
else
    echo "❌ 백업 워크플로우 파일을 찾을 수 없습니다."
    exit 1
fi

echo ""
echo "📊 변경 사항:"
echo "   Before: self-hosted runner (CPU 1.6, 메모리 4GB) - 연결 불안정"
echo "   After:  GitHub-hosted runner (CPU 2.0, 메모리 7GB) - 무료 무제한"
echo ""

# Git 상태 확인
cd "$REPO_ROOT"
if git diff --quiet .github/workflows/jekyll.yml; then
    echo "⚠️  변경사항이 없습니다."
else
    echo "📝 커밋 메시지 생성 중..."
    cat > /tmp/commit-msg.txt << 'EOF'
fix: GitHub-hosted runner로 전환하여 빌드 안정성 개선

## 문제
- Self-hosted runner (CPU 1.6, 메모리 4GB)에서 연결 끊김 발생
- 1,032개 포스트 빌드 시 시간 초과로 heartbeat 실패

## 해결
- GitHub-hosted runner (CPU 2.0, 메모리 7GB) 사용
- Public repo이므로 무료 무제한 사용 가능
- 예상 빌드 시간: 5-8분
- 연결 안정성 보장

## 참고
- 이전 self-hosted 설정은 백업됨
- 필요시 복원 가능: git checkout HEAD~1 .github/workflows/jekyll.yml
EOF

    echo ""
    echo "🚀 다음 명령어로 커밋 및 푸시:"
    echo ""
    echo "   git add .github/workflows/jekyll.yml"
    echo "   git commit -F /tmp/commit-msg.txt"
    echo "   git push"
    echo ""
    
    read -p "지금 바로 커밋하고 푸시하시겠습니까? (y/N): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        git add .github/workflows/jekyll.yml
        git commit -F /tmp/commit-msg.txt
        echo ""
        echo "✅ 커밋 완료!"
        echo ""
        read -p "푸시하시겠습니까? (y/N): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            git push
            echo ""
            echo "🎉 완료! GitHub Actions에서 새로운 빌드를 확인하세요:"
            echo "   https://github.com/$(git remote get-url origin | sed 's/.*github.com[:/]\(.*\)\.git/\1/')/actions"
        fi
    else
        echo ""
        echo "💡 나중에 수동으로 커밋하려면 위의 명령어를 사용하세요."
    fi
fi

echo ""
echo "✨ 전환 완료!"
echo ""
echo "📌 참고:"
echo "   - 빌드 시간: 5-8분 (self-hosted보다 안정적)"
echo "   - 비용: 무료 (Public repository)"
echo "   - 연결 끊김: 없음"
echo ""
echo "📖 자세한 내용: docs/runner-connection-lost-fix.md"

