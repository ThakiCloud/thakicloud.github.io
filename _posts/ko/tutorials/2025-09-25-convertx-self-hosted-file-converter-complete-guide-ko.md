---
title: "ConvertX: 셀프 호스팅 온라인 파일 변환기 - 완전 설치 및 사용 가이드"
excerpt: "1000개 이상의 파일 형식을 지원하는 강력한 셀프 호스팅 파일 변환기 ConvertX를 Docker로 배포하고 사용하는 방법을 학습하세요. 개인정보 보호를 중시하는 사용자와 조직에 완벽한 솔루션입니다."
seo_title: "ConvertX 셀프 호스팅 파일 변환기 튜토리얼 - 완전 가이드 - Thaki Cloud"
seo_description: "ConvertX를 Docker로 배포하는 단계별 가이드. 이미지, 비디오, 문서, 3D 에셋을 포함한 1000개 이상의 파일 형식을 지원하는 셀프 호스팅 파일 변환기입니다."
date: 2025-09-25
categories:
  - tutorials
tags:
  - docker
  - file-converter
  - self-hosted
  - typescript
  - privacy
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/convertx-self-hosted-file-converter-complete-guide/
canonical_url: "https://thakicloud.github.io/ko/tutorials/convertx-self-hosted-file-converter-complete-guide/"
---

⏱️ **예상 읽기 시간**: 8분

## 소개

오늘날 디지털 세상에서 파일 형식 변환은 흔한 필요사항입니다. 이미지, 비디오, 문서, 또는 3D 에셋을 다룰 때 신뢰할 수 있는 변환기는 필수적입니다. 클라우드 기반 솔루션들이 존재하지만, 이들은 종종 개인정보 보호 우려를 불러일으키고 파일 크기나 사용량 제한이 있을 수 있습니다.

