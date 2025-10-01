---
title: "AutoScraper: أداة ثورية لأتمتة استخراج البيانات من الويب في Python"
excerpt: "AutoScraper هي مكتبة Python تستخدم التعلم الآلي لتعلم قواعد استخراج البيانات من الويب تلقائياً. استخرج البيانات المطلوبة بسهولة دون الحاجة لـ CSS selectors معقدة أو XPath."
seo_title: "دليل AutoScraper لأتمتة استخراج البيانات من الويب في Python - Thaki Cloud"
seo_description: "دليل شامل لـ AutoScraper لأتمتة استخراج البيانات من الويب في Python. تعلم قواعد الاستخراج القائمة على التعلم الآلي مع أمثلة عملية ومشاريع حقيقية."
date: 2025-10-01
categories:
  - tutorials
tags:
  - python
  - web-scraping
  - autoscraper
  - automation
  - machine-learning
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/autoscraper-tutorial/"
---

⏱️ **الوقت المقدر للقراءة**: 15 دقيقة

## ما هو AutoScraper؟

AutoScraper هي مكتبة Python ثورية تبسط عملية استخراج البيانات من الويب بشكل كبير. بينما يتطلب استخراج البيانات التقليدي استخدام CSS selectors معقدة أو XPath لاستخراج البيانات، يستخدم AutoScraper التعلم الآلي لتعلم قواعد الاستخراج تلقائياً.

### الميزات الرئيسية

- **تعلم القواعد تلقائياً**: ما عليك سوى تقديم عينة من البيانات التي تريد استخراجها، وسيتعلم قواعد الاستخراج تلقائياً
- **سريع وخفيف**: خوارزميات محسنة للسرعة في المعالجة
- **استخدام مرن**: يدعم أنواع بيانات متنوعة بما في ذلك النصوص والروابط وقيم HTML tags
- **حفظ/تحميل النماذج**: حفظ النماذج المُتعلمة وإعادة استخدامها

## طريقة التثبيت

يمكن تثبيت AutoScraper بسهولة عبر pip:

```bash
# التثبيت من PyPI
pip install autoscraper

# أو تثبيت أحدث إصدار مباشرة من GitHub
pip install git+https://github.com/alirezamika/autoscraper.git
```

## الاستخدام الأساسي

### 1. الحصول على نتائج مشابهة

إليك مثال لاستخراج عناوين الأسئلة ذات الصلة من صفحة StackOverflow:

```python
from autoscraper import AutoScraper

url = 'https://stackoverflow.com/questions/2081586/web-scraping-with-python'

# قدم عينة من البيانات التي تريد استخراجها
wanted_list = ["What are metaclasses in Python?"]

scraper = AutoScraper()
result = scraper.build(url, wanted_list)
print(result)
```

**النتيجة:**
```
[
    'How do I merge two dictionaries in a single expression in Python (taking union of dictionaries)?', 
    'How to call an external command?', 
    'What are metaclasses in Python?', 
    'Does Python have a ternary conditional operator?', 
    'How do you remove duplicates from a list whilst preserving order?', 
    'Convert bytes to a string', 
    'How to get line count of a large file cheaply in Python?', 
    "Does Python have a string 'contains' substring method?", 
    'Why is "1000000000000000 in range(1000000000000001)" so fast in Python 3?'
]
```

الآن يمكنك استخدام كائن `scraper` المُتعلم لاستخراج محتوى مشابه من صفحات StackOverflow أخرى:

```python
# استخراج نتائج مشابهة من صفحات أخرى
result = scraper.get_result_similar('https://stackoverflow.com/questions/606191/convert-bytes-to-a-string')
```

### 2. الحصول على نتائج دقيقة

إليك مثال لاستخراج أسعار الأسهم المباشرة من Yahoo Finance:

```python
from autoscraper import AutoScraper

url = 'https://finance.yahoo.com/quote/AAPL/'
wanted_list = ["124.81"]  # تحديث بالسعر الفعلي

scraper = AutoScraper()
result = scraper.build(url, wanted_list)
print(result)
```

الآن يمكنك بسهولة الحصول على أسعار رموز أسهم أخرى:

```python
# الحصول على سعر أسهم Microsoft
result = scraper.get_result_exact('https://finance.yahoo.com/quote/MSFT/')
```

### 3. استخراج بيانات متعددة في نفس الوقت

إليك مثال لاستخراج معلومات متعددة من صفحة مستودع GitHub:

```python
from autoscraper import AutoScraper

url = 'https://github.com/alirezamika/autoscraper'
wanted_list = [
    'A Smart, Automatic, Fast and Lightweight Web Scraper for Python',  # الوصف
    '6.2k',  # عدد النجوم
    'https://github.com/alirezamika/autoscraper/issues'  # رابط المشاكل
]

scraper = AutoScraper()
scraper.build(url, wanted_list)

# استخراج البيانات بالترتيب الدقيق
result = scraper.get_result_exact('https://github.com/another-repo')
```

## الاستخدام المتقدم

### استخدام البروكسي والرؤوس المخصصة

