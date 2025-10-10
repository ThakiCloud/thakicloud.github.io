---
title: "UserLM-8b: ثورة في اختبار الذكاء الاصطناعي التحاوري من خلال محاكاة المستخدم"
excerpt: "اكتشف كيف يقلب UserLM-8b من Microsoft التدريب التقليدي لنماذج اللغة الكبيرة من خلال محاكاة المستخدمين بدلاً من المساعدين، مما يتيح سير عمل اختبار أكثر واقعية لأنظمة الذكاء الاصطناعي التحاوري."
seo_title: "UserLM-8b: محاكاة المستخدم لأتمتة سير العمل بالذكاء الاصطناعي - Thaki Cloud"
seo_description: "تعرف على كيفية تحويل UserLM-8b لاختبار الذكاء الاصطناعي التحاوري من خلال محاكاة دور المستخدم، مما يوفر أتمتة اختبار واقعية وسير عمل تقييم لنماذج اللغة المساعدة."
date: 2025-10-10
categories:
  - owm
tags:
  - UserLM
  - LLM
  - محاكاة-المستخدم
  - أتمتة-سير-العمل
  - الذكاء-الاصطناعي-التحاوري
  - Microsoft
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/owm/userlm-8b-user-simulation-workflow-automation/
canonical_url: "https://thakicloud.github.io/ar/owm/userlm-8b-user-simulation-workflow-automation/"
---

⏱️ **وقت القراءة المتوقع**: 8 دقائق

## المقدمة: تحول نموذجي في تدريب نماذج اللغة الكبيرة

لقد ركز مجال نماذج اللغة الكبيرة (LLMs) بشكل أساسي على تدريب النماذج لتكون بمثابة مساعدين، حيث تستجيب بشكل مفيد لاستفسارات المستخدم وتتبع التعليمات. ومع ذلك، قدمت Microsoft Research تحولاً مثيراً في هذا النموذج مع **UserLM-8b**، وهو نموذج تم تدريبه خصيصاً لمحاكاة دور المستخدم في المحادثات بدلاً من دور المساعد.

يفتح هذا النهج المبتكر إمكانيات جديدة تماماً لأتمتة سير العمل في تطوير الذكاء الاصطناعي التحاوري، خاصة في عمليات الاختبار والتقييم وضمان الجودة. من خلال توفير محاكاة واقعية لسلوك المستخدم، يمكّن UserLM-8b المطورين من إنشاء سير عمل اختبار أكثر قوة تتنبأ بشكل أفضل بالأداء في العالم الحقيقي.

## ما الذي يجعل UserLM-8b مختلفاً؟

### الابتكار الأساسي

على عكس نماذج اللغة الكبيرة التقليدية التي تم تحسينها للتنبؤ وتوليد استجابات المساعد، تم تدريب UserLM-8b على مجموعة بيانات **WildChat-1M** للتنبؤ بأدوار المستخدم في المحادثات. هذا الاختلاف الأساسي يعني أن النموذج تعلم:

- صياغة الأسئلة والطلبات مثل المستخدمين الحقيقيين
- اتباع نوايا المهام بتباين واقعي
- توليد استجابات متابعة بناءً على ملاحظات المساعد
- التعرف على متى وصلت المحادثة إلى نهايتها الطبيعية

### الأساس التقني

تم بناء UserLM-8b على **Llama 3.1-8B** كنموذج أساسي وخضع لضبط دقيق كامل المعاملات بالمواصفات التالية:

- **بيانات التدريب**: نسخة مصفاة من WildChat-1M (مليون محادثة من العالم الحقيقي)
- **طول التسلسل**: 2048 رمزاً كحد أقصى
- **حجم الدفعة**: 1024 عينة
- **معدل التعلم**: 2e-5
- **أجهزة التدريب**: أربعة أجهزة NVIDIA RTX A6000 GPU
- **مدة التدريب**: 227 ساعة
- **البصمة الكربونية**: حوالي 115 كجم CO2

## حالات استخدام أتمتة سير العمل

### 1. اختبار الذكاء الاصطناعي التحاوري الآلي

يتيح UserLM-8b إنشاء سير عمل اختبار آلي متطور لأنظمة الذكاء الاصطناعي التحاوري. غالباً ما تعتمد أساليب الاختبار التقليدية على:

- نصوص اختبار مكتوبة مسبقاً بمدخلات مستخدم ثابتة
- مختبرين بشريين يتحادثون يدوياً مع النظام
- اختبار بسيط قائم على المطالبات باستخدام نماذج اللغة المساعدة

