# ThakiCloud 블로그 로컬 개발 환경 구축 가이드 (macOS)

이 가이드는 ThakiCloud 기술 블로그를 macOS 환경에서 로컬로 실행하기 위한 단계별 설정 방법을 제공합니다.

## 목차
- [사전 요구사항](#사전-요구사항)
- [1단계: Homebrew 설치](#1단계-homebrew-설치)
- [2단계: Ruby 설치 (rbenv 사용)](#2단계-ruby-설치-rbenv-사용)
- [3단계: 프로젝트 클론](#3단계-프로젝트-클론)
- [4단계: 의존성 설치](#4단계-의존성-설치)
- [5단계: 로컬 서버 실행](#5단계-로컬-서버-실행)
- [문제 해결](#문제-해결)
- [추가 팁](#추가-팁)

---

## 사전 요구사항

### 필요한 도구들
- **macOS 10.15** 이상
- **Xcode Command Line Tools**
- **Homebrew** (패키지 관리자)
- **Ruby 3.0+** (Jekyll 요구사항)
- **Bundler** (Ruby 의존성 관리자)
- **Git** (소스 코드 관리)

### 예상 소요 시간
- 신규 설치: 30-45분
- 기존 환경이 있는 경우: 10-15분

---

## 1단계: Homebrew 설치

### 1.1 Homebrew가 이미 설치되어 있는지 확인
```bash
brew --version
```

설치되어 있다면 다음과 같은 결과가 나타납니다:
```
Homebrew 4.x.x
```

### 1.2 Homebrew 설치 (필요한 경우)
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### 1.3 Xcode Command Line Tools 설치
```bash
xcode-select --install
```

팝업이 나타나면 "Install"을 클릭하고 설치를 완료합니다.

---

## 2단계: Ruby 설치 (rbenv 사용)

macOS에 기본 설치된 Ruby는 시스템 Ruby로, Jekyll 개발에는 적합하지 않습니다. rbenv를 사용하여 최신 Ruby를 설치합니다.

### 2.1 rbenv 및 ruby-build 설치
```bash
brew install rbenv ruby-build
```

### 2.2 셸 환경 설정
**Zsh 사용자 (macOS 기본):**
```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(rbenv init -)"' >> ~/.zshrc
source ~/.zshrc
```

**Bash 사용자:**
```bash
echo 'export PATH="$HOME/.rbenv/bin:$PATH"' >> ~/.bash_profile
echo 'eval "$(rbenv init -)"' >> ~/.bash_profile
source ~/.bash_profile
```

### 2.3 설치 가능한 Ruby 버전 확인
```bash
rbenv install -l
```

### 2.4 Ruby 3.2.8 설치 (권장)

**추천 버전 선택 가이드:**
- **Ruby 3.2.8**: 최신 안정성과 성능, Jekyll과 완벽 호환 (권장)
- **Ruby 3.1.7**: GitHub Pages 완벽 호환, 보수적 선택
- **Ruby 3.3.x**: 최신 기능, 일부 gem 호환성 주의
- **Ruby 3.4.x**: 실험적, 프로덕션 비권장

```bash
rbenv install 3.2.8
rbenv global 3.2.8
```

### 2.5 설치 확인
```bash
ruby -v
which ruby
```

다음과 같은 결과가 나와야 합니다:
```
ruby 3.2.8p91 (2024-xx-xx revision xxxxxxx) [arm64-darwin22]
/Users/username/.rbenv/shims/ruby
```

### 2.6 Bundler 설치
```bash
gem install bundler
```

---

## 3단계: 프로젝트 클론

### 3.1 프로젝트를 원하는 디렉터리로 이동
```bash
cd ~/Documents/
# 또는 원하는 디렉터리로 이동
```

### 3.2 저장소 클론
```bash
git clone https://github.com/ThakiCloud/thakicloud.github.io.git
cd thakicloud.github.io
```

### 3.3 프로젝트 구조 확인
```bash
ls -la
```

다음과 같은 파일들이 있는지 확인:
- `_config.yml`
- `Gemfile`
- `Gemfile.lock`
- `_posts/` 디렉터리
- `_layouts/` 디렉터리

---

## 4단계: 의존성 설치

### 4.1 Bundle 설치
```bash
bundle install
```

이 명령은 `Gemfile`에 명시된 모든 Ruby gem들을 설치합니다.

### 4.2 설치 진행 상황 모니터링
설치 과정에서 다음과 같은 메시지들이 나타납니다:
```
Fetching gem metadata from https://rubygems.org/
Installing jekyll 4.x.x
Installing minimal-mistakes-jekyll x.x.x
...
Bundle complete!
```

### 4.3 설치 확인
```bash
bundle exec jekyll --version
```

Jekyll 버전이 출력되면 성공입니다.

---

## 5단계: 로컬 서버 실행

### 5.1 개발 서버 시작
```bash
bundle exec jekyll serve
```

### 5.2 실시간 재빌드 옵션 (권장)
```bash
bundle exec jekyll serve --livereload
```

### 5.3 드래프트 포함 옵션
```bash
bundle exec jekyll serve --livereload --drafts
```

### 5.4 성공 메시지 확인
다음과 같은 메시지가 나타나면 성공:
```
Configuration file: /path/to/thakicloud.github.io/_config.yml
            Source: /path/to/thakicloud.github.io
       Destination: /path/to/thakicloud.github.io/_site
 Incremental build: disabled. Enable with --incremental
      Generating... 
                    done in 2.341 seconds.
 Auto-regeneration: enabled for '/path/to/thakicloud.github.io'
    Server address: http://127.0.0.1:4000/
  Server running... press ctrl-c to stop.
```

### 5.5 브라우저에서 확인
웹 브라우저에서 다음 주소로 접속:
```
http://localhost:4000
```

---

## 문제 해결

### 문제 1: Ruby 버전 충돌
**증상:**
```
Your Ruby version is x.x.x, but your Gemfile specified y.y.y
```

**해결방법:**
```bash
rbenv local 3.2.8
bundle install
```

### 문제 2: Permission 에러
**증상:**
```
Permission denied @ rb_sysopen
```

**해결방법:**
```bash
# 시스템 Ruby 사용하지 말고 rbenv Ruby 사용 확인
which ruby
# /Users/username/.rbenv/shims/ruby 가 나와야 함

# gem 설치 경로 확인
gem env home
```

### 문제 3: Bundle 설치 실패
**증상:**
```
An error occurred while installing nokogiri
```

**해결방법:**
```bash
# Xcode Command Line Tools 재설치
sudo xcode-select --reset
xcode-select --install

# 특정 gem 설치 문제 해결
bundle config build.nokogiri --use-system-libraries
bundle install
```

### 문제 4: Port 4000 이미 사용 중
**증상:**
```
Address already in use - bind(2) (Errno::EADDRINUSE)
```

**해결방법:**
```bash
# 다른 포트 사용
bundle exec jekyll serve --port 4001

# 또는 4000 포트 사용 중인 프로세스 종료
lsof -ti:4000 | xargs kill -9
```

### 문제 5: 페이지가 업데이트되지 않음
**해결방법:**
```bash
# 캐시 클리어 후 재시작
rm -rf _site .jekyll-cache
bundle exec jekyll serve --livereload
```

---

## 추가 팁

### 개발 워크플로우 최적화

#### 1. 별칭(Alias) 설정
`~/.zshrc` 또는 `~/.bash_profile`에 추가:
```bash
alias jserve="bundle exec jekyll serve --livereload --drafts"
alias jbuild="bundle exec jekyll build"
alias jclean="rm -rf _site .jekyll-cache"
```

적용:
```bash
source ~/.zshrc  # 또는 source ~/.bash_profile
```

사용:
```bash
jserve  # 개발 서버 시작
```

#### 2. VS Code 통합
추천 확장:
- **Jekyll Snippets**
- **Liquid**
- **YAML**
- **Markdown All in One**

#### 3. 새 포스트 작성 템플릿
`_drafts/` 디렉터리 생성 및 템플릿 사용:
```bash
mkdir -p _drafts
```

새 포스트 템플릿 (`_drafts/template.md`):
```markdown
---
title: "제목을 입력하세요"
excerpt: "포스트 요약을 입력하세요"
date: YYYY-MM-DD
categories:
  - 카테고리명
tags:
  - 태그1
  - 태그2
author_profile: true
---

포스트 내용을 작성하세요.
```

#### 4. 성능 최적화
큰 사이트의 경우:
```bash
# 증분 빌드 활성화
bundle exec jekyll serve --incremental --livereload

# 특정 포스트만 처리
bundle exec jekyll serve --limit_posts 5
```

### 배포 전 체크리스트

1. **로컬 빌드 테스트:**
   ```bash
   JEKYLL_ENV=production bundle exec jekyll build
   ```

2. **링크 검사:**
   ```bash
   bundle exec htmlproofer ./_site --check-html --check-opengraph
   ```

3. **성능 체크:**
   - 이미지 최적화 확인
   - 페이지 로딩 속도 테스트

### 정기적인 유지보수

#### 월간 체크리스트:
```bash
# Ruby 및 gem 업데이트
brew upgrade rbenv ruby-build
rbenv install-latest

# Bundle 의존성 업데이트
bundle update

# Jekyll 버전 확인
bundle exec jekyll --version
```

---

## 도움말 및 참고 자료

### 공식 문서
- [Jekyll 공식 문서](https://jekyllrb.com/docs/)
- [Minimal Mistakes 테마 문서](https://mmistakes.github.io/minimal-mistakes/)
- [GitHub Pages 문서](https://docs.github.com/en/pages)

### 커뮤니티
- [Jekyll Talk Forum](https://talk.jekyllrb.com/)
- [Jekyll Discord](https://discord.gg/jekyll)

### 문제 보고
프로젝트 관련 문제는 [GitHub Issues](https://github.com/ThakiCloud/thakicloud.github.io/issues)에 보고해주세요.

---

**축하합니다! 🎉** 
ThakiCloud 블로그 로컬 개발 환경이 성공적으로 구축되었습니다. 이제 로컬에서 편안하게 포스트를 작성하고 테스트할 수 있습니다. 