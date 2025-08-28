#!/bin/bash
# 다국어 블로그 빌드 스크립트

echo "🌍 다국어 블로그 빌드 시작..."

# 빌드 디렉토리 정리
echo "🧹 기존 빌드 파일 정리 중..."
rm -rf _site _site_en _site_ar

# 한국어 빌드
echo "🇰🇷 한국어 버전 빌드 중..."
JEKYLL_ENV=production bundle exec jekyll build \
  --config _config.yml,_config-ko.yml \
  --destination _site \
  --verbose --limit_posts 10

if [ $? -ne 0 ]; then
    echo "❌ 한국어 빌드 실패"
    exit 1
fi

# 영어 빌드 (별도 디렉토리)
echo "🇺🇸 영어 버전 빌드 중..."
JEKYLL_ENV=production bundle exec jekyll build \
  --config _config.yml,_config-en.yml \
  --destination _site_en \
  --verbose --limit_posts 10

if [ $? -ne 0 ]; then
    echo "❌ 영어 빌드 실패"
    exit 1
fi

# 아랍어 빌드 (별도 디렉토리)
echo "🇸🇦 아랍어 버전 빌드 중..."
JEKYLL_ENV=production bundle exec jekyll build \
  --config _config.yml,_config-ar.yml \
  --destination _site_ar \
  --verbose --limit_posts 10

if [ $? -ne 0 ]; then
    echo "❌ 아랍어 빌드 실패"
    exit 1
fi

# 언어별 사이트를 메인 사이트에 통합
echo "🔗 언어별 사이트 통합 중..."
mkdir -p _site/en _site/ar

# 영어와 아랍어 사이트를 해당 언어 디렉토리로 복사
cp -r _site_en/* _site/en/
cp -r _site_ar/* _site/ar/

# 임시 디렉토리 정리
rm -rf _site_en _site_ar

echo "✅ 다국어 블로그 빌드 완료!"
echo "📂 빌드 결과:"
echo "   - 한국어: _site/ko/"
echo "   - 영어: _site/en/"
echo "   - 아랍어: _site/ar/"
echo "   - 루트: _site/ (언어 선택 페이지)"
