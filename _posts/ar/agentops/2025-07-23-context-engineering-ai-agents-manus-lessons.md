---
title: "هندسة السياق لوكلاء الذكاء الاصطناعي: دروس عملية من بناء Manus"
excerpt: "تحليل تفصيلي لاستراتيجيات تحسين السياق والمبادئ الأساسية لوكلاء الذكاء الاصطناعي في بيئة الإنتاج، مستوحى من تجربة فريق Manus في إعادة بناء إطارهم أربع مرات."
seo_title: "دليل عملي لهندسة السياق لوكلاء الذكاء الاصطناعي - دراسة حالة Manus - Thaki Cloud"
seo_description: "تعلّم استراتيجيات هندسة السياق المثبتة من تجربة بناء Manus: تحسين KV-cache، إدارة الأدوات الديناميكية، توظيف نظام الملفات، والمزيد لتطوير وكلاء الذكاء الاصطناعي."
date: 2025-07-23
last_modified_at: 2025-07-23
lang: ar
categories:
  - agentops
  - llmops
tags:
  - AI에이전트
  - 컨텍스트엔지니어링
  - LLM최적화
  - KV캐시
  - 프로덕션AI
  - Manus
  - 도구관리
  - 에이전트프레임워크
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/agentops/context-engineering-ai-agents-manus-lessons/"
reading_time: true
---

⏱️ **وقت القراءة المقدر**: 12 دقيقة

## مقدمة

أحد أصعب الخيارات في تطوير وكلاء الذكاء الاصطناعي هو الموازنة بين تدريب النموذج وهندسة السياق. من خلال التجربة الميدانية التي شاركها Yichao 'Peak' Ji من فريق Manus AI، يمكننا استكشاف استراتيجيات تحسين السياق المُثبَتة في بيئات الإنتاج.

شهد فريق Manus التحوّل من حقبة BERT إلى GPT-3، وتوصّل إلى استراتيجية التحسين الحالية عبر نهج تجريبي يسمّونه "Stochastic Graduate Descent"، بعد إعادة بناء إطارهم أربع مرات.

## التصميم المحوري على KV-Cache: المقياس الأهم لوكلاء الإنتاج

### لماذا تهم نسبة إصابة KV-Cache؟

بالنسبة لوكيل الذكاء الاصطناعي في مرحلة الإنتاج، تعد نسبة إصابة KV-cache المقياس الأهم للأداء، لأنها تؤثر مباشرةً على زمن الاستجابة والتكلفة.

سير عمل مهمة وكيل نموذجي:
1. استقبال مدخل المستخدم
2. اختيار إجراء بناءً على السياق الحالي
3. تنفيذ الإجراء في البيئة وتوليد ملاحظة
4. إضافة زوج الإجراء والملاحظة إلى السياق
5. التكرار حتى اكتمال المهمة

**بيانات Manus الفعلية**: نسبة متوسطة للرموز المدخلة إلى المخرجة تبلغ 100:1

### التأثير الفعلي على تحسين التكلفة

مقارنة التكاليف باستخدام Claude Sonnet مرجعاً:
- رموز المدخلات المخزنة مؤقتاً: 0.30 دولار/مليون رمز
- الرموز غير المخزنة: 3.00 دولار/مليون رمز
- **فرق في التكلفة يبلغ 10 أضعاف**

### استراتيجيات تحسين KV-Cache

#### 1. تثبيت بادئة الموجّه

```python
# يُبطل التخزين المؤقت
system_prompt = f"""
الوقت الحالي: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}
أنت وكيل ذكاء اصطناعي...
"""

# نمط صديق للتخزين المؤقت
system_prompt = """
أنت وكيل ذكاء اصطناعي...
المهمة الحالية: {task_description}
"""
```

#### 2. تصميم سياق إلحاقي فقط

```python
class AgentContext:
    def __init__(self):
        self.actions = []
        self.observations = []
    
    def add_step(self, action, observation):
        # إلحاق فقط، لا تعديل
        self.actions.append(action)
        self.observations.append(observation)
    
    def serialize(self):
        # ضمان التسلسل الحتمي
        return json.dumps({
            'actions': self.actions,
            'observations': self.observations
        }, sort_keys=True)
```

#### 3. إدارة نقاط توقف التخزين المؤقت بوضوح

```python
def create_cache_breakpoints(context):
    breakpoints = [
        'system_prompt_end',
        'tools_definition_end',
        'conversation_start'
    ]
    
    for bp in breakpoints:
        context.add_cache_marker(bp)
```

## إدارة الأدوات الديناميكية: الإخفاء مقابل الإزالة

### مشكلة الانفجار في عدد الأدوات

مع تبني MCP (بروتوكول سياق النموذج)، يتزايد عدد الأدوات بصورة مضطردة. إضافة الأدوات بدون تمييز تُضعف جودة اتخاذ القرار لدى الوكيل.

### حل Manus: آلة حالة واعية بالسياق

أسباب إخفاء الأدوات بدلاً من إزالتها:

1. **الحفاظ على KV-cache**: تعريفات الأدوات تقع في مقدمة السياق، لذا تغييرها يُبطل التخزين المؤقت بالكامل
2. **سلامة المراجع**: اختفاء أداة أشار إليها إجراء سابق يُسبّب ارتباكاً للنموذج

### تطبيق التحكم في استدعاء الدالة

```python
class FunctionCallController:
    def __init__(self):
        self.call_modes = {
            'auto': '<|im_start|>assistant',
            'required': '<|im_start|>assistant<tool_call>',
            'specified': '<|im_start|>assistant<tool_call>{"name": "browser_'
        }
    
    def constrain_tools(self, context, allowed_prefixes):
        """السماح بالأدوات ذات البوادئ المحددة فقط"""
        # التحكم عبر إخفاء logit الرمز
        pass
```

### اتفاقيات تسمية الأدوات

```python
# استخدام بوادئ متسقة
BROWSER_TOOLS = [
    'browser_navigate',
    'browser_click',
    'browser_extract'
]

SHELL_TOOLS = [
    'shell_execute',
    'shell_cd',
    'shell_env'
]
```

## استخدام نظام الملفات كسياق

### قيود نافذة السياق

رغم توفر نماذج اللغة الكبيرة الحديثة نوافذ تبلغ 128K+ رمز، تواجه سيناريوهات الوكلاء الفعلية هذه المشكلات:

1. **بيانات ملاحظة ضخمة**: بيانات غير منظمة كصفحات الويب وملفات PDF
2. **تراجع الأداء**: تدهور أداء النموذج في السياقات الطويلة
3. **ارتفاع التكلفة**: تبقى تكاليف الرموز مرتفعة حتى مع التخزين المؤقت للبادئة

### نهج Manus في نظام الملفات

```python
class FileSystemContext:
    def __init__(self, sandbox_path):
        self.sandbox_path = sandbox_path
        self.context_files = {}
    
    def store_observation(self, content, context_type):
        """تخزين الملاحظات الكبيرة كملفات"""
        file_path = f"{self.sandbox_path}/observations/{uuid4()}.{context_type}"
        with open(file_path, 'w') as f:
            f.write(content)
        
        return {
            'type': 'file_reference',
            'path': file_path,
            'summary': self.generate_summary(content)
        }
    
    def restore_observation(self, file_ref):
        """استعادة المحتوى من الملف عند الحاجة"""
        with open(file_ref['path'], 'r') as f:
            return f.read()
```

### استراتيجية ضغط قابلة للاسترداد

```python
def compress_context(self, context):
    """ضغط دون فقدان المعلومات"""
    compressed = []
    
    for item in context:
        if item['type'] == 'web_page':
            # الحفاظ على URL للاسترداد
            compressed.append({
                'type': 'web_page_ref',
                'url': item['url'],
                'summary': item['summary']
            })
        elif item['type'] == 'document':
            # الحفاظ على مسار الملف
            compressed.append({
                'type': 'document_ref',
                'path': item['path'],
                'key_points': item['key_points']
            })
    
    return compressed
```

