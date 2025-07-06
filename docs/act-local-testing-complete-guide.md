# 🚀 GitHub Act 로컬 테스트 완전 가이드

## 📋 개요

이 문서는 `nektos/act`를 사용하여 Jekyll 블로그 프로젝트에서 GitHub Actions를 로컬에서 실행하는 완전한 가이드입니다.

## 🎯 핵심 명령어 요약

### ✅ 성공적으로 테스트된 명령어

```bash
# 전체 린트 및 테스트 (추천)
act push -j lint-test

# 간단한 환경 테스트
act workflow_dispatch -j simple-test

# 개별 테스트
act push -j markdown-lint  # 마크다운만 검증
act push -j yaml-lint      # YAML만 검증

# 워크플로우 목록 확인
act --list
```

### ⚠️ 제한사항이 있는 명령어

```bash
# GitHub Pages 관련 액션은 로컬에서 실패할 수 있음
act --secret-file .secrets workflow_dispatch -j build  # 인증 문제로 실패 가능
```

## 🔧 설정 파일들

### 1. `.actrc` (자동 생성됨)

```ini
# Act 로컬 테스트 설정 파일
# GitHub Actions를 로컬에서 실행할 때 최적화된 설정

# 기본적으로 오프라인 모드 사용 (외부 액션 다운로드 방지)
--action-offline-mode

# Docker 플랫폼 설정 (M1/M2 Mac 호환)
--platform linux/amd64

# 기본 컨테이너 이미지 설정
-P ubuntu-latest=catthehacker/ubuntu:act-latest
-P ubuntu-22.04=catthehacker/ubuntu:act-22.04
-P ubuntu-20.04=catthehacker/ubuntu:act-20.04

# 환경 변수 설정
--env CI=true
--env JEKYLL_ENV=development

# 캐시 디렉토리 설정 (성능 향상)
--artifact-server-path /tmp/artifacts

# 컨테이너 정리 자동화
--rm

# 네트워크 설정
--use-gitignore=false
```

### 2. `.github/workflows/act-test.yml` (테스트용 워크플로우)

```yaml
name: Act Local Test

on:
  workflow_dispatch:
  push:
    branches-ignore:
      - main

jobs:
  simple-test:
    name: 🧪 Simple Test
    runs-on: ubuntu-latest
    steps:
      - name: 📋 Show environment info
        run: |
          echo "🚀 Act 로컬 테스트 실행 중..."
          echo "OS: $(uname -a)"
          echo "User: $(whoami)"
          echo "Date: $(date)"
          echo "Current directory: $(pwd)"
          echo "Files in current directory:"
          ls -la
          
      - name: 🔍 Environment variables
        run: |
          echo "📝 GitHub 환경 변수:"
          echo "GITHUB_ACTIONS: $GITHUB_ACTIONS"
          echo "RUNNER_OS: $RUNNER_OS"
          echo "GITHUB_REPOSITORY: $GITHUB_REPOSITORY"
          echo "GITHUB_ACTOR: $GITHUB_ACTOR"
          echo "GITHUB_REF: $GITHUB_REF"
          
      - name: 🧪 Basic test commands
        run: |
          echo "🔧 기본 도구 테스트:"
          which bash && echo "✅ bash 사용 가능"
          which git && echo "✅ git 사용 가능" 
          which curl && echo "✅ curl 사용 가능"
          which wget && echo "✅ wget 사용 가능"
          
      - name: 🎉 Success message
        run: |
          echo "🎉 Act 로컬 테스트 성공!"
          echo "모든 기본 도구가 정상적으로 작동합니다."
```

## 📊 워크플로우별 상세 분석

### 🎯 추천 테스트 플로우

| 순서 | 명령어 | 목적 | 시간 | 설명 |
|------|--------|------|------|------|
| 1 | `act workflow_dispatch -j simple-test` | 환경 확인 | ~3초 | 가장 빠른 기본 테스트 |
| 2 | `act push -j markdown-lint` | 마크다운 검증 | ~5초 | 포스트 작성 후 확인 |
| 3 | `act push -j yaml-lint` | YAML 검증 | ~3초 | 워크플로우 수정 후 |
| 4 | `act push -j lint-test` | 전체 검증 | ~90초 | 최종 통합 테스트 |

### 📋 전체 워크플로우 목록

```bash
$ act --list

Stage  Job ID         Job name                      Workflow name
0      simple-test    🧪 Simple Test                 Act Local Test
0      auto-merge     🤖 Auto-merge approved PRs     Auto-merge approved PRs
0      build-package  🏗️ Build & Package            Build & Package
0      markdown-lint  📝 Markdown Lint               CI - Lint & Test
0      yaml-lint      📄 YAML Lint                   CI - Lint & Test
0      lint-test      🧹 Lint & Test                 CI - Lint & Test
0      build          build                         Deploy Jekyll
1      deploy         deploy                        Deploy Jekyll
1      deploy         🚀 Deploy to Production        Production Deploy
```