لهذه الأساليب قيود كبيرة في التقاط تنوع وعدم قابلية التنبؤ بسلوك المستخدم الحقيقي. يعالج UserLM-8b هذه القيود من خلال توفير:

**توليد الاختبار الديناميكي**: يمكن للنموذج توليد تعبيرات مستخدم متنوعة لنفس نية المهمة، مما يخلق تغطية اختبار أكثر شمولاً دون جهد يدوي.

**اختبار المحادثة متعددة الأدوار**: على عكس نصوص الاختبار الثابتة، يمكن لـ UserLM-8b الانخراط في محادثات واقعية متعددة الأدوار، واختبار مدى جودة تعامل المساعد مع الحوارات الممتدة مع تبديل السياق وتراكم المعلومات.

**إنهاء المحادثة الطبيعي**: يتضمن النموذج رمزاً خاصاً `<|endconversation|>` يشير إلى متى يعتقد أن المحادثة قد انتهت بشكل طبيعي، مما يسمح لسير عمل الاختبار الآلي بمعرفة متى اكتملت حالة الاختبار.

### 2. تكامل خط أنابيب التقييم

يوفر دمج UserLM-8b في خطوط أنابيب التقييم العديد من فوائد أتمتة سير العمل:

**ظروف تقييم متسقة**: باستخدام محاكي مستخدم مدرب، يمكنك التأكد من أن نماذج المساعد المختلفة يتم تقييمها في ظل نفس أنماط سلوك المستخدم المحاكاة، مما يوفر مقارنات أداء أكثر موثوقية.

**اختبار الأداء القابل للتوسع**: بدلاً من توظيف مختبرين بشريين لكل دورة تقييم، يمكن لـ UserLM-8b محاكاة مئات أو آلاف التفاعلات مع المستخدمين، مما يسرع بشكل كبير سير عمل التقييم.

### 3. سير عمل توليد البيانات الاصطناعية

يمكن دمج UserLM-8b مع نماذج اللغة المساعدة لإنشاء مجموعات بيانات محادثة اصطناعية لأغراض التدريب والضبط الدقيق:

```python
# سير عمل مفاهيمي لتوليد البيانات الاصطناعية
def generate_synthetic_conversation(task_intent, assistant_model, user_model):
    """
    توليد محادثة اصطناعية بين UserLM ونموذج مساعد.
    """
    conversation = []
    
    # التهيئة بنية المهمة
    user_message = user_model.generate_first_turn(task_intent)
    conversation.append({"role": "user", "content": user_message})
    
    for turn in range(max_turns):
        # استجابة المساعد
        assistant_message = assistant_model.generate(conversation)
        conversation.append({"role": "assistant", "content": assistant_message})
        
        # متابعة المستخدم
        user_response = user_model.generate_followup(conversation)
        
        # التحقق من نهاية المحادثة
        if user_response == "<|endconversation|>":
            break
            
        conversation.append({"role": "user", "content": user_response})
    
    return conversation
```

يمكن لسير العمل الآلي هذا توليد بيانات تدريب متنوعة على نطاق واسع، مما يقلل الاعتماد على مجموعات بيانات المحادثة المولدة بواسطة الإنسان باهظة الثمن.

### 4. نمذجة المستخدم واختبار التخصيص

يمكن تكييف UserLM-8b لنمذجة شخصيات مستخدم معينة أو أنماط سلوكية، مما يتيح:

**الاختبار القائم على الشخصية**: إنشاء محاكيات مستخدم لأنواع مختلفة من المستخدمين (على سبيل المثال، المستخدمون التقنيون، المستخدمون المبتدئون، المستخدمون المتعجلون) لاختبار مدى تكيف المساعد مع أنماط التفاعل المختلفة.

**اكتشاف الحالات الحدية**: من خلال تغيير نوايا المهام ومعاملات التوليد، يمكنك اكتشاف الحالات الحدية تلقائياً حيث يكون أداء المساعد ضعيفاً.

## التنفيذ العملي

### البدء مع UserLM-8b

إليك كيفية دمج UserLM-8b في خط أنابيب أتمتة سير العمل الخاص بك:

```python
from transformers import AutoTokenizer, AutoModelForCausalLM
import torch

class UserSimulator:
    def __init__(self, model_path="microsoft/UserLM-8b"):
        """تهيئة محاكي المستخدم."""
        self.tokenizer = AutoTokenizer.from_pretrained(
            model_path, 
            trust_remote_code=True
        )
        self.model = AutoModelForCausalLM.from_pretrained(
            model_path,
            trust_remote_code=True
        ).to("cuda")
        
        # تعريف الرموز الخاصة
        self.end_token = "<|eot_id|>"
        self.end_token_id = self.tokenizer.encode(
            self.end_token, 
            add_special_tokens=False
        )
        
        self.end_conv_token = "<|endconversation|>"
        self.end_conv_token_id = self.tokenizer.encode(
            self.end_conv_token, 
            add_special_tokens=False
        )
    
    def generate_first_turn(self, task_intent, temperature=1.0, top_p=0.8):
        """توليد أول تعبير للمستخدم بناءً على نية المهمة."""
        messages = [
            {
                "role": "system", 
                "content": task_intent
            }
        ]
        
        inputs = self.tokenizer.apply_chat_template(
            messages, 
            return_tensors="pt"
        ).to("cuda")
        
        outputs = self.model.generate(
            input_ids=inputs,
            do_sample=True,
            top_p=top_p,
            temperature=temperature,
            max_new_tokens=256,
            eos_token_id=self.end_token_id,
            pad_token_id=self.tokenizer.eos_token_id,
            bad_words_ids=[[token_id] for token_id in self.end_conv_token_id]
        )
        
        response = self.tokenizer.decode(
            outputs[0][inputs.shape[1]:], 
            skip_special_tokens=True
        )
        return response.strip()
```

### مثال سير عمل الاختبار الآلي

إليك مثال كامل لدمج UserLM-8b في سير عمل اختبار آلي:

```python
class ConversationalAITester:
    def __init__(self, user_simulator, assistant_model):
        self.user_sim = user_simulator
        self.assistant = assistant_model
        self.test_results = []
    
    def run_test_suite(self, task_intents, num_conversations_per_intent=10):
        """تشغيل اختبار آلي عبر نوايا مهام متعددة."""
        for intent in task_intents:
            for i in range(num_conversations_per_intent):
                result = self._run_single_test(intent, test_id=f"{intent}_{i}")
                self.test_results.append(result)
        
        return self._analyze_results()
    
    def _run_single_test(self, task_intent, test_id, max_turns=20):
        """تشغيل محادثة اختبار واحدة."""
        conversation = []
        metrics = {
            "test_id": test_id,
            "task_intent": task_intent,
            "num_turns": 0,
            "success": False,
            "error_occurred": False,
            "conversation_history": []
        }
        
        try:
            # توليد رسالة المستخدم الأولى
            user_msg = self.user_sim.generate_first_turn(task_intent)
            conversation.append({"role": "user", "content": user_msg})
            
            for turn in range(max_turns):
                # الحصول على استجابة المساعد
                assistant_msg = self.assistant.generate(conversation)
                conversation.append({"role": "assistant", "content": assistant_msg})
                
                # توليد متابعة المستخدم
                user_response = self.user_sim.generate_followup(conversation)
                
                # التحقق من نهاية المحادثة
                if user_response == "<|endconversation|>" or \
                   "<|endconversation|>" in user_response:
                    metrics["success"] = True
                    break
                
                conversation.append({"role": "user", "content": user_response})
                metrics["num_turns"] += 1
            
            metrics["conversation_history"] = conversation
            
        except Exception as e:
            metrics["error_occurred"] = True
            metrics["error_message"] = str(e)
        
        return metrics
```

## خصائص الأداء والقيود

### نقاط القوة

تظهر تقييمات الأبحاث لـ UserLM-8b عدة نقاط قوة رئيسية:

**توافق توزيعي متفوق**: يحقق UserLM-8b حيرة أقل في محادثات الاختبار المحجوزة مقارنة بأساليب محاكاة المستخدم السابقة، بما في ذلك النماذج المدربة (USP-8b) والنماذج المساعدة المطالبة.

**التزام قوي بالدور**: يحافظ النموذج باستمرار على دور المستخدم الخاص به ويتبع نوايا المهام بشكل أكثر موثوقية من أساليب المحاكاة القائمة على المساعد.

**ديناميكيات المحادثة الطبيعية**: يُظهر UserLM-8b وتيرة محادثة أكثر واقعية، وتنوع معجمي، وأنماط مشاركة المعلومات مقارنة بنماذج المساعد المطالبة.

### القيود الواجب مراعاتها

**ليست مثالية القوة**: بينما أكثر قوة من البدائل، لا يزال UserLM-8b ينحرف أحياناً عن دور المستخدم أو نية المهمة الأولية (القوة < 100٪).

**هلوسة المتطلبات**: يقدم النموذج أحياناً حقائق أو قيود إضافية غير محددة في نية المهمة. قد يكون هذا مفيداً (زيادة التنوع) وضاراً (إدخال عدم التوافق).

