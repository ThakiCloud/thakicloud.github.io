---
title: "دليل شامل لناشر شاوهونغشو بالذكاء الاصطناعي: أتمتة إنشاء المحتوى والنشر"
excerpt: "إتقان أداة xhs_ai_publisher لأتمتة إنشاء ونشر محتوى شاوهونغشو. دروس تعليمية شاملة تغطي التثبيت والتكوين والميزات المتقدمة لأتمتة وسائل التواصل الاجتماعي."
seo_title: "دروس ناشر شاوهونغشو بالذكاء الاصطناعي: دليل الأتمتة الشامل - Thaki Cloud"
seo_description: "تعلم كيفية أتمتة إنشاء ونشر محتوى شاوهونغشو باستخدام xhs_ai_publisher. دروس تعليمية خطوة بخطوة مع التثبيت والتكوين وأفضل الممارسات لأتمتة وسائل التواصل الاجتماعي."
date: 2025-09-22
categories:
  - tutorials
tags:
  - شاوهونغشو
  - أتمتة-الذكاء-الاصطناعي
  - إنشاء-المحتوى
  - وسائل-التواصل-الاجتماعي
  - بايثون
  - سيلينيوم
  - أتمتة-العمليات
  - أتمتة-التسويق
author_profile: true
toc: true
toc_label: "المحتويات"
lang: ar
permalink: /ar/tutorials/xiaohongshu-ai-publisher-complete-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/xiaohongshu-ai-publisher-complete-guide/"
published: false
---

⏱️ **وقت القراءة المتوقع**: 8 دقائق

## مقدمة

أصبحت شاوهونغشو (الكتاب الأحمر الصغير، المعروف أيضاً باسم RedNote) واحدة من أكثر منصات التجارة الاجتماعية تأثيراً في الصين، حيث تضم أكثر من 300 مليون مستخدم نشط شهرياً. بالنسبة لمنشئي المحتوى والمسوقين الذين يسعون لتأسيس حضور على هذه المنصة، يوفر مشروع **xhs_ai_publisher** حلاً قوياً لأتمتة سير عمل إنشاء ونشر المحتوى.

سيرشدك هذا الدليل الشامل عبر إعداد واستخدام أداة xhs_ai_publisher، التي تجمع بين إنشاء المحتوى المدعوم بالذكاء الاصطناعي وقدرات النشر الآلي باستخدام أتمتة العمليات الآلية (RPA) القائمة على Selenium.

## ما هو xhs_ai_publisher؟

**xhs_ai_publisher** هو مشروع بايثون مفتوح المصدر يعمل كمساعد تشغيل مدعوم بالذكاء الاصطناعي لشاوهونغشو. يتكون من مكونين رئيسيين:

### 🤖 إنشاء المحتوى بالذكاء الاصطناعي
- **إنشاء المحتوى الآلي**: ينشئ منشورات بأسلوب شاوهونغشو تتضمن العناوين والأوصاف والهاشتاغات
- **تكامل الصور**: يختار ويعالج الصور ذات الصلة للمنشورات تلقائياً
- **تحسين الأسلوب**: يضمن مطابقة المحتوى لأسلوب الكتابة الفريد ومعايير التنسيق في شاوهونغشو

### 🎯 النشر الآلي
- **أتمتة RPA**: يستخدم Selenium WebDriver لمحاكاة تفاعلات المستخدم
- **دعم متعدد الحسابات**: يدير عدة حسابات شاوهونغشو في وقت واحد
- **النشر المجدول**: يدعم ميزات النشر المؤقت والدفعي
- **بصمة المتصفح**: يتضمن تدابير مكافحة الكشف لضمان أمان الأتمتة

## الميزات والقدرات الرئيسية

| الميزة | الوصف | الفوائد |
|-------|---------|---------|
| 🎨 **إنشاء المحتوى بالذكاء الاصطناعي** | ينشئ منشورات جذابة بتنسيق مناسب | توفير الوقت في إنشاء المحتوى |
| 📱 **إدارة متعدد الحسابات** | التعامل مع عدة حسابات شاوهونغشو | توسيع العمليات بكفاءة |
| 🖼️ **معالجة الصور الآلية** | اختيار وتحسين الصور الذكي | محتوى بصري احترافي |
| 🔒 **دعم البروكسي** | تكوين بروكسي HTTP/HTTPS/SOCKS5 | خصوصية وأمان محسنان |
| 🌐 **أتمتة المتصفح** | أتمتة النشر القائمة على Selenium | سير عمل نشر موثوق |
| 📊 **نظام إدارة المستخدمين** | إدارة شاملة للحسابات والملفات الشخصية | عمليات منظمة |

