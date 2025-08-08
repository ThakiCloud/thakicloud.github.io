---
title: "HubProxy 완전 가이드 - Docker와 GitHub 가속을 위한 고성능 프록시 서버 구축"
excerpt: "Go 기반의 오픈소스 HubProxy로 Docker 이미지 풀링과 GitHub 파일 다운로드 속도를 획기적으로 개선하는 방법을 배웁니다."
seo_title: "HubProxy 설치 및 구축 완전 가이드 - Docker GitHub 가속 프록시 - Thaki Cloud"
seo_description: "Go 언어로 구현된 HubProxy 프록시 서버 설치부터 운영까지, Docker 이미지와 GitHub 파일 다운로드 속도 개선을 위한 완전한 튜토리얼"
date: 2025-08-07
last_modified_at: 2025-08-07
categories:
  - tutorials
tags:
  - HubProxy
  - Docker
  - GitHub
  - Proxy
  - DevOps
  - Go
  - Registry
  - Acceleration
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/hubproxy-comprehensive-tutorial-docker-github-acceleration/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 25분

## 서론

개발자라면 누구나 경험하는 고충이 있습니다. 바로 **느린 Docker 이미지 다운로드**와 **GitHub 파일 접근 속도** 문제입니다. 특히 국내에서는 네트워크 제약으로 인해 이런 문제가 더욱 심각합니다.

**HubProxy**는 이러한 문제를 해결하기 위해 개발된 Go 언어 기반의 고성능 프록시 서버입니다. 단일 도메인으로 Docker Hub, GitHub Container Registry(GHCR), Quay.io 등 여러 레지스트리를 가속하고, GitHub 파일 다운로드까지 지원합니다.

이 글에서는 HubProxy의 **기술적 원리부터 실제 구축 방법까지** 완전히 다루겠습니다.

## HubProxy 개요

### 핵심 기능

HubProxy는 다음과 같은 강력한 기능들을 제공합니다:

- 🐳 **Docker 이미지 가속**: Docker Hub, GHCR, Quay.io, GCR, K8s.io 등 지원
- 📁 **GitHub 파일 가속**: Release 파일, Raw 파일, API 접근 가속
- 🤖 **AI 모델 라이브러리 지원**: Hugging Face 모델 다운로드 가속
- 📦 **오프라인 이미지 패키지**: 이미지를 tar 파일로 다운로드
- 🔍 **이미지 검색**: Docker 이미지 온라인 검색
- 🛡️ **지능형 보안**: IP 기반 레이트 리밋, 블랙리스트/화이트리스트
- ⚡ **고성능**: 스트리밍 전송, 메모리 효율적 설계

### 기술적 특징

- **언어**: Go (Golang)
- **아키텍처**: 단일 바이너리, 컨테이너 지원
- **프로토콜**: HTTP/2 지원, 스트리밍 전송
- **저장소**: 캐시 없음 (스트리밍 프록시)
- **메모리**: 초기 점유량 약 18MB
- **크기**: 바이너리 약 12MB

## 기술 스택 및 아키텍처

### 시스템 아키텍처

```mermaid
graph TB
    subgraph "클라이언트 계층"
        DC[Docker Client]
        GC[Git Client]
        WB[Web Browser]
        HC[HTTP Client]
    end
    
    subgraph "HubProxy 서버"
        subgraph "프록시 계층"
            RP[Reverse Proxy]
            RLM[Rate Limiter]
            ACL[Access Control]
        end
        
        subgraph "라우팅 계층"
            DR[Docker Registry Router]
            GR[GitHub Router]
            HR[Hugging Face Router]
            SR[Search Router]
        end
        
        subgraph "인증 및 토큰 관리"
            TM[Token Manager]
            TC[Token Cache]
            AM[Auth Manager]
        end
    end
    
    subgraph "업스트림 서비스"
        DH[Docker Hub]
        GHCR[GitHub Container Registry]
        QR[Quay.io]
        GCR[Google Container Registry]
        HF[Hugging Face]
        GH[GitHub API]
    end
    
    DC --> RP
    GC --> RP
    WB --> RP
    HC --> RP
    
    RP --> RLM
    RLM --> ACL
    ACL --> DR
    ACL --> GR
    ACL --> HR
    ACL --> SR
    
    DR --> TM
    GR --> TM
    HR --> TM
    
    TM --> TC
    TM --> AM
    
    DR --> DH
    DR --> GHCR
    DR --> QR
    DR --> GCR
    GR --> GH
    HR --> HF
```

