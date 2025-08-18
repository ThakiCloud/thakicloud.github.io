---
title: "Sampler로 터미널에서 실시간 모니터링하기 - 완전한 가이드"
excerpt: "YAML 설정만으로 시스템, 웹사이트, 개발환경을 실시간 모니터링할 수 있는 강력한 도구 Sampler 완전 정복"
seo_title: "Sampler 터미널 모니터링 도구 완전 가이드 - macOS 실습 - Thaki Cloud"
seo_description: "Sampler로 시스템 리소스, 웹사이트 상태, Git 활동을 실시간 모니터링하는 방법. YAML 설정부터 실제 테스트까지 macOS 환경에서 완전히 검증된 튜토리얼"
date: 2025-08-18
last_modified_at: 2025-08-18
categories:
  - tutorials
tags:
  - sampler
  - monitoring
  - terminal
  - devops
  - yaml
  - macos
  - golang
  - visualization
  - alerting
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/sampler-terminal-monitoring-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 15분

## 서론

개발자라면 누구나 시스템 리소스 사용량, 웹사이트 응답 시간, Git 활동 등을 모니터링해야 하는 순간이 있습니다. 기존에는 여러 도구를 조합하거나 복잡한 대시보드를 구축해야 했지만, **Sampler**는 단순한 YAML 설정만으로 터미널에서 아름다운 실시간 모니터링 대시보드를 제공합니다.