[ConvertX](https://github.com/C4illin/ConvertX)는 우아한 솔루션을 제공합니다: 1000개 이상의 다양한 형식을 지원하는 셀프 호스팅 온라인 파일 변환기입니다. TypeScript, Bun, Elysia로 구축된 ConvertX는 엔터프라이즈급 변환 기능을 제공하면서 데이터에 대한 완전한 제어권을 제공합니다.

## ConvertX란 무엇인가요?

ConvertX는 완전히 당신의 인프라에서 실행되는 오픈소스 셀프 호스팅 파일 변환 플랫폼입니다. 다양한 카테고리의 여러 파일 형식을 지원하며, 강력하면서도 개인정보 보호에 중점을 둔 설계를 특징으로 합니다.

### 주요 기능

- **광범위한 형식 지원**: 1000개 이상의 다양한 파일 형식
- **배치 처리**: 여러 파일을 동시에 변환
- **개인정보 보호**: 비밀번호 보호 및 사용자 인증
- **다중 사용자 지원**: 적절한 격리를 통한 여러 계정
- **모던 아키텍처**: TypeScript와 최신 웹 기술로 구축
- **Docker 지원**: Docker 및 Docker Compose를 통한 쉬운 배포

### 지원되는 변환기

ConvertX는 다양한 파일 타입을 처리하기 위해 여러 전문 변환기를 통합합니다:

| 변환기 | 사용 용도 | 입력 형식 | 출력 형식 |
|--------|-----------|-----------|-----------|
| **FFmpeg** | 비디오/오디오 | ~472 | ~199 |
| **ImageMagick** | 이미지 | 245 | 183 |
| **GraphicsMagick** | 이미지 | 167 | 130 |
| **Assimp** | 3D 에셋 | 77 | 23 |
| **Pandoc** | 문서 | 43 | 65 |
| **Vips** | 이미지 | 45 | 23 |
| **Calibre** | 전자책 | 26 | 19 |
| **Inkscape** | 벡터 그래픽 | 7 | 17 |
| **libjxl** | JPEG XL | 11 | 11 |
| **Potrace** | 래스터를 벡터로 | 4 | 11 |

## 사전 요구사항

ConvertX를 배포하기 전에 다음을 확인하세요:

- **Docker** (버전 20.10 이상)
- **Docker Compose** (버전 2.0 이상)
- **충분한 리소스를 가진 서버**:
  - 최소 요구사항: 2GB RAM, 1개 CPU 코어
  - 권장사항: 4GB RAM, 2개 이상 CPU 코어
  - 스토리지: 파일과 컨테이너용 최소 10GB 여유 공간

## 설치 및 설정

### 방법 1: Docker Compose (권장)

프로젝트 디렉토리를 생성하고 설정을 구성합니다:

```bash
# 프로젝트 디렉토리 생성
mkdir convertx-app
cd convertx-app

# Docker Compose 파일 생성
cat > docker-compose.yml << 'EOF'
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: convertx
    restart: unless-stopped
    ports:
      - "3000:3000"
    environment:
      - JWT_SECRET=aLongAndSecretStringUsedToSignTheJSONWebToken1234567890
      - ACCOUNT_REGISTRATION=false
      - AUTO_DELETE_EVERY_N_HOURS=24
      - LANGUAGE=ko
      # HTTP로 접근하는 경우 주석 해제 (프로덕션에서는 권장하지 않음)
      # - HTTP_ALLOWED=true
    volumes:
      - ./data:/app/data
    labels:
      - "com.docker.compose.project=convertx"
EOF

# 적절한 권한으로 데이터 디렉토리 생성
mkdir -p data
sudo chown -R $USER:$USER data
```

### 방법 2: Docker Run

Docker Compose 없이 빠른 시작:

```bash
# 데이터 디렉토리 생성
mkdir -p ~/convertx-data

# ConvertX 컨테이너 실행
docker run -d \
  --name convertx \
  --restart unless-stopped \
  -p 3000:3000 \
  -v ~/convertx-data:/app/data \
  -e JWT_SECRET=aLongAndSecretStringUsedToSignTheJSONWebToken1234567890 \
  -e ACCOUNT_REGISTRATION=false \
  -e AUTO_DELETE_EVERY_N_HOURS=24 \
  -e LANGUAGE=ko \
  ghcr.io/c4illin/convertx
```

### 배포

애플리케이션을 배포합니다:

```bash
# Docker Compose 사용
docker-compose up -d

# 컨테이너가 실행 중인지 확인
docker-compose ps

# 로그 확인
docker-compose logs -f convertx
```

## 초기 설정

### 1. 애플리케이션 접근

웹 브라우저를 열고 다음으로 이동합니다:
- **로컬 접근**: `http://localhost:3000`
- **원격 접근**: `https://your-domain.com:3000` (HTTPS 권장)

### 2. 관리자 계정 생성

1. 첫 접근 시 회원가입 페이지가 표시됩니다
2. 강력한 비밀번호로 관리자 계정을 생성합니다
3. **중요**: 계정 생성 후 `ACCOUNT_REGISTRATION=false`로 설정하여 회원가입을 비활성화합니다

### 3. 보안 설정 구성

프로덕션 배포를 위해 다음 보안 강화 사항을 고려하세요:

```yaml
# 강화된 docker-compose.yml
services:
  convertx:
    image: ghcr.io/c4illin/convertx
    container_name: convertx
    restart: unless-stopped
    ports:
      - "127.0.0.1:3000:3000"  # localhost에만 바인딩
    environment:
      - JWT_SECRET=${JWT_SECRET}  # 환경 변수 사용
      - ACCOUNT_REGISTRATION=false
      - HTTP_ALLOWED=false  # HTTPS 강제
      - AUTO_DELETE_EVERY_N_HOURS=12  # 더 자주 파일 정리
      - HIDE_HISTORY=false
      - LANGUAGE=ko
    volumes:
      - ./data:/app/data
      - /etc/localtime:/etc/localtime:ro  # 시간대 동기화
    networks:
      - convertx-network

networks:
  convertx-network:
    driver: bridge
```

## 사용 가이드

### 기본 파일 변환

1. **파일 업로드**:
   - "파일 선택"을 클릭하거나 드래그 앤 드롭
   - 단일 또는 다중 파일 선택
   - 지원되는 형식이 자동으로 감지됩니다

2. **출력 형식 선택**:
   - 드롭다운에서 대상 형식 선택
   - 형식은 타입별로 분류됩니다 (이미지, 비디오, 문서 등)

3. **설정 구성** (가능한 경우):
   - 이미지/비디오 품질 설정
   - 압축 옵션
   - 해상도 설정

4. **변환 시작**:
   - "변환"을 클릭하여 처리 시작
   - 실시간으로 진행 상황 모니터링
   - 완료되면 결과 다운로드

### 고급 기능

#### 배치 처리

ConvertX는 여러 파일 처리에 탁월합니다:

```bash
# 예시: 여러 이미지 변환
# 업로드: image1.png, image2.jpg, image3.bmp
# 출력 형식: WebP
# 결과: 모든 이미지가 WebP 형식으로 변환됨
```

#### 비밀번호 보호

변환 중 민감한 파일을 보호합니다:

1. 설정에서 비밀번호 보호 활성화
2. 변환 비밀번호 설정
3. 인증된 사용자와 안전하게 비밀번호 공유

#### 사용자 정의 FFmpeg 인수

고급 비디오 처리를 위해 사용자 정의 FFmpeg 인수를 구성할 수 있습니다:

```yaml
environment:
  - FFMPEG_ARGS=-preset veryfast -crf 23
```

### 실용적인 사용 사례

#### 1. 웹용 이미지 최적화

```bash
# 웹 사용을 위한 이미지 변환 및 최적화
입력: high-resolution.jpg (5MB)
출력: optimized.webp (500KB)
설정: WebP 형식, 80% 품질
```

#### 2. 문서 형식 마이그레이션

```bash
# 레거시 문서 변환
입력: old-document.doc
출력: modern-document.pdf
변환기: Pandoc
```

#### 3. 비디오 압축

```bash
# 비디오 파일 압축
입력: large-video.mov (1GB)
출력: compressed-video.mp4 (200MB)
변환기: H.264 코덱이 포함된 FFmpeg
```

#### 4. 3D 에셋 처리

```bash
# 3D 모델 형식 간 변환
입력: model.fbx
출력: model.glb
변환기: Assimp
```

## 환경 변수 참조

이러한 환경 변수로 ConvertX 동작을 사용자 정의하세요:

| 변수 | 기본값 | 설명 |
|------|--------|------|
| `JWT_SECRET` | Random UUID | JWT 토큰 서명용 비밀 키 |
| `ACCOUNT_REGISTRATION` | `false` | 새 사용자 회원가입 허용 |
| `HTTP_ALLOWED` | `false` | HTTP 연결 허용 (로컬에서만 사용) |
| `ALLOW_UNAUTHENTICATED` | `false` | 익명 사용 허용 |
| `AUTO_DELETE_EVERY_N_HOURS` | `24` | 자동 파일 정리 간격 |
| `WEBROOT` | `/` | 웹 애플리케이션 루트 경로 |
| `FFMPEG_ARGS` | 없음 | 사용자 정의 FFmpeg 인수 |
| `HIDE_HISTORY` | `false` | 변환 기록 숨기기 |
| `LANGUAGE` | `en` | 인터페이스 언어 (BCP 47 형식) |
| `UNAUTHENTICATED_USER_SHARING` | `false` | 익명 사용자 간 기록 공유 |

## 모니터링 및 유지보수

### 상태 확인

ConvertX 상태를 모니터링합니다:

```bash
# 컨테이너 상태 확인
docker-compose ps

# 실시간 로그 보기
docker-compose logs -f convertx

# 리소스 사용량 확인
docker stats convertx
```

### 백업 전략

정기적인 백업으로 데이터를 보호합니다:

```bash
#!/bin/bash
# backup-convertx.sh

BACKUP_DIR="/backup/convertx"
DATA_DIR="./data"
DATE=$(date +%Y%m%d_%H%M%S)

# 백업 디렉토리 생성
mkdir -p "$BACKUP_DIR"

# 데이터 디렉토리 백업
tar -czf "$BACKUP_DIR/convertx_data_$DATE.tar.gz" -C "$DATA_DIR" .

# 최근 7개 백업만 유지
find "$BACKUP_DIR" -name "convertx_data_*.tar.gz" -mtime +7 -delete

echo "백업 완료: convertx_data_$DATE.tar.gz"
```

### 업데이트

ConvertX를 최신 상태로 유지합니다:

```bash
# 최신 버전으로 업데이트
docker-compose pull
docker-compose up -d

# 버전 확인
docker exec convertx cat /app/package.json | grep version
```

## 문제 해결

### 일반적인 문제

#### 1. 권한 오류

```bash
# 데이터 디렉토리 권한 수정
sudo chown -R $USER:$USER ./data
chmod -R 755 ./data
```

#### 2. 로그인 문제

로그인할 수 없는 경우:
- HTTPS 또는 localhost를 통해 접근하는지 확인
- HTTP 접근을 위해 `HTTP_ALLOWED=true` 설정 (프로덕션에서는 권장하지 않음)

#### 3. 변환 실패

특정 오류 메시지에 대한 로그 확인:

```bash
# 상세 로그 보기
docker-compose logs --tail=50 convertx

# 컨테이너 리소스 확인
docker stats convertx
```

#### 4. 파일 업로드 제한

대용량 파일 업로드가 실패할 수 있습니다. 확인사항:
- 사용 가능한 디스크 공간
- 컨테이너 메모리 제한
- 네트워크 타임아웃 설정

### 성능 최적화

#### 리소스 할당

많은 사용량에 대해 Docker 리소스 제한을 조정합니다:

```yaml
services:
  convertx:
    # ... 기타 설정
    deploy:
      resources:
        limits:
          memory: 4G
          cpus: '2'
        reservations:
          memory: 2G
          cpus: '1'
```

#### 스토리지 최적화

자동 정리 구성:

```yaml
environment:
  - AUTO_DELETE_EVERY_N_HOURS=6  # 6시간마다 정리
```

## 보안 모범 사례

### 1. 네트워크 보안

프로덕션용 리버스 프록시 사용:

```nginx
# Nginx 설정 예시
server {
    listen 443 ssl http2;
    server_name convert.yourdomain.com;
    
    ssl_certificate /path/to/certificate.crt;
    ssl_certificate_key /path/to/private.key;
    
    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_set_header Host $host;
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        
        # 파일 업로드 크기 제한
        client_max_body_size 100M;
    }
}
```

### 2. 접근 제어

추가 보안 계층 구현:

```yaml
# 인증을 위한 Traefik 라벨 사용
labels:
  - "traefik.http.middlewares.convertx-auth.basicauth.users=admin:$$2y$$10$$..."
  - "traefik.http.routers.convertx.middlewares=convertx-auth"
```

### 3. 정기적인 보안 업데이트

```bash
# ConvertX 정기적으로 업데이트
docker-compose pull && docker-compose up -d

# 기본 시스템 업데이트
sudo apt update && sudo apt upgrade -y
```

## 결론

ConvertX는 파일 변환 필요에 대한 강력하고 셀프 호스팅된 솔루션을 제공합니다. 광범위한 형식 지원, 개인정보 보호 중심 설계, 그리고 쉬운 Docker 배포로 개인 사용과 엔터프라이즈 사용 모두에 탁월한 선택입니다.

이 플랫폼의 강점은 강력한 변환 기능과 사용자 제어의 조합에 있습니다. 직접 호스팅함으로써 전문가급 변환 도구의 이점을 누리면서 파일에 대한 완전한 개인정보 보호를 유지할 수 있습니다.

웹사이트용 이미지 처리, 보관용 문서 변환, 또는 멀티미디어 콘텐츠 처리 등 무엇을 하든, ConvertX는 현대적인 파일 변환 워크플로우에 필요한 유연성과 신뢰성을 제공합니다.

## 추가 자료

- **공식 저장소**: [https://github.com/C4illin/ConvertX](https://github.com/C4illin/ConvertX)
- **Docker Hub**: [https://hub.docker.com/r/c4illin/convertx](https://hub.docker.com/r/c4illin/convertx)
- **GitHub Container Registry**: [https://ghcr.io/c4illin/convertx](https://ghcr.io/c4illin/convertx)
- **이슈 트래커**: [https://github.com/C4illin/ConvertX/issues](https://github.com/C4illin/ConvertX/issues)

---

*이 튜토리얼은 ConvertX 배포 및 사용의 필수 측면을 다룹니다. 특정 사용 사례나 고급 설정에 대해서는 공식 문서나 커뮤니티 토론을 참조하세요.*
