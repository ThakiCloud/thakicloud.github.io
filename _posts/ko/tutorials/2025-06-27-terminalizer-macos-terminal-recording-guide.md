---
title: "Terminalizer 완전 가이드 - macOS에서 터미널 녹화하고 GIF 만들기"
excerpt: "macOS에서 Terminalizer로 터미널 세션을 녹화하고 animated GIF를 생성하는 완전한 튜토리얼"
seo_title: "Terminalizer macOS 터미널 녹화 가이드 - GIF 생성 튜토리얼 - Thaki Cloud"
seo_description: "macOS에서 Terminalizer 설치부터 zshrc alias 설정, 터미널 녹화, GIF 생성까지 개발자를 위한 완전한 가이드. 터미널 데모 영상 제작의 모든 것"
date: 2025-06-27
categories: 
  - tutorials
  - dev
tags: 
  - Terminalizer
  - macOS
  - 터미널-녹화
  - GIF-생성
  - zsh
  - alias
  - 개발자-도구
  - 터미널-데모
author_profile: true
toc: true
toc_label: "Terminalizer 가이드"
canonical_url: "https://thakicloud.github.io/tutorials/dev/terminalizer-macos-terminal-recording-guide/"
published: false
---

개발자라면 누구나 터미널 작업을 공유하거나 문서화해야 할 때가 있습니다. [Terminalizer](https://github.com/faressoft/terminalizer)는 터미널 세션을 녹화하고 아름다운 animated GIF로 변환해주는 강력한 도구입니다. 이 가이드에서는 macOS에서 Terminalizer를 완벽하게 활용하는 방법을 다룹니다.

## Terminalizer란?

Terminalizer는 다음과 같은 기능을 제공하는 오픈소스 도구입니다.

- **터미널 녹화**: 실제 터미널 세션을 YAML 파일로 기록
- **GIF 생성**: 녹화된 세션을 고품질 animated GIF로 변환
- **웹 플레이어**: 온라인에서 재생 가능한 웹 플레이어 생성
- **테마 커스터마이징**: 폰트, 색상, 프레임 스타일 완전 커스터마이징

## macOS 설치 가이드

### 1. Node.js 설치 확인

Terminalizer는 Node.js 기반이므로 먼저 Node.js가 설치되어 있는지 확인합니다.

```bash
node --version
npm --version
```

Node.js가 없다면 [공식 웹사이트](https://nodejs.org)에서 설치하거나 Homebrew를 사용합니다.

```bash
# Homebrew로 Node.js 설치
brew install node
```

### 2. Terminalizer 설치

```bash
# npm으로 전역 설치
npm install -g terminalizer

# 또는 yarn 사용
yarn global add terminalizer
```

### 3. 설치 확인

```bash
terminalizer --version
```

## 기본 사용법

### 전역 설정 초기화

먼저 전역 설정 디렉토리를 생성합니다.

```bash
terminalizer init
```

이 명령은 `~/.config/terminalizer` 디렉토리를 생성하고 기본 설정 파일을 복사합니다.

### 기본 녹화 워크플로우

#### 1. 녹화 시작

```bash
terminalizer record my-demo
```

- 녹화가 시작되면 새로운 터미널 세션이 열립니다.
- 원하는 명령어들을 실행합니다.
- `exit` 명령으로 녹화를 종료합니다.

#### 2. 녹화 파일 재생

```bash
terminalizer play my-demo
```

#### 3. GIF로 렌더링

```bash
terminalizer render my-demo
```

생성된 GIF 파일은 `my-demo.gif`로 저장됩니다.

## zshrc Alias 설정으로 워크플로우 간소화

매번 긴 명령어를 입력하는 것은 번거롭습니다. zshrc에 유용한 alias들을 설정해보겠습니다.

### ~/.zshrc 파일 편집

```bash
# zshrc 파일 열기
nano ~/.zshrc
# 또는 VS Code 사용
code ~/.zshrc
```

### 추천 Alias 설정

```bash
# Terminalizer 관련 alias들
alias trec='terminalizer record'
alias tplay='terminalizer play'
alias trender='terminalizer render'
alias tshare='terminalizer share'
alias tconfig='terminalizer config'

# 빠른 녹화 + 렌더링 함수
function tquick() {
    if [ -z "$1" ]; then
        echo "사용법: tquick <파일명>"
        return 1
    fi
    
    echo "🎬 '$1' 녹화를 시작합니다..."
    terminalizer record "$1"
    
    echo "🎨 GIF로 렌더링 중..."
    terminalizer render "$1"
    
    echo "✅ '$1.gif' 생성 완료!"
    open "$1.gif"
}

# 고품질 렌더링 함수
function thq() {
    if [ -z "$1" ]; then
        echo "사용법: thq <파일명>"
        return 1
    fi
    
    terminalizer render "$1" --quality 100
    echo "🎯 고품질 '$1.gif' 생성 완료!"
    open "$1.gif"
}

# 프로젝트별 녹화 디렉토리 관리
function tproj() {
    local project_name="$1"
    if [ -z "$project_name" ]; then
        echo "사용법: tproj <프로젝트명>"
        return 1
    fi
    
    mkdir -p ~/terminalizer-recordings/"$project_name"
    cd ~/terminalizer-recordings/"$project_name"
    echo "📂 프로젝트 '$project_name' 디렉토리로 이동했습니다."
}
```

### 설정 적용

```bash
# zshrc 다시 로드
source ~/.zshrc
```

## 고급 커스터마이징

### 설정 파일 생성

현재 디렉토리에 커스텀 설정 파일을 생성합니다.

```bash
terminalizer config
```

### 주요 설정 옵션

생성된 `config.yml` 파일을 편집하여 다음과 같이 커스터마이징할 수 있습니다.

```yaml
# 녹화 설정
recording:
  command: zsh  # macOS의 기본 쉘
  cwd: null
  env:
    recording: true
  cols: auto
  rows: auto

# 지연 시간 설정
delays:
  frameDelay: auto  # 실제 타이핑 속도 반영
  maxIdleTime: 2000  # 최대 2초 대기

# GIF 품질 설정
gif:
  quality: 80
  repeat: 0  # 무한 반복

# 터미널 모양
terminal:
  cursorStyle: block
  fontFamily: '"Fira Code", "SF Mono", Monaco, monospace'
  fontSize: 14
  lineHeight: 1.4
  letterSpacing: 0

# 프레임 스타일
frameBox:
  type: window
  title: "Terminal Demo"
  style:
    backgroundColor: '#2d3748'
    boxShadow: '0 20px 40px rgba(0,0,0,0.4)'
    borderRadius: 6px

# 워터마크 (선택사항)
watermark:
  imagePath: null
  style:
    position: absolute
    right: 15px
    bottom: 15px
    width: 100px
    opacity: 0.8
```

### 커스텀 설정으로 녹화

```bash
# 커스텀 설정 파일 사용
terminalizer record demo -c config.yml
```

## 실전 사용 예시

### 1. Git 워크플로우 데모

```bash
# 새 프로젝트 디렉토리 생성
tproj git-demo

# Git 워크플로우 녹화
trec git-workflow

# 녹화 세션에서 실행할 명령어들:
git init
echo "# My Project" > README.md
git add README.md
git commit -m "Initial commit"
git log --oneline
exit

# GIF 생성
trender git-workflow
```

### 2. 개발 환경 설정 데모

```bash
# 개발 환경 설정 녹화
trec dev-setup

# 녹화 중 실행:
npm init -y
npm install express
echo 'console.log("Hello World!")' > app.js
node app.js
exit

# 고품질 GIF 생성
thq dev-setup
```

### 3. 빠른 코딩 데모

```bash
# 한 번에 녹화 + 렌더링
tquick coding-demo

# 녹화 중:
vim hello.py
# Python 코드 작성
python hello.py
exit
```

## 문제 해결

### 권한 오류 해결

```bash
# Node.js 권한 문제 해결
sudo mkdir -p /usr/local/lib/node_modules
sudo chown -R $(whoami):$(whoami) /usr/local/lib/node_modules
```

### 폰트 문제 해결

macOS에서 터미널 폰트가 제대로 표시되지 않는 경우:

```yaml
# config.yml에서 폰트 설정
terminal:
  fontFamily: '"SF Mono", "Monaco", "Menlo", monospace'
```

### 녹화 파일이 너무 큰 경우

```bash
# 프레임 스텝 조정으로 파일 크기 줄이기
terminalizer render demo --step 2

# 품질 조정
terminalizer render demo --quality 50
```

## 프로 팁

### 1. 녹화 전 준비사항

```bash
# 터미널 히스토리 클리어
clear
history -c

# 프롬프트 단순화 (선택사항)
export PS1="$ "
```

### 2. 효과적인 데모 제작

- **속도 조절**: 너무 빠르게 타이핑하지 마세요
- **명확한 명령어**: 한 번에 하나씩 명령어 실행
- **결과 확인**: 각 명령어 후 잠시 멈춰서 결과 확인
- **클린업**: 불필요한 출력은 `clear` 명령으로 정리

### 3. 배치 처리 스크립트

여러 데모를 한 번에 처리하는 스크립트:

```bash
#!/bin/zsh
# batch-render.sh

demos=("git-demo" "docker-demo" "npm-demo")

for demo in "${demos[@]}"; do
    echo "🎨 렌더링 중: $demo"
    terminalizer render "$demo" --quality 90
    echo "✅ 완료: $demo.gif"
done

echo "🎉 모든 데모 렌더링 완료!"
```

## 고급 워크플로우

### GitHub Actions와 연동

```yaml
# .github/workflows/demo.yml
name: Generate Terminal Demos

on:
  push:
    paths:
      - 'demos/*.yml'

jobs:
  render:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Setup Node.js
        uses: actions/setup-node@v2
        with:
          node-version: '16'
      - name: Install Terminalizer
        run: npm install -g terminalizer
      - name: Render demos
        run: |
          for demo in demos/*.yml; do
            terminalizer render "$demo"
          done
      - name: Upload artifacts
        uses: actions/upload-artifact@v2
        with:
          name: terminal-gifs
          path: '*.gif'
```

### 웹 플레이어 생성

```bash
# 웹 플레이어 생성
terminalizer generate my-demo

# 로컬 서버에서 테스트
python -m http.server 8000
# http://localhost:8000에서 확인
```

## 마무리

Terminalizer는 개발자의 터미널 워크플로우를 시각적으로 공유하는 최고의 도구입니다. 이 가이드의 alias 설정과 커스터마이징을 통해 다음과 같은 이점을 얻을 수 있습니다.

### 핵심 이점

- **빠른 녹화**: `tquick demo`로 원클릭 녹화 + 렌더링
- **일관된 품질**: 커스텀 설정으로 통일된 스타일
- **효율적 관리**: 프로젝트별 디렉토리 구조화
- **자동화**: 배치 처리로 여러 데모 동시 생성

### 활용 시나리오

- **기술 블로그**: 코딩 튜토리얼 시각화
- **오픈소스 프로젝트**: README에 사용법 데모
- **팀 공유**: 새로운 도구나 워크플로우 소개
- **포트폴리오**: 개발 스킬 시연

이제 `tquick my-awesome-demo` 명령어 하나로 전문적인 터미널 데모를 만들어보세요. 여러분의 개발 과정을 더 효과적으로 공유할 수 있을 것입니다! 