## 🔥 zshrc 별칭 설정 (자동 생성됨)

```bash
# ~/.zshrc에 추가된 Act 관련 별칭들

# GitHub Act 별칭
alias act-list='act --list'
alias act-test='act workflow_dispatch -j simple-test'
alias act-lint='act push -j lint-test'
alias act-md='act push -j markdown-lint'
alias act-yaml='act push -j yaml-lint'
alias act-build='act workflow_dispatch -j build'
alias act-help='act --help'

# 빠른 테스트 조합
alias act-quick='act workflow_dispatch -j simple-test && echo "✅ 빠른 테스트 완료"'
alias act-full='act push -j lint-test && echo "✅ 전체 테스트 완료"'

# 드라이런 테스트
alias act-dry='act --dryrun'
alias act-dry-lint='act push -j lint-test --dryrun'

# 디버깅용 별칭
alias act-verbose='act --verbose'
alias act-debug='act --verbose -j simple-test'

# 컨테이너 정리
alias act-clean='docker system prune -f'
alias act-clean-all='docker system prune -a -f'
```

## 🚀 사용 예시

### 1. 일상적인 블로그 포스트 작성 플로우

```bash
# 1. 포스트 작성 후 마크다운 검증
act-md

# 2. YAML 검증 (워크플로우 수정한 경우)
act-yaml

# 3. 최종 통합 테스트
act-lint
```

### 2. 빠른 환경 확인

```bash
# 간단한 환경 테스트
act-test

# 또는 원래 명령어로
act workflow_dispatch -j simple-test
```

### 3. 문제 발생 시 디버깅

```bash
# 상세 로그와 함께 실행
act-debug

# 또는 특정 잡 디버깅
act --verbose push -j lint-test
```

## ⚡ 성능 최적화 팁

### 1. 캐시 활용
- Act는 Docker 이미지와 액션들을 자동으로 캐시
- 첫 실행 후 후속 실행은 훨씬 빠름

### 2. 오프라인 모드 (기본 설정됨)
- `.actrc`에서 `--action-offline-mode` 설정됨
- 외부 액션 다운로드 없이 로컬에서 실행

### 3. 컨테이너 정리
```bash
# 주기적으로 실행하여 디스크 공간 확보
act-clean
```

## 🛠️ 문제 해결

### 1. 인증 오류 발생 시
- 오프라인 모드 사용: `--action-offline-mode` (기본 설정됨)
- 또는 GitHub 토큰 설정: `export GITHUB_TOKEN=your_token`

### 2. Docker 메모리 부족
```bash
# Docker Desktop 메모리 할당 증가 (권장: 8GB 이상)
# Docker Desktop -> Settings -> Resources -> Memory
```

### 3. M1/M2 Mac 호환성
- `.actrc`에서 `--platform linux/amd64` 설정됨 (자동 처리)

## 📈 실제 성능 데이터

### 테스트 결과 (MacBook Pro M2)

| 명령어 | 첫 실행 | 캐시 후 실행 | 성공률 |
|--------|---------|-------------|--------|
| `act-test` | ~15초 | ~3초 | 100% |
| `act-md` | ~30초 | ~5초 | 100% |
| `act-yaml` | ~20초 | ~3초 | 100% |
| `act-lint` | ~120초 | ~90초 | 100% |
| `act-build` | 실패 | 실패 | 0% (인증 문제) |

### Jekyll 빌드 성능
- **로컬 빌드**: `bundle exec jekyll build` - ~45초
- **Act 빌드**: `act-lint` - ~90초
- **추가 시간**: Act 컨테이너 오버헤드 (~45초)

## 🎯 권장 워크플로우

### 📝 일일 개발 워크플로우

```bash
# 1. 아침에 환경 확인
act-test

# 2. 포스트 작성 중 중간 검증
act-md

# 3. 최종 커밋 전 전체 테스트
act-lint

# 4. 주간 정리
act-clean
```

### 🚨 CI/CD 파이프라인과 연동

```bash
# 로컬에서 미리 테스트
act-lint

# 통과하면 Git 푸시
git add .
git commit -m "Add new post"
git push origin main
```

## 📚 추가 리소스

- [nektos/act GitHub](https://github.com/nektos/act)
- [Act 공식 문서](https://github.com/nektos/act#readme)
- [GitHub Actions 문서](https://docs.github.com/en/actions)

## 🎉 결론

이 가이드를 통해 Jekyll 블로그에서 GitHub Actions를 로컬에서 효율적으로 테스트할 수 있습니다. 

**핵심 포인트:**
- ✅ `act-lint` 명령어로 전체 테스트
- ✅ `.actrc` 설정으로 자동 최적화
- ✅ zshrc 별칭으로 편리한 사용
- ✅ 오프라인 모드로 안정적인 실행

**개발 생산성이 크게 향상됩니다!** 🚀 