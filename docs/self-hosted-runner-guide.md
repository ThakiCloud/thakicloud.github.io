# Self-Hosted Runner 설정 및 문제 해결 가이드

## 📋 발생 가능한 문제들

### 문제 1: Artifact 배포 실패 (Symlink 문제)
```
Error: Artifact could not be deployed. 
Please ensure the content does not contain any hard links, symlinks 
and total size is less than 10GB.
```

### 문제 2: Native Extension 컴파일 실패 (빌드 도구 미설치) ⚠️
```
You have to install development tools first.
No such file or directory - make
ERROR: Failed to build gem native extension.
```

**원인**: 호스트러너에 C 컴파일러, make 등 빌드 도구가 설치되지 않음
**영향받는 gem**: bigdecimal, eventmachine, http_parser.rb, json, ffi 등

## 🎯 문제 원인 및 해결 방법

### 1️⃣ **Symlink/Hard Link 문제**

#### 원인
- Bundler 캐시가 symlink를 생성할 수 있음
- Ruby gem 설치 경로에 symlink가 포함될 수 있음
- Jekyll 빌드 과정에서 생성되는 캐시 파일

#### 해결 방법
✅ **워크플로우에 cleanup 단계 추가** (이미 적용됨)
```yaml
- name: Clean up symlinks and hard links
  run: |
    find ./_site -type l -delete || true
    rm -rf ./_site/.sass-cache || true
    rm -rf ./_site/.jekyll-cache || true
```

### 2️⃣ **빌드 도구 설치 문제** ⚠️ 가장 흔한 문제!

#### 원인
- Native extension gem (C 코드로 작성된 gem)을 컴파일하려면 빌드 도구 필요
- 호스트러너에 gcc, make, 헤더 파일이 없으면 설치 실패

#### 해결 방법 A: 워크플로우에서 자동 설치 (✅ 이미 적용됨)
```yaml
- name: Install build dependencies
  run: |
    # Ubuntu/Debian
    if command -v apt-get &> /dev/null; then
      sudo apt-get update -qq
      sudo apt-get install -y -qq build-essential libssl-dev libreadline-dev zlib1g-dev
    # macOS
    elif command -v brew &> /dev/null; then
      brew install openssl readline
    fi
```

#### 해결 방법 B: 호스트러너에 수동 설치 (한 번만 실행)
```bash
# Ubuntu/Debian 호스트러너
sudo apt-get update
sudo apt-get install -y build-essential libssl-dev libreadline-dev zlib1g-dev

# macOS 호스트러너
xcode-select --install
brew install openssl readline

# 설치 확인
gcc --version
make --version
```

### 3️⃣ **호스트러너 환경 체크리스트**

#### CPU & 메모리 설정 (현재: CPU 1.6, 메모리 4GB)
```bash
# 권장 사양
CPU: 2 코어 이상
메모리: 8GB 이상 (다국어 빌드 시)

# 현재 설정으로도 가능하지만, 빌드 속도가 느릴 수 있음
```

#### 필수 확인 사항

##### ✅ 1. 빌드 도구 확인 (최우선!)
```bash
# 호스트러너에서 실행
gcc --version  # C 컴파일러
make --version  # make 도구
pkg-config --version  # 패키지 설정 도구

# 하나라도 없으면 위의 "해결 방법 B" 실행
```

##### ✅ 2. Ruby 환경 확인
```bash
# 호스트러너에서 실행
ruby -v  # 3.2 이상 필요
gem -v
bundle -v

# Ruby가 없다면 설치
# macOS
brew install ruby@3.2

# Linux (Ubuntu/Debian)
sudo apt-get update
sudo apt-get install ruby-full build-essential zlib1g-dev
```

##### ✅ 2. Jekyll 의존성 확인
```bash
# 호스트러너에서 실행
bundle install

# 오류 발생 시
gem install bundler
bundle update
```

##### ✅ 3. 파일시스템 타입 확인
```bash
# 호스트러너에서 실행
df -T .  # Linux
df -h .  # macOS

# ext4, APFS 등 일반 파일시스템이어야 함
# NFS, CIFS 같은 네트워크 파일시스템은 symlink 문제 발생 가능
```

##### ✅ 4. 디스크 공간 확인
```bash
# 호스트러너에서 실행
df -h

# 최소 10GB 이상의 여유 공간 필요
```

##### ✅ 5. 작업 디렉토리 권한 확인
```bash
# 호스트러너에서 실행
ls -la /path/to/runner/_work

# runner 사용자가 읽기/쓰기 권한을 가져야 함
```

### 4️⃣ **GitHub Actions Runner 설정**

