---
title: "Umami Analytics GitHub Pages Jekyll 연동 완벽 가이드: 프라이버시 중심 웹사이트 분석"
excerpt: "GitHub Pages Jekyll 블로그에 Umami Analytics를 설정하여 프라이버시를 보호하면서 웹사이트 트래픽을 분석하는 완벽한 구현 가이드입니다."
seo_title: "Umami Analytics GitHub Pages Jekyll 설정 완벽 가이드 - Thaki Cloud"
seo_description: "GitHub Pages Jekyll 블로그에 Umami Analytics를 연동하는 단계별 가이드. 프라이버시 중심 웹 분석 툴 설정부터 실시간 모니터링까지 완벽 구현 방법을 제공합니다."
date: 2025-07-15
last_modified_at: 2025-07-15
categories:
  - tutorials
tags:
  - umami-analytics
  - github-pages
  - jekyll
  - web-analytics
  - privacy-focused
  - website-tracking
  - docker
  - postgresql
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/umami-analytics-github-pages-jekyll-setup-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 12분

## 서론

웹사이트 분석은 현대 웹 개발에서 필수적인 요소입니다. 하지만 Google Analytics 같은 전통적인 솔루션들은 사용자 프라이버시에 대한 우려를 불러일으키고 있습니다. **Umami Analytics**는 이러한 문제를 해결하는 현대적이고 프라이버시 중심의 대안입니다.

이 튜토리얼에서는 GitHub Pages Jekyll 블로그에 Umami Analytics를 완전히 설정하는 방법을 단계별로 안내합니다. macOS 환경에서 실제 테스트 가능한 예제와 함께 실무에서 바로 적용할 수 있는 구현 방법을 제공합니다.

### 왜 Umami Analytics인가?

- **🔒 프라이버시 중심**: GDPR 준수, 쿠키 불필요
- **🚀 경량화**: 최소한의 성능 영향
- **🎯 심플함**: 복잡한 설정 없이 바로 사용 가능
- **💰 오픈소스**: 무료 셀프 호스팅 지원
- **🌍 실시간**: 실시간 방문자 추적

## Umami Analytics 소개

### 핵심 특징

Umami는 다음과 같은 특징을 가진 웹 분석 도구입니다:

```yaml
핵심 기능:
  - 실시간 방문자 추적
  - 페이지뷰 및 세션 분석
  - 디바이스 및 브라우저 통계
  - 지역별 트래픽 분석
  - 맞춤 이벤트 추적
  - API 기반 데이터 접근

기술 스택:
  - Next.js (프론트엔드)
  - Node.js (백엔드)
  - PostgreSQL/MySQL (데이터베이스)
  - Docker (컨테이너화)
```

### 아키텍처 개요

```mermaid
graph TD
    A[Jekyll Blog] -->|Tracking Script| B[Umami Server]
    B --> C[PostgreSQL Database]
    B --> D[Umami Dashboard]
    D --> E[Analytics Reports]
    
    subgraph "GitHub Pages"
        A
    end
    
    subgraph "Self-hosted/Cloud"
        B
        C
        D
    end
```

## 사전 요구사항

### 시스템 요구사항

```bash
# macOS 개발 환경 확인
system_profiler SPSoftwareDataType | grep "System Version"
node --version  # v18.18+ 필요
docker --version  # Docker Desktop 설치 필요
git --version
```

### 필수 도구 설치

```bash
# Homebrew 설치 (없는 경우)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Node.js 설치
brew install node

# Docker Desktop 설치
brew install --cask docker

# 선택적: PostgreSQL 클라이언트
brew install postgresql
```

## Umami 서버 설정

### 1. Docker를 이용한 빠른 설정

가장 간단한 방법은 Docker Compose를 사용하는 것입니다:

```bash
# 작업 디렉토리 생성
mkdir ~/umami-analytics
cd ~/umami-analytics

# Docker Compose 파일 생성
cat > docker-compose.yml << 'EOF'
version: '3.8'

services:
  umami:
    image: ghcr.io/umami-software/umami:postgresql-latest
    ports:
      - "3000:3000"
    environment:
      DATABASE_URL: postgresql://umami:umami@db:5432/umami
      DATABASE_TYPE: postgresql
      HASH_SALT: your-secret-hash-salt-here
    depends_on:
      - db
    restart: always
    
  db:
    image: postgres:15-alpine
    environment:
      POSTGRES_DB: umami
      POSTGRES_USER: umami
      POSTGRES_PASSWORD: umami
    volumes:
      - umami-db-data:/var/lib/postgresql/data
    restart: always

volumes:
  umami-db-data:
EOF
```

