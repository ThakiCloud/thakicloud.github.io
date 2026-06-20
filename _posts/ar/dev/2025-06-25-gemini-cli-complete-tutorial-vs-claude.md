---
layout: single
title: "الدليل الشامل لـ Gemini CLI: وكيل الذكاء الاصطناعي من الجيل القادم في الطرفية"
excerpt: "استكشاف شامل لميزات Gemini CLI الثورية ومقارنته بـ Claude وقدراته متعددة الوسائط وتكامل الأدوات"
date: 2025-06-25
categories: [dev, tutorials]
tags: [gemini-cli, google-gemini, ai-agent, multimodal-ai, tool-calling, mcp-servers, claude-comparison]
lang: ar
canonical_url: "https://thakicloud.github.io/ar/dev/gemini-cli-complete-tutorial-vs-claude/"
toc: true
toc_sticky: true
toc_label: "الدليل الشامل لـ Gemini CLI"
---

## نظرة عامة: ثورة في تجربة الطرفية

أطلقت Google في يونيو 2025 **Gemini CLI** بشكل مفتوح المصدر، مما أحدث تحولًا جوهريًا في مشهد وكلاء الذكاء الاصطناعي في بيئة الطرفية. يمتلك Gemini CLI ميزات تجعله منافسًا قويًا لـ Claude Code، أبرزها نافذة سياق تتجاوز **مليون رمز (token)**، وقدرات متعددة الوسائط مدمجة، وتكامل مع خوادم MCP.

في هذا الدليل سنستعرض جميع ميزات Gemini CLI بعمق ونقارنه بـ Claude، لمساعدتك على اختيار الأنسب لسير عملك.

---

## الميزات الرئيسية لـ Gemini CLI

### 1. نافذة سياق بالمليون رمز

```
النموذج المستخدم: gemini-2.5-pro
حجم نافذة السياق: 1,048,576 رمز (1M+)
ما يعادله: ~750,000 كلمة أو قاعدة شيفرة كاملة متوسطة الحجم
```

هذا يعني إمكانية تحليل مشاريع كاملة دون الحاجة إلى تقسيمها.

### 2. القدرات متعددة الوسائط

يدعم Gemini CLI بشكل أصيل:
- تحليل الصور وتوليدها (Imagen 3)
- توليد الفيديو (Veo 3)
- توليد الصوت والموسيقى (Lyria)
- قراءة ملفات PDF وتحليلها
- معالجة الفيديو مباشرة

### 3. تكامل خوادم MCP

يدعم Gemini CLI بروتوكول MCP (Model Context Protocol) بالكامل، مما يُتيح التوسع اللامحدود باستخدام أدوات مخصصة.

### 4. توليد الوسائط الإبداعية

على عكس معظم وكلاء الطرفية، يمكن لـ Gemini CLI توليد المحتوى المرئي والصوتي مباشرة.

### 5. أتمتة النظام

يمتلك صلاحيات واسعة للتفاعل مع نظام التشغيل، مما يجعله مناسبًا لأتمتة المهام المعقدة.

---

## التثبيت والإعداد

### المتطلبات الأساسية

```bash
# Node.js 18 أو أحدث (مطلوب)
node --version  # يجب أن يكون 18.0.0 أو أعلى

# التحقق من npm
npm --version
```

### التثبيت عبر npm

```bash
# التثبيت العالمي
npm install -g @google/gemini-cli

# أو الاستخدام مباشرة بدون تثبيت
npx @google/gemini-cli
```

### التثبيت عبر npx (مستحسن للتجربة)

```bash
# التشغيل المباشر
npx @google/gemini-cli

# مع تحديد النموذج
npx @google/gemini-cli --model gemini-2.5-pro
```

### خيارات المصادقة

**الخيار الأول: حساب Google الشخصي (مجاني)**

```bash
# عند أول تشغيل، سيفتح متصفح المصادقة
gemini
# اتبع التعليمات لتسجيل الدخول بحساب Google
```

**الخيار الثاني: مفتاح API**

```bash
# إعداد متغير البيئة
export GEMINI_API_KEY="your_api_key_here"

# أو في الملف .env
echo 'GEMINI_API_KEY=your_api_key_here' >> ~/.env
```

**الخيار الثالث: مصادقة المشروع (للمؤسسات)**

```bash
# مصادقة Google Cloud
gcloud auth application-default login

# إعداد المشروع
export GOOGLE_CLOUD_PROJECT="your-project-id"
gemini --project your-project-id
```

---

## الاستخدام الأساسي

### الوضع التفاعلي

```bash
# تشغيل الوضع التفاعلي
gemini

# أوامر داخل الوضع التفاعلي
> مرحبًا! ساعدني في فهم هذا الكود
> /help          # عرض المساعدة
> /clear         # مسح السياق
> /quit          # الخروج
```