**التركيز على اللغة الإنجليزية**: تم تصميم واختبار UserLM-8b بشكل أساسي باستخدام اللغة الإنجليزية. قد يختلف الأداء في اللغات الأخرى ويتطلب تقييماً دقيقاً من قبل المتحدثين الأصليين.

**التحيزات الموروثة**: يرث النموذج أي تحيزات أو أخطاء أو إغفالات من كل من نموذجه الأساسي (Llama 3.1-8B) وبيانات التدريب (WildChat-1M).

### استراتيجيات التخفيف

لمعالجة هذه القيود في سير عمل الإنتاج:

1. **تحديد نوايا المهام بوضوح**: قدم نوايا مهام مفصلة ومحددة لتقليل فرص الهلوسة.

2. **تنفيذ مرشحات الجودة**: أضف طبقات التحقق للكشف عند انحراف النموذج عن السلوك المقبول.

3. **استخدام أساليب المجموعة**: ادمج UserLM-8b مع أساليب اختبار أخرى للتغطية الشاملة.

4. **المراجعة البشرية المنتظمة**: قم بأخذ عينات ومراجعة المحادثات المولدة بشكل دوري لتحديد المشكلات المنهجية.

## التكامل مع سير العمل الحالي

### تكامل خط أنابيب CI/CD

يمكن دمج UserLM-8b في خطوط أنابيب التكامل المستمر / النشر المستمر لأنظمة الذكاء الاصطناعي التحاوري:

```yaml
# مثال سير عمل GitHub Actions
name: Conversational AI Testing

on:
  pull_request:
    branches: [main]
  push:
    branches: [main]

jobs:
  user-simulation-tests:
    runs-on: ubuntu-latest-gpu
    steps:
      - uses: actions/checkout@v3
      
      - name: Setup Python
        uses: actions/setup-python@v4
        with:
          python-version: '3.10'
      
      - name: Install dependencies
        run: |
          pip install transformers torch pytest
      
      - name: Run UserLM-8b tests
        run: |
          python -m pytest tests/test_user_simulation.py \
            --task-intents=tests/task_intents.json \
            --num-conversations=50 \
            --max-turns=20
```

## الخلاصة

يمثل UserLM-8b ابتكاراً مهماً في سير عمل تطوير الذكاء الاصطناعي التحاوري. من خلال قلب نموذج التدريب التقليدي لنماذج اللغة الكبيرة للتركيز على محاكاة دور المستخدم، أنشأت Microsoft Research أداة قوية للاختبار الآلي والتقييم وضمان الجودة.

يتيح النموذج أتمتة سير العمل على مستويات متعددة:

- **الاختبار الآلي**: اختبار محادثة قابل للتوسع ومتنوع دون جهد يدوي
- **خطوط أنابيب التقييم**: تقييم الأداء المتسق والقابل للتكرار
- **توليد البيانات الاصطناعية**: الإنشاء الآلي لمجموعات بيانات التدريب
- **المراقبة المستمرة**: فحوصات الحالة المستمرة لأنظمة الإنتاج

بينما لدى UserLM-8b قيود تتطلب دراسة متأنية، خاصة حول القوة والهلوسة، يمكن أن يؤدي تنفيذ حواجز الأمان وطبقات التحقق المناسبة إلى تخفيف هذه المخاوف في سير عمل الإنتاج.

بالنسبة للفرق التي تطور أنظمة الذكاء الاصطناعي التحاوري، فإن دمج UserLM-8b في خط أنابيب أتمتة سير العمل الخاص بهم يوفر إمكانية إجراء اختبار أكثر شمولاً ودورات تكرار أسرع، وفي النهاية، مساعدين أكثر قوة يعملون بشكل أفضل مع المستخدمين الحقيقيين.

## المراجع

- **الورقة البحثية**: Naous, T., Laban, P., Xu, W., & Neville, J. (2025). Flipping the Dialogue: Training and Evaluating User Language Models. arXiv preprint arXiv:2510.06552. [https://arxiv.org/abs/2510.06552](https://arxiv.org/abs/2510.06552)
- **النموذج**: [https://huggingface.co/microsoft/UserLM-8b](https://huggingface.co/microsoft/UserLM-8b)
- **النموذج الأساسي**: Meta Llama 3.1-8B
- **مجموعة بيانات التدريب**: WildChat-1M (نسخة مصفاة)

---

*تستكشف هذه المقالة تطبيقات أتمتة سير العمل لـ UserLM-8b. للاستفسارات البحثية والتقييمية، اتصل بفريق Microsoft Research على plaban@microsoft.com*

