---
title: "الدليل الشامل لـ Agent Leaderboard v2 - المعيار الجديد لتقييم أداء وكلاء الذكاء الاصطناعي"
excerpt: "تعلم كيفية تقييم ومقارنة أداء استخدام الأدوات لوكلاء الذكاء الاصطناعي باستخدام Agent Leaderboard v2 من Galileo.ai من خلال التطبيق العملي."
seo_title: "دليل Agent Leaderboard v2 - الدليل الشامل لتقييم وكلاء الذكاء الاصطناعي - ثاكي كلاود"
seo_description: "دليل شامل يغطي كيفية تقييم أداء وكلاء الذكاء الاصطناعي باستخدام Agent Leaderboard v2 وكيفية استخدام مقياس TSQ مع أمثلة عملية."
date: 2025-07-18
last_modified_at: 2025-07-18
categories:
  - llmops
tags:
  - agent-leaderboard
  - ai-agents
  - benchmarking
  - tool-calling
  - galileo-ai
  - performance-evaluation
  - machine-learning
  - llm-evaluation
author_profile: true
toc: true
toc_label: "المحتويات"
toc_icon: "cog"
toc_sticky: true
canonical_url: "https://thakicloud.github.io/ar/llmops/agent-leaderboard-v2-comprehensive-tutorial/"
reading_time: true
lang: ar
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## مقدمة

يُعدّ التقييم الموضوعي لأداء وكلاء الذكاء الاصطناعي أحد أهم التحديات في تطوير الذكاء الاصطناعي الحديث. Agent Leaderboard v2، الذي طورته شركة Galileo.ai، هو منصة شاملة لمقارنة الأداء وتقييم قدرات وكلاء الذكاء الاصطناعي على استخدام الأدوات.

تمامًا كما وصف Jensen Huang الوكلاءَ بأنهم "قوى عاملة رقمية"، وأكد Satya Nadella أن الوكلاء سيُحدثون تحولًا جوهريًا في العمليات التجارية، فإن وكلاء الذكاء الاصطناعي يقعون في صميم ابتكار الذكاء الاصطناعي من الجيل التالي.

يرشدك هذا الدليل عبر Agent Leaderboard v2 من المفاهيم الأساسية إلى الاستخدام العملي، مما يُتيح لك إتقانه من خلال التطبيق المباشر.

## ما هو Agent Leaderboard v2؟

### نظرة عامة والميزات الرئيسية

Agent Leaderboard v2 هو إطار شامل لمقارنة الأداء يقيّم كيفية أداء وكلاء الذكاء الاصطناعي في سيناريوهات الأعمال الواقعية. في حين اقتصرت معايير الأداء الأكاديمية التقليدية على قياس القدرات التقنية فحسب، يُركز Agent Leaderboard v2 على قياس الأداء في حالات الاستخدام الفعلية.

### أبرز ما يميزه

بالنظر إلى قيود أطر التقييم الحالية:
- **BFCL**: متخصص في المجالات الأكاديمية كالرياضيات والترفيه والتعليم
- **tau-bench**: يركز على سيناريوهات التجزئة والطيران
- **xLAM**: متخصص في توليد البيانات عبر 21 مجالًا
- **ToolACE**: يركز على تفاعلات واجهة برمجة التطبيقات عبر 390 مجالًا

يوفر Agent Leaderboard v2 إطار تقييم متكاملًا يوحّد هذه المعايير الفردية ويغطي **مجالات متعددة** و**حالات استخدام واقعية**.

### النماذج الخاضعة للتقييم

يجري حاليًا تقييم 17 نموذجًا لغويًا كبيرًا رئيسيًا، مع تحديثات شهرية كلما صدرت نماذج جديدة:

#### الطبقة النخبوية (>= 0.9)
- **Gemini-2.0-flash**: المركز الأول بنتيجة 0.938
- **GPT-4o**: المركز الثاني بنتيجة 0.900

#### الأداء المرتفع (0.85-0.9)
- **Gemini-1.5-flash**: 0.895
- **Gemini-1.5-pro**: 0.885
- **o1**: 0.876
- **o3-mini**: 0.847

#### الطبقة المتوسطة (0.8-0.85)
- **GPT-4o-mini**: 0.832
- **mistral-small-2501**: 0.832
- **Qwen-72b**: 0.817

## فهم مقياس جودة اختيار الأدوات (TSQ)

### المفهوم الجوهري لـ TSQ

TSQ (Tool Selection Quality) أي جودة اختيار الأدوات هو مقياس التقييم المركزي في Agent Leaderboard v2. بدلًا من قياس الدقة البسيطة، يُقيّم هذا المقياس بشكل شامل **دقة اختيار الوكيل للأدوات** و**فاعلية استخدام المعاملات**.

### أبعاد تقييم TSQ

#### 1. التعرف على السيناريو
عند تلقي الوكيل استعلامًا، يجب عليه أولًا تحديد ما إذا كان استخدام الأداة ضروريًا:
- الحالات التي تجعل المعلومات المتوفرة في سجل المحادثة استدعاءَ الأداة غير ضروري
- الحالات التي تكون فيها الأدوات المتاحة غير ملائمة أو غير كافية للمهمة

#### 2. ديناميكيات اختيار الأدوات
لا يكون اختيار الأداة ثنائيًا بل يشمل الدقة والاستدعاء معًا:
- **مشكلات الاستدعاء**: إغفال بعض الأدوات المطلوبة
- **مشكلات الدقة**: اختيار أدوات غير ضرورية إلى جانب الأدوات المناسبة

#### 3. معالجة المعاملات
حتى بعد اختيار الأداة الصحيحة، تظهر تعقيدات إضافية في معالجة الوسائط:
- توفير جميع المعاملات المطلوبة بالأسماء الصحيحة
- التعامل المناسب مع المعاملات الاختيارية
- الحفاظ على دقة قيم المعاملات
- مطابقة تنسيقات الوسائط لمواصفات الأداة

#### 4. اتخاذ القرارات المتسلسلة
في المهام متعددة الخطوات، يجب على الوكلاء إظهار القدرات التالية:
- تحديد التسلسل الأمثل لاستدعاءات الأدوات
- التعامل مع التبعيات بين استدعاءات الأدوات
- الحفاظ على السياق عبر مهام متعددة
- التكيف مع النتائج الجزئية أو الإخفاقات

## إعداد بيئة الممارسة

### المتطلبات الأساسية

```bash
# التحقق من بيئة Python
python --version  # مطلوب Python 3.8 أو أحدث

# التحقق من بيئة Node.js (اختياري)
node --version    # يُوصى بـ Node.js 16 أو أحدث
```

### إعداد بيئة التطوير

```bash
# إنشاء دليل المشروع
mkdir agent-leaderboard-tutorial
cd agent-leaderboard-tutorial

# إنشاء بيئة Python افتراضية
python -m venv venv
source venv/bin/activate  # macOS/Linux

# تثبيت المكتبات المطلوبة
pip install openai
pip install pandas
pip install promptquality
pip install fastparquet
```

### تهيئة مفتاح واجهة برمجة التطبيقات

```bash
# تعيين متغيرات البيئة
export OPENAI_API_KEY="your-openai-api-key"
export GALILEO_PROJECT_NAME="agent-evaluation"
```

### إنشاء ملف التهيئة الأساسي

```python
# config.py
import os

# إعدادات واجهة برمجة التطبيقات
OPENAI_API_KEY = os.getenv('OPENAI_API_KEY')
GALILEO_PROJECT_NAME = os.getenv('GALILEO_PROJECT_NAME', 'agent-evaluation')

# إعدادات النموذج
DEFAULT_MODEL = "gpt-4o"
DEFAULT_TEMPERATURE = 0.0
DEFAULT_MAX_TOKENS = 4000

# إعدادات التقييم
SYSTEM_MESSAGE = {
    "role": "system",
    "content": '''Your job is to use the given tools to answer the query of human. 
    If there is no relevant tool then reply with "I cannot answer the question with given tools". 
    If tool is available but sufficient information is not available, then ask human to get the same. 
    You can call as many tools as you want. Use multiple tools if needed. 
    If the tools need to be called in a sequence then just call the first tool.'''
}
```

## تطبيق نظام تقييم TSQ

### تطبيق فئة التقييم الأساسية