### الوضع المباشر (One-shot)

```bash
# سؤال واحد مباشر
gemini -p "ما هي أفضل ممارسات TypeScript لعام 2025؟"

# مع تحديد النموذج
gemini -p "حلل هذا الكود" --model gemini-2.5-flash

# قراءة من ملف
cat code.py | gemini -p "راجع هذا الكود Python"
```

### الوضع الأنبوبي (Pipeline)

```bash
# تكامل مع أدوات Unix
git diff | gemini -p "اكتب رسالة commit مناسبة"

# تحليل ملفات السجل
cat error.log | gemini -p "حلل هذه الأخطاء وحدد الأسباب الجذرية"

# فحص أمان الشيفرة
grep -r "password\|secret\|key" ./src | gemini -p "هل هناك مشاكل أمنية؟"
```

---

## السيناريوهات العملية

### السيناريو الأول: استكشاف قاعدة الشيفرة

```bash
# تحليل مشروع كامل
gemini -p "حلل هيكل هذا المشروع وأعطِني نظرة عامة شاملة" \
  --all_files \
  --model gemini-2.5-pro

# فهم منطق تجاري معقد
gemini << 'EOF'
بناءً على ملفات المشروع التالية:
- src/auth/
- src/billing/
- src/notifications/

اشرح تدفق البيانات من تسجيل المستخدم حتى أول فاتورة.
EOF
```

### السيناريو الثاني: تطوير الشيفرة

```bash
# توليد مكون React
gemini -p "
أنشئ مكون React TypeScript لعرض قائمة المستخدمين مع:
- تصفية حسب الاسم والبريد
- ترقيم الصفحات (pagination)
- تحميل كسول (lazy loading)
- رسائل خطأ مناسبة
"

# إعادة هيكلة الشيفرة
cat legacy_code.js | gemini -p "
أعِد هيكلة هذا الكود JavaScript إلى TypeScript مع:
- إضافة أنواع صارمة
- تحويل الـ callbacks إلى async/await
- إضافة معالجة الأخطاء المناسبة
"
```

### السيناريو الثالث: تحليل متعدد الوسائط

```bash
# تحليل صورة معمارية
gemini -p "حلل هذا المخطط المعماري وحدد نقاط الضعف" \
  --image architecture-diagram.png

# استخراج معلومات من PDF
gemini -p "استخرج جميع نقاط نهاية API المذكورة في هذه الوثيقة" \
  --file api-documentation.pdf

# تحليل لقطة شاشة
gemini -p "ما هي مشكلة واجهة المستخدم في هذه الصورة؟" \
  --image ui-bug-screenshot.png
```

### السيناريو الرابع: أتمتة العمليات

```bash
# فحص الأمان الشامل
gemini -p "
افحص هذا المستودع وأعطِني:
1. قائمة الثغرات الأمنية المحتملة
2. ملفات الإعداد المكشوفة
3. اعتماديات قديمة أو غير آمنة
4. خطوات علاج مرتبة حسب الأولوية
"

# توثيق API تلقائي
find ./src -name "*.ts" | xargs gemini -p "
أنشئ وثيقة API شاملة بتنسيق OpenAPI 3.0 
لجميع نقاط النهاية الموجودة في هذه الملفات
"
```

---

## تكامل خوادم MCP

### إعداد خادم MCP مخصص

```typescript
// custom-mcp-server.ts
// خادم MCP مخصص لـ Gemini CLI

import { Server } from "@modelcontextprotocol/sdk/server/index.js";
import { StdioServerTransport } from "@modelcontextprotocol/sdk/server/stdio.js";
import {
  CallToolRequestSchema,
  ListToolsRequestSchema,
} from "@modelcontextprotocol/sdk/types.js";

const server = new Server(
  {
    name: "custom-tools",
    version: "1.0.0",
  },
  {
    capabilities: {
      tools: {},
    },
  }
);

// تعريف الأدوات المتاحة
server.setRequestHandler(ListToolsRequestSchema, async () => {
  return {
    tools: [
      {
        name: "analyze_database",
        description: "تحليل هيكل قاعدة البيانات وأداؤها",
        inputSchema: {
          type: "object",
          properties: {
            connection_string: {
              type: "string",
              description: "سلسلة الاتصال بقاعدة البيانات",
            },
            analysis_type: {
              type: "string",
              enum: ["schema", "performance", "security"],
              description: "نوع التحليل المطلوب",
            },
          },
          required: ["connection_string"],
        },
      },
      {
        name: "deploy_to_cloud",
        description: "نشر التطبيق على السحابة",
        inputSchema: {
          type: "object",
          properties: {
            environment: {
              type: "string",
              enum: ["staging", "production"],
            },
            version: {
              type: "string",
              description: "رقم الإصدار",
            },
          },
          required: ["environment", "version"],
        },
      },
    ],
  };
});

// معالجة طلبات استدعاء الأدوات
server.setRequestHandler(CallToolRequestSchema, async (request) => {
  const { name, arguments: args } = request.params;

  if (name === "analyze_database") {
    // تنفيذ تحليل قاعدة البيانات
    const result = await analyzeDatabase(
      args.connection_string,
      args.analysis_type || "schema"
    );
    return { content: [{ type: "text", text: JSON.stringify(result) }] };
  }

  if (name === "deploy_to_cloud") {
    // تنفيذ النشر
    const result = await deployToCloud(args.environment, args.version);
    return { content: [{ type: "text", text: result }] };
  }

  throw new Error(`أداة غير معروفة: ${name}`);
});

// تشغيل الخادم
const transport = new StdioServerTransport();
await server.connect(transport);
```