### 핵심 컴포넌트 분석

#### 1. 프록시 계층 (Proxy Layer)

**리버스 프록시**가 모든 요청의 진입점 역할을 합니다:

```go
// 의사 코드 - HubProxy의 핵심 라우팅 로직
func (h *HubProxy) ServeHTTP(w http.ResponseWriter, r *http.Request) {
    // 1. IP 기반 레이트 리밋 검사
    if !h.rateLimiter.Allow(getRealIP(r)) {
        http.Error(w, "Rate limit exceeded", http.StatusTooManyRequests)
        return
    }
    
    // 2. 접근 제어 검사
    if !h.accessControl.IsAllowed(r.URL.Path, getRealIP(r)) {
        http.Error(w, "Access denied", http.StatusForbidden)
        return
    }
    
    // 3. 요청 유형별 라우팅
    switch {
    case isDockerRegistryRequest(r):
        h.handleDockerRegistry(w, r)
    case isGitHubRequest(r):
        h.handleGitHub(w, r)
    case isHuggingFaceRequest(r):
        h.handleHuggingFace(w, r)
    case isSearchRequest(r):
        h.handleSearch(w, r)
    default:
        h.handleDefault(w, r)
    }
}
```

#### 2. Docker Registry 라우팅

HubProxy는 **Docker Registry API v2** 표준을 완전히 구현합니다:

```go
// Docker Registry 요청 처리 예시
func (h *HubProxy) handleDockerRegistry(w http.ResponseWriter, r *http.Request) {
    // URL 파싱: yourproxy.com/library/nginx -> docker.io/library/nginx
    registry, namespace, repository := h.parseDockerURL(r.URL.Path)
    
    // 업스트림 레지스트리 결정
    upstream := h.getUpstreamRegistry(registry)
    
    // 인증 토큰 획득 (캐시된 토큰 사용 또는 새로 발급)
    token := h.tokenManager.GetToken(upstream, repository)
    
    // 업스트림으로 스트리밍 프록시
    h.streamProxy(w, r, upstream, token)
}
```

#### 3. 토큰 관리 시스템

각 레지스트리별로 다른 인증 방식을 지원합니다:

```yaml
# config.toml 예시
[registries."ghcr.io"]
upstream = "ghcr.io"
authHost = "ghcr.io/token"
authType = "github"
enabled = true

[registries."gcr.io"]
upstream = "gcr.io"
authHost = "gcr.io/v2/token"
authType = "google"
enabled = true

[registries."quay.io"]
upstream = "quay.io"
authHost = "quay.io/v2/auth"
authType = "quay"
enabled = true
```

### 성능 최적화 기법

#### 1. 스트리밍 전송

HubProxy는 **캐시를 사용하지 않고** 스트리밍 방식으로 데이터를 전송합니다:

```go
// 스트리밍 프록시 구현 예시
func (h *HubProxy) streamProxy(w http.ResponseWriter, r *http.Request, upstream string, token string) {
    // 업스트림 요청 생성
    upstreamReq := h.createUpstreamRequest(r, upstream, token)
    
    // 업스트림 응답 받기
    resp, err := h.httpClient.Do(upstreamReq)
    if err != nil {
        http.Error(w, err.Error(), http.StatusInternalServerError)
        return
    }
    defer resp.Body.Close()
    
    // 헤더 복사
    h.copyHeaders(w.Header(), resp.Header)
    w.WriteHeader(resp.StatusCode)
    
    // 스트리밍 복사 (메모리 효율적)
    io.Copy(w, resp.Body)
}
```

#### 2. HTTP/2 지원

HTTP/2 멀티플렉싱으로 동시 다운로드 성능을 향상시킵니다:

```toml
[server]
# HTTP/2 다중화 활성화
enableH2C = true
```

#### 3. 토큰 캐싱

인증 토큰을 캐싱하여 인증 오버헤드를 줄입니다:

```toml
[tokenCache]
enabled = true
defaultTTL = "20m"
```

## 실제 구축 가이드

### 방법 1: Docker 배포 (권장)

가장 간단하고 안정적인 방법입니다.

#### 기본 실행

```bash
# 기본 실행
docker run -d \
  --name hubproxy \
  -p 5000:5000 \
  --restart always \
  ghcr.io/sky22333/hubproxy

# 실행 확인
curl http://localhost:5000/v2/
```

