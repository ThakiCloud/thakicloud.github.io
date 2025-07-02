# Thaki Cloud 기술 블로그 위키

AI/ML Engineering, LLMOps, DevOps 전문 기술 블로그의 공식 위키입니다.

## 📚 주요 페이지

- [[블로그 작성 가이드|Blog-Writing-Guide]]
- [[카테고리 분류 규칙|Category-Guidelines]]
- [[기술 스택 문서|Tech-Stack]]
- [[CI/CD 워크플로우|CICD-Workflow]]
- [[SEO 최적화 가이드|SEO-Guide]]
- [[프로젝트 관리 가이드|Project-Management]]

## 🎯 블로그 카테고리

### 개발 관련
- `dev`: 개발 및 아키텍처
- `tutorials`: 기술 인사이트 & 튜토리얼

### AI/ML 관련  
- `llmops`: LLM Ops & AI 엔지니어링
- `research`: 산업 연구 & 분석
- `reviews`: 학술 논문 리뷰

### 기타
- `careers`: Thaki Cloud Life & 커리어
- `news`: 기술 뉴스 & 트렌드
- `science`: 과학 & 딥테크
- `misc`: 기타

## 📈 블로그 통계 (2025년 1월 기준)

- **총 포스트 수**: 300+ 개
- **주요 카테고리**: `llmops` (80개), `tutorials` (70개), `dev` (65개)
- **월 평균 업데이트**: 15-20개 포스트
- **주요 기술 스택**: Jekyll, Minimal Mistakes, GitHub Pages

## 🚀 빠른 시작

### 새 포스트 작성하기
1. [GitHub Issues](https://github.com/ThakiCloud/thakicloud.github.io/issues)에서 새 이슈 생성
2. 적절한 라벨 추가 (`blog-post` + 카테고리)
3. [프로젝트 보드](https://github.com/orgs/ThakiCloud/projects/2)에 이슈 추가
4. `_posts/카테고리/YYYY-MM-DD-title.md` 형식으로 파일 생성
5. Front Matter 작성 및 콘텐츠 작성
6. PR 생성 및 리뷰

### 로컬 개발 환경 설정
```bash
# 리포지토리 클론
git clone https://github.com/ThakiCloud/thakicloud.github.io.git
cd thakicloud.github.io

# 의존성 설치
bundle install

# 로컬 서버 실행
bundle exec jekyll serve
```

## 📋 작성 가이드라인

### Front Matter 필수 항목
```yaml
---
title: "포스트 제목"
excerpt: "요약 (100-150자)"
seo_title: "SEO 제목 (60자 이내) - Thaki Cloud"
seo_description: "SEO 설명 (150-160자)"
date: YYYY-MM-DD
categories:
  - 카테고리명
tags:
  - 태그1
  - 태그2
author_profile: true
toc: true
canonical_url: "https://thakicloud.github.io/카테고리/포스트-slug/"
---
```

### 파일명 규칙
- 형식: `YYYY-MM-DD-title-in-english.md`
- 위치: `_posts/카테고리/`
- 예시: `2025-01-15-kubernetes-llm-serving-guide.md`

## 🔗 유용한 링크

- **메인 블로그**: [thakicloud.github.io](https://thakicloud.github.io)
- **GitHub 프로젝트**: [Blog Management Project](https://github.com/orgs/ThakiCloud/projects/2)
- **Thaki Cloud 공식 사이트**: [thakicloud.co.kr](https://thakicloud.co.kr)
- **이슈 트래커**: [GitHub Issues](https://github.com/ThakiCloud/thakicloud.github.io/issues)
- **CI/CD 상태**: [GitHub Actions](https://github.com/ThakiCloud/thakicloud.github.io/actions)

## 📞 문의 및 지원

- **이메일**: info@thakicloud.co.kr
- **GitHub Issues**: 기술적 문제나 제안사항
- **프로젝트 관리자**: [@sskang-thaki](https://github.com/sskang-thaki)

---

*이 위키는 Thaki Cloud 기술 블로그 팀이 관리하며, 모든 기여자들의 협업을 통해 발전하고 있습니다.* 