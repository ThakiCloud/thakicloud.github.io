---
title: "دليل المهارات الأساسية لمهندسي التعلم الآلي - قائمة مرجعية ضرورية للمجندين والمرشحين"
excerpt: "دليل عملي يوضح المجموعة التقنية الأساسية والكفاءات المطلوبة لبناء تطبيقات التعلم الآلي في بيئات الإنتاج"
seo_title: "دليل المهارات الأساسية لمهندس التعلم الآلي - قائمة التوظيف - Thaki Cloud"
seo_description: "دليل التوظيف المبني على Made-With-ML لكفاءات مهندس التعلم الآلي الأساسية والمجموعة التقنية ومتطلبات الخبرة العملية"
date: 2025-07-08
last_modified_at: 2025-07-08
categories:
  - careers
tags:
  - مهندس-التعلم-الآلي
  - دليل-المهنة
  - متطلبات-الوظيفة
  - المهارات-التقنية
  - التعلم-الآلي
  - MLOps
  - التوظيف
  - الإنتاج-ML
author_profile: true
toc: true
toc_label: "جدول المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/careers/ml-engineer-essential-skills-guide/"
reading_time: true
lang: ar
permalink: /ar/careers/ml-engineer-essential-skills-guide/
---

⏱️ **الوقت المقدر للقراءة**: 12 دقيقة

## المقدمة

مع تزايد أهمية تقنية الذكاء الاصطناعي/التعلم الآلي بسرعة في المؤسسات الحديثة، هناك طلب متفجر على المهندسين الذين يمكنهم تجاوز مجرد إنشاء النماذج إلى **بناء أنظمة التعلم الآلي التي تعمل فعلاً في بيئات الإنتاج**.

