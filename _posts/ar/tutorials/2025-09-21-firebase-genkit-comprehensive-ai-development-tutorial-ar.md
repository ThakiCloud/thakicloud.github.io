---
title: "Firebase Genkit: دليل شامل لبناء تطبيقات الذكاء الاصطناعي الإنتاجية"
excerpt: "تعلم Firebase Genkit لبناء ونشر ومراقبة التطبيقات المدعومة بالذكاء الاصطناعي باستخدام JavaScript و Go و Python. دليل شامل يغطي الذكاء الاصطناعي متعدد الوسائط والمخرجات المنظمة والنشر الإنتاجي."
seo_title: "دروس Firebase Genkit: بناء تطبيقات الذكاء الاصطناعي الإنتاجية - Thaki Cloud"
seo_description: "تعلم Firebase Genkit لبناء تطبيقات الذكاء الاصطناعي الإنتاجية. دليل كامل يغطي التثبيت والتطوير والنشر والمراقبة مع أمثلة عملية."
date: 2025-09-21
categories:
  - tutorials
tags:
  - firebase
  - genkit
  - ai
  - javascript
  - go
  - python
  - دروس
author_profile: true
toc: true
toc_label: "فهرس المحتويات"
lang: ar
permalink: /ar/tutorials/firebase-genkit-comprehensive-ai-development-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/firebase-genkit-comprehensive-ai-development-tutorial/"
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## المقدمة

Firebase Genkit هو إطار عمل مفتوح المصدر من Google لبناء التطبيقات المدعومة بالذكاء الاصطناعي باستخدام JavaScript و Go و Python. يستخدمه فريق Firebase في Google في الإنتاج، ويوفر Genkit واجهة موحدة لدمج نماذج الذكاء الاصطناعي من مقدمي خدمات مختلفين بما في ذلك Google و OpenAI و Anthropic و Ollama.

في هذا الدليل الشامل، سنستكشف كيفية بناء ونشر ومراقبة تطبيقات الذكاء الاصطناعي الجاهزة للإنتاج باستخدام Firebase Genkit.

## ما هو Firebase Genkit؟

Firebase Genkit هو SDK مفتوح المصدر يبسط تطوير تطبيقات الذكاء الاصطناعي من خلال توفير:

- **واجهة نماذج موحدة**: العمل مع مئات نماذج الذكاء الاصطناعي من خلال واجهات برمجة تطبيقات متسقة
- **دعم متعدد اللغات**: JavaScript/TypeScript (جاهز للإنتاج)، Go (جاهز للإنتاج)، Python (ألفا)
- **أدوات الإنتاج**: مراقبة وتصحيح ونشر مدمج
- **دعم متعدد الوسائط**: توليد النصوص والصور والبيانات المنظمة
- **تجربة المطور**: أدوات CLI المحلية والتصحيح المرئي

### الإمكانيات الرئيسية

| الميزة | الوصف |
|--------|---------|
| **دعم واسع لنماذج الذكاء الاصطناعي** | واجهة موحدة لنماذج Google و OpenAI و Anthropic و Ollama |
| **تطوير مبسط** | واجهات برمجة تطبيقات مبسطة للمخرجات المنظمة واستدعاء الأدوات و RAG |
| **جاهز للويب/الموبايل** | تكامل سلس مع Next.js و React و Angular و iOS و Android |
| **متعدد اللغات** | واجهات برمجة تطبيقات متسقة عبر JavaScript و Go و Python |
| **نشر في أي مكان** | Cloud Functions و Cloud Run أو أي منصة استضافة |
| **أدوات المطور** | CLI و UI محلي للاختبار والتصحيح والتقييم |
| **مراقبة الإنتاج** | مراقبة شاملة وتتبع الأداء |

## التثبيت والإعداد

### المتطلبات المسبقة

- Node.js 18+ (لـ JavaScript/TypeScript)
- Go 1.21+ (لتطوير Go)
- Python 3.9+ (لتطوير Python)
- مفاتيح API لمقدم نماذج الذكاء الاصطناعي المختار

### إعداد JavaScript/TypeScript

```bash
# تثبيت Genkit CLI عالمياً
npm install -g genkit-cli

# إنشاء مشروع جديد
mkdir my-genkit-app
cd my-genkit-app
npm init -y

# تثبيت Genkit الأساسي وإضافة Google AI
npm install genkit @genkit-ai/google-genai

# تثبيت تبعيات التطوير
npm install -D typescript @types/node tsx
```

### إعداد Go