## متطلبات النظام

قبل البدء، تأكد من أن نظامك يلبي هذه المتطلبات:

| المكون | المتطلب | التوصية |
|--------|----------|-----------|
| 🐍 **Python** | 3.8+ | أحدث إصدار مستقر |
| 🌐 **متصفح Chrome** | أحدث إصدار | لأتمتة Selenium |
| 💾 **الذاكرة** | 4GB+ | يُوصى بـ 8GB+ |
| 💿 **التخزين** | 2GB+ | للتبعيات والبيانات |
| 🌍 **الشبكة** | إنترنت مستقر | قد تحتاج VPN |

## دليل التثبيت

يدعم المشروع طرق تثبيت متعددة عبر أنظمة تشغيل مختلفة.

### 🚀 التثبيت السريع (موصى به)

اختر نص التثبيت المناسب لنظام التشغيل الخاص بك:

#### 🍎 تثبيت macOS

```bash
# 1️⃣ نسخ المستودع
git clone https://github.com/BetaStreetOmnis/xhs_ai_publisher.git
cd xhs_ai_publisher

# 2️⃣ تشغيل نص التثبيت
chmod +x install_mac.sh
./install_mac.sh

# 3️⃣ بدء التطبيق
./启动程序.sh
```

**الميزات:**
- ✅ كشف وتثبيت بيئة Python تلقائياً
- ✅ تثبيت Homebrew (عند الحاجة)
- ✅ دعم كل من شرائح Apple Silicon وIntel
- ✅ إدارة التبعيات وإعداد البيئة الافتراضية بالكامل

#### 🐧 تثبيت Linux

```bash
# 1️⃣ نسخ المستودع
git clone https://github.com/BetaStreetOmnis/xhs_ai_publisher.git
cd xhs_ai_publisher

# 2️⃣ تشغيل نص التثبيت
chmod +x install.sh
./install.sh

# 3️⃣ بدء التطبيق
./启动程序.sh
```

**التوزيعات المدعومة:**
- ✅ عائلة Ubuntu/Debian
- ✅ RHEL/CentOS/Rocky Linux
- ✅ Fedora
- ✅ openSUSE/SLES
- ✅ Arch Linux/Manjaro

#### 💻 تثبيت Windows

```cmd
# 1️⃣ نسخ المستودع
git clone https://github.com/BetaStreetOmnis/xhs_ai_publisher.git
cd xhs_ai_publisher

# 2️⃣ تشغيل نص التثبيت
install.bat

# 3️⃣ بدء التطبيق
启动程序.bat
```

**المتطلبات:**
- ✅ Windows 10/11
- ✅ تثبيت Python تلقائياً (عند الحاجة)
- ✅ إدارة التبعيات بالكامل

### 🔧 التثبيت اليدوي (للمستخدمين المتقدمين)

```bash
# 1️⃣ نسخ المستودع
git clone https://github.com/BetaStreetOmnis/xhs_ai_publisher.git
cd xhs_ai_publisher

# 2️⃣ إنشاء بيئة افتراضية
python -m venv venv

# 3️⃣ تفعيل البيئة الافتراضية
# Linux/Mac:
source venv/bin/activate
# Windows:
venv\Scripts\activate

# 4️⃣ تثبيت التبعيات
pip install -r requirements.txt

# 5️⃣ تهيئة قاعدة البيانات (اختياري)
python init_db.py

# 6️⃣ بدء التطبيق
python main.py
```

## إعداد التكوين

### 🔑 تكوين البيئة

أنشئ وكوّن ملف `.env` الخاص بك:

```env
# تكوين الذكاء الاصطناعي
OPENAI_API_KEY=your_openai_api_key_here
AI_MODEL=gpt-3.5-turbo
MAX_TOKENS=2000
TEMPERATURE=0.7

# تكوين شاوهونغشو
XHS_USERNAME=your_username
XHS_PASSWORD=your_password

# تكوين البروكسي (اختياري)
PROXY_TYPE=http
PROXY_HOST=your_proxy_host
PROXY_PORT=your_proxy_port
PROXY_USERNAME=your_proxy_username
PROXY_PASSWORD=your_proxy_password

# تكوين المتصفح
HEADLESS_MODE=false
BROWSER_TIMEOUT=30
```

