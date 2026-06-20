---
title: "MCP-UI: دليل شامل لبناء واجهات الذكاء الاصطناعي من الجيل القادم"
excerpt: "تعلم كيفية تطوير واجهات تفاعلية باستخدام بروتوكول Model Context Protocol. بناء واجهات ديناميكية تعزز تفاعل وكلاء الذكاء الاصطناعي مع مكونات الوقت الفعلي والتكامل السلس."
seo_title: "دروس MCP-UI: دليل تطوير واجهات الذكاء الاصطناعي - Thaki Cloud"
seo_description: "دليل شامل لتطوير MCP-UI. تعلم بناء واجهات الذكاء الاصطناعي التفاعلية باستخدام TypeScript و Python و Ruby. يتضمن أمثلة عملية واستراتيجيات النشر."
date: 2025-10-03
categories:
  - tutorials
tags:
  - mcp-ui
  - ai-interface
  - typescript
  - python
  - ruby
  - model-context-protocol
  - ui-development
author_profile: true
toc: true
toc_label: "جدول المحتويات"
canonical_url: "https://thakicloud.github.io/ar/tutorials/mcp-ui-next-generation-ai-interface-tutorial/"
published: false
---

⏱️ **وقت القراءة المتوقع**: 15 دقيقة

## مقدمة

لقد أحدث بروتوكول Model Context Protocol (MCP) ثورة في طريقة تفاعل وكلاء الذكاء الاصطناعي مع الأنظمة الخارجية. الآن، مع **MCP-UI**، يمكننا إنشاء واجهات مستخدم غنية وتفاعلية تتكامل بسلاسة مع سير عمل الذكاء الاصطناعي. سيرشدك هذا الدرس خلال بناء واجهات الذكاء الاصطناعي من الجيل القادم باستخدام إطار عمل MCP-UI.

## ما هو MCP-UI؟

MCP-UI هو إطار عمل مبتكر يمكّن المطورين من إنشاء واجهات مستخدم تفاعلية فوق بروتوكول Model Context Protocol. يسد الفجوة بين وكلاء الذكاء الاصطناعي وتجربة المستخدم من خلال توفير:

- **مكونات واجهة المستخدم الديناميكية**: إنشاء عناصر تفاعلية تستجيب لإجراءات وكيل الذكاء الاصطناعي
- **دعم متعدد اللغات**: SDKs متاحة لـ TypeScript و Python و Ruby
- **تنفيذ آمن**: تنفيذ iframe محاط بالحماية للأمان المعزز
- **أنواع محتوى مرنة**: دعم HTML والروابط الخارجية ومعالجة DOM البعيدة

## المتطلبات الأساسية

قبل أن نبدأ، تأكد من وجود:

- Node.js 18+ مثبت
- معرفة أساسية بـ TypeScript/JavaScript
- فهم أساسيات MCP
- Git لإدارة الإصدارات

## إعداد بيئة التطوير

### 1. تهيئة المشروع

```bash
# إنشاء دليل مشروع جديد
mkdir mcp-ui-tutorial
cd mcp-ui-tutorial

# تهيئة مشروع npm
npm init -y

# تثبيت تبعيات MCP-UI
npm install @mcp-ui/server @mcp-ui/client
npm install -D typescript @types/node ts-node
```

### 2. تكوين TypeScript

إنشاء ملف `tsconfig.json`:

```json
{
  "compilerOptions": {
    "target": "ES2020",
    "module": "commonjs",
    "lib": ["ES2020"],
    "outDir": "./dist",
    "rootDir": "./src",
    "strict": true,
    "esModuleInterop": true,
    "skipLibCheck": true,
    "forceConsistentCasingInFileNames": true,
    "resolveJsonModule": true
  },
  "include": ["src/**/*"],
  "exclude": ["node_modules", "dist"]
}
```

## بناء أول خادم MCP-UI

### 1. إنشاء هيكل الخادم

```bash
mkdir src
touch src/server.ts src/ui-resources.ts
```

### 2. تنفيذ موارد واجهة المستخدم

إنشاء ملف `src/ui-resources.ts`:

```typescript
import { createUIResource } from '@mcp-ui/server';

// مكون ترحيب HTML بسيط
export const greetingResource = createUIResource({
  uri: 'ui://greeting/welcome',
  content: {
    type: 'rawHtml',
    htmlString: `
      <div style="padding: 20px; border-radius: 8px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; font-family: Arial, sans-serif;">
        <h2>🚀 مرحباً بك في MCP-UI!</h2>
        <p>هذا هو أول مكون واجهة ذكاء اصطناعي تفاعلي لك.</p>
        <button onclick="alert('مرحباً من MCP-UI!')" style="padding: 10px 20px; background: white; color: #667eea; border: none; border-radius: 4px; cursor: pointer;">
          اضغط هنا!
        </button>
      </div>
    `
  },
  encoding: 'text'
});

// مكون لوحة تحكم تفاعلية
export const dashboardResource = createUIResource({
  uri: 'ui://dashboard/analytics',
  content: {
    type: 'rawHtml',
    htmlString: `
      <div style="padding: 20px; font-family: Arial, sans-serif;">
        <h3>📊 لوحة تحليلات وكيل الذكاء الاصطناعي</h3>
        <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px; margin-top: 20px;">
          <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #28a745;">
            <h4 style="margin: 0; color: #28a745;">الجلسات النشطة</h4>
            <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">42</p>
          </div>
          <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #007bff;">
            <h4 style="margin: 0; color: #007bff;">إجمالي الطلبات</h4>
            <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">1,337</p>
          </div>
          <div style="padding: 15px; background: #f8f9fa; border-radius: 8px; border-left: 4px solid #ffc107;">
            <h4 style="margin: 0; color: #ffc107;">وقت الاستجابة</h4>
            <p style="font-size: 24px; margin: 10px 0; font-weight: bold;">125ms</p>
          </div>
        </div>
      </div>
    `
  },
  encoding: 'text'
});

// تكامل الرابط الخارجي
export const externalResource = createUIResource({
  uri: 'ui://external/documentation',
  content: {
    type: 'externalUrl',
    iframeUrl: 'https://mcpui.dev'
  },
  encoding: 'text'
});

// مكون DOM البعيد التفاعلي
export const interactiveResource = createUIResource({
  uri: 'ui://interactive/tool-caller',
  content: {
    type: 'remoteDom',
    script: `
      const container = document.createElement('div');
      container.style.cssText = 'padding: 20px; background: #f0f8ff; border-radius: 8px; font-family: Arial, sans-serif;';
      
      const title = document.createElement('h3');
      title.textContent = '🔧 مستدعي الأدوات التفاعلي';
      title.style.cssText = 'margin: 0 0 15px 0; color: #2c3e50;';
      
      const button = document.createElement('button');
      button.textContent = 'تنفيذ أداة الذكاء الاصطناعي';
      button.style.cssText = 'padding: 12px 24px; background: #3498db; color: white; border: none; border-radius: 6px; cursor: pointer; font-size: 16px;';
      
      const status = document.createElement('div');
      status.style.cssText = 'margin-top: 15px; padding: 10px; background: #ecf0f1; border-radius: 4px; font-size: 14px;';
      status.textContent = 'جاهز للتنفيذ...';
      
      button.addEventListener('click', () => {
        status.textContent = 'تنفيذ استدعاء الأداة...';
        status.style.background = '#fff3cd';
        
        // إرسال استدعاء الأداة للوالد
        window.parent.postMessage({
          type: 'tool',
          payload: {
            toolName: 'aiInteraction',
            params: {
              action: 'process-data',
              timestamp: new Date().toISOString(),
              source: 'mcp-ui-interactive'
            }
          }
        }, '*');
        
        setTimeout(() => {
          status.textContent = 'تم تنفيذ الأداة بنجاح! ✅';
          status.style.background = '#d4edda';
        }, 1000);
      });
      
      container.appendChild(title);
      container.appendChild(button);
      container.appendChild(status);
      root.appendChild(container);
    `,
    framework: 'react'
  },
  encoding: 'text'
});
```

### 3. تنفيذ خادم MCP

إنشاء ملف `src/server.ts`:

```typescript
import { Server } from '@modelcontextprotocol/sdk/server/index.js';
import { StdioServerTransport } from '@modelcontextprotocol/sdk/server/stdio.js';
import {
  CallToolRequestSchema,
  ListResourcesRequestSchema,
  ListToolsRequestSchema,
  ReadResourceRequestSchema,
} from '@modelcontextprotocol/sdk/types.js';
import {
  greetingResource,
  dashboardResource,
  externalResource,
  interactiveResource
} from './ui-resources.js';

class MCPUIServer {
  private server: Server;

  constructor() {
    this.server = new Server(
      {
        name: 'mcp-ui-tutorial-server',
        version: '1.0.0',
      },
      {
        capabilities: {
          resources: {},
          tools: {},
        },
      }
    );

    this.setupHandlers();
  }

  private setupHandlers() {
    // قائمة الموارد المتاحة
    this.server.setRequestHandler(ListResourcesRequestSchema, async () => {
      return {
        resources: [
          {
            uri: greetingResource.uri,
            name: 'ترحيب الترحيب',
            description: 'مكون واجهة مستخدم ترحيبي للمستخدمين الجدد',
            mimeType: 'text/html'
          },
          {
            uri: dashboardResource.uri,
            name: 'لوحة التحليلات',
            description: 'لوحة تحكم تفاعلية تظهر مقاييس وكيل الذكاء الاصطناعي',
            mimeType: 'text/html'
          },
          {
            uri: externalResource.uri,
            name: 'وثائق MCP-UI',
            description: 'وثائق خارجية في iframe',
            mimeType: 'text/html'
          },
          {
            uri: interactiveResource.uri,
            name: 'مستدعي الأدوات التفاعلي',
            description: 'مكون يمكنه تشغيل استدعاءات الأدوات',
            mimeType: 'text/html'
          }
        ]
      };
    });

    // قراءة مورد محدد
    this.server.setRequestHandler(ReadResourceRequestSchema, async (request) => {
      const { uri } = request.params;

      const resources = {
        [greetingResource.uri]: greetingResource,
        [dashboardResource.uri]: dashboardResource,
        [externalResource.uri]: externalResource,
        [interactiveResource.uri]: interactiveResource
      };

      const resource = resources[uri];
      if (!resource) {
        throw new Error(`المورد غير موجود: ${uri}`);
      }

      return {
        contents: [
          {
            uri: resource.uri,
            mimeType: 'application/json',
            text: JSON.stringify(resource.content)
          }
        ]
      };
    });

    // قائمة الأدوات المتاحة
    this.server.setRequestHandler(ListToolsRequestSchema, async () => {
      return {
        tools: [
          {
            name: 'aiInteraction',
            description: 'التعامل مع أحداث التفاعل مع الذكاء الاصطناعي من مكونات واجهة المستخدم',
            inputSchema: {
              type: 'object',
              properties: {
                action: { type: 'string' },
                timestamp: { type: 'string' },
                source: { type: 'string' }
              },
              required: ['action']
            }
          },
          {
            name: 'generateUIComponent',
            description: 'إنشاء مكون واجهة مستخدم جديد ديناميكياً',
            inputSchema: {
              type: 'object',
              properties: {
                componentType: { type: 'string' },
                title: { type: 'string' },
                content: { type: 'string' }
              },
              required: ['componentType', 'title']
            }
          }
        ]
      };
    });

    // التعامل مع استدعاءات الأدوات
    this.server.setRequestHandler(CallToolRequestSchema, async (request) => {
      const { name, arguments: args } = request.params;

      switch (name) {
        case 'aiInteraction':
          return {
            content: [
              {
                type: 'text',
                text: `تم معالجة التفاعل مع الذكاء الاصطناعي: ${args.action} في ${args.timestamp} من ${args.source}`
              }
            ]
          };

        case 'generateUIComponent':
          const newComponent = this.generateDynamicComponent(args);
          return {
            content: [
              {
                type: 'resource',
                resource: newComponent
              }
            ]
          };

        default:
          throw new Error(`أداة غير معروفة: ${name}`);
      }
    });
  }

  private generateDynamicComponent(args: any) {
    const { componentType, title, content = '' } = args;
    
    let htmlContent = '';
    
    switch (componentType) {
      case 'alert':
        htmlContent = `
          <div style="padding: 20px; background: #fff3cd; border: 1px solid #ffeaa7; border-radius: 8px; color: #856404;">
            <h4>⚠️ ${title}</h4>
            <p>${content}</p>
          </div>
        `;
        break;
      case 'success':
        htmlContent = `
          <div style="padding: 20px; background: #d4edda; border: 1px solid #c3e6cb; border-radius: 8px; color: #155724;">
            <h4>✅ ${title}</h4>
            <p>${content}</p>
          </div>
        `;
        break;
      default:
        htmlContent = `
          <div style="padding: 20px; background: #f8f9fa; border-radius: 8px;">
            <h4>${title}</h4>
            <p>${content}</p>
          </div>
        `;
    }

    return {
      uri: `ui://dynamic/${Date.now()}`,
      content: {
        type: 'rawHtml',
        htmlString: htmlContent
      },
      encoding: 'text'
    };
  }

  async run() {
    const transport = new StdioServerTransport();
    await this.server.connect(transport);
    console.error('خادم دروس MCP-UI يعمل على stdio');
  }
}

