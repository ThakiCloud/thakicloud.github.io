#!/bin/bash

set -e

echo "🔧 GitHub Act 개발 테스트 스크립트"
echo "================================="

# 환경 확인
echo "📋 환경 확인..."
echo "Docker: $(docker --version)"
echo "Act: $(act --version)"
echo ""

# 워크플로우 목록
echo "📝 사용 가능한 워크플로우:"
act --list
echo ""

# CI 테스트 실행
echo "🧪 CI 테스트 실행..."
act push -j lint-test --verbose

echo ""
echo "✅ 테스트 완료!"
