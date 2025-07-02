# 블로그 작성 가이드

Thaki Cloud 기술 블로그 포스트 작성을 위한 완전한 가이드입니다.

## 📋 목차

1. [파일명 및 구조 규칙](#파일명-및-구조-규칙)
2. [Front Matter 작성법](#front-matter-작성법)
3. [카테고리 분류 가이드](#카테고리-분류-가이드)
4. [콘텐츠 작성 규칙](#콘텐츠-작성-규칙)
5. [SEO 최적화](#seo-최적화)
6. [이미지 및 미디어](#이미지-및-미디어)
7. [체크리스트](#체크리스트)

## 📁 파일명 및 구조 규칙

### 파일명 형식
```YYYY-MM-DD-title-in-english.md
```

### 디렉토리 구조
```
_posts/
├── dev/                    # 개발 관련
├── llmops/                 # LLM Ops & AI 엔지니어링
├── tutorials/              # 튜토리얼
├── research/               # 연구 & 분석
├── careers/                # 커리어 & 라이프
├── news/                   # 기술 뉴스
├── science/                # 과학 & 딥테크
└── misc/                   # 기타
```

### 파일명 예시
- `2025-01-15-kubernetes-llm-serving-optimization.md`
- `2025-01-16-deepseek-r1-vs-openai-o1-comparison.md`
- `2025-01-17-ai-agent-framework-comparison-study.md`

## 🏷️ Front Matter 작성법

### 기본 템플릿
```yaml
---
title: "명확하고 구체적인 제목 (한글 60자 이내)"
excerpt: "포스트 요약 (100-150자, 검색 결과에 표시될 내용)"
seo_title: "SEO 최적화 제목 (60자 이내) - Thaki Cloud"
seo_description: "검색 엔진용 상세 설명 (150-160자)"
date: YYYY-MM-DD
last_modified_at: YYYY-MM-DD
categories:
  - 주요카테고리
  - 부카테고리 (선택사항)
tags:
  - 핵심키워드1
  - 핵심키워드2
  - 기술스택명
  - 도구명
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
header:
  teaser: "/assets/images/posts/카테고리/포스트명/thumbnail.jpg"
  overlay_image: "/assets/images/posts/카테고리/포스트명/header.jpg"
  overlay_filter: 0.5
canonical_url: "https://thakicloud.github.io/카테고리/포스트-slug/"
reading_time: true
---
```

### 필수 항목 설명

| 항목 | 설명 | 예시 |
|------|------|------|
| `title` | 포스트 제목 (60자 이내) | "Kubernetes에서 LLM 서빙 최적화 완전 가이드" |
| `excerpt` | 포스트 요약 (100-150자) | "Kubernetes 환경에서 대규모 LLM 모델을 효율적으로 서빙하는 방법과 성능 최적화 기법을 상세히 다룹니다." |
| `seo_title` | SEO 제목 (60자 이내) | "Kubernetes LLM 서빙 최적화 가이드 - Thaki Cloud" |
| `seo_description` | SEO 설명 (150-160자) | "VLLM, TensorRT-LLM을 활용한 Kubernetes LLM 서빙 최적화 방법. GPU 스케줄링, 오토스케일링, 성능 튜닝까지 실무에서 검증된 모든 기법을 제공합니다." |
| `categories` | 카테고리 (아래 가이드 참조) | `dev`, `tutorials` |
| `tags` | 관련 태그 (5-8개 권장) | `kubernetes`, `llm`, `vllm`, `gpu`, `optimization` |

## 🗂️ 카테고리 분류 가이드

### 주요 카테고리

| 카테고리 | 설명 | 사용 예시 |
|----------|------|-----------|
| `dev` | 개발 및 아키텍처 | 쿠버네티스, Docker, 마이크로서비스 |
| `llmops` | LLM 운영 및 관리 | 모델 배포, 추론 최적화, MLOps |
| `tutorials` | 실습 가이드 | 단계별 튜토리얼, 핸즈온 |
| `research` | 연구 자료 | 논문 리뷰, 실험 결과, 분석 |
| `careers` | 커리어 | 취업, 이직, 성장, 팀 문화 |
| `news` | 기술 뉴스 | 업계 동향, 신제품 발표 |
| `science` | 과학 & 딥테크 | 기초 과학, 신기술 연구 |
| `misc` | 기타 | 위 카테고리에 속하지 않는 내용 |

### 카테고리 선택 가이드
1. **단일 카테고리 우선**: 가능한 한 하나의 주요 카테고리 사용
2. **복합 주제**: 두 개 카테고리까지 허용 (예: `dev`, `tutorials`)
3. **계층 구조**: 주요 카테고리 → 세부 카테고리 순서

## ✍️ 콘텐츠 작성 규칙

### 구조 가이드
```markdown
⏱️ **예상 읽기 시간**: X분

## 서론
- 문제 정의 및 배경
- 포스트에서 다룰 내용 개요

## 본론
### 주요 섹션 1
### 주요 섹션 2
### 주요 섹션 3

## 실습 (튜토리얼의 경우)
### 환경 설정
### 단계별 구현
### 결과 확인

## 결론
- 핵심 내용 요약
- 다음 단계 제안
- 관련 자료 링크
```

### 작성 규칙
1. **제목**: H2(##), H3(###) 사용, H1(#)은 금지
2. **문체**: 존댓말, 일관된 어조 유지
3. **코드**: 언어명 명시 (```python, ```bash 등)
4. **링크**: 전체 URL 작성, 외부 링크는 새 탭에서 열기
5. **이미지**: 적절한 alt 텍스트 추가

### 튜토리얼 특별 규칙
- **macOS 실행 가능**: 로컬에서 테스트 완료 후 작성
- **환경 버전 명시**: Python 3.x, Node.js 18+ 등
- **실행 결과 포함**: 스크린샷 또는 출력 예시
- **에러 처리**: 예상 에러 및 해결 방법 제시

## 🔍 SEO 최적화

### 키워드 전략
1. **주요 키워드**: 제목에 포함
2. **부키워드**: 첫 번째 단락에 자연스럽게 포함
3. **롱테일 키워드**: 본문 전체에 분산 배치
4. **키워드 밀도**: 전체 글의 1-2% 수준 유지

### 메타데이터 최적화
- **제목**: 60자 이내, 키워드 앞쪽 배치
- **설명**: 150-160자, 클릭을 유도하는 내용
- **URL**: 영문 소문자, 하이픈으로 구분
- **이미지**: alt 텍스트에 키워드 포함

## 🖼️ 이미지 및 미디어

### 디렉토리 구조
```
assets/images/posts/
├── 카테고리명/
│   └── 포스트명/
│       ├── thumbnail.jpg     (썸네일, 600x400)
│       ├── header.jpg        (헤더, 1200x600)
│       ├── screenshot1.jpg   (본문 이미지)
│       └── diagram1.jpg      (다이어그램)
```

### 이미지 규격
- **썸네일**: 600x400px, 100KB 이하
- **헤더**: 1200x600px, 200KB 이하  
- **본문**: 최대 1000px 폭, 150KB 이하
- **형식**: JPG (사진), PNG (스크린샷), SVG (아이콘)

### 사용 예시
```markdown
![Kubernetes 아키텍처 다이어그램](/assets/images/posts/dev/kubernetes-llm-guide/architecture.jpg)
*그림 1: Kubernetes에서 LLM 서빙 아키텍처*
```

## ✅ 체크리스트

### 작성 전 체크
- [ ] 이슈가 GitHub 프로젝트에 등록되어 있는가?
- [ ] 카테고리가 적절히 선택되었는가?
- [ ] 제목이 명확하고 SEO에 최적화되어 있는가?

### 작성 중 체크
- [ ] Front Matter가 모든 필수 항목을 포함하는가?
- [ ] 목차(TOC)가 설정되어 있는가?
- [ ] 코드 블록에 언어가 명시되어 있는가?
- [ ] 이미지에 alt 텍스트가 있는가?
- [ ] 외부 링크가 올바르게 작동하는가?

### 발행 전 체크
- [ ] 로컬에서 `bundle exec jekyll serve`로 확인했는가?
- [ ] 읽기 시간이 추가되어 있는가?
- [ ] 맞춤법과 문법을 검토했는가?
- [ ] SEO 최적화가 완료되었는가?
- [ ] 관련 태그가 적절히 설정되어 있는가?

### 발행 후 체크
- [ ] 사이트에서 정상적으로 표시되는가?
- [ ] 목차와 네비게이션이 작동하는가?
- [ ] 이미지가 모두 로드되는가?
- [ ] GitHub 이슈를 클로즈했는가?

## 📚 참고 자료

- [Jekyll 공식 문서](https://jekyllrb.com/docs/)
- [Minimal Mistakes 테마 가이드](https://mmistakes.github.io/minimal-mistakes/docs/quick-start-guide/)
- [Markdown 문법 가이드](https://www.markdownguide.org/)
- [SEO 최적화 가이드](https://developers.google.com/search/docs)

---

*이 가이드는 지속적으로 업데이트되며, 팀의 피드백을 반영하여 개선됩니다.* 