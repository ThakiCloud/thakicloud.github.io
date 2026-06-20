---
title: "الدليل الشامل لـ mdream: تحويل أي موقع ويب إلى مارك داون نظيف للذكاء الاصطناعي ونماذج اللغة الكبيرة"
excerpt: "تعلم كيفية استخدام mdream، مكتبة Node.js قوية تحول مواقع الويب إلى تنسيق مارك داون نظيف مثالي لتطبيقات الذكاء الاصطناعي وإنتاج السياق لنماذج اللغة الكبيرة."
seo_title: "دروس mdream: تحويل HTML إلى مارك داون للذكاء الاصطناعي - Thaki Cloud"
seo_description: "إتقان مكتبة mdream لتحويل مواقع الويب إلى مارك داون. يشمل التثبيت واستخدام API ونظام الإضافات وأمثلة واقعية لتطبيقات الذكاء الاصطناعي وتكامل نماذج اللغة الكبيرة."
date: 2025-09-24
categories:
  - tutorials
tags:
  - mdream
  - html-to-markdown
  - ai-tools
  - llm
  - web-scraping
  - nodejs
author_profile: true
toc: true
toc_label: "جدول المحتويات"
lang: ar
permalink: /ar/tutorials/mdream-html-to-markdown-conversion-tutorial/
canonical_url: "https://thakicloud.github.io/ar/tutorials/mdream-html-to-markdown-conversion-tutorial/"
published: false
---

⏱️ **وقت القراءة المقدر**: 8 دقائق

## مقدمة

في عصر الذكاء الاصطناعي ونماذج اللغة الكبيرة (LLMs)، أصبح تحويل محتوى الويب إلى تنسيق مارك داون نظيف ومنظم أمرًا مهمًا بشكل متزايد. **mdream** هي مكتبة Node.js قوية تحول أي موقع ويب إلى تنسيق مارك داون نظيف، مما يجعلها مثالية لتطبيقات الذكاء الاصطناعي وإنتاج السياق لنماذج اللغة الكبيرة وسير عمل معالجة المحتوى.