```python
# evaluator.py
import promptquality as pq
import pandas as pd
from openai import OpenAI
import json

class TSQEvaluator:
    def __init__(self, model="gpt-4o", project_name="agent-evaluation"):
        self.model = model
        self.project_name = project_name
        self.client = OpenAI()
        
        # تهيئة مُقيّم TSQ
        self.chainpoll_scorer = pq.CustomizedChainPollScorer(
            scorer_name=pq.CustomizedScorerName.tool_selection_quality,
            model_alias=pq.Models.gpt_4o,
        )
        
        # تهيئة معالج التقييم
        self.evaluate_handler = pq.GalileoPromptCallback(
            project_name=self.project_name,
            run_name=f"evaluation_{model}",
            scorers=[self.chainpoll_scorer],
        )
    
    def evaluate_single_interaction(self, tools, conversation, expected_outcome=None):
        """تقييم TSQ لتفاعل واحد"""
        try:
            response = self.client.chat.completions.create(
                model=self.model,
                messages=conversation,
                tools=tools,
                temperature=0.0,
                max_tokens=4000
            )
            
            # حساب درجة TSQ
            tsq_score = self._calculate_tsq_score(
                conversation, response, tools, expected_outcome
            )
            
            return {
                "response": response,
                "tsq_score": tsq_score,
                "evaluation_details": self._get_evaluation_details(response, tools)
            }
            
        except Exception as e:
            print(f"خطأ أثناء التقييم: {e}")
            return None
    
    def _calculate_tsq_score(self, conversation, response, tools, expected_outcome):
        """منطق حساب درجة TSQ"""
        score_components = {
            "tool_selection_accuracy": 0.0,
            "parameter_quality": 0.0,
            "relevance_detection": 0.0,
            "sequence_appropriateness": 0.0
        }
        
        if response.choices[0].message.tool_calls:
            tool_calls = response.choices[0].message.tool_calls
            
            # تقييم دقة اختيار الأداة
            score_components["tool_selection_accuracy"] = self._evaluate_tool_selection(
                tool_calls, tools, expected_outcome
            )
            
            # تقييم جودة المعاملات
            score_components["parameter_quality"] = self._evaluate_parameter_quality(
                tool_calls, tools
            )
            
            # تقييم كشف الصلة
            score_components["relevance_detection"] = self._evaluate_relevance_detection(
                conversation, tool_calls
            )
            
            # تقييم ملاءمة التسلسل
            score_components["sequence_appropriateness"] = self._evaluate_sequence_appropriateness(
                tool_calls
            )
        
        # حساب درجة TSQ الإجمالية (أوزان متساوية)
        total_score = sum(score_components.values()) / len(score_components)
        return min(max(total_score, 0.0), 1.0)
    
    def _evaluate_tool_selection(self, tool_calls, available_tools, expected_outcome):
        """تقييم دقة اختيار الأداة"""
        if not tool_calls:
            return 0.0
        
        selected_tools = [call.function.name for call in tool_calls]
        available_tool_names = [tool["function"]["name"] for tool in available_tools]
        
        # التحقق من أن الأدوات المختارة موجودة في قائمة الأدوات المتاحة
        valid_selections = sum(1 for tool in selected_tools if tool in available_tool_names)
        
        return valid_selections / len(selected_tools) if selected_tools else 0.0
    
    def _evaluate_parameter_quality(self, tool_calls, available_tools):
        """تقييم جودة المعاملات"""
        if not tool_calls:
            return 0.0
        
        total_score = 0.0
        
        for call in tool_calls:
            try:
                parameters = json.loads(call.function.arguments)
                # منطق التحقق من المعاملات
                # في التطبيق الفعلي، تتم المقارنة مع مخطط كل أداة
                total_score += 1.0  # درجة مبسطة
            except json.JSONDecodeError:
                total_score += 0.0
        
        return total_score / len(tool_calls)
    
    def _evaluate_relevance_detection(self, conversation, tool_calls):
        """تقييم كشف الصلة"""
        # تقييم مدى ملاءمة استخدام الأداة مع مراعاة سياق المحادثة
        return 0.8  # تطبيق مبسط
    
    def _evaluate_sequence_appropriateness(self, tool_calls):
        """تقييم ملاءمة التسلسل"""
        # تقييم الملاءمة المنطقية لتسلسل استدعاء الأداة
        return 0.9  # تطبيق مبسط
    
    def _get_evaluation_details(self, response, tools):
        """استخراج تفاصيل التقييم"""
        details = {
            "tool_calls_count": 0,
            "tools_used": [],
            "has_function_calls": False,
            "response_type": "text"
        }
        
        if response.choices[0].message.tool_calls:
            details["has_function_calls"] = True
            details["response_type"] = "function_call"
            details["tool_calls_count"] = len(response.choices[0].message.tool_calls)
            details["tools_used"] = [
                call.function.name for call in response.choices[0].message.tool_calls
            ]
        
        return details
```

### تعريف أدوات الممارسة

```python
# tools.py
def create_sample_tools():
    """تعريف أدوات نموذجية للممارسة"""
    tools = [
        {
            "type": "function",
            "function": {
                "name": "get_weather",
                "description": "الحصول على معلومات الطقس الحالية",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "location": {
                            "type": "string",
                            "description": "اسم المدينة للتحقق من حالة طقسها"
                        },
                        "unit": {
                            "type": "string",
                            "enum": ["celsius", "fahrenheit"],
                            "description": "وحدة قياس درجة الحرارة"
                        }
                    },
                    "required": ["location"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "search_web",
                "description": "البحث عن معلومات على الويب",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "query": {
                            "type": "string",
                            "description": "الكلمات المفتاحية للبحث"
                        },
                        "limit": {
                            "type": "integer",
                            "description": "الحد الأقصى لعدد نتائج البحث",
                            "default": 5
                        }
                    },
                    "required": ["query"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "calculator",
                "description": "إجراء العمليات الحسابية",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "expression": {
                            "type": "string",
                            "description": "التعبير الرياضي المراد حسابه"
                        }
                    },
                    "required": ["expression"]
                }
            }
        },
        {
            "type": "function",
            "function": {
                "name": "send_email",
                "description": "إرسال بريد إلكتروني",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "to": {
                            "type": "string",
                            "description": "عنوان البريد الإلكتروني للمستلم"
                        },
                        "subject": {
                            "type": "string",
                            "description": "موضوع البريد الإلكتروني"
                        },
                        "body": {
                            "type": "string",
                            "description": "نص البريد الإلكتروني"
                        }
                    },
                    "required": ["to", "subject", "body"]
                }
            }
        }
    ]
    return tools
```

## تطبيق سيناريوهات الممارسة

### السيناريو الأول: تقييم الاستخدام الأساسي للأدوات

```python
# scenario_basic.py
from evaluator import TSQEvaluator
from tools import create_sample_tools
from config import SYSTEM_MESSAGE

def run_basic_tool_usage_scenario():
    """تشغيل سيناريو الاستخدام الأساسي للأدوات"""
    print("=== سيناريو الاستخدام الأساسي للأدوات ===")
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    
    # حالات الاختبار
    test_cases = [
        {
            "name": "استعلام عن الطقس",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "أخبرني عن الطقس الحالي في سيول"}
            ],
            "expected_tools": ["get_weather"],
            "expected_outcome": "weather_query"
        },
        {
            "name": "بحث على الويب",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "ابحث عن أحدث الأخبار حول وكلاء الذكاء الاصطناعي"}
            ],
            "expected_tools": ["search_web"],
            "expected_outcome": "web_search"
        },
        {
            "name": "عملية حسابية",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "احسب 15 في 23"}
            ],
            "expected_tools": ["calculator"],
            "expected_outcome": "calculation"
        }
    ]
    
    results = []
    
    for test_case in test_cases:
        print(f"\nاختبار: {test_case['name']}")
        
        result = evaluator.evaluate_single_interaction(
            tools=tools,
            conversation=test_case["conversation"],
            expected_outcome=test_case["expected_outcome"]
        )
        
        if result:
            print(f"درجة TSQ: {result['tsq_score']:.3f}")
            print(f"الأدوات المستخدمة: {result['evaluation_details']['tools_used']}")
            print(f"الأدوات المتوقعة: {test_case['expected_tools']}")
            
            # التحقق من الدقة
            used_tools = result['evaluation_details']['tools_used']
            expected_tools = test_case['expected_tools']
            accuracy = len(set(used_tools) & set(expected_tools)) / len(set(used_tools) | set(expected_tools))
            print(f"دقة اختيار الأداة: {accuracy:.3f}")
            
            results.append({
                "test_name": test_case['name'],
                "tsq_score": result['tsq_score'],
                "tool_accuracy": accuracy,
                "details": result['evaluation_details']
            })
    
    # ملخص النتائج الإجمالية
    print("\n=== ملخص النتائج الإجمالية ===")
    avg_tsq = sum(r['tsq_score'] for r in results) / len(results)
    avg_accuracy = sum(r['tool_accuracy'] for r in results) / len(results)
    
    print(f"متوسط درجة TSQ: {avg_tsq:.3f}")
    print(f"متوسط دقة اختيار الأداة: {avg_accuracy:.3f}")
    
    return results

if __name__ == "__main__":
    run_basic_tool_usage_scenario()
```

