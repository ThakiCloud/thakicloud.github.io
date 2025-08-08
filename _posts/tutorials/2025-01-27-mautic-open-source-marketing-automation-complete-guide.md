---
title: "Mautic 오픈소스 마케팅 자동화 플랫폼 완벽 가이드: 설치부터 고급 활용까지"
excerpt: "Mautic은 강력한 오픈소스 마케팅 자동화 플랫폼입니다. 이메일 마케팅, 리드 관리, 캠페인 자동화를 무료로 구축하고 완전한 데이터 소유권을 확보하는 방법을 알아보세요."
seo_title: "Mautic 오픈소스 마케팅 자동화 완벽 설치 가이드 - 무료 대안 - Thaki Cloud"
seo_description: "Mautic 오픈소스 마케팅 자동화 플랫폼 설치부터 고급 활용까지 완벽 가이드. Docker, AWS 배포, 이메일 캠페인, 리드 스코링, API 연동 등 실무 중심의 튜토리얼을 제공합니다."
date: 2025-01-27
last_modified_at: 2025-01-27
categories:
  - tutorials
  - dev
tags:
  - mautic
  - marketing-automation
  - open-source
  - email-marketing
  - lead-management
  - campaign-automation
  - crm
  - docker
  - php
  - mysql
  - self-hosted
author_profile: true
toc: true
toc_label: "목차"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/tutorials/mautic-open-source-marketing-automation-complete-guide/"
reading_time: true
---

⏱️ **예상 읽기 시간**: 20분

## 서론

마케팅 자동화는 현대 비즈니스의 필수 요소가 되었지만, 상용 솔루션들의 높은 비용과 데이터 종속성은 많은 기업에게 부담이 됩니다. [Mautic](https://github.com/mautic/mautic)은 이러한 문제를 해결하는 강력한 오픈소스 대안으로, 완전한 데이터 소유권과 무제한 커스터마이징을 제공합니다.

이 가이드에서는 Mautic의 설치부터 고급 활용법까지 실무에 필요한 모든 것을 다루겠습니다. Mailchimp나 HubSpot 같은 상용 서비스에 월 수백 달러를 지불하는 대신, 자체 호스팅으로 완전한 통제권을 확보하는 방법을 알아보세요.

## Mautic 개요 및 특징

### 🎯 Mautic이란?

Mautic은 GPL 라이선스 하에 배포되는 완전 오픈소스 마케팅 자동화 플랫폼입니다. PHP로 개발되었으며, MySQL/MariaDB를 데이터베이스로 사용하여 다양한 환경에서 안정적으로 동작합니다.

#### 핵심 기능
```yaml
mautic_features:
  email_marketing:
    - "드래그 앤 드롭 이메일 빌더"
    - "A/B 테스팅"
    - "자동 응답 시퀀스"
    - "개인화된 콘텐츠"
  
  lead_management:
    - "리드 스코링"
    - "세그멘테이션"
    - "행동 추적"
    - "생애주기 관리"
  
  campaign_automation:
    - "멀티채널 캠페인"
    - "트리거 기반 자동화"
    - "워크플로우 빌더"
    - "조건부 액션"
  
  analytics_reporting:
    - "실시간 대시보드"
    - "ROI 추적"
    - "소스별 분석"
    - "커스텀 리포트"
```

### 🆚 상용 솔루션 대비 장점

| 항목 | Mautic | Mailchimp | HubSpot |
|------|--------|-----------|---------|
| **비용** | 무료 (호스팅만) | $10-299/월 | $45-3,200/월 |
| **데이터 소유권** | ✅ 완전 소유 | ❌ 제한적 | ❌ 제한적 |
| **커스터마이징** | ✅ 무제한 | ❌ 제한적 | 🔶 부분적 |
| **API 제한** | ✅ 없음 | ❌ 있음 | ❌ 있음 |
| **GDPR 준수** | ✅ 완전 통제 | 🔶 의존적 | 🔶 의존적 |

### 🏗️ 시스템 아키텍처

```python
# Mautic 시스템 구조
mautic_architecture = {
    "frontend": {
        "framework": "Symfony",
        "ui_components": ["Bootstrap", "jQuery"],
        "email_builder": "Drag & Drop Builder"
    },
    "backend": {
        "language": "PHP 8.1+",
        "framework": "Symfony 6.x",
        "database": "MySQL 8.0+ / MariaDB 10.4+",
        "cache": "Redis (선택사항)"
    },
    "integrations": {
        "email_providers": ["Amazon SES", "Mailgun", "SendGrid"],
        "crm_systems": ["Salesforce", "Pipedrive", "HubSpot"],
        "analytics": ["Google Analytics", "Matomo"],
        "storage": ["AWS S3", "Local Storage"]
    }
}
```

## 설치 방법

### 🐳 Docker를 이용한 빠른 설치 (권장)

#### Docker Compose 설정

```yaml
# docker-compose.yml
version: '3.8'

services:
  mautic:
    image: mautic/mautic:v5-apache
    container_name: mautic_app
    restart: unless-stopped
    ports:
      - "8080:80"
    environment:
      - MAUTIC_DB_HOST=mautic_db
      - MAUTIC_DB_USER=mautic
      - MAUTIC_DB_PASSWORD=mautic_password
      - MAUTIC_DB_NAME=mautic
      - MAUTIC_TRUSTED_PROXIES=0.0.0.0/0
    volumes:
      - mautic_data:/var/www/html
    depends_on:
      - mautic_db
      - mautic_redis

  mautic_db:
    image: mariadb:10.11
    container_name: mautic_database
    restart: unless-stopped
    environment:
      - MYSQL_ROOT_PASSWORD=root_password
      - MYSQL_DATABASE=mautic
      - MYSQL_USER=mautic
      - MYSQL_PASSWORD=mautic_password
    volumes:
      - db_data:/var/lib/mysql
    command: --default-authentication-plugin=mysql_native_password

  mautic_redis:
    image: redis:7-alpine
    container_name: mautic_cache
    restart: unless-stopped
    volumes:
      - redis_data:/data

volumes:
  mautic_data:
  db_data:
  redis_data:

networks:
  default:
    name: mautic_network
```

#### 실행 스크립트

```bash
#!/bin/bash
# install_mautic.sh

echo "🚀 Mautic 설치 시작..."

# Docker 및 Docker Compose 확인
if ! command -v docker &> /dev/null; then
    echo "❌ Docker가 설치되지 않았습니다."
    echo "Docker 설치: https://docs.docker.com/get-docker/"
    exit 1
fi

if ! command -v docker-compose &> /dev/null; then
    echo "❌ Docker Compose가 설치되지 않았습니다."
    echo "Docker Compose 설치: https://docs.docker.com/compose/install/"
    exit 1
fi

# 작업 디렉토리 생성
mkdir -p mautic-setup
cd mautic-setup

# Docker Compose 파일 다운로드 (위의 내용을 파일로 저장)
curl -o docker-compose.yml https://raw.githubusercontent.com/mautic/docker-mautic/main/examples/basic/docker-compose.yml

# 환경 설정
echo "MAUTIC_DB_PASSWORD=$(openssl rand -base64 32)" > .env
echo "MYSQL_ROOT_PASSWORD=$(openssl rand -base64 32)" >> .env

# 컨테이너 시작
docker-compose up -d

echo "✅ Mautic 설치 완료!"
echo "📍 접속 URL: http://localhost:8080"
echo "⏳ 초기화 완료까지 약 2-3분 소요됩니다."

# 로그 확인
echo "📊 실시간 로그 확인:"
docker-compose logs -f mautic
```

### 💻 전통적인 설치 방법

#### 시스템 요구사항

```bash
# Ubuntu 22.04 기준 설치
sudo apt update

# 필수 패키지 설치
sudo apt install -y \
    apache2 \
    php8.1 \
    php8.1-cli \
    php8.1-common \
    php8.1-curl \
    php8.1-gd \
    php8.1-mbstring \
    php8.1-mysql \
    php8.1-xml \
    php8.1-intl \
    php8.1-zip \
    php8.1-imap \
    php8.1-soap \
    libapache2-mod-php8.1 \
    mariadb-server \
    unzip \
    wget
```

#### MariaDB 설정

```sql
-- MariaDB 보안 설정
sudo mysql_secure_installation

-- Mautic 데이터베이스 생성
sudo mysql -u root -p

CREATE DATABASE mautic CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'mautic'@'localhost' IDENTIFIED BY 'secure_password_here';
GRANT ALL PRIVILEGES ON mautic.* TO 'mautic'@'localhost';
FLUSH PRIVILEGES;
EXIT;
```

#### Mautic 다운로드 및 설정

```bash
# 웹 루트로 이동
cd /var/www

# 최신 Mautic 다운로드
sudo wget https://github.com/mautic/mautic/releases/latest/download/mautic.zip

# 압축 해제
sudo unzip mautic.zip -d mautic/
sudo rm mautic.zip

# 권한 설정
sudo chown -R www-data:www-data /var/www/mautic/
sudo chmod -R 755 /var/www/mautic/
sudo chmod -R 775 /var/www/mautic/var/

# Apache 가상 호스트 설정
sudo tee /etc/apache2/sites-available/mautic.conf << 'EOF'
<VirtualHost *:80>
    ServerName your-domain.com
    DocumentRoot /var/www/mautic
    
    <Directory /var/www/mautic>
        DirectoryIndex index.php
        Options FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/mautic_error.log
    CustomLog ${APACHE_LOG_DIR}/mautic_access.log combined
</VirtualHost>
EOF

# 사이트 활성화
sudo a2ensite mautic.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
```

### ☁️ AWS EC2 자동 배포

```bash
#!/bin/bash
# aws_deploy_mautic.sh

echo "🌥️ AWS EC2에 Mautic 자동 배포"

# 인스턴스 생성 (t3.medium 권장)
aws ec2 run-instances \
    --image-id ami-0c02fb55956c7d316 \
    --count 1 \
    --instance-type t3.medium \
    --key-name your-key-pair \
    --security-group-ids sg-your-security-group \
    --subnet-id subnet-your-subnet \
    --user-data file://user-data.sh \
    --tag-specifications 'ResourceType=instance,Tags=[{Key=Name,Value=Mautic-Server}]'

# User Data 스크립트 (user-data.sh)
cat > user-data.sh << 'EOF'
#!/bin/bash
yum update -y
yum install -y docker

# Docker 시작
systemctl start docker
systemctl enable docker
usermod -a -G docker ec2-user

# Docker Compose 설치
curl -L "https://github.com/docker/compose/releases/latest/download/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Mautic 설정
mkdir -p /opt/mautic
cd /opt/mautic

# Docker Compose 파일 생성 (앞서 제공한 내용)
# ... docker-compose.yml 내용 ...

# Mautic 시작
docker-compose up -d

echo "Mautic이 성공적으로 설치되었습니다!"
EOF
```

## 초기 설정 및 구성

### 🎛️ 웹 인터페이스 설정

#### 1. 데이터베이스 연결 설정

```php
// app/config/local.php 예제
<?php
$parameters = array(
    'db_driver' => 'pdo_mysql',
    'db_host' => 'localhost',
    'db_port' => 3306,
    'db_name' => 'mautic',
    'db_user' => 'mautic',
    'db_password' => 'your_secure_password',
    'db_table_prefix' => null,
    
    'mailer_from_name' => 'Your Company',
    'mailer_from_email' => 'noreply@yourcompany.com',
    'mailer_transport' => 'smtp',
    'mailer_host' => 'smtp.mailgun.org',
    'mailer_port' => 587,
    'mailer_user' => 'your_smtp_user',
    'mailer_password' => 'your_smtp_password',
    'mailer_encryption' => 'tls',
    'mailer_auth_mode' => 'login',
    
    'secret_key' => 'generated_secret_key_here',
    'site_url' => 'https://your-mautic-domain.com',
    'cache_path' => '%kernel.project_dir%/var/cache',
    'log_path' => '%kernel.project_dir%/var/logs',
    'image_path' => 'media/images',
    'tmp_path' => '%kernel.project_dir%/var/tmp',
);
```

#### 2. 관리자 계정 생성

```bash
# CLI를 통한 관리자 계정 생성
php bin/console mautic:user:create \
    --first-name="Admin" \
    --last-name="User" \
    --username="admin" \
    --email="admin@yourcompany.com" \
    --password="SecurePassword123!" \
    --role="administrator"
```

### 📧 이메일 설정

#### SMTP 제공업체별 설정

```yaml
# Amazon SES 설정
amazon_ses:
  transport: ses
  host: email-smtp.us-east-1.amazonaws.com
  port: 587
  username: YOUR_SES_ACCESS_KEY
  password: YOUR_SES_SECRET_KEY
  encryption: tls

# Mailgun 설정  
mailgun:
  transport: mailgun
  host: smtp.mailgun.org
  port: 587
  username: postmaster@mg.yourdomain.com
  password: YOUR_MAILGUN_SMTP_PASSWORD
  encryption: tls

# SendGrid 설정
sendgrid:
  transport: smtp
  host: smtp.sendgrid.net
  port: 587
  username: apikey
  password: YOUR_SENDGRID_API_KEY
  encryption: tls
```

#### 이메일 인증 설정

```bash
# SPF 레코드 (DNS)
v=spf1 include:mailgun.org include:amazonses.com ~all

# DKIM 설정 (Mautic CLI)
php bin/console mautic:email:configure-dkim \
    --domain=yourdomain.com \
    --selector=mautic \
    --private-key-path=/path/to/private.key

# DMARC 레코드
v=DMARC1; p=quarantine; rua=mailto:dmarc@yourdomain.com
```

### 🔧 성능 최적화 설정

#### Cron Job 설정

```bash
# crontab -e로 추가
# 세그먼트 업데이트 (매 15분)
*/15 * * * * /usr/bin/php /var/www/mautic/bin/console mautic:segments:update

# 캠페인 실행 (매 5분)
*/5 * * * * /usr/bin/php /var/www/mautic/bin/console mautic:campaigns:trigger

# 이메일 발송 (매 2분)
*/2 * * * * /usr/bin/php /var/www/mautic/bin/console mautic:emails:send

# 소셜 미디어 모니터링 (매 10분)
*/10 * * * * /usr/bin/php /var/www/mautic/bin/console mautic:social:monitoring

# 정리 작업 (매일 새벽 2시)
0 2 * * * /usr/bin/php /var/www/mautic/bin/console mautic:maintenance:cleanup --days-old=365
```

#### Redis 캐시 설정

```php
// app/config/local.php에 추가
'cache_adapter' => 'mautic.cache.adapter.redis',
'cache_prefix' => 'mautic',
'redis_host' => '127.0.0.1',
'redis_port' => 6379,
'redis_password' => null,
'redis_database' => 1,
```

## 기본 기능 활용

### 👥 리드 관리

#### 리드 가져오기 및 세그멘테이션

```php
// API를 통한 리드 생성 예제
$leadApi = $this->getApiContext('leads');

$data = [
    'firstname' => 'John',
    'lastname' => 'Doe',
    'email' => 'john.doe@example.com',
    'company' => 'Example Corp',
    'tags' => ['vip', 'enterprise'],
    'customFields' => [
        'industry' => 'Technology',
        'budget' => '50000'
    ]
];

$lead = $leadApi->create($data);
```

#### 스마트 세그먼테이션

```yaml
# 고가치 리드 세그먼트 설정
high_value_segment:
  name: "High Value Prospects"
  filters:
    - field: "lead_score"
      operator: "gte"
      value: 75
    - field: "company_size"
      operator: "in"
      value: ["Enterprise", "Large"]
    - field: "budget"
      operator: "gte"
      value: 10000
  
  actions:
    - assign_to_owner: "sales_manager@company.com"
    - add_to_campaign: "Enterprise Nurture Campaign"
    - send_email: "VIP Welcome Email"
```

### 📧 이메일 캠페인

#### 드래그 앤 드롭 이메일 빌더

```html
<!-- 이메일 템플릿 예제 -->
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <title>{subject}</title>
</head>
<body>
    <div class="email-container" style="max-width: 600px; margin: 0 auto;">
        <header style="background: #007bff; color: white; padding: 20px;">
            <h1>Hello {contactfield=firstname|Dear Valued Customer}!</h1>
        </header>
        
        <main style="padding: 20px;">
            <p>Thank you for your interest in our products.</p>
            
            <!-- 개인화된 콘텐츠 -->
            {dynamiccontent="Product Recommendations"}
                {if company == "Enterprise"}
                    <div>Enterprise-specific content here</div>
                {else}
                    <div>Standard content here</div>
                {/if}
            {/dynamiccontent}
            
            <!-- CTA 버튼 -->
            <div style="text-align: center; margin: 30px 0;">
                <a href="{mautic:url}" 
                   style="background: #28a745; color: white; padding: 15px 30px; 
                          text-decoration: none; border-radius: 5px;">
                    Get Started Today
                </a>
            </div>
        </main>
        
        <footer style="background: #f8f9fa; padding: 20px; text-align: center;">
            <p>
                <a href="{unsubscribe_url}">Unsubscribe</a> | 
                <a href="{webview_url}">View in Browser</a>
            </p>
        </footer>
    </div>
</body>
</html>
```

#### A/B 테스팅 설정

```python
# A/B 테스트 캠페인 설정
ab_test_config = {
    "name": "Subject Line A/B Test",
    "test_type": "subject",
    "variants": {
        "variant_a": {
            "name": "Control",
            "subject": "Don't Miss This Limited Offer!",
            "percentage": 40
        },
        "variant_b": {
            "name": "Variant",
            "subject": "Exclusive Offer Inside - Act Now!",
            "percentage": 40
        }
    },
    "winner_criteria": "open_rate",
    "test_duration": "4 hours",
    "winner_percentage": 20
}
```

### 🎯 마케팅 자동화

#### 드립 캠페인 워크플로우

```yaml
# 온보딩 드립 캠페인
onboarding_campaign:
  name: "New User Onboarding"
  trigger: "form_submission"
  form_id: "newsletter_signup"
  
  workflow:
    day_0:
      - action: "send_email"
        template: "welcome_email"
        delay: "immediate"
    
    day_3:
      - action: "check_engagement"
        condition: "email_opened"
        if_true:
          - send_email: "getting_started_guide"
        if_false:
          - send_email: "re_engagement_email"
    
    day_7:
      - action: "send_email"
        template: "success_stories"
        condition: "not_unsubscribed"
    
    day_14:
      - action: "assign_score"
        points: 10
      - action: "add_to_segment"
        segment: "engaged_users"
```

#### 리드 스코링 모델

```php
// 리드 스코링 규칙 설정
$scoringRules = [
    [
        'name' => 'Email Open',
        'points' => 5,
        'trigger' => 'email.open'
    ],
    [
        'name' => 'Link Click',
        'points' => 10,
        'trigger' => 'email.click'
    ],
    [
        'name' => 'Form Submission',
        'points' => 25,
        'trigger' => 'form.submit'
    ],
    [
        'name' => 'Page Visit - Pricing',
        'points' => 15,
        'trigger' => 'page.hit',
        'conditions' => [
            'url' => 'contains:/pricing'
        ]
    ],
    [
        'name' => 'Download Whitepaper',
        'points' => 20,
        'trigger' => 'asset.download'
    ]
];
```

## 고급 활용법

### 🔌 API 연동

#### REST API 기본 사용법

```python
import requests
import base64

class MauticAPI:
    def __init__(self, base_url, username, password):
        self.base_url = base_url.rstrip('/')
        self.session = requests.Session()
        
        # Basic Auth 설정
        credentials = base64.b64encode(f"{username}:{password}".encode()).decode()
        self.session.headers.update({
            'Authorization': f'Basic {credentials}',
            'Content-Type': 'application/json'
        })
    
    def get_contacts(self, search=None, limit=100):
        """연락처 목록 조회"""
        params = {'limit': limit}
        if search:
            params['search'] = search
            
        response = self.session.get(
            f'{self.base_url}/api/contacts',
            params=params
        )
        return response.json()
    
    def create_contact(self, contact_data):
        """새 연락처 생성"""
        response = self.session.post(
            f'{self.base_url}/api/contacts/new',
            json=contact_data
        )
        return response.json()
    
    def update_contact(self, contact_id, data):
        """연락처 정보 업데이트"""
        response = self.session.patch(
            f'{self.base_url}/api/contacts/{contact_id}/edit',
            json=data
        )
        return response.json()
    
    def send_email(self, email_id, contact_id):
        """개별 이메일 발송"""
        data = {
            'lead': contact_id,
            'email': email_id
        }
        response = self.session.post(
            f'{self.base_url}/api/emails/{email_id}/contact/{contact_id}/send',
            json=data
        )
        return response.json()

# 사용 예제
mautic = MauticAPI('https://your-mautic.com', 'admin', 'password')

# 새 연락처 생성
new_contact = {
    'firstname': 'Jane',
    'lastname': 'Smith',
    'email': 'jane.smith@example.com',
    'company': 'Tech Startup',
    'customFields': {
        'industry': 'SaaS',
        'lead_source': 'webinar'
    }
}

result = mautic.create_contact(new_contact)
print(f"Contact created with ID: {result['contact']['id']}")
```

#### Webhook 설정

```php
// webhook_handler.php
<?php
header('Content-Type: application/json');

// Mautic에서 전송된 데이터 수신
$input = file_get_contents('php://input');
$data = json_decode($input, true);

// 보안을 위한 시크릿 키 검증
$expectedSignature = hash_hmac('sha256', $input, 'your_webhook_secret');
$receivedSignature = $_SERVER['HTTP_X_MAUTIC_SIGNATURE'] ?? '';

if (!hash_equals($expectedSignature, $receivedSignature)) {
    http_response_code(401);
    exit('Unauthorized');
}

// 이벤트 타입별 처리
switch ($data['mautic.webhook_event']) {
    case 'email_on_open':
        handleEmailOpen($data);
        break;
        
    case 'form_on_submit':
        handleFormSubmission($data);
        break;
        
    case 'page_on_hit':
        handlePageHit($data);
        break;
        
    default:
        error_log("Unknown webhook event: " . $data['mautic.webhook_event']);
}

function handleEmailOpen($data) {
    // 이메일 열람 처리 로직
    $contactId = $data['contact']['id'];
    $emailId = $data['email']['id'];
    
    // 외부 CRM 시스템에 동기화
    syncToCRM('email_open', [
        'contact_id' => $contactId,
        'email_id' => $emailId,
        'timestamp' => $data['timestamp']
    ]);
}

function handleFormSubmission($data) {
    // 폼 제출 처리 로직
    $formData = $data['submission']['results'];
    
    // Slack 알림 발송
    sendSlackNotification("New lead: " . $formData['email']);
    
    // 즉시 후속 액션 트리거
    triggerFollowUpAction($data['contact']['id']);
}

http_response_code(200);
echo json_encode(['status' => 'success']);
?>
```

### 🎨 커스텀 플러그인 개발

#### 플러그인 구조

```php
// plugins/CustomIntegrationBundle/CustomIntegrationBundle.php
<?php
namespace MauticPlugin\CustomIntegrationBundle;

use Mautic\PluginBundle\Bundle\PluginBundleBase;

class CustomIntegrationBundle extends PluginBundleBase
{
    public function getParent()
    {
        return 'MauticCoreBundle';
    }
}
```

```php
// plugins/CustomIntegrationBundle/Config/config.php
<?php
return [
    'name' => 'Custom Integration',
    'description' => 'Custom integration with external services',
    'version' => '1.0.0',
    'author' => 'Your Company',
    
    'routes' => [
        'main' => [
            'mautic_custom_integration_index' => [
                'path' => '/custom-integration',
                'controller' => 'CustomIntegrationBundle:Default:index'
            ]
        ]
    ],
    
    'services' => [
        'events' => [
            'mautic.custom.integration.subscriber' => [
                'class' => 'MauticPlugin\CustomIntegrationBundle\EventListener\IntegrationSubscriber',
                'arguments' => ['@mautic.helper.integration']
            ]
        ]
    ]
];
```

### 📊 고급 분석 및 리포팅

#### 커스텀 대시보드 생성

```javascript
// 실시간 대시보드 위젯
class MauticDashboard {
    constructor() {
        this.widgets = [];
        this.updateInterval = 30000; // 30초
        this.init();
    }
    
    init() {
        this.createWidgets();
        this.startAutoUpdate();
    }
    
    createWidgets() {
        // 리드 스코어 분포 차트
        this.addWidget('lead-score-distribution', {
            type: 'doughnut',
            endpoint: '/api/reports/lead-scores',
            title: 'Lead Score Distribution'
        });
        
        // 이메일 성과 추이
        this.addWidget('email-performance', {
            type: 'line',
            endpoint: '/api/reports/email-stats',
            title: 'Email Performance Trend'
        });
        
        // 캠페인 ROI
        this.addWidget('campaign-roi', {
            type: 'bar',
            endpoint: '/api/reports/campaign-roi',
            title: 'Campaign ROI'
        });
    }
    
    addWidget(id, config) {
        const widget = new DashboardWidget(id, config);
        this.widgets.push(widget);
        widget.render();
    }
    
    startAutoUpdate() {
        setInterval(() => {
            this.widgets.forEach(widget => widget.update());
        }, this.updateInterval);
    }
}

class DashboardWidget {
    constructor(id, config) {
        this.id = id;
        this.config = config;
        this.chart = null;
    }
    
    async fetchData() {
        try {
            const response = await fetch(this.config.endpoint);
            return await response.json();
        } catch (error) {
            console.error(`Error fetching data for ${this.id}:`, error);
            return null;
        }
    }
    
    async render() {
        const data = await this.fetchData();
        if (!data) return;
        
        const ctx = document.getElementById(this.id);
        this.chart = new Chart(ctx, {
            type: this.config.type,
            data: data,
            options: {
                responsive: true,
                plugins: {
                    title: {
                        display: true,
                        text: this.config.title
                    }
                }
            }
        });
    }
    
    async update() {
        const data = await this.fetchData();
        if (data && this.chart) {
            this.chart.data = data;
            this.chart.update();
        }
    }
}

// 대시보드 초기화
document.addEventListener('DOMContentLoaded', () => {
    new MauticDashboard();
});
```

## 운영 및 최적화

### 🚀 성능 최적화

#### 데이터베이스 튜닝

```sql
-- MySQL/MariaDB 최적화 설정
-- /etc/mysql/conf.d/mautic.cnf

[mysqld]
# 메모리 설정 (16GB RAM 기준)
innodb_buffer_pool_size = 12G
innodb_log_file_size = 1G
innodb_log_buffer_size = 64M

# 연결 설정
max_connections = 500
max_connect_errors = 10000
connect_timeout = 10
wait_timeout = 600
interactive_timeout = 600

# 쿼리 캐시
query_cache_type = 1
query_cache_size = 256M
query_cache_limit = 2M

# 인덱스 최적화
key_buffer_size = 512M
table_open_cache = 2000
sort_buffer_size = 4M
read_buffer_size = 2M
read_rnd_buffer_size = 8M

# 로그 설정
slow_query_log = 1
slow_query_log_file = /var/log/mysql/slow.log
long_query_time = 2
```

#### PHP 최적화

```ini
; /etc/php/8.1/apache2/php.ini
memory_limit = 512M
max_execution_time = 300
max_input_time = 300
post_max_size = 64M
upload_max_filesize = 64M
max_file_uploads = 100

; OPcache 설정
opcache.enable = 1
opcache.memory_consumption = 256
opcache.interned_strings_buffer = 16
opcache.max_accelerated_files = 10000
opcache.validate_timestamps = 0
opcache.save_comments = 1
opcache.fast_shutdown = 1

; Session 설정
session.gc_maxlifetime = 86400
session.save_handler = redis
session.save_path = "tcp://127.0.0.1:6379"
```

### 🔒 보안 강화

#### 보안 설정 체크리스트

```bash
#!/bin/bash
# mautic_security_check.sh

echo "🔒 Mautic 보안 점검 시작..."

# 1. 파일 권한 점검
echo "📁 파일 권한 점검..."
find /var/www/mautic -type f -exec chmod 644 {} \;
find /var/www/mautic -type d -exec chmod 755 {} \;
chmod -R 775 /var/www/mautic/var/
chown -R www-data:www-data /var/www/mautic

# 2. 민감한 파일 보호
echo "🛡️ 민감한 파일 보호..."
cat > /var/www/mautic/.htaccess << 'EOF'
# 민감한 파일 접근 차단
<Files "composer.json">
    Require all denied
</Files>
<Files "composer.lock">
    Require all denied
</Files>
<FilesMatch "\.env">
    Require all denied
</FilesMatch>

# 디렉토리 브라우징 차단
Options -Indexes

# PHP 실행 차단 (업로드 폴더)
<Directory "/var/www/mautic/media/files">
    php_admin_flag engine off
</Directory>
EOF

# 3. SSL/TLS 설정 점검
echo "🔐 SSL/TLS 설정 점검..."
if ! command -v certbot &> /dev/null; then
    echo "⚠️ Certbot이 설치되지 않았습니다."
    echo "Let's Encrypt 설치: sudo apt install certbot python3-certbot-apache"
fi

# 4. 방화벽 설정
echo "🔥 방화벽 설정..."
ufw enable
ufw allow 22    # SSH
ufw allow 80    # HTTP
ufw allow 443   # HTTPS
ufw deny 3306   # MySQL (외부 접근 차단)

# 5. 로그 모니터링 설정
echo "📊 로그 모니터링 설정..."
cat > /etc/logrotate.d/mautic << 'EOF'
/var/www/mautic/var/logs/*.log {
    daily
    missingok
    rotate 52
    compress
    delaycompress
    notifempty
    create 644 www-data www-data
}
EOF

echo "✅ 보안 점검 완료!"
```

#### 침입 탐지 시스템

```python
# security_monitor.py
import re
import time
from datetime import datetime, timedelta
import smtplib
from email.mime.text import MIMEText

class SecurityMonitor:
    def __init__(self):
        self.log_file = '/var/www/mautic/var/logs/prod.log'
        self.alert_patterns = [
            r'Failed login attempt',
            r'SQL injection attempt',
            r'Unauthorized access to',
            r'Brute force attack detected',
            r'Suspicious file upload'
        ]
        self.alert_email = 'admin@yourcompany.com'
        
    def monitor_logs(self):
        """실시간 로그 모니터링"""
        with open(self.log_file, 'r') as f:
            f.seek(0, 2)  # 파일 끝으로 이동
            
            while True:
                line = f.readline()
                if line:
                    self.check_security_event(line.strip())
                else:
                    time.sleep(1)
    
    def check_security_event(self, log_line):
        """보안 이벤트 검사"""
        for pattern in self.alert_patterns:
            if re.search(pattern, log_line, re.IGNORECASE):
                self.send_alert(log_line, pattern)
                break
    
    def send_alert(self, log_line, pattern):
        """보안 알림 발송"""
        subject = f"Mautic Security Alert: {pattern}"
        body = f"""
        보안 이벤트가 감지되었습니다.
        
        시간: {datetime.now()}
        패턴: {pattern}
        로그: {log_line}
        
        즉시 확인이 필요합니다.
        """
        
        msg = MIMEText(body)
        msg['Subject'] = subject
        msg['From'] = 'security@yourcompany.com'
        msg['To'] = self.alert_email
        
        # SMTP 서버를 통해 이메일 발송
        # 설정에 맞게 수정 필요
        try:
            server = smtplib.SMTP('localhost')
            server.send_message(msg)
            server.quit()
        except Exception as e:
            print(f"Alert email failed: {e}")

if __name__ == '__main__':
    monitor = SecurityMonitor()
    monitor.monitor_logs()
```

### 📈 모니터링 및 백업

#### 자동 백업 시스템

```bash
#!/bin/bash
# mautic_backup.sh

# 설정
BACKUP_DIR="/backup/mautic"
MAUTIC_DIR="/var/www/mautic"
DB_NAME="mautic"
DB_USER="mautic"
DB_PASS="your_password"
RETENTION_DAYS=30
S3_BUCKET="your-backup-bucket"

# 백업 디렉토리 생성
mkdir -p "$BACKUP_DIR"

# 날짜별 백업 폴더
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_PATH="$BACKUP_DIR/$DATE"
mkdir -p "$BACKUP_PATH"

echo "🗄️ Mautic 백업 시작: $DATE"

# 1. 데이터베이스 백업
echo "📊 데이터베이스 백업..."
mysqldump -u"$DB_USER" -p"$DB_PASS" "$DB_NAME" | gzip > "$BACKUP_PATH/database.sql.gz"

# 2. 파일 백업 (미디어 파일 포함)
echo "📁 파일 시스템 백업..."
tar -czf "$BACKUP_PATH/files.tar.gz" \
    --exclude="$MAUTIC_DIR/var/cache/*" \
    --exclude="$MAUTIC_DIR/var/logs/*" \
    --exclude="$MAUTIC_DIR/var/tmp/*" \
    "$MAUTIC_DIR"

# 3. 설정 파일 백업
echo "⚙️ 설정 파일 백업..."
cp "$MAUTIC_DIR/app/config/local.php" "$BACKUP_PATH/"
cp "/etc/apache2/sites-available/mautic.conf" "$BACKUP_PATH/"

# 4. 백업 압축
echo "🗜️ 백업 압축..."
cd "$BACKUP_DIR"
tar -czf "mautic_backup_$DATE.tar.gz" "$DATE/"
rm -rf "$DATE"

# 5. AWS S3 업로드 (선택사항)
if command -v aws &> /dev/null && [ -n "$S3_BUCKET" ]; then
    echo "☁️ S3 업로드..."
    aws s3 cp "mautic_backup_$DATE.tar.gz" "s3://$S3_BUCKET/mautic/"
fi

# 6. 오래된 백업 정리
echo "🧹 오래된 백업 정리..."
find "$BACKUP_DIR" -name "mautic_backup_*.tar.gz" -mtime +$RETENTION_DAYS -delete

# 백업 크기 확인
BACKUP_SIZE=$(du -h "mautic_backup_$DATE.tar.gz" | cut -f1)
echo "✅ 백업 완료: mautic_backup_$DATE.tar.gz ($BACKUP_SIZE)"

# 백업 무결성 검사
if tar -tzf "mautic_backup_$DATE.tar.gz" &>/dev/null; then
    echo "✅ 백업 무결성 확인됨"
else
    echo "❌ 백업 파일 손상!"
    exit 1
fi
```

## 문제 해결

### 🔧 일반적인 문제들

#### 이메일 발송 문제

```bash
# 이메일 큐 상태 확인
php bin/console mautic:emails:send --show-messages

# SMTP 연결 테스트
php bin/console mautic:email:test \
    --to=test@example.com \
    --subject="Test Email"

# 이메일 스풀 초기화
php bin/console mautic:email:spool:clear
```

#### 성능 문제 진단

```sql
-- 느린 쿼리 분석
SELECT * FROM information_schema.processlist 
WHERE time > 10 AND command != 'Sleep';

-- 인덱스 사용률 확인
SHOW INDEX FROM leads WHERE cardinality < 10;

-- 테이블 크기 확인
SELECT 
    table_name,
    ROUND(((data_length + index_length) / 1024 / 1024), 2) AS 'Size (MB)'
FROM information_schema.tables 
WHERE table_schema = 'mautic'
ORDER BY (data_length + index_length) DESC;
```

#### 로그 분석 도구

```python
# mautic_log_analyzer.py
import re
from collections import defaultdict, Counter
from datetime import datetime

class MauticLogAnalyzer:
    def __init__(self, log_file):
        self.log_file = log_file
        self.errors = []
        self.warnings = []
        self.performance_issues = []
        
    def analyze(self):
        """로그 파일 분석"""
        with open(self.log_file, 'r') as f:
            for line_num, line in enumerate(f, 1):
                self.parse_line(line_num, line.strip())
        
        return self.generate_report()
    
    def parse_line(self, line_num, line):
        """각 로그 라인 파싱"""
        # 에러 패턴
        if re.search(r'\[ERROR\]', line):
            self.errors.append({
                'line': line_num,
                'content': line,
                'timestamp': self.extract_timestamp(line)
            })
        
        # 경고 패턴
        elif re.search(r'\[WARNING\]', line):
            self.warnings.append({
                'line': line_num,
                'content': line,
                'timestamp': self.extract_timestamp(line)
            })
        
        # 성능 이슈 패턴
        elif re.search(r'Query took (\d+)ms', line):
            match = re.search(r'Query took (\d+)ms', line)
            if match and int(match.group(1)) > 5000:  # 5초 이상
                self.performance_issues.append({
                    'line': line_num,
                    'content': line,
                    'duration': int(match.group(1))
                })
    
    def extract_timestamp(self, line):
        """타임스탬프 추출"""
        match = re.search(r'\[(\d{4}-\d{2}-\d{2} \d{2}:\d{2}:\d{2})\]', line)
        if match:
            return datetime.strptime(match.group(1), '%Y-%m-%d %H:%M:%S')
        return None
    
    def generate_report(self):
        """분석 리포트 생성"""
        return {
            'summary': {
                'total_errors': len(self.errors),
                'total_warnings': len(self.warnings),
                'performance_issues': len(self.performance_issues)
            },
            'top_errors': self.get_top_errors(),
            'performance_summary': self.get_performance_summary(),
            'recommendations': self.get_recommendations()
        }
    
    def get_top_errors(self):
        """자주 발생하는 에러 TOP 10"""
        error_patterns = [re.sub(r'\d+', 'N', err['content']) for err in self.errors]
        return Counter(error_patterns).most_common(10)
    
    def get_performance_summary(self):
        """성능 이슈 요약"""
        if not self.performance_issues:
            return "성능 이슈 없음"
        
        durations = [issue['duration'] for issue in self.performance_issues]
        return {
            'max_duration': max(durations),
            'avg_duration': sum(durations) / len(durations),
            'count': len(durations)
        }
    
    def get_recommendations(self):
        """개선 권장사항"""
        recommendations = []
        
        if len(self.errors) > 100:
            recommendations.append("에러 발생률이 높습니다. 코드 검토 필요")
        
        if len(self.performance_issues) > 50:
            recommendations.append("데이터베이스 쿼리 최적화 필요")
        
        return recommendations

# 사용 예제
if __name__ == '__main__':
    analyzer = MauticLogAnalyzer('/var/www/mautic/var/logs/prod.log')
    report = analyzer.analyze()
    
    print("📊 Mautic 로그 분석 리포트")
    print("=" * 40)
    print(f"총 에러: {report['summary']['total_errors']}")
    print(f"총 경고: {report['summary']['total_warnings']}")
    print(f"성능 이슈: {report['summary']['performance_issues']}")
```

## 결론

Mautic은 마케팅 자동화 영역에서 강력한 오픈소스 대안을 제공합니다. 이 가이드를 통해 Mautic의 설치부터 고급 활용까지 모든 과정을 다뤘습니다.

### 🎯 주요 이점 요약

- **비용 절약**: 월 수백 달러의 라이선스 비용 없이 동일한 기능 제공
- **데이터 소유권**: 완전한 데이터 통제권과 GDPR 준수
- **무제한 확장**: 사용자, 연락처, 이메일 발송량 제한 없음
- **커스터마이징**: 소스 코드 수준의 완전한 커스터마이징 가능

### 🚀 다음 단계

1. **파일럿 프로젝트**: 작은 규모의 캠페인으로 시작
2. **팀 교육**: 마케팅 팀을 위한 Mautic 교육 실시
3. **점진적 확장**: 성공 사례를 바탕으로 사용 범위 확대
4. **커뮤니티 참여**: Mautic 커뮤니티 활동 및 기여

### 📚 추가 학습 자료

- [Mautic 공식 문서](https://docs.mautic.org/)
- [Mautic 커뮤니티 포럼](https://forum.mautic.org/)
- [GitHub 저장소](https://github.com/mautic/mautic)
- [Mautic 마케팅 자동화 가이드](https://www.mautic.org/resource-center)

Mautic을 통해 마케팅 자동화의 새로운 차원을 경험해보세요. 오픈소스의 힘으로 더 나은 마케팅 성과를 달성할 수 있습니다.

---

**더 알아보기:**
- [Mautic 공식 웹사이트](https://www.mautic.org/)
- [Mautic GitHub Repository](https://github.com/mautic/mautic)
- [Docker Hub - Mautic](https://hub.docker.com/r/mautic/mautic)
- [Mautic 개발자 문서](https://developer.mautic.org/)
