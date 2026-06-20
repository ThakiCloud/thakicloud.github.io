---
title: "AnyCrawl: الدليل الشامل لزاحف الويب الجاهز للنماذج اللغوية الكبيرة - معيار جديد لجمع بيانات الذكاء الاصطناعي"
excerpt: "أتقن كيفية تحويل مواقع الويب إلى بيانات جاهزة للنماذج اللغوية الكبيرة وجمع نتائج Google/Bing SERP بكفاءة باستخدام AnyCrawl المبني على Node.js/TypeScript."
seo_title: "دليل AnyCrawl الشامل لزاحف الويب بالذكاء الاصطناعي - أداة جمع بيانات AI - Thaki Cloud"
seo_description: "كيفية تنفيذ استخراج الويب وزحف SERP وجمع البيانات متعدد الخيوط باستخدام AnyCrawl من Any4AI. دليل تفصيلي من تثبيت Docker إلى الاستخدام الفعلي."
date: 2025-08-15
last_modified_at: 2025-08-15
categories:
  - datasets
tags:
  - anycrawl
  - web-crawler
  - llm-data
  - serp-scraping
  - any4ai
  - node-js
  - typescript
  - docker
  - data-collection
  - ai-tools
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/datasets/anycrawl-llm-ready-web-crawler-comprehensive-guide/"
lang: ar
reading_time: true
---

⏱️ **وقت القراءة المقدر**: 15 دقائق

## نظرة عامة

