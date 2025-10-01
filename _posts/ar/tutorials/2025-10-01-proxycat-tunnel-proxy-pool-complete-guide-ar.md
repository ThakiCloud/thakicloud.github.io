---
title: "دليل ProxyCat الشامل: بناء وتشغيل مجموعات البروكسي النفقية"
excerpt: "دليل شامل لبناء مجموعات البروكسي النفقية عالية الأداء باستخدام ProxyCat ورؤى عملية للتطبيق في العالم الحقيقي."
seo_title: "دليل ProxyCat الشامل لمجموعات البروكسي النفقية - Thaki Cloud"
seo_description: "تعلم كيفية بناء وتشغيل مجموعات البروكسي النفقية عالية الأداء باستخدام ProxyCat مع تعليمات خطوة بخطوة وأفضل الممارسات."
date: 2025-10-01
categories:
  - tutorials
tags:
  - ProxyCat
  - ProxyPool
  - TunnelProxy
  - SecurityTools
  - Networking
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/proxycat-tunnel-proxy-pool-complete-guide/"
---

⏱️ **الوقت المقدر للقراءة**: 15 دقيقة

# دليل ProxyCat الشامل: بناء وتشغيل مجموعات البروكسي النفقية

ProxyCat هو برنامج وسيط مبتكر لمجموعات البروكسي النفقية يحول عناوين البروكسي قصيرة المدى إلى عناوين ثابتة للاستخدام المستمر. يغطي هذا الدليل الشامل كل شيء من التثبيت إلى التكوين المتقدم وأفضل الممارسات التشغيلية.

## ما هو ProxyCat؟