### 2. Umami 서버 실행

```bash
# 컨테이너 시작
docker-compose up -d

# 실행 상태 확인
docker-compose ps

# 로그 확인
docker-compose logs -f umami
```

### 3. 초기 설정

```bash
# 브라우저에서 접속
open http://localhost:3000

# 기본 로그인 정보
# Username: admin
# Password: umami
```

### 4. 웹사이트 추가

Umami 대시보드에서:

1. **Settings** > **Websites** > **Add Website**
2. **Name**: `Thaki Cloud Blog`
3. **Domain**: `thakicloud.github.io`
4. **Save** 클릭

생성된 **Website ID**와 **Tracking Code**를 복사해 둡니다.

## Jekyll 블로그 연동

### 1. Analytics 설정 파일 수정

Jekyll `_config.yml` 파일에 Umami 설정을 추가합니다:

```yaml
# Analytics 설정
analytics:
  provider: "umami"
  umami:
    script_url: "http://localhost:3000/script.js"  # 프로덕션에서는 실제 도메인 사용
    website_id: "your-website-id-here"             # Umami에서 생성된 ID
```

### 2. Umami Analytics Provider 생성

`_includes/analytics-providers/umami.html` 파일을 생성합니다:

```html
{% if site.analytics.umami.script_url and site.analytics.umami.website_id %}
<!-- Umami Analytics -->
<script defer 
        src="{{ site.analytics.umami.script_url }}" 
        data-website-id="{{ site.analytics.umami.website_id }}"
        data-domains="{{ site.url | remove: 'https://' | remove: 'http://' }}">
</script>
{% endif %}
```

### 3. Analytics Include 파일 업데이트

`_includes/analytics.html` 파일에 Umami 케이스를 추가합니다:

```liquid
{% if jekyll.environment == 'production' and site.analytics.provider and page.analytics != false %}

{% case site.analytics.provider %}
{% when "google" %}
  {% include /analytics-providers/google.html %}
{% when "google-universal" %}
  {% include /analytics-providers/google-universal.html %}
{% when "google-gtag" %}
  {% include /analytics-providers/google-gtag.html %}
{% when "umami" %}
  {% include /analytics-providers/umami.html %}
{% when "custom" %}
  {% include /analytics-providers/custom.html %}
{% endcase %}

{% endif %}
```

## 로컬 테스트 및 검증

### 1. Jekyll 사이트 빌드

```bash
# 블로그 디렉토리로 이동
cd ~/your-jekyll-blog

# 의존성 설치
bundle install

# 프로덕션 모드로 빌드
JEKYLL_ENV=production bundle exec jekyll build

# 로컬 서버 실행
JEKYLL_ENV=production bundle exec jekyll serve --host 0.0.0.0 --port 4000
```

### 2. 트래킹 테스트

```bash
# 별도 터미널에서 트래킹 테스트
curl -H "User-Agent: Mozilla/5.0" http://localhost:4000/

# 여러 페이지 방문 시뮬레이션
for page in "/" "/categories/" "/about/"; do
  curl -H "User-Agent: Test-Browser" "http://localhost:4000$page"
  sleep 2
done
```

### 3. 실시간 분석 확인

```bash
# Umami 대시보드 접속
open http://localhost:3000

# 실시간 방문자 확인
# 페이지뷰 증가 확인
# 디바이스/브라우저 정보 확인
```

## 고급 설정 및 커스터마이징

### 1. 맞춤 이벤트 추적

블로그 포스트에 커스텀 이벤트를 추가할 수 있습니다:

```html
<!-- 다운로드 버튼 추적 -->
<button onclick="umami.track('download', {file: 'tutorial-guide.pdf'})">
  PDF 다운로드
</button>

<!-- 외부 링크 클릭 추적 -->
<a href="https://github.com/thakicloud" 
   onclick="umami.track('external-link', {destination: 'github'})">
  GitHub 방문
</a>
```

### 2. 환경별 설정

개발/스테이징/프로덕션 환경별로 다른 설정을 사용:

```yaml
# _config.yml
analytics:
  provider: "umami"
  umami:
    script_url: {% if jekyll.environment == 'production' %}"https://analytics.yourdomain.com/script.js"{% else %}"http://localhost:3000/script.js"{% endif %}
    website_id: {% if jekyll.environment == 'production' %}"prod-website-id"{% else %}"dev-website-id"{% endif %}
```