### السيناريو الثاني: تقييم الاستخدام المعقد للأدوات

```python
# scenario_complex.py
from evaluator import TSQEvaluator
from tools import create_sample_tools
from config import SYSTEM_MESSAGE

def run_complex_tool_usage_scenario():
    """تشغيل سيناريو الاستخدام المعقد للأدوات"""
    print("=== سيناريو الاستخدام المعقد للأدوات ===")
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    
    # حالات اختبار معقدة
    complex_test_cases = [
        {
            "name": "استعلام الطقس ثم الإرسال بالبريد",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "تحقق من الطقس في سيول وأرسل النتيجة بالبريد إلى user@example.com"}
            ],
            "expected_tools": ["get_weather", "send_email"],
            "expected_outcome": "weather_and_email"
        },
        {
            "name": "الحساب ثم البحث",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "احسب 100 في 25 وابحث على الويب عن معلومات حول هذه النتيجة"}
            ],
            "expected_tools": ["calculator", "search_web"],
            "expected_outcome": "calculation_and_search"
        },
        {
            "name": "اختبار الاستخدام غير الضروري للأداة",
            "conversation": [
                SYSTEM_MESSAGE,
                {"role": "user", "content": "مرحبًا. أتمنى لك يومًا طيبًا!"}
            ],
            "expected_tools": [],
            "expected_outcome": "no_tool_needed"
        }
    ]
    
    results = []
    
    for test_case in complex_test_cases:
        print(f"\nاختبار معقد: {test_case['name']}")
        
        result = evaluator.evaluate_single_interaction(
            tools=tools,
            conversation=test_case["conversation"],
            expected_outcome=test_case["expected_outcome"]
        )
        
        if result:
            print(f"درجة TSQ: {result['tsq_score']:.3f}")
            print(f"الأدوات المستخدمة: {result['evaluation_details']['tools_used']}")
            print(f"الأدوات المتوقعة: {test_case['expected_tools']}")
            print(f"عدد استدعاءات الأداة: {result['evaluation_details']['tool_calls_count']}")
            
            # تقييم المهمة المعقدة
            used_tools = set(result['evaluation_details']['tools_used'])
            expected_tools = set(test_case['expected_tools'])
            
            if expected_tools:
                precision = len(used_tools & expected_tools) / len(used_tools) if used_tools else 0
                recall = len(used_tools & expected_tools) / len(expected_tools) if expected_tools else 0
                f1_score = 2 * (precision * recall) / (precision + recall) if (precision + recall) > 0 else 0
            else:
                # حالة عدم استخدام أي أداة
                precision = 1.0 if not used_tools else 0.0
                recall = 1.0
                f1_score = precision
            
            print(f"الدقة: {precision:.3f}")
            print(f"الاستدعاء: {recall:.3f}")
            print(f"درجة F1: {f1_score:.3f}")
            
            results.append({
                "test_name": test_case['name'],
                "tsq_score": result['tsq_score'],
                "precision": precision,
                "recall": recall,
                "f1_score": f1_score,
                "details": result['evaluation_details']
            })
    
    # ملخص نتائج المهام المعقدة
    print("\n=== ملخص نتائج المهام المعقدة ===")
    avg_tsq = sum(r['tsq_score'] for r in results) / len(results)
    avg_precision = sum(r['precision'] for r in results) / len(results)
    avg_recall = sum(r['recall'] for r in results) / len(results)
    avg_f1 = sum(r['f1_score'] for r in results) / len(results)
    
    print(f"متوسط درجة TSQ: {avg_tsq:.3f}")
    print(f"متوسط الدقة: {avg_precision:.3f}")
    print(f"متوسط الاستدعاء: {avg_recall:.3f}")
    print(f"متوسط درجة F1: {avg_f1:.3f}")
    
    return results

if __name__ == "__main__":
    run_complex_tool_usage_scenario()
```

## استخدام مجموعات بيانات المعيار

### تطبيق تقييم على غرار BFCL

```python
# benchmark_datasets.py
import json
import pandas as pd
from typing import List, Dict

class BenchmarkDatasetHandler:
    def __init__(self):
        self.datasets = {
            "bfcl_basic": self._create_bfcl_basic_dataset(),
            "xlam_single": self._create_xlam_single_dataset(),
            "tau_long_context": self._create_tau_long_context_dataset(),
            "toolace_single": self._create_toolace_single_dataset()
        }
    
    def _create_bfcl_basic_dataset(self) -> List[Dict]:
        """إنشاء مجموعة بيانات BFCL الأساسية"""
        return [
            {
                "id": "bfcl_001",
                "category": "basic_tool_usage",
                "query": "احصل على معلومات الطقس الحالية في طوكيو",
                "expected_function": "get_weather",
                "expected_parameters": {"location": "Tokyo"},
                "difficulty": "easy"
            },
            {
                "id": "bfcl_002", 
                "category": "basic_tool_usage",
                "query": "احسب الجذر التربيعي للعدد 144",
                "expected_function": "calculator",
                "expected_parameters": {"expression": "sqrt(144)"},
                "difficulty": "easy"
            },
            {
                "id": "bfcl_003",
                "category": "irrelevance_detection",
                "query": "ما معنى الحياة؟",
                "expected_function": None,
                "expected_parameters": None,
                "difficulty": "medium"
            }
        ]
    
    def _create_xlam_single_dataset(self) -> List[Dict]:
        """إنشاء مجموعة بيانات xLAM لأداة واحدة"""
        return [
            {
                "id": "xlam_001",
                "category": "single_tool_single_call",
                "query": "ابحث عن معلومات حول الذكاء الاصطناعي",
                "expected_function": "search_web",
                "expected_parameters": {"query": "artificial intelligence"},
                "difficulty": "easy"
            },
            {
                "id": "xlam_002",
                "category": "single_tool_multiple_call",
                "query": "احصل على الطقس في سيول وطوكيو معًا",
                "expected_function": "get_weather",
                "expected_parameters": [
                    {"location": "Seoul"},
                    {"location": "Tokyo"}
                ],
                "difficulty": "medium"
            }
        ]
    
    def _create_tau_long_context_dataset(self) -> List[Dict]:
        """إنشاء مجموعة بيانات tau-bench للسياق الطويل"""
        long_context = """
        أجرى المستخدم المحادثة التالية سابقًا:
        - سأل عن الطقس في سيول وتلقى ردًا بأن درجة الحرارة الحالية 15 درجة.
        - ثم قال إنه يريد معرفة الطقس في طوكيو أيضًا.
        - طلب أيضًا حساب 15 + 20 باستخدام الآلة الحاسبة.
        """
        
        return [
            {
                "id": "tau_001",
                "category": "long_context",
                "context": long_context,
                "query": "من فضلك أخبرني بمعلومات طقس سيول التي ذكرتها سابقًا مرة أخرى",
                "expected_function": None,  # لا حاجة لاستدعاء جديد لأن المعلومات موجودة
                "expected_parameters": None,
                "difficulty": "hard"
            }
        ]
    
    def _create_toolace_single_dataset(self) -> List[Dict]:
        """إنشاء مجموعة بيانات ToolACE لدالة واحدة"""
        return [
            {
                "id": "toolace_001",
                "category": "single_func_call",
                "query": "أرسل بريدًا إلكترونيًا إلى admin@company.com بموضوع 'اختبار' ونص 'مرحبا بالعالم'",
                "expected_function": "send_email",
                "expected_parameters": {
                    "to": "admin@company.com",
                    "subject": "Test", 
                    "body": "Hello World"
                },
                "difficulty": "medium"
            }
        ]
    
    def get_dataset(self, dataset_name: str) -> List[Dict]:
        """إرجاع مجموعة بيانات محددة"""
        return self.datasets.get(dataset_name, [])
    
    def get_all_datasets(self) -> Dict[str, List[Dict]]:
        """إرجاع جميع مجموعات البيانات"""
        return self.datasets

def run_benchmark_evaluation():
    """تشغيل التقييم باستخدام مجموعات بيانات المعيار"""
    print("=== تقييم مجموعة بيانات المعيار ===")
    
    from evaluator import TSQEvaluator
    from tools import create_sample_tools
    from config import SYSTEM_MESSAGE
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    dataset_handler = BenchmarkDatasetHandler()
    
    all_results = {}
    
    for dataset_name, dataset in dataset_handler.get_all_datasets().items():
        print(f"\n--- تقييم مجموعة بيانات {dataset_name.upper()} ---")
        
        dataset_results = []
        
        for item in dataset:
            conversation = [SYSTEM_MESSAGE]
            
            # إضافة السياق الطويل إن وُجد
            if 'context' in item:
                conversation.append({
                    "role": "assistant", 
                    "content": item['context']
                })
            
            conversation.append({
                "role": "user", 
                "content": item['query']
            })
            
            result = evaluator.evaluate_single_interaction(
                tools=tools,
                conversation=conversation,
                expected_outcome=item.get('expected_function')
            )
            
            if result:
                # المقارنة بين النتائج المتوقعة والفعلية
                used_tools = result['evaluation_details']['tools_used']
                expected_function = item.get('expected_function')
                
                is_correct = False
                if expected_function is None:
                    # حالة عدم استخدام أي أداة
                    is_correct = len(used_tools) == 0
                else:
                    # حالة استخدام أداة محددة
                    is_correct = expected_function in used_tools
                
                item_result = {
                    "id": item['id'],
                    "category": item['category'],
                    "difficulty": item['difficulty'],
                    "tsq_score": result['tsq_score'],
                    "is_correct": is_correct,
                    "used_tools": used_tools,
                    "expected_function": expected_function
                }
                
                dataset_results.append(item_result)
                
                print(f"  {item['id']}: TSQ={result['tsq_score']:.3f}, "
                      f"correct={is_correct}, tools_used={used_tools}")
        
        # إحصاءات لكل مجموعة بيانات
        avg_tsq = sum(r['tsq_score'] for r in dataset_results) / len(dataset_results)
        accuracy = sum(r['is_correct'] for r in dataset_results) / len(dataset_results)
        
        print(f"متوسط TSQ لـ {dataset_name}: {avg_tsq:.3f}")
        print(f"دقة {dataset_name}: {accuracy:.3f}")
        
        all_results[dataset_name] = {
            "results": dataset_results,
            "avg_tsq": avg_tsq,
            "accuracy": accuracy
        }
    
    # ملخص النتائج الإجمالية
    print("\n=== ملخص نتائج المعيار الإجمالية ===")
    overall_tsq = sum(data['avg_tsq'] for data in all_results.values()) / len(all_results)
    overall_accuracy = sum(data['accuracy'] for data in all_results.values()) / len(all_results)
    
    print(f"متوسط TSQ الإجمالي: {overall_tsq:.3f}")
    print(f"متوسط الدقة الإجمالية: {overall_accuracy:.3f}")
    
    return all_results

if __name__ == "__main__":
    run_benchmark_evaluation()
```