## الحفاظ على الأهداف عبر التلاعب بالانتباه

### التحكم في الانتباه عبر قائمة المهام

لماذا ينشئ Manus ملف `todo.md` ويحدّثه للمهام المعقدة:

1. **إعادة تأكيد الهدف**: وضع الأهداف بشكل متكرر في نهاية السياق
2. **حل مشكلة الضياع في المنتصف**: منع نسيان المعلومات الحرجة في السياقات الطويلة
3. **تحيّز الانتباه القائم على اللغة الطبيعية**: يُنفَّذ دون تغييرات معمارية خاصة

### مثال تطبيقي ملموس

```markdown
# مثال todo.md

## المهمة الحالية: تحسين أداء الموقع الإلكتروني

### مكتمل
- [x] قياس وقت تحميل الصفحة الحالي
- [x] تحليل أحجام ملفات الصور
- [x] التحقق من حالة ضغط CSS/JS

### قيد التنفيذ
- [ ] تطبيق استراتيجية التخزين المؤقت
- [ ] تطبيق تحسين الصور

### الخطوات التالية
- [ ] تشغيل اختبارات الأداء
- [ ] كتابة تقرير النتائج
```

### متوسط تعقيد المهمة

**بيانات Manus الفعلية**: يتطلب المتوسط 50 استدعاءً للأدوات لكل مهمة

## استراتيجية الاستفادة من الأخطاء: التعلم من الإخفاقات بدلاً من إخفائها

### فخ إزالة الإخفاقات

مناهج شائعة لمعالجة الأخطاء:
- إزالة الإجراءات الفاشلة
- إعادة ضبط الحالة وإعادة المحاولة
- إضافة عشوائية بضبط "درجة الحرارة"

### استراتيجية Manus في الاستفادة من الأخطاء

```python
class ErrorLearningContext:
    def handle_failed_action(self, action, error):
        """الاحتفاظ بالإجراءات الفاشلة في السياق"""
        error_context = {
            'action': action,
            'error': error,
            'timestamp': datetime.now(),
            'learning_signal': True
        }
        
        # الاحتفاظ بمعلومات الفشل في السياق
        self.context.append(error_context)
        
        # تقليل احتمالية تكرار النموذج لأخطاء مماثلة
        self.update_action_priors(action, negative_signal=True)
```

### أهمية التعافي من الأخطاء

التعافي من الأخطاء مؤشر أساسي للسلوك الوكيلي الحقيقي. معظم الأبحاث الأكاديمية ومعايير القياس اليوم تركز فقط على النجاح في الظروف المثالية، وتفشل في عكس تعقيد بيئات الإنتاج الفعلية.

## تجنب فخ التوجيه بالأمثلة القليلة

### خطر تقليد النمط

قدرة نماذج اللغة القوية على التقليد قد تصبح في الواقع مشكلة في أنظمة الوكلاء:

```python
# نمط موحد إشكالي
context_examples = [
    "Action: analyze file, Observation: 20 items found",
    "Action: analyze file, Observation: 15 items found",
    "Action: analyze file, Observation: 25 items found"
]
# ينتهي الأمر بالنموذج باختيار "analyze file" دائماً
```

### استراتيجية Manus لتعزيز التنوع

```python
class ContextDiversifier:
    def add_structural_variation(self, action, observation):
        """إدخال تنويع هيكلي"""
        templates = [
            "Executed: {action} -> Result: {observation}",
            "Action: {action}\nObservation: {observation}",
            "{action} completed. {observation}"
        ]
        
        template = random.choice(templates)
        return template.format(action=action, observation=observation)
    
    def add_semantic_noise(self, text):
        """تنويع التعبير مع الحفاظ على المعنى"""
        synonyms = {
            'analyze': ['review', 'inspect', 'check'],
            'execute': ['perform', 'run', 'process']
        }
        # استبدال مرادفات عشوائي
        return self.apply_synonyms(text, synonyms)
```

## دليل التطبيق العملي

### قائمة التحقق لمراحل التطوير

