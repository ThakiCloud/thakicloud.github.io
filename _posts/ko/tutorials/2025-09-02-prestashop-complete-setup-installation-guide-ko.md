---
title: "PrestaShop 완벽 설치 가이드: 처음부터 전자상거래 스토어 구축하기"
excerpt: "PrestaShop 9.0 전자상거래 플랫폼을 Docker, PHP, MySQL과 함께 설치하고 구성하는 단계별 튜토리얼. 첫 온라인 스토어를 구축하는 초보자에게 완벽한 가이드입니다."
seo_title: "PrestaShop 설치 가이드 2025 - 완벽한 설정 튜토리얼 - Thaki Cloud"
seo_description: "PrestaShop 9.0 전자상거래 플랫폼을 단계별로 설치하는 방법을 배우세요. Docker 설정, 데이터베이스 구성, 온라인 스토어 개발 모범 사례를 포함합니다."
date: 2025-09-02
categories:
  - tutorials
tags:
  - prestashop
  - 전자상거래
  - php
  - docker
  - mysql
  - 설치
author_profile: true
toc: true
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/prestashop-complete-setup-installation-guide/
canonical_url: "https://thakicloud.github.io/ko/tutorials/prestashop-complete-setup-installation-guide/"
---

⏱️ **예상 읽기 시간**: 15분

## 서론

PrestaShop은 다국어 지원, 결제 게이트웨이 통합, 포괄적인 재고 관리와 같은 고급 기능을 갖춘 전문적인 온라인 스토어를 구축할 수 있게 해주는 강력한 오픈소스 전자상거래 플랫폼입니다. 이 포괄적인 튜토리얼에서는 기존 서버 설정을 사용하든 최신 Docker 컨테이너를 사용하든 처음부터 PrestaShop 9.0을 설치하고 구성하는 방법을 배우게 됩니다.

GitHub에서 8.7k개 이상의 스타와 활발한 커뮤니티 지원을 받고 있는 PrestaShop은 모든 규모의 비즈니스를 위한 선도적인 전자상거래 솔루션 중 하나로 자리잡았습니다. 이 가이드는 설치 프로세스의 모든 단계를 안내하여 커스터마이징할 준비가 된 완전히 기능적인 온라인 스토어를 확보할 수 있도록 도와드립니다.

## 전제 조건 및 시스템 요구사항

설치를 시작하기 전에 시스템이 다음 요구사항을 충족하는지 확인하세요:

### 서버 요구사항
- **PHP**: 버전 8.1 이상
- **데이터베이스**: MySQL 5.6+, MariaDB, 또는 Percona Server
- **웹 서버**: Apache 또는 Nginx (권장)
- **메모리**: 최소 512MB RAM (프로덕션용으로는 2GB+ 권장)
- **스토리지**: 최소 1GB 여유 디스크 공간

### 개발 환경 요구사항
- **Docker**: 최신 버전 (컨테이너 기반 설정용)
- **Git**: 저장소 복제용
- **텍스트 에디터**: VS Code, PhpStorm 또는 유사한 도구
- **데이터베이스 관리 도구**: phpMyAdmin (선택사항이지만 권장)

### 권장 시스템 구성
```bash
# Ubuntu/Debian 시스템용
sudo apt update && sudo apt upgrade -y
sudo apt install php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip
sudo apt install mysql-server nginx git curl
```

## 설치 방법 1: Docker 설정 (개발용 권장)

Docker는 특히 개발 및 테스트 목적으로 PrestaShop을 실행하는 가장 빠르고 안정적인 방법을 제공합니다.

### 단계 1: PrestaShop 저장소 복제

```bash
# 프로젝트 디렉토리 생성
mkdir prestashop-project && cd prestashop-project

# 공식 저장소 복제
git clone https://github.com/PrestaShop/PrestaShop.git
cd PrestaShop

# 안정적인 브랜치로 전환 (선택사항)
git checkout main
```

### 단계 2: 환경 변수 구성

```bash
# 사용자 정의 관리자 자격 증명 설정 (선택사항)
export ADMIN_MAIL=admin@yourstore.com
export ADMIN_PASSWD=SecurePassword123!

# 환경 변수 확인
echo "관리자 이메일: $ADMIN_MAIL"
echo "관리자 비밀번호: $ADMIN_PASSWD"
```

