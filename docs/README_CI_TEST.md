# 🧪 CI 로컬 테스트 가이드

이 가이드는 GitHub Actions CI 워크플로우를 macOS에서 로컬로 테스트하는 방법을 설명합니다.

## 📋 개요

`test-ci.sh` 스크립트는 `.github/workflows/ci.yml`과 동일한 검증을 로컬에서 실행합니다:

- 🧹 **Jekyll Lint & Test**: 설정 검증 및 개발 빌드
- 📝 **Markdown Lint**: Markdown 파일 문법 검사
- 📄 **YAML Lint**: YAML 파일 문법 검사

## 🚀 사용법

### 1. 기본 실행

```bash
./test-ci.sh
```

### 2. 스크립트 권한 문제 시

```bash
chmod +x test-ci.sh
./test-ci.sh
```

## 📦 필요한 도구들

### 필수 도구 (스크립트가 자동 확인)

- **Ruby** & **Bundler**: Jekyll 실행용
- **Node.js**: Markdown lint용 (선택사항)
- **Python3**: YAML lint용 (선택사항)

### macOS 설치 방법

```bash
# Homebrew로 한번에 설치
brew install ruby node python

# Bundler 설치
gem install bundler

# 글로벌 도구 설치 (스크립트가 자동으로 수행)
npm install -g markdownlint-cli
pip3 install yamllint
```

## 🔍 스크립트 동작 과정

### Step 1: 🧹 Jekyll Lint & Test
```bash
bundle install                              # 의존성 설치
bundle exec jekyll doctor                   # 설정 검증
JEKYLL_ENV=development bundle exec jekyll build --drafts --verbose
```

### Step 2: 📝 Markdown Lint
```bash
npm install -g markdownlint-cli            # 도구 설치 (필요시)
markdownlint '_posts/**/*.md' --config .markdownlint.json
```

### Step 3: 📄 YAML Lint
```bash
pip3 install yamllint                      # 도구 설치 (필요시)
yamllint -d relaxed .
```

## 📊 출력 예시

```
===========================================
🚀 CI 워크플로우 로컬 테스트 시작
===========================================

✅ Jekyll 프로젝트 루트 디렉토리 확인됨

===========================================
🧹 Step 1: Jekyll Lint & Test
===========================================

✅ Ruby 3.2.0 및 Bundler 확인됨

📦 Bundle 의존성 설치 중...
✅ Bundle 의존성 설치 완료

🧹 Jekyll 설정 검증 중...
✅ Jekyll 설정이 유효합니다!

🧪 Jekyll 개발 빌드 테스트 중...
✅ Jekyll 개발 빌드 테스트 완료!

===========================================
🎉 CI 워크플로우 로컬 테스트 완료
===========================================
✅ 모든 테스트가 성공적으로 완료되었습니다!
소요 시간: 45초
```

## 🛠️ 문제 해결

### Jekyll 빌드 실패
```bash
# 의존성 업데이트
bundle update

# 상세 로그 확인
bundle exec jekyll build --verbose --trace
```

### Markdown Lint 실패
```bash
# 자동 수정 시도
markdownlint '_posts/**/*.md' --config .markdownlint.json --fix

# 수동 확인
markdownlint '_posts/**/*.md' --config .markdownlint.json
```

### YAML Lint 실패
```bash
# 수동 확인
yamllint -d relaxed .

# 특정 파일만 확인
yamllint _config.yml
```

### Node.js/Python 없을 때
- **Node.js 없음**: Markdown Lint 건너뜀 (경고 메시지 표시)
- **Python3 없음**: YAML Lint 건너뜀 (경고 메시지 표시)
- Jekyll 테스트는 계속 진행됨

## 🎯 CI/CD 워크플로우와의 차이점

| 항목 | GitHub Actions | 로컬 스크립트 |
|------|----------------|---------------|
| **병렬 실행** | 3개 Job 병렬 | 순차 실행 |
| **환경** | Ubuntu 20.04 | macOS |
| **도구 설치** | 매번 새로 설치 | 기존 설치된 것 재사용 |
| **실행 시간** | ~2-3분 | ~30-60초 |

## 📝 사용 시나리오

### 1. 커밋 전 검증
```bash
# 변경사항 작업 후
./test-ci.sh

# 테스트 통과 후 커밋
git add .
git commit -m "Add new feature"
git push origin feature-branch
```

### 2. PR 생성 전 확인
```bash
# PR 생성 전 최종 검증
./test-ci.sh

# GitHub에서 PR 생성
```

### 3. CI 실패 디버깅
```bash
# GitHub Actions에서 CI 실패 시
./test-ci.sh

# 로컬에서 문제 해결 후 다시 푸시
```

## 🔗 관련 문서

- [CI/CD 가이드](CI_CD_GUIDE.md)
- [Jekyll 공식 문서](https://jekyllrb.com/docs/)
- [Markdown Lint 규칙](https://github.com/DavidAnson/markdownlint/blob/main/doc/Rules.md)

---

**💡 팁**: 이 스크립트를 정기적으로 실행하여 CI 실패를 사전에 방지하세요! 