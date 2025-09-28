---
title: "mdream 완전 가이드: 웹사이트를 AI 및 LLM용 깔끔한 마크다운으로 변환하기"
excerpt: "웹사이트를 AI 애플리케이션과 LLM 컨텍스트 생성에 완벽한 깔끔한 마크다운 형식으로 변환하는 강력한 Node.js 라이브러리 mdream 사용법을 배워보세요."
seo_title: "mdream 튜토리얼: AI용 HTML to 마크다운 변환 - Thaki Cloud"
seo_description: "웹사이트를 마크다운으로 변환하는 mdream 라이브러리 마스터하기. 설치, API 사용법, 플러그인 시스템, AI 애플리케이션과 LLM 통합을 위한 실제 예제 포함."
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
toc_label: "목차"
lang: ko
permalink: /ko/tutorials/mdream-html-to-markdown-conversion-tutorial/
canonical_url: "https://thakicloud.github.io/ko/tutorials/mdream-html-to-markdown-conversion-tutorial/"
---

⏱️ **예상 읽기 시간**: 8분

## 소개

AI와 대형 언어 모델(LLM) 시대에 웹 콘텐츠를 깔끔하고 구조화된 마크다운으로 변환하는 것이 점점 중요해지고 있습니다. **mdream**은 모든 웹사이트를 깔끔한 마크다운 형식으로 변환하는 강력한 Node.js 라이브러리로, AI 애플리케이션, LLM 컨텍스트 생성, 콘텐츠 처리 워크플로우에 완벽합니다.

[Harlan Wilton](https://github.com/harlan-zw)이 개발한 mdream은 스트리밍 기능, 광범위한 플러그인 시스템, 다양한 사용 사례를 위한 전문 프리셋으로 차별화됩니다. AI 애플리케이션을 구축하거나, 문서를 생성하거나, 대규모 웹 콘텐츠를 처리하든 mdream이 필요한 도구를 제공합니다.

## mdream이란?

mdream은 다음 기능을 제공하는 포괄적인 HTML-to-마크다운 변환 라이브러리입니다:

- **깔끔한 마크다운 출력**: AI 소비에 완벽한 잘 구조화된 마크다운 생성
- **스트리밍 지원**: 스트리밍 변환으로 대형 웹페이지를 효율적으로 처리
- **플러그인 시스템**: 커스텀 처리 요구사항을 위한 확장 가능한 아키텍처
- **프레임워크 통합**: Vite와 Nuxt.js 내장 지원
- **AI 중심 기능**: AI 발견성 향상을 위한 `llms.txt` 파일 생성

## 설치 및 설정

### 기본 설치

```bash
# npm 사용
npm install mdream

# yarn 사용
yarn add mdream

# pnpm 사용
pnpm add mdream
```

### 프레임워크별 설치

**Vite** 프로젝트용:
```bash
pnpm install @mdream/vite
```

**Nuxt.js** 프로젝트용:
```bash
pnpm add @mdream/nuxt
```

## 핵심 API 사용법

### 기존 HTML 변환

mdream을 사용하는 가장 간단한 방법은 `htmlToMarkdown` 함수입니다:

```javascript
import { htmlToMarkdown } from 'mdream'

// 기본 변환
const html = '<h1>안녕하세요</h1><p>이것은 문단입니다.</p>'
const markdown = htmlToMarkdown(html)
console.log(markdown)
// 출력:
// # 안녕하세요
// 
// 이것은 문단입니다.
```

### 스트리밍 HTML 변환

대형 웹사이트의 성능 향상을 위해 `streamHtmlToMarkdown`을 사용하세요:

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
    // 청크가 도착하면 처리
    console.log('청크 수신:', chunk.length, '문자')
  }
  
  return fullMarkdown
}

// 사용법
const markdown = await convertWebsite('https://example.com')
```

### 순수 HTML 파싱

마크다운 변환 없이 DOM 파싱이 필요한 애플리케이션용:

```javascript
import { parseHtml } from 'mdream'

const html = '<div><h1>제목</h1><p>내용</p></div>'
const { events, remainingHtml } = parseHtml(html)