```python
from autoscraper import AutoScraper

url = 'https://example.com'
wanted_list = ["sample data"]

# إعداد البروكسي
proxies = {
    "http": 'http://127.0.0.1:8001',
    "https": 'https://127.0.0.1:8001',
}

# الرؤوس المخصصة
headers = {
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
}

scraper = AutoScraper()
result = scraper.build(
    url, 
    wanted_list, 
    request_args=dict(proxies=proxies, headers=headers)
)
```

### استخدام محتوى HTML مباشرة

يمكنك أيضاً استخدام محتوى HTML مباشرة بدلاً من الروابط:

```python
html_content = """
<html>
<body>
    <h1>العنوان</h1>
    <p>المحتوى</p>
</body>
</html>
"""

scraper = AutoScraper()
result = scraper.build(html=html_content, wanted_list=["العنوان"])
```

## حفظ وتحميل النماذج

يمكنك حفظ النماذج المُتعلمة وإعادة استخدامها لاحقاً:

```python
# حفظ النموذج
scraper.save('my-scraper-model')

# تحميل النموذج
scraper = AutoScraper()
scraper.load('my-scraper-model')

# استخدام النموذج المحمل للاستخراج
result = scraper.get_result_exact('https://new-url.com')
```

## أمثلة مشاريع حقيقية

### جامع عناوين الأخبار

```python
from autoscraper import AutoScraper
import json

def collect_news_headlines():
    scraper = AutoScraper()
    
    # بيانات التدريب
    url = 'https://news.ycombinator.com/'
    wanted_list = ["Sample headline text"]
    
    # تدريب النموذج
    scraper.build(url, wanted_list)
    
    # جمع العناوين من مواقع أخبار متعددة
    news_sites = [
        'https://news.ycombinator.com/',
        'https://www.reddit.com/r/programming/',
        'https://dev.to/'
    ]
    
    all_headlines = []
    for site in news_sites:
        headlines = scraper.get_result_similar(site)
        all_headlines.extend(headlines)
    
    return all_headlines

# التنفيذ
headlines = collect_news_headlines()
print(f"تم جمع {len(headlines)} عنوان إخباري في المجموع.")
```

### مراقب أسعار المنتجات

```python
from autoscraper import AutoScraper
import time
import json

class PriceMonitor:
    def __init__(self):
        self.scraper = AutoScraper()
        self.setup_scraper()
    
    def setup_scraper(self):
        # التدريب مع صفحة منتج Amazon
        url = 'https://www.amazon.com/dp/B08N5WRWNW'  # منتج مثال
        wanted_list = ["$299.99"]  # تحديث بالسعر الفعلي
        
        self.scraper.build(url, wanted_list)
    
    def monitor_price(self, product_url):
        try:
            result = self.scraper.get_result_exact(product_url)
            if result:
                return {
                    'url': product_url,
                    'price': result[0],
                    'timestamp': time.time()
                }
        except Exception as e:
            print(f"خطأ في مراقبة السعر: {e}")
            return None
    
    def save_price_data(self, price_data, filename='price_history.json'):
        try:
            with open(filename, 'r') as f:
                data = json.load(f)
        except FileNotFoundError:
            data = []
        
        data.append(price_data)
        
        with open(filename, 'w') as f:
            json.dump(data, f, indent=2)

# مثال الاستخدام
monitor = PriceMonitor()
price_data = monitor.monitor_price('https://www.amazon.com/dp/B08N5WRWNW')
if price_data:
    monitor.save_price_data(price_data)
    print(f"السعر الحالي: {price_data['price']}")
```

## نصائح تحسين الأداء

### 1. المعالجة المجمعة

```python
def batch_scrape(urls, wanted_list):
    scraper = AutoScraper()
    
    # التدريب مع الرابط الأول
    scraper.build(urls[0], wanted_list)
    
    # معالجة الروابط المتبقية في مجموعة
    results = []
    for url in urls[1:]:
        result = scraper.get_result_similar(url)
        results.append({'url': url, 'data': result})
    
    return results
```

### 2. معالجة الأخطاء

```python
def safe_scrape(url, wanted_list, max_retries=3):
    scraper = AutoScraper()
    
    for attempt in range(max_retries):
        try:
            result = scraper.build(url, wanted_list)
            return result
        except Exception as e:
            print(f"المحاولة {attempt + 1} فشلت: {e}")
            if attempt == max_retries - 1:
                return None
            time.sleep(2 ** attempt)  # التراجع الأسي
```

## أفضل الممارسات والاعتبارات

### 1. احترام سياسات المواقع

- **فحص robots.txt**: تحقق دائماً من ملف robots.txt للموقع واتبع القواعد
- **تحديد معدل الطلبات**: ضع تأخيرات مناسبة لتجنب إرهاق الخوادم بطلبات مفرطة
- **إعداد User-Agent**: ضع User-Agent مناسب ليبدو كطلب متصفح عادي

### 2. التحقق من صحة البيانات

```python
def validate_scraped_data(data, expected_fields):
    """التحقق من سلامة البيانات المستخرجة."""
    if not data:
        return False
    
    for field in expected_fields:
        if field not in data or not data[field]:
            return False
    
    return True
```