#### 커스텀 설정으로 실행

```bash
# 설정 디렉토리 생성
mkdir -p ~/hubproxy-config

# 설정 파일 생성
cat > ~/hubproxy-config/config.toml << 'EOF'
[server]
host = "0.0.0.0"
port = 5000
fileSize = 2147483648
enableH2C = true

[rateLimit]
requestLimit = 1000
periodHours = 1.0

[security]
whiteList = [
    "127.0.0.1",
    "172.17.0.0/16",
    "192.168.0.0/16"
]

[access]
blackList = [
    "*/malicious-repo"
]
EOF

# 설정 파일과 함께 실행
docker run -d \
  --name hubproxy \
  -p 5000:5000 \
  -v ~/hubproxy-config:/root \
  --restart always \
  ghcr.io/sky22333/hubproxy
```

### 방법 2: 원클릭 스크립트 설치

```bash
# 설치 스크립트 실행
curl -fsSL https://raw.githubusercontent.com/sky22333/hubproxy/main/install.sh | sudo bash

# 서비스 상태 확인
sudo systemctl status hubproxy

# 로그 확인
sudo journalctl -u hubproxy -f
```

이 스크립트는 다음 작업을 자동으로 수행합니다:

1. 시스템 아키텍처 감지 (AMD64/ARM64)
2. 최신 버전 바이너리 다운로드
3. `/opt/hubproxy/` 디렉토리에 설치
4. systemd 서비스 등록 및 시작
5. 기존 설정 보존 (업그레이드 시)

### 방법 3: 직접 바이너리 실행

```bash
# 최신 릴리스 다운로드
wget https://github.com/sky22333/hubproxy/releases/latest/download/hubproxy-linux-amd64

# 실행 권한 부여
chmod +x hubproxy-linux-amd64

# 실행
./hubproxy-linux-amd64
```

### 리버스 프록시 설정

#### Caddy 설정

```caddyfile
# /etc/caddy/Caddyfile
hub.yourdomain.com {
    reverse_proxy 127.0.0.1:5000 {
        header_up X-Real-IP {remote}
        header_up X-Forwarded-For {remote}
        header_up X-Forwarded-Proto {scheme}
        header_up X-Forwarded-Host {host}
    }
}
```

#### Nginx 설정

```nginx
# /etc/nginx/sites-available/hubproxy
server {
    listen 80;
    server_name hub.yourdomain.com;
    
    client_max_body_size 0;
    chunked_transfer_encoding on;
    
    location / {
        proxy_pass http://127.0.0.1:5000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 스트리밍 최적화
        proxy_buffering off;
        proxy_request_buffering off;
    }
}
```

## 실제 사용법과 최적화

### Docker 이미지 가속 사용

#### 개별 명령어에서 사용

```bash
# 원래 명령어
docker pull nginx

# HubProxy 사용
docker pull yourdomain.com/nginx

# 다른 레지스트리들
docker pull yourdomain.com/ghcr.io/owner/image:tag
docker pull yourdomain.com/quay.io/organization/image:tag
docker pull yourdomain.com/gcr.io/project/image:tag
```

#### 전역 미러로 설정

```bash
# Docker daemon 설정 수정
sudo tee /etc/docker/daemon.json << 'EOF'
{
  "registry-mirrors": [
    "https://yourdomain.com"
  ],
  "experimental": true,
  "features": {
    "buildkit": true
  }
}
EOF

# Docker 재시작
sudo systemctl restart docker

# 이제 기본 명령어가 가속됨
docker pull nginx
```

### GitHub 파일 가속 사용

#### Release 파일 다운로드

```bash
# 원본 URL
https://github.com/owner/repo/releases/download/v1.0.0/file.tar.gz

# 가속 URL
https://yourdomain.com/https://github.com/owner/repo/releases/download/v1.0.0/file.tar.gz

# wget으로 사용
wget https://yourdomain.com/https://github.com/owner/repo/releases/download/v1.0.0/file.tar.gz
```

#### Git 저장소 클론 가속

```bash
# 일반 클론
git clone https://github.com/owner/repo.git

# 가속 클론
git clone https://yourdomain.com/https://github.com/owner/repo.git
```

#### GitHub API 가속

```bash
# API 호출 가속
curl https://yourdomain.com/https://api.github.com/repos/owner/repo/releases/latest
```

### Hugging Face 모델 다운로드 가속

