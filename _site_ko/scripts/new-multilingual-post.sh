#!/bin/bash
# 다국어 블로그 포스트 생성 스크립트

TITLE_SLUG=$1
CATEGORY=$2
LANGUAGES=("ko" "en" "ar")

if [ -z "$TITLE_SLUG" ] || [ -z "$CATEGORY" ]; then
    echo "사용법: new-multilingual-post <title-slug> <category>"
    echo "카테고리: agentops, careers, culture, datasets, dev, devops, iaas, llmops, misc, news, owm, paas, research, reviews, saas, science, tutorials"
    exit 1
fi

TODAY=$(date +"%Y-%m-%d")
BLOG_DIR="/Users/$(whoami)/work/thakicloud/thakicloud.github.io"

# 각 언어별로 포스트 생성
for lang in "${LANGUAGES[@]}"; do
    FILENAME="${TODAY}-${TITLE_SLUG}.md"
    FILEPATH="${BLOG_DIR}/_posts/${lang}/${CATEGORY}/${FILENAME}"
    
    # 디렉토리 생성
    mkdir -p "${BLOG_DIR}/_posts/${lang}/${CATEGORY}"
    
    # 언어별 템플릿 생성
    case $lang in
        "ko")
            TITLE_TEMPLATE="[한국어 제목을 입력하세요]"
            EXCERPT_TEMPLATE="[한국어 요약을 입력하세요]"
            SEO_TITLE_TEMPLATE="[한국어 SEO 제목] - Thaki Cloud"
            SEO_DESC_TEMPLATE="[한국어 SEO 설명을 입력하세요]"
            READING_TIME="분"
            LANG_CODE="ko"
            INTRO_SECTION="## 서론"
            MAIN_SECTION="## 본론"
            CONCLUSION_SECTION="## 결론"
            ;;
        "en")
            TITLE_TEMPLATE="[Enter English Title]"
            EXCERPT_TEMPLATE="[Enter English Summary]"
            SEO_TITLE_TEMPLATE="[English SEO Title] - Thaki Cloud"
            SEO_DESC_TEMPLATE="[Enter English SEO Description]"
            READING_TIME="min read"
            LANG_CODE="en"
            INTRO_SECTION="## Introduction"
            MAIN_SECTION="## Main Content"
            CONCLUSION_SECTION="## Conclusion"
            ;;
        "ar")
            TITLE_TEMPLATE="[أدخل العنوان العربي]"
            EXCERPT_TEMPLATE="[أدخل الملخص العربي]"
            SEO_TITLE_TEMPLATE="[عنوان SEO العربي] - ثاكي كلاود"
            SEO_DESC_TEMPLATE="[أدخل وصف SEO العربي]"
            READING_TIME="دقيقة قراءة"
            LANG_CODE="ar"
            INTRO_SECTION="## مقدمة"
            MAIN_SECTION="## المحتوى الرئيسي"
            CONCLUSION_SECTION="## خلاصة"
            ;;
    esac

    # Front Matter 템플릿 생성
    cat > "$FILEPATH" << EOF
---
title: "$TITLE_TEMPLATE"
excerpt: "$EXCERPT_TEMPLATE"
seo_title: "$SEO_TITLE_TEMPLATE"
seo_description: "$SEO_DESC_TEMPLATE"
date: ${TODAY}
lang: ${LANG_CODE}
categories:
  - ${CATEGORY}
tags:
  - 
author_profile: true
toc: true
toc_label: "목차"
canonical_url: "https://thakicloud.github.io/${lang}/${CATEGORY}/${TITLE_SLUG}/"
---

⏱️ **예상 읽기 시간**: ${READING_TIME}

${INTRO_SECTION}

${MAIN_SECTION}

${CONCLUSION_SECTION}
EOF

    echo "✅ $(echo $lang | tr '[:lower:]' '[:upper:]') 포스트 생성됨: $FILEPATH"
done

echo ""
echo "🎉 다국어 포스트 생성 완료!"
echo "📝 생성된 파일들:"
echo "   🇰🇷 한국어: _posts/ko/${CATEGORY}/${TODAY}-${TITLE_SLUG}.md"
echo "   🇺🇸 영어: _posts/en/${CATEGORY}/${TODAY}-${TITLE_SLUG}.md"
echo "   🇸🇦 아랍어: _posts/ar/${CATEGORY}/${TODAY}-${TITLE_SLUG}.md"
echo ""
echo "💡 다음 단계:"
echo "   1. 각 언어별로 콘텐츠 작성"
echo "   2. 로컬 테스트: bundle exec jekyll serve --config _config.yml,_config-ko.yml"
echo "   3. GitHub에 푸시하여 자동 배포"
