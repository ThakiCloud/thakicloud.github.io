---
title: "Complete Guide to mdream: Convert Any Website to Clean Markdown for AI & LLMs"
excerpt: "Learn how to use mdream, a powerful Node.js library that converts websites into clean markdown format perfect for AI applications and LLM context generation."
seo_title: "mdream Tutorial: HTML to Markdown Conversion for AI - Thaki Cloud"
seo_description: "Master mdream library for converting websites to markdown. Includes installation, API usage, plugin system, and real-world examples for AI applications and LLM integration."
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
toc_label: "Table of Contents"
lang: en
permalink: /en/tutorials/mdream-html-to-markdown-conversion-tutorial/
canonical_url: "https://thakicloud.github.io/en/tutorials/mdream-html-to-markdown-conversion-tutorial/"
---

⏱️ **Estimated Reading Time**: 8 minutes

## Introduction

In the era of AI and Large Language Models (LLMs), converting web content into clean, structured markdown has become increasingly important. **mdream** is a powerful Node.js library that transforms any website into clean markdown format, making it perfect for AI applications, LLM context generation, and content processing workflows.

Created by [Harlan Wilton](https://github.com/harlan-zw), mdream stands out with its streaming capabilities, extensive plugin system, and specialized presets for different use cases. Whether you're building AI applications, creating documentation, or processing web content at scale, mdream provides the tools you need.

## What is mdream?

mdream is a comprehensive HTML-to-markdown conversion library that offers:

- **Clean Markdown Output**: Produces well-structured markdown perfect for AI consumption
- **Streaming Support**: Efficiently handles large web pages with streaming conversion
- **Plugin System**: Extensible architecture for custom processing needs
- **Framework Integration**: Built-in support for Vite and Nuxt.js
- **AI-Focused Features**: Generates `llms.txt` files for improved AI discoverability

## Installation and Setup

### Basic Installation

```bash
# Using npm
npm install mdream

# Using yarn
yarn add mdream

# Using pnpm
pnpm add mdream
```

### Framework-Specific Installation

For **Vite** projects:
```bash
pnpm install @mdream/vite
```

For **Nuxt.js** projects:
```bash
pnpm add @mdream/nuxt
```

## Core API Usage

### Converting Existing HTML

The simplest way to use mdream is with the `htmlToMarkdown` function:

```javascript
import { htmlToMarkdown } from 'mdream'

// Basic conversion
const html = '<h1>Hello World</h1><p>This is a paragraph.</p>'
const markdown = htmlToMarkdown(html)
console.log(markdown)
// Output:
// # Hello World
// 
// This is a paragraph.
```

### Streaming HTML Conversion

For better performance with large websites, use `streamHtmlToMarkdown`:

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
    // Process chunks as they arrive
    console.log('Received chunk:', chunk.length, 'characters')
  }
  
  return fullMarkdown
}

// Usage
const markdown = await convertWebsite('https://example.com')
```

### Pure HTML Parsing

For applications that need DOM parsing without markdown conversion:

```javascript
import { parseHtml } from 'mdream'

const html = '<div><h1>Title</h1><p>Content</p></div>'
const { events, remainingHtml } = parseHtml(html)

// Process DOM events
events.forEach((event) => {
  if (event.type === 'enter' && event.node.type === 'element') {
    console.log('Entering element:', event.node.tagName)
  }
  if (event.type === 'exit' && event.node.type === 'element') {
    console.log('Exiting element:', event.node.tagName)
  }
})
```

## Plugin System Deep Dive

mdream's plugin system is one of its most powerful features, allowing you to customize every aspect of the conversion process.

### Built-in Plugins

#### 1. Filter Plugin
Exclude or include specific elements:

```javascript
import { htmlToMarkdown } from 'mdream'
import { filterPlugin } from 'mdream/plugins'

const html = `
<div>
  <nav>Navigation menu</nav>
  <main>
    <h1>Main Content</h1>
    <p>Important content here</p>
  </main>
  <footer>Footer content</footer>
</div>
`

const markdown = htmlToMarkdown(html, {
  plugins: [
    filterPlugin({ 
      exclude: ['nav', 'footer', '.sidebar', '#advertisement'] 
    })
  ]
})
// Only main content will be converted
```

#### 2. Frontmatter Plugin
Generate YAML frontmatter from HTML meta tags:

```javascript
import { frontmatterPlugin } from 'mdream/plugins'

const html = `
<html>
<head>
  <title>My Blog Post</title>
  <meta name="description" content="This is a great blog post">
  <meta name="author" content="John Doe">
</head>
<body>
  <h1>Content</h1>
</body>
</html>
`