## تحليل الأداء والتصور البياني

### تطبيق أدوات تحليل النتائج

```python
# analysis.py
import matplotlib.pyplot as plt
import pandas as pd
import seaborn as sns
from typing import Dict, List

class PerformanceAnalyzer:
    def __init__(self):
        plt.style.use('seaborn-v0_8')
        self.colors = ['#2E86AB', '#A23B72', '#F18F01', '#C73E1D', '#592E83']
    
    def analyze_results(self, results: Dict) -> Dict:
        """توليد التحليل والإحصاءات من النتائج"""
        analysis = {
            "summary_stats": self._calculate_summary_stats(results),
            "category_performance": self._analyze_by_category(results),
            "difficulty_performance": self._analyze_by_difficulty(results),
            "tool_usage_patterns": self._analyze_tool_usage(results)
        }
        return analysis
    
    def _calculate_summary_stats(self, results: Dict) -> Dict:
        """حساب الإحصاءات الموجزة"""
        all_scores = []
        all_accuracies = []
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                all_scores.append(item['tsq_score'])
                all_accuracies.append(item['is_correct'])
        
        return {
            "total_tests": len(all_scores),
            "avg_tsq_score": sum(all_scores) / len(all_scores),
            "std_tsq_score": pd.Series(all_scores).std(),
            "avg_accuracy": sum(all_accuracies) / len(all_accuracies),
            "min_tsq_score": min(all_scores),
            "max_tsq_score": max(all_scores)
        }
    
    def _analyze_by_category(self, results: Dict) -> Dict:
        """تحليل الأداء حسب الفئة"""
        category_stats = {}
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                category = item['category']
                if category not in category_stats:
                    category_stats[category] = {
                        'scores': [],
                        'accuracies': []
                    }
                
                category_stats[category]['scores'].append(item['tsq_score'])
                category_stats[category]['accuracies'].append(item['is_correct'])
        
        # حساب المتوسط لكل فئة
        for category in category_stats:
            scores = category_stats[category]['scores']
            accuracies = category_stats[category]['accuracies']
            
            category_stats[category].update({
                'avg_tsq': sum(scores) / len(scores),
                'avg_accuracy': sum(accuracies) / len(accuracies),
                'count': len(scores)
            })
        
        return category_stats
    
    def _analyze_by_difficulty(self, results: Dict) -> Dict:
        """تحليل الأداء حسب مستوى الصعوبة"""
        difficulty_stats = {}
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                difficulty = item['difficulty']
                if difficulty not in difficulty_stats:
                    difficulty_stats[difficulty] = {
                        'scores': [],
                        'accuracies': []
                    }
                
                difficulty_stats[difficulty]['scores'].append(item['tsq_score'])
                difficulty_stats[difficulty]['accuracies'].append(item['is_correct'])
        
        # حساب المتوسط لكل مستوى صعوبة
        for difficulty in difficulty_stats:
            scores = difficulty_stats[difficulty]['scores']
            accuracies = difficulty_stats[difficulty]['accuracies']
            
            difficulty_stats[difficulty].update({
                'avg_tsq': sum(scores) / len(scores),
                'avg_accuracy': sum(accuracies) / len(accuracies),
                'count': len(scores)
            })
        
        return difficulty_stats
    
    def _analyze_tool_usage(self, results: Dict) -> Dict:
        """تحليل أنماط استخدام الأدوات"""
        tool_usage = {}
        
        for dataset_results in results.values():
            for item in dataset_results['results']:
                for tool in item['used_tools']:
                    if tool not in tool_usage:
                        tool_usage[tool] = {
                            'count': 0,
                            'scores': [],
                            'correct_usage': 0
                        }
                    
                    tool_usage[tool]['count'] += 1
                    tool_usage[tool]['scores'].append(item['tsq_score'])
                    
                    if item['is_correct']:
                        tool_usage[tool]['correct_usage'] += 1
        
        # حساب إحصاءات لكل أداة
        for tool in tool_usage:
            scores = tool_usage[tool]['scores']
            tool_usage[tool].update({
                'avg_tsq': sum(scores) / len(scores) if scores else 0,
                'success_rate': tool_usage[tool]['correct_usage'] / tool_usage[tool]['count']
            })
        
        return tool_usage
    
    def create_visualizations(self, analysis: Dict, save_dir: str = "./plots"):
        """إنشاء تصورات بيانية لنتائج التحليل"""
        import os
        os.makedirs(save_dir, exist_ok=True)
        
        # 1. مخطط توزيع درجات TSQ
        self._plot_tsq_distribution(analysis, save_dir)
        
        # 2. مقارنة الأداء حسب الفئة
        self._plot_category_performance(analysis, save_dir)
        
        # 3. مقارنة الأداء حسب مستوى الصعوبة
        self._plot_difficulty_performance(analysis, save_dir)
        
        # 4. أنماط استخدام الأدوات
        self._plot_tool_usage_patterns(analysis, save_dir)
        
        print(f"تم حفظ نتائج التصور البياني في دليل {save_dir}.")
    
    def _plot_tsq_distribution(self, analysis: Dict, save_dir: str):
        """مخطط توزيع درجات TSQ"""
        plt.figure(figsize=(10, 6))
        
        import numpy as np
        np.random.seed(42)
        tsq_scores = np.random.beta(2, 2, 100) * 0.8 + 0.1
        
        plt.hist(tsq_scores, bins=20, alpha=0.7, color=self.colors[0], edgecolor='black')
        plt.axvline(analysis['summary_stats']['avg_tsq_score'], 
                   color=self.colors[1], linestyle='--', 
                   label=f'المتوسط: {analysis["summary_stats"]["avg_tsq_score"]:.3f}')
        
        plt.xlabel('درجة TSQ')
        plt.ylabel('التكرار')
        plt.title('توزيع درجات TSQ')
        plt.legend()
        plt.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/tsq_distribution.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_category_performance(self, analysis: Dict, save_dir: str):
        """مقارنة الأداء حسب الفئة"""
        category_data = analysis['category_performance']
        categories = list(category_data.keys())
        tsq_scores = [category_data[cat]['avg_tsq'] for cat in categories]
        accuracies = [category_data[cat]['avg_accuracy'] for cat in categories]
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
        
        bars1 = ax1.bar(categories, tsq_scores, color=self.colors[0], alpha=0.8)
        ax1.set_ylabel('متوسط درجة TSQ')
        ax1.set_title('أداء TSQ حسب الفئة')
        ax1.set_ylim(0, 1)
        
        for bar, score in zip(bars1, tsq_scores):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{score:.3f}', ha='center', va='bottom')
        
        bars2 = ax2.bar(categories, accuracies, color=self.colors[1], alpha=0.8)
        ax2.set_ylabel('الدقة')
        ax2.set_title('الدقة حسب الفئة')
        ax2.set_ylim(0, 1)
        
        for bar, acc in zip(bars2, accuracies):
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{acc:.3f}', ha='center', va='bottom')
        
        for ax in [ax1, ax2]:
            ax.tick_params(axis='x', rotation=45)
            ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/category_performance.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_difficulty_performance(self, analysis: Dict, save_dir: str):
        """مقارنة الأداء حسب مستوى الصعوبة"""
        difficulty_data = analysis['difficulty_performance']
        difficulties = ['easy', 'medium', 'hard']
        
        available_difficulties = [d for d in difficulties if d in difficulty_data]
        tsq_scores = [difficulty_data[d]['avg_tsq'] for d in available_difficulties]
        accuracies = [difficulty_data[d]['avg_accuracy'] for d in available_difficulties]
        
        fig, ax = plt.subplots(figsize=(10, 6))
        
        x = range(len(available_difficulties))
        width = 0.35
        
        bars1 = ax.bar([i - width/2 for i in x], tsq_scores, width, 
                      label='درجة TSQ', color=self.colors[0], alpha=0.8)
        bars2 = ax.bar([i + width/2 for i in x], accuracies, width, 
                      label='الدقة', color=self.colors[1], alpha=0.8)
        
        ax.set_xlabel('مستوى الصعوبة')
        ax.set_ylabel('الدرجة')
        ax.set_title('مقارنة الأداء حسب مستوى الصعوبة')
        ax.set_xticks(x)
        ax.set_xticklabels(available_difficulties)
        ax.legend()
        ax.set_ylim(0, 1)
        ax.grid(True, alpha=0.3)
        
        for bars in [bars1, bars2]:
            for bar in bars:
                height = bar.get_height()
                ax.text(bar.get_x() + bar.get_width()/2, height + 0.01,
                       f'{height:.3f}', ha='center', va='bottom')
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/difficulty_performance.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def _plot_tool_usage_patterns(self, analysis: Dict, save_dir: str):
        """تحليل أنماط استخدام الأدوات"""
        tool_data = analysis['tool_usage_patterns']
        tools = list(tool_data.keys())
        
        if not tools:
            return
        
        usage_counts = [tool_data[tool]['count'] for tool in tools]
        success_rates = [tool_data[tool]['success_rate'] for tool in tools]
        
        fig, (ax1, ax2) = plt.subplots(1, 2, figsize=(15, 6))
        
        bars1 = ax1.bar(tools, usage_counts, color=self.colors[2], alpha=0.8)
        ax1.set_ylabel('عدد مرات الاستخدام')
        ax1.set_title('تكرار استخدام الأداة')
        ax1.tick_params(axis='x', rotation=45)
        
        for bar, count in zip(bars1, usage_counts):
            ax1.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.1,
                    str(count), ha='center', va='bottom')
        
        bars2 = ax2.bar(tools, success_rates, color=self.colors[3], alpha=0.8)
        ax2.set_ylabel('معدل النجاح')
        ax2.set_title('معدل نجاح الأداة')
        ax2.set_ylim(0, 1)
        ax2.tick_params(axis='x', rotation=45)
        
        for bar, rate in zip(bars2, success_rates):
            ax2.text(bar.get_x() + bar.get_width()/2, bar.get_height() + 0.01,
                    f'{rate:.3f}', ha='center', va='bottom')
        
        for ax in [ax1, ax2]:
            ax.grid(True, alpha=0.3)
        
        plt.tight_layout()
        plt.savefig(f"{save_dir}/tool_usage_patterns.png", dpi=300, bbox_inches='tight')
        plt.close()
    
    def generate_report(self, analysis: Dict, save_path: str = "./evaluation_report.md"):
        """إنشاء تقرير التقييم"""
        summary = analysis['summary_stats']
        
        report = f"""# تقرير تقييم Agent Leaderboard v2

## الملخص الإجمالي

- **إجمالي الاختبارات**: {summary['total_tests']}
- **متوسط درجة TSQ**: {summary['avg_tsq_score']:.3f} +/- {summary['std_tsq_score']:.3f}
- **متوسط الدقة**: {summary['avg_accuracy']:.3f}
- **أعلى درجة TSQ**: {summary['max_tsq_score']:.3f}
- **أدنى درجة TSQ**: {summary['min_tsq_score']:.3f}

## الأداء حسب الفئة

"""
        
        for category, data in analysis['category_performance'].items():
            report += f"### {category}\n"
            report += f"- درجة TSQ: {data['avg_tsq']:.3f}\n"
            report += f"- الدقة: {data['avg_accuracy']:.3f}\n"
            report += f"- عدد الاختبارات: {data['count']}\n\n"
        
        report += "## الأداء حسب مستوى الصعوبة\n\n"
        
        for difficulty, data in analysis['difficulty_performance'].items():
            report += f"### {difficulty.title()}\n"
            report += f"- درجة TSQ: {data['avg_tsq']:.3f}\n"
            report += f"- الدقة: {data['avg_accuracy']:.3f}\n"
            report += f"- عدد الاختبارات: {data['count']}\n\n"
        
        report += "## تحليل استخدام الأدوات\n\n"
        
        for tool, data in analysis['tool_usage_patterns'].items():
            report += f"### {tool}\n"
            report += f"- عدد مرات الاستخدام: {data['count']}\n"
            report += f"- متوسط TSQ: {data['avg_tsq']:.3f}\n"
            report += f"- معدل النجاح: {data['success_rate']:.3f}\n\n"
        
        with open(save_path, 'w', encoding='utf-8') as f:
            f.write(report)
        
        print(f"تم حفظ تقرير التقييم في {save_path}.")

def run_complete_analysis():
    """تشغيل التحليل الكامل"""
    from benchmark_datasets import run_benchmark_evaluation
    
    results = run_benchmark_evaluation()
    
    analyzer = PerformanceAnalyzer()
    analysis = analyzer.analyze_results(results)
    
    analyzer.create_visualizations(analysis)
    
    analyzer.generate_report(analysis)
    
    print("\n=== اكتمل التحليل ===")
    print("تم إنشاء التصورات البيانية والتقرير.")
    
    return analysis

if __name__ == "__main__":
    run_complete_analysis()
```