تم إنشاء mdream بواسطة [Harlan Wilton](https://github.com/harlan-zw)، وتتميز بقدراتها على التدفق المباشر ونظام الإضافات الشامل والإعدادات المسبقة المتخصصة لحالات الاستخدام المختلفة. سواء كنت تبني تطبيقات ذكاء اصطناعي أو تنشئ وثائق أو تعالج محتوى الويب على نطاق واسع، فإن mdream توفر الأدوات التي تحتاجها.

## ما هو mdream؟

mdream هي مكتبة شاملة لتحويل HTML إلى مارك داون تقدم:

- **مخرجات مارك داون نظيفة**: ينتج مارك داون منظم جيدًا مثالي للاستهلاك بواسطة الذكاء الاصطناعي
- **دعم التدفق المباشر**: يتعامل بكفاءة مع صفحات الويب الكبيرة مع التحويل المتدفق
- **نظام الإضافات**: هيكل قابل للتوسيع لاحتياجات المعالجة المخصصة
- **تكامل الإطارات**: دعم مدمج لـ Vite و Nuxt.js
- **ميزات مركزة على الذكاء الاصطناعي**: ينتج ملفات `llms.txt` لتحسين قابلية اكتشاف الذكاء الاصطناعي

## التثبيت والإعداد

### التثبيت الأساسي

```bash
# استخدام npm
npm install mdream

# استخدام yarn
yarn add mdream

# استخدام pnpm
pnpm add mdream
```

### التثبيت الخاص بالإطارات

لمشاريع **Vite**:
```bash
pnpm install @mdream/vite
```

لمشاريع **Nuxt.js**:
```bash
pnpm add @mdream/nuxt
```

## استخدام API الأساسي

### تحويل HTML الموجود

أبسط طريقة لاستخدام mdream هي مع دالة `htmlToMarkdown`:

```javascript
import { htmlToMarkdown } from 'mdream'

// التحويل الأساسي
const html = '<h1>مرحبا بالعالم</h1><p>هذه فقرة.</p>'
const markdown = htmlToMarkdown(html)
console.log(markdown)
// المخرجات:
// # مرحبا بالعالم
// 
// هذه فقرة.
```

### تحويل HTML المتدفق

للحصول على أداء أفضل مع مواقع الويب الكبيرة، استخدم `streamHtmlToMarkdown`:

```javascript
import { streamHtmlToMarkdown } from 'mdream'

async function convertWebsite(url) {
  const response = await fetch(url)
  const htmlStream = response.body
  
  const markdownGenerator = streamHtmlToMarkdown(htmlStream, {
    origin: url
  })

  let fullMarkdown = ''
  for await (const chunk of markdownGenerator) {
    fullMarkdown += chunk
    // معالجة القطع عند وصولها
    console.log('تم استلام قطعة:', chunk.length, 'حرف')
  }
  
  return fullMarkdown
}

// الاستخدام
const markdown = await convertWebsite('https://example.com')
```

### تحليل HTML البحت

للتطبيقات التي تحتاج إلى تحليل DOM بدون تحويل مارك داون:

```javascript
import { parseHtml } from 'mdream'

const html = '<div><h1>العنوان</h1><p>المحتوى</p></div>'
const { events, remainingHtml } = parseHtml(html)

// معالجة أحداث DOM
events.forEach((event) => {
  if (event.type === 'enter' && event.node.type === 'element') {
    console.log('دخول العنصر:', event.node.tagName)
  }
  if (event.type === 'exit' && event.node.type === 'element') {
    console.log('خروج العنصر:', event.node.tagName)
  }
})
```

## استكشاف نظام الإضافات

نظام الإضافات في mdream هو واحد من أقوى ميزاته، مما يسمح لك بتخصيص كل جانب من جوانب عملية التحويل.

### الإضافات المدمجة

#### 1. إضافة الفلترة
استبعاد أو تضمين عناصر محددة:

```javascript
import { htmlToMarkdown } from 'mdream'
import { filterPlugin } from 'mdream/plugins'

const html = `
<div>
  <nav>قائمة التنقل</nav>
  <main>
    <h1>المحتوى الرئيسي</h1>
    <p>محتوى مهم هنا</p>
  </main>
  <footer>محتوى التذييل</footer>
</div>
`

const markdown = htmlToMarkdown(html, {
  plugins: [
    filterPlugin({ 
      exclude: ['nav', 'footer', '.sidebar', '#advertisement'] 
    })
  ]
})
// سيتم تحويل المحتوى الرئيسي فقط
```

#### 2. إضافة Frontmatter
إنتاج YAML frontmatter من علامات HTML meta:

```javascript
import { frontmatterPlugin } from 'mdream/plugins'

const html = `
<html>
<head>
  <title>مقالة مدونتي</title>
  <meta name="description" content="هذه مقالة مدونة رائعة">
  <meta name="author" content="أحمد محمد">
</head>
<body>
  <h1>المحتوى</h1>
</body>
</html>
`

const markdown = htmlToMarkdown(html, {
  plugins: [frontmatterPlugin()]
})

// المخرجات تشمل frontmatter:
// ---
// title: مقالة مدونتي
// description: هذه مقالة مدونة رائعة
// author: أحمد محمد
// ---
// # المحتوى
```

#### 3. إضافة العزل
استخراج المحتوى الرئيسي تلقائيًا:

```javascript
import { isolateMainPlugin } from 'mdream/plugins'

const markdown = htmlToMarkdown(html, {
  plugins: [isolateMainPlugin()]
})
// يجد ويحول منطقة المحتوى الرئيسي تلقائيًا
```

#### 4. إضافة Tailwind
تحويل فئات Tailwind CSS إلى تنسيق مارك داون:

```javascript
import { tailwindPlugin } from 'mdream/plugins'

const html = '<p class="font-bold text-red-500">نص مهم</p>'
const markdown = htmlToMarkdown(html, {
  plugins: [tailwindPlugin()]
})
// المخرجات: **نص مهم**
```

### إنشاء إضافات مخصصة

بناء إضافاتك الخاصة للاحتياجات المحددة:

```javascript
import { createPlugin } from 'mdream/plugins'
import type { ElementNode, TextNode } from 'mdream'

// مثال: إضافة رموز تعبيرية للعناوين
const emojiHeadingPlugin = createPlugin({
  onNodeEnter(node: ElementNode) {
    if (node.name === 'h1') {
      return '🚀 '
    }
    if (node.name === 'h2') {
      return '📚 '
    }
    if (node.name === 'h3') {
      return '✨ '
    }
  },

  processTextNode(textNode: TextNode) {
    // تمييز النص المهم
    if (textNode.parent?.attributes?.class?.includes('highlight')) {
      return {
        content: `**${textNode.value}**`,
        skip: false
      }
    }
  }
})

// الاستخدام
const markdown = htmlToMarkdown(html, {
  plugins: [emojiHeadingPlugin]
})
```

### مثال إضافة متقدم: استخراج المحتوى

```javascript
import { extractionPlugin } from 'mdream'

const extractedData = {}

const dataExtractionPlugin = extractionPlugin({
  'h1, h2, h3': (element, state) => {
    if (!extractedData.headings) extractedData.headings = []
    extractedData.headings.push({
      level: element.tagName,
      text: element.textContent,
      depth: state.depth
    })
  },
  
  'img[alt]': (element, state) => {
    if (!extractedData.images) extractedData.images = []
    extractedData.images.push({
      src: element.attributes.src,
      alt: element.attributes.alt,
      context: state.options.origin
    })
  },
  
  'a[href]': (element, state) => {
    if (!extractedData.links) extractedData.links = []
    extractedData.links.push({
      href: element.attributes.href,
      text: element.textContent,
      isExternal: element.attributes.href.startsWith('http')
    })
  }
})

// تحويل واستخراج البيانات في نفس الوقت
const markdown = htmlToMarkdown(html, {
  plugins: [dataExtractionPlugin],
  origin: 'https://example.com'
})

console.log('البيانات المستخرجة:', extractedData)
```

## إعدادات مسبقة لحالات الاستخدام الشائعة

### الإعداد المسبق الأدنى

مثالي لتطبيقات الذكاء الاصطناعي حيث تريد مخرجات نظيفة وفعالة من ناحية الرموز:

```javascript
import { withMinimalPreset } from 'mdream/preset/minimal'

const options = withMinimalPreset({
  origin: 'https://example.com'
})

const markdown = htmlToMarkdown(html, options)
```

الإعداد المسبق الأدنى يشمل:
- `isolateMainPlugin()` - استخراج المحتوى الرئيسي
- `frontmatterPlugin()` - إنتاج YAML frontmatter
- `tailwindPlugin()` - تحويل فئات Tailwind
- `filterPlugin()` - إزالة العناصر غير المحتوى

### استخدام CLI مع الإعدادات المسبقة

```bash
# استخدام الإعداد المسبق الأدنى عبر CLI
curl -s https://example.com | npx mdream --preset minimal --origin https://example.com

# حفظ في ملف
curl -s https://example.com | npx mdream --preset minimal --origin https://example.com > output.md
```

## تكامل الإطارات

### تكامل Vite

إضافة إنتاج مارك داون تلقائي لمشروع Vite الخاص بك:

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import MdreamVite from '@mdream/vite'

export default defineConfig({
  plugins: [
    MdreamVite({
      // خيارات مخصصة
      plugins: [
        // إضافاتك المخصصة
      ]
    })
  ]
})
```

الآن يمكنك الوصول إلى أي مسار بامتداد `.md`:
- `/about.html` → `/about.md`
- `/blog/post.html` → `/blog/post.md`

### تكامل Nuxt.js

تمكين مسارات مارك داون التلقائية وإنتاج LLMs.txt:

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  modules: [
    '@mdream/nuxt'
  ],
  mdream: {
    // تكوين مخصص
    preset: 'minimal',
    plugins: [
      // إضافات إضافية
    ]
  }
})
```

الميزات:
- متغيرات مسار `.md` تلقائية
- إنتاج `llms.txt` و `llms-full.txt` أثناء الإنتاج الثابت
- إصدارات مارك داون صديقة لـ SEO من صفحاتك

## أمثلة واقعية

### مثال 1: محول موقع التوثيق

```javascript
import { htmlToMarkdown } from 'mdream'
import { filterPlugin, frontmatterPlugin, isolateMainPlugin } from 'mdream/plugins'
import fs from 'fs/promises'

async function convertDocumentationSite(urls) {
  const results = []
  
  for (const url of urls) {
    try {
      const response = await fetch(url)
      const html = await response.text()
      
      const markdown = htmlToMarkdown(html, {
        origin: url,
        plugins: [
          isolateMainPlugin(),
          frontmatterPlugin(),
          filterPlugin({
            exclude: [
              'nav', 'footer', '.sidebar', 
              '.advertisement', '.social-share'
            ]
          })
        ]
      })
      
      // استخراج اسم الملف من URL
      const filename = url.split('/').pop() || 'index'
      await fs.writeFile(`docs/${filename}.md`, markdown)
      
      results.push({ url, filename, success: true })
    } catch (error) {
      results.push({ url, success: false, error: error.message })
    }
  }
  
  return results
}

// الاستخدام
const urls = [
  'https://docs.example.com/getting-started',
  'https://docs.example.com/api-reference',
  'https://docs.example.com/examples'
]

const results = await convertDocumentationSite(urls)
console.log('نتائج التحويل:', results)
```

### مثال 2: جامع محتوى المدونات

```javascript
import { htmlToMarkdown } from 'mdream'
import { extractionPlugin, filterPlugin } from 'mdream/plugins'

class BlogAggregator {
  constructor() {
    this.articles = []
  }
  
  async processArticle(url) {
    const response = await fetch(url)
    const html = await response.text()
    
    const articleData = {}
    
    const extractionPluginInstance = extractionPlugin({
      'h1': (element) => {
        articleData.title = element.textContent
      },
      '[datetime], .published-date, .date': (element) => {
        articleData.publishedDate = element.textContent || element.attributes.datetime
      },
      '.author, [rel="author"]': (element) => {
        articleData.author = element.textContent
      },
      'img[src]': (element) => {
        if (!articleData.images) articleData.images = []
        articleData.images.push({
          src: element.attributes.src,
          alt: element.attributes.alt || ''
        })
      }
    })
    
    const markdown = htmlToMarkdown(html, {
      origin: url,
      plugins: [
        extractionPluginInstance,
        filterPlugin({
          exclude: [
            'nav', 'footer', '.comments', 
            '.social-share', '.advertisement'
          ]
        })
      ]
    })
    
    return {
      url,
      markdown,
      metadata: articleData,
      wordCount: markdown.split(' ').length,
      processedAt: new Date().toISOString()
    }
  }
  
  async aggregateBlogs(urls) {
    const results = await Promise.allSettled(
      urls.map(url => this.processArticle(url))
    )
    
    return results
      .filter(result => result.status === 'fulfilled')
      .map(result => result.value)
  }
}

// الاستخدام
const aggregator = new BlogAggregator()
const blogUrls = [
  'https://blog.example.com/post-1',
  'https://blog.example.com/post-2',
  'https://blog.example.com/post-3'
]

const articles = await aggregator.aggregateBlogs(blogUrls)
console.log(`تمت معالجة ${articles.length} مقال`)
```

### مثال 3: إعداد بيانات تدريب الذكاء الاصطناعي

```javascript
import { htmlToMarkdown } from 'mdream'
import { withMinimalPreset } from 'mdream/preset/minimal'

class AIDataPreparator {
  constructor(options = {}) {
    this.maxTokens = options.maxTokens || 4000
    this.outputDir = options.outputDir || './ai-training-data'
  }
  
  estimateTokens(text) {
    // تقدير تقريبي: 1 رمز ≈ 4 أحرف
    return Math.ceil(text.length / 4)
  }
  
  async prepareTrainingData(urls) {
    const trainingExamples = []
    
    for (const url of urls) {
      try {
        const response = await fetch(url)
        const html = await response.text()
        
        const options = withMinimalPreset({
          origin: url
        })
        
        const markdown = htmlToMarkdown(html, options)
        const tokenCount = this.estimateTokens(markdown)
        
        if (tokenCount <= this.maxTokens) {
          trainingExamples.push({
            source: url,
            content: markdown,
            tokens: tokenCount,
            type: 'full_page'
          })
        } else {
          // تقسيم إلى قطع إذا كان كبيرًا جدًا
          const chunks = this.chunkContent(markdown, this.maxTokens)
          chunks.forEach((chunk, index) => {
            trainingExamples.push({
              source: `${url}#chunk-${index}`,
              content: chunk,
              tokens: this.estimateTokens(chunk),
              type: 'chunk'
            })
          })
        }
      } catch (error) {
        console.error(`فشل في معالجة ${url}:`, error.message)
      }
    }
    
    return trainingExamples
  }
  
  chunkContent(content, maxTokens) {
    const chunks = []
    const paragraphs = content.split('\n\n')
    let currentChunk = ''
    
    for (const paragraph of paragraphs) {
      const potentialChunk = currentChunk + '\n\n' + paragraph
      if (this.estimateTokens(potentialChunk) > maxTokens && currentChunk) {
        chunks.push(currentChunk.trim())
        currentChunk = paragraph
      } else {
        currentChunk = potentialChunk
      }
    }
    
    if (currentChunk.trim()) {
      chunks.push(currentChunk.trim())
    }
    
    return chunks
  }
  
  async saveTrainingData(trainingExamples, filename = 'training_data.jsonl') {
    const jsonlContent = trainingExamples
      .map(example => JSON.stringify(example))
      .join('\n')
    
    await fs.writeFile(filename, jsonlContent, 'utf8')
    console.log(`تم حفظ ${trainingExamples.length} مثال تدريبي في ${filename}`)
  }
}