### 단계 3: Docker 서비스 시작

```bash
# Docker Compose로 PrestaShop 시작
docker compose up -d

# 시작 프로세스 모니터링
docker compose logs -f prestashop
```

### 단계 4: 스토어 접속

컨테이너가 실행되면 다음에 접속할 수 있습니다:

- **프론트엔드 스토어**: http://localhost:8001
- **관리자 패널**: http://localhost:8001/admin-dev
- **기본 로그인**: demo@prestashop.com / Correct Horse Battery Staple

### 단계 5: 선택적 서비스 설정

#### phpMyAdmin 추가
```bash
# 오버라이드 구성 복사
cp docker-compose.override.yml.dist docker-compose.override.yml

# phpMyAdmin과 함께 서비스 시작
docker compose up -d

# http://localhost:8080에서 phpMyAdmin 접속
```

#### Blackfire 통합 (성능 모니터링)
```bash
# Blackfire 환경 변수 설정
export BLACKFIRE_ENABLE=1
export BLACKFIRE_SERVER_ID="your_server_id"
export BLACKFIRE_SERVER_TOKEN="your_blackfire_server_token"

# docker-compose.override.yml을 Blackfire 구성으로 업데이트
# 그 다음 서비스 재시작
docker compose down && docker compose up -d
```

## 설치 방법 2: 전통적인 서버 설정

프로덕션 환경이나 전통적인 서버 설정을 선호하는 경우 다음 단계를 따르세요:

### 단계 1: PrestaShop 다운로드

```bash
# 최신 안정 릴리스 다운로드
wget https://github.com/PrestaShop/PrestaShop/releases/download/9.0.0/prestashop_9.0.0.zip

# 파일 추출
unzip prestashop_9.0.0.zip -d /var/www/html/prestashop

# 적절한 권한 설정
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo chmod -R 755 /var/www/html/prestashop
```

### 단계 2: 웹 서버 구성

#### Nginx 구성
```nginx
server {
    listen 80;
    server_name your-domain.com;
    root /var/www/html/prestashop;
    index index.php index.html;

    location / {
        try_files $uri $uri/ /index.php?$query_string;
    }

    location ~ \.php$ {
        fastcgi_pass unix:/var/run/php/php8.1-fpm.sock;
        fastcgi_index index.php;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
        include fastcgi_params;
    }

    location ~* \.(js|css|png|jpg|jpeg|gif|ico|svg)$ {
        expires 1y;
        add_header Cache-Control "public, immutable";
    }
}
```

#### Apache 구성
```apache
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/html/prestashop
    
    <Directory /var/www/html/prestashop>
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/prestashop_error.log
    CustomLog ${APACHE_LOG_DIR}/prestashop_access.log combined
</VirtualHost>
```

### 단계 3: 데이터베이스 설정

```sql
-- 데이터베이스와 사용자 생성
CREATE DATABASE prestashop_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'prestashop_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON prestashop_db.* TO 'prestashop_user'@'localhost';
FLUSH PRIVILEGES;
```

### 단계 4: 설치 마법사 실행

1. `http://your-domain.com/install-dev`로 이동
2. 설치 마법사를 따라가세요:
   - **언어 선택**: 원하는 언어 선택
   - **라이선스 계약**: 약관 동의
   - **시스템 요구사항**: 모든 요구사항이 충족되는지 확인
   - **스토어 정보**: 스토어 이름, 로고, 관리자 계정 구성
   - **데이터베이스 구성**: MySQL 자격 증명 입력
   - **설치**: 프로세스 완료까지 대기

### 단계 5: 보안 강화

```bash
# 설치 디렉토리 제거
sudo rm -rf /var/www/html/prestashop/install-dev

# 보안을 위해 관리자 디렉토리 이름 변경
sudo mv /var/www/html/prestashop/admin-dev /var/www/html/prestashop/admin-$(openssl rand -hex 4)

# 제한적인 권한 설정
sudo chmod 644 /var/www/html/prestashop/app/config/parameters.php
sudo chmod 755 /var/www/html/prestashop/var
```