#### 1. مرحلة التصميم
- [ ] تصميم هيكل موجّه صديق لـ KV-cache
- [ ] تحديد اتفاقيات تسمية الأدوات (بوادئ متسقة)
- [ ] التخطيط لمعمارية ذاكرة قائمة على نظام الملفات

#### 2. مرحلة التطبيق
- [ ] تطبيق هيكل سياق إلحاقي فقط
- [ ] تطبيق التحكم في الأدوات عبر إخفاء logit الرمز
- [ ] تطبيق استراتيجية ضغط قابلة للاسترداد

#### 3. مرحلة التحسين
- [ ] رصد نسبة إصابة KV-cache
- [ ] إدخال آليات تنويع السياق
- [ ] بناء نظام التعلم من الأخطاء

### مقاييس مراقبة الأداء

```python
class AgentMetrics:
    def __init__(self):
        self.metrics = {
            'kv_cache_hit_rate': 0.0,
            'avg_context_length': 0,
            'error_recovery_rate': 0.0,
            'task_completion_rate': 0.0,
            'cost_per_interaction': 0.0
        }
    
    def calculate_efficiency_score(self):
        """حساب درجة كفاءة مركبة"""
        weights = {
            'kv_cache_hit_rate': 0.3,
            'error_recovery_rate': 0.25,
            'task_completion_rate': 0.25,
            'cost_efficiency': 0.2
        }
        
        return sum(self.metrics[k] * weights[k] for k in weights)
```

## نظرة مستقبلية: نماذج الفضاء الحالي والوكلاء

### إمكانات SSMs

منظور مثير قدّمه فريق Manus: إذا أتقنت نماذج الفضاء الحالي (SSMs) الذاكرة القائمة على الملفات، فقد يكون بالإمكان بناء وكلاء فعّالة دون الانتباه الكامل للـ Transformer.

مزايا محتملة للوكلاء المبنية على SSM:
- **السرعة**: استدلال أسرع من الـ Transformers
- **الكفاءة**: استخدام ذاكرة محسّن
- **قابلية التوسع**: القدرة على معالجة تسلسلات طويلة

يُلمح هذا إلى إمكانية أن تكون الخليفة الحقيقي لآلة تورينج العصبية.

## خلاصة

الدروس المستفادة من إعادة بناء فريق Manus لإطارهم أربع مرات واضحة: هندسة السياق محورية في تطوير وكلاء الذكاء الاصطناعي وتستلزم نهجاً منهجياً.

### ملخص المبادئ الأساسية

1. **KV-cache أولاً**: تحسين نسبة الإصابة يؤثر مباشرةً على الأداء والتكلفة
2. **الإخفاء على الإزالة**: يضمن الاستقرار في إدارة الأدوات
3. **توظيف نظام الملفات**: ذاكرة خارجية لسياق غير محدود
4. **التعلم من الإخفاقات**: استخدام الأخطاء إشارات تعلم لا إخفاؤها
5. **الحفاظ على التنوع**: تنويع هيكلي لتجنب فخاخ النمط

### نصيحة للممارسين

إذا كنت فريق تطوير وكلاء ذكاء اصطناعي، استخدم هذه الأسئلة لمراجعة نظامك الحالي:

- هل تقيس نسبة إصابة KV-cache؟
- هل إضافة أداة تُبطل التخزين المؤقت بالكامل؟
- كيف تتعامل مع الإجراءات الفاشلة؟
- هل سياقك موحد أكثر مما ينبغي؟

هندسة السياق لا تزال حقلاً ناشئاً. لكن استناداً إلى المبادئ المُثبَتة في بيئات الإنتاج الفعلية كـ Manus، يمكنك بناء وكلاء ذكاء اصطناعي أكثر كفاءةً ومتانةً.

مستقبل الوكلاء سيُبنى على سياق مُصمَّم بعناية. ابدأ الآن.

---

**المراجع**:
- [مدونة Manus AI الأصلية](https://manus.im/blog/Context-Engineering-for-AI-Agents-Lessons-from-Building-Manus)
- أبحاث تحسين KV-Cache
- توثيق MCP (بروتوكول سياق النموذج)