// الاستخدام
const preparator = new AIDataPreparator({
  maxTokens: 3000,
  outputDir: './ai-data'
})

const urls = [
  'https://docs.framework.com/guide',
  'https://docs.framework.com/api',
  'https://docs.framework.com/examples'
]

const trainingData = await preparator.prepareTrainingData(urls)
await preparator.saveTrainingData(trainingData)
```

## تحسين الأداء

### التدفق للمواقع الكبيرة

```javascript
import { streamHtmlToMarkdown } from 'mdream'

async function efficientConversion(url) {
  const response = await fetch(url)
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`)
  }
  
  if (!response.body) {
    throw new Error('لا يوجد نص استجابة متاح للتدفق')
  }
  
  const markdownGenerator = streamHtmlToMarkdown(response.body, {
    origin: url,
    plugins: [
      // إضافات أساسية فقط لأداء أفضل
    ]
  })
  
  let result = ''
  let chunkCount = 0
  
  for await (const chunk of markdownGenerator) {
    result += chunk
    chunkCount++
    
    // اختياري: تقرير التقدم
    if (chunkCount % 10 === 0) {
      console.log(`معالجة ${chunkCount} قطعة...`)
    }
  }
  
  return result
}
```

### المعالجة المجمعة

```javascript
import pLimit from 'p-limit'

const limit = pLimit(5) // معالجة 5 URLs في نفس الوقت

async function batchConvertUrls(urls, options = {}) {
  const results = await Promise.allSettled(
    urls.map(url => 
      limit(() => convertUrl(url, options))
    )
  )
  
  const successful = results
    .filter(result => result.status === 'fulfilled')
    .map(result => result.value)
  
  const failed = results
    .filter(result => result.status === 'rejected')
    .map((result, index) => ({
      url: urls[index],
      error: result.reason.message
    }))
  
  return { successful, failed }
}
```

## أفضل الممارسات

### 1. اختيار النهج الصحيح

```javascript
// لمقتطفات HTML الصغيرة
const markdown = htmlToMarkdown(html)

// لصفحات الويب الكبيرة
const markdown = await streamHtmlToMarkdown(htmlStream, { origin })

// لتحليل DOM بدون مارك داون
const { events } = parseHtml(html)
```

### 2. اختيار الإضافات

```javascript
// لتطبيقات الذكاء الاصطناعي/نماذج اللغة الكبيرة
const options = withMinimalPreset({ origin })

// لتحويل التوثيق
const options = {
  plugins: [
    isolateMainPlugin(),
    frontmatterPlugin(),
    filterPlugin({ exclude: ['nav', 'footer'] })
  ]
}

// لتحليل المحتوى
const options = {
  plugins: [
    extractionPlugin({
      'h1, h2, h3': extractHeadings,
      'img': extractImages,
      'a[href]': extractLinks
    })
  ]
}
```

### 3. معالجة الأخطاء

```javascript
async function robustConversion(url) {
  try {
    const response = await fetch(url, {
      timeout: 10000, // مهلة زمنية 10 ثوان
      headers: {
        'User-Agent': 'mdream-converter/1.0'
      }
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    
    const contentType = response.headers.get('content-type')
    if (!contentType?.includes('text/html')) {
      throw new Error(`نوع محتوى غير متوقع: ${contentType}`)
    }
    
    return await streamHtmlToMarkdown(response.body, {
      origin: url
    })
  } catch (error) {
    console.error(`فشل في تحويل ${url}:`, error.message)
    return null
  }
}
```

## استكشاف الأخطاء وإصلاحها

### المشاكل الشائعة

1. **مشاكل الذاكرة مع الصفحات الكبيرة**
   ```javascript
   // استخدم التدفق بدلاً من تحميل HTML كامل
   const stream = streamHtmlToMarkdown(htmlStream, options)
   ```

2. **HTML مشوه**
   ```javascript
   // mdream يتعامل مع HTML المشوه بأناقة
   const markdown = htmlToMarkdown(malformedHtml, {
     // النتائج قد تختلف حسب بنية HTML
   })
   ```

3. **محتوى مفقود**
   ```javascript
   // تحقق مما إذا كان المحتوى في علامات <main>
   const options = {
     plugins: [isolateMainPlugin()]
   }
   ```

4. **ضوضاء كثيرة في المخرجات**
   ```javascript
   // استخدم ترشيح عدواني
   const options = {
     plugins: [
       filterPlugin({
         exclude: [
           'nav', 'footer', 'aside', '.sidebar',
           '.advertisement', '.social', '.comments'
         ]
       })
     ]
   }
   ```

## الخلاصة

mdream هي مكتبة قوية ومرنة تجعل تحويل HTML إلى مارك داون مباشرًا وقابلاً للتخصيص. قدراتها على التدفق المباشر ونظام الإضافات الشامل والميزات المركزة على الذكاء الاصطناعي تجعلها خيارًا ممتازًا لسير عمل معالجة محتوى الويب الحديث.

سواء كنت تبني تطبيقات ذكاء اصطناعي أو تنشئ أنظمة توثيق أو تعالج محتوى الويب على نطاق واسع، فإن mdream توفر الأدوات والمرونة التي تحتاجها للحصول على مخرجات مارك داون نظيفة ومنظمة.

النقاط الرئيسية:
- استخدم التدفق للمواقع الكبيرة والأداء الأفضل
- استفد من نظام الإضافات لاحتياجات المعالجة المخصصة
- اختر الإعدادات المسبقة المناسبة لحالة الاستخدام الخاصة بك
- فكر في تكامل الإطارات لتطبيقات الويب
- نفذ معالجة أخطاء مناسبة للاستخدام في الإنتاج

ابدأ في التجريب مع mdream اليوم وشاهد كيف يمكنها تبسيط سير عمل تحويل HTML إلى مارك داون الخاص بك!

## موارد إضافية

- [مستودع mdream على GitHub](https://github.com/harlan-zw/mdream)
- [التوثيق الرسمي](https://github.com/harlan-zw/mdream/blob/main/README.md)
- [دليل تطوير الإضافات](https://github.com/harlan-zw/mdream/tree/main/packages)
- [دليل الأمثلة](https://github.com/harlan-zw/mdream/tree/main/examples)