[AnyCrawl](https://github.com/any4ai/AnyCrawl) هو **زاحف ويب عالي الأداء** طوّرته شركة Any4AI، يحوّل مواقع الويب إلى بيانات محسّنة للنماذج اللغوية الكبيرة (LLMs) ويستخرج صفحات نتائج محركات البحث (SERP) المنظّمة من Google و Bing و Baidu وغيرها.

يحظى AnyCrawl بـ **1.8 ألف نجمة على GitHub** ومجتمع نشط، ويرسي **معياراً جديداً** لجمع البيانات في تطبيقات الذكاء الاصطناعي.

### القيمة الجوهرية

- **تحسين للنماذج اللغوية الكبيرة**: تحويل بيانات الويب إلى صيغة يسهل على النماذج اللغوية معالجتها
- **دعم متعدد المحركات**: Cheerio و Playwright و Puppeteer وغيرها
- **تخصص في SERP**: دعم Google و Bing و Baidu وغيرها من محركات البحث الرئيسية
- **معالجة عالية الأداء**: بنية متعددة الخيوط والعمليات
- **المعالجة الدفعية**: إدارة فعّالة لمهام الزحف الواسعة النطاق

## ما هو AnyCrawl؟

### منصة جمع بيانات في عصر الذكاء الاصطناعي

يتجاوز AnyCrawl كونه مجرد زاحف ويب؛ إذ هو **منصة جمع بيانات مدعومة بالذكاء الاصطناعي**:

```
محتوى الويب -> معالجة AnyCrawl -> بيانات جاهزة للنماذج اللغوية -> تدريب/استنتاج نموذج AI
```

### بنية معمارية حديثة

**مبنية على Node.js + TypeScript**:
- أداء ممتاز عبر المعالجة غير المتزامنة
- تشغيل مستقر بفضل الأنواع الصارمة
- استفادة من نظام بيئي غني

**نشر معتمد على الحاويات**:
- دعم Docker وDocker Compose
- بنية الخدمات الصغيرة
- قابلية التوسع وسهولة الصيانة

### أربع ميزات جوهرية

#### 1. **زحف SERP** (صفحات نتائج محركات البحث)
```bash
# جمع نتائج بحث Google
curl -X POST http://localhost:8080/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "artificial intelligence trends 2025",
    "limit": 20,
    "engine": "google"
  }'
```

#### 2. **استخراج الويب** (استخراج صفحة واحدة)
```bash
# استخراج محتوى صفحة واحدة
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com/article",
    "engine": "playwright"
  }'
```

#### 3. **زحف الموقع** (زحف الموقع بالكامل)
- اجتياز الروابط بذكاء
- إزالة المحتوى المكرر
- استخراج بيانات منظّمة

#### 4. **المعالجة الدفعية** (عمليات الدُفعات)
- معالجة قوائم URL الضخمة
- تحسين المهام المتوازية
- مراقبة التقدم

## متطلبات النظام

### البيئة الأساسية

```bash
# التحقق من إصدار Docker (يُنصح بـ 20.10 أو أحدث)
docker --version

# التحقق من إصدار Docker Compose (يُنصح بـ 1.29 أو أحدث)
docker-compose --version

# التحقق من Git
git --version

# الذاكرة: 4 GB كحد أدنى، 8 GB أو أكثر موصى به
# القرص: 10 GB مساحة حرة على الأقل
```

### التشغيل القائم على Docker

**التثبيت على macOS**:
```bash
# تثبيت Docker عبر Homebrew
brew install --cask docker

# إتمام الإعداد بعد تشغيل Docker Desktop
```

**التثبيت على Linux**:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install docker.io docker-compose

# CentOS/RHEL
sudo yum install docker docker-compose
```

## التثبيت والإعداد الأولي

### الخطوة 1: استنساخ المستودع

```bash
# استنساخ مستودع AnyCrawl
git clone https://github.com/any4ai/AnyCrawl.git
cd AnyCrawl

# التحقق من الفرع (استخدام الفرع main)
git branch -a
```

### الخطوة 2: تهيئة البيئة

#### ضبط متغيرات البيئة الأساسية
```bash
# إنشاء ملف .env
cp .env.example .env

# مراجعة بنود الإعداد الرئيسية
cat .env
```

#### متغيرات البيئة الرئيسية

| المتغير | القيمة الافتراضية | الوصف |
|--------|--------|------|
| `NODE_ENV` | production | إعداد بيئة التشغيل |
| `ANYCRAWL_API_PORT` | 8080 | منفذ خادم API |
| `ANYCRAWL_HEADLESS` | true | وضع المتصفح بلا واجهة |
| `ANYCRAWL_AVAILABLE_ENGINES` | cheerio,playwright,puppeteer | المحركات المتاحة |
| `ANYCRAWL_REDIS_URL` | redis://redis:6379 | عنوان اتصال Redis |

### الخطوة 3: تشغيل حاويات Docker

```bash
# بناء الحاويات وتشغيلها
docker-compose up --build -d

# التحقق من حالة الخدمة
docker-compose ps

# عرض السجلات
docker-compose logs -f
```

### الخطوة 4: التحقق من التثبيت

```bash
# فحص صحة خادم API
curl http://localhost:8080/health

# الوصول إلى وثائق API (المتصفح)
open http://localhost:8080/docs
```

## دليل مفصّل للميزات الجوهرية

### استخراج الويب

#### محرك Cheerio (HTML الثابت)
```bash
# أسرع تحليل لـ HTML الثابت
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://news.ycombinator.com",
    "engine": "cheerio"
  }'
```

**الخصائص**:
- أعلى سرعة
- استهلاك منخفض للذاكرة
- لا يدعم JavaScript

#### محرك Playwright (عرض JavaScript)
```bash
# محرك متصفح حديث
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com/spa-app",
    "engine": "playwright"
  }'
```

**الخصائص**:
- يدعم جميع المتصفحات (Chrome وFirefox وSafari)
- عرض كامل لـ JavaScript
- يدعم أحدث معايير الويب

#### محرك Puppeteer (مخصص لـ Chrome)
```bash
# عرض قائم على Chrome
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com/react-app",
    "engine": "puppeteer"
  }'
```

**الخصائص**:
- مخصص لـ Chrome/Chromium
- معالجة موثوقة لـ JavaScript
- إمكانيات تصحيح أخطاء غنية

### زحف SERP (نتائج البحث)

#### جمع نتائج بحث Google
```bash
# بحث أساسي
curl -X POST http://localhost:8080/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "machine learning tutorials",
    "engine": "google",
    "pages": 2,
    "lang": "en"
  }'
```

#### دعم البحث متعدد اللغات
```bash
# نتائج البحث بالعربية
curl -X POST http://localhost:8080/v1/search \
  -H 'Content-Type: application/json' \
  -d '{
    "query": "دروس الذكاء الاصطناعي",
    "engine": "google",
    "lang": "ar"
  }'