// بدء الخادم
const server = new MCPUIServer();
server.run().catch(console.error);
```

### 4. إضافة سكريبت الحزمة

تحديث `package.json`:

```json
{
  "name": "mcp-ui-tutorial",
  "version": "1.0.0",
  "scripts": {
    "build": "tsc",
    "start": "node dist/server.js",
    "dev": "ts-node src/server.ts",
    "test": "echo \"لا توجد اختبارات بعد\" && exit 0"
  },
  "dependencies": {
    "@mcp-ui/server": "^5.12.0",
    "@mcp-ui/client": "^5.12.0",
    "@modelcontextprotocol/sdk": "^0.5.0"
  },
  "devDependencies": {
    "typescript": "^5.0.0",
    "@types/node": "^20.0.0",
    "ts-node": "^10.9.0"
  }
}
```

## بناء تطبيق العميل

### 1. إنشاء هيكل العميل

```bash
mkdir client
cd client
npm init -y
npm install @mcp-ui/client react react-dom @types/react @types/react-dom
npm install -D webpack webpack-cli webpack-dev-server html-webpack-plugin ts-loader css-loader
```

### 2. تنفيذ عميل React

إنشاء ملف `client/src/App.tsx`:

```typescript
import React, { useState, useEffect } from 'react';
import { UIResourceRenderer } from '@mcp-ui/client';

// تعريف واجهة المورد
interface MCPResource {
  type: string;
  resource: {
    uri: string;
    content: any;
  };
}

const App: React.FC = () => {
  const [resources, setResources] = useState<MCPResource[]>([]);
  const [selectedResource, setSelectedResource] = useState<MCPResource | null>(null);

  // إعداد الموارد الوهمية للعرض التوضيحي
  useEffect(() => {
    // إنشاء موارد تجريبية
    const mockResources = [
      // مورد الترحيب
      // مورد لوحة التحكم
    ];

    setResources(mockResources);
    setSelectedResource(mockResources[0]);
  }, []);

  const handleUIAction = (result: any) => {
    console.log('تم استلام إجراء واجهة المستخدم:', result);
    // معالجة إجراءات واجهة المستخدم هنا
  };

  return (
    <div className="app-container">
      <h1>🎯 عميل دروس MCP-UI</h1>
      
      <div className="main-layout">
        {/* محدد الموارد */}
        <div className="resource-selector">
          <h3>الموارد المتاحة</h3>
          {/* قائمة الموارد */}
        </div>

        {/* عارض الموارد */}
        <div className="resource-renderer">
          <h3>المكون المعروض</h3>
          {selectedResource && (
            <UIResourceRenderer
              resource={selectedResource.resource}
              onUIAction={handleUIAction}
            />
          )}
        </div>
      </div>
    </div>
  );
};

export default App;
```

## اختبار تنفيذ MCP-UI

### 1. بناء وتشغيل الخادم

```bash
# بناء خادم TypeScript
npm run build

