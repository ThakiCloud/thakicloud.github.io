---
title: "Deep Chat: بناء مكون روبوت دردشة ذكاء اصطناعي قابل للتخصيص بالكامل - دليل شامل"
excerpt: "تعلم كيفية دمج Deep Chat، مكون روبوت دردشة ذكاء اصطناعي قوي، في موقعك الإلكتروني بسطر واحد فقط من التعليمات البرمجية. برنامج تعليمي خطوة بخطوة يغطي التثبيت ودمج OpenAI والميزات المتقدمة مثل التعرف على الكلام ودعم الكاميرا."
seo_title: "دليل Deep Chat لروبوت الدردشة بالذكاء الاصطناعي: دليل التكامل الكامل - Thaki Cloud"
seo_description: "دليل شامل لـ Deep Chat - دمج روبوتات الدردشة بالذكاء الاصطناعي مع OpenAI وHuggingFace وواجهات برمجة التطبيقات المخصصة. يتضمن أمثلة React وVue وAngular وميزات تحويل الكلام إلى نص."
date: 2025-10-02
lang: ar
permalink: /ar/tutorials/deep-chat-ai-chatbot-complete-guide/
canonical_url: "https://thakicloud.github.io/ar/tutorials/deep-chat-ai-chatbot-complete-guide/"
categories:
  - tutorials
tags:
  - deep-chat
  - روبوت-دردشة-ذكاء-اصطناعي
  - openai
  - react
  - vue
  - angular
  - التعرف-على-الكلام
  - مكونات-الويب
author_profile: true
toc: true
toc_label: "جدول المحتويات"
---

⏱️ **وقت القراءة المقدر**: 15 دقيقة

## المقدمة

Deep Chat هو مكون ويب ثوري يتيح لك إضافة روبوت دردشة ذكاء اصطناعي قابل للتخصيص بالكامل إلى موقعك الإلكتروني **بسطر واحد فقط من التعليمات البرمجية**. سواء كنت تبني نظام دعم العملاء أو مساعد ذكاء اصطناعي أو واجهة محادثة، يوفر Deep Chat كل ما تحتاجه فوراً.

### ما الذي يجعل Deep Chat مميزاً؟

- **مستقل عن إطار العمل**: يعمل مع React وVue وAngular وSvelte وجافا سكريبت النقي
- **اتصالات API مباشرة**: اتصل بـ OpenAI وHuggingFace وCohere وغيرها
- **دعم وسائط غنية**: معالجة النصوص والصور والملفات والصوت والفيديو
- **تكامل الكلام**: تحويل الكلام إلى نص وتحويل النص إلى كلام مدمج
- **قابل للتخصيص بالكامل**: يمكن تصميم وتكوين كل جانب
- **LLM المستند إلى المتصفح**: تشغيل نماذج الذكاء الاصطناعي بالكامل في المتصفح مع Web LLM

## الجزء الأول: التثبيت والإعداد الأساسي

### المتطلبات الأساسية

قبل أن نبدأ، تأكد من توفر:
- Node.js 14+ مثبت
- مدير حزم (npm أو yarn أو pnpm)
- معرفة أساسية بـ HTML وجافا سكريبت

### التثبيت

لمشاريع **جافا سكريبت النقي أو TypeScript**:

```bash
npm install deep-chat
```

لمشاريع **React**:

```bash
npm install deep-chat-react
```

### التنفيذ الأساسي

#### جافا سكريبت النقي/HTML

إنشاء ملف HTML بسيط:

```html
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>عرض توضيحي لـ Deep Chat</title>
    <script type="module">
        import 'deep-chat';
    </script>
</head>
<body>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px;"
        introMessage='{"text": "مرحباً! كيف يمكنني مساعدتك اليوم؟"}'
    ></deep-chat>
</body>
</html>
```

#### تنفيذ React

```jsx
import { DeepChat } from 'deep-chat-react';

function App() {
    return (
        <div className="App">
            <DeepChat
                style={{borderRadius: '10px', width: '100%', height: '600px'}}
                introMessage={% raw %}{{text: "مرحباً! كيف يمكنني مساعدتك اليوم؟"}}{% endraw %}}
            />
        </div>
    );
}

export default App;
```

#### تنفيذ Vue 3

```vue
<template>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px"
        :introMessage="introMessage"
    />
</template>

<script setup>
import 'deep-chat';

const introMessage = { text: "مرحباً! كيف يمكنني مساعدتك اليوم؟" };
</script>
```

## الجزء الثاني: الاتصال بـ OpenAI

واحدة من أقوى ميزات Deep Chat هي القدرة على الاتصال مباشرة بخدمات الذكاء الاصطناعي مثل OpenAI.

### الاتصال المباشر (للتطوير فقط)

**⚠️ تحذير**: هذه الطريقة تكشف مفتاح API الخاص بك في المتصفح. استخدمها فقط للتطوير المحلي/العروض التوضيحية.

```html
<deep-chat
    directConnection='{
        "openAI": {
            "key": "your-api-key-here",
            "chat": {
                "model": "gpt-4",
                "max_tokens": 1000,
                "temperature": 0.7
            }
        }
    }'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### جاهز للإنتاج: خادم بروكسي

لبيئات الإنتاج، أنشئ بروكسي خلفي:

**مثال خادم Express.js:**

```javascript
// server.js
const express = require('express');
const cors = require('cors');
const fetch = require('node-fetch');

const app = express();
app.use(cors());
app.use(express.json());

app.post('/chat', async (req, res) => {
    try {
        const response = await fetch('https://api.openai.com/v1/chat/completions', {
            method: 'POST',
            headers: {
                'Content-Type': 'application/json',
                'Authorization': `Bearer ${process.env.OPENAI_API_KEY}`
            },
            body: JSON.stringify({
                model: 'gpt-4',
                messages: req.body.messages,
                max_tokens: 1000,
                temperature: 0.7
            })
        });

        const data = await response.json();
        res.json({
            text: data.choices[0].message.content
        });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
    console.log(`الخادم يعمل على المنفذ ${PORT}`);
});
```

**تكوين الواجهة الأمامية:**

```html
<deep-chat
    request='{"url": "http://localhost:3000/chat", "method": "POST"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## الجزء الثالث: تخصيص واجهة الدردشة

### إضافة الصور الرمزية والأسماء

```html
<deep-chat
    avatars='{
        "default": {
            "styles": {"avatar": {"width": "40px", "height": "40px"}}
        },
        "ai": {
            "src": "https://example.com/ai-avatar.png"
        },
        "user": {
            "src": "https://example.com/user-avatar.png"
        }
    }'
    names='{"ai": "المساعد الذكي", "user": "أنت"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### تصميم الرسائل

```html
<deep-chat
    messageStyles='{
        "default": {
            "shared": {
                "bubble": {
                    "maxWidth": "80%",
                    "borderRadius": "12px",
                    "padding": "12px"
                }
            },
            "user": {
                "bubble": {
                    "backgroundColor": "#007AFF",
                    "color": "white"
                }
            },
            "ai": {
                "bubble": {
                    "backgroundColor": "#F0F0F0",
                    "color": "#000000"
                }
            }
        }
    }'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## الجزء الرابع: الميزات المتقدمة

### 1. دعم تحميل الملفات

تمكين المستخدمين من تحميل الصور والمستندات:

```html
<deep-chat
    textInput='{"files": {"button": {"position": "inside-left"}}}'
    request='{"url": "http://localhost:3000/upload", "method": "POST"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 2. تكامل تحويل الكلام إلى نص

تمكين إدخال الصوت:

```html
<deep-chat
    speechToText='{"webSpeech": true}'
    microphone='{"button": {"position": "inside-left"}}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 3. تحويل النص إلى كلام للاستجابات

اجعل الذكاء الاصطناعي يقرأ الردود بصوت عالٍ:

```html
<deep-chat
    textToSpeech='{"webSpeech": true}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 4. تكامل الكاميرا

التقط الصور مباشرة في الدردشة:

```html
<deep-chat
    camera='{"button": {"position": "inside-left"}}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

### 5. دعم Markdown

تمكين تنسيق النص الغني:

```html
<deep-chat
    textToSpeech='{"displayMarkdown": true}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

## الجزء الخامس: LLM المستند إلى المتصفح مع Web Model

تشغيل نماذج الذكاء الاصطناعي بالكامل في المتصفح بدون أي خادم:

**الخطوة 1: تثبيت حزمة Web LLM**

```bash
npm install deep-chat-web-llm
```

**الخطوة 2: تكوين Deep Chat**

```html
<script type="module">
    import 'deep-chat';
    import 'deep-chat-web-llm';
</script>

<deep-chat
    webModel='{"model": "Mistral-7B-Instruct-v0.2-q4f32_1"}'
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
```

**الفوائد:**
- ✅ بدون تكاليف API
- ✅ خصوصية كاملة (البيانات لا تغادر المتصفح أبداً)
- ✅ يعمل دون اتصال بالإنترنت
- ✅ لا يحتاج إلى خادم

## الجزء السادس: معالجة الرسائل برمجياً

### مثال React مع منطق مخصص

```jsx
import { DeepChat } from 'deep-chat-react';
import { useState } from 'react';

function App() {
    const [chatHistory, setChatHistory] = useState([]);

    const handleNewMessage = (message) => {
        console.log('رسالة جديدة:', message);
        setChatHistory(prev => [...prev, message]);
    };

    const customHandler = async (body, signals) => {
        try {
            // استدعاء API مخصص
            const response = await fetch('https://your-api.com/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body),
                signal: signals.controller.signal
            });

            const data = await response.json();
            
            // إرجاع الاستجابة بتنسيق Deep Chat
            return { text: data.message };
        } catch (error) {
            return { error: error.message };
        }
    };

    return (
        <DeepChat
            handler={customHandler}
            onMessage={handleNewMessage}
            style={% raw %}{{borderRadius: '10px', width: '100%', height: '600px'}}{% endraw %}}
        />
    );
}
```

### استجابات البث

للحصول على استجابات بث في الوقت الفعلي (مثل ChatGPT):

```javascript
const streamHandler = async (body, signals) => {
    const response = await fetch('https://api.openai.com/v1/chat/completions', {
        method: 'POST',
        headers: {
            'Content-Type': 'application/json',
            'Authorization': `Bearer ${API_KEY}`
        },
        body: JSON.stringify({
            ...body,
            stream: true
        }),
        signal: signals.controller.signal
    });

    const reader = response.body.getReader();
    const decoder = new TextDecoder();
    let fullText = '';

    while (true) {
        const { done, value } = await reader.read();
        if (done) break;

        const chunk = decoder.decode(value);
        const lines = chunk.split('\n').filter(line => line.trim() !== '');

        for (const line of lines) {
            if (line.startsWith('data: ')) {
                const data = line.slice(6);
                if (data === '[DONE]') continue;

                try {
                    const parsed = JSON.parse(data);
                    const content = parsed.choices[0]?.delta?.content || '';
                    fullText += content;
                    signals.onResponse({ text: fullText });
                } catch (e) {
                    console.error('خطأ في التحليل:', e);
                }
            }
        }
    }
};
```

## الجزء السابع: اختبار التنفيذ

### إنشاء نص اختبار

احفظه كـ `test-deep-chat.sh`:

```bash
#!/bin/bash

echo "🚀 نص اختبار Deep Chat"
echo "========================"

# التحقق من تثبيت Node.js
if ! command -v node &> /dev/null; then
    echo "❌ Node.js غير مثبت. يرجى تثبيت Node.js أولاً."
    exit 1
fi

echo "✅ إصدار Node.js: $(node --version)"

# إنشاء دليل الاختبار
TEST_DIR="deep-chat-test"
echo "📁 إنشاء دليل الاختبار: $TEST_DIR"
mkdir -p $TEST_DIR
cd $TEST_DIR

# تهيئة المشروع
echo "📦 تهيئة مشروع npm..."
npm init -y

# تثبيت التبعيات
echo "📥 تثبيت deep-chat..."
npm install deep-chat

# إنشاء ملف HTML للاختبار
echo "📝 إنشاء ملف HTML للاختبار..."
cat > index.html << 'EOF'
<!DOCTYPE html>
<html lang="ar" dir="rtl">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>اختبار Deep Chat</title>
    <script type="module">
        import 'deep-chat';
    </script>
    <style>
        body {
            font-family: Arial, sans-serif;
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
        }
        h1 {
            text-align: center;
            color: #007AFF;
        }
    </style>
</head>
<body>
    <h1>اختبار Deep Chat</h1>
    <deep-chat
        style="border-radius: 10px; width: 100%; height: 600px; border: 2px solid #007AFF;"
        introMessage='{"text": "مرحباً! أنا مساعدك الذكي. جرب إرسال رسالة!"}'
        messageStyles='{
            "default": {
                "user": {
                    "bubble": {
                        "backgroundColor": "#007AFF",
                        "color": "white"
                    }
                }
            }
        }'
    ></deep-chat>
</body>
</html>
EOF

echo "✅ تم إنشاء ملف الاختبار بنجاح!"
echo ""
echo "🌐 للاختبار:"
echo "   1. تشغيل: npx serve"
echo "   2. فتح: http://localhost:3000"
echo ""
echo "📂 دليل الاختبار: $(pwd)"
```

### تشغيل الاختبار

```bash
chmod +x test-deep-chat.sh
./test-deep-chat.sh
```

## الجزء الثامن: أفضل الممارسات والنصائح

### 1. أفضل ممارسات الأمان

- **لا تكشف أبداً مفاتيح API في كود الواجهة الأمامية**
- استخدم دائماً بروكسي خلفي للإنتاج
- نفذ تحديد المعدل على خادمك
- تحقق من صحة جميع مدخلات المستخدم ونظفها

### 2. تحسين الأداء

```javascript
// تحميل Deep Chat بشكل كسول لتحسين تحميل الصفحة الأولي
const loadDeepChat = async () => {
    await import('deep-chat');
    // تهيئة الدردشة بعد التحميل
};

// التحميل عندما يقوم المستخدم بالتمرير إلى قسم الدردشة
const observer = new IntersectionObserver((entries) => {
    if (entries[0].isIntersecting) {
        loadDeepChat();
        observer.disconnect();
    }
});

observer.observe(document.querySelector('#chat-container'));
```

### 3. معالجة الأخطاء

```javascript
const chatElement = document.querySelector('deep-chat');

chatElement.addEventListener('error', (event) => {
    console.error('خطأ في الدردشة:', event.detail);
    // عرض رسالة خطأ سهلة الاستخدام
    chatElement.appendChild({
        role: 'ai',
        text: 'عذراً، واجهت خطأ. يرجى المحاولة مرة أخرى.'
    });
});
```

### 4. إمكانية الوصول

```html
<deep-chat
    aria-label="مساعد الدردشة الذكي"
    aria-describedby="chat-description"
    style="border-radius: 10px; width: 100%; height: 600px;"
></deep-chat>
<p id="chat-description" class="sr-only">
    واجهة دردشة تفاعلية للتواصل مع مساعد ذكاء اصطناعي
</p>
```

## مثال كامل: تطبيق دردشة كامل الميزات

إليك تطبيق React كامل يجمع بين ميزات متعددة:

```jsx
import { DeepChat } from 'deep-chat-react';
import { useState } from 'react';

function FullFeaturedChat() {
    const [isLoading, setIsLoading] = useState(false);
    const [messageCount, setMessageCount] = useState(0);

    const customHandler = async (body, signals) => {
        setIsLoading(true);
        
        try {
            const response = await fetch('/api/chat', {
                method: 'POST',
                headers: { 'Content-Type': 'application/json' },
                body: JSON.stringify(body),
                signal: signals.controller.signal
            });

            if (!response.ok) {
                throw new Error(`خطأ HTTP! الحالة: ${response.status}`);
            }

            const data = await response.json();
            setMessageCount(prev => prev + 1);
            
            return { text: data.message };
        } catch (error) {
            console.error('خطأ في الدردشة:', error);
            return { 
                error: 'عذراً، واجهت خطأ. يرجى المحاولة مرة أخرى.' 
            };
        } finally {
            setIsLoading(false);
        }
    };

    return (
        <div style={% raw %}{{ 
            maxWidth: '1200px', 
            margin: '0 auto', 
            padding: '20px' 
        }}{% endraw %}}>
            <div style={% raw %}{{ 
                marginBottom: '20px', 
                display: 'flex', 
                justifyContent: 'space-between' 
            }}{% endraw %}}>
                <h1>مساعد الدردشة الذكي</h1>
                <div>
                    الرسائل: {messageCount}
                    {isLoading && ' (جاري التحميل...)'}
                </div>
            </div>

            <DeepChat
                handler={customHandler}
                introMessage={% raw %}{{
                    text: "👋 مرحباً! أنا مساعدك الذكي. يمكنني مساعدتك في:\n\n" +
                          "• الإجابة على الأسئلة\n" +
                          "• تحليل الصور (تحميل ملف)\n" +
                          "• المحادثات الصوتية (استخدام الميكروفون)\n\n" +
                          "كيف يمكنني مساعدتك اليوم؟"
                }}{% endraw %}}
                textInput={% raw %}{{
                    files: { button: { position: "inside-left" } },
                    placeholder: { text: "اكتب رسالتك..." }
                }}{% endraw %}}
                microphone={% raw %}{{ button: { position: "inside-left" } }}{% endraw %}}
                speechToText={% raw %}{{ webSpeech: true }}{% endraw %}}
                textToSpeech={% raw %}{{ webSpeech: true }}{% endraw %}}
                camera={% raw %}{{ button: { position: "inside-left" } }}{% endraw %}}
                avatars={% raw %}{{
                    ai: { 
                        src: "https://api.dicebear.com/7.x/bottts/svg?seed=ai" 
                    },
                    user: { 
                        src: "https://api.dicebear.com/7.x/personas/svg?seed=user" 
                    }
                }}{% endraw %}}
                names={% raw %}{{ ai: "المساعد الذكي", user: "أنت" }}{% endraw %}}
                messageStyles={% raw %}{{
                    default: {
                        shared: {
                            bubble: {
                                maxWidth: "80%",
                                borderRadius: "12px",
                                padding: "12px 16px"
                            }
                        },
                        user: {
                            bubble: {
                                backgroundColor: "#007AFF",
                                color: "white"
                            }
                        },
                        ai: {
                            bubble: {
                                backgroundColor: "#F0F0F0",
                                color: "#000000"
                            }
                        }
                    }
                }}{% endraw %}}
                style={% raw %}{{
                    borderRadius: '16px',
                    border: '2px solid #E5E5EA',
                    width: '100%',
                    height: '700px',
                    boxShadow: '0 4px 6px rgba(0, 0, 0, 0.1)'
                }}{% endraw %}}
            />
        </div>
    );
}

export default FullFeaturedChat;
```

## الخلاصة

Deep Chat هو حل قوي ومرن لإضافة وظائف الدردشة بالذكاء الاصطناعي إلى تطبيقات الويب الخاصة بك. مع مجموعة ميزاته الواسعة ودعم الأطر وخيارات التخصيص، يمكنك إنشاء أي شيء من روبوتات الدردشة البسيطة إلى مساعدي الذكاء الاصطناعي المتطورين.

### النقاط الرئيسية

1. **تكامل سهل**: أضف روبوت دردشة بسطر واحد فقط من التعليمات البرمجية
2. **مرونة إطار العمل**: يعمل مع React وVue وAngular والمزيد
3. **تكامل خدمة الذكاء الاصطناعي**: اتصال مباشر بـ OpenAI وHuggingFace وCohere
4. **ميزات غنية**: الكلام والكاميرا وتحميل الملفات والمزيد
5. **قابل للتخصيص بالكامل**: صمم كل جانب ليتناسب مع علامتك التجارية
6. **جاهز للإنتاج**: ممارسات أمان مناسبة مع بروكسيات خلفية

### الخطوات التالية

- استكشف الوثائق الرسمية على [deepchat.dev](https://deepchat.dev)
- تحقق من مستودع GitHub لمزيد من الأمثلة
- انضم إلى المجتمع وساهم
- ابنِ تكاملاتك المخصصة

### الموارد

- 📚 [الوثائق الرسمية](https://deepchat.dev)
- 💻 [مستودع GitHub](https://github.com/OvidijusParsiunas/deep-chat)
- 🎮 [ساحة اللعب التفاعلية](https://deepchat.dev/playground)
- 📺 [دروس الفيديو](https://www.youtube.com/@DeepChat)

برمجة سعيدة! 🚀