```bash
# 원본 다운로드 (느림)
wget https://huggingface.co/microsoft/DialoGPT-large/resolve/main/pytorch_model.bin

# 가속 다운로드
wget https://yourdomain.com/https://huggingface.co/microsoft/DialoGPT-large/resolve/main/pytorch_model.bin
```

### 오프라인 이미지 패키지 다운로드

```bash
# 단일 이미지 다운로드
curl "https://yourdomain.com/download?images=nginx:latest" -o nginx.tar

# 여러 이미지 동시 다운로드
curl "https://yourdomain.com/download?images=nginx:latest,redis:alpine,postgres:13" -o myapp.tar

# 다운로드한 이미지 로드
docker load -i nginx.tar
```

### 이미지 검색 기능

```bash
# 이미지 검색 API
curl "https://yourdomain.com/search?q=nginx&limit=10"

# 검색 결과 예시
{
  "results": [
    {
      "name": "nginx",
      "description": "Official build of Nginx",
      "stars": 15000,
      "official": true,
      "automated": false
    }
  ]
}
```

## 성능 모니터링 및 최적화

### 성능 측정

```bash
# 다운로드 속도 측정 스크립트
#!/bin/bash

echo "=== HubProxy 성능 테스트 ==="

# 직접 다운로드
echo "1. Docker Hub 직접 다운로드:"
time docker pull nginx:latest

# 이미지 삭제
docker rmi nginx:latest

# HubProxy를 통한 다운로드
echo "2. HubProxy를 통한 다운로드:"
time docker pull yourdomain.com/nginx:latest

echo "테스트 완료"
```

### 시스템 리소스 모니터링

```bash
# HubProxy 프로세스 모니터링
ps aux | grep hubproxy

# 메모리 사용량 확인
top -p $(pgrep hubproxy)

# 네트워크 연결 상태
netstat -tulpn | grep :5000
```

### 로그 분석

```bash
# systemd 서비스 로그
sudo journalctl -u hubproxy -f --since "1 hour ago"

# Docker 컨테이너 로그
docker logs hubproxy -f --since 1h

# 접근 패턴 분석
sudo journalctl -u hubproxy --since "1 day ago" | grep "GET" | awk '{print $7}' | sort | uniq -c | sort -nr
```

## 고급 설정 및 운영

### 세밀한 접근 제어

```toml
[access]
# 특정 조직만 허용
whiteList = [
    "microsoft/*",
    "google/*",
    "hashicorp/*"
]

# 악성 저장소 차단
blackList = [
    "*/malware-*",
    "suspicious-user/*",
    "*/backdoor"
]
```

### 성능 튜닝

```toml
[server]
# 파일 크기 제한 (5GB)
fileSize = 5368709120
# HTTP/2 활성화
enableH2C = true

[rateLimit]
# 더 관대한 제한 (기업 환경)
requestLimit = 2000
periodHours = 1.0

[tokenCache]
# 토큰 캐시 최적화
enabled = true
defaultTTL = "30m"
```

### 보안 강화

```toml
[security]
# 사내 네트워크만 허용
whiteList = [
    "10.0.0.0/8",
    "172.16.0.0/12",
    "192.168.0.0/16"
]

# 알려진 악성 IP 차단
blackList = [
    "suspicious.ip.range/24"
]
```

### 프록시 체인 설정

```toml
# 업스트림 프록시 사용 (예: 회사 프록시)
proxy = "socks5://proxy.company.com:1080"

# 인증이 필요한 프록시
proxy = "socks5://username:password@proxy.company.com:1080"
```

## 실무에서의 활용 사례

### 사례 1: CI/CD 파이프라인 가속

```yaml
# .github/workflows/build.yml
name: Build and Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    # Docker daemon에 HubProxy 미러 설정
    - name: Configure Docker mirror
      run: |
        echo '{"registry-mirrors": ["https://hub.company.com"]}' | sudo tee /etc/docker/daemon.json
        sudo systemctl restart docker
    
    - name: Build Docker image
      run: |
        # 이제 모든 docker pull이 가속됨
        docker build -t myapp .
    
    - name: Run tests
      run: |
        docker run --rm myapp npm test
```

### 사례 2: 개발팀 공유 인프라

```bash
# 팀 전체에서 사용할 HubProxy 설정
# /etc/docker/daemon.json (모든 개발 머신에 적용)
{
  "registry-mirrors": [
    "https://hub.internal.company.com"
  ],
  "insecure-registries": [
    "registry.internal.company.com"
  ]
}
```