### ⚙️ التكوين المتقدم

عدّل ملف `config.py` للإعدادات المتقدمة:

```python
# تكوين الذكاء الاصطناعي
AI_CONFIG = {
    "model": "gpt-3.5-turbo",
    "max_tokens": 2000,
    "temperature": 0.7,
    "system_prompt": "أنت منشئ محتوى شاوهونغشو..."
}

# تكوين المتصفح
BROWSER_CONFIG = {
    "headless": False,
    "user_agent": "Mozilla/5.0...",
    "viewport": {"width": 1920, "height": 1080},
    "page_load_timeout": 30
}

# تكوين النشر
PUBLISH_CONFIG = {
    "auto_publish": False,
    "delay_range": [3, 8],
    "max_retry": 3,
    "screenshot_on_error": True
}
```

## دليل الاستخدام خطوة بخطوة

### 1. 🚀 بدء التطبيق

شغّل التطبيق باستخدام إحدى هذه الطرق:

```bash
# الطريقة 1: استخدام نص البدء
./启动程序.sh

# الطريقة 2: تنفيذ Python مباشرة
python main.py

# الطريقة 3: استخدام تكوين محدد
python main.py --config custom_config.py
```

### 2. 👤 إدارة المستخدمين

1. **الوصول لإدارة المستخدمين**: انقر على زر "إدارة المستخدمين" في الواجهة الرئيسية
2. **إضافة مستخدم جديد**: كوّن تفاصيل الحساب والتفضيلات
3. **إعدادات البروكسي**: أعد تكوين البروكسي لكل حساب
4. **بصمة المتصفح**: كوّن بصمات متصفح فريدة لتجنب الكشف

### 3. 📱 مصادقة الحساب

```python
# مثال على تدفق المصادقة
def authenticate_account(phone_number):
    """
    مصادقة حساب شاوهونغشو
    """
    # 1. إدخال رقم الهاتف
    driver.find_element(By.ID, "phone").send_keys(phone_number)
    
    # 2. طلب رمز التحقق
    driver.find_element(By.ID, "send_code").click()
    
    # 3. إدخال رمز التحقق (مطلوب إدخال يدوي)
    verification_code = input("أدخل رمز التحقق: ")
    driver.find_element(By.ID, "code").send_keys(verification_code)
    
    # 4. إرسال وحفظ الجلسة
    driver.find_element(By.ID, "login").click()
    
    return True
```

### 4. ✍️ سير عمل إنشاء المحتوى

#### إنشاء المحتوى الآلي

```python
# مثال على إنشاء المحتوى
def generate_content(topic):
    """
    إنشاء محتوى بأسلوب شاوهونغشو
    """
    prompt = f"""
    أنشئ منشور شاوهونغشو حول: {topic}
    
    المتطلبات:
    - عنوان جذاب مع الرموز التعبيرية
    - وصف من 200-300 حرف
    - 5-8 هاشتاغات ذات صلة
    - أسلوب كتابة شاوهونغشو
    """
    
    response = openai.ChatCompletion.create(
        model="gpt-3.5-turbo",
        messages=[{"role": "user", "content": prompt}],
        max_tokens=2000,
        temperature=0.7
    )
    
    return response.choices[0].message.content
```

#### إدخال المحتوى اليدوي

1. **إدخال الموضوع**: أدخل الموضوع المرغوب في حقل الإدخال الرئيسي
2. **إنشاء المحتوى**: انقر على زر "إنشاء المحتوى"
3. **المراجعة والتعديل**: راجع المحتوى المُنشأ بالذكاء الاصطناعي وقم بالتعديلات
4. **اختيار الصور**: اختر أو ارفع الصور ذات الصلة

### 5. 🖼️ إدارة الصور

توفر الأداة معالجة شاملة للصور:

```python
# مثال على معالجة الصور
def process_images(topic, num_images=3):
    """
    معالجة وتحسين الصور لشاوهونغشو
    """
    # 1. البحث عن الصور ذات الصلة
    images = search_stock_images(topic)
    
    # 2. تغيير الحجم والتحسين
    processed_images = []
    for img in images[:num_images]:
        # الأبعاد المثلى لشاوهونغشو: نسبة 3:4
        resized = img.resize((750, 1000))
        processed_images.append(resized)
    
    # 3. إضافة العلامات المائية أو المرشحات عند الحاجة
    return processed_images
```

### 6. 📤 عملية النشر

#### النشر الآلي

```python
def publish_post(title, content, images, hashtags):
    """
    أتمتة نشر المنشور على شاوهونغشو
    """
    try:
        # 1. الانتقال إلى صفحة إنشاء المنشور
        driver.get("https://creator.xiaohongshu.com/publish/publish")
        
        # 2. رفع الصور
        for img_path in images:
            upload_element = driver.find_element(By.CSS_SELECTOR, "input[type='file']")
            upload_element.send_keys(img_path)
            time.sleep(2)
        
        # 3. إضافة العنوان والمحتوى
        title_field = driver.find_element(By.CSS_SELECTOR, "input[placeholder*='title']")
        title_field.send_keys(title)
        
        content_field = driver.find_element(By.CSS_SELECTOR, "textarea")
        content_field.send_keys(f"{content}\n\n{' '.join(hashtags)}")
        
        # 4. النشر
        publish_button = driver.find_element(By.CSS_SELECTOR, "button[data-testid='publish']")
        publish_button.click()
        
        return True
        
    except Exception as e:
        logger.error(f"فشل النشر: {e}")
        return False
```

#### النشر المجدول

```python
def schedule_post(content, publish_time):
    """
    جدولة المنشور للنشر المستقبلي
    """
    scheduler = BackgroundScheduler()
    scheduler.add_job(
        func=publish_post,
        trigger="date",
        run_date=publish_time,
        args=[content['title'], content['text'], content['images'], content['hashtags']]
    )
    scheduler.start()
```

## الميزات المتقدمة

### 🔒 تكوين البروكسي

كوّن أنواع بروكسي مختلفة للأمان المحسن:

```python
# أمثلة على تكوين البروكسي
PROXY_CONFIGS = {
    "http": {
        "proxy_type": "http",
        "host": "proxy.example.com",
        "port": 8080,
        "username": "user",
        "password": "pass"
    },
    "socks5": {
        "proxy_type": "socks5",
        "host": "socks.example.com",
        "port": 1080
    }
}

def setup_proxy(driver, config):
    """إعداد البروكسي لجلسة المتصفح"""
    proxy = Proxy()
    proxy.proxy_type = ProxyType.MANUAL
    proxy.http_proxy = f"{config['host']}:{config['port']}"
    proxy.ssl_proxy = f"{config['host']}:{config['port']}"
    
    capabilities = webdriver.DesiredCapabilities.CHROME
    proxy.add_to_capabilities(capabilities)
    
    return capabilities
```

### 🔍 تدابير مكافحة الكشف

تنفيذ بصمة المتصفح وعشوائية السلوك:

```python
def setup_stealth_browser():
    """تكوين المتصفح للعمل الخفي"""
    options = webdriver.ChromeOptions()
    
    # تعطيل علامات الأتمتة
    options.add_experimental_option("excludeSwitches", ["enable-automation"])
    options.add_experimental_option('useAutomationExtension', False)
    
    # وكيل مستخدم عشوائي
    options.add_argument(f"--user-agent={get_random_user_agent()}")
    
    # إطار عرض عشوائي
    viewport = get_random_viewport()
    options.add_argument(f"--window-size={viewport['width']},{viewport['height']}")
    
    driver = webdriver.Chrome(options=options)
    
    # تنفيذ نص خفي
    driver.execute_script("Object.defineProperty(navigator, 'webdriver', {get: () => undefined})")
    
    return driver
```

### 📊 التحليلات والمراقبة

تتبع أداء المنشورات وصحة النظام:

```python
def track_post_performance(post_id):
    """مراقبة مقاييس تفاعل المنشور"""
    metrics = {
        "views": 0,
        "likes": 0,
        "comments": 0,
        "shares": 0,
        "timestamp": datetime.now()
    }
    
    # استخراج المقاييس من صفحة المنشور
    driver.get(f"https://xiaohongshu.com/explore/{post_id}")
    
    try:
        likes = driver.find_element(By.CSS_SELECTOR, "[data-testid='like-count']").text
        metrics["likes"] = int(likes.replace("k", "000") if "k" in likes else likes)
    except:
        pass
    
    # حفظ في قاعدة البيانات
    save_metrics(post_id, metrics)
    return metrics
```