# تشغيل الخادم
npm run dev
```

### 2. الاختبار باستخدام UI Inspector

تثبيت مفتش MCP-UI للاختبار:

```bash
npx @mcp-ui/inspector
```

### 3. الاتصال بالخادم

1. فتح UI Inspector
2. إضافة تكوين الخادم
3. اختبار المكونات التفاعلية
4. التحقق من عمل استدعاءات الأدوات بشكل صحيح

## الميزات المتقدمة

### 1. تكامل Python

إنشاء خادم Python MCP-UI:

```python
from mcp_ui_server import create_ui_resource
import asyncio
from mcp import Server, types

# إنشاء موارد واجهة المستخدم
html_resource = create_ui_resource({
    "uri": "ui://python/greeting",
    "content": {
        "type": "rawHtml",
        "htmlString": "<h2>مرحباً من Python MCP-UI!</h2>"
    },
    "encoding": "text"
})

server = Server("python-mcp-ui-server")

@server.list_resources()
async def list_resources() -> list[types.Resource]:
    return [
        types.Resource(
            uri=html_resource["uri"],
            name="ترحيب Python",
            mimeType="text/html"
        )
    ]

@server.read_resource()
async def read_resource(uri: str) -> str:
    if uri == html_resource["uri"]:
        return json.dumps(html_resource["content"])
    raise ValueError(f"المورد غير موجود: {uri}")

if __name__ == "__main__":
    asyncio.run(server.run())
```

### 2. تكامل Ruby

إنشاء خادم Ruby MCP-UI:

```ruby
require 'mcp_ui_server'
require 'mcp'

# إنشاء مورد واجهة المستخدم
html_resource = McpUiServer.create_ui_resource(
  uri: 'ui://ruby/greeting',
  content: {
    type: :raw_html,
    htmlString: '<h2>مرحباً من Ruby MCP-UI!</h2>'
  },
  encoding: :text
)

server = MCP::Server.new('ruby-mcp-ui-server')

server.list_resources do
  [
    {
      uri: html_resource[:uri],
      name: 'ترحيب Ruby',
      mimeType: 'text/html'
    }
  ]
end

server.read_resource do |uri|
  if uri == html_resource[:uri]
    html_resource[:content].to_json
  else
    raise "المورد غير موجود: #{uri}"
  end
end

server.run
```

## اعتبارات الأمان

### 1. التنفيذ المحاط بالحماية

يقوم MCP-UI بتنفيذ جميع المحتويات في iframes محاطة بالحماية للأمان:

```typescript
// يتم تطويق المحتوى تلقائياً بالحماية
const secureResource = createUIResource({
  uri: 'ui://secure/component',
  content: {
    type: 'rawHtml',
    htmlString: `
      <!-- يعمل في بيئة آمنة محاطة بالحماية -->
      <script>
        // وصول محدود لنافذة الوالد
        console.log('بيئة تنفيذ آمنة');
      </script>
    `
  },
  encoding: 'text'
});
```

### 2. التحقق من الرسائل

تحقق دائماً من الرسائل القادمة من مكونات واجهة المستخدم:

```typescript
const handleUIAction = (result: any) => {
  // التحقق من بنية الرسالة
  if (!result.type || !result.payload) {
    console.error('تنسيق إجراء واجهة المستخدم غير صالح');
    return;
  }

  // تنظيف المعاملات
  const sanitizedPayload = {
    toolName: String(result.payload.toolName || ''),
    params: result.payload.params || {}
  };

  // معالجة الإجراء المتحقق منه
  processToolCall(sanitizedPayload);
};
```

## استراتيجيات النشر

### 1. النشر المحتوى

إنشاء `Dockerfile`:

```dockerfile
FROM node:18-alpine

WORKDIR /app
COPY package*.json ./
RUN npm ci --only=production

COPY dist/ ./dist/
EXPOSE 3000