## 설치 후 구성

### 필수 보안 설정

1. **관리자 디렉토리 이름 변경**
   ```bash
   # 무단 접근을 방지하기 위해 관리자 디렉토리 이름을 변경해야 합니다
   mv admin-dev admin-$(date +%s)
   ```

2. **SSL/HTTPS 구성**
   ```bash
   # SSL 인증서 설치 (Let's Encrypt 사용)
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

3. **구성 매개변수 업데이트**
   ```php
   // app/config/parameters.php에서
   'ps_base_dir' => '/var/www/html/prestashop/',
   'ps_ssl_enabled' => true,
   'ps_shop_domain' => 'your-domain.com',
   'ps_shop_domain_ssl' => 'your-domain.com',
   ```

### 성능 최적화

#### 캐싱 활성화
```php
// app/config/parameters.php에서
'cache_driver' => 'redis', // 또는 'memcached'
'cache_prefix' => 'ps_',
'cache_host' => '127.0.0.1',
'cache_port' => 6379,
```

#### OpCache 구성
```ini
; php.ini에서
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=1
```

### 모듈 관리

#### 필수 모듈 설치
```bash
# 모듈 디렉토리로 이동
cd /var/www/html/prestashop/modules

# 인기 모듈 다운로드
git clone https://github.com/PrestaShop/ps_facetedsearch.git
git clone https://github.com/PrestaShop/ps_emailsubscription.git
```

#### 결제 모듈 구성
1. **PayPal 통합**
   - 관리자 → 모듈 → 결제로 이동
   - PayPal 공식 모듈 설치
   - API 자격 증명 구성

2. **Stripe 구성**
   - Stripe 공식 모듈 설치
   - 웹훅 엔드포인트 설정
   - 테스트/라이브 모드 구성

## 개발 환경 설정

### 개발 의존성

```bash
# 테마 개발을 위한 Node.js와 npm 설치
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# PHP 의존성을 위한 Composer 설치
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# 개발 도구 설치
composer install --dev
npm install
```

### 테마 개발 설정

```bash
# 테마 디렉토리로 이동
cd themes/classic

# 테마 의존성 설치
npm install

# 핫 리로드와 함께 개발 서버 시작
npm run dev

# 프로덕션용 빌드
npm run build
```

### 모듈 개발 환경

```bash
# 사용자 정의 모듈 구조 생성
mkdir modules/mycustommodule
cd modules/mycustommodule

# 기본 모듈 구조
touch mycustommodule.php
mkdir config controllers override translations views
mkdir views/templates views/css views/js
```

## 일반적인 문제 해결

### Docker 관련 문제

#### 컨테이너가 시작되지 않음
```bash
# 컨테이너 로그 확인
docker compose logs prestashop

# 컨테이너 완전 리셋
docker compose down -v
docker compose build --no-cache
docker compose up --build --force-recreate
```

#### 데이터베이스 연결 문제
```bash
# 데이터베이스 컨테이너가 실행 중인지 확인
docker compose ps

# 데이터베이스 로그 확인
docker compose logs mysql

# 데이터베이스 볼륨 리셋
docker compose down -v
docker volume rm prestashop_mysql_data
```

### 전통적인 설치 문제

#### 권한 문제
```bash
# 파일 권한 수정
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo find /var/www/html/prestashop -type d -exec chmod 755 {} \;
sudo find /var/www/html/prestashop -type f -exec chmod 644 {} \;
```

#### PHP 메모리 한계
```ini
; php.ini 또는 .htaccess에서
memory_limit = 512M
max_execution_time = 300
max_input_vars = 10000
```

#### URL 재작성 문제
```apache
# .htaccess에서
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

## 고급 구성

### 멀티스토어 설정

```php
// parameters.php에서 멀티스토어 활성화
'ps_multishop_feature_active' => true,

// 스토어 그룹 구성
'shop_group' => [
    'main' => ['id' => 1, 'name' => 'Main Group'],
    'secondary' => ['id' => 2, 'name' => 'Secondary Group']
],
```

### API 구성

