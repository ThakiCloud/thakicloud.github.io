# 🚀 CI/CD 가이드

이 문서는 ThakiCloud 블로그의 CI/CD 파이프라인에 대한 상세한 가이드입니다.

## 📋 목차

- [워크플로 개요](#워크플로-개요)
- [PR 검증 프로세스](#pr-검증-프로세스)
- [브랜치 보호 규칙](#브랜치-보호-규칙)
- [자동 배포](#자동-배포)
- [문제 해결](#문제-해결)

## 🔄 워크플로 개요

### 1. CI - Pull Request Validation (`.github/workflows/ci.yml`)

PR이 생성되거나 업데이트될 때 자동으로 실행되는 포괄적인 검증 파이프라인입니다.

#### 📝 검증 단계

| 단계 | 설명 | 도구 |
|------|------|------|
| 🏗️ **Jekyll Build Test** | Jekyll 사이트 빌드 테스트 | Bundle, Jekyll |
| 📝 **Markdown Lint** | Markdown 파일 린트 검사 | markdownlint-cli |
| 🔗 **HTML Validation** | HTML 유효성 및 링크 검사 | html-validate, broken-link-checker |
| 🛡️ **Security Scan** | 보안 취약점 스캔 | Trivy, detect-secrets |
| 🚦 **Lighthouse Audit** | 성능/접근성/SEO 감사 | Lighthouse CI |
| 🚀 **Deployment Simulation** | 배포 시뮬레이션 | Custom scripts |

#### 🎯 트리거 조건

```yaml
on:
  pull_request:
    branches: [ main, develop ]
    paths:
      - '**/*.md'
      - '**/*.html'
      - '**/*.yml'
      - '**/*.yaml'
      - '**/*.scss'
      - '**/*.css'
      - '**/*.js'
      - '_config.yml'
      - 'Gemfile*'
      - '.github/workflows/**'
```

### 2. Auto-merge (`.github/workflows/auto-merge.yml`)

승인된 PR의 자동 머지를 처리합니다.

#### 🤖 자동 머지 조건

- PR이 승인(approved) 상태일 때
- 모든 CI 체크가 통과했을 때
- `auto-merge` 라벨이 있을 때

### 3. Jekyll GitHub Pages (`.github/workflows/jekyll-gh-pages.yml`)

`main` 브랜치에 변경사항이 푸시되면 자동으로 GitHub Pages에 배포합니다.

## 🔒 브랜치 보호 규칙

`main` 브랜치에 다음 보호 규칙을 설정하는 것을 권장합니다:

### GitHub Repository Settings → Branches

1. **Branch name pattern**: `main`
2. **Require a pull request before merging**: ✅
   - Require approvals: `1`
   - Dismiss stale PR approvals when new commits are pushed: ✅
3. **Require status checks to pass before merging**: ✅
   - Require branches to be up to date before merging: ✅
   - 필수 status checks:
     - `🏗️ Jekyll Build Test`
     - `📝 Markdown Lint`
     - `🔗 HTML Validation & Link Check`
     - `🛡️ Security & Quality Scan`
4. **Require linear history**: ✅
5. **Include administrators**: ✅

## 📦 Dependabot 설정

`.github/dependabot.yml` 파일을 통해 의존성 자동 업데이트를 설정했습니다.

### 🔄 업데이트 일정

- **Ruby Gems**: 매주 월요일 09:00 (KST)
- **GitHub Actions**: 매주 월요일 09:30 (KST)

### 🏷️ 자동 라벨링

- `dependencies`
- `ruby` (Gems용)
- `github-actions` (Actions용)
- `auto-merge` (자동 머지 대상)

## 📝 사용 가이드

### 🆕 새 포스트 작성 시

1. 새 브랜치 생성:
   ```bash
   git checkout -b post/new-article-title
   ```

2. 포스트 작성 (Jekyll 규칙 준수):
   - 파일명: `YYYY-MM-DD-title.md`
   - Front Matter 필수 항목 포함
   - Markdown 스타일 가이드 준수

3. 로컬 테스트:
   ```bash
   bundle exec jekyll serve
   ```

4. PR 생성:
   - PR 템플릿에 따라 작성
   - 적절한 라벨 추가

5. CI 검증 대기:
   - 모든 체크가 통과할 때까지 대기
   - 실패 시 로그 확인 후 수정

6. 승인 및 머지:
   - 리뷰어 승인 후 자동 머지

### 🔧 CI 실패 시 대응

#### Jekyll Build 실패
```bash
# 로컬에서 빌드 테스트
bundle exec jekyll build --verbose --trace

# 의존성 문제 시
bundle update
```

#### Markdown Lint 실패
```bash
# 로컬에서 린트 실행
npx markdownlint '_posts/**/*.md' '_pages/**/*.md'

# 자동 수정 (가능한 경우)
npx markdownlint '_posts/**/*.md' '_pages/**/*.md' --fix
```

#### Link Check 실패
- 깨진 링크 수정
- 외부 링크 유효성 확인
- 이미지 경로 확인

### 🎯 성능 최적화

Lighthouse 감사에서 낮은 점수를 받은 경우:

#### Performance (성능)
- 이미지 최적화 (WebP 변환)
- 불필요한 CSS/JS 제거
- 지연 로딩 적용

#### Accessibility (접근성)
- alt 태그 추가
- 적절한 heading 구조
- 색상 대비 개선

#### SEO
- meta 태그 최적화
- structured data 추가
- 사이트맵 업데이트

## 🔍 모니터링 및 알림

### GitHub Actions 로그 확인

1. Repository → Actions 탭
2. 워크플로 실행 결과 확인
3. 실패한 단계의 로그 상세 분석

### 알림 설정

GitHub 설정에서 다음 알림을 활성화하는 것을 권장합니다:
- Actions 워크플로 실패
- PR 상태 변경
- Dependabot 보안 업데이트

## 🚨 응급 상황 대응

### CI 시스템 전체 장애

```bash
# 임시로 CI 건너뛰기 (권장하지 않음)
git commit -m "hotfix: critical bug fix [skip ci]"
```

### GitHub Pages 배포 실패

1. Actions 탭에서 실패 원인 확인
2. `_site` 폴더 권한 문제 확인
3. GitHub Pages 설정 확인

### 보안 취약점 발견

1. Dependabot 보안 업데이트 즉시 적용
2. 영향 범위 분석
3. 필요시 긴급 패치 배포

## 📈 CI/CD 개선 방안

### 1. 캐싱 최적화
- Ruby gems 캐싱
- Node.js 의존성 캐싱
- Jekyll 빌드 캐싱

### 2. 병렬 처리
- 독립적인 체크 동시 실행
- 매트릭스 빌드 활용

### 3. 조건부 실행
- 변경된 파일 유형에 따른 선택적 실행
- Draft PR에 대한 제한적 검증

## 🆘 문제 해결

### 자주 발생하는 문제

1. **Bundle 설치 실패**
   ```bash
   bundle clean --force
   bundle install
   ```

2. **Jekyll 빌드 오류**
   - `_config.yml` 문법 확인
   - Front Matter 형식 확인
   - Liquid 템플릿 문법 확인

3. **Markdown 린트 오류**
   - `.markdownlint.json` 설정 확인
   - 라인 길이 제한 (120자)
   - HTML 태그 사용 규칙

4. **링크 체크 실패**
   - 상대 경로 vs 절대 경로
   - 앵커 링크 유효성
   - 외부 링크 가용성

## 📚 추가 자료

- [GitHub Actions 공식 문서](https://docs.github.com/en/actions)
- [Jekyll 공식 문서](https://jekyllrb.com/docs/)
- [Markdown Lint 규칙](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)
- [Lighthouse 성능 가이드](https://web.dev/lighthouse-performance/)

---

**📞 문의사항이나 개선 제안이 있으시면 이슈를 생성해 주세요!** 

# CI/CD 워크플로우 가이드

## 📋 개요

이 프로젝트는 3단계 CI/CD 파이프라인을 사용합니다:

1. **Lint & Test**: 모든 커밋에서 실행
2. **Build & Package**: main 브랜치 머지 시 실행
3. **Production Deploy**: 태그 생성 시 실행

## 🔄 워크플로우 정책

### 1. Lint & Test (`ci.yml`)

**트리거 조건:**
- 모든 브랜치의 push (hotfix/* 브랜치 제외)
- main, develop 브랜치로의 Pull Request (hotfix/* 브랜치 제외)
- 수동 실행 (workflow_dispatch)

**실행 작업:**
- Jekyll 설정 검증 (`bundle exec jekyll doctor`)
- 개발 환경 빌드 테스트
- Markdown 문법 검사
- YAML 문법 검사

**목적:**
- 코드 품질 유지
- 빌드 오류 사전 방지
- 문서 규칙 준수 확인

### 2. Build & Package (`jekyll-gh-pages.yml`)

**트리거 조건:**
- main 브랜치 push (hotfix/* 브랜치 제외)
- 수동 실행 (workflow_dispatch)

**실행 작업:**
- 프로덕션 환경 Jekyll 빌드
- 빌드 정보 생성 (날짜, 커밋, 실행 번호)
- 빌드 아티팩트 저장 (30일 보관)

**목적:**
- 배포 준비된 빌드 생성
- 빌드 아티팩트 관리
- 배포 추적성 확보

### 3. Production Deploy (`production-deploy.yml`)

**트리거 조건:**
- 태그 생성 (v*.*.* 패턴, hotfix/* 브랜치 제외)
- 수동 실행 (workflow_dispatch)

**실행 작업:**
- 최신 성공 빌드 아티팩트 다운로드
- 배포 정보 추가
- GitHub Pages 배포

**목적:**
- 태그 기반 운영 배포
- 아티팩트 기반 배포로 일관성 보장
- 배포 추적 및 롤백 지원

## 🚫 제외 정책

### hotfix/* 브랜치
- 모든 워크플로우에서 제외
- 긴급 수정사항에 대한 별도 처리 필요

## 📱 사용 방법

### 개발 워크플로우

1. **기능 개발**
   ```bash
   git checkout -b feature/new-feature
   git commit -m "Add new feature"
   git push origin feature/new-feature
   ```
   → Lint & Test 실행

2. **Pull Request 생성**
   ```bash
   # GitHub에서 PR 생성
   ```
   → Lint & Test 실행

3. **main 브랜치 머지**
   ```bash
   # PR 승인 후 merge
   ```
   → Build & Package 실행

### 배포 워크플로우

1. **운영 배포**
   ```bash
   git tag v1.2.3
   git push origin v1.2.3
   ```
   → Production Deploy 실행

2. **수동 배포**
   - GitHub Actions 탭에서 "Production Deploy" 워크플로우 실행
   - 배포할 태그 입력

## 🔍 모니터링

### 빌드 상태 확인
- GitHub Actions 탭에서 워크플로우 실행 상태 확인
- 실패 시 로그 확인 및 수정

### 아티팩트 관리
- 빌드 아티팩트는 30일간 보관
- 배포 시 최신 성공 빌드 사용

### 배포 추적
- `build-info.txt`: 빌드 정보
- `deploy-info.txt`: 배포 정보

## ⚠️ 주의사항

1. **hotfix 브랜치**는 모든 자동화에서 제외됩니다
2. **태그는 v*.*.* 형식**만 운영 배포를 트리거합니다
3. **배포는 아티팩트 기반**으로 수행되므로 main 브랜치에 성공적인 빌드가 필요합니다
4. **동시 배포는 차단**되므로 이전 배포 완료 후 새 배포가 시작됩니다

## 🛠️ 트러블슈팅

### 빌드 실패
1. Lint & Test 실패: 코드 품질 문제 수정
2. Build & Package 실패: Jekyll 설정 또는 종속성 문제 확인

### 배포 실패
1. 아티팩트 없음: main 브랜치에 성공적인 빌드 확인
2. 권한 오류: GitHub Pages 설정 및 repository 권한 확인

### 응급 상황
- hotfix 브랜치 사용 시 수동으로 워크플로우 실행 필요
- 긴급 배포 시 workflow_dispatch 사용 