CMD ["npm", "start"]
```

### 2. النشر بدون خادم

النشر على Cloudflare Workers:

```typescript
export default {
  async fetch(request: Request): Promise<Response> {
    const server = new MCPUIServer();
    
    if (request.method === 'POST') {
      const body = await request.json();
      const response = await server.handleRequest(body);
      return new Response(JSON.stringify(response));
    }
    
    return new Response('خادم MCP-UI', { status: 200 });
  }
};
```

## أفضل الممارسات

### 1. تصميم المكونات

- **التركيز على المكونات**: يجب أن يكون لكل مورد واجهة مستخدم مسؤولية واحدة
- **استخدام HTML الدلالي**: ضمان إمكانية الوصول والبنية المناسبة
- **تنفيذ حدود الأخطاء**: التعامل مع الفشل بأناقة
- **تحسين الأداء**: تقليل حجم المورد والتعقيد

### 2. إدارة الحالة

```typescript
// استخدام أنماط حالة متسقة
const createStatefulComponent = (initialState: any) => {
  return createUIResource({
    uri: 'ui://stateful/component',
    content: {
      type: 'remoteDom',
      script: `
        let state = ${JSON.stringify(initialState)};
        
        function updateState(newState) {
          state = { ...state, ...newState };
          render();
        }
        
        function render() {
          // تحديث DOM بناءً على الحالة
        }
        
        render();
      `,
      framework: 'react'
    },
    encoding: 'text'
  });
};
```

### 3. معالجة الأخطاء

```typescript
// تنفيذ معالجة شاملة للأخطاء
const robustResource = createUIResource({
  uri: 'ui://robust/component',
  content: {
    type: 'remoteDom',
    script: `
      try {
        // منطق المكون هنا
      } catch (error) {
        console.error('خطأ في المكون:', error);
        root.innerHTML = '<div style="color: red;">فشل تحميل المكون</div>';
      }
    `,
    framework: 'react'
  },
  encoding: 'text'
});
```

## استكشاف الأخطاء وإصلاحها

### 1. المورد غير موجود

```bash
# فحص تنسيق URI للمورد
Error: المورد غير موجود: ui://invalid/uri

# الحل: التأكد من تنسيق URI المناسب
uri: 'ui://namespace/component-name'
```

### 2. قيود الحماية

```javascript
// المشكلة: لا يمكن الوصول لنافذة الوالد
window.parent.someFunction(); // ❌ محجوب

// الحل: استخدام postMessage API
window.parent.postMessage({
  type: 'tool',
  payload: { /* البيانات */ }
}, '*'); // ✅ مسموح
```

### 3. سياسة أمان المحتوى

```html
<!-- إضافة رؤوس CSP للأمان -->
<meta http-equiv="Content-Security-Policy" 
      content="default-src 'self'; script-src 'unsafe-inline';">
```

## الخلاصة

يمثل MCP-UI تقدماً كبيراً في تطوير واجهات الذكاء الاصطناعي، مما يمكّن المطورين من إنشاء تجارب غنية وتفاعلية تتكامل بسلاسة مع وكلاء الذكاء الاصطناعي. من خلال اتباع هذا الدرس، تعلمت:

- كيفية إعداد خوادم MCP-UI بلغات متعددة
- إنشاء أنواع مختلفة من موارد واجهة المستخدم
- تنفيذ مكونات آمنة وتفاعلية
- أفضل الممارسات للنشر والصيانة

مرونة الإطار وميزات الأمان تجعله خياراً ممتازاً لبناء واجهات الذكاء الاصطناعي من الجيل القادم. مع استمرار تطور النظام البيئي، سيلعب MCP-UI دوراً حاسماً في تشكيل كيفية تفاعل المستخدمين مع أنظمة الذكاء الاصطناعي.

## الخطوات التالية

1. **استكشاف المكونات المتقدمة**: تجريب أنماط واجهة المستخدم المعقدة
2. **اختبار التكامل**: الاختبار مع مضيفي MCP مختلفين
3. **تحسين الأداء**: تحليل وتحسين المكونات
4. **مساهمة المجتمع**: مشاركة المكونات مع مجتمع MCP-UI

## المراجع

- [وثائق MCP-UI الرسمية](https://mcpui.dev)
- [مستودع GitHub](https://github.com/idosal/mcp-ui)
- [مواصفات بروتوكول MCP](https://modelcontextprotocol.io)
- [أمثلة المجتمع](https://github.com/idosal/mcp-ui/tree/main/examples)

---

*هل أنت مستعد لبناء مستقبل واجهات الذكاء الاصطناعي؟ ابدأ التجريب مع MCP-UI اليوم وأنشئ تجارب ستحدد الجيل القادم من التفاعل بين الإنسان والذكاء الاصطناعي!*
