---
title: "Claude Relay Service 완전 설치 가이드 - 자건 Claude API 미러링 서비스 구축"
excerpt: "Claude 계정 차단 걱정 없이 안전하게 Claude API를 사용할 수 있는 자체 중계 서비스를 구축하는 완전한 가이드입니다. 다중 계정 관리, OpenAI 호환 API, OAuth 인증까지 모든 기능을 단계별로 설명합니다."
seo_title: "Claude Relay Service 설치 튜토리얼 - 자체 Claude API 중계 서비스 구축 가이드 - Thaki Cloud"
seo_description: "Claude 계정 차단 걱정 없는 자체 Claude API 중계 서비스 구축 완전 가이드. 다중 계정 관리, OpenAI 호환, OAuth 인증, 클라이언트 제한 기능까지 상세한 설치와 설정 방법을 제공합니다."
date: 2025-08-01
last_modified_at: 2025-08-01
categories:
  - tutorials
  - ai-tools
tags:
  - Claude-API
  - Claude-Relay-Service
  - Self-Hosted
  - API-Gateway
  - OAuth-Authentication
  - Multi-Account
  - OpenAI-Compatible
  - Node.js
  - Redis
  - Caddy
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/claude-relay-service-complete-setup-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 19분

## 서론: Claude Relay Service가 필요한 이유