```bash
# تهيئة وحدة Go
go mod init my-genkit-app

# تثبيت Genkit لـ Go
go get github.com/firebase/genkit/go/genkit
go get github.com/firebase/genkit/go/plugins/googleai
```

### إعداد Python (ألفا)

```bash
# إنشاء بيئة افتراضية
python -m venv genkit-env
source genkit-env/bin/activate  # في Windows: genkit-env\Scripts\activate

# تثبيت Genkit لـ Python
pip install genkit google-genai
```

## أمثلة الاستخدام الأساسي

### مثال JavaScript/TypeScript

إنشاء تطبيق ذكاء اصطناعي أساسي:

```typescript
// index.ts
import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';

// تهيئة Genkit مع إضافة Google AI
const ai = genkit({ 
  plugins: [googleAI()] 
});

// توليد النص الأساسي
async function generateText() {
  const {% raw %}{ text }{% endraw %} = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: 'اشرح الحوسبة الكمية بمصطلحات بسيطة'
  });
  
  console.log(text);
}

// توليد البيانات المنظمة
async function generateStructuredData() {
  const response = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: 'أنشئ مراجعة منتج لهاتف ذكي',
    output: {
      schema: {
        type: 'object',
        properties: {
          product: { type: 'string' },
          rating: { type: 'number', minimum: 1, maximum: 5 },
          pros: { type: 'array', items: { type: 'string' } },
          cons: { type: 'array', items: { type: 'string' } },
          summary: { type: 'string' }
        },
        required: ['product', 'rating', 'summary']
      }
    }
  });
  
  console.log('المراجعة المنظمة:', response.output);
}

// تشغيل الأمثلة
generateText();
generateStructuredData();
```

### مثال Go

```go
// main.go
package main

import (
    "context"
    "fmt"
    "log"

    "github.com/firebase/genkit/go/genkit"
    "github.com/firebase/genkit/go/plugins/googleai"
)

func main() {
    ctx := context.Background()
    
    // تهيئة Genkit مع Google AI
    if err := genkit.Init(ctx, &genkit.Options{
        Plugins: []genkit.Plugin{googleai.Plugin()},
    }); err != nil {
        log.Fatal(err)
    }

    // توليد النص
    model := googleai.Model("gemini-2.0-flash-exp")
    
    resp, err := model.Generate(ctx, &genkit.GenerateRequest{
        Messages: []*genkit.Message{
            {
                Content: []*genkit.Part{
                    genkit.NewTextPart("ما هي فوائد الحوسبة السحابية؟"),
                },
                Role: genkit.RoleUser,
            },
        },
    })
    
    if err != nil {
        log.Fatal(err)
    }
    
    fmt.Printf("الاستجابة: %s\n", resp.Candidates[0].Message.Content[0].Text)
}
```

### مثال Python (ألفا)

```python
# main.py
import asyncio
from genkit import ai
from genkit.providers.google import google_genai

# تكوين مقدم Google AI
google_genai.configure(api_key="your-api-key")

async def generate_text():
    # توليد النص الأساسي
    response = await ai.generate(
        model=google_genai.models.gemini_2_0_flash_exp,
        prompt="اشرح التعلم الآلي للمبتدئين"
    )
    
    print(f"النص المولد: {response.text}")

async def main():
    await generate_text()

if __name__ == "__main__":
    asyncio.run(main())
```

## الميزات المتقدمة

### استدعاء الأدوات وتكامل الوظائف

يدعم Genkit وكلاء الذكاء الاصطناعي التي يمكنها استدعاء الأدوات والوظائف الخارجية:

```typescript
import { defineTool } from 'genkit';

// تعريف أداة الطقس
const weatherTool = defineTool({
  name: 'getWeather',
  description: 'الحصول على الطقس الحالي لموقع محدد',
  inputSchema: {
    type: 'object',
    properties: {
      location: { type: 'string', description: 'اسم المدينة' }
    },
    required: ['location']
  },
  outputSchema: {
    type: 'object',
    properties: {
      temperature: { type: 'number' },
      condition: { type: 'string' },
      humidity: { type: 'number' }
    }
  }
}, async (input) => {
  // محاكاة استدعاء API الطقس
  return {
    temperature: 22,
    condition: 'مشمس',
    humidity: 65
  };
});

// استخدام الأداة في محادثة الذكاء الاصطناعي
async function weatherAssistant() {
  const response = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: 'كيف هو الطقس في الرياض؟',
    tools: [weatherTool]
  });
  
  console.log(response.text);
}
```

### الذكاء الاصطناعي متعدد الوسائط (نص + صور)