## دليل استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة والحلول

#### 1. 🚫 مشاكل تسجيل الدخول

**المشكلة**: عدم القدرة على المصادقة مع حساب شاوهونغشو

**الحلول**:
```python
def fix_login_issues():
    """خطوات استكشاف أخطاء تسجيل الدخول الشائعة"""
    steps = [
        "1. مسح كاش وملفات تعريف الارتباط للمتصفح",
        "2. تحديث متصفح Chrome لأحدث إصدار",
        "3. فحص تكوين البروكسي",
        "4. التحقق من تنسيق رقم الهاتف",
        "5. استخدام سلسلة وكيل مستخدم مختلفة",
        "6. تمكين حل الكابتشا اليدوي"
    ]
    return steps
```

#### 2. 🖼️ فشل رفع الصور

**المشكلة**: فشل في رفع أو معالجة الصور

**الحلول**:
```python
def fix_image_issues():
    """قائمة فحص مشاكل الصور"""
    checks = [
        "التحقق من تنسيق الصورة (JPG, PNG مدعومة)",
        "فحص حجم الصورة (أقصى حد 10MB)",
        "ضمان النسبة المناسبة (3:4 موصى بها)",
        "التحقق من أبعاد الصورة (الحد الأدنى 750px عرض)",
        "فحص المساحة المتاحة في القرص",
        "التحقق من اتصال الشبكة"
    ]
    return checks
```

#### 3. 🔄 كشف الأتمتة

**المشكلة**: شاوهونغشو تكشف الأتمتة

**الحلول**:
```python
def avoid_detection():
    """أفضل ممارسات مكافحة الكشف"""
    practices = [
        "استخدام بروكسيات سكنية",
        "عشوائية التوقيت بين الإجراءات",
        "تنفيذ حركات الماوس الشبيهة بالبشر",
        "تبديل وكلاء المستخدم بانتظام",
        "تحديد تكرار النشر",
        "استخدام بصمات متصفح مختلفة"
    ]
    return practices
```

## أفضل الممارسات والنصائح

### 📝 أفضل ممارسات إنشاء المحتوى

1. **فهم ثقافة شاوهونغشو**: ابحث في المواضيع الرائجة والتنسيقات الشائعة
2. **استخدام الهاشتاغات المناسبة**: ادرج 5-8 هاشتاغات ذات صلة لقابلية اكتشاف أفضل
3. **تحسين جودة الصورة**: استخدم صور عالية الدقة مع إضاءة مناسبة
4. **الحفاظ على الاتساق**: انشر بانتظام لبناء تفاعل الجمهور
5. **مراقبة الاتجاهات**: ابق محدثاً مع تغييرات خوارزمية المنصة

### 🔒 اعتبارات الأمان

```python
# قائمة فحص الأمان
SECURITY_CHECKLIST = {
    "أمان_الحساب": [
        "استخدام كلمات مرور قوية وفريدة",
        "تمكين المصادقة الثنائية",
        "تبديل بيانات الاعتماد بانتظام",
        "مراقبة سجلات نشاط الحساب"
    ],
    "أمان_الأتمتة": [
        "تنفيذ تحديد المعدل",
        "استخدام بروكسيات عالية الجودة",
        "عشوائية أنماط الأتمتة",
        "مراقبة تغييرات سياسة المنصة"
    ],
    "حماية_البيانات": [
        "تشفير التكوين الحساس",
        "تأمين مفاتيح API بشكل صحيح",
        "تنفيذ ضوابط الوصول",
        "إجراءات النسخ الاحتياطي المنتظمة"
    ]
}
```

## تحسين الأداء

### ⚡ تحسين السرعة

```python
def optimize_performance():
    """تقنيات تحسين الأداء"""
    optimizations = {
        "المعالجة_المتوازية": "استخدام التدفق للحسابات المتعددة",
        "إدارة_الكاش": "تنفيذ تخزين مؤقت ذكي للصور والمحتوى",
        "تجميع_الموارد": "إعادة استخدام مثيلات المتصفح عند الإمكان",
        "تحسين_قاعدة_البيانات": "فهرسة الحقول المستعلمة بكثرة",
        "إدارة_الذاكرة": "تنظيف منتظم للكائنات غير المستخدمة"
    }
    return optimizations
```

