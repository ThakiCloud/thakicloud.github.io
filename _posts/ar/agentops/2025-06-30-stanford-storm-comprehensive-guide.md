---
title: "Stanford STORM: دليل شامل لنظام وكيل تنظيم المعرفة المعتمد على LLM"
excerpt: "تحليل كامل لـ STORM وCo-STORM المطوَّرَين في جامعة Stanford. دليل عملي يشمل البحث الآلي، وإنشاء التقارير، وأنظمة الاستشهاد، ووكلاء الذكاء الاصطناعي التعاونيين."
seo_title: "دليل Stanford STORM الشامل - نظام وكيل تنظيم المعرفة بـ LLM - Thaki Cloud"
seo_description: "تحليل كامل لمشروع Stanford STORM. بحث آلي، إنشاء تقارير على غرار Wikipedia، وكلاء AI تعاونيون، ودليل النشر الإنتاجي. كيفية استخدام المشروع مفتوح المصدر بـ 25.4k نجمة."
date: 2025-06-30
last_modified_at: 2025-06-30
categories:
  - agentops
tags:
  - stanford-storm
  - knowledge-curation
  - llm-agents
  - report-generation
  - collaborative-ai
  - retrieval-augmented-generation
  - agentic-rag
  - research-automation
  - wikipedia-generation
  - multi-agent-system
author_profile: true
toc: true
toc_label: "جدول المحتويات"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/agentops/stanford-storm-comprehensive-guide/"
lang: ar
published: false
---

⏱️ **وقت القراءة المقدر**: 10 دقائق

## مقدمة

**STORM (تركيب مخططات الموضوعات من خلال الاسترجاع وطرح الأسئلة متعددة المنظورات)** المطوَّر في جامعة Stanford هو نظام وكيل تنظيم المعرفة المعتمد على LLM. بـ **25.4k نجمة على GitHub**، يُعدّ هذا المشروع نظاماً مبتكراً يبحث في الموضوعات بشكل آلي ويولّد تقارير كاملة مع الاستشهادات.

**STORM** ليس مجرد منشئ نصوص. إنه **نظام وكيل ذكي** يطرح أسئلة من منظورات متنوعة، ويجمع المعلومات، وينظمها بشكل منهجي لإنتاج تقارير بجودة Wikipedia.

## نظرة عامة على نظام STORM

### الميزات الجوهرية

يتميز **STORM** بالخصائص المبتكرة التالية:

- **بحث آلي**: جمع معلومات متعدد الزوايا حول موضوع ما
- **نظام استشهاد**: نسب المصدر لجميع المحتويات
- **تنظيم هيكلي**: مخططات هرمية على غرار Wikipedia
- **منظورات متعددة**: المقاربة من وجهات نظر خبراء مختلفين
- **الوضع التعاوني**: دعم التعاون بين الإنسان والذكاء الاصطناعي عبر Co-STORM
- **التخصيص**: قابل للتطبيق في مجالات متنوعة

## التثبيت والاستخدام

### 1. التثبيت

```bash
# تثبيت بسيط عبر pip
pip install knowledge-storm

# أو التثبيت من المصدر
git clone https://github.com/stanford-oval/storm.git
cd storm
pip install -r requirements.txt
pip install -e .
```

### 2. إعداد مفاتيح API

```toml
# إنشاء ملف secrets.toml
OPENAI_API_KEY="your_openai_api_key"
OPENAI_API_TYPE="openai"
BING_SEARCH_API_KEY="your_bing_search_api_key"
ENCODER_API_TYPE="openai"
```

### 3. الاستخدام الأساسي لـ STORM

```python
# مثال على الاستخدام الأساسي
from knowledge_storm import STORMWikiRunnerArguments, STORMWikiRunner
from knowledge_storm import STORMWikiLMConfigs

lm_configs = STORMWikiLMConfigs()
runner_args = STORMWikiRunnerArguments(
    output_dir="./storm_output",
    max_conv_turn=5,
    max_perspective=5
)

runner = STORMWikiRunner(lm_configs)

topic = "الذكاء الاصطناعي في الرعاية الصحية"
runner.run(
    topic=topic,
    do_research=True,
    do_generate_outline=True,
    do_generate_article=True,
    do_polish_article=True
)
```

### 4. واجهة سطر الأوامر

```bash
# تشغيل آلي كامل
python examples/storm_examples/run_storm_wiki_gpt.py \
    --output-dir ./results \
    --retriever bing \
    --do-research \
    --do-generate-outline \
    --do-generate-article \
    --do-polish-article
```

## المعمارية: 4 وحدات جوهرية

