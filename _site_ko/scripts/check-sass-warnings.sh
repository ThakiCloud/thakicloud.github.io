#!/bin/bash

# Sass 경고 모니터링 스크립트
# 사용법: ./scripts/check-sass-warnings.sh

set -e

echo "🔍 Sass 경고 검사 시작..."
echo "================================"

# Jekyll 빌드 실행 및 경고 카운트
echo "📦 Jekyll 빌드 중..."
BUILD_OUTPUT=$(bundle exec jekyll build 2>&1)
BUILD_STATUS=$?

if [ $BUILD_STATUS -ne 0 ]; then
    echo "❌ Jekyll 빌드 실패!"
    echo "$BUILD_OUTPUT"
    exit 1
fi

# 경고 개수 계산
WARNING_COUNT=$(echo "$BUILD_OUTPUT" | grep -i 'deprecation\|warning' | wc -l | tr -d ' ')
echo "현재 경고 개수: ${WARNING_COUNT}개"

# 경고 유형별 분석
echo ""
echo "📊 경고 유형별 분포:"
echo "----------------"
echo "$BUILD_OUTPUT" | grep "DEPRECATION WARNING" | cut -d'[' -f2 | cut -d']' -f1 | sort | uniq -c | while read count type; do
    echo "  $type: $count개"
done

# 임계값 검사 (기준: 25개)
THRESHOLD=25
echo ""
echo "🎯 임계값 검사 (기준: ${THRESHOLD}개)"
echo "----------------"

if [ "$WARNING_COUNT" -gt $THRESHOLD ]; then
    echo "❌ 경고가 임계값을 초과했습니다!"
    echo "   현재: ${WARNING_COUNT}개 > 기준: ${THRESHOLD}개"
    echo ""
    echo "📋 최근 경고 샘플:"
    echo "$BUILD_OUTPUT" | grep -A2 "DEPRECATION WARNING" | head -10
    exit 1
else
    echo "✅ 경고 수준이 적정합니다."
    echo "   현재: ${WARNING_COUNT}개 ≤ 기준: ${THRESHOLD}개"
fi

# 성공 완료
echo ""
echo "🎉 Sass 경고 검사 완료!"
echo "================================"
echo "빌드 시간: $(date)"
echo "상태: 정상"
echo "경고: ${WARNING_COUNT}개" 