يوفر مشروع [Made-With-ML](https://github.com/GokuMohandas/Made-With-ML)، الذي حصل على 40.6 ألف نجمة على GitHub، دليلاً عملياً لهندسة التعلم الآلي يعكس هذا الواقع. هذا المنشور هو دليل توظيف يوضح **الكفاءات الأساسية التي يجب أن يمتلكها مهندسو التعلم الآلي في شركتنا** بناءً على المحتوى الأساسي لذلك المشروع.

## لماذا نحتاج هذا الدليل؟

### المشاكل الحالية في سوق التوظيف

```python
# مشاكل إعلانات الوظائف التقليدية
traditional_requirements = {
    "machine_learning": "القدرة على استخدام PyTorch، TensorFlow",
    "programming": "خبرة في برمجة Python",
    "theory": "معرفة الإحصاء والنظرية الرياضية",
    "experience": "3 سنوات من خبرة تحليل البيانات"
}

# ما هو مطلوب فعلاً في الإنتاج
production_requirements = {
    "full_stack_ml": "العملية الشاملة من التصميم إلى النشر إلى العمليات",
    "engineering": "تطبيق مبادئ هندسة البرمجيات",
    "scalability": "خبرة في بناء أنظمة واسعة النطاق",
    "reliability": "القدرة على تشغيل خدمات مستقرة"
}
```

### النموذج الجديد المقترح من Made-With-ML

يقدم [Made-With-ML](https://github.com/GokuMohandas/Made-With-ML) كيفية بناء أنظمة التعلم الآلي في بيئات الإنتاج الفعلية من خلال عملية من 4 مراحل: **التصميم · التطوير · النشر · التكرار**.

## قائمة مرجعية للكفاءات الأساسية

### 1. البرمجة الأساسية وبيئة التطوير (الأساس)

#### المجموعة التقنية الأساسية
```python
# إتقان النظام البيئي لـ Python
python_skills = {
    "core": ["Python 3.8+", "Type hints", "Async/await"],
    "data_science": ["NumPy", "Pandas", "Scikit-learn"],
    "deep_learning": ["PyTorch", "Transformers", "Ray"],
    "web": ["FastAPI", "Pydantic", "Uvicorn"],
    "testing": ["pytest", "unittest", "coverage"],
    "packaging": ["pip", "conda", "poetry", "requirements.txt"]
}
```

#### إدارة بيئة التطوير
- **إدارة البيئة الافتراضية**: conda، virtualenv، poetry
- **إدارة التبعيات**: requirements.txt، pyproject.toml
- **جودة الكود**: pre-commit hooks، linting، formatting
- **بيئة Jupyter**: الاستخدام الفعال للدفاتر

### 2. هندسة البيانات

#### بناء خط أنابيب البيانات
```python
# مثال على خط أنابيب معالجة البيانات
class DataProcessor:
    def __init__(self, config: DataConfig):
        self.config = config
    
    def extract_data(self) -> pd.DataFrame:
        """استخراج البيانات من مصادر مختلفة"""
        pass
    
    def transform_data(self, df: pd.DataFrame) -> pd.DataFrame:
        """معالجة البيانات مسبقاً وتحويلها"""
        pass
    
    def validate_data(self, df: pd.DataFrame) -> bool:
        """التحقق من جودة البيانات"""
        pass
    
    def load_data(self, df: pd.DataFrame) -> None:
        """حفظ البيانات المعالجة مسبقاً"""
        pass
```

#### الكفاءات الأساسية
- **إدارة جودة البيانات**: التحقق من البيانات، اكتشاف القيم الشاذة
- **معالجة البيانات المتدفقة**: خطوط أنابيب البيانات في الوقت الفعلي
- **التحكم في إصدار البيانات**: استخدام DVC، Git-LFS
- **معالجة البيانات واسعة النطاق**: المعالجة الموزعة مع Ray، Dask

### 3. تطوير النماذج والتدريب

#### مبادئ تصميم النماذج
```python
# مثال على تصميم هيكل النموذج
class ProductionModel:
    def __init__(self, config: ModelConfig):
        self.config = config
        self.model = self._build_model()
    
    def _build_model(self) -> torch.nn.Module:
        """هيكل نموذج قابل للتوسع"""
        pass
    
    def train(self, train_data: DataLoader) -> Dict[str, float]:
        """عملية تدريب قابلة للتكرار"""
        pass
    
    def evaluate(self, test_data: DataLoader) -> Dict[str, float]:
        """تقييم شامل للنموذج"""
        pass
    
    def save_model(self, path: str) -> None:
        """حفظ نقطة تفتيش النموذج"""
        pass
```

#### التقنيات الأساسية
- **التدريب الموزع**: Ray Train، PyTorch Distributed
- **ضبط المعاملات الفائقة**: Ray Tune، Optuna
- **تحسين النموذج**: التكميم، التقليم، تقطير المعرفة
- **إدارة التجارب**: MLflow، Weights & Biases

### 4. نشر النماذج والخدمة

#### هيكل الخدمة في الإنتاج
```python
# خدمة النموذج المبنية على FastAPI
from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
import ray
from ray import serve

@serve.deployment
@serve.ingress(app)
class MLService:
    def __init__(self, model_path: str):
        self.model = self.load_model(model_path)
    
    @app.post("/predict")
    async def predict(self, request: PredictionRequest) -> PredictionResponse:
        try:
            result = await self.model.predict(request.data)
            return PredictionResponse(prediction=result)
        except Exception as e:
            raise HTTPException(status_code=500, detail=str(e))
```

#### استراتيجيات النشر
- **الحاويات**: Docker، Kubernetes
- **تصميم API**: RESTful API، GraphQL
- **توزيع الأحمال**: Ray Serve، Nginx
- **المراقبة**: Prometheus، Grafana

### 5. MLOps والبنية التحتية

#### خط أنابيب CI/CD
```yaml
# مثال على GitHub Actions
name: ML Pipeline
on:
  push:
    branches: [main]
  pull_request:
    branches: [main]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.9'
      - name: Install dependencies
        run: |
          pip install -r requirements.txt
      - name: Run tests
        run: |
          pytest tests/ --cov=madewithml --cov-report=xml
      - name: Data tests
        run: |
          pytest tests/data --dataset-loc=$DATASET_LOC
      - name: Model tests
        run: |
          pytest tests/model --run-id=$RUN_ID
```

#### إدارة العمليات
- **التحكم في إصدار النموذج**: سجل النماذج، اختبار A/B
- **مراقبة الأداء**: تتبع زمن الاستجابة والإنتاجية والدقة
- **الاستجابة للحوادث**: التراجع، النشر التدريجي
- **تحسين التكلفة**: التوسع التلقائي، إدارة الموارد

## معايير تقييم الخبرة العملية

### 1. المستوى المبتدئ (1-2 سنة خبرة)

#### الكفاءات الأساسية
```python
junior_requirements = {
    "programming": {
        "python": "الصيغة الأساسية، البرمجة الكائنية",
        "data_handling": "استخدام Pandas، NumPy",
        "visualization": "استخدام Matplotlib، Seaborn"
    },
    "ml_basics": {
        "algorithms": "فهم التعلم المُشرف/غير المُشرف",
        "frameworks": "أساسيات Scikit-learn، PyTorch",
        "evaluation": "فهم التحقق المتقاطع ومقاييس الأداء"
    },
    "tools": {
        "version_control": "أوامر Git الأساسية",
        "environment": "استخدام Jupyter، VSCode",
        "documentation": "كتابة README، تعليقات الكود"
    }
}
```

#### مشاكل التقييم النموذجية
```python
# معالجة البيانات مسبقاً وتدريب النموذج
def evaluate_junior_candidate():
    """
    مهمة إنشاء نموذج تصنيف مع مجموعة بيانات معطاة
    وتقييم الأداء
    """
    tasks = [
        "استكشاف البيانات والتصور",
        "بناء خط أنابيب المعالجة المسبقة",
        "تدريب النموذج والتقييم",
        "تفسير النتائج واقتراحات التحسين"
    ]
    return tasks
```

### 2. المستوى المتوسط (3-5 سنوات خبرة)

#### الكفاءات الأساسية
```python
mid_level_requirements = {
    "engineering": {
        "architecture": "التقسيم إلى وحدات، تصميم الفئات",
        "testing": "اختبار الوحدة، اختبار التكامل",
        "optimization": "تحسين الكود، التحليل"
    },
    "ml_engineering": {
        "pipelines": "بناء خط أنابيب شامل",
        "deployment": "خدمة API، نشر الحاويات",
        "monitoring": "تتبع أداء النموذج"
    },
    "collaboration": {
        "code_review": "المشاركة في مراجعة الكود",
        "documentation": "كتابة الوثائق التقنية",
        "mentoring": "توجيه المطورين المبتدئين"
    }
}
```

#### مشاكل التقييم النموذجية
```python
# تصميم نظام الإنتاج
def evaluate_mid_level_candidate():
    """
    مهمة تصميم وتنفيذ نظام التعلم الآلي
    القابل للنشر في الخدمة الفعلية
    """
    tasks = [
        "تصميم هيكل النظام",
        "تنفيذ نقطة نهاية API",
        "كتابة كود الاختبار",
        "تكوين حاوية Docker",
        "بناء لوحة مراقبة"
    ]
    return tasks
```

### 3. المستوى الأول (5+ سنوات خبرة)

#### الكفاءات الأساسية
```python
senior_requirements = {
    "leadership": {
        "architecture": "تصميم هيكل النظام",
        "decision_making": "قيادة اتخاذ القرارات التقنية",
        "team_leading": "خبرة قيادة الفريق"
    },
    "advanced_ml": {
        "research": "فهم أحدث اتجاهات البحث",
        "optimization": "تحسين الأنظمة واسعة النطاق",
        "innovation": "إدخال تقنيات جديدة"
    },
    "business": {
        "strategy": "ربط أهداف العمل بالتكنولوجيا",
        "communication": "التواصل مع غير المطورين",
        "project_management": "إدارة المشاريع"
    }
}
```

## دليل أسئلة المقابلة

### 1. أسئلة المقابلة التقنية

#### أسئلة تصميم النظام
```python
# تصميم نظام التوصيات واسع النطاق
interview_questions = {
    "system_design": [
        "صمم نظام توصيات لـ 100 مليون مستخدم",
        "كيف ستبني نظام تعلم عبر الإنترنت يعكس التغذية الراجعة في الوقت الفعلي؟",
        "اشرح استراتيجية نشر النموذج لاختبار A/B"
    ],
    "optimization": [
        "كيف ستقلل زمن استنتاج النموذج إلى أقل من 10 مللي ثانية؟",
        "كيف ستحل مشاكل نقص ذاكرة GPU؟",
        "كيفية تقليل عبء الاتصال في التدريب الموزع؟"
    ],
    "troubleshooting": [
        "كيف ستستجيب عندما ينخفض أداء النموذج فجأة في الإنتاج؟",
        "كيفية اكتشاف والاستجابة لانحراف البيانات؟",
        "كيف ستقيم وتحسن التحيز في نتائج تنبؤ النموذج؟"
    ]
}
```

### 2. مشاكل اختبار البرمجة

#### تحديات البرمجة العملية
```python
# تنفيذ API خدمة النموذج
class CodingChallenge:
    def __init__(self):
        self.tasks = [
            "تنفيذ API خدمة النموذج مع FastAPI",
            "التحقق من بيانات الإدخال والمعالجة المسبقة",
            "تحسين التنبؤ المجمع",
            "معالجة الأخطاء والتسجيل",
            "كتابة اختبار الوحدة"
        ]
    
    def evaluate_solution(self, solution: str) -> Dict[str, float]:
        """
        تقييم الحل بناءً على:
        - جودة الكود (30%)
        - تحسين الأداء (25%)
        - معالجة الأخطاء (20%)
        - كود الاختبار (15%)
        - الوثائق (10%)
        """
        pass
```

## تعريفات أدوار الفريق

### 1. مهندس بحث التعلم الآلي
```python
research_engineer_role = {
    "primary_focus": "البحث وتنفيذ هياكل النماذج الجديدة",
    "required_skills": [
        "القدرة على تنفيذ الأوراق البحثية",
        "تصميم وتحليل التجارب",
        "استخدام PyTorch المتقدم",
        "خبرة التدريب الموزع"
    ],
    "deliverables": [
        "معايير نماذج SOTA",
        "هياكل نماذج مخصصة",
        "تقارير تحليل نتائج التجارب"
    ]
}
```

### 2. مهندس منصة التعلم الآلي
```python
platform_engineer_role = {
    "primary_focus": "بناء البنية التحتية ومنصة التعلم الآلي",
    "required_skills": [
        "Kubernetes، Docker",
        "خدمات السحابة (AWS، GCP)",
        "خطوط أنابيب CI/CD",
        "أنظمة المراقبة"
    ],
    "deliverables": [
        "أتمتة خط أنابيب التعلم الآلي",
        "أنظمة نشر النماذج",
        "لوحات مراقبة الأداء"
    ]
}
```

### 3. مهندس MLOps
```python
mlops_engineer_role = {
    "primary_focus": "إدارة دورة حياة النموذج",
    "required_skills": [
        "MLflow، Kubeflow",
        "التحكم في إصدار النموذج",
        "تصميم اختبار A/B",
        "مراقبة انحراف البيانات"
    ],
    "deliverables": [
        "إدارة سجل النماذج",
        "أنظمة إعادة التدريب التلقائي",
        "أنظمة تنبيه تدهور الأداء"
    ]
}
```

## خريطة طريق التعلم

### 1. دليل التعلم خطوة بخطوة

#### المرحلة 1: الأساس (2-3 أشهر)
```python
foundation_learning_path = {
    "week_1_4": {
        "topic": "Python والأدوات الأساسية",
        "resources": [
            "صيغة Python المتقدمة",
            "Git & GitHub",
            "Jupyter Lab",
            "إعداد VS Code"
        ]
    },
    "week_5_8": {
        "topic": "أساسيات علم البيانات",
        "resources": [
            "NumPy، Pandas",
            "Matplotlib، Seaborn",
            "أساسيات الإحصاء",
            "معالجة البيانات مسبقاً"
        ]
    },
    "week_9_12": {
        "topic": "أساسيات التعلم الآلي",
        "resources": [
            "Scikit-learn",
            "تقييم النموذج",
            "التحقق المتقاطع",
            "ضبط المعاملات الفائقة"
        ]
    }
}
```

#### المرحلة 2: المتوسط (3-4 أشهر)
```python
intermediate_learning_path = {
    "month_1": {
        "topic": "التعلم العميق و PyTorch",
        "projects": [
            "نموذج تصنيف الصور",
            "أساسيات معالجة اللغة الطبيعية",
            "ممارسة التعلم بالنقل"
        ]
    },
    "month_2": {
        "topic": "تطوير الويب و API",
        "projects": [
            "أساسيات FastAPI",
            "API خدمة النموذج",
            "تكامل قاعدة البيانات"
        ]
    },
    "month_3": {
        "topic": "الحاويات والنشر",
        "projects": [
            "أساسيات Docker",
            "حاوية النموذج",
            "النشر السحابي"
        ]
    }
}
```

#### المرحلة 3: المتقدم (4-6 أشهر)
```python
advanced_learning_path = {
    "quarter_1": {
        "topic": "الأنظمة الموزعة والتوسع",
        "projects": [
            "التدريب الموزع مع Ray",
            "نشر Kubernetes",
            "أنظمة المراقبة"
        ]
    },
    "quarter_2": {
        "topic": "أنظمة الإنتاج",
        "projects": [
            "تنفيذ مشروع Made-With-ML",
            "خطوط أنابيب CI/CD",
            "أنظمة اختبار A/B"
        ]
    }
}
```

## محفظة المشاريع العملية

### 1. قائمة المشاريع الأساسية

#### محفظة المبتدئ
```python
junior_portfolio = {
    "project_1": {
        "title": "مشروع تصنيف شامل",
        "description": "من جمع البيانات إلى نشر النموذج",
        "tech_stack": ["Python", "Pandas", "Scikit-learn", "FastAPI"],
        "github_example": "https://github.com/your-repo/classification-project"
    },
    "project_2": {
        "title": "مصنف صور التعلم العميق",
        "description": "نموذج CNN باستخدام PyTorch",
        "tech_stack": ["PyTorch", "torchvision", "Streamlit"],
        "github_example": "https://github.com/your-repo/image-classifier"
    }
}
```

#### محفظة المستوى المتوسط
```python
mid_level_portfolio = {
    "project_1": {
        "title": "نظام التدريب الموزع",
        "description": "معالجة البيانات الموزعة واسعة النطاق",
        "tech_stack": ["Ray", "PyTorch", "Docker"],
        "github_example": "https://github.com/your-repo/distributed-training"
    },
    "project_2": {
        "title": "نظام التوصيات في الوقت الفعلي",
        "description": "معالجة البيانات المتدفقة",
        "tech_stack": ["Kafka", "Redis", "FastAPI", "Kubernetes"],
        "github_example": "https://github.com/your-repo/recommendation-system"
    }
}
```

### 2. معايير تقييم المشروع

#### قائمة مرجعية لجودة الكود
```python
def evaluate_project_quality(project_repo: str) -> Dict[str, bool]:
    """قائمة مرجعية لتقييم جودة المشروع"""
    criteria = {
        "code_structure": "هيكل كود مقسم إلى وحدات",
        "documentation": "اكتمال README، docstring",
        "testing": "تغطية اختبار الوحدة > 80%",
        "ci_cd": "إعداد GitHub Actions",
        "containerization": "تكوين حاوية Docker",
        "monitoring": "تنفيذ التسجيل والمراقبة",
        "scalability": "هيكل قابل للتوسع"
    }
    return criteria
```

## دليل عملية التوظيف

### 1. قائمة مرجعية لفحص الوثائق

#### معايير تقييم السيرة الذاتية
```python
resume_evaluation_criteria = {
    "education": {
        "preferred": ["علوم الحاسوب", "الإحصاء", "الرياضيات", "الفيزياء"],
        "alternative": ["Bootcamp", "دورات عبر الإنترنت", "الشهادات"],
        "weight": 20
    },
    "experience": {
        "ml_projects": "عدد خبرات مشاريع التعلم الآلي",
        "production_experience": "خبرة النشر في الإنتاج",
        "collaboration": "خبرة مشاريع الفريق",
        "weight": 40
    },
    "technical_skills": {
        "programming": "إتقان Python، SQL",
        "ml_frameworks": "خبرة PyTorch، TensorFlow",
        "cloud_platforms": "خبرة AWS، GCP، Azure",
        "weight": 30
    },
    "portfolio": {
        "github_activity": "تكرار نشاط GitHub",
        "project_quality": "اكتمال المشروع",
        "documentation": "مستوى الوثائق",
        "weight": 10
    }
}
```

### 2. عملية المقابلة التقنية

#### هيكل المقابلة من 3 مراحل
```python
interview_process = {
    "stage_1": {
        "type": "الفحص التقني",
        "duration": "ساعة واحدة",
        "format": "مقابلة فيديو",
        "content": [
            "أسئلة المفاهيم الأساسية",
            "اختبار البرمجة (البرمجة المباشرة)",
            "مشاركة خبرة المشروع"
        ]
    },
    "stage_2": {
        "type": "مقابلة تقنية متقدمة",
        "duration": "ساعتان",
        "format": "شخصياً أو فيديو",
        "content": [
            "مشاكل تصميم النظام",
            "حل مشاكل الحالات العملية",
            "جلسة مراجعة الكود"
        ]
    },
    "stage_3": {
        "type": "التوافق الثقافي والمقابلة النهائية",
        "duration": "ساعة واحدة",
        "format": "لقاء مع أعضاء الفريق",
        "content": [
            "مهارات العمل الجماعي والتواصل",
            "الرغبة في التعلم وعقلية النمو",
            "التوافق مع رؤية الشركة"
        ]
    }
}
```

## الخلاصة والخطوات التالية

### ملخص النقاط الرئيسية

1. **الكفاءات العملية**: القدرة على حل المشاكل في بيئات الإنتاج الفعلية بدلاً من المعرفة النظرية
2. **فهم خط الأنابيب الشامل**: الفهم من جمع البيانات إلى نشر النموذج والمراقبة
3. **هندسة البرمجيات**: الأساسيات مثل جودة الكود والاختبار والوثائق والتحكم في الإصدار
4. **التعلم المستمر**: القدرة على التكيف مع اتجاهات التكنولوجيا المتغيرة بسرعة

### عناصر العمل للمجندين

```python
action_items_for_recruiters = [
    "تحديث JD الحالي بناءً على معايير Made-With-ML",
    "بناء بنك أسئلة المقابلة التقنية",
    "إنشاء منصة اختبار البرمجة",
    "تضمين المشاريع العملية في برنامج التأهيل",
    "التخطيط لجلسات تحديث اتجاهات التكنولوجيا المنتظمة"
]
```

### خريطة طريق التعلم للمرشحين

```python
learning_roadmap_for_candidates = [
    "إكمال مشروع Made-With-ML",
    "إكمال 3+ مشاريع محفظة شخصية",
    "خبرة المساهمة في مشروع مفتوح المصدر",
    "تشغيل مدونة تقنية أو خبرة العرض",
    "تراكم خبرة النشر في الإنتاج الفعلي"
]
```

## المراجع

- [مستودع Made-With-ML على GitHub](https://github.com/GokuMohandas/Made-With-ML) - دليل التعلم الآلي في الإنتاج بـ 40.6 ألف نجمة
- [وثائق Ray](https://docs.ray.io/) - إطار عمل التعلم الآلي الموزع
- [مجتمع MLOps](https://mlops.community/) - مجتمع MLOps العملي
- [Papers with Code](https://paperswithcode.com/) - أحدث اتجاهات بحث التعلم الآلي

---

هذا الدليل منظم حول النهج العملي لمشروع Made-With-ML، مع التركيز على الكفاءات المطلوبة في بيئات الإنتاج الفعلية. سنواصل تحديثه ودمج التغذية الراجعة من الميدان.