```python
# وحدة تنظيم المعرفة
class KnowledgeCurationModule:
    def collect_information(self, topic):
        perspectives = self.generate_perspectives(topic)
        collected_info = []
        for perspective in perspectives:
            queries = self.generate_queries(topic, perspective)
            for query in queries:
                results = self.retriever.search(query)
                collected_info.extend(results)
        return self.deduplicate_and_filter(collected_info)

# وحدة توليد المخطط
class OutlineGenerationModule:
    def generate_outline(self, collected_info, topic):
        key_concepts = self.extract_key_concepts(collected_info)
        hierarchy = self.build_hierarchy(key_concepts)
        return {
            "title": topic,
            "sections": [
                {
                    "title": s["title"],
                    "subsections": s["subsections"],
                    "key_points": s["key_points"]
                }
                for s in hierarchy
            ]
        }
```

## Co-STORM: نظام الذكاء الاصطناعي التعاوني

### نظرة عامة على Co-STORM

**Co-STORM** هو نظام مبتكر لتنظيم المعرفة بالتعاون بين الإنسان والذكاء الاصطناعي:

- **حوار في الوقت الفعلي**: محادثة بين المستخدم ووكلاء AI
- **خبراء متعددون**: تعاون عدة خبراء من AI
- **مشاركة المستخدم**: إمكانية التدخل في الحوار في أي وقت
- **التعديل الديناميكي**: تعديل الاتجاه بناءً على ملاحظات المستخدم

```python
from knowledge_storm import CoStormRunner

costorm_runner = CoStormRunner(
    args=costorm_args,
    lm_configs=lm_configs,
    rm=rm,
    topic=topic
)

costorm_runner.warm_start()
conv_turn = costorm_runner.step()
costorm_runner.step(user_utterance="تعليق المستخدم")

costorm_runner.knowledge_base.reorganize()
article = costorm_runner.generate_report()
```

## النشر الإنتاجي

### Dockerfile لـ STORM

```dockerfile
FROM python:3.9-slim

RUN apt-get update && apt-get install -y git build-essential \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
RUN pip install knowledge-storm

COPY . .
ENV PYTHONPATH=/app
EXPOSE 8000
CMD ["python", "storm_server.py"]
```

### نشر على Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: storm-api
spec:
  replicas: 3
  selector:
    matchLabels:
      app: storm-api
  template:
    metadata:
      labels:
        app: storm-api
    spec:
      containers:
      - name: storm-api
        image: your-registry/storm-api:latest
        ports:
        - containerPort: 8000
        env:
        - name: OPENAI_API_KEY
          valueFrom:
            secretKeyRef:
              name: storm-secrets
              key: openai-api-key
        resources:
          requests:
            memory: "2Gi"
            cpu: "1000m"
          limits:
            memory: "4Gi"
            cpu: "2000m"
```

## مجموعات البيانات والمعايير

### مجموعة بيانات FreshWiki

**FreshWiki** هي مجموعة بيانات عالية الجودة لتقييم STORM:

- **الحجم**: 100 مقال Wikipedia عالي الجودة
- **الفترة**: الصفحات الأكثر تحريراً من فبراير 2022 إلى سبتمبر 2023
- **الاستخدام**: بحث تنظيم المعرفة الآلي

## المقارنة: STORM مقابل الأنظمة الموجودة

| الميزة | STORM | ChatGPT | Claude | Perplexity |
|--------|-------|---------|--------|------------|
| بحث آلي | نعم | لا | لا | نعم |
| مخطط هيكلي | نعم | لا | لا | لا |
| نظام استشهاد | نعم | لا | لا | نعم |
| منظورات متعددة | نعم | لا | لا | لا |
| الوضع التعاوني | نعم | لا | لا | لا |
| التخصيص | نعم | لا | لا | لا |

## الخلاصة

**Stanford STORM** هو نظام مبتكر يقدم نموذجاً جديداً لتنظيم المعرفة.

### المزايا الرئيسية

1. **نهج منهجي**: خط أنابيب معياري من 4 مراحل
2. **منظورات متعددة**: جمع المعلومات من وجهات نظر خبراء مختلفين
3. **نظام استشهاد**: نسب المصدر لجميع المحتويات
4. **ميزات تعاونية**: التعاون بين الإنسان والذكاء الاصطناعي عبر Co-STORM
5. **التخصيص**: قابل للتطبيق في مجالات متنوعة
6. **مفتوح المصدر**: استخدام مجاني تحت رخصة MIT

---

**روابط مرجعية**:
- [مستودع STORM على GitHub](https://github.com/stanford-oval/storm)
- [الموقع الرسمي لـ STORM](https://storm.genie.stanford.edu)
- [ورقة NAACL 2024](https://aclanthology.org/2024.naacl-long.347/)
- [ورقة Co-STORM EMNLP 2024](https://aclanthology.org/2024.emnlp-main.554/)