```

#### معاملات البحث المتقدمة

| المعامل | النوع | الوصف | الافتراضي |
|----------|------|------|--------|
| `query` | string | استعلام البحث | مطلوب |
| `engine` | string | محرك البحث (google) | google |
| `pages` | number | عدد الصفحات للجمع | 1 |
| `lang` | string | رمز اللغة | en-US |
| `limit` | number | حد النتائج | 10 |

### الوكلاء والإعدادات المتقدمة

#### استخدام وكيل HTTP
```bash
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com",
    "engine": "playwright",
    "proxy": "http://proxy.example.com:8080"
  }'
```

#### استخدام وكيل SOCKS
```bash
# إعداد وكيل SOCKS5
curl -X POST http://localhost:8080/v1/scrape \
  -H 'Content-Type: application/json' \
  -d '{
    "url": "https://example.com",
    "proxy": "socks5://proxy.example.com:1080"
  }'
```

## أمثلة تطبيقية عملية

### المثال 1: أتمتة جمع بيانات الأخبار

```bash
#!/bin/bash
# news-collector.sh

API_URL="http://localhost:8080"
OUTPUT_DIR="./news-data"

mkdir -p "$OUTPUT_DIR"

# قائمة المواقع الإخبارية الرئيسية
NEWS_SITES=(
    "https://news.ycombinator.com"
    "https://techcrunch.com"
    "https://www.wired.com"
)

for site in "${NEWS_SITES[@]}"; do
    echo "بدء الزحف: $site"
    
    # جمع البيانات لكل موقع
    curl -X POST "$API_URL/v1/scrape" \
      -H 'Content-Type: application/json' \
      -d "{
        \"url\": \"$site\",
        \"engine\": \"playwright\"
      }" > "$OUTPUT_DIR/$(basename $site).json"
    
    echo "اكتمل: $site"
    sleep 2  # التحكم في معدل الطلبات
done
```

### المثال 2: البحث عن الأوراق الأكاديمية وجمعها

```python
# academic_research.py
import requests
import json
import time

class AcademicCrawler:
    def __init__(self, base_url="http://localhost:8080"):
        self.base_url = base_url
        
    def search_papers(self, keywords, pages=3):
        """البحث عن الأوراق الأكاديمية"""
        results = []
        
        for keyword in keywords:
            response = requests.post(
                f"{self.base_url}/v1/search",
                json={
                    "query": f"{keyword} site:arxiv.org OR site:scholar.google.com",
                    "pages": pages,
                    "limit": 20
                }
            )
            
            if response.status_code == 200:
                data = response.json()
                results.extend(data.get('data', {}).get('results', []))
                
            time.sleep(1)  # احترام حدود معدل API
            
        return results
    
    def extract_paper_content(self, url):
        """استخراج محتوى صفحة الورقة"""
        response = requests.post(
            f"{self.base_url}/v1/scrape",
            json={
                "url": url,
                "engine": "playwright"
            }
        )
        
        if response.status_code == 200:
            return response.json()
        return None

# مثال على الاستخدام
crawler = AcademicCrawler()

# البحث عن أوراق متعلقة بالذكاء الاصطناعي
keywords = [
    "transformer neural network",
    "large language model",
    "computer vision 2025"
]

papers = crawler.search_papers(keywords)
print(f"الأوراق المجمّعة: {len(papers)}")

# استخراج تفاصيل الورقة الأولى
if papers:
    first_paper = papers[0]
    content = crawler.extract_paper_content(first_paper['url'])
    print(f"عنوان الورقة: {first_paper['title']}")
```

### المثال 3: مراقبة أسعار التجارة الإلكترونية

```javascript
// price-monitor.js
const axios = require('axios');

class PriceMonitor {
    constructor(baseUrl = 'http://localhost:8080') {
        this.baseUrl = baseUrl;
    }
    
    async scrapeProduct(url) {
        try {
            const response = await axios.post(`${this.baseUrl}/v1/scrape`, {
                url: url,
                engine: 'playwright'
            });
            
            return response.data;
        } catch (error) {
            console.error('خطأ في الاستخراج:', error.message);
            return null;
        }
    }
    