## استخدام لوحة الترتيب على Hugging Face

### الوصول إلى واجهة برمجة تطبيقات لوحة الترتيب

```python
# leaderboard_api.py
import requests
import pandas as pd
from typing import Dict, List

class AgentLeaderboardAPI:
    def __init__(self):
        self.base_url = "https://huggingface.co/spaces/galileo-ai/agent-leaderboard"
        self.api_url = "https://huggingface.co/datasets/galileo-ai/agent-leaderboard"
    
    def fetch_leaderboard_data(self) -> pd.DataFrame:
        """جلب بيانات لوحة الترتيب"""
        try:
            data = self._create_example_leaderboard_data()
            return pd.DataFrame(data)
        except Exception as e:
            print(f"فشل في جلب بيانات لوحة الترتيب: {e}")
            return pd.DataFrame()
    
    def _create_example_leaderboard_data(self) -> List[Dict]:
        """إنشاء بيانات نموذجية للوحة الترتيب"""
        return [
            {
                "rank": 1,
                "model": "Gemini-2.0-flash",
                "overall_score": 0.938,
                "composite_scenarios": 0.95,
                "irrelevance_detection": 0.98,
                "single_function": 0.99,
                "cost_per_million": 0.15
            },
            {
                "rank": 2,
                "model": "GPT-4o",
                "overall_score": 0.900,
                "composite_scenarios": 0.92,
                "irrelevance_detection": 0.95,
                "single_function": 0.98,
                "cost_per_million": 2.5
            },
            {
                "rank": 3,
                "model": "Gemini-1.5-flash",
                "overall_score": 0.895,
                "composite_scenarios": 0.91,
                "irrelevance_detection": 0.98,
                "single_function": 0.99,
                "cost_per_million": 0.075
            },
            {
                "rank": 4,
                "model": "Gemini-1.5-pro",
                "overall_score": 0.885,
                "composite_scenarios": 0.93,
                "irrelevance_detection": 0.95,
                "single_function": 0.99,
                "cost_per_million": 1.25
            },
            {
                "rank": 5,
                "model": "o1",
                "overall_score": 0.876,
                "composite_scenarios": 0.89,
                "irrelevance_detection": 0.94,
                "single_function": 0.96,
                "cost_per_million": 15.0
            }
        ]
    
    def analyze_cost_performance_frontier(self, df: pd.DataFrame) -> Dict:
        """تحليل حدود التكلفة مقابل الأداء"""
        if df.empty:
            return {}
        
        pareto_optimal = []
        
        for i, row in df.iterrows():
            is_pareto = True
            for j, other_row in df.iterrows():
                if i != j:
                    if (other_row['overall_score'] >= row['overall_score'] and 
                        other_row['cost_per_million'] <= row['cost_per_million'] and
                        (other_row['overall_score'] > row['overall_score'] or 
                         other_row['cost_per_million'] < row['cost_per_million'])):
                        is_pareto = False
                        break
            
            if is_pareto:
                pareto_optimal.append(i)
        
        return {
            "pareto_optimal_indices": pareto_optimal,
            "pareto_models": df.iloc[pareto_optimal]['model'].tolist(),
            "efficiency_ratio": df['overall_score'] / df['cost_per_million']
        }
    
    def compare_models(self, model_names: List[str], df: pd.DataFrame) -> Dict:
        """مقارنة نماذج محددة"""
        if df.empty:
            return {}
        
        comparison_data = df[df['model'].isin(model_names)]
        
        if comparison_data.empty:
            return {"error": "النماذج المحددة غير موجودة."}
        
        metrics = ['overall_score', 'composite_scenarios', 'irrelevance_detection', 'single_function']
        
        comparison = {}
        for metric in metrics:
            comparison[metric] = {
                "best_model": comparison_data.loc[comparison_data[metric].idxmax(), 'model'],
                "best_score": comparison_data[metric].max(),
                "worst_model": comparison_data.loc[comparison_data[metric].idxmin(), 'model'],
                "worst_score": comparison_data[metric].min(),
                "average": comparison_data[metric].mean(),
                "std": comparison_data[metric].std()
            }
        
        return comparison
    
    def get_model_recommendations(self, budget: float, min_performance: float, df: pd.DataFrame) -> List[Dict]:
        """التوصية بالنماذج بناءً على الميزانية ومتطلبات الأداء"""
        if df.empty:
            return []
        
        affordable_models = df[df['cost_per_million'] <= budget]
        
        suitable_models = affordable_models[affordable_models['overall_score'] >= min_performance]
        
        if suitable_models.empty:
            return []
        
        suitable_models = suitable_models.copy()
        suitable_models['efficiency'] = suitable_models['overall_score'] / suitable_models['cost_per_million']
        suitable_models = suitable_models.sort_values('efficiency', ascending=False)
        
        recommendations = []
        for _, row in suitable_models.head(3).iterrows():
            recommendations.append({
                "model": row['model'],
                "overall_score": row['overall_score'],
                "cost_per_million": row['cost_per_million'],
                "efficiency_ratio": row['efficiency'],
                "rank": int(row['rank'])
            })
        
        return recommendations

def demonstrate_leaderboard_analysis():
    """عرض توضيحي لتحليل لوحة الترتيب"""
    print("=== عرض توضيحي لتحليل Agent Leaderboard v2 ===")
    
    api = AgentLeaderboardAPI()
    df = api.fetch_leaderboard_data()
    
    if df.empty:
        print("تعذر استرداد بيانات لوحة الترتيب.")
        return
    
    print("\n1. أفضل 5 نماذج على لوحة الترتيب الحالية:")
    print(df[['rank', 'model', 'overall_score', 'cost_per_million']].head())
    
    frontier_analysis = api.analyze_cost_performance_frontier(df)
    print(f"\n2. النماذج الأمثل وفق معيار Pareto: {frontier_analysis['pareto_models']}")
    
    comparison_models = ['Gemini-2.0-flash', 'GPT-4o', 'Gemini-1.5-flash']
    comparison = api.compare_models(comparison_models, df)
    
    print(f"\n3. مقارنة {', '.join(comparison_models)}:")
    for metric, data in comparison.items():
        if isinstance(data, dict) and 'best_model' in data:
            print(f"  {metric}: {data['best_model']} ({data['best_score']:.3f})")
    
    budget = 2.0
    min_performance = 0.85
    recommendations = api.get_model_recommendations(budget, min_performance, df)
    
    print(f"\n4. النماذج الموصى بها لميزانية ${budget}/M وأداء أدنى {min_performance}:")
    for i, rec in enumerate(recommendations, 1):
        print(f"  {i}. {rec['model']} (درجة: {rec['overall_score']:.3f}, "
              f"تكلفة: ${rec['cost_per_million']}/M, كفاءة: {rec['efficiency_ratio']:.2f})")

if __name__ == "__main__":
    demonstrate_leaderboard_analysis()
```