### 사례 3: Kubernetes 클러스터 최적화

```yaml
# kubernetes/docker-config.yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: docker-daemon-config
data:
  daemon.json: |
    {
      "registry-mirrors": [
        "https://hub.company.com"
      ],
      "max-concurrent-downloads": 10,
      "max-concurrent-uploads": 10
    }
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: docker-config-updater
spec:
  selector:
    matchLabels:
      app: docker-config-updater
  template:
    metadata:
      labels:
        app: docker-config-updater
    spec:
      hostNetwork: true
      containers:
      - name: config-updater
        image: alpine
        command: ["sh", "-c"]
        args:
        - |
          cp /config/daemon.json /host/etc/docker/daemon.json
          kill -HUP $(pidof dockerd)
        volumeMounts:
        - name: config
          mountPath: /config
        - name: docker-config
          mountPath: /host/etc/docker
      volumes:
      - name: config
        configMap:
          name: docker-daemon-config
      - name: docker-config
        hostPath:
          path: /etc/docker
```

## 트러블슈팅

### 일반적인 문제들

#### 1. 인증 오류

```bash
# 문제: unauthorized: authentication required
# 해결: 토큰 캐시 초기화
curl -X DELETE http://localhost:5000/api/cache/tokens

# 또는 서비스 재시작
sudo systemctl restart hubproxy
```

#### 2. 레이트 리밋 도달

```bash
# 문제: Rate limit exceeded
# 해결: IP 화이트리스트 추가 또는 제한 완화
```

```toml
[rateLimit]
requestLimit = 2000  # 기본값: 500
periodHours = 1.0    # 기본값: 3.0

[security]
whiteList = [
    "your.ip.address"
]
```

#### 3. 대용량 파일 다운로드 실패

```toml
[server]
# 파일 크기 제한 증가 (10GB)
fileSize = 10737418240
```

#### 4. SSL/TLS 인증서 오류

```bash
# 자체 서명 인증서인 경우
docker run -d \
  --name hubproxy \
  -p 5000:5000 \
  -e SKIP_TLS_VERIFY=true \
  ghcr.io/sky22333/hubproxy
```

### 성능 이슈 해결

#### 1. 동시 연결 수 제한

```bash
# 시스템 제한 확인
ulimit -n

# 제한 증가
echo "* soft nofile 65536" | sudo tee -a /etc/security/limits.conf
echo "* hard nofile 65536" | sudo tee -a /etc/security/limits.conf
```

#### 2. 메모리 사용량 최적화

```bash
# Go 가비지 컬렉터 튜닝
export GOGC=50  # 더 자주 GC 실행
export GOMEMLIMIT=500MiB  # 메모리 사용 제한
```

## 결론

HubProxy는 **단순하면서도 강력한** 개발 도구입니다. Go 언어의 성능과 간결함을 바탕으로 복잡한 네트워크 환경에서도 안정적으로 작동합니다.

### 핵심 장점 요약

1. **즉시 사용 가능**: 별도 구성 없이 바로 실행
2. **경량 설계**: 최소한의 리소스로 최대 성능
3. **포괄적 지원**: Docker, GitHub, Hugging Face 모두 지원
4. **보안 기능**: 접근 제어, 레이트 리밋, 감사 기능
5. **운영 친화적**: 상세한 로그, 모니터링 지원

### 다음 단계

1. **프로덕션 배포**: HTTPS 인증서 설정, 도메인 연결
2. **모니터링 구축**: Prometheus, Grafana 연동
3. **백업 전략**: 설정 파일 버전 관리
4. **팀 교육**: 사용법 공유, 가이드라인 수립

HubProxy를 통해 **개발 생산성을 크게 향상**시킬 수 있을 것입니다. 더 빠른 빌드, 더 원활한 배포, 더 안정적인 개발 환경을 경험해보세요.

## 참고 자료

- **HubProxy GitHub**: [https://github.com/sky22333/hubproxy](https://github.com/sky22333/hubproxy)
- **공식 문서**: README.md 및 설정 예제
- **Docker Registry API v2**: [Docker Registry HTTP API V2](https://docs.docker.com/registry/spec/api/)
- **Go 성능 최적화**: [Effective Go](https://golang.org/doc/effective_go.html)

---

💡 **실제 테스트 경험을 공유하세요!** HubProxy를 사용해보신 경험이나 추가 질문이 있으시면 댓글로 남겨주세요.