### 📊 المراقبة والتسجيل

```python
import logging
from datetime import datetime

def setup_logging():
    """إعداد تسجيل شامل"""
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s',
        handlers=[
            logging.FileHandler(f'xhs_publisher_{datetime.now().strftime("%Y%m%d")}.log'),
            logging.StreamHandler()
        ]
    )
    
    # إنشاء مسجلات متخصصة
    automation_logger = logging.getLogger('automation')
    content_logger = logging.getLogger('content_generation')
    error_logger = logging.getLogger('errors')
    
    return {
        'automation': automation_logger,
        'content': content_logger,
        'errors': error_logger
    }
```

## خارطة الطريق المستقبلية والتحديثات

يستمر مشروع xhs_ai_publisher في التطور مع التحسينات المخططة:

### 🚀 الميزات القادمة

- ✅ **الوظائف الأساسية**: إنشاء ونشر المحتوى *(مكتمل)*
- ✅ **إدارة المستخدمين**: دعم متعدد الحسابات *(مكتمل)*
- ✅ **تكوين البروكسي**: دعم بروكسي الشبكة *(مكتمل)*
- 🔄 **مكتبة المحتوى**: نظام إدارة المواد *(قيد التطوير)*
- 🔄 **مكتبة القوالب**: نظام القوالب المحددة مسبقاً *(قيد التطوير)*
- 🔄 **لوحة التحليلات**: تحليل أداء النشر *(مخطط)*
- 🔄 **واجهة API**: نقاط API مفتوحة *(مخطط)*
- 🔄 **الدعم المحمول**: تطبيق محمول *(مخطط)*

## الخلاصة

تمثل أداة **xhs_ai_publisher** تقدماً مهماً في أتمتة وسائل التواصل الاجتماعي، مصممة خصيصاً لمنصة شاوهونغشو. من خلال دمج إنشاء المحتوى المدعوم بالذكاء الاصطناعي مع قدرات الأتمتة المتطورة، تمكن منشئي المحتوى والمسوقين من توسيع عملياتهم مع الحفاظ على الجودة والأصالة.

### النقاط الرئيسية

1. **حل شامل**: تغطي الأداة دورة حياة المحتوى الكاملة من الإنشاء إلى النشر
2. **تكوين مرن**: خيارات تخصيص واسعة لحالات استخدام مختلفة
3. **التركيز على الأمان**: تدابير مكافحة الكشف والأمان المدمجة
4. **تطوير نشط**: تحسينات مستمرة وإضافة ميزات
5. **مدفوع بالمجتمع**: مشروع مفتوح المصدر مع مجتمع مساهمين نشط

### البداية

لبدء رحلتك مع xhs_ai_publisher:

1. **تثبيت الأداة**: اتبع دليل التثبيت لنظام التشغيل الخاص بك
2. **تكوين الإعدادات**: أعد مفاتيح API للذكاء الاصطناعي وتكوينات البروكسي
3. **إنشاء المحتوى**: ابدأ بمنشورات بسيطة لفهم سير العمل
4. **مراقبة الأداء**: تتبع النتائج وحسّن استراتيجيتك
5. **انضم للمجتمع**: تفاعل مع مستخدمين آخرين للنصائح واستكشاف الأخطاء

سواء كنت منشئ محتوى يسعى لتبسيط سير العمل أو مسوق يهدف لتوسيع حضوره على شاوهونغشو، توفر هذه الأداة الأساس لإدارة وسائل التواصل الاجتماعي الآلية والذكية.

---

**📚 موارد إضافية:**
- [مستودع GitHub](https://github.com/BetaStreetOmnis/xhs_ai_publisher)
- [وثائق API](https://github.com/BetaStreetOmnis/xhs_ai_publisher/wiki)
- [منتدى المجتمع](https://github.com/BetaStreetOmnis/xhs_ai_publisher/discussions)
- [متتبع المشاكل](https://github.com/BetaStreetOmnis/xhs_ai_publisher/issues)

**🌟 ضع نجمة للمشروع على GitHub إذا وجدته مفيداً!**