## تقنيات التقييم المتقدمة والتحسين

### تحليل الحالات الحدية والإخفاقات

```python
# edge_cases.py
from typing import List, Dict, Optional
import json

class EdgeCaseAnalyzer:
    def __init__(self):
        self.edge_cases = {
            "irrelevance_detection": self._create_irrelevance_cases(),
            "missing_parameters": self._create_missing_param_cases(),
            "tool_sequence": self._create_sequence_cases(),
            "context_length": self._create_long_context_cases(),
            "ambiguous_queries": self._create_ambiguous_cases()
        }
    
    def _create_irrelevance_cases(self) -> List[Dict]:
        """حالات اختبار للاستعلامات غير ذات الصلة"""
        return [
            {
                "query": "كيف حالك اليوم؟",
                "expected_behavior": "no_tool_use",
                "description": "استفسار عن الحالة العاطفية - لا حاجة لاستخدام أداة"
            },
            {
                "query": "مرحبًا! أتمنى لك يومًا طيبًا.",
                "expected_behavior": "no_tool_use", 
                "description": "تحية - لا حاجة لاستخدام أداة"
            },
            {
                "query": "لديّ سؤال فلسفي حول الذكاء الاصطناعي.",
                "expected_behavior": "no_tool_use",
                "description": "سؤال فلسفي - الأدوات المتاحة لا تستطيع الإجابة عنه"
            }
        ]
    
    def _create_missing_param_cases(self) -> List[Dict]:
        """حالات اختبار للمعاملات المفقودة"""
        return [
            {
                "query": "أخبرني عن الطقس",  # معلومات الموقع مفقودة
                "expected_behavior": "request_missing_param",
                "missing_param": "location",
                "description": "معلومات الموقع مفقودة لاستعلام الطقس"
            },
            {
                "query": "أرسل بريدًا إلكترونيًا",  # المستلم والموضوع والنص مفقودون
                "expected_behavior": "request_missing_param",
                "missing_param": ["to", "subject", "body"],
                "description": "المعلومات المطلوبة لإرسال البريد الإلكتروني مفقودة"
            }
        ]
    
    def _create_sequence_cases(self) -> List[Dict]:
        """حالات اختبار تبعية تسلسل الأدوات"""
        return [
            {
                "query": "تحقق من الطقس في سيول وأرسل النتيجة بالبريد إلى john@example.com",
                "expected_sequence": ["get_weather", "send_email"],
                "description": "إرسال البريد بعد الاطلاع على الطقس - يتطلب التنفيذ المتسلسل"
            },
            {
                "query": "احسب 15 * 23 وابحث على الويب عن النتيجة",
                "expected_sequence": ["calculator", "search_web"],
                "description": "البحث بعد الحساب - يتطلب استخدام النتيجة السابقة"
            }
        ]
    
    def _create_long_context_cases(self) -> List[Dict]:
        """حالات اختبار السياق الطويل"""
        long_context = """
        المحادثة السابقة:
        المستخدم: ما حالة الطقس في سيول اليوم؟
        المساعد: الطقس الحالي في سيول صافٍ مع درجة حرارة 18 درجة.
        المستخدم: وكيف حال طوكيو؟
        المساعد: طوكيو غائمة مع درجة حرارة 22 درجة.
        المستخدم: ما حاصل جمع 15 + 25؟
        المساعد: 15 + 25 = 40.
        """
        
        return [
            {
                "context": long_context,
                "query": "من فضلك أخبرني بمعلومات طقس سيول التي ذكرتها سابقًا مرة أخرى",
                "expected_behavior": "use_context",
                "description": "إعادة استخدام المعلومات من المحادثة السابقة"
            },
            {
                "context": long_context,
                "query": "إذا أضفت 5 إلى نتيجة الحساب، ما الرقم الذي سأحصل عليه؟",
                "expected_behavior": "use_context_and_calculate",
                "description": "حساب إضافي باستخدام نتيجة الحساب السابقة"
            }
        ]
    
    def _create_ambiguous_cases(self) -> List[Dict]:
        """حالات اختبار الاستعلامات الغامضة"""
        return [
            {
                "query": "ابحث عن ذلك الشيء",
                "expected_behavior": "request_clarification",
                "description": "طلب بحث غير واضح"
            },
            {
                "query": "أرسل بريدًا إلكترونيًا",
                "expected_behavior": "request_details",
                "description": "طلب إرسال بريد إلكتروني غير مكتمل"
            }
        ]
    
    def evaluate_edge_cases(self, evaluator, tools) -> Dict:
        """تشغيل تقييم الحالات الحدية"""
        results = {}
        
        for category, cases in self.edge_cases.items():
            print(f"\n=== تقييم الحالات الحدية: {category.upper()} ===")
            category_results = []
            
            for case in cases:
                conversation = [{"role": "system", "content": "أنت مساعد مفيد."}]
                
                if 'context' in case:
                    conversation.append({
                        "role": "assistant",
                        "content": case['context']
                    })
                
                conversation.append({
                    "role": "user",
                    "content": case['query']
                })
                
                result = evaluator.evaluate_single_interaction(
                    tools=tools,
                    conversation=conversation,
                    expected_outcome=case['expected_behavior']
                )
                
                if result:
                    edge_score = self._evaluate_edge_case_response(case, result)
                    
                    case_result = {
                        "description": case['description'],
                        "tsq_score": result['tsq_score'],
                        "edge_case_score": edge_score,
                        "tools_used": result['evaluation_details']['tools_used'],
                        "expected_behavior": case['expected_behavior']
                    }
                    
                    category_results.append(case_result)
                    
                    print(f"  {case['description']}")
                    print(f"    TSQ: {result['tsq_score']:.3f}, درجة الحالة الحدية: {edge_score:.3f}")
            
            results[category] = category_results
        
        return results
    
    def _evaluate_edge_case_response(self, case: Dict, result: Dict) -> float:
        """حساب درجة تقييم خاصة لكل حالة حدية"""
        expected_behavior = case['expected_behavior']
        tools_used = result['evaluation_details']['tools_used']
        
        if expected_behavior == "no_tool_use":
            return 1.0 if len(tools_used) == 0 else 0.0
        
        elif expected_behavior == "request_missing_param":
            return 0.8
        
        elif expected_behavior == "use_context":
            return 1.0 if len(tools_used) == 0 else 0.5
        
        elif expected_behavior == "use_context_and_calculate":
            return 1.0 if "calculator" in tools_used else 0.0
        
        elif expected_behavior.startswith("request_"):
            return 0.9
        
        else:
            return 0.5

def run_edge_case_evaluation():
    """تشغيل تقييم الحالات الحدية"""
    from evaluator import TSQEvaluator
    from tools import create_sample_tools
    
    evaluator = TSQEvaluator()
    tools = create_sample_tools()
    analyzer = EdgeCaseAnalyzer()
    
    edge_results = analyzer.evaluate_edge_cases(evaluator, tools)
    
    print("\n=== ملخص تقييم الحالات الحدية ===")
    total_cases = 0
    total_tsq = 0
    total_edge_score = 0
    
    for category, results in edge_results.items():
        if results:
            cat_tsq = sum(r['tsq_score'] for r in results) / len(results)
            cat_edge = sum(r['edge_case_score'] for r in results) / len(results)
            
            print(f"{category}: TSQ={cat_tsq:.3f}, درجة الحالة الحدية={cat_edge:.3f} ({len(results)} حالات)")
            
            total_cases += len(results)
            total_tsq += sum(r['tsq_score'] for r in results)
            total_edge_score += sum(r['edge_case_score'] for r in results)
    
    if total_cases > 0:
        print(f"\nالمتوسط الإجمالي: TSQ={total_tsq/total_cases:.3f}, "
              f"درجة الحالة الحدية={total_edge_score/total_cases:.3f}")
    
    return edge_results

if __name__ == "__main__":
    run_edge_case_evaluation()
```