```php
// 웹 서비스 활성화
'ps_webservice' => true,
'ps_webservice_key' => 'your-api-key-here',

// API 권한 구성
'api_permissions' => [
    'products' => ['GET', 'POST', 'PUT', 'DELETE'],
    'customers' => ['GET', 'POST', 'PUT'],
    'orders' => ['GET', 'PUT']
],
```

### 백업 및 유지보수

#### 자동 백업 스크립트
```bash
#!/bin/bash
# backup-prestashop.sh

BACKUP_DIR="/var/backups/prestashop"
DB_NAME="prestashop_db"
DB_USER="prestashop_user"
DB_PASS="secure_password"
WEB_DIR="/var/www/html/prestashop"

# 백업 디렉토리 생성
mkdir -p $BACKUP_DIR/$(date +%Y-%m-%d)

# 데이터베이스 백업
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/$(date +%Y-%m-%d)/database.sql

# 파일 백업
tar -czf $BACKUP_DIR/$(date +%Y-%m-%d)/files.tar.gz $WEB_DIR

# 오래된 백업 정리 (30일 보관)
find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} \;
```

## 모범 사례 및 보안

### 보안 체크리스트

1. **정기 업데이트**
   ```bash
   # 업데이트 확인
   git fetch origin
   git checkout tags/latest-stable-version
   
   # 의존성 업데이트
   composer update
   npm update
   ```

2. **데이터베이스 보안**
   ```sql
   -- 강력한 비밀번호 사용
   -- 데이터베이스 사용자 권한 제한
   -- SSL 연결 활성화
   SET GLOBAL require_secure_transport=ON;
   ```

3. **파일 시스템 보안**
   ```bash
   # 디렉토리 브라우징 비활성화
   echo "Options -Indexes" >> .htaccess
   
   # 민감한 파일 보호
   chmod 600 app/config/parameters.php
   chmod 600 .env
   ```

### 성능 모니터링

#### 모니터링 도구 설정
```bash
# 시스템 모니터링 설치
sudo apt install htop iotop nethogs

# 로그 순환 구성
sudo logrotate -d /etc/logrotate.d/prestashop

# 데이터베이스 모니터링 설정
mysql -e "SHOW PROCESSLIST; SHOW STATUS LIKE 'Slow_queries';"
```

## 결론

PrestaShop을 성공적으로 설치하고 구성하여 전자상거래 스토어를 위한 견고한 기반을 만들었습니다. 개발 편의성을 위한 Docker 방식을 선택했든 프로덕션 배포를 위한 전통적인 서버 설정을 선택했든, PrestaShop 설치가 이제 커스터마이징과 스토어 개발을 위한 준비가 완료되었습니다.

이 튜토리얼의 주요 성과:
- ✅ **완전한 설치**: PrestaShop 9.0 성공적으로 배포
- ✅ **보안 구성**: 필수 보안 조치 구현
- ✅ **성능 최적화**: 캐싱 및 최적화 설정 구성
- ✅ **개발 환경**: 테마 및 모듈 개발을 위한 도구 설정
- ✅ **문제 해결 지식**: 일반적인 설치 문제 해결 방법 학습

### 다음 단계

1. **스토어 커스터마이징**: 스토어 설정을 구성하고, 제품을 추가하고, 테마를 커스터마이징하세요
2. **결제 통합**: PayPal, Stripe 또는 지역 결제 방법과 같은 결제 게이트웨이를 설정하세요
3. **SEO 최적화**: URL 재작성, 메타 태그, 사이트맵 생성을 구성하세요
4. **모듈 개발**: 특정 비즈니스 요구사항을 위한 사용자 정의 모듈을 만드세요
5. **성능 튜닝**: 고급 캐싱 전략과 CDN 통합을 구현하세요

지속적인 학습을 위해 [PrestaShop DevDocs](https://devdocs.prestashop-project.org/)를 탐색하고 [GitHub](https://github.com/PrestaShop/PrestaShop)과 [Slack](https://www.prestashop-project.org/slack/)의 활발한 커뮤니티에 참여하세요.

PrestaShop과 함께하는 전자상거래 여정이 지금 시작됩니다 – 온라인 비즈니스를 구축하고, 커스터마이징하고, 성장시켜 나가세요!