const markdown = htmlToMarkdown(html, {
  plugins: [frontmatterPlugin()]
})

// Output includes frontmatter:
// ---
// title: My Blog Post
// description: This is a great blog post
// author: John Doe
// ---
// # Content
```

#### 3. Isolation Plugin
Extract main content automatically:

```javascript
import { isolateMainPlugin } from 'mdream/plugins'

const markdown = htmlToMarkdown(html, {
  plugins: [isolateMainPlugin()]
})
// Automatically finds and converts only the main content area
```

#### 4. Tailwind Plugin
Convert Tailwind CSS classes to markdown formatting:

```javascript
import { tailwindPlugin } from 'mdream/plugins'

const html = '<p class="font-bold text-red-500">Important text</p>'
const markdown = htmlToMarkdown(html, {
  plugins: [tailwindPlugin()]
})
// Output: **Important text**
```

### Creating Custom Plugins

Build your own plugins for specific needs:

```javascript
import { createPlugin } from 'mdream/plugins'
import type { ElementNode, TextNode } from 'mdream'

// Example: Add emoji to headings
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
    // Highlight important text
    if (textNode.parent?.attributes?.class?.includes('highlight')) {
      return {
        content: `**${textNode.value}**`,
        skip: false
      }
    }
  }
})

// Usage
const markdown = htmlToMarkdown(html, {
  plugins: [emojiHeadingPlugin]
})
```

### Advanced Plugin Example: Content Extraction

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

// Convert and extract data simultaneously
const markdown = htmlToMarkdown(html, {
  plugins: [dataExtractionPlugin],
  origin: 'https://example.com'
})

console.log('Extracted data:', extractedData)
```

## Presets for Common Use Cases

### Minimal Preset

Perfect for AI applications where you want clean, token-efficient output:

```javascript
import { withMinimalPreset } from 'mdream/preset/minimal'

const options = withMinimalPreset({
  origin: 'https://example.com'
})

const markdown = htmlToMarkdown(html, options)
```

The minimal preset includes:
- `isolateMainPlugin()` - Extracts main content
- `frontmatterPlugin()` - Generates YAML frontmatter
- `tailwindPlugin()` - Converts Tailwind classes
- `filterPlugin()` - Removes non-content elements

### CLI Usage with Presets

```bash
# Use minimal preset via CLI
curl -s https://example.com | npx mdream --preset minimal --origin https://example.com

# Save to file
curl -s https://example.com | npx mdream --preset minimal --origin https://example.com > output.md
```

## Framework Integration

### Vite Integration

Add automatic markdown generation to your Vite project:

```typescript
// vite.config.ts
import { defineConfig } from 'vite'
import MdreamVite from '@mdream/vite'

export default defineConfig({
  plugins: [
    MdreamVite({
      // Custom options
      plugins: [
        // Your custom plugins
      ]
    })
  ]
})
```

Now you can access any route with `.md` extension:
- `/about.html` → `/about.md`
- `/blog/post.html` → `/blog/post.md`

### Nuxt.js Integration

Enable automatic markdown routes and LLMs.txt generation:

```typescript
// nuxt.config.ts
export default defineNuxtConfig({
  modules: [
    '@mdream/nuxt'
  ],
  mdream: {
    // Custom configuration
    preset: 'minimal',
    plugins: [
      // Additional plugins
    ]
  }
})
```

Features:
- Automatic `.md` route variants
- `llms.txt` and `llms-full.txt` generation during static generation
- SEO-friendly markdown versions of your pages

## Real-World Examples

### Example 1: Documentation Site Converter

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
      
      // Extract filename from URL
      const filename = url.split('/').pop() || 'index'
      await fs.writeFile(`docs/${filename}.md`, markdown)
      
      results.push({ url, filename, success: true })
    } catch (error) {
      results.push({ url, success: false, error: error.message })
    }
  }
  
  return results
}

// Usage
const urls = [
  'https://docs.example.com/getting-started',
  'https://docs.example.com/api-reference',
  'https://docs.example.com/examples'
]

const results = await convertDocumentationSite(urls)
console.log('Conversion results:', results)
```

### Example 2: Blog Content Aggregator

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

// Usage
const aggregator = new BlogAggregator()
const blogUrls = [
  'https://blog.example.com/post-1',
  'https://blog.example.com/post-2',
  'https://blog.example.com/post-3'
]

const articles = await aggregator.aggregateBlogs(blogUrls)
console.log(`Processed ${articles.length} articles`)
```

### Example 3: AI Training Data Preparation