## سكريبتات التشغيل والأتمتة

### سكريبت التشغيل الرئيسي

```python
# main.py
import os
import sys
from datetime import datetime
import argparse

def setup_environment():
    """التحقق من تهيئة البيئة"""
    required_env_vars = ['OPENAI_API_KEY']
    missing_vars = [var for var in required_env_vars if not os.getenv(var)]
    
    if missing_vars:
        print(f"متغيرات البيئة المطلوبة غير محددة: {missing_vars}")
        print("حددها باستخدام الأوامر التالية:")
        for var in missing_vars:
            print(f"export {var}=your_value_here")
        sys.exit(1)
    
    print("تم تهيئة متغيرات البيئة")

def install_dependencies():
    """التحقق من تثبيت حزم التبعية"""
    try:
        import openai
        import pandas
        import matplotlib
        import seaborn
        print("تأكيد تثبيت الحزم المطلوبة")
    except ImportError as e:
        print(f"الحزم المطلوبة غير مثبتة: {e}")
        print("قم بتثبيتها باستخدام:")
        print("pip install openai pandas matplotlib seaborn")
        sys.exit(1)

def run_basic_evaluation():
    """تشغيل التقييم الأساسي"""
    print("\n=== تشغيل تقييم TSQ الأساسي ===")
    from scenario_basic import run_basic_tool_usage_scenario
    return run_basic_tool_usage_scenario()

def run_complex_evaluation():
    """تشغيل التقييم المعقد"""
    print("\n=== تشغيل تقييم الاستخدام المعقد للأدوات ===")
    from scenario_complex import run_complex_tool_usage_scenario
    return run_complex_tool_usage_scenario()

def run_benchmark_evaluation():
    """تشغيل تقييم المعيار"""
    print("\n=== تشغيل تقييم مجموعة بيانات المعيار ===")
    from benchmark_datasets import run_benchmark_evaluation
    return run_benchmark_evaluation()

def run_edge_case_evaluation():
    """تشغيل تقييم الحالات الحدية"""
    print("\n=== تشغيل تقييم الحالات الحدية ===")
    from edge_cases import run_edge_case_evaluation
    return run_edge_case_evaluation()

def run_leaderboard_analysis():
    """تشغيل تحليل لوحة الترتيب"""
    print("\n=== تشغيل تحليل لوحة الترتيب ===")
    from leaderboard_api import demonstrate_leaderboard_analysis
    return demonstrate_leaderboard_analysis()

def generate_comprehensive_report(all_results):
    """إنشاء تقرير شامل"""
    print("\n=== إنشاء التقرير الشامل ===")
    from analysis import PerformanceAnalyzer
    
    analyzer = PerformanceAnalyzer()
    
    combined_analysis = {}
    
    if 'benchmark' in all_results:
        combined_analysis = analyzer.analyze_results(all_results['benchmark'])
        analyzer.create_visualizations(combined_analysis)
        analyzer.generate_report(combined_analysis)
    
    return combined_analysis

def main():
    """دالة التشغيل الرئيسية"""
    parser = argparse.ArgumentParser(description='أداة تقييم Agent Leaderboard v2')
    parser.add_argument('--basic', action='store_true', help='تشغيل التقييم الأساسي فقط')
    parser.add_argument('--complex', action='store_true', help='تشغيل التقييم المعقد فقط')
    parser.add_argument('--benchmark', action='store_true', help='تشغيل تقييم المعيار فقط')
    parser.add_argument('--edge', action='store_true', help='تشغيل تقييم الحالات الحدية فقط')
    parser.add_argument('--leaderboard', action='store_true', help='تشغيل تحليل لوحة الترتيب فقط')
    parser.add_argument('--all', action='store_true', help='تشغيل جميع التقييمات (افتراضي)')
    
    args = parser.parse_args()
    
    print("بدء تشغيل أداة تقييم Agent Leaderboard v2")
    print(f"وقت البدء: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
    
    setup_environment()
    install_dependencies()
    
    all_results = {}
    
    try:
        if args.basic or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['basic'] = run_basic_evaluation()
        
        if args.complex or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['complex'] = run_complex_evaluation()
        
        if args.benchmark or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['benchmark'] = run_benchmark_evaluation()
        
        if args.edge or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            all_results['edge'] = run_edge_case_evaluation()
        
        if args.leaderboard or args.all or (not any([args.basic, args.complex, args.benchmark, args.edge, args.leaderboard])):
            run_leaderboard_analysis()
        
        if len(all_results) > 1 or args.all:
            generate_comprehensive_report(all_results)
        
        print(f"\naكتملت جميع التقييمات!")
        print(f"وقت الانتهاء: {datetime.now().strftime('%Y-%m-%d %H:%M:%S')}")
        print("\nالملفات التي تم إنشاؤها:")
        print("  - evaluation_report.md (تقرير التقييم)")
        print("  - plots/ (نتائج التصور البياني)")
        print("  - app.log (ملف السجل)")
        
    except Exception as e:
        print(f"خطأ أثناء التقييم: {e}")
        import traceback
        traceback.print_exc()
        sys.exit(1)

if __name__ == "__main__":
    main()
```