#### Runner 레이블 확인
```bash
# GitHub 저장소 Settings > Actions > Runners에서 확인
레이블: self-hosted, linux, x64 (또는 macOS, arm64 등)
```

#### Runner 서비스 상태 확인
```bash
# Linux (systemd 사용 시)
sudo systemctl status actions.runner.*

# macOS
launchctl list | grep actions.runner

# 직접 실행하는 경우
./run.sh  # runner 디렉토리에서
```

### 5️⃣ **빌드 최적화 옵션**

#### 옵션 1: 빌드 job만 self-hosted 사용 (현재 설정)
```yaml
build:
  runs-on: self-hosted  # 호스트러너
deploy:
  runs-on: ubuntu-latest  # GitHub-hosted (안정성)
```

#### 옵션 2: 두 job 모두 self-hosted 사용
```yaml
build:
  runs-on: self-hosted
deploy:
  runs-on: self-hosted
```

#### 옵션 3: 특정 레이블 사용
```yaml
build:
  runs-on: [self-hosted, linux]  # 또는 [self-hosted, macOS]
```

### 6️⃣ **트러블슈팅 명령어**

#### 호스트러너에서 수동 빌드 테스트
```bash
# 1. 저장소 클론 (테스트용)
cd /tmp
git clone https://github.com/thakicloud/thakicloud.github.io.git
cd thakicloud.github.io

# 2. 의존성 설치
bundle install

# 3. Jekyll 빌드
JEKYLL_ENV=production bundle exec jekyll build --verbose

# 4. Symlink 확인
find ./_site -type l
find ./_site -links +1 -type f

# 5. 크기 확인
du -sh ./_site
```

#### 캐시 정리
```bash
# 호스트러너에서 실행
cd /path/to/runner/_work/thakicloud.github.io/thakicloud.github.io

# Jekyll 캐시 삭제
rm -rf .sass-cache .jekyll-cache .jekyll-metadata

# Bundler 캐시 삭제 (필요시)
bundle clean --force

# 완전히 새로 빌드
bundle exec jekyll clean
bundle exec jekyll build
```

## 🔧 추가 최적화 방안

### 1. .gitignore 확인
```gitignore
# Jekyll
_site/
.sass-cache/
.jekyll-cache/
.jekyll-metadata

# Bundler
.bundle/
vendor/
```

### 2. _config.yml 최적화
```yaml
# 불필요한 파일 제외
exclude:
  - .sass-cache/
  - .jekyll-cache/
  - gemfiles/
  - Gemfile
  - Gemfile.lock
  - node_modules/
  - vendor/
  - scripts/
  - docs/
  - "*.sh"
  - "*.py"
```

### 3. GitHub Actions 워크플로우 최적화
```yaml
# 캐시 버전 증가로 캐시 재생성
- name: Setup Ruby
  uses: ruby/setup-ruby@v1
  with:
    ruby-version: '3.2'
    bundler-cache: true
    cache-version: 1  # 1로 증가 (문제 발생 시)
```

## 📊 모니터링 및 디버깅

### GitHub Actions 로그 확인
```bash
# 각 단계의 로그를 자세히 확인
- "Clean up symlinks and hard links" 단계: symlink가 발견되었는지
- "Verify _site size" 단계: 크기가 적절한지
- "Upload artifact" 단계: 업로드가 성공했는지
- "Deploy to GitHub Pages" 단계: 어느 시점에서 실패하는지
```

### 성공적인 배포 확인
✅ Build job 성공
✅ Symlink cleanup 완료
✅ _site 크기 < 1GB
✅ Artifact 업로드 성공
✅ Deploy job 성공
✅ 사이트 접속 가능

## 🎓 추가 참고 자료

- [GitHub Actions Self-hosted Runners 공식 문서](https://docs.github.com/en/actions/hosting-your-own-runners)
- [GitHub Pages 배포 제한사항](https://docs.github.com/en/pages/getting-started-with-github-pages/about-github-pages#usage-limits)
- [Jekyll 빌드 최적화](https://jekyllrb.com/docs/configuration/options/)

---

## 💡 빠른 해결 체크리스트

- [ ] 워크플로우에 symlink cleanup 단계 추가 (✅ 완료)
- [ ] 호스트러너에서 Ruby 3.2+ 설치 확인
- [ ] 호스트러너에서 `bundle install` 실행 확인
- [ ] 호스트러너 디스크 공간 10GB+ 확인
- [ ] 호스트러너 파일시스템 타입 확인 (NFS/CIFS 아닌지)
- [ ] GitHub Actions Runner 서비스 정상 실행 확인
- [ ] 캐시 정리 후 재빌드
- [ ] 워크플로우 재실행

**문제가 계속되면**: build job을 `ubuntu-latest`로 되돌리고 GitHub-hosted runner 사용