### 3. التسجيل والمراقبة

```python
import logging

# إعداد التسجيل
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(levelname)s - %(message)s',
    handlers=[
        logging.FileHandler('scraper.log'),
        logging.StreamHandler()
    ]
)

def scrape_with_logging(url, wanted_list):
    logging.info(f"بدء الاستخراج: {url}")
    
    try:
        scraper = AutoScraper()
        result = scraper.build(url, wanted_list)
        logging.info(f"تم استخراج {len(result)} عنصر بنجاح")
        return result
    except Exception as e:
        logging.error(f"فشل الاستخراج: {e}")
        return None
```

## أمثلة التكامل المتقدم

### تكامل Flask API

```python
from flask import Flask, jsonify, request
from autoscraper import AutoScraper

app = Flask(__name__)

# مثيل scraper عام
scraper = AutoScraper()

@app.route('/train', methods=['POST'])
def train_scraper():
    data = request.json
    url = data.get('url')
    wanted_list = data.get('wanted_list')
    
    try:
        scraper.build(url, wanted_list)
        return jsonify({'status': 'success', 'message': 'تم تدريب النموذج بنجاح'})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 400

@app.route('/scrape', methods=['POST'])
def scrape_data():
    data = request.json
    url = data.get('url')
    mode = data.get('mode', 'similar')  # 'similar' أو 'exact'
    
    try:
        if mode == 'similar':
            result = scraper.get_result_similar(url)
        else:
            result = scraper.get_result_exact(url)
        
        return jsonify({'status': 'success', 'data': result})
    except Exception as e:
        return jsonify({'status': 'error', 'message': str(e)}), 400

if __name__ == '__main__':
    app.run(debug=True)
```

### تكامل قاعدة البيانات

```python
import sqlite3
from autoscraper import AutoScraper

class ScrapingDatabase:
    def __init__(self, db_path='scraping_data.db'):
        self.db_path = db_path
        self.init_database()
    
    def init_database(self):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute('''
            CREATE TABLE IF NOT EXISTS scraped_data (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                url TEXT NOT NULL,
                data TEXT NOT NULL,
                timestamp DATETIME DEFAULT CURRENT_TIMESTAMP
            )
        ''')
        
        conn.commit()
        conn.close()
    
    def save_scraped_data(self, url, data):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        cursor.execute(
            'INSERT INTO scraped_data (url, data) VALUES (?, ?)',
            (url, json.dumps(data))
        )
        
        conn.commit()
        conn.close()
    
    def get_scraped_data(self, url=None):
        conn = sqlite3.connect(self.db_path)
        cursor = conn.cursor()
        
        if url:
            cursor.execute('SELECT * FROM scraped_data WHERE url = ?', (url,))
        else:
            cursor.execute('SELECT * FROM scraped_data ORDER BY timestamp DESC')
        
        results = cursor.fetchall()
        conn.close()
        
        return results

# الاستخدام
db = ScrapingDatabase()
scraper = AutoScraper()

# التدريب والاستخراج
scraper.build('https://example.com', ['sample data'])
result = scraper.get_result_similar('https://another-site.com')

# الحفظ في قاعدة البيانات
db.save_scraped_data('https://another-site.com', result)
```

## الخلاصة

AutoScraper هي أداة قوية ثورية تبسط عملية استخراج البيانات من الويب بشكل كبير. مع التعلم الآلي لتعلم القواعد تلقائياً، يمكنك بسهولة استخراج البيانات المطلوبة دون CSS selectors معقدة أو XPath.

### المزايا الرئيسية

- **منحنى تعلم منخفض**: قابل للاستخدام دون معرفة عميقة في استخراج البيانات من الويب
- **المرونة**: قابل للتطبيق على مواقع ويب وأنواع بيانات متنوعة
- **إعادة الاستخدام**: إعادة استخدام النماذج المُتعلمة عبر مواقع متعددة
- **القابلية للتوسع**: مناسب لعمليات الاستخراج واسعة النطاق

### حالات الاستخدام

- **جمع البيانات**: جمع الأخبار ومعلومات المنتجات وبيانات الأسعار
- **المراقبة**: تتبع تغييرات المواقع
- **البحث**: تحليل بيانات الويب والبحث
- **الأعمال**: تحليل المنافسين وأبحاث السوق

باستخدام AutoScraper، يمكنك تقليل تعقيد استخراج البيانات من الويب بشكل كبير والتركيز أكثر على تحليل البيانات واستخراج الرؤى.

فكر في AutoScraper عند بدء مشاريع استخراج البيانات من الويب. يمكنك بناء أنظمة استخراج قوية ببضعة أسطر من الكود فقط.

---

**المراجع:**
- [مستودع AutoScraper على GitHub](https://github.com/alirezamika/autoscraper)
- [صفحة AutoScraper على PyPI](https://pypi.org/project/autoscraper/)
- [دليل أفضل الممارسات لاستخراج البيانات من الويب](https://docs.python.org/3/library/urllib.html)