```javascript
import { htmlToMarkdown } from 'mdream'
import { withMinimalPreset } from 'mdream/preset/minimal'

class AIDataPreparator {
  constructor(options = {}) {
    this.maxTokens = options.maxTokens || 4000
    this.outputDir = options.outputDir || './ai-training-data'
  }
  
  estimateTokens(text) {
    // Rough estimation: 1 token ≈ 4 characters
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
          // Split into chunks if too large
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
        console.error(`Failed to process ${url}:`, error.message)
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
    console.log(`Saved ${trainingExamples.length} training examples to ${filename}`)
  }
}

// Usage
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

## Performance Optimization

### Streaming for Large Sites

```javascript
import { streamHtmlToMarkdown } from 'mdream'

async function efficientConversion(url) {
  const response = await fetch(url)
  
  if (!response.ok) {
    throw new Error(`HTTP ${response.status}: ${response.statusText}`)
  }
  
  if (!response.body) {
    throw new Error('No response body available for streaming')
  }
  
  const markdownGenerator = streamHtmlToMarkdown(response.body, {
    origin: url,
    plugins: [
      // Only essential plugins for better performance
    ]
  })
  
  let result = ''
  let chunkCount = 0
  
  for await (const chunk of markdownGenerator) {
    result += chunk
    chunkCount++
    
    // Optional: Progress reporting
    if (chunkCount % 10 === 0) {
      console.log(`Processed ${chunkCount} chunks...`)
    }
  }
  
  return result
}
```

### Batch Processing

```javascript
import pLimit from 'p-limit'

const limit = pLimit(5) // Process 5 URLs concurrently

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

## Best Practices

### 1. Choose the Right Approach

```javascript
// For small HTML snippets
const markdown = htmlToMarkdown(html)

// For large web pages
const markdown = await streamHtmlToMarkdown(htmlStream, { origin })

// For DOM analysis without markdown
const { events } = parseHtml(html)
```

### 2. Plugin Selection

```javascript
// For AI/LLM applications
const options = withMinimalPreset({ origin })

// For documentation conversion
const options = {
  plugins: [
    isolateMainPlugin(),
    frontmatterPlugin(),
    filterPlugin({ exclude: ['nav', 'footer'] })
  ]
}

// For content analysis
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

### 3. Error Handling

```javascript
async function robustConversion(url) {
  try {
    const response = await fetch(url, {
      timeout: 10000, // 10 second timeout
      headers: {
        'User-Agent': 'mdream-converter/1.0'
      }
    })
    
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`)
    }
    
    const contentType = response.headers.get('content-type')
    if (!contentType?.includes('text/html')) {
      throw new Error(`Unexpected content type: ${contentType}`)
    }
    
    return await streamHtmlToMarkdown(response.body, {
      origin: url
    })
  } catch (error) {
    console.error(`Failed to convert ${url}:`, error.message)
    return null
  }
}
```

## Troubleshooting

### Common Issues

1. **Memory Issues with Large Pages**
   ```javascript
   // Use streaming instead of loading entire HTML
   const stream = streamHtmlToMarkdown(htmlStream, options)
   ```

2. **Malformed HTML**
   ```javascript
   // mdream handles malformed HTML gracefully
   const markdown = htmlToMarkdown(malformedHtml, {
     // Results may vary based on HTML structure
   })
   ```

3. **Missing Content**
   ```javascript
   // Check if content is in <main> tags
   const options = {
     plugins: [isolateMainPlugin()]
   }
   ```

4. **Too Much Noise in Output**
   ```javascript
   // Use aggressive filtering
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

## Conclusion

mdream is a powerful and flexible library that makes HTML-to-markdown conversion straightforward and customizable. Its streaming capabilities, extensive plugin system, and AI-focused features make it an excellent choice for modern web content processing workflows.

Whether you're building AI applications, creating documentation systems, or processing web content at scale, mdream provides the tools and flexibility you need to get clean, structured markdown output.

Key takeaways:
- Use streaming for large websites and better performance
- Leverage the plugin system for custom processing needs
- Choose appropriate presets for your use case
- Consider framework integration for web applications
- Implement proper error handling for production use

Start experimenting with mdream today and see how it can streamline your HTML-to-markdown conversion workflows!

## Additional Resources

- [mdream GitHub Repository](https://github.com/harlan-zw/mdream)
- [Official Documentation](https://github.com/harlan-zw/mdream/blob/main/README.md)
- [Plugin Development Guide](https://github.com/harlan-zw/mdream/tree/main/packages)
- [Examples Directory](https://github.com/harlan-zw/mdream/tree/main/examples)