// DOM 이벤트 처리
events.forEach((event) => {
  if (event.type === 'enter' && event.node.type === 'element') {
    console.log('요소 진입:', event.node.tagName)
  }
  if (event.type === 'exit' && event.node.type === 'element') {
    console.log('요소 종료:', event.node.tagName)
  }
})
```

## 플러그인 시스템 심화

mdream의 플러그인 시스템은 변환 과정의 모든 측면을 커스터마이즈할 수 있게 해주는 가장 강력한 기능 중 하나입니다.

### 내장 플러그인

#### 1. 필터 플러그인
특정 요소를 제외하거나 포함:

```javascript
import { htmlToMarkdown } from 'mdream'
import { filterPlugin } from 'mdream/plugins'

const html = `
<div>
  <nav>네비게이션 메뉴</nav>
  <main>
    <h1>주요 콘텐츠</h1>
    <p>여기에 중요한 내용</p>
  </main>
  <footer>푸터 내용</footer>
</div>
`

const markdown = htmlToMarkdown(html, {
  plugins: [
    filterPlugin({ 
      exclude: ['nav', 'footer', '.sidebar', '#advertisement'] 
    })
  ]
})
// 주요 콘텐츠만 변환됩니다
```

#### 2. 프론트매터 플러그인
HTML 메타 태그에서 YAML 프론트매터 생성:

```javascript
import { frontmatterPlugin } from 'mdream/plugins'

const html = `
<html>
<head>
  <title>내 블로그 포스트</title>
  <meta name="description" content="이것은 훌륭한 블로그 포스트입니다">
  <meta name="author" content="홍길동">
</head>
<body>
  <h1>내용</h1>
</body>
</html>
`

const markdown = htmlToMarkdown(html, {
  plugins: [frontmatterPlugin()]
})

// 출력에 프론트매터 포함:
// ---
// title: 내 블로그 포스트
// description: 이것은 훌륭한 블로그 포스트입니다
// author: 홍길동
// ---
// # 내용
```

#### 3. 격리 플러그인
주요 콘텐츠를 자동으로 추출:

```javascript
import { isolateMainPlugin } from 'mdream/plugins'

const markdown = htmlToMarkdown(html, {
  plugins: [isolateMainPlugin()]
})
// 자동으로 주요 콘텐츠 영역만 찾아서 변환합니다
```

#### 4. Tailwind 플러그인
Tailwind CSS 클래스를 마크다운 형식으로 변환:

```javascript
import { tailwindPlugin } from 'mdream/plugins'

const html = '<p class="font-bold text-red-500">중요한 텍스트</p>'
const markdown = htmlToMarkdown(html, {
  plugins: [tailwindPlugin()]
})
// 출력: **중요한 텍스트**
```

### 커스텀 플러그인 생성

특정 요구사항을 위한 자체 플러그인 구축:

```javascript
import { createPlugin } from 'mdream/plugins'
import type { ElementNode, TextNode } from 'mdream'

// 예시: 제목에 이모지 추가
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
    // 중요한 텍스트 강조
    if (textNode.parent?.attributes?.class?.includes('highlight')) {
      return {
        content: `**${textNode.value}**`,
        skip: false
      }
    }
  }
})

// 사용법
const markdown = htmlToMarkdown(html, {
  plugins: [emojiHeadingPlugin]
})
```

### 고급 플러그인 예시: 콘텐츠 추출

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

// 변환과 데이터 추출을 동시에 수행
const markdown = htmlToMarkdown(html, {
  plugins: [dataExtractionPlugin],
  origin: 'https://example.com'
})

console.log('추출된 데이터:', extractedData)
```

## 일반적인 사용 사례를 위한 프리셋

### 미니멀 프리셋

토큰 효율적인 출력이 필요한 AI 애플리케이션에 완벽:

```javascript
import { withMinimalPreset } from 'mdream/preset/minimal'

const options = withMinimalPreset({
  origin: 'https://example.com'
})

const markdown = htmlToMarkdown(html, options)
```

미니멀 프리셋 포함 사항:
- `isolateMainPlugin()` - 주요 콘텐츠 추출
- `frontmatterPlugin()` - YAML 프론트매터 생성
- `tailwindPlugin()` - Tailwind 클래스 변환
- `filterPlugin()` - 비콘텐츠 요소 제거

### CLI에서 프리셋 사용

```bash
# CLI로 미니멀 프리셋 사용
curl -s https://example.com | npx mdream --preset minimal --origin https://example.com

# 파일로 저장
curl -s https://example.com | npx mdream --preset minimal --origin https://example.com > output.md
```

## 프레임워크 통합

### Vite 통합

Vite 프로젝트에 자동 마크다운 생성 추가:

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import MdreamVite from '@mdream/vite'

export default defineConfig({
  plugins: [
    MdreamVite({
      // 커스텀 옵션
      plugins: [
        // 사용자 정의 플러그인
      ]
    })
  ]
})
```

이제 모든 라우트에 `.md` 확장자로 접근할 수 있습니다:
- `/about.html` → `/about.md`
- `/blog/post.html` → `/blog/post.md`

### Nuxt.js 통합

자동 마크다운 라우트와 LLMs.txt 생성 활성화:

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  modules: [
    '@mdream/nuxt'
  ],
  mdream: {
    // 커스텀 구성
    preset: 'minimal',
    plugins: [
      // 추가 플러그인
    ]
  }
})
```

기능:
- 자동 `.md` 라우트 변형
- 정적 생성 중 `llms.txt` 및 `llms-full.txt` 생성
- 페이지의 SEO 친화적 마크다운 버전

## 실제 예제

### 예제 1: 문서 사이트 변환기

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
      
      // URL에서 파일명 추출
      const filename = url.split('/').pop() || 'index'
      await fs.writeFile(`docs/${filename}.md`, markdown)
      
      results.push({ url, filename, success: true })
    } catch (error) {
      results.push({ url, success: false, error: error.message })
    }
  }
  
  return results
}

// 사용법
const urls = [
  'https://docs.example.com/getting-started',
  'https://docs.example.com/api-reference',
  'https://docs.example.com/examples'
]

const results = await convertDocumentationSite(urls)
console.log('변환 결과:', results)
```

### 예제 2: 블로그 콘텐츠 수집기

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

// 사용법
const aggregator = new BlogAggregator()
const blogUrls = [
  'https://blog.example.com/post-1',
  'https://blog.example.com/post-2',
  'https://blog.example.com/post-3'
]

const articles = await aggregator.aggregateBlogs(blogUrls)
console.log(`${articles.length}개 아티클 처리 완료`)
```

### 예제 3: AI 학습 데이터 준비

```javascript
import { htmlToMarkdown } from 'mdream'
import { withMinimalPreset } from 'mdream/preset/minimal'

class AIDataPreparator {
  constructor(options = {}) {
    this.maxTokens = options.maxTokens || 4000
    this.outputDir = options.outputDir || './ai-training-data'
  }
  
  estimateTokens(text) {
    // 대략적 추정: 1 토큰 ≈ 4 문자
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
          // 너무 클 경우 청크로 분할
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
        console.error(`${url} 처리 실패:`, error.message)
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
    console.log(`${trainingExamples.length}개 학습 예제를 ${filename}에 저장했습니다`)
  }
}

// 사용법
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

## 성능 최적화

### 대형 사이트를 위한 스트리밍

```javascript
import { streamHtmlToMarkdown } from 'mdream'

async function efficientConversion(url) {
  const response = await fetch(url)
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`)
  }
  
  if (!response.body) {
    throw new Error('스트리밍을 위한 응답 본문이 없습니다')
  }
  
  const markdownGenerator = streamHtmlToMarkdown(response.body, {
    origin: url,
    plugins: [
      // 성능 향상을 위해 필수 플러그인만 사용
    ]
  })
  
  let result = ''
  let chunkCount = 0
  
  for await (const chunk of markdownGenerator) {
    result += chunk
    chunkCount++
    
    // 선택사항: 진행 상황 보고
    if (chunkCount % 10 === 0) {
      console.log(`${chunkCount}개 청크 처리 중...`)
    }
  }
  
  return result
}
```

### 일괄 처리

```javascript
import pLimit from 'p-limit'

const limit = pLimit(5) // 5개 URL을 동시에 처리

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

## 모범 사례

### 1. 올바른 접근법 선택

```javascript
// 작은 HTML 스니펫용
const markdown = htmlToMarkdown(html)

// 대형 웹페이지용
const markdown = await streamHtmlToMarkdown(htmlStream, { origin })

// 마크다운 없는 DOM 분석용
const { events } = parseHtml(html)
```

### 2. 플러그인 선택

```javascript
// AI/LLM 애플리케이션용
const options = withMinimalPreset({ origin })

// 문서 변환용
const options = {
  plugins: [
    isolateMainPlugin(),
    frontmatterPlugin(),
    filterPlugin({ exclude: ['nav', 'footer'] })
  ]
}

// 콘텐츠 분석용
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

### 3. 오류 처리

```javascript
async function robustConversion(url) {
  try {
    const response = await fetch(url, {
      timeout: 10000, // 10초 타임아웃
      headers: {
        'User-Agent': 'mdream-converter/1.0'
      }
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    
    const contentType = response.headers.get('content-type')
    if (!contentType?.includes('text/html')) {
      throw new Error(`예상치 못한 콘텐츠 타입: ${contentType}`)
    }
    
    return await streamHtmlToMarkdown(response.body, {
      origin: url
    })
  } catch (error) {
    console.error(`${url} 변환 실패:`, error.message)
    return null
  }
}
```

## 문제 해결

### 일반적인 문제

1. **대형 페이지의 메모리 문제**
   ```javascript
   // 전체 HTML 로딩 대신 스트리밍 사용
   const stream = streamHtmlToMarkdown(htmlStream, options)
   ```

2. **잘못된 형식의 HTML**
   ```javascript
   // mdream은 잘못된 형식의 HTML을 우아하게 처리합니다
   const markdown = htmlToMarkdown(malformedHtml, {
     // 결과는 HTML 구조에 따라 달라질 수 있습니다
   })
   ```

3. **누락된 콘텐츠**
   ```javascript
   // 콘텐츠가 <main> 태그에 있는지 확인
   const options = {
     plugins: [isolateMainPlugin()]
   }
   ```

4. **출력에 너무 많은 노이즈**
   ```javascript
   // 적극적인 필터링 사용
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

## 결론

mdream은 HTML-to-마크다운 변환을 간단하고 커스터마이즈 가능하게 만드는 강력하고 유연한 라이브러리입니다. 스트리밍 기능, 광범위한 플러그인 시스템, AI 중심 기능으로 현대적인 웹 콘텐츠 처리 워크플로우에 탁월한 선택입니다.

AI 애플리케이션을 구축하거나, 문서 시스템을 만들거나, 대규모 웹 콘텐츠를 처리하든 mdream은 깨끗하고 구조화된 마크다운 출력을 얻는 데 필요한 도구와 유연성을 제공합니다.

핵심 요점:
- 대형 웹사이트와 더 나은 성능을 위해 스트리밍 사용
- 커스텀 처리 요구사항을 위해 플러그인 시스템 활용
- 사용 사례에 적합한 프리셋 선택
- 웹 애플리케이션을 위한 프레임워크 통합 고려
- 프로덕션 사용을 위한 적절한 오류 처리 구현

오늘부터 mdream으로 실험을 시작하고 HTML-to-마크다운 변환 워크플로우를 어떻게 간소화할 수 있는지 확인해보세요!

## 추가 자료

- [mdream GitHub 저장소](https://github.com/harlan-zw/mdream)
- [공식 문서](https://github.com/harlan-zw/mdream/blob/main/README.md)
- [플러그인 개발 가이드](https://github.com/harlan-zw/mdream/tree/main/packages)
- [예제 디렉토리](https://github.com/harlan-zw/mdream/tree/main/examples)