### 3. 프라이버시 설정 강화

```html
<!-- GDPR 준수를 위한 설정 -->
<script defer 
        src="{{ site.analytics.umami.script_url }}" 
        data-website-id="{{ site.analytics.umami.website_id }}"
        data-domains="{{ site.url | remove: 'https://' | remove: 'http://' }}"
        data-do-not-track="true"
        data-cache="true">
</script>
```

## 성능 최적화

### 1. 스크립트 로딩 최적화

```html
<!-- 비동기 로딩 -->
<script>
  (function() {
    var script = document.createElement('script');
    script.defer = true;
    script.src = '{{ site.analytics.umami.script_url }}';
    script.setAttribute('data-website-id', '{{ site.analytics.umami.website_id }}');
    document.head.appendChild(script);
  })();
</script>
```

### 2. CDN 사용

```yaml
# CDN을 통한 빠른 로딩
analytics:
  umami:
    script_url: "https://cdn.yourdomain.com/umami.js"
```

### 3. 캐싱 설정

```nginx
# Nginx 설정 예시
location /script.js {
    add_header Cache-Control "public, max-age=86400";
    expires 1d;
}
```

## 프로덕션 배포

### 1. 클라우드 배포 옵션

#### Vercel 배포

```bash
# Vercel CLI 설치
npm i -g vercel

# 프로젝트 배포
vercel --prod
```

#### Railway 배포

```bash
# Railway CLI 설치
npm install -g @railway/cli

# 프로젝트 배포
railway login
railway deploy
```

### 2. 환경 변수 설정

```bash
# 프로덕션 환경 변수
export DATABASE_URL="postgresql://user:pass@host:5432/umami"
export HASH_SALT="your-production-salt"
export HOSTNAME="analytics.yourdomain.com"
```

### 3. SSL 인증서 설정

```bash
# Let's Encrypt를 사용한 SSL 설정
certbot --nginx -d analytics.yourdomain.com
```

## 모니터링 및 백업

### 1. 시스템 모니터링

```bash
# Docker 컨테이너 상태 확인
docker-compose ps

# 리소스 사용량 확인
docker stats

# 로그 모니터링
docker-compose logs -f --tail=100
```

### 2. 데이터베이스 백업

```bash
# PostgreSQL 백업 스크립트
#!/bin/bash
DATE=$(date +%Y%m%d_%H%M%S)
docker exec umami-analytics_db_1 pg_dump -U umami umami > backup_$DATE.sql

# 자동 백업 cron 설정
echo "0 2 * * * /path/to/backup-script.sh" | crontab -
```

### 3. 업타임 모니터링

```bash
# 서비스 상태 확인 스크립트
#!/bin/bash
if ! curl -f http://localhost:3000/api/heartbeat; then
    echo "Umami service is down" | mail -s "Alert" admin@yourdomain.com
    docker-compose restart
fi
```

## 문제 해결

### 1. 일반적인 문제들

#### 트래킹이 작동하지 않는 경우

```bash
# 브라우저 개발자 도구에서 확인
# Network 탭에서 script.js 로딩 확인
# Console에서 JavaScript 오류 확인

# 서버 로그 확인
docker-compose logs umami | grep ERROR
```

#### 데이터베이스 연결 문제

```bash
# 데이터베이스 상태 확인
docker-compose exec db psql -U umami -d umami -c "\dt"

# 연결 테스트
docker-compose exec umami npm run check-db
```

### 2. 디버깅 도구

```javascript
// 브라우저 콘솔에서 Umami 상태 확인
console.log(window.umami);

// 이벤트 추적 테스트
umami.track('test-event', {test: true});
```

### 3. 로그 분석

```bash
# 접근 로그 분석
docker-compose logs umami | grep "POST /api/collect" | wc -l

# 오류 로그 필터링
docker-compose logs umami | grep -i error
```

## 보안 고려사항

### 1. 데이터베이스 보안

```yaml
# docker-compose.yml 보안 설정
services:
  db:
    environment:
      POSTGRES_PASSWORD: ${DB_PASSWORD}  # 환경 변수 사용
    networks:
      - internal  # 내부 네트워크 사용
```

### 2. 네트워크 보안