معالجة النصوص والصور في تطبيقات الذكاء الاصطناعي:

```typescript
import { readFileSync } from 'fs';

async function analyzeImage() {
  const imageData = readFileSync('path/to/image.jpg');
  
  const response = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: [
      { text: 'صف ما تراه في هذه الصورة' },
      { 
        media: {
          contentType: 'image/jpeg',
          data: imageData
        }
      }
    ]
  });
  
  console.log('تحليل الصورة:', response.text);
}
```

### RAG (الجيل المعزز بالاسترجاع)

تنفيذ ذكاء اصطناعي واعي بالسياق مع المعرفة الخارجية:

```typescript
import { defineRetriever } from 'genkit';

// تعريف مسترجع الوثائق
const documentRetriever = defineRetriever({
  name: 'companyDocs',
  configSchema: {
    type: 'object',
    properties: {
      query: { type: 'string' }
    }
  }
}, async (input) => {
  // محاكاة البحث في الوثائق
  return [
    {
      content: 'محتوى وثيقة سياسة الشركة...',
      metadata: { source: 'employee-handbook.pdf', page: 1 }
    }
  ];
});

// أسئلة وأجوبة مدعومة بـ RAG
async function answerQuestion(question: string) {
  const response = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: `أجب على هذا السؤال بناءً على السياق المقدم: ${question}`,
    config: {
      retriever: documentRetriever,
      retrieverConfig: { query: question }
    }
  });
  
  return response.text;
}
```

## سير عمل التطوير

### استخدام Genkit CLI

يوفر Genkit CLI أدوات تطوير قوية:

```bash
# بدء خادم التطوير مع واجهة المستخدم
genkit start -- npm run dev

# تشغيل تدفق محدد
genkit flow:run myFlow --input '{"query": "test"}'

# تقييم التدفقات
genkit eval:run --flow myFlow --dataset test-data.json

# إنتاج التتبعات
genkit trace:list
```

### ميزات واجهة المطور

توفر واجهة Genkit المحلية:

1. **ملعب التدفق**: اختبار تدفقات الذكاء الاصطناعي بمدخلات مختلفة
2. **مقارنة النماذج**: مقارنة مخرجات النماذج المختلفة
3. **مفتش التتبع**: تصحيح التنفيذ بتتبعات مفصلة
4. **لوحة التقييم**: مراجعة مقاييس الأداء
5. **هندسة المطالبات**: تكرار المطالبات بصرياً

الوصول إلى واجهة المستخدم على `http://localhost:4000` عند تشغيل `genkit start`.

## النشر الإنتاجي

### نشر Firebase Functions

```typescript
// functions/src/index.ts
import { onFlow } from '@genkit-ai/firebase/functions';
import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';

const ai = genkit({
  plugins: [googleAI()]
});

export const chatFlow = onFlow(ai, {
  name: 'chatFlow',
  inputSchema: {
    type: 'object',
    properties: {
      message: { type: 'string' }
    }
  },
  outputSchema: {
    type: 'object',
    properties: {
      response: { type: 'string' }
    }
  }
}, async (input) => {
  const {% raw %}{ text }{% endraw %} = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: input.message
  });
  
  return { response: text };
});
```

النشر إلى Firebase:

```bash
# تهيئة مشروع Firebase
firebase init functions

# نشر الوظائف
firebase deploy --only functions
```

### نشر Google Cloud Run

```dockerfile
# Dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY . .
RUN npm run build

EXPOSE 8080
CMD ["npm", "start"]
```

النشر إلى Cloud Run:

```bash
# بناء ودفع الحاوية
gcloud builds submit --tag gcr.io/PROJECT_ID/genkit-app

# النشر إلى Cloud Run
gcloud run deploy genkit-app \
  --image gcr.io/PROJECT_ID/genkit-app \
  --platform managed \
  --region us-central1 \
  --allow-unauthenticated
```

## المراقبة والملاحظة

### إعداد المراقبة

تكوين المراقبة لعمليات النشر الإنتاجية:

```typescript
import { genkit } from 'genkit';
import { googleCloudTrace } from '@genkit-ai/google-cloud';

const ai = genkit({
  plugins: [
    googleAI(),
    googleCloudTrace({
      projectId: 'your-project-id'
    })
  ],
  telemetry: {
    instrumentation: 'googleCloud',
    logger: 'googleCloud'
  }
});
```

### لوحة المراقبة

توفر وحدة تحكم Firebase:

- **حجم الطلبات**: تتبع تكرار استدعاءات API
- **مقاييس زمن الاستجابة**: مراقبة أوقات الاستجابة
- **معدلات الخطأ**: تحديد وتصحيح الأخطاء
- **تحليل التكلفة**: مراقبة استخدام الرموز والتكاليف
- **أداء النموذج**: مقارنة فعالية النماذج

## أفضل الممارسات

### 1. معالجة الأخطاء

```typescript
import { GenkitError } from 'genkit';

async function robustGeneration(prompt: string) {
  try {
    const response = await ai.generate({
      model: googleAI.model('gemini-2.0-flash-exp'),
      prompt,
      config: {
        maxRetries: 3,
        timeout: 30000
      }
    });
    
    return response.text;
  } catch (error) {
    if (error instanceof GenkitError) {
      console.error('خطأ Genkit:', error.message);
      // معالجة أنواع أخطاء محددة
      switch (error.code) {
        case 'RATE_LIMIT_EXCEEDED':
          // تنفيذ استراتيجية التراجع
          break;
        case 'INVALID_REQUEST':
          // معالجة الإدخال غير صالح
          break;
      }
    }
    throw error;
  }
}
```

### 2. التحقق من الإدخال

```typescript
import Joi from 'joi';

const inputSchema = Joi.object({
  query: Joi.string().min(1).max(1000).required(),
  language: Joi.string().valid('en', 'ko', 'ar').default('ar')
});

async function validateAndProcess(input: any) {
  const {% raw %}{ error, value }{% endraw %} = inputSchema.validate(input);
  
  if (error) {
    throw new Error(`إدخال غير صالح: ${error.message}`);
  }
  
  return value;
}
```

### 3. هندسة المطالبات

```typescript
const SYSTEM_PROMPT = `
أنت مساعد ذكي مختص في الوثائق التقنية.
قدم دائماً إجابات دقيقة ومنظمة جيداً مع أمثلة عند الاقتضاء.
إذا لم تكن متأكداً من شيء، اذكر عدم يقينك بوضوح.
`;

async function generateDocumentation(topic: string) {
  const response = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: `${SYSTEM_PROMPT}\n\nالموضوع: ${topic}\n\nقدم وثائق شاملة:`,
    config: {
      temperature: 0.3, // درجة حرارة منخفضة للمحتوى التقني
      maxOutputTokens: 2000
    }
  });
  
  return response.text;
}
```

### 4. تحسين التكلفة

```typescript
// استخدام النماذج المناسبة لمهام مختلفة
const MODEL_CONFIG = {
  simple: googleAI.model('gemini-2.0-flash-exp'), // سريع وفعال من حيث التكلفة
  complex: googleAI.model('gemini-2.0-pro'), // أكثر قدرة، تكلفة أعلى
  multimodal: googleAI.model('gemini-2.0-pro-vision') // صورة + نص
};

function selectModel(taskComplexity: 'simple' | 'complex' | 'multimodal') {
  return MODEL_CONFIG[taskComplexity];
}
```

## استكشاف الأخطاء وإصلاحها

### مشاكل المصادقة

```bash
# تعيين بيانات اعتماد Google Cloud
export GOOGLE_APPLICATION_CREDENTIALS="path/to/service-account-key.json"

# أو استخدام gcloud CLI
gcloud auth application-default login
```

### مشاكل الوصول للنماذج

```typescript
// فحص توفر النماذج
const availableModels = await googleAI.listModels();
console.log('النماذج المتاحة:', availableModels);

// معالجة أخطاء خاصة بالنماذج
try {
  const response = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt: 'test'
  });
} catch (error) {
  if (error.message.includes('model not found')) {
    console.log('جرب استخدام gemini-1.5-pro بدلاً من ذلك');
  }
}
```

### تحسين الأداء

```typescript
// تنفيذ تخزين الطلبات مؤقتاً
const cache = new Map();

async function cachedGeneration(prompt: string) {
  const cacheKey = `generation:${prompt}`;
  
  if (cache.has(cacheKey)) {
    return cache.get(cacheKey);
  }
  
  const result = await ai.generate({
    model: googleAI.model('gemini-2.0-flash-exp'),
    prompt
  });
  
  cache.set(cacheKey, result.text);
  return result.text;
}
```

## استراتيجيات الاختبار

### اختبار الوحدة