Claude를 개발 작업에 활용하다 보면 계정 차단이나 API 제한으로 인한 문제를 경험한 적이 있을 것입니다. [Claude Relay Service](https://github.com/Wei-Shaw/claude-relay-service)는 이러한 문제를 해결하기 위한 자체 호스팅 솔루션으로, Claude API를 안전하고 효율적으로 사용할 수 있도록 도와줍니다.

### Claude Relay Service의 핵심 기능

**계정 관리 및 보안**:
- 🔄 **다중 계정 전환**: 여러 Claude 계정을 자동으로 로드밸런싱
- 🛡️ **계정 차단 회피**: 효과적인 요청 분산으로 계정 보호
- 🔐 **OAuth 통합**: 브라우저를 통한 간편한 계정 추가
- 🚫 **클라이언트 제한**: API 키별 사용 가능한 클라이언트 제어

**API 호환성**:
- 🔗 **Claude API 네이티브**: 원본 Claude API와 완전 호환
- 🤖 **OpenAI 호환 모드**: 기존 OpenAI 도구들과 즉시 연동
- 📊 **사용량 모니터링**: 실시간 사용 통계 및 제한 관리
- 🌐 **웹 인터페이스**: 직관적인 계정 및 API 키 관리

### 이 가이드에서 배울 내용

1. **시스템 요구사항과 사전 준비**
2. **Redis 설치 및 설정**
3. **Claude Relay Service 설치 및 기본 설정**
4. **OAuth 인증을 통한 Claude 계정 연동**
5. **API 키 생성 및 관리**
6. **Caddy를 이용한 HTTPS 프록시 설정**
7. **다양한 클라이언트와의 연동 방법**
8. **운영 및 모니터링**
9. **문제 해결 및 최적화**

## 시스템 요구사항 및 사전 준비

### 시스템 요구사항

**최소 요구사항**:
- **OS**: Ubuntu 20.04+ / CentOS 8+ / macOS 10.15+
- **CPU**: 1 Core (2 Core 권장)
- **메모리**: 1GB RAM (2GB 권장)
- **저장공간**: 5GB 여유 공간
- **네트워크**: 안정적인 인터넷 연결

**권장 요구사항** (프로덕션 환경):
- **CPU**: 2-4 Core
- **메모리**: 4GB RAM
- **저장공간**: 20GB SSD
- **대역폭**: 100Mbps+

### 필수 소프트웨어

**Node.js 18+ 설치**:

```bash
# Ubuntu/Debian
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt-get install -y nodejs

# CentOS/RHEL
curl -fsSL https://rpm.nodesource.com/setup_18.x | sudo bash -
sudo dnf install -y nodejs npm

# macOS (Homebrew)
brew install node@18
brew link --force node@18
```

**Git 설치**:

```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y git

# CentOS/RHEL
sudo dnf install -y git

# macOS
xcode-select --install
```

**방화벽 설정**:

```bash
# Ubuntu/Debian (UFW)
sudo ufw allow 22/tcp     # SSH
sudo ufw allow 80/tcp     # HTTP
sudo ufw allow 443/tcp    # HTTPS
sudo ufw allow 3000/tcp   # 개발용 (선택적)
sudo ufw enable

# CentOS/RHEL (firewalld)
sudo firewall-cmd --permanent --add-service=ssh
sudo firewall-cmd --permanent --add-service=http
sudo firewall-cmd --permanent --add-service=https
sudo firewall-cmd --permanent --add-port=3000/tcp  # 개발용
sudo firewall-cmd --reload
```

## Redis 설치 및 설정

Claude Relay Service는 계정 정보와 세션 관리를 위해 Redis를 사용합니다.

### Redis 설치

**Ubuntu/Debian**:

```bash
# Redis 설치
sudo apt update
sudo apt install -y redis-server

# Redis 서비스 시작 및 활성화
sudo systemctl start redis-server
sudo systemctl enable redis-server

# 설치 확인
redis-cli ping
# 응답: PONG
```

**CentOS/RHEL**:

```bash
# EPEL 저장소 활성화
sudo dnf install -y epel-release

# Redis 설치
sudo dnf install -y redis

# Redis 서비스 시작 및 활성화
sudo systemctl start redis
sudo systemctl enable redis

# 설치 확인
redis-cli ping
```

**macOS**:

```bash
# Homebrew로 설치
brew install redis

# Redis 서비스 시작
brew services start redis

# 설치 확인
redis-cli ping
```

### Redis 보안 설정

```bash
# Redis 설정 파일 편집
sudo nano /etc/redis/redis.conf

# 또는 macOS의 경우
nano /usr/local/etc/redis.conf
```

**중요한 설정 변경사항**:

```conf
# 바인드 주소 (로컬만 허용)
bind 127.0.0.1

# 포트 (기본값 유지 또는 변경)
port 6379

# 패스워드 설정 (강력 권장)
requirepass your_strong_redis_password_here

# 메모리 제한 설정
maxmemory 256mb
maxmemory-policy allkeys-lru

# 로깅
loglevel notice
logfile /var/log/redis/redis-server.log
```

**Redis 재시작 및 테스트**:

```bash
# 서비스 재시작
sudo systemctl restart redis-server  # Ubuntu/Debian
sudo systemctl restart redis         # CentOS/RHEL

# 패스워드로 연결 테스트
redis-cli -a your_strong_redis_password_here ping
# 응답: PONG
```

## Claude Relay Service 설치 및 기본 설정

### 프로젝트 클론 및 설치

```bash
# 프로젝트 디렉토리 생성
mkdir -p ~/projects
cd ~/projects

# GitHub에서 클론
git clone https://github.com/Wei-Shaw/claude-relay-service.git
cd claude-relay-service

# 의존성 설치
npm install

# 전역 CLI 도구 설치 (선택적)
npm install -g pm2  # 프로덕션 환경용 프로세스 매니저
```

### 환경 설정 파일 구성

**기본 환경 변수 설정**:

```bash
# .env 파일 생성
cp .env.example .env
nano .env
```

**.env 파일 내용**:

```env
# 서버 설정
PORT=3000
HOST=0.0.0.0
NODE_ENV=production

# Redis 설정
REDIS_HOST=127.0.0.1
REDIS_PORT=6379
REDIS_PASSWORD=your_strong_redis_password_here
REDIS_DB=0

# 보안 설정
JWT_SECRET=your_jwt_secret_key_min_32_chars_long
ENCRYPT_KEY=your_encrypt_key_exactly_32_chars_
ADMIN_PASSWORD=your_admin_dashboard_password

# Claude OAuth 설정 (나중에 설정)
CLAUDE_OAUTH_CLIENT_ID=
CLAUDE_OAUTH_CLIENT_SECRET=
CLAUDE_OAUTH_REDIRECT_URI=http://localhost:3000/auth/claude/callback

# 로깅 설정
LOG_LEVEL=info
LOG_TO_FILE=true

# 기타 설정
MAX_CONCURRENT_REQUESTS=10
REQUEST_TIMEOUT=300000
```

**중요한 보안 키 생성**:

```bash
# JWT Secret 생성 (32자 이상)
node -e "console.log(require('crypto').randomBytes(32).toString('hex'))"

# Encrypt Key 생성 (정확히 32자)
node -e "console.log(require('crypto').randomBytes(16).toString('hex'))"
```

### 설정 파일 커스터마이징

**config/config.js 파일 편집**:

```bash
nano config/config.js
```

**주요 설정 옵션**:

```javascript
module.exports = {
  server: {
    port: process.env.PORT || 3000,
    host: process.env.HOST || '0.0.0.0',
    corsOrigins: ['*'], // 프로덕션에서는 구체적인 도메인 지정
  },
  
  redis: {
    host: process.env.REDIS_HOST || '127.0.0.1',
    port: parseInt(process.env.REDIS_PORT) || 6379,
    password: process.env.REDIS_PASSWORD,
    db: parseInt(process.env.REDIS_DB) || 0,
    retryDelayOnFailover: 100,
    maxRetriesPerRequest: 3,
  },
  
  claude: {
    baseUrl: 'https://api.anthropic.com',
    maxRetries: 3,
    retryDelay: 1000,
    timeout: 300000, // 5분
  },
  
  rateLimit: {
    enabled: true,
    windowMs: 60000, // 1분
    maxRequests: 100, // 분당 최대 요청 수
  },
  
  logging: {
    level: process.env.LOG_LEVEL || 'info',
    file: process.env.LOG_TO_FILE === 'true',
    directory: './logs',
  },
  
  // 클라이언트 제한 기능
  clientRestrictions: {
    enabled: true,
    predefinedClients: [
      {
        id: 'claude_code',
        name: 'Claude Code',
        description: 'Official Claude CLI',
        userAgentPattern: /^claude-cli\/[\d\.]+\s+\(external,\s+cli\)/i
      },
      {
        id: 'gemini_cli',
        name: 'Gemini CLI',
        description: 'Gemini Command Line Interface',
        userAgentPattern: /^GeminiCLI\/v[\d\.]+\s+\([^)]+\)/i
      }
    ]
  }
};
```

## OAuth 인증을 통한 Claude 계정 연동

### OAuth 애플리케이션 등록

Claude 계정을 자동으로 추가하려면 OAuth 인증이 필요합니다. 하지만 현재 Claude는 공개 OAuth를 지원하지 않으므로, 수동으로 계정을 추가해야 합니다.

### 수동 계정 추가 방법

**1. 서비스 시작**:

```bash
# 개발 모드로 시작
npm run dev

# 또는 프로덕션 모드
npm start
```

**2. 웹 인터페이스 접속**:

브라우저에서 `http://localhost:3000/web` 접속

**3. 관리자 로그인**:

- 패스워드: `.env` 파일의 `ADMIN_PASSWORD` 값 입력

**4. 계정 추가**:

- "계정 관리" → "새 계정 추가" 클릭
- Claude 계정 정보 입력:
  - **이메일**: Claude 계정 이메일
  - **세션 키**: Claude 웹사이트에서 추출한 세션 토큰
  - **계정 이름**: 식별용 이름 (예: "Main Account")

### 세션 키 추출 방법

**1. Claude 웹사이트 로그인**:

- https://claude.ai 접속 후 로그인

**2. 개발자 도구 열기**:

- F12 키 또는 우클릭 → "검사"

**3. 네트워크 탭에서 요청 확인**:

- Network 탭 클릭
- Claude와 대화 시작
- `/api/` 요청 찾기

**4. 헤더에서 세션 키 복사**:

```
Cookie: sessionKey=sk-ant-session-xxxxx...
```

**5. 서비스에 추가**:

- 웹 인터페이스에서 추출한 세션 키 입력

## API 키 생성 및 관리

### API 키 생성

**1. 웹 인터페이스에서 생성**:

- "API 키 관리" → "새 API 키 생성" 클릭
- 다음 정보 입력:
  - **키 이름**: 식별용 이름 (예: "Development Key")
  - **사용량 제한**: 월별 요청 수 제한 (선택적)
  - **만료일**: 키 만료 날짜 (선택적)
  - **클라이언트 제한**: 특정 클라이언트만 사용 가능 (선택적)

**2. CLI를 통한 생성**:

```bash
# CLI 도구 실행
npm run cli

# 대화형 메뉴에서 "API 키 생성" 선택
# 또는 직접 명령어
node cli/index.js create-api-key --name "My API Key" --limit 1000
```

### API 키 설정 옵션

**기본 설정**:

```javascript
{
  name: "Development Key",
  keyPrefix: "sk-relay-",
  monthlyLimit: 10000,      // 월 요청 제한
  dailyLimit: 1000,         // 일 요청 제한
  enabled: true,
  expiresAt: null,          // 만료일 (null = 무제한)
  clientRestrictions: [],   // 허용된 클라이언트 목록
  rateLimitOverride: {      // 개별 속도 제한
    windowMs: 60000,
    maxRequests: 100
  }
}
```

**클라이언트 제한 설정**:

```javascript
// Claude CLI만 허용
clientRestrictions: ['claude_code']

// 다중 클라이언트 허용
clientRestrictions: ['claude_code', 'gemini_cli']

// 제한 없음 (빈 배열)
clientRestrictions: []
```

### API 키 사용 예제

**cURL을 이용한 테스트**:

```bash
# Claude API 형식
curl -X POST http://localhost:3000/api/v1/messages \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-relay-xxxxxxxxxxxxxxxx" \
  -H "anthropic-version: 2023-06-01" \
  -d '{
    "model": "claude-3-sonnet-20240229",
    "max_tokens": 1000,
    "messages": [
      {
        "role": "user",
        "content": "Hello, how are you?"
      }
    ]
  }'

# OpenAI 호환 형식
curl -X POST http://localhost:3000/openai/claude/v1/chat/completions \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer sk-relay-xxxxxxxxxxxxxxxx" \
  -d '{
    "model": "claude-3-sonnet-20240229",
    "messages": [
      {
        "role": "user",
        "content": "Hello, how are you?"
      }
    ]
  }'
```

## Caddy를 이용한 HTTPS 프록시 설정

프로덕션 환경에서는 HTTPS와 도메인을 사용하는 것이 필수입니다. Caddy는 자동으로 SSL 인증서를 관리해주는 가장 쉬운 솔루션입니다.

### Caddy 설치

**Ubuntu/Debian**:

```bash
# 공식 저장소 추가
sudo apt install -y debian-keyring debian-archive-keyring apt-transport-https
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | sudo gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | sudo tee /etc/apt/sources.list.d/caddy-stable.list

# Caddy 설치
sudo apt update
sudo apt install caddy
```

**CentOS/RHEL/Fedora**:

```bash
# COPR 저장소 활성화
sudo dnf install 'dnf-command(copr)'
sudo dnf copr enable @caddy/caddy

# Caddy 설치
sudo dnf install caddy
```

### Caddy 설정

**Caddyfile 편집**:

```bash
sudo nano /etc/caddy/Caddyfile
```

**기본 설정** (도메인 변경 필요):

```caddyfile
# your-domain.com을 실제 도메인으로 변경
your-domain.com {
    # 메인 API 엔드포인트
    reverse_proxy 127.0.0.1:3000 {
        # 스트리밍 응답 지원 (SSE)
        flush_interval -1
        
        # 실제 클라이언트 IP 전달
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-Host {host}
        
        # 타임아웃 설정 (장시간 요청 대응)
        transport http {
            read_timeout 300s
            write_timeout 300s
            dial_timeout 30s
            keep_alive 30s
        }
    }
    
    # 보안 헤더 추가
    header {
        # HTTPS 강제
        Strict-Transport-Security "max-age=31536000; includeSubDomains; preload"
        
        # XSS 보호
        X-Content-Type-Options "nosniff"
        X-Frame-Options "DENY"
        X-XSS-Protection "1; mode=block"
        
        # 서버 정보 숨김
        -Server
        
        # 리퍼러 정책
        Referrer-Policy "strict-origin-when-cross-origin"
    }
    
    # 로그 설정
    log {
        output file /var/log/caddy/access.log {
            roll_size 100MB
            roll_keep 10
        }
        format console
    }
}

# 관리 인터페이스용 서브도메인 (선택적)
admin.your-domain.com {
    reverse_proxy 127.0.0.1:3000 {
        header_up X-Real-IP {remote_host}
        header_up X-Forwarded-For {remote_host}
        header_up X-Forwarded-Proto {scheme}
    }
    
    # 관리 페이지는 특정 경로로만 접근 허용
    handle /web* {
        reverse_proxy 127.0.0.1:3000
    }
    
    # 다른 모든 요청은 차단
    handle {
        respond "Forbidden" 403
    }
}
```

**고급 설정** (로드밸런싱 지원):

```caddyfile
your-domain.com {
    # 여러 인스턴스 로드밸런싱
    reverse_proxy {
        to 127.0.0.1:3000
        to 127.0.0.1:3001  # 추가 인스턴스
        to 127.0.0.1:3002  # 추가 인스턴스
        
        # 헬스체크
        health_uri /health
        health_interval 30s
        health_timeout 5s
        
        # 로드밸런싱 정책
        lb_policy round_robin
        
        # 실패한 백엔드 재시도
        fail_duration 30s
        max_fails 3
    }
    
    # 기타 설정 동일...
}
```

### Caddy 서비스 시작

```bash
# 설정 파일 문법 검사
sudo caddy validate --config /etc/caddy/Caddyfile

# Caddy 서비스 시작
sudo systemctl start caddy
sudo systemctl enable caddy

# 상태 확인
sudo systemctl status caddy

# 로그 확인
sudo journalctl -u caddy -f
```

### 서비스 설정 변경

Claude Relay Service가 로컬에서만 접근 가능하도록 설정:

```bash
nano config/config.js
```

```javascript
module.exports = {
  server: {
    port: 3000,
    host: '127.0.0.1',  // 로컬만 바인딩
    // ... 기타 설정
  }
}
```

## 다양한 클라이언트와의 연동 방법

### Claude CLI 연동

**Claude CLI 설치**:

```bash
# npm을 통한 설치
npm install -g @anthropic-ai/claude-cli

# 또는 직접 다운로드
curl -fsSL https://claude.ai/cli/install.sh | sh
```

**설정**:

```bash
# 환경 변수 설정
export ANTHROPIC_API_KEY="sk-relay-xxxxxxxxxxxxxxxx"
export ANTHROPIC_API_URL="https://your-domain.com/api"

# 또는 설정 파일 편집
claude config set api_key sk-relay-xxxxxxxxxxxxxxxx
claude config set api_url https://your-domain.com/api
```

**사용 예제**:

```bash
# 간단한 질문
claude "Hello, how are you?"

# 파일과 함께 질문
claude "Please review this code" --file script.js

# 대화 모드
claude chat
```

### Cherry Studio 연동

Cherry Studio는 OpenAI 호환 형식을 지원하는 GUI 클라이언트입니다.

**설정 방법**:

1. Cherry Studio 설치 및 실행
2. 설정 → API 설정
3. 다음 정보 입력:
   - **API URL**: `https://your-domain.com/openai/claude/v1/`
   - **API Key**: `sk-relay-xxxxxxxxxxxxxxxx`
   - **Model**: `claude-3-sonnet-20240229`

### Continue.dev (VS Code) 연동

**설정 파일 편집** (`~/.continue/config.json`):

```json
{
  "models": [
    {
      "title": "Claude via Relay",
      "provider": "anthropic",
      "model": "claude-3-sonnet-20240229",
      "apiKey": "sk-relay-xxxxxxxxxxxxxxxx",
      "apiBase": "https://your-domain.com/api"
    }
  ],
  "tabAutocompleteModel": {
    "title": "Claude Autocomplete",
    "provider": "anthropic",
    "model": "claude-3-haiku-20240307",
    "apiKey": "sk-relay-xxxxxxxxxxxxxxxx",
    "apiBase": "https://your-domain.com/api"
  }
}
```

### 커스텀 애플리케이션 연동

**Node.js 예제**:

```javascript
const fetch = require('node-fetch');

async function callClaudeRelay(message) {
  const response = await fetch('https://your-domain.com/api/v1/messages', {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer sk-relay-xxxxxxxxxxxxxxxx',
      'anthropic-version': '2023-06-01'
    },
    body: JSON.stringify({
      model: 'claude-3-sonnet-20240229',
      max_tokens: 1000,
      messages: [
        {
          role: 'user',
          content: message
        }
      ]
    })
  });
  
  const data = await response.json();
  return data.content[0].text;
}

// 사용 예제
callClaudeRelay('Hello, Claude!')
  .then(response => console.log(response))
  .catch(error => console.error(error));
```

**Python 예제**:

```python
import requests
import json

def call_claude_relay(message):
    url = "https://your-domain.com/api/v1/messages"
    
    headers = {
        "Content-Type": "application/json",
        "Authorization": "Bearer sk-relay-xxxxxxxxxxxxxxxx",
        "anthropic-version": "2023-06-01"
    }
    
    data = {
        "model": "claude-3-sonnet-20240229",
        "max_tokens": 1000,
        "messages": [
            {
                "role": "user",
                "content": message
            }
        ]
    }
    
    response = requests.post(url, headers=headers, json=data)
    return response.json()["content"][0]["text"]

# 사용 예제
result = call_claude_relay("Hello, Claude!")
print(result)
```

## 프로덕션 환경 운영

### PM2를 이용한 프로세스 관리

**PM2 설정 파일 생성** (`ecosystem.config.js`):

```javascript
module.exports = {
  apps: [
    {
      name: 'claude-relay-service',
      script: 'app.js',
      instances: 'max',  // CPU 코어 수만큼 인스턴스 생성
      exec_mode: 'cluster',
      env: {
        NODE_ENV: 'production',
        PORT: 3000
      },
      
      // 로그 설정
      log_file: './logs/combined.log',
      out_file: './logs/out.log',
      error_file: './logs/error.log',
      log_date_format: 'YYYY-MM-DD HH:mm:ss Z',
      
      // 자동 재시작 설정
      watch: false,  // 파일 변경 감지 비활성화 (프로덕션)
      ignore_watch: ['node_modules', 'logs'],
      max_memory_restart: '1G',
      
      // 클러스터 설정
      kill_timeout: 5000,
      wait_ready: true,
      listen_timeout: 10000,
    }
  ]
};
```

**PM2 명령어**:

```bash
# 애플리케이션 시작
pm2 start ecosystem.config.js

# 상태 확인
pm2 status
pm2 monit

# 로그 확인
pm2 logs claude-relay-service

# 재시작
pm2 restart claude-relay-service

# 중지
pm2 stop claude-relay-service

# 서버 부팅시 자동 시작 설정
pm2 startup
pm2 save
```

### 시스템 서비스 등록

**systemd 서비스 파일 생성**:

```bash
sudo nano /etc/systemd/system/claude-relay.service
```

```ini
[Unit]
Description=Claude Relay Service
After=network.target redis.service
Wants=redis.service

[Service]
Type=simple
User=www-data
Group=www-data
WorkingDirectory=/path/to/claude-relay-service
Environment=NODE_ENV=production
ExecStart=/usr/bin/node app.js
Restart=always
RestartSec=10

# 로그 설정
StandardOutput=journal
StandardError=journal
SyslogIdentifier=claude-relay

# 리소스 제한
LimitNOFILE=65536
MemoryLimit=2G

# 보안 설정
NoNewPrivileges=yes
PrivateTmp=yes
ProtectSystem=strict
ReadWritePaths=/path/to/claude-relay-service/logs

[Install]
WantedBy=multi-user.target
```

**서비스 활성화**:

```bash
# 서비스 파일 리로드
sudo systemctl daemon-reload

# 서비스 시작 및 활성화
sudo systemctl start claude-relay
sudo systemctl enable claude-relay

# 상태 확인
sudo systemctl status claude-relay

# 로그 확인
sudo journalctl -u claude-relay -f
```

### 모니터링 및 로깅

**로그 로테이션 설정**:

```bash
sudo nano /etc/logrotate.d/claude-relay
```

```
/path/to/claude-relay-service/logs/*.log {
    daily
    missingok
    rotate 30
    compress
    delaycompress
    notifempty
    create 0644 www-data www-data
    postrotate
        systemctl reload claude-relay
    endscript
}
```

**모니터링 스크립트 생성**:

```bash
nano monitor.sh
```

```bash
#!/bin/bash

# 서비스 상태 확인
check_service() {
    if systemctl is-active --quiet claude-relay; then
        echo "✅ Claude Relay Service is running"
    else
        echo "❌ Claude Relay Service is not running"
        # 자동 재시작 시도
        sudo systemctl start claude-relay
    fi
}

# Redis 상태 확인
check_redis() {
    if redis-cli -a "${REDIS_PASSWORD}" ping > /dev/null 2>&1; then
        echo "✅ Redis is running"
    else
        echo "❌ Redis is not running"
    fi
}

# 디스크 용량 확인
check_disk() {
    USAGE=$(df -h / | awk 'NR==2 {print $5}' | sed 's/%//')
    if [ $USAGE -gt 80 ]; then
        echo "⚠️  Disk usage is high: ${USAGE}%"
    else
        echo "✅ Disk usage is normal: ${USAGE}%"
    fi
}

# 메모리 사용량 확인
check_memory() {
    USAGE=$(free | grep Mem | awk '{printf "%.2f", $3/$2 * 100.0}')
    if (( $(echo "$USAGE > 80" | bc -l) )); then
        echo "⚠️  Memory usage is high: ${USAGE}%"
    else
        echo "✅ Memory usage is normal: ${USAGE}%"
    fi
}

# 모든 검사 실행
echo "=== Claude Relay Service Monitor ==="
echo "$(date)"
echo "-----------------------------------"
check_service
check_redis
check_disk
check_memory
echo "==================================="
```

**cron으로 정기 모니터링**:

```bash
# crontab 편집
crontab -e

# 5분마다 모니터링 실행
*/5 * * * * /path/to/monitor.sh >> /var/log/claude-relay-monitor.log 2>&1
```

## 문제 해결 및 최적화

### 일반적인 문제와 해결방법

**1. Redis 연결 실패**

```bash
# Redis 상태 확인
sudo systemctl status redis-server
redis-cli ping

# 설정 확인
grep -E "^(bind|port|requirepass)" /etc/redis/redis.conf

# 연결 테스트
redis-cli -h 127.0.0.1 -p 6379 -a your_password ping
```

**2. 세션 키 만료**

```
Error: Invalid session key or expired
```

**해결방법**:
- Claude 웹사이트에서 새 세션 키 추출
- 웹 인터페이스에서 계정 정보 업데이트

**3. API 키 인증 실패**

```
Error: Invalid API key
```

**해결방법**:
- API 키가 정확한지 확인
- API 키가 활성화되어 있는지 확인
- 클라이언트 제한 설정 확인

**4. 속도 제한 오류**

```
Error: Rate limit exceeded
```

**해결방법**:
- API 키별 속도 제한 증가
- 여러 계정으로 로드밸런싱
- 요청 간격 조정

### 성능 최적화

**1. Redis 최적화**:

```conf
# Redis 설정 (/etc/redis/redis.conf)
maxmemory 512mb
maxmemory-policy allkeys-lru
timeout 300
tcp-keepalive 60

# 저장 설정 (메모리 중심으로)
save ""
# 또는 최소한의 저장
save 3600 1 300 100 60 10000
```

**2. Node.js 최적화**:

```javascript
// config/config.js
module.exports = {
  server: {
    keepAliveTimeout: 30000,
    headersTimeout: 35000,
  },
  
  cluster: {
    enabled: true,
    instances: 'max', // CPU 코어 수
  },
  
  cache: {
    ttl: 3600, // 1시간
    maxSize: 1000, // 최대 캐시 항목
  }
}
```

**3. 로드밸런싱 최적화**:

```bash
# 여러 포트에서 인스턴스 실행
PORT=3000 npm start &
PORT=3001 npm start &
PORT=3002 npm start &
```

**Caddy 설정 업데이트**:

```caddyfile
your-domain.com {
    reverse_proxy {
        to 127.0.0.1:3000
        to 127.0.0.1:3001
        to 127.0.0.1:3002
        
        health_uri /health
        lb_policy least_conn
    }
}
```

### 보안 강화

**1. 방화벽 설정**:

```bash
# 필요한 포트만 개방
sudo ufw reset
sudo ufw default deny incoming
sudo ufw default allow outgoing
sudo ufw allow ssh
sudo ufw allow 80/tcp
sudo ufw allow 443/tcp
sudo ufw enable
```

**2. Fail2ban 설정**:

```bash
# Fail2ban 설치
sudo apt install fail2ban

# 설정 파일 생성
sudo nano /etc/fail2ban/jail.local
```

```ini
[DEFAULT]
bantime = 3600
findtime = 600
maxretry = 5

[claude-relay]
enabled = true
filter = claude-relay
logpath = /path/to/claude-relay-service/logs/error.log
maxretry = 3
bantime = 1800
```

**3. 환경 변수 보안**:

```bash
# .env 파일 권한 설정
chmod 600 .env
chown www-data:www-data .env

# 민감한 정보는 시스템 환경 변수로
echo 'export REDIS_PASSWORD="your_password"' >> /etc/environment
```

### 백업 및 복구

**1. 설정 백업**:

```bash
#!/bin/bash
# backup.sh

BACKUP_DIR="/backup/claude-relay/$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"

# 설정 파일 백업
cp .env "$BACKUP_DIR/"
cp config/config.js "$BACKUP_DIR/"
cp -r logs "$BACKUP_DIR/"

# Redis 백업
redis-cli -a "$REDIS_PASSWORD" --rdb "$BACKUP_DIR/redis.rdb"

# 압축
tar -czf "${BACKUP_DIR}.tar.gz" -C "/backup/claude-relay" "$(basename "$BACKUP_DIR")"
rm -rf "$BACKUP_DIR"

echo "Backup completed: ${BACKUP_DIR}.tar.gz"
```

**2. 복구 스크립트**:

```bash
#!/bin/bash
# restore.sh

BACKUP_FILE="$1"

if [ -z "$BACKUP_FILE" ]; then
    echo "Usage: $0 <backup_file.tar.gz>"
    exit 1
fi

# 서비스 중지
sudo systemctl stop claude-relay

# 백업 복원
tar -xzf "$BACKUP_FILE" -C /tmp/
BACKUP_DIR=$(tar -tzf "$BACKUP_FILE" | head -1 | cut -f1 -d"/")

# 설정 복원
cp "/tmp/$BACKUP_DIR/.env" ./
cp "/tmp/$BACKUP_DIR/config.js" config/

# Redis 데이터 복원
sudo systemctl stop redis-server
sudo cp "/tmp/$BACKUP_DIR/redis.rdb" /var/lib/redis/dump.rdb
sudo chown redis:redis /var/lib/redis/dump.rdb
sudo systemctl start redis-server

# 서비스 재시작
sudo systemctl start claude-relay

echo "Restore completed"
```

## 고급 기능 활용

### 계정 풀 자동 관리

**계정 상태 모니터링 스크립트**:

```javascript
// scripts/account-monitor.js
const Redis = require('ioredis');
const redis = new Redis(process.env.REDIS_URL);

async function checkAccountHealth() {
    const accounts = await redis.hgetall('claude:accounts');
    
    for (const [accountId, accountData] of Object.entries(accounts)) {
        const account = JSON.parse(accountData);
        
        try {
            // 계정 상태 체크 로직
            const isHealthy = await testAccountHealth(account);
            
            if (!isHealthy) {
                console.log(`⚠️  Account ${account.name} appears unhealthy`);
                // 알림 발송 또는 자동 비활성화
                await disableAccount(accountId);
            }
        } catch (error) {
            console.error(`❌ Error checking account ${account.name}:`, error);
        }
    }
}

// 5분마다 실행
setInterval(checkAccountHealth, 5 * 60 * 1000);
```

### 사용량 분석 및 리포팅

**일일 사용량 리포트 생성**:

```javascript
// scripts/usage-report.js
async function generateDailyReport() {
    const today = new Date().toISOString().split('T')[0];
    const stats = await redis.hgetall(`stats:${today}`);
    
    const report = {
        date: today,
        totalRequests: stats.total_requests || 0,
        totalTokens: stats.total_tokens || 0,
        uniqueUsers: stats.unique_users || 0,
        errorRate: (stats.errors / stats.total_requests * 100).toFixed(2),
        topModels: JSON.parse(stats.model_usage || '{}')
    };
    
    // 리포트 저장 또는 이메일 발송
    await saveReport(report);
    return report;
}
```

### 웹훅 통합

**사용량 알림 웹훅**:

```javascript
// config/webhooks.js
module.exports = {
    usage_alert: {
        url: 'https://discord.com/api/webhooks/...',
        threshold: 0.8, // 80% 사용량 시 알림
        events: ['monthly_limit', 'daily_limit', 'account_error']
    }
};
```

## 결론: Claude Relay Service 활용의 이점과 주의사항

### 도입 효과

**비용 절감**:
- 계정 차단으로 인한 업무 중단 방지
- 다중 계정 활용을 통한 사용량 최적화
- 기존 도구들과의 원활한 통합

**개발 효율성 향상**:
- 안정적인 Claude API 접근
- 팀 전체 사용량 중앙 관리
- 사용 패턴 분석을 통한 최적화

**보안 및 제어**:
- 자체 호스팅을 통한 데이터 보안
- 세밀한 접근 제어 및 모니터링
- 사용량 제한을 통한 비용 관리

### 주의사항

**라이선스 및 약관**:
- Claude 서비스 약관 준수 필요
- 상업적 사용 시 라이선스 확인
- 계정 공유에 대한 정책 검토

**기술적 고려사항**:
- 정기적인 보안 업데이트
- 백업 및 재해 복구 계획
- 확장성을 고려한 아키텍처 설계

**운영 관리**:
- 계정 상태 정기 모니터링
- 사용량 패턴 분석 및 최적화
- 사용자 교육 및 지원

### 다음 단계

1. **모니터링 강화**: Prometheus, Grafana 등을 활용한 고급 모니터링
2. **자동화 확장**: 계정 상태 자동 감지 및 대응
3. **성능 최적화**: 캐싱, 커넥션 풀링 등 성능 개선
4. **보안 강화**: 2FA, RBAC 등 추가 보안 기능

Claude Relay Service는 Claude API를 안전하고 효율적으로 활용할 수 있는 강력한 도구입니다. 이 가이드를 통해 구축한 시스템을 지속적으로 개선하고 모니터링하여 최적의 성능을 유지하시기 바랍니다.