```bash
# 방화벽 설정
sudo ufw allow 22/tcp   # SSH
sudo ufw allow 80/tcp   # HTTP
sudo ufw allow 443/tcp  # HTTPS
sudo ufw deny 3000/tcp  # Umami 직접 접근 차단
```

### 3. 정기 보안 업데이트

```bash
# 정기 업데이트 스크립트
#!/bin/bash
docker-compose pull
docker-compose up -d
docker image prune -f
```

## 성능 벤치마킹

### 1. 로딩 시간 측정

```bash
# 스크립트 로딩 시간 테스트
curl -w "@curl-format.txt" -o /dev/null -s "http://localhost:3000/script.js"

# curl-format.txt 내용
     time_namelookup:  %{time_namelookup}\n
        time_connect:  %{time_connect}\n
     time_appconnect:  %{time_appconnect}\n
    time_pretransfer:  %{time_pretransfer}\n
       time_redirect:  %{time_redirect}\n
  time_starttransfer:  %{time_starttransfer}\n
                     ----------\n
          time_total:  %{time_total}\n
```

### 2. 트래픽 부하 테스트

```bash
# Apache Bench를 이용한 부하 테스트
ab -n 1000 -c 10 http://localhost:3000/api/collect

# 결과 분석
# Requests per second
# Time per request
# Transfer rate
```

## 실제 구현 예제

### 1. 완전한 설정 파일

```yaml
# _config.yml 완전 예제
analytics:
  provider: "umami"
  umami:
    script_url: "https://analytics.thakicloud.com/script.js"
    website_id: "01234567-89ab-cdef-0123-456789abcdef"
    
# 환경별 오버라이드
development:
  analytics:
    umami:
      script_url: "http://localhost:3000/script.js"
      website_id: "dev-website-id"
```

### 2. 고급 추적 구현

```html
<!-- _layouts/post.html에 추가 -->
<script>
document.addEventListener('DOMContentLoaded', function() {
  // 읽기 시간 추적
  var startTime = Date.now();
  
  window.addEventListener('beforeunload', function() {
    var readTime = Math.round((Date.now() - startTime) / 1000);
    if (readTime > 10) {  // 10초 이상 읽은 경우만
      umami.track('read-time', {
        post: '{{ page.title }}',
        category: '{{ page.categories[0] }}',
        duration: readTime
      });
    }
  });
  
  // 스크롤 깊이 추적
  var maxScroll = 0;
  window.addEventListener('scroll', function() {
    var scrollPercent = Math.round(
      (window.scrollY / (document.body.scrollHeight - window.innerHeight)) * 100
    );
    if (scrollPercent > maxScroll) {
      maxScroll = scrollPercent;
      if (maxScroll % 25 === 0) {  // 25%, 50%, 75%, 100%
        umami.track('scroll-depth', {
          post: '{{ page.title }}',
          depth: maxScroll
        });
      }
    }
  });
});
</script>
```

### 3. zshrc 편의 명령어

```bash
# ~/.zshrc에 추가할 Umami 관련 alias
alias umami-start="cd ~/umami-analytics && docker-compose up -d"
alias umami-stop="cd ~/umami-analytics && docker-compose down"
alias umami-logs="cd ~/umami-analytics && docker-compose logs -f umami"
alias umami-status="cd ~/umami-analytics && docker-compose ps"
alias umami-backup="cd ~/umami-analytics && docker exec umami-analytics_db_1 pg_dump -U umami umami > backup_$(date +%Y%m%d_%H%M%S).sql"

# Jekyll 빌드 및 테스트
alias jekyll-prod="JEKYLL_ENV=production bundle exec jekyll serve --host 0.0.0.0"
alias jekyll-check="bundle exec jekyll doctor && bundle exec jekyll build --verbose"

# Umami 연동 테스트
alias test-analytics="curl -H 'User-Agent: Test-Browser' http://localhost:4000/ && echo 'Analytics test sent'"

# 소스 적용 후 재로드
source ~/.zshrc
```

## 모니터링 대시보드

### 1. 실시간 모니터링 스크립트

```bash
#!/bin/bash
# monitor-umami.sh

echo "=== Umami Analytics 모니터링 대시보드 ==="
echo "시간: $(date)"
echo

# 서비스 상태
echo "🔧 서비스 상태:"
docker-compose ps

echo
echo "📊 실시간 통계:"
# API를 통한 실시간 데이터 조회 (인증 토큰 필요)
curl -s -H "Authorization: Bearer YOUR_API_TOKEN" \
  "http://localhost:3000/api/websites/YOUR_WEBSITE_ID/stats" | \
  jq '.pageviews.value, .visitors.value'

echo
echo "💾 디스크 사용량:"
docker system df

echo
echo "🔍 최근 로그 (마지막 10줄):"
docker-compose logs --tail=10 umami
```

### 2. 자동 리포트 생성

```python
#!/usr/bin/env python3
# generate-report.py

import requests
import json
from datetime import datetime, timedelta

def generate_weekly_report():
    """주간 분석 리포트 생성"""
    
    # API 설정
    base_url = "http://localhost:3000/api"
    headers = {"Authorization": "Bearer YOUR_API_TOKEN"}
    website_id = "YOUR_WEBSITE_ID"
    
    # 지난 주 데이터 조회
    end_date = datetime.now()
    start_date = end_date - timedelta(days=7)
    
    params = {
        "startAt": int(start_date.timestamp() * 1000),
        "endAt": int(end_date.timestamp() * 1000)
    }
    
    # 통계 데이터 수집
    stats = requests.get(
        f"{base_url}/websites/{website_id}/stats",
        headers=headers,
        params=params
    ).json()
    
    pageviews = requests.get(
        f"{base_url}/websites/{website_id}/pageviews",
        headers=headers,
        params=params
    ).json()
    
    # 리포트 생성
    report = f"""
# 📊 주간 분석 리포트
생성일: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
기간: {start_date.strftime('%Y-%m-%d')} ~ {end_date.strftime('%Y-%m-%d')}

## 주요 지표
- 총 페이지뷰: {stats.get('pageviews', {}).get('value', 0):,}
- 순방문자: {stats.get('visitors', {}).get('value', 0):,}
- 평균 세션 시간: {stats.get('totaltime', {}).get('value', 0) / stats.get('pageviews', {}).get('value', 1):.1f}초

## 인기 페이지
"""
    
    for page in pageviews.get('pageviews', [])[:10]:
        report += f"- {page['x']}: {page['y']:,}회\n"
    
    # 파일로 저장
    with open(f"report_{datetime.now().strftime('%Y%m%d')}.md", "w", encoding="utf-8") as f:
        f.write(report)
    
    print("리포트가 생성되었습니다!")

if __name__ == "__main__":
    generate_weekly_report()
```

## 결론

이 튜토리얼을 통해 GitHub Pages Jekyll 블로그에 Umami Analytics를 완전히 설정하는 방법을 배웠습니다. 주요 성과는 다음과 같습니다:

### ✅ 완료된 작업들

1. **🐳 Docker 기반 Umami 서버 구축**
   - PostgreSQL 데이터베이스 연동
   - 로컬 개발 환경 구성

2. **🔧 Jekyll 블로그 연동**
   - Analytics provider 설정
   - 환경별 구성 관리
   - 자동 스크립트 로딩

3. **📊 실시간 모니터링**
   - 방문자 추적 시스템
   - 커스텀 이벤트 구현
   - 성능 최적화

4. **🔒 보안 및 프라이버시**
   - GDPR 준수 설정
   - 데이터 보호 구현
   - 보안 강화 조치

### 🚀 다음 단계

1. **프로덕션 배포**: 클라우드 서비스를 통한 실제 배포
2. **고급 분석**: 맞춤 대시보드 및 리포트 구성
3. **자동화**: CI/CD 파이프라인 통합
4. **스케일링**: 트래픽 증가에 따른 인프라 확장

### 💡 핵심 혜택

- **프라이버시 보호**: 사용자 데이터 완전 통제
- **성능 최적화**: 최소한의 로딩 시간
- **비용 효율성**: 오픈소스 기반 무료 운영
- **커스터마이징**: 필요에 따른 기능 확장

Umami Analytics를 통해 웹사이트 분석의 새로운 패러다임을 경험해보세요. 프라이버시를 지키면서도 강력한 인사이트를 얻을 수 있는 현대적인 솔루션입니다.

---

### 관련 리소스

- [Umami 공식 문서](https://umami.is/docs)
- [GitHub 저장소](https://github.com/umami-software/umami)
- [Jekyll 공식 문서](https://jekyllrb.com/docs/)
- [Minimal Mistakes 테마](https://mmistakes.github.io/minimal-mistakes/)

### 문의 및 지원

질문이나 도움이 필요하시면 [GitHub Issues](https://github.com/thakicloud/thakicloud.github.io/issues)를 통해 연락해 주세요. 