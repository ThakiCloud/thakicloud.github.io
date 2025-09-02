---
title: "دليل تثبيت PrestaShop الشامل: بناء متجر التجارة الإلكترونية من البداية"
excerpt: "دليل تفصيلي خطوة بخطوة لتثبيت وتكوين منصة PrestaShop 9.0 للتجارة الإلكترونية مع Docker و PHP و MySQL. دليل مثالي للمبتدئين لبناء متجرهم الإلكتروني الأول."
seo_title: "دليل تثبيت PrestaShop 2025 - دليل الإعداد الشامل - Thaki Cloud"
seo_description: "تعلم كيفية تثبيت منصة PrestaShop 9.0 للتجارة الإلكترونية خطوة بخطوة. يتضمن إعداد Docker وتكوين قاعدة البيانات وأفضل الممارسات لتطوير المتاجر الإلكترونية."
date: 2025-09-02
categories:
  - tutorials
tags:
  - prestashop
  - التجارة الإلكترونية
  - php
  - docker
  - mysql
  - التثبيت
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/prestashop-complete-setup-installation-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/prestashop-complete-setup-installation-guide/"
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة

PrestaShop هي منصة قوية مفتوحة المصدر للتجارة الإلكترونية تمكنك من بناء متاجر إلكترونية احترافية مع ميزات متقدمة مثل دعم اللغات المتعددة وتكامل بوابات الدفع وإدارة المخزون الشاملة. في هذا الدليل الشامل، ستتعلم كيفية تثبيت وتكوين PrestaShop 9.0 من البداية، سواء كنت تستخدم إعداد الخادم التقليدي أو حاويات Docker الحديثة.

مع أكثر من 8.7 ألف نجمة على GitHub ودعم مجتمعي نشط، أثبت PrestaShop نفسه كواحد من الحلول الرائدة للتجارة الإلكترونية للشركات من جميع الأحجام. سيرشدك هذا الدليل خلال كل خطوة من خطوات عملية التثبيت، مما يضمن حصولك على متجر إلكتروني يعمل بكامل طاقته وجاهز للتخصيص.

## المتطلبات الأساسية ومتطلبات النظام

قبل بدء التثبيت، تأكد من أن نظامك يلبي المتطلبات التالية:

### متطلبات الخادم
- **PHP**: الإصدار 8.1 أو أحدث
- **قاعدة البيانات**: MySQL 5.6+ أو MariaDB أو Percona Server
- **خادم الويب**: Apache أو Nginx (مُوصى به)
- **الذاكرة**: الحد الأدنى 512MB RAM (2GB+ مُوصى به للإنتاج)
- **التخزين**: ما لا يقل عن 1GB مساحة قرص حرة

### متطلبات بيئة التطوير
- **Docker**: الإصدار الأحدث (للإعداد المبني على الحاويات)
- **Git**: لاستنساخ المستودع
- **محرر النصوص**: VS Code أو PhpStorm أو أدوات مشابهة
- **أداة إدارة قاعدة البيانات**: phpMyAdmin (اختياري لكنه موصى به)

### تكوين النظام الموصى به
```bash
# لأنظمة Ubuntu/Debian
sudo apt update && sudo apt upgrade -y
sudo apt install php8.1 php8.1-mysql php8.1-curl php8.1-gd php8.1-mbstring php8.1-xml php8.1-zip
sudo apt install mysql-server nginx git curl
```

## طريقة التثبيت 1: إعداد Docker (موصى به للتطوير)

يوفر Docker أسرع وأموثق طريقة لتشغيل PrestaShop، خاصة لأغراض التطوير والاختبار.

### الخطوة 1: استنساخ مستودع PrestaShop

```bash
# إنشاء دليل المشروع
mkdir prestashop-project && cd prestashop-project

# استنساخ المستودع الرسمي
git clone https://github.com/PrestaShop/PrestaShop.git
cd PrestaShop

# التبديل إلى الفرع المستقر (اختياري)
git checkout main
```

### الخطوة 2: تكوين متغيرات البيئة

```bash
# تعيين بيانات اعتماد مخصصة للمدير (اختياري)
export ADMIN_MAIL=admin@yourstore.com
export ADMIN_PASSWD=SecurePassword123!

# التحقق من متغيرات البيئة
echo "بريد المدير: $ADMIN_MAIL"
echo "كلمة مرور المدير: $ADMIN_PASSWD"
```

### الخطوة 3: تشغيل خدمات Docker

```bash
# بدء PrestaShop مع Docker Compose
docker compose up -d

# مراقبة عملية البدء
docker compose logs -f prestashop
```

### الخطوة 4: الوصول إلى متجرك

بمجرد تشغيل الحاويات، يمكنك الوصول إلى:

- **واجهة المتجر**: http://localhost:8001
- **لوحة الإدارة**: http://localhost:8001/admin-dev
- **تسجيل الدخول الافتراضي**: demo@prestashop.com / Correct Horse Battery Staple

### الخطوة 5: إعداد الخدمات الاختيارية

#### إضافة phpMyAdmin
```bash
# نسخ تكوين التجاوز
cp docker-compose.override.yml.dist docker-compose.override.yml

# بدء الخدمات مع phpMyAdmin
docker compose up -d

# الوصول إلى phpMyAdmin على http://localhost:8080
```

#### تكامل Blackfire (مراقبة الأداء)
```bash
# تعيين متغيرات بيئة Blackfire
export BLACKFIRE_ENABLE=1
export BLACKFIRE_SERVER_ID="your_server_id"
export BLACKFIRE_SERVER_TOKEN="your_blackfire_server_token"

# تحديث docker-compose.override.yml مع تكوين Blackfire
# ثم إعادة تشغيل الخدمات
docker compose down && docker compose up -d
```

## طريقة التثبيت 2: الإعداد التقليدي للخادم

لبيئات الإنتاج أو عندما تفضل الإعداد التقليدي للخادم، اتبع هذه الخطوات:

### الخطوة 1: تنزيل PrestaShop

```bash
# تنزيل أحدث إصدار مستقر
wget https://github.com/PrestaShop/PrestaShop/releases/download/9.0.0/prestashop_9.0.0.zip

# استخراج الملفات
unzip prestashop_9.0.0.zip -d /var/www/html/prestashop

# تعيين الأذونات المناسبة
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo chmod -R 755 /var/www/html/prestashop
```

### الخطوة 2: تكوين خادم الويب

#### تكوين Nginx
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

#### تكوين Apache
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

### الخطوة 3: إعداد قاعدة البيانات

```sql
-- إنشاء قاعدة البيانات والمستخدم
CREATE DATABASE prestashop_db CHARACTER SET utf8mb4 COLLATE utf8mb4_unicode_ci;
CREATE USER 'prestashop_user'@'localhost' IDENTIFIED BY 'secure_password';
GRANT ALL PRIVILEGES ON prestashop_db.* TO 'prestashop_user'@'localhost';
FLUSH PRIVILEGES;
```

### الخطوة 4: تشغيل معالج التثبيت

1. انتقل إلى `http://your-domain.com/install-dev`
2. اتبع معالج التثبيت:
   - **اختيار اللغة**: اختر لغتك المفضلة
   - **اتفاقية الترخيص**: اقبل الشروط
   - **متطلبات النظام**: تحقق من استيفاء جميع المتطلبات
   - **معلومات المتجر**: قم بتكوين اسم المتجر والشعار وحساب المدير
   - **تكوين قاعدة البيانات**: أدخل بيانات اعتماد MySQL
   - **التثبيت**: انتظر حتى اكتمال العملية

### الخطوة 5: تعزيز الأمان

```bash
# إزالة دليل التثبيت
sudo rm -rf /var/www/html/prestashop/install-dev

# إعادة تسمية دليل المدير للأمان
sudo mv /var/www/html/prestashop/admin-dev /var/www/html/prestashop/admin-$(openssl rand -hex 4)

# تعيين أذونات مقيدة
sudo chmod 644 /var/www/html/prestashop/app/config/parameters.php
sudo chmod 755 /var/www/html/prestashop/var
```

## التكوين بعد التثبيت

### إعدادات الأمان الأساسية

1. **تغيير اسم دليل المدير**
   ```bash
   # يجب إعادة تسمية دليل المدير لمنع الوصول غير المصرح به
   mv admin-dev admin-$(date +%s)
   ```

2. **تكوين SSL/HTTPS**
   ```bash
   # تثبيت شهادة SSL (باستخدام Let's Encrypt)
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

3. **تحديث معاملات التكوين**
   ```php
   // في app/config/parameters.php
   'ps_base_dir' => '/var/www/html/prestashop/',
   'ps_ssl_enabled' => true,
   'ps_shop_domain' => 'your-domain.com',
   'ps_shop_domain_ssl' => 'your-domain.com',
   ```

### تحسين الأداء

#### تمكين التخزين المؤقت
```php
// في app/config/parameters.php
'cache_driver' => 'redis', // أو 'memcached'
'cache_prefix' => 'ps_',
'cache_host' => '127.0.0.1',
'cache_port' => 6379,
```

#### تكوين OpCache
```ini
; في php.ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.revalidate_freq=60
opcache.save_comments=1
```

### إدارة الوحدات

#### تثبيت الوحدات الأساسية
```bash
# الانتقال إلى دليل الوحدات
cd /var/www/html/prestashop/modules

# تنزيل الوحدات الشائعة
git clone https://github.com/PrestaShop/ps_facetedsearch.git
git clone https://github.com/PrestaShop/ps_emailsubscription.git
```

#### تكوين وحدات الدفع
1. **تكامل PayPal**
   - انتقل إلى المدير → الوحدات → الدفع
   - قم بتثبيت وحدة PayPal الرسمية
   - قم بتكوين بيانات اعتماد API

2. **تكوين Stripe**
   - قم بتثبيت وحدة Stripe الرسمية
   - قم بإعداد نقاط webhook
   - قم بتكوين أوضاع الاختبار/المباشر

## إعداد بيئة التطوير

### التبعيات التطويرية

```bash
# تثبيت Node.js و npm لتطوير القوالب
curl -fsSL https://deb.nodesource.com/setup_18.x | sudo -E bash -
sudo apt install nodejs

# تثبيت Composer لتبعيات PHP
curl -sS https://getcomposer.org/installer | php
sudo mv composer.phar /usr/local/bin/composer

# تثبيت أدوات التطوير
composer install --dev
npm install
```

### إعداد تطوير القوالب

```bash
# الانتقال إلى دليل القوالب
cd themes/classic

# تثبيت تبعيات القالب
npm install

# بدء خادم التطوير مع إعادة التحميل التلقائي
npm run dev

# البناء للإنتاج
npm run build
```

### بيئة تطوير الوحدات

```bash
# إنشاء هيكل وحدة مخصصة
mkdir modules/mycustommodule
cd modules/mycustommodule

# هيكل الوحدة الأساسي
touch mycustommodule.php
mkdir config controllers override translations views
mkdir views/templates views/css views/js
```

## استكشاف الأخطاء وإصلاحها

### مشاكل متعلقة بـ Docker

#### الحاوية لا تبدأ
```bash
# فحص سجلات الحاوية
docker compose logs prestashop

# إعادة تعيين الحاويات بالكامل
docker compose down -v
docker compose build --no-cache
docker compose up --build --force-recreate
```

#### مشاكل اتصال قاعدة البيانات
```bash
# التحقق من تشغيل حاوية قاعدة البيانات
docker compose ps

# فحص سجلات قاعدة البيانات
docker compose logs mysql

# إعادة تعيين حجم قاعدة البيانات
docker compose down -v
docker volume rm prestashop_mysql_data
```

### مشاكل التثبيت التقليدي

#### مشاكل الأذونات
```bash
# إصلاح أذونات الملفات
sudo chown -R www-data:www-data /var/www/html/prestashop
sudo find /var/www/html/prestashop -type d -exec chmod 755 {} \;
sudo find /var/www/html/prestashop -type f -exec chmod 644 {} \;
```

#### حد ذاكرة PHP
```ini
; في php.ini أو .htaccess
memory_limit = 512M
max_execution_time = 300
max_input_vars = 10000
```

#### مشاكل إعادة كتابة URL
```apache
# في .htaccess
RewriteEngine On
RewriteCond %{REQUEST_FILENAME} !-f
RewriteCond %{REQUEST_FILENAME} !-d
RewriteRule ^(.*)$ index.php [QSA,L]
```

## التكوين المتقدم

### إعداد متعدد المتاجر

```php
// تمكين متعدد المتاجر في parameters.php
'ps_multishop_feature_active' => true,

// تكوين مجموعات المتاجر
'shop_group' => [
    'main' => ['id' => 1, 'name' => 'Main Group'],
    'secondary' => ['id' => 2, 'name' => 'Secondary Group']
],
```

### تكوين API

```php
// تمكين خدمات الويب
'ps_webservice' => true,
'ps_webservice_key' => 'your-api-key-here',

// تكوين أذونات API
'api_permissions' => [
    'products' => ['GET', 'POST', 'PUT', 'DELETE'],
    'customers' => ['GET', 'POST', 'PUT'],
    'orders' => ['GET', 'PUT']
],
```

### النسخ الاحتياطي والصيانة

#### سكريبت نسخ احتياطي تلقائي
```bash
#!/bin/bash
# backup-prestashop.sh

BACKUP_DIR="/var/backups/prestashop"
DB_NAME="prestashop_db"
DB_USER="prestashop_user"
DB_PASS="secure_password"
WEB_DIR="/var/www/html/prestashop"

# إنشاء دليل النسخ الاحتياطي
mkdir -p $BACKUP_DIR/$(date +%Y-%m-%d)

# نسخ احتياطي لقاعدة البيانات
mysqldump -u$DB_USER -p$DB_PASS $DB_NAME > $BACKUP_DIR/$(date +%Y-%m-%d)/database.sql

# نسخ احتياطي للملفات
tar -czf $BACKUP_DIR/$(date +%Y-%m-%d)/files.tar.gz $WEB_DIR

# تنظيف النسخ الاحتياطية القديمة (الاحتفاظ بـ 30 يوماً)
find $BACKUP_DIR -type d -mtime +30 -exec rm -rf {} \;
```

## أفضل الممارسات والأمان

### قائمة مراجعة الأمان

1. **التحديثات المنتظمة**
   ```bash
   # فحص التحديثات
   git fetch origin
   git checkout tags/latest-stable-version
   
   # تحديث التبعيات
   composer update
   npm update
   ```

2. **أمان قاعدة البيانات**
   ```sql
   -- استخدام كلمات مرور قوية
   -- تقييد أذونات مستخدم قاعدة البيانات
   -- تمكين اتصالات SSL
   SET GLOBAL require_secure_transport=ON;
   ```

3. **أمان نظام الملفات**
   ```bash
   # تعطيل تصفح الدليل
   echo "Options -Indexes" >> .htaccess
   
   # حماية الملفات الحساسة
   chmod 600 app/config/parameters.php
   chmod 600 .env
   ```

### مراقبة الأداء

#### إعداد أدوات المراقبة
```bash
# تثبيت مراقبة النظام
sudo apt install htop iotop nethogs

# تكوين دوران السجلات
sudo logrotate -d /etc/logrotate.d/prestashop

# إعداد مراقبة قاعدة البيانات
mysql -e "SHOW PROCESSLIST; SHOW STATUS LIKE 'Slow_queries';"
```

## الخلاصة

لقد نجحت في تثبيت وتكوين PrestaShop، مما يخلق أساساً قوياً لمتجرك الإلكتروني. سواء اخترت نهج Docker للراحة في التطوير أو الإعداد التقليدي للخادم لنشر الإنتاج، فإن تثبيت PrestaShop الخاص بك جاهز الآن للتخصيص وتطوير المتجر.

الإنجازات الرئيسية في هذا الدليل:
- ✅ **التثبيت الكامل**: نشر PrestaShop 9.0 بنجاح
- ✅ **تكوين الأمان**: تنفيذ إجراءات الأمان الأساسية
- ✅ **تحسين الأداء**: تكوين إعدادات التخزين المؤقت والتحسين
- ✅ **بيئة التطوير**: إعداد أدوات لتطوير القوالب والوحدات
- ✅ **معرفة استكشاف الأخطاء**: تعلم حل مشاكل التثبيت الشائعة

### الخطوات التالية

1. **تخصيص المتجر**: قم بتكوين إعدادات متجرك وإضافة المنتجات وتخصيص القالب
2. **تكامل الدفع**: قم بإعداد بوابات دفع مثل PayPal أو Stripe أو طرق الدفع المحلية
3. **تحسين SEO**: قم بتكوين إعادة كتابة URL ووسوم meta وإنشاء خريطة الموقع
4. **تطوير الوحدات**: قم بإنشاء وحدات مخصصة لمتطلبات الأعمال المحددة
5. **ضبط الأداء**: قم بتنفيذ استراتيجيات التخزين المؤقت المتقدمة وتكامل CDN

للتعلم المستمر، استكشف [PrestaShop DevDocs](https://devdocs.prestashop-project.org/) وانضم إلى المجتمع النشط على [GitHub](https://github.com/PrestaShop/PrestaShop) و [Slack](https://www.prestashop-project.org/slack/).

رحلتك في التجارة الإلكترونية مع PrestaShop تبدأ الآن – ابدأ في البناء والتخصيص وتنمية عملك الإلكتروني!
