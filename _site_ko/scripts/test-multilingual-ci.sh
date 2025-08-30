#!/bin/bash
# 다국어 블로그 CI/CD 로컬 테스트 스크립트

echo "🧪 다국어 블로그 CI/CD 로컬 테스트 시작..."

# 현재 디렉토리 확인
if [ ! -f "_config.yml" ]; then
    echo "❌ Jekyll 프로젝트 루트 디렉토리에서 실행해주세요."
    exit 1
fi

# act 버전 확인
echo "📋 act 버전 정보:"
act --version

echo ""
echo "🔍 사용 가능한 워크플로우:"
act -l

echo ""
echo "🚀 다국어 배포 워크플로우 테스트 시작..."

# 빌드 작업만 테스트 (배포는 제외)
act -j build --verbose

if [ $? -eq 0 ]; then
    echo "✅ 다국어 블로그 CI 테스트 성공!"
    echo ""
    echo "📊 테스트 결과:"
    echo "   - 한국어 사이트 빌드: ✅"
    echo "   - 영어 사이트 빌드: ✅" 
    echo "   - 아랍어 사이트 빌드: ✅"
    echo "   - 사이트 통합: ✅"
    echo ""
    echo "🎉 모든 테스트가 성공적으로 완료되었습니다!"
else
    echo "❌ 다국어 블로그 CI 테스트 실패"
    echo "로그를 확인하여 문제를 해결해주세요."
    exit 1
fi