[Sampler](https://github.com/sqshq/sampler)는 13.8k 스타를 받은 Go로 작성된 오픈소스 도구로, 셸 명령어의 실행 결과를 시각화하고 알림을 제공하는 강력한 기능을 제공합니다.

### 이 튜토리얼에서 배울 내용

- Sampler 설치 및 기본 사용법
- 시스템 리소스 모니터링 대시보드 구축
- 웹사이트 상태 모니터링 및 알림 설정
- 개발환경 Git 활동 추적
- Docker 컨테이너 모니터링
- 실무에 바로 적용할 수 있는 YAML 템플릿

## 1. Sampler 설치 및 환경 설정

### macOS에서 설치하기

HomeBrew를 사용하여 간단하게 설치할 수 있습니다:

```bash
# HomeBrew로 설치
brew install sampler

# 설치 확인
sampler --version
```

**테스트 결과:**
```
1.1.0
```

### 프로젝트 디렉토리 설정

```bash
# 테스트 환경 설정
mkdir -p ~/sampler-configs
cd ~/sampler-configs

# 또는 기존 프로젝트 내에서
mkdir sampler-test && cd sampler-test
```

## 2. 시스템 리소스 모니터링

### 기본 시스템 모니터링 설정

첫 번째로 CPU, 메모리, 디스크 사용량을 실시간으로 모니터링하는 설정을 만들어보겠습니다.

`system-monitor.yml` 파일을 생성하세요:

```yaml
variables:
  refresh_rate: 1000

sparklines:
  - title: CPU Usage (%)
    rate-ms: 1000
    scale: 0
    sample: ps -A -o %cpu | awk '{s+=$1} END {print s}'

  - title: Memory Usage (%)
    rate-ms: 1000
    scale: 0
    sample: ps -A -o %mem | awk '{s+=$1} END {print s}'

  - title: Disk Usage (GB)
    rate-ms: 5000
    scale: 0
    sample: df -h / | awk 'NR==2 {print $3}' | sed 's/Gi//'

barcharts:
  - title: Top Processes by CPU
    rate-ms: 3000
    items:
      - label: Process 1
        sample: ps aux --sort=-%cpu | awk 'NR==2 {print $3}'
      - label: Process 2
        sample: ps aux --sort=-%cpu | awk 'NR==3 {print $3}'
      - label: Process 3
        sample: ps aux --sort=-%cpu | awk 'NR==4 {print $3}'
      - label: Process 4
        sample: ps aux --sort=-%cpu | awk 'NR==5 {print $3}'
      - label: Process 5
        sample: ps aux --sort=-%cpu | awk 'NR==6 {print $3}'

runcharts:
  - title: Network Activity (KB/s)
    rate-ms: 2000
    scale: 0
    items:
      - label: RX
        sample: netstat -ib | awk 'FNR==2 {print $7/1024}'
      - label: TX
        sample: netstat -ib | awk 'FNR==2 {print $10/1024}'

textboxes:
  - title: System Information
    rate-ms: 5000
    sample: |
      echo "Hostname: $(hostname)"
      echo "Uptime: $(uptime | awk -F'up ' '{print $2}' | awk -F', load' '{print $1}')"
      echo "Load Average: $(uptime | awk -F'load averages: ' '{print $2}')"
      echo "Users: $(who | wc -l | tr -d ' ')"
      echo "Processes: $(ps aux | wc -l | tr -d ' ')"
```

### 실행 및 테스트

```bash
# 시스템 모니터링 실행
sampler -c system-monitor.yml
```

**Sampler 화면 구성 요소:**
- **Sparklines**: 시간에 따른 데이터 변화를 작은 그래프로 표시
- **Barcharts**: 여러 항목을 막대 그래프로 비교
- **Runcharts**: 실시간 라인 차트
- **Textboxes**: 텍스트 정보 표시

## 3. 웹사이트 상태 모니터링

웹사이트의 응답 시간과 상태를 모니터링하는 설정을 만들어보겠습니다.

### 웹 모니터링 설정

`web-monitor.yml` 파일을 생성하세요:

```yaml
variables:
  google_url: https://www.google.com
  github_url: https://github.com
  stackoverflow_url: https://stackoverflow.com

runcharts:
  - title: Website Response Time (seconds)
    rate-ms: 3000
    scale: 0
    items:
      - label: Google
        sample: curl -o /dev/null -s -w '%{time_total}' $google_url
        color: 178
      - label: GitHub
        sample: curl -o /dev/null -s -w '%{time_total}' $github_url
        color: 85
      - label: StackOverflow
        sample: curl -o /dev/null -s -w '%{time_total}' $stackoverflow_url
        color: 202
    triggers:
      - title: High latency alert
        condition: echo "$cur > 2.0" | bc -l
        actions:
          terminal-bell: true
          sound: true
          visual: true
          script: 'echo "Alert: High latency detected for $label - $cur s"'

barcharts:
  - title: HTTP Status Codes
    rate-ms: 5000
    items:
      - label: Google (200)
        sample: curl -o /dev/null -s -w '%{http_code}' $google_url | grep -c "200" || echo "0"
      - label: GitHub (200)
        sample: curl -o /dev/null -s -w '%{http_code}' $github_url | grep -c "200" || echo "0"
      - label: StackOverflow (200)
        sample: curl -o /dev/null -s -w '%{http_code}' $stackoverflow_url | grep -c "200" || echo "0"

sparklines:
  - title: DNS Resolution Time (ms)
    rate-ms: 2000
    scale: 0
    sample: dig +stats google.com | grep "Query time:" | awk '{print $4}'

textboxes:
  - title: Website Health Check
    rate-ms: 10000
    sample: |
      echo "=== Website Health Status ==="
      echo "Google: $(curl -o /dev/null -s -w 'Status: %{http_code}, Time: %{time_total}s' $google_url)"
      echo "GitHub: $(curl -o /dev/null -s -w 'Status: %{http_code}, Time: %{time_total}s' $github_url)"
      echo "StackOverflow: $(curl -o /dev/null -s -w 'Status: %{http_code}, Time: %{time_total}s' $stackoverflow_url)"
      echo "=== DNS Info ==="
      echo "Google DNS: $(dig +short google.com | head -1)"
      echo "Local DNS: $(scutil --dns | grep 'nameserver\[0\]' | head -1 | awk '{print $3}')"
```

### 알림 기능 (Triggers)

**Triggers 설정의 핵심 요소:**
- `condition`: 알림 조건 (bash 스크립트로 "1" 반환시 트리거)
- `terminal-bell`: 터미널 벨 소리
- `sound`: NASA quindar 톤
- `visual`: 시각적 알림
- `script`: 사용자 정의 스크립트 실행

### 실행 테스트

```bash
# 웹 모니터링 실행
sampler -c web-monitor.yml
```

**실제 테스트 결과:**
DNS Resolution Time과 Website Response Time이 실시간으로 업데이트되는 것을 확인했습니다.

## 4. 개발환경 Git 활동 모니터링

Git 리포지토리의 활동을 추적하는 개발자 친화적인 모니터링을 설정해보겠습니다.

### 개발 모니터링 설정

`development-monitor.yml` 파일을 생성하세요:

```yaml
variables:
  project_dir: ~/work/thakicloud/thakicloud.github.io

sparklines:
  - title: Git Commits per Day
    rate-ms: 5000
    scale: 0
    sample: cd $project_dir && git log --since="1 day ago" --oneline | wc -l | tr -d ' '

  - title: Code Lines Changed Today
    rate-ms: 10000
    scale: 0
    sample: cd $project_dir && git log --since="1 day ago" --numstat | awk '{add+=$1; del+=$2} END {print add+del}'

barcharts:
  - title: File Types in Project
    rate-ms: 15000
    items:
      - label: Markdown (.md)
        sample: cd $project_dir && find . -name "*.md" | wc -l | tr -d ' '
      - label: YAML (.yml)
        sample: cd $project_dir && find . -name "*.yml" | wc -l | tr -d ' '
      - label: JavaScript (.js)
        sample: cd $project_dir && find . -name "*.js" | wc -l | tr -d ' '
      - label: Python (.py)
        sample: cd $project_dir && find . -name "*.py" | wc -l | tr -d ' '
      - label: Shell (.sh)
        sample: cd $project_dir && find . -name "*.sh" | wc -l | tr -d ' '

runcharts:
  - title: Development Activity (Files Modified)
    rate-ms: 5000
    scale: 0
    items:
      - label: Modified Files
        sample: cd $project_dir && git status --porcelain | wc -l | tr -d ' '
        color: 178
      - label: Staged Files
        sample: cd $project_dir && git diff --cached --name-only | wc -l | tr -d ' '
        color: 85

textboxes:
  - title: Project Statistics
    rate-ms: 20000
    sample: |
      cd $project_dir
      echo "=== Repository Info ==="
      echo "Current Branch: $(git branch --show-current)"
      echo "Last Commit: $(git log -1 --format='%h - %s (%cr)')"
      echo "Total Commits: $(git rev-list --count HEAD)"
      echo "Contributors: $(git log --format='%an' | sort -u | wc -l | tr -d ' ')"
      echo ""
      echo "=== File Statistics ==="
      echo "Total Files: $(find . -type f | wc -l | tr -d ' ')"
      echo "Blog Posts: $(find ./_posts -name "*.md" | wc -l | tr -d ' ')"
      echo "Tutorials: $(find ./_posts/tutorials -name "*.md" | wc -l | tr -d ' ')"
      echo ""
      echo "=== Recent Activity ==="
      echo "Files changed today: $(git log --since='1 day ago' --name-only --pretty=format: | sort | uniq | wc -l | tr -d ' ')"

  - title: Git Status
    rate-ms: 3000
    sample: cd $project_dir && git status --short
```

### 개발자를 위한 유용한 메트릭

1. **Commit 활동**: 일일 커밋 수 추적
2. **코드 변경량**: 추가/삭제된 라인 수
3. **파일 타입 분포**: 프로젝트 구성 파악
4. **실시간 Git 상태**: 수정된 파일, 스테이징된 파일
5. **프로젝트 통계**: 커밋 수, 기여자 수, 파일 수

## 5. Docker 컨테이너 모니터링

Docker 환경에서 컨테이너 상태와 리소스 사용량을 모니터링하는 설정입니다.

### Docker 모니터링 설정

`docker-monitor.yml` 파일을 생성하세요:

```yaml
sparklines:
  - title: Running Containers
    rate-ms: 3000
    scale: 0
    sample: docker ps -q | wc -l | tr -d ' '

  - title: Total Images
    rate-ms: 5000
    scale: 0
    sample: docker images -q | wc -l | tr -d ' '

barcharts:
  - title: Container Status
    rate-ms: 5000
    items:
      - label: Running
        sample: docker ps --filter "status=running" -q | wc -l | tr -d ' '
      - label: Stopped
        sample: docker ps --filter "status=exited" -a -q | wc -l | tr -d ' '
      - label: Paused
        sample: docker ps --filter "status=paused" -q | wc -l | tr -d ' '

runcharts:
  - title: Docker System Usage
    rate-ms: 3000
    scale: 0
    items:
      - label: CPU Usage (%)
        sample: docker stats --no-stream --format "{{.CPUPerc}}" | head -1 | sed 's/%//' || echo "0"
        color: 178
      - label: Memory Usage (%)
        sample: docker stats --no-stream --format "{{.MemPerc}}" | head -1 | sed 's/%//' || echo "0"
        color: 85

textboxes:
  - title: Docker System Info
    rate-ms: 10000
    sample: |
      echo "=== Docker Version ==="
      docker --version
      echo ""
      echo "=== System Info ==="
      docker system df --format "table {{.Type}}\t{{.Total}}\t{{.Active}}\t{{.Size}}"
      echo ""
      echo "=== Running Containers ==="
      docker ps --format "table {{.Names}}\t{{.Status}}\t{{.Ports}}" | head -10

  - title: Container Resource Usage
    rate-ms: 5000
    sample: |
      echo "=== Container Stats ==="
      docker stats --no-stream --format "table {{.Name}}\t{{.CPUPerc}}\t{{.MemPerc}}\t{{.NetIO}}" | head -5 || echo "No containers running"
```

## 6. 실무 활용을 위한 스크립트 및 Alias 설정

### 자동화 스크립트 작성

편리한 사용을 위한 alias 설정 스크립트를 만들어보겠습니다.

`setup-sampler-aliases.sh` 파일을 생성하세요:

```bash
#!/bin/bash

# Sampler Aliases Setup Script
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "🔧 Setting up Sampler aliases..."

# Add aliases to zshrc
cat >> ~/.zshrc << 'EOF'

# ==========================================
# Sampler Monitoring Aliases
# ==========================================

# Basic Sampler commands
alias sampler-system="sampler -c $HOME/sampler-configs/system-monitor.yml"
alias sampler-web="sampler -c $HOME/sampler-configs/web-monitor.yml"
alias sampler-dev="sampler -c $HOME/sampler-configs/development-monitor.yml"
alias sampler-docker="sampler -c $HOME/sampler-configs/docker-monitor.yml"

# Quick monitoring shortcuts
alias monitor-sys="sampler-system"
alias monitor-web="sampler-web"
alias monitor-dev="sampler-dev"
alias monitor-docker="sampler-docker"

# Sampler config directory
alias sampler-configs="cd $HOME/sampler-configs"

# System monitoring shortcuts
alias cpu-monitor="ps -A -o %cpu | awk '{s+=\$1} END {print s}'"
alias mem-monitor="ps -A -o %mem | awk '{s+=\$1} END {print s}'"
alias disk-monitor="df -h / | awk 'NR==2 {print \$3}'"

# Web monitoring shortcuts
alias web-ping="curl -o /dev/null -s -w 'Status: %{http_code}, Time: %{time_total}s'"
alias google-ping="web-ping https://www.google.com"
alias github-ping="web-ping https://github.com"

# Development monitoring shortcuts
alias git-activity="git log --since='1 day ago' --oneline | wc -l"
alias project-stats="find . -type f | wc -l"
alias commit-today="git log --since='today' --oneline"

EOF

echo "✅ Sampler aliases added to ~/.zshrc"
echo "🔄 Run 'source ~/.zshrc' to load the new aliases"
```

### 실행 권한 부여 및 설정

```bash
# 실행 권한 부여
chmod +x setup-sampler-aliases.sh

# 스크립트 실행
./setup-sampler-aliases.sh

# zshrc 재로드
source ~/.zshrc
```

### 설정된 Alias 사용법

```bash
# 시스템 모니터링 시작
monitor-sys

# 웹사이트 모니터링 시작
monitor-web

# 개발환경 모니터링 시작
monitor-dev

# Docker 모니터링 시작
monitor-docker

# 설정 디렉토리로 이동
sampler-configs

# 개별 명령어
cpu-monitor      # 현재 CPU 사용률
mem-monitor      # 현재 메모리 사용률
google-ping      # Google 응답 시간 측정
git-activity     # 오늘 커밋 수
```

## 7. 고급 기능 및 실무 팁

### 변수 활용

YAML 설정에서 변수를 활용하여 중복을 줄이고 유지보수성을 높일 수 있습니다:

```yaml
variables:
  refresh_rate: 1000
  project_path: ~/my-project
  db_host: localhost:5432

sparklines:
  - title: Project Activity
    rate-ms: $refresh_rate
    sample: cd $project_path && git status --porcelain | wc -l
```

### 다중 단계 초기화

데이터베이스나 원격 서버 연결이 필요한 경우:

```yaml
textboxes:
  - title: Database Query
    multistep-init:
      - psql -h localhost -U user -d mydb
      - \timing on
    sample: SELECT COUNT(*) FROM users WHERE created_at > NOW() - INTERVAL '1 day';
```

### PTY 모드 활용

일부 대화형 도구는 PTY 모드가 필요합니다:

```yaml
textboxes:
  - title: Remote Server Monitoring
    pty: true
    init: ssh user@server.com
    sample: top -n 1 | head -5
```

### 색상 및 테마 커스터마이징

```yaml
theme: light  # 라이트 테마 사용

runcharts:
  - title: Network Traffic
    items:
      - label: Download
        sample: echo $((RANDOM % 100))
        color: 85    # 사용자 정의 색상
      - label: Upload
        sample: echo $((RANDOM % 50))
        color: 202
```

## 8. 문제 해결 및 디버깅

### 일반적인 문제와 해결방법

**1. YAML 문법 오류**
```bash
# YAML 유효성 검증
yamllint your-config.yml

# Sampler로 설정 확인
sampler -c your-config.yml --validate
```

**2. 명령어 실행 오류**
```bash
# 명령어를 직접 터미널에서 테스트
ps -A -o %cpu | awk '{s+=$1} END {print s}'

# 결과가 숫자가 아닌 경우 파싱 수정
```

**3. 권한 문제**
```bash
# Docker 명령어 권한 오류 시
sudo usermod -aG docker $USER
newgrp docker
```

**4. 성능 최적화**
- `rate-ms` 값을 적절히 조정 (너무 빈번한 업데이트는 CPU 사용량 증가)
- 복잡한 명령어는 더 긴 간격으로 실행
- 텍스트박스의 출력량 제한

### 개발환경별 주의사항

**macOS 특화 설정:**
```yaml
# macOS의 ps 명령어는 리눅스와 다름
sample: ps -A -o %cpu | awk '{s+=$1} END {print s}'  # macOS
sample: ps aux --sort=-%cpu | awk 'NR==2 {print $3}'  # Linux
```

**네트워크 도구 확인:**
```bash
# 필요한 도구들이 설치되어 있는지 확인
which curl dig netstat
brew install bind  # dig 명령어 설치 (macOS)
```

## 9. 실무 활용 사례

### DevOps 팀의 실시간 모니터링

```yaml
# production-monitor.yml
variables:
  api_endpoint: https://api.yourservice.com/health
  database_host: prod-db.yourcompany.com

runcharts:
  - title: Service Health
    rate-ms: 5000
    items:
      - label: API Response Time
        sample: curl -o /dev/null -s -w '%{time_total}' $api_endpoint
      - label: Database Connections
        sample: netstat -an | grep :5432 | grep ESTABLISHED | wc -l
    triggers:
      - title: Service Down Alert
        condition: echo "$cur > 5.0" | bc -l
        actions:
          terminal-bell: true
          script: 'slack-cli send "#alerts" "🚨 API response time exceeded 5s: ${cur}s"'

textboxes:
  - title: Error Logs
    rate-ms: 10000
    sample: tail -10 /var/log/application/error.log | grep ERROR | wc -l
```

### 블로그 운영자의 컨텐츠 모니터링

```yaml
# blog-monitor.yml
variables:
  blog_dir: ~/my-blog

sparklines:
  - title: Daily Posts
    rate-ms: 60000  # 1분마다 업데이트
    sample: cd $blog_dir && find ./_posts -name "$(date +%Y-%m-%d)*.md" | wc -l

barcharts:
  - title: Content by Category
    rate-ms: 300000  # 5분마다 업데이트
    items:
      - label: Tutorials
        sample: cd $blog_dir && find ./_posts/tutorials -name "*.md" | wc -l
      - label: Reviews
        sample: cd $blog_dir && find ./_posts/reviews -name "*.md" | wc -l
      - label: News
        sample: cd $blog_dir && find ./_posts/news -name "*.md" | wc -l

textboxes:
  - title: Writing Progress
    rate-ms: 30000
    sample: |
      cd $blog_dir
      echo "=== Today's Writing ==="
      echo "Words written: $(find ./_posts -name "$(date +%Y-%m-%d)*.md" -exec wc -w {} \; | awk '{sum+=$1} END {print sum}')"
      echo "Files modified: $(git status --porcelain | wc -l)"
      echo "Drafts: $(find ./_drafts -name "*.md" | wc -l 2>/dev/null || echo 0)"
```

## 10. 성능 및 보안 고려사항

### 성능 최적화

**리소스 사용량 관리:**
```yaml
# CPU 집약적인 명령어는 긴 간격으로
- title: Heavy Computation
  rate-ms: 30000  # 30초마다
  sample: find / -name "*.log" 2>/dev/null | wc -l

# 가벼운 명령어는 자주 업데이트
- title: Simple Check
  rate-ms: 1000   # 1초마다
  sample: date +%s
```

**메모리 효율성:**
```yaml
# 출력량이 많은 명령어는 제한
sample: docker ps | head -10  # 상위 10개만
sample: tail -20 /var/log/app.log  # 최근 20줄만
```

### 보안 고려사항

**민감한 정보 처리:**
```yaml
# 환경변수 활용
variables:
  db_password: $DB_PASSWORD  # 하드코딩 금지

# 출력에서 민감한 정보 제거
sample: ps aux | grep mysql | grep -v grep | awk '{print $1,$2,$11}'  # PID와 프로세스명만
```

**원격 접근 보안:**
```yaml
# SSH 키 기반 인증 사용
init: ssh -i ~/.ssh/monitor_key user@server
sample: systemctl status nginx
```

## 결론

Sampler는 복잡한 모니터링 시스템 없이도 터미널에서 강력한 실시간 대시보드를 구축할 수 있게 해주는 훌륭한 도구입니다. 이 튜토리얼에서 다룬 내용들을 바탕으로:

### 핵심 장점

1. **간단한 설정**: YAML 파일만으로 복잡한 모니터링 구성
2. **실시간 시각화**: 다양한 차트와 그래프로 데이터 표현
3. **알림 기능**: 임계값 기반 자동 알림
4. **확장성**: 모든 셸 명령어를 활용 가능
5. **경량성**: 별도 서버나 데이터베이스 불필요

### 다음 단계

1. **커스터마이징**: 자신의 환경에 맞는 설정 파일 작성
2. **자동화**: CI/CD 파이프라인에 모니터링 통합
3. **알림 확장**: Slack, Discord 등과 연동
4. **성능 튜닝**: 리소스 사용량 최적화

### 실무 활용 팁

- 팀별로 표준 설정 템플릿 공유
- Git으로 설정 파일 버전 관리
- 프로덕션 환경용 별도 설정 분리
- 정기적인 모니터링 설정 리뷰

**개발환경 정보:**
- **테스트 환경**: macOS Sequoia (darwin 25.0.0)
- **Sampler 버전**: 1.1.0
- **설치 방법**: HomeBrew
- **Shell**: Zsh

Sampler를 통해 개발 생산성을 높이고, 시스템 상태를 실시간으로 파악하여 더 나은 개발 환경을 구축해보세요. 단순한 YAML 설정으로 시작해서 점진적으로 고도화해나가면, 어느새 전문적인 모니터링 시스템을 갖추게 될 것입니다.

---

**관련 링크:**
- [Sampler GitHub Repository](https://github.com/sqshq/sampler)
- [공식 문서](https://sampler.dev)
- [YAML 문법 가이드](https://yaml.org/spec/1.2/spec.html)
