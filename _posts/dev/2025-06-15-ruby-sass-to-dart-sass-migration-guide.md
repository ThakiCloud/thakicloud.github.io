---
title: "Ruby Sass 3.x에서 Dart Sass로 완벽 마이그레이션 가이드"
excerpt: "Ruby Sass 3.x 코드베이스를 최신 Dart Sass로 안전하게 이동하는 단계별 체크리스트와 자동화 도구 활용법"
date: 2025-06-15
categories: 
  - tutorials
  - dev
tags: 
  - sass
  - scss  
  - dart-sass
  - ruby-sass
  - migration
  - frontend
author_profile: true
toc: true
toc_label: 마이그레이션 가이드
---

Ruby Sass 3.x 코드베이스를 최신 Dart Sass(향후 3.0 안전 대응)로 이동할 때 따라할 수 있는 체크리스트를 소개합니다. 핵심은 **"공식 Sass Migrator로 최대한 자동화 → 위험 구간만 수동 보강 → 빌드/CI 정비"**라는 세 단계로 압축됩니다.

## 1단계 – 사전 준비

### 1-1. 현행 버전 · 빌드 파이프라인 파악

`npm ls sass node-sass` 등으로 의존성을 확인합니다. Ruby Sass, LibSass, node-sass에서 Dart Sass로 갈아타야 합니다.

### 1-2. 안전망 확보

- **Git 브랜치** 새로 파서 전체를 백업해 두세요.
- 대규모 저장소라면 **폴더별 마이그레이션** 계획을 세워요.

## 2단계 – 도구 설치 및 환경 세팅

| 항목            | 명령어                                                                  | 비고                              |
| ------------- | -------------------------------------------------------------------- | ------------------------------- |
| Dart Sass 설치  | `npm i -D sass`                                                      | node-sass 제거 후 설치 |
| Sass Migrator | `npm i -g sass-migrator` 또는 `dart pub global activate sass_migrator` | 글로벌 설치 |

> **TIP** `npx sass-migrator --version` 으로 정상 설치를 확인하세요.

## 3단계 – 자동 마이그레이션 실행

### 3-1. 드라이런으로 변화 미리 보기

```bash
sass-migrator division,namespace,module path/to/**/*.scss --dry-run
```

변경 사항을 diff로 확인하고 커밋합니다.

### 3-2. `/` 연산 → `math.div()` 변환

```bash
sass-migrator division path/to/**/*.scss
```

Dart Sass 2.0부터 `/` 연산이 제거되니 필수입니다.

### 3-3. `@import` → `@use·@forward` 변환

```bash
sass-migrator module path/to/**/*.scss --migrate-deps
```

- 의존 파일까지 한 번에 바뀌도록 `--migrate-deps` 사용
- 변수·믹스인 접근은 자동으로 **네임스페이스**를 붙여줍니다

### 3-4. 네임스페이스 충돌 정리

```bash
sass-migrator namespace path/to/**/*.scss
```

동명이인 변수 · 믹스인을 안전하게 분리해 줍니다.

## 4단계 – 빌드 파이프라인 업데이트

1. **webpack**이라면 `sass-loader` v14+로 올리고, `implementation: require('sass')` 옵션으로 Dart Sass를 지정합니다.
2. Gulp/Grunt 사용 시 `gulp-sass` 대신 `gulp-dart-sass` 플러그인으로 교체합니다.

## 5단계 – 수동 점검 & 코드 클린업

| 체크 항목  | 설명                                                                |
| ------ | ----------------------------------------------------------------- |
| 컬러 함수  | `darken()/lighten()` 대신 `color.adjust()` 사용 |
| 복잡한 계산 | `math.div()`로 바뀌지 않은 비확정적 나눗셈 직접 수정                               |
| 중첩 셀렉터 | `&` 위치가 바뀌면서 의미가 달라졌는지 테스트                                        |
| 전역 변수  | `@use 'path' with ($var: value)` 구조로 재조정                          |

## 6단계 – 코드 스타일 & CI 통합

- **Stylelint 14+** 도입 → `stylelint-config-standard-scss` 사용해 규칙을 맞춥니다.
- `prettier-plugin-scss`로 코드 포맷 일관성 유지
- GitHub Actions · GitLab CI에서 **Sass compile + lint** 잡을 추가합니다.

## 7단계 – 테스트·배포

1. 브라우저 크로스 테스트로 시각적 회귀를 확인합니다.
2. 프로덕션 빌드를 한 번 더 돌려 **bundle size** 변화를 점검합니다.
3. 이상 없으면 메인 브랜치에 머지하고 배포합니다.

## 부록 – 문서 & 문제 해결 링크

- **공식 Migrator 사용법** [sass-lang.com](https://sass-lang.com/documentation/cli/migrator/)
- **Division 경고 해결 블로그** [weekendprojects.dev](https://weekendprojects.dev/posts/sasserror-math-div/)
- **@import → @use 깊이 있는 설명** [bom2zzang.tistory.com](https://bom2zzang.tistory.com/48)
- **네임스페이스 이슈 레포트** [github.com](https://github.com/sass/migrator/issues/257)

## 정리

1. **도구 설치** → 2. **division → module → namespace 순차 마이그레이션** → 3. **빌드·CI 업데이트** → 4. **수동 보강 & 테스트**

순서로 진행하면 대부분의 Sass 3.x 프로젝트를 하루 만에 Dart Sass로 옮길 수 있습니다. 이제 그대로 따라 적용해 보세요!