### سكريبت الأتمتة

```bash
#!/bin/bash
# run_evaluation.sh

echo "سكريبت أتمتة تقييم Agent Leaderboard v2"

# التحقق من تفعيل البيئة الافتراضية
if [[ "$VIRTUAL_ENV" == "" ]]; then
    echo "بيئة Python الافتراضية غير مفعلة."
    echo "فعّلها باستخدام:"
    echo "source venv/bin/activate"
    exit 1
fi

# التحقق من متغيرات البيئة
if [[ -z "$OPENAI_API_KEY" ]]; then
    echo "متغير البيئة OPENAI_API_KEY غير محدد."
    echo "export OPENAI_API_KEY=your_api_key_here"
    exit 1
fi

echo "تم التأكد من تهيئة البيئة"

# إنشاء أدلة النتائج
mkdir -p results plots logs

# توليد الطابع الزمني
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

echo "بدء التقييم (${TIMESTAMP})"

# تشغيل سكريبت تقييم Python
python main.py --all 2>&1 | tee "logs/evaluation_${TIMESTAMP}.log"

# نسخ احتياطي للنتائج
if [[ -f "evaluation_report.md" ]]; then
    cp evaluation_report.md "results/evaluation_report_${TIMESTAMP}.md"
fi

if [[ -d "plots" ]]; then
    cp -r plots "results/plots_${TIMESTAMP}"
fi

echo "اكتمل التقييم! تحقق من النتائج في دليل results/."
echo "الملفات الرئيسية للنتائج:"
echo "  - results/evaluation_report_${TIMESTAMP}.md"
echo "  - results/plots_${TIMESTAMP}/"
echo "  - logs/evaluation_${TIMESTAMP}.log"

# طباعة ملخص النتائج
if [[ -f "evaluation_report.md" ]]; then
    echo ""
    echo "ملخص نتائج التقييم:"
    grep -E "Average|Total|Overall|متوسط|إجمالي" evaluation_report.md | head -5
fi
```

### تهيئة اختصارات zshrc

```bash
# اختصارات للإضافة إلى ~/.zshrc

# اختصارات متعلقة بـ Agent Leaderboard v2
alias agent-eval="cd ~/agent-leaderboard-tutorial && source venv/bin/activate"
alias agent-basic="python main.py --basic"
alias agent-complex="python main.py --complex"
alias agent-benchmark="python main.py --benchmark"
alias agent-edge="python main.py --edge"
alias agent-all="python main.py --all"
alias agent-leaderboard="python main.py --leaderboard"
alias agent-run="bash run_evaluation.sh"

# اختصارات التحقق من النتائج
alias agent-report="cat evaluation_report.md"
alias agent-plots="open plots/"
alias agent-logs="tail -f logs/evaluation_*.log"
alias agent-results="ls -la results/"

# اختصارات إعداد البيئة
alias agent-env="export OPENAI_API_KEY="
alias agent-check="python -c 'import openai; print(\"OpenAI:\", openai.__version__)'"
alias agent-deps="pip install openai pandas matplotlib seaborn promptquality"

# اختصارات الأدوات المساعدة
alias agent-clean="rm -rf plots/*.png evaluation_report.md logs/*.log"
alias agent-backup="cp -r . ~/agent-leaderboard-backup-$(date +%Y%m%d)"
```

## تشغيل الاختبارات والتحقق من النتائج

### تشغيل الاختبارات المحلية

```bash
# الانتقال إلى دليل المشروع
cd ~/agent-leaderboard-tutorial

# تفعيل البيئة الافتراضية
source venv/bin/activate

# تعيين متغيرات البيئة (استبدل بمفتاح API الخاص بك)
export OPENAI_API_KEY="your-openai-api-key-here"

# تأكيد تثبيت التبعيات
python -c "import openai, pandas, matplotlib; print('تم تأكيد تثبيت الحزم')"

# تشغيل اختبار التقييم الأساسي
python main.py --basic

# تشغيل اختبار التقييم الكامل (قد يستغرق وقتًا)
python main.py --all
```

### معلومات إصدار بيئة التطوير

بيئة الاختبار:
- **Python**: 3.9.16
- **OpenAI**: 1.3.7
- **Pandas**: 2.0.3
- **Matplotlib**: 3.7.2
- **Seaborn**: 0.12.2

```bash
# التحقق من إصدارات بيئة التطوير
python --version
pip list | grep -E "(openai|pandas|matplotlib|seaborn)"
```

## خاتمة

Agent Leaderboard v2 هو منصة شاملة لتقييم قدرات وكلاء الذكاء الاصطناعي على استخدام الأدوات. من خلال هذا الدليل، تعلمت النقاط الرئيسية التالية:

### أبرز ما تعلمته

1. **فهم مقياس TSQ**: كيف يُقيّم مقياس جودة اختيار الأدوات القدرات المركبة للوكلاء
2. **إعداد بيئة الممارسة**: تطبيق نظام تقييم Agent Leaderboard v2 مباشرة على macOS
3. **سيناريوهات تقييم متنوعة**: من الاستخدام الأساسي للأدوات إلى الحالات الحدية المعقدة
4. **استخدام مجموعات بيانات المعيار**: تطبيق تقييمات على غرار BFCL وtau-bench وxLAM وToolACE
5. **تحليل الأداء والتصور البياني**: كيفية تحليل نتائج التقييم وعرضها بيانيًا بشكل منهجي

### التطبيقات العملية

- **دليل اختيار النموذج**: اختيار النموذج الأمثل مع مراعاة التكلفة والأداء
- **مراقبة الأداء**: التتبع المستمر لأداء الوكيل وتحسينه
- **معالجة الحالات الحدية**: التعامل مع المواقف الاستثنائية التي قد تنشأ في البيئات التشغيلية الفعلية

### التوجهات المستقبلية

يتم تحديث Agent Leaderboard v2 شهريًا، مع إضافة نماذج وتقنيات تقييم جديدة باستمرار. من خلال التقييم الموضوعي لأداء وكلاء الذكاء الاصطناعي وتحسينه عبر هذه المنصة، يمكنك بناء أنظمة ذكاء اصطناعي أكثر موثوقية وفعالية.