    async monitorPrices(products) {
        const results = [];
        
        for (const product of products) {
            console.log(`مراقبة: ${product.name}`);
            
            const data = await this.scrapeProduct(product.url);
            
            if (data) {
                results.push({
                    name: product.name,
                    url: product.url,
                    timestamp: new Date().toISOString(),
                    data: data
                });
            }
            
            // التحكم في معدل الطلبات
            await new Promise(resolve => setTimeout(resolve, 2000));
        }
        
        return results;
    }
}

// مثال على الاستخدام
const monitor = new PriceMonitor();

const products = [
    {
        name: 'MacBook Pro',
        url: 'https://www.apple.com/macbook-pro/'
    },
    {
        name: 'iPhone 15',
        url: 'https://www.apple.com/iphone-15/'
    }
];

monitor.monitorPrices(products)
    .then(results => {
        console.log('اكتملت مراقبة الأسعار');
        console.log(JSON.stringify(results, null, 2));
    })
    .catch(error => {
        console.error('خطأ في المراقبة:', error);
    });
```

## الاختبار على macOS

فيما يلي سكريبت لإعداد AnyCrawl واختباره على macOS.

### الإعداد التلقائي لبيئة الاختبار

```bash
#!/bin/bash
# test-anycrawl-setup.sh
echo "إعداد بيئة اختبار AnyCrawl"

# التحقق من Docker
if command -v docker &> /dev/null; then
    echo "تم التحقق من Docker"
else
    echo "Docker مطلوب: brew install --cask docker"
    exit 1
fi

# إنشاء دليل الاختبار
TEST_DIR="$HOME/anycrawl-test-$(date +%Y%m%d)"
mkdir -p "$TEST_DIR" && cd "$TEST_DIR"

# استنساخ المستودع
git clone https://github.com/any4ai/AnyCrawl.git
cd AnyCrawl

# تهيئة البيئة
cp .env.example .env

# تشغيل Docker
docker-compose up --build -d
sleep 30

# فحص الصحة
if curl -s http://localhost:8080/health | grep -q "ok"; then
    echo "AnyCrawl جاهز!"
    echo "وثائق API: http://localhost:8080/docs"
else
    echo "فشل في تشغيل الخدمة"
fi
```

## الخلاصة

AnyCrawl منصة قادرة على تلبية **متطلبات جمع البيانات في عصر الذكاء الاصطناعي**. من خلال تحويل البيانات بصورة ملائمة للنماذج اللغوية الكبيرة، والمعالجة عالية الأداء متعددة الخيوط، ودعم محركات البحث المتعددة، تتيح هذه المنصة **بناء مجموعات بيانات عالية الجودة** الضرورية لتطوير تطبيقات الذكاء الاصطناعي.

### أبرز المزايا

1. **تحسين للنماذج اللغوية**: توفير بيانات منظّمة يسهل على نماذج AI معالجتها
2. **قابلية التوسع**: نشر قائم على Docker بسيط التوسعة
3. **تعدد الاستخدامات**: دعم شامل من استخراج الويب إلى زحف SERP
4. **الأداء**: معالجة البيانات الضخمة عبر تعدد الخيوط

### حالات الاستخدام المحتملة

- **أنظمة RAG**: بناء قواعد معرفة للتوليد المعزّز بالاسترجاع
- **بيانات تدريب AI**: جمع بيانات تدريب عالية الجودة عبر نطاقات متنوعة
- **المراقبة الفورية**: رصد تغييرات الويب وتحليل الاتجاهات
- **خطوط أنابيب آلية**: جمع البيانات الآلي في بيئات CI/CD

ابدأ تجربة جمع البيانات المدعوم بالذكاء الاصطناعي مع [AnyCrawl](https://github.com/any4ai/AnyCrawl) من Any4AI.

---

**مقالات ذات صلة:**
- [الدليل الشامل لاستخراج الويب](https://thakicloud.github.io/tutorials/web-scraping-guide/)
- [منهجيات معالجة بيانات النماذج اللغوية الكبيرة](https://thakicloud.github.io/datasets/llm-data-preprocessing/)
- [بناء بنية تحتية لـ AI قائمة على Docker](https://thakicloud.github.io/tutorials/docker-ai-infrastructure/)