```typescript
import { describe, it, expect, beforeEach } from 'vitest';

describe('وظائف الذكاء الاصطناعي', () => {
  beforeEach(() => {
    // إعداد بيئة الاختبار
  });
  
  it('يجب أن ينتج استجابات صالحة', async () => {
    const response = await generateText('مطالبة اختبار');
    
    expect(response).toBeDefined();
    expect(typeof response).toBe('string');
    expect(response.length).toBeGreaterThan(0);
  });
  
  it('يجب أن يعالج الإخراج المنظم', async () => {
    const result = await generateStructuredData();
    
    expect(result).toHaveProperty('product');
    expect(result.rating).toBeGreaterThanOrEqual(1);
    expect(result.rating).toBeLessThanOrEqual(5);
  });
});
```

### اختبار التكامل

```typescript
// test/integration.test.ts
import { genkit } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';

const testAI = genkit({
  plugins: [googleAI()],
  environment: 'test'
});

describe('اختبارات التكامل', () => {
  it('يجب التكامل مع Google AI بنجاح', async () => {
    const response = await testAI.generate({
      model: googleAI.model('gemini-2.0-flash-exp'),
      prompt: 'قل مرحبا'
    });
    
    expect(response.text).toContain('مرحبا');
  });
});
```

## اعتبارات الأمان

### إدارة مفاتيح API

```typescript
// استخدام متغيرات البيئة لمفاتيح API
const config = {
  googleAI: {
    apiKey: process.env.GOOGLE_AI_API_KEY || '',
    projectId: process.env.GOOGLE_CLOUD_PROJECT || ''
  }
};

// التحقق من التكوين
if (!config.googleAI.apiKey) {
  throw new Error('متغير البيئة GOOGLE_AI_API_KEY مطلوب');
}
```

### تطهير الإدخال

```typescript
import DOMPurify from 'isomorphic-dompurify';

function sanitizeInput(input: string): string {
  // إزالة المحتوى الضار المحتمل
  const cleaned = DOMPurify.sanitize(input);
  
  // التحقق الإضافي
  if (cleaned.length > 10000) {
    throw new Error('الإدخال طويل جداً');
  }
  
  return cleaned;
}
```

### تحديد المعدل

```typescript
import rateLimit from 'express-rate-limit';

const aiRateLimit = rateLimit({
  windowMs: 15 * 60 * 1000, // 15 دقيقة
  max: 100, // تحديد كل IP بـ 100 طلب لكل windowMs
  message: 'طلبات ذكاء اصطناعي كثيرة جداً من هذا IP'
});

// تطبيق على نقاط نهاية الذكاء الاصطناعي
app.use('/api/ai', aiRateLimit);
```

## الخلاصة

يوفر Firebase Genkit إطار عمل قوي وجاهز للإنتاج لبناء تطبيقات الذكاء الاصطناعي. واجهته الموحدة ودعمه متعدد اللغات وأدواته الشاملة تجعله خياراً ممتازاً للمطورين الذين يتطلعون لدمج قدرات الذكاء الاصطناعي في تطبيقاتهم.

النقاط الرئيسية:

1. **ابدأ ببساطة**: ابدأ بتوليد النص الأساسي وأضف الميزات المعقدة تدريجياً
2. **استخدم الأدوات**: استفد من CLI وواجهة المطور للتطوير الفعال
3. **خطط للإنتاج**: نفذ المراقبة ومعالجة الأخطاء والأمان المناسب
4. **حسّن التكاليف**: اختر النماذج المناسبة ونفذ استراتيجيات التخزين المؤقت
5. **اختبر بدقة**: استخدم استراتيجيات اختبار شاملة لتطبيقات ذكاء اصطناعي موثوقة

مع Firebase Genkit، يمكنك بناء تطبيقات ذكاء اصطناعي متقدمة تتوسع من النموذج الأولي إلى الإنتاج بثقة.

## الخطوات التالية

- استكشف [وثائق Genkit الرسمية](https://genkit.dev/)
- جرب [عينات Genkit](https://github.com/firebase/genkit/tree/main/samples)
- انضم إلى [مجتمع Genkit Discord](https://discord.gg/genkit)
- جرب مقدمي النماذج والقدرات المختلفة
- ابن تطبيق الذكاء الاصطناعي الخاص بك باستخدام المفاهيم المغطاة في هذا الدليل

## موارد إضافية

- [مستودع Genkit GitHub](https://github.com/firebase/genkit)
- [وحدة تحكم Firebase](https://console.firebase.google.com/)
- [Google AI Studio](https://aistudio.google.com/)
- [وثائق Vertex AI](https://cloud.google.com/vertex-ai/docs)
- [نظام إضافات Genkit البيئي](https://genkit.dev/docs/plugins)