### ربط خادم MCP بـ Gemini CLI

```json
// ~/.gemini/settings.json - إعداد خوادم MCP
{
  "mcpServers": {
    "custom-tools": {
      "command": "node",
      "args": ["/path/to/custom-mcp-server.js"],
      "env": {
        "DATABASE_URL": "${DATABASE_URL}"
      }
    },
    "filesystem": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/workspace"]
    },
    "github": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-github"],
      "env": {
        "GITHUB_TOKEN": "${GITHUB_TOKEN}"
      }
    }
  }
}
```

---

## توليد الوسائط الإبداعية

### توليد الصور (Imagen 3)

```bash
# توليد صورة لواجهة مستخدم
gemini -p "
أنشئ صورة لتصميم واجهة مستخدم عصرية لتطبيق إدارة المهام:
- لوح معلومات بتصميم بطاقات
- وضع داكن (dark mode)
- عناصر مادية (material design)
- ألوان: أزرق، أبيض، رمادي
" --generate-image

# توليد شعار
gemini -p "صمم شعارًا بسيطًا لشركة تقنية ناشئة" \
  --generate-image \
  --image-style "minimalist, professional"
```

### توليد الفيديو (Veo 3)

```bash
# إنشاء فيديو توضيحي
gemini -p "
أنشئ مقطع فيديو قصير (10 ثوانٍ) يوضح:
- رحلة المستخدم من التسجيل حتى أول استخدام
- للتطبيق يستهدف المطورين
- أسلوب احترافي وتقني
" --generate-video
```

### توليد الموسيقى (Lyria)

```bash
# إنشاء موسيقى خلفية
gemini -p "
أنشئ مقطعًا موسيقيًا (30 ثانية) لعرض تقديمي تقني:
- إيقاع هادئ ومحفز
- بدون كلمات
- مناسب للعروض التجارية
" --generate-audio
```

---

## العمل المتقدم مع الشيفرة

### تحليل قاعدة شيفرة كاملة

```bash
# تحليل عميق للمشروع
gemini << 'EOF'
لديّ مشروع Next.js 14 في المجلد الحالي.

المهام المطلوبة:
1. تحليل أداء Bundle Size وتحديد أسباب الحجم الكبير
2. تحديد الشيفرة غير المستخدمة (dead code)
3. اقتراح تحسينات للـ Server Components
4. مراجعة استخدام React hooks وتحديد re-renders غير ضرورية
5. تقرير شامل بالأولويات

ابدأ بالملفات الأكثر أهمية: package.json, tsconfig.json, next.config.js
EOF

# تحسين الأداء تلقائيًا
find . -name "*.tsx" -newer "package.json" | \
  gemini -p "راجع هذه الملفات وحسّن الأداء مع الحفاظ على الوظائف"
```

---

## مقارنة Gemini CLI مقابل Claude

| الميزة | Gemini CLI | Claude Code |
|--------|------------|-------------|
| حجم نافذة السياق | 1M+ رمز | 200K رمز |
| توليد الصور | نعم (Imagen 3) | لا |
| توليد الفيديو | نعم (Veo 3) | لا |
| توليد الصوت | نعم (Lyria) | لا |
| تكامل MCP | نعم | نعم |
| دعم المشاريع الضخمة | ممتاز | جيد جدًا |
| جودة الشيفرة | ممتازة | ممتازة |
| فهم السياق | ممتاز | ممتاز |
| دعم اللغة العربية | جيد | ممتاز |
| التسعير المجاني | سخي (حساب Google) | محدود |
| مفتوح المصدر | نعم | لا |
| نضج النظام البيئي | في نمو | ناضج |

---

## سير العمل الهجين (Gemini + Claude)

### التوصية: استخدام كل أداة لما تتقنه

```bash
# المرحلة 1: استكشاف المشروع (Gemini لنافذة السياق الكبيرة)
gemini -p "حلل المشروع بالكامل وأعطِني خريطة شاملة" --all_files > project_map.md

# المرحلة 2: التطوير التفاعلي (Claude لدقة الشيفرة)
# استخدم Claude Code للتطوير التفاعلي

# المرحلة 3: توليد الوسائط (Gemini للمحتوى المرئي)
gemini -p "أنشئ صورًا توضيحية للتوثيق" --generate-image
```

### سكريبت الأتمتة الهجينة

```python
# hybrid_workflow.py
# سير عمل هجين بين Gemini و Claude

import subprocess
import json

def analyze_with_gemini(project_path: str) -> dict:
    """تحليل شامل بـ Gemini (نافذة سياق كبيرة)"""
    result = subprocess.run(
        ["gemini", "-p", 
         f"حلل المشروع في {project_path} وأعطِني خريطة معمارية شاملة",
         "--output", "json"],
        capture_output=True,
        text=True
    )
    return json.loads(result.stdout)

def develop_with_claude(spec: dict) -> str:
    """تطوير دقيق بـ Claude"""
    # استدعاء Claude API بالمواصفات من Gemini
    pass

def generate_assets_with_gemini(descriptions: list) -> list:
    """توليد الوسائط بـ Gemini"""
    assets = []
    for desc in descriptions:
        result = subprocess.run(
            ["gemini", "-p", desc, "--generate-image"],
            capture_output=True
        )
        assets.append(result.stdout)
    return assets

# التنفيذ
project_analysis = analyze_with_gemini("./src")
print("تحليل المشروع:", project_analysis)
```

---

## تحسين الأداء

### نصائح لتعظيم الكفاءة

```bash
# استخدام نموذج Flash للمهام البسيطة (أسرع وأرخص)
gemini -p "أكمل هذا الكود" --model gemini-2.5-flash

# استخدام نموذج Pro للمهام المعقدة
gemini -p "صمم نظام microservices" --model gemini-2.5-pro

# تخزين السياق مؤقتًا لتوفير الرموز
gemini -p "حلل المشروع" --cache-context --context-id "my-project"

# استخدام السياق المخزن لاحقًا
gemini -p "بناءً على تحليلك السابق، نفّذ ميزة X" --context-id "my-project"
```

---

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة وحلولها

**مشكلة: تجاوز حد الرموز**

```bash
# الخطأ
Error: Context length exceeded: 1,048,576 tokens

# الحل: تقسيم المدخلات
find ./src -name "*.ts" | head -50 | gemini -p "حلل هذا المجموعة الأولى"
find ./src -name "*.ts" | tail -50 | gemini -p "حلل هذه المجموعة الثانية"
```

**مشكلة: فشل المصادقة**

```bash
# إعادة تهيئة المصادقة
gemini auth logout
gemini auth login

# أو استخدام مفتاح API
export GEMINI_API_KEY="new_key_here"
gemini -p "اختبار" # للتحقق من المصادقة
```

**مشكلة: بطء الاستجابة**

```bash
# استخدام نموذج أسرع
gemini -p "سؤالك" --model gemini-2.5-flash

# تقليل كمية المدخلات
# بدلًا من تمرير الملفات كاملة، اختصر المحتوى المهم
cat important_parts.txt | gemini -p "حلل هذا"
```

---

## اعتبارات الأمان

### أفضل ممارسات الأمان

```bash
# لا تمرر أبدًا بيانات اعتماد مباشرة
# خطأ
gemini -p "الكود يستخدم API_KEY=sk-abc123def..."

# صحيح
gemini -p "الكود يستخدم متغير بيئة API_KEY، ساعدني في تحسين المصادقة"

# استخدام وضع الخصوصية للشيفرة الحساسة
gemini -p "..." --no-logs --privacy-mode

# تحديد نطاق الوصول للملفات
gemini -p "..." --allowed-paths "./src,./docs"
```

### مراجعة الأذونات

```bash
# فحص الأذونات الممنوحة
gemini permissions list

# سحب صلاحية النظام
gemini permissions revoke --system-access

# الاستخدام في وضع القراءة فقط
gemini -p "راجع الشيفرة" --read-only
```

---

## الخلاصة

يُمثل Gemini CLI قفزة نوعية في عالم وكلاء الطرفية بفضل:

1. **نافذة السياق الضخمة**: المليون رمز تفتح آفاقًا جديدة لتحليل المشاريع الكبيرة
2. **القدرات متعددة الوسائط**: توليد الصور والفيديو والصوت مباشرة من الطرفية
3. **المصدر المفتوح**: مجتمع نشط وتطوير مستمر
4. **التكامل مع النظام البيئي لـ Google**: MCP وCloud وأدوات التطوير

أما التوصية العملية، فهي استخدام **سير العمل الهجين**: Gemini لاستكشاف المشاريع الكبيرة وتوليد الوسائط، وClaude للتطوير التفاعلي الدقيق. الأداتان متكاملتان لا متنافستان.