ProxyCat هو برنامج وسيط مفتوح المصدر لمجموعات البروكسي النفقية متاح على [GitHub](https://github.com/honmashironeko/ProxyCat). يحول عناوين البروكسي قصيرة المدى (تدوم من 1-60 دقيقة) إلى عناوين ثابتة، مما يوفر حلاً فعالاً من حيث التكلفة للبروكسي لاستخدامات مختلفة.

### الميزات الرئيسية

- **دعم متعدد البروتوكولات**: دعم بروتوكولات HTTP/HTTPS/SOCKS5
- **إدارة ذكية للبروكسي**: التحقق التلقائي من البروكسي والتبديل
- **واجهة ويب**: واجهة إدارة ويب بديهية
- **دعم Docker**: نشر سهل قائم على الحاويات
- **تكوين ديناميكي**: تغيير التكوين دون إعادة التشغيل

## متطلبات النظام

### الحد الأدنى من المتطلبات
- **نظام التشغيل**: Linux (Ubuntu 18.04+)، macOS، Windows
- **Python**: 3.7 أو أعلى
- **الذاكرة**: 512 ميجابايت RAM
- **التخزين**: 1 جيجابايت مساحة فارغة
- **الشبكة**: اتصال إنترنت مستقر

### المواصفات الموصى بها
- **نظام التشغيل**: Ubuntu 20.04 LTS
- **Python**: 3.9 أو أعلى
- **الذاكرة**: 2 جيجابايت RAM
- **التخزين**: 5 جيجابايت SSD
- **الشبكة**: 100 ميجابت في الثانية أو أعلى

## طرق التثبيت

### 1. استنساخ Git وتثبيت التبعيات

```bash
# استنساخ المستودع
git clone https://github.com/honmashironeko/ProxyCat.git
cd ProxyCat

# إنشاء بيئة Python الافتراضية (موصى به)
python3 -m venv proxycat_env
source proxycat_env/bin/activate  # Linux/macOS
# proxycat_env\Scripts\activate  # Windows

# تثبيت التبعيات
pip install -r requirements.txt
```

### 2. التثبيت باستخدام Docker (موصى به)

```bash
# التثبيت باستخدام Docker Compose
git clone https://github.com/honmashironeko/ProxyCat.git
cd ProxyCat
docker-compose up -d
```

### 3. إعداد التكوين

```bash
# نسخ ملف التكوين
cp config/config.ini.example config/config.ini

# تحرير ملف التكوين
nano config/config.ini
```

## التكوين الأساسي

### مثال تكوين config.ini

```ini
[server]
# إعدادات الخادم
host = 0.0.0.0
port = 8080
debug = false

[proxy]
# إعدادات وضع البروكسي
mode = random  # random, order, custom
timeout = 30
retry_count = 3

[auth]
# إعدادات المصادقة
enable_auth = false
username = admin
password = password123

[log]
# إعدادات السجل
level = INFO
file = logs/proxycat.log
```

## استخدام واجهة الويب

### 1. الوصول إلى واجهة الويب

بعد التثبيت، قم بالوصول إلى واجهة الويب على:

```
http://localhost:8080
```

### 2. الميزات الرئيسية

- **مراقبة حالة البروكسي**: فحص حالة البروكسي في الوقت الفعلي
- **تغيير التكوين**: تعديل الإعدادات من خلال واجهة الويب
- **عرض السجلات**: مراقبة السجلات في الوقت الفعلي
- **معلومات الإحصائيات**: إحصائيات حركة المرور والأداء

## التكوين المتقدم

### 1. تكوين مجموعة البروكسي

```python
# مثال تكوين مجموعة البروكسي
proxy_pool = [
    {
        "type": "http",
        "host": "proxy1.example.com",
        "port": 8080,
        "username": "user1",
        "password": "pass1"
    },
    {
        "type": "socks5",
        "host": "proxy2.example.com", 
        "port": 1080,
        "username": "user2",
        "password": "pass2"
    }
]
```

### 2. تكوين التبديل التلقائي للبروكسي

```ini
[advanced]
# الإعدادات المتقدمة
auto_switch = true
switch_interval = 300  # التبديل كل 5 دقائق
health_check_interval = 60  # فحص الصحة كل دقيقة
max_failures = 3  # الحد الأقصى لعدد الأخطاء
```

### 3. تكوين الأمان

```ini
[security]
# إعدادات الأمان
whitelist_enabled = true
whitelist_ips = 192.168.1.0/24,10.0.0.0/8
blacklist_enabled = true
blacklist_ips = 192.168.1.100
rate_limit = 1000  # حد الطلبات في الدقيقة
```

## دليل العمليات الإنتاجية

### 1. إعداد المراقبة

```bash
# مراقبة موارد النظام
htop
iostat -x 1
netstat -tulpn | grep :8080
```

### 2. تحليل السجلات

```bash
# مراقبة السجلات في الوقت الفعلي
tail -f logs/proxycat.log

# تصفية سجلات الأخطاء
grep "ERROR" logs/proxycat.log

# إحصائيات الأداء
grep "STATS" logs/proxycat.log | tail -100
```

### 3. النسخ الاحتياطي والاسترداد

```bash
# نسخ احتياطي للتكوين
cp -r config/ backup/config_$(date +%Y%m%d)/
cp -r logs/ backup/logs_$(date +%Y%m%d)/

# نسخ احتياطي لقاعدة البيانات (إذا كنت تستخدم قاعدة بيانات)
mysqldump -u root -p proxycat_db > backup/db_$(date +%Y%m%d).sql
```

## تحسين الأداء

### 1. ضبط النظام

```bash
# زيادة حجم مخزن الشبكة
echo 'net.core.rmem_max = 16777216' >> /etc/sysctl.conf
echo 'net.core.wmem_max = 16777216' >> /etc/sysctl.conf
sysctl -p

# زيادة حد واصف الملف
echo '* soft nofile 65536' >> /etc/security/limits.conf
echo '* hard nofile 65536' >> /etc/security/limits.conf
```

### 2. تحسين مجموعة البروكسي

```python
# تحسين حجم مجموعة البروكسي
OPTIMAL_POOL_SIZE = 10  # اضبط حسب المستخدمين المتزامنين
HEALTH_CHECK_INTERVAL = 30  # فاصل فحص الصحة
CONNECTION_TIMEOUT = 10  # انتهاء مهلة الاتصال
```

## استكشاف الأخطاء وإصلاحها

### 1. المشاكل الشائعة

**المشكلة**: فشل اتصال البروكسي
```bash
# الحل
# 1. فحص حالة خادم البروكسي
curl -x http://proxy:port http://httpbin.org/ip

# 2. فحص إعدادات الجدار الناري
sudo ufw status
sudo iptables -L
```

**المشكلة**: عدم إمكانية الوصول إلى واجهة الويب
```bash
# الحل
# 1. فحص المنفذ
netstat -tulpn | grep :8080

# 2. إعادة تشغيل الخدمة
docker-compose restart
```

### 2. تحليل السجلات

```bash
# فحص السجلات التفصيلية
grep -E "(ERROR|WARNING|CRITICAL)" logs/proxycat.log

# تشخيص مشاكل الأداء
grep "slow" logs/proxycat.log
grep "timeout" logs/proxycat.log
```

## اعتبارات الأمان

### 1. أمان الشبكة

```bash
# تكوين الجدار الناري
sudo ufw enable
sudo ufw allow 22/tcp  # SSH
sudo ufw allow 8080/tcp  # واجهة ويب ProxyCat
sudo ufw deny 8080/tcp from 0.0.0.0/0  # منع الوصول الخارجي
```

### 2. تعزيز المصادقة

```ini
[auth]
enable_auth = true
username = secure_admin
password = complex_password_123!
session_timeout = 3600
max_login_attempts = 3
```

## المراقبة والتنبيه

### 1. جمع مقاييس Prometheus

```yaml
# مثال تكوين prometheus.yml
scrape_configs:
  - job_name: 'proxycat'
    static_configs:
      - targets: ['localhost:8080']
    metrics_path: '/metrics'
    scrape_interval: 30s
```

### 2. لوحة تحكم Grafana

```json
{
  "dashboard": {
    "title": "ProxyCat Monitoring",
    "panels": [
      {
        "title": "Active Proxies",
        "type": "stat",
        "targets": [
          {
            "expr": "proxycat_active_proxies"
          }
        ]
      }
    ]
  }
}
```

## أفضل الممارسات

### 1. استراتيجية اختيار البروكسي

```python
# اختيار البروكسي الذكي
def select_proxy(proxy_pool, request_type):
    if request_type == "high_bandwidth":
        return select_fastest_proxy(proxy_pool)
    elif request_type == "stealth":
        return select_least_used_proxy(proxy_pool)
    else:
        return select_random_proxy(proxy_pool)
```

### 2. موازنة الأحمال

```ini
[load_balancing]
# تكوين موازنة الأحمال
strategy = round_robin  # round_robin, weighted, least_connections
health_check_interval = 30
failover_threshold = 3
```

### 3. تحديد معدل الطلبات

```ini
[rate_limiting]
# تكوين تحديد معدل الطلبات
requests_per_minute = 1000
burst_limit = 200
per_ip_limit = 100
```

## الخلاصة

يوفر ProxyCat حلاً فعالاً من حيث التكلفة ومرناً لمجموعات البروكسي. لقد غطى هذا الدليل كل شيء من التثبيت الأساسي إلى العمليات المتقدمة.

### النقاط الرئيسية

1. **الكفاءة من حيث التكلفة**: استخدام البروكسي قصير المدى كعناوين ثابتة
2. **المرونة**: خيارات متعددة للبروتوكولات والتكوين
3. **القابلية للتوسع**: توسع سهل مع Docker
4. **المراقبة**: فحص الحالة في الوقت الفعلي والإدارة

### الخطوات التالية

- راجع [الوثائق الرسمية لـ ProxyCat](https://github.com/honmashironeko/ProxyCat)
- شارك حالات الاستخدام المتقدمة في منتديات المجتمع
- نفذ أدوات مراقبة الأداء
- أنشئ وطبق سياسات الأمان

قم ببناء بنية تحتية للبروكسي مستقرة وفعالة باستخدام ProxyCat!

---

**المراجع**:
- [مستودع ProxyCat على GitHub](https://github.com/honmashironeko/ProxyCat)
- [الوثائق الرسمية لـ Docker](https://docs.docker.com/)
- [دليل بيئة Python الافتراضية](https://docs.python.org/3/tutorial/venv